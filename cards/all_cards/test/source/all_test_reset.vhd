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
-- all_test_reset.vhd
--
-- Project:	      SCUBA-2
-- Author:	       Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Reset state for common test
-- 
-- Revision History:
--
-- $Log: all_test_reset.vhd,v $
-- Revision 1.2  2004/05/11 03:28:09  erniel
-- updated header information
--
-- Revision 1.1  2004/04/28 20:16:13  erniel
-- initial version
--
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity all_test_reset is
   port (
      -- basic signals
      rst_i : in std_logic;   -- reset input
      clk_i : in std_logic;   -- clock input
      en_i : in std_logic;    -- enable signal
      done_o : out std_logic; -- done ouput signal
      
      -- transmitter signals
      tx_data_o : out std_logic_vector(7 downto 0);
      tx_start_o : out std_logic;
      tx_done_i : in std_logic);   
end all_test_reset;

architecture behaviour of all_test_reset is
   type astring is array (natural range <>) of std_logic_vector(7 downto 0);
   signal message : astring (0 to 16);
      
   signal count : integer range 0 to 17;
   
   type states is (RESET, TX_CHAR, TX_WAIT, DONE);
   signal pres_state : states;
   signal next_state : states;
   
begin

   -- Our output string
   -- I wanted to use characters and strings, but for some reason
   -- character'pos always returns 0 in Quartus 2.2
   message(0) <= conv_std_logic_vector(10,8);  -- \r
   message(1) <= conv_std_logic_vector(13,8);  -- \n
   message(2) <= conv_std_logic_vector(65,8);   -- A
   message(3) <= conv_std_logic_vector(108,8);  -- l
   message(4) <= conv_std_logic_vector(108,8);  -- l
   message(5) <= conv_std_logic_vector(95,8);   -- _
   message(6) <= conv_std_logic_vector(84,8);   -- T
   message(7) <= conv_std_logic_vector(101,8);  -- e
   message(8) <= conv_std_logic_vector(115,8);  -- s
   message(9) <= conv_std_logic_vector(116,8);  -- t
   message(10) <= conv_std_logic_vector(32,8);  -- 
   message(11) <= conv_std_logic_vector(118,8); -- v
   message(12) <= conv_std_logic_vector(48,8);  -- 0
   message(13) <= conv_std_logic_vector(51,8);  -- 3
   message(14) <= conv_std_logic_vector(46,8);  -- .
   message(15) <= conv_std_logic_vector(48,8);  -- 0
   message(16) <= conv_std_logic_vector(48,8);  -- 0

   process(rst_i, clk_i)
   begin
      if(rst_i = '1') then
         pres_state <= RESET;
      elsif(clk_i'event and clk_i = '1') then
         pres_state <= next_state;
      end if;
   end process;
   
   process(pres_state, en_i, tx_done_i, count)
   begin
      case pres_state is
         when RESET =>   if(en_i = '1') then
                            next_state <= TX_CHAR;
                         else
                            next_state <= RESET;
                         end if;
         when TX_CHAR => next_state <= TX_WAIT;
         when TX_WAIT => if(tx_done_i = '0') then
                            next_state <= TX_WAIT;
                         elsif(tx_done_i = '1' and count = 17) then
                            next_state <= DONE;
                         else
                            next_state <= TX_CHAR;
                         end if;
         when DONE =>    next_state <= RESET;
      end case;
   end process;
   
   process(pres_state)
   begin
      case pres_state is
         when RESET =>   tx_data_o <= (others => '0');
                         tx_start_o <= '0';
                         count <= 0;
                         done_o <= '0';
                         
         when TX_CHAR => tx_data_o <= message(count);
                         tx_start_o <= '1';
                         count <= count + 1;
                         done_o <= '0';
                         
         when TX_WAIT => tx_data_o <= (others => '0');
                         tx_start_o <= '0';
                         done_o <= '0';
                         
         when DONE =>    tx_data_o <= (others => '0');
                         tx_start_o <= '0';
                         done_o <= '1';
      end case;
   end process;
   
end;
