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
# ac_pin_assign.tcl
#
# Project:       SCUBA-2
# Author:        Ernie Lin
# Organization:  UBC
#
# Description:
# This script allows you to make pin assignments to the address card
#
# Revision history:
#
# $Log: ac_pin_assign.tcl,v $
# Revision 1.12  2004/05/25 21:42:17  mandana
# changed the LSB to MSB order on bus 0 to 9 to the correct order
#
# Revision 1.11  2004/05/17 00:12:57  erniel
# renamed PLL 5 input pin to inclk
#
# Revision 1.10  2004/05/15 22:59:25  erniel
# unrolled foreach loops
#
# Revision 1.9  2004/05/14 20:25:24  erniel
# added PLL section
#
# Revision 1.8  2004/05/14 19:25:36  erniel
# initial version
#
#
#
############################################################################

# print welcome message
puts "\n\nAddress Card Pin Assignment Script v1.0"
puts "---------------------------------------"


# include Quartus Tcl API
package require ::quartus::project
package require ::quartus::flow


# get entity name
set top_name [get_project_settings -cmp]
puts "\nInfo: Top-level entity is $top_name."

puts "\nInfo: Assigning pins:"


# assign device parameters
cmp add_assignment $top_name "" "" DEVICE EP1S10F780C5
cmp add_assignment $top_name "" "" RESERVE_ALL_UNUSED_PINS "AS INPUT TRI-STATED"

# dev_clr_n disabled
cmp add_assignment $top_name "" "" ENABLE_DEVICE_WIDE_RESET OFF
puts "   Assigned: EP1S10 device parameters."

# assign rst_n
cmp add_assignment $top_name "" rst_n LOCATION "Pin_AC9"
puts "   Assigned: RST_N pin."

# assign LEDs
cmp add_assignment $top_name "" red_led LOCATION "Pin_V27"
cmp add_assignment $top_name "" ylw_led LOCATION "Pin_T24"
cmp add_assignment $top_name "" grn_led LOCATION "Pin_T23"
puts "   Assigned: LED pins."


# assign dip switches
cmp add_assignment $top_name "" dip_sw3 LOCATION "Pin_M2"
cmp add_assignment $top_name "" dip_sw4 LOCATION "Pin_N1"
puts "   Assigned: DIP switch pins."


# assign watchdog
cmp add_assignment $top_name "" wdog LOCATION "Pin_T28"
puts "   Assigned: Watchdog pin."


# assign ID pins
cmp add_assignment $top_name "" "slot_id\[0\]" LOCATION "Pin_V25"
cmp add_assignment $top_name "" "slot_id\[1\]" LOCATION "Pin_V26"
cmp add_assignment $top_name "" "slot_id\[2\]" LOCATION "Pin_T25"
cmp add_assignment $top_name "" "slot_id\[3\]" LOCATION "Pin_T26"
cmp add_assignment $top_name "" card_id LOCATION "Pin_T21"
puts "   Assigned: ID pins."


# assign LVDS pins
# for LVDS clk, see PLL section
cmp add_assignment $top_name "" lvds_cmd LOCATION "Pin_V23"
cmp add_assignment $top_name "" lvds_sync LOCATION "Pin_AA28"
cmp add_assignment $top_name "" lvds_spare LOCATION "Pin_V24"
cmp add_assignment $top_name "" lvds_txa LOCATION "Pin_V19"
cmp add_assignment $top_name "" lvds_txb LOCATION "Pin_V20"
puts "   Assigned: LVDS pins."


# assign TTL pins
cmp add_assignment $top_name "" "ttl_nrx\[1\]" LOCATION "Pin_U19"
cmp add_assignment $top_name "" "ttl_nrx\[2\]" LOCATION "Pin_U20"
cmp add_assignment $top_name "" "ttl_nrx\[3\]" LOCATION "Pin_W28"
cmp add_assignment $top_name "" "ttl_tx\[1\]" LOCATION "Pin_Y26"
cmp add_assignment $top_name "" "ttl_tx\[2\]" LOCATION "Pin_U21"
cmp add_assignment $top_name "" "ttl_tx\[3\]" LOCATION "Pin_Y28"
cmp add_assignment $top_name "" "ttl_txena\[1\]" LOCATION "Pin_Y25"
cmp add_assignment $top_name "" "ttl_txena\[2\]" LOCATION "Pin_U22"
cmp add_assignment $top_name "" "ttl_txena\[3\]" LOCATION "Pin_Y27"
puts "   Assigned: Spare TTL pins."


