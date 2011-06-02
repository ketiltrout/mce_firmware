onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_cc_rcs_bcs_ac/i_readout_card1/rst_n
add wave -noupdate /tb_cc_rcs_bcs_ac/i_readout_card1/clk
add wave -noupdate /tb_cc_rcs_bcs_ac/i_readout_card1/dispatch_dat_out
add wave -noupdate /tb_cc_rcs_bcs_ac/i_readout_card1/dispatch_addr_out
add wave -noupdate /tb_cc_rcs_bcs_ac/i_readout_card1/dispatch_we_out
add wave -noupdate /tb_cc_rcs_bcs_ac/i_readout_card1/dispatch_tga_out
add wave -noupdate /tb_cc_rcs_bcs_ac/i_readout_card1/dispatch_dat_in
add wave -noupdate /tb_cc_rcs_bcs_ac/i_readout_card1/dispatch_ack_in
add wave -noupdate /tb_cc_rcs_bcs_ac/i_readout_card1/adc_coadd_en
add wave -noupdate /tb_cc_rcs_bcs_ac/i_readout_card1/restart_frame_aligned
add wave -noupdate /tb_cc_rcs_bcs_ac/i_readout_card1/initialize_window
add wave -noupdate /tb_cc_rcs_bcs_ac/i_readout_card1/fltr_rst
add wave -noupdate /tb_cc_rcs_bcs_ac/i_readout_card1/row_switch
add wave -noupdate -divider {filter calc}
add wave -noupdate /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/filter_coeff0_i
add wave -noupdate /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/filter_coeff1_i
add wave -noupdate /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/filter_coeff2_i
add wave -noupdate /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/filter_coeff3_i
add wave -noupdate /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/filter_coeff4_i
add wave -noupdate /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/filter_coeff5_i
add wave -noupdate -divider {Filter- pidz}
add wave -noupdate -expand /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/i_fsfb_processor/i_fsfb_proc_pidz/filter_b22_coef
add wave -noupdate /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/i_fsfb_processor/i_fsfb_proc_pidz/filter_b21_coef
add wave -noupdate /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/i_fsfb_processor/i_fsfb_proc_pidz/filter_b12_coef
add wave -noupdate /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/i_fsfb_processor/i_fsfb_proc_pidz/filter_b11_coef
add wave -noupdate /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/i_fsfb_processor/i_fsfb_proc_pidz/filter_coeff4_i
add wave -noupdate /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/i_fsfb_processor/i_fsfb_proc_pidz/filter_coeff5_i
add wave -noupdate /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_wbs_fb_data/i_misc_banks_admin/reg(29)
add wave -noupdate /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_wbs_fb_data/i_misc_banks_admin/reg(30)
add wave -noupdate /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_wbs_fb_data/i_misc_banks_admin/reg(31)
add wave -noupdate /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_wbs_fb_data/i_misc_banks_admin/reg(32)
add wave -noupdate /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_wbs_fb_data/i_misc_banks_admin/reg(33)
add wave -noupdate /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_wbs_fb_data/i_misc_banks_admin/reg(34)
add wave -noupdate /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_wbs_fb_data/i_misc_banks_admin/reg_temp(29)
add wave -noupdate /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_wbs_fb_data/i_misc_banks_admin/reg_temp(30)
add wave -noupdate /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_wbs_fb_data/i_misc_banks_admin/reg_temp(31)
add wave -noupdate /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_wbs_fb_data/i_misc_banks_admin/reg_temp(32)
add wave -noupdate /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_wbs_fb_data/i_misc_banks_admin/reg_temp(33)
add wave -noupdate /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_wbs_fb_data/i_misc_banks_admin/reg_temp(34)
add wave -noupdate /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_wbs_fb_data/i_misc_banks_admin/i_misc_bank(0)/i_reg/j
add wave -noupdate /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_wbs_fb_data/i_misc_banks_admin/i_misc_bank(29)/i_reg/j
add wave -noupdate /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_wbs_fb_data/i_misc_banks_admin/i_misc_bank(30)/i_reg/j
add wave -noupdate /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_wbs_fb_data/i_misc_banks_admin/rst_i
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {21917538 ps} 0}
configure wave -namecolwidth 338
configure wave -valuecolwidth 79
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
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {373967999 ps}
