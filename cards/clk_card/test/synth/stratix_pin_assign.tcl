###############################################################################
# pin_assign.tcl
#
# This script allows you to make pin assignments to the Nios tutorial design
#
#
# Written by: Jeremy Fox
# Rev 1.0
# 10/25/00
#
# Modified for the clock card by Neil Gruending, Mar 4, 2004
# 
# Revision History:
# $Log: stratix_pin_assign.tcl,v $
# Revision 1.1  2004/04/14 22:14:01  jjacob
# new directory structure
#
# Revision 1.3  2004/04/07 16:28:02  erniel
# added SRAM bank 0 pins
# added SRAM bank 1 pins
# added id (card, slot, array) pins
#
#
#
# You can run this script from Quartus by observing the following steps:
# 1. Place this TCL script in your project directory
# 2. Open your project
# 3. Go to the View Menu and Auxilary Windows -> TCL console
# 4. In the TCL console type:
#						source pin_assign.tcl
# 5. The script will assign pins and return an "assignment made" message.
###############################################################################


################ Open a Project if one does not yet exist ####################
set project_name cc_test
set top_name cc_test

if { ![project exists ./$project_name] } {
	project create ./$project_name
}
project open ./$project_name

set cmp_settings_group $top_name
if { ![project cmp_exists $cmp_settings_group] } {
        project create_cmp $top_name
}
project set_active_cmp $top_name

cmp add_assignment $top_name "" "" DEVICE EP1S30F780C6

################################################
#### Set the pin location variables

### Control Pins
set clk J17
set reset_n AC9

### LVDS transmit pins
set cmd G24
set sync F24
set txspare G23

### SRAM Bank 0 Address, Data, Control Pins
set sram0_addr {C1 C2 D1 D2 E1 E2 F3 F4 F5 F6 G5 G6 H5 H6 H7 H8 J5 J6 K5 K6}
set sram0_data {G1 G2 H1 H2 H3 H4 J3 J4 L5 L6 L7 L8 M7 M8 L9 L10}
set sram0_nble J7
set sram0_nbhe G3
set sram0_noe J8
set sram0_nce1 F2
set sram0_nwe F1

### SRAM Bank 1 Address, Data, Control Pins
#set sram1_addr {T1 U2 T3 T4 U3 U4 T5 T6 T7 T8 T9 T10 U9 U10 V1 V2 W1 W2 V3 V4}
#set sram1_data {V5 V6 W5 W6 Y2 Y3 Y4 AA1 AA2 AA3 AA4 AB1 AB2 AB4 AB3 AC1}
#set sram1_nble U6
#set sram1_nbhe Y1
#set sram1_noe U5
#set sram1_nce1 W3
#set sram1_nwe W4

### Card ID, Slot ID, Array ID Pins
set card_id L23
set slot_id {C28 C27 H23 H24}
set array_id {E27 J23 J24}

### PIOs
set sw {B8 A8 A9}
set led {AC24 AC23 AB22}

### UARTs
set rxd AG22
set txd AH22


################################################
#### Make the clock and reset signal assignments
cmp add_assignment $top_name "" clk LOCATION "Pin_$clk"
cmp add_assignment $top_name "" reset_n LOCATION "Pin_$reset_n"


################################################
#### Make the LVDS signal assignments
cmp add_assignment $top_name "" cmd LOCATION "Pin_$cmd"
cmp add_assignment $top_name "" sync LOCATION "Pin_$sync"
cmp add_assignment $top_name "" txspare LOCATION "Pin_$txspare"


################################################
#### Make SRAM signal assignments

### Bank 0:
set i 0
foreach {a} $sram0_addr {
	cmp add_assignment $top_name "" "sram0_addr\[$i\]" LOCATION "Pin_$a"
	set i [expr $i+1]
}
set i 0
foreach {a} $sram0_data {
	cmp add_assignment $top_name "" "sram0_data\[$i\]" LOCATION "Pin_$a"
	set i [expr $i+1]
}
cmp add_assignment $top_name "" sram0_nble LOCATION "Pin_$sram0_nble"
cmp add_assignment $top_name "" sram0_nbhe LOCATION "Pin_$sram0_nbhe"
cmp add_assignment $top_name "" sram0_noe LOCATION "Pin_$sram0_noe"
cmp add_assignment $top_name "" sram0_nce1 LOCATION "Pin_$sram0_nce1"
cmp add_assignment $top_name "" sram0_nwe LOCATION "Pin_$sram0_nwe"


### Bank 1:
#set i 0
#foreach {a} $sram1_addr {
#	cmp add_assignment $top_name "" "sram1_addr\[$i\]" LOCATION "Pin_$a"
#	set i [expr $i+1]
#}
#set i 0
#foreach {a} $sram1_addr {
#	cmp add_assignment $top_name "" "sram1_data\[$i\]" LOCATION "Pin_$a"
#	set i [expr $i+1]
#}
#cmp add_assignment $top_name "" sram1_nble LOCATION "Pin_$sram1_nble"
#cmp add_assignment $top_name "" sram1_nbhe LOCATION "Pin_$sram1_nbhe"
#cmp add_assignment $top_name "" sram1_noe LOCATION "Pin_$sram1_noe"
#cmp add_assignment $top_name "" sram1_nce1 LOCATION "Pin_$sram1_nce1"
#cmp add_assignment $top_name "" sram1_nwe LOCATION "Pin_$sram1_nwe"


################################################
#### Make Card ID signal assignments
cmp add_assignment $top_name "" card_id LOCATION "Pin_$card_id"


################################################
#### Make Slot ID signal assignments
set i 0
foreach {a} $slot_id {
	cmp add_assignment $top_name "" "slot_id\[$i\]" LOCATION "Pin_$a"
	set i [expr $i+1]
}


################################################
#### Make Array ID signal assignments
set i 0
foreach {a} $array_id {
	cmp add_assignment $top_name "" "array_id\[$i\]" LOCATION "Pin_$a"
	set i [expr $i+1]
}


################################################
#### Make the PIO pin assignments
set i 2
foreach {a} $sw {
	cmp add_assignment $top_name "" "sw\[$i\]" LOCATION "Pin_$a" 
	set i [expr $i+1]
}
set i 0
foreach {a} $led {
	cmp add_assignment $top_name "" "led\[$i\]" LOCATION "Pin_$a" 
	set i [expr $i+1]
}


################################################
#### Make the UART assignments
cmp add_assignment $top_name "" "rxd" LOCATION "Pin_$rxd"
cmp add_assignment $top_name "" "txd" LOCATION "Pin_$txd"





