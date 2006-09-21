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
-- <revision control keyword substitutions e.g. $Id: cmd_translator_arbiter.vhd,v 1.28 2006/09/15 00:36:11 bburger Exp $>
--
-- Project:       SCUBA-2
-- Author:         Jonathan Jacob
--
-- Organisation:  UBC
--
-- Description:   
-- 
-- 
--
-- Revision history:
-- 
-- <date $Date: 2006/09/15 00:36:11 $> -     <text>      - <initials $Author: bburger $>
--
-- $Log: cmd_translator_arbiter.vhd,v $
-- Revision 1.28  2006/09/15 00:36:11  bburger
-- Bryce:  Added internal_cmd_window between ret_dat_fsm and arbiter_fsm
--
-- Revision 1.27  2006/09/07 22:25:22  bburger
-- Bryce:  replace cmd_type (1-bit: read/write) interfaces and funtionality with cmd_code (32-bit: read_block/ write_block/ start/ stop/ reset) interface because reply_queue_sequencer needed to know to discard replies to reset commands
--
-- Revision 1.26  2006/03/23 23:14:07  bburger
-- Bryce:  added "use work.frame_timing_pack.all;" after moving the location of some constants from sync_gen_pack
--
-- Revision 1.25  2006/01/16 18:45:27  bburger
-- Ernie:  removed references to issue_reply_pack and cmd_translator_pack
-- moved component declarations from above package files to cmd_translator
-- renamed constants to work with new command_pack (new bus backplane constants)
--
-- Revision 1.24  2005/09/28 23:35:22  bburger
-- Bryce:
-- removed ret_dat_s logic and interface signals, which are not used.
-- added a hardcoded data size in cmd_translator_ret_dat_fsm of 328 for data frames
--
-- Revision 1.23  2005/09/03 23:51:26  bburger
-- jjacob:
-- removed recirculation muxes and replaced with register enables, and cleaned up formatting
--
-- Revision 1.22  2005/03/04 03:45:58  bburger
-- Bryce:  fixed bugs associated with ret_dat_s and ret_dat
--
-- Revision 1.21  2004/12/05 21:32:22  jjacob
-- synchronized timing of internal_cmd_o signal and instr_rdy_o signal
--
-- Revision 1.19  2004/12/03 07:45:25  jjacob
-- debugging internal commands
--
-- Revision 1.18  2004/12/02 05:41:58  jjacob
-- added internal commands
--
-- Revision 1.17  2004/10/08 19:45:26  bburger
-- Bryce:  Changed SYNC_NUM_WIDTH to 16, removed TIMEOUT_SYNC_WIDTH, added a command-code to cmd_queue, added two words of book-keeping information to the cmd_queue
--
-- Revision 1.16  2004/09/30 22:34:44  erniel
-- using new command_pack constants
--
-- Revision 1.15  2004/09/13 16:44:42  jjacob
-- fixed timing on instr_rdy_o and a few other signals starting on line 425:
--    macro_instr_rdy_o <= macro_instr_rdy;  -- this outputs signal one clock cycle earlier
--    --macro_instr_rdy_o <= macro_instr_rdy_reg;  -- this outputs signal one clock cycle later
--
--    cmd_type_o        <= cmd_type;
--    --cmd_type_o        <= cmd_type_reg;
--
--    cmd_stop_o        <= cmd_stop;
--    --cmd_stop_o        <= cmd_stop_reg;
--
--    last_frame_o      <= last_frame;
--    --last_frame_o      <= last_frame_reg;
--
-- So that all signals line up properly at the output
--
-- Revision 1.14  2004/09/09 18:25:51  jjacob
-- added 3 outputs:
-- >       cmd_type_o        :  out std_logic_vector (BB_COMMAND_TYPE_WIDTH-1 downto 0);       -- this is a re-mapping of the cmd_code into a 3-bit number
-- >       cmd_stop_o        :  out std_logic;                                          -- indicates a STOP command was recieved
-- >       last_frame_o      :  out std_logic;                                          -- indicates the last frame of data for a ret_dat command
--
-- Revision 1.13  2004/09/02 18:24:28  jjacob
-- cleaning up and formatting
--
-- Revision 1.12  2004/08/24 00:00:44  jjacob
-- registered the macro_instr_rdy_o signal, and the ack_i signal to/from the
-- cmd_queue to break a combinational loop
--
-- Revision 1.11  2004/08/06 00:14:14  jjacob
-- hard coded data size to (others=>'0') for ret_dat commands.  This needs
-- to be changed at the source.
--
-- Revision 1.10  2004/08/05 20:51:33  jjacob
-- added sync_number input
--
-- Revision 1.9  2004/08/05 18:14:42  jjacob
-- changed frame_sync_num_o to use the parameter
-- SYNC_NUM_WIDTH
--
-- Revision 1.8  2004/08/03 20:00:55  jjacob
-- updating the macro_instr_rdy signal and cleaning up
--
-- Revision 1.7  2004/07/30 23:31:32  jjacob
-- safety checkin for the long weekend
--
-- Revision 1.6  2004/07/28 23:39:12  jjacob
-- added:
-- library sys_param;
-- use sys_param.command_pack.all;
--
-- Revision 1.5  2004/07/05 23:51:47  jjacob
-- added ack_o output to cmd_translator_ret_dat_fsm
--
-- Revision 1.4  2004/06/21 17:01:51  jjacob
-- first stable version, doesn't yet have macro-instruction buffer, doesn't have
-- "quick" acknolwedgements for instructions that require them, no error
-- handling, basically no return path logic yet.  Have implemented ret_dat
-- instructions, and "simple" instructions.  Not all instructions are fully
-- implemented yet.
--
-- Revision 1.2  2004/06/09 23:35:54  jjacob
-- cleaned formatting
--
-- Revision 1.1  2004/06/03 23:40:34  jjacob
-- first version
--
-- Revision 1.1  2004/05/28 15:52:27  jjacob
-- first version
--
--
-- 
-----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library sys_param;
use sys_param.command_pack.all;

