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
-- Asynchronous transmitter and receiver test bench.
-- 
-- Revision History:
-- Dec 29, 2003: Initial version - NRG
--
-- $Log: tb_async.vhd,v $
-- Revision 1.1  2004/04/28 02:57:14  erniel
-- renamed file from async_tb
--
--
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library work;
use work.async_pack.all;

entity tb_async is
   port(
      error : out std_logic   -- goes high when we detect an error
   );
end tb_async;

architecture behaviour of tb_async is

   constant CLOCK_PERIOD : time := 100 ns;
   signal zero : std_logic := '0';
   signal one : std_logic := '1';

   -- transmitter signals
   signal tx_clock : std_logic := '0';
   signal tx_busy : std_logic;
   signal tx_bit : std_logic;
   signal tx_data : std_logic_vector(7 downto 0);
   signal tx_write : std_logic := '0';
   signal tx_strobe : std_logic := '0';
   signal tx_ack : std_logic;
   
   -- reciever signals
   signal rx_clock : std_logic := '0';
   signal rx_bit : std_logic;
   signal rx_flag : std_logic;
   signal rx_error : std_logic;
   signal rx_read : std_logic;
   signal rx_data : std_logic_vector(7 downto 0);
   signal rx_strobe : std_logic;
   signal rx_ack : std_logic;

   -- internal signals
   signal lfsr : std_logic_vector(9 downto 0) := "0000000000";
   signal rx_comp : std_logic_vector(7 downto 0);
   signal reset : std_logic;
   signal noise : std_logic;

begin

   receiver : async_rx
      port map(
         rx_i => rx_bit,
         flag_o => rx_flag,
         error_o => rx_error,
         clk_i => rx_clock,
         rst_i => reset,
         dat_o => rx_data,
         we_i => zero,
         stb_i => rx_strobe,
         ack_o => rx_ack,
         cyc_i => one
   );

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

   -- system wide reset
   reset <= '1', '0' after 2.5 * CLOCK_PERIOD;

   transmit : process(tx_clock)
   variable tx : std_logic;
   begin
      if (reset = '1') then
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
   
   -- transmit word control
   tx_wctl : process(reset, tx_ack, tx_clock)
   begin
      if (reset = '1') then
         tx_data <= "01011010";
         rx_comp <= "00000000";
      end if;
      if (Rising_Edge(tx_clock) and (tx_ack = '1')) then
         tx_data <= tx_data(6 downto 0) & (not(tx_data(7)));
         rx_comp <= tx_data;
      end if;
   end process tx_wctl;

   noise_gen : process(reset, rx_clock)
   variable cnt : integer;
   begin
      if (reset = '1') then
         noise <= '0';
         cnt := 0;
      elsif (Rising_Edge(rx_clock)) then
         if (cnt = 5) then
            lfsr <= lfsr(8 downto 0) & (not (lfsr(9) xor lfsr(6)));
            cnt := 0;
            noise <= lfsr(0);
         else
            cnt := cnt + 1;
            noise <= '0';
         end if;
      end if;
   end process noise_gen;

   receive : process(rx_clock)
   begin
      if (Rising_Edge(rx_clock)) then
         rx_strobe <= rx_flag;
      end if;
   end process receive;
   rx_bit <= tx_bit or noise;
   
   -- rx_check verifies the tranmitted data
   rx_check : process(reset, rx_ack)
   begin
      if (reset = '1') then
         error <= '0';
      elsif (Rising_Edge(rx_ack)) then
         if (rx_comp = rx_data) then
            error <= '0' or rx_error;
         else
            error <= '1';
         end if;
      end if;
   end process rx_check;

   -- generate the transmit clock
   tx_clock <= not tx_clock after CLOCK_PERIOD / 2;

   -- generate the rx clock which is 8x the transmit clock
   rx_clock <= not rx_clock after CLOCK_PERIOD / 16;

end behaviour;
