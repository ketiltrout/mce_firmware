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
-- $Id: bias_card.vhd,v 1.52 2012-12-20 23:17:49 mandana Exp $
--
-- Project:       SCUBA-2
-- Author:        Bryce Burger
-- Organisation:  UBC
--
-- Description:
-- Bias Card top-level file
--
-- Revision history:
--
-- $Log: bias_card.vhd,v $
-- Revision 1.52  2012-12-20 23:17:49  mandana
-- 5.3.4 enbl_bias_mod and enbl_flux_fb_mod now work properly.
--
-- Revision 1.51  2012-08-21 22:08:04  mandana
-- rev. 5.3.2 compiled for Rev. E cards with different lvds_dac pin assigments, check tcl file
--
-- Revision 1.50  2012-04-13 18:05:13  mandana
-- rev. 5.3.1 mod_val takes one value
--
-- Revision 1.49  2012-03-26 21:57:33  mandana
-- rev. 5.1.3 with enbl_bias_mod, enbl_flux_fb_mod, mod_val
-- compiled with Q11.1sp2, sdc file and timequest
--
-- Revision 1.48  2011-11-29 01:00:13  mandana
-- rev. 5.2.0
-- added dev_clr_fpga_out and critical_error_reset support through reset_clr module
-- ln_bias dacs now wake up at 0V on both Rev. D and Rev. F cards
-- bugfix associated with collision of wb bias arriving on ARZ
--
-- Revision 1.47  2011-10-26 18:25:21  mandana
-- 5.1.0 with modified cs/clk timing for flux-fb DACs, cs is always active and deasserted only at restart_frame_timing_1dly
-- In non-multiplex mode, flux_fb updates are frame aligned, previously row-aligned
-- bugfix: ln_bias values are not loaded twice anymore, only once!
--
-- Revision 1.46  2011-10-24 20:25:44  mandana
-- 5.0.a the only change is in spi_if.vhd to have a complete if statement! and update_bias=42 in frame_timing_pack
--
-- Revision 1.45  2011-10-05 22:11:56  mandana
-- 5.0.8 update_bias parameter changed to 10 which causes biases to be loaded 32 clock cycles after row switch
--
-- Revision 1.44  2011-10-05 20:04:23  mandana
-- 5.0.8 update_bias parameter changed to 22 which causes biases to be loaded few (20?) clock cycles after row switch
--
-- Revision 1.43  2011-06-23 16:13:07  mandana
-- 5.0.7 update_bias parameter changed to 32 which causes biases to be loaded few (10?) clock cycles after row switch
--
-- Revision 1.42  2011-05-11 21:32:13  bburger
-- BB:  bc_v05000006
--
-- Revision 1.41  2010-07-19 23:42:56  mandana
-- rev. 5.0.5
-- adds pcb_rev_i interface to read the hardware revision through card_type parameter
-- This firmware can be run on both Rev. D and Rev. F cards
-- card_type is set to 1 indicating bias card type!
--
-- Revision 1.40  2010/06/02 17:38:54  mandana
-- 5.0.4 biases (regular and low noise) are refreshed 1 clock cycle after the start of a new row, regardless of enbl_mux =0 or 1
-- use 1row_prev signal from frame_timing interface to reset the index of bias value memory
--
-- Revision 1.39  2010/05/13 23:58:36  mandana
-- 5.0.3 adds support for fb_col0 to fb_col31 and enbl_mux commands to allow fast switching of sq2fb values
--
-- Revision 1.38  2010/01/28 01:14:26  mandana
-- rev. 5.0.2
-- removed eeprom interface from top-level as there is none on bias card!
-- ln_bias lines are controlled individually
--
-- Revision 1.37  2010/01/20 21:57:19  mandana
-- rev. 5.0.1
-- Firmware changed to loading all DACs in parallel as opposed to one after next in preparation for SQ2_FB switching implementation
-- added interface for 12 new low-noise biases introduced in Bias_card Rev. E and card_type set to 5.
-- If this firmware runs on BC Rev. D, the bias command will not work as cs and clk are swapped between Rev. D and E. Otherwise, the firmware is harmless to rev.D
-- supports cards with both temperature reading chips: MAX1618 (old cards) and LM95235 (on new cards)
--
-- Revision 1.36  2009/11/24 23:49:59  bburger
-- BB: Made a top-level modification that does not affect old cards with the MAX1618, but enables the LM95235 on new cards.
--
-- Revision 1.35  2009/03/19 20:19:01  bburger
-- BB:  Added default TTL outputs
--
-- Revision 1.34  2009/01/16 01:36:22  bburger
-- BB:  v05000000 again, due to a signal name change and new commands added
--
-- Revision 1.33  2008/12/22 20:36:59  bburger
-- BB:  Added a second LVDS reply channel to dispatch
--
-- Revision 1.32  2008/07/15 17:48:58  bburger
-- BB: bc_v01040002
--
-- Revision 1.31  2008/01/26 01:20:33  mandana
-- added all_cards slave to add card_type, scratch and integrate fw_rev and slot_id
-- rev. 1.4.1
--
-- Revision 1.30  2007/12/20 00:39:29  mandana
-- rev. 1.4.0
-- added flux_fb_upper command for mceV2
-- added safe FSM compile option + completing state machines
--
-- Revision 1.29  2007/03/08 22:24:13  mandana
-- Rev. 01030007 to fix fpga_thermo bug and 1C resolution for card_temp instead of 0.5C
--
-- Revision 1.28  2006/10/04 18:49:26  mandana
-- updated revision to x1030006 for seperating update_bias and update_flux_fb
-- updated top-level interface according to latest bias-card tcl
--
-- Revision 1.27  2006/08/03 19:06:31  mandana
-- reorganized pack files, bc_dac_ctrl_core_pack, bc_dac_ctrl_wbs_pack, frame_timing_pack are all obsolete
--
-- Revision 1.26  2006/06/05 22:59:45  mandana
-- reorganized pack files and now uses all_cards_pack, leds are set to green on only
--
-- Revision 1.25  2006/04/07 23:15:42  bburger
-- Bryce:  Commital for v01030004
--
-- Revision 1.24  2006/04/07 22:00:46  bburger
-- Bryce:  Commital for v01030003
--
-- Revision 1.23  2006/03/08 21:01:46  bench2
-- Mandana: changed revision to 01030002 to incorporate 100MHz lvds_rx
--
-- Revision 1.22  2006/03/02 20:12:51  mandana
-- revision number changed to 01030001 for new dispatch and backplane Rev. C
-- added FPGA_thermo
--
-- Revision 1.21  2006/02/09 20:32:59  bburger
-- Bryce:
-- - Added a fltr_rst_o output signal from the frame_timing block
-- - Adjusted the top-levels of each card to reflect the frame_timing interface change
--
-- Revision 1.20  2006/01/19 00:30:27  mandana
-- new dispatch module that incorporates the new BB protocol is integrated, rev. num upgraded to 01020002
--
-- Revision 1.19  2005/07/05 19:49:54  mandana
-- added id_thermo dispatch slave to the top level, rev. 01020001
--
-- Revision 1.18  2005/06/03 20:36:25  mandana
-- build revision 01010007 updated the tcl script to reverse ch0 to ch16 pin assignment
--
-- Revision 1.17  2005/05/17 21:07:38  mandana
-- v01010006 frame_timing fix
--
-- Revision 1.16  2005/05/06 20:02:31  bburger
-- Bryce:  Added a 50MHz clock that is 180 degrees out of phase with clk_i.
-- This clk_n_i signal is used for sampling the sync_i line during the middle of the pulse, to avoid problems associated with sampling on the edges.
--
-- Revision 1.15  2005/04/20 20:54:51  mandana
-- build revision 0005, frame_timing updated
--
-- Revision 1.14  2005/03/31 18:32:28  mandana
-- Build revision 0004
--
-- Revision 1.13  2005/03/24 19:23:32  mandana
-- build revision changed to 0003
--
-- Revision 1.12  2005/03/07 20:29:32  bench2
-- build revision changed to 0002
--
-- Revision 1.11  2005/02/21 22:25:58  mandana
-- added firmware revision (fw_rev)
--
-- Revision 1.10  2005/01/19 23:39:06  bburger
-- Bryce:  Fixed a couple of errors with the special-character clear.  Always compile, simulate before comitting.
--
-- Revision 1.9  2005/01/19 02:42:19  bburger
-- Bryce:  Fixed a couple of errors.  Always compile, simulate before comitting.
--
-- Revision 1.8  2005/01/18 22:20:47  bburger
-- Bryce:  Added a BClr signal across the bus backplane to all the card top levels.
--
-- Revision 1.7  2005/01/17 23:03:11  mandana
-- removed mem_clk_i from bc_dac_ctrl
--
-- Revision 1.6  2005/01/12 22:37:11  mandana
-- added slot_id to dispatch interface
-- removed mem_clk_i from dispatch interface
--
-- Revision 1.5  2005/01/07 01:33:23  bench2
-- Mandana: remove spi_clk from PLL, it is divided down by a counter in bc_dac_core module now.
--
-- Revision 1.4  2005/01/04 19:19:47  bburger
-- Mandana: changed mictor assignment to 0 to 31 and swapped odd and even pods
--
-- Revision 1.3  2004/12/21 22:06:51  bburger
-- Bryce:  update
--
-- Revision 1.2  2004/12/16 18:09:35  bench2
-- Mandana: fixed the clocking, added bc_pll
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
use work.bias_card_pack.all;
use work.all_cards_pack.all;

