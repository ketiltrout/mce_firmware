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
-- LED state function.
-- 
-- Revision History:
-- Feb 29, 2004: Initial version - NRG
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library work;
use work.io_pack.all;

---------------------------------------------------------------------
                     
entity s_led is
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
      led_o : out std_logic      -- physical LED pin
   );
end;

---------------------------------------------------------------------

architecture behaviour of s_led is

   -- state definitions
   type led_states is (LED_READ, LED_READ_WAIT, LED_WRITE, LED_WRITE_WAIT, LED_IDLE);
   signal led_state : led_states;

   -- LED wishbone signals
   signal dat_i   : std_logic_vector (IO_LED_BUS_SIZE downto 0);
   signal dat_o   : std_logic_vector (IO_LED_BUS_SIZE downto 0);
   signal we      : std_logic;
   signal stb     : std_logic;
   signal ack     : std_logic;
   signal cyc     : std_logic;
   
begin

   -- create the LED interface
   led : io_led
      port map(
         led_o => led_o,
         clk_i => clk_i,
         rst_i => rst_i,
         dat_i => dat_o,
         dat_o => dat_i,
         we_i => we,
         stb_i => stb,
         ack_o => ack,
         cyc_i => cyc
      );
   -- we don't need cyc_i
   cyc <= '1';
   
   -- we don't use the transmitter
   tx_data_o <= (others => '0');
   tx_we_o <= '0';
   tx_stb_o <= '0';
   
   -- led_test is our test state machine
   led_test : process (rst_i, en_i, clk_i)
   begin
      if ((rst_i = '1') or (en_i = '0')) then
         -- asynchronous reset
         led_state <= LED_READ;
         done_o <= '0';
         stb <= '0';
         we <= '0';
         dat_o <= IO_LED_OFF;
      elsif Rising_Edge(clk_i) then
         -- process our state machine
         case led_state is
            when LED_READ =>
               -- read the current led state
               stb <= '1';
               we <= '0';
               led_state <= LED_READ_WAIT;
            
            when LED_READ_WAIT =>
               -- wait for an ack
               if (ack = '1') then
                  stb <= '0';
                  we <= '0';
                  -- toggle led state
                  if (dat_i = IO_LED_OFF) then
                     dat_o <= IO_LED_ON;
                  else
                     dat_o <= IO_LED_OFF;
                  end if;
                  led_state <= LED_WRITE;
               end if;
            
            when LED_WRITE =>
               -- write the new data
               stb <= '1';
               we <= '1';
               led_state <= LED_WRITE_WAIT;
               
            when LED_WRITE_WAIT =>
               -- wait for an ack
               if (ack = '1') then
                  stb <= '0';
                  we <= '0';
                  led_state <= LED_IDLE;
               end if;
            
            when LED_IDLE =>
               -- all done
               done_o <= '1';
               
            when others =>
               led_state <= LED_IDLE;
               
         end case;
      end if;
   end process led_test;


end;
