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
# Modified for the bias card by Mandana Amiri, Apr. 28, 04
#
# Revision history:
# <date $Date: 2004/05/12 19:02:16 $>	- <initials $Author: mandana $>
# $Log: bc_stratix_pin_assign.tcl,v $
# Revision 1.5  2004/05/12 19:02:16  mandana
# modified signal names to match FPGA names, not the board
#
# Revision 1.2  2004/04/29 22:59:04  mandana
# LVDS pins only need positive end to be assigned
#
# Revision 1.1  2004/04/29 20:10:42  mandana
# initial release
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



# print welcome message
puts "\n\nBias Card Pin Assignment Script v1.0"
puts "-------------------------------------"


# include Quartus Tcl API
package require ::quartus::project
package require ::quartus::flow


# get entity name
set top_name [get_project_settings -cmp]
puts "\nInfo: Top-level entity is $top_name."


# assign device parameters
cmp add_assignment $top_name "" "" DEVICE EP1S10F780C5
cmp add_assignment $top_name "" "" RESERVE_ALL_UNUSED_PINS "AS INPUT TRI-STATED"
cmp add_assignment $top_name "" "" ENABLE_DEVICE_WIDE_RESET ON
puts "   Assigned: EP1S30 device parameters."

puts "\nInfo: Assigning pins:"

################################################
#### Set the pin location variables

### DAC PINS
##  the order is dac0, dac1,...., dac31 
set dac_clk {L23 L24 H27 H28 L22 L21 H26 H25  A9  A8  B8  B9  D9  E8  C8  D8 B23 E23 C23 A23 D22 C22 A22 B22 L18 F17 C24 D23 D20 B18 G19 F19}
set dac_ncs {N20 M27 N22 N24 L27 N26 L25 M20 K27 M24 M22 J27 L20 J25 L11 J13  A4  B3  B4  A5  E6  B7  A7  C6 B11 C11 B10 A10 B20 C20 B21 D21}
set dac_dat {N19 N28 N21 N23 L28 N25 L26 M19 K28 M23 M21 J28 L19 J26 M11 L13  A3  B5  C4  C5  A6  D6  D7  C7 D11 A11 C10 E10 A20 A21 C21 E21} 
set dac_nclr {M16}

### LVDS DAC pins (only the positive side of LVDS signals have to be assigned)

#set lvds_dac_clk_n T6
set lvds_dac_clk T5

#set lvds_ncs_n U9
set lvds__dac_ncs U10

#set lvds_dat_n U6
set lvds_dac_dat U5

### Card ID, Slot ID Pins
set card_id T21
set slot_id {V25 V26 T25 T26}

### LVDS receive pins
set lvds_clk AA27
set lvds_cmd V23
set lvds_sync AA28
set lvds_spare V24

### LVDS transmit pins
set lvds_txa V19
set lvds_txb V20

### DIP switch 
set dip_sw3 W23
set dip_sw4 W24

### LEDs
## Fault LED
set red_led V27
## Status LED
set ylw_led T24
## Power LED
set grn_led_led T23


### mictor connector header (MSB in the left-most position, LSB in the right-most)
set mictor_od        {AE18 AG19 AF20 AG21 AG22 AG23 AG24 AG25 AG26 AD18 AF19 AE20 AF21 AF22 AF23 AE24 }
set mictor_od_clk    Y17

set mictor_ed        {AH19 AG18 AH20 AH21 AH22 AH23 AH24 AH25 AH26 AF25 AD19 AE19 AD21 AE21 AE22 AD23 }
set mictor_ed_clk    AB17

#### test point header (MSB in the left-most position, LSB in the right-most)
set test_header      {AG8  AF8  AD8  AH9  AH8  AE9  AF9  AG9 AD10 AF10 AH10 AE10 AF11 AE11 AH11 AG11 }

### POWER Status pins
set minus7vok  U25
set n15vok     U26
set n5vdok     T20
set n7vok      T22

### NRX pins???
#set nrx1 U19
#set nrx2 U20
#set nrx3 W28

### tx pins
set tx1     Y26
set tx2     U21
set tx3     Y28
set txen1   Y25
set txen2   U22
set txen3   Y27

### watchdog pin
set wdog     T28



################################################
#### Make DAC SPI signal assignments

set i 0
foreach {a} $dac_clk {
	cmp add_assignment $top_name "" "dac_clk\[$i\]" LOCATION "Pin_$a"
	set i [expr $i+1]
}

