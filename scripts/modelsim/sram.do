onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider SRAM
add wave -noupdate -format Literal -radix hexadecimal /tb_sram_ctrl/dut/addr_o
add wave -noupdate -format Literal -radix hexadecimal /tb_sram_ctrl/dut/data_bi
add wave -noupdate -format Logic -radix hexadecimal /tb_sram_ctrl/dut/n_ble_o
add wave -noupdate -format Logic -radix hexadecimal /tb_sram_ctrl/dut/n_bhe_o
add wave -noupdate -format Logic -radix hexadecimal /tb_sram_ctrl/dut/n_oe_o
add wave -noupdate -format Logic -radix hexadecimal /tb_sram_ctrl/dut/n_ce1_o
add wave -noupdate -format Logic -radix hexadecimal /tb_sram_ctrl/dut/ce2_o
add wave -noupdate -format Logic -radix hexadecimal /tb_sram_ctrl/dut/n_we_o
add wave -noupdate -divider Wishbone
add wave -noupdate -format Logic -radix hexadecimal /tb_sram_ctrl/dut/clk_i
add wave -noupdate -format Logic -radix hexadecimal /tb_sram_ctrl/dut/rst_i
add wave -noupdate -format Literal -radix hexadecimal /tb_sram_ctrl/dut/dat_i
add wave -noupdate -format Literal -radix hexadecimal /tb_sram_ctrl/dut/addr_i
add wave -noupdate -format Literal -radix hexadecimal /tb_sram_ctrl/dut/tga_i
add wave -noupdate -format Logic -radix hexadecimal /tb_sram_ctrl/dut/we_i
add wave -noupdate -format Logic -radix hexadecimal /tb_sram_ctrl/dut/stb_i
add wave -noupdate -format Logic -radix hexadecimal /tb_sram_ctrl/dut/cyc_i
add wave -noupdate -format Literal -radix hexadecimal /tb_sram_ctrl/dut/dat_o
add wave -noupdate -format Logic -radix hexadecimal /tb_sram_ctrl/dut/rty_o
add wave -noupdate -format Logic -radix hexadecimal /tb_sram_ctrl/dut/ack_o
add wave -noupdate -divider {Data and Addr Regs}
add wave -noupdate -format Literal -radix hexadecimal /tb_sram_ctrl/dut/base_addr_reg
add wave -noupdate -format Literal -radix hexadecimal /tb_sram_ctrl/dut/base_addr
add wave -noupdate -format Logic -radix hexadecimal /tb_sram_ctrl/dut/base_addr_wren
add wave -noupdate -format Literal -radix hexadecimal /tb_sram_ctrl/dut/addr
add wave -noupdate -format Literal -radix hexadecimal /tb_sram_ctrl/dut/data
add wave -noupdate -format Literal -radix hexadecimal /tb_sram_ctrl/dut/sram_data_reg
add wave -noupdate -format Logic -radix hexadecimal /tb_sram_ctrl/dut/sram_reg_wren
add wave -noupdate -divider <NULL>
add wave -noupdate -format Literal -radix hexadecimal /tb_sram_ctrl/dut/present_state
add wave -noupdate -format Literal -radix hexadecimal /tb_sram_ctrl/dut/next_state
add wave -noupdate -format Logic -radix hexadecimal /tb_sram_ctrl/dut/ce_ctrl
add wave -noupdate -format Logic -radix hexadecimal /tb_sram_ctrl/dut/wr_ctrl
add wave -noupdate -format Logic -radix hexadecimal /tb_sram_ctrl/dut/test_mode
add wave -noupdate -format Literal -radix hexadecimal /tb_sram_ctrl/dut/present_test_state
add wave -noupdate -format Literal -radix hexadecimal /tb_sram_ctrl/dut/next_test_state
add wave -noupdate -format Logic -radix hexadecimal /tb_sram_ctrl/dut/ce_ctrl_test
add wave -noupdate -format Logic -radix hexadecimal /tb_sram_ctrl/dut/wr_ctrl_test
add wave -noupdate -format Literal -radix hexadecimal /tb_sram_ctrl/dut/addr_test
add wave -noupdate -format Literal -radix hexadecimal /tb_sram_ctrl/dut/data_test
add wave -noupdate -format Logic -radix hexadecimal /tb_sram_ctrl/dut/step_rst_ctrl
add wave -noupdate -format Logic -radix hexadecimal /tb_sram_ctrl/dut/addr_dir_ctrl
add wave -noupdate -format Logic -radix hexadecimal /tb_sram_ctrl/dut/test_done
add wave -noupdate -format Literal -radix hexadecimal /tb_sram_ctrl/dut/test_step
add wave -noupdate -format Literal -radix hexadecimal /tb_sram_ctrl/dut/test_addr
add wave -noupdate -format Literal -radix hexadecimal /tb_sram_ctrl/dut/num_fault
add wave -noupdate -format Logic -radix hexadecimal /tb_sram_ctrl/dut/master_wait
add wave -noupdate -format Logic -radix hexadecimal /tb_sram_ctrl/dut/read_cmd
add wave -noupdate -format Logic -radix hexadecimal /tb_sram_ctrl/dut/write_cmd
add wave -noupdate -format Logic -radix hexadecimal /tb_sram_ctrl/dut/test_cmd
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {537779 ps} 0}
configure wave -namecolwidth 212
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
WaveRestoreZoom {147481922816 ps} {147483814589 ps}
