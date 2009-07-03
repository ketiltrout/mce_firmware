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

# Quartus II Version 8.1 Build 163 10/28/2008 SJ Full Version
# File: C:\mce\cards\readout_card\readout_card\synth\readout_card.tcl
# Generated on: Thu Nov 27 22:24:55 2008

# $Id: readout_card_ep3se50.tcl,v 1.5.2.1 2009/06/24 16:14:58 bburger Exp $

# print welcome message
puts "\n\nReadout Card Rev C Pin Assignment Script"
puts "--------------------------------------------"

cd ../../ddr2_sdram_ctrl/source/rtl/
source micron_ctrl_pin_assignments.tcl
cd ../../../readout_card/synth_stratix_iii/

# include Quartus Tcl API
package require ::quartus::project
package require ::quartus::flow

# get entity name
set top_name [get_project_settings -cmp]
puts "\nInfo: Top-level entity is $top_name."

## List of pins not assigned.
#     AE22 DDR_LDQS#/NU
#     AH24 DDR_UDQS#/NU

puts "\nInfo: Assigning pins:"

set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to mem_odt[0]
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to mem_odt[0]
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.8-V SSTL CLASS I" -to mem_clk[0]
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITHOUT CALIBRATION" -to mem_clk[0]

# Not picked up by Quartus for complementary pair
#set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.8-V SSTL CLASS I" -to mem_clk_n[0]
#set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITHOUT CALIBRATION" -to mem_clk_n[0]

set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to mem_cs_n[0]
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to mem_cs_n[0]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to mem_cke[0]
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to mem_cke[0]

set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to mem_addr[0]
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to mem_addr[0]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to mem_addr[1]
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to mem_addr[1]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to mem_addr[2]
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to mem_addr[2]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to mem_addr[3]
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to mem_addr[3]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to mem_addr[4]
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to mem_addr[4]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to mem_addr[5]
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to mem_addr[5]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to mem_addr[6]
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to mem_addr[6]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to mem_addr[7]
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to mem_addr[7]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to mem_addr[8]
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to mem_addr[8]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to mem_addr[9]
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to mem_addr[9]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to mem_addr[10]
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to mem_addr[10]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to mem_addr[11]
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to mem_addr[11]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to mem_addr[12]
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to mem_addr[12]

set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to mem_ba[0]
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to mem_ba[0]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to mem_ba[1]
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to mem_ba[1]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to mem_ras_n
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to mem_ras_n
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to mem_cas_n
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to mem_cas_n
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to mem_we_n
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to mem_we_n

set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to mem_dq[0]
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to mem_dq[0]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to mem_dq[1]
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to mem_dq[1]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to mem_dq[2]
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to mem_dq[2]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to mem_dq[3]
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to mem_dq[3]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to mem_dq[4]
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to mem_dq[4]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to mem_dq[5]
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to mem_dq[5]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to mem_dq[6]
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to mem_dq[6]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to mem_dq[7]
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to mem_dq[7]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to mem_dq[8]
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to mem_dq[8]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to mem_dq[9]
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to mem_dq[9]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to mem_dq[10]
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to mem_dq[10]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to mem_dq[11]
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to mem_dq[11]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to mem_dq[12]
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to mem_dq[12]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to mem_dq[13]
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to mem_dq[13]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to mem_dq[14]
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to mem_dq[14]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to mem_dq[15]
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to mem_dq[15]

set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.8-V SSTL CLASS I" -to mem_dqs[0]
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to mem_dqs[0]
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.8-V SSTL CLASS I" -to mem_dqs[1]
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to mem_dqs[1]

# Need these because these complement signals are explicitely specified in the DDR interface
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.8-V SSTL CLASS I" -to mem_dqsn[0]
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to mem_dqsn[0]
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.8-V SSTL CLASS I" -to mem_dqsn[1]
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to mem_dqsn[1]

# I'd like to rename these signals to ldm and udm to agree with the pinout.
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to mem_dm[0]
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to mem_dm[0]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to mem_dm[1]
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to mem_dm[1]

