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
set project_name dip_leds_test
set top_name dip_leds_test

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
