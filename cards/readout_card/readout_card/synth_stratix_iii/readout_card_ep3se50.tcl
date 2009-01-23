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

# print welcome message
puts "\n\nReadout Card Rev C Pin Assignment Script v1.0"
puts "--------------------------------------------------"

# include Quartus Tcl API
package require ::quartus::project
package require ::quartus::flow

# get entity name
set top_name [get_project_settings -cmp]
puts "\nInfo: Top-level entity is $top_name."

puts "\nInfo: Assigning pins:"

set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to mem_odt[0]
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to mem_odt[0]
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.8-V SSTL CLASS I" -to mem_clk[0]
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITHOUT CALIBRATION" -to mem_clk[0]
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.8-V SSTL CLASS I" -to mem_clk_n[0]
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITHOUT CALIBRATION" -to mem_clk_n[0]
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
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.8-V SSTL CLASS I" -to mem_dqsn[0]
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to mem_dqsn[0]
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.8-V SSTL CLASS I" -to mem_dqsn[1]
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to mem_dqsn[1]
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
set_instance_assignment -name OUTPUT_ENABLE_GROUP 517035168 -to mem_dqsn[0]
set_instance_assignment -name OUTPUT_ENABLE_GROUP 517035168 -to mem_dqsn[1]
set_instance_assignment -name OUTPUT_ENABLE_GROUP 517035168 -to mem_dm[0]
set_instance_assignment -name OUTPUT_ENABLE_GROUP 517035168 -to mem_dm[1]
#set_location_assignment PIN_F17 -to adc1_ovr
#set_location_assignment PIN_B25 -to adc2_ovr
#set_location_assignment PIN_D23 -to adc3_ovr
#set_location_assignment PIN_AE7 -to adc4_ovr
#set_location_assignment PIN_C12 -to adc5_ovr
#set_location_assignment PIN_AB3 -to adc6_ovr
#set_location_assignment PIN_R1 -to adc7_ovr
#set_location_assignment PIN_E13 -to adc8_ovr
#set_location_assignment PIN_B19 -to adc1_rdy
#set_location_assignment PIN_H20 -to adc2_rdy
#set_location_assignment PIN_D24 -to adc3_rdy
#set_location_assignment PIN_AE5 -to adc4_rdy
#set_location_assignment PIN_D20 -to adc5_rdy
#set_location_assignment PIN_D13 -to adc6_rdy
#set_location_assignment PIN_AC7 -to adc7_rdy
#set_location_assignment PIN_AF5 -to adc8_rdy
#set_location_assignment PIN_AE4 -to adc1_clk
#set_location_assignment PIN_A22 -to adc2_clk
#set_location_assignment PIN_D16 -to adc3_clk
#set_location_assignment PIN_Y6 -to adc4_clk
#set_location_assignment PIN_E17 -to adc5_clk
#set_location_assignment PIN_C19 -to adc6_clk
#set_location_assignment PIN_C18 -to adc7_clk
#set_location_assignment PIN_G16 -to adc8_clk
#################################################
set_location_assignment PIN_AB11 -to adc1_clk
set_location_assignment PIN_AH2  -to adc1_dat[0]           
set_location_assignment PIN_Y4   -to adc1_dat[10]          
set_location_assignment PIN_Y5   -to adc1_dat[11]          
set_location_assignment PIN_AA4  -to adc1_dat[12]          
set_location_assignment PIN_Y7   -to adc1_dat[13]          
set_location_assignment PIN_AH5  -to adc1_dat[1]           
set_location_assignment PIN_AH4  -to adc1_dat[2]           
set_location_assignment PIN_J12  -to adc1_dat[3]           
set_location_assignment PIN_J11  -to adc1_dat[4]           
set_location_assignment PIN_AB7  -to adc1_dat[5]           
set_location_assignment PIN_M27  -to adc1_dat[6]           
set_location_assignment PIN_W5   -to adc1_dat[7]           
set_location_assignment PIN_W9   -to adc1_dat[8]           
set_location_assignment PIN_W8   -to adc1_dat[9]           
set_location_assignment PIN_B10  -to adc1_ovr              
set_location_assignment PIN_C13  -to adc1_rdy              
set_location_assignment PIN_AC10 -to adc2_clk              
set_location_assignment PIN_H10  -to adc2_dat[0]           
set_location_assignment PIN_K4   -to adc2_dat[10]          
set_location_assignment PIN_K5   -to adc2_dat[11]          
set_location_assignment PIN_K6   -to adc2_dat[12]          
set_location_assignment PIN_K7   -to adc2_dat[13]          
set_location_assignment PIN_F10  -to adc2_dat[1]           
set_location_assignment PIN_E10  -to adc2_dat[2]           
set_location_assignment PIN_D9   -to adc2_dat[3]           
set_location_assignment PIN_D8   -to adc2_dat[4]           
set_location_assignment PIN_AC7  -to adc2_dat[5]           
set_location_assignment PIN_K28  -to adc2_dat[6]           
set_location_assignment PIN_L8   -to adc2_dat[7]           
set_location_assignment PIN_L9   -to adc2_dat[8]           
set_location_assignment PIN_J4   -to adc2_dat[9]           
set_location_assignment PIN_C10  -to adc2_ovr              
set_location_assignment PIN_D12  -to adc2_rdy              
set_location_assignment PIN_Y10  -to adc3_clk              
set_location_assignment PIN_Y9   -to adc3_dat[0]           
set_location_assignment PIN_W4   -to adc3_dat[10]          
set_location_assignment PIN_V7   -to adc3_dat[11]          
set_location_assignment PIN_V6   -to adc3_dat[12]          
set_location_assignment PIN_W6   -to adc3_dat[13]          
set_location_assignment PIN_AB9  -to adc3_dat[1]           
set_location_assignment PIN_AA9  -to adc3_dat[2]           
set_location_assignment PIN_AC9  -to adc3_dat[3]           
set_location_assignment PIN_AD9  -to adc3_dat[4]           
set_location_assignment PIN_M23  -to adc3_dat[5]           
set_location_assignment PIN_N23  -to adc3_dat[6]           
set_location_assignment PIN_P9   -to adc3_dat[7]           
set_location_assignment PIN_P1   -to adc3_dat[8]           
set_location_assignment PIN_P2   -to adc3_dat[9]           
set_location_assignment PIN_A10  -to adc3_ovr              
set_location_assignment PIN_G12  -to adc3_rdy              
set_location_assignment PIN_Y11  -to adc4_clk              
set_location_assignment PIN_J10  -to adc4_dat[0]           
set_location_assignment PIN_H5   -to adc4_dat[10]          
set_location_assignment PIN_J6   -to adc4_dat[11]          
set_location_assignment PIN_K8   -to adc4_dat[12]          
set_location_assignment PIN_K9   -to adc4_dat[13]          
set_location_assignment PIN_H11  -to adc4_dat[1]           
set_location_assignment PIN_E11  -to adc4_dat[2]           
set_location_assignment PIN_D10  -to adc4_dat[3]           
set_location_assignment PIN_G10  -to adc4_dat[4]           
set_location_assignment PIN_AD7  -to adc4_dat[5]           
set_location_assignment PIN_M28  -to adc4_dat[6]           
set_location_assignment PIN_Y6   -to adc4_dat[7]           
set_location_assignment PIN_G5   -to adc4_dat[8]           
set_location_assignment PIN_H6   -to adc4_dat[9]           
set_location_assignment PIN_B11  -to adc4_ovr              
set_location_assignment PIN_F12  -to adc4_rdy              
set_location_assignment PIN_AG9  -to adc5_clk              
set_location_assignment PIN_F9   -to adc5_dat[0]           
set_location_assignment PIN_AC16 -to adc5_dat[10]          
set_location_assignment PIN_AB17 -to adc5_dat[11]          
set_location_assignment PIN_AE17 -to adc5_dat[12]          
set_location_assignment PIN_AF16 -to adc5_dat[13]          
set_location_assignment PIN_D5   -to adc5_dat[1]           
set_location_assignment PIN_E5   -to adc5_dat[2]           
set_location_assignment PIN_D6   -to adc5_dat[3]           
set_location_assignment PIN_F8   -to adc5_dat[4]           
set_location_assignment PIN_AC8  -to adc5_dat[5]           
set_location_assignment PIN_M20  -to adc5_dat[6]           
set_location_assignment PIN_AG15 -to adc5_dat[7]           
set_location_assignment PIN_AH16 -to adc5_dat[8]           
set_location_assignment PIN_AA15 -to adc5_dat[9]           
set_location_assignment PIN_C12  -to adc5_ovr              
set_location_assignment PIN_F13  -to adc5_rdy              
set_location_assignment PIN_AH8  -to adc6_clk              
set_location_assignment PIN_C14  -to adc6_dat[0]           
set_location_assignment PIN_N26  -to adc6_dat[10]          
set_location_assignment PIN_N27  -to adc6_dat[11]          
set_location_assignment PIN_P19  -to adc6_dat[12]          
set_location_assignment PIN_P20  -to adc6_dat[13]          
set_location_assignment PIN_B14  -to adc6_dat[1]           
set_location_assignment PIN_A14  -to adc6_dat[2]           
set_location_assignment PIN_B13  -to adc6_dat[3]           
set_location_assignment PIN_A13  -to adc6_dat[4]           
set_location_assignment PIN_AF5  -to adc6_dat[5]           
set_location_assignment PIN_L25  -to adc6_dat[6]           
set_location_assignment PIN_AF19 -to adc6_dat[7]           
set_location_assignment PIN_P28  -to adc6_dat[8]           
set_location_assignment PIN_N28  -to adc6_dat[9]           
set_location_assignment PIN_D11  -to adc6_ovr              
set_location_assignment PIN_G13  -to adc6_rdy              
set_location_assignment PIN_AH9  -to adc7_clk              
set_location_assignment PIN_AE5  -to adc7_dat[0]           
set_location_assignment PIN_N8   -to adc7_dat[10]          
set_location_assignment PIN_N6   -to adc7_dat[11]          
set_location_assignment PIN_N7   -to adc7_dat[12]          
set_location_assignment PIN_P8   -to adc7_dat[13]          
set_location_assignment PIN_AE7  -to adc7_dat[1]           
set_location_assignment PIN_AE4  -to adc7_dat[2]           
set_location_assignment PIN_AE6  -to adc7_dat[3]           
set_location_assignment PIN_AA10 -to adc7_dat[4]           
set_location_assignment PIN_M22  -to adc7_dat[5]           
set_location_assignment PIN_P25  -to adc7_dat[6]           
set_location_assignment PIN_R9   -to adc7_dat[7]           
set_location_assignment PIN_T9   -to adc7_dat[8]           
set_location_assignment PIN_U9   -to adc7_dat[9]           
set_location_assignment PIN_E13  -to adc7_ovr              
set_location_assignment PIN_H14  -to adc7_rdy              
set_location_assignment PIN_AE9  -to adc8_clk              
set_location_assignment PIN_E8   -to adc8_dat[0]           
set_location_assignment PIN_AH18 -to adc8_dat[10]          
set_location_assignment PIN_AG18 -to adc8_dat[11]          
set_location_assignment PIN_AH19 -to adc8_dat[12]          
set_location_assignment PIN_AG19 -to adc8_dat[13]          
set_location_assignment PIN_G9   -to adc8_dat[1]           
set_location_assignment PIN_G8   -to adc8_dat[2]           
set_location_assignment PIN_E7   -to adc8_dat[3]           
set_location_assignment PIN_D14  -to adc8_dat[4]           
set_location_assignment PIN_AB8  -to adc8_dat[5]           
set_location_assignment PIN_M21  -to adc8_dat[6]           
set_location_assignment PIN_AE16 -to adc8_dat[7]           
set_location_assignment PIN_AE18 -to adc8_dat[8]           
set_location_assignment PIN_AF17 -to adc8_dat[9]           
set_location_assignment PIN_D13  -to adc8_ovr              
set_location_assignment PIN_J14  -to adc8_rdy              

