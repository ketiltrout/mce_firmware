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
-- $Id: issue_reply_pack.vhd,v 1.33 2004/11/19 16:21:02 dca Exp $
--
-- Project:    SCUBA2
-- Author:     Bryce Burger
-- Organisation:  UBC
--
-- Description:
-- Declares a few constants used as parameters in the issue_reply block
--
-- Revision history:
-- $Log: issue_reply_pack.vhd,v $
-- Revision 1.33  2004/11/19 16:21:02  dca
-- reply_translator: fibre_word_req_o changed to fibre_word_ack_o
--
-- Revision 1.32  2004/11/16 09:55:41  dca
-- reply_translator: 'num_fibre_words_i' changed to integer
--
-- Revision 1.31  2004/11/11 17:04:18  dca
-- change to reply_translator component declaration
--
-- Revision 1.30  2004/11/09 14:42:34  dca
-- reply_translator component declaration modified
--
-- Revision 1.29  2004/10/12 14:22:31  dca
-- Various component declations for fibre_tx changed (i.e. nTrp removed)
-- due to fibre_tx_fifo becoming synchronous megafunction.
--
-- Revision 1.28  2004/10/11 13:32:07  dca
-- Changes due to fibre_rx_fifo becoming a synchronous FIFO megafunction.
--
-- Revision 1.27  2004/10/08 19:45:26  bburger
-- Bryce:  Changed SYNC_NUM_WIDTH to 16, removed TIMEOUT_SYNC_WIDTH, added a command-code to cmd_queue, added two words of book-keeping information to the cmd_queue
--
-- Revision 1.26  2004/10/06 19:58:02  erniel
-- using new command_pack constants
--
-- Revision 1.25  2004/09/29 14:54:05  dca
-- components declarations for all components of fibre_rx and fibre_tx added.
--
-- Revision 1.24  2004/09/29 14:25:14  dca
-- component 'fibre_tx' port map corrected
--
-- Revision 1.23  2004/09/29 13:14:14  dca
-- Component declarations added for fibre_tx and reply_translator.
--
-- Revision 1.22  2004/09/09 18:28:49  jjacob
-- added 3 outputs to cmd_translator:
-- >       cmd_type_o        :  out std_logic_vector (BB_COMMAND_TYPE_WIDTH-1 downto 0);       -- this is a re-mapping of the cmd_code into a 3-bit number
-- >       cmd_stop_o        :  out std_logic;                                          -- indicates a STOP command was recieved
-- >       last_frame_o      :  out std_logic;                                          -- indicates the last frame of data for a ret_dat command
--
-- Revision 1.21  2004/08/11 00:09:00  jjacob
-- added the following signals to cmd_translator for the reply_translator interface:
--       reply_cmd_rcvd_er_o         : out std_logic;
--       reply_cmd_rcvd_ok_o         : out std_logic;
--       reply_cmd_code_o            : out std_logic_vector (15 downto 0);
--       reply_param_id_o            : out std_logic_vector (FIBRE_PARAMETER_ID_WIDTH-1 downto 0);       -- the parameter ID
--       reply_card_id_o             : out std_logic_vector (FIBRE_CARD_ADDRESS_WIDTH-1 downto 0)
--
-- and also added an input for the checksum error to route to the reply_cmd_rcvd_er_
--
-- Revision 1.20  2004/08/05 20:52:13  jjacob
-- added sync_number input to arbiter
--
-- Revision 1.19  2004/08/05 18:16:30  jjacob
-- changed frame_sync_num_o to use the parameter
-- SYNC_NUM_WIDTH
--
-- Revision 1.18  2004/07/22 23:09:02  bench2
-- Bryce: moved system-level constants to command_pack
--
-- Revision 1.17  2004/07/22 01:17:00  bench2
-- Bryce:  in progress
--
-- Revision 1.16  2004/07/20 00:33:53  bench2
-- Bryce:  in progress
--
-- Revision 1.15  2004/07/16 18:23:31  erniel
-- in progress
--
-- Revision 1.14  2004/07/09 10:19:15  dca
-- Ports "retiring_busy_o", and "clk_i" added to
-- cmd_translator_m_op_table entity.
--
-- Revision 1.13  2004/07/07 10:52:03  dca
-- FIBRE_CMD_CODE_WIDTH parameter added
--
-- Revision 1.12  2004/07/06 11:09:47  dca
-- "cmd_translator_m_op_table" component declaration included.
--
-- Revision 1.11  2004/07/06 00:29:15  bburger
-- in progress
--
-- Revision 1.10  2004/07/05 23:51:08  jjacob
-- added ack_o output to cmd_translator_ret_dat_fsm
--
-- Revision 1.9  2004/06/30 23:14:40  bburger
-- bug fix: FIBRE_DATA_SIZE_WIDTH is =32, was =8
--
-- Revision 1.8  2004/06/29 22:42:31  jjacob
-- updating testbench, not even the first version yet.  This is a safety
-- check-in
--
-- Revision 1.7  2004/06/22 17:28:12  jjacob
-- modified bus widths
--
-- Revision 1.6  2004/05/25 21:25:32  bburger
-- added constant sync_num_bus_width
--
-- Revision 1.5  2004/05/20 18:00:51  jjacob
-- changed data width from 16 to 32 bits
--
-- Revision 1.4  2004/05/17 22:54:13  jjacob
-- modified FIBRE_DATA_SIZE_WIDTH = 8 from 16
--
-- Revision 1.3  2004/05/11 17:35:14  jjacob
-- increased parameter ID to 24 bits, even though we only use bottom 8 bits.
--
-- Revision 1.2  2004/05/10 19:24:41  bburger
-- added BB_STATUS_WIDTH
--
-- Revision 1.1  2004/05/10 19:01:45  bburger
-- new
--
--
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library sys_param;
use sys_param.command_pack.all;

