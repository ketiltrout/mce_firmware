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
-- $Id: reply_queue.vhd,v 1.6 2004/11/25 01:32:37 bburger Exp $
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
-- Revision 1.6  2004/11/25 01:32:37  bburger
-- Bryce:
-- - Changed to cmd_code over the bus backplane to read/write only
-- - Added interface signals for internal commands
-- - RB command data-sizes are correctly handled
--
-- Revision 1.5  2004/11/13 03:30:25  bburger
-- Bryce:  card_id renamed to card_addr
--
-- Revision 1.4  2004/11/13 03:25:34  bburger
-- Bryce:  integration with ernie's side of reply_queue
--
-- Revision 1.3  2004/11/08 23:40:29  bburger
-- Bryce:  small modifications
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

library work;
use work.cmd_queue_ram40_pack.all;
use work.reply_queue_pack.all;

entity reply_queue is
   port(
      -- cmd_queue interface
      cmd_to_retire_i   : in std_logic;                                           
      cmd_retired_o     : out std_logic;                                          
      cmd_i             : in std_logic_vector(QUEUE_WIDTH-1 downto 0);            
      
      -- reply_translator interface (from reply_queue, i.e. these signals are de-multiplexed from retire and sequencer)
      size_o            : out integer;
      data_o            : out std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
      error_code_o      : out std_logic_vector(BB_STATUS_WIDTH-1 downto 0);
      matched_o         : out std_logic; -- reply ready for tx
      rdy_o             : out std_logic; -- word is valid
      ack_i             : in std_logic;
      
      -- reply_translator interface (from reply_queue_retire)
      cmd_sent_i        : in std_logic;
      cmd_code_o        : out std_logic_vector(BB_COMMAND_TYPE_WIDTH-1 downto 0); 
      param_id_o        : out std_logic_vector(BB_PARAMETER_ID_WIDTH-1 downto 0); 
      card_addr_o       : out std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0); 
      stop_bit_o        : out std_logic;                                          
      last_frame_bit_o  : out std_logic;                                          
      frame_seq_num_o   : out std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);     
      internal_cmd_o    : out std_logic;

      -- Bus Backplane interface
      lvds_rx_ac_a      : in std_logic;
      lvds_rx_bc1_a     : in std_logic;
      lvds_rx_bc2_a     : in std_logic;
      lvds_rx_bc3_a     : in std_logic;
      lvds_rx_rc1_a     : in std_logic;
      lvds_rx_rc2_a     : in std_logic;
      lvds_rx_rc3_a     : in std_logic;
      lvds_rx_rc4_a     : in std_logic;
      
      -- Global signals
      clk_i             : in std_logic;
      comm_clk_i        : in std_logic;
      rst_i             : in std_logic
   );
end reply_queue;

architecture behav of reply_queue is

   -- Internal interface signals to/from reply_queue_retire and reply_queue_sequencer
   signal mop_num            : std_logic_vector(BB_MACRO_OP_SEQ_WIDTH-1 downto 0);
   signal uop_num            : std_logic_vector(BB_MICRO_OP_SEQ_WIDTH-1 downto 0);
   signal cmd_rdy            : std_logic;
   signal card_addr          : std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0); 
   signal cmd_code           : std_logic_vector(BB_COMMAND_TYPE_WIDTH-1 downto 0); 
   
   -- cmd_queue signals for stop commands
   signal cq_size            : integer;
   signal cq_data            : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal cq_rdy             : std_logic; -- word is valid
   signal cq_ack             : std_logic;
   signal cq_err             : std_logic_vector(BB_STATUS_WIDTH-1 downto 0);

   -- reply_queue signals for all other commands
   signal rq_size            : integer;
   signal rq_data            : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal rq_rdy             : std_logic; -- word is valid
   signal rq_ack             : std_logic;
   signal rq_start           : std_logic;
   signal rq_match           : std_logic;
   signal rq_err             : std_logic_vector(BB_STATUS_WIDTH-1 downto 0);
   
begin   
   
   cmd_code_o    <= cmd_code;
   card_addr_o   <= card_addr;
   size_o        <= cq_size when cmd_code =  STOP else rq_size;
   data_o        <= cq_data when cmd_code =  STOP else rq_data;
   rdy_o         <= cq_rdy  when cmd_code =  STOP else rq_rdy;   
   matched_o     <= cmd_rdy when cmd_code =  STOP else rq_match;
   error_code_o  <= cq_err  when cmd_code =  STOP else rq_err;
   
   cq_ack        <= ack_i   when cmd_code =  STOP else '0';
   rq_ack        <= ack_i   when cmd_code /= STOP else '0';
   rq_start      <= cmd_rdy when cmd_code /= STOP else '0';
   
   
   rqr : reply_queue_retire
      port map(
         cmd_to_retire_i   => cmd_to_retire_i,
         cmd_sent_o        => cmd_retired_o,
         cmd_i             => cmd_i,
         
         cmd_sent_i        => cmd_sent_i,        
         cmd_code_o        => cmd_code,   
         param_id_o        => param_id_o,   
         stop_bit_o        => stop_bit_o,       
         last_frame_bit_o  => last_frame_bit_o,     
         frame_seq_num_o   => frame_seq_num_o,
         internal_cmd_o    => internal_cmd_o,

         card_addr_o       => card_addr,    

         size_o            => cq_size,
         data_o            => cq_data,
         rdy_o             => cq_rdy,
         error_code_o      => cq_err,
         ack_i             => cq_ack,      
         
         mop_num_o         => mop_num,
         uop_num_o         => uop_num,
         cmd_rdy_o         => cmd_rdy,

         clk_i             => clk_i,     
         comm_clk_i        => comm_clk_i,
         rst_i             => rst_i   
      );               

   rqs : reply_queue_sequencer
      port map(
         clk_i             => clk_i,
         rst_i             => rst_i,
 
         -- fibre interface:
         size_o            => rq_size,
         data_o            => rq_data,
         rdy_o             => rq_rdy,
         ack_i             => rq_ack,
        
         -- cmd_queue interface:
         macro_op_i        => mop_num,
         micro_op_i        => uop_num,
         card_addr_i       => card_addr,
         match_o           => rq_match,
         start_i           => rq_start
     );

end behav;