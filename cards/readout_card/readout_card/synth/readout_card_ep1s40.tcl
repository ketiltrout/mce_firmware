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
# $Log: readout_card_ep1s40.tcl,v $
# Revision 1.6  2010-11-18 21:28:07  mandana
# Quartus 10.1 doesn't support cmp syntax anymore, so updated tcl file appropriately.
#
# Revision 1.5  2010/06/29 01:37:32  bburger
# BB:  Automatic .pof generation
#
# Revision 1.4  2006/05/16 21:23:49  mandana
# added pins dedicated to RS232 comm introduced in Rev. B boards
#
# Revision 1.3  2006/04/13 17:04:38  mandana
# added mictor_clk pins introduced in Rev. B RC
#
# Revision 1.2  2006/04/03 19:03:43  mandana
# fixed the print out for 1s30/1s40 device selection
#
# Revision 1.1  2006/03/23 23:28:58  bburger
# Bryce:  commit
#
# Revision 1.10  2005/01/18 22:20:47  bburger
# Bryce:  Added a BClr signal across the bus backplane to all the card top levels.
#
# Revision 1.9  2004/12/17 01:17:23  bench2
# *** empty log message ***
#
# Revision 1.8  2004/12/06 07:22:35  bburger
# Bryce:
# Created pack files for the card top-levels.
# Added some simulation signals to the top-levels (i.e. clocks)
#
# Revision 1.7  2004/07/26 20:06:46  mandana
# renamed mictor pins
#
# Revision 1.6  2004/07/19 20:40:25  mandana
# changed back the DAC numbering (that Ernie has changed) to 0-7 to stay consistant with the DAC tests
#
# Revision 1.5  2004/07/16 00:17:16  erniel
# Mandana: fixed dac_fb_clk naming that Ernie had changed
#
# Revision 1.4  2004/07/13 16:41:42  erniel
# Mandana: renamed eeprom si and clk pins to rs232_rx and rs232_tx
#
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
package require ::quartus::project_ui
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
set_global_assignment -name DEVICE EP1S40F780C7
set_global_assignment -name RESERVE_ALL_UNUSED_PINS "AS INPUT TRI-STATED"

# dev_clr_n disabled
set_global_assignment -name ENABLE_DEVICE_WIDE_RESET OFF
puts "   Assigned: EP1S40 device parameters."

# assign rst_n
set_location_assignment Pin_AC9 -to rst_n
puts "   Assigned: RST_N pin."

# assign leds
set_location_assignment Pin_H20 -to red_led
set_location_assignment Pin_H19 -to ylw_led
set_location_assignment Pin_J20 -to grn_led
puts "   Assigned: LED pins."

# assign dip switches
set_location_assignment Pin_K10 -to dip_sw3
set_location_assignment Pin_L11 -to dip_sw4
puts "   Assigned: DIP switch pins."

# assign watchdog
set_location_assignment Pin_A5 -to wdog
puts "   Assigned: Watchdog pin."

# assign ID pins
set_location_assignment Pin_D5 -to "slot_id\[0\]"
set_location_assignment Pin_B6 -to "slot_id\[1\]"
set_location_assignment Pin_C9 -to "slot_id\[2\]"
set_location_assignment Pin_D10 -to "slot_id\[3\]"

set_location_assignment Pin_A16 -to card_id
puts "   Assigned: ID pins."

# assign spare TTL
set_location_assignment Pin_G7 -to "ttl_dir1"
set_location_assignment Pin_F7 -to "ttl_in1"
set_location_assignment Pin_F11 -to "ttl_out1"

set_location_assignment Pin_G9 -to "ttl_dir2"
set_location_assignment Pin_F8 -to "ttl_in2"
set_location_assignment Pin_G8 -to "ttl_out2"

set_location_assignment Pin_H9 -to "ttl_dir3"
set_location_assignment Pin_F9 -to "ttl_in3"
set_location_assignment Pin_G12 -to "ttl_out3"
puts "   Assigned: Spare TTL pins."

