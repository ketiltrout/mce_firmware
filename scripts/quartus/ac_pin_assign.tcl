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
# Revision 1.2  2004/04/14 19:22:01  jjacob
# added DAC buses, DAC clock signals and mictor and test headers
#
# Revision 1.1  2004/04/14 01:00:55  bburger
# new
#
# Revision 1.1  2004/04/13 19:43:26  bburger
# new
#
#
#
#
# You can run this script from Quartus by observing the following steps:
# 1. Place this TCL script in your project directory
# 2. Open your project
# 3. Go to the View Menu and Auxilary Windows -> TCL console
# 4. In the TCL console type:
#                        source pin_assign.tcl
# 5. The script will assign pins and return an "assignment made" message.
###############################################################################


################ Open a Project if one does not yet exist ####################
set project_name lvds_test
set top_name lvds_test

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

################################################
#### Set the pin location variables

#set up groups of pins with generic names

# mictor connector header (MSB in the left-most position, LSB in the right-most)
set mictor_od        {Y17 AE21 AF21 AG21 AH21 AF20 AH20 AG19 AH19 AE20 AG18 AF19 AE18 AE19 AD18}
set mictor_od_clk    AB17

set mictor_ed        {AE24 AE22 AD21 AF23 AF22 AG23 AG22 AH22 AF25 AH23 AG24 AH24 AG25 AH25 AG26 AH26}
set mictor_ed_clk    AD23


# test point header (MSB in the left-most position, LSB in the right-most)
set test_header      {AH8 AG9 AF10 AG8 AH9 AF8 AE11 AE9 AH10 AD8 AF11 AE10 AH11 AD10 AG11 AF9)

### LVDS receive pins
set lvds_clk AA27
set lvds_cmd V23
set lvds_sync AA28
set lvds_spr V24

### LVDS transmit pins
set lvds_txa V19
set lvds_txb V20

### DIP switch
set dip3 M2
set dip4 N1

### LEDs
set nfault_led V27
set status_led T24
set pow_ok_led T23

### Micellaneous
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

