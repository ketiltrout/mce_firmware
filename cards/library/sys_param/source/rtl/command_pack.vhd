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
-- command_pack.vhd
--
-- Project:       SCUBA-2
-- Author:        Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Package file for command processing blocks
--
-- Revision history:
--
-- $Log: command_pack.vhd,v $
-- Revision 1.25  2010/05/15 00:42:29  bburger
-- BB: Re-introduced two constants that had been deleted, so that I can simulate cards that use the old constants.
--
-- Revision 1.24  2010/01/19 23:03:02  mandana
-- BC_CARD_TYPE and RC_CARD_TYPE are now managed by card_type.vhd generated through tcl file.
--
-- Revision 1.23  2008/02/22 01:34:12  bburger
-- BB: Renamed "PSCUC_CARD" to "PS_CARD"
--
-- Revision 1.22  2008/01/26 01:12:16  mandana
-- added support for card_type
-- renamed ALL_CARDS to ALL_MCE_CARDS to avoid conflict with all_cards wishbone slave
--
-- Revision 1.21  2006/07/17 14:34:38  bburger
-- Bryce:  modified FIBRE_NO_ERROR_STATUS for new fibre protocol
--
-- Revision 1.20  2006/06/09 22:22:59  bburger
-- Bryce:  Moved the no_channels constant from wbs_frame_data_pack to command_pack so that the clock card could use it.  I also modified flux_loop_pack to use no_channels instead of a literal value of 8.
--
-- Revision 1.19  2005/11/23 18:20:44  erniel
-- brought back PACKET_WORD_WIDTH constant
-- changed FIBRE_PREAMBLE1 and FIBRE_PREAMBLE2 to 32 bits
--
-- Revision 1.18  2005/11/21 23:35:09  erniel
-- temporary version (to maintain compatibility with previous version)
--
-- Revision 1.17  2005/11/18 20:43:16  erniel
-- removed obsolete parameters:
--      PACKET_WORD_WIDTH
--      BB_NUM_CMD_HEADER_WORDS
--      BB_NUM_REPLY_HEADER_WORDS
-- modified bus backplane parameter definitions:
--      BB_PREAMBLE
--      BB_COMMAND_TYPE
--      BB_DATA_SIZE
--
-- Revision 1.16  2005/11/15 03:28:04  bburger
-- Bryce: Added support to reply_queue_sequencer, reply_queue and reply_translator for timeouts and CRC errors from the bus backplane
--
-- Revision 1.15  2005/10/28 01:44:17  erniel
-- updated constants definitions for new bus backplane protocol
--
-- Revision 1.14  2004/12/03 16:41:25  dca
-- FIBRE_CHECKSUM_ERR definition removed.
-- Now local definition in reply_translator
--
-- Revision 1.13  2004/11/26 00:11:50  erniel
-- changed command type definitions
-- changed status code definitions
--
-- Revision 1.12  2004/10/21 09:19:35  dca
-- width of error table entries changed.
-- COMMAND_SUCCESS added
--
-- Revision 1.11  2004/09/27 19:15:43  erniel
-- renamed BB_NUM_HEADER_WORDS to BB_NUM_CMD_HEADER_WORDS
--
-- Revision 1.10  2004/09/27 18:38:36  erniel
-- renamed card address constants
-- renamed PASS_FAIL constant to STATUS
-- removed redundant fibre constants
--
-- Revision 1.9  2004/09/24 18:14:49  erniel
-- moved definitions from wishbone pack
-- moved definitions from dispatch pack
--
-- Revision 1.8  2004/09/10 16:59:24  erniel
-- changed data field size to 13 bits
-- added file header
--
--
-----------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