# assign PLL pins
# PLL5 in     = CLK       (from crystal via CPLD)
# PLL5 out[0] 
# PLL5 out[1] 
# PLL5 out[2] 
# PLL5 out[3] 
set_location_assignment Pin_K17 -to inclk
set_location_assignment Pin_E15 -to "pll5_out\[0\]"
set_location_assignment Pin_K14 -to "pll5_out\[1\]"
set_location_assignment Pin_C15 -to "pll5_out\[2\]"
set_location_assignment Pin_K16 -to "pll5_out\[3\]"
set_location_assignment Pin_AC17 -to "pll6_in"
set_location_assignment Pin_AD15 -to "pll6_out\[0\]"
set_location_assignment Pin_W14 -to "pll6_out\[1\]"
set_location_assignment Pin_AF15 -to "pll6_out\[2\]"
set_location_assignment Pin_W16 -to "pll6_out\[3\]"
puts "   Assigned: PLL pins."

# assign SMB pins
set_location_assignment Pin_F17 -to smb_clk
set_location_assignment Pin_G22 -to smb_data
set_location_assignment Pin_G21 -to smb_nalert
puts "   Assigned: SMB interface pins."


# assign EEPROM pins
# In Rev. A, the eeprom debug header is also used for rs232 communication
# but in Rev. B there is a dedicated RS232 header.
set_location_assignment Pin_F20 -to eeprom_si
set_location_assignment Pin_F18 -to eeprom_so
set_location_assignment Pin_F21 -to eeprom_sck
set_location_assignment Pin_F22 -to eeprom_cs
puts "   Assigned: EEPROM pins."

# assign SRAM 
set_location_assignment Pin_C21 -to "sram_addr\[0\]"
set_location_assignment Pin_D21 -to "sram_addr\[1\]"
set_location_assignment Pin_E21 -to "sram_addr\[2\]"
set_location_assignment Pin_B22 -to "sram_addr\[3\]"
set_location_assignment Pin_A22 -to "sram_addr\[4\]"
set_location_assignment Pin_C22 -to "sram_addr\[5\]"
set_location_assignment Pin_D22 -to "sram_addr\[6\]"
set_location_assignment Pin_A23 -to "sram_addr\[7\]"
set_location_assignment Pin_C23 -to "sram_addr\[8\]"
set_location_assignment Pin_E23 -to "sram_addr\[9\]"
set_location_assignment Pin_B23 -to "sram_addr\[10\]"
set_location_assignment Pin_A24 -to "sram_addr\[11\]"
set_location_assignment Pin_C25 -to "sram_addr\[12\]"
set_location_assignment Pin_A25 -to "sram_addr\[13\]"
set_location_assignment Pin_D24 -to "sram_addr\[14\]"
set_location_assignment Pin_B24 -to "sram_addr\[15\]"
set_location_assignment Pin_B25 -to "sram_addr\[16\]"
set_location_assignment Pin_A26 -to "sram_addr\[17\]"
set_location_assignment Pin_B26 -to "sram_addr\[18\]"
set_location_assignment Pin_D23 -to "sram_addr\[19\]"
set_location_assignment Pin_D16 -to "sram_data\[0\]"
set_location_assignment Pin_C16 -to "sram_data\[1\]"
set_location_assignment Pin_E16 -to "sram_data\[2\]"
set_location_assignment Pin_B16 -to "sram_data\[3\]"
set_location_assignment Pin_E17 -to "sram_data\[4\]"
set_location_assignment Pin_D17 -to "sram_data\[5\]"
set_location_assignment Pin_B17 -to "sram_data\[6\]"
set_location_assignment Pin_C17 -to "sram_data\[7\]"
set_location_assignment Pin_A18 -to "sram_data\[8\]"
set_location_assignment Pin_C18 -to "sram_data\[9\]"
set_location_assignment Pin_D18 -to "sram_data\[10\]"
set_location_assignment Pin_A19 -to "sram_data\[11\]"
set_location_assignment Pin_B19 -to "sram_data\[12\]"
set_location_assignment Pin_C19 -to "sram_data\[13\]"
set_location_assignment Pin_E19 -to "sram_data\[14\]"
set_location_assignment Pin_D19 -to "sram_data\[15\]"
set_location_assignment Pin_B20 -to sram_nbhe
set_location_assignment Pin_A20 -to sram_nble
set_location_assignment Pin_C20 -to sram_noe
set_location_assignment Pin_A21 -to sram_nwe
set_location_assignment Pin_B21 -to sram_ncs
puts "   Assigned: SRAM pins."

### reply lines to clock card (brx7a, brx7b)
set_location_assignment Pin_A4 -to lvds_txa
set_location_assignment Pin_A3 -to lvds_txb
set_location_assignment Pin_B3 -to lvds_sync
set_location_assignment Pin_B4 -to lvds_spare
set_location_assignment Pin_B5 -to lvds_cmd
puts "   Assigned: LVDS pins."