library components;
use components.component_pack.all;

library work;
use work.sync_gen_pack.all;
use work.frame_timing_pack.all;
use work.issue_reply_pack.all;

entity cmd_translator_arbiter is
port(
      -- global inputs
      rst_i                          : in  std_logic;
      clk_i                          : in  std_logic;

      -- inputs from the 'return data' state machine
      internal_cmd_window_i          : in  integer;
      ret_dat_frame_seq_num_i        : in  std_logic_vector (                     31 downto 0);
      ret_dat_frame_sync_num_i       : in  std_logic_vector (       SYNC_NUM_WIDTH-1 downto 0);
      ret_dat_card_addr_i            : in  std_logic_vector (BB_CARD_ADDRESS_WIDTH-1 downto 0);  -- specifies which card the command is targetting
      ret_dat_parameter_id_i         : in  std_logic_vector (BB_PARAMETER_ID_WIDTH-1 downto 0);  -- comes from reg_addr_i, indicates which device(s) the command is targett_ig
      ret_dat_data_size_i            : in  std_logic_vector (   BB_DATA_SIZE_WIDTH-1 downto 0);  -- num_data_i, indicates number of 16-bit words of data
      ret_dat_data_i                 : in  std_logic_vector (    PACKET_WORD_WIDTH-1 downto 0);  -- data will be passed straight thru in 16-bit words
      ret_dat_data_clk_i             : in  std_logic;                                               -- for clocking out the data
      ret_dat_instr_rdy_i            : in  std_logic;                                               -- ='1' when the data is valid, else it's '0'
      ret_dat_fsm_working_i          : in  std_logic;
      ret_dat_cmd_code_i             : in  std_logic_vector( FIBRE_PACKET_TYPE_WIDTH-1 downto 0);
      ret_dat_cmd_stop_i             : in  std_logic;                                               -- indicates a STOP command was recieved
      ret_dat_last_frame_i           : in  std_logic;  
         
      -- output to the 'return data' state machine
      ret_dat_ack_o                  : out std_logic;                                               -- acknowledgment from the arbiter that it is ready and has grabbed the data

      -- inputs from the 'simple commands' state machine
      simple_cmd_card_addr_i         : in  std_logic_vector (BB_CARD_ADDRESS_WIDTH-1 downto 0);  -- specifies which card the command is targetting
      simple_cmd_parameter_id_i      : in  std_logic_vector (BB_PARAMETER_ID_WIDTH-1 downto 0);  -- comes from reg_addr_i, indicates which device(s) the command is targetting
      simple_cmd_data_size_i         : in  std_logic_vector (   BB_DATA_SIZE_WIDTH-1 downto 0);  -- data_size_i, indicates number of 16-bit words of data
      simple_cmd_data_i              : in  std_logic_vector (    PACKET_WORD_WIDTH-1 downto 0);  -- data will be passed straight thru in 16-bit words
      simple_cmd_data_clk_i          : in  std_logic;                                               -- for clocking out the data
      simple_cmd_instr_rdy_i         : in  std_logic;                                               -- ='1' when the data is valid, else it's '0'
      simple_cmd_code_i              : in  std_logic_vector( FIBRE_PACKET_TYPE_WIDTH-1 downto 0);
       
      -- output to the simple command state machine
      simple_cmd_ack_o               : out std_logic;  
       
      -- inputs from the internal commands state machine
      internal_cmd_card_addr_i       : in  std_logic_vector (BB_CARD_ADDRESS_WIDTH-1 downto 0);  -- specifies which card the command is targetting
      internal_cmd_parameter_id_i    : in  std_logic_vector (BB_PARAMETER_ID_WIDTH-1 downto 0);  -- comes from reg_addr_i, indicates which device(s) the command is targetting
      internal_cmd_data_size_i       : in  std_logic_vector (   BB_DATA_SIZE_WIDTH-1 downto 0);  -- data_size_i, indicates number of 16-bit words of data
      internal_cmd_data_i            : in  std_logic_vector (    PACKET_WORD_WIDTH-1 downto 0);  -- data will be passed straight thru in 16-bit words
      internal_cmd_data_clk_i        : in  std_logic;                                               -- for clocking in the data
      internal_cmd_instr_rdy_i       : in  std_logic;                                               -- ='1' when the data is valid, else it's '0'
      internal_cmd_code_i            : in  std_logic_vector( FIBRE_PACKET_TYPE_WIDTH-1 downto 0);
       
      -- output to the internal command state machine
      internal_cmd_ack_o             : out std_logic;  
      
      -- input for sync_number for simple commands
      sync_number_i                  : in  std_logic_vector (          SYNC_NUM_WIDTH-1 downto 0);
      
      -- outputs to the cmd_queue 
      frame_seq_num_o                : out std_logic_vector (                     31 downto 0);
      frame_sync_num_o               : out std_logic_vector (       SYNC_NUM_WIDTH-1 downto 0);
      card_addr_o                    : out std_logic_vector (BB_CARD_ADDRESS_WIDTH-1 downto 0);  -- specifies which card the command is targetting
      parameter_id_o                 : out std_logic_vector (BB_PARAMETER_ID_WIDTH-1 downto 0);  -- comes from reg_addr_i, indicates which device(s) the command is targetting
      data_size_o                    : out std_logic_vector (   BB_DATA_SIZE_WIDTH-1 downto 0);  -- num_data_i, indicates number of 16-bit words of data
      data_o                         : out std_logic_vector (    PACKET_WORD_WIDTH-1 downto 0);  -- data will be passed straight thru in 16-bit words
      data_clk_o                     : out std_logic;                                               -- for clocking out the data
      instr_rdy_o                    : out std_logic;                                               -- ='1' when the data is valid, else it's '0'
      cmd_code_o                     : out std_logic_vector ( FIBRE_PACKET_TYPE_WIDTH-1 downto 0);
      cmd_stop_o                     : out std_logic;                                               -- indicates a STOP command was recieved
      last_frame_o                   : out std_logic;  
      internal_cmd_o                 : out std_logic;  
      tes_bias_step_level_i          : in std_logic;
      tes_bias_step_level_o          : out std_logic;
       
      -- input from the cmd_queue
      ack_i                          : in std_logic                                                 -- acknowledgment from the cmd_queue that it is ready and has grabbed the data
   ); 
     
