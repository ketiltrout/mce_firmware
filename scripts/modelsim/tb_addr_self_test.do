onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /tb_addr_card_self_test/i_addr_card_self_test/inclk
add wave -noupdate -format Logic /tb_addr_card_self_test/i_addr_card_self_test/rst_n
add wave -noupdate -format Logic /tb_addr_card_self_test/i_addr_card_self_test/rst
add wave -noupdate -format Logic /tb_addr_card_self_test/i_addr_card_self_test/packets_done
add wave -noupdate -format Logic /tb_addr_card_self_test/i_addr_card_self_test/lvds_sync
add wave -noupdate -format Logic /tb_addr_card_self_test/i_addr_card_self_test/lvds_txa
add wave -noupdate -format Literal -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/dac_data0
add wave -noupdate -format Literal -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/dac_data1
add wave -noupdate -format Literal -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/dac_data2
add wave -noupdate -format Literal -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/dac_data3
add wave -noupdate -format Literal -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/dac_data4
add wave -noupdate -format Literal -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/dac_data5
add wave -noupdate -format Literal -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/dac_data6
add wave -noupdate -format Literal -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/dac_data7
add wave -noupdate -format Literal -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/dac_data8
add wave -noupdate -format Literal -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/dac_data9
add wave -noupdate -format Literal -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/dac_data10
add wave -noupdate -format Logic -height 15 -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/dac_clk(0)
add wave -noupdate -format Logic -height 15 -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/dac_clk(1)
add wave -noupdate -format Logic -height 15 -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/dac_clk(2)
add wave -noupdate -format Literal -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/dac_clk
add wave -noupdate -format Logic /tb_addr_card_self_test/i_addr_card_self_test/red_led
add wave -noupdate -format Logic /tb_addr_card_self_test/i_addr_card_self_test/ylw_led
add wave -noupdate -format Logic /tb_addr_card_self_test/i_addr_card_self_test/grn_led
add wave -noupdate -format Logic /tb_addr_card_self_test/i_addr_card_self_test/wdog
add wave -noupdate -format Literal /tb_addr_card_self_test/i_addr_card_self_test/slot_id
add wave -noupdate -format Logic /tb_addr_card_self_test/i_addr_card_self_test/clk
add wave -noupdate -format Logic /tb_addr_card_self_test/i_addr_card_self_test/state_shift
add wave -noupdate -format Logic /tb_addr_card_self_test/i_addr_card_self_test/lvds_lvds_tx
add wave -noupdate -format Logic /tb_addr_card_self_test/i_addr_card_self_test/rdy_lvds_tx
add wave -noupdate -format Logic /tb_addr_card_self_test/i_addr_card_self_test/busy_lvds_tx
add wave -noupdate -format Literal -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/rdaddress_packet_ram
add wave -noupdate -format Literal -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/q_packet_ram
add wave -noupdate -format Literal /tb_addr_card_self_test/i_addr_card_self_test/i
add wave -noupdate -divider dispatch
add wave -noupdate -format Logic /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/cmd0/lvds_cmd_i
add wave -noupdate -format Logic /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/cmd0/lvds_reply_o
add wave -noupdate -format Literal -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/cmd0/dat_o
add wave -noupdate -format Literal -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/cmd0/addr_o
add wave -noupdate -format Literal -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/cmd0/tga_o
add wave -noupdate -format Logic /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/cmd0/we_o
add wave -noupdate -format Logic /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/cmd0/stb_o
add wave -noupdate -format Logic /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/cmd0/cyc_o
add wave -noupdate -format Literal -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/cmd0/dat_i
add wave -noupdate -format Logic /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/cmd0/ack_i
add wave -noupdate -format Logic /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/cmd0/err_i
add wave -noupdate -format Logic /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/cmd0/wdt_rst_o
add wave -noupdate -format Literal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/cmd0/slot_i
add wave -noupdate -format Literal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/cmd0/pres_state
add wave -noupdate -format Literal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/cmd0/next_state
add wave -noupdate -color Gold -format Logic -itemcolor Gold -label CMD_RDY /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/cmd0/cmd_rdy
add wave -noupdate -format Logic /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/cmd0/cmd_err
add wave -noupdate -format Logic /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/cmd0/wb_cmd_rdy
add wave -noupdate -format Logic /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/cmd0/wb_rdy
add wave -noupdate -format Logic /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/cmd0/wb_err
add wave -noupdate -format Logic /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/cmd0/reply_rdy
add wave -noupdate -format Logic /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/cmd0/reply_ack
add wave -noupdate -format Logic /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/cmd0/uop_status_ld
add wave -noupdate -format Logic /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/cmd0/status_clr
add wave -noupdate -format Literal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/cmd0/status_reg
add wave -noupdate -format Literal -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/cmd0/reply_data_size
add wave -noupdate -format Literal -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/cmd0/cmd_hdr0
add wave -noupdate -format Literal -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/cmd0/cmd_hdr1
add wave -noupdate -format Literal -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/cmd0/reply_hdr0
add wave -noupdate -format Literal -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/cmd0/reply_hdr1
add wave -noupdate -format Literal -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/cmd0/reply_hdr2
add wave -noupdate -format Literal -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/cmd0/cmd_header0
add wave -noupdate -format Literal -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/cmd0/cmd_header1
add wave -noupdate -format Literal -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/cmd0/reply_header0
add wave -noupdate -format Literal -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/cmd0/reply_header1
add wave -noupdate -format Literal -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/cmd0/reply_header2
add wave -noupdate -format Logic /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/cmd0/cmd_hdr_ld
add wave -noupdate -format Logic /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/cmd0/cmd_buf_wren
add wave -noupdate -format Literal -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/cmd0/cmd_buf_wrdata
add wave -noupdate -format Literal -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/cmd0/cmd_buf_wraddr
add wave -noupdate -format Literal -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/cmd0/cmd_buf_rddata
add wave -noupdate -format Literal -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/cmd0/cmd_buf_rdaddr
add wave -noupdate -format Logic /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/cmd0/reply_buf_wren
add wave -noupdate -format Literal -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/cmd0/reply_buf_wrdata
add wave -noupdate -format Literal -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/cmd0/reply_buf_wraddr
add wave -noupdate -format Literal -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/cmd0/reply_buf_rddata
add wave -noupdate -format Literal -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/cmd0/reply_buf_rdaddr
add wave -noupdate -format Literal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/cmd0/card
add wave -noupdate -divider ac_ctrl_slave
add wave -noupdate -format Logic /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/ac_dac_ctrl_slave/clk_i
add wave -noupdate -format Literal -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/ac_dac_ctrl_slave/dac_data_o
add wave -noupdate -format Literal -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/ac_dac_ctrl_slave/dac_clks_o
add wave -noupdate -format Literal -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/ac_dac_ctrl_slave/dat_i
add wave -noupdate -format Literal -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/ac_dac_ctrl_slave/addr_i
add wave -noupdate -format Literal -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/ac_dac_ctrl_slave/tga_i
add wave -noupdate -format Logic -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/ac_dac_ctrl_slave/we_i
add wave -noupdate -format Logic -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/ac_dac_ctrl_slave/stb_i
add wave -noupdate -format Logic -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/ac_dac_ctrl_slave/cyc_i
add wave -noupdate -format Literal -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/ac_dac_ctrl_slave/dat_o
add wave -noupdate -format Logic /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/ac_dac_ctrl_slave/ack_o
add wave -noupdate -format Logic /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/ac_dac_ctrl_slave/row_switch_i
add wave -noupdate -format Logic /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/ac_dac_ctrl_slave/restart_frame_aligned_i
add wave -noupdate -format Logic /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/ac_dac_ctrl_slave/row_en_i
add wave -noupdate -format Logic /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/ac_dac_ctrl_slave/mux_en
add wave -noupdate -format Literal -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/ac_dac_ctrl_slave/on_off_addr
add wave -noupdate -format Literal -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/ac_dac_ctrl_slave/dac_id
add wave -noupdate -format Literal -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/ac_dac_ctrl_slave/on_data
add wave -noupdate -format Literal -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/ac_dac_ctrl_slave/off_data
add wave -noupdate -divider dac_core
add wave -noupdate -format Literal -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/ac_dac_ctrl_slave/acdcc/dac_clks_o
add wave -noupdate -format Literal -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/ac_dac_ctrl_slave/acdcc/on_off_addr_o
add wave -noupdate -format Literal -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/ac_dac_ctrl_slave/acdcc/dac_id_i
add wave -noupdate -format Literal -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/ac_dac_ctrl_slave/acdcc/on_data_i
add wave -noupdate -format Literal -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/ac_dac_ctrl_slave/acdcc/off_data_i
add wave -noupdate -format Logic /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/ac_dac_ctrl_slave/acdcc/mux_en_wbs_i
add wave -noupdate -format Logic /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/ac_dac_ctrl_slave/acdcc/row_switch_i
add wave -noupdate -format Logic /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/ac_dac_ctrl_slave/acdcc/restart_frame_aligned_i
add wave -noupdate -format Logic /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/ac_dac_ctrl_slave/acdcc/row_en_i
add wave -noupdate -format Literal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/ac_dac_ctrl_slave/acdcc/row_current_state
add wave -noupdate -format Literal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/ac_dac_ctrl_slave/acdcc/row_next_state
add wave -noupdate -format Logic /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/ac_dac_ctrl_slave/acdcc/frame_aligned_reg
add wave -noupdate -format Logic /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/ac_dac_ctrl_slave/acdcc/mux_en
add wave -noupdate -format Literal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/ac_dac_ctrl_slave/acdcc/row_count
add wave -noupdate -format Literal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/ac_dac_ctrl_slave/acdcc/row_count_new
add wave -noupdate -format Literal -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/ac_dac_ctrl_slave/acdcc/dac_on_data
add wave -noupdate -format Literal -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/ac_dac_ctrl_slave/acdcc/dac_off_data
add wave -noupdate -format Literal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/ac_dac_ctrl_slave/acdcc/dac_id_int
add wave -noupdate -color Turquoise -format Literal -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/ac_dac_ctrl_slave/acdcc/dac_data_o
add wave -noupdate -format Logic -height 15 -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/ac_dac_ctrl_slave/acdcc/dac_clks_o(0)
add wave -noupdate -format Logic -height 15 -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/ac_dac_ctrl_slave/acdcc/dac_clks_o(1)
add wave -noupdate -format Logic -height 15 -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/ac_dac_ctrl_slave/acdcc/dac_clks_o(2)
add wave -noupdate -format Logic -height 15 -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/ac_dac_ctrl_slave/acdcc/dac_clks_o(3)
add wave -noupdate -format Literal -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/ac_dac_ctrl_slave/acdcc/dac_data
add wave -noupdate -divider dac_wbs
add wave -noupdate -format Logic -height 15 -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/ac_dac_ctrl_slave/acdcc/dac_clks_o(0)
add wave -noupdate -format Literal -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/ac_dac_ctrl_slave/wbi/on_off_addr_i
add wave -noupdate -format Literal -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/ac_dac_ctrl_slave/wbi/dac_id_o
add wave -noupdate -format Literal -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/ac_dac_ctrl_slave/wbi/on_data_o
add wave -noupdate -format Literal -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/ac_dac_ctrl_slave/wbi/off_data_o
add wave -noupdate -format Logic -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/ac_dac_ctrl_slave/wbi/mux_en_o
add wave -noupdate -format Logic -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/ac_dac_ctrl_slave/wbi/clk_i
add wave -noupdate -format Logic -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/ac_dac_ctrl_slave/wbi/rst_i
add wave -noupdate -format Literal -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/ac_dac_ctrl_slave/wbi/dat_i
add wave -noupdate -format Literal -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/ac_dac_ctrl_slave/wbi/addr_i
add wave -noupdate -format Literal -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/ac_dac_ctrl_slave/wbi/tga_i
add wave -noupdate -format Logic -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/ac_dac_ctrl_slave/wbi/we_i
add wave -noupdate -format Logic -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/ac_dac_ctrl_slave/wbi/stb_i
add wave -noupdate -format Logic -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/ac_dac_ctrl_slave/wbi/cyc_i
add wave -noupdate -format Literal -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/ac_dac_ctrl_slave/wbi/dat_o
add wave -noupdate -format Logic -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/ac_dac_ctrl_slave/wbi/ack_o
add wave -noupdate -format Logic -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/ac_dac_ctrl_slave/wbi/wr_cmd
add wave -noupdate -format Logic -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/ac_dac_ctrl_slave/wbi/rd_cmd
add wave -noupdate -format Logic -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/ac_dac_ctrl_slave/wbi/master_wait
add wave -noupdate -format Logic -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/ac_dac_ctrl_slave/wbi/on_val_wren
add wave -noupdate -format Logic -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/ac_dac_ctrl_slave/wbi/off_val_wren
add wave -noupdate -format Logic -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/ac_dac_ctrl_slave/wbi/row_order_wren
add wave -noupdate -format Literal -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/ac_dac_ctrl_slave/wbi/logical_addr
add wave -noupdate -format Logic -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/ac_dac_ctrl_slave/wbi/mux_en_wren
add wave -noupdate -format Literal -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/ac_dac_ctrl_slave/wbi/mux_en_data
add wave -noupdate -format Literal -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/ac_dac_ctrl_slave/wbi/on_data
add wave -noupdate -format Literal -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/ac_dac_ctrl_slave/wbi/off_data
add wave -noupdate -format Literal -radix hexadecimal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/ac_dac_ctrl_slave/wbi/row_order_data
add wave -noupdate -format Literal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/ac_dac_ctrl_slave/wbi/current_state
add wave -noupdate -format Literal /tb_addr_card_self_test/i_addr_card_self_test/i_addr_card/ac_dac_ctrl_slave/wbi/next_state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {107620000 ps} 0}
WaveRestoreZoom {105711280 ps} {108308720 ps}
configure wave -namecolwidth 343
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
bookmark add wave bookmark0 {{314958713 ps} {315048929 ps}} 97
bookmark add wave bookmark1 {{314958713 ps} {315048929 ps}} 97
