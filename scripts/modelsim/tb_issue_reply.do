onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {Testbench signals}
add wave -noupdate -format Logic /tb_issue_reply/t_rst_i
add wave -noupdate -format Logic /tb_issue_reply/t_clk_i
add wave -noupdate -format Literal -radix hexadecimal /tb_issue_reply/t_rx_data_i
add wave -noupdate -format Logic /tb_issue_reply/t_nrx_rdy_i
add wave -noupdate -format Logic /tb_issue_reply/t_rvs_i
add wave -noupdate -format Logic /tb_issue_reply/t_rso_i
add wave -noupdate -format Logic /tb_issue_reply/t_rsc_nrd_i
add wave -noupdate -format Logic /tb_issue_reply/t_tx
add wave -noupdate -format Logic /tb_issue_reply/t_clk_200mhz_i
add wave -noupdate -format Literal -radix hexadecimal /tb_issue_reply/address_id
add wave -noupdate -format Literal -radix hexadecimal /tb_issue_reply/checksum
add wave -noupdate -format Literal -radix hexadecimal /tb_issue_reply/command
add wave -noupdate -format Literal -radix hexadecimal /tb_issue_reply/data_valid
add wave -noupdate -format Literal -radix hexadecimal /tb_issue_reply/data
add wave -noupdate -format Literal -radix hexadecimal /tb_issue_reply/count
add wave -noupdate -format Logic /tb_issue_reply/t_rst_i
add wave -noupdate -format Logic /tb_issue_reply/t_clk_i
add wave -noupdate -format Literal -radix hexadecimal /tb_issue_reply/t_rx_data_i
add wave -noupdate -format Logic /tb_issue_reply/t_nrx_rdy_i
add wave -noupdate -format Logic /tb_issue_reply/t_rvs_i
add wave -noupdate -format Logic /tb_issue_reply/t_rso_i
add wave -noupdate -format Logic /tb_issue_reply/t_rsc_nrd_i
add wave -noupdate -format Logic /tb_issue_reply/t_tx
add wave -noupdate -format Logic /tb_issue_reply/t_clk_200mhz_i
add wave -noupdate -format Literal -radix hexadecimal /tb_issue_reply/address_id
add wave -noupdate -format Literal -radix hexadecimal /tb_issue_reply/checksum
add wave -noupdate -format Literal -radix hexadecimal /tb_issue_reply/command
add wave -noupdate -format Literal -radix hexadecimal /tb_issue_reply/data_valid
add wave -noupdate -format Literal -radix hexadecimal /tb_issue_reply/data
add wave -noupdate -format Literal -radix hexadecimal /tb_issue_reply/count
add wave -noupdate -format Logic /tb_issue_reply/dut/i_cmd_translator/sync_pulse_i
add wave -noupdate -divider {lvds rx}
add wave -noupdate -format Logic /tb_issue_reply/rx/clk_i
add wave -noupdate -format Logic /tb_issue_reply/rx/comm_clk_i
add wave -noupdate -format Logic /tb_issue_reply/rx/rst_i
add wave -noupdate -format Literal -radix hexadecimal /tb_issue_reply/rx/dat_o
add wave -noupdate -format Logic /tb_issue_reply/rx/rdy_o
add wave -noupdate -format Logic /tb_issue_reply/rx/ack_i
add wave -noupdate -format Logic /tb_issue_reply/rx/lvds_i
add wave -noupdate -format Literal -radix hexadecimal /tb_issue_reply/rx/rx_data
add wave -noupdate -format Logic /tb_issue_reply/rx/rx_stb
add wave -noupdate -format Logic /tb_issue_reply/rx/rx_rdy
add wave -noupdate -format Logic /tb_issue_reply/rx/rx_error
add wave -noupdate -format Literal -radix hexadecimal /tb_issue_reply/rx/data_reg
add wave -noupdate -format Literal /tb_issue_reply/rx/byte_count
add wave -noupdate -format Literal /tb_issue_reply/rx/pres_state
add wave -noupdate -format Literal /tb_issue_reply/rx/next_state
add wave -noupdate -divider {Issue Reply top level signals}
add wave -noupdate -format Logic /tb_issue_reply/dut/rst_i
add wave -noupdate -format Logic /tb_issue_reply/dut/clk_i
add wave -noupdate -format Literal -radix hexadecimal /tb_issue_reply/dut/rx_data_i
add wave -noupdate -format Logic /tb_issue_reply/dut/nrx_rdy_i
add wave -noupdate -format Logic /tb_issue_reply/dut/rvs_i
add wave -noupdate -format Logic /tb_issue_reply/dut/rso_i
add wave -noupdate -format Logic /tb_issue_reply/dut/rsc_nrd_i
add wave -noupdate -format Logic /tb_issue_reply/dut/cksum_err_o
add wave -noupdate -format Logic /tb_issue_reply/dut/tx_o
add wave -noupdate -format Logic /tb_issue_reply/dut/clk_200mhz_i
add wave -noupdate -format Literal -radix hexadecimal /tb_issue_reply/dut/card_id
add wave -noupdate -format Literal -radix hexadecimal /tb_issue_reply/dut/cmd_code
add wave -noupdate -format Literal -radix hexadecimal /tb_issue_reply/dut/cmd_data
add wave -noupdate -format Logic /tb_issue_reply/dut/cmd_rdy
add wave -noupdate -format Logic /tb_issue_reply/dut/data_clk
add wave -noupdate -format Literal -radix hexadecimal /tb_issue_reply/dut/num_data
add wave -noupdate -format Literal -radix hexadecimal /tb_issue_reply/dut/param_id
add wave -noupdate -format Logic /tb_issue_reply/dut/cmd_ack
add wave -noupdate -format Logic /tb_issue_reply/dut/reply_cmd_ack_o
add wave -noupdate -format Literal -radix hexadecimal /tb_issue_reply/dut/reply_card_addr_o
add wave -noupdate -format Literal -radix hexadecimal /tb_issue_reply/dut/reply_parameter_id_o
add wave -noupdate -format Literal -radix hexadecimal /tb_issue_reply/dut/reply_data_size_o
add wave -noupdate -format Literal -radix hexadecimal /tb_issue_reply/dut/reply_data_o
add wave -noupdate -format Logic /tb_issue_reply/dut/sync_pulse
add wave -noupdate -format Literal -radix hexadecimal /tb_issue_reply/dut/sync_number
add wave -noupdate -format Literal -radix hexadecimal /tb_issue_reply/dut/count
add wave -noupdate -format Logic /tb_issue_reply/dut/count_rst
add wave -noupdate -format Literal -radix hexadecimal /tb_issue_reply/dut/uop_status
add wave -noupdate -format Logic /tb_issue_reply/dut/uop_rdy
add wave -noupdate -format Logic /tb_issue_reply/dut/uop_ack
add wave -noupdate -format Logic /tb_issue_reply/dut/uop_discard
add wave -noupdate -format Logic /tb_issue_reply/dut/uop_timedout
add wave -noupdate -format Literal -radix hexadecimal /tb_issue_reply/dut/uop
add wave -noupdate -format Literal -radix hexadecimal /tb_issue_reply/dut/card_addr
add wave -noupdate -format Literal -radix hexadecimal /tb_issue_reply/dut/parameter_id
add wave -noupdate -format Literal -radix hexadecimal /tb_issue_reply/dut/data_size
add wave -noupdate -format Literal -radix hexadecimal /tb_issue_reply/dut/data
add wave -noupdate -format Logic /tb_issue_reply/dut/data_clk2
add wave -noupdate -format Literal -radix hexadecimal /tb_issue_reply/dut/m_op_seq_num
add wave -noupdate -format Literal -radix hexadecimal /tb_issue_reply/dut/frame_sync_num
add wave -noupdate -format Literal -radix hexadecimal /tb_issue_reply/dut/frame_seq_num
add wave -noupdate -format Logic /tb_issue_reply/dut/macro_instr_rdy
add wave -noupdate -format Logic /tb_issue_reply/dut/mop_ack
add wave -noupdate -divider {cmd translator signals}
add wave -noupdate -format Logic /tb_issue_reply/dut/i_cmd_translator/rst_i
add wave -noupdate -format Logic /tb_issue_reply/dut/i_cmd_translator/clk_i
add wave -noupdate -format Literal -radix hexadecimal /tb_issue_reply/dut/i_cmd_translator/card_id_i
add wave -noupdate -format Literal -radix hexadecimal /tb_issue_reply/dut/i_cmd_translator/cmd_code_i
add wave -noupdate -format Literal -radix hexadecimal /tb_issue_reply/dut/i_cmd_translator/cmd_data_i
add wave -noupdate -format Logic /tb_issue_reply/dut/i_cmd_translator/cmd_rdy_i
add wave -noupdate -format Logic /tb_issue_reply/dut/i_cmd_translator/data_clk_i
add wave -noupdate -format Literal -radix hexadecimal /tb_issue_reply/dut/i_cmd_translator/num_data_i
add wave -noupdate -format Literal -radix hexadecimal /tb_issue_reply/dut/i_cmd_translator/param_id_i
add wave -noupdate -format Logic /tb_issue_reply/dut/i_cmd_translator/ack_o
add wave -noupdate -format Logic /tb_issue_reply/dut/i_cmd_translator/sync_pulse_i
add wave -noupdate -format Literal -radix hexadecimal /tb_issue_reply/dut/i_cmd_translator/sync_number_i
add wave -noupdate -format Literal -radix hexadecimal /tb_issue_reply/dut/i_cmd_translator/card_addr_o
add wave -noupdate -format Literal -radix hexadecimal /tb_issue_reply/dut/i_cmd_translator/parameter_id_o
add wave -noupdate -format Literal -radix hexadecimal /tb_issue_reply/dut/i_cmd_translator/data_size_o
add wave -noupdate -format Literal -radix hexadecimal /tb_issue_reply/dut/i_cmd_translator/data_o
add wave -noupdate -format Logic /tb_issue_reply/dut/i_cmd_translator/data_clk_o
add wave -noupdate -format Logic /tb_issue_reply/dut/i_cmd_translator/macro_instr_rdy_o
add wave -noupdate -format Logic /tb_issue_reply/dut/i_cmd_translator/ack_i
add wave -noupdate -format Literal -radix hexadecimal /tb_issue_reply/dut/i_cmd_translator/m_op_seq_num_o
add wave -noupdate -format Literal -radix hexadecimal /tb_issue_reply/dut/i_cmd_translator/frame_seq_num_o
add wave -noupdate -format Literal -radix hexadecimal /tb_issue_reply/dut/i_cmd_translator/frame_sync_num_o
add wave -noupdate -format Logic /tb_issue_reply/dut/i_cmd_translator/reply_cmd_ack_o
add wave -noupdate -format Literal -radix hexadecimal /tb_issue_reply/dut/i_cmd_translator/reply_card_addr_o
add wave -noupdate -format Literal -radix hexadecimal /tb_issue_reply/dut/i_cmd_translator/reply_parameter_id_o
add wave -noupdate -format Literal -radix hexadecimal /tb_issue_reply/dut/i_cmd_translator/reply_data_size_o
add wave -noupdate -format Literal -radix hexadecimal /tb_issue_reply/dut/i_cmd_translator/reply_data_o
add wave -noupdate -format Logic /tb_issue_reply/dut/i_cmd_translator/ret_dat_start
add wave -noupdate -format Logic /tb_issue_reply/dut/i_cmd_translator/ret_dat_stop
add wave -noupdate -format Logic /tb_issue_reply/dut/i_cmd_translator/arbiter_ret_dat_ack
add wave -noupdate -format Logic /tb_issue_reply/dut/i_cmd_translator/ret_dat_cmd_valid
add wave -noupdate -format Logic /tb_issue_reply/dut/i_cmd_translator/ret_dat_ack
add wave -noupdate -format Logic /tb_issue_reply/dut/i_cmd_translator/ret_dat_s_start
add wave -noupdate -format Logic /tb_issue_reply/dut/i_cmd_translator/ret_dat_s_done
add wave -noupdate -format Logic /tb_issue_reply/dut/i_cmd_translator/ret_dat_s_ack
add wave -noupdate -format Logic /tb_issue_reply/dut/i_cmd_translator/cmd_start
add wave -noupdate -format Logic /tb_issue_reply/dut/i_cmd_translator/cmd_stop
add wave -noupdate -format Logic /tb_issue_reply/dut/i_cmd_translator/cmd_ack
add wave -noupdate -format Logic /tb_issue_reply/dut/i_cmd_translator/error_handler_start
add wave -noupdate -format Logic /tb_issue_reply/dut/i_cmd_translator/error_handler_stop
add wave -noupdate -format Logic /tb_issue_reply/dut/i_cmd_translator/error_handler_ack
add wave -noupdate -format Logic /tb_issue_reply/dut/i_cmd_translator/ret_dat_cmd_ack
add wave -noupdate -format Literal /tb_issue_reply/dut/i_cmd_translator/ret_dat_cmd_card_addr
add wave -noupdate -format Literal /tb_issue_reply/dut/i_cmd_translator/ret_dat_cmd_parameter_id
add wave -noupdate -format Literal /tb_issue_reply/dut/i_cmd_translator/ret_dat_cmd_data_size
add wave -noupdate -format Literal /tb_issue_reply/dut/i_cmd_translator/ret_dat_cmd_data
add wave -noupdate -format Logic /tb_issue_reply/dut/i_cmd_translator/ret_dat_cmd_data_clk
add wave -noupdate -format Logic /tb_issue_reply/dut/i_cmd_translator/ret_dat_fsm_working
add wave -noupdate -format Literal /tb_issue_reply/dut/i_cmd_translator/frame_seq_num
add wave -noupdate -format Literal /tb_issue_reply/dut/i_cmd_translator/frame_sync_num
add wave -noupdate -format Logic /tb_issue_reply/dut/i_cmd_translator/simple_cmd_ack
add wave -noupdate -format Literal /tb_issue_reply/dut/i_cmd_translator/simple_cmd_card_addr
add wave -noupdate -format Literal /tb_issue_reply/dut/i_cmd_translator/simple_cmd_parameter_id
add wave -noupdate -format Literal /tb_issue_reply/dut/i_cmd_translator/simple_cmd_data_size
add wave -noupdate -format Literal /tb_issue_reply/dut/i_cmd_translator/simple_cmd_data
add wave -noupdate -format Logic /tb_issue_reply/dut/i_cmd_translator/simple_cmd_data_clk
add wave -noupdate -format Logic /tb_issue_reply/dut/i_cmd_translator/simple_cmd_macro_instr_rdy
add wave -noupdate -format Literal /tb_issue_reply/dut/i_cmd_translator/arbiter_ack
add wave -noupdate -format Logic /tb_issue_reply/dut/i_cmd_translator/macro_instr_rdy
add wave -noupdate -divider cmd_queue
add wave -noupdate -format Literal /tb_issue_reply/dut/i_cmd_queue/uop_status_i
add wave -noupdate -format Logic /tb_issue_reply/dut/i_cmd_queue/uop_rdy_o
add wave -noupdate -format Logic /tb_issue_reply/dut/i_cmd_queue/uop_ack_i
add wave -noupdate -format Logic /tb_issue_reply/dut/i_cmd_queue/uop_discard_o
add wave -noupdate -format Logic /tb_issue_reply/dut/i_cmd_queue/uop_timedout_o
add wave -noupdate -format Literal /tb_issue_reply/dut/i_cmd_queue/uop_o
add wave -noupdate -format Literal /tb_issue_reply/dut/i_cmd_queue/data_i
add wave -noupdate -format Logic /tb_issue_reply/dut/i_cmd_queue/tx_o
add wave -noupdate -format Logic /tb_issue_reply/dut/i_cmd_queue/clk_200mhz_i
add wave -noupdate -format Logic /tb_issue_reply/dut/i_cmd_queue/sync_i
add wave -noupdate -format Literal /tb_issue_reply/dut/i_cmd_queue/sync_num_i
add wave -noupdate -format Logic /tb_issue_reply/dut/i_cmd_queue/clk_i
add wave -noupdate -format Logic /tb_issue_reply/dut/i_cmd_queue/rst_i
add wave -noupdate -format Literal /tb_issue_reply/dut/i_cmd_queue/rdaddress_a_sig
add wave -noupdate -format Literal /tb_issue_reply/dut/i_cmd_queue/rdaddress_b_sig
add wave -noupdate -format Literal /tb_issue_reply/dut/i_cmd_queue/qa_sig
add wave -noupdate -format Literal /tb_issue_reply/dut/i_cmd_queue/qb_sig
add wave -noupdate -format Logic /tb_issue_reply/dut/i_cmd_queue/nfast_clk
add wave -noupdate -format Logic /tb_issue_reply/dut/i_cmd_queue/n_clk
add wave -noupdate -format Literal /tb_issue_reply/dut/i_cmd_queue/uop_counter
add wave -noupdate -format Literal /tb_issue_reply/dut/i_cmd_queue/sync_count_slv
add wave -noupdate -format Literal /tb_issue_reply/dut/i_cmd_queue/uops_generated
add wave -noupdate -format Literal /tb_issue_reply/dut/i_cmd_queue/cards_addressed
add wave -noupdate -format Literal /tb_issue_reply/dut/i_cmd_queue/retire_ptr
add wave -noupdate -divider Generate
add wave -noupdate -format Literal /tb_issue_reply/dut/i_cmd_queue/present_gen_state
add wave -noupdate -format Literal /tb_issue_reply/dut/i_cmd_queue/next_gen_state
add wave -noupdate -format Logic /tb_issue_reply/dut/i_cmd_queue/mop_rdy_i
add wave -noupdate -format Logic /tb_issue_reply/dut/i_cmd_queue/mop_rdy
add wave -noupdate -format Logic /tb_issue_reply/dut/i_cmd_queue/mop_ack_o
add wave -noupdate -format Literal /tb_issue_reply/dut/i_cmd_queue/size_uops
add wave -noupdate -format Literal -radix hexadecimal /tb_issue_reply/dut/i_cmd_queue/issue_sync_i
add wave -noupdate -format Literal -radix hexadecimal /tb_issue_reply/dut/i_cmd_queue/card_addr_i
add wave -noupdate -format Literal -radix hexadecimal /tb_issue_reply/dut/i_cmd_queue/par_id_i
add wave -noupdate -format Literal /tb_issue_reply/dut/i_cmd_queue/num_uops
add wave -noupdate -format Literal /tb_issue_reply/dut/i_cmd_queue/num_uops_inserted
add wave -noupdate -divider Insert
add wave -noupdate -format Literal /tb_issue_reply/dut/i_cmd_queue/present_insert_state
add wave -noupdate -format Literal /tb_issue_reply/dut/i_cmd_queue/next_insert_state
add wave -noupdate -format Logic /tb_issue_reply/dut/i_cmd_queue/insert_uop_ack
add wave -noupdate -format Literal /tb_issue_reply/dut/i_cmd_queue/queue_space
add wave -noupdate -format Literal -radix hexadecimal /tb_issue_reply/dut/i_cmd_queue/free_ptr
add wave -noupdate -format Logic /tb_issue_reply/dut/i_cmd_queue/wren_sig
add wave -noupdate -format Literal -radix hexadecimal /tb_issue_reply/dut/i_cmd_queue/data_sig
add wave -noupdate -format Literal -radix hexadecimal /tb_issue_reply/dut/i_cmd_queue/wraddress_sig
add wave -noupdate -format Literal -radix hexadecimal /tb_issue_reply/dut/i_cmd_queue/data_size_i
add wave -noupdate -format Literal /tb_issue_reply/dut/i_cmd_queue/data_size_int
add wave -noupdate -format Literal -radix hexadecimal /tb_issue_reply/dut/i_cmd_queue/num_uops_inserted_slv
add wave -noupdate -format Literal -radix hexadecimal /tb_issue_reply/dut/i_cmd_queue/issue_sync
add wave -noupdate -format Literal -radix hexadecimal /tb_issue_reply/dut/i_cmd_queue/data_count
add wave -noupdate -format Literal -radix hexadecimal /tb_issue_reply/dut/i_cmd_queue/new_card_addr
add wave -noupdate -format Literal -radix hexadecimal /tb_issue_reply/dut/i_cmd_queue/new_par_id
add wave -noupdate -format Literal -radix hexadecimal /tb_issue_reply/dut/i_cmd_queue/mop_i
add wave -noupdate -format Logic /tb_issue_reply/dut/i_cmd_queue/data_clk_i
add wave -noupdate -format Logic /tb_issue_reply/dut/i_cmd_queue/insert_uop_rdy
add wave -noupdate -divider Send
add wave -noupdate -format Literal /tb_issue_reply/dut/i_cmd_queue/next_send_state
add wave -noupdate -format Literal /tb_issue_reply/dut/i_cmd_queue/present_send_state
add wave -noupdate -format Literal /tb_issue_reply/dut/i_cmd_queue/previous_send_state
add wave -noupdate -format Logic /tb_issue_reply/dut/i_cmd_queue/uop_send_expired
add wave -noupdate -divider Retire
add wave -noupdate -format Literal /tb_issue_reply/dut/i_cmd_queue/flush_ptr
add wave -noupdate -format Literal /tb_issue_reply/dut/i_cmd_queue/send_ptr
add wave -noupdate -format Literal /tb_issue_reply/dut/i_cmd_queue/present_retire_state
add wave -noupdate -format Literal /tb_issue_reply/dut/i_cmd_queue/next_retire_state
add wave -noupdate -format Logic /tb_issue_reply/dut/i_cmd_queue/retired
add wave -noupdate -format Logic /tb_issue_reply/dut/i_cmd_queue/uop_timed_out
add wave -noupdate -format Logic /tb_issue_reply/dut/i_cmd_queue/freeze_send
add wave -noupdate -format Literal /tb_issue_reply/dut/i_cmd_queue/timeout_sync
add wave -noupdate -format Literal /tb_issue_reply/dut/i_cmd_queue/uop_data_size
add wave -noupdate -format Literal /tb_issue_reply/dut/i_cmd_queue/uop_data_size_int
add wave -noupdate -format Literal /tb_issue_reply/dut/i_cmd_queue/uop_data_count
add wave -noupdate -format Literal /tb_issue_reply/dut/i_cmd_queue/cmd_tx_dat
add wave -noupdate -format Logic /tb_issue_reply/dut/i_cmd_queue/cmd_tx_start
add wave -noupdate -format Logic /tb_issue_reply/dut/i_cmd_queue/cmd_tx_done
add wave -noupdate -format Logic /tb_issue_reply/dut/i_cmd_queue/crc_clr
add wave -noupdate -format Logic /tb_issue_reply/dut/i_cmd_queue/crc_ena
add wave -noupdate -format Logic /tb_issue_reply/dut/i_cmd_queue/crc_data
add wave -noupdate -format Literal /tb_issue_reply/dut/i_cmd_queue/crc_num_bits
add wave -noupdate -format Logic /tb_issue_reply/dut/i_cmd_queue/crc_done
add wave -noupdate -format Logic /tb_issue_reply/dut/i_cmd_queue/crc_valid
add wave -noupdate -format Literal /tb_issue_reply/dut/i_cmd_queue/crc_checksum
add wave -noupdate -format Logic /tb_issue_reply/dut/i_cmd_queue/crc_start
add wave -noupdate -format Literal /tb_issue_reply/dut/i_cmd_queue/crc_reg
add wave -noupdate -format Logic /tb_issue_reply/dut/i_cmd_queue/sh_reg_serial_o
add wave -noupdate -format Literal /tb_issue_reply/dut/i_cmd_queue/sh_reg_parallel_i
add wave -noupdate -format Literal /tb_issue_reply/dut/i_cmd_queue/sh_reg_parallel_o
add wave -noupdate -format Literal /tb_issue_reply/dut/i_cmd_queue/bit_ctr_count
add wave -noupdate -format Logic /tb_issue_reply/dut/i_cmd_queue/bit_ctr_ena
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {133014 ns} 0}
WaveRestoreZoom {0 ns} {137634 ns}
configure wave -namecolwidth 325
configure wave -valuecolwidth 102
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
