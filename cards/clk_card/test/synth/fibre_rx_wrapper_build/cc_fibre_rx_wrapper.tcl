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
# cc_fibre_rx_wrapper.tcl
#
# Project:       SCUBA-2
# Author:        David Atkinson
# Organization:  ATC
#
# Description:
# This script allows you to make pin assignments to the nios card
#
#
#
#############################################################################

# print welcome message
puts "\n\nClock Card AA - Pin Assignment Script v1.0"
puts "---------------------------------------------"
puts "          David Atkinson - Nov '04           "
puts "---------------------------------------------"

# include Quartus Tcl API
package require ::quartus::project
package require ::quartus::flow


# print welcome message
puts "\n\nClock Card Pin Assignment Script v1.0"
puts "-------------------------------------"
puts "\n(for clock card rev. AA)"


# include Quartus Tcl API
package require ::quartus::project
package require ::quartus::flow


# get entity name
set top_name [get_project_settings -cmp]
puts "\n\nInfo: Top-level entity is $top_name."

puts "\nInfo: Assigning pins:"


# assign device parameters
cmp add_assignment $top_name "" "" DEVICE EP1S30F780C5
cmp add_assignment $top_name "" "" RESERVE_ALL_UNUSED_PINS "AS INPUT TRI-STATED"
cmp add_assignment $top_name "" "" ENABLE_DEVICE_WIDE_RESET ON
puts "   Assigned: EP1S30 device parameters."


# assign leds
#cmp add_assignment $top_name "" grn_led LOCATION "Pin_AC23"
#cmp add_assignment $top_name "" ylw_led LOCATION "Pin_AC24"
#cmp add_assignment $top_name "" red_led LOCATION "Pin_AB22"
#puts "   Assigned: LED pins."


# assign dip switches
#cmp add_assignment $top_name "" dip_sw2 LOCATION "Pin_B8"
#cmp add_assignment $top_name "" dip_sw3 LOCATION "Pin_A8"
#cmp add_assignment $top_name "" dip_sw4 LOCATION "Pin_A9"
#cmp add_assignment $top_name "" dip_sw7 LOCATION "Pin_AD5"
#cmp add_assignment $top_name "" dip_sw8 LOCATION "Pin_AE4"
#puts "   Assigned: DIP switch pins."


# assign watchdog
#cmp add_assignment $top_name "" wdog LOCATION "Pin_E6"
#puts "   Assigned: Watchdog pin."


# assign ID pins
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
puts "   Assigned: ID pins."


# assign LVDS pins
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
puts "   Assigned: LVDS pins."


# assign spare TTL
cmp add_assignment $top_name "" "ttl_nrx\[1\]" LOCATION "Pin_L24"
cmp add_assignment $top_name "" "ttl_nrx\[2\]" LOCATION "Pin_H26"
cmp add_assignment $top_name "" "ttl_nrx\[3\]" LOCATION "Pin_H25"
cmp add_assignment $top_name "" "ttl_tx\[1\]" LOCATION "Pin_L21"
cmp add_assignment $top_name "" "ttl_tx\[2\]" LOCATION "Pin_G27"
cmp add_assignment $top_name "" "ttl_tx\[3\]" LOCATION "Pin_G28"
cmp add_assignment $top_name "" "ttl_txena\[1\]" LOCATION "Pin_K22"
cmp add_assignment $top_name "" "ttl_txena\[2\]" LOCATION "Pin_G26"
cmp add_assignment $top_name "" "ttl_txena\[3\]" LOCATION "Pin_G25"
puts "   Assigned: Spare TTL pins."


# assign PLL pins
# PLL5 in     = CLK       (25 MHz from crystal via CPLD)
# PLL5 out[0] = CLKOUT    (25 MHz to lvds clock)
# PLL5 out[1] = FT_CLKW   (25 MHz to fibre tx clock)
# PLL5 out[2] = FR_REFCLK (25 MHz to fibre rx clock)

cmp add_assignment $top_name "" inclk LOCATION "Pin_K17"


cmp add_assignment $top_name "" lvds_clk LOCATION "Pin_E15"
cmp add_assignment $top_name "" fibre_tx_clk LOCATION "Pin_K14"
cmp add_assignment $top_name "" fibre_rx_clk LOCATION "Pin_C15"

