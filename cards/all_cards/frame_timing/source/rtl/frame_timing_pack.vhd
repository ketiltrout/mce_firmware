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
-- <revision control keyword substitutions e.g. $Id: frame_timing_pack.vhd,v 1.4 2004/11/19 20:00:05 bburger Exp $>
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
-- <date $Date: 2004/11/19 20:00:05 $> - <text> - <initials $Author: bburger $>
-- $Log: frame_timing_pack.vhd,v $
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
   constant UPDATE_BIAS : integer := 0;
   
   ------------------------------------------------------------------------------------
   -- Frame Timing Interface

   component frame_timing is
   port(
      -- Readout Card interface
      dac_dat_en_o               : out std_logic;
      adc_coadd_en_o             : out std_logic;
      restart_frame_1row_prev_o  : out std_logic;
      restart_frame_aligned_o    : out std_logic; 
      restart_frame_1row_post_o  : out std_logic;
      initialize_window_o        : out std_logic;
      
      -- Address Card interface
      row_switch_o               : out std_logic;
      row_en_o                   : out std_logic;
         
      -- Bias Card interface
      update_bias_o              : out std_logic;
      
      -- Wishbone interface
      dat_i                      : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      addr_i                     : in std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
      tga_i                      : in std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
      we_i                       : in std_logic;
      stb_i                      : in std_logic;
      cyc_i                      : in std_logic;
      dat_o                      : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      ack_o                      : out std_logic;      
      
      -- Global signals
      clk_i                      : in std_logic;
      mem_clk_i                  : in std_logic;
      rst_i                      : in std_logic;
      sync_i                     : in std_logic
   );
   end component;


end frame_timing_pack;