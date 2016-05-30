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
-- $Id: clk_card_pack.vhd,v 1.25 2012-05-16 22:58:46 mandana Exp $
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
-- Revision 1.25  2012-05-16 22:58:46  mandana
-- 5.0.e pcb_rev bits added for Rev. C PCB
-- bugfix: awg now works with the new commanding scheme
--
-- Revision 1.24  2012-03-27 22:58:53  mandana
-- pack file clean up again
--
-- Revision 1.23  2012-02-09 00:19:10  mandana
-- dv_pulse_fibre_i is now reported in bit 9 of the frame-status word of the frame header
-- header version 7
--
-- Revision 1.22  2012-01-06 23:03:19  mandana
-- cosmetic cleanup
--
-- Revision 1.21  2011-12-01 20:52:14  mandana
-- re-organized pack files, moved global definitions from sync_gen and ret_dat_wbs to top level
--
-- Revision 1.20  2010/05/14 22:39:09  bburger
-- BB:  added a dead_card interface to issue_reply for dead_card detection.
--
-- Revision 1.19  2010/02/26 09:32:44  bburger
-- BB: cc_v05000004 -- JTAG support.
--
-- Revision 1.18  2010/01/21 18:48:51  bburger
-- BB: awg_addr interfaces
--
-- Revision 1.17  2010/01/18 20:39:32  bburger
-- BB: Changed "MLS" prefixes to "AWG" for "Abitrary Waveform Generator"
--
-- Revision 1.16  2010/01/13 20:32:10  bburger
-- BB:  Changed constant names from MEM_DAT_WIDTH and MEM_ADDR_WIDTH to MLS_DAT_WIDTH and MLS_ADDR_WIDTH
--
-- Revision 1.15  2010/01/13 20:07:31  bburger
-- BB:  Added stratix_crcblock and d_flipflop declarations, and addes interface signals for the Maximum Length Sequence functionality
--
-- Revision 1.14  2009/01/16 01:48:44  bburger
-- BB: Changed some of the interface signals in sync_gen, ret_dat_wbs, and issue_reply
--
-- Revision 1.13  2008/12/22 20:39:14  bburger
-- BB:  Added interface signals for dual LVDS lines from each card, and for supporting column data from the Readout Cards
--
-- Revision 1.12  2008/10/25 00:24:54  bburger
-- BB:  Added support for RCS_TO_REPORT_DATA command
--
-- Revision 1.11  2008/10/17 00:30:29  bburger
-- BB:  added support for the stop_dly and cards_to_report commands
--
-- Revision 1.10  2008/02/03 09:40:29  bburger
-- BB:
-- - Added interface signals to ret_dat_wbs to support for several new commands:  CARDS_TO_REPORT_ADDR |  CARDS_PRESENT_ADDR | RET_DAT_REQ_ADDR | RCS_TO_REPORT_ADDR
--
-- Revision 1.9  2007/10/18 22:34:37  bburger
-- BB:  Added a manchester pll declaration
--
-- Revision 1.8  2007/10/11 18:35:00  bburger
-- BB:  Rolled dv_rx back from 1.5 to 1.3 because of a bug in the 1.5 code that causes the DV Number (from the sync box) to increment by two, and to spit out garble every few frames.
--
-- Revision 1.7  2007/09/20 19:50:19  bburger
-- BB:  cc_v04000002
--
-- Revision 1.6  2007/08/28 23:31:30  bburger
-- BB: added interface signals to support the following commands:
-- constant NUM_ROWS_TO_READ_ADDR   : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"55";
-- constant INTERNAL_CMD_MODE_ADDR  : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"B0";
-- constant RAMP_STEP_PERIOD_ADDR   : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"B1";
-- constant RAMP_MIN_VAL_ADDR       : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"B2";
-- constant RAMP_STEP_SIZE_ADDR     : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"B3";
-- constant RAMP_MAX_VAL_ADDR       : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"B4";
-- constant RAMP_PARAM_ID_ADDR      : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"B5";
-- constant RAMP_CARD_ADDR_ADDR     : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"B6";
-- constant RAMP_STEP_DATA_NUM_ADDR : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"B7";
--
-- Revision 1.5  2007/07/26 20:28:10  bburger
-- BB:  entity name updates:  subarray_id and backplane_id_thermo
--
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
--use sys_param.data_types_pack.all;