####################################################
set_location_assignment PIN_V26 -to dip_sw3
set_location_assignment PIN_T21 -to dip_sw4
set_location_assignment PIN_AG3 -to wdog
set_location_assignment PIN_A11 -to mictor[0]
#set_location_assignment PIN_E16 -to mictor[1]
#set_location_assignment PIN_G20 -to mictor[2]
#set_location_assignment PIN_C24 -to mictor[3]
set_location_assignment PIN_AF6 -to mictor[4]
set_location_assignment PIN_AC3 -to mictor[5]
set_location_assignment PIN_A17 -to mictor[6]
set_location_assignment PIN_AD6 -to mictor[7]
set_location_assignment PIN_A18 -to mictor[8]
#set_location_assignment PIN_A21 -to mictor[9]
set_location_assignment PIN_A16 -to mictor[10]
#set_location_assignment PIN_A25 -to mictor[11]
#set_location_assignment PIN_E20 -to mictor[12]
#set_location_assignment PIN_G21 -to mictor[13]
#set_location_assignment PIN_A19 -to mictor[14]
#set_location_assignment PIN_D15 -to mictor[15]
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
set_location_assignment PIN_AF26 -to mem_dm[0]
set_location_assignment PIN_AD24 -to mem_dm[1]
set_location_assignment PIN_AD19 -to mem_odt[0]
set_location_assignment PIN_AD18 -to mem_ras_n
set_location_assignment PIN_AB19 -to mem_we_n
set_location_assignment PIN_AG16 -to pnf
set_location_assignment PIN_AG13 -to pnf_per_byte[0]
set_location_assignment PIN_AB16 -to pnf_per_byte[1]
set_location_assignment PIN_AE8 -to pnf_per_byte[2]
set_location_assignment PIN_AE15 -to pnf_per_byte[3]
set_location_assignment PIN_AD16 -to pnf_per_byte[4]
set_location_assignment PIN_AH17 -to pnf_per_byte[5]
set_location_assignment PIN_Y15 -to pnf_per_byte[6]
set_location_assignment PIN_AC17 -to pnf_per_byte[7]
set_location_assignment PIN_AG6 -to test_complete
set_location_assignment PIN_AF14 -to test_status[0]
set_location_assignment PIN_J15 -to test_status[1]
set_location_assignment PIN_AF15 -to test_status[2]
set_location_assignment PIN_AH15 -to test_status[3]
set_location_assignment PIN_C20 -to test_status[4]
set_location_assignment PIN_A12 -to test_status[5]
set_location_assignment PIN_R6 -to test_status[6]
set_location_assignment PIN_AE10 -to test_status[7]
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
set_location_assignment PIN_U2 -to inclk
set_location_assignment PIN_N21 -to ~ALTERA_DATA0~
set_location_assignment PIN_P23 -to ~ALTERA_CRC_ERROR~
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
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to mem_dqsn[0]
set_instance_assignment -name INPUT_TERMINATION "PARALLEL 50 OHM WITH CALIBRATION" -to mem_dqsn[1]