end cmd_translator_arbiter;

architecture rtl of cmd_translator_arbiter is

   -------------------------------------------------------------------------------------------
   -- type definitions
   ------------------------------------------------------------------------------------------- 
   type   state is (IDLE, INTRNL_CMD_RDY, SIMPLE_CMD_RDY, SIMPLE_CMD_PAUSE, RET_DAT_RDY, RET_DAT_PAUSE, RET_DAT_RDY_SIMPLE_CMD_PENDING, 
                    RET_DAT_RDY_SIMPLE_CMD_PENDING_WAIT, RDY_HIGH, RDY_LOW1, RDY_LOW2, RDY_LOW_WAIT);
                    
   -------------------------------------------------------------------------------------------
   -- signals
   ------------------------------------------------------------------------------------------- 
   signal instr_rdy                 : std_logic;
   signal instr_rdy_reg             : std_logic;
   signal instr_rdy_1st_stg         : std_logic;
   signal instr_rdy_mux_sel         : std_logic;
   
   signal data_mux_sel              : std_logic_vector ( 1 downto 0); --'00' routes simple cmds thru, '01' is for ret_dat cmds, "10" for internal
   signal simple_cmd_ack_mux_sel    : std_logic;
   signal ret_dat_ack_mux_sel       : std_logic;
   signal internal_cmd_ack_mux_sel  : std_logic;
   
   signal ret_dat_pending_mux       : std_logic;
   signal ret_dat_pending_mux_sel   : std_logic;
   signal ret_dat_pending_reg_en    : std_logic;
                    
   signal current_state             : state;
   signal next_state                : state;
   signal m_op_seq_num_cur_state    : state;
   signal m_op_seq_num_next_state   : state;
   
   signal ret_dat_pending           : std_logic;
   signal ack_reg                   : std_logic;
   signal sync_number_plus_1        : std_logic_vector (       SYNC_NUM_WIDTH-1 downto 0);
   
   signal cmd_code                  : std_logic_vector ( FIBRE_PACKET_TYPE_WIDTH-1 downto 0);
   signal cmd_stop                  : std_logic;
   signal last_frame                : std_logic;
   signal card_addr                 : std_logic_vector (BB_CARD_ADDRESS_WIDTH-1 downto 0); 
   signal parameter_id              : std_logic_vector (BB_PARAMETER_ID_WIDTH-1 downto 0); 
   signal data_size                 : std_logic_vector (   BB_DATA_SIZE_WIDTH-1 downto 0);
   signal data                      : std_logic_vector (    PACKET_WORD_WIDTH-1 downto 0); 
   signal data_clk                  : std_logic;
   signal frame_seq_num             : std_logic_vector (                     31 downto 0);
   signal frame_sync_num            : std_logic_vector (       SYNC_NUM_WIDTH-1 downto 0);
   signal internal_cmd              : std_logic;

   signal cmd_code_reg              : std_logic_vector ( FIBRE_PACKET_TYPE_WIDTH-1 downto 0);
   signal cmd_stop_reg              : std_logic;
   signal last_frame_reg            : std_logic;
   signal card_addr_reg             : std_logic_vector (BB_CARD_ADDRESS_WIDTH-1 downto 0); 
   signal parameter_id_reg          : std_logic_vector (BB_PARAMETER_ID_WIDTH-1 downto 0);
   signal data_size_reg             : std_logic_vector (   BB_DATA_SIZE_WIDTH-1 downto 0);
   signal data_reg                  : std_logic_vector (    PACKET_WORD_WIDTH-1 downto 0); 
   signal data_clk_reg              : std_logic;
   signal frame_seq_num_reg         : std_logic_vector (                     31 downto 0);
   signal frame_sync_num_reg        : std_logic_vector (       SYNC_NUM_WIDTH-1 downto 0);
   signal internal_cmd_reg          : std_logic;
   signal tes_bias_step_level_reg   : std_logic;
   
