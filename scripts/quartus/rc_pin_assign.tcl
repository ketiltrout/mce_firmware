#############################################################################
# Copyright (c) 2003 SCUBA-2 Project
#                  All Rights Reserved
#
# THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF THE SCUBA-2 Project
# The copyright notice above does not evidence any
# actual or intended publication of such source code.
#
# SOURCE CODE IS PROVIDED "AS IS". ALL EXPRESS OR IMPLIED CONDITIONS,
# REPRESENTATIONS, AND WARRANTIES, INCLUDING ANY IMPLIED WARRANT OF
# MERCHANTABILITY, SATISFACTORY QUALITY, FITNESS FOR A PARTICULAR
# PURPOSE, OR NON-INFRINGEMENT, ARE DISCLAIMED, EXCEPT TO THE EXTENT
# THAT SUCH DISCLAIMERS ARE HELD TO BE LEGALLY INVALID.
#
# For the purposes of this code the SCUBA-2 Project consists of the
# following organisations.
#
# UKATC, Royal Observatory, Blackford Hill Edinburgh EH9 3HJ
# UBC,   University of British Columbia, Physics & Astronomy Department,
#        Vancouver BC, V6T 1Z1
#
#
# rc_pin_assign.tcl
#
# Project:       SCUBA-2
# Author:        Mandana Amiri
# Organization:  UBC
#
# Description:
# This script allows you to make pin assignments to the readout card
#
# Revision history:
#
# $Log: rc_pin_assign.tcl,v $
# Revision 1.3  2004/06/19 03:06:41  erniel
# unrolled foreach loops
#
#
#
#############################################################################

# print welcome message
puts "\n\nReadout Card Pin Assignment Script v1.0"
puts "---------------------------------------"


# include Quartus Tcl API
package require ::quartus::project
package require ::quartus::flow

# get entity name
set top_name [get_project_settings -cmp]
puts "\nInfo: Top-level entity is $top_name."

puts "\nInfo: Assigning pins:"

## List of pins not assigned.
#NEXTEND_IN        U10.A13
#DCLK              U10.F16
#MSEL2             U10.AB15
#Dev_clrn          U10.AC9
#dxp               U10.B14
#U10.nCE           U10.AB13
#U10.PLLEn         U10.AC18
#U10.nIOPullup     U10.Y12

# assign device parameters
cmp add_assignment $top_name "" "" DEVICE EP1S30F780C5
cmp add_assignment $top_name "" "" RESERVE_ALL_UNUSED_PINS "AS INPUT TRI-STATED"
cmp add_assignment $top_name "" "" ENABLE_DEVICE_WIDE_RESET ON
puts "   Assigned: EP1S30 device parameters."

# assign leds
cmp add_assignment $top_name "" red_led LOCATION "Pin_H20"
cmp add_assignment $top_name "" ylw_led LOCATION "Pin_H19"
cmp add_assignment $top_name "" grn_led LOCATION "Pin_J20"
puts "   Assigned: LED pins."

# assign dip switches
cmp add_assignment $top_name "" dip_sw3 LOCATION "Pin_K10"
cmp add_assignment $top_name "" dip_sw4 LOCATION "Pin_L11"
puts "   Assigned: DIP switch pins."

# assign watchdog
cmp add_assignment $top_name "" wdog LOCATION "Pin_A5"
puts "   Assigned: Watchdog pin."

# assign ID pins
cmp add_assignment $top_name "" "slot_id\[0\]" LOCATION "Pin_D5"
cmp add_assignment $top_name "" "slot_id\[1\]" LOCATION "Pin_B6"
cmp add_assignment $top_name "" "slot_id\[2\]" LOCATION "Pin_C9"
cmp add_assignment $top_name "" "slot_id\[3\]" LOCATION "Pin_D10"

cmp add_assignment $top_name "" card_id LOCATION "Pin_A16"
puts "   Assigned: ID pins."

# assign spare TTL
cmp add_assignment $top_name "" "ttl_dir\[1\]" LOCATION "Pin_G7"
cmp add_assignment $top_name "" "ttl_in\[1\]" LOCATION "Pin_F7"
cmp add_assignment $top_name "" "ttl_out\[1\]" LOCATION "Pin_F11"

cmp add_assignment $top_name "" "ttl_dir\[2\]" LOCATION "Pin_G9"
cmp add_assignment $top_name "" "ttl_in\[2\]" LOCATION "Pin_F8"
cmp add_assignment $top_name "" "ttl_out\[2\]" LOCATION "Pin_G8"

cmp add_assignment $top_name "" "ttl_dir\[3\]" LOCATION "Pin_H9"
cmp add_assignment $top_name "" "ttl_in\[3\]" LOCATION "Pin_F9"
cmp add_assignment $top_name "" "ttl_out\[3\]" LOCATION "Pin_G12"
puts "   Assigned: Spare TTL pins."

# assign PLL pins
# PLL5 in     = CLK       (from crystal via CPLD)
# PLL5 out[0] 
# PLL5 out[1] 
# PLL5 out[2] 
# PLL5 out[3] 
cmp add_assignment $top_name "" inclk LOCATION "Pin_K17"
cmp add_assignment $top_name "" "pll5_out\[0]" LOCATION "Pin_E15"
cmp add_assignment $top_name "" "pll5_out\[1]" LOCATION "Pin_K14"
cmp add_assignment $top_name "" "pll5_out\[2]" LOCATION "Pin_C15"
cmp add_assignment $top_name "" "pll5_out\[3]" LOCATION "Pin_K16"
cmp add_assignment $top_name "" "pll6_in" LOCATION "Pin_AC17"
cmp add_assignment $top_name "" "pll6_out\[0\]" LOCATION "Pin_AD15"
cmp add_assignment $top_name "" "pll6_out\[1\]" LOCATION "Pin_W14"
cmp add_assignment $top_name "" "pll6_out\[2\]" LOCATION "Pin_AF15"
cmp add_assignment $top_name "" "pll6_out\[3\]" LOCATION "Pin_W16"
puts "   Assigned: PLL pins."

