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
-- counter.vhd
--
-- Project:	      SCUBA-2
-- Author:	       Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Generic parameterized counter
--
-- Revision history:
-- <date $Date: 2004/09/01 17:09:16 $>	- <initials $Author: erniel $>
-- $Log: counter.vhd,v $
-- Revision 1.5  2004/09/01 17:09:16  erniel
-- added range parameter to input and output counter value
--
-- Revision 1.4  2004/07/22 00:01:44  erniel
-- wraparound is default
--
-- Revision 1.3  2004/07/21 19:45:10  erniel
-- added generics to parameterize counter behaviour:
--    WRAP_AROUND
--    UP_COUNTER
--
-- Revision 1.2  2004/05/17 20:10:44  mandana
-- changed the count increments to generic STEPSIZE=1
--
-- Revision 1.1  2004/03/23 02:00:42  erniel
-- initial version
--
--
-----------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity counter is
generic(MAX         : integer := 255;
        STEP_SIZE   : integer := 1;
        WRAP_AROUND : std_logic := '1';
        UP_COUNTER  : std_logic := '1');
port(clk_i   : in std_logic;
     rst_i   : in std_logic;
     ena_i   : in std_logic;
     load_i  : in std_logic;
     count_i : in integer range 0 to MAX;
     count_o : out integer range 0 to MAX);
end counter;

architecture behav of counter is

signal count_reset : integer range 0 to MAX;
signal count_new   : integer range 0 to MAX;
signal count       : integer range 0 to MAX;

begin

   reset_value_up:        if UP_COUNTER = '1' generate 
                             count_reset <= 0;   
                          end generate;
   
   reset_value_down:      if UP_COUNTER = '0' generate 
                             count_reset <= MAX; 
                          end generate;
   
   new_value_up_nowrap:   if UP_COUNTER = '1' and WRAP_AROUND = '0' generate
                             count_new <= (count + STEP_SIZE) when count < MAX else MAX;
                          end generate;   
                          
   new_value_up_wrap:     if UP_COUNTER = '1' and WRAP_AROUND = '1' generate
                             count_new <= (count + STEP_SIZE) when count < MAX else 0;
                          end generate;
   
   new_value_down_nowrap: if UP_COUNTER = '0' and WRAP_AROUND = '0' generate
                             count_new <= (count - STEP_SIZE) when count > 0 else 0;
                          end generate;
                          
   new_value_down_wrap:   if UP_COUNTER = '0' and WRAP_AROUND = '1' generate
                             count_new <= (count - STEP_SIZE) when count > 0 else MAX;
                          end generate;
   
   process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         count <= count_reset;
      elsif(clk_i'event and clk_i = '1') then
         if(ena_i = '1') then
            if(load_i = '1') then
               count <= count_i;
            else          
               count <= count_new;
            end if;
         end if;
      end if;
   end process;
   
   count_o <= count;
   
end behav;