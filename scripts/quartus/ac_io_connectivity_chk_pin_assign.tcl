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
# $Log: ac_io_connectivity_chk_pin_assign.tcl,v $
# Revision 1.1  2004/04/16 00:27:45  jjacob
# new test
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
# 4. In the TCL console type: source pin_assign.tcl
# 5. The script will assign pins and return an "assignment made" message.
#
###############################################################################


###############################################################################
#
# Open a Project if one does not yet exist
#
###############################################################################

set project_name addr_card_io_connectivity_chk
set top_name addr_card_io_connectivity_chk

if { ![project exists ./$project_name] } {
	project create ./$project_name
}
project open ./$project_name

set cmp_settings_group $top_name
if { ![project cmp_exists $cmp_settings_group] } {
        project create_cmp $top_name
}
project set_active_cmp $top_name

cmp add_assignment $top_name "" "" DEVICE EP1S10F780C5

###############################################################################
#
# Set pin location variables
#
###############################################################################

#set up groups of pins with generic names


# for the DACs, the first pin in the group (left-most) is the MSB (bit 13), the last pin is LSB (bit 0)

# bus_0 goes to the DACs for Rows 00, 02, 05, 07
set bus_0         {M27 L27 H27 L26 L25 H25 N24 N23 L23 N22 N21 L21 N20 N19}

# bus_1 goes to the DACs for Rows 01, 03, 04, 06
set bus_1         {M24 M23 L24 K28 K27 J28 J27 H28 J26 J25 H26 M22 L22 M21}

# bus_2 goes to the DACs for Rows 08, 10, 13, 15
set bus_2         {H4  H3  G2  J3  H2  G1  J2  H1  K4  L7  M7  M6  L9  L10}

# bus_3 goes to the DACs for Rows 09, 11, 12, 14
set bus_3         {C24 E21 A21 B21 C21 D21 C20 A19 B19 A18 C19 B18 D19 C18}

# bus_4 goes to the DACs for Rows 16, 18, 21, 23
set bus_4         {B5  A4  A3  C5  B4  B3  C6  C4  D6  D7  D5  D10 F10  G7}

# bus_5 goes to the DACs for Rows 17, 19, 20, 22
set bus_5         {A11 C11 B11 B10 C10 A9  B9  A8  C9  B8  C8  B6  D8  D9}

# bus_6 goes to the DACs for Rows... 
set bus_6         {AF7 AF6 AE6 AD6 AG6 AE5 AG7 AG5 AF4 AG4 AG3 AH4 AH6 AH7}

# bus_7 goes to the DACs for Rows...
set bus_7         {M10 M9  M8  N8  K3  K2  J1  L2  K1  N7  L1  M3  M4  N3}

# bus_8 goes to the DACs for Rows...
set bus_8         {V6  V5  W4  W1  Y2  Y1  AA2 AA1 V8  AA3 U10 AA4 V9 V10}

# bus_9 goes to the DACs for Rows...
set bus_9         {T7  T6  T4  T3  T1  T5  U5  U2  V2  V1  V3  W2  W3  V4}

# bus_10 goes to the DACs for Rows...
set bus_10        {D22 E23 C22 D23 B22 A22 C23 A23 B23 B24 D24 A25 B25 B26}


# DAC clk signals
set dac40_dark_clk    D20

set dac39_clk         V7
set dac38_clk         U9
set dac37_clk         U6
set dac36_clk         T10
set dac35_clk         T9
set dac34_clk         T8
set dac33_clk         U7
set dac32_clk         U8
set dac31_clk         AE8
set dac30_clk         N6

set dac29_clk         AC8
set dac28_clk         N5
set dac27_clk         N4
set dac26_clk         AH5
set dac25_clk         M5
set dac24_clk         AB10
set dac23_clk         A5
set dac22_clk         G10
set dac21_clk         C7
set dac20_clk         F8

set dac19_clk         D11
set dac18_clk         B7
set dac17_clk         E8
set dac16_clk         A7
set dac15_clk         J4
set dac14_clk         J18
set dac13_clk         K7
set dac12_clk         F19
set dac11_clk         D18
set dac10_clk         L8

