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
-- <revision control keyword substitutions e.g. $Id: cmd_translator_ret_dat_fsm.vhd,v 1.41 2006/10/19 22:02:43 bburger Exp $>
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
-- <date $Date: 2006/10/19 22:02:43 $> -     <text>      - <initials $Author: bburger $>
--
-- $Log: cmd_translator_ret_dat_fsm.vhd,v $
-- Revision 1.41  2006/10/19 22:02:43  bburger
-- Bryce:  Re-wrote to simplify and support stop ret_dat commands
--
-- Revision 1.40  2006/09/21 16:13:48  bburger
-- Bryce:
-- - cleaned up the fsm,
-- - implemented a sliding sync register so that the fsm recovers nicely if delayed by an internal command at the start of data taking
-- - added an 'internal_cmd_window' interface to allow the arbiter to choose judiciously between ret_dat and internal commands
--
-- 
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library sys_param;
use sys_param.wishbone_pack.all;
use sys_param.command_pack.all;

library components;
use components.component_pack.all;

library work;
use work.sync_gen_pack.all;
use work.frame_timing_pack.all;
use work.issue_reply_pack.all;

entity cmd_translator_ret_dat_fsm is
port(
      -- global inputs
      rst_i                   : in  std_logic;
      clk_i                   : in  std_logic;

      -- inputs from fibre_rx      
      card_addr_i             : in  std_logic_vector (FIBRE_CARD_ADDRESS_WIDTH-1 downto 0);  -- specifies which card the command is targetting
      parameter_id_i          : in  std_logic_vector (FIBRE_PARAMETER_ID_WIDTH-1 downto 0);  -- comes from reg_addr_i, indicates which device(s) the command is targetting
      data_i                  : in  std_logic_vector (       PACKET_WORD_WIDTH-1 downto 0);  -- data will be passed straight thru in 16-bit words
      data_clk_i              : in  std_logic;                                               -- for clocking out the data
      
      -- ret_dat_wbs interface:
      start_seq_num_i         : in  std_logic_vector(        PACKET_WORD_WIDTH-1 downto 0);
      stop_seq_num_i          : in  std_logic_vector(        PACKET_WORD_WIDTH-1 downto 0);
      data_rate_i             : in  std_logic_vector(           SYNC_NUM_WIDTH-1 downto 0);
      
      dv_mode_i               : in std_logic_vector(DV_SELECT_WIDTH-1 downto 0);
      external_dv_i           : in std_logic;
      external_dv_num_i       : in std_logic_vector(DV_NUM_WIDTH-1 downto 0);

      -- other inputs
      sync_number_i           : in  std_logic_vector (          SYNC_NUM_WIDTH-1 downto 0);  -- a counter of synch pulses 
      internal_cmd_window_o   : out integer;
      cmd_code_i              : in  std_logic_vector( FIBRE_PACKET_TYPE_WIDTH-1 downto 0);
      cmd_rdy_i               : in  std_logic;                                            
      row_len_i               : in integer;
      num_rows_i              : in integer;

      frame_seq_num_o         : out std_logic_vector (                        31 downto 0);
      frame_sync_num_o        : out std_logic_vector (          SYNC_NUM_WIDTH-1 downto 0);
      
      -- outputs to the arbiter
      card_addr_o             : out std_logic_vector (BB_CARD_ADDRESS_WIDTH-1 downto 0);  -- specifies which card the command is targetting
      parameter_id_o          : out std_logic_vector (BB_PARAMETER_ID_WIDTH-1 downto 0);  -- comes from reg_addr_i, indicates which device(s) the command is targetting
      data_size_o             : out std_logic_vector (   BB_DATA_SIZE_WIDTH-1 downto 0);  -- num_data_i, indicates number of 16-bit words of data
      data_o                  : out std_logic_vector (    PACKET_WORD_WIDTH-1 downto 0);  -- data will be passed straight thru in 16-bit words
      data_clk_o              : out std_logic;                                               -- for clocking out the data
      instr_rdy_o             : out std_logic;                                               -- ='1' when the data is valid, else it's '0'
      cmd_code_o              : out std_logic_vector ( FIBRE_PACKET_TYPE_WIDTH-1 downto 0);
      cmd_stop_o              : out std_logic;                      
      last_frame_o            : out std_logic;
      ret_dat_fsm_working_o   : out std_logic;                                               -- indicates the state machine is busy
      
      -- input from the arbiter
      ack_i                   : in  std_logic;                                               -- acknowledgment from the micro-instr arbiter that it is ready and has grabbed the data

      -- output to the cmd_translator top level
      ack_o                   : out std_logic                                                -- acknowledge signal going back to the fibre_rx block
   ); 
     
end cmd_translator_ret_dat_fsm;


