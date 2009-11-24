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
--
-- addr_card.vhd
--
-- Project:       SCUBA-2
-- Author:        Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Address card top-level file
--
-- Revision history:
--
-- $Log: addr_card.vhd,v $
-- Revision 1.36  2009/11/19 20:02:17  bburger
-- BB: ac_v05000003
--
-- Revision 1.35  2009/10/16 23:58:38  bburger
-- BB: ac_v05000002_16oct2009
--
-- Revision 1.34  2009/09/14 21:37:32  bburger
-- BB: corrected the clock source from changes made for simulation only.
--
-- Revision 1.33  2009/09/14 20:06:22  bburger
-- BB: v5.0.1 incorporates BIAS_START_ADDR command
--
-- Revision 1.32  2009/03/19 20:19:14  bburger
-- BB:  Added default TTL outputs
--
-- Revision 1.31  2009/01/16 01:27:01  bburger
-- BB:  v05000000 again, due to a signal name change in addr_card.vhd
--
-- Revision 1.30  2008/12/22 20:36:45  bburger
-- BB:  Added a second LVDS reply channel to dispatch
--
-- Revision 1.29  2008/06/17 19:03:20  bburger
-- BB:  Added support for const_val39, for revision ac_v02000007
--
-- Revision 1.29  2008/06/12 21:43:12  bburger
-- BB:  Added support for const_val39, for revision ac_v02000007
--
-- Revision 1.28  2008/05/29 21:19:51  bburger
-- BB:
-- - Added the all_cards slave, which replaces bp_slot_id and fw_rev
-- - Incremented the version number to v02000006
--
-- Revision 1.27  2008/02/22 01:44:48  bburger
-- BB:  Added card not present i/o bit to overall interface.
--
-- Revision 1.26  2008/01/21 19:34:52  bburger
-- BB:
-- - v02000005
-- - Added wishbone support for fb_col0, fb_col1, .., fb_col40
--
-- Revision 1.25  2007/12/18 21:13:27  bburger
-- BB:
-- - moved all the component declarations from addr_card to addr_card_pack
-- - instatiated bp_slot_id
-- - ac_v02000004
--
-- Revision 1.24  2007/03/22 21:14:57  bburger
-- Bryce:  ac_v02000003
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;
use sys_param.data_types_pack.all;

library work;
use work.frame_timing_pack.all;
use work.all_cards_pack.all;

entity addr_card is
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
      dac_data0  : out std_logic_vector(13 downto 0);
      dac_data1  : out std_logic_vector(13 downto 0);
      dac_data2  : out std_logic_vector(13 downto 0);
      dac_data3  : out std_logic_vector(13 downto 0);
      dac_data4  : out std_logic_vector(13 downto 0);
      dac_data5  : out std_logic_vector(13 downto 0);
      dac_data6  : out std_logic_vector(13 downto 0);
      dac_data7  : out std_logic_vector(13 downto 0);
      dac_data8  : out std_logic_vector(13 downto 0);
      dac_data9  : out std_logic_vector(13 downto 0);
      dac_data10 : out std_logic_vector(13 downto 0);
      dac_clk    : out std_logic_vector(40 downto 0);

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
      smb_nalert : out std_logic;
      smb_data   : inout std_logic;

      -- debug ports:
      test       : inout std_logic_vector(16 downto 3);
      mictor     : out std_logic_vector(32 downto 1);
      mictorclk  : out std_logic_vector(2 downto 1);
      rx         : in std_logic;
      tx         : out std_logic
   );
end addr_card;

