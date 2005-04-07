This folder contains all the required files to 
generate SCUBA2's PCI bootcode release A (version 1.1)


updated 07/04/05
---------------------------------------
When downloading via dataman to EEPROM
Checksum = $7398D2
---------------------------------------

'build_pci_once' is run to generate .lod and .cld files which can be downloaded to the PCI DSP via the on-chip emulator OnCe.

'build_pci_rom' is run to generate a motorola .s file which is burned to E2PROM, from which the PCI code is bootstraped.


DEBUG
-----
PCI code includes a frame count (X:2), and sets a status bit if 
there is ever a preamble error.

Change from RevA1.0 --> RevA1.1
--------------------------------
Word 4 of CON command changed (was used to indicate block con command - but since all commands are size 64words this is no longer needed).  Now used to indicate if the MCE command to be sent to the controller is a GO command. If it is a flag in status is set "DATA_DLY".  This flag enables a delay added to first data packet returned after go reply packet (delay is after packet arrives but before host notified).  By default the delay value is 0 (i.e. not used). 


Notes
------
This PCI code enables hardware byte swapping. 
The PCI card is in charge of all byte / word swapping.   The host stores commands in little endian format.  32bit Data written to the host must end up in the hosts memory in little endian format. 

All packets sent to and from the MCE are sent LSB first (little endian).

The code uses DMA BURST MODE to write the data across the PCI bus. 

This version does not use the large SRAM area in Y memory, but stores a 512 (memory) buffer in on-chip y memory and then immediately DMAs it to X memory for PCI burst mode transfer across the bus (similar to 'ultracam' version 3.0).

-------------------------------------------------------------------------