set_instance_assignment -name OUTPUT_ENABLE_GROUP 517035168 -to mem_dq[0]
set_instance_assignment -name OUTPUT_ENABLE_GROUP 517035168 -to mem_dq[1]
set_instance_assignment -name OUTPUT_ENABLE_GROUP 517035168 -to mem_dq[2]
set_instance_assignment -name OUTPUT_ENABLE_GROUP 517035168 -to mem_dq[3]
set_instance_assignment -name OUTPUT_ENABLE_GROUP 517035168 -to mem_dq[4]
set_instance_assignment -name OUTPUT_ENABLE_GROUP 517035168 -to mem_dq[5]
set_instance_assignment -name OUTPUT_ENABLE_GROUP 517035168 -to mem_dq[6]
set_instance_assignment -name OUTPUT_ENABLE_GROUP 517035168 -to mem_dq[7]
set_instance_assignment -name OUTPUT_ENABLE_GROUP 517035168 -to mem_dq[8]
set_instance_assignment -name OUTPUT_ENABLE_GROUP 517035168 -to mem_dq[9]
set_instance_assignment -name OUTPUT_ENABLE_GROUP 517035168 -to mem_dq[10]
set_instance_assignment -name OUTPUT_ENABLE_GROUP 517035168 -to mem_dq[11]
set_instance_assignment -name OUTPUT_ENABLE_GROUP 517035168 -to mem_dq[12]
set_instance_assignment -name OUTPUT_ENABLE_GROUP 517035168 -to mem_dq[13]
set_instance_assignment -name OUTPUT_ENABLE_GROUP 517035168 -to mem_dq[14]
set_instance_assignment -name OUTPUT_ENABLE_GROUP 517035168 -to mem_dq[15]

set_instance_assignment -name OUTPUT_ENABLE_GROUP 517035168 -to mem_dqs[0]
set_instance_assignment -name OUTPUT_ENABLE_GROUP 517035168 -to mem_dqs[1]

# Need these because these complement signals are explicitely specified in the DDR interface
set_instance_assignment -name OUTPUT_ENABLE_GROUP 517035168 -to mem_dqsn[0]
set_instance_assignment -name OUTPUT_ENABLE_GROUP 517035168 -to mem_dqsn[1]

set_instance_assignment -name OUTPUT_ENABLE_GROUP 517035168 -to mem_dm[0]
set_instance_assignment -name OUTPUT_ENABLE_GROUP 517035168 -to mem_dm[1]

# New ADC Assignments
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to adc_sclk
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to adc_sdio
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to adc_csb_n
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to adc_pdwn

set_instance_assignment -name IO_STANDARD LVDS -to adc0_lvds_p
set_instance_assignment -name IO_STANDARD LVDS -to adc1_lvds_p
set_instance_assignment -name IO_STANDARD LVDS -to adc2_lvds_p
set_instance_assignment -name IO_STANDARD LVDS -to adc3_lvds_p
set_instance_assignment -name IO_STANDARD LVDS -to adc4_lvds_p
set_instance_assignment -name IO_STANDARD LVDS -to adc5_lvds_p
set_instance_assignment -name IO_STANDARD LVDS -to adc6_lvds_p
set_instance_assignment -name IO_STANDARD LVDS -to adc7_lvds_p
set_instance_assignment -name IO_STANDARD LVDS -to adc_clk_p
# adc_fco_p will go through a level shifter to TTL for rev C issue 1
#set_instance_assignment -name IO_STANDARD LVDS -to adc_fco_p


#############################################################
# Assign DDR pins
# It would be good to rename the whole lot with the prefix "ddr" instead of "mem" to agree with the schematics
#############################################################
# I'd like to rename all this set of signals as ddr_a[x] to agree with the schematics
set_location_assignment PIN_Y19 -to mem_addr[0]
set_location_assignment PIN_AE20 -to mem_addr[1]
set_location_assignment PIN_AF21 -to mem_addr[2]
set_location_assignment PIN_Y18 -to mem_addr[3]
set_location_assignment PIN_AE21 -to mem_addr[4]
set_location_assignment PIN_AG21 -to mem_addr[5]
set_location_assignment PIN_Y17 -to mem_addr[6]
set_location_assignment PIN_AC20 -to mem_addr[7]
set_location_assignment PIN_AE19 -to mem_addr[8]
set_location_assignment PIN_AA19 -to mem_addr[9]
set_location_assignment PIN_AA23 -to mem_addr[10]
set_location_assignment PIN_W21 -to mem_addr[11]
set_location_assignment PIN_AD28 -to mem_addr[12]

set_location_assignment PIN_AB24 -to mem_ba[0]
set_location_assignment PIN_AD27 -to mem_ba[1]
set_location_assignment PIN_AC19 -to mem_cas_n
set_location_assignment PIN_AA18 -to mem_cke[0]
set_location_assignment PIN_AF20 -to mem_cs_n[0]
# I'd like to rename this as ddr_ldm[0] to agree with the schematics
set_location_assignment PIN_AF26 -to mem_dm[0]
# I'd like to rename this as ddr_udm[0] to agree with the schematics
set_location_assignment PIN_AD24 -to mem_dm[1]
set_location_assignment PIN_AD19 -to mem_odt[0]
set_location_assignment PIN_AD18 -to mem_ras_n
set_location_assignment PIN_AB19 -to mem_we_n