# assign power supply interface
set_location_assignment Pin_J10 -to n7Vok
set_location_assignment Pin_J9 -to minus7Vok
set_location_assignment Pin_H10 -to n15Vok
puts "   Assigned: Power supply status pin."

# assign rs232 interface
set_location_assignment Pin_B12 -to tx
set_location_assignment Pin_C12 -to rx
puts "   Assigned: RS232 pins."

# assign mictor connector header
set_location_assignment Pin_A11 -to "mictor\[0\]"
set_location_assignment Pin_B11 -to "mictor\[1\]"
set_location_assignment Pin_C11 -to "mictor\[2\]"
set_location_assignment Pin_A10 -to "mictor\[3\]"
set_location_assignment Pin_B10 -to "mictor\[4\]"
#set_location_assignment Pin_C12 -to "mictor\[5\]"
#set_location_assignment Pin_B12 -to "mictor\[6\]"
set_location_assignment Pin_C13 -to "mictor\[7\]"
set_location_assignment Pin_B13 -to "mictor\[8\]"
set_location_assignment Pin_C10 -to "mictor\[9\]"
set_location_assignment Pin_D11 -to "mictor\[10\]"
set_location_assignment Pin_D13 -to "mictor\[11\]"
set_location_assignment Pin_E13 -to "mictor\[12\]"
set_location_assignment Pin_D12 -to "mictor\[13\]"
set_location_assignment Pin_E12 -to "mictor\[14\]"
set_location_assignment Pin_E10 -to "mictor\[15\]"
set_location_assignment Pin_G5 -to "mictor_clk\[0\]"
set_location_assignment Pin_A9 -to "mictor\[16\]"
set_location_assignment Pin_B9 -to "mictor\[17\]"
set_location_assignment Pin_B8 -to "mictor\[18\]"
set_location_assignment Pin_A8 -to "mictor\[19\]"
set_location_assignment Pin_C8 -to "mictor\[20\]"
set_location_assignment Pin_D8 -to "mictor\[21\]"
set_location_assignment Pin_A7 -to "mictor\[22\]"
set_location_assignment Pin_B7 -to "mictor\[23\]"
set_location_assignment Pin_C7 -to "mictor\[24\]"
set_location_assignment Pin_A6 -to "mictor\[25\]"
set_location_assignment Pin_C6 -to "mictor\[26\]"
set_location_assignment Pin_D6 -to "mictor\[27\]"
set_location_assignment Pin_D9 -to "mictor\[28\]"
set_location_assignment Pin_D7 -to "mictor\[29\]"
set_location_assignment Pin_E8 -to "mictor\[30\]"
set_location_assignment Pin_E6 -to "mictor\[31\]"
set_location_assignment Pin_C5 -to "mictor_clk\[1\]"
puts "   Assigned: Mictor header pins."

# assign serial DAC
set_location_assignment Pin_AE8 -to "dac_clk\[0\]"
set_location_assignment Pin_Y10 -to "dac_clk\[1\]"
set_location_assignment Pin_AB7 -to "dac_clk\[2\]"
set_location_assignment Pin_AC5 -to "dac_clk\[3\]"
set_location_assignment Pin_AG20 -to "dac_clk\[4\]"
set_location_assignment Pin_AB22 -to "dac_clk\[5\]"
set_location_assignment Pin_AB20 -to "dac_clk\[6\]"
set_location_assignment Pin_AB18 -to "dac_clk\[7\]"
set_location_assignment Pin_AG10 -to "dac_dat\[0\]"
set_location_assignment Pin_Y11 -to "dac_dat\[1\]"
set_location_assignment Pin_AB8 -to "dac_dat\[2\]"
set_location_assignment Pin_AC6 -to "dac_dat\[3\]"
set_location_assignment Pin_AE23 -to "dac_dat\[4\]"
set_location_assignment Pin_AE25 -to "dac_dat\[5\]"
set_location_assignment Pin_Y20 -to "dac_dat\[6\]"
set_location_assignment Pin_V18 -to "dac_dat\[7\]"
set_location_assignment Pin_AH3 -to "bias_dac_ncs\[0\]"
set_location_assignment Pin_V11 -to "bias_dac_ncs\[1\]"
set_location_assignment Pin_AA9 -to "bias_dac_ncs\[2\]"
set_location_assignment Pin_AB9 -to "bias_dac_ncs\[3\]"
set_location_assignment Pin_AH16 -to "bias_dac_ncs\[4\]"
set_location_assignment Pin_AC24 -to "bias_dac_ncs\[5\]"
set_location_assignment Pin_AD24 -to "bias_dac_ncs\[6\]"
set_location_assignment Pin_AC22 -to "bias_dac_ncs\[7\]"
set_location_assignment Pin_AE7 -to "offset_dac_ncs\[0\]"
set_location_assignment Pin_Y9 -to "offset_dac_ncs\[1\]"
set_location_assignment Pin_AA10 -to "offset_dac_ncs\[2\]"
set_location_assignment Pin_AB12 -to "offset_dac_ncs\[3\]"
set_location_assignment Pin_AF18 -to "offset_dac_ncs\[4\]"
set_location_assignment Pin_AC23 -to "offset_dac_ncs\[5\]"
set_location_assignment Pin_AB21 -to "offset_dac_ncs\[6\]"
set_location_assignment Pin_AC20 -to "offset_dac_ncs\[7\]"
puts "   Assigned: Serial DAC pins."


