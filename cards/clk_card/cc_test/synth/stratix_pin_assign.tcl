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

##############################################################################

########## Set the pin location variables ############
### Control Pins
set clk J17
set reset_n AC9

### Data bus, Address bus, and related control signals
#set ext_addr {A4 A3 B3 B5 B4 C4 A5 C5 D5 E6 A6 B7 D6 A7 D7 C6 C7 B6 D8 C8 E8 D9 B9}
#set ext_data {H12 F12 J12 M12 H17 K18 H18 G18 B8 A8 A9 C9 E10 A10 C10 B10 A11 C11 D11 B11 D10 G10 F10 H11 G11 F8 J9 J13 L13 M11 L11 G7}
#set ext_be_n {M18 F17 J18 L17}
#set ext_read_n F19
#set ext_write_n G19
#set sram_read_n B26
#set flash_ce_n K19
#set sram_ce_n B24
#set sram_we_n C24

### PIOs
set sw {B8 A8 A9}
#set seven_seg {C21 B21 A21 C20 A20 B20 B18 D21 E19 C19 B19 A19 D18 C18 A18 D19}
set led {AC24 AC23 AB22}
#set lcd {H3 L7 L8 H2 H1 L6 L5 J4 M8 M7 K3}

### UARTs
set rxd AG22
set txd AH22


################################################
#### Make the clock and reset signal assignments
cmp add_assignment $top_name "" clk LOCATION "Pin_$clk"
cmp add_assignment $top_name "" reset_n LOCATION "Pin_$reset_n"

#################################################
#### Make the external Flash and SRAM assignments
#set i 0
#foreach {a} $ext_addr {
#	cmp add_assignment $top_name "" "ext_addr\[$i\]" LOCATION "Pin_$a"
#	set i [expr $i+1] 
#}
#set i 0
#foreach {a} $ext_data {
#	cmp add_assignment $top_name "" "ext_data\[$i\]" LOCATION "Pin_$a" 
#	set i [expr $i+1]
#}
#set i 0
#foreach {a} $ext_be_n {
#	cmp add_assignment $top_name "" "ext_be_n\[$i\]" LOCATION "Pin_$a"
#	set i [expr $i+1] 
#}
#cmp add_assignment $top_name "" "ext_read_n" LOCATION "Pin_$ext_read_n"
#cmp add_assignment $top_name "" "ext_write_n" LOCATION "Pin_$ext_write_n"
#cmp add_assignment $top_name "" "sram_read_n" LOCATION "Pin_$sram_read_n"
#cmp add_assignment $top_name "" "flash_ce_n" LOCATION "Pin_$flash_ce_n"
#cmp add_assignment $top_name "" "sram_ce_n" LOCATION "Pin_$sram_ce_n"
#cmp add_assignment $top_name "" "sram_we_n" LOCATION "Pin_$sram_we_n"


#################################
#### Make the PIO pin assignments
set i 2
foreach {a} $sw {
	cmp add_assignment $top_name "" "sw\[$i\]" LOCATION "Pin_$a" 
	set i [expr $i+1]
}
#set i 0
#foreach {a} $lcd {
#	cmp add_assignment $top_name "" "lcd\[$i\]" LOCATION "Pin_$a" 
#	set i [expr $i+1]
#}
#set i 0
#foreach {a} $seven_seg {
#	cmp add_assignment $top_name "" "seven_seg\[$i\]" LOCATION "Pin_$a" 
#	set i [expr $i+1]
#}
set i 0
foreach {a} $led {
	cmp add_assignment $top_name "" "led\[$i\]" LOCATION "Pin_$a" 
	set i [expr $i+1]
}

##############################
#### Make the UART assignments
cmp add_assignment $top_name "" "rxd" LOCATION "Pin_$rxd"
cmp add_assignment $top_name "" "txd" LOCATION "Pin_$txd"