foreach {a} $dac_ncs {
	cmp add_assignment $top_name "" "dac_ncs\[$i\]" LOCATION "Pin_$a"
	set i [expr $i+1]
}

set i 0
foreach {a} $dac_dat {
	cmp add_assignment $top_name "" "dac_dat\[$i\]" LOCATION "Pin_$a"
	set i [expr $i+1]
}
cmp add_assignment $top_name "" dac_nclr LOCATION "Pin_$dac_nclr"

puts "   Assigned: DAC pins."

################################################
#### Make LVDS DAC signal assignments
cmp add_assignment $top_name "" lvds_dac_clk LOCATION "Pin_$lvds_dac_clk"
cmp add_assignment $top_name "" lvds_dac_ncs LOCATION "Pin_$lvds_dac_ncs"
cmp add_assignment $top_name "" lvds_dac_dat LOCATION "Pin_$lvds_dac_dat"

##cmp add_assignment $top_name "" lvds_clk_n LOCATION "Pin_$lvds_clk_n"
##cmp add_assignment $top_name "" lvds_ncs_n LOCATION "Pin_$lvds_ncs_n"
##cmp add_assignment $top_name "" lvds_data_n LOCATION "Pin_$lvds_data_n"

puts "   Assigned: LVDS DAC pins."

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
puts "   Assigned: ID pins."

################################################
#### Make the LVDS signal assignments
cmp add_assignment $top_name "" lvds_clk LOCATION "Pin_$lvds_clk"
cmp add_assignment $top_name "" lvds_cmd LOCATION "Pin_$lvds_cmd"
cmp add_assignment $top_name "" lvds_sync LOCATION "Pin_$lvds_sync"
cmp add_assignment $top_name "" lvds_spare LOCATION "Pin_$lvds_spare"
cmp add_assignment $top_name "" lvds_txa LOCATION "Pin_$lvds_txa"
cmp add_assignment $top_name "" lvds_txb LOCATION "Pin_$lvds_txb"
puts "   Assigned: LVDS pins."


################################################
#### Make the DIP switch signal assignments
cmp add_assignment $top_name "" dip_sw3 LOCATION "Pin_$dip_sw3"
cmp add_assignment $top_name "" dip_sw4 LOCATION "Pin_$dip_sw4"
puts "   Assigned: DIP switch pins."

################################################
#### Make the LED signal assignments
cmp add_assignment $top_name "" red_led LOCATION "Pin_$red_led"
cmp add_assignment $top_name "" ylw_led LOCATION "Pin_$ylw_led"
cmp add_assignment $top_name "" grn_led LOCATION "Pin_$grn_led"
puts "   Assigned: LED pins."


################################################
#### Make the POWER signal assignments
cmp add_assignment $top_name "" minus7vok LOCATION "Pin_$minus7vok"
cmp add_assignment $top_name "" n15vok    LOCATION "Pin_$n15vok"   
cmp add_assignment $top_name "" n5vdok    LOCATION "Pin_$n5vdok"   
cmp add_assignment $top_name "" n7vok     LOCATION "Pin_$n7vok"   

################################################
#### Make the NRX signal assignments
cmp add_assignment $top_name "" nrx3 LOCATION "Pin_$nrx3"
cmp add_assignment $top_name "" nrx2 LOCATION "Pin_$nrx2"
cmp add_assignment $top_name "" nrx1 LOCATION "Pin_$nrx1"

################################################
#### Make the TX signal assignments
cmp add_assignment $top_name "" tx1   LOCATION "Pin_$tx1"  
cmp add_assignment $top_name "" tx2   LOCATION "Pin_$tx2"  
cmp add_assignment $top_name "" tx3   LOCATION "Pin_$tx3"  
cmp add_assignment $top_name "" tx1en LOCATION "Pin_$tx1en"
cmp add_assignment $top_name "" tx2en LOCATION "Pin_$tx2en"
cmp add_assignment $top_name "" tx3en LOCATION "Pin_$tx3en"

################################################
#### Make the Watchdog signal assignments
cmp add_assignment $top_name "" wdog LOCATION "Pin_$wdog"
puts "   Assigned: Watchdog pin."

################################################
#### Make the Test Header signal assignments
set i 0
foreach {a} $test_header {
	cmp add_assignment $top_name "" "test_header\[$i\]" LOCATION "Pin_$a"
	set i [expr $i+1]
}
puts "   Assigned: 16-pin Test Header pins."

# recompile to commit
puts "\nInfo: Recompiling to commit assignments..."
execute_flow -compile

puts "\nInfo: Process completed."