# assign parallel DAC
set_location_assignment Pin_N10 -to "dac_FB_clk\[0\]"
set_location_assignment Pin_N9 -to "dac_FB1_dat\[0\]"
set_location_assignment Pin_M3 -to "dac_FB1_dat\[1\]"
set_location_assignment Pin_M4 -to "dac_FB1_dat\[2\]"
set_location_assignment Pin_N5 -to "dac_FB1_dat\[3\]"
set_location_assignment Pin_N6 -to "dac_FB1_dat\[4\]"
set_location_assignment Pin_L1 -to "dac_FB1_dat\[5\]"
set_location_assignment Pin_L2 -to "dac_FB1_dat\[6\]"
set_location_assignment Pin_N7 -to "dac_FB1_dat\[7\]"
set_location_assignment Pin_N8 -to "dac_FB1_dat\[8\]"
set_location_assignment Pin_L3 -to "dac_FB1_dat\[9\]"
set_location_assignment Pin_L4 -to "dac_FB1_dat\[10\]"
set_location_assignment Pin_N4 -to "dac_FB1_dat\[11\]"
set_location_assignment Pin_N3 -to "dac_FB1_dat\[12\]"
set_location_assignment Pin_K1 -to "dac_FB1_dat\[13\]"

set_location_assignment Pin_C2 -to "dac_FB_clk\[1\]"
set_location_assignment Pin_C1 -to "dac_FB2_dat\[0\]"
set_location_assignment Pin_H5 -to "dac_FB2_dat\[1\]"
set_location_assignment Pin_H6 -to "dac_FB2_dat\[2\]"
set_location_assignment Pin_D2 -to "dac_FB2_dat\[3\]"
set_location_assignment Pin_D1 -to "dac_FB2_dat\[4\]"
set_location_assignment Pin_H7 -to "dac_FB2_dat\[5\]"
set_location_assignment Pin_H8 -to "dac_FB2_dat\[6\]"
set_location_assignment Pin_E2 -to "dac_FB2_dat\[7\]"
set_location_assignment Pin_E1 -to "dac_FB2_dat\[8\]"
set_location_assignment Pin_J5 -to "dac_FB2_dat\[9\]"
set_location_assignment Pin_J6 -to "dac_FB2_dat\[10\]"
set_location_assignment Pin_F4 -to "dac_FB2_dat\[11\]"
set_location_assignment Pin_F3 -to "dac_FB2_dat\[12\]"
set_location_assignment Pin_K6 -to "dac_FB2_dat\[13\]"

set_location_assignment Pin_F2 -to "dac_FB_clk\[2\]"
set_location_assignment Pin_F1 -to "dac_FB3_dat\[0\]"
set_location_assignment Pin_J8 -to "dac_FB3_dat\[1\]"
set_location_assignment Pin_J7 -to "dac_FB3_dat\[2\]"
set_location_assignment Pin_G3 -to "dac_FB3_dat\[3\]"
set_location_assignment Pin_G4 -to "dac_FB3_dat\[4\]"
set_location_assignment Pin_K8 -to "dac_FB3_dat\[5\]"
set_location_assignment Pin_K7 -to "dac_FB3_dat\[6\]"
set_location_assignment Pin_G2 -to "dac_FB3_dat\[7\]"
set_location_assignment Pin_G1 -to "dac_FB3_dat\[8\]"
set_location_assignment Pin_L7 -to "dac_FB3_dat\[9\]"
set_location_assignment Pin_L8 -to "dac_FB3_dat\[10\]"
set_location_assignment Pin_H4 -to "dac_FB3_dat\[11\]"
set_location_assignment Pin_H3 -to "dac_FB3_dat\[12\]"
set_location_assignment Pin_L6 -to "dac_FB3_dat\[13\]"