# assign SMB pins
cmp add_assignment $top_name "" smb_clk LOCATION "Pin_F17"
cmp add_assignment $top_name "" smb_data LOCATION "Pin_G22"
cmp add_assignment $top_name "" smb_nalert LOCATION "Pin_G21"
puts "   Assigned: SMB interface pins."


# assign EEPROM pins

# The eeprom debug header is also used for rs232 communication
#cmp add_assignment $top_name "" eeprom_si LOCATION "Pin_F20"
cmp add_assignment $top_name "" rs232_rx LOCATION "Pin_F20"

cmp add_assignment $top_name "" eeprom_so LOCATION "Pin_F18"


#cmp add_assignment $top_name "" eeprom_sck LOCATION "Pin_F21"
cmp add_assignment $top_name "" rs232_tx LOCATION "Pin_F21"

cmp add_assignment $top_name "" eeprom_cs LOCATION "Pin_F22"
puts "   Assigned: EEPROM pins."

# assign SRAM 
cmp add_assignment $top_name "" "sram_addr\[0\]" LOCATION "Pin_C21"
cmp add_assignment $top_name "" "sram_addr\[1\]" LOCATION "Pin_D21"
cmp add_assignment $top_name "" "sram_addr\[2\]" LOCATION "Pin_E21"
cmp add_assignment $top_name "" "sram_addr\[3\]" LOCATION "Pin_B22"
cmp add_assignment $top_name "" "sram_addr\[4\]" LOCATION "Pin_A22"
cmp add_assignment $top_name "" "sram_addr\[5\]" LOCATION "Pin_C22"
cmp add_assignment $top_name "" "sram_addr\[6\]" LOCATION "Pin_D22"
cmp add_assignment $top_name "" "sram_addr\[7\]" LOCATION "Pin_A23"
cmp add_assignment $top_name "" "sram_addr\[8\]" LOCATION "Pin_C23"
cmp add_assignment $top_name "" "sram_addr\[9\]" LOCATION "Pin_E23"
cmp add_assignment $top_name "" "sram_addr\[10\]" LOCATION "Pin_B23"
cmp add_assignment $top_name "" "sram_addr\[11\]" LOCATION "Pin_A24"
cmp add_assignment $top_name "" "sram_addr\[12\]" LOCATION "Pin_C25"
cmp add_assignment $top_name "" "sram_addr\[13\]" LOCATION "Pin_A25"
cmp add_assignment $top_name "" "sram_addr\[14\]" LOCATION "Pin_D24"
cmp add_assignment $top_name "" "sram_addr\[15\]" LOCATION "Pin_B24"
cmp add_assignment $top_name "" "sram_addr\[16\]" LOCATION "Pin_B25"
cmp add_assignment $top_name "" "sram_addr\[17\]" LOCATION "Pin_A26"
cmp add_assignment $top_name "" "sram_addr\[18\]" LOCATION "Pin_B26"
cmp add_assignment $top_name "" "sram_addr\[19\]" LOCATION "Pin_D23"
cmp add_assignment $top_name "" "sram_data\[0\]" LOCATION "Pin_D16"
cmp add_assignment $top_name "" "sram_data\[1\]" LOCATION "Pin_C16"
cmp add_assignment $top_name "" "sram_data\[2\]" LOCATION "Pin_E16"
cmp add_assignment $top_name "" "sram_data\[3\]" LOCATION "Pin_B16"
cmp add_assignment $top_name "" "sram_data\[4\]" LOCATION "Pin_E17"
cmp add_assignment $top_name "" "sram_data\[5\]" LOCATION "Pin_D17"
cmp add_assignment $top_name "" "sram_data\[6\]" LOCATION "Pin_B17"
cmp add_assignment $top_name "" "sram_data\[7\]" LOCATION "Pin_C17"
cmp add_assignment $top_name "" "sram_data\[8\]" LOCATION "Pin_A18"
cmp add_assignment $top_name "" "sram_data\[9\]" LOCATION "Pin_C18"
cmp add_assignment $top_name "" "sram_data\[10\]" LOCATION "Pin_D18"
cmp add_assignment $top_name "" "sram_data\[11\]" LOCATION "Pin_A19"
cmp add_assignment $top_name "" "sram_data\[12\]" LOCATION "Pin_B19"
cmp add_assignment $top_name "" "sram_data\[13\]" LOCATION "Pin_C19"
cmp add_assignment $top_name "" "sram_data\[14\]" LOCATION "Pin_E19"
cmp add_assignment $top_name "" "sram_data\[15\]" LOCATION "Pin_D19"
cmp add_assignment $top_name "" sram_nbhe LOCATION "Pin_B20"
cmp add_assignment $top_name "" sram_nble LOCATION "Pin_A20"
cmp add_assignment $top_name "" sram_noe LOCATION "Pin_C20"
cmp add_assignment $top_name "" sram_nwe LOCATION "Pin_A21"
cmp add_assignment $top_name "" sram_ncs LOCATION "Pin_B21"
puts "   Assigned: SRAM pins."

### reply lines to clock card (brx7a, brx7b)
cmp add_assignment $top_name "" lvds_txa LOCATION "Pin_A4"
cmp add_assignment $top_name "" lvds_txb LOCATION "Pin_A3"
cmp add_assignment $top_name "" lvds_sync LOCATION "Pin_B3"
cmp add_assignment $top_name "" lvds_spare LOCATION "Pin_B4"
cmp add_assignment $top_name "" lvds_cmd LOCATION "Pin_B5"
puts "   Assigned: LVDS pins."

