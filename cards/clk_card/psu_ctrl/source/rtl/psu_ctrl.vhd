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
-- $Id: psu_ctrl.vhd,v 1.2 2006/07/27 00:04:30 bburger Exp $
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
-- Revision 1.2  2006/07/27 00:04:30  bburger
-- Bryce:  New
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

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
   
   ------------------------------
   -- SPI Interface
   ------------------------------
   mosi_i        : in std_logic;   -- Master Output/ Slave Input
   sclk_i        : in std_logic;   -- Serial Clock
   ccss_i        : in std_logic;   -- Clock Card Slave Select
   miso_o        : out std_logic;  -- Master Input/ Slave Output
   sreq_o        : out std_logic  -- Service Request      
);     
end psu_ctrl;

architecture top of psu_ctrl is

   -- The size in bits of the status header.
   constant COMMAND_LENGTH    : integer   := 48;
   constant STATUS_LENGTH     : integer   := 288;

   constant HIGH              : std_logic := '1';
   constant LOW               : std_logic := '0';
   constant INT_ZERO          : integer   := 0;
   constant STATUS_ADDR_WIDTH : integer   := 6; 

   constant ASCII_C    : std_logic_vector(7 downto 0) := "01000011"; 
   constant ASCII_P    : std_logic_vector(7 downto 0) := "01010000"; 
   constant ASCII_R    : std_logic_vector(7 downto 0) := "01010010"; 
   constant ASCII_M    : std_logic_vector(7 downto 0) := "01001101"; 
   constant ASCII_T    : std_logic_vector(7 downto 0) := "01010100"; 
   constant ASCII_O    : std_logic_vector(7 downto 0) := "01001111"; 
   constant ASCII_NULL : std_logic_vector(7 downto 0) := "00000000"; 

   component tpram_32bit_x_64
   PORT
   (
      data        : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
      wraddress   : IN STD_LOGIC_VECTOR (STATUS_ADDR_WIDTH-1 DOWNTO 0);
      rdaddress_a : IN STD_LOGIC_VECTOR (STATUS_ADDR_WIDTH-1 DOWNTO 0);
      rdaddress_b : IN STD_LOGIC_VECTOR (STATUS_ADDR_WIDTH-1 DOWNTO 0);
      wren        : IN STD_LOGIC  := '1';
      clock       : IN STD_LOGIC ;
      qa          : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
      qb          : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
   );
   end component;

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
   
   -- SPI interface signals
   signal mosi      : std_logic;   -- Master Output/ Slave Input
   signal sclk      : std_logic;   -- Serial Clock
   signal ccss      : std_logic;   -- Clock Card Slave Select
   signal mosi_temp : std_logic;   -- Master Output/ Slave Input
   signal sclk_temp : std_logic;   -- Serial Clock
   signal ccss_temp : std_logic;   -- Clock Card Slave Select

   -- RAM interface signals
   signal status_wren : std_logic;
   signal status_addr : std_logic_vector(STATUS_ADDR_WIDTH-1 downto 0);
   signal status_data : std_logic_vector(WB_DATA_WIDTH-1 downto 0);

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
   
   -- Shift Register Signals
   signal spi_tx_word         : std_logic_vector(COMMAND_LENGTH-1 downto 0);