architecture rtl of cmd_translator_ret_dat_fsm is

   -------------------------------------------------------------------------------------------
   -- type definitions
   ------------------------------------------------------------------------------------------- 
   type state is (IDLE, UPDATE_FOR_NEXT, FIRST, ONE_MORE);
   signal next_state                      : state;
   signal current_state                   : state;
                                           
   -------------------------------------------------------------------------------------------
   -- signals
   ------------------------------------------------------------------------------------------- 
   signal ret_dat_req                     : std_logic;
   signal ret_dat_ack                     : std_logic;
   signal ret_dat_fsm_working             : std_logic;  

   signal card_addr_reg                   : std_logic_vector (BB_CARD_ADDRESS_WIDTH-1 downto 0); 
   signal parameter_id_reg                : std_logic_vector (BB_PARAMETER_ID_WIDTH-1 downto 0);
   signal data_reg                        : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
 
   signal sync_num                        : std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);
   signal seq_num                         : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal load_sync_num                   : std_logic;
   signal next_sync_num                   : std_logic;
   signal load_seq_num                    : std_logic;
   signal next_seq_num                    : std_logic;
   
   signal data_size                       : std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);  -- num_data_i, indicates number of 16-bit words of data
   signal data_size_int                   : integer;
   
   signal prod_rl_nm                      : integer;
   signal diff_csn_sn                     : integer;
   signal window                          : integer;

   -------------------------------------------------------------------------------------------
   -- constants
   ------------------------------------------------------------------------------------------- 
   -- signals for generating the sync and sequence numbers
   constant INPUT_NUM_SEL             : std_logic := '1';
   constant CURRENT_NUM_PLUS_1_SEL    : std_logic := '0';

begin

   -------------------------------------------------------------------------------------------
   -- sequencer for state machines
   ------------------------------------------------------------------------------------------- 
   process(rst_i, clk_i)
   begin
      if rst_i = '1' then
         current_state      <= IDLE;
      elsif clk_i'event and clk_i = '1' then
         current_state      <= next_state;
      end if;
   end process;
   
   -------------------------------------------------------------------------------------------
   -- State machine for issuing ret_dat macro-ops.
   -- Next State logic
   ------------------------------------------------------------------------------------------- 
   process(current_state, ret_dat_req, seq_num, stop_seq_num_i, ack_i, dv_mode_i, external_dv_i)
   begin
      next_state <= current_state;
   
      case current_state is
         when IDLE =>
            if(ret_dat_req = '1') then
               next_state <= FIRST;
            end if;
            
         when FIRST =>             
            if(ack_i = '1' and seq_num /= stop_seq_num_i) then
               next_state <= UPDATE_FOR_NEXT;
            elsif(ack_i = '1' and seq_num = stop_seq_num_i) then
               next_state <= IDLE;
            end if;

         when UPDATE_FOR_NEXT =>
            -- We stay in this state for one cycle if we're in internal-dv mode, otherwise we wait for the next dv-pulse.
            if(dv_mode_i = DV_INTERNAL) then
               next_state <= ONE_MORE;
            elsif(dv_mode_i /= DV_INTERNAL and external_dv_i = '1') then
               next_state <= ONE_MORE;
            end if;         
         
         when ONE_MORE =>
            if(ack_i = '1' and seq_num /= stop_seq_num_i) then
               next_state <= UPDATE_FOR_NEXT;
            elsif(ack_i = '1' and seq_num = stop_seq_num_i) then
               next_state <= IDLE;
            end if;
         
         when others =>
            next_state <= IDLE;
      end case;
   end process;

   -------------------------------------------------------------------------------------------
   -- State machine for issuing ret_dat macro-ops.
   -- Assign values
   ------------------------------------------------------------------------------------------- 
   process(current_state, ret_dat_req, stop_seq_num_i, seq_num, ack_i, dv_mode_i, external_dv_i)
   begin
      -- default assignments
      load_sync_num       <= '0';
      next_sync_num       <= '0';
      load_seq_num        <= '0';
      next_seq_num        <= '0';

      instr_rdy_o         <= '0'; 
      ret_dat_ack         <= '0';
      ret_dat_fsm_working <= '1';
      
      last_frame_o        <= '0';
      cmd_stop_o          <= '0';
      
      case current_state is
         when IDLE =>
            ret_dat_fsm_working <= '0';
            
            if(ret_dat_req = '1') then
               ret_dat_fsm_working <= '1';
               load_sync_num <= '1';
               load_seq_num <= '1';
            end if;

         when FIRST =>
            -- Slide the sync number until the arbiter takes the first data command.
            -- This is to correct for internal commands that are clogging up the cmd_queue, and causing delays
            load_sync_num <= '1';
            instr_rdy_o   <= '1';
            
            if(seq_num = stop_seq_num_i) then
               last_frame_o <= '1';
               if(ack_i = '1') then
                  -- Ack the data run.
                  ret_dat_ack <= '1';
                  -- De-assert instr_rdy_o immediately to prevent cmd_queue from re-latching it
                  instr_rdy_o <= '0';
               end if;
            end if;
            
            if(ret_dat_req = '0') then
               cmd_stop_o <= '1';
            end if;               

         when UPDATE_FOR_NEXT =>
            if(dv_mode_i = DV_INTERNAL) then
               next_sync_num <= '1';
               next_seq_num  <= '1';
            elsif(dv_mode_i /= DV_INTERNAL and external_dv_i = '1') then
               -- Since the timing of the DV pulse dictates the next data packet,
               -- we issue a ret_dat on the frame period following a sync pulse.
               load_sync_num <= '1';
               next_seq_num  <= '1';
            end if;         

         when ONE_MORE =>
            -- The only difference between FIRST and ONE_MORE is the assertion of load_sync_num in FIRST
            instr_rdy_o   <= '1';
            
            if(seq_num = stop_seq_num_i) then
               last_frame_o <= '1';
               if(ack_i = '1') then
                  -- Ack the data run.
                  ret_dat_ack <= '1';
                  -- De-assert instr_rdy_o immediately to prevent cmd_queue from re-latching it
                  instr_rdy_o <= '0';
               end if;
            end if;
            
            if(ret_dat_req = '0') then
               cmd_stop_o <= '1';
            end if;               
 
         when others =>            
      end case;
   end process;

   -------------------------------------------------------------------------------------------
   -- registers
   ------------------------------------------------------------------------------------------- 
   -- cmd_stop_o only get latched by cmd_queue when it receives a ret_dat command
   -- if ret_dat_req will only be low when the cmd_queue receives a ret_dat command if a ST was received