# assign power supply interface
cmp add_assignment $top_name "" n7Vok LOCATION "Pin_J10"
cmp add_assignment $top_name "" minus7Vok LOCATION "Pin_J9"
cmp add_assignment $top_name "" n15Vok LOCATION "Pin_H10"
puts "   Assigned: Power supply status pin."

# assign mictor connector header
cmp add_assignment $top_name "" "mictor\[0\]" LOCATION "Pin_E13"
cmp add_assignment $top_name "" "mictor\[1\]" LOCATION "Pin_D13"
cmp add_assignment $top_name "" "mictor\[2\]" LOCATION "Pin_C13"
cmp add_assignment $top_name "" "mictor\[3\]" LOCATION "Pin_E12"
cmp add_assignment $top_name "" "mictor\[4\]" LOCATION "Pin_B13"
cmp add_assignment $top_name "" "mictor\[5\]" LOCATION "Pin_D12"
cmp add_assignment $top_name "" "mictor\[6\]" LOCATION "Pin_C12"
cmp add_assignment $top_name "" "mictor\[7\]" LOCATION "Pin_B12"
cmp add_assignment $top_name "" "mictor\[8\]" LOCATION "Pin_B11"
cmp add_assignment $top_name "" "mictor\[9\]" LOCATION "Pin_D11"
cmp add_assignment $top_name "" "mictor\[10\]" LOCATION "Pin_C11"
cmp add_assignment $top_name "" "mictor\[11\]" LOCATION "Pin_A11"
cmp add_assignment $top_name "" "mictor\[12\]" LOCATION "Pin_B10"
cmp add_assignment $top_name "" "mictor\[13\]" LOCATION "Pin_C10"
cmp add_assignment $top_name "" "mictor\[14\]" LOCATION "Pin_A10"
cmp add_assignment $top_name "" "mictor\[15\]" LOCATION "Pin_E10"
cmp add_assignment $top_name "" "mictor\[16\]" LOCATION "Pin_A9"
cmp add_assignment $top_name "" "mictor\[17\]" LOCATION "Pin_A8"
cmp add_assignment $top_name "" "mictor\[18\]" LOCATION "Pin_B8"
cmp add_assignment $top_name "" "mictor\[19\]" LOCATION "Pin_B9"
cmp add_assignment $top_name "" "mictor\[20\]" LOCATION "Pin_D9"
cmp add_assignment $top_name "" "mictor\[21\]" LOCATION "Pin_E8"
cmp add_assignment $top_name "" "mictor\[22\]" LOCATION "Pin_C8"
cmp add_assignment $top_name "" "mictor\[23\]" LOCATION "Pin_D8"
cmp add_assignment $top_name "" "mictor\[24\]" LOCATION "Pin_C7"
cmp add_assignment $top_name "" "mictor\[25\]" LOCATION "Pin_C6"
cmp add_assignment $top_name "" "mictor\[26\]" LOCATION "Pin_D7"
cmp add_assignment $top_name "" "mictor\[27\]" LOCATION "Pin_A7"
cmp add_assignment $top_name "" "mictor\[28\]" LOCATION "Pin_D6"
cmp add_assignment $top_name "" "mictor\[29\]" LOCATION "Pin_B7"
cmp add_assignment $top_name "" "mictor\[30\]" LOCATION "Pin_A6"
cmp add_assignment $top_name "" "mictor\[31\]" LOCATION "Pin_E6"
puts "   Assigned: Mictor header pins."

# assign serial DAC
cmp add_assignment $top_name "" "dac_clk\[1\]" LOCATION "Pin_AE8"
cmp add_assignment $top_name "" "dac_clk\[2\]" LOCATION "Pin_Y10"
cmp add_assignment $top_name "" "dac_clk\[3\]" LOCATION "Pin_AB7"
cmp add_assignment $top_name "" "dac_clk\[4\]" LOCATION "Pin_AC5"
cmp add_assignment $top_name "" "dac_clk\[5\]" LOCATION "Pin_AG20"
cmp add_assignment $top_name "" "dac_clk\[6\]" LOCATION "Pin_AB22"
cmp add_assignment $top_name "" "dac_clk\[7\]" LOCATION "Pin_AB20"
cmp add_assignment $top_name "" "dac_clk\[8\]" LOCATION "Pin_AB18"
cmp add_assignment $top_name "" "dac_dat\[1\]" LOCATION "Pin_AG10"
cmp add_assignment $top_name "" "dac_dat\[2\]" LOCATION "Pin_Y11"
cmp add_assignment $top_name "" "dac_dat\[3\]" LOCATION "Pin_AB8"
cmp add_assignment $top_name "" "dac_dat\[4\]" LOCATION "Pin_AC6"
cmp add_assignment $top_name "" "dac_dat\[5\]" LOCATION "Pin_AE23"
cmp add_assignment $top_name "" "dac_dat\[6\]" LOCATION "Pin_AE25"
cmp add_assignment $top_name "" "dac_dat\[7\]" LOCATION "Pin_Y20"
cmp add_assignment $top_name "" "dac_dat\[8\]" LOCATION "Pin_V18"
cmp add_assignment $top_name "" "bias_dac_ncs\[1\]" LOCATION "Pin_AH3"
cmp add_assignment $top_name "" "bias_dac_ncs\[2\]" LOCATION "Pin_V11"
cmp add_assignment $top_name "" "bias_dac_ncs\[3\]" LOCATION "Pin_AA9"
cmp add_assignment $top_name "" "bias_dac_ncs\[4\]" LOCATION "Pin_AB9"
cmp add_assignment $top_name "" "bias_dac_ncs\[5\]" LOCATION "Pin_AH16"
cmp add_assignment $top_name "" "bias_dac_ncs\[6\]" LOCATION "Pin_AC24"
cmp add_assignment $top_name "" "bias_dac_ncs\[7\]" LOCATION "Pin_AD24"
cmp add_assignment $top_name "" "bias_dac_ncs\[8\]" LOCATION "Pin_AC22"
cmp add_assignment $top_name "" "offset_dac_ncs\[1\]" LOCATION "Pin_AE7"
cmp add_assignment $top_name "" "offset_dac_ncs\[2\]" LOCATION "Pin_Y9"
cmp add_assignment $top_name "" "offset_dac_ncs\[3\]" LOCATION "Pin_AA10"
cmp add_assignment $top_name "" "offset_dac_ncs\[4\]" LOCATION "Pin_AB12"
cmp add_assignment $top_name "" "offset_dac_ncs\[5\]" LOCATION "Pin_AF18"
cmp add_assignment $top_name "" "offset_dac_ncs\[6\]" LOCATION "Pin_AC23"
cmp add_assignment $top_name "" "offset_dac_ncs\[7\]" LOCATION "Pin_AB21"
cmp add_assignment $top_name "" "offset_dac_ncs\[8\]" LOCATION "Pin_AC20"
puts "   Assigned: Serial DAC pins."