# assign rst_n
cmp add_assignment $top_name "" rst_n LOCATION "Pin_N24"
puts "   Assigned: RST_N pin."

# assign leds
cmp add_assignment $top_name "" red_led LOCATION "Pin_M25"
cmp add_assignment $top_name "" ylw_led LOCATION "Pin_N25"
cmp add_assignment $top_name "" grn_led LOCATION "Pin_M24"
puts "   Assigned: LED pins."

# assign dip switches
#cmp add_assignment $top_name "" dip0 LOCATION "Pin_T24"
#cmp add_assignment $top_name "" dip1 LOCATION "Pin_U26"
#cmp add_assignment $top_name "" dip2 LOCATION "Pin_V26"
#cmp add_assignment $top_name "" dip3 LOCATION "Pin_T21"
#puts "   Assigned: DIP switch pins."

# assign watchdog
#cmp add_assignment $top_name "" wdog LOCATION "Pin_A5"
#puts "   Assigned: Watchdog pin."


### reply lines to clock card (brx7a, brx7b)
cmp add_assignment $top_name "" lvds_txa LOCATION "Pin_AE12"
cmp add_assignment $top_name "" lvds_txb LOCATION "Pin_AG12"
cmp add_assignment $top_name "" lvds_sync LOCATION "Pin_AD12"
cmp add_assignment $top_name "" lvds_spare LOCATION "Pin_AE11"
cmp add_assignment $top_name "" lvds_cmd LOCATION "Pin_AC11"
puts "   Assigned: LVDS pins."

