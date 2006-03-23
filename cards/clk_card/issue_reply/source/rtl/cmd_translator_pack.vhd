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
-- $Id: cmd_translator_pack.vhd,v 1.9 2006/03/09 00:57:10 bburger Exp $
--
-- Project:    SCUBA2
-- Author:     Greg Dennis
-- Organization:  UBC
--
-- Description:
-- Declares a few constants used as parameters in the cmd_translator block
--
-- Revision history:
-- $Log: cmd_translator_pack.vhd,v $
-- Revision 1.9  2006/03/09 00:57:10  bburger
-- Bryce:  Added the following signals to the interface:  dv_mode_i, external_dv_i, external_dv_num_i
--
-- Revision 1.8  2006/02/11 01:19:33  bburger
-- Bryce:  Added the following signal interfaces to implement responding to external dv pulses
-- data_req
-- data_ack
-- frame_num_external
--
-- Revision 1.7  2006/01/16 18:45:27  bburger
-- Ernie:  removed references to issue_reply_pack and cmd_translator_pack
-- moved component declarations from above package files to cmd_translator
-- renamed constants to work with new command_pack (new bus backplane constants)
--
-- Revision 1.6  2005/09/28 23:35:22  bburger
-- Bryce:
-- removed ret_dat_s logic and interface signals, which are not used.
-- added a hardcoded data size in cmd_translator_ret_dat_fsm of 328 for data frames
--
-- Revision 1.5  2005/03/19 00:31:23  bburger
-- bryce:  Fixed several bugs.  Tagging cc_01010007.
--
-- Revision 1.4  2005/03/04 03:45:58  bburger
-- Bryce:  fixed bugs associated with ret_dat_s and ret_dat
--
-- Revision 1.3  2004/12/03 07:45:32  jjacob
-- debugging internal commands
--
-- Revision 1.2  2004/12/02 05:41:32  jjacob
-- added internal_cmd output
--
-- Revision 1.1  2004/11/24 01:15:52  bench2
-- Greg: Broke apart issue reply and created pack files for all of its sub-components
--
--
--
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;

library work;
use work.sync_gen_pack.all;
use work.frame_timing_pack.all;



package cmd_translator_pack is

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
--      data_size_i             : in std_logic_vector (FIBRE_DATA_SIZE_WIDTH-1 downto 0);  -- data_size_i, indicates number of 16-bit words of data
      data_i                  : in std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);       -- data will be passed straight thru in 16-bit words
      data_clk_i              : in std_logic;                                          -- for clocking out the data
      cmd_code_i              : in std_logic_vector (15 downto 0);
  
      -- ret_dat_wbs interface:
      start_seq_num_i         : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      stop_seq_num_i          : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      data_rate_i             : in std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);

      -- other inputs
      sync_pulse_i            : in std_logic;
      sync_number_i           : in std_logic_vector (SYNC_NUM_WIDTH-1 downto 0);    -- a counter of synch pulses
      ret_dat_start_i         : in std_logic;
      ret_dat_stop_i          : in std_logic;
      dv_mode_i               : in std_logic_vector(DV_SELECT_WIDTH-1 downto 0);
      external_dv_i           : in std_logic;
      external_dv_num_i       : in std_logic_vector(DV_NUM_WIDTH-1 downto 0);
      
      ret_dat_cmd_valid_o     : out std_logic;

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
      
      -- inputs from the internal commands state machine
      internal_cmd_card_addr_i       : in std_logic_vector (FIBRE_CARD_ADDRESS_WIDTH-1 downto 0);  -- specifies which card the command is targetting
      internal_cmd_parameter_id_i    : in std_logic_vector (FIBRE_PARAMETER_ID_WIDTH-1 downto 0);  -- comes from reg_addr_i, indicates which device(s) the command is targetting
      internal_cmd_data_size_i       : in std_logic_vector (FIBRE_DATA_SIZE_WIDTH-1 downto 0);     -- data_size_i, indicates number of 16-bit words of data
      internal_cmd_data_i            : in std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);         -- data will be passed straight thru in 16-bit words
      internal_cmd_data_clk_i        : in std_logic;                                                            -- for clocking in the data
      internal_cmd_macro_instr_rdy_i : in std_logic;                                               -- ='1' when the data is valid, else it's '0'
      internal_cmd_type_i            : in std_logic_vector (BB_COMMAND_TYPE_WIDTH-1 downto 0);     -- this is a re-mapping of the cmd_code into a 3-bit number
      
      -- output to the internal command state machine
      internal_cmd_ack_o             : out std_logic ;  
          
      -- input for sync_number for simple commands
      sync_number_i                : in  std_logic_vector (SYNC_NUM_WIDTH-1 downto 0);

      -- outputs to the cmd_queue (micro instruction sequence generator)
