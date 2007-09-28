 COMMENT *

Compile this to build all files together.

Project:     SCUBA 2 
Author:      DAVID ATKINSON
Target:      250MHz SDSU PCI card - DSP56301
Controller:  For use with SCUBA 2 Multichannel Electronics 

Modified:    MATTHEW HASSELFIELD

Assembler directives:
	DOWNLOAD=EEPROM => EEPROM CODE
	DOWNLOAD=ONCE => ONCE CODE

	*
	PAGE    132     ; Printronix page width - 132 columns
	OPT	CEX	; print DC evaluations

	INCLUDE 'header.asm'
	INCLUDE	'init.asm'
	INCLUDE 'main.asm'



