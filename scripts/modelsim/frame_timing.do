onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /tb_frame_timing/sync_i
add wave -noupdate -format Logic /tb_frame_timing/frame_rst_i
add wave -noupdate -format Literal /tb_frame_timing/clk_count_o
add wave -noupdate -format Literal -radix decimal /tb_frame_timing/clk_error_o
add wave -noupdate -format Logic /tb_frame_timing/clk_i
add wave -noupdate -format Logic /tb_frame_timing/dut/clk_i
add wave -noupdate -format Logic /tb_frame_timing/dut/sync_i
add wave -noupdate -format Logic /tb_frame_timing/dut/frame_rst_i
add wave -noupdate -format Literal /tb_frame_timing/dut/clk_count_o
add wave -noupdate -format Literal -radix decimal /tb_frame_timing/dut/clk_error_o
add wave -noupdate -format Literal -radix decimal /tb_frame_timing/dut/clk_error
add wave -noupdate -format Logic /tb_frame_timing/dut/counter_rst
add wave -noupdate -format Literal -radix decimal /tb_frame_timing/dut/count
add wave -noupdate -format Literal /tb_frame_timing/dut/count_int
add wave -noupdate -format Logic /tb_frame_timing/dut/reg_rst
add wave -noupdate -format Logic /tb_frame_timing/dut/wait_for_sync
add wave -noupdate -format Literal /tb_frame_timing/dut/current_state
add wave -noupdate -format Literal /tb_frame_timing/dut/next_state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {540 ns} 0}
WaveRestoreZoom {0 ns} {934 ns}
configure wave -namecolwidth 213
configure wave -valuecolwidth 217
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
