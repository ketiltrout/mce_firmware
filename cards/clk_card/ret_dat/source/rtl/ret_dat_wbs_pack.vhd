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
-- $Id: ret_dat_wbs_pack.vhd,v 1.11 2008/12/22 20:51:50 bburger Exp $
--
-- Project:       SCUBA2
-- Author:        Bryce Burger
-- Organisation:  UBC
--
-- Description:
-- Wishbone interface for a 14-bit 165MS/s DAC (AD9744) controller
-- This block was written to be coupled with wbs_ac_dac_ctrl
--
-- Revision history:
-- $Log: ret_dat_wbs_pack.vhd,v $
-- Revision 1.11  2008/12/22 20:51:50  bburger
-- BB:  Added a constant for reading out column data from the Readout Cards.
--
-- Revision 1.10  2008/10/25 00:24:54  bburger
-- BB:  Added support for RCS_TO_REPORT_DATA command
--
-- Revision 1.9  2008/10/17 00:34:38  bburger
-- BB:  added the constant DEFAULT_CARDS_TO_REPORT
--
-- Revision 1.8  2007/08/28 23:28:56  bburger
-- BB:  Added the following constants for ramping and frame-rate data:
-- constant DEFAULT_NUM_ROWS_TO_READ : std_logic_vector(WB_DATA_WIDTH-1 downto 0) := x"00000029";  -- 41 Rows by default.
-- constant DEFAULT_STEP_DATA_NUM    : std_logic_vector(WB_DATA_WIDTH-1 downto 0) := x"00000001";  -- Then default number of data words to be send in the ramp command.
--
-- Revision 1.7  2006/09/21 16:18:36  bburger
-- Bryce:  Corrected a comment
--
-- Revision 1.6  2006/05/04 23:10:08  bburger
-- Bryce adjusted the default data_rate to be approximately 202 Hz
--
-- Revision 1.5  2006/03/16 00:23:07  bburger
-- Bryce:  removed the ret_dat_wbs component declaration
--
-- Revision 1.4  2006/03/09 01:27:21  bburger
-- Bryce:
-- - ret_dat_wbs no longer clamps the data_rate
-- - ret_dat_wbs_pack defines a default data rate of ~200Hz based on row_len=120 and num_rows=41
--
-- Revision 1.3  2006/01/16 18:00:44  bburger
-- Bryce:  Adjusted the upper and lower bounds for data_rate, and added a default value of 0x5F = 95 = data at 200 Hz based on 50 Mhz/41rows/64cycles per row
--
-- Revision 1.2  2005/03/19 00:31:23  bburger
-- bryce:  Fixed several bugs.  Tagging cc_01010007.
--
-- Revision 1.1  2005/03/05 01:31:36  bburger
-- Bryce:  New
--
-- Revision 1.3  2005/01/26 01:27:20  mandana
-- removed mem_clk_i
--
-- Revision 1.2  2004/12/21 22:06:51  bburger
-- Bryce:  update
--
-- Revision 1.1  2004/11/18 05:21:56  bburger
-- Bryce :  modified addr_card top level.  Added ac_dac_ctrl and frame_timing
--
-- Revision 1.4  2004/11/06 03:12:01  bburger
-- Bryce:  debugging
--
-- Revision 1.3  2004/11/02 07:38:09  bburger
-- Bryce:  ac_dac_ctrl in progress
--
--
-----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;

library work;
use work.sync_gen_pack.all;

package ret_dat_wbs_pack is

   -- Data rate is calculated as "1 data packet per x frames".  A smaller x values yields a larger data rate, and vice versa
   constant MIN_DATA_RATE            : std_logic_vector(WB_DATA_WIDTH-1 downto 0) := x"0000FFFF";
   constant MAX_DATA_RATE            : std_logic_vector(WB_DATA_WIDTH-1 downto 0) := x"00000001";
   constant DEFAULT_DATA_RATE        : std_logic_vector(WB_DATA_WIDTH-1 downto 0) := x"0000002F";  -- 202.71 Hz Based on 41 rows, 120 cycles per row, 20ns per cycle
   -- All four RCs are set to report by default
   constant DEFAULT_RCS_TO_REPORT    : std_logic_vector(WB_DATA_WIDTH-1 downto 0) := x"0000003C";
   constant DEFAULT_CARDS_TO_REPORT  : std_logic_vector(WB_DATA_WIDTH-1 downto 0) := x"000003FF";
   constant DEFAULT_STEP_DATA_NUM    : std_logic_vector(WB_DATA_WIDTH-1 downto 0) := x"00000001";  -- Then default number of data words to be send in the ramp command.

end package;