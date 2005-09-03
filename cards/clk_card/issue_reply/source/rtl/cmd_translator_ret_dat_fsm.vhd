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
-- <revision control keyword substitutions e.g. $Id: cmd_translator_ret_dat_fsm.vhd,v 1.20 2005/03/19 00:31:23 bburger Exp $>
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
-- <date $Date: 2005/03/19 00:31:23 $> -     <text>      - <initials $Author: bburger $>
--
-- $Log: cmd_translator_ret_dat_fsm.vhd,v $
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
      data_size_i             : in  std_logic_vector (   FIBRE_DATA_SIZE_WIDTH-1 downto 0);  -- data_size_i, indicates number of 16-bit words of data
      data_i                  : in  std_logic_vector (       PACKET_WORD_WIDTH-1 downto 0);  -- data will be passed straight thru in 16-bit words
      data_clk_i              : in  std_logic;                                               -- for clocking out the data
      cmd_code_i              : in  std_logic_vector (                        15 downto 0);
      
      -- ret_dat_wbs interface:
      start_seq_num_i         : in  std_logic_vector(            WB_DATA_WIDTH-1 downto 0);
      stop_seq_num_i          : in  std_logic_vector(            WB_DATA_WIDTH-1 downto 0);
      data_rate_i             : in  std_logic_vector(           SYNC_NUM_WIDTH-1 downto 0);

      -- other inputs
      sync_pulse_i            : in  std_logic;
      sync_number_i           : in  std_logic_vector (          SYNC_NUM_WIDTH-1 downto 0);  -- a counter of synch pulses 
      ret_dat_start_i         : in  std_logic;
      ret_dat_stop_i          : in  std_logic;
      ret_dat_cmd_valid_o     : out std_logic;
      ret_dat_s_start_i       : in  std_logic;
      frame_seq_num_o         : out std_logic_vector (                        31 downto 0);
      frame_sync_num_o        : out std_logic_vector (          SYNC_NUM_WIDTH-1 downto 0);
      
      -- outputs to the arbiter
      card_addr_o             : out std_logic_vector (FIBRE_CARD_ADDRESS_WIDTH-1 downto 0);  -- specifies which card the command is targetting
      parameter_id_o          : out std_logic_vector (FIBRE_PARAMETER_ID_WIDTH-1 downto 0);  -- comes from reg_addr_i, indicates which device(s) the command is targetting
      data_size_o             : out std_logic_vector (   FIBRE_DATA_SIZE_WIDTH-1 downto 0);  -- num_data_i, indicates number of 16-bit words of data
      data_o                  : out std_logic_vector (       PACKET_WORD_WIDTH-1 downto 0);  -- data will be passed straight thru in 16-bit words
      data_clk_o              : out std_logic;                                               -- for clocking out the data
      macro_instr_rdy_o       : out std_logic;                                               -- ='1' when the data is valid, else it's '0'
      cmd_type_o              : out std_logic_vector (   BB_COMMAND_TYPE_WIDTH-1 downto 0);  -- this is a re-mapping of the cmd_code into a 3-bit number
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
   type state      is                     (RETURN_DATA_IDLE, RETURN_DATA_1ST, RETURN_DATA_PAUSE, RETURN_DATA, RETURN_DATA_LAST_PAUSE, RETURN_DATA_LAST,
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

   signal cmd_type                        : std_logic_vector (   BB_COMMAND_TYPE_WIDTH-1 downto 0);       -- this is a re-mapping of the cmd_code into a 3-bit number
   signal cmd_stop                        : std_logic;      
   
   signal input_reg_en                    : std_logic;  
   signal card_addr_reg                   : std_logic_vector (FIBRE_CARD_ADDRESS_WIDTH-1 downto 0); 
   signal parameter_id_reg                : std_logic_vector (FIBRE_PARAMETER_ID_WIDTH-1 downto 0);
   signal data_size_reg                   : std_logic_vector (   FIBRE_DATA_SIZE_WIDTH-1 downto 0);
   signal data_reg                        : std_logic_vector (       PACKET_WORD_WIDTH-1 downto 0);
 
   signal sync_next_state                 : sync_state;
   signal sync_current_state              : sync_state;

   signal next_state                      : state;
   signal current_state                   : state;
 
   signal mux_sel                         : std_logic;
   signal reg_en                          : std_logic;
   
   signal current_sync_num_reg_plus_1     : std_logic_vector(           SYNC_NUM_WIDTH-1 downto 0);
   signal current_sync_num_reg            : std_logic_vector(           SYNC_NUM_WIDTH-1 downto 0);
   signal current_sync_num                : std_logic_vector(           SYNC_NUM_WIDTH-1 downto 0);
  
   signal current_seq_num_reg_plus_1      : std_logic_vector(                         31 downto 0);
   signal current_seq_num_reg             : std_logic_vector(                         31 downto 0);
   signal current_seq_num                 : std_logic_vector(                         31 downto 0);
   
   signal ack_mux                         : std_logic;

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
   process(current_state, ret_dat_start, ret_dat_start_i, ret_dat_stop_i, current_seq_num, start_seq_num_i, stop_seq_num_i, ack_i)
   begin
     next_state                     <= current_state;
     ret_dat_stop_reg_en            <= '0';
     ret_dat_stop_reg_rst           <= '0';
   
      case current_state is

         when RETURN_DATA_IDLE =>
            if(ret_dat_start = '1') and (start_seq_num_i /= stop_seq_num_i) then
               next_state           <= RETURN_DATA_1ST;
            elsif(ret_dat_start = '1') and (start_seq_num_i = stop_seq_num_i) then
               next_state           <= RETURN_DATA_SINGLE_FRAME;
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
            if ack_i = '1' and ret_dat_stop_i = '0' then
               next_state           <= RETURN_DATA_PAUSE;
            elsif ack_i = '1' and ret_dat_stop_i = '1' then
               next_state           <= RETURN_DATA_LAST_PAUSE;
               ret_dat_stop_reg_en    <= '1'; -- grab ret_dat_stop_i;
            else
               next_state           <= RETURN_DATA_1ST;
            end if;

         when RETURN_DATA =>
            if ack_i = '1' and ret_dat_stop_i = '0' then
               next_state           <= RETURN_DATA_PAUSE;
            elsif ack_i = '1' and ret_dat_stop_i = '1' then
               next_state           <= RETURN_DATA_LAST_PAUSE;
               ret_dat_stop_reg_en  <= '1'; -- grab ret_dat_stop_i;
            else
               next_state           <= RETURN_DATA;
            end if;

         when RETURN_DATA_LAST_PAUSE =>
            next_state              <= RETURN_DATA_LAST;

         when RETURN_DATA_PAUSE =>
            if ret_dat_stop_i = '1' then
               ret_dat_stop_reg_en  <= '1'; -- grab ret_dat_stop_i;
               next_state           <= RETURN_DATA_LAST;
            elsif current_seq_num >= stop_seq_num_i then   
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
   process(current_state, ack_i, ret_dat_start, ret_dat_start_i)
   begin
      -- default assignments
      ack_mux                          <= '0';
      ret_dat_cmd_valid                <= '0';
      macro_instr_rdy_o                <= '0'; 
      ret_dat_done                     <= '0';
      ret_dat_fsm_working              <= '0';
      input_reg_en                     <= '0';
      
      case current_state is
         when RETURN_DATA_IDLE =>
         
            if ret_dat_start = '1' then
               ret_dat_cmd_valid       <= '1';
               macro_instr_rdy_o       <= '1';
               ret_dat_fsm_working     <= '1';
            else
               input_reg_en            <= '1';
            end if;

         when RETURN_DATA_SINGLE_FRAME =>
            ret_dat_cmd_valid          <= '1';
            macro_instr_rdy_o          <= '1';
            ret_dat_fsm_working        <= '1';

         when RETURN_DATA_SINGLE_FRAME_PAUSE1 =>
            ret_dat_cmd_valid          <= '1';
            macro_instr_rdy_o          <= '1';
            ret_dat_fsm_working        <= '1';
            ack_mux                    <= '1';

         when RETURN_DATA_SINGLE_FRAME_PAUSE2 =>
            if ret_dat_start_i = '0' then
               ret_dat_cmd_valid       <= '1';
               ret_dat_done            <= '1';
               ret_dat_fsm_working     <= '1';               
            else
               ret_dat_cmd_valid       <= '1';
               ret_dat_fsm_working     <= '1';
            end if;

         when RETURN_DATA_1ST =>
            ret_dat_cmd_valid          <= '1';
            macro_instr_rdy_o          <= '1';
            ret_dat_fsm_working        <= '1';
            ack_mux                    <= '1';
            
         when RETURN_DATA =>
            ret_dat_cmd_valid          <= '1';
            macro_instr_rdy_o          <= '1';
            ret_dat_fsm_working        <= '1';  

         when RETURN_DATA_PAUSE =>
            ret_dat_fsm_working        <= '1';
            
         when RETURN_DATA_LAST_PAUSE =>
            ret_dat_fsm_working        <= '1';
            
         when RETURN_DATA_LAST =>
            if ack_i = '1' then
               ret_dat_cmd_valid       <= '1';
               macro_instr_rdy_o       <= '1';
               ret_dat_done            <= '1';
               ret_dat_fsm_working     <= '1';               
            else
               ret_dat_cmd_valid       <= '1';
               macro_instr_rdy_o       <= '1';
               ret_dat_fsm_working     <= '1';
            end if;
            
      end case;
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
   
   -- If a STOP command is issued during data frame taking, the last frame of data will be tagged
   -- with a STOP cmd_code, rather than a DATA cmd_code for the cmd_queue
   cmd_type <= STOP when cmd_stop = '1' else DATA;
   
   -------------------------------------------------------------------------------------------
   -- state machine for grabbing ret_dat_s data
   ------------------------------------------------------------------------------------------- 
   process(sync_current_state, ret_dat_start_i, ret_dat_done)
   begin
      ret_dat_start                        <= '0';
      case sync_current_state is
         when IDLE =>
            if ret_dat_start_i = '1' then
               ret_dat_start               <= '1';  
               sync_next_state             <= RETURN_DATA_WAIT;
            elsif ret_dat_done = '1' then
               ret_dat_start               <= '0';       
               sync_next_state             <= IDLE;
            else
               sync_next_state             <= IDLE;
            end if;

         when RETURN_DATA_WAIT =>
            if ret_dat_done = '1' then
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
   -- registers
   ------------------------------------------------------------------------------------------- 
   process(rst_i, clk_i)
   begin
      if rst_i = '1' then
         current_sync_num_reg    <= (others=>'0');
         current_seq_num_reg     <= (others=>'0');
         data_reg                <= (others=>'0');
         data_size_reg           <= (others=>'0');
         parameter_id_reg        <= (others=>'0');
         card_addr_reg           <= (others=>'0');
      elsif clk_i'event and clk_i='1' then
         if reg_en = '1' then
            current_sync_num_reg    <= current_sync_num;
            current_seq_num_reg     <= current_seq_num;
         end if;
         
         if input_reg_en = '1' then  
            parameter_id_reg     <= parameter_id_i;
            card_addr_reg        <= card_addr_i;
            data_reg             <= data_i;
            data_size_reg        <= data_size_i;
         end if;
      end if;
   end process;

   -------------------------------------------------------------------------------------------
   -- select line and register enable generation for 'sync number' and 'sequence number' mux 
   ------------------------------------------------------------------------------------------- 
   process(current_state, ret_dat_start)
   begin
      --default assignments
      reg_en           <= '0';
      mux_sel          <= CURRENT_NUM_PLUS_1_SEL;
      
      case current_state is 
         when RETURN_DATA_IDLE =>         
            if ret_dat_start = '1' then
               mux_sel          <= INPUT_NUM_SEL;
               reg_en           <= '1';           
            end if;

         when RETURN_DATA_PAUSE | RETURN_DATA_LAST_PAUSE =>        
            mux_sel             <= CURRENT_NUM_PLUS_1_SEL;
            reg_en              <= '1';
  
         when others =>            
            mux_sel             <= CURRENT_NUM_PLUS_1_SEL;
            reg_en              <= '0';    

      end case;
   end process;

   -------------------------------------------------------------------------------------------
   -- 'sync number' and 'sequence number' muxes
   -------------------------------------------------------------------------------------------    
   current_sync_num            <= sync_number_i + 1           when mux_sel = INPUT_NUM_SEL          else -- the first ret_dat command
                                  current_sync_num_reg_plus_1;                                           -- the next increment of the sync number

   current_sync_num_reg_plus_1 <= current_sync_num_reg + data_rate_i; -- this is the sync pulse increment value for issuing ret_dat commands on consecutive
                                                                      -- frames of data.  Ex: if you want every 1000 frames, change to "+ 1000"

   current_seq_num             <= start_seq_num_i             when mux_sel = INPUT_NUM_SEL          else
                                  current_seq_num_reg_plus_1;

   current_seq_num_reg_plus_1  <= current_seq_num_reg + 1;

   -------------------------------------------------------------------------------------------
   -- START and STOP acknowledgments
   -------------------------------------------------------------------------------------------       
   ret_dat_stop_ack            <= '1' when current_state = RETURN_DATA_LAST and ret_dat_stop_i = '1' else '0';
   ret_dat_start_ack           <= ack_i when ack_mux = '1' else '0';  -- this is to acknowledge back to the fibre_rx that cmd_queue has grabbed the ret_dat command
                                                                     -- for the first ret_dat, but after that, the fibre_rx doesn't need to know about the 'ack'
                                                                     -- only the cmd_translator needs to know so it can issue the ret_dat for the next frame of data.
   cmd_stop                    <= '1' when current_state = RETURN_DATA_LAST and ret_dat_stop_reg  = '1' else '0';
   
   -------------------------------------------------------------------------------------------
   -- assign outputs
   -------------------------------------------------------------------------------------------
   ack_o                   <= ret_dat_stop_ack or ret_dat_start_ack;
   cmd_stop_o              <= cmd_stop;
   ret_dat_cmd_valid_o     <= ret_dat_cmd_valid;
   ret_dat_fsm_working_o   <= ret_dat_fsm_working;

   last_frame_o            <= '1' when (current_state = RETURN_DATA_LAST and (ret_dat_stop_reg = '1' or current_seq_num >= stop_seq_num_i)) 
                                    or (current_state = RETURN_DATA_SINGLE_FRAME or current_state = RETURN_DATA_SINGLE_FRAME_PAUSE1) else '0';

   process(ret_dat_s_start_i, ret_dat_fsm_working, card_addr_i, parameter_id_i, data_size_i, data_i,
           current_seq_num, current_sync_num, card_addr_reg, parameter_id_reg, data_size_reg, data_reg, cmd_type)
   begin
      if ret_dat_s_start_i = '1' then
         frame_seq_num_o  <= (others => '0');
         frame_sync_num_o <= (others => '0');
         card_addr_o      <= card_addr_i;
         parameter_id_o   <= parameter_id_i;
         data_size_o      <= data_size_i;
         data_o           <= data_i;
         cmd_type_o       <= (others => '0');  -- the cmd_queue doesn't need to know about the ret_dat_s command
         data_clk_o       <= '0';              -- no need to pass the data_clk through
         
      elsif ret_dat_fsm_working = '1' then
         frame_seq_num_o  <= current_seq_num_reg;
         frame_sync_num_o <= current_sync_num_reg;
         card_addr_o      <= card_addr_reg;    --card_addr;
         parameter_id_o   <= parameter_id_reg; --parameter_id;
         data_size_o      <= data_size_reg;    --data_size;
         data_o           <= data_reg;         --data_mux;
         cmd_type_o       <= cmd_type;
         data_clk_o       <= '0';              -- not passing any data, so keep the data clock inactive
         
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