set_location_assignment PIN_AE27 -to mem_clk[0]
set_location_assignment PIN_AH27 -to mem_dq[0]
set_location_assignment PIN_AH25 -to mem_dq[1]
set_location_assignment PIN_AG25 -to mem_dq[2]
set_location_assignment PIN_AG27 -to mem_dq[3]
set_location_assignment PIN_AH26 -to mem_dq[4]
set_location_assignment PIN_AB20 -to mem_dq[5]
set_location_assignment PIN_AB21 -to mem_dq[6]
set_location_assignment PIN_AD21 -to mem_dq[7]
set_location_assignment PIN_AE23 -to mem_dq[8]
set_location_assignment PIN_AF24 -to mem_dq[9]
set_location_assignment PIN_AE24 -to mem_dq[10]
set_location_assignment PIN_AF23 -to mem_dq[11]
set_location_assignment PIN_AG24 -to mem_dq[12]
set_location_assignment PIN_AH20 -to mem_dq[13]
set_location_assignment PIN_AH21 -to mem_dq[14]
set_location_assignment PIN_AH22 -to mem_dq[15]
set_location_assignment PIN_AD22 -to mem_dqs[0]
set_location_assignment PIN_AH23 -to mem_dqs[1]
# The FPGA does not connect to this DDR pin.  Has it moved?
#set_location_assignment PIN_AC28 -to ddr_shutdown_n
set_location_assignment PIN_D27 -to termination_blk0~_rup_pad
set_location_assignment PIN_C28 -to termination_blk0~_rdn_pad

set_location_assignment PIN_U28 -to inclk_ddr
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to mem_dq[0]
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to mem_dq[1]
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to mem_dq[2]
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to mem_dq[3]
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to mem_dq[4]
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to mem_dq[5]
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to mem_dq[6]
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to mem_dq[7]
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to mem_dq[8]
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to mem_dq[9]
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to mem_dq[10]
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to mem_dq[11]
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to mem_dq[12]
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to mem_dq[13]
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to mem_dq[14]
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to mem_dq[15]
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to mem_dqs[0]
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to mem_dqs[1]
# Need these because these complement signals are explicitely specified in the DDR interface
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to mem_dqsn[0]
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to mem_dqsn[1]
puts "   Assigned: DDR pins."
            
# Assign DDR test pins
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
puts "   Assigned: DDR test pins."

# assign PLL pins
# CLK0 N26
# CLK1 P28
# CLK2 U28   --> inclk_ddr
# CLK3 R27
# --CLK5 AG15-- removed in latest pcb
# --CLK8 R1 -- removed in latest pcb
# CLK9 U2    --> inclk
# --CLK10 P2-- removed in latest pcb
# CLK12 D14
# CLK13 B14

# PLL_L2 in     = CLK2       (from crystal via CPLD)
# PLL_R1_in     = CLK9
cmp add_assignment $top_name "" inclk LOCATION "Pin_U2"
# inclk_ddr assigned in ddr section
# cmp add_assignment $top_name "" inclk_ddr LOCATION "Pin_U28"
# No longer an output.  Not sure if this was replaced by something else.
#cmp add_assignment $top_name "" "pll_l2_out\[0\]" LOCATION "Pin_P19"
puts "   Assigned: PLL pins."

# Assign ADC pins
# These pins are the negative complements of differential pairs.  
# Quartus picks these up automatically when the positive complements are assigned as differential 
#cmp add_assignment $top_name "" adc0_lvds_n LOCATION "Pin_W3"
cmp add_assignment $top_name "" adc0_lvds_p LOCATION "Pin_W4"
#cmp add_assignment $top_name "" adc1_lvds_n LOCATION "Pin_Y1"
cmp add_assignment $top_name "" adc1_lvds_p LOCATION "Pin_W2"
#cmp add_assignment $top_name "" adc2_lvds_n LOCATION "Pin_AA1"
cmp add_assignment $top_name "" adc2_lvds_p LOCATION "Pin_Y2"
#cmp add_assignment $top_name "" adc3_lvds_n LOCATION "Pin_AB1"
cmp add_assignment $top_name "" adc3_lvds_p LOCATION "Pin_AB2"
#cmp add_assignment $top_name "" adc4_lvds_n LOCATION "Pin_AC1"
cmp add_assignment $top_name "" adc4_lvds_p LOCATION "Pin_AC2"
#cmp add_assignment $top_name "" adc5_lvds_n LOCATION "Pin_AE1"
cmp add_assignment $top_name "" adc5_lvds_p LOCATION "Pin_AD1"
#cmp add_assignment $top_name "" adc6_lvds_n LOCATION "Pin_AF1"
cmp add_assignment $top_name "" adc6_lvds_p LOCATION "Pin_AE2"
#cmp add_assignment $top_name "" adc7_lvds_n LOCATION "Pin_AG1"
cmp add_assignment $top_name "" adc7_lvds_p LOCATION "Pin_AF2"
#cmp add_assignment $top_name "" adc_fco_n LOCATION ""

