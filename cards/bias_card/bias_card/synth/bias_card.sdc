## Generated SDC file "bias_card.out.sdc"

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

## DATE    "Mon Mar 26 11:46:33 2012"

##
## DEVICE  "EP1S10F780C5"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {inclk} -period 40.000 -waveform { 0.000 20.000 } [get_ports {inclk}]


#**************************************************************
# Create Generated Clock
#**************************************************************

create_generated_clock -name {pll0|altpll_component|pll|clk[0]} -source [get_pins {pll0|altpll_component|pll|inclk[0]}] -duty_cycle 50.000 -multiply_by 2 -master_clock {inclk} [get_pins {pll0|altpll_component|pll|clk[0]}] 
create_generated_clock -name {pll0|altpll_component|pll|clk[1]} -source [get_pins {pll0|altpll_component|pll|inclk[0]}] -duty_cycle 50.000 -multiply_by 4 -master_clock {inclk} [get_pins {pll0|altpll_component|pll|clk[1]}] 
create_generated_clock -name {pll0|altpll_component|pll|clk[2]} -source [get_pins {pll0|altpll_component|pll|inclk[0]}] -duty_cycle 50.000 -multiply_by 2 -phase 180.000 -master_clock {inclk} [get_pins {pll0|altpll_component|pll|clk[2]}] 
create_generated_clock -name {pll0|altpll_component|pll|clk[3]} -source [get_pins {pll0|altpll_component|pll|inclk[0]}] -duty_cycle 50.000 -multiply_by 1 -master_clock {inclk} [get_pins {pll0|altpll_component|pll|clk[3]}] 


#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************



#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



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

