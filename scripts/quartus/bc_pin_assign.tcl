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
# bc_pin_assign
#
# Project:       SCUBA-2
# Author:        Ernie Lin
# Organization:  UBC
#
# Description:
# This script allows you to make pin assignments to the bias card
#
# Revision history:
#
# $Log: bc_pin_assign.tcl,v $
# Revision 1.2  2004/05/12 01:57:10  erniel
# updated header information
# removed project open TCL commands
#
# Revision 1.1  2004/05/06 17:58:43  erniel
# *** empty log message ***
#
# Revision 1.2  2004/04/29 22:59:04  mandana
# LVDS pins only need positive end to be assigned
#
# Revision 1.1  2004/04/29 20:10:42  mandana
# initial release
#
###############################################################################

# print welcome message
puts "\n\nBias Card Pin Assignment Script v1.0"
puts "------------------------------------"


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
cmp add_assignment $top_name "" dip_sw3 LOCATION "Pin_W23"
cmp add_assignment $top_name "" dip_sw4 LOCATION "Pin_W24"
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
# PLL5 in     = lvds_clk
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
cmp add_assignment $top_name "" n15vok LOCATION "Pin_U26"
cmp add_assignment $top_name "" minus7vok LOCATION "Pin_U25"
puts "   Assigned: Power supply status pin."


# assign SMB pins
cmp add_assignment $top_name "" smb_clk LOCATION "Pin_U23"
cmp add_assignment $top_name "" smb_data LOCATION "Pin_W26"
cmp add_assignment $top_name "" smb_nalert LOCATION "Pin_W25"
puts "   Assigned: SMB interface pins."


# assign 2x8 test header pins
cmp add_assignment $top_name "" rs232_rx LOCATION "Pin_AE11"
cmp add_assignment $top_name "" rs232_tx LOCATION "Pin_AD8"
cmp add_assignment $top_name "" "test\[3\]" LOCATION "Pin_AF11"
cmp add_assignment $top_name "" "test\[4\]" LOCATION "Pin_AF8"
cmp add_assignment $top_name "" "test\[5\]" LOCATION "Pin_AG11"
cmp add_assignment $top_name "" "test\[6\]" LOCATION "Pin_AG8"
cmp add_assignment $top_name "" "test\[7\]" LOCATION "Pin_AH11"
cmp add_assignment $top_name "" "test\[8\]" LOCATION "Pin_AH8"
cmp add_assignment $top_name "" "test\[9\]" LOCATION "Pin_AF10"
cmp add_assignment $top_name "" "test\[10\]" LOCATION "Pin_AG9"
cmp add_assignment $top_name "" "test\[11\]" LOCATION "Pin_AH10"
cmp add_assignment $top_name "" "test\[12\]" LOCATION "Pin_AE9"
cmp add_assignment $top_name "" "test\[13\]" LOCATION "Pin_AF9"
cmp add_assignment $top_name "" "test\[14\]" LOCATION "Pin_AD10"
cmp add_assignment $top_name "" "test\[15\]" LOCATION "Pin_AH9"
cmp add_assignment $top_name "" "test\[16\]" LOCATION "Pin_AE10"
puts "   Assigned: 2x8 test header pins."


