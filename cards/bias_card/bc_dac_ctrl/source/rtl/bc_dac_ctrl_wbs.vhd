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
-- $Id: bc_dac_ctrl_wbs.vhd,v 1.1 2004/11/25 03:05:08 bburger Exp $
--
-- Project:       SCUBA2
-- Author:        Bryce Burger
-- Organisation:  UBC
--
-- Description:
-- Wishbone interface for a 16-bit serial DAC controller
-- This block was written to be coupled with bc_dac_ctrl
--
-- Revision history:
-- $Log: bc_dac_ctrl_wbs.vhd,v $
-- Revision 1.1  2004/11/25 03:05:08  bburger
-- Bryce:  Modified the Bias Card DAC control slaves.
--
-- Revision 1.1  2004/11/11 01:46:56  bburger
-- Bryce:  new
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

library work;
use work.ac_dac_ctrl_wbs_pack.all;
use work.bc_dac_ctrl_pack.all;

entity bc_dac_ctrl_wbs is        
   port
   (
      -- ac_dac_ctrl interface:
      flux_fb_addr_i    : in std_logic_vector(COL_ADDR_WIDTH-1 downto 0);
      flux_fb_data_o    : out std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
      bias_data_o       : out std_logic_vector(PACKET_WORD_WIDTH-1 downto 0); 
      flux_fb_changed_o : out std_logic;
      bias_changed_o    : out std_logic;

      -- wishbone interface:
      dat_i             : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      addr_i            : in std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
      tga_i             : in std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
      we_i              : in std_logic;
      stb_i             : in std_logic;
      cyc_i             : in std_logic;
      dat_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      ack_o             : out std_logic;

      -- global interface
      clk_i             : in std_logic;
      mem_clk_i         : in std_logic;
      rst_i             : in std_logic;
      debug             : inout std_logic_vector(31 downto 0)
   );     
end bc_dac_ctrl_wbs;

architecture rtl of bc_dac_ctrl_wbs is

   -- FSM inputs
   signal wr_cmd           : std_logic;
   signal rd_cmd           : std_logic;
   signal master_wait      : std_logic;

   -- RAM/Register signals
   signal flux_fb_wren     : std_logic;   
   signal flux_fb_data     : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal bias_wren        : std_logic;
   signal bias_data        : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   
   -- WBS states:
   type states is (IDLE, WR, RD); 
   signal current_state    : states;
   signal next_state       : states;
   
begin

   flux_fb_ram : tpram_32bit_x_64
      port map
      (
         data              => dat_i,
         wren              => flux_fb_wren,
         wraddress         => tga_i(COL_ADDR_WIDTH-1 downto 0),
         rdaddress_a       => flux_fb_addr_i,
         rdaddress_b       => tga_i(COL_ADDR_WIDTH-1 downto 0),
         clock             => mem_clk_i,
         qa                => flux_fb_data_o,
         qb                => flux_fb_data
      );   
   
   -- To the bc_dac_ctrl block
   bias_data_o <= bias_data;
   debug(19 downto 16) <= dat_i(3 downto 0);
   debug(23 downto 20) <= addr_i(3 downto 0);
   debug(24)    <= we_i;
   debug(25)    <= stb_i;
   debug(26)    <= cyc_i;
--   debug(27)    <= ack_o;
   
   bias_data_reg : reg
      generic map(
         WIDTH             => PACKET_WORD_WIDTH
      )
      port map(
         clk_i             => mem_clk_i,
         rst_i             => rst_i,
         ena_i             => bias_wren,
         reg_i             => dat_i,
         reg_o             => bias_data
      );


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
   state_out: process(current_state, stb_i, addr_i, cyc_i)
   begin
      -- Default assignments
      flux_fb_wren      <= '0';
      bias_wren         <= '0';
      ack_o             <= '0';
      flux_fb_changed_o <= '0';
      bias_changed_o    <= '0';
      
      case current_state is         
         when IDLE  =>                   
            ack_o <= '0';
            
         when WR =>
            ack_o <= '1';
            
            if(stb_i = '1') then
               if(addr_i = FLUX_FB_ADDR) then
                  flux_fb_wren <= '1';
               elsif(addr_i = BIAS_ADDR) then
                  bias_wren <= '1';
               end if;
            end if;
            
            -- This is so that the bias block does not update bias during every frame - only when the values are changed
            if(cyc_i = '0') then
               flux_fb_changed_o <= '1';
               bias_changed_o    <= '1';
            end if;
         
         when RD =>
            ack_o <= '1';
            
            if(cyc_i = '0') then
               flux_fb_changed_o <= '1';
               bias_changed_o    <= '1';
            end if;
         
         when others =>
            null;
         
      end case;
   end process state_out;

------------------------------------------------------------
--  Wishbone interface 
------------------------------------------------------------
   
   with addr_i select dat_o <=
      flux_fb_data    when FLUX_FB_ADDR,
      bias_data       when BIAS_ADDR,
      (others => '0') when others;
   
   master_wait <= '1' when ( stb_i = '0' and cyc_i = '1') else '0';   
           
   rd_cmd  <= '1' when 
      (stb_i = '1' and cyc_i = '1' and we_i = '0') and 
      (addr_i = FLUX_FB_ADDR or addr_i = BIAS_ADDR) else '0'; 
      
   wr_cmd  <= '1' when 
      (stb_i = '1' and cyc_i = '1' and we_i = '1') and 
      (addr_i = FLUX_FB_ADDR or addr_i = BIAS_ADDR) else '0'; 
      
end rtl;