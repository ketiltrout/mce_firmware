-- 2003 SCUBA-2 Project
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

-- general_pack.vhd
--
-- Project:	      SCUBA-2
-- Author:	      Mandana Amiri
-- Organisation:      UBC
--
-- Description:
-- pack file for general_pack
--
-- Revision history:
-- <date $Date: 2004/07/29 23:45:20 $>	- <initials $Author: mandana $>
-- $Log: general_pack.vhd,v $
-- Revision 1.4  2004/07/29 23:45:20  mandana
-- moved address card constants to ac_dac_ctrl_pack.vhd
--
-- Revision 1.3  2004/07/29 00:24:41  mandana
-- add AC parameters
--
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package general_pack is

   -- NOTE: please modify both parameters if you change a clock frequency
   
   -- clock card global fpga clock:  50 MHz  
   constant CLOCK_PERIOD_PS    : integer := 20000;
   constant CLOCK_PERIOD       : time    := 20000 ps;
   
   -- clock card global fpga clock:  200 MHz     
   constant MEM_CLK_PERIOD_PS  : integer := 5000;
   constant MEM_CLK_PERIOD     : time    := 5000 ps;
   
   -- clock card global fpga clock:  400 MHz     
   constant COMM_CLK_PERIOD_PS : integer := 2500;
   constant COMM_CLK_PERIOD    : time    := 2500 ps;
         
end general_pack;