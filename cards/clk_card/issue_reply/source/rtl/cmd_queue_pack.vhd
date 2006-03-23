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
-- $Id: cmd_queue_pack.vhd,v 1.25 2006/03/09 00:55:07 bburger Exp $
--
-- Project:       SCUBA2
-- Author:        Bryce Burger
-- Organisation:  UBC
--
-- Description:
-- Pack file for cmd_queue
--
-- Revision history:
-- $Log: cmd_queue_pack.vhd,v $
-- Revision 1.25  2006/03/09 00:55:07  bburger
-- Bryce:  Added an issue_sync_o signal to the interface so that the reply_queue can include this information in data headers
--
-- Revision 1.24  2006/01/16 18:07:33  bburger
-- Bryce:  Brand new version of the cmd_queue.  It only queue's up a single command at a time.
--
-- Revision 1.23  2005/11/15 03:17:22  bburger
-- Bryce: Added support to reply_queue_sequencer, reply_queue and reply_translator for timeouts and CRC errors from the bus backplane
--
-- Revision 1.22  2005/03/19 00:31:23  bburger
-- bryce:  Fixed several bugs.  Tagging cc_01010007.
--
-- Revision 1.21  2005/03/16 02:20:58  bburger
-- bryce:  removed mem_clk from the cmd_queue and sync_gen blocks
--
-- Revision 1.20  2005/02/20 00:13:59  bburger
-- Bryce:  added a uop_timeout signal to the interface that will tell the cmd_queue to skip a command if it times out in the reply_queue
--
-- Revision 1.19  2005/01/12 22:04:35  mandana
-- remove comm_clk_i port
--
-- Revision 1.18  2004/12/16 22:05:40  bburger
-- Bryce:  changes associated with lvds_tx and cmd_translator interface changes
--
-- Revision 1.17  2004/11/25 01:32:37  bburger
-- Bryce:
-- - Changed to cmd_code over the bus backplane to read/write only
-- - Added interface signals for internal commands
-- - RB command data-sizes are correctly handled
--
-- Revision 1.16  2004/10/29 23:09:22  bburger
-- Bryce:  Weekend update
--
-- Revision 1.15  2004/10/26 23:59:16  bburger
-- Bryce:  working out the bugs from the cmd_queue<->reply_queue interface
--
-- Revision 1.14  2004/10/08 19:45:26  bburger
-- Bryce:  Changed SYNC_NUM_WIDTH to 16, removed TIMEOUT_SYNC_WIDTH, added a command-code to cmd_queue, added two words of book-keeping information to the cmd_queue
--
-- Revision 1.13  2004/09/30 21:59:40  erniel
-- using new command_pack constants
--
-- Revision 1.12  2004/09/27 23:34:33  erniel
-- using new command_pack constants
--
-- Revision 1.11  2004/09/25 01:23:49  bburger
-- Bryce:  Added command-code, last-frame and stop-frame interfaces
--
-- Revision 1.10  2004/09/02 01:14:52  bburger
-- Bryce:  Debugging - found that crc_ena must be asserted for crc_clear to function correctly
--
-- Revision 1.9  2004/08/18 06:48:43  bench2
-- Bryce: removed unnecessary interface signals between the cmd_queue and the reply_queue.
--
-- Revision 1.8  2004/08/04 17:26:43  bburger
-- Bryce:  In progress
--
-- Revision 1.7  2004/07/22 23:43:31  bench2
-- Bryce: in progress
--
-- Revision 1.6  2004/07/22 20:39:08  bench2
-- Bryce: in progress
--
-- Revision 1.5  2004/06/30 23:10:53  bburger
-- in progress
--
-- Revision 1.4  2004/06/16 17:02:36  bburger
-- in progress
--
-- Revision 1.3  2004/05/31 21:55:49  mandana
-- syntax fix
--
-- Revision 1.2  2004/05/31 21:23:19  bburger
-- in progress
--
-- Revision 1.1  2004/05/25 21:26:29  bburger
-- pack file
--
--
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library sys_param;
use sys_param.command_pack.all;

library work;
use work.sync_gen_pack.all;
use work.cmd_queue_ram40_pack.all;
use work.frame_timing_pack.all;

package cmd_queue_pack is
   
constant MAX_NUM_UOPS     : integer :=   3;

-- Calculated constants for inputing data on the correct lines into/out-of the queue
-- The following fields make up the first four lines of each u-op entry in the queue:
constant NUM_NON_BB_CMD_HEADER_WORDS : integer := 2;
constant BB_NUM_CMD_HEADER_WORDS : integer := 2;
constant CQ_NUM_CMD_HEADER_WORDS : integer := BB_NUM_CMD_HEADER_WORDS + NUM_NON_BB_CMD_HEADER_WORDS;

-- Line 1:
-- ISSUE_SYNC_WIDTH (16 bits),
-- COMMAND_TYPE_END (3 bits),
-- CQ_DATA_SIZE_BUS_WIDTH (13 bits)
constant ISSUE_SYNC_END   : integer := QUEUE_WIDTH - ISSUE_SYNC_WIDTH;
constant COMMAND_TYPE_END : integer := QUEUE_WIDTH - ISSUE_SYNC_WIDTH - BB_COMMAND_TYPE_WIDTH;
constant DATA_SIZE_END    : integer := QUEUE_WIDTH - ISSUE_SYNC_WIDTH - BB_COMMAND_TYPE_WIDTH - BB_DATA_SIZE_WIDTH;

-- Line 2:
-- BB_CARD_ADDRESS_WIDTH (8 bits),
-- BB_PARAMETER_ID_WIDTH (8 bits),
-- BB_MACRO_OP_SEQ_WIDTH (8 bits),
-- BB_MICRO_OP_SEQ_WIDTH (8 bits)
constant CARD_ADDR_END    : integer := QUEUE_WIDTH - BB_CARD_ADDRESS_WIDTH;
constant PARAM_ID_END     : integer := QUEUE_WIDTH - BB_CARD_ADDRESS_WIDTH - BB_PARAMETER_ID_WIDTH;
--constant MOP_END          : integer := QUEUE_WIDTH - BB_CARD_ADDRESS_WIDTH - BB_PARAMETER_ID_WIDTH - BB_MACRO_OP_SEQ_WIDTH;
--constant UOP_END          : integer := QUEUE_WIDTH - BB_CARD_ADDRESS_WIDTH - BB_PARAMETER_ID_WIDTH - BB_MACRO_OP_SEQ_WIDTH - BB_MICRO_OP_SEQ_WIDTH;

-- Line 3:
-- 'Data Frame Stop' bit (bit 1)
-- 'Last Data Frame' bit (bit 0)

-- Line 4:
-- Data Frame Sequence Number (32 bits)   

end cmd_queue_pack;