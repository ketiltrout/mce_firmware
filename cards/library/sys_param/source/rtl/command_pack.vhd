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
-- Project:	      SCUBA-2
-- Author:	       Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Package file for command processing blocks
--
-- Revision history:
-- 
-- $Log: command_pack.vhd,v $
-- Revision 1.8  2004/09/10 16:59:24  erniel
-- changed data field size to 13 bits
-- added file header
--
--
-----------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

package command_pack is

   ------------------------------------------------------------------------
   -- Bus Backplane-Side Declarations
   ------------------------------------------------------------------------
   
   constant BB_PACKET_WORD_WIDTH  : integer := 32;
   constant BB_CMD_HEADER_WORDS   : integer := 2;
   constant BB_REPLY_HEADER_WORDS : integer := 3;
   
   -- header field range declarations:
   constant BB_PREAMBLE     : std_logic_vector(31 downto 16) := "1010101010101010";  
   constant BB_COMMAND_TYPE : std_logic_vector(15 downto 13) := "000";
   constant BB_DATA_SIZE    : std_logic_vector(12 downto 0)  := "0000000000000";
   constant BB_CARD_ADDRESS : std_logic_vector(31 downto 24) := "00000000";
   constant BB_PARAMETER_ID : std_logic_vector(23 downto 16) := "00000000";
   constant BB_MACRO_OP_SEQ : std_logic_vector(15 downto 8)  := "00000000";
   constant BB_MICRO_OP_SEQ : std_logic_vector(7 downto 0)   := "00000000";
   constant BB_PASS_FAIL    : std_logic_vector(31 downto 24) := "00000000";
   
   -- header field width declarations:      
   constant BB_PREAMBLE_WIDTH     : integer := BB_PREAMBLE'length;
   constant BB_COMMAND_TYPE_WIDTH : integer := BB_COMMAND_TYPE'length;
   constant BB_DATA_SIZE_WIDTH    : integer := BB_DATA_SIZE'length;
   constant BB_CARD_ADDRESS_WIDTH : integer := BB_CARD_ADDRESS'length;
   constant BB_PARAMETER_ID_WIDTH : integer := BB_PARAMETER_ID'length;
   constant BB_MACRO_OP_SEQ_WIDTH : integer := BB_MACRO_OP_SEQ'length;
   constant BB_MICRO_OP_SEQ_WIDTH : integer := BB_MICRO_OP_SEQ'length;
   constant BB_PASS_FAIL_WIDTH    : integer := BB_PASS_FAIL'length;
   
   -- header field value declarations:
   -- command types:
   constant WRITE_BLOCK    : std_logic_vector(BB_COMMAND_TYPE_WIDTH-1 downto 0) := "000";
   constant READ_BLOCK     : std_logic_vector(BB_COMMAND_TYPE_WIDTH-1 downto 0) := "001";
   constant START          : std_logic_vector(BB_COMMAND_TYPE_WIDTH-1 downto 0) := "010";
   constant STOP           : std_logic_vector(BB_COMMAND_TYPE_WIDTH-1 downto 0) := "011";
   constant RESET          : std_logic_vector(BB_COMMAND_TYPE_WIDTH-1 downto 0) := "100";
   constant DATA           : std_logic_vector(BB_COMMAND_TYPE_WIDTH-1 downto 0) := "101";

   -- card addresses:
   constant NO_CARDS       : std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0) := x"00";
   constant PSC            : std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0) := x"01";
   constant CC             : std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0) := x"02";
   constant RC1            : std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0) := x"03";
   constant RC2            : std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0) := x"04";
   constant RC3            : std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0) := x"05";
   constant RC4            : std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0) := x"06";
   constant BC1            : std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0) := x"07";
   constant BC2            : std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0) := x"08";
   constant BC3            : std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0) := x"09";
   constant AC             : std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0) := x"0A";
   constant RCS            : std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0) := x"0B";
   constant BCS            : std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0) := x"0C";
   constant ALL_FPGA_CARDS : std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0) := x"0D";
   constant ALL_CARDS      : std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0) := x"0E";

   -- status fields:
   constant SUCCESS        : std_logic_vector(BB_PASS_FAIL_WIDTH-1 downto 0) := "11111111";
   constant FAIL           : std_logic_vector(BB_PASS_FAIL_WIDTH-1 downto 0) := "00000000";
   
   
   ------------------------------------------------------------------------
   -- Fibre-Side Declarations
   ------------------------------------------------------------------------
   
   constant FIBRE_CARD_ADDRESS_WIDTH : integer := 16;
   constant FIBRE_PARAMETER_ID_WIDTH : integer := 16;
   constant FIBRE_UOP_STATUS_WIDTH   : integer := 8;
   constant FIBRE_DATA_SIZE_WIDTH    : integer := 32;
   constant FIBRE_DATA_WIDTH         : integer := 32;
   constant FIBRE_SYNC_NUM_WIDTH     : integer := 8;
   constant FIBRE_CMD_CODE_WIDTH     : integer := 16;
   constant FIBRE_CHECKSUM_WIDTH     : integer := 32;
   constant FIBRE_ERROR_WORD_WIDTH   : integer := 32;
    
   constant FIBRE_PREAMBLE1 : std_logic_vector := X"A5";
   constant FIBRE_PREAMBLE2 : std_logic_vector := X"5A";

   -- used in cmd_queue
   constant ISSUE_SYNC_WIDTH   : integer := FIBRE_SYNC_NUM_WIDTH;  -- The width of the data field for the absolute sync count at which an instruction was issued
   constant TIMEOUT_SYNC_WIDTH : integer := FIBRE_SYNC_NUM_WIDTH;  -- The width of the data field for the absolute sync count at which an instruction expires
   

   ------------------------------------------------------------------------
   -- Error Number Table
   ------------------------------------------------------------------------
   -- list of errors / error numbers to be returned to Linux PC (word 3 of reply packet)
   -- if a command is unsuccessfully exectuted.
   
   constant CHECKSUM_ER_NUM     : std_logic_vector (FIBRE_ERROR_WORD_WIDTH-1 downto 0) := X"00000001" ;

   --------------------------------------------------------------------------------------------------


   -- ASCII character byte definitions for fibre commands/reply packets:
   subtype byte is std_logic_vector(7 downto 0);
   constant ASCII_A    : byte := X"41";  -- ascii value for 'A'
   constant ASCII_B    : byte := X"42";  -- ascii value for 'B'
   constant ASCII_D    : byte := X"44";  -- ascii value for 'D'   
   constant ASCII_E    : byte := X"45";  -- ascii value for 'E'
   constant ASCII_G    : byte := X"47";  -- ascii value for 'G'
   constant ASCII_K    : byte := X"4B";  -- ascii value for 'K'
   constant ASCII_O    : byte := X"4F";  -- ascii value for 'O'
   constant ASCII_P    : byte := X"50";  -- ascii value for 'P'
   constant ASCII_R    : byte := X"52";  -- ascii value for 'R'
   constant ASCII_S    : byte := X"53";  -- ascii value for 'S'
   constant ASCII_T    : byte := X"54";  -- ascii value for 'T'
   constant ASCII_W    : byte := X"57";  -- ascii value for 'W'
   constant ASCII_SP   : byte := X"20";  -- ascii value for space

end command_pack;