library work;
use work.sync_gen_pack.all;

package issue_reply_pack is

------------------------------------------------------------------------
--
-- component declarations for the command translator
--
------------------------------------------------------------------------

component cmd_translator

port(

     -- global inputs

      rst_i             : in     std_logic;
      clk_i             : in     std_logic;

      -- inputs from fibre_rx

      card_id_i         : in    std_logic_vector (FIBRE_CARD_ADDRESS_WIDTH-1 downto 0);    -- specifies which card the command is targetting
      cmd_code_i        : in    std_logic_vector (15 downto 0);   -- the least significant 16-bits from the fibre packet
      cmd_data_i        : in    std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);   -- the data
      cksum_err_i       : in    std_logic;
      cmd_rdy_i         : in    std_logic;                        -- indicates the fibre_rx outputs are valid
      data_clk_i        : in    std_logic;                        -- used to clock the data out
      num_data_i        : in    std_logic_vector (FIBRE_DATA_SIZE_WIDTH-1 downto 0);    -- number of 16-bit data words to be clocked out, possibly number of bytes
      --reg_addr_i        : in    std_logic_vector (23 downto 0);   -- the parameter ID
      param_id_i        : in    std_logic_vector (FIBRE_PARAMETER_ID_WIDTH-1 downto 0);   -- the parameter ID

      -- output to fibre_rx
      ack_o             : out std_logic;

      -- other inputs
      sync_pulse_i      : in    std_logic;
      sync_number_i     : in    std_logic_vector (SYNC_NUM_WIDTH-1 downto 0);

      -- signals from the arbiter to cmd_queue (micro-op sequence generator)
      --ack_o             :  out std_logic;     -- DEAD unused signal --RENAME to cmd_rdy_o        -- ready signal
      card_addr_o       :  out std_logic_vector (FIBRE_CARD_ADDRESS_WIDTH-1 downto 0);  -- specifies which card the command is targetting
      parameter_id_o    :  out std_logic_vector (FIBRE_PARAMETER_ID_WIDTH-1 downto 0);     -- comes from param_id_i, indicates which device(s) the command is targetting
      data_size_o       :  out std_logic_vector (FIBRE_DATA_SIZE_WIDTH-1 downto 0);  -- num_data_i, indicates number of 16-bit words of data
      data_o            :  out std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);        -- data will be passed straight thru
      data_clk_o        :  out std_logic;
      macro_instr_rdy_o :  out std_logic;
      cmd_type_o        :  out std_logic_vector (BB_COMMAND_TYPE_WIDTH-1 downto 0);       -- this is a re-mapping of the cmd_code into a 3-bit number
      cmd_stop_o        :  out std_logic;                                          -- indicates a STOP command was recieved
      last_frame_o      :  out std_logic;  
       
      -- input from the micro-op sequence generator
      ack_i                 : in std_logic;                    -- acknowledge signal from the micro-instruction sequence generator


      -- outputs to the cmd_queue (micro instruction sequence generator)
      m_op_seq_num_o        : out std_logic_vector (BB_MACRO_OP_SEQ_WIDTH-1 downto 0);
      frame_seq_num_o       : out std_logic_vector (31 downto 0);
      frame_sync_num_o      : out std_logic_vector (SYNC_NUM_WIDTH-1 downto 0);--(7 downto 0);


      -- outputs to reply_translator for commands that require quick acknowldgements  
      reply_cmd_rcvd_er_o         : out std_logic;
      reply_cmd_rcvd_ok_o         : out std_logic;
      reply_cmd_code_o            : out std_logic_vector (15 downto 0);
      reply_param_id_o            : out std_logic_vector (FIBRE_PARAMETER_ID_WIDTH-1 downto 0);       -- the parameter ID
      reply_card_id_o             : out std_logic_vector (FIBRE_CARD_ADDRESS_WIDTH-1 downto 0)    -- specifies which card the command is targetting



   );

