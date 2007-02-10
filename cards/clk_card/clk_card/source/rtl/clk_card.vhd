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
-- $Id: clk_card.vhd,v 1.67 2007/02/01 01:48:41 bburger Exp $
--
-- Project:       SCUBA-2
-- Author:        Bryce Burger/ Greg Dennis
-- Organization:  UBC
--
-- Description:
-- Clock card top-level file
--
-- Revision history:
-- $Log: clk_card.vhd,v $
-- Revision 1.67  2007/02/01 01:48:41  bburger
-- Bryce:  removed some unused signals
--
-- Revision 1.66  2007/01/24 01:24:08  bburger
-- Bryce:  Integrated SRAM controller from branch v03000000
--
-- Revision 1.65  2006/12/22 21:58:41  bburger
-- Bryce:  removed unused port
--
-- Revision 1.64  2006/11/22 01:00:16  bburger
-- Bryce:  Interim commital
--
-- Revision 1.63  2006/10/24 17:06:14  bburger
-- Bryce:  removed unused signal from issue_reply interface
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
use work.leds_pack.all;
use work.sync_gen_pack.all;
use work.issue_reply_pack.all;
use work.cc_reset_pack.all;
use work.ret_dat_wbs_pack.all;
use work.frame_timing_pack.all;

entity clk_card is
   port(
      -- Crystal Clock PLL input:
      inclk14           : in std_logic; -- Crystal Clock Input
      rst_n             : in std_logic;

      -- Manchester Clock PLL inputs:
      inclk15           : in std_logic;

      -- LVDS interface:
      lvds_cmd          : out std_logic;
      lvds_sync         : out std_logic;
      lvds_spare        : out std_logic;
      lvds_clk          : out std_logic;
      lvds_reply_ac_a   : in std_logic;
      lvds_reply_ac_b   : in std_logic;
      lvds_reply_bc1_a  : in std_logic;
      lvds_reply_bc1_b  : in std_logic;
      lvds_reply_bc2_a  : in std_logic;
      lvds_reply_bc2_b  : in std_logic;
      lvds_reply_bc3_a  : in std_logic;
      lvds_reply_bc3_b  : in std_logic;
      lvds_reply_rc1_a  : in std_logic;
      lvds_reply_rc1_b  : in std_logic;
      lvds_reply_rc2_a  : in std_logic;
      lvds_reply_rc2_b  : in std_logic;
      lvds_reply_rc3_a  : in std_logic;
      lvds_reply_rc3_b  : in std_logic;
      lvds_reply_rc4_a  : in std_logic;
      lvds_reply_rc4_b  : in std_logic;

      -- DV interface:
      dv_pulse_fibre    : in std_logic;
      manchester_data   : in std_logic;
      manchester_sigdet : in std_logic;

      -- TTL interface:
      ttl_nrx1          : in std_logic;
      ttl_tx1           : out std_logic;
      ttl_txena1        : out std_logic;

      ttl_nrx2          : in std_logic;
      ttl_tx2           : out std_logic;
      ttl_txena2        : out std_logic;

      ttl_nrx3          : in std_logic;
      ttl_tx3           : out std_logic;
      ttl_txena3        : out std_logic;

      -- eeprom interface:
      eeprom_si         : in std_logic;
      eeprom_so         : out std_logic;
      eeprom_sck        : out std_logic;
      eeprom_cs         : out std_logic;

      mosii             : in std_logic;
      sclki             : in std_logic;
      ccssi             : in std_logic;
      misoo             : out std_logic;
      sreqo             : out std_logic;

      -- SRAM bank 0 interface
      sram0_addr : out std_logic_vector(19 downto 0);
      sram0_data : inout std_logic_vector(15 downto 0);
      sram0_nbhe : out std_logic;
      sram0_nble : out std_logic;
      sram0_noe  : out std_logic;
      sram0_nwe  : out std_logic;
      sram0_nce1 : out std_logic;
      sram0_ce2  : out std_logic;

      -- SRAM bank 1 interface
      sram1_addr : out std_logic_vector(19 downto 0);
      sram1_data : inout std_logic_vector(15 downto 0);
      sram1_nbhe : out std_logic;
      sram1_nble : out std_logic;
      sram1_noe  : out std_logic;
      sram1_nwe  : out std_logic;
      sram1_nce1 : out std_logic;
      sram1_ce2  : out std_logic;

      -- miscellaneous ports:
      red_led           : out std_logic;
      ylw_led           : out std_logic;
      grn_led           : out std_logic;
      dip_sw3           : in std_logic;
      dip_sw4           : in std_logic;
      wdog              : out std_logic;
      slot_id           : in std_logic_vector(3 downto 0);
      card_id           : inout std_logic;
      smb_clk           : out std_logic;
      smb_data          : inout std_logic;

      box_id_in         : inout std_logic;
      box_id_out        : out std_logic;
      box_id_ena        : out std_logic;

      -- debug ports:
      mictor0_o         : out std_logic_vector(15 downto 0);
      mictor0clk_o      : out std_logic;
      mictor0_e         : out std_logic_vector(15 downto 0);
      mictor0clk_e      : out std_logic;
      mictor1_o         : out std_logic_vector(15 downto 0);
      mictor1clk_o      : out std_logic;
      mictor1_e         : out std_logic_vector(15 downto 0);
      mictor1clk_e      : out std_logic;

      rx                : in std_logic;
      tx                : out std_logic;

      -- interface to HOTLINK fibre receiver
      fibre_rx_data     : in std_logic_vector (7 downto 0);
      fibre_rx_rdy      : in std_logic;
      fibre_rx_rvs      : in std_logic;
      fibre_rx_status   : in std_logic;
      fibre_rx_sc_nd    : in std_logic;
      fibre_rx_clkr     : in std_logic;
      fibre_rx_refclk   : out std_logic;
      fibre_rx_a_nb     : out std_logic;
      fibre_rx_bisten   : out std_logic;
      fibre_rx_rf       : out std_logic;

      -- interface to hotlink fibre transmitter
      fibre_tx_clkw     : out std_logic;
      fibre_tx_data     : out std_logic_vector (7 downto 0);
      fibre_tx_ena      : out std_logic;
      fibre_tx_sc_nd    : out std_logic;
      fibre_tx_enn      : out std_logic;
      fibre_tx_bisten   : out std_logic;
      fibre_tx_foto     : out std_logic;

      nreconf           : out std_logic;
      nepc_sel          : out std_logic
   );
