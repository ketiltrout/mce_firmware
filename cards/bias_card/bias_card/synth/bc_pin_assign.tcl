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
# Revision 1.8  2011-11-29 01:07:14  mandana
# minor change
#
# Revision 1.7  2011-06-23 16:03:26  mandana
# made compatible with Q10.1 tcl format
#
# Revision 1.6  2010/07/19 23:51:44  mandana
# updated for rev. F cards and it is compatible for Rev. D and F
# It does not generate a card_type.pack anymore, instead it uses newly added pcb_rev_i pins to find out hardware revision
#
# Revision 1.5  2010/06/29 01:37:17  bburger
# BB:  Automatic .pof generation
#
# Revision 1.4  2010/01/21 17:17:02  mandana
# v2.0
# supports Rev. E Bias cards
# dynamically creates card_type_pack.vhd to set card_type=BC_E_CARD_TYPE
# as is: we need to branch Rev. D and Rev. E tcl files, but this will be the only different file
#
# Revision 1.3  2006/10/02 22:39:15  mandana
# renamed rs232 pins to rx/tx not to conflict with async component rs232_rx and rs232_tx
# assigned rs232 dedicated pins as per Rev. D schematics
#
# Revision 1.2  2006/08/23 21:09:25  mandana
# sa_heater pins added for Rev. D PCB
#
# Revision 1.1  2006/03/08 22:09:18  bench2
# Mandana: changed revision to 01030002 to incorporate 100MHz lvds_rx
#
# Revision 1.14  2005/06/03 17:52:59  mandana
# reverse the order for DAC0 to DAC15. Be careful: silkscreen and schematics are labeled wrong.
#
# Revision 1.13  2005/01/18 22:20:47  bburger
# Bryce:  Added a BClr signal across the bus backplane to all the card top levels.
#
# Revision 1.12  2005/01/06 01:16:14  bench2
# Mandana: reversed dac0 to dac15 pin assignments to match new boards
#
# Revision 1.11  2004/12/22 18:26:26  bburger
# Mandana: changed mictor assignment to 0 to 31 and swapped odd and even pods
#
# Revision 1.10  2004/12/09 23:30:28  erniel
# fixed reversal of DAC channels 0-15
#
# Revision 1.9  2004/12/06 07:22:35  bburger
# Bryce:
# Created pack files for the card top-levels.
# Added some simulation signals to the top-levels (i.e. clocks)
#
# Revision 1.8  2004/09/15 20:25:18  erniel
# changed pin assignment of dac_dat[15]
# changed pin assignment of dac_ncs[15]
#
# Revision 1.7  2004/05/20 15:59:59  erniel
# removed DAC_nclr pin, tied to status pin on board
#
# Revision 1.6  2004/05/17 00:12:57  erniel
# renamed PLL 5 input pin to inclk
#
# Revision 1.5  2004/05/15 02:13:32  erniel
# unrolled foreach loops
#
# Revision 1.4  2004/05/15 00:17:40  erniel
# renamed signals to match similar signals in other scripts
# modified script general structure
#
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
puts "\n\nBias Card Pin Assignment Script v4.1"	
puts "\n compatible for Rev. E pin assignment (Rev. D and Rev. F are commented"
puts     "-----------------------------------------------------------------------"


# include Quartus Tcl API
package require ::quartus::project
package require ::quartus::flow


# get entity name
set top_name [get_project_settings -cmp]
puts "\nInfo: Top-level entity is $top_name."

puts "\nInfo: Assigning pins:"


# assign device parameters
set_global_assignment -name DEVICE EP1S10F780C5
set_global_assignment -name RESERVE_ALL_UNUSED_PINS "AS INPUT TRI-STATED"

# dev_clr_n disabled
set_global_assignment -name ENABLE_DEVICE_WIDE_RESET OFF
puts "   Assigned: EP1S10 device parameters."

# assign rst_n
set_location_assignment Pin_AC9 -to rst_n
puts "   Assigned: RST_N pin."

