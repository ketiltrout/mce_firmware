# Copyright (C) 1991-2004 Altera Corporation
# Any  megafunction  design,  and related netlist (encrypted  or  decrypted),
# support information,  device programming or simulation file,  and any other
# associated  documentation or information  provided by  Altera  or a partner
# under  Altera's   Megafunction   Partnership   Program  may  be  used  only
# to program  PLD  devices (but not masked  PLD  devices) from  Altera.   Any
# other  use  of such  megafunction  design,  netlist,  support  information,
# device programming or simulation file,  or any other  related documentation
# or information  is prohibited  for  any  other purpose,  including, but not
# limited to  modification,  reverse engineering,  de-compiling, or use  with
# any other  silicon devices,  unless such use is  explicitly  licensed under
# a separate agreement with  Altera  or a megafunction partner.  Title to the
# intellectual property,  including patents,  copyrights,  trademarks,  trade
# secrets,  or maskworks,  embodied in any such megafunction design, netlist,
# support  information,  device programming or simulation file,  or any other
# related documentation or information provided by  Altera  or a megafunction
# partner, remains with Altera, the megafunction partner, or their respective
# licensors. No other licenses, including any licenses needed under any third
# party's intellectual property, are provided herein.

# Quartus II: Generate Tcl File for Project
# File: all_test_rc_EP1S40.tcl
# Generated on: Wed Nov 02 09:13:55 2005

# Load Quartus II Tcl Project package
package require ::quartus::project
package require ::quartus::flow

set need_to_close_project 0
set make_assignments 1

# Check that the right project is open
if {[is_project_open]} {
	if {[string compare $quartus(project) "all_test"]} {
		puts "Project all_test is not open"
		set make_assignments 0
	}
} else {
	# Only open if not already open
	if {[project_exists all_test]} {
		project_open -cmp all_test all_test
	} else {
		project_new -cmp all_test all_test
	}
	set need_to_close_project 1
}

