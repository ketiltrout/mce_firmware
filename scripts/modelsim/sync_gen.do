onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /tb_sync_gen/clk_i
add wave -noupdate -format Logic /tb_sync_gen/rst_i
add wave -noupdate -format Logic /tb_sync_gen/dv_i
add wave -noupdate -format Logic /tb_sync_gen/dv_en_i
add wave -noupdate -format Logic /tb_sync_gen/sync
add wave -noupdate -format Literal -radix unsigned /tb_sync_gen/sync_num_o
add wave -noupdate -format Logic /tb_sync_gen/init_window_req
add wave -noupdate -format Literal /tb_sync_gen/sample_num
add wave -noupdate -format Literal /tb_sync_gen/sample_delay
add wave -noupdate -format Literal /tb_sync_gen/feedback_delay
add wave -noupdate -format Logic /tb_sync_gen/dac_dat_en
add wave -noupdate -format Logic /tb_sync_gen/adc_coadd_en
add wave -noupdate -format Logic /tb_sync_gen/restart_frame_1row_prev
add wave -noupdate -format Logic /tb_sync_gen/restart_frame_aligned
add wave -noupdate -format Logic /tb_sync_gen/restart_frame_1row_post
add wave -noupdate -format Logic /tb_sync_gen/row_switch
add wave -noupdate -format Logic /tb_sync_gen/initialize_window
add wave -noupdate -divider sync_gen
add wave -noupdate -format Logic /tb_sync_gen/dut/clk_i
add wave -noupdate -format Logic /tb_sync_gen/dut/rst_i
add wave -noupdate -format Logic /tb_sync_gen/dut/dv_i
add wave -noupdate -format Logic /tb_sync_gen/dut/dv_en_i
add wave -noupdate -format Logic /tb_sync_gen/dut/sync_o
add wave -noupdate -format Literal /tb_sync_gen/dut/sync_num_o
add wave -noupdate -format Literal /tb_sync_gen/dut/current_state
add wave -noupdate -format Literal /tb_sync_gen/dut/next_state
add wave -noupdate -format Logic /tb_sync_gen/dut/new_frame_period
add wave -noupdate -format Literal /tb_sync_gen/dut/clk_count
add wave -noupdate -format Literal /tb_sync_gen/dut/sync_count
add wave -noupdate -format Literal /tb_sync_gen/dut/sync_num
add wave -noupdate -format Literal /tb_sync_gen/dut/sync_num_mux
add wave -noupdate -format Logic /tb_sync_gen/dut/sync_num_mux_sel
add wave -noupdate -divider frame_timing
add wave -noupdate -format Logic /tb_sync_gen/dut2/clk_i
add wave -noupdate -format Logic /tb_sync_gen/dut2/rst_i
add wave -noupdate -format Logic /tb_sync_gen/dut2/sync_i
add wave -noupdate -format Logic /tb_sync_gen/dut2/frame_rst_i
add wave -noupdate -format Logic /tb_sync_gen/dut2/init_window_req_i
add wave -noupdate -format Literal /tb_sync_gen/dut2/sample_num_i
add wave -noupdate -format Literal /tb_sync_gen/dut2/sample_delay_i
add wave -noupdate -format Literal /tb_sync_gen/dut2/feedback_delay_i
add wave -noupdate -format Logic /tb_sync_gen/dut2/update_bias_o
add wave -noupdate -format Logic /tb_sync_gen/dut2/dac_dat_en_o
add wave -noupdate -format Logic /tb_sync_gen/dut2/adc_coadd_en_o
add wave -noupdate -format Logic /tb_sync_gen/dut2/restart_frame_1row_prev_o
add wave -noupdate -format Logic /tb_sync_gen/dut2/restart_frame_aligned_o
add wave -noupdate -format Logic /tb_sync_gen/dut2/restart_frame_1row_post_o
add wave -noupdate -format Logic /tb_sync_gen/dut2/row_switch_o
add wave -noupdate -format Logic /tb_sync_gen/dut2/initialize_window_o
add wave -noupdate -format Literal /tb_sync_gen/dut2/clk_error
add wave -noupdate -format Logic /tb_sync_gen/dut2/counter_rst
add wave -noupdate -format Literal /tb_sync_gen/dut2/count
add wave -noupdate -format Literal /tb_sync_gen/dut2/frame_count_int
add wave -noupdate -format Literal /tb_sync_gen/dut2/row_count_int
add wave -noupdate -format Logic /tb_sync_gen/dut2/wait_for_sync
add wave -noupdate -format Logic /tb_sync_gen/dut2/latch_error
add wave -noupdate -format Logic /tb_sync_gen/dut2/restart_frame_aligned
add wave -noupdate -format Literal /tb_sync_gen/dut2/current_state
add wave -noupdate -format Literal /tb_sync_gen/dut2/next_state
add wave -noupdate -format Literal /tb_sync_gen/dut2/current_init_win_state
add wave -noupdate -format Literal /tb_sync_gen/dut2/next_init_win_state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {274238 ns} 0}
WaveRestoreZoom {234411 ns} {325497 ns}
configure wave -namecolwidth 241
configure wave -valuecolwidth 88
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
