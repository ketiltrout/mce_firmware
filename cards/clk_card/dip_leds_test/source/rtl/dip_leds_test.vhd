-- dip_leds_test.vhd
--
-- <revision control keyword substitutions e.g. $Id: dip_leds_test.vhd,v 1.2 2004/04/13 19:42:51 bburger Exp $>
--
-- Project:     SCUBA2
-- Author:      Bryce Burger
-- Organisation:    UBC Physics and Astronomy
--
-- Description:
-- This code implements the testbench for the Array ID
--
-- Revision history:
-- <date $Date: 2004/04/13 19:42:51 $>  -       <text>      - <initials $Author: bburger $>
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
   pow_ok_led : out std_logic;
   
   lvds_clk : in std_logic;
   lvds_cmd : in std_logic;
   lvds_sync : in std_logic;
   lvds_spr : in std_logic;
   
   lvds_txa : out std_logic;
   lvds_txb : out std_logic
   );
end DIP_LEDS_TEST;

architecture BEH of DIP_LEDS_TEST is
begin
   status_led <= dip3;
   pow_ok_led <= dip4;
   lvds_txa <= lvds_clk;
   lvds_txb <= lvds_clk;
   nfault_led <= '1';
end BEH;
