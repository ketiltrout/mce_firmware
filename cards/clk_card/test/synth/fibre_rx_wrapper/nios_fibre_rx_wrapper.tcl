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
# nios_fibre_rx_wrapper.tcl
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
puts "\n\nNios Dev Board Pin Assignment Script v1.0"
puts "---------------------------------------------"
puts "          David Atkinson - Oct '04           "
puts "---------------------------------------------"

# include Quartus Tcl API
package require ::quartus::project
package require ::quartus::flow


# get entity name
set top_name [get_project_settings -cmp]
puts "\nInfo: Top-level entity is $top_name."


# assign device parameters
cmp add_assignment $top_name "" "" DEVICE EP1S10F780C6ES
cmp add_assignment $top_name "" "" RESERVE_ALL_UNUSED_PINS "AS INPUT TRI-STATED"
cmp add_assignment $top_name "" "" ENABLE_DEVICE_WIDE_RESET ON
puts "   Assigned: EP1S10 device parameters."




puts "\nInfo: Assigning pins:"

# assign pins

# J11-21
cmp add_assignment $top_name "" "rst_i"   LOCATION "Pin_L4"         
# nios 50Mhz clock
cmp add_assignment $top_name "" "clk_i"   LOCATION "Pin_K17"


# J16-21
cmp add_assignment $top_name "" "stim1_i"   LOCATION "Pin_AH23"       
# J16-25
cmp add_assignment $top_name "" "stim2_i"   LOCATION "Pin_AD23"        


puts "....Pins Assigned."


# recompile to commit
puts "\nInfo: Recompiling to commit assignments..."
execute_flow -compile

puts "\nInfo: Process completed."