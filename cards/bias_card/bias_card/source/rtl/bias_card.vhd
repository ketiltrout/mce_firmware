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
-- $Id: bias_card.vhd,v 1.30 2007/12/20 00:39:29 mandana Exp $
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
use sys_param.data_types_pack.all;

library work;
use work.bias_card_pack.all;
use work.all_cards_pack.all;
use work.bc_dac_ctrl_pack.all;

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
      card_id    : inout std_logic;
      smb_clk    : out std_logic;
      smb_nalert : in std_logic;
      smb_data   : inout std_logic;      
      
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
--               RR is the major revision number
--               rr is the minor revision number
--               BBBB is the build number
constant BC_REVISION: std_logic_vector (31 downto 0) := X"01040001"; -- 04 signifies support of FLUX_FB_UPPER_ADDR

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

-- frame_timing interface
signal update_bias : std_logic; 

signal debug       : std_logic_vector (31 downto 0);

begin
   
   -- Active low enable signal for the transmitter on the card.  With '1' it is disabled.
   -- The transmitter is disabled because the Clock Card is driving this line.
   ttl_txena1 <= '1';
   -- The ttl_nrx1 signal is inverted on the Card, thus the FPGA sees an active-high signal.
   rst <= (not rst_n) or (ttl_nrx1);
   
   -- This line will be used by clock card to check card presence
   lvds_txb <= '0';

   mictor   <= debug;
   test (4) <= dac_ncs_temp(0);
   test (6) <= dac_data_temp(0);
   test (8) <= dac_sclk_temp(0);
      
   dac_ncs <= dac_ncs_temp;
   dac_data <= dac_data_temp;
   dac_sclk <= dac_sclk_temp;
   
   pll0: bc_pll
   port map(inclk0 => inclk,
            c0 => clk,
            c1 => comm_clk,
            c2 => clk_n,
            c3 => open);
            
   cmd0: dispatch
      port map(                                                                  
         clk_i                      => clk,
         comm_clk_i                 => comm_clk,
         rst_i                      => rst,         
         
         lvds_cmd_i                 => lvds_cmd,
         lvds_reply_o               => lvds_txa,
     
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
         smbalert_i                 => smb_nalert,
         smbdat_io                  => smb_data);
       

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
   
   ----------------------------------------------------------------------------
   -- all_cards registers Instantition
   ----------------------------------------------------------------------------

    i_all_cards: all_cards
       generic map( REVISION => BC_REVISION, 
                    CARD_TYPE=> BC_CARD_TYPE
                    )
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
          err_all_cards_o  => all_cards_err,
          qa_all_cards_o   => all_cards_data,
          ack_all_cards_o  => all_cards_ack
     );

   bc_dac_ctrl_slave: bc_dac_ctrl
      port map(
         -- DAC hardware interface:
         -- There are 32 DAC channels, thus 32 serial data/cs/clk lines.
         flux_fb_data_o             => dac_data_temp,      
         flux_fb_ncs_o              => dac_ncs_temp,     
         flux_fb_clk_o              => dac_sclk_temp,     
                                       
         bias_data_o                => lvds_dac_data,
         bias_ncs_o                 => lvds_dac_ncs,
         bias_clk_o                 => lvds_dac_sclk,
         
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
         update_bias_i              => update_bias,
         
         -- Global Signals      
         clk_i                      => clk,
         rst_i                      => rst,
         debug                      => debug
      );                         
                                 
   frame_timing_slave: frame_timing
      port map(
         dac_dat_en_o               => open,
         adc_coadd_en_o             => open,
         restart_frame_1row_prev_o  => open,
         restart_frame_aligned_o    => open,
         restart_frame_1row_post_o  => open,
         initialize_window_o        => open,
         
         row_switch_o               => open,
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
   
   with addr select
      slave_data <=
         all_cards_data    when FW_REV_ADDR | SLOT_ID_ADDR | CARD_TYPE_ADDR | SCRATCH_ADDR,     
         led_data          when LED_ADDR,
         bc_dac_data       when FLUX_FB_ADDR | BIAS_ADDR | FLUX_FB_UPPER_ADDR,
         frame_timing_data when ROW_LEN_ADDR | NUM_ROWS_ADDR | SAMPLE_DLY_ADDR | SAMPLE_NUM_ADDR | FB_DLY_ADDR | ROW_DLY_ADDR | RESYNC_ADDR | FLX_LP_INIT_ADDR,
         id_thermo_data    when CARD_ID_ADDR | CARD_TEMP_ADDR,
         fpga_thermo_data  when FPGA_TEMP_ADDR,         
         (others => '0')   when others;

   with addr select
      slave_ack <= 
         all_cards_ack    when FW_REV_ADDR | SLOT_ID_ADDR | CARD_TYPE_ADDR | SCRATCH_ADDR,
         led_ack          when LED_ADDR,
         bc_dac_ack       when FLUX_FB_ADDR | BIAS_ADDR | FLUX_FB_UPPER_ADDR,
         frame_timing_ack when ROW_LEN_ADDR | NUM_ROWS_ADDR | SAMPLE_DLY_ADDR | SAMPLE_NUM_ADDR | FB_DLY_ADDR | ROW_DLY_ADDR | RESYNC_ADDR | FLX_LP_INIT_ADDR,
         id_thermo_ack    when CARD_ID_ADDR | CARD_TEMP_ADDR,
         fpga_thermo_ack  when FPGA_TEMP_ADDR,         
         '0'              when others;
         
   with addr select
      slave_err <= 
         '0'              when LED_ADDR | FLUX_FB_ADDR | BIAS_ADDR | ROW_LEN_ADDR | NUM_ROWS_ADDR | FLUX_FB_UPPER_ADDR | 
                               SAMPLE_DLY_ADDR | SAMPLE_NUM_ADDR | FB_DLY_ADDR | ROW_DLY_ADDR | RESYNC_ADDR | FLX_LP_INIT_ADDR,
         all_cards_err    when FW_REV_ADDR | SLOT_ID_ADDR | CARD_TYPE_ADDR | SCRATCH_ADDR,
         id_thermo_err    when CARD_ID_ADDR | CARD_TEMP_ADDR,
         fpga_thermo_err  when FPGA_TEMP_ADDR,
         '1'              when others;        
   
end top;