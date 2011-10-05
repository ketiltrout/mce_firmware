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
-- <revision control keyword substitutions e.g. $Id: frame_timing_pack.vhd,v 1.18 2011-10-05 20:05:24 mandana Exp $>
--
-- Project:     SCUBA-2
-- Author:      Bryce Burger
-- Organisation:  UBC
--
-- Description:
-- This records all of the constants needed for frame synchronization
-- on the AC, BC, RC.
--
-- Revision history:
-- <date $Date: 2011-10-05 20:05:24 $> - <text> - <initials $Author: mandana $>
-- $Log: frame_timing_pack.vhd,v $
-- Revision 1.18  2011-10-05 20:05:24  mandana
-- update_bias parameter changed to 22 which causes biases to be loaded few (20?) clock cycles after row switch
--
-- Revision 1.17  2011-06-23 16:08:36  mandana
-- modified update_bias so biias values are being pushed back by 10 clock cycles from the beginning of a row-switch
--
-- Revision 1.16  2011-05-11 21:31:35  bburger
-- BB:  Changed the parameter for pre-loading the bf_colxx Bias Card values from 42 to 10.  10 cycles are necessary to fetch the next value from memory.
--
-- Revision 1.15  2010/06/01 21:06:53  mandana
-- changed update_bias to 42 so it is asserted 42 clock cycles prior to row switch
--
-- Revision 1.14  2009/09/16 20:10:52  bburger
-- BB: re-instated 3 constants that are used in older versions of firmware
--
-- Revision 1.13  2009/09/14 19:57:24  bburger
-- BB:  Added ROW_COUNT_WIDTH and MAX_NUM_OF_ROWS for use on the Address Card.
--
-- Revision 1.12  2009/05/27 01:20:29  bburger
-- BB: corrected a comment
--
-- Revision 1.11  2009/01/16 01:33:39  bburger
-- BB: Added two default constants (DEFAULT_NUM_ROWS_REPORTED, DEFAULT_NUM_COLS_REPORTED)
--
-- Revision 1.10  2006/03/22 19:25:12  mandana
-- moved constant definitions from sync_gen_pack to frame_timing_pack
--
-- Revision 1.9  2006/02/09 20:32:59  bburger
-- Bryce:
-- - Added a fltr_rst_o output signal from the frame_timing block
-- - Adjusted the top-levels of each card to reflect the frame_timing interface change
--
-- Revision 1.8  2005/05/06 20:02:31  bburger
-- Bryce:  Added a 50MHz clock that is 180 degrees out of phase with clk_i.
-- This clk_n_i signal is used for sampling the sync_i line during the middle of the pulse, to avoid problems associated with sampling on the edges.
--
-- Revision 1.7  2005/02/19 01:21:44  mohsen
-- Changed encoding to 1000 to match with previous version that uses single pulse of 1.
--
-- Revision 1.6  2005/02/17 22:42:12  bburger
-- Bryce:  changes to synchronization in the MCE in response to two problems
-- - a rising edge on the sync line during configuration
-- - an errant pulse on the restart_frame_1row_post_o from frame_timing block
--
-- Revision 1.5  2005/01/13 03:14:51  bburger
-- Bryce:
-- addr_card and clk_card:  added slot_id functionality, removed mem_clock
-- sync_gen and frame_timing:  added custom counters and registers
--
-- Revision 1.4  2004/11/19 20:00:05  bburger
-- Bryce :  updated frame_timing and sync_gen interfaces
--
-- Revision 1.3  2004/11/18 05:21:56  bburger
-- Bryce :  modified addr_card top level.  Added ac_dac_ctrl and frame_timing
--
-- Revision 1.2  2004/11/17 01:57:32  bburger
-- Bryce :  updating the interface signal order
--
-- Revision 1.1  2004/11/15 20:03:41  bburger
-- Bryce :  Moved frame_timing to the 'work' library, and physically moved the files to "all_cards" directory
--
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
library sys_param;
use sys_param.data_types_pack.all;
use sys_param.wishbone_pack.all;

package frame_timing_pack is

   constant MUX_LINE_PERIOD        : integer := 64; -- 64 50MHz cycles
   constant MAX_NUM_OF_ROWS        : integer := 64;
   constant NUM_OF_ROWS            : integer := 41;
   constant END_OF_FRAME           : integer := (NUM_OF_ROWS*MUX_LINE_PERIOD)-1;
   constant SYNC_PULSE_BIT0        : std_logic := '1';
   constant SYNC_PULSE_BIT1        : std_logic := '0';
   constant SYNC_PULSE_BIT2        : std_logic := '0';
   constant SYNC_PULSE_BIT3        : std_logic := '0';
   constant SYNC_NUM_WIDTH         : integer := 32;
   constant ISSUE_SYNC_WIDTH       : integer := SYNC_NUM_WIDTH;
   constant ROW_COUNT_WIDTH        : integer := 16;
   
   ------------------------------------------------------------------------------------
   -- Clock Card frame structure

   -- START_OF_BLACKOUT:
   -- This value is used by the cmd_queue to determe whether it can issue a command.
   -- START_OF_BLACKOUT indicates the point in a frame at which there is not enough
   -- time remaining to send out a command and have the wishbone master parse it before
   -- data becomes invalid.
   -- During normal operation, there should be enough time in a frame to issue all
   -- required commands for normal operaiton.  However, START_OF_BLACKOUT may come
   -- into consideration if a corrupted reply was received by the reply_queue and
   -- the cmd_queue needs to reissued the corresponding u-op
   -- 800 clock cycles is about the time required to issue all the u-ops necessary
   -- during science mode, and to receive all their replies.  The cmd_queue will not
   -- restart the transmission of all u-ops pertaining to a m-op that expires at
   -- START_OF_BLACKOUT, if the blackout period has begun.  On the other hand, if the
   -- blackout period begins midway through the issue of u-ops from a single m-op, the
   -- command queue will finish issuing them.  In other words, all u-ops generated from
   -- a single m-op are treated as an atomic unit.
   constant START_OF_BLACKOUT : integer := END_OF_FRAME - 800;

   -- RETIRE_TIMEOUT indicates at what point in a frame all the commands that were
   -- in that frame must be retired.
   -- If some commands remain to be retired at the end of a frame, some type of error
   -- recovery must be initiated
   constant RETIRE_TIMEOUT    : integer := END_OF_FRAME;

   ------------------------------------------------------------------------------------
   -- Timing constants for the Readout Card
   constant END_OF_FRAME_1ROW_PREV : integer := (NUM_OF_ROWS*MUX_LINE_PERIOD)-MUX_LINE_PERIOD-1;
   constant END_OF_FRAME_1ROW_POST : integer := MUX_LINE_PERIOD-1;

   ------------------------------------------------------------------------------------
   -- UPDATE_BIAS specifies the number of clock cycles before the beginning of a new frame needed to prime the DACs with data.
   -- It takes 16 x 25MHz clock cycles or 32 clock cycles to update the DAC plus 10 clock cycles of over head, total of 42
   constant UPDATE_BIAS : integer := 10;
   
   ------------------------------------------------------------------------------------
   -- For data readout
   constant DEFAULT_NUM_ROWS_REPORTED : std_logic_vector(WB_DATA_WIDTH-1 downto 0) := x"00000029";  -- 41 Rows by default.
   constant DEFAULT_NUM_COLS_REPORTED : std_logic_vector(WB_DATA_WIDTH-1 downto 0) := x"00000008";  -- 8 Columns by default.


end frame_timing_pack;
