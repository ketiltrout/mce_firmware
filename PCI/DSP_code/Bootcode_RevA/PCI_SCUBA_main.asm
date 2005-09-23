 COMMENT *

This is the main section of the pci card code. 

Project:     SCUBA 2 
Author:      DAVID ATKINSON
Target:      250MHz SDSU PCI card - DSP56301
Controller:  For use with SCUBA 2 Multichannel Electronics 

Version:     Release Version A


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
		JMP	<PACKET_IN			; wait for next packet


PACKET_INFO                                            ; packet preamble valid

; Packet preamle is valid so....
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


; It's a data packet....
; check if it's the first packet after the GO command has been issued...

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

; ----------------------------------------------------------------------------------------------------------
; Determine how to break up packet to write to host

; Note that this SR uses accumulator B 
; Therefore execute before we get the bus address from host (which is stored in B) 
; i.e before we issue notify message ('NFY')

		JSR	<CALC_NO_BUFFS		; subroutine which calculates the number of 512 (16bit) buffers 
						; number of left over 32 (16bit) blocks  
						; and number of left overs (16bit) words  

;  note that a 512 (16-bit) buffer is transfered to the host as 4 x 64 x 32bit DMA burst
;            a 32  (16-bit) block is transfered to the host as a    16 x 32bit DMA burst
;            left over 16bit words are transfered to the host in pairs as 32bit words 
; -------------------------------------------------------------------------------------------------


; notify the host that there is a packet.....
		
		JSR	<PCI_MESSAGE_TO_HOST			; notify host of packet	
		BSET	#HST_NFYD,X:<STATUS			; flag to indicate host has been notified.
WT_HOST		JSET	#FATAL_ERROR,X:<STATUS,START		; if fatal error - run initialisation code...
		JCLR	#SEND_TO_HOST,X:<STATUS,WT_HOST		; wait for host to reply - which it does with 'send_packet_to_host' ISR


; we now have 32 bit address in accumulator B
; from send-packet_to_host

; ---------------------------------------------------------------------------------------------------------
; Write TOTAL_BUFFS * 512 buffers to host
; ----------------------------------------------------------------------------------------------------				
		DO	X:<TOTAL_BUFFS,ALL_BUFFS_END	; note that if TOTAL_BUFFS = 0 we jump to ALL_BUFFS_END

		MOVE	#<IMAGE_BUFFER,R1		; FO ---> Y mem 
		MOVE	#<IMAGE_BUFFER,R2		; Y mem ----->  PCI BUS	


WAIT_BUFF	JSET	#FATAL_ERROR,X:<STATUS,START	; if fatal error then reset (i.e. if HST timeout)
		JSET	#HF,X:PDRD,WAIT_BUFF		; Wait for FIFO to be half full + 1
		NOP
		NOP
		JSET	#HF,X:PDRD,WAIT_BUFF		; Protection against metastability


; Copy the image block as 512 x 16bit words to DSP Y: Memory using R1 as pointer
		DO	#512,L_BUFFER
		MOVEP	Y:RDFIFO,Y:(R1)+
L_BUFFER


; R2 points to data in Y memory to be written to host
; host address is in B - got by SEND_PACKET_TO_HOST command 
; so we can now write this buffer to host

		JSR	<WRITE_512_TO_PCI			; this subroutine will increment host address, which is in B and R2
		NOP
ALL_BUFFS_END							; all buffers have been writen to host	

; ---------------------------------------------------------------------------------------------------------
; Write NUM_LEFTOVER_BLOCKS * 32 blocks to host
; ----------------------------------------------------------------------------------------------------		

; less than 512 pixels but if greater than 32 will then do bursts
; of 16 x 32bit in length, if less than 32 then does single read writes

		DO	X:<NUM_LEFTOVER_BLOCKS,LEFTOVER_BLOCKS	 ;note that if NUM_LEFOVERS_BLOCKS = 0 we jump to LEFTOVER_BLOCKS


		MOVE	#<IMAGE_BUFFER,R1		; FO ---> Y mem
		MOVE	#<IMAGE_BUFFER,R2		; Y mem ----->  PCI BUS	

		DO	#32,S_BUFFER
WAIT_1		JSET	#FATAL_ERROR,X:<STATUS,START	; check for fatal error (i.e. after HST timeout)
		JCLR	#EF,X:PDRD,WAIT_1		; Wait for the pixel datum to be there
		NOP					; Settling time
		NOP
		JCLR	#EF,X:PDRD,WAIT_1		; Protection against metastability
		MOVEP	Y:RDFIFO,Y:(R1)+		; save fibre word
S_BUFFER

		JSR	<WRITE_32_TO_PCI		; write small blocks
		NOP
LEFTOVER_BLOCKS

; -----------------------------------------------------------------------------------------------------
; Single write left over words to host
; ----------------------------------------------------------------------------------------------------	