# assign PLL pins
# PLL5 in     = inclk  (from LVDS)
# PLL5 out[0] = outclk (for observing PLL)
# PLL5 out[1] = N/C
# PLL5 out[2] = N/C
# PLL5 out[3] = N/C
# PLL6 in     = N/C
# PLL6 out[0] = N/C
# PLL6 out[1] = N/C
# PLL6 out[2] = N/C
# PLL6 out[3] = N/C
cmp add_assignment $top_name "" inclk LOCATION "Pin_K17"
cmp add_assignment $top_name "" outclk LOCATION "Pin_E15"
cmp add_assignment $top_name "" "pll5_out\[1\]" LOCATION "Pin_K14"
cmp add_assignment $top_name "" "pll5_out\[2\]" LOCATION "Pin_C15"
cmp add_assignment $top_name "" "pll5_out\[3\]" LOCATION "Pin_K16"
cmp add_assignment $top_name "" "pll6_in" LOCATION "Pin_AC17"
cmp add_assignment $top_name "" "pll6_out\[0\]" LOCATION "Pin_AD15"
cmp add_assignment $top_name "" "pll6_out\[1\]" LOCATION "Pin_W14"
cmp add_assignment $top_name "" "pll6_out\[2\]" LOCATION "Pin_AF15"
cmp add_assignment $top_name "" "pll6_out\[3\]" LOCATION "Pin_W16"
puts "   Assigned: PLL pins."


# assign power supply interface
cmp add_assignment $top_name "" n7vok LOCATION "Pin_T22"
puts "   Assigned: Power supply status pin."


# assign SMB pins
cmp add_assignment $top_name "" smb_clk LOCATION "Pin_U23"
cmp add_assignment $top_name "" smb_data LOCATION "Pin_W26"
cmp add_assignment $top_name "" smb_nalert LOCATION "Pin_W25"
puts "   Assigned: SMB interface pins."


# assign 2x8 test header pins
cmp add_assignment $top_name "" rs232_rx LOCATION "Pin_AF9"
cmp add_assignment $top_name "" rs232_tx LOCATION "Pin_AG11"
cmp add_assignment $top_name "" "test\[3\]" LOCATION "Pin_AD10"
cmp add_assignment $top_name "" "test\[4\]" LOCATION "Pin_AH11"
cmp add_assignment $top_name "" "test\[5\]" LOCATION "Pin_AE10"
cmp add_assignment $top_name "" "test\[6\]" LOCATION "Pin_AF11"
cmp add_assignment $top_name "" "test\[7\]" LOCATION "Pin_AD8"
cmp add_assignment $top_name "" "test\[8\]" LOCATION "Pin_AH10"
cmp add_assignment $top_name "" "test\[9\]" LOCATION "Pin_AE9"
cmp add_assignment $top_name "" "test\[10\]" LOCATION "Pin_AE11"
cmp add_assignment $top_name "" "test\[11\]" LOCATION "Pin_AF8"
cmp add_assignment $top_name "" "test\[12\]" LOCATION "Pin_AH9"
cmp add_assignment $top_name "" "test\[13\]" LOCATION "Pin_AG8"
cmp add_assignment $top_name "" "test\[14\]" LOCATION "Pin_AF10"
cmp add_assignment $top_name "" "test\[15\]" LOCATION "Pin_AG9"
cmp add_assignment $top_name "" "test\[16\]" LOCATION "Pin_AH8"
puts "   Assigned: 2x8 test header pins."


