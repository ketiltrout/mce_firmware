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
-- ascii_pack.vhd
--
-- Project:	      SCUBA-2
-- Author:        Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Package file for ASCII.  Allows character literals to be used instead
-- of std_logic_vectors.  To access caps and "shifted" keys, use shift().
--
-- Revision history:
-- 
-- $Log: ascii_pack.vhd,v $
-- Revision 1.1  2004/12/10 00:12:15  erniel
-- initial version
--
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

package ascii_pack is

   -- letters:
   constant a : std_logic_vector(7 downto 0) := "01100001";
   constant b : std_logic_vector(7 downto 0) := "01100010";
   constant c : std_logic_vector(7 downto 0) := "01100011";
   constant d : std_logic_vector(7 downto 0) := "01100100";
   constant e : std_logic_vector(7 downto 0) := "01100101";
   constant f : std_logic_vector(7 downto 0) := "01100110";
   constant g : std_logic_vector(7 downto 0) := "01100111";
   constant h : std_logic_vector(7 downto 0) := "01101000";
   constant i : std_logic_vector(7 downto 0) := "01101001";
   constant j : std_logic_vector(7 downto 0) := "01101010";
   constant k : std_logic_vector(7 downto 0) := "01101011";
   constant l : std_logic_vector(7 downto 0) := "01101100";
   constant m : std_logic_vector(7 downto 0) := "01101101";
   constant n : std_logic_vector(7 downto 0) := "01101110";
   constant o : std_logic_vector(7 downto 0) := "01101111";
   constant p : std_logic_vector(7 downto 0) := "01110000";
   constant q : std_logic_vector(7 downto 0) := "01110001";
   constant r : std_logic_vector(7 downto 0) := "01110010";
   constant s : std_logic_vector(7 downto 0) := "01110011";
   constant t : std_logic_vector(7 downto 0) := "01110100";
   constant u : std_logic_vector(7 downto 0) := "01110101";
   constant v : std_logic_vector(7 downto 0) := "01110110";
   constant w : std_logic_vector(7 downto 0) := "01110111";
   constant x : std_logic_vector(7 downto 0) := "01111000";
   constant y : std_logic_vector(7 downto 0) := "01111001";
   constant z : std_logic_vector(7 downto 0) := "01111010";

   -- numbers:
   constant zero  : std_logic_vector(7 downto 0) := "00110000";
   constant one   : std_logic_vector(7 downto 0) := "00110001";
   constant two   : std_logic_vector(7 downto 0) := "00110010";
   constant three : std_logic_vector(7 downto 0) := "00110011";
   constant four  : std_logic_vector(7 downto 0) := "00110100";
   constant five  : std_logic_vector(7 downto 0) := "00110101";
   constant six   : std_logic_vector(7 downto 0) := "00110110";
   constant seven : std_logic_vector(7 downto 0) := "00110111";
   constant eight : std_logic_vector(7 downto 0) := "00111000";
   constant nine  : std_logic_vector(7 downto 0) := "00111001";

   -- punctuation:
   constant space     : std_logic_vector(7 downto 0) := "00100000";
   constant comma     : std_logic_vector(7 downto 0) := "00101100";
   constant period    : std_logic_vector(7 downto 0) := "00101110";
   constant slash     : std_logic_vector(7 downto 0) := "00101111";
   constant semicolon : std_logic_vector(7 downto 0) := "00111011";
   constant quote     : std_logic_vector(7 downto 0) := "00100111";
   constant lbracket  : std_logic_vector(7 downto 0) := "01011011";
   constant rbracket  : std_logic_vector(7 downto 0) := "01011101";
   constant backslash : std_logic_vector(7 downto 0) := "01011100";
   constant minus     : std_logic_vector(7 downto 0) := "00101101";
   constant equal     : std_logic_vector(7 downto 0) := "00111101";

   -- control characters:
   constant nullchar : std_logic_vector(7 downto 0) := "00000000";
   constant tab      : std_logic_vector(7 downto 0) := "00001001";
   constant newline  : std_logic_vector(7 downto 0) := "00001101";
   constant escape   : std_logic_vector(7 downto 0) := "00011011";

   -- conversion of lowercase/punctuation -> uppercase/alternate punctuation
   function shift (key : std_logic_vector(7 downto 0)) return std_logic_vector;

   -- conversion of 4-bit -> hex character (ascii)
   function hex2asc (input : std_logic_vector(3 downto 0)) return std_logic_vector;

   -- conversion of 1-bit -> bin character (ascii)
   function bin2asc (input : std_logic) return std_logic_vector;

