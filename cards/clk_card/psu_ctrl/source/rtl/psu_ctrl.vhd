-- Copyright (c) 2003 SCUBA-2 Project
--                  All Rights Reserved
--
--  THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF THE SCUBA-2 Project
--  The copyright notice above does not evidence any
--  actual or intended publication of such source code.
--
--  SOURCE CODE IS PROVIDED "AS IS". ALL EXPRESS OR IMPLIED CONDITIONS,
--  REPRESENTATIONS, AND WARRANTIES, INCLUDING ANY IMPLIED WARRANT OF
--  MERCHANTABILITY, SATISFACTORY QUALITY, FITNESS FOR A PARTICULAR
--  PURPOSE, OR NON-INFRINGEMENT, ARE DISCLAIMED, EXCEPT TO THE EXTENT
--  THAT SUCH DISCLAIMERS ARE HELD TO BE LEGALLY INVALID.
--
-- For the purposes of this code the SCUBA-2 Project consists of the
-- following organisations.
--
-- UKATC, Royal Observatory, Blackford Hill Edinburgh EH9 3HJ
-- UBC,   University of British Columbia, Physics & Astronomy Department,
--        Vancouver BC, V6T 1Z1
--
-- $Id: psu_ctrl.vhd,v 1.7 2007/07/25 18:37:04 bburger Exp $
--
-- Project:       SCUBA-2
-- Author:        Bryce Burger
-- Organization:  UBC
--
-- Description:
-- Wishbone slave interface to the Power Supply Unit Controller.
--
-- Revision history:
-- $Log: psu_ctrl.vhd,v $
-- Revision 1.7  2007/07/25 18:37:04  bburger
-- BB:
-- - added the err_o signal to the psu_ctrl interface to assert a wishbone error when dispatch attempts to write to the psc_status register
-- - implemented a set_flag/ clr_flag register to monitor the up-to-dateness of the status register and trigger a stale bit if it is not.
--
-- Revision 1.6  2006/09/06 00:22:32  bburger
-- Bryce:  Ironed out some bugs
--
-- Revision 1.5  2006/08/12 00:02:10  bburger
-- Bryce:  First simulated version of the Power Supply Controller Wishbone slave
--
-- Revision 1.4  2006/08/01 00:34:38  bburger
-- Bryce:  Interim committal -- this file is in progress
--
-- Revision 1.3  2006/07/28 22:40:24  bburger
-- Bryce:  beginning simulation
--
-- Revision 1.2  2006/07/27 00:04:30  bburger
-- Bryce:  New
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

--library work;
--use work.bc_dac_ctrl_wbs_pack.all;

library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;

library components;
use components.component_pack.all;

entity psu_ctrl is
port(
   -- Clock and Reset:
   clk_i         : in std_logic;
   clk_n_i       : in std_logic;
   rst_i         : in std_logic;

   -- Wishbone Interface:
   dat_i         : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   addr_i        : in std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
   tga_i         : in std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
   we_i          : in std_logic;
   stb_i         : in std_logic;
   cyc_i         : in std_logic;
   dat_o         : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   ack_o         : out std_logic;
   err_o         : out std_logic;

   ------------------------------
   -- SPI Interface
   ------------------------------
   mosi_i        : in std_logic;   -- Master Output/ Slave Input
   sclk_i        : in std_logic;   -- Serial Clock
   ccss_i        : in std_logic;   -- Clock Card Slave Select
   miso_o        : out std_logic;  -- Master Input/ Slave Output
   sreq_o        : out std_logic   -- Service Request
);
end psu_ctrl;