# This assignment has changed to fix a hardware mistake in Issue 0
cmp add_assignment $top_name "" adc_fco_p LOCATION "PIN_P2"
#cmp add_assignment $top_name "" adc_clk_n LOCATION "Pin_AA15"

cmp add_assignment $top_name "" adc_clk_p LOCATION "Pin_Y15"
cmp add_assignment $top_name "" adc_sclk LOCATION "Pin_AF28"
cmp add_assignment $top_name "" adc_sdio LOCATION "Pin_AC25"
cmp add_assignment $top_name "" adc_csb_n LOCATION "Pin_AC26"
cmp add_assignment $top_name "" adc_pdwn LOCATION "Pin_AB27"
# There is a hardware mistake on this pin, and it has not been reassigned yet
#cmp add_assignment $top_name "" adc_dco_n LOCATION "Pin_T1"
#cmp add_assignment $top_name "" adc_dco_p LOCATION "Pin_R1"
puts "   Assigned: ADC pins."

cmp add_assignment $top_name "" dev_clr_n LOCATION "Pin_R27" 
puts "   Assigned: RST_N pin."

# assign leds
cmp add_assignment $top_name "" red_led LOCATION "Pin_AG10"
cmp add_assignment $top_name "" ylw_led LOCATION "Pin_AH11"
cmp add_assignment $top_name "" grn_led LOCATION "Pin_AH13"
puts "   Assigned: LED pins."

# assign dip switches
cmp add_assignment $top_name "" dip0 LOCATION "Pin_AE9"
cmp add_assignment $top_name "" dip1 LOCATION "Pin_U26"
cmp add_assignment $top_name "" dip2 LOCATION "Pin_V26"
cmp add_assignment $top_name "" dip3 LOCATION "Pin_AH9"
#puts "   Assigned: DIP switch pins."

# assign watchdog
cmp add_assignment $top_name "" wdog LOCATION "Pin_AF10"
#puts "   Assigned: Watchdog pin."

# reply lines to clock card (brx7a, brx7b)
cmp add_assignment $top_name "" lvds_txa LOCATION "Pin_B11"
cmp add_assignment $top_name "" lvds_txb LOCATION "Pin_A10"
cmp add_assignment $top_name "" lvds_sync LOCATION "Pin_AD12"
cmp add_assignment $top_name "" lvds_spare LOCATION "Pin_AE11"
cmp add_assignment $top_name "" lvds_cmd LOCATION "Pin_AE12"
puts "   Assigned: LVDS pins."

# assign rs232 interface
cmp add_assignment $top_name "" rs232_tx LOCATION "Pin_M23"
cmp add_assignment $top_name "" rs232_rx LOCATION "Pin_M22"
puts "   Assigned: RS232 pins."

# assign mictor connector header
set_location_assignment Pin_P20 -to mictor_clk
puts "   Assigned: Mictor header pins"

# assign SMB pins to read fpga temperature
cmp add_assignment $top_name "" smb_clk LOCATION "Pin_L28"
cmp add_assignment $top_name "" smb_data LOCATION "Pin_M28"
# I'd like to rename this pin to nalert to agree with the schematics
cmp add_assignment $top_name "" smb_nalert LOCATION "Pin_M26"
puts "   Assigned: SMB interface pins."

# assign EEPROM pins
cmp add_assignment $top_name "" eeprom_si LOCATION "Pin_M20"
cmp add_assignment $top_name "" eeprom_so LOCATION "Pin_K28"
cmp add_assignment $top_name "" eeprom_sck LOCATION "Pin_N20"
cmp add_assignment $top_name "" eeprom_cs LOCATION "Pin_L25"
puts "   Assigned: EEPROM pins."

# assign ID pins
# I'd like to rename this signals to sid[0], etc. to agree with the schematics
cmp add_assignment $top_name "" "slot_id\[0\]" LOCATION "Pin_AC12"
cmp add_assignment $top_name "" "slot_id\[1\]" LOCATION "Pin_AF12"
cmp add_assignment $top_name "" "slot_id\[2\]" LOCATION "Pin_AG12"
cmp add_assignment $top_name "" "slot_id\[3\]" LOCATION "Pin_AH10"

cmp add_assignment $top_name "" card_id LOCATION "Pin_L26"
puts "   Assigned: ID pins."

