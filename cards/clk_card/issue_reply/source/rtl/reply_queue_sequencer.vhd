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
-- reply_queue_sequencer.vhd
--
-- Project:       SCUBA-2
-- Author:        Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Implementation of state machine that performs matching and sequencing
-- functions for reply queue.
--
-- Revision history:
--
-- $Log: reply_queue_sequencer.vhd,v $
-- Revision 1.39  2008/12/22 20:56:42  bburger
-- BB:  Added a second LVDS receiver for each card receiver block.
--
-- Revision 1.38  2008/11/21 20:14:10  bburger
-- BB: fixed a bug that would hang the FSM when sending commands to RC4
--
-- Revision 1.37  2008/10/25 00:24:54  bburger
-- BB:  Added support for RCS_TO_REPORT_DATA command
--
-- Revision 1.36  2008/10/17 00:33:29  bburger
-- BB:  modified the logic for reading the data from the reply queues; modified the logic for determining when to stop readout from a card queue to ease timing constraints.
--
-- Revision 1.35  2008/01/28 20:28:33  bburger
-- BB:
-- - No code content changes.  Just cosmetic re-spacing of if-else statements to make them more readable.
--
-- Revision 1.34  2007/12/18 20:36:40  bburger
-- BB:  Repaired the errno word logic that was reporting both card error and card not present at the same time.
--
-- Revision 1.33  2007/11/07 00:38:22  bburger
-- BB:  Added a comment.  No changes to the code.
--
-- Revision 1.32  2007/10/18 22:44:08  bburger
-- BB:
-- - The firmware now uses the spare LVDS Bus Backplane signals to determine which cards are there
-- - Simplified the logic for determining which bits are set in the error word.  Now, if a card is not present, it’s bit will always be asserted, regardless of if the reply is from it or not.  This is because card-not-present bits are now always valid, from start up.  Before, a command had to be issued to a card before the bits were valid.
-- - If a card is not present, a command to it will time out immediately, instead of waiting for the timeout period to expire.
-- - Added a buffer to the data pipeline to relax timing constraints on the synthesizer.
--
-- Revision 1.31  2007/07/24 23:27:47  bburger
-- BB:
-- - added lvds_reply_psu_a signal to sequencer interface for replies from the PSUC dispatch block
-- - removed the size_o signal from the sequencer interface, because the size of reply packets is now calculated in reply_queue
-- - trimmed the error_o bus from 31 bits to 30 bits to make room for stale_data and internal_reset_has_occurred bits that are incorporated in the reply_queue
-- - Fixed latency issues in the data pipeline.
--
-- Revision 1.30  2007/02/10 05:11:32  bburger
-- Bryce:  Changed the error logic to act more like the timing of the non-error logic.
--
-- Revision 1.29  2006/11/07 23:52:07  bburger
-- Bryce:  fixed a poorly coded conditiont that checked param_id instead of cmd_code
--
-- Revision 1.28  2006/11/03 01:10:53  bburger
-- Bryce:  Added support for the DATA cmd_code
--
-- Revision 1.27  2006/10/28 00:10:07  bburger
-- Bryce:  Moved some command timeout constants from here to issue_reply_pack
--
-- Revision 1.26  2006/09/15 00:48:36  bburger
-- Bryce:  Cleaned up the data word acknowledgement chain to speed things up.  Untested in hardware.  Data packets are un-simulated
--
-- Revision 1.25  2006/09/07 22:25:22  bburger
-- Bryce:  replace cmd_type (1-bit: read/write) interfaces and funtionality with cmd_code (32-bit: read_block/ write_block/ start/ stop/ reset) interface because reply_queue_sequencer needed to know to discard replies to reset commands
--
-- Revision 1.24  2006/09/06 00:27:11  bburger
-- Bryce:  added support for reset commands.  their replies are now discarded when they arrive from the backplane because the clock card has already sent a generic reply.
--
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
use work.issue_reply_pack.all;

entity reply_queue_sequencer is
port(
    -- for debugging
    timer_trigger_o   : out std_logic;

    comm_clk_i        : in std_logic;
    clk_i             : in std_logic;
    rst_i             : in std_logic;

    -- Bus Backplane interface
    lvds_reply_all_a_i : in std_logic_vector(9 downto 0);
    lvds_reply_all_b_i : in std_logic_vector(9 downto 0);
    card_not_present_o : out std_logic_vector(9 downto 0);
    cards_to_report_i  : in std_logic_vector(9 downto 0);
    rcs_to_report_data_i : in std_logic_vector(9 downto 0);

    card_data_size_i  : in std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);
    -- cmd_translator interface
    cmd_code_i        : in  std_logic_vector (FIBRE_PACKET_TYPE_WIDTH-1 downto 0);       -- the least significant 16-bits from the fibre packet
    par_id_i          : in std_logic_vector(BB_PARAMETER_ID_WIDTH-1 downto 0);

    -- reply_queue_retire interface:
    card_addr_i       : in std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0);
    cmd_valid_i       : in std_logic;
    matched_o         : out std_logic;
    timeout_o         : out std_logic;

    -- reply_translator interface:
    --size_o            : out integer;
    error_o           : out std_logic_vector(29 downto 0);
    data_o            : out std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
    rdy_o             : out std_logic;
    ack_i             : in std_logic);
end reply_queue_sequencer;

architecture rtl of reply_queue_sequencer is

   component reply_queue_receive
   port(
      clk_i          : in std_logic;
      comm_clk_i     : in std_logic;
      rst_i          : in std_logic;

      lvds_reply_a_i : in std_logic;
      lvds_reply_b_i : in std_logic;

      error_o        : out std_logic_vector(2 downto 0);   -- 3 error bits: Tx CRC error, Rx CRC error, Execute Error
      bad_preamble_o : out std_logic;

      data_o         : out std_logic_vector(31 downto 0);
      rdy_o          : out std_logic;
      pres_n_o       : out std_logic;
      ack_i          : in std_logic;
      clear_i        : in std_logic
   );
   end component;

   type seq_states is (IDLE, WAIT_FOR_REPLY, READ_AC, READ_BC1, READ_BC2, READ_BC3, MATCHED, TIMED_OUT, READ_PSU,
      READ_RC1, READ_RC2, READ_RC3, READ_RC4, READ_CC, DONE, STATUS_WORD, LATCH_ERROR, ERROR_WAIT1, ERROR_WAIT2, ERROR_WAIT3);
   signal pres_state       : seq_states;
   signal next_state       : seq_states;

   signal timeout          : std_logic;
   signal timeout_clr      : std_logic;
   signal timeout_count    : integer;

   signal timeout_reg_set  : std_logic;
   signal timeout_reg_clr  : std_logic;
   signal timeout_reg_q    : std_logic;

   signal card_ready        : std_logic_vector(9 downto 0);
   signal cards_addressed   : std_logic_vector(9 downto 0);
   --signal no_reply_yet     : std_logic_vector(9 downto 0);
