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
-- <revision control keyword substitutions e.g. $Id: cmd_translator.vhd,v 1.44 2006/09/15 00:36:11 bburger Exp $>
--
-- Project:       SCUBA-2
-- Author:        Jonathan Jacob
--
-- Organisation:  UBC
--
-- Description:  This module is the fibre command translator. 
-- 
-- 
--
-- Revision history:
-- 
-- <date $Date: 2006/09/15 00:36:11 $> -     <text>      - <initials $Author: bburger $>
--
-- $Log: cmd_translator.vhd,v $
-- Revision 1.44  2006/09/15 00:36:11  bburger
-- Bryce:  Added internal_cmd_window between ret_dat_fsm and arbiter_fsm
--
-- Revision 1.43  2006/09/07 22:25:22  bburger
-- Bryce:  replace cmd_type (1-bit: read/write) interfaces and funtionality with cmd_code (32-bit: read_block/ write_block/ start/ stop/ reset) interface because reply_queue_sequencer needed to know to discard replies to reset commands
--
-- Revision 1.42  2006/08/02 16:24:41  bburger
-- Bryce:  trying to fixed occasional wb bugs in issue_reply
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
use work.frame_timing_pack.all;

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
   ret_dat_req_i         : in std_logic;
   ret_dat_ack_o         : out std_logic;

   dv_mode_i             : in std_logic_vector(DV_SELECT_WIDTH-1 downto 0);
   external_dv_i         : in std_logic;
   external_dv_num_i     : in std_logic_vector(DV_NUM_WIDTH-1 downto 0);

   -- ret_dat_wbs interface
   tes_bias_toggle_en_i   : in std_logic;
   tes_bias_high_i        : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   tes_bias_low_i         : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   tes_bias_toggle_rate_i : in std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);
   status_cmd_en_i        : in std_logic;

   -- other inputs 
   sync_pulse_i          : in  std_logic;
   sync_number_i         : in  std_logic_vector(          SYNC_NUM_WIDTH-1 downto 0);
   
   -- signals from the arbiter to cmd_queue
   cmd_code_o            : out std_logic_vector(FIBRE_PACKET_TYPE_WIDTH-1 downto 0);        -- this is a re-mapping of the cmd_code into a 3-bit number
   card_addr_o           : out std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0);        -- specifies which card the command is targetting
   parameter_id_o        : out std_logic_vector(BB_PARAMETER_ID_WIDTH-1 downto 0);        -- comes from param_id_i, indicates which device(s) the command is targetting
   data_size_o           : out std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);        -- num_data_i, indicates number of 16-bit words of data
   data_o                : out std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);        -- data will be passed straight thru
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
   frame_seq_num_o       : out std_logic_vector(       PACKET_WORD_WIDTH-1 downto 0);
   frame_sync_num_o      : out std_logic_vector(          SYNC_NUM_WIDTH-1 downto 0);

   -- outputs to reply_translator for commands that require quick acknowldgements
   reply_cmd_rcvd_er_o   : out std_logic;
   reply_cmd_rcvd_ok_o   : out std_logic;
   reply_cmd_code_o      : out std_logic_vector(FIBRE_PACKET_TYPE_WIDTH-1 downto 0);
   reply_param_id_o      : out std_logic_vector(FIBRE_PARAMETER_ID_WIDTH-1 downto 0);        -- the parameter ID
   reply_card_id_o       : out std_logic_vector(FIBRE_CARD_ADDRESS_WIDTH-1 downto 0));         -- specifies which card the command is targetting          
end cmd_translator;