end component;


component cmd_translator_simple_cmd_fsm

port(

     -- global inputs

      rst_i             : in     std_logic;
      clk_i             : in     std_logic;

      -- inputs from cmd_translator top level
      card_addr_i       : in std_logic_vector (FIBRE_CARD_ADDRESS_WIDTH-1 downto 0);  -- specifies which card the command is targetting
      parameter_id_i    : in std_logic_vector (FIBRE_PARAMETER_ID_WIDTH-1 downto 0);     -- comes from param_id_i, indicates which device(s) the command is targetting
      data_size_i       : in std_logic_vector (FIBRE_DATA_SIZE_WIDTH-1 downto 0);  -- data_size_i, indicates number of 16-bit words of data
      data_i            : in std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);       -- data will be passed straight thru in 16-bit words
      data_clk_i        : in std_logic;                                              -- for clocking out the data
      cmd_code_i        : in std_logic_vector (15 downto 0);

      -- other inputs
      sync_pulse_i      : in std_logic;
      cmd_start_i       : in std_logic;
      cmd_stop_i        : in std_logic;

      -- outputs to the macro-instruction arbiter
      card_addr_o       : out std_logic_vector (FIBRE_CARD_ADDRESS_WIDTH-1 downto 0);  -- specifies which card the command is targetting
      parameter_id_o    : out std_logic_vector (FIBRE_PARAMETER_ID_WIDTH-1 downto 0);     -- comes from param_id_i, indicates which device(s) the command is targetting
      data_size_o       : out std_logic_vector (FIBRE_DATA_SIZE_WIDTH-1 downto 0);  -- data_size_i, indicates number of 16-bit words of data
      data_o            : out std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);       -- data will be passed straight thru in 16-bit words
      data_clk_o        : out std_logic;                                          -- for clocking out the data
      macro_instr_rdy_o : out std_logic;                                          -- ='1' when the data is valid, else it's '0'
      cmd_type_o        : out std_logic_vector (BB_COMMAND_TYPE_WIDTH-1 downto 0);       -- this is a re-mapping of the cmd_code into a 3-bit number

      -- input from the macro-instruction arbiter
      ack_i             : in std_logic                   -- acknowledgment from the micro-instr arbiter that it is ready and has grabbed the data

   );

end component;



component cmd_translator_ret_dat_fsm

