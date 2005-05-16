/* Quartus II Version 4.1 Build 208 09/10/2004 Service Pack 2 SJ Full Version */
JedecChain;
	FileRevision(JESD32A);
	DefaultMfr(6E);

	P ActionCode(Cfg)
		Device PartName(EPC16) Path("E:/public_html/sc2mce/system/clk_card/test_plan/sof_pof_files/") File("cc_19apr2005_sync_syncronizer.pof") MfrSpec(OpMask(1));
	P ActionCode(Ign)
		Device PartName(EPM3128A) MfrSpec(OpMask(0));

ChainEnd;

AlteraBegin;
	ChainType(JTAG);
AlteraEnd;