end clk_card;

architecture top of clk_card is

   -- The REVISION format is RRrrBBBB where
   --               RR is the major revision number
   --               rr is the minor revision number
   --               BBBB is the build number
   constant CC_REVISION: std_logic_vector (31 downto 0) := X"03000002";

   -- reset
   signal rst                : std_logic;
   signal sc_rst             : std_logic;    -- reset signal generated by Linux PC issuing a 'special character' byte down the fibre

   -- clocks
   signal clk                : std_logic;
   signal clk_n              : std_logic;
   signal comm_clk           : std_logic;
   signal fibre_clk          : std_logic;

   -- sync_gen interface
   signal sync_num           : std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);
   signal encoded_sync       : std_logic;
   signal row_len            : integer;
   signal num_rows           : integer;

   -- ret_dat_wbs interface
   signal start_seq_num        : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal stop_seq_num         : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal data_rate            : std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);
   signal data_req             : std_logic;
   signal data_ack             : std_logic;
   signal dv_mode              : std_logic_vector(DV_SELECT_WIDTH-1 downto 0);
   signal external_dv          : std_logic;
   signal external_dv_num      : std_logic_vector(DV_NUM_WIDTH-1 downto 0);
   signal sync_mode            : std_logic_vector(SYNC_SELECT_WIDTH-1 downto 0);
   signal external_sync        : std_logic;
   signal ret_dat_req          : std_logic;
   signal ret_dat_done         : std_logic;
   signal tes_bias_toggle_en   : std_logic;
   signal tes_bias_high        : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal tes_bias_low         : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal tes_bias_toggle_rate : std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);
   signal status_cmd_en        : std_logic;
   signal crc_err_en           : std_logic;

   -- sram_ctrl interface
   signal sram_addr           : std_logic_vector(19 downto 0);
   signal sram_data           : std_logic_vector(31 downto 0);
   signal sram_nbhe           : std_logic;
   signal sram_nble           : std_logic;
   signal sram_noe            : std_logic;
   signal sram_nwe            : std_logic;
   signal sram_nce1           : std_logic;
   signal sram_ce2            : std_logic;

   -- wishbone bus (from master)
   signal data : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal addr : std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
   signal tga  : std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
   signal we   : std_logic;
   signal stb  : std_logic;
   signal cyc  : std_logic;
   constant data_dummy : std_logic_vector(WB_DATA_WIDTH-1 downto 0) := (others => '0');
   constant addr_dummy : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := (others => '0');
   constant tga_dummy  : std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0) := (others => '0');
   constant we_dummy   : std_logic := '0';
   constant stb_dummy  : std_logic := '0';
   constant cyc_dummy  : std_logic := '0';

   -- wishbone bus (from slaves)
   signal slave_err           : std_logic;
   signal slave_data          : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal slave_ack           : std_logic;

   signal led_data            : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal led_ack             : std_logic;
   signal sync_gen_data       : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal sync_gen_ack        : std_logic;
   signal frame_timing_data   : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal frame_timing_ack    : std_logic;
   signal fw_rev_data         : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal fw_rev_ack          : std_logic;
   signal ret_dat_data        : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal ret_dat_ack         : std_logic;
   signal id_thermo_data      : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal id_thermo_ack       : std_logic;
   signal box_id_thermo_data  : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal box_id_thermo_ack   : std_logic;
   signal fpga_thermo_data    : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal fpga_thermo_ack     : std_logic;
   signal config_fpga_data    : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal config_fpga_ack     : std_logic;
   signal select_clk_data     : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal select_clk_ack      : std_logic;
   signal psu_ctrl_data       : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal psu_ctrl_ack        : std_logic;
   signal sram_ctrl_data      : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal sram_ctrl_ack       : std_logic;

   signal fw_rev_err              : std_logic;
   signal id_thermo_err           : std_logic;
   signal box_id_thermo_err       : std_logic;
   signal fpga_thermo_err         : std_logic;

   -- lvds_tx interface
   signal sync       : std_logic;
   signal cmd        : std_logic;

   -- lvds_rx interface
   signal lvds_reply_cc_a     : std_logic;

   -- For testing
   signal debug             : std_logic_vector(31 downto 0);
   signal fib_tx_data       : std_logic_vector (7 downto 0);
   signal fib_tx_ena        : std_logic;
   signal fib_tx_scnd       : std_logic;

   -- The clock being used by the PLL to generate all others.
   -- 0 = crystal clock, 1 = manchester clock
   signal active_clk        : std_logic;

   -- dv_rx interface signals
   signal sync_box_err      : std_logic;
   signal sync_box_free_run : std_logic;

   component sram_ctrl
   port(-- SRAM signals:
        addr_o  : out std_logic_vector(19 downto 0);
        data_bi : inout std_logic_vector(31 downto 0);
        n_ble_o : out std_logic;
        n_bhe_o : out std_logic;
        n_oe_o  : out std_logic;
        n_ce1_o : out std_logic;
        ce2_o   : out std_logic;
        n_we_o  : out std_logic;

        -- wishbone signals:
        clk_i   : in std_logic;
        rst_i   : in std_logic;
        dat_i   : in std_logic_vector (WB_DATA_WIDTH-1 downto 0);
        addr_i  : in std_logic_vector (WB_ADDR_WIDTH-1 downto 0);
        tga_i   : in std_logic_vector (WB_TAG_ADDR_WIDTH-1 downto 0);
        we_i    : in std_logic;
        stb_i   : in std_logic;
        cyc_i   : in std_logic;
        dat_o   : out std_logic_vector (WB_DATA_WIDTH-1 downto 0);
        ack_o   : out std_logic);
   end component;

   component psu_ctrl
   port(
      -- Clock and Reset:
      clk_i         : in std_logic;
      clk_n_i       : in std_logic;
      rst_i         : in std_logic;

      -- Wishbone Interface:
      dat_i         : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      addr_i        : in std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
      tga_i         : in std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
      we_i          : in std_logic;
      stb_i         : in std_logic;
      cyc_i         : in std_logic;
      dat_o         : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      ack_o         : out std_logic;

      ------------------------------
      -- SPI Interface
      ------------------------------
      mosi_i        : in std_logic;   -- Master Output/ Slave Input
      sclk_i        : in std_logic;   -- Serial Clock
      ccss_i        : in std_logic;   -- Clock Card Slave Select
      miso_o        : out std_logic;  -- Master Input/ Slave Output
      sreq_o        : out std_logic   -- Service Request
   );
   end component;

   component config_fpga
   port(
      -- Clock and Reset:
      clk_i         : in std_logic;
      rst_i         : in std_logic;

      -- Wishbone Interface:
      dat_i         : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      addr_i        : in std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
      tga_i         : in std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
      we_i          : in std_logic;
      stb_i         : in std_logic;
      cyc_i         : in std_logic;
      dat_o         : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      ack_o         : out std_logic;

      -- Configuration Interface
      config_n_o    : out std_logic;
      epc16_sel_n_o : out std_logic
   );
   end component;

   component clk_switchover
   port(
      -- wishbone interface:
      dat_i               : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      addr_i              : in std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
      tga_i               : in std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
      we_i                : in std_logic;
      stb_i               : in std_logic;
      cyc_i               : in std_logic;
      dat_o               : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      ack_o               : out std_logic;

      rst_i               : in std_logic;
      xtal_clk_i          : in std_logic; -- Crystal Clock Input
      manch_clk_i         : in std_logic; -- Manchester Clock Input
      active_clk_o        : out std_logic;
      e2_o                : out std_logic;
      c0_o                : out std_logic;
      c1_o                : out std_logic;
      c2_o                : out std_logic;
      c3_o                : out std_logic;
      e0_o                : out std_logic;
      e1_o                : out std_logic
   );
   end component;

   component dispatch
   port(
      clk_i      : in std_logic;
      comm_clk_i : in std_logic;
      rst_i      : in std_logic;

      -- bus backplane interface (LVDS)
      lvds_cmd_i   : in std_logic;
      lvds_reply_o : out std_logic;

      -- wishbone slave interface
      dat_o  : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      addr_o : out std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
      tga_o  : out std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
      we_o   : out std_logic;
      stb_o  : out std_logic;
      cyc_o  : out std_logic;
      dat_i  : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      ack_i  : in std_logic;
      err_i  : in std_logic;

      -- misc. external interface
      wdt_rst_o : out std_logic;
      slot_i    : in std_logic_vector(3 downto 0);
      dip_sw3 : in std_logic;
      dip_sw4 : in std_logic
   );
   end component;

   component fw_rev
   generic(REVISION :std_logic_vector (31 downto 0) := X"01010001");
   port(
      clk_i   : in std_logic;
      rst_i   : in std_logic;

      -- Wishbone signals
      dat_i   : in std_logic_vector (WB_DATA_WIDTH-1 downto 0);
      addr_i  : in std_logic_vector (WB_ADDR_WIDTH-1 downto 0);
      tga_i   : in std_logic_vector (WB_TAG_ADDR_WIDTH-1 downto 0);
      we_i    : in std_logic;
      stb_i   : in std_logic;
      cyc_i   : in std_logic;
      err_o   : out std_logic;
      dat_o   : out std_logic_vector (WB_DATA_WIDTH-1 downto 0);
      ack_o   : out std_logic
   );
   end component;

   component fpga_thermo
   port(
      clk_i : in std_logic;
      rst_i : in std_logic;

      -- wishbone signals
      dat_i   : in std_logic_vector (WB_DATA_WIDTH-1 downto 0);
      addr_i  : in std_logic_vector (WB_ADDR_WIDTH-1 downto 0);
      tga_i   : in std_logic_vector (WB_TAG_ADDR_WIDTH-1 downto 0);
      we_i    : in std_logic;
      stb_i   : in std_logic;
      cyc_i   : in std_logic;
      err_o   : out std_logic;
      dat_o   : out std_logic_vector (WB_DATA_WIDTH-1 downto 0);
      ack_o   : out std_logic;

      -- SMBus temperature sensor signals
      smbclk_o : out std_logic;
      smbdat_io : inout std_logic
   );
   end component;

   component id_thermo
   generic(
      tristate    : string := "INTERNAL";  -- valid values are "INTERNAL" and "EXTERNAL".
      card_or_box : string := "CARD");     -- valid values are "CARD" and "BOX".
   port(
      clk_i : in std_logic;
      rst_i : in std_logic;

      -- Wishbone signals
      dat_i   : in std_logic_vector (WB_DATA_WIDTH-1 downto 0);
      addr_i  : in std_logic_vector (WB_ADDR_WIDTH-1 downto 0);
      tga_i   : in std_logic_vector (WB_TAG_ADDR_WIDTH-1 downto 0);
      we_i    : in std_logic;
      stb_i   : in std_logic;
      cyc_i   : in std_logic;
      err_o   : out std_logic;
      dat_o   : out std_logic_vector (WB_DATA_WIDTH-1 downto 0);
      ack_o   : out std_logic;

      -- silicon id/temperature chip signals
      data_io : inout std_logic;
      data_o  : out std_logic;
      wren_o  : out std_logic
   );
   end component;

   component sync_gen
   port(
      -- Inputs/Outputs
      dv_mode_o            : out std_logic_vector(DV_SELECT_WIDTH-1 downto 0);
      sync_mode_o          : out std_logic_vector(SYNC_SELECT_WIDTH-1 downto 0);
      encoded_sync_o       : out std_logic;
      external_sync_i      : in std_logic;
      row_len_o            : out integer;
      num_rows_o           : out integer;

      -- Wishbone interface
      dat_i                : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      addr_i               : in std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
      tga_i                : in std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
      we_i                 : in std_logic;
      stb_i                : in std_logic;
      cyc_i                : in std_logic;
      dat_o                : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      ack_o                : out std_logic;

      -- Global Signals
      clk_i                : in std_logic;
      rst_i                : in std_logic
   );
   end component;

   component frame_timing is
   port(
      -- Readout Card interface
      dac_dat_en_o               : out std_logic;
      adc_coadd_en_o             : out std_logic;
      restart_frame_1row_prev_o  : out std_logic;
      restart_frame_aligned_o    : out std_logic;
      restart_frame_1row_post_o  : out std_logic;
      initialize_window_o        : out std_logic;
      fltr_rst_o                 : out std_logic;
      sync_num_o                 : out std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);

      -- Address Card interface
      row_switch_o               : out std_logic;
      row_en_o                   : out std_logic;

      -- Bias Card interface
      update_bias_o              : out std_logic;

      -- Wishbone interface
      dat_i                      : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      addr_i                     : in std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
      tga_i                      : in std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
      we_i                       : in std_logic;
      stb_i                      : in std_logic;
      cyc_i                      : in std_logic;
      dat_o                      : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      ack_o                      : out std_logic;

      -- Global signals
      clk_i                      : in std_logic;
      clk_n_i                    : in std_logic;
      rst_i                      : in std_logic;
      sync_i                     : in std_logic
   );
   end component;

   component dv_rx
   port(
      -- Clock and Reset:
      clk_i               : in std_logic;
      clk_n_i             : in std_logic;
      rst_i               : in std_logic;

      -- Fibre Interface:
      manch_det_i         : in std_logic;
      manch_dat_i         : in std_logic;
      dv_dat_i            : in std_logic;

      -- Issue-Reply Interface:
      dv_mode_i           : in std_logic_vector(DV_SELECT_WIDTH-1 downto 0);
      dv_o                : out std_logic;
      dv_sequence_num_o   : out std_logic_vector(DV_NUM_WIDTH-1 downto 0);
      sync_box_err_o      : out std_logic;
      sync_box_free_run_o : out std_logic;

      sync_mode_i         : in std_logic_vector(SYNC_SELECT_WIDTH-1 downto 0);
      sync_o              : out std_logic
   );
   end component;

   component ret_dat_wbs is
   port(
      -- to ret_dat fsm (cmd_translator):
      start_seq_num_o        : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      stop_seq_num_o         : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      data_rate_o            : out std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);
      ret_dat_req_o          : out std_logic;
      ret_dat_ack_i          : in std_logic;
      frame_seq_num_o        : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);

      -- to internal_cmd_fsm (cmd_translator):
      tes_bias_toggle_en_o   : out std_logic;
      tes_bias_high_o        : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      tes_bias_low_o         : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      tes_bias_toggle_rate_o : out std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);
      status_cmd_en_o        : out std_logic;
      crc_err_en_o           : out std_logic;

      -- global interface
      clk_i                  : in std_logic;
      rst_i                  : in std_logic;

      -- wishbone interface:
      dat_i                  : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      addr_i                 : in std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
      tga_i                  : in std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
      we_i                   : in std_logic;
      stb_i                  : in std_logic;
      cyc_i                  : in std_logic;
      dat_o                  : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      ack_o                  : out std_logic
   );
   end component;

   component cc_reset is
   port(
      clk_i        : in  std_logic;
      brst_event_o : out std_logic;
      brst_ack_i   : in  std_logic;
      bclr_event_o : out std_logic;
      bclr_ack_i   : in  std_logic;
      rst_n_i      : in  std_logic; -- rst_n_i is an input to the FPGA that is dependent on the 1.5V level, the 3.3V level and BRst line.
      nRx_rdy_i    : in  std_logic;                     -- hotlink receiver data ready (active low)
      rsc_nRd_i    : in  std_logic;                     -- hotlink receiver special character/(not) Data
      rso_i        : in  std_logic;                     -- hotlink receiver status out
      rvs_i        : in  std_logic;                     -- hotlink receiver violation symbol detected
      rx_data_i    : in  std_logic_vector (7 downto 0); -- hotlink receiver data byte
      reset_o      : out std_logic                      -- cc firmware reset
   );
   end component;

   component issue_reply
   port(
      -- for testing
      debug_o                : out std_logic_vector (31 downto 0);

      -- global signals
      rst_i                  : in std_logic;
      clk_i                  : in std_logic;
      comm_clk_i             : in std_logic;

      -- inputs from the bus backplane
      lvds_reply_ac_a        : in std_logic;
      lvds_reply_bc1_a       : in std_logic;
      lvds_reply_bc2_a       : in std_logic;
      lvds_reply_bc3_a       : in std_logic;
      lvds_reply_rc1_a       : in std_logic;
      lvds_reply_rc2_a       : in std_logic;
      lvds_reply_rc3_a       : in std_logic;
      lvds_reply_rc4_a       : in std_logic;
      lvds_reply_cc_a        : in std_logic;

      -- inputs from the fibre receiver
      fibre_clkr_i           : in std_logic;
      rx_data_i              : in std_logic_vector (7 DOWNTO 0);
      nRx_rdy_i              : in std_logic;
      rvs_i                  : in std_logic;
      rso_i                  : in std_logic;
      rsc_nRd_i              : in std_logic;

      -- interface to fibre transmitter
      tx_data_o              : out std_logic_vector (7 downto 0);      -- byte of data to be transmitted
      tsc_nTd_o              : out std_logic;                          -- hotlink tx special char/ data sel
      nFena_o                : out std_logic;                          -- hotlink tx enable

      -- 25MHz clock for fibre_tx_control
      fibre_clkw_i           : in std_logic;                           -- in phase with 25MHz hotlink clock

      -- lvds_tx interface
      lvds_cmd_o             : out std_logic;                          -- transmitter output pin

      -- ret_dat_wbs interface
      start_seq_num_i        : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      stop_seq_num_i         : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      data_rate_i            : in std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);
      ret_dat_req_i          : in std_logic;
      ret_dat_ack_o          : out std_logic;

      -- sync_gen interface
      dv_mode_i              : in std_logic_vector(DV_SELECT_WIDTH-1 downto 0);
      external_dv_i          : in std_logic;
      external_dv_num_i      : in std_logic_vector(DV_NUM_WIDTH-1 downto 0);

      -- ret_dat_wbs interface
      tes_bias_toggle_en_i   : in std_logic;
      tes_bias_high_i        : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      tes_bias_low_i         : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      tes_bias_toggle_rate_i : in std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);
      status_cmd_en_i        : in std_logic;
      crc_err_en_i           : in std_logic;

      -- clk_switchover interface
      active_clk_i           : in std_logic;

      -- dv_rx interface
      sync_box_err_i         : in std_logic;
      sync_box_free_run_i    : in std_logic;

      -- sync_gen interface
      row_len_i              : in integer;
      num_rows_i             : in integer;
      sync_pulse_i           : in std_logic;
      sync_number_i          : in std_logic_vector (SYNC_NUM_WIDTH-1 downto 0)
   );
   end component;

