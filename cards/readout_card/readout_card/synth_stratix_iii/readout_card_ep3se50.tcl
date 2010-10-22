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

# $Id: readout_card_ep3se50.tcl,v 1.14 2010/10/21 18:04:06 mandana Exp $



# print welcome message
puts ""
puts "-----------------------------------------"
puts "Readout Card Rev D/E Pin Assignment Script"
puts "-----------------------------------------"

# Run DDR tcl assignments first
cd ../../ddr2_sdram_ctrl/source/rtl/
source micron_ctrl_pin_assignments.tcl
cd ../../../readout_card/synth_stratix_iii/


# include Quartus Tcl API
package require ::quartus::flow
package require ::quartus::project_ui

# get entity name
set top_name [get_project_settings -cmp]
puts "Info: Top-level entity is $top_name."

set_global_assignment -name FAMILY "Stratix III"
set_global_assignment -name DEVICE EP3SE50F780C4
set_global_assignment -name RESERVE_ALL_UNUSED_PINS "AS INPUT TRI-STATED"
puts "   Assigned: EP3SE50 device parameters."

puts "\n Assigning Pins:"


# assign PLL pins
# PLL_T1_in     = CLK       (from crystal via CPLD)
# PLL_T1_out[3] = TP17
# PLL_R2_in     = adc_fco    
# PLL_B1_out    = adc_clk   (taking advantage of a PLL output)
# PLL_B1_in     = CLK
# PLL_B1_out    =
# PLL_L2_in     = CLK0 (for ddr)
# PLL_L2_out[0] = ddr mictor

set_location_assignment Pin_P19 -to pll_l2_out[0]
set_location_assignment PIN_G16 -to pll_t1_out[3]


#####################################################
## rs232 interface
puts "Info: Assigning: RS232 pins."
#####################################################
set_location_assignment Pin_M23 -to rs232_tx
set_location_assignment Pin_M22 -to rs232_rx

#####################################################
## EEPROM pins
puts "Info: Assigning EEPROM pins."
#####################################################
set_location_assignment Pin_M20 -to eeprom_si 
set_location_assignment Pin_K28 -to eeprom_so 
set_location_assignment Pin_N20 -to eeprom_sck
set_location_assignment Pin_L25 -to eeprom_cs_n

#####################################################
## misc pins
puts "   Assigning miscellaneous pins."
#####################################################

# Note that crc_error_out is special fpga pin ...set_location_assignment PIN_P23 -to ~ALTERA_CRC_ERROR~
set_location_assignment Pin_P23  -to  crc_error_out
set_location_assignment Pin_T23  -to  crc_error_in
set_location_assignment Pin_M24  -to  critical_error 
set_location_assignment Pin_AH12 -to  extend_n 
#set_location_assignment PIN_AC28 -to ddr_shutdown_n

#####################################################
# Clocks and Resets
puts "Info: Assigning Main Clock and Resets"
#####################################################
# inclk on board is connected to pins (n26/p28/u28, ag15, u2, b14/d14) or ck0/ck1/ck2(PLL_L2), ck5(PLL_B1), ck9(PLL_R2), ck12/ck13(PLL_T1)
# In order to free up Left/right PLLs for DDR and altlvds (serdes), we move to PLL_T1.
set_location_assignment PIN_B14 -to inclk
set_location_assignment PIN_AE14 -to inclk6

# dev_clr_n (PIN_N24)is also tied to clk3 or dev_clr_gclk_n (PIN_R27) to be able to take advantage of global routing
set_location_assignment PIN_R27 -to dev_clr_gclk_n
set_location_assignment PIN_N24 -to dev_clr_n
# dev_clr_fpga_out_n is assigned to be able to reset the board by asserting dev_clr_n
set_location_assignment PIN_M25 -to dev_clr_fpga_out_n

set_location_assignment PIN_AF10 -to wdog

#####################################################
# LVDS
puts "Info: Assigning Backplane communication LVDS lines"
#####################################################
set_location_assignment PIN_AE11 -to lvds_spare
set_location_assignment PIN_B11 -to lvds_txa
set_location_assignment PIN_A10 -to lvds_txb
set_location_assignment PIN_AD12 -to lvds_sync
set_location_assignment PIN_AE12 -to lvds_cmd


