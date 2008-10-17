-- Copyright (c) 2003 SCUBA-2 Project
-- All Rights Reserved
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
-- UBC, University of British Columbia, Physics & Astronomy Department,
-- Vancouver BC, V6T 1Z1
--
-- reply_translator
--
-- <revision control keyword substitutions e.g. $Id: reply_translator.vhd,v 1.60 2008/02/03 09:49:33 bburger Exp $>
--
-- Project:          SCUBA-2
-- Author:           David Atkinson/ Bryce Burger
-- Organisation:     UKATC         / UBC
--
-- Description:
-- <description text>
--
-- Revision history:
-- <date $Date: 2008/02/03 09:49:33 $> - <text> - <initials $Author: bburger $>
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;
use work.issue_reply_pack.all;

library sys_param;
use sys_param.command_pack.all;

library components;
use components.component_pack.all;

entity reply_translator is
port(
   -- for testing
   debug_o             : out std_logic_vector (31 downto 0);

   -- global inputs
   rst_i               : in std_logic;                                               -- global reset
   clk_i               : in std_logic;                                               -- global clock
   crc_err_en_i        : in std_logic;
   stop_delay_i        : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);

   -- signals to/from cmd_translator
   cmd_rcvd_er_i       : in std_logic;                                               -- command received on fibre with checksum error
   cmd_rcvd_ok_i       : in std_logic;                                               -- command received on fibre - no checksum error
   c_cmd_code_i        : in std_logic_vector(FIBRE_PACKET_TYPE_WIDTH-1 downto 0);
   c_card_addr_i       : in std_logic_vector(FIBRE_CARD_ADDRESS_WIDTH-1 downto 0);
   c_param_id_i        : in std_logic_vector(FIBRE_PARAMETER_ID_WIDTH-1 downto 0);
   stop_reply_req_i    : in std_logic;
   stop_reply_ack_o    : out std_logic;

   -- signals to/from reply queue
   r_cmd_code_i        : in std_logic_vector(FIBRE_PACKET_TYPE_WIDTH-1 downto 0);
   r_card_addr_i       : in std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0);
   r_param_id_i        : in std_logic_vector(BB_PARAMETER_ID_WIDTH-1 downto 0);
   r_cmd_rdy_i         : in std_logic;                                               -- macro op response ready to be processed
   mop_error_code_i    : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);    -- macro op success (others => '0') else error code
   fibre_word_i        : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);     -- packet word read from reply queue
   num_fibre_words_i   : in integer;                                                -- indicate number of packet words to be read from reply queue
   fibre_word_ack_o    : out std_logic;                                               -- asserted to requeset next fibre word
   fibre_word_rdy_i    : in std_logic;
   mop_ack_o           : out std_logic;                                               -- asserted to indicate to reply queue the the packet has been processed

   -- We may choose to remove these signals once we move to the new protocol.
--   last_frame_i        : in std_logic;
   frame_seq_num_i     : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   frame_status_word_i : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);

   -- input from the cmd_queue
--   busy_i              : in std_logic;

   -- signals to/ from fibre_tx (interface to a FIFO)
   fibre_tx_rdy_o      : out std_logic;                                               -- transmit fifo full
   fibre_tx_busy_i     : in std_logic;                                                -- transmit fifo write request
   fibre_tx_dat_o      : out std_logic_vector (PACKET_WORD_WIDTH-1 downto 0)          -- transmit fifo data input
);
end reply_translator;


architecture rtl of reply_translator is

   -- The logical AND of this word with the status word filters out the warnings from the status word,
   -- leaving only the errors.
   constant STATUS_WORD_WARNING_MASK : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0) :=   "00011011011011011011011011011011"; --"00010010010010010010010010010010";
   constant NO_ERRORS_REPORTED       : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0) :=   "00000000000000000000000000000000";

   constant RB_OK : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0) := x"52424F4B";
   -- "GOOK" = 0x474F4F4B or
   -- "STOK" = 0x53544F4B or
   -- "RSOK" = 0x52534F4B or
   -- "WBOK" = 0x57424F4B or
   -- "RBOK" = 0x52424F4B or
   -- "GOER" = 0x474F4552 or
   -- "STER" = 0x53544552 or
   -- "RSER" = 0x52534552 or
   -- "WBER" = 0x57424552 or
   -- "RBER" = 0x52424552 or

   -- Reply Structure
   constant NUM_REPLY_WORDS        : integer := 4;
   constant NUM_FRAME_HEAD_WORDS   : integer := 41;
