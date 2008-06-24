onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider Dispatch
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_dispatch/dat_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_dispatch/addr_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_dispatch/tga_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_dispatch/we_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_dispatch/stb_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_dispatch/cyc_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_dispatch/dat_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_dispatch/ack_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_dispatch/clk_i
add wave -noupdate -color cyan -format Logic -itemcolor cyan /tb_cc_rcs_bcs_ac/i_readout_card1/i_dispatch/err_i
add wave -noupdate -divider {bias card dispatch}
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_bias_card1/cmd0/dat_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_bias_card1/cmd0/addr_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_bias_card1/cmd0/tga_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_bias_card1/cmd0/we_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_bias_card1/cmd0/stb_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_bias_card1/cmd0/cyc_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_bias_card1/cmd0/dat_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_bias_card1/cmd0/ack_i
add wave -noupdate -color cyan -format Logic -itemcolor cyan -radix hexadecimal /tb_cc_rcs_bcs_ac/i_bias_card1/cmd0/err_i
add wave -noupdate -divider fibre_tx
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply_block/i_fibre_tx/clk_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply_block/i_fibre_tx/dat_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply_block/i_fibre_tx/rdy_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply_block/i_fibre_tx/busy_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply_block/i_fibre_tx/fibre_clk_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply_block/i_fibre_tx/fibre_data_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply_block/i_fibre_tx/fibre_nena_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply_block/i_fibre_tx/pres_state
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply_block/i_fibre_tx/next_state
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply_block/i_fibre_tx/fifo_rd_dat
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply_block/i_fibre_tx/fifo_rd_empty
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply_block/i_fibre_tx/fifo_rd_req
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {146574437 ps} 0}
configure wave -namecolwidth 416
configure wave -valuecolwidth 51
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
update
WaveRestoreZoom {146488956 ps} {146821002 ps}
