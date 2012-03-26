## Generated SDC file "readout_card.out.sdc"

## Copyright (C) 1991-2011 Altera Corporation
## Your use of Altera Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Altera Program License 
## Subscription Agreement, Altera MegaCore Function License 
## Agreement, or other applicable license agreement, including, 
## without limitation, that your use is for the sole purpose of 
## programming logic devices manufactured by Altera and sold by 
## Altera or its authorized distributors.  Please refer to the 
## applicable agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus II"
## VERSION "Version 11.1 Build 259 01/25/2012 Service Pack 2 SJ Full Version"

## DATE    "Wed Feb 22 11:20:17 2012"

##
## DEVICE  "EP1S40F780C7"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {inclk} -period 40.000 -waveform { 0.000 20.000 } [get_ports {inclk}]
create_clock -name {inclk_virt} -period 40.000 -waveform { 0.000 20.000 } 


#**************************************************************
# Create Generated Clock
#**************************************************************

create_generated_clock -name {rc_pll:i_rc_pll|altpll:altpll_component|_clk0} -source [get_pins {i_rc_pll|altpll_component|pll|inclk[0]}] -duty_cycle 50.000 -multiply_by 2 -master_clock {inclk} [get_pins {i_rc_pll|altpll_component|pll|clk[0]}] 
create_generated_clock -name {rc_pll:i_rc_pll|altpll:altpll_component|_clk2} -source [get_pins {i_rc_pll|altpll_component|pll|inclk[0]}] -duty_cycle 50.000 -multiply_by 4 -master_clock {inclk} [get_pins {i_rc_pll|altpll_component|pll|clk[2]}] 
create_generated_clock -name {rc_pll:i_rc_pll|altpll:altpll_component|_clk3} -source [get_pins {i_rc_pll|altpll_component|pll|inclk[0]}] -duty_cycle 50.000 -multiply_by 1 -divide_by 2 -master_clock {inclk} [get_pins {i_rc_pll|altpll_component|pll|clk[3]}] 
create_generated_clock -name {rc_pll:i_rc_pll|altpll:altpll_component|_clk4} -source [get_pins {i_rc_pll|altpll_component|pll|inclk[0]}] -duty_cycle 50.000 -multiply_by 2 -phase 180.000 -master_clock {inclk} [get_pins {i_rc_pll|altpll_component|pll|clk[4]}] 


#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************



#**************************************************************
# Set Input Delay
#**************************************************************