# assign parallel DAC
cmp add_assignment $top_name "" "dac_FB1_clk" LOCATION "Pin_N10"
cmp add_assignment $top_name "" "dac_FB1_dat\[0\]" LOCATION "Pin_N9"
cmp add_assignment $top_name "" "dac_FB1_dat\[1\]" LOCATION "Pin_M3"
cmp add_assignment $top_name "" "dac_FB1_dat\[2\]" LOCATION "Pin_M4"
cmp add_assignment $top_name "" "dac_FB1_dat\[3\]" LOCATION "Pin_N5"
cmp add_assignment $top_name "" "dac_FB1_dat\[4\]" LOCATION "Pin_N6"
cmp add_assignment $top_name "" "dac_FB1_dat\[5\]" LOCATION "Pin_L1"
cmp add_assignment $top_name "" "dac_FB1_dat\[6\]" LOCATION "Pin_L2"
cmp add_assignment $top_name "" "dac_FB1_dat\[7\]" LOCATION "Pin_N7"
cmp add_assignment $top_name "" "dac_FB1_dat\[8\]" LOCATION "Pin_N8"
cmp add_assignment $top_name "" "dac_FB1_dat\[9\]" LOCATION "Pin_L3"
cmp add_assignment $top_name "" "dac_FB1_dat\[10\]" LOCATION "Pin_L4"
cmp add_assignment $top_name "" "dac_FB1_dat\[11\]" LOCATION "Pin_N4"
cmp add_assignment $top_name "" "dac_FB1_dat\[12\]" LOCATION "Pin_N3"
cmp add_assignment $top_name "" "dac_FB1_dat\[13\]" LOCATION "Pin_K1"

cmp add_assignment $top_name "" "dac_FB2_clk" LOCATION "Pin_C2"
cmp add_assignment $top_name "" "dac_FB2_dat\[0\]" LOCATION "Pin_C1"
cmp add_assignment $top_name "" "dac_FB2_dat\[1\]" LOCATION "Pin_H5"
cmp add_assignment $top_name "" "dac_FB2_dat\[2\]" LOCATION "Pin_H6"
cmp add_assignment $top_name "" "dac_FB2_dat\[3\]" LOCATION "Pin_D2"
cmp add_assignment $top_name "" "dac_FB2_dat\[4\]" LOCATION "Pin_D1"
cmp add_assignment $top_name "" "dac_FB2_dat\[5\]" LOCATION "Pin_H7"
cmp add_assignment $top_name "" "dac_FB2_dat\[6\]" LOCATION "Pin_H8"
cmp add_assignment $top_name "" "dac_FB2_dat\[7\]" LOCATION "Pin_E2"
cmp add_assignment $top_name "" "dac_FB2_dat\[8\]" LOCATION "Pin_E1"
cmp add_assignment $top_name "" "dac_FB2_dat\[9\]" LOCATION "Pin_J5"
cmp add_assignment $top_name "" "dac_FB2_dat\[10\]" LOCATION "Pin_J6"
cmp add_assignment $top_name "" "dac_FB2_dat\[11\]" LOCATION "Pin_F4"
cmp add_assignment $top_name "" "dac_FB2_dat\[12\]" LOCATION "Pin_F3"
cmp add_assignment $top_name "" "dac_FB2_dat\[13\]" LOCATION "Pin_K6"

cmp add_assignment $top_name "" "dac_FB3_clk" LOCATION "Pin_F2"
cmp add_assignment $top_name "" "dac_FB3_dat\[0\]" LOCATION "Pin_F1"
cmp add_assignment $top_name "" "dac_FB3_dat\[1\]" LOCATION "Pin_J8"
cmp add_assignment $top_name "" "dac_FB3_dat\[2\]" LOCATION "Pin_J7"
cmp add_assignment $top_name "" "dac_FB3_dat\[3\]" LOCATION "Pin_G3"
cmp add_assignment $top_name "" "dac_FB3_dat\[4\]" LOCATION "Pin_G4"
cmp add_assignment $top_name "" "dac_FB3_dat\[5\]" LOCATION "Pin_K8"
cmp add_assignment $top_name "" "dac_FB3_dat\[6\]" LOCATION "Pin_K7"
cmp add_assignment $top_name "" "dac_FB3_dat\[7\]" LOCATION "Pin_G2"
cmp add_assignment $top_name "" "dac_FB3_dat\[8\]" LOCATION "Pin_G1"
cmp add_assignment $top_name "" "dac_FB3_dat\[9\]" LOCATION "Pin_L7"
cmp add_assignment $top_name "" "dac_FB3_dat\[10\]" LOCATION "Pin_L8"
cmp add_assignment $top_name "" "dac_FB3_dat\[11\]" LOCATION "Pin_H4"
cmp add_assignment $top_name "" "dac_FB3_dat\[12\]" LOCATION "Pin_H3"
cmp add_assignment $top_name "" "dac_FB3_dat\[13\]" LOCATION "Pin_L6"