#assign mictor header pins (odd pod = 1-16, even pod = 17-32)
cmp add_assignment $top_name "" "mictor\[1\]" LOCATION "Pin_AD19"
cmp add_assignment $top_name "" "mictor\[2\]" LOCATION "Pin_AD18"
cmp add_assignment $top_name "" "mictor\[3\]" LOCATION "Pin_AE19"
cmp add_assignment $top_name "" "mictor\[4\]" LOCATION "Pin_AE18"
cmp add_assignment $top_name "" "mictor\[5\]" LOCATION "Pin_AF19"
cmp add_assignment $top_name "" "mictor\[6\]" LOCATION "Pin_AG18"
cmp add_assignment $top_name "" "mictor\[7\]" LOCATION "Pin_AE20"
cmp add_assignment $top_name "" "mictor\[8\]" LOCATION "Pin_AH19"
cmp add_assignment $top_name "" "mictor\[9\]" LOCATION "Pin_AG19"
cmp add_assignment $top_name "" "mictor\[10\]" LOCATION "Pin_AH20"
cmp add_assignment $top_name "" "mictor\[11\]" LOCATION "Pin_AF20"
cmp add_assignment $top_name "" "mictor\[12\]" LOCATION "Pin_AH21"
cmp add_assignment $top_name "" "mictor\[13\]" LOCATION "Pin_AG21"
cmp add_assignment $top_name "" "mictor\[14\]" LOCATION "Pin_AF21"
cmp add_assignment $top_name "" "mictor\[15\]" LOCATION "Pin_AE21"
cmp add_assignment $top_name "" "mictor\[16\]" LOCATION "Pin_Y17"
cmp add_assignment $top_name "" "mictor\[17\]" LOCATION "Pin_AH26"
cmp add_assignment $top_name "" "mictor\[18\]" LOCATION "Pin_AG26"
cmp add_assignment $top_name "" "mictor\[19\]" LOCATION "Pin_AH25"
cmp add_assignment $top_name "" "mictor\[20\]" LOCATION "Pin_AG25"
cmp add_assignment $top_name "" "mictor\[21\]" LOCATION "Pin_AH24"
cmp add_assignment $top_name "" "mictor\[22\]" LOCATION "Pin_AG24"
cmp add_assignment $top_name "" "mictor\[23\]" LOCATION "Pin_AH23"
cmp add_assignment $top_name "" "mictor\[24\]" LOCATION "Pin_AF25"
cmp add_assignment $top_name "" "mictor\[25\]" LOCATION "Pin_AH22"
cmp add_assignment $top_name "" "mictor\[26\]" LOCATION "Pin_AG22"
cmp add_assignment $top_name "" "mictor\[27\]" LOCATION "Pin_AG23"
cmp add_assignment $top_name "" "mictor\[28\]" LOCATION "Pin_AF22"
cmp add_assignment $top_name "" "mictor\[29\]" LOCATION "Pin_AF23"
cmp add_assignment $top_name "" "mictor\[30\]" LOCATION "Pin_AD21"
cmp add_assignment $top_name "" "mictor\[31\]" LOCATION "Pin_AE22"
cmp add_assignment $top_name "" "mictor\[32\]" LOCATION "Pin_AE24"
cmp add_assignment $top_name "" "mictorclk\[1\]" LOCATION "Pin_AB17"
cmp add_assignment $top_name "" "mictorclk\[2\]" LOCATION "Pin_AD23"
puts "   Assigned: Mictor header pins."


# assign EEPROM pins
cmp add_assignment $top_name "" eeprom_si LOCATION "Pin_T20"
cmp add_assignment $top_name "" eeprom_so LOCATION "Pin_T19"
cmp add_assignment $top_name "" eeprom_sck LOCATION "Pin_U26"
cmp add_assignment $top_name "" eeprom_cs LOCATION "Pin_U25"
puts "   Assigned: EEPROM pins."


