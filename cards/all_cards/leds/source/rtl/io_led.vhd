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
-- FPGA LED IO implementation.
-- 
-- Revision History:
-- Feb 29, 2004: Initial version - NRG
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.io_pack.all;

---------------------------------------------------------------------

entity io_led is
   port( 
      led_o  : out std_logic;  -- physical LED pin

      -- Wishbone signals
      clk_i   : in std_logic;
      rst_i   : in std_logic;
      dat_i   : in std_logic_vector (IO_LED_BUS_SIZE downto 0);
      dat_o   : out std_logic_vector (IO_LED_BUS_SIZE downto 0);
      we_i    : in std_logic;
      stb_i   : in std_logic;
      ack_o   : out std_logic;
      cyc_i   : in std_logic
   );
end io_led ;

---------------------------------------------------------------------

architecture behaviour of io_led is

   signal led_bit : std_logic;
   signal led_reg : std_logic_vector (IO_LED_BUS_SIZE downto 0);
   
   constant LED_ON : std_logic := '0';
   constant LED_OFF : std_logic := '1';

begin

   process (rst_i, clk_i)
   begin
      if (rst_i = '1') then
         -- default led state is off
         led_bit <= LED_OFF;
         led_reg <= IO_LED_OFF;
         ack_o <= '0';
      elsif Rising_Edge(clk_i) then
         -- do we have a valid wishbone transaction?
         if ((stb_i = '1') and (cyc_i = '1')) then
            -- yes - are we writing a new value?
            if (we_i = '1') then
               -- yes, so update our registers
               case dat_i is
                  when IO_LED_OFF =>
                     led_bit <= LED_OFF;
                     led_reg <= IO_LED_OFF;
                  when IO_LED_ON =>
                     led_bit <= LED_ON;
                     led_reg <= IO_LED_ON;
                  when others =>
                     led_bit <= led_bit;
                     led_reg <= led_reg;
               end case;
            end if;
         end if;
         
         -- don't forget about the ack signal!
         ack_o <= stb_i and cyc_i;
      end if;
   end process;
   
   led_o <= led_bit;
   dat_o <= led_reg;

end behaviour;
