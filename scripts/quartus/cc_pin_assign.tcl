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
# cc_pin_assign.tcl
#
# Project:       SCUBA-2
# Author:        Ernie Lin
# Organization:  UBC
#
# Description:
# This script allows you to make pin assignments to the clock card
#
# Revision history:
#
# $Log$
#
#
#############################################################################


puts "Clock Card Pin Assignment Script"
puts "--------------------------------"


puts -nonewline "Enter the name of the top-level entity:  "
flush stdout
set top_name [gets stdin]

puts "Entity name = $top_name"


#############################################################################
# assign device

cmp add_assignment $top_name "" "" DEVICE EP1S30F780C5


#############################################################################
# leds

cmp add_assignment $top_name "" grn_led LOCATION "Pin_AC23"
cmp add_assignment $top_name "" ylw_led LOCATION "Pin_AC24"
cmp add_assignment $top_name "" red_led LOCATION "Pin_AB22"

puts "LED pins assigned"


#############################################################################
# dip

cmp add_assignment $top_name "" dip_sw2 LOCATION "Pin_B8"
cmp add_assignment $top_name "" dip_sw3 LOCATION "Pin_A8"
cmp add_assignment $top_name "" dip_sw4 LOCATION "Pin_A9"
cmp add_assignment $top_name "" dip_sw7 LOCATION "Pin_AD5"
cmp add_assignment $top_name "" dip_sw8 LOCATION "Pin_AE4"

puts "DIP switch pins assigned"


#############################################################################
# Watchdog

cmp add_assignment $top_name "" wdog LOCATION "Pin_E6"

puts "Watchdog pin assigned"


#############################################################################
# ID pins

cmp add_assignment $top_name "" "array_id\[0\]" LOCATION "Pin_E27"
cmp add_assignment $top_name "" "array_id\[1\]" LOCATION "Pin_J23"
cmp add_assignment $top_name "" "array_id\[2\]" LOCATION "Pin_J24"

cmp add_assignment $top_name "" "slot_id\[0\]" LOCATION "Pin_C28"
cmp add_assignment $top_name "" "slot_id\[1\]" LOCATION "Pin_C27"
cmp add_assignment $top_name "" "slot_id\[2\]" LOCATION "Pin_H23"
cmp add_assignment $top_name "" "slot_id\[3\]" LOCATION "Pin_H24"

cmp add_assignment $top_name "" card_id LOCATION "Pin_AD24"

cmp add_assignment $top_name "" box_id_in LOCATION "Pin_L23"
cmp add_assignment $top_name "" box_id_out LOCATION "Pin_L22"
cmp add_assignment $top_name "" box_id_ena LOCATION "Pin_K21"

puts "ID pins assigned"


#############################################################################
# LVDS pins

# for LVDS clk, see PLL section

cmp add_assignment $top_name "" lvds_cmd LOCATION "Pin_G24"
cmp add_assignment $top_name "" lvds_sync LOCATION "Pin_F24"
cmp add_assignment $top_name "" lvds_spare LOCATION "Pin_G23"

cmp add_assignment $top_name "" lvds_rx0a LOCATION "Pin_W26"
cmp add_assignment $top_name "" lvds_rx0b LOCATION "Pin_Y26"
cmp add_assignment $top_name "" lvds_rx1a LOCATION "Pin_U26"
cmp add_assignment $top_name "" lvds_rx1b LOCATION "Pin_V26"
cmp add_assignment $top_name "" lvds_rx2a LOCATION "Pin_W28"
cmp add_assignment $top_name "" lvds_rx2b LOCATION "Pin_Y28"
cmp add_assignment $top_name "" lvds_rx3a LOCATION "Pin_T28"
cmp add_assignment $top_name "" lvds_rx3b LOCATION "Pin_V27"
cmp add_assignment $top_name "" lvds_rx4a LOCATION "Pin_AB28"
cmp add_assignment $top_name "" lvds_rx4b LOCATION "Pin_AA28"
cmp add_assignment $top_name "" lvds_rx5a LOCATION "Pin_AE28"
cmp add_assignment $top_name "" lvds_rx5b LOCATION "Pin_AC28"
cmp add_assignment $top_name "" lvds_rx6a LOCATION "Pin_AB26"
cmp add_assignment $top_name "" lvds_rx6b LOCATION "Pin_AA25"
cmp add_assignment $top_name "" lvds_rx7a LOCATION "Pin_AF28"
cmp add_assignment $top_name "" lvds_rx7b LOCATION "Pin_AD28"

