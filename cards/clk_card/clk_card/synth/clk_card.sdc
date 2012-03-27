## Generated SDC file "clk_card.out.sdc"

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

## DATE    "Wed Feb 15 11:14:20 2012"

##
## DEVICE  "EP1S30F780C5"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {inclk15} -period 40.000 -waveform { 0.000 20.000 } [get_ports {inclk15}]
create_clock -name {inclk14} -period 40.000 -waveform { 0.000 20.000 } [get_ports {inclk14}]
create_clock -name {inclk1} -period 40.000 -waveform { 0.000 20.000 } [get_ports {inclk1}]
create_clock -name {fibre_rx_clkr} -period 40.000 -waveform { 0.000 20.000 } [get_ports {fibre_rx_clkr}]

derive_pll_clocks

#**************************************************************
# Create Generated Clock
#**************************************************************

#create_generated_clock -name {clk_switchover:clk_switchover_slave|cc_pll:pll0|altpll:altpll_component|_clk0~1} -source [get_pins {clk_switchover_slave|pll0|altpll_component|pll|inclk[1]}] -duty_cycle 50.000 -multiply_by 2 -master_clock {inclk15} [get_pins {clk_switchover_slave|pll0|altpll_component|pll|clk[0]}] -add
#create_generated_clock -name {clk_switchover:clk_switchover_slave|cc_pll:pll0|altpll:altpll_component|_clk0} -source [get_pins {clk_switchover_slave|pll0|altpll_component|pll|inclk[0]}] -duty_cycle 50.000 -multiply_by 2 -master_clock {inclk14} [get_pins {clk_switchover_slave|pll0|altpll_component|pll|clk[0]}] -add
#create_generated_clock -name {clk_switchover:clk_switchover_slave|cc_pll:pll0|altpll:altpll_component|_clk1~1} -source [get_pins {clk_switchover_slave|pll0|altpll_component|pll|inclk[1]}] -duty_cycle 50.000 -multiply_by 2 -phase 180.000 -master_clock {inclk15} [get_pins {clk_switchover_slave|pll0|altpll_component|pll|clk[1]}] -add
#create_generated_clock -name {clk_switchover:clk_switchover_slave|cc_pll:pll0|altpll:altpll_component|_clk1} -source [get_pins {clk_switchover_slave|pll0|altpll_component|pll|inclk[0]}] -duty_cycle 50.000 -multiply_by 2 -phase 180.000 -master_clock {inclk14} [get_pins {clk_switchover_slave|pll0|altpll_component|pll|clk[1]}] -add
#create_generated_clock -name {clk_switchover:clk_switchover_slave|cc_pll:pll0|altpll:altpll_component|_clk2~1} -source [get_pins {clk_switchover_slave|pll0|altpll_component|pll|inclk[1]}] -duty_cycle 50.000 -multiply_by 4 -master_clock {inclk15} [get_pins {clk_switchover_slave|pll0|altpll_component|pll|clk[2]}] -add
#create_generated_clock -name {clk_switchover:clk_switchover_slave|cc_pll:pll0|altpll:altpll_component|_clk2} -source [get_pins {clk_switchover_slave|pll0|altpll_component|pll|inclk[0]}] -duty_cycle 50.000 -multiply_by 4 -master_clock {inclk14} [get_pins {clk_switchover_slave|pll0|altpll_component|pll|clk[2]}] -add
#create_generated_clock -name {clk_switchover:clk_switchover_slave|cc_pll:pll0|altpll:altpll_component|_clk3~1} -source [get_pins {clk_switchover_slave|pll0|altpll_component|pll|inclk[1]}] -duty_cycle 50.000 -multiply_by 1 -master_clock {inclk15} [get_pins {clk_switchover_slave|pll0|altpll_component|pll|clk[3]}] -add
#create_generated_clock -name {clk_switchover:clk_switchover_slave|cc_pll:pll0|altpll:altpll_component|_clk3} -source [get_pins {clk_switchover_slave|pll0|altpll_component|pll|inclk[0]}] -duty_cycle 50.000 -multiply_by 1 -master_clock {inclk14} [get_pins {clk_switchover_slave|pll0|altpll_component|pll|clk[3]}] -add
#create_generated_clock -name {clk_switchover:clk_switchover_slave|cc_pll:pll0|altpll:altpll_component|_extclk0~1} -source [get_pins {clk_switchover_slave|pll0|altpll_component|pll|inclk[1]}] -duty_cycle 50.000 -multiply_by 1 -phase 180.000 -master_clock {inclk15} [get_pins {clk_switchover_slave|pll0|altpll_component|pll|extclk[0]}] -add
#create_generated_clock -name {clk_switchover:clk_switchover_slave|cc_pll:pll0|altpll:altpll_component|_extclk0} -source [get_pins {clk_switchover_slave|pll0|altpll_component|pll|inclk[0]}] -duty_cycle 50.000 -multiply_by 1 -phase 180.000 -master_clock {inclk14} [get_pins {clk_switchover_slave|pll0|altpll_component|pll|extclk[0]}] -add
#create_generated_clock -name {clk_switchover:clk_switchover_slave|cc_pll:pll0|altpll:altpll_component|_extclk1~1} -source [get_pins {clk_switchover_slave|pll0|altpll_component|pll|inclk[1]}] -duty_cycle 50.000 -multiply_by 1 -master_clock {inclk15} [get_pins {clk_switchover_slave|pll0|altpll_component|pll|extclk[1]}] -add
#create_generated_clock -name {clk_switchover:clk_switchover_slave|cc_pll:pll0|altpll:altpll_component|_extclk1} -source [get_pins {clk_switchover_slave|pll0|altpll_component|pll|inclk[0]}] -duty_cycle 50.000 -multiply_by 1 -master_clock {inclk14} [get_pins {clk_switchover_slave|pll0|altpll_component|pll|extclk[1]}] -add
#create_generated_clock -name {clk_switchover:clk_switchover_slave|cc_pll:pll0|altpll:altpll_component|_extclk2~1} -source [get_pins {clk_switchover_slave|pll0|altpll_component|pll|inclk[1]}] -duty_cycle 50.000 -multiply_by 1 -master_clock {inclk15} [get_pins {clk_switchover_slave|pll0|altpll_component|pll|extclk[2]}] -add
#create_generated_clock -name {clk_switchover:clk_switchover_slave|cc_pll:pll0|altpll:altpll_component|_extclk2} -source [get_pins {clk_switchover_slave|pll0|altpll_component|pll|inclk[0]}] -duty_cycle 50.000 -multiply_by 1 -master_clock {inclk14} [get_pins {clk_switchover_slave|pll0|altpll_component|pll|extclk[2]}] -add
#create_generated_clock -name {manch_pll:manch_pll_block|altpll:altpll_component|_clk0} -source [get_pins {manch_pll_block|altpll_component|pll|inclk[0]}] -duty_cycle 50.000 -multiply_by 1 -phase -7.500 -master_clock {inclk1} [get_pins {manch_pll_block|altpll_component|pll|clk[0]}] 


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

