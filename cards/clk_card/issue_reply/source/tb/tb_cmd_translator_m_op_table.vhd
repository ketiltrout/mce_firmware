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
-- <revision control keyword substitutions e.g. $Id: tb_cmd_translator_m_op_table.vhd,v 1.3 2004/07/09 10:17:50 dca Exp $>
--
-- Project:	     SCUBA-2
-- Author:	      David Atkinson
--
-- Organisation:  UK ATC
--
-- Description:  
-- This module is the test bed for cmd_translator_m_op_table
-- 
-- 
-- Revision history:
-- 
-- <date $Date: 2004/07/09 10:17:50 $>	-		<text>		- <initials $Author: dca $>
--
-- $Log: tb_cmd_translator_m_op_table.vhd,v $
-- Revision 1.3  2004/07/09 10:17:50  dca
--
-- Simultaneous store/retire no longer permitted, so removed from TB.
--
-- Revision 1.2  2004/07/06 11:02:43  dca
-- "cmd_translator_m_op_table" component declaration removed.
-- Now referenced from issue_reply_pack.
--
-- Revision 1.1  2004/07/06 10:54:53  dca
-- Initial Version
--
--
-- 
-----------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.issue_reply_pack.all;



entity tb_cmd_translator_m_op_table is
end tb_cmd_translator_m_op_table;



library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.issue_reply_pack.all;


architecture bench of tb_cmd_translator_m_op_table is


signal   dut_rst              : std_logic;
signal   card_addr_store      : std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0); 
signal   parameter_id_store   : std_logic_vector (PAR_ID_BUS_WIDTH-1    downto 0);  
signal   m_op_seq_num_store   : std_logic_vector (MOP_BUS_WIDTH-1       downto 0);
signal   frame_seq_num_store  : std_logic_vector (31                    downto 0);
signal   macro_instr_rdy      : std_logic;                                           
signal   card_addr_retire     : std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0);  
signal   parameter_id_retire  : std_logic_vector (PAR_ID_BUS_WIDTH-1    downto 0);  
signal   m_op_seq_num_retire  : std_logic_vector (MOP_BUS_WIDTH-1       downto 0);
signal   frame_seq_num_retire : std_logic_vector (31                    downto 0);
signal   macro_instr_done     : std_logic;                                           
signal   table_full           : std_logic;     
signal   table_empty          : std_logic;  
signal   retiring_busy        : std_logic;  
  
-- tb clock signals
signal   tb_clk       : std_logic := '1';  
constant clk_prd      : TIME := 40 ns;    -- 25Mhz clock
  
  
-- issue macro op 
signal  issue_m_op    : integer := 16; 

-- retire macro op
signal  retire_m_op    : integer := 16; 
   

constant BUFFER_SIZE  : integer := 16;
    
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
---constant card_addr_buffer       : card_addr_mem;
---constant parameter_id_buffer    : parameter_id_mem;
---constant m_op_seq_num_buffer    : m_op_seq_num_mem;
---constant frame_seq_num_buffer   : frame_seq_num_mem;





  
begin

-------------------------------------------------
-- Instantiate DUT
-------------------------------------------------

   DUT :  cmd_translator_m_op_table
   
   port map ( 
   
     rst_i                    =>  dut_rst,  
     clk_i                    =>  tb_clk, 
     card_addr_store_i        =>  card_addr_store,
     parameter_id_store_i     =>  parameter_id_store,
     m_op_seq_num_store_i     =>  m_op_seq_num_store,
     frame_seq_num_store_i    =>  frame_seq_num_store,
     macro_instr_rdy_i        =>  macro_instr_rdy,
     m_op_seq_num_retire_i    =>  m_op_seq_num_retire,
     macro_instr_done_i       =>  macro_instr_done,
     retiring_busy_o          =>  retiring_busy,
     table_empty_o            =>  table_empty,
     table_full_o             =>  table_full
   ); 
   
  
------------------------------------------------
-- Create test bench clock
-------------------------------------------------
  
   tb_clk <= not tb_clk after clk_prd/2;

------------------------------------------------
-- Create test bench stimuli
-------------------------------------------------
   
   stimuli : process
  
