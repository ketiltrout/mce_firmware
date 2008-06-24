onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider LVDS_RX
add wave -noupdate -color Coral -format Logic /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/clk_50_i
add wave -noupdate -color Cyan -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_dispatch/receiver/cmd_rx/comm_clk_i
add wave -noupdate -color Salmon -format Logic /tb_cc_rcs_bcs_ac/i_readout_card1/lvds_cmd
add wave -noupdate -format Logic -radix unsigned /tb_cc_rcs_bcs_ac/i_readout_card1/i_dispatch/receiver/cmd_rx/lvds
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_dispatch/receiver/cmd_rx/dat_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_dispatch/receiver/cmd_rx/rx_bit
add wave -noupdate -color Orange -format Logic -radix unsigned /tb_cc_rcs_bcs_ac/i_readout_card1/i_dispatch/receiver/cmd_rx/rx_buf_ena
add wave -noupdate -format Logic -radix unsigned /tb_cc_rcs_bcs_ac/i_readout_card1/i_dispatch/receiver/cmd_rx/rx_buf_clr
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_dispatch/receiver/cmd_rx/rx_buf
add wave -noupdate -format Literal -radix hexadecimal -expand /tb_cc_rcs_bcs_ac/i_readout_card1/i_dispatch/receiver/cmd_rx/sample_buf
add wave -noupdate -format Logic -radix unsigned /tb_cc_rcs_bcs_ac/i_readout_card1/i_dispatch/receiver/cmd_rx/data_buf_write
add wave -noupdate -format Literal -radix unsigned /tb_cc_rcs_bcs_ac/i_readout_card1/i_dispatch/receiver/cmd_rx/sample_count
add wave -noupdate -format Logic -radix unsigned /tb_cc_rcs_bcs_ac/i_readout_card1/i_dispatch/receiver/cmd_rx/lvds_receiving
add wave -noupdate -divider LVDS_TX
add wave -noupdate -format Literal -radix unsigned /tb_cc_rcs_bcs_ac/i_readout_card1/i_dispatch/transmitter/reply_tx/bit_count
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_dispatch/transmitter/reply_tx/buf_data
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/cmd0/transmitter/reply_tx/tx_data
add wave -noupdate -format Logic -radix unsigned /tb_cc_rcs_bcs_ac/i_readout_card1/i_dispatch/transmitter/reply_tx/buf_empty
add wave -noupdate -format Logic -radix unsigned /tb_cc_rcs_bcs_ac/i_readout_card1/i_dispatch/transmitter/reply_tx/buf_full
add wave -noupdate -format Logic -radix unsigned /tb_cc_rcs_bcs_ac/i_readout_card1/i_dispatch/transmitter/reply_tx/clk_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_dispatch/transmitter/reply_tx/dat_i
add wave -noupdate -format Logic -radix binary /tb_cc_rcs_bcs_ac/i_clk_card/cmd0/transmitter/reply_tx/rdy_i
add wave -noupdate -format Logic -radix unsigned /tb_cc_rcs_bcs_ac/i_readout_card1/i_dispatch/transmitter/reply_tx/busy_o
add wave -noupdate -format Logic -radix unsigned /tb_cc_rcs_bcs_ac/i_readout_card1/i_dispatch/transmitter/reply_tx/lvds_o
add wave -noupdate -format Logic -radix unsigned /tb_cc_rcs_bcs_ac/i_readout_card1/i_dispatch/transmitter/reply_tx/tx_bit
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_clk_card/cmd0/transmitter/reply_tx/data_buffer/write_i
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_clk_card/cmd0/transmitter/lvds_tx_rdy
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_clk_card/cmd0/transmitter/lvds_tx_busy
add wave -noupdate -format Literal /tb_cc_rcs_bcs_ac/i_clk_card/cmd0/transmitter/reply_tx/pres_state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {144775222 ps} 0} {{Cursor 2} {4022000000 ps} 0} {{Cursor 3} {146239234 ps} 0} {{Cursor 4} {140612837 ps} 0}
configure wave -namecolwidth 181
configure wave -valuecolwidth 70
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
WaveRestoreZoom {140373619 ps} {153664547 ps}
