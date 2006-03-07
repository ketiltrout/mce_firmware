This folder contains all the required files to 
generate SCUBA2's PCI bootcode release A (version 1.4)


updated 07/03/06

---------------------------------------
When downloading via dataman to EEPROM
Checksum = $73475F
---------------------------------------

'build_pci_once' is run to generate .lod and .cld files which can be downloaded to the PCI DSP via the on-chip emulator OnCe.

'build_pci_rom' is run to generate a motorola .s file which is burned to E2PROM, from which the PCI code is bootstraped.


Change from RevA_1.3 --> RevA1.4
--------------------------------

1. byte swapping disabled after a pci reset.  Only enabled once comms opened with MCE.  This is to help protect against the MCE sending an odd number of bytes after it is power cycled.  The pci card should be reset prior to any MCE power cycle/reconfiguration. 

2. If pre-amble error FIFO *RS line now held low for 2ms to clear both FIFOs.  This is to add protection against an odd number of bytes being sent up the fibre - which would put the preamble out of sync (since byte swapping enabled)

Added a Fifo dump after an HST timout.  That is, if the PCI card is waiting on some packet data and gets a fatal error fast interrupt it will save any data in the FO FIFO before re-initialising (max of 512 words).   Any words in FIFO are saved to Y mem.   The number of 16-bit words recovered from Y mem are saved in X:NUM_DUMPED, and the number of words that were successfully written to the host (before HST timeout) are saved in X:WORD_COUNT.  These are not re-initialised by a fatal error reset, but will be reset by a RST command or when a new packet arrives.


Change from RevA_1.2 --> RevA1.3
--------------------------------

various changes added post code review.   Including....

1. PACKET_CHOKE bit added to status.  This bit is set in initialisation,
   which results in anything on fibre from MCE being ignored.  
   It stays set until the first command is issued to MCE (via PCI CON command).  
   After that it remains clear unless PCI reset is issued (or 'fatal error' fast interrupt, 
   which caused the initialisation code to be re-run).  This means that after start up the PCI card will 
   ignore the MCE (even valid packets) until communications are opened by the host PC.

2. FATAL_ERROR bit added to STATUS.   The driver may set this bit by issuing a fast interrupt.  
   For example this would occur if there was a problem communicating an 'NFY' or 'REP' message.   
   Ultimately it will result in the  initialisation code being re-run. 

3. Applications can now be downloaded to PCI card. e.g. pci_diagnostic.lod.  
   Applications reside at address $800 and can be downloaded using the command: "dwloadpci <filename>"



Change from RevA_1.1 --> RevA1.2
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


