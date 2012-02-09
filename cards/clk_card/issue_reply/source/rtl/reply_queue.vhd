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
-- $Id: reply_queue.vhd,v 1.57 2012-01-06 23:10:39 mandana Exp $
--
-- Project:    SCUBA2
-- Author:     Bryce Burger, Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- This file implements the reply_queue block in the issue/reply chain
-- on the clock card.
-- It assembles the frame header of the reply packet and it assumes that replies to the 
-- internal commands come in a known order.
-- WARNING: This module needs major overhaul, it is poorly coded and non-parametrized.
-- Any changes to the header format may derive rewriting this module.
--
-- Revision history:
-- $Log: reply_queue.vhd,v $
-- Revision 1.57  2012-01-06 23:10:39  mandana
-- cosmetic cleanup and parametrized signals
-- moved frame-header definitions to issue_reply_pack
--
-- Revision 1.56  2011-12-01 19:46:11  mandana
-- re-organized pack files
--
-- Revision 1.55  2011-11-30 22:16:33  mandana
-- typo
--
-- Revision 1.54  2011-11-30 22:06:06  mandana
-- re-organized pack files in hierarchical manner and moved all component declarations into pack files
--
-- Revision 1.53  2010/05/14 22:57:17  bburger
-- BB:  Added dead_card_i interface signals
--
-- Revision 1.52  2009/05/12 18:50:29  bburger
-- BB: Added the data_timing_err_i flag to the data packet status word.
--
-- Revision 1.51  2009/01/16 01:51:03  bburger
-- BB: fixed a card_not_present logic error
--
-- Revision 1.50  2008/12/22 20:48:25  bburger
-- BB:  Added interface signals for dual LVDS lines from each card, and for supporting column data from the Readout Cards
--
-- Revision 1.49  2008/10/25 00:24:54  bburger
-- BB:  Added support for RCS_TO_REPORT_DATA command
--
-- Revision 1.48  2008/10/17 00:33:10  bburger
-- BB:  modified the logic for calculating the reply data size because of the cards_to_report command
--
-- Revision 1.47  2008/02/03 09:47:07  bburger
-- BB:  removed stop_bit_o and last_frame_bit_o and cmd_sent_i interface signals.  They are unused.
--
-- Revision 1.46  2007/10/18 22:40:10  bburger
-- BB:  Added card-not-present interfaces
--
-- Revision 1.45  2007/09/20 19:48:37  bburger
-- BB:
-- - Added the following interface signals to reply_queue for version 6 of the data frame header:  ramp_card_addr, ramp_param_id, run_file_id, user_writable_i
-- - Updated the header to version 6
--
-- Revision 1.44  2007/09/05 03:43:28  bburger
-- BB:  Reordered the words in the data frame headers to match the original configuration at ACT.
--
-- Revision 1.43  2007/08/28 23:24:54  bburger
-- BB:
-- - removed tes_bias_step_level from the data header.
-- - added card_addr, ramp_value, row_len, num_rows and data_rate to the data header.
--
-- Revision 1.42  2007/07/24 23:10:55  bburger
-- BB:
-- - added the over_temperature_o signal to the reply_queue interface to signal the cmd_translator to shut down the MCE.
-- - added the frame_status_word_o signal to the reply_queue interface to the reply_translator for integration into data-frame headers
-- - added the reset_event_i and reset_ack_o signals to the reply_queue interface for integration into the frame status word in data frames
-- - added the lvds_reply_psu_a signale to the reply_queue interface for replies from the PSUC dispatch block
-- - added the clk_n_i signal for off-cycle signal sampling by the frame header RAM
-- - added constants for card- and fpga- temperature absolute maximums
-- - implemented data frame header storage
-- - implemented stale data bit setting logic.
-- - implemented logic that determines the number of cards expected to respond to every command
-- - implemented logic to calculated the expected total data size of the reply
-- - implemented error registers for saving frame status bits that are associated with errors until the next data frame
--
-- Revision 1.41  2007/02/13 02:34:53  bburger
-- Bryce:  fixed a counter bug in reply_queue that was preventing all header words from being read out
--
------------------------------------------------------------------------

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
use work.issue_reply_pack.all;

-- Call own Library
use work.reply_queue_pack.all;

entity reply_queue is
   port(
      -- Global signals
      clk_i               : in std_logic;
      clk_n_i             : in std_logic;
      comm_clk_i          : in std_logic;
      rst_i               : in std_logic;

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
-- The reply_queue acks, based on how much data it has to give,
-- not how much the reply_transator thinks it needs!
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
      dv_pulse_fibre_i    : in std_logic;

      -- Bus Backplane interface
      lvds_reply_all_a_i  : in std_logic_vector(NUM_CARDS_TO_REPLY-1 downto 0);
      lvds_reply_all_b_i  : in std_logic_vector(NUM_CARDS_TO_REPLY-1 downto 0);

      card_not_present_o  : out std_logic_vector(NUM_CARDS_TO_REPLY-1 downto 0)
   );
end reply_queue;

