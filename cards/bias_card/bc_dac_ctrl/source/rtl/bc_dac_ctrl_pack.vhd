-- Copyright (c) 2003 SCUBA-2 Project
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

-- $Id$
--

-- Project:       SCUBA2
-- Author:        Bryce Burger
-- Organisation:  UBC
--
-- Description:
-- package file for dac_ctrl
--
-- 
-- Revision history:
-- $Log$
--
--
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library sys_param;
use sys_param.wishbone_pack.all;
use sys_param.command_pack.all;

library work;
use work.wbs_bc_dac_ctrl_pack.all;

package bc_dac_ctrl_pack is

constant NUM_FLUX_FB_DACS : integer := 32;
constant BIAS_DATA_LENGTH : integer := 16;

component bc_dac_ctrl
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

      -- wbs_bc_dac_ctrl interface:
      flux_fb_addr_o    : out std_logic_vector(COL_ADDR_WIDTH-1 downto 0);
      flux_fb_data_i    : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
      bias_data_i       : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
      flux_fb_changed_i : in std_logic;
      bias_changed_i    : in std_logic;
      
      -- frame_timing signals
      update_bias_i     : in std_logic;
      
      -- Global Signals      
      clk_i             : in std_logic;
      rst_i             : in std_logic      
   );     
end component;
   
end bc_dac_ctrl_pack;

