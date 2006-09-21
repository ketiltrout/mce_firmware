-- Copyright (c) 2003 SCUBA-2 Project
--                  All Rights Reserved

--  THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF THE SCUBA-2 Project
--  The copyright notice above does not evidence any
--  actual or intended publication of such source code.

--  SOURCE CODE IS PROVIDED "AS IS". ALL EXPRESS OR IMPLIED CONDITIONS,
--  REPRESENTATIONS, AND WARRANTIES, INCLUDING ANY IMPLIED WARRANT OF
--  MERCHANTABILITY, SATISFACTORY QUALITY, FITNESS FOR A PARTICULAR
--  PURPOSE, OR NON-INFRINGEMENT, ARE DISCLAIMED, EXCEPT TO THE EXTENT
--  THAT SUCH DISCLAIMERS ARE HELD TO BE LEGALLY INVALID.

-- For the purposes of this code the SCUBA-2 Project consists of the
-- following organisations.

-- UKATC, Royal Observatory, Blackford Hill Edinburgh EH9 3HJ
-- UBC,   University of British Columbia, Physics & Astronomy Department,
--        Vancouver BC, V6T 1Z1

-- 
--
-- <revision control keyword substitutions e.g. $Id: issue_reply.vhd,v 1.53 2006/09/07 22:25:22 bburger Exp $>
--
-- Project:       SCUBA-2
-- Author:        Jonathan Jacob
--
-- Organisation:  UBC
--
-- Description:  This module is the top level for receiving fibre commands, translating them into
-- instructions, and issuing them over the bus backplane. 
-- 
--
-- Revision history:
-- 
-- <date $Date: 2006/09/07 22:25:22 $> -     <text>      - <initials $Author: bburger $>
--
-- $Log: issue_reply.vhd,v $
-- Revision 1.53  2006/09/07 22:25:22  bburger
-- Bryce:  replace cmd_type (1-bit: read/write) interfaces and funtionality with cmd_code (32-bit: read_block/ write_block/ start/ stop/ reset) interface because reply_queue_sequencer needed to know to discard replies to reset commands
--
-- Revision 1.52  2006/08/16 18:07:46  bburger
-- Bryce:  piped the dv sequence number to the reply queue for inclusion in data headers
--
-- Revision 1.51  2006/07/11 18:22:24  bburger
-- Bryce:  Added a debug port to reply_translator
--
-- Revision 1.50  2006/07/01 00:04:25  bburger
-- Bryce:  added active_clk, sync_box_err and sync_box_free_run interface signals to reply_queue, clk_switchover and dv_rx blocks
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library components;
use components.component_pack.all;

library work;
use work.sync_gen_pack.all;
use work.fibre_rx_pack.all;
use work.frame_timing_pack.all;

library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;

entity issue_reply is
   port(
      -- for testing
      debug_o                : out std_logic_vector (31 downto 0);
   
      -- global signals
      rst_i                  : in std_logic;
      clk_i                  : in std_logic;
      comm_clk_i             : in std_logic;
   
      -- inputs from the bus backplane
      lvds_reply_ac_a        : in std_logic;  
      lvds_reply_bc1_a       : in std_logic;
      lvds_reply_bc2_a       : in std_logic;
      lvds_reply_bc3_a       : in std_logic;
      lvds_reply_rc1_a       : in std_logic;
      lvds_reply_rc2_a       : in std_logic;
      lvds_reply_rc3_a       : in std_logic; 
      lvds_reply_rc4_a       : in std_logic;
      lvds_reply_cc_a        : in std_logic;
      
      -- inputs from the fibre receiver 
      fibre_clkr_i           : in std_logic;
      rx_data_i              : in std_logic_vector (7 DOWNTO 0);
      nRx_rdy_i              : in std_logic;
      rvs_i                  : in std_logic;
      rso_i                  : in std_logic;
      rsc_nRd_i              : in std_logic;        
      cksum_err_o            : out std_logic;
   
      -- interface to fibre transmitter
      tx_data_o              : out std_logic_vector (7 downto 0);      -- byte of data to be transmitted
      tsc_nTd_o              : out std_logic;                          -- hotlink tx special char/ data sel
      nFena_o                : out std_logic;                          -- hotlink tx enable
   
      -- 25MHz clock for fibre_tx_control
      fibre_clkw_i           : in std_logic;                           -- in phase with 25MHz hotlink clock
   
      -- lvds_tx interface
      lvds_cmd_o             : out std_logic;                          -- transmitter output pin
   
      -- ret_dat_wbs interface
      start_seq_num_i        : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      stop_seq_num_i         : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      data_rate_i            : in std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);
      ret_dat_req_i          : in std_logic;
      ret_dat_ack_o          : out std_logic;

      -- sync_gen interface
      dv_mode_i              : in std_logic_vector(DV_SELECT_WIDTH-1 downto 0);
      external_dv_i          : in std_logic;
      external_dv_num_i      : in std_logic_vector(DV_NUM_WIDTH-1 downto 0);

      -- ret_dat_wbs interface
      tes_bias_toggle_en_i   : in std_logic;
      tes_bias_high_i        : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      tes_bias_low_i         : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      tes_bias_toggle_rate_i : in std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);
      status_cmd_en_i        : in std_logic;
   
      -- clk_switchover interface
      active_clk_i           : in std_logic;
   
      -- dv_rx interface
      sync_box_err_i         : in std_logic;
      sync_box_free_run_i    : in std_logic;
   
      -- sync_gen interface
      row_len_i              : in integer;
      num_rows_i             : in integer;
      sync_pulse_i           : in std_logic;
      sync_number_i          : in std_logic_vector (SYNC_NUM_WIDTH-1 downto 0)
   );     
