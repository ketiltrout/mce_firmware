onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider Inputs
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_readout_card1/i_dispatch/transmitter/reply_tx/rst_i
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_readout_card1/i_dispatch/transmitter/reply_tx/clk_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_dispatch/transmitter/reply_tx/dat_i
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_readout_card1/i_dispatch/transmitter/reply_tx/rdy_i
add wave -noupdate -divider Outputs
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_readout_card1/i_dispatch/transmitter/reply_tx/lvds_o
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_readout_card1/i_dispatch/transmitter/reply_tx/busy_o
add wave -noupdate -divider Internal
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_readout_card1/i_dispatch/transmitter/reply_tx/buf_empty
add wave -noupdate -format Literal /tb_cc_rcs_bcs_ac/i_readout_card1/i_dispatch/transmitter/reply_tx/bit_count
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_dispatch/transmitter/reply_tx/buf_data
add wave -noupdate -format Literal /tb_cc_rcs_bcs_ac/i_readout_card1/i_dispatch/transmitter/reply_tx/pres_state
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_dispatch/transmitter/reply_tx/tx_data
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_readout_card1/i_dispatch/transmitter/reply_tx/tx_ena
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 5} {145200000 ps} 0} {{Cursor 6} {150900000 ps} 0}
configure wave -namecolwidth 138
configure wave -valuecolwidth 222
configure wave -justifyvalue left
configure wave -signalnamewidth 2
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
update
WaveRestoreZoom {300425 ns} {478925 ns}
