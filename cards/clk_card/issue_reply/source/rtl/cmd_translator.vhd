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
-- <revision control keyword substitutions e.g. $Id: cmd_translator.vhd,v 1.36 2006/03/16 00:19:17 bburger Exp $>
--
-- Project:       SCUBA-2
-- Author:         Jonathan Jacob
--
-- Organisation:  UBC
--
-- Description:  This module is the fibre command translator. 
-- 
-- 
--
-- Revision history:
-- 
-- <date $Date: 2006/03/16 00:19:17 $> -     <text>      - <initials $Author: bburger $>
--
-- $Log: cmd_translator.vhd,v $
-- Revision 1.36  2006/03/16 00:19:17  bburger
-- Bryce:
-- - added ret_dat_req_i  and ret_dat_ack_o interfaces
-- - reply_cmd_rcvd_ok_o is now asserted for a single cycle instead of for as long as cmd_rdy_i is asserted
--
-- Revision 1.35  2006/03/11 03:45:11  bburger
-- Bryce:  polishing off dv_rx functionality -- fixing bugs
--
-- Revision 1.34  2006/03/09 00:57:10  bburger
-- Bryce:  Added the following signals to the interface:  dv_mode_i, external_dv_i, external_dv_num_i
--
-- Revision 1.33  2006/02/11 01:19:33  bburger
-- Bryce:  Added the following signal interfaces to implement responding to external dv pulses
-- data_req
-- data_ack
-- frame_num_external
--
-- Revision 1.32  2006/01/16 18:45:27  bburger
-- Ernie:  removed references to issue_reply_pack and cmd_translator_pack
-- moved component declarations from above package files to cmd_translator
-- renamed constants to work with new command_pack (new bus backplane constants)
--
-- Revision 1.31  2005/11/15 03:17:22  bburger
-- Bryce: Added support to reply_queue_sequencer, reply_queue and reply_translator for timeouts and CRC errors from the bus backplane
--
-- Revision 1.30  2005/09/28 23:35:22  bburger
-- Bryce:
-- removed ret_dat_s logic and interface signals, which are not used.
-- added a hardcoded data size in cmd_translator_ret_dat_fsm of 328 for data frames
--
-- Revision 1.29  2005/09/03 23:51:26  bburger
-- jjacob:
-- removed recirculation muxes and replaced with register enables, and cleaned up formatting
--
-- Revision 1.28  2005/07/23 01:39:25  bburger
-- Bryce:
-- Added a wishbone-accessible register to change the data rate.  The register default is one frame of data every ten frames (maximum rate).
-- Disabled internal commanding
--
-- Revision 1.27  2005/03/04 03:45:58  bburger
-- Bryce:  fixed bugs associated with ret_dat_s and ret_dat
--
-- Revision 1.26  2005/02/19 22:40:17  mandana
-- jjacob: registered all outputs going to cmd_queue
--
-- Revision 1.25  2004/12/16 18:53:05  bench2
-- Mandana: added comments on how to disable internal commands
--
-- Revision 1.24  2004/12/03 07:45:17  jjacob
-- debugging internal commands
--
-- Revision 1.23  2004/12/02 05:42:07  jjacob
-- added internal commands
--
-- Revision 1.22  2004/11/25 01:32:37  bburger
-- Bryce:
-- - Changed to cmd_code over the bus backplane to read/write only
-- - Added interface signals for internal commands
-- - RB command data-sizes are correctly handled
--
-- Revision 1.21  2004/10/14 00:38:43  bburger
-- Bryce:  cleaning up un-used signals
--
-- Revision 1.20  2004/10/08 20:51:08  bburger
-- Bryce: No explicit command code checking is done except for commands that that require special handling (ret_dat, ret_dat_s)
--
-- Revision 1.19  2004/10/08 19:45:26  bburger
-- Bryce:  Changed SYNC_NUM_WIDTH to 16, removed TIMEOUT_SYNC_WIDTH, added a command-code to cmd_queue, added two words of book-keeping information to the cmd_queue
--
-- Revision 1.18  2004/09/30 22:34:44  erniel
-- using new command_pack constants
--
-- Revision 1.17  2004/09/10 19:14:36  jjacob
-- modifed outputs to reply_translator to feedthrough values from fibre_rx
--
-- Revision 1.16  2004/09/09 18:25:38  jjacob
-- added 3 outputs:
-- >       cmd_type_o        :  out std_logic_vector (BB_COMMAND_TYPE_WIDTH-1 downto 0);       -- this is a re-mapping of the cmd_code into a 3-bit number
-- >       cmd_stop_o        :  out std_logic;                                          -- indicates a STOP command was recieved
-- >       last_frame_o      :  out std_logic;                                          -- indicates the last frame of data for a ret_dat command
--
-- Revision 1.15  2004/09/02 23:41:43  jjacob
-- cleaning up and formatting
--
-- Revision 1.14  2004/09/02 18:24:17  jjacob
-- cleaning up and formatting
--
-- Revision 1.13  2004/08/25 22:15:33  bburger
-- Bryce:  removed the dbl_buffer command
--
-- Revision 1.12  2004/08/11 00:08:25  jjacob
-- added the following signals for the reply_translator interface:
--       reply_cmd_rcvd_er_o         : out std_logic;
--       reply_cmd_rcvd_ok_o         : out std_logic;
--       reply_cmd_code_o            : out std_logic_vector (15 downto 0);
--       reply_param_id_o            : out std_logic_vector (FIBRE_PARAMETER_ID_WIDTH-1 downto 0);       -- the parameter ID
--       reply_card_id_o             : out std_logic_vector (FIBRE_CARD_ADDRESS_WIDTH-1 downto 0)
--
-- and also added an input for the checksum error to route to the reply_cmd_rcvd_er_
--
-- Revision 1.11  2004/08/05 20:52:01  jjacob
-- added sync_number input to arbiter instatiation
--
-- Revision 1.10  2004/08/05 18:14:29  jjacob
-- changed frame_sync_num_o to use the parameter
-- SYNC_NUM_WIDTH
--
-- Revision 1.9  2004/07/28 23:39:05  jjacob
-- added:
-- library sys_param;
-- use sys_param.command_pack.all;
--
-- Revision 1.8  2004/07/05 23:38:56  jjacob
-- added ack_o signal to cmd_translator_ret_dat_fsm to control the
-- acknowledge signal back to the fibre_rx block
--
-- Revision 1.6  2004/06/21 16:57:24  jjacob
-- first stable version, doesn't yet have macro-instruction buffer, doesn't have
-- "quick" acknolwedgements for instructions that require them, no error
-- handling, basically no return path logic yet.  Have implemented ret_dat
-- instructions, and "simple" instructions.  Not all instructions are fully
-- implemented yet.
--
-- Revision 1.5  2004/06/09 23:32:47  jjacob
-- cleaned formatting
--
-- Revision 1.4  2004/06/08 00:14:10  jjacob
-- updating
--
-- Revision 1.3  2004/06/04 23:01:17  jjacob
-- daily update/ safety checkin
--
-- Revision 1.2  2004/06/03 23:39:39  jjacob
-- safety checkin
--
-- Revision 1.1  2004/05/28 15:53:25  jjacob
-- first version
--
--
-- 
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library components;
use components.component_pack.all;