set_location_assignment Pin_M10 -to "dac_FB_clk\[3\]"
set_location_assignment Pin_M9 -to "dac_FB4_dat\[0\]"
set_location_assignment Pin_K4 -to "dac_FB4_dat\[1\]"
set_location_assignment Pin_K3 -to "dac_FB4_dat\[2\]"
set_location_assignment Pin_M6 -to "dac_FB4_dat\[3\]"
set_location_assignment Pin_M5 -to "dac_FB4_dat\[4\]"
set_location_assignment Pin_J1 -to "dac_FB4_dat\[5\]"
set_location_assignment Pin_J2 -to "dac_FB4_dat\[6\]"
set_location_assignment Pin_M8 -to "dac_FB4_dat\[7\]"
set_location_assignment Pin_M7 -to "dac_FB4_dat\[8\]"
set_location_assignment Pin_J3 -to "dac_FB4_dat\[9\]"
set_location_assignment Pin_J4 -to "dac_FB4_dat\[10\]"
set_location_assignment Pin_L10 -to "dac_FB4_dat\[11\]"
set_location_assignment Pin_L9 -to "dac_FB4_dat\[12\]"
set_location_assignment Pin_H1 -to "dac_FB4_dat\[13\]"

set_location_assignment Pin_AG12 -to "dac_FB_clk\[4\]"
set_location_assignment Pin_AF12 -to "dac_FB5_dat\[0\]"
set_location_assignment Pin_AE12 -to "dac_FB5_dat\[1\]"
set_location_assignment Pin_AG13 -to "dac_FB5_dat\[2\]"
set_location_assignment Pin_AD12 -to "dac_FB5_dat\[3\]"
set_location_assignment Pin_AF13 -to "dac_FB5_dat\[4\]"
set_location_assignment Pin_AE13 -to "dac_FB5_dat\[5\]"
set_location_assignment Pin_AD13 -to "dac_FB5_dat\[6\]"
set_location_assignment Pin_AE16 -to "dac_FB5_dat\[7\]"
set_location_assignment Pin_AF16 -to "dac_FB5_dat\[8\]"
set_location_assignment Pin_AD16 -to "dac_FB5_dat\[9\]"
set_location_assignment Pin_AG16 -to "dac_FB5_dat\[10\]"
set_location_assignment Pin_AD17 -to "dac_FB5_dat\[11\]"
set_location_assignment Pin_AE17 -to "dac_FB5_dat\[12\]"
set_location_assignment Pin_AG17 -to "dac_FB5_dat\[13\]"

set_location_assignment Pin_AH4 -to "dac_FB_clk\[5\]"
set_location_assignment Pin_AE5 -to "dac_FB6_dat\[0\]"
set_location_assignment Pin_AG3 -to "dac_FB6_dat\[1\]"
set_location_assignment Pin_AG5 -to "dac_FB6_dat\[2\]"
set_location_assignment Pin_AG4 -to "dac_FB6_dat\[3\]"
set_location_assignment Pin_AF4 -to "dac_FB6_dat\[4\]"
set_location_assignment Pin_AH5 -to "dac_FB6_dat\[5\]"
set_location_assignment Pin_AF5 -to "dac_FB6_dat\[6\]"
set_location_assignment Pin_AE6 -to "dac_FB6_dat\[7\]"
set_location_assignment Pin_AG6 -to "dac_FB6_dat\[8\]"
set_location_assignment Pin_AH6 -to "dac_FB6_dat\[9\]"
set_location_assignment Pin_AD6 -to "dac_FB6_dat\[10\]"
set_location_assignment Pin_AF7 -to "dac_FB6_dat\[11\]"
set_location_assignment Pin_AH7 -to "dac_FB6_dat\[12\]"
set_location_assignment Pin_AG7 -to "dac_FB6_dat\[13\]"

