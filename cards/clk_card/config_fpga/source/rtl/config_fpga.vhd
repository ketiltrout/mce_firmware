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
-- $Id: config_fpga.vhd,v 1.7 2010/03/05 19:05:47 bburger Exp $
--
-- Project:       SCUBA-2
-- Author:        Bryce Burger
-- Organization:  UBC
--
-- Description:
-- Allows user to reconfigure the Clock Card FPGA from either the Factory or Application EPC16
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;

library components;
use components.component_pack.all;

entity config_fpga is
   port(
      -- Clock and Reset:
      clk_i         : in std_logic;
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
      jtag_busy_o   : out std_logic; -- Implement this

      -- JTAG interface
      fpga_tdo_o    : out std_logic; -- TDO
      fpga_tck_o    : out std_logic; -- TCK
      fpga_tms_o    : out std_logic; -- TMS
      epc_tdo_i     : in std_logic;  -- TDI (into the FPGA)
      
      jtag_sel_o    : out std_logic; -- JTAG source: '0'=Header, '1'=FGPA
      nbb_jtag_i    : in std_logic;  -- JTAG source:  readback (jtag_sel)
      
      -- Configuration Interface
      config_n_o    : out std_logic;
      epc16_sel_n_o : out std_logic
   );     
end config_fpga;

architecture top of config_fpga is

   -- TCK_HALF_PERIOD = number of clock cycles per TCK half-period.
   -- This divisor should set the JTAG TCK frequency slow enough so that programming Flash devices is successful.
   constant TCK_HALF_PERIOD  : std_logic_vector := x"00000008"; -- Clock cycles       
   constant TDO_SAMPLE_DELAY : std_logic_vector := x"00000002"; -- Clock cycles
   constant JTAG_ADDR_WIDTH  : integer := 7;
   signal tck_hlf_period : integer;
   
   component jtag_data_bank IS
      PORT
      (
         clock    : IN STD_LOGIC  := '1';
         data     : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
         rdaddress      : IN STD_LOGIC_VECTOR (6 DOWNTO 0);
         wraddress      : IN STD_LOGIC_VECTOR (6 DOWNTO 0);
         wren     : IN STD_LOGIC  := '0';
         q     : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
      );
   END component;
   
   type out_states is (IDLE, SEL_FAC, SEL_APP, CONFIG_FAC, CONFIG_APP); 
   signal current_out_state : out_states;
   signal next_out_state    : out_states;

   type jtag_states is (IDLE, SYNC_TMS_BIT, LATCH_WORD, LATCH_SIZE, TDI_SETTLE, TCK_HIGH, TCK_LOW,
      JTAG_ENGINE1, JTAG_ENGINE2, SHIFT_WORD, SEQUENCE_DONE, ADDR_DLY1, ADDR_DLY2); 
   signal current_jtag_state  : jtag_states;
   signal next_jtag_state     : jtag_states;
   
   type timer_states is (IDLE, TIMING); 
   signal current_timer_state : timer_states;
   signal next_timer_state    : timer_states;

   -- WBS states:
   type states is (IDLE, WR, RD1, RD2); 
   signal current_state       : states;
   signal next_state          : states;

   -- FSM inputs
   signal wr_cmd              : std_logic;
   signal rd_cmd              : std_logic;

   signal config_n            : std_logic;
   signal epc16_sel_n         : std_logic;
   
   signal jtag0_dat           : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal jtag1_dat           : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal jtag2_dat           : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal jtag0_wren          : std_logic;
   signal jtag1_wren          : std_logic;
   signal jtag2_wren          : std_logic;

   signal tck_half_period_dat : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal tck_half_period_wren : std_logic;
   
   signal tck_dly1            : std_logic;
   signal tck_dly2            : std_logic;
   signal tck_count         : integer; -- range 0 to TCK_HALF_PERIOD + 1;
   signal tck_count_new     : integer; -- range 0 to TCK_HALF_PERIOD + 1;
   signal tck_level         : std_logic;
   signal tck_count_en      : std_logic;

   signal timer_rst           : std_logic;
   signal timer               : integer;  
   signal timer_new           : integer;  

   signal tdi_word_rdy      : std_logic; -- asserted when there is data to latch out over JTAG
   signal branch2_tms       : std_logic;
   signal branch2_tdi       : std_logic;

   signal bit_num           : integer;
   signal bit_num_wren      : std_logic;
   signal bit_count_ena     : std_logic;
   signal bit_count_clr     : std_logic;
   signal bit_count         : integer;
   signal bit_count_new     : integer;
   signal wbit_count         : integer;
   signal wbit_count_new     : integer;

   signal tdi_sh_dat        : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal tdi_sh_ena        : std_logic;
   signal tdi_sh_shr        : std_logic;
   signal tdi_sh_load       : std_logic;
   signal tdi_sh_clear      : std_logic; 
   
   signal tms_sh_ena        : std_logic;
   signal tms_sh_shr        : std_logic;
   signal tms_sh_load       : std_logic;
   signal tms_sh_clear      : std_logic;
   
   signal tdo_sh_dat        : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal tdo_sh_ena        : std_logic;
   signal tdo_sh_shr        : std_logic;
   signal tdo_sh_clear      : std_logic;
   signal tdo_sample_dly_dat  : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal tdo_sample_dly : integer;
   signal tdo_sample_dly_wren : std_logic;

   ----------------------------------------------------------------
   -- RAM Management Signals
   ----------------------------------------------------------------
   signal tdi_rd_addr       : std_logic_vector(JTAG_ADDR_WIDTH-1 downto 0);
   signal tdi_rd_addr_new   : std_logic_vector(JTAG_ADDR_WIDTH-1 downto 0);
   signal tdi_rden          : std_logic;

   signal tdi_wr_addr       : std_logic_vector(JTAG_ADDR_WIDTH-1 downto 0);
   signal tdi_wr_addr_new   : std_logic_vector(JTAG_ADDR_WIDTH-1 downto 0);
   signal tdi_wren          : std_logic;

   signal tdo_wr_addr       : std_logic_vector(JTAG_ADDR_WIDTH-1 downto 0);
   signal tdo_wr_addr_new   : std_logic_vector(JTAG_ADDR_WIDTH-1 downto 0);
   signal tdo_wren          : std_logic;
   signal tdo_wr_addr_clr   : std_logic;
   signal tdo_dat           : std_logic_vector(WB_DATA_WIDTH-1 downto 0);

   signal tdo_rd_addr       : std_logic_vector(JTAG_ADDR_WIDTH-1 downto 0);
   signal tdo_rd_addr_new   : std_logic_vector(JTAG_ADDR_WIDTH-1 downto 0);
   signal tdo_rden          : std_logic;
   signal tdo_rd_addr_clr   : std_logic;
  
