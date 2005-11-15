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
-- $Id: reply_queue_pack.vhd,v 1.18 2005/03/23 19:25:54 bburger Exp $
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
-- Revision 1.18  2005/03/23 19:25:54  bburger
-- Bryce:  Added a debugging trigger
--
-- Revision 1.17  2005/03/12 02:19:01  bburger
-- bryce:  bug fixes
--
-- Revision 1.16  2005/02/20 02:00:29  bburger
-- Bryce:  integrated the reply_queue and cmd_queue with respect to the timeout signal.
--
-- Revision 1.15  2005/02/20 00:50:25  erniel
-- updated reply_queue declaration
--
-- Revision 1.14  2005/02/20 00:38:39  erniel
-- changed timeout limit to 500 us
--
-- Revision 1.13  2005/02/09 20:45:02  erniel
-- added condensed header format declarations
-- added misc. reply_queue constants
-- updated reply_queue_sequencer component
-- updated reply_queue_receive component
--
-- Revision 1.12  2005/01/11 22:48:00  erniel
-- removed mem_clk_i from reply_queue_receive
-- removed mem_clk_i from reply_queue top-level
--
-- Revision 1.11  2004/12/04 02:03:06  bburger
-- Bryce:  fixing some problems associated with integrating the reply_queue
--
-- Revision 1.10  2004/12/01 18:41:32  erniel
-- fixed error code width...again
-- updated reply_queue_sequencer component
--
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
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library sys_param;
use sys_param.command_pack.all;

library work;
use work.cmd_queue_ram40_pack.all;
use work.sync_gen_pack.all;

package reply_queue_pack is

-- reply_queue fifo depths:
constant PACKET_BUFFER_DEPTH  : integer := 9; 
constant PACKET_STORAGE_DEPTH : integer := 11;

-- reply_queue timeout limit (in microseconds):
constant CMD_TIMEOUT_LIMIT : integer := 100;
constant DATA_TIMEOUT_LIMIT : integer := 650;

-- condensed header field range declarations:
constant RQ_STATUS    : std_logic_vector(31 downto 26) := "000000";
constant RQ_DATA_SIZE : std_logic_vector(25 downto 16) := "0000000000";
constant RQ_SEQ_NUM   : std_logic_vector(15 downto 0)  := "0000000000000000";

-- condensed header field width declarations:      
constant RQ_DATA_SIZE_WIDTH : integer := RQ_DATA_SIZE'length;
constant RQ_SEQ_NUM_WIDTH   : integer := RQ_SEQ_NUM'length;
constant RQ_STATUS_WIDTH    : integer := RQ_STATUS'length;

-- status bit scheme:
--
-- bit 0 : dispatch CRC error
-- bit 1 : dispatch WB error
-- bit 2 : reply queue CRC error
-- bit 3 : reply queue data error
-- bit 4 : reply queue timeout error 
-- bit 5 : reply queue marker flag



component reply_queue
   port(
      -- cmd_queue interface
      cmd_to_retire_i   : in std_logic;                                           
      cmd_sent_o        : out std_logic;                                          
      cmd_i             : in std_logic_vector(QUEUE_WIDTH-1 downto 0);   
--      cmd_timeout_o     : out std_logic;         
      
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
--      internal_cmd_o    : out std_logic;

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
end component;
   
component reply_queue_retire
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
end component;   
   
component reply_queue_receive
   port(clk_i      : in std_logic;
        comm_clk_i : in std_logic;
        rst_i      : in std_logic;
     
        lvds_reply_i : in std_logic;
     
        data_o    : out std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);      
        rdy_o     : out std_logic;
        ack_i     : in std_logic;
        discard_i : in std_logic);
end component;

component reply_queue_accumulator
   port(data : in std_logic_vector(31 downto 0);
        clock : in std_logic;
        sload : in std_logic;
        clken : in std_logic;
        aclr : in std_logic;
        result : out std_logic_vector(31 downto 0));
end component;

component reply_queue_sequencer
   port(
        -- for debugging
        timer_trigger_o : out std_logic;

        clk_i : in std_logic;
        rst_i : in std_logic;
  
        -- receiver FIFO interfaces:
        ac_data_i     : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
        ac_rdy_i      : in std_logic;
        ac_ack_o      : out std_logic;
        ac_discard_o  : out std_logic;
          
        bc1_data_i    : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
        bc1_rdy_i     : in std_logic;
        bc1_ack_o     : out std_logic;
        bc1_discard_o : out std_logic;
          
        bc2_data_i    : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
        bc2_rdy_i     : in std_logic;
        bc2_ack_o     : out std_logic;
        bc2_discard_o : out std_logic;
       
        bc3_data_i    : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
        bc3_rdy_i     : in std_logic;
        bc3_ack_o     : out std_logic;
        bc3_discard_o : out std_logic;
       
        rc1_data_i    : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
        rc1_rdy_i     : in std_logic;
        rc1_ack_o     : out std_logic;
        rc1_discard_o : out std_logic;
       
        rc2_data_i    : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
        rc2_rdy_i     : in std_logic;
        rc2_ack_o     : out std_logic;
        rc2_discard_o : out std_logic;
       
        rc3_data_i    : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
        rc3_rdy_i     : in std_logic;
        rc3_ack_o     : out std_logic;
        rc3_discard_o : out std_logic;
        
        rc4_data_i    : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
        rc4_rdy_i     : in std_logic;
        rc4_ack_o     : out std_logic;
        rc4_discard_o : out std_logic;
       
        cc_data_i     : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
        cc_rdy_i      : in std_logic;
        cc_ack_o      : out std_logic;
        cc_discard_o  : out std_logic;
      
        card_data_size_i : in std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);
        cmd_code_i       : in std_logic_vector(BB_COMMAND_TYPE_WIDTH-1 downto 0);

        -- fibre interface:
        size_o  : out integer;
        error_o : out std_logic_vector(29 downto 0);
        data_o  : out std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
        rdy_o   : out std_logic;
        ack_i   : in std_logic;
      
        -- cmd_queue interface:
        macro_op_i  : in std_logic_vector(BB_MACRO_OP_SEQ_WIDTH-1 downto 0);
        micro_op_i  : in std_logic_vector(BB_MICRO_OP_SEQ_WIDTH-1 downto 0);
        card_addr_i : in std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0);
        cmd_valid_i : in std_logic;
        matched_o   : out std_logic--;
--        timeout_o   : out std_logic
        );
end component;   
   
end reply_queue_pack;