############################################################################
# Address Card DAC data buses
#
# bus_0 goes to the DACs for Rows 00, 02, 05, 07
# bus_1 goes to the DACs for Rows 01, 03, 04, 06
# bus_2 goes to the DACs for Rows 08, 10, 13, 15
# bus_3 goes to the DACs for Rows 09, 11, 12, 14
# bus_4 goes to the DACs for Rows 16, 18, 21, 23
# bus_5 goes to the DACs for Rows 17, 19, 20, 22
# bus_6 goes to the DACs for Rows 24, 26, 29, 31
# bus_7 goes to the DACs for Rows 25, 27, 28, 30
# bus_8 goes to the DACs for Rows 32, 34, 37, 39
# bus_9 goes to the DACs for Rows 33, 35, 36, 38
# bus_10 goes to the DAC for Row 40
#
# assign DAC data bus 0
cmp add_assignment $top_name "" "dac_data0\[13\]" LOCATION "Pin_M27"
cmp add_assignment $top_name "" "dac_data0\[12\]" LOCATION "Pin_L27"
cmp add_assignment $top_name "" "dac_data0\[11\]" LOCATION "Pin_H27"
cmp add_assignment $top_name "" "dac_data0\[10\]" LOCATION "Pin_L26"
cmp add_assignment $top_name "" "dac_data0\[9\]" LOCATION "Pin_L25"
cmp add_assignment $top_name "" "dac_data0\[8\]" LOCATION "Pin_H25"
cmp add_assignment $top_name "" "dac_data0\[7\]" LOCATION "Pin_N24"
cmp add_assignment $top_name "" "dac_data0\[6\]" LOCATION "Pin_N23"
cmp add_assignment $top_name "" "dac_data0\[5\]" LOCATION "Pin_L23"
cmp add_assignment $top_name "" "dac_data0\[4\]" LOCATION "Pin_N22"
cmp add_assignment $top_name "" "dac_data0\[3\]" LOCATION "Pin_N21"
cmp add_assignment $top_name "" "dac_data0\[2\]" LOCATION "Pin_L21"
cmp add_assignment $top_name "" "dac_data0\[1\]" LOCATION "Pin_N20"
cmp add_assignment $top_name "" "dac_data0\[0\]" LOCATION "Pin_N19"
puts "   Assigned: DAC data bus #0 pins."


# assign DAC data bus 1
cmp add_assignment $top_name "" "dac_data1\[13\]" LOCATION "Pin_M24"
cmp add_assignment $top_name "" "dac_data1\[12\]" LOCATION "Pin_M23"
cmp add_assignment $top_name "" "dac_data1\[11\]" LOCATION "Pin_L24"
cmp add_assignment $top_name "" "dac_data1\[10\]" LOCATION "Pin_K28"
cmp add_assignment $top_name "" "dac_data1\[9\]"  LOCATION "Pin_K27"
cmp add_assignment $top_name "" "dac_data1\[8\]"  LOCATION "Pin_J28"
cmp add_assignment $top_name "" "dac_data1\[7\]"  LOCATION "Pin_J27"
cmp add_assignment $top_name "" "dac_data1\[6\]"  LOCATION "Pin_H28"
cmp add_assignment $top_name "" "dac_data1\[5\]"  LOCATION "Pin_J26"
cmp add_assignment $top_name "" "dac_data1\[4\]"  LOCATION "Pin_J25"
cmp add_assignment $top_name "" "dac_data1\[3\]"  LOCATION "Pin_H26"
cmp add_assignment $top_name "" "dac_data1\[2\]"  LOCATION "Pin_M22"
cmp add_assignment $top_name "" "dac_data1\[1\]"  LOCATION "Pin_L22"
cmp add_assignment $top_name "" "dac_data1\[0\]"  LOCATION "Pin_M21"
puts "   Assigned: DAC data bus #1 pins."


# assign DAC data bus 2
cmp add_assignment $top_name "" "dac_data2\[13\]" LOCATION "Pin_H4"
cmp add_assignment $top_name "" "dac_data2\[12\]" LOCATION "Pin_H3"
cmp add_assignment $top_name "" "dac_data2\[11\]" LOCATION "Pin_G2"
cmp add_assignment $top_name "" "dac_data2\[10\]" LOCATION "Pin_J3"
cmp add_assignment $top_name "" "dac_data2\[9\]"  LOCATION "Pin_H2"
cmp add_assignment $top_name "" "dac_data2\[8\]"  LOCATION "Pin_G1"
cmp add_assignment $top_name "" "dac_data2\[7\]"  LOCATION "Pin_J2"
cmp add_assignment $top_name "" "dac_data2\[6\]"  LOCATION "Pin_H1"
cmp add_assignment $top_name "" "dac_data2\[5\]"  LOCATION "Pin_K4"
cmp add_assignment $top_name "" "dac_data2\[4\]"  LOCATION "Pin_L7"
cmp add_assignment $top_name "" "dac_data2\[3\]"  LOCATION "Pin_M7"
cmp add_assignment $top_name "" "dac_data2\[2\]"  LOCATION "Pin_M6"
cmp add_assignment $top_name "" "dac_data2\[1\]"  LOCATION "Pin_L9"
cmp add_assignment $top_name "" "dac_data2\[0\]"  LOCATION "Pin_L10"
puts "   Assigned: DAC data bus #2 pins."


