-- dip_leds_test.vhd
--
-- <revision control keyword substitutions e.g. $Id$>
--
-- Project:		SCUBA2
-- Author:		Bryce Burger
-- Organisation:	UBC Physics and Astronomy
--
-- Description:
-- This code implements the testbench for the Array ID
--
-- Revision history:
-- <date $Date$>	-		<text>		- <initials $Author$>
--
------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

library sys_param;
use sys_param.wishbone_pack.all;

entity LIB_COMPILE_TEST is
port(
   dip : in std_logic_vector(1 downto 0);
   led : out std_logic_vector(1 downto 0)
   );
end LIB_COMPILE_TEST;

architecture BEH of LIB_COMPILE_TEST is
begin
   led <= dip;
end BEH;