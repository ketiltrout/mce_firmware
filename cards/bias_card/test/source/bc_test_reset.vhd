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
-- bc_test_reset.vhd
--
-- Project:	      SCUBA-2
-- Author:	       Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Reset state for bias card test
-- 
-- Revision History:
--
-- $Log: bc_test_reset.vhd,v $
-- Revision 1.2  2004/05/12 16:49:07  erniel
-- removed components already in all_test
--
-- Revision 1.1  2004/05/11 23:04:40  mandana
-- initial release - copied from all_test
--
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity bc_test_reset is
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
end bc_test_reset;

architecture behaviour of bc_test_reset is
   type astring is array (natural range <>) of std_logic_vector(7 downto 0);
   signal message : astring (0 to 15);
   
   signal done : std_logic;
   
begin

   -- Our output string
   -- I wanted to use characters and strings, but for some reason
   -- character'pos always returns 0 in Quartus 2.2
   message(0) <= conv_std_logic_vector(10,8);  -- \r
   message(1) <= conv_std_logic_vector(13,8);  -- \n
   message(2) <= conv_std_logic_vector(66,8);   -- B
   message(3) <= conv_std_logic_vector(67,8);   -- C
   message(4) <= conv_std_logic_vector(95,8);   -- _
   message(5) <= conv_std_logic_vector(84,8);   -- T
   message(6) <= conv_std_logic_vector(101,8);  -- e
   message(7) <= conv_std_logic_vector(115,8);  -- s
   message(8) <= conv_std_logic_vector(116,8);  -- t
   message(9) <= conv_std_logic_vector(32,8);   -- 
   message(10) <= conv_std_logic_vector(118,8); -- v
   message(11) <= conv_std_logic_vector(48,8);  -- 0
   message(12) <= conv_std_logic_vector(49,8);  -- 1
   message(13) <= conv_std_logic_vector(46,8);  -- .
   message(14) <= conv_std_logic_vector(48,8);  -- 0
   message(15) <= conv_std_logic_vector(48,8);  -- 0
   
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
