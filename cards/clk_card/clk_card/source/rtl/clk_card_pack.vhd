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
-- $Id: clk_card_pack.vhd,v 1.4 2007/07/25 19:00:50 bburger Exp $
--
-- Project:       SCUBA-2
-- Author:        Bryce Burger
-- Organization:  UBC
--
-- Description:
--
--
-- Revision history:
-- $Log: clk_card_pack.vhd,v $
-- Revision 1.4  2007/07/25 19:00:50  bburger
-- BB:  Moved all the slave declarations that were in clk_card to clk_card_pack
--
-- Revision 1.3  2005/01/19 23:39:06  bburger
-- Bryce:  Fixed a couple of errors with the special-character clear.  Always compile, simulate before comitting.
--
-- Revision 1.2  2004/12/08 22:15:12  bburger
-- Bryce:  changed the usage of PLLs in the top levels of clk and addr cards
--
-- Revision 1.1  2004/11/30 23:07:53  bburger
-- Bryce:  testing the Clock Card top-level
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
use work.all_cards_pack.all;
use work.sync_gen_pack.all;
use work.issue_reply_pack.all;
use work.cc_reset_pack.all;
use work.ret_dat_wbs_pack.all;
use work.frame_timing_pack.all;

package clk_card_pack is

   constant ARRAY_ID_BITS : integer := 3;

   component subarray_id
   port (
      clk_i   : in std_logic;
      rst_i   : in std_logic;

      array_id_i : in std_logic_vector(ARRAY_ID_BITS-1 downto 0);

      -- wishbone signals
      dat_i   : in std_logic_vector(WB_DATA_WIDTH-1 downto 0); -- not used since not writing to array ID
      addr_i  : in std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
      tga_i   : in std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
      we_i    : in std_logic;
      stb_i   : in std_logic;
      cyc_i   : in std_logic;
      err_o   : out std_logic;
      dat_o   : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      ack_o   : out std_logic);
   end component;

   component backplane_id_thermo
   port(
      clk_i   : in std_logic;
      rst_i   : in std_logic;

      -- Wishbone signals
      dat_i   : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      addr_i  : in std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
      tga_i   : in std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
      we_i    : in std_logic;
      stb_i   : in std_logic;
      cyc_i   : in std_logic;
      err_o   : out std_logic;
      dat_o   : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      ack_o   : out std_logic;

      data_i  : in std_logic;
      data_o  : out std_logic;
      wren_n_o  : out std_logic);
   end component;

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
      err_o         : out std_logic;

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

   component dv_rx
   port(
      -- Clock and Reset:
      clk_i               : in std_logic;
      manch_clk_i         : in std_logic;
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
      clk_i            : in  std_logic;
      fibre_clkr_i     : in std_logic;

      -- Header Signals
      brst_event_o     : out std_logic;
      brst_ack_i       : in  std_logic;
      mce_bclr_event_o : out std_logic;
      mce_bclr_ack_i   : in  std_logic;
      cc_bclr_event_o  : out std_logic;
      cc_bclr_ack_i    : in  std_logic;

      -- Fibre Signals
      nRx_rdy_i        : in  std_logic;                     -- hotlink receiver data ready (active low)
      rsc_nRd_i        : in  std_logic;                     -- hotlink receiver special character/(not) Data
      rso_i            : in  std_logic;                     -- hotlink receiver status out
      rvs_i            : in  std_logic;                     -- hotlink receiver violation symbol detected
      rx_data_i        : in  std_logic_vector (7 downto 0); -- hotlink receiver data byte

      -- Register Clear Signals
      ext_rst_n_i      : in std_logic;
      cc_bclr_o        : out std_logic;
      mce_bclr_o       : out std_logic;

      -- Wishbone Interface:
      dat_i            : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      addr_i           : in std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
      tga_i            : in std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
      we_i             : in std_logic;
      stb_i            : in std_logic;
      cyc_i            : in std_logic;
      dat_o            : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      ack_o            : out std_logic
   );
   end component;

   component issue_reply
   port(
      -- for testing
      debug_o                : out std_logic_vector (31 downto 0);

      -- global signals
      rst_i                  : in std_logic;
      clk_i                  : in std_logic;
      clk_n_i                : in std_logic;
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
      lvds_reply_psu_a       : in std_logic;

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

      -- cc_reset interface
      reset_event_i          : in std_logic;
      reset_ack_o            : out std_logic;

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

end clk_card_pack;
