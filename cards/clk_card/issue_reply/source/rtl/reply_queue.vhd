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
-- $Id: reply_queue.vhd,v 1.7 2004/11/30 03:22:47 bburger Exp $
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
      cmd_retired_o     : out std_logic;                                          
      cmd_i             : in std_logic_vector(QUEUE_WIDTH-1 downto 0);            
      
      -- reply_translator interface (from reply_queue, i.e. these signals are de-multiplexed from retire and sequencer)
      size_o            : out integer;
      data_o            : out std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
      error_code_o      : out std_logic_vector(26 downto 0);
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
   signal cq_err             : std_logic_vector(26 downto 0);

   -- reply_queue signals for all other commands
   signal rq_size            : integer;
   signal rq_data            : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal rq_rdy             : std_logic; -- word is valid
   signal rq_ack             : std_logic;
   signal rq_start           : std_logic;
   signal rq_match           : std_logic;
   signal rq_err             : std_logic_vector(26 downto 0);
   
   -- reply queue receiver interfaces
   signal ac_data            : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal ac_header          : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal ac_rdy             : std_logic;
   signal ac_ack             : std_logic;
   signal ac_nack            : std_logic;
   signal ac_done            : std_logic;
   
   signal bc1_data           : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal bc1_header         : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal bc1_rdy            : std_logic;
   signal bc1_ack            : std_logic;
   signal bc1_nack           : std_logic;
   signal bc1_done           : std_logic;
   
   signal bc2_data           : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal bc2_header         : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal bc2_rdy            : std_logic;
   signal bc2_ack            : std_logic;
   signal bc2_nack           : std_logic;
   signal bc2_done           : std_logic;
   
   signal bc3_data           : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal bc3_header         : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal bc3_rdy            : std_logic;
   signal bc3_ack            : std_logic;
   signal bc3_nack           : std_logic;
   signal bc3_done           : std_logic;
   
   signal rc1_data           : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal rc1_header         : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal rc1_rdy            : std_logic;
   signal rc1_ack            : std_logic;
   signal rc1_nack           : std_logic;
   signal rc1_done           : std_logic;
   
   signal rc2_data           : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal rc2_header         : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal rc2_rdy            : std_logic;
   signal rc2_ack            : std_logic;
   signal rc2_nack           : std_logic;
   signal rc2_done           : std_logic;
   
   signal rc3_data           : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal rc3_header         : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal rc3_rdy            : std_logic;
   signal rc3_ack            : std_logic;
   signal rc3_nack           : std_logic;
   signal rc3_done           : std_logic;
   
   signal rc4_data           : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal rc4_header         : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal rc4_rdy            : std_logic;
   signal rc4_ack            : std_logic;
   signal rc4_nack           : std_logic;
   signal rc4_done           : std_logic;
   
   signal cc_data            : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal cc_header          : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal cc_rdy             : std_logic;
   signal cc_ack             : std_logic;
   signal cc_nack            : std_logic;
   signal cc_done            : std_logic;
   
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

   rq_seq : reply_queue_sequencer
      port map(
         clk_i        => clk_i,
         rst_i        => rst_i,
 
         ac_data_i    => ac_data,
         ac_header_i  => ac_header,
         ac_rdy_i     => ac_rdy,
         ac_ack_o     => ac_ack,
         ac_nack_o    => ac_nack,
         ac_done_i    => ac_done,
         
         bc1_data_i   => bc1_data,
         bc1_header_i => bc1_header,
         bc1_rdy_i    => bc1_rdy,
         bc1_ack_o    => bc1_ack,
         bc1_nack_o   => bc1_nack,
         bc1_done_i   => bc1_done,
         
         bc2_data_i   => bc2_data,
         bc2_header_i => bc2_header,
         bc2_rdy_i    => bc2_rdy,
         bc2_ack_o    => bc2_ack,
         bc2_nack_o   => bc2_nack,
         bc2_done_i   => bc2_done,
         
         bc3_data_i   => bc3_data,
         bc3_header_i => bc3_header,
         bc3_rdy_i    => bc3_rdy,
         bc3_ack_o    => bc3_ack,
         bc3_nack_o   => bc3_nack,
         bc3_done_i   => bc3_done,
         
         rc1_data_i   => rc1_data,
         rc1_header_i => rc1_header,
         rc1_rdy_i    => rc1_rdy,
         rc1_ack_o    => rc1_ack,
         rc1_nack_o   => rc1_nack,
         rc1_done_i   => rc1_done,
         
         rc2_data_i   => rc2_data,
         rc2_header_i => rc2_header,
         rc2_rdy_i    => rc2_rdy,
         rc2_ack_o    => rc2_ack,
         rc2_nack_o   => rc2_nack,
         rc2_done_i   => rc2_done,
         
         rc3_data_i   => rc3_data,
         rc3_header_i => rc3_header,
         rc3_rdy_i    => rc3_rdy,
         rc3_ack_o    => rc3_ack,
         rc3_nack_o   => rc3_nack,
         rc3_done_i   => rc3_done,
         
         rc4_data_i   => rc4_data,
         rc4_header_i => rc4_header,
         rc4_rdy_i    => rc4_rdy,
         rc4_ack_o    => rc4_ack,
         rc4_nack_o   => rc4_nack,
         rc4_done_i   => rc4_done,
         
         cc_data_i    => cc_data,
         cc_header_i  => cc_header,
         cc_rdy_i     => cc_rdy,
         cc_ack_o     => cc_ack,
         cc_nack_o    => cc_nack,
         cc_done_i    => cc_done,
         
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
         match_o      => rq_match,
         start_i      => rq_start
     );

   rx_ac : reply_queue_receive
      port map(
         clk_i        => clk_i,
         mem_clk_i    => mem_clk_i,
         comm_clk_i   => comm_clk_i,
         rst_i        => rst_i,
               
         lvds_reply_i => lvds_reply_ac_a,
             
         data_o       => ac_data,
         header_o     => ac_header,
               
         rdy_o        => ac_rdy,
         ack_i        => ac_ack,
         nack_i       => ac_nack,
         done_o       => ac_done
      );
   
   rx_bc1 : reply_queue_receive
      port map(
         clk_i        => clk_i,
         mem_clk_i    => mem_clk_i,
         comm_clk_i   => comm_clk_i,
         rst_i        => rst_i,
               
         lvds_reply_i => lvds_reply_bc1_a,
             
         data_o       => bc1_data,
         header_o     => bc1_header,
               
         rdy_o        => bc1_rdy,
         ack_i        => bc1_ack,
         nack_i       => bc1_nack,
         done_o       => bc1_done
      );
   
   rx_bc2 : reply_queue_receive
      port map(
         clk_i        => clk_i,
         mem_clk_i    => mem_clk_i,
         comm_clk_i   => comm_clk_i,
         rst_i        => rst_i,
               
         lvds_reply_i => lvds_reply_bc2_a,
             
         data_o       => bc2_data,
         header_o     => bc2_header,
               
         rdy_o        => bc2_rdy,
         ack_i        => bc2_ack,
         nack_i       => bc2_nack,
         done_o       => bc2_done
      );
   
   rx_bc3 : reply_queue_receive
      port map(
         clk_i        => clk_i,
         mem_clk_i    => mem_clk_i,
         comm_clk_i   => comm_clk_i,
         rst_i        => rst_i,
               
         lvds_reply_i => lvds_reply_bc3_a,
             
         data_o       => bc3_data,
         header_o     => bc3_header,
               
         rdy_o        => bc3_rdy,
         ack_i        => bc3_ack,
         nack_i       => bc3_nack,
         done_o       => bc3_done
      );
      
   rx_rc1 : reply_queue_receive
      port map(
         clk_i        => clk_i,
         mem_clk_i    => mem_clk_i,
         comm_clk_i   => comm_clk_i,
         rst_i        => rst_i,
               
         lvds_reply_i => lvds_reply_rc1_a,
             
         data_o       => rc1_data,
         header_o     => rc1_header,
               
         rdy_o        => rc1_rdy,
         ack_i        => rc1_ack,
         nack_i       => rc1_nack,
         done_o       => rc1_done
      );
      
   rx_rc2 : reply_queue_receive
      port map(
         clk_i        => clk_i,
         mem_clk_i    => mem_clk_i,
         comm_clk_i   => comm_clk_i,
         rst_i        => rst_i,
               
         lvds_reply_i => lvds_reply_rc2_a,
             
         data_o       => rc2_data,
         header_o     => rc2_header,
               
         rdy_o        => rc2_rdy,
         ack_i        => rc2_ack,
         nack_i       => rc2_nack,
         done_o       => rc2_done
      );
      
   rx_rc3 : reply_queue_receive
      port map(
         clk_i        => clk_i,
         mem_clk_i    => mem_clk_i,
         comm_clk_i   => comm_clk_i,
         rst_i        => rst_i,
               
         lvds_reply_i => lvds_reply_rc3_a,
             
         data_o       => rc3_data,
         header_o     => rc3_header,
               
         rdy_o        => rc3_rdy,
         ack_i        => rc3_ack,
         nack_i       => rc3_nack,
         done_o       => rc3_done
      );
      
   rx_rc4 : reply_queue_receive
      port map(
         clk_i        => clk_i,
         mem_clk_i    => mem_clk_i,
         comm_clk_i   => comm_clk_i,
         rst_i        => rst_i,
               
         lvds_reply_i => lvds_reply_rc4_a,
             
         data_o       => rc4_data,
         header_o     => rc4_header,
               
         rdy_o        => rc4_rdy,
         ack_i        => rc4_ack,
         nack_i       => rc4_nack,
         done_o       => rc4_done
      );
   
   rx_cc : reply_queue_receive
      port map(
         clk_i        => clk_i,
         mem_clk_i    => mem_clk_i,
         comm_clk_i   => comm_clk_i,
         rst_i        => rst_i,
               
         lvds_reply_i => lvds_reply_cc_a,
             
         data_o       => cc_data,
         header_o     => cc_header,
                        
         rdy_o        => cc_rdy,
         ack_i        => cc_ack,
         nack_i       => cc_nack,
         done_o       => cc_done
      );
   
end behav;