set_location_assignment Pin_AG18 -to "dac_FB_clk\[6\]"
set_location_assignment Pin_AE18 -to "dac_FB7_dat\[0\]"
set_location_assignment Pin_AD18 -to "dac_FB7_dat\[1\]"
set_location_assignment Pin_AH19 -to "dac_FB7_dat\[2\]"
set_location_assignment Pin_AG19 -to "dac_FB7_dat\[3\]"
set_location_assignment Pin_AF19 -to "dac_FB7_dat\[4\]"
set_location_assignment Pin_AD19 -to "dac_FB7_dat\[5\]"
set_location_assignment Pin_AE19 -to "dac_FB7_dat\[6\]"
set_location_assignment Pin_AH20 -to "dac_FB7_dat\[7\]"
set_location_assignment Pin_AH21 -to "dac_FB7_dat\[8\]"
set_location_assignment Pin_AF20 -to "dac_FB7_dat\[9\]"
set_location_assignment Pin_AE20 -to "dac_FB7_dat\[10\]"
set_location_assignment Pin_AF21 -to "dac_FB7_dat\[11\]"
set_location_assignment Pin_AG21 -to "dac_FB7_dat\[12\]"
set_location_assignment Pin_AE21 -to "dac_FB7_dat\[13\]"

set_location_assignment Pin_AG8 -to "dac_FB_clk\[7\]"
set_location_assignment Pin_AF8 -to "dac_FB8_dat\[0\]"
set_location_assignment Pin_AD8 -to "dac_FB8_dat\[1\]"
set_location_assignment Pin_AH9 -to "dac_FB8_dat\[2\]"
set_location_assignment Pin_AH8 -to "dac_FB8_dat\[3\]"
set_location_assignment Pin_AE9 -to "dac_FB8_dat\[4\]"
set_location_assignment Pin_AF9 -to "dac_FB8_dat\[5\]"
set_location_assignment Pin_AG9 -to "dac_FB8_dat\[6\]"
set_location_assignment Pin_AD10 -to "dac_FB8_dat\[7\]"
set_location_assignment Pin_AF10 -to "dac_FB8_dat\[8\]"
set_location_assignment Pin_AH10 -to "dac_FB8_dat\[9\]"
set_location_assignment Pin_AE10 -to "dac_FB8_dat\[10\]"
set_location_assignment Pin_AF11 -to "dac_FB8_dat\[11\]"
set_location_assignment Pin_AE11 -to "dac_FB8_dat\[12\]"
set_location_assignment Pin_AH11 -to "dac_FB8_dat\[13\]"
puts "   Assigned: Parallel DAC pins."


# assign ADC
set_location_assignment Pin_AB6 -to "adc1_clk"
set_location_assignment Pin_W22 -to "adc1_rdy"
set_location_assignment Pin_AG22 -to "adc1_ovr"
set_location_assignment Pin_AB26 -to "adc1_dat\[0\]"
set_location_assignment Pin_AB25 -to "adc1_dat\[1\]"
set_location_assignment Pin_W23 -to "adc1_dat\[2\]"
set_location_assignment Pin_W24 -to "adc1_dat\[3\]"
set_location_assignment Pin_AB28 -to "adc1_dat\[4\]"
set_location_assignment Pin_AB27 -to "adc1_dat\[5\]"
set_location_assignment Pin_V22 -to "adc1_dat\[6\]"
set_location_assignment Pin_V21 -to "adc1_dat\[7\]"
set_location_assignment Pin_AA25 -to "adc1_dat\[8\]"
set_location_assignment Pin_AA26 -to "adc1_dat\[9\]"
set_location_assignment Pin_V24 -to "adc1_dat\[10\]"
set_location_assignment Pin_V23 -to "adc1_dat\[11\]"
set_location_assignment Pin_AA28 -to "adc1_dat\[12\]"
set_location_assignment Pin_AA27 -to "adc1_dat\[13\]"

