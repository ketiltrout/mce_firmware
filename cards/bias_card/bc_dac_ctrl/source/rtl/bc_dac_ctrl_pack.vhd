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

-- $Id: bc_dac_ctrl_pack.vhd,v 1.13 2016/05/19 22:14:24 mandana Exp $
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
-- Revision 1.13  2016/05/19 22:14:24  mandana
-- 6.0.1 added flux_fb_dly parameter and removed num_idle_rows implementation
--
-- Revision 1.12  2014/12/18 23:21:41  mandana
-- 5.3.5 added num_idle_rows
--
-- Revision 1.11  2012-12-20 20:55:19  mandana
-- added DAC_CYCLE_COUNT_MAX to indicate time spent to refresh each LN_BIAS DAC
--
-- Revision 1.10  2011-11-29 00:55:44  mandana
-- ln_bias_changed changed to std_logic_vector, one bit per DAC
--
-- Revision 1.9  2010/06/02 17:40:58  mandana
-- flux_fb_changed flag is now defined as 1 bit per column
-- 1row_prev is added to the interface
--
-- Revision 1.8  2010/05/14 22:50:04  mandana
-- parametrized ram interfaces
-- adds interface ports for mux_flux_fb_data, row_switch, row_addr
--
-- Revision 1.7  2010/01/20 23:11:53  mandana
-- moved hardware-dependent constants to bias_card_pack
-- added low-noise bias interface
-- added ram components for storing flux_fb and ln_bias values
--
-- Revision 1.6  2006/08/03 19:06:31  mandana
-- reorganized pack files, bc_dac_ctrl_core_pack, bc_dac_ctrl_wbs_pack, frame_timing_pack are all obsolete
--
-- Revision 1.5  2005/01/19 02:42:19  bburger
-- Bryce:  Fixed a couple of errors.  Always compile, simulate before comitting.
--
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

library work;
use work.bias_card_pack.all;

package bc_dac_ctrl_pack is

constant DAC_CYCLE_COUNT_MAX         : integer := 44; -- number of clock cycles to refresh one LN_BIAS DAC, they are refreshed sequentially due to shared data/clock lines

component bc_dac_ctrl_core
   port
   (
      -- DAC hardware interface:
      -- There are 32 flux-fb DAC channels, thus 32 serial data/cs/clk lines.
      -- There are 12 (1 prior to Rev E Hardware) low-noise bias DAC channels with shared data/clk lines
      flux_fb_data_o    : out std_logic_vector(NUM_FLUX_FB_DACS-1 downto 0);   
      flux_fb_ncs_o     : out std_logic_vector(NUM_FLUX_FB_DACS-1 downto 0);
      flux_fb_clk_o     : out std_logic_vector(NUM_FLUX_FB_DACS-1 downto 0);
      
      ln_bias_data_o    : out std_logic;
      ln_bias_ncs_o     : out std_logic_vector(NUM_LN_BIAS_DACS-1 downto 0);
      ln_bias_clk_o     : out std_logic;
      
      dac_nclr_o        : out std_logic;

      -- wbs_bc_dac_ctrl interface:
      row_addr_o        : out std_logic_vector(ROW_ADDR_WIDTH-1 downto 0);
      flux_fb_addr_o    : out std_logic_vector(FLUX_FB_DAC_ADDR_WIDTH-1 downto 0);
      flux_fb_data_i    : in flux_fb_dac_array; 
      flux_fb_changed_i : in std_logic_vector(NUM_FLUX_FB_DACS-1 downto 0);
      ln_bias_addr_o    : out std_logic_vector(LN_BIAS_DAC_ADDR_WIDTH-1 downto 0);
      ln_bias_data_i    : in std_logic_vector(LN_BIAS_DAC_DATA_WIDTH-1 downto 0);
      ln_bias_changed_i : in std_logic_vector(NUM_LN_BIAS_DACS-1 downto 0);

      mux_flux_fb_data_i: in flux_fb_dac_array;    
      enbl_mux_data_i   : in std_logic_vector(NUM_FLUX_FB_DACS-1 downto 0);
      
      -- frame_timing signals
      row_switch_i      : in std_logic;
      update_bias_i     : in std_logic;
      flux_fb_dly_i     : in std_logic;
      restart_frame_aligned_i : in std_logic;
      restart_frame_1row_prev_i : in std_logic;
      
      -- Global Signals      
      clk_i             : in std_logic;
      spi_clk_i         : in std_logic;
      rst_i             : in std_logic;
      debug             : inout std_logic_vector(31 downto 0)
   );     
