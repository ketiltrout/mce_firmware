-- 2003 SCUBA-2 Project
--                  All Rights Reserved

--  THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF THE SCUBA-2 Project
--  The copyright notice above does not evidence any
--  actual or intended publication of such source code.

--  SOURCE CODE IS PROVIDED "AS IS". ALL EXPRESS OR IMPLIED CONDITIONS,
--  REPRESENTATIONS, AND WARRANTIES, INCLUDING ANY IMPLIED WARRANT OF
--  MERCHANTABILITY, SATISFACTORY QUALITY, FITNESS FOR A PARTICULAR
--  PURPOSE, OR NON-INFRINGEMENT, ARE DISCLAIMED, EXCEPT TO THE EXTENT
--  THAT SUCH DISCLAIMERS ARE HELD TO BE LEGALLY INVALID.

-- For the purposes of this code the SCUBA-2 Project consists of the
-- following organisations.

-- UKATC, Royal Observatory, Blackford Hill Edinburgh EH9 3HJ
-- UBC,   University of British Columbia, Physics & Astronomy Department,
--        Vancouver BC, V6T 1Z1

-- $Id: bc_dac_ctrl.vhd,v 1.2 2004/11/15 20:03:41 bburger Exp $
--
-- Project:       SCUBA2
-- Author:        Bryce Burger
-- Organisation:  UBC
--
-- Description:
-- 
-- Revision history:
-- $Log: bc_dac_ctrl.vhd,v $
-- Revision 1.2  2004/11/15 20:03:41  bburger
-- Bryce :  Moved frame_timing to the 'work' library, and physically moved the files to "all_cards" directory
--
-- Revision 1.1  2004/11/11 01:47:10  bburger
-- Bryce:  new
--
--   
--
-- 
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
--use ieee.std_logic_unsigned.all;

library sys_param;
use sys_param.wishbone_pack.all;
use sys_param.general_pack.all;
use sys_param.data_types_pack.all;
use sys_param.command_pack.all;

library components;
use components.component_pack.all;

library work;
use work.bc_dac_ctrl_pack.all;
use work.bc_dac_ctrl_core_pack.all;
use work.bc_dac_ctrl_wbs_pack.all;
use work.frame_timing_pack.all;

entity bc_dac_ctrl is
   port
   (
      -- DAC hardware interface:
      -- There are 32 DAC channels, thus 32 serial data/cs/clk lines.
      flux_fb_data_o    : out std_logic_vector(NUM_FLUX_FB_DACS-1 downto 0);   
      flux_fb_ncs_o     : out std_logic_vector(NUM_FLUX_FB_DACS-1 downto 0);
      flux_fb_clk_o     : out std_logic_vector(NUM_FLUX_FB_DACS-1 downto 0);      
      bias_data_o       : out std_logic;
      bias_ncs_o        : out std_logic;
      bias_clk_o        : out std_logic;      
      dac_nclr_o        : out std_logic;
      
      -- wishbone interface:
      dat_i                   : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      addr_i                  : in std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
      tga_i                   : in std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
      we_i                    : in std_logic;
      stb_i                   : in std_logic;
      cyc_i                   : in std_logic;
      dat_o                   : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      ack_o                   : out std_logic;
      
      -- frame_timing signals
      update_bias_i     : in std_logic;
      
      -- Global Signals      
      clk_i             : in std_logic;
      mem_clk_i         : in std_logic;
      rst_i             : in std_logic      
   );     
end bc_dac_ctrl;

architecture rtl of bc_dac_ctrl is

   -- wbs_bc_dac_ctrl interface:
   signal flux_fb_addr    : std_logic_vector(COL_ADDR_WIDTH-1 downto 0);
   signal flux_fb_data    : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal bias_data       : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal flux_fb_changed : std_logic;
   signal bias_changed    : std_logic;   
   
begin

 bcdc_core: bc_dac_ctrl_core
   port map(
      -- DAC hardware interface:
      flux_fb_data_o    => flux_fb_data_o,
      flux_fb_ncs_o     => flux_fb_ncs_o, 
      flux_fb_clk_o     => flux_fb_clk_o, 
      
      bias_data_o       => bias_data_o,
      bias_ncs_o        => bias_ncs_o, 
      bias_clk_o        => bias_clk_o, 
      
      dac_nclr_o        => dac_nclr_o,

      -- wbs_bc_dac_ctrl interface:
      flux_fb_addr_o    => flux_fb_addr,
      flux_fb_data_i    => flux_fb_data,   
      bias_data_i       => bias_data,      
      flux_fb_changed_i => flux_fb_changed,
      bias_changed_i    => bias_changed,   
      
      -- frame_timing signals
      update_bias_i     => update_bias_i,
      
      -- Global Signals      
      clk_i             => clk_i,
      rst_i             => rst_i
   );     

bcdc_wbs: bc_dac_ctrl_wbs
   port map(
      -- ac_dac_ctrl interface:
      flux_fb_addr_i    => flux_fb_addr,
      flux_fb_data_o    => flux_fb_data,   
      bias_data_o       => bias_data,      
      flux_fb_changed_o => flux_fb_changed,
      bias_changed_o    => bias_changed,   

      -- wishbone interface:
      dat_i             => dat_i, 
      addr_i            => addr_i,
      tga_i             => tga_i, 
      we_i              => we_i,  
      stb_i             => stb_i, 
      cyc_i             => cyc_i, 
      dat_o             => dat_o, 
      ack_o             => ack_o, 

      -- global interface
      clk_i             => clk_i,
      mem_clk_i         => mem_clk_i,
      rst_i             => rst_i
   );
      
end rtl;