library work;
use work.sync_gen_pack.all;

library sys_param;
use sys_param.wishbone_pack.all;
use sys_param.command_pack.all;

entity cmd_translator is

port(

     -- global inputs
      rst_i                 : in  std_logic;
      clk_i                 : in  std_logic;

      -- inputs from fibre_rx
      card_id_i             : in  std_logic_vector(FIBRE_CARD_ADDRESS_WIDTH-1 downto 0);       -- specifies which card the command is targetting
      cmd_code_i            : in  std_logic_vector( FIBRE_PACKET_TYPE_WIDTH-1 downto 0);       -- the least significant 16-bits from the fibre packet
      cmd_data_i            : in  std_logic_vector(       PACKET_WORD_WIDTH-1 downto 0);       -- the data
      cksum_err_i           : in  std_logic;
      cmd_rdy_i             : in  std_logic;                                                    -- indicates the fibre_rx outputs are valid
      data_clk_i            : in  std_logic;                                                    -- used to clock the data out
      num_data_i            : in  std_logic_vector(    FIBRE_DATA_SIZE_WIDTH-1 downto 0);      -- number of 16-bit data words to be clocked out, possibly number of bytes
      param_id_i            : in  std_logic_vector( FIBRE_PARAMETER_ID_WIDTH-1 downto 0);      -- the parameter ID
 
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

      -- other inputs 
      sync_pulse_i          : in  std_logic;
      sync_number_i         : in  std_logic_vector(          SYNC_NUM_WIDTH-1 downto 0);
     
      -- signals from the arbiter to cmd_queue
      cmd_type_o            : out std_logic_vector(BB_COMMAND_TYPE_WIDTH-1 downto 0);        -- this is a re-mapping of the cmd_code into a 3-bit number
      card_addr_o           : out std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0);        -- specifies which card the command is targetting
      parameter_id_o        : out std_logic_vector(BB_PARAMETER_ID_WIDTH-1 downto 0);        -- comes from param_id_i, indicates which device(s) the command is targetting
      data_size_o           : out std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);        -- num_data_i, indicates number of 16-bit words of data
      data_o                : out std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);        -- data will be passed straight thru
      data_clk_o            : out std_logic;
      instr_rdy_o           : out std_logic;
      cmd_stop_o            : out std_logic;                                                     -- indicates a STOP command was recieved
      last_frame_o          : out std_logic;                                                     -- indicates the last frame of data for a ret_dat command
      internal_cmd_o        : out std_logic;                                       
      
      -- input from the cmd_queue
      ack_i                 : in  std_logic;                                                     -- acknowledge signal from the micro-instruction sequence generator

      -- outputs to the cmd_queue
      frame_seq_num_o       : out std_logic_vector(       PACKET_WORD_WIDTH-1 downto 0);
      frame_sync_num_o      : out std_logic_vector(          SYNC_NUM_WIDTH-1 downto 0);

      -- outputs to reply_translator for commands that require quick acknowldgements
      reply_cmd_rcvd_er_o   : out std_logic;
      reply_cmd_rcvd_ok_o   : out std_logic;
      reply_cmd_code_o      : out std_logic_vector(FIBRE_PACKET_TYPE_WIDTH-1 downto 0);
      reply_param_id_o      : out std_logic_vector(FIBRE_PARAMETER_ID_WIDTH-1 downto 0);        -- the parameter ID
      reply_card_id_o       : out std_logic_vector(FIBRE_CARD_ADDRESS_WIDTH-1 downto 0)         -- specifies which card the command is targetting

   ); 
     
end cmd_translator;