architecture behav of reply_queue is

   -- Max temperature is 100 degrees Celcius.
   constant MAX_NUM_OVERTEMPERATURES : integer := 10;
   constant MAX_TEMP  : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0) := x"00000064";
   constant BIT_STATUS_SIZE : integer := PACKET_WORD_WIDTH;   

   -- Internal signals
   signal active_clk           : std_logic;
   signal sync_box_err         : std_logic;
   signal clr_sync_box_err     : std_logic;
   signal sync_box_free_run    : std_logic;

   signal matched              : std_logic;
   signal cmd_rdy              : std_logic;
   signal internal_cmd         : std_logic;

   signal data_size            : integer;
   signal data_bus             : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal error_code           : std_logic_vector(29 downto 0);
   signal reset_and_error_code : std_logic_vector(30 downto 0);
   signal word_rdy             : std_logic; -- word is valid
   signal word_ack             : std_logic;

   -- Register Signals
   signal num_cols_reported    : std_logic_vector(3 downto 0);
   signal cmd_code             : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);       -- the least significant 16-bits from the fibre packet
   signal card_addr            : std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0);   -- The card address of the m-op
   signal par_id               : std_logic_vector(BB_PARAMETER_ID_WIDTH-1 downto 0);   -- The parameter id of the m-op
   signal data_size_t          : std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);      -- The number of bytes of data in the m-op
   signal bit_status           : std_logic_vector(BIT_STATUS_SIZE-1 downto 0);
   signal bit_status_i         : std_logic_vector(BIT_STATUS_SIZE-1 downto 0);
   signal frame_seq_num        : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal frame_status         : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal issue_sync_num       : std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);
   signal reg_en               : std_logic;

   -- Retire FSM:  waits for replies from the Bus Backplane, and retires pending instructions in the the command queue
   type retire_states is (IDLE, LATCH_CMD1, LATCH_CMD2, RECEIVED, WAIT_FOR_MATCH, REPLY, STORE_ERRNO_HEADER_WORD,
      STORE_HEADER_WORD, PAUSE_HEADER_WORD, NEXT_HEADER_WORD, DONE_HEADER_STORE, TX_HEADER, TX_SYNC_NUM, TX_FRAME_STATUS, TX_CARD_ADDR,
      TX_ACTIVE_CLK, TX_SYNC_BOX_ERR, TX_SYNC_BOX_FR, TX_DATA_RATE, TX_ROW_LEN, TX_NUM_ROWS_SERVOED, TX_RAMP_VALUE, TX_FRAME_SEQUENCE_NUM,
      TX_SEND_DATA, WAIT_FOR_ACK, TX_STATUS, TX_DV_NUM, INTERNAL_WB, TX_TES_BIAS_LEVEL, TX_NUM_ROWS_TO_READ, TX_SPARE,
      TX_RUN_FILE_ID, TX_USER_WRITABLE, TX_RAMP_CA_PI, TX_HEADER_VERSION);
   signal present_retire_state : retire_states;
   signal next_retire_state    : retire_states;

   -- signals for header RAM
   signal hdr_ram_dat_in       : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal hdr_ram_dat_out      : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
   signal hdr_ram_addr         : std_logic_vector (RAM_HEAD_ADDR_WIDTH-1 downto 0);
   signal hdr_ram_wren         : std_logic;
   
   signal header_storage_address : std_logic_vector (RAM_HEAD_ADDR_WIDTH-1 downto 0);

   signal header_tx_address      : std_logic_vector (RAM_HEAD_ADDR_WIDTH-1 downto 0);
   
   -- Specifies the starting index at which to store internal command information
   signal internal_cmd_offset  : integer;
   
   -- Specifies the header offset at which we insert the first word from the header queue
   constant TX_OFFSET          : integer := 4;
   
   -- overtemperature counter signals!
   signal inc_ot_count         : std_logic;
   signal dec_ot_count         : std_logic;
   signal clr_ot_count         : std_logic;
   signal ot_count             : integer;
   signal ot_count_plus_1      : integer;
   signal ot_count_minus_1     : integer;

   signal head_data            : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);

   signal ena_word_count       : std_logic;
   signal clr_word_count       : std_logic;
   signal word_count           : integer;
   signal word_count_new       : integer;

   signal status_en            : std_logic;
   signal status_q             : std_logic_vector(30 downto 0);

   signal fpga_temp_stale      : std_logic;
   signal card_temp_stale      : std_logic;
   signal psu_status_stale     : std_logic;
   signal box_temp_stale       : std_logic;

   signal num_cards        : std_logic_vector(3 downto 0);
   signal datasize_reg_en  : std_logic;
   signal datasize_reg_q   : std_logic_vector(BB_DATA_SIZE_WIDTH +4 -1 downto 0);
   signal num_cards_reg_en : std_logic;

   signal timer_rst           : std_logic;
   signal time                : integer;

   signal reset_event         : std_logic;
   signal clr_reset           : std_logic;

   signal rc_bit_encoding : std_logic_vector(3 downto 0);
   signal rcs_responding  : std_logic_vector(3 downto 0);

   signal psu_slv : std_logic_vector(3 downto 0);
   signal cc_slv  : std_logic_vector(3 downto 0);
   signal rc4_slv : std_logic_vector(3 downto 0);
   signal rc3_slv : std_logic_vector(3 downto 0);
   signal rc2_slv : std_logic_vector(3 downto 0);
   signal rc1_slv : std_logic_vector(3 downto 0);
   signal bc3_slv : std_logic_vector(3 downto 0);
   signal bc2_slv : std_logic_vector(3 downto 0);
   signal bc1_slv : std_logic_vector(3 downto 0);
   signal ac_slv  : std_logic_vector(3 downto 0);