--   signal wrong_card_error      : std_logic_vector(9 downto 0);
   -- Timeout:  Card Not Populated
   --signal card_not_populated  : std_logic_vector(9 downto 0);
   -- Timeout:  Execution Error
   signal timeout_error       : std_logic_vector(9 downto 0);
   signal detected_crc_error  : std_logic_vector(9 downto 0);
   signal half_done_error     : std_logic_vector(9 downto 0);
   signal crc_error           : std_logic_vector(9 downto 0);
   signal update_status       : std_logic;
--   signal card_rdy_or_np      : std_logic_vector(9 downto 0);
   signal card_should_reply   : std_logic_vector(9 downto 0);
   signal card_not_present    : std_logic_vector(9 downto 0);

   ---------------------------------------------------------
   -- FSM for latching out 0xDEADDEAD data
   ---------------------------------------------------------
   constant ERR_DATA       : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0) := x"FFFFFFFF";
   constant ZEROS          : std_logic_vector(16-BB_DATA_SIZE_WIDTH-1 downto 0) := (others => '0');

   -- output that indicates that there is an error word ready
   -- is asserted for each card that must reply only as long as needed to clock out the correct number of error words
   --signal err_rdy          : std_logic;
   signal word_count_ena   : std_logic;
   signal word_count_clr   : std_logic;
   signal word_count       : integer;
   signal word_count_new   : integer;
   signal card_data_size   : integer;

   ---------------------------------------------------------
   -- Debugging Logic
   ---------------------------------------------------------
   signal timer_count     : integer;

   ---------------------------------------------------------
   -- Reply_queue_receiver interface signals
   ---------------------------------------------------------
   signal data_buf_a         : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal data_buf_b         : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal data_buf_c         : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);

   signal ac_error           : std_logic_vector(2 downto 0);
   signal ac_data            : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal ac_rdy             : std_logic;
   signal ac_ack             : std_logic;
   signal ac_clear           : std_logic;
   signal ac_pres_n          : std_logic;

   signal bc1_error          : std_logic_vector(2 downto 0);
   signal bc1_data           : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal bc1_rdy            : std_logic;
   signal bc1_ack            : std_logic;
   signal bc1_clear          : std_logic;
   signal bc1_pres_n         : std_logic;

   signal bc2_error          : std_logic_vector(2 downto 0);
   signal bc2_data           : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal bc2_rdy            : std_logic;
   signal bc2_ack            : std_logic;
   signal bc2_clear          : std_logic;
   signal bc2_pres_n         : std_logic;

   signal bc3_error          : std_logic_vector(2 downto 0);
   signal bc3_data           : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal bc3_rdy            : std_logic;
   signal bc3_ack            : std_logic;
   signal bc3_clear          : std_logic;
   signal bc3_pres_n         : std_logic;

   signal rc1_error          : std_logic_vector(2 downto 0);
   signal rc1_data           : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal rc1_rdy            : std_logic;
   signal rc1_ack            : std_logic;
   signal rc1_clear          : std_logic;
   signal rc1_pres_n         : std_logic;

   signal rc2_error          : std_logic_vector(2 downto 0);
   signal rc2_data           : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal rc2_rdy            : std_logic;
   signal rc2_ack            : std_logic;
   signal rc2_clear          : std_logic;
   signal rc2_pres_n         : std_logic;

   signal rc3_error          : std_logic_vector(2 downto 0);
   signal rc3_data           : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal rc3_rdy            : std_logic;
   signal rc3_ack            : std_logic;
   signal rc3_clear          : std_logic;
   signal rc3_pres_n         : std_logic;

   signal rc4_error          : std_logic_vector(2 downto 0);
   signal rc4_data           : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal rc4_rdy            : std_logic;
   signal rc4_ack            : std_logic;
   signal rc4_clear          : std_logic;
   signal rc4_pres_n         : std_logic;

   signal cc_error           : std_logic_vector(2 downto 0);
   signal cc_data            : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal cc_rdy             : std_logic;
   signal cc_ack             : std_logic;
   signal cc_clear           : std_logic;
   signal cc_pres_n          : std_logic;

   signal psu_error          : std_logic_vector(2 downto 0);
   signal psu_data           : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal psu_rdy            : std_logic;
   signal psu_ack            : std_logic;
   signal psu_clear          : std_logic;
   signal psu_pres_n         : std_logic;

