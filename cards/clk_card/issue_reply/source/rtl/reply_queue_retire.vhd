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
-- $Id: reply_queue_retire.vhd,v 1.5 2004/11/25 01:32:37 bburger Exp $
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
      -- cmd_queue interface
      uop_rdy_i         : in std_logic;                                           
      uop_ack_o         : out std_logic;                                          
      uop_i             : in std_logic_vector(QUEUE_WIDTH-1 downto 0);            
      
      -- reply_translator interface 
      m_op_done_i       : in std_logic;
      m_op_cmd_code_o   : out std_logic_vector(BB_COMMAND_TYPE_WIDTH-1 downto 0); 
      m_op_param_id_o   : out std_logic_vector(BB_PARAMETER_ID_WIDTH-1 downto 0); 
      m_op_card_addr_o  : out std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0); 
      m_op_ack_i        : in std_logic;    
      cmd_stop_o        : out std_logic;                                          
      last_frame_o      : out std_logic;                                          
      frame_seq_num_o   : out std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);     
      internal_cmd_o    : out std_logic;
     
      -- Internal interface signals to the lvds_rx fifo's
      mop_num_o         : out std_logic_vector(BB_MACRO_OP_SEQ_WIDTH-1 downto 0);
      uop_num_o         : out std_logic_vector(BB_MICRO_OP_SEQ_WIDTH-1 downto 0);
--      match_o           : out std_logic;
      start_o           : out std_logic;
--      done_o            : out std_logic      

      -- Global signals
      clk_i             : in std_logic;
      comm_clk_i        : in std_logic;
      rst_i             : in std_logic
   );
end reply_queue_retire;

architecture behav of reply_queue_retire is

signal uop_recieved : std_logic;

-- Signals for the registers that store the four cmd_queue words
signal header_a : std_logic_vector(QUEUE_WIDTH-1 downto 0);
signal header_b : std_logic_vector(QUEUE_WIDTH-1 downto 0);
signal header_c : std_logic_vector(QUEUE_WIDTH-1 downto 0);
signal header_d : std_logic_vector(QUEUE_WIDTH-1 downto 0);
signal header_a_en : std_logic;
signal header_b_en : std_logic;
signal header_c_en : std_logic;
signal header_d_en : std_logic;

-- Retire FSM:  waits for replies from the Bus Backplane, and retires pending instructions in the the command queue
type retire_states is (IDLE, HEADERB, HEADERC, HEADERD, RECEIVED);
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
         reg_i      => uop_i,
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
         reg_i      => uop_i,
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
         reg_i      => uop_i,
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
         reg_i      => uop_i,
         reg_o      => header_d
      );

   -- Some of the outputs to reply_translator and lvds_rx fifo's
   m_op_cmd_code_o   <= header_a(ISSUE_SYNC_END-1 downto COMMAND_TYPE_END);      
   m_op_card_addr_o  <= header_b(QUEUE_WIDTH-1 downto CARD_ADDR_END);
   m_op_param_id_o   <= header_b(CARD_ADDR_END-1 downto PARAM_ID_END);   
   internal_cmd_o    <= header_c(2);
   cmd_stop_o        <= header_c(1);  
   last_frame_o      <= header_c(0);   
   frame_seq_num_o   <= header_d;
   
   -- Internal signal assignments to the lvds_rx fifo's
   mop_num_o         <= header_b(PARAM_ID_END-1 downto MOP_END);
   uop_num_o         <= header_b(MOP_END-1 downto UOP_END);
   
   -- The acknowledgement of a m-op sent comes from the reply_translator
   uop_ack_o         <= m_op_ack_i;
   
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

   retire_state_NS: process(present_retire_state, uop_rdy_i)
   begin
      case present_retire_state is
         when IDLE =>
            if (uop_rdy_i = '1') then
               next_retire_state <= HEADERB;
            else
               next_retire_state <= IDLE;
            end if;
         when HEADERB =>
            next_retire_state <= HEADERC;
         when HEADERC =>
            next_retire_state <= HEADERD;
         when HEADERD =>
            next_retire_state <= RECEIVED;
         when RECEIVED =>
            next_retire_state <= IDLE;
         when others =>
            next_retire_state <= IDLE;
      end case;
   end process;

   retire_state_out: process(present_retire_state, uop_rdy_i) --next_retire_state)
   begin
   
      -- Default values
      header_a_en  <= '0';
      header_b_en  <= '0';
      header_c_en  <= '0';
      header_d_en  <= '0';
      start_o      <= '0';

      case present_retire_state is
         when IDLE =>
--            if (next_retire_state = HEADERB) then
            if(uop_rdy_i = '1') then
               header_a_en <= '1';
            end if;
         
         when HEADERB =>
            header_b_en  <= '1';

         when HEADERC =>
            header_c_en  <= '1';
            
         when HEADERD => 
            header_d_en  <= '1';

         when RECEIVED =>
            start_o      <= '1';
            
         when others =>

      end case;
   end process;

end behav;