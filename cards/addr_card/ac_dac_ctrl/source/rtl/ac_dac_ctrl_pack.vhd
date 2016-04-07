-- 2003 SCUBA-2 Project
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
-- $Id: ac_dac_ctrl_pack.vhd,v 1.10 2009/09/14 20:12:00 bburger Exp $
--
-- Project:       SCUBA2
-- Author:        Bryce Burger
-- Organisation:  UBC
--
-- Description:
-- 14-bit 165MS/s DAC (AD9744) controller pack file
-- This block must be coupled with frame_timing and wbs_ac_dac_ctrl blocks to work properly
--
-- Revision history:
-- $Log: ac_dac_ctrl_pack.vhd,v $
-- Revision 1.10  2009/09/14 20:12:00  bburger
-- BB: tied AC_NUM_DACS to NUM_OF_ROWS
--
-- Revision 1.9  2008/06/17 17:36:01  bburger
-- BB:  Added the AC_NUM_DACS constant
--
-- Revision 1.9  2008/05/29 21:16:41  bburger
-- BB:  Added the AC_NUM_DACS constant
--
-- Revision 1.8  2006/08/01 18:20:51  bburger
-- Bryce:  removed component declarations from header files and moved them to source files
--
-- Revision 1.7  2005/01/26 01:26:04  mandana
-- removed mem_clk_i
--
-- Revision 1.6  2004/11/20 01:20:44  bburger
-- Bryce :  fixed a bug in the ac_dac_ctrl_core block that did not load the off value of the row at the end of a frame.
--
-- Revision 1.5  2004/11/18 05:21:56  bburger
-- Bryce :  modified addr_card top level.  Added ac_dac_ctrl and frame_timing
--
-- Revision 1.4  2004/11/15 20:03:41  bburger
-- Bryce :  Moved frame_timing to the 'work' library, and physically moved the files to "all_cards" directory
--
-- Revision 1.3  2004/11/02 07:38:09  bburger
-- Bryce:  ac_dac_ctrl in progress
--
--
--
-----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library sys_param;
use sys_param.data_types_pack.all;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;

library work;
use work.addr_card_pack.all;
use work.frame_timing_pack.all;

package ac_dac_ctrl_pack is

   constant AC_NUM_DACS : integer := NUM_OF_ROWS;
   constant AC_NUM_BUSES : integer := 11;
   constant AC_BUS_WIDTH : integer := 14;
   constant ROW_COUNTER_MAX : integer := 64;

   -- The reset value is one less than the max value so that the counter does not stop, and hold reset high forever.
   constant FRAME_RESTART_DELAY_MAX : integer := 2;
   constant FRAME_RESTART_RESET : integer := 1;
   
   component tpram_32bit_x_64 port
   (
      data        : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
      wraddress   : IN STD_LOGIC_VECTOR (ROW_ADDR_WIDTH-1 DOWNTO 0);
      rdaddress_a : IN STD_LOGIC_VECTOR (ROW_ADDR_WIDTH-1 DOWNTO 0);
      rdaddress_b : IN STD_LOGIC_VECTOR (ROW_ADDR_WIDTH-1 DOWNTO 0);
      wren        : IN STD_LOGIC  := '1';
      clock       : IN STD_LOGIC ;
      qa          : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
      qb          : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
   );
   end component;   
   component tpram_14bit_x_64 port
   (
      clock       : IN STD_LOGIC ;
      data        : IN STD_LOGIC_VECTOR (13 DOWNTO 0);
      rdaddress_a : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
      rdaddress_b : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
      wraddress   : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
      wren        : IN STD_LOGIC  := '0';
      qa          : OUT STD_LOGIC_VECTOR (13 DOWNTO 0);
      qb          : OUT STD_LOGIC_VECTOR (13 DOWNTO 0)
   );
   end component;   

end ac_dac_ctrl_pack;