onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_adc_sample_coadd/adc_dat_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_adc_sample_coadd/clk_50_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_adc_sample_coadd/rst_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_adc_sample_coadd/adc_coadd_en_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_adc_sample_coadd/restart_frame_1row_prev_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_adc_sample_coadd/restart_frame_aligned_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_adc_sample_coadd/row_switch_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_adc_sample_coadd/initialize_window_i
add wave -noupdate -format Literal -radix unsigned /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_adc_sample_coadd/coadded_addr_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_adc_sample_coadd/coadded_dat_o
add wave -noupdate -format Literal -radix unsigned /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_adc_sample_coadd/raw_addr_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_adc_sample_coadd/raw_dat_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_adc_sample_coadd/raw_req_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_adc_sample_coadd/raw_ack_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_adc_sample_coadd/coadd_done_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_adc_sample_coadd/current_coadd_dat_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_adc_sample_coadd/raw_dat
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_adc_sample_coadd/raw_dat_out
add wave -noupdate -format Literal -radix unsigned /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_adc_sample_coadd/raw_write_addr
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_adc_sample_coadd/clr_raw_addr_index
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_adc_sample_coadd/raw_wren
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_adc_sample_coadd/adc_coadd_en_5delay
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_adc_sample_coadd/adc_coadd_en_4delay
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_adc_sample_coadd/samples_coadd_reg
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_adc_sample_coadd/coadd_write_addr
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_adc_sample_coadd/clr_samples_coadd_reg
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_adc_sample_coadd/address_count_en
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_adc_sample_coadd/clr_address_count
add wave -noupdate -divider raw
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_wbs_frame_data/current_state
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_wbs_frame_data/cyc_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_wbs_frame_data/dat_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_wbs_frame_data/dat_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_wbs_frame_data/dat_rdy
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_wbs_frame_data/data_mode
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_wbs_frame_data/data_mode_wren
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_wbs_frame_data/pix_addr_clr
add wave -noupdate -format Literal -radix unsigned /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_wbs_frame_data/pix_address
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_wbs_frame_data/raw_ack
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_wbs_frame_data/raw_ack_ch0_i
add wave -noupdate -color gold -format Literal -itemcolor gold -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_wbs_frame_data/raw_addr_ch0_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_wbs_frame_data/raw_addr_clr
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_wbs_frame_data/inc_addr
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_wbs_frame_data/dec_raw_addr
add wave -noupdate -color salmon -format Literal -itemcolor salmon -radix unsigned /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_wbs_frame_data/raw_address
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_wbs_frame_data/raw_ch_mux_sel
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_wbs_frame_data/raw_ch_mux_sel_dly1
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_wbs_frame_data/raw_dat
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_wbs_frame_data/raw_req
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_wbs_frame_data/raw_req_ch0_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_wbs_frame_data/stb_i
add wave -noupdate -format Literal -radix unsigned /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_wbs_frame_data/tga_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_wbs_frame_data/wb_ack
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_wbs_frame_data/we_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_wbs_frame_data/addr_i
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {883557480 ps} 0}
configure wave -namecolwidth 427
configure wave -valuecolwidth 77
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
WaveRestoreZoom {605455101 ps} {2073397100 ps}
