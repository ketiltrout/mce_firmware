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
-- Asynchronous transmitter and receiver clock generator for
-- a 57600 KBaud RS232 compatible interface
-- 
-- Revision History:
-- Jan 4, 2004: Initial version - NRG
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity async_clk is
   port(
      clk_i : in std_logic;   -- 25MHz input clock
      rst_i : in std_logic;   -- reset input
      txclk_o : out std_logic;   -- 57.6 kHz output
      rxclk_o : out std_logic   -- 462 kHz output
   );
end async_clk;

architecture behaviour of async_clk is
   constant TX_CLOCK_PERIOD : integer := 432;
   constant RX_CLOCK_PERIOD : integer := 54;
   
   signal rxclk : std_logic;
begin
   -- transmit clock output
   tx_clock : process(rst_i, rxclk)
      variable txcount : integer range 0 to (TX_CLOCK_PERIOD / RX_CLOCK_PERIOD) - 1;
   begin
      if (rst_i = '1') then
         txclk_o <= '0';
         txcount := (TX_CLOCK_PERIOD / RX_CLOCK_PERIOD) - 1;
      elsif (Rising_Edge(rxclk)) then
         if (txcount = 0) then
            txclk_o <= '1';
            txcount := (TX_CLOCK_PERIOD / RX_CLOCK_PERIOD) - 1;
         else
            txclk_o <= '0';
            txcount := txcount - 1;
         end if;
      end if;
   end process tx_clock;
   
   -- receive clock output
   rx_clock : process(rst_i, clk_i)
      variable rxcount : integer range 0 to RX_CLOCK_PERIOD - 1;
   begin
      if (rst_i = '1') then
         rxclk_o <= '0';
         rxcount := RX_CLOCK_PERIOD - 1;
      elsif (Rising_Edge(clk_i)) then
         if (rxcount = 0) then
            rxclk <= '1';
            rxclk_o <= '1';
            rxcount := RX_CLOCK_PERIOD - 1;
         else
            rxclk <= '0';
            rxclk_o <= '0';
            rxcount := rxcount - 1;
         end if;
      end if;
   end process rx_clock;
   
end behaviour;
