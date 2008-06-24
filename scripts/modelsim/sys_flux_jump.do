onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_readout_card1/i_dispatch/lvds_cmd_i
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_readout_card1/i_dispatch/lvds_reply_o
add wave -noupdate -format Literal -radix unsigned /tb_cc_rcs_bcs_ac/i_readout_card1/i_dispatch/dat_o
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_dispatch/dat_i
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_dispatch/addr_o
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_readout_card1/i_dispatch/we_o
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_readout_card1/i_dispatch/stb_o
add wave -noupdate -divider wbs_frame_data
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_wbs_frame_data/filtfb_flx_cnt_dat
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_wbs_frame_data/wbs_data
add wave -noupdate -divider {frame_timing (well from fsfb_calc)}
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/row_switch_i
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/initialize_window_i
add wave -noupdate -divider fsfb_corr
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/clk_i
add wave -noupdate -format Logic /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/rst_i
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/flux_jumping_en_i
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/fsfb_ctrl_dat0_o
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/fsfb_ctrl_dat1_o
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/fsfb_ctrl_dat7_o
add wave -noupdate -format Logic -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/fsfb_ctrl_dat_rdy_o
add wave -noupdate -format Logic -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/fsfb_ctrl_lock_en0_i
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/flux_quanta0_i
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/num_flux_quanta_prev0_i
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/fsfb_ctrl_dat1_i
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/fsfb_ctrl_dat7_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/fsfb_ctrl_dat0_i
add wave -noupdate -format Logic -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/fsfb_ctrl_dat_rdy0_i
add wave -noupdate -format Logic -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/fsfb_ctrl_dat_rdy1_i
add wave -noupdate -format Logic -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/fsfb_ctrl_dat_rdy7_i
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/num_flux_quanta_pres0_o
add wave -noupdate -format Logic -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/num_flux_quanta_pres_rdy_o
add wave -noupdate -format Logic -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/start_corr
add wave -noupdate -format Logic -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/rdy_clr
add wave -noupdate -format Literal -radix unsigned /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/column_switch1
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/column_switch2
add wave -noupdate -format Logic -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/pid_corr_rdy
add wave -noupdate -format Logic -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/m_pres_rdy
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/flux_quanta1
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/flux_quanta2
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/m_prev
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/m_pres_reg0
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/m_pres
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/m_pres0
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/pid_prev1
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/pid_prev2
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/mult_res1
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/mult_res2
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/mult_res1_xtnd
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/mult_res2_xtnd
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/sub_res1
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/sub_res2
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/flux_quanta_reg0
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/m_prev_reg0
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/pid_prev_reg0
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/fsfb_ctrl_dat_rdy0
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/res_a_reg0
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/res_a_en0
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/res_b_reg0
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/res_b_en0
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/res_b0
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/res_b1
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/res_b7
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/m_pres_en0
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/present_state
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_fsfb_corr/next_state
add wave -noupdate -divider fsfb_queue
add wave -noupdate -format Logic -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/i_fsfb_queue_bank0/clock
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/i_fsfb_queue_bank0/data
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/i_fsfb_queue_bank0/rdaddress_a
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/i_fsfb_queue_bank0/rdaddress_b
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/i_fsfb_queue_bank0/wraddress
add wave -noupdate -format Logic -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/i_fsfb_queue_bank0/wren
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/i_fsfb_queue_bank0/qa
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/i_fsfb_queue_bank0/qb
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/i_fsfb_queue_bank0/sub_wire0
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/i_fsfb_queue_bank0/sub_wire1
add wave -noupdate -format Logic -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/i_fsfb_queue_bank1/clock
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/i_fsfb_queue_bank1/data
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/i_fsfb_queue_bank1/rdaddress_a
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/i_fsfb_queue_bank1/rdaddress_b
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/i_fsfb_queue_bank1/wraddress
add wave -noupdate -format Logic -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/i_fsfb_queue_bank1/wren
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/i_fsfb_queue_bank1/qa
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/i_fsfb_queue_bank1/qb
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/i_fsfb_queue_bank1/sub_wire0
add wave -noupdate -format Literal -radix decimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/i_fsfb_queue_bank1/sub_wire1
add wave -noupdate -format Logic -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/i_fsfb_io_controller/initialize_window_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/i_fsfb_io_controller/fsfb_proc_dat_i
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/i_fsfb_io_controller/ctrl_dat_selected
add wave -noupdate -format Literal -radix hexadecimal /tb_cc_rcs_bcs_ac/i_readout_card1/i_flux_loop/i_flux_loop_ctrl_ch0/i_fsfb_calc/i_fsfb_io_controller/ctrl_dat
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {530238054 ps} 0}
configure wave -namecolwidth 441
configure wave -valuecolwidth 83
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
WaveRestoreZoom {530174459 ps} {531186324 ps}