#cmp add_assignment $top_name "" "pll6_in" LOCATION "Pin_AC17"
#cmp add_assignment $top_name "" "pll6_out\[0\]" LOCATION "Pin_AD15"
#cmp add_assignment $top_name "" "pll6_out\[1\]" LOCATION "Pin_W14"
#cmp add_assignment $top_name "" "pll6_out\[2\]" LOCATION "Pin_AF15"
#cmp add_assignment $top_name "" "pll6_out\[3\]" LOCATION "Pin_W16"
puts "   Assigned: PLL pins."


# assign power supply interface
cmp add_assignment $top_name "" psdo LOCATION "Pin_H21"
cmp add_assignment $top_name "" pscso LOCATION "Pin_H22"
cmp add_assignment $top_name "" psclko LOCATION "Pin_E28"
cmp add_assignment $top_name "" psdi LOCATION "Pin_F28"
cmp add_assignment $top_name "" pscsi LOCATION "Pin_F27"
cmp add_assignment $top_name "" psclki LOCATION "Pin_J22"
cmp add_assignment $top_name "" n5vok LOCATION "Pin_AG25"
puts "   Assigned: Power supply interface pins."


# assign SMB pins
cmp add_assignment $top_name "" smb_clk LOCATION "Pin_AB21"
cmp add_assignment $top_name "" smb_data LOCATION "Pin_AB20"
cmp add_assignment $top_name "" smb_nalert LOCATION "Pin_Y20"
puts "   Assigned: SMB interface pins."


# assign mictor test header pins
cmp add_assignment $top_name "" "mictor_o\[1\]" LOCATION "Pin_AD21"
cmp add_assignment $top_name "" "mictor_o\[2\]" LOCATION "Pin_AE21"
cmp add_assignment $top_name "" "mictor_o\[3\]" LOCATION "Pin_AG21"
cmp add_assignment $top_name "" "mictor_o\[4\]" LOCATION "Pin_AF21"
cmp add_assignment $top_name "" "mictor_o\[5\]" LOCATION "Pin_AE20"
cmp add_assignment $top_name "" "mictor_o\[6\]" LOCATION "Pin_AF20"
cmp add_assignment $top_name "" "mictor_o\[7\]" LOCATION "Pin_AH21"
cmp add_assignment $top_name "" "mictor_o\[8\]" LOCATION "Pin_AH20"
cmp add_assignment $top_name "" "mictor_o\[9\]" LOCATION "Pin_AE19"
cmp add_assignment $top_name "" "mictor_o\[10\]" LOCATION "Pin_AD19"
cmp add_assignment $top_name "" "mictor_o\[11\]" LOCATION "Pin_AF19"
cmp add_assignment $top_name "" "mictor_o\[12\]" LOCATION "Pin_AG19"
cmp add_assignment $top_name "" "mictor_o\[13\]" LOCATION "Pin_AH19"
cmp add_assignment $top_name "" "mictor_o\[14\]" LOCATION "Pin_AD18"
cmp add_assignment $top_name "" "mictor_o\[15\]" LOCATION "Pin_AE18"
cmp add_assignment $top_name "" "mictorclk_o" LOCATION "Pin_AG18"
puts "   Assigned: Mictor test header pins (ODD pod)."

cmp add_assignment $top_name "" "mictor_e\[1\]" LOCATION "Pin_AG22"
cmp add_assignment $top_name "" "mictor_e\[2\]" LOCATION "Pin_AH22"
cmp add_assignment $top_name "" "mictor_e\[3\]" LOCATION "Pin_AF22"
cmp add_assignment $top_name "" "mictor_e\[4\]" LOCATION "Pin_AE22"
cmp add_assignment $top_name "" "mictor_e\[5\]" LOCATION "Pin_AH23"
cmp add_assignment $top_name "" "mictor_e\[6\]" LOCATION "Pin_AF23"
cmp add_assignment $top_name "" "mictor_e\[7\]" LOCATION "Pin_AD23"
cmp add_assignment $top_name "" "mictor_e\[8\]" LOCATION "Pin_AG23"
cmp add_assignment $top_name "" "mictor_e\[9\]" LOCATION "Pin_AH24"
cmp add_assignment $top_name "" "mictor_e\[10\]" LOCATION "Pin_AE24"
cmp add_assignment $top_name "" "mictor_e\[11\]" LOCATION "Pin_AG24"
cmp add_assignment $top_name "" "mictor_e\[12\]" LOCATION "Pin_AF25"
cmp add_assignment $top_name "" "mictor_e\[13\]" LOCATION "Pin_AH25"
cmp add_assignment $top_name "" "mictor_e\[14\]" LOCATION "Pin_AG25"
cmp add_assignment $top_name "" "mictor_e\[15\]" LOCATION "Pin_AH26"
cmp add_assignment $top_name "" "mictorclk_e" LOCATION "Pin_AG26"
puts "   Assigned: Mictor test header pins (EVEN pod)."


