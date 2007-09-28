      COMMENT *

PCI code header file.

Project:     SCUBA 2 
Author:      DAVID ATKINSON
Target:      250MHz SDSU PCI card - DSP56301
Controller:  For use with SCUBA 2 Multichannel Electronics 

Modified:    MATTHEW HASSELFIELD
	
Assembler directives:
	DOWNLOAD=0 => EEPROM CODE
	DOWNLOAD=1 => DOWNLOAD CODE

	*
	PAGE    132     ; Printronix page width - 132 columns
	OPT	CEX	; print DC evaluations

	MSG ' INCLUDE PCI_header.asm HERE  '

; Equates to define the X: memory tables
VAR_TBL		EQU	0	; Variables and constants table

APPLICATION	EQU	$800	; application memory start location in P memory
				; note applications should start with this address 
				; and end with a JMP to PACKET_IN
				; if only want appl to run once
				; penultimate line of code should be 
				; to clear bit APPLICATION_LOADED in STATUS
				; otherwise will run continusly until 'STP'
				; command is sent

APPL_PARAM	EQU	$200 	; application parameters in x memory start here.


HF_FIFO		EQU	512	; number of 16 bit words in a half full FIFO
SMALL_BLK	EQU	32	; small block burst size for < 512 pixels
IMAGE_BUFFER	EQU	0	; location in y memory of image buffer....


;Status bits

APPLICATION_LOADED	EQU	0   ; set if PCI application to run
SEND_TO_HOST		EQU	1   ; set in HST ISR when host ready for packet (stays set until after HST reply)
FATAL_ERROR		EQU	2   ; PCI message to host error detected by driver....
FO_WRD_RCV		EQU	3   ; set when packet detected in FIFO - stays set till packet processed

;INTA_FLAG		EQU	4   ; used for interupt handshaking with host
BYTE_SWAP		EQU	5   ; flag to show byte swapping enabled
PREAMBLE_ERROR		EQU	6   ; set if preamble error detected
DATA_DLY		EQU	7   ; set in CON ISR if MCE command is 'GO'.  USed to add delay to first returned data packet 

PACKET_CHOKE		EQU	8   ;  don't let any packets from MCE through to host....
HST_NFYD		EQU	9   ; set after host notified (NFY message) of packet (stays set until after HST reply)
SB_SPARE1		EQU	10
SB_SPARE2		EQU	11


APPLICATION_RUNNING	EQU	12   ; can be set by an application to indicate its still running
				     ; e.g. set by diagnostic application
				     ; indicates in a 'self_test_mode'
				     ; subsequnet GO commands (for MCE) will be handelled internally. 
				     ; disable with PCI STOP_APPLICATION command.

INTERNAL_GO		EQU	13   ; GO command received while diagnostic application still running 
				     ; tests DMA bursts as bus master

;;; MFH - PCI burst error recovery
PCIDMA_RESTART		EQU	14
PCIDMA_RESUME		EQU	15
PCIDMA_RETRY		EQU	16

; HST timeout recovery....

MAX_DUMP		EQU	512	; if HST timeout.. max number that could be in FIFO is 511..
DUMP_BUFF		EQU	$1000	; store in Y memory above normal data buffer: in off-chip RAM



; Various addressing control registers
BCR	EQU	$FFFFFB		; Bus Control Register
DCR	EQU	$FFFFFA		; DRAM Control Register
AAR0	EQU	$FFFFF9		; Address Attribute Register, channel 0	
AAR1	EQU	$FFFFF8		; Address Attribute Register, channel 1	
AAR2	EQU	$FFFFF7		; Address Attribute Register, channel 2	
AAR3	EQU	$FFFFF6		; Address Attribute Register, channel 3	
PCTL	EQU	$FFFFFD		; PLL control register
IPRP	EQU	$FFFFFE		; Interrupt Priority register - Peripheral
IPRC	EQU	$FFFFFF		; Interrupt Priority register - Core

; PCI control register
DTXS	EQU	$FFFFCD		; DSP Slave transmit data FIFO
DTXM	EQU	$FFFFCC		; DSP Master transmit data FIFO
DRXR	EQU	$FFFFCB		; DSP Receive data FIFO
DPSR	EQU	$FFFFCA		; DSP PCI Status Register 
DSR	EQU	$FFFFC9		; DSP Status Register
DPAR	EQU	$FFFFC8		; DSP PCI Address Register
DPMC	EQU	$FFFFC7		; DSP PCI Master Control Register 
DPCR	EQU	$FFFFC6		; DSP PCI Control Register
DCTR	EQU	$FFFFC5		; DSP Control Register