------------------------------------------------
-- Stimulus procedures
-------------------------------------------------
   
      
-- reset procedure   
   procedure do_reset is
   begin
      macro_instr_rdy <= '0';
      macro_instr_done <= '0'; 
      dut_rst <= '1';
      assert false report "DUT reset...." severity NOTE;
      wait for clk_prd*5 ;
      dut_rst <= '0';
      wait for clk_prd*5 ;
   end do_reset;
      
-- store macro op 
   procedure do_store_m_op is
   begin
      macro_instr_rdy <= '1';
      assert false report "store macro op...." severity NOTE;
      wait for clk_prd;
      macro_instr_rdy <= '0';
      wait for clk_prd;
   end do_store_m_op;
   
-- retire macro op 
   procedure do_retire_m_op is
   begin
      macro_instr_done <= '1';
      assert false report "retire macro op...." severity NOTE;
      wait until retiring_busy <= '1';                            -- must not de-assert until retirment has begun 
      macro_instr_done <= '0';
      wait for clk_prd;
   end do_retire_m_op;
   
      
   begin
      do_reset;
      
      -- fill with some dummy values...just using same value for all saved parameters...
      
      for I in 0 to 15 loop
                    
         card_addr_store        <= std_logic_vector(to_unsigned(issue_m_op,CARD_ADDR_BUS_WIDTH));
         parameter_id_store     <= std_logic_vector(to_unsigned(issue_m_op,PAR_ID_BUS_WIDTH));
         m_op_seq_num_store     <= std_logic_vector(to_unsigned(issue_m_op,MOP_BUS_WIDTH));
         frame_seq_num_store    <= std_logic_vector(to_unsigned(issue_m_op,32));
         do_store_m_op;
         
         issue_m_op             <= issue_m_op + 1;

         wait for clk_prd*2;
      
      end loop;
      
      assert false report "m_op table should now be full......." severity NOTE;
      wait for clk_prd*2;
      
      -- now retire 4 of the m_ops
      -- in a different sequence than issued
     
      
      retire_m_op               <= retire_m_op + 7; 
      wait for clk_prd;
      m_op_seq_num_retire    <= std_logic_vector(to_unsigned(retire_m_op,MOP_BUS_WIDTH));   
      do_retire_m_op;
      wait for clk_prd;
      wait until retiring_busy <= '0';
      
      retire_m_op            <= retire_m_op + 3; 
      wait for clk_prd;     
      m_op_seq_num_retire    <= std_logic_vector(to_unsigned(retire_m_op,MOP_BUS_WIDTH));
      do_retire_m_op;
      wait for clk_prd;
      wait until retiring_busy <= '0';
      
      retire_m_op            <= retire_m_op + 3; 
      wait for clk_prd;     
      m_op_seq_num_retire    <= std_logic_vector(to_unsigned(retire_m_op,MOP_BUS_WIDTH));
      do_retire_m_op;
      wait for clk_prd;
      wait until retiring_busy <= '0';
      
      retire_m_op            <= retire_m_op - 9; 
      wait for clk_prd;     
      m_op_seq_num_retire    <= std_logic_vector(to_unsigned(retire_m_op,MOP_BUS_WIDTH));
      do_retire_m_op;
      wait for clk_prd;
      wait until retiring_busy <= '0';
      wait for clk_prd;
      
      assert false report "m_op table should now have 4 free slots......." severity NOTE;
      
      
        
      -- now fill again with 4 more issued commands
      -- ......will fill from lowest free slot
          
      
      for I in 0 to 3 loop
                    
         card_addr_store        <= std_logic_vector(to_unsigned(issue_m_op,CARD_ADDR_BUS_WIDTH));
         parameter_id_store     <= std_logic_vector(to_unsigned(issue_m_op,PAR_ID_BUS_WIDTH));
         m_op_seq_num_store     <= std_logic_vector(to_unsigned(issue_m_op,MOP_BUS_WIDTH));
         frame_seq_num_store    <= std_logic_vector(to_unsigned(issue_m_op,32));
         do_store_m_op;
         
         issue_m_op             <= issue_m_op + 1;

         wait for clk_prd*2;
      
      end loop;
      
      assert false report "m_op table should be full again......." severity NOTE;
      wait for clk_prd*1;
               
      do_reset;
      wait for clk_prd*2;

      assert false report "simulation finished...." severity FAILURE;
      
      wait;
      

   end process stimuli;
  
   
end bench;