# assign RS232 pins
cmp add_assignment $top_name "" rs232_rx LOCATION "Pin_AF17"
cmp add_assignment $top_name "" rs232_tx LOCATION "Pin_AG17"
puts "   Assigned: RS-232 interface pins."


# assign EEPROM pins
cmp add_assignment $top_name "" eeprom_si LOCATION "Pin_AF16"
cmp add_assignment $top_name "" eeprom_so LOCATION "Pin_AD16"
cmp add_assignment $top_name "" eeprom_sck LOCATION "Pin_AE16"
cmp add_assignment $top_name "" eeprom_cs LOCATION "Pin_AG16"
puts "   Assigned: EEPROM pins."


# assign SRAM Bank 0
cmp add_assignment $top_name "" "sram0_addr\[0\]" LOCATION "Pin_C1"
cmp add_assignment $top_name "" "sram0_addr\[1\]" LOCATION "Pin_C2"
cmp add_assignment $top_name "" "sram0_addr\[2\]" LOCATION "Pin_D1"
cmp add_assignment $top_name "" "sram0_addr\[3\]" LOCATION "Pin_D2"
cmp add_assignment $top_name "" "sram0_addr\[4\]" LOCATION "Pin_E1"
cmp add_assignment $top_name "" "sram0_addr\[5\]" LOCATION "Pin_E2"
cmp add_assignment $top_name "" "sram0_addr\[6\]" LOCATION "Pin_F3"
cmp add_assignment $top_name "" "sram0_addr\[7\]" LOCATION "Pin_F4"
cmp add_assignment $top_name "" "sram0_addr\[8\]" LOCATION "Pin_F5"
cmp add_assignment $top_name "" "sram0_addr\[9\]" LOCATION "Pin_F6"
cmp add_assignment $top_name "" "sram0_addr\[10\]" LOCATION "Pin_G5"
cmp add_assignment $top_name "" "sram0_addr\[11\]" LOCATION "Pin_G6"
cmp add_assignment $top_name "" "sram0_addr\[12\]" LOCATION "Pin_H5"
cmp add_assignment $top_name "" "sram0_addr\[13\]" LOCATION "Pin_H6"
cmp add_assignment $top_name "" "sram0_addr\[14\]" LOCATION "Pin_H7"
cmp add_assignment $top_name "" "sram0_addr\[15\]" LOCATION "Pin_H8"
cmp add_assignment $top_name "" "sram0_addr\[16\]" LOCATION "Pin_J5"
cmp add_assignment $top_name "" "sram0_addr\[17\]" LOCATION "Pin_J6"
cmp add_assignment $top_name "" "sram0_addr\[18\]" LOCATION "Pin_K5"
cmp add_assignment $top_name "" "sram0_addr\[19\]" LOCATION "Pin_K6"
cmp add_assignment $top_name "" "sram0_data\[0\]" LOCATION "Pin_G1"
cmp add_assignment $top_name "" "sram0_data\[1\]" LOCATION "Pin_G2"
cmp add_assignment $top_name "" "sram0_data\[2\]" LOCATION "Pin_H1"
cmp add_assignment $top_name "" "sram0_data\[3\]" LOCATION "Pin_H2"
cmp add_assignment $top_name "" "sram0_data\[4\]" LOCATION "Pin_H3"
cmp add_assignment $top_name "" "sram0_data\[5\]" LOCATION "Pin_H4"
cmp add_assignment $top_name "" "sram0_data\[6\]" LOCATION "Pin_J3"
cmp add_assignment $top_name "" "sram0_data\[7\]" LOCATION "Pin_J4"
cmp add_assignment $top_name "" "sram0_data\[8\]" LOCATION "Pin_L5"
cmp add_assignment $top_name "" "sram0_data\[9\]" LOCATION "Pin_L6"
cmp add_assignment $top_name "" "sram0_data\[10\]" LOCATION "Pin_L7"
cmp add_assignment $top_name "" "sram0_data\[11\]" LOCATION "Pin_L8"
cmp add_assignment $top_name "" "sram0_data\[12\]" LOCATION "Pin_M7"
cmp add_assignment $top_name "" "sram0_data\[13\]" LOCATION "Pin_M8"
cmp add_assignment $top_name "" "sram0_data\[14\]" LOCATION "Pin_L9"
cmp add_assignment $top_name "" "sram0_data\[15\]" LOCATION "Pin_L10"
cmp add_assignment $top_name "" sram0_nbhe LOCATION "Pin_G3"
cmp add_assignment $top_name "" sram0_nble LOCATION "Pin_J7"
cmp add_assignment $top_name "" sram0_noe LOCATION "Pin_J8"
cmp add_assignment $top_name "" sram0_nwe LOCATION "Pin_F1"
cmp add_assignment $top_name "" sram0_ncs LOCATION "Pin_F2"
puts "   Assigned: SRAM bank 0 pins."


