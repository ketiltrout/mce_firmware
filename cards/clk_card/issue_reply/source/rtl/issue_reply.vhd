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

--
--
-- <revision control keyword substitutions e.g. $Id: issue_reply.vhd,v 1.87 2012-05-14 19:55:40 mandana Exp $>
--
-- Project:       SCUBA-2
-- Author:        Jonathan Jacob
--
-- Organisation:  UBC
--
-- Description:  This module is the top level for receiving fibre commands, translating them into
-- instructions, and issuing them over the bus backplane.
--
--
-- Revision history:
--
-- <date $Date: 2012-05-14 19:55:40 $> -     <text>      - <initials $Author: mandana $>
--
-- $Log: issue_reply.vhd,v $
-- Revision 1.87  2012-05-14 19:55:40  mandana
-- step_value removed from cmd_q interface. This is only passed to reply translator to be assembled as part of the header.
--
-- Revision 1.86  2012-02-09 00:19:10  mandana
-- dv_pulse_fibre_i is now reported in bit 9 of the frame-status word of the frame header
-- header version 7
--
-- Revision 1.85  2012-01-06 23:07:24  mandana
-- added simple_cmd and busy_io to cmd_translator/cmd_q interface
-- cosmetic cleanup
--
-- Revision 1.84  2011-12-01 19:46:11  mandana
-- re-organized pack files
--
-- Revision 1.83  2011-11-30 22:06:05  mandana
-- re-organized pack files in hierarchical manner and moved all component declarations into pack files
--
-- Revision 1.82  2010/05/14 22:56:16  bburger
-- BB:  Added dead_card_i interface signals
--
-- Revision 1.81  2010/01/21 19:45:15  bburger
-- BB: awg_addr interfaces
--
-- Revision 1.80  2010/01/18 20:39:38  bburger
-- BB: Changed "MLS" prefixes to "AWG" for "Abitrary Waveform Generator"
--
-- Revision 1.79  2010/01/13 20:32:11  bburger
-- BB:  Changed constant names from MEM_DAT_WIDTH and MEM_ADDR_WIDTH to MLS_DAT_WIDTH and MLS_ADDR_WIDTH
--
-- Revision 1.78  2010/01/13 20:13:40  bburger
-- BB: Added interface signals for MLS functionality.
--
-- Revision 1.77  2009/05/12 19:19:31  bburger
-- BB: Renamed the last_ret_dat_i signal interface to cmd_stop_i -- a more self-evident name.
--
-- Revision 1.76  2009/05/12 18:47:12  bburger
-- BB: Added new and removed unused interface signals.
--
-- Revision 1.75  2009/01/16 01:49:36  bburger
-- BB:  Interface signal direction changes
--
-- Revision 1.74  2008/12/22 20:47:59  bburger
-- BB:  Added interface signals for dual LVDS lines from each card, and for supporting column data from the Readout Cards
--
-- Revision 1.73  2008/10/25 00:24:54  bburger
-- BB:  Added support for RCS_TO_REPORT_DATA command
--
-- Revision 1.72  2008/10/17 00:31:20  bburger
-- BB:  added support for the stop_dly and cards_to_report commands
--
-- Revision 1.71  2008/02/03 09:45:37  bburger
-- BB:
-- - Removed unused interface signals
-- - Added interface signals that will be used in the future
--
-- Revision 1.70  2008/01/28 20:26:15  bburger
-- BB:
-- - added the override_sync_num interface signal to the cmd_translator and cmd_queue
--
-- Revision 1.69  2007/10/18 22:37:34  bburger
-- BB:  Added card-not-present interfaces
--
-- Revision 1.68  2007/09/20 19:44:53  bburger
-- BB:  Added the following interface signals to reply_queue for version 6 of the data frame header:  ramp_card_addr, ramp_param_id, run_file_id, user_writable_i
--
-- Revision 1.67  2007/09/05 03:41:50  bburger
-- BB:  added num_rows_to_read_i interface to reply_queue
--
-- Revision 1.66  2007/08/28 23:20:53  bburger
-- BB:  added new interface signals between issue_reply and ret_dat_wbs for communicating internal ramp command parameters to the cmd_translator block.
--
-- Revision 1.65  2007/07/24 22:47:24  bburger
-- BB:
-- - added clk_n_i signal to the issue_reply interface.  The signal is used by the reply_translator frame header buffer for sampling data.
-- - added lvds_reply_psu_a signal for the dispatch block instantiated for the PSUC
-- - added the reset_event_i and reset_ack_o signals from the cc_reset block for the mce_has_been_reset flag in packet error words
--
-- Revision 1.64  2007/02/01 01:53:54  bburger
-- Bryce:  removed unused interfaces
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;

