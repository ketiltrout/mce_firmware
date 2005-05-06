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
-- $Id: frame_timing_core_pack.vhd,v 1.1 2004/11/19 20:00:05 bburger Exp $
--
-- Project:       SCUBA-2
-- Author:        Bryce Burger
-- Organisation:  UBC
--
-- Description:
-- This records all of the constants needed for frame synchronization
-- on the AC, BC, RC.
--
-- Revision history:
-- $Log: frame_timing_core_pack.vhd,v $
-- Revision 1.1  2004/11/19 20:00:05  bburger
-- Bryce :  updated frame_timing and sync_gen interfaces
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

package frame_timing_core_pack is

   component frame_timing_core is
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
      row_len_i                  : in integer; -- not used yet
      num_rows_i                 : in integer; -- not used yet
      sample_delay_i             : in integer;
      sample_num_i               : in integer;
      feedback_delay_i           : in integer;
      address_on_delay_i         : in integer;
      resync_req_i               : in std_logic;
      resync_ack_o               : out std_logic; -- not used yet
      init_window_req_i          : in std_logic;
      init_window_ack_o          : out std_logic; -- not used yet
      
      -- Global signals
      clk_i                      : in std_logic;
      clk_n_i                    : in std_logic;
      rst_i                      : in std_logic;
      sync_i                     : in std_logic
   );
   end component;


end frame_timing_core_pack;