package command_pack is

   ------------------------------------------------------------------------
   -- General Declarations
   ------------------------------------------------------------------------

   constant PACKET_WORD_WIDTH : integer := 32;

   -- Number of channels per RC
   constant NO_CHANNELS       : integer := 8;

   ------------------------------------------------------------------------
   -- CARD-TYPE Declarations
   ------------------------------------------------------------------------
   constant MAX_NUM_CARD_TYPES : integer := 8;
   constant CARD_TYPE_WIDTH    : integer := 3;

   constant AC_CARD_TYPE       : std_logic_vector(CARD_TYPE_WIDTH-1 downto 0) := "000";
   constant BC_CARD_TYPE       : std_logic_vector(CARD_TYPE_WIDTH-1 downto 0) := "001";
   constant RC_CARD_TYPE       : std_logic_vector(CARD_TYPE_WIDTH-1 downto 0) := "010";
   constant BC_D_CARD_TYPE     : std_logic_vector(CARD_TYPE_WIDTH-1 downto 0) := "001"; -- Bias Card  Revision D 
   constant RC_B_CARD_TYPE     : std_logic_vector(CARD_TYPE_WIDTH-1 downto 0) := "010"; -- Readout Card Revision B
   constant CC_CARD_TYPE       : std_logic_vector(CARD_TYPE_WIDTH-1 downto 0) := "011";
   constant PS_CARD_TYPE       : std_logic_vector(CARD_TYPE_WIDTH-1 downto 0) := "100";
   constant BC_E_CARD_TYPE     : std_logic_vector(CARD_TYPE_WIDTH-1 downto 0) := "101";	-- Bias Card  Revision E 
   constant RC_D_CARD_TYPE     : std_logic_vector(CARD_TYPE_WIDTH-1 downto 0) := "110";	-- Readout Card Revision D
   
   ------------------------------------------------------------------------
   -- Bus Backplane-Protocol Declarations
   ------------------------------------------------------------------------

   -- field range declarations:

   constant BB_PREAMBLE     : std_logic_vector(31 downto 12) := x"AAAAA";
   constant BB_COMMAND_TYPE : std_logic_vector(11 downto 11) := "0";
   constant BB_DATA_SIZE    : std_logic_vector(10 downto 0)  := "00000000000";
   constant BB_CARD_ADDRESS : std_logic_vector(31 downto 24) := "00000000";
   constant BB_CARD_HW_ADDR : std_logic_vector(27 downto 24) := "0000";	 -- the lower nibble is the actual slot id, the upper nibble is used to introduce virtual cards for the purpose of supporting 64 rows.
   constant BB_CARD_U_ADDRESS: std_logic_vector(28 downto 28) := "0";    -- this bit signifies a virtual card to write to the upper 32 word of a param id.
   constant BB_PARAMETER_ID : std_logic_vector(23 downto 16) := "00000000";
   constant BB_STATUS       : std_logic_vector(15 downto 0)  := "0000000000000000";


   -- field width declarations:

   constant BB_PREAMBLE_WIDTH     : integer := BB_PREAMBLE'length;
   constant BB_COMMAND_TYPE_WIDTH : integer := BB_COMMAND_TYPE'length;
   constant BB_DATA_SIZE_WIDTH    : integer := BB_DATA_SIZE'length;
   constant BB_CARD_ADDRESS_WIDTH : integer := BB_CARD_ADDRESS'length;
   constant BB_CARD_HW_ADDR_WIDTH : integer := BB_CARD_HW_ADDR'length;
   constant BB_PARAMETER_ID_WIDTH : integer := BB_PARAMETER_ID'length;
   constant BB_STATUS_WIDTH       : integer := BB_STATUS'length;


   -- field value declarations:

   -- command types:
   constant WRITE_CMD         : std_logic_vector(BB_COMMAND_TYPE_WIDTH-1 downto 0) := "1";
   constant READ_CMD          : std_logic_vector(BB_COMMAND_TYPE_WIDTH-1 downto 0) := "0";

   -- card addresses:
   constant NO_CARDS          : std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0) := x"00";
   constant POWER_SUPPLY_CARD : std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0) := x"01";
   constant CLOCK_CARD        : std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0) := x"02";
   constant READOUT_CARD_1    : std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0) := x"03";
   constant READOUT_CARD_2    : std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0) := x"04";
   constant READOUT_CARD_3    : std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0) := x"05";
   constant READOUT_CARD_4    : std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0) := x"06";
   constant BIAS_CARD_1       : std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0) := x"07";
   constant BIAS_CARD_2       : std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0) := x"08";
   constant BIAS_CARD_3       : std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0) := x"09";
   constant ADDRESS_CARD      : std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0) := x"0A";
   constant ALL_READOUT_CARDS : std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0) := x"0B";
   constant ALL_BIAS_CARDS    : std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0) := x"0C";
   constant ALL_FPGA_CARDS    : std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0) := x"0D";
   constant ALL_MCE_CARDS     : std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0) := x"0E";

   -- virtual card-ids introduced to support 64 rows or writing upper 32 words of a given parameter id   
   constant READOUT_CARD_1_U  : std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0) := x"13";
   constant READOUT_CARD_2_U  : std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0) := x"14";
   constant READOUT_CARD_3_U  : std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0) := x"15";
   constant READOUT_CARD_4_U  : std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0) := x"16";
   constant BIAS_CARD_1_U     : std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0) := x"17";
   constant BIAS_CARD_2_U     : std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0) := x"18";
   constant BIAS_CARD_3_U     : std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0) := x"19";
   constant ADDRESS_CARD_U    : std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0) := x"1A";

   -- parameter id's are defined in wishbone_pack.vhd


   ------------------------------------------------------------------------
   -- Fibre-Protocol Declarations
   ------------------------------------------------------------------------

   -- field range declarations:

   constant FIBRE_PREAMBLE1    : std_logic_vector(31 downto 0)  := x"A5A5A5A5";
   constant FIBRE_PREAMBLE2    : std_logic_vector(31 downto 0)  := x"5A5A5A5A";
   constant FIBRE_PACKET_TYPE  : std_logic_vector(31 downto 0)  := "00000000000000000000000000000000";
   constant FIBRE_CARD_ADDRESS : std_logic_vector(31 downto 16) := "0000000000000000";
   constant FIBRE_PARAMETER_ID : std_logic_vector(15 downto 0)  := "0000000000000000";
   constant FIBRE_DATA_SIZE    : std_logic_vector(31 downto 0)  := "00000000000000000000000000000000";
   constant FIBRE_STATUS       : std_logic_vector(31 downto 0)  := "00000000000000000000000000000000";
   constant FIBRE_CHECKSUM     : std_logic_vector(31 downto 0)  := "00000000000000000000000000000000";


   -- field width declarations:

   constant FIBRE_PREAMBLE1_WIDTH    : integer := FIBRE_PREAMBLE1'length;
   constant FIBRE_PREAMBLE2_WIDTH    : integer := FIBRE_PREAMBLE2'length;
   constant FIBRE_PACKET_TYPE_WIDTH  : integer := FIBRE_PACKET_TYPE'length;
   constant FIBRE_CARD_ADDRESS_WIDTH : integer := FIBRE_CARD_ADDRESS'length;
   constant FIBRE_PARAMETER_ID_WIDTH : integer := FIBRE_PARAMETER_ID'length;
   constant FIBRE_DATA_SIZE_WIDTH    : integer := FIBRE_DATA_SIZE'length;
   constant FIBRE_STATUS_WIDTH       : integer := FIBRE_STATUS'length;
   constant FIBRE_CHECKSUM_WIDTH     : integer := FIBRE_CHECKSUM'length;


   -- field value declarations:

   -- command packet types:
   constant WRITE_BLOCK : std_logic_vector(FIBRE_PACKET_TYPE_WIDTH-1 downto 0) := x"20205742";
   constant READ_BLOCK  : std_logic_vector(FIBRE_PACKET_TYPE_WIDTH-1 downto 0) := x"20205242";
   constant GO          : std_logic_vector(FIBRE_PACKET_TYPE_WIDTH-1 downto 0) := x"2020474F";
   constant STOP        : std_logic_vector(FIBRE_PACKET_TYPE_WIDTH-1 downto 0) := x"20205354";
   constant RESET       : std_logic_vector(FIBRE_PACKET_TYPE_WIDTH-1 downto 0) := x"20205253";

   -- reply packet types:
   constant REPLY       : std_logic_vector(FIBRE_PACKET_TYPE_WIDTH-1 downto 0) := x"20205250";
   constant DATA        : std_logic_vector(FIBRE_PACKET_TYPE_WIDTH-1 downto 0) := x"20204441";

   -- reply status types:
   constant WRITE_OK    : std_logic_vector(FIBRE_STATUS_WIDTH-1 downto 0) := x"57424F4B";
   constant READ_OK     : std_logic_vector(FIBRE_STATUS_WIDTH-1 downto 0) := x"52424F4B";
   constant GO_OK       : std_logic_vector(FIBRE_STATUS_WIDTH-1 downto 0) := x"474F4F4B";
   constant STOP_OK     : std_logic_vector(FIBRE_STATUS_WIDTH-1 downto 0) := x"53544F4B";
   constant RESET_OK    : std_logic_vector(FIBRE_STATUS_WIDTH-1 downto 0) := x"52534F4B";
   constant DATA_OK     : std_logic_vector(FIBRE_STATUS_WIDTH-1 downto 0) := x"44414F4B";
   constant WRITE_ERR   : std_logic_vector(FIBRE_STATUS_WIDTH-1 downto 0) := x"57424552";
   constant READ_ERR    : std_logic_vector(FIBRE_STATUS_WIDTH-1 downto 0) := x"52424552";
   constant GO_ERR      : std_logic_vector(FIBRE_STATUS_WIDTH-1 downto 0) := x"474F4552";
   constant STOP_ERR    : std_logic_vector(FIBRE_STATUS_WIDTH-1 downto 0) := x"53544552";
   constant RESET_ERR   : std_logic_vector(FIBRE_STATUS_WIDTH-1 downto 0) := x"52534552";
   constant DATA_ERR    : std_logic_vector(FIBRE_STATUS_WIDTH-1 downto 0) := x"44414552";

   constant FIBRE_NO_ERROR_STATUS : std_logic_vector(9 downto 0) := (others => '0');

   -- card addresses and parameter id's are the same as ones
   -- used over bus backplane, except zero-padded to 16 bits.

   ------------------------------------------------------------------------
   -- Issue-Reply Declarations
   ------------------------------------------------------------------------

