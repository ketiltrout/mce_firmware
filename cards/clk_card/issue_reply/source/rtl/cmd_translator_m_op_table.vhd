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

-- <revision control keyword substitutions e.g. $Id: cmd_translator_m_op_table.vhd,v 1.5 2004/09/30 22:34:44 erniel Exp $>
--
-- Project:	     SCUBA-2
-- Author:	      David Atkinson
--
-- Organisation:  UK ATC
--
-- Description:  
-- This module is the macro_op table.  It keeps track of the issued marco_op commands,
-- and retires them once completed.  The vector 'table_status' has a bit set for 
-- each macro command issued.   The bit corresponds to the element in the table where 
-- the command is stored. 
--
-- SIMULTANEOUS M_OP STORES AND M_OP RETIRES ARE NOT PERMITTED.
--
-- When a m_op is being retired the output 'retiring_busy' will be asserterd high.
-- Not other m_ops should be stored or retired during this time.
--
-- Furthermore, when retiring a command the input "macro_instr_done_i" should be held high   
-- until the output signal "retiring_busy_o" goes high.
--
-- 
-- Revision history:
-- 
-- <date $Date: 2004/09/30 22:34:44 $>	-		<text>		- <initials $Author: erniel $>
--
-- $Log: cmd_translator_m_op_table.vhd,v $
-- Revision 1.5  2004/09/30 22:34:44  erniel
-- using new command_pack constants
--
-- Revision 1.4  2004/07/28 23:39:19  jjacob
-- added:
-- library sys_param;
-- use sys_param.command_pack.all;
--
-- Revision 1.3  2004/07/09 12:25:31  dca
-- transition state condition added to FSM
--
-- Revision 1.2  2004/07/09 10:17:14  dca
-- small FSM added to handel M_OP retires.
-- Simultaneous store/retire NOT permitted.
--
-- Revision 1.1  2004/07/06 10:53:40  dca
-- Initial Version
--
--
-- 
-----------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;

library sys_param;
use sys_param.command_pack.all;

entity cmd_translator_m_op_table is

port(
     -- global inputs 
     rst_i                   : in     std_logic;
     clk_i                   : in     std_logic;

     -- inputs from cmd_translator (top level)     
     card_addr_store_i       : in std_logic_vector (FIBRE_CARD_ADDRESS_WIDTH-1 downto 0);  -- specifies which card the command is targetting
     parameter_id_store_i    : in std_logic_vector (FIBRE_PARAMETER_ID_WIDTH-1    downto 0);  -- comes from reg_addr_i, indicates which device(s) the command is targetting
     m_op_seq_num_store_i    : in std_logic_vector (BB_MACRO_OP_SEQ_WIDTH-1       downto 0);
     frame_seq_num_store_i   : in std_logic_vector (31                    downto 0);
     macro_instr_rdy_i       : in std_logic;                                           -- ='1' when the data is valid, else it's '0'
 
     -- inputs from reply translator
     m_op_seq_num_retire_i    : in std_logic_vector (BB_MACRO_OP_SEQ_WIDTH-1       downto 0);
     macro_instr_done_i       : in std_logic;                                          -- ='1' when the data is valid, else it's '0'
 
     retiring_busy_o          : out std_logic;                                         -- asserted high while retiring a m_op, during which time no other m-ops should be issues.
     table_empty_o            : out std_logic;                                         -- asserted high if table full.  no more macro instructions should be retired.
     table_full_o             : out std_logic                                          -- asserted high if table full.  No more macro instructions should be issued.
   ); 
     
end cmd_translator_m_op_table;


architecture rtl of cmd_translator_m_op_table is


-- m_op buffer (store/retire) declaration 
constant BUFFER_SIZE               : positive := 16;

-- local memory buffer word size declaration
subtype card_addr_word      is std_logic_vector (FIBRE_CARD_ADDRESS_WIDTH-1 downto 0);
subtype parameter_id_word   is std_logic_vector (FIBRE_PARAMETER_ID_WIDTH-1    downto 0); 
subtype m_op_seq_num_word   is std_logic_vector (BB_MACRO_OP_SEQ_WIDTH-1       downto 0); 
subtype frame_seq_num_word  is std_logic_vector (31                    downto 0); 

