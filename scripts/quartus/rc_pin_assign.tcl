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
#
#
#############################################################################

# print welcome message
puts "\n\nReadout Card Pin Assignment Script v1.0"
puts "-------------------------------------"


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
cmp add_assignment $top_name "" eeprom_si LOCATION "Pin_F20"
cmp add_assignment $top_name "" eeprom_so LOCATION "Pin_F18"
cmp add_assignment $top_name "" eeprom_sck LOCATION "Pin_F21"
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

### mictor connector header (LSB in the left-most position, MSB in the right-most)
set mictor {E13 D13 C13 E12 B13 D12 C12 B12 B11 D11 C11 A11 B10 C10 A10 E10  A9  A8  B8  B9  D9  E8  C8  D8  C7  C6  D7  A7  D6  B7  A6  E6}
set i 0
foreach {a} $mictor {
	cmp add_assignment $top_name "" "mictor\[$i\]" LOCATION "Pin_$a"
	set i [expr $i+1]
}


### Serial DAC PINS
##  the order is dac1, dac2,...., dac8 
set dac_clk {AE8 Y10 AB7 AC5 AG20 AB22 AB20 AB18}
set bias_dac_ncs {AH3 V11 AA9 AB9 AH16 AC24 AD24 AC22}
set offset_dac_ncs {AE7 Y9 AA10 AB12 AF18 AC23 AB21 AC20}
set dac_dat {AG10 Y11 AB8 AC6 AE23 AE25 Y20 V18}  

set i 0
foreach {a} $dac_clk {
	cmp add_assignment $top_name "" "dac_clk\[$i\]" LOCATION "Pin_$a"
	set i [expr $i+1]
}

foreach {a} $dac_ncs {
	cmp add_assignment $top_name "" "bias_dac_ncs\[$i\]" LOCATION "Pin_$a"
	set i [expr $i+1]
}

foreach {a} $dac_ncs {
	cmp add_assignment $top_name "" "offset_dac_ncs\[$i\]" LOCATION "Pin_$a"
	set i [expr $i+1]
}

set i 0
foreach {a} $dac_dat {
	cmp add_assignment $top_name "" "dac_dat\[$i\]" LOCATION "Pin_$a"
	set i [expr $i+1]
}

puts "   Assigned: Serial DAC pins."

### Parallel DAC PINS
##  the order is dac1, dac2,...., dac8 
set dac_FB_clk {N10 C2 F2 M10 AG12 AH4 AG18 AG8}
set dac_FB1_dat {N9 M3 M4 N5 N6 L1 L2 N7 N8 L3 L4 N4 N3 K1}  
set dac_FB2_dat {C1 H5 H6 D2 D1 H7 H8 E2 E1 J5 J6 F4 F3 K6}
set dac_FB3_dat {F1 J8 J7 G3 G4 K8 K7 G2 G1 L7 L8 H4 H3 L6}
set dac_FB4_dat {M9 K4 K3 M6 M5 J1 J2 M8 M7 J3 J4 L10 L9 H1}
set dac_FB5_dat {AF12 AE12 AG13 AD12 AF13 AE13 AD13 AE16 AF16 AD16 AG16 AD17 AE17 AG17}
set dac_FB6_dat {AE5 AG3 AG5 AG4 AF4 AH5 AF5 AE6 AG6 AH6 AD6 AF7 AH7 AG7}
set dac_FB7_dat {AE18 AD18 AH19 AG19 AF19 AD19 AE19 AH20 AH21 AF20 AE20 AF21 AG21 AE21}
set dac_FB8_dat {AF8 AD8 AH9 AH8 AE9 AF9 AG9 AD10 AF10 AH10 AE10 AF11 AE11 AH11}

set i 0
foreach {a} $dac_FB_clk {
	cmp add_assignment $top_name "" "dac_FB_clk\[$i\]" LOCATION "Pin_$a"
	set i [expr $i+1]
}

set i 0
foreach {a} $dac_FB1_dat {
	cmp add_assignment $top_name "" "dac_FB1_dat\[$i\]" LOCATION "Pin_$a"
	set i [expr $i+1]
}

set i 0
foreach {a} $dac_FB2_dat {
	cmp add_assignment $top_name "" "dac_FB2_dat\[$i\]" LOCATION "Pin_$a"
	set i [expr $i+1]
}

set i 0
foreach {a} $dac_FB3_dat {
	cmp add_assignment $top_name "" "dac_FB3_dat\[$i\]" LOCATION "Pin_$a"
	set i [expr $i+1]
}

