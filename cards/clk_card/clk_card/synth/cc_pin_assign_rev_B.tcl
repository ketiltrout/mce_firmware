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
#############################################################################


# print welcome message
puts "-------------------------------------"
puts "\n\nClock Card Pin Assignment Script v2.0"
puts "-------------------------------------"
puts "\n(for clock card rev. B)"


# include Quartus Tcl API
package require ::quartus::project
package require ::quartus::flow


# get entity name
set top_name [get_project_settings -cmp]
puts "\n\nInfo: Top-level entity is $top_name."

puts "\nInfo: Assigning pins:"


# assign device parameters
set_global_assignment -name DEVICE EP1S30F780C5
set_global_assignment -name RESERVE_ALL_UNUSED_PINS "AS INPUT TRI-STATED"


#dev_clr_n disabled
set_global_assignment -name ENABLE_DEVICE_WIDE_RESET OFF
puts "   Assigned: EP1S30 device parameters."


# assign rst_n
set_location_assignment Pin_AC9 -to rst_n 
puts "   Assigned: RST_N pin."

# assign extend
set_location_assignment Pin_D28 -to extend_n
puts "   Assigned: EXTEND_N pin."

# assign leds
set_location_assignment Pin_AC23 -to grn_led
set_location_assignment Pin_AC24 -to ylw_led
set_location_assignment Pin_AB22 -to red_led
puts "   Assigned: LED pins."


# assign dip switches
set_location_assignment Pin_B8 -to  dip_sw2
set_location_assignment Pin_A8 -to  dip_sw3
set_location_assignment Pin_A9 -to  dip_sw4
set_location_assignment Pin_AD5 -to dip_sw7
set_location_assignment Pin_AE4 -to dip_sw8
puts "   Assigned: DIP switch pins."


# assign watchdog
set_location_assignment Pin_E6 -to wdog 
# set_location_assignment Pin_AA20 -to crc_error_out
puts "   Assigned: Watchdog pin."


# assign ID pins
set_location_assignment Pin_E27 -to "array_id\[0\]"
set_location_assignment Pin_J23 -to "array_id\[1\]"
set_location_assignment Pin_J24 -to "array_id\[2\]"
set_location_assignment Pin_C28 -to "slot_id\[0\]"
set_location_assignment Pin_C27 -to "slot_id\[1\]"
set_location_assignment Pin_H23 -to "slot_id\[2\]"
set_location_assignment Pin_H24 -to "slot_id\[3\]"
set_location_assignment Pin_AD24 -to card_id
set_location_assignment Pin_L23 -to box_id_in
set_location_assignment Pin_L22 -to box_id_out
set_location_assignment Pin_K21 -to box_id_ena_n
puts "   Assigned: ID pins."


# assign LVDS pins
# for LVDS clk, see PLL section
set_location_assignment Pin_G24 -to lvds_cmd
set_location_assignment Pin_F24 -to lvds_sync
set_location_assignment Pin_G23 -to lvds_spare
set_location_assignment Pin_W26 -to  lvds_reply_ac_a 
set_location_assignment Pin_Y26 -to  lvds_reply_ac_b 
set_location_assignment Pin_U26 -to  lvds_reply_bc1_a
set_location_assignment Pin_V26 -to  lvds_reply_bc1_b
set_location_assignment Pin_W28 -to  lvds_reply_bc2_a
set_location_assignment Pin_Y28 -to  lvds_reply_bc2_b
set_location_assignment Pin_T28 -to  lvds_reply_bc3_a
set_location_assignment Pin_V27 -to  lvds_reply_bc3_b
set_location_assignment Pin_AB28 -to lvds_reply_rc1_a
set_location_assignment Pin_AA28 -to lvds_reply_rc1_b
set_location_assignment Pin_AE28 -to lvds_reply_rc2_a
set_location_assignment Pin_AC28 -to lvds_reply_rc2_b
set_location_assignment Pin_AB26 -to lvds_reply_rc3_a
set_location_assignment Pin_AA25 -to lvds_reply_rc3_b
set_location_assignment Pin_AF28 -to lvds_reply_rc4_a
set_location_assignment Pin_AD28 -to lvds_reply_rc4_b
puts "   Assigned: LVDS pins."


