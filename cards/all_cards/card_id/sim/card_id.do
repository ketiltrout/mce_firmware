onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Literal /tb_card_id_top/dut/card_id_temp_addr
add wave -noupdate -format Literal /tb_card_id_top/dut/card_id_serial_num_addr
add wave -noupdate -format Logic /tb_card_id_top/dut/data_bi
add wave -noupdate -format Logic /tb_card_id_top/dut/clk_i
add wave -noupdate -format Logic /tb_card_id_top/dut/rst_i
add wave -noupdate -format Literal -radix hexadecimal /tb_card_id_top/dut/addr_i
add wave -noupdate -format Literal -radix hexadecimal /tb_card_id_top/dut/dat_i
add wave -noupdate -format Literal -radix hexadecimal /tb_card_id_top/dut/dat_o
add wave -noupdate -format Logic /tb_card_id_top/dut/we_i
add wave -noupdate -format Logic /tb_card_id_top/dut/stb_i
add wave -noupdate -format Logic /tb_card_id_top/dut/ack_o
add wave -noupdate -format Logic /tb_card_id_top/dut/cyc_i
add wave -noupdate -format Literal /tb_card_id_top/dut/present_state
add wave -noupdate -format Literal /tb_card_id_top/dut/next_state
add wave -noupdate -format Logic /tb_card_id_top/dut/init_start
add wave -noupdate -format Logic /tb_card_id_top/dut/write_cmd_start
add wave -noupdate -format Logic /tb_card_id_top/dut/read_serial_start
add wave -noupdate -format Logic /tb_card_id_top/dut/crc_check_start
add wave -noupdate -format Logic /tb_card_id_top/dut/init_done
add wave -noupdate -format Logic /tb_card_id_top/dut/write_cmd_done
add wave -noupdate -format Logic /tb_card_id_top/dut/read_serial_done
add wave -noupdate -format Logic /tb_card_id_top/dut/crc_check_done
add wave -noupdate -format Logic /tb_card_id_top/dut/card_id_wr_ready
add wave -noupdate -format Logic /tb_card_id_top/dut/card_id_rd_ready
add wave -noupdate -format Literal -radix hexadecimal /tb_card_id_top/dut/card_id_dat_i
add wave -noupdate -format Literal -radix hexadecimal /tb_card_id_top/dut/card_id_dat_o
add wave -noupdate -format Literal -radix hexadecimal /tb_card_id_top/dut/serial_num
add wave -noupdate -format Logic /tb_card_id_top/dut/crc_valid
add wave -noupdate -format Logic /tb_card_id_top/dut/no_connect
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {7484530 ns} 0}
WaveRestoreZoom {7484389 ns} {7484733 ns}
configure wave -namecolwidth 267
configure wave -valuecolwidth 67
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
