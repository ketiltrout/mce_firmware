-- Copyright (c) 2003 SCUBA-2 Project
--                  All Rights Reserved
--
--  THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF THE SCUBA-2 Project
--  The copyright notice above does not evidence any
--  actual or intended publication of such source code.
--
--  SOURCE CODE IS PROVIDED "AS IS". ALL EXPRESS OR IMPLIED CONDITIONS,
--  REPRESENTATIONS, AND WARRANTIES, INCLUDING ANY IMPLIED WARRANT OF
--  MERCHANTABILITY, SATISFACTORY QUALITY, FITNESS FOR A PARTICULAR
--  PURPOSE, OR NON-INFRINGEMENT, ARE DISCLAIMED, EXCEPT TO THE EXTENT
--  THAT SUCH DISCLAIMERS ARE HELD TO BE LEGALLY INVALID.
--
-- For the purposes of this code the SCUBA-2 Project consists of the
-- following organisations.
--
-- UKATC, Royal Observatory, Blackford Hill Edinburgh EH9 3HJ
-- UBC,   University of British Columbia, Physics & Astronomy Department,
--        Vancouver BC, V6T 1Z1
--
--
-- tb_reply_queue_accumulator.vhd
--
-- Project:	      SCUBA-2
-- Author:        Mandana Amiri
-- Organisation:  UBC
--
-- Description:
-- Testbench for Accumulator block reply_queue_accumulator
--
-- Revision history:
-- <date $Date$>    - <initials $Author$>
-- $Log$
--
-----------------------------------------------------------------------------


LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;
use work.reply_queue_pack.all;

ENTITY tb_reply_queue_accumulator IS
END tb_reply_queue_accumulator;


ARCHITECTURE tb OF tb_reply_queue_accumulator IS

constant CLK_PERIOD     : TIME := 20 ns;    -- 50Mhz clock

signal	tb_data		: STD_LOGIC_VECTOR (31 DOWNTO 0);
signal	tb_clock	: STD_LOGIC  := '0';
signal	tb_sload	: STD_LOGIC  := '0';
signal	tb_clken	: STD_LOGIC;
signal	tb_aclr		: STD_LOGIC;
signal	tb_result	: STD_LOGIC_VECTOR (31 DOWNTO 0);

begin

   acc : reply_queue_accumulator  
   port map(clock  => tb_clock, 
            clken  => tb_clken,
            sload  => tb_sload,
            aclr   => tb_aclr,
            data   => tb_data,
            result => tb_result);

   -- data counter         
   data_counter : process (tb_aclr, tb_clock)
   begin
      if (tb_aclr = '1') then
         tb_data <= (others => '0');
      elsif (tb_clock'event and tb_clock = '1') then
         if (tb_data = x"ffffffff") then
            tb_data <= (others => '0');
         else   
            tb_data <= tb_data + 1;
         end if;   
      end if;
   end process ;   

   tb_clock <= not tb_clock after CLK_PERIOD/2;
            
   stimuli : process
           
   procedure do_reset is
      begin
         tb_aclr <= '1';
         wait for CLK_PERIOD*5;
         tb_aclr <= '0';
         wait for CLK_PERIOD*5 ;
      
         assert false report " clearing the accumulator" severity NOTE;
      end do_reset;
   
   procedure do_load is
      begin 
         tb_sload <= '1';
         wait for CLK_PERIOD*5;
         tb_sload <= '0';
         wait for CLK_PERIOD*5 ;
      
         assert false report " loading the accumulator" severity NOTE;
      end do_load;
      
   begin                   

   
      do_reset;
      wait for CLK_PERIOD;
      tb_clken <= '1';
      wait for 50 us;
      tb_clken <= '0';
      do_reset;
      tb_clken <= '1';
      wait for 50 us;
      assert false report "Simulation done." severity FAILURE;

   end process stimuli;
END tb;