# assign LEDs
set_location_assignment Pin_V27 -to red_led
set_location_assignment Pin_T24 -to ylw_led
set_location_assignment Pin_T23 -to grn_led
puts "   Assigned: LED pins."


# assign dip switches
set_location_assignment Pin_W23 -to dip_sw3
set_location_assignment Pin_W24 -to dip_sw4
puts "   Assigned: DIP switch pins."


# assign watchdog
set_location_assignment Pin_T28 -to wdog
puts "   Assigned: Watchdog pin."

# assign miscellaneous
set_location_assignment Pin_U27 -to extend_n

# Bias Card Rev. E+ Only! (next 4 pins) They are all unused in Rev. D
set_location_assignment Pin_AA20 -to crc_error_out
set_location_assignment Pin_Y19 -to crc_error_in 			 
set_location_assignment Pin_AB28 -to critical_error
set_location_assignment Pin_V28 -to dev_clr_fpga_out
puts "   Assigned: miscellaneous pins."


# assign ID pins 
set_location_assignment Pin_V25 -to "slot_id\[0\]"
set_location_assignment Pin_V26 -to "slot_id\[1\]"
set_location_assignment Pin_T25 -to "slot_id\[2\]"
set_location_assignment Pin_T26 -to "slot_id\[3\]"

set_location_assignment Pin_T21 -to card_id
puts "   Assigned: ID pins."

# assign Hardware Revision pins (as of Rev. F Hardware)
set_location_assignment Pin_AF7 -to "pcb_rev\[0\]"
set_location_assignment Pin_AF6 -to "pcb_rev\[1\]"
set_location_assignment Pin_AE6 -to "pcb_rev\[2\]"
set_location_assignment Pin_AD6 -to "pcb_rev\[3\]"
puts "   Assigned: Hardware Revision pins."

# assign LVDS pins
# for LVDS clk, see PLL section
set_location_assignment Pin_V23 -to lvds_cmd
set_location_assignment Pin_AA28 -to lvds_sync
set_location_assignment Pin_V24 -to lvds_spare
set_location_assignment Pin_V19 -to lvds_txa  
set_location_assignment Pin_V20 -to lvds_txb
puts "   Assigned: LVDS pins."


# assign TTL pins
set_location_assignment Pin_U19 -to "ttl_nrx1"
set_location_assignment Pin_U20 -to "ttl_nrx2"
set_location_assignment Pin_W28 -to "ttl_nrx3"
set_location_assignment Pin_Y26 -to "ttl_tx1"
set_location_assignment Pin_U21 -to "ttl_tx2"
set_location_assignment Pin_Y28 -to "ttl_tx3"
set_location_assignment Pin_Y25 -to "ttl_txena1"
set_location_assignment Pin_U22 -to "ttl_txena2"
set_location_assignment Pin_Y27 -to "ttl_txena3"
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
set_location_assignment Pin_K17 -to inclk
set_location_assignment Pin_E15 -to outclk
set_location_assignment Pin_K14 -to  "pll5_out\[1\]"
set_location_assignment Pin_C15 -to  "pll5_out\[2\]"
set_location_assignment Pin_K16 -to  "pll5_out\[3\]"
set_location_assignment Pin_AC17 -to "pll6_in"
set_location_assignment Pin_AD15 -to "pll6_out\[0\]"
set_location_assignment Pin_W14 -to "pll6_out\[1\]" 
set_location_assignment Pin_AF15 -to "pll6_out\[2\]"
set_location_assignment Pin_W16 -to "pll6_out\[3\]"
puts "   Assigned: PLL pins."


# assign power supply interface
set_location_assignment Pin_T22 -to n7vok
set_location_assignment Pin_U26 -to n15vok
set_location_assignment Pin_U25 -to minus7vok
puts "   Assigned: Power supply status pin."


# assign SMB pins
set_location_assignment Pin_U23 -to smb_clk
set_location_assignment Pin_W26 -to smb_data  
set_location_assignment Pin_W25 -to smb_nalert
puts "   Assigned: SMB interface pins."

