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
-- s_idle test bench
-- 
-- Revision History:
-- Feb 17, 2004: Initial version - NRG
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library work;
use work.async_pack.all;
use work.s_pack.all;

entity s_idle_tb is
   port(
      tx : out std_logic
   );
end s_idle_tb;

architecture behaviour of s_idle_tb is
   constant CLOCK_PERIOD : time := 5 ns;
   signal one : std_logic := '1';
   signal zero : std_logic := '0';
   
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
   signal tx_ack : std_logic;

   -- dummy transmitter signals
   signal dtx_busy : std_logic;
   signal dtx_bit : std_logic;
   signal dtx_data : std_logic_vector(7 downto 0);
   signal dtx_write : std_logic := '0';
   signal dtx_strobe : std_logic := '0';
   signal dtx_ack : std_logic;

   
   -- reciever signals
   signal rx_clock : std_logic;
   signal rx_flag : std_logic;
   signal rx_error : std_logic;
   signal rx_read : std_logic;
   signal rx_data : std_logic_vector(7 downto 0);
   signal rx_stb : std_logic;
   signal rx_ack : std_logic;
   
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
   
   dummy_transmitter : async_tx
      port map(
         tx_o => dtx_bit,
         busy_o => dtx_busy,
         clk_i => tx_clock,
         rst_i => reset,
         dat_i => dtx_data,
         we_i => dtx_write,
         stb_i => dtx_strobe,
         ack_o => dtx_ack,
         cyc_i => one
      );
   
   receiver : async_rx
      port map(
         rx_i => dtx_bit,
         flag_o => rx_flag,
         error_o => rx_error,
         clk_i => rx_clock,
         rst_i => reset,
         dat_o => rx_data,
         we_i => zero,
         stb_i => rx_stb,
         ack_o => rx_ack,
         cyc_i => one
      );
      
   aclock : async_clk
      port map(
         clk_i => clock,
         rst_i => reset,
         txclk_o => tx_clock,
         rxclk_o => rx_clock
      );
      
   idle_state : s_idle
      port map (
         rst_i => reset,
         clk_i => clock,
         en_i => one,
         done_o => open,
         tx_busy_i => tx_busy,
         tx_ack_i => tx_ack,
         tx_data_o => tx_data,
         tx_we_o => tx_write,
         tx_stb_o => tx_strobe,
         rx_flag_i => rx_flag,
         rx_ack_i => rx_ack,
         rx_stb_o => rx_stb,
         rx_data_i => rx_data
      );
      
   reset <= '1', '0' after 2.5 * CLOCK_PERIOD;
   reset_n <= not reset;
   clock <= not clock after CLOCK_PERIOD / 2;
   
   dtransmit : process(reset, tx_clock)
   variable tx : std_logic;
   begin
      if (reset = '1') then
         dtx_data <= "11110000";
         tx := '1';
      elsif (Rising_Edge(tx_clock)) then
         if (dtx_busy = '0') then
            dtx_write <= tx;
            dtx_strobe <= tx;
            tx := '0';
         else
             dtx_write <= '0';
             dtx_strobe <= '0';
             tx := '1';
         end if;
      end if;
   end process dtransmit;
   
end behaviour;