library work;
use work.all_cards_pack.all;
use work.frame_timing_pack.all;

package clk_card_pack is

   constant ARRAY_ID_BITS : integer := 3;
   
   -------------------------------------------------------
   -- Reply Queue and Ret_dat_wbs (!) definitions 
   -------------------------------------------------------
   -- number of cards with dedicated lvds reply lines to CC
   constant NUM_CARDS_TO_REPLY : integer := 10;
   
   -- Offsets in the cards_to_report word
   constant AC   : integer := 9;
   constant BC1  : integer := 8;
   constant BC2  : integer := 7;
   constant BC3  : integer := 6;
   constant RC1  : integer := 5;
   constant RC2  : integer := 4;
   constant RC3  : integer := 3;
   constant RC4  : integer := 2;
   constant CC   : integer := 1;
   constant PSUC : integer := 0;
   
   -- All four RCs are set to report by default
   constant DEFAULT_RCS_TO_REPORT    : std_logic_vector(WB_DATA_WIDTH-1 downto 0) := x"0000003C";
   constant DEFAULT_CARDS_TO_REPORT  : std_logic_vector(WB_DATA_WIDTH-1 downto 0) := x"000003FF";
   constant DEFAULT_STEP_DATA_NUM    : std_logic_vector(WB_DATA_WIDTH-1 downto 0) := x"00000001";  -- Then default number of data words to be send in the ramp command.
   
   constant DEFAULT_DATA_RATE        : std_logic_vector(WB_DATA_WIDTH-1 downto 0) := x"0000002F";  -- 202.71 Hz Based on 41 rows, 120 cycles per row, 20ns per cycle

   -- Arbitrary Wave Generator RAM-size parameters (used in ret_dat_wbs, issue_reply, command translator)
   constant AWG_DAT_WIDTH  : integer := 16;
   constant AWG_ADDR_WIDTH : integer := 13; -- 16,384 values

   -- Internal command mode descriptions   
   constant INTERNAL_CMD_MODE_WIDTH: integer := 2;
   constant NUM_INTERNAL_CMD_MODES : integer := 4;
   constant INTERNAL_OFF           : integer := 0;
   constant INTERNAL_HOUSEKEEPING  : integer := 1;
   constant INTERNAL_RAMP          : integer := 2;
   constant INTERNAL_MEM           : integer := 3;
      
   -------------------------------------------------------
   -- DV-rx and Sync Gen definitions
   -------------------------------------------------------
   -- DV-mode, number of bits
   constant DV_SELECT_WIDTH          : integer := 2;
   -- DV-mode definitions
   constant DV_INTERNAL              : std_logic_vector(DV_SELECT_WIDTH-1 downto 0) := "00";
   constant DV_EXTERNAL_FIBRE        : std_logic_vector(DV_SELECT_WIDTH-1 downto 0) := "01";
   constant DV_EXTERNAL_MANCHESTER   : std_logic_vector(DV_SELECT_WIDTH-1 downto 0) := "10";
 
   constant DV_NUM_WIDTH             : integer := PACKET_WORD_WIDTH;

   -- Sync-mode, number of bits
   constant SYNC_SELECT_WIDTH        : integer := 2;    

   -- Sync Mode definitions
   constant SYNC_INTERNAL            : std_logic_vector(DV_SELECT_WIDTH-1 downto 0) := "00";
   constant SYNC_EXTERNAL_FIBRE      : std_logic_vector(DV_SELECT_WIDTH-1 downto 0) := "01";
   constant SYNC_EXTERNAL_MANCHESTER : std_logic_vector(DV_SELECT_WIDTH-1 downto 0) := "10";

   -------------------------------------------------------
   --
   -- Component Declarations 
   -------------------------------------------------------
   component stratix_crcblock
      generic (
         crc_deld_disable  :  string := "off";
         error_delay :  natural := 0;
         error_dra_dl_bypass  :  string := "off";
         lpm_hint :  string := "UNUSED";
         lpm_type :  string := "stratixiii_crcblock";
         oscillator_divider   :  natural := 2);
      port (
         clk   :  in std_logic := '0';
--         -- This signal is noted as required in an357, but is not present in any library interfaces except stratixiii_components.vhd
         ldsrc :  in std_logic := '0';
         crcerror :  out std_logic;
         regout   :  out std_logic;
         shiftnld :  in std_logic := '0'
      );
   end component;   

   component d_flipflop IS
      PORT (
         clock    : IN STD_LOGIC ;
         data     : IN STD_LOGIC ;
         q     : OUT STD_LOGIC 
      );
   END component;

   component manch_pll
      port (
         inclk0      : IN STD_LOGIC  := '0';
         c0    : OUT STD_LOGIC ;
         locked      : OUT STD_LOGIC
      );
   end component;

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
   -------------------------------------------------------
   -- PSU Control component 
   -------------------------------------------------------
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
   -------------------------------------------------------
   -- Config FPGA component
   -------------------------------------------------------
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

      -- JTAG interface
      fpga_tdo_o    : out std_logic; -- TDO
      fpga_tck_o    : out std_logic; -- TCK
      fpga_tms_o    : out std_logic; -- TMS
      epc_tdo_i     : in std_logic;  -- TDI (into the FPGA)
      jtag_sel_o    : out std_logic; -- JTAG source: '0'=Header, '1'=FGPA
      nbb_jtag_i    : in std_logic;  -- JTAG source:  readback (jtag_sel)

      -- Configuration Interface