cmp add_assignment $top_name "" "dac_FB4_clk" LOCATION "Pin_M10"
cmp add_assignment $top_name "" "dac_FB4_dat\[0\]" LOCATION "Pin_M9"
cmp add_assignment $top_name "" "dac_FB4_dat\[1\]" LOCATION "Pin_K4"
cmp add_assignment $top_name "" "dac_FB4_dat\[2\]" LOCATION "Pin_K3"
cmp add_assignment $top_name "" "dac_FB4_dat\[3\]" LOCATION "Pin_M6"
cmp add_assignment $top_name "" "dac_FB4_dat\[4\]" LOCATION "Pin_M5"
cmp add_assignment $top_name "" "dac_FB4_dat\[5\]" LOCATION "Pin_J1"
cmp add_assignment $top_name "" "dac_FB4_dat\[6\]" LOCATION "Pin_J2"
cmp add_assignment $top_name "" "dac_FB4_dat\[7\]" LOCATION "Pin_M8"
cmp add_assignment $top_name "" "dac_FB4_dat\[8\]" LOCATION "Pin_M7"
cmp add_assignment $top_name "" "dac_FB4_dat\[9\]" LOCATION "Pin_J3"
cmp add_assignment $top_name "" "dac_FB4_dat\[10\]" LOCATION "Pin_J4"
cmp add_assignment $top_name "" "dac_FB4_dat\[11\]" LOCATION "Pin_L10"
cmp add_assignment $top_name "" "dac_FB4_dat\[12\]" LOCATION "Pin_L9"
cmp add_assignment $top_name "" "dac_FB4_dat\[13\]" LOCATION "Pin_H1"

cmp add_assignment $top_name "" "dac_FB5_clk" LOCATION "Pin_AG12"
cmp add_assignment $top_name "" "dac_FB5_dat\[0\]" LOCATION "Pin_AF12"
cmp add_assignment $top_name "" "dac_FB5_dat\[1\]" LOCATION "Pin_AE12"
cmp add_assignment $top_name "" "dac_FB5_dat\[2\]" LOCATION "Pin_AG13"
cmp add_assignment $top_name "" "dac_FB5_dat\[3\]" LOCATION "Pin_AD12"
cmp add_assignment $top_name "" "dac_FB5_dat\[4\]" LOCATION "Pin_AF13"
cmp add_assignment $top_name "" "dac_FB5_dat\[5\]" LOCATION "Pin_AE13"
cmp add_assignment $top_name "" "dac_FB5_dat\[6\]" LOCATION "Pin_AD13"
cmp add_assignment $top_name "" "dac_FB5_dat\[7\]" LOCATION "Pin_AE16"
cmp add_assignment $top_name "" "dac_FB5_dat\[8\]" LOCATION "Pin_AF16"
cmp add_assignment $top_name "" "dac_FB5_dat\[9\]" LOCATION "Pin_AD16"
cmp add_assignment $top_name "" "dac_FB5_dat\[10\]" LOCATION "Pin_AG16"
cmp add_assignment $top_name "" "dac_FB5_dat\[11\]" LOCATION "Pin_AD17"
cmp add_assignment $top_name "" "dac_FB5_dat\[12\]" LOCATION "Pin_AE17"
cmp add_assignment $top_name "" "dac_FB5_dat\[13\]" LOCATION "Pin_AG17"

cmp add_assignment $top_name "" "dac_FB6_clk" LOCATION "Pin_AH4"
cmp add_assignment $top_name "" "dac_FB6_dat\[0\]" LOCATION "Pin_AE5"
cmp add_assignment $top_name "" "dac_FB6_dat\[1\]" LOCATION "Pin_AG3"
cmp add_assignment $top_name "" "dac_FB6_dat\[2\]" LOCATION "Pin_AG5"
cmp add_assignment $top_name "" "dac_FB6_dat\[3\]" LOCATION "Pin_AG4"
cmp add_assignment $top_name "" "dac_FB6_dat\[4\]" LOCATION "Pin_AF4"
cmp add_assignment $top_name "" "dac_FB6_dat\[5\]" LOCATION "Pin_AH5"
cmp add_assignment $top_name "" "dac_FB6_dat\[6\]" LOCATION "Pin_AF5"
cmp add_assignment $top_name "" "dac_FB6_dat\[7\]" LOCATION "Pin_AE6"
cmp add_assignment $top_name "" "dac_FB6_dat\[8\]" LOCATION "Pin_AG6"
cmp add_assignment $top_name "" "dac_FB6_dat\[9\]" LOCATION "Pin_AH6"
cmp add_assignment $top_name "" "dac_FB6_dat\[10\]" LOCATION "Pin_AD6"
cmp add_assignment $top_name "" "dac_FB6_dat\[11\]" LOCATION "Pin_AF7"
cmp add_assignment $top_name "" "dac_FB6_dat\[12\]" LOCATION "Pin_AH7"
cmp add_assignment $top_name "" "dac_FB6_dat\[13\]" LOCATION "Pin_AG7"

