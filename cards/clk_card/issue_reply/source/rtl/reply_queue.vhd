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
-- $Id: reply_queue.vhd,v 1.1 2004/10/21 00:45:38 bburger Exp $
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
      uop_rdy_i         : in std_logic;                                           
      uop_ack_o         : out std_logic;                                          
      uop_i             : in std_logic_vector(QUEUE_WIDTH-1 downto 0);            
      
      -- reply_translator interface 
      m_op_done_o       : out std_logic;
      m_op_error_code_o : out std_logic_vector(BB_STATUS_WIDTH-1 downto 0); 
      m_op_cmd_code_o   : out std_logic_vector(BB_COMMAND_TYPE_WIDTH-1 downto 0); 
      m_op_param_id_o   : out std_logic_vector(BB_PARAMETER_ID_WIDTH-1 downto 0); 
      m_op_card_id_o    : out std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0); 
      fibre_word_o      : out std_logic_vector(PACKET_WORD_WIDTH-1 downto 0); 
      num_fibre_words_o : out std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);    
      fibre_word_req_i  : in std_logic; 
      fibre_word_rdy_o  : out std_logic;
      m_op_ack_i        : in std_logic;    
      cmd_stop_o        : out std_logic;                                          
      last_frame_o      : out std_logic;                                          
      frame_seq_num_o   : out std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);     
     
      -- Bus Backplane interface
      lvds_rx0a         : in std_logic;
      lvds_rx1a         : in std_logic;
      lvds_rx2a         : in std_logic;
      lvds_rx3a         : in std_logic;
      lvds_rx4a         : in std_logic;
      lvds_rx5a         : in std_logic;
      lvds_rx6a         : in std_logic;
      lvds_rx7a         : in std_logic;
      
      -- Global signals
      clk_i             : in std_logic;
      comm_clk_i        : in std_logic;
      rst_i             : in std_logic
   );
end reply_queue;

architecture behav of reply_queue is

   -- Internal interface signals to/from the lvds_rx fifo's
   signal mop_num   : std_logic_vector(BB_MACRO_OP_SEQ_WIDTH-1 downto 0);
   signal uop_num   : std_logic_vector(BB_MICRO_OP_SEQ_WIDTH-1 downto 0);
   signal mop_done  : std_logic := '0';
--   signal data_rdy  : std_logic;
--   signal data_stb  : std_logic;
--   signal data      : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
--   signal data_size : std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);
--   signal card_addr : std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0);
   
begin   
   
   m_op_done_o <= mop_done;
   
   rqr : reply_queue_retire
      port map(
         uop_rdy_i         => uop_rdy_i,
         uop_ack_o         => uop_ack_o,
         uop_i             => uop_i,     
         
         m_op_done_i       => mop_done,       
         m_op_cmd_code_o   => m_op_cmd_code_o,   
         m_op_param_id_o   => m_op_param_id_o,   
         m_op_card_id_o    => m_op_card_id_o,    
         m_op_ack_i        => m_op_ack_i,        
         cmd_stop_o        => cmd_stop_o,       
         last_frame_o      => last_frame_o,     
         frame_seq_num_o   => frame_seq_num_o,  
        
         mop_num_o           => mop_num,
         uop_num_o           => uop_num,

         clk_i             => clk_i,     
         comm_clk_i        => comm_clk_i,
         rst_i             => rst_i   
      );
   
end behav;