port(

     -- global inputs

      rst_i                   : in     std_logic;
      clk_i                   : in     std_logic;

      -- inputs from fibre_rx

      card_addr_i             : in std_logic_vector (FIBRE_CARD_ADDRESS_WIDTH-1 downto 0);  -- specifies which card the command is targetting
      parameter_id_i          : in std_logic_vector (FIBRE_PARAMETER_ID_WIDTH-1 downto 0);     -- comes from param_id_i, indicates which device(s) the command is targetting
      data_size_i             : in std_logic_vector (FIBRE_DATA_SIZE_WIDTH-1 downto 0);  -- data_size_i, indicates number of 16-bit words of data
      data_i                  : in std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);       -- data will be passed straight thru in 16-bit words
      data_clk_i              : in std_logic;                                          -- for clocking out the data
      cmd_code_i              : in std_logic_vector (15 downto 0);
  
      -- other inputs
      sync_pulse_i            : in std_logic;
      sync_number_i           : in std_logic_vector (SYNC_NUM_WIDTH-1 downto 0);    -- a counter of synch pulses
      ret_dat_start_i         : in std_logic;
      ret_dat_stop_i          : in std_logic;

      ret_dat_cmd_valid_o     : out std_logic;

      ret_dat_s_start_i       : in std_logic;
      ret_dat_s_done_o        : out std_logic;

      -- outputs to the macro-instruction arbiter
      card_addr_o             : out std_logic_vector (FIBRE_CARD_ADDRESS_WIDTH-1 downto 0);  -- specifies which card the command is targetting
      parameter_id_o          : out std_logic_vector (FIBRE_PARAMETER_ID_WIDTH-1 downto 0);     -- comes from param_id_i, indicates which device(s) the command is targetting
      data_size_o             : out std_logic_vector (FIBRE_DATA_SIZE_WIDTH-1 downto 0);  -- num_data_i, indicates number of 16-bit words of data
      data_o                  : out std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);       -- data will be passed straight thru in 16-bit words
      data_clk_o              : out std_logic;                                          -- for clocking out the data
      macro_instr_rdy_o       : out std_logic;                                          -- ='1' when the data is valid, else it's '0'
      cmd_type_o              : out std_logic_vector (BB_COMMAND_TYPE_WIDTH-1 downto 0);       -- this is a re-mapping of the cmd_code into a 3-bit number
      cmd_stop_o              : out std_logic;                                          -- indicates a STOP command was recieved
      last_frame_o            : out std_logic;
      
      ret_dat_fsm_working_o   : out std_logic;

      frame_seq_num_o         : out std_logic_vector (31 downto 0);
      frame_sync_num_o        : out std_logic_vector (SYNC_NUM_WIDTH-1 downto 0);--(7 downto 0);

      -- input from the macro-instruction arbiter
      ack_i                   : in std_logic;                   -- acknowledgment from the micro-instr arbiter that it is ready and has grabbed the data
      ack_o                   : out std_logic

   );

end component;



component cmd_translator_arbiter