architecture top of addr_card is

   -- The REVISION format is RRrrBBBB where
   --               RR is the major revision number
   --               rr is the minor revision number
   --               BBBB is the build number
   constant AC_REVISION: std_logic_vector (31 downto 0) := X"05000003";

   -- clocks
   signal clk      : std_logic;
   signal mem_clk  : std_logic;
   signal comm_clk : std_logic;
   signal clk_n    : std_logic;
   signal rst      : std_logic;

   -- wishbone bus (from master)
   signal data      : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal addr      : std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
   signal tga       : std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
   signal we        : std_logic;
   signal stb       : std_logic;
   signal cyc       : std_logic;
   signal slave_err : std_logic;

   -- wishbone bus (from slaves)
   signal slave_data        : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal slave_ack         : std_logic;

   signal led_data          : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal led_ack           : std_logic;

   signal ac_dac_data       : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal ac_dac_ack        : std_logic;

   signal frame_timing_data : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal frame_timing_ack  : std_logic;
   signal fw_rev_err        : std_logic;

   signal fw_rev_data       : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal fw_rev_ack        : std_logic;

   signal id_thermo_data    : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal id_thermo_ack     : std_logic;
   signal id_thermo_err     : std_logic;

   signal fpga_thermo_data  : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal fpga_thermo_ack   : std_logic;
   signal fpga_thermo_err   : std_logic;

   signal slot_id_data      : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal slot_id_ack       : std_logic;
   signal slot_id_err       : std_logic;

   signal all_cards_data    : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal all_cards_ack     : std_logic;
   signal all_cards_err     : std_logic;

   -- frame_timing interface
   signal restart_frame_aligned   : std_logic;
   signal restart_frame_1row_prev : std_logic;
   signal row_switch              : std_logic;
   signal row_en                  : std_logic;
   signal row_count               : std_logic_vector(ROW_COUNT_WIDTH-1 downto 0);
   signal dac_clk_internal        : std_logic_vector(MAX_NUM_OF_ROWS-1 downto 0);

   -- DAC hardware interface:
   signal dac_data : w14_array11;

   component ac_pll
   port(
      inclk0 : in std_logic;
      c0 : out std_logic;
      c1 : out std_logic;
      c2 : out std_logic;
      c3 : out std_logic);
   end component;

   component ac_dac_ctrl is
   port
   (
      -- DAC hardware interface:
      dac_data_o                : out w14_array11;
      dac_clks_o                : out std_logic_vector(NUM_OF_ROWS-1 downto 0);

      -- wishbone interface:
      dat_i                     : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      addr_i                    : in std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
      tga_i                     : in std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
      we_i                      : in std_logic;
      stb_i                     : in std_logic;
      cyc_i                     : in std_logic;
      dat_o                     : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      ack_o                     : out std_logic;

      -- frame_timing interface:
      row_count_i               : in std_logic_vector(ROW_COUNT_WIDTH-1 downto 0);
      row_switch_i              : in std_logic;
      restart_frame_aligned_i   : in std_logic;
      restart_frame_1row_prev_i : in std_logic;
      row_en_i                  : in std_logic;

      -- Global Signals
      clk_i                     : in std_logic;
      clk_i_n                   : in std_logic;
      clk_100_i                 : in std_logic;
      rst_i                     : in std_logic
   );
   end component;