--      epc16_sel_n_i : in std_logic;
      config_n_o    : out std_logic;
      epc16_sel_n_o : out std_logic
   );
   end component;
   -------------------------------------------------------   
   -- Clock Switch Over component
   -------------------------------------------------------
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
   
   -- cc_pll for switchover 
   component cc_pll
      port (
         clkswitch      : IN STD_LOGIC  := '0';
         inclk0      : IN STD_LOGIC  := '0';
         inclk1      : IN STD_LOGIC  := '0';
         e2    : OUT STD_LOGIC ;
         c0    : OUT STD_LOGIC ;
         c1    : OUT STD_LOGIC ;
         c2    : OUT STD_LOGIC ;
         c3    : OUT STD_LOGIC ;
         clkloss : out std_logic;
         locked      : OUT STD_LOGIC ;
         activeclock    : OUT STD_LOGIC ;
         e0    : OUT STD_LOGIC ;
         clkbad0     : OUT STD_LOGIC ;
         e1    : OUT STD_LOGIC ;
         clkbad1     : OUT STD_LOGIC
      );
   end component;
   
   -------------------------------------------------------
   -- Sync Generator Component
   -------------------------------------------------------
   component sync_gen
   port(
      -- Inputs/Outputs
      dv_mode_o            : out std_logic_vector(DV_SELECT_WIDTH-1 downto 0);
      sync_mode_o          : out std_logic_vector(SYNC_SELECT_WIDTH-1 downto 0);
      encoded_sync_o       : out std_logic;
      external_sync_i      : in std_logic;
      row_len_i            : in integer;
      num_rows_i           : in integer;

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
   -------------------------------------------------------
   -- dv Receive component
   -------------------------------------------------------
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
      sync_box_err_ack_i  : in std_logic;
      sync_box_free_run_o : out std_logic;

      sync_mode_i         : in std_logic_vector(SYNC_SELECT_WIDTH-1 downto 0);
      sync_o              : out std_logic
   );
   end component;
   -------------------------------------------------------
   -- ret_dat_wbs component
   -------------------------------------------------------
   component ret_dat_wbs is
   port(
      -- global interface
      clk_i                  : in std_logic;
      rst_i                  : in std_logic;
      
      -- to issue_reply:
      start_seq_num_o        : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      stop_seq_num_o         : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      data_rate_o            : out std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);
      internal_cmd_mode_o    : out std_logic_vector(INTERNAL_CMD_MODE_WIDTH-1 downto 0);
      step_period_o          : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      step_minimum_o         : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      step_size_o            : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      step_maximum_o         : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      step_param_id_o        : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      step_card_addr_o       : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      step_data_num_o        : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      step_phase_o           : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);      
      run_file_id_o          : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      user_writable_o        : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      stop_delay_o           : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      crc_err_en_o           : out std_logic;
      cards_present_i        : in std_logic_vector(NUM_CARDS_TO_REPLY-1 downto 0);
      cards_to_report_o      : out std_logic_vector(NUM_CARDS_TO_REPLY-1 downto 0);
      rcs_to_report_data_o   : out std_logic_vector(NUM_CARDS_TO_REPLY-1 downto 0);
      ret_dat_req_o          : out std_logic;
      ret_dat_ack_i          : in std_logic;
      awg_dat_o              : out std_logic_vector(AWG_DAT_WIDTH-1 downto 0);
      awg_addr_o             : out std_logic_vector(AWG_ADDR_WIDTH-1 downto 0);
      awg_addr_incr_i        : in std_logic;
      awg_addr_clr_i         : in std_logic;

      -- wishbone interface:
      dat_i                  : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      addr_i                 : in std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
      tga_i                  : in std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
      we_i                   : in std_logic;
      stb_i                  : in std_logic;
      cyc_i                  : in std_logic;
      err_o                  : out std_logic;
      dat_o                  : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      ack_o                  : out std_logic
   );
   end component;
   -------------------------------------------------------
   -- Arbitrary Wave Generator (AWG) RAM block component (instantiated in ret_dat_wbs)
   -------------------------------------------------------

   component awg_data_bank IS
      PORT
      (
         clock    : IN STD_LOGIC  := '1';
         data     : IN STD_LOGIC_VECTOR (AWG_DAT_WIDTH-1 DOWNTO 0);
         rdaddress      : IN STD_LOGIC_VECTOR (AWG_ADDR_WIDTH-1 DOWNTO 0);
         wraddress      : IN STD_LOGIC_VECTOR (AWG_ADDR_WIDTH-1 DOWNTO 0);
         wren     : IN STD_LOGIC  := '0';
         q     : OUT STD_LOGIC_VECTOR (AWG_DAT_WIDTH-1 DOWNTO 0)
      );
   END component;
   -------------------------------------------------------
   -- Clock Card Reset component
   -------------------------------------------------------   
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
   -------------------------------------------------------
   -- Issue Reply Component
   -------------------------------------------------------

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
      lvds_reply_all_a_i     : in std_logic_vector(NUM_CARDS_TO_REPLY-1 downto 0);
      lvds_reply_all_b_i     : in std_logic_vector(NUM_CARDS_TO_REPLY-1 downto 0);

      card_not_present_o     : out std_logic_vector(NUM_CARDS_TO_REPLY-1 downto 0);

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
      run_file_id_i          : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
      user_writable_i        : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
      stop_delay_i           : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
      internal_cmd_mode_i    : in std_logic_vector(INTERNAL_CMD_MODE_WIDTH-1 downto 0);
      step_period_i          : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      step_minimum_i         : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      step_size_i            : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      step_maximum_i         : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      step_param_id_i        : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      step_card_addr_i       : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      step_data_num_i        : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      step_phase_i           : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      crc_err_en_i           : in std_logic;
      num_rows_to_read_i     : in integer;
      num_cols_to_read_i     : in integer;
      cards_to_report_i      : in std_logic_vector(NUM_CARDS_TO_REPLY-1 downto 0);
      rcs_to_report_data_i   : in std_logic_vector(NUM_CARDS_TO_REPLY-1 downto 0);
      awg_dat_i              : in std_logic_vector(AWG_DAT_WIDTH-1 downto 0);
      awg_addr_i             : in std_logic_vector(AWG_ADDR_WIDTH-1 downto 0);
      awg_addr_incr_o        : out std_logic;
      awg_addr_clr_o         : out std_logic;
      dead_card_i            : in std_logic;

      -- clk_switchover interface
      active_clk_i           : in std_logic;

      -- cc_reset interface
      reset_event_i          : in std_logic;
      reset_ack_o            : out std_logic;

      -- dv_rx interface
      sync_box_err_i         : in std_logic;
      sync_box_err_ack_o     : out std_logic;
      sync_box_free_run_i    : in std_logic;
      external_dv_i          : in std_logic;
      external_dv_num_i      : in std_logic_vector(DV_NUM_WIDTH-1 downto 0);
      
      -- non-manchester encoded fibre input to be encoded in the frame header
      dv_pulse_fibre_i       : in std_logic;

      -- sync_gen interface
      dv_mode_i              : in std_logic_vector(DV_SELECT_WIDTH-1 downto 0);
      row_len_i              : in integer;
      num_rows_i             : in integer;

      -- frame_timing interface
      sync_pulse_i           : in std_logic; -- or restart_frame_aligned
      sync_number_i          : in std_logic_vector (SYNC_NUM_WIDTH-1 downto 0)
   );
   end component;

end clk_card_pack;