# assign sa heater pins - firmware not in place YET!
# Bias Card Rev. D - These pins serve a different purpose in Rev. E, 
# so careful before uncommenting
#set_location_assignment Pin_T3 -to sa_htr1p
#set_location_assignment Pin_T4 -to sa_htr1n
#set_location_assignment Pin_T1 -to sa_htr2p
#set_location_assignment Pin_U2 -to sa_htr2n

# Bias Card Rev. E
#set_location_assignment Pin_AH4 -to sa_htr1p
#set_location_assignment Pin_AG4 -to sa_htr1n
#set_location_assignment Pin_AG5 -to sa_htr2p
#set_location_assignment Pin_AH5 -to sa_htr2n
puts "   Assigned: SA Heater pins."

# assign 2x8 test header pins
set_location_assignment Pin_AE11 -to "test\[1\]"
set_location_assignment Pin_AD8  -to "test\[2\]"
set_location_assignment Pin_AF11 -to "test\[3\]"
set_location_assignment Pin_AF8  -to "test\[4\]"
set_location_assignment Pin_AG11 -to "test\[5\]"
set_location_assignment Pin_AG8  -to "test\[6\]"
set_location_assignment Pin_AH11 -to "test\[7\]"
set_location_assignment Pin_AH8 -to "test\[8\]"
set_location_assignment Pin_AF10 -to "test\[9\]"
set_location_assignment Pin_AG9 -to "test\[10\]"
set_location_assignment Pin_AH10 -to "test\[11\]"
set_location_assignment Pin_AE9 -to "test\[12\]"
set_location_assignment Pin_AF9 -to "test\[13\]"
set_location_assignment Pin_AD10 -to "test\[14\]"
#the following 2 pins used as rs232 rx/tx interface below
#set_location_assignment "test\[15\]" -to Pin_AH9
#set_location_assignment "test\[16\]" -to Pin_AE10
puts "   Assigned: 2x8 test header pins."

set_location_assignment Pin_AH9 -to rx 
set_location_assignment Pin_AE10 -to tx
puts "   Assigned: rs232 pins."


#assign mictor header pins (odd pod = 0-15, even pod = 16-31)
set_location_assignment Pin_AF25 -to  "mictor\[0\]"
set_location_assignment Pin_AG26 -to  "mictor\[1\]"
set_location_assignment Pin_AH26 -to  "mictor\[2\]"
set_location_assignment Pin_AG25 -to  "mictor\[3\]"
set_location_assignment Pin_AH25 -to  "mictor\[4\]"
set_location_assignment Pin_AG24 -to  "mictor\[5\]"
set_location_assignment Pin_AH24 -to  "mictor\[6\]"
set_location_assignment Pin_AG23 -to  "mictor\[7\]"
set_location_assignment Pin_AH23 -to  "mictor\[8\]"
set_location_assignment Pin_AG22 -to  "mictor\[9\]"
set_location_assignment Pin_AH22 -to  "mictor\[10\]"
set_location_assignment Pin_AG21 -to  "mictor\[11\]"
set_location_assignment Pin_AH21 -to  "mictor\[12\]"
set_location_assignment Pin_AF20 -to  "mictor\[13\]"
set_location_assignment Pin_AH20 -to  "mictor\[14\]"
set_location_assignment Pin_AG19 -to  "mictor\[15\]"
set_location_assignment Pin_AD18 -to  "mictor\[16\]"
set_location_assignment Pin_AD19 -to  "mictor\[17\]"
set_location_assignment Pin_AF19 -to  "mictor\[18\]"
set_location_assignment Pin_AE19 -to  "mictor\[19\]"
set_location_assignment Pin_AE20 -to  "mictor\[20\]"
set_location_assignment Pin_AD21 -to  "mictor\[21\]"
set_location_assignment Pin_AF21 -to  "mictor\[22\]"
set_location_assignment Pin_AE21 -to  "mictor\[23\]"
set_location_assignment Pin_AF22 -to  "mictor\[24\]"
set_location_assignment Pin_AE22 -to  "mictor\[25\]"
set_location_assignment Pin_AF23 -to  "mictor\[26\]"
set_location_assignment Pin_AD23 -to  "mictor\[27\]"
set_location_assignment Pin_AE24 -to  "mictor\[28\]"
set_location_assignment Pin_AG18 -to  "mictor\[29\]"
set_location_assignment Pin_AH19 -to  "mictor\[30\]"
set_location_assignment Pin_AE18 -to  "mictor\[31\]"
set_location_assignment Pin_Y17 -to "mictorclk\[1\]"
set_location_assignment Pin_AB17 -to "mictorclk\[2\]"
puts "   Assigned: Mictor header pins."


