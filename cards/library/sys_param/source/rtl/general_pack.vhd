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
-- <date $Date$>	- <initials $Author$>
-- $Log$
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package general_pack is

   -- clock card global fpga clock:  50 MHz  
   -- (pls modify both parameters if you change the clock frequency)
   constant CLOCK_PERIOD_NS : integer := 20;
   constant CLOCK_PERIOD    : time    := 20 ns;
   
   -- max and min allowable DAC settings on Bias card
   constant MAX_FLUX_FB      : std_logic_vector (15 downto 0) := x"FFFF";
   constant MIN_FLUX_FB      : std_logic_vector (15 downto 0) := x"0000";
   constant MAX_BIAS         : std_logic_vector (15 downto 0) := x"FFFF";
   constant MIN_BIAS         : std_logic_vector (15 downto 0) := x"0000";
   
   -- Memory map for the dac_ctrl sram on Address card
   constant ON_VAL_BASE : std_logic_vector (7 downto 0) := x"00";
   constant OFF_VAL_BASE: std_logic_vector (7 downto 0) := x"29";
   constant ROW_ORD_BASE: std_logic_vector (7 downto 0) := x"52";
   constant MUX_ON_BASE : std_logic_vector (7 downto 0) := x"67";
      
end general_pack;