# assign spare TTL
set_location_assignment Pin_L24 -to "ttl_nrx1"
set_location_assignment Pin_H26 -to "ttl_nrx2"
set_location_assignment Pin_H25 -to "ttl_nrx3"
set_location_assignment Pin_L21 -to "ttl_tx1"
set_location_assignment Pin_G27 -to "ttl_tx2"
set_location_assignment Pin_G28 -to "ttl_tx3"
set_location_assignment Pin_K22 -to "ttl_txena1"
set_location_assignment Pin_G26 -to "ttl_txena2"
set_location_assignment Pin_G25 -to "ttl_txena3"
puts "   Assigned: Spare TTL pins."


# assign PLL pins
# PLL5 in     = CLK       (25 MHz from crystal via CPLD)
# PLL5 out[0] = CLKOUT    (25 MHz to lvds clock)
# PLL5 out[1] = FT_CLKW   (25 MHz to fibre tx clock)
# PLL5 out[2] = FR_REFCLK (25 MHz to fibre rx clock)
set_location_assignment Pin_P27 -to   inclk0
set_location_assignment Pin_P25 -to   inclk1
set_location_assignment Pin_R27 -to   inclk2
set_location_assignment Pin_R25 -to   inclk3
set_location_assignment Pin_AC17 -to  inclk4
set_location_assignment Pin_AA17 -to  inclk5
set_location_assignment Pin_R4 -to    inclk8
set_location_assignment Pin_P4 -to   inclk10
set_location_assignment Pin_P2 -to   inclk11
set_location_assignment Pin_K17 -to  inclk14
set_location_assignment Pin_M17 -to  inclk15
set_location_assignment Pin_E15 -to lvds_clk
set_location_assignment Pin_K14 -to fibre_tx_clkW


# For CC Rev. A & AA
#set_location_assignment Pin_AE10 -to fibre_rx_clkr
# For CC Rev B before the new fibre_rx/fibre_tx firmware is in place
#set_location_assignment Pin_G22 -to fibre_rx_clkr
# For CC Rev B after the new fibre_rx/fibre_tx firmware is in place
set_location_assignment Pin_R2 -to fibre_rx_clkr


set_location_assignment Pin_C15 -to fibre_rx_refclk
puts "   Assigned: PLL and clock pins."

   
# assign power supply interface
set_location_assignment Pin_H21 -to mosii
set_location_assignment Pin_H22 -to ccssi
set_location_assignment Pin_E28 -to sclki
set_location_assignment Pin_F28 -to misoo
set_location_assignment Pin_F27 -to sreqo
puts "   Assigned: Power supply interface pins."


set_location_assignment Pin_C10 -to nplus7vok
puts "   Assigned: Power supply status pin."


# assign SMB pins
set_location_assignment Pin_AB21 -to  smb_clk 
set_location_assignment Pin_AB20 -to smb_data
set_location_assignment Pin_Y20 -to smb_nalert
puts "   Assigned: SMB interface pins."


# assign Mictor 0 (P10, Bank 8) test header pins
# set_location_assignment Pin_AE21 -to  "auto_stp_trigger_out_0"
 set_location_assignment Pin_AE21 -to "mictor0_o\[0\]"
 set_location_assignment Pin_AG21 -to "mictor0_o\[1\]"
 set_location_assignment Pin_AF21 -to "mictor0_o\[2\]"
 set_location_assignment Pin_AE20 -to "mictor0_o\[3\]"
 set_location_assignment Pin_AF20 -to "mictor0_o\[4\]"
 set_location_assignment Pin_AH21 -to "mictor0_o\[5\]"
 set_location_assignment Pin_AH20 -to "mictor0_o\[6\]"
 set_location_assignment Pin_AE19 -to "mictor0_o\[7\]"
 set_location_assignment Pin_AD19 -to "mictor0_o\[8\]"
 set_location_assignment Pin_AF19 -to "mictor0_o\[9\]"
 set_location_assignment Pin_AG19 -to "mictor0_o\[10\]"
 set_location_assignment Pin_AH19 -to "mictor0_o\[11\]"
 set_location_assignment Pin_AD18 -to "mictor0_o\[12\]"
 set_location_assignment Pin_AE18 -to "mictor0_o\[13\]"
 set_location_assignment Pin_AG18 -to "mictor0_o\[14\]"
 set_location_assignment Pin_AF17 -to "mictor0_o\[15\]"
 set_location_assignment Pin_AG17 -to "mictor0clk_o"
 puts "   Assigned: Mictor 0 (P10, Bank 8) ODD pod."

