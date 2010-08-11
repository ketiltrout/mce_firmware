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
puts "\n\nBias Card Pin Assignment Script v4.0"	
puts "\n compatible for Rev. D and Rev. F pin assignment"
puts     "----------------------------------------------"


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
cmp add_assignment $top_name "" dip_sw3 LOCATION "Pin_W23"
cmp add_assignment $top_name "" dip_sw4 LOCATION "Pin_W24"
puts "   Assigned: DIP switch pins."


# assign watchdog
cmp add_assignment $top_name "" wdog LOCATION "Pin_T28"
puts "   Assigned: Watchdog pin."

# assign miscellaneous
cmp add_assignment $top_name "" extend_n LOCATION "Pin_U27"

# Bias Card Rev. E Only! (next 4 pins) They are all unused in Rev. D
cmp add_assignment $top_name "" crc_error_out LOCATION "Pin_AA20"
cmp add_assignment $top_name "" crc_error_in LOCATION "Pin_Y19"				 
cmp add_assignment $top_name "" critical_error_in LOCATION "Pin_AB28"
cmp add_assignment $top_name "" dev_clr_fpga_out LOCATION "Pin_V28"
puts "   Assigned: miscellaneous pins."


# assign ID pins 
cmp add_assignment $top_name "" "slot_id\[0\]" LOCATION "Pin_V25"
cmp add_assignment $top_name "" "slot_id\[1\]" LOCATION "Pin_V26"
cmp add_assignment $top_name "" "slot_id\[2\]" LOCATION "Pin_T25"
cmp add_assignment $top_name "" "slot_id\[3\]" LOCATION "Pin_T26"

cmp add_assignment $top_name "" card_id LOCATION "Pin_T21"
puts "   Assigned: ID pins."

# assign Hardware Revision pins (as of Rev. F Hardware)
cmp add_assignment $top_name "" "pcb_rev\[0\]" LOCATION "Pin_AF7"
cmp add_assignment $top_name "" "pcb_rev\[1\]" LOCATION "Pin_AF6"
cmp add_assignment $top_name "" "pcb_rev\[2\]" LOCATION "Pin_AE6"
cmp add_assignment $top_name "" "pcb_rev\[3\]" LOCATION "Pin_AD6"
puts "   Assigned: Hardware Revision pins."

# assign LVDS pins
# for LVDS clk, see PLL section
cmp add_assignment $top_name "" lvds_cmd LOCATION "Pin_V23"
cmp add_assignment $top_name "" lvds_sync LOCATION "Pin_AA28"
cmp add_assignment $top_name "" lvds_spare LOCATION "Pin_V24"
cmp add_assignment $top_name "" lvds_txa LOCATION "Pin_V19"
cmp add_assignment $top_name "" lvds_txb LOCATION "Pin_V20"
puts "   Assigned: LVDS pins."


# assign TTL pins
cmp add_assignment $top_name "" "ttl_nrx1" LOCATION "Pin_U19"
cmp add_assignment $top_name "" "ttl_nrx2" LOCATION "Pin_U20"
cmp add_assignment $top_name "" "ttl_nrx3" LOCATION "Pin_W28"
cmp add_assignment $top_name "" "ttl_tx1" LOCATION "Pin_Y26"
cmp add_assignment $top_name "" "ttl_tx2" LOCATION "Pin_U21"
cmp add_assignment $top_name "" "ttl_tx3" LOCATION "Pin_Y28"
cmp add_assignment $top_name "" "ttl_txena1" LOCATION "Pin_Y25"
cmp add_assignment $top_name "" "ttl_txena2" LOCATION "Pin_U22"
cmp add_assignment $top_name "" "ttl_txena3" LOCATION "Pin_Y27"
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
cmp add_assignment $top_name "" n15vok LOCATION "Pin_U26"
cmp add_assignment $top_name "" minus7vok LOCATION "Pin_U25"
puts "   Assigned: Power supply status pin."


# assign SMB pins
cmp add_assignment $top_name "" smb_clk LOCATION "Pin_U23"
cmp add_assignment $top_name "" smb_data LOCATION "Pin_W26"
cmp add_assignment $top_name "" smb_nalert LOCATION "Pin_W25"
puts "   Assigned: SMB interface pins."

# assign sa heater pins - firmware not in place YET!
# Bias Card Rev. D - These pins serve a different purpose in Rev. E, 
# so careful before uncommenting
#cmp add_assignment $top_name "" sa_htr1p LOCATION "Pin_T3"
#cmp add_assignment $top_name "" sa_htr1n LOCATION "Pin_T4"
#cmp add_assignment $top_name "" sa_htr2p LOCATION "Pin_T1"
#cmp add_assignment $top_name "" sa_htr2n LOCATION "Pin_U2"