--   -- command types:
--   constant WRITE_BLOCK : std_logic_vector(BB_COMMAND_TYPE_WIDTH-1 downto 0) := "000";
--   constant READ_BLOCK  : std_logic_vector(BB_COMMAND_TYPE_WIDTH-1 downto 0) := "001";
--   constant START       : std_logic_vector(BB_COMMAND_TYPE_WIDTH-1 downto 0) := "010";
--   constant STOP        : std_logic_vector(BB_COMMAND_TYPE_WIDTH-1 downto 0) := "011";
--   constant RESET       : std_logic_vector(BB_COMMAND_TYPE_WIDTH-1 downto 0) := "100";
--   constant DATA        : std_logic_vector(BB_COMMAND_TYPE_WIDTH-1 downto 0) := "101";


   ------------------------------------------------------------------------
   -- ASCII character byte definitions for fibre commands/reply packets
   ------------------------------------------------------------------------

   subtype byte is std_logic_vector(7 downto 0);
   constant ASCII_A    : byte := x"41";  -- ascii value for 'A'
   constant ASCII_B    : byte := x"42";  -- ascii value for 'B'
   constant ASCII_D    : byte := x"44";  -- ascii value for 'D'
   constant ASCII_E    : byte := x"45";  -- ascii value for 'E'
   constant ASCII_G    : byte := x"47";  -- ascii value for 'G'
   constant ASCII_K    : byte := x"4B";  -- ascii value for 'K'
   constant ASCII_O    : byte := x"4F";  -- ascii value for 'O'
   constant ASCII_P    : byte := x"50";  -- ascii value for 'P'
   constant ASCII_R    : byte := x"52";  -- ascii value for 'R'
   constant ASCII_S    : byte := x"53";  -- ascii value for 'S'
   constant ASCII_T    : byte := x"54";  -- ascii value for 'T'
   constant ASCII_W    : byte := x"57";  -- ascii value for 'W'
   constant ASCII_SP   : byte := x"20";  -- ascii value for space

end command_pack;