############################################################################
# Bias card DACs
#
# assign DAC clocks	

#set_location_assignment Pin_T5 -to lvds_dac_sclk

# T9 is lvds_dac_sclk only in Rev. E, pin unused in Rev. D, ncs09 in rev F
set_location_assignment Pin_T9 -to lvds_dac_sclk 

set_instance_assignment -name IO_STANDARD LVDS -to lvds_dac_sclk

set_location_assignment Pin_L23 -to "dac_sclk\[15\]"
set_location_assignment Pin_L24 -to "dac_sclk\[14\]"
set_location_assignment Pin_H27 -to "dac_sclk\[13\]"
set_location_assignment Pin_H28 -to "dac_sclk\[12\]"
set_location_assignment Pin_L22 -to "dac_sclk\[11\]"
set_location_assignment Pin_L21 -to "dac_sclk\[10\]"
set_location_assignment Pin_H26 -to  "dac_sclk\[9\]"
set_location_assignment Pin_H25 -to  "dac_sclk\[8\]"
set_location_assignment Pin_A9  -to "dac_sclk\[7\]"
set_location_assignment Pin_A8  -to "dac_sclk\[6\]"
set_location_assignment Pin_B8  -to "dac_sclk\[5\]"
set_location_assignment Pin_B9  -to "dac_sclk\[4\]"
set_location_assignment Pin_D9  -to "dac_sclk\[3\]"
set_location_assignment Pin_E8  -to "dac_sclk\[2\]"
set_location_assignment Pin_C8  -to "dac_sclk\[1\]"
set_location_assignment Pin_D8  -to "dac_sclk\[0\]"
set_location_assignment Pin_B23 -to "dac_sclk\[16\]"
set_location_assignment Pin_E23 -to "dac_sclk\[17\]"
set_location_assignment Pin_C23 -to "dac_sclk\[18\]"
set_location_assignment Pin_A23 -to "dac_sclk\[19\]"
set_location_assignment Pin_D22 -to "dac_sclk\[20\]"
set_location_assignment Pin_C22 -to "dac_sclk\[21\]"
set_location_assignment Pin_A22 -to "dac_sclk\[22\]"
set_location_assignment Pin_B22 -to "dac_sclk\[23\]"
set_location_assignment Pin_L18 -to "dac_sclk\[24\]"
set_location_assignment Pin_F17 -to "dac_sclk\[25\]"
set_location_assignment Pin_C24 -to "dac_sclk\[26\]"
set_location_assignment Pin_D23 -to "dac_sclk\[27\]"
set_location_assignment Pin_D20 -to "dac_sclk\[28\]"
set_location_assignment Pin_B18 -to "dac_sclk\[29\]"
set_location_assignment Pin_G19 -to "dac_sclk\[30\]"
set_location_assignment Pin_F19 -to "dac_sclk\[31\]"
puts "   Assigned: DAC clock pins."


# assign DAC chip selects	 
# Only Valid prior to Rev. E
#set_location_assignment lvds_dac_ncs -to Pin_U10
#set_location_assignment lvds_dac_ncs IO_STANDARD LVDS