# assign DAC data bus 3
cmp add_assignment $top_name "" "dac_data3\[13\]" LOCATION "Pin_C24"
cmp add_assignment $top_name "" "dac_data3\[12\]" LOCATION "Pin_E21"
cmp add_assignment $top_name "" "dac_data3\[11\]" LOCATION "Pin_A21"
cmp add_assignment $top_name "" "dac_data3\[10\]" LOCATION "Pin_B21"
cmp add_assignment $top_name "" "dac_data3\[9\]"  LOCATION "Pin_C21"
cmp add_assignment $top_name "" "dac_data3\[8\]"  LOCATION "Pin_D21"
cmp add_assignment $top_name "" "dac_data3\[7\]"  LOCATION "Pin_C20"
cmp add_assignment $top_name "" "dac_data3\[6\]"  LOCATION "Pin_A19"
cmp add_assignment $top_name "" "dac_data3\[5\]"  LOCATION "Pin_B19"
cmp add_assignment $top_name "" "dac_data3\[4\]"  LOCATION "Pin_A18"
cmp add_assignment $top_name "" "dac_data3\[3\]"  LOCATION "Pin_C19"
cmp add_assignment $top_name "" "dac_data3\[2\]"  LOCATION "Pin_B18"
cmp add_assignment $top_name "" "dac_data3\[1\]"  LOCATION "Pin_D19"
cmp add_assignment $top_name "" "dac_data3\[0\]"  LOCATION "Pin_C18"
puts "   Assigned: DAC data bus #3 pins."


# assign DAC data bus 4
cmp add_assignment $top_name "" "dac_data4\[13\]" LOCATION "Pin_B5"
cmp add_assignment $top_name "" "dac_data4\[12\]" LOCATION "Pin_A4"
cmp add_assignment $top_name "" "dac_data4\[11\]" LOCATION "Pin_A3"
cmp add_assignment $top_name "" "dac_data4\[10\]" LOCATION "Pin_C5"
cmp add_assignment $top_name "" "dac_data4\[9\]"  LOCATION "Pin_B4"
cmp add_assignment $top_name "" "dac_data4\[8\]"  LOCATION "Pin_B3"
cmp add_assignment $top_name "" "dac_data4\[7\]"  LOCATION "Pin_C6"
cmp add_assignment $top_name "" "dac_data4\[6\]"  LOCATION "Pin_C4"
cmp add_assignment $top_name "" "dac_data4\[5\]"  LOCATION "Pin_D6"
cmp add_assignment $top_name "" "dac_data4\[4\]"  LOCATION "Pin_D7"
cmp add_assignment $top_name "" "dac_data4\[3\]"  LOCATION "Pin_D5"
cmp add_assignment $top_name "" "dac_data4\[2\]"  LOCATION "Pin_D10"
cmp add_assignment $top_name "" "dac_data4\[1\]"  LOCATION "Pin_F10"
cmp add_assignment $top_name "" "dac_data4\[0\]"  LOCATION "Pin_G7"
puts "   Assigned: DAC data bus #4 pins."


# assign DAC data bus 5
cmp add_assignment $top_name "" "dac_data5\[13\]" LOCATION "Pin_A11"
cmp add_assignment $top_name "" "dac_data5\[12\]" LOCATION "Pin_C11"
cmp add_assignment $top_name "" "dac_data5\[11\]" LOCATION "Pin_B11"
cmp add_assignment $top_name "" "dac_data5\[10\]" LOCATION "Pin_B10"
cmp add_assignment $top_name "" "dac_data5\[9\]"  LOCATION "Pin_C10"
cmp add_assignment $top_name "" "dac_data5\[8\]"  LOCATION "Pin_A9"
cmp add_assignment $top_name "" "dac_data5\[7\]"  LOCATION "Pin_B9"
cmp add_assignment $top_name "" "dac_data5\[6\]"  LOCATION "Pin_A8"
cmp add_assignment $top_name "" "dac_data5\[5\]"  LOCATION "Pin_C9"
cmp add_assignment $top_name "" "dac_data5\[4\]"  LOCATION "Pin_B8"
cmp add_assignment $top_name "" "dac_data5\[3\]"  LOCATION "Pin_C8"
cmp add_assignment $top_name "" "dac_data5\[2\]"  LOCATION "Pin_B6"
cmp add_assignment $top_name "" "dac_data5\[1\]"  LOCATION "Pin_D8"
cmp add_assignment $top_name "" "dac_data5\[0\]"  LOCATION "Pin_D9"
puts "   Assigned: DAC data bus #5 pins."