set_location_assignment Pin_AD21 -to "mictor0_e\[0\]"
set_location_assignment Pin_AG22 -to "mictor0_e\[1\]"
set_location_assignment Pin_AH22 -to "mictor0_e\[2\]"
set_location_assignment Pin_AF22 -to "mictor0_e\[3\]"
set_location_assignment Pin_AE22 -to "mictor0_e\[4\]"
set_location_assignment Pin_AH23 -to "mictor0_e\[5\]"
set_location_assignment Pin_AF23 -to "mictor0_e\[6\]"
set_location_assignment Pin_AD23 -to "mictor0_e\[7\]"
set_location_assignment Pin_AG23 -to "mictor0_e\[8\]"
set_location_assignment Pin_AH24 -to "mictor0_e\[9\]"
set_location_assignment Pin_AE24 -to "mictor0_e\[10\]"
set_location_assignment Pin_AG24 -to "mictor0_e\[11\]"
set_location_assignment Pin_AF25 -to "mictor0_e\[12\]"
set_location_assignment Pin_AH25 -to "mictor0_e\[13\]"
set_location_assignment Pin_AG25 -to "mictor0_e\[14\]"
set_location_assignment Pin_AH26 -to "mictor0_e\[15\]"
set_location_assignment Pin_AG26 -to "mictor0clk_e"
puts "   Assigned: Mictor 0 (P10, Bank 8) EVEN pod."


# assign Mictor 1 (P11, Bank 7 & 8) test header pins
set_location_assignment Pin_V11 -to "mictor1_o\[0\]"
set_location_assignment Pin_Y9 -to  "mictor1_o\[1\]"
set_location_assignment Pin_Y10 -to "mictor1_o\[2\]"
set_location_assignment Pin_Y11 -to "mictor1_o\[3\]"
set_location_assignment Pin_AA9 -to "mictor1_o\[4\]"
set_location_assignment Pin_AA10 -to "mictor1_o\[5\]"
set_location_assignment Pin_AB7 -to "mictor1_o\[6\]"
set_location_assignment Pin_AB8 -to "mictor1_o\[7\]"
set_location_assignment Pin_AB9 -to "mictor1_o\[8\]"
set_location_assignment Pin_AB12 -to "mictor1_o\[9\]"
set_location_assignment Pin_AC5 -to  "mictor1_o\[10\]"
set_location_assignment Pin_AC6 -to  "mictor1_o\[11\]"
set_location_assignment Pin_AC7 -to  "mictor1_o\[12\]"
set_location_assignment Pin_AD13 -to "mictor1_o\[13\]"
set_location_assignment Pin_AE13 -to "mictor1_o\[14\]"
set_location_assignment Pin_AF13 -to "mictor1_o\[15\]"
set_location_assignment Pin_AD12 -to "mictor1clk_o"
puts "   Assigned: Mictor 1 (P11, Bank 7 & 8) ODD pod."

