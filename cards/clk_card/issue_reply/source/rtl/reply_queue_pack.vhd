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
-- $Id$
--
-- Project:    SCUBA2
-- Author:     Bryce Burger, Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- This is the reply_queue pack file.
--
-- Revision history:
-- $Log$
--
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library sys_param;
use sys_param.command_pack.all;

library work;
use work.cmd_queue_ram40_pack.all;
use work.sync_gen_pack.all;

package reply_queue_pack is
   
   component reply_queue
      port(
          -- reply_queue interface
         uop_rdy_i         : in std_logic; -- Tells the reply_queue when valid m-op and u-op codes are asserted on it's interface
         uop_ack_o         : out std_logic; -- Tells the reply_queue that a reply to the u-op waiting to be retired has been found and it's status is asserted on uop_status_i
         uop_i             : in std_logic_vector(QUEUE_WIDTH-1 downto 0); --Tells the reply_queue the next u-op that the cmd_queue wants to retire
         
         -- reply_translator interface 
         m_op_done_o       : out std_logic;                                            -- macro op done
         m_op_ok_nEr_o     : out std_logic;                                            -- macro op success ('1') or error ('0') 
         m_op_cmd_code_o   : out std_logic_vector(BB_COMMAND_TYPE_WIDTH-1 downto 0);    -- command code vector - indicates if data or reply (and which command)
         m_op_param_id_o   : out std_logic_vector(FIBRE_PARAMETER_ID_WIDTH-1 downto 0);    -- m_op parameter id passed from reply_queue
         m_op_card_id_o    : out std_logic_vector(FIBRE_CARD_ADDRESS_WIDTH-1 downto 0);    -- m_op card id passed from reply_queue
         fibre_word_o      : out std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);    -- packet word read from reply queue
         num_fibre_words_o : out std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);    -- indicate number of packet words to be read from reply queue
         fibre_word_req_i  : in std_logic;                                            -- asserted to requeset next fibre word
         m_op_ack_i        : in std_logic;                                            -- asserted to indicate to reply queue the the packet has been processed      
         cmd_stop_o        : out std_logic;                                          -- indicates a STOP command was recieved
         last_frame_o      : out std_logic;                                          -- indicates the last frame of data for a ret_dat command
         frame_seq_num_o   : out std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
         
         -- Global signals
         clk_i             : in std_logic;
         rst_i             : in std_logic
      );
   end component;
   
   component reply_queue_retire
      port(
         -- cmd_queue interface
         uop_rdy_i         : in std_logic;                                           
         uop_ack_o         : out std_logic;                                          
         uop_i             : in std_logic_vector(QUEUE_WIDTH-1 downto 0);            
         
         -- reply_translator interface 
         m_op_done_o       : out std_logic;
         m_op_cmd_code_o   : out std_logic_vector(BB_COMMAND_TYPE_WIDTH-1 downto 0); 
         m_op_param_id_o   : out std_logic_vector(BB_PARAMETER_ID_WIDTH-1 downto 0); 
         m_op_card_id_o    : out std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0); 
         m_op_ack_i        : in std_logic;    
         cmd_stop_o        : out std_logic;                                          
         last_frame_o      : out std_logic;                                          
         frame_seq_num_o   : out std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);     
        
         -- Internal interface signals to the lvds_rx fifo's
         mop_num_o         : out std_logic_vector(BB_MACRO_OP_SEQ_WIDTH-1 downto 0);
         uop_num_o         : out std_logic_vector(BB_MICRO_OP_SEQ_WIDTH-1 downto 0);
   
         -- Global signals
         clk_i             : in std_logic;
         comm_clk_i        : in std_logic;
         rst_i             : in std_logic
      );
   end component;   
   
end reply_queue_pack;