onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider Globals
add wave -noupdate -format Logic /tb_wbs_frame_data/i_wbs_frame_data/rst_i
add wave -noupdate -format Logic /tb_wbs_frame_data/i_wbs_frame_data/clk_i
add wave -noupdate -divider {Wishbone Interface}
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/dat_i
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/addr_i
add wave -noupdate -format Logic /tb_wbs_frame_data/i_wbs_frame_data/we_i
add wave -noupdate -format Logic /tb_wbs_frame_data/i_wbs_frame_data/stb_i
add wave -noupdate -format Logic /tb_wbs_frame_data/i_wbs_frame_data/cyc_i
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/dat_o
add wave -noupdate -format Logic /tb_wbs_frame_data/i_wbs_frame_data/ack_o
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/wbm_dat_reg
add wave -noupdate -divider {wishbone actions}
add wave -noupdate -format Logic /tb_wbs_frame_data/i_wbs_frame_data/write_data_mode
add wave -noupdate -format Logic /tb_wbs_frame_data/i_wbs_frame_data/read_ret_data
add wave -noupdate -format Logic /tb_wbs_frame_data/i_wbs_frame_data/write_captr_raw
add wave -noupdate -format Logic /tb_wbs_frame_data/i_wbs_frame_data/read_data_mode
add wave -noupdate -format Logic /tb_wbs_frame_data/i_wbs_frame_data/write_ret_data
add wave -noupdate -format Logic /tb_wbs_frame_data/i_wbs_frame_data/read_captr_raw
add wave -noupdate -divider {Internal Signals}
add wave -noupdate -format Logic /tb_wbs_frame_data/i_wbs_frame_data/instr_done
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/data_mode_reg
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/data_mode
add wave -noupdate -format Logic /tb_wbs_frame_data/i_wbs_frame_data/data_mode_mux_sel
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/wbs_data
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/filtered_dat
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/unfiltered_dat
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/fb_error_dat
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/raw_dat
add wave -noupdate -format Literal /tb_wbs_frame_data/i_wbs_frame_data/dat_out_mux_sel
add wave -noupdate -format Literal -radix unsigned /tb_wbs_frame_data/i_wbs_frame_data/pix_addr_cnt
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/pix_address
add wave -noupdate -format Literal /tb_wbs_frame_data/i_wbs_frame_data/ch_mux_sel
add wave -noupdate -format Literal /tb_wbs_frame_data/i_wbs_frame_data/raw_addr_cnt
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/raw_address
add wave -noupdate -format Literal /tb_wbs_frame_data/i_wbs_frame_data/raw_ch_mux_sel
add wave -noupdate -format Logic /tb_wbs_frame_data/i_wbs_frame_data/raw_req
add wave -noupdate -format Logic /tb_wbs_frame_data/i_wbs_frame_data/raw_ack
add wave -noupdate -format Logic /tb_wbs_frame_data/i_wbs_frame_data/dat_rdy
add wave -noupdate -format Literal /tb_wbs_frame_data/i_wbs_frame_data/current_state
add wave -noupdate -format Literal /tb_wbs_frame_data/i_wbs_frame_data/next_state
add wave -noupdate -format Logic /tb_wbs_frame_data/i_wbs_frame_data/inc_addr_ena
add wave -noupdate -format Logic /tb_wbs_frame_data/i_wbs_frame_data/dec_addr_ena
add wave -noupdate -format Logic /tb_wbs_frame_data/i_wbs_frame_data/rst_addr_ena
add wave -noupdate -divider {FLC interfaces}
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/filtered_addr_ch0_o
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/filtered_dat_ch0_i
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/fsfb_addr_ch0_o
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/fsfb_dat_ch0_i
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/coadded_addr_ch0_o
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/coadded_dat_ch0_i
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/raw_addr_ch0_o
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/raw_dat_ch0_i
add wave -noupdate -format Logic /tb_wbs_frame_data/i_wbs_frame_data/raw_req_ch0_o
add wave -noupdate -format Logic /tb_wbs_frame_data/i_wbs_frame_data/raw_ack_ch0_i
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/filtered_addr_ch1_o
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/filtered_dat_ch1_i
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/fsfb_addr_ch1_o
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/fsfb_dat_ch1_i
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/coadded_addr_ch1_o
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/coadded_dat_ch1_i
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/raw_addr_ch1_o
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/raw_dat_ch1_i
add wave -noupdate -format Logic /tb_wbs_frame_data/i_wbs_frame_data/raw_req_ch1_o
add wave -noupdate -format Logic /tb_wbs_frame_data/i_wbs_frame_data/raw_ack_ch1_i
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/filtered_addr_ch2_o
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/filtered_dat_ch2_i
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/fsfb_addr_ch2_o
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/fsfb_dat_ch2_i
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/coadded_addr_ch2_o
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/coadded_dat_ch2_i
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/raw_addr_ch2_o
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/raw_dat_ch2_i
add wave -noupdate -format Logic /tb_wbs_frame_data/i_wbs_frame_data/raw_req_ch2_o
add wave -noupdate -format Logic /tb_wbs_frame_data/i_wbs_frame_data/raw_ack_ch2_i
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/filtered_addr_ch3_o
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/filtered_dat_ch3_i
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/fsfb_addr_ch3_o
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/fsfb_dat_ch3_i
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/coadded_addr_ch3_o
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/coadded_dat_ch3_i
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/raw_addr_ch3_o
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/raw_dat_ch3_i
add wave -noupdate -format Logic /tb_wbs_frame_data/i_wbs_frame_data/raw_req_ch3_o
add wave -noupdate -format Logic /tb_wbs_frame_data/i_wbs_frame_data/raw_ack_ch3_i
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/filtered_addr_ch4_o
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/filtered_dat_ch4_i
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/fsfb_addr_ch4_o
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/fsfb_dat_ch4_i
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/coadded_addr_ch4_o
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/coadded_dat_ch4_i
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/raw_addr_ch4_o
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/raw_dat_ch4_i
add wave -noupdate -format Logic /tb_wbs_frame_data/i_wbs_frame_data/raw_req_ch4_o
add wave -noupdate -format Logic /tb_wbs_frame_data/i_wbs_frame_data/raw_ack_ch4_i
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/filtered_addr_ch5_o
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/filtered_dat_ch5_i
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/fsfb_addr_ch5_o
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/fsfb_dat_ch5_i
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/coadded_addr_ch5_o
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/coadded_dat_ch5_i
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/raw_addr_ch5_o
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/raw_dat_ch5_i
add wave -noupdate -format Logic /tb_wbs_frame_data/i_wbs_frame_data/raw_req_ch5_o
add wave -noupdate -format Logic /tb_wbs_frame_data/i_wbs_frame_data/raw_ack_ch5_i
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/filtered_addr_ch6_o
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/filtered_dat_ch6_i
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/fsfb_addr_ch6_o
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/fsfb_dat_ch6_i
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/coadded_addr_ch6_o
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/coadded_dat_ch6_i
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/raw_addr_ch6_o
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/raw_dat_ch6_i
add wave -noupdate -format Logic /tb_wbs_frame_data/i_wbs_frame_data/raw_req_ch6_o
add wave -noupdate -format Logic /tb_wbs_frame_data/i_wbs_frame_data/raw_ack_ch6_i
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/filtered_addr_ch7_o
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/filtered_dat_ch7_i
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/fsfb_addr_ch7_o
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/fsfb_dat_ch7_i
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/coadded_addr_ch7_o
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/coadded_dat_ch7_i
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/raw_addr_ch7_o
add wave -noupdate -format Literal -radix hexadecimal /tb_wbs_frame_data/i_wbs_frame_data/raw_dat_ch7_i
add wave -noupdate -format Logic /tb_wbs_frame_data/i_wbs_frame_data/raw_req_ch7_o
add wave -noupdate -format Logic /tb_wbs_frame_data/i_wbs_frame_data/raw_ack_ch7_i
add wave -noupdate -divider {FLC sim}
add wave -noupdate -format Logic /tb_wbs_frame_data/i_tb_wbs_frame_data_flc_sim/rst_i
add wave -noupdate -format Logic /tb_wbs_frame_data/i_tb_wbs_frame_data_flc_sim/clk_i
add wave -noupdate -format Logic /tb_wbs_frame_data/i_tb_wbs_frame_data_flc_sim/raw_req_ch0_i
add wave -noupdate -format Logic /tb_wbs_frame_data/i_tb_wbs_frame_data_flc_sim/raw_req_ch1_i
add wave -noupdate -format Logic /tb_wbs_frame_data/i_tb_wbs_frame_data_flc_sim/raw_req_ch2_i
add wave -noupdate -format Logic /tb_wbs_frame_data/i_tb_wbs_frame_data_flc_sim/raw_req_ch3_i
add wave -noupdate -format Logic /tb_wbs_frame_data/i_tb_wbs_frame_data_flc_sim/raw_req_ch4_i
add wave -noupdate -format Logic /tb_wbs_frame_data/i_tb_wbs_frame_data_flc_sim/raw_req_ch5_i
add wave -noupdate -format Logic /tb_wbs_frame_data/i_tb_wbs_frame_data_flc_sim/raw_req_ch6_i
add wave -noupdate -format Logic /tb_wbs_frame_data/i_tb_wbs_frame_data_flc_sim/raw_req_ch7_i
add wave -noupdate -format Logic /tb_wbs_frame_data/i_tb_wbs_frame_data_flc_sim/raw_ack_ch0_o
add wave -noupdate -format Logic /tb_wbs_frame_data/i_tb_wbs_frame_data_flc_sim/raw_ack_ch1_o
add wave -noupdate -format Logic /tb_wbs_frame_data/i_tb_wbs_frame_data_flc_sim/raw_ack_ch2_o
add wave -noupdate -format Logic /tb_wbs_frame_data/i_tb_wbs_frame_data_flc_sim/raw_ack_ch3_o
add wave -noupdate -format Logic /tb_wbs_frame_data/i_tb_wbs_frame_data_flc_sim/raw_ack_ch4_o
add wave -noupdate -format Logic /tb_wbs_frame_data/i_tb_wbs_frame_data_flc_sim/raw_ack_ch5_o
add wave -noupdate -format Logic /tb_wbs_frame_data/i_tb_wbs_frame_data_flc_sim/raw_ack_ch6_o
add wave -noupdate -format Logic /tb_wbs_frame_data/i_tb_wbs_frame_data_flc_sim/raw_req_all
add wave -noupdate -format Logic /tb_wbs_frame_data/i_tb_wbs_frame_data_flc_sim/raw_ack_all
add wave -noupdate -format Literal /tb_wbs_frame_data/i_tb_wbs_frame_data_flc_sim/current_state
add wave -noupdate -format Literal /tb_wbs_frame_data/i_tb_wbs_frame_data_flc_sim/next_state
add wave -noupdate -format Literal /tb_wbs_frame_data/i_tb_wbs_frame_data_flc_sim/wait_count
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1149 ns} 0}
WaveRestoreZoom {874135 ns} {874436 ns}
configure wave -namecolwidth 375
configure wave -valuecolwidth 84
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
