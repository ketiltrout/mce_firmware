/* Quartus II Version 4.1 Build 181 06/29/2004 SJ Full Version */
JedecChain;
	FileRevision(JESD32A);
	DefaultMfr(6E);

	P ActionCode(Ign)
		Device PartName(EPC16) MfrSpec(OpMask(0));
	P ActionCode(Cfg)
		Device PartName(EP1S30F780) Path("C:/scuba2_repository/cards/clk_card/clk_card/synth/") File("clk_card.sof") MfrSpec(OpMask(1));

ChainEnd;

AlteraBegin;
	ChainType(JTAG);
AlteraEnd;