entity bias_card is
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

      -- dac interface:
      dac_ncs       : out std_logic_vector(NUM_FLUX_FB_DACS-1 downto 0);
      dac_sclk      : out std_logic_vector(NUM_FLUX_FB_DACS-1 downto 0);
      dac_data      : out std_logic_vector(NUM_FLUX_FB_DACS-1 downto 0);
      lvds_dac_ncs  : out std_logic_vector(NUM_LN_BIAS_DACS-1 downto 0);
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
      card_id    : inout std_logic;
      pcb_rev    : in std_logic_vector(3 downto 0);
      smb_clk    : out std_logic;
      smb_nalert : out std_logic;
      smb_data   : inout std_logic;
      dev_clr_fpga_out: out std_logic;
      critical_error: out std_logic;
      
      -- debug ports:
      test       : inout std_logic_vector(14 downto 1);
      mictor     : out std_logic_vector(31 downto 0);
      mictorclk  : out std_logic_vector(2 downto 1);
      rx         : in std_logic;
      tx         : out std_logic
   );
end bias_card;

architecture top of bias_card is

-- The REVISION format is RRrrBBBB where
--               RR is the major revision number, incremented when major new features are added and possibly incompatible with previous versions
--               rr is the minor revision number, incremented when new features added
--               BBBB is the build number, incremented for bug fixes
constant BC_REVISION: std_logic_vector (31 downto 0) := X"05030005";

