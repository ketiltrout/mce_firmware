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
-- <revision control keyword substitutions e.g. $Id: us_timer.vhd,v 1.5 2004/10/13 02:10:49 erniel Exp $>
--
-- Project:		 SCUBA-2
-- Author:		 Ernie Lin
-- Organisation: UBC
--
-- Description:
-- This file implements a microsecond timer
--
-- Revision history:
--
-- $Log: us_timer.vhd,v $
-- Revision 1.5  2004/10/13 02:10:49  erniel
-- simplified counter logic
-- removed requirement for 50% duty in generated clock
--
--
-- Jan. 15 2004		- Initial version      - EL
-- <date $Date: 2004/10/13 02:10:49 $>	-		<text>		- <initials $Author: erniel $>
-- $Log: us_timer.vhd,v $
-- Revision 1.5  2004/10/13 02:10:49  erniel
-- simplified counter logic
-- removed requirement for 50% duty in generated clock
--
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

signal us_count  : integer range 0 to 999999999;

begin

   timer: process(clk)
   variable clk_count : integer range 0 to (1000/CLOCK_PERIOD_NS)-1;
   begin
      if(clk'event and clk = '1') then 
         if(timer_reset_i = '1') then
            us_count <= 0;
            clk_count := 0;
         end if;
         
         if(clk_count = (1000/CLOCK_PERIOD_NS)-1) then
            us_count <= us_count + 1;
            clk_count := 0;
         else
            clk_count := clk_count + 1;
         end if;
      end if;
   end process timer;
   
   timer_count_o <= us_count;
   
end behav;