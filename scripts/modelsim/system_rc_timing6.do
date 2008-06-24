onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic -label {clk (50 MHz)} -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/clk_50_i
add wave -noupdate -format Logic -label row_switch -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/row_switch_i
add wave -noupdate -divider {Updating Feedback DAC}
add wave -noupdate -color gold -format Logic -itemcolor gold -label {Flux Jumping Enable} /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/flux_jumping_en_i
add wave -noupdate -format Literal -label FB_DAC_data -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/dac_fb1_dat
add wave -noupdate -color Salmon -format Logic -itemcolor Coral -label FB_DAC_clk /tb_cc_rcs_bcs_ac/i_readout_card1/dac_fb_clk(0)
add wave -noupdate -format Literal -label {Row (used for FB DAC values)} -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch1/i_fsfb_calc/i_fsfb_io_controller/ctrl_rd_addr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Row Select 6 asserted by Address Card} {1042759309 ps} 0} {{Row Select 7 asserted by Address Card} {1044039999 ps} 0}
configure wave -namecolwidth 190
configure wave -valuecolwidth 40
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
WaveRestoreZoom {1042567466 ps} {1044443351 ps}
