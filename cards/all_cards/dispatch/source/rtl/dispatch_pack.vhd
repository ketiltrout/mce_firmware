-- Copyright (c) 2003 SCUBA-2 Project
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
--
-- dispatch_pack.vhd
--
-- Project:       SCUBA-2
-- Author:         Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Package file for dispatch block
--
-- Revision history:
-- 
-- $Log: dispatch_pack.vhd,v $
-- Revision 1.12  2005/10/08 00:14:28  erniel
-- removed component declarations
-- removed unnecessary constants
--
-- Revision 1.11  2005/03/18 23:07:33  erniel
-- added constants for cmd buffer addr & data bus sizes
-- added constants for reply buffer addr & data bus sizes
-- updated all component declarations for new constants
-- removed obsolete dispatch_data_buf declaration
--
-- Revision 1.10  2005/01/11 20:51:48  erniel
-- updated dispatch_cmd_receive declaration
-- updated dispatch_reply_transmit declaration
-- updated dispatch top-level declaration
--
-- Revision 1.9  2004/12/16 01:47:44  erniel
-- added mem_clk port to disaptch_reply_transmit
--
-- Revision 1.8  2004/11/29 23:35:32  bench2
-- Greg: Added err_i and extended FIBRE_CHECKSUM_ERR to 8-bits for reply_argument in reply_translator.vhd
--
-- Revision 1.7  2004/11/26 01:35:13  erniel
-- updated dispatch_wishbone component
--
-- Revision 1.6  2004/10/13 04:37:38  erniel
-- corrected missing generic in dispatch component declaration
--
-- Revision 1.5  2004/10/13 03:57:50  erniel
-- added WATCHDOG_LIMIT constant
-- added component declaration for top-level
--
-- Revision 1.4  2004/09/27 23:00:24  erniel
-- added component declarations
-- moved constants to command_pack
--
-- Revision 1.3  2004/08/28 03:10:01  erniel
-- renamed some constants
--
-- Revision 1.2  2004/08/25 20:19:56  erniel
-- added packet field declarations
-- added buffer declarations
--
-- Revision 1.1  2004/08/04 19:43:19  erniel
-- initial version
--
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library sys_param;
use sys_param.command_pack.all;

package dispatch_pack is

end dispatch_pack;