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
cmp add_assignment $top_name "" "" ENABLE_DEVICE_WIDE_RESET ON
puts "   Assigned: EP1S10 device parameters."


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
# PLL5 in     = LVDSClk
# PLL5 out[0] = outclk (for observing PLL)
# PLL5 out[1] = N/C
# PLL5 out[2] = N/C
# PLL5 out[3] = N/C
# PLL6 in     = N/C
# PLL6 out[0] = N/C
# PLL6 out[1] = N/C
# PLL6 out[2] = N/C
# PLL6 out[3] = N/C
cmp add_assignment $top_name "" lvds_clk LOCATION "Pin_K17"
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
cmp add_assignment $top_name "" "test\[1\]" LOCATION "Pin_AF9"
cmp add_assignment $top_name "" "test\[2\]" LOCATION "Pin_AG11"
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
set bus_0 {M27 L27 H27 L26 L25 H25 N24 N23 L23 N22 N21 L21 N20 N19}
set i 0
foreach {a} $bus_0 
{
   cmp add_assignment $top_name "" "dac_data0\[$i\]" LOCATION "Pin_$a"
   set i [expr $i+1] 
}
puts "   Assigned: DAC data bus #0 pins."


# assign DAC data bus 1
set bus_1 {M24 M23 L24 K28 K27 J28 J27 H28 J26 J25 H26 M22 L22 M21}
set i 0
foreach {a} $bus_1
{
   cmp add_assignment $top_name "" "dac_data1\[$i\]" LOCATION "Pin_$a"
   set i [expr $i+1] 
}
puts "   Assigned: DAC data bus #1 pins."


# assign DAC data bus 2
set bus_2 {H4 H3 G2 J3 H2 G1 J2 H1 K4 L7 M7 M6 L9 L10}
set i 0
foreach {a} $bus_2 
{
   cmp add_assignment $top_name "" "dac_data2\[$i\]" LOCATION "Pin_$a"
   set i [expr $i+1] 
}
puts "   Assigned: DAC data bus #2 pins."


# assign DAC data bus 3
set bus_3 {C24 E21 A21 B21 C21 D21 C20 A19 B19 A18 C19 B18 D19 C18}
set i 0
foreach {a} $bus_3
{
   cmp add_assignment $top_name "" "dac_data3\[$i\]" LOCATION "Pin_$a"
   set i [expr $i+1] 
}
puts "   Assigned: DAC data bus #3 pins."


# assign DAC data bus 4
set bus_4 {B5 A4 A3 C5 B4 B3 C6 C4 D6 D7 D5 D10 F10 G7}
set i 0
foreach {a} $bus_4 
{
   cmp add_assignment $top_name "" "dac_data4\[$i\]" LOCATION "Pin_$a"
   set i [expr $i+1] 
}
puts "   Assigned: DAC data bus #4 pins."


# assign DAC data bus 5
set bus_5 {A11 C11 B11 B10 C10 A9 B9 A8 C9 B8 C8 B6 D8 D9}
set i 0
foreach {a} $bus_5
{
   cmp add_assignment $top_name "" "dac_data5\[$i\]" LOCATION "Pin_$a"
   set i [expr $i+1] 
}
puts "   Assigned: DAC data bus #5 pins."


# assign DAC data bus 6
set bus_6 {AF7 AF6 AE6 AD6 AG6 AE5 AG7 AG5 AF4 AG4 AG3 AH4 AH6 AH7}
set i 0
foreach {a} $bus_6
{
   cmp add_assignment $top_name "" "dac_data6\[$i\]" LOCATION "Pin_$a"
   set i [expr $i+1] 
}
puts "   Assigned: DAC data bus #6 pins."


# assign DAC data bus 7
set bus_7 {M10 M9 M8 N8 K3 K2 J1 L2 K1 N7 L1 M3 M4 N3}
set i 0
foreach {a} $bus_7
{
   cmp add_assignment $top_name "" "dac_data7\[$i\]" LOCATION "Pin_$a"
   set i [expr $i+1] 
}
puts "   Assigned: DAC data bus #7 pins."


# assign DAC data bus 8
set bus_8 {V6 V5 W4 W1 Y2 Y1 AA2 AA1 V8 AA3 U10 AA4 V9 V10}
set i 0
foreach {a} $bus_8
{
   cmp add_assignment $top_name "" "dac_data8\[$i\]" LOCATION "Pin_$a"
   set i [expr $i+1] 
}
puts "   Assigned: DAC data bus #8 pins."


# assign DAC data bus 9
set bus_9 {T7 T6 T4 T3 T1 T5 U5 U2 V2 V1 V3 W2 W3 V4}
set i 0
foreach {a} $bus_9
{
   cmp add_assignment $top_name "" "dac_data9\[$i\]" LOCATION "Pin_$a"
   set i [expr $i+1] 
}
puts "   Assigned: DAC data bus #9 pins."


# assign DAC data bus 10
set bus_10 {D22 E23 C22 D23 B22 A22 C23 A23 B23 B24 D24 A25 B25 B26}
set i 0
foreach {a} $bus_10
{
   cmp add_assignment $top_name "" "dac_data10\[$i\]" LOCATION "Pin_$a"
   set i [expr $i+1] 
}
puts "   Assigned: DAC data bus #10 pins."


############################################################################
# Address Card DAC clocks
#
# assign DAC clock
set dac_clk {N28  M20  N26  L20  M19  N25  L19  L28  K8   E19  L8   D18  F19  K7   J18  J4   A7   E8   B7   D11
             F8   C7   G10  A5   AB10 M5   AH5  N4   N5   AC8  N6   AE8  U8   U7   T8   T9   T10  U6   U9   V7   D20}
set i 0
foreach {a} $dac_clk {
   cmp add_assignment $top_name "" "dac_clk\[$i\]" LOCATION "Pin_$a"
   set i [expr $i+1] }

puts "   Assigned: DAC clock pins."


# recompile to commit
puts "\nInfo: Recompiling to commit assignments..."
execute_flow -compile

puts "\nInfo: Process completed."