# assign spare TTL
cmp add_assignment $top_name "" "ttl_dir1" LOCATION "Pin_AA13"
cmp add_assignment $top_name "" "ttl_in1" LOCATION "Pin_A14"
cmp add_assignment $top_name "" "ttl_out1" LOCATION "Pin_AB13"

cmp add_assignment $top_name "" "ttl_dir2" LOCATION "Pin_AD13"
cmp add_assignment $top_name "" "ttl_in2" LOCATION "Pin_A13"
cmp add_assignment $top_name "" "ttl_out2" LOCATION "Pin_C10"

cmp add_assignment $top_name "" "ttl_dir3" LOCATION "Pin_Y13"
cmp add_assignment $top_name "" "ttl_in3" LOCATION "Pin_A11"
cmp add_assignment $top_name "" "ttl_out3" LOCATION "Pin_Y14"
puts "   Assigned: Spare TTL pins."

# assign serial DAC
#dac_clr_n clears parallel and serial dacs
cmp add_assignment $top_name "" "dac_clr_n" LOCATION "Pin_AH6"

cmp add_assignment $top_name "" "dac_clk\[0\]" LOCATION "Pin_J4"
cmp add_assignment $top_name "" "dac_clk\[1\]" LOCATION "Pin_G5"
cmp add_assignment $top_name "" "dac_clk\[2\]" LOCATION "Pin_M4"
cmp add_assignment $top_name "" "dac_clk\[3\]" LOCATION "Pin_T5"
cmp add_assignment $top_name "" "dac_clk\[4\]" LOCATION "Pin_U3"
cmp add_assignment $top_name "" "dac_clk\[5\]" LOCATION "Pin_T3"
cmp add_assignment $top_name "" "dac_clk\[6\]" LOCATION "Pin_U8"
cmp add_assignment $top_name "" "dac_clk\[7\]" LOCATION "Pin_U7"

cmp add_assignment $top_name "" "dac_dat\[0\]" LOCATION "Pin_E5"
cmp add_assignment $top_name "" "dac_dat\[1\]" LOCATION "Pin_L5"
cmp add_assignment $top_name "" "dac_dat\[2\]" LOCATION "Pin_N4"
cmp add_assignment $top_name "" "dac_dat\[3\]" LOCATION "Pin_M3"
cmp add_assignment $top_name "" "dac_dat\[4\]" LOCATION "Pin_U4"
cmp add_assignment $top_name "" "dac_dat\[5\]" LOCATION "Pin_V3"
cmp add_assignment $top_name "" "dac_dat\[6\]" LOCATION "Pin_U5"
cmp add_assignment $top_name "" "dac_dat\[7\]" LOCATION "Pin_U6"

cmp add_assignment $top_name "" "bias_dac_ncs\[0\]" LOCATION "Pin_M6"
cmp add_assignment $top_name "" "bias_dac_ncs\[1\]" LOCATION "Pin_D5"
cmp add_assignment $top_name "" "bias_dac_ncs\[2\]" LOCATION "Pin_T6"
cmp add_assignment $top_name "" "bias_dac_ncs\[3\]" LOCATION "Pin_L3"
cmp add_assignment $top_name "" "bias_dac_ncs\[4\]" LOCATION "Pin_AE6"
cmp add_assignment $top_name "" "bias_dac_ncs\[5\]" LOCATION "Pin_T4"
cmp add_assignment $top_name "" "bias_dac_ncs\[6\]" LOCATION "Pin_AH4"
cmp add_assignment $top_name "" "bias_dac_ncs\[7\]" LOCATION "Pin_AH5"

cmp add_assignment $top_name "" "offset_dac_ncs\[0\]" LOCATION "Pin_C3"
cmp add_assignment $top_name "" "offset_dac_ncs\[1\]" LOCATION "Pin_N5"
cmp add_assignment $top_name "" "offset_dac_ncs\[2\]" LOCATION "Pin_L4"
cmp add_assignment $top_name "" "offset_dac_ncs\[3\]" LOCATION "Pin_P3"
cmp add_assignment $top_name "" "offset_dac_ncs\[4\]" LOCATION "Pin_R4"
cmp add_assignment $top_name "" "offset_dac_ncs\[5\]" LOCATION "Pin_V4"
cmp add_assignment $top_name "" "offset_dac_ncs\[6\]" LOCATION "Pin_AH3"
cmp add_assignment $top_name "" "offset_dac_ncs\[7\]" LOCATION "Pin_AH2"
puts "   Assigned: Serial DAC pins."