# assign SMB pins
cmp add_assignment $top_name "" smb_clk LOCATION "Pin_L28"
cmp add_assignment $top_name "" smb_data LOCATION "Pin_N20"
cmp add_assignment $top_name "" smb_nalert LOCATION "Pin_M26"
puts "   Assigned: SMB interface pins."
set_location_assignment PIN_L28 -to smb_clk
set_location_assignment PIN_M26 -to smb_nalert

# assign ID pins
cmp add_assignment $top_name "" "slot_id\[0\]" LOCATION "Pin_AC12"
cmp add_assignment $top_name "" "slot_id\[1\]" LOCATION "Pin_AF12"
cmp add_assignment $top_name "" "slot_id\[2\]" LOCATION "Pin_AF11"
cmp add_assignment $top_name "" "slot_id\[3\]" LOCATION "Pin_AF10"

cmp add_assignment $top_name "" card_id LOCATION "Pin_L26"
puts "   Assigned: ID pins."

# assign spare TTL
cmp add_assignment $top_name "" "ttl_dir1" LOCATION "Pin_AA13"
cmp add_assignment $top_name "" "ttl_in1" LOCATION "Pin_AH11"
cmp add_assignment $top_name "" "ttl_out1" LOCATION "Pin_AB13"

cmp add_assignment $top_name "" "ttl_dir2" LOCATION "Pin_AD13"
cmp add_assignment $top_name "" "ttl_in2" LOCATION "Pin_AH10"
cmp add_assignment $top_name "" "ttl_out2" LOCATION "Pin_AE13"