-- all_cards regs (including fw_rev, card_type, slot_id, scratch) signals
signal all_cards_data          : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
signal all_cards_ack           : std_logic;
signal all_cards_err           : std_logic;

signal dac_ncs_temp : std_logic_vector(NUM_FLUX_FB_DACS-1 downto 0);
signal dac_sclk_temp: std_logic_vector(NUM_FLUX_FB_DACS-1 downto 0);
signal dac_data_temp: std_logic_vector(NUM_FLUX_FB_DACS-1 downto 0);

-- clocks
signal clk      : std_logic;
signal comm_clk : std_logic;
signal clk_n    : std_logic;
signal spi_clk  : std_logic;

signal rst      : std_logic;

-- wishbone bus (from master)
signal data : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
signal addr : std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
signal tga  : std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
signal we   : std_logic;
signal stb  : std_logic;
signal cyc  : std_logic;

-- wishbone bus (from slaves)
signal slave_data        : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
signal slave_ack         : std_logic;
signal led_data          : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
signal led_ack           : std_logic;
signal bc_dac_data       : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
signal bc_dac_ack        : std_logic;
signal frame_timing_data : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
signal frame_timing_ack  : std_logic;
signal slave_err         : std_logic;

signal id_thermo_data    : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
signal id_thermo_ack     : std_logic;
signal id_thermo_err     : std_logic;