set_location_assignment Pin_AA8 -to "adc2_clk"
set_location_assignment Pin_AH22 -to "adc2_rdy"
set_location_assignment Pin_N20 -to "adc2_ovr"
set_location_assignment Pin_AF22 -to "adc2_dat\[0\]"
set_location_assignment Pin_AE22 -to "adc2_dat\[1\]"
set_location_assignment Pin_AH23 -to "adc2_dat\[2\]"
set_location_assignment Pin_AF23 -to "adc2_dat\[3\]"
set_location_assignment Pin_AD23 -to "adc2_dat\[4\]"
set_location_assignment Pin_AG23 -to "adc2_dat\[5\]"
set_location_assignment Pin_AH24 -to "adc2_dat\[6\]"
set_location_assignment Pin_AE24 -to "adc2_dat\[7\]"
set_location_assignment Pin_AG24 -to "adc2_dat\[8\]"
set_location_assignment Pin_AF25 -to "adc2_dat\[9\]"
set_location_assignment Pin_AH25 -to "adc2_dat\[10\]"
set_location_assignment Pin_AG25 -to "adc2_dat\[11\]"
set_location_assignment Pin_AH26 -to "adc2_dat\[12\]"
set_location_assignment Pin_AG26 -to "adc2_dat\[13\]"

set_location_assignment Pin_AA6 -to "adc3_clk"
set_location_assignment Pin_N19 -to "adc3_rdy"
set_location_assignment Pin_AA21 -to "adc3_ovr"
set_location_assignment Pin_M25 -to "adc3_dat\[0\]"
set_location_assignment Pin_M26 -to "adc3_dat\[1\]"
set_location_assignment Pin_N22 -to "adc3_dat\[2\]"
set_location_assignment Pin_N21 -to "adc3_dat\[3\]"
set_location_assignment Pin_L27 -to "adc3_dat\[4\]"
set_location_assignment Pin_L28 -to "adc3_dat\[5\]"
set_location_assignment Pin_N24 -to "adc3_dat\[6\]"
set_location_assignment Pin_N23 -to "adc3_dat\[7\]"
set_location_assignment Pin_L25 -to "adc3_dat\[8\]"
set_location_assignment Pin_L26 -to "adc3_dat\[9\]"
set_location_assignment Pin_N26 -to "adc3_dat\[10\]"
set_location_assignment Pin_N25 -to "adc3_dat\[11\]"
set_location_assignment Pin_K27 -to "adc3_dat\[12\]"
set_location_assignment Pin_K28 -to "adc3_dat\[13\]"

set_location_assignment Pin_Y5 -to "adc4_clk"
set_location_assignment Pin_AA22 -to "adc4_rdy"
set_location_assignment Pin_W27 -to "adc4_ovr"
set_location_assignment Pin_AF28 -to "adc4_dat\[0\]"
set_location_assignment Pin_AF27 -to "adc4_dat\[1\]"
set_location_assignment Pin_AA23 -to "adc4_dat\[2\]"
set_location_assignment Pin_AA24 -to "adc4_dat\[3\]"
set_location_assignment Pin_AE28 -to "adc4_dat\[4\]"
set_location_assignment Pin_AE27 -to "adc4_dat\[5\]"
set_location_assignment Pin_Y24 -to "adc4_dat\[6\]"
set_location_assignment Pin_Y23 -to "adc4_dat\[7\]"
set_location_assignment Pin_AD28 -to "adc4_dat\[8\]"
set_location_assignment Pin_AD27 -to "adc4_dat\[9\]"
set_location_assignment Pin_Y21 -to "adc4_dat\[10\]"
set_location_assignment Pin_Y22 -to "adc4_dat\[11\]"
set_location_assignment Pin_AC28 -to "adc4_dat\[12\]"
set_location_assignment Pin_AC27 -to "adc4_dat\[13\]"

set_location_assignment Pin_Y8 -to "adc5_clk"
set_location_assignment Pin_W28 -to "adc5_rdy"
set_location_assignment Pin_M20 -to "adc5_ovr"
set_location_assignment Pin_U20 -to "adc5_dat\[0\]"
set_location_assignment Pin_U19 -to "adc5_dat\[1\]"
set_location_assignment Pin_W25 -to "adc5_dat\[2\]"
set_location_assignment Pin_W26 -to "adc5_dat\[3\]"
set_location_assignment Pin_U23 -to "adc5_dat\[4\]"
set_location_assignment Pin_U24 -to "adc5_dat\[5\]"
set_location_assignment Pin_Y27 -to "adc5_dat\[6\]"
set_location_assignment Pin_Y28 -to "adc5_dat\[7\]"
set_location_assignment Pin_U22 -to "adc5_dat\[8\]"
set_location_assignment Pin_U21 -to "adc5_dat\[9\]"
set_location_assignment Pin_Y25 -to "adc5_dat\[10\]"
set_location_assignment Pin_Y26 -to "adc5_dat\[11\]"
set_location_assignment Pin_V20 -to "adc5_dat\[12\]"
set_location_assignment Pin_V19 -to "adc5_dat\[13\]"

