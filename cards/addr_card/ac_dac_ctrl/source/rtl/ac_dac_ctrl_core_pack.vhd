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
-- $Id: ac_dac_ctrl_core_pack.vhd,v 1.2 2005/01/26 01:25:42 mandana Exp $
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
-- $Log: ac_dac_ctrl_core_pack.vhd,v $
-- Revision 1.2  2005/01/26 01:25:42  mandana
-- removed mem_clk_i
--
-- Revision 1.1  2004/11/20 01:20:44  bburger
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
use work.ac_dac_ctrl_wbs_pack.all;
use work.frame_timing_pack.all;

package ac_dac_ctrl_core_pack is


end ac_dac_ctrl_core_pack;