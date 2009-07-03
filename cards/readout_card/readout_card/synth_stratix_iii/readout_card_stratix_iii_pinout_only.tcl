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
# File: C:\mce\cards\readout_card\readout_card\synth_stratix_iii\pin_backup03_gold_standard.tcl
# Generated on: Thu Jun 18 16:03:13 2009

# $Id: readout_card_stratix_iii_pinout_only.tcl,v 1.2 2009/06/23 19:52:47 bburger Exp $



# print welcome message
puts ""
puts "----------------------------------------"
puts "Readout Card Rev C Pin Assignment Script"
puts "----------------------------------------"

# get entity name
set top_name [get_project_settings -cmp]
puts "Info: Top-level entity is $top_name."



#####################################################
# Start
#####################################################
package require ::quartus::project
package require ::quartus::flow



# Run the DDR2 assignment file
#cd ../../ddr2_sdram_ctrl/source/rtl/
#source micron_ctrl_pin_assignments.tcl
#cd ../../../readout_card/synth_stratix_iii/

# Run the DDR2 assignment file
source C:/mce/cards/readout_card/ddr2_sdram_ctrl/source/rtl/micron_ctrl_pin_assignments.tcl
cd C:/mce/cards/readout_card/readout_card/synth_stratix_iii/



#####################################################
puts "Info: Assigning DDR I/O Balancing Pins"
#####################################################
set_location_assignment PIN_D27 -to termination_blk0~_rup_pad
set_location_assignment PIN_C28 -to termination_blk0~_rdn_pad



#####################################################
puts "Info: Assigning Altera Special Pins"
#####################################################
set_location_assignment PIN_N21 -to ~ALTERA_DATA0~
set_location_assignment PIN_P23 -to ~ALTERA_CRC_ERROR~



#####################################################
puts "Info: Assigning Clocks and Resets"
#####################################################
set_location_assignment PIN_U2 -to inclk
set_location_assignment PIN_R27 -to dev_clr_n
set_location_assignment PIN_AF10 -to wdi



#####################################################
puts "Info: Assigning RS232 Interface"
#####################################################
set_location_assignment Pin_M23 -to rs232_tx 
set_location_assignment Pin_M22 -to rs232_rx 



#####################################################
puts "Info: Assigning EEPROM"
#####################################################
set_location_assignment Pin_M20 -to eeprom_si
set_location_assignment Pin_K28 -to eeprom_so
set_location_assignment Pin_N20 -to eeprom_sck
set_location_assignment Pin_L25 -to eeprom_cs



#####################################################
puts "Info: Assigning LVDS"
#####################################################
set_location_assignment PIN_AE11 -to lvds_spare
set_location_assignment PIN_B11 -to lvds_txa
set_location_assignment PIN_A10 -to lvds_txb
set_location_assignment PIN_AD12 -to lvds_sync
set_location_assignment PIN_AE12 -to lvds_cmd



#####################################################
puts "Info: Assigning Miscellaneous"
#####################################################

# Silicon ID
set_location_assignment PIN_L26 -to card_id

# Slot ID
set_location_assignment PIN_AC12 -to sid[0]
set_location_assignment PIN_AF12 -to sid[1]
set_location_assignment PIN_AG12 -to sid[2]
set_location_assignment PIN_AH10 -to sid[3]

# DIP Switches
set_location_assignment Pin_AE9 -to dip0
set_location_assignment Pin_U26 -to dip1
set_location_assignment PIN_V26 -to dip2
set_location_assignment PIN_AH9 -to dip3

# FPGA Temperature
set_location_assignment PIN_M26 -to nalert
set_location_assignment PIN_L28 -to smbclk
set_location_assignment PIN_M28 -to smbdata

# CRC Error Loop-Back
set_location_assignment Pin_T23 -to crc_error_in
# This pin is not assigned via the TCL file.  It is hardwared, if enabled through Quartus II.
#set_location_assignment Pin_P23 -to crc_error_out


