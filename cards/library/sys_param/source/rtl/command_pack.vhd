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

   constant PACKET_WORD_WIDTH   : integer := 32;
   
   ------------------------------------------------------------------------
   -- Bus Backplane-Protocol Declarations
   ------------------------------------------------------------------------
   
   constant BB_NUM_CMD_HEADER_WORDS   : integer := 2;
   constant BB_NUM_REPLY_HEADER_WORDS : integer := 2;
     
   -- field range declarations:   
   constant BB_PREAMBLE     : std_logic_vector(31 downto 16) := x"AAAA";  
   constant BB_COMMAND_TYPE : std_logic_vector(15 downto 12) := "0000";
   constant BB_DATA_SIZE    : std_logic_vector(11 downto 0)  := "000000000000";
   constant BB_CARD_ADDRESS : std_logic_vector(31 downto 24) := "00000000";
   constant BB_PARAMETER_ID : std_logic_vector(23 downto 16) := "00000000";
   constant BB_STATUS       : std_logic_vector(15 downto 0)  := "0000000000000000";
  
   -- field width declarations:    
   constant BB_PREAMBLE_WIDTH     : integer := BB_PREAMBLE'length;
   constant BB_COMMAND_TYPE_WIDTH : integer := BB_COMMAND_TYPE'length;
   constant BB_DATA_SIZE_WIDTH    : integer := BB_DATA_SIZE'length;
   constant BB_CARD_ADDRESS_WIDTH : integer := BB_CARD_ADDRESS'length;
   constant BB_PARAMETER_ID_WIDTH : integer := BB_PARAMETER_ID'length;
   constant BB_STATUS_WIDTH       : integer := BB_STATUS'length;
   
   -- field value declarations:   
      -- command types:
      constant WRITE_CMD         : std_logic_vector(BB_COMMAND_TYPE_WIDTH-1 downto 0) := "1000";
      constant READ_CMD          : std_logic_vector(BB_COMMAND_TYPE_WIDTH-1 downto 0) := "0000";
      
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
      constant ALL_CARDS         : std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0) := x"0E";

      -- parameter id's are defined in wishbone_pack.vhd
   
      -- status codes:
      -- not defined yet
   
  
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
      -- packet types:
      constant WRITE_BLOCK : std_logic_vector(FIBRE_PACKET_TYPE_WIDTH-1 downto 0) := x"20205742";
      constant READ_BLOCK  : std_logic_vector(FIBRE_PACKET_TYPE_WIDTH-1 downto 0) := x"20205242";
      constant GO          : std_logic_vector(FIBRE_PACKET_TYPE_WIDTH-1 downto 0) := x"2020474F";
      constant STOP        : std_logic_vector(FIBRE_PACKET_TYPE_WIDTH-1 downto 0) := x"20205354";
      constant RESET       : std_logic_vector(FIBRE_PACKET_TYPE_WIDTH-1 downto 0) := x"20205253";
      constant REPLY       : std_logic_vector(FIBRE_PACKET_TYPE_WIDTH-1 downto 0) := x"20205250";
      constant DATA        : std_logic_vector(FIBRE_PACKET_TYPE_WIDTH-1 downto 0) := x"20204441";
   
      -- status types:
      constant WRITE_OK    : std_logic_vector(FIBRE_STATUS_WIDTH-1 downto 0) := x"57424F4B";
      constant READ_OK     : std_logic_vector(FIBRE_STATUS_WIDTH-1 downto 0) := x"52424F4B";
      constant GO_OK       : std_logic_vector(FIBRE_STATUS_WIDTH-1 downto 0) := x"474F4F4B";
      constant STOP_OK     : std_logic_vector(FIBRE_STATUS_WIDTH-1 downto 0) := x"53544F4B";
      constant RESET_OK    : std_logic_vector(FIBRE_STATUS_WIDTH-1 downto 0) := x"52534F4B";
      constant WRITE_ERR   : std_logic_vector(FIBRE_STATUS_WIDTH-1 downto 0) := x"57424552";
      constant READ_ERR    : std_logic_vector(FIBRE_STATUS_WIDTH-1 downto 0) := x"52424552";
      constant GO_ERR      : std_logic_vector(FIBRE_STATUS_WIDTH-1 downto 0) := x"474F4552";
      constant STOP_ERR    : std_logic_vector(FIBRE_STATUS_WIDTH-1 downto 0) := x"53544552";
      constant RESET_ERR   : std_logic_vector(FIBRE_STATUS_WIDTH-1 downto 0) := x"52534552";
      
      -- card addresses and parameter id's are the same as ones 
      -- used over bus backplane, except zero-padded to 16 bits.

end command_pack;