cmp add_assignment $top_name "" "ttl_dir3" LOCATION "Pin_Y13"
cmp add_assignment $top_name "" "ttl_in3" LOCATION "Pin_AG10"
cmp add_assignment $top_name "" "ttl_out3" LOCATION "Pin_Y14"
puts "   Assigned: Spare TTL pins."

# assign serial DAC
cmp add_assignment $top_name "" "dac_clk\[0\]" LOCATION "Pin_F4"
cmp add_assignment $top_name "" "dac_clk\[1\]" LOCATION "Pin_E17"
cmp add_assignment $top_name "" "dac_clk\[2\]" LOCATION "Pin_C9"
cmp add_assignment $top_name "" "dac_clk\[3\]" LOCATION "Pin_D19"
cmp add_assignment $top_name "" "dac_clk\[4\]" LOCATION "Pin_H19"
cmp add_assignment $top_name "" "dac_clk\[5\]" LOCATION "Pin_M6"
cmp add_assignment $top_name "" "dac_clk\[6\]" LOCATION "Pin_W3"
cmp add_assignment $top_name "" "dac_clk\[7\]" LOCATION "Pin_U7"
cmp add_assignment $top_name "" "dac_dat\[0\]" LOCATION "Pin_H3"
cmp add_assignment $top_name "" "dac_dat\[1\]" LOCATION "Pin_F17"
cmp add_assignment $top_name "" "dac_dat\[2\]" LOCATION "Pin_D7"
cmp add_assignment $top_name "" "dac_dat\[3\]" LOCATION "Pin_D20"
cmp add_assignment $top_name "" "dac_dat\[4\]" LOCATION "Pin_J18"
cmp add_assignment $top_name "" "dac_dat\[5\]" LOCATION "Pin_N9"
cmp add_assignment $top_name "" "dac_dat\[6\]" LOCATION "Pin_AC4"
cmp add_assignment $top_name "" "dac_dat\[7\]" LOCATION "Pin_U8"
cmp add_assignment $top_name "" "bias_dac_ncs\[0\]" LOCATION "Pin_H4"
cmp add_assignment $top_name "" "bias_dac_ncs\[1\]" LOCATION "Pin_D18"
cmp add_assignment $top_name "" "bias_dac_ncs\[2\]" LOCATION "Pin_C6"
cmp add_assignment $top_name "" "bias_dac_ncs\[3\]" LOCATION "Pin_C23"
cmp add_assignment $top_name "" "bias_dac_ncs\[4\]" LOCATION "Pin_D23"
cmp add_assignment $top_name "" "bias_dac_ncs\[5\]" LOCATION "Pin_N5"
cmp add_assignment $top_name "" "bias_dac_ncs\[6\]" LOCATION "Pin_AB3"
cmp add_assignment $top_name "" "bias_dac_ncs\[7\]" LOCATION "Pin_U5"
cmp add_assignment $top_name "" "offset_dac_ncs\[0\]" LOCATION "Pin_G4"
cmp add_assignment $top_name "" "offset_dac_ncs\[1\]" LOCATION "Pin_E16"
cmp add_assignment $top_name "" "offset_dac_ncs\[2\]" LOCATION "Pin_C8"
cmp add_assignment $top_name "" "offset_dac_ncs\[3\]" LOCATION "Pin_C24"
cmp add_assignment $top_name "" "offset_dac_ncs\[4\]" LOCATION "Pin_H20"
cmp add_assignment $top_name "" "offset_dac_ncs\[5\]" LOCATION "Pin_L6"
cmp add_assignment $top_name "" "offset_dac_ncs\[6\]" LOCATION "Pin_Y3"
cmp add_assignment $top_name "" "offset_dac_ncs\[7\]" LOCATION "Pin_T8"
puts "   Assigned: Serial DAC pins."