# assign parallel DAC
#dac_clr_n (assigned above) clears parallel and serial dacs
cmp add_assignment $top_name "" "dac_dfb_clk\[0\]" LOCATION "Pin_F17"
cmp add_assignment $top_name "" "dac0_dfb_dat\[0\]" LOCATION "Pin_J18"
cmp add_assignment $top_name "" "dac0_dfb_dat\[1\]" LOCATION "Pin_J20"
cmp add_assignment $top_name "" "dac0_dfb_dat\[2\]" LOCATION "Pin_J19"
cmp add_assignment $top_name "" "dac0_dfb_dat\[3\]" LOCATION "Pin_G20"
cmp add_assignment $top_name "" "dac0_dfb_dat\[4\]" LOCATION "Pin_G21"
cmp add_assignment $top_name "" "dac0_dfb_dat\[5\]" LOCATION "Pin_F21"
cmp add_assignment $top_name "" "dac0_dfb_dat\[6\]" LOCATION "Pin_E22"
cmp add_assignment $top_name "" "dac0_dfb_dat\[7\]" LOCATION "Pin_D21"
cmp add_assignment $top_name "" "dac0_dfb_dat\[8\]" LOCATION "Pin_E20"
cmp add_assignment $top_name "" "dac0_dfb_dat\[9\]" LOCATION "Pin_F20"
cmp add_assignment $top_name "" "dac0_dfb_dat\[10\]" LOCATION "Pin_F19"
cmp add_assignment $top_name "" "dac0_dfb_dat\[11\]" LOCATION "Pin_D18"
cmp add_assignment $top_name "" "dac0_dfb_dat\[12\]" LOCATION "Pin_E17"
cmp add_assignment $top_name "" "dac0_dfb_dat\[13\]" LOCATION "Pin_E16"

cmp add_assignment $top_name "" "dac_dfb_clk\[1\]" LOCATION "Pin_A27"
cmp add_assignment $top_name "" "dac1_dfb_dat\[0\]" LOCATION "Pin_A18"
cmp add_assignment $top_name "" "dac1_dfb_dat\[1\]" LOCATION "Pin_B19"
cmp add_assignment $top_name "" "dac1_dfb_dat\[2\]" LOCATION "Pin_A19"
cmp add_assignment $top_name "" "dac1_dfb_dat\[3\]" LOCATION "Pin_B20"
cmp add_assignment $top_name "" "dac1_dfb_dat\[4\]" LOCATION "Pin_A20"
cmp add_assignment $top_name "" "dac1_dfb_dat\[5\]" LOCATION "Pin_A21"
cmp add_assignment $top_name "" "dac1_dfb_dat\[6\]" LOCATION "Pin_B22"
cmp add_assignment $top_name "" "dac1_dfb_dat\[7\]" LOCATION "Pin_A22"
cmp add_assignment $top_name "" "dac1_dfb_dat\[8\]" LOCATION "Pin_B23"
cmp add_assignment $top_name "" "dac1_dfb_dat\[9\]" LOCATION "Pin_A23"
cmp add_assignment $top_name "" "dac1_dfb_dat\[10\]" LOCATION "Pin_B25"
cmp add_assignment $top_name "" "dac1_dfb_dat\[11\]" LOCATION "Pin_A25"
cmp add_assignment $top_name "" "dac1_dfb_dat\[12\]" LOCATION "Pin_B26"
cmp add_assignment $top_name "" "dac1_dfb_dat\[13\]" LOCATION "Pin_A26"

cmp add_assignment $top_name "" "dac_dfb_clk\[2\]" LOCATION "Pin_F1"
cmp add_assignment $top_name "" "dac2_dfb_dat\[0\]" LOCATION "Pin_G18"
cmp add_assignment $top_name "" "dac2_dfb_dat\[1\]" LOCATION "Pin_H19"
cmp add_assignment $top_name "" "dac2_dfb_dat\[2\]" LOCATION "Pin_J16"
cmp add_assignment $top_name "" "dac2_dfb_dat\[3\]" LOCATION "Pin_T8"
cmp add_assignment $top_name "" "dac2_dfb_dat\[4\]" LOCATION "Pin_B4"
cmp add_assignment $top_name "" "dac2_dfb_dat\[5\]" LOCATION "Pin_A3"
cmp add_assignment $top_name "" "dac2_dfb_dat\[6\]" LOCATION "Pin_A2"
cmp add_assignment $top_name "" "dac2_dfb_dat\[7\]" LOCATION "Pin_B2"
cmp add_assignment $top_name "" "dac2_dfb_dat\[8\]" LOCATION "Pin_B1"
cmp add_assignment $top_name "" "dac2_dfb_dat\[9\]" LOCATION "Pin_C1"
cmp add_assignment $top_name "" "dac2_dfb_dat\[10\]" LOCATION "Pin_D2"
cmp add_assignment $top_name "" "dac2_dfb_dat\[11\]" LOCATION "Pin_D1"
cmp add_assignment $top_name "" "dac2_dfb_dat\[12\]" LOCATION "Pin_E2"
cmp add_assignment $top_name "" "dac2_dfb_dat\[13\]" LOCATION "Pin_E1"

