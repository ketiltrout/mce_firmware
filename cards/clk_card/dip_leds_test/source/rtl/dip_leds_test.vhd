-- dip_leds_test.vhd
--
-- <revision control keyword substitutions e.g. $Id: dip_leds_test.vhd,v 1.6 2004/04/13 23:21:03 bburger Exp $>
--
-- Project:     SCUBA2
-- Author:      Bryce Burger
-- Organisation:    UBC Physics and Astronomy
--
-- Description:
-- This code implements the testbench for the Array ID
--
-- Revision history:
-- <date $Date: 2004/04/13 23:21:03 $>  -       <text>      - <initials $Author: bburger $>
--
------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity DIP_LEDS_TEST is
port(
   dip3 : in std_logic;
   dip4 : in std_logic;
   nfault_led : out std_logic;
   status_led : out std_logic;
   pow_ok_led : out std_logic
   );
end DIP_LEDS_TEST;

architecture BEH of DIP_LEDS_TEST is
begin
   status_led <= dip3;
   pow_ok_led <= dip4;
   nfault_led <= '1';
end BEH;