# assign parallel DAC
cmp add_assignment $top_name "" "dac_FB_clk\[0\]" LOCATION "Pin_B1"
cmp add_assignment $top_name "" "dac_FB1_dat\[0\]" LOCATION "Pin_C1"
cmp add_assignment $top_name "" "dac_FB1_dat\[1\]" LOCATION "Pin_D1"
cmp add_assignment $top_name "" "dac_FB1_dat\[2\]" LOCATION "Pin_E1"
cmp add_assignment $top_name "" "dac_FB1_dat\[3\]" LOCATION "Pin_F1"
cmp add_assignment $top_name "" "dac_FB1_dat\[4\]" LOCATION "Pin_G1"
cmp add_assignment $top_name "" "dac_FB1_dat\[5\]" LOCATION "Pin_H1"
cmp add_assignment $top_name "" "dac_FB1_dat\[6\]" LOCATION "Pin_J1"
cmp add_assignment $top_name "" "dac_FB1_dat\[7\]" LOCATION "Pin_H2"
cmp add_assignment $top_name "" "dac_FB1_dat\[8\]" LOCATION "Pin_G2"
cmp add_assignment $top_name "" "dac_FB1_dat\[9\]" LOCATION "Pin_E2"
cmp add_assignment $top_name "" "dac_FB1_dat\[10\]" LOCATION "Pin_D2"
cmp add_assignment $top_name "" "dac_FB1_dat\[11\]" LOCATION "Pin_G3"
cmp add_assignment $top_name "" "dac_FB1_dat\[12\]" LOCATION "Pin_F3"
cmp add_assignment $top_name "" "dac_FB1_dat\[13\]" LOCATION "Pin_J3"

cmp add_assignment $top_name "" "dac_FB_clk\[1\]" LOCATION "Pin_A15"
cmp add_assignment $top_name "" "dac_FB2_dat\[0\]" LOCATION "Pin_J16"
cmp add_assignment $top_name "" "dac_FB2_dat\[1\]" LOCATION "Pin_G16"
cmp add_assignment $top_name "" "dac_FB2_dat\[2\]" LOCATION "Pin_H16"
cmp add_assignment $top_name "" "dac_FB2_dat\[3\]" LOCATION "Pin_A19"
cmp add_assignment $top_name "" "dac_FB2_dat\[4\]" LOCATION "Pin_B16"
cmp add_assignment $top_name "" "dac_FB2_dat\[5\]" LOCATION "Pin_B17"
cmp add_assignment $top_name "" "dac_FB2_dat\[6\]" LOCATION "Pin_B19"
cmp add_assignment $top_name "" "dac_FB2_dat\[7\]" LOCATION "Pin_C15"
cmp add_assignment $top_name "" "dac_FB2_dat\[8\]" LOCATION "Pin_C17"
cmp add_assignment $top_name "" "dac_FB2_dat\[9\]" LOCATION "Pin_C18"
cmp add_assignment $top_name "" "dac_FB2_dat\[10\]" LOCATION "Pin_C19"
cmp add_assignment $top_name "" "dac_FB2_dat\[11\]" LOCATION "Pin_D15"
cmp add_assignment $top_name "" "dac_FB2_dat\[12\]" LOCATION "Pin_D16"
cmp add_assignment $top_name "" "dac_FB2_dat\[13\]" LOCATION "Pin_D17"

cmp add_assignment $top_name "" "dac_FB_clk\[2\]" LOCATION "Pin_A2"
cmp add_assignment $top_name "" "dac_FB3_dat\[0\]" LOCATION "Pin_A3"
cmp add_assignment $top_name "" "dac_FB3_dat\[1\]" LOCATION "Pin_A4"
cmp add_assignment $top_name "" "dac_FB3_dat\[2\]" LOCATION "Pin_A5"
cmp add_assignment $top_name "" "dac_FB3_dat\[3\]" LOCATION "Pin_A6"
cmp add_assignment $top_name "" "dac_FB3_dat\[4\]" LOCATION "Pin_A7"
cmp add_assignment $top_name "" "dac_FB3_dat\[5\]" LOCATION "Pin_A8"
cmp add_assignment $top_name "" "dac_FB3_dat\[6\]" LOCATION "Pin_A9"
cmp add_assignment $top_name "" "dac_FB3_dat\[7\]" LOCATION "Pin_B2"
cmp add_assignment $top_name "" "dac_FB3_dat\[8\]" LOCATION "Pin_B4"
cmp add_assignment $top_name "" "dac_FB3_dat\[9\]" LOCATION "Pin_B5"
cmp add_assignment $top_name "" "dac_FB3_dat\[10\]" LOCATION "Pin_B7"
cmp add_assignment $top_name "" "dac_FB3_dat\[11\]" LOCATION "Pin_B8"
cmp add_assignment $top_name "" "dac_FB3_dat\[12\]" LOCATION "Pin_C3"
cmp add_assignment $top_name "" "dac_FB3_dat\[13\]" LOCATION "Pin_C5"