#set_location_assignment Pin_AA18 -to "mictor1_e\[0\]"
#set_location_assignment Pin_Y18 -to  "mictor1_e\[1\]"
#set_location_assignment Pin_AA19 -to "mictor1_e\[2\]"
#set_location_assignment Pin_W19 -to  "mictor1_e\[3\]"
#set_location_assignment Pin_Y19 -to  "mictor1_e\[4\]"
#set_location_assignment Pin_AA20 -to "mictor1_e\[5\]"
#set_location_assignment Pin_AF24 -to "mictor1_e\[6\]"
#set_location_assignment Pin_AE23 -to "mictor1_e\[7\]"
#set_location_assignment Pin_AG20 -to "mictor1_e\[8\]"
#set_location_assignment Pin_AF18 -to "mictor1_e\[9\]"
#set_location_assignment Pin_AH16 -to "mictor1_e\[10\]"
#set_location_assignment Pin_AC21 -to "mictor1_e\[11\]"
#set_location_assignment Pin_AC19 -to "mictor1_e\[12\]"
#set_location_assignment Pin_AD17 -to "mictor1_e\[13\]"
#set_location_assignment Pin_AE17 -to "mictor1_e\[14\]"
#set_location_assignment Pin_AE12 -to "mictor1_e\[15\]"
#set_location_assignment Pin_AG13 -to "mictor1clk_e"
#puts "   Assigned: Mictor 1 (P11, Bank 7 & 8) EVEN pod."


# assign RS232 pins
#set_location_assignment Pin_C12 -to rs232_rx
#set_location_assignment Pin_B12 -to rs232_tx
#puts "   Assigned: RS-232 interface pins."


# assign RS232 pins
set_location_assignment Pin_C12 -to rx
set_location_assignment Pin_B12 -to tx
puts "   Assigned: RS-232 interface pins."


# assign EEPROM pins
set_location_assignment Pin_AF16 -to eeprom_si
set_location_assignment Pin_AD16 -to eeprom_so
set_location_assignment Pin_AE16 -to eeprom_sck
set_location_assignment Pin_AG16 -to eeprom_cs
puts "   Assigned: EEPROM pins."


# assign SRAM Bank 0
set_location_assignment Pin_C1 -to "sram0_addr\[0\]"
set_location_assignment Pin_C2 -to "sram0_addr\[1\]"
set_location_assignment Pin_D1 -to "sram0_addr\[2\]"
set_location_assignment Pin_D2 -to "sram0_addr\[3\]"
set_location_assignment Pin_E1 -to "sram0_addr\[4\]"
set_location_assignment Pin_E2 -to "sram0_addr\[5\]"
set_location_assignment Pin_F3 -to "sram0_addr\[6\]"
set_location_assignment Pin_F4 -to "sram0_addr\[7\]"
set_location_assignment Pin_F5 -to "sram0_addr\[8\]"
set_location_assignment Pin_F6 -to "sram0_addr\[9\]"
set_location_assignment Pin_G5 -to "sram0_addr\[10\]"
set_location_assignment Pin_G6 -to "sram0_addr\[11\]"
set_location_assignment Pin_H5 -to "sram0_addr\[12\]"
set_location_assignment Pin_H6 -to "sram0_addr\[13\]"
set_location_assignment Pin_H7 -to "sram0_addr\[14\]"
set_location_assignment Pin_H8 -to "sram0_addr\[15\]"
set_location_assignment Pin_J5 -to "sram0_addr\[16\]"
set_location_assignment Pin_J6 -to "sram0_addr\[17\]"
set_location_assignment Pin_K5 -to "sram0_addr\[18\]"
set_location_assignment Pin_K6 -to "sram0_addr\[19\]"
set_location_assignment Pin_G1 -to "sram0_data\[0\]"
set_location_assignment Pin_G2 -to "sram0_data\[1\]"
set_location_assignment Pin_H1 -to "sram0_data\[2\]"
set_location_assignment Pin_H2 -to "sram0_data\[3\]"
set_location_assignment Pin_H3 -to "sram0_data\[4\]"
set_location_assignment Pin_H4 -to "sram0_data\[5\]"
set_location_assignment Pin_J3 -to "sram0_data\[6\]"
set_location_assignment Pin_J4 -to "sram0_data\[7\]"
set_location_assignment Pin_L5 -to "sram0_data\[8\]"
set_location_assignment Pin_L6 -to "sram0_data\[9\]"
set_location_assignment Pin_L7 -to "sram0_data\[10\]"
set_location_assignment Pin_L8 -to "sram0_data\[11\]"
set_location_assignment Pin_M7 -to "sram0_data\[12\]"
set_location_assignment Pin_M8 -to "sram0_data\[13\]"
set_location_assignment Pin_L9 -to "sram0_data\[14\]"
set_location_assignment Pin_L10 -to "sram0_data\[15\]"
set_location_assignment Pin_G3 -to sram0_nbhe
set_location_assignment Pin_J7 -to sram0_nble
set_location_assignment Pin_J8 -to sram0_noe
set_location_assignment Pin_F1 -to sram0_nwe
set_location_assignment Pin_F2 -to  sram0_nce1
set_location_assignment Pin_G4 -to sram0_ce2
puts "   Assigned: SRAM bank 0 pins."