# assign DAC data bus 6
cmp add_assignment $top_name "" "dac_data6\[13\]" LOCATION "Pin_AF7"
cmp add_assignment $top_name "" "dac_data6\[12\]" LOCATION "Pin_AF6"
cmp add_assignment $top_name "" "dac_data6\[11\]" LOCATION "Pin_AE6"
cmp add_assignment $top_name "" "dac_data6\[10\]" LOCATION "Pin_AD6"
cmp add_assignment $top_name "" "dac_data6\[9\]"  LOCATION "Pin_AG6"
cmp add_assignment $top_name "" "dac_data6\[8\]"  LOCATION "Pin_AE5"
cmp add_assignment $top_name "" "dac_data6\[7\]"  LOCATION "Pin_AG7"
cmp add_assignment $top_name "" "dac_data6\[6\]"  LOCATION "Pin_AG5"
cmp add_assignment $top_name "" "dac_data6\[5\]"  LOCATION "Pin_AF4"
cmp add_assignment $top_name "" "dac_data6\[4\]"  LOCATION "Pin_AG4"
cmp add_assignment $top_name "" "dac_data6\[3\]"  LOCATION "Pin_AG3"
cmp add_assignment $top_name "" "dac_data6\[2\]"  LOCATION "Pin_AH4"
cmp add_assignment $top_name "" "dac_data6\[1\]"  LOCATION "Pin_AH6"
cmp add_assignment $top_name "" "dac_data6\[0\]"  LOCATION "Pin_AH7"
puts "   Assigned: DAC data bus #6 pins."


# assign DAC data bus 7
cmp add_assignment $top_name "" "dac_data7\[13\]" LOCATION "Pin_M10"
cmp add_assignment $top_name "" "dac_data7\[12\]" LOCATION "Pin_M9"
cmp add_assignment $top_name "" "dac_data7\[11\]" LOCATION "Pin_M8"
cmp add_assignment $top_name "" "dac_data7\[10\]" LOCATION "Pin_N8"
cmp add_assignment $top_name "" "dac_data7\[9\]"  LOCATION "Pin_K3"
cmp add_assignment $top_name "" "dac_data7\[8\]"  LOCATION "Pin_K2"
cmp add_assignment $top_name "" "dac_data7\[7\]"  LOCATION "Pin_J1"
cmp add_assignment $top_name "" "dac_data7\[6\]"  LOCATION "Pin_L2"
cmp add_assignment $top_name "" "dac_data7\[5\]"  LOCATION "Pin_K1"
cmp add_assignment $top_name "" "dac_data7\[4\]"  LOCATION "Pin_N7"
cmp add_assignment $top_name "" "dac_data7\[3\]"  LOCATION "Pin_L1"
cmp add_assignment $top_name "" "dac_data7\[2\]"  LOCATION "Pin_M3"
cmp add_assignment $top_name "" "dac_data7\[1\]"  LOCATION "Pin_M4"
cmp add_assignment $top_name "" "dac_data7\[0\]"  LOCATION "Pin_N3"
puts "   Assigned: DAC data bus #7 pins."


