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
-- <revision control keyword substitutions e.g. $Id: cmd_translator_ret_dat_fsm.vhd,v 1.28 2006/03/16 00:20:21 bburger Exp $>
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
-- <date $Date: 2006/03/16 00:20:21 $> -     <text>      - <initials $Author: bburger $>
--
-- $Log: cmd_translator_ret_dat_fsm.vhd,v $
-- Revision 1.28  2006/03/16 00:20:21  bburger
-- Bryce:
-- - added support for dv pulses
-- - removed recirculation muxes
--
-- Revision 1.27  2006/03/11 03:45:11  bburger
-- Bryce:  polishing off dv_rx functionality -- fixing bugs
--
-- Revision 1.26  2006/03/09 00:58:41  bburger
-- Bryce:
-- - Added the following signals to the interface:  dv_mode_i, external_dv_i, external_dv_num_i
-- - Implemented logic for this block to be responsive to external dv pulses
--
-- Revision 1.25  2006/02/11 01:19:33  bburger
-- Bryce:  Added the following signal interfaces to implement responding to external dv pulses
-- data_req
-- data_ack
-- frame_num_external
--
-- Revision 1.24  2006/02/02 00:30:52  mandana
-- unused signal data_size_reg removed
--
-- Revision 1.23  2006/01/16 18:45:27  bburger
-- Ernie:  removed references to issue_reply_pack and cmd_translator_pack
-- moved component declarations from above package files to cmd_translator
-- renamed constants to work with new command_pack (new bus backplane constants)
--
-- Revision 1.22  2005/09/28 23:35:22  bburger
-- Bryce:
-- removed ret_dat_s logic and interface signals, which are not used.
-- added a hardcoded data size in cmd_translator_ret_dat_fsm of 328 for data frames
--
-- Revision 1.21  2005/09/03 23:51:26  bburger
-- jjacob:
-- removed recirculation muxes and replaced with register enables, and cleaned up formatting
--
-- Revision 1.20  2005/03/19 00:31:23  bburger
-- bryce:  Fixed several bugs.  Tagging cc_01010007.
--
-- Revision 1.19  2005/03/12 02:19:00  bburger
-- bryce:  bug fixes
--
-- Revision 1.18  2005/03/04 03:45:58  bburger
-- Bryce:  fixed bugs associated with ret_dat_s and ret_dat
--
-- Revision 1.17  2004/11/14 22:33:29  bburger
-- Jonathan : modified cmd_type_o to output the "STOP" command code on the last frame of data when a "STOP" command is received.
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
      ret_dat_req_i           : in std_logic;
      ret_dat_ack_o           : out std_logic;

      -- other inputs
      sync_pulse_i            : in  std_logic;
      sync_number_i           : in  std_logic_vector (          SYNC_NUM_WIDTH-1 downto 0);  -- a counter of synch pulses 
      ret_dat_start_i         : in  std_logic;
      ret_dat_stop_i          : in  std_logic;
      ret_dat_cmd_valid_o     : out std_logic;
      frame_seq_num_o         : out std_logic_vector (                        31 downto 0);
      frame_sync_num_o        : out std_logic_vector (          SYNC_NUM_WIDTH-1 downto 0);
      
      -- outputs to the arbiter
      card_addr_o             : out std_logic_vector (BB_CARD_ADDRESS_WIDTH-1 downto 0);  -- specifies which card the command is targetting
      parameter_id_o          : out std_logic_vector (BB_PARAMETER_ID_WIDTH-1 downto 0);  -- comes from reg_addr_i, indicates which device(s) the command is targetting
      data_size_o             : out std_logic_vector (   BB_DATA_SIZE_WIDTH-1 downto 0);  -- num_data_i, indicates number of 16-bit words of data
      data_o                  : out std_logic_vector (    PACKET_WORD_WIDTH-1 downto 0);  -- data will be passed straight thru in 16-bit words
      data_clk_o              : out std_logic;                                               -- for clocking out the data
      instr_rdy_o             : out std_logic;                                               -- ='1' when the data is valid, else it's '0'
      cmd_type_o              : out std_logic_vector (BB_COMMAND_TYPE_WIDTH-1 downto 0);  -- this is a re-mapping of the cmd_code into a 3-bit number
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
   type sync_state is                     (IDLE, SET_SEQ_NUM_1, SET_SEQ_NUM_2, RETURN_DATA_WAIT);
   type state      is                     (RETURN_DATA_IDLE, RETURN_DATA_1ST, RETURN_DATA_PAUSE, RETURN_DATA_DV_PAUSE, RETURN_DATA, RETURN_DATA_LAST_PAUSE, RETURN_DATA_LAST,
                                           RETURN_DATA_SINGLE_FRAME, RETURN_DATA_SINGLE_FRAME_PAUSE1, RETURN_DATA_SINGLE_FRAME_PAUSE2);
                                           
   -------------------------------------------------------------------------------------------
   -- signals
   ------------------------------------------------------------------------------------------- 
   signal ret_dat_start                   : std_logic; 
   signal ret_dat_done                    : std_logic; 
   signal ret_dat_fsm_working             : std_logic;  
   signal ret_dat_cmd_valid               : std_logic;  
   signal ret_dat_stop_ack                : std_logic;
   signal ret_dat_start_ack               : std_logic;
   signal ret_dat_stop_reg                : std_logic;
   signal ret_dat_stop_reg_en             : std_logic;
   signal ret_dat_stop_reg_rst            : std_logic; 

   signal input_reg_en                    : std_logic;  
   signal card_addr_reg                   : std_logic_vector (BB_CARD_ADDRESS_WIDTH-1 downto 0); 
   signal parameter_id_reg                : std_logic_vector (BB_PARAMETER_ID_WIDTH-1 downto 0);
   signal data_reg                        : std_logic_vector (    PACKET_WORD_WIDTH-1 downto 0);
 
   signal sync_next_state                 : sync_state;
   signal sync_current_state              : sync_state;

   signal next_state                      : state;
   signal current_state                   : state;
 
