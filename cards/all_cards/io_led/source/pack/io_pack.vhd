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
-- FPGA IO package.
-- 
-- Revision History:
-- Feb 29, 2004: Initial version. - NRG
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package io_pack is

   -- define io_led read/write constants
   constant IO_LED_ON : std_logic_vector(1 downto 0) := "01";
   constant IO_LED_OFF : std_logic_vector(1 downto 0) := "00";
   constant IO_LED_BUS_SIZE : integer := 1;

   component io_led
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
   end component;


end io_pack;
