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
-- <revision control keyword substitutions e.g. $Id$>
--
-- Project:	      SCUBA-2
-- Author:	      David Atkinson
--               
-- Organisation:  UK ATC
--
-- Description:  simple_reply_fsm
--
-- This block is for test purposes and generates a an appropriate reply when a command
-- is received.  For use with the NIOS development kit / fo tranceiver board.
--
--
-- Revision history:
-- 
-- <date $Date$>	-		<text>		- <initials $Author$>
-- $log$
-----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity simple_reply_fsm is
   port( 
      rst_i        : in     std_logic;
      clk_i        : in     std_logic;

      cmd_code_i   : in    std_logic_vector (15 downto 0);
      cksum_err_i  : in    std_logic;
      cmd_rdy_i    : in    std_logic;
      tx_ff_i      : in    std_logic;

      txd_o        : out    std_logic_vector (7 downto 0);
      tx_fw_o      : out    std_logic 
   );

end simple_reply_fsm ;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

architecture rtl of simple_reply_fsm is


-- FSM's states defined

constant IDLE        : std_logic_vector(1 downto 0) := "00";
constant LD_BYTE     : std_logic_vector(1 downto 0) := "01";
constant TX_BYTE     : std_logic_vector(1 downto 0) := "10";


-- controller state variables:
signal current_state  : std_logic_vector(1 downto 0);
signal next_state     : std_logic_vector(1 downto 0);

signal tx_reply: std_logic;


constant mem_size : integer:= 32;
constant rep_size : integer:= 24;

subtype mem_deep is integer range 0 to mem_size-1;
subtype word is std_logic_vector(7 downto 0);

type mem is array (0 to mem_size-1) of word;
signal memory: mem;


signal memory_index  : mem_deep ;  
signal reset_index   : std_logic;   
signal read_mem      : std_logic;
signal data_out      : std_logic_vector(7 downto 0); -- current data word read from memory
 
---------------------------------------------------------
-- [procedure to initialise memory 

   procedure init_mem(signal memory_cell : inout mem ) is
   begin
     for i in 0 to mem_size-1 loop
        memory_cell(i) <= (others => '0');
     end loop;
   end init_mem;
---------------------------------------------------------
  
   
---------------------------------------------------------
-- [procedure to initialise OK reply

   procedure init_ok_rep(signal memory_cell : inout mem;
                         signal cmd_code :in std_logic_vector (15 downto 0)) is
   begin
       memory_cell(0)  <= X"A5";
       memory_cell(1)  <= X"A5";
       memory_cell(2)  <= X"A5";
       memory_cell(3)  <= X"A5";
       
       memory_cell(4)  <= X"5A";
       memory_cell(5)  <= X"5A";
       memory_cell(6)  <= X"5A";
       memory_cell(7)  <= X"5A";
       
       memory_cell(8)  <= X"50";
       memory_cell(9)  <= X"52";
       memory_cell(10) <= X"20";
       memory_cell(11) <= X"20";
       
       memory_cell(12) <= X"02";
       memory_cell(13) <= X"00";
       memory_cell(14) <= X"00";
       memory_cell(15) <= X"00";
       
       memory_cell(16) <= X"4b";
       memory_cell(17) <= X"4f";
       memory_cell(18) <= cmd_code(7 downto 0);
       memory_cell(19) <= cmd_code(15 downto 8);
       
       memory_cell(20) <= X"00";
       memory_cell(21) <= X"00";
       memory_cell(22) <= X"00";
       memory_cell(23) <= X"00";
       
    end init_ok_rep;
    
    ---------------------------------------------------------
-- [procedure to initialise OK reply

   procedure init_er_rep(signal memory_cell : inout mem;
                         signal cmd_code :in std_logic_vector (15 downto 0)) is
   begin
       memory_cell(0)  <= X"A5";
       memory_cell(1)  <= X"A5";
       memory_cell(2)  <= X"A5";
       memory_cell(3)  <= X"A5";
       
       memory_cell(4)  <= X"5A";
       memory_cell(5)  <= X"5A";
       memory_cell(6)  <= X"5A";
       memory_cell(7)  <= X"5A";
       
       memory_cell(8)  <= X"50";
       memory_cell(9)  <= X"52";
       memory_cell(10) <= X"20";
       memory_cell(11) <= X"20";
       
       memory_cell(12) <= X"02";
       memory_cell(13) <= X"00";
       memory_cell(14) <= X"00";
       memory_cell(15) <= X"00";
       
       memory_cell(16) <= X"52";
       memory_cell(17) <= X"45";
       memory_cell(18) <= cmd_code(7 downto 0);
       memory_cell(19) <= cmd_code(15 downto 8);
       
       memory_cell(20) <= X"00";
       memory_cell(21) <= X"00";
       memory_cell(22) <= X"00";
       memory_cell(23) <= X"00";
       
    end init_er_rep;
---------------------------------------------------------


begin

  tx_reply <= cmd_rdy_i or cksum_err_i;

  ----------------------------------------------------------------------------
   initialise_reply : process(
      rst_i, cmd_rdy_i,
      cksum_err_i)
   ----------------------------------------------------------------------------
   begin
      if (rst_i = '1') then
         init_mem(memory);
      elsif (cmd_rdy_i'event and cmd_rdy_i = '1') then
         init_ok_rep(memory, cmd_code_i);
      elsif (cksum_err_i'event and cksum_err_i = '1') then
         init_er_rep(memory, cmd_code_i);
      end if;
      
   end process initialise_reply;

   ----------------------------------------------------------------------------
   clocked : process(
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

   end process clocked;

   ----------------------------------------------------------------------------
   nextstate : process (
      current_state,
      tx_reply,
      tx_ff_i,
      memory_index
   )
   ----------------------------------------------------------------------------
   begin
     
      case current_state is

      when IDLE =>
         if (tx_reply = '1') then
            next_state <= LD_BYTE;
         else
            next_state <= IDLE; 
         end if;

      when LD_BYTE =>
         if (tx_ff_i = '1') then 
            next_state <= LD_BYTE;
         else
            next_state <= TX_BYTE;
         end if;
         
      when TX_BYTE =>
         if (memory_index < rep_size) then
            next_state <= LD_BYTE;
         else 
            next_state <= IDLE;
         end if;
          
     
      when others =>
         next_state <= IDLE;
      end case;

   end process nextstate;

   ----------------------------------------------------------------------------
   output : process (
      current_state, data_out
   )
   ----------------------------------------------------------------------------
   begin

      case current_state IS
      
      when IDLE =>
         reset_index <= '1';
         read_mem    <= '0';
         tx_fw_o     <= '0';
         
      when LD_BYTE =>
         reset_index <= '0';
         read_mem    <= '1'; 
         tx_fw_o     <= '0';
    
      when TX_BYTE =>
         reset_index <= '0';
         read_mem    <= '0'; 
         txd_o       <= data_out;
         tx_fw_o     <= '1';

      when others =>
            NULL;
  
      end case;

   end process output;
   
 ------------------------------------------------------------------------------
  read_memory: process(reset_index, read_mem)
  ----------------------------------------------------------------------------
  -- process to read data word from local memory
  ----------------------------------------------------------------------------

 begin
     if (reset_index = '1') then
        memory_index <= 0;
     elsif (read_mem'EVENT AND read_mem = '1') then
        data_out <= memory(memory_index); 
        memory_index <= memory_index + 1;
     end if; 

  end process read_memory;  
  
end rtl;
