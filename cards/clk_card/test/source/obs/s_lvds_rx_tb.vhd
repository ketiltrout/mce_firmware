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
-- s_lvds_rx test bench
-- 
-- Revision History:
-- April 15, 2004: Initial version - NRG
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library work;
use work.s_pack.all;
use work.async_pack.all;

library components;
use components.component_pack.all;

entity s_lvds_rx_tb is
   port(
      error : out std_logic
   );
end s_lvds_rx_tb;

architecture behaviour of s_lvds_rx_tb is
   constant CLOCK_PERIOD : time := 80 ns;
   signal one : std_logic := '1';
   signal zero : std_logic := '0';
   
   signal reset : std_logic;
   signal reset_n : std_logic;
   signal clock : std_logic := '0';
   signal done : std_logic;
   signal enable : std_logic;
   signal rnd_clk : std_logic;
   
   -- transmitter signals
   signal tx_dat : std_logic_vector(7 downto 0);
   signal tx_we : std_logic;
   signal tx_ack : std_logic;
   signal tx_clock : std_logic := '0';
   signal tx_busy : std_logic;
   signal tx_stb : std_logic;
   signal tx_bit : std_logic;
   
   signal serial_busy : std_logic;
   signal serial_ack : std_logic;
   signal serial_data : std_logic_vector(7 downto 0);
   signal serial_we : std_logic;
   signal serial_stb : std_logic;

begin
      
   -- our LVDS receiver
   lvds_rx : s_lvds_rx
      port map (
         rst_i => reset,
         clk_i => clock,
         en_i => enable,
         done_o => done,
         tx_busy_i => serial_busy,
         tx_ack_i => serial_ack,
         tx_data_o => serial_data,
         tx_we_o => serial_we,
         tx_stb_o => serial_stb,
         lvds_i => tx_bit
      );
      
   -- our LVDS transmitter
   lvds_tx : async_tx
      port map(
         tx_o => tx_bit,
         busy_o => tx_busy,
         clk_i => tx_clock,
         rst_i => reset,
         dat_i => tx_dat,
         we_i => tx_we,
         stb_i => tx_stb,
         ack_o => tx_ack,
         cyc_i => one
      );
      
   -- dummy serial port
   serial_tx : async_tx
      port map(
         tx_o => open,
         busy_o => serial_busy,
         clk_i => tx_clock,
         rst_i => reset,
         dat_i => serial_data,
         we_i => serial_we,
         stb_i => serial_stb,
         ack_o => serial_ack,
         cyc_i => one
      );
      
   -- our random number generator
   random : prand
      generic map (size => 8)
      port map (
         clr_i => reset,
         clk_i => tx_clock,
         en_i => rnd_clk,
         out_o => tx_dat
      );
      
   reset <= '1', '0' after 2.5 * CLOCK_PERIOD;
   reset_n <= not reset;
   clock <= not clock after CLOCK_PERIOD / 16;
   tx_clock <= not tx_clock after CLOCK_PERIOD / 2;
   
   -- generate random number clock
   rnd_clk <= tx_ack and not tx_busy;

   -- tx_strobe controls the tx strobe lines
   tx_strobe : process (reset, tx_clock)
   begin
      if (reset = '1') then
         tx_we <= '0';
         tx_stb <= '0';
      elsif Rising_Edge(tx_clock) then
         tx_we <= not(tx_ack or tx_busy);
         tx_stb <= not(tx_ack or tx_busy);
      end if;
   end process tx_strobe;
   
   process(reset, clock)
   begin
      if (reset = '1') then
         enable <= '0';
      elsif (Rising_Edge(clock)) then
         enable <= '1';
      end if;
   end process;
   
end behaviour;