cmp add_assignment $top_name "" "dac_FB7_clk" LOCATION "Pin_AG18"
cmp add_assignment $top_name "" "dac_FB7_dat\[0\]" LOCATION "Pin_AE18"
cmp add_assignment $top_name "" "dac_FB7_dat\[1\]" LOCATION "Pin_AD18"
cmp add_assignment $top_name "" "dac_FB7_dat\[2\]" LOCATION "Pin_AH19"
cmp add_assignment $top_name "" "dac_FB7_dat\[3\]" LOCATION "Pin_AG19"
cmp add_assignment $top_name "" "dac_FB7_dat\[4\]" LOCATION "Pin_AF19"
cmp add_assignment $top_name "" "dac_FB7_dat\[5\]" LOCATION "Pin_AD19"
cmp add_assignment $top_name "" "dac_FB7_dat\[6\]" LOCATION "Pin_AE19"
cmp add_assignment $top_name "" "dac_FB7_dat\[7\]" LOCATION "Pin_AH20"
cmp add_assignment $top_name "" "dac_FB7_dat\[8\]" LOCATION "Pin_AH21"
cmp add_assignment $top_name "" "dac_FB7_dat\[9\]" LOCATION "Pin_AF20"
cmp add_assignment $top_name "" "dac_FB7_dat\[10\]" LOCATION "Pin_AE20"
cmp add_assignment $top_name "" "dac_FB7_dat\[11\]" LOCATION "Pin_AF21"
cmp add_assignment $top_name "" "dac_FB7_dat\[12\]" LOCATION "Pin_AG21"
cmp add_assignment $top_name "" "dac_FB7_dat\[13\]" LOCATION "Pin_AE21"

cmp add_assignment $top_name "" "dac_FB8_clk" LOCATION "Pin_AG8"
cmp add_assignment $top_name "" "dac_FB8_dat\[0\]" LOCATION "Pin_AF8"
cmp add_assignment $top_name "" "dac_FB8_dat\[1\]" LOCATION "Pin_AD8"
cmp add_assignment $top_name "" "dac_FB8_dat\[2\]" LOCATION "Pin_AH9"
cmp add_assignment $top_name "" "dac_FB8_dat\[3\]" LOCATION "Pin_AH8"
cmp add_assignment $top_name "" "dac_FB8_dat\[4\]" LOCATION "Pin_AE9"
cmp add_assignment $top_name "" "dac_FB8_dat\[5\]" LOCATION "Pin_AF9"
cmp add_assignment $top_name "" "dac_FB8_dat\[6\]" LOCATION "Pin_AG9"
cmp add_assignment $top_name "" "dac_FB8_dat\[7\]" LOCATION "Pin_AD10"
cmp add_assignment $top_name "" "dac_FB8_dat\[8\]" LOCATION "Pin_AF10"
cmp add_assignment $top_name "" "dac_FB8_dat\[9\]" LOCATION "Pin_AH10"
cmp add_assignment $top_name "" "dac_FB8_dat\[10\]" LOCATION "Pin_AE10"
cmp add_assignment $top_name "" "dac_FB8_dat\[11\]" LOCATION "Pin_AF11"
cmp add_assignment $top_name "" "dac_FB8_dat\[12\]" LOCATION "Pin_AE11"
cmp add_assignment $top_name "" "dac_FB8_dat\[13\]" LOCATION "Pin_AH11"
puts "   Assigned: Parallel DAC pins."


# assign ADC
cmp add_assignment $top_name "" "adc1_clk" LOCATION "Pin_AB6"
cmp add_assignment $top_name "" "adc1_rdy" LOCATION "Pin_W22"
cmp add_assignment $top_name "" "adc1_ovr" LOCATION "Pin_AG22"
cmp add_assignment $top_name "" "adc1_dat\[0\]" LOCATION "Pin_AB26"
cmp add_assignment $top_name "" "adc1_dat\[1\]" LOCATION "Pin_AB25"
cmp add_assignment $top_name "" "adc1_dat\[2\]" LOCATION "Pin_W23"
cmp add_assignment $top_name "" "adc1_dat\[3\]" LOCATION "Pin_W24"
cmp add_assignment $top_name "" "adc1_dat\[4\]" LOCATION "Pin_AB28"
cmp add_assignment $top_name "" "adc1_dat\[5\]" LOCATION "Pin_AB27"
cmp add_assignment $top_name "" "adc1_dat\[6\]" LOCATION "Pin_V22"
cmp add_assignment $top_name "" "adc1_dat\[7\]" LOCATION "Pin_V21"
cmp add_assignment $top_name "" "adc1_dat\[8\]" LOCATION "Pin_AA25"
cmp add_assignment $top_name "" "adc1_dat\[9\]" LOCATION "Pin_AA26"
cmp add_assignment $top_name "" "adc1_dat\[10\]" LOCATION "Pin_V24"
cmp add_assignment $top_name "" "adc1_dat\[11\]" LOCATION "Pin_V23"
cmp add_assignment $top_name "" "adc1_dat\[12\]" LOCATION "Pin_AA28"
cmp add_assignment $top_name "" "adc1_dat\[13\]" LOCATION "Pin_AA27"