# Bias Card Rev. E
cmp add_assignment $top_name "" sa_htr1p LOCATION "Pin_AH4"
cmp add_assignment $top_name "" sa_htr1n LOCATION "Pin_AG4"
cmp add_assignment $top_name "" sa_htr2p LOCATION "Pin_AG5"
cmp add_assignment $top_name "" sa_htr2n LOCATION "Pin_AH5"
puts "   Assigned: SA Heater pins."

# assign 2x8 test header pins
cmp add_assignment $top_name "" "test\[1\]" LOCATION "Pin_AE11"
cmp add_assignment $top_name "" "test\[2\]" LOCATION "Pin_AD8"
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
#the following 2 pins used as rs232 rx/tx interface below
#cmp add_assignment $top_name "" "test\[15\]" LOCATION "Pin_AH9"
#cmp add_assignment $top_name "" "test\[16\]" LOCATION "Pin_AE10"
puts "   Assigned: 2x8 test header pins."

cmp add_assignment $top_name "" rx LOCATION "Pin_AH9"
cmp add_assignment $top_name "" tx LOCATION "Pin_AE10"
puts "   Assigned: rs232 pins."


#assign mictor header pins (odd pod = 0-15, even pod = 16-31)
cmp add_assignment $top_name "" "mictor\[0\]" LOCATION  "Pin_AF25"
cmp add_assignment $top_name "" "mictor\[1\]" LOCATION  "Pin_AG26"
cmp add_assignment $top_name "" "mictor\[2\]" LOCATION  "Pin_AH26"
cmp add_assignment $top_name "" "mictor\[3\]" LOCATION  "Pin_AG25"
cmp add_assignment $top_name "" "mictor\[4\]" LOCATION  "Pin_AH25"
cmp add_assignment $top_name "" "mictor\[5\]" LOCATION  "Pin_AG24"
cmp add_assignment $top_name "" "mictor\[6\]" LOCATION  "Pin_AH24"
cmp add_assignment $top_name "" "mictor\[7\]" LOCATION  "Pin_AG23"
cmp add_assignment $top_name "" "mictor\[8\]" LOCATION  "Pin_AH23"
cmp add_assignment $top_name "" "mictor\[9\]" LOCATION  "Pin_AG22"
cmp add_assignment $top_name "" "mictor\[10\]" LOCATION "Pin_AH22"
cmp add_assignment $top_name "" "mictor\[11\]" LOCATION "Pin_AG21"
cmp add_assignment $top_name "" "mictor\[12\]" LOCATION "Pin_AH21"
cmp add_assignment $top_name "" "mictor\[13\]" LOCATION "Pin_AF20"
cmp add_assignment $top_name "" "mictor\[14\]" LOCATION "Pin_AH20"
cmp add_assignment $top_name "" "mictor\[15\]" LOCATION "Pin_AG19"
cmp add_assignment $top_name "" "mictor\[16\]" LOCATION "Pin_AD18"
cmp add_assignment $top_name "" "mictor\[17\]" LOCATION "Pin_AD19"
cmp add_assignment $top_name "" "mictor\[18\]" LOCATION "Pin_AF19"
cmp add_assignment $top_name "" "mictor\[19\]" LOCATION "Pin_AE19"
cmp add_assignment $top_name "" "mictor\[20\]" LOCATION "Pin_AE20"
cmp add_assignment $top_name "" "mictor\[21\]" LOCATION "Pin_AD21"
cmp add_assignment $top_name "" "mictor\[22\]" LOCATION "Pin_AF21"
cmp add_assignment $top_name "" "mictor\[23\]" LOCATION "Pin_AE21"
cmp add_assignment $top_name "" "mictor\[24\]" LOCATION "Pin_AF22"
cmp add_assignment $top_name "" "mictor\[25\]" LOCATION "Pin_AE22"
cmp add_assignment $top_name "" "mictor\[26\]" LOCATION "Pin_AF23"
cmp add_assignment $top_name "" "mictor\[27\]" LOCATION "Pin_AD23"
cmp add_assignment $top_name "" "mictor\[28\]" LOCATION "Pin_AE24"
cmp add_assignment $top_name "" "mictor\[29\]" LOCATION "Pin_AG18"
cmp add_assignment $top_name "" "mictor\[30\]" LOCATION "Pin_AH19"
cmp add_assignment $top_name "" "mictor\[31\]" LOCATION "Pin_AE18"
cmp add_assignment $top_name "" "mictorclk\[1\]" LOCATION "Pin_Y17"
cmp add_assignment $top_name "" "mictorclk\[2\]" LOCATION "Pin_AB17"
puts "   Assigned: Mictor header pins."