# assign DAC data bus 8
cmp add_assignment $top_name "" "dac_data8\[13\]" LOCATION "Pin_V6"
cmp add_assignment $top_name "" "dac_data8\[12\]" LOCATION "Pin_V5"
cmp add_assignment $top_name "" "dac_data8\[11\]" LOCATION "Pin_W4"
cmp add_assignment $top_name "" "dac_data8\[10\]" LOCATION "Pin_W1"
cmp add_assignment $top_name "" "dac_data8\[9\]"  LOCATION "Pin_Y2"
cmp add_assignment $top_name "" "dac_data8\[8\]"  LOCATION "Pin_Y1"
cmp add_assignment $top_name "" "dac_data8\[7\]"  LOCATION "Pin_AA2"
cmp add_assignment $top_name "" "dac_data8\[6\]"  LOCATION "Pin_AA1"
cmp add_assignment $top_name "" "dac_data8\[5\]"  LOCATION "Pin_V8"
cmp add_assignment $top_name "" "dac_data8\[4\]"  LOCATION "Pin_AA3"
cmp add_assignment $top_name "" "dac_data8\[3\]"  LOCATION "Pin_U10"
cmp add_assignment $top_name "" "dac_data8\[2\]"  LOCATION "Pin_AA4"
cmp add_assignment $top_name "" "dac_data8\[1\]"  LOCATION "Pin_V9"
cmp add_assignment $top_name "" "dac_data8\[0\]"  LOCATION "Pin_V10"
puts "   Assigned: DAC data bus #8 pins."


# assign DAC data bus 9
cmp add_assignment $top_name "" "dac_data9\[13\]" LOCATION "Pin_T7"
cmp add_assignment $top_name "" "dac_data9\[12\]" LOCATION "Pin_T6"
cmp add_assignment $top_name "" "dac_data9\[11\]" LOCATION "Pin_T4"
cmp add_assignment $top_name "" "dac_data9\[10\]" LOCATION "Pin_T3"
cmp add_assignment $top_name "" "dac_data9\[9\]"  LOCATION "Pin_T1"
cmp add_assignment $top_name "" "dac_data9\[8\]"  LOCATION "Pin_T5"
cmp add_assignment $top_name "" "dac_data9\[7\]"  LOCATION "Pin_U5"
cmp add_assignment $top_name "" "dac_data9\[6\]"  LOCATION "Pin_U2"
cmp add_assignment $top_name "" "dac_data9\[5\]"  LOCATION "Pin_V2"
cmp add_assignment $top_name "" "dac_data9\[4\]"  LOCATION "Pin_V1"
cmp add_assignment $top_name "" "dac_data9\[3\]"  LOCATION "Pin_V3"
cmp add_assignment $top_name "" "dac_data9\[2\]"  LOCATION "Pin_W2"
cmp add_assignment $top_name "" "dac_data9\[1\]"  LOCATION "Pin_W3"
cmp add_assignment $top_name "" "dac_data9\[0\]"  LOCATION "Pin_V4"
puts "   Assigned: DAC data bus #9 pins."


# assign DAC data bus 10
cmp add_assignment $top_name "" "dac_data10\[13\]" LOCATION "Pin_D22"
cmp add_assignment $top_name "" "dac_data10\[12\]" LOCATION "Pin_E23"
cmp add_assignment $top_name "" "dac_data10\[11\]" LOCATION "Pin_C22"
cmp add_assignment $top_name "" "dac_data10\[10\]" LOCATION "Pin_D23"
cmp add_assignment $top_name "" "dac_data10\[9\]"  LOCATION "Pin_B22"
cmp add_assignment $top_name "" "dac_data10\[8\]"  LOCATION "Pin_A22"
cmp add_assignment $top_name "" "dac_data10\[7\]"  LOCATION "Pin_C23"
cmp add_assignment $top_name "" "dac_data10\[6\]"  LOCATION "Pin_A23"
cmp add_assignment $top_name "" "dac_data10\[5\]"  LOCATION "Pin_B23"
cmp add_assignment $top_name "" "dac_data10\[4\]"  LOCATION "Pin_B24"
cmp add_assignment $top_name "" "dac_data10\[3\]"  LOCATION "Pin_D24"
cmp add_assignment $top_name "" "dac_data10\[2\]"  LOCATION "Pin_A25"
cmp add_assignment $top_name "" "dac_data10\[1\]"  LOCATION "Pin_B25"
cmp add_assignment $top_name "" "dac_data10\[0\]"  LOCATION "Pin_B26"
puts "   Assigned: DAC data bus #10 pins."


