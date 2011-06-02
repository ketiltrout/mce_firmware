onerror {resume}
quietly virtual function -install /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/i_fltr2_add/lpm_add_sub_component/l2/v -env /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/i_fltr2_add/lpm_add_sub_component/l2/v { (&{ 31'b0000000000000000000000000000000,cin })} dbgTemp76
quietly virtual signal -install /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/i_fltr2_add/lpm_add_sub_component/l2/v {/tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/i_fltr2_add/lpm_add_sub_component/l2/v/line__1627/resulttmp(0)(30)  } dbgTemp72
quietly virtual function -install /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/i_fltr2_add/lpm_add_sub_component/l2/v -env /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/i_fltr2_add/lpm_add_sub_component/l2/v { (i_dataa[31:0]  + i_datab[31:0] )} dbgTemp75
quietly virtual function -install /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/i_fltr2_add/lpm_add_sub_component/l2/v -env /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/i_fltr2_add/lpm_add_sub_component/l2/v { (dbgTemp75  + dbgTemp76 )} dbgTemp77
quietly virtual signal -install /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/i_fltr2_add/lpm_add_sub_component/l2/v {/tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/i_fltr2_add/lpm_add_sub_component/l2/v/line__1627/resulttmp(0)(30)  } dbgTemp73
quietly virtual function -install /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/i_fltr2_add/lpm_add_sub_component/l2/v -env /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/i_fltr2_add/lpm_add_sub_component/l2/v { ((dbgTemp77[31]  xor i_dataa[31] ) xor i_datab[31] )} dbgTemp78
quietly virtual function -install /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/i_fltr2_add/lpm_add_sub_component/l2/v -env /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/i_fltr2_add/lpm_add_sub_component/l2/v { ((( !(i_dataa[31] ) and  !(i_datab[31] )) and dbgTemp72 ) or ((i_dataa[31]  and i_datab[31] ) and  !(dbgTemp73 )))} dbgTemp74
quietly virtual function -install /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz -env /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz { (store_fltr2_sum  ? fltr2_sum[31:0] : fltr2_sum_reg[31:0])} dbgTemp108_fltr2_sum_reg_12
quietly virtual function -install /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz -env /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz { &{(store_fltr1_tmp  ? fltr1_tmp[30:0] : fltr1_tmp_reg[30:0]) , (store_fltr1_tmp  ? fltr1_tmp[30] : fltr1_tmp_reg[31])}} dbgTemp108_fltr1_tmp_reg_8
quietly virtual function -install /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz -env /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz { &{(store_wn10  ? wn10[28:0] : wn10_reg[28:0]) , (store_wn10  ? wn10[28] : wn10_reg[29]) , (store_wn10  ? wn10[28] : wn10_reg[30]) , (store_wn10  ? wn10[28] : wn10_reg[31])}} dbgTemp108_wn10_reg_7
quietly virtual function -install /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz -env /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz { &{(store_1st_add  ? d_product_reg[64:0] : dz_sum_reg[64:0]) , (store_1st_add  ? d_product_reg[64] : dz_sum_reg[65])}} dbgTemp108_dz_sum_reg_3
quietly virtual function -install /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz -env /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz { (store_fltr1_sum  ? fltr1_sum[31:0] : fltr1_sum_reg[31:0])} dbgTemp108_fltr1_sum_reg_9
quietly virtual function -install /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz -env /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz { (store_1st_wtemp  ? wtemp[42:14] : wtemp_reg_shift[28:0])} dbgTemp108_wtemp_reg_shift_5
quietly virtual function -install /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz -env /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz { (store_2nd_add  ? pidz_sum[65:0] : pidz_sum_reg[65:0])} dbgTemp108_pidz_sum_reg_4
quietly virtual function -install /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz -env /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz { (store_2nd_wtemp  ? wtemp[42:14] : dbgTemp108_wtemp_reg_shift_5)} dbgTemp108_wtemp_reg_shift_6
quietly virtual function -install /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz -env /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz { &{(store_fltr2_tmp  ? fltr2_tmp[30:0] : fltr2_tmp_reg[30:0]) , (store_fltr2_tmp  ? fltr2_tmp[30] : fltr2_tmp_reg[31])}} dbgTemp108_fltr2_tmp_reg_11
quietly virtual function -install /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz -env /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz { &{(store_wn20  ? wn20[28:0] : wn20_reg[28:0]) , (store_wn20  ? wn20[28] : wn20_reg[29]) , (store_wn20  ? wn20[28] : wn20_reg[30]) , (store_wn20  ? wn20[28] : wn20_reg[31])}} dbgTemp108_wn20_reg_10
quietly virtual function -install /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz -env /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz { &{(store_1st_add  ? pi_sum[64:0] : pi_sum_reg[64:0]) , (store_1st_add  ? pi_sum[64] : pi_sum_reg[65])}} dbgTemp108_pi_sum_reg_3
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_fsfb_calc/ft_initialize_window_i
add wave -noupdate /tb_fsfb_calc/pq_wraddr_i
add wave -noupdate /tb_fsfb_calc/pq_wrdata_i
add wave -noupdate /tb_fsfb_calc/pq_wren_i
add wave -noupdate /tb_fsfb_calc/impulse
add wave -noupdate /tb_fsfb_calc/calc_clk_i
add wave -noupdate /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/coadd_done_i
add wave -noupdate /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/current_coadd_dat_i
add wave -noupdate /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/current_diff_dat_i
add wave -noupdate /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/current_integral_dat_i
add wave -noupdate /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/lock_mode_en_i
add wave -noupdate /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/p_dat_i
add wave -noupdate /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/i_dat_i
add wave -noupdate /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/d_dat_i
add wave -noupdate /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/wn11_dat_i
add wave -noupdate /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/wn12_dat_i
add wave -noupdate /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/wn21_dat_i
add wave -noupdate /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/wn22_dat_i
add wave -noupdate /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/wn10_dat_o
add wave -noupdate /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/wn20_dat_o
add wave -noupdate /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/fsfb_proc_pidz_update_o
add wave -noupdate /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/fsfb_proc_pidz_sum_o
add wave -noupdate /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/fsfb_proc_fltr_update_o
add wave -noupdate /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/fsfb_proc_fltr_sum_o
add wave -noupdate /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/fsfb_proc_fltr_sum_mine
add wave -noupdate /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/calc_shift_state
add wave -noupdate /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/store_1st_add
add wave -noupdate /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/store_2nd_add
add wave -noupdate /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/store_1st_wtemp
add wave -noupdate /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/store_2nd_wtemp
add wave -noupdate /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/store_wn10
add wave -noupdate /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/store_fltr1_tmp
add wave -noupdate /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/store_fltr1_sum
add wave -noupdate /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/store_wn20
add wave -noupdate /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/store_fltr2_tmp
add wave -noupdate /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/store_fltr2_sum
add wave -noupdate /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/current_coadd_dat_reg
add wave -noupdate /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/current_diff_dat_reg
add wave -noupdate /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/current_integral_dat_reg
add wave -noupdate /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/multiplicand_a
add wave -noupdate /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/multiplicand_b
add wave -noupdate /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/multiplied_result
add wave -noupdate /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/multiplicand_a_reg
add wave -noupdate /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/multiplicand_b_reg
add wave -noupdate /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/p_product_reg
add wave -noupdate /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/i_product_reg
add wave -noupdate /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/d_product_reg
add wave -noupdate /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/b11_product_reg
add wave -noupdate /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/b12_product_reg
add wave -noupdate /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/b21_product_reg
add wave -noupdate /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/b22_product_reg
add wave -noupdate /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/pi_sum
add wave -noupdate /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/pidz_sum
add wave -noupdate /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/pidz_sum_reg
add wave -noupdate /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/pidz_sum_reg_shift
add wave -noupdate /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/fltr1_tmp
add wave -noupdate /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/fltr1_tmp_reg
add wave -noupdate /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/fltr1_sum
add wave -noupdate /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/fltr1_sum_reg
add wave -noupdate /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/fltr1_sum_reg_shift
add wave -noupdate /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/fltr2_tmp
add wave -noupdate /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/fltr2_tmp_reg
add wave -noupdate -color gold -itemcolor gold /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/fltr2_sum
add wave -noupdate /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/fltr2_sum_reg
add wave -noupdate /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/operand_a
add wave -noupdate /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/operand_b
add wave -noupdate /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/wtemp
add wave -noupdate /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/wtemp_reg_shift
add wave -noupdate /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/wtemp_reg_shift_corrected
add wave -noupdate /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/correction_on
add wave -noupdate /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/wn10
add wave -noupdate /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/wn20
add wave -noupdate /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/wn10_reg
add wave -noupdate /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/wn20_reg
add wave -noupdate /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/wn11_shift
add wave -noupdate /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/wn21_shift
add wave -noupdate /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/wn12_shift
add wave -noupdate /tb_fsfb_calc/uut/i_fsfb_processor/i_fsfb_proc_pidz/wn22_shift
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {93923190842 ps} 0} {Trace {0 ps} 0}
configure wave -namecolwidth 150
configure wave -valuecolwidth 165
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
WaveRestoreZoom {93916955680 ps} {93941496640 ps}