--   cmd_stop_o <= not ret_dat_req;
   
   process(rst_i, clk_i)
   begin
      if rst_i = '1' then
         data_reg         <= (others=>'0');
         parameter_id_reg <= (others=>'0');
         card_addr_reg    <= (others=>'0');
         sync_num         <= (others=>'0');
         seq_num          <= (others=>'0');
         prod_rl_nm       <= 0;
         diff_csn_sn      <= 0;
         window           <= 0;
         ret_dat_req      <= '0';
         ack_o            <= '0';

      elsif(clk_i'event and clk_i='1') then
         prod_rl_nm              <= row_len_i * num_rows_i;
         if(sync_num = sync_number_i + 1 or current_state = IDLE) then 
            diff_csn_sn          <= 0;
         else
            diff_csn_sn          <= conv_integer(sync_num - sync_number_i) - 1;
         end if;
         window                  <= prod_rl_nm * diff_csn_sn;

         -- Latch important command information
         if(cmd_rdy_i = '1') then  
            parameter_id_reg     <= parameter_id_i(BB_PARAMETER_ID_WIDTH-1 downto 0);
            card_addr_reg        <= card_addr_i(BB_CARD_ADDRESS_WIDTH-1 downto 0);
            data_reg             <= data_i;
         end if;
         
         -- Track GO/ST ret_dat commands
         if(cmd_rdy_i = '1' and parameter_id_i(BB_PARAMETER_ID_WIDTH-1 downto 0) = RET_DAT_ADDR) then
            -- Acknowledge the GO/ST command from fibre_rx, to clear it for a new command.
            ack_o <= '1';
            if(cmd_code_i = GO) then
               ret_dat_req <= '1';
            else
               -- Assume it's a stop command            
               ret_dat_req <= '0';
            end if;
         elsif(ret_dat_ack = '1') then
            -- Data run is done
            ret_dat_req <= '0';
         end if;

         -- Manage sync number
         if(load_sync_num = '1') then
            -- issue ret_dat on the following frame period
            sync_num <= sync_number_i + 1;
         elsif(next_sync_num = '1') then
            sync_num <= sync_num + data_rate_i;
         end if;
         
         -- Manage sequence number
         if(load_seq_num = '1') then
            -- issue ret_dat on the following frame period
            seq_num <= start_seq_num_i;
         elsif(next_seq_num = '1') then
            seq_num <= seq_num + 1;
         end if;
         
      end if;
   end process;
    
   -------------------------------------------------------------------------------------------
   -- assign outputs
   -------------------------------------------------------------------------------------------
   ret_dat_fsm_working_o  <= ret_dat_fsm_working;

   data_size_int          <= NO_CHANNELS * num_rows_i;
   data_size              <= conv_std_logic_vector(data_size_int,11);

   process(ret_dat_fsm_working, seq_num, sync_num, card_addr_reg, parameter_id_reg, data_reg, data_size, window)
   begin
      if(ret_dat_fsm_working = '1') then
         frame_seq_num_o       <= seq_num;
         frame_sync_num_o      <= sync_num;
         card_addr_o           <= card_addr_reg;
         parameter_id_o        <= parameter_id_reg;
         data_size_o           <= data_size;    
         data_o                <= data_reg;         
         cmd_code_o            <= READ_BLOCK;
         data_clk_o            <= '0';  
         internal_cmd_window_o <= window;         
      else
         frame_seq_num_o       <= (others => '0');
         frame_sync_num_o      <= (others => '0');
         card_addr_o           <= (others => '0');
         parameter_id_o        <= (others => '0');
         data_size_o           <= (others => '0');
         data_o                <= (others => '0');
         cmd_code_o            <= (others => '0');
         data_clk_o            <= '0';
         internal_cmd_window_o <= MIN_WINDOW + 1;
      end if;       
   end process;

    
end rtl;