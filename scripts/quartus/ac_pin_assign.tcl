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
# $Log: ac_pin_assign.tcl,v $
# Revision 1.4  2004/04/29 02:32:43  bburger
# no message
#
# Revision 1.3  2004/04/28 18:03:31  bburger
# Regrouped bus and clock signals into standard logic vectors
#
# Revision 1.2  2004/04/14 19:22:01  jjacob
# added DAC buses, DAC clock signals and mictor and test headers
#
# Revision 1.1  2004/04/14 01:00:55  bburger
# new
#
# Revision 1.1  2004/04/13 19:43:26  bburger
# new
#
# You can run this script from Quartus by observing the following steps:
# 1. Place this TCL script in your project directory
# 2. Open your project
# 3. Go to the View Menu and Auxilary Windows -> TCL console
# 4. In the TCL console type:
#                        source pin_assign.tcl
# 5. The script will assign pins and return an "assignment made" message.
###############################################################################

# print welcome message
puts "\n\nAddress Card Pin Assignment Script v1.0"
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

#set up groups of pins with generic names

# mictor connector header (LSB in the right-most, MSB in the left-most position)
set mictor_od        {AD19 AD18 AE19 AE18 AF19 AG18 AE20 AH19 AG19 AH20 AF20 AH21 AG21 AF21 AE21 Y17}
set mictor_od_clk    AB17

set mictor_ed        {AH26 AG26 AH25 AG25 AH24 AG24 AH23 AF25 AG22 AG23 AF22 AF23 AD21 AE22 AH22 AE24 }
set mictor_ed_clk    AD23


# test point header (LSB in the right-most, MSB in the left-most position)
set test_header     {AF9 AG11 AD10 AH11 AE10 AF11 AD8 AH10 AE9 AE11 AF8 AH9 AG8 AF10 AG9 AH8}

### LVDS receive pins
set lvds_clk AA27
set lvds_cmd V23
set lvds_sync AA28
set lvds_spare V24

### LVDS transmit pins
set lvds_txa V19
set lvds_txb V20

### DIP switch (pin 3 and 4)
set dip_sw3 M2
set dip_sw4 N1

### LEDs (red is fault, yellow is status and green is power_ok)
set red_led V27
set ylw_led T24
set grn_led T23

## watchdog 
set wdog T28

## slot ID
set slot_id {V25 V26 T25 T26}
set card_id T21

### Micellaneous
set nextnd U27
set n7v_ok T22

### spare TTL pins
set nrx3 W28
set nrx2 U20
set nrx1 U19
set tx1 Y26
set tx_en1 Y25
set tx2 U21
set tx_en2 U22
set tx3 Y28
set tx_en3 Y27

# smb pins
set smb_clk U23
set smb_data W26
set nalert W25

# DAC bus signals
# for the DACs, the leftmost pin on each line is the LSB (bit 0), the rightmost pin is MSB (bit 13)
# the first line lists pins for bus 0, the last line list pins for bus 10
set dac_dat {N19 N20 L21 N21 N22 L23 N23 N24 H25 L25 L26 H27 L27 M27 
             M21 L22 M22 H26 J25 J26 H28 J27 J28 K27 K28 L24 M23 M24 
             L10 L9  M6  M7  L7  K4  H1  J2  G1  H2  J3  G2  H3  H4  
             C18 D19 B18 C19 A18 B19 A19 C20 D21 C21 B21 A21 E21 C24 
             G7  F10 D10 D5  D7  D6  C4  C6  B3  B4  C5  A3  A4  B5  
             D9  D8  B6  C8  B8  C9  A8  B9  A9  C10 B10 B11 C11 A11 
             AH7 AH6 AH4 AG3 AG4 AF4 AG5 AG7 AE5 AG6 AD6 AE6 AF6 AF7 
             N3  M4  M3  L1  N7  K1  L2  J1  K2  K3  N8  M8  M9  M10 
             V10 V9  AA4 U10 AA3 V8  AA1 AA2 Y1  Y2  W1  W4  V5  V6  
             V4  W3  W2  V3  V1  V2  U2  U5  T5  T1  T3  T4  T6  T7  
             B26 B25 A25 D24 B24 B23 A23 C23 A22 B22 D23 C22 E23 D22}