#####################################################
# Miscellaneous
puts "Info: Assigning Miscellaneous"
#####################################################
set_location_assignment PIN_L26 -to card_id

set_location_assignment PIN_AC12 -to slot_id[0]
set_location_assignment PIN_AF12 -to slot_id[1]
set_location_assignment PIN_AG12 -to slot_id[2]
set_location_assignment PIN_AH10 -to slot_id[3]
 
set_location_assignment PIN_AE9 -to dip_sw0
set_location_assignment PIN_U26 -to dip_sw1
set_location_assignment PIN_V26 -to dip_sw2
set_location_assignment PIN_AH9 -to dip_sw3

# FPGA Temperature
set_location_assignment PIN_M26 -to smb_nalert
set_location_assignment PIN_L28 -to smb_clk
set_location_assignment PIN_M28 -to smb_data


#####################################################
# TTL Backplane Spares
puts "Info: Assigning TTL Backplane Spares"
#####################################################
set_location_assignment PIN_T28 -to ttl_dir1
set_location_assignment PIN_R25 -to ttl_dir2
set_location_assignment PIN_F12 -to ttl_dir3
set_location_assignment PIN_A14 -to ttl_in1
set_location_assignment PIN_A13 -to ttl_in2
set_location_assignment PIN_A11 -to ttl_in3
set_location_assignment PIN_R26 -to ttl_out1
set_location_assignment PIN_C10 -to ttl_out2
set_location_assignment PIN_Y14 -to ttl_out3



#####################################################
# ADC
puts "Info: Assigning ADC"
#####################################################
# data lines on bank 5A
set_location_assignment PIN_W4 -to adc0_lvds
set_location_assignment PIN_W2 -to adc1_lvds
set_location_assignment PIN_Y2 -to adc2_lvds
set_location_assignment PIN_AB2 -to adc3_lvds
set_location_assignment PIN_AC2 -to adc4_lvds
set_location_assignment PIN_AD1 -to adc5_lvds
set_location_assignment PIN_L2 -to adc6_lvds
set_location_assignment PIN_AF2 -to adc7_lvds

set_instance_assignment -name INPUT_TERMINATION DIFFERENTIAL -to adc7_lvds
set_instance_assignment -name INPUT_TERMINATION DIFFERENTIAL -to adc6_lvds
set_instance_assignment -name INPUT_TERMINATION DIFFERENTIAL -to adc5_lvds
set_instance_assignment -name INPUT_TERMINATION DIFFERENTIAL -to adc4_lvds
set_instance_assignment -name INPUT_TERMINATION DIFFERENTIAL -to adc3_lvds
set_instance_assignment -name INPUT_TERMINATION DIFFERENTIAL -to adc2_lvds
set_instance_assignment -name INPUT_TERMINATION DIFFERENTIAL -to adc1_lvds
set_instance_assignment -name INPUT_TERMINATION DIFFERENTIAL -to adc0_lvds


# adc clock lines are on bank 3C to take advantage of the clk_out lines for the bottom PLL
set_location_assignment PIN_Y15 -to adc_clk

# adc_dco is tied to clk10 (unterminated) of PLL_R2
set_location_assignment PIN_P2 -to adc_dco

# adc_fco is tied to clk11 (terminated) of PLL_R2
set_location_assignment PIN_M1 -to adc_fco
set_instance_assignment -name INPUT_TERMINATION DIFFERENTIAL -to adc_fco

# control signals on bank 2A
set_location_assignment PIN_AF28 -to adc_sclk
set_location_assignment PIN_AC25 -to adc_sdio
set_location_assignment PIN_AC26 -to adc_csb_n
set_location_assignment PIN_AB27 -to adc_pdwn