set_location_assignment Pin_V10 -to "adc6_clk"
set_location_assignment Pin_M19 -to "adc6_rdy"
set_location_assignment Pin_F28 -to "adc6_ovr"
set_location_assignment Pin_K26 -to "adc6_dat\[0\]"
set_location_assignment Pin_K25 -to "adc6_dat\[1\]"
set_location_assignment Pin_M24 -to "adc6_dat\[2\]"
set_location_assignment Pin_M23 -to "adc6_dat\[3\]"
set_location_assignment Pin_J27 -to "adc6_dat\[4\]"
set_location_assignment Pin_J28 -to "adc6_dat\[5\]"
set_location_assignment Pin_M22 -to "adc6_dat\[6\]"
set_location_assignment Pin_M21 -to "adc6_dat\[7\]"
set_location_assignment Pin_J25 -to "adc6_dat\[8\]"
set_location_assignment Pin_J26 -to "adc6_dat\[9\]"
set_location_assignment Pin_L20 -to "adc6_dat\[10\]"
set_location_assignment Pin_L19 -to "adc6_dat\[11\]"
set_location_assignment Pin_H27 -to "adc6_dat\[12\]"
set_location_assignment Pin_H28 -to "adc6_dat\[13\]"

set_location_assignment Pin_U8 -to "adc7_clk"
set_location_assignment Pin_F27 -to "adc7_rdy"
set_location_assignment Pin_C28 -to "adc7_ovr"
set_location_assignment Pin_J22 -to "adc7_dat\[0\]"
set_location_assignment Pin_J21 -to "adc7_dat\[1\]"
set_location_assignment Pin_G25 -to "adc7_dat\[2\]"
set_location_assignment Pin_G26 -to "adc7_dat\[3\]"
set_location_assignment Pin_K22 -to "adc7_dat\[4\]"
set_location_assignment Pin_K21 -to "adc7_dat\[5\]"
set_location_assignment Pin_G28 -to "adc7_dat\[6\]"
set_location_assignment Pin_G27 -to "adc7_dat\[7\]"
set_location_assignment Pin_L21 -to "adc7_dat\[8\]"
set_location_assignment Pin_L22 -to "adc7_dat\[9\]"
set_location_assignment Pin_H25 -to "adc7_dat\[10\]"
set_location_assignment Pin_H26 -to "adc7_dat\[11\]"
set_location_assignment Pin_L24 -to "adc7_dat\[12\]"
set_location_assignment Pin_L23 -to "adc7_dat\[13\]"

set_location_assignment Pin_U5 -to "adc8_clk"
set_location_assignment Pin_C27 -to "adc8_rdy"
set_location_assignment Pin_W21 -to "adc8_ovr"
set_location_assignment Pin_H23 -to "adc8_dat\[0\]"
set_location_assignment Pin_H24 -to "adc8_dat\[1\]"
set_location_assignment Pin_D28 -to "adc8_dat\[2\]"
set_location_assignment Pin_D27 -to "adc8_dat\[3\]"
set_location_assignment Pin_H21 -to "adc8_dat\[4\]"
set_location_assignment Pin_H22 -to "adc8_dat\[5\]"
set_location_assignment Pin_E28 -to "adc8_dat\[6\]"
set_location_assignment Pin_E27 -to "adc8_dat\[7\]"
set_location_assignment Pin_J23 -to "adc8_dat\[8\]"
set_location_assignment Pin_J24 -to "adc8_dat\[9\]"
set_location_assignment Pin_F26 -to "adc8_dat\[10\]"
set_location_assignment Pin_F25 -to "adc8_dat\[11\]"
set_location_assignment Pin_K24 -to "adc8_dat\[12\]"
set_location_assignment Pin_K23 -to "adc8_dat\[13\]"
puts "   Assigned: ADC pins."


# recompile to commit
puts "\nInfo: Recompiling to commit assignments..."
execute_flow -compile


puts "\nInfo: Generating .pof file after waiting 10s to let compilation finish."
after 10000 "exec quartus_cpf -c readout_card_sof2pof.cof"


puts "\nInfo: Process completed."