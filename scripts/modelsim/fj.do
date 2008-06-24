onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_readout_card1/i_frame_timing/restart_frame_aligned_o
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_readout_card1/i_frame_timing/row_switch_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/flux_jumping_en_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/fsfb_ctrl_lock_en0_i
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/flux_quanta0_i
add wave -noupdate -color gold -format Literal -itemcolor gold -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/num_flux_quanta_prev0_i
add wave -noupdate -color gold -format Literal -itemcolor gold -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/num_flux_quanta_pres0_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/fsfb_ctrl_dat_rdy0_i
add wave -noupdate -color Salmon -format Literal -itemcolor Coral -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/fsfb_ctrl_dat0_i
add wave -noupdate -color Salmon -format Literal -itemcolor Coral -radix unsigned /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/fsfb_ctrl_dat0_o
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/fsfb_ctrl_dat7_o
add wave -noupdate -color cyan -format Logic -itemcolor cyan -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/fsfb_ctrl_dat_rdy_o
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/flux_quanta7_i
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/num_flux_quanta_prev7_i
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/fsfb_ctrl_dat7_i
add wave -noupdate -format Logic -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/fsfb_ctrl_dat_rdy7_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/clk_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/rst_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/start_corr
add wave -noupdate -color gold -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/rdy_clr
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/column_switch1
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/column_switch2
add wave -noupdate -format Logic -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/pid_corr_rdy
add wave -noupdate -format Logic -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/m_pres_rdy
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/flux_quanta1
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/flux_quanta2
add wave -noupdate -color salmon -format Literal -itemcolor coral -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/m_pres
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/m_pres0
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/pid_prev1
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/pid_prev2
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/mult_res1
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/mult_res2
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/mult_res1_xtnd
add wave -noupdate -color Salmon -format Literal -itemcolor Salmon -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/mult_res2_xtnd
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/sub_res1
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/sub_res2
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/flux_quanta_reg0
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/m_prev
add wave -noupdate -color Cyan -format Literal -itemcolor cyan -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/m_prev_reg0
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/pid_prev_reg0
add wave -noupdate -format Logic -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/fsfb_ctrl_dat_rdy0
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/res_a_reg0
add wave -noupdate -format Logic -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/res_a_en0
add wave -noupdate -color gold -format Literal -itemcolor gold -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/res_b_reg0
add wave -noupdate -format Logic -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/res_b_en0
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/res_b0
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/m_pres_reg0
add wave -noupdate -format Logic -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/m_pres_en0
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/present_state
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/next_state
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
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_readout_card1/i_dispatch/err_i
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
WaveRestoreCursors {{Cursor 1} {1855885158 ps} 0}
configure wave -namecolwidth 449
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
WaveRestoreZoom {1852691253 ps} {1862967294 ps}