# DAC bus signals
# for the DACs, the leftmost pin on each line is the LSB (bit 0), the rightmost pin is MSB (bit 13)
# the first line corresponds to bus 0, the last line corresponds to bus 10
set bus_0_10 {N19 N20 L21 N21 N22 L23 N23 N24 H25 L25 L26 H27 L27 M27 
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

# bus_0 goes to the DACs for Rows 00, 02, 05, 07
#set bus_0         {M27 L27 H27 L26 L25 H25 N24 N23 L23 N22 N21 L21 N20 N19}
# bus_1 goes to the DACs for Rows 01, 03, 04, 06
#set bus_1         {M24 M23 L24 K28 K27 J28 J27 H28 J26 J25 H26 M22 L22 M21}
# bus_2 goes to the DACs for Rows 08, 10, 13, 15
#set bus_2         {H4  H3  G2  J3  H2  G1  J2  H1  K4  L7  M7  M6  L9  L10}
# bus_3 goes to the DACs for Rows 09, 11, 12, 14
#set bus_3         {C24 E21 A21 B21 C21 D21 C20 A19 B19 A18 C19 B18 D19 C18}
# bus_4 goes to the DACs for Rows 16, 18, 21, 23
#set bus_4         {B5  A4  A3  C5  B4  B3  C6  C4  D6  D7  D5  D10 F10  G7}
# bus_5 goes to the DACs for Rows 17, 19, 20, 22
#set bus_5         {A11 C11 B11 B10 C10 A9  B9  A8  C9  B8  C8  B6  D8  D9}
# bus_6 goes to the DACs for Rows... 
#set bus_6         {AF7 AF6 AE6 AD6 AG6 AE5 AG7 AG5 AF4 AG4 AG3 AH4 AH6 AH7}
# bus_7 goes to the DACs for Rows...
#set bus_7         {M10 M9  M8  N8  K3  K2  J1  L2  K1  N7  L1  M3  M4  N3}
# bus_8 goes to the DACs for Rows...
#set bus_8         {V6  V5  W4  W1  Y2  Y1  AA2 AA1 V8  AA3 U10 AA4 V9 V10}
# bus_9 goes to the DACs for Rows...
#set bus_9         {T7  T6  T4  T3  T1  T5  U5  U2  V2  V1  V3  W2  W3  V4}
# bus_10 goes to the DACs for Rows...
#set bus_10        {D22 E23 C22 D23 B22 A22 C23 A23 B23 B24 D24 A25 B25 B26}

# DAC clk signals
# The list of clock signals begins at clock 0, and ends with clock 40 (dark row)
set dac_clk_0_40 {N28 M20 N26 L20 M19  N25 L19 L28 K8 E19 
                  L8  D18 F19 K7  J18  J4  A7  E8  B7 D11
                  F8  C7  G10 A5  AB10 M5  AH5 N4  N5 AC8
                  N6  AE8 U8  U7  T8   T9  T10 U6  U9 V7
                  D20}

# set dac40_dark_clk    D20
# set dac39_clk         V7
# set dac38_clk         U9
# set dac37_clk         U6
# set dac36_clk         T10
# set dac35_clk         T9
# set dac34_clk         T8
# set dac33_clk         U7
# set dac32_clk         U8
# set dac31_clk         AE8
# set dac30_clk         N6
# set dac29_clk         AC8
# set dac28_clk         N5
# set dac27_clk         N4
# set dac26_clk         AH5
# set dac25_clk         M5
# set dac24_clk         AB10
# set dac23_clk         A5
# set dac22_clk         G10
# set dac21_clk         C7
# set dac20_clk         F8
# set dac19_clk         D11
# set dac18_clk         B7
# set dac17_clk         E8
# set dac16_clk         A7
# set dac15_clk         J4
# set dac14_clk         J18
# set dac13_clk         K7
# set dac12_clk         F19
# set dac11_clk         D18
# set dac10_clk         L8
# set dac9_clk          E19
# set dac8_clk          K8
# set dac7_clk          L28
# set dac6_clk          L19
# set dac5_clk          N25
# set dac4_clk          M19
# set dac3_clk          L20
# set dac2_clk          N26
# set dac1_clk          M20
# set dac0_clk          N28

################################################
#### Make the LVDS signal assignments
cmp add_assignment $top_name "" lvds_clk LOCATION "Pin_$lvds_clk"
cmp add_assignment $top_name "" lvds_cmd LOCATION "Pin_$lvds_cmd"
cmp add_assignment $top_name "" lvds_sync LOCATION "Pin_$lvds_sync"
cmp add_assignment $top_name "" lvds_spr LOCATION "Pin_$lvds_spr"
cmp add_assignment $top_name "" lvds_txa LOCATION "Pin_$lvds_txa"
cmp add_assignment $top_name "" lvds_txb LOCATION "Pin_$lvds_txb"

################################################
#### Make the DIP switch signal assignments
cmp add_assignment $top_name "" dip3 LOCATION "Pin_$dip3"
cmp add_assignment $top_name "" dip4 LOCATION "Pin_$dip4"

################################################
#### Make the LED signal assignments
cmp add_assignment $top_name "" nfault_led LOCATION "Pin_$nfault_led"
cmp add_assignment $top_name "" status_led LOCATION "Pin_$status_led"
cmp add_assignment $top_name "" pow_ok_led LOCATION "Pin_$pow_ok_led"

################################################
#### Make the Micellaneous signal assignments
cmp add_assignment $top_name "" nextnd LOCATION "Pin_$nextnd"
cmp add_assignment $top_name "" wdi LOCATION "Pin_$wdi"
cmp add_assignment $top_name "" n7v_ok LOCATION "Pin_$n7v_ok"
cmp add_assignment $top_name "" sil_id LOCATION "Pin_$sil_id"
cmp add_assignment $top_name "" nsid00 LOCATION "Pin_$nsid00"
cmp add_assignment $top_name "" nsid01 LOCATION "Pin_$nsid01"
cmp add_assignment $top_name "" nsid02 LOCATION "Pin_$nsid02"
cmp add_assignment $top_name "" nsid03 LOCATION "Pin_$nsid03"
cmp add_assignment $top_name "" nrx3 LOCATION "Pin_$nrx3"
cmp add_assignment $top_name "" nrx2 LOCATION "Pin_$nrx2"
cmp add_assignment $top_name "" nrx1 LOCATION "Pin_$nrx1"
cmp add_assignment $top_name "" tx1 LOCATION "Pin_$tx1"
cmp add_assignment $top_name "" tx_en1 LOCATION "Pin_$tx_en1"
cmp add_assignment $top_name "" tx2 LOCATION "Pin_$tx2"
cmp add_assignment $top_name "" tx_en2 LOCATION "Pin_$tx_en2"
cmp add_assignment $top_name "" tx3 LOCATION "Pin_$tx3"
cmp add_assignment $top_name "" tx_en3 LOCATION "Pin_$tx_en3"
cmp add_assignment $top_name "" smb_clk LOCATION "Pin_$smb_clk"
cmp add_assignment $top_name "" smb_data LOCATION "Pin_$smb_data"
cmp add_assignment $top_name "" nalert LOCATION "Pin_$nalert"

################################################
#### Make the DAC signal assignments
set i 0
foreach {a} $bus_0_10 {
   cmp add_assignment $top_name "" "bus_0_10\[$i\]" LOCATION "Pin_$a"
   set i [expr $i+1] }
   
set i 0
foreach {a} $dac_clk_0_40 {
   cmp add_assignment $top_name "" "dac_clk_0_40\[$i\]" LOCATION "Pin_$a"
   set i [expr $i+1] }