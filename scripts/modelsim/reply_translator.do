onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /tb_reply_translator/dut/rst_i
add wave -noupdate -format Logic /tb_reply_translator/dut/clk_i
add wave -noupdate -format Logic /tb_reply_translator/dut/stop_err_rdy
add wave -noupdate -format Logic /tb_reply_translator/dut/arb_fsm_ack
add wave -noupdate -format Logic /tb_reply_translator/dut/fibre_fsm_busy
add wave -noupdate -format Literal /tb_reply_translator/dut/arb_current_state
add wave -noupdate -format Literal /tb_reply_translator/dut/arb_next_state
add wave -noupdate -format Literal /tb_reply_translator/dut/fibre_current_state
add wave -noupdate -format Literal /tb_reply_translator/dut/fibre_next_state
add wave -noupdate -format Literal /tb_reply_translator/dut/local_current_state
add wave -noupdate -format Literal /tb_reply_translator/dut/local_next_state
add wave -noupdate -format Logic /tb_reply_translator/dut/cmd_rcvd_er_i
add wave -noupdate -format Logic /tb_reply_translator/dut/cmd_rcvd_ok_i
add wave -noupdate -format Literal -radix hexadecimal /tb_reply_translator/dut/cmd_code_i
add wave -noupdate -format Literal -radix hexadecimal /tb_reply_translator/dut/card_id_i
add wave -noupdate -format Literal -radix hexadecimal /tb_reply_translator/dut/param_id_i
add wave -noupdate -format Logic /tb_reply_translator/dut/m_op_done_i
add wave -noupdate -format Logic /tb_reply_translator/dut/m_op_ok_ner_i
add wave -noupdate -format Logic /tb_reply_translator/dut/reply_ndata_i
add wave -noupdate -format Literal -radix hexadecimal /tb_reply_translator/dut/fibre_word_i
add wave -noupdate -format Literal /tb_reply_translator/dut/fibre_word_count
add wave -noupdate -format Literal -radix hexadecimal /tb_reply_translator/dut/num_fibre_words_i
add wave -noupdate -format Logic /tb_reply_translator/dut/fibre_word_req_o
add wave -noupdate -format Logic /tb_reply_translator/dut/ena_fibre_count
add wave -noupdate -format Logic /tb_reply_translator/dut/rst_fibre_count
add wave -noupdate -format Literal -radix hexadecimal /tb_reply_translator/dut/fibre_byte
add wave -noupdate -format Logic /tb_reply_translator/dut/m_op_ack_o
add wave -noupdate -format Logic /tb_reply_translator/dut/tx_ff_i
add wave -noupdate -color {Orange Red} -format Logic -itemcolor Yellow /tb_reply_translator/dut/tx_fw_o
add wave -noupdate -color {Orange Red} -format Literal -itemcolor Yellow -radix hexadecimal /tb_reply_translator/dut/txd_o
add wave -noupdate -format Logic /tb_reply_translator/dut/ena_checksum
add wave -noupdate -format Literal -radix hexadecimal /tb_reply_translator/dut/checksum
add wave -noupdate -format Literal -radix hexadecimal /tb_reply_translator/dut/checksum_in
add wave -noupdate -format Literal -radix hexadecimal /tb_reply_translator/dut/packet_header3_0
add wave -noupdate -format Literal -radix hexadecimal /tb_reply_translator/dut/packet_header3_1
add wave -noupdate -format Literal -radix hexadecimal /tb_reply_translator/dut/packet_header3_2
add wave -noupdate -format Literal -radix hexadecimal /tb_reply_translator/dut/packet_header3_3
add wave -noupdate -format Literal -radix hexadecimal /tb_reply_translator/dut/packet_header4_0
add wave -noupdate -format Literal -radix hexadecimal /tb_reply_translator/dut/packet_header4_1
add wave -noupdate -format Literal -radix hexadecimal /tb_reply_translator/dut/packet_header4_2
add wave -noupdate -format Literal -radix hexadecimal /tb_reply_translator/dut/packet_header4_3
add wave -noupdate -format Literal -radix hexadecimal /tb_reply_translator/dut/reply_word1_0
add wave -noupdate -format Literal -radix hexadecimal /tb_reply_translator/dut/reply_word1_1
add wave -noupdate -format Literal -radix hexadecimal /tb_reply_translator/dut/reply_word1_2
add wave -noupdate -format Literal -radix hexadecimal /tb_reply_translator/dut/reply_word1_3
add wave -noupdate -format Literal -radix hexadecimal /tb_reply_translator/dut/reply_word2_0
add wave -noupdate -format Literal -radix hexadecimal /tb_reply_translator/dut/reply_word2_1
add wave -noupdate -format Literal -radix hexadecimal /tb_reply_translator/dut/reply_word2_2
add wave -noupdate -format Literal -radix hexadecimal /tb_reply_translator/dut/reply_word2_3
add wave -noupdate -format Literal -radix hexadecimal /tb_reply_translator/dut/wordn_0
add wave -noupdate -format Literal -radix hexadecimal /tb_reply_translator/dut/wordn_1
add wave -noupdate -format Literal -radix hexadecimal /tb_reply_translator/dut/wordn_2
add wave -noupdate -format Literal -radix hexadecimal /tb_reply_translator/dut/wordn_3
add wave -noupdate -format Literal -radix hexadecimal /tb_reply_translator/dut/checksum_in_mux
add wave -noupdate -format Literal -radix hexadecimal /tb_reply_translator/dut/checksum_load
add wave -noupdate -format Logic /tb_reply_translator/dut/checksum_in_mux_sel
add wave -noupdate -format Logic /tb_reply_translator/dut/packet_header3_0mux_sel
add wave -noupdate -format Logic /tb_reply_translator/dut/packet_header3_1mux_sel
add wave -noupdate -format Logic /tb_reply_translator/dut/packet_header3_2mux_sel
add wave -noupdate -format Logic /tb_reply_translator/dut/packet_header3_3mux_sel
add wave -noupdate -format Logic /tb_reply_translator/dut/packet_header4_0mux_sel
add wave -noupdate -format Logic /tb_reply_translator/dut/packet_header4_1mux_sel
add wave -noupdate -format Logic /tb_reply_translator/dut/packet_header4_2mux_sel
add wave -noupdate -format Logic /tb_reply_translator/dut/packet_header4_3mux_sel
add wave -noupdate -format Logic /tb_reply_translator/dut/reply_word1_0mux_sel
add wave -noupdate -format Logic /tb_reply_translator/dut/reply_word1_1mux_sel
add wave -noupdate -format Logic /tb_reply_translator/dut/reply_word1_2mux_sel
add wave -noupdate -format Logic /tb_reply_translator/dut/reply_word1_3mux_sel
add wave -noupdate -format Logic /tb_reply_translator/dut/reply_word2_0mux_sel
add wave -noupdate -format Logic /tb_reply_translator/dut/reply_word2_1mux_sel
add wave -noupdate -format Logic /tb_reply_translator/dut/reply_word2_2mux_sel
add wave -noupdate -format Logic /tb_reply_translator/dut/reply_word2_3mux_sel
add wave -noupdate -format Logic /tb_reply_translator/dut/wordn_0mux_sel
add wave -noupdate -format Logic /tb_reply_translator/dut/wordn_1mux_sel
add wave -noupdate -format Logic /tb_reply_translator/dut/wordn_2mux_sel
add wave -noupdate -format Logic /tb_reply_translator/dut/wordn_3mux_sel
add wave -noupdate -format Literal -radix hexadecimal /tb_reply_translator/dut/packet_header3_0mux
add wave -noupdate -format Literal -radix hexadecimal /tb_reply_translator/dut/packet_header3_1mux
add wave -noupdate -format Literal -radix hexadecimal /tb_reply_translator/dut/packet_header3_2mux
add wave -noupdate -format Literal -radix hexadecimal /tb_reply_translator/dut/packet_header3_3mux
add wave -noupdate -format Literal -radix hexadecimal /tb_reply_translator/dut/packet_header4_0mux
add wave -noupdate -format Literal -radix hexadecimal /tb_reply_translator/dut/packet_header4_1mux
add wave -noupdate -format Literal -radix hexadecimal /tb_reply_translator/dut/packet_header4_2mux
add wave -noupdate -format Literal -radix hexadecimal /tb_reply_translator/dut/packet_header4_3mux
add wave -noupdate -format Literal -radix hexadecimal /tb_reply_translator/dut/reply_word1_0mux
add wave -noupdate -format Literal -radix hexadecimal /tb_reply_translator/dut/reply_word1_1mux
add wave -noupdate -format Literal -radix hexadecimal /tb_reply_translator/dut/reply_word1_2mux
add wave -noupdate -format Literal -radix hexadecimal /tb_reply_translator/dut/reply_word1_3mux
add wave -noupdate -format Literal -radix hexadecimal /tb_reply_translator/dut/reply_word2_0mux
add wave -noupdate -format Literal -radix hexadecimal /tb_reply_translator/dut/reply_word2_1mux
add wave -noupdate -format Literal -radix hexadecimal /tb_reply_translator/dut/reply_word2_2mux
add wave -noupdate -format Literal -radix hexadecimal /tb_reply_translator/dut/reply_word2_3mux
add wave -noupdate -format Literal -radix hexadecimal /tb_reply_translator/dut/wordn_0mux
add wave -noupdate -format Literal -radix hexadecimal /tb_reply_translator/dut/wordn_1mux
add wave -noupdate -format Literal -radix hexadecimal /tb_reply_translator/dut/wordn_2mux
add wave -noupdate -format Literal -radix hexadecimal /tb_reply_translator/dut/wordn_3mux
add wave -noupdate -format Literal -radix hexadecimal /tb_reply_translator/dut/packet_size
add wave -noupdate -format Literal -radix hexadecimal /tb_reply_translator/dut/reply_status
add wave -noupdate -format Literal -radix hexadecimal /tb_reply_translator/dut/reply_data
add wave -noupdate -format Literal -radix hexadecimal /tb_reply_translator/dut/packet_type
add wave -noupdate -format Logic /tb_reply_translator/dut/m_op_done_reply
add wave -noupdate -format Logic /tb_reply_translator/dut/m_op_done_data
add wave -noupdate -format Logic /tb_reply_translator/dut/rst_checksum
add wave -noupdate -format Logic /tb_reply_translator/dut/write_fifo
add wave -noupdate -format Literal /tb_reply_translator/dut/reply_size
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1593 ns} 0}
WaveRestoreZoom {40049 ns} {40851 ns}
configure wave -namecolwidth 276
configure wave -valuecolwidth 138
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
