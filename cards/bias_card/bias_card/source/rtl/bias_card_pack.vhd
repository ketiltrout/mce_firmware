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
-- $Id: bias_card_pack.vhd,v 1.14 2010/05/13 19:23:24 mandana Exp $
--
-- Project:       SCUBA-2
-- Author:        Bryce Burger
-- Organization:  UBC
--
-- Description:
-- 
--
-- Revision history:
-- $Log: bias_card_pack.vhd,v $
-- Revision 1.14  2010/05/13 19:23:24  mandana
-- added support for row-specific flux_fb values by adding:
-- ROW_ADDR_WIDTH constant
-- row_switch_i portto bc_dac_ctrl interface
--
-- Revision 1.13  2010/01/20 22:00:06  mandana
-- added hardware-dependent constants here
-- added array-type defs for the new firmware structure
--
-- Revision 1.12  2006/10/04 18:50:49  mandana
-- renamed rs232_rx/tx to rx/tx to adhere to latest tcl
--
-- Revision 1.11  2006/08/03 19:06:31  mandana
-- reorganized pack files, bc_dac_ctrl_core_pack, bc_dac_ctrl_wbs_pack, frame_timing_pack are all obsolete
--
-- Revision 1.10  2006/06/05 22:59:45  mandana
-- reorganized pack files and now uses all_cards_pack, leds are set to green on only
--
-- Revision 1.9  2006/03/02 20:14:41  mandana
-- added frame_timing component declaration as a consequence of integrating new frame_timing block
-- added FPGA_thermo component declaration
--
-- Revision 1.8  2006/01/19 00:30:59  mandana
-- dispatch_pack.vhd is obsolete now and the dispatch component declaration is added here
--
-- Revision 1.7  2005/07/05 19:49:54  mandana
-- added id_thermo dispatch slave to the top level, rev. 01020001
--
-- Revision 1.6  2005/02/01 01:10:18  mandana
-- slot_id and ttl_nrx1 are now hard coded in the self_test module
--
-- Revision 1.5  2005/01/27 00:12:09  mandana
-- added bias_card_self_test component
--
-- Revision 1.4  2005/01/19 23:39:06  bburger
-- Bryce:  Fixed a couple of errors with the special-character clear.  Always compile, simulate before comitting.
--
-- Revision 1.3  2005/01/12 22:37:11  mandana
-- added slot_id to dispatch interface
-- removed mem_clk_i from dispatch interface
--
-- Revision 1.2  2004/12/16 18:15:33  bench2
-- Mandana: fixed the clocking
--
-- Revision 1.1  2004/12/06 07:22:34  bburger
-- Bryce:
-- Created pack files for the card top-levels.
-- Added some simulation signals to the top-levels (i.e. clocks)
--
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;

library work;
use work.all_cards_pack.all;

package bias_card_pack is

-- Bias card only uses the concept of "rows" when operating in multiplexed mode
constant ROW_ADDR_WIDTH         : integer := 6;

--
-- Constants driven by BC Hardware 
--
constant NUM_FLUX_FB_DACS       : integer := 32;
constant FLUX_FB_DAC_DATA_WIDTH : integer := 16;
constant FLUX_FB_DAC_ADDR_WIDTH : integer := 5;

constant NUM_LN_BIAS_DACS       : integer := 12; -- 1 prior to BC Rev. E hardware
constant LN_BIAS_DAC_DATA_WIDTH : integer := 16;
constant LN_BIAS_DAC_ADDR_WIDTH : integer :=  4; -- 1 prior to BC Rev. E hardware

subtype flux_fb_dac_word  is std_logic_vector(FLUX_FB_DAC_DATA_WIDTH-1 downto 0);         -- parallel DAC data
type flux_fb_dac_array  is array (NUM_FLUX_FB_DACS-1 downto 0) of flux_fb_dac_word;       -- array of parallel DAC data

subtype ln_bias_dac_word  is std_logic_vector(LN_BIAS_DAC_DATA_WIDTH-1 downto 0);         -- parallel DAC data
type ln_bias_dac_array  is array (NUM_LN_BIAS_DACS-1 downto 0) of ln_bias_dac_word;       -- array of parallel DAC data

subtype spi_word is std_logic_vector(SPI_DATA_WIDTH-1 downto 0);
type flux_fb_spi_array is array (NUM_FLUX_FB_DACS-1 downto 0) of spi_word;
type ln_bias_spi_array is array (NUM_LN_BIAS_DACS-1 downto 0) of spi_word;

subtype wb_word is std_logic_vector(WB_DATA_WIDTH-1 downto 0);
type wb_array is array (NUM_FLUX_FB_DACS-1 downto 0) of wb_word;