begin

   -- Debug Signals
   mictor0_o(7 downto 0) <= debug(7 downto 0);
   mictor0_e(7 downto 0) <= fib_tx_data;
   mictor0_e(8)          <= fib_tx_ena;
   mictor0_e(9)          <= fib_tx_scnd;

   -- Fibre TX Signals
   fibre_tx_data   <= fib_tx_data;
   fibre_tx_ena    <= fib_tx_ena;
   fibre_tx_sc_nd  <= fib_tx_scnd;
   fibre_tx_enn    <= '1';
   fibre_tx_bisten <= '1';
   fibre_tx_foto   <= '0';

   -- Fibre RX Signals
   fibre_rx_a_nb   <= '1';
   fibre_rx_bisten <= '1';
   fibre_rx_rf     <= '1';

   -- This is an active-low enable signal for the TTL transmitter.  This line is used as a BClr.
   ttl_txena1 <= '0';

   -- ttl_tx1 is an active-low reset transmitted accross the bus backplane to clear FPGA registers (BClr)
   ttl_tx1    <= not sc_rst;
   rst        <= (not rst_n) or sc_rst;

   with addr select
      slave_data <=
         fw_rev_data        when FW_REV_ADDR,
         led_data           when LED_ADDR,
         sync_gen_data      when USE_DV_ADDR | ROW_LEN_ADDR | NUM_ROWS_ADDR | USE_SYNC_ADDR,
         ret_dat_data       when RET_DAT_S_ADDR | DATA_RATE_ADDR | TES_TGL_EN_ADDR | TES_TGL_MAX_ADDR |
                                 TES_TGL_MIN_ADDR | TES_TGL_RATE_ADDR | INT_CMD_EN_ADDR | CRC_ERR_EN_ADDR,
         id_thermo_data     when CARD_TEMP_ADDR | CARD_ID_ADDR,
