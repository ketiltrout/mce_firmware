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

-- hex2ascii.vhd
--
-- <revision control keyword substitutions e.g. $Id: hex2ascii.vhd,v 1.1 2004/03/22 20:26:32 erniel Exp $>
--
-- Project:	      SCUBA-2
-- Author:	       Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Implements hexadecimal-to-ascii decoder
--
-- Revision history:
-- <date $Date: 2004/03/22 20:26:32 $>	- <initials $Author: erniel $>
-- $Log: hex2ascii.vhd,v $
-- Revision 1.1  2004/03/22 20:26:32  erniel
-- initial version
--
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity hex2ascii is
port(hex_i   : in std_logic_vector(3 downto 0);
     ascii_o : out std_logic_vector(7 downto 0));
end hex2ascii;

architecture behav of hex2ascii is
begin
   decode: process(hex_i)
   begin
      case hex_i is
         when "0000" => ascii_o <= "00110000";   -- 0 hex = 48 ascii
         when "0001" => ascii_o <= "00110001";   -- 1 hex = 49 ascii
         when "0010" => ascii_o <= "00110010";   -- 2 hex = 50 ascii
         when "0011" => ascii_o <= "00110011";   -- 3 hex = 51 ascii
         when "0100" => ascii_o <= "00110100";   -- 4 hex = 52 ascii
         when "0101" => ascii_o <= "00110101";   -- 5 hex = 53 ascii
         when "0110" => ascii_o <= "00110110";   -- 6 hex = 54 ascii
         when "0111" => ascii_o <= "00110111";   -- 7 hex = 55 ascii
         when "1000" => ascii_o <= "00111000";   -- 8 hex = 56 ascii
         when "1001" => ascii_o <= "00111001";   -- 9 hex = 57 ascii
         when "1010" => ascii_o <= "01000001";   -- A hex = 65 ascii
         when "1011" => ascii_o <= "01000010";   -- B hex = 66 ascii
         when "1100" => ascii_o <= "01000011";   -- C hex = 67 ascii
         when "1101" => ascii_o <= "01000100";   -- D hex = 68 ascii
         when "1110" => ascii_o <= "01000101";   -- E hex = 69 ascii
         when "1111" => ascii_o <= "01000110";   -- F hex = 70 ascii

         when "LLLL" => ascii_o <= "00110000";   -- 0 hex = 48 ascii
         when "LLLH" => ascii_o <= "00110001";   -- 1 hex = 49 ascii
         when "LLHL" => ascii_o <= "00110010";   -- 2 hex = 50 ascii
         when "LLHH" => ascii_o <= "00110011";   -- 3 hex = 51 ascii
         when "LHLL" => ascii_o <= "00110100";   -- 4 hex = 52 ascii
         when "LHLH" => ascii_o <= "00110101";   -- 5 hex = 53 ascii
         when "LHHL" => ascii_o <= "00110110";   -- 6 hex = 54 ascii
         when "LHHH" => ascii_o <= "00110111";   -- 7 hex = 55 ascii
         when "HLLL" => ascii_o <= "00111000";   -- 8 hex = 56 ascii
         when "HLLH" => ascii_o <= "00111001";   -- 9 hex = 57 ascii
         when "HLHL" => ascii_o <= "01000001";   -- A hex = 65 ascii
         when "HLHH" => ascii_o <= "01000010";   -- B hex = 66 ascii
         when "HHLL" => ascii_o <= "01000011";   -- C hex = 67 ascii
         when "HHLH" => ascii_o <= "01000100";   -- D hex = 68 ascii
         when "HHHL" => ascii_o <= "01000101";   -- E hex = 69 ascii
         when "HHHH" => ascii_o <= "01000110";   -- F hex = 70 ascii
         
         when others => ascii_o <= "00111111";   -- anything else prints out "?" 

      end case;
   end process decode;
end behav;
