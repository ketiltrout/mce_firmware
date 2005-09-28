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
-- $Id: reply_queue.vhd,v 1.16 2005/03/23 19:25:54 bburger Exp $
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
-- Revision 1.16  2005/03/23 19:25:54  bburger
-- Bryce:  Added a debugging trigger
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
use work.reply_queue_pack.all;

entity reply_queue is
   port(
      -- cmd_queue interface
      cmd_to_retire_i   : in std_logic;                                           
      cmd_sent_o        : out std_logic;                                          
      cmd_i             : in std_logic_vector(QUEUE_WIDTH-1 downto 0);   
      cmd_timeout_o     : out std_logic;         
      
      -- reply_translator interface (from reply_queue, i.e. these signals are de-multiplexed from retire and sequencer)
      size_o            : out integer;
      data_o            : out std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
      error_code_o      : out std_logic_vector(29 downto 0);
      rdy_o             : out std_logic; -- word is valid
      ack_i             : in std_logic;
      
      -- reply_translator interface (from reply_queue_retire)
      cmd_sent_i        : in std_logic;
      cmd_valid_o       : out std_logic; -- reply ready for tx
      cmd_code_o        : out std_logic_vector(BB_COMMAND_TYPE_WIDTH-1 downto 0); 
      param_id_o        : out std_logic_vector(BB_PARAMETER_ID_WIDTH-1 downto 0); 
      card_addr_o       : out std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0); 
      stop_bit_o        : out std_logic;                                          
      last_frame_bit_o  : out std_logic;                                          
      frame_seq_num_o   : out std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);     
      internal_cmd_o    : out std_logic;

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
      
      -- Global signals
      clk_i             : in std_logic;
      comm_clk_i        : in std_logic;
      rst_i             : in std_logic
   );
end reply_queue;