#####################################################
# DDR2 SDRAM
puts "Info: Assigning DDR2 SDRAM"
#####################################################
set_location_assignment PIN_D27 -to termination_blk0~_rup_pad
set_location_assignment PIN_C28 -to termination_blk0~_rdn_pad
set_location_assignment PIN_U28 -to inclk_ddr
set_location_assignment PIN_AD22 -to mem_dqs[0]
set_location_assignment PIN_AH23 -to mem_dqs[1]
set_location_assignment PIN_AF26 -to mem_dm[0]
set_location_assignment PIN_AD19 -to mem_odt[0]
set_location_assignment PIN_AD24 -to mem_dm[1]
set_location_assignment PIN_AB24 -to mem_ba[0]
set_location_assignment PIN_AD27 -to mem_ba[1]
set_location_assignment PIN_AC19 -to mem_cas_n
set_location_assignment PIN_AA18 -to mem_cke[0]
set_location_assignment PIN_AF20 -to mem_cs_n[0]
set_location_assignment PIN_AD18 -to mem_ras_n
set_location_assignment PIN_AB19 -to mem_we_n
set_location_assignment PIN_AE27 -to mem_clk[0]

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
set_location_assignment PIN_AB13 -to test_status[1]
set_location_assignment PIN_AG7 -to test_status[2]
set_location_assignment PIN_AG9 -to test_status[3]
set_location_assignment PIN_C20 -to test_status[4]
set_location_assignment PIN_AB9 -to test_status[5]
set_location_assignment PIN_AB11 -to test_status[6]
set_location_assignment PIN_AE10 -to test_status[7]



#####################################################
# LEDs
puts "Info: Assigning LEDs"
#####################################################
set_location_assignment PIN_AH13 -to grn_led
set_location_assignment PIN_AG10 -to red_led
set_location_assignment PIN_AH11 -to ylw_led

#####################################################
# Feedback, Offset, and Bias DACS
puts "Info: Assigning Feedback, Offset, and Bias DACS"
#####################################################
##dac_clr_n clears parallel and serial dacs
set_location_assignment Pin_AH6 -to dac_clr_n

set_location_assignment PIN_J4 -to dac_clk[0]
set_location_assignment PIN_G5 -to dac_clk[1]
set_location_assignment PIN_T8 -to dac_clk[2]
set_location_assignment PIN_T5 -to dac_clk[3]
set_location_assignment PIN_U3 -to dac_clk[4]
set_location_assignment PIN_T3 -to dac_clk[5]
set_location_assignment PIN_U8 -to dac_clk[6]
set_location_assignment PIN_U7 -to dac_clk[7]

set_location_assignment PIN_E5 -to dac_dat[0]
set_location_assignment PIN_E11 -to dac_dat[1]
set_location_assignment PIN_T9 -to dac_dat[2]
set_location_assignment PIN_K5 -to dac_dat[3]
set_location_assignment PIN_U4 -to dac_dat[4]
set_location_assignment PIN_V3 -to dac_dat[5]
set_location_assignment PIN_U5 -to dac_dat[6]
set_location_assignment PIN_U6 -to dac_dat[7]

set_location_assignment PIN_D10 -to bias_dac_ncs[0]
set_location_assignment PIN_D5 -to bias_dac_ncs[1]
set_location_assignment PIN_T6 -to bias_dac_ncs[2]
set_location_assignment PIN_R9 -to bias_dac_ncs[3]
set_location_assignment PIN_AE6 -to bias_dac_ncs[4]
set_location_assignment PIN_T4 -to bias_dac_ncs[5]
set_location_assignment PIN_AH4 -to bias_dac_ncs[6]
set_location_assignment PIN_AH5 -to bias_dac_ncs[7]

set_location_assignment PIN_C3 -to offset_dac_ncs[0]
set_location_assignment PIN_H11 -to offset_dac_ncs[1]
set_location_assignment PIN_J11 -to offset_dac_ncs[2]
set_location_assignment PIN_E8 -to offset_dac_ncs[3]
set_location_assignment PIN_R4 -to offset_dac_ncs[4]
set_location_assignment PIN_V4 -to offset_dac_ncs[5]
set_location_assignment PIN_AH3 -to offset_dac_ncs[6]
set_location_assignment PIN_AH2 -to offset_dac_ncs[7]