library components;
use components.component_pack.all;

library work;
use work.frame_timing_pack.all;

-- Call Parent Library
use work.clk_card_pack.all;

-- Call Own Library
use work.issue_reply_pack.all;

entity issue_reply is
   port(
      -- for testing
      debug_o                : out std_logic_vector (31 downto 0);

      -- global signals
      rst_i                  : in std_logic;
      clk_i                  : in std_logic;
      clk_n_i                : in std_logic;
      comm_clk_i             : in std_logic;

      -- inputs from the bus backplane
      lvds_reply_all_a_i     : in std_logic_vector(9 downto 0);
      lvds_reply_all_b_i     : in std_logic_vector(9 downto 0);
      card_not_present_o     : out std_logic_vector(9 downto 0);

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
      cards_to_report_i      : in std_logic_vector(9 downto 0);
      rcs_to_report_data_i   : in std_logic_vector(9 downto 0);
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
      sync_pulse_i           : in std_logic;  -- restart_frame_aligned_i
      sync_number_i          : in std_logic_vector (SYNC_NUM_WIDTH-1 downto 0)
   );
end issue_reply;


architecture rtl of issue_reply is

   -- fibre_rx to cmd_translator and reply_translator
   signal c_cmd_code          : std_logic_vector (FIBRE_PACKET_TYPE_WIDTH-1 downto 0);
   signal c_param_id          : std_logic_vector (FIBRE_PARAMETER_ID_WIDTH-1 downto 0);
   signal c_card_addr         : std_logic_vector (FIBRE_CARD_ADDRESS_WIDTH-1 downto 0);
   signal cmd_err             : std_logic;
   signal cmd_data            : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
   signal cmd_rdy             : std_logic;
   signal rt_cmd_rdy          : std_logic;
   signal data_clk            : std_logic;
   signal num_data            : std_logic_vector (FIBRE_DATA_SIZE_WIDTH-1 downto 0);
   signal cmd_ack             : std_logic;
   signal reply_cmd_code      : std_logic_vector (FIBRE_PACKET_TYPE_WIDTH-1 downto 0);
   signal reply_cmd_code_b    : std_logic_vector (FIBRE_PACKET_TYPE_WIDTH-1 downto 0);
   signal issue_sync          : std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);
   signal ret_dat_in_progress : std_logic;

   -- cmd_translator to cmd_queue interface
   signal card_addr2          : std_logic_vector (BB_CARD_ADDRESS_WIDTH-1 downto 0);
   signal parameter_id        : std_logic_vector (BB_PARAMETER_ID_WIDTH-1 downto 0);
   signal data_size           : std_logic_vector (BB_DATA_SIZE_WIDTH-1 downto 0);
   signal data                : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
   signal data_clk2           : std_logic;
   signal frame_sync_num      : std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);
   signal frame_seq_num       : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal macro_instr_rdy     : std_logic;
   signal cmd_queue_busy      : std_logic;
   signal mop_ack             : std_logic;
   signal cmd_stop            : std_logic;
   signal last_frame          : std_logic;
   signal internal_cmd        : std_logic;
   signal simple_cmd          : std_logic;
   signal rdy_for_data        : std_logic;
   signal override_sync_num   : std_logic;

   -- cmd_queue to reply_queue interface
   signal r_cmd_code          : std_logic_vector (FIBRE_PACKET_TYPE_WIDTH-1 downto 0);
   signal r_param_id          : std_logic_vector (BB_PARAMETER_ID_WIDTH-1 downto 0);
   signal r_card_addr         : std_logic_vector (BB_CARD_ADDRESS_WIDTH-1 downto 0);
   signal uop_rdy             : std_logic;
   signal uop_ack             : std_logic;
   signal card_addr_cr        : std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0);
   signal par_id_cr           : std_logic_vector(BB_PARAMETER_ID_WIDTH-1 downto 0);
   signal data_size_cr        : std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);
   signal cmd_stop_cr         : std_logic;
   signal last_frame_cr       : std_logic;
   signal frame_seq_num_cr    : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal internal_cmd_cr     : std_logic;
   signal step_value          : std_logic_vector(WB_DATA_WIDTH-1 downto 0);

   -- reply_queue to reply_translator interface
   signal m_op_rdy            : std_logic;
   signal m_op_error_code     : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal fibre_word          : std_logic_vector (PACKET_WORD_WIDTH-1        downto 0);
   signal num_fibre_words     : integer;
   signal fibre_word_ack      : std_logic;
   signal fibre_word_rdy      : std_logic;

   -- reply_translator to fibre_tx interface
   signal fibre_tx_dat        : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal fibre_tx_rdy        : std_logic;
   signal fibre_tx_busy       : std_logic;
   
   signal data_timing_err   : std_logic;