# Make assignments
if {$make_assignments} {
	catch { set_global_assignment -name ORIGINAL_QUARTUS_VERSION "4.1 SP2" } result
	catch { set_global_assignment -name PROJECT_CREATION_TIME_DATE "10:28:24  OCTOBER 20, 2005" } result
	catch { set_global_assignment -name LAST_QUARTUS_VERSION "4.1 SP2" } result
	catch { set_global_assignment -name VHDL_FILE ../../../library/sys_param/source/rtl/command_pack.vhd } result
	catch { set_global_assignment -name VHDL_FILE ../../../library/sys_param/source/rtl/data_types_pack.vhd } result
	catch { set_global_assignment -name VHDL_FILE ../../../library/sys_param/source/rtl/frame_timing_pack.vhd } result
	catch { set_global_assignment -name VHDL_FILE ../../../library/sys_param/source/rtl/general_pack.vhd } result
	catch { set_global_assignment -name VHDL_FILE ../../../library/sys_param/source/rtl/wishbone_pack.vhd } result
	catch { set_global_assignment -name VHDL_FILE ../../../library/components/source/rtl/component_pack.vhd } result
	catch { set_global_assignment -name VHDL_FILE ../../../library/components/source/rtl/us_timer.vhd } result
	catch { set_global_assignment -name VHDL_FILE ../../../library/components/source/rtl/binary_counter.vhd } result
	catch { set_global_assignment -name VHDL_FILE ../../../library/components/source/rtl/counter.vhd } result
	catch { set_global_assignment -name VHDL_FILE ../../../library/components/source/rtl/counter_xstep.vhd } result
	catch { set_global_assignment -name VHDL_FILE ../../../library/components/source/rtl/hex2ascii.vhd } result
	catch { set_global_assignment -name VHDL_FILE ../../../library/components/source/rtl/lfsr.vhd } result
	catch { set_global_assignment -name VHDL_FILE ../../../library/components/source/rtl/ns_timer.vhd } result
	catch { set_global_assignment -name VHDL_FILE ../../../library/components/source/rtl/one_wire_master.vhd } result
	catch { set_global_assignment -name VHDL_FILE ../../../library/components/source/rtl/reg.vhd } result
	catch { set_global_assignment -name VHDL_FILE ../../../library/components/source/rtl/fifo.vhd } result
	catch { set_global_assignment -name VHDL_FILE ../../../library/components/source/rtl/serial_crc.vhd } result
	catch { set_global_assignment -name VHDL_FILE ../../../library/components/source/rtl/shift_reg.vhd } result
	catch { set_global_assignment -name VHDL_FILE ../../id_thermo/source/rtl/id_thermo.vhd } result
	catch { set_global_assignment -name VHDL_FILE ../../id_thermo/source/tb/id_thermo_test_wrapper.vhd } result
	catch { set_global_assignment -name VHDL_FILE ../../slot_id/source/rtl/slot_id_pack.vhd } result
	catch { set_global_assignment -name VHDL_FILE ../../slot_id/source/rtl/slot_id.vhd } result
	catch { set_global_assignment -name VHDL_FILE ../../slot_id/source/tb/slot_id_test_wrapper.vhd } result
	catch { set_global_assignment -name VHDL_FILE ../../dip_switch/source/rtl/dip_switch_pack.vhd } result
	catch { set_global_assignment -name VHDL_FILE ../../dip_switch/source/rtl/dip_switch.vhd } result
	catch { set_global_assignment -name VHDL_FILE ../../dip_switch/source/tb/dip_switch_test_wrapper.vhd } result
	catch { set_global_assignment -name VHDL_FILE ../../async/source/rtl/async_pack.vhd } result
	catch { set_global_assignment -name VHDL_FILE ../../async/source/rtl/ascii_pack.vhd } result
	catch { set_global_assignment -name VHDL_FILE ../../async/source/rtl/rs232_rx.vhd } result
	catch { set_global_assignment -name VHDL_FILE ../../async/source/rtl/rs232_tx.vhd } result
	catch { set_global_assignment -name VHDL_FILE ../source/all_test_pll.vhd } result
	catch { set_global_assignment -name VHDL_FILE ../source/all_test.vhd } result
	catch { set_global_assignment -name SIGNALTAP_FILE test1.stp } result
	catch { set_global_assignment -name COMPILER_SETTINGS all_test } result
	catch { set_global_assignment -name SIMULATOR_SETTINGS all_test } result
	catch { set_global_assignment -name SOFTWARE_SETTINGS all_test } result
	catch { set_global_assignment -name FAMILY Stratix } result
	catch { set_global_assignment -name DEVICE EP1S40F780C6 } result
	catch { set_global_assignment -name RESERVE_ALL_UNUSED_PINS "AS INPUT TRI-STATED" } result
	catch { set_global_assignment -name ON_CHIP_BITSTREAM_DECOMPRESSION OFF } result
	catch { set_global_assignment -name USE_COMPILER_SETTINGS all_test } result
	catch { set_global_assignment -name ENABLE_SIGNALTAP On } result
	catch { set_global_assignment -name USE_SIGNALTAP_FILE test1.stp } result
	catch { set_global_assignment -name SLD_NODE_CREATOR_ID 110 -section_id auto_signaltap_0 } result
	catch { set_global_assignment -name SLD_NODE_ENTITY_NAME sld_signaltap -section_id auto_signaltap_0 } result
	catch { set_global_assignment -name SLD_NODE_PARAMETER_ASSIGNMENT "SLD_NODE_INFO=402681344" -section_id auto_signaltap_0 } result
	catch { set_global_assignment -name SLD_NODE_PARAMETER_ASSIGNMENT "SLD_DATA_BIT_CNTR_BITS=6" -section_id auto_signaltap_0 } result
	catch { set_global_assignment -name SLD_NODE_PARAMETER_ASSIGNMENT "SLD_TRIGGER_LEVEL=1" -section_id auto_signaltap_0 } result
	catch { set_global_assignment -name SLD_NODE_PARAMETER_ASSIGNMENT "SLD_TRIGGER_IN_ENABLED=0" -section_id auto_signaltap_0 } result
	catch { set_global_assignment -name SLD_NODE_PARAMETER_ASSIGNMENT "SLD_ADVANCED_TRIGGER_ENTITY=basic,1," -section_id auto_signaltap_0 } result
	catch { set_global_assignment -name SLD_NODE_PARAMETER_ASSIGNMENT "SLD_TRIGGER_LEVEL_PIPELINE=1" -section_id auto_signaltap_0 } result
	catch { set_global_assignment -name SLD_NODE_PARAMETER_ASSIGNMENT "SLD_ENABLE_ADVANCED_TRIGGER=0" -section_id auto_signaltap_0 } result
	catch { set_global_assignment -name SLD_NODE_PARAMETER_ASSIGNMENT "SLD_RAM_BLOCK_TYPE=AUTO" -section_id auto_signaltap_0 } result
	catch { set_global_assignment -name SLD_NODE_PARAMETER_ASSIGNMENT "SLD_SAMPLE_DEPTH=8192" -section_id auto_signaltap_0 } result
	catch { set_global_assignment -name SLD_NODE_PARAMETER_ASSIGNMENT "SLD_MEM_ADDRESS_BITS=13" -section_id auto_signaltap_0 } result
	catch { set_global_assignment -name SLD_NODE_PARAMETER_ASSIGNMENT "SLD_DATA_BITS=64" -section_id auto_signaltap_0 } result
	catch { set_global_assignment -name SLD_NODE_PARAMETER_ASSIGNMENT "SLD_TRIGGER_BITS=64" -section_id auto_signaltap_0 } result
	catch { set_global_assignment -name SLD_NODE_PARAMETER_ASSIGNMENT "SLD_NODE_CRC_LOWORD=8330" -section_id auto_signaltap_0 } result
	catch { set_global_assignment -name SLD_NODE_PARAMETER_ASSIGNMENT "SLD_NODE_CRC_HIWORD=37546" -section_id auto_signaltap_0 } result
	catch { set_global_assignment -name LOGICLOCK_INCREMENTAL_COMPILE_ASSIGNMENT off } result
#
# PIN ASSIGNMENT for Rev B Readout Card
#
	catch { set_location_assignment PIN_C12 -to rx } result
	catch { set_location_assignment PIN_A16 -to cardid } result
	catch { set_location_assignment PIN_B12 -to tx } result
	catch { set_location_assignment PIN_H20 -to led\[0\] } result
	catch { set_location_assignment PIN_H19 -to led\[1\] } result
	catch { set_location_assignment PIN_J20 -to led\[2\] } result
	catch { set_location_assignment PIN_AC9 -to nrst } result
	catch { set_location_assignment PIN_K17 -to inclk } result
	catch { set_location_assignment PIN_D5 -to slot\[0\] } result
	catch { set_location_assignment PIN_B6 -to slot\[1\] } result
	catch { set_location_assignment PIN_C9 -to slot\[2\] } result
	catch { set_location_assignment PIN_D10 -to slot\[3\] } result
	catch { set_location_assignment PIN_K10 -to dip\[0\] } result
	catch { set_location_assignment PIN_L11 -to dip\[1\] } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_clk -to "all_test_pll:clk0\|c0" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in\[0\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data0\|reg_o\[0\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in\[1\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data0\|reg_o\[1\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in\[2\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data0\|reg_o\[2\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in\[3\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data0\|reg_o\[3\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in\[4\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data0\|reg_o\[4\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in\[5\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data0\|reg_o\[5\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in\[6\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data0\|reg_o\[6\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in\[7\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data0\|reg_o\[7\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in\[8\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data1\|reg_o\[0\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in\[9\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data1\|reg_o\[1\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in\[10\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data1\|reg_o\[2\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in\[11\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data1\|reg_o\[3\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in\[12\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data1\|reg_o\[4\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in\[13\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data1\|reg_o\[5\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in\[14\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data1\|reg_o\[6\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in\[15\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data1\|reg_o\[7\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in\[16\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data2\|reg_o\[0\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in\[17\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data2\|reg_o\[1\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in\[18\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data2\|reg_o\[2\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in\[19\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data2\|reg_o\[3\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in\[20\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data2\|reg_o\[4\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in\[21\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data2\|reg_o\[5\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in\[22\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data2\|reg_o\[6\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in\[23\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data2\|reg_o\[7\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in\[24\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data3\|reg_o\[0\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in\[25\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data3\|reg_o\[1\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in\[26\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data3\|reg_o\[2\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in\[27\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data3\|reg_o\[3\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in\[28\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data3\|reg_o\[4\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in\[29\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data3\|reg_o\[5\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in\[30\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data3\|reg_o\[6\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in\[31\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data3\|reg_o\[7\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in\[32\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data4\|reg_o\[0\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in\[33\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data4\|reg_o\[1\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in\[34\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data4\|reg_o\[2\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in\[35\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data4\|reg_o\[3\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in\[36\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data4\|reg_o\[4\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in\[37\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data4\|reg_o\[5\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in\[38\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data4\|reg_o\[6\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in\[39\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data4\|reg_o\[7\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in\[40\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data5\|reg_o\[0\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in\[41\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data5\|reg_o\[1\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in\[42\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data5\|reg_o\[2\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in\[43\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data5\|reg_o\[3\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in\[44\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data5\|reg_o\[4\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in\[45\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data5\|reg_o\[5\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in\[46\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data5\|reg_o\[6\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in\[47\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data5\|reg_o\[7\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in\[48\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:thermo_data0\|reg_o\[0\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in\[49\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:thermo_data0\|reg_o\[1\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in\[50\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:thermo_data0\|reg_o\[2\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in\[51\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:thermo_data0\|reg_o\[3\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in\[52\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:thermo_data0\|reg_o\[4\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in\[53\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:thermo_data0\|reg_o\[5\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in\[54\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:thermo_data0\|reg_o\[6\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in\[55\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:thermo_data0\|reg_o\[7\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in\[56\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:thermo_data1\|reg_o\[0\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in\[57\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:thermo_data1\|reg_o\[1\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in\[58\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:thermo_data1\|reg_o\[2\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in\[59\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:thermo_data1\|reg_o\[3\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in\[60\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:thermo_data1\|reg_o\[4\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in\[61\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:thermo_data1\|reg_o\[5\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in\[62\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:thermo_data1\|reg_o\[6\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in\[63\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:thermo_data1\|reg_o\[7\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in\[0\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data0\|reg_o\[0\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in\[1\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data0\|reg_o\[1\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in\[2\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data0\|reg_o\[2\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in\[3\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data0\|reg_o\[3\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in\[4\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data0\|reg_o\[4\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in\[5\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data0\|reg_o\[5\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in\[6\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data0\|reg_o\[6\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in\[7\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data0\|reg_o\[7\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in\[8\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data1\|reg_o\[0\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in\[9\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data1\|reg_o\[1\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in\[10\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data1\|reg_o\[2\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in\[11\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data1\|reg_o\[3\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in\[12\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data1\|reg_o\[4\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in\[13\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data1\|reg_o\[5\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in\[14\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data1\|reg_o\[6\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in\[15\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data1\|reg_o\[7\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in\[16\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data2\|reg_o\[0\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in\[17\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data2\|reg_o\[1\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in\[18\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data2\|reg_o\[2\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in\[19\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data2\|reg_o\[3\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in\[20\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data2\|reg_o\[4\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in\[21\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data2\|reg_o\[5\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in\[22\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data2\|reg_o\[6\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in\[23\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data2\|reg_o\[7\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in\[24\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data3\|reg_o\[0\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in\[25\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data3\|reg_o\[1\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in\[26\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data3\|reg_o\[2\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in\[27\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data3\|reg_o\[3\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in\[28\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data3\|reg_o\[4\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in\[29\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data3\|reg_o\[5\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in\[30\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data3\|reg_o\[6\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in\[31\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data3\|reg_o\[7\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in\[32\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data4\|reg_o\[0\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in\[33\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data4\|reg_o\[1\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in\[34\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data4\|reg_o\[2\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in\[35\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data4\|reg_o\[3\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in\[36\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data4\|reg_o\[4\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in\[37\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data4\|reg_o\[5\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in\[38\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data4\|reg_o\[6\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in\[39\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data4\|reg_o\[7\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in\[40\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data5\|reg_o\[0\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in\[41\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data5\|reg_o\[1\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in\[42\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data5\|reg_o\[2\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in\[43\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data5\|reg_o\[3\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in\[44\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data5\|reg_o\[4\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in\[45\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data5\|reg_o\[5\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in\[46\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data5\|reg_o\[6\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in\[47\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:id_data5\|reg_o\[7\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in\[48\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:thermo_data0\|reg_o\[0\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in\[49\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:thermo_data0\|reg_o\[1\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in\[50\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:thermo_data0\|reg_o\[2\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in\[51\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:thermo_data0\|reg_o\[3\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in\[52\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:thermo_data0\|reg_o\[4\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in\[53\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:thermo_data0\|reg_o\[5\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in\[54\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:thermo_data0\|reg_o\[6\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in\[55\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:thermo_data0\|reg_o\[7\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in\[56\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:thermo_data1\|reg_o\[0\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in\[57\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:thermo_data1\|reg_o\[1\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in\[58\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:thermo_data1\|reg_o\[2\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in\[59\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:thermo_data1\|reg_o\[3\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in\[60\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:thermo_data1\|reg_o\[4\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in\[61\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:thermo_data1\|reg_o\[5\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in\[62\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:thermo_data1\|reg_o\[6\]" -section_id auto_signaltap_0 } result
	catch { set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in\[63\] -to "id_thermo_test_wrapper:id_thermo_test\|id_thermo:id_thermo_test\|reg:thermo_data1\|reg_o\[7\]" -section_id auto_signaltap_0 } result

	# Including default assignments
	catch { set_global_assignment -name PROJECT_SHOW_ENTITY_NAME ON } result
	catch { set_global_assignment -name VER_COMPATIBLE_DB_DIR export_db } result
	catch { set_global_assignment -name AUTO_EXPORT_VER_COMPATIBLE_DB OFF } result
	catch { set_global_assignment -name DO_MIN_ANALYSIS ON } result
	catch { set_global_assignment -name DO_MIN_TIMING OFF } result
	catch { set_global_assignment -name REPORT_IO_PATHS_SEPARATELY OFF } result
	catch { set_global_assignment -name CLOCK_ANALYSIS_ONLY OFF } result
	catch { set_global_assignment -name CUT_OFF_PATHS_BETWEEN_CLOCK_DOMAINS ON } result
	catch { set_global_assignment -name CUT_OFF_READ_DURING_WRITE_PATHS ON } result
	catch { set_global_assignment -name CUT_OFF_CLEAR_AND_PRESET_PATHS ON } result
	catch { set_global_assignment -name CUT_OFF_IO_PIN_FEEDBACK ON } result
	catch { set_global_assignment -name IGNORE_CLOCK_SETTINGS OFF } result
	catch { set_global_assignment -name MUX_RESTRUCTURE AUTO } result
	catch { set_global_assignment -name ENABLE_IP_DEBUG OFF } result
	catch { set_global_assignment -name SPEED_DISK_USAGE_TRADEOFF NORMAL } result
	catch { set_global_assignment -name SAVE_DISK_SPACE ON } result
	catch { set_global_assignment -name DISABLE_OCP_HW_EVAL OFF } result
	catch { set_global_assignment -name RECOMPILE_QUESTION YES } result
	catch { set_global_assignment -name DEVICE_FILTER_PACKAGE ANY } result
	catch { set_global_assignment -name DEVICE_FILTER_PIN_COUNT ANY } result
	catch { set_global_assignment -name DEVICE_FILTER_SPEED_GRADE ANY } result
	catch { set_global_assignment -name EDA_DESIGN_ENTRY_SYNTHESIS_TOOL "<None>" } result
	catch { set_global_assignment -name VERILOG_INPUT_VERSION VERILOG_2001 } result
	catch { set_global_assignment -name VHDL_INPUT_VERSION VHDL93 } result
	catch { set_global_assignment -name COMPILATION_LEVEL FULL } result
	catch { set_global_assignment -name TRUE_WYSIWYG_FLOW OFF } result
	catch { set_global_assignment -name SMART_COMPILE_IGNORES_TDC_FOR_STRATIX_PLL_CHANGES OFF } result
	catch { set_global_assignment -name STATE_MACHINE_PROCESSING AUTO } result
	catch { set_global_assignment -name DSP_BLOCK_BALANCING AUTO } result
	catch { set_global_assignment -name NOT_GATE_PUSH_BACK ON } result
	catch { set_global_assignment -name ALLOW_POWER_UP_DONT_CARE ON } result
	catch { set_global_assignment -name REMOVE_REDUNDANT_LOGIC_CELLS OFF } result
	catch { set_global_assignment -name REMOVE_DUPLICATE_REGISTERS ON } result
	catch { set_global_assignment -name IGNORE_CARRY_BUFFERS OFF } result
	catch { set_global_assignment -name IGNORE_CASCADE_BUFFERS OFF } result
	catch { set_global_assignment -name IGNORE_GLOBAL_BUFFERS OFF } result
	catch { set_global_assignment -name IGNORE_ROW_GLOBAL_BUFFERS OFF } result
	catch { set_global_assignment -name IGNORE_LCELL_BUFFERS OFF } result
	catch { set_global_assignment -name MAX7000_IGNORE_LCELL_BUFFERS AUTO } result
	catch { set_global_assignment -name IGNORE_SOFT_BUFFERS ON } result
	catch { set_global_assignment -name MAX7000_IGNORE_SOFT_BUFFERS OFF } result
	catch { set_global_assignment -name LIMIT_AHDL_INTEGERS_TO_32_BITS OFF } result
	catch { set_global_assignment -name USE_LPM_FOR_AHDL_OPERATORS ON } result
	catch { set_global_assignment -name AUTO_GLOBAL_CLOCK_MAX ON } result
	catch { set_global_assignment -name AUTO_GLOBAL_OE_MAX ON } result
	catch { set_global_assignment -name MAX_AUTO_GLOBAL_REGISTER_CONTROLS ON } result
	catch { set_global_assignment -name AUTO_IMPLEMENT_IN_ROM OFF } result
	catch { set_global_assignment -name STRATIX_TECHNOLOGY_MAPPER LUT } result
	catch { set_global_assignment -name MAX7000_TECHNOLOGY_MAPPER "PRODUCT TERM" } result
	catch { set_global_assignment -name APEX20K_TECHNOLOGY_MAPPER LUT } result
	catch { set_global_assignment -name MERCURY_TECHNOLOGY_MAPPER LUT } result
	catch { set_global_assignment -name FLEX6K_TECHNOLOGY_MAPPER LUT } result
	catch { set_global_assignment -name FLEX10K_TECHNOLOGY_MAPPER LUT } result
	catch { set_global_assignment -name STRATIXII_OPTIMIZATION_TECHNIQUE BALANCED } result
	catch { set_global_assignment -name CYCLONE_OPTIMIZATION_TECHNIQUE BALANCED } result
	catch { set_global_assignment -name CYCLONEII_OPTIMIZATION_TECHNIQUE BALANCED } result
	catch { set_global_assignment -name STRATIX_OPTIMIZATION_TECHNIQUE BALANCED } result
	catch { set_global_assignment -name MAXII_OPTIMIZATION_TECHNIQUE BALANCED } result
	catch { set_global_assignment -name MAX7000_OPTIMIZATION_TECHNIQUE SPEED } result
	catch { set_global_assignment -name APEX20K_OPTIMIZATION_TECHNIQUE BALANCED } result
	catch { set_global_assignment -name MERCURY_OPTIMIZATION_TECHNIQUE AREA } result
	catch { set_global_assignment -name FLEX6K_OPTIMIZATION_TECHNIQUE AREA } result
	catch { set_global_assignment -name FLEX10K_OPTIMIZATION_TECHNIQUE AREA } result
	catch { set_global_assignment -name ALLOW_XOR_GATE_USAGE ON } result
	catch { set_global_assignment -name AUTO_LCELL_INSERTION ON } result
	catch { set_global_assignment -name CARRY_CHAIN_LENGTH 48 } result
	catch { set_global_assignment -name FLEX6K_CARRY_CHAIN_LENGTH 32 } result
	catch { set_global_assignment -name FLEX10K_CARRY_CHAIN_LENGTH 32 } result
	catch { set_global_assignment -name MERCURY_CARRY_CHAIN_LENGTH 48 } result
	catch { set_global_assignment -name STRATIX_CARRY_CHAIN_LENGTH 70 } result
	catch { set_global_assignment -name STRATIXII_CARRY_CHAIN_LENGTH 70 } result
	catch { set_global_assignment -name CASCADE_CHAIN_LENGTH 2 } result
	catch { set_global_assignment -name PARALLEL_EXPANDER_CHAIN_LENGTH 16 } result
	catch { set_global_assignment -name MAX7000_PARALLEL_EXPANDER_CHAIN_LENGTH 4 } result
	catch { set_global_assignment -name AUTO_CARRY_CHAINS ON } result
	catch { set_global_assignment -name AUTO_CASCADE_CHAINS ON } result
	catch { set_global_assignment -name AUTO_PARALLEL_EXPANDERS ON } result
	catch { set_global_assignment -name AUTO_OPEN_DRAIN_PINS ON } result
	catch { set_global_assignment -name REMOVE_DUPLICATE_LOGIC ON } result
	catch { set_global_assignment -name ADV_NETLIST_OPT_SYNTH_WYSIWYG_REMAP OFF } result
	catch { set_global_assignment -name ADV_NETLIST_OPT_SYNTH_GATE_RETIME OFF } result
	catch { set_global_assignment -name ADV_NETLIST_OPT_RETIME_CORE_AND_IO ON } result
	catch { set_global_assignment -name AUTO_ROM_RECOGNITION ON } result
	catch { set_global_assignment -name AUTO_RAM_RECOGNITION ON } result
	catch { set_global_assignment -name AUTO_DSP_RECOGNITION ON } result
	catch { set_global_assignment -name AUTO_SHIFT_REGISTER_RECOGNITION ON } result
	catch { set_global_assignment -name AUTO_CLOCK_ENABLE_RECOGNITION ON } result
	catch { set_global_assignment -name SHOW_REGISTRATION_MESSAGE ON } result
	catch { set_global_assignment -name ALLOW_SYNCH_CTRL_USAGE ON } result
	catch { set_global_assignment -name AUTO_RAM_BLOCK_BALANCING ON } result
	catch { set_global_assignment -name ESTIMATE_POWER_DURING_COMPILATION OFF } result
	catch { set_global_assignment -name AUTO_RESOURCE_SHARING OFF } result
	catch { set_global_assignment -name USE_NEW_TEXT_REPORT_TABLE_FORMAT OFF } result
	catch { set_global_assignment -name ALLOW_ANY_RAM_SIZE_FOR_RECOGNITION OFF } result
	catch { set_global_assignment -name ALLOW_ANY_ROM_SIZE_FOR_RECOGNITION OFF } result
	catch { set_global_assignment -name ALLOW_ANY_SHIFT_REGISTER_SIZE_FOR_RECOGNITION OFF } result
	catch { set_global_assignment -name MAX7000_FANIN_PER_CELL 100 } result
	catch { set_global_assignment -name IGNORE_DUPLICATE_DESIGN_ENTITY OFF } result
	catch { set_global_assignment -name VHDL_VERILOG_BREAK_LOOPS OFF } result
	catch { set_global_assignment -name TOP_LEVEL_ENTITY all_test } result
	catch { set_global_assignment -name ECO_ALLOW_ROUTING_CHANGES OFF } result
	catch { set_global_assignment -name BASE_PIN_OUT_FILE_ON_SAMEFRAME_DEVICE OFF } result
	catch { set_global_assignment -name ENABLE_JTAG_BST_SUPPORT OFF } result
	catch { set_global_assignment -name MAX7000_ENABLE_JTAG_BST_SUPPORT ON } result
	catch { set_global_assignment -name RESERVE_NCEO_AFTER_CONFIGURATION "USE AS REGULAR IO" } result
	catch { set_global_assignment -name CYCLONEII_RESERVE_NCEO_AFTER_CONFIGURATION "AS OUTPUT DRIVING GROUND" } result
	catch { set_global_assignment -name STRATIX_UPDATE_MODE STANDARD } result
	catch { set_global_assignment -name STRATIX_II_CONFIGURATION_SCHEME "PASSIVE SERIAL" } result
	catch { set_global_assignment -name CYCLONEII_CONFIGURATION_SCHEME "ACTIVE SERIAL" } result
	catch { set_global_assignment -name APEX20K_CONFIGURATION_SCHEME "PASSIVE SERIAL" } result
	catch { set_global_assignment -name STRATIX_CONFIGURATION_SCHEME "PASSIVE SERIAL" } result
	catch { set_global_assignment -name CYCLONE_CONFIGURATION_SCHEME "ACTIVE SERIAL" } result
	catch { set_global_assignment -name EXCALIBUR_CONFIGURATION_SCHEME "PASSIVE SERIAL" } result
	catch { set_global_assignment -name MERCURY_CONFIGURATION_SCHEME "PASSIVE SERIAL" } result
	catch { set_global_assignment -name FLEX6K_CONFIGURATION_SCHEME "PASSIVE SERIAL" } result
	catch { set_global_assignment -name FLEX10K_CONFIGURATION_SCHEME "PASSIVE SERIAL" } result
	catch { set_global_assignment -name APEXII_CONFIGURATION_SCHEME "PASSIVE SERIAL" } result
	catch { set_global_assignment -name USER_START_UP_CLOCK OFF } result
	catch { set_global_assignment -name ENABLE_VREFA_PIN OFF } result
	catch { set_global_assignment -name ENABLE_VREFB_PIN OFF } result
	catch { set_global_assignment -name AUTO_RESTART_CONFIGURATION ON } result
	catch { set_global_assignment -name RELEASE_CLEARS_BEFORE_TRI_STATES OFF } result
	catch { set_global_assignment -name ENABLE_DEVICE_WIDE_RESET OFF } result
	catch { set_global_assignment -name ENABLE_DEVICE_WIDE_OE OFF } result
	catch { set_global_assignment -name FLEX10K_ENABLE_LOCK_OUTPUT OFF } result
	catch { set_global_assignment -name ENABLE_INIT_DONE_OUTPUT OFF } result
	catch { set_global_assignment -name RESERVE_NWS_NRS_NCS_CS_AFTER_CONFIGURATION "USE AS REGULAR IO" } result
	catch { set_global_assignment -name RESERVE_RDYNBUSY_AFTER_CONFIGURATION "USE AS REGULAR IO" } result
	catch { set_global_assignment -name RESERVE_DATA7_THROUGH_DATA1_AFTER_CONFIGURATION "USE AS REGULAR IO" } result
	catch { set_global_assignment -name RESERVE_DATA0_AFTER_CONFIGURATION "AS INPUT TRI-STATED" } result
	catch { set_global_assignment -name RESERVE_ASDO_AFTER_CONFIGURATION "USE AS REGULAR IO" } result
	catch { set_global_assignment -name CRC_ERROR_CHECKING OFF } result
	catch { set_global_assignment -name OPTIMIZE_HOLD_TIMING "IO PATHS AND MINIMUM TPD PATHS" } result
	catch { set_global_assignment -name OPTIMIZE_TIMING "NORMAL COMPILATION" } result
	catch { set_global_assignment -name OPTIMIZE_IOC_REGISTER_PLACEMENT_FOR_TIMING ON } result
	catch { set_global_assignment -name DISABLE_PLL_COMPENSATION_DELAY_CHANGE_WARNING OFF } result
	catch { set_global_assignment -name FIT_ONLY_ONE_ATTEMPT OFF } result
	catch { set_global_assignment -name STRIPE_TO_PLD_BRIDGE_EPXA4_10 "MEGALAB COLUMN 1" } result
	catch { set_global_assignment -name PROCESSOR_DEBUG_EXTENSIONS_EPXA4_10 "MEGALAB COLUMN 2" } result
	catch { set_global_assignment -name PLD_TO_STRIPE_INTERRUPTS_EPXA4_10 "MEGALAB COLUMN 2" } result
	catch { set_global_assignment -name STRIPE_TO_PLD_INTERRUPTS_EPXA4_10 "MEGALAB COLUMN 2" } result
	catch { set_global_assignment -name DPRAM_INPUT_EPXA4_10 "DEFAULT INPUT ROUTING OPTIONS" } result
	catch { set_global_assignment -name DPRAM_OUTPUT_EPXA4_10 "DEFAULT OUTPUT ROUTING OPTIONS" } result
	catch { set_global_assignment -name DPRAM_OTHER_SIGNALS_EPXA4_10 "DEFAULT OTHER ROUTING OPTIONS" } result
	catch { set_global_assignment -name DPRAM_DEEP_MODE_INPUT_EPXA4_10 "MEGALAB COLUMN 3" } result
	catch { set_global_assignment -name DPRAM_WIDE_MODE_INPUT_EPXA4_10 "LOWER TO 3 UPPER TO 4" } result
	catch { set_global_assignment -name DPRAM_SINGLE_PORT_MODE_INPUT_EPXA4_10 "DPRAM0 TO 3 DPRAM1 TO 4" } result
	catch { set_global_assignment -name DPRAM_DUAL_PORT_MODE_INPUT_EPXA4_10 "DPRAM0 TO 3 DPRAM1 TO 4" } result
	catch { set_global_assignment -name DPRAM_DEEP_MODE_OUTPUT_EPXA4_10 "MEGALAB COLUMN 3" } result
	catch { set_global_assignment -name DPRAM_WIDE_MODE_OUTPUT_EPXA4_10 "LOWER TO 3 UPPER TO 4ESB" } result
	catch { set_global_assignment -name DPRAM_SINGLE_PORT_MODE_OUTPUT_EPXA4_10 "DPRAM0 TO 3 DPRAM1 TO 4ESB" } result
	catch { set_global_assignment -name DPRAM_DUAL_PORT_MODE_OUTPUT_EPXA4_10 "DPRAM0 TO 3 DPRAM1 TO 4ESB" } result
	catch { set_global_assignment -name DPRAM_DEEP_MODE_OTHER_SIGNALS_EPXA4_10 "MEGALAB COLUMN 3" } result
	catch { set_global_assignment -name DPRAM_WIDE_MODE_OTHER_SIGNALS_EPXA4_10 "MEGALAB COLUMN 3" } result
	catch { set_global_assignment -name DPRAM_SINGLE_PORT_MODE_OTHER_SIGNALS_EPXA4_10 "DPRAM0 TO 3 DPRAM1 TO 4" } result
	catch { set_global_assignment -name DPRAM_DUAL_PORT_MODE_OTHER_SIGNALS_EPXA4_10 "DPRAM0 TO 3 DPRAM1 TO 4" } result
	catch { set_global_assignment -name DPRAM_8BIT_16BIT_SINGLE_PORT_MODE_INPUT_EPXA1 "MEGALAB COLUMN 1" } result
	catch { set_global_assignment -name DPRAM_32BIT_SINGLE_PORT_MODE_INPUT_EPXA1 "MEGALAB COLUMN 1" } result
	catch { set_global_assignment -name DPRAM_DUAL_PORT_MODE_INPUT_EPXA1 "DPRAM0 TO 1 DPRAM1 TO 2" } result
	catch { set_global_assignment -name DPRAM_8BIT_16BIT_SINGLE_PORT_MODE_OUTPUT_EPXA1 "MEGALAB COLUMN 1" } result
	catch { set_global_assignment -name DPRAM_32BIT_SINGLE_PORT_MODE_OUTPUT_EPXA1 "LOWER TO 1ESB UPPER TO 1" } result
	catch { set_global_assignment -name DPRAM_DUAL_PORT_MODE_OUTPUT_EPXA1 "DPRAM0 TO 1 DPRAM1 TO 2" } result
	catch { set_global_assignment -name DPRAM_8BIT_16BIT_SINGLE_PORT_MODE_OTHER_SIGNALS_EPXA1 "MEGALAB COLUMN 1" } result
	catch { set_global_assignment -name DPRAM_32BIT_SINGLE_PORT_MODE_OTHER_SIGNALS_EPXA1 "MEGALAB COLUMN 1" } result
	catch { set_global_assignment -name DPRAM_DUAL_PORT_MODE_OTHER_SIGNALS_EPXA1 "DPRAM0 TO 1 DPRAM1 TO 2" } result
	catch { set_global_assignment -name FINAL_PLACEMENT_OPTIMIZATION AUTOMATICALLY } result
	catch { set_global_assignment -name SEED 1 } result
	catch { set_global_assignment -name SLOW_SLEW_RATE OFF } result
	catch { set_global_assignment -name PCI_IO OFF } result
	catch { set_global_assignment -name TURBO_BIT ON } result
	catch { set_global_assignment -name WEAK_PULL_UP_RESISTOR OFF } result
	catch { set_global_assignment -name ENABLE_BUS_HOLD_CIRCUITRY OFF } result
	catch { set_global_assignment -name AUTO_GLOBAL_MEMORY_CONTROLS OFF } result
	catch { set_global_assignment -name AUTO_PACKED_REGISTERS_STRATIXII AUTO } result
	catch { set_global_assignment -name AUTO_PACKED_REGISTERS_MAXII AUTO } result
	catch { set_global_assignment -name AUTO_PACKED_REGISTERS_CYCLONE AUTO } result
	catch { set_global_assignment -name AUTO_PACKED_REGISTERS OFF } result
	catch { set_global_assignment -name AUTO_PACKED_REGISTERS_STRATIX AUTO } result
	catch { set_global_assignment -name NORMAL_LCELL_INSERT ON } result
	catch { set_global_assignment -name CARRY_OUT_PINS_LCELL_INSERT ON } result
	catch { set_global_assignment -name AUTO_DELAY_CHAINS ON } result
	catch { set_global_assignment -name AUTO_FAST_INPUT_REGISTERS OFF } result
	catch { set_global_assignment -name AUTO_FAST_OUTPUT_REGISTERS OFF } result
	catch { set_global_assignment -name AUTO_FAST_OUTPUT_ENABLE_REGISTERS OFF } result
	catch { set_global_assignment -name AUTO_MERGE_PLLS ON } result
	catch { set_global_assignment -name AUTO_TURBO_BIT ON } result
	catch { set_global_assignment -name PHYSICAL_SYNTHESIS_COMBO_LOGIC OFF } result
	catch { set_global_assignment -name PHYSICAL_SYNTHESIS_REGISTER_DUPLICATION OFF } result
	catch { set_global_assignment -name PHYSICAL_SYNTHESIS_REGISTER_RETIMING OFF } result
	catch { set_global_assignment -name IO_PLACEMENT_OPTIMIZATION ON } result
	catch { set_global_assignment -name ALLOW_LVTTL_LVCMOS_INPUT_LEVELS_TO_OVERDRIVE_INPUT_BUFFER OFF } result
	catch { set_global_assignment -name OVERRIDE_DEFAULT_ELECTROMIGRATION_PARAMETERS OFF } result
	catch { set_global_assignment -name FITTER_EFFORT "AUTO FIT" } result
	catch { set_global_assignment -name FITTER_AUTO_EFFORT_DESIRED_SLACK_MARGIN 0ns } result
	catch { set_global_assignment -name PHYSICAL_SYNTHESIS_EFFORT NORMAL } result
	catch { set_global_assignment -name ROUTER_LCELL_INSERTION_AND_LOGIC_DUPLICATION AUTO } result
	catch { set_global_assignment -name ROUTER_REGISTER_DUPLICATION OFF } result
	catch { set_global_assignment -name ALLOW_SERIES_TERMINATION OFF } result
	catch { set_global_assignment -name ALLOW_PARALLEL_TERMINATION OFF } result
	catch { set_global_assignment -name STRATIXGX_ALLOW_CLOCK_FANOUT_WITH_ANALOG_RESET OFF } result
	catch { set_global_assignment -name AUTO_GLOBAL_CLOCK ON } result
	catch { set_global_assignment -name AUTO_GLOBAL_OE ON } result
	catch { set_global_assignment -name AUTO_GLOBAL_REGISTER_CONTROLS ON } result
	catch { set_global_assignment -name NUMBER_OF_SOURCES_PER_DESTINATION_TO_REPORT 10 } result
	catch { set_global_assignment -name NUMBER_OF_DESTINATION_TO_REPORT 10 } result
	catch { set_global_assignment -name NUMBER_OF_PATHS_TO_REPORT 200 } result
	catch { set_global_assignment -name DEFAULT_HOLD_MULTICYCLE "SAME AS MULTICYCLE" } result
	catch { set_global_assignment -name ANALYZE_LATCHES_AS_SYNCHRONOUS_ELEMENTS OFF } result
	catch { set_global_assignment -name EDA_SIMULATION_TOOL "<None>" } result
	catch { set_global_assignment -name EDA_TIMING_ANALYSIS_TOOL "<None>" } result
	catch { set_global_assignment -name EDA_BOARD_DESIGN_TOOL "<None>" } result
	catch { set_global_assignment -name EDA_FORMAL_VERIFICATION_TOOL "<None>" } result
	catch { set_global_assignment -name EDA_RESYNTHESIS_TOOL "<None>" } result
	catch { set_global_assignment -name HARDCOPY_EXTERNAL_CLOCK_JITTER "0.0 ns" } result
	catch { set_global_assignment -name HARDCOPY_INPUT_TRANSITION_CLOCK_PIN "0.1 ns" } result
	catch { set_global_assignment -name HARDCOPY_INPUT_TRANSITION_DATA_PIN "1.0 ns" } result
	catch { set_global_assignment -name COMPRESSION_MODE OFF } result
	catch { set_global_assignment -name CLOCK_SOURCE INTERNAL } result
	catch { set_global_assignment -name CONFIGURATION_CLOCK_FREQUENCY "10 MHZ" } result
	catch { set_global_assignment -name CONFIGURATION_CLOCK_DIVISOR 1 } result
	catch { set_global_assignment -name ENABLE_LOW_VOLTAGE_MODE_ON_CONFIG_DEVICE ON } result
	catch { set_global_assignment -name FLEX6K_ENABLE_LOW_VOLTAGE_MODE_ON_CONFIG_DEVICE OFF } result
	catch { set_global_assignment -name FLEX10K_ENABLE_LOW_VOLTAGE_MODE_ON_CONFIG_DEVICE ON } result
	catch { set_global_assignment -name MAX7000S_JTAG_USER_CODE FFFF } result
	catch { set_global_assignment -name STRATIX_JTAG_USER_CODE FFFFFFFF } result
	catch { set_global_assignment -name APEX20K_JTAG_USER_CODE FFFFFFFF } result
	catch { set_global_assignment -name MERCURY_JTAG_USER_CODE FFFFFFFF } result
	catch { set_global_assignment -name FLEX10K_JTAG_USER_CODE 7F } result
	catch { set_global_assignment -name MAX7000_JTAG_USER_CODE FFFFFFFF } result
	catch { set_global_assignment -name MAX7000_USE_CHECKSUM_AS_USERCODE OFF } result
	catch { set_global_assignment -name USE_CHECKSUM_AS_USERCODE OFF } result
	catch { set_global_assignment -name SECURITY_BIT OFF } result
	catch { set_global_assignment -name USE_CONFIGURATION_DEVICE ON } result
	catch { set_global_assignment -name STRATIX_II_CONFIGURATION_DEVICE AUTO } result
	catch { set_global_assignment -name APEX20K_CONFIGURATION_DEVICE AUTO } result
	catch { set_global_assignment -name EXCALIBUR_CONFIGURATION_DEVICE AUTO } result
	catch { set_global_assignment -name MERCURY_CONFIGURATION_DEVICE AUTO } result
	catch { set_global_assignment -name FLEX6K_CONFIGURATION_DEVICE AUTO } result
	catch { set_global_assignment -name FLEX10K_CONFIGURATION_DEVICE AUTO } result
	catch { set_global_assignment -name CYCLONE_CONFIGURATION_DEVICE AUTO } result
	catch { set_global_assignment -name STRATIX_CONFIGURATION_DEVICE AUTO } result
	catch { set_global_assignment -name APEX20K_CONFIG_DEVICE_JTAG_USER_CODE FFFFFFFF } result
	catch { set_global_assignment -name STRATIX_CONFIG_DEVICE_JTAG_USER_CODE FFFFFFFF } result
	catch { set_global_assignment -name MERCURY_CONFIG_DEVICE_JTAG_USER_CODE FFFFFFFF } result
	catch { set_global_assignment -name FLEX10K_CONFIG_DEVICE_JTAG_USER_CODE FFFFFFFF } result
	catch { set_global_assignment -name EPROM_USE_CHECKSUM_AS_USERCODE OFF } result
	catch { set_global_assignment -name AUTO_INCREMENT_CONFIG_DEVICE_JTAG_USER_CODE ON } result
	catch { set_global_assignment -name DISABLE_NCS_AND_OE_PULLUPS_ON_CONFIG_DEVICE OFF } result
	catch { set_global_assignment -name GENERATE_TTF_FILE OFF } result
	catch { set_global_assignment -name GENERATE_RBF_FILE OFF } result
	catch { set_global_assignment -name GENERATE_HEX_FILE OFF } result
	catch { set_global_assignment -name HEXOUT_FILE_START_ADDRESS 0 } result
	catch { set_global_assignment -name HEXOUT_FILE_COUNT_DIRECTION UP } result
	catch { set_global_assignment -name START_TIME 0ns } result
	catch { set_global_assignment -name SIMULATION_MODE TIMING } result
	catch { set_global_assignment -name AUTO_USE_SIMULATION_PDB_NETLIST OFF } result
	catch { set_global_assignment -name ADD_DEFAULT_PINS_TO_SIMULATION_OUTPUT_WAVEFORMS ON } result
	catch { set_global_assignment -name POWER_ESTIMATION_START_TIME "0 ns" } result
	catch { set_global_assignment -name SETUP_HOLD_DETECTION OFF } result
	catch { set_global_assignment -name CHECK_OUTPUTS OFF } result
	catch { set_global_assignment -name SIMULATION_COVERAGE ON } result
	catch { set_global_assignment -name GLITCH_DETECTION OFF } result
	catch { set_global_assignment -name GLITCH_INTERVAL 1ns } result
	catch { set_global_assignment -name ESTIMATE_POWER_CONSUMPTION OFF } result
	catch { set_global_assignment -name SIM_NO_DELAYS OFF } result
	catch { set_global_assignment -name PROCESSOR ARM922T } result
	catch { set_global_assignment -name BYTE_ORDER "LITTLE ENDIAN" } result
	catch { set_global_assignment -name TOOLSET "CUSTOM BUILD" } result
	catch { set_global_assignment -name OUTPUT_TYPE "INTEL HEX" } result
	catch { set_global_assignment -name PROGRAMMING_FILE_TYPE "NO PROGRAMMING FILE" } result
	catch { set_global_assignment -name DO_POST_BUILD_COMMAND_LINE OFF } result
	catch { set_global_assignment -name USE_C_PREPROCESSOR_FOR_GNU_ASM_FILES ON } result
	catch { set_global_assignment -name ARM_CPP_COMMAND_LINE "-O2" } result
	catch { set_global_assignment -name GNUPRO_NIOS_CPP_COMMAND_LINE "-O3" } result
	catch { set_global_assignment -name GNUPRO_ARM_CPP_COMMAND_LINE "-O3 -fomit-frame-pointer" } result
	catch { set_global_assignment -name DRC_REPORT_TOP_FANOUT ON } result
	catch { set_global_assignment -name DRC_TOP_FANOUT 50 } result
	catch { set_global_assignment -name DRC_REPORT_FANOUT_EXCEEDING ON } result
	catch { set_global_assignment -name DRC_FANOUT_EXCEEDING 30 } result
	catch { set_global_assignment -name ASSG_CAT ON } result
	catch { set_global_assignment -name ASSG_RULE_MISSING_FMAX ON } result
	catch { set_global_assignment -name ASSG_RULE_MISSING_TIMING ON } result
	catch { set_global_assignment -name SIGNALRACE_RULE_TRISTATE ON } result
	catch { set_global_assignment -name HCPY_PLL_MULTIPLE_CLK_NETWORK_TYPES ON } result
	catch { set_global_assignment -name NONSYNCHSTRUCT_RULE_ASYN_RAM ON } result
	catch { set_global_assignment -name HARDCOPY_FLOW_AUTOMATION MIGRATION_ONLY } result
	catch { set_global_assignment -name ENABLE_DRC_SETTINGS OFF } result
	catch { set_global_assignment -name CLK_CAT ON } result
	catch { set_global_assignment -name CLK_RULE_COMB_CLOCK ON } result
	catch { set_global_assignment -name CLK_RULE_INV_CLOCK ON } result
	catch { set_global_assignment -name CLK_RULE_GATING_SCHEME ON } result
	catch { set_global_assignment -name CLK_RULE_INPINS_CLKNET ON } result
	catch { set_global_assignment -name CLK_RULE_CLKNET_CLKSPINES ON } result
	catch { set_global_assignment -name CLK_RULE_MIX_EDGES ON } result
	catch { set_global_assignment -name RESET_CAT ON } result
	catch { set_global_assignment -name RESET_RULE_INPINS_RESETNET ON } result
	catch { set_global_assignment -name RESET_RULE_UNSYNCH_EXRESET ON } result
	catch { set_global_assignment -name RESET_RULE_IMSYNCH_EXRESET ON } result
	catch { set_global_assignment -name RESET_RULE_COMB_ASYNCH_RESET ON } result
	catch { set_global_assignment -name RESET_RULE_UNSYNCH_ASYNCH_DOMAIN ON } result
	catch { set_global_assignment -name RESET_RULE_IMSYNCH_ASYNCH_DOMAIN ON } result
	catch { set_global_assignment -name TIMING_CAT ON } result
	catch { set_global_assignment -name TIMING_RULE_SHIFT_REG ON } result
	catch { set_global_assignment -name TIMING_RULE_COIN_CLKEDGE ON } result
	catch { set_global_assignment -name NONSYNCHSTRUCT_RULE_COMB_DRIVES_RAM_WE ON } result
	catch { set_global_assignment -name NONSYNCHSTRUCT_CAT ON } result
	catch { set_global_assignment -name NONSYNCHSTRUCT_RULE_COMBLOOP ON } result
	catch { set_global_assignment -name NONSYNCHSTRUCT_RULE_REG_LOOP ON } result
	catch { set_global_assignment -name NONSYNCHSTRUCT_RULE_DELAY_CHAIN ON } result
	catch { set_global_assignment -name NONSYNCHSTRUCT_RULE_RIPPLE_CLK ON } result
	catch { set_global_assignment -name NONSYNCHSTRUCT_RULE_ILLEGAL_PULSE_GEN ON } result
	catch { set_global_assignment -name NONSYNCHSTRUCT_RULE_MULTI_VIBRATOR ON } result
	catch { set_global_assignment -name NONSYNCHSTRUCT_RULE_SRLATCH ON } result
	catch { set_global_assignment -name NONSYNCHSTRUCT_RULE_LATCH_UNIDENTIFIED ON } result
	catch { set_global_assignment -name SIGNALRACE_CAT ON } result
	catch { set_global_assignment -name ACLK_CAT ON } result
	catch { set_global_assignment -name ACLK_RULE_NO_SZER_ACLK_DOMAIN ON } result
	catch { set_global_assignment -name ACLK_RULE_SZER_BTW_ACLK_DOMAIN ON } result
	catch { set_global_assignment -name ACLK_RULE_IMSZER_ADOMAIN ON } result
	catch { set_global_assignment -name HCPY_CAT ON } result
	catch { set_global_assignment -name HCPY_VREF_PINS ON } result
	catch { set_global_assignment -name MERGE_HEX_FILE OFF } result
	catch { set_global_assignment -name GENERATE_SVF_FILE OFF } result
	catch { set_global_assignment -name GENERATE_ISC_FILE OFF } result
	catch { set_global_assignment -name GENERATE_JAM_FILE OFF } result
	catch { set_global_assignment -name GENERATE_JBC_FILE OFF } result
	catch { set_global_assignment -name GENERATE_JBC_FILE_COMPRESSED ON } result
	catch { set_global_assignment -name GENERATE_CONFIG_SVF_FILE OFF } result
	catch { set_global_assignment -name GENERATE_CONFIG_ISC_FILE OFF } result
	catch { set_global_assignment -name GENERATE_CONFIG_JAM_FILE OFF } result
	catch { set_global_assignment -name GENERATE_CONFIG_JBC_FILE OFF } result
	catch { set_global_assignment -name GENERATE_CONFIG_JBC_FILE_COMPRESSED ON } result
	catch { set_global_assignment -name GENERATE_CONFIG_HEXOUT_FILE OFF } result
	catch { set_global_assignment -name SIGNALPROBE_ALLOW_OVERUSE OFF } result
	catch { set_global_assignment -name SIGNALPROBE_DURING_NORMAL_COMPILATION OFF } result
	catch { set_global_assignment -name HUB_ENTITY_NAME sld_hub } result
	catch { set_global_assignment -name HUB_INSTANCE_NAME sld_hub_inst } result
	catch { set_global_assignment -name AUTO_INSERT_SLD_HUB_ENTITY ENABLE } result

	# Commit assignments
	export_assignments

    # start recompile
    execute_flow -compile

	# Close project
	if {$need_to_close_project} {
		project_close
	}
}
