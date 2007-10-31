 COMMENT *

This is the main section of the pci card code. 

Project:     SCUBA 2 
Author:      DAVID ATKINSON
Target:      250MHz SDSU PCI card - DSP56301
Controller:  For use with SCUBA 2 Multichannel Electronics 

Version:     Release Version A (2.0)


Assembler directives:
	DOWNLOAD=EEPROM => EEPROM CODE
	DOWNLOAD=ONCE => ONCE CODE

	*
	PAGE    132     ; Printronix page width - 132 columns
	OPT	CEX	; print DC evaluations

	MSG ' INCLUDE PCI_main.asm HERE  '

; --------------------------------------------------------------------------
; --------------------- MAIN PACKET HANDLING CODE --------------------------
; --------------------------------------------------------------------------

; initialse buffer pointers	
PACKET_IN

; R1 used as pointer for data written to y:memory            FO --> (Y)
; R2 used as pointer for date in y mem to be writen to host  (Y) --> HOST

		MOVE	#<IMAGE_BUFFER,R1		; pointer for Fibre ---> Y mem
		MOVE	#<IMAGE_BUFFER,R2		; pointer for Y mem ---> PCI BUS	

; initialise some bits in status..	
		BCLR	#SEND_TO_HOST,X:<STATUS		; clear send to host flag
		BCLR	#HST_NFYD,X:<STATUS		; clear flag to indicate host has been notified.
		BCLR	#FO_WRD_RCV,X:<STATUS		; clear Fiber Optic flag

; check some bits in status....
		JSET	#FATAL_ERROR,X:<STATUS,START		       ; fatal error?  Go to initialisation.
		JSET	#APPLICATION_LOADED,X:<STATUS,APPLICATION      ; application loaded?  Execute in appl space.
		JSET	#INTERNAL_GO,X:<STATUS,APPLICATION	       ; internal GO to process?  PCI bus master write test.
					
CHK_FIFO	JSR	<GET_FO_WRD		      		       ; see if there's a 16-bit word in Fibre FIFO from MCE 
						      
						
		JSET	#FO_WRD_RCV,X:<STATUS,CHECK_WD	               ; there is a word - check if it's preamble
		JMP	<PACKET_IN				       ; else go back and repeat

; check that we preamble sequence

CHECK_WD	JSET	#PACKET_CHOKE,X:<STATUS,PACKET_IN	; IF MCE Packet choke on - just keep clearing FIFO.
		MOVE	X0,X:<HEAD_W1_0				;store received word
		MOVE	X:PREAMB1,A
		CMP	X0,A					; check it is correct
		JNE	<PRE_ERROR				; if not go to start


		JSR	<WT_FIFO		; wait for next preamble 16-bit word
		MOVE	X0,X:<HEAD_W1_1		;store received word
		MOVE	X:PREAMB1,A
		CMP	X0,A			; check it is correct
		JNE	<PRE_ERROR		; if not go to start


		JSR	<WT_FIFO		; wait for next preamble 16-bit word
		MOVE	X0,X:<HEAD_W2_0		;store received word
		MOVE	X:PREAMB2,A
		CMP	X0,A			; check it is correct
		JNE	<PRE_ERROR		; if not go to start

		JSR	<WT_FIFO		; wait for next preamble 16-bit word
		MOVE	X0,X:<HEAD_W2_1		;store received word
		MOVE	X:PREAMB2,A
		CMP	X0,A			; check it is correct
		JNE	<PRE_ERROR		; if not go to start
		JMP	<PACKET_INFO		; get packet info

	
PRE_ERROR	
		BSET	#PREAMBLE_ERROR,X:<STATUS	; indicate a preamble error
                MOVE	X0,X:<PRE_CORRUPT		; store corrupted word

; preampble error so clear out both FIFOs using reset line
; - protects against an odd number of bytes having been sent 
; (byte swapping on - so odd byte being would end up in 
; the FIFO without the empty flag)

		MOVEP	#%011000,X:PDRD			; clear FIFO RESET* for 2 ms
		MOVE	#200000,X0
		DO	X0,*+3
		NOP
		MOVEP	#%011100,X:PDRD

		JMP	<PACKET_IN			; wait for next packet


PACKET_INFO                                            ; packet preamble valid

; Packet preamble is valid so....
; now get next two 32bit words.  i.e. $20205250 $00000004, or $20204441 $xxxxxxxx
; note that these are received little endian (and byte swapped)
; i.e. for RP receive 50 52 20 20  04 00 00 00
; but byte swapped on arrival
; 5250
; 2020
; 0004
; 0000

		JSR	<WT_FIFO	
		MOVE	X0,X:<HEAD_W3_0		; RP or DA
		JSR	<WT_FIFO	
		MOVE	X0,X:<HEAD_W3_1		; $2020

		JSR	<WT_FIFO	
		MOVE	X0,X:<HEAD_W4_0		; packet size lo
		JSR	<WT_FIFO	
		MOVE	X0,X:<HEAD_W4_1		; packet size hi
		
		MOVE    X:<HEAD_W3_0,X0		; get data header word 3 (low 2 bytes)
		MOVE    X:<REPLY_WD,A		; $5250
		CMP	X0,A			; is it a reply packet?
		JEQ	MCE_PACKET              ; yes - go process it.

		MOVE    X:<DATA_WD,A		; $4441
		CMP	X0,A			; is it a data packet?
		JNE	<PACKET_IN              ; no?  Not a valid packet type.  Go back to start and resync to next preamble.


; It's a data packet.
; check if it's the first packet after the GO command has been issued.

                JCLR  	#DATA_DLY,X:STATUS,INC_FRAME_COUNT        ; do we need to add a delay since first frame?

; yes first frame after GO reply packet so add a delay.
PACKET_DELAY 
		MOVE	X:DATA_DLY_VAL,X0
		DO	X0,*+3			; 10ns x DATA_DLY_VAL
		NOP
                NOP
                BCLR 	#DATA_DLY,X:STATUS	; clear so delay isn't added next time.


INC_FRAME_COUNT					; increment frame count 
		CLR	A
		MOVE	X:<FRAME_COUNT,A0
		INC	A
		NOP
		MOVE	A0,X:<FRAME_COUNT

; -------------------------------------------------------------------------------------------
; ----------------------------------- IT'S A PAKCET FROM MCE --------------------------------
; ------------------------------------------------------------------------------------------- 
; prepare notify to inform host that a packet has arrived.

