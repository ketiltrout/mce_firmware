-- Copyright (c) 2003 SCUBA-2 Project
--                All Rights Reserved

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

-- us_counter.vhd
--
-- <revision control keyword substitutions e.g. $Id: us_timer.vhd,v 1.4 2004/04/06 22:04:57 erniel Exp $>
--
-- Project:		 SCUBA-2
-- Author:		 Ernie Lin
-- Organisation: UBC
--
-- Description:
-- This file implements a microsecond timer
--
-- Revision history:
-- Jan. 15 2004		- Initial version      - EL
-- <date $Date: 2004/04/06 22:04:57 $>	-		<text>		- <initials $Author: erniel $>
-- $Log: us_timer.vhd,v $
-- Revision 1.4  2004/04/06 22:04:57  erniel
-- Removed obsolete code
--
-- Revision 1.3  2004/04/06 21:57:09  erniel
-- Added two counters:
--    1. Count out a 0.5 us period
--    2. Count out number of us passed
-- Modified timer reset logic
--
--
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library sys_param;
use sys_param.general_pack.all;

entity us_timer is
port(clk : in std_logic;
     timer_reset_i : in std_logic;
     timer_count_o : out integer
);
end us_timer;

architecture behav of us_timer is

signal us_count      : integer;
signal clk_count     : integer;
signal clk_count_rst : std_logic;
signal slow_clk      : std_logic;

begin

   -- fast counter runs at system clock rate and counts number of system clock periods
   fast_counter: process(clk)
   begin
      if(clk'event and clk = '1') then
         if(clk_count_rst = '1') then
            clk_count <= 0;
         else
            clk_count <= clk_count + 1;
         end if;
      end if;
   end process fast_counter;

   -- fast counter counts to (500 ns / clock_period) then resets.
   -- ie. if clock_period = 20 ns, then every 500/20 = 25 clock periods, 500 ns = 0.5 us have passed.
   clk_count_rst <= '1' when ((timer_reset_i = '1') or (clk_count >= (500/CLOCK_PERIOD_NS)-1)) else '0';
      
   
   -- slow clock generator generates 1 MHz clock (50% duty) for slow counter
   slow_clk_gen: process(clk_count, timer_reset_i)
   begin
      if(timer_reset_i = '1') then
         slow_clk <= '0';
      elsif(clk_count >= (500/CLOCK_PERIOD_NS)-1) then
         slow_clk <= not slow_clk;
      end if;
   end process slow_clk_gen;
   
   
   -- slow counter runs at derived 1 MHz clock and counts elapsed microseconds until reset by user
   slow_counter: process(slow_clk, timer_reset_i)
   begin
      if(timer_reset_i = '1') then
         us_count <= 0;
      elsif(slow_clk'event and slow_clk = '1') then
         us_count <= us_count + 1;
      end if;
   end process slow_counter;
   
   timer_count_o <= us_count;
   
end behav;