-- local memory buffer declarations
type card_addr_mem     is array (0 to BUFFER_SIZE-1) of card_addr_word;
type parameter_id_mem  is array (0 to BUFFER_SIZE-1) of parameter_id_word;
type m_op_seq_num_mem  is array (0 to BUFFER_SIZE-1) of m_op_seq_num_word;
type frame_seq_num_mem is array (0 to BUFFER_SIZE-1) of frame_seq_num_word;

-- assignement of signals to memory arrays
signal card_addr_buffer       : card_addr_mem;
signal parameter_id_buffer    : parameter_id_mem;
signal m_op_seq_num_buffer    : m_op_seq_num_mem;
signal frame_seq_num_buffer   : frame_seq_num_mem;

-- signals used by the look up table
signal store_pointer          : integer;                                   -- points to next available (loweset) free slot in table 
signal retire_pointer         : integer;                                   -- points to slot to be retired
signal table_status		         : std_logic_vector(0 to BUFFER_SIZE-1);      -- bit vector which reveals if slot in table is free or occupied

signal retire_mop             : std_logic;                                 -- FSM output which initiates the retirement of a m_op
signal find_mop               : std_logic;                                 -- FSM output which initiates a search for the m_op to be retired
signal update_table           : std_logic;                                 -- when asserted the table is updated with either a store or a retire.

-- retire fsm states
constant IDLE                 : std_logic_vector(1 downto 0)  := "00";     -- FSM idle state
constant FIND_MOP_SEQ         : std_logic_vector(1 downto 0)  := "01";     -- FSM state in which the m_op to be retired is foundstate
constant RETIRE_MOP_SEQ       : std_logic_vector(1 downto 0)  := "10";     -- FSM state in whcih the m_op is retired

-- state variables:
signal current_state  : std_logic_vector(1 downto 0);
signal next_state     : std_logic_vector(1 downto 0);