# assign SRAM Bank 1
cmp add_assignment $top_name "" "sram1_addr\[0\]" LOCATION "Pin_T1"
cmp add_assignment $top_name "" "sram1_addr\[1\]" LOCATION "Pin_U2"
cmp add_assignment $top_name "" "sram1_addr\[2\]" LOCATION "Pin_T3"
cmp add_assignment $top_name "" "sram1_addr\[3\]" LOCATION "Pin_T4"
cmp add_assignment $top_name "" "sram1_addr\[4\]" LOCATION "Pin_U3"
cmp add_assignment $top_name "" "sram1_addr\[5\]" LOCATION "Pin_U4"
cmp add_assignment $top_name "" "sram1_addr\[6\]" LOCATION "Pin_T5"
cmp add_assignment $top_name "" "sram1_addr\[7\]" LOCATION "Pin_T6"
cmp add_assignment $top_name "" "sram1_addr\[8\]" LOCATION "Pin_T7"
cmp add_assignment $top_name "" "sram1_addr\[9\]" LOCATION "Pin_T8"
cmp add_assignment $top_name "" "sram1_addr\[10\]" LOCATION "Pin_T9"
cmp add_assignment $top_name "" "sram1_addr\[11\]" LOCATION "Pin_T10"
cmp add_assignment $top_name "" "sram1_addr\[12\]" LOCATION "Pin_U9"
cmp add_assignment $top_name "" "sram1_addr\[13\]" LOCATION "Pin_U10"
cmp add_assignment $top_name "" "sram1_addr\[14\]" LOCATION "Pin_V1"
cmp add_assignment $top_name "" "sram1_addr\[15\]" LOCATION "Pin_V2"
cmp add_assignment $top_name "" "sram1_addr\[16\]" LOCATION "Pin_W1"
cmp add_assignment $top_name "" "sram1_addr\[17\]" LOCATION "Pin_W2"
cmp add_assignment $top_name "" "sram1_addr\[18\]" LOCATION "Pin_V3"
cmp add_assignment $top_name "" "sram1_addr\[19\]" LOCATION "Pin_V4"
cmp add_assignment $top_name "" "sram1_data\[0\]" LOCATION "Pin_V5"
cmp add_assignment $top_name "" "sram1_data\[1\]" LOCATION "Pin_V6"
cmp add_assignment $top_name "" "sram1_data\[2\]" LOCATION "Pin_W5"
cmp add_assignment $top_name "" "sram1_data\[3\]" LOCATION "Pin_W6"
cmp add_assignment $top_name "" "sram1_data\[4\]" LOCATION "Pin_Y2"
cmp add_assignment $top_name "" "sram1_data\[5\]" LOCATION "Pin_Y3"
cmp add_assignment $top_name "" "sram1_data\[6\]" LOCATION "Pin_Y4"
cmp add_assignment $top_name "" "sram1_data\[7\]" LOCATION "Pin_AA1"
cmp add_assignment $top_name "" "sram1_data\[8\]" LOCATION "Pin_AA2"
cmp add_assignment $top_name "" "sram1_data\[9\]" LOCATION "Pin_AA3"
cmp add_assignment $top_name "" "sram1_data\[10\]" LOCATION "Pin_AA4"
cmp add_assignment $top_name "" "sram1_data\[11\]" LOCATION "Pin_AB1"
cmp add_assignment $top_name "" "sram1_data\[12\]" LOCATION "Pin_AB2"
cmp add_assignment $top_name "" "sram1_data\[13\]" LOCATION "Pin_AB4"
cmp add_assignment $top_name "" "sram1_data\[14\]" LOCATION "Pin_AB3"
cmp add_assignment $top_name "" "sram1_data\[15\]" LOCATION "Pin_AC1"
cmp add_assignment $top_name "" sram1_nbhe LOCATION "Pin_Y1"
cmp add_assignment $top_name "" sram1_nble LOCATION "Pin_U6"
cmp add_assignment $top_name "" sram1_noe LOCATION "Pin_U5"
cmp add_assignment $top_name "" sram1_nwe LOCATION "Pin_W4"
cmp add_assignment $top_name "" sram1_ncs LOCATION "Pin_W3"
puts "   Assigned: SRAM bank 1 pins."