# Rev. E adds 12 "new" low-noise bias lines
set_instance_assignment -name IO_STANDARD LVDS -to "lvds_dac_ncs\[11\]"
set_instance_assignment -name IO_STANDARD LVDS -to "lvds_dac_ncs\[10\]"
set_instance_assignment -name IO_STANDARD LVDS -to "lvds_dac_ncs\[9\]"
set_instance_assignment -name IO_STANDARD LVDS -to "lvds_dac_ncs\[8\]"
set_instance_assignment -name IO_STANDARD LVDS -to "lvds_dac_ncs\[7\]"
set_instance_assignment -name IO_STANDARD LVDS -to "lvds_dac_ncs\[6\]"
set_instance_assignment -name IO_STANDARD LVDS -to "lvds_dac_ncs\[5\]"
set_instance_assignment -name IO_STANDARD LVDS -to "lvds_dac_ncs\[4\]"
set_instance_assignment -name IO_STANDARD LVDS -to "lvds_dac_ncs\[3\]"
set_instance_assignment -name IO_STANDARD LVDS -to "lvds_dac_ncs\[2\]"
set_instance_assignment -name IO_STANDARD LVDS -to "lvds_dac_ncs\[1\]"
set_instance_assignment -name IO_STANDARD LVDS -to "lvds_dac_ncs\[0\]"

#set_location_assignment Pin_U10 -to "lvds_dac_ncs\[11\]"
# T3 is valid for lvds_dac_ncs11 Only in Rev. E
set_location_assignment Pin_T3 -to "lvds_dac_ncs\[11\]"

set_location_assignment Pin_N3 -to "lvds_dac_ncs\[10\]"

#set_location_assignment Pin_T9 -to "lvds_dac_ncs\[9\]"
# T5 is valid for lvds_dac_ncs9 Only in Rev. E
set_location_assignment Pin_T5 -to "lvds_dac_ncs\[9\]"

set_location_assignment Pin_T8 -to "lvds_dac_ncs\[8\]"
set_location_assignment Pin_W6 -to "lvds_dac_ncs\[7\]"
set_location_assignment Pin_V5 -to "lvds_dac_ncs\[6\]"
set_location_assignment Pin_N9 -to "lvds_dac_ncs\[5\]"
set_location_assignment Pin_L7 -to "lvds_dac_ncs\[4\]"
set_location_assignment Pin_L6 -to "lvds_dac_ncs\[3\]"
set_location_assignment Pin_M7 -to "lvds_dac_ncs\[2\]"
set_location_assignment Pin_N8 -to "lvds_dac_ncs\[1\]"
set_location_assignment Pin_N6 -to "lvds_dac_ncs\[0\]"

set_location_assignment Pin_N20 -to "dac_ncs\[15\]"
set_location_assignment Pin_M27 -to "dac_ncs\[14\]"
set_location_assignment Pin_N22 -to "dac_ncs\[13\]"
set_location_assignment Pin_N24 -to "dac_ncs\[12\]"
set_location_assignment Pin_L27 -to "dac_ncs\[11\]"
set_location_assignment Pin_N26 -to "dac_ncs\[10\]"
set_location_assignment Pin_L25 -to "dac_ncs\[9\]"
set_location_assignment Pin_M20 -to "dac_ncs\[8\]"
set_location_assignment Pin_K27 -to "dac_ncs\[7\]"
set_location_assignment Pin_M24 -to "dac_ncs\[6\]"
set_location_assignment Pin_M22 -to "dac_ncs\[5\]"
set_location_assignment Pin_J27 -to "dac_ncs\[4\]"
set_location_assignment Pin_L20 -to "dac_ncs\[3\]"
set_location_assignment Pin_J25 -to "dac_ncs\[2\]"
set_location_assignment Pin_L11 -to "dac_ncs\[1\]"
set_location_assignment Pin_F8  -to "dac_ncs\[0\]" 
set_location_assignment Pin_A4  -to   "dac_ncs\[16\]"
set_location_assignment Pin_B3  -to   "dac_ncs\[17\]"
set_location_assignment Pin_B4  -to   "dac_ncs\[18\]"
set_location_assignment Pin_A5  -to   "dac_ncs\[19\]"
set_location_assignment Pin_E6  -to   "dac_ncs\[20\]"
set_location_assignment Pin_B7  -to   "dac_ncs\[21\]"
set_location_assignment Pin_A7  -to   "dac_ncs\[22\]"
set_location_assignment Pin_C6  -to   "dac_ncs\[23\]"
set_location_assignment Pin_B11 -to   "dac_ncs\[24\]"
set_location_assignment Pin_C11 -to   "dac_ncs\[25\]"
set_location_assignment Pin_B10 -to   "dac_ncs\[26\]"
set_location_assignment Pin_A10 -to   "dac_ncs\[27\]"
set_location_assignment Pin_B20 -to   "dac_ncs\[28\]"
set_location_assignment Pin_C20 -to   "dac_ncs\[29\]"
set_location_assignment Pin_B21 -to   "dac_ncs\[30\]"
set_location_assignment Pin_D21 -to   "dac_ncs\[31\]"
puts "   Assigned: DAC select pins."


