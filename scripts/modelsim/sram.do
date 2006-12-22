onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider SRAM
add wave -noupdate -format Literal -radix hexadecimal /tb_sram_ctrl/dut/addr_o
add wave -noupdate -format Literal -radix hexadecimal /tb_sram_ctrl/dut/data_bi
add wave -noupdate -format Logic -radix hexadecimal /tb_sram_ctrl/dut/n_we_o
add wave -noupdate -format Logic -radix hexadecimal /tb_sram_ctrl/dut/n_ble_o
add wave -noupdate -format Logic -radix hexadecimal /tb_sram_ctrl/dut/n_bhe_o
add wave -noupdate -format Logic -radix hexadecimal /tb_sram_ctrl/dut/n_oe_o
add wave -noupdate -format Logic -radix hexadecimal /tb_sram_ctrl/dut/n_ce1_o
add wave -noupdate -format Logic -radix hexadecimal /tb_sram_ctrl/dut/ce2_o
add wave -noupdate -divider Wishbone
add wave -noupdate -format Logic -radix hexadecimal /tb_sram_ctrl/dut/clk_i
add wave -noupdate -format Logic -radix hexadecimal /tb_sram_ctrl/dut/rst_i
add wave -noupdate -format Literal -radix hexadecimal /tb_sram_ctrl/dut/dat_i
add wave -noupdate -format Literal -radix hexadecimal /tb_sram_ctrl/dut/addr_i
add wave -noupdate -format Literal -radix hexadecimal /tb_sram_ctrl/dut/tga_i
add wave -noupdate -format Logic -radix hexadecimal /tb_sram_ctrl/dut/we_i
add wave -noupdate -format Logic -radix hexadecimal /tb_sram_ctrl/dut/stb_i
add wave -noupdate -format Logic -radix hexadecimal /tb_sram_ctrl/dut/cyc_i
add wave -noupdate -format Literal -radix unsigned /tb_sram_ctrl/dut/dat_o
add wave -noupdate -format Logic -radix hexadecimal /tb_sram_ctrl/dut/ack_o
add wave -noupdate -divider {Data and Addr Regs}
add wave -noupdate -format Literal -radix hexadecimal /tb_sram_ctrl/dut/base_addr
add wave -noupdate -format Logic -radix hexadecimal /tb_sram_ctrl/dut/base_addr_wren
add wave -noupdate -format Literal -radix unsigned /tb_sram_ctrl/dut/addr_reg
add wave -noupdate -format Logic -radix unsigned /tb_sram_ctrl/dut/sram_addr_wren
add wave -noupdate -color Yellow -format Literal -itemcolor Yellow -radix unsigned /tb_sram_ctrl/dut/sram_wdata
add wave -noupdate -format Logic -radix unsigned /tb_sram_ctrl/dut/sram_wdata_wren
add wave -noupdate -format Literal -radix unsigned /tb_sram_ctrl/dut/sram_rdata
add wave -noupdate -format Logic -radix unsigned /tb_sram_ctrl/dut/sram_rdata_wren
add wave -noupdate -format Literal /tb_sram_ctrl/dut/i_gen_ack/count
add wave -noupdate -divider <NULL>
add wave -noupdate -format Logic -radix hexadecimal /tb_sram_ctrl/dut/master_wait
add wave -noupdate -format Logic -radix hexadecimal /tb_sram_ctrl/dut/read_cmd
add wave -noupdate -format Logic -radix hexadecimal /tb_sram_ctrl/dut/write_cmd
add wave -noupdate -format Logic /tb_sram_ctrl/reset_window_done
add wave -noupdate -format Logic /tb_sram_ctrl/finish_write_base_addr
add wave -noupdate -format Logic /tb_sram_ctrl/finish_write_sram
add wave -noupdate -format Logic /tb_sram_ctrl/finish_read_base_addr
add wave -noupdate -format Logic /tb_sram_ctrl/finish_read_sram
add wave -noupdate -format Logic /tb_sram_ctrl/finish_tb1
add wave -noupdate -format Literal -radix hexadecimal /tb_sram_ctrl/dut/present_state
add wave -noupdate -format Literal -radix hexadecimal /tb_sram_ctrl/dut/next_state
add wave -noupdate -format Logic -radix hexadecimal /tb_sram_ctrl/dut/test_mode
add wave -noupdate -format Literal -radix hexadecimal /tb_sram_ctrl/dut/present_test_state
add wave -noupdate -format Literal -radix hexadecimal /tb_sram_ctrl/dut/next_test_state
add wave -noupdate -format Logic -radix hexadecimal /tb_sram_ctrl/dut/test_done
add wave -noupdate -format Literal -radix hexadecimal /tb_sram_ctrl/dut/test_step
add wave -noupdate -format Literal -radix hexadecimal /tb_sram_ctrl/dut/test_addr
add wave -noupdate -format Literal -radix hexadecimal /tb_sram_ctrl/dut/num_fault
add wave -noupdate -format Logic -radix hexadecimal /tb_sram_ctrl/dut/test_cmd
add wave -noupdate -format Literal /tb_sram_ctrl/addr_o
add wave -noupdate -format Literal /tb_sram_ctrl/data_bi
add wave -noupdate -format Logic /tb_sram_ctrl/n_ble_o
add wave -noupdate -format Logic /tb_sram_ctrl/n_bhe_o
add wave -noupdate -format Logic /tb_sram_ctrl/n_oe_o
add wave -noupdate -format Logic /tb_sram_ctrl/n_ce1_o
add wave -noupdate -format Logic /tb_sram_ctrl/ce2_o
add wave -noupdate -format Logic /tb_sram_ctrl/n_we_o
add wave -noupdate -format Logic /tb_sram_ctrl/clk_i
add wave -noupdate -format Logic /tb_sram_ctrl/rst_i
add wave -noupdate -format Literal /tb_sram_ctrl/dat_i
add wave -noupdate -format Literal /tb_sram_ctrl/addr_i
add wave -noupdate -format Literal /tb_sram_ctrl/tga_i
add wave -noupdate -format Logic /tb_sram_ctrl/we_i
add wave -noupdate -format Logic /tb_sram_ctrl/stb_i
add wave -noupdate -format Logic /tb_sram_ctrl/cyc_i
add wave -noupdate -format Literal /tb_sram_ctrl/dat_o
add wave -noupdate -format Logic /tb_sram_ctrl/ack_o
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3005 ns} 0}
configure wave -namecolwidth 226
configure wave -valuecolwidth 100
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
WaveRestoreZoom {2783 ns} {4332 ns}