architecture top of psu_ctrl is

   -- The size in bits of the status header.
   constant COMMAND_LENGTH    : integer   := 64;
   constant STATUS_LENGTH     : integer   := 288;

   constant HIGH              : std_logic :='1';
   constant LOW               : std_logic :='0';
   constant INT_ZERO          : integer   := 0;
   constant STATUS_ADDR_WIDTH : integer   := 6;

   constant SLV_ZERO          : std_logic_vector(WB_DATA_WIDTH-1 downto 0) := (others => '0');

   constant ASCII_C    : std_logic_vector(7 downto 0) := "01000011";
   constant ASCII_P    : std_logic_vector(7 downto 0) := "01010000";
   constant ASCII_R    : std_logic_vector(7 downto 0) := "01010010";
   constant ASCII_M    : std_logic_vector(7 downto 0) := "01001101";
   constant ASCII_T    : std_logic_vector(7 downto 0) := "01010100";
   constant ASCII_O    : std_logic_vector(7 downto 0) := "01001111";
   constant ASCII_NULL : std_logic_vector(7 downto 0) := "00000000";

   component ram_32bit_x_64
   PORT
   (
      clock    : IN STD_LOGIC ;
      data     : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
      rdaddress      : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
      wraddress      : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
      wren     : IN STD_LOGIC  := '1';
      q     : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
   );
   END component;

   -- FSM req/ ack signals
   signal brst_mce_req  : std_logic;
   signal brst_mce_set  : std_logic;
   signal brst_mce_clr  : std_logic;
   signal cycle_pow_req : std_logic;
   signal cycle_pow_set : std_logic;
   signal cycle_pow_clr : std_logic;
   signal cut_pow_req   : std_logic;
   signal cut_pow_set   : std_logic;
   signal cut_pow_clr   : std_logic;
   signal update_status : std_logic;
   signal status_done   : std_logic;
   signal timeout_clr   : std_logic;
   signal timeout_count : integer;

   signal req_reg       : std_logic_vector(3 downto 0);
   signal req_reg_load  : std_logic;

   -- SPI interface signals
   signal mosi      : std_logic;   -- Master Output/ Slave Input
   signal sclk      : std_logic;   -- Serial Clock
   signal ccss      : std_logic;   -- Clock Card Slave Select
   signal mosi_temp : std_logic;   -- Master Output/ Slave Input
   signal sclk_temp : std_logic;   -- Serial Clock
   signal ccss_temp : std_logic;   -- Clock Card Slave Select
   signal miso      : std_logic;   -- Master Input/ Slave Output
   signal sreq      : std_logic;   -- Service Request

   -- RAM interface signals
   signal status_wren : std_logic;
   signal status_addr : std_logic_vector(STATUS_ADDR_WIDTH-1 downto 0);
   signal bit_ctr_count_slv : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal status_data : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal status_data2 : std_logic_vector(WB_DATA_WIDTH-1 downto 0);

   -- FSM inputs
   signal wr_cmd : std_logic;
   signal rd_cmd : std_logic;

   -- WBS states:
   type states is (IDLE, WR, RD1, RD2);
   signal current_state : states;
   signal next_state    : states;
   type out_states is (IDLE, TX_RX, CLK_LOW, CLK_HIGH, DONE);
   signal current_out_state : out_states;
   signal next_out_state    : out_states;

   -- Bit Counter signals
   signal bit_ctr_count        : integer range 0 to STATUS_LENGTH;
   signal bit_ctr_ena          : std_logic; -- enables the counter which controls the enable line to the CRC block.  The counter should only be functional when there is a to calculate.
   signal bit_ctr_load         : std_logic; --Not part of the interface to the crc block; enables sh_reg and bit_ctr.
   signal bit_capture          : std_logic;

   -- Shift Register Signals
   signal spi_tx_word         : std_logic_vector(COMMAND_LENGTH-1 downto 0);
   signal spi_rx_word         : std_logic_vector(WB_DATA_WIDTH-1 downto 0);

   -- PSU update flag
   signal set_flag : std_logic;
   signal clr_flag : std_logic;
   signal status_block_updated : std_logic;

