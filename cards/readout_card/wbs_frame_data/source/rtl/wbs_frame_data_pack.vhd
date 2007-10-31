-- Copyright (c) 2003 SCUBA-2 Project
-- All Rights Reserved
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
-- UBC, University of British Columbia, Physics & Astronomy Department,
-- Vancouver BC, V6T 1Z1
--
-- wbs_frame_data_pack.vhd
--
--
-- Project:          Scuba 2
-- Author:           David Atkinson
-- Organisation:        UKATC
--
-- Description:
-- 
--
-- Revision history:
-- <date $Date: 2007/10/24 22:51:27 $> - <text> - <initials $Author: mandana $>
--
-- $Log: wbs_frame_data_pack.vhd,v $
-- Revision 1.12  2007/10/24 22:51:27  mandana
-- added ch_mux_init
-- added data mode 7 for mixed filtfb/error
-- added data mode 8 for mixed filtfb/flux count
--
-- Revision 1.11  2007/06/16 03:31:17  mandana
-- added data_mode=6 for 18b filtered fb + 14b error
--
-- Revision 1.10  2007/02/19 20:20:01  mandana
-- clean up, removed redundant no_rows constant
--
-- Revision 1.9  2006/06/09 22:25:10  bburger
-- Bryce:  Moved the no_channels constant from wbs_frame_data_pack to command_pack so that the clock card could use it.  I also modified flux_loop_pack to use no_channels instead of a literal value of 8.
--
-- Revision 1.8  2005/12/13 00:51:08  mandana
-- reorganized the data modes, added data mode for filtering and for mixed feedback and flux-count
--
-- Revision 1.7  2005/06/23 17:31:56  mohsen
-- MA/BB: RAW_ADDR_MAX changed to 8192 which is the maximum size of raw memory bank
--
-- Revision 1.6  2004/12/07 19:37:46  mohsen
-- Anthony & Mohsen: Restructured constant declaration.  Moved shared constants from lower level package files to the upper level ones.  This was done to resolve compilation error resulting from shared constants defined in multiple package files.
--
-- Revision 1.5  2004/11/26 18:29:08  mohsen
-- Anthony & Mohsen: Restructured constant declaration.  Moved shared constants from lower level package files to the upper level ones.  This was done to resolve compilation error resulting from shared constants defined in multiple package files.
--
-- Revision 1.4  2004/10/26 16:13:41  dca
-- no message
--
-- Revision 1.3  2004/10/20 13:50:11  dca
-- channel range changed from 1-->8 to 0-->7
--
-- Revision 1.2  2004/10/19 14:30:39  dca
-- raw data addressing changed.
-- MUX structure changed
--
-- Revision 1.1  2004/10/18 16:35:36  dca
-- initial version
--

--
-- 
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.readout_card_pack.all;
use work.flux_loop_pack.all;
use work.frame_timing_pack.all; -- anomoly, just for NUM_OF_ROWS

library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;

package wbs_frame_data_pack is

constant CH_MUX_SEL_WIDTH  : integer := 3;
constant DAT_MUX_SEL_WIDTH : integer := 4;

constant PIXEL_ADDR_MAX    : integer := NO_CHANNELS * NUM_OF_ROWS;

constant RAW_ADDR_MAX      : integer := NO_CHANNELS * (2**RAW_ADDR_WIDTH);

constant CH_MUX_INIT       : std_logic_vector(CH_MUX_SEL_WIDTH-1 downto 0) := (others => '0');

constant MODE0_ERROR       : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0) := X"00000000";
constant MODE1_UNFILTERED  : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0) := X"00000001";
constant MODE2_FILTERED    : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0) := X"00000002";
constant MODE3_RAW         : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0) := X"00000003";
constant MODE4_FB_ERROR    : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0) := X"00000004";
constant MODE5_FB_FLX_CNT  : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0) := X"00000005";
constant MODE6_FILT_ERROR  : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0) := X"00000006";
constant MODE7_FILT_ERROR2 : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0) := X"00000007";
constant MODE9_FILT_FLX_CNT: std_logic_vector (PACKET_WORD_WIDTH-1 downto 0) := X"00000009";

end package;
