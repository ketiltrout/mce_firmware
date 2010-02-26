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
-- $Id: config_fpga.vhd,v 1.5 2006/11/22 01:00:16 bburger Exp $
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

   component jtag_data_bank IS
      PORT
      (
         clock    : IN STD_LOGIC  := '1';
         data     : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
         rdaddress      : IN STD_LOGIC_VECTOR (6 DOWNTO 0);
         wraddress      : IN STD_LOGIC_VECTOR (6 DOWNTO 0);
         wren     : IN STD_LOGIC  := '0';
         q     : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
      );
   END component;
   
   type out_states is (IDLE, SEL_FAC, SEL_APP, CONFIG_FAC, CONFIG_APP); 
   signal current_out_state : out_states;
   signal next_out_state    : out_states;

   -- FSM inputs
   signal wr_cmd        : std_logic;
   signal rd_cmd        : std_logic;

   -- WBS states:
   type states is (IDLE, WR, RD); 
   signal current_state : states;
   signal next_state    : states;

   signal config_n      : std_logic;
   signal epc16_sel_n   : std_logic;
   
   -- *** Is this a standard size?  No.
   constant JTAG_WORD_WIDTH : integer := WB_DATA_WIDTH;
   constant JTAG_ADDR_WIDTH : integer := 7;
   
   signal jtag0_dat         : std_logic_vector(JTAG_WORD_WIDTH-1 downto 0);
   signal jtag1_dat         : std_logic_vector(JTAG_WORD_WIDTH-1 downto 0);
   signal jtag2_dat         : std_logic_vector(JTAG_WORD_WIDTH-1 downto 0);
   
   signal jtag0_wren        : std_logic;
   signal jtag1_wren        : std_logic;
   signal jtag2_wren        : std_logic;

   signal tck_dly1          : std_logic;
   signal tck_dly2          : std_logic;

   type jtag_states is (IDLE, PREP_TDO_WORD, WAIT1, TCK_HIGH, TCK_LOW, WORD_DONE); 
   signal current_jtag_state : jtag_states;
   signal next_jtag_state    : jtag_states;
   
   type timer_states is (IDLE, TIMING); 
   signal current_timer_state : timer_states;
   signal next_timer_state    : timer_states;

   constant TDO_SAMPLE_DELAY_US : integer := 100;
   signal timer_rst : std_logic;
   signal timer     : integer;  
   