end ascii_pack;

package body ascii_pack is

   function shift (key : std_logic_vector(7 downto 0)) return std_logic_vector is
   variable result : std_logic_vector(7 downto 0);
   begin
      case key is                                   -- KEY:            SHIFT+KEY:
         when "00101100" => result := "00111100";   -- comma        -> lessthan
         when "00101110" => result := "00111110";   -- period       -> greaterthan
         when "00101111" => result := "00111111";   -- slash        -> question
         when "00111011" => result := "00111010";   -- semicolon    -> colon
         when "00100111" => result := "00100010";   -- quote        -> doublequote
         when "01011011" => result := "01111011";   -- lbracket     -> lbrace
         when "01011101" => result := "11111101";   -- rbracket     -> rbrace
         when "01011100" => result := "01111100";   -- backslash    -> pipe
         when "00101101" => result := "01011111";   -- minus        -> underscore
         when "00111101" => result := "00101011";   -- equal        -> add

         when "00110000" => result := "00101001";   -- 0            -> rparenthesis
         when "00110001" => result := "00100001";   -- 1            -> exclamation
         when "00110010" => result := "01000000";   -- 2            -> at
         when "00110011" => result := "00100011";   -- 3            -> number
         when "00110100" => result := "00100100";   -- 4            -> dollar
         when "00110101" => result := "00100101";   -- 5            -> percent
         when "00110110" => result := "01011110";   -- 6            -> caret
         when "00110111" => result := "00100110";   -- 7            -> ampersand
         when "00111000" => result := "00101010";   -- 8            -> star
         when "00111001" => result := "00101000";   -- 9            -> lparenthesis

         when others =>     if(key > 96 and key < 123) then
                               result := key - 32;  -- smallletters -> capsletters
                            else
                               result := key;       -- don't change other keys
                            end if;
      end case;
      return result;
   end function shift;

   function hex2asc (input : std_logic_vector(3 downto 0)) return std_logic_vector is
   variable result : std_logic_vector(7 downto 0);
   begin
      case input is
         when "0000" => result := "00110000";       -- 0
         when "0001" => result := "00110001";       -- 1
         when "0010" => result := "00110010";       -- 2
         when "0011" => result := "00110011";       -- 3
         when "0100" => result := "00110100";       -- 4
         when "0101" => result := "00110101";       -- 5
         when "0110" => result := "00110110";       -- 6
         when "0111" => result := "00110111";       -- 7
         when "1000" => result := "00111000";       -- 8
         when "1001" => result := "00111001";       -- 9
         when "1010" => result := "01000001";       -- A
         when "1011" => result := "01000010";       -- B
         when "1100" => result := "01000011";       -- C
         when "1101" => result := "01000100";       -- D
         when "1110" => result := "01000101";       -- E
         when "1111" => result := "01000110";       -- F

         when others => result := "01011000";       -- X
      end case;
      return result;
   end function hex2asc;

   function bin2asc (input : std_logic) return std_logic_vector is
   variable result : std_logic_vector(7 downto 0);
   begin
      case input is
         when '0' =>    result := "00110000";       -- 0
         when '1' =>    result := "00110001";       -- 1

         when others => result := "01011000";       -- X
      end case;
      return result;
   end function bin2asc;

end package body ascii_pack;