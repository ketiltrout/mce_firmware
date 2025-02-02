# Copyright (C) 1991-2008 Altera Corporation
# Your use of Altera Corporation's design tools, logic functions 
# and other software and tools, and its AMPP partner logic 
# functions, and any output files from any of the foregoing 
# (including device programming or simulation files), and any 
# associated documentation or information are expressly subject 
# to the terms and conditions of the Altera Program License 
# Subscription Agreement, Altera MegaCore Function License 
# Agreement, or other applicable license agreement, including, 
# without limitation, that your use is for the sole purpose of 
# programming logic devices manufactured by Altera and sold by 
# Altera or its authorized distributors.  Please refer to the 
# applicable agreement for further details.

# Quartus II: Generate Tcl File for Project
# File: readout_card_stratix_iii.tcl
# Generated on: Thu Jun 18 16:02:08 2009

# Load Quartus II Tcl Project package
package require ::quartus::project

set need_to_close_project 0
set make_assignments 1

# Check that the right project is open
if {[is_project_open]} {
	if {[string compare $quartus(project) "readout_card_stratix_iii"]} {
		puts "Project readout_card_stratix_iii is not open"
		set make_assignments 0
	}
} else {
	# Only open if not already open
	if {[project_exists readout_card_stratix_iii]} {
		project_open -revision readout_card_stratix_iii readout_card_stratix_iii
	} else {
		project_new -revision readout_card_stratix_iii readout_card_stratix_iii
	}
	set need_to_close_project 1
}