cmp add_assignment $top_name "" "adc2_clk" LOCATION "Pin_AA8"
cmp add_assignment $top_name "" "adc2_rdy" LOCATION "Pin_AH22"
cmp add_assignment $top_name "" "adc2_ovr" LOCATION "Pin_N20"
cmp add_assignment $top_name "" "adc2_dat\[0\]" LOCATION "Pin_AF22"
cmp add_assignment $top_name "" "adc2_dat\[1\]" LOCATION "Pin_AE22"
cmp add_assignment $top_name "" "adc2_dat\[2\]" LOCATION "Pin_AH23"
cmp add_assignment $top_name "" "adc2_dat\[3\]" LOCATION "Pin_AF23"
cmp add_assignment $top_name "" "adc2_dat\[4\]" LOCATION "Pin_AD23"
cmp add_assignment $top_name "" "adc2_dat\[5\]" LOCATION "Pin_AG23"
cmp add_assignment $top_name "" "adc2_dat\[6\]" LOCATION "Pin_AH24"
cmp add_assignment $top_name "" "adc2_dat\[7\]" LOCATION "Pin_AE24"
cmp add_assignment $top_name "" "adc2_dat\[8\]" LOCATION "Pin_AG24"
cmp add_assignment $top_name "" "adc2_dat\[9\]" LOCATION "Pin_AF25"
cmp add_assignment $top_name "" "adc2_dat\[10\]" LOCATION "Pin_AH25"
cmp add_assignment $top_name "" "adc2_dat\[11\]" LOCATION "Pin_AG25"
cmp add_assignment $top_name "" "adc2_dat\[12\]" LOCATION "Pin_AH26"
cmp add_assignment $top_name "" "adc2_dat\[13\]" LOCATION "Pin_AG26"

cmp add_assignment $top_name "" "adc3_clk" LOCATION "Pin_AA6"
cmp add_assignment $top_name "" "adc3_rdy" LOCATION "Pin_N19"
cmp add_assignment $top_name "" "adc3_ovr" LOCATION "Pin_AA21"
cmp add_assignment $top_name "" "adc3_dat\[0\]" LOCATION "Pin_M25"
cmp add_assignment $top_name "" "adc3_dat\[1\]" LOCATION "Pin_M26"
cmp add_assignment $top_name "" "adc3_dat\[2\]" LOCATION "Pin_N22"
cmp add_assignment $top_name "" "adc3_dat\[3\]" LOCATION "Pin_N21"
cmp add_assignment $top_name "" "adc3_dat\[4\]" LOCATION "Pin_L27"
cmp add_assignment $top_name "" "adc3_dat\[5\]" LOCATION "Pin_L28"
cmp add_assignment $top_name "" "adc3_dat\[6\]" LOCATION "Pin_N24"
cmp add_assignment $top_name "" "adc3_dat\[7\]" LOCATION "Pin_N23"
cmp add_assignment $top_name "" "adc3_dat\[8\]" LOCATION "Pin_L25"
cmp add_assignment $top_name "" "adc3_dat\[9\]" LOCATION "Pin_L26"
cmp add_assignment $top_name "" "adc3_dat\[10\]" LOCATION "Pin_N26"
cmp add_assignment $top_name "" "adc3_dat\[11\]" LOCATION "Pin_N25"
cmp add_assignment $top_name "" "adc3_dat\[12\]" LOCATION "Pin_K27"
cmp add_assignment $top_name "" "adc3_dat\[13\]" LOCATION "Pin_K28"

cmp add_assignment $top_name "" "adc4_clk" LOCATION "Pin_Y5"
cmp add_assignment $top_name "" "adc4_rdy" LOCATION "Pin_AA22"
cmp add_assignment $top_name "" "adc4_ovr" LOCATION "Pin_W27"
cmp add_assignment $top_name "" "adc4_dat\[0\]" LOCATION "Pin_AF28"
cmp add_assignment $top_name "" "adc4_dat\[1\]" LOCATION "Pin_AF27"
cmp add_assignment $top_name "" "adc4_dat\[2\]" LOCATION "Pin_AA23"
cmp add_assignment $top_name "" "adc4_dat\[3\]" LOCATION "Pin_AA24"
cmp add_assignment $top_name "" "adc4_dat\[4\]" LOCATION "Pin_AE28"
cmp add_assignment $top_name "" "adc4_dat\[5\]" LOCATION "Pin_AE27"
cmp add_assignment $top_name "" "adc4_dat\[6\]" LOCATION "Pin_Y24"
cmp add_assignment $top_name "" "adc4_dat\[7\]" LOCATION "Pin_Y23"
cmp add_assignment $top_name "" "adc4_dat\[8\]" LOCATION "Pin_AD28"
cmp add_assignment $top_name "" "adc4_dat\[9\]" LOCATION "Pin_AD27"
cmp add_assignment $top_name "" "adc4_dat\[10\]" LOCATION "Pin_Y21"
cmp add_assignment $top_name "" "adc4_dat\[11\]" LOCATION "Pin_Y22"
cmp add_assignment $top_name "" "adc4_dat\[12\]" LOCATION "Pin_AC28"
cmp add_assignment $top_name "" "adc4_dat\[13\]" LOCATION "Pin_AC27"

cmp add_assignment $top_name "" "adc5_clk" LOCATION "Pin_Y8"
cmp add_assignment $top_name "" "adc5_rdy" LOCATION "Pin_W28"
cmp add_assignment $top_name "" "adc5_ovr" LOCATION "Pin_M20"
cmp add_assignment $top_name "" "adc5_dat\[0\]" LOCATION "Pin_U20"
cmp add_assignment $top_name "" "adc5_dat\[1\]" LOCATION "Pin_U19"
cmp add_assignment $top_name "" "adc5_dat\[2\]" LOCATION "Pin_W25"
cmp add_assignment $top_name "" "adc5_dat\[3\]" LOCATION "Pin_W26"
cmp add_assignment $top_name "" "adc5_dat\[4\]" LOCATION "Pin_U23"
cmp add_assignment $top_name "" "adc5_dat\[5\]" LOCATION "Pin_U24"
cmp add_assignment $top_name "" "adc5_dat\[6\]" LOCATION "Pin_Y27"
cmp add_assignment $top_name "" "adc5_dat\[7\]" LOCATION "Pin_Y28"
cmp add_assignment $top_name "" "adc5_dat\[8\]" LOCATION "Pin_U22"
cmp add_assignment $top_name "" "adc5_dat\[9\]" LOCATION "Pin_U21"
cmp add_assignment $top_name "" "adc5_dat\[10\]" LOCATION "Pin_Y25"
cmp add_assignment $top_name "" "adc5_dat\[11\]" LOCATION "Pin_Y26"
cmp add_assignment $top_name "" "adc5_dat\[12\]" LOCATION "Pin_V20"
cmp add_assignment $top_name "" "adc5_dat\[13\]" LOCATION "Pin_V19"