begin
   -------------------------------------------------------------------------------------------
   -- arbiter state machine state sequencer
   -------------------------------------------------------------------------------------------    
   process(rst_i, clk_i)
   begin
      if rst_i = '1' then
         current_state <= SIMPLE_CMD_RDY;
      elsif clk_i'event and clk_i = '1' then
         current_state <= next_state;
      end if;
   end process;

   -------------------------------------------------------------------------------------------
   -- assign next states
   -------------------------------------------------------------------------------------------    
   process(current_state, simple_cmd_instr_rdy_i, ret_dat_instr_rdy_i, internal_cmd_instr_rdy_i, internal_cmd_window_i)
   begin
      case current_state is
         when IDLE =>
            -- Priority is given to ret_dat commands
            if(simple_cmd_instr_rdy_i = '1' and internal_cmd_window_i >= MIN_WINDOW)then
               next_state <= SIMPLE_CMD_RDY;
            elsif(internal_cmd_instr_rdy_i = '1' and internal_cmd_window_i >= MIN_WINDOW) then
               next_state <= INTRNL_CMD_RDY;
            elsif(ret_dat_instr_rdy_i = '1') then
               next_state <= RET_DAT_RDY;
            else
               next_state <= IDLE;
            end if;
      
         when INTRNL_CMD_RDY =>
            if internal_cmd_instr_rdy_i = '1' then
               next_state <= INTRNL_CMD_RDY;
            else
               next_state <= IDLE;
            end if;
            
         when SIMPLE_CMD_RDY =>
            if simple_cmd_instr_rdy_i = '1' then
               next_state <= SIMPLE_CMD_RDY;
            elsif ret_dat_instr_rdy_i = '1' then
               next_state <= SIMPLE_CMD_PAUSE;
            else
               next_state <= IDLE;
            end if;
            
         when SIMPLE_CMD_PAUSE =>
            next_state    <= RET_DAT_RDY;
            
         when RET_DAT_RDY =>
            if simple_cmd_instr_rdy_i = '1' then
               next_state <= RET_DAT_RDY_SIMPLE_CMD_PENDING;
            elsif ret_dat_instr_rdy_i = '1' then
               next_state <= RET_DAT_RDY;
            else
               next_state <= IDLE;
            end if; 
            
         when RET_DAT_RDY_SIMPLE_CMD_PENDING =>
            if ret_dat_instr_rdy_i = '1' and simple_cmd_instr_rdy_i = '1' then -- wait for current ret_dat m_op to finish
               next_state <= RET_DAT_RDY_SIMPLE_CMD_PENDING;
            elsif ret_dat_instr_rdy_i = '0' and simple_cmd_instr_rdy_i = '1' then
               next_state <= RET_DAT_RDY_SIMPLE_CMD_PENDING_WAIT;
            else
               next_state <= IDLE;
            end if;
            
         when RET_DAT_RDY_SIMPLE_CMD_PENDING_WAIT =>
            next_state    <= SIMPLE_CMD_RDY;
                    
         when others => 
            next_state    <= IDLE;
         
      end case;     
   end process;

   -------------------------------------------------------------------------------------------
   -- assign state values
   -------------------------------------------------------------------------------------------      
   process(current_state, simple_cmd_instr_rdy_i, ret_dat_instr_rdy_i, ret_dat_pending,
           internal_cmd_instr_rdy_i)           
   begin
      -- defaults
      data_mux_sel               <= "00";  --"00" routes simple cmds thru, "01" is for ret_dat cmds, "10" for internal
      simple_cmd_ack_mux_sel     <= '0';
      ret_dat_ack_mux_sel        <= '0';
      internal_cmd_ack_mux_sel   <= '0';
      instr_rdy_mux_sel    <= '0'; 
      ret_dat_pending_mux_sel    <= '0';
      ret_dat_pending_reg_en     <= '0';
   
      case current_state is 
         when IDLE =>
            if internal_cmd_instr_rdy_i = '1' then
               data_mux_sel                   <= "10";
               internal_cmd_ack_mux_sel       <= '1';
            end if;
            
         when INTRNL_CMD_RDY =>
            data_mux_sel                      <= "10";
            internal_cmd_ack_mux_sel          <= '1';
      
         when SIMPLE_CMD_RDY =>
            if simple_cmd_instr_rdy_i = '1' then
               simple_cmd_ack_mux_sel         <= '1';
            elsif ret_dat_instr_rdy_i = '1' then
               if ret_dat_pending = '1' then 
                  data_mux_sel                <= "01";
                  instr_rdy_mux_sel     <= '1';
               else
                  data_mux_sel                <= "01";
                  ret_dat_ack_mux_sel         <= '1';
               end if;
            else
               simple_cmd_ack_mux_sel         <= '1';
            end if;
            
         when SIMPLE_CMD_PAUSE =>
            instr_rdy_mux_sel           <= '1';

         when RET_DAT_PAUSE =>
            data_mux_sel                      <= "01";

         when RET_DAT_RDY =>        
            if ret_dat_instr_rdy_i = '1' then
               data_mux_sel                   <= "01";
            end if; 
            ret_dat_ack_mux_sel               <= '1';
          
         when RET_DAT_RDY_SIMPLE_CMD_PENDING =>
            data_mux_sel                      <= "01";
            ret_dat_ack_mux_sel               <= '1';
             
         when RET_DAT_RDY_SIMPLE_CMD_PENDING_WAIT =>
            ret_dat_pending_mux_sel           <= '1';
            ret_dat_pending_reg_en            <= '1';
                  
         when others =>              
            simple_cmd_ack_mux_sel            <= '1';
            
      end case;
   end process;

   ------------------------------------------------------------------------
   -- routing muxes
   ------------------------------------------------------------------------
      

   card_addr               <= simple_cmd_card_addr_i       when data_mux_sel = "00" else 
                              ret_dat_card_addr_i          when data_mux_sel = "01" else
                              internal_cmd_card_addr_i;
                                                         
   parameter_id            <= simple_cmd_parameter_id_i    when data_mux_sel = "00" else 
                              ret_dat_parameter_id_i       when data_mux_sel = "01" else
                              internal_cmd_parameter_id_i;
                                                       
   data_size               <= simple_cmd_data_size_i       when data_mux_sel = "00" else 
                              ret_dat_data_size_i          when data_mux_sel = "01" else -- fix this in fibre_rx! data_size should be '0', not '1' for ret_dat commands. ret_dat_data_size_i;
                              internal_cmd_data_size_i;
                                                        
   data                    <= simple_cmd_data_i            when data_mux_sel = "00" else 
                              ret_dat_data_i               when data_mux_sel = "01" else
                              internal_cmd_data_i;
                            
   data_clk                <= simple_cmd_data_clk_i        when data_mux_sel = "00" else 
                              ret_dat_data_clk_i           when data_mux_sel = "01" else
                              internal_cmd_data_clk_i;   
   
   frame_seq_num           <= ret_dat_frame_seq_num_i      when data_mux_sel = "01" else (others=>'0');
   frame_sync_num          <= ret_dat_frame_sync_num_i     when data_mux_sel = "01" else sync_number_plus_1;  
   
   internal_cmd            <= instr_rdy when data_mux_sel = "10" else '0';  
 
   cmd_code                <= simple_cmd_code_i            when data_mux_sel = "00" else 
                              ret_dat_cmd_code_i           when data_mux_sel = "01" else 
                              internal_cmd_code_i;

   cmd_stop                <= ret_dat_cmd_stop_i           when data_mux_sel = "01" else '0';                        
   last_frame              <= ret_dat_last_frame_i         when data_mux_sel = "01" else '0';
   
   sync_number_plus_1      <= sync_number_i + 1;

   instr_rdy_1st_stg <= simple_cmd_instr_rdy_i when data_mux_sel = "00" else 
                        ret_dat_instr_rdy_i    when data_mux_sel = "01" else
                        internal_cmd_instr_rdy_i;
                              
   instr_rdy         <= instr_rdy_1st_stg      when instr_rdy_mux_sel = '0' else '0';

   ret_dat_pending_mux     <= '0' when ret_dat_pending_mux_sel = '0' else
                              '1';

   ------------------------------------------------------------------------
   -- register stage
   ------------------------------------------------------------------------   
   process(clk_i, rst_i)
   begin
      if rst_i = '1' then
         instr_rdy_reg           <= '0';
         ack_reg                 <= '0';
         ret_dat_pending         <= '0';
         cmd_code_reg            <= (others=>'0');
         cmd_stop_reg            <= '0';
         last_frame_reg          <= '0';
         
         card_addr_reg           <= (others=>'0');
         parameter_id_reg        <= (others=>'0');
         data_size_reg           <= (others=>'0');
         data_reg                <= (others=>'0');
         data_clk_reg            <= '0';
         frame_seq_num_reg       <= (others=>'0');
         frame_sync_num_reg      <= (others=>'0');
         internal_cmd_reg        <= '0';
         tes_bias_step_level_reg <= '0';
         
      elsif clk_i'event and clk_i = '1' then
         if ret_dat_pending_reg_en = '1' then
            ret_dat_pending      <= ret_dat_pending_mux;
         end if;
         instr_rdy_reg           <= instr_rdy;
         ack_reg                 <= ack_i;
         cmd_code_reg            <= cmd_code;
         cmd_stop_reg            <= cmd_stop;
         last_frame_reg          <= last_frame;
          
         card_addr_reg           <= card_addr;
         parameter_id_reg        <= parameter_id;
         data_size_reg           <= data_size;
         data_reg                <= data;
         data_clk_reg            <= data_clk;
         frame_seq_num_reg       <= frame_seq_num;
         frame_sync_num_reg      <= frame_sync_num;
         internal_cmd_reg        <= internal_cmd;
         tes_bias_step_level_reg <= tes_bias_step_level_i;
      end if;
   end process;

   ------------------------------------------------------------------------
   -- assign outputs
   ------------------------------------------------------------------------   
   simple_cmd_ack_o     <= ack_reg when simple_cmd_ack_mux_sel   = '1' else '0';
   ret_dat_ack_o        <= ack_reg when ret_dat_ack_mux_sel      = '1' else '0'; 
   internal_cmd_ack_o   <= ack_reg when internal_cmd_ack_mux_sel = '1' else '0';
 
   -- outputs to the cmd_queue 
   tes_bias_step_level_o <= tes_bias_step_level_reg;
   frame_seq_num_o       <= frame_seq_num_reg;
   frame_sync_num_o      <= frame_sync_num_reg;
   card_addr_o           <= card_addr_reg;
   parameter_id_o        <= parameter_id_reg;
   data_size_o           <= data_size_reg;
   data_o                <= data_reg;
   data_clk_o            <= data_clk_reg;
   instr_rdy_o           <= instr_rdy_reg;
   cmd_code_o            <= cmd_code_reg;
   cmd_stop_o            <= cmd_stop_reg;
   last_frame_o          <= last_frame_reg;
   internal_cmd_o        <= internal_cmd_reg;

     
end rtl;