; Port E is the Synchronous Communications Interface (SCI) port
PCRE	EQU	$FFFF9F		; Port Control Register
PRRE	EQU	$FFFF9E		; Port Direction Register
PDRE	EQU	$FFFF9D		; Port Data Register

; Various PCI register bit equates
STRQ	EQU	1		; Slave transmit data request (DSR)
SRRQ	EQU	2		; Slave receive data request (DSR) 
HACT	EQU	23		; Host active, low true (DSR)
MTRQ	EQU	1		; Set whem master transmitter is not full (DPSR)
MARQ	EQU	4		; Master address request (DPSR)
MRRQ	EQU	2		; Master Receive Request (DPSR)
TRTY	EQU	10		; PCI Target Retry (DPSR)

APER	EQU	5		; Address parity error
DPER	EQU	6		; Data parity error
MAB	EQU	7		; Master Abort
TAB	EQU	8		; Target Abort
TDIS	EQU	9		; Target Disconnect
TO	EQU	11		; Timeout
MDT	EQU	14		; Master Data Transfer complete
SCLK	EQU	2		; SCLK = transmitter special code

; bits in DPMC

FC1	EQU	23
FC0	EQU	22


; DMA register definitions
DSR0	EQU	$FFFFEF		; Source address register
DDR0	EQU	$FFFFEE		; Destination address register
DCO0	EQU	$FFFFED		; Counter register
DCR0	EQU	$FFFFEC		; Control register

; The DCTR host flags are written by the DSP and read by PCI host
DCTR_HF3	EQU	3		; used as a semiphore for INTA handshaking
DCTR_HF4  	EQU	4		; 
DCTR_HF5  	EQU	5		; 
INTA	   	EQU	6		; Request PCI interrupt

; The DSR host flags are written by the PCI host and read by the DSP
DSR_BUF0   EQU	4		; PCI host sets this when copying buffer 0
DSR_BUF1   EQU	5		; PCI host sets this when copying buffer 1

; DPCR bit definitions
CLRT	EQU	14		; Clear transmitter
MACE	EQU	18		; Master access counter enable
IAE	EQU	21		; Insert Address Enable

; Addresses of ESSI port
TX00	EQU	$FFFFBC		; Transmit Data Register 0
SSISR0	EQU	$FFFFB7		; Status Register
CRB0	EQU	$FFFFB6		; Control Register B
CRA0	EQU	$FFFFB5		; Control Register A

; SSI Control Register A Bit Flags
TDE	EQU	6		; Set when transmitter data register is empty

; Miscellaneous addresses
RDFIFO	EQU	$FFFFFF		; Read the FIFO for incoming fiber optic data
TCSR0	EQU	$FFFF8F		; Triper timer control and status register 0
TCSR1	EQU	$FFFF8B		; Triper timer control and status register 1
TCSR2	EQU	$FFFF87		; Triper timer control and status register 2

;***************************************************************
; Phase Locked Loop initialization
PLL_INIT EQU	$050003		; PLL = 25 MHz x 4 = 100 MHz
;****************************************************************

; Port C is Enhanced Synchronous Serial Port 0
PCRC	EQU	$FFFFBF		; Port C Control Register
PRRC	EQU	$FFFFBE		; Port C Data direction Register
PDRC	EQU	$FFFFBD		; Port C GPIO Data Register

; Port D is Enhanced Synchronous Serial Port 1
PCRD	EQU	$FFFFAF		; Port D Control Register
PRRD	EQU	$FFFFAE		; Port D Data direction Register
PDRD	EQU	$FFFFAD		; Port D GPIO Data Register

; Bit number definitions of GPIO pins on Port C
ROM_FIFO EQU	2		; Select ROM or FIFO accesses for AA1

; Bit number definitions of GPIO pins on Port D
EF	EQU	0		; FIFO Empty flag, low true
HF	EQU	1		; FIFO half full flag, low true
RS	EQU	2		; FIFO reset signal, low true
FSYNC	EQU	3		; High during image transmission
AUX1	EQU	4		; enable/disable byte swapping
WRFIFO	EQU	5		; Low true if FIFO is being written to


; Errors - self test application

Y_MEM_ER	EQU	0	; y memory corrupted
X_MEM_ER	EQU	1	; x memory corrupted
P_MEM_ER	EQU	2	; p memory corrupted
FO_EMPTY	EQU	3	; no transmitted data in FIFO

FO_OVER		EQU	4	; too much data received
FO_UNDER	EQU	5 	; not enough data receiv
FO_RX_ER	EQU	6	; received data in FIFO incorrect.
DEBUG		EQU	7	; debug bit