port(

     -- global inputs

      rst_i                        : in std_logic;
      clk_i                        : in std_logic;

      -- inputs from the 'return data' state machine
      ret_dat_frame_seq_num_i      : in std_logic_vector (31 downto 0);
      ret_dat_frame_sync_num_i     : in std_logic_vector (SYNC_NUM_WIDTH-1 downto 0);

      ret_dat_card_addr_i          : in std_logic_vector (FIBRE_CARD_ADDRESS_WIDTH-1 downto 0);  -- specifies which card the command is targetting
      ret_dat_parameter_id_i       : in std_logic_vector (FIBRE_PARAMETER_ID_WIDTH-1 downto 0);     -- comes from param_id_i, indicates which device(s) the command is targett_ig
      ret_dat_data_size_i          : in std_logic_vector (FIBRE_DATA_SIZE_WIDTH-1 downto 0);  -- num_data_i, indicates number of 16-bit words of data
      ret_dat_data_i               : in std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);       -- data will be passed straight thru in 16-bit words
      ret_dat_data_clk_i           : in std_logic;                                                      -- for clocking out the data
      ret_dat_macro_instr_rdy_i    : in std_logic;                                          -- ='1' when the data is valid, else it's '0'
      ret_dat_fsm_working_i        : in std_logic;
      ret_dat_cmd_type_i           : in std_logic_vector (BB_COMMAND_TYPE_WIDTH-1 downto 0);       -- this is a re-mapping of the cmd_code into a 3-bit number
      ret_dat_cmd_stop_i           : in std_logic;                                          -- indicates a STOP command was recieved
      ret_dat_last_frame_i         : in std_logic;   
 
      -- output to the 'return data' state machine
      ret_dat_ack_o                : out std_logic;                   -- acknowledgment from the macro-instr arbiter that it is ready and has grabbed the data

      -- inputs from the 'simple commands' state machine
      simple_cmd_card_addr_i       : in std_logic_vector (FIBRE_CARD_ADDRESS_WIDTH-1 downto 0);  -- specifies which card the command is targetting
      simple_cmd_parameter_id_i    : in std_logic_vector (FIBRE_PARAMETER_ID_WIDTH-1 downto 0);     -- comes from param_id_i, indicates which device(s) the command is targetting
      simple_cmd_data_size_i       : in std_logic_vector (FIBRE_DATA_SIZE_WIDTH-1 downto 0);  -- data_size_i, indicates number of 16-bit words of data
      simple_cmd_data_i            : in std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);       -- data will be passed straight thru in 16-bit words
      simple_cmd_data_clk_i        : in std_logic;                                          -- for clocking out the data
      simple_cmd_macro_instr_rdy_i : in std_logic;                                          -- ='1' when the data is valid, else it's '0'
      simple_cmd_type_i            : in std_logic_vector (BB_COMMAND_TYPE_WIDTH-1 downto 0);       -- this is a re-mapping of the cmd_code into a 3-bit number
      -- input from the macro-instruction arbiter
      simple_cmd_ack_o             : out std_logic ;
      
      -- input for sync_number for simple commands
      sync_number_i                : in  std_logic_vector (SYNC_NUM_WIDTH-1 downto 0);

      -- outputs to the cmd_queue (micro instruction sequence generator)
      m_op_seq_num_o               : out std_logic_vector (BB_MACRO_OP_SEQ_WIDTH-1 downto 0);
      frame_seq_num_o              : out std_logic_vector (31 downto 0);
      frame_sync_num_o             : out std_logic_vector (SYNC_NUM_WIDTH-1 downto 0);
      
      -- outputs to the micro-instruction generator
      card_addr_o                  : out std_logic_vector (FIBRE_CARD_ADDRESS_WIDTH-1 downto 0);  -- specifies which card the command is targetting
      parameter_id_o               : out std_logic_vector (FIBRE_PARAMETER_ID_WIDTH-1 downto 0);     -- comes from param_id_i, indicates which device(s) the command is targetting
      data_size_o                  : out std_logic_vector (FIBRE_DATA_SIZE_WIDTH-1 downto 0);  -- num_data_i, indicates number of 16-bit words of data
      data_o                       : out std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);       -- data will be passed straight thru in 16-bit words
      data_clk_o                   : out std_logic;                                               -- for clocking out the data
      macro_instr_rdy_o            : out std_logic;                                          -- ='1' when the data is valid, else it's '0'
      cmd_type_o                   : out std_logic_vector (BB_COMMAND_TYPE_WIDTH-1 downto 0);       -- this is a re-mapping of the cmd_code into a 3-bit number
      cmd_stop_o                   : out std_logic;                                          -- indicates a STOP command was recieved
      last_frame_o                 : out std_logic;
      
      -- input from the micro-instruction arbiter
      ack_i             : in std_logic                   -- acknowledgment from the micro-instr arbiter that it is ready and has grabbed the data

   );

end component;

component cmd_translator_m_op_table 

port(
     -- global inputs
     rst_i                   : in     std_logic;
     clk_i                   : in     std_logic;

     -- inputs from cmd_translator (top level)     
     card_addr_store_i       : in std_logic_vector (FIBRE_CARD_ADDRESS_WIDTH-1 downto 0);  -- specifies which card the command is targetting
     parameter_id_store_i    : in std_logic_vector (FIBRE_PARAMETER_ID_WIDTH-1    downto 0);  -- comes from reg_addr_i, indicates which device(s) the command is targetting
     m_op_seq_num_store_i    : in std_logic_vector (BB_MACRO_OP_SEQ_WIDTH-1       downto 0);
     frame_seq_num_store_i   : in std_logic_vector (31                    downto 0);
     macro_instr_rdy_i       : in std_logic;                                           -- '1' when data is valid and ready to be stored in table 
 
     -- inputs from reply translator
     m_op_seq_num_retire_i    : in std_logic_vector (BB_MACRO_OP_SEQ_WIDTH-1       downto 0);
     macro_instr_done_i       : in std_logic;                                          --'1' when issued command ready to be retired from table  
      
     retiring_busy_o          : out std_logic;                                         -- asserted high if retiring a command, during which no command should be issued.
     table_empty_o            : out std_logic;                                         -- asserted high if table full.  no more macro instructions should be retired.
     table_full_o             : out std_logic                                          -- asserted high  if table full.  No more macro instructions should be issued.
   ); 
     
end component;


