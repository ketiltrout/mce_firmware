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
# File: readout_card.tcl
# Generated on: Mon Jan 10 17:49:45 2005

# Load Quartus II Tcl Project package
package require ::quartus::project

set need_to_close_project 0
set make_assignments 1

# Check that the right project is open
if {[is_project_open]} {
	if {[string compare $quartus(project) "readout_card"]} {
		puts "Project readout_card is not open"
		set make_assignments 0
	}
} else {
	# Only open if not already open
	if {[project_exists readout_card]} {
		project_open -revision readout_card readout_card
	} else {
		project_new -revision readout_card readout_card
	}
	set need_to_close_project 1
}

# Make assignments
if {$make_assignments} {
	set_global_assignment -name ORIGINAL_QUARTUS_VERSION 4.1
	set_global_assignment -name PROJECT_CREATION_TIME_DATE "13:51:03  NOVEMBER 16, 2004"
	set_global_assignment -name LAST_QUARTUS_VERSION "4.1 SP2"
	set_global_assignment -name VHDL_FILE ../../../library/sys_param/source/rtl/general_pack.vhd
	set_global_assignment -name VHDL_FILE ../../../library/sys_param/source/rtl/command_pack.vhd
	set_global_assignment -name VHDL_FILE ../../../library/sys_param/source/rtl/wishbone_pack.vhd
	set_global_assignment -name VHDL_FILE ../../../library/sys_param/source/rtl/data_types_pack.vhd
	set_global_assignment -name VHDL_FILE ../../../all_cards/frame_timing/source/rtl/frame_timing_pack.vhd
	set_global_assignment -name VHDL_FILE ../../../all_cards/frame_timing/source/rtl/frame_timing_wbs_pack.vhd
	set_global_assignment -name VHDL_FILE ../../../all_cards/frame_timing/source/rtl/frame_timing_core_pack.vhd
	set_global_assignment -name VHDL_FILE ../../../all_cards/dispatch/source/rtl/dispatch_pack.vhd
	set_global_assignment -name VHDL_FILE ../../../all_cards/async/source/rtl/ascii_pack.vhd
	set_global_assignment -name VHDL_FILE ../../../library/components/source/rtl/component_pack.vhd
	set_global_assignment -name VHDL_FILE ../source/rtl/readout_card_pack.vhd
	set_global_assignment -name VHDL_FILE ../../flux_loop/source/rtl/flux_loop_pack.vhd
	set_global_assignment -name VHDL_FILE ../../flux_loop_ctrl/source/rtl/flux_loop_ctrl_pack.vhd
	set_global_assignment -name VHDL_FILE ../../adc_sample_coadd/source/rtl/adc_sample_coadd_pack.vhd
	set_global_assignment -name VHDL_FILE ../../fsfb_ctrl/source/rtl/fsfb_ctrl_pack.vhd
	set_global_assignment -name VHDL_FILE ../../fsfb_calc/source/rtl/fsfb_calc_pack.vhd
	set_global_assignment -name VHDL_FILE ../../sa_bias_ctrl/source/rtl/sa_bias_ctrl_pack.vhd
	set_global_assignment -name VHDL_FILE ../../offset_ctrl/source/rtl/offset_ctrl_pack.vhd
	set_global_assignment -name VHDL_FILE ../../wbs_fb_data/source/rtl/wbs_fb_data_pack.vhd
	set_global_assignment -name VHDL_FILE ../../wbs_frame_data/source/rtl/wbs_frame_data_pack.vhd
	set_global_assignment -name VHDL_FILE ../../../all_cards/async/source/rtl/async_pack.vhd
	set_global_assignment -name VHDL_FILE ../../../all_cards/leds/source/rtl/leds_pack.vhd
	set_global_assignment -name VHDL_FILE ../../../library/components/source/rtl/fifo.vhd
	set_global_assignment -name VHDL_FILE ../../../library/components/source/rtl/us_timer.vhd
	set_global_assignment -name VHDL_FILE ../../../library/components/source/rtl/shift_reg.vhd
	set_global_assignment -name VHDL_FILE ../../../library/components/source/rtl/reg.vhd
	set_global_assignment -name VHDL_FILE ../../../library/components/source/rtl/crc.vhd
	set_global_assignment -name VHDL_FILE ../../../all_cards/leds/source/rtl/leds.vhd
	set_global_assignment -name VHDL_FILE ../../../library/components/source/rtl/counter.vhd
	set_global_assignment -name VHDL_FILE ../../../all_cards/async/source/rtl/rs232_tx.vhd
	set_global_assignment -name VHDL_FILE ../../../all_cards/async/source/rtl/async_rx.vhd
	set_global_assignment -name VHDL_FILE ../../../all_cards/async/source/rtl/async_tx.vhd
	set_global_assignment -name VHDL_FILE ../../../all_cards/async/source/rtl/lvds_rx.vhd
	set_global_assignment -name VHDL_FILE ../../../all_cards/async/source/rtl/lvds_tx.vhd
	set_global_assignment -name VHDL_FILE ../../../all_cards/async/source/rtl/rs232_rx.vhd
	set_global_assignment -name VHDL_FILE ../../../all_cards/frame_timing/source/rtl/frame_timing_wbs.vhd
	set_global_assignment -name VHDL_FILE ../../../all_cards/frame_timing/source/rtl/frame_timing.vhd
	set_global_assignment -name VHDL_FILE ../../../all_cards/frame_timing/source/rtl/frame_timing_core.vhd
	set_global_assignment -name VHDL_FILE ../../../all_cards/dispatch/source/rtl/dispatch_wishbone.vhd
	set_global_assignment -name VHDL_FILE ../../../all_cards/dispatch/source/rtl/dispatch_cmd_receive.vhd
	set_global_assignment -name VHDL_FILE ../../../all_cards/dispatch/source/rtl/dispatch_data_buf.vhd
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
	set_global_assignment -name VHDL_FILE ../../fsfb_ctrl/source/rtl/fsfb_ctrl.vhd
	set_global_assignment -name VHDL_FILE ../../fsfb_calc/source/rtl/fsfb_calc_add_sub16.vhd
	set_global_assignment -name VHDL_FILE ../../fsfb_calc/source/rtl/fsfb_calc_adder65.vhd
	set_global_assignment -name VHDL_FILE ../../fsfb_calc/source/rtl/fsfb_calc_adder66.vhd
	set_global_assignment -name VHDL_FILE ../../fsfb_calc/source/rtl/fsfb_queue.vhd
	set_global_assignment -name VHDL_FILE ../../fsfb_calc/source/rtl/fsfb_io_controller.vhd
	set_global_assignment -name VHDL_FILE ../../fsfb_calc/source/rtl/fsfb_proc_pidz.vhd
	set_global_assignment -name VHDL_FILE ../../fsfb_calc/source/rtl/fsfb_proc_ramp.vhd
	set_global_assignment -name VHDL_FILE ../../fsfb_calc/source/rtl/fsfb_processor.vhd
	set_global_assignment -name VHDL_FILE ../../fsfb_calc/source/rtl/fsfb_calc_multiplier.vhd
	set_global_assignment -name VHDL_FILE ../../fsfb_calc/source/rtl/fsfb_calc.vhd
	set_global_assignment -name VHDL_FILE ../../flux_loop_ctrl/source/rtl/flux_loop_ctrl.vhd
	set_global_assignment -name VHDL_FILE ../../pll/source/rtl/rc_pll.vhd
	set_global_assignment -name VHDL_FILE ../../wbs_frame_data/source/rtl/wbs_frame_data.vhd
	set_global_assignment -name VHDL_FILE ../../wbs_fb_data/source/rtl/wbs_fb_storage.vhd
	set_global_assignment -name VHDL_FILE ../../wbs_fb_data/source/rtl/p_banks_admin.vhd
	set_global_assignment -name VHDL_FILE ../../wbs_fb_data/source/rtl/i_banks_admin.vhd
	set_global_assignment -name VHDL_FILE ../../wbs_fb_data/source/rtl/d_banks_admin.vhd
	set_global_assignment -name VHDL_FILE ../../wbs_fb_data/source/rtl/z_banks_admin.vhd
	set_global_assignment -name VHDL_FILE ../../wbs_fb_data/source/rtl/adc_offset_banks_admin.vhd
	set_global_assignment -name VHDL_FILE ../../wbs_fb_data/source/rtl/misc_banks_admin.vhd
	set_global_assignment -name VHDL_FILE ../../wbs_fb_data/source/rtl/wbs_fb_data.vhd
	set_global_assignment -name VHDL_FILE ../../flux_loop/source/rtl/flux_loop.vhd
	set_global_assignment -name VHDL_FILE ../source/rtl/readout_card.vhd
	set_global_assignment -name DUTY_CYCLE 50 -section_id inclk
	set_global_assignment -name FMAX_REQUIREMENT "25.0 MHz" -section_id inclk
	set_global_assignment -name MUX_RESTRUCTURE OFF
	set_global_assignment -name SPEED_DISK_USAGE_TRADEOFF SMART
	set_global_assignment -name DEVICE_FILTER_SPEED_GRADE FASTEST
	set_global_assignment -name FAMILY Stratix
	set_global_assignment -name STATE_MACHINE_PROCESSING "ONE-HOT"
	set_global_assignment -name REMOVE_REDUNDANT_LOGIC_CELLS ON
	set_global_assignment -name STRATIX_OPTIMIZATION_TECHNIQUE SPEED
	set_global_assignment -name ADV_NETLIST_OPT_SYNTH_WYSIWYG_REMAP OFF
	set_global_assignment -name ADV_NETLIST_OPT_SYNTH_GATE_RETIME OFF
	set_global_assignment -name AUTO_ENABLE_SMART_COMPILE on
	set_global_assignment -name DEVICE EP1S30F780C5
	set_global_assignment -name ENABLE_DEVICE_WIDE_RESET OFF
	set_global_assignment -name CRC_ERROR_CHECKING ON
	set_global_assignment -name RESERVE_ALL_UNUSED_PINS "AS INPUT TRI-STATED"
	set_global_assignment -name FINAL_PLACEMENT_OPTIMIZATION ALWAYS
	set_global_assignment -name AUTO_GLOBAL_MEMORY_CONTROLS ON
	set_global_assignment -name PHYSICAL_SYNTHESIS_REGISTER_DUPLICATION ON
	set_global_assignment -name PHYSICAL_SYNTHESIS_REGISTER_RETIMING OFF
	set_global_assignment -name FITTER_AUTO_EFFORT_DESIRED_SLACK_MARGIN 2ns
	set_global_assignment -name PHYSICAL_SYNTHESIS_EFFORT NORMAL
	set_global_assignment -name ERROR_CHECK_FREQUENCY_DIVISOR 1
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
	set_global_assignment -name ENABLE_SIGNALTAP off
	set_global_assignment -name USE_SIGNALTAP_FILE readout_card.stp
	set_global_assignment -name LOGICLOCK_INCREMENTAL_COMPILE_ASSIGNMENT off
	set_global_assignment -name TIMEGROUP_MEMBER adc1_ovr -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc1_rdy -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc2_ovr -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc2_rdy -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc3_ovr -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc3_rdy -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc4_ovr -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc4_rdy -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc5_ovr -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc5_rdy -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc6_ovr -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc6_rdy -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc7_ovr -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc7_rdy -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc8_ovr -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc8_rdy -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc1_dat\[0\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc1_dat\[1\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc1_dat\[2\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc1_dat\[3\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc1_dat\[4\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc1_dat\[5\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc1_dat\[6\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc1_dat\[7\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc1_dat\[8\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc1_dat\[9\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc1_dat\[10\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc1_dat\[11\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc1_dat\[12\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc1_dat\[13\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc2_dat\[0\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc2_dat\[1\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc2_dat\[2\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc2_dat\[3\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc2_dat\[4\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc2_dat\[5\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc2_dat\[6\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc2_dat\[7\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc2_dat\[8\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc2_dat\[9\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc2_dat\[10\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc2_dat\[11\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc2_dat\[12\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc2_dat\[13\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc3_dat\[0\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc3_dat\[1\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc3_dat\[2\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc3_dat\[3\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc3_dat\[4\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc3_dat\[5\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc3_dat\[6\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc3_dat\[7\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc3_dat\[8\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc3_dat\[9\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc3_dat\[10\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc3_dat\[11\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc3_dat\[12\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc3_dat\[13\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc4_dat\[0\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc4_dat\[1\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc4_dat\[2\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc4_dat\[3\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc4_dat\[4\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc4_dat\[5\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc4_dat\[6\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc4_dat\[7\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc4_dat\[8\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc4_dat\[9\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc4_dat\[10\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc4_dat\[11\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc4_dat\[12\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc4_dat\[13\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc5_dat\[0\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc5_dat\[1\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc5_dat\[2\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc5_dat\[3\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc5_dat\[4\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc5_dat\[5\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc5_dat\[6\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc5_dat\[7\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc5_dat\[8\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc5_dat\[9\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc5_dat\[10\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc5_dat\[11\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc5_dat\[12\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc5_dat\[13\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc6_dat\[0\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc6_dat\[1\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc6_dat\[2\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc6_dat\[3\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc6_dat\[4\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc6_dat\[5\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc6_dat\[6\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc6_dat\[7\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc6_dat\[8\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc6_dat\[9\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc6_dat\[10\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc6_dat\[11\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc6_dat\[12\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc6_dat\[13\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc7_dat\[0\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc7_dat\[1\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc7_dat\[2\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc7_dat\[3\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc7_dat\[4\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc7_dat\[5\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc7_dat\[6\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc7_dat\[7\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc7_dat\[8\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc7_dat\[9\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc7_dat\[10\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc7_dat\[11\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc7_dat\[12\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc7_dat\[13\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc8_dat\[0\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc8_dat\[1\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc8_dat\[2\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc8_dat\[3\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc8_dat\[4\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc8_dat\[5\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc8_dat\[6\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc8_dat\[7\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc8_dat\[8\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc8_dat\[9\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc8_dat\[10\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc8_dat\[11\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc8_dat\[12\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc8_dat\[13\] -section_id "ADC Inputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc1_clk -section_id "ADC Outputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc2_clk -section_id "ADC Outputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc3_clk -section_id "ADC Outputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc4_clk -section_id "ADC Outputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc5_clk -section_id "ADC Outputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc6_clk -section_id "ADC Outputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc7_clk -section_id "ADC Outputs"
	set_global_assignment -name TIMEGROUP_MEMBER adc8_clk -section_id "ADC Outputs"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB1_dat\[0\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB1_dat\[1\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB1_dat\[2\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB1_dat\[3\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB1_dat\[4\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB1_dat\[5\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB1_dat\[6\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB1_dat\[7\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB1_dat\[8\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB1_dat\[9\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB1_dat\[10\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB1_dat\[11\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB1_dat\[12\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB1_dat\[13\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB2_dat\[0\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB2_dat\[1\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB2_dat\[2\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB2_dat\[3\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB2_dat\[4\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB2_dat\[5\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB2_dat\[6\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB2_dat\[7\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB2_dat\[8\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB2_dat\[9\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB2_dat\[10\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB2_dat\[11\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB2_dat\[12\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB2_dat\[13\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB3_dat\[0\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB3_dat\[1\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB3_dat\[2\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB3_dat\[3\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB3_dat\[4\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB3_dat\[5\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB3_dat\[6\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB3_dat\[7\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB3_dat\[8\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB3_dat\[9\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB3_dat\[10\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB3_dat\[11\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB3_dat\[12\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB3_dat\[13\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB4_dat\[0\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB4_dat\[1\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB4_dat\[2\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB4_dat\[3\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB4_dat\[4\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB4_dat\[5\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB4_dat\[6\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB4_dat\[7\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB4_dat\[8\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB4_dat\[9\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB4_dat\[10\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB4_dat\[11\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB4_dat\[12\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB4_dat\[13\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB5_dat\[0\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB5_dat\[1\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB5_dat\[2\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB5_dat\[3\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB5_dat\[4\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB5_dat\[5\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB5_dat\[6\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB5_dat\[7\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB5_dat\[8\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB5_dat\[9\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB5_dat\[10\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB5_dat\[11\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB5_dat\[12\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB5_dat\[13\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB6_dat\[0\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB6_dat\[1\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB6_dat\[2\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB6_dat\[3\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB6_dat\[4\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB6_dat\[5\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB6_dat\[6\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB6_dat\[7\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB6_dat\[8\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB6_dat\[9\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB6_dat\[10\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB6_dat\[11\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB6_dat\[12\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB6_dat\[13\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB7_dat\[0\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB7_dat\[1\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB7_dat\[2\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB7_dat\[3\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB7_dat\[4\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB7_dat\[5\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB7_dat\[6\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB7_dat\[7\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB7_dat\[8\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB7_dat\[9\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB7_dat\[10\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB7_dat\[11\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB7_dat\[12\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB7_dat\[13\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB8_dat\[0\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB8_dat\[1\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB8_dat\[2\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB8_dat\[3\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB8_dat\[4\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB8_dat\[5\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB8_dat\[6\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB8_dat\[7\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB8_dat\[8\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB8_dat\[9\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB8_dat\[10\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB8_dat\[11\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB8_dat\[12\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB8_dat\[13\] -section_id "DAC Data Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB_clk\[0\] -section_id "DAC clk Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB_clk\[1\] -section_id "DAC clk Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB_clk\[2\] -section_id "DAC clk Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB_clk\[3\] -section_id "DAC clk Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB_clk\[4\] -section_id "DAC clk Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB_clk\[5\] -section_id "DAC clk Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB_clk\[6\] -section_id "DAC clk Output"
	set_global_assignment -name TIMEGROUP_MEMBER dac_FB_clk\[7\] -section_id "DAC clk Output"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch0\|fsfb_ctrl:i_fsfb_ctrl\|dac_clk" -section_id "DAC clk output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch1\|fsfb_ctrl:i_fsfb_ctrl\|dac_clk" -section_id "DAC clk output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch2\|fsfb_ctrl:i_fsfb_ctrl\|dac_clk" -section_id "DAC clk output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch3\|fsfb_ctrl:i_fsfb_ctrl\|dac_clk" -section_id "DAC clk output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch4\|fsfb_ctrl:i_fsfb_ctrl\|dac_clk" -section_id "DAC clk output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch5\|fsfb_ctrl:i_fsfb_ctrl\|dac_clk" -section_id "DAC clk output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch6\|fsfb_ctrl:i_fsfb_ctrl\|dac_clk" -section_id "DAC clk output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch7\|fsfb_ctrl:i_fsfb_ctrl\|dac_clk" -section_id "DAC clk output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch0\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[0\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch0\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[1\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch0\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[2\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch0\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[3\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch0\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[4\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch0\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[5\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch0\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[6\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch0\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[7\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch0\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[8\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch0\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[9\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch0\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[10\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch0\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[11\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch0\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[12\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch0\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[13\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch1\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[0\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch1\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[1\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch1\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[2\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch1\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[3\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch1\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[4\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch1\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[5\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch1\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[6\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch1\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[7\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch1\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[8\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch1\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[9\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch1\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[10\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch1\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[11\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch1\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[12\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch1\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[13\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch2\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[0\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch2\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[1\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch2\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[2\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch2\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[3\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch2\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[4\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch2\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[5\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch2\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[6\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch2\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[7\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch2\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[8\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch2\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[9\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch2\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[10\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch2\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[11\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch2\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[12\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch2\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[13\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch3\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[0\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch3\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[1\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch3\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[2\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch3\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[3\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch3\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[4\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch3\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[5\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch3\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[6\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch3\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[7\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch3\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[8\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch3\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[9\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch3\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[10\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch3\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[11\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch3\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[12\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch3\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[13\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch4\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[0\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch4\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[1\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch4\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[2\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch4\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[3\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch4\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[4\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch4\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[5\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch4\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[6\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch4\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[7\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch4\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[8\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch4\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[9\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch4\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[10\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch4\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[11\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch4\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[12\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch4\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[13\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch5\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[0\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch5\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[1\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch5\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[2\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch5\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[3\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch5\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[4\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch5\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[5\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch5\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[6\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch5\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[7\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch5\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[8\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch5\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[9\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch5\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[10\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch5\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[11\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch5\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[12\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch5\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[13\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch6\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[0\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch6\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[1\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch6\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[2\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch6\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[3\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch6\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[4\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch6\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[5\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch6\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[6\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch6\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[7\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch6\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[8\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch6\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[9\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch6\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[10\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch6\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[11\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch6\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[12\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch6\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[13\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch7\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[0\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch7\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[1\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch7\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[2\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch7\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[3\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch7\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[4\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch7\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[5\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch7\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[6\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch7\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[7\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch7\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[8\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch7\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[9\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch7\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[10\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch7\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[11\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch7\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[12\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch7\|fsfb_ctrl:i_fsfb_ctrl\|dac_dat_o\[13\]~reg0" -section_id "DAC data output reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch0\|offset_ctrl:i_offset_ctrl\|offset_spi_if:i_offset_spi_if\|spi_csb_o~reg0" -section_id "Serial DA data & CS reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch0\|sa_bias_ctrl:i_sa_bias_ctrl\|sa_bias_spi_if:i_sa_bias_spi_if\|spi_csb_o~reg0" -section_id "Serial DA data & CS reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch1\|offset_ctrl:i_offset_ctrl\|offset_spi_if:i_offset_spi_if\|spi_csb_o~reg0" -section_id "Serial DA data & CS reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch1\|sa_bias_ctrl:i_sa_bias_ctrl\|sa_bias_spi_if:i_sa_bias_spi_if\|spi_csb_o~reg0" -section_id "Serial DA data & CS reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch2\|offset_ctrl:i_offset_ctrl\|offset_spi_if:i_offset_spi_if\|spi_csb_o~reg0" -section_id "Serial DA data & CS reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch2\|sa_bias_ctrl:i_sa_bias_ctrl\|sa_bias_spi_if:i_sa_bias_spi_if\|spi_csb_o~reg0" -section_id "Serial DA data & CS reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch3\|offset_ctrl:i_offset_ctrl\|offset_spi_if:i_offset_spi_if\|spi_csb_o~reg0" -section_id "Serial DA data & CS reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch3\|sa_bias_ctrl:i_sa_bias_ctrl\|sa_bias_spi_if:i_sa_bias_spi_if\|spi_csb_o~reg0" -section_id "Serial DA data & CS reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch4\|offset_ctrl:i_offset_ctrl\|offset_spi_if:i_offset_spi_if\|spi_csb_o~reg0" -section_id "Serial DA data & CS reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch4\|sa_bias_ctrl:i_sa_bias_ctrl\|sa_bias_spi_if:i_sa_bias_spi_if\|spi_csb_o~reg0" -section_id "Serial DA data & CS reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch5\|offset_ctrl:i_offset_ctrl\|offset_spi_if:i_offset_spi_if\|spi_csb_o~reg0" -section_id "Serial DA data & CS reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch5\|sa_bias_ctrl:i_sa_bias_ctrl\|sa_bias_spi_if:i_sa_bias_spi_if\|spi_csb_o~reg0" -section_id "Serial DA data & CS reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch6\|offset_ctrl:i_offset_ctrl\|offset_spi_if:i_offset_spi_if\|spi_csb_o~reg0" -section_id "Serial DA data & CS reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch6\|sa_bias_ctrl:i_sa_bias_ctrl\|sa_bias_spi_if:i_sa_bias_spi_if\|spi_csb_o~reg0" -section_id "Serial DA data & CS reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch7\|offset_ctrl:i_offset_ctrl\|offset_spi_if:i_offset_spi_if\|spi_csb_o~reg0" -section_id "Serial DA data & CS reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch7\|sa_bias_ctrl:i_sa_bias_ctrl\|sa_bias_spi_if:i_sa_bias_spi_if\|spi_csb_o~reg0" -section_id "Serial DA data & CS reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch0\|offset_ctrl:i_offset_ctrl\|offset_spi_if:i_offset_spi_if\|spi_sdat_o~reg0" -section_id "Serial DA data & CS reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch0\|sa_bias_ctrl:i_sa_bias_ctrl\|sa_bias_spi_if:i_sa_bias_spi_if\|spi_sdat_o~reg0" -section_id "Serial DA data & CS reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch1\|offset_ctrl:i_offset_ctrl\|offset_spi_if:i_offset_spi_if\|spi_sdat_o~reg0" -section_id "Serial DA data & CS reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch1\|sa_bias_ctrl:i_sa_bias_ctrl\|sa_bias_spi_if:i_sa_bias_spi_if\|spi_sdat_o~reg0" -section_id "Serial DA data & CS reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch2\|offset_ctrl:i_offset_ctrl\|offset_spi_if:i_offset_spi_if\|spi_sdat_o~reg0" -section_id "Serial DA data & CS reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch2\|sa_bias_ctrl:i_sa_bias_ctrl\|sa_bias_spi_if:i_sa_bias_spi_if\|spi_sdat_o~reg0" -section_id "Serial DA data & CS reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch3\|offset_ctrl:i_offset_ctrl\|offset_spi_if:i_offset_spi_if\|spi_sdat_o~reg0" -section_id "Serial DA data & CS reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch3\|sa_bias_ctrl:i_sa_bias_ctrl\|sa_bias_spi_if:i_sa_bias_spi_if\|spi_sdat_o~reg0" -section_id "Serial DA data & CS reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch4\|offset_ctrl:i_offset_ctrl\|offset_spi_if:i_offset_spi_if\|spi_sdat_o~reg0" -section_id "Serial DA data & CS reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch4\|sa_bias_ctrl:i_sa_bias_ctrl\|sa_bias_spi_if:i_sa_bias_spi_if\|spi_sdat_o~reg0" -section_id "Serial DA data & CS reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch5\|offset_ctrl:i_offset_ctrl\|offset_spi_if:i_offset_spi_if\|spi_sdat_o~reg0" -section_id "Serial DA data & CS reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch5\|sa_bias_ctrl:i_sa_bias_ctrl\|sa_bias_spi_if:i_sa_bias_spi_if\|spi_sdat_o~reg0" -section_id "Serial DA data & CS reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch6\|offset_ctrl:i_offset_ctrl\|offset_spi_if:i_offset_spi_if\|spi_sdat_o~reg0" -section_id "Serial DA data & CS reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch6\|sa_bias_ctrl:i_sa_bias_ctrl\|sa_bias_spi_if:i_sa_bias_spi_if\|spi_sdat_o~reg0" -section_id "Serial DA data & CS reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch7\|offset_ctrl:i_offset_ctrl\|offset_spi_if:i_offset_spi_if\|spi_sdat_o~reg0" -section_id "Serial DA data & CS reg"
	set_global_assignment -name TIMEGROUP_MEMBER "flux_loop:i_flux_loop\|flux_loop_ctrl:i_flux_loop_ctrl_ch7\|sa_bias_ctrl:i_sa_bias_ctrl\|sa_bias_spi_if:i_sa_bias_spi_if\|spi_sdat_o~reg0" -section_id "Serial DA data & CS reg"
	set_global_assignment -name TIMEGROUP_MEMBER dac_clk\[0\] -section_id "serial DAC clk"
	set_global_assignment -name TIMEGROUP_MEMBER dac_clk\[1\] -section_id "serial DAC clk"
	set_global_assignment -name TIMEGROUP_MEMBER dac_clk\[2\] -section_id "serial DAC clk"
	set_global_assignment -name TIMEGROUP_MEMBER dac_clk\[3\] -section_id "serial DAC clk"
	set_global_assignment -name TIMEGROUP_MEMBER dac_clk\[4\] -section_id "serial DAC clk"
	set_global_assignment -name TIMEGROUP_MEMBER dac_clk\[5\] -section_id "serial DAC clk"
	set_global_assignment -name TIMEGROUP_MEMBER dac_clk\[6\] -section_id "serial DAC clk"
	set_global_assignment -name TIMEGROUP_MEMBER dac_clk\[7\] -section_id "serial DAC clk"
	set_global_assignment -name TIMEGROUP_MEMBER dac_dat\[0\] -section_id "serial DAC data&cs"
	set_global_assignment -name TIMEGROUP_MEMBER dac_dat\[1\] -section_id "serial DAC data&cs"
	set_global_assignment -name TIMEGROUP_MEMBER dac_dat\[2\] -section_id "serial DAC data&cs"
	set_global_assignment -name TIMEGROUP_MEMBER dac_dat\[3\] -section_id "serial DAC data&cs"
	set_global_assignment -name TIMEGROUP_MEMBER dac_dat\[4\] -section_id "serial DAC data&cs"
	set_global_assignment -name TIMEGROUP_MEMBER dac_dat\[5\] -section_id "serial DAC data&cs"
	set_global_assignment -name TIMEGROUP_MEMBER dac_dat\[6\] -section_id "serial DAC data&cs"
	set_global_assignment -name TIMEGROUP_MEMBER dac_dat\[7\] -section_id "serial DAC data&cs"
	set_global_assignment -name TIMEGROUP_MEMBER bias_dac_ncs\[0\] -section_id "serial DAC data&cs"
	set_global_assignment -name TIMEGROUP_MEMBER bias_dac_ncs\[1\] -section_id "serial DAC data&cs"
	set_global_assignment -name TIMEGROUP_MEMBER bias_dac_ncs\[2\] -section_id "serial DAC data&cs"
	set_global_assignment -name TIMEGROUP_MEMBER bias_dac_ncs\[3\] -section_id "serial DAC data&cs"
	set_global_assignment -name TIMEGROUP_MEMBER bias_dac_ncs\[4\] -section_id "serial DAC data&cs"
	set_global_assignment -name TIMEGROUP_MEMBER bias_dac_ncs\[5\] -section_id "serial DAC data&cs"
	set_global_assignment -name TIMEGROUP_MEMBER bias_dac_ncs\[6\] -section_id "serial DAC data&cs"
	set_global_assignment -name TIMEGROUP_MEMBER bias_dac_ncs\[7\] -section_id "serial DAC data&cs"
	set_global_assignment -name TIMEGROUP_MEMBER offset_dac_ncs\[0\] -section_id "serial DAC data&cs"
	set_global_assignment -name TIMEGROUP_MEMBER offset_dac_ncs\[1\] -section_id "serial DAC data&cs"
	set_global_assignment -name TIMEGROUP_MEMBER offset_dac_ncs\[2\] -section_id "serial DAC data&cs"
	set_global_assignment -name TIMEGROUP_MEMBER offset_dac_ncs\[3\] -section_id "serial DAC data&cs"
	set_global_assignment -name TIMEGROUP_MEMBER offset_dac_ncs\[4\] -section_id "serial DAC data&cs"
	set_global_assignment -name TIMEGROUP_MEMBER offset_dac_ncs\[5\] -section_id "serial DAC data&cs"
	set_global_assignment -name TIMEGROUP_MEMBER offset_dac_ncs\[6\] -section_id "serial DAC data&cs"
	set_global_assignment -name TIMEGROUP_MEMBER offset_dac_ncs\[7\] -section_id "serial DAC data&cs"
	set_location_assignment PIN_H20 -to red_led
	set_location_assignment PIN_H19 -to ylw_led
	set_location_assignment PIN_J20 -to grn_led
	set_location_assignment PIN_K10 -to dip_sw3
	set_location_assignment PIN_L11 -to dip_sw4
	set_location_assignment PIN_A5 -to wdog
	set_location_assignment PIN_D5 -to slot_id\[0\]
	set_location_assignment PIN_B6 -to slot_id\[1\]
	set_location_assignment PIN_C9 -to slot_id\[2\]
	set_location_assignment PIN_D10 -to slot_id\[3\]
	set_location_assignment PIN_A16 -to card_id
	set_location_assignment PIN_G7 -to ttl_dir\[1\]
	set_location_assignment PIN_F7 -to ttl_in\[1\]
	set_location_assignment PIN_F11 -to ttl_out\[1\]
	set_location_assignment PIN_G9 -to ttl_dir\[2\]
	set_location_assignment PIN_F8 -to ttl_in\[2\]
	set_location_assignment PIN_G8 -to ttl_out\[2\]
	set_location_assignment PIN_H9 -to ttl_dir\[3\]
	set_location_assignment PIN_F9 -to ttl_in\[3\]
	set_location_assignment PIN_G12 -to ttl_out\[3\]
	set_location_assignment PIN_K17 -to inclk
	set_location_assignment PIN_E15 -to pll5_out\[0\]
	set_location_assignment PIN_K14 -to pll5_out\[1\]
	set_location_assignment PIN_C15 -to pll5_out\[2\]
	set_location_assignment PIN_K16 -to pll5_out\[3\]
	set_location_assignment PIN_AC17 -to pll6_in
	set_location_assignment PIN_AD15 -to pll6_out\[0\]
	set_location_assignment PIN_W14 -to pll6_out\[1\]
	set_location_assignment PIN_AF15 -to pll6_out\[2\]
	set_location_assignment PIN_W16 -to pll6_out\[3\]
	set_location_assignment PIN_F17 -to smb_clk
	set_location_assignment PIN_G22 -to smb_data
	set_location_assignment PIN_G21 -to smb_nalert
	set_location_assignment PIN_F20 -to rs232_rx
	set_location_assignment PIN_F18 -to eeprom_so
	set_location_assignment PIN_F21 -to rs232_tx
	set_location_assignment PIN_F22 -to eeprom_cs
	set_location_assignment PIN_C21 -to sram_addr\[0\]
	set_location_assignment PIN_D21 -to sram_addr\[1\]
	set_location_assignment PIN_E21 -to sram_addr\[2\]
	set_location_assignment PIN_B22 -to sram_addr\[3\]
	set_location_assignment PIN_A22 -to sram_addr\[4\]
	set_location_assignment PIN_C22 -to sram_addr\[5\]
	set_location_assignment PIN_D22 -to sram_addr\[6\]
	set_location_assignment PIN_A23 -to sram_addr\[7\]
	set_location_assignment PIN_C23 -to sram_addr\[8\]
	set_location_assignment PIN_E23 -to sram_addr\[9\]
	set_location_assignment PIN_B23 -to sram_addr\[10\]
	set_location_assignment PIN_A24 -to sram_addr\[11\]
	set_location_assignment PIN_C25 -to sram_addr\[12\]
	set_location_assignment PIN_A25 -to sram_addr\[13\]
	set_location_assignment PIN_D24 -to sram_addr\[14\]
	set_location_assignment PIN_B24 -to sram_addr\[15\]
	set_location_assignment PIN_B25 -to sram_addr\[16\]
	set_location_assignment PIN_A26 -to sram_addr\[17\]
	set_location_assignment PIN_B26 -to sram_addr\[18\]
	set_location_assignment PIN_D23 -to sram_addr\[19\]
	set_location_assignment PIN_D16 -to sram_data\[0\]
	set_location_assignment PIN_C16 -to sram_data\[1\]
	set_location_assignment PIN_E16 -to sram_data\[2\]
	set_location_assignment PIN_B16 -to sram_data\[3\]
	set_location_assignment PIN_E17 -to sram_data\[4\]
	set_location_assignment PIN_D17 -to sram_data\[5\]
	set_location_assignment PIN_B17 -to sram_data\[6\]
	set_location_assignment PIN_C17 -to sram_data\[7\]
	set_location_assignment PIN_A18 -to sram_data\[8\]
	set_location_assignment PIN_C18 -to sram_data\[9\]
	set_location_assignment PIN_D18 -to sram_data\[10\]
	set_location_assignment PIN_A19 -to sram_data\[11\]
	set_location_assignment PIN_B19 -to sram_data\[12\]
	set_location_assignment PIN_C19 -to sram_data\[13\]
	set_location_assignment PIN_E19 -to sram_data\[14\]
	set_location_assignment PIN_D19 -to sram_data\[15\]
	set_location_assignment PIN_B20 -to sram_nbhe
	set_location_assignment PIN_A20 -to sram_nble
	set_location_assignment PIN_C20 -to sram_noe
	set_location_assignment PIN_A21 -to sram_nwe
	set_location_assignment PIN_B21 -to sram_ncs
	set_location_assignment PIN_A4 -to lvds_txa
	set_location_assignment PIN_A3 -to lvds_txb
	set_location_assignment PIN_B3 -to lvds_sync
	set_location_assignment PIN_B4 -to lvds_spare
	set_location_assignment PIN_B5 -to lvds_cmd
	set_location_assignment PIN_J10 -to n7Vok
	set_location_assignment PIN_J9 -to minus7Vok
	set_location_assignment PIN_H10 -to n15Vok
	set_location_assignment PIN_A11 -to mictor\[0\]
	set_location_assignment PIN_B11 -to mictor\[1\]
	set_location_assignment PIN_C11 -to mictor\[2\]
	set_location_assignment PIN_A10 -to mictor\[3\]
	set_location_assignment PIN_B10 -to mictor\[4\]
	set_location_assignment PIN_C12 -to mictor\[5\]
	set_location_assignment PIN_B12 -to mictor\[6\]
	set_location_assignment PIN_C13 -to mictor\[7\]
	set_location_assignment PIN_B13 -to mictor\[8\]
	set_location_assignment PIN_C10 -to mictor\[9\]
	set_location_assignment PIN_D11 -to mictor\[10\]
	set_location_assignment PIN_D13 -to mictor\[11\]
	set_location_assignment PIN_E13 -to mictor\[12\]
	set_location_assignment PIN_D12 -to mictor\[13\]
	set_location_assignment PIN_E12 -to mictor\[14\]
	set_location_assignment PIN_E10 -to mictor\[15\]
	set_location_assignment PIN_A9 -to mictor\[16\]
	set_location_assignment PIN_B9 -to mictor\[17\]
	set_location_assignment PIN_B8 -to mictor\[18\]
	set_location_assignment PIN_A8 -to mictor\[19\]
	set_location_assignment PIN_C8 -to mictor\[20\]
	set_location_assignment PIN_D8 -to mictor\[21\]
	set_location_assignment PIN_A7 -to mictor\[22\]
	set_location_assignment PIN_B7 -to mictor\[23\]
	set_location_assignment PIN_C7 -to mictor\[24\]
	set_location_assignment PIN_A6 -to mictor\[25\]
	set_location_assignment PIN_C6 -to mictor\[26\]
	set_location_assignment PIN_D6 -to mictor\[27\]
	set_location_assignment PIN_D9 -to mictor\[28\]
	set_location_assignment PIN_D7 -to mictor\[29\]
	set_location_assignment PIN_E8 -to mictor\[30\]
	set_location_assignment PIN_E6 -to mictor\[31\]
	set_location_assignment PIN_AE8 -to dac_clk\[0\]
	set_location_assignment PIN_Y10 -to dac_clk\[1\]
	set_location_assignment PIN_AB7 -to dac_clk\[2\]
	set_location_assignment PIN_AC5 -to dac_clk\[3\]
	set_location_assignment PIN_AG20 -to dac_clk\[4\]
	set_location_assignment PIN_AB22 -to dac_clk\[5\]
	set_location_assignment PIN_AB20 -to dac_clk\[6\]
	set_location_assignment PIN_AB18 -to dac_clk\[7\]
	set_location_assignment PIN_AG10 -to dac_dat\[0\]
	set_location_assignment PIN_Y11 -to dac_dat\[1\]
	set_location_assignment PIN_AB8 -to dac_dat\[2\]
	set_location_assignment PIN_AC6 -to dac_dat\[3\]
	set_location_assignment PIN_AE23 -to dac_dat\[4\]
	set_location_assignment PIN_AE25 -to dac_dat\[5\]
	set_location_assignment PIN_Y20 -to dac_dat\[6\]
	set_location_assignment PIN_V18 -to dac_dat\[7\]
	set_location_assignment PIN_AH3 -to bias_dac_ncs\[0\]
	set_location_assignment PIN_V11 -to bias_dac_ncs\[1\]
	set_location_assignment PIN_AA9 -to bias_dac_ncs\[2\]
	set_location_assignment PIN_AB9 -to bias_dac_ncs\[3\]
	set_location_assignment PIN_AH16 -to bias_dac_ncs\[4\]
	set_location_assignment PIN_AC24 -to bias_dac_ncs\[5\]
	set_location_assignment PIN_AD24 -to bias_dac_ncs\[6\]
	set_location_assignment PIN_AC22 -to bias_dac_ncs\[7\]
	set_location_assignment PIN_Y9 -to offset_dac_ncs\[1\]
	set_location_assignment PIN_AA10 -to offset_dac_ncs\[2\]
	set_location_assignment PIN_AB12 -to offset_dac_ncs\[3\]
	set_location_assignment PIN_AF18 -to offset_dac_ncs\[4\]
	set_location_assignment PIN_AC23 -to offset_dac_ncs\[5\]
	set_location_assignment PIN_AB21 -to offset_dac_ncs\[6\]
	set_location_assignment PIN_AC20 -to offset_dac_ncs\[7\]
	set_location_assignment PIN_N10 -to dac_FB_clk\[0\]
	set_location_assignment PIN_N9 -to dac_FB1_dat\[0\]
	set_location_assignment PIN_M3 -to dac_FB1_dat\[1\]
	set_location_assignment PIN_M4 -to dac_FB1_dat\[2\]
	set_location_assignment PIN_N5 -to dac_FB1_dat\[3\]
	set_location_assignment PIN_N6 -to dac_FB1_dat\[4\]
	set_location_assignment PIN_L1 -to dac_FB1_dat\[5\]
	set_location_assignment PIN_L2 -to dac_FB1_dat\[6\]
	set_location_assignment PIN_N7 -to dac_FB1_dat\[7\]
	set_location_assignment PIN_N8 -to dac_FB1_dat\[8\]
	set_location_assignment PIN_L3 -to dac_FB1_dat\[9\]
	set_location_assignment PIN_L4 -to dac_FB1_dat\[10\]
	set_location_assignment PIN_N4 -to dac_FB1_dat\[11\]
	set_location_assignment PIN_N3 -to dac_FB1_dat\[12\]
	set_location_assignment PIN_K1 -to dac_FB1_dat\[13\]
	set_location_assignment PIN_C2 -to dac_FB_clk\[1\]
	set_location_assignment PIN_C1 -to dac_FB2_dat\[0\]
	set_location_assignment PIN_H5 -to dac_FB2_dat\[1\]
	set_location_assignment PIN_H6 -to dac_FB2_dat\[2\]
	set_location_assignment PIN_D2 -to dac_FB2_dat\[3\]
	set_location_assignment PIN_D1 -to dac_FB2_dat\[4\]
	set_location_assignment PIN_H7 -to dac_FB2_dat\[5\]
	set_location_assignment PIN_H8 -to dac_FB2_dat\[6\]
	set_location_assignment PIN_E2 -to dac_FB2_dat\[7\]
	set_location_assignment PIN_E1 -to dac_FB2_dat\[8\]
	set_location_assignment PIN_J5 -to dac_FB2_dat\[9\]
	set_location_assignment PIN_J6 -to dac_FB2_dat\[10\]
	set_location_assignment PIN_F4 -to dac_FB2_dat\[11\]
	set_location_assignment PIN_F3 -to dac_FB2_dat\[12\]
	set_location_assignment PIN_K6 -to dac_FB2_dat\[13\]
	set_location_assignment PIN_F2 -to dac_FB_clk\[2\]
	set_location_assignment PIN_F1 -to dac_FB3_dat\[0\]
	set_location_assignment PIN_J8 -to dac_FB3_dat\[1\]
	set_location_assignment PIN_J7 -to dac_FB3_dat\[2\]
	set_location_assignment PIN_G3 -to dac_FB3_dat\[3\]
	set_location_assignment PIN_G4 -to dac_FB3_dat\[4\]
	set_location_assignment PIN_K8 -to dac_FB3_dat\[5\]
	set_location_assignment PIN_K7 -to dac_FB3_dat\[6\]
	set_location_assignment PIN_G2 -to dac_FB3_dat\[7\]
	set_location_assignment PIN_G1 -to dac_FB3_dat\[8\]
	set_location_assignment PIN_L7 -to dac_FB3_dat\[9\]
	set_location_assignment PIN_L8 -to dac_FB3_dat\[10\]
	set_location_assignment PIN_H4 -to dac_FB3_dat\[11\]
	set_location_assignment PIN_H3 -to dac_FB3_dat\[12\]
	set_location_assignment PIN_L6 -to dac_FB3_dat\[13\]
	set_location_assignment PIN_M10 -to dac_FB_clk\[3\]
	set_location_assignment PIN_M9 -to dac_FB4_dat\[0\]
	set_location_assignment PIN_K4 -to dac_FB4_dat\[1\]
	set_location_assignment PIN_K3 -to dac_FB4_dat\[2\]
	set_location_assignment PIN_M6 -to dac_FB4_dat\[3\]
	set_location_assignment PIN_M5 -to dac_FB4_dat\[4\]
	set_location_assignment PIN_J1 -to dac_FB4_dat\[5\]
	set_location_assignment PIN_J2 -to dac_FB4_dat\[6\]
	set_location_assignment PIN_M8 -to dac_FB4_dat\[7\]
	set_location_assignment PIN_M7 -to dac_FB4_dat\[8\]
	set_location_assignment PIN_J3 -to dac_FB4_dat\[9\]
	set_location_assignment PIN_J4 -to dac_FB4_dat\[10\]
	set_location_assignment PIN_L10 -to dac_FB4_dat\[11\]
	set_location_assignment PIN_L9 -to dac_FB4_dat\[12\]
	set_location_assignment PIN_H1 -to dac_FB4_dat\[13\]
	set_location_assignment PIN_AG12 -to dac_FB_clk\[4\]
	set_location_assignment PIN_AF12 -to dac_FB5_dat\[0\]
	set_location_assignment PIN_AE12 -to dac_FB5_dat\[1\]
	set_location_assignment PIN_AG13 -to dac_FB5_dat\[2\]
	set_location_assignment PIN_AD12 -to dac_FB5_dat\[3\]
	set_location_assignment PIN_AF13 -to dac_FB5_dat\[4\]
	set_location_assignment PIN_AE13 -to dac_FB5_dat\[5\]
	set_location_assignment PIN_AD13 -to dac_FB5_dat\[6\]
	set_location_assignment PIN_AE16 -to dac_FB5_dat\[7\]
	set_location_assignment PIN_AF16 -to dac_FB5_dat\[8\]
	set_location_assignment PIN_AD16 -to dac_FB5_dat\[9\]
	set_location_assignment PIN_AG16 -to dac_FB5_dat\[10\]
	set_location_assignment PIN_AD17 -to dac_FB5_dat\[11\]
	set_location_assignment PIN_AE17 -to dac_FB5_dat\[12\]
	set_location_assignment PIN_AG17 -to dac_FB5_dat\[13\]
	set_location_assignment PIN_AH4 -to dac_FB_clk\[5\]
	set_location_assignment PIN_AE5 -to dac_FB6_dat\[0\]
	set_location_assignment PIN_AG3 -to dac_FB6_dat\[1\]
	set_location_assignment PIN_AG5 -to dac_FB6_dat\[2\]
	set_location_assignment PIN_AG4 -to dac_FB6_dat\[3\]
	set_location_assignment PIN_AF4 -to dac_FB6_dat\[4\]
	set_location_assignment PIN_AH5 -to dac_FB6_dat\[5\]
	set_location_assignment PIN_AF5 -to dac_FB6_dat\[6\]
	set_location_assignment PIN_AE6 -to dac_FB6_dat\[7\]
	set_location_assignment PIN_AG6 -to dac_FB6_dat\[8\]
	set_location_assignment PIN_AH6 -to dac_FB6_dat\[9\]
	set_location_assignment PIN_AD6 -to dac_FB6_dat\[10\]
	set_location_assignment PIN_AF7 -to dac_FB6_dat\[11\]
	set_location_assignment PIN_AH7 -to dac_FB6_dat\[12\]
	set_location_assignment PIN_AG7 -to dac_FB6_dat\[13\]
	set_location_assignment PIN_AG18 -to dac_FB_clk\[6\]
	set_location_assignment PIN_AE18 -to dac_FB7_dat\[0\]
	set_location_assignment PIN_AD18 -to dac_FB7_dat\[1\]
	set_location_assignment PIN_AH19 -to dac_FB7_dat\[2\]
	set_location_assignment PIN_AG19 -to dac_FB7_dat\[3\]
	set_location_assignment PIN_AF19 -to dac_FB7_dat\[4\]
	set_location_assignment PIN_AD19 -to dac_FB7_dat\[5\]
	set_location_assignment PIN_AE19 -to dac_FB7_dat\[6\]
	set_location_assignment PIN_AH20 -to dac_FB7_dat\[7\]
	set_location_assignment PIN_AH21 -to dac_FB7_dat\[8\]
	set_location_assignment PIN_AF20 -to dac_FB7_dat\[9\]
	set_location_assignment PIN_AE20 -to dac_FB7_dat\[10\]
	set_location_assignment PIN_AF21 -to dac_FB7_dat\[11\]
	set_location_assignment PIN_AG21 -to dac_FB7_dat\[12\]
	set_location_assignment PIN_AE21 -to dac_FB7_dat\[13\]
	set_location_assignment PIN_AG8 -to dac_FB_clk\[7\]
	set_location_assignment PIN_AF8 -to dac_FB8_dat\[0\]
	set_location_assignment PIN_AD8 -to dac_FB8_dat\[1\]
	set_location_assignment PIN_AH9 -to dac_FB8_dat\[2\]
	set_location_assignment PIN_AH8 -to dac_FB8_dat\[3\]
	set_location_assignment PIN_AE9 -to dac_FB8_dat\[4\]
	set_location_assignment PIN_AF9 -to dac_FB8_dat\[5\]
	set_location_assignment PIN_AG9 -to dac_FB8_dat\[6\]
	set_location_assignment PIN_AD10 -to dac_FB8_dat\[7\]
	set_location_assignment PIN_AF10 -to dac_FB8_dat\[8\]
	set_location_assignment PIN_AH10 -to dac_FB8_dat\[9\]
	set_location_assignment PIN_AE10 -to dac_FB8_dat\[10\]
	set_location_assignment PIN_AF11 -to dac_FB8_dat\[11\]
	set_location_assignment PIN_AE11 -to dac_FB8_dat\[12\]
	set_location_assignment PIN_AH11 -to dac_FB8_dat\[13\]
	set_location_assignment PIN_AB6 -to adc1_clk
	set_location_assignment PIN_W22 -to adc1_rdy
	set_location_assignment PIN_AG22 -to adc1_ovr
	set_location_assignment PIN_AB26 -to adc1_dat\[0\]
	set_location_assignment PIN_AB25 -to adc1_dat\[1\]
	set_location_assignment PIN_W23 -to adc1_dat\[2\]
	set_location_assignment PIN_W24 -to adc1_dat\[3\]
	set_location_assignment PIN_AB28 -to adc1_dat\[4\]
	set_location_assignment PIN_AB27 -to adc1_dat\[5\]
	set_location_assignment PIN_V22 -to adc1_dat\[6\]
	set_location_assignment PIN_V21 -to adc1_dat\[7\]
	set_location_assignment PIN_AA25 -to adc1_dat\[8\]
	set_location_assignment PIN_AA26 -to adc1_dat\[9\]
	set_location_assignment PIN_V24 -to adc1_dat\[10\]
	set_location_assignment PIN_V23 -to adc1_dat\[11\]
	set_location_assignment PIN_AA28 -to adc1_dat\[12\]
	set_location_assignment PIN_AA27 -to adc1_dat\[13\]
	set_location_assignment PIN_AA8 -to adc2_clk
	set_location_assignment PIN_AH22 -to adc2_rdy
	set_location_assignment PIN_N20 -to adc2_ovr
	set_location_assignment PIN_AF22 -to adc2_dat\[0\]
	set_location_assignment PIN_AE22 -to adc2_dat\[1\]
	set_location_assignment PIN_AH23 -to adc2_dat\[2\]
	set_location_assignment PIN_AF23 -to adc2_dat\[3\]
	set_location_assignment PIN_AD23 -to adc2_dat\[4\]
	set_location_assignment PIN_AG23 -to adc2_dat\[5\]
	set_location_assignment PIN_AH24 -to adc2_dat\[6\]
	set_location_assignment PIN_AE24 -to adc2_dat\[7\]
	set_location_assignment PIN_AG24 -to adc2_dat\[8\]
	set_location_assignment PIN_AF25 -to adc2_dat\[9\]
	set_location_assignment PIN_AH25 -to adc2_dat\[10\]
	set_location_assignment PIN_AG25 -to adc2_dat\[11\]
	set_location_assignment PIN_AH26 -to adc2_dat\[12\]
	set_location_assignment PIN_AG26 -to adc2_dat\[13\]
	set_location_assignment PIN_AA6 -to adc3_clk
	set_location_assignment PIN_N19 -to adc3_rdy
	set_location_assignment PIN_AA21 -to adc3_ovr
	set_location_assignment PIN_M25 -to adc3_dat\[0\]
	set_location_assignment PIN_M26 -to adc3_dat\[1\]
	set_location_assignment PIN_N22 -to adc3_dat\[2\]
	set_location_assignment PIN_N21 -to adc3_dat\[3\]
	set_location_assignment PIN_L27 -to adc3_dat\[4\]
	set_location_assignment PIN_L28 -to adc3_dat\[5\]
	set_location_assignment PIN_N24 -to adc3_dat\[6\]
	set_location_assignment PIN_N23 -to adc3_dat\[7\]
	set_location_assignment PIN_L25 -to adc3_dat\[8\]
	set_location_assignment PIN_L26 -to adc3_dat\[9\]
	set_location_assignment PIN_N26 -to adc3_dat\[10\]
	set_location_assignment PIN_N25 -to adc3_dat\[11\]
	set_location_assignment PIN_K27 -to adc3_dat\[12\]
	set_location_assignment PIN_K28 -to adc3_dat\[13\]
	set_location_assignment PIN_Y5 -to adc4_clk
	set_location_assignment PIN_AA22 -to adc4_rdy
	set_location_assignment PIN_W27 -to adc4_ovr
	set_location_assignment PIN_AF28 -to adc4_dat\[0\]
	set_location_assignment PIN_AF27 -to adc4_dat\[1\]
	set_location_assignment PIN_AA23 -to adc4_dat\[2\]
	set_location_assignment PIN_AA24 -to adc4_dat\[3\]
	set_location_assignment PIN_AE28 -to adc4_dat\[4\]
	set_location_assignment PIN_AE27 -to adc4_dat\[5\]
	set_location_assignment PIN_Y24 -to adc4_dat\[6\]
	set_location_assignment PIN_Y23 -to adc4_dat\[7\]
	set_location_assignment PIN_AD28 -to adc4_dat\[8\]
	set_location_assignment PIN_AD27 -to adc4_dat\[9\]
	set_location_assignment PIN_Y21 -to adc4_dat\[10\]
	set_location_assignment PIN_Y22 -to adc4_dat\[11\]
	set_location_assignment PIN_AC28 -to adc4_dat\[12\]
	set_location_assignment PIN_AC27 -to adc4_dat\[13\]
	set_location_assignment PIN_Y8 -to adc5_clk
	set_location_assignment PIN_W28 -to adc5_rdy
	set_location_assignment PIN_M20 -to adc5_ovr
	set_location_assignment PIN_U20 -to adc5_dat\[0\]
	set_location_assignment PIN_U19 -to adc5_dat\[1\]
	set_location_assignment PIN_W25 -to adc5_dat\[2\]
	set_location_assignment PIN_W26 -to adc5_dat\[3\]
	set_location_assignment PIN_U23 -to adc5_dat\[4\]
	set_location_assignment PIN_U24 -to adc5_dat\[5\]
	set_location_assignment PIN_Y27 -to adc5_dat\[6\]
	set_location_assignment PIN_Y28 -to adc5_dat\[7\]
	set_location_assignment PIN_U22 -to adc5_dat\[8\]
	set_location_assignment PIN_U21 -to adc5_dat\[9\]
	set_location_assignment PIN_Y25 -to adc5_dat\[10\]
	set_location_assignment PIN_Y26 -to adc5_dat\[11\]
	set_location_assignment PIN_V20 -to adc5_dat\[12\]
	set_location_assignment PIN_V19 -to adc5_dat\[13\]
	set_location_assignment PIN_V10 -to adc6_clk
	set_location_assignment PIN_M19 -to adc6_rdy
	set_location_assignment PIN_F28 -to adc6_ovr
	set_location_assignment PIN_K26 -to adc6_dat\[0\]
	set_location_assignment PIN_K25 -to adc6_dat\[1\]
	set_location_assignment PIN_M24 -to adc6_dat\[2\]
	set_location_assignment PIN_M23 -to adc6_dat\[3\]
	set_location_assignment PIN_J27 -to adc6_dat\[4\]
	set_location_assignment PIN_J28 -to adc6_dat\[5\]
	set_location_assignment PIN_M22 -to adc6_dat\[6\]
	set_location_assignment PIN_M21 -to adc6_dat\[7\]
	set_location_assignment PIN_J25 -to adc6_dat\[8\]
	set_location_assignment PIN_J26 -to adc6_dat\[9\]
	set_location_assignment PIN_L20 -to adc6_dat\[10\]
	set_location_assignment PIN_L19 -to adc6_dat\[11\]
	set_location_assignment PIN_H27 -to adc6_dat\[12\]
	set_location_assignment PIN_H28 -to adc6_dat\[13\]
	set_location_assignment PIN_U8 -to adc7_clk
	set_location_assignment PIN_F27 -to adc7_rdy
	set_location_assignment PIN_C28 -to adc7_ovr
	set_location_assignment PIN_J22 -to adc7_dat\[0\]
	set_location_assignment PIN_J21 -to adc7_dat\[1\]
	set_location_assignment PIN_G25 -to adc7_dat\[2\]
	set_location_assignment PIN_G26 -to adc7_dat\[3\]
	set_location_assignment PIN_K22 -to adc7_dat\[4\]
	set_location_assignment PIN_K21 -to adc7_dat\[5\]
	set_location_assignment PIN_G28 -to adc7_dat\[6\]
	set_location_assignment PIN_G27 -to adc7_dat\[7\]
	set_location_assignment PIN_L21 -to adc7_dat\[8\]
	set_location_assignment PIN_L22 -to adc7_dat\[9\]
	set_location_assignment PIN_H25 -to adc7_dat\[10\]
	set_location_assignment PIN_H26 -to adc7_dat\[11\]
	set_location_assignment PIN_L24 -to adc7_dat\[12\]
	set_location_assignment PIN_L23 -to adc7_dat\[13\]
	set_location_assignment PIN_U5 -to adc8_clk
	set_location_assignment PIN_C27 -to adc8_rdy
	set_location_assignment PIN_W21 -to adc8_ovr
	set_location_assignment PIN_H23 -to adc8_dat\[0\]
	set_location_assignment PIN_H24 -to adc8_dat\[1\]
	set_location_assignment PIN_D28 -to adc8_dat\[2\]
	set_location_assignment PIN_D27 -to adc8_dat\[3\]
	set_location_assignment PIN_H21 -to adc8_dat\[4\]
	set_location_assignment PIN_H22 -to adc8_dat\[5\]
	set_location_assignment PIN_E28 -to adc8_dat\[6\]
	set_location_assignment PIN_E27 -to adc8_dat\[7\]
	set_location_assignment PIN_J23 -to adc8_dat\[8\]
	set_location_assignment PIN_J24 -to adc8_dat\[9\]
	set_location_assignment PIN_F26 -to adc8_dat\[10\]
	set_location_assignment PIN_F25 -to adc8_dat\[11\]
	set_location_assignment PIN_K24 -to adc8_dat\[12\]
	set_location_assignment PIN_K23 -to adc8_dat\[13\]
	set_location_assignment PIN_AC9 -to rst_n
	set_location_assignment PIN_AE7 -to offset_dac_ncs\[0\]
	set_instance_assignment -name GLOBAL_SIGNAL ON -to "dispatch:i_dispatch\|dispatch_wishbone:wishbone\|tga_o"
	set_instance_assignment -name CLOCK_SETTINGS inclk -to inclk
	set_instance_assignment -name OUTPUT_MAX_DELAY 0ns -from "rc_pll:i_rc_pll\|altpll:altpll_component\|_clk0" -to "ADC Outputs"
	set_instance_assignment -name SETUP_RELATIONSHIP 10ns -from "frame_timing:i_frame_timing\|frame_timing_wbs:wbi\|reg*" -to "flux_loop:i_flux_loop\|*"
	set_instance_assignment -name SETUP_RELATIONSHIP 10ns -from "frame_timing:i_frame_timing\|frame_timing_wbs:wbi\|reg*" -to "frame_timing:i_frame_timing\|frame_timing_core:ftc\|*"
	set_instance_assignment -name SETUP_RELATIONSHIP 10ns -from "dispatch:i_dispatch\|dispatch_data_buf:receive_buf\|*" -to "flux_loop:i_flux_loop\|wbs_fb_data:i_wbs_fb_data\|*"
	set_instance_assignment -name SETUP_RELATIONSHIP 10ns -from "dispatch:i_dispatch\|dispatch_data_buf:receive_buf\|*" -to "flux_loop:i_flux_loop\|wbs_frame_data:i_wbs_frame_data\|*"
	set_instance_assignment -name SETUP_RELATIONSHIP 10ns -from "dispatch:i_dispatch\|dispatch_data_buf:transmit_buf\|*" -to "dispatch:i_dispatch\|dispatch_reply_transmit:transmitter\|shift_reg:crc_data_reg\|*"
	set_instance_assignment -name SETUP_RELATIONSHIP 10ns -from "dispatch:i_dispatch\|dispatch_data_buf:receive_buf\|*" -to "leds:i_LED\|led_data*"
	set_instance_assignment -name SETUP_RELATIONSHIP 10ns -from "dispatch:i_dispatch\|dispatch_wishbone:wishbone\|pres_state*" -to "dispatch:i_dispatch\|dispatch_data_buf:transmit_buf\|*"
	set_instance_assignment -name SETUP_RELATIONSHIP 10ns -from "dispatch:i_dispatch\|dispatch_reply_transmit:transmitter\|crc:crc_calc\|*" -to "dispatch:i_dispatch\|dispatch_reply_transmit:transmitter\|lvds_tx:reply_tx\|fifo:tx_buffer\|*"
	set_instance_assignment -name SETUP_RELATIONSHIP 10ns -from "dispatch:i_dispatch\|dispatch_reply_transmit:transmitter\|reg:data_size_reg\|reg_o*" -to "dispatch:i_dispatch\|dispatch_reply_transmit:transmitter\|lvds_tx:reply_tx\|fifo:tx_buffer\|*"
	set_instance_assignment -name SETUP_RELATIONSHIP 10ns -from "dispatch:i_dispatch\|dispatch_reply_transmit:transmitter\|tx_pres_state*" -to "dispatch:i_dispatch\|dispatch_reply_transmit:transmitter\|lvds_tx:reply_tx\|fifo:tx_buffer\|*"
	set_instance_assignment -name SETUP_RELATIONSHIP 10ns -from "dispatch:i_dispatch\|dispatch_wishbone:wishbone\|counter:addr_gen\|*" -to "dispatch:i_dispatch\|dispatch_data_buf:transmit_buf\|*"
	set_instance_assignment -name SETUP_RELATIONSHIP 10ns -from "dispatch:i_dispatch\|reg:cmd0\|reg_o*" -to "dispatch:i_dispatch\|dispatch_data_buf:transmit_buf\|*"
	set_instance_assignment -name SETUP_RELATIONSHIP 10ns -from "dispatch:i_dispatch\|reg:cmd1\|reg_o*" -to "dispatch:i_dispatch\|dispatch_data_buf:transmit_buf\|*"
	set_instance_assignment -name SETUP_RELATIONSHIP 10ns -from "flux_loop:i_flux_loop\|*" -to "dispatch:i_dispatch\|dispatch_data_buf:transmit_buf\|*"
	set_instance_assignment -name SETUP_RELATIONSHIP 10ns -from "leds:i_LED\|led_data*" -to "dispatch:i_dispatch\|dispatch_data_buf:transmit_buf\|*"
	set_instance_assignment -name SETUP_RELATIONSHIP 10ns -from "dispatch:i_dispatch\|dispatch_data_buf:receive_buf\|*" -to "frame_timing:i_frame_timing\|frame_timing_wbs:wbi\|reg*"
	set_instance_assignment -name SETUP_RELATIONSHIP 10ns -from "frame_timing:i_frame_timing\|frame_timing_wbs:wbi\|reg*" -to "dispatch:i_dispatch\|dispatch_data_buf:transmit_buf\|*"
	set_instance_assignment -name SETUP_RELATIONSHIP 10ns -from "dispatch:i_dispatch\|dispatch_reply_transmit:transmitter\|counter:word_counter\|*" -to "dispatch:i_dispatch\|dispatch_data_buf:transmit_buf\|*"
	set_instance_assignment -name SETUP_RELATIONSHIP 10ns -from "leds:i_LED\|pres_state*" -to "dispatch:i_dispatch\|dispatch_data_buf:transmit_buf\|*"
	set_instance_assignment -name SETUP_RELATIONSHIP 10ns -from "dispatch:i_dispatch\|dispatch_cmd_receive:receiver\|shift_reg:crc_data_reg\|*" -to "dispatch:i_dispatch\|dispatch_data_buf:receive_buf\|*"
	set_instance_assignment -name SETUP_RELATIONSHIP 10ns -from "dispatch:i_dispatch\|dispatch_cmd_receive:receiver\|rx_pres_state*" -to "dispatch:i_dispatch\|dispatch_data_buf:receive_buf\|*"
	set_instance_assignment -name INPUT_MAX_DELAY 11.7ns -from "rc_pll:i_rc_pll\|altpll:altpll_component\|_clk0" -to "ADC Inputs"
	set_instance_assignment -name INPUT_MIN_DELAY 3.7ns -from "rc_pll:i_rc_pll\|altpll:altpll_component\|_clk0" -to "ADC Inputs"
	set_instance_assignment -name OUTPUT_MIN_DELAY "-3.7ns" -from "rc_pll:i_rc_pll\|altpll:altpll_component\|_clk0" -to "ADC Outputs"
	set_instance_assignment -name MAX_FANOUT 100 -to *
	set_instance_assignment -name MAX_FANOUT 100 -to "dispatch:i_dispatch\|dispatch_wishbone:wishbone\|tga_o"
	set_instance_assignment -name IO_STANDARD LVDS -to adc1_clk
	set_instance_assignment -name IO_STANDARD LVTTL -to red_led
	set_instance_assignment -name IO_STANDARD LVDS -to adc2_clk
	set_instance_assignment -name IO_STANDARD LVDS -to adc3_clk
	set_instance_assignment -name IO_STANDARD LVDS -to adc4_clk
	set_instance_assignment -name IO_STANDARD LVDS -to adc5_clk
	set_instance_assignment -name IO_STANDARD LVDS -to adc6_clk
	set_instance_assignment -name IO_STANDARD LVDS -to adc7_clk
	set_instance_assignment -name IO_STANDARD LVDS -to adc8_clk

	# Including default assignments
	set_global_assignment -name PROJECT_SHOW_ENTITY_NAME ON
	set_global_assignment -name VER_COMPATIBLE_DB_DIR export_db
	set_global_assignment -name AUTO_EXPORT_VER_COMPATIBLE_DB OFF
	set_global_assignment -name DO_MIN_ANALYSIS ON
	set_global_assignment -name DO_MIN_TIMING OFF
	set_global_assignment -name REPORT_IO_PATHS_SEPARATELY OFF
	set_global_assignment -name CLOCK_ANALYSIS_ONLY OFF
	set_global_assignment -name CUT_OFF_PATHS_BETWEEN_CLOCK_DOMAINS ON
	set_global_assignment -name CUT_OFF_READ_DURING_WRITE_PATHS ON
	set_global_assignment -name CUT_OFF_CLEAR_AND_PRESET_PATHS ON
	set_global_assignment -name CUT_OFF_IO_PIN_FEEDBACK ON
	set_global_assignment -name IGNORE_CLOCK_SETTINGS OFF
	set_global_assignment -name INVERT_BASE_CLOCK OFF -section_id inclk
	set_global_assignment -name MULTIPLY_BASE_CLOCK_PERIOD_BY 1 -section_id inclk
	set_global_assignment -name DIVIDE_BASE_CLOCK_PERIOD_BY 1 -section_id inclk
	set_global_assignment -name ENABLE_IP_DEBUG OFF
	set_global_assignment -name SAVE_DISK_SPACE ON
	set_global_assignment -name DISABLE_OCP_HW_EVAL OFF
	set_global_assignment -name RECOMPILE_QUESTION YES
	set_global_assignment -name DEVICE_FILTER_PACKAGE ANY
	set_global_assignment -name DEVICE_FILTER_PIN_COUNT ANY
	set_global_assignment -name EDA_DESIGN_ENTRY_SYNTHESIS_TOOL "<None>"
	set_global_assignment -name VERILOG_INPUT_VERSION VERILOG_2001
	set_global_assignment -name VHDL_INPUT_VERSION VHDL93
	set_global_assignment -name COMPILATION_LEVEL FULL
	set_global_assignment -name TRUE_WYSIWYG_FLOW OFF
	set_global_assignment -name SMART_COMPILE_IGNORES_TDC_FOR_STRATIX_PLL_CHANGES OFF
	set_global_assignment -name DSP_BLOCK_BALANCING AUTO
	set_global_assignment -name NOT_GATE_PUSH_BACK ON
	set_global_assignment -name ALLOW_POWER_UP_DONT_CARE ON
	set_global_assignment -name REMOVE_DUPLICATE_REGISTERS ON
	set_global_assignment -name IGNORE_CARRY_BUFFERS OFF
	set_global_assignment -name IGNORE_CASCADE_BUFFERS OFF
	set_global_assignment -name IGNORE_GLOBAL_BUFFERS OFF
	set_global_assignment -name IGNORE_ROW_GLOBAL_BUFFERS OFF
	set_global_assignment -name IGNORE_LCELL_BUFFERS OFF
	set_global_assignment -name MAX7000_IGNORE_LCELL_BUFFERS AUTO
	set_global_assignment -name IGNORE_SOFT_BUFFERS ON
	set_global_assignment -name MAX7000_IGNORE_SOFT_BUFFERS OFF
	set_global_assignment -name LIMIT_AHDL_INTEGERS_TO_32_BITS OFF
	set_global_assignment -name USE_LPM_FOR_AHDL_OPERATORS ON
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
	set_global_assignment -name STRATIXII_OPTIMIZATION_TECHNIQUE BALANCED
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
	set_global_assignment -name AUTO_SHIFT_REGISTER_RECOGNITION ON
	set_global_assignment -name AUTO_CLOCK_ENABLE_RECOGNITION ON
	set_global_assignment -name SHOW_REGISTRATION_MESSAGE ON
	set_global_assignment -name ALLOW_SYNCH_CTRL_USAGE ON
	set_global_assignment -name AUTO_RAM_BLOCK_BALANCING ON
	set_global_assignment -name ESTIMATE_POWER_DURING_COMPILATION OFF
	set_global_assignment -name AUTO_RESOURCE_SHARING OFF
	set_global_assignment -name USE_NEW_TEXT_REPORT_TABLE_FORMAT OFF
	set_global_assignment -name ALLOW_ANY_RAM_SIZE_FOR_RECOGNITION OFF
	set_global_assignment -name ALLOW_ANY_ROM_SIZE_FOR_RECOGNITION OFF
	set_global_assignment -name ALLOW_ANY_SHIFT_REGISTER_SIZE_FOR_RECOGNITION OFF
	set_global_assignment -name MAX7000_FANIN_PER_CELL 100
	set_global_assignment -name IGNORE_DUPLICATE_DESIGN_ENTITY OFF
	set_global_assignment -name VHDL_VERILOG_BREAK_LOOPS OFF
	set_global_assignment -name TOP_LEVEL_ENTITY readout_card
	set_global_assignment -name EDA_DESIGN_ENTRY_SYNTHESIS_TOOL "<None>"
	set_global_assignment -name ECO_ALLOW_ROUTING_CHANGES OFF
	set_global_assignment -name BASE_PIN_OUT_FILE_ON_SAMEFRAME_DEVICE OFF
	set_global_assignment -name ENABLE_JTAG_BST_SUPPORT OFF
	set_global_assignment -name MAX7000_ENABLE_JTAG_BST_SUPPORT ON
	set_global_assignment -name RESERVE_NCEO_AFTER_CONFIGURATION "USE AS REGULAR IO"
	set_global_assignment -name CYCLONEII_RESERVE_NCEO_AFTER_CONFIGURATION "AS OUTPUT DRIVING GROUND"
	set_global_assignment -name STRATIX_UPDATE_MODE STANDARD
	set_global_assignment -name STRATIX_II_CONFIGURATION_SCHEME "PASSIVE SERIAL"
	set_global_assignment -name CYCLONEII_CONFIGURATION_SCHEME "ACTIVE SERIAL"
	set_global_assignment -name APEX20K_CONFIGURATION_SCHEME "PASSIVE SERIAL"
	set_global_assignment -name STRATIX_CONFIGURATION_SCHEME "PASSIVE SERIAL"
	set_global_assignment -name CYCLONE_CONFIGURATION_SCHEME "ACTIVE SERIAL"
	set_global_assignment -name EXCALIBUR_CONFIGURATION_SCHEME "PASSIVE SERIAL"
	set_global_assignment -name MERCURY_CONFIGURATION_SCHEME "PASSIVE SERIAL"
	set_global_assignment -name FLEX6K_CONFIGURATION_SCHEME "PASSIVE SERIAL"
	set_global_assignment -name FLEX10K_CONFIGURATION_SCHEME "PASSIVE SERIAL"
	set_global_assignment -name APEXII_CONFIGURATION_SCHEME "PASSIVE SERIAL"
	set_global_assignment -name USER_START_UP_CLOCK OFF
	set_global_assignment -name ENABLE_VREFA_PIN OFF
	set_global_assignment -name ENABLE_VREFB_PIN OFF
	set_global_assignment -name AUTO_RESTART_CONFIGURATION ON
	set_global_assignment -name RELEASE_CLEARS_BEFORE_TRI_STATES OFF
	set_global_assignment -name ENABLE_DEVICE_WIDE_OE OFF
	set_global_assignment -name FLEX10K_ENABLE_LOCK_OUTPUT OFF
	set_global_assignment -name ENABLE_INIT_DONE_OUTPUT OFF
	set_global_assignment -name RESERVE_NWS_NRS_NCS_CS_AFTER_CONFIGURATION "USE AS REGULAR IO"
	set_global_assignment -name RESERVE_RDYNBUSY_AFTER_CONFIGURATION "USE AS REGULAR IO"
	set_global_assignment -name RESERVE_DATA7_THROUGH_DATA1_AFTER_CONFIGURATION "USE AS REGULAR IO"
	set_global_assignment -name RESERVE_DATA0_AFTER_CONFIGURATION "AS INPUT TRI-STATED"
	set_global_assignment -name RESERVE_ASDO_AFTER_CONFIGURATION "USE AS REGULAR IO"
	set_global_assignment -name OPTIMIZE_HOLD_TIMING "IO PATHS AND MINIMUM TPD PATHS"
	set_global_assignment -name OPTIMIZE_TIMING "NORMAL COMPILATION"
	set_global_assignment -name OPTIMIZE_IOC_REGISTER_PLACEMENT_FOR_TIMING ON
	set_global_assignment -name DISABLE_PLL_COMPENSATION_DELAY_CHANGE_WARNING OFF
	set_global_assignment -name FIT_ONLY_ONE_ATTEMPT OFF
	set_global_assignment -name STRIPE_TO_PLD_BRIDGE_EPXA4_10 "MEGALAB COLUMN 1"
	set_global_assignment -name PROCESSOR_DEBUG_EXTENSIONS_EPXA4_10 "MEGALAB COLUMN 2"
	set_global_assignment -name PLD_TO_STRIPE_INTERRUPTS_EPXA4_10 "MEGALAB COLUMN 2"
	set_global_assignment -name STRIPE_TO_PLD_INTERRUPTS_EPXA4_10 "MEGALAB COLUMN 2"
	set_global_assignment -name DPRAM_INPUT_EPXA4_10 "DEFAULT INPUT ROUTING OPTIONS"
	set_global_assignment -name DPRAM_OUTPUT_EPXA4_10 "DEFAULT OUTPUT ROUTING OPTIONS"
	set_global_assignment -name DPRAM_OTHER_SIGNALS_EPXA4_10 "DEFAULT OTHER ROUTING OPTIONS"
	set_global_assignment -name DPRAM_DEEP_MODE_INPUT_EPXA4_10 "MEGALAB COLUMN 3"
	set_global_assignment -name DPRAM_WIDE_MODE_INPUT_EPXA4_10 "LOWER TO 3 UPPER TO 4"
	set_global_assignment -name DPRAM_SINGLE_PORT_MODE_INPUT_EPXA4_10 "DPRAM0 TO 3 DPRAM1 TO 4"
	set_global_assignment -name DPRAM_DUAL_PORT_MODE_INPUT_EPXA4_10 "DPRAM0 TO 3 DPRAM1 TO 4"
	set_global_assignment -name DPRAM_DEEP_MODE_OUTPUT_EPXA4_10 "MEGALAB COLUMN 3"
	set_global_assignment -name DPRAM_WIDE_MODE_OUTPUT_EPXA4_10 "LOWER TO 3 UPPER TO 4ESB"
	set_global_assignment -name DPRAM_SINGLE_PORT_MODE_OUTPUT_EPXA4_10 "DPRAM0 TO 3 DPRAM1 TO 4ESB"
	set_global_assignment -name DPRAM_DUAL_PORT_MODE_OUTPUT_EPXA4_10 "DPRAM0 TO 3 DPRAM1 TO 4ESB"
	set_global_assignment -name DPRAM_DEEP_MODE_OTHER_SIGNALS_EPXA4_10 "MEGALAB COLUMN 3"
	set_global_assignment -name DPRAM_WIDE_MODE_OTHER_SIGNALS_EPXA4_10 "MEGALAB COLUMN 3"
	set_global_assignment -name DPRAM_SINGLE_PORT_MODE_OTHER_SIGNALS_EPXA4_10 "DPRAM0 TO 3 DPRAM1 TO 4"
	set_global_assignment -name DPRAM_DUAL_PORT_MODE_OTHER_SIGNALS_EPXA4_10 "DPRAM0 TO 3 DPRAM1 TO 4"
	set_global_assignment -name DPRAM_8BIT_16BIT_SINGLE_PORT_MODE_INPUT_EPXA1 "MEGALAB COLUMN 1"
	set_global_assignment -name DPRAM_32BIT_SINGLE_PORT_MODE_INPUT_EPXA1 "MEGALAB COLUMN 1"
	set_global_assignment -name DPRAM_DUAL_PORT_MODE_INPUT_EPXA1 "DPRAM0 TO 1 DPRAM1 TO 2"
	set_global_assignment -name DPRAM_8BIT_16BIT_SINGLE_PORT_MODE_OUTPUT_EPXA1 "MEGALAB COLUMN 1"
	set_global_assignment -name DPRAM_32BIT_SINGLE_PORT_MODE_OUTPUT_EPXA1 "LOWER TO 1ESB UPPER TO 1"
	set_global_assignment -name DPRAM_DUAL_PORT_MODE_OUTPUT_EPXA1 "DPRAM0 TO 1 DPRAM1 TO 2"
	set_global_assignment -name DPRAM_8BIT_16BIT_SINGLE_PORT_MODE_OTHER_SIGNALS_EPXA1 "MEGALAB COLUMN 1"
	set_global_assignment -name DPRAM_32BIT_SINGLE_PORT_MODE_OTHER_SIGNALS_EPXA1 "MEGALAB COLUMN 1"
	set_global_assignment -name DPRAM_DUAL_PORT_MODE_OTHER_SIGNALS_EPXA1 "DPRAM0 TO 1 DPRAM1 TO 2"
	set_global_assignment -name SEED 1
	set_global_assignment -name SLOW_SLEW_RATE OFF
	set_global_assignment -name PCI_IO OFF
	set_global_assignment -name TURBO_BIT ON
	set_global_assignment -name WEAK_PULL_UP_RESISTOR OFF
	set_global_assignment -name ENABLE_BUS_HOLD_CIRCUITRY OFF
	set_global_assignment -name AUTO_PACKED_REGISTERS_STRATIXII AUTO
	set_global_assignment -name AUTO_PACKED_REGISTERS_MAXII AUTO
	set_global_assignment -name AUTO_PACKED_REGISTERS_CYCLONE AUTO
	set_global_assignment -name AUTO_PACKED_REGISTERS OFF
	set_global_assignment -name AUTO_PACKED_REGISTERS_STRATIX AUTO
	set_global_assignment -name NORMAL_LCELL_INSERT ON
	set_global_assignment -name CARRY_OUT_PINS_LCELL_INSERT ON
	set_global_assignment -name AUTO_DELAY_CHAINS ON
	set_global_assignment -name AUTO_FAST_INPUT_REGISTERS OFF
	set_global_assignment -name AUTO_FAST_OUTPUT_REGISTERS OFF
	set_global_assignment -name AUTO_FAST_OUTPUT_ENABLE_REGISTERS OFF
	set_global_assignment -name AUTO_MERGE_PLLS ON
	set_global_assignment -name AUTO_TURBO_BIT ON
	set_global_assignment -name PHYSICAL_SYNTHESIS_COMBO_LOGIC OFF
	set_global_assignment -name IO_PLACEMENT_OPTIMIZATION ON
	set_global_assignment -name ALLOW_LVTTL_LVCMOS_INPUT_LEVELS_TO_OVERDRIVE_INPUT_BUFFER OFF
	set_global_assignment -name OVERRIDE_DEFAULT_ELECTROMIGRATION_PARAMETERS OFF
	set_global_assignment -name FITTER_EFFORT "AUTO FIT"
	set_global_assignment -name ROUTER_LCELL_INSERTION_AND_LOGIC_DUPLICATION AUTO
	set_global_assignment -name ROUTER_REGISTER_DUPLICATION OFF
	set_global_assignment -name ALLOW_SERIES_TERMINATION OFF
	set_global_assignment -name ALLOW_PARALLEL_TERMINATION OFF
	set_global_assignment -name STRATIXGX_ALLOW_CLOCK_FANOUT_WITH_ANALOG_RESET OFF
	set_global_assignment -name AUTO_GLOBAL_CLOCK ON
	set_global_assignment -name AUTO_GLOBAL_OE ON
	set_global_assignment -name AUTO_GLOBAL_REGISTER_CONTROLS ON
	set_global_assignment -name NUMBER_OF_SOURCES_PER_DESTINATION_TO_REPORT 10
	set_global_assignment -name NUMBER_OF_DESTINATION_TO_REPORT 10
	set_global_assignment -name DEFAULT_HOLD_MULTICYCLE "SAME AS MULTICYCLE"
	set_global_assignment -name ANALYZE_LATCHES_AS_SYNCHRONOUS_ELEMENTS OFF
	set_global_assignment -name EDA_SIMULATION_TOOL "<None>"
	set_global_assignment -name EDA_TIMING_ANALYSIS_TOOL "<None>"
	set_global_assignment -name EDA_BOARD_DESIGN_TOOL "<None>"
	set_global_assignment -name EDA_FORMAL_VERIFICATION_TOOL "<None>"
	set_global_assignment -name EDA_RESYNTHESIS_TOOL "<None>"
	set_global_assignment -name HARDCOPY_EXTERNAL_CLOCK_JITTER "0.0 ns"
	set_global_assignment -name HARDCOPY_INPUT_TRANSITION_CLOCK_PIN "0.1 ns"
	set_global_assignment -name HARDCOPY_INPUT_TRANSITION_DATA_PIN "1.0 ns"
	set_global_assignment -name EDA_SIMULATION_TOOL "<None>"
	set_global_assignment -name EDA_TIMING_ANALYSIS_TOOL "<None>"
	set_global_assignment -name EDA_BOARD_DESIGN_TOOL "<None>"
	set_global_assignment -name EDA_FORMAL_VERIFICATION_TOOL "<None>"
	set_global_assignment -name EDA_RESYNTHESIS_TOOL "<None>"
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
	set_global_assignment -name USE_CONFIGURATION_DEVICE ON
	set_global_assignment -name STRATIX_II_CONFIGURATION_DEVICE AUTO
	set_global_assignment -name APEX20K_CONFIGURATION_DEVICE AUTO
	set_global_assignment -name EXCALIBUR_CONFIGURATION_DEVICE AUTO
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
	set_global_assignment -name START_TIME 0ns
	set_global_assignment -name SIMULATION_MODE TIMING
	set_global_assignment -name AUTO_USE_SIMULATION_PDB_NETLIST OFF
	set_global_assignment -name ADD_DEFAULT_PINS_TO_SIMULATION_OUTPUT_WAVEFORMS ON
	set_global_assignment -name POWER_ESTIMATION_START_TIME "0 ns"
	set_global_assignment -name SETUP_HOLD_DETECTION OFF
	set_global_assignment -name CHECK_OUTPUTS OFF
	set_global_assignment -name SIMULATION_COVERAGE ON
	set_global_assignment -name GLITCH_DETECTION OFF
	set_global_assignment -name GLITCH_INTERVAL 1ns
	set_global_assignment -name ESTIMATE_POWER_CONSUMPTION OFF
	set_global_assignment -name SIM_NO_DELAYS OFF
	set_global_assignment -name PROCESSOR ARM922T
	set_global_assignment -name BYTE_ORDER "LITTLE ENDIAN"
	set_global_assignment -name TOOLSET "CUSTOM BUILD"
	set_global_assignment -name OUTPUT_TYPE "INTEL HEX"
	set_global_assignment -name PROGRAMMING_FILE_TYPE "NO PROGRAMMING FILE"
	set_global_assignment -name DO_POST_BUILD_COMMAND_LINE OFF
	set_global_assignment -name USE_C_PREPROCESSOR_FOR_GNU_ASM_FILES ON
	set_global_assignment -name ARM_CPP_COMMAND_LINE "-O2"
	set_global_assignment -name GNUPRO_NIOS_CPP_COMMAND_LINE "-O3"
	set_global_assignment -name GNUPRO_ARM_CPP_COMMAND_LINE "-O3 -fomit-frame-pointer"
	set_global_assignment -name DRC_REPORT_TOP_FANOUT ON
	set_global_assignment -name DRC_TOP_FANOUT 50
	set_global_assignment -name DRC_REPORT_FANOUT_EXCEEDING ON
	set_global_assignment -name DRC_FANOUT_EXCEEDING 30
	set_global_assignment -name ASSG_CAT ON
	set_global_assignment -name ASSG_RULE_MISSING_FMAX ON
	set_global_assignment -name SIGNALRACE_RULE_TRISTATE ON
	set_global_assignment -name HCPY_PLL_MULTIPLE_CLK_NETWORK_TYPES ON
	set_global_assignment -name NONSYNCHSTRUCT_RULE_ASYN_RAM ON
	set_global_assignment -name HARDCOPY_FLOW_AUTOMATION MIGRATION_ONLY
	set_global_assignment -name CLK_CAT ON
	set_global_assignment -name CLK_RULE_COMB_CLOCK ON
	set_global_assignment -name CLK_RULE_INV_CLOCK ON
	set_global_assignment -name CLK_RULE_GATING_SCHEME ON
	set_global_assignment -name CLK_RULE_INPINS_CLKNET ON
	set_global_assignment -name CLK_RULE_CLKNET_CLKSPINES ON
	set_global_assignment -name CLK_RULE_MIX_EDGES ON
	set_global_assignment -name RESET_CAT ON
	set_global_assignment -name RESET_RULE_INPINS_RESETNET ON
	set_global_assignment -name TIMING_CAT ON
	set_global_assignment -name TIMING_RULE_SHIFT_REG ON
	set_global_assignment -name TIMING_RULE_COIN_CLKEDGE ON
	set_global_assignment -name NONSYNCHSTRUCT_RULE_COMB_DRIVES_RAM_WE ON
	set_global_assignment -name NONSYNCHSTRUCT_CAT ON
	set_global_assignment -name NONSYNCHSTRUCT_RULE_COMBLOOP ON
	set_global_assignment -name NONSYNCHSTRUCT_RULE_REG_LOOP ON
	set_global_assignment -name NONSYNCHSTRUCT_RULE_DELAY_CHAIN ON
	set_global_assignment -name NONSYNCHSTRUCT_RULE_RIPPLE_CLK ON
	set_global_assignment -name NONSYNCHSTRUCT_RULE_ILLEGAL_PULSE_GEN ON
	set_global_assignment -name NONSYNCHSTRUCT_RULE_MULTI_VIBRATOR ON
	set_global_assignment -name NONSYNCHSTRUCT_RULE_SRLATCH ON
	set_global_assignment -name NONSYNCHSTRUCT_RULE_LATCH_UNIDENTIFIED ON
	set_global_assignment -name SIGNALRACE_CAT ON
	set_global_assignment -name ACLK_CAT ON
	set_global_assignment -name ACLK_RULE_NO_SZER_ACLK_DOMAIN ON
	set_global_assignment -name ACLK_RULE_SZER_BTW_ACLK_DOMAIN ON
	set_global_assignment -name ACLK_RULE_IMSZER_ADOMAIN ON
	set_global_assignment -name HCPY_CAT ON
	set_global_assignment -name HCPY_VREF_PINS ON
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
	set_global_assignment -name AUTO_INSERT_SLD_HUB_ENTITY ENABLE

	# Commit assignments
	export_assignments

	# Close project
	if {$need_to_close_project} {
		project_close
	}
}