--      m_op_seq_num_o               : out std_logic_vector (BB_MACRO_OP_SEQ_WIDTH-1 downto 0);
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
      internal_cmd_o               : out std_logic;
      
      -- input from the micro-instruction arbiter
      ack_i             : in std_logic                   -- acknowledgment from the micro-instr arbiter that it is ready and has grabbed the data
   );
end component;



component cmd_translator_internal_cmd_fsm
   port(
       -- global inputs
       rst_i             : in     std_logic;
       clk_i             : in     std_logic;

       -- inputs from cmd_translator top level
       internal_cmd_start_i : in std_logic;
       --internal_cmd_stop_i  : in std_logic;   
  
       -- outputs to the macro-instruction arbiter
       card_addr_o       : out std_logic_vector (FIBRE_CARD_ADDRESS_WIDTH-1 downto 0);  -- specifies which card the command is targetting
       parameter_id_o    : out std_logic_vector (FIBRE_PARAMETER_ID_WIDTH-1 downto 0);  -- comes from reg_addr_i, indicates which device(s) the command is targetting
       data_size_o       : out std_logic_vector (FIBRE_DATA_SIZE_WIDTH-1 downto 0);     -- data_size_i, indicates number of 16-bit words of data
       data_o            : out std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);         -- data will be passed straight thru in 16-bit words
       data_clk_o        : out std_logic;                                                   -- for clocking out the data
       macro_instr_rdy_o : out std_logic;                                               -- ='1' when the data is valid, else it's '0'
       cmd_type_o        : out std_logic_vector (BB_COMMAND_TYPE_WIDTH-1 downto 0);     -- this is a re-mapping of the cmd_code into a 3-bit number
       
       -- input from the macro-instruction arbiter
       ack_i             : in std_logic                   -- acknowledgment from the macro-instr arbiter that it is ready and has grabbed the data
                             -- not currently used
   ); 
end component;


--component cmd_translator_m_op_table 
--   port(
--      -- global inputs
--      rst_i                   : in     std_logic;
--      clk_i                   : in     std_logic;
--
--      -- inputs from cmd_translator (top level)     
--      card_addr_store_i       : in std_logic_vector (FIBRE_CARD_ADDRESS_WIDTH-1 downto 0);  -- specifies which card the command is targetting
--      parameter_id_store_i    : in std_logic_vector (FIBRE_PARAMETER_ID_WIDTH-1    downto 0);  -- comes from reg_addr_i, indicates which device(s) the command is targetting
--      m_op_seq_num_store_i    : in std_logic_vector (BB_MACRO_OP_SEQ_WIDTH-1       downto 0);
--      frame_seq_num_store_i   : in std_logic_vector (31                    downto 0);
--      macro_instr_rdy_i       : in std_logic;                                           -- '1' when data is valid and ready to be stored in table 
-- 
--      -- inputs from reply translator
--      m_op_seq_num_retire_i    : in std_logic_vector (BB_MACRO_OP_SEQ_WIDTH-1       downto 0);
--      macro_instr_done_i       : in std_logic;                                          --'1' when issued command ready to be retired from table  
--       
--      retiring_busy_o          : out std_logic;                                         -- asserted high if retiring a command, during which no command should be issued.
--      table_empty_o            : out std_logic;                                         -- asserted high if table full.  no more macro instructions should be retired.
--      table_full_o             : out std_logic                                          -- asserted high  if table full.  No more macro instructions should be issued.
--   ); 
--end component;

end cmd_translator_pack;