begin

   ------------------------------------------------------------------------
   -- fibre receiver
   ------------------------------------------------------------------------
   i_fibre_rx : fibre_rx
   port map(
      sbr_o          => open,

      clk_i          => clk_i,
      rst_i          => rst_i,

      cmd_err_o      => cmd_err,
      cmd_rdy_o      => cmd_rdy,
      cmd_ack_i      => cmd_ack,
      rt_cmd_rdy_o   => rt_cmd_rdy,
      rdy_for_data_i => rdy_for_data,

      cmd_code_o     => c_cmd_code,
      card_addr_o    => c_card_addr,
      param_id_o     => c_param_id,
      dat_size_o     => num_data,
      dat_clk_o      => data_clk,
      dat_o          => cmd_data,

      fibre_clkr_i   => fibre_clkr_i,
      fibre_data_i   => rx_data_i,
      fibre_nrdy_i   => nrx_rdy_i,
      fibre_rvs_i    => rvs_i,
      fibre_rso_i    => rso_i,
      fibre_sc_nd_i  => rsc_nrd_i
   );

   ------------------------------------------------------------------------
   -- command translator
   ------------------------------------------------------------------------
   i_cmd_translator : cmd_translator
   port map(
      -- global inputs
      rst_i               => rst_i,
      clk_i               => clk_i,

      -- inputs from fibre_rx
      card_addr_i         => c_card_addr,
      cmd_code_i          => c_cmd_code,
      cmd_data_i          => cmd_data,
      cmd_rdy_i           => cmd_rdy,
      data_clk_i          => data_clk,
      num_data_i          => num_data,
      param_id_i          => c_param_id,

      -- output to fibre_rx
      ack_o               => cmd_ack,

      -- outputs to cmd_queue
      card_addr_o         => card_addr2,
      param_id_o          => parameter_id,
      data_size_o         => data_size,
      data_o              => data,
      data_clk_o          => data_clk2,
      instr_rdy_o         => macro_instr_rdy,
      frame_seq_num_o     => frame_seq_num,
      frame_sync_num_o    => frame_sync_num,
      cmd_code_o          => reply_cmd_code,
      cmd_stop_o          => cmd_stop,
      last_frame_o        => last_frame,
      internal_cmd_o      => internal_cmd,
      simple_cmd_o        => simple_cmd,
      step_value_o        => step_value,
      override_sync_num_o => override_sync_num,

      --input from the cmd_queue
      busy_i              => cmd_queue_busy,
      ack_i               => mop_ack,
      rdy_for_data_i      => rdy_for_data,
      data_timing_err_i   => data_timing_err,

      start_seq_num_i     => start_seq_num_i,
      stop_seq_num_i      => stop_seq_num_i,
      data_rate_i         => data_rate_i,
      dv_mode_i           => dv_mode_i,
      external_dv_i       => external_dv_i,
      ret_dat_in_progress_o => ret_dat_in_progress,

      -- ret_dat_wbs interface
      num_rows_to_read_i  => num_rows_to_read_i,
      num_cols_to_read_i  => num_cols_to_read_i,
      internal_cmd_mode_i => internal_cmd_mode_i,
      step_period_i       => step_period_i,
      step_minimum_i      => step_minimum_i,
      step_size_i         => step_size_i,
      step_maximum_i      => step_maximum_i,
      step_param_id_i     => step_param_id_i,
      step_card_addr_i    => step_card_addr_i,
      step_data_num_i     => step_data_num_i,
      step_phase_i        => step_phase_i,

      awg_dat_i           => awg_dat_i, 
      awg_addr_i          => awg_addr_i,
      awg_addr_incr_o     => awg_addr_incr_o,
      awg_addr_clr_o      => awg_addr_clr_o,
      
      -- frame_timing
      sync_number_i       => sync_number_i,
      sync_pulse_i        => sync_pulse_i
   );

   ------------------------------------------------------------------------
   -- command queue (u-op sequence generator)
   ------------------------------------------------------------------------
   i_cmd_queue : cmd_queue
   port map(
      -- global siganls
      rst_i           => rst_i,
      clk_i           => clk_i,
      
      -- reply_queue interface
      uop_rdy_o       => uop_rdy,
      uop_ack_i       => uop_ack,
      card_addr_o     => card_addr_cr,
      par_id_o        => par_id_cr,
      data_size_o     => data_size_cr,
      cmd_stop_o      => cmd_stop_cr,
      last_frame_o    => last_frame_cr,
      frame_seq_num_o => frame_seq_num_cr,
      internal_cmd_o  => internal_cmd_cr,
      issue_sync_o    => issue_sync,
      cmd_code_o      => reply_cmd_code_b,
      data_timing_err_o => data_timing_err,

      -- cmd_translator interface
      card_addr_i     => card_addr2,
      par_id_i        => parameter_id,
      data_size_i     => data_size,
      data_i          => data,
      data_clk_i      => data_clk2,
      issue_sync_i    => frame_sync_num,
      mop_rdy_i       => macro_instr_rdy,
      busy_o          => cmd_queue_busy,
      mop_ack_o       => mop_ack,
      rdy_for_data_o  => rdy_for_data,
      cmd_stop_i      => cmd_stop,
      last_frame_i    => last_frame,
      frame_seq_num_i => frame_seq_num,
      internal_cmd_i  => internal_cmd,
      simple_cmd_i    => simple_cmd,
      cmd_code_i      => reply_cmd_code,
      override_sync_num_i => override_sync_num,
      ret_dat_in_progress_i => ret_dat_in_progress,

      -- lvds_tx interface
      tx_o            => lvds_cmd_o,

      -- frame_timing interface
      sync_num_i      => sync_number_i,
      
      -- for testing
      debug_o         => open,
      timer_trigger_o => open
   );

   ------------------------------------------------------------------------
   -- reply queue
   ------------------------------------------------------------------------
   i_reply_queue : reply_queue
   port map(
      -- Global signals
      rst_i               => rst_i,
      clk_i               => clk_i,
      clk_n_i             => clk_n_i,
      comm_clk_i          => comm_clk_i,

      -- cmd_queue interface
      cmd_to_retire_i     => uop_rdy,
      cmd_sent_o          => uop_ack,
      card_addr_i         => card_addr_cr,
      par_id_i            => par_id_cr,
      data_size_i         => data_size_cr,
      cmd_stop_i          => cmd_stop_cr,
      last_frame_i        => last_frame_cr,
      frame_seq_num_i     => frame_seq_num_cr,
      internal_cmd_i      => internal_cmd_cr,
      cmd_code_i          => reply_cmd_code_b,
      step_value_i        => step_value,
      issue_sync_i        => issue_sync,
      data_timing_err_i   => data_timing_err,

      -- sync_gen interface
      row_len_i           => row_len_i,
      num_rows_i          => num_rows_i,

      -- reply_translator interface (from reply_queue, i.e. these signals are de-multiplexed from retire and sequencer)
      size_o              => num_fibre_words,
      data_o              => fibre_word,
      error_code_o        => m_op_error_code,
      cmd_valid_o         => m_op_rdy,
      rdy_o               => fibre_word_rdy,
      ack_i               => fibre_word_ack,

      -- reply_translator interface (from reply_queue_retire)
      -- reply_queue acks, based on how much data it has to give, not how much the reply_transator thinks it needs!
      cmd_code_o          => r_cmd_code,
      param_id_o          => r_param_id,
      card_addr_o         => r_card_addr,

      -- ret_dat_wbs interface
      data_rate_i          => data_rate_i,
      num_rows_to_read_i   => num_rows_to_read_i,
      num_cols_to_read_i   => num_cols_to_read_i,
      ramp_card_addr_i     => step_card_addr_i,
      ramp_param_id_i      => step_param_id_i,
      run_file_id_i        => run_file_id_i,
      user_writable_i      => user_writable_i,
      cards_to_report_i    => cards_to_report_i,
      rcs_to_report_data_i => rcs_to_report_data_i,
      dead_card_i          => dead_card_i,

      -- clk_switchover interface
      active_clk_i        => active_clk_i,

      -- cc_reset interface
      reset_event_i       => reset_event_i,
      reset_ack_o         => reset_ack_o,

      -- dv_rx interface
      sync_box_err_i      => sync_box_err_i,
      sync_box_err_ack_o  => sync_box_err_ack_o,
      sync_box_free_run_i => sync_box_free_run_i,
      external_dv_num_i   => external_dv_num_i,
      
      -- non-manchester encoded fibre input to be encoded in the frame header
      dv_pulse_fibre_i    => dv_pulse_fibre_i,      

      -- Bus Backplane interface
      lvds_reply_all_a_i  => lvds_reply_all_a_i,
      lvds_reply_all_b_i  => lvds_reply_all_b_i,
      card_not_present_o  => card_not_present_o
   );

   ------------------------------------------------------------------------
   -- reply_translator
   ------------------------------------------------------------------------
   i_reply_translator : reply_translator
   port map(
      -- For testing
      debug_o           => debug_o,

      -- Global inputs
      rst_i             => rst_i,
      clk_i             => clk_i,
      crc_err_en_i      => crc_err_en_i,
      stop_delay_i      => stop_delay_i,

      -- Signals to/from fibre_rx
      cmd_rcvd_er_i     => cmd_err,
      cmd_rcvd_ok_i     => rt_cmd_rdy,
      c_cmd_code_i      => c_cmd_code,
      c_card_addr_i     => c_card_addr,
      c_param_id_i      => c_param_id,

      -- Signals to/from cmd_translator
      cmd_stop_i   => cmd_stop,

      -- Signals to/from reply queue
      r_cmd_code_i      => r_cmd_code,
      r_card_addr_i     => r_card_addr,
      r_param_id_i      => r_param_id,
      r_cmd_rdy_i       => m_op_rdy,
      mop_error_code_i  => m_op_error_code,
      fibre_word_i      => fibre_word,
      num_fibre_words_i => num_fibre_words,
      fibre_word_ack_o  => fibre_word_ack,
      fibre_word_rdy_i  => fibre_word_rdy,

      -- Signals from cmd_queue
--      busy_i            => busy,

      -- Signals to / from fibre_tx
      fibre_tx_rdy_o    => fibre_tx_rdy,
      fibre_tx_busy_i   => fibre_tx_busy,
      fibre_tx_dat_o    => fibre_tx_dat
   );

   ------------------------------------------------------------------------
   -- fibre transmitter
   ------------------------------------------------------------------------
   i_fibre_tx : fibre_tx
   port map(
      clk_i         => clk_i,
      rst_i         => rst_i,

      dat_i         => fibre_tx_dat,
      rdy_i         => fibre_tx_rdy,
      busy_o        => fibre_tx_busy,

      fibre_clk_i   => fibre_clkw_i,
      fibre_data_o  => tx_data_o,
      fibre_sc_nd_o => tsc_nTd_o,
      fibre_nena_o  => nFena_o
   );

end rtl;