onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Literal -label flux_fb_data_o -radix hexadecimal /tb_clk_bias_card/i_bias_card/bc_dac_ctrl_slave/flux_fb_data_o
add wave -noupdate -format Literal -label flux_fb_ncs_o -radix hexadecimal /tb_clk_bias_card/i_bias_card/bc_dac_ctrl_slave/flux_fb_ncs_o
add wave -noupdate -format Literal -label flux_fb_clk_o -radix hexadecimal /tb_clk_bias_card/i_bias_card/bc_dac_ctrl_slave/flux_fb_clk_o
add wave -noupdate -format Logic -label lvds_dac_data_o /tb_clk_bias_card/i_bias_card/bc_dac_ctrl_slave/bias_data_o
add wave -noupdate -format Logic -label lvds_dac_ncs_o /tb_clk_bias_card/i_bias_card/bc_dac_ctrl_slave/bias_ncs_o
add wave -noupdate -format Logic -label lvds_dac_clk_o /tb_clk_bias_card/i_bias_card/bc_dac_ctrl_slave/bias_clk_o
add wave -noupdate -format Logic /tb_clk_bias_card/i_bias_card/bc_dac_ctrl_slave/dac_nclr_o
add wave -noupdate -format Literal /tb_clk_bias_card/i_bias_card/bc_dac_ctrl_slave/dat_i
add wave -noupdate -format Literal /tb_clk_bias_card/i_bias_card/bc_dac_ctrl_slave/addr_i
add wave -noupdate -format Literal /tb_clk_bias_card/i_bias_card/bc_dac_ctrl_slave/tga_i
add wave -noupdate -format Logic /tb_clk_bias_card/i_bias_card/bc_dac_ctrl_slave/we_i
add wave -noupdate -format Logic /tb_clk_bias_card/i_bias_card/bc_dac_ctrl_slave/stb_i
add wave -noupdate -format Logic /tb_clk_bias_card/i_bias_card/bc_dac_ctrl_slave/cyc_i
add wave -noupdate -format Literal /tb_clk_bias_card/i_bias_card/bc_dac_ctrl_slave/dat_o
add wave -noupdate -format Logic /tb_clk_bias_card/i_bias_card/bc_dac_ctrl_slave/ack_o
add wave -noupdate -format Logic /tb_clk_bias_card/i_bias_card/bc_dac_ctrl_slave/update_bias_i
add wave -noupdate -format Logic /tb_clk_bias_card/i_bias_card/bc_dac_ctrl_slave/clk_i
add wave -noupdate -format Logic /tb_clk_bias_card/i_bias_card/bc_dac_ctrl_slave/mem_clk_i
add wave -noupdate -format Logic /tb_clk_bias_card/i_bias_card/bc_dac_ctrl_slave/rst_i
add wave -noupdate -format Literal -label flux_fb_addr /tb_clk_bias_card/i_bias_card/bc_dac_ctrl_slave/flux_fb_addr
add wave -noupdate -format Literal -label flux_fb_data /tb_clk_bias_card/i_bias_card/bc_dac_ctrl_slave/flux_fb_data
add wave -noupdate -format Literal -label bias_data /tb_clk_bias_card/i_bias_card/bc_dac_ctrl_slave/bias_data
add wave -noupdate -format Logic /tb_clk_bias_card/i_bias_card/bc_dac_ctrl_slave/flux_fb_changed
add wave -noupdate -format Logic /tb_clk_bias_card/i_bias_card/bc_dac_ctrl_slave/bias_changed
add wave -noupdate -divider Bias_card
add wave -noupdate -format Logic /tb_clk_bias_card/i_bias_card/clk
add wave -noupdate -format Logic /tb_clk_bias_card/i_bias_card/mem_clk
add wave -noupdate -format Logic /tb_clk_bias_card/i_bias_card/comm_clk
add wave -noupdate -format Logic /tb_clk_bias_card/i_bias_card/inclk
add wave -noupdate -format Logic /tb_clk_bias_card/i_bias_card/rst_n
add wave -noupdate -format Logic /tb_clk_bias_card/i_bias_card/lvds_cmd
add wave -noupdate -format Logic /tb_clk_bias_card/i_bias_card/lvds_sync
add wave -noupdate -format Logic /tb_clk_bias_card/i_bias_card/lvds_spare
add wave -noupdate -format Logic /tb_clk_bias_card/i_bias_card/lvds_txa
add wave -noupdate -format Logic /tb_clk_bias_card/i_bias_card/lvds_txb
add wave -noupdate -format Literal /tb_clk_bias_card/i_bias_card/ttl_nrx
add wave -noupdate -format Literal /tb_clk_bias_card/i_bias_card/ttl_tx
add wave -noupdate -format Literal /tb_clk_bias_card/i_bias_card/ttl_txena
add wave -noupdate -format Logic /tb_clk_bias_card/i_bias_card/eeprom_si
add wave -noupdate -format Logic /tb_clk_bias_card/i_bias_card/eeprom_so
add wave -noupdate -format Logic /tb_clk_bias_card/i_bias_card/eeprom_sck
add wave -noupdate -format Logic /tb_clk_bias_card/i_bias_card/eeprom_cs
add wave -noupdate -format Literal /tb_clk_bias_card/i_bias_card/dac_ncs
add wave -noupdate -format Literal /tb_clk_bias_card/i_bias_card/dac_sclk
add wave -noupdate -format Literal /tb_clk_bias_card/i_bias_card/dac_data
add wave -noupdate -format Logic /tb_clk_bias_card/i_bias_card/lvds_dac_ncs
add wave -noupdate -format Logic /tb_clk_bias_card/i_bias_card/lvds_dac_sclk
add wave -noupdate -format Logic /tb_clk_bias_card/i_bias_card/lvds_dac_data
add wave -noupdate -format Logic /tb_clk_bias_card/i_bias_card/dac_nclr
add wave -noupdate -format Logic /tb_clk_bias_card/i_bias_card/red_led
add wave -noupdate -format Logic /tb_clk_bias_card/i_bias_card/ylw_led
add wave -noupdate -format Logic /tb_clk_bias_card/i_bias_card/grn_led
add wave -noupdate -format Logic /tb_clk_bias_card/i_bias_card/dip_sw3
add wave -noupdate -format Logic /tb_clk_bias_card/i_bias_card/dip_sw4
add wave -noupdate -format Logic /tb_clk_bias_card/i_bias_card/wdog
add wave -noupdate -format Literal /tb_clk_bias_card/i_bias_card/slot_id
add wave -noupdate -format Literal /tb_clk_bias_card/i_bias_card/test
add wave -noupdate -format Literal /tb_clk_bias_card/i_bias_card/mictor
add wave -noupdate -format Literal /tb_clk_bias_card/i_bias_card/mictorclk
add wave -noupdate -format Logic /tb_clk_bias_card/i_bias_card/rs232_rx
add wave -noupdate -format Logic /tb_clk_bias_card/i_bias_card/rs232_tx
add wave -noupdate -format Logic /tb_clk_bias_card/i_bias_card/rst
add wave -noupdate -format Literal /tb_clk_bias_card/i_bias_card/data
add wave -noupdate -format Literal /tb_clk_bias_card/i_bias_card/addr
add wave -noupdate -format Literal /tb_clk_bias_card/i_bias_card/tga
add wave -noupdate -format Logic /tb_clk_bias_card/i_bias_card/we
add wave -noupdate -format Logic /tb_clk_bias_card/i_bias_card/stb
add wave -noupdate -format Logic /tb_clk_bias_card/i_bias_card/cyc
add wave -noupdate -format Literal /tb_clk_bias_card/i_bias_card/slave_data
add wave -noupdate -format Logic /tb_clk_bias_card/i_bias_card/slave_ack
add wave -noupdate -format Literal /tb_clk_bias_card/i_bias_card/led_data
add wave -noupdate -format Logic /tb_clk_bias_card/i_bias_card/led_ack
add wave -noupdate -format Literal /tb_clk_bias_card/i_bias_card/bc_dac_data
add wave -noupdate -format Logic /tb_clk_bias_card/i_bias_card/bc_dac_ack
add wave -noupdate -format Literal /tb_clk_bias_card/i_bias_card/frame_timing_data
add wave -noupdate -format Logic /tb_clk_bias_card/i_bias_card/frame_timing_ack
add wave -noupdate -format Logic /tb_clk_bias_card/i_bias_card/slave_err
add wave -noupdate -format Logic /tb_clk_bias_card/i_bias_card/update_bias
add wave -noupdate -divider clk_card
add wave -noupdate -format Logic /tb_clk_bias_card/i_clk_card/inclk
add wave -noupdate -format Logic /tb_clk_bias_card/i_clk_card/rst_n
add wave -noupdate -format Logic /tb_clk_bias_card/i_clk_card/lvds_cmd
add wave -noupdate -format Logic /tb_clk_bias_card/i_clk_card/lvds_sync
add wave -noupdate -format Logic /tb_clk_bias_card/i_clk_card/lvds_spare
add wave -noupdate -format Logic /tb_clk_bias_card/i_clk_card/lvds_clk
add wave -noupdate -format Logic /tb_clk_bias_card/i_clk_card/lvds_reply_ac_a
add wave -noupdate -format Logic /tb_clk_bias_card/i_clk_card/lvds_reply_ac_b
add wave -noupdate -format Logic /tb_clk_bias_card/i_clk_card/lvds_reply_bc1_a
add wave -noupdate -format Logic /tb_clk_bias_card/i_clk_card/lvds_reply_bc1_b
add wave -noupdate -format Logic /tb_clk_bias_card/i_clk_card/lvds_reply_bc2_a
add wave -noupdate -format Logic /tb_clk_bias_card/i_clk_card/lvds_reply_bc2_b
add wave -noupdate -format Logic /tb_clk_bias_card/i_clk_card/lvds_reply_bc3_a
add wave -noupdate -format Logic /tb_clk_bias_card/i_clk_card/lvds_reply_bc3_b
add wave -noupdate -format Logic /tb_clk_bias_card/i_clk_card/lvds_reply_rc1_a
add wave -noupdate -format Logic /tb_clk_bias_card/i_clk_card/lvds_reply_rc1_b
add wave -noupdate -format Logic /tb_clk_bias_card/i_clk_card/lvds_reply_rc2_a
add wave -noupdate -format Logic /tb_clk_bias_card/i_clk_card/lvds_reply_rc2_b
add wave -noupdate -format Logic /tb_clk_bias_card/i_clk_card/lvds_reply_rc3_a
add wave -noupdate -format Logic /tb_clk_bias_card/i_clk_card/lvds_reply_rc3_b
add wave -noupdate -format Logic /tb_clk_bias_card/i_clk_card/lvds_reply_rc4_a
add wave -noupdate -format Logic /tb_clk_bias_card/i_clk_card/lvds_reply_rc4_b
add wave -noupdate -format Logic /tb_clk_bias_card/i_clk_card/dv_pulse_fibre
add wave -noupdate -format Logic /tb_clk_bias_card/i_clk_card/dv_pulse_bnc
add wave -noupdate -format Logic /tb_clk_bias_card/i_clk_card/red_led
add wave -noupdate -format Logic /tb_clk_bias_card/i_clk_card/ylw_led
add wave -noupdate -format Logic /tb_clk_bias_card/i_clk_card/grn_led
add wave -noupdate -format Logic /tb_clk_bias_card/i_clk_card/dip_sw3
add wave -noupdate -format Logic /tb_clk_bias_card/i_clk_card/dip_sw4
add wave -noupdate -format Logic /tb_clk_bias_card/i_clk_card/wdog
add wave -noupdate -format Logic /tb_clk_bias_card/i_clk_card/fibre_rx_clk
add wave -noupdate -format Literal /tb_clk_bias_card/i_clk_card/fibre_rx_data
add wave -noupdate -format Logic /tb_clk_bias_card/i_clk_card/fibre_rx_rdy
add wave -noupdate -format Logic /tb_clk_bias_card/i_clk_card/fibre_rx_rvs
add wave -noupdate -format Logic /tb_clk_bias_card/i_clk_card/fibre_rx_status
add wave -noupdate -format Logic /tb_clk_bias_card/i_clk_card/fibre_rx_sc_nd
add wave -noupdate -format Logic /tb_clk_bias_card/i_clk_card/fibre_rx_ckr
add wave -noupdate -format Logic /tb_clk_bias_card/i_clk_card/fibre_tx_clk
add wave -noupdate -format Literal /tb_clk_bias_card/i_clk_card/fibre_tx_data
add wave -noupdate -format Logic /tb_clk_bias_card/i_clk_card/fibre_tx_ena
add wave -noupdate -format Logic /tb_clk_bias_card/i_clk_card/fibre_tx_sc_nd
add wave -noupdate -format Logic /tb_clk_bias_card/i_clk_card/rst
add wave -noupdate -format Logic /tb_clk_bias_card/i_clk_card/clk
add wave -noupdate -format Logic /tb_clk_bias_card/i_clk_card/mem_clk
add wave -noupdate -format Logic /tb_clk_bias_card/i_clk_card/comm_clk
add wave -noupdate -format Logic /tb_clk_bias_card/i_clk_card/fibre_clk
add wave -noupdate -format Literal /tb_clk_bias_card/i_clk_card/sync_num
add wave -noupdate -format Literal /tb_clk_bias_card/i_clk_card/data
add wave -noupdate -format Literal /tb_clk_bias_card/i_clk_card/addr
add wave -noupdate -format Literal /tb_clk_bias_card/i_clk_card/tga
add wave -noupdate -format Logic /tb_clk_bias_card/i_clk_card/we
add wave -noupdate -format Logic /tb_clk_bias_card/i_clk_card/stb
add wave -noupdate -format Logic /tb_clk_bias_card/i_clk_card/cyc
add wave -noupdate -format Literal /tb_clk_bias_card/i_clk_card/slave_data
add wave -noupdate -format Logic /tb_clk_bias_card/i_clk_card/slave_ack
add wave -noupdate -format Literal /tb_clk_bias_card/i_clk_card/led_data
add wave -noupdate -format Logic /tb_clk_bias_card/i_clk_card/led_ack
add wave -noupdate -format Literal /tb_clk_bias_card/i_clk_card/sync_gen_data
add wave -noupdate -format Logic /tb_clk_bias_card/i_clk_card/sync_gen_ack
add wave -noupdate -format Literal /tb_clk_bias_card/i_clk_card/frame_timing_data
add wave -noupdate -format Logic /tb_clk_bias_card/i_clk_card/frame_timing_ack
add wave -noupdate -format Logic /tb_clk_bias_card/i_clk_card/slave_err
add wave -noupdate -format Logic /tb_clk_bias_card/i_clk_card/sync
add wave -noupdate -format Logic /tb_clk_bias_card/i_clk_card/cmd
add wave -noupdate -format Logic /tb_clk_bias_card/i_clk_card/lvds_reply_cc_a
add wave -noupdate -format Literal /tb_clk_bias_card/i_clk_card/debug
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {270400 ps} 0}
WaveRestoreZoom {0 ps} {1409562 ns}
configure wave -namecolwidth 362
configure wave -valuecolwidth 82
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