# assign fibre interface
# (fibre_tx_clk and fibre_rx_clk are assigned in PLL section)
cmp add_assignment $top_name "" "fibre_tx_data\[0\]" LOCATION "Pin_AF5"
cmp add_assignment $top_name "" "fibre_tx_data\[1\]" LOCATION "Pin_AH5"
cmp add_assignment $top_name "" "fibre_tx_data\[2\]" LOCATION "Pin_AF4"
cmp add_assignment $top_name "" "fibre_tx_data\[3\]" LOCATION "Pin_AG4"
cmp add_assignment $top_name "" "fibre_tx_data\[4\]" LOCATION "Pin_AG5"
cmp add_assignment $top_name "" "fibre_tx_data\[5\]" LOCATION "Pin_AG3"
cmp add_assignment $top_name "" "fibre_tx_data\[6\]" LOCATION "Pin_AE5"
cmp add_assignment $top_name "" "fibre_tx_data\[7\]" LOCATION "Pin_AH4"
cmp add_assignment $top_name "" fibre_tx_ena LOCATION "Pin_AG6"
cmp add_assignment $top_name "" fibre_tx_rp LOCATION "Pin_AH6"
cmp add_assignment $top_name "" fibre_tx_sc_nd LOCATION "Pin_AE6"
puts "   Assigned: Fibre transmitter interface pins."

#fibre_rx_data
cmp add_assignment $top_name "" "fibre_rx_data\[0\]" LOCATION "Pin_AG9"
cmp add_assignment $top_name "" "fibre_rx_data\[1\]" LOCATION "Pin_AF9"
cmp add_assignment $top_name "" "fibre_rx_data\[2\]" LOCATION "Pin_AE9"
cmp add_assignment $top_name "" "fibre_rx_data\[3\]" LOCATION "Pin_AH8"
cmp add_assignment $top_name "" "fibre_rx_data\[4\]" LOCATION "Pin_AH9"
cmp add_assignment $top_name "" "fibre_rx_data\[5\]" LOCATION "Pin_AD8"
cmp add_assignment $top_name "" "fibre_rx_data\[6\]" LOCATION "Pin_AF8"
cmp add_assignment $top_name "" "fibre_rx_data\[7\]" LOCATION "Pin_AG8"
cmp add_assignment $top_name "" fibre_rx_rdy LOCATION "Pin_AE14"
cmp add_assignment $top_name "" fibre_rx_status LOCATION "Pin_AH10"
cmp add_assignment $top_name "" fibre_rx_sc_nd LOCATION "Pin_AF10"
cmp add_assignment $top_name "" fibre_rx_rvs LOCATION "Pin_AD10"
cmp add_assignment $top_name "" fibre_rx_ckr LOCATION "Pin_AE10"
puts "   Assigned: Fibre receiver interface pins."


# recompile to commit
puts "\nInfo: Recompiling to commit assignments..."
execute_flow -compile

puts "\nInfo: Process completed."