--   constant STOP_REPLY_WAIT_PERIOD : integer := 25;
   constant SERVICING_COMMAND      : std_logic := '0';
   constant SERVICING_REPLY        : std_logic := '1';

   -- reply word registers
   signal frame_status   : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);  -- reply word 1 byte 0
   signal frame_seq_num  : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);  -- reply word 1 byte 0
   signal ok_or_er       : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);  -- reply word 1 byte 0
   signal crd_add_par_id : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);  -- reply word 2 byte 0
   signal status         : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);  -- reply word 3 byte 0
   signal checksum       : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);  -- checksum word (output from checksum calculator)

   ----------------------------------------------------------------------------------------------------------------
   --                             FIBRE PACKET FSM
   ----------------------------------------------------------------------------------------------------------------
   -- handles the writting off all packets (replies and data) to the
   -- fibre transmit FIFO (fibre_tx_fifo)

   type translator_state is
      (TRANSLATOR_IDLE, CMD_ERROR_REPLY, QUICK_REPLY, QUICK_REPLY_PAUSE, STANDARD_REPLY, DATA_PACKET, LD_PREAMBLE1,  LD_PREAMBLE2,
       LD_xxRP, LD_PACKET_SIZE, LD_OKorER, LD_CARD_PARAM, LD_STATUS, WAIT_Q_WORD1, WAIT_Q_WORD2,
       WAIT_Q_WORD3, WAIT_Q_WORD4, LD_DATA, ACK_Q_WORD, LD_CKSUM, DONE, SKIP_COMMAND, SKIP_REPLY);

   signal translator_current_state : translator_state;
   signal translator_next_state    : translator_state;

   signal packet_size       : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0); -- this value is written to the packet header word 4
   signal packet_type       : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0); -- indicates reply or data packet - written to header word 3
   signal checksum_clr      : std_logic;                                      -- signal asserted to reset packet checksum
   signal checksum_ld       : std_logic;                                      -- signal assertd to update packet checksum with checksum_in value
   signal fibre_tx_dat      : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);

   signal rb_packet_size    : integer;
   signal data_packet_size  : integer;

   -- fibre fsm uses this to acknowledge that it will package up a reply to checksum error stop
   signal fibre_word        : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0); -- packet word read from reply queue

   signal error_flags_only  : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0); -- packet word read from reply queue

   signal c_cmd_rdy         : std_logic;
   signal c_cmd_err         : std_logic;
   signal c_cmd_rdy_tmp     : std_logic;
   signal c_cmd_err_tmp     : std_logic;
   signal c_cmd_ack         : std_logic;
   signal c_cmd_code        : std_logic_vector(FIBRE_PACKET_TYPE_WIDTH-1 downto 0);
   signal c_card_addr       : std_logic_vector(FIBRE_CARD_ADDRESS_WIDTH-1 downto 0);
   signal c_param_id        : std_logic_vector(FIBRE_PARAMETER_ID_WIDTH-1 downto 0);

   signal r_cmd_rdy         : std_logic;
   signal r_cmd_ack         : std_logic;
   signal r_cmd_code        : std_logic_vector(FIBRE_PACKET_TYPE_WIDTH-1 downto 0);
   signal r_card_addr       : std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0);
   signal r_param_id        : std_logic_vector(BB_PARAMETER_ID_WIDTH-1 downto 0);
   signal c_or_r            : std_logic;

   signal timer_clr         : std_logic;
   signal timer_count       : integer;
   signal stop_delay        : integer;

