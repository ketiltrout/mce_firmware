sync_fifo_tx_inst : sync_fifo_tx PORT MAP (
		data	 => data_sig,
		wrreq	 => wrreq_sig,
		rdreq	 => rdreq_sig,
		rdclk	 => rdclk_sig,
		wrclk	 => wrclk_sig,
		aclr	 => aclr_sig,
		q	 => q_sig,
		rdempty	 => rdempty_sig,
		wrfull	 => wrfull_sig
	);