set_location_assignment PIN_F17 -to dac_dfb_clk[0]
set_location_assignment PIN_A27 -to dac_dfb_clk[1]
set_location_assignment PIN_F1 -to dac_dfb_clk[2]
set_location_assignment PIN_A17 -to dac_dfb_clk[3]
set_location_assignment PIN_C17 -to dac_dfb_clk[4]
set_location_assignment PIN_G2 -to dac_dfb_clk[5]
set_location_assignment PIN_J3 -to dac_dfb_clk[6]
set_location_assignment PIN_H6 -to dac_dfb_clk[7]

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
set_location_assignment PIN_D12 -to dac2_dfb_dat[3]
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
set_location_assignment PIN_E10 -to dac5_dfb_dat[2]
set_location_assignment PIN_F10 -to dac5_dfb_dat[3]
set_location_assignment PIN_G10 -to dac5_dfb_dat[4]
set_location_assignment PIN_H10 -to dac5_dfb_dat[5]
set_location_assignment PIN_F8 -to dac5_dfb_dat[6]
set_location_assignment PIN_A12 -to dac5_dfb_dat[7]
set_location_assignment PIN_G9 -to dac5_dfb_dat[8]
set_location_assignment PIN_G8 -to dac5_dfb_dat[9]
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
set_location_assignment PIN_L8 -to dac7_dfb_dat[5]
set_location_assignment PIN_K9 -to dac7_dfb_dat[6]
set_location_assignment PIN_K8 -to dac7_dfb_dat[7]
set_location_assignment PIN_K4 -to dac7_dfb_dat[8]
set_location_assignment PIN_L9 -to dac7_dfb_dat[9]
set_location_assignment PIN_K6 -to dac7_dfb_dat[10]
set_location_assignment PIN_K7 -to dac7_dfb_dat[11]
set_location_assignment PIN_J6 -to dac7_dfb_dat[12]
set_location_assignment PIN_H5 -to dac7_dfb_dat[13]

set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to termination_blk0~_rup_pad
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to termination_blk0~_rdn_pad
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to mem_cke[0]
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to mem_dm[0]
set_instance_assignment -name OUTPUT_ENABLE_GROUP 517035168 -to mem_dm[0]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to mem_dm[0]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to mem_odt[0]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to mem_dm[1]
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to mem_dm[1]
set_instance_assignment -name OUTPUT_ENABLE_GROUP 517035168 -to mem_dm[1]
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to mem_odt[0]
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.8-V SSTL CLASS I" -to mem_clk[0]
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITHOUT CALIBRATION" -to mem_clk[0]
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to mem_cs_n[0]
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
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to mem_dqs[0]
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to mem_dqs[1]
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
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to adc_sclk
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to adc_sdio
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to adc_csb_n
set_instance_assignment -name IO_STANDARD LVDS -to adc0_lvds
set_instance_assignment -name IO_STANDARD LVDS -to adc1_lvds
set_instance_assignment -name IO_STANDARD LVDS -to adc2_lvds
set_instance_assignment -name IO_STANDARD LVDS -to adc3_lvds
set_instance_assignment -name IO_STANDARD LVDS -to adc4_lvds
set_instance_assignment -name IO_STANDARD LVDS -to adc5_lvds
set_instance_assignment -name IO_STANDARD LVDS -to adc6_lvds
set_instance_assignment -name IO_STANDARD LVDS -to adc7_lvds
set_instance_assignment -name IO_STANDARD LVDS -to adc_clk
set_instance_assignment -name IO_STANDARD LVDS -to adc_dco
set_instance_assignment -name IO_STANDARD LVDS -to adc_fco
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to adc_pdwn
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to mem_cs_n[0]
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.8-V SSTL CLASS I" -to mem_dqs[0]
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.8-V SSTL CLASS I" -to mem_dqs[1]

# recompile to commit
puts "\nInfo: Recompiling to commit assignments..."
execute_flow -compile

puts "\nInfo: Generating .pof file after waiting 10s to let compilation finish."
after 10000 "exec quartus_cpf -c readout_card_sof2jic.cof"

puts "\nInfo: Process completed."