--         box_id_thermo_data when BOX_TEMP_ADDR | BOX_ID_ADDR,
         fpga_thermo_data   when FPGA_TEMP_ADDR,
         config_fpga_data   when CONFIG_FAC_ADDR | CONFIG_APP_ADDR,
         select_clk_data    when SELECT_CLK_ADDR,
         psu_ctrl_data      when BRST_MCE_ADDR | CYCLE_POW_ADDR | CUT_POW_ADDR | PSC_STATUS_ADDR,
         sram_ctrl_data     when SRAM_ADDR_ADDR | SRAM_DATA_ADDR,
         (others => '0')    when others;

   with addr select
      slave_ack <=
         fw_rev_ack         when FW_REV_ADDR,
         led_ack            when LED_ADDR,
         sync_gen_ack       when USE_DV_ADDR | ROW_LEN_ADDR | NUM_ROWS_ADDR | USE_SYNC_ADDR,
         ret_dat_ack        when RET_DAT_S_ADDR | DATA_RATE_ADDR | TES_TGL_EN_ADDR | TES_TGL_MAX_ADDR |
                                 TES_TGL_MIN_ADDR | TES_TGL_RATE_ADDR | INT_CMD_EN_ADDR | CRC_ERR_EN_ADDR,
         id_thermo_ack      when CARD_TEMP_ADDR | CARD_ID_ADDR,
