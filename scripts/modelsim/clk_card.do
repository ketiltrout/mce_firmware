onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/clk
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/mem_clk
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/comm_clk
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/fibre_clk
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/fibre_tx_clk
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/fibre_rx_clk
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/inclk
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/rst_n
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/lvds_sync
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/lvds_clk
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/lvds_reply_ac_b
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/lvds_reply_bc1_a
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/lvds_reply_bc1_b
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/lvds_reply_bc2_a
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/lvds_reply_bc2_b
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/lvds_reply_bc3_a
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/lvds_reply_bc3_b
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/lvds_reply_rc1_a
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/lvds_reply_rc1_b
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/lvds_reply_rc2_a
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/lvds_reply_rc2_b
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/lvds_reply_rc3_a
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/lvds_reply_rc3_b
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/lvds_reply_rc4_a
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/lvds_reply_rc4_b
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/dv_pulse_fibre
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/dv_pulse_bnc
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/slot_id
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/fibre_rx_rvs
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/fibre_rx_status
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/fibre_rx_sc_nd
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/fibre_rx_ckr
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/fibre_tx_sc_nd
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/rst
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/sync_num
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/data
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/addr
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/tga
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/we
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/stb
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/cyc
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/slave_data
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/slave_ack
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/led_data
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/led_ack
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/sync_gen_data
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/sync_gen_ack
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/frame_timing_data
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/frame_timing_ack
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/slave_err
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/sync
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/fibre_rx_data
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/fibre_rx_rdy
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/lvds_cmd
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/lvds_reply_cc_a
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/lvds_reply_ac_a
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/fibre_tx_data
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/fibre_tx_ena
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/debug
add wave -noupdate -divider cmd_translator
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_cmd_translator/rst_i
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_cmd_translator/clk_i
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_translator/card_id_i
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_translator/cmd_code_i
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_translator/cmd_data_i
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_cmd_translator/cksum_err_i
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_cmd_translator/cmd_rdy_i
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_cmd_translator/data_clk_i
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_translator/num_data_i
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_translator/param_id_i
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_cmd_translator/ack_o
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_cmd_translator/sync_pulse_i
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_translator/sync_number_i
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_translator/card_addr_o
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_translator/parameter_id_o
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_translator/data_size_o
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_translator/data_o
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_cmd_translator/data_clk_o
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_cmd_translator/macro_instr_rdy_o
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_translator/cmd_type_o
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_cmd_translator/cmd_stop_o
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_cmd_translator/last_frame_o
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_cmd_translator/ack_i
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_translator/m_op_seq_num_o
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_translator/frame_seq_num_o
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_translator/frame_sync_num_o
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_cmd_translator/reply_cmd_rcvd_er_o
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_cmd_translator/reply_cmd_rcvd_ok_o
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_translator/reply_cmd_code_o
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_translator/reply_param_id_o
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_translator/reply_card_id_o
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_cmd_translator/ret_dat_start
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_cmd_translator/ret_dat_stop
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_cmd_translator/arbiter_ret_dat_ack
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_cmd_translator/ret_dat_cmd_valid
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_cmd_translator/ret_dat_ack
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_cmd_translator/ret_dat_s_start
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_cmd_translator/ret_dat_s_done
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_cmd_translator/ret_dat_s_ack
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_cmd_translator/cmd_start
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_cmd_translator/cmd_stop
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_cmd_translator/ret_dat_cmd_ack
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_translator/ret_dat_cmd_card_addr
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_translator/ret_dat_cmd_parameter_id
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_translator/ret_dat_cmd_data_size
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_translator/ret_dat_cmd_data
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_cmd_translator/ret_dat_cmd_data_clk
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_translator/ret_dat_cmd_type
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_cmd_translator/ret_dat_fsm_working
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_translator/frame_seq_num
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_translator/frame_sync_num
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_cmd_translator/simple_cmd_ack
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_translator/simple_cmd_card_addr
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_translator/simple_cmd_parameter_id
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_translator/simple_cmd_data_size
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_translator/simple_cmd_data
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_cmd_translator/simple_cmd_data_clk
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_cmd_translator/simple_cmd_macro_instr_rdy
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_translator/simple_cmd_type
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_cmd_translator/macro_instr_rdy
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_cmd_translator/ret_dat_cmd_stop
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_cmd_translator/ret_dat_last_frame
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_translator/parameter_id
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_translator/card_addr
add wave -noupdate -divider cmd_queue
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/debug_o
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/uop_rdy_o
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/uop_ack_i
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/uop_o
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/card_addr_i
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/par_id_i
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/data_size_i
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/data_i
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/data_clk_i
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/mop_i
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/issue_sync_i
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/mop_rdy_i
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/mop_ack_o
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/cmd_type_i
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/cmd_stop_i
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/last_frame_i
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/frame_seq_num_i
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/internal_cmd_i
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/tx_o
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/clk_200mhz_i
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/sync_i
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/sync_num_i
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/clk_i
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/rst_i
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/data_sig
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/wraddress_sig
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/rdaddress_a_sig
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/rdaddress_b_sig
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/wren_sig
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/qa_sig
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/qb_sig
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/sync_count_slv
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/uops_generated
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/cards_addressed
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/num_uops
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/data_size_int
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/size_uops
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/num_uops_inserted
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/queue_space
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/num_uops_contained
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/num_uops_contained_mux
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/retire_ptr
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/send_ptr
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/free_ptr
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/present_insert_state
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/next_insert_state
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/data_count
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/insert_uop_ack
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/num_uops_inserted_slv
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/one_more
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/present_retire_state
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/next_retire_state
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/retired
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/uop_to_retire
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/retire_data_size_int
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/retire_data_size_en
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/retire_data_size
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/one_less
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/retire_cmd_code_en
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/retire_cmd_code
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/present_gen_state
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/next_gen_state
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/mop_rdy
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/insert_uop_rdy
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/new_card_addr
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/new_par_id
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/data_size_reg
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/data_size_mux
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/data_size_mux_sel
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/present_send_state
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/next_send_state
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/previous_send_state
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/update_prev_state
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/freeze_send
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/uop_send_expired
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/issue_sync
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/timeout_sync
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/uop_data_count
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/send_cmd_code_en
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/send_cmd_code
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/bb_cmd_code
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/cmd_tx_dat
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/lvds_tx_rdy
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/lvds_tx_busy
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/crc_clr
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/crc_ena
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/crc_data
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/crc_num_bits
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/crc_done
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/crc_valid
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/crc_checksum
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/crc_reg
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/sh_reg_serial_o
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/sh_reg_parallel_i
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/sh_reg_parallel_o
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/bit_ctr_count
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/bit_ctr_ena
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/bit_ctr_load
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/queue_space_mux
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/queue_space_mux_sel
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/data_sig_mux
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/data_sig_mux_sel
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/data_count_mux
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/data_count_mux_sel
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/free_ptr_mux_sel
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/free_ptr_reg
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/retire_ptr_mux
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/retire_ptr_mux_sel
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/current_par_id
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/new_par_id_mux_sel
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/num_uops_inserted_mux_sel
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/num_uops_inserted_mux
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/num_uops_inserted_reg
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/first_time_cur_state
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/first_time_next_state
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/first_time_uop_inc
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/crc_num_bits_mux_sel
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/crc_num_bits_reg
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/crc_num_bits2
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/cmd_tx_dat_mux_sel
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/cmd_tx_dat_reg
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/send_ptr_reg
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/send_ptr_mux_sel
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/uop_data_count_mux_sel
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/uop_data_count_reg
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/sh_reg_parallel_mux_sel
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/queue_next_state
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/queue_cur_state
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_cmd_queue/queue_init_value_sel
add wave -noupdate -divider wishbone
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/cmd0/wishbone/clk_i
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/cmd0/wishbone/rst_i
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/cmd0/wishbone/cmd_rdy_i
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/cmd0/wishbone/data_size_i
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/cmd0/wishbone/cmd_type_i
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/cmd0/wishbone/param_id_i
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/cmd0/wishbone/cmd_buf_data_i
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/cmd0/wishbone/cmd_buf_addr_o
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/cmd0/wishbone/wb_rdy_o
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/cmd0/wishbone/wb_err_o
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/cmd0/wishbone/reply_buf_data_o
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/cmd0/wishbone/reply_buf_addr_o
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/cmd0/wishbone/reply_buf_wren_o
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/cmd0/wishbone/dat_o
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/cmd0/wishbone/addr_o
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/cmd0/wishbone/tga_o
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/cmd0/wishbone/we_o
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/cmd0/wishbone/stb_o
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/cmd0/wishbone/cyc_o
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/cmd0/wishbone/dat_i
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/cmd0/wishbone/ack_i
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/cmd0/wishbone/err_i
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/cmd0/wishbone/wait_i
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/cmd0/wishbone/wdt_rst_o
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/cmd0/wishbone/pres_state
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/cmd0/wishbone/next_state
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/cmd0/wishbone/addr_ena
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/cmd0/wishbone/addr_clr
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/cmd0/wishbone/addr
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/cmd0/wishbone/buf_addr
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/cmd0/wishbone/tga_addr
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/cmd0/wishbone/timer_rst
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/cmd0/wishbone/timer
add wave -noupdate -divider {dispatch lvds_rx}
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/cmd0/receiver/lvds_rx_data
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/cmd0/receiver/lvds_rx_rdy
add wave -noupdate -divider {reply_queue lvds_rx}
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/rx_cc/lvds_receiver/rx_data
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/rx_cc/lvds_receiver/rx_rdy
add wave -noupdate -divider reply_queue
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/cmd_to_retire_i
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/cmd_sent_o
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/cmd_i
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/size_o
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/data_o
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/error_code_o
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/rdy_o
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/ack_i
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/cmd_sent_i
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/cmd_valid_o
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/cmd_code_o
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/param_id_o
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/card_addr_o
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/stop_bit_o
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/last_frame_bit_o
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/frame_seq_num_o
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/internal_cmd_o
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/lvds_reply_cc_a
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/clk_i
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/mem_clk_i
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/comm_clk_i
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/rst_i
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/mop_num
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/uop_num
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/card_addr
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/cmd_code
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/cq_size
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/cq_data
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/cq_rdy
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/cq_ack
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/cq_err
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/rq_size
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/rq_data
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/rq_rdy
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/rq_ack
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/rq_err
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/rq_match
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/rq_start
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/cc_data
add wave -noupdate -format Literal -radix hexadecimal /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/cc_header
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/cc_rdy
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/cc_ack
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/cc_nack
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/cc_done
add wave -noupdate -divider reply_queue_retire
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/rqr/cmd_to_retire_i
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/rqr/cmd_sent_o
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/rqr/cmd_i
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/rqr/cmd_sent_i
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/rqr/cmd_valid_o
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/rqr/rdy_o
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/rqr/ack_i
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/rqr/cmd_code_o
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/rqr/param_id_o
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/rqr/stop_bit_o
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/rqr/last_frame_bit_o
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/rqr/frame_seq_num_o
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/rqr/internal_cmd_o
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/rqr/size_o
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/rqr/data_o
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/rqr/error_code_o
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/rqr/card_addr_o
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/rqr/matched_i
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/rqr/cmd_rdy_o
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/rqr/mop_num_o
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/rqr/uop_num_o
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/rqr/clk_i
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/rqr/comm_clk_i
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/rqr/rst_i
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/rqr/ack
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/rqr/matched
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/rqr/cmd_rdy
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/rqr/cmd_code
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/rqr/header_a
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/rqr/header_b
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/rqr/header_c
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/rqr/header_d
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/rqr/header_a_en
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/rqr/header_b_en
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/rqr/header_c_en
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/rqr/header_d_en
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/rqr/present_retire_state
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/issue_reply0/i_reply_queue/rqr/next_retire_state
add wave -noupdate -divider sync_gen
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/sync_gen0/dv_i
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/sync_gen0/sync_o
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/sync_gen0/sync_num_o
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/sync_gen0/dat_i
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/sync_gen0/addr_i
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/sync_gen0/tga_i
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/sync_gen0/we_i
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/sync_gen0/stb_i
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/sync_gen0/cyc_i
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/sync_gen0/dat_o
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/sync_gen0/ack_o
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/sync_gen0/clk_i
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/sync_gen0/mem_clk_i
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/sync_gen0/rst_i
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/sync_gen0/current_state
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/sync_gen0/next_state
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/sync_gen0/clk_count
add wave -noupdate -format Literal /tb_clk_card/i_clk_card/sync_gen0/sync_count
add wave -noupdate -format Logic /tb_clk_card/i_clk_card/sync_gen0/dv_en
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {78830000 ps} 0}
WaveRestoreZoom {0 ps} {1283226 ns}
configure wave -namecolwidth 468
configure wave -valuecolwidth 109
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