############################################################################
# Bias card DACs
#
# assign DAC clocks	

cmp add_assignment $top_name "" lvds_dac_sclk LOCATION "Pin_T5"

# Only valid in Rev. E, pin unused in Rev. D, ncs11 in rev F
#cmp add_assignment $top_name "" lvds_dac_sclk LOCATION "Pin_T9"

cmp add_assignment $top_name "" lvds_dac_sclk IO_STANDARD LVDS
cmp add_assignment $top_name "" "dac_sclk\[15\]" LOCATION "Pin_L23"
cmp add_assignment $top_name "" "dac_sclk\[14\]" LOCATION "Pin_L24"
cmp add_assignment $top_name "" "dac_sclk\[13\]" LOCATION "Pin_H27"
cmp add_assignment $top_name "" "dac_sclk\[12\]" LOCATION "Pin_H28"
cmp add_assignment $top_name "" "dac_sclk\[11\]" LOCATION "Pin_L22"
cmp add_assignment $top_name "" "dac_sclk\[10\]" LOCATION "Pin_L21"
cmp add_assignment $top_name "" "dac_sclk\[9\]" LOCATION "Pin_H26"
cmp add_assignment $top_name "" "dac_sclk\[8\]" LOCATION "Pin_H25"
cmp add_assignment $top_name "" "dac_sclk\[7\]" LOCATION "Pin_A9"
cmp add_assignment $top_name "" "dac_sclk\[6\]" LOCATION "Pin_A8"
cmp add_assignment $top_name "" "dac_sclk\[5\]" LOCATION "Pin_B8"
cmp add_assignment $top_name "" "dac_sclk\[4\]" LOCATION "Pin_B9"
cmp add_assignment $top_name "" "dac_sclk\[3\]" LOCATION "Pin_D9"
cmp add_assignment $top_name "" "dac_sclk\[2\]" LOCATION "Pin_E8"
cmp add_assignment $top_name "" "dac_sclk\[1\]" LOCATION "Pin_C8"
cmp add_assignment $top_name "" "dac_sclk\[0\]" LOCATION "Pin_D8"
cmp add_assignment $top_name "" "dac_sclk\[16\]" LOCATION "Pin_B23"
cmp add_assignment $top_name "" "dac_sclk\[17\]" LOCATION "Pin_E23"
cmp add_assignment $top_name "" "dac_sclk\[18\]" LOCATION "Pin_C23"
cmp add_assignment $top_name "" "dac_sclk\[19\]" LOCATION "Pin_A23"
cmp add_assignment $top_name "" "dac_sclk\[20\]" LOCATION "Pin_D22"
cmp add_assignment $top_name "" "dac_sclk\[21\]" LOCATION "Pin_C22"
cmp add_assignment $top_name "" "dac_sclk\[22\]" LOCATION "Pin_A22"
cmp add_assignment $top_name "" "dac_sclk\[23\]" LOCATION "Pin_B22"
cmp add_assignment $top_name "" "dac_sclk\[24\]" LOCATION "Pin_L18"
cmp add_assignment $top_name "" "dac_sclk\[25\]" LOCATION "Pin_F17"
cmp add_assignment $top_name "" "dac_sclk\[26\]" LOCATION "Pin_C24"
cmp add_assignment $top_name "" "dac_sclk\[27\]" LOCATION "Pin_D23"
cmp add_assignment $top_name "" "dac_sclk\[28\]" LOCATION "Pin_D20"
cmp add_assignment $top_name "" "dac_sclk\[29\]" LOCATION "Pin_B18"
cmp add_assignment $top_name "" "dac_sclk\[30\]" LOCATION "Pin_G19"
cmp add_assignment $top_name "" "dac_sclk\[31\]" LOCATION "Pin_F19"
puts "   Assigned: DAC clock pins."


# assign DAC chip selects	 
# Only Valid prior to Rev. E
#cmp add_assignment $top_name "" lvds_dac_ncs LOCATION "Pin_U10"
#cmp add_assignment $top_name "" lvds_dac_ncs IO_STANDARD LVDS

