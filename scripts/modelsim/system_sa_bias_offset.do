onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/offset_dac_ncs
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/offset_dac_spi_ch0
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/offset_dac_spi_ch1
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/offset_dac_spi_ch2
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/offset_dac_spi_ch3
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/offset_dac_spi_ch4
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/offset_dac_spi_ch5
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/offset_dac_spi_ch6
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/offset_dac_spi_ch7
add wave -noupdate -divider sa_bias
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/sa_bias_dac_spi_ch0
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/sa_bias_dac_spi_ch1
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/sa_bias_dac_spi_ch2
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/sa_bias_dac_spi_ch3
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/sa_bias_dac_spi_ch4
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/sa_bias_dac_spi_ch5
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/sa_bias_dac_spi_ch6
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/sa_bias_dac_spi_ch7
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/bias_dac_ncs
add wave -noupdate -divider dispatch
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/dispatch_ack_in
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/dispatch_addr_out
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/dispatch_cyc_out
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/dispatch_dat_in
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/dispatch_dat_out
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/dispatch_err_in
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/dispatch_stb_out
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/dispatch_tga_out
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/dispatch_we_out
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/clk
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_readout_card1/i_frame_timing/restart_frame_aligned_o
add wave -noupdate -divider wbs_fb_data
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_wbs_fb_data/i_misc_banks_admin/offset_dat_rdy
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_wbs_fb_data/i_misc_banks_admin/offset_dat_rdy_ch0_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_wbs_fb_data/i_misc_banks_admin/sa_bias_ch0_o
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_wbs_fb_data/i_misc_banks_admin/sa_bias_rdy
add wave -noupdate -divider sa_bias
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_sa_bias_ctrl/rst_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_sa_bias_ctrl/clk_25_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_sa_bias_ctrl/clk_50_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_sa_bias_ctrl/restart_frame_aligned_i
add wave -noupdate -color salmon -format Logic -itemcolor salmon -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_sa_bias_ctrl/sa_bias_dat_rdy_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_sa_bias_ctrl/sa_bias_dat_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_sa_bias_ctrl/sa_bias_dac_spi_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_sa_bias_ctrl/spi_write_start
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_sa_bias_ctrl/spi_csb
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_sa_bias_ctrl/spi_sclk
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_sa_bias_ctrl/spi_sdat
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_sa_bias_ctrl/update_frame_aligned
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_sa_bias_ctrl/update_pending
add wave -noupdate -divider offset
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_offset_ctrl/rst_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_offset_ctrl/clk_25_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_offset_ctrl/clk_50_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_offset_ctrl/restart_frame_aligned_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_offset_ctrl/offset_dat_rdy_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_offset_ctrl/offset_dat_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_offset_ctrl/offset_dac_spi_o
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_offset_ctrl/spi_write_start
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_offset_ctrl/spi_csb
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_offset_ctrl/spi_sclk
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_offset_ctrl/spi_sdat
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_offset_ctrl/update_frame_aligned
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_offset_ctrl/update_pending
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {506834510 ps} 0}
configure wave -namecolwidth 546
configure wave -valuecolwidth 51
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
WaveRestoreZoom {0 ps} {574770 ns}