# assign DAC data
set_location_assignment Pin_U5 -to  lvds_dac_data
set_instance_assignment -name IO_STANDARD LVDS -to lvds_dac_data

set_location_assignment Pin_N19 -to "dac_data\[15\]"
set_location_assignment Pin_N28 -to "dac_data\[14\]"
set_location_assignment Pin_N21 -to "dac_data\[13\]"
set_location_assignment Pin_N23 -to "dac_data\[12\]"
set_location_assignment Pin_L28 -to "dac_data\[11\]"
set_location_assignment Pin_N25 -to "dac_data\[10\]"
set_location_assignment Pin_L26 -to  "dac_data\[9\]" 
set_location_assignment Pin_M19 -to  "dac_data\[8\]" 
set_location_assignment Pin_K28 -to  "dac_data\[7\]" 
set_location_assignment Pin_M23 -to  "dac_data\[6\]" 
set_location_assignment Pin_M21 -to  "dac_data\[5\]" 
set_location_assignment Pin_J28 -to  "dac_data\[4\]" 
set_location_assignment Pin_L19 -to  "dac_data\[3\]" 
set_location_assignment Pin_J26 -to  "dac_data\[2\]" 
set_location_assignment Pin_M11 -to  "dac_data\[1\]" 
set_location_assignment Pin_G7  -to  "dac_data\[0\]" 
set_location_assignment Pin_A3  -to  "dac_data\[16\]"
set_location_assignment Pin_B5  -to  "dac_data\[17\]"
set_location_assignment Pin_C4  -to  "dac_data\[18\]"
set_location_assignment Pin_C5  -to  "dac_data\[19\]"
set_location_assignment Pin_A6  -to  "dac_data\[20\]"
set_location_assignment Pin_D6  -to  "dac_data\[21\]"
set_location_assignment Pin_D7  -to  "dac_data\[22\]"
set_location_assignment Pin_C7  -to  "dac_data\[23\]"
set_location_assignment Pin_D11 -to  "dac_data\[24\]"
set_location_assignment Pin_A11 -to  "dac_data\[25\]"
set_location_assignment Pin_C10 -to  "dac_data\[26\]"
set_location_assignment Pin_E10 -to  "dac_data\[27\]"
set_location_assignment Pin_A20 -to  "dac_data\[28\]"
set_location_assignment Pin_A21 -to  "dac_data\[29\]"
set_location_assignment Pin_C21 -to  "dac_data\[30\]"
set_location_assignment Pin_E21 -to  "dac_data\[31\]"
puts "   Assigned: DAC data pins."


# recompile to commit
puts "\nInfo: Recompiling to commit assignments..."
execute_flow -compile

puts "\nInfo: Generating .pof file after waiting 10s to let compilation finish."
after 10000 "exec quartus_cpf -c bias_card_sof2pof.cof"


puts "\nInfo: Process completed."
