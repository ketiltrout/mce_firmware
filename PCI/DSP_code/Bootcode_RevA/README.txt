This folder contains all the required files to 
generate SCUBA2's PCI bootcode release A
This is the same as develpment code V5.1

updated 29/11/04
---------------------------------------
When downloading via dataman to EEPROM
Checksum = $737140
---------------------------------------

'build_pci_once' is run to generate .lod and .cld files which can be downloaded to the PCI DSP via the on-chip emulator OnCe.

'build_pci_rom' is run to generate a motorola .s file which is burned to E2PROM, from which the PCI code is bootstraped.

--------------------------------------
when testing with timing board use 
use V4.0 
---------------------------------------

DEBUG
-----
PCI code includes a frame count, and sets a status bit if 
there is ever a preamble error.

NOTES
-----
This PCI code enables hardware byte swapping. 
The PCI card is now in charge of all byte / word swapping.   The host stores commands in little endian format.  32bit Data written to the host must end up in the hosts memory in little endian format. 

All packets sent to and from the MCE are sent LSB first (little endian).

The code uses DMA BURST MODE to write the data across the PCI bus. 

This version does not use the large SRAM area in Y memory, but stores a 512 (memory) buffer in on-chip y memory and then immediately DMAs it to X memory for PCI burst mode transfer across the bus (similar to 'ultracam' version 3.0).

-------------------------------------------------------------------------