architecture rtl of cmd_translator is

   -------------------------------------------------------------------------------------------
   -- 'return data' (ret_dat) state machine signals
   -------------------------------------------------------------------------------------------
   signal ret_dat_start                : std_logic;
   signal ret_dat_stop                 : std_logic;
   signal arbiter_ret_dat_ack          : std_logic;
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
   port(
      rst_i                   : in  std_logic;
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
      sync_number_i           : in  std_logic_vector (          SYNC_NUM_WIDTH-1 downto 0);
      internal_cmd_window_o   : out integer;
      ret_dat_start_i         : in  std_logic;
      ret_dat_stop_i          : in  std_logic;
      row_len_i               : in integer;
      num_rows_i              : in integer;
      ret_dat_cmd_valid_o     : out std_logic;
      frame_seq_num_o         : out std_logic_vector (                        31 downto 0);
      frame_sync_num_o        : out std_logic_vector (          SYNC_NUM_WIDTH-1 downto 0);
      card_addr_o             : out std_logic_vector (BB_CARD_ADDRESS_WIDTH-1 downto 0);
      parameter_id_o          : out std_logic_vector (BB_PARAMETER_ID_WIDTH-1 downto 0);
      data_size_o             : out std_logic_vector (   BB_DATA_SIZE_WIDTH-1 downto 0);
      data_o                  : out std_logic_vector (    PACKET_WORD_WIDTH-1 downto 0);
      data_clk_o              : out std_logic;
      instr_rdy_o             : out std_logic;
      cmd_code_o              : out std_logic_vector ( FIBRE_PACKET_TYPE_WIDTH-1 downto 0);
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
   signal ret_dat_cmd_code             : std_logic_vector ( FIBRE_PACKET_TYPE_WIDTH-1 downto 0);
   signal ret_dat_fsm_working          : std_logic;
   signal ret_dat_frame_seq_num        : std_logic_vector (    PACKET_WORD_WIDTH-1 downto 0);
   signal ret_dat_frame_sync_num       : std_logic_vector (       SYNC_NUM_WIDTH-1 downto 0);
   signal ret_dat_internal_cmd_window  : integer;    

   -------------------------------------------------------------------------------------------
   -- 'simple command' signals to the arbiter
   -------------------------------------------------------------------------------------------
   signal simple_cmd_ack               : std_logic;                                               -- ready signal

   -------------------------------------------------------------------------------------------
   -- 'internal command' signals to the arbiter
   -------------------------------------------------------------------------------------------
   
   component cmd_translator_internal_cmd_fsm
   port(
      rst_i                  : in  std_logic;
      clk_i                  : in  std_logic;

      sync_number_i          : in  std_logic_vector (          SYNC_NUM_WIDTH-1 downto 0);

      -- ret_dat_wbs interface
      tes_bias_toggle_en_i   : in std_logic;
      tes_bias_high_i        : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      tes_bias_low_i         : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      tes_bias_toggle_rate_i : in std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);
      status_cmd_en_i        : in std_logic;

      card_addr_o            : out std_logic_vector (BB_CARD_ADDRESS_WIDTH-1 downto 0);
      parameter_id_o         : out std_logic_vector (BB_PARAMETER_ID_WIDTH-1 downto 0);
      data_size_o            : out std_logic_vector (   BB_DATA_SIZE_WIDTH-1 downto 0);
      data_o                 : out std_logic_vector (    PACKET_WORD_WIDTH-1 downto 0);
      data_clk_o             : out std_logic;
      instr_rdy_o            : out std_logic;
      cmd_code_o             : out std_logic_vector ( FIBRE_PACKET_TYPE_WIDTH-1 downto 0);
      tes_bias_step_level_o  : out std_logic;
      ack_i                  : in  std_logic); 
   end component;

   signal internal_cmd_card_addr       : std_logic_vector (BB_CARD_ADDRESS_WIDTH-1 downto 0);
   signal internal_cmd_parameter_id    : std_logic_vector (BB_PARAMETER_ID_WIDTH-1 downto 0);
   signal internal_cmd_data_size       : std_logic_vector (   BB_DATA_SIZE_WIDTH-1 downto 0);
   signal internal_cmd_data            : std_logic_vector (    PACKET_WORD_WIDTH-1 downto 0);  
   signal internal_cmd_data_clk        : std_logic; 
   signal internal_cmd_instr_rdy       : std_logic; 
   signal internal_cmd_code            : std_logic_vector ( FIBRE_PACKET_TYPE_WIDTH-1 downto 0);
   signal internal_cmd_ack             : std_logic;   
   
   -------------------------------------------------------------------------------------------
   -- arbiter signals
   -------------------------------------------------------------------------------------------
   component cmd_translator_arbiter
   port(
      rst_i                          : in  std_logic;
      clk_i                          : in  std_logic;
      internal_cmd_window_i          : in  integer;
      ret_dat_frame_seq_num_i        : in  std_logic_vector (                     31 downto 0);
      ret_dat_frame_sync_num_i       : in  std_logic_vector (       SYNC_NUM_WIDTH-1 downto 0);
      ret_dat_card_addr_i            : in  std_logic_vector (BB_CARD_ADDRESS_WIDTH-1 downto 0);
      ret_dat_parameter_id_i         : in  std_logic_vector (BB_PARAMETER_ID_WIDTH-1 downto 0);
      ret_dat_data_size_i            : in  std_logic_vector (   BB_DATA_SIZE_WIDTH-1 downto 0);
      ret_dat_data_i                 : in  std_logic_vector (    PACKET_WORD_WIDTH-1 downto 0);
      ret_dat_data_clk_i             : in  std_logic; 
      ret_dat_instr_rdy_i            : in  std_logic; 
      ret_dat_fsm_working_i          : in  std_logic;
      ret_dat_cmd_code_i             : in  std_logic_vector( FIBRE_PACKET_TYPE_WIDTH-1 downto 0);
      ret_dat_cmd_stop_i             : in  std_logic;
      ret_dat_last_frame_i           : in  std_logic;
      ret_dat_ack_o                  : out std_logic;
      simple_cmd_card_addr_i         : in  std_logic_vector (BB_CARD_ADDRESS_WIDTH-1 downto 0);
      simple_cmd_parameter_id_i      : in  std_logic_vector (BB_PARAMETER_ID_WIDTH-1 downto 0);
      simple_cmd_data_size_i         : in  std_logic_vector (   BB_DATA_SIZE_WIDTH-1 downto 0);
      simple_cmd_data_i              : in  std_logic_vector (    PACKET_WORD_WIDTH-1 downto 0);
      simple_cmd_data_clk_i          : in  std_logic;
      simple_cmd_instr_rdy_i         : in  std_logic;
      simple_cmd_code_i              : in  std_logic_vector( FIBRE_PACKET_TYPE_WIDTH-1 downto 0);
      simple_cmd_ack_o               : out std_logic;  
      internal_cmd_card_addr_i       : in  std_logic_vector (BB_CARD_ADDRESS_WIDTH-1 downto 0);
      internal_cmd_parameter_id_i    : in  std_logic_vector (BB_PARAMETER_ID_WIDTH-1 downto 0);
      internal_cmd_data_size_i       : in  std_logic_vector (   BB_DATA_SIZE_WIDTH-1 downto 0);
      internal_cmd_data_i            : in  std_logic_vector (    PACKET_WORD_WIDTH-1 downto 0);
      internal_cmd_data_clk_i        : in  std_logic; 
      internal_cmd_instr_rdy_i       : in  std_logic; 
      internal_cmd_code_i            : in  std_logic_vector( FIBRE_PACKET_TYPE_WIDTH-1 downto 0);
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
      cmd_code_o                     : out std_logic_vector ( FIBRE_PACKET_TYPE_WIDTH-1 downto 0);
      cmd_stop_o                     : out std_logic; 
      last_frame_o                   : out std_logic;  
      internal_cmd_o                 : out std_logic;  
      tes_bias_step_level_i          : in std_logic;
      tes_bias_step_level_o          : out std_logic;
      ack_i                          : in  std_logic);      
   end component;

   signal card_addr                    : std_logic_vector (BB_CARD_ADDRESS_WIDTH-1 downto 0);
   signal parameter_id                 : std_logic_vector (BB_PARAMETER_ID_WIDTH-1 downto 0);
   signal data_size                    : std_logic_vector (   BB_DATA_SIZE_WIDTH-1 downto 0);
   signal data                         : std_logic_vector (    PACKET_WORD_WIDTH-1 downto 0);       
   signal data_clk                     : std_logic;
   signal instr_rdy                    : std_logic;
   signal cmd_code                     : std_logic_vector ( FIBRE_PACKET_TYPE_WIDTH-1 downto 0);
   signal cmd_stop_cmd_queue           : std_logic; 
   signal last_frame                   : std_logic; 
   signal internal_cmd                 : std_logic;                                       
   signal frame_seq_num                : std_logic_vector (    PACKET_WORD_WIDTH-1 downto 0);
   signal frame_sync_num               : std_logic_vector (       SYNC_NUM_WIDTH-1 downto 0);   
   signal tes_bias_step_level          : std_logic;
   signal tes_bias_step_level2         : std_logic;
   signal tes_bias_step_level_reg      : std_logic;
   
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
   signal cmd_code_reg                 : std_logic_vector ( FIBRE_PACKET_TYPE_WIDTH-1 downto 0); 
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


   -- Get rid of this
   dat_req <= '0';
