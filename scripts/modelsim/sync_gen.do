onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /tb_sync_gen/clk_i
add wave -noupdate -format Logic /tb_sync_gen/rst_i
add wave -noupdate -format Logic /tb_sync_gen/dv_i
add wave -noupdate -format Logic /tb_sync_gen/dv_en_i
add wave -noupdate -format Logic /tb_sync_gen/sync_o
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Literal -radix unsigned /tb_sync_gen/sync_num_o
add wave -noupdate -format Literal -radix unsigned /tb_sync_gen/clk_count_o
add wave -noupdate -format Literal -radix unsigned /tb_sync_gen/clk_error_o
add wave -noupdate -format Logic /tb_sync_gen/dut/clk_i
add wave -noupdate -format Logic /tb_sync_gen/dut/rst_i
add wave -noupdate -format Logic /tb_sync_gen/dut/dv_i
add wave -noupdate -format Logic /tb_sync_gen/dut/dv_en_i
add wave -noupdate -format Logic /tb_sync_gen/dut/sync_o
add wave -noupdate -format Literal -radix unsigned /tb_sync_gen/dut/sync_num_o
add wave -noupdate -format Literal /tb_sync_gen/dut/current_state
add wave -noupdate -format Literal /tb_sync_gen/dut/next_state
add wave -noupdate -format Logic /tb_sync_gen/dut/new_frame_period
add wave -noupdate -format Literal /tb_sync_gen/dut/clk_count
add wave -noupdate -format Literal /tb_sync_gen/dut/sync_count
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Logic /tb_sync_gen/dut2/clk_i
add wave -noupdate -format Logic /tb_sync_gen/dut2/sync_i
add wave -noupdate -format Logic /tb_sync_gen/dut2/frame_rst_i
add wave -noupdate -format Literal -radix unsigned /tb_sync_gen/dut2/clk_count_o
add wave -noupdate -format Literal -radix unsigned /tb_sync_gen/dut2/clk_error_o
add wave -noupdate -format Literal -radix unsigned /tb_sync_gen/dut2/clk_error
add wave -noupdate -format Logic /tb_sync_gen/dut2/counter_rst
add wave -noupdate -format Literal -radix unsigned /tb_sync_gen/dut2/count
add wave -noupdate -format Literal -radix unsigned /tb_sync_gen/dut2/count_int
add wave -noupdate -format Logic /tb_sync_gen/dut2/reg_rst
add wave -noupdate -format Logic /tb_sync_gen/dut2/wait_for_sync
add wave -noupdate -format Logic /tb_sync_gen/dut2/latch_error
add wave -noupdate -format Literal /tb_sync_gen/dut2/current_state
add wave -noupdate -format Literal /tb_sync_gen/dut2/next_state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {52520 ns} 0}
WaveRestoreZoom {52493 ns} {52589 ns}
configure wave -namecolwidth 213
configure wave -valuecolwidth 116
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