cmp add_assignment $top_name "" "dac_FB_clk\[3\]" LOCATION "Pin_A20"
cmp add_assignment $top_name "" "dac_FB4_dat\[0\]" LOCATION "Pin_J19"
cmp add_assignment $top_name "" "dac_FB4_dat\[1\]" LOCATION "Pin_A22"
cmp add_assignment $top_name "" "dac_FB4_dat\[2\]" LOCATION "Pin_A23"
cmp add_assignment $top_name "" "dac_FB4_dat\[3\]" LOCATION "Pin_A21"
cmp add_assignment $top_name "" "dac_FB4_dat\[4\]" LOCATION "Pin_J20"
cmp add_assignment $top_name "" "dac_FB4_dat\[5\]" LOCATION "Pin_A26"
cmp add_assignment $top_name "" "dac_FB4_dat\[6\]" LOCATION "Pin_A27"
cmp add_assignment $top_name "" "dac_FB4_dat\[7\]" LOCATION "Pin_B22"
cmp add_assignment $top_name "" "dac_FB4_dat\[8\]" LOCATION "Pin_B23"
cmp add_assignment $top_name "" "dac_FB4_dat\[9\]" LOCATION "Pin_B20"
cmp add_assignment $top_name "" "dac_FB4_dat\[10\]" LOCATION "Pin_B25"
cmp add_assignment $top_name "" "dac_FB4_dat\[11\]" LOCATION "Pin_B26"
cmp add_assignment $top_name "" "dac_FB4_dat\[12\]" LOCATION "Pin_A25"
cmp add_assignment $top_name "" "dac_FB4_dat\[13\]" LOCATION "Pin_C21"

cmp add_assignment $top_name "" "dac_FB_clk\[4\]" LOCATION "Pin_D21"
cmp add_assignment $top_name "" "dac_FB5_dat\[0\]" LOCATION "Pin_D22"
cmp add_assignment $top_name "" "dac_FB5_dat\[1\]" LOCATION "Pin_D24"
cmp add_assignment $top_name "" "dac_FB5_dat\[2\]" LOCATION "Pin_D25"
cmp add_assignment $top_name "" "dac_FB5_dat\[3\]" LOCATION "Pin_E22"
cmp add_assignment $top_name "" "dac_FB5_dat\[4\]" LOCATION "Pin_E23"
cmp add_assignment $top_name "" "dac_FB5_dat\[5\]" LOCATION "Pin_E20"
cmp add_assignment $top_name "" "dac_FB5_dat\[6\]" LOCATION "Pin_F19"
cmp add_assignment $top_name "" "dac_FB5_dat\[7\]" LOCATION "Pin_F20"
cmp add_assignment $top_name "" "dac_FB5_dat\[8\]" LOCATION "Pin_F21"
cmp add_assignment $top_name "" "dac_FB5_dat\[9\]" LOCATION "Pin_F22"
cmp add_assignment $top_name "" "dac_FB5_dat\[10\]" LOCATION "Pin_G18"
cmp add_assignment $top_name "" "dac_FB5_dat\[11\]" LOCATION "Pin_G20"
cmp add_assignment $top_name "" "dac_FB5_dat\[12\]" LOCATION "Pin_G21"
cmp add_assignment $top_name "" "dac_FB5_dat\[13\]" LOCATION "Pin_G22"

