onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/present_sim_state
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply_block/sync_number_i
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply_block/i_fibre_rx/fibre_data_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply_block/i_fibre_rx/fibre_nrdy_i
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_clk_card/manchester_data
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply_block/i_cmd_queue/cmd_tx2/dat_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply_block/i_cmd_queue/cmd_tx2/rdy_i
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply_block/lvds_reply_ac_a
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply_block/lvds_reply_bc1_a
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply_block/lvds_reply_bc2_a
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply_block/lvds_reply_bc3_a
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply_block/lvds_reply_rc1_a
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply_block/lvds_reply_rc2_a
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply_block/lvds_reply_rc3_a
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply_block/lvds_reply_rc4_a
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply_block/lvds_reply_cc_a
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply_block/lvds_reply_psu_a
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply_block/i_reply_translator/fibre_tx_rdy_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply_block/i_reply_translator/fibre_tx_dat_o
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply_block/i_fibre_rx/current_state
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply_block/i_cmd_translator/current_state
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply_block/i_cmd_queue/present_state
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply_block/i_reply_queue/rq_seq/pres_state
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply_block/i_reply_queue/present_retire_state
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply_block/i_reply_translator/translator_current_state
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply_block/i_fibre_tx/pres_state
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply_block/i_cmd_translator/current_state
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply_block/i_cmd_translator/cmd_stop_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply_block/i_cmd_translator/last_frame_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply_block/i_cmd_translator/ack_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply_block/i_cmd_translator/instr_rdy_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply_block/i_cmd_translator/ack_o
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply_block/i_cmd_translator/f_rx_ret_dat_ack
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply_block/i_cmd_translator/ret_dat_ack
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply_block/i_cmd_translator/ret_dat_stop_req
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply_block/i_cmd_translator/ret_dat_req
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply_block/i_cmd_translator/ret_dat_start
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply_block/i_cmd_translator/ret_dat_done
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply_block/i_cmd_translator/ret_dat_in_progress
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply_block/i_cmd_queue/present_state
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply_block/i_cmd_queue/cmd_stop_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply_block/i_cmd_queue/last_frame_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply_block/i_cmd_queue/cmd_stop_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply_block/i_cmd_queue/last_frame_i
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply_block/i_reply_queue/rq_seq/rx_cc/lvds_receiver/rdy_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply_block/i_reply_queue/rq_seq/rx_cc/lvds_receiver/dat_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply_block/i_reply_queue/present_retire_state
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply_block/i_reply_queue/cmd_stop_i
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply_block/i_reply_queue/last_frame_i
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply_block/i_reply_translator/translator_current_state
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply_block/i_reply_translator/fibre_tx_rdy_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply_block/i_reply_translator/fibre_tx_dat_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply_block/tx_data_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_clk_card/issue_reply_block/nfena_o
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_clk_card/lvds_reply_rc4_b
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_clk_card/lvds_reply_rc3_b
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_clk_card/lvds_reply_rc2_b
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_clk_card/lvds_reply_rc1_b
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_clk_card/lvds_reply_bc3_b
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_clk_card/lvds_reply_bc2_b
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_clk_card/lvds_reply_bc1_b
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_clk_card/lvds_reply_ac_b
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/row_switch_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/restart_frame_aligned_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/row_current_state
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/const_current_state
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/dac_data_o
add wave -noupdate -format Literal -radix binary /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/dac_clks_o
add wave -noupdate -format Literal -radix unsigned /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/row_to_turn_off_int
add wave -noupdate -format Literal -radix unsigned /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/row_to_turn_on_int
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/update_const
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/update_const_ack
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/update_row_index
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/clk_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/clk_100_i
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/dat_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/addr_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/tga_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/we_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/stb_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/cyc_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/dat_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/ack_o
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/clk_i_n
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/dat_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/addr_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/tga_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/we_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/stb_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/cyc_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/dat_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/ack_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/restart_frame_aligned_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/restart_frame_1row_prev_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/row_en_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/rst_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/row_to_turn_off_slv
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/row_to_turn_off_int
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/row_to_turn_on_slv
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/row_to_turn_on_int
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/row_order_index_int
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/row_order_index_slv
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/row_next_state
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/const_next_state
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/frame_aligned_reg
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/mux_en
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/prev_row_count
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/row_count_new
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/k
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/dac_id_int
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/tga_int
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/fb_wren
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/pre_reg_data
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/fast_dac_data
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/dataa
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/datab
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/mode_wren_vec
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/val_wren_vec
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/mode_data_slv
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/mode_data_vec
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/const_data_vec
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/mode_data
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/const_data
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/val_changing
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/update_const_dly1
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/update_const_dly2
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/wr_cmd
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/rd_cmd
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/on_val_wren
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/off_val_wren
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/row_order_wren
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/mux_en_wren
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/mux_en_data
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/on_dataa
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/off_dataa
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/on_datab
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/off_datab
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/row_order_data
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/slow_dac_data_on
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/slow_dac_data_off
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/current_state
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/next_state
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/addr_int
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/datab_mux
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/start_row
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/next_row_order_index_int
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/next_row_order_index_int_new
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Logic -height 15 -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/mode_data_vec(40)(0)
add wave -noupdate -format Logic -height 15 -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/mode_data_vec(39)(0)
add wave -noupdate -format Logic -height 15 -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/mode_data_vec(38)(0)
add wave -noupdate -format Logic -height 15 -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/mode_data_vec(37)(0)
add wave -noupdate -format Logic -height 15 -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/mode_data_vec(36)(0)
add wave -noupdate -format Logic -height 15 -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/mode_data_vec(35)(0)
add wave -noupdate -format Logic -height 15 -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/mode_data_vec(33)(0)
add wave -noupdate -format Logic -height 15 -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/mode_data_vec(34)(0)
add wave -noupdate -format Logic -height 15 -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/mode_data_vec(32)(0)
add wave -noupdate -format Logic -height 15 -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/mode_data_vec(31)(0)
add wave -noupdate -format Logic -height 15 -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/mode_data_vec(30)(0)
add wave -noupdate -format Logic -height 15 -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/mode_data_vec(29)(0)
add wave -noupdate -format Logic -height 15 -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/mode_data_vec(28)(0)
add wave -noupdate -format Logic -height 15 -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/mode_data_vec(27)(0)
add wave -noupdate -format Logic -height 15 -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/mode_data_vec(26)(0)
add wave -noupdate -format Logic -height 15 -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/mode_data_vec(25)(0)
add wave -noupdate -format Logic -height 15 -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/mode_data_vec(24)(0)
add wave -noupdate -format Logic -height 15 -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/mode_data_vec(23)(0)
add wave -noupdate -format Logic -height 15 -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/mode_data_vec(22)(0)
add wave -noupdate -format Logic -height 15 -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/mode_data_vec(21)(0)
add wave -noupdate -format Logic -height 15 -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/mode_data_vec(20)(0)
add wave -noupdate -format Logic -height 15 -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/mode_data_vec(19)(0)
add wave -noupdate -format Logic -height 15 -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/mode_data_vec(18)(0)
add wave -noupdate -format Logic -height 15 -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/mode_data_vec(17)(0)
add wave -noupdate -format Logic -height 15 -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/mode_data_vec(16)(0)
add wave -noupdate -format Logic -height 15 -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/mode_data_vec(15)(0)
add wave -noupdate -format Logic -height 15 -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/mode_data_vec(14)(0)
add wave -noupdate -format Logic -height 15 -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/mode_data_vec(13)(0)
add wave -noupdate -format Logic -height 15 -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/mode_data_vec(12)(0)
add wave -noupdate -format Logic -height 15 -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/mode_data_vec(11)(0)
add wave -noupdate -format Logic -height 15 -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/mode_data_vec(10)(0)
add wave -noupdate -format Logic -height 15 -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/mode_data_vec(9)(0)
add wave -noupdate -format Logic -height 15 -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/mode_data_vec(8)(0)
add wave -noupdate -format Logic -height 15 -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/mode_data_vec(7)(0)
add wave -noupdate -format Logic -height 15 -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/mode_data_vec(6)(0)
add wave -noupdate -format Logic -height 15 -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/mode_data_vec(5)(0)
add wave -noupdate -format Logic -height 15 -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/mode_data_vec(4)(0)
add wave -noupdate -format Logic -height 15 -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/mode_data_vec(3)(0)
add wave -noupdate -format Logic -height 15 -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/mode_data_vec(2)(0)
add wave -noupdate -format Logic -height 15 -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/mode_data_vec(1)(0)
add wave -noupdate -format Logic -height 15 -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/ac_dac_ctrl_slave/mode_data_vec(0)(0)
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 2} {3800839999 ps} 0}
configure wave -namecolwidth 420
configure wave -valuecolwidth 323
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
WaveRestoreZoom {3800687810 ps} {3801344034 ps}
