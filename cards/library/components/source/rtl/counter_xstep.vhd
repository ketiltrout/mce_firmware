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

-- counter.vhd
--
-- <revision control keyword substitutions e.g. $Id: counter_xstep.vhd,v 1.1 2004/04/23 00:54:46 mandana Exp $>
--
-- Project:	      SCUBA-2
-- Author:	       Ernie Lin/Mandana Amiri
-- Organisation:  UBC
--
-- Description:
-- generic integer up counter with asynch. reset, count enable and counting step specified
--
-- Revision history:
-- <date $Date: 2004/04/23 00:54:46 $>	- <initials $Author: mandana $>
-- $Log: counter_xstep.vhd,v $
-- Revision 1.1  2004/04/23 00:54:46  mandana
-- added counter_xstep counts 'step' at each clock.
--   
--
-----------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity counter_xstep is
generic(MAX : integer := 255);
port(clk_i   : in std_logic;
     rst_i   : in std_logic;
     ena_i   : in std_logic;
     step_i  : in integer;
     count_o : out integer);
end counter_xstep;

architecture behav of counter_xstep is
begin
   process(clk_i, rst_i, ena_i,step_i)
   variable count : integer;
   begin
      if(rst_i = '1') then
            -- asynchronous reset to lower limit:
            count := 0;
      elsif(clk_i'event and clk_i = '1') then
         if(ena_i = '1') then
            -- if counter is enabled...
               -- do synchronous count up:
               count := count + step_i;
         end if;
      end if;
      
      -- implement counter wrap-around:
      if(count > MAX) then
         count := 0;
      elsif(count < 0) then
         count := MAX;
      end if;
      
      count_o <= count;
   end process;
   
end behav;