set dac9_clk          E19
set dac8_clk          K8
set dac7_clk          L28
set dac6_clk          L19
set dac5_clk          N25
set dac4_clk          M19
set dac3_clk          L20
set dac2_clk          N26
set dac1_clk          M20
set dac0_clk          N28

# mictor connector header (MSB in the left-most position, LSB in the right-most)
set mictor_od        {Y17 AE21 AF21 AG21 AH21 AF20 AH20 AG19 AH19 AE20 AG18 AF19 AE18 AE19 AD18}
set mictor_od_clk    AB17

set mictor_ed        {AE24 AE22 AD21 AF23 AF22 AG23 AG22 AH22 AF25 AH23 AG24 AH24 AG25 AH25 AG26 AH26}
set mictor_ed_clk    AD23


# test point header (MSB in the left-most position, LSB in the right-most)
set test_header      {AH8 AG9 AF10 AG8 AH9 AF8 AE11 AE9 AH10 AD8 AF11 AE10 AH11 AD10 AG11 AF9}

# LVDS transmit pins
set lvds_txa V19
set lvds_txb V20

# DIP switch
set dip3 M2
set dip4 N1

# LEDs
set nfault_led V27
set status_led T24
set pow_ok_led T23

# Micellaneous
set nextnd U27
set wdi T28
set n7v_ok T22
set sil_id T21
set nsid00 V25
set nsid01 V26
set nsid02 T25
set nsid03 T26
set nrx3 W28
set nrx2 U20
set nrx1 U19
set tx1 Y26
set tx_en1 Y25
set tx2 U21
set tx_en2 U22
set tx3 Y28
set tx_en3 Y27
set smb_clk U23
set smb_data W26
set nalert W25

#set test_o {bus_0 bus_1 bus_2 bus_3 bus_4 bus_5 bus_6 bus_7 bus_8 bus_9 bus_10 dac39_clk dac38_clk dac37_clk dac36_clk dac35_clk dac34_clk dac33_clk dac32_clk dac31_clk dac30_clk dac29_clk dac28_clk dac27_clk dac26_clk dac25_clk dac24_clk dac23_clk dac22_clk dac21_clk dac20_clk dac19_clk dac18_clk dac17_clk dac16_clk dac15_clk dac14_clk dac13_clk dac12_clk dac11_clk dac10_clk  dac9_clk  dac8_clk  dac7_clk  dac6_clk  dac5_clk dac4_clk  dac3_clk  dac2_clk  dac1_clk  dac0_clk mictor_od mictor_od_clk mictor_ed mictor_ed_clk test_header lvds_txa lvds_txb dip3 dip4 nfault_led status_led pow_ok_led nextnd wdi n7v_ok sil_id nsid00 nsid01 nsid02 nsid03 nrx3 nrx2 nrx1 tx1 tx_en1 tx2 tx_en2 tx3 tx_en3 smb_clk smb_data nalert}


set clk_i AA27


###############################################################################
#
# Make the signal assignments
#
###############################################################################

set i 0
foreach {a} $bus_0 {
	cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$a"
	set i [expr $i+1] }

foreach {a} $bus_1 {
	cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$a"
	set i [expr $i+1] }

foreach {a} $bus_2 {
	cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$a"
	set i [expr $i+1] }

foreach {a} $bus_3 {
	cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$a"
	set i [expr $i+1] }

foreach {a} $bus_4 {
	cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$a"
	set i [expr $i+1] }

foreach {a} $bus_5 {
	cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$a"
	set i [expr $i+1] }

foreach {a} $bus_6 {
	cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$a"
	set i [expr $i+1] }

foreach {a} $bus_7 {
	cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$a"
	set i [expr $i+1] }

foreach {a} $bus_8 {
	cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$a"
	set i [expr $i+1] }

foreach {a} $bus_9 {
	cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$a"
	set i [expr $i+1] }

foreach {a} $bus_10 {
	cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$a"
	set i [expr $i+1] }


cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$dac40_dark_clk"
set i [expr $i+1]

cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$dac39_clk"
set i [expr $i+1]
cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$dac38_clk"
set i [expr $i+1]
cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$dac37_clk"
set i [expr $i+1]
cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$dac36_clk"
set i [expr $i+1]
cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$dac35_clk"
set i [expr $i+1]
cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$dac34_clk"
set i [expr $i+1]
cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$dac33_clk"
set i [expr $i+1]
cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$dac32_clk"
set i [expr $i+1]
cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$dac31_clk"
set i [expr $i+1]
cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$dac30_clk"
set i [expr $i+1]

cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$dac29_clk"
set i [expr $i+1]
cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$dac28_clk"
set i [expr $i+1]
cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$dac27_clk"
set i [expr $i+1]
cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$dac26_clk"
set i [expr $i+1]
cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$dac25_clk"
set i [expr $i+1]
cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$dac24_clk"
set i [expr $i+1]
cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$dac23_clk"
set i [expr $i+1]
cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$dac22_clk"
set i [expr $i+1]
cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$dac21_clk"
set i [expr $i+1]
cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$dac20_clk" 
set i [expr $i+1]

cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$dac19_clk"
set i [expr $i+1]
cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$dac18_clk"
set i [expr $i+1]
cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$dac17_clk"
set i [expr $i+1]
cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$dac16_clk"
set i [expr $i+1]
cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$dac15_clk"
set i [expr $i+1]
cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$dac14_clk"
set i [expr $i+1]
cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$dac13_clk"
set i [expr $i+1]
cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$dac12_clk"
set i [expr $i+1]
cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$dac11_clk"
set i [expr $i+1]
cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$dac10_clk"
set i [expr $i+1]
cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$dac9_clk"
set i [expr $i+1]
cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$dac8_clk"
set i [expr $i+1]
cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$dac7_clk"
set i [expr $i+1]
cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$dac6_clk"
set i [expr $i+1]
cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$dac5_clk"
set i [expr $i+1]
cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$dac4_clk"
set i [expr $i+1]
cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$dac3_clk"
set i [expr $i+1]
cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$dac2_clk"
set i [expr $i+1]
cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$dac1_clk"
set i [expr $i+1]
cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$dac0_clk"

# mictor connector header (MSB in the left-most position, LSB in the right-most)
foreach {a} $mictor_od {
	cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$a"
	set i [expr $i+1] }

cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$mictor_od_clk"
set i [expr $i+1]

foreach {a} $mictor_ed {
	cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$a"
	set i [expr $i+1] }

cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$mictor_ed_clk"
set i [expr $i+1]

# test point header (MSB in the left-most position, LSB in the right-most)
foreach {a} $test_header {
	cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$a"
	set i [expr $i+1] }

# LVDS transmit pins
cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$lvds_txa"
set i [expr $i+1]
cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$lvds_txb"
set i [expr $i+1]

# DIP switch
cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$dip3"
set i [expr $i+1]
cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$dip4"
set i [expr $i+1]

# LEDs
cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$nfault_led"
set i [expr $i+1]
cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$status_led"
set i [expr $i+1]
cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$pow_ok_led"
set i [expr $i+1]

# Micellaneous
cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$nextnd"
set i [expr $i+1]
cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$wdi"
set i [expr $i+1]
cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$n7v_ok"
set i [expr $i+1]
cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$sil_id"
set i [expr $i+1]
cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$nsid00"
set i [expr $i+1]
cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$nsid01"
set i [expr $i+1]
cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$nsid02"
set i [expr $i+1]
cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$nsid03"
set i [expr $i+1]
cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$nrx3"
set i [expr $i+1]
cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$nrx2"
set i [expr $i+1]
cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$nrx1"
set i [expr $i+1]
cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$tx1"
set i [expr $i+1]
cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$tx_en1"
set i [expr $i+1]
cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$tx2"
set i [expr $i+1]
cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$tx_en2"
set i [expr $i+1]
cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$tx3"
set i [expr $i+1]
cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$tx_en3"
set i [expr $i+1]
cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$smb_clk" 
set i [expr $i+1]
cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$smb_data" 
set i [expr $i+1]
cmp add_assignment $top_name "" "test_o\[$i\]" LOCATION "Pin_$nalert"


cmp add_assignment $top_name "" clk_i LOCATION "Pin_$clk_i"