LEFT_OVERS	
		MOVE	#<IMAGE_BUFFER,R1		; FO ---> Y mem
		MOVE	#<IMAGE_BUFFER,R2		; Y mem ----->  PCI BUS	

		DO	X:<LEFT_TO_READ,LEFT_OVERS_READ		; read in remaining words of data packet
								; if LEFT_TO_READ = 0 then will jump to LEFT_OVERS_READ

WAIT_2		JSET	#FATAL_ERROR,X:<STATUS,START		; check for fatal error (i.e. after HST timeout)
		JCLR	#EF,X:PDRD,WAIT_2			; Wait till something in FIFO flagged
		NOP
		NOP
		JCLR	#EF,X:PDRD,WAIT_2		   	; protect against metastability.....
		MOVEP	Y:RDFIFO,Y:(R1)+			; save fibre word	
LEFT_OVERS_READ

; now write left overs to host as 32 bit words
		
		DO	X:LEFT_TO_WRITE,LEFT_OVERS_WRITEN	; left overs to write is half left overs read - since 32 bit writes
								; if LEFT_TO_WRITE = 0, will jump to LEFT_OVERS_WRITTEN
		JSR	WRITE_TO_PCI				; uses R2 as pointer to Y memory, host address in B	
LEFT_OVERS_WRITEN


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
BLOCK_CON
	DO	#64,END_BLOCK_CON	; block size = 32bit x 64 (256 bytes)
	JSR	<READ_FROM_PCI		; get next 32 bit word from HOST
	MOVE	X0,A1			; prepare to send
	MOVE	X1,A0			; prepare to send
	JSR	<XMT_WD_FIBRE		; off it goes
	NOP
END_BLOCK_CON

	BCLR	#PACKET_CHOKE,X:<STATUS	; disable packet choke...
					; comms now open with MCE and packets will be processed.	

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

	JSET	#INTA_FLAG,X:<STATUS,*   ; wait for host to process
	
	BCLR	#APPLICATION_LOADED,X:<STATUS	; clear app flag
        BCLR	#PREAMBLE_ERROR,X:<STATUS	; clear preamble error
	BCLR	#APPLICATION_RUNNING,X:<STATUS  ; clear appl running bit.

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
	ASR	#9,A,A			; divide by 512...number of 16bit words in a buffer
	NOP
	MOVE	A0,X:<TOTAL_BUFFS

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
	ASR	#5,A,A			; divide by 32... number of 16bit words in lefover block
	NOP
	MOVE	A0,X:<NUM_LEFTOVER_BLOCKS
	MOVE	A0,X1
	MOVE	#>SMALL_BLK,Y1
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

WT_FIFO		JCLR	#EF,X:PDRD,*		; Wait till something in FIFO flagged
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
;-----------------------------------------------
; Recover from an error writing to the PCI bus

	JCLR	#TRTY,X:DPSR,ERROR1	; Retry error
	MOVEP	#$0400,X:DPSR		; Clear target retry error bit
	RTS
ERROR1	JCLR	#TO,X:DPSR,ERROR2	; Timeout error
	MOVEP	#$0800,X:DPSR		; Clear timeout error bit
	RTS
ERROR2	JCLR	#TDIS,X:DPSR,ERROR3	; Target disconnect error
	MOVEP	#$0200,X:DPSR		; Clear target disconnect bit
	RTS
ERROR3	JCLR	#TAB,X:DPSR,ERROR4	; Target abort error
	MOVEP	#$0100,X:DPSR		; Clear target abort error bit
	RTS
ERROR4	JCLR	#MAB,X:DPSR,ERROR5	; Master abort error
	MOVEP	#$0080,X:DPSR		; Clear master abort error bit
	RTS
ERROR5	JCLR	#DPER,X:DPSR,ERROR6	; Data parity error
	MOVEP	#$0040,X:DPSR		; Clear data parity error bit
	RTS
ERROR6	JCLR	#APER,X:DPSR,ERROR7	; Address parity error
	MOVEP	#$0020,X:DPSR		; Clear address parity error bit
ERROR7	RTS

; ----------------------------------------------------------------------------
PCI_MESSAGE_TO_HOST
;----------------------------------------------------------------------------

; subroutine to send 4 words as a reply from PCI to the Host
; using the DTXS-HRXS data path
; PCI card writes here first then causes an interrupt INTA on
; the PCI bus to alert the host to the reply message



	JSET	#INTA_FLAG,X:<STATUS,*	; make sure host ready to receive message
					; bit will be cleared by fast interrupt 
					; if ready
	BSET	#INTA_FLAG,X:<STATUS	; set flag for next time round.....


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



; ------------------------------------------------------------------------------------
WRITE_TO_PCI 		
;-------------------------------------------------------------------------------------
; sub routine to write two 16 bit words (stored in Y memory) 
; to host memory as PCI bus master.
; results in a 32bit word written to host memory. 

; the 32 bit host address is in accumulator B.
; this address is writen to DPMC (MSBs) and DPAR (LSBs)
; address is incrememted by 4 (bytes) after write.

; R2 is used as a pointer to Y:memory address

	
	JCLR	#MTRQ,X:DPSR,*		; wait here if DTXM is full

