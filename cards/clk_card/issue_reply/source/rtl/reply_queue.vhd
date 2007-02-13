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
-- $Id: reply_queue.vhd,v 1.40 2006/11/07 23:52:51 bburger Exp $
--
-- Project:    SCUBA2
-- Author:     Bryce Burger, Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- This file implements the reply_queue block in the issue/reply chain
-- on the clock card.
--
-- Revision history:
-- $Log: reply_queue.vhd,v $
-- Revision 1.40  2006/11/07 23:52:51  bburger
-- Bryce: Modified some of the header logic in preparation for the new housekeeping header format.
--
-- Revision 1.39  2006/11/03 01:10:53  bburger
-- Bryce:  Added support for the DATA cmd_code
--
-- Revision 1.38  2006/10/02 18:45:28  bburger
-- Bryce:  explicity cased the "WAIT_FOR_ACK" state
--
-- Revision 1.37  2006/09/28 00:34:18  bburger
-- Bryce:  now asserts cmd_sent_o/ mop_ack_o only when there is no data left in the queues.  This prevents short responses interfering with long ones.
--
-- Revision 1.36  2006/09/21 16:16:59  bburger
-- Bryce:
-- - parameterized some literals
-- - added support for WB internal commands (TES Bias Step)
-- - added a TES Bias Level bit to the data packet status header
--
-- Revision 1.35  2006/09/15 00:48:36  bburger
-- Bryce:  Cleaned up the data word acknowledgement chain to speed things up.  Untested in hardware.  Data packets are un-simulated
--
-- Revision 1.34  2006/09/07 22:25:22  bburger
-- Bryce:  replace cmd_type (1-bit: read/write) interfaces and funtionality with cmd_code (32-bit: read_block/ write_block/ start/ stop/ reset) interface because reply_queue_sequencer needed to know to discard replies to reset commands
--
-- Revision 1.33  2006/09/06 00:27:11  bburger
-- Bryce:  added support for reset commands.  their replies are now discarded when they arrive from the backplane because the clock card has already sent a generic reply.
--
-- Revision 1.32  2006/08/17 01:45:36  bburger
-- Bryce:  Changed the data_o signal from being a clocked mux to a combinatorial mux to get rid of timing violations
--
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
use work.cmd_queue_ram40_pack.all;
use work.cmd_queue_pack.all;
use work.sync_gen_pack.all;
use work.frame_timing_pack.all;
use work.issue_reply_pack.all;

entity reply_queue is
   port(
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
      tes_bias_step_level_i : in std_logic;

      data_rate_i         : in std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);
      row_len_i           : in integer;
      num_rows_i          : in integer;
      issue_sync_i        : in std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);
      cmd_code_i          : in  std_logic_vector (FIBRE_PACKET_TYPE_WIDTH-1 downto 0);       -- the least significant 16-bits from the fibre packet

      -- reply_translator interface (from reply_queue, i.e. these signals are de-multiplexed from retire and sequencer)
      size_o              : out integer;
      data_o              : out std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
      error_code_o        : out std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
      rdy_o               : out std_logic;
      ack_i               : in std_logic;

      -- reply_translator interface (from reply_queue_retire)
      cmd_sent_i          : in std_logic;
      cmd_valid_o         : out std_logic;
      cmd_code_o          : out std_logic_vector(FIBRE_PACKET_TYPE_WIDTH-1 downto 0);
      param_id_o          : out std_logic_vector(BB_PARAMETER_ID_WIDTH-1 downto 0);
      card_addr_o         : out std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0);
      stop_bit_o          : out std_logic;
      last_frame_bit_o    : out std_logic;
      frame_seq_num_o     : out std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);

      -- clk_switchover interface
      active_clk_i        : in std_logic;

      -- dv_rx interface
      sync_box_err_i      : in std_logic;
      sync_box_free_run_i : in std_logic;
      external_dv_num_i   : in std_logic_vector(DV_NUM_WIDTH-1 downto 0);

      -- Bus Backplane interface
      lvds_reply_ac_a     : in std_logic;
      lvds_reply_bc1_a    : in std_logic;
      lvds_reply_bc2_a    : in std_logic;
      lvds_reply_bc3_a    : in std_logic;
      lvds_reply_rc1_a    : in std_logic;
      lvds_reply_rc2_a    : in std_logic;
      lvds_reply_rc3_a    : in std_logic;
      lvds_reply_rc4_a    : in std_logic;
      lvds_reply_cc_a     : in std_logic;

      -- Global signals
      clk_i               : in std_logic;
      comm_clk_i          : in std_logic;
      rst_i               : in std_logic
   );