cmp add_assignment $top_name "" "dac_dfb_clk\[3\]" LOCATION "Pin_A17"
cmp add_assignment $top_name "" "dac3_dfb_dat\[0\]" LOCATION "Pin_A4"
cmp add_assignment $top_name "" "dac3_dfb_dat\[1\]" LOCATION "Pin_B5"
cmp add_assignment $top_name "" "dac3_dfb_dat\[2\]" LOCATION "Pin_A5"
cmp add_assignment $top_name "" "dac3_dfb_dat\[3\]" LOCATION "Pin_A6"
cmp add_assignment $top_name "" "dac3_dfb_dat\[4\]" LOCATION "Pin_B7"
cmp add_assignment $top_name "" "dac3_dfb_dat\[5\]" LOCATION "Pin_A7"
cmp add_assignment $top_name "" "dac3_dfb_dat\[6\]" LOCATION "Pin_B8"
cmp add_assignment $top_name "" "dac3_dfb_dat\[7\]" LOCATION "Pin_A8"
cmp add_assignment $top_name "" "dac3_dfb_dat\[8\]" LOCATION "Pin_A9"
cmp add_assignment $top_name "" "dac3_dfb_dat\[9\]" LOCATION "Pin_C9"
cmp add_assignment $top_name "" "dac3_dfb_dat\[10\]" LOCATION "Pin_A15"
cmp add_assignment $top_name "" "dac3_dfb_dat\[11\]" LOCATION "Pin_B16"
cmp add_assignment $top_name "" "dac3_dfb_dat\[12\]" LOCATION "Pin_A16"
cmp add_assignment $top_name "" "dac3_dfb_dat\[13\]" LOCATION "Pin_B17"

cmp add_assignment $top_name "" "dac_dfb_clk\[4\]" LOCATION "Pin_C17"
cmp add_assignment $top_name "" "dac4_dfb_dat\[0\]" LOCATION "Pin_G22"
cmp add_assignment $top_name "" "dac4_dfb_dat\[1\]" LOCATION "Pin_F22"
cmp add_assignment $top_name "" "dac4_dfb_dat\[2\]" LOCATION "Pin_E23"
cmp add_assignment $top_name "" "dac4_dfb_dat\[3\]" LOCATION "Pin_D25"
cmp add_assignment $top_name "" "dac4_dfb_dat\[4\]" LOCATION "Pin_C24"
cmp add_assignment $top_name "" "dac4_dfb_dat\[5\]" LOCATION "Pin_D24"
cmp add_assignment $top_name "" "dac4_dfb_dat\[6\]" LOCATION "Pin_C23"
cmp add_assignment $top_name "" "dac4_dfb_dat\[7\]" LOCATION "Pin_D23"
cmp add_assignment $top_name "" "dac4_dfb_dat\[8\]" LOCATION "Pin_D22"
cmp add_assignment $top_name "" "dac4_dfb_dat\[9\]" LOCATION "Pin_C21"
cmp add_assignment $top_name "" "dac4_dfb_dat\[10\]" LOCATION "Pin_D20"
cmp add_assignment $top_name "" "dac4_dfb_dat\[11\]" LOCATION "Pin_C19"
cmp add_assignment $top_name "" "dac4_dfb_dat\[12\]" LOCATION "Pin_D19"
cmp add_assignment $top_name "" "dac4_dfb_dat\[13\]" LOCATION "Pin_C18"

cmp add_assignment $top_name "" "dac_dfb_clk\[5\]" LOCATION "Pin_G2"
cmp add_assignment $top_name "" "dac5_dfb_dat\[0\]" LOCATION "Pin_V1"
cmp add_assignment $top_name "" "dac5_dfb_dat\[1\]" LOCATION "Pin_U1"
cmp add_assignment $top_name "" "dac5_dfb_dat\[2\]" LOCATION "Pin_P4"
cmp add_assignment $top_name "" "dac5_dfb_dat\[3\]" LOCATION "Pin_N1"
cmp add_assignment $top_name "" "dac5_dfb_dat\[4\]" LOCATION "Pin_N2"
cmp add_assignment $top_name "" "dac5_dfb_dat\[5\]" LOCATION "Pin_M1"
cmp add_assignment $top_name "" "dac5_dfb_dat\[6\]" LOCATION "Pin_L1"
cmp add_assignment $top_name "" "dac5_dfb_dat\[7\]" LOCATION "Pin_L2"
cmp add_assignment $top_name "" "dac5_dfb_dat\[8\]" LOCATION "Pin_K1"
cmp add_assignment $top_name "" "dac5_dfb_dat\[9\]" LOCATION "Pin_K2"
cmp add_assignment $top_name "" "dac5_dfb_dat\[10\]" LOCATION "Pin_J1"
cmp add_assignment $top_name "" "dac5_dfb_dat\[11\]" LOCATION "Pin_H1"
cmp add_assignment $top_name "" "dac5_dfb_dat\[12\]" LOCATION "Pin_H2"
cmp add_assignment $top_name "" "dac5_dfb_dat\[13\]" LOCATION "Pin_G1"