# The following false paths are recommended by DCFIFO Constraint settings
set_false_path -from [get_keepers {*write_delay_cycle*}] -to [get_keepers {*dffpipe_rs_dgwp|dffpipe_hd9:dffpipe9|dffe10a*}]
set_false_path -from [get_keepers {*write_delay_cycle*}] -to [get_keepers {*dffpipe_rs_dgwp|dffpipe_gd9:dffpipe9|dffe10a*}]

# The following paths are Clock-Domain Crossing and the intermediate meta-stable signal of the inter-synchrnozier block
set_false_path -from [get_keepers {dv_rx:dv_rx_slave|current_m_state.DONE}] -to [get_keepers {dv_rx:dv_rx_slave|manch_rdy_dly1}]
set_false_path -from [get_keepers {dv_rx:dv_rx_slave|manch_reg[26]}] -to [get_keepers {dv_rx:dv_rx_slave|manch_reg_dly1[26]}]
set_false_path -from [get_keepers {dv_rx:dv_rx_slave|manch_reg[17]}] -to [get_keepers {dv_rx:dv_rx_slave|manch_reg_dly1[17]}]
set_false_path -from [get_keepers {dv_rx:dv_rx_slave|manch_reg[18]}] -to [get_keepers {dv_rx:dv_rx_slave|manch_reg_dly1[18]}]
set_false_path -from [get_keepers {dv_rx:dv_rx_slave|manch_reg[14]}] -to [get_keepers {dv_rx:dv_rx_slave|manch_reg_dly1[14]}]
set_false_path -from [get_keepers {dv_rx:dv_rx_slave|manch_reg[13]}] -to [get_keepers {dv_rx:dv_rx_slave|manch_reg_dly1[13]}]
set_false_path -from [get_keepers {dv_rx:dv_rx_slave|manch_reg[36]}] -to [get_keepers {dv_rx:dv_rx_slave|manch_reg_dly1[36]}]
set_false_path -from [get_keepers {dv_rx:dv_rx_slave|manch_reg[27]}] -to [get_keepers {dv_rx:dv_rx_slave|manch_reg_dly1[27]}]
set_false_path -from [get_keepers {dv_rx:dv_rx_slave|manch_reg[23]}] -to [get_keepers {dv_rx:dv_rx_slave|manch_reg_dly1[23]}]
set_false_path -from [get_keepers {dv_rx:dv_rx_slave|manch_reg[8]}] -to [get_keepers {dv_rx:dv_rx_slave|manch_reg_dly1[8]}]
set_false_path -from [get_keepers {dv_rx:dv_rx_slave|manch_reg[10]}] -to [get_keepers {dv_rx:dv_rx_slave|manch_reg_dly1[10]}]
set_false_path -from [get_keepers {dv_rx:dv_rx_slave|manch_reg[28]}] -to [get_keepers {dv_rx:dv_rx_slave|manch_reg_dly1[28]}]
set_false_path -from [get_keepers {dv_rx:dv_rx_slave|manch_reg[31]}] -to [get_keepers {dv_rx:dv_rx_slave|manch_reg_dly1[31]}]
set_false_path -from [get_keepers {dv_rx:dv_rx_slave|manch_reg[7]}] -to [get_keepers {dv_rx:dv_rx_slave|manch_reg_dly1[7]}]
set_false_path -from [get_keepers {dv_rx:dv_rx_slave|manch_reg[20]}] -to [get_keepers {dv_rx:dv_rx_slave|manch_reg_dly1[20]}]
set_false_path -from [get_keepers {dv_rx:dv_rx_slave|manch_reg[22]}] -to [get_keepers {dv_rx:dv_rx_slave|manch_reg_dly1[22]}]
set_false_path -from [get_keepers {dv_rx:dv_rx_slave|manch_reg[3]}] -to [get_keepers {dv_rx:dv_rx_slave|manch_reg_dly1[3]}]
set_false_path -from [get_keepers {dv_rx:dv_rx_slave|manch_reg[11]}] -to [get_keepers {dv_rx:dv_rx_slave|manch_reg_dly1[11]}]
set_false_path -from [get_keepers {dv_rx:dv_rx_slave|manch_reg[29]}] -to [get_keepers {dv_rx:dv_rx_slave|manch_reg_dly1[29]}]
set_false_path -from [get_keepers {dv_rx:dv_rx_slave|manch_reg[15]}] -to [get_keepers {dv_rx:dv_rx_slave|manch_reg_dly1[15]}]
set_false_path -from [get_keepers {dv_rx:dv_rx_slave|manch_reg[25]}] -to [get_keepers {dv_rx:dv_rx_slave|manch_reg_dly1[25]}]
set_false_path -from [get_keepers {dv_rx:dv_rx_slave|manch_reg[6]}] -to [get_keepers {dv_rx:dv_rx_slave|manch_reg_dly1[6]}]
set_false_path -from [get_keepers {dv_rx:dv_rx_slave|manch_reg[4]}] -to [get_keepers {dv_rx:dv_rx_slave|manch_reg_dly1[4]}]
set_false_path -from [get_keepers {dv_rx:dv_rx_slave|manch_reg[12]}] -to [get_keepers {dv_rx:dv_rx_slave|manch_reg_dly1[12]}]
set_false_path -from [get_keepers {dv_rx:dv_rx_slave|manch_reg[2]}] -to [get_keepers {dv_rx:dv_rx_slave|manch_reg_dly1[2]}]
set_false_path -from [get_keepers {dv_rx:dv_rx_slave|manch_reg[5]}] -to [get_keepers {dv_rx:dv_rx_slave|manch_reg_dly1[5]}]
set_false_path -from [get_keepers {dv_rx:dv_rx_slave|manch_reg[1]}] -to [get_keepers {dv_rx:dv_rx_slave|manch_reg_dly1[1]}]
set_false_path -from [get_keepers {dv_rx:dv_rx_slave|manch_reg[30]}] -to [get_keepers {dv_rx:dv_rx_slave|manch_reg_dly1[30]}]
set_false_path -from [get_keepers {dv_rx:dv_rx_slave|manch_reg[16]}] -to [get_keepers {dv_rx:dv_rx_slave|manch_reg_dly1[16]}]
set_false_path -from [get_keepers {dv_rx:dv_rx_slave|manch_reg[9]}] -to [get_keepers {dv_rx:dv_rx_slave|manch_reg_dly1[9]}]
set_false_path -from [get_keepers {dv_rx:dv_rx_slave|manch_reg[38]}] -to [get_keepers {dv_rx:dv_rx_slave|manch_reg_dly1[38]}]
set_false_path -from [get_keepers {dv_rx:dv_rx_slave|manch_reg[19]}] -to [get_keepers {dv_rx:dv_rx_slave|manch_reg_dly1[19]}]
set_false_path -from [get_keepers {dv_rx:dv_rx_slave|manch_reg[24]}] -to [get_keepers {dv_rx:dv_rx_slave|manch_reg_dly1[24]}]
set_false_path -from [get_keepers {dv_rx:dv_rx_slave|manch_reg[0]}] -to [get_keepers {dv_rx:dv_rx_slave|manch_reg_dly1[0]}]
set_false_path -from [get_keepers {dv_rx:dv_rx_slave|manch_reg[21]}] -to [get_keepers {dv_rx:dv_rx_slave|manch_reg_dly1[21]}]


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