end reply_queue;

architecture behav of reply_queue is

   component reply_queue_sequencer
   port(
        -- for debugging
        timer_trigger_o   : out std_logic;

        comm_clk_i        : in std_logic;
        clk_i             : in std_logic;
        rst_i             : in std_logic;

        card_data_size_i  : in std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);
        -- cmd_translator interface
        cmd_code_i        : in  std_logic_vector (FIBRE_PACKET_TYPE_WIDTH-1 downto 0);       -- the least significant 16-bits from the fibre packet
        par_id_i          : in std_logic_vector(BB_PARAMETER_ID_WIDTH-1 downto 0);

        -- Bus Backplane interface
        lvds_reply_ac_a   : in std_logic;
        lvds_reply_bc1_a  : in std_logic;
        lvds_reply_bc2_a  : in std_logic;
        lvds_reply_bc3_a  : in std_logic;
        lvds_reply_rc1_a  : in std_logic;
        lvds_reply_rc2_a  : in std_logic;
        lvds_reply_rc3_a  : in std_logic;
        lvds_reply_rc4_a  : in std_logic;
        lvds_reply_cc_a   : in std_logic;

        -- fibre interface:
        size_o            : out integer;
        error_o           : out std_logic_vector(30 downto 0);
        data_o            : out std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
        rdy_o             : out std_logic;
        ack_i             : in std_logic;

        -- cmd_queue interface:
        card_addr_i       : in std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0);
        cmd_valid_i       : in std_logic;
        matched_o         : out std_logic
        );
   end component;

   -- Internal signals
   signal active_clk           : std_logic;
   signal sync_box_err         : std_logic;
   signal sync_box_free_run    : std_logic;

   signal matched              : std_logic;
   signal cmd_rdy              : std_logic;
   signal internal_cmd         : std_logic;
   signal tes_bias_step_level  : std_logic;

   signal data_size            : integer;
   signal data_bus             : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal header_data_bus      : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal error_code           : std_logic_vector(30 downto 0);
   signal word_rdy             : std_logic; -- word is valid
   signal word_ack             : std_logic;

   -- Register Signals
   signal cmd_code             : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);       -- the least significant 16-bits from the fibre packet
   signal card_addr            : std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0); -- The card address of the m-op
   signal par_id               : std_logic_vector(BB_PARAMETER_ID_WIDTH-1 downto 0); -- The parameter id of the m-op
   signal data_size_t          : std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0); -- The number of bytes of data in the m-op
   signal bit_status           : std_logic_vector(6 downto 0);
   signal bit_status_i         : std_logic_vector(6 downto 0);
   signal frame_seq_num        : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal issue_sync_num       : std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);
   signal reg_en               : std_logic;

   -- Retire FSM:  waits for replies from the Bus Backplane, and retires pending instructions in the the command queue
   type retire_states is (IDLE, LATCH_CMD, RECEIVED, WAIT_FOR_MATCH, REPLY, STORE_ERRNO_HEADER_WORD,
      STORE_HEADER_WORD, NEXT_HEADER_WORD, DONE_HEADER_STORE, TX_HEADER, TX_SYNC_NUM, TX_ACTIVE_CLK, TX_SYNC_BOX_ERR, TX_SYNC_BOX_FR,
      TX_DATA_RATE, TX_ROW_LEN, TX_NUM_ROWS, TX_FRAME_SEQUENCE_NUM, TX_SEND_DATA, WAIT_FOR_ACK, TX_STATUS, TX_DV_NUM, INTERNAL_WB, TX_TES_BIAS_LEVEL);
   signal present_retire_state : retire_states;
   signal next_retire_state    : retire_states;

   -- signals for header RAM
   signal head_address         : std_logic_vector (RAM_HEAD_ADDR_WIDTH-1 downto 0);
   signal head_offset          : integer;

   signal head_q               : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
   signal head_wren            : std_logic;

   -- signals for recirculation MUX to register RAM output.
   signal head_q_reg           : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);    -- register RAM output
   signal head_q_mux           : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
   signal head_q_mux_sel       : std_logic;

   signal ena_word_count       : std_logic;
   signal load_word_count      : std_logic;
   signal word_count           : integer;
   signal word_count_new       : integer;

   signal status_en            : std_logic;
   signal status_q             : std_logic_vector(30 downto 0);

   signal fpga_temp_stale      : std_logic;
   signal card_temp_stale      : std_logic;
   signal psu_status_stale     : std_logic;
   signal box_temp_stale       : std_logic;

   component reply_translator_frame_head_ram
   port(
      address  : in  std_logic_vector (RAM_HEAD_ADDR_WIDTH-1 downto 0);
      clock    : in  std_logic ;
      data     : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
      wren     : in  std_logic ;
      q        : out std_logic_vector (PACKET_WORD_WIDTH-1 downto 0)
   );
   end component;