begin

   ----------------------------------------------------------------------------
   -- Logic Analyzer Signals
   ----------------------------------------------------------------------------
   debug_o <= (others => '0');

   error_flags_only <= mop_error_code_i and STATUS_WORD_WARNING_MASK;

   ----------------------------------------------------------------------------
   -- timer for delaying replies after a ST reply has been sent out
   ----------------------------------------------------------------------------
   stop_delay <= conv_integer(stop_delay_i);
   timer : us_timer
   port map(
      clk           => clk_i,
      timer_reset_i => timer_clr,
      timer_count_o => timer_count
   );

   ----------------------------------------------------------------------------
   -- register inputs from cmd_translator
   ----------------------------------------------------------------------------
   register_cmd_code: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         c_cmd_rdy            <= '0';
         c_cmd_err            <= '0';
         c_cmd_rdy_tmp        <= '0';
         c_cmd_err_tmp        <= '0';

         c_cmd_code           <= (others => '0');
         c_card_addr          <= (others => '0');
         c_param_id           <= (others => '0');

      elsif (clk_i'EVENT and clk_i = '1') then
         c_cmd_err_tmp        <= cmd_rcvd_er_i;
         c_cmd_rdy_tmp        <= cmd_rcvd_ok_i;

         if(cmd_rcvd_er_i = '0' and c_cmd_err_tmp = '1') then
            c_cmd_code        <= c_cmd_code_i;
            c_card_addr       <= c_card_addr_i;
            c_param_id        <= c_param_id_i;
            c_cmd_err         <= '1';

         elsif(cmd_rcvd_ok_i = '0' and c_cmd_rdy_tmp = '1') then
            c_cmd_code        <= c_cmd_code_i;
            c_card_addr       <= c_card_addr_i;
            c_param_id        <= c_param_id_i;
            c_cmd_rdy         <= '1';

         elsif(c_cmd_ack = '1') then
            c_cmd_rdy         <= '0';
            c_cmd_err         <= '0';
         end if;

      end if;
   end process register_cmd_code;

   ----------------------------------------------------------------------------
   -- register inputs from the reply_queue
   ----------------------------------------------------------------------------
   register_reply_queue: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         fibre_word           <= (others => '0');
         r_cmd_rdy            <= '0';
         r_cmd_code           <= (others => '0');
         r_card_addr          <= (others => '0');
         r_param_id           <= (others => '0');
         rb_packet_size       <=  0;
         data_packet_size     <=  0;

      elsif (clk_i'EVENT and clk_i = '1') then
         fibre_word           <= fibre_word_i;
         -- Delay the signal by one cycle to allow the registers to latch the data
         r_cmd_rdy            <= r_cmd_rdy_i;

         if(r_cmd_rdy_i = '1') then
            r_cmd_code        <= r_cmd_code_i;
            r_card_addr       <= r_card_addr_i;
            r_param_id        <= r_param_id_i;
            -- The three extra words are for "RBOK", "card_addr & param_id" and checksum
            rb_packet_size    <= num_fibre_words_i + 3;
            -- The extra word is for the checksum
            data_packet_size  <= num_fibre_words_i + 1 ;
         end if;
      end if;
   end process register_reply_queue;

   ----------------------------------------------------------------------------
   -- process to update calculated packet checksum
   ----------------------------------------------------------------------------
   checksum_calculator: process(rst_i, clk_i)
   begin
      if(rst_i = '1') then
         checksum <= (others => '0');
      elsif(clk_i'EVENT and clk_i = '1') then
         if(checksum_clr = '1') then
            checksum <= (others => '0');
         elsif(checksum_ld = '1') then
            if(packet_type = DATA and crc_err_en_i = '1') then
               checksum <= x"ABCDABCD";
            else
               checksum <= checksum xor fibre_tx_dat;
            end if;
         end if;
      end if;
   end process checksum_calculator;

   ----------------------------------------------------------------------------
   -- Data Pipeline MUX
   ----------------------------------------------------------------------------
   fibre_tx_dat_o <= fibre_tx_dat;
   with translator_current_state select
      fibre_tx_dat <=
         FIBRE_PREAMBLE1 when LD_PREAMBLE1,
         FIBRE_PREAMBLE2 when LD_PREAMBLE2,
         packet_type     when LD_xxRP,
         packet_size     when LD_PACKET_SIZE,
         ok_or_er        when LD_OKorER,
         crd_add_par_id  when LD_CARD_PARAM,
         status          when LD_STATUS,
         fibre_word      when LD_DATA,
         checksum        when LD_CKSUM,
         (others => '0') when others;

   ---------------------------------------------------------------------------
   -- FIBRE FSM - writes fibre packets to transmit FIFO
   -- and writes header info to RAM (local command)
   ----------------------------------------------------------------------------
   fsm_state_forwarder : process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         translator_current_state <= TRANSLATOR_IDLE;
      elsif(clk_i'EVENT AND clk_i = '1') then
         translator_current_state <= translator_next_state;
      end if;
   end process fsm_state_forwarder;

   translator_fsm_nextstate : process (translator_current_state, c_cmd_rdy, c_cmd_err, c_or_r,
      r_cmd_code, c_cmd_code, fibre_tx_busy_i, fibre_word_rdy_i, r_cmd_rdy, ok_or_er, timer_count, stop_delay)
   begin
      -- Default Assignments
      translator_next_state <= translator_current_state;

      case translator_current_state is
      when TRANSLATOR_IDLE =>
         -- The problem here is that the stop command changes the command code
         -- and now the reply_translator doesn't know what its getting from the reply_queue so it doesn't ack anymore
         -- The reply_translator needs to ignore new command codes during data taking.  The best way to do this is probably to register command code,
         -- and use that for the duration of the data run (and all other commands too)
         -- We may need two registers here, for the cmd_translator to handle quick replies from the cmd_translator and normal replies from the reply_queue
         -- There is also the issue of getting a stop command in the middle of a packet that is being replied to..

         if(c_cmd_err = '1') then
           -- Error in received command packet
            translator_next_state <= CMD_ERROR_REPLY;
         -- Commands received by fibre_rx will always be service first because they may require immediate response
         -- Lets take replies to stop commands out of the cmd_translator's hands for now, and see where this leads.
         elsif(c_cmd_rdy = '1' and (c_cmd_code = GO or c_cmd_code = RESET or c_cmd_code = STOP)) then
            -- We have to go to quick reply right away, because if another reply is ready, it will supercede this one
            translator_next_state <= QUICK_REPLY;
         elsif(c_cmd_rdy = '1' and (c_cmd_code = WRITE_BLOCK or c_cmd_code = READ_BLOCK)) then
            -- Acknowledge all other commands (WB, RB) and stay in this state because no quick response is required.
            translator_next_state <= SKIP_COMMAND;
         -- Then replies from the reply_queue are serviced.
         elsif(r_cmd_rdy = '1' and (r_cmd_code = WRITE_BLOCK or r_cmd_code = READ_BLOCK)) then
            -- No housekeeping header required
            -- Note that it doesn't matter what the Errno word is, we return xxOK.
            translator_next_state <= STANDARD_REPLY;
         elsif(r_cmd_rdy = '1' and r_cmd_code = DATA) then
            -- Housekeeping header required
            -- Note that it doesn't matter what the Errno word is, we return xxOK.
            translator_next_state <= DATA_PACKET;
         elsif(r_cmd_rdy = '1') then
            -- Clear other possible commands (like STOP, RS) and stay in this state
            -- STOP and RS commands should never make to the reply_translator through this route, but just to be safe.
            translator_next_state <= SKIP_REPLY;
         end if;

      when SKIP_COMMAND =>
         translator_next_state <= TRANSLATOR_IDLE;

      when SKIP_REPLY =>
         translator_next_state <= TRANSLATOR_IDLE;

      when CMD_ERROR_REPLY | STANDARD_REPLY | DATA_PACKET =>
         translator_next_state <= LD_PREAMBLE1;

      when QUICK_REPLY =>
         translator_next_state <= QUICK_REPLY_PAUSE;

      when QUICK_REPLY_PAUSE =>
         -- If we were servicing a ST reply, then pause here to give the DSP chip on the PCI card timer_count to recover
         if(ok_or_er = STOP_OK or ok_or_er = STOP_ERR) then
            -- If we've haven't waited for 1 ms
            if(timer_count <= stop_delay) then
               translator_next_state <= QUICK_REPLY_PAUSE;
            -- If we have waited for 1 ms.
            else
               translator_next_state <= LD_PREAMBLE1;
            end if;
         -- Otherwise, head straight back to IDLE
         else
            translator_next_state <= LD_PREAMBLE1;
         end if;

      ----------------------------------------
      -- Preamble 1
      -- 0xA5A5A5A5
      ----------------------------------------
      when LD_PREAMBLE1 =>
         if(fibre_tx_busy_i = '0') then
            translator_next_state <= LD_PREAMBLE2;
         end if;

      ----------------------------------------
      -- Preamble 2
      -- 0x5A5A5A5A
      ----------------------------------------
      when LD_PREAMBLE2 =>
         if(fibre_tx_busy_i = '0') then
            translator_next_state <= LD_xxRP;
         end if;

      ----------------------------------------
      -- Packet Type
      -- "  RP" = 0x20205250 or
      -- "  DA" = 0x20204441
      ----------------------------------------
      when LD_xxRP =>
         if(fibre_tx_busy_i = '0') then
            translator_next_state <= LD_PACKET_SIZE;
         end if;

      ----------------------------------------
      -- Packet Size
      ----------------------------------------
      when LD_PACKET_SIZE =>
         if(fibre_tx_busy_i = '0') then
            translator_next_state <= LD_OKorER;
         end if;

      ----------------------------------------
      -- Frame Status Block
      ----------------------------------------
      when LD_OKorER =>
         if(fibre_tx_busy_i = '0') then
            translator_next_state <= LD_CARD_PARAM;
         end if;

      ----------------------------------------
      -- Card Address & Parameter ID
      ----------------------------------------
      when LD_CARD_PARAM =>
         if(fibre_tx_busy_i = '0') then
            translator_next_state <= LD_STATUS;
         end if;

      ----------------------------------------
      -- Status word
      ----------------------------------------
      when LD_STATUS =>
         if(fibre_tx_busy_i = '0') then
            -- This check is to determine weather we should be returning data or not
            -- Because the reply to ST commands is delayed, it is sometimes possible for data to build up in reply_queue
            -- By checking whether we are replying to a command or a reply, we can avoid mixing the two replies.
            if(c_or_r = SERVICING_REPLY) then
               translator_next_state <= WAIT_Q_WORD1;
            else
               translator_next_state <= LD_CKSUM;
            end if;
         end if;

      ----------------------------------------
      -- Wait states for allowing the reply_queue to respond
      ----------------------------------------
      when WAIT_Q_WORD1 =>
         if(DATA_PROPAGATION_DELAY = 1) then
            -- and fibre_tx_busy_i = '0' Don't check for busy here, because its done in all other states.
            if (fibre_word_rdy_i  = '1') then
               translator_next_state <= LD_DATA;
            else
               translator_next_state <= LD_CKSUM;
            end if;
         else
            translator_next_state <= WAIT_Q_WORD2;
         end if;

      when WAIT_Q_WORD2 =>
         if(DATA_PROPAGATION_DELAY = 2) then
            -- and fibre_tx_busy_i = '0' Don't check for busy here, because its done in all other states.
            if (fibre_word_rdy_i  = '1') then
               translator_next_state <= LD_DATA;
            else
               translator_next_state <= LD_CKSUM;
            end if;
         else
            translator_next_state <= WAIT_Q_WORD3;
         end if;

      when WAIT_Q_WORD3 =>
         if(DATA_PROPAGATION_DELAY = 3) then
            -- and fibre_tx_busy_i = '0' Don't check for busy here, because its done in all other states.
            if (fibre_word_rdy_i  = '1') then
               translator_next_state <= LD_DATA;
            else
               translator_next_state <= LD_CKSUM;
            end if;
         else
            translator_next_state <= WAIT_Q_WORD4;
         end if;

      when WAIT_Q_WORD4 =>
         -- and fibre_tx_busy_i = '0' Don't check for busy here, because its done in all other states.
         if (fibre_word_rdy_i  = '1') then
            translator_next_state <= LD_DATA;
         else
            translator_next_state <= LD_CKSUM;
         end if;

      ----------------------------------------
      -- Data words
      ----------------------------------------
      when LD_DATA =>
         if(fibre_tx_busy_i = '0') then
            translator_next_state <= WAIT_Q_WORD1;
         end if;

      ----------------------------------------
      -- Checksum word
      ----------------------------------------
      when LD_CKSUM =>
         if(fibre_tx_busy_i = '0') then
            translator_next_state <= DONE;
         end if;

      when DONE =>
         -- If we were servicing a ST reply, then pause here to give the DSP chip on the PCI card timer_count to recover
         if(ok_or_er = STOP_OK or ok_or_er = STOP_ERR) then
            -- If we've haven't waited for 1 ms
            if(timer_count <= stop_delay) then
               translator_next_state <= DONE;
            -- If we have waited for 1 ms.
            else
               translator_next_state <= TRANSLATOR_IDLE;
            end if;
         -- Otherwise, head straight back to IDLE
         else
            translator_next_state <= TRANSLATOR_IDLE;
         end if;

      when OTHERS =>
        translator_next_state <= TRANSLATOR_IDLE;

      end case;

   end process translator_fsm_nextstate;

   ----------------------------------------------------------------------------
   -- process to register the correct packet information
   ----------------------------------------------------------------------------
   register_packet: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         packet_size    <= (others => '0');
         packet_type    <= (others => '0');
         ok_or_er       <= (others => '0');
         crd_add_par_id <= (others => '0');
         status         <= (others => '0');
         frame_status   <= (others => '0');
         frame_seq_num  <= (others => '0');
         c_or_r         <= SERVICING_COMMAND;

      elsif(clk_i'event and clk_i = '1') then
         if(translator_current_state = TRANSLATOR_IDLE) then
            c_or_r         <= SERVICING_COMMAND;

         elsif(translator_current_state = CMD_ERROR_REPLY) then
            packet_size    <= conv_std_logic_vector(NUM_REPLY_WORDS,32);
            packet_type    <= REPLY;
            -- Card address and param id cannot be assumed to be valid.
            crd_add_par_id <= (others => '0');
            ok_or_er       <= c_cmd_code(15 downto 0) & ASCII_E & ASCII_R;
            -- No error encodings available for fibre errors :(.  All spaces taken.
            -- All the bits are spoken for (see the document called "Monitoring MCE Status")
            status         <= (others => '0');
            c_or_r         <= SERVICING_COMMAND;

         elsif(translator_current_state = QUICK_REPLY or translator_current_state = QUICK_REPLY_PAUSE) then
            packet_size    <= conv_std_logic_vector(NUM_REPLY_WORDS,32);
            packet_type    <= REPLY;
            crd_add_par_id <= c_card_addr & c_param_id;
            ok_or_er       <= c_cmd_code(15 downto 0) & ASCII_O & ASCII_K;
            status         <= (others => '0');
            c_or_r         <= SERVICING_COMMAND;

         elsif(translator_current_state = STANDARD_REPLY) then
-- When we implement RB replies so that they follow the standard protocol for Data packets, we will use this logic
-- Until then, if there is any error flag raise, we must not return data in RB packets.
--            if (r_cmd_code = READ_BLOCK or r_cmd_code = DATA) then
--               packet_size <= conv_std_logic_vector(rb_packet_size,PACKET_WORD_WIDTH);
--            else
--               packet_size <= conv_std_logic_vector(NUM_REPLY_WORDS,32);
--            end if;

            -- If there is an error in the RB
            if (r_cmd_code = READ_BLOCK and error_flags_only /= NO_ERRORS_REPORTED) then
               packet_size <= conv_std_logic_vector(4,PACKET_WORD_WIDTH);
            -- Else if it is a non-error RB, or any DA reply
            elsif (r_cmd_code = READ_BLOCK or r_cmd_code = DATA) then
               packet_size <= conv_std_logic_vector(rb_packet_size, PACKET_WORD_WIDTH);
            -- Else for any other packet.
            else
               packet_size <= conv_std_logic_vector(NUM_REPLY_WORDS,32);
            end if;

            packet_type    <= REPLY;
            crd_add_par_id <= "00000000" & r_card_addr & "00000000" & r_param_id;

            if(error_flags_only = NO_ERRORS_REPORTED) then
               ok_or_er <= r_cmd_code(15 downto 0) & ASCII_O & ASCII_K;
            else
               ok_or_er <= r_cmd_code(15 downto 0) & ASCII_E & ASCII_R;
            end if;
--            ok_or_er       <= (r_cmd_code(15 downto 0) & ASCII_O & ASCII_K);
            -- this will be error code x"00" - i.e. success.

            status         <= mop_error_code_i;
            c_or_r         <= SERVICING_REPLY;

         elsif(translator_current_state = DATA_PACKET) then
            packet_size    <= conv_std_logic_vector(data_packet_size,PACKET_WORD_WIDTH);
            packet_type    <= DATA;
            crd_add_par_id <= frame_seq_num_i;
            ok_or_er       <= (others => '0');
            status         <= (others => '0');
--            frame_status   <= "000000000000000000000000000000" & cmd_stop_i & last_frame_i;
            frame_status   <= frame_status_word_i;
            frame_seq_num  <= frame_seq_num_i;
            c_or_r         <= SERVICING_REPLY;

         else
            packet_size    <= packet_size;
            packet_type    <= packet_type;
            ok_or_er       <= ok_or_er;
            crd_add_par_id <= crd_add_par_id;
            status         <= status;
            c_or_r         <= c_or_r;

         end if;
      end if;
   end process register_packet;

   translator_fsm_output : process (translator_current_state, ok_or_er, fibre_tx_busy_i,
      c_or_r, packet_type, timer_count, stop_delay) --, c_cmd_code, c_cmd_rdy, timer_count)
   begin
      fibre_tx_rdy_o   <= '0';
      fibre_word_ack_o <= '0';
      checksum_ld      <= '0';
      checksum_clr     <= '0';
      mop_ack_o        <= '0'; -- For commands from reply_queue
      c_cmd_ack        <= '0'; -- For commands from cmd_translator
      r_cmd_ack        <= '0'; -- For commands from cmd_translator
      stop_reply_ack_o <= '0';
      timer_clr        <= '1';

      case translator_current_state is

      -- Idle state - no packets to process
      when TRANSLATOR_IDLE =>
         checksum_clr   <= '1';

      -- From fibre_rx
      -- Checksum error has occurred
      when SKIP_COMMAND =>
         c_cmd_ack <= '1';

      when SKIP_REPLY =>
         r_cmd_ack <= '1';

      when CMD_ERROR_REPLY =>
         c_cmd_ack <= '1'; -- go to CMD_ERROR_REPLY

      -- From fibre_rx
      -- command is RS, GO, or ST -- so generate an instant reply
      when QUICK_REPLY =>
         -- Moved this to the DONE state, so that I don't include frame data in the ST reply.
         -- c_cmd_ack <= '1'; -- go to CMD_ERROR_REPLY

      when QUICK_REPLY_PAUSE =>
         -- If we were servicing a ST reply, then pause here to give the DSP chip on the PCI card timer_count to recover
         if(ok_or_er = STOP_OK or ok_or_er = STOP_ERR) then
            timer_clr <= '0';
         -- Otherwise, head straight back to IDLE
         else
            timer_clr <= '1';
         end if;

      -- From reply_queue
      when STANDARD_REPLY =>
         r_cmd_ack <= '1'; -- go to DATA_PACKET

      -- From reply_queue
      when DATA_PACKET =>
         r_cmd_ack <= '1'; -- go to DATA_PACKET

      ----------------------------------------
      -- Preamble 1
      -- 0xA5A5A5A5
      ----------------------------------------
      when LD_PREAMBLE1 =>
         if(fibre_tx_busy_i = '0') then
            fibre_tx_rdy_o <= '1';
         end if;

      ----------------------------------------
      -- Preamble 2
      -- 0x5A5A5A5A
      ----------------------------------------
      when LD_PREAMBLE2 =>
         if(fibre_tx_busy_i = '0') then
            fibre_tx_rdy_o <= '1';
         end if;

      ----------------------------------------
      -- Packet Type
      -- "  RP" = 0x20205250 or
      -- "  DA" = 0x20204441
      ----------------------------------------
      when LD_xxRP =>
         if(fibre_tx_busy_i = '0') then
            fibre_tx_rdy_o <= '1';
         end if;

      ----------------------------------------
      -- Packet Size
      ----------------------------------------
      when LD_PACKET_SIZE =>
         if(fibre_tx_busy_i = '0') then
            fibre_tx_rdy_o <= '1';
         end if;

      ----------------------------------------
      -- "GOOK" = 0x474F4F4B or
      -- "STOK" = 0x53544F4B or
      -- "RSOK" = 0x52534F4B or
      -- "WBOK" = 0x57424F4B or
      -- "RBOK" = 0x52424F4B or
      -- "GOER" = 0x474F4552 or
      -- "STER" = 0x53544552 or
      -- "RSER" = 0x52534552 or
      -- "WBER" = 0x57424552 or
      -- "RBER" = 0x52424552 or
      -- Frame Status Block
      ----------------------------------------
      when LD_OKorER =>
         if(fibre_tx_busy_i = '0') then
            -- Not transmitted in data packets
            if(c_or_r = SERVICING_REPLY and packet_type = DATA) then
               fibre_tx_rdy_o <= '0';
               checksum_ld    <= '0';
            else
               fibre_tx_rdy_o <= '1';
               checksum_ld    <= '1';
            end if;
         end if;

      ----------------------------------------
      -- Card Address & Parameter ID
      ----------------------------------------
      when LD_CARD_PARAM =>
         if(fibre_tx_busy_i = '0') then
            -- Not transmitted in data packets
            if(c_or_r = SERVICING_REPLY and packet_type = DATA) then
               fibre_tx_rdy_o <= '0';
               checksum_ld    <= '0';
            else
               fibre_tx_rdy_o <= '1';
               checksum_ld    <= '1';
            end if;
         end if;

      ----------------------------------------
      -- Status word
      ----------------------------------------
      when LD_STATUS =>
         if(fibre_tx_busy_i = '0') then

            if(c_or_r = SERVICING_REPLY) then
               fibre_word_ack_o <= '1';
            end if;

            -- Not transmitted in RBOK packets or data packets
            if(c_or_r = SERVICING_REPLY and (ok_or_er = RB_OK or packet_type = DATA)) then
               fibre_tx_rdy_o <= '0';
               checksum_ld    <= '0';
            else
               fibre_tx_rdy_o <= '1';
               checksum_ld    <= '1';
            end if;

         end if;

      ----------------------------------------
      -- Data words
      ----------------------------------------
      when LD_DATA =>
         if(fibre_tx_busy_i = '0') then
            fibre_word_ack_o <= '1';
            -- Do not transmit a data word if an "RB" was unsuccessful
            -- The only timer_count an "xxER" occurs is when there is a checksum error over the fibre
            -- Otherwise, replies will always indicate "xxOK" and an error flag will be set is any errors have occurred in the MCE
            if(c_or_r = SERVICING_REPLY and ok_or_er = x"52424552") then
               fibre_tx_rdy_o <= '0';
               checksum_ld    <= '0';
            else
               fibre_tx_rdy_o <= '1';
               checksum_ld    <= '1';
            end if;
         end if;

      ----------------------------------------
      -- Checksum word
      ----------------------------------------
      when LD_CKSUM =>
         if(fibre_tx_busy_i = '0') then
            fibre_tx_rdy_o <= '1';
         end if;

      when WAIT_Q_WORD1  =>
      when WAIT_Q_WORD2  =>
      when WAIT_Q_WORD3  =>
      when WAIT_Q_WORD4  =>

      when DONE =>
         -- If we were servicing a ST reply, then pause here to give the DSP chip on the PCI card timer_count to recover
         if(ok_or_er = STOP_OK or ok_or_er = STOP_ERR) then
            -- If we've haven't waited for 1 ms
            if(timer_count <= stop_delay) then
               timer_clr <= '0';
            -- If we have waited for 1 ms.
            else
               c_cmd_ack <= '1';
               stop_reply_ack_o <= '1';
            end if;
         -- Otherwise, if the command was a GO or RS, head straight back to IDLE
         elsif(ok_or_er = GO_OK or ok_or_er = GO_ERR or ok_or_er = RESET_OK or ok_or_er = RESET_ERR) then
            c_cmd_ack <= '1';
         end if;

      when others =>

      end case;

   end process translator_fsm_output;

end rtl;