# assign SRAM Bank 1
set_location_assignment Pin_T1 -to  "sram1_addr\[0\]"
set_location_assignment Pin_U2 -to  "sram1_addr\[1\]"
set_location_assignment Pin_T3 -to  "sram1_addr\[2\]"
set_location_assignment Pin_T4 -to  "sram1_addr\[3\]"
set_location_assignment Pin_U3 -to  "sram1_addr\[4\]"
set_location_assignment Pin_U4 -to  "sram1_addr\[5\]"
set_location_assignment Pin_T5 -to  "sram1_addr\[6\]"
set_location_assignment Pin_T6 -to  "sram1_addr\[7\]"
set_location_assignment Pin_T7 -to  "sram1_addr\[8\]"
set_location_assignment Pin_T8 -to  "sram1_addr\[9\]"
set_location_assignment Pin_T9 -to  "sram1_addr\[10\]"
set_location_assignment Pin_T10 -to "sram1_addr\[11\]"
set_location_assignment Pin_U9 -to  "sram1_addr\[12\]"
set_location_assignment Pin_U10 -to "sram1_addr\[13\]"
set_location_assignment Pin_V1 -to  "sram1_addr\[14\]"
set_location_assignment Pin_V2 -to  "sram1_addr\[15\]"
set_location_assignment Pin_W1 -to  "sram1_addr\[16\]"
set_location_assignment Pin_W2 -to  "sram1_addr\[17\]"
set_location_assignment Pin_V3 -to  "sram1_addr\[18\]"
set_location_assignment Pin_V4 -to  "sram1_addr\[19\]"
set_location_assignment Pin_V5 -to  "sram1_data\[0\]"
set_location_assignment Pin_V6 -to  "sram1_data\[1\]"
set_location_assignment Pin_W5 -to  "sram1_data\[2\]"
set_location_assignment Pin_W6 -to  "sram1_data\[3\]"
set_location_assignment Pin_Y2 -to  "sram1_data\[4\]"
set_location_assignment Pin_Y3 -to  "sram1_data\[5\]"
set_location_assignment Pin_Y4 -to  "sram1_data\[6\]"
set_location_assignment Pin_AA1 -to "sram1_data\[7\]"
set_location_assignment Pin_AA2 -to "sram1_data\[8\]"
set_location_assignment Pin_AA3 -to "sram1_data\[9\]"
set_location_assignment Pin_AA4 -to "sram1_data\[10\]"
set_location_assignment Pin_AB1 -to "sram1_data\[11\]"
set_location_assignment Pin_AB2 -to "sram1_data\[12\]"
set_location_assignment Pin_AB4 -to "sram1_data\[13\]"
set_location_assignment Pin_AB3 -to "sram1_data\[14\]"
set_location_assignment Pin_AC1 -to "sram1_data\[15\]"
set_location_assignment Pin_Y1 -to sram1_nbhe
set_location_assignment Pin_U6 -to sram1_nble
set_location_assignment Pin_U5 -to sram1_noe 
set_location_assignment Pin_W4 -to sram1_nwe 
set_location_assignment Pin_W3 -to sram1_nce1
set_location_assignment Pin_V9 -to sram1_ce2 
puts "   Assigned: SRAM bank 1 pins."


