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
-- <revision control keyword substitutions e.g. $Id: frame_timing_pack.vhd,v 1.1 2004/11/15 20:03:41 bburger Exp $>
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
-- <date $Date: 2004/11/15 20:03:41 $> - <text> - <initials $Author: bburger $>
-- $Log: frame_timing_pack.vhd,v $
-- Revision 1.1  2004/11/15 20:03:41  bburger
-- Bryce :  Moved frame_timing to the 'work' library, and physically moved the files to "all_cards" directory
--
-- Revision 1.16  2004/11/02 07:38:09  bburger
-- Bryce:  ac_dac_ctrl in progress
--
-- Revision 1.15  2004/10/26 18:59:24  bburger
-- Bryce:  More signals
--
-- Revision 1.14  2004/10/23 02:28:48  bburger
-- Bryce:  Work out a couple of bugs to do with the initialization window
--
-- Revision 1.13  2004/10/22 01:55:31  bburger
-- Bryce:  adding timing signals for RC flux_loop
--
-- Revision 1.12  2004/08/28 01:46:05  bburger
-- Bryce:  The end_of_frame parameter wasn't right
--
-- Revision 1.11  2004/08/25 01:31:45  bburger
-- Bryce:  just spacing
--
-- Revision 1.10  2004/08/20 23:59:45  bburger
-- Bryce:  now expects sync pulses on the last clock cycle in a frame, and restarts clk_count on the next cycle in a frame
--
-- Revision 1.9  2004/08/04 17:12:14  bburger
-- Bryce:  END_OF_FRAME finishes at 41*61-1 instead of 41*61.
--
-- Revision 1.8  2004/07/29 00:23:44  mandana
-- Add num. of rows as a constant
--
-- Revision 1.7  2004/06/19 01:17:26  bburger
-- changed the BLACKOUT_PERIOD parameter
--
-- Revision 1.6  2004/05/14 22:55:59  mandana
-- UPDATE_BIAS was declared twice
--
-- Revision 1.5  2004/05/14 21:10:06  mandana
-- changed frame_timing values to integer(Bias_count)
--
-- Revision 1.4  2004/05/13 00:09:10  bburger
-- added a few timing parameters for the clock card
--
-- Revision 1.3  2004/04/16 21:58:43  bburger
-- changed port names
--
-- Revision 1.2  2004/04/16 00:41:16  bburger
-- renamed some signals
--
-- Revision 1.1  2004/04/14 21:56:40  jjacob
-- new directory structure
--
-- Revision 1.6  2004/04/14 20:14:14  bburger
-- no message
--
-- Revision 1.5  2004/04/02 01:12:04  bburger
-- added a log field to header
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

package frame_timing_pack is

   constant MUX_LINE_PERIOD        : integer := 64; -- 64 50MHz cycles
   constant NUM_OF_ROWS            : integer := 41;
   constant END_OF_FRAME           : integer := (NUM_OF_ROWS*MUX_LINE_PERIOD)-1;
   
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
   -- Bias Card begins updating its bias values on the second clock cycle of a frame
   constant UPDATE_BIAS : integer := 2;
   
   ------------------------------------------------------------------------------------
--   -- Address Card frame structure
--   constant SEL_ROW : int_array41:= (
--    0*MUX_LINE_PERIOD, 1*MUX_LINE_PERIOD, 2*MUX_LINE_PERIOD, 3*MUX_LINE_PERIOD, 4*MUX_LINE_PERIOD,
--    5*MUX_LINE_PERIOD, 6*MUX_LINE_PERIOD, 7*MUX_LINE_PERIOD, 8*MUX_LINE_PERIOD, 9*MUX_LINE_PERIOD,
--   10*MUX_LINE_PERIOD,11*MUX_LINE_PERIOD,12*MUX_LINE_PERIOD,13*MUX_LINE_PERIOD,14*MUX_LINE_PERIOD,
--   15*MUX_LINE_PERIOD,16*MUX_LINE_PERIOD,17*MUX_LINE_PERIOD,18*MUX_LINE_PERIOD,19*MUX_LINE_PERIOD,
--   20*MUX_LINE_PERIOD,21*MUX_LINE_PERIOD,22*MUX_LINE_PERIOD,23*MUX_LINE_PERIOD,24*MUX_LINE_PERIOD,
--   25*MUX_LINE_PERIOD,26*MUX_LINE_PERIOD,27*MUX_LINE_PERIOD,28*MUX_LINE_PERIOD,29*MUX_LINE_PERIOD,
--   30*MUX_LINE_PERIOD,31*MUX_LINE_PERIOD,32*MUX_LINE_PERIOD,33*MUX_LINE_PERIOD,34*MUX_LINE_PERIOD,
--   35*MUX_LINE_PERIOD,36*MUX_LINE_PERIOD,37*MUX_LINE_PERIOD,38*MUX_LINE_PERIOD,39*MUX_LINE_PERIOD,
--   40*MUX_LINE_PERIOD);
--    
   ------------------------------------------------------------------------------------
   -- Frame Timing Interface

   component frame_timing is
   port(
      -- Global signals
      clk_i                      : in std_logic;
      rst_i                      : in std_logic;
      sync_i                     : in std_logic;
      frame_rst_i                : in std_logic;
      
      -- Readout Card
      dac_dat_en_o               : out std_logic;
      adc_coadd_en_o             : out std_logic;
      restart_frame_1row_prev_o  : out std_logic;
      restart_frame_aligned_o    : out std_logic; 
      restart_frame_1row_post_o  : out std_logic;
      initialize_window_o        : out std_logic;
      
      -- Address Card
      row_switch_o               : out std_logic;
      row_en_o                   : out std_logic;
         
      -- Bias Card
      update_bias_o              : out std_logic;
      
      -- frame_timing_wbs
      sample_num_i               : in integer;
      sample_delay_i             : in integer;
      feedback_delay_i           : in integer;
      address_on_delay_i         : in integer;
      init_window_req_i          : in std_logic;
      init_window_ack_o          : out std_logic
   );
   end component;


end frame_timing_pack;