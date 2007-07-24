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
-- <revision control keyword substitutions e.g. $Id: cmd_translator.vhd,v 1.48 2006/11/03 23:02:43 bburger Exp $>
--
-- Project:       SCUBA-2
-- Author:        Jonathan Jacob
--
-- Organisation:  UBC
--
-- Description:  This module is the fibre command translator.
--
-- Revision history:
--
-- <date $Date: 2006/11/03 23:02:43 $> -     <text>      - <initials $Author: bburger $>
--
-- $Log: cmd_translator.vhd,v $
-- Revision 1.48  2006/11/03 23:02:43  bburger
-- Bryce:  issue_reply now waits until the after the last data packet to send the reply to a stop command.
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library sys_param;
use sys_param.wishbone_pack.all;
use sys_param.command_pack.all;

library components;
use components.component_pack.all;

library work;
use work.sync_gen_pack.all;
use work.frame_timing_pack.all;
use work.issue_reply_pack.all;

entity cmd_translator is

port(
   -- global inputs
   rst_i                 : in  std_logic;
   clk_i                 : in  std_logic;

   -- inputs from fibre_rx
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

   -- sync_gen interface
   dv_mode_i             : in std_logic_vector(DV_SELECT_WIDTH-1 downto 0);

   -- dv_rx interface
   external_dv_i         : in std_logic;

   -- ret_dat_wbs interface
   tes_bias_toggle_en_i   : in std_logic;
   tes_bias_high_i        : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   tes_bias_low_i         : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   tes_bias_toggle_rate_i : in std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);
   status_cmd_en_i        : in std_logic;

   -- other inputs
   sync_number_i         : in  std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);

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
   num_rows_i            : in integer;
   tes_bias_step_level_o : out std_logic;

   -- input from the cmd_queue
   ack_i                 : in  std_logic;
   busy_i                : in std_logic; -- Not used here
   rdy_for_data_i        : in std_logic;

   -- outputs to the cmd_queue
   frame_seq_num_o       : out std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   frame_sync_num_o      : out std_logic_vector(SYNC_NUM_WIDTH-1 downto 0)
);
end cmd_translator;


architecture rtl of cmd_translator is

   -------------------------------------------------------------------------------------------
   -- data command control signals
   -------------------------------------------------------------------------------------------
   constant INPUT_NUM_SEL          : std_logic := '1';
   constant CURRENT_NUM_PLUS_1_SEL : std_logic := '0';

   type state is (IDLE, SIMPLE, FPGA_TEMP, CARD_TEMP, PSC_STATUS, BOX_TEMP, TES_BIAS, LATCH_TES_BIAS_DATA, DONE, UPDATE_FOR_NEXT, WAIT_FOR_ACK, ONE_MORE, STOP);
   signal current_state : state;
   signal next_state    : state;

   -- For tracking requests
   signal ret_dat_req         : std_logic;
   -- For acknowledging requests
   signal ret_dat_ack         : std_logic;

   -- If a ret_dat command comes in during an internal command, the cmd_translator messes up in the DONE state.
   -- For indicating the start of a data run
   signal ret_dat_start       : std_logic;
   signal ret_dat_done        : std_logic;
   -- For indicating a continuous data run
   signal ret_dat_in_progress : std_logic;

   -- Fibre_rx will be ack'd immediately upon starting a data run in the cmd_translator.
   -- This is to avoid tying it up during a data run -- it will thus be responsive to simple commands during a data run.
   signal f_rx_ret_dat_ack : std_logic;
   signal f_rx_card_addr   : std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0);
   signal f_rx_param_id    : std_logic_vector(BB_PARAMETER_ID_WIDTH-1 downto 0);
   signal f_rx_data        : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal f_rx_cmd_code    : std_logic_vector(FIBRE_PACKET_TYPE_WIDTH-1 downto 0);
   signal f_rx_num_data    : std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);
   signal external_dv_num  : std_logic_vector(DV_NUM_WIDTH-1 downto 0);

   signal sync_num         : std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);
   signal seq_num          : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal load_sync_num    : std_logic;
   signal next_sync_num    : std_logic;
   signal load_seq_num     : std_logic;
   signal next_seq_num     : std_logic;

   signal data_size        : std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);
   signal data_size_int    : integer range 0 to (2**BB_DATA_SIZE_WIDTH)-1;

   -------------------------------------------------------------------------------------------
   -- Internal command control signals
   -------------------------------------------------------------------------------------------
   constant NUM_INTERNAL_CMD_TYPES : integer := 4;
   constant FPGA_TEMPERATURE       : integer := 0;
   constant CARD_TEMPERATURE       : integer := 1;
   constant PSUC_STATUS            : integer := 2;
   constant BOX_TEMPERATURE        : integer := 3;

   signal internal_status_req : std_logic;
   signal internal_status_ack : std_logic;
   signal tes_bias_toggle_req : std_logic;
   signal tes_bias_toggle_ack : std_logic;
   signal toggle_which_way    : std_logic;
   signal toggle_en_delayed   : std_logic;

   signal next_toggle_sync    : std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);
   signal update_nts          : std_logic;

   signal timer_rst           : std_logic;
   signal time                : integer;

   signal internal_cmd_id     : integer range 0 to NUM_INTERNAL_CMD_TYPES;
   signal internal_cmd_ack    : std_logic;

   -------------------------------------------------------------------------------------------
   -- simple command control signals
   -------------------------------------------------------------------------------------------
   signal simple_cmd_ack : std_logic;
   signal simple_cmd_req : std_logic;

