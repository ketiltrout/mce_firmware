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
-- $Id: reply_queue_retire.vhd,v 1.13 2005/03/16 02:20:58 bburger Exp $
--
-- Project:    SCUBA2
-- Author:     Bryce Burger
-- Organisation:  UBC
--
-- Description:
-- This file implements the reply_queue_retire block of the reply_queue
-- block on the clock card.
--
-- Revision history:
-- $Log: reply_queue_retire.vhd,v $
-- Revision 1.13  2005/03/16 02:20:58  bburger
-- bryce:  removed mem_clk from the cmd_queue and sync_gen blocks
--
-- Revision 1.12  2005/02/20 02:00:29  bburger
-- Bryce:  integrated the reply_queue and cmd_queue with respect to the timeout signal.
--
-- Revision 1.11  2004/12/06 07:22:34  bburger
-- Bryce:
-- Created pack files for the card top-levels.
-- Added some simulation signals to the top-levels (i.e. clocks)
--
-- Revision 1.10  2004/12/04 02:03:06  bburger
-- Bryce:  fixing some problems associated with integrating the reply_queue
--
-- Revision 1.9  2004/11/30 22:58:47  bburger
-- Bryce:  reply_queue integration
--
-- Revision 1.8  2004/11/30 04:57:58  erniel
-- fixed error code width
--
-- Revision 1.7  2004/11/30 03:22:47  bburger
-- Bryce:  building reply_queue top-level interface and functionality
--
-- Revision 1.6  2004/11/30 02:49:26  erniel
-- fixed output logic (removed dependancy on next_state)
--
-- Revision 1.5  2004/11/25 01:32:37  bburger
-- Bryce:
-- - Changed to cmd_code over the bus backplane to read/write only
-- - Added interface signals for internal commands
-- - RB command data-sizes are correctly handled
--
-- Revision 1.4  2004/11/13 03:25:34  bburger
-- Bryce:  integration with ernie's side of reply_queue
--
-- Revision 1.3  2004/10/26 23:59:16  bburger
-- Bryce:  working out the bugs from the cmd_queue<->reply_queue interface
--
-- Revision 1.2  2004/10/22 01:54:38  bburger
-- Bryce:  fixed bugs
--
-- Revision 1.1  2004/10/21 00:45:38  bburger
-- Bryce:  new
--
--
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library sys_param;
use sys_param.command_pack.all;

library components;
use components.component_pack.all;

library work;
use work.cmd_queue_ram40_pack.all;
use work.cmd_queue_pack.all;

entity reply_queue_retire is
   port(
      -- cmd_queue interface control
      cmd_to_retire_i   : in std_logic;                                           
      cmd_sent_o        : out std_logic;
      cmd_timeout_o     : out std_logic;
      
      -- cmd_queue interface data
      cmd_i             : in std_logic_vector(QUEUE_WIDTH-1 downto 0);            
      
      -- reply_translator interface control
      cmd_sent_i        : in std_logic;
      cmd_valid_o       : out std_logic; --

      rdy_o             : out std_logic;
      ack_i             : in std_logic;      
      
      -- reply_translator interface data
      cmd_code_o        : out std_logic_vector(BB_COMMAND_TYPE_WIDTH-1 downto 0); 
      param_id_o        : out std_logic_vector(BB_PARAMETER_ID_WIDTH-1 downto 0); 
      stop_bit_o        : out std_logic;                                          
      last_frame_bit_o  : out std_logic;                                          
      frame_seq_num_o   : out std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);     
      internal_cmd_o    : out std_logic;      
      
      size_o            : out integer;
      data_o            : out std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
      error_code_o      : out std_logic_vector(29 downto 0); 
      
      -- reply_translator and reply_queue_sequencer interface
      card_addr_o       : out std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0);
      
      -- reply_queue_sequencer interface control
      matched_i         : in std_logic;
      timeout_i         : in std_logic;
      cmd_rdy_o         : out std_logic;
     
      -- reply_queue_sequencer interface data
      mop_num_o         : out std_logic_vector(BB_MACRO_OP_SEQ_WIDTH-1 downto 0);
      uop_num_o         : out std_logic_vector(BB_MICRO_OP_SEQ_WIDTH-1 downto 0);

      -- Global signals
      clk_i             : in std_logic;
      comm_clk_i        : in std_logic;
      rst_i             : in std_logic
   );
end reply_queue_retire;

architecture behav of reply_queue_retire is

   -- Signals from the reply_translator
   signal ack         : std_logic;
   
   -- Internal signals
   signal matched     : std_logic;
   signal cmd_rdy     : std_logic;
   signal cmd_code    : std_logic_vector(BB_COMMAND_TYPE_WIDTH-1 downto 0); 
   
   -- Signals for the registers that store the four cmd_queue words
   signal header_a    : std_logic_vector(QUEUE_WIDTH-1 downto 0);
   signal header_b    : std_logic_vector(QUEUE_WIDTH-1 downto 0);
   signal header_c    : std_logic_vector(QUEUE_WIDTH-1 downto 0);
   signal header_d    : std_logic_vector(QUEUE_WIDTH-1 downto 0);
   signal header_a_en : std_logic;
   signal header_b_en : std_logic;
   signal header_c_en : std_logic;
   signal header_d_en : std_logic;

   -- Retire FSM:  waits for replies from the Bus Backplane, and retires pending instructions in the the command queue
   type retire_states is (IDLE, HEADERA, HEADERB, HEADERC, HEADERD, RECEIVED, WAIT_FOR_MATCH, WAIT_FOR_ACK);
   signal present_retire_state : retire_states;
   signal next_retire_state    : retire_states;

