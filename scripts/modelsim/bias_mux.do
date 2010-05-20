onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Literal /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_wbs/flux_fb_addr_i
add wave -noupdate -format Literal /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_wbs/flux_fb_data_o
add wave -noupdate -format Literal /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_wbs/flux_fb_changed_o
add wave -noupdate -format Literal /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_wbs/ln_bias_addr_i
add wave -noupdate -format Literal /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_wbs/ln_bias_data_o
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_wbs/ln_bias_changed_o
add wave -noupdate -format Literal /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_wbs/mux_flux_fb_data_o
add wave -noupdate -format Literal /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_wbs/enbl_mux_data_o
add wave -noupdate -format Literal /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_wbs/row_addr_i
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_wbs/row_switch_i
add wave -noupdate -divider wishbone
add wave -noupdate -format Literal -itemcolor black /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_wbs/dat_i
add wave -noupdate -format Literal -itemcolor black /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_wbs/addr_i
add wave -noupdate -format Literal -itemcolor black /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_wbs/tga_i
add wave -noupdate -format Logic -itemcolor black /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_wbs/we_i
add wave -noupdate -format Logic -itemcolor black /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_wbs/stb_i
add wave -noupdate -format Logic -itemcolor black /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_wbs/cyc_i
add wave -noupdate -format Literal -itemcolor black /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_wbs/dat_o
add wave -noupdate -color cyan -format Logic -itemcolor black /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_wbs/ack_o
add wave -noupdate -divider ram
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_wbs/clk_i
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_wbs/rst_i
add wave -noupdate -format Literal /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_wbs/flux_fb_wren
add wave -noupdate -format Literal /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_wbs/fix_flux_fb_data
add wave -noupdate -format Literal /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_wbs/mux_flux_fb_data
add wave -noupdate -format Literal /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_wbs/wb_mux_flux_fb_data
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_wbs/ln_bias_wren
add wave -noupdate -format Literal /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_wbs/ln_bias_data
add wave -noupdate -format Literal /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_wbs/enbl_mux_wren
add wave -noupdate -format Literal /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_wbs/enbl_mux_data
add wave -noupdate -format Literal /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_wbs/ram_addr
add wave -noupdate -format Literal /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_wbs/mux_ram_addr
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_wbs/row_flux_fb_wren(0)
add wave -noupdate -format Literal /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_wbs/row_flux_fb_wren
add wave -noupdate -format Literal /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_wbs/ram_addr_int
add wave -noupdate -format Literal /tb_cc_rcs_bcs_ac/i_bias_card1/dac_ncs
add wave -noupdate -format Literal /tb_cc_rcs_bcs_ac/i_bias_card1/dac_sclk
add wave -noupdate -format Literal /tb_cc_rcs_bcs_ac/i_bias_card1/dac_data
add wave -noupdate -divider timing
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_core/restart_frame_aligned_i
add wave -noupdate -color CYAN -format Logic -itemcolor cyan /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_core/row_switch_i
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_core/update_bias_i
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_core/clk_i
add wave -noupdate -color violet -format Logic /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_core/spi_clk_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_core/row_addr_o
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_core/row_addr_clr_pending
add wave -noupdate -divider CH0
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_bias_card1/dac_ncs(0)
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_bias_card1/dac_sclk(0)
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_bias_card1/dac_data(0)
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_core/update_aligned(0)
add wave -noupdate -divider CH1
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_core/flux_fb_update_pending(1)
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_bias_card1/dac_ncs(1)
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_bias_card1/dac_sclk(1)
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_bias_card1/dac_data(1)
add wave -noupdate -divider ln_bias
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_bias_card1/lvds_dac_ncs(11)
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_bias_card1/lvds_dac_ncs(0)
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_bias_card1/lvds_dac_sclk
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_bias_card1/lvds_dac_data
add wave -noupdate -color Aquamarine -format Logic -itemcolor Aquamarine /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_core/ln_bias_update_pending
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_core/ln_bias_dac_state(0)
add wave -noupdate -divider SPI_0
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_core/gen_spi_flux_fb__0/spi_dac_ctrl_i/clk_25_i
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_core/gen_spi_flux_fb__0/spi_dac_ctrl_i/clk_50_i
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_core/gen_spi_flux_fb__0/spi_dac_ctrl_i/restart_frame_aligned_i
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_core/gen_spi_flux_fb__0/spi_dac_ctrl_i/dat_rdy_i
add wave -noupdate -format Literal /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_core/gen_spi_flux_fb__0/spi_dac_ctrl_i/dat_i
add wave -noupdate -format Literal /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_core/gen_spi_flux_fb__0/spi_dac_ctrl_i/dac_spi_o
add wave -noupdate -color yellow -format Logic -itemcolor yellow /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_core/gen_spi_flux_fb__0/spi_dac_ctrl_i/spi_write_start
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_core/gen_spi_flux_fb__0/spi_dac_ctrl_i/update_frame_aligned
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_core/gen_spi_flux_fb__0/spi_dac_ctrl_i/spi_csb
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_core/gen_spi_flux_fb__0/spi_dac_ctrl_i/spi_sclk
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_core/gen_spi_flux_fb__0/spi_dac_ctrl_i/spi_sdat
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_core/gen_spi_flux_fb__0/spi_dac_ctrl_i/update_pending
add wave -noupdate -divider CORE
add wave -noupdate -format Literal /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_core/flux_fb_data_o
add wave -noupdate -format Literal /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_core/flux_fb_ncs_o
add wave -noupdate -format Literal /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_core/flux_fb_clk_o
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_core/ln_bias_data_o
add wave -noupdate -format Literal /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_core/ln_bias_ncs_o
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_core/ln_bias_clk_o
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_core/dac_nclr_o
add wave -noupdate -format Literal /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_core/flux_fb_addr_o
add wave -noupdate -format Literal /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_core/flux_fb_data_i
add wave -noupdate -format Literal /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_core/flux_fb_changed_i
add wave -noupdate -color cyan -format Literal -itemcolor cyan /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_core/ln_bias_addr_o
add wave -noupdate -format Literal /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_core/ln_bias_data_i
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_core/ln_bias_changed_i
add wave -noupdate -format Literal /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_core/mux_flux_fb_data_i(1)
add wave -noupdate -color cyan -format Literal -itemcolor cyan -label MUX_flux_fb_data_0 /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_core/mux_flux_fb_data_i(0)
add wave -noupdate -format Literal /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_core/mux_flux_fb_data_i
add wave -noupdate -format Literal /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_core/enbl_mux_data_i
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_core/rst_i
add wave -noupdate -format Literal /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_core/flux_fb_data
add wave -noupdate -format Literal /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_core/flux_fb_dac_spi
add wave -noupdate -format Literal /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_core/ln_bias_data
add wave -noupdate -format Literal /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_core/ln_bias_dac_spi
add wave -noupdate -format Literal /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_core/ln_bias_ncs
add wave -noupdate -format Literal /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_core/ln_bias_ncs_1dly
add wave -noupdate -format Literal /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_core/rd_addr
add wave -noupdate -format Literal /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_core/row_addr
add wave -noupdate -format Literal /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_core/flux_fb_update_pending
add wave -noupdate -format Literal /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_core/ln_bias_dac_state
add wave -noupdate -format Literal /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_core/update_aligned
add wave -noupdate -format Literal /tb_cc_rcs_bcs_ac/i_bias_card1/bc_dac_ctrl_slave/bcdc_core/flux_fb_dat_ready
add wave -noupdate -format Literal /tb_cc_rcs_bcs_ac/i_bias_card1/lvds_dac_ncs
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1097376705142 fs} 0}
configure wave -namecolwidth 187
configure wave -valuecolwidth 100
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
configure wave -timelineunits fs
update
WaveRestoreZoom {1096893183229 fs} {1097860227055 fs}