begin

   -------------------------------------------------------------------------------------------
   -- Combinatorial Logic
   -------------------------------------------------------------------------------------------
   -- Acknowledgement signal to fibre_rx
   ack_o <= f_rx_ret_dat_ack or simple_cmd_ack;

   -- Registered outputs to cmd_queue
   tes_bias_step_level_o  <= not toggle_which_way;

   frame_seq_num_o <= seq_num;
   frame_sync_num_o <= sync_num;

   -- Size calculation logic for data packets
   data_size_int          <= NO_CHANNELS * num_rows_i;
   data_size              <= conv_std_logic_vector(data_size_int,BB_DATA_SIZE_WIDTH);

   -------------------------------------------------------------------------------------------
   -- Registers
   -------------------------------------------------------------------------------------------
   process(rst_i, clk_i)
   begin
      if(rst_i = '1') then
         timer_rst            <= '1';
         internal_status_req  <= '0';
         tes_bias_toggle_req  <= '0';
         next_toggle_sync     <= (others => '0');
         toggle_which_way     <= '1';
         toggle_en_delayed    <= '0';
         f_rx_data            <= (others=>'0');
         f_rx_param_id        <= (others=>'0');
         f_rx_card_addr       <= (others=>'0');
         f_rx_cmd_code        <= (others=>'0');
         f_rx_num_data        <= (others=>'0');
         external_dv_num      <= (others=>'0');
         sync_num             <= (others=>'0');
         seq_num              <= (others=>'0');
         ret_dat_req          <= '0';
         internal_cmd_id      <=  0;
         simple_cmd_req       <= '0';
         ret_dat_in_progress  <= '0';

      elsif(clk_i'event and clk_i = '1') then

         toggle_en_delayed <= tes_bias_toggle_en_i;
         timer_rst         <= '0';

         -- internal_status_ack is asserted for two consecutive cycles to make sure that both timer and internal_status_req are cleared.
         if(internal_status_ack = '1') then
            internal_status_req  <= '0';
            timer_rst            <= '1';
         elsif(status_cmd_en_i = '1' and time >= INTERNAL_COMMAND_PERIOD) then
--         elsif(status_cmd_en_i = '1' and time >= 1000) then
            internal_status_req  <= '1';
         end if;

         -- Manage the TES toggling control signals
         if(tes_bias_toggle_en_i = '1' and next_toggle_sync = sync_number_i) then
            tes_bias_toggle_req <= '1';
         elsif(tes_bias_toggle_ack = '1') then
            tes_bias_toggle_req <= '0';
            toggle_which_way <= not toggle_which_way;
         end if;

         -- If it's time to toggle, or we detect a rising edge on the toggle enable line we update the TES toggle sync number.
         if(update_nts = '1' or (toggle_en_delayed = '0' and tes_bias_toggle_en_i = '1')) then
            next_toggle_sync <= sync_number_i + tes_bias_toggle_rate_i;
         end if;

         -- Latch important command information
         if(cmd_rdy_i = '1') then
            f_rx_param_id  <= param_id_i(BB_PARAMETER_ID_WIDTH-1 downto 0);
            f_rx_card_addr <= card_addr_i(BB_CARD_ADDRESS_WIDTH-1 downto 0);
            -- I'm not sure why I need this here
            f_rx_data      <= cmd_data_i;
            f_rx_cmd_code  <= cmd_code_i;
            f_rx_num_data  <= num_data_i(BB_DATA_SIZE_WIDTH-1 downto 0);
         end if;

         -- Track ret_dat commands
         if(ret_dat_ack = '1') then
            -- Data run is done
            ret_dat_req <= '0';
         elsif(cmd_rdy_i = '1') then
            if(param_id_i(BB_PARAMETER_ID_WIDTH-1 downto 0) = RET_DAT_ADDR) then
               -- Acknowledge the GO/ST command from fibre_rx, to clear it for a new command.
               if(cmd_code_i = GO) then
                  ret_dat_req <= '1';
               else
                  -- Assume it's a stop command
                  ret_dat_req <= '0';
               end if;
            end if;
         end if;

         if(ret_dat_done = '1') then
            ret_dat_in_progress <= '0';
         elsif(ret_dat_start = '1') then
            ret_dat_in_progress <= '1';
         end if;

         -- Track simple commands
         if(simple_cmd_ack = '1') then
            -- Simple command is done
            simple_cmd_req <= '0';
         elsif(cmd_rdy_i = '1') then
            if(param_id_i(BB_PARAMETER_ID_WIDTH-1 downto 0) /= RET_DAT_ADDR) then
               simple_cmd_req <= '1';
            end if;
         end if;

         -- Manage sync number
         if(load_sync_num = '1') then
            -- issue ret_dat on the following frame period
            sync_num <= sync_number_i + 1;
         elsif(next_sync_num = '1') then
            sync_num <= sync_num + data_rate_i;
         end if;

         -- Manage sequence number
         if(load_seq_num = '1') then
            -- issue ret_dat on the following frame period
            seq_num <= start_seq_num_i;
         elsif(next_seq_num = '1') then
            seq_num <= seq_num + 1;
         end if;

         -- internal_cmd_ack is asserted for one cycle after an internal command is complete.
         if(internal_cmd_ack = '1') then
            if(internal_cmd_id = 0) then
               internal_cmd_id <= 1;
            elsif(internal_cmd_id = 1) then
               internal_cmd_id <= 2;
            elsif(internal_cmd_id = 2) then
               internal_cmd_id <= 3;
            elsif(internal_cmd_id = 3) then
               internal_cmd_id <= 0;
            end if;
         else
            internal_cmd_id <= internal_cmd_id;
         end if;

      end if;
   end process;

   -------------------------------------------------------------------------------------------
   -- timer for issuing internal status commands
   -------------------------------------------------------------------------------------------
   timer : us_timer
   port map(
      clk           => clk_i,
      timer_reset_i => timer_rst,
      timer_count_o => time);

   -------------------------------------------------------------------------------------------
   -- sequencer for ret_dat state machine
   -------------------------------------------------------------------------------------------
   process(rst_i, clk_i)
   begin
      if rst_i = '1' then
         current_state      <= IDLE;
      elsif clk_i'event and clk_i = '1' then
         current_state      <= next_state;
      end if;
   end process;

   -------------------------------------------------------------------------------------------
   -- State machine for issuing ret_dat macro-ops.
   -- Next State logic
   -------------------------------------------------------------------------------------------
   process(current_state, dv_mode_i, ret_dat_req, external_dv_i, ack_i, seq_num, stop_seq_num_i,
      tes_bias_toggle_en_i, internal_status_req, internal_cmd_id, tes_bias_toggle_req,
      simple_cmd_req, rdy_for_data_i)
   begin
      next_state    <= current_state;
      ret_dat_start <= '0';
      ret_dat_done  <= '0';

      case current_state is
         when IDLE =>
            -- If there is a data command
            if(ret_dat_req = '1') then
               ret_dat_start <= '1';
               if(dv_mode_i = DV_INTERNAL) then
                  next_state <= WAIT_FOR_ACK;
               -- Issue the first ret_dat command on the next DV pulse
               elsif(dv_mode_i /= DV_INTERNAL and external_dv_i = '1') then
                  next_state <= WAIT_FOR_ACK;
               end if;
            -- If there is a simple command
            elsif(simple_cmd_req = '1') then
               next_state <= SIMPLE;
            -- If it is time to toggle the bias
            elsif(tes_bias_toggle_en_i = '1' and tes_bias_toggle_req = '1') then
               next_state <= TES_BIAS;
            -- If toggling is disabled and it is time to issue an internal command
            elsif(tes_bias_toggle_en_i = '0' and internal_status_req = '1') then
               if(internal_cmd_id = FPGA_TEMPERATURE) then
                  next_state <= FPGA_TEMP;
               elsif(internal_cmd_id = CARD_TEMPERATURE) then
                  next_state <= CARD_TEMP;
               elsif(internal_cmd_id = PSUC_STATUS) then
                  next_state <= PSC_STATUS;
               elsif(internal_cmd_id = BOX_TEMPERATURE) then
                  next_state <= BOX_TEMP;
               end if;
            end if;

         when WAIT_FOR_ACK =>
            -- If there are more data frames to go:
            if(ack_i = '1' and seq_num /= stop_seq_num_i) then
               -- Before moving on to UPDATE_FOR_NEXT, let's check for pending internal commands
               if(tes_bias_toggle_en_i = '1' and tes_bias_toggle_req = '1') then
                  next_state <= TES_BIAS;
               -- If toggling is enabled, internal commands are disabled to preserve the timing of the toggle commands
               elsif(tes_bias_toggle_en_i = '0' and internal_status_req = '1') then
                  if(internal_cmd_id = FPGA_TEMPERATURE) then
                     next_state <= FPGA_TEMP;
                  elsif(internal_cmd_id = CARD_TEMPERATURE) then
                     next_state <= CARD_TEMP;
                  elsif(internal_cmd_id = PSUC_STATUS) then
                     next_state <= PSC_STATUS;
                  elsif(internal_cmd_id = BOX_TEMPERATURE) then
                     next_state <= BOX_TEMP;
                  end if;
               -- If there are no pending internal commands, then we move on
               else
                  next_state <= UPDATE_FOR_NEXT;
               end if;
            -- There are no more data frames to be returned, so we return to IDLE
            elsif(ack_i = '1' and seq_num = stop_seq_num_i) then
               next_state <= IDLE;
               ret_dat_done <= '1';
            end if;

         when UPDATE_FOR_NEXT =>
            -- We stay in this state for one cycle if we're in internal-dv mode, otherwise we wait for the next dv-pulse.
            if(dv_mode_i = DV_INTERNAL) then
               if(ret_dat_req = '1') then
                  next_state <= WAIT_FOR_ACK;
               else
                  next_state <= STOP;
               end if;
            elsif(dv_mode_i /= DV_INTERNAL and external_dv_i = '1') then
               if(ret_dat_req = '1') then
                  next_state <= WAIT_FOR_ACK;
               else
                  next_state <= STOP;
               end if;
            end if;

         when STOP =>
            if(ack_i = '1') then
               next_state <= IDLE;
            end if;

         when SIMPLE =>
            if(ack_i = '1') then
               next_state <= IDLE;
            end if;

         when TES_BIAS =>
            if(rdy_for_data_i = '1') then
               next_state <= LATCH_TES_BIAS_DATA;
            end if;

         when LATCH_TES_BIAS_DATA =>
            if(ack_i = '1') then
               -- Directly to IDLE, no cleanup needed
               if(ret_dat_req = '1') then
                  next_state <= UPDATE_FOR_NEXT;
               else
                  next_state <= IDLE;
               end if;
            end if;

         when FPGA_TEMP =>
            if(ack_i = '1') then
               next_state <= DONE;
            end if;

         when CARD_TEMP =>
            if(ack_i = '1') then
               next_state <= DONE;
            end if;

         when PSC_STATUS =>
            if(ack_i = '1') then
               next_state <= DONE;
            end if;

         when BOX_TEMP =>
            if(ack_i = '1') then
               next_state <= DONE;
            end if;

         when DONE =>
            -- The DONE state is used to advance the index for which internal command to execute next
            if(ret_dat_req = '1') then
               next_state <= UPDATE_FOR_NEXT;
            else
               next_state <= IDLE;
            end if;

         when others =>
            next_state <= IDLE;
      end case;
   end process;

   -------------------------------------------------------------------------------------------
   -- Output logic:  signals that go to cmd_queue
   -------------------------------------------------------------------------------------------
   process(current_state, f_rx_card_addr, f_rx_param_id, data_size, f_rx_data, cmd_data_i,
      tes_bias_low_i, tes_bias_high_i, toggle_which_way, tes_bias_toggle_req, internal_status_req,
      f_rx_cmd_code, f_rx_num_data, data_clk_i)
   begin
      -- Default assignments for signals that are common for all commands
      card_addr_o      <= (others => '0');
      param_id_o       <= (others => '0');
      cmd_code_o       <= (others => '0');
      data_size_o      <= (others => '0');
      data_clk_o       <= '0';
      internal_cmd_o   <= '0';
      data_o           <= (others => '0');

      case current_state is
         when UPDATE_FOR_NEXT | WAIT_FOR_ACK =>
            card_addr_o          <= f_rx_card_addr;
            param_id_o           <= f_rx_param_id;
            cmd_code_o           <= DATA;
            data_size_o          <= data_size;
            data_clk_o           <= '0';
            internal_cmd_o       <= '0';
            data_o               <= f_rx_data;

         when SIMPLE =>
            card_addr_o          <= f_rx_card_addr;
            param_id_o           <= f_rx_param_id;
            cmd_code_o           <= f_rx_cmd_code;
            data_size_o          <= f_rx_num_data;
            data_clk_o           <= data_clk_i;
            internal_cmd_o       <= '0';
            data_o               <= cmd_data_i;

         when TES_BIAS =>
            if(tes_bias_toggle_req = '1') then
               card_addr_o       <= BIAS_CARD_2;
               param_id_o        <= BIAS_ADDR;
               cmd_code_o        <= WRITE_BLOCK;
               data_size_o       <= TES_BIAS_DATA_SIZE; -- 1 word
               data_clk_o        <= '0';
               internal_cmd_o    <= '1';

               if(toggle_which_way = '0') then
                  data_o         <= tes_bias_low_i;
               else
                  data_o         <= tes_bias_high_i;
               end if;
            end if;

         when LATCH_TES_BIAS_DATA =>
            if(tes_bias_toggle_req = '1') then
               card_addr_o       <= BIAS_CARD_2;
               param_id_o        <= BIAS_ADDR;
               cmd_code_o        <= WRITE_BLOCK;
               data_size_o       <= TES_BIAS_DATA_SIZE; -- 1 word
               -- cmd_queue is level-sensitive, not edge-sensitive.
               data_clk_o        <= '1';
               internal_cmd_o    <= '1';

               if(toggle_which_way = '0') then
                  data_o         <= tes_bias_low_i;
               else
                  data_o         <= tes_bias_high_i;
               end if;
            end if;

         when FPGA_TEMP =>
            if(internal_status_req = '1') then
               card_addr_o       <= ALL_FPGA_CARDS;
               param_id_o        <= FPGA_TEMP_ADDR;
               cmd_code_o        <= READ_BLOCK;
               data_size_o       <= FPGA_TEMP_DATA_SIZE;
               data_clk_o        <= '0';
               internal_cmd_o    <= '1';
               data_o            <= (others => '0');
            end if;

         when CARD_TEMP =>
            if(internal_status_req = '1') then
               card_addr_o       <= ALL_FPGA_CARDS;
               param_id_o        <= CARD_TEMP_ADDR;
               cmd_code_o        <= READ_BLOCK;
               data_size_o       <= CARD_TEMP_DATA_SIZE;
               data_clk_o        <= '0';
               internal_cmd_o    <= '1';
               data_o            <= (others => '0');
            end if;

         when PSC_STATUS =>
            if(internal_status_req = '1') then
               card_addr_o       <= POWER_SUPPLY_CARD;
               param_id_o        <= PSC_STATUS_ADDR;
               cmd_code_o        <= READ_BLOCK;
               data_size_o       <= PSC_STATUS_DATA_SIZE; -- 9 words
               data_clk_o        <= '0';
               internal_cmd_o    <= '1';
               data_o            <= (others => '0');
            end if;

         when BOX_TEMP =>
            if(internal_status_req = '1') then
               card_addr_o       <= CLOCK_CARD;
               param_id_o        <= BOX_TEMP_ADDR;
               cmd_code_o        <= READ_BLOCK;
               data_size_o       <= BOX_TEMP_DATA_SIZE;
               data_clk_o        <= '0';
               internal_cmd_o    <= '1';
               data_o            <= (others => '0');
            end if;

         when others =>
      end case;
   end process;

   -------------------------------------------------------------------------------------------
   -- Control logic:  control signals used internally for book-keeping
   -------------------------------------------------------------------------------------------
   process(current_state, ret_dat_req, stop_seq_num_i, seq_num, ack_i, dv_mode_i, external_dv_i,
      tes_bias_toggle_req, cmd_rdy_i, tes_bias_toggle_en_i)
   begin
      -- default assignments
      load_sync_num        <= '0';
      next_sync_num        <= '0';
      load_seq_num         <= '0';
      next_seq_num         <= '0';

      instr_rdy_o          <= '0';
      ret_dat_ack          <= '0';

      last_frame_o         <= '0';
      cmd_stop_o           <= '0';

      tes_bias_toggle_ack  <= '0';
      internal_status_ack  <= '0';
      update_nts           <= '0';

      internal_cmd_ack     <= '0';
      simple_cmd_ack       <= '0';
      f_rx_ret_dat_ack     <= '0';

      case current_state is
         when IDLE =>
            -- ret_dat_req may be asserted for some time before the cmd_queue is ready for the first ret_dat command
            -- Thus slide the sync number until the cmd_queue accepts the ret_dat command
            if(ret_dat_req = '1') then
               load_sync_num <= '1';
               load_seq_num  <= '1';

               -- Ack fibre_rx one cycle before entering the data process.
               -- This frees up fibre_rx for internal commands.
               if(dv_mode_i = DV_INTERNAL) then
                  f_rx_ret_dat_ack <= '1';
               elsif(dv_mode_i /= DV_INTERNAL and external_dv_i = '1') then
                  f_rx_ret_dat_ack <= '1';
               end if;

            -- If we aren't waiting to send the cmd_queue a ret_dat command, and if tes_bias_toggle_req is asserted
            -- then update the next toggle sync number.
            elsif(tes_bias_toggle_req = '1') then
               update_nts <= '1';
            end if;

         when WAIT_FOR_ACK =>
            instr_rdy_o <= '1';

            if(seq_num = stop_seq_num_i) then
               last_frame_o <= '1';
            end if;

            if(ack_i = '1' and seq_num /= stop_seq_num_i) then
               if(tes_bias_toggle_en_i = '1' and tes_bias_toggle_req = '1') then
                  update_nts <= '1';
               end if;
            elsif(ack_i = '1' and seq_num = stop_seq_num_i) then
               -- Ack the data run.
               ret_dat_ack <= '1';
               -- De-assert instr_rdy_o immediately to prevent cmd_queue from re-latching it
               instr_rdy_o <= '0';
            end if;

         when UPDATE_FOR_NEXT =>
            -- Either of these conditions are only met on the last clock period in this state.
            if(dv_mode_i = DV_INTERNAL) then
               next_sync_num <= '1';
               next_seq_num  <= '1';
            elsif(dv_mode_i /= DV_INTERNAL and external_dv_i = '1') then
               -- Since the timing of the DV pulse dictates the next data packet,
               -- we issue a ret_dat on the frame period immediately following a DV packet/pulse.
               -- Until the DV packet/pulse arrives, we slide the sync number
               load_sync_num <= '1';
               next_seq_num  <= '1';
            end if;

         when STOP =>
            instr_rdy_o  <= '1';
            last_frame_o <= '1';
            cmd_stop_o   <= '1';
            if(ack_i = '1') then
               -- Don't need to assert ret_dat_ack, because ret_dat_rdy is already low due to stop command
               -- De-assert instr_rdy_o immediately to prevent cmd_queue from re-latching it
               instr_rdy_o <= '0';
            end if;

         when SIMPLE =>
            instr_rdy_o <= cmd_rdy_i;

            if(ack_i = '1') then
               simple_cmd_ack <= '1';
            end if;

         when LATCH_TES_BIAS_DATA =>
            instr_rdy_o       <= '1';

            if(ack_i = '1') then
               tes_bias_toggle_ack <= '1';
            end if;

         when TES_BIAS =>
            instr_rdy_o <= '1';

         when FPGA_TEMP =>
            instr_rdy_o <= '1';
            if(ack_i = '1') then
               internal_status_ack <= '1';
            end if;

         when CARD_TEMP =>
            instr_rdy_o <= '1';
            if(ack_i = '1') then
               internal_status_ack <= '1';
            end if;

         when PSC_STATUS =>
            instr_rdy_o <= '1';
            if(ack_i = '1') then
               internal_status_ack <= '1';
            end if;

         when BOX_TEMP =>
            instr_rdy_o <= '1';
            if(ack_i = '1') then
               internal_status_ack <= '1';
            end if;

         when DONE =>
            internal_status_ack <= '1';
            internal_cmd_ack <= '1';

         when others =>
      end case;
   end process;

end rtl;