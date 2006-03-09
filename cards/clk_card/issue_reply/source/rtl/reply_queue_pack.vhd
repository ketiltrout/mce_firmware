-- Copyright (c) 2003 SCUBA-2 Project
--               All Rights Reserved
--
-- THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF THE SCUBA-2 Project
-- The copyright notice above does not evidence any
-- actual or intended publication of such source code.
--
-- SOURCE CODE IS PROVIDED "AS IS". ALL EXPRESS OR IMPLIED CONDITIONS,
-- REPRESENTATIONS, AND WARRANTIES, INCLUDING ANY IMPLIED WARRANT OF
-- MERCHANTABILITY, SATISFACTORY QUALITY, FITNESS FOR A PARTICULAR
-- PURPOSE, OR NON-INFRINGEMENT, ARE DISCLAIMED, EXCEPT TO THE EXTENT
-- THAT SUCH DISCLAIMERS ARE HELD TO BE LEGALLY INVALID.
--
-- For the purposes of this code the SCUBA-2 Project consists of the
-- following organisations.
--
-- UKATC, Royal Observatory, Blackford Hill Edinburgh EH9 3HJ
-- UBC,   University of British Columbia, Physics & Astronomy Department,
--        Vancouver BC, V6T 1Z1
--
-- $Id: reply_queue_pack.vhd,v 1.20 2006/01/16 19:03:02 bburger Exp $
--
-- Project:    SCUBA2
-- Author:     Bryce Burger, Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- This is the reply_queue pack file.
--
-- Revision history:
-- $Log: reply_queue_pack.vhd,v $
-- Revision 1.20  2006/01/16 19:03:02  bburger
-- Bryce:
-- minor bug fixes for handling crc errors and timeouts
-- moved reply_queue_receive instantiations from reply_queue to reply_queue_sequencer
--
-- Revision 1.19  2005/11/15 03:17:22  bburger
-- Bryce: Added support to reply_queue_sequencer, reply_queue and reply_translator for timeouts and CRC errors from the bus backplane
--
-- Revision 1.18  2005/03/23 19:25:54  bburger
-- Bryce:  Added a debugging trigger
--
-- Revision 1.17  2005/03/12 02:19:01  bburger
-- bryce:  bug fixes
--
-- Revision 1.16  2005/02/20 02:00:29  bburger
-- Bryce:  integrated the reply_queue and cmd_queue with respect to the timeout signal.
--
-- Revision 1.15  2005/02/20 00:50:25  erniel
-- updated reply_queue declaration
--
-- Revision 1.14  2005/02/20 00:38:39  erniel
-- changed timeout limit to 500 us
--
-- Revision 1.13  2005/02/09 20:45:02  erniel
-- added condensed header format declarations
-- added misc. reply_queue constants
-- updated reply_queue_sequencer component
-- updated reply_queue_receive component
--
-- Revision 1.12  2005/01/11 22:48:00  erniel
-- removed mem_clk_i from reply_queue_receive
-- removed mem_clk_i from reply_queue top-level
--
-- Revision 1.11  2004/12/04 02:03:06  bburger
-- Bryce:  fixing some problems associated with integrating the reply_queue
--
-- Revision 1.10  2004/12/01 18:41:32  erniel
-- fixed error code width...again
-- updated reply_queue_sequencer component
--
-- Revision 1.9  2004/11/30 22:58:47  bburger
-- Bryce:  reply_queue integration
--
-- Revision 1.8  2004/11/30 04:57:48  erniel
-- fixed error code width
--
-- Revision 1.7  2004/11/30 04:43:32  erniel
-- added components:
--    reply_queue_receiver
--    reply_queue_sequencer
--
-- Revision 1.6  2004/11/30 03:22:47  bburger
-- Bryce:  building reply_queue top-level interface and functionality
--
-- Revision 1.5  2004/11/25 01:32:37  bburger
-- Bryce:
-- - Changed to cmd_code over the bus backplane to read/write only
-- - Added interface signals for internal commands
-- - RB command data-sizes are correctly handled
--
-- Revision 1.4  2004/11/13 03:25:34  bburger
-- Bryce:  integration with ernie's side of reply_queue
--
-- Revision 1.3  2004/11/08 23:40:29  bburger
-- Bryce:  small modifications
--
-- Revision 1.2  2004/10/22 01:54:38  bburger
-- Bryce:  fixed bugs
--
-- Revision 1.1  2004/10/21 00:45:38  bburger
-- Bryce:  new
--
--
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library sys_param;
use sys_param.command_pack.all;

library work;
use work.cmd_queue_ram40_pack.all;
use work.sync_gen_pack.all;

package reply_queue_pack is

end reply_queue_pack;