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
-- $Id: config_fpga.vhd,v 1.3 2006/05/29 23:11:00 bburger Exp $
--
-- Project:       SCUBA-2
-- Author:        Bryce Burger
-- Organization:  UBC
--
-- Description:
-- Allows user to reconfigure the Clock Card FPGA from either the Factory or Application EPC16
--
-- Revision history:
-- $Log: config_fpga.vhd,v $
-- Revision 1.3  2006/05/29 23:11:00  bburger
-- Bryce: Removed unused signals to simplify code and remove warnings from Quartus II
--
-- Revision 1.2  2006/04/29 00:52:36  bburger
-- Bryce:
-- - fw_rev:  added a 'when others' statement to a state machine
-- - clock_card:  upped the cc rev #
-- - config_fpga:  fixed a couple of bugs
--
-- Revision 1.1  2006/04/26 22:55:08  bburger
-- Bryce:  Added a slave to Clock Card called config_fpga, which allows the user to toggle between factory and application configurations.
-- In the process:
-- - fixed a bug in cmd_translator_simple_cmd_fsm that output the wrong read/write code.
-- - updated the cc_pin_assign_rev_b.tcl file to include the fpga output pins for epc16 control
-- - updated the clock card top level with a new version number.
--
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

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
      
      -- Configuration Interface
      config_n_o    : out std_logic;
      epc16_sel_n_o : out std_logic
   );     
end config_fpga;

architecture top of config_fpga is
   
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
   
   signal timeout_clr   : std_logic;
   signal timeout_count : integer;

begin

   timeout_timer : us_timer
   port map
   (
      clk => clk_i,
      timer_reset_i => timeout_clr,
      timer_count_o => timeout_count
   );

   ------------------------------------------------------------
   --  WB FSM
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
   
   out_state_NS: process(current_out_state, config_n, epc16_sel_n, timeout_count)
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
            if(timeout_count > 1024) then
               next_out_state <= CONFIG_FAC;            
            end if;
            
         when CONFIG_FAC =>     
            if(timeout_count > 1024) then
               next_out_state <= IDLE;            
            end if;
         
         when SEL_APP =>     
            if(timeout_count > 1024) then
               next_out_state <= CONFIG_APP;            
            end if;

         when CONFIG_APP =>     
            if(timeout_count > 1024) then
               next_out_state <= IDLE;            
            end if;

         when others =>
            next_out_state <= IDLE;

      end case;
   end process out_state_NS;

   out_state_out: process(current_out_state, timeout_count)
   begin
      -- Default assignments
      config_n_o    <= '1';  -- '0' triggers reconfiguration
      epc16_sel_n_o <= '1';  -- '1'=Factory, '0'=Application
      timeout_clr   <= '1';
     
      case current_out_state is         
         when IDLE  =>                   
            
         when SEL_FAC =>     
            epc16_sel_n_o <= '1';

            if(timeout_count <= 1024) then
               -- Allow for a long settling time for the epc16_sel_n_o signal
               timeout_clr   <= '0';
            end if;
         
         when CONFIG_FAC =>     
            config_n_o    <= '0';  
            epc16_sel_n_o <= '1';  

            if(timeout_count <= 1024) then
               -- Allow for a long settling time for the epc16_sel_n_o signal
               timeout_clr   <= '0';
            end if;

         when SEL_APP =>     
            epc16_sel_n_o <= '0';  

            if(timeout_count <= 1024) then
               -- Allow for a long settling time for the epc16_sel_n_o signal
               timeout_clr   <= '0';
            end if;
         
         when CONFIG_APP =>     
            config_n_o    <= '0';  
            epc16_sel_n_o <= '0';  

            if(timeout_count <= 1024) then
               -- Allow for a long settling time for the epc16_sel_n_o signal
               timeout_clr   <= '0';
            end if;

         when others =>
         
      end case;
   end process out_state_out;

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
   dat_o <= (others => '0');
   
   rd_cmd  <= '1' when 
      (stb_i = '1' and cyc_i = '1' and we_i = '0') and 
      (addr_i = CONFIG_FAC_ADDR or addr_i = CONFIG_APP_ADDR) else '0'; 
      
   wr_cmd  <= '1' when 
      (stb_i = '1' and cyc_i = '1' and we_i = '1') and 
      (addr_i = CONFIG_FAC_ADDR or addr_i = CONFIG_APP_ADDR) else '0'; 
      
end top;