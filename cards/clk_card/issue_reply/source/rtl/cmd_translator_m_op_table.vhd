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

-- <revision control keyword substitutions e.g. $Id$>
--
-- Project:	     SCUBA-2
-- Author:	      David Atkinson
--
-- Organisation:  UK ATC
--
-- Description:  
-- This module is the macro_op table.  It keeps track of the issued marco_op commands,
-- and retires them once completed. 
-- 
-- 
-- Revision history:
-- 
-- <date $Date$>	-		<text>		- <initials $Author$>
--
-- $Log: cmd_translator_m_op_table.vhd,v $
--
-- 
-----------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.issue_reply_pack.all;



entity cmd_translator_m_op_table is

port(
     -- global inputs
     rst_i             : in     std_logic;

     -- inputs from cmd_translator (top level)     
     card_addr_store_i       : in std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0);  -- specifies which card the command is targetting
     parameter_id_store_i    : in std_logic_vector (PAR_ID_BUS_WIDTH-1    downto 0);  -- comes from reg_addr_i, indicates which device(s) the command is targetting
     m_op_seq_num_store_i    : in std_logic_vector (MOP_BUS_WIDTH-1       downto 0);
     frame_seq_num_store_i   : in std_logic_vector (31                    downto 0);
     macro_instr_rdy_i       : in std_logic;                                           -- ='1' when the data is valid, else it's '0'
 
     -- inputs from reply translator
     m_op_seq_num_retire_i    : in std_logic_vector (MOP_BUS_WIDTH-1       downto 0);
     macro_instr_done_i       : in std_logic;                                           -- ='1' when the data is valid, else it's '0'
 
     table_empty_o            : out std_logic;                                         -- asserted if table full.  no more macro instructions should be retired.
     table_full_o             : out std_logic                                          -- asserted if table full.  No more macro instructions should be issued.
   ); 
     
end cmd_translator_m_op_table;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.issue_reply_pack.all;

architecture rtl of cmd_translator_m_op_table is


-- m_op buffer (store/retire) declaration 
constant BUFFER_SIZE               : positive := 16;

-- local memory buffer word size declaration
subtype card_addr_word      is std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0);
subtype parameter_id_word   is std_logic_vector (PAR_ID_BUS_WIDTH-1    downto 0); 
subtype m_op_seq_num_word   is std_logic_vector (MOP_BUS_WIDTH-1       downto 0); 
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
signal set_mop_flag           : std_logic_vector(0 to BUFFER_SIZE-1);      -- bit vector to show which slot has just been occupied  
signal clr_mop_flag           : std_logic_vector(0 to BUFFER_SIZE-1);      -- bit vector to show which slot is to be retired

begin


   --------------------------------------------
   m_op_store: process(rst_i, macro_instr_rdy_i)
   ---------------------------------------------
   -- process to store macro_op instructions
   ---------------------------------------------
   begin
      if (rst_i = '1') then 
         set_mop_flag                           <= (others => '0');
         
         for clear_index in 0 to (BUFFER_SIZE-1) loop
            card_addr_buffer(clear_index)       <= (others => '0');
            parameter_id_buffer(clear_index)    <= (others => '0');
            m_op_seq_num_buffer(clear_index)    <= (others => '0');
            frame_seq_num_buffer(clear_index)   <= (others => '0');
         end loop;
         
      
      elsif (macro_instr_rdy_i'event and macro_instr_rdy_i = '1') then        -- store values in table
            card_addr_buffer(store_pointer)     <= card_addr_store_i;
            parameter_id_buffer(store_pointer)  <= parameter_id_store_i;
            m_op_seq_num_buffer(store_pointer)  <= m_op_seq_num_store_i;
            frame_seq_num_buffer(store_pointer) <= frame_seq_num_store_i;
            
            set_mop_flag                        <= (others => '0');
            set_mop_flag(store_pointer)         <= '1';
      end if;  
   end process m_op_store; 
 
  
   --------------------------------------------------------
   m_op_retire_pointer: process(rst_i, macro_instr_done_i)
   --------------------------------------------------------
   -- process to estable macro op to retire 
   --------------------------------------------------------
   begin
      if (rst_i = '1') then 
         retire_pointer                         <=  0 ;      
         clr_mop_flag                           <= (others => '0');
      elsif (macro_instr_done_i'event and macro_instr_done_i = '1') then     
   
      -- find instruction to be retired in look-up table using sequence number
      -- and table_status, then set element in clr_mop_flag
         clr_mop_flag                           <= (others => '0'); 
         for retire_index in 0 to BUFFER_SIZE-1 loop
            if (m_op_seq_num_retire_i = m_op_seq_num_buffer(retire_index) ) and (table_status(retire_index) = '1') then
               retire_pointer <= retire_index;  
               clr_mop_flag(retire_index)       <= '1';             
            end if;
         end loop;
            

          
      end if;    
   end process m_op_retire_pointer;
   
           
                 
   ----------------------------------------------------------
   flag_status: process(rst_i, set_mop_flag, clr_mop_flag)
   ----------------------------------------------------------
   -- process to get set/clear macro op flags in table_status
   -- to refect which are issued/retired
   ----------------------------------------------------------
   
   begin
      if rst_i  = '1' then
         table_status <= (others => '0');
      
      else
       
         if set_mop_flag'event then
            for set_index in 0 to BUFFER_SIZE-1 loop
              if set_mop_flag(set_index) = '1' then
                 table_status(set_index)<= '1';                       -- indicate table slot occupied
              end if;
            end loop;
         end if;
      
         if clr_mop_flag'event then
            for clr_index in 0 to BUFFER_SIZE-1 loop
              if clr_mop_flag(clr_index) = '1' then
                table_status(clr_index) <= '0';                       -- indicate table slot occupied
              end if;
            end loop;
         end if;
      
      end if;
      
    end process flag_status;
    
    
   -----------------------------------------------------
   m_op_store_pointer: process(table_status)
   -----------------------------------------------------
   -- process to get next value for store_pointer
   ------------------------------------------------------
   begin
      for store_index in BUFFER_SIZE-1 downto 0 loop          -- assign store_pointer lowest availble location in table
         if table_status(store_index) = '0' then
            store_pointer <= store_index;
         else
            null;
         end if;
      end loop;
      
   end process m_op_store_pointer;       
  
   -----------------------------------------------
   table_full_empty: process(table_status)
   -----------------------------------------------
   -- process to check if table is full or empty 
   ----------------------------------------------
   begin
      if table_status = std_logic_vector(to_signed(-1,BUFFER_SIZE)) then        -- table empty
         table_full_o    <= '1';
         table_empty_o   <= '0';
      elsif table_status = std_logic_vector(to_unsigned(0,BUFFER_SIZE)) then    -- table full
         table_full_o    <= '0';
         table_empty_o   <= '1';
      else                                                                      -- neither empty not full
         table_full_o    <= '0';
         table_empty_o   <= '0';
      end if;
   end process table_full_empty;
                      
end rtl;