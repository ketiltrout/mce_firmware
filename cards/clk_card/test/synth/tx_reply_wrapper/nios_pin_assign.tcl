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
# nios_pin_assign.tcl
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

# J11-25 
cmp add_assignment $top_name "" "read1_i"   LOCATION "Pin_M9"      
# J11-29    
cmp add_assignment $top_name "" "read2_i"   LOCATION "Pin_M6"        
 
# J16-21
cmp add_assignment $top_name "" "stim1_i"   LOCATION "Pin_AH23"       
# J16-25
cmp add_assignment $top_name "" "stim2_i"   LOCATION "Pin_AD23"        

# J11-3..10
#cmp add_assignment $top_name "" "tx_data_o\[0]" LOCATION "Pin_P3"    
#cmp add_assignment $top_name "" "tx_data_o\[1]" LOCATION "Pin_N10"   
#cmp add_assignment $top_name "" "tx_data_o\[2]" LOCATION "Pin_N9"    
#cmp add_assignment $top_name "" "tx_data_o\[3]" LOCATION "Pin_M2"    
#cmp add_assignment $top_name "" "tx_data_o\[4]" LOCATION "Pin_N1"    
#cmp add_assignment $top_name "" "tx_data_o\[5]" LOCATION "Pin_N5"    
#cmp add_assignment $top_name "" "tx_data_o\[6]" LOCATION "Pin_N6"    
#cmp add_assignment $top_name "" "tx_data_o\[7]" LOCATION "Pin_M3"    

# J11-11..12
cmp add_assignment $top_name "" "tsc_nTd_o" LOCATION "Pin_M4"        
cmp add_assignment $top_name "" "nFena_o"   LOCATION "Pin_N7"        


# J16-3..10
#cmp add_assignment $top_name "" "tx_data_o\[0]" LOCATION "Pin_AD19"    
#cmp add_assignment $top_name "" "tx_data_o\[1]" LOCATION "Pin_AE19"   
#cmp add_assignment $top_name "" "tx_data_o\[2]" LOCATION "Pin_AF18"    
#cmp add_assignment $top_name "" "tx_data_o\[3]" LOCATION "Pin_AH20"    
#cmp add_assignment $top_name "" "tx_data_o\[4]" LOCATION "Pin_AH21"    
#cmp add_assignment $top_name "" "tx_data_o\[5]" LOCATION "Pin_AF20"    
#cmp add_assignment $top_name "" "tx_data_o\[6]" LOCATION "Pin_AE20"    
#cmp add_assignment $top_name "" "tx_data_o\[7]" LOCATION "Pin_AF21"    
       
# J16-13
cmp add_assignment $top_name "" "ant16_trig_o" LOCATION "Pin_AD21"  


# J16-3,5,7,9
#cmp add_assignment $top_name "" "test1_i" LOCATION "Pin_AD19"   
#cmp add_assignment $top_name "" "test2_i" LOCATION "Pin_AF18"
#cmp add_assignment $top_name "" "test3_i" LOCATION "Pin_AH21"   
#cmp add_assignment $top_name "" "test4_i" LOCATION "Pin_AE20"

# J16-4,6,8,10,12,14
#cmp add_assignment $top_name "" "test1_o" LOCATION "Pin_AE19"
#cmp add_assignment $top_name "" "test2_o" LOCATION "Pin_AH20"   
#cmp add_assignment $top_name "" "test3_o" LOCATION "Pin_AF20"
#cmp add_assignment $top_name "" "test4_o" LOCATION "Pin_AF21" 
#cmp add_assignment $top_name "" "test5_o" LOCATION "Pin_AE21"
#cmp add_assignment $top_name "" "test6_o" LOCATION "Pin_AG20"   
  

puts "....Pins Assigned."


# recompile to commit
puts "\nInfo: Recompiling to commit assignments..."
execute_flow -compile

puts "\nInfo: Process completed."