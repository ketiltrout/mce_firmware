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
-- $Id: ac_dac_ctrl.vhd,v 1.10 2004/11/20 01:20:44 bburger Exp $
--
-- Project:       SCUBA2
-- Author:        Bryce Burger
-- Organisation:  UBC
--
-- Description:
-- 14-bit 165MS/s DAC (AD9744) controller
-- This block must be coupled with frame_timing and wbs_ac_dac_ctrl blocks to work properly
--
-- Revision history:
-- $Log: ac_dac_ctrl.vhd,v $
-- Revision 1.10  2004/11/20 01:20:44  bburger
-- Bryce :  fixed a bug in the ac_dac_ctrl_core block that did not load the off value of the row at the end of a frame.
--
-- Revision 1.9  2004/11/18 05:21:56  bburger
-- Bryce :  modified addr_card top level.  Added ac_dac_ctrl and frame_timing
--
-- Revision 1.8  2004/11/15 20:03:41  bburger
-- Bryce :  Moved frame_timing to the 'work' library, and physically moved the files to "all_cards" directory
--
-- Revision 1.7  2004/11/06 03:12:01  bburger
-- Bryce:  debugging
--
-- Revision 1.6  2004/11/04 00:08:18  bburger
-- Bryce:  small updates
--
-- Revision 1.5  2004/11/02 07:38:09  bburger
-- Bryce:  ac_dac_ctrl in progress
--
--   
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library sys_param;
use sys_param.wishbone_pack.all;
use sys_param.command_pack.all;
use sys_param.data_types_pack.all;

library work;
use work.ac_dac_ctrl_pack.all;
use work.ac_dac_ctrl_wbs_pack.all;
use work.ac_dac_ctrl_core_pack.all;
use work.frame_timing_pack.all;

library components;
use components.component_pack.all;

entity ac_dac_ctrl is        
   port(
      -- DAC hardware interface:
      dac_data_o              : out w14_array11;   
      dac_clks_o              : out std_logic_vector(NUM_OF_ROWS-1 downto 0);
   
      -- wishbone interface:
      dat_i                   : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      addr_i                  : in std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
      tga_i                   : in std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
      we_i                    : in std_logic;
      stb_i                   : in std_logic;
      cyc_i                   : in std_logic;
      dat_o                   : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      ack_o                   : out std_logic;

      -- frame_timing interface:
      row_switch_i            : in std_logic;
      restart_frame_aligned_i : in std_logic;
      row_en_i                : in std_logic;
      
      -- Global Signals      
      clk_i                   : in std_logic;
      rst_i                   : in std_logic     
   );     
end ac_dac_ctrl;

architecture rtl of ac_dac_ctrl is

signal mux_en              : std_logic;

signal on_off_addr         : std_logic_vector(ROW_ADDR_WIDTH-1 downto 0);
signal dac_id              : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
signal on_data             : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
signal off_data            : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);

begin

   wbi: ac_dac_ctrl_wbs       
      port map(
         on_off_addr_i => on_off_addr,
         dac_id_o      => dac_id,     
         on_data_o     => on_data,    
         off_data_o    => off_data,  
         mux_en_o      => mux_en,     
                      
         clk_i         => clk_i,    
         rst_i         => rst_i,    
                       
         dat_i         => dat_i, 
         addr_i        => addr_i,
         tga_i         => tga_i, 
         we_i          => we_i,  
         stb_i         => stb_i, 
         cyc_i         => cyc_i, 
         dat_o         => dat_o, 
         ack_o         => ack_o 
      );               
                       
   acdcc: ac_dac_ctrl_core
      port map(
         -- DAC hardware interface:
         dac_data_o               => dac_data_o,
         dac_clks_o               => dac_clks_o,
      
         -- Wishbone interface
         on_off_addr_o            => on_off_addr,
         dac_id_i                 => dac_id,     
         on_data_i                => on_data,    
         off_data_i               => off_data,  
         mux_en_wbs_i             => mux_en,     
                                  
         -- frame_timing interfac 
         row_switch_i             => row_switch_i,           
         restart_frame_aligned_i  => restart_frame_aligned_i,
         row_en_i                 => row_en_i,               
         
         -- Global Signals      
         clk_i                    => clk_i,    
         rst_i                    => rst_i    
      );                          
     
end rtl;