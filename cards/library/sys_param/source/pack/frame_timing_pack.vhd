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

-- frame_timing_pack.vhd
--
-- <revision control keyword substitutions e.g. $Id: frame_timing_pack.vhd,v 1.5 2004/04/02 01:12:04 bburger Exp $>
--
-- Project:		 SCUBA-2
-- Author:		 Bryce Burger
-- Organisation:	UBC
--
-- Description:
-- This records all of the constants needed for frame synchronization 
-- on the AC, BC, RC.
--
-- Revision history:
-- <date $Date: 2004/04/02 01:12:04 $> - <text> - <initials $Author: bburger $>
-- $Log: frame_timing_pack.vhd,v $
-- Revision 1.5  2004/04/02 01:12:04  bburger
-- added a log field to header
--
--
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-- This package contains the timing information for the cards in the 
-- MCE that need to be synchronized to an overall frame structure.
-- The frame structure is resolved to 50Mhz clock cycles.
-- If the resolution freqency changes, then all the constants below 
-- will need to be adjusted.
-- Multiplexing by the MCE will occur at 781.250kHz, meaning that 
-- address-dwell times will be 1.280us or the duration of 64 50MHz 
-- cycles.
package frame_timing_pack is

   constant MUX_LINE_PERIOD : integer := 64;  -- 64 50MHz cycles
   constant END_OF_FRAME    : integer := 8;--(41*MUX_LINE_PERIOD);

   -- Bias Card frame structure   
   constant UPDATE_BIAS : integer := 0;

   -- Address Card frame structure
   constant SEL_ROW0  : integer :=  0*MUX_LINE_PERIOD;
   constant SEL_ROW1  : integer :=  1*MUX_LINE_PERIOD;
   constant SEL_ROW2  : integer :=  2*MUX_LINE_PERIOD;
   constant SEL_ROW3  : integer :=  3*MUX_LINE_PERIOD;
   constant SEL_ROW4  : integer :=  4*MUX_LINE_PERIOD;
   constant SEL_ROW5  : integer :=  5*MUX_LINE_PERIOD;
   constant SEL_ROW6  : integer :=  6*MUX_LINE_PERIOD;
   constant SEL_ROW7  : integer :=  7*MUX_LINE_PERIOD;
   constant SEL_ROW8  : integer :=  8*MUX_LINE_PERIOD;
   constant SEL_ROW9  : integer :=  9*MUX_LINE_PERIOD;
   constant SEL_ROW10 : integer := 10*MUX_LINE_PERIOD;
   constant SEL_ROW11 : integer := 11*MUX_LINE_PERIOD;
   constant SEL_ROW12 : integer := 12*MUX_LINE_PERIOD;
   constant SEL_ROW13 : integer := 13*MUX_LINE_PERIOD;
   constant SEL_ROW14 : integer := 14*MUX_LINE_PERIOD;
   constant SEL_ROW15 : integer := 15*MUX_LINE_PERIOD;
   constant SEL_ROW16 : integer := 16*MUX_LINE_PERIOD;
   constant SEL_ROW17 : integer := 17*MUX_LINE_PERIOD;
   constant SEL_ROW18 : integer := 18*MUX_LINE_PERIOD;
   constant SEL_ROW19 : integer := 19*MUX_LINE_PERIOD;
   constant SEL_ROW20 : integer := 20*MUX_LINE_PERIOD;
   constant SEL_ROW21 : integer := 21*MUX_LINE_PERIOD;
   constant SEL_ROW22 : integer := 22*MUX_LINE_PERIOD;
   constant SEL_ROW23 : integer := 23*MUX_LINE_PERIOD;
   constant SEL_ROW24 : integer := 24*MUX_LINE_PERIOD;
   constant SEL_ROW25 : integer := 25*MUX_LINE_PERIOD;
   constant SEL_ROW26 : integer := 26*MUX_LINE_PERIOD;
   constant SEL_ROW27 : integer := 27*MUX_LINE_PERIOD;
   constant SEL_ROW28 : integer := 28*MUX_LINE_PERIOD;
   constant SEL_ROW29 : integer := 29*MUX_LINE_PERIOD;
   constant SEL_ROW30 : integer := 30*MUX_LINE_PERIOD;
   constant SEL_ROW31 : integer := 31*MUX_LINE_PERIOD;
   constant SEL_ROW32 : integer := 32*MUX_LINE_PERIOD;
   constant SEL_ROW33 : integer := 33*MUX_LINE_PERIOD;
   constant SEL_ROW34 : integer := 34*MUX_LINE_PERIOD;
   constant SEL_ROW35 : integer := 35*MUX_LINE_PERIOD;
   constant SEL_ROW36 : integer := 36*MUX_LINE_PERIOD;
   constant SEL_ROW37 : integer := 37*MUX_LINE_PERIOD;
   constant SEL_ROW38 : integer := 38*MUX_LINE_PERIOD;
   constant SEL_ROW39 : integer := 39*MUX_LINE_PERIOD;
   constant SEL_ROWDARK : integer := 40*MUX_LINE_PERIOD;
   
   component frame_timing is
      port(
         clk_i              : in std_logic;
         sync_i             : in std_logic;
         rst_on_next_sync_i : in std_logic;
         cycle_count_o      : out std_logic_vector(31 downto 0);
         cycle_error_o      : out std_logic_vector(31 downto 0)
      );
   end component;
   
   
end frame_timing_pack;