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
-- s_lvds_tx test bench
-- 
-- Revision History:
-- Mar 07, 2004: Initial version - NRG
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library work;
use work.s_pack.all;

entity s_lvds_tx_tb is
   port(
      lvds : out std_logic
   );
end s_lvds_tx_tb;

architecture behaviour of s_lvds_tx_tb is
   constant CLOCK_PERIOD : time := 5 ns;
   signal one : std_logic := '1';
   signal zero : std_logic := '0';
   
   signal reset : std_logic;
   signal reset_n : std_logic;
   signal clock : std_logic := '0';
   signal done : std_logic;
   signal enable : std_logic;

begin
      
   lvds_state : s_lvds_tx
      port map (
         rst_i => reset,
         clk_i => clock,
         en_i => enable,
         done_o => done,
         tx_busy_i => zero,
         tx_ack_i => zero,
         tx_data_o => open,
         tx_we_o => open,
         tx_stb_o => open,
         lvds_o => lvds
      );
      
   reset <= '1', '0' after 2.5 * CLOCK_PERIOD;
   reset_n <= not reset;
   clock <= not clock after CLOCK_PERIOD / 2;
   
   process(reset, clock)
   begin
      if (reset = '1') then
         enable <= '0';
      elsif (Rising_Edge(clock)) then
         enable <= '1';
      end if;
   end process;
   
end behaviour;