puts "LVDS pins assigned"


#############################################################################
# Spare TTL

cmp add_assignment $top_name "" "spttl_in\[1\]" LOCATION "Pin_L24"
cmp add_assignment $top_name "" "spttl_in\[2\]" LOCATION "Pin_H26"
cmp add_assignment $top_name "" "spttl_in\[3\]" LOCATION "Pin_H25"
cmp add_assignment $top_name "" "spttl_out\[1\]" LOCATION "Pin_L21"
cmp add_assignment $top_name "" "spttl_out\[2\]" LOCATION "Pin_G27"
cmp add_assignment $top_name "" "spttl_out\[3\]" LOCATION "Pin_G28"
cmp add_assignment $top_name "" "spttl_ena\[1\]" LOCATION "Pin_K22"
cmp add_assignment $top_name "" "spttl_ena\[2\]" LOCATION "Pin_G26"
cmp add_assignment $top_name "" "spttl_ena\[3\]" LOCATION "Pin_G25"

puts "Spare TTL pins assigned"


#############################################################################
# PLL

# PLL5 in     = CLK
# PLL5 out[0] = CLKOUT    (lvds clock)
# PLL5 out[1] = FT_CLKW   (fibre tx clock)
# PLL5 out[2] = FR_REFCLK (fibre rx clock)
# PLL5 out[3] = pllout    (for observing PLL)

cmp add_assignment $top_name "" inclk LOCATION "Pin_K17"
cmp add_assignment $top_name "" lvds_clk LOCATION "Pin_E15"
cmp add_assignment $top_name "" fibre_tx_clk LOCATION "Pin_K14"
cmp add_assignment $top_name "" fibre_rx_clk LOCATION "Pin_C15"
cmp add_assignment $top_name "" outclk LOCATION "Pin_K16"

cmp add_assignment $top_name "" "pll6_in" LOCATION "Pin_AC17"
cmp add_assignment $top_name "" "pll6_out\[0\]" LOCATION "Pin_AD15"
cmp add_assignment $top_name "" "pll6_out\[1\]" LOCATION "Pin_W14"
cmp add_assignment $top_name "" "pll6_out\[2\]" LOCATION "Pin_AF15"
cmp add_assignment $top_name "" "pll6_out\[3\]" LOCATION "Pin_W16"

puts "PLL pins assigned"


#############################################################################
# Power Supply

cmp add_assignment $top_name "" psdo LOCATION "Pin_H21"
cmp add_assignment $top_name "" pscso LOCATION "Pin_H22"
cmp add_assignment $top_name "" psclko LOCATION "Pin_E28"

cmp add_assignment $top_name "" psdi LOCATION "Pin_F28"
cmp add_assignment $top_name "" pscsi LOCATION "Pin_F27"
cmp add_assignment $top_name "" psclki LOCATION "Pin_J22"

cmp add_assignment $top_name "" n_5vok LOCATION "Pin_AG25"

puts "Power supply pins assigned"


#############################################################################
# SMB

cmp add_assignment $top_name "" smbclk LOCATION "Pin_AB21"
cmp add_assignment $top_name "" smbdata LOCATION "Pin_AB20"
cmp add_assignment $top_name "" talert LOCATION "Pin_Y20"

puts "SMB pins assigned"


#############################################################################
# Test Header (2X20)

# test[8]  = rs232_rx
# test[10] = rs232_tx
cmp add_assignment $top_name "" rs232_rx LOCATION "Pin_AG22"     
cmp add_assignment $top_name "" rs232_tx LOCATION "Pin_AH22"     