############################################################################
# Address Card DAC clocks
#
# assign DAC clock
cmp add_assignment $top_name "" "dac_clk\[0\]" LOCATION "Pin_N28"
cmp add_assignment $top_name "" "dac_clk\[1\]" LOCATION "Pin_M20"
cmp add_assignment $top_name "" "dac_clk\[2\]" LOCATION "Pin_N26"
cmp add_assignment $top_name "" "dac_clk\[3\]" LOCATION "Pin_L20"
cmp add_assignment $top_name "" "dac_clk\[4\]" LOCATION "Pin_M19"
cmp add_assignment $top_name "" "dac_clk\[5\]" LOCATION "Pin_N25"
cmp add_assignment $top_name "" "dac_clk\[6\]" LOCATION "Pin_L19"
cmp add_assignment $top_name "" "dac_clk\[7\]" LOCATION "Pin_L28"
cmp add_assignment $top_name "" "dac_clk\[8\]" LOCATION "Pin_K8"
cmp add_assignment $top_name "" "dac_clk\[9\]" LOCATION "Pin_E19"
cmp add_assignment $top_name "" "dac_clk\[10\]" LOCATION "Pin_L8"
cmp add_assignment $top_name "" "dac_clk\[11\]" LOCATION "Pin_D18"
cmp add_assignment $top_name "" "dac_clk\[12\]" LOCATION "Pin_F19"
cmp add_assignment $top_name "" "dac_clk\[13\]" LOCATION "Pin_K7"
cmp add_assignment $top_name "" "dac_clk\[14\]" LOCATION "Pin_J18"
cmp add_assignment $top_name "" "dac_clk\[15\]" LOCATION "Pin_J4"
cmp add_assignment $top_name "" "dac_clk\[16\]" LOCATION "Pin_A7"
cmp add_assignment $top_name "" "dac_clk\[17\]" LOCATION "Pin_E8"
cmp add_assignment $top_name "" "dac_clk\[18\]" LOCATION "Pin_B7"
cmp add_assignment $top_name "" "dac_clk\[19\]" LOCATION "Pin_D11"
cmp add_assignment $top_name "" "dac_clk\[20\]" LOCATION "Pin_F8"
cmp add_assignment $top_name "" "dac_clk\[21\]" LOCATION "Pin_C7"
cmp add_assignment $top_name "" "dac_clk\[22\]" LOCATION "Pin_G10"
cmp add_assignment $top_name "" "dac_clk\[23\]" LOCATION "Pin_A5"
cmp add_assignment $top_name "" "dac_clk\[24\]" LOCATION "Pin_AB10"
cmp add_assignment $top_name "" "dac_clk\[25\]" LOCATION "Pin_M5"
cmp add_assignment $top_name "" "dac_clk\[26\]" LOCATION "Pin_AH5"
cmp add_assignment $top_name "" "dac_clk\[27\]" LOCATION "Pin_N4"
cmp add_assignment $top_name "" "dac_clk\[28\]" LOCATION "Pin_N5"
cmp add_assignment $top_name "" "dac_clk\[29\]" LOCATION "Pin_AC8"
cmp add_assignment $top_name "" "dac_clk\[30\]" LOCATION "Pin_N6"
cmp add_assignment $top_name "" "dac_clk\[31\]" LOCATION "Pin_AE8"
cmp add_assignment $top_name "" "dac_clk\[32\]" LOCATION "Pin_U8"
cmp add_assignment $top_name "" "dac_clk\[33\]" LOCATION "Pin_U7"
cmp add_assignment $top_name "" "dac_clk\[34\]" LOCATION "Pin_T8"
cmp add_assignment $top_name "" "dac_clk\[35\]" LOCATION "Pin_T9"
cmp add_assignment $top_name "" "dac_clk\[36\]" LOCATION "Pin_T10"
cmp add_assignment $top_name "" "dac_clk\[37\]" LOCATION "Pin_U6"
cmp add_assignment $top_name "" "dac_clk\[38\]" LOCATION "Pin_U9"
cmp add_assignment $top_name "" "dac_clk\[39\]" LOCATION "Pin_V7"
cmp add_assignment $top_name "" "dac_clk\[40\]" LOCATION "Pin_D20"
puts "   Assigned: DAC clock pins."


# recompile to commit
puts "\nInfo: Recompiling to commit assignments..."
execute_flow -compile

puts "\nInfo: Process completed."