cmp add_assignment $top_name "" "dac_dfb_clk\[6\]" LOCATION "Pin_J3"
cmp add_assignment $top_name "" "dac6_dfb_dat\[0\]" LOCATION "Pin_D17"
cmp add_assignment $top_name "" "dac6_dfb_dat\[1\]" LOCATION "Pin_D16"
cmp add_assignment $top_name "" "dac6_dfb_dat\[2\]" LOCATION "Pin_C15"
cmp add_assignment $top_name "" "dac6_dfb_dat\[3\]" LOCATION "Pin_D15"
cmp add_assignment $top_name "" "dac6_dfb_dat\[4\]" LOCATION "Pin_C8"
cmp add_assignment $top_name "" "dac6_dfb_dat\[5\]" LOCATION "Pin_D7"
cmp add_assignment $top_name "" "dac6_dfb_dat\[6\]" LOCATION "Pin_C6"
cmp add_assignment $top_name "" "dac6_dfb_dat\[7\]" LOCATION "Pin_C5"
cmp add_assignment $top_name "" "dac6_dfb_dat\[8\]" LOCATION "Pin_F4"
cmp add_assignment $top_name "" "dac6_dfb_dat\[9\]" LOCATION "Pin_F3"
cmp add_assignment $top_name "" "dac6_dfb_dat\[10\]" LOCATION "Pin_G3"
cmp add_assignment $top_name "" "dac6_dfb_dat\[11\]" LOCATION "Pin_G4"
cmp add_assignment $top_name "" "dac6_dfb_dat\[12\]" LOCATION "Pin_H3"
cmp add_assignment $top_name "" "dac6_dfb_dat\[13\]" LOCATION "Pin_H4"

cmp add_assignment $top_name "" "dac_dfb_clk\[7\]" LOCATION "Pin_H6"
cmp add_assignment $top_name "" "dac7_dfb_dat\[0\]" LOCATION "Pin_D9"
cmp add_assignment $top_name "" "dac7_dfb_dat\[1\]" LOCATION "Pin_D8"
cmp add_assignment $top_name "" "dac7_dfb_dat\[2\]" LOCATION "Pin_D6"
cmp add_assignment $top_name "" "dac7_dfb_dat\[3\]" LOCATION "Pin_E7"
cmp add_assignment $top_name "" "dac7_dfb_dat\[4\]" LOCATION "Pin_R10"
cmp add_assignment $top_name "" "dac7_dfb_dat\[5\]" LOCATION "Pin_N9"
cmp add_assignment $top_name "" "dac7_dfb_dat\[6\]" LOCATION "Pin_N8"
cmp add_assignment $top_name "" "dac7_dfb_dat\[7\]" LOCATION "Pin_K8"
cmp add_assignment $top_name "" "dac7_dfb_dat\[8\]" LOCATION "Pin_N7"
cmp add_assignment $top_name "" "dac7_dfb_dat\[9\]" LOCATION "Pin_N6"
cmp add_assignment $top_name "" "dac7_dfb_dat\[10\]" LOCATION "Pin_K6"
cmp add_assignment $top_name "" "dac7_dfb_dat\[11\]" LOCATION "Pin_K7"
cmp add_assignment $top_name "" "dac7_dfb_dat\[12\]" LOCATION "Pin_J6"
cmp add_assignment $top_name "" "dac7_dfb_dat\[13\]" LOCATION "Pin_H5"
puts "   Assigned: Parallel DAC pins."

# Assign misc pins
set_location_assignment PIN_N21 -to ~ALTERA_DATA0~
set_location_assignment PIN_P23 -to ~ALTERA_CRC_ERROR~
#cmp add_assignment $top_name "" crc_error_out LOCATION "Pin_P23"
cmp add_assignment $top_name "" crc_error_in LOCATION "Pin_T23"
cmp add_assignment $top_name "" critical_error LOCATION "Pin_M24"
cmp add_assignment $top_name "" extend_n LOCATION "Pin_AH12"
puts "   Assigned: miscellaneous pins."
