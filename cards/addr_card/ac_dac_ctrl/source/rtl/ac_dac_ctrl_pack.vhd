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

-- ac_dac_ctrl_pack.vhd
--
-- Project:	      SCUBA-2
-- Author:	      Mandana Amiri
-- Organisation:      UBC
--
-- Description:
-- pack file for ac_dac_ctrl
--
-- Revision history:
-- <date $Date$>	- <initials $Author$>
-- $Log$
--
-----------------------------------------------------------------------------
library ieee, sys_param;
use ieee.std_logic_1164.all;
use sys_param.data_types_pack.all;

package ac_dac_ctrl_pack is

   -- Memory map for the dac_ctrl sram
   constant ON_VAL_BASE : std_logic_vector (7 downto 0) := x"00"; 
   constant OFF_VAL_BASE: std_logic_vector (7 downto 0) := x"2a";
   constant ROW_ORD_BASE: std_logic_vector (7 downto 0) := x"52";
   constant MUX_ON_BASE : std_logic_vector (7 downto 0) := x"6A";

   constant ROW_ORDER: int_array41 := (
    0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 
   20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 
   40   
   );
   
   type    w16_array41 is array (40 downto 0) of integer; -- for address card rows

end ac_dac_ctrl_pack;