#assign mictor header pins (odd pod = 1-16, even pod = 17-32)
cmp add_assignment $top_name "" "mictor\[1\]" LOCATION "Pin_AD18"
cmp add_assignment $top_name "" "mictor\[2\]" LOCATION "Pin_AD19"
cmp add_assignment $top_name "" "mictor\[3\]" LOCATION "Pin_AF19"
cmp add_assignment $top_name "" "mictor\[4\]" LOCATION "Pin_AE19"
cmp add_assignment $top_name "" "mictor\[5\]" LOCATION "Pin_AE20"
cmp add_assignment $top_name "" "mictor\[6\]" LOCATION "Pin_AD21"
cmp add_assignment $top_name "" "mictor\[7\]" LOCATION "Pin_AF21"
cmp add_assignment $top_name "" "mictor\[8\]" LOCATION "Pin_AE21"
cmp add_assignment $top_name "" "mictor\[9\]" LOCATION "Pin_AF22"
cmp add_assignment $top_name "" "mictor\[10\]" LOCATION "Pin_AE22"
cmp add_assignment $top_name "" "mictor\[11\]" LOCATION "Pin_AF23"
cmp add_assignment $top_name "" "mictor\[12\]" LOCATION "Pin_AD23"
cmp add_assignment $top_name "" "mictor\[13\]" LOCATION "Pin_AE24"
cmp add_assignment $top_name "" "mictor\[14\]" LOCATION "Pin_AG18"
cmp add_assignment $top_name "" "mictor\[15\]" LOCATION "Pin_AH19"
cmp add_assignment $top_name "" "mictor\[16\]" LOCATION "Pin_AE18"
cmp add_assignment $top_name "" "mictor\[17\]" LOCATION "Pin_AF25"
cmp add_assignment $top_name "" "mictor\[18\]" LOCATION "Pin_AG26"
cmp add_assignment $top_name "" "mictor\[19\]" LOCATION "Pin_AH26"
cmp add_assignment $top_name "" "mictor\[20\]" LOCATION "Pin_AG25"
cmp add_assignment $top_name "" "mictor\[21\]" LOCATION "Pin_AH25"
cmp add_assignment $top_name "" "mictor\[22\]" LOCATION "Pin_AG24"
cmp add_assignment $top_name "" "mictor\[23\]" LOCATION "Pin_AH24"
cmp add_assignment $top_name "" "mictor\[24\]" LOCATION "Pin_AG23"
cmp add_assignment $top_name "" "mictor\[25\]" LOCATION "Pin_AH23"
cmp add_assignment $top_name "" "mictor\[26\]" LOCATION "Pin_AG22"
cmp add_assignment $top_name "" "mictor\[27\]" LOCATION "Pin_AH22"
cmp add_assignment $top_name "" "mictor\[28\]" LOCATION "Pin_AG21"
cmp add_assignment $top_name "" "mictor\[29\]" LOCATION "Pin_AH21"
cmp add_assignment $top_name "" "mictor\[30\]" LOCATION "Pin_AF20"
cmp add_assignment $top_name "" "mictor\[31\]" LOCATION "Pin_AH20"
cmp add_assignment $top_name "" "mictor\[32\]" LOCATION "Pin_AG19"
cmp add_assignment $top_name "" "mictorclk\[1\]" LOCATION "Pin_Y17"
cmp add_assignment $top_name "" "mictorclk\[2\]" LOCATION "Pin_AB17"
puts "   Assigned: Mictor header pins."


############################################################################
# Bias card DACs
#
# assign DAC clocks
cmp add_assignment $top_name "" lvds_dac_sclk LOCATION "Pin_T5"
cmp add_assignment $top_name "" lvds_dac_sclk IO_STANDARD LVDS
set sclk {L23 L24 H27 H28 L22 L21 H26 H25 A9 A8 B8 B9 D9 E8 C8 D8 B23 E23 C23 A23 D22 C22 A22 B22 L18 F17 C24 D23 D20 B18 G19 F19}
set i 0
foreach {a} $sclk 
{
   cmp add_assignment $top_name "" "dac_sclk\[$i\]" LOCATION "Pin_$a"
   set i [expr $i+1]
}
puts "   Assigned: DAC clock pins."


# assign DAC chip selects
cmp add_assignment $top_name "" lvds_dac_ncs LOCATION "Pin_U10"
cmp add_assignment $top_name "" lvds_dac_ncs IO_STANDARD LVDS
set ncs  {N20 M27 N22 N24 L27 N26 L25 M20 K27 M24 M22 J27 L20 J25 L11 J13 A4 B3 B4 A5 E6 B7 A7 C6 B11 C11 B10 A10 B20 C20 B21 D21}
set i 0
foreach {a} $ncs 
{
   cmp add_assignment $top_name "" "dac_ncs\[$i\]" LOCATION "Pin_$a"
   set i [expr $i+1]
}
puts "   Assigned: DAC select pins."


# assign DAC data
cmp add_assignment $top_name "" lvds_dac_data LOCATION "Pin_U5"
cmp add_assignment $top_name "" lvds_dac_data IO_STANDARD LVDS
set data {N19 N28 N21 N23 L28 N25 L26 M19 K28 M23 M21 J28 L19 J26 M11 L13 A3 B5 C4 C5 A6 D6 D7 C7 D11 A11 C10 E10 A20 A21 C21 E21} 
set i 0
foreach {a} $data 
{
   cmp add_assignment $top_name "" "dac_data\[$i\]" LOCATION "Pin_$a"
   set i [expr $i+1]
}
puts "   Assigned: DAC data pins."


# assign DAC clear
cmp add_assignment $top_name "" dac_nclr LOCATION "Pin_M16"
puts "   Assigned: DAC clear pin."


# recompile to commit
puts "\nInfo: Recompiling to commit assignments..."
execute_flow -compile

puts "\nInfo: Process completed."