architecture behav of reply_queue is

   -- Internal signals
   signal mop_num            : std_logic_vector(BB_MACRO_OP_SEQ_WIDTH-1 downto 0);
   signal uop_num            : std_logic_vector(BB_MICRO_OP_SEQ_WIDTH-1 downto 0);
   signal card_addr          : std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0); 
   signal matched            : std_logic;
   signal timeout            : std_logic;
   signal cmd_rdy            : std_logic;
   signal cmd_code           : std_logic_vector(BB_COMMAND_TYPE_WIDTH-1 downto 0); 

   -- Reply_queue_receiver interfaces
   signal ac_data            : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal ac_rdy             : std_logic;
   signal ac_ack             : std_logic;
   signal ac_discard         : std_logic;
   
   signal bc1_data           : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal bc1_rdy            : std_logic;
   signal bc1_ack            : std_logic;
   signal bc1_discard        : std_logic;
   
   signal bc2_data           : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal bc2_rdy            : std_logic;
   signal bc2_ack            : std_logic;
   signal bc2_discard        : std_logic;
   
   signal bc3_data           : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal bc3_rdy            : std_logic;
   signal bc3_ack            : std_logic;
   signal bc3_discard        : std_logic;
   
   signal rc1_data           : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal rc1_rdy            : std_logic;
   signal rc1_ack            : std_logic;
   signal rc1_discard        : std_logic;
   
   signal rc2_data           : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal rc2_rdy            : std_logic;
   signal rc2_ack            : std_logic;
   signal rc2_discard        : std_logic;
   
   signal rc3_data           : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal rc3_rdy            : std_logic;
   signal rc3_ack            : std_logic;
   signal rc3_discard        : std_logic;
   
   signal rc4_data           : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal rc4_rdy            : std_logic;
   signal rc4_ack            : std_logic;
   signal rc4_discard        : std_logic;
   
   signal cc_data            : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal cc_rdy             : std_logic;
   signal cc_ack             : std_logic;
   signal cc_discard         : std_logic;
 
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

   -- Some of the outputs to reply_translator and lvds_rx fifo's
   cmd_code_o        <= cmd_code;
   card_addr_o       <= card_addr;   
   cmd_code          <= header_a(ISSUE_SYNC_END-1 downto COMMAND_TYPE_END);      
   card_addr         <= header_b(QUEUE_WIDTH-1 downto CARD_ADDR_END);
   param_id_o        <= header_b(CARD_ADDR_END-1 downto PARAM_ID_END);   
   last_frame_bit_o  <= header_c(0);   
   stop_bit_o        <= header_c(1);  
   internal_cmd_o    <= header_c(2);   
   frame_seq_num_o   <= header_d;

   -- Internal signal assignments to the lvds_rx fifo's
   mop_num           <= header_b(PARAM_ID_END-1 downto MOP_END);
   uop_num           <= header_b(MOP_END-1 downto UOP_END);
   
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

   retire_state_NS: process(present_retire_state, cmd_to_retire_i, cmd_sent_i, matched, timeout)
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
            elsif(timeout = '1') then
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

   retire_state_out: process(present_retire_state, cmd_sent_i, timeout)
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
            cmd_timeout_o <= timeout;
            
         when WAIT_FOR_ACK =>
            cmd_rdy      <= '1';
            cmd_valid_o  <= '1';
            if(cmd_sent_i = '1') then
               cmd_sent_o <= '1';
            end if;
            
         when others =>

      end case;
   end process;


   rq_seq : reply_queue_sequencer
      port map(
         -- for debugging
         timer_trigger_o => open,
                  
         clk_i        => clk_i,
         rst_i        => rst_i,
 
         ac_data_i     => ac_data,
         ac_rdy_i      => ac_rdy,
         ac_ack_o      => ac_ack,
         ac_discard_o  => ac_discard,
         
         bc1_data_i    => bc1_data,
         bc1_rdy_i     => bc1_rdy,
         bc1_ack_o     => bc1_ack,
         bc1_discard_o => bc1_discard,
         
         bc2_data_i    => bc2_data,
         bc2_rdy_i     => bc2_rdy,
         bc2_ack_o     => bc2_ack,
         bc2_discard_o => bc2_discard,
         
         bc3_data_i    => bc3_data,
         bc3_rdy_i     => bc3_rdy,
         bc3_ack_o     => bc3_ack,
         bc3_discard_o => bc3_discard,
         
         rc1_data_i    => rc1_data,
         rc1_rdy_i     => rc1_rdy,
         rc1_ack_o     => rc1_ack,
         rc1_discard_o => rc1_discard,
         
         rc2_data_i    => rc2_data,
         rc2_rdy_i     => rc2_rdy,
         rc2_ack_o     => rc2_ack,
         rc2_discard_o => rc2_discard,
         
         rc3_data_i    => rc3_data,
         rc3_rdy_i     => rc3_rdy,
         rc3_ack_o     => rc3_ack,
         rc3_discard_o => rc3_discard,
         
         rc4_data_i    => rc4_data,
         rc4_rdy_i     => rc4_rdy,
         rc4_ack_o     => rc4_ack,
         rc4_discard_o => rc4_discard,
         
         cc_data_i     => cc_data,
         cc_rdy_i      => cc_rdy,
         cc_ack_o      => cc_ack,
         cc_discard_o  => cc_discard,
         
         -- fibre interface:
         size_o       => size_o,
         error_o      => error_code_o,
         data_o       => data_o,
         rdy_o        => rdy_o,
         ack_i        => ack_i,
        
         -- cmd_queue interface:
         macro_op_i   => mop_num,
         micro_op_i   => uop_num,
         card_addr_i  => card_addr,
         cmd_valid_i  => cmd_rdy,
         matched_o    => matched,
         timeout_o    => timeout
     );

   rx_ac : reply_queue_receive
      port map(
         clk_i        => clk_i,
         comm_clk_i   => comm_clk_i,
         rst_i        => rst_i,
               
         lvds_reply_i => lvds_reply_ac_a,
             
         data_o       => ac_data,
         rdy_o        => ac_rdy,
         ack_i        => ac_ack,
         discard_i    => ac_discard
      );
   
   rx_bc1 : reply_queue_receive
      port map(
         clk_i        => clk_i,
         comm_clk_i   => comm_clk_i,
         rst_i        => rst_i,
               
         lvds_reply_i => lvds_reply_bc1_a,
             
         data_o       => bc1_data,               
         rdy_o        => bc1_rdy,
         ack_i        => bc1_ack,
         discard_i    => bc1_discard
      );
   
   rx_bc2 : reply_queue_receive
      port map(
         clk_i        => clk_i,
         comm_clk_i   => comm_clk_i,
         rst_i        => rst_i,
               
         lvds_reply_i => lvds_reply_bc2_a,
             
         data_o       => bc2_data,
         rdy_o        => bc2_rdy,
         ack_i        => bc2_ack,
         discard_i    => bc2_discard
      );
   
   rx_bc3 : reply_queue_receive
      port map(
         clk_i        => clk_i,
         comm_clk_i   => comm_clk_i,
         rst_i        => rst_i,
               
         lvds_reply_i => lvds_reply_bc3_a,
             
         data_o       => bc3_data,
         rdy_o        => bc3_rdy,
         ack_i        => bc3_ack,
         discard_i    => bc3_discard
      );
      
   rx_rc1 : reply_queue_receive
      port map(
         clk_i        => clk_i,
         comm_clk_i   => comm_clk_i,
         rst_i        => rst_i,
               
         lvds_reply_i => lvds_reply_rc1_a,
             
         data_o       => rc1_data,
         rdy_o        => rc1_rdy,
         ack_i        => rc1_ack,
         discard_i    => rc1_discard
      );
      
   rx_rc2 : reply_queue_receive
      port map(
         clk_i        => clk_i,
         comm_clk_i   => comm_clk_i,
         rst_i        => rst_i,
               
         lvds_reply_i => lvds_reply_rc2_a,
             
         data_o       => rc2_data,
         rdy_o        => rc2_rdy,
         ack_i        => rc2_ack,
         discard_i    => rc2_discard
      );
      
   rx_rc3 : reply_queue_receive
      port map(
         clk_i        => clk_i,
         comm_clk_i   => comm_clk_i,
         rst_i        => rst_i,
               
         lvds_reply_i => lvds_reply_rc3_a,
             
         data_o       => rc3_data,
         rdy_o        => rc3_rdy,
         ack_i        => rc3_ack,
         discard_i    => rc3_discard
      );
      
   rx_rc4 : reply_queue_receive
      port map(
         clk_i        => clk_i,
         comm_clk_i   => comm_clk_i,
         rst_i        => rst_i,
               
         lvds_reply_i => lvds_reply_rc4_a,
             
         data_o       => rc4_data,
         rdy_o        => rc4_rdy,
         ack_i        => rc4_ack,
         discard_i    => rc4_discard
      );
   
   rx_cc : reply_queue_receive
      port map(
         clk_i        => clk_i,
         comm_clk_i   => comm_clk_i,
         rst_i        => rst_i,
               
         lvds_reply_i => lvds_reply_cc_a,
             
         data_o       => cc_data,                        
         rdy_o        => cc_rdy,
         ack_i        => cc_ack,
         discard_i    => cc_discard
      );
   
end behav;