begin

   ----------------------------------------------------------------
   -- JTAG Output Data Path
   ----------------------------------------------------------------
   -- Sample triads:
   -- 0000 0010 out: 0x2
   -- 0000 0011 out: 0x3
   -- 0000 0010 out: 0x2
   --
   -- 0100 0000 out: 0x40
   -- 0011 0000 in: 0x30
   -- 0100 0001 out: 0x41
   -- 0100 0000 out: 0x40

   -- write_byteblaster(0, data);
   -- write_byteblaster(0, data | (alternative_cable_l ? 0x02 : (alternative_cable_x ? 0x02: 0x01)));
   -- write_byteblaster(0, data);
   -- Bit 7: --
   -- Bit 6: TDI.
   -- Bit 5: --
   -- Bit 4: --
   -- Bit 3: --
   -- Bit 2: --
   -- Bit 1: TMS.
   -- Bit 0: TCK. Toggles on the middle bit of every triad.      
   fpga_tdo_o <= jtag0_dat(6); -- TDI (into JTAG chain)
   fpga_tms_o <= jtag0_dat(1); -- TMS
   fpga_tck_o <= jtag0_dat(0); -- TCK
   
   jtag_reg0 : process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         jtag0_dat <= (others => '0');
      elsif(clk_i'event and clk_i = '1') then
         if(jtag0_wren = '1') then
            jtag0_dat <= dat_i(JTAG_WORD_WIDTH-1 downto 0);
         end if;
      end if;
   end process jtag_reg0;
  
   -- initialize_jtag_hardware() and close_jtag_hardware():
   -- Bit 7: --
   -- Bit 6: --
   -- Bit 5: --
   -- Bit 4: --
   -- Bit 3: --
   -- Bit 2: --
   -- Bit 1: JTAG_CTRL.
   -- Bit 0: --   
   -- Enables the FPGA's access to the JTAG chain
   -- write_byteblaster(2, (initial_lpt_ctrl | 0x02) & 0xDF);
   jtag_sel_o <= jtag2_dat(1); -- JTAG source: '0'=Header, '1'=FGPA
   
   jtag_reg2 : process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         jtag2_dat <= (others => '0');
      elsif(clk_i'event and clk_i = '1') then
         if(jtag2_wren = '1') then
            jtag2_dat <= dat_i(JTAG_WORD_WIDTH-1 downto 0);
         end if;
      end if;
   end process jtag_reg2;

   ----------------------------------------------------------------
   -- JTAG Input Data Path
   ----------------------------------------------------------------
   -- read_byteblaster():
   -- Bit 7: TDO (out of JTAG chain, and inverted by Byte Blaster)
   -- Bit 6: --
   -- Bit 5: --
   -- Bit 4: --
   -- Bit 3: --
   -- Bit 2: --
   -- Bit 1: --
   -- Bit 0: --

   tdo_timer : us_timer
   port map (
      clk => clk_i,
      timer_reset_i => timer_rst,
      timer_count_o => timer
   );
    
   jtag_reg1 : process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         
         jtag1_dat <= (others => '0');         
         tck_dly1  <= '0';
         tck_dly2  <= '0';
         
      elsif(clk_i'event and clk_i = '1') then
         -- *** What's the correct delay here? 
         -- Here, tck_dly1 is triggered by writing to TDI/TCK/TMS.  Perhaps this isn't right.
         -- The delay for capturing TDI is based on how triads are constructed, and the scope waveform captures.         
         tck_dly1 <= jtag0_dat(0); --TCK
         tck_dly2 <= tck_dly1;

         if(jtag1_wren = '1') then
            jtag1_dat <= "000000000000000000000000" & not epc_tdo_i & "0110000"; -- TDO
         end if;
      end if;
   end process jtag_reg1;

--      -- *** I'm assuming here that these signals can be inferred, and don't have to be specified explicitly via fibre
--      -- *** I'm assuming that the JTAG words are 16 bits.
--      -- *** I'm also assuming that bits are shifted out LSB to MSB.  If not, just assert ena, and not shr.
--      -- *** I'm also assuming that the bits are shifted out LSB to MSB, and that the propagation delay is minimal.
--      -- *** Probe these signals to confirm their behavior during JTAG configuration.
--      -- *** These signals may need to be removed from the JAM Player code.
--      -- *** TDO has to be cleared by the TDO FSM slave when it is asserted
--      -- *** JTAG sel may have to be asserted for the duration of the JAM file.  If so, write to JTAG slowley so that MAS can keep up.

   timer_state_NS: process(current_timer_state, tck_dly1, tck_dly2, timer)
   begin
      -- Default assignments
      next_timer_state <= current_timer_state;
      
      case current_timer_state is
         when IDLE =>
            if(tck_dly1 = '0' and tck_dly2 = '1') then
               next_timer_state <= TIMING;
            end if;
            
         when TIMING =>
            if(timer = TDO_SAMPLE_DELAY_US) then
               next_timer_state <= IDLE;
            end if;

         when others =>
            next_timer_state <= IDLE;
      end case;
   end process timer_state_NS;

   timer_state_out: process(current_timer_state, timer)
   begin
      -- Default assignments
      timer_rst  <= '1';      
      jtag1_wren <= '0';
     
      case current_timer_state is         
         when IDLE  => 

         when TIMING =>
            timer_rst <= '0';                  
            if(timer = TDO_SAMPLE_DELAY_US) then
               jtag1_wren <= '1';
            end if;

         when others =>
      end case;
   end process timer_state_out;


   ------------------------------------------------------
   -- Factory/ Application Configuration Trigger
   ------------------------------------------------------
   -- clocked FSMs, advance the state for both FSMs
   state_FF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         current_state      <= IDLE;
         current_out_state  <= IDLE;
         current_timer_state <= IDLE;
      
      elsif(clk_i'event and clk_i = '1') then
         current_state      <= next_state;
         current_out_state  <= next_out_state;
         current_timer_state <= next_timer_state;
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
               next_state <= RD;
            end if;                  
            
         when WR =>     
            if(cyc_i = '0') then
               next_state <= IDLE;
            end if;
         
         when RD =>
            if(cyc_i = '0') then
               next_state <= IDLE;
            end if;
         
         when others =>
            next_state <= IDLE;

      end case;
   end process state_NS;
   
   -- Output states for DAC controller   
   state_out: process(current_state, stb_i, addr_i)
   begin
      -- Default assignments
      ack_o       <= '0';
      config_n    <= '1';  -- '0' triggers reconfiguration
      epc16_sel_n <= '1';  -- '1'=Factory, '0'=Application
      jtag0_wren  <= '0';
      jtag2_wren  <= '0';
     
      case current_state is         
         when IDLE  =>                   
            ack_o <= '0';
            
         when WR =>
            ack_o <= '1';
            if(stb_i = '1') then
               if(addr_i = CONFIG_FAC_ADDR) then
                  config_n    <= '0'; 
                  epc16_sel_n <= '1';
               elsif(addr_i = CONFIG_APP_ADDR) then
                  config_n    <= '0'; 
                  epc16_sel_n <= '0';  
               elsif(addr_i = JTAG0_ADDR) then
                  jtag0_wren  <= '1';
               elsif(addr_i = JTAG1_ADDR) then
                  -- Read only
                  null;
               elsif(addr_i = JTAG2_ADDR) then
                  jtag2_wren  <= '1';
               end if;
            end if;
         
         when RD =>
            ack_o <= '1';
         
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
      (others => '0');
   
   rd_cmd  <= '1' when 
      (stb_i = '1' and cyc_i = '1' and we_i = '0') and 
      (addr_i = CONFIG_FAC_ADDR or addr_i = CONFIG_APP_ADDR or addr_i = JTAG0_ADDR or addr_i = JTAG1_ADDR or addr_i = JTAG2_ADDR) else '0'; 
      
   wr_cmd  <= '1' when 
      (stb_i = '1' and cyc_i = '1' and we_i = '1') and 
      (addr_i = CONFIG_FAC_ADDR or addr_i = CONFIG_APP_ADDR or addr_i = JTAG0_ADDR or addr_i = JTAG1_ADDR or addr_i = JTAG2_ADDR) else '0'; 
      
end top;