--         box_id_thermo_ack  when BOX_TEMP_ADDR | BOX_ID_ADDR,
         fpga_thermo_ack    when FPGA_TEMP_ADDR,
         config_fpga_ack    when CONFIG_FAC_ADDR | CONFIG_APP_ADDR,
         select_clk_ack     when SELECT_CLK_ADDR,
         psu_ctrl_ack       when BRST_MCE_ADDR | CYCLE_POW_ADDR | CUT_POW_ADDR | PSC_STATUS_ADDR,
         sram_ctrl_ack      when SRAM_ADDR_ADDR | SRAM_DATA_ADDR,
         '0'                when others;

   with addr select
      slave_err <=
         '0'                when LED_ADDR | USE_DV_ADDR | ROW_LEN_ADDR | NUM_ROWS_ADDR | USE_SYNC_ADDR | RET_DAT_S_ADDR |
                                 DATA_RATE_ADDR | CONFIG_FAC_ADDR | CONFIG_APP_ADDR |
                                 SELECT_CLK_ADDR | BRST_MCE_ADDR | CYCLE_POW_ADDR | CUT_POW_ADDR | PSC_STATUS_ADDR |
                                 TES_TGL_EN_ADDR | TES_TGL_MAX_ADDR | TES_TGL_MIN_ADDR | TES_TGL_RATE_ADDR | INT_CMD_EN_ADDR | CRC_ERR_EN_ADDR |
                                 SRAM_ADDR_ADDR | SRAM_DATA_ADDR,
         fw_rev_err         when FW_REV_ADDR,
         id_thermo_err      when CARD_ID_ADDR | CARD_TEMP_ADDR,
