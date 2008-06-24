onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider Timing
add wave -noupdate -color cyan -format Logic -height 15 -itemcolor cyan -label {Row Select (supplied by Address Card)} -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/dac_clk(0)
add wave -noupdate -format Logic -label {clk (50 MHz)} -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/clk_50_i
add wave -noupdate -format Logic -label {Address_Return_to_Zero (restart_frame)} -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/restart_frame_aligned_i
add wave -noupdate -format Logic -label row_switch -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/row_switch_i
add wave -noupdate -divider {Updating FB DAC}
add wave -noupdate -format Literal -label FB_DAC_data -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/dac_fb1_dat
add wave -noupdate -format Logic -label FB_DAC_clk /tb_cc_rcs_bcs_ac/i_readout_card1/dac_fb_clk(0)
add wave -noupdate -format Literal -label {Row (used for FB DAC values)} -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch1/i_fsfb_calc/i_fsfb_io_controller/ctrl_rd_addr
add wave -noupdate -divider {Coadding ADC Samples}
add wave -noupdate -format Logic -label {Start Coadding ADC Samples} -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_adc_sample_coadd/adc_coadd_en_i
add wave -noupdate -format Logic -label {ADC Latency} -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_adc_sample_coadd/adc_coadd_en_4delay
add wave -noupdate -format Logic -label {Coadding Done} -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_adc_sample_coadd/coadd_done_o
add wave -noupdate -format Literal -label {Row (used during Coadding)} -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_adc_sample_coadd/adc_offset_adr_o
add wave -noupdate -divider {Calculating FB (to be applied during next row visit)}
add wave -noupdate -format Logic -label {Calculated FB ready} -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/i_fsfb_processor/fsfb_proc_update_o
add wave -noupdate -format Literal -label {Calculated FB} -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/i_fsfb_processor/fsfb_proc_dat_o
add wave -noupdate -format Literal -label {Filtered FB} -radix unsigned /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/fsfb_fltr_dat_o
add wave -noupdate -format Logic -label {Filtered FB ready} -radix unsigned /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/fsfb_fltr_dat_rdy_o
add wave -noupdate -format Literal -label {Row (used for calculating Feedback)} -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/p_addr_o
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {891757691 ps} 0} {{Cursor 2} {891359999 ps} 0}
configure wave -namecolwidth 267
configure wave -valuecolwidth 76
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
WaveRestoreZoom {891291994 ps} {892171941 ps}
