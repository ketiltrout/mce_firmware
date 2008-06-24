onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/initialize_window_i
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_addr_card/lvds_sync
add wave -noupdate -format Logic -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/rst_i
add wave -noupdate -format Logic -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/clk_50_i
add wave -noupdate -format Logic -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/restart_frame_aligned_i
add wave -noupdate -format Logic -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/restart_frame_1row_post_i
add wave -noupdate -color cyan -format Logic -height 15 -itemcolor cyan -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/dac_clk(0)
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/dac_fb1_dat
add wave -noupdate -format Logic -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/row_switch_i
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_readout_card1/dac_fb_clk(0)
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch1/i_fsfb_calc/i_fsfb_io_controller/ctrl_rd_addr
add wave -noupdate -divider coadding
add wave -noupdate -format Logic -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_adc_sample_coadd/adc_coadd_en_i
add wave -noupdate -format Logic -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_adc_sample_coadd/adc_coadd_en_4delay
add wave -noupdate -format Logic -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_adc_sample_coadd/adc_coadd_en_5delay
add wave -noupdate -format Logic -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_adc_sample_coadd/coadd_done_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/i_fsfb_processor/fsfb_proc_update_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/i_fsfb_processor/fsfb_proc_dat_o
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/p_addr_o
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_adc_sample_coadd/adc_offset_adr_o
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_adc_sample_coadd/samples_coadd_reg
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_adc_sample_coadd/current_coadd_dat_o
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_adc_sample_coadd/current_diff_dat_o
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_adc_sample_coadd/current_integral_dat_o
add wave -noupdate -divider fsfb_corr
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/fsfb_ctrl_lock_en0_i
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/fsfb_ctrl_dat0_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/fsfb_ctrl_dat_rdy0_i
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/fsfb_ctrl_dat0_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/fsfb_ctrl_dat_rdy0
add wave -noupdate -divider fsfb_ctrl
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_ctrl/dac_dat_en_i
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_ctrl/fsfb_ctrl_dat_i
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_ctrl/dac_dat_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_ctrl/fsfb_ctrl_dat_rdy_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_ctrl/dac_clk_o
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_ctrl/fsfb_ctrl_dat
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch1/i_fsfb_calc/i_fsfb_io_controller/ctrl_dat_rdy
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_ctrl/dac_dat
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_ctrl/rdy_to_clk_dac
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_ctrl/dac_clk
add wave -noupdate -format Logic -height 15 -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/dac_clk(6)
add wave -noupdate -format Logic -height 15 -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/dac_clk(5)
add wave -noupdate -format Logic -height 15 -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/dac_clk(4)
add wave -noupdate -format Logic -height 15 -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/dac_clk(3)
add wave -noupdate -format Logic -height 15 -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/dac_clk(2)
add wave -noupdate -format Logic -height 15 -radix hexadecimal /tb_cc_rcs_bcs_ac/i_addr_card/dac_clk(1)
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2079479999 ps} 0} {{Cursor 2} {2079601799 ps} 0}
configure wave -namecolwidth 380
configure wave -valuecolwidth 127
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
WaveRestoreZoom {2079370351 ps} {2080127724 ps}