begin

   --------------------------------------------------------------------
   -- RAM to save frame header info
   -------------------------------------------------------------------

   i_reply_translator_frame_head_ram : reply_translator_frame_head_ram
   port map(
      address  => head_address,
      clock    => clk_i,
      data     => header_data_bus,
      wren     => head_wren,
      q        => head_q
   );

   head_offset <=
      0                                                  when par_id = FPGA_TEMP_ADDR else
      FPGA_TEMP_SIZE                                     when par_id = CARD_TEMP_ADDR else
      FPGA_TEMP_SIZE + CARD_TEMP_SIZE                    when par_id = PSC_STATUS_ADDR else
      FPGA_TEMP_SIZE + CARD_TEMP_SIZE + PSC_STATUS_SIZE  when par_id = BOX_TEMP_ADDR else 0;

   head_address <= conv_std_logic_vector(word_count + head_offset, 6);

   -- register RAM output with recirculation mux
   head_q_mux_sel <= '0';
   head_q_mux     <= head_q when head_q_mux_sel = '1' else head_q_reg;


   register_0 : process (rst_i, clk_i)
   begin
      if(rst_i = '1') then
         head_q_reg       <= (others => '0');

         fpga_temp_stale  <= '1';
         card_temp_stale  <= '1';
         psu_status_stale <= '1';
         box_temp_stale   <= '1';

      elsif (clk_i'EVENT and clk_i = '1') then
         head_q_reg <= head_q_mux;

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
         if(load_word_count = '1') then
            word_count <= 0;
         elsif(ena_word_count = '1') then
            word_count <= word_count_new;
         end if;
      end if;
   end process word_cntr;

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
   -- Bit Status Logic and Registers
   -------------------------------------------------------------------
   bit_status_i <=
      internal_cmd_i &
      tes_bias_step_level_i &
      active_clk_i &
      sync_box_err_i &
      sync_box_free_run_i &
      cmd_stop_i &
      last_frame_i;

   internal_cmd        <= bit_status(6);
   tes_bias_step_level <= bit_status(5);
   active_clk          <= bit_status(4);
   sync_box_err        <= bit_status(3);
   sync_box_free_run   <= bit_status(2);
   stop_bit_o          <= bit_status(1);
   last_frame_bit_o    <= bit_status(0);

   bit_status_reg: reg
      generic map(
         WIDTH      => 7
      )
      port map(
         clk_i      => clk_i,
         rst_i      => rst_i,
         ena_i      => reg_en,
         reg_i      => bit_status_i,
         reg_o      => bit_status
      );

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
   error_code_o <= "0" & status_q;
   status_reg : reg
      generic map(
         WIDTH => 31
      )
      port map(
         clk_i => clk_i,
         rst_i => rst_i,
         ena_i => status_en,
         reg_i => error_code,
         reg_o => status_q
      );

   -- Some of the outputs to reply_translator and lvds_rx fifo's
   cmd_code_o          <= cmd_code;
   card_addr_o         <= card_addr;
   frame_seq_num_o     <= frame_seq_num;
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
               next_retire_state <= LATCH_CMD;
            else
               next_retire_state <= IDLE;
            end if;

         when LATCH_CMD =>
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
                  next_retire_state <= TX_ROW_LEN;
               -- If this is a RB
               elsif(cmd_code = READ_BLOCK) then
                  next_retire_state <= REPLY;
               -- If this is a WB
               else
                  next_retire_state <= WAIT_FOR_ACK;
               end if;
            end if;

         when WAIT_FOR_ACK =>
            next_retire_state <= IDLE;

         when STORE_ERRNO_HEADER_WORD =>
            next_retire_state <= STORE_HEADER_WORD;

         when STORE_HEADER_WORD =>
            next_retire_state <= NEXT_HEADER_WORD;

         when NEXT_HEADER_WORD =>
            -- data_size + 1 compensates for the errno word we store for every internal command
            -- it's doubtful whether i need both of these conditions here..
            if(word_rdy = '1') and (word_count < data_size + 1) then
               next_retire_state <= STORE_HEADER_WORD;
            else
               next_retire_state <= DONE_HEADER_STORE;
            end if;

         when DONE_HEADER_STORE =>
            next_retire_state <= IDLE;

         when TX_ROW_LEN =>
            if(word_count >= 1) then
               next_retire_state <= TX_NUM_ROWS;
            end if;

         when TX_NUM_ROWS =>
            if(word_count >= 2) then
               next_retire_state <= TX_DATA_RATE;
            end if;

         when TX_DATA_RATE =>
            if(word_count >= 3) then
               next_retire_state <= TX_SYNC_NUM;
            end if;

         when TX_SYNC_NUM =>
            if(word_count >= 4) then
               next_retire_state <= TX_FRAME_SEQUENCE_NUM;
            end if;

         when TX_FRAME_SEQUENCE_NUM =>
            if(word_count >= 5) then
               next_retire_state <= TX_ACTIVE_CLK;
            end if;

         when TX_ACTIVE_CLK =>
            if(word_count >= 6) then
               next_retire_state <= TX_SYNC_BOX_ERR;
            end if;

         when TX_SYNC_BOX_ERR =>
            if(word_count >= 7) then
               next_retire_state <= TX_SYNC_BOX_FR;
            end if;

         when TX_SYNC_BOX_FR =>
            if(word_count >= 8) then
               next_retire_state <= TX_DV_NUM;
            end if;

         when TX_DV_NUM =>
            if(word_count >= 9) then
               next_retire_state <= TX_TES_BIAS_LEVEL;
            end if;

         when TX_TES_BIAS_LEVEL =>
            if(word_count >= 10) then
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
         data_bus                                 when TX_STATUS | TX_SEND_DATA | REPLY,
         data_rate_i                              when TX_DATA_RATE,
         conv_std_logic_vector(row_len_i,32)      when TX_ROW_LEN,
         conv_std_logic_vector(num_rows_i,32)     when TX_NUM_ROWS,
         issue_sync_num                           when TX_SYNC_NUM,
         frame_seq_num                            when TX_FRAME_SEQUENCE_NUM,
         x"0000000" & "000" & active_clk          when TX_ACTIVE_CLK,
         x"0000000" & "000" & sync_box_err        when TX_SYNC_BOX_ERR,
         x"0000000" & "000" & sync_box_free_run   when TX_SYNC_BOX_FR,
         external_dv_num_i                        when TX_DV_NUM,
         x"0000000" & "000" & tes_bias_step_level when TX_TES_BIAS_LEVEL,
         (others => '0')                          when others;

   retire_state_out: process(present_retire_state, ack_i, data_size, word_rdy, cmd_code, matched, data_bus, error_code)
   begin
      -- Default values
      reg_en          <= '0';
      cmd_rdy         <= '0';
      cmd_valid_o     <= '0';

      head_wren       <= '0';
      word_ack        <= '0';
      ena_word_count  <= '0';
      load_word_count <= '0';

      size_o          <=  0 ;
      rdy_o           <= '0';

      status_en       <= '0';
      cmd_sent_o      <= '0';

      header_data_bus <= (others => '0');

      case present_retire_state is
         when IDLE =>
            load_word_count <= '1';

         when LATCH_CMD =>
            reg_en          <= '1';

         when RECEIVED =>
            cmd_rdy         <= '1';

         when WAIT_FOR_MATCH =>
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

            rdy_o           <= '1';
            word_ack        <= ack_i;
            cmd_valid_o     <= '1';

         when WAIT_FOR_ACK =>
            cmd_sent_o <= '1';

         when INTERNAL_WB =>
            word_ack        <= '1';

         when STORE_ERRNO_HEADER_WORD =>
            header_data_bus <= '0' & error_code;
            head_wren       <= '1';
            ena_word_count  <= '1';

         when STORE_HEADER_WORD =>
            header_data_bus <= data_bus;
            head_wren       <= '1';
            ena_word_count  <= '1';

         when NEXT_HEADER_WORD =>
            word_ack        <= '1';

         when DONE_HEADER_STORE =>
            cmd_sent_o <= '1';

         when TX_HEADER =>
            rdy_o           <= '1';
            ena_word_count  <= ack_i;

         when TX_DATA_RATE =>
            rdy_o           <= '1';
            ena_word_count  <= ack_i;

         when TX_ROW_LEN =>
            rdy_o           <= '1';
            ena_word_count  <= ack_i;

         when TX_NUM_ROWS =>
            rdy_o           <= '1';
            ena_word_count  <= ack_i;

         when TX_SYNC_NUM =>
            rdy_o           <= '1';
            ena_word_count  <= ack_i;

         when TX_FRAME_SEQUENCE_NUM =>
            rdy_o           <= '1';
            ena_word_count  <= ack_i;

         when TX_ACTIVE_CLK =>
            rdy_o           <= '1';
            ena_word_count  <= ack_i;

         when TX_SYNC_BOX_ERR =>
            rdy_o           <= '1';
            ena_word_count  <= ack_i;

         when TX_SYNC_BOX_FR =>
            rdy_o           <= '1';
            ena_word_count  <= ack_i;

         when TX_DV_NUM =>
            rdy_o           <= '1';
            ena_word_count  <= ack_i;

         when TX_TES_BIAS_LEVEL =>
            rdy_o           <= '1';
            ena_word_count  <= ack_i;

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
         lvds_reply_ac_a   => lvds_reply_ac_a,
         lvds_reply_bc1_a  => lvds_reply_bc1_a,
         lvds_reply_bc2_a  => lvds_reply_bc2_a,
         lvds_reply_bc3_a  => lvds_reply_bc3_a,
         lvds_reply_rc1_a  => lvds_reply_rc1_a,
         lvds_reply_rc2_a  => lvds_reply_rc2_a,
         lvds_reply_rc3_a  => lvds_reply_rc3_a,
         lvds_reply_rc4_a  => lvds_reply_rc4_a,
         lvds_reply_cc_a   => lvds_reply_cc_a,

         card_data_size_i  => data_size_t,  -- Add this to the pack file
         -- cmd_translator interface
         cmd_code_i        => cmd_code,
         par_id_i          => par_id,

         -- fibre interface:
         size_o            => data_size,
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