component bc_dac_ctrl
   port
   (
      -- DAC hardware interface:
      -- There are 32 DAC channels, thus 32 serial data/cs/clk lines.
      flux_fb_data_o    : out std_logic_vector(NUM_FLUX_FB_DACS-1 downto 0);   
      flux_fb_ncs_o     : out std_logic_vector(NUM_FLUX_FB_DACS-1 downto 0);
      flux_fb_clk_o     : out std_logic_vector(NUM_FLUX_FB_DACS-1 downto 0);      
      ln_bias_data_o    : out std_logic;
      ln_bias_ncs_o     : out std_logic_vector(NUM_LN_BIAS_DACS-1 downto 0);
      ln_bias_clk_o     : out std_logic;    
      
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
      row_switch_i      : in std_logic;
      update_bias_i     : in std_logic;
      restart_frame_aligned_i : in std_logic;
      restart_frame_1row_prev_i : in std_logic;
      
      -- Global Signals      
      clk_i             : in std_logic;
      spi_clk_i         : in std_logic;
      rst_i             : in std_logic;
      debug             : inout std_logic_vector(31 downto 0)      
   );     
end component;

component bc_pll
port(inclk0 : in std_logic;
     c0 : out std_logic;
     c1 : out std_logic;
     c2 : out std_logic;
     c3 : out std_logic);
end component;

component bias_card
   port(

      -- PLL input:
      inclk      : in std_logic;
      rst_n      : in std_logic;
      
      -- LVDS interface:
      lvds_cmd   : in std_logic;
      lvds_sync  : in std_logic;
      lvds_spare : in std_logic;
      lvds_txa   : out std_logic;
      lvds_txb   : out std_logic;
      
      -- TTL interface:
      ttl_nrx1   : in std_logic;
      ttl_tx1    : out std_logic;
      ttl_txena1 : out std_logic;
      
      ttl_nrx2   : in std_logic;
      ttl_tx2    : out std_logic;
      ttl_txena2 : out std_logic;
      
      ttl_nrx3   : in std_logic;
      ttl_tx3    : out std_logic;
      ttl_txena3 : out std_logic;

      -- eeprom interface:
      eeprom_si  : in std_logic;
      eeprom_so  : out std_logic;
      eeprom_sck : out std_logic;
      eeprom_cs  : out std_logic;
                  
      -- dac interface:
      dac_ncs       : out std_logic_vector(NUM_FLUX_FB_DACS-1 downto 0);
      dac_sclk      : out std_logic_vector(NUM_FLUX_FB_DACS-1 downto 0);
      dac_data      : out std_logic_vector(NUM_FLUX_FB_DACS-1 downto 0);      
      lvds_dac_ncs  : out std_logic;
      lvds_dac_sclk : out std_logic;
      lvds_dac_data : out std_logic;
      dac_nclr      : out std_logic; -- add to tcl file
      
      -- miscellaneous ports:
      red_led    : out std_logic;
      ylw_led    : out std_logic;
      grn_led    : out std_logic;
      dip_sw3    : in std_logic;
      dip_sw4    : in std_logic;
      wdog       : out std_logic;
      slot_id    : in std_logic_vector(3 downto 0);
      
      -- debug ports:
      test       : inout std_logic_vector(16 downto 3);
      mictor     : out std_logic_vector(31 downto 0);
      mictorclk  : out std_logic_vector(2 downto 1);
      rx         : in std_logic;
      tx         : out std_logic
   );     
end component;
  
-----------------------------------------------------------------------------
-- bias card self test component
-----------------------------------------------------------------------------

component bias_card_self_test
   port(
 
      -- PLL input:
      inclk      : in std_logic;
      rst_n      : in std_logic;
      
      -- LVDS interface:
--      lvds_cmd   : in std_logic;
      lvds_sync  : in std_logic;
      lvds_spare : in std_logic;
      lvds_txa   : out std_logic;
      lvds_txb   : out std_logic;
      
      -- TTL interface:
 --     ttl_nrx1   : in std_logic;
      ttl_tx1    : out std_logic;
      ttl_txena1 : out std_logic;
      
      ttl_nrx2   : in std_logic;
      ttl_tx2    : out std_logic;
      ttl_txena2 : out std_logic;
      
      ttl_nrx3   : in std_logic;
      ttl_tx3    : out std_logic;
      ttl_txena3 : out std_logic;

      -- eeprom interface:
      eeprom_si  : in std_logic;
      eeprom_so  : out std_logic;
      eeprom_sck : out std_logic;
      eeprom_cs  : out std_logic;
                  
      -- dac interface:
      dac_ncs       : out std_logic_vector(NUM_FLUX_FB_DACS-1 downto 0);
      dac_sclk      : out std_logic_vector(NUM_FLUX_FB_DACS-1 downto 0);
      dac_data      : out std_logic_vector(NUM_FLUX_FB_DACS-1 downto 0);      
      lvds_dac_ncs  : out std_logic;
      lvds_dac_sclk : out std_logic;
      lvds_dac_data : out std_logic;
      dac_nclr      : out std_logic; -- add to tcl file
      
      -- miscellaneous ports:
      red_led    : out std_logic;
      ylw_led    : out std_logic;
      grn_led    : out std_logic;
      dip_sw3    : in std_logic;
      dip_sw4    : in std_logic;
      wdog       : out std_logic;
 --     slot_id    : in std_logic_vector(3 downto 0);
      
      -- debug ports:
      test       : inout std_logic_vector(16 downto 3);
      mictor     : out std_logic_vector(31 downto 0);
      mictorclk  : out std_logic_vector(2 downto 1);
      rx   : in std_logic;
      tx   : out std_logic
   );
end component;

                                     
end bias_card_pack;
