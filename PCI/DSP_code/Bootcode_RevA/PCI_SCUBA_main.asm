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

; ****************************************************
; ************* MAIN PACKET SWITCHING CODE ***********
; ****************************************************

; initialse buffer pointers	
PACKET_IN
		MOVE	#<IMAGE_BUFFER,R1		; pointer for Fibre ---> Y mem
		MOVE	#<IMAGE_BUFFER,R2		; pointer for Y mem ---> PCI BUS	
	
; R1 used as pointer for data written to y:memory            FO --> (Y)
; R2 used as pointer for date in y mem to be writen to host  (Y) --> HOST
		
	
		BCLR	#SEND_TO_HOST,X:STATUS	; clear send to host flag
		BCLR	#ERROR_HF,X:<STATUS	; clear error flag
		BCLR	#FO_WRD_RCV,X:<STATUS	; clear Fiber Optic flag


; PCI test application loaded?
		JSET	#APPLICATION_LOADED,X:STATUS,APPLICATION	; at P:$800 for just now

; if 'GOA' command has been sent will jump to application memory space
; note that applications should terminate with the line 'JMP PACKET_IN'
; terminate appl with a STP command

					
CHK_FIFO	JSR	<GET_FO_WRD		        ; see if there's a 16-bit word in Fibre FIFO from MCE 
						        ; if so it will be in X0 (should be 'A5A5' - preamble)
						

		JSET	#FO_WRD_RCV,X:<STATUS,CHECK_WD	; if there is check its preamble
		JMP	<PACKET_IN			; else go back and repeat

; check that we have $a5a5a5a5 then $5a5a5a5a

CHECK_WD	MOVE	X0,X:<HEAD_W1_1			;store received word
		MOVE	X:PREAMB1,A
		CMP	X0,A				; check it is correct
		JNE	<PRE_ERROR			; if not go to start


		JSR	<WT_FIFO		; wait for next preamble 16-bit word
		MOVE	X0,X:<HEAD_W1_0		;store received word
		MOVE	X:PREAMB1,A
		CMP	X0,A			; check it is correct
		JNE	<PRE_ERROR		; if not go to start


		JSR	<WT_FIFO		; wait for next preamble 16-bit word
		MOVE	X0,X:<HEAD_W2_1		;store received word
		MOVE	X:PREAMB2,A
		CMP	X0,A			; check it is correct
		JNE	<PRE_ERROR		; if not go to start

		JSR	<WT_FIFO		; wait for next preamble 16-bit word
		MOVE	X0,X:<HEAD_W2_0		;store received word
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

		CLR	A			; check if it's a frame of data
		MOVE    X:<HEAD_W3_0,X0
		MOVE    X:<DATA_WD,A		; $4441
		CMP	X0,A
		JNE	MCE_PACKET              ; if not - then must be a command reply
INC_FRAME_COUNT					; if frame then inc count (which host PC can interrogate/clear)

; increment frame count

		CLR	A
		MOVE	X:<FRAME_COUNT,A0
		INC	A
		NOP
		MOVE	A0,X:<FRAME_COUNT


; *********************************************************************
; *********************** IT'S A PAKCET FROM MCE ***********************
; ***********************************************************************	
; ***  Data or reply packet from MCE *******

; prepare notify to inform host that a packet has arrived.

