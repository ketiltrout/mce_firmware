/* Quartus II Version 5.1 Build 213 01/19/2006 Service Pack 1 SJ Full Version */
JedecChain;
	FileRevision(JESD32A);
	DefaultMfr(6E);

	P ActionCode(Ign)
		Device PartName(EPC16) MfrSpec(OpMask(0));
	P ActionCode(Cfg)
		Device PartName(EP1S30F780) Path("") File("fo_bist.sof") MfrSpec(OpMask(1));

ChainEnd;

AlteraBegin;
	ChainType(JTAG);
AlteraEnd;