MCE_PACKET
		MOVE	#'NFY',X0		; initialise communication to host as a notify
		MOVE	X0,X:<DTXS_WD1		; 1st word transmitted to host in notify message

		MOVE	X:<HEAD_W3_0,X0		;RP or DA - top two bytes of word 3 ($2020) not passed to driver.
		MOVE	X0,X:<DTXS_WD2		;2nd word transmitted to host in notify message

		MOVE	X:<HEAD_W4_0,X0		; size of packet LSB 16bits (# 32bit words)
		MOVE	X0,X:<DTXS_WD3		; 3rd word transmitted to host in notify message

		MOVE	X:<HEAD_W4_1,X0		; size of packet MSB 16bits (# of 32bit words)
		MOVE	X0,X:<DTXS_WD4		; 4th word transmitted to host in notify messasge

		CLR	A			; 
		MOVE	#0,R4			; initialise word count
		MOVE	A,X:<WORD_COUNT	  	; initialise word count store (num of words written over bus/packet)
		MOVE	A,X:<NUM_DUMPED		; initialise number dumped from FIFO (after HST TO)


; ----------------------------------------------------------------------------------------------------------
; Determine how to break up packet to write to host.
; Determine number of Half Full FIFOs will be read in and number of left over words in FIFO.
; Determine the number of maximum PCI write bursts (256 bytes) are required
; to write the packet to host, and the size of the left over burst.

; Note that this SR uses accumulator B 
; Therefore execute before we get the bus address from host (which is stored in B) 
; i.e before we issue notify message ('NFY')

		JSR	<CALC_NO_BUFFS		; subroutine which calculates the number of 512 (16bit)
				
; -------------------------------------------------------------------------------------------------


; notify the host that there is a packet.....
		
		JSR	<PCI_MESSAGE_TO_HOST			; notify host of packet	
		BSET	#HST_NFYD,X:<STATUS			; flag to indicate host has been notified.

; initialise read/write buffers 
; AND IMMEDIATELY BEGIN TO BUFFER FIBRE DATA TO Y MEMORY.

		MOVE	#<IMAGE_BUFFER,R1		; FO ---> Y mem
		MOVE	#<IMAGE_BUFFER,R2		; Y mem ----->  PCI BUS	


; ---------------------------------------------------------------------------------------------------------
; Write TOTAL_BUFFS * 512 buffers to host
; ----------------------------------------------------------------------------------------------------				
		DO	X:<TOTAL_BUFFS,READ_BUFFS_END	
	
WAIT_BUFF	JSET	#FATAL_ERROR,X:<STATUS,DUMP_FIFO  ; if fatal error then dump fifo and reset (i.e. if HST timeout)
		JSET	#HF,X:PDRD,WAIT_BUFF		  ; Wait for FIFO to be half full + 1
		NOP
		NOP
		JSET	#HF,X:PDRD,WAIT_BUFF		 ; Protection against metastability

; Copy the image block as 512 x 16bit words to DSP Y: Memory using R1 as pointer
		DO	#512,L_BUFFER
		MOVEP	Y:RDFIFO,Y:(R1)+
L_BUFFER
		NOP
READ_BUFFS_END							; all buffers have been read (-->Y)	

; ---------------------------------------------------------------------------------------------------------
; Read NUM_LEFTOVER_BLOCKS * 128 blocks to host
; ----------------------------------------------------------------------------------------------------		
; less than 512 Y Memory locations then read in N x 128 (x16bit words) 

		DO	X:<NUM_LEFTOVER_BLOCKS,READ_BLOCKS

		DO	#128,S_BUFFER
WAIT_1		JSET	#FATAL_ERROR,X:<STATUS,DUMP_FIFO ; check for fatal error (i.e. after HST timeout)
		JCLR	#EF,X:PDRD,WAIT_1		; Wait for the pixel datum to be there
		NOP					; Settling time
		NOP
		JCLR	#EF,X:PDRD,WAIT_1		; Protection against metastability
		MOVEP	Y:RDFIFO,Y:(R1)+		; save fibre word
S_BUFFER
		NOP
READ_BLOCKS

; -----------------------------------------------------------------------------------------------------
; Left over data to read from FIFO
; ----------------------------------------------------------------------------------------------------	

LEFT_OVERS	
		DO	X:<LEFT_TO_READ,LEFT_OVERS_READ		; read in remaining words of data packet
			

WAIT_2		JSET	#FATAL_ERROR,X:<STATUS,START		; check for fatal error (i.e. after HST timeout)
		JCLR	#EF,X:PDRD,WAIT_2			; Wait till something in FIFO flagged
		NOP
		NOP
		JCLR	#EF,X:PDRD,WAIT_2		   	; protect against metastability.....
		MOVEP	Y:RDFIFO,Y:(R1)+			; save fibre word	
LEFT_OVERS_READ

;---------------------------------------------------------------------------------------
; ENTIRE PACKET NOW IN Y MEMORY
;----------------------------------------------------------------------------------------
; CHECK THAT HST COMMAND WAS ISSUED DURING DATA COLLECTION...


WT_HOST		JSET	#FATAL_ERROR,X:<STATUS,START		; if fatal error - run initialisation code...
		JCLR	#SEND_TO_HOST,X:<STATUS,WT_HOST		; wait for host to reply - which it does with 'send_packet_to_host' ISR

; we now have 32 bit address in accumulator B
; from send-packet_to_host (HST COMMAND) which should of been issued during data collection.

; Write all data to host.

; ---------------------------------------------------------------------------------------------------------
; Write N * maximum bursts over bus.  Each burst writes from 128 y memory locations
; R2 points to data in Y memory to be written to host
; host address is in B - got by SEND_PACKET_TO_HOST command 
; ----------------------------------------------------------------------------------------------------				

		DO	X:<NMAX_BURSTS,WRITE_BUFFS_END		; write N x 256 byte bursts.
		MOVE	#>128,X0
		MOVE	X0,X:NBURST_YMEM			; # of locations in y memory (256bytes)		
		JSR	<WRITE_PCI_BURST
		NOP
WRITE_BUFFS_END							; all buffers have been writen to host	
		JSET	#FATAL_ERROR,X:<STATUS,START

; ---------------------------------------------------------------------------------------------------------
; Burst the final data words over the PCI bus
; ----------------------------------------------------------------------------------------------------		

		CLR	A
		MOVE	X:LEFT_TO_READ,X0		; number of left over 16-bit words in Y memory
		MOVE	X0,X:NBURST_YMEM
		CMP	X0,A	
		JEQ	HST_ACK_REP			; Check that there are words to write.
		JSR	<WRITE_PCI_BURST
		JSET	#FATAL_ERROR,X:<STATUS,START

; ----------------------------------------------------------------------------------------------------------
; reply to host's send_packet_to_host command

HST_ACK_REP	MOVE	#'REP',X0
		MOVE	X0,X:<DTXS_WD1		; REPly
		MOVE	#'HST',X0
		MOVE	X0,X:<DTXS_WD2		; echo command sent
		MOVE	#'ACK',X0
		MOVE	X0,X:<DTXS_WD3		; ACKnowledge okay
		MOVE	#'000',X0
		MOVE	X0,X:<DTXS_WD4		; no error
		JSR	<PCI_MESSAGE_TO_HOST
		JMP	<PACKET_IN

;---------------------------------------------------------------------------------------------------
; clear out the fifo after an HST timeout...
;----------------------------------------------------------

DUMP_FIFO	MOVE	#DUMP_BUFF,R1		; address where dumped words stored in Y mem
		MOVE	#MAX_DUMP,X0		; put a limit to number of words read from fifo
		CLR	A
		MOVE	#0,R2			; use R2 as a dump count

NEXT_DUMP	JCLR	#EF,X:PDRD,FIFO_EMPTY
		NOP
		NOP
		JCLR	#EF,X:PDRD,FIFO_EMPTY

		MOVEP	Y:RDFIFO,Y:(R1)+	; dump word to Y mem.
		MOVE	(R2)+			; inc dump count
		MOVE	R2,A			; 	
		CMP	X0,A			; check we've not hit dump limit
		JNE	NEXT_DUMP		; not hit limit?


FIFO_EMPTY	MOVE	R2,X:NUM_DUMPED		; store number of words dumped after HST timeout.
		JMP	<START			; re-initialise



; ------------------------------------------------------------------------------------------------
;                              END OF MAIN PACKET HANDLING CODE
; ---------------------------------------------------------------------------------------------


; -------------------------------------------------------------------------------------
;
;                              INTERRUPT SERVICE ROUTINES 
;
; ---------------------------------------------------------------------------------------

;--------------------------------------------------------------------
CLEAN_UP_PCI
;--------------------------------------------------------------------
; Clean up the PCI board from wherever it was executing

	MOVEP	#$0001C0,X:IPRC		; Disable HF* FIFO interrupt
	MOVE	#$200,SR		; mask for reset interrupts only

	MOVEC	#1,SP			; Point stack pointer to the top	
	MOVEC	#$000200,SSL		; SR = zero except for interrupts
	MOVEC	#0,SP			; Writing to SSH preincrements the SP
	MOVEC	#START,SSH		; Set PC to for full initialization
	NOP
	RTI

; ---------------------------------------------------------------------------
READ_MEMORY
;--------------------------------------------------------------------------
; word 1 = command = 'RDM'
; word 2 = memory type, P=$00'_P', X=$00_'X' or Y=$00_'Y'
; word 3 = address in memory
; word 4 = not used

	JSR	<SAVE_REGISTERS		; save working registers

	JSR	<RD_DRXR		; read words from host write to HTXR
	MOVE	X:DRXR_WD1,A		; read command
	MOVE	#'RDM',X0
	CMP	X0,A			; ensure command is 'RDM'
	JNE	<READ_MEMORY_ERROR_CNE	; error, command NOT HCVR address
	MOVE	X:<DRXR_WD2,A		; Memory type (X, Y, P)
	MOVE	X:<DRXR_WD3,B
	NOP				; pipeline restriction
	MOVE	B1,R0			; get address to write to
	CMP	#$005F50,A		; $00'_P'
        JNE	<RDX	
        MOVE	P:(R0),X0		; Read from P memory
	MOVE	X0,A			; 
        JMP     <FINISH_READ_MEMORY
RDX
	CMP	#$005F58,A		; $00'_X'
        JNE	<RDY
	MOVE	X:(R0),X0		; Read from P memory
	MOVE	X0,A	
        JMP     <FINISH_READ_MEMORY
RDY
	CMP	#$005F59,A		; $00'_Y'
        JNE	<READ_MEMORY_ERROR_MTE	; not a valid memory type	
	MOVE	Y:(R0),X0		; Read from P memory
	MOVE	X0,A	

; when completed successfully then PCI needs to reply to Host with
; word1 = reply/data = reply
FINISH_READ_MEMORY
	MOVE	#'REP',X0
	MOVE	X0,X:<DTXS_WD1		; REPly
	MOVE	#'RDM',X0
	MOVE	X0,X:<DTXS_WD2		; echo command sent
	MOVE	#'ACK',X0
	MOVE	X0,X:<DTXS_WD3		;  im command
	MOVE	A,X0
	MOVE	X0,X:<DTXS_WD4		; write to PCI memory error
	JSR	<RESTORE_REGISTERS	; restore registers 
	JSR	<PCI_MESSAGE_TO_HOST	; interrupt host with message (x0 restored here)
	RTI

READ_MEMORY_ERROR_CNE
	MOVE	#'CNE',X0		
	MOVE	X0,X:<DTXS_WD4		; Command Name Error - command name in DRXR does not match
	JMP	READ_MEMORY_ERROR	; fill in rest of reply
READ_MEMORY_ERROR_MTE
	MOVE	#'MTE',X0				
	MOVE	X0,X:<DTXS_WD4		;  Memory Type Error - not a valid memory type

READ_MEMORY_ERROR
	MOVE	#'REP',X0
	MOVE	X0,X:<DTXS_WD1		; REPly
	MOVE	#'RDM',X0
	MOVE	X0,X:<DTXS_WD2		; echo command sent
	MOVE	#'ERR',X0
	MOVE	X0,X:<DTXS_WD3		; ERRor.
	JSR	<RESTORE_REGISTERS	; restore working registers	
	JSR	<PCI_MESSAGE_TO_HOST 	; interrupt host with message (x0 restored here)
	RTI
		
;-----------------------------------------------------------------------------
RESET_CONTROLLER
; Reset the controller by sending a special code byte $0B with SC/nData = 1
;---------------------------------------------------------------------------
; word 1 = command = 'RCO'
; word 2 = not used but read
; word 3 = not used but read
; word 4 = not used but read

	JSR	<SAVE_REGISTERS		; save working registers
	JSR	<RD_DRXR		; read words from host write to HTXR
	MOVE	X:<DRXR_WD1,A		; read command
	MOVE	#'RCO',X0
	CMP	X0,A			; ensure command is 'RCO'
	JNE	<RCO_ERROR		; error, command NOT HCVR address

; if we get here then everything is fine and we can send reset to controller    

; 250MHZ CODE....

	BSET	#SCLK,X:PDRE		; Enable special command mode
	NOP
	NOP
	MOVE	#$FFF000,R0		; Memory mapped address of transmitter
	MOVE	#$10000B,X0		; Special command to reset controller
	MOVE	X0,X:(R0)
	REP	#6			; Wait for transmission to complete
	NOP
	BCLR	#SCLK,X:PDRE		; Disable special command mode

; Wait for a bit for MCE to be reset.......
	MOVE	#10000,X0		; Delay by about 350 milliseconds
	DO	X0,L_DELAY
	DO	#1000,L_RDFIFO
	MOVEP	Y:RDFIFO,Y0		; Read the FIFO word to keep the
	NOP				;   receiver empty
L_RDFIFO
	NOP
L_DELAY
	NOP	

; when completed successfully then PCI needs to reply to Host with
; word1 = reply/data = reply
FINISH_RCO
	MOVE	#'REP',X0
	MOVE	X0,X:<DTXS_WD1		; REPly
	MOVE	#'RCO',X0
	MOVE	X0,X:<DTXS_WD2		; echo command sent
	MOVE	#'ACK',X0
	MOVE	X0,X:<DTXS_WD3		; ACKnowledge okay
	MOVE	#'000',X0
	MOVE	X0,X:<DTXS_WD4		; read data
	JSR	<RESTORE_REGISTERS	; restore working registers
	JSR	<PCI_MESSAGE_TO_HOST    ; interrupt host with message (x0 restored here)
	RTI				; return from ISR

; when there is a failure in the host to PCI command then the PCI
; needs still to reply to Host but with an error message
RCO_ERROR
	MOVE	#'REP',X0
	MOVE	X0,X:DTXS_WD1		; REPly
	MOVE	#'RCO',X0
	MOVE	X0,X:DTXS_WD2		; echo command sent
	MOVE	#'ERR',X0
	MOVE	X0,X:DTXS_WD3		; ERRor im command
	MOVE	#'CNE',X0		
	MOVE	X0,X:DTXS_WD4		; Command Name Error - command name in DRXR does not match
	JSR	<RESTORE_REGISTERS      ; restore wroking registers
	JSR	<PCI_MESSAGE_TO_HOST    ; interrupt host with message (x0 restored here)
	RTI				; return from ISR

	
;----------------------------------------------------------------------
SEND_PACKET_TO_CONTROLLER

; forward packet stuff to the MCE
; gets address in HOST memory where packet is stored
; read 3 consecutive locations starting at this address
; then sends the data from these locations up to the MCE
;----------------------------------------------------------------------

; word 1 = command = 'CON'
; word 2 = host high address
; word 3 = host low address
; word 4 = '0' --> when MCE command is RS,WB,RB,ST
;	 = '1' --> when MCE command is GO  

; all MCE commands are now 'block commands'
; i.e. 64 words long.

	JSR	<SAVE_REGISTERS		; save working registers

	JSR	<RD_DRXR		; read words from host write to HTXR
					; reads as 4 x 24 bit words

	MOVE	X:<DRXR_WD1,A		; read command
	MOVE	#'CON',X0
	CMP	X0,A			; ensure command is 'CON'
	JNE	<CON_ERROR		; error, command NOT HCVR address 

; convert 2 x 24 bit words ( only 16 LSBs are significant) from host into 32 bit address 
	CLR	B
	MOVE	X:<DRXR_WD2,X0		; MS 16bits of address
	MOVE	X:<DRXR_WD3,B0		; LS 16bits of address
	INSERT	#$010010,X0,B		; convert to 32 bits and put in B

	MOVE	X:<DRXR_WD4,A		; read word 4 - GO command?
	MOVE	X:ZERO,X0
	CMP	X0,A
	JEQ	BLOCK_CON

; debug: toggle TOUT to indicate go command issued (monitor pin 26 on Dtype)
	MOVEP	#%010,X:PDRE		; Port E Data Register (TXD-->TOUT)

	JCLR	#APPLICATION_RUNNING,X:STATUS,SET_PACKET_DELAY	; not running diagnostic application?

; need to generate an internal go command to test master write on bus.....  Diagnostic test
	BSET	#INTERNAL_GO,X:STATUS	; set flag so that GO reply / data is generated by PCI card... 					

; since INTERNAL_GO  - read command but don't send it to MCE...

CLR_CMD
	DO	#64,END_CLR_CMD		; block size = 32bit x 64 (256 bytes)
	JSR	<READ_FROM_PCI		; get next 32 bit word from HOST
	NOP
END_CLR_CMD
	JMP	FINISH_CON		; don't send out on command on fibre
	
		
SET_PACKET_DELAY
	BSET	#DATA_DLY,X:STATUS      ; set data delay so that next data packet after go reply
                                        ; experiences a delay before host notify.

; -----------------------------------------------------------------------
; WARNING!!!
; MCE requires IDLE characters between 32bit words sent FROM the PCI card
; DO not change READ_FROM_PCI to DMA block transfer....
; ------------------------------------------------------------------------

BLOCK_CON
	MOVE	X:CONSTORE,R6

	DO	#64,END_BLOCK_CON	; block size = 32bit x 64 (256 bytes)
	JSR	<READ_FROM_PCI		; get next 32 bit word from HOST
	MOVE	X0,A1			; prepare to send
	MOVE	X1,A0			; prepare to send

	MOVE	X1,Y:(R6)+		; b4, b3 (msb)		
	MOVE	X0,Y:(R6)+		; b2, b1  (lsb)

	JSR	<XMT_WD_FIBRE		; off it goes
	NOP
END_BLOCK_CON

	MOVEP	#%001,X:PDRE		; re-initialise Port Data Register - GO done.
	BCLR	#PACKET_CHOKE,X:<STATUS	; disable packet choke...
					; comms now open with MCE and packets will be processed.	
; Enable Byte swaping for correct comms protocol.
	BSET	#BYTE_SWAP,X:<STATUS	; flag to let host know byte swapping on
	BSET	#AUX1,X:PDRC		; enable hardware


; -------------------------------------------------------------------------
; when completed successfully then PCI needs to reply to Host with
; word1 = reply/data = reply
FINISH_CON
	MOVE	#'REP',X0
	MOVE	X0,X:<DTXS_WD1		; REPly
	MOVE	#'CON',X0
	MOVE	X0,X:<DTXS_WD2		; echo command sent
	MOVE	#'ACK',X0
	MOVE	X0,X:<DTXS_WD3		; ACKnowledge okay
	MOVE	#'000',X0
	MOVE	X0,X:<DTXS_WD4		; read data
	JSR	<RESTORE_REGISTERS	; restore working registers
	JSR	<PCI_MESSAGE_TO_HOST    ;  interrupt host with message (x0 restored here)
	RTI				; return from ISR

; when there is a failure in the host to PCI command then the PCI
; needs still to reply to Host but with an error message
CON_ERROR
	MOVE	#'REP',X0
	MOVE	X0,X:<DTXS_WD1		; REPly
	MOVE	#'CON',X0
	MOVE	X0,X:<DTXS_WD2		; echo command sent
	MOVE	#'ERR',X0
	MOVE	X0,X:<DTXS_WD3		; ERRor im command
	MOVE	#'CNE',X0		
	MOVE	X0,X:<DTXS_WD4		; Command Name Error - command name in DRXR does not match
	JSR	<RESTORE_REGISTERS    	; restore working registers
	JSR	<PCI_MESSAGE_TO_HOST  	; interrupt host with message (x0 restored here)  
	RTI				; return from ISR

; ------------------------------------------------------------------------------------
SEND_PACKET_TO_HOST
; this command is received from the Host and actions the PCI board to pick up an address
; pointer from DRXR which the PCI board then uses to write packets from the 
; MCE to the host memory starting at the address given.
; Since this is interrupt driven all this piece of code does is get the address pointer from
; the host via DRXR, set a flag so that the main prog can write the packet.  Replies to  
; HST after packet sent (unless error).
; --------------------------------------------------------------------------------------
; word 1 = command = 'HST'
; word 2 = host high address
; word 3 = host low address
; word 4 = not used but read

; save some registers but not B

	JSR	<SAVE_REGISTERS		; save working registers

	JSR	<RD_DRXR		; read words from host write to HTXR
	CLR	B
	MOVE	X:<DRXR_WD1,A		; read command
	MOVE	#'HST',X0
	CMP	X0,A			; ensure command is 'HST'
	JNE	<HOST_ERROR		; error, command NOT HCVR address
	MOVE	X:<DRXR_WD2,X0		; high 16 bits of address 
	MOVE	X:<DRXR_WD3,B0		; low 16 bits of adderss
	INSERT	#$010010,X0,B		; convert to 32 bits and put in B

	BSET	#SEND_TO_HOST,X:<STATUS	 ; tell main program to write packet to host memory
	JSR	<RESTORE_HST_REGISTERS	 ; restore registers for HST .... B not restored..
	RTI

; !!NOTE!!!
; successful reply to this command is sent after packet has been send to host.
; Not here unless error.

; when there is a failure in the host to PCI command then the PCI
; needs still to reply to Host but with an error message
HOST_ERROR
	BCLR	#SEND_TO_HOST,X:STATUS
	MOVE	#'REP',X0
	MOVE	X0,X:<DTXS_WD1		; REPly
	MOVE	#'HST',X0
	MOVE	X0,X:<DTXS_WD2		; echo command sent
	MOVE	#'ERR',X0
	MOVE	X0,X:<DTXS_WD3		; ERRor im command
	MOVE	#'CNE',X0
	MOVE	X0,X:<DTXS_WD4		; Command Name Error - command name in DRXR does not match
	JSR	<RESTORE_REGISTERS	; restore working registers
	JSR	<PCI_MESSAGE_TO_HOST	; interrupt host with message (x0 restored here)
	RTI

; --------------------------------------------------------------------
SOFTWARE_RESET
;----------------------------------------------------------------------
; word 1 = command = 'RST'
; word 2 = not used but read
; word 3 = not used but read
; word 4 = not used but read

	JSR	<SAVE_REGISTERS

	JSR	<RD_DRXR		; read words from host write to HTXR
	MOVE	X:<DRXR_WD1,A		; read command
	MOVE	#'RST',X0
	CMP	X0,A			; ensure command is 'RST'
	JNE	<RST_ERROR		; error, command NOT HCVR address

; RST command OK so reply to host
FINISH_RST
	MOVE	#'REP',X0
	MOVE	X0,X:<DTXS_WD1		; REPly
	MOVE	#'RST',X0
	MOVE	X0,X:<DTXS_WD2		; echo command sent
	MOVE	#'ACK',X0
	MOVE	X0,X:<DTXS_WD3		; ACKnowledge okay
	MOVE	#'000',X0
	MOVE	X0,X:<DTXS_WD4		; read data
	JSR	<PCI_MESSAGE_TO_HOST

	JSET	#DCTR_HF3,X:DCTR,*
	
	BCLR	#APPLICATION_LOADED,X:<STATUS	; clear app flag
        BCLR	#PREAMBLE_ERROR,X:<STATUS	; clear preamble error
	BCLR	#APPLICATION_RUNNING,X:<STATUS  ; clear appl running bit.

; initialise some parameter here - that we don't want to initialse under a fatal error reset.

	CLR	A			
	MOVE	#0,R4			; initialise word count
	MOVE	A,X:<WORD_COUNT	  	; initialise word count store (num of words written over bus/packet)
	MOVE	A,X:<NUM_DUMPED		; initialise number dumped from FIFO (after HST TO)


; remember we are in a ISR so can't just jump to start.

	MOVEP	#$0001C0,X:IPRC		; Disable HF* FIFO interrupt
	MOVE	#$200,SR		; Mask set up for reset switch only.


	MOVEC	#1,SP			; Point stack pointer to the top	
	MOVEC	#$000200,SSL		; SSL holds SR return state
					; set to zero except for interrupts
	MOVEC	#0,SP			; Writing to SSH preincrements the SP
					; so first set to 0
	MOVEC	#START,SSH		; SSH holds return address of PC
					; therefore,return to initialization
	NOP
	RTI				; return from ISR - to START

; when there is a failure in the host to PCI command then the PCI
; needs still to reply to Host but with an error message
RST_ERROR
	MOVE	#'REP',X0
	MOVE	X0,X:<DTXS_WD1		; REPly
	MOVE	#'RST',X0
	MOVE	X0,X:<DTXS_WD2		; echo command sent
	MOVE	#'ERR',X0
	MOVE	X0,X:<DTXS_WD3		; ERRor im command
	MOVE	#'CNE',X0
	MOVE	X0,X:<DTXS_WD4		; Command Name Error - command name in DRXR does not match
	JSR	<RESTORE_REGISTERS	; restore working registers
	JSR	<PCI_MESSAGE_TO_HOST 	; interrupt host with message (x0 restored here)
	RTI				; return from ISR


;-----------------------------------------------------------------------------
START_APPLICATION
; an application should already have been downloaded to the PCI memory.
; this command will execute it.
; ----------------------------------------------------------------------
; word 1 = command = 'GOA'
; word 2 = not used but read by RD_DRXR
; word 3 = not used but read by RD_DRXR
; word 4 = not used but read by RD_DRXR
	
	JSR	<SAVE_REGISTERS		; save working registers

	JSR	<RD_DRXR		; read words from host write to HTXR
	MOVE	X:<DRXR_WD1,A		; read command
	MOVE	#'GOA',X0
	CMP	X0,A			; ensure command is 'RDM'
	JNE	<GO_ERROR		; error, command NOT HCVR address

; if we get here then everything is fine and we can start the application
; set bit in status so that main fibre servicing code knows to jump
; to application space after returning from this ISR

; reply after application has been executed.
	BSET	#APPLICATION_LOADED,X:<STATUS	
	RTI				; return from ISR
	

; when there is a failure in the host to PCI command then the PCI
; needs still to reply to Host but with an error message
GO_ERROR
	MOVE	#'REP',X0
	MOVE	X0,X:<DTXS_WD1	; REPly
	MOVE	#'GOA',X0
	MOVE	X0,X:<DTXS_WD2	; echo command sent
	MOVE	#'ERR',X0
	MOVE	X0,X:<DTXS_WD3	; ERRor im command
	MOVE	#'CNE',X0
	MOVE	X0,X:<DTXS_WD4		; Command Name Error - command name in DRXR does not match
	JSR	<RESTORE_REGISTERS	; restore working registers
	JSR	<PCI_MESSAGE_TO_HOST	; interrupt host with message (x0 restored here)
	RTI				; return from ISR

; ---------------------------------------------------------
STOP_APPLICATION
; this command stops an application that is currently running
; used for applications that once started run contiunually
;-----------------------------------------------------------

; word 1 = command = ' STP'
; word 2 = not used but read
; word 3 = not used but read
; word 4 = not used but read

	JSR	<SAVE_REGISTERS

	JSR	<RD_DRXR		; read words from host write to HTXR
	MOVE	X:<DRXR_WD1,A		; read command
	MOVE	#'STP',X0
	CMP	X0,A			; ensure command is 'RDM'
	JNE	<STP_ERROR		; error, command NOT HCVR address

	BCLR	#APPLICATION_LOADED,X:<STATUS
	BCLR	#APPLICATION_RUNNING,X:STATUS	

; when completed successfully then PCI needs to reply to Host with
; word1 = reply/data = reply
FINISH_STP
	MOVE	#'REP',X0
	MOVE	X0,X:<DTXS_WD1		; REPly
	MOVE	#'STP',X0
	MOVE	X0,X:<DTXS_WD2		; echo command sent
	MOVE	#'ACK',X0
	MOVE	X0,X:<DTXS_WD3		; ACKnowledge okay
	MOVE	#'000',X0
	MOVE	X0,X:<DTXS_WD4		; read data
	JSR	<RESTORE_REGISTERS	; restore working registers.
	JSR	<PCI_MESSAGE_TO_HOST	; interrupt host with message (x0 restored here)
	RTI

; when there is a failure in the host to PCI command then the PCI
; needs still to reply to Host but with an error message
STP_ERROR
	MOVE	#'REP',X0
	MOVE	X0,X:<DTXS_WD1		; REPly
	MOVE	#'STP',X0
	MOVE	X0,X:<DTXS_WD2		; echo command sent
	MOVE	#'ERR',X0
	MOVE	X0,X:<DTXS_WD3		; ERRor im command
	MOVE	#'CNE',X0
	MOVE	X0,X:<DTXS_WD4		; Command Name Error - command name in DRXR does not match
	JSR	<RESTORE_REGISTERS	; restore working registers
	JSR	<PCI_MESSAGE_TO_HOST	; interrupt host with message (x0 restored here)
	RTI	

;--------------------------------------------------------------	
WRITE_MEMORY
;---------------------------------------------------------------
; word 1 = command = 'WRM'
; word 2 = memory type, P=$00'_P', X=$00'_X' or Y=$00'_Y'
; word 3 = address in memory
; word 4 = value 

	JSR	<SAVE_REGISTERS		; save working registers

	JSR	<RD_DRXR		; read words from host write to HTXR
	MOVE	X:DRXR_WD1,A		; read command
	MOVE	#'WRM',X0
	CMP	X0,A			; ensure command is 'WRM'
	JNE	<WRITE_MEMORY_ERROR_CNE	; error, command NOT HCVR address
	MOVE	X:<DRXR_WD2,A		; Memory type (X, Y, P)
	MOVE	X:<DRXR_WD3,B
	NOP				; pipeline restriction
	MOVE	B1,R0			; get address to write to
	MOVE	X:<DRXR_WD4,X0		; get data to write
	CMP	#$005F50,A		; $00'_P'
        JNE	<WRX	
        MOVE	X0,P:(R0)		; Write to Program memory
        JMP     <FINISH_WRITE_MEMORY
WRX
	CMP	#$005F58,A		; $00'_X'
        JNE	<WRY
        MOVE    X0,X:(R0)		; Write to X: memory
        JMP     <FINISH_WRITE_MEMORY
WRY
	CMP	#$005F59,A		; $00'_Y'
        JNE	<WRITE_MEMORY_ERROR_MTE	
        MOVE    X0,Y:(R0)		; Write to Y: memory

; when completed successfully then PCI needs to reply to Host with
; word1 = reply/data = reply
FINISH_WRITE_MEMORY
	MOVE	#'REP',X0
	MOVE	X0,X:<DTXS_WD1		; REPly
	MOVE	#'WRM',X0
	MOVE	X0,X:<DTXS_WD2		; echo command sent
	MOVE	#'ACK',X0
	MOVE	X0,X:<DTXS_WD3		; ACKnowledge okay
	MOVE	#'000',X0
	MOVE	X0,X:<DTXS_WD4		; no error
	JSR	<RESTORE_REGISTERS	; restore working registers
	JSR	<PCI_MESSAGE_TO_HOST	; interrupt host with message (x0 restored here)
	RTI

; 
WRITE_MEMORY_ERROR_CNE
	MOVE	#'CNE',X0
	MOVE	X0,X:<DTXS_WD4		; Command Name Error - command name in DRXR does not match
	JMP	<WRITE_MEMORY_ERROR	; fill in rest of reply

WRITE_MEMORY_ERROR_MTE
	MOVE	#'MTE',X0
	MOVE	X0,X:<DTXS_WD4		; Memory Type Error - memory type not valid

WRITE_MEMORY_ERROR
	MOVE	#'REP',X0
	MOVE	X0,X:<DTXS_WD1		; REPly
	MOVE	#'WRM',X0
	MOVE	X0,X:<DTXS_WD2		; echo command sent
	MOVE	#'ERR',X0
	MOVE	X0,X:<DTXS_WD3		; ERRor im command
	JSR	<RESTORE_REGISTERS	; restore working registers
	JSR	<PCI_MESSAGE_TO_HOST	; interrupt host with message (x0 restored here)
	RTI


;---------------------------------------------------------------
;
;                          * END OF ISRs *
;
;--------------------------------------------------------------



;----------------------------------------------------------------
;
;                     * Beginning of SUBROUTINES *
;
;-----------------------------------------------------------------


; -------------------------------------------------------------
CALC_NO_BUFFS
;----------------------------------------------------
; number of 512 buffers in packet calculated (X:TOTAL_BUFFS) 
; and number of left over blocks (X:NUM_LEFTOVER_BLOCKS)
; and left over words (X:LEFT_TO_READ)

	CLR	B
	MOVE	X:<HEAD_W4_0,B0		; LS 16bits
	MOVE	X:<HEAD_W4_1,X0		; MS 16bits

	INSERT	#$010010,X0,B		; now size of packet B....giving # of 32bit words in packet
	NOP

; need to covert this to 16 bit since read from FIFO and saved in Y memory as 16bit words...

; so double size of packet....
	ASL	B	

; now save	
	MOVE	B0,X0
	MOVE	B1,X1
	MOVE	X0,X:<PACKET_SIZE_LOW	; low 24 bits of packet size (in 16bit words)
	MOVE	X1,X:<PACKET_SIZE_HIH	; high 8 bits of packet size (in 16bit words)

	MOVE	X:<PACKET_SIZE_LOW,A0
	MOVE	X:<PACKET_SIZE_HIH,A1
	ASR	#7,A,A			; divide by 128. To get # of max 256byte bursts over bus
	NOP
	MOVE	A0,X:<NMAX_BURSTS	
	ASR	#2,A,A			; divide by another 2 (total=/512: number of 16bit words)
	NOP
	MOVE	A0,X:<TOTAL_BUFFS	; number of half full fifos required to read in all of data.


	MOVE	A0,X1
	MOVE	#HF_FIFO,Y1
	MPY	X1,Y1,A
	ASR	#1,A,B			; B holds number of 16bit words in all full buffers
	NOP

	MOVE	X:<PACKET_SIZE_LOW,A0
	MOVE	X:<PACKET_SIZE_HIH,A1	; A holds total number of 16bit words	
	SUB	B,A			; now A holds number of left over 16bit words 
	NOP
	MOVE	A0,X:<LEFT_TO_READ	; store number of left over 16bit words to read
	ASR	#7,A,A			; divide by 128 - for max burst size (256bytes)
	NOP
	MOVE	A0,X:<NUM_LEFTOVER_BLOCKS
	MOVE	A0,X1
	MOVE	#>128,Y1
	MPY	X1,Y1,A
	ASR	#1,A,A
	NOP
	
	ADD	A,B			; B holds words in all buffers
	NOP
	MOVE	X:<PACKET_SIZE_LOW,A0
	MOVE	X:<PACKET_SIZE_HIH,A1	; A holds total number of words	
	SUB	B,A			; now A holds number of left over words
	NOP
	MOVE	A0,X:<LEFT_TO_READ	; store number of left over 16bit words to read

	ASR	#1,A,A			; divide by two to get number of 32 bit words to write
	NOP				; for pipeline
	MOVE	A0,X:<LEFT_TO_WRITE	; store number of left over 32 bit words (2 x 16 bit) to write to host after small block transfer as well

	RTS

;---------------------------------------------------------------
GET_FO_WRD	
;--------------------------------------------------------------
; Anything in fibre receive FIFO?   If so store in X0

		JCLR	#EF,X:PDRD,CLR_FO_RTS
		NOP	
		NOP
		JCLR	#EF,X:PDRD,CLR_FO_RTS		; check twice for FO metastability.	
		JMP	RD_FO_WD

WT_FIFO		JCLR	#EF,X:PDRD,*			; Wait till something in FIFO flagged
		NOP
		NOP
		JCLR	#EF,X:PDRD,WT_FIFO	; check twice.....

; Read one word from the fiber optics FIFO, check it and put it in A1
RD_FO_WD
		MOVEP	Y:RDFIFO,X0			; then read to X0
		MOVE	#$00FFFF,A1			; mask off top 2 bytes ($FC)
		AND	X0,A				; since receiving 16 bits in 24bit register
		NOP
		MOVE	A1,X0
		BSET	#FO_WRD_RCV,X:<STATUS
		RTS
CLR_FO_RTS	
		BCLR	#FO_WRD_RCV,X:<STATUS
		RTS

;-----------------------------------------------
PCI_ERROR_RECOVERY
; Recover from an error writing to the PCI bus
; TO, TDIS 			- resume burst
; TRTY,TAB,MAB,APER,DPER   	- restart burst
;
; resume recovery for TO/TDIS added on advice 
; from Matthew Hasselfield (UBC) 
;----------------------------------------------

; in pci error count

	MOVE	X:ECOUNT_PCI,A0
	INC	A
	NOP
	MOVE	A0,X:ECOUNT_PCI

	JSET	#TRTY,X:DPSR,TRTY_ERROR
	JSET	#TO,X:DPSR,TO_ERROR	
	JSET	#TDIS,X:DPSR,TDIS_ERROR	
	JSET	#TAB,X:DPSR,TAB_ERROR
	JSET	#MAB,X:DPSR,MAB_ERROR		
	JSET	#DPER,X:DPSR,DPER_ERROR	
	JSET	#APER,X:DPSR,APER_ERROR	

TRTY_ERROR					; Retry error
	MOVE	X:ECOUNT_TRTY,A0
	INC	A
	MOVEP	#$0400,X:DPSR		; Clear target retry error bit
	MOVE	A0,X:ECOUNT_TRTY
	BSET	#PCIBURST_RESTART,X:STATUS
	RTS

TO_ERROR				; Timeout error
	MOVE	X:ECOUNT_TO,A0
	INC	A
	MOVEP	#$0800,X:DPSR		; Clear timeout error bit
	MOVE	A0,X:ECOUNT_TO
	BSET	#PCIBURST_RESUME,X:STATUS
	RTS

TDIS_ERROR				; Target disconnect error
	MOVE	X:ECOUNT_TDIS,A0
	INC	A
	MOVEP	#$0200,X:DPSR		; Clear target disconnect bit
	MOVE	A0,X:ECOUNT_TDIS
	BSET	#PCIBURST_RESUME,X:STATUS
	RTS

TAB_ERROR				; Target abort error
	MOVE	X:ECOUNT_TAB,A0
	INC	A
	MOVEP	#$0100,X:DPSR		; Clear target abort error bit	
	MOVE	A0,X:ECOUNT_TAB
	BSET	#PCIBURST_RESTART,X:STATUS
	RTS

MAB_ERROR				; Master abort error
	MOVE	X:ECOUNT_MAB,A0
	INC	A
	MOVEP	#$0080,X:DPSR		; Clear master abort error bit
	MOVE	A0,X:ECOUNT_MAB
	BSET	#PCIBURST_RESTART,X:STATUS
	RTS

DPER_ERROR				; Data parity error
	MOVE	X:ECOUNT_DPER,A0
	INC	A
	MOVEP	#$0040,X:DPSR		; Clear data parity error bit
	MOVE	A0,X:ECOUNT_DPER
	BSET	#PCIBURST_RESTART,X:STATUS
	RTS

APER_ERROR				; Address parity error
	MOVE	X:ECOUNT_APER,A0
	INC	A
	MOVEP	#$0020,X:DPSR		; Clear address parity error bit
	MOVE	A0,X:ECOUNT_APER
	BSET	#PCIBURST_RESTART,X:STATUS
	RTS


; ----------------------------------------------------------------------------
PCI_MESSAGE_TO_HOST
;----------------------------------------------------------------------------

; subroutine to send 4 words as a reply from PCI to the Host
; using the DTXS-HRXS data path
; PCI card writes here first then causes an interrupt INTA on
; the PCI bus to alert the host to the reply message

	JSET	#DCTR_HF3,X:DCTR,*	; make sure host ready to receive interrupt
					; cleared via fast interrupt if host out of its ISR

	JCLR	#STRQ,X:DSR,*		; Wait for transmitter to be NOT FULL
					; i.e. if CLR then FULL so wait
					; if not then it is clear to write
	MOVE	X:<DTXS_WD1,X0
	MOVE	X0,X:DTXS		; Write 24 bit word1

	JCLR	#STRQ,X:DSR,*		; wait to be not full
	MOVE	X:<DTXS_WD2,X0
	MOVE	X0,X:DTXS		; Write 24 bit word2

	JCLR	#STRQ,X:DSR,*		; wait to be not full
	MOVE	X:<DTXS_WD3,X0
	MOVE	X0,X:DTXS		; Write 24 bit word3

	JCLR	#STRQ,X:DSR,*		; wait to be not full
	MOVE	X:<DTXS_WD4,X0
	MOVE	X0,X:DTXS		; Write 24 bit word4


; restore X0....  
; PCI_MESSAGE_TO_HOST is used by all command vector ISRs. 
; Working registers must be restored before RTI.  
; However, we want to restore before asserting INTA.
; x0 is only one that can't be restored before PCI_MESSAGE_TO_HOST
; (since it is used by this SR) hence we restore here.
; this is redundant for a 'NFY' message (since sequential instruction) 
; but may be required for a PCI command reply 'REP' message.
; (since interrupt driven) 

	MOVE	X:SV_X0,X0		; restore X0

; all the transmit words are in the FIFO, interrupt the Host
; the Host should clear this interrupt once it is detected. 
; It does this by writing to HCVR to cause a fast interrupt.


	BSET	#DCTR_HF3,X:DCTR	; set flag to handshake interrupt (INTA) with host. 
	BSET	#INTA,X:DCTR		; Assert the interrupt

	RTS

;---------------------------------------------------------------
RD_DRXR
;--------------------------------------------------------------
; routine is used to read from HTXR-DRXR data path
; which is used by the Host to communicate with the PCI board
; the host writes 4 words to this FIFO then interrupts the PCI
; which reads the 4 words and acts on them accordingly.


	JCLR	#SRRQ,X:DSR,*		; Wait for receiver to be not empty
					; implies that host has written words


; actually reading as slave here so this shouldn't be necessary......?

	BCLR	#FC1,X:DPMC		; 24 bit read FC1 = 0, FC1 = 0
	BSET	#FC0,X:DPMC	


	MOVEP	X:DRXR,X0		; Get word1
	MOVE	X0,X:<DRXR_WD1	
	MOVEP	X:DRXR,X0		; Get word2
	MOVE	X0,X:<DRXR_WD2	
	MOVEP	X:DRXR,X0		; Get word3
	MOVE	X0,X:<DRXR_WD3
	MOVEP	X:DRXR,X0		; Get word4
	MOVE	X0,X:<DRXR_WD4
	RTS

;---------------------------------------------------------------
READ_FROM_PCI
;--------------------------------------------------------------
; sub routine to read a 24 bit word in from PCI bus --> Y memory
; 32bit host address in accumulator B.

; read as master 

	EXTRACTU #$010010,B,A		; Get D31-16 bits only
	NOP

	MOVE	A0,A1
	NOP
	MOVE	A1,X:DPMC		; high 16bits of address in DSP master cntr reg.
					; 32 bit read so FC1 = 0 and FC0 = 0

	NOP
	EXTRACTU #$010000,B,A
	NOP
	MOVE	A0,A1
	OR	#$060000,A		; A1 gets written to DPAR register
	NOP				; C3-C0 of DPAR=0110 for memory read
WRT_ADD	MOVEP	A1,X:DPAR		; Write address to PCI bus - PCI READ action
	NOP				; Pipeline delay
RD_PCI	JSET	#MRRQ,X:DPSR,GET_DAT	; If MTRQ = 1 go read the word from host via FIFO
	JCLR	#TRTY,X:DPSR,RD_PCI	; Bit is set if its a retry
	MOVEP	#$0400,X:DPSR		; Clear bit 10 = target retry bit
	JCLR	#MARQ,X:DPSR,*		; Wait for PCI addressing to be complete
	JMP	<WRT_ADD

GET_DAT	MOVEP	X:DRXR,X0		; Read 1st 16 bits of 32 bit word from host memory
	MOVEP	X:DRXR,X1		; Read 2nd 16 bits of 32 bit word from host memory	

; note that we now have 4 bytes in X0 and X1.
; The 32bit word was in host memory in little endian format
; If form LSB --> MSB the bytes are b1, b2, b3, b4 in host memory
; in progressing through the HTRX/DRXR FIFO the 
; bytes end up like this.....
; then X0 = $00 b2 b1
; and  X1 = $00 b4 b3

	REP	#4			; increment PCI address by four bytes.
	INC	B			
	NOP
	RTS

;------------------------------------------------------------------------------------
RESTORE_REGISTERS
;-------------------------------------------------------------------------------------

	MOVEC	X:<SV_SR,SR	

	MOVE	X:<SV_A0,A0		
	MOVE	X:<SV_A1,A1
	MOVE	X:<SV_A2,A2

	MOVE	X:<SV_B0,B0		
	MOVE	X:<SV_B1,B1
	MOVE	X:<SV_B2,B2

	MOVE	X:<SV_X0,X0	
	MOVE	X:<SV_X1,X1

	MOVE	X:<SV_Y0,Y0
	MOVE	X:<SV_Y1,Y1

	RTS
;------------------------------------------------------------------------------------
RESTORE_HST_REGISTERS
;-------------------------------------------------------------------------------------
; B not restored after HST as it now contains address.

	MOVEC	X:<SV_SR,SR

	MOVE	X:<SV_A0,A0		
	MOVE	X:<SV_A1,A1
	MOVE	X:<SV_A2,A2

	MOVE	X:<SV_X0,X0	
	MOVE	X:<SV_X1,X1

	MOVE	X:<SV_Y0,Y0
	MOVE	X:<SV_Y1,Y1
	
	RTS

;-------------------------------------------------------------------------------------
SAVE_REGISTERS
;-------------------------------------------------------------------------------------

	MOVEC	SR,X:<SV_SR		; save status register.  May jump to ISR during CMP
	
	MOVE	A0,X:<SV_A0		
	MOVE	A1,X:<SV_A1
	MOVE	A2,X:<SV_A2

	MOVE	B0,X:<SV_B0		
	MOVE	B1,X:<SV_B1
	MOVE	B2,X:<SV_B2

	MOVE	X0,X:<SV_X0	
	MOVE	X1,X:<SV_X1

	MOVE	Y0,X:<SV_Y0
	MOVE	Y1,X:<SV_Y1

	RTS


;--------------------------------------------------------------------------------------------------
WRITE_PCI_BURST 		; writes 128x16bit words across PCI bus: 256 bytes (max burst) 	
;----------------------------------------------------------------------------------------------------

	CLR	A
	MOVE	X:NBURST_YMEM,A0	; Number of y memory locations to trasfer.
	MOVE	X:NBURST_YMEM,N2	; y memory increment

	ASL	#1,A,A			; x2 for bytes
	NOP
	MOVE	A0,X:NBURST_BYTE	; save # bytes to transfer
	ASR	#1,A,A			; back to pixels
	ADD	#0,A			; clear carry
	DEC	A			; DMA count = number pixels - 1
	ADD	#0,A			; clear carry

	MOVE	R2,X:DSR0		; Source address for DMA = pixel data
	MOVEP	#DTXM,X:DDR0		; Destination = PCI master transmitter
	MOVEP	A0,X:DCO0		; DMA Count = # of pixels - 1 
DMA_GO	MOVEP	#$8EFA51,X:DCR0		; Start DMA with control register DE=1
	MOVE	(R2)+N2			; Increment pixel buffer address for next time

	ASR	#1,A,A			; npix/2 to get BL (#PCI transfers-1)
	ADD	#0,A			; clear carry
	ASL	#16,A,A			; get BL into top byte
	NOP
	MOVE	A0,X:PCI_BL		; save BL

PCI_BURST
	EXTRACTU #$010010,B,A		; Get D31-16 bits only of PCI addr
	ASL	#24,A,A			; put in A1
	MOVE	X:PCI_BL,X0
	ADD	X0,A			; add BL = pci burst size - 1
	NOP				;   = # of pixels / 2 - 1 ...
	MOVE	A1,X:DPMC		; DPMC = B[31:16] + $BL0000

	EXTRACTU #$010000,B,A
	ASL	#24,A,A			; put in A1
	MOVE	#$070000,X0
	ADD	X0,A
	NOP	
	MOVEP	A1,X:DPAR		; Initiate writing to the PCI bus
	NOP
	NOP
WAIT_PCI
	JCLR	#MARQ,X:DPSR,*		; Wait until the PCI operation is done
	JSET	#MDT,X:DPSR,WR_OK	; If no error go to the next sub-block
	JSR	<PCI_ERROR_RECOVERY
	BCLR	#PCIBURST_RESTART,X:STATUS 	;  Clear and Test
	JCS	<PCI_BURST		   	;  restart burst
	BCLR	#PCIBURST_RESUME,X:STATUS  	;  Clear and Test
	JCS	<PCI_RESUME			;  resume burst
WR_OK
	CLR 	A
	MOVE	X:NBURST_BYTE,A0	; get number of bytes transferred
	ADD	A,B			; update PCI address = + # bytes transferred 
	RTS

PCI_RESUME	
	CLR	A
	MOVEP	X:DPSR,A0		; get dpsr: remaining data count
	ASR	#16,A,A			; get remaining words to write into bottom byte
	JCLR	#RDCQ,X:DPSR,NO_RDCQ	;	 
	INC	A			; BL[5-0] = RDC[5-0] + RDCQ
NO_RDCQ
	NOP
	MOVE	A0,X1			; save burst length still to go in X1 (=transfers-1)

	INC	A			; BL + 1 = number of 32bit words left to transfer
	ASL	#2,A,A			; x4 = number of bytes left to transfer
	NOP
	MOVE	A0,X0			; number bytes left to transfer now in x0

	MOVE	X:NBURST_BYTE,A		; get number of bytes that were supposed to have been transferred (A1)
	MOVE	X0,X:NBURST_BYTE	; update #bytes left to burst in resume 
	SUB	X0,A			; subtract #bytes left to get number of bytes trasferred already (A1)
	ASR	#24,A,A			; shift to A0
	ADD	#0,A			; clear carry

	ADD	A,B			; add what's been transferred to pci bus address
	ADD	#0,B			; clear carry
	MOVE	X1,A0			; get BL (transfers-1) 
	ASL	#16,A,A			; get BL into top byte
	NOP
	MOVE	A0,X:PCI_BL		; save burst length (top byte)
	JMP	PCI_BURST		; resume burst



;------------------------------------------------------------
WRITE_512_TO_PCI 		
;-------------------------------------------------------------
; DMAs 128 x 16bit words to host memory as PCI burst 
; does x 4 of these (total of 512 x 16bit words written to host memory)
;
; R2 is used as a pointer to Y:memory address


	MOVE	#128,N2			; Number of 16bit words per transfer.
	MOVE	#64,N4			; NUmber of 32bit words per transfer.

; Make sure its always 512 pixels per loop = 1/2 FIFO
	MOVE	R2,X:DSR0		; Source address for DMA = pixel data
	MOVEP	#DTXM,X:DDR0		; Destination = PCI master transmitter
	MOVEP	#>127,X:DCO0		; DMA Count = # of pixels - 1 

; Do loop does 4 x 128 pixel DMA writes = 512.
; need to recalculate hi and lo parts of address
; for each burst.....Leach code doesn't do this since not
; multiple frames...so only needs to inc low part.....

	DO	#4,WR_BLK0		; x # of pixels = 512

	EXTRACTU #$010010,B,A		; Get D31-16 bits only
	NOP
	MOVE	A0,A1			; [D31-16] in A1
	NOP
	ORI	#$3F0000,A		; Burst length = # of PCI writes
	NOP				;   = # of pixels / 2 - 1 ...$3F = 63
	MOVE	A1,X:DPMC		; DPMC = B[31:16] + $3F0000


	EXTRACTU #$010000,B,A
	NOP
	MOVE	A0,A1			; Get PCI_ADDR[15:0] into A1[15:0]
	NOP
	OR	#$070000,A		; A1 gets written to DPAR register
	NOP


AGAIN0	MOVEP	#$8EFA51,X:DCR0		; Start DMA with control register DE=1
	MOVEP	A1,X:DPAR		; Initiate writing to the PCI bus
	NOP
	NOP
	JCLR	#MARQ,X:DPSR,*		; Wait until the PCI operation is done
	JSET	#MDT,X:DPSR,WR_OK0	; If no error go to the next sub-block
	JSR	<PCI_ERROR_RECOVERY
	JMP	<AGAIN0			; Just try to write the sub-block again
WR_OK0	

	CLR 	A	(R4)+N4		  ; clear A and increment word count
	MOVE	#>256,A0		  ; 2 bytes on pcibus per pixel
	ADD	A,B	R4,X:<WORD_COUNT  ; Inc bus address by # of bytes, and save word count
	MOVE	(R2)+N2			  ; Pixel buffer address = + # of pixels
WR_BLK0
	RTS

;-----------------------------
XMT_DLY	
;-----------------------------
; Short delay for reliability

	NOP
	NOP
	NOP
	RTS

;-------------------------------------------------------
XMT_WD_FIBRE
;-----------------------------------------------------
; 250 MHz code - Transmit contents of Accumulator A1 to the MCE
; we want to send 32bit word in little endian fomat to the host.
; i.e. b4b3b2b1 goes b1, b2, b3, b4
; currently the bytes are in this order:
;  A1 = $00 b2 b1
;  A0 = $00 b4 b3
;  A = $00 00 b2 b1 00 b4 b3

; This subroutine must take at least 160ns (4 bytes at 25Mbytes/s)

	NOP
	NOP

; split up 4 bytes b2, b1, b4, b3

	ASL	#16,A,A			; shift byte b2 into A2
	MOVE	#$FFF000,R0		; Memory mapped address of transmitter

	MOVE	A2,Y1			; byte b2 in Y1

	ASL     #8,A,A			; shift byte b1 into A2
	NOP
	MOVE	A2,Y0			; byte b1 in Y0

	ASL     #16,A,A			; shift byte b4 into A2
	NOP
	MOVE	A2,X1			; byte b4 in X1


	ASL     #8,A,A			; shift byte b3 into A2
	NOP
	MOVE	A2,X0			; byte b3 in x0	

; transmit b1, b2, b3 ,b4

	MOVE	Y0,X:(R0)		; byte b1 - off it goes
	MOVE	Y1,X:(R0)		; byte b2 - off it goes
	MOVE	X0,X:(R0)		; byte b3 - off it goes 
	MOVE	X1,X:(R0)		; byte b4 - off it goes

	NOP
	NOP
	RTS


BOOTCODE_END
BOOTEND_ADDR	EQU	@CVI(BOOTCODE_END)

PROGRAM_END
PEND_ADDR	EQU	@CVI(PROGRAM_END)
;---------------------------------------------


; --------------------------------------------------------------------
; --------------- x memory parameter table ---------------------------
; --------------------------------------------------------------------

        ORG     X:VAR_TBL,P:


	IF	@SCP("DOWNLOAD","ROM")	; Boot ROM code
VAR_TBL_START	EQU	@LCV(L)-2
	ENDIF

	IF	@SCP("DOWNLOAD","ONCE")	; Download via ONCE debugger
VAR_TBL_START	EQU	@LCV(L)
	ENDIF

; -----------------------------------------------
; do not move these (X:0 --> x:3)
STATUS		DC	0
FRAME_COUNT	DC	0	; used as a check....... increments for every frame write.....must be cleared by host.
PRE_CORRUPT	DC	0
REV_NUMBER	DC	$410200		; byte 0 = minor revision #
					; byte 1 = mayor revision #
					; byte 2 = release Version (ascii letter)
REV_DATA	DC	$1F0A07		; data: day-month-year
P_CHECKSUM	DC	$e8681f         ;**** DO NOT CHANGE
; -------------------------------------------------
WORD_COUNT		DC	0	; word count.  Number of words successfully writen to host in last packet.	
NUM_DUMPED		DC	0	; number of words (16-bit) dumped to Y memory (512) after an HST timeout.
; --------------------------------------------------------------------------------------------------------------

DRXR_WD1		DC	0
DRXR_WD2		DC	0
DRXR_WD3		DC	0
DRXR_WD4		DC	0
DTXS_WD1		DC	0
DTXS_WD2		DC	0
DTXS_WD3		DC	0
DTXS_WD4		DC	0

PCI_WD1_1		DC	0
PCI_WD1_2		DC	0
PCI_WD2_1		DC	0
PCI_WD2_2		DC	0
PCI_WD3_1		DC	0
PCI_WD3_2		DC	0
PCI_WD4_1		DC	0
PCI_WD4_2		DC	0
PCI_WD5_1		DC	0
PCI_WD5_2		DC	0
PCI_WD6_1		DC	0
PCI_WD6_2		DC	0


HEAD_W1_1		DC	0
HEAD_W1_0		DC	0
HEAD_W2_1		DC	0
HEAD_W2_0		DC	0
HEAD_W3_1		DC	0
HEAD_W3_0		DC	0
HEAD_W4_1		DC	0
HEAD_W4_0		DC	0


REP_WD1			DC	0
REP_WD2			DC	0
REP_WD3			DC	0
REP_WD4			DC	0

SV_A0			DC	0   
SV_A1			DC	0 
SV_A2			DC	0
SV_B0			DC	0
SV_B1			DC	0
SV_B2			DC	0
SV_X0			DC	0
SV_X1			DC	0
SV_Y0			DC	0
SV_Y1			DC	0

SV_SR			DC	0	; stauts register save.



PACKET_SIZE_LOW		DC	0
PACKET_SIZE_HIH		DC	0

PREAMB1			DC	$A5A5	; pramble 16-bit word....2 of which make up first preamble 32bit word
PREAMB2			DC	$5A5A	; preamble 16-bit word....2 of which make up second preamble 32bit word
DATA_WD			DC	$4441	; "DA"
REPLY_WD		DC	$5250	; "RP"

NMAX_BURSTS		DC	0
TOTAL_BUFFS		DC	0	; total number of 512 buffers in packet
LEFT_TO_READ		DC	0	; number of words (16 bit) left to read after last 512 buffer
LEFT_TO_WRITE		DC	0	; number of woreds (32 bit) to write to host i.e. half of those left over read
NUM_LEFTOVER_BLOCKS	DC	0	; small block DMA burst transfer

DATA_DLY_VAL		DC	0	; data delay value..  Delay added to first frame received after GO command 
CONSTORE		DC	$200

NBURST_YMEM		DC	0	; number of y memory locations in DMA transfer (to PCI burst) 
NBURST_BYTE		DC	0	; number of bytes in PCI burst 
PCI_BL			DC	0	; holds PCI "burst length" in top byte (= word transfers -1)

ZERO			DC	0
ONE			DC	1
FOUR			DC	4

FILL46			DC	0

; pci error counts
ECOUNT_PCI		DC	0	; total count
ECOUNT_TRTY		DC	0	; PCI target retry count
ECOUNT_TO		DC	0	; PCI time out count
ECOUNT_TDIS		DC	0	; PCI target disconnect count
ECOUNT_TAB		DC	0	; PCI target abort count
ECOUNT_MAB		DC	0	; PCI master abort count
ECOUNT_DPER		DC	0	; PCI data parity error count
ECOUNT_APER		DC	0	; PCI address parity error count

;----------------------------------------------------------



	IF	@SCP("DOWNLOAD","ROM")	; Boot ROM code
VAR_TBL_END	EQU	@LCV(L)-2
	ENDIF

	IF	@SCP("DOWNLOAD","ONCE")	; Download via ONCE debugger
VAR_TBL_END	EQU	@LCV(L)
	ENDIF

VAR_TBL_LENGTH EQU	VAR_TBL_END-VAR_TBL_START
                          

	IF	@CVS(N,*)>=APPLICATION
        WARN    'The boot code is too large and could be overwritten by an Application!'
	ENDIF


;--------------------------------------------
; APPLICATION AREA
;---------------------------------------------
	IF	@SCP("DOWNLOAD","ROM")		; Download via ONCE debugger
	ORG	P:APPLICATION,P:APPLICATION+2
	ENDIF

	IF	@SCP("DOWNLOAD","ONCE")		; Download via ONCE debugger
	ORG	P:APPLICATION,P:APPLICATION
	ENDIF

; starts with no application loaded
; so just reply with an error if we get a GOA command
	MOVE	#'REP',X0
	MOVE	X0,X:<DTXS_WD1		; REPly
	MOVE	#'GOA',X0
	MOVE	X0,X:<DTXS_WD2		; echo command sent
	MOVE	#'ERR',X0
	MOVE	X0,X:<DTXS_WD3		; No Application Loaded
	MOVE	#'NAL',X0
	MOVE	X0,X:<DTXS_WD4		; write to PCI memory error;
	JSR	<RESTORE_REGISTERS	
	JSR	<PCI_MESSAGE_TO_HOST
	BCLR	#APPLICATION_LOADED,X:<STATUS 
	JMP	PACKET_IN


END_ADR	EQU	@LCV(L)		; End address of P: code written to ROM