# Make assignments
if {$make_assignments} {
	set_global_assignment -name FAMILY "Stratix III"
	set_global_assignment -name DEVICE EP3SE50F780C4
	set_global_assignment -name ORIGINAL_QUARTUS_VERSION 4.1
	set_global_assignment -name PROJECT_CREATION_TIME_DATE "13:51:03  NOVEMBER 16, 2004"
	set_global_assignment -name LAST_QUARTUS_VERSION 8.1
	set_global_assignment -name EDA_DESIGN_ENTRY_SYNTHESIS_TOOL "<None>"
	set_global_assignment -name EDA_INPUT_DATA_FORMAT VHDL -section_id eda_design_synthesis
	set_global_assignment -name EDA_SIMULATION_TOOL "ModelSim-Altera (VHDL)"
	set_global_assignment -name EDA_OUTPUT_DATA_FORMAT VHDL -section_id eda_simulation
	set_global_assignment -name USE_GENERATED_PHYSICAL_CONSTRAINTS OFF -section_id eda_blast_fpga
	set_global_assignment -name SEARCH_PATH "c:\\altera\\81\\ip\\altera\\ddr2_high_perf\\lib/"
	set_global_assignment -name STRATIXII_OPTIMIZATION_TECHNIQUE SPEED
	set_global_assignment -name MIN_CORE_JUNCTION_TEMP 0
	set_global_assignment -name MAX_CORE_JUNCTION_TEMP 85
	set_global_assignment -name NOMINAL_CORE_SUPPLY_VOLTAGE 1.1V
	set_global_assignment -name ENABLE_CLOCK_LATENCY ON
	set_global_assignment -name ROUTER_TIMING_OPTIMIZATION_LEVEL MAXIMUM
	set_global_assignment -name MUX_RESTRUCTURE OFF
	set_global_assignment -name STATE_MACHINE_PROCESSING "ONE-HOT"
	set_global_assignment -name REMOVE_REDUNDANT_LOGIC_CELLS ON
	set_global_assignment -name IGNORE_CARRY_BUFFERS OFF
	set_global_assignment -name IGNORE_CASCADE_BUFFERS OFF
	set_global_assignment -name IGNORE_GLOBAL_BUFFERS OFF
	set_global_assignment -name IGNORE_LCELL_BUFFERS ON
	set_global_assignment -name STRATIX_OPTIMIZATION_TECHNIQUE SPEED
	set_global_assignment -name ADV_NETLIST_OPT_SYNTH_WYSIWYG_REMAP ON
	set_global_assignment -name ADV_NETLIST_OPT_SYNTH_GATE_RETIME ON
	set_global_assignment -name AUTO_RESOURCE_SHARING OFF
	set_global_assignment -name ALLOW_ANY_RAM_SIZE_FOR_RECOGNITION ON
	set_global_assignment -name ALLOW_ANY_ROM_SIZE_FOR_RECOGNITION ON
	set_global_assignment -name ALLOW_ANY_SHIFT_REGISTER_SIZE_FOR_RECOGNITION OFF
	set_global_assignment -name AUTO_ENABLE_SMART_COMPILE OFF
	set_global_assignment -name ENABLE_DEVICE_WIDE_RESET OFF
	set_global_assignment -name CRC_ERROR_CHECKING ON
	set_global_assignment -name FINAL_PLACEMENT_OPTIMIZATION AUTOMATICALLY
	set_global_assignment -name AUTO_GLOBAL_MEMORY_CONTROLS ON
	set_global_assignment -name AUTO_PACKED_REGISTERS_STRATIX NORMAL
	set_global_assignment -name PHYSICAL_SYNTHESIS_COMBO_LOGIC ON
	set_global_assignment -name PHYSICAL_SYNTHESIS_REGISTER_DUPLICATION ON
	set_global_assignment -name PHYSICAL_SYNTHESIS_REGISTER_RETIMING ON
	set_global_assignment -name PHYSICAL_SYNTHESIS_EFFORT EXTRA
	set_global_assignment -name ERROR_CHECK_FREQUENCY_DIVISOR 2
	set_global_assignment -name STRATIX_DEVICE_IO_STANDARD LVTTL
	set_global_assignment -name NUMBER_OF_PATHS_TO_REPORT 500
	set_global_assignment -name ON_CHIP_BITSTREAM_DECOMPRESSION OFF
	set_global_assignment -name ASSG_RULE_MISSING_TIMING OFF
	set_global_assignment -name ENABLE_DRC_SETTINGS ON
	set_global_assignment -name RESET_RULE_UNSYNCH_EXRESET OFF
	set_global_assignment -name RESET_RULE_IMSYNCH_EXRESET OFF
	set_global_assignment -name RESET_RULE_COMB_ASYNCH_RESET OFF
	set_global_assignment -name RESET_RULE_UNSYNCH_ASYNCH_DOMAIN OFF
	set_global_assignment -name RESET_RULE_IMSYNCH_ASYNCH_DOMAIN OFF
	set_global_assignment -name ENABLE_SIGNALTAP OFF
	set_global_assignment -name USE_SIGNALTAP_FILE raw.stp
	set_global_assignment -name DUTY_CYCLE 50 -section_id inclk
	set_global_assignment -name INVERT_BASE_CLOCK OFF -section_id inclk
	set_global_assignment -name MULTIPLY_BASE_CLOCK_PERIOD_BY 1 -section_id inclk
	set_global_assignment -name DIVIDE_BASE_CLOCK_PERIOD_BY 1 -section_id inclk
	set_global_assignment -name FMAX_REQUIREMENT "25 MHz" -section_id inclk
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch0|fsfb_ctrl:i_fsfb_ctrl|dac_clk" -section_id "DAC clk output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch1|fsfb_ctrl:i_fsfb_ctrl|dac_clk" -section_id "DAC clk output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch2|fsfb_ctrl:i_fsfb_ctrl|dac_clk" -section_id "DAC clk output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch3|fsfb_ctrl:i_fsfb_ctrl|dac_clk" -section_id "DAC clk output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch4|fsfb_ctrl:i_fsfb_ctrl|dac_clk" -section_id "DAC clk output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch5|fsfb_ctrl:i_fsfb_ctrl|dac_clk" -section_id "DAC clk output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch6|fsfb_ctrl:i_fsfb_ctrl|dac_clk" -section_id "DAC clk output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch7|fsfb_ctrl:i_fsfb_ctrl|dac_clk" -section_id "DAC clk output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch0|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[0]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch0|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[1]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch0|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[2]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch0|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[3]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch0|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[4]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch0|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[5]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch0|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[6]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch0|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[7]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch0|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[8]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch0|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[9]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch0|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[10]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch0|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[11]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch0|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[12]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch0|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[13]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch1|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[0]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch1|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[1]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch1|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[2]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch1|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[3]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch1|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[4]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch1|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[5]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch1|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[6]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch1|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[7]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch1|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[8]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch1|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[9]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch1|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[10]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch1|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[11]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch1|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[12]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch1|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[13]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch2|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[0]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch2|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[1]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch2|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[2]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch2|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[3]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch2|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[4]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch2|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[5]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch2|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[6]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch2|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[7]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch2|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[8]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch2|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[9]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch2|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[10]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch2|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[11]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch2|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[12]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch2|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[13]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch3|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[0]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch3|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[1]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch3|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[2]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch3|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[3]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch3|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[4]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch3|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[5]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch3|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[6]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch3|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[7]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch3|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[8]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch3|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[9]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch3|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[10]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch3|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[11]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch3|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[12]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch3|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[13]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch4|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[0]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch4|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[1]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch4|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[2]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch4|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[3]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch4|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[4]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch4|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[5]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch4|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[6]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch4|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[7]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch4|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[8]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch4|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[9]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch4|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[10]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch4|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[11]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch4|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[12]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch4|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[13]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch5|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[0]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch5|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[1]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch5|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[2]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch5|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[3]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch5|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[4]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch5|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[5]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch5|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[6]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch5|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[7]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch5|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[8]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch5|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[9]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch5|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[10]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch5|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[11]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch5|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[12]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch5|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[13]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch6|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[0]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch6|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[1]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch6|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[2]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch6|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[3]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch6|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[4]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch6|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[5]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch6|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[6]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch6|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[7]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch6|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[8]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch6|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[9]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch6|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[10]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch6|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[11]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch6|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[12]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch6|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[13]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch7|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[0]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch7|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[1]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch7|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[2]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch7|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[3]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch7|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[4]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch7|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[5]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch7|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[6]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch7|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[7]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch7|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[8]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch7|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[9]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch7|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[10]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch7|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[11]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch7|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[12]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch7|fsfb_ctrl:i_fsfb_ctrl|dac_dat_o[13]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch0|offset_ctrl:i_offset_ctrl|offset_spi_if:i_offset_spi_if|spi_csb_o~reg0" -section_id "Serial DA data & CS reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch0|sa_bias_ctrl:i_sa_bias_ctrl|sa_bias_spi_if:i_sa_bias_spi_if|spi_csb_o~reg0" -section_id "Serial DA data & CS reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch1|offset_ctrl:i_offset_ctrl|offset_spi_if:i_offset_spi_if|spi_csb_o~reg0" -section_id "Serial DA data & CS reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch1|sa_bias_ctrl:i_sa_bias_ctrl|sa_bias_spi_if:i_sa_bias_spi_if|spi_csb_o~reg0" -section_id "Serial DA data & CS reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch2|offset_ctrl:i_offset_ctrl|offset_spi_if:i_offset_spi_if|spi_csb_o~reg0" -section_id "Serial DA data & CS reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch2|sa_bias_ctrl:i_sa_bias_ctrl|sa_bias_spi_if:i_sa_bias_spi_if|spi_csb_o~reg0" -section_id "Serial DA data & CS reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch3|offset_ctrl:i_offset_ctrl|offset_spi_if:i_offset_spi_if|spi_csb_o~reg0" -section_id "Serial DA data & CS reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch3|sa_bias_ctrl:i_sa_bias_ctrl|sa_bias_spi_if:i_sa_bias_spi_if|spi_csb_o~reg0" -section_id "Serial DA data & CS reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch4|offset_ctrl:i_offset_ctrl|offset_spi_if:i_offset_spi_if|spi_csb_o~reg0" -section_id "Serial DA data & CS reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch4|sa_bias_ctrl:i_sa_bias_ctrl|sa_bias_spi_if:i_sa_bias_spi_if|spi_csb_o~reg0" -section_id "Serial DA data & CS reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch5|offset_ctrl:i_offset_ctrl|offset_spi_if:i_offset_spi_if|spi_csb_o~reg0" -section_id "Serial DA data & CS reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch5|sa_bias_ctrl:i_sa_bias_ctrl|sa_bias_spi_if:i_sa_bias_spi_if|spi_csb_o~reg0" -section_id "Serial DA data & CS reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch6|offset_ctrl:i_offset_ctrl|offset_spi_if:i_offset_spi_if|spi_csb_o~reg0" -section_id "Serial DA data & CS reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch6|sa_bias_ctrl:i_sa_bias_ctrl|sa_bias_spi_if:i_sa_bias_spi_if|spi_csb_o~reg0" -section_id "Serial DA data & CS reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch7|offset_ctrl:i_offset_ctrl|offset_spi_if:i_offset_spi_if|spi_csb_o~reg0" -section_id "Serial DA data & CS reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch7|sa_bias_ctrl:i_sa_bias_ctrl|sa_bias_spi_if:i_sa_bias_spi_if|spi_csb_o~reg0" -section_id "Serial DA data & CS reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch0|offset_ctrl:i_offset_ctrl|offset_spi_if:i_offset_spi_if|spi_sdat_o~reg0" -section_id "Serial DA data & CS reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch0|sa_bias_ctrl:i_sa_bias_ctrl|sa_bias_spi_if:i_sa_bias_spi_if|spi_sdat_o~reg0" -section_id "Serial DA data & CS reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch1|offset_ctrl:i_offset_ctrl|offset_spi_if:i_offset_spi_if|spi_sdat_o~reg0" -section_id "Serial DA data & CS reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch1|sa_bias_ctrl:i_sa_bias_ctrl|sa_bias_spi_if:i_sa_bias_spi_if|spi_sdat_o~reg0" -section_id "Serial DA data & CS reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch2|offset_ctrl:i_offset_ctrl|offset_spi_if:i_offset_spi_if|spi_sdat_o~reg0" -section_id "Serial DA data & CS reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch2|sa_bias_ctrl:i_sa_bias_ctrl|sa_bias_spi_if:i_sa_bias_spi_if|spi_sdat_o~reg0" -section_id "Serial DA data & CS reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch3|offset_ctrl:i_offset_ctrl|offset_spi_if:i_offset_spi_if|spi_sdat_o~reg0" -section_id "Serial DA data & CS reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch3|sa_bias_ctrl:i_sa_bias_ctrl|sa_bias_spi_if:i_sa_bias_spi_if|spi_sdat_o~reg0" -section_id "Serial DA data & CS reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch4|offset_ctrl:i_offset_ctrl|offset_spi_if:i_offset_spi_if|spi_sdat_o~reg0" -section_id "Serial DA data & CS reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch4|sa_bias_ctrl:i_sa_bias_ctrl|sa_bias_spi_if:i_sa_bias_spi_if|spi_sdat_o~reg0" -section_id "Serial DA data & CS reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch5|offset_ctrl:i_offset_ctrl|offset_spi_if:i_offset_spi_if|spi_sdat_o~reg0" -section_id "Serial DA data & CS reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch5|sa_bias_ctrl:i_sa_bias_ctrl|sa_bias_spi_if:i_sa_bias_spi_if|spi_sdat_o~reg0" -section_id "Serial DA data & CS reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch6|offset_ctrl:i_offset_ctrl|offset_spi_if:i_offset_spi_if|spi_sdat_o~reg0" -section_id "Serial DA data & CS reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch6|sa_bias_ctrl:i_sa_bias_ctrl|sa_bias_spi_if:i_sa_bias_spi_if|spi_sdat_o~reg0" -section_id "Serial DA data & CS reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch7|offset_ctrl:i_offset_ctrl|offset_spi_if:i_offset_spi_if|spi_sdat_o~reg0" -section_id "Serial DA data & CS reg"
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER "flux_loop:i_flux_loop|flux_loop_ctrl:i_flux_loop_ctrl_ch7|sa_bias_ctrl:i_sa_bias_ctrl|sa_bias_spi_if:i_sa_bias_spi_if|spi_sdat_o~reg0" -section_id "Serial DA data & CS reg"
	set_global_assignment -name FITTER_EFFORT "STANDARD FIT"
	set_global_assignment -name EDA_INCLUDE_VHDL_CONFIGURATION_DECLARATION ON -section_id eda_simulation
	set_global_assignment -name OPTIMIZE_POWER_DURING_SYNTHESIS OFF
	set_global_assignment -name AUTO_PACKED_REGISTERS_STRATIXII NORMAL
	set_global_assignment -name AUTO_PACKED_REGISTERS_MAXII NORMAL
	set_global_assignment -name AUTO_PACKED_REGISTERS_CYCLONE NORMAL
	set_global_assignment -name AUTO_PACKED_REGISTERS NORMAL
	set_global_assignment -name OPTIMIZE_MULTI_CORNER_TIMING ON
	set_global_assignment -name DO_COMBINED_ANALYSIS OFF
	set_global_assignment -name SAFE_STATE_MACHINE ON
	set_global_assignment -name INCREMENTAL_COMPILATION OFF
	set_global_assignment -name NUM_PARALLEL_PROCESSORS 2
	set_global_assignment -name SEED 1
	set_global_assignment -name PHYSICAL_SYNTHESIS_MAP_LOGIC_TO_MEMORY_FOR_AREA ON
	set_global_assignment -name ENABLE_ADVANCED_IO_TIMING ON
	set_global_assignment -name SEARCH_PATH "c:\\altera\\81\\ip\\altera\\ddr2_high_perf\\lib"
	set_global_assignment -name MISC_FILE "C:/mce/cards/readout_card/readout_card/synth/readout_card_stratix_iii.dpf"
	set_global_assignment -name USE_CONFIGURATION_DEVICE ON
	set_global_assignment -name DEVICE_MIGRATION_LIST EP3SE50F780C4
	set_global_assignment -name PARTITION_NETLIST_TYPE SOURCE -section_id Top
	set_global_assignment -name PARTITION_COLOR 2147039 -section_id Top
	set_global_assignment -name LL_ROOT_REGION ON -section_id "Root Region"
	set_global_assignment -name LL_MEMBER_STATE LOCKED -section_id "Root Region"
	set_global_assignment -name MISC_FILE "C:/mce/cards/readout_card/readout_card/synth_stratix_iii/readout_card_stratix_iii.dpf"
	set_global_assignment -name PROJECT_SHOW_ENTITY_NAME ON
	set_global_assignment -name PROJECT_USE_SIMPLIFIED_NAMES OFF
	set_global_assignment -name ENABLE_REDUCED_MEMORY_MODE OFF
	set_global_assignment -name VER_COMPATIBLE_DB_DIR export_db
	set_global_assignment -name AUTO_EXPORT_VER_COMPATIBLE_DB OFF
	set_global_assignment -name SMART_RECOMPILE OFF
	set_global_assignment -name FLOW_DISABLE_ASSEMBLER OFF
	set_global_assignment -name FLOW_ENABLE_HC_COMPARE OFF
	set_global_assignment -name HC_OUTPUT_DIR hc_output
	set_global_assignment -name SAVE_MIGRATION_INFO_DURING_COMPILATION OFF
	set_global_assignment -name FLOW_ENABLE_IO_ASSIGNMENT_ANALYSIS OFF
	set_global_assignment -name RUN_FULL_COMPILE_ON_DEVICE_CHANGE ON
	set_global_assignment -name FLOW_ENABLE_RTL_VIEWER OFF
	set_global_assignment -name READ_OR_WRITE_IN_BYTE_ADDRESS "USE GLOBAL SETTINGS"
	set_global_assignment -name FLOW_HARDCOPY_DESIGN_READINESS_CHECK ON
	set_global_assignment -name DEFAULT_HOLD_MULTICYCLE "SAME AS MULTICYCLE"
	set_global_assignment -name CUT_OFF_PATHS_BETWEEN_CLOCK_DOMAINS ON
	set_global_assignment -name CUT_OFF_READ_DURING_WRITE_PATHS ON
	set_global_assignment -name CUT_OFF_CLEAR_AND_PRESET_PATHS ON
	set_global_assignment -name CUT_OFF_IO_PIN_FEEDBACK ON
	set_global_assignment -name IGNORE_CLOCK_SETTINGS OFF
	set_global_assignment -name ANALYZE_LATCHES_AS_SYNCHRONOUS_ELEMENTS ON
	set_global_assignment -name DO_MINMAX_ANALYSIS_USING_RISEFALL_DELAYS OFF
	set_global_assignment -name ENABLE_RECOVERY_REMOVAL_ANALYSIS OFF
	set_global_assignment -name NUMBER_OF_SOURCES_PER_DESTINATION_TO_REPORT 10
	set_global_assignment -name NUMBER_OF_DESTINATION_TO_REPORT 10
	set_global_assignment -name DO_MIN_ANALYSIS OFF
	set_global_assignment -name DO_MIN_TIMING OFF
	set_global_assignment -name REPORT_IO_PATHS_SEPARATELY OFF
	set_global_assignment -name CLOCK_ANALYSIS_ONLY OFF
	set_global_assignment -name FLOW_ENABLE_TIMING_CONSTRAINT_CHECK OFF
	set_global_assignment -name ENABLE_IP_DEBUG OFF
	set_global_assignment -name SAVE_DISK_SPACE ON
	set_global_assignment -name DISABLE_OCP_HW_EVAL OFF
	set_global_assignment -name VERILOG_INPUT_VERSION VERILOG_2001
	set_global_assignment -name VHDL_INPUT_VERSION VHDL93
	set_global_assignment -name COMPILATION_LEVEL FULL
	set_global_assignment -name TRUE_WYSIWYG_FLOW OFF
	set_global_assignment -name SMART_COMPILE_IGNORES_TDC_FOR_STRATIX_PLL_CHANGES OFF
	set_global_assignment -name EXTRACT_VERILOG_STATE_MACHINES ON
	set_global_assignment -name EXTRACT_VHDL_STATE_MACHINES ON
	set_global_assignment -name IGNORE_VERILOG_INITIAL_CONSTRUCTS OFF
	set_global_assignment -name VERILOG_CONSTANT_LOOP_LIMIT 5000
	set_global_assignment -name VERILOG_NON_CONSTANT_LOOP_LIMIT 250
	set_global_assignment -name ADD_PASS_THROUGH_LOGIC_TO_INFERRED_RAMS ON
	set_global_assignment -name PARALLEL_SYNTHESIS OFF
	set_global_assignment -name DSP_BLOCK_BALANCING AUTO
	set_global_assignment -name NOT_GATE_PUSH_BACK ON
	set_global_assignment -name ALLOW_POWER_UP_DONT_CARE ON
	set_global_assignment -name REMOVE_DUPLICATE_REGISTERS ON
	set_global_assignment -name IGNORE_ROW_GLOBAL_BUFFERS OFF
	set_global_assignment -name MAX7000_IGNORE_LCELL_BUFFERS AUTO
	set_global_assignment -name IGNORE_SOFT_BUFFERS ON
	set_global_assignment -name MAX7000_IGNORE_SOFT_BUFFERS OFF
	set_global_assignment -name LIMIT_AHDL_INTEGERS_TO_32_BITS OFF
	set_global_assignment -name AUTO_GLOBAL_CLOCK_MAX ON
	set_global_assignment -name AUTO_GLOBAL_OE_MAX ON
	set_global_assignment -name MAX_AUTO_GLOBAL_REGISTER_CONTROLS ON
	set_global_assignment -name AUTO_IMPLEMENT_IN_ROM OFF
	set_global_assignment -name STRATIX_TECHNOLOGY_MAPPER LUT
	set_global_assignment -name MAX7000_TECHNOLOGY_MAPPER "PRODUCT TERM"
	set_global_assignment -name APEX20K_TECHNOLOGY_MAPPER LUT
	set_global_assignment -name MERCURY_TECHNOLOGY_MAPPER LUT
	set_global_assignment -name FLEX6K_TECHNOLOGY_MAPPER LUT
	set_global_assignment -name FLEX10K_TECHNOLOGY_MAPPER LUT
	set_global_assignment -name OPTIMIZATION_TECHNIQUE BALANCED
	set_global_assignment -name CYCLONE_OPTIMIZATION_TECHNIQUE BALANCED
	set_global_assignment -name CYCLONEII_OPTIMIZATION_TECHNIQUE BALANCED
	set_global_assignment -name MAXII_OPTIMIZATION_TECHNIQUE BALANCED
	set_global_assignment -name MAX7000_OPTIMIZATION_TECHNIQUE SPEED
	set_global_assignment -name APEX20K_OPTIMIZATION_TECHNIQUE BALANCED
	set_global_assignment -name MERCURY_OPTIMIZATION_TECHNIQUE AREA
	set_global_assignment -name FLEX6K_OPTIMIZATION_TECHNIQUE AREA
	set_global_assignment -name FLEX10K_OPTIMIZATION_TECHNIQUE AREA
	set_global_assignment -name ALLOW_XOR_GATE_USAGE ON
	set_global_assignment -name AUTO_LCELL_INSERTION ON
	set_global_assignment -name CARRY_CHAIN_LENGTH 48
	set_global_assignment -name FLEX6K_CARRY_CHAIN_LENGTH 32
	set_global_assignment -name FLEX10K_CARRY_CHAIN_LENGTH 32
	set_global_assignment -name MERCURY_CARRY_CHAIN_LENGTH 48
	set_global_assignment -name STRATIX_CARRY_CHAIN_LENGTH 70
	set_global_assignment -name STRATIXII_CARRY_CHAIN_LENGTH 70
	set_global_assignment -name CASCADE_CHAIN_LENGTH 2
	set_global_assignment -name PARALLEL_EXPANDER_CHAIN_LENGTH 16
	set_global_assignment -name MAX7000_PARALLEL_EXPANDER_CHAIN_LENGTH 4
	set_global_assignment -name AUTO_CARRY_CHAINS ON
	set_global_assignment -name AUTO_CASCADE_CHAINS ON
	set_global_assignment -name AUTO_PARALLEL_EXPANDERS ON
	set_global_assignment -name AUTO_OPEN_DRAIN_PINS ON
	set_global_assignment -name REMOVE_DUPLICATE_LOGIC ON
	set_global_assignment -name ADV_NETLIST_OPT_RETIME_CORE_AND_IO ON
	set_global_assignment -name AUTO_ROM_RECOGNITION ON
	set_global_assignment -name AUTO_RAM_RECOGNITION ON
	set_global_assignment -name AUTO_DSP_RECOGNITION ON
	set_global_assignment -name AUTO_SHIFT_REGISTER_RECOGNITION AUTO
	set_global_assignment -name AUTO_CLOCK_ENABLE_RECOGNITION ON
	set_global_assignment -name STRICT_RAM_RECOGNITION OFF
	set_global_assignment -name ALLOW_SYNCH_CTRL_USAGE ON
	set_global_assignment -name FORCE_SYNCH_CLEAR OFF
	set_global_assignment -name DONT_TOUCH_USER_CELL OFF
	set_global_assignment -name AUTO_RAM_BLOCK_BALANCING ON
	set_global_assignment -name AUTO_RAM_TO_LCELL_CONVERSION OFF
	set_global_assignment -name IP_SHOW_ANALYSIS_MESSAGES OFF
	set_global_assignment -name USE_NEW_TEXT_REPORT_TABLE_FORMAT OFF
	set_global_assignment -name MAX7000_FANIN_PER_CELL 100
	set_global_assignment -name USE_LOGICLOCK_CONSTRAINTS_IN_BALANCING ON
	set_global_assignment -name IGNORE_TRANSLATE_OFF_AND_SYNTHESIS_OFF OFF
	set_global_assignment -name STRATIXGX_BYPASS_REMAPPING_OF_FORCE_SIGNAL_DETECT_SIGNAL_THRESHOLD_SELECT OFF
	set_global_assignment -name SYNTH_TIMING_DRIVEN_REGISTER_DUPLICATION OFF
	set_global_assignment -name SYNTH_TIMING_DRIVEN_BALANCED_MAPPING OFF
	set_global_assignment -name SYNTH_TIMING_DRIVEN_SYNTHESIS OFF
	set_global_assignment -name SHOW_PARAMETER_SETTINGS_TABLES_IN_SYNTHESIS_REPORT ON
	set_global_assignment -name IGNORE_MAX_FANOUT_ASSIGNMENTS OFF
	set_global_assignment -name SYNCHRONIZATION_REGISTER_CHAIN_LENGTH 2
	set_global_assignment -name HDL_MESSAGE_LEVEL LEVEL2
	set_global_assignment -name HDL_INTERFACE_OUTPUT_PATH ./
	set_global_assignment -name SUPPRESS_REG_MINIMIZATION_MSG OFF
	set_global_assignment -name USE_HIGH_SPEED_ADDER AUTO
	set_global_assignment -name NUMBER_OF_REMOVED_REGISTERS_REPORTED 100
	set_global_assignment -name NUMBER_OF_INVERTED_REGISTERS_REPORTED 100
	set_global_assignment -name ENCRYPTED_LUTMASK OFF
	set_global_assignment -name SYNTH_CLOCK_MUX_PROTECTION ON
	set_global_assignment -name SYNTH_GATED_CLOCK_CONVERSION OFF
	set_global_assignment -name BLOCK_DESIGN_NAMING AUTO
	set_global_assignment -name SYNTH_PROTECT_SDC_CONSTRAINT OFF
	set_global_assignment -name SYNTHESIS_EFFORT AUTO
	set_global_assignment -name ALLOW_ACLR_FOR_SHIFT_REGISTER_RECOGNITION ON
	set_global_assignment -name PRE_MAPPING_RESYNTHESIS OFF
	set_global_assignment -name SYNTH_MESSAGE_LEVEL MEDIUM
	set_global_assignment -name PLACEMENT_EFFORT_MULTIPLIER 1.0
	set_global_assignment -name ROUTER_EFFORT_MULTIPLIER 1.0
	set_global_assignment -name FIT_ATTEMPTS_TO_SKIP 0
	set_global_assignment -name ECO_ALLOW_ROUTING_CHANGES OFF
	set_global_assignment -name BASE_PIN_OUT_FILE_ON_SAMEFRAME_DEVICE OFF
	set_global_assignment -name ENABLE_JTAG_BST_SUPPORT OFF
	set_global_assignment -name MAX7000_ENABLE_JTAG_BST_SUPPORT ON
	set_global_assignment -name RESERVE_NCEO_AFTER_CONFIGURATION "USE AS REGULAR IO"
	set_global_assignment -name CYCLONEII_RESERVE_NCEO_AFTER_CONFIGURATION "USE AS PROGRAMMING PIN"
	set_global_assignment -name STRATIXIII_UPDATE_MODE STANDARD
	set_global_assignment -name STRATIX_UPDATE_MODE STANDARD
	set_global_assignment -name STRATIXIII_CONFIGURATION_SCHEME "PASSIVE SERIAL"
	set_global_assignment -name CYCLONEIII_CONFIGURATION_SCHEME "ACTIVE SERIAL"
	set_global_assignment -name STRATIXII_CONFIGURATION_SCHEME "PASSIVE SERIAL"
	set_global_assignment -name CYCLONEII_CONFIGURATION_SCHEME "ACTIVE SERIAL"
	set_global_assignment -name APEX20K_CONFIGURATION_SCHEME "PASSIVE SERIAL"
	set_global_assignment -name STRATIX_CONFIGURATION_SCHEME "PASSIVE SERIAL"
	set_global_assignment -name CYCLONE_CONFIGURATION_SCHEME "ACTIVE SERIAL"
	set_global_assignment -name MERCURY_CONFIGURATION_SCHEME "PASSIVE SERIAL"
	set_global_assignment -name FLEX6K_CONFIGURATION_SCHEME "PASSIVE SERIAL"
	set_global_assignment -name FLEX10K_CONFIGURATION_SCHEME "PASSIVE SERIAL"
	set_global_assignment -name APEXII_CONFIGURATION_SCHEME "PASSIVE SERIAL"
	set_global_assignment -name USER_START_UP_CLOCK OFF
	set_global_assignment -name ENABLE_VREFA_PIN OFF
	set_global_assignment -name ENABLE_VREFB_PIN OFF
	set_global_assignment -name ALWAYS_ENABLE_INPUT_BUFFERS OFF
	set_global_assignment -name ENABLE_ASMI_FOR_FLASH_LOADER OFF
	set_global_assignment -name ENABLE_DEVICE_WIDE_OE OFF
	set_global_assignment -name FLEX10K_ENABLE_LOCK_OUTPUT OFF
	set_global_assignment -name ENABLE_INIT_DONE_OUTPUT OFF
	set_global_assignment -name RESERVE_NWS_NRS_NCS_CS_AFTER_CONFIGURATION "USE AS REGULAR IO"
	set_global_assignment -name RESERVE_RDYNBUSY_AFTER_CONFIGURATION "USE AS REGULAR IO"
	set_global_assignment -name RESERVE_DATA7_THROUGH_DATA1_AFTER_CONFIGURATION "USE AS REGULAR IO"
	set_global_assignment -name RESERVE_DATA0_AFTER_CONFIGURATION "AS INPUT TRI-STATED"
	set_global_assignment -name RESERVE_ASDO_AFTER_CONFIGURATION "USE AS REGULAR IO"
	set_global_assignment -name RESERVE_DATA1_AFTER_CONFIGURATION "AS INPUT TRI-STATED"
	set_global_assignment -name RESERVE_DATA7_THROUGH_DATA2_AFTER_CONFIGURATION "USE AS REGULAR IO"
	set_global_assignment -name RESERVE_FLASH_NCE_AFTER_CONFIGURATION "AS INPUT TRI-STATED"
	set_global_assignment -name RESERVE_OTHER_AP_PINS_AFTER_CONFIGURATION "USE AS REGULAR IO"
	set_global_assignment -name RESERVE_DCLK_AFTER_CONFIGURATION "USE AS PROGRAMMING PIN"
	set_global_assignment -name BLOCK_RAM_TO_MLAB_CELL_CONVERSION ON
	set_global_assignment -name BLOCK_RAM_AND_MLAB_EQUIVALENT_POWER_UP_CONDITIONS AUTO
	set_global_assignment -name BLOCK_RAM_AND_MLAB_EQUIVALENT_PAUSED_READ_CAPABILITIES CARE
	set_global_assignment -name PROGRAMMABLE_POWER_TECHNOLOGY_SETTING AUTOMATIC
	set_global_assignment -name PROGRAMMABLE_POWER_MAXIMUM_HIGH_SPEED_FRACTION_OF_USED_LAB_TILES 1.0
	set_global_assignment -name GUARANTEE_MIN_DELAY_CORNER_IO_ZERO_HOLD_TIME ON
	set_global_assignment -name OPTIMIZE_POWER_DURING_FITTING "NORMAL COMPILATION"
	set_global_assignment -name OPTIMIZE_SIGNAL_INTEGRITY OFF
	set_global_assignment -name OPTIMIZE_TIMING "NORMAL COMPILATION"
	set_global_assignment -name ECO_OPTIMIZE_TIMING OFF
	set_global_assignment -name ECO_REGENERATE_REPORT OFF
	set_global_assignment -name OPTIMIZE_IOC_REGISTER_PLACEMENT_FOR_TIMING ON
	set_global_assignment -name DISABLE_PLL_COMPENSATION_DELAY_CHANGE_WARNING OFF
	set_global_assignment -name FIT_ONLY_ONE_ATTEMPT OFF
	set_global_assignment -name FITTER_AGGRESSIVE_ROUTABILITY_OPTIMIZATION AUTOMATICALLY
	set_global_assignment -name SLOW_SLEW_RATE OFF
	set_global_assignment -name PCI_IO OFF
	set_global_assignment -name TURBO_BIT ON
	set_global_assignment -name WEAK_PULL_UP_RESISTOR OFF
	set_global_assignment -name ENABLE_BUS_HOLD_CIRCUITRY OFF
	set_global_assignment -name MIGRATION_CONSTRAIN_CORE_RESOURCES ON
	set_global_assignment -name NORMAL_LCELL_INSERT ON
	set_global_assignment -name CARRY_OUT_PINS_LCELL_INSERT ON
	set_global_assignment -name AUTO_DELAY_CHAINS ON
	set_global_assignment -name AUTO_FAST_INPUT_REGISTERS OFF
	set_global_assignment -name AUTO_FAST_OUTPUT_REGISTERS OFF
	set_global_assignment -name AUTO_FAST_OUTPUT_ENABLE_REGISTERS OFF
	set_global_assignment -name XSTL_INPUT_ALLOW_SE_BUFFER OFF
	set_global_assignment -name TREAT_BIDIR_AS_OUTPUT OFF
	set_global_assignment -name AUTO_MERGE_PLLS ON
	set_global_assignment -name IGNORE_MODE_FOR_MERGE OFF
	set_global_assignment -name AUTO_TURBO_BIT ON
	set_global_assignment -name PHYSICAL_SYNTHESIS_COMBO_LOGIC_FOR_AREA OFF
	set_global_assignment -name PHYSICAL_SYNTHESIS_LOG_FILE OFF
	set_global_assignment -name PHYSICAL_SYNTHESIS_ASYNCHRONOUS_SIGNAL_PIPELINING OFF
	set_global_assignment -name IO_PLACEMENT_OPTIMIZATION ON
	set_global_assignment -name ALLOW_LVTTL_LVCMOS_INPUT_LEVELS_TO_OVERDRIVE_INPUT_BUFFER OFF
	set_global_assignment -name OVERRIDE_DEFAULT_ELECTROMIGRATION_PARAMETERS OFF
	set_global_assignment -name FITTER_AUTO_EFFORT_DESIRED_SLACK_MARGIN "0 ns"
	set_global_assignment -name ROUTER_LCELL_INSERTION_AND_LOGIC_DUPLICATION AUTO
	set_global_assignment -name ROUTER_REGISTER_DUPLICATION AUTO
	set_global_assignment -name ALLOW_SERIES_TERMINATION OFF
	set_global_assignment -name ALLOW_SERIES_WITH_CALIBRATION_TERMINATION OFF
	set_global_assignment -name ALLOW_PARALLEL_TERMINATION OFF
	set_global_assignment -name STRATIXGX_ALLOW_CLOCK_FANOUT_WITH_ANALOG_RESET OFF
	set_global_assignment -name AUTO_GLOBAL_CLOCK ON
	set_global_assignment -name AUTO_GLOBAL_OE ON
	set_global_assignment -name AUTO_GLOBAL_REGISTER_CONTROLS ON
	set_global_assignment -name FITTER_EARLY_TIMING_ESTIMATE_MODE REALISTIC
	set_global_assignment -name STRATIXGX_ALLOW_GIGE_UNDER_FULL_DATARATE_RANGE OFF
	set_global_assignment -name STRATIXGX_ALLOW_RX_CORECLK_FROM_NON_RX_CLKOUT_SOURCE_IN_DOUBLE_DATA_WIDTH_MODE OFF
	set_global_assignment -name STRATIXGX_ALLOW_GIGE_IN_DOUBLE_DATA_WIDTH_MODE OFF
	set_global_assignment -name STRATIXGX_ALLOW_PARALLEL_LOOPBACK_IN_DOUBLE_DATA_WIDTH_MODE OFF
	set_global_assignment -name STRATIXGX_ALLOW_XAUI_IN_SINGLE_DATA_WIDTH_MODE OFF
	set_global_assignment -name STRATIXGX_ALLOW_XAUI_WITH_CORECLK_SELECTED_AT_RATE_MATCHER OFF
	set_global_assignment -name STRATIXGX_ALLOW_XAUI_WITH_RX_CORECLK_FROM_NON_TXPLL_SOURCE OFF
	set_global_assignment -name STRATIXGX_ALLOW_GIGE_WITH_CORECLK_SELECTED_AT_RATE_MATCHER OFF
	set_global_assignment -name STRATIXGX_ALLOW_GIGE_WITHOUT_8B10B OFF
	set_global_assignment -name STRATIXGX_ALLOW_GIGE_WITH_RX_CORECLK_FROM_NON_TXPLL_SOURCE OFF
	set_global_assignment -name STRATIXGX_ALLOW_POST8B10B_LOOPBACK OFF
	set_global_assignment -name STRATIXGX_ALLOW_REVERSE_PARALLEL_LOOPBACK OFF
	set_global_assignment -name STRATIXGX_ALLOW_USE_OF_GXB_COUPLED_IOS OFF
	set_global_assignment -name IO_SSO_CHECKING ON
	set_global_assignment -name GENERATE_GXB_RECONFIG_MIF OFF
	set_global_assignment -name GENERATE_GXB_RECONFIG_MIF_WITH_PLL OFF
	set_global_assignment -name RESERVE_ALL_UNUSED_PINS_WEAK_PULLUP "AS INPUT TRI-STATED WITH WEAK PULL-UP"
	set_global_assignment -name STOP_AFTER_CONGESTION_MAP OFF
	set_global_assignment -name SAVE_INTERMEDIATE_FITTING_RESULTS OFF
	set_global_assignment -name ENABLE_HOLD_BACK_OFF ON
	set_global_assignment -name FORCE_CONFIGURATION_VCCIO OFF
	set_global_assignment -name SYNCHRONIZER_IDENTIFICATION OFF
	set_global_assignment -name ENABLE_BENEFICIAL_SKEW_OPTIMIZATION OFF
	set_global_assignment -name OPTIMIZE_FOR_METASTABILITY OFF
	set_global_assignment -name CRC_ERROR_OPEN_DRAIN OFF
	set_global_assignment -name MAX_GLOBAL_CLOCKS_ALLOWED "-1"
	set_global_assignment -name MAX_REGIONAL_CLOCKS_ALLOWED "-1"
	set_global_assignment -name MAX_PERIPHERY_CLOCKS_ALLOWED "-1"
	set_global_assignment -name MAX_CLOCKS_ALLOWED "-1"
	set_global_assignment -name RAM_BLOCK_READ_CLOCK_DUTY_CYCLE_DEPENDENCY ON
	set_global_assignment -name STRATIXIII_MRAM_COMPATIBILITY ON
	set_global_assignment -name EDA_TIMING_ANALYSIS_TOOL "<None>"
	set_global_assignment -name EDA_BOARD_DESIGN_TIMING_TOOL "<None>"
	set_global_assignment -name EDA_BOARD_DESIGN_SYMBOL_TOOL "<None>"
	set_global_assignment -name EDA_BOARD_DESIGN_SIGNAL_INTEGRITY_TOOL "<None>"
	set_global_assignment -name EDA_BOARD_DESIGN_BOUNDARY_SCAN_TOOL "<None>"
	set_global_assignment -name EDA_BOARD_DESIGN_TOOL "<None>"
	set_global_assignment -name EDA_FORMAL_VERIFICATION_TOOL "<None>"
	set_global_assignment -name EDA_RESYNTHESIS_TOOL "<None>"
	set_global_assignment -name STRATIX_FAST_PLL_INCREASE_LOCK_WINDOW OFF
	set_global_assignment -name COMPRESSION_MODE OFF
	set_global_assignment -name CLOCK_SOURCE INTERNAL
	set_global_assignment -name CONFIGURATION_CLOCK_FREQUENCY "10 MHZ"
	set_global_assignment -name CONFIGURATION_CLOCK_DIVISOR 1
	set_global_assignment -name ENABLE_LOW_VOLTAGE_MODE_ON_CONFIG_DEVICE ON
	set_global_assignment -name FLEX6K_ENABLE_LOW_VOLTAGE_MODE_ON_CONFIG_DEVICE OFF
	set_global_assignment -name FLEX10K_ENABLE_LOW_VOLTAGE_MODE_ON_CONFIG_DEVICE ON
	set_global_assignment -name MAX7000S_JTAG_USER_CODE FFFF
	set_global_assignment -name STRATIX_JTAG_USER_CODE FFFFFFFF
	set_global_assignment -name APEX20K_JTAG_USER_CODE FFFFFFFF
	set_global_assignment -name MERCURY_JTAG_USER_CODE FFFFFFFF
	set_global_assignment -name FLEX10K_JTAG_USER_CODE 7F
	set_global_assignment -name MAX7000_JTAG_USER_CODE FFFFFFFF
	set_global_assignment -name MAX7000_USE_CHECKSUM_AS_USERCODE OFF
	set_global_assignment -name USE_CHECKSUM_AS_USERCODE OFF
	set_global_assignment -name SECURITY_BIT OFF
	set_global_assignment -name STRATIXII_CONFIGURATION_DEVICE AUTO
	set_global_assignment -name APEX20K_CONFIGURATION_DEVICE AUTO
	set_global_assignment -name MERCURY_CONFIGURATION_DEVICE AUTO
	set_global_assignment -name FLEX6K_CONFIGURATION_DEVICE AUTO
	set_global_assignment -name FLEX10K_CONFIGURATION_DEVICE AUTO
	set_global_assignment -name CYCLONE_CONFIGURATION_DEVICE AUTO
	set_global_assignment -name STRATIX_CONFIGURATION_DEVICE AUTO
	set_global_assignment -name APEX20K_CONFIG_DEVICE_JTAG_USER_CODE FFFFFFFF
	set_global_assignment -name STRATIX_CONFIG_DEVICE_JTAG_USER_CODE FFFFFFFF
	set_global_assignment -name MERCURY_CONFIG_DEVICE_JTAG_USER_CODE FFFFFFFF
	set_global_assignment -name FLEX10K_CONFIG_DEVICE_JTAG_USER_CODE FFFFFFFF
	set_global_assignment -name EPROM_USE_CHECKSUM_AS_USERCODE OFF
	set_global_assignment -name AUTO_INCREMENT_CONFIG_DEVICE_JTAG_USER_CODE ON
	set_global_assignment -name DISABLE_NCS_AND_OE_PULLUPS_ON_CONFIG_DEVICE OFF
	set_global_assignment -name GENERATE_TTF_FILE OFF
	set_global_assignment -name GENERATE_RBF_FILE OFF
	set_global_assignment -name GENERATE_HEX_FILE OFF
	set_global_assignment -name HEXOUT_FILE_START_ADDRESS 0
	set_global_assignment -name HEXOUT_FILE_COUNT_DIRECTION UP
	set_global_assignment -name RELEASE_CLEARS_BEFORE_TRI_STATES OFF
	set_global_assignment -name AUTO_RESTART_CONFIGURATION ON
	set_global_assignment -name STRATIXII_EP2S60ES_ALLOW_MRAM_USAGE OFF
	set_global_assignment -name STRATIXII_ALLOW_DUAL_PORT_DUAL_CLOCK_MRAM_USAGE OFF
	set_global_assignment -name STRATIXII_MRAM_COMPATIBILITY OFF
	set_global_assignment -name CYCLONEII_M4K_COMPATIBILITY ON
	set_global_assignment -name ENABLE_OCT_DONE OFF
	set_global_assignment -name USE_CHECKERED_PATTERN_AS_UNINITIALIZED_RAM_CONTENT OFF
	set_global_assignment -name START_TIME "0 ns"
	set_global_assignment -name SIMULATION_MODE TIMING
	set_global_assignment -name AUTO_USE_SIMULATION_PDB_NETLIST OFF
	set_global_assignment -name ADD_DEFAULT_PINS_TO_SIMULATION_OUTPUT_WAVEFORMS ON
	set_global_assignment -name SETUP_HOLD_DETECTION OFF
	set_global_assignment -name SETUP_HOLD_DETECTION_INPUT_REGISTERS_BIDIR_PINS_DISABLED OFF
	set_global_assignment -name CHECK_OUTPUTS OFF
	set_global_assignment -name SIMULATION_COVERAGE ON
	set_global_assignment -name SIMULATION_COMPLETE_COVERAGE_REPORT_PANEL ON
	set_global_assignment -name SIMULATION_MISSING_1_VALUE_COVERAGE_REPORT_PANEL ON
	set_global_assignment -name SIMULATION_MISSING_0_VALUE_COVERAGE_REPORT_PANEL ON
	set_global_assignment -name GLITCH_DETECTION OFF
	set_global_assignment -name GLITCH_INTERVAL "1 ns"
	set_global_assignment -name SIM_NO_DELAYS OFF
	set_global_assignment -name SIMULATOR_GENERATE_SIGNAL_ACTIVITY_FILE OFF
	set_global_assignment -name SIMULATION_WITH_GLITCH_FILTERING_WHEN_GENERATING_SAF ON
	set_global_assignment -name SIMULATION_BUS_CHANNEL_GROUPING OFF
	set_global_assignment -name SIMULATION_VDB_RESULT_FLUSH ON
	set_global_assignment -name VECTOR_COMPARE_TRIGGER_MODE INPUT_EDGE
	set_global_assignment -name SIMULATION_NETLIST_VIEWER OFF
	set_global_assignment -name SIMULATION_INTERCONNECT_DELAY_MODEL_TYPE TRANSPORT
	set_global_assignment -name SIMULATION_CELL_DELAY_MODEL_TYPE TRANSPORT
	set_global_assignment -name SIMULATOR_GENERATE_POWERPLAY_VCD_FILE OFF
	set_global_assignment -name SIMULATOR_PVT_TIMING_MODEL_TYPE AUTO
	set_global_assignment -name SIMULATION_WITH_AUTO_GLITCH_FILTERING AUTO
	set_global_assignment -name DRC_TOP_FANOUT 50
	set_global_assignment -name DRC_FANOUT_EXCEEDING 30
	set_global_assignment -name DRC_GATED_CLOCK_FEED 30
	set_global_assignment -name ASSG_CAT ON
	set_global_assignment -name ASSG_RULE_MISSING_FMAX ON
	set_global_assignment -name HARDCOPY_FLOW_AUTOMATION MIGRATION_ONLY
	set_global_assignment -name CLK_RULE_CLKNET_CLKSPINES_THRESHOLD 25
	set_global_assignment -name TIMING_RULE_SHIFT_REG ON
	set_global_assignment -name TIMING_RULE_COIN_CLKEDGE ON
	set_global_assignment -name DRC_DETAIL_MESSAGE_LIMIT 10
	set_global_assignment -name DRC_VIOLATION_MESSAGE_LIMIT 30
	set_global_assignment -name DRC_DEADLOCK_STATE_LIMIT 2
	set_global_assignment -name MERGE_HEX_FILE OFF
	set_global_assignment -name GENERATE_SVF_FILE OFF
	set_global_assignment -name GENERATE_ISC_FILE OFF
	set_global_assignment -name GENERATE_JAM_FILE OFF
	set_global_assignment -name GENERATE_JBC_FILE OFF
	set_global_assignment -name GENERATE_JBC_FILE_COMPRESSED ON
	set_global_assignment -name GENERATE_CONFIG_SVF_FILE OFF
	set_global_assignment -name GENERATE_CONFIG_ISC_FILE OFF
	set_global_assignment -name GENERATE_CONFIG_JAM_FILE OFF
	set_global_assignment -name GENERATE_CONFIG_JBC_FILE OFF
	set_global_assignment -name GENERATE_CONFIG_JBC_FILE_COMPRESSED ON
	set_global_assignment -name GENERATE_CONFIG_HEXOUT_FILE OFF
	set_global_assignment -name SIGNALPROBE_ALLOW_OVERUSE OFF
	set_global_assignment -name SIGNALPROBE_DURING_NORMAL_COMPILATION OFF
	set_global_assignment -name HUB_ENTITY_NAME sld_hub
	set_global_assignment -name HUB_INSTANCE_NAME sld_hub_inst
	set_global_assignment -name LOGICLOCK_INCREMENTAL_COMPILE_ASSIGNMENT OFF
	set_global_assignment -name LL_OLD_BEHAVIOR OFF
	set_global_assignment -name POWER_DEFAULT_TOGGLE_RATE 12.5%
	set_global_assignment -name POWER_DEFAULT_INPUT_IO_TOGGLE_RATE 12.5%
	set_global_assignment -name POWER_USE_PVA ON
	set_global_assignment -name POWER_USE_INPUT_FILE "NO FILE"
	set_global_assignment -name POWER_USE_INPUT_FILES OFF
	set_global_assignment -name POWER_VCD_FILTER_GLITCHES ON
	set_global_assignment -name POWER_REPORT_SIGNAL_ACTIVITY OFF
	set_global_assignment -name POWER_REPORT_POWER_DISSIPATION OFF
	set_global_assignment -name POWER_USE_DEVICE_CHARACTERISTICS TYPICAL
	set_global_assignment -name POWER_AUTO_COMPUTE_TJ ON
	set_global_assignment -name POWER_TJ_VALUE 25
	set_global_assignment -name POWER_USE_TA_VALUE 25
	set_global_assignment -name POWER_USE_CUSTOM_COOLING_SOLUTION OFF
	set_global_assignment -name POWER_BOARD_TEMPERATURE 25
	set_global_assignment -name AUTO_EXPORT_INCREMENTAL_COMPILATION OFF
	set_global_assignment -name INCREMENTAL_COMPILATION_EXPORT_NETLIST_TYPE POST_FIT
	set_global_assignment -name OUTPUT_IO_TIMING_ENDPOINT "NEAR END"
	set_global_assignment -name RTLV_REMOVE_FANOUT_FREE_REGISTERS ON
	set_global_assignment -name RTLV_SIMPLIFIED_LOGIC ON
	set_global_assignment -name RTLV_GROUP_RELATED_NODES ON
	set_global_assignment -name RTLV_GROUP_COMB_LOGIC_IN_CLOUD OFF
	set_global_assignment -name RTLV_GROUP_COMB_LOGIC_IN_CLOUD_TMV OFF
	set_global_assignment -name RTLV_GROUP_RELATED_NODES_TMV ON
	set_global_assignment -name EQC_CONSTANT_DFF_DETECTION ON
	set_global_assignment -name EQC_DUPLICATE_DFF_DETECTION ON
	set_global_assignment -name EQC_BBOX_MERGE ON
	set_global_assignment -name EQC_LVDS_MERGE ON
	set_global_assignment -name EQC_RAM_UNMERGING ON
	set_global_assignment -name EQC_DFF_SS_EMULATION ON
	set_global_assignment -name EQC_RAM_REGISTER_UNPACK ON
	set_global_assignment -name EQC_MAC_REGISTER_UNPACK ON
	set_global_assignment -name EQC_SET_PARTITION_BB_TO_VCC_GND ON
	set_global_assignment -name EQC_STRUCTURE_MATCHING ON
	set_global_assignment -name EQC_AUTO_BREAK_CONE ON
	set_global_assignment -name EQC_POWER_UP_COMPARE OFF
	set_global_assignment -name EQC_AUTO_COMP_LOOP_CUT ON
	set_global_assignment -name EQC_AUTO_INVERSION ON
	set_global_assignment -name EQC_AUTO_TERMINATE ON
	set_global_assignment -name EQC_SUB_CONE_REPORT OFF
	set_global_assignment -name EQC_RENAMING_RULES ON
	set_global_assignment -name EQC_PARAMETER_CHECK ON
	set_global_assignment -name EQC_AUTO_PORTSWAP ON
	set_global_assignment -name EQC_DETECT_DONT_CARES ON
	set_global_assignment -name EQC_SHOW_ALL_MAPPED_POINTS OFF
	set_global_assignment -name PARTITION_IMPORT_ASSIGNMENTS ON -section_id Top
	set_global_assignment -name PARTITION_IMPORT_EXISTING_ASSIGNMENTS REPLACE_CONFLICTING -section_id Top
	set_global_assignment -name PARTITION_IMPORT_EXISTING_LOGICLOCK_REGIONS REPLACE_CONFLICTING -section_id Top
	set_global_assignment -name PARTITION_IMPORT_PIN_ASSIGNMENTS ON -section_id Top
	set_global_assignment -name PARTITION_IMPORT_PROMOTE_ASSIGNMENTS ON -section_id Top
	set_global_assignment -name PARTITION_TYPE STANDARD_PARTITION -section_id Top
	set_global_assignment -name TIMEQUEST_MULTICORNER_ANALYSIS ON
	set_global_assignment -name TIMEQUEST_DO_CCPP_REMOVAL ON
	set_global_assignment -name VHDL_FILE ../../pll/source/rtl/adc_pll_stratix_iii.vhd
	set_global_assignment -name VHDL_FILE ../../ddr2_sdram_ctrl/source/rtl/micron_ctrl_phy.vhd
	set_global_assignment -name VHDL_FILE ../../ddr2_sdram_ctrl/source/rtl/micron_ctrl_ex_lfsr8.vhd
	set_global_assignment -name VHDL_FILE ../../ddr2_sdram_ctrl/source/rtl/micron_ctrl_example_driver.vhd
	set_global_assignment -name VHDL_FILE ../../ddr2_sdram_ctrl/source/rtl/micron_ctrl_phy_alt_mem_phy_pll.vhd
	set_global_assignment -name VHDL_FILE ../../ddr2_sdram_ctrl/source/rtl/alt_mem_phy_sequencer.vhd
	set_global_assignment -name VERILOG_FILE ../../ddr2_sdram_ctrl/source/rtl/micron_ctrl_phy_alt_mem_phy.v
	set_global_assignment -name VHDL_FILE ../../ddr2_sdram_ctrl/source/rtl/micron_ctrl.vhd
	set_global_assignment -name VHDL_FILE ../../ddr2_sdram_ctrl/source/rtl/micron_ctrl_controller_phy.vhd
	set_global_assignment -name SDC_FILE ../../ddr2_sdram_ctrl/source/rtl/micron_ctrl_example_top.sdc
	set_global_assignment -name SDC_FILE ../../ddr2_sdram_ctrl/source/rtl/micron_ctrl_phy_ddr_timing.sdc
	set_global_assignment -name SDC_FILE readout_card_stratix_iii.sdc
	set_global_assignment -name VHDL_FILE ../../../all_cards/leds/source/rtl/leds_pack.vhd
	set_global_assignment -name VHDL_FILE ../../../library/sys_param/source/rtl/data_types_pack.vhd
	set_global_assignment -name VHDL_FILE ../../../library/sys_param/source/rtl/general_pack.vhd
	set_global_assignment -name VHDL_FILE ../../../library/sys_param/source/rtl/command_pack.vhd
	set_global_assignment -name VHDL_FILE ../../../library/sys_param/source/rtl/wishbone_pack.vhd
	set_global_assignment -name VHDL_FILE ../../../all_cards/all_cards/source/rtl/all_cards_pack.vhd
	set_global_assignment -name VHDL_FILE ../source/rtl/readout_card_pack.vhd
	set_global_assignment -name VHDL_FILE ../../../all_cards/frame_timing/source/rtl/frame_timing_pack.vhd
	set_global_assignment -name VHDL_FILE ../../../all_cards/frame_timing/source/rtl/frame_timing_wbs_pack.vhd
	set_global_assignment -name VHDL_FILE ../../../all_cards/frame_timing/source/rtl/frame_timing_core_pack.vhd
	set_global_assignment -name VHDL_FILE ../../../library/components/source/rtl/component_pack.vhd
	set_global_assignment -name VHDL_FILE ../../wbs_frame_data/source/rtl/rectangle_ram_bank.vhd
	set_global_assignment -name VHDL_FILE ../../flux_loop/source/rtl/raw_ram_bank.vhd
	set_global_assignment -name VHDL_FILE ../../adc_sample_coadd/source/rtl/flipflop_56.vhd
	set_global_assignment -name VHDL_FILE ../../adc_sample_coadd/source/rtl/adc_serdes.vhd
	set_global_assignment -name VHDL_FILE ../../../all_cards/all_cards/source/rtl/all_cards.vhd
	set_global_assignment -name VHDL_FILE ../../adc_sample_coadd/source/rtl/flipflop_112.vhd
	set_global_assignment -name VHDL_FILE ../../../library/components/source/rtl/binary_counter.vhd
	set_global_assignment -name VHDL_FILE ../../../library/components/source/rtl/one_wire_master.vhd
	set_global_assignment -name VHDL_FILE ../../flux_loop/source/rtl/flux_loop_pack.vhd
	set_global_assignment -name VHDL_FILE ../../flux_loop_ctrl/source/rtl/flux_loop_ctrl_pack.vhd
	set_global_assignment -name VHDL_FILE ../../adc_sample_coadd/source/rtl/adc_sample_coadd_pack.vhd
	set_global_assignment -name VHDL_FILE ../../../library/components/source/rtl/smb_master.vhd
	set_global_assignment -name VHDL_FILE ../../fsfb_ctrl/source/rtl/fsfb_ctrl_pack.vhd
	set_global_assignment -name VHDL_FILE ../../fsfb_calc/source/rtl/fsfb_calc_pack.vhd
	set_global_assignment -name VHDL_FILE ../../sa_bias_ctrl/source/rtl/sa_bias_ctrl_pack.vhd
	set_global_assignment -name VHDL_FILE ../../../all_cards/fpga_thermo/source/rtl/fpga_thermo.vhd
	set_global_assignment -name VHDL_FILE ../../../library/components/source/rtl/parallel_crc.vhd
	set_global_assignment -name VHDL_FILE ../../offset_ctrl/source/rtl/offset_ctrl_pack.vhd
	set_global_assignment -name VHDL_FILE ../../wbs_fb_data/source/rtl/wbs_fb_data_pack.vhd
	set_global_assignment -name VHDL_FILE ../../wbs_frame_data/source/rtl/wbs_frame_data_pack.vhd
	set_global_assignment -name VHDL_FILE ../source/rtl/readout_card_stratix_iii.vhd
	set_global_assignment -name VHDL_FILE ../../wbs_fb_data/source/rtl/ram_8x64.vhd
	set_global_assignment -name VHDL_FILE ../../../all_cards/async/source/rtl/async_pack.vhd
	set_global_assignment -name VHDL_FILE ../../../all_cards/id_thermo/source/rtl/id_thermo.vhd
	set_global_assignment -name VHDL_FILE ../../../library/components/source/rtl/serial_crc.vhd
	set_global_assignment -name VHDL_FILE ../../../library/components/source/rtl/fifo.vhd
	set_global_assignment -name VHDL_FILE ../../../library/components/source/rtl/us_timer.vhd
	set_global_assignment -name VHDL_FILE ../../../library/components/source/rtl/shift_reg.vhd
	set_global_assignment -name VHDL_FILE ../../../library/components/source/rtl/reg.vhd
	set_global_assignment -name VHDL_FILE ../../../all_cards/leds/source/rtl/leds.vhd
	set_global_assignment -name VHDL_FILE ../../../library/components/source/rtl/counter.vhd
	set_global_assignment -name VHDL_FILE ../../../all_cards/async/source/rtl/lvds_rx.vhd
	set_global_assignment -name VHDL_FILE ../../../all_cards/async/source/rtl/lvds_tx.vhd
	set_global_assignment -name VHDL_FILE ../../../all_cards/frame_timing/source/rtl/frame_timing_wbs.vhd
	set_global_assignment -name VHDL_FILE ../../../all_cards/frame_timing/source/rtl/frame_timing.vhd
	set_global_assignment -name VHDL_FILE ../../../all_cards/frame_timing/source/rtl/frame_timing_core.vhd
	set_global_assignment -name VHDL_FILE ../../../all_cards/dispatch/source/rtl/dispatch_wishbone.vhd
	set_global_assignment -name VHDL_FILE ../../../all_cards/dispatch/source/rtl/dispatch_cmd_receive.vhd
	set_global_assignment -name VHDL_FILE ../../../all_cards/dispatch/source/rtl/dispatch_reply_transmit.vhd
	set_global_assignment -name VHDL_FILE ../../../all_cards/dispatch/source/rtl/dispatch.vhd
	set_global_assignment -name VHDL_FILE ../../adc_sample_coadd/source/rtl/coadd_storage.vhd
	set_global_assignment -name VHDL_FILE ../../adc_sample_coadd/source/rtl/coadd_dynamic_manager_ctrl.vhd
	set_global_assignment -name VHDL_FILE ../../adc_sample_coadd/source/rtl/coadd_manager_data_path.vhd
	set_global_assignment -name VHDL_FILE ../../adc_sample_coadd/source/rtl/dynamic_manager_data_path.vhd
	set_global_assignment -name VHDL_FILE ../../adc_sample_coadd/source/rtl/raw_dat_bank.vhd
	set_global_assignment -name VHDL_FILE ../../adc_sample_coadd/source/rtl/raw_dat_manager_ctrl.vhd
	set_global_assignment -name VHDL_FILE ../../adc_sample_coadd/source/rtl/raw_dat_manager_data_path.vhd
	set_global_assignment -name VHDL_FILE ../../adc_sample_coadd/source/rtl/adc_sample_coadd.vhd
	set_global_assignment -name VHDL_FILE ../../sa_bias_ctrl/source/rtl/sa_bias_clk_domain_crosser.vhd
	set_global_assignment -name VHDL_FILE ../../sa_bias_ctrl/source/rtl/sa_bias_ctrl.vhd
	set_global_assignment -name VHDL_FILE ../../sa_bias_ctrl/source/rtl/sa_bias_spi_if.vhd
	set_global_assignment -name VHDL_FILE ../../offset_ctrl/source/rtl/offset_clk_domain_crosser.vhd
	set_global_assignment -name VHDL_FILE ../../offset_ctrl/source/rtl/offset_ctrl.vhd
	set_global_assignment -name VHDL_FILE ../../offset_ctrl/source/rtl/offset_spi_if.vhd
	set_global_assignment -name VHDL_FILE ../../fsfb_calc/source/rtl/ram_40x64.vhd
	set_global_assignment -name VHDL_FILE ../../fsfb_calc/source/rtl/fsfb_calc_sub29.vhd
	set_global_assignment -name VHDL_FILE ../../fsfb_calc/source/rtl/fsfb_calc_add_sub32.vhd
	set_global_assignment -name VHDL_FILE ../../fsfb_calc/source/rtl/fsfb_calc_adder29.vhd
	set_global_assignment -name VHDL_FILE ../../fsfb_calc/source/rtl/fsfb_calc_sub45.vhd
	set_global_assignment -name VHDL_FILE ../../fsfb_ctrl/source/rtl/fsfb_ctrl.vhd
	set_global_assignment -name VHDL_FILE ../../fsfb_calc/source/rtl/fsfb_wn_queue.vhd
	set_global_assignment -name VHDL_FILE ../../fsfb_calc/source/rtl/fsfb_calc_add_sub16.vhd
	set_global_assignment -name VHDL_FILE ../../fsfb_calc/source/rtl/fsfb_calc_adder30.vhd
	set_global_assignment -name VHDL_FILE ../../fsfb_calc/source/rtl/fsfb_calc_adder31.vhd
	set_global_assignment -name VHDL_FILE ../../fsfb_calc/source/rtl/fsfb_calc_adder32.vhd
	set_global_assignment -name VHDL_FILE ../../fsfb_calc/source/rtl/fsfb_calc_adder65.vhd
	set_global_assignment -name VHDL_FILE ../../fsfb_calc/source/rtl/fsfb_calc_adder66.vhd
	set_global_assignment -name VHDL_FILE ../../fsfb_calc/source/rtl/fsfb_filter_storage.vhd
	set_global_assignment -name VHDL_FILE ../../fsfb_calc/source/rtl/fsfb_fltr_regs.vhd
	set_global_assignment -name VHDL_FILE ../../fsfb_calc/source/rtl/fsfb_queue.vhd
	set_global_assignment -name VHDL_FILE ../../fsfb_corr/source/rtl/fsfb_corr_pack.vhd
	set_global_assignment -name VHDL_FILE ../../fsfb_corr/source/rtl/fsfb_corr.vhd
	set_global_assignment -name VHDL_FILE ../../fsfb_corr/source/rtl/fsfb_corr_multiplier.vhd
	set_global_assignment -name VHDL_FILE ../../fsfb_corr/source/rtl/fsfb_corr_subtractor.vhd
	set_global_assignment -name VHDL_FILE ../../fsfb_calc/source/rtl/fsfb_io_controller.vhd
	set_global_assignment -name VHDL_FILE ../../fsfb_calc/source/rtl/fsfb_proc_pidz.vhd
	set_global_assignment -name VHDL_FILE ../../fsfb_calc/source/rtl/fsfb_proc_ramp.vhd
	set_global_assignment -name VHDL_FILE ../../fsfb_calc/source/rtl/fsfb_processor.vhd
	set_global_assignment -name VHDL_FILE ../../fsfb_calc/source/rtl/fsfb_calc_multiplier.vhd
	set_global_assignment -name VHDL_FILE ../../fsfb_calc/source/rtl/fsfb_calc.vhd
	set_global_assignment -name VHDL_FILE ../../flux_loop_ctrl/source/rtl/flux_loop_ctrl.vhd
	set_global_assignment -name VHDL_FILE ../../wbs_frame_data/source/rtl/wbs_frame_data.vhd
	set_global_assignment -name VHDL_FILE ../../wbs_fb_data/source/rtl/wbs_fb_storage.vhd
	set_global_assignment -name VHDL_FILE ../../wbs_fb_data/source/rtl/adc_offset_banks_admin.vhd
	set_global_assignment -name VHDL_FILE ../../wbs_fb_data/source/rtl/pid_ram.vhd
	set_global_assignment -name VHDL_FILE ../../wbs_fb_data/source/rtl/ram_14x64.vhd
	set_global_assignment -name VHDL_FILE ../../wbs_fb_data/source/rtl/flux_quanta_ram_admin.vhd
	set_global_assignment -name VHDL_FILE ../../wbs_fb_data/source/rtl/pid_ram_admin.vhd
	set_global_assignment -name VHDL_FILE ../../wbs_fb_data/source/rtl/misc_banks_admin.vhd
	set_global_assignment -name VHDL_FILE ../../wbs_fb_data/source/rtl/wbs_fb_data.vhd
	set_global_assignment -name VHDL_FILE ../../flux_loop/source/rtl/flux_loop.vhd
	set_global_assignment -name MIF_FILE ../../fsfb_calc/source/rtl/ram_40x64.mif
	set_global_assignment -name CDF_FILE ../../../../../jrunner/nios.cdf
	set_global_assignment -name HEX_FILE ../../fsfb_calc/source/rtl/ram_40x64.hex
	set_global_assignment -name SIGNALTAP_FILE ../../fsfb_calc/source/rtl/raw.stp
	set_global_assignment -name SIGNALTAP_FILE raw.stp
	set_global_assignment -name QIP_FILE ../../ddr2_sdram_ctrl/source/rtl/micron_ctrl.qip
	set_global_assignment -name QIP_FILE ../../pll/source/rtl/rc_pll_stratix_iii.qip
	set_global_assignment -name QIP_FILE ../../wbs_fb_data/source/rtl/pid_ram.qip
	set_global_assignment -name QIP_FILE ../../wbs_fb_data/source/rtl/ram_14x64.qip
	set_global_assignment -name QIP_FILE ../../wbs_fb_data/source/rtl/wbs_fb_storage.qip
	set_global_assignment -name QIP_FILE ../../pll/source/rtl/adc_pll_stratix_iii.qip
	set_location_assignment PIN_J4 -to dac_clk[0]
	set_location_assignment PIN_G5 -to dac_clk[1]
	set_location_assignment PIN_M4 -to dac_clk[2]
	set_location_assignment PIN_T5 -to dac_clk[3]
	set_location_assignment PIN_U3 -to dac_clk[4]
	set_location_assignment PIN_T3 -to dac_clk[5]
	set_location_assignment PIN_U8 -to dac_clk[6]
	set_location_assignment PIN_U7 -to dac_clk[7]
	set_location_assignment PIN_E5 -to dac_dat[0]
	set_location_assignment PIN_L5 -to dac_dat[1]
	set_location_assignment PIN_N4 -to dac_dat[2]
	set_location_assignment PIN_M3 -to dac_dat[3]
	set_location_assignment PIN_U4 -to dac_dat[4]
	set_location_assignment PIN_V3 -to dac_dat[5]
	set_location_assignment PIN_U5 -to dac_dat[6]
	set_location_assignment PIN_U6 -to dac_dat[7]
	set_location_assignment PIN_M6 -to bias_dac_ncs[0]
	set_location_assignment PIN_D5 -to bias_dac_ncs[1]
	set_location_assignment PIN_T6 -to bias_dac_ncs[2]
	set_location_assignment PIN_L3 -to bias_dac_ncs[3]
	set_location_assignment PIN_AE6 -to bias_dac_ncs[4]
	set_location_assignment PIN_T4 -to bias_dac_ncs[5]
	set_location_assignment PIN_AH4 -to bias_dac_ncs[6]
	set_location_assignment PIN_AH5 -to bias_dac_ncs[7]
	set_location_assignment PIN_C3 -to offset_dac_ncs[0]
	set_location_assignment PIN_N5 -to offset_dac_ncs[1]
	set_location_assignment PIN_L4 -to offset_dac_ncs[2]
	set_location_assignment PIN_P3 -to offset_dac_ncs[3]
	set_location_assignment PIN_R4 -to offset_dac_ncs[4]
	set_location_assignment PIN_V4 -to offset_dac_ncs[5]
	set_location_assignment PIN_AH3 -to offset_dac_ncs[6]
	set_location_assignment PIN_AH2 -to offset_dac_ncs[7]
	set_location_assignment PIN_AE11 -to lvds_spare
	set_location_assignment PIN_B11 -to lvds_txa
	set_location_assignment PIN_A10 -to lvds_txb
	set_location_assignment PIN_AA13 -to ttl_dir1
	set_location_assignment PIN_AB13 -to ttl_out1
	set_location_assignment PIN_AD13 -to ttl_dir2
	set_location_assignment PIN_A13 -to ttl_in2
	set_location_assignment PIN_C10 -to ttl_out2
	set_location_assignment PIN_Y13 -to ttl_dir3
	set_location_assignment PIN_A11 -to ttl_in3
	set_location_assignment PIN_Y14 -to ttl_out3
	set_location_assignment PIN_AH7 -to pnf
	set_location_assignment PIN_AG13 -to pnf_per_byte[0]
	set_location_assignment PIN_AG4 -to pnf_per_byte[1]
	set_location_assignment PIN_AE8 -to pnf_per_byte[2]
	set_location_assignment PIN_AF9 -to pnf_per_byte[3]
	set_location_assignment PIN_AG3 -to pnf_per_byte[4]
	set_location_assignment PIN_AF5 -to pnf_per_byte[5]
	set_location_assignment PIN_AH8 -to pnf_per_byte[6]
	set_location_assignment PIN_AE4 -to pnf_per_byte[7]
	set_location_assignment PIN_AG6 -to test_complete
	set_location_assignment PIN_AF14 -to test_status[0]
	set_location_assignment PIN_J15 -to test_status[1]
	set_location_assignment PIN_AG7 -to test_status[2]
	set_location_assignment PIN_AG9 -to test_status[3]
	set_location_assignment PIN_C20 -to test_status[4]
	set_location_assignment PIN_A12 -to test_status[5]
	set_location_assignment PIN_R6 -to test_status[6]
	set_location_assignment PIN_AE10 -to test_status[7]
	set_location_assignment PIN_L26 -to card_id
	set_location_assignment PIN_U2 -to inclk
	set_location_assignment PIN_A14 -to ttl_in1
	set_location_assignment PIN_AD12 -to lvds_sync
	set_location_assignment PIN_AE12 -to lvds_cmd
	set_location_assignment PIN_U28 -to inclk_ddr
	set_instance_assignment -name PARTITION_HIERARCHY no_file_for_top_partition -to | -section_id Top
	set_location_assignment PIN_W4 -to adc0_lvds_p
	set_location_assignment PIN_W2 -to adc1_lvds_p
	set_location_assignment PIN_Y2 -to adc2_lvds_p
	set_location_assignment PIN_AB2 -to adc3_lvds_p
	set_location_assignment PIN_AC2 -to adc4_lvds_p
	set_location_assignment PIN_AD1 -to adc5_lvds_p
	set_location_assignment PIN_AE2 -to adc6_lvds_p
	set_location_assignment PIN_AF2 -to adc7_lvds_p
	set_location_assignment PIN_AE15 -to adc_fco_p
	set_location_assignment PIN_Y15 -to adc_clk_p
	set_location_assignment PIN_AF28 -to adc_sclk
	set_location_assignment PIN_AC25 -to adc_sdio
	set_location_assignment PIN_AC26 -to adc_csb_n
	set_location_assignment PIN_R1 -to adc_dco_p
	set_location_assignment PIN_V26 -to dip2
	set_location_assignment PIN_AH9 -to dip3
	set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to ddr_odt[0]
	set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.8-V SSTL CLASS I" -to ddr_clk[0]
	set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITHOUT CALIBRATION" -to ddr_clk[0]
	set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to ddr_cs_n[0]
	set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to ddr_cke[0]
	set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr_a[0]
	set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to ddr_a[0]
	set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr_a[1]
	set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to ddr_a[1]
	set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr_a[2]
	set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to ddr_a[2]
	set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr_a[3]
	set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to ddr_a[3]
	set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr_a[4]
	set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to ddr_a[4]
	set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr_a[5]
	set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to ddr_a[5]
	set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr_a[6]
	set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to ddr_a[6]
	set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr_a[7]
	set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to ddr_a[7]
	set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr_a[8]
	set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to ddr_a[8]
	set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr_a[9]
	set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to ddr_a[9]
	set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr_a[10]
	set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to ddr_a[10]
	set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr_a[11]
	set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to ddr_a[11]
	set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr_a[12]
	set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to ddr_a[12]
	set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr_ba[0]
	set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to ddr_ba[0]
	set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr_ba[1]
	set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to ddr_ba[1]
	set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr_ras_n
	set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to ddr_ras_n
	set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr_cas_n
	set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to ddr_cas_n
	set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr_we_n
	set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to ddr_we_n
	set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr_dq[0]
	set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to ddr_dq[0]
	set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr_dq[1]
	set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to ddr_dq[1]
	set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr_dq[2]
	set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to ddr_dq[2]
	set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr_dq[3]
	set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to ddr_dq[3]
	set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr_dq[4]
	set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to ddr_dq[4]
	set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr_dq[5]
	set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to ddr_dq[5]
	set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr_dq[6]
	set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to ddr_dq[6]
	set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr_dq[7]
	set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to ddr_dq[7]
	set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr_dq[8]
	set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to ddr_dq[8]
	set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr_dq[9]
	set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to ddr_dq[9]
	set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr_dq[10]
	set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to ddr_dq[10]
	set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr_dq[11]
	set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to ddr_dq[11]
	set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr_dq[12]
	set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to ddr_dq[12]
	set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr_dq[13]
	set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to ddr_dq[13]
	set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr_dq[14]
	set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to ddr_dq[14]
	set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr_dq[15]
	set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to ddr_dq[15]
	set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to ddr_dqs[0]
	set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to ddr_dqs[1]
	set_instance_assignment -name OUTPUT_ENABLE_GROUP 517035168 -to ddr_dq[0]
	set_instance_assignment -name OUTPUT_ENABLE_GROUP 517035168 -to ddr_dq[1]
	set_instance_assignment -name OUTPUT_ENABLE_GROUP 517035168 -to ddr_dq[2]
	set_instance_assignment -name OUTPUT_ENABLE_GROUP 517035168 -to ddr_dq[3]
	set_instance_assignment -name OUTPUT_ENABLE_GROUP 517035168 -to ddr_dq[4]
	set_instance_assignment -name OUTPUT_ENABLE_GROUP 517035168 -to ddr_dq[5]
	set_instance_assignment -name OUTPUT_ENABLE_GROUP 517035168 -to ddr_dq[6]
	set_instance_assignment -name OUTPUT_ENABLE_GROUP 517035168 -to ddr_dq[7]
	set_instance_assignment -name OUTPUT_ENABLE_GROUP 517035168 -to ddr_dq[8]
	set_instance_assignment -name OUTPUT_ENABLE_GROUP 517035168 -to ddr_dq[9]
	set_instance_assignment -name OUTPUT_ENABLE_GROUP 517035168 -to ddr_dq[10]
	set_instance_assignment -name OUTPUT_ENABLE_GROUP 517035168 -to ddr_dq[11]
	set_instance_assignment -name OUTPUT_ENABLE_GROUP 517035168 -to ddr_dq[12]
	set_instance_assignment -name OUTPUT_ENABLE_GROUP 517035168 -to ddr_dq[13]
	set_instance_assignment -name OUTPUT_ENABLE_GROUP 517035168 -to ddr_dq[14]
	set_instance_assignment -name OUTPUT_ENABLE_GROUP 517035168 -to ddr_dq[15]
	set_instance_assignment -name OUTPUT_ENABLE_GROUP 517035168 -to ddr_dqs[0]
	set_instance_assignment -name OUTPUT_ENABLE_GROUP 517035168 -to ddr_dqs[1]
	set_location_assignment PIN_Y19 -to ddr_a[0]
	set_location_assignment PIN_AE20 -to ddr_a[1]
	set_location_assignment PIN_AF21 -to ddr_a[2]
	set_location_assignment PIN_Y18 -to ddr_a[3]
	set_location_assignment PIN_AE21 -to ddr_a[4]
	set_location_assignment PIN_AG21 -to ddr_a[5]
	set_location_assignment PIN_Y17 -to ddr_a[6]
	set_location_assignment PIN_AC20 -to ddr_a[7]
	set_location_assignment PIN_AE19 -to ddr_a[8]
	set_location_assignment PIN_AA19 -to ddr_a[9]
	set_location_assignment PIN_AA23 -to ddr_a[10]
	set_location_assignment PIN_W21 -to ddr_a[11]
	set_location_assignment PIN_AD28 -to ddr_a[12]
	set_location_assignment PIN_AB24 -to ddr_ba[0]
	set_location_assignment PIN_AD27 -to ddr_ba[1]
	set_location_assignment PIN_AC19 -to ddr_cas_n
	set_location_assignment PIN_AA18 -to ddr_cke[0]
	set_location_assignment PIN_AF20 -to ddr_cs_n[0]
	set_location_assignment PIN_AD18 -to ddr_ras_n
	set_location_assignment PIN_AB19 -to ddr_we_n
	set_location_assignment PIN_AE27 -to ddr_clk[0]
	set_location_assignment PIN_AH27 -to ddr_dq[0]
	set_location_assignment PIN_AH25 -to ddr_dq[1]
	set_location_assignment PIN_AG25 -to ddr_dq[2]
	set_location_assignment PIN_AG27 -to ddr_dq[3]
	set_location_assignment PIN_AH26 -to ddr_dq[4]
	set_location_assignment PIN_AB20 -to ddr_dq[5]
	set_location_assignment PIN_AB21 -to ddr_dq[6]
	set_location_assignment PIN_AD21 -to ddr_dq[7]
	set_location_assignment PIN_AE23 -to ddr_dq[8]
	set_location_assignment PIN_AF24 -to ddr_dq[9]
	set_location_assignment PIN_AE24 -to ddr_dq[10]
	set_location_assignment PIN_AF23 -to ddr_dq[11]
	set_location_assignment PIN_AG24 -to ddr_dq[12]
	set_location_assignment PIN_AH20 -to ddr_dq[13]
	set_location_assignment PIN_AH21 -to ddr_dq[14]
	set_location_assignment PIN_AH22 -to ddr_dq[15]
	set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to ddr_dq[0]
	set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to ddr_dq[1]
	set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to ddr_dq[2]
	set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to ddr_dq[3]
	set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to ddr_dq[4]
	set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to ddr_dq[5]
	set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to ddr_dq[6]
	set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to ddr_dq[7]
	set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to ddr_dq[8]
	set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to ddr_dq[9]
	set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to ddr_dq[10]
	set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to ddr_dq[11]
	set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to ddr_dq[12]
	set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to ddr_dq[13]
	set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to ddr_dq[14]
	set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to ddr_dq[15]
	set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to ddr_dqs[0]
	set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to ddr_dqs[1]
	set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to adc_sclk
	set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to adc_sdio
	set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to adc_csb_n
	set_instance_assignment -name IO_STANDARD LVDS -to adc0_lvds_p
	set_instance_assignment -name IO_STANDARD LVDS -to adc1_lvds_p
	set_instance_assignment -name IO_STANDARD LVDS -to adc2_lvds_p
	set_instance_assignment -name IO_STANDARD LVDS -to adc3_lvds_p
	set_instance_assignment -name IO_STANDARD LVDS -to adc4_lvds_p
	set_instance_assignment -name IO_STANDARD LVDS -to adc5_lvds_p
	set_instance_assignment -name IO_STANDARD LVDS -to adc6_lvds_p
	set_instance_assignment -name IO_STANDARD LVDS -to adc7_lvds_p
	set_instance_assignment -name IO_STANDARD LVDS -to adc_clk_p
	set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr_cs_n
	set_location_assignment PIN_AB27 -to adc_pdwn
	set_location_assignment PIN_AD22 -to ddr_dqs[0]
	set_location_assignment PIN_AH23 -to ddr_dqs[1]
	set_location_assignment PIN_AF26 -to ddr_ldm[0]
	set_location_assignment PIN_AD19 -to ddr_odt[0]
	set_location_assignment PIN_AD24 -to ddr_udm[0]
	set_location_assignment PIN_AH13 -to led_grn
	set_location_assignment PIN_AG10 -to led_red
	set_location_assignment PIN_AH11 -to led_ylw
	set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr_cke[0]
	set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to ddr_ldm[0]
	set_instance_assignment -name OUTPUT_ENABLE_GROUP 517035168 -to ddr_ldm[0]
	set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr_ldm[0]
	set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr_odt[0]
	set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr_udm[0]
	set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to ddr_udm[0]
	set_instance_assignment -name OUTPUT_ENABLE_GROUP 517035168 -to ddr_udm[0]
	set_location_assignment PIN_R27 -to dev_clr_n
	set_location_assignment PIN_M26 -to nalert
	set_location_assignment PIN_AC12 -to sid[0]
	set_location_assignment PIN_AF12 -to sid[1]
	set_location_assignment PIN_AG12 -to sid[2]
	set_location_assignment PIN_AH10 -to sid[3]
	set_location_assignment PIN_L28 -to smbclk
	set_location_assignment PIN_M28 -to smbdata
	set_location_assignment PIN_AF10 -to wdi
	set_location_assignment PIN_J18 -to dac0_dfb_dat[0]
	set_location_assignment PIN_J20 -to dac0_dfb_dat[1]
	set_location_assignment PIN_J19 -to dac0_dfb_dat[2]
	set_location_assignment PIN_G20 -to dac0_dfb_dat[3]
	set_location_assignment PIN_G21 -to dac0_dfb_dat[4]
	set_location_assignment PIN_F21 -to dac0_dfb_dat[5]
	set_location_assignment PIN_E22 -to dac0_dfb_dat[6]
	set_location_assignment PIN_D21 -to dac0_dfb_dat[7]
	set_location_assignment PIN_E20 -to dac0_dfb_dat[8]
	set_location_assignment PIN_F20 -to dac0_dfb_dat[9]
	set_location_assignment PIN_F19 -to dac0_dfb_dat[10]
	set_location_assignment PIN_D18 -to dac0_dfb_dat[11]
	set_location_assignment PIN_E17 -to dac0_dfb_dat[12]
	set_location_assignment PIN_E16 -to dac0_dfb_dat[13]
	set_location_assignment PIN_A18 -to dac1_dfb_dat[0]
	set_location_assignment PIN_B19 -to dac1_dfb_dat[1]
	set_location_assignment PIN_A19 -to dac1_dfb_dat[2]
	set_location_assignment PIN_B20 -to dac1_dfb_dat[3]
	set_location_assignment PIN_A20 -to dac1_dfb_dat[4]
	set_location_assignment PIN_A21 -to dac1_dfb_dat[5]
	set_location_assignment PIN_B22 -to dac1_dfb_dat[6]
	set_location_assignment PIN_A22 -to dac1_dfb_dat[7]
	set_location_assignment PIN_B23 -to dac1_dfb_dat[8]
	set_location_assignment PIN_A23 -to dac1_dfb_dat[9]
	set_location_assignment PIN_B25 -to dac1_dfb_dat[10]
	set_location_assignment PIN_A25 -to dac1_dfb_dat[11]
	set_location_assignment PIN_B26 -to dac1_dfb_dat[12]
	set_location_assignment PIN_A26 -to dac1_dfb_dat[13]
	set_location_assignment PIN_G18 -to dac2_dfb_dat[0]
	set_location_assignment PIN_H19 -to dac2_dfb_dat[1]
	set_location_assignment PIN_J16 -to dac2_dfb_dat[2]
	set_location_assignment PIN_T8 -to dac2_dfb_dat[3]
	set_location_assignment PIN_B4 -to dac2_dfb_dat[4]
	set_location_assignment PIN_A3 -to dac2_dfb_dat[5]
	set_location_assignment PIN_A2 -to dac2_dfb_dat[6]
	set_location_assignment PIN_B2 -to dac2_dfb_dat[7]
	set_location_assignment PIN_B1 -to dac2_dfb_dat[8]
	set_location_assignment PIN_C1 -to dac2_dfb_dat[9]
	set_location_assignment PIN_D2 -to dac2_dfb_dat[10]
	set_location_assignment PIN_D1 -to dac2_dfb_dat[11]
	set_location_assignment PIN_E2 -to dac2_dfb_dat[12]
	set_location_assignment PIN_E1 -to dac2_dfb_dat[13]
	set_location_assignment PIN_A4 -to dac3_dfb_dat[0]
	set_location_assignment PIN_B5 -to dac3_dfb_dat[1]
	set_location_assignment PIN_A5 -to dac3_dfb_dat[2]
	set_location_assignment PIN_A6 -to dac3_dfb_dat[3]
	set_location_assignment PIN_B7 -to dac3_dfb_dat[4]
	set_location_assignment PIN_A7 -to dac3_dfb_dat[5]
	set_location_assignment PIN_B8 -to dac3_dfb_dat[6]
	set_location_assignment PIN_A8 -to dac3_dfb_dat[7]
	set_location_assignment PIN_A9 -to dac3_dfb_dat[8]
	set_location_assignment PIN_C9 -to dac3_dfb_dat[9]
	set_location_assignment PIN_A15 -to dac3_dfb_dat[10]
	set_location_assignment PIN_B16 -to dac3_dfb_dat[11]
	set_location_assignment PIN_A16 -to dac3_dfb_dat[12]
	set_location_assignment PIN_B17 -to dac3_dfb_dat[13]
	set_location_assignment PIN_G22 -to dac4_dfb_dat[0]
	set_location_assignment PIN_F22 -to dac4_dfb_dat[1]
	set_location_assignment PIN_E23 -to dac4_dfb_dat[2]
	set_location_assignment PIN_D25 -to dac4_dfb_dat[3]
	set_location_assignment PIN_C24 -to dac4_dfb_dat[4]
	set_location_assignment PIN_D24 -to dac4_dfb_dat[5]
	set_location_assignment PIN_C23 -to dac4_dfb_dat[6]
	set_location_assignment PIN_D23 -to dac4_dfb_dat[7]
	set_location_assignment PIN_D22 -to dac4_dfb_dat[8]
	set_location_assignment PIN_C21 -to dac4_dfb_dat[9]
	set_location_assignment PIN_D20 -to dac4_dfb_dat[10]
	set_location_assignment PIN_C19 -to dac4_dfb_dat[11]
	set_location_assignment PIN_D19 -to dac4_dfb_dat[12]
	set_location_assignment PIN_C18 -to dac4_dfb_dat[13]
	set_location_assignment PIN_V1 -to dac5_dfb_dat[0]
	set_location_assignment PIN_U1 -to dac5_dfb_dat[1]
	set_location_assignment PIN_P4 -to dac5_dfb_dat[2]
	set_location_assignment PIN_N1 -to dac5_dfb_dat[3]
	set_location_assignment PIN_N2 -to dac5_dfb_dat[4]
	set_location_assignment PIN_M1 -to dac5_dfb_dat[5]
	set_location_assignment PIN_L1 -to dac5_dfb_dat[6]
	set_location_assignment PIN_L2 -to dac5_dfb_dat[7]
	set_location_assignment PIN_K1 -to dac5_dfb_dat[8]
	set_location_assignment PIN_K2 -to dac5_dfb_dat[9]
	set_location_assignment PIN_J1 -to dac5_dfb_dat[10]
	set_location_assignment PIN_H1 -to dac5_dfb_dat[11]
	set_location_assignment PIN_H2 -to dac5_dfb_dat[12]
	set_location_assignment PIN_G1 -to dac5_dfb_dat[13]
	set_location_assignment PIN_D17 -to dac6_dfb_dat[0]
	set_location_assignment PIN_D16 -to dac6_dfb_dat[1]
	set_location_assignment PIN_C15 -to dac6_dfb_dat[2]
	set_location_assignment PIN_D15 -to dac6_dfb_dat[3]
	set_location_assignment PIN_C8 -to dac6_dfb_dat[4]
	set_location_assignment PIN_D7 -to dac6_dfb_dat[5]
	set_location_assignment PIN_C6 -to dac6_dfb_dat[6]
	set_location_assignment PIN_C5 -to dac6_dfb_dat[7]
	set_location_assignment PIN_F4 -to dac6_dfb_dat[8]
	set_location_assignment PIN_F3 -to dac6_dfb_dat[9]
	set_location_assignment PIN_G3 -to dac6_dfb_dat[10]
	set_location_assignment PIN_G4 -to dac6_dfb_dat[11]
	set_location_assignment PIN_H3 -to dac6_dfb_dat[12]
	set_location_assignment PIN_H4 -to dac6_dfb_dat[13]
	set_location_assignment PIN_D9 -to dac7_dfb_dat[0]
	set_location_assignment PIN_D8 -to dac7_dfb_dat[1]
	set_location_assignment PIN_D6 -to dac7_dfb_dat[2]
	set_location_assignment PIN_E7 -to dac7_dfb_dat[3]
	set_location_assignment PIN_R10 -to dac7_dfb_dat[4]
	set_location_assignment PIN_N9 -to dac7_dfb_dat[5]
	set_location_assignment PIN_N8 -to dac7_dfb_dat[6]
	set_location_assignment PIN_K8 -to dac7_dfb_dat[7]
	set_location_assignment PIN_N7 -to dac7_dfb_dat[8]
	set_location_assignment PIN_N6 -to dac7_dfb_dat[9]
	set_location_assignment PIN_K6 -to dac7_dfb_dat[10]
	set_location_assignment PIN_K7 -to dac7_dfb_dat[11]
	set_location_assignment PIN_J6 -to dac7_dfb_dat[12]
	set_location_assignment PIN_H5 -to dac7_dfb_dat[13]
	set_location_assignment PIN_F17 -to dac_fb_clk[0]
	set_location_assignment PIN_A27 -to dac_fb_clk[1]
	set_location_assignment PIN_F1 -to dac_fb_clk[2]
	set_location_assignment PIN_A17 -to dac_fb_clk[3]
	set_location_assignment PIN_C17 -to dac_fb_clk[4]
	set_location_assignment PIN_G2 -to dac_fb_clk[5]
	set_location_assignment PIN_J3 -to dac_fb_clk[6]
	set_location_assignment PIN_H6 -to dac_fb_clk[7]
	set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to adc_pdwn
	set_instance_assignment -name IO_STANDARD LVDS -to adc_fco_p
	set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.8-V SSTL CLASS I" -to ddr_dqs[0]
	set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.8-V SSTL CLASS I" -to ddr_dqs[1]
	set_instance_assignment -name DQSB_DQS_PAIR ON -from ddr_dqsn[0] -to ddr_dqs[0]
	set_instance_assignment -name DQSB_DQS_PAIR ON -from ddr_dqsn[1] -to ddr_dqs[1]
	set_instance_assignment -name DQ_GROUP 9 -from ddr_dqs[0] -to ddr_dq[0]
	set_instance_assignment -name DQ_GROUP 9 -from ddr_dqs[0] -to ddr_dq[1]
	set_instance_assignment -name DQ_GROUP 9 -from ddr_dqs[0] -to ddr_dq[2]
	set_instance_assignment -name DQ_GROUP 9 -from ddr_dqs[0] -to ddr_dq[3]
	set_instance_assignment -name DQ_GROUP 9 -from ddr_dqs[0] -to ddr_dq[4]
	set_instance_assignment -name DQ_GROUP 9 -from ddr_dqs[0] -to ddr_dq[5]
	set_instance_assignment -name DQ_GROUP 9 -from ddr_dqs[0] -to ddr_dq[6]
	set_instance_assignment -name DQ_GROUP 9 -from ddr_dqs[0] -to ddr_dq[7]
	set_instance_assignment -name DQ_GROUP 9 -from ddr_dqs[1] -to ddr_dq[8]
	set_instance_assignment -name DQ_GROUP 9 -from ddr_dqs[1] -to ddr_dq[9]
	set_instance_assignment -name DQ_GROUP 9 -from ddr_dqs[1] -to ddr_dq[10]
	set_instance_assignment -name DQ_GROUP 9 -from ddr_dqs[1] -to ddr_dq[11]
	set_instance_assignment -name DQ_GROUP 9 -from ddr_dqs[1] -to ddr_dq[12]
	set_instance_assignment -name DQ_GROUP 9 -from ddr_dqs[1] -to ddr_dq[13]
	set_instance_assignment -name DQ_GROUP 9 -from ddr_dqs[1] -to ddr_dq[14]
	set_instance_assignment -name DQ_GROUP 9 -from ddr_dqs[1] -to ddr_dq[15]
	set_instance_assignment -name DQ_GROUP 9 -from ddr_dqs[0] -to ddr_ldm[0]
	set_instance_assignment -name DQ_GROUP 9 -from ddr_dqs[1] -to ddr_udm[0]

	# Including default assignments
	set_global_assignment -name USE_TIMEQUEST_TIMING_ANALYZER ON -family "Stratix III"
	set_global_assignment -name TIMEQUEST_DO_REPORT_TIMING OFF
	set_global_assignment -name DEVICE_FILTER_PACKAGE ANY
	set_global_assignment -name DEVICE_FILTER_PIN_COUNT ANY
	set_global_assignment -name DEVICE_FILTER_SPEED_GRADE ANY
	set_global_assignment -name RESERVE_ALL_UNUSED_PINS "AS OUTPUT DRIVING GROUND"
	set_global_assignment -name OPTIMIZE_HOLD_TIMING "ALL PATHS" -family "Stratix III"
	set_global_assignment -name CONFIGURATION_VCCIO_LEVEL AUTO
	set_global_assignment -name ACTIVE_SERIAL_CLOCK FREQ_40MHZ
	set_global_assignment -name CYCLONEIII_CONFIGURATION_DEVICE AUTO
	set_global_assignment -name RESERVE_ALL_UNUSED_PINS_NO_OUTPUT_GND "AS OUTPUT DRIVING AN UNSPECIFIED SIGNAL"
	set_global_assignment -name HARDCOPYII_POWER_ON_EXTRA_DELAY OFF
	set_global_assignment -name ISP_CLAMP_STATE_DEFAULT "TRI-STATE"
	set_global_assignment -name TOP_LEVEL_ENTITY readout_card_stratix_iii

	# Commit assignments
	export_assignments

	# Close project
	if {$need_to_close_project} {
		project_close
	}
}
