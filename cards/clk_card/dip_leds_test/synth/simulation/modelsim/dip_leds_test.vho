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
-- VERSION "Version 3.0 Build 245 10/09/2003 Service Pack 2 SJ Full Version"

-- DATE "04/13/2004 16:08:48"

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
	dip3 : IN std_logic;
	dip4 : IN std_logic;
	nfault_led : OUT std_logic;
	status_led : OUT std_logic;
	pow_ok_led : OUT std_logic
	);
END dip_leds_test;

ARCHITECTURE structure OF dip_leds_test IS
SIGNAL gnd : std_logic := '0';
SIGNAL vcc : std_logic := '1';
SIGNAL devclrn : std_logic := '1';
SIGNAL devpor : std_logic := '1';
SIGNAL devoe : std_logic := '0';
SIGNAL ww_dip3 : std_logic;
SIGNAL ww_dip4 : std_logic;
SIGNAL ww_nfault_led : std_logic;
SIGNAL ww_status_led : std_logic;
SIGNAL ww_pow_ok_led : std_logic;
SIGNAL dip3_apadio : std_logic;
SIGNAL dip4_apadio : std_logic;
SIGNAL nfault_led_apadio : std_logic;
SIGNAL status_led_apadio : std_logic;
SIGNAL pow_ok_led_apadio : std_logic;
SIGNAL dip3_acombout : std_logic;
SIGNAL dip4_acombout : std_logic;

BEGIN

ww_dip3 <= dip3;
ww_dip4 <= dip4;
nfault_led <= ww_nfault_led;
status_led <= ww_status_led;
pow_ok_led <= ww_pow_ok_led;

dip3_aI : stratix_io 
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
	padio => ww_dip3,
	combout => dip3_acombout);

dip4_aI : stratix_io 
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
	padio => ww_dip4,
	combout => dip4_acombout);

status_led_aI : stratix_io 
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
	datain => dip3_acombout,
	devclrn => devclrn,
	devpor => devpor,
	devoe => devoe,
	padio => ww_status_led);

pow_ok_led_aI : stratix_io 
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
	datain => dip4_acombout,
	devclrn => devclrn,
	devpor => devpor,
	devoe => devoe,
	padio => ww_pow_ok_led);

nfault_led_aI : stratix_io 
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
	datain => VCC,
	devclrn => devclrn,
	devpor => devpor,
	devoe => devoe,
	padio => ww_nfault_led);
END structure;


