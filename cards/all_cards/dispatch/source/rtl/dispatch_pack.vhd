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
-- dispatch_pack.vhd
--
-- Project:	      SCUBA-2
-- Author:	       Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Package file for dispatch block
--
-- Revision history:
-- 
-- $Log: dispatch_pack.vhd,v $
-- Revision 1.1  2004/08/04 19:43:19  erniel
-- initial version
--
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package dispatch_pack is

   -- header field range declarations:
   constant PREAMBLE      : std_logic_vector(31 downto 16) := "1010101010101010";  -- = sys_param.command_pack.BB_PREAMBLE
   constant COMMAND_TYPE  : std_logic_vector(15 downto 13) := "000";
   constant CMD_DATA_SIZE : std_logic_vector(12 downto 0)  := "0000000000000";
   constant CARD_ADDRESS  : std_logic_vector(31 downto 24) := "00000000";
   constant PARAMETER_ID  : std_logic_vector(23 downto 16) := "00000000";
   constant MACRO_OP_SEQ  : std_logic_vector(15 downto 8)  := "00000000";
   constant MICRO_OP_SEQ  : std_logic_vector(7 downto 0)   := "00000000";
   constant PASS_FAIL     : std_logic_vector(31 downto 24) := "00000000";
   
   -- header field width declarations:
   constant CMD_WORD_WIDTH      : integer := 32;
   
   constant PREAMBLE_WIDTH      : integer := 16;  -- = sys_param.command_pack.PREAMBLE_BUS_WIDTH
   constant COMMAND_TYPE_WIDTH  : integer := 3;   -- = sys_param.wishbone_pack.CMD_TYPE_WIDTH
   constant CMD_DATA_SIZE_WIDTH : integer := 13;  -- = sys_param.command_pack.CQ_DATA_SIZE_BUS_WIDTH
   constant CARD_ADDRESS_WIDTH  : integer := 8;   -- = sys_param.command_pack.CQ_CARD_ADDR_BUS_WIDTH
   constant PARAMETER_ID_WIDTH  : integer := 8;   -- = sys_param.command_pack.CQ_PAR_ID_BUS_WIDTH
   constant MACRO_OP_SEQ_WIDTH  : integer := 8;   -- = sys_param.command_pack.MOP_BUS_WIDTH
   constant MICRO_OP_SEQ_WIDTH  : integer := 8;   -- = sys_param.command_pack.UOP_BUS_WIDTH
   constant PASS_FAIL_WIDTH     : integer := 8;
   
   -- CRC polynomial:
   constant CRC32 : std_logic_vector(31 downto 0) := "00000100110000010001110110110111";
   
   -- miscellaneous declarations:
   constant MAX_CMD_HEADER_WORDS   : integer := 2;  -- = sys_param.command_pack.BB_PACKET_HEADER_SIZE
   constant MAX_REPLY_HEADER_WORDS : integer := 3;
   constant MAX_DATA_WORDS         : integer := (2**CMD_DATA_SIZE_WIDTH);
   
   constant BUF_DATA_WIDTH : integer := CMD_WORD_WIDTH;
   constant BUF_ADDR_WIDTH : integer := 6;   
   
end dispatch_pack;