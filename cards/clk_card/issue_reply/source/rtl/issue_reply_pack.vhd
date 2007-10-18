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
-- $Id: issue_reply_pack.vhd,v 1.54 2007/08/28 23:22:08 bburger Exp $
--
-- Project:    SCUBA2
-- Author:     Greg Dennis
-- Organization:  UBC
--
-- Description:
-- Declares a few constants used as parameters in the fibre_rx block
--
-- Revision history:
-- $Log: issue_reply_pack.vhd,v $
-- Revision 1.54  2007/08/28 23:22:08  bburger
-- BB:  Renamed INTERNAL_COMMAND_PERIOD to HOUSEKEEPING_COMMAND_PERIOD
--
-- Revision 1.53  2007/07/24 22:55:44  bburger
-- BB:
-- - Updated the constants in this file to be consistent with the new protocol, to fix bugs, to suport internal commands and to implement a warning mask.
--
-- Revision 1.52  2006/11/07 23:50:18  bburger
-- Bryce:  modified some of the constants
--
-- Revision 1.51  2006/10/28 00:06:46  bburger
-- Bryce:  Changed the command timeout limits
--
-- Revision 1.50  2006/10/19 22:19:32  bburger
-- Bryce:  Interim committal
--
-- Revision 1.49  2006/09/28 00:32:25  bburger
-- Bryce:  Caught a bug that specified the TES_BIAS_DATA_SIZE = 32.
--
-- Revision 1.48  2006/09/26 02:16:05  bburger
-- Bryce: added busy_i interface for arbitration between ret_dat, internal and simple commands
--
-- Revision 1.47  2006/09/21 16:15:16  bburger
-- Bryce:  added constants for internal commands
--
-- Revision 1.46  2006/09/15 00:36:11  bburger
-- Bryce:  Added internal_cmd_window between ret_dat_fsm and arbiter_fsm
--
-- Revision 1.45  2006/03/16 00:21:28  bburger
-- Bryce:  removed the issue_reply component declaration
--
-- Revision 1.44  2006/03/09 01:04:37  bburger
-- Bryce:
-- - cmd_translator interface now takes the following signals:  dv_mode_i, external_dv_i, external_dv_num_i
-- - cmd_queue communicates the issue_sync to reply_queue
--
-- Revision 1.43  2006/02/11 01:19:33  bburger
-- Bryce:  Added the following signal interfaces to implement responding to external dv pulses
-- data_req
-- data_ack
-- frame_num_external
--
-- Revision 1.42  2006/01/16 18:58:05  bburger
-- Ernie:
-- Added component declarations
-- Updated the interfaces to issue_reply sub-blocks
--
-- Revision 1.41  2005/03/19 00:31:23  bburger
-- bryce:  Fixed several bugs.  Tagging cc_01010007.
--
-- Revision 1.40  2005/03/16 02:20:58  bburger
-- bryce:  removed mem_clk from the cmd_queue and sync_gen blocks
--
-- Revision 1.39  2005/03/04 03:45:58  bburger
-- Bryce:  fixed bugs associated with ret_dat_s and ret_dat
--
-- Revision 1.38  2005/01/12 22:18:24  mandana
-- added comm_clk_i (shouldn't have removed it!)
--
-- Revision 1.37  2005/01/12 21:53:01  mandana
-- Updated cmd_queue interface by deleting comm_clk_i
--
-- Revision 1.36  2004/11/30 22:58:47  bburger
-- Bryce:  reply_queue integration
--
-- Revision 1.35  2004/11/24 01:15:52  bench2
-- Greg: Broke apart issue reply and created pack files for all of its sub-components
--
--
--
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;

library work;
use work.sync_gen_pack.all;

package issue_reply_pack is

   -- Measured in clock cycles, CMD_TIMEOUT_LIMIT is slightly more than the amount of cycles necessary for an internal/ simple command to execute
   -- For a 58-word WB command, 100 us are required from receiving the last word of the command to sending the last word of the reply
   -- For a 58-word RB command, 105 us are required from receiving the last word of the command to sending the last word of the reply.
--   constant CMD_TIMEOUT_LIMIT : integer := 110; --us
   constant CMD_TIMEOUT_LIMIT : integer := 150; --us

   -- This should be dependent on row_len and num_rows!
--   constant DATA_TIMEOUT_LIMIT : integer := 650; --us
   constant DATA_TIMEOUT_LIMIT : integer := 1000; --us

   -- The minimum window for transmitting an internal command needs to be slightly more than CMD_TIMEOUT_LIMIT
   -- To account for the time needed to prime the cmd_translator
   constant MIN_WINDOW : integer := (CMD_TIMEOUT_LIMIT+5)*1000/20; -- # clock cycles = (110us+5us)*1000/20ns = 5750;

   -- Period of internal commands
   constant HOUSEKEEPING_COMMAND_PERIOD : integer := 1000000;

   -- Data sizes for internal commands
   constant TES_BIAS_DATA_SIZE   : std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0) := "00000000001"; --  1 word
   constant FPGA_TEMP_DATA_SIZE  : std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0) := "00000000001"; --  1 word
   constant CARD_TEMP_DATA_SIZE  : std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0) := "00000000001"; --  1 word
   constant PSC_STATUS_DATA_SIZE : std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0) := "00000001001"; --  9 words
   constant BOX_TEMP_DATA_SIZE   : std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0) := "00000000001"; --  1 word

   -- number of frame header words stored in RAM
   constant NUM_RAM_HEAD_WORDS  : integer := 43;
   constant RAM_HEAD_ADDR_WIDTH : integer :=  6;

   constant FPGA_TEMP_SIZE  : integer := 10; -- Includes space for fpga_temp errno word
   constant CARD_TEMP_SIZE  : integer := 10; -- Includes space for fpga_temp errno word
   constant PSC_STATUS_SIZE : integer :=  8; -- Includes space for card_temp errno word
   constant BOX_TEMP_SIZE   : integer :=  2; -- Includes space for fpga_temp errno word

   -- The logical AND of this word with the status word filters out the warnings from the status word,
   -- leaving only the errors.
   constant STATUS_WORD_WARNING_MASK : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0) :=   "00011011011011011011011011011011"; --"00010010010010010010010010010010";

   -- This is the data pipeline propagation delay setting for the reply_translator
   constant DATA_PROPAGATION_DELAY : integer := 2;

end issue_reply_pack;