begin

   ------------------------------------------------------------
   -- PSC Status RAM
   ------------------------------------------------------------
   bit_ctr_count_slv <= std_logic_vector(conv_unsigned(bit_ctr_count, WB_DATA_WIDTH));
   status_addr <= bit_ctr_count_slv(STATUS_ADDR_WIDTH+5-1 downto 5);

   status_ram : ram_32bit_x_64
   port map
   (
      clock     => clk_i,
      data      => spi_rx_word,
      rdaddress => tga_i      (STATUS_ADDR_WIDTH-1 downto 0),
      wraddress => status_addr(STATUS_ADDR_WIDTH-1 downto 0),
      wren      => status_wren,
      q         => status_data
   );

   sh_reg_rx: shift_reg
   generic map(
      WIDTH      => WB_DATA_WIDTH
   )
   port map(
      clk_i      => clk_i,
      rst_i      => rst_i,
      ena_i      => bit_capture,
      load_i     => bit_ctr_load,
      clr_i      => LOW,
      shr_i      => LOW,
      serial_i   => mosi,
      serial_o   => open,
      parallel_i => SLV_ZERO,
      parallel_o => spi_rx_word
   );

   -- miso is inverted by an on-board buffer before the signal gets to the PSUC
   -- To rectify the signal received by the PSUC, it is inverted here as well.
   miso_o <= not miso;
   sreq_o <= not sreq;

   sh_reg_tx: shift_reg
   generic map(
      WIDTH      => COMMAND_LENGTH
   )
   port map(
      clk_i      => clk_i,
      rst_i      => rst_i,
      ena_i      => bit_ctr_ena,
      load_i     => bit_ctr_load,
      clr_i      => LOW,
      shr_i      => LOW,
      serial_i   => LOW,
      serial_o   => miso,
      parallel_i => spi_tx_word,
      parallel_o => open
   );

   bit_ctr: counter
   generic map(
      MAX         => STATUS_LENGTH,
      STEP_SIZE   => 1,
      WRAP_AROUND => LOW,
      UP_COUNTER  => HIGH
   )
   port map(
      clk_i       => clk_i,
      rst_i       => rst_i,
      ena_i       => bit_ctr_ena,
      load_i      => bit_ctr_load,
      count_i     => INT_ZERO,
      count_o     => bit_ctr_count
   );

   ---------------------------------------------------------
   -- Status Block Update Timer
   ---------------------------------------------------------
   timeout_timer : us_timer
   port map(clk => clk_i,
            timer_reset_i => timeout_clr,
            timer_count_o => timeout_count);

   ------------------------------------------------------------
   -- Registers
   ------------------------------------------------------------
   process(rst_i, clk_i)
   begin
      if(rst_i = '1') then
         brst_mce_req  <= '0';
         cycle_pow_req <= '0';
         cut_pow_req   <= '0';
         update_status <= '0';
         req_reg       <= (others => '0');
         status_block_updated <= '0';

      elsif(clk_i'event and clk_i = '1') then

         if(clr_flag = '1') then
            status_block_updated <= '0';
         elsif(set_flag = '1') then
            status_block_updated <= '1';
         end if;

         -- For brst_mce, cycle_pow and cut_pow, if a set arrives at the same time as a clr, the req line will remain asserted.
         if(brst_mce_set = '1') then
            brst_mce_req <= '1';
         elsif(brst_mce_clr = '1') then
            brst_mce_req <= '0';
         else
            brst_mce_req <= brst_mce_req;
         end if;

         if(cycle_pow_set = '1') then
            cycle_pow_req <= '1';
         elsif(cycle_pow_clr = '1') then
            cycle_pow_req <= '0';
         else
            cycle_pow_req <= cycle_pow_req;
         end if;

         if(cut_pow_set = '1') then
            cut_pow_req <= '1';
         elsif(cut_pow_clr = '1') then
            cut_pow_req <= '0';
         else
            cut_pow_req <= cut_pow_req;
         end if;

         -- Status Block is updated at 200 Hz
         -- For update_status, if the timer is expired at the same time that status_done is asserted, update_status is deasserted.
         -- This is because it takes one cycle to reset the timer after timeout_clr is asserted (at the same time as status_done).
         -- What this means is that timeout_count is >= 2000000 when status_done is asserted.
         if(status_done = '1') then
            update_status <= '0';
--         elsif(timeout_count >= 350) then
         elsif(timeout_count >= 2000000) then
            update_status <= '1';
         else
            update_status <= update_status;
         end if;

         if(req_reg_load = '1') then
            req_reg <= brst_mce_req & cycle_pow_req & cut_pow_req & update_status;
         else
            req_reg <= req_reg;
         end if;

      end if;
   end process;

   ------------------------------------------------------------
   -- Double Synchronizer
   ------------------------------------------------------------
   process(rst_i, clk_n_i)
   begin
      if(rst_i = '1') then
         mosi_temp <= '0';
         sclk_temp <= '0';
         ccss_temp <= '0';
      elsif(clk_n_i'event and clk_n_i = '1') then

         ------------------------------------------------------------
         -- Notes on active-high/low signals
         ------------------------------------------------------------
         -- ccss is active-low from the PSUC before it is inverted by a buffer on the Clock Card
         -- Here, ccss is re-inverted because this code was written to take ccss as active-low (same as PSUC).
         --
         -- mosi is an active-high data line before being inverted by a buffer on the Clock Card.
         -- Here, mosi is re-inverted to rectify the signal.
         --
         -- sclk latches data in on rising edges before it is inverted by a buffer on the Clock Card.
         -- Here, sclk is re-inverted because this code was written to detect rising edges.
         ------------------------------------------------------------

         mosi_temp <= not mosi_i;
         sclk_temp <= not sclk_i;
         ccss_temp <= not ccss_i;
      end if;
   end process;

   process(rst_i, clk_i)
   begin
      if(rst_i = '1') then
         mosi <= '0';
         sclk <= '0';
         ccss <= '0';
      elsif(clk_i'event and clk_i = '1') then
         mosi <= mosi_temp;
         sclk <= sclk_temp;
         ccss <= ccss_temp;
      end if;
   end process;

   ------------------------------------------------------------
   -- SPI FSM
   ------------------------------------------------------------
   -- clocked FSMs, advance the state for both FSMs
   state_FF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         current_state     <= IDLE;
         current_out_state <= IDLE;
      elsif(clk_i'event and clk_i = '1') then
         current_state     <= next_state;
         current_out_state <= next_out_state;
      end if;
   end process state_FF;

   out_state_NS: process(current_out_state, brst_mce_req, cycle_pow_req, cut_pow_req, update_status, bit_ctr_count, sclk, ccss)
   begin
      -- Default assignments
      next_out_state <= current_out_state;

      case current_out_state is
         when IDLE =>
            if(brst_mce_req = '1' or cycle_pow_req = '1' or cut_pow_req = '1' or update_status = '1') then
               next_out_state <= TX_RX;
            end if;

         -- For sending brst, power-cycle or power-shutdown commands and retrieving status block simultaneously
         when TX_RX =>
            -- This statement prevents us from entering a tx/rx state if a transmission is in progress
            -- and the sclk='0' requirement retimes this FSM to the PSUC clock.
            if(ccss = '1') then
               next_out_state <= CLK_LOW;
            end if;

         when CLK_LOW =>
            -- 3=brst_mce, 2=cycle_pow, 1=cut_pow, 0=update_status
            -- We are done tx/rx after the falling edge of the last bit received
            -- Note that for every command sent, the status block must be received in its entirety.
            -- This is why we don't just wait until bit_ctr_count = COMMAND_LENGTH
            if(bit_ctr_count = STATUS_LENGTH) then
               next_out_state <= DONE;
            elsif(ccss = '0' and sclk = '1') then
               next_out_state <= CLK_HIGH;
            end if;

         when CLK_HIGH =>
            if(ccss = '0' and sclk = '0') then
               next_out_state <= CLK_LOW;
            end if;

         when DONE =>
            next_out_state <= IDLE;

         when others =>
            next_out_state <= IDLE;

      end case;
   end process out_state_NS;

   out_state_out: process(current_out_state, brst_mce_req, cycle_pow_req, cut_pow_req, update_status, bit_ctr_count, sclk, req_reg, ccss)
   begin
      -- Default assignments
      -- sreq is active low on the PSUC, but is inverted by a buffer on the Clock Card.
      -- Here, it is treated as active low but is again inverted before being output, to counteract the buffer.
      sreq          <= '1';
      spi_tx_word   <= (others => '0');
      bit_ctr_ena   <= '1';
      bit_ctr_load  <= '1';
      bit_capture   <= '0';
      brst_mce_clr  <= '0';
      cycle_pow_clr <= '0';
      cut_pow_clr   <= '0';
      timeout_clr   <= '0';
      status_done   <= '0';
      req_reg_load  <= '0';
      status_wren   <= '0';
      set_flag      <= '0';

      case current_out_state is
         when IDLE  =>
            if(brst_mce_req = '1' or cycle_pow_req = '1' or cut_pow_req = '1' or update_status = '1') then
               req_reg_load <= '1';
            end if;

         -- For sending brst, power-cycle or power-shutdown commands only
         when TX_RX =>
            -- 3=brst_mce, 2=cycle_pow, 1=cut_pow, 0=update_status
            if(req_reg(3) = '1') then
               spi_tx_word  <= ASCII_R & ASCII_M & ASCII_R & ASCII_M & ASCII_R & ASCII_M & ASCII_R & ASCII_M;
            elsif(req_reg(2) = '1') then
               spi_tx_word  <= ASCII_C & ASCII_P & ASCII_C & ASCII_P & ASCII_C & ASCII_P & ASCII_C & ASCII_P;
            elsif(req_reg(1) = '1') then
               spi_tx_word  <= ASCII_T & ASCII_O & ASCII_T & ASCII_O & ASCII_T & ASCII_O & ASCII_T & ASCII_O;
            elsif(req_reg(0) = '1') then
               spi_tx_word  <= (others => '0');
            end if;

         when CLK_LOW =>
            bit_ctr_ena  <= '0';
            bit_ctr_load <= '0';
            sreq         <= '0';

            -- If all the status bits have been received, don't capture crap
            if(bit_ctr_count >= STATUS_LENGTH) then null;
            -- Otherwise capture the next bit of the status block on the rising edge of sclk
            elsif(ccss = '0' and sclk = '1') then
               bit_capture   <= '1';
            end if;

         when CLK_HIGH =>
            bit_ctr_ena  <= '0';
            bit_ctr_load <= '0';
            sreq         <= '0';

            -- If all the command bits have been transmitted, we transmit zeros
            if(bit_ctr_count >= STATUS_LENGTH) then null;
            -- Otherwise latch out the next bit of the command on the falling edge of sclk
            elsif(ccss = '0' and sclk = '0') then
               bit_ctr_ena <= '1';

               -- if we've captured 32 bits, then store the word in the status block RAM
               -- we do this in the clk low state because counter is incremented as we enter this state
               if(bit_ctr_count mod WB_DATA_WIDTH = 31) then
                  status_wren <= '1';
               end if;
            end if;


         when DONE =>
            -- 3=brst_mce, 2=cycle_pow, 1=cut_pow, 0=update_status
            if(req_reg(3) = '1') then
               brst_mce_clr  <= '1';
            elsif(req_reg(2) = '1') then
               cycle_pow_clr <= '1';
            elsif(req_reg(1) = '1') then
               cut_pow_clr   <= '1';
            elsif(req_reg(0) = '1') then
               timeout_clr <= '1';
               status_done <= '1';
               set_flag <= '1';
            end if;

         when others =>

      end case;
   end process out_state_out;

   ------------------------------------------------------------
   --  WBS FSM
   ------------------------------------------------------------
   -- Transition table for DAC controller
   state_NS: process(current_state, rd_cmd, wr_cmd, cyc_i)
   begin
      -- Default assignments
      next_state <= current_state;

      case current_state is
         when IDLE =>
            if(wr_cmd = '1') then
               next_state <= WR;
            elsif(rd_cmd = '1') then
               next_state <= RD1;
            end if;

         when WR =>
            if(cyc_i = '0') then
               next_state <= IDLE;
            end if;

         when RD1 =>
            next_state <= RD2;

         when RD2 =>
            if(cyc_i = '0') then
               next_state <= IDLE;
            else
               next_state <= RD1;
            end if;

         when others =>
            next_state <= IDLE;

      end case;
   end process state_NS;

   -- Output states for DAC controller
   state_out: process(current_state, stb_i, cyc_i, addr_i)
   begin
      -- Default assignments
      ack_o         <= '0';
      brst_mce_set  <= '0';
      cycle_pow_set <= '0';
      cut_pow_set   <= '0';
      clr_flag      <= '0';
      err_o         <= '0';

      case current_state is
         when IDLE  =>
            ack_o <= '0';

         when WR =>
            ack_o <= '1';
            if(stb_i = '1') then
               if(addr_i = BRST_MCE_ADDR) then
                  brst_mce_set  <= '1';
               elsif(addr_i = CYCLE_POW_ADDR) then
                  cycle_pow_set <= '1';
               elsif(addr_i = CUT_POW_ADDR) then
                  cut_pow_set   <= '1';
               elsif(addr_i = PSC_STATUS_ADDR) then
                  err_o <= '1';
               end if;
            end if;

         -- implied that in RD1 ack_o is 0
         when RD2 =>
            ack_o <= '1';
            if(cyc_i = '0') then
               clr_flag <= '1';
            end if;

         when others =>

      end case;
   end process state_out;

   ------------------------------------------------------------
   --  Wishbone Interface Signals
   ------------------------------------------------------------
   with tga_i select status_data2 <=
      status_data(31 downto 10) & status_block_updated & status_data(8 downto 0) when x"00000008",
      status_data when others;

   with addr_i select dat_o <=
      (others => '0') when BRST_MCE_ADDR,
      (others => '0') when CYCLE_POW_ADDR,
      (others => '0') when CUT_POW_ADDR,
      status_data2    when PSC_STATUS_ADDR,
      (others => '0') when others;

   rd_cmd  <= '1' when
      (stb_i = '1' and cyc_i = '1' and we_i = '0') and
      (addr_i = BRST_MCE_ADDR or addr_i = CYCLE_POW_ADDR or addr_i = CUT_POW_ADDR or addr_i = PSC_STATUS_ADDR) else '0';

   wr_cmd  <= '1' when
      (stb_i = '1' and cyc_i = '1' and we_i = '1') and
      (addr_i = BRST_MCE_ADDR or addr_i = CYCLE_POW_ADDR or addr_i = CUT_POW_ADDR or addr_i = PSC_STATUS_ADDR) else '0';

end top;