architecture rtl of cmd_translator is

   -------------------------------------------------------------------------------------------
   -- 'return data' (ret_dat) state machine signals
   -------------------------------------------------------------------------------------------
   signal ret_dat_start                : std_logic;
   signal ret_dat_stop                 : std_logic;
   signal arbiter_ret_dat_ack          : std_logic;
   signal ret_dat_cmd_valid            : std_logic;
   signal ret_dat_ack                  : std_logic;
   signal ret_dat_cmd_stop             : std_logic;
   signal ret_dat_last_frame           : std_logic;
   
   -------------------------------------------------------------------------------------------   
   -- signals to state machine controlling simple commands
   -------------------------------------------------------------------------------------------
   signal cmd_start                    : std_logic;
   signal cmd_stop                     : std_logic;

   -------------------------------------------------------------------------------------------
   -- 'return data' signals to the arbiter
   -------------------------------------------------------------------------------------------
   
   component cmd_translator_ret_dat_fsm
   port(rst_i                   : in  std_logic;
        clk_i                   : in  std_logic;
        card_addr_i             : in  std_logic_vector (FIBRE_CARD_ADDRESS_WIDTH-1 downto 0);
        parameter_id_i          : in  std_logic_vector (FIBRE_PARAMETER_ID_WIDTH-1 downto 0);
        data_i                  : in  std_logic_vector (       PACKET_WORD_WIDTH-1 downto 0);
        data_clk_i              : in  std_logic;
        start_seq_num_i         : in  std_logic_vector(        PACKET_WORD_WIDTH-1 downto 0);
        stop_seq_num_i          : in  std_logic_vector(        PACKET_WORD_WIDTH-1 downto 0);
        data_rate_i             : in  std_logic_vector(           SYNC_NUM_WIDTH-1 downto 0);
        dv_mode_i               : in std_logic_vector(DV_SELECT_WIDTH-1 downto 0);
        external_dv_i           : in std_logic;
        external_dv_num_i       : in std_logic_vector(DV_NUM_WIDTH-1 downto 0);
        ret_dat_req_i           : in std_logic;
        ret_dat_ack_o           : out std_logic;
        sync_pulse_i            : in  std_logic;
        sync_number_i           : in  std_logic_vector (          SYNC_NUM_WIDTH-1 downto 0);
        ret_dat_start_i         : in  std_logic;
        ret_dat_stop_i          : in  std_logic;
        ret_dat_cmd_valid_o     : out std_logic;
        frame_seq_num_o         : out std_logic_vector (                        31 downto 0);
        frame_sync_num_o        : out std_logic_vector (          SYNC_NUM_WIDTH-1 downto 0);
        card_addr_o             : out std_logic_vector (BB_CARD_ADDRESS_WIDTH-1 downto 0);
        parameter_id_o          : out std_logic_vector (BB_PARAMETER_ID_WIDTH-1 downto 0);
        data_size_o             : out std_logic_vector (   BB_DATA_SIZE_WIDTH-1 downto 0);
        data_o                  : out std_logic_vector (    PACKET_WORD_WIDTH-1 downto 0);
        data_clk_o              : out std_logic;
        instr_rdy_o             : out std_logic;
        cmd_type_o              : out std_logic_vector (BB_COMMAND_TYPE_WIDTH-1 downto 0);
        cmd_stop_o              : out std_logic;                      
        last_frame_o            : out std_logic;
        ret_dat_fsm_working_o   : out std_logic;
        ack_i                   : in  std_logic;
        ack_o                   : out std_logic);
   end component;

   signal ret_dat_cmd_card_addr        : std_logic_vector (BB_CARD_ADDRESS_WIDTH-1 downto 0);  -- specifies which card the command is targetting
   signal ret_dat_cmd_parameter_id     : std_logic_vector (BB_PARAMETER_ID_WIDTH-1 downto 0);  -- comes from param_id_i, indicates which device(s) the command is targetting
   signal ret_dat_cmd_data_size        : std_logic_vector (   BB_DATA_SIZE_WIDTH-1 downto 0);  -- num_data_i, indicates number of 16-bit words of data
   signal ret_dat_cmd_data             : std_logic_vector (    PACKET_WORD_WIDTH-1 downto 0);  -- data will be passed straight thru
   signal ret_dat_cmd_data_clk         : std_logic;
   signal ret_dat_cmd_instr_rdy        : std_logic; 
   signal ret_dat_cmd_type             : std_logic_vector (BB_COMMAND_TYPE_WIDTH-1 downto 0);  -- this is a re-mapping of the cmd_code into a 3-bit number
   
   signal ret_dat_fsm_working          : std_logic;
   signal ret_dat_frame_seq_num        : std_logic_vector (    PACKET_WORD_WIDTH-1 downto 0);
   signal ret_dat_frame_sync_num       : std_logic_vector (       SYNC_NUM_WIDTH-1 downto 0);

   -------------------------------------------------------------------------------------------
   -- 'simple command' signals to the arbiter
   -------------------------------------------------------------------------------------------
   
   component cmd_translator_simple_cmd_fsm
   port(rst_i             : in  std_logic;
        clk_i             : in  std_logic;
        card_addr_i       : in  std_logic_vector (FIBRE_CARD_ADDRESS_WIDTH-1 downto 0);
        parameter_id_i    : in  std_logic_vector (FIBRE_PARAMETER_ID_WIDTH-1 downto 0);
        data_size_i       : in  std_logic_vector (   FIBRE_DATA_SIZE_WIDTH-1 downto 0);
        data_i            : in  std_logic_vector (       PACKET_WORD_WIDTH-1 downto 0);
        data_clk_i        : in  std_logic;
        cmd_code_i        : in  std_logic_vector ( FIBRE_PACKET_TYPE_WIDTH-1 downto 0);
        sync_pulse_i      : in  std_logic;
        cmd_start_i       : in  std_logic;
        cmd_stop_i        : in  std_logic;
        card_addr_o       : out std_logic_vector (BB_CARD_ADDRESS_WIDTH-1 downto 0);
        parameter_id_o    : out std_logic_vector (BB_PARAMETER_ID_WIDTH-1 downto 0);
        data_size_o       : out std_logic_vector (   BB_DATA_SIZE_WIDTH-1 downto 0);
        data_o            : out std_logic_vector (    PACKET_WORD_WIDTH-1 downto 0);
        data_clk_o        : out std_logic;
        instr_rdy_o       : out std_logic;
        cmd_type_o        : out std_logic_vector (BB_COMMAND_TYPE_WIDTH-1 downto 0);
        instr_ack_i       : in std_logic); 
   end component;

   signal simple_cmd_ack               : std_logic;                                               -- ready signal
   signal simple_cmd_card_addr         : std_logic_vector (BB_CARD_ADDRESS_WIDTH-1 downto 0);  -- specifies which card the command is targetting
   signal simple_cmd_parameter_id      : std_logic_vector (BB_PARAMETER_ID_WIDTH-1 downto 0);  -- comes from param_id_i, indicates which device(s) the command is targetting
   signal simple_cmd_data_size         : std_logic_vector (   BB_DATA_SIZE_WIDTH-1 downto 0);  -- num_data_i, indicates number of 16-bit words of data
   signal simple_cmd_data              : std_logic_vector (    PACKET_WORD_WIDTH-1 downto 0);  -- data will be passed straight thru
   signal simple_cmd_data_clk          : std_logic;
   signal simple_cmd_instr_rdy         : std_logic;
   signal simple_cmd_type              : std_logic_vector (BB_COMMAND_TYPE_WIDTH-1 downto 0);  -- this is a re-mapping of the cmd_code into a 3-bit number

   -------------------------------------------------------------------------------------------
   -- 'internal command' signals to the arbiter
   -------------------------------------------------------------------------------------------
   
   component cmd_translator_internal_cmd_fsm
   port(rst_i                : in  std_logic;
        clk_i                : in  std_logic;
        internal_cmd_start_i : in  std_logic;
        card_addr_o          : out std_logic_vector (BB_CARD_ADDRESS_WIDTH-1 downto 0);
        parameter_id_o       : out std_logic_vector (BB_PARAMETER_ID_WIDTH-1 downto 0);
        data_size_o          : out std_logic_vector (   BB_DATA_SIZE_WIDTH-1 downto 0);
        data_o               : out std_logic_vector (    PACKET_WORD_WIDTH-1 downto 0);
        data_clk_o           : out std_logic;
        instr_rdy_o          : out std_logic;
        cmd_type_o           : out std_logic_vector (BB_COMMAND_TYPE_WIDTH-1 downto 0);
        ack_i                : in  std_logic); 
   end component;

   signal internal_cmd_card_addr       : std_logic_vector (BB_CARD_ADDRESS_WIDTH-1 downto 0);
   signal internal_cmd_parameter_id    : std_logic_vector (BB_PARAMETER_ID_WIDTH-1 downto 0);
   signal internal_cmd_data_size       : std_logic_vector (   BB_DATA_SIZE_WIDTH-1 downto 0);
   signal internal_cmd_data            : std_logic_vector (    PACKET_WORD_WIDTH-1 downto 0);  
   signal internal_cmd_data_clk        : std_logic; 
   signal internal_cmd_instr_rdy       : std_logic; 
   signal internal_cmd_type            : std_logic_vector (BB_COMMAND_TYPE_WIDTH-1 downto 0);

   signal internal_cmd_start           : std_logic; 
   signal internal_cmd_ack             : std_logic;   
   signal timer_rst                    : std_logic;
   signal time                         : integer;
   
   -------------------------------------------------------------------------------------------
   -- arbiter signals
   -------------------------------------------------------------------------------------------
   
   component cmd_translator_arbiter
   port(rst_i                          : in  std_logic;
        clk_i                          : in  std_logic;
        ret_dat_frame_seq_num_i        : in  std_logic_vector (                     31 downto 0);
        ret_dat_frame_sync_num_i       : in  std_logic_vector (       SYNC_NUM_WIDTH-1 downto 0);
        ret_dat_card_addr_i            : in  std_logic_vector (BB_CARD_ADDRESS_WIDTH-1 downto 0);
        ret_dat_parameter_id_i         : in  std_logic_vector (BB_PARAMETER_ID_WIDTH-1 downto 0);
        ret_dat_data_size_i            : in  std_logic_vector (   BB_DATA_SIZE_WIDTH-1 downto 0);
        ret_dat_data_i                 : in  std_logic_vector (    PACKET_WORD_WIDTH-1 downto 0);
        ret_dat_data_clk_i             : in  std_logic; 
        ret_dat_instr_rdy_i            : in  std_logic; 
        ret_dat_fsm_working_i          : in  std_logic;
        ret_dat_cmd_type_i             : in  std_logic_vector (BB_COMMAND_TYPE_WIDTH-1 downto 0);
        ret_dat_cmd_stop_i             : in  std_logic;
        ret_dat_last_frame_i           : in  std_logic;
        ret_dat_ack_o                  : out std_logic;
        simple_cmd_card_addr_i         : in  std_logic_vector (BB_CARD_ADDRESS_WIDTH-1 downto 0);
        simple_cmd_parameter_id_i      : in  std_logic_vector (BB_PARAMETER_ID_WIDTH-1 downto 0);
        simple_cmd_data_size_i         : in  std_logic_vector (   BB_DATA_SIZE_WIDTH-1 downto 0);
        simple_cmd_data_i              : in  std_logic_vector (    PACKET_WORD_WIDTH-1 downto 0);
        simple_cmd_data_clk_i          : in  std_logic;
        simple_cmd_instr_rdy_i         : in  std_logic;
        simple_cmd_type_i              : in  std_logic_vector (BB_COMMAND_TYPE_WIDTH-1 downto 0);
        simple_cmd_ack_o               : out std_logic;  
        internal_cmd_card_addr_i       : in  std_logic_vector (BB_CARD_ADDRESS_WIDTH-1 downto 0);
        internal_cmd_parameter_id_i    : in  std_logic_vector (BB_PARAMETER_ID_WIDTH-1 downto 0);
        internal_cmd_data_size_i       : in  std_logic_vector (   BB_DATA_SIZE_WIDTH-1 downto 0);
        internal_cmd_data_i            : in  std_logic_vector (    PACKET_WORD_WIDTH-1 downto 0);
        internal_cmd_data_clk_i        : in  std_logic; 
        internal_cmd_instr_rdy_i       : in  std_logic; 
        internal_cmd_type_i            : in  std_logic_vector (BB_COMMAND_TYPE_WIDTH-1 downto 0);
        internal_cmd_ack_o             : out std_logic;  
        sync_number_i                  : in  std_logic_vector (       SYNC_NUM_WIDTH-1 downto 0);
        frame_seq_num_o                : out std_logic_vector (                     31 downto 0);
        frame_sync_num_o               : out std_logic_vector (       SYNC_NUM_WIDTH-1 downto 0);
        card_addr_o                    : out std_logic_vector (BB_CARD_ADDRESS_WIDTH-1 downto 0);
        parameter_id_o                 : out std_logic_vector (BB_PARAMETER_ID_WIDTH-1 downto 0);
        data_size_o                    : out std_logic_vector (   BB_DATA_SIZE_WIDTH-1 downto 0);
        data_o                         : out std_logic_vector (    PACKET_WORD_WIDTH-1 downto 0);
        data_clk_o                     : out std_logic; 
        instr_rdy_o                    : out std_logic; 
        cmd_type_o                     : out std_logic_vector (BB_COMMAND_TYPE_WIDTH-1 downto 0);  
        cmd_stop_o                     : out std_logic; 
        last_frame_o                   : out std_logic;  
        internal_cmd_o                 : out std_logic;  
        ack_i                          : in std_logic);      
   end component;

   signal card_addr                    : std_logic_vector (BB_CARD_ADDRESS_WIDTH-1 downto 0);
   signal parameter_id                 : std_logic_vector (BB_PARAMETER_ID_WIDTH-1 downto 0);
   signal data_size                    : std_logic_vector (   BB_DATA_SIZE_WIDTH-1 downto 0);
   signal data                         : std_logic_vector (    PACKET_WORD_WIDTH-1 downto 0);       
   signal data_clk                     : std_logic;
   signal instr_rdy                    : std_logic;
   signal cmd_type                     : std_logic_vector (BB_COMMAND_TYPE_WIDTH-1 downto 0);   
   signal cmd_stop_cmd_queue           : std_logic; 
   signal last_frame                   : std_logic; 
   signal internal_cmd                 : std_logic;                                       
   signal frame_seq_num                : std_logic_vector (    PACKET_WORD_WIDTH-1 downto 0);
   signal frame_sync_num               : std_logic_vector (       SYNC_NUM_WIDTH-1 downto 0);   
   
   -------------------------------------------------------------------------------------------
   -- registered arbiter output signals
   -------------------------------------------------------------------------------------------   
   type states is (IDLE, CMD_READY, CMD_WAITING);   
   signal current_state, next_state : states;

   signal card_addr_reg                : std_logic_vector (BB_CARD_ADDRESS_WIDTH-1 downto 0);
   signal parameter_id_reg             : std_logic_vector (BB_PARAMETER_ID_WIDTH-1 downto 0);
   signal data_size_reg                : std_logic_vector (   BB_DATA_SIZE_WIDTH-1 downto 0);
   signal data_reg                     : std_logic_vector (    PACKET_WORD_WIDTH-1 downto 0);       
   signal data_clk_reg                 : std_logic;
   signal instr_rdy_reg                : std_logic;
   signal cmd_type_reg                 : std_logic_vector (BB_COMMAND_TYPE_WIDTH-1 downto 0);   
   signal cmd_stop_reg                 : std_logic; 
   signal last_frame_reg               : std_logic; 
   signal internal_cmd_reg             : std_logic;                                       
   signal frame_seq_num_reg            : std_logic_vector (    PACKET_WORD_WIDTH-1 downto 0);
   signal frame_sync_num_reg           : std_logic_vector (       SYNC_NUM_WIDTH-1 downto 0); 

   signal data_req                     : std_logic;
   signal dat_req                      : std_logic;
   signal dat_ack                      : std_logic;