# Rev. E adds 12 "new" low-noise bias lines
cmp add_assignment $top_name "" "lvds_dac_ncs\[11\]" LOCATION "Pin_U10"
cmp add_assignment $top_name "" "lvds_dac_ncs\[11\]" IO_STANDARD LVDS
cmp add_assignment $top_name "" "lvds_dac_ncs\[10\]" LOCATION "Pin_N3"
cmp add_assignment $top_name "" "lvds_dac_ncs\[10\]" IO_STANDARD LVDS
cmp add_assignment $top_name "" "lvds_dac_ncs\[9\]" LOCATION "Pin_T9"
cmp add_assignment $top_name "" "lvds_dac_ncs\[9\]" IO_STANDARD LVDS
cmp add_assignment $top_name "" "lvds_dac_ncs\[8\]" LOCATION "Pin_T8"
cmp add_assignment $top_name "" "lvds_dac_ncs\[8\]" IO_STANDARD LVDS
cmp add_assignment $top_name "" "lvds_dac_ncs\[7\]" LOCATION "Pin_W6"
cmp add_assignment $top_name "" "lvds_dac_ncs\[7\]" IO_STANDARD LVDS
cmp add_assignment $top_name "" "lvds_dac_ncs\[6\]" LOCATION "Pin_V5"
cmp add_assignment $top_name "" "lvds_dac_ncs\[6\]" IO_STANDARD LVDS
cmp add_assignment $top_name "" "lvds_dac_ncs\[5\]" LOCATION "Pin_N9"
cmp add_assignment $top_name "" "lvds_dac_ncs\[5\]" IO_STANDARD LVDS
cmp add_assignment $top_name "" "lvds_dac_ncs\[4\]" LOCATION "Pin_L7"
cmp add_assignment $top_name "" "lvds_dac_ncs\[4\]" IO_STANDARD LVDS
cmp add_assignment $top_name "" "lvds_dac_ncs\[3\]" LOCATION "Pin_L6"
cmp add_assignment $top_name "" "lvds_dac_ncs\[3\]" IO_STANDARD LVDS
cmp add_assignment $top_name "" "lvds_dac_ncs\[2\]" LOCATION "Pin_M7"
cmp add_assignment $top_name "" "lvds_dac_ncs\[2\]" IO_STANDARD LVDS
cmp add_assignment $top_name "" "lvds_dac_ncs\[1\]" LOCATION "Pin_N8"
cmp add_assignment $top_name "" "lvds_dac_ncs\[1\]" IO_STANDARD LVDS
cmp add_assignment $top_name "" "lvds_dac_ncs\[0\]" LOCATION "Pin_N6"
cmp add_assignment $top_name "" "lvds_dac_ncs\[0\]" IO_STANDARD LVDS

cmp add_assignment $top_name "" "dac_ncs\[15\]" LOCATION "Pin_N20"
cmp add_assignment $top_name "" "dac_ncs\[14\]" LOCATION "Pin_M27"
cmp add_assignment $top_name "" "dac_ncs\[13\]" LOCATION "Pin_N22"
cmp add_assignment $top_name "" "dac_ncs\[12\]" LOCATION "Pin_N24"
cmp add_assignment $top_name "" "dac_ncs\[11\]" LOCATION "Pin_L27"
cmp add_assignment $top_name "" "dac_ncs\[10\]" LOCATION "Pin_N26"
cmp add_assignment $top_name "" "dac_ncs\[9\]" LOCATION "Pin_L25"
cmp add_assignment $top_name "" "dac_ncs\[8\]" LOCATION "Pin_M20"
cmp add_assignment $top_name "" "dac_ncs\[7\]" LOCATION "Pin_K27"
cmp add_assignment $top_name "" "dac_ncs\[6\]" LOCATION "Pin_M24"
cmp add_assignment $top_name "" "dac_ncs\[5\]" LOCATION "Pin_M22"
cmp add_assignment $top_name "" "dac_ncs\[4\]" LOCATION "Pin_J27"
cmp add_assignment $top_name "" "dac_ncs\[3\]" LOCATION "Pin_L20"
cmp add_assignment $top_name "" "dac_ncs\[2\]" LOCATION "Pin_J25"
cmp add_assignment $top_name "" "dac_ncs\[1\]" LOCATION "Pin_L11"
cmp add_assignment $top_name "" "dac_ncs\[0\]" LOCATION "Pin_F8"
cmp add_assignment $top_name "" "dac_ncs\[16\]" LOCATION "Pin_A4"
cmp add_assignment $top_name "" "dac_ncs\[17\]" LOCATION "Pin_B3"
cmp add_assignment $top_name "" "dac_ncs\[18\]" LOCATION "Pin_B4"
cmp add_assignment $top_name "" "dac_ncs\[19\]" LOCATION "Pin_A5"
cmp add_assignment $top_name "" "dac_ncs\[20\]" LOCATION "Pin_E6"
cmp add_assignment $top_name "" "dac_ncs\[21\]" LOCATION "Pin_B7"
cmp add_assignment $top_name "" "dac_ncs\[22\]" LOCATION "Pin_A7"
cmp add_assignment $top_name "" "dac_ncs\[23\]" LOCATION "Pin_C6"
cmp add_assignment $top_name "" "dac_ncs\[24\]" LOCATION "Pin_B11"
cmp add_assignment $top_name "" "dac_ncs\[25\]" LOCATION "Pin_C11"
cmp add_assignment $top_name "" "dac_ncs\[26\]" LOCATION "Pin_B10"
cmp add_assignment $top_name "" "dac_ncs\[27\]" LOCATION "Pin_A10"
cmp add_assignment $top_name "" "dac_ncs\[28\]" LOCATION "Pin_B20"
cmp add_assignment $top_name "" "dac_ncs\[29\]" LOCATION "Pin_C20"
cmp add_assignment $top_name "" "dac_ncs\[30\]" LOCATION "Pin_B21"
cmp add_assignment $top_name "" "dac_ncs\[31\]" LOCATION "Pin_D21"
puts "   Assigned: DAC select pins."


