---------------------------------------------------------------------
-- Copyright (c) 2003 UK Astronomy Technology Centre
--                All Rights Reserved
--
--  THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF THE UK ATC
--  The copyright notice above does not evidence any
--  actual or intended publication of such source code.
--
--  SOURCE CODE IS PROVIDED "AS IS". ALL EXPRESS OR IMPLIED CONDITIONS,
--  REPRESENTATIONS, AND WARRANTIES, INCLUDING ANY IMPLIED WARRANT OF
--  MERCHANTABILITY, SATISFACTORY QUALITY, FITNESS FOR A PARTICULAR
--  PURPOSE, OR NON-INFRINGEMENT, ARE DISCLAIMED, EXCEPT TO THE EXTENT
--  THAT SUCH DISCLAIMERS ARE HELD TO BE LEGALLY INVALID.
--
-- Project:             Scuba 2
-- Author:              Neil Gruending
-- Organisation:        UBC Physics and Astronomy
--
-- Description:
-- Puseudo random LVDS transmitter test.
-- 
-- Revision History:
-- Mar 07, 2004: Initial version - NRG
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library work;
use work.async_pack.all;
use work.component_pack.all;

entity s_lvds_tx is
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
      tx_stb_o : out std_logic;  -- transmit strobe flag
      
      -- extended signals
      lvds_o : out std_logic   -- LVDS output bit
   );
end;

architecture behaviour of s_lvds_tx is

   -- lvds signals
   signal lvds_dat : std_logic_vector(7 downto 0);
   signal lvds_we : std_logic;
   signal lvds_ack : std_logic;
   signal lvds_cyc : std_logic;
   signal lvds_busy : std_logic;
   signal lvds_stb : std_logic;
   
   -- internal signals
   signal enabled : std_logic;
   signal rnd_clk : std_logic;
   
begin

   -- our LVDS transmitter
   lvds_tx : async_tx
      port map(
         tx_o => lvds_o,
         busy_o => lvds_busy,
         clk_i => clk_i,
         rst_i => rst_i,
         dat_i => lvds_dat,
         we_i => lvds_we,
         stb_i => lvds_stb,
         ack_o => lvds_ack,
         cyc_i => lvds_cyc
      );
      
   -- our random number generator
   random : prand
      generic map (size => 8)
      port map (
         clr_i => rst_i,
         clk_i => rnd_clk,
         out_o => lvds_dat
      );

   -- we don't use the cyc signal
   lvds_cyc <= '1';
   
   -- the random counter should only tick if we are enabled
   rnd_clk <= lvds_ack and enabled;
   
   -- test controls the state of the test
   test : process (rst_i, en_i)
   begin
      if (rst_i = '1') then
         enabled <= '0';
      elsif Rising_Edge(en_i) then
         enabled <= enabled xor '1';
      end if;
   end process test;
   
   -- done_flag controls the done output
   done_flag : process (rst_i, clk_i)
   begin
      if (rst_i = '1') then
         done_o <= '0';
      elsif Rising_Edge(clk_i) then
         done_o <= en_i;
      end if;
   end process done_flag;
   
   -- lvds_strobe controls the lvds strobe lines
   lvds_strobe : process (rst_i, clk_i)
   begin
      if (rst_i = '1') then
         lvds_we <= '0';
         lvds_stb <= '0';
      elsif Rising_Edge(clk_i) then
         lvds_we <= not(lvds_ack or lvds_busy) and enabled;
         lvds_stb <= not(lvds_ack or lvds_busy) and enabled;
      end if;
   end process lvds_strobe;
end;