cmp add_assignment $top_name "" "test\[7\]" LOCATION "Pin_AD21"
cmp add_assignment $top_name "" "test\[9\]" LOCATION "Pin_AE21"


# assign pins to test header pins 11 thru 38 (pins 1 thru 10 are used by RS232 connector, pins 39 & 40 are DGND)

set test {AG21 AF22 AF21 AE22 AE20 AH23 AF20 AF23 AH21 AD23 AH20 AG23 AE19 AH24 AD19 AE24 AF19 AG24 AG19 AF25 AH19 AH25 AD18 AG25 AE18 AH26 AG18 AG26}
set i 11
foreach {a} $test
{
   cmp add_assignment $top_name "" "test\[$i\]" LOCATION "Pin_$a"
   set i [expr $i+1]
}

puts "Test header pins assigned"


#############################################################################
# EEPROM

cmp add_assignment $top_name "" eeprom_si LOCATION "Pin_AF16"
cmp add_assignment $top_name "" eeprom_so LOCATION "Pin_AD16"
cmp add_assignment $top_name "" eeprom_sck LOCATION "Pin_AE16"
cmp add_assignment $top_name "" eeprom_cs LOCATION "Pin_AG16"

puts "EEPROM pins assigned"


#############################################################################
# SRAM Bank 0

set sram0_addr {C1 C2 D1 D2 E1 E2 F3 F4 F5 F6 G5 G6 H5 H6 H7 H8 J5 J6 K5 K6}
set i 0
foreach {a} $sram0_addr
{
   cmp add_assignment $top_name "" "sram0_addr\[$i\]" LOCATION "Pin_$a"
   set i [expr $i+1]
}

set sram0_data {G1 G2 H1 H2 H3 H4 J3 J4 L5 L6 L7 L8 M7 M8 L9 L10}
set i 0
foreach {a} $sram0_data
{
   cmp add_assignment $top_name "" "sram0_data\[$i\]" LOCATION "Pin_$a"
   set i [expr $i+1]
}

cmp add_assignment $top_name "" sram0_nbhe LOCATION "Pin_G3"
cmp add_assignment $top_name "" sram0_nble LOCATION "Pin_J7"
cmp add_assignment $top_name "" sram0_noe LOCATION "Pin_J8"
cmp add_assignment $top_name "" sram0_nwe LOCATION "Pin_F1"
cmp add_assignment $top_name "" sram0_ncs LOCATION "Pin_F2"

puts "SRAM bank 0 pins assigned"


#############################################################################
# SRAM Bank 1

set sram1_addr {T1 U2 T3 T4 U3 U4 T5 T6 T7 T8 T9 T10 U9 U10 V1 V2 W1 W2 V3 V4}
set i 0
foreach {a} $sram1_addr
{
   cmp add_assignment $top_name "" "sram1_addr\[$i\]" LOCATION "Pin_$a"
   set i [expr $i+1]
}

set sram1_data {V5 V6 W5 W6 Y2 Y3 Y4 AA1 AA2 AA3 AA4 AB1 AB2 AB4 AB3 AC1}
set i 0
foreach {a} $sram1_data
{
   cmp add_assignment $top_name "" "sram1_data\[$i\]" LOCATION "Pin_$a"
   set i [expr $i+1]
}

cmp add_assignment $top_name "" sram1_nbhe LOCATION "Pin_Y1"
cmp add_assignment $top_name "" sram1_nble LOCATION "Pin_U6"
cmp add_assignment $top_name "" sram1_noe LOCATION "Pin_U5"
cmp add_assignment $top_name "" sram1_nwe LOCATION "Pin_W4"
cmp add_assignment $top_name "" sram1_ncs LOCATION "Pin_W3"

puts "SRAM bank 1 pins assigned"


#############################################################################
# Fibre

#fibre_tx_data
#fibre_tx_clk
#fibre_tx_ena
#fibre_tx_rp
#fibre_tx_sc_nd

#fibre_rx_data
#fibre_rx_clk
#fibre_rx_error
#fibre_rx_rdy
#fibre_rx_status
#fibre_rx_sc_nd


#############################################################################
# Flash

