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
-- Project: 			Scuba 2
-- Author:  			David Atkinson
-- Organisation: 			UKATC
--
-- Description:
-- 
--
-- Revision history:
-- <date $Date: 2004/11/26 18:29:08 $> - <text> - <initials $Author: mohsen $>
--
-- $Log: wbs_frame_data_pack.vhd,v $
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

--library work;
--use work.flux_loop_pack.all;

library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;

package wbs_frame_data_pack is

constant CH_MUX_SEL_WIDTH :  integer := 3;

constant NO_CHANNELS       :  integer := 2**CH_MUX_SEL_WIDTH;
constant NO_ROWS           :  integer := 41;

constant PIXEL_ADDR_MAX    :  integer := NO_CHANNELS * NO_ROWS;
constant RAW_ADDR_MAX      :  integer := 2 * NO_CHANNELS * NO_ROWS * 64 ;

constant MODE1_FILTERED    : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0) := X"00000000";
constant MODE2_UNFILTERED  : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0) := X"00000001";
constant MODE3_FB_ERROR    : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0) := X"00000002";
constant MODE4_RAW         : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0) := X"00000003";







end package;