cmp add_assignment $top_name "" "adc6_clk" LOCATION "Pin_V10"
cmp add_assignment $top_name "" "adc6_rdy" LOCATION "Pin_M19"
cmp add_assignment $top_name "" "adc6_ovr" LOCATION "Pin_F28"
cmp add_assignment $top_name "" "adc6_dat\[0\]" LOCATION "Pin_K26"
cmp add_assignment $top_name "" "adc6_dat\[1\]" LOCATION "Pin_K25"
cmp add_assignment $top_name "" "adc6_dat\[2\]" LOCATION "Pin_M24"
cmp add_assignment $top_name "" "adc6_dat\[3\]" LOCATION "Pin_M23"
cmp add_assignment $top_name "" "adc6_dat\[4\]" LOCATION "Pin_J27"
cmp add_assignment $top_name "" "adc6_dat\[5\]" LOCATION "Pin_J28"
cmp add_assignment $top_name "" "adc6_dat\[6\]" LOCATION "Pin_M22"
cmp add_assignment $top_name "" "adc6_dat\[7\]" LOCATION "Pin_M21"
cmp add_assignment $top_name "" "adc6_dat\[8\]" LOCATION "Pin_J25"
cmp add_assignment $top_name "" "adc6_dat\[9\]" LOCATION "Pin_J26"
cmp add_assignment $top_name "" "adc6_dat\[10\]" LOCATION "Pin_L20"
cmp add_assignment $top_name "" "adc6_dat\[11\]" LOCATION "Pin_L19"
cmp add_assignment $top_name "" "adc6_dat\[12\]" LOCATION "Pin_H27"
cmp add_assignment $top_name "" "adc6_dat\[13\]" LOCATION "Pin_H28"

cmp add_assignment $top_name "" "adc7_clk" LOCATION "Pin_U8"
cmp add_assignment $top_name "" "adc7_rdy" LOCATION "Pin_F27"
cmp add_assignment $top_name "" "adc7_ovr" LOCATION "Pin_C28"
cmp add_assignment $top_name "" "adc7_dat\[0\]" LOCATION "Pin_J22"
cmp add_assignment $top_name "" "adc7_dat\[1\]" LOCATION "Pin_J21"
cmp add_assignment $top_name "" "adc7_dat\[2\]" LOCATION "Pin_G25"
cmp add_assignment $top_name "" "adc7_dat\[3\]" LOCATION "Pin_G26"
cmp add_assignment $top_name "" "adc7_dat\[4\]" LOCATION "Pin_K22"
cmp add_assignment $top_name "" "adc7_dat\[5\]" LOCATION "Pin_K21"
cmp add_assignment $top_name "" "adc7_dat\[6\]" LOCATION "Pin_G28"
cmp add_assignment $top_name "" "adc7_dat\[7\]" LOCATION "Pin_G27"
cmp add_assignment $top_name "" "adc7_dat\[8\]" LOCATION "Pin_L21"
cmp add_assignment $top_name "" "adc7_dat\[9\]" LOCATION "Pin_L22"
cmp add_assignment $top_name "" "adc7_dat\[10\]" LOCATION "Pin_H25"
cmp add_assignment $top_name "" "adc7_dat\[11\]" LOCATION "Pin_H26"
cmp add_assignment $top_name "" "adc7_dat\[12\]" LOCATION "Pin_L24"
cmp add_assignment $top_name "" "adc7_dat\[13\]" LOCATION "Pin_L23"

cmp add_assignment $top_name "" "adc8_clk" LOCATION "Pin_U5"
cmp add_assignment $top_name "" "adc8_rdy" LOCATION "Pin_C27"
cmp add_assignment $top_name "" "adc8_ovr" LOCATION "Pin_W21"
cmp add_assignment $top_name "" "adc8_dat\[0\]" LOCATION "Pin_H23"
cmp add_assignment $top_name "" "adc8_dat\[1\]" LOCATION "Pin_H24"
cmp add_assignment $top_name "" "adc8_dat\[2\]" LOCATION "Pin_D28"
cmp add_assignment $top_name "" "adc8_dat\[3\]" LOCATION "Pin_D27"
cmp add_assignment $top_name "" "adc8_dat\[4\]" LOCATION "Pin_H21"
cmp add_assignment $top_name "" "adc8_dat\[5\]" LOCATION "Pin_H22"
cmp add_assignment $top_name "" "adc8_dat\[6\]" LOCATION "Pin_E28"
cmp add_assignment $top_name "" "adc8_dat\[7\]" LOCATION "Pin_E27"
cmp add_assignment $top_name "" "adc8_dat\[8\]" LOCATION "Pin_J23"
cmp add_assignment $top_name "" "adc8_dat\[9\]" LOCATION "Pin_J24"
cmp add_assignment $top_name "" "adc8_dat\[10\]" LOCATION "Pin_F26"
cmp add_assignment $top_name "" "adc8_dat\[11\]" LOCATION "Pin_F25"
cmp add_assignment $top_name "" "adc8_dat\[12\]" LOCATION "Pin_K24"
cmp add_assignment $top_name "" "adc8_dat\[13\]" LOCATION "Pin_K23"
puts "   Assigned: ADC pins."


# recompile to commit
puts "\nInfo: Recompiling to commit assignments..."
execute_flow -compile

puts "\nInfo: Process completed."