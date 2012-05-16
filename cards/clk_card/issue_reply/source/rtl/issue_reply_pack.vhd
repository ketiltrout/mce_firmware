-- Copyright (c) 2003 SCUBA-2 Project
--               All Rights Reserved
--
-- THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF THE SCUBA-2 Project
-- The copyright notice above does not evidence any
-- actual or intended publication of such source code.
--
-- SOURCE CODE IS PROVIDED "AS IS". ALL EXPRESS OR IMPLIED CONDITIONS,
-- REPRESENTATIONS, AND WARRANTIES, INCLUDING ANY IMPLIED WARRANT OF
-- MERCHANTABILITY, SATISFACTORY QUALITY, FITNESS FOR A PARTICULAR
-- PURPOSE, OR NON-INFRINGEMENT, ARE DISCLAIMED, EXCEPT TO THE EXTENT
-- THAT SUCH DISCLAIMERS ARE HELD TO BE LEGALLY INVALID.
--
-- For the purposes of this code the SCUBA-2 Project consists of the
-- following organisations.
--
-- UKATC, Royal Observatory, Blackford Hill Edinburgh EH9 3HJ
-- UBC,   University of British Columbia, Physics & Astronomy Department,
--        Vancouver BC, V6T 1Z1
--
-- $Id: issue_reply_pack.vhd,v 1.63 2012-05-14 19:55:40 mandana Exp $
--
-- Project:    SCUBA2
-- Author:     Greg Dennis
-- Organization:  UBC
--
-- Description:
-- Declares a few constants used as parameters in the fibre_rx block
--
-- Revision history:
-- $Log: issue_reply_pack.vhd,v $
-- Revision 1.63  2012-05-14 19:55:40  mandana
-- step_value removed from cmd_q interface. This is only passed to reply translator to be assembled as part of the header.
--
-- Revision 1.62  2012-02-09 00:19:10  mandana
-- dv_pulse_fibre_i is now reported in bit 9 of the frame-status word of the frame header
-- header version 7
--
-- Revision 1.61  2012-01-06 23:09:16  mandana
-- parametrized interface definitions
-- moved all frame-header defines here
-- added step_phase, revived busy_i to the interface
--
-- Revision 1.60  2011-12-01 19:46:11  mandana
-- re-organized pack files
--
-- Revision 1.59  2011-11-30 22:06:05  mandana
-- re-organized pack files in hierarchical manner and moved all component declarations into pack files
--
-- Revision 1.58  2010/01/21 19:44:52  bburger
-- BB: Added a comment.
--
-- Revision 1.57  2008/10/17 00:32:50  bburger
-- BB:  added indexing constants.
--
-- Revision 1.56  2008/01/28 20:27:24  bburger
-- BB:
-- - moved the constant called STATUS_WORD_WARNING_MASK from issue_reply_pack to reply_translator, where it is used locally
--
-- Revision 1.55  2007/10/18 22:38:43  bburger
-- BB:  added a parameter that characterizes the data propagation delay of the data pipeline from reply_queue_receive to reply_translator.  This will help make adjustments more quickly in the future.
--
-- Revision 1.54  2007/08/28 23:22:08  bburger
-- BB:  Renamed INTERNAL_COMMAND_PERIOD to HOUSEKEEPING_COMMAND_PERIOD
--
-- Revision 1.53  2007/07/24 22:55:44  bburger
-- BB:
-- - Updated the constants in this file to be consistent with the new protocol, to fix bugs, to suport internal commands and to implement a warning mask.
--
-- Revision 1.52  2006/11/07 23:50:18  bburger
-- Bryce:  modified some of the constants
--
-- Revision 1.51  2006/10/28 00:06:46  bburger
-- Bryce:  Changed the command timeout limits
--
-- Revision 1.50  2006/10/19 22:19:32  bburger
-- Bryce:  Interim committal
--
-- Revision 1.49  2006/09/28 00:32:25  bburger
-- Bryce:  Caught a bug that specified the TES_BIAS_DATA_SIZE = 32.
--
-- Revision 1.48  2006/09/26 02:16:05  bburger
-- Bryce: added busy_i interface for arbitration between ret_dat, internal and simple commands
--
-- Revision 1.47  2006/09/21 16:15:16  bburger
-- Bryce:  added constants for internal commands
--
-- Revision 1.46  2006/09/15 00:36:11  bburger
-- Bryce:  Added internal_cmd_window between ret_dat_fsm and arbiter_fsm
--
-- Revision 1.45  2006/03/16 00:21:28  bburger
-- Bryce:  removed the issue_reply component declaration
--
-- Revision 1.44  2006/03/09 01:04:37  bburger
-- Bryce:
-- - cmd_translator interface now takes the following signals:  dv_mode_i, external_dv_i, external_dv_num_i
-- - cmd_queue communicates the issue_sync to reply_queue
--
-- Revision 1.43  2006/02/11 01:19:33  bburger
-- Bryce:  Added the following signal interfaces to implement responding to external dv pulses
-- data_req
-- data_ack
-- frame_num_external
--
-- Revision 1.42  2006/01/16 18:58:05  bburger
-- Ernie:
-- Added component declarations
-- Updated the interfaces to issue_reply sub-blocks
--
-- Revision 1.41  2005/03/19 00:31:23  bburger
-- bryce:  Fixed several bugs.  Tagging cc_01010007.
--
-- Revision 1.40  2005/03/16 02:20:58  bburger
-- bryce:  removed mem_clk from the cmd_queue and sync_gen blocks
--
-- Revision 1.39  2005/03/04 03:45:58  bburger
-- Bryce:  fixed bugs associated with ret_dat_s and ret_dat
--
-- Revision 1.38  2005/01/12 22:18:24  mandana
-- added comm_clk_i (shouldn't have removed it!)
--
-- Revision 1.37  2005/01/12 21:53:01  mandana
-- Updated cmd_queue interface by deleting comm_clk_i
--
-- Revision 1.36  2004/11/30 22:58:47  bburger
-- Bryce:  reply_queue integration
--
-- Revision 1.35  2004/11/24 01:15:52  bench2
-- Greg: Broke apart issue reply and created pack files for all of its sub-components
--
--
--
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;

library work;
use work.frame_timing_pack.all;

-- Call Parent Library
use work.clk_card_pack.all;

package issue_reply_pack is

   -- cmd_queue_ram defines
   constant QUEUE_LEN        : integer := 256; -- The u-op queue is 256 entries long
   constant QUEUE_WIDTH      : integer :=  32;
   constant QUEUE_ADDR_WIDTH : integer :=   8;
   constant BB_NUM_CMD_HEADER_WORDS : integer := 2; -- cleanup at a later time

   -- Measured in clock cycles, CMD_TIMEOUT_LIMIT is slightly more than the amount of cycles necessary for an internal/ simple command to execute
   -- For a 58-word WB command, 100 us are required from receiving the last word of the command to sending the last word of the reply
   -- For a 58-word RB command, 105 us are required from receiving the last word of the command to sending the last word of the reply.
   constant CMD_TIMEOUT_LIMIT : integer := 150; --us

   -- This should be dependent on row_len and num_rows!
   constant DATA_TIMEOUT_LIMIT : integer := 1000; --us

   -- The minimum window for transmitting an internal command needs to be slightly more than CMD_TIMEOUT_LIMIT
   -- To account for the time needed to prime the cmd_translator
   constant MIN_WINDOW : integer := (CMD_TIMEOUT_LIMIT+5)*1000/20; -- # clock cycles = (110us+5us)*1000/20ns = 5750;

   -- Period of internal commands
   constant HOUSEKEEPING_COMMAND_PERIOD : integer := 1000000; -- in us

   -- Data sizes for internal commands
   constant TES_BIAS_DATA_SIZE   : std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0) := "00000000001"; --  1 word
   constant FPGA_TEMP_DATA_SIZE  : std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0) := "00000000001"; --  1 word
   constant CARD_TEMP_DATA_SIZE  : std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0) := "00000000001"; --  1 word
   constant PSC_STATUS_DATA_SIZE : std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0) := "00000001001"; --  9 words
   constant BOX_TEMP_DATA_SIZE   : std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0) := "00000000001"; --  1 word

   -- number of frame header words stored in RAM
   constant DATA_PACKET_HEADER_REVISION: std_logic_vector (PACKET_WORD_WIDTH-1 downto 0) := X"00000007";
   constant NUM_RAM_HEAD_WORDS  : integer := 43;
   constant RAM_HEAD_ADDR_WIDTH : integer :=  6;

   constant FPGA_TEMP_COUNT  : integer := 10; -- Includes space for fpga_temp errno word
   constant CARD_TEMP_COUNT  : integer := 10; -- Includes space for fpga_temp errno word
   constant PSC_STATUS_COUNT : integer :=  8; -- Includes space for card_temp errno word
   constant BOX_TEMP_COUNT   : integer :=  2; -- Includes space for fpga_temp errno word

   -- Memory Map for the header information RAM, version 6+
   constant FPGA_TEMP_OFFSET   : integer := 0;
   constant CARD_TEMP_OFFSET   : integer := FPGA_TEMP_COUNT;
   constant PSC_STATUS_OFFSET  : integer := FPGA_TEMP_COUNT + CARD_TEMP_COUNT;
   constant BOX_TEMP_OFFSET    : integer := FPGA_TEMP_COUNT + CARD_TEMP_COUNT + PSC_STATUS_COUNT;
    
   constant FPGA_TEMP_ADDR_AC  : std_logic_vector(RAM_HEAD_ADDR_WIDTH-1 downto 0) := "000001";
   constant FPGA_TEMP_ADDR_BC1 : std_logic_vector(RAM_HEAD_ADDR_WIDTH-1 downto 0) := "000010";
   constant FPGA_TEMP_ADDR_BC2 : std_logic_vector(RAM_HEAD_ADDR_WIDTH-1 downto 0) := "000011";
   constant FPGA_TEMP_ADDR_BC3 : std_logic_vector(RAM_HEAD_ADDR_WIDTH-1 downto 0) := "000100";
   constant FPGA_TEMP_ADDR_RC1 : std_logic_vector(RAM_HEAD_ADDR_WIDTH-1 downto 0) := "000101";
   constant FPGA_TEMP_ADDR_RC2 : std_logic_vector(RAM_HEAD_ADDR_WIDTH-1 downto 0) := "000110";
   constant FPGA_TEMP_ADDR_RC3 : std_logic_vector(RAM_HEAD_ADDR_WIDTH-1 downto 0) := "000111";
   constant FPGA_TEMP_ADDR_RC4 : std_logic_vector(RAM_HEAD_ADDR_WIDTH-1 downto 0) := "001000";
   constant FPGA_TEMP_ADDR_CC  : std_logic_vector(RAM_HEAD_ADDR_WIDTH-1 downto 0) := "001001";

   constant CARD_TEMP_ADDR_AC  : std_logic_vector(RAM_HEAD_ADDR_WIDTH-1 downto 0) := "001011";
   constant CARD_TEMP_ADDR_BC1 : std_logic_vector(RAM_HEAD_ADDR_WIDTH-1 downto 0) := "001100";
   constant CARD_TEMP_ADDR_BC2 : std_logic_vector(RAM_HEAD_ADDR_WIDTH-1 downto 0) := "001101";
   constant CARD_TEMP_ADDR_BC3 : std_logic_vector(RAM_HEAD_ADDR_WIDTH-1 downto 0) := "001110";
   constant CARD_TEMP_ADDR_RC1 : std_logic_vector(RAM_HEAD_ADDR_WIDTH-1 downto 0) := "001111";
   constant CARD_TEMP_ADDR_RC2 : std_logic_vector(RAM_HEAD_ADDR_WIDTH-1 downto 0) := "010000";
   constant CARD_TEMP_ADDR_RC3 : std_logic_vector(RAM_HEAD_ADDR_WIDTH-1 downto 0) := "010001";
   constant CARD_TEMP_ADDR_RC4 : std_logic_vector(RAM_HEAD_ADDR_WIDTH-1 downto 0) := "010010";
   constant CARD_TEMP_ADDR_CC  : std_logic_vector(RAM_HEAD_ADDR_WIDTH-1 downto 0) := "010011";

   -- This is the data pipeline propagation delay setting for the reply_translator
   constant DATA_PROPAGATION_DELAY : integer := 3;

   -----------------------------------------------------------------------------
   -- Fibre Recieve component
   -----------------------------------------------------------------------------
   component fibre_rx
   port(
      sbr_o          : out std_logic;

      clk_i          : in std_logic;
      rst_i          : in std_logic;

      cmd_err_o      : out std_logic;
      cmd_rdy_o      : out std_logic;
      cmd_ack_i      : in std_logic;
      rt_cmd_rdy_o   : out std_logic;
      rdy_for_data_i : in std_logic;

      cmd_code_o     : out std_logic_vector (FIBRE_PACKET_TYPE_WIDTH-1 downto 0);
      card_addr_o    : out std_logic_vector (FIBRE_CARD_ADDRESS_WIDTH-1 downto 0);
      param_id_o     : out std_logic_vector (FIBRE_PARAMETER_ID_WIDTH-1 downto 0);
      dat_size_o     : out std_logic_vector (FIBRE_DATA_SIZE_WIDTH-1 downto 0);
      dat_clk_o      : out std_logic;
      dat_o          : out std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);

      fibre_clkr_i   : in std_logic;
      fibre_data_i   : in std_logic_vector (7 downto 0);
      fibre_nrdy_i   : in std_logic;
      fibre_rvs_i    : in std_logic;
      fibre_rso_i    : in std_logic;
      fibre_sc_nd_i  : in std_logic
   );
   end component;
   -----------------------------------------------------------------------------
   -- Fibre Transmit component      
   -----------------------------------------------------------------------------
   component fibre_tx
   port(
      -- global signals
      clk_i  : in std_logic;
      rst_i  : in std_logic;

      -- interface to reply_translator
      dat_i  : in std_logic_vector(31 downto 0);        
      rdy_i  : in std_logic;
      busy_o : out std_logic;
      
      -- interface to HOTLINK transmitter
      fibre_clk_i   : in std_logic;                     -- 25MHz hotlink clock
      fibre_data_o  : out std_logic_vector(7 downto 0); -- byte of data to be transmitted
      fibre_sc_nd_o : out std_logic;                    -- hotlink tx special char/ data sel
      fibre_nena_o  : out std_logic                     -- hotlink tx enable
   );
   end component;

   -----------------------------------------------------------------------------
   -- Command Translator component
   -----------------------------------------------------------------------------
   component cmd_translator
   port(
      -- global inputs
      rst_i                 : in  std_logic;
      clk_i                 : in  std_logic;

      -- fibre_rx interface
      card_addr_i           : in  std_logic_vector(FIBRE_CARD_ADDRESS_WIDTH-1 downto 0);
      cmd_code_i            : in  std_logic_vector(FIBRE_PACKET_TYPE_WIDTH-1 downto 0);
      cmd_data_i            : in  std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
      cmd_rdy_i             : in  std_logic;
      data_clk_i            : in  std_logic;
      num_data_i            : in  std_logic_vector(FIBRE_DATA_SIZE_WIDTH-1 downto 0);
      param_id_i            : in  std_logic_vector(FIBRE_PARAMETER_ID_WIDTH-1 downto 0);
      -- output to fibre_rx
      ack_o                 : out std_logic;

      -- ret_dat_wbs interface:
      start_seq_num_i       : in  std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
      stop_seq_num_i        : in  std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
      data_rate_i           : in  std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);
      dv_mode_i             : in std_logic_vector(DV_SELECT_WIDTH-1 downto 0);
      external_dv_i         : in std_logic;
      awg_dat_i             : in std_logic_vector(AWG_DAT_WIDTH-1 downto 0);
      awg_addr_i            : in std_logic_vector(AWG_ADDR_WIDTH-1 downto 0);
      awg_addr_incr_o       : out std_logic;
      awg_addr_clr_o        : out std_logic;

      -- ret_dat_wbs interface
      internal_cmd_mode_i    : in std_logic_vector(INTERNAL_CMD_MODE_WIDTH-1 downto 0);
      step_period_i          : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      step_minimum_i         : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      step_size_i            : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      step_maximum_i         : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      step_param_id_i        : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      step_card_addr_i       : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      step_data_num_i        : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      step_phase_i           : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      step_value_o           : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);

      -- frame_timing interface
      sync_number_i         : in  std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);
      sync_pulse_i          : in std_logic;

      -- signals to cmd_queue
      cmd_code_o            : out std_logic_vector(FIBRE_PACKET_TYPE_WIDTH-1 downto 0);
      card_addr_o           : out std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0);
      param_id_o            : out std_logic_vector(BB_PARAMETER_ID_WIDTH-1 downto 0);
      data_size_o           : out std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);
      data_o                : out std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
      data_clk_o            : out std_logic;
      instr_rdy_o           : out std_logic;
      cmd_stop_o            : out std_logic;
      last_frame_o          : out std_logic;
      internal_cmd_o        : out std_logic;
      simple_cmd_o        : out std_logic;      
      num_rows_to_read_i    : in integer;
      num_cols_to_read_i    : in integer;
      override_sync_num_o   : out std_logic;
      ret_dat_in_progress_o : out std_logic;

      -- input from the cmd_queue
      busy_i                : in std_logic;
      ack_i                 : in std_logic;
      rdy_for_data_i        : in std_logic;
      data_timing_err_i     : in std_logic;

      -- outputs to the cmd_queue
      frame_seq_num_o       : out std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
      frame_sync_num_o      : out std_logic_vector(SYNC_NUM_WIDTH-1 downto 0)
   );
   end component;

   -----------------------------------------------------------------------------
   -- Command Queue component
   -----------------------------------------------------------------------------
   component cmd_queue
   port(
      -- for testing
      debug_o         : out std_logic_vector(31 downto 0);
      timer_trigger_o : out std_logic;

      -- reply_queue interface
      uop_rdy_o       : out std_logic;
      uop_ack_i       : in std_logic;
      card_addr_o     : out std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0);
      par_id_o        : out std_logic_vector(BB_PARAMETER_ID_WIDTH-1 downto 0);
      data_size_o     : out std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);
      cmd_code_o        : out std_logic_vector ( FIBRE_PACKET_TYPE_WIDTH-1 downto 0);
      data_timing_err_o : out std_logic;

      -- indicates a STOP command was recieved
      cmd_stop_o      : out std_logic;

      -- indicates the last frame of data for a ret_dat command
      last_frame_o    : out std_logic;

      frame_seq_num_o : out std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
      internal_cmd_o  : out std_logic;
      issue_sync_o    : out std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);

      -- cmd_translator interface
      card_addr_i     : in std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0);
      par_id_i        : in std_logic_vector(BB_PARAMETER_ID_WIDTH-1 downto 0);
      data_size_i     : in std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);
      data_i          : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
      data_clk_i      : in std_logic;
      issue_sync_i    : in std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);
      mop_rdy_i       : in std_logic;
      mop_ack_o       : out std_logic;
      rdy_for_data_o  : out std_logic;
      busy_o          : out std_logic;
      cmd_code_i      : in std_logic_vector ( FIBRE_PACKET_TYPE_WIDTH-1 downto 0);
      cmd_stop_i      : in std_logic;
      last_frame_i    : in std_logic;
      frame_seq_num_i : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
      internal_cmd_i  : in std_logic;
      simple_cmd_i    : in std_logic;
      override_sync_num_i : in std_logic;
      ret_dat_in_progress_i : in std_logic;

      -- lvds_tx interface
      tx_o            : out std_logic;

      -- frame_timing interface
      sync_num_i      : in std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);

      -- Clock lines
      clk_i           : in std_logic;
      rst_i           : in std_logic
   );
   end component;
   -----------------------------------------------------------------------------
   -- Command Q tpram component
   -----------------------------------------------------------------------------
   component cmd_queue_tpram is
      PORT
      (
         data        : IN STD_LOGIC_VECTOR (QUEUE_WIDTH-1 DOWNTO 0);
         wraddress   : IN STD_LOGIC_VECTOR (QUEUE_ADDR_WIDTH-1 DOWNTO 0);
         rdaddress_a : IN STD_LOGIC_VECTOR (QUEUE_ADDR_WIDTH-1 DOWNTO 0);
         rdaddress_b : IN STD_LOGIC_VECTOR (QUEUE_ADDR_WIDTH-1 DOWNTO 0);
         wren        : IN STD_LOGIC;
         clock       : IN STD_LOGIC;
         qa          : OUT STD_LOGIC_VECTOR (QUEUE_WIDTH-1 DOWNTO 0);
         qb          : OUT STD_LOGIC_VECTOR (QUEUE_WIDTH-1 DOWNTO 0)
      );
   END component;
   
   -----------------------------------------------------------------------------
   -- Reply Queue
   -----------------------------------------------------------------------------
   component reply_queue
   port(
      -- Global signals
      rst_i               : in std_logic;
      clk_i               : in std_logic;
      clk_n_i             : in std_logic;
      comm_clk_i          : in std_logic;
      
      -- cmd_queue interface
      cmd_to_retire_i     : in std_logic;
      cmd_sent_o          : out std_logic;
      card_addr_i         : in std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0);
      par_id_i            : in std_logic_vector(BB_PARAMETER_ID_WIDTH-1 downto 0);
      data_size_i         : in std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);
      cmd_stop_i          : in std_logic;
      last_frame_i        : in std_logic;
      frame_seq_num_i     : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
      internal_cmd_i      : in std_logic;
      data_rate_i         : in std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);
      row_len_i           : in integer;
      num_rows_i          : in integer;
      issue_sync_i        : in std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);
      cmd_code_i          : in  std_logic_vector (FIBRE_PACKET_TYPE_WIDTH-1 downto 0);       -- the least significant 16-bits from the fibre packet
      step_value_i        : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      data_timing_err_i   : in std_logic;

      -- cmd_translator interface
      over_temperature_o  : out std_logic;

      -- reply_translator interface (from reply_queue, i.e. these signals are de-multiplexed from retire and sequencer)
      size_o              : out integer;
      data_o              : out std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
      error_code_o        : out std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
      rdy_o               : out std_logic;
      ack_i               : in std_logic;

      -- reply_translator interface (from reply_queue_retire)
      cmd_valid_o         : out std_logic;
      cmd_code_o          : out std_logic_vector(FIBRE_PACKET_TYPE_WIDTH-1 downto 0);
      param_id_o          : out std_logic_vector(BB_PARAMETER_ID_WIDTH-1 downto 0);
      card_addr_o         : out std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0);

      -- ret_dat_wbs interface
      num_rows_to_read_i  : in integer;
      num_cols_to_read_i  : in integer;
      ramp_card_addr_i    : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
      ramp_param_id_i     : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
      run_file_id_i       : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
      user_writable_i     : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
      cards_to_report_i   : in std_logic_vector(NUM_CARDS_TO_REPLY-1 downto 0);
      rcs_to_report_data_i: in std_logic_vector(NUM_CARDS_TO_REPLY-1 downto 0);
      dead_card_i         : in std_logic;

      -- clk_switchover interface
      active_clk_i        : in std_logic;

      -- cc_reset interface
      reset_event_i       : in std_logic;
      reset_ack_o         : out std_logic;

      -- dv_rx interface
      sync_box_err_i      : in std_logic;
      sync_box_err_ack_o  : out std_logic;
      sync_box_free_run_i : in std_logic;
      external_dv_num_i   : in std_logic_vector(DV_NUM_WIDTH-1 downto 0);

      -- non-manchester encoded fibre input to be encoded in the frame header
      dv_pulse_fibre_i       : in std_logic;

      -- Bus Backplane interface
      lvds_reply_all_a_i  : in std_logic_vector(NUM_CARDS_TO_REPLY-1 downto 0);
      lvds_reply_all_b_i  : in std_logic_vector(NUM_CARDS_TO_REPLY-1 downto 0);
      card_not_present_o  : out std_logic_vector(NUM_CARDS_TO_REPLY-1 downto 0)
   );
   end component;

   -----------------------------------------------------------------------------
   -- Reply Translator component
   -----------------------------------------------------------------------------
   component reply_translator
   port(
      -- for testing
      debug_o             : out std_logic_vector (31 downto 0);

      -- global inputs
      rst_i                   : in  std_logic;
      clk_i                   : in  std_logic;

      -- ret_dat_wbs interface
      crc_err_en_i           : in std_logic;
      stop_delay_i           : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);

      -- signals to/from fibre_rx
      cmd_rcvd_er_i           : in  std_logic;
      cmd_rcvd_ok_i           : in  std_logic;
      c_cmd_code_i            : in  std_logic_vector(FIBRE_PACKET_TYPE_WIDTH-1  downto 0);
      c_card_addr_i           : in  std_logic_vector(FIBRE_CARD_ADDRESS_WIDTH-1 downto 0);
      c_param_id_i            : in  std_logic_vector(FIBRE_PARAMETER_ID_WIDTH-1 downto 0);

      -- signals to/from cmd_translator
      cmd_stop_i              : in std_logic;

      -- signals to/from reply queue
      r_cmd_code_i            : in  std_logic_vector(FIBRE_PACKET_TYPE_WIDTH-1  downto 0);
      r_card_addr_i           : in  std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0);
      r_param_id_i            : in  std_logic_vector(BB_PARAMETER_ID_WIDTH-1 downto 0);

      -- signals to/from reply queue
      r_cmd_rdy_i             : in  std_logic;
      mop_error_code_i        : in  std_logic_vector(PACKET_WORD_WIDTH-1      downto 0);
      fibre_word_i            : in  std_logic_vector(PACKET_WORD_WIDTH-1     downto 0);
      num_fibre_words_i       : in  integer ;
      fibre_word_ack_o        : out std_logic;
      fibre_word_rdy_i        : in std_logic;
      -- input from the cmd_queue
--      busy_i                  : in std_logic;

      checksum_repeated_o   : out std_logic;
      checksum_prev1_o      : out std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);  
      checksum_prev2_o      : out std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);  

      -- signals to / from fibre_tx
      fibre_tx_busy_i         : in std_logic;
      fibre_tx_rdy_o          : out std_logic;
      fibre_tx_dat_o          : out std_logic_vector(PACKET_WORD_WIDTH-1 downto 0)
      );
   end component;

end issue_reply_pack;
