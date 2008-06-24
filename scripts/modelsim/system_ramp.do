onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/rst_i
add wave -noupdate -format Logic -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/clk_50_i
add wave -noupdate -format Logic -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/restart_frame_aligned_i
add wave -noupdate -format Logic -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/restart_frame_1row_post_i
add wave -noupdate -format Logic -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/row_switch_i
add wave -noupdate -format Logic -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/initialize_window_i
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/num_rows_sub1_i
add wave -noupdate -format Literal -radix unsigned /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/servo_mode_i
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/ramp_step_size_i
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/ramp_amp_i
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/const_val_i
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/num_ramp_frame_cycles_i
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/fsfb_ws_addr_i
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/fsfb_ws_dat_o
add wave -noupdate -format Logic -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/fsfb_ctrl_dat_rdy_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/fsfb_ctrl_dat_o
add wave -noupdate -format Logic -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/fsfb_proc_update_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/fsfb_proc_dat_o
add wave -noupdate -format Logic -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/previous_fsfb_dat_rdy_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/previous_fsfb_dat_o
add wave -noupdate -format Logic -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/ramp_update_new_o
add wave -noupdate -color Salmon -format Logic -itemcolor Salmon -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/initialize_window_ext_o
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/fsfb_queue_wr_data_o
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/fsfb_queue_wr_addr_o
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/fsfb_queue_rd_addra_o
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/fsfb_queue_rd_addrb_o
add wave -noupdate -format Logic -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/fsfb_queue_wr_en_bank0_o
add wave -noupdate -format Logic -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/fsfb_queue_wr_en_bank1_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/fsfb_queue_rd_dataa_bank0_i
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/fsfb_queue_rd_dataa_bank1_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/fsfb_queue_rd_datab_bank0_i
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/fsfb_queue_rd_datab_bank1_i
add wave -noupdate -divider fsfb_proc_ramp
add wave -noupdate -format Logic -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/i_fsfb_processor/i_fsfb_proc_ramp/previous_fsfb_dat_rdy_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/i_fsfb_processor/i_fsfb_proc_ramp/previous_fsfb_dat_i
add wave -noupdate -format Logic -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/i_fsfb_processor/i_fsfb_proc_ramp/ramp_mode_en_i
add wave -noupdate -format Logic -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/restart_frame_aligned_i
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/i_fsfb_processor/i_fsfb_proc_ramp/ramp_step_size_i
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/i_fsfb_processor/i_fsfb_proc_ramp/ramp_amp_i
add wave -noupdate -format Logic -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/i_fsfb_processor/i_fsfb_proc_ramp/fsfb_proc_ramp_update_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/i_fsfb_processor/i_fsfb_proc_ramp/fsfb_proc_ramp_dat_o
add wave -noupdate -color {Cornflower Blue} -format Logic -itemcolor {Sky Blue} -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/i_fsfb_processor/i_fsfb_proc_ramp/add_sub_n
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/i_fsfb_processor/i_fsfb_proc_ramp/add_sub_result
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/i_fsfb_processor/i_fsfb_proc_ramp/result_reg
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/i_fsfb_processor/i_fsfb_proc_ramp/ramp_dat
add wave -noupdate -format Logic -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/i_fsfb_processor/i_fsfb_proc_ramp/pre_fsfb_dat_rdy_1d
add wave -noupdate -format Logic -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/i_fsfb_processor/i_fsfb_proc_ramp/pre_fsfb_dat_rdy_2d
add wave -noupdate -format Logic -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/i_fsfb_processor/i_fsfb_proc_ramp/ramp_update
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/dac_dat_ch0_o
add wave -noupdate -format Literal -radix unsigned /tb_cc_rcs_bcs_ac/i_readout_card1/dac_fb1_dat
add wave -noupdate -color cyan -format Literal -itemcolor cyan -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/i_fsfb_processor/i_fsfb_proc_ramp/ramp_upper_limit
add wave -noupdate -divider Processor
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/i_fsfb_processor/ramp_update_new_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/i_fsfb_processor/previous_fsfb_dat_rdy_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/i_fsfb_processor/previous_fsfb_dat_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/i_fsfb_processor/fsfb_proc_update_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/i_fsfb_processor/fsfb_proc_dat_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/i_fsfb_processor/ramp_update
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/i_fsfb_processor/ramp_update_1d
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/i_fsfb_processor/ramp_dat
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/i_fsfb_processor/ramp_dat_ltch
add wave -noupdate -divider upper_limit_adder
add wave -noupdate -format Logic -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/i_fsfb_processor/i_fsfb_proc_ramp/i_adder/add_sub
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/i_fsfb_processor/i_fsfb_proc_ramp/i_adder/dataa
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/i_fsfb_processor/i_fsfb_proc_ramp/i_adder/datab
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/i_fsfb_processor/i_fsfb_proc_ramp/i_adder/result
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/i_fsfb_processor/i_fsfb_proc_ramp/i_adder/sub_wire0
add wave -noupdate -divider fsfb_corr
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/fsfb_ctrl_lock_en0_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/fsfb_ctrl_dat0_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/fsfb_ctrl_dat_rdy0_i
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/fsfb_ctrl_dat0_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/start_corr
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/rdy_clr
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/pid_prev_reg0
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/fsfb_ctrl_dat_rdy0
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/res_a_reg0
add wave -noupdate -divider fsfb_ctrl
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_ctrl/clk_50_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_ctrl/rst_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_ctrl/dac_dat_en_i
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_ctrl/fsfb_ctrl_dat_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_ctrl/dac_dat_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_ctrl/fsfb_ctrl_dat_rdy_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_ctrl/fsfb_ctrl_lock_en_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_ctrl/dac_clk_o
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_ctrl/fsfb_ctrl_dat
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_ctrl/dac_dat
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_ctrl/fsfb_ctrl_dat_mapped
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_ctrl/latch_dac_dat
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_ctrl/rdy_to_clk_dac
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_ctrl/dac_clk
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_ctrl/wakeup
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_ctrl/wakeup_dac_clk
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/dispatch_dat_out
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/dispatch_addr_out
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/dispatch_tga_out
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/dispatch_we_out
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/dispatch_stb_out
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/dispatch_cyc_out
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/dispatch_err_in
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/dispatch_lvds_txa
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/dispatch_dat_in
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/dispatch_ack_in
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/all_cards_data
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/all_cards_ack
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/all_cards_err
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2478536500 ps} 0}
configure wave -namecolwidth 349
configure wave -valuecolwidth 59
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
WaveRestoreZoom {0 ps} {1079483999 ps}
