onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider reply_queue
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_reply_queue/cmd_to_retire_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_reply_queue/cmd_sent_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_reply_queue/cmd_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_reply_queue/cmd_timeout_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_reply_queue/size_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_reply_queue/data_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_reply_queue/error_code_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_reply_queue/rdy_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_reply_queue/ack_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_reply_queue/cmd_sent_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_reply_queue/cmd_valid_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_reply_queue/cmd_code_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_reply_queue/param_id_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_reply_queue/card_addr_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_reply_queue/stop_bit_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_reply_queue/last_frame_bit_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_reply_queue/frame_seq_num_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_reply_queue/internal_cmd_o
add wave -noupdate -divider sync
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_clk_card/sync
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/sync_num
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/frame_sync_num
add wave -noupdate -divider {fibre_rx rx}
add wave -noupdate -color Magenta -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_fibre_rx/nrx_rdy_i
add wave -noupdate -color Magenta -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_fibre_rx/rx_data_i
add wave -noupdate -divider {cmd_queue tx}
add wave -noupdate -color Blue -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/cmd_tx2/dat_i
add wave -noupdate -color Blue -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/cmd_tx2/rdy_i
add wave -noupdate -divider reply_queue
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_reply_queue/rx_cc/lvds_receiver/dat_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_reply_queue/rx_cc/lvds_receiver/rdy_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_reply_queue/rx_rc1/lvds_receiver/dat_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_reply_queue/rx_rc1/lvds_receiver/rdy_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_reply_queue/rx_rc2/lvds_receiver/dat_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_reply_queue/rx_rc2/lvds_receiver/rdy_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_reply_queue/rx_rc3/lvds_receiver/dat_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_reply_queue/rx_rc3/lvds_receiver/rdy_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_reply_queue/rx_rc4/lvds_receiver/dat_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_reply_queue/rx_rc4/lvds_receiver/rdy_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_reply_queue/rx_ac/lvds_receiver/dat_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_reply_queue/rx_ac/lvds_receiver/rdy_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_reply_queue/rx_bc1/lvds_receiver/dat_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_reply_queue/rx_bc1/lvds_receiver/rdy_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_reply_queue/rx_bc2/lvds_receiver/dat_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_reply_queue/rx_bc2/lvds_receiver/rdy_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_reply_queue/rx_bc3/lvds_receiver/dat_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_reply_queue/rx_bc3/lvds_receiver/rdy_o
add wave -noupdate -divider fibre_tx
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_fibre_tx/tx_fw_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_fibre_tx/tx_data_o
add wave -noupdate -divider cmd_translator
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/cmd_rdy_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/param_id_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/ret_dat_start
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/cmd_code_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/ret_dat_stop
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/ret_dat_s_start
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/ret_dat_s_ack
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/cmd_start
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/cmd_stop
add wave -noupdate -format Literal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/cmd_type
add wave -noupdate -divider {cmd_translator (more)}
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/rst_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/clk_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/card_id_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/cmd_data_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/cksum_err_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/data_clk_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/num_data_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/ack_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/sync_pulse_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/sync_number_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/card_addr_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/parameter_id_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/data_size_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/data_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/data_clk_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/macro_instr_rdy_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/cmd_type_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/cmd_stop_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/last_frame_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/internal_cmd_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/ack_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/m_op_seq_num_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/frame_seq_num_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/frame_sync_num_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/reply_cmd_rcvd_er_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/reply_cmd_rcvd_ok_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/reply_cmd_code_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/reply_param_id_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/reply_card_id_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/arbiter_ret_dat_ack
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/ret_dat_cmd_valid
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/ret_dat_ack
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/ret_dat_stop_ack
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/ret_dat_s_done
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/ret_dat_cmd_ack
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/ret_dat_cmd_card_addr
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/ret_dat_cmd_parameter_id
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/ret_dat_cmd_data_size
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/ret_dat_cmd_data
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/ret_dat_cmd_data_clk
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/ret_dat_cmd_type
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/ret_dat_fsm_working
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/ret_dat_frame_seq_num
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/ret_dat_frame_sync_num
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/simple_cmd_ack
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/simple_cmd_card_addr
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/simple_cmd_parameter_id
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/simple_cmd_data_size
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/simple_cmd_data
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/simple_cmd_data_clk
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/simple_cmd_macro_instr_rdy
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/simple_cmd_type
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/internal_cmd_start
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/internal_cmd_card_addr
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/internal_cmd_parameter_id
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/internal_cmd_data_size
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/internal_cmd_data
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/internal_cmd_data_clk
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/internal_cmd_macro_instr_rdy
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/internal_cmd_type
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/internal_cmd_ack
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/ret_dat_cmd_stop
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/ret_dat_last_frame
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/timer_rst
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/time
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/card_addr_reg
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/parameter_id_reg
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/data_size_reg
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/data_reg
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/data_clk_reg
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/macro_instr_rdy_reg
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/cmd_type_reg
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/cmd_stop_reg
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/last_frame_reg
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/internal_cmd_reg
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/m_op_seq_num_reg
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/frame_seq_num_reg
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/frame_sync_num_reg
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/card_addr
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/parameter_id
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/data_size
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/data
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/data_clk
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/macro_instr_rdy
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/cmd_stop_cmd_queue
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/last_frame
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/internal_cmd
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/m_op_seq_num
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/frame_seq_num
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/frame_sync_num
add wave -noupdate -divider cmd_queue
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/debug_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/uop_rdy_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/uop_ack_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/uop_timeout_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/uop_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/card_addr_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/par_id_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/data_size_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/data_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/data_clk_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/mop_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/issue_sync_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/mop_rdy_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/mop_ack_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/cmd_type_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/cmd_stop_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/last_frame_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/frame_seq_num_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/internal_cmd_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/tx_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/sync_num_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/clk_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/mem_clk_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/rst_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/data_sig
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/wraddress_sig
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/rdaddress_a_sig
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/rdaddress_b_sig
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/wren_sig
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/qa_sig
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/qb_sig
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/sync_count_slv
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/num_uops
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/data_size_int
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/size_uops
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/num_uops_inserted
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/queue_space
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/num_uops_contained
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/num_uops_contained_mux
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/retire_ptr
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/send_ptr
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/free_ptr
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/present_insert_state
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/next_insert_state
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/data_count
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/insert_uop_ack
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/num_uops_inserted_slv
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/one_more
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/present_retire_state
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/next_retire_state
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/retired
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/uop_to_retire
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/retire_data_size_int
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/retire_data_size_en
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/retire_data_size
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/one_less
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/retire_cmd_code_en
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/retire_cmd_code
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/present_gen_state
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/next_gen_state
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/mop_rdy
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/insert_uop_rdy
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/new_card_addr
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/data_size_reg
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/data_size_mux
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/data_size_mux_sel
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/present_send_state
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/next_send_state
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/previous_send_state
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/update_prev_state
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/freeze_send
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/uop_send_expired
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/issue_sync
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/timeout_sync
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/send_data_size_int
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/uop_data_count
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/send_cmd_code_en
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/send_cmd_code
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/bb_cmd_code
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/send_data_size_en
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/send_data_size
add wave -noupdate -color Yellow -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/cmd_tx_dat
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/lvds_tx_rdy
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/lvds_tx_busy
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/crc_clr
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/crc_ena
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/crc_data
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/crc_num_bits
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/crc_done
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/crc_valid
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/crc_checksum
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/crc_reg
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/sh_reg_serial_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/sh_reg_parallel_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/sh_reg_parallel_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/bit_ctr_count
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/bit_ctr_ena
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/bit_ctr_load
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/queue_space_mux
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/queue_space_mux_sel
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/data_sig_mux
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/data_sig_mux_sel
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/data_count_mux
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/data_count_mux_sel
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/free_ptr_mux_sel
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/retire_ptr_mux_sel
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/num_uops_inserted_mux_sel
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/num_uops_inserted_mux
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/num_uops_inserted_reg
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/first_time_cur_state
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/first_time_next_state
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/first_time_uop_inc
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/crc_num_bits_mux_sel
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/crc_num_bits_reg
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/cmd_tx_dat_mux_sel
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/cmd_tx_dat_reg
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/send_ptr_mux_sel
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/uop_data_count_mux_sel
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/uop_data_count_reg
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/sh_reg_parallel_mux_sel
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/queue_next_state
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/queue_cur_state
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/queue_init_value_sel
add wave -noupdate -divider ret_dat_wbs
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/ret_dat_param/start_seq_num_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/ret_dat_param/stop_seq_num_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/ret_dat_param/clk_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/ret_dat_param/rst_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/ret_dat_param/dat_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/ret_dat_param/addr_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/ret_dat_param/tga_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/ret_dat_param/we_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/ret_dat_param/stb_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/ret_dat_param/cyc_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/ret_dat_param/dat_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/ret_dat_param/ack_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/ret_dat_param/wr_cmd
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/ret_dat_param/rd_cmd
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/ret_dat_param/master_wait
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/ret_dat_param/start_wren
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/ret_dat_param/stop_wren
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/ret_dat_param/start_data
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/ret_dat_param/stop_data
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/ret_dat_param/current_state
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/ret_dat_param/next_state
add wave -noupdate -divider {rcs leds}
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_readout_card4/red_led
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_readout_card4/ylw_led
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_readout_card4/grn_led
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_readout_card3/red_led
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_readout_card3/ylw_led
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_readout_card3/grn_led
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_readout_card2/red_led
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_readout_card2/ylw_led
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_readout_card2/grn_led
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_readout_card1/red_led
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_readout_card1/ylw_led
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_readout_card1/grn_led
add wave -noupdate -divider cc_reset
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/cc_reset0/nrx_rdy_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/cc_reset0/rsc_nrd_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/cc_reset0/rso_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/cc_reset0/rvs_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/cc_reset0/rx_data_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/cc_reset0/reset_o
add wave -noupdate -divider cmd_translator_simple_commands
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_simple_cmds/rst_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_simple_cmds/clk_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_simple_cmds/card_addr_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_simple_cmds/parameter_id_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_simple_cmds/data_size_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_simple_cmds/data_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_simple_cmds/data_clk_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_simple_cmds/cmd_code_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_simple_cmds/sync_pulse_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_simple_cmds/cmd_start_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_simple_cmds/cmd_stop_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_simple_cmds/card_addr_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_simple_cmds/parameter_id_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_simple_cmds/data_size_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_simple_cmds/data_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_simple_cmds/data_clk_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_simple_cmds/macro_instr_rdy_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_simple_cmds/cmd_type_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_simple_cmds/ack_i
add wave -noupdate -divider cmd_translator_arbiter
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/rst_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/clk_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/ret_dat_frame_seq_num_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/ret_dat_frame_sync_num_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/ret_dat_card_addr_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/ret_dat_parameter_id_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/ret_dat_data_size_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/ret_dat_data_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/ret_dat_data_clk_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/ret_dat_macro_instr_rdy_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/ret_dat_fsm_working_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/ret_dat_cmd_type_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/ret_dat_cmd_stop_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/ret_dat_last_frame_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/ret_dat_ack_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/simple_cmd_card_addr_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/simple_cmd_parameter_id_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/simple_cmd_data_size_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/simple_cmd_data_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/simple_cmd_data_clk_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/simple_cmd_macro_instr_rdy_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/simple_cmd_type_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/simple_cmd_ack_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/internal_cmd_card_addr_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/internal_cmd_parameter_id_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/internal_cmd_data_size_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/internal_cmd_data_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/internal_cmd_data_clk_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/internal_cmd_macro_instr_rdy_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/internal_cmd_type_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/internal_cmd_ack_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/sync_number_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/m_op_seq_num_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/frame_seq_num_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/frame_sync_num_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/card_addr_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/parameter_id_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/data_size_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/data_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/data_clk_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/macro_instr_rdy_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/cmd_type_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/cmd_stop_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/last_frame_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/internal_cmd_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/ack_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/macro_instr_rdy
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/macro_instr_rdy_reg
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/macro_instr_rdy_1st_stg
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/macro_instr_rdy_mux_sel
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/m_op_seq_num
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/m_op_seq_num_mux
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/m_op_seq_num_mux_sel
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/frame_seq_num
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/frame_seq_num_1st_stg
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/frame_sync_num
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/frame_sync_num_1st_stg
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/data_mux_sel
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/simple_cmd_ack_mux_sel
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/ret_dat_ack_mux_sel
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/internal_cmd_ack_mux_sel
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/ret_dat_pending_mux
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/ret_dat_pending_mux_sel
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/current_state
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/next_state
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/m_op_seq_num_next_state
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/m_op_seq_num_cur_state
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/arbiter_mux
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/ret_dat_pending
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/sync_number_plus_1
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/ack_reg
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/cmd_type_reg
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/cmd_type
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/cmd_stop_reg
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/cmd_stop
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/last_frame_reg
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_arbiter/last_frame
add wave -noupdate -divider cmd_translator
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/cmd_rdy_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/param_id_i
add wave -noupdate -divider fibre_rx
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_fibre_rx/rst_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_fibre_rx/clk_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_fibre_rx/fibre_clkr_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_fibre_rx/nrx_rdy_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_fibre_rx/rvs_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_fibre_rx/rso_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_fibre_rx/rsc_nrd_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_fibre_rx/rx_data_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_fibre_rx/cmd_ack_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_fibre_rx/cmd_code_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_fibre_rx/card_id_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_fibre_rx/param_id_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_fibre_rx/num_data_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_fibre_rx/cmd_data_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_fibre_rx/cksum_err_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_fibre_rx/cmd_rdy_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_fibre_rx/data_clk_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_fibre_rx/rx_fr
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_fibre_rx/rx_fw
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_fibre_rx/rx_fe
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_fibre_rx/rx_ff
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_fibre_rx/rxd
add wave -noupdate -divider ret_dat_fsm
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/mop_rdy_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_queue/mop_ack_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_return_data_cmd/macro_instr_rdy_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_return_data_cmd/frame_seq_num_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_return_data_cmd/current_seq_num_reg_plus_1
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_return_data_cmd/current_seq_num_reg
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_return_data_cmd/sync_current_state
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_return_data_cmd/sync_next_state
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_return_data_cmd/current_state
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_return_data_cmd/next_state
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_return_data_cmd/ret_dat_start_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_return_data_cmd/ret_dat_start
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_return_data_cmd/ack_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_return_data_cmd/ack_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_return_data_cmd/ret_dat_stop_ack
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_return_data_cmd/ret_dat_start_ack
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_return_data_cmd/ack_mux
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_return_data_cmd/last_frame_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_return_data_cmd/ret_dat_stop_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_return_data_cmd/start_seq_num_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_return_data_cmd/stop_seq_num_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_return_data_cmd/current_seq_num
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_return_data_cmd/rst_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_return_data_cmd/clk_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_return_data_cmd/card_addr_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_return_data_cmd/parameter_id_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_return_data_cmd/data_size_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_return_data_cmd/data_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_return_data_cmd/data_clk_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_return_data_cmd/cmd_code_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_return_data_cmd/sync_pulse_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_return_data_cmd/sync_number_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_return_data_cmd/ret_dat_cmd_valid_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_return_data_cmd/ret_dat_s_start_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_return_data_cmd/frame_sync_num_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_return_data_cmd/card_addr_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_return_data_cmd/parameter_id_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_return_data_cmd/data_size_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_return_data_cmd/data_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_return_data_cmd/data_clk_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_return_data_cmd/cmd_type_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_return_data_cmd/cmd_stop_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_return_data_cmd/ret_dat_fsm_working_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_return_data_cmd/ret_dat_done
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_return_data_cmd/ret_dat_fsm_working
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_return_data_cmd/ret_dat_cmd_valid
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_return_data_cmd/ret_dat_stop_mux
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_return_data_cmd/ret_dat_stop_reg
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_return_data_cmd/ret_dat_stop_mux_sel
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_return_data_cmd/card_addr
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_return_data_cmd/parameter_id
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_return_data_cmd/data_size
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_return_data_cmd/data_mux
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_return_data_cmd/cmd_type
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_return_data_cmd/cmd_stop
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_return_data_cmd/card_addr_reg
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_return_data_cmd/parameter_id_reg
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_return_data_cmd/data_size_reg
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_return_data_cmd/data_reg
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_return_data_cmd/word_count
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_return_data_cmd/mux_sel
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_return_data_cmd/current_sync_num_reg_plus_1
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_return_data_cmd/current_sync_num_reg
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply0/i_cmd_translator/i_return_data_cmd/current_sync_num
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {52795622 ps} 0} {{Cursor 2} {740653434 ps} 0}
WaveRestoreZoom {52747010 ps} {53139955 ps}
configure wave -namecolwidth 587
configure wave -valuecolwidth 85
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
