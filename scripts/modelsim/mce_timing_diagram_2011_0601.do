onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -label rst /tb_cc_rcs_bcs_ac/i_readout_card1/rst
add wave -noupdate -label {Clock Card / cmd } /tb_cc_rcs_bcs_ac/i_clk_card/addr
add wave -noupdate -label fibre_rx_data /tb_cc_rcs_bcs_ac/fibre_rx_data
add wave -noupdate -label {Command over Backplane (cmd)} /tb_cc_rcs_bcs_ac/i_clk_card/cmd
add wave -noupdate -divider {RC frame timing}
add wave -noupdate -color Gold -itemcolor Gold -label CLK /tb_cc_rcs_bcs_ac/i_addr_card/clk
add wave -noupdate -label row_len -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_frame_timing/row_len_o
add wave -noupdate -label {Sync over backplane } /tb_cc_rcs_bcs_ac/i_readout_card1/i_frame_timing/sync_i
add wave -noupdate -color Turquoise -itemcolor Turquoise -label Address-Return-to-Zero /tb_cc_rcs_bcs_ac/i_readout_card1/i_frame_timing/restart_frame_aligned_o
add wave -noupdate -label row_switch /tb_cc_rcs_bcs_ac/i_readout_card1/i_frame_timing/row_switch_o
add wave -noupdate -label clk_cycle_counter -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_frame_timing/row_count_o
add wave -noupdate -color Salmon -itemcolor salmon -label SQ1_FB_DAC_CLK /tb_cc_rcs_bcs_ac/i_readout_card1/dac_fb_clk
add wave -noupdate /tb_cc_rcs_bcs_ac/i_readout_card1/dac_fb1_dat
add wave -noupdate -label ADC_COADD /tb_cc_rcs_bcs_ac/i_readout_card1/adc_coadd_en
add wave -noupdate -color Orange -itemcolor Orange -label AC_SQ1_BIAS_DAC_CLK_0 /tb_cc_rcs_bcs_ac/i_addr_card/dac_clk(0)
add wave -noupdate -label AC_SQ1_BIAS_DAC_DATA0 /tb_cc_rcs_bcs_ac/i_addr_card/dac_data0
add wave -noupdate -color Orange -itemcolor Orange -label AC_SQ1_BIAS_DAC_CLK_32 /tb_cc_rcs_bcs_ac/i_addr_card/dac_clk(32)
add wave -noupdate -label BC_DAC0_sclk /tb_cc_rcs_bcs_ac/i_bias_card1/dac_sclk(0)
add wave -noupdate -label BC_DAC0_ncs /tb_cc_rcs_bcs_ac/i_bias_card1/dac_ncs(0)
add wave -noupdate -label BC_DAC0_data /tb_cc_rcs_bcs_ac/i_bias_card1/dac_data(0)
add wave -noupdate -divider {RC command}
add wave -noupdate -label {RC cmd} -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_dispatch/addr_o
add wave -noupdate -label {RC reply} -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_dispatch/dat_i
add wave -noupdate -label {RC cmd parameters} /tb_cc_rcs_bcs_ac/i_readout_card1/i_dispatch/dat_o
add wave -noupdate -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_dispatch/tga_o
add wave -noupdate -divider {RAW RAM}
add wave -noupdate -color Gold -itemcolor Gold -label CLK /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/rectangle_mode_ram/clock
add wave -noupdate -label wr_data /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/rectangle_mode_ram/data
add wave -noupdate -label rd_data /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/rectangle_mode_ram/q
add wave -noupdate -label rdaddress -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/rectangle_mode_ram/rdaddress
add wave -noupdate -label wraddress /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/rectangle_mode_ram/wraddress
add wave -noupdate -label wren /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/rectangle_mode_ram/wren
add wave -noupdate -divider {Flux-Loop raw current state}
add wave -noupdate -label current_state /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/current_state
add wave -noupdate -divider {frame data raw signals}
add wave -noupdate /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_wbs_frame_data/raw_ack_i
add wave -noupdate /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_wbs_frame_data/raw_addr
add wave -noupdate /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_wbs_frame_data/raw_addr_clr
add wave -noupdate -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_wbs_frame_data/raw_addr_o
add wave -noupdate /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_wbs_frame_data/raw_addr_offset
add wave -noupdate /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_wbs_frame_data/raw_addr_save
add wave -noupdate /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_wbs_frame_data/raw_dat
add wave -noupdate /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_wbs_frame_data/raw_dat_i
add wave -noupdate /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_wbs_frame_data/raw_req
add wave -noupdate /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_wbs_frame_data/raw_req_o
add wave -noupdate -divider {ADC data}
add wave -noupdate -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/adc_dat
add wave -noupdate -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/adc_dat_ch0_i
add wave -noupdate /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/adc_dat_ch1_i
add wave -noupdate /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/adc_dat_ch2_i
add wave -noupdate /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/adc_dat_ch3_i
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {13433440000 ps} 0} {Trace {332718891 ps} 0}
configure wave -namecolwidth 303
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
configure wave -timelineunits ps
update
WaveRestoreZoom {332446928 ps} {333096985 ps}