end component;
   
component bc_dac_ctrl_wbs is        
   port
   (
      -- ac_dac_ctrl interface:
      flux_fb_addr_i    : in std_logic_vector(FLUX_FB_DAC_ADDR_WIDTH-1 downto 0);
      flux_fb_data_o    : out flux_fb_dac_array; 
      flux_fb_changed_o : out std_logic_vector(NUM_FLUX_FB_DACS-1 downto 0);
      ln_bias_addr_i    : in std_logic_vector(LN_BIAS_DAC_ADDR_WIDTH-1 downto 0);     
      ln_bias_data_o    : out std_logic_vector(LN_BIAS_DAC_DATA_WIDTH-1 downto 0); 
      ln_bias_changed_o : out std_logic_vector(NUM_LN_BIAS_DACS-1 downto 0);

      mux_flux_fb_data_o: out flux_fb_dac_array;    
      enbl_mux_data_o   : out std_logic_vector(NUM_FLUX_FB_DACS-1 downto 0);

      -- current_row to access the right flux_fb bank when in multiplexing mode (enbl_mux = 1)
      row_addr_i        : in std_logic_vector(ROW_ADDR_WIDTH-1 downto 0);
      row_switch_i      : in std_logic;

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
      rst_i             : in std_logic;
      debug             : inout std_logic_vector(31 downto 0)
   );     
end component;

component ram_16x64 is
   PORT
   (
      data     : IN STD_LOGIC_VECTOR (FLUX_FB_DAC_DATA_WIDTH-1 DOWNTO 0);
      wraddress      : IN STD_LOGIC_VECTOR (ROW_ADDR_WIDTH-1 DOWNTO 0);
      rdaddress_a    : IN STD_LOGIC_VECTOR (ROW_ADDR_WIDTH-1 DOWNTO 0);
      rdaddress_b    : IN STD_LOGIC_VECTOR (ROW_ADDR_WIDTH-1 DOWNTO 0);
      wren     : IN STD_LOGIC  := '1';
      clock    : IN STD_LOGIC ;
      qa    : OUT STD_LOGIC_VECTOR (FLUX_FB_DAC_DATA_WIDTH-1 DOWNTO 0);
      qb    : OUT STD_LOGIC_VECTOR (FLUX_FB_DAC_DATA_WIDTH-1 DOWNTO 0)
   );
end component;

component ram_16x16 is
   PORT
   (
      data     : IN STD_LOGIC_VECTOR (LN_BIAS_DAC_DATA_WIDTH-1 DOWNTO 0);
      wraddress      : IN STD_LOGIC_VECTOR (LN_BIAS_DAC_ADDR_WIDTH-1 DOWNTO 0);
      rdaddress_a    : IN STD_LOGIC_VECTOR (LN_BIAS_DAC_ADDR_WIDTH-1 DOWNTO 0);
      rdaddress_b    : IN STD_LOGIC_VECTOR (LN_BIAS_DAC_ADDR_WIDTH-1 DOWNTO 0);
      wren     : IN STD_LOGIC  := '1';
      clock    : IN STD_LOGIC ;
      qa    : OUT STD_LOGIC_VECTOR (LN_BIAS_DAC_DATA_WIDTH-1 DOWNTO 0);
      qb    : OUT STD_LOGIC_VECTOR (LN_BIAS_DAC_DATA_WIDTH-1 DOWNTO 0)
   );
end component;

end bc_dac_ctrl_pack;