end issue_reply;


architecture rtl of issue_reply is

   component fibre_rx
   port( 
      rst_i        : in     std_logic;                                         -- global reset
      clk_i        : in     std_logic;                                         -- gobal clock
      
      fibre_clkr_i : in     std_logic;                                          -- CKR from hotlink receiver       
      nRx_rdy_i    : in     std_logic;                                         -- received fibre data ready (active low) 
      rvs_i        : in     std_logic;                                         -- receive fibre data violation symbol (high indicates error)
      rso_i        : in     std_logic;                                         -- receive fibre status out
      rsc_nRd_i    : in     std_logic;                                         -- received special character / (Not) Data select
      rx_data_i    : in     std_logic_vector (RX_FIFO_DATA_WIDTH-1 downto 0);  -- received data byte from fibre  
      cmd_ack_i    : in     std_logic;                                         -- command acknowledge
      
      cmd_code_o   : out    std_logic_vector (FIBRE_PACKET_TYPE_WIDTH-1 downto 0);   -- command code  
      card_id_o    : out    std_logic_vector (FIBRE_CARD_ADDRESS_WIDTH-1 downto 0);  -- card id
      param_id_o   : out    std_logic_vector (FIBRE_PARAMETER_ID_WIDTH-1 downto 0);     -- parameter id
      num_data_o   : out    std_logic_vector (FIBRE_DATA_SIZE_WIDTH-1 downto 0);  -- number of valid 32 bit data words
      cmd_data_o   : out    std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);       -- 32bit valid data word
      cksum_err_o  : out    std_logic;                                          -- checksum error flag
      cmd_rdy_o    : out    std_logic;                                          -- command ready flag (checksum passed)
      data_clk_o   : out    std_logic                                           -- data clock
   );
   end component;
   
   -------------------------------
   component cmd_translator
   -------------------------------
   port(-- global inputs
      rst_i                 : in  std_logic;
      clk_i                 : in  std_logic;

      -- inputs from fibre_rx
      card_id_i             : in  std_logic_vector (FIBRE_CARD_ADDRESS_WIDTH-1 downto 0);       -- specifies which card the command is targetting
      cmd_code_i            : in  std_logic_vector ( FIBRE_PACKET_TYPE_WIDTH-1 downto 0);       -- the least significant 16-bits from the fibre packet
      cmd_data_i            : in  std_logic_vector (       PACKET_WORD_WIDTH-1 downto 0);       -- the data
      cksum_err_i           : in  std_logic;
      cmd_rdy_i             : in  std_logic;                                                    -- indicates the fibre_rx outputs are valid
      data_clk_i            : in  std_logic;                                                    -- used to clock the data out
      num_data_i            : in  std_logic_vector (    FIBRE_DATA_SIZE_WIDTH-1 downto 0);      -- number of 16-bit data words to be clocked out, possibly number of bytes
      param_id_i            : in  std_logic_vector ( FIBRE_PARAMETER_ID_WIDTH-1 downto 0);      -- the parameter ID
 
      -- output to fibre_rx
      ack_o                 : out std_logic;
      
      -- ret_dat_wbs interface:
      start_seq_num_i       : in  std_logic_vector(        PACKET_WORD_WIDTH-1 downto 0);
      stop_seq_num_i        : in  std_logic_vector(        PACKET_WORD_WIDTH-1 downto 0);
      data_rate_i           : in  std_logic_vector(           SYNC_NUM_WIDTH-1 downto 0);
      dv_mode_i             : in std_logic_vector(DV_SELECT_WIDTH-1 downto 0);
      external_dv_i         : in std_logic;
      external_dv_num_i     : in std_logic_vector(DV_NUM_WIDTH-1 downto 0);
      ret_dat_req_i         : in std_logic;
      ret_dat_ack_o         : out std_logic;

      -- ret_dat_wbs interface
      tes_bias_toggle_en_i   : in std_logic;
      tes_bias_high_i        : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      tes_bias_low_i         : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      tes_bias_toggle_rate_i : in std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);
      status_cmd_en_i        : in std_logic;

      -- other inputs 
      sync_pulse_i          : in  std_logic;
      sync_number_i         : in  std_logic_vector (          SYNC_NUM_WIDTH-1 downto 0);
     
      -- signals from the arbiter to cmd_queue
      cmd_code_o            : out std_logic_vector (FIBRE_PACKET_TYPE_WIDTH-1 downto 0);        -- this is a re-mapping of the cmd_code into a 3-bit number
      card_addr_o           : out std_logic_vector (BB_CARD_ADDRESS_WIDTH-1 downto 0);        -- specifies which card the command is targetting
      parameter_id_o        : out std_logic_vector (BB_PARAMETER_ID_WIDTH-1 downto 0);        -- comes from param_id_i, indicates which device(s) the command is targetting
      data_size_o           : out std_logic_vector (BB_DATA_SIZE_WIDTH-1 downto 0);        -- num_data_i, indicates number of 16-bit words of data
      data_o                : out std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);        -- data will be passed straight thru
      data_clk_o            : out std_logic;
      instr_rdy_o           : out std_logic;
      cmd_stop_o            : out std_logic;                                                     -- indicates a STOP command was recieved
      last_frame_o          : out std_logic;                                                     -- indicates the last frame of data for a ret_dat command
      internal_cmd_o        : out std_logic;                                       
      row_len_i             : in integer;
      num_rows_i            : in integer;
      tes_bias_step_level_o : out std_logic;
      
      -- input from the cmd_queue
      ack_i                 : in  std_logic;                                                     -- acknowledge signal from the micro-instruction sequence generator

      -- outputs to the cmd_queue
      frame_seq_num_o       : out std_logic_vector (       PACKET_WORD_WIDTH-1 downto 0);
      frame_sync_num_o      : out std_logic_vector (          SYNC_NUM_WIDTH-1 downto 0);

      -- outputs to reply_translator for commands that require quick acknowldgements
      reply_cmd_rcvd_er_o   : out std_logic;
      reply_cmd_rcvd_ok_o   : out std_logic;
      reply_cmd_code_o      : out std_logic_vector (FIBRE_PACKET_TYPE_WIDTH-1 downto 0);
      reply_param_id_o      : out std_logic_vector (FIBRE_PARAMETER_ID_WIDTH-1 downto 0);        -- the parameter ID
      reply_card_id_o       : out std_logic_vector (FIBRE_CARD_ADDRESS_WIDTH-1 downto 0)         -- specifies which card the command is targetting

   ); 
   end component;

   component cmd_queue
   port(
      -- for testing
      debug_o         : out std_logic_vector (31 downto 0);
      timer_trigger_o : out std_logic;

      -- reply_queue interface
      uop_rdy_o       : out std_logic; 
      uop_ack_i       : in std_logic; 
      card_addr_o     : out std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0);
      par_id_o        : out std_logic_vector(BB_PARAMETER_ID_WIDTH-1 downto 0);
      data_size_o     : out std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);
      cmd_code_o      : out std_logic_vector (FIBRE_PACKET_TYPE_WIDTH-1 downto 0);
      -- indicates a STOP command was recieved
      cmd_stop_o      : out std_logic;                                          
      -- indicates the last frame of data for a ret_dat command
      last_frame_o    : out std_logic;                                          
      frame_seq_num_o : out std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
      internal_cmd_o  : out std_logic;
      issue_sync_o    : out std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);
      tes_bias_step_level_o : out std_logic;

      -- cmd_translator interface
      card_addr_i     : in std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0); 
      par_id_i        : in std_logic_vector(BB_PARAMETER_ID_WIDTH-1 downto 0); 
      data_size_i     : in std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0); 
      data_i          : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);  
      data_clk_i      : in std_logic; 
      issue_sync_i    : in std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);
      mop_rdy_i       : in std_logic;
      mop_ack_o       : out std_logic; 
      cmd_code_i      : in std_logic_vector (FIBRE_PACKET_TYPE_WIDTH-1 downto 0);
      cmd_stop_i      : in std_logic;                                          
      last_frame_i    : in std_logic;                                          
      frame_seq_num_i : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
      internal_cmd_i  : in std_logic;
      tes_bias_step_level_i : in std_logic;

      -- lvds_tx interface
      tx_o            : out std_logic;  

      -- frame_timing interface
      sync_num_i      : in std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);

      -- Clock lines
      clk_i           : in std_logic; 
      rst_i           : in std_logic  
   );
   end component;

   component reply_queue
   port(
      -- cmd_queue interface
      cmd_to_retire_i   : in std_logic;                                           
      cmd_sent_o        : out std_logic;                                          
      card_addr_i       : in std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0); 
      par_id_i          : in std_logic_vector(BB_PARAMETER_ID_WIDTH-1 downto 0); 
      data_size_i       : in std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);  
      cmd_stop_i        : in std_logic;                                          
      last_frame_i      : in std_logic;                                          
      frame_seq_num_i   : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
      internal_cmd_i    : in std_logic;
      tes_bias_step_level_i : in std_logic;

      data_rate_i       : in std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);
      row_len_i         : in integer;
      num_rows_i        : in integer;
      issue_sync_i      : in std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);
      
      -- cmd_translator interface
      cmd_code_i        : in  std_logic_vector ( FIBRE_PACKET_TYPE_WIDTH-1 downto 0);       -- the least significant 16-bits from the fibre packet

      -- reply_translator interface (from reply_queue, i.e. these signals are de-multiplexed from retire and sequencer)
      size_o            : out integer;
      data_o            : out std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
      error_code_o      : out std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
      rdy_o             : out std_logic;
      ack_i             : in std_logic;
      
      -- reply_translator interface (from reply_queue_retire)
      cmd_sent_i        : in std_logic;
      cmd_valid_o       : out std_logic;
      cmd_code_o        : out std_logic_vector(FIBRE_PACKET_TYPE_WIDTH-1 downto 0); 
      param_id_o        : out std_logic_vector(BB_PARAMETER_ID_WIDTH-1 downto 0); 
      card_addr_o       : out std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0); 
      stop_bit_o        : out std_logic;                                          
      last_frame_bit_o  : out std_logic;                                          
      frame_seq_num_o   : out std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);     

      -- clk_switchover interface
      active_clk_i      : in std_logic;

      -- dv_rx interface
      sync_box_err_i      : in std_logic;
      sync_box_free_run_i : in std_logic;
      external_dv_num_i   : in std_logic_vector(DV_NUM_WIDTH-1 downto 0);

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

   component reply_translator
   port(
      -- for testing
      debug_o             : out std_logic_vector (31 downto 0);

      -- global inputs 
      rst_i                   : in  std_logic;                                               -- global reset
      clk_i                   : in  std_logic;                                               -- global clock

      -- signals to/from cmd_translator    
      cmd_rcvd_er_i           : in  std_logic;                                               -- command received on fibre with checksum error
      cmd_rcvd_ok_i           : in  std_logic;                                               -- command received on fibre - no checksum error
      cmd_code_i              : in  std_logic_vector (FIBRE_PACKET_TYPE_WIDTH-1  downto 0);  -- fibre command code
      card_addr_i             : in  std_logic_vector (FIBRE_CARD_ADDRESS_WIDTH-1 downto 0);  -- fibre command card id
      param_id_i              : in  std_logic_vector (FIBRE_PARAMETER_ID_WIDTH-1 downto 0);  -- fibre command parameter id
          
      -- signals to/from reply queue 
      mop_rdy_i               : in  std_logic;                                                 -- macro op response ready to be processed
      mop_error_code_i        : in  std_logic_vector (PACKET_WORD_WIDTH-1      downto 0);      -- macro op success (others => '0') else error code
      fibre_word_i            : in  std_logic_vector (PACKET_WORD_WIDTH-1     downto 0);      -- packet word read from reply queue
      num_fibre_words_i       : in  integer ;                                                 -- indicate number of packet words to be read from reply queue
      fibre_word_ack_o        : out std_logic;                                                -- asserted to requeset next fibre word
      fibre_word_rdy_i        : in std_logic;
      mop_ack_o               : out std_logic;                                                 -- asserted to indicate to reply queue the the packet has been processed
      cmd_stop_i              : in std_logic;
      last_frame_i            : in std_logic;
      frame_seq_num_i         : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);

      -- signals to / from fibre_tx
      fibre_tx_busy_i         : in std_logic;                                             -- transmit fifo full
      fibre_tx_rdy_o          : out std_logic;                                            -- transmit fifo write request
      fibre_tx_dat_o          : out std_logic_vector(PACKET_WORD_WIDTH-1 downto 0)                         -- transmit fifo data input
      );      
   end component;

   component fibre_tx
   port(       
      clk_i  : in std_logic;
      rst_i  : in std_logic;
      
      dat_i  : in std_logic_vector(31 downto 0);
      rdy_i  : in std_logic;
      busy_o : out std_logic;    
   
      fibre_clk_i   : in std_logic;    
      fibre_clkw_o  : out std_logic;
      fibre_data_o  : out std_logic_vector(7 downto 0);
      fibre_sc_nd_o : out std_logic;
      fibre_nena_o  : out std_logic
   );
   end component;

   -- inputs from fibre_rx 
   signal card_id             : std_logic_vector (FIBRE_CARD_ADDRESS_WIDTH-1 downto 0);    -- specifies which card the command is targetting
   signal cmd_code            : std_logic_vector (FIBRE_PACKET_TYPE_WIDTH-1 downto 0);                       -- the least significant 16-bits from the fibre packet
   signal cksum_err           : std_logic;
   signal cmd_data            : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);         -- the data 
   signal cmd_rdy             : std_logic;                                            -- indicates the fibre_rx outputs are valid
   signal data_clk            : std_logic;                                            -- used to clock the data out
   signal num_data            : std_logic_vector (FIBRE_DATA_SIZE_WIDTH-1 downto 0);    -- number of 16-bit data words to be clocked out, possibly number of bytes
   signal param_id            : std_logic_vector (FIBRE_PARAMETER_ID_WIDTH-1 downto 0);       -- the parameter ID
   signal cmd_type            : std_logic_vector (BB_COMMAND_TYPE_WIDTH-1 downto 0);       -- this is a re-mapping of the cmd_code into a 3-bit number
   signal cmd_ack             : std_logic;   -- acknowledge signal from cmd_translator to fibre_rx  
   signal reply_cmd_rcvd_er   : std_logic;
   signal reply_cmd_rcvd_ok   : std_logic;
   signal reply_cmd_code      : std_logic_vector (FIBRE_PACKET_TYPE_WIDTH-1 downto 0);
   signal reply_cmd_code_b    : std_logic_vector (FIBRE_PACKET_TYPE_WIDTH-1 downto 0);
   signal reply_cmd_code_c    : std_logic_vector (FIBRE_PACKET_TYPE_WIDTH-1 downto 0);
   signal reply_param_id      : std_logic_vector (FIBRE_PARAMETER_ID_WIDTH-1 downto 0); 
   signal reply_card_id       : std_logic_vector (FIBRE_CARD_ADDRESS_WIDTH-1 downto 0);
   signal sync_pulse          : std_logic;
   signal issue_sync          : std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);
   
   -- reply_queue interface
   signal uop_rdy             : std_logic;
   signal uop_ack             : std_logic;
   signal card_addr_cr        : std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0); -- The card address of the m-op
   signal par_id_cr           : std_logic_vector(BB_PARAMETER_ID_WIDTH-1 downto 0); -- The parameter id of the m-op
   signal data_size_cr        : std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0); -- The number of bytes of data in the m-op
   signal cmd_type_cr         : std_logic_vector(BB_COMMAND_TYPE_WIDTH-1 downto 0);       -- this is a re-mapping of the cmd_code into a 3-bit number
   signal cmd_stop_cr         : std_logic;                                          -- indicates a STOP command was recieved
   signal last_frame_cr       : std_logic;                                          -- indicates the last frame of data for a ret_dat command
   signal frame_seq_num_cr    : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal internal_cmd_cr     : std_logic;
   signal tes_bias_step_level : std_logic;

   -- cmd_translator to cmd_queue interface
   signal card_addr           : std_logic_vector (BB_CARD_ADDRESS_WIDTH-1 downto 0);
   signal parameter_id        : std_logic_vector (BB_PARAMETER_ID_WIDTH-1 downto 0); 
   signal data_size           : std_logic_vector (BB_DATA_SIZE_WIDTH-1 downto 0);
   signal data                : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
   signal data_clk2           : std_logic; 
   signal frame_sync_num      : std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);
   signal frame_seq_num       : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal macro_instr_rdy     : std_logic; 
   signal mop_ack             : std_logic; 
   signal cmd_stop            : std_logic;
   signal last_frame          : std_logic;      
   signal internal_cmd_issued : std_logic;
   signal tes_bias_step_level2 : std_logic;
   
   -- reply_translator to reply_queue interface      
   signal m_op_rdy            : std_logic;     
   signal m_op_error_code     : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0); 
   signal fibre_word          : std_logic_vector (PACKET_WORD_WIDTH-1        downto 0); 
   signal num_fibre_words     : integer;    
   signal fibre_word_ack      : std_logic;
   signal fibre_word_rdy      : std_logic;
   signal m_op_ack            : std_logic;   
   signal reply_cmd_stop      : std_logic;
   signal reply_last_frame    : std_logic;
   signal reply_frame_seq_num : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
 
   -- reply_translator / fibre_tx interface 
   signal fibre_tx_dat        : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0); 
   signal fibre_tx_rdy        : std_logic; 
   signal fibre_tx_busy       : std_logic;     
   
   type state is (IDLE, WAIT1, WAIT2, ACK1, ACK2);
   signal cur_state, next_state  : state;