begin
   -------------------------------------------------------------------------------------------
   -- logic for routing incoming de-composed fibre commands
   -------------------------------------------------------------------------------------------
   
   -- This FSM ensures that the reply_cmd_rcvd_ok_o signal is only asserted for one cycle per command.
   cmd_state_FF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         current_state <= IDLE;
      elsif(clk_i'event and clk_i = '1') then
         current_state <= next_state;
      end if;
   end process;

   cmd_state_NS: process(current_state, cmd_rdy_i)
   begin
      next_state <= current_state;      
      case current_state is         
         when IDLE =>
            if (cmd_rdy_i = '1') then
               next_state <= CMD_READY;
            end if;         
         when CMD_READY =>
            next_state <= CMD_WAITING;         
         when CMD_WAITING =>
            if (cmd_rdy_i = '0') then
               next_state <= IDLE;
            end if;         
         when others =>
            next_state <= IDLE;      
      end case;
   end process;    
   
   cmd_state_out: process(current_state)
   begin
      reply_cmd_rcvd_ok_o <= '0';
      
      case current_state is
         when IDLE =>
         when CMD_READY =>
            reply_cmd_rcvd_ok_o <= '1';
         when CMD_WAITING =>
         when others =>
      end case;
   end process;

   process (cmd_rdy_i, param_id_i, cmd_code_i)            
   begin
      if cmd_rdy_i = '1' then 
         case param_id_i (7 downto 0) is
            -- RETURN DATA FRAMES command
            when RET_DAT_ADDR  =>
               if cmd_code_i = GO then
                  -- START command
                  ret_dat_start        <= '1';
                  ret_dat_stop         <= '0';
                  cmd_start            <= '0';
                  cmd_stop             <= '0';
               else 
                  -- assume it's a STOP command
                  ret_dat_start        <= '0';
                  ret_dat_stop         <= '1';
                  cmd_start            <= '0';
                  cmd_stop             <= '0';
               end if;

            -- all other commands (SIMPLE commands)
            when others =>
               ret_dat_start           <= '0';
               ret_dat_stop            <= '0';
               cmd_start               <= '1';
               cmd_stop                <= '0';

         end case;
                 
      else
        -- no commands pending
         ret_dat_start         <= '0';
         ret_dat_stop          <= '0';
         cmd_start             <= '0';
         cmd_stop              <= '0';
 
      end if;
   end process;

   -- Custom register that indicates fresh ret_dat commands
   dat_req <= data_req;
   data_req_reg: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         data_req <= '0';
      elsif(clk_i'event and clk_i = '1') then
         if(ret_dat_start = '1') then
            data_req <= '1';
         elsif(dat_ack = '1' or ret_dat_stop = '1') then
            data_req <= '0';
         else
            data_req <= data_req;
         end if;
      end if;
   end process data_req_reg;


   -------------------------------------------------------------------------------------------
   -- timer reset logic for issuing internal commands
   -------------------------------------------------------------------------------------------
   process(rst_i, clk_i)
   begin
      if rst_i = '1' then
         timer_rst               <= '1';
         internal_cmd_start      <= '0';  
      elsif clk_i'event and clk_i = '1' then 
   ---------------------------------------------------------------------  
   -- in order to disable internal commands, start commenting from here
   ---------------------------------------------------------------------
--      if time >= 400 then --1000000 then  -- 1x10^6 us = 1s
--         timer_rst            <= '1';
--         internal_cmd_start   <= '1';      
--      else
         timer_rst            <= '0';
         internal_cmd_start   <= '0';      
--      end if;
   ---------------------------------------------------------------------  
   -- end of comments for disabling internal commands.
   ---------------------------------------------------------------------  
      end if;
   end process;
 
   -------------------------------------------------------------------------------------------
   -- timer for issuing internal commands
   ------------------------------------------------------------------------------------------- 
   timer : us_timer
   port map(
      clk           => clk_i,
      timer_reset_i => timer_rst,
      timer_count_o => time);

   -------------------------------------------------------------------------------------------
   -- RETURN DATA command state machine
   ------------------------------------------------------------------------------------------- 
   i_return_data_cmd : cmd_translator_ret_dat_fsm
   port map(
      -- global inputs
      rst_i                  => rst_i,
      clk_i                  => clk_i,

      -- inputs from fibre_rx      
      card_addr_i            => card_id_i,                   -- specifies which card the command is targetting
      parameter_id_i         => param_id_i,                  -- comes from param_id_i, indicates which device(s) the command is targetting
      data_i                 => cmd_data_i,                  -- data will be passed straight thru in 16-bit words
      data_clk_i             => data_clk_i,                  -- for clocking out the data
      
      -- ret_dat_wbs interface
      start_seq_num_i        => start_seq_num_i,
      stop_seq_num_i         => stop_seq_num_i, 
      data_rate_i            => data_rate_i,
      dv_mode_i              => dv_mode_i,        
      external_dv_i          => external_dv_i,    
      external_dv_num_i      => external_dv_num_i,
      ret_dat_req_i          => dat_req,
      ret_dat_ack_o          => dat_ack,

      -- other inputs
      sync_pulse_i           => sync_pulse_i,
      sync_number_i          => sync_number_i,               -- a counter of synch pulses 
      ret_dat_start_i        => ret_dat_start,
      ret_dat_stop_i         => ret_dat_stop,
      ret_dat_cmd_valid_o    => ret_dat_cmd_valid,
 
      -- outputs to arbiter
      card_addr_o            => ret_dat_cmd_card_addr,       -- specifies which card the command is targetting
      parameter_id_o         => ret_dat_cmd_parameter_id,    -- comes from param_id_i, indicates which device(s) the command is targetting
      data_size_o            => ret_dat_cmd_data_size,       -- num_data_i, indicates number of 16-bit words of data
      data_o                 => ret_dat_cmd_data,            -- data will be passed straight thru in 16-bit words
      data_clk_o             => ret_dat_cmd_data_clk,        -- for clocking out the data
      instr_rdy_o            => ret_dat_cmd_instr_rdy,       -- ='1' when the data is valid, else it's '0'
      ret_dat_fsm_working_o  => ret_dat_fsm_working,    
      cmd_type_o             => ret_dat_cmd_type,            -- this is a re-mapping of the cmd_code into a 3-bit number
      cmd_stop_o             => ret_dat_cmd_stop,                    
      last_frame_o           => ret_dat_last_frame,
      frame_seq_num_o        => ret_dat_frame_seq_num,
      frame_sync_num_o       => ret_dat_frame_sync_num,    
      
      -- input from the arbiter
      ack_i                  => arbiter_ret_dat_ack,         -- acknowledgment from the micro-instr arbiter that it is ready and has grabbed the data
      ack_o                  => ret_dat_ack
   ); 

   -------------------------------------------------------------------------------------------
   -- SIMPLE commands state machine
   ------------------------------------------------------------------------------------------- 
   i_simple_cmds : cmd_translator_simple_cmd_fsm
   port map(
     -- global inputs
      rst_i                  => rst_i,
      clk_i                  => clk_i,

      -- inputs from cmd_translator top level      
      card_addr_i            => card_id_i,                   -- specifies which card the command is targetting
      parameter_id_i         => param_id_i,                  -- comes from param_id_i, indicates which device(s) the command is targetting
      data_size_i            => num_data_i,                  -- data_size_i, indicates number of 16-bit words of data
      data_i                 => cmd_data_i,                  -- data will be passed straight thru in 16-bit words
      data_clk_i             => data_clk_i,                  -- for clocking out the data
      cmd_code_i             => cmd_code_i,
      
      -- other inputs
      sync_pulse_i           => sync_pulse_i,
      cmd_start_i            => cmd_start,
      cmd_stop_i             => cmd_stop,                    -- what's this for???
  
      -- outputs to the macro-instruction arbiter
      card_addr_o            => simple_cmd_card_addr,        -- specifies which card the command is targetting
      parameter_id_o         => simple_cmd_parameter_id,     -- comes from param_id_i, indicates which device(s) the command is targetting
      data_size_o            => simple_cmd_data_size,        -- data_size_i, indicates number of 16-bit words of data
      data_o                 => simple_cmd_data,             -- data will be passed straight thru in 16-bit words
      data_clk_o             => simple_cmd_data_clk,         -- for clocking out the data
      instr_rdy_o            => simple_cmd_instr_rdy,        -- ='1' when the data is valid, else it's '0'
      cmd_type_o             => simple_cmd_type,
      
      -- input from the macro-instruction arbiter
      instr_ack_i            => simple_cmd_ack               -- acknowledgment from the macro-instr arbiter that it is ready and has grabbed the data
   );  
 
   -------------------------------------------------------------------------------------------
   -- INTERNAL commands state machine
   ------------------------------------------------------------------------------------------- 
   i_internal_cmd : cmd_translator_internal_cmd_fsm
   port map(
     -- global inputs
      rst_i                  => rst_i,
      clk_i                  => clk_i,

      -- inputs from cmd_translator top level
      internal_cmd_start_i   => internal_cmd_start,

      -- outputs to the macro-instruction arbiter
      card_addr_o            => internal_cmd_card_addr,
      parameter_id_o         => internal_cmd_parameter_id, 
      data_size_o            => internal_cmd_data_size,
      data_o                 => internal_cmd_data,
      data_clk_o             => internal_cmd_data_clk,
      instr_rdy_o            => internal_cmd_instr_rdy,
      cmd_type_o             => internal_cmd_type,
      
      -- input from the macro-instruction arbiter
      ack_i                  => internal_cmd_ack
   ); 

   -------------------------------------------------------------------------------------------
   -- arbiter
   ------------------------------------------------------------------------------------------- 
   i_arbiter : cmd_translator_arbiter
   port map(
     -- global inputs
      rst_i                          => rst_i,
      clk_i                          => clk_i,
      sync_number_i                  => sync_number_i,

      -- inputs from the 'return data' state machine
      ret_dat_frame_seq_num_i        => ret_dat_frame_seq_num,
      ret_dat_frame_sync_num_i       => ret_dat_frame_sync_num,
      ret_dat_card_addr_i            => ret_dat_cmd_card_addr,      -- specifies which card the command is targetting
      ret_dat_parameter_id_i         => ret_dat_cmd_parameter_id,   -- comes from param_id_i, indicates which device(s) the command is targett_ig
      ret_dat_data_size_i            => ret_dat_cmd_data_size,      -- num_data_i, indicates number of 16-bit words of data
      ret_dat_data_i                 => ret_dat_cmd_data ,          -- data will be passed straight thru in 16-bit words
      ret_dat_data_clk_i             => ret_dat_cmd_data_clk ,      -- for clocking out the data
      ret_dat_instr_rdy_i            => ret_dat_cmd_instr_rdy,      -- ='1' when the data is valid, else it's '0'
      ret_dat_fsm_working_i          => ret_dat_fsm_working, 
      ret_dat_cmd_type_i             => ret_dat_cmd_type,
      ret_dat_cmd_stop_i             => ret_dat_cmd_stop,                    
      ret_dat_last_frame_i           => ret_dat_last_frame,
      
      -- output to the 'return data' state machine
      ret_dat_ack_o                  => arbiter_ret_dat_ack ,       -- acknowledgment from the macro-instr arbiter that it is ready and has grabbed the data

      -- inputs from the 'simple commands' state machine
      simple_cmd_card_addr_i         => simple_cmd_card_addr,       -- specifies which card the command is targetting
      simple_cmd_parameter_id_i      => simple_cmd_parameter_id,    -- comes from param_id_i, indicates which device(s) the command is targetting
      simple_cmd_data_size_i         => simple_cmd_data_size,       -- data_size_i, indicates number of 16-bit words of data
      simple_cmd_data_i              => simple_cmd_data,            -- data will be passed straight thru in 16-bit words
      simple_cmd_data_clk_i          => simple_cmd_data_clk,        -- for clocking out the data
      simple_cmd_instr_rdy_i         => simple_cmd_instr_rdy,       -- ='1' when the data is valid, else it's '0'
      simple_cmd_type_i              => simple_cmd_type, 
      
      -- output to simple cmd fsm
      simple_cmd_ack_o               => simple_cmd_ack, 
      
      -- inputs from the internal commands state machine
      internal_cmd_card_addr_i       => internal_cmd_card_addr,
      internal_cmd_parameter_id_i    => internal_cmd_parameter_id,
      internal_cmd_data_size_i       => internal_cmd_data_size,
      internal_cmd_data_i            => internal_cmd_data,
      internal_cmd_data_clk_i        => internal_cmd_data_clk,
      internal_cmd_instr_rdy_i       => internal_cmd_instr_rdy,
      internal_cmd_type_i            => internal_cmd_type,
      
      -- output to the internal command state machine
      internal_cmd_ack_o             => internal_cmd_ack,
 
      -- outputs to the cmd_queue 
      frame_seq_num_o                => frame_seq_num,
      frame_sync_num_o               => frame_sync_num,
      card_addr_o                    => card_addr,                  -- specifies which card the command is targetting
      parameter_id_o                 => parameter_id,               -- comes from param_id_i, indicates which device(s) the command is targetting
      data_size_o                    => data_size,                  -- num_data_i, indicates number of 16-bit words of data
      data_o                         => data,                       -- data will be passed straight thru in 16-bit words
      data_clk_o                     => data_clk,                   -- for clocking out the data
      instr_rdy_o                    => instr_rdy,                  -- ='1' when the data is valid, else it's '0'
      cmd_type_o                     => cmd_type,
      cmd_stop_o                     => cmd_stop_cmd_queue,                    
      last_frame_o                   => last_frame,
      internal_cmd_o                 => internal_cmd,

      -- input from the cmd_queue
      ack_i                          => ack_i                       -- acknowledgment from the cmd_queue that it is ready and has grabbed the data
   ); 

   -------------------------------------------------------------------------------------------
   -- register arbiter outputs
   ------------------------------------------------------------------------------------------- 
   process(clk_i, rst_i)
   begin
      if rst_i = '1' then
         card_addr_reg               <= (others => '0');
         parameter_id_reg            <= (others => '0');
         data_size_reg               <= (others => '0');
         data_reg                    <= (others => '0');
         data_clk_reg                <= '0';
         instr_rdy_reg               <= '0';
         cmd_type_reg                <= (others => '0');
         cmd_stop_reg                <= '0';
         last_frame_reg              <= '0';
         internal_cmd_reg            <= '0'; 
         frame_seq_num_reg           <= (others => '0');   
         frame_sync_num_reg          <= (others => '0');   
      elsif clk_i'event and clk_i = '1' then
         card_addr_reg               <= card_addr;
         parameter_id_reg            <= parameter_id;
         data_size_reg               <= data_size;
         data_reg                    <= data;
         data_clk_reg                <= data_clk;
         instr_rdy_reg               <= instr_rdy;
         cmd_type_reg                <= cmd_type;
         cmd_stop_reg                <= cmd_stop_cmd_queue;
         last_frame_reg              <= last_frame;
         internal_cmd_reg            <= internal_cmd;
         frame_seq_num_reg           <= frame_seq_num;
         frame_sync_num_reg          <= frame_sync_num;
      end if;
    end process;

   -------------------------------------------------------------------------------------------
   -- assign outputs
   ------------------------------------------------------------------------------------------- 
         
   -- outputs to the reply_translator
   reply_cmd_rcvd_er_o               <= cksum_err_i;
   reply_cmd_code_o                  <= cmd_code_i;
   reply_param_id_o                  <= param_id_i;
   reply_card_id_o                   <= card_id_i;   
 
   -- acknowledge signal back to fibre_rx indicating receipt of command
   ack_o                             <= ret_dat_ack or simple_cmd_ack;

   -- outputs to cmd_queue
   card_addr_o                       <= card_addr_reg;      
   parameter_id_o                    <= parameter_id_reg;   
   data_size_o                       <= data_size_reg;      
   data_o                            <= data_reg;           
   data_clk_o                        <= data_clk_reg;      
   instr_rdy_o                       <= instr_rdy_reg;
   cmd_type_o                        <= cmd_type_reg;   
   cmd_stop_o                        <= cmd_stop_reg;
   last_frame_o                      <= last_frame_reg;
   internal_cmd_o                    <= internal_cmd_reg;
   frame_seq_num_o                   <= frame_seq_num_reg;
   frame_sync_num_o                  <= frame_sync_num_reg;

end rtl; 