# DAC clk signals
# The list of clock signals begins at clock 0, and ends with clock 40 (dark row)
set dac_clk {N28 M20 N26 L20 M19  N25 L19 L28 K8 E19 
             L8  D18 F19 K7  J18  J4  A7  E8  B7 D11
             F8  C7  G10 A5  AB10 M5  AH5 N4  N5 AC8
             N6  AE8 U8  U7  T8   T9  T10 U6  U9 V7
             D20}

################################################
#### Make the DAC signal assignments
set i 0
set j 0
foreach {a} $dac_dat {   
   cmp add_assignment $top_name "" "dac_dat\[$j\][$i\]" LOCATION "Pin_$a"
   set i [expr $i+1] }
   if { $i = 13} {
     set j [expr $j+1]
     set i 0
   }     
}   
set i 0
foreach {a} $dac_clk {
   cmp add_assignment $top_name "" "dac_clk\[$i\]" LOCATION "Pin_$a"
   set i [expr $i+1] }
}

puts "   Assigned: DAC pins."

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
#### Make the DIP switch signal assignments (pin 3 and 4)
cmp add_assignment $top_name "" dip_sw3 LOCATION "Pin_$dip_sw3"
cmp add_assignment $top_name "" dip_sw4 LOCATION "Pin_$dip_sw4"
puts "   Assigned: DIP Switch pins."

################################################
#### Make the LED signal assignments
cmp add_assignment $top_name "" red_led LOCATION "Pin_$red_led"
cmp add_assignment $top_name "" ylw_led LOCATION "Pin_$ylw_led"
cmp add_assignment $top_name "" grn_led LOCATION "Pin_$grn_led"
puts "   Assigned: LED pins."

################################################
#### Make the Watchdog signal assignments
cmp add_assignment $top_name "" wdog LOCATION "Pin_$wdog"
puts "   Assigned: watchdog pin."

################################################
#### Make the Card ID signal assignments
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
#### Make the Micellaneous signal assignments
cmp add_assignment $top_name "" nextnd LOCATION "Pin_$nextnd"
cmp add_assignment $top_name "" n7v_ok LOCATION "Pin_$n7v_ok"

################################################
#### Make the spare TTL signal assignments
cmp add_assignment $top_name "" nrx3 LOCATION "Pin_$nrx3"
cmp add_assignment $top_name "" nrx2 LOCATION "Pin_$nrx2"
cmp add_assignment $top_name "" nrx1 LOCATION "Pin_$nrx1"
cmp add_assignment $top_name "" tx1 LOCATION "Pin_$tx1"
cmp add_assignment $top_name "" tx_en1 LOCATION "Pin_$tx_en1"
cmp add_assignment $top_name "" tx2 LOCATION "Pin_$tx2"
cmp add_assignment $top_name "" tx_en2 LOCATION "Pin_$tx_en2"
cmp add_assignment $top_name "" tx3 LOCATION "Pin_$tx3"
cmp add_assignment $top_name "" tx_en3 LOCATION "Pin_$tx_en3"

################################################
#### Make the SMB interface signal assignments
cmp add_assignment $top_name "" smb_clk LOCATION "Pin_$smb_clk"
cmp add_assignment $top_name "" smb_data LOCATION "Pin_$smb_data"
cmp add_assignment $top_name "" nalert LOCATION "Pin_$nalert"
puts "   Assigned: SMB interface pins."

################################################
#### Make the test header pin assignments
set i 0
foreach {a} $test_header {
   cmp add_assignment $top_name "" "test_header\[$i\]" LOCATION "Pin_$a"
   set i [expr $i+1] }
} 
puts "   Assigned: test header pins."

# recompile to commit
puts "\nInfo: Recompiling to commit assignments..."
execute_flow -compile

puts "\nInfo: Process completed."