-- 2003 SCUBA-2 Project
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
-- $Id: sync_gen_wbs.vhd,v 1.1 2004/11/18 05:21:56 bburger Exp $
--
-- Project:       SCUBA2
-- Author:        Bryce Burger
-- Organisation:  UBC
--
-- Description:
-- Wishbone interface for sync_gen
--
-- Revision history:
-- $Log: sync_gen_wbs.vhd,v $
-- Revision 1.1  2004/11/18 05:21:56  bburger
-- Bryce :  modified addr_card top level.  Added ac_dac_ctrl and frame_timing
--
--
--
-----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library components;
use components.component_pack.all;

library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;

--library work;
--use work.frame_timing_wbs_pack.all;

entity sync_gen_wbs is        
   port(
      -- sync_gen interface:
      dv_en_o            : out std_logic;

      -- wishbone interface:
      dat_i              : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      addr_i             : in std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
      tga_i              : in std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
      we_i               : in std_logic;
      stb_i              : in std_logic;
      cyc_i              : in std_logic;
      dat_o              : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      ack_o              : out std_logic;

      -- global interface
      clk_i              : in std_logic;
      mem_clk_i          : in std_logic;
      rst_i              : in std_logic 
   );     
end sync_gen_wbs;

architecture rtl of sync_gen_wbs is

   -- FSM inputs
   signal wr_cmd         : std_logic;
   signal rd_cmd         : std_logic;
   signal master_wait    : std_logic;

   -- Register signals
   signal dv_en_wren     : std_logic;
   signal dv_en_data     : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
 
   -- WBS states:
   type states is (IDLE, WR, RD); 
   signal current_state  : states;
   signal next_state     : states;
   
begin

   dv_en_reg : reg
      generic map(
         WIDTH             => PACKET_WORD_WIDTH
      )
      port map(
         clk_i             => mem_clk_i,
         rst_i             => rst_i,
         ena_i             => dv_en_wren,
         reg_i             => dat_i,
         reg_o             => dv_en_data
      );


   dv_en_o <= '0' when (dv_en_data = x"00000000") else '1';

------------------------------------------------------------
--  WB FSM
------------------------------------------------------------   

   -- clocked FSMs, advance the state for both FSMs
   state_FF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         current_state     <= IDLE;
      elsif(clk_i'event and clk_i = '1') then
         current_state     <= next_state;
      end if;
   end process state_FF;
   
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
      ack_o      <= '0';
      dv_en_wren <= '0';
     
      case current_state is         
         when IDLE  =>                   
            ack_o <= '0';
            
         when WR =>
            ack_o <= '1';
            if(stb_i = '1') then
               if(addr_i = USE_DV_ADDR) then
                  dv_en_wren <= '1';
               end if;
            end if;
         
         when RD =>
            ack_o <= '1';
         
         when others =>
         
      end case;
   end process state_out;

------------------------------------------------------------
--  Wishbone interface: 
--  constant USE_DV_ADDR       
------------------------------------------------------------
  
   with addr_i select dat_o <=
      dv_en_data when USE_DV_ADDR,
      (others => '0') when others;
   
   master_wait <= '1' when ( stb_i = '0' and cyc_i = '1') else '0';   
           
   rd_cmd  <= '1' when 
      (stb_i = '1' and cyc_i = '1' and we_i = '0') and 
      (addr_i = USE_DV_ADDR) else '0'; 
      
   wr_cmd  <= '1' when 
      (stb_i = '1' and cyc_i = '1' and we_i = '1') and 
      (addr_i = USE_DV_ADDR) else '0'; 
      
end rtl;