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
-- $Id: reply_queue_pack.vhd,v 1.9 2004/11/30 22:58:47 bburger Exp $
--
-- Project:    SCUBA2
-- Author:     Bryce Burger, Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- This is the reply_queue pack file.
--
-- Revision history:
-- $Log: reply_queue_pack.vhd,v $
-- Revision 1.9  2004/11/30 22:58:47  bburger
-- Bryce:  reply_queue integration
--
-- Revision 1.8  2004/11/30 04:57:48  erniel
-- fixed error code width
--
-- Revision 1.7  2004/11/30 04:43:32  erniel
-- added components:
--    reply_queue_receiver
--    reply_queue_sequencer
--
-- Revision 1.6  2004/11/30 03:22:47  bburger
-- Bryce:  building reply_queue top-level interface and functionality
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
use work.sync_gen_pack.all;

package reply_queue_pack is
   
component reply_queue
   port(
      -- cmd_queue interface
      cmd_to_retire_i   : in std_logic;                                           
      cmd_retired_o     : out std_logic;                                          
      cmd_i             : in std_logic_vector(QUEUE_WIDTH-1 downto 0);            
      
      -- reply_translator interface (from reply_queue, i.e. these signals are de-multiplexed from retire and sequencer)
      size_o            : out integer;
      data_o            : out std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
      error_code_o      : out std_logic_vector(29 downto 0);
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
      mem_clk_i         : in std_logic;
      comm_clk_i        : in std_logic;
      rst_i             : in std_logic
   );
end component;
   
component reply_queue_retire
   port(
      -- cmd_queue interface
      cmd_to_retire_i   : in std_logic;                                           
      cmd_sent_o     : out std_logic;                                          
      cmd_i             : in std_logic_vector(QUEUE_WIDTH-1 downto 0);            
      
      -- reply_translator interface
      cmd_sent_i        : in std_logic;
      cmd_code_o        : out std_logic_vector(BB_COMMAND_TYPE_WIDTH-1 downto 0); 
      param_id_o        : out std_logic_vector(BB_PARAMETER_ID_WIDTH-1 downto 0); 
      stop_bit_o        : out std_logic;                                          
      last_frame_bit_o  : out std_logic;                                          
      frame_seq_num_o   : out std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);     
      internal_cmd_o    : out std_logic;      
      
      -- reply_translator and reply_queue_sequencer interface
      card_addr_o       : out std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0); 

      -- to MUX in reply_queue (for handling STOP commands)
      size_o            : out integer;
      data_o            : out std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
      error_code_o      : out std_logic_vector(29 downto 0); 
      rdy_o             : out std_logic;
      ack_i             : in std_logic;      
     
      -- reply_queue_sequencer interface
      mop_num_o         : out std_logic_vector(BB_MACRO_OP_SEQ_WIDTH-1 downto 0);
      uop_num_o         : out std_logic_vector(BB_MICRO_OP_SEQ_WIDTH-1 downto 0);
      cmd_rdy_o         : out std_logic;

      -- Global signals
      clk_i             : in std_logic;
      comm_clk_i        : in std_logic;
      rst_i             : in std_logic
   );
end component;   
   
   component reply_queue_receive
      port(clk_i      : in std_logic;
           mem_clk_i  : in std_logic;
           comm_clk_i : in std_logic;
           rst_i      : in std_logic;
     
           lvds_reply_i : in std_logic;
     
           data_o   : out std_logic_vector(PACKET_WORD_WIDTH-1 downto 0); 
           header_o : out std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
     
           rdy_o  : out std_logic;
           ack_i  : in std_logic;
           nack_i : in std_logic;
           done_o : out std_logic);
   end component;

   component reply_queue_sequencer
      port(clk_i : in std_logic;
           rst_i : in std_logic;
     
           -- receiver FIFO interfaces:
           ac_data_i    : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
           ac_header_i  : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
           ac_rdy_i     : in std_logic;
           ac_ack_o     : out std_logic;
           ac_nack_o    : out std_logic;
           ac_done_i    : in std_logic;
          
           bc1_data_i   : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
           bc1_header_i : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
           bc1_rdy_i    : in std_logic;
           bc1_ack_o    : out std_logic;
           bc1_nack_o   : out std_logic;
           bc1_done_i   : in std_logic;
          
           bc2_data_i   : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
           bc2_header_i : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
           bc2_rdy_i    : in std_logic;
           bc2_ack_o    : out std_logic;
           bc2_nack_o   : out std_logic;
           bc2_done_i   : in std_logic;
          
           bc3_data_i   : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
           bc3_header_i : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
           bc3_rdy_i    : in std_logic;
           bc3_ack_o    : out std_logic;
           bc3_nack_o   : out std_logic;
           bc3_done_i   : in std_logic;
          
           rc1_data_i   : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
           rc1_header_i : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
           rc1_rdy_i    : in std_logic;
           rc1_ack_o    : out std_logic;
           rc1_nack_o   : out std_logic;
           rc1_done_i   : in std_logic;
          
           rc2_data_i   : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
           rc2_header_i : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
           rc2_rdy_i    : in std_logic;
           rc2_ack_o    : out std_logic;
           rc2_nack_o   : out std_logic;
           rc2_done_i   : in std_logic;
          
           rc3_data_i   : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
           rc3_header_i : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
           rc3_rdy_i    : in std_logic;
           rc3_ack_o    : out std_logic;
           rc3_nack_o   : out std_logic;
           rc3_done_i   : in std_logic;
           
           rc4_data_i   : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
           rc4_header_i : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
           rc4_rdy_i    : in std_logic;
           rc4_ack_o    : out std_logic;
           rc4_nack_o   : out std_logic;
           rc4_done_i   : in std_logic;
          
           cc_data_i    : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
           cc_header_i  : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
           cc_rdy_i     : in std_logic;
           cc_ack_o     : out std_logic;
           cc_nack_o    : out std_logic;
           cc_done_i    : in std_logic;
      
      -- fibre interface:
      size_o : out integer;
           error_o : out std_logic_vector(29 downto 0);
      data_o : out std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
      rdy_o  : out std_logic;
      ack_i  : in std_logic;
      
      -- cmd_queue interface:
      macro_op_i  : in std_logic_vector(BB_MACRO_OP_SEQ_WIDTH-1 downto 0);
      micro_op_i  : in std_logic_vector(BB_MICRO_OP_SEQ_WIDTH-1 downto 0);
      card_addr_i : in std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0);
      cmd_valid_i : in std_logic;
      match_o     : out std_logic);
   end component;   
   
end reply_queue_pack;