begin

   --------------------------------------------------------------------
   -- RAM to save frame header info
   --------------------------------------------------------------------
   i_reply_translator_frame_head_ram : reply_translator_frame_head_ram
   port map(
      address  => hdr_ram_addr,
      clock    => clk_n_i,
      data     => hdr_ram_dat_in,
      wren     => hdr_ram_wren,
      q        => hdr_ram_dat_out
   );

   -- Header access address for RX and TX
   header_storage_address <= conv_std_logic_vector(word_count + internal_cmd_offset, 6);
   header_tx_address      <= conv_std_logic_vector(word_count - TX_OFFSET, 6);

   -- Errno word for each internal command
   head_data <=
      fpga_temp_stale  & hdr_ram_dat_out(30 downto 0) when (word_count - TX_OFFSET = FPGA_TEMP_OFFSET)  else
      card_temp_stale  & hdr_ram_dat_out(30 downto 0) when (word_count - TX_OFFSET = CARD_TEMP_OFFSET)  else
      psu_status_stale & hdr_ram_dat_out(30 downto 0) when (word_count - TX_OFFSET = PSC_STATUS_OFFSET) else
      box_temp_stale   & hdr_ram_dat_out(30 downto 0) when (word_count - TX_OFFSET = BOX_TEMP_OFFSET)   else hdr_ram_dat_out;

   -- Internal command RAM storage offset
   internal_cmd_offset <=
      FPGA_TEMP_OFFSET  when par_id = FPGA_TEMP_ADDR else
      CARD_TEMP_OFFSET  when par_id = CARD_TEMP_ADDR else
      PSC_STATUS_OFFSET when par_id = PSC_STATUS_ADDR else
      BOX_TEMP_OFFSET   when par_id = BOX_TEMP_ADDR else 0;

   -------------------------------------------------------------------------------------------
   -- timer for decrementing the warning counter
   -------------------------------------------------------------------------------------------
   timer : us_timer
   port map(
      clk           => clk_i,
      timer_reset_i => timer_rst,
      timer_count_o => time);

   -------------------------------------------------------------------------------------------
   -- Registers
   -------------------------------------------------------------------------------------------
   register_0 : process (rst_i, clk_i)
   begin
      if(rst_i = '1') then
         fpga_temp_stale  <= '1';
         card_temp_stale  <= '1';
         psu_status_stale <= '1';
         box_temp_stale   <= '1';

      elsif (clk_i'EVENT and clk_i = '1') then
         -- Keep track of what fields have been updated since the last data packet.
         if(internal_cmd = '1') then
            if(par_id = FPGA_TEMP_ADDR) then
               fpga_temp_stale  <= '0';
            elsif(par_id = CARD_TEMP_ADDR) then
               card_temp_stale  <= '0';
            elsif(par_id = PSC_STATUS_ADDR) then
               psu_status_stale <= '0';
            elsif(par_id = BOX_TEMP_ADDR) then
               box_temp_stale   <= '0';
            end if;
         -- Clear the flags after having send the header.
         elsif(present_retire_state = TX_SEND_DATA) then
            fpga_temp_stale  <= '1';
            card_temp_stale  <= '1';
            psu_status_stale <= '1';
            box_temp_stale   <= '1';
         end if;
      end if;
   end process register_0;

   word_count_new <= word_count + 1;
   word_cntr: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         word_count <= 0;
      elsif(clk_i'event and clk_i = '1') then
         if(clr_word_count = '1') then
            word_count <= 0;
         elsif(ena_word_count = '1') then
            word_count <= word_count_new;
         end if;
      end if;
   end process word_cntr;

   over_temperature_o <= '1' when (ot_count >= MAX_NUM_OVERTEMPERATURES) else '0';
   ot_count_minus_1 <= ot_count - 1 when (ot_count /= 0) else 0;
   ot_count_plus_1 <= ot_count + 1;
   over_temperature_cntr: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         ot_count <= 0;
         dec_ot_count <= '0';
         timer_rst <= '0';

      elsif(clk_i'event and clk_i = '1') then

         if(time >= 4*HOUSEKEEPING_COMMAND_PERIOD) then
            dec_ot_count <= '1';
            timer_rst <= '1';
         else
            dec_ot_count <= '0';
            timer_rst <= '0';
         end if;

         if(clr_ot_count = '1') then
            ot_count <= 0;
         elsif(inc_ot_count = '1' and dec_ot_count = '0') then
            ot_count <= ot_count_plus_1;
         elsif(dec_ot_count = '1' and inc_ot_count = '0') then
            ot_count <= ot_count_minus_1;
         end if;
      end if;
   end process over_temperature_cntr;

   cmd_code_reg: reg
      generic map(
         WIDTH      => PACKET_WORD_WIDTH
      )
      port map(
         clk_i      => clk_i,
         rst_i      => rst_i,
         ena_i      => reg_en,
         reg_i      => cmd_code_i,
         reg_o      => cmd_code
      );

   card_addr_reg: reg
      generic map(
         WIDTH      => BB_CARD_ADDRESS_WIDTH
      )
      port map(
         clk_i      => clk_i,
         rst_i      => rst_i,
         ena_i      => reg_en,
         reg_i      => card_addr_i,
         reg_o      => card_addr
      );

   par_id_reg: reg
      generic map(
         WIDTH      => BB_PARAMETER_ID_WIDTH
      )
      port map(
         clk_i      => clk_i,
         rst_i      => rst_i,
         ena_i      => reg_en,
         reg_i      => par_id_i,
         reg_o      => par_id
      );

   data_size_reg_t: reg
      generic map(
         WIDTH      => BB_DATA_SIZE_WIDTH
      )
      port map(
         clk_i      => clk_i,
         rst_i      => rst_i,
         ena_i      => reg_en,
         reg_i      => data_size_i,
         reg_o      => data_size_t
      );

   -------------------------------------------------------------------
   -- data size calculation logic and registers
   -------------------------------------------------------------------
   psu_slv <= "000" & cards_to_report_i(PSUC);
   cc_slv  <= "000" & cards_to_report_i(CC);
   rc4_slv <= "000" & cards_to_report_i(RC4);
   rc3_slv <= "000" & cards_to_report_i(RC3);
   rc2_slv <= "000" & cards_to_report_i(RC2);
   rc1_slv <= "000" & cards_to_report_i(RC1);
   bc3_slv <= "000" & cards_to_report_i(BC3);
   bc2_slv <= "000" & cards_to_report_i(BC2);
   bc1_slv <= "000" & cards_to_report_i(BC1);
   ac_slv  <= "000" & cards_to_report_i(AC);

   num_cards_reg: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         num_cards <= (others => '0');
      elsif(clk_i'event and clk_i = '1') then
         if(num_cards_reg_en = '1') then
            if(cmd_code = DATA) then
               if(card_addr = ALL_READOUT_CARDS) then
                  if(rcs_to_report_data_i(5 downto 2) = "0000") then
                     num_cards <= x"0";
                  elsif(rcs_to_report_data_i(5 downto 2) = "1111") then
                     num_cards <= x"4";
                  elsif(rcs_to_report_data_i(5 downto 2) = "1000" or rcs_to_report_data_i(5 downto 2) = "0100" or
                     rcs_to_report_data_i(5 downto 2) = "0010" or rcs_to_report_data_i(5 downto 2) = "0001") then
                     num_cards <= x"1";
                  elsif(rcs_to_report_data_i(5 downto 2) = "0111" or rcs_to_report_data_i(5 downto 2) = "1011" or
                     rcs_to_report_data_i(5 downto 2) = "1101" or rcs_to_report_data_i(5 downto 2) = "1110") then
                     num_cards <= x"3";
                  else
                     num_cards <= x"2";
                  end if;
               -- Otherwise, if the card_addr is RC1/ RC2/ RC3/ RC4.
               else
                  num_cards <= x"1";
               end if;           
            else
               if(card_addr = NO_CARDS) then
                  num_cards <= x"0";
               elsif(card_addr = POWER_SUPPLY_CARD) then
                  num_cards <= psu_slv;
               elsif(card_addr = CLOCK_CARD) then
                  num_cards <= cc_slv;
               elsif(card_addr = READOUT_CARD_1) then
                  num_cards <= rc1_slv;
               elsif(card_addr = READOUT_CARD_2) then
                  num_cards <= rc2_slv;
               elsif(card_addr = READOUT_CARD_3) then
                  num_cards <= rc3_slv;
               elsif(card_addr = READOUT_CARD_4) then
                  num_cards <= rc4_slv;
               elsif(card_addr = BIAS_CARD_1) then
                  num_cards <= bc1_slv;
               elsif(card_addr = BIAS_CARD_2) then
                  num_cards <= bc2_slv;
               elsif(card_addr = BIAS_CARD_3) then
                  num_cards <= bc3_slv;
               elsif(card_addr = ADDRESS_CARD) then
                  num_cards <= ac_slv;
               elsif(card_addr = ALL_BIAS_CARDS) then
                  num_cards <= bc1_slv + bc2_slv + bc3_slv;
               elsif(card_addr = ALL_READOUT_CARDS) then
                  num_cards <= rc1_slv + rc2_slv + rc3_slv + rc4_slv;
               elsif(card_addr = ALL_FPGA_CARDS) then
                  num_cards <= bc1_slv + bc2_slv + bc3_slv + rc1_slv + rc2_slv + rc3_slv + rc4_slv + cc_slv + ac_slv;
               else
                  num_cards <= x"0";
               end if;
            end if;
         end if;
      end if;
   end process num_cards_reg;

   data_size <= conv_integer(datasize_reg_q);
   datasize_reg: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         datasize_reg_q <= (others => '0');
      elsif(clk_i'event and clk_i = '1') then
         if(datasize_reg_en = '1') then
            datasize_reg_q <= num_cards * data_size_t;
         end if;
      end if;
   end process datasize_reg;

   -------------------------------------------------------------------
   -- Frame Status Logic and Registers
   -------------------------------------------------------------------
   -- The error saver is for saving error flags that are reported out in the next reply packet
   error_saver: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         reset_event  <= '0';
         sync_box_err <= '0';
         internal_cmd <= '0';

      elsif(clk_i'event and clk_i = '1') then
         if(clr_reset = '1') then
            reset_event  <= '0';
         elsif(reg_en = '1') then
            reset_event  <= reset_event  or reset_event_i;
         end if;

         if(clr_sync_box_err = '1') then
            sync_box_err <= '0';
         elsif(reg_en = '1') then
            sync_box_err <= sync_box_err or sync_box_err_i;
         end if;

         if(reg_en = '1') then
            internal_cmd <= internal_cmd_i;
         end if;

      end if;
   end process error_saver;

   rc_bit_encoding <=
      "0001" when card_addr_i = READOUT_CARD_1    else
      "0010" when card_addr_i = READOUT_CARD_2    else
      "0100" when card_addr_i = READOUT_CARD_3    else
      "1000" when card_addr_i = READOUT_CARD_4    else
      "1111" when card_addr_i = ALL_READOUT_CARDS else
      "0000";

   -- integrate the cards address with the rcs_to_report_data register.
   -- This encoding must reflect the content of the data packets as put together by the reply_queue_sequencer.
   rcs_responding <= rc_bit_encoding and rcs_to_report_data_i(RC4) & rcs_to_report_data_i(RC3) & rcs_to_report_data_i(RC2) & rcs_to_report_data_i(RC1);

   -- all status bits, except reset and sync-box-error, are latched at frame boundaries and included in the status header of every data frame
   num_cols_reported <= conv_std_logic_vector(num_cols_to_read_i, num_cols_reported'length);   
   bit_status_i <= "00000000000" & 
                    data_timing_err_i & num_cols_reported & 
                    "00" & 
                    rcs_responding & dv_pulse_fibre_i &
                    "0000" & --formerly TES bias square wave level
                    active_clk_i & sync_box_err & sync_box_free_run_i & cmd_stop_i & last_frame_i;

   bit_status_reg: reg
      generic map(
         WIDTH      => BIT_STATUS_SIZE
      )
      port map(
         clk_i      => clk_i,
         rst_i      => rst_i,
         ena_i      => reg_en,
         reg_i      => bit_status_i,
         reg_o      => bit_status
      );

   frame_status <= bit_status;
   -------------------------------------------------------------------
   -- Miscellaneous Registers
   -------------------------------------------------------------------
   frame_seq_num_reg: reg
      generic map(
         WIDTH      => PACKET_WORD_WIDTH
      )
      port map(
         clk_i      => clk_i,
         rst_i      => rst_i,
         ena_i      => reg_en,
         reg_i      => frame_seq_num_i,
         reg_o      => frame_seq_num
      );

   issue_sync_num_reg: reg
      generic map(
         WIDTH      => SYNC_NUM_WIDTH
      )
      port map(
         clk_i      => clk_i,
         rst_i      => rst_i,
         ena_i      => reg_en,
         reg_i      => issue_sync_i,
         reg_o      => issue_sync_num
      );

   -- No need to register the error code here because it is registered in reply_queue_sequencer
   reset_and_error_code <= reset_event & error_code;

   -- In the new protocol, error_code will be include in every packet, and does not have to be duplicated from the header RAM
   -- When this is the case, we can get rid of the status_reg
   error_code_o <= '0' & status_q;
   status_reg : reg
      generic map(
         WIDTH => 31
      )
      port map(
         clk_i => clk_i,
         rst_i => rst_i,
         ena_i => status_en,
         reg_i => reset_and_error_code,
         reg_o => status_q
      );

   -- Some of the outputs to reply_translator and lvds_rx fifo's
   cmd_code_o          <= cmd_code;
   card_addr_o         <= card_addr;
--   frame_seq_num_o     <= frame_seq_num;
   param_id_o          <= par_id;

   ---------------------------------------------------------
   -- Retire FSM:
   ---------------------------------------------------------
   retire_state_FF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         present_retire_state <= IDLE;
      elsif(clk_i'event and clk_i = '1') then
         present_retire_state <= next_retire_state;
      end if;
   end process retire_state_FF;

   retire_state_NS: process(present_retire_state, cmd_to_retire_i, matched, ack_i,
      internal_cmd, word_rdy, word_count, data_size, cmd_code)
   begin
      -- Default Values
      next_retire_state <= present_retire_state;

      case present_retire_state is
         when IDLE =>
            if (cmd_to_retire_i = '1') then
               next_retire_state <= LATCH_CMD1;
            end if;

         when LATCH_CMD1 =>
            next_retire_state <= LATCH_CMD2;

         when LATCH_CMD2 =>
            next_retire_state <= RECEIVED;

         when RECEIVED =>
            next_retire_state <= WAIT_FOR_MATCH;

         when WAIT_FOR_MATCH =>
            if(matched = '1') then
               if(cmd_code = RESET) then
                  -- If we match the replies to a reset command, we forget about it,
                  -- and allow the next reply to overwrite the reset's reply.
                  next_retire_state <= IDLE;
               elsif(internal_cmd = '1') then
                  if(cmd_code = READ_BLOCK or cmd_code = DATA) then
                     -- If this is an internal command, store the data
                     next_retire_state <= STORE_ERRNO_HEADER_WORD;
                  else
                     next_retire_state <= INTERNAL_WB;
                  end if;
               else
                  next_retire_state <= TX_STATUS;
               end if;
            end if;

         when INTERNAL_WB =>
            next_retire_state <= DONE_HEADER_STORE;

         when TX_STATUS =>
            if (ack_i = '1') then
               -- If is a data frame
               if(cmd_code = DATA) then
                  next_retire_state <= TX_FRAME_STATUS;
               -- If this is a RB
               elsif(cmd_code = READ_BLOCK) then
                  next_retire_state <= REPLY;
               -- If this is a WB
               else
                  next_retire_state <= WAIT_FOR_ACK;
               end if;
            end if;

         when WAIT_FOR_ACK =>
            -- Should I be waiting here?
            next_retire_state <= IDLE;

         when STORE_ERRNO_HEADER_WORD =>
            next_retire_state <= NEXT_HEADER_WORD;

         when STORE_HEADER_WORD =>
            next_retire_state <= NEXT_HEADER_WORD;

         when NEXT_HEADER_WORD =>
            -- data_size + 1 compensates for the errno word we store for every internal command
            -- it's doubtful whether i need both of these conditions here..
            if(word_rdy = '1') and (word_count < data_size + 1) then
               next_retire_state <= PAUSE_HEADER_WORD;
            else
               next_retire_state <= DONE_HEADER_STORE;
            end if;

         when PAUSE_HEADER_WORD =>
            next_retire_state <= STORE_HEADER_WORD;

         when DONE_HEADER_STORE =>
            next_retire_state <= IDLE;

         when TX_FRAME_STATUS =>
            if(word_count >= 1) then
               next_retire_state <= TX_FRAME_SEQUENCE_NUM;
            end if;

         when TX_FRAME_SEQUENCE_NUM =>
            if(word_count >= 2) then
               next_retire_state <= TX_ROW_LEN;
            end if;

         when TX_ROW_LEN =>
            if(word_count >= 3) then
               next_retire_state <= TX_NUM_ROWS_TO_READ;
            end if;

         when TX_NUM_ROWS_TO_READ =>
            if(word_count >= 4) then
               next_retire_state <= TX_DATA_RATE;
            end if;

         when TX_DATA_RATE =>
            if(word_count >= 5) then
               next_retire_state <= TX_SYNC_NUM;
            end if;

         when TX_SYNC_NUM =>
            if(word_count >= 6) then
               next_retire_state <= TX_HEADER_VERSION;
            end if;

         when TX_HEADER_VERSION =>
            if(word_count >= 7) then
               next_retire_state <= TX_RAMP_VALUE;
            end if;

         when TX_RAMP_VALUE =>
            if(word_count >= 8) then
               next_retire_state <= TX_RAMP_CA_PI;
            end if;

         when TX_RAMP_CA_PI =>
            if(word_count >= 9) then
               next_retire_state <= TX_NUM_ROWS_SERVOED;
            end if;

         when TX_NUM_ROWS_SERVOED =>
            if(word_count >= 10) then
               next_retire_state <= TX_DV_NUM;
            end if;

         when TX_DV_NUM =>
            if(word_count >= 11) then
               next_retire_state <= TX_RUN_FILE_ID;
            end if;

         when TX_RUN_FILE_ID =>
            if(word_count >= 12) then
               next_retire_state <= TX_USER_WRITABLE;
            end if;

         when TX_USER_WRITABLE =>
            if(word_count >= 13) then
               next_retire_state <= TX_HEADER;
            end if;

         when TX_HEADER =>
            -- The "- 1" is to compensate for single words sent at the end of the header
            -- i.e. sync_num (TX_SYNC_NUM)
            if(word_count >= NUM_RAM_HEAD_WORDS) then
               next_retire_state <= TX_SEND_DATA;
            end if;

         when TX_SEND_DATA =>
            if(word_rdy = '0') then
               next_retire_state <= IDLE;
            end if;

         when REPLY =>
            if(word_rdy = '0') then
               next_retire_state <= IDLE;
            end if;

         when others =>
            next_retire_state <= IDLE;

      end case;
   end process;

   -- There should be a snapshot of each of these parameters for each command.
   -- In particular, external_dv_num_i should be registered by cmd_queue at the time of issue..maybe..
   with present_retire_state select
      data_o <=
         data_bus                                      when TX_STATUS | TX_SEND_DATA | REPLY,
         frame_status                                  when TX_FRAME_STATUS,
         frame_seq_num                                 when TX_FRAME_SEQUENCE_NUM,
         conv_std_logic_vector(row_len_i,32)           when TX_ROW_LEN,
         -- Should we embed num_cols_to_read in the header too?
         conv_std_logic_vector(num_rows_to_read_i, 32) when TX_NUM_ROWS_TO_READ,
         data_rate_i                                   when TX_DATA_RATE,
         issue_sync_num                                when TX_SYNC_NUM,
         DATA_PACKET_HEADER_REVISION                   when TX_HEADER_VERSION,
         step_value_i                                  when TX_RAMP_VALUE,
         ramp_card_addr_i(15 downto 0) & ramp_param_id_i(15 downto 0) when TX_RAMP_CA_PI,
         conv_std_logic_vector(num_rows_i,32)          when TX_NUM_ROWS_SERVOED,
         external_dv_num_i                             when TX_DV_NUM,
         run_file_id_i                                 when TX_RUN_FILE_ID,
         user_writable_i                               when TX_USER_WRITABLE,
         head_data                                     when TX_HEADER,
         (others => '0')                               when others;


   retire_state_out: process(present_retire_state, ack_i, data_size, word_rdy, cmd_code, matched,
      data_bus, reset_and_error_code, header_storage_address, header_tx_address, cmd_to_retire_i, word_count)
   begin
      -- Default values
      reg_en          <= '0';
      reset_ack_o     <= '0';
      sync_box_err_ack_o <= '1';
      cmd_rdy         <= '0';
      cmd_valid_o     <= '0';
      clr_reset       <= '0';
      clr_sync_box_err <= '0';

      hdr_ram_wren    <= '0';
      word_ack        <= '0';

      ena_word_count  <= '0';
      clr_word_count  <= '0';

      size_o          <=  0 ;
      rdy_o           <= '0';

      status_en       <= '0';
      cmd_sent_o      <= '0';

      hdr_ram_addr    <= (others => '0');
      hdr_ram_dat_in  <= (others => '0');

      num_cards_reg_en <= '0';
      datasize_reg_en <= '0';

      inc_ot_count <= '0';
      clr_ot_count <= '0';

      case present_retire_state is
         when IDLE =>
            clr_word_count <= '1';

            if (cmd_to_retire_i = '1') then
               reg_en          <= '1';
            end if;

         when LATCH_CMD1 =>
            num_cards_reg_en <= '1';

         when LATCH_CMD2 =>
            datasize_reg_en <= '1';

         when RECEIVED =>
            cmd_rdy         <= '1';

         when WAIT_FOR_MATCH =>
            -- The reset event bit is stored for every command including internal commands
            -- However it is only cleared once a reply is returned to the RTL PC, in TX_STATUS
            -- Thus, the flag may be set in the errno words for some internal command, but not others.
            -- Using this information, we determine during which internal command a reset occurred.
            -- The same goes for the sync box error flag, but it is reported out even more rarely -- only in data frames.
            status_en       <= '1';

            if(matched = '1') then
               if(cmd_code = RESET) then
                  cmd_sent_o <= '1';
               end if;
            end if;

         when TX_STATUS =>
            if(cmd_code = DATA) then
               size_o       <= data_size + NUM_RAM_HEAD_WORDS;
            else
               size_o       <= data_size;
            end if;

            if (ack_i = '1') then
               reset_ack_o     <= '1';
               sync_box_err_ack_o <= '1';
            end if;

            rdy_o           <= '1';
            -- By acking 'work_ack' we clear the front of the queue
            word_ack        <= ack_i;
            cmd_valid_o     <= '1';

            if (ack_i = '1') then
               -- If is a data frame
               if(cmd_code = DATA) then
                  clr_reset       <= '1';
                  -- The sync box error flag is only reported in data frame headers
                  clr_sync_box_err <= '1';
               -- If this is a RB
               elsif(cmd_code = READ_BLOCK) then
                  clr_reset       <= '1';
               -- If this is a WB
               else
                  clr_reset       <= '1';
               end if;
            end if;


         when WAIT_FOR_ACK =>
            cmd_sent_o <= '1';

         when INTERNAL_WB =>
            word_ack        <= '1';

         when STORE_ERRNO_HEADER_WORD =>
            hdr_ram_dat_in  <= '0' & reset_and_error_code;
            hdr_ram_wren    <= '1';
            ena_word_count  <= '1';
            hdr_ram_addr    <= header_storage_address;

         when STORE_HEADER_WORD =>
            hdr_ram_dat_in <= data_bus;
            hdr_ram_wren    <= '1';
            ena_word_count  <= '1';
            hdr_ram_addr    <= header_storage_address;

         when NEXT_HEADER_WORD =>
            -- Use this condition to determine if there is an over-temperature.
            if(word_rdy = '1') and (word_count < data_size + 1) then
               if(header_storage_address = FPGA_TEMP_ADDR_AC) then
                  if(data_bus > MAX_TEMP) then
                     inc_ot_count <= '1';
                  end if;
               elsif(header_storage_address = FPGA_TEMP_ADDR_BC1) then
                  if(data_bus > MAX_TEMP) then
                     inc_ot_count <= '1';
                  end if;
               elsif(header_storage_address = FPGA_TEMP_ADDR_BC2) then
                  if(data_bus > MAX_TEMP) then
                     inc_ot_count <= '1';
                  end if;
               elsif(header_storage_address = FPGA_TEMP_ADDR_BC3) then
                  if(data_bus > MAX_TEMP) then
                     inc_ot_count <= '1';
                  end if;
               elsif(header_storage_address = FPGA_TEMP_ADDR_RC1) then
                  if(data_bus > MAX_TEMP) then
                     inc_ot_count <= '1';
                  end if;
               elsif(header_storage_address = FPGA_TEMP_ADDR_RC2) then
                  if(data_bus > MAX_TEMP) then
                     inc_ot_count <= '1';
                  end if;
               elsif(header_storage_address = FPGA_TEMP_ADDR_RC3) then
                  if(data_bus > MAX_TEMP) then
                     inc_ot_count <= '1';
                  end if;
               elsif(header_storage_address = FPGA_TEMP_ADDR_RC4) then
                  if(data_bus > MAX_TEMP) then
                     inc_ot_count <= '1';
                  end if;
               elsif(header_storage_address = FPGA_TEMP_ADDR_CC) then
                  if(data_bus > MAX_TEMP) then
                     inc_ot_count <= '1';
                  end if;
               -------------------------------------------------------
               elsif(header_storage_address = CARD_TEMP_ADDR_AC) then
                  if(data_bus > MAX_TEMP) then
                     inc_ot_count <= '1';
                  end if;
               elsif(header_storage_address = CARD_TEMP_ADDR_BC1) then
                  if(data_bus > MAX_TEMP) then
                     inc_ot_count <= '1';
                  end if;
               elsif(header_storage_address = CARD_TEMP_ADDR_BC2) then
                  if(data_bus > MAX_TEMP) then
                     inc_ot_count <= '1';
                  end if;
               elsif(header_storage_address = CARD_TEMP_ADDR_BC3) then
                  if(data_bus > MAX_TEMP) then
                     inc_ot_count <= '1';
                  end if;
               elsif(header_storage_address = CARD_TEMP_ADDR_RC1) then
                  if(data_bus > MAX_TEMP) then
                     inc_ot_count <= '1';
                  end if;
               elsif(header_storage_address = CARD_TEMP_ADDR_RC2) then
                  if(data_bus > MAX_TEMP) then
                     inc_ot_count <= '1';
                  end if;
               elsif(header_storage_address = CARD_TEMP_ADDR_RC3) then
                  if(data_bus > MAX_TEMP) then
                     inc_ot_count <= '1';
                  end if;
               elsif(header_storage_address = CARD_TEMP_ADDR_RC4) then
                  if(data_bus > MAX_TEMP) then
                     inc_ot_count <= '1';
                  end if;
               elsif(header_storage_address = CARD_TEMP_ADDR_CC) then
                  if(data_bus > MAX_TEMP) then
                     inc_ot_count <= '1';
                  end if;
               end if;
            end if;

            hdr_ram_dat_in <= data_bus;
            word_ack       <= '1';
            hdr_ram_addr   <= header_storage_address;

         when PAUSE_HEADER_WORD =>
            hdr_ram_dat_in <= data_bus;
            hdr_ram_addr   <= header_storage_address;

         when DONE_HEADER_STORE =>
            cmd_sent_o <= '1';
            hdr_ram_addr   <= header_storage_address;

         when
         TX_FRAME_STATUS |
         TX_FRAME_SEQUENCE_NUM |
         TX_ROW_LEN |
         TX_NUM_ROWS_TO_READ |
         TX_DATA_RATE |
         TX_SYNC_NUM |
         TX_HEADER_VERSION |
         TX_RAMP_VALUE |
         TX_RAMP_CA_PI |
         TX_NUM_ROWS_SERVOED |
         TX_DV_NUM |
         TX_RUN_FILE_ID |
         TX_USER_WRITABLE =>

            rdy_o           <= '1';
            ena_word_count  <= ack_i;
            hdr_ram_addr    <= header_tx_address;

         when TX_HEADER =>
            rdy_o           <= '1';
            ena_word_count  <= ack_i;
            hdr_ram_addr    <= header_tx_address;

         when TX_SEND_DATA =>
            rdy_o           <= word_rdy;
            word_ack        <= ack_i;

            if(word_rdy = '0') then
               cmd_sent_o <= '1';
            end if;

         when REPLY =>
            rdy_o           <= word_rdy;
            word_ack        <= ack_i;

            if(word_rdy = '0') then
               cmd_sent_o <= '1';
            end if;

         when others =>
            null;

      end case;
   end process;


   rq_seq : reply_queue_sequencer
      port map(
         -- for debugging
         timer_trigger_o   => open,

         comm_clk_i        => comm_clk_i,
         clk_i             => clk_i,
         rst_i             => rst_i,

         -- Bus Backplane interface
         lvds_reply_all_a_i => lvds_reply_all_a_i,
         lvds_reply_all_b_i => lvds_reply_all_b_i,

         card_not_present_o => card_not_present_o,
         cards_to_report_i  => cards_to_report_i,
         rcs_to_report_data_i => rcs_to_report_data_i,
         dead_card_i          => dead_card_i,

         card_data_size_i  => data_size_t,  -- Add this to the pack file
         -- cmd_translator interface
         cmd_code_i        => cmd_code,
         par_id_i          => par_id,

         -- fibre interface:
         error_o           => error_code,
         data_o            => data_bus,
         rdy_o             => word_rdy,
         ack_i             => word_ack,

         -- cmd_queue interface:
         card_addr_i       => card_addr,
         cmd_valid_i       => cmd_rdy,
         matched_o         => matched
     );

end behav;