# assign DAC data
cmp add_assignment $top_name "" lvds_dac_data LOCATION "Pin_U5"
cmp add_assignment $top_name "" lvds_dac_data IO_STANDARD LVDS
cmp add_assignment $top_name "" "dac_data\[15\]" LOCATION "Pin_N19"
cmp add_assignment $top_name "" "dac_data\[14\]" LOCATION "Pin_N28"
cmp add_assignment $top_name "" "dac_data\[13\]" LOCATION "Pin_N21"
cmp add_assignment $top_name "" "dac_data\[12\]" LOCATION "Pin_N23"
cmp add_assignment $top_name "" "dac_data\[11\]" LOCATION "Pin_L28"
cmp add_assignment $top_name "" "dac_data\[10\]" LOCATION "Pin_N25"
cmp add_assignment $top_name "" "dac_data\[9\]" LOCATION "Pin_L26"
cmp add_assignment $top_name "" "dac_data\[8\]" LOCATION "Pin_M19"
cmp add_assignment $top_name "" "dac_data\[7\]" LOCATION "Pin_K28"
cmp add_assignment $top_name "" "dac_data\[6\]" LOCATION "Pin_M23"
cmp add_assignment $top_name "" "dac_data\[5\]" LOCATION "Pin_M21"
cmp add_assignment $top_name "" "dac_data\[4\]" LOCATION "Pin_J28"
cmp add_assignment $top_name "" "dac_data\[3\]" LOCATION "Pin_L19"
cmp add_assignment $top_name "" "dac_data\[2\]" LOCATION "Pin_J26"
cmp add_assignment $top_name "" "dac_data\[1\]" LOCATION "Pin_M11"
cmp add_assignment $top_name "" "dac_data\[0\]" LOCATION "Pin_G7"
cmp add_assignment $top_name "" "dac_data\[16\]" LOCATION "Pin_A3"
cmp add_assignment $top_name "" "dac_data\[17\]" LOCATION "Pin_B5"
cmp add_assignment $top_name "" "dac_data\[18\]" LOCATION "Pin_C4"
cmp add_assignment $top_name "" "dac_data\[19\]" LOCATION "Pin_C5"
cmp add_assignment $top_name "" "dac_data\[20\]" LOCATION "Pin_A6"
cmp add_assignment $top_name "" "dac_data\[21\]" LOCATION "Pin_D6"
cmp add_assignment $top_name "" "dac_data\[22\]" LOCATION "Pin_D7"
cmp add_assignment $top_name "" "dac_data\[23\]" LOCATION "Pin_C7"
cmp add_assignment $top_name "" "dac_data\[24\]" LOCATION "Pin_D11"
cmp add_assignment $top_name "" "dac_data\[25\]" LOCATION "Pin_A11"
cmp add_assignment $top_name "" "dac_data\[26\]" LOCATION "Pin_C10"
cmp add_assignment $top_name "" "dac_data\[27\]" LOCATION "Pin_E10"
cmp add_assignment $top_name "" "dac_data\[28\]" LOCATION "Pin_A20"
cmp add_assignment $top_name "" "dac_data\[29\]" LOCATION "Pin_A21"
cmp add_assignment $top_name "" "dac_data\[30\]" LOCATION "Pin_C21"
cmp add_assignment $top_name "" "dac_data\[31\]" LOCATION "Pin_E21"
puts "   Assigned: DAC data pins."


# recompile to commit
puts "\nInfo: Recompiling to commit assignments..."
execute_flow -compile

puts "\nInfo: Process completed."