TX_LSB	MOVEP	Y:(R2)+,X:DTXM		; Least significant word to transmit
TX_MSB	MOVEP	Y:(R2)+,X:DTXM		; Most significant word to transmit


	EXTRACTU #$010010,B,A		; Get D31-16 bits only, 
	NOP				; top byte = $00 so FC1 = FC0 = 0
	MOVE	A0,A1

; we are using two 16 bit writes to make a 32bit word 
; so FC1=0 and FC0=0 when A1 written to DPMC

	NOP
	MOVE	A1,X:DPMC		; DSP master control register
	NOP
	EXTRACTU #$010000,B,A
	NOP
	MOVE	A0,A1
	OR	#$070000,A		; A1 gets written to DPAR register
	NOP

AGAIN1	MOVEP	A1,X:DPAR		; Write to PCI bus
	NOP				; Pipeline delay
	NOP
	JCLR	#MARQ,X:DPSR,*		; Bit is set if its a retry
	JSET	#MDT,X:DPSR,INC_ADD	; If no error go to the next sub-block
	JSR	<PCI_ERROR_RECOVERY
	JMP	<AGAIN1
INC_ADD	
	CLR 	A	(R4)+		  ; clear A and increment word count
	MOVE	#>4,A0			  ; 4 bytes per word transfer on pcibus
	ADD	A,B	R4,X:<WORD_COUNT  ; Inc bus address by 4 bytes, and save word count
	RTS

; -------------------------------------------------------------------------------------------
WRITE_32_TO_PCI 			
; DMAs 32 x 16bit words to host memory as PCI burst.  	
;-----------------------------------------------------------------------------------------------
	MOVE	#32,N2			; Number of 16bit words per transfer 
	MOVE	#16,N4			; Number of 32bit words per transfer

	MOVE	R2,X:DSR0		; Source address for DMA = pixel data
	MOVEP	#DTXM,X:DDR0		; Destination = PCI master transmitter
	MOVEP	#>31,X:DCO0		; DMA Count = # of pixels - 1 

	EXTRACTU #$010010,B,A		; Get D31-16 bits only
	NOP
	MOVE	A0,A1			; [D31-16] in A1
	NOP
	ORI	#$0F0000,A		; Burst length = # of PCI writes 
	NOP				;   = # of pixels / 2 - 1 ...$0F = 16
	MOVE	A1,X:DPMC		; DPMC = B[31:16] + $3F0000

	EXTRACTU #$010000,B,A
	NOP
	MOVE	A0,A1			; Get PCI_ADDR[15:0] into A1[15:0]
	NOP
	ORI	#$070000,A		; A1 gets written to DPAR register
	NOP

	
AGAIN2	MOVEP	#$8EFA51,X:DCR0		; Start DMA with control register DE=1
	MOVEP	A1,X:DPAR		; Initiate writing to the PCI bus
	NOP
	NOP
	JCLR	#MARQ,X:DPSR,*		; Wait until the PCI operation is done
	JSET	#MDT,X:DPSR,WR_OK1	; If no error go to the next sub-block
	JSR	<PCI_ERROR_RECOVERY
	JMP	<AGAIN2			; Just try to write the sub-block again
WR_OK1	
	CLR 	A	(R4)+N4	  	  ; increment number of 32bit word count
	MOVE	#>64,A0			  ; 2 bytes on pcibus per pixel
	ADD	A,B	R4,X:<WORD_COUNT  ; PCI address = + 2 x # of pixels (!!!)
	MOVE	(R2)+N2			  ; Pixel buffer address = + # of pixels
	RTS

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
REV_NUMBER	DC	$410103		; byte 0 = minor revision #
					; byte 1 = mayor revision #
					; byte 2 = release Version (ascii letter)
REV_DATA	DC	$230905		; data: day-month-year
P_CHECKSUM	DC	$c06238         ;**** DO NOT CHANGE
; -------------------------------------------------

WORD_COUNT		DC	0	; word count.  Number of words successfully writen to host in last packet.	

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

ZERO			DC	0
ONE			DC	1
FOUR			DC	4

PACKET_SIZE_LOW		DC	0
PACKET_SIZE_HIH		DC	0

PREAMB1			DC	$A5A5	; pramble 16-bit word....2 of which make up first preamble 32bit word
PREAMB2			DC	$5A5A	; preamble 16-bit word....2 of which make up second preamble 32bit word
DATA_WD			DC	$4441	; "DA"
REPLY_WD		DC	$5250	; "RP"

TOTAL_BUFFS		DC	0	; total number of 512 buffers in packet
LEFT_TO_READ		DC	0	; number of words (16 bit) left to read after last 512 buffer
LEFT_TO_WRITE		DC	0	; number of woreds (32 bit) to write to host i.e. half of those left over read
NUM_LEFTOVER_BLOCKS	DC	0	; small block DMA burst transfer

DATA_DLY_VAL		DC	0	; data delay value..  Delay added to first frame received after GO command 

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