--   signal mux_sel                         : std_logic;
   signal reg_en                          : std_logic;
   
   signal current_sync_num_reg_plus_1     : std_logic_vector(           SYNC_NUM_WIDTH-1 downto 0);
   signal current_sync_num_reg            : std_logic_vector(           SYNC_NUM_WIDTH-1 downto 0);
   signal current_sync_num                : std_logic_vector(           SYNC_NUM_WIDTH-1 downto 0);
  
   signal current_seq_num_reg_plus_1      : std_logic_vector(                         31 downto 0);
   signal current_seq_num_reg             : std_logic_vector(                         31 downto 0);
   signal current_seq_num                 : std_logic_vector(                         31 downto 0);
   

   -------------------------------------------------------------------------------------------
   -- constants
   ------------------------------------------------------------------------------------------- 
   -- signals for generating the sync and sequence numbers
   constant INPUT_NUM_SEL             : std_logic := '1';
   constant CURRENT_NUM_PLUS_1_SEL    : std_logic := '0';
   constant RET_DAT_NUM_WORDS         : std_logic_vector(FIBRE_DATA_SIZE_WIDTH-1 downto 0) := x"00000148";  -- 328 words

begin

   -------------------------------------------------------------------------------------------
   -- sequencer for state machines
   ------------------------------------------------------------------------------------------- 
   process(rst_i, clk_i)
   begin
      if rst_i = '1' then
         sync_current_state <= IDLE;
         current_state      <= RETURN_DATA_IDLE;
      elsif clk_i'event and clk_i = '1' then
         sync_current_state <= sync_next_state;
         current_state      <= next_state;
      end if;
   end process;
   
   -------------------------------------------------------------------------------------------
   -- State machine for issuing ret_dat macro-ops.
   -- Next State logic
   ------------------------------------------------------------------------------------------- 
   process(current_state, ret_dat_start, ret_dat_start_i, ret_dat_stop_i, current_seq_num, 
      start_seq_num_i, stop_seq_num_i, ack_i, dv_mode_i, external_dv_i, ret_dat_req_i)
   begin
     next_state                     <= current_state;
     ret_dat_stop_reg_en            <= '0';
     ret_dat_stop_reg_rst           <= '0';
   
      case current_state is

         when RETURN_DATA_IDLE =>
            if(ret_dat_start = '1') and (start_seq_num_i /= stop_seq_num_i) then
               if(dv_mode_i /= DV_INTERNAL and ret_dat_req_i = '0') then
                  next_state        <= RETURN_DATA_IDLE;
               else
                  next_state        <= RETURN_DATA_1ST;
               end if;
            elsif(ret_dat_start = '1') and (start_seq_num_i = stop_seq_num_i) then
               if(dv_mode_i /= DV_INTERNAL and ret_dat_req_i = '0') then
                  next_state        <= RETURN_DATA_IDLE;
               else
                  next_state        <= RETURN_DATA_SINGLE_FRAME;
               end if;
            else
               next_state           <= RETURN_DATA_IDLE;
            end if;

            ret_dat_stop_reg_rst    <= '1'; -- reset value

         when RETURN_DATA_SINGLE_FRAME =>
            next_state              <= RETURN_DATA_SINGLE_FRAME_PAUSE1;
            
         when RETURN_DATA_SINGLE_FRAME_PAUSE1 =>
            if ack_i = '1' then
               next_state           <= RETURN_DATA_SINGLE_FRAME_PAUSE2;
            else
               next_state           <= RETURN_DATA_SINGLE_FRAME_PAUSE1;
            end if;

         when RETURN_DATA_SINGLE_FRAME_PAUSE2 =>
            if ret_dat_start_i = '0' then
               next_state           <= RETURN_DATA_IDLE;
            else
               next_state           <= RETURN_DATA_SINGLE_FRAME_PAUSE2;
            end if;
         
         when RETURN_DATA_1ST =>
            if ack_i = '1' and ret_dat_stop_i = '0' and dv_mode_i = DV_INTERNAL then
               next_state           <= RETURN_DATA_PAUSE;
            elsif ack_i = '1' and ret_dat_stop_i = '0' and dv_mode_i /= DV_INTERNAL then
               next_state           <= RETURN_DATA_DV_PAUSE;
            elsif ack_i = '1' and ret_dat_stop_i = '1' and dv_mode_i = DV_INTERNAL then
               next_state           <= RETURN_DATA_LAST_PAUSE;
               ret_dat_stop_reg_en    <= '1'; -- grab ret_dat_stop_i;
            elsif ack_i = '1' and ret_dat_stop_i = '1' and dv_mode_i /= DV_INTERNAL then
               next_state           <= RETURN_DATA_DV_PAUSE;
               ret_dat_stop_reg_en    <= '1'; -- grab ret_dat_stop_i;
            else
               next_state           <= RETURN_DATA_1ST;
            end if;

         when RETURN_DATA =>
            if ack_i = '1' and ret_dat_stop_i = '0' and dv_mode_i = DV_INTERNAL then
               next_state           <= RETURN_DATA_PAUSE;
            elsif ack_i = '1' and ret_dat_stop_i = '0' and dv_mode_i /= DV_INTERNAL then
               next_state           <= RETURN_DATA_DV_PAUSE;
            elsif ack_i = '1' and ret_dat_stop_i = '1' and dv_mode_i = DV_INTERNAL then
               next_state           <= RETURN_DATA_LAST_PAUSE;
               ret_dat_stop_reg_en  <= '1'; -- grab ret_dat_stop_i;
            elsif ack_i = '1' and ret_dat_stop_i = '1' and dv_mode_i /= DV_INTERNAL then
               next_state           <= RETURN_DATA_DV_PAUSE;
               ret_dat_stop_reg_en  <= '1'; -- grab ret_dat_stop_i;
            else
               next_state           <= RETURN_DATA;
            end if;

         when RETURN_DATA_LAST_PAUSE =>
            next_state              <= RETURN_DATA_LAST;

         when RETURN_DATA_DV_PAUSE =>
            if ret_dat_stop_i = '1' then
               ret_dat_stop_reg_en  <= '1'; -- grab ret_dat_stop_i;
               next_state           <= RETURN_DATA_LAST;
            elsif(external_dv_i = '1') then
               if(current_seq_num >= stop_seq_num_i) then
                  next_state        <= RETURN_DATA_LAST;
               else
                  next_state        <= RETURN_DATA;
               end if;
            end if;
         
         when RETURN_DATA_PAUSE =>
            if ret_dat_stop_i = '1' then
               ret_dat_stop_reg_en  <= '1'; -- grab ret_dat_stop_i;
               next_state           <= RETURN_DATA_LAST;
            elsif (current_seq_num >= stop_seq_num_i) then
               next_state           <= RETURN_DATA_LAST;
            
            else
               next_state           <= RETURN_DATA;
            end if;

         when RETURN_DATA_LAST =>
            if ack_i = '1' then
               next_state           <= RETURN_DATA_IDLE;
            else
               next_state           <= RETURN_DATA_LAST;
            end if;     

         when others =>
            next_state              <= RETURN_DATA_IDLE;
            
      end case;
   end process;

   -------------------------------------------------------------------------------------------
   -- State machine for issuing ret_dat macro-ops.
   -- Assign values
   ------------------------------------------------------------------------------------------- 
   process(current_state, ack_i, ret_dat_start, ret_dat_start_i, ret_dat_stop_reg, external_dv_i, 
      sync_number_i, start_seq_num_i, current_seq_num_reg, current_sync_num_reg, data_rate_i)
   begin
      -- default assignments
      ret_dat_cmd_valid                <= '0';
      instr_rdy_o                      <= '0'; 
      ret_dat_done                     <= '0';
      ret_dat_fsm_working              <= '0';
      input_reg_en                     <= '0';
      ret_dat_start_ack                <= '0';
      last_frame_o                     <= '0';
      cmd_stop_o                       <= '0';
      
      current_sync_num                 <= (others => '0');
      current_seq_num                  <= (others => '0');
      reg_en                           <= '0';
      
      ret_dat_ack_o                    <= '0';
      
      case current_state is
         when RETURN_DATA_IDLE =>
         
            if(ret_dat_start = '1') then
