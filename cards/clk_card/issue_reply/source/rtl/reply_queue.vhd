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
-- $Id: reply_queue.vhd,v 1.13 2005/02/09 20:41:10 erniel Exp $
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
-- Revision 1.13  2005/02/09 20:41:10  erniel
-- updated reply_queue_sequencer component
-- updated reply_queue_receive component
--
-- Revision 1.12  2005/01/11 22:50:29  erniel
-- removed mem_clk_i from ports
--
-- Revision 1.11  2004/12/06 07:23:04  bburger
-- Bryce:  Modified cmd_queue and reply_queue stop them from allowing start commands over the backplane
--
-- Revision 1.10  2004/12/04 02:03:06  bburger
-- Bryce:  fixing some problems associated with integrating the reply_queue
--
-- Revision 1.9  2004/11/30 22:58:47  bburger
-- Bryce:  reply_queue integration
--
-- Revision 1.8  2004/11/30 05:12:30  erniel
-- fixed error code width in reply_queue_retire
-- added reply_queue_sequencer subblock
-- added reply_queue_receiver subblocks
--
-- Revision 1.7  2004/11/30 03:22:47  bburger
-- Bryce:  building reply_queue top-level interface and functionality
--
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

   -- Internal interface signals to/from reply_queue_retire and reply_queue_sequencer
   signal mop_num            : std_logic_vector(BB_MACRO_OP_SEQ_WIDTH-1 downto 0);
   signal uop_num            : std_logic_vector(BB_MICRO_OP_SEQ_WIDTH-1 downto 0);
   signal card_addr          : std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0); 
   signal cmd_code           : std_logic_vector(BB_COMMAND_TYPE_WIDTH-1 downto 0);
   
   -- cmd_queue signals for stop commands
   signal cq_size            : integer;
   signal cq_data            : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal cq_rdy             : std_logic; -- word is valid
   signal cq_ack             : std_logic;
   signal cq_err             : std_logic_vector(29 downto 0);

   -- reply_queue signals for all other commands
   signal rq_size            : integer;
   signal rq_data            : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal rq_rdy             : std_logic; -- word is valid
   signal rq_ack             : std_logic;
   signal rq_err             : std_logic_vector(29 downto 0);
   signal rq_match           : std_logic;
   signal rq_start           : std_logic;
   
   -- reply queue receiver interfaces
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
   
begin   
   
   cmd_code_o    <= cmd_code;
   card_addr_o   <= card_addr;
   size_o        <= cq_size when (cmd_code =  STOP or  cmd_code =  START) else rq_size;
   data_o        <= cq_data when (cmd_code =  STOP or  cmd_code =  START) else rq_data;
   rdy_o         <= cq_rdy  when (cmd_code =  STOP or  cmd_code =  START) else rq_rdy;   
   error_code_o  <= cq_err  when (cmd_code =  STOP or  cmd_code =  START) else rq_err;
   
   cq_ack        <= ack_i   when (cmd_code =  STOP or  cmd_code =  START) else '0';
   rq_ack        <= ack_i   when (cmd_code /= STOP and cmd_code /= START) else '0';   
   
   rqr : reply_queue_retire
      port map(
         -- cmd_queue interface control
         cmd_to_retire_i   => cmd_to_retire_i,
         cmd_sent_o        => cmd_sent_o,
         
         cmd_i             => cmd_i,
         
         -- reply_translator interface control
         cmd_sent_i        => cmd_sent_i,
         cmd_valid_o       => cmd_valid_o,         
         rdy_o             => cq_rdy,
         ack_i             => cq_ack,      

         cmd_code_o        => cmd_code,   
         param_id_o        => param_id_o,   
         stop_bit_o        => stop_bit_o,       
         last_frame_bit_o  => last_frame_bit_o,     
         frame_seq_num_o   => frame_seq_num_o,
         internal_cmd_o    => internal_cmd_o,

         size_o            => cq_size,
         data_o            => cq_data,
         error_code_o      => cq_err,
         
         card_addr_o       => card_addr,
         
         -- reply_queue_sequencer interface control
         matched_i         => rq_match,
         cmd_rdy_o         => rq_start,

         mop_num_o         => mop_num,
         uop_num_o         => uop_num,

         clk_i             => clk_i,     
         comm_clk_i        => comm_clk_i,
         rst_i             => rst_i   
      );               

   rq_seq : reply_queue_sequencer
      port map(
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
         size_o       => rq_size,
         error_o      => rq_err,
         data_o       => rq_data,
         rdy_o        => rq_rdy,
         ack_i        => rq_ack,
        
         -- cmd_queue interface:
         macro_op_i   => mop_num,
         micro_op_i   => uop_num,
         card_addr_i  => card_addr,
         cmd_valid_i  => rq_start,
         matched_o    => rq_match,
         timeout_o    => cmd_timeout_o
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