begin

   -- Default assignments to get rid of synthesis warnings.
   ttl_tx1 <= '0';
   ttl_txena2 <= '0';
   ttl_tx2 <= '0';
   ttl_txena3 <= '0';
   ttl_tx3 <= '0';

   -- Active low enable signal for the transmitter on the card.  With '1' it is disabled.
   -- The transmitter is disabled because the Clock Card is driving this line.
   ttl_txena1 <= '1';

   -- The ttl_nrx1 signal is inverted on the Card, thus the FPGA sees an active-high signal.
   rst <= (not rst_n) or (ttl_nrx1);

   -- For simulation; for some reason, the PLL adds an unexpected phase shift between the clk_n and clk.
   --clk_n <= not clk;
   
   pll0: ac_pll
   port map(
      inclk0 => inclk,
      c0 => clk,
      c1 => mem_clk,
      c2 => comm_clk,
      c3 => clk_n
   );

   cmd0: dispatch
   port map(
      clk_i        => clk,
      comm_clk_i   => comm_clk,
      rst_i        => rst,

      lvds_cmd_i   => lvds_cmd,
      lvds_replya_o => lvds_txa,
      lvds_replyb_o => lvds_txb,

      dat_o        => data,
      addr_o       => addr,
      tga_o        => tga,
      we_o         => we,
      stb_o        => stb,
      cyc_o        => cyc,
      dat_i        => slave_data,
      ack_i        => slave_ack,
      err_i        => slave_err,

      wdt_rst_o    => wdog,
      slot_i       => slot_id,

      dip_sw3      => '1',
      dip_sw4      => '1'
   );

   i_all_cards: all_cards
   generic map(
      REVISION        => AC_REVISION,
      CARD_TYPE       => AC_CARD_TYPE)
   port map(
      clk_i           => clk,
      rst_i           => rst,

      dat_i           => data,
      addr_i          => addr,
      tga_i           => tga,
      we_i            => we,
      stb_i           => stb,
      cyc_i           => cyc,
      slot_id_i       => slot_id,
      err_o           => all_cards_err,
      dat_o           => all_cards_data,
      ack_o           => all_cards_ack
   );

   leds_slave: leds
   port map(
      clk_i  => clk,
      rst_i  => rst,

      dat_i  => data,
      addr_i => addr,
      tga_i  => tga,
      we_i   => we,
      stb_i  => stb,
      cyc_i  => cyc,
      dat_o  => led_data,
      ack_o  => led_ack,

      power  => grn_led,
      status => ylw_led,
      fault  => red_led
   );

   ac_dac_ctrl_slave: ac_dac_ctrl
   port map(
      dac_data_o                => dac_data,
      dac_clks_o                => dac_clk,

      dat_i                     => data,
      addr_i                    => addr,
      tga_i                     => tga,
      we_i                      => we,
      stb_i                     => stb,
      cyc_i                     => cyc,
      dat_o                     => ac_dac_data,
      ack_o                     => ac_dac_ack,

      row_count_i               => row_count,
      row_switch_i              => row_switch,
      restart_frame_aligned_i   => restart_frame_aligned,
      restart_frame_1row_prev_i => restart_frame_1row_prev,
      row_en_i                  => row_en,

      clk_i                     => clk,
      clk_i_n                   => clk_n,
      clk_100_i                 => comm_clk,
      rst_i                     => rst
   );

   frame_timing_slave: frame_timing
   port map(
      dac_dat_en_o              => open,
      adc_coadd_en_o            => open,
      restart_frame_1row_prev_o => restart_frame_1row_prev,
      restart_frame_aligned_o   => restart_frame_aligned,
      restart_frame_1row_post_o => open,
      initialize_window_o       => open,

      row_count_o               => row_count,
      row_switch_o              => row_switch,
      row_en_o                  => row_en,

      update_bias_o             => open,

      dat_i                     => data,
      addr_i                    => addr,
      tga_i                     => tga,
      we_i                      => we,
      stb_i                     => stb,
      cyc_i                     => cyc,
      dat_o                     => frame_timing_data,
      ack_o                     => frame_timing_ack,

      clk_i                     => clk,
      clk_n_i                   => clk_n,
      rst_i                     => rst,
      sync_i                    => lvds_sync
   );

   id_thermo0: id_thermo
   port map(
      clk_i   => clk,
      rst_i   => rst,

      -- Wishbone signals
      dat_i   => data,
      addr_i  => addr,
      tga_i   => tga,
      we_i    => we,
      stb_i   => stb,
      cyc_i   => cyc,
      err_o   => id_thermo_err,
      dat_o   => id_thermo_data,
      ack_o   => id_thermo_ack,

      -- silicon id/temperature chip signals
      data_io => card_id
   );

   smb_nalert <= '0';
   fpga_thermo0: fpga_thermo
   port map(
      clk_i      => clk,
      rst_i      => rst,

      -- Wishbone signals
      dat_i      => data,
      addr_i     => addr,
      tga_i      => tga,
      we_i       => we,
      stb_i      => stb,
      cyc_i      => cyc,
      err_o      => fpga_thermo_err,
      dat_o      => fpga_thermo_data,
      ack_o      => fpga_thermo_ack,

      -- FPGA temperature chip signals
      smbclk_o   => smb_clk,
      smbalert_i => '1',
      smbdat_io  => smb_data
   );

   dac_data0  <= dac_data(0);
   dac_data1  <= dac_data(1);
   dac_data2  <= dac_data(2);
   dac_data3  <= dac_data(3);
   dac_data4  <= dac_data(4);
   dac_data5  <= dac_data(5);
   dac_data6  <= dac_data(6);
   dac_data7  <= dac_data(7);
   dac_data8  <= dac_data(8);
   dac_data9  <= dac_data(9);
   dac_data10 <= dac_data(10);

   with addr select
      slave_data <=
         all_cards_data    when FW_REV_ADDR | SLOT_ID_ADDR | CARD_TYPE_ADDR | SCRATCH_ADDR,
         led_data          when LED_ADDR,
         ac_dac_data       when ON_BIAS_ADDR | OFF_BIAS_ADDR | ENBL_MUX_ADDR   | ROW_ORDER_ADDR | CONST_MODE_ADDR | CONST_VAL_ADDR | CONST_VAL39_ADDR |
                                FB_COL0_ADDR | FB_COL1_ADDR | FB_COL2_ADDR | FB_COL3_ADDR | FB_COL4_ADDR | FB_COL5_ADDR | FB_COL6_ADDR | FB_COL7_ADDR | FB_COL8_ADDR | FB_COL9_ADDR |
                                FB_COL10_ADDR | FB_COL11_ADDR | FB_COL12_ADDR | FB_COL13_ADDR | FB_COL14_ADDR | FB_COL15_ADDR | FB_COL16_ADDR | FB_COL17_ADDR | FB_COL18_ADDR | FB_COL19_ADDR |
                                FB_COL20_ADDR | FB_COL21_ADDR | FB_COL22_ADDR | FB_COL23_ADDR | FB_COL24_ADDR | FB_COL25_ADDR | FB_COL26_ADDR | FB_COL27_ADDR | FB_COL28_ADDR | FB_COL29_ADDR |
                                FB_COL30_ADDR | FB_COL31_ADDR | FB_COL32_ADDR | FB_COL33_ADDR | FB_COL34_ADDR | FB_COL35_ADDR | FB_COL36_ADDR | FB_COL37_ADDR | FB_COL38_ADDR | FB_COL39_ADDR |
                                FB_COL40_ADDR | BIAS_START_ADDR | HEATER_BIAS_ADDR | HEATER_BIAS_LEN_ADDR,
         frame_timing_data when ROW_LEN_ADDR | NUM_ROWS_ADDR | SAMPLE_DLY_ADDR | SAMPLE_NUM_ADDR | FB_DLY_ADDR | ROW_DLY_ADDR | RESYNC_ADDR | FLX_LP_INIT_ADDR | FLTR_RST_ADDR | NUM_COLS_REPORTED_ADDR | NUM_ROWS_REPORTED_ADDR,
         id_thermo_data    when CARD_TEMP_ADDR | CARD_ID_ADDR,
         fpga_thermo_data  when FPGA_TEMP_ADDR,
         (others => '0')   when others;

   with addr select
      slave_ack <=
         all_cards_ack     when FW_REV_ADDR | SLOT_ID_ADDR | CARD_TYPE_ADDR | SCRATCH_ADDR,
         led_ack           when LED_ADDR,
         ac_dac_ack        when ON_BIAS_ADDR | OFF_BIAS_ADDR | ENBL_MUX_ADDR   | ROW_ORDER_ADDR | CONST_MODE_ADDR | CONST_VAL_ADDR | CONST_VAL39_ADDR |
                                FB_COL0_ADDR | FB_COL1_ADDR | FB_COL2_ADDR | FB_COL3_ADDR | FB_COL4_ADDR | FB_COL5_ADDR | FB_COL6_ADDR | FB_COL7_ADDR | FB_COL8_ADDR | FB_COL9_ADDR |
                                FB_COL10_ADDR | FB_COL11_ADDR | FB_COL12_ADDR | FB_COL13_ADDR | FB_COL14_ADDR | FB_COL15_ADDR | FB_COL16_ADDR | FB_COL17_ADDR | FB_COL18_ADDR | FB_COL19_ADDR |
                                FB_COL20_ADDR | FB_COL21_ADDR | FB_COL22_ADDR | FB_COL23_ADDR | FB_COL24_ADDR | FB_COL25_ADDR | FB_COL26_ADDR | FB_COL27_ADDR | FB_COL28_ADDR | FB_COL29_ADDR |
                                FB_COL30_ADDR | FB_COL31_ADDR | FB_COL32_ADDR | FB_COL33_ADDR | FB_COL34_ADDR | FB_COL35_ADDR | FB_COL36_ADDR | FB_COL37_ADDR | FB_COL38_ADDR | FB_COL39_ADDR |
                                FB_COL40_ADDR | BIAS_START_ADDR | HEATER_BIAS_ADDR | HEATER_BIAS_LEN_ADDR,
         frame_timing_ack  when ROW_LEN_ADDR | NUM_ROWS_ADDR | SAMPLE_DLY_ADDR | SAMPLE_NUM_ADDR | FB_DLY_ADDR | ROW_DLY_ADDR | RESYNC_ADDR | FLX_LP_INIT_ADDR | FLTR_RST_ADDR | NUM_COLS_REPORTED_ADDR | NUM_ROWS_REPORTED_ADDR,
         id_thermo_ack     when CARD_TEMP_ADDR | CARD_ID_ADDR,
         fpga_thermo_ack   when FPGA_TEMP_ADDR,
         '0'               when others;

   with addr select
      slave_err <=
         '0'               when LED_ADDR | ON_BIAS_ADDR | OFF_BIAS_ADDR | ENBL_MUX_ADDR | ROW_ORDER_ADDR | CONST_MODE_ADDR | CONST_VAL_ADDR | CONST_VAL39_ADDR |
                                ROW_LEN_ADDR | NUM_ROWS_ADDR | SAMPLE_DLY_ADDR | SAMPLE_NUM_ADDR | FB_DLY_ADDR | ROW_DLY_ADDR | RESYNC_ADDR | FLX_LP_INIT_ADDR | FLTR_RST_ADDR | NUM_COLS_REPORTED_ADDR | NUM_ROWS_REPORTED_ADDR |
                                FB_COL0_ADDR | FB_COL1_ADDR | FB_COL2_ADDR | FB_COL3_ADDR | FB_COL4_ADDR | FB_COL5_ADDR | FB_COL6_ADDR | FB_COL7_ADDR | FB_COL8_ADDR | FB_COL9_ADDR |
                                FB_COL10_ADDR | FB_COL11_ADDR | FB_COL12_ADDR | FB_COL13_ADDR | FB_COL14_ADDR | FB_COL15_ADDR | FB_COL16_ADDR | FB_COL17_ADDR | FB_COL18_ADDR | FB_COL19_ADDR |
                                FB_COL20_ADDR | FB_COL21_ADDR | FB_COL22_ADDR | FB_COL23_ADDR | FB_COL24_ADDR | FB_COL25_ADDR | FB_COL26_ADDR | FB_COL27_ADDR | FB_COL28_ADDR | FB_COL29_ADDR |
                                FB_COL30_ADDR | FB_COL31_ADDR | FB_COL32_ADDR | FB_COL33_ADDR | FB_COL34_ADDR | FB_COL35_ADDR | FB_COL36_ADDR | FB_COL37_ADDR | FB_COL38_ADDR | FB_COL39_ADDR |
                                FB_COL40_ADDR | BIAS_START_ADDR | HEATER_BIAS_ADDR | HEATER_BIAS_LEN_ADDR,
         all_cards_err     when FW_REV_ADDR | SLOT_ID_ADDR | CARD_TYPE_ADDR | SCRATCH_ADDR,
         id_thermo_err     when CARD_ID_ADDR | CARD_TEMP_ADDR,
         fpga_thermo_err   when FPGA_TEMP_ADDR,
         '1'               when others;

end top;