cmp add_assignment $top_name "" "dac_FB_clk\[5\]" LOCATION "Pin_K1"
cmp add_assignment $top_name "" "dac_FB6_dat\[0\]" LOCATION "Pin_L1"
cmp add_assignment $top_name "" "dac_FB6_dat\[1\]" LOCATION "Pin_N1"
cmp add_assignment $top_name "" "dac_FB6_dat\[2\]" LOCATION "Pin_M1"
cmp add_assignment $top_name "" "dac_FB6_dat\[3\]" LOCATION "Pin_K2"
cmp add_assignment $top_name "" "dac_FB6_dat\[4\]" LOCATION "Pin_L2"
cmp add_assignment $top_name "" "dac_FB6_dat\[5\]" LOCATION "Pin_N2"
cmp add_assignment $top_name "" "dac_FB6_dat\[6\]" LOCATION "Pin_L3"
cmp add_assignment $top_name "" "dac_FB6_dat\[7\]" LOCATION "Pin_P3"
cmp add_assignment $top_name "" "dac_FB6_dat\[8\]" LOCATION "Pin_M3"
cmp add_assignment $top_name "" "dac_FB6_dat\[9\]" LOCATION "Pin_L4"
cmp add_assignment $top_name "" "dac_FB6_dat\[10\]" LOCATION "Pin_P4"
cmp add_assignment $top_name "" "dac_FB6_dat\[11\]" LOCATION "Pin_M4"
cmp add_assignment $top_name "" "dac_FB6_dat\[12\]" LOCATION "Pin_N4"
cmp add_assignment $top_name "" "dac_FB6_dat\[13\]" LOCATION "Pin_L5"

cmp add_assignment $top_name "" "dac_FB_clk\[6\]" LOCATION "Pin_AG1"
cmp add_assignment $top_name "" "dac_FB7_dat\[0\]" LOCATION "Pin_AF1"
cmp add_assignment $top_name "" "dac_FB7_dat\[1\]" LOCATION "Pin_AE1"
cmp add_assignment $top_name "" "dac_FB7_dat\[2\]" LOCATION "Pin_AD1"
cmp add_assignment $top_name "" "dac_FB7_dat\[3\]" LOCATION "Pin_AC1"
cmp add_assignment $top_name "" "dac_FB7_dat\[4\]" LOCATION "Pin_AA1"
cmp add_assignment $top_name "" "dac_FB7_dat\[5\]" LOCATION "Pin_AB1"
cmp add_assignment $top_name "" "dac_FB7_dat\[6\]" LOCATION "Pin_Y1"
cmp add_assignment $top_name "" "dac_FB7_dat\[7\]" LOCATION "Pin_AE2"
cmp add_assignment $top_name "" "dac_FB7_dat\[8\]" LOCATION "Pin_AF2"
cmp add_assignment $top_name "" "dac_FB7_dat\[9\]" LOCATION "Pin_AC2"
cmp add_assignment $top_name "" "dac_FB7_dat\[10\]" LOCATION "Pin_AB2"
cmp add_assignment $top_name "" "dac_FB7_dat\[11\]" LOCATION "Pin_Y2"
cmp add_assignment $top_name "" "dac_FB7_dat\[12\]" LOCATION "Pin_W2"
cmp add_assignment $top_name "" "dac_FB7_dat\[13\]" LOCATION "Pin_AB4"

cmp add_assignment $top_name "" "dac_FB_clk\[7\]" LOCATION "Pin_U1"
cmp add_assignment $top_name "" "dac_FB8_dat\[0\]" LOCATION "Pin_V1"
cmp add_assignment $top_name "" "dac_FB8_dat\[1\]" LOCATION "Pin_W1"
cmp add_assignment $top_name "" "dac_FB8_dat\[2\]" LOCATION "Pin_R10"
cmp add_assignment $top_name "" "dac_FB8_dat\[3\]" LOCATION "Pin_T2"
cmp add_assignment $top_name "" "dac_FB8_dat\[4\]" LOCATION "Pin_V3"
cmp add_assignment $top_name "" "dac_FB8_dat\[5\]" LOCATION "Pin_U3"
cmp add_assignment $top_name "" "dac_FB8_dat\[6\]" LOCATION "Pin_T3"
cmp add_assignment $top_name "" "dac_FB8_dat\[7\]" LOCATION "Pin_V4"
cmp add_assignment $top_name "" "dac_FB8_dat\[8\]" LOCATION "Pin_T4"
cmp add_assignment $top_name "" "dac_FB8_dat\[9\]" LOCATION "Pin_U4"
cmp add_assignment $top_name "" "dac_FB8_dat\[10\]" LOCATION "Pin_R4"
cmp add_assignment $top_name "" "dac_FB8_dat\[11\]" LOCATION "Pin_T5"
cmp add_assignment $top_name "" "dac_FB8_dat\[12\]" LOCATION "Pin_T6"
cmp add_assignment $top_name "" "dac_FB8_dat\[13\]" LOCATION "Pin_U6"
puts "   Assigned: Parallel DAC pins."
