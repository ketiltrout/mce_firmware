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

-- $Id: bc_dac_ctrl_pack.vhd,v 1.4 2005/01/04 19:19:47 bburger Exp $
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
-- $Log: bc_dac_ctrl_pack.vhd,v $
-- Revision 1.4  2005/01/04 19:19:47  bburger
-- Mandana: changed mictor assignment to 0 to 31 and swapped odd and even pods
--
-- Revision 1.3  2004/12/21 22:06:51  bburger
-- Bryce:  update
--
-- Revision 1.2  2004/11/25 03:05:08  bburger
-- Bryce:  Modified the Bias Card DAC control slaves.
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

library sys_param;
use sys_param.wishbone_pack.all;
use sys_param.command_pack.all;

--library work;
--use work.bc_dac_ctrl_pack.all;

package bc_dac_ctrl_pack is

constant NUM_FLUX_FB_DACS : integer := 32;
constant BIAS_DATA_LENGTH : integer := 16;
constant COL_ADDR_WIDTH   : integer := 6; 

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
      rst_i             : in std_logic;
      debug             : inout std_logic_vector(31 downto 0)      
   );     
end component;
   
end bc_dac_ctrl_pack;

