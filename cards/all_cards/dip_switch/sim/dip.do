onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Literal -radix hexadecimal /tb_dip_switch/dut/dip_switch_i
add wave -noupdate -format Logic /tb_dip_switch/dut/clk_i
add wave -noupdate -format Logic /tb_dip_switch/dut/rst_i
add wave -noupdate -format Literal -radix hexadecimal /tb_dip_switch/dut/dat_i
add wave -noupdate -format Literal -radix hexadecimal /tb_dip_switch/dut/addr_i
add wave -noupdate -format Logic /tb_dip_switch/dut/we_i
add wave -noupdate -format Logic /tb_dip_switch/dut/stb_i
add wave -noupdate -format Logic /tb_dip_switch/dut/cyc_i
add wave -noupdate -format Literal -radix hexadecimal /tb_dip_switch/dut/dat_o
add wave -noupdate -format Logic /tb_dip_switch/dut/ack_o
add wave -noupdate -format Literal -radix hexadecimal /tb_dip_switch/dut/dip_reg
add wave -noupdate -format Logic /tb_dip_switch/dut/dip_rd_valid
add wave -noupdate -format Logic /tb_dip_switch/dut/dip_wr_ready
add wave -noupdate -format Literal -radix hexadecimal /tb_dip_switch/dut/padded_dip_reg
add wave -noupdate -format Logic /tb_dip_switch/dut/dummy_wr_data_valid
add wave -noupdate -format Literal -radix hexadecimal /tb_dip_switch/dut/dummy_data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {151 ns} 0}
WaveRestoreZoom {0 ns} {210 ns}
configure wave -namecolwidth 253
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
