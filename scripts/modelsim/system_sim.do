vdbg
vsim -sdfnoerror -sdfnowarn -debugdb -t ps -vopt {-voptargs=+acc -keep_delta -hazards} work.tb_cc_rcs_bcs_ac
log -r /*