# assign fibre transmitter interface
# (fibre_clkw is assigned in PLL section)
set_location_assignment Pin_AF5 -to "fibre_tx_data\[0\]"
set_location_assignment Pin_AH5 -to "fibre_tx_data\[1\]"
set_location_assignment Pin_AF4 -to "fibre_tx_data\[2\]"
set_location_assignment Pin_AG4 -to "fibre_tx_data\[3\]"
set_location_assignment Pin_AG5 -to "fibre_tx_data\[4\]"
set_location_assignment Pin_AG3 -to "fibre_tx_data\[5\]"
set_location_assignment Pin_AE5 -to "fibre_tx_data\[6\]"
set_location_assignment Pin_AH4 -to "fibre_tx_data\[7\]"
set_location_assignment Pin_AG6 -to fibre_tx_ena
set_location_assignment Pin_AH6 -to fibre_tx_rp
set_location_assignment Pin_AE6 -to fibre_tx_sc_nd
set_location_assignment Pin_AD6 -to fibre_tx_enn
set_location_assignment Pin_AF7 -to fibre_tx_bisten
set_location_assignment Pin_AH7 -to fibre_tx_foto
puts "   Assigned: Fibre transmitter interface pins."


# assign fibre receiver interface
# (fibre_clkr and fibre_refclk are assigned in the PLL section)
set_location_assignment Pin_AG9 -to "fibre_rx_data\[0\]"
set_location_assignment Pin_AF9 -to "fibre_rx_data\[1\]"
set_location_assignment Pin_AE9 -to "fibre_rx_data\[2\]"
set_location_assignment Pin_AH8 -to "fibre_rx_data\[3\]"
set_location_assignment Pin_AH9 -to "fibre_rx_data\[4\]"
set_location_assignment Pin_AD8 -to "fibre_rx_data\[5\]"
set_location_assignment Pin_AF8 -to "fibre_rx_data\[6\]"
set_location_assignment Pin_AG8 -to "fibre_rx_data\[7\]"
set_location_assignment Pin_AE14 -to fibre_rx_rdy
set_location_assignment Pin_AH10 -to fibre_rx_status
set_location_assignment Pin_AF10 -to fibre_rx_sc_nd
set_location_assignment Pin_AD10 -to fibre_rx_rvs
set_location_assignment Pin_AF11 -to fibre_rx_a_nb
set_location_assignment Pin_AE11 -to fibre_rx_bisten 
set_location_assignment Pin_AH11 -to fibre_rx_rf 
puts "   Assigned: Fibre receiver interface pins."


# assign manchester fibre interface
set_location_assignment Pin_E10 -to manchester_data 
set_location_assignment Pin_A10 -to manchester_sigdet
puts "   Assigned: Manchester fibre interface pins."


# data valid pulse
set_location_assignment Pin_AG12 -to dv_pulse_fibre
puts "   Assigned: Data valid pulse interface pins."


# configuration device selection
set_location_assignment Pin_A18 -to fpga_tdo
set_location_assignment Pin_C18 -to fpga_tck
set_location_assignment Pin_D18 -to fpga_tms
set_location_assignment Pin_A19 -to epc_tdo
set_location_assignment Pin_B19 -to jtag_sel
set_location_assignment Pin_C19 -to nbb_jtag
set_location_assignment Pin_E19 -to nreconf
set_location_assignment Pin_D19 -to nepc_sel
puts "   Assigned: Configuration device selection pins."

# Clock Card Rev. C+ Only! (next 4 pins) They are all unused in Rev. A/B
set_location_assignment Pin_AA20 -to crc_error_out
set_location_assignment Pin_AA21 -to crc_error_in 			 
set_location_assignment Pin_AH13 -to critical_error
set_location_assignment Pin_AF1 -to dev_clr_fpga_out
puts "   Assigned: miscellaneous pins."


# assign Hardware Revision pins (as of Rev. C Hardware)
set_location_assignment Pin_J28 -to "pcb_rev\[0\]"
set_location_assignment Pin_K28 -to "pcb_rev\[1\]"
set_location_assignment Pin_L28 -to "pcb_rev\[2\]"
set_location_assignment Pin_L27 -to "pcb_rev\[3\]"
puts "   Assigned: Hardware Revision pins."


# recompile to commit
puts "\nInfo: Recompiling to commit assignments..."
execute_flow -compile


puts "\nInfo: Generating .pof file after waiting 10s to let compilation finish."
after 10000 "exec quartus_cpf -c clk_card_sof2pof.cof"


puts "\nInfo: Process completed."