---------------------------
component fibre_tx 
----------------------------
      port(       
      -- global inputs
         clk_i        : in     std_logic;
         rst_i        : in     std_logic;                         -- global reset
         
      -- interface to reply_translator
      
         txd_i        : in     std_logic_vector (7 downto 0);     -- FIFO input byte
         tx_fw_i      : in     std_logic;                         -- FIFO write request
         tx_ff_o      : out    std_logic;                         -- FIFO full flag
      
      -- interface to HOTLINK transmitter
         fibre_clkw_i : in     std_logic;                          -- 25MHz hotlink clock
         tx_data_o    : out    std_logic_vector (7 downto 0);      -- byte of data to be transmitted
         tsc_nTd_o    : out    std_logic;                          -- hotlink tx special char/ data sel
         nFena_o      : out    std_logic                           -- hotlink tx enable
      );

end component;

 
-------------------------------
component reply_translator
-------------------------------
port(
    -- global inputs 
     rst_i                   : in  std_logic;                                               -- global reset
     clk_i                   : in  std_logic;                                               -- global clock

     -- signals to/from cmd_translator    
     cmd_rcvd_er_i           : in  std_logic;                                               -- command received on fibre with checksum error
     cmd_rcvd_ok_i           : in  std_logic;                                               -- command received on fibre - no checksum error
     cmd_code_i              : in  std_logic_vector (FIBRE_CMD_CODE_WIDTH-1     downto 0);  -- fibre command code
     card_id_i               : in  std_logic_vector (FIBRE_CARD_ADDRESS_WIDTH-1 downto 0);  -- fibre command card id
     param_id_i              : in  std_logic_vector (FIBRE_PARAMETER_ID_WIDTH-1 downto 0);  -- fibre command parameter id
         
     -- signals to/from reply queue 
     m_op_rdy_i              : in  std_logic;                                                 -- macro op done
     m_op_error_code_i       : in  std_logic_vector(BB_STATUS_WIDTH-1           downto 0);    -- macro op success (others => '0') else error code
     m_op_cmd_code_i         : in  std_logic_vector (BB_COMMAND_TYPE_WIDTH-1    downto 0);    -- command code vector - indicates if data or reply (and which command)
     m_op_param_id_i         : in  std_logic_vector (BB_PARAMETER_ID_WIDTH-1  downto 0);      -- m_op parameter id passed from reply_queue
     m_op_card_id_i          : in  std_logic_vector (BB_CARD_ADDRESS_WIDTH-1  downto 0);      -- m_op card id passed from reply_queue
     fibre_word_i            : in  std_logic_vector (PACKET_WORD_WIDTH-1        downto 0);    -- packet word read from reply queue
     num_fibre_words_i       : in  integer ;                                                  -- indicate number of packet words to be read from reply queue
     fibre_word_ack_o        : out std_logic;                                                 -- asserted to requeset next fibre word
     fibre_word_rdy_i        : in std_logic;
     m_op_ack_o              : out std_logic;                                                 -- asserted to indicate to reply queue the the packet has been processed

     cmd_stop_i              : in std_logic;
     last_frame_i            : in std_logic;
     frame_seq_num_i         : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);

     -- signals to / from fibre_tx
     tx_ff_i                 : in std_logic;                                             -- transmit fifo full
     tx_fw_o                 : out std_logic;                                            -- transmit fifo write request
     txd_o                   : out std_logic_vector (7 downto 0)                         -- transmit fifo data input
     );      
end component;


constant TX_FIFO_DATA_WIDTH   : integer := 8;                              -- size of data words in fibre transmit FIFO
------------------------------
component fibre_tx_fifo 
------------------------------   

port( 
   clk_i        : in     std_logic;
   rst_i        : in     std_logic;
   fibre_clkw_i : in     std_logic;
   tx_fr_i      : in     std_logic;
   tx_fw_i      : in     std_logic;
   txd_i        : in     std_logic_vector (7 downto 0);
   tx_fe_o      : out    std_logic;
   tx_ff_o      : out    std_logic;
   tx_data_o    : out    std_logic_vector (7 downto 0)
   );
end component;


-----------------------------  
component fibre_tx_control
----------------------------- 
port( 
   fibre_clkw_i : in     std_logic;
   tx_fe_i      : in     std_logic;
   tsc_nTd_o    : out    std_logic;
   nFena_o      : out    std_logic;
   tx_fr_o      : out    std_logic
   );