# Critical Error Manual Pin Assignment
set_location_assignment Pin_M24 -to critical_error

# Extender Card Signal
set_location_assignment Pin_AH12 -to extend_n

# Check on this
cmp add_assignment $top_name "" "pll_l2_out\[0\]" LOCATION "Pin_P19"


#####################################################
puts "Info: Assigning TTL Backplane Spares"
#####################################################
set_location_assignment PIN_AA13 -to ttl_dir1
set_location_assignment PIN_AD13 -to ttl_dir2
set_location_assignment PIN_Y13 -to ttl_dir3
set_location_assignment PIN_A14 -to ttl_in1
set_location_assignment PIN_A13 -to ttl_in2
set_location_assignment PIN_A11 -to ttl_in3
set_location_assignment PIN_AB13 -to ttl_out1
set_location_assignment PIN_C10 -to ttl_out2
set_location_assignment PIN_Y14 -to ttl_out3



#####################################################
puts "Info: Assigning ADC"
#####################################################
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
set_location_assignment PIN_AB27 -to adc_pdwn

# This assignment is pointless because the input was mistakenly to a TTL input
#set_location_assignment PIN_R1 -to adc_dco_p



#####################################################
puts "Info: Assigning DDR2 SDRAM"
#####################################################
set_location_assignment PIN_U28 -to inclk_ddr
set_location_assignment PIN_AD22 -to ddr_dqs[0]
set_location_assignment PIN_AH23 -to ddr_dqs[1]
set_location_assignment PIN_AF26 -to ddr_ldm[0]
set_location_assignment PIN_AD19 -to ddr_odt[0]
set_location_assignment PIN_AD24 -to ddr_udm[0]
set_location_assignment PIN_AB24 -to ddr_ba[0]
set_location_assignment PIN_AD27 -to ddr_ba[1]
set_location_assignment PIN_AC19 -to ddr_cas_n
set_location_assignment PIN_AA18 -to ddr_cke[0]
set_location_assignment PIN_AF20 -to ddr_cs_n[0]
set_location_assignment PIN_AD18 -to ddr_ras_n
set_location_assignment PIN_AB19 -to ddr_we_n
set_location_assignment PIN_AE27 -to ddr_clk[0]

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

set_location_assignment Pin_P20 -to mictor_clk



#####################################################
# LEDs
puts "Info: Assigning LEDs"
#####################################################
set_location_assignment PIN_AH13 -to led_grn
set_location_assignment PIN_AG10 -to led_red
set_location_assignment PIN_AH11 -to led_ylw



#####################################################
# Feedback, Offset, and Bias DACS
puts "Info: Assigning Feedback, Offset, and Bias DACS"
#####################################################
set_location_assignment Pin_AH6 -to dac_clr_n

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

set_location_assignment PIN_F17 -to dac_fb_clk[0]
set_location_assignment PIN_A27 -to dac_fb_clk[1]
set_location_assignment PIN_F1 -to dac_fb_clk[2]
set_location_assignment PIN_A17 -to dac_fb_clk[3]
set_location_assignment PIN_C17 -to dac_fb_clk[4]
set_location_assignment PIN_G2 -to dac_fb_clk[5]
set_location_assignment PIN_J3 -to dac_fb_clk[6]
set_location_assignment PIN_H6 -to dac_fb_clk[7]

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



set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr_cke[0]
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to ddr_ldm[0]
set_instance_assignment -name OUTPUT_ENABLE_GROUP 517035168 -to ddr_ldm[0]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr_ldm[0]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr_odt[0]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr_udm[0]
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to ddr_udm[0]
set_instance_assignment -name OUTPUT_ENABLE_GROUP 517035168 -to ddr_udm[0]
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
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to adc_pdwn
set_instance_assignment -name IO_STANDARD LVDS -to adc_fco_p
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.8-V SSTL CLASS I" -to ddr_dqs[0]
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.8-V SSTL CLASS I" -to ddr_dqs[1]