MCE_PACKET
		MOVE	#'NFY',X0		; initialise communication to host as a notify
		MOVE	X0,X:<DTXS_WD1		; 1st word transmitted to host to notify there's a message

		MOVE	X:<HEAD_W3_0,X0		;RP or DA
		MOVE	X0,X:<DTXS_WD2		;2nd word transmitted to host to notify there's a message

		MOVE	X:<HEAD_W4_0,X0		; size of packet LSB 16bits (# 32bit words)
		MOVE	X0,X:<DTXS_WD3		; 3rd word transmitted to host to notify there's a message

		MOVE	X:<HEAD_W4_1,X0		; size of packet MSB 16bits (# of 32bit words)
		MOVE	X0,X:<DTXS_WD4		; 4th word transmitted to host to notify there's a message


; ********************* HOW MANY BUFFERS ****************************************************************

; Note that this JSP uses accumulator B 
; therefore it MUST be run before we get the bus address from host... 
; i.e before we send 'NFY'

		JSR	<CALC_NO_BUFFS		; subroutine which calculates the number of 512 (16bit) buffers 
						; number of left over 32 (16bit) blocks  
						; and number of left overs (16bit) words  

;  note that a 512 (16-bit) buffer is transfered to the host as a 256 x 32bit burst
;            a 32  (16-bit) block is transfered to the host as a 16 x 32bit burst
;            left over 16bit words are transfered to the host in pairs as 32bit words 
; ****************************************************************************************************************


		CLR	A
		MOVE	X:<TOTAL_BUFFS,X0			  
		CMP	X0,A                    ; are there any 512 buffers to process
		JEQ	<CHK_SMALL_BLK		; is it a very small packet - i.e less than 512 words so no 512 buffers
		JMP	<WT_HOST_3		; there is a 512 block to move
	
CHK_SMALL_BLK
		CLR	A
		MOVE	X:<NUM_LEFTOVER_BLOCKS,X0			  
		CMP	X0,A                             ; are there any 32 blocks to process
		JNE	<WT_HOST_3			; there is a 32 (16bit) block to transfer
		

WT_HOST_2	JSR	<PCI_MESSAGE_TO_HOST		; notify host of packet	
		JCLR	#SEND_TO_HOST,X:<STATUS,*	; wait for host to reply - which it does with 'send_packet_to_host' ISR
		BCLR	#SEND_TO_HOST,X:<STATUS		; tidy up
		JMP	<LEFT_OVERS			; jump to left overs since HF not required	
		

WT_HOST_3	JSR	<PCI_MESSAGE_TO_HOST		; notify host of packet	
		JCLR	#SEND_TO_HOST,X:<STATUS,*	; wait for host to reply - which it does with 'send_packet_to_host' ISR
		BCLR	#SEND_TO_HOST,X:<STATUS		; tidy up


; we now have 32 bit address in accumulator B
; from send-packet_to_host

; ************************* DO LOOP to write buffers to host **************************************
				
		DO	X:<TOTAL_BUFFS,ALL_BUFFS_END


		MOVE	#<IMAGE_BUFFER,R1		; FO ---> Y mem 
		MOVE	#<IMAGE_BUFFER,R2		; Y mem ----->  PCI BUS	

WAIT_BUFF
		JSET	#HF,X:PDRD,*		; Wait for FIFO to be half full + 1
		NOP
		NOP
		JSET	#HF,X:PDRD,WAIT_BUFF	; Protection against metastability


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

; ******************************* END of buffer read/write DO LOOP *****************************************************

; less than 512 pixels but if greater than 32 will then do bursts
; of 16 x 32bit in length, if less than 32 then does single read writes

		DO	X:<NUM_LEFTOVER_BLOCKS,LEFTOVER_BLOCKS
		MOVE	#<IMAGE_BUFFER,R1		; FO ---> Y mem
		MOVE	#<IMAGE_BUFFER,R2		; Y mem ----->  PCI BUS	

		DO	#32,S_BUFFER
WAIT_1		JCLR	#EF,X:PDRD,*		; Wait for the pixel datum to be there
		NOP				; Settling time
		NOP
		JCLR	#EF,X:PDRD,WAIT_1	; Protection against metastability
		MOVEP	Y:RDFIFO,Y:(R1)+
S_BUFFER

		JSR	<WRITE_32_TO_PCI			; write small blocks
		NOP
LEFTOVER_BLOCKS



LEFT_OVERS	
		MOVE	#<IMAGE_BUFFER,R1		; FO ---> Y mem
		MOVE	#<IMAGE_BUFFER,R2		; Y mem ----->  PCI BUS	

		DO	X:<LEFT_TO_READ,LEFT_OVERS_READ		; read in remaining words of data packet
		JSR	<WT_FIFO_DA					; each word from FIFO to X0
		MOVE	X0,Y:(R1)+				; now store in Y memory
LEFT_OVERS_READ

; now write left overs to host as 32 bit words
		
		DO	X:LEFT_TO_WRITE,LEFT_OVERS_WRITEN	; left overs to write is half left overs read - since 32 bit writes
		JSR	WRITE_TO_PCI				; uses R2 as pointer to Y memory, host address in B	
LEFT_OVERS_WRITEN



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

HST_ERR_REP
		MOVE	#'REP',X0
		MOVE	X0,X:<DTXS_WD1		; REPly
		MOVE	#'HST',X0
		MOVE	X0,X:<DTXS_WD2		; echo command sent
		MOVE	#'ERR',X0
		MOVE	X0,X:<DTXS_WD3		; ACKnowledge okay
		MOVE	#'HFE',X0
		MOVE	X0,X:<DTXS_WD4		; HF error
		JSR	<PCI_MESSAGE_TO_HOST
		JMP	<PACKET_IN		; return to service timing board fibre




; ****************************************************************************************
; ************************************ INTERRUPT ROUTINES ********************************
; *****************************************************************************************

; ISR routines defined here
; place holders only in place so we can build the code

; Clean up the PCI board from wherever it was executing
CLEAN_UP_PCI
	MOVEP	#$0001C0,X:IPRC		; Disable HF* FIFO interrupt
	MOVE	#$200,SR		; mask for reset interrupts only

	MOVEC	#1,SP			; Point stack pointer to the top	
	MOVEC	#$000200,SSL		; SR = zero except for interrupts
	MOVEC	#0,SP			; Writing to SSH preincrements the SP
	MOVEC	#START,SSH		; Set PC to for full initialization
	NOP
	RTI
; ---------------------------------------------------------------------------

WRITE_MEMORY
; word 1 = command = 'WRM'
; word 2 = memory type, P=$00'_P', X=$00'_X' or Y=$00'_Y'
; word 3 = address in memory
; word 4 = value 
	JSR	<RD_DRXR		; read words from host write to HTXR
	MOVE	X:DRXR_WD1,A		; read command
	MOVE	#'WRM',X0
	CMP	X0,A			; ensure command is 'WRM'
	JNE	<WRITE_MEMORY_ERROR	; error, command NOT HCVR address
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
        JNE	<WRITE_MEMORY_ERROR	
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
	JSR	<PCI_MESSAGE_TO_HOST
	JMP	<END_WRITE_MEMORY

; when there is a failure in the host to PCI command then the PCI
; needs still to reply to Host but with an error message
WRITE_MEMORY_ERROR
	MOVE	#'REP',X0
	MOVE	X0,X:<DTXS_WD1		; REPly
	MOVE	#'WRM',X0
	MOVE	X0,X:<DTXS_WD2		; echo command sent
	MOVE	#'ERR',X0
	MOVE	X0,X:<DTXS_WD3		; ERRor im command
	MOVE	#'001',X0
	MOVE	X0,X:<DTXS_WD4		; write to PCI memory error
	JSR	<PCI_MESSAGE_TO_HOST
END_WRITE_MEMORY
	RTI

; ------------------------------------------------------------------------
READ_MEMORY
; word 1 = command = 'RDM'
; word 2 = memory type, P=$00'_P', X=$00_'X' or Y=$00_'Y'
; word 3 = address in memory
; word 4 = not used
	JSR	<RD_DRXR		; read words from host write to HTXR
	MOVE	X:DRXR_WD1,A		; read command
	MOVE	#'RDM',X0
	CMP	X0,A			; ensure command is 'RDM'
	JNE	<READ_MEMORY_ERROR	; error, command NOT HCVR address
	MOVE	X:<DRXR_WD2,A		; Memory type (X, Y, P)
	MOVE	X:<DRXR_WD3,B
	NOP				; pipeline restriction
	MOVE	B1,R0			; get address to write to
	MOVE	X:<DRXR_WD4,X0		; get data to write
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
        JNE	<READ_MEMORY_ERROR	
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
	JSR	<PCI_MESSAGE_TO_HOST
	JMP	<END_READ_MEMORY

; when there is a failure in the host to PCI command then the PCI
; needs still to reply to Host but with an error message
READ_MEMORY_ERROR
	MOVE	#'REP',X0
	MOVE	X0,X:<DTXS_WD1		; REPly
	MOVE	#'RDM',X0
	MOVE	X0,X:<DTXS_WD2		; echo command sent
	MOVE	#'ERR',X0
	MOVE	X0,X:<DTXS_WD3		; ERRor im command
	MOVE	#'001',X0
	MOVE	X0,X:<DTXS_WD4		; write to PCI memory error
	JSR	<PCI_MESSAGE_TO_HOST
END_READ_MEMORY
	RTI
	

; ----------------------------------------------------------------------
; an application should already have been downloaded to the PCI memory
; before this command is called - this command compares the 
; application name against the name in the GO command - if not the same
; then error else switch on a flag to tell the boot code to start the application

START_APPLICATION
; word 1 = command = 'GOA'
; word 2 = application number or name
; word 3 = not used but read
; word 4 = not used but read
	JSR	<RD_DRXR		; read words from host write to HTXR
	MOVE	X:<DRXR_WD1,A		; read command
	MOVE	#'GOA',X0
	CMP	X0,A			; ensure command is 'RDM'
	JNE	<GO_ERROR		; error, command NOT HCVR address
	MOVE	X:<DRXR_WD2,X0		; APPLICATION NUMBER/NAME
	MOVE	X:<DRXR_WD3,A		; read word 3 - not used
	MOVE	X:<DRXR_WD4,B		; read word 4 - not used
; if we get here then everything is fine and we can start the application
; but first we must reply to the host that everyting is fine and then
;start the application        

; when completed successfully then PCI needs to reply to Host with
; word1 = reply/data = reply
FINISH_GO
	MOVE	#'REP',X0
	MOVE	X0,X:<DTXS_WD1		; REPly
	MOVE	#'GOA',X0
	MOVE	X0,X:<DTXS_WD2		; echo command sent
	MOVE	#'ACK',X0
	MOVE	X0,X:<DTXS_WD3		; ACKnowledge okay
	MOVE	#'000',X0
	MOVE	X0,X:<DTXS_WD4		; read data
	JSR	<PCI_MESSAGE_TO_HOST

; remember we are in an ISR so we just can't jump to any old code since
; we must return from the ISR properly - thereofre we switched on a flag
; in a STATUS word which tells the boot code that it has an application loaded
; which it must now run
	BSET	#APPLICATION_LOADED,X:<STATUS
	JMP	<END_GO

; when there is a failure in the host to PCI command then the PCI
; needs still to reply to Host but with an error message
GO_ERROR
	MOVE	#'REP',X0
	MOVE	X0,X:<DTXS_WD1	; REPly
	MOVE	#'GOA',X0
	MOVE	X0,X:<DTXS_WD2	; echo command sent
	MOVE	#'ERR',X0
	MOVE	X0,X:<DTXS_WD3	; ERRor im command
	MOVE	#'003',X0
	MOVE	X0,X:<DTXS_WD4	; write to PCI memory error
	JSR	<PCI_MESSAGE_TO_HOST
; failure so ensure that no application is started
	BCLR	#APPLICATION_LOADED,X:<STATUS 
END_GO
	RTI

; ---------------------------------------------------------
; this command stops an application that is already running
STOP_APPLICATION
; word 1 = command = ' STP'
; word 2 = application number or name
; word 3 = not used but read
; word 4 = not used but read
	JSR	<RD_DRXR		; read words from host write to HTXR
	MOVE	X:<DRXR_WD1,A		; read command
	MOVE	#'STP',X0
	CMP	X0,A			; ensure command is 'RDM'
	JNE	<STP_ERROR		; error, command NOT HCVR address
	MOVE	X:<DRXR_WD2,X0		; APPLICATION NUMBER/NAME
	MOVE	X:<DRXR_WD3,A		; read word 3 - not used
	MOVE	X:<DRXR_WD4,B		; read word 4 - not used
; if we get here then everything is fine and we can start the application
; but first we must reply to the host that everyting is fine and then
;start the application        

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
	JSR	<PCI_MESSAGE_TO_HOST

; remember we are in an ISR so we just can't jump to any old code since
; we must return from the ISR properly - therefore we switch the flag
; off to tell the bootcode that no application is loaded
	BCLR	#APPLICATION_LOADED,X:<STATUS
	JMP	<END_STP

; when there is a failure in the host to PCI command then the PCI
; needs still to reply to Host but with an error message
STP_ERROR
	MOVE	#'REP',X0
	MOVE	X0,X:<DTXS_WD1		; REPly
	MOVE	#'STP',X0
	MOVE	X0,X:<DTXS_WD2		; echo command sent
	MOVE	#'ERR',X0
	MOVE	X0,X:<DTXS_WD3		; ERRor im command
	MOVE	#'004',X0
	MOVE	X0,X:<DTXS_WD4		; write to PCI memory error
	JSR	<PCI_MESSAGE_TO_HOST
; failure so ensure that application continues to run.
	BSET	#APPLICATION_LOADED,X:STATUS 
END_STP
	RTI

; -------------------------------------------------------------------
; nothing defined at present - just checks command and the replies
; with ACKnowledge or ERRor
; will modify later to do a nice cleanup and program start
SOFTWARE_RESET
; word 1 = command = 'RST'
; word 2 = not used but read
; word 3 = not used but read
; word 4 = not used but read
	JSR	<RD_DRXR		; read words from host write to HTXR
	MOVE	X:<DRXR_WD1,A		; read command
	MOVE	#'RST',X0
	CMP	X0,A			; ensure command is 'RST'
	JNE	<RST_ERROR		; error, command NOT HCVR address
	MOVE	X:<DRXR_WD2,X0		; read but not used
	MOVE	X:<DRXR_WD3,A		; read word 3 - not used
	MOVE	X:<DRXR_WD4,B		; read word 4 - not used
; if we get here then everything is fine and we can start the application
; but first we must reply to the host that everyting is fine and then
;start the application        

; when completed successfully then PCI needs to reply to Host with
; word1 = reply/data = reply
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


	JMP	<END_RST

; when there is a failure in the host to PCI command then the PCI
; needs still to reply to Host but with an error message
RST_ERROR
	MOVE	#'REP',X0
	MOVE	X0,X:<DTXS_WD1		; REPly
	MOVE	#'RST',X0
	MOVE	X0,X:<DTXS_WD2		; echo command sent
	MOVE	#'ERR',X0
	MOVE	X0,X:<DTXS_WD3		; ERRor im command
	MOVE	#'005',X0
	MOVE	X0,X:<DTXS_WD4		; write to PCI memory error
	JSR	<PCI_MESSAGE_TO_HOST
; failure so ensure that application continues to run.
	BSET	#APPLICATION_LOADED,X:<STATUS 
END_RST
	RTI

; ---------------------------------------------------------------

; forward packet stuff to the MCE
; gets address in HOST memory where packet is stored
; read 3 consecutive locations starting at this address
; then sends the data from these locations up to the MCE
SEND_PACKET_TO_CONTROLLER

; word 1 = command = 'CON'
; word 2 = host high address
; word 3 = host low address
; word 4 = '0' --> normal command
;	 = '1' --> 'block command'
; all MCE commands are now 'block commands'
; i.e. 64 words long.


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

	MOVE	X:<DRXR_WD4,A		; read word 4 - block command?
	MOVE	X:ZERO,X0
	CMP	X0,A
	JNE	BLOCK_CON
 

; PCI address incremented in Sub routine
; get 32bit word as 2 x 16 bit words

; preamble
	JSR	<READ_FROM_PCI		; get a 32 bit word from HOST
	MOVE	X0,X:<PCI_WD1_1		; read word 1 from host memory
	MOVE	X1,X:<PCI_WD1_2			
; preamble
	JSR	<READ_FROM_PCI		; get a 32 bit word from HOST
	MOVE	X0,X:<PCI_WD2_1		; read word 2 from host memory
	MOVE	X1,X:<PCI_WD2_2
; command
	JSR	<READ_FROM_PCI		; get a 32 bit word from HOST
	MOVE	X0,X:<PCI_WD3_1		; read word 3 from host memory
	MOVE	X1,X:<PCI_WD3_2	
;arg1
	JSR	<READ_FROM_PCI		; get a 32 bit word from HOST
	MOVE	X0,X:<PCI_WD4_1		; read word 4 from host memory
	MOVE	X1,X:<PCI_WD4_2	
;arg2
	JSR	<READ_FROM_PCI		; get a 32 bit word from HOST
	MOVE	X0,X:<PCI_WD5_1		; read word 5 from host memory
	MOVE	X1,X:<PCI_WD5_2	
;checksum
	JSR	<READ_FROM_PCI		; get a 32 bit word from HOST
	MOVE	X0,X:<PCI_WD6_1		; read word 6 from host memory
	MOVE	X1,X:<PCI_WD6_2	


; when we reach this stage then we have successfully read a 3 word packet from
; the host which has to be send onwards to the Timing board
; the routine which transmits to the fibre expects the word to be in register A1

; preamble
	MOVE	X:<PCI_WD1_1,A1		; put 1st word (1) in A1 to transmit
	MOVE	X:<PCI_WD1_2,A0		; put 1st word (2) in A1 to transmit
	JSR	<XMT_WD_FIBRE		; off it goes
;preamble
	MOVE	X:<PCI_WD2_1,A1		; put 2nd word (1) in A1 to transmit
	MOVE	X:<PCI_WD2_2,A0		; put 2nd word (2) in A1 to transmit
	JSR	<XMT_WD_FIBRE		; off it goes
; command
	MOVE	X:<PCI_WD3_1,A1		; put 3rd word (1) in A1 to transmit
	MOVE	X:<PCI_WD3_2,A0		; put 3rd word (2) in A1 to transmit
	JSR	<XMT_WD_FIBRE		; off it goes
; arg1
	MOVE	X:<PCI_WD4_1,A1		; put 4th word (1) in A1 to transmit
	MOVE	X:<PCI_WD4_2,A0		; put 4th word (2)in A1 to transmit
	JSR	<XMT_WD_FIBRE		; off it goes
; arg2
	MOVE	X:<PCI_WD5_1,A1		; put 5th word (1) in A1 to transmit
	MOVE	X:<PCI_WD5_2,A0		; put 5th word (2) in A1 to transmit
	JSR	<XMT_WD_FIBRE		; off it goes
; check sum
	MOVE	X:<PCI_WD6_1,A1		; put 6th word (1) in A1 to transmit
	MOVE	X:<PCI_WD6_2,A0		; put 6th word (2) in A1 to transmit
	JSR	<XMT_WD_FIBRE		; off it goes
	JMP	<FINISH_CON		; finished

BLOCK_CON
	DO	#64,END_BLOCK_CON	; block size = 32bit x 64 (256 bytes)
	JSR	<READ_FROM_PCI		; get next 32 bit word from HOST
	MOVE	X0,A1			; prepare to send
	MOVE	X1,A0			; prepare to send
	JSR	<XMT_WD_FIBRE		; off it goes
	NOP
END_BLOCK_CON

; --------------- this might work for a DMA block burst read ----------------

; DMA block CON
; note maximum block size is 64 (burst limit - since six bits in DPMC define length)

;BLOCK_CON
; set up clock size in x0, address in B

;	MOVE	X:WBLK_SIZE,X0
;	JSR	<READ_WBLOCK		; DMA read block --> Y memory	

;XMT_WBLOCK				; send to BAC
;	MOVE	X:ZERO,R3
;	MOVE	X:WBLK_SIZE,X0		;
;	DO	X0,END_XMT_WBLOCK	; block size in X0
;	MOVE	Y:(R3)+,A1		; get word MS16
;	MOVE	Y:(R3)+,A0		; get word LS16
;	JSR	<XMT_WD_FIBRE		; ...off it goes
;	NOP
;END_XMT_WBLOCK
;	NOP
;END_BLOCK_CON

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
	JSR	<PCI_MESSAGE_TO_HOST
	JMP	<END_CON

; when there is a failure in the host to PCI command then the PCI
; needs still to reply to Host but with an error message
CON_ERROR
	MOVE	#'REP',X0
	MOVE	X0,X:<DTXS_WD1		; REPly
	MOVE	#'CON',X0
	MOVE	X0,X:<DTXS_WD2		; echo command sent
	MOVE	#'ERR',X0
	MOVE	X0,X:<DTXS_WD3		; ERRor im command
	MOVE	#'006',X0
	MOVE	X0,X:<DTXS_WD4		; write to PCI memory error
	JSR	<PCI_MESSAGE_TO_HOST

END_CON

	RTI

; ------------------------------------------------------------------------------------

SEND_PACKET_TO_HOST
; this command is received from the Host and actions the PCI board to pick up an address
; pointer from DRXR which the PCI board then uses to write packets from the 
; MCE to the host memory starting at the address given.
; Since this is interrupt driven all this piece of code does is get the address pointer from
; the host via DRXR, set a flag so that the main prog can write the packet.  Replies to  
; HST after packet sent (unless error).
;
; word 1 = command = 'HST'
; word 2 = host high address
; word 3 = host low address
; word 4 = not used but read

; store some registers.....

	MOVEC	SR,X:<SV_SR
	MOVE	A0,X:<SV_A0		; Save registers used here
	MOVE	A1,X:<SV_A1
	MOVE	A2,X:<SV_A2
	MOVE	X0,X:<SV_X0		


	JSR	<RD_DRXR		; read words from host write to HTXR
	CLR	B
	MOVE	X:<DRXR_WD1,A		; read command
	MOVE	#'HST',X0
	CMP	X0,A			; ensure command is 'HST'
	JNE	<HOST_ERROR		; error, command NOT HCVR address
	MOVE	X:<DRXR_WD2,X0		; high 16 bits of address 
	MOVE	X:<DRXR_WD3,B0		; low 16 bits of adderss
	INSERT	#$010010,X0,B		; convert to 32 bits and put in B
	MOVE	X:<DRXR_WD4,X0		; dummy
	
	BSET	#SEND_TO_HOST,X:<STATUS	; tell main program to start sending packets
	JMP	<END_HOST

; !!!!!!!!!!!! the reply is not sent here unless error !!!!!!!
; reply to this command is sent after packet has been sucessfully send to host.


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
	MOVE	#'007',X0
	MOVE	X0,X:<DTXS_WD4		; write to PCI memory error
	JSR	<PCI_MESSAGE_TO_HOST
END_HOST


	MOVEC	X:<SV_SR,SR
	MOVE	X:<SV_A0,A0		; restore registers used here
	MOVE	X:<SV_A1,A1
	MOVE	X:<SV_A2,A2
	MOVE	X:<SV_X0,X0		

	RTI
; --------------------------------------------------------------------

; Reset the controller by sending a special code byte $0B with SC/nData = 1
RESET_CONTROLLER
; word 1 = command = 'RCO'
; word 2 = not used but read
; word 3 = not used but read
; word 4 = not used but read
	JSR	<RD_DRXR		; read words from host write to HTXR
	MOVE	X:<DRXR_WD1,A		; read command
	MOVE	#'RCO',X0
	CMP	X0,A			; ensure command is 'RCO'
	JNE	<RCO_ERROR		; error, command NOT HCVR address
	MOVE	X:<DRXR_WD2,X0		; read but not used
	MOVE	X:<DRXR_WD3,A		; read word 3 - not used
	MOVE	X:<DRXR_WD4,B		; read word 4 - not used

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

; Wait until the timing board is reset, because FO data is invalid
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
	JSR	<PCI_MESSAGE_TO_HOST

	JMP	<END_RST

; when there is a failure in the host to PCI command then the PCI
; needs still to reply to Host but with an error message
RCO_ERROR
	MOVE	#'REP',X0
	MOVE	X0,X:DTXS_WD1		; REPly
	MOVE	#'RCO',X0
	MOVE	X0,X:DTXS_WD2		; echo command sent
	MOVE	#'ERR',X0
	MOVE	X0,X:DTXS_WD3		; ERRor im command
	MOVE	#'006',X0
	MOVE	X0,X:DTXS_WD4		; write to PCI memory error
	JSR	<PCI_MESSAGE_TO_HOST 
END_RCO
	RTI
;---------------------------------------------------------------
;                          * END OF ISRs *
; --------------------------------------------------------------



;                     * Beginning of SUBROUTINES *
; --------------------------------------------------------------
; routine is used to read from HTXR-DRXR data path
; which is used by the Host to communicate with the PCI board
; the host writes 4 words to this FIFO then interrupts the PCI
; which reads the 4 words and acts on them accordingly.
RD_DRXR
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

; ----------------------------------------------------------------------------
; subroutine to send 4 words as a reply from PCI to the Host
; using the DTXS-HRXS data path
; PCI card writes here first then causes an interrupt INTA on
; the PCI bus to alert the host to the reply message
PCI_MESSAGE_TO_HOST

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

; once the transmit words are in the FIFO, interrupt the Host
; the Host should clear this interrupt once it has seen it
; to do this it writes to the HCVR to cause a fast interrupt in the DSP
; which clears the interrupt

	BSET	#INTA,X:DCTR		; Assert the interrupt

	RTS

; ---------------------------------------------------------------

; sub routine to read a 24 bit word in  from PCI bus
; first setup the PCI address
; assumes register B contains the 32 bit PCI address
READ_FROM_PCI

; read as master 

	EXTRACTU #$010010,B,A		; Get D31-16 bits only
	NOP

	MOVE	A0,A1
	NOP
	MOVE	A1,X:DPMC		; high 16bits of address in DSP master cntr reg.

; these should both be clear from above write....for 32 bit read.
;	BCLR	#FC1,X:DPMC		; 32 bit read FC1 = 0, FC1 = 0
;	BCLR	#FC0,X:DPMC	


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

; sub routine to write two 16 bit words to the PCI bus
; which get read as a 32 bit word by the PC
; the 32 bit address we are writing to is writen to DPMC (MSBs) and DPAR (LSBs)
; writes 2 words from Y:memory to one 32 bit PC address then increments address
;
; R2 is used as a pointer to Y:memory address




; sub routine to read a block of 24 bit words from PCI bus --> Y mem
; assumes register B contains the 32 bit PCI address
; register X0 contains block size

; ------------------------------------------------------------------------------

READ_WBLOCK
; this subroutine is as of yet untested.....26/2/4 da
; and is currently not used.

; set up DMA parameters 

	CLR	A
	NOP
	MOVE	A,R3

	MOVE	R3,X:DDR0		; destination address address for DMA Y(R3)
	MOVEP	#DRXR,X:DSR0		; source address for DMA X:DRXR

	MOVE	X0,A			; get block size
	ASL	A			; double - since DMA trnasfers are extended 16bit
	DEC	A
	NOP
	MOVEP	A,X:DCO0		; #dma txfs - 1 (2*block size - 1)

; get burst length -1 into top byte of X0 (block size-1)
	MOVE	X0,A
	DEC	A
	ASL	#16,A,A
	NOP
	ANDI	#$FF0000,A		; mask off bottom two bytes
	MOVE	A,X0

; read as master 


	EXTRACTU #$010010,B,A		; Get D31-16 bits only
	NOP
	MOVE	A0,A1
	NOP
	OR	X0,A			; add burst length to address
	NOP
	MOVE	A1,X:DPMC		; high 16bits of address in DSP master cntr reg.

	NOP
	EXTRACTU #$010000,B,A
	NOP
	MOVE	A0,A1
	OR	#$060000,A		; A1 gets written to DPAR register
	NOP				; C3-C0 of DPAR=0110 for memory read
	
	MOVEP	#$8EFAC4,X:DCR0		; START DMA with control reg DE=1
					; source X, destination Y
					; post inc dest.

WRTB_ADD
	MOVEP	A1,X:DPAR		; Initiate PCI READ action
	NOP				; Pipeline delay
RDB_PCI
	JSET	#MRRQ,X:DPSR,GETB_DON	; If MTRQ = 1 - FIFO DRXR contains data
	JCLR	#TRTY,X:DPSR,RDB_PCI	; Bit is set if its a retry
	MOVEP	#$0400,X:DPSR		; Clear bit 10 = target retry bit
	JCLR	#MARQ,X:DPSR,*		; Wait for PCI addressing to be complete
	JMP	<WRTB_ADD
GETB_DON
	JSET	#MRRQ,X:DPSR,*		; wait till finished.....till DMA empties DRXR
	RTS


; --------------------------------------------------------------------------------


WRITE_TO_PCI 		
	
	JCLR	#MTRQ,X:DPSR,*		; wait here if DTXM is full

TX_LSB	MOVEP	Y:(R2)+,X:DTXM		; Least significant word to transmit
TX_MSB	MOVEP	Y:(R2)+,X:DTXM		; Most significant word to transmit


	EXTRACTU #$010010,B,A		; Get D31-16 bits only
	NOP
	MOVE	A0,A1

; we are using two 16 bit writes to make a 32bit word so FC1=0 and FC1=0

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
	REP	#4			; increment PCI address by four bytes.
	INC	B			
	NOP
	RTS

; ----------------------------------------------------------------------------------

; R2 is used as a pointer to Y:memory address

WRITE_512_TO_PCI 		; writes 512 pixels (256 x 32bit writes) across PCI bus in 4 x 128 pixel bursts 		
	MOVE	#128,N2			; Number of pixels per transfer (!!!)

; Make sure its always 512 pixels per loop = 1/2 FIFO
	MOVE	R2,X:DSR0		; Source address for DMA = pixel data
	MOVEP	#DTXM,X:DDR0		; Destination = PCI master transmitter
	MOVEP	#>127,X:DCO0		; DMA Count = # of pixels - 1 (!!!)

; Do loop does 4 x 128 pixel DMA writes = 512.
; need to recalculate hi and lo parts of address
; for each burst.....Leach doesn't do this since not
; multiple frames...so only needs to inc low part.....

	DO	#4,WR_BLK0		; x # of pixels = 512 (!!!)

	EXTRACTU #$010010,B,A		; Get D31-16 bits only
	NOP
	MOVE	A0,A1			; [D31-16] in A1
	NOP
	ORI	#$3F0000,A		; Burst length = # of PCI writes (!!!)
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

	CLR 	A
	MOVE	#>256,A0		; 2 bytes on pcibus per pixel
	ADD	A,B			; PCI address = + 2 x # of pixels (!!!)
	MOVE	(R2)+N2			; Pixel buffer address = + # of pixels
WR_BLK0
	RTS

; -------------------------------------------------------------------------------------------

WRITE_32_TO_PCI 			; writes 32 pixels....= 16 x 32bit words across PCI bus bursted 	
	MOVE	#32,N2			; Number of pixels per transfer (!!!)

	MOVE	R2,X:DSR0		; Source address for DMA = pixel data
	MOVEP	#DTXM,X:DDR0		; Destination = PCI master transmitter
	MOVEP	#>31,X:DCO0		; DMA Count = # of pixels - 1 (!!!)

	EXTRACTU #$010010,B,A		; Get D31-16 bits only
	NOP
	MOVE	A0,A1			; [D31-16] in A1
	NOP
	ORI	#$0F0000,A		; Burst length = # of PCI writes (!!!)
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
	CLR 	A
	MOVE	#>64,A0			; 2 bytes on pcibus per pixel
	ADD	A,B			; PCI address = + 2 x # of pixels (!!!)
	MOVE	(R2)+N2			; Pixel buffer address = + # of pixels
	RTS


; ------------------------------------------------------------------------------

	; Recover from an error writing to the PCI bus
PCI_ERROR_RECOVERY
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

; --------------------------------------------------------------------------------
	

; **********   get a word from FO and put in X0     **********************************

GET_FO_WRD	JCLR	#EF,X:PDRD,CLR_FO_RTS
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

GET_WD	MOVEP	Y:RDFIFO,X0			; then read to X0
	MOVE	#$00FFFF,A1			; mask off top 2 bytes ($FC)
	AND	X0,A				; since receiving 16 bits in 24bit register
	NOP
	MOVE	A1,X0
SET_FO_RTS	BSET	#FO_WRD_RCV,X:<STATUS
END_WT_FIFO	RTS

CLR_FO_RTS	BCLR	#FO_WRD_RCV,X:<STATUS
		RTS

; ----------------------------------------------------------------------------------

; put this in just now for left over data reads
WT_FIFO_DA
	JCLR	#EF,X:PDRD,*		; Wait till something in FIFO flagged
	NOP
	NOP
	JCLR	#EF,X:PDRD,WT_FIFO_DA   	; check twice.....
	MOVEP	Y:RDFIFO,X0			; then read to X0
	MOVE	#$00FFFF,A1			; mask off top 2 bytes ($FC)
	AND	X0,A				; since receiving 16 bits and 3 bytes sent	
	NOP
	MOVE	A1,X0
	RTS

; Short delay for reliability
XMT_DLY	NOP
	NOP
	NOP
	RTS

; 250 MHz code - Transmit contents of Accumulator A1 to the MCE

; we want to send 32bit word in little endian fomat to the host.
; i.e. b4b3b2b1 goes b1, b2, b3, b4

; currently the bytes are in this order:
; then A1 = $00 b2 b1
; and  A0 = $00 b4 b3
; A = $00 00 b2 b1 00 b4 b3


XMT_WD_FIBRE

; save registers 

	MOVE	A0,X:<SV_A0		; Save registers used in XMT_WRD
	MOVE	A1,X:<SV_A1
	MOVE	A2,X:<SV_A2
	MOVE	X1,X:<SV_X1
	MOVE	X0,X:<SV_X0
	MOVE	Y1,X:<SV_Y1
	MOVE	Y0,X:<SV_Y0

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
	MOVE	Y1,X:(R0)		; byte b2- off it goes
	MOVE	X0,X:(R0)		; byte b3 - off it goes 
	MOVE	X1,X:(R0)		; byte b4 - off it goes

; restore registers
	MOVE	A0,X:<SV_A0
	MOVE	A1,X:<SV_A1
	MOVE	A2,X:<SV_A2
	MOVE	X:<SV_X1,X1		; Restore registers used here
	MOVE	X:<SV_X0,X0
	MOVE	X:<SV_Y1,Y1
	MOVE	X:<SV_Y0,Y0
	RTS

; ----------------------------------------------------------------------------

; number of 512 buffers in packet calculated (X:TOTAL_BUFFS) 
; and number of left over blocks 
; and left over words (X:LEFT_TO_READ)

CALC_NO_BUFFS
	
	MOVE	Y0,X:<SV_Y0
	MOVE	Y1,X:<SV_Y1

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

	MOVE	X:<SV_Y0,Y0
	MOVE	X:<SV_Y1,Y1

	RTS

; -------------------------------------------------------------------------------------

; ******** end of Sub Routines ********


	IF	@CVS(N,*)>=APPLICATION
        WARN    'The boot code is too large and could be overwritten by an Application!'
	ENDIF




; ******************************************
;******* x memory parameter table **********
; ******************************************

        ORG     X:VAR_TBL,P:


	IF	@SCP("DOWNLOAD","ROM")	; Boot ROM code
VAR_TBL_START	EQU	@LCV(L)-2
	ENDIF

	IF	@SCP("DOWNLOAD","ONCE")	; Download via ONCE debugger
VAR_TBL_START	EQU	@LCV(L)
	ENDIF

; -----------------------------------------------
; do not move these from X:0 and X:1
STATUS		DC	0
FRAME_COUNT	DC	0	; used as a check....... increments for every frame write.....must be cleared by host.
PRE_CORRUPT	DC	0
; -------------------------------------------------

DRXR_WD1	DC	0
DRXR_WD2	DC	0
DRXR_WD3	DC	0
DRXR_WD4	DC	0
DTXS_WD1	DC	0
DTXS_WD2	DC	0
DTXS_WD3	DC	0
DTXS_WD4	DC	0

PCI_WD1_1	DC	0
PCI_WD1_2	DC	0
PCI_WD2_1	DC	0
PCI_WD2_2	DC	0
PCI_WD3_1	DC	0
PCI_WD3_2	DC	0
PCI_WD4_1	DC	0
PCI_WD4_2	DC	0
PCI_WD5_1	DC	0
PCI_WD5_2	DC	0
PCI_WD6_1	DC	0
PCI_WD6_2	DC	0


HEAD_W1_1	DC	0
HEAD_W1_0	DC	0
HEAD_W2_1	DC	0
HEAD_W2_0	DC	0
HEAD_W3_1	DC	0
HEAD_W3_0	DC	0
HEAD_W4_1	DC	0
HEAD_W4_0	DC	0


REP_WD1		DC	0
REP_WD2		DC	0
REP_WD3		DC	0
REP_WD4		DC	0

NO_32BIT	DC	0
MASK_16BIT	DC	$00FFFF	; 16 bit mask to clear top to bytes
C00FF00		DC	$00FF00

SV_A0		DC	0   
SV_A1		DC	0 
SV_A2		DC	0
SV_B0		DC	0
SV_B1		DC	0
SV_B2		DC	0
SV_X0		DC	0
SV_X1		DC	0
SV_Y0		DC	0
SV_Y1		DC	0

SV_SR		DC	0	; stauts register save.

ZERO		DC	0
ONE		DC	1
TWO		DC	2
THREE		DC	3
FOUR		DC	4
WBLK_SIZE	DC	64

PACKET_SIZE_LOW		DC	0
PACKET_SIZE_HIH		DC	0

PREAMB1			DC	$A5A5	; pramble 16-bit word....2 of which make up first preamble 32bit word
PREAMB2			DC	$5A5A	; preamble 16-bit word....2 of which make up second preamble 32bit word
DATA_WD			DC	$4441

TOTAL_BUFFS		DC	0	; total number of 512 buffers in packet
LEFT_TO_READ		DC	0	; number of words (16 bit) left to read after last 512 buffer
LEFT_TO_WRITE		DC	0	; number of woreds (32 bit) to write to host i.e. half of those left over read
NUM_LEFTOVER_BLOCKS	DC	0	; small block DMA burst transfer



	IF	@SCP("DOWNLOAD","ROM")	; Boot ROM code
VAR_TBL_END	EQU	@LCV(L)-2
	ENDIF

	IF	@SCP("DOWNLOAD","ONCE")	; Download via ONCE debugger
VAR_TBL_END	EQU	@LCV(L)
	ENDIF

VAR_TBL_LENGTH EQU	VAR_TBL_END-VAR_TBL_START


END_ADR	EQU	@LCV(L)		; End address of P: code written to ROM

