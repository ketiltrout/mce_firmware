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

-- <Title>
--
-- <revision control keyword substitutions e.g. $Id$>
--
-- Project:	      SCUBA-2
-- Author:	       Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- <description text>
--
-- Revision history:
-- <date $Date$>	- <initials $Author$>
-- $Log$
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity ac_test_reset is
   port (
      -- basic signals
      rst_i : in std_logic;   -- reset input
      clk_i : in std_logic;   -- clock input
      en_i : in std_logic;    -- enable signal
      done_o : out std_logic; -- done ouput signal
      
      -- transmitter signals
      tx_busy_i : in std_logic;  -- transmit busy flag
      tx_ack_i : in std_logic;   -- transmit ack
      tx_data_o : out std_logic_vector(7 downto 0);   -- transmit data
      tx_we_o : out std_logic;   -- transmit write flag
      tx_stb_o : out std_logic   -- transmit strobe flag
   );
end ac_test_reset;

architecture behaviour of ac_test_reset is
   type astring is array (natural range <>) of std_logic_vector(7 downto 0);
   signal message : astring (0 to 15);
   
   signal done : std_logic;
   
begin

   -- Our output string
   -- I wanted to use characters and strings, but for some reason
   -- character'pos always returns 0 in Quartus 2.2
   message(0)  <= x"0A";  -- \r
   message(1)  <= x"0D";  -- \n
   message(2)  <= x"41";  -- A
   message(3)  <= x"43";  -- C
   message(4)  <= x"20";  -- 
   message(5)  <= x"54";  -- T
   message(6)  <= x"65";  -- e
   message(7)  <= x"73";  -- s
   message(8)  <= x"74";  -- t
   message(9)  <= x"20";  -- 
   message(10) <= x"76";  -- v
   message(11) <= x"31";  -- 1
   message(13) <= x"2E";  -- .
   message(14) <= x"30";  -- 0
   message(15) <= x"30";  -- 0
   
   -- tx_word gets ready to transmit the next word
   tx_word : process (rst_i, en_i, tx_busy_i, message)
      variable pos : integer range message'range;
   begin
      if ((rst_i = '1') or (en_i = '0')) then
         tx_data_o <= (others => '0');
         done <= '0';
         pos := message'left;
         tx_data_o <= message(message'left);
      elsif Rising_Edge(tx_busy_i) then
         if (pos < message'right) then
            pos := pos + 1;
            done <= '0';
         else
            pos := pos;
            done <= '1';
         end if;
         tx_data_o <= message(pos);
      end if;
   end process tx_word;
   done_o <= done;
   
   -- tx_strobe controls the transmit strobe lines
   tx_strobe : process (rst_i, en_i, clk_i)
   begin
      if ((rst_i = '1') or (en_i = '0')) then
         tx_we_o <= '0';
         tx_stb_o <= '0';
      elsif Rising_Edge(clk_i) then
         tx_we_o <= not(tx_ack_i or tx_busy_i or done);
         tx_stb_o <= not(tx_ack_i or tx_busy_i or done);
      end if;
   end process tx_strobe;
end;