begin

   ----------------------------------------------------------------
   -- JTAG Output Data Path #1:  write_byteblaster()
   -- Sample triads:
   -- 0000 0010 out: 0x2
   -- 0000 0011 out: 0x3
   -- 0000 0010 out: 0x2

   -- 0100 0000 out: 0x40
   -- 0011 0000 in: 0x30
   -- 0100 0001 out: 0x41
   -- 0100 0000 out: 0x40

   -- write_byteblaster(0, data);
   -- write_byteblaster(0, data | (alternative_cable_l ? 0x02 : (alternative_cable_x ? 0x02: 0x01)));
   -- write_byteblaster(0, data);
   ----------------------------------------------------------------  
   -- Port Mapping:
   -- Bit 7: --
   -- Bit 6: TDI.
   -- Bit 5: --
   -- Bit 4: --
   -- Bit 3: --
   -- Bit 2: --
   -- Bit 1: TMS.
   -- Bit 0: TCK. Toggles on the middle bit of every triad.      
   fpga_tdo_o <= jtag0_dat(6) or branch2_tdi; -- TDI (into JTAG chain)
   fpga_tms_o <= jtag0_dat(1) or branch2_tms; -- TMS
   fpga_tck_o <= jtag0_dat(0) or tck_level; -- TCK
   
   jtag_reg0 : process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         jtag0_dat <= (others => '0');
      elsif(clk_i'event and clk_i = '1') then
         if(jtag0_wren = '1') then
            jtag0_dat <= dat_i(WB_DATA_WIDTH-1 downto 0);
         end if;
      end if;
   end process jtag_reg0;
  
   ----------------------------------------------------------------
   -- JTAG Data Paths #1 and #2:  initialize_jtag_hardware() and close_jtag_hardware():
   -- Enables the FPGA's access to the JTAG chain
   -- write_byteblaster(2, (initial_lpt_ctrl | 0x02) & 0xDF);
   ----------------------------------------------------------------
   -- Port Mapping:
   -- Bit 7: --
   -- Bit 6: --
   -- Bit 5: --
   -- Bit 4: --
   -- Bit 3: --
   -- Bit 2: --
   -- Bit 1: JTAG_CTRL.
   -- Bit 0: --   
   jtag_sel_o <= jtag2_dat(1); -- JTAG source: '0'=Header, '1'=FGPA
   
   jtag_reg2 : process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         jtag2_dat <= (others => '0');
      elsif(clk_i'event and clk_i = '1') then
         if(jtag2_wren = '1') then
            jtag2_dat <= dat_i(WB_DATA_WIDTH-1 downto 0);
         end if;
      end if;
   end process jtag_reg2;

   ----------------------------------------------------------------
   -- JTAG Data Path #1: Parallel Port Interface
   ----------------------------------------------------------------
   -- read_byteblaster() Port Mapping:
   -- Bit 7: TDO (out of JTAG chain, and inverted by Byte Blaster)
   -- Bit 6: --
   -- Bit 5: --
   -- Bit 4: --
   -- Bit 3: --
   -- Bit 2: --
   -- Bit 1: --
   -- Bit 0: --

--   tdo_timer : us_timer
--   port map (
--      clk => clk_i,
--      timer_reset_i => timer_rst,
--      timer_count_o => timer
--   );
   
   timer_new <= timer + 1;   
   tdo_timer : process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         timer   <=  0;
      elsif(clk_i'event and clk_i = '1') then
         if(timer_rst = '1') then
            timer <= 0;
         else
            timer <= timer_new;
         end if;
      end if;
   end process tdo_timer;   
    
   jtag_reg1 : process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         
         jtag1_dat <= (others => '0');         
         tck_dly1  <= '0';
         tck_dly2  <= '0';
         
      elsif(clk_i'event and clk_i = '1') then
         -- According to datasheets, TDO is valid 25ns after the falling edge of TCK.
         tck_dly1 <= jtag0_dat(0); --TCK
         tck_dly2 <= tck_dly1;

         if(jtag1_wren = '1') then
            jtag1_dat <= "000000000000000000000000" & not epc_tdo_i & "0110000"; -- TDO
         end if;
      end if;
   end process jtag_reg1;

   -- I'm assuming here that TCK can be inferred, and doesn't have to be specified explicitly via fibre.  Yes.
   -- I'm assuming that the JTAG words are 16 bits.  No!  But don't worry about that here.  Let the Software worry about that.
   -- I'm also assuming that bits are shifted out LSB to MSB.  If not, just assert ena, and not shr.  Confirm this with Matt.
   timer_state_NS: process(current_timer_state, jtag0_dat, tck_dly1, timer, tdo_sample_dly)
   begin
      -- Default assignments
      next_timer_state <= current_timer_state;
      
      case current_timer_state is
         when IDLE =>
            -- If there is a falling edge on TCK..
--            if(tck_dly1 = '0' and tck_dly2 = '1') then
            if(jtag0_dat(0) = '0' and tck_dly1 = '1') then
               if(tdo_sample_dly = 0) then
                  next_timer_state <= IDLE;
               else
                  next_timer_state <= TIMING;
               end if;
            end if;
            
         when TIMING =>
            if(timer = tdo_sample_dly) then
               next_timer_state <= IDLE;
            end if;

         when others =>
            next_timer_state <= IDLE;
      end case;
   end process timer_state_NS;

   timer_state_out: process(current_timer_state, timer, tdo_sample_dly, jtag0_dat, tck_dly1)
   begin
      -- Default assignments
      timer_rst  <= '1';      
      jtag1_wren <= '0';
     
      case current_timer_state is         
         when IDLE  => 
            if(jtag0_dat(0) = '0' and tck_dly1 = '1') then
               if(tdo_sample_dly = 0) then
                  jtag1_wren <= '1';
               else
                  timer_rst <= '0';                  
               end if;
            end if;          

         when TIMING =>
            timer_rst <= '0';                  
            if(timer = tdo_sample_dly) then
               jtag1_wren <= '1';
            end if;

         when others =>
      end case;
   end process timer_state_out;

   ----------------------------------------------------------------
   -- JTAG Data Path #2:  Packing Problem, aka Encapsulation Enigma
   ----------------------------------------------------------------
   -- What follows below is code for Data Path #2, which implements a solution to the Encapsulation Enigma.
   -- Note that the registers that emulate the parallel port interface to the Byte Blaster are still present and working above.

   ----------------------------------------------------------------
   -- JTAG Engine (Data Path #2)
   ----------------------------------------------------------------
   -- Counting out JTAG TMS, TDO bits.
   bit_num_reg : process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         bit_num <= 0;
      elsif(clk_i'event and clk_i = '1') then
         if(bit_num_wren = '1') then
            bit_num <= conv_integer(tdi_sh_dat);
         end if;
      end if;
   end process bit_num_reg; 
   
   -- Counting out TCK periods.
   tck_count_new <= tck_count + 1;   
   tck_generator : process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         tck_count   <=  0;
      elsif(clk_i'event and clk_i = '1') then
         -- Count out 50MHz clock cycles to generate TCK.
         if(tck_count_en = '1') then
            if(tck_count = tck_hlf_period-1) then
               tck_count <= 0;
            else
               tck_count <= tck_count_new;
            end if;
         else
            tck_count <= 0;
         end if;
      end if;
   end process tck_generator;

   tck_hlf_period <= conv_integer(tck_half_period_dat);
   tck_half_period_reg : process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         tck_half_period_dat <= TCK_HALF_PERIOD;
      elsif(clk_i'event and clk_i = '1') then
         if(tck_half_period_wren = '1') then
            tck_half_period_dat <= dat_i(WB_DATA_WIDTH-1 downto 0);
         end if;
      end if;
   end process tck_half_period_reg;

   ----------------------------------------------------------------
   -- TDI (Data Path #2)
   ----------------------------------------------------------------
   -- For writing TDI words from Wishbone to RAM
   tdi_wr_addr_new <= tdi_wr_addr + 1;
   tdi_wr_addr_reg : process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         tdi_wr_addr <= (others => '0');
      elsif(clk_i'event and clk_i = '1') then
         if(tdi_wren = '1') then
            tdi_wr_addr <= tdi_wr_addr_new;
         end if;
      end if;
   end process tdi_wr_addr_reg;
   
   -- For reading TDI words from RAM to Shift Register (JTAG) or Size Register
   tdi_rd_addr_new <= tdi_rd_addr + 1;
   tdi_rd_addr_reg : process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         tdi_rd_addr <= (others => '0');
      elsif(clk_i'event and clk_i = '1') then
         if(tdi_rden = '1') then
            tdi_rd_addr <= tdi_rd_addr_new;
         end if;
      end if;
   end process tdi_rd_addr_reg;

   -- Stores JTAG TDI words
   tdi_bank : jtag_data_bank
   port map
   (
      clock     => clk_i,
      data      => dat_i(WB_DATA_WIDTH-1 downto 0),
      rdaddress => tdi_rd_addr,
      wraddress => tdi_wr_addr,
      wren      => tdi_wren,
      q         => tdi_sh_dat
   );
   
   -- Is there another TDI word to be latched out?
   tdi_word_rdy <= '0' when tdi_rd_addr = tdi_wr_addr else '1'; -- Starting condition

   -- Determine the next counter value.
   wbit_count_new <= 0 when wbit_count = WB_DATA_WIDTH-1 else wbit_count + 1;   
   bit_count_new <= bit_count + 1;   
   bit_counter : process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         bit_count <= 0;
         wbit_count <= 0;
      elsif(clk_i'event and clk_i = '1') then
         if(bit_count_clr = '1') then
            bit_count <= 0;
            wbit_count <= 0;
          elsif(bit_count_ena = '1') then
            bit_count <= bit_count_new;
            wbit_count <= wbit_count_new;
         end if;
      end if;
   end process bit_counter;
   
   -- TDI Shift Register
   tdi_tx : shift_reg
   generic map(WIDTH => WB_DATA_WIDTH)
   port map
   (
      clk_i      => clk_i,
      rst_i      => rst_i,
      ena_i      => tdi_sh_ena,
      load_i     => tdi_sh_load,
      clr_i      => tdi_sh_clear,
      shr_i      => tdi_sh_shr,
      serial_i   => '0',
      serial_o   => branch2_tdi,
      parallel_i => tdi_sh_dat,
      parallel_o => open
   );
   
   -- TMS Shift Register
   tms_tx : shift_reg
   generic map(WIDTH => WB_DATA_WIDTH)
   port map
   (
      clk_i      => clk_i,
      rst_i      => rst_i,
      ena_i      => tms_sh_ena,
      load_i     => tms_sh_load,
      clr_i      => tms_sh_clear,
      shr_i      => tms_sh_shr,
      serial_i   => '0',
      serial_o   => branch2_tms,
      parallel_i => tdi_sh_dat,
      parallel_o => open
   );

   ----------------------------------------------------------------
   -- TDO (Data Path #2)
   ----------------------------------------------------------------
   -- For storing the TDO read delay.  
   -- Units are: # of clock cycles after a TCK falling edge.
   tdo_sample_dly <= conv_integer(tdo_sample_dly_dat);
   tdo_sample_dly_reg : process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         tdo_sample_dly_dat <= TDO_SAMPLE_DELAY;
      elsif(clk_i'event and clk_i = '1') then
         if(tdo_sample_dly_wren = '1') then
            tdo_sample_dly_dat <= dat_i(WB_DATA_WIDTH-1 downto 0);
         end if;
      end if;
   end process tdo_sample_dly_reg;
           
   -- TDO Shift Register
   tdo_rx : shift_reg
   generic map(WIDTH => WB_DATA_WIDTH)
   port map
   (
      clk_i      => clk_i,
      rst_i      => rst_i,
      ena_i      => tdo_sh_ena,
      load_i     => '0',
      clr_i      => tdo_sh_clear,
      shr_i      => tdo_sh_shr,
      serial_i   => epc_tdo_i,
      serial_o   => open,
      parallel_i => (others => '0'),
      parallel_o => tdo_sh_dat
   );

   -- For writing TDO words from Shift Register (JTAG) to RAM
   tdo_wr_addr_new <= tdo_wr_addr + 1;
   tdo_rd_addr_new <= tdo_rd_addr + 1;
   tdo_wr_addr_reg : process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         tdo_wr_addr <= (others => '0');
         tdo_rd_addr <= (others => '0');
      elsif(clk_i'event and clk_i = '1') then
         if(tdo_wr_addr_clr = '1') then
            tdo_wr_addr <= (others => '0');
         elsif(tdo_wren = '1') then
            tdo_wr_addr <= tdo_wr_addr_new;
         end if;
         
         if(tdo_rd_addr_clr = '1') then
            tdo_rd_addr <= (others => '0');
         elsif(tdo_rden = '1') then
            tdo_rd_addr <= tdo_rd_addr_new;
         end if;
         
      end if;
   end process tdo_wr_addr_reg;

   -- TDO Storage RAM
   tdo_bank : jtag_data_bank
   port map
   (
      clock     => clk_i,
      data      => tdo_sh_dat,
      rdaddress => tdo_rd_addr,
      wraddress => tdo_wr_addr,
      wren      => tdo_wren,
      q         => tdo_dat
   );   

   ------------------------------------------------------
   -- JTAG FSM: Data Path #2
   ------------------------------------------------------
   jtag_state_NS: process(current_jtag_state, tdi_word_rdy, bit_count, bit_num, tck_count, wbit_count, tck_hlf_period)
   begin
      -- Default assignments
      next_jtag_state <= current_jtag_state;
      
      case current_jtag_state is
         when IDLE =>
            -- In IDLE we assume that we are sitting on the first TDI RAM index of the next batch of words.
            -- The first index always get the number of bits that are to be written to JTAG
            -- *** is this OK with Matt?
            if(tdi_word_rdy = '1') then
               next_jtag_state <= LATCH_SIZE;
            end if;
            
         when LATCH_SIZE =>
            next_jtag_state <= ADDR_DLY1;
            
         when ADDR_DLY1 =>
            next_jtag_state <= ADDR_DLY2;

         when ADDR_DLY2 =>
            next_jtag_state <= LATCH_WORD;
         
         when LATCH_WORD =>
            next_jtag_state <= SYNC_TMS_BIT;
         
         when SYNC_TMS_BIT =>            
            next_jtag_state <= TDI_SETTLE;

         when TDI_SETTLE =>
            if(tck_count = tck_hlf_period-1) then
               next_jtag_state <= TCK_HIGH;
            end if;
        
         when TCK_HIGH => 
            if(tck_count = tck_hlf_period-1) then
               next_jtag_state <= TCK_LOW;
            end if;
         
         when TCK_LOW => 
            -- On the last clock cycle of the TCK = 0, where are we in the JTAG words?
            -- The bit count is updating at this point, so we have have to synchronize with what that value is on the last cycle.
            if(tck_count = tck_hlf_period-1) then
               -- No more bits to shift out, cuz we just shifted out the last TMS/TCK
               if(bit_count = bit_num-1) then 
                  next_jtag_state <= SEQUENCE_DONE;
               -- At the end of a word
               elsif(wbit_count = WB_DATA_WIDTH-1) then 
                  -- Could this be pointing to LATCH_WORD?
                  next_jtag_state <= ADDR_DLY1;
               -- Keep trucking trough the word
               else
                  next_jtag_state <= TCK_HIGH;
               end if;               
            end if;
         
         when SEQUENCE_DONE =>
            next_jtag_state <= IDLE;

         when others =>
            next_jtag_state <= IDLE;

      end case;
   end process jtag_state_NS;
   
   -- Output states for DAC controller   
   jtag_state_out: process(current_jtag_state, bit_count, bit_num, tck_count, tdo_sample_dly, wbit_count, tck_hlf_period)
   begin
      -- Default assignments      
      tdi_rden  <= '0';
      
      bit_count_ena     <= '0';
      bit_count_clr     <= '0';
      bit_num_wren      <= '0';
     
      tdi_sh_ena        <= '0';
      tdi_sh_shr        <= '1';
      tdi_sh_load       <= '0';
      tdi_sh_clear      <= '0'; -- unused

      tms_sh_ena        <= '0';
      tms_sh_shr        <= '1';
      tms_sh_load       <= '0';
      tms_sh_clear      <= '0'; -- unused

      tdo_sh_ena        <= '0';
      tdo_sh_shr        <= '0'; -- Note that this inverts the bit order but maintains the data content to the same portion of the word.
      tdo_sh_clear      <= '0';
      tdo_wren          <= '0';
      tdo_wr_addr_clr   <= '0';
--      tdo_rd_addr_clr   <= '0';

      tck_level         <= '0';
      tck_count_en      <= '0';
      jtag_busy_o       <= '1';

      case current_jtag_state is         
         when IDLE  =>
            jtag_busy_o       <= '0';

         when LATCH_SIZE =>
            -- Latch number of bit to write to JTAG
            bit_num_wren      <= '1';
            -- Increment RAM address
            tdi_rden  <= '1';
            -- Reset the bit counter value
            bit_count_clr     <= '1';
            
         when ADDR_DLY1 =>
         when ADDR_DLY2 =>
         when LATCH_WORD =>            
            -- Load the TDI and TMS shift registers
            tdi_sh_ena        <= '1';
            tdi_sh_load       <= '1';
            tms_sh_ena        <= '1';
            tms_sh_load       <= '1';
            
            -- Once the TDI and TMS registers are latched, we can prime the next word
            tdi_rden  <= '1';          
            
         when SYNC_TMS_BIT =>
            -- Shift over to TMS bit
            tms_sh_ena        <= '1';
         
         when TDI_SETTLE =>
            -- Count out the duration of the TCK half-period
            tck_count_en      <= '1';
            tck_level         <= '0';

         when TCK_HIGH => 
            -- Count out the duration of the TCK half-period
            tck_count_en      <= '1';
            tck_level         <= '1';

            -- While TCK is high, shift to the next TDI and TMS positions in the shift registers (See AN39, p.24)
            if(tck_count = tdo_sample_dly) then
               -- Shift to next TMS/TDI bits
               tdi_sh_ena        <= '1';
               tms_sh_ena        <= '1';
--               bit_count_ena     <= '1';
            elsif(tck_count = tdo_sample_dly+1) then
               -- Shift to next TMS/TDI bits
               tdi_sh_ena        <= '1';
               tms_sh_ena        <= '1';
--               bit_count_ena     <= '1';
            end if;
         
         when TCK_LOW => 
            -- Count out the duration of the TCK half-period
            tck_count_en      <= '1';
            tck_level         <= '0';

            -- Capture TDO at after a delay = tdo_sample_dly
            if(tck_count = tdo_sample_dly) then
               tdo_sh_ena        <= '1';
            end if;
            
--            -- If it's that time, store the TDO word in RAM and clear the shift register
--            if(tck_count = tck_hlf_period-1) then
--               -- No more bits to shift out, cuz we just shifted out the last TMS/TCK
--               if(bit_count = bit_num-2) then 
--                  -- It takes one cycle to clear the shift register, so storing it output at the same time is legit.
--                  tdo_wren          <= '1';
--                  tdo_sh_clear      <= '1';
--               -- At the end of a word
--               elsif(wbit_count = WB_DATA_WIDTH-2) then 
--                  tdo_wren          <= '1';
--                  tdo_sh_clear      <= '1';
--               -- Keep trucking trough the word
--               end if;               
--            end if;
            
            if(tck_count = tck_hlf_period-1) then
               -- No more bits to shift out, cuz we just shifted out the last TMS/TCK
               if(bit_count = bit_num-1) then 
                  -- It takes one cycle to clear the shift register, so storing it output at the same time is legit.
                  tdo_wren          <= '1';
                  tdo_sh_clear      <= '1';
               -- At the end of a word
               elsif(wbit_count = WB_DATA_WIDTH-1) then 
                  tdo_wren          <= '1';
                  tdo_sh_clear      <= '1';
               end if;               
            end if;

            -- On the last clock cycle of the TCK = 0, update the bit counter.
            if(tck_count = tck_hlf_period-2) then
               bit_count_ena     <= '1';
            elsif(tck_count = tck_hlf_period-1) then
               bit_count_ena     <= '1';
            end if;

         when SEQUENCE_DONE =>
            -- Reset the TDO RAM pointer for the next sequence.
            tdo_wr_addr_clr   <= '1';            
--            tdo_rd_addr_clr   <= '1';
            
         when others =>
         
      end case;
   end process jtag_state_out;

   ------------------------------------------------------
   -- Factory/ Application Configuration Trigger
   ------------------------------------------------------
   -- clocked FSMs, advance the state for both FSMs
   state_FF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         current_state       <= IDLE;
         current_out_state   <= IDLE;
         current_timer_state <= IDLE;
         current_jtag_state  <= IDLE;
      elsif(clk_i'event and clk_i = '1') then
         current_state       <= next_state;
         current_out_state   <= next_out_state;
         current_timer_state <= next_timer_state;
         current_jtag_state  <= next_jtag_state;
      end if;
   end process state_FF;
   
   out_state_NS: process(current_out_state, config_n, epc16_sel_n)
   begin
      -- Default assignments
      next_out_state <= current_out_state;
      
      case current_out_state is
         when IDLE =>
            if(config_n = '0' and epc16_sel_n = '1') then
               next_out_state <= SEL_FAC;            
            elsif(config_n = '0' and epc16_sel_n = '0') then
               next_out_state <= SEL_APP;            
            end if;                  
            
         when SEL_FAC =>     
            next_out_state <= CONFIG_FAC;            
            
         when CONFIG_FAC =>     
            -- wait here until configuration starts         

         when SEL_APP =>     
            next_out_state <= CONFIG_APP;            

         when CONFIG_APP =>     
            -- wait here until configuration starts         

         when others =>
            next_out_state <= IDLE;

      end case;
   end process out_state_NS;

   out_state_out: process(current_out_state)
   begin
      -- Default assignments
      config_n_o    <= '1';  -- '0' triggers reconfiguration
      epc16_sel_n_o <= '1';  -- '1'=Factory, '0'=Application
     
      case current_out_state is         
         when IDLE  =>                   
            
         when SEL_FAC =>     
            epc16_sel_n_o <= '1';

         when CONFIG_FAC =>     
            config_n_o    <= '0';  
            epc16_sel_n_o <= '1';  

         when SEL_APP =>     
            epc16_sel_n_o <= '0';  

         when CONFIG_APP =>     
            config_n_o    <= '0';  
            epc16_sel_n_o <= '0';  

         when others =>
         
      end case;
   end process out_state_out;

   ------------------------------------------------------
   -- Wishbone
   ------------------------------------------------------
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
            if(cyc_i = '0') then
               next_state <= IDLE;
            end if;
         
         when others =>
            next_state <= IDLE;

      end case;
   end process state_NS;
   
   -- Output states for DAC controller   
   state_out: process(current_state, stb_i, addr_i, next_state, rd_cmd)
   begin
      -- Default assignments
      ack_o                <= '0';
      config_n             <= '1';  -- '0' triggers reconfiguration
      epc16_sel_n          <= '1';  -- '1'=Factory, '0'=Application
      jtag0_wren           <= '0';
      jtag2_wren           <= '0';
      tdi_wren             <= '0';
      tdo_sample_dly_wren  <= '0';
      tck_half_period_wren <= '0';
      tdo_rden             <= '0';
      tdo_rd_addr_clr      <= '0';
     
      case current_state is         
         when IDLE  =>                   
            ack_o <= '0';

            if(rd_cmd = '1') then
               if(addr_i = TDO_ADDR) then
                  tdo_rden <= '1';
               end if;
            end if;
            
         when WR =>
            ack_o <= '1';
            if(stb_i = '1') then
               if(addr_i = CONFIG_FAC_ADDR) then
                  config_n    <= '0'; 
                  epc16_sel_n <= '1';
               elsif(addr_i = CONFIG_APP_ADDR) then
                  config_n    <= '0'; 
                  epc16_sel_n <= '0';  
               
               ---------------------------------
               -- Parallel Port JTAG Interface:
               ---------------------------------
               elsif(addr_i = JTAG0_ADDR) then
                  jtag0_wren  <= '1';
               elsif(addr_i = JTAG1_ADDR) then
                  null; -- Read only
               elsif(addr_i = JTAG2_ADDR) then
                  jtag2_wren  <= '1';
               
               ---------------------------------
               -- Compact JTAG Interface: 
               ---------------------------------
               elsif(addr_i = TMS_TDI_ADDR) then
                  tdi_wren  <= '1';
               elsif(addr_i = TDO_ADDR) then
                  null; -- Read only
               elsif(addr_i = TDO_SAMPLE_DLY_ADDR) then
                  tdo_sample_dly_wren  <= '1';
               elsif(addr_i = TCK_HALF_PERIOD_ADDR) then
                  tck_half_period_wren <= '1';
               end if;
            end if;
         
         when RD1 =>
            if(next_state /= IDLE) then
               ack_o <= '1';               
               
               if(addr_i = TDO_ADDR) then
                  -- Don't assert ack_o if we are reading from the RAM becuase of it's 3-cycle latency
                  tdo_rden <= '1';
               end if;
            else
               tdo_rd_addr_clr      <= '1';           
            end if;
         
         when others =>
         
      end case;
   end process state_out;

   ------------------------------------------------------------
   --  Wishbone interface: 
   ------------------------------------------------------------  
   dat_o <= 
      ext(jtag0_dat, WB_DATA_WIDTH) when addr_i = JTAG0_ADDR else 
      ext(jtag1_dat, WB_DATA_WIDTH) when addr_i = JTAG1_ADDR else 
      ext(jtag2_dat, WB_DATA_WIDTH) when addr_i = JTAG2_ADDR else 
      (others => '0') when addr_i = TMS_TDI_ADDR else
      tdo_dat when addr_i = TDO_ADDR else
      tdo_sample_dly_dat when addr_i = TDO_SAMPLE_DLY_ADDR else
      tck_half_period_dat when addr_i = TCK_HALF_PERIOD_ADDR else
      (others => '0');
   
   rd_cmd  <= '1' when 
      (stb_i = '1' and cyc_i = '1' and we_i = '0') and 
      (addr_i = CONFIG_FAC_ADDR or addr_i = CONFIG_APP_ADDR or addr_i = JTAG0_ADDR or addr_i = JTAG1_ADDR or addr_i = JTAG2_ADDR or addr_i = TMS_TDI_ADDR or addr_i = TDO_ADDR or addr_i = TDO_SAMPLE_DLY_ADDR or addr_i = TCK_HALF_PERIOD_ADDR) else '0'; 
      
   wr_cmd  <= '1' when 
      (stb_i = '1' and cyc_i = '1' and we_i = '1') and 
      (addr_i = CONFIG_FAC_ADDR or addr_i = CONFIG_APP_ADDR or addr_i = JTAG0_ADDR or addr_i = JTAG1_ADDR or addr_i = JTAG2_ADDR or addr_i = TMS_TDI_ADDR or addr_i = TDO_ADDR or addr_i = TDO_SAMPLE_DLY_ADDR or addr_i = TCK_HALF_PERIOD_ADDR) else '0'; 
      
end top;