end component;

constant RX_FIFO_DATA_WIDTH   : integer := 8;                               -- size of data words in fibre receive FIFO
---------------------------
component fibre_rx_fifo 
---------------------------
port(
   clk_i        : in     std_logic;                                          -- global clock
   rst_i        : in     std_logic;                                          -- global reset
           
   fibre_clkr_i : in     std_logic;                                          -- CKR from hotlink receiver 
   rx_fr_i      : in     std_logic;                                          -- fifo read request
   rx_fw_i      : in     std_logic;                                          -- fifo write request
   rx_data_i    : in     std_logic_vector (RX_FIFO_DATA_WIDTH-1 downto 0);   -- fifo data input
   rx_fe_o      : out    std_logic;                                          -- fifo empty flag
   rx_ff_o      : out    std_logic;                                          -- fifo full flagg
   rxd_o        : out    std_logic_vector (RX_FIFO_DATA_WIDTH-1 downto 0)    -- fifo data output
);
    
end component;

---------------------------
component fibre_rx_protocol
--------------------------- 
port( 
   rst_i       : in     std_logic;                                             -- reset
   clk_i       : in     std_logic;                                             -- clock 
   rx_fe_i     : in     std_logic;                                             -- receive fifo empty flag
   rxd_i       : in     std_logic_vector (RX_FIFO_DATA_WIDTH-1 downto 0);      -- receive data byte 
   cmd_ack_i   : in     std_logic;                                             -- command acknowledge

   cmd_code_o  : out    std_logic_vector (FIBRE_CMD_CODE_WIDTH-1 downto 0);      -- command code  
   card_id_o   : out    std_logic_vector (FIBRE_CARD_ADDRESS_WIDTH-1 downto 0);     -- card id
   param_id_o  : out    std_logic_vector (FIBRE_PARAMETER_ID_WIDTH-1 downto 0);        -- parameter id
   num_data_o  : out    std_logic_vector (FIBRE_DATA_SIZE_WIDTH-1 downto 0);     -- number of valid 32 bit data words
   cmd_data_o  : out    std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);          -- 32bit valid data word
   cksum_err_o : out    std_logic;                                             -- checksum error flag
   cmd_rdy_o   : out    std_logic;                                             -- command ready flag (checksum passed)
   data_clk_o  : out    std_logic;                                             -- data clock
   rx_fr_o     : out    std_logic                                              -- receive fifo read request
);
end component;

---------------------------
component fibre_rx_control
---------------------------
port( 
   nRx_rdy_i : in     std_logic;
   rsc_nRd_i : in     std_logic;
   rso_i     : in     std_logic;
   rvs_i     : in     std_logic;
   rx_ff_i   : in     std_logic;
   rx_fw_o   : out    std_logic
   );
end component;


---------------------------
component fibre_rx 
---------------------------
port( 
   rst_i        : in     std_logic;
   clk_i        : in     std_logic;
   
   fibre_clkr_i : in     std_logic;                                          -- CKR from hotlink receiver   
   nRx_rdy_i    : in     std_logic;
   rvs_i        : in     std_logic;
   rso_i        : in     std_logic;
   rsc_nrd_i    : in     std_logic;  
   rx_data_i    : in     std_logic_vector (RX_FIFO_DATA_WIDTH-1 downto 0);
   cmd_ack_i    : in     std_logic;                                           -- command acknowledge
   
   cmd_code_o   : out    std_logic_vector (FIBRE_CMD_CODE_WIDTH-1 downto 0);    -- command code  
   card_id_o    : out    std_logic_vector (FIBRE_CARD_ADDRESS_WIDTH-1 downto 0);   -- card id
   param_id_o   : out    std_logic_vector (FIBRE_PARAMETER_ID_WIDTH-1 downto 0);      -- parameter id
   num_data_o   : out    std_logic_vector (FIBRE_DATA_SIZE_WIDTH-1 downto 0);   -- number of valid 32 bit data words
   cmd_data_o   : out    std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);        -- 32bit valid data word
   cksum_err_o  : out    std_logic;                                           -- checksum error flag
   cmd_rdy_o    : out    std_logic;                                           -- command ready flag (checksum passed)
   data_clk_o   : out    std_logic                                            -- data clock
   );
end component;


end issue_reply_pack;