begin
 
   ---------------------------------------------------------
   -- Edge-sensitive registers
   ---------------------------------------------------------
   header_a_reg : reg
      generic map(
         WIDTH      => PACKET_WORD_WIDTH
      )
      port map(
         clk_i      => clk_i,
         rst_i      => rst_i,
         ena_i      => header_a_en,
         reg_i      => cmd_i,
         reg_o      => header_a
      );

   header_b_reg : reg
      generic map(
         WIDTH      => PACKET_WORD_WIDTH
      )
      port map(
         clk_i      => clk_i,
         rst_i      => rst_i,
         ena_i      => header_b_en,
         reg_i      => cmd_i,
         reg_o      => header_b
      );

   header_c_reg : reg
      generic map(
         WIDTH      => PACKET_WORD_WIDTH
      )
      port map(
         clk_i      => clk_i,
         rst_i      => rst_i,
         ena_i      => header_c_en,
         reg_i      => cmd_i,
         reg_o      => header_c
      );

   header_d_reg : reg
      generic map(
         WIDTH      => PACKET_WORD_WIDTH
      )
      port map(
         clk_i      => clk_i,
         rst_i      => rst_i,
         ena_i      => header_d_en,
         reg_i      => cmd_i,
         reg_o      => header_d
      );

   -- If it is a GO or ST command, then it is 'matched' immediately, and we do not wait for a response from BB
   matched   <= cmd_rdy when (cmd_code =  STOP or  cmd_code =  START) else matched_i;
   
   -- Only assert cmd_rdy to the reply_queue_sequencer if we need to wait for a response
   cmd_rdy_o <= cmd_rdy when (cmd_code /= STOP and cmd_code /= START) else '0';

   -- Some of the outputs to reply_translator and lvds_rx fifo's
   cmd_code_o        <= cmd_code;
   cmd_code          <= header_a(ISSUE_SYNC_END-1 downto COMMAND_TYPE_END);      
   param_id_o        <= header_b(CARD_ADDR_END-1 downto PARAM_ID_END);   
   stop_bit_o        <= header_c(1);  
   last_frame_bit_o  <= header_c(0);   
   frame_seq_num_o   <= header_d;
   internal_cmd_o    <= header_c(2);   
   card_addr_o       <= header_b(QUEUE_WIDTH-1 downto CARD_ADDR_END);

   -- Internal signal assignments to the lvds_rx fifo's
   mop_num_o         <= header_b(PARAM_ID_END-1 downto MOP_END);
   uop_num_o         <= header_b(MOP_END-1 downto UOP_END);
   
   -- Outputs for STOP commands
   size_o            <= 0;
   data_o            <= (others => '0');
   error_code_o      <= (others => '0');
   rdy_o             <= '0';
   ack               <= ack_i;
   
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

   retire_state_NS: process(present_retire_state, cmd_to_retire_i, cmd_sent_i, matched, timeout_i)
   begin
      -- Default Values
      next_retire_state <= present_retire_state;
      
      case present_retire_state is
         when IDLE =>
            if (cmd_to_retire_i = '1') then
               next_retire_state <= HEADERA;
            else
               next_retire_state <= IDLE;
            end if;
         when HEADERA =>
            next_retire_state <= HEADERB;
         when HEADERB =>
            next_retire_state <= HEADERC;
         when HEADERC =>
            next_retire_state <= HEADERD;
         when HEADERD =>
            next_retire_state <= RECEIVED;
         when RECEIVED =>
            next_retire_state <= WAIT_FOR_MATCH;
         when WAIT_FOR_MATCH =>
            if(matched = '1') then
               next_retire_state <= WAIT_FOR_ACK;
            elsif(timeout_i = '1') then
               next_retire_state <= IDLE;
            end if;
         when WAIT_FOR_ACK =>
            if(cmd_sent_i = '1') then
               next_retire_state <= IDLE;
            end if;
         when others =>
            next_retire_state <= IDLE;
      end case;
   end process;

   retire_state_out: process(present_retire_state, cmd_sent_i, timeout_i)
   begin   
      -- Default values
      header_a_en  <= '0';
      header_b_en  <= '0';
      header_c_en  <= '0';
      header_d_en  <= '0';
      cmd_sent_o   <= '0';
      cmd_rdy      <= '0';
      cmd_valid_o  <= '0';
      cmd_timeout_o <= '0';

      case present_retire_state is
         when IDLE =>
--            if(cmd_to_retire_i = '1') then
--               header_a_en <= '1';
--            end if;
         
         when HEADERA =>
            header_a_en  <= '1';

         when HEADERB =>
            header_b_en  <= '1';

         when HEADERC =>
            header_c_en  <= '1';
            
         when HEADERD => 
            header_d_en  <= '1';

         when RECEIVED =>
            cmd_rdy      <= '1';

         when WAIT_FOR_MATCH =>
            cmd_rdy       <= '1';
            cmd_timeout_o <= timeout_i;
            
         when WAIT_FOR_ACK =>
            cmd_rdy      <= '1';
            cmd_valid_o  <= '1';
            if(cmd_sent_i = '1') then
               cmd_sent_o <= '1';
            end if;
            
         when others =>

      end case;
   end process;

end behav;