--   -- Custom register that indicates fresh ret_dat commands
--   dat_req <= data_req;
--   data_req_reg: process(clk_i, rst_i)
--   begin
--      if(rst_i = '1') then
--         data_req <= '0';
--      elsif(clk_i'event and clk_i = '1') then
--         if(ret_dat_start = '1') then
--            data_req <= '1';
--         elsif(dat_ack = '1' or ret_dat_stop = '1') then
--            data_req <= '0';
--         else
--            data_req <= data_req;
--         end if;
--      end if;
--   end process data_req_reg;

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
      --sync_pulse_i           => sync_pulse_i,
      sync_number_i          => sync_number_i,               -- a counter of synch pulses 
      internal_cmd_window_o  => ret_dat_internal_cmd_window,
      ret_dat_start_i        => ret_dat_start,
      ret_dat_stop_i         => ret_dat_stop,
      ret_dat_cmd_valid_o    => open, --ret_dat_cmd_valid,
      row_len_i              => row_len_i,
      num_rows_i             => num_rows_i,

      -- outputs to arbiter
      card_addr_o            => ret_dat_cmd_card_addr,       -- specifies which card the command is targetting
      parameter_id_o         => ret_dat_cmd_parameter_id,    -- comes from param_id_i, indicates which device(s) the command is targetting
      data_size_o            => ret_dat_cmd_data_size,       -- num_data_i, indicates number of 16-bit words of data
      data_o                 => ret_dat_cmd_data,            -- data will be passed straight thru in 16-bit words
      data_clk_o             => ret_dat_cmd_data_clk,        -- for clocking out the data
      instr_rdy_o            => ret_dat_cmd_instr_rdy,       -- ='1' when the data is valid, else it's '0'
      ret_dat_fsm_working_o  => ret_dat_fsm_working,    
      cmd_code_o             => ret_dat_cmd_code,            -- this is a re-mapping of the cmd_code into a 3-bit number
      cmd_stop_o             => ret_dat_cmd_stop,                    
      last_frame_o           => ret_dat_last_frame,
      frame_seq_num_o        => ret_dat_frame_seq_num,
      frame_sync_num_o       => ret_dat_frame_sync_num,    
      
      -- input from the arbiter
      ack_i                  => arbiter_ret_dat_ack,         -- acknowledgment from the micro-instr arbiter that it is ready and has grabbed the data
      ack_o                  => ret_dat_ack
   ); 

   -------------------------------------------------------------------------------------------
   -- INTERNAL commands state machine
   ------------------------------------------------------------------------------------------- 
   i_internal_cmd : cmd_translator_internal_cmd_fsm
   port map(
      -- global inputs
      rst_i                  => rst_i,
      clk_i                  => clk_i,

      sync_number_i          => sync_number_i,

      -- ret_dat_wbs interface
      tes_bias_toggle_en_i   => tes_bias_toggle_en_i,
      tes_bias_high_i        => tes_bias_high_i,
      tes_bias_low_i         => tes_bias_low_i,
      tes_bias_toggle_rate_i => tes_bias_toggle_rate_i,
      status_cmd_en_i        => status_cmd_en_i,

      -- outputs to the macro-instruction arbiter
      card_addr_o            => internal_cmd_card_addr,
      parameter_id_o         => internal_cmd_parameter_id, 
      data_size_o            => internal_cmd_data_size,
      data_o                 => internal_cmd_data,
      data_clk_o             => internal_cmd_data_clk,
      instr_rdy_o            => internal_cmd_instr_rdy,
      cmd_code_o             => internal_cmd_code,
      tes_bias_step_level_o  => tes_bias_step_level,
      
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

      -- i/o with the 'return data' state machine
      internal_cmd_window_i          => ret_dat_internal_cmd_window,
      ret_dat_frame_seq_num_i        => ret_dat_frame_seq_num,
      ret_dat_frame_sync_num_i       => ret_dat_frame_sync_num,
      ret_dat_card_addr_i            => ret_dat_cmd_card_addr,      -- specifies which card the command is targetting
      ret_dat_parameter_id_i         => ret_dat_cmd_parameter_id,   -- comes from param_id_i, indicates which device(s) the command is targett_ig
      ret_dat_data_size_i            => ret_dat_cmd_data_size,      -- num_data_i, indicates number of 16-bit words of data
      ret_dat_data_i                 => ret_dat_cmd_data ,          -- data will be passed straight thru in 16-bit words
      ret_dat_data_clk_i             => ret_dat_cmd_data_clk ,      -- for clocking out the data
      ret_dat_instr_rdy_i            => ret_dat_cmd_instr_rdy,      -- ='1' when the data is valid, else it's '0'
      ret_dat_fsm_working_i          => ret_dat_fsm_working, 
      ret_dat_cmd_code_i             => ret_dat_cmd_code,
      ret_dat_cmd_stop_i             => ret_dat_cmd_stop,                    
      ret_dat_last_frame_i           => ret_dat_last_frame,
      ret_dat_ack_o                  => arbiter_ret_dat_ack,       -- acknowledgment from the macro-instr arbiter that it is ready and has grabbed the data
      
      -- i/o with the fibre_rx block for simple commands
      simple_cmd_card_addr_i         => card_id_i(BB_CARD_ADDRESS_WIDTH-1 downto 0),        -- specifies which card the command is targetting
      simple_cmd_parameter_id_i      => param_id_i(BB_PARAMETER_ID_WIDTH-1 downto 0),       -- comes from param_id_i, indicates which device(s) the command is targetting
      simple_cmd_data_size_i         => num_data_i(BB_DATA_SIZE_WIDTH-1 downto 0),       -- data_size_i, indicates number of 16-bit words of data
      simple_cmd_data_i              => cmd_data_i,       -- data will be passed straight thru in 16-bit words
      simple_cmd_data_clk_i          => data_clk_i,       -- for clocking out the data
      simple_cmd_instr_rdy_i         => cmd_start,        -- ='1' when the data is valid, else it's '0'
      simple_cmd_code_i              => cmd_code_i, 
      simple_cmd_ack_o               => simple_cmd_ack, 
      
      -- i/o with the internal commands state machine
      internal_cmd_card_addr_i       => internal_cmd_card_addr,
      internal_cmd_parameter_id_i    => internal_cmd_parameter_id,
      internal_cmd_data_size_i       => internal_cmd_data_size,
      internal_cmd_data_i            => internal_cmd_data,
      internal_cmd_data_clk_i        => internal_cmd_data_clk,
      internal_cmd_instr_rdy_i       => internal_cmd_instr_rdy,
      internal_cmd_code_i            => internal_cmd_code,
      internal_cmd_ack_o             => internal_cmd_ack,
 
      -- i/o with the cmd_queue 
      frame_seq_num_o                => frame_seq_num,
      frame_sync_num_o               => frame_sync_num,
      card_addr_o                    => card_addr,                  -- specifies which card the command is targetting
      parameter_id_o                 => parameter_id,               -- comes from param_id_i, indicates which device(s) the command is targetting
      data_size_o                    => data_size,                  -- num_data_i, indicates number of 16-bit words of data
      data_o                         => data,                       -- data will be passed straight thru in 16-bit words
      data_clk_o                     => data_clk,                   -- for clocking out the data
      instr_rdy_o                    => instr_rdy,                  -- ='1' when the data is valid, else it's '0'
      cmd_code_o                     => cmd_code,
      cmd_stop_o                     => cmd_stop_cmd_queue,                    
      last_frame_o                   => last_frame,
      internal_cmd_o                 => internal_cmd,
      tes_bias_step_level_i          => tes_bias_step_level,
      tes_bias_step_level_o          => tes_bias_step_level2,
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
         cmd_code_reg                <= (others => '0');
         cmd_stop_reg                <= '0';
         last_frame_reg              <= '0';
         internal_cmd_reg            <= '0'; 
         frame_seq_num_reg           <= (others => '0');   
         frame_sync_num_reg          <= (others => '0'); 
         tes_bias_step_level_reg     <= '0';
      elsif clk_i'event and clk_i = '1' then
         card_addr_reg               <= card_addr;
         parameter_id_reg            <= parameter_id;
         data_size_reg               <= data_size;
         data_reg                    <= data;
         data_clk_reg                <= data_clk;
         instr_rdy_reg               <= instr_rdy;
         cmd_code_reg                <= cmd_code;
         cmd_stop_reg                <= cmd_stop_cmd_queue;
         last_frame_reg              <= last_frame;
         internal_cmd_reg            <= internal_cmd;
         frame_seq_num_reg           <= frame_seq_num;
         frame_sync_num_reg          <= frame_sync_num;
         tes_bias_step_level_reg     <= tes_bias_step_level2;
      end if;
    end process;

   -------------------------------------------------------------------------------------------
   -- assign outputs
   ------------------------------------------------------------------------------------------- 
   
   ret_dat_ack_o                     <= '0';
   
   -- outputs to the reply_translator
   -- this should be from the arbiter?
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
   cmd_code_o                        <= cmd_code_reg;
   cmd_stop_o                        <= cmd_stop_reg;
   last_frame_o                      <= last_frame_reg;
   internal_cmd_o                    <= internal_cmd_reg;
   frame_seq_num_o                   <= frame_seq_num_reg;
   frame_sync_num_o                  <= frame_sync_num_reg;
   tes_bias_step_level_o             <= tes_bias_step_level_reg;

end rtl; 