--               ret_dat_cmd_valid       <= '1';
--               instr_rdy_o             <= '1';
               ret_dat_fsm_working     <= '1';
               ret_dat_start_ack       <= '1';
               reg_en                  <= '1';           
               current_sync_num        <= sync_number_i + 1;
               current_seq_num         <= start_seq_num_i;
            else
               input_reg_en            <= '1';
            end if;

         when RETURN_DATA_SINGLE_FRAME =>
            ret_dat_cmd_valid          <= '1';
            instr_rdy_o                <= '1';
            ret_dat_fsm_working        <= '1';
            last_frame_o               <= '1';

         when RETURN_DATA_SINGLE_FRAME_PAUSE1 =>
            ret_dat_cmd_valid          <= '1';
            instr_rdy_o                <= '1';
            ret_dat_fsm_working        <= '1';
            last_frame_o               <= '1';

         when RETURN_DATA_SINGLE_FRAME_PAUSE2 =>
            if ret_dat_start_i = '0' then
               ret_dat_cmd_valid       <= '1';
               ret_dat_done            <= '1';
               ret_dat_fsm_working     <= '1';               
            else
               ret_dat_cmd_valid       <= '1';
               ret_dat_fsm_working     <= '1';
            end if;
            ret_dat_ack_o              <= '1';

         when RETURN_DATA_1ST =>
            ret_dat_cmd_valid          <= '1';
            instr_rdy_o                <= '1';
            ret_dat_fsm_working        <= '1';
            
         when RETURN_DATA =>
            ret_dat_cmd_valid          <= '1';
            instr_rdy_o                <= '1';
            ret_dat_fsm_working        <= '1';  

         when RETURN_DATA_DV_PAUSE =>
            ret_dat_fsm_working        <= '1';
            if(external_dv_i = '1') then
               reg_en                  <= '1';
               current_sync_num        <= sync_number_i + 1;
               current_seq_num         <= current_seq_num_reg + 1;
            end if;
         
         when RETURN_DATA_PAUSE =>
            ret_dat_fsm_working        <= '1';
            reg_en                     <= '1';
            current_sync_num           <= current_sync_num_reg + data_rate_i;
            current_seq_num            <= current_seq_num_reg + 1;
            
         when RETURN_DATA_LAST_PAUSE =>
            ret_dat_fsm_working        <= '1';
            reg_en                     <= '1';
            current_sync_num           <= current_sync_num_reg + data_rate_i;
            current_seq_num            <= current_seq_num_reg + 1;
            
         when RETURN_DATA_LAST =>
            
            if ack_i = '1' then
               ret_dat_cmd_valid       <= '1';
               instr_rdy_o             <= '1';
               ret_dat_done            <= '1';
               ret_dat_fsm_working     <= '1';               
            else
               ret_dat_cmd_valid       <= '1';
               instr_rdy_o             <= '1';
               ret_dat_fsm_working     <= '1';
            end if;

            if(ret_dat_stop_reg  = '1') then
               cmd_stop_o              <= '1';
            end if;            
             
            last_frame_o               <= '1';
            ret_dat_ack_o              <= '1';
 
         when others =>            
            
      end case;
   end process;

   -------------------------------------------------------------------------------------------
   -- registers
   ------------------------------------------------------------------------------------------- 
   process(rst_i, clk_i)
   begin
      if rst_i = '1' then
         current_sync_num_reg    <= (others=>'0');
         current_seq_num_reg     <= (others=>'0');
         data_reg                <= (others=>'0');
         parameter_id_reg        <= (others=>'0');
         card_addr_reg           <= (others=>'0');
      elsif clk_i'event and clk_i='1' then
         if reg_en = '1' then
            current_sync_num_reg    <= current_sync_num;
            current_seq_num_reg     <= current_seq_num;
         end if;
         
         if input_reg_en = '1' then  
            parameter_id_reg     <= parameter_id_i(BB_PARAMETER_ID_WIDTH-1 downto 0);
            card_addr_reg        <= card_addr_i(BB_CARD_ADDRESS_WIDTH-1 downto 0);
            data_reg             <= data_i;
         end if;
      end if;
   end process;
   
   -------------------------------------------------------------------------------------------
   -- return data STOP signal
   ------------------------------------------------------------------------------------------- 
   process(clk_i, rst_i)
   begin
      if rst_i = '1' then
         ret_dat_stop_reg <= '0';
      elsif clk_i'event and clk_i='1' then
         if ret_dat_stop_reg_en = '1' then
            ret_dat_stop_reg <= ret_dat_stop_i;
         elsif ret_dat_stop_reg_rst = '1' then
            ret_dat_stop_reg <= '0';
          end if;
      end if;
   end process;   
   
   -------------------------------------------------------------------------------------------
   -- state machine for grabbing ret_dat_s data
   ------------------------------------------------------------------------------------------- 
   process(sync_current_state, ret_dat_start_i, ret_dat_done, external_dv_i, dv_mode_i, ret_dat_req_i)
   begin
      ret_dat_start                        <= '0';
      case sync_current_state is
         when IDLE =>
            if((dv_mode_i = DV_INTERNAL) and (ret_dat_start_i = '1')) then
               ret_dat_start               <= '1';  
               sync_next_state             <= RETURN_DATA_WAIT;
            elsif(dv_mode_i /= DV_INTERNAL and ret_dat_req_i = '1' and external_dv_i = '1') then
               ret_dat_start               <= '1';  
               sync_next_state             <= RETURN_DATA_WAIT;
            elsif(ret_dat_done = '1') then
               ret_dat_start               <= '0';       
               sync_next_state             <= IDLE;
            else
               sync_next_state             <= IDLE;
            end if;

         when RETURN_DATA_WAIT =>
            if(ret_dat_done = '1') then
               sync_next_state             <= IDLE;
            else
               sync_next_state             <= RETURN_DATA_WAIT;
               ret_dat_start               <= '1';
            end if;

         when others =>
            sync_next_state                <= IDLE;
    
      end case;  
   end process;

   -------------------------------------------------------------------------------------------
   -- START and STOP acknowledgments
   -------------------------------------------------------------------------------------------       
   ret_dat_stop_ack            <= '1' when current_state = RETURN_DATA_LAST and ret_dat_stop_i = '1' else '0';
   
   -------------------------------------------------------------------------------------------
   -- assign outputs
   -------------------------------------------------------------------------------------------
   ack_o                   <= ret_dat_stop_ack or ret_dat_start_ack;
   ret_dat_cmd_valid_o     <= ret_dat_cmd_valid;
   ret_dat_fsm_working_o   <= ret_dat_fsm_working;

   process(ret_dat_fsm_working, current_seq_num_reg, current_sync_num_reg, card_addr_reg, parameter_id_reg, data_reg, dv_mode_i)
   begin
      if ret_dat_fsm_working = '1' then
         frame_seq_num_o  <= current_seq_num_reg;
         frame_sync_num_o <= current_sync_num_reg;

         if(dv_mode_i = DV_INTERNAL) then
            card_addr_o      <= card_addr_reg;
            parameter_id_o   <= parameter_id_reg;
         else
            -- These statements override the values of the previous command, so that DV pulses cause this FSM to fetch data frames
            card_addr_o      <= ALL_READOUT_CARDS;
            parameter_id_o   <= RET_DAT_ADDR;
         end if;
         
         data_size_o      <= "00101001000";    
         data_o           <= data_reg;         
         --this will always indicate data, whether or not a stop command was received, or it is the last frame
         cmd_type_o       <= READ_CMD;         
         -- not passing any data, so keep the data clock inactive
         data_clk_o       <= '0';              
         
      else
         frame_seq_num_o  <= (others => '0');
         frame_sync_num_o <= (others => '0');
         card_addr_o      <= (others => '0');
         parameter_id_o   <= (others => '0');
         data_size_o      <= (others => '0');
         data_o           <= (others => '0');
         cmd_type_o       <= (others => '0');  -- equivalent to a WB command, although we don't actually do WB cmds in this block
         data_clk_o       <= '0';
         
      end if;       
   end process;

    
end rtl;