set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc1_dat[0]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc1_dat[0]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc1_dat[1]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc1_dat[1]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc1_dat[2]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc1_dat[2]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc1_dat[3]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc1_dat[3]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc1_dat[4]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc1_dat[4]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc1_dat[5]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc1_dat[5]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc1_dat[6]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc1_dat[6]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc1_dat[7]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc1_dat[7]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc1_dat[8]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc1_dat[8]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc1_dat[9]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc1_dat[9]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc1_dat[10]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc1_dat[10]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc1_dat[11]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc1_dat[11]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc1_dat[12]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc1_dat[12]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc1_dat[13]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc1_dat[13]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc2_dat[0]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc2_dat[0]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc2_dat[1]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc2_dat[1]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc2_dat[2]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc2_dat[2]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc2_dat[3]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc2_dat[3]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc2_dat[4]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc2_dat[4]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc2_dat[5]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc2_dat[5]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc2_dat[6]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc2_dat[6]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc2_dat[7]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc2_dat[7]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc2_dat[8]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc2_dat[8]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc2_dat[9]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc2_dat[9]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc2_dat[10]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc2_dat[10]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc2_dat[11]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc2_dat[11]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc2_dat[12]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc2_dat[12]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc2_dat[13]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc2_dat[13]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc3_dat[0]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc3_dat[0]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc3_dat[1]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc3_dat[1]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc3_dat[2]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc3_dat[2]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc3_dat[3]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc3_dat[3]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc3_dat[4]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc3_dat[4]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc3_dat[5]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc3_dat[5]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc3_dat[6]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc3_dat[6]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc3_dat[7]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc3_dat[7]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc3_dat[8]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc3_dat[8]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc3_dat[9]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc3_dat[9]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc3_dat[10]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc3_dat[10]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc3_dat[11]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc3_dat[11]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc3_dat[12]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc3_dat[12]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc3_dat[13]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc3_dat[13]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc4_dat[0]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc4_dat[0]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc4_dat[1]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc4_dat[1]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc4_dat[2]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc4_dat[2]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc4_dat[3]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc4_dat[3]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc4_dat[4]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc4_dat[4]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc4_dat[5]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc4_dat[5]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc4_dat[6]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc4_dat[6]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc4_dat[7]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc4_dat[7]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc4_dat[8]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc4_dat[8]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc4_dat[9]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc4_dat[9]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc4_dat[10]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc4_dat[10]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc4_dat[11]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc4_dat[11]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc4_dat[12]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc4_dat[12]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc4_dat[13]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc4_dat[13]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc5_dat[0]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc5_dat[0]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc5_dat[1]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc5_dat[1]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc5_dat[2]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc5_dat[2]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc5_dat[3]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc5_dat[3]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc5_dat[4]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc5_dat[4]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc5_dat[5]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc5_dat[5]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc5_dat[6]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc5_dat[6]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc5_dat[7]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc5_dat[7]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc5_dat[8]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc5_dat[8]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc5_dat[9]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc5_dat[9]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc5_dat[10]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc5_dat[10]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc5_dat[11]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc5_dat[11]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc5_dat[12]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc5_dat[12]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc5_dat[13]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc5_dat[13]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc6_dat[0]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc6_dat[0]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc6_dat[1]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc6_dat[1]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc6_dat[2]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc6_dat[2]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc6_dat[3]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc6_dat[3]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc6_dat[4]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc6_dat[4]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc6_dat[5]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc6_dat[5]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc6_dat[6]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc6_dat[6]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc6_dat[7]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc6_dat[7]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc6_dat[8]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc6_dat[8]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc6_dat[9]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc6_dat[9]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc6_dat[10]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc6_dat[10]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc6_dat[11]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc6_dat[11]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc6_dat[12]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc6_dat[12]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc6_dat[13]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc6_dat[13]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc7_dat[0]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc7_dat[0]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc7_dat[1]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc7_dat[1]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc7_dat[2]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc7_dat[2]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc7_dat[3]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc7_dat[3]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc7_dat[4]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc7_dat[4]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc7_dat[5]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc7_dat[5]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc7_dat[6]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc7_dat[6]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc7_dat[7]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc7_dat[7]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc7_dat[8]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc7_dat[8]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc7_dat[9]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc7_dat[9]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc7_dat[10]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc7_dat[10]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc7_dat[11]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc7_dat[11]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc7_dat[12]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc7_dat[12]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc7_dat[13]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc7_dat[13]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc8_dat[0]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc8_dat[0]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc8_dat[1]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc8_dat[1]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc8_dat[2]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc8_dat[2]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc8_dat[3]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc8_dat[3]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc8_dat[4]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc8_dat[4]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc8_dat[5]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc8_dat[5]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc8_dat[6]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc8_dat[6]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc8_dat[7]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc8_dat[7]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc8_dat[8]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc8_dat[8]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc8_dat[9]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc8_dat[9]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc8_dat[10]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc8_dat[10]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc8_dat[11]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc8_dat[11]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc8_dat[12]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc8_dat[12]}]
set_input_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  11.700 [get_ports {adc8_dat[13]}]
set_input_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  3.700 [get_ports {adc8_dat[13]}]


#**************************************************************
# Set Output Delay
#**************************************************************

set_output_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  0.000 [get_ports {adc1_clk}]
set_output_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  -3.700 [get_ports {adc1_clk}]
set_output_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  0.000 [get_ports {adc2_clk}]
set_output_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  -3.700 [get_ports {adc2_clk}]
set_output_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  0.000 [get_ports {adc3_clk}]
set_output_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  -3.700 [get_ports {adc3_clk}]
set_output_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  0.000 [get_ports {adc4_clk}]
set_output_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  -3.700 [get_ports {adc4_clk}]
set_output_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  0.000 [get_ports {adc5_clk}]
set_output_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  -3.700 [get_ports {adc5_clk}]
set_output_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  0.000 [get_ports {adc6_clk}]
set_output_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  -3.700 [get_ports {adc6_clk}]
set_output_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  0.000 [get_ports {adc7_clk}]
set_output_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  -3.700 [get_ports {adc7_clk}]
set_output_delay -add_delay -max -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  0.000 [get_ports {adc8_clk}]
set_output_delay -add_delay -min -clock [get_clocks {rc_pll:i_rc_pll|altpll:altpll_component|_clk0}]  -3.700 [get_ports {adc8_clk}]


#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

