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
-- <revision control keyword substitutions e.g. $Id$>
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
-- <date $Date$>	-		<text>		- <initials $Author$>

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
signal count_clk : integer;
signal count_us : integer;
begin

   -- this process counts clock pulses up to 1 us
   period_count: process(clk)
   begin
      if(clk'event and clk = '1') then
         if(timer_reset_i = '1') then
            count_clk <= 0;
         elsif(count_clk >= 1000/CLOCK_PERIOD_NS) then
            count_clk <= 1;
         else
            count_clk <= count_clk + 1;
         end if;
      end if;
   end process period_count;
   
   -- this process counts the number of microseconds that have passed
   us_count: process(count_clk)
   begin
      if(timer_reset_i = '1') then
         count_us <= 0;
      elsif(count_clk >= 1000/CLOCK_PERIOD_NS) then
         -- count_clk is reset by previous process when >= 1000_ns/clock_period_ns, increments count_us
         count_us <= count_us + 1;
      end if;
   end process us_count;
   
   timer_count_o <= count_us;

end behav;