set i 0
foreach {a} $dac_FB4_dat {
	cmp add_assignment $top_name "" "dac_FB4_dat\[$i\]" LOCATION "Pin_$a"
	set i [expr $i+1]
}

set i 0
foreach {a} $dac_FB5_dat {
	cmp add_assignment $top_name "" "dac_FB5_dat\[$i\]" LOCATION "Pin_$a"
	set i [expr $i+1]
}

set i 0
foreach {a} $dac_FB6_dat {
	cmp add_assignment $top_name "" "dac_FB6_dat\[$i\]" LOCATION "Pin_$a"
	set i [expr $i+1]
}

set i 0
foreach {a} $dac_FB7_dat {
	cmp add_assignment $top_name "" "dac_FB7_dat\[$i\]" LOCATION "Pin_$a"
	set i [expr $i+1]
}

set i 0
foreach {a} $dac_FB8_dat {
	cmp add_assignment $top_name "" "dac_FB8_dat\[$i\]" LOCATION "Pin_$a"
	set i [expr $i+1]
}

puts "   Assigned: Parallel DAC pins."

### ADC PINS
##  the order is adc1, adc2,...., adc8 
set adc_clk {AB6 AA8 AA6 Y5 Y8 V10 U8 U5}
set adc_rdy {W22 AH22  N19 AA22  W28  M19  F27  C27}
set adc_ovr {AG22 N20 AA21 W27 M20 F28 C28 W21}
set adc1_dat {AB26 AB25  W23  W24 AB28 AB27  V22  V21 AA25 AA26  V24  V23 AA28 AA27}  
set adc2_dat {AF22  AE22  AH23  AF23  AD23  AG23  AH24  AE24  AG24  AF25  AH25  AG25  AH26  AG26}
set adc3_dat {M25 M26 N22 N21 L27 L28 N24 N23 L25 L26 N26 N25 K27 K28}
set adc4_dat {AF28 AF27 AA23 AA24 AE28 AE27  Y24  Y23 AD28 AD27  Y21  Y22 AC28 AC27}
set adc5_dat {U20 U19 W25 W26 U23 U24 Y27 Y28 U22 U21 Y25 Y26 V20 V19}
set adc6_dat {K26 K25 M24 M23 J27 J28 M22 M21 J25 J26 L20 L19 H27 H28}
set adc7_dat {J22 J21 G25 G26 K22 K21 G28 G27 L21 L22 H25 H26 L24 L23}
set adc8_dat {H23 H24 D28 D27 H21 H22 E28 E27 J23 J24 F26 F25 K24 K23}

set i 0
foreach {a} $adc_clk {
	cmp add_assignment $top_name "" "adc_clk\[$i\]" LOCATION "Pin_$a"
	set i [expr $i+1]
}

set i 0
foreach {a} $adc_rdy {
	cmp add_assignment $top_name "" "adc_rdy\[$i\]" LOCATION "Pin_$a"
	set i [expr $i+1]
}

set i 0
foreach {a} $adc1_dat {
	cmp add_assignment $top_name "" "adc1_dat\[$i\]" LOCATION "Pin_$a"
	set i [expr $i+1]
}

set i 0
foreach {a} $adc2_dat {
	cmp add_assignment $top_name "" "adc2_dat\[$i\]" LOCATION "Pin_$a"
	set i [expr $i+1]
}

set i 0
foreach {a} $adc3_dat {
	cmp add_assignment $top_name "" "adc3_dat\[$i\]" LOCATION "Pin_$a"
	set i [expr $i+1]
}

set i 0
foreach {a} $adc4_dat {
	cmp add_assignment $top_name "" "adc4_dat\[$i\]" LOCATION "Pin_$a"
	set i [expr $i+1]
}

set i 0
foreach {a} $adc5_dat {
	cmp add_assignment $top_name "" "adc5_dat\[$i\]" LOCATION "Pin_$a"
	set i [expr $i+1]
}

set i 0
foreach {a} $adc6_dat {
	cmp add_assignment $top_name "" "adc6_dat\[$i\]" LOCATION "Pin_$a"
	set i [expr $i+1]
}

set i 0
foreach {a} $adc7_dat {
	cmp add_assignment $top_name "" "adc7_dat\[$i\]" LOCATION "Pin_$a"
	set i [expr $i+1]
}

set i 0
foreach {a} $adc8_dat {
	cmp add_assignment $top_name "" "adc8_dat\[$i\]" LOCATION "Pin_$a"
	set i [expr $i+1]
}

puts "   Assigned: ADC pins."

# recompile to commit
puts "\nInfo: Recompiling to commit assignments..."
execute_flow -compile

puts "\nInfo: Process completed."