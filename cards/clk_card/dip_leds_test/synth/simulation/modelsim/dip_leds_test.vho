-- Copyright (C) 1991-2003 Altera Corporation
-- Any  megafunction  design,  and related netlist (encrypted  or  decrypted),
-- support information,  device programming or simulation file,  and any other
-- associated  documentation or information  provided by  Altera  or a partner
-- under  Altera's   Megafunction   Partnership   Program  may  be  used  only
-- to program  PLD  devices (but not masked  PLD  devices) from  Altera.   Any
-- other  use  of such  megafunction  design,  netlist,  support  information,
-- device programming or simulation file,  or any other  related documentation
-- or information  is prohibited  for  any  other purpose,  including, but not
-- limited to  modification,  reverse engineering,  de-compiling, or use  with
-- any other  silicon devices,  unless such use is  explicitly  licensed under
-- a separate agreement with  Altera  or a megafunction partner.  Title to the
-- intellectual property,  including patents,  copyrights,  trademarks,  trade
-- secrets,  or maskworks,  embodied in any such megafunction design, netlist,
-- support  information,  device programming or simulation file,  or any other
-- related documentation or information provided by  Altera  or a megafunction
-- partner, remains with Altera, the megafunction partner, or their respective
-- licensors. No other licenses, including any licenses needed under any third
-- party's intellectual property, are provided herein.

-- VENDOR "Altera"
-- PROGRAM "Quartus II"
-- VERSION "Version 3.0 Build 199 06/26/2003 SJ Full Version"

-- DATE "03/02/2004 11:55:27"

--
-- Device: Altera EP1S30F780C5 Package FBGA780
-- 

-- 
-- This VHDL file should be used for ModelSim (VHDL output from Quartus II) only
-- 

LIBRARY IEEE, stratix;
USE IEEE.std_logic_1164.all;
USE stratix.stratix_components.all;

ENTITY 	dip_leds_test IS
    PORT (
	dip : IN std_logic_vector(1 DOWNTO 0);
	led : OUT std_logic_vector(1 DOWNTO 0)
	);
END dip_leds_test;

ARCHITECTURE structure OF dip_leds_test IS
SIGNAL gnd : std_logic := '0';
SIGNAL vcc : std_logic := '1';
SIGNAL devclrn : std_logic := '1';
SIGNAL devpor : std_logic := '1';
SIGNAL devoe : std_logic := '0';
SIGNAL ww_dip : std_logic_vector(1 DOWNTO 0);
SIGNAL ww_led : std_logic_vector(1 DOWNTO 0);
SIGNAL dip_a1_a_apadio : std_logic;
SIGNAL dip_a0_a_apadio : std_logic;
SIGNAL led_a1_a_apadio : std_logic;
SIGNAL led_a0_a_apadio : std_logic;
SIGNAL dip_a1_a_acombout : std_logic;
SIGNAL dip_a0_a_acombout : std_logic;

BEGIN

ww_dip <= dip;
led <= ww_led;

dip_a1_a_aI : stratix_io 
-- pragma translate_off
GENERIC MAP (
	operation_mode => "input",
	ddio_mode => "none",
	input_register_mode => "none",
	output_register_mode => "none",
	oe_register_mode => "none",
	input_async_reset => "none",
	output_async_reset => "none",
	oe_async_reset => "none",
	input_sync_reset => "none",
	output_sync_reset => "none",
	oe_sync_reset => "none",
	input_power_up => "low",
	output_power_up => "low",
	oe_power_up => "low")
-- pragma translate_on
PORT MAP (
	devclrn => devclrn,
	devpor => devpor,
	devoe => devoe,
	padio => ww_dip(1),
	combout => dip_a1_a_acombout);

dip_a0_a_aI : stratix_io 
-- pragma translate_off
GENERIC MAP (
	operation_mode => "input",
	ddio_mode => "none",
	input_register_mode => "none",
	output_register_mode => "none",
	oe_register_mode => "none",
	input_async_reset => "none",
	output_async_reset => "none",
	oe_async_reset => "none",
	input_sync_reset => "none",
	output_sync_reset => "none",
	oe_sync_reset => "none",
	input_power_up => "low",
	output_power_up => "low",
	oe_power_up => "low")
-- pragma translate_on
PORT MAP (
	devclrn => devclrn,
	devpor => devpor,
	devoe => devoe,
	padio => ww_dip(0),
	combout => dip_a0_a_acombout);

led_a1_a_aI : stratix_io 
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output",
	ddio_mode => "none",
	input_register_mode => "none",
	output_register_mode => "none",
	oe_register_mode => "none",
	input_async_reset => "none",
	output_async_reset => "none",
	oe_async_reset => "none",
	input_sync_reset => "none",
	output_sync_reset => "none",
	oe_sync_reset => "none",
	input_power_up => "low",
	output_power_up => "low",
	oe_power_up => "low")
-- pragma translate_on
PORT MAP (
	datain => dip_a1_a_acombout,
	devclrn => devclrn,
	devpor => devpor,
	devoe => devoe,
	padio => ww_led(1));

led_a0_a_aI : stratix_io 
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output",
	ddio_mode => "none",
	input_register_mode => "none",
	output_register_mode => "none",
	oe_register_mode => "none",
	input_async_reset => "none",
	output_async_reset => "none",
	oe_async_reset => "none",
	input_sync_reset => "none",
	output_sync_reset => "none",
	oe_sync_reset => "none",
	input_power_up => "low",
	output_power_up => "low",
	oe_power_up => "low")
-- pragma translate_on
PORT MAP (
	datain => dip_a0_a_acombout,
	devclrn => devclrn,
	devpor => devpor,
	devoe => devoe,
	padio => ww_led(0));
END structure;