--         box_id_thermo_err  when BOX_TEMP_ADDR | BOX_ID_ADDR,
         fpga_thermo_err    when FPGA_TEMP_ADDR,
         '1'                when others;

   -- SRAM interface
   sram_ctrl_inst: sram_ctrl
   port map(
        -- SRAM signals:
        addr_o  => sram_addr,
        data_bi(15 downto 0) => sram0_data,
        data_bi(31 downto 16) => sram1_data,
        n_ble_o => sram_nble,
        n_bhe_o => sram_nbhe,
        n_oe_o  => sram_noe,
        n_ce1_o => sram_nce1,
        ce2_o   => sram_ce2,
        n_we_o  => sram_nwe,

        -- wishbone signals:
        clk_i   => clk,
        rst_i   => rst,
        dat_i   => data,
        addr_i  => addr,
        tga_i   => tga,
        we_i    => we,
        stb_i   => stb,
        cyc_i   => cyc,
        dat_o   => sram_ctrl_data,
        ack_o   => sram_ctrl_ack);

   sram0_addr <= sram_addr(19 downto 0);    sram1_addr <= sram_addr(19 downto 0);
--   sram0_data <= sram_data(15 downto 0);    sram1_data <= sram_data(31 downto 16);
   sram0_nbhe <= sram_nbhe;                 sram1_nbhe <= sram_nbhe;
   sram0_nble <= sram_nble;                 sram1_nble <= sram_nble;
   sram0_noe  <= sram_noe;                  sram1_noe  <= sram_noe;
   sram0_nwe  <= sram_nwe;                  sram1_nwe  <= sram_nwe;
   sram0_nce1 <= sram_nce1;                 sram1_nce1 <= sram_nce1;
   sram0_ce2  <= sram_ce2;                  sram1_ce2  <= sram_ce2;

   psu_ctrl_inst: psu_ctrl
   port map(
      -- Clock and Reset:
      clk_i   => clk,
      clk_n_i => clk_n,
      rst_i   => rst,

      -- Wishbone Interface:
      dat_i   => data,
      addr_i  => addr,
      tga_i   => tga,
      we_i    => we,
      stb_i   => stb,
      cyc_i   => cyc,
      dat_o   => psu_ctrl_data,
      ack_o   => psu_ctrl_ack,

      ------------------------------
      -- SPI Interface
      ------------------------------
      mosi_i  => mosii,
      sclk_i  => sclki,
      ccss_i  => ccssi,
      miso_o  => misoo,
      sreq_o  => sreqo
   );

   -- E0 is 180 degrees out of phase with C3 to ensure that the rising edge of fibre_tx_ena occurs at least 5ns before the rising edge of fibre_tx_clkw.
   -- That is a spec-sheet requirement.
   -- This should ensure that there is no metastability.
   clk_switchover_inst: clk_switchover
   port map(
      -- wishbone interface:
      dat_i               => data,
      addr_i              => addr,
      tga_i               => tga,
      we_i                => we,
      stb_i               => stb,
      cyc_i               => cyc,
      dat_o               => select_clk_data,
      ack_o               => select_clk_ack,

      rst_i               => rst,
      xtal_clk_i          => inclk14, -- Crystal Clock Input
      manch_clk_i         => inclk15,  -- Manchester Clock Input
      active_clk_o        => active_clk,
      c0_o                => clk,
      c1_o                => clk_n,
      c2_o                => comm_clk,
      c3_o                => fibre_clk,
      e0_o                => fibre_tx_clkw,  -- 180 degrees out of phase with fibre_clk
      e1_o                => fibre_rx_refclk,
      e2_o                => lvds_clk
   );

   config_fpga_inst: config_fpga
   port map(
      -- Clock and Reset:
      clk_i         => clk,
      rst_i         => rst,

      -- Wishbone Interface:
      dat_i         => data,
      addr_i        => addr,
      tga_i         => tga,
      we_i          => we,
      stb_i         => stb,
      cyc_i         => cyc,
      dat_o         => config_fpga_data,
      ack_o         => config_fpga_ack,

      -- Configuration Interface
      config_n_o    => nreconf,
      epc16_sel_n_o => nepc_sel
   );

   lvds_cmd <= cmd;
   cmd0: dispatch
   port map(
      lvds_cmd_i   => cmd,
      lvds_reply_o => lvds_reply_cc_a,

      --  Global signals
      clk_i        => clk,
      comm_clk_i   => comm_clk,
      rst_i        => rst,

      -- Wishbone interface
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
      dip_sw3      => '1',--dip_sw3,--'1',
      dip_sw4      => '1'--dip_sw4--'1'
   );

   led0: leds
   port map(
      --  Global signals
      clk_i  => clk,
      rst_i  => rst,

      -- Wishbone interface
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

   fw_rev_slave: fw_rev
   generic map( REVISION => CC_REVISION)
   port map(
      clk_i  => clk,
      rst_i  => rst,

      dat_i  => data,
      addr_i => addr,
      tga_i  => tga,
      we_i   => we,
      stb_i  => stb,
      cyc_i  => cyc,
      err_o  => fw_rev_err,
      dat_o  => fw_rev_data,
      ack_o  => fw_rev_ack
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
      data_io => card_id,
      data_o  => open,
      wren_o  => open
   );

--   id_thermo1: id_thermo
--   generic map(
--      tristate => "EXTERNAL",
--      card_or_box => "BOX")
--   port map(
--      clk_i   => clk,
--      rst_i   => rst,
--
--      -- Wishbone signals
--      dat_i   => data,
--      addr_i  => addr,
--      tga_i   => tga,
--      we_i    => we,
--      stb_i   => stb,
--      cyc_i   => cyc,
--      err_o   => box_id_thermo_err,
--      dat_o   => box_id_thermo_data,
--      ack_o   => box_id_thermo_ack,
--
--      -- silicon id/temperature chip signals
--      data_io => box_id_in,
--      data_o  => box_id_out,
--      wren_o  => box_id_ena
--   );


   fpga_thermo0: fpga_thermo
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
      err_o   => fpga_thermo_err,
      dat_o   => fpga_thermo_data,
      ack_o   => fpga_thermo_ack,

      -- FPGA temperature chip signals
      smbclk_o  => smb_clk,
      smbdat_io => smb_data
   );

   lvds_sync <= encoded_sync;

   sync_gen0: sync_gen
   port map(
      -- Inputs/Outputs
      dv_mode_o            => dv_mode,
      sync_mode_o          => sync_mode,
--      sync_mode_o          => open,
      encoded_sync_o       => encoded_sync,
      external_sync_i      => external_sync,
      row_len_o            => row_len,
      num_rows_o           => num_rows,

      -- Wishbone interface
      dat_i                => data,
      addr_i               => addr,
      tga_i                => tga,
      we_i                 => we,
      stb_i                => stb,
      cyc_i                => cyc,
      dat_o                => sync_gen_data,
      ack_o                => sync_gen_ack,

      --  Global signals
      clk_i                => clk,
      rst_i                => rst
   );

   frame_timing_slave: frame_timing
   port map(
      dac_dat_en_o               => open,
      adc_coadd_en_o             => open,
      restart_frame_1row_prev_o  => open,
      restart_frame_aligned_o    => sync,
      restart_frame_1row_post_o  => open,
      initialize_window_o        => open,
      sync_num_o                 => sync_num,

      row_switch_o               => open,
      row_en_o                   => open,

      update_bias_o              => open,

      dat_i                      => data_dummy,
      addr_i                     => addr_dummy,
      tga_i                      => tga_dummy,
      we_i                       => we_dummy,
      stb_i                      => stb_dummy,
      cyc_i                      => cyc_dummy,
      dat_o                      => open,
      ack_o                      => open,

      clk_i                      => clk,
      clk_n_i                    => clk_n,
      rst_i                      => rst,
      sync_i                     => encoded_sync
   );

   dv_rx_inst: dv_rx
   port map(
      -- Clock and Reset:
      clk_i               => clk,
      clk_n_i             => clk_n,
      rst_i               => rst,

      -- Fibre Interface
      manch_det_i         => manchester_sigdet,
      manch_dat_i         => manchester_data,
      dv_dat_i            => dv_pulse_fibre,

      -- Issue-Reply Interface:
      dv_mode_i           => dv_mode,
      dv_o                => external_dv,
      dv_sequence_num_o   => external_dv_num,
      sync_box_err_o      => sync_box_err,
      sync_box_free_run_o => sync_box_free_run,

      sync_mode_i         => sync_mode,
      sync_o              => external_sync
   );

   issue_reply0: issue_reply
   port map(
      -- For testing
      debug_o    => debug,

      -- global signals
      rst_i             => rst,
      clk_i             => clk,
      comm_clk_i        => comm_clk,

      -- bus backplane interface
      lvds_reply_ac_a   => lvds_reply_ac_a,
      lvds_reply_bc1_a  => lvds_reply_bc1_a,
      lvds_reply_bc2_a  => lvds_reply_bc2_a,
      lvds_reply_bc3_a  => lvds_reply_bc3_a,
      lvds_reply_rc1_a  => lvds_reply_rc1_a,
      lvds_reply_rc2_a  => lvds_reply_rc2_a,
      lvds_reply_rc3_a  => lvds_reply_rc3_a,
      lvds_reply_rc4_a  => lvds_reply_rc4_a,
      lvds_reply_cc_a   => lvds_reply_cc_a,

      -- fibre receiver interface
      fibre_clkr_i      => fibre_rx_clkr,
      rx_data_i         => fibre_rx_data,
      nRx_rdy_i         => fibre_rx_rdy,
      rvs_i             => fibre_rx_rvs,
      rso_i             => fibre_rx_status,
      rsc_nRd_i         => fibre_rx_sc_nd,

      -- fibre transmitter interface
      tx_data_o         => fib_tx_data,     -- byte of data to be transmitted
      tsc_nTd_o         => fib_tx_scnd,  -- hotlink tx special char/ data sel
      nFena_o           => fib_tx_ena,      -- hotlink tx enable

      -- 25MHz clock for fibre_tx_control
      fibre_clkw_i      => fibre_clk,

      -- lvds_tx interface
      lvds_cmd_o        => cmd,

      -- ret_dat signals (from ret_dat_wbs)
      start_seq_num_i   => start_seq_num,
      stop_seq_num_i    => stop_seq_num,
      data_rate_i       => data_rate,
      ret_dat_req_i     => ret_dat_req,
      ret_dat_ack_o     => ret_dat_done,

      -- ret_dat signals (from dv_rx)
      dv_mode_i         => dv_mode,
      external_dv_i     => external_dv,
      external_dv_num_i => external_dv_num,

      -- internal command signals (from ret_dat_wbs)
      tes_bias_toggle_en_i   => tes_bias_toggle_en,
      tes_bias_high_i        => tes_bias_high,
      tes_bias_low_i         => tes_bias_low,
      tes_bias_toggle_rate_i => tes_bias_toggle_rate,
      status_cmd_en_i        => status_cmd_en,
      crc_err_en_i           => crc_err_en,

      -- clk_switchover interface
      active_clk_i      => active_clk,

      -- dv_rx interface
      sync_box_err_i      => sync_box_err,
      sync_box_free_run_i => sync_box_free_run,

      -- sync_gen interface
      row_len_i         => row_len,
      num_rows_i        => num_rows,
      sync_pulse_i      => sync,
      sync_number_i     => sync_num
   );

   cc_reset0: cc_reset
   port map (
      clk_i        =>  clk,
      -- These signals will eventually be stored in reply-packet headers
      brst_event_o =>  open,
      brst_ack_i   =>  '1',
      bclr_event_o =>  open,
      bclr_ack_i   =>  '1',
      rst_n_i      =>  rst_n,
      nRx_rdy_i    =>  fibre_rx_rdy,
      rsc_nRd_i    =>  fibre_rx_sc_nd,
      rso_i        =>  fibre_rx_status,
      rvs_i        =>  fibre_rx_rvs,
      rx_data_i    =>  fibre_rx_data,
      reset_o      =>  sc_rst
   );

   ret_dat_param: ret_dat_wbs
   port map
   (
      -- ret_dat command signals (to cmd_translator)
      start_seq_num_o        => start_seq_num,
      stop_seq_num_o         => stop_seq_num,
      data_rate_o            => data_rate,
      ret_dat_req_o          => ret_dat_req,
      ret_dat_ack_i          => ret_dat_done,

      -- internal command signals (to cmd_translator)
      tes_bias_toggle_en_o   => tes_bias_toggle_en,
      tes_bias_high_o        => tes_bias_high,
      tes_bias_low_o         => tes_bias_low,
      tes_bias_toggle_rate_o => tes_bias_toggle_rate,
      status_cmd_en_o        => status_cmd_en,
      crc_err_en_o           => crc_err_en,

      -- global interface
      clk_i                  => clk,
      rst_i                  => rst,

      -- wishbone interface:
      dat_i                  => data,
      addr_i                 => addr,
      tga_i                  => tga,
      we_i                   => we,
      stb_i                  => stb,
      cyc_i                  => cyc,
      dat_o                  => ret_dat_data,
      ack_o                  => ret_dat_ack
   );

end top;