begin

 
   update_table  <= macro_instr_rdy_i OR retire_mop;
   
   -----------------------------------------------------------
   store_retire_table: process(rst_i, update_table )
   -----------------------------------------------------------
   -- process to store/retire macro commands
   -- note store/retire cannot be done simultaneously
   -----------------------------------------------------------
   begin
      
      if rst_i = '1' then
         table_status <= (others => '0');
         
         for clear_index in 0 to (BUFFER_SIZE-1) loop
            card_addr_buffer(clear_index)       <= (others => '0');
            parameter_id_buffer(clear_index)    <= (others => '0');
            m_op_seq_num_buffer(clear_index)    <= (others => '0');
            frame_seq_num_buffer(clear_index)   <= (others => '0');
         end loop;
         
      elsif (update_table'event and update_table = '1') then
         if macro_instr_rdy_i = '1' then
            card_addr_buffer(store_pointer)     <= card_addr_store_i;
            parameter_id_buffer(store_pointer)  <= parameter_id_store_i;
            m_op_seq_num_buffer(store_pointer)  <= m_op_seq_num_store_i;
            frame_seq_num_buffer(store_pointer) <= frame_seq_num_store_i;
            table_status(store_pointer) <= '1';
         else
            card_addr_buffer(retire_pointer)       <= (others => '0');
            parameter_id_buffer(retire_pointer)    <= (others => '0');
            m_op_seq_num_buffer(retire_pointer)    <= (others => '0');
            frame_seq_num_buffer(retire_pointer)   <= (others => '0');
            table_status(retire_pointer) <= '0';
         end if;
      end if;
      
   end process store_retire_table;       
  
     
   
   --------------------------------------------------------------------
   find_store_pointer: process(rst_i, macro_instr_rdy_i, table_status)
   ---------------------------------------------------------------------
   -- process establish the next value for store_pointer
   ---------------------------------------------------------------------
   begin
      
      if rst_i = '1' then
         store_pointer <= 0;
      elsif macro_instr_rdy_i = '0' then                         -- find next free slot 
      
         for store_index in BUFFER_SIZE-1 downto 0 loop          -- assign store_pointer lowest availble location in table
            if table_status(store_index) = '0' then
               store_pointer <= store_index;
            end if;
         end loop;
      
      end if;
      
   end process find_store_pointer;       
  
  
   ---------------------------------------------------------------------------
   -- FSM used to retire macro operations
   ----------------------------------------------------------------------------
   fsm_clocked : process(
      clk_i,
      rst_i
   )
   ----------------------------------------------------------------------------
   begin
         
      if (rst_i = '1') then
         current_state <= IDLE;
      elsif (clk_i'EVENT AND clk_i = '1') then
         current_state <= next_state;
      end if;

   end process fsm_clocked;

   -------------------------------------------------------------------------
   fsm_nextstate : process (
      current_state,
      macro_instr_done_i
   )
   ----------------------------------------------------------------------------
   begin
     
      case current_state is


      when IDLE =>
         if (macro_instr_done_i = '1') then
            next_state <= FIND_MOP_SEQ;
         else
            next_state <= IDLE;
         end if;  
         
      when FIND_MOP_SEQ =>
         next_state <= RETIRE_MOP_SEQ;

      when RETIRE_MOP_SEQ =>
         if (macro_instr_done_i = '0') then
            next_state <= IDLE;
         else
            next_state <= RETIRE_MOP_SEQ;
         end if;  
         
      when OTHERS =>
         next_state <= IDLE;   
         
      end case;
      
   end process fsm_nextstate;
    
         
   -------------------------------------------------------------------------
   fsm_output : process (
      current_state
   )
   ----------------------------------------------------------------------------
   begin
     
      case current_state is

      when IDLE =>
         
         retiring_busy_o <= '0';
         find_mop        <= '0';
         retire_mop      <= '0';
      
      when  FIND_MOP_SEQ =>
         retiring_busy_o <= '1';
         find_mop        <= '1';
         retire_mop      <= '0';
           
      when RETIRE_MOP_SEQ =>
         retiring_busy_o <= '1';
         find_mop        <= '0';
         retire_mop      <= '1';   
      
      when OTHERS => 
         retiring_busy_o <= '0';
         find_mop        <= '0';
         retire_mop      <= '0';
      
      end case;
      
      
   end process fsm_output;
 
   -------------------------------------------------------------------------
   find_retire_pointer: process(rst_i, find_mop)
   -------------------------------------------------------------------------
   -- process to estable macro op to retire 
   -- finds instruction to be retired in look-up table using sequence number
   -------------------------------------------------------------------------
   begin
      if (rst_i = '1') then 
         retire_pointer                         <=  0 ;      

      elsif (find_mop'event and find_mop = '1') then     
   
         for retire_index in 0 to BUFFER_SIZE-1 loop
            if (m_op_seq_num_retire_i = m_op_seq_num_buffer(retire_index) ) and (table_status(retire_index) = '1') then
               retire_pointer <= retire_index; 
            end if;
         end loop;
        
      end if;    
   end process find_retire_pointer;
   
   
        
   -----------------------------------------------
   table_full_empty: process(table_status)
   -----------------------------------------------
   -- process to check if table is full or empty 
   ----------------------------------------------
   begin
      if table_status = conv_std_logic_vector(-1, BUFFER_SIZE) then
--      if table_status = std_logic_vector(to_signed(-1,BUFFER_SIZE)) then        -- table empty
         table_full_o    <= '1';
         table_empty_o   <= '0';
      elsif table_status = conv_std_logic_vector(0, BUFFER_SIZE) then
--      elsif table_status = std_logic_vector(to_unsigned(0,BUFFER_SIZE)) then    -- table full
         table_full_o    <= '0';
         table_empty_o   <= '1';
      else                                                                      -- neither empty not full
         table_full_o    <= '0';
         table_empty_o   <= '0';
      end if;
   end process table_full_empty;
                      
end rtl;