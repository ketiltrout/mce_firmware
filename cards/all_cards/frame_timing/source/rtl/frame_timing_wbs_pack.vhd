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
-- $Id: frame_timing_wbs_pack.vhd,v 1.2 2005/05/06 20:02:31 bburger Exp $
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
-- $Log: frame_timing_wbs_pack.vhd,v $
-- Revision 1.2  2005/05/06 20:02:31  bburger
-- Bryce:  Added a 50MHz clock that is 180 degrees out of phase with clk_i.
-- This clk_n_i signal is used for sampling the sync_i line during the middle of the pulse, to avoid problems associated with sampling on the edges.
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

package frame_timing_wbs_pack is

end package;