signal fpga_thermo_data  : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
signal fpga_thermo_ack   : std_logic;
signal fpga_thermo_err   : std_logic;

signal reset_clr_data  : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
signal reset_clr_ack   : std_logic;
signal reset_clr_err   : std_logic;

-- frame_timing interface
signal update_bias : std_logic;
signal restart_frame_aligned : std_logic;
signal restart_frame_1row_prev: std_logic;
signal row_switch  : std_logic;


signal debug       : std_logic_vector (31 downto 0);
   

begin

   -- Default assignments to get rid of synthesis warnings.
   ttl_tx1    <= '0';
   ttl_txena2 <= '1';
   ttl_tx2    <= '0';
   ttl_txena3 <= '1';
   ttl_tx3    <= '0';
   
   -- Active low enable signal for the transmitter on the card.  With '1' it is disabled.
   -- The transmitter is disabled because the Clock Card is driving this line.
   ttl_txena1 <= '1';
   -- The ttl_nrx1 signal is inverted on the Card, thus the FPGA sees an active-high signal.
   rst <= (not rst_n) or (ttl_nrx1);

   mictor   <= debug;
   --test (4) <= dac_ncs_temp(0);
   --test (6) <= dac_data_temp(0);
   --test (8) <= dac_sclk_temp(0);

   dac_ncs <= dac_ncs_temp;
   dac_data <= dac_data_temp;
   dac_sclk <= dac_sclk_temp;

   pll0: bc_pll
   port map(
      inclk0 => inclk,
      c0 => clk,
      c1 => comm_clk,
      c2 => clk_n,
      c3 => spi_clk
   );

   cmd0: dispatch
   port map(
      clk_i                      => clk,
      comm_clk_i                 => comm_clk,
      rst_i                      => rst,

      lvds_cmd_i                 => lvds_cmd,
      lvds_replya_o              => lvds_txa,
      lvds_replyb_o              => lvds_txb,

      dat_o                      => data,
      addr_o                     => addr,
      tga_o                      => tga,
      we_o                       => we,
      stb_o                      => stb,
      cyc_o                      => cyc,
      dat_i                      => slave_data,
      ack_i                      => slave_ack,
      err_i                      => slave_err,
      wdt_rst_o                  => wdog,
      slot_i                     => slot_id,
      dip_sw3                    => '1',
      dip_sw4                    => '1'
   );

   id_thermo0: id_thermo
   port map(
      clk_i                      => clk,
      rst_i                      => rst,

      -- Wishbone signals
      dat_i                      => data,
      addr_i                     => addr,
      tga_i                      => tga,
      we_i                       => we,
      stb_i                      => stb,
      cyc_i                      => cyc,
      err_o                      => id_thermo_err,
      dat_o                      => id_thermo_data,
      ack_o                      => id_thermo_ack,

      -- silicon id/temperature chip signals
      data_io                    => card_id
   );

   smb_nalert <= '0';
   fpga_thermo0: fpga_thermo
   port map(
      clk_i                      => clk,
      rst_i                      => rst,

      -- Wishbone signals
      dat_i                      => data,
      addr_i                     => addr,
      tga_i                      => tga,
      we_i                       => we,
      stb_i                      => stb,
      cyc_i                      => cyc,
      err_o                      => fpga_thermo_err,
      dat_o                      => fpga_thermo_data,
      ack_o                      => fpga_thermo_ack,

      -- FPGA temperature chip signals
      smbclk_o                   => smb_clk,
      smbalert_i                 => '1',
      smbdat_io                  => smb_data
   );


   leds_slave: leds
   port map(
      clk_i                      => clk,
      rst_i                      => rst,

      dat_i                      => data,
      addr_i                     => addr,
      tga_i                      => tga,
      we_i                       => we,
      stb_i                      => stb,
      cyc_i                      => cyc,
      dat_o                      => led_data,
      ack_o                      => led_ack,

      power                      => grn_led,
      status                     => ylw_led,
      fault                      => red_led
   );

   i_reset_clr: reset_clr
   port map(
      clk_i                      => clk,
      rst_i                      => rst,

      -- Wishbone signals
      dat_i                      => data,
      addr_i                     => addr,
      tga_i                      => tga,
      we_i                       => we,
      stb_i                      => stb,
      cyc_i                      => cyc,
      err_o                      => reset_clr_err,
      dat_o                      => reset_clr_data,
      ack_o                      => reset_clr_ack,
      
      -- outputs
      critical_error_o           => critical_error,
      dev_clr_o                  => dev_clr_fpga_out
   );
   ----------------------------------------------------------------------------
   -- all_cards registers Instantition
   ----------------------------------------------------------------------------

    i_all_cards: all_cards
    generic map(
       REVISION => BC_REVISION,
       CARD_TYPE=> BC_CARD_TYPE)
    port map(
       clk_i  => clk,
       rst_i  => rst,

       dat_i  => data,
       addr_i => addr,
       tga_i  => tga,
       we_i   => we,
       stb_i  => stb,
       cyc_i  => cyc,
       slot_id_i => slot_id,
       pcb_rev_i => pcb_rev,
       err_o           => all_cards_err,
       dat_o           => all_cards_data,
       ack_o           => all_cards_ack
    );
   ----------------------------------------------------------------------------
   -- DAC-control block Instantiation
   ----------------------------------------------------------------------------

   bc_dac_ctrl_slave: bc_dac_ctrl
   port map(
      -- DAC hardware interface:
      -- There are 32 DAC channels, thus 32 serial data/cs/clk lines.
      flux_fb_data_o             => dac_data_temp,
      flux_fb_ncs_o              => dac_ncs_temp,
      flux_fb_clk_o              => dac_sclk_temp,

      ln_bias_data_o             => lvds_dac_data,
      ln_bias_ncs_o              => lvds_dac_ncs,
      ln_bias_clk_o              => lvds_dac_sclk,      
      
      dac_nclr_o                 => dac_nclr,

      -- wishbone interface:
      dat_i                      => data,
      addr_i                     => addr,
      tga_i                      => tga,
      we_i                       => we,
      stb_i                      => stb,
      cyc_i                      => cyc,
      dat_o                      => bc_dac_data,
      ack_o                      => bc_dac_ack,

      -- frame_timing signals
      row_switch_i               => row_switch,
      update_bias_i              => update_bias,
      restart_frame_aligned_i    => restart_frame_aligned,
      restart_frame_1row_prev_i  => restart_frame_1row_prev,
      
      -- Global Signals
      clk_i                      => clk,
      spi_clk_i                  => spi_clk,
      rst_i                      => rst,
      debug                      => debug
   );

   frame_timing_slave: frame_timing
   port map(
      dac_dat_en_o               => open,
      adc_coadd_en_o             => open,
      restart_frame_1row_prev_o  => restart_frame_1row_prev,
      restart_frame_aligned_o    => restart_frame_aligned,
      restart_frame_1row_post_o  => open,
      initialize_window_o        => open,
      
      row_count_o                => open,
      row_switch_o               => row_switch,
      row_en_o                   => open,

      update_bias_o              => update_bias,

      dat_i                      => data,
      addr_i                     => addr,
      tga_i                      => tga,
      we_i                       => we,
      stb_i                      => stb,
      cyc_i                      => cyc,
      dat_o                      => frame_timing_data,
      ack_o                      => frame_timing_ack,

      clk_i                      => clk,
      clk_n_i                    => clk_n,
      rst_i                      => rst,
      sync_i                     => lvds_sync
   );

   --------------------------------------------------

   with addr select
      slave_data <=
         all_cards_data    when FW_REV_ADDR | SLOT_ID_ADDR | CARD_TYPE_ADDR | SCRATCH_ADDR,
         
         reset_clr_data    when CRIT_ERR_RST_ADDR | DEV_CLR_ADDR,
         
         led_data          when LED_ADDR,
         
         bc_dac_data       when FLUX_FB_ADDR | BIAS_ADDR | FLUX_FB_UPPER_ADDR | ENBL_MUX_ADDR | ENBL_FLUX_FB_MOD_ADDR | ENBL_BIAS_MOD_ADDR | MOD_VAL_ADDR |BC_NUM_IDLE_ROWS_ADDR|
                                FB_COL0_ADDR | FB_COL1_ADDR | FB_COL2_ADDR | FB_COL3_ADDR | FB_COL4_ADDR | FB_COL5_ADDR | FB_COL6_ADDR | FB_COL7_ADDR | 
                                FB_COL8_ADDR | FB_COL9_ADDR | FB_COL10_ADDR | FB_COL11_ADDR | FB_COL12_ADDR | FB_COL13_ADDR | FB_COL14_ADDR | FB_COL15_ADDR | 
                                FB_COL16_ADDR | FB_COL17_ADDR | FB_COL18_ADDR | FB_COL19_ADDR | FB_COL20_ADDR | FB_COL21_ADDR | FB_COL22_ADDR | FB_COL23_ADDR | 
                                FB_COL24_ADDR | FB_COL25_ADDR | FB_COL26_ADDR | FB_COL27_ADDR | FB_COL28_ADDR | FB_COL29_ADDR | FB_COL30_ADDR | FB_COL31_ADDR,
                                
         frame_timing_data when ROW_LEN_ADDR | NUM_ROWS_ADDR | SAMPLE_DLY_ADDR | SAMPLE_NUM_ADDR | FB_DLY_ADDR | ROW_DLY_ADDR | RESYNC_ADDR |  
                                FLX_LP_INIT_ADDR | FLTR_RST_ADDR | NUM_COLS_REPORTED_ADDR | NUM_ROWS_REPORTED_ADDR,
                                
         id_thermo_data    when CARD_ID_ADDR | CARD_TEMP_ADDR,
         
         fpga_thermo_data  when FPGA_TEMP_ADDR,
         (others => '0')   when others;

   with addr select
      slave_ack <=
         all_cards_ack    when FW_REV_ADDR | SLOT_ID_ADDR | CARD_TYPE_ADDR | SCRATCH_ADDR,
         reset_clr_ack    when CRIT_ERR_RST_ADDR | DEV_CLR_ADDR,         
         led_ack          when LED_ADDR,
         bc_dac_ack       when FLUX_FB_ADDR | BIAS_ADDR | FLUX_FB_UPPER_ADDR | ENBL_MUX_ADDR | ENBL_FLUX_FB_MOD_ADDR | ENBL_BIAS_MOD_ADDR | MOD_VAL_ADDR |BC_NUM_IDLE_ROWS_ADDR|
                               FB_COL0_ADDR | FB_COL1_ADDR | FB_COL2_ADDR | FB_COL3_ADDR | FB_COL4_ADDR | FB_COL5_ADDR | FB_COL6_ADDR | FB_COL7_ADDR | FB_COL8_ADDR | FB_COL9_ADDR |
                               FB_COL10_ADDR | FB_COL11_ADDR | FB_COL12_ADDR | FB_COL13_ADDR | FB_COL14_ADDR | FB_COL15_ADDR | FB_COL16_ADDR | FB_COL17_ADDR | FB_COL18_ADDR | FB_COL19_ADDR |
                               FB_COL20_ADDR | FB_COL21_ADDR | FB_COL22_ADDR | FB_COL23_ADDR | FB_COL24_ADDR | FB_COL25_ADDR | FB_COL26_ADDR | FB_COL27_ADDR | FB_COL28_ADDR | FB_COL29_ADDR |
                               FB_COL30_ADDR | FB_COL31_ADDR,
                               
         frame_timing_ack when ROW_LEN_ADDR | NUM_ROWS_ADDR | SAMPLE_DLY_ADDR | SAMPLE_NUM_ADDR | FB_DLY_ADDR | ROW_DLY_ADDR | RESYNC_ADDR | FLX_LP_INIT_ADDR | FLTR_RST_ADDR | NUM_COLS_REPORTED_ADDR | NUM_ROWS_REPORTED_ADDR,
         id_thermo_ack    when CARD_ID_ADDR | CARD_TEMP_ADDR,
         fpga_thermo_ack  when FPGA_TEMP_ADDR,
         '0'              when others;

   with addr select
      slave_err <=
         '0'              when LED_ADDR | FLUX_FB_ADDR | BIAS_ADDR | FLUX_FB_UPPER_ADDR | ENBL_MUX_ADDR | ENBL_FLUX_FB_MOD_ADDR | ENBL_BIAS_MOD_ADDR | MOD_VAL_ADDR |BC_NUM_IDLE_ROWS_ADDR|
                               FB_COL0_ADDR | FB_COL1_ADDR | FB_COL2_ADDR | FB_COL3_ADDR | FB_COL4_ADDR | FB_COL5_ADDR | FB_COL6_ADDR | FB_COL7_ADDR | FB_COL8_ADDR | FB_COL9_ADDR |
                               FB_COL10_ADDR | FB_COL11_ADDR | FB_COL12_ADDR | FB_COL13_ADDR | FB_COL14_ADDR | FB_COL15_ADDR | FB_COL16_ADDR | FB_COL17_ADDR | FB_COL18_ADDR | FB_COL19_ADDR |
                               FB_COL20_ADDR | FB_COL21_ADDR | FB_COL22_ADDR | FB_COL23_ADDR | FB_COL24_ADDR | FB_COL25_ADDR | FB_COL26_ADDR | FB_COL27_ADDR | FB_COL28_ADDR | FB_COL29_ADDR |
                               FB_COL30_ADDR | FB_COL31_ADDR |                               
                               CRIT_ERR_RST_ADDR | DEV_CLR_ADDR |
                               ROW_LEN_ADDR | NUM_ROWS_ADDR | SAMPLE_DLY_ADDR | SAMPLE_NUM_ADDR | FB_DLY_ADDR | ROW_DLY_ADDR | RESYNC_ADDR | FLX_LP_INIT_ADDR | FLTR_RST_ADDR | NUM_COLS_REPORTED_ADDR | NUM_ROWS_REPORTED_ADDR,
         all_cards_err    when FW_REV_ADDR | SLOT_ID_ADDR | CARD_TYPE_ADDR | SCRATCH_ADDR,
         --reset_clr_err    when CRIT_ERR_RST_ADDR | DEV_CLR_ADDR,         
         id_thermo_err    when CARD_ID_ADDR | CARD_TEMP_ADDR,
         fpga_thermo_err  when FPGA_TEMP_ADDR,
         '1'              when others;

end top;