begin

   ------------------------------------------------------------
   -- PSC Status RAM
   ------------------------------------------------------------
   status_ram : tpram_32bit_x_64
   port map
   (
      data              => dat_i,
      wren              => status_wren,
      wraddress         => tga_i      (STATUS_ADDR_WIDTH-1 downto 0), --raw_addr_counter,         
      rdaddress_a       => status_addr(STATUS_ADDR_WIDTH-1 downto 0),
      rdaddress_b       => tga_i      (STATUS_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
      clock             => clk_i,
      qa                => status_data,
      qb                => open
   );

   sh_reg: shift_reg
   generic map(
      WIDTH      => COMMAND_LENGTH
   )   
   port map(
      clk_i      => clk_i,
      rst_i      => rst_i,
      ena_i      => bit_ctr_ena,       
      load_i     => bit_ctr_load,      
      clr_i      => LOW,    
      shr_i      => HIGH,        
      serial_i   => LOW, 
      serial_o   => miso_o,  
      parallel_i => spi_tx_word, 
      parallel_o => open
   );

   bit_ctr: counter
   generic map(
      MAX => STATUS_LENGTH,
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
         
      elsif(clk_i'event and clk_i = '1') then
         if(brst_mce_set = '1') then
            brst_mce_req  <= '1';
         elsif(brst_mce_clr = '1') then
            brst_mce_req  <= '0';
         end if;
         
         if(cycle_pow_set = '1') then
            cycle_pow_req <= '1';
         elsif(cycle_pow_clr = '1') then
            cycle_pow_req <= '0';
         end if;
         
         if(cut_pow_set = '1') then
            cut_pow_req   <= '1';
         elsif(cut_pow_clr = '1') then
            cut_pow_req   <= '0';
         end if;
         
         -- Status Block is updated at 200 Hz
         if(timeout_count = 5000) then
            update_status <= '1';
         elsif(status_done = '1') then
            update_status <= '0';
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
         mosi_temp <= mosi_i;
         sclk_temp <= sclk_i;
         ccss_temp <= ccss_i;
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
   
   out_state_NS: process(current_out_state, brst_mce_req, cycle_pow_req, cut_pow_req, update_status, bit_ctr_count, sclk)
   begin
      -- Default assignments
      next_out_state <= current_out_state;
      
      case current_out_state is
         when IDLE =>
            if(brst_mce_req = '1') then
               next_out_state <= CLK_LOW;
            elsif(cycle_pow_req = '1') then
               next_out_state <= CLK_LOW;
            elsif(cut_pow_req = '1') then
               next_out_state <= CLK_LOW;
            elsif(update_status = '1') then
               next_out_state <= CLK_LOW;
            end if;
          
         -- For sending brst, power-cycle or power-shutdown commands and retrieving status block simultaneously
         when TX_RX =>
            next_out_state <= CLK_HIGH;
         
         when CLK_LOW =>
            if(bit_ctr_count = STATUS_LENGTH) then
               next_out_state <= DONE;
            elsif(sclk = '1') then
               next_out_state <= CLK_HIGH;
            end if;            
            
         when CLK_HIGH =>
            if(bit_ctr_count = STATUS_LENGTH) then
               next_out_state <= DONE;
            elsif(sclk = '0') then
               next_out_state <= CLK_LOW;
            end if;            
         
         when DONE =>

         when others =>
            next_out_state <= IDLE;

      end case;
   end process out_state_NS;

   out_state_out: process(current_out_state, brst_mce_req, cycle_pow_req, cut_pow_req, update_status, bit_ctr_count, sclk)
   begin
      -- Default assignments
      sreq_o       <= '0'; -- Active High?
      spi_tx_word  <= (others => '0');
      bit_ctr_ena  <= '0';
      bit_ctr_load <= '0';
     
      case current_out_state is         
         when IDLE  =>                   
            
         -- For sending brst, power-cycle or power-shutdown commands only
         when TX_RX =>
            bit_ctr_load <= '1';
            if(brst_mce_req = '1') then
               spi_tx_word  <= ASCII_R & ASCII_M & ASCII_R & ASCII_M & ASCII_R & ASCII_M;
            elsif(cycle_pow_req = '1') then
               spi_tx_word  <= ASCII_C & ASCII_P & ASCII_C & ASCII_P & ASCII_C & ASCII_P;
            elsif(cut_pow_req = '1') then
               spi_tx_word  <= ASCII_T & ASCII_O & ASCII_T & ASCII_O & ASCII_T & ASCII_O;
            elsif(update_status = '1') then
               spi_tx_word  <= (others => '0');
            end if;

         when CLK_LOW =>
            sreq_o <= '1';
            if(bit_ctr_count = STATUS_LENGTH) then
               null;
            elsif(sclk = '1') then
               bit_ctr_ena <= '1';
            end if;            

         when CLK_HIGH =>
            sreq_o <= '1';
         
         when DONE =>

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
   state_out: process(current_state, stb_i, addr_i)
   begin
      -- Default assignments
      ack_o         <= '0';
      brst_mce_set  <= '0';
      cycle_pow_set <= '0';
      cut_pow_set   <= '0';      
      
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
                  null;
               end if;
            end if;
         
         -- implied that in RD1 ack_o is 0
         when RD2 =>
            ack_o <= '1';
         
         when others =>
         
      end case;
   end process state_out;   

   ------------------------------------------------------------
   --  Wishbone Interface Signals
   ------------------------------------------------------------   
   with addr_i select dat_o <=
      (others => '0') when BRST_MCE_ADDR,
      (others => '0') when CYCLE_POW_ADDR,
      (others => '0') when CUT_POW_ADDR,
      status_data     when PSC_STATUS_ADDR,
      (others => '0') when others;
   
   rd_cmd  <= '1' when 
      (stb_i = '1' and cyc_i = '1' and we_i = '0') and 
      (addr_i = BRST_MCE_ADDR or addr_i = CYCLE_POW_ADDR or addr_i = CUT_POW_ADDR or addr_i = PSC_STATUS_ADDR) else '0'; 
      
   wr_cmd  <= '1' when 
      (stb_i = '1' and cyc_i = '1' and we_i = '1') and 
      (addr_i = BRST_MCE_ADDR or addr_i = CYCLE_POW_ADDR or addr_i = CUT_POW_ADDR or addr_i = PSC_STATUS_ADDR) else '0'; 
    
end top;