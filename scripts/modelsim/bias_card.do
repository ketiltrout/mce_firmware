onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -color {Medium Orchid} -format Logic -label lvds_cmd /tb_cc_rcs_bcs_ac/i_bias_card1/lvds_cmd
add wave -noupdate -color {Medium Orchid} -format Logic -label lvds_reply /tb_cc_rcs_bcs_ac/i_bias_card1/lvds_txa
add wave -noupdate -color Blue -format Logic -label {Start of a frame} /tb_cc_rcs_bcs_ac/i_bias_card1/frame_timing_slave/restart_frame_aligned_o
add wave -noupdate -color Blue -format Logic -label Update_bias /tb_cc_rcs_bcs_ac/i_bias_card1/update_bias
add wave -noupdate -color {Blue Violet} -format Logic -height 15 -label DAC31_ncs /tb_cc_rcs_bcs_ac/i_bias_card1/dac_ncs(31)
add wave -noupdate -color {Blue Violet} -format Logic -height 15 -label DAC30_ncs /tb_cc_rcs_bcs_ac/i_bias_card1/dac_ncs(30)
add wave -noupdate -color {Blue Violet} -format Logic -height 15 -label DAC29_ncs /tb_cc_rcs_bcs_ac/i_bias_card1/dac_ncs(29)
add wave -noupdate -color {Blue Violet} -format Logic -height 15 -label DAC28_ncs /tb_cc_rcs_bcs_ac/i_bias_card1/dac_ncs(28)
add wave -noupdate -color {Blue Violet} -format Logic -height 15 -label DAC2_ncs /tb_cc_rcs_bcs_ac/i_bias_card1/dac_ncs(2)
add wave -noupdate -color {Blue Violet} -format Logic -height 15 -label DAC1_ncs /tb_cc_rcs_bcs_ac/i_bias_card1/dac_ncs(1)
add wave -noupdate -color {Sea Green} -format Logic -height 15 -label DAC0_ncs /tb_cc_rcs_bcs_ac/i_bias_card1/dac_ncs(0)
add wave -noupdate -color {Sea Green} -format Logic -label DAC0_data /tb_cc_rcs_bcs_ac/i_bias_card1/dac_data(0)
add wave -noupdate -color {Sea Green} -format Logic -height 15 -label DAC0_sclk /tb_cc_rcs_bcs_ac/i_bias_card1/dac_sclk(0)
TreeUpdate [SetDefaultTree]
configure wave -namecolwidth 119
configure wave -valuecolwidth 38
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
WaveRestoreZoom {141452818 ps} {252264615 ps}
