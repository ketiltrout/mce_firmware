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

-- ns_timer.vhd
--
-- <revision control keyword substitutions e.g. $Id: ns_timer.vhd,v 1.1 2004/03/23 23:53:42 jjacob Exp $>
--
-- Project:		 SCUBA-2
-- Author:		 Jonathan Jacob
-- Organisation: UBC
--
-- Description:
-- This file implements a nanosecond timer
--
-- Revision history:
-- 
-- <date $Date: 2004/03/23 23:53:42 $>	-		<text>		- <initials $Author: jjacob $>

--
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library sys_param;
use sys_param.general_pack.all;

entity ns_timer is

   port(clk           : in std_logic;
        timer_reset_i : in std_logic;
        timer_count_o : out integer  );

end ns_timer;

architecture rtl of ns_timer is

   signal count_ns : integer;

   begin

      process(timer_reset_i, clk)
      begin
         if timer_reset_i = '1' then
            count_ns <= 0;
         elsif clk'event and clk = '1' then
            count_ns <= count_ns + CLOCK_PERIOD_NS;
         end if;     
      end process;
   
      timer_count_o <= count_ns;
   
   end rtl;