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
-- CC_test test bench
-- 
-- Revision History:
-- Jan 17, 2004: Initial version - NRG
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library work;
use work.async_pack.all;

entity cc_tb is
   port(
      tx : out std_logic
   );
end cc_tb;

architecture behaviour of cc_tb is
   constant CLOCK_PERIOD : time := 5 ns;
   constant MAX_STATES : integer := 2;
   signal one : std_logic := '1';
   
   signal reset : std_logic;
   signal reset_n : std_logic;
   signal clock : std_logic := '0';

   -- transmitter signals
   signal tx_clock : std_logic := '0';
   signal tx_busy : std_logic;
   signal tx_bit : std_logic;
   signal tx_data : std_logic_vector(7 downto 0);
   signal tx_write : std_logic := '0';
   signal tx_strobe : std_logic := '0';
   signal tx_rec_array : tx_array(MAX_STATES - 1 downto 0);
   signal tx_ack : std_logic;
   
   component cc_test
      port(
         reset_n : in std_logic;
         clk : in std_logic;
         txd : out std_logic;
         rxd : in std_logic
      );
   end component;
   
begin
   transmitter : async_tx
      port map(
         tx_o => tx_bit,
         busy_o => tx_busy,
         clk_i => tx_clock,
         rst_i => reset,
         dat_i => tx_data,
         we_i => tx_write,
         stb_i => tx_strobe,
         ack_o => tx_ack,
         cyc_i => one
      );
      
   aclock : async_clk
      port map(
         clk_i => clock,
         rst_i => reset,
         txclk_o => tx_clock,
         rxclk_o => open
      );
      
   test : cc_test
      port map(
         reset_n => reset_n,
         clk => clock,
         txd => tx,
         rxd => tx_bit
      );
      
   reset <= '1', '0' after 2.5 * CLOCK_PERIOD;
   reset_n <= not reset;
   clock <= not clock after CLOCK_PERIOD / 2;
   
   transmit : process(reset, tx_clock)
   variable tx : std_logic;
   begin
      if (reset = '1') then
         tx_data <= "01010111";
         tx := '1';
      elsif (Rising_Edge(tx_clock)) then
         if (tx_busy = '0') then
            tx_write <= tx;
            tx_strobe <= tx;
            tx := '0';
         else
             tx_write <= '0';
             tx_strobe <= '0';
             tx := '1';
         end if;
      end if;
   end process transmit;
   
end behaviour;