begin
   ---------------------------------------------------------
   -- Receive FIFO Instantiations
   ---------------------------------------------------------
   rx_ac : reply_queue_receive
      port map(
         clk_i          => clk_i,
         comm_clk_i     => comm_clk_i,
         rst_i          => rst_i,
         -- Note:  One can only make partial assignments like this for outputs
         lvds_reply_a_i => lvds_reply_all_a_i(AC),
         lvds_reply_b_i => lvds_reply_all_b_i(AC),
         error_o        => ac_error,
         data_o         => ac_data,
         rdy_o          => ac_rdy,
         pres_n_o       => ac_pres_n,
         ack_i          => ac_ack,
         clear_i        => ac_clear
      );

   rx_bc1 : reply_queue_receive
      port map(
         clk_i          => clk_i,
         comm_clk_i     => comm_clk_i,
         rst_i          => rst_i,
         lvds_reply_a_i => lvds_reply_all_a_i(BC1),
         lvds_reply_b_i => lvds_reply_all_b_i(BC1),
         error_o        => bc1_error,
         data_o         => bc1_data,
         rdy_o          => bc1_rdy,
         pres_n_o       => bc1_pres_n,
         ack_i          => bc1_ack,
         clear_i        => bc1_clear
      );

   rx_bc2 : reply_queue_receive
      port map(
         clk_i          => clk_i,
         comm_clk_i     => comm_clk_i,
         rst_i          => rst_i,
         lvds_reply_a_i => lvds_reply_all_a_i(BC2),
         lvds_reply_b_i => lvds_reply_all_b_i(BC2),
         error_o        => bc2_error,
         data_o         => bc2_data,
         rdy_o          => bc2_rdy,
         pres_n_o       => bc2_pres_n,
         ack_i          => bc2_ack,
         clear_i        => bc2_clear
      );

   rx_bc3 : reply_queue_receive
      port map(
         clk_i          => clk_i,
         comm_clk_i     => comm_clk_i,
         rst_i          => rst_i,
         lvds_reply_a_i => lvds_reply_all_a_i(BC3),
         lvds_reply_b_i => lvds_reply_all_b_i(BC3),
         error_o        => bc3_error,
         data_o         => bc3_data,
         rdy_o          => bc3_rdy,
         pres_n_o       => bc3_pres_n,
         ack_i          => bc3_ack,
         clear_i        => bc3_clear
      );

   rx_rc1 : reply_queue_receive
      port map(
         clk_i          => clk_i,
         comm_clk_i     => comm_clk_i,
         rst_i          => rst_i,
         lvds_reply_a_i => lvds_reply_all_a_i(RC1),
         lvds_reply_b_i => lvds_reply_all_b_i(RC1),
         error_o        => rc1_error,
         data_o         => rc1_data,
         rdy_o          => rc1_rdy,
         pres_n_o       => rc1_pres_n,
         ack_i          => rc1_ack,
         clear_i        => rc1_clear
      );

   rx_rc2 : reply_queue_receive
      port map(
         clk_i          => clk_i,
         comm_clk_i     => comm_clk_i,
         rst_i          => rst_i,
         lvds_reply_a_i => lvds_reply_all_a_i(RC2),
         lvds_reply_b_i => lvds_reply_all_b_i(RC2),
         error_o        => rc2_error,
         data_o         => rc2_data,
         rdy_o          => rc2_rdy,
         pres_n_o       => rc2_pres_n,
         ack_i          => rc2_ack,
         clear_i        => rc2_clear
      );

   rx_rc3 : reply_queue_receive
      port map(
         clk_i          => clk_i,
         comm_clk_i     => comm_clk_i,
         rst_i          => rst_i,
         lvds_reply_a_i => lvds_reply_all_a_i(RC3),
         lvds_reply_b_i => lvds_reply_all_b_i(RC3),
         error_o        => rc3_error,
         data_o         => rc3_data,
         rdy_o          => rc3_rdy,
         pres_n_o       => rc3_pres_n,
         ack_i          => rc3_ack,
         clear_i        => rc3_clear
      );

   rx_rc4 : reply_queue_receive
      port map(
         clk_i          => clk_i,
         comm_clk_i     => comm_clk_i,
         rst_i          => rst_i,
         lvds_reply_a_i => lvds_reply_all_a_i(RC4),
         lvds_reply_b_i => lvds_reply_all_b_i(RC4),
         error_o        => rc4_error,
         data_o         => rc4_data,
         rdy_o          => rc4_rdy,
         pres_n_o       => rc4_pres_n,
         ack_i          => rc4_ack,
         clear_i        => rc4_clear
      );

   rx_cc : reply_queue_receive
      port map(
         clk_i          => clk_i,
         comm_clk_i     => comm_clk_i,
         rst_i          => rst_i,
         lvds_reply_a_i => lvds_reply_all_a_i(CC),
         lvds_reply_b_i => lvds_reply_all_b_i(CC),
         error_o        => cc_error,
         data_o         => cc_data,
         rdy_o          => cc_rdy,
         pres_n_o       => cc_pres_n,
         ack_i          => cc_ack,
         clear_i        => cc_clear
      );

   rx_psu : reply_queue_receive
      port map(
         clk_i          => clk_i,
         comm_clk_i     => comm_clk_i,
         rst_i          => rst_i,
         lvds_reply_a_i => lvds_reply_all_a_i(PSUC),
         lvds_reply_b_i => lvds_reply_all_b_i(PSUC),
         error_o        => psu_error,
         data_o         => psu_data,
         rdy_o          => psu_rdy,
         pres_n_o       => psu_pres_n,
         ack_i          => psu_ack,
         clear_i        => psu_clear
      );

   ---------------------------------------------------------
   -- Continuous Assignments
   ---------------------------------------------------------
   error_o <=
      -- The bit order from left to right of the following lines is:
      -- (a) Timeout because card not present
      -- (b) CRC error or other timeout error
      -- (c) Wishbone execution error
      card_not_present(AC)   & crc_error(AC)   & ac_error(0)  &
      card_not_present(BC1)  & crc_error(BC1)  & bc1_error(0) &
      card_not_present(BC2)  & crc_error(BC2)  & bc2_error(0) &
      card_not_present(BC3)  & crc_error(BC3)  & bc3_error(0) &
      card_not_present(RC1)  & crc_error(RC1)  & rc1_error(0) &
      card_not_present(RC2)  & crc_error(RC2)  & rc2_error(0) &
      card_not_present(RC3)  & crc_error(RC3)  & rc3_error(0) &
      card_not_present(RC4)  & crc_error(RC4)  & rc4_error(0) &
      card_not_present(CC)   & crc_error(CC)   & cc_error(0)  &
      card_not_present(PSUC) & crc_error(PSUC) & psu_error(0);

   ---------------------------------------------------------
   -- Error FSM
   ---------------------------------------------------------
   card_data_size <= conv_integer(card_data_size_i);
   word_count_new <= word_count + 1;
   err_counter: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         word_count <= 0;
      elsif(clk_i'event and clk_i = '1') then
         if(word_count_clr = '1') then
            word_count <= 0;
         elsif(word_count_ena = '1') then
            word_count <= word_count_new;
         end if;
      end if;
   end process err_counter;

   ---------------------------------------------------------
   -- Status Word Registers
   ---------------------------------------------------------
   status_word_ff: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         -- Resetting to '1' to clear the slate and record whether a card ever replies.
--         wrong_card_error <= (others => '0');
         timeout_error     <= (others => '0');
         crc_error         <= (others => '0');
         card_should_reply <= (others => '0');

      elsif(clk_i'event and clk_i = '1') then
         -- Cascaded logic
         -- The states are for sequential stages of the logic
         -- The LATCH_ERROR state occurs after either all expected replies have been received, or after a timeout.
         if(pres_state = LATCH_ERROR) then
            -- The Carnot Maps for this logic are Bryce Burger's SCUBA2 Logbook #8, near the beginning of the book.
            -- wrong_card_error indicates that a card has responded in part or in full to the command that wasn't supposed to.
            -- This error is not currently reported..
--            wrong_card_error  <= ((half_done_error or card_ready) and (not cards_addressed));

            -- card_should_reply is asserted when the card has been addressed by a command, and the Clock Card detects that is is populated in the subrack
            card_should_reply <= cards_addressed and (not card_not_present);

         elsif(pres_state = ERROR_WAIT1) then
            -- timeout_error indicates that the receiver has not received an answer from a card is populated and has been addressed.
            timeout_error <= card_should_reply and (not card_ready);

         elsif(pres_state = ERROR_WAIT2) then
            -- crc_error is any sort of error that is not due to a card not being populated or a wishbone error.
            crc_error <= (detected_crc_error or timeout_error);

         else
--            wrong_card_error <= wrong_card_error;
            timeout_error     <= timeout_error;
            crc_error         <= crc_error;
            card_should_reply <= card_should_reply;
         end if;
      end if;
   end process;

   card_not_present_o <= card_not_present;
   card_not_present <=
      ac_pres_n &
      bc1_pres_n &
      bc2_pres_n &
      bc3_pres_n &
      rc1_pres_n &
      rc2_pres_n &
      rc3_pres_n &
      rc4_pres_n &
      cc_pres_n &
      psu_pres_n;
  
--   card_not_present(AC)
--   card_not_present(BC1)
--   card_not_present(BC2)
--   card_not_present(BC3)
--   card_not_present(RC1)
--   card_not_present(RC2)
--   card_not_present(RC3)
--   card_not_present(RC4)
--   card_not_present(CC)
--   card_not_present(PSUC)
   
   -- The card-error bit is set if the receiver has detected a CRC error over the backplane in either direction
   detected_crc_error <=
      ac_error(1) &
      bc1_error(1) &
      bc2_error(1) &
      bc3_error(1) &
      rc1_error(1) &
      rc2_error(1) &
      rc3_error(1) &
      rc4_error(1) &
      cc_error(1) &
      psu_error(1);

   -- The half-done bit is set if the receiver has started receiving something, but has not finished
   half_done_error <=
      ac_error(2) &
      bc1_error(2) &
      bc2_error(2) &
      bc3_error(2) &
      rc1_error(2) &
      rc2_error(2) &
      rc3_error(2) &
      rc4_error(2) &
      cc_error(2) &
      psu_error(2);

   -- Indicates which cards have responded fully to a command
   card_ready <=
      ac_rdy &
      bc1_rdy &
      bc2_rdy &
      bc3_rdy &
      rc1_rdy &
      rc2_rdy &
      rc3_rdy &
      rc4_rdy &
      cc_rdy &
      psu_rdy;

   cards_addressed <=
      "0000000000" when (card_addr_i = NO_CARDS) else
      "0000000001" when (card_addr_i = POWER_SUPPLY_CARD) else
      "0000000010" when (card_addr_i = CLOCK_CARD) else
      "0000000100" when (card_addr_i = READOUT_CARD_4) else
      "0000001000" when (card_addr_i = READOUT_CARD_3) else
      "0000010000" when (card_addr_i = READOUT_CARD_2) else
      "0000100000" when (card_addr_i = READOUT_CARD_1) else
      "0001000000" when (card_addr_i = BIAS_CARD_3) else
      "0010000000" when (card_addr_i = BIAS_CARD_2) else
      "0100000000" when (card_addr_i = BIAS_CARD_1) else
      "1000000000" when (card_addr_i = ADDRESS_CARD) else
      "0111000000" when (card_addr_i = ALL_BIAS_CARDS) else
      "0000111100" when (card_addr_i = ALL_READOUT_CARDS) else
      "1111111110" when (card_addr_i = ALL_FPGA_CARDS) else
      "0000000000";

   ---------------------------------------------------------
   -- Registers
   ---------------------------------------------------------
   timeout_reg: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         timeout_reg_q <= '0';
      elsif(clk_i'event and clk_i = '1') then
         if(timeout_reg_clr = '1') then
            timeout_reg_q <= '0';
         elsif(timeout_reg_set = '1') then
            timeout_reg_q <= '1';
         end if;
      end if;
   end process timeout_reg;

   ---------------------------------------------------------
   -- Debugging Logic
   ---------------------------------------------------------
   -- This timer will allow us to trigger earlier to monitor the timeout of commands with little data.
   -- The purpose of time is to provide a trigger to track down unreliablility issues.
   timer_trigger_o <= '1' when timer_count >= 600 else '0';
   trigger_timer : us_timer
      port map(
         clk           => clk_i,
         timer_reset_i => timeout_clr,
         timer_count_o => timer_count
      );

   ---------------------------------------------------------
   -- Command Timeout Logic
   ---------------------------------------------------------
   -- timeout_clr is exercised such that the timer only counts when there is a command in flight.
   timeout_timer : us_timer
   port map(clk => clk_i,
            timer_reset_i => timeout_clr,
            timer_count_o => timeout_count);

   timeout <= '1' when
      (cmd_code_i /= DATA and timeout_count >= CMD_TIMEOUT_LIMIT) or
      (cmd_code_i = DATA and timeout_count >= DATA_TIMEOUT_LIMIT) else '0';  -- TIMEOUT_LIMIT is defined in reply_queue_pack

   ---------------------------------------------------------
   -- Sequencer FSM
   ---------------------------------------------------------
   state_FF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         pres_state <= IDLE;
      elsif(clk_i'event and clk_i = '1') then
         pres_state <= next_state;
      end if;
   end process state_FF;

   state_NS: process(pres_state, timeout, cmd_valid_i, card_addr_i, ack_i, word_count, card_data_size,
      ac_rdy, bc1_rdy, bc2_rdy, bc3_rdy, rc1_rdy, rc2_rdy, rc3_rdy, rc4_rdy, cc_rdy, psu_rdy, cmd_code_i,
      card_not_present, cards_to_report_i, rcs_to_report_data_i)
   begin
      -- Default Assignments
      next_state <= pres_state;

      case pres_state is
         when IDLE =>
            if(cmd_valid_i = '1') then
               next_state <= WAIT_FOR_REPLY;
            else
               next_state <= IDLE;
            end if;

         when WAIT_FOR_REPLY =>
            if((card_addr_i = CLOCK_CARD and
                  (cc_rdy = '1'  or card_not_present(CC) = '1')) or
               (card_addr_i = POWER_SUPPLY_CARD and
                  (psu_rdy = '1' or card_not_present(PSUC) = '1')) or
               (card_addr_i = ADDRESS_CARD and
                  (ac_rdy = '1'  or card_not_present(AC) = '1')) or
               (card_addr_i = BIAS_CARD_1 and
                  (bc1_rdy = '1' or card_not_present(BC1) = '1')) or
               (card_addr_i = BIAS_CARD_2 and
                  (bc2_rdy = '1' or card_not_present(BC2) = '1')) or
               (card_addr_i = BIAS_CARD_3 and
                  (bc3_rdy = '1' or card_not_present(BC3) = '1')) or
               (card_addr_i = READOUT_CARD_1 and
                  (rc1_rdy = '1' or card_not_present(RC1) = '1')) or
               (card_addr_i = READOUT_CARD_2 and
                  (rc2_rdy = '1' or card_not_present(RC2) = '1')) or
               (card_addr_i = READOUT_CARD_3 and
                  (rc3_rdy = '1' or card_not_present(RC3) = '1')) or
               (card_addr_i = READOUT_CARD_4 and
                  (rc4_rdy = '1' or card_not_present(RC4) = '1')) or
               (card_addr_i = ALL_BIAS_CARDS and
                  (bc1_rdy = '1' or card_not_present(BC1) = '1') and
                  (bc2_rdy = '1' or card_not_present(BC2) = '1') and
                  (bc3_rdy = '1' or card_not_present(BC3) = '1')) or
               (card_addr_i = ALL_READOUT_CARDS and
                  (rc1_rdy = '1' or card_not_present(RC1) = '1') and
                  (rc2_rdy = '1' or card_not_present(RC2) = '1') and
                  (rc3_rdy = '1' or card_not_present(RC3) = '1') and
                  (rc4_rdy = '1' or card_not_present(RC4) = '1')) or
               (card_addr_i = ALL_FPGA_CARDS and
                  (cc_rdy = '1' or card_not_present(CC) = '1') and
                  (ac_rdy = '1' or card_not_present(AC) = '1') and
                  (bc1_rdy = '1' or card_not_present(BC1) = '1') and
                  (bc2_rdy = '1' or card_not_present(BC2) = '1') and
                  (bc3_rdy = '1' or card_not_present(BC3) = '1') and
                  (rc1_rdy = '1' or card_not_present(RC1) = '1') and
                  (rc2_rdy = '1' or card_not_present(RC2) = '1') and
                  (rc3_rdy = '1' or card_not_present(RC3) = '1') and
                  (rc4_rdy = '1' or card_not_present(RC4) = '1'))) then
                  next_state <= LATCH_ERROR;
               elsif(timeout = '1') then
                  next_state <= TIMED_OUT;
               else
                  next_state <= WAIT_FOR_REPLY;
               end if;

         when LATCH_ERROR =>
               next_state <= ERROR_WAIT1;

         when ERROR_WAIT1 =>
               next_state <= ERROR_WAIT2;

         when ERROR_WAIT2 =>
               next_state <= ERROR_WAIT3;

         when ERROR_WAIT3 =>
               next_state <= MATCHED;

         when MATCHED =>
            if(cmd_code_i = RESET) then
               next_state <= DONE;
            else
               next_state <= STATUS_WORD;
            end if;

         when STATUS_WORD =>
            -- If the status word is acknowledged
            if(ack_i = '1') then
               -- If there is data to read
               if(cmd_code_i = READ_BLOCK) then
                  if(card_addr_i = POWER_SUPPLY_CARD and cards_to_report_i(PSUC) = '1') then
                     next_state <= READ_PSU;
                  elsif(card_addr_i = CLOCK_CARD and cards_to_report_i(CC) = '1') then
                     next_state <= READ_CC;
                  elsif(card_addr_i = BIAS_CARD_1 and cards_to_report_i(BC1) = '1') then
                     next_state <= READ_BC1;
                  elsif(card_addr_i = BIAS_CARD_2 and cards_to_report_i(BC2) = '1') then
                     next_state <= READ_BC2;
                  elsif(card_addr_i = BIAS_CARD_3 and cards_to_report_i(BC3) = '1') then
                     next_state <= READ_BC3;
                  elsif(card_addr_i = ADDRESS_CARD and cards_to_report_i(AC) = '1') then
                     next_state <= READ_AC;
                  elsif(card_addr_i = READOUT_CARD_1 and cards_to_report_i(RC1) = '1') then
                     next_state <= READ_RC1;
                  elsif(card_addr_i = READOUT_CARD_2 and cards_to_report_i(RC2) = '1') then
                     next_state <= READ_RC2;
                  elsif(card_addr_i = READOUT_CARD_3 and cards_to_report_i(RC3) = '1') then
                     next_state <= READ_RC3;
                  elsif(card_addr_i = READOUT_CARD_4 and cards_to_report_i(RC4) = '1') then
                     next_state <= READ_RC4;
                  elsif(card_addr_i = ALL_BIAS_CARDS) then
                     if(cards_to_report_i(BC1) = '1') then
                        next_state <= READ_BC1;
                     elsif(cards_to_report_i(BC2) = '1') then
                        next_state <= READ_BC2;
                     elsif(cards_to_report_i(BC3) = '1') then
                        next_state <= READ_BC3;
                     else
                        next_state <= DONE;
                     end if;
                  elsif(card_addr_i = ALL_FPGA_CARDS) then
                     if(cards_to_report_i(AC) = '1') then
                        next_state <= READ_AC;
                     elsif(cards_to_report_i(BC1) = '1') then
                        next_state <= READ_BC1;
                     elsif(cards_to_report_i(BC2) = '1') then
                        next_state <= READ_BC2;
                     elsif(cards_to_report_i(BC3) = '1') then
                        next_state <= READ_BC3;
                     elsif(cards_to_report_i(RC1) = '1') then
                        next_state <= READ_RC1;
                     elsif(cards_to_report_i(RC2) = '1') then
                        next_state <= READ_RC2;
                     elsif(cards_to_report_i(RC3) = '1') then
                        next_state <= READ_RC3;
                     elsif(cards_to_report_i(RC4) = '1') then
                        next_state <= READ_RC4;
                     elsif(cards_to_report_i(CC) = '1') then
                        next_state <= READ_CC;
                     else
                        next_state <= DONE;
                     end if;
                  elsif(card_addr_i = ALL_READOUT_CARDS) then
                     if(cards_to_report_i(RC1) = '1') then
                        next_state <= READ_RC1;
                     elsif(cards_to_report_i(RC2) = '1') then
                        next_state <= READ_RC2;
                     elsif(cards_to_report_i(RC3) = '1') then
                        next_state <= READ_RC3;
                     elsif(cards_to_report_i(RC4) = '1') then
                        next_state <= READ_RC4;
                     else
                        next_state <= DONE;
                     end if;
                  -- Otherwise, we are done
                  else
                     next_state <= DONE;
                  end if;
               elsif(cmd_code_i = DATA) then
                  if(card_addr_i = READOUT_CARD_1 and rcs_to_report_data_i(RC1) = '1') then
                     next_state <= READ_RC1;
                  elsif(card_addr_i = READOUT_CARD_2 and rcs_to_report_data_i(RC2) = '1') then
                     next_state <= READ_RC2;
                  elsif(card_addr_i = READOUT_CARD_3 and rcs_to_report_data_i(RC3) = '1') then
                     next_state <= READ_RC3;
                  elsif(card_addr_i = READOUT_CARD_4 and rcs_to_report_data_i(RC4) = '1') then
                     next_state <= READ_RC4;
                  elsif(card_addr_i = ALL_READOUT_CARDS) then
                     if(rcs_to_report_data_i(RC1) = '1') then
                        next_state <= READ_RC1;
                     elsif(rcs_to_report_data_i(RC2) = '1') then
                        next_state <= READ_RC2;
                     elsif(rcs_to_report_data_i(RC3) = '1') then
                        next_state <= READ_RC3;
                     elsif(rcs_to_report_data_i(RC4) = '1') then
                        next_state <= READ_RC4;
                     else
                        next_state <= DONE;
                     end if;
                  -- Otherwise, we are done
                  else
                     next_state <= DONE;
                  end if;
               else
                  next_state <= DONE;
               end if;
            end if;

         -------------------------------------------------------------------------------
         -- We get into these states only if there is definitely data to read!
         -------------------------------------------------------------------------------
         when READ_AC =>
            if(word_count >= card_data_size) then
               if(card_addr_i = ALL_FPGA_CARDS) then
                  if(cards_to_report_i(BC1) = '1') then
                     next_state <= READ_BC1;
                  elsif(cards_to_report_i(BC2) = '1') then
                     next_state <= READ_BC2;
                  elsif(cards_to_report_i(BC3) = '1') then
                     next_state <= READ_BC3;
                  elsif(cards_to_report_i(RC1) = '1') then
                     next_state <= READ_RC1;
                  elsif(cards_to_report_i(RC2) = '1') then
                     next_state <= READ_RC2;
                  elsif(cards_to_report_i(RC3) = '1') then
                     next_state <= READ_RC3;
                  elsif(cards_to_report_i(RC4) = '1') then
                     next_state <= READ_RC4;
                  elsif(cards_to_report_i(CC) = '1') then
                     next_state <= READ_CC;
                  else
                     next_state <= DONE;
                  end if;
               else
                  next_state <= DONE;
               end if;
            end if;

         when READ_BC1 =>
            if(word_count >= card_data_size) then
               if(card_addr_i = ALL_FPGA_CARDS) then
                  if(cards_to_report_i(BC2) = '1') then
                     next_state <= READ_BC2;
                  elsif(cards_to_report_i(BC3) = '1') then
                     next_state <= READ_BC3;
                  elsif(cards_to_report_i(RC1) = '1') then
                     next_state <= READ_RC1;
                  elsif(cards_to_report_i(RC2) = '1') then
                     next_state <= READ_RC2;
                  elsif(cards_to_report_i(RC3) = '1') then
                     next_state <= READ_RC3;
                  elsif(cards_to_report_i(RC4) = '1') then
                     next_state <= READ_RC4;
                  elsif(cards_to_report_i(CC) = '1') then
                     next_state <= READ_CC;
                  else
                     next_state <= DONE;
                  end if;
               elsif(card_addr_i = ALL_BIAS_CARDS) then
                  if(cards_to_report_i(BC2) = '1') then
                     next_state <= READ_BC2;
                  elsif(cards_to_report_i(BC3) = '1') then
                     next_state <= READ_BC3;
                  else
                     next_state <= DONE;
                  end if;
               else
                  next_state <= DONE;
               end if;
            end if;

         when READ_BC2 =>
            if(word_count >= card_data_size) then
               if(card_addr_i = ALL_FPGA_CARDS) then
                  if(cards_to_report_i(BC3) = '1') then
                     next_state <= READ_BC3;
                  elsif(cards_to_report_i(RC1) = '1') then
                     next_state <= READ_RC1;
                  elsif(cards_to_report_i(RC2) = '1') then
                     next_state <= READ_RC2;
                  elsif(cards_to_report_i(RC3) = '1') then
                     next_state <= READ_RC3;
                  elsif(cards_to_report_i(RC4) = '1') then
                     next_state <= READ_RC4;
                  elsif(cards_to_report_i(CC) = '1') then
                     next_state <= READ_CC;
                  else
                     next_state <= DONE;
                  end if;
               elsif(card_addr_i = ALL_BIAS_CARDS) then
                  if(cards_to_report_i(BC3) = '1') then
                     next_state <= READ_BC3;
                  else
                     next_state <= DONE;
                  end if;
               else
                  next_state <= DONE;
               end if;
            end if;

         when READ_BC3 =>
            if(word_count >= card_data_size) then
               if(card_addr_i = ALL_FPGA_CARDS) then
                  if(cards_to_report_i(RC1) = '1') then
                     next_state <= READ_RC1;
                  elsif(cards_to_report_i(RC2) = '1') then
                     next_state <= READ_RC2;
                  elsif(cards_to_report_i(RC3) = '1') then
                     next_state <= READ_RC3;
                  elsif(cards_to_report_i(RC4) = '1') then
                     next_state <= READ_RC4;
                  elsif(cards_to_report_i(CC) = '1') then
                     next_state <= READ_CC;
                  else
                     next_state <= DONE;
                  end if;
               elsif(card_addr_i = ALL_BIAS_CARDS) then
                  next_state <= DONE;
               else
                  next_state <= DONE;
               end if;
            end if;

         when READ_RC1 =>
            if(word_count >= card_data_size) then
               if(cmd_code_i = READ_BLOCK) then
                  if(card_addr_i = ALL_FPGA_CARDS) then
                     if(cards_to_report_i(RC2) = '1') then
                        next_state <= READ_RC2;
                     elsif(cards_to_report_i(RC3) = '1') then
                        next_state <= READ_RC3;
                     elsif(cards_to_report_i(RC4) = '1') then
                        next_state <= READ_RC4;
                     elsif(cards_to_report_i(CC) = '1') then
                        next_state <= READ_CC;
                     else
                        next_state <= DONE;
                     end if;
                  elsif(card_addr_i = ALL_READOUT_CARDS) then
                     if(cards_to_report_i(RC2) = '1') then
                        next_state <= READ_RC2;
                     elsif(cards_to_report_i(RC3) = '1') then
                        next_state <= READ_RC3;
                     elsif(cards_to_report_i(RC4) = '1') then
                        next_state <= READ_RC4;
                     else
                        next_state <= DONE;
                     end if;
                  else
                     next_state <= DONE;
                  end if;
               else -- if (cmd_code_i = DATA)
                  if(card_addr_i = ALL_READOUT_CARDS) then
                     if(rcs_to_report_data_i(RC2) = '1') then
                        next_state <= READ_RC2;
                     elsif(rcs_to_report_data_i(RC3) = '1') then
                        next_state <= READ_RC3;
                     elsif(rcs_to_report_data_i(RC4) = '1') then
                        next_state <= READ_RC4;
                     else
                        next_state <= DONE;
                     end if;
                  -- Otherwise, we are done
                  else
                     next_state <= DONE;
                  end if;
               end if;
            end if;

         when READ_RC2 =>
            if(word_count >= card_data_size) then
               if(cmd_code_i = READ_BLOCK) then
                  if(card_addr_i = ALL_FPGA_CARDS) then
                     if(cards_to_report_i(RC3) = '1') then
                        next_state <= READ_RC3;
                     elsif(cards_to_report_i(RC4) = '1') then
                        next_state <= READ_RC4;
                     elsif(cards_to_report_i(CC) = '1') then
                        next_state <= READ_CC;
                     else
                        next_state <= DONE;
                     end if;
                  elsif(card_addr_i = ALL_READOUT_CARDS) then
                     if(cards_to_report_i(RC3) = '1') then
                        next_state <= READ_RC3;
                     elsif(cards_to_report_i(RC4) = '1') then
                        next_state <= READ_RC4;
                     else
                        next_state <= DONE;
                     end if;
                  else
                     next_state <= DONE;
                  end if;
               else -- if (cmd_code_i = DATA)
                  if(card_addr_i = ALL_READOUT_CARDS) then
                     if(rcs_to_report_data_i(RC3) = '1') then
                        next_state <= READ_RC3;
                     elsif(rcs_to_report_data_i(RC4) = '1') then
                        next_state <= READ_RC4;
                     else
                        next_state <= DONE;
                     end if;
                  -- Otherwise, we are done
                  else
                     next_state <= DONE;
                  end if;
               end if;
            end if;

         when READ_RC3 =>
            if(word_count >= card_data_size) then
               if(cmd_code_i = READ_BLOCK) then
                  if(card_addr_i = ALL_FPGA_CARDS) then
                     if(cards_to_report_i(RC4) = '1') then
                        next_state <= READ_RC4;
                     elsif(cards_to_report_i(CC) = '1') then
                        next_state <= READ_CC;
                     else
                        next_state <= DONE;
                     end if;
                  elsif(card_addr_i = ALL_READOUT_CARDS) then
                     if(cards_to_report_i(RC4) = '1') then
                        next_state <= READ_RC4;
                     else
                        next_state <= DONE;
                     end if;
                  else
                     next_state <= DONE;
                  end if;
               else -- if (cmd_code_i = DATA)
                  if(card_addr_i = ALL_READOUT_CARDS) then
                     if(rcs_to_report_data_i(RC4) = '1') then
                        next_state <= READ_RC4;
                     else
                        next_state <= DONE;
                     end if;
                  -- Otherwise, we are done
                  else
                     next_state <= DONE;
                  end if;
               end if;
            end if;

         when READ_RC4 =>
            if(word_count >= card_data_size) then
               if(cmd_code_i = READ_BLOCK) then
                  if(card_addr_i = ALL_FPGA_CARDS) then
                     if(cards_to_report_i(CC) = '1') then
                        next_state <= READ_CC;
                     else
                        next_state <= DONE;
                     end if;
                  else -- (card_addr_i = ALL_READOUT_CARDS or card_addr_i = RC4) then
                     next_state <= DONE;
                  end if;
               else -- if (cmd_code_i = DATA)
                  next_state <= DONE;
               end if;
            end if;

         when READ_CC =>
            if(word_count >= card_data_size) then
               next_state <= DONE;
            end if;

         when READ_PSU =>
            if(word_count >= card_data_size) then
               next_state <= DONE;
            end if;
         -------------------------------------------------------------------------------

         when TIMED_OUT =>
            next_state <= LATCH_ERROR;

         when DONE =>
            next_state <= IDLE;

         when others =>
            next_state <= IDLE;

      end case;
   end process state_NS;

   ---------------------------------------------------------
   -- Data Pipeline:  Not to be integrated in a state machine because of latency issues
   ---------------------------------------------------------
   data_buff: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         data_buf_a <= (others => '0');
         data_buf_b <= (others => '0');
         data_buf_c <= (others => '0');
         data_o     <= (others => '0');
      elsif(clk_i'event and clk_i = '1') then

         -- All of the rdy signals may be asserted, but they are looked at in this order.
         -- They are in groups of 4 because that is how many inputs each LUT has in Stratix FPGAs
         if (ac_rdy  = '1') then
            data_buf_a  <= ac_data;
         elsif (bc1_rdy  = '1') then
            data_buf_a <= bc1_data;
         elsif (bc2_rdy  = '1') then
            data_buf_a <= bc2_data;
         elsif (bc3_rdy  = '1') then
            data_buf_a <= bc3_data;
         end if;

         if (rc1_rdy  = '1') then
            data_buf_b  <= rc1_data;
         elsif (rc2_rdy  = '1') then
            data_buf_b <= rc2_data;
         elsif (rc3_rdy  = '1') then
            data_buf_b <= rc3_data;
         elsif (rc4_rdy  = '1') then
            data_buf_b <= rc4_data;
         end if;

         if (cc_rdy  = '1') then
            data_buf_c  <= cc_data;
         elsif (psu_rdy  = '1') then
            data_buf_c <= psu_data;
         end if;

         if (pres_state = READ_AC) then
            data_o <= data_buf_a;
         elsif (pres_state = READ_BC1) then
            data_o <= data_buf_a;
         elsif (pres_state = READ_BC2) then
            data_o <= data_buf_a;
         elsif (pres_state = READ_BC3) then
            data_o <= data_buf_a;
         elsif (pres_state = READ_RC1) then
            data_o <= data_buf_b;
         elsif (pres_state = READ_RC2) then
            data_o <= data_buf_b;
         elsif (pres_state = READ_RC3) then
            data_o <= data_buf_b;
         elsif (pres_state = READ_RC4) then
            data_o <= data_buf_b;
         elsif (pres_state = READ_CC) then
            data_o <= data_buf_c;
         elsif (pres_state = READ_PSU) then
            data_o <= data_buf_c;
         end if;
      end if;
   end process data_buff;

   state_Out: process(pres_state, ack_i, word_count, card_data_size)
   begin
      update_status <= '0';
      timeout_clr   <= '1';

      ac_ack        <= '0';
      ac_clear      <= '0';
      bc1_ack       <= '0';
      bc1_clear     <= '0';
      bc2_ack       <= '0';
      bc2_clear     <= '0';
      bc3_ack       <= '0';
      bc3_clear     <= '0';
      rc1_ack       <= '0';
      rc1_clear     <= '0';
      rc2_ack       <= '0';
      rc2_clear     <= '0';
      rc3_ack       <= '0';
      rc3_clear     <= '0';
      rc4_ack       <= '0';
      rc4_clear     <= '0';
      cc_ack        <= '0';
      cc_clear      <= '0';
      psu_ack       <= '0';
      psu_clear     <= '0';

      rdy_o         <= '0';
      matched_o     <= '0';
      timeout_o     <= '0';

      timeout_reg_set <= '0';
      timeout_reg_clr <= '0';

      word_count_ena <= '0';
      word_count_clr <= '0';

--      data_o <= ERR_DATA;

      case pres_state is
         when IDLE =>

         when WAIT_FOR_REPLY =>
            timeout_clr <= '0';

         when LATCH_ERROR =>
            update_status <= '1';

         when ERROR_WAIT1 =>

         when ERROR_WAIT2 =>

         when ERROR_WAIT3 =>

         when MATCHED =>
            matched_o <= '1';

         when READ_AC =>
            -- Keep rdy_o asserted throughout
            rdy_o <= '1';
            -- If the number of words to output has been met
            if(word_count = card_data_size) then
               -- Clear the word counter
               word_count_clr <= '1';
            else
               if(ack_i = '1') then
                  word_count_ena <= '1';
                  ac_ack        <= '1';
               end if;
            end if;

         when READ_BC1 =>
            rdy_o <= '1';
            if(word_count = card_data_size) then
               word_count_clr <= '1';
            else
               if(ack_i = '1') then
                  word_count_ena <= '1';
                  bc1_ack       <= '1';
               end if;
            end if;

         when READ_BC2 =>
            rdy_o <= '1';
            if(word_count = card_data_size) then
               word_count_clr <= '1';
            else
               if(ack_i = '1') then
                  word_count_ena <= '1';
                  bc2_ack       <= '1';
               end if;
            end if;

         when READ_BC3 =>
            rdy_o <= '1';
            if(word_count = card_data_size) then
               word_count_clr <= '1';
            else
               if(ack_i = '1') then
                  word_count_ena <= '1';
                  bc3_ack       <= '1';
               end if;
            end if;

         when READ_RC1 =>
            rdy_o <= '1';
            if(word_count = card_data_size) then
               word_count_clr <= '1';
            else
               if(ack_i = '1') then
                  word_count_ena <= '1';
                  rc1_ack       <= '1';
               end if;
            end if;

         when READ_RC2 =>
            rdy_o <= '1';
            if(word_count = card_data_size) then
               word_count_clr <= '1';
            else
               if(ack_i = '1') then
                  word_count_ena <= '1';
                  rc2_ack       <= '1';
               end if;
            end if;

         when READ_RC3 =>
            rdy_o <= '1';
            if(word_count = card_data_size) then
               word_count_clr <= '1';
            else
               if(ack_i = '1') then
                  word_count_ena <= '1';
                  rc3_ack       <= '1';
               end if;
            end if;

         when READ_RC4 =>
            rdy_o <= '1';
            if(word_count = card_data_size) then
               word_count_clr <= '1';
            else
               if(ack_i = '1') then
                  word_count_ena <= '1';
                  rc4_ack       <= '1';
               end if;
            end if;

         when READ_CC =>
            rdy_o <= '1';
            if(word_count = card_data_size) then
               word_count_clr <= '1';
            else
               if(ack_i = '1') then
                  word_count_ena <= '1';
                  cc_ack        <= '1';
               end if;
            end if;

         when READ_PSU =>
            rdy_o <= '1';
            if(word_count = card_data_size) then
               word_count_clr <= '1';
            else
               if(ack_i = '1') then
                  word_count_ena <= '1';
                  psu_ack       <= '1';
               end if;
            end if;

         when TIMED_OUT =>
            timeout_o        <= '1';
            timeout_reg_set  <= '1';

         when STATUS_WORD =>
            rdy_o            <= '1';

            -- Even if there is just a status word (no data) we don't have to pipe through the ack, because the DONE state below
            -- takes care of clearing the reply_queue_receive blocks once we're done with them

         when DONE =>
            word_count_clr   <= '1';
            timeout_reg_clr  <= '1';
            ac_clear         <= '1';
            bc1_clear        <= '1';
            bc2_clear        <= '1';
            bc3_clear        <= '1';
            rc1_clear        <= '1';
            rc2_clear        <= '1';
            rc3_clear        <= '1';
            rc4_clear        <= '1';
            cc_clear         <= '1';
            psu_clear        <= '1';

         when others =>
            null;

      end case;
   end process state_Out;

end rtl;