begin

   ------------------------------------------------------------------------
   -- fibre receiver
   ------------------------------------------------------------------------
   i_fibre_rx : fibre_rx
      port map( 
         rst_i        => rst_i,
         clk_i        => clk_i,
         
         -- inputs from the fibre
         fibre_clkr_i => fibre_clkr_i,
         nrx_rdy_i    => nrx_rdy_i,
         rvs_i        => rvs_i,
         rso_i        => rso_i,
         rsc_nrd_i    => rsc_nrd_i,
         rx_data_i    => rx_data_i,
         
         -- input from cmd_translator
         cmd_ack_i    => cmd_ack,                  -- command acknowledge
         
         -- outputs to cmd_translator
         cmd_code_o   => cmd_code,                   -- command code
         card_id_o    => card_id,                    -- card id
         param_id_o   => param_id,                   -- parameter id
         num_data_o   => num_data,                   -- number of valid 32 bit data words
         cmd_data_o   => cmd_data,                   -- 32bit valid data word
         cmd_rdy_o    => cmd_rdy,                    -- checksum error flag
         data_clk_o   => data_clk,                   -- data clock
         
         cksum_err_o  => cksum_err
      );

   cksum_err_o <= cksum_err;

   ------------------------------------------------------------------------
   -- fibre transmitter
   ------------------------------------------------------------------------
   i_fibre_tx : fibre_tx
      port map(        
         clk_i         => clk_i,
         rst_i         => rst_i,
         
         dat_i         => fibre_tx_dat,
         rdy_i         => fibre_tx_rdy,
         busy_o        => fibre_tx_busy,
     
         fibre_clk_i   => fibre_clkw_i,
         fibre_clkw_o  => open,
         fibre_data_o  => tx_data_o,
         fibre_sc_nd_o => tsc_nTd_o,
         fibre_nena_o  => nFena_o
      );

   ------------------------------------------------------------------------
   -- reply_translator
   ------------------------------------------------------------------------ 
   i_reply_translator : reply_translator
      port map(
         -- for testing
         debug_o           => debug_o,

         -- global inputs 
         rst_i             => rst_i,
         clk_i             => clk_i,

         -- signals to/from cmd_translator    
         cmd_rcvd_er_i     => reply_cmd_rcvd_er,
         cmd_rcvd_ok_i     => reply_cmd_rcvd_ok,
         cmd_code_i        => reply_cmd_code_c,
         card_addr_i       => reply_card_id,
         param_id_i        => reply_param_id,            
                         
         -- signals to/from reply queue
         mop_rdy_i         => m_op_rdy,  
         mop_error_code_i  => m_op_error_code, 
         fibre_word_i      => fibre_word,
         num_fibre_words_i => num_fibre_words,
         fibre_word_ack_o  => fibre_word_ack,
         fibre_word_rdy_i  => fibre_word_rdy,
         mop_ack_o         => m_op_ack,    
         
         cmd_stop_i        => reply_cmd_stop,
         last_frame_i      => reply_last_frame,
         frame_seq_num_i   => reply_frame_seq_num,

         -- signals to / from fibre_tx
         fibre_tx_rdy_o    => fibre_tx_rdy,
         fibre_tx_busy_i   => fibre_tx_busy,   
         fibre_tx_dat_o    => fibre_tx_dat
      );      

   ------------------------------------------------------------------------
   -- command translator
   ------------------------------------------------------------------------
   i_cmd_translator : cmd_translator
      port map(
         -- global inputs
         rst_i               => rst_i,
         clk_i               => clk_i,
         
         -- inputs from fibre_rx
         card_id_i           => card_id,
         cmd_code_i          => cmd_code,
         cmd_data_i          => cmd_data,
         cksum_err_i         => cksum_err,
         cmd_rdy_i           => cmd_rdy,
         data_clk_i          => data_clk,
         num_data_i          => num_data,
         param_id_i          => param_id,
         
         -- output to fibre_rx
         ack_o               => cmd_ack,
         
         -- outputs to cmd_queue         
         card_addr_o         => card_addr,
         parameter_id_o      => parameter_id,
         data_size_o         => data_size,
         data_o              => data,
         data_clk_o          => data_clk2,
         instr_rdy_o         => macro_instr_rdy,
         frame_seq_num_o     => frame_seq_num,
         frame_sync_num_o    => frame_sync_num,
         cmd_code_o          => reply_cmd_code,
         cmd_stop_o          => cmd_stop,
         last_frame_o        => last_frame,       
         internal_cmd_o      => internal_cmd_issued,
         row_len_i           => row_len_i,
         num_rows_i          => num_rows_i,
         tes_bias_step_level_o => tes_bias_step_level,
         
         --input from the u-op sequence generator
         ack_i               => mop_ack,
         
         -- reply_translator interface          
         reply_cmd_rcvd_er_o => reply_cmd_rcvd_er,
         reply_cmd_rcvd_ok_o => reply_cmd_rcvd_ok,
         reply_cmd_code_o    => reply_cmd_code_c,
         reply_param_id_o    => reply_param_id,
         reply_card_id_o     => reply_card_id,         
         
         start_seq_num_i     => start_seq_num_i,
         stop_seq_num_i      => stop_seq_num_i,
         data_rate_i         => data_rate_i,
         dv_mode_i           => dv_mode_i,        
         external_dv_i       => external_dv_i,    
         external_dv_num_i   => external_dv_num_i,
         ret_dat_req_i       => ret_dat_req_i,
         ret_dat_ack_o       => ret_dat_ack_o,

         -- ret_dat_wbs interface
         tes_bias_toggle_en_i   => tes_bias_toggle_en_i,
         tes_bias_high_i        => tes_bias_high_i,
         tes_bias_low_i         => tes_bias_low_i,
         tes_bias_toggle_rate_i => tes_bias_toggle_rate_i,
         status_cmd_en_i        => status_cmd_en_i,

         sync_pulse_i        => sync_pulse_i,
         sync_number_i       => sync_number_i
      );

   ------------------------------------------------------------------------
   -- command queue (u-op sequence generator)
   ------------------------------------------------------------------------               
   i_cmd_queue : cmd_queue
     port map(
        -- for testing
        debug_o         => open,
        timer_trigger_o => open,

        -- reply_queue interface
        uop_rdy_o       => uop_rdy,
        uop_ack_i       => uop_ack,
        card_addr_o     => card_addr_cr,    
        par_id_o        => par_id_cr,       
        data_size_o     => data_size_cr,    
        cmd_stop_o      => cmd_stop_cr,     
        last_frame_o    => last_frame_cr,   
        frame_seq_num_o => frame_seq_num_cr,
        internal_cmd_o  => internal_cmd_cr, 
        issue_sync_o    => issue_sync,
        cmd_code_o      => reply_cmd_code_b,
        tes_bias_step_level_o => tes_bias_step_level2,

        -- cmd_translator interface
        card_addr_i     => card_addr,
        par_id_i        => parameter_id,
        data_size_i     => data_size,
        data_i          => data,
        data_clk_i      => data_clk2,
        issue_sync_i    => frame_sync_num,
        mop_rdy_i       => macro_instr_rdy,
        mop_ack_o       => mop_ack,
        cmd_stop_i      => cmd_stop,
        last_frame_i    => last_frame,
        frame_seq_num_i => frame_seq_num,
        internal_cmd_i  => internal_cmd_issued,
        cmd_code_i      => reply_cmd_code,
        tes_bias_step_level_i  => tes_bias_step_level,

        -- lvds_tx interface
        tx_o            => lvds_cmd_o,

        -- frame_timing interface
        sync_num_i      => sync_number_i,

        -- Clock lines
        clk_i           => clk_i,
        rst_i           => rst_i
     );

   ------------------------------------------------------------------------
   -- reply queue
   ------------------------------------------------------------------------
   i_reply_queue : reply_queue
      port map(
         -- cmd_queue interface
         cmd_to_retire_i     => uop_rdy,
         cmd_sent_o          => uop_ack,
         card_addr_i         => card_addr_cr,    
         par_id_i            => par_id_cr,       
         data_size_i         => data_size_cr,    
         cmd_stop_i          => cmd_stop_cr,     
         last_frame_i        => last_frame_cr,   
         frame_seq_num_i     => frame_seq_num_cr,
         internal_cmd_i      => internal_cmd_cr,
         cmd_code_i          => reply_cmd_code_b,
         tes_bias_step_level_i => tes_bias_step_level2,
         
         data_rate_i         => data_rate_i,
         row_len_i           => row_len_i,
         num_rows_i          => num_rows_i,
         issue_sync_i        => issue_sync,

         -- reply_translator interface (from reply_queue, i.e. these signals are de-multiplexed from retire and sequencer)
         size_o              => num_fibre_words,
         data_o              => fibre_word,
         error_code_o        => m_op_error_code,
         cmd_valid_o         => m_op_rdy,
         rdy_o               => fibre_word_rdy,
         ack_i               => fibre_word_ack,
         
         -- reply_translator interface (from reply_queue_retire)
         cmd_sent_i          => m_op_ack,
         cmd_code_o          => open, --m_op_cmd_code,
         param_id_o          => open, --m_op_param_id,
         card_addr_o         => open, --m_op_card_id,
         stop_bit_o          => reply_cmd_stop,
         last_frame_bit_o    => reply_last_frame,
         frame_seq_num_o     => reply_frame_seq_num,

         -- clk_switchover interface
         active_clk_i        => active_clk_i,
   
         -- dv_rx interface
         sync_box_err_i      => sync_box_err_i,
         sync_box_free_run_i => sync_box_free_run_i,
         external_dv_num_i   => external_dv_num_i,

         -- Bus Backplane interface
         lvds_reply_ac_a     => lvds_reply_ac_a,
         lvds_reply_bc1_a    => lvds_reply_bc1_a,
         lvds_reply_bc2_a    => lvds_reply_bc2_a,
         lvds_reply_bc3_a    => lvds_reply_bc3_a,
         lvds_reply_rc1_a    => lvds_reply_rc1_a,
         lvds_reply_rc2_a    => lvds_reply_rc2_a,
         lvds_reply_rc3_a    => lvds_reply_rc3_a,
         lvds_reply_rc4_a    => lvds_reply_rc4_a,
         lvds_reply_cc_a     => lvds_reply_cc_a,
         
         -- Global signals
         clk_i               => clk_i,
         comm_clk_i          => comm_clk_i,
         rst_i               => rst_i
      );

end rtl; 