onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider General
add wave -noupdate -format Logic /tb_cmd_queue/dut/n_clk
add wave -noupdate -format Logic /tb_cmd_queue/dut/clk_200mhz_i
add wave -noupdate -format Logic /tb_cmd_queue/dut/rst_i
add wave -noupdate -format Logic /tb_cmd_queue/dut/sync_i
add wave -noupdate -divider Retire
add wave -noupdate -format Literal /tb_cmd_queue/dut/uop_status_i
add wave -noupdate -format Logic /tb_cmd_queue/dut/uop_rdy_o
add wave -noupdate -format Logic /tb_cmd_queue/dut/uop_ack_i
add wave -noupdate -format Logic /tb_cmd_queue/dut/uop_discard_o
add wave -noupdate -format Logic /tb_cmd_queue/dut/uop_timedout_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cmd_queue/dut/uop_o
add wave -noupdate -format Literal /tb_cmd_queue/dut/rdaddress_b_sig
add wave -noupdate -format Literal -radix hexadecimal /tb_cmd_queue/dut/qb_sig
add wave -noupdate -format Literal -radix decimal /tb_cmd_queue/dut/clk_count
add wave -noupdate -format Literal -radix hexadecimal /tb_cmd_queue/dut/clk_error
add wave -noupdate -format Literal -radix decimal /tb_cmd_queue/dut/retire_ptr
add wave -noupdate -format Literal -radix decimal /tb_cmd_queue/dut/flush_ptr
add wave -noupdate -format Literal /tb_cmd_queue/dut/present_retire_state
add wave -noupdate -format Literal /tb_cmd_queue/dut/next_retire_state
add wave -noupdate -format Logic /tb_cmd_queue/dut/retired
add wave -noupdate -format Logic /tb_cmd_queue/dut/uop_timed_out
add wave -noupdate -divider Insert
add wave -noupdate -format Literal /tb_cmd_queue/dut/present_insert_state
add wave -noupdate -format Literal /tb_cmd_queue/dut/next_insert_state
add wave -noupdate -format Literal -radix hexadecimal /tb_cmd_queue/dut/data_sig
add wave -noupdate -format Literal -radix hexadecimal /tb_cmd_queue/dut/data_i
add wave -noupdate -format Logic /tb_cmd_queue/dut/insert_uop_ack
add wave -noupdate -format Logic /tb_cmd_queue/dut/wren_sig
add wave -noupdate -format Logic /tb_cmd_queue/dut/data_clk_i
add wave -noupdate -format Literal -radix decimal /tb_cmd_queue/dut/free_ptr
add wave -noupdate -format Literal -radix decimal /tb_cmd_queue/dut/data_count
add wave -noupdate -format Literal -radix decimal /tb_cmd_queue/dut/data_size_i
add wave -noupdate -format Literal /tb_cmd_queue/dut/data_size_int
add wave -noupdate -format Literal -radix decimal /tb_cmd_queue/dut/queue_space
add wave -noupdate -format Literal -radix hexadecimal /tb_cmd_queue/dut/wraddress_sig
add wave -noupdate -divider Generate
add wave -noupdate -format Literal /tb_cmd_queue/dut/num_uops_inserted
add wave -noupdate -format Literal /tb_cmd_queue/dut/present_gen_state
add wave -noupdate -format Literal /tb_cmd_queue/dut/next_gen_state
add wave -noupdate -format Logic /tb_cmd_queue/dut/mop_rdy_i
add wave -noupdate -format Logic /tb_cmd_queue/dut/mop_rdy
add wave -noupdate -format Logic /tb_cmd_queue/dut/mop_ack_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cmd_queue/dut/card_addr_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cmd_queue/dut/par_id_i
add wave -noupdate -format Logic /tb_cmd_queue/dut/insert_uop_rdy
add wave -noupdate -format Literal /tb_cmd_queue/dut/uops_generated
add wave -noupdate -format Literal /tb_cmd_queue/dut/cards_addressed
add wave -noupdate -format Literal /tb_cmd_queue/dut/num_uops
add wave -noupdate -format Literal /tb_cmd_queue/dut/size_uops
add wave -noupdate -divider {Queue inputs}
add wave -noupdate -format Literal -radix hexadecimal /tb_cmd_queue/dut/issue_sync_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cmd_queue/dut/uop_data_size
add wave -noupdate -format Literal -radix hexadecimal /tb_cmd_queue/dut/new_card_addr
add wave -noupdate -format Literal -radix hexadecimal /tb_cmd_queue/dut/new_par_id
add wave -noupdate -format Literal -radix hexadecimal /tb_cmd_queue/dut/mop_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cmd_queue/dut/uop_counter
add wave -noupdate -divider Send
add wave -noupdate -format Literal /tb_cmd_queue/dut/present_send_state
add wave -noupdate -format Literal /tb_cmd_queue/dut/next_send_state
add wave -noupdate -format Literal /tb_cmd_queue/dut/sync_count_slv
add wave -noupdate -format Literal /tb_cmd_queue/dut/sync_count_int
add wave -noupdate -format Logic /tb_cmd_queue/dut/freeze_send
add wave -noupdate -format Logic /tb_cmd_queue/dut/uop_send_expired
add wave -noupdate -format Literal /tb_cmd_queue/dut/uop_data_size_int
add wave -noupdate -format Literal -radix decimal /tb_cmd_queue/dut/uop_data_count
add wave -noupdate -format Literal -radix hexadecimal /tb_cmd_queue/dut/cmd_tx_dat
add wave -noupdate -format Logic /tb_cmd_queue/dut/clk_i
add wave -noupdate -format Logic /tb_cmd_queue/dut/tx_o
add wave -noupdate -format Logic /tb_cmd_queue/dut/cmd_tx_start
add wave -noupdate -format Literal /tb_cmd_queue/dut/previous_send_state
add wave -noupdate -format Logic /tb_cmd_queue/dut/cmd_tx_done
add wave -noupdate -format Logic /tb_cmd_queue/dut/crc_clr
add wave -noupdate -format Logic /tb_cmd_queue/dut/crc_ena
add wave -noupdate -format Literal /tb_cmd_queue/dut/crc_num_bits
add wave -noupdate -format Logic /tb_cmd_queue/dut/crc_data
add wave -noupdate -format Logic /tb_cmd_queue/dut/sh_reg_serial_o
add wave -noupdate -format Logic /tb_cmd_queue/dut/crc_done
add wave -noupdate -format Logic /tb_cmd_queue/dut/crc_valid
add wave -noupdate -format Literal -radix hexadecimal /tb_cmd_queue/dut/crc_checksum
add wave -noupdate -format Logic /tb_cmd_queue/dut/crc_start
add wave -noupdate -format Literal -radix hexadecimal /tb_cmd_queue/dut/sh_reg_parallel_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cmd_queue/dut/sh_reg_parallel_o
add wave -noupdate -format Literal /tb_cmd_queue/dut/bit_ctr_count
add wave -noupdate -divider {Queue outputs}
add wave -noupdate -format Literal -radix decimal /tb_cmd_queue/dut/send_ptr
add wave -noupdate -format Literal -radix decimal /tb_cmd_queue/dut/rdaddress_a_sig
add wave -noupdate -format Literal -radix hexadecimal /tb_cmd_queue/dut/qa_sig
add wave -noupdate -format Literal -radix hexadecimal /tb_cmd_queue/dut/issue_sync
add wave -noupdate -format Literal -radix hexadecimal /tb_cmd_queue/dut/timeout_sync
add wave -noupdate -divider {LVDS RX}
add wave -noupdate -format Logic /tb_cmd_queue/rx/receive/rx_clk_i
add wave -noupdate -format Logic /tb_cmd_queue/rx/receive/rst_i
add wave -noupdate -format Literal /tb_cmd_queue/rx/receive/dat_o
add wave -noupdate -format Logic /tb_cmd_queue/rx/receive/stb_i
add wave -noupdate -format Logic /tb_cmd_queue/rx/receive/rx_i
add wave -noupdate -format Logic /tb_cmd_queue/rx/receive/valid_o
add wave -noupdate -format Logic /tb_cmd_queue/rx/receive/error_o
add wave -noupdate -format Literal /tb_cmd_queue/rx/receive/pres_state
add wave -noupdate -format Literal /tb_cmd_queue/rx/receive/next_state
add wave -noupdate -format Literal /tb_cmd_queue/rx/receive/sample
add wave -noupdate -format Logic /tb_cmd_queue/rx/receive/rxbit
add wave -noupdate -format Literal /tb_cmd_queue/rx/receive/data
add wave -noupdate -format Literal /tb_cmd_queue/rx/receive/count
add wave -noupdate -format Literal -radix hexadecimal /tb_cmd_queue/rx_dat
add wave -noupdate -format Logic /tb_cmd_queue/rx_rdy
add wave -noupdate -format Logic /tb_cmd_queue/rx_ack
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {990 ns} 0}
WaveRestoreZoom {170 ns} {1298 ns}
configure wave -namecolwidth 269
configure wave -valuecolwidth 73
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
