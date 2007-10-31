Motorola DSP56300 Assembler  Version 6.3.4   07-10-31  14:32:10  PCI_SCUBA_build.asm  Page 1



1                           COMMENT *
2      
3                          Compile this to build all files together.
4      
5                          Project:     SCUBA 2
6                          Author:      DAVID ATKINSON
7                          Target:      250MHz SDSU PCI card - DSP56301
8                          Controller:  For use with SCUBA 2 Multichannel Electronics
9      
10     
11                         Assembler directives:
12                                 ROM=EEPROM => EEPROM CODE
13                                 ROM=ONCE => ONCE CODE
14     
15                                 *
16                                   PAGE    132                               ; Printronix page width - 132 columns
17                                   OPT     CEX                               ; print DC evaluations
18     
**** 19 [PCI_SCUBA_build.asm 19]:  Build all files together here 
19                                   MSG     ' Build all files together here '
20     
21                                   INCLUDE 'PCI_SCUBA_header.asm'
22                               COMMENT *
23     
24                         PCI code header file.
25     
26                         Project:     SCUBA 2
27                         Author:      DAVID ATKINSON
28                         Target:      250MHz SDSU PCI card - DSP56301
29                         Controller:  For use with SCUBA 2 Multichannel Electronics
30     
31     
32                         Assembler directives:
33                                 ROM=0 => EEPROM CODE
34                                 ROM=1 => ROM CODE
35     
36                                 *
37                                   PAGE    132                               ; Printronix page width - 132 columns
38                                   OPT     CEX                               ; print DC evaluations
39     
**** 40 [PCI_SCUBA_header.asm 19]:  INCLUDE PCI_header.asm HERE  
40                                   MSG     ' INCLUDE PCI_header.asm HERE  '
41     
42                         ; Equates to define the X: memory tables
43        000000           VAR_TBL   EQU     0                                 ; Variables and constants table
44     
45                         APPLICATION
46        000800                     EQU     $800                              ; application memory start location in P memory
47                                                                             ; note applications should start with this address
48                                                                             ; and end with a JMP to PACKET_IN
49                                                                             ; if only want appl to run once
50                                                                             ; penultimate line of code should be
51                                                                             ; to clear bit APPLICATION_LOADED in STATUS
52                                                                             ; otherwise will run continusly until 'STP'
53                                                                             ; command is sent
54     
55        000200           APPL_PARAM EQU    $200                              ; application parameters in x memory start here.
56     
57     
58        000200           HF_FIFO   EQU     512                               ; number of 16 bit words in a half full FIFO
59        000020           SMALL_BLK EQU     32                                ; small block burst size for < 512 pixels
60                         IMAGE_BUFFER
Motorola DSP56300 Assembler  Version 6.3.4   07-10-31  14:32:10  PCI_SCUBA_header.asm  Page 2



61        000000                     EQU     0                                 ; location in y memory of image buffer....
62     
63     
64                         ;Status bits
65     
66                         APPLICATION_LOADED
67        000000                     EQU     0                                 ; set if PCI application to run
68                         SEND_TO_HOST
69        000001                     EQU     1                                 ; set in HST ISR when host ready for packet (stays se
t until after HST reply)
70                         FATAL_ERROR
71        000002                     EQU     2                                 ; PCI message to host error detected by driver....
72        000003           FO_WRD_RCV EQU    3                                 ; set when packet detected in FIFO - stays set till p
acket processed
73     
74                         ;INTA_FLAG              EQU     4   ; used for interupt handshaking with host
75        000005           BYTE_SWAP EQU     5                                 ; flag to show byte swapping enabled
76                         PREAMBLE_ERROR
77        000006                     EQU     6                                 ; set if preamble error detected
78        000007           DATA_DLY  EQU     7                                 ; set in CON ISR if MCE command is 'GO'.  USed to add
 delay to first returned data packet
79     
80                         PACKET_CHOKE
81        000008                     EQU     8                                 ;  don't let any packets from MCE through to host....
82        000009           HST_NFYD  EQU     9                                 ; set after host notified (NFY message) of packet (st
ays set until after HST reply)
83        00000A           SB_SPARE1 EQU     10
84        00000B           SB_SPARE2 EQU     11
85     
86     
87                         APPLICATION_RUNNING
88        00000C                     EQU     12                                ; can be set by an application to indicate its still 
running
89                                                                             ; e.g. set by diagnostic application
90                                                                             ; indicates in a 'self_test_mode'
91                                                                             ; subsequnet GO commands (for MCE) will be handelled 
internally.
92                                                                             ; disable with PCI STOP_APPLICATION command.
93     
94                         INTERNAL_GO
95        00000D                     EQU     13                                ; GO command received while diagnostic application st
ill running
96                                                                             ; tests DMA bursts as bus master
97                         PCIBURST_RESTART
98        00000E                     EQU     14                                ; RESTART BURST ON PCI ERROR
99                         PCIBURST_RESUME
100       00000F                     EQU     15                                ; RESUME BURST ON PCI ERROR
101    
102    
103    
104                        ; HST timeout recovery....
105    
106       000200           MAX_DUMP  EQU     512                               ; if HST timeout.. max number that could be in FIFO i
s 511..
107       001000           DUMP_BUFF EQU     $1000                             ; store in Y memory above normal data buffer: in off-
chip RAM
108    
109    
110    
111                        ; Various addressing control registers
112       FFFFFB           BCR       EQU     $FFFFFB                           ; Bus Control Register
113       FFFFFA           DCR       EQU     $FFFFFA                           ; DRAM Control Register
Motorola DSP56300 Assembler  Version 6.3.4   07-10-31  14:32:10  PCI_SCUBA_header.asm  Page 3



114       FFFFF9           AAR0      EQU     $FFFFF9                           ; Address Attribute Register, channel 0
115       FFFFF8           AAR1      EQU     $FFFFF8                           ; Address Attribute Register, channel 1
116       FFFFF7           AAR2      EQU     $FFFFF7                           ; Address Attribute Register, channel 2
117       FFFFF6           AAR3      EQU     $FFFFF6                           ; Address Attribute Register, channel 3
118       FFFFFD           PCTL      EQU     $FFFFFD                           ; PLL control register
119       FFFFFE           IPRP      EQU     $FFFFFE                           ; Interrupt Priority register - Peripheral
120       FFFFFF           IPRC      EQU     $FFFFFF                           ; Interrupt Priority register - Core
121    
122                        ; PCI control register
123       FFFFCD           DTXS      EQU     $FFFFCD                           ; DSP Slave transmit data FIFO
124       FFFFCC           DTXM      EQU     $FFFFCC                           ; DSP Master transmit data FIFO
125       FFFFCB           DRXR      EQU     $FFFFCB                           ; DSP Receive data FIFO
126       FFFFCA           DPSR      EQU     $FFFFCA                           ; DSP PCI Status Register
127       FFFFC9           DSR       EQU     $FFFFC9                           ; DSP Status Register
128       FFFFC8           DPAR      EQU     $FFFFC8                           ; DSP PCI Address Register
129       FFFFC7           DPMC      EQU     $FFFFC7                           ; DSP PCI Master Control Register
130       FFFFC6           DPCR      EQU     $FFFFC6                           ; DSP PCI Control Register
131       FFFFC5           DCTR      EQU     $FFFFC5                           ; DSP Control Register
132    
133                        ; Port E is the Synchronous Communications Interface (SCI) port
134       FFFF9F           PCRE      EQU     $FFFF9F                           ; Port Control Register
135       FFFF9E           PRRE      EQU     $FFFF9E                           ; Port Direction Register
136       FFFF9D           PDRE      EQU     $FFFF9D                           ; Port Data Register
137    
138                        ; Various PCI register bit equates
139       000001           STRQ      EQU     1                                 ; Slave transmit data request (DSR)
140       000002           SRRQ      EQU     2                                 ; Slave receive data request (DSR)
141       000017           HACT      EQU     23                                ; Host active, low true (DSR)
142       000001           MTRQ      EQU     1                                 ; Set whem master transmitter is not full (DPSR)
143       000004           MARQ      EQU     4                                 ; Master address request (DPSR)
144       000002           MRRQ      EQU     2                                 ; Master Receive Request (DPSR)
145       00000A           TRTY      EQU     10                                ; PCI Target Retry (DPSR)
146       00000F           RDCQ      EQU     15                                ; Remaining Data Count Qualifier (DPSR)
147    
148    
149       000005           APER      EQU     5                                 ; Address parity error
150       000006           DPER      EQU     6                                 ; Data parity error
151       000007           MAB       EQU     7                                 ; Master Abort
152       000008           TAB       EQU     8                                 ; Target Abort
153       000009           TDIS      EQU     9                                 ; Target Disconnect
154       00000B           TO        EQU     11                                ; Timeout
155       00000E           MDT       EQU     14                                ; Master Data Transfer complete
156       000002           SCLK      EQU     2                                 ; SCLK = transmitter special code
157    
158                        ; bits in DPMC
159    
160       000017           FC1       EQU     23
161       000016           FC0       EQU     22
162    
163    
164                        ; DMA register definitions
165       FFFFEF           DSR0      EQU     $FFFFEF                           ; Source address register
166       FFFFEE           DDR0      EQU     $FFFFEE                           ; Destination address register
167       FFFFED           DCO0      EQU     $FFFFED                           ; Counter register
168       FFFFEC           DCR0      EQU     $FFFFEC                           ; Control register
169    
170                        ; The DCTR host flags are written by the DSP and read by PCI host
171       000003           DCTR_HF3  EQU     3                                 ; used as a semiphore for INTA handshaking
172       000004           DCTR_HF4  EQU     4                                 ;
173       000005           DCTR_HF5  EQU     5                                 ;
174       000006           INTA      EQU     6                                 ; Request PCI interrupt
175    
Motorola DSP56300 Assembler  Version 6.3.4   07-10-31  14:32:10  PCI_SCUBA_header.asm  Page 4



176                        ; The DSR host flags are written by the PCI host and read by the DSP
177       000004           DSR_BUF0  EQU     4                                 ; PCI host sets this when copying buffer 0
178       000005           DSR_BUF1  EQU     5                                 ; PCI host sets this when copying buffer 1
179    
180                        ; DPCR bit definitions
181       00000E           CLRT      EQU     14                                ; Clear transmitter
182       000012           MACE      EQU     18                                ; Master access counter enable
183       000015           IAE       EQU     21                                ; Insert Address Enable
184    
185                        ; Addresses of ESSI port
186       FFFFBC           TX00      EQU     $FFFFBC                           ; Transmit Data Register 0
187       FFFFB7           SSISR0    EQU     $FFFFB7                           ; Status Register
188       FFFFB6           CRB0      EQU     $FFFFB6                           ; Control Register B
189       FFFFB5           CRA0      EQU     $FFFFB5                           ; Control Register A
190    
191                        ; SSI Control Register A Bit Flags
192       000006           TDE       EQU     6                                 ; Set when transmitter data register is empty
193    
194                        ; Miscellaneous addresses
195       FFFFFF           RDFIFO    EQU     $FFFFFF                           ; Read the FIFO for incoming fiber optic data
196       FFFF8F           TCSR0     EQU     $FFFF8F                           ; Triper timer control and status register 0
197       FFFF8B           TCSR1     EQU     $FFFF8B                           ; Triper timer control and status register 1
198       FFFF87           TCSR2     EQU     $FFFF87                           ; Triper timer control and status register 2
199    
200                        ;***************************************************************
201                        ; Phase Locked Loop initialization
202       050003           PLL_INIT  EQU     $050003                           ; PLL = 25 MHz x 4 = 100 MHz
203                        ;****************************************************************
204    
205                        ; Port C is Enhanced Synchronous Serial Port 0
206       FFFFBF           PCRC      EQU     $FFFFBF                           ; Port C Control Register
207       FFFFBE           PRRC      EQU     $FFFFBE                           ; Port C Data direction Register
208       FFFFBD           PDRC      EQU     $FFFFBD                           ; Port C GPIO Data Register
209    
210                        ; Port D is Enhanced Synchronous Serial Port 1
211       FFFFAF           PCRD      EQU     $FFFFAF                           ; Port D Control Register
212       FFFFAE           PRRD      EQU     $FFFFAE                           ; Port D Data direction Register
213       FFFFAD           PDRD      EQU     $FFFFAD                           ; Port D GPIO Data Register
214    
215                        ; Bit number definitions of GPIO pins on Port C
216       000002           ROM_FIFO  EQU     2                                 ; Select ROM or FIFO accesses for AA1
217    
218                        ; Bit number definitions of GPIO pins on Port D
219       000000           EF        EQU     0                                 ; FIFO Empty flag, low true
220       000001           HF        EQU     1                                 ; FIFO half full flag, low true
221       000002           RS        EQU     2                                 ; FIFO reset signal, low true
222       000003           FSYNC     EQU     3                                 ; High during image transmission
223       000004           AUX1      EQU     4                                 ; enable/disable byte swapping
224       000005           WRFIFO    EQU     5                                 ; Low true if FIFO is being written to
225    
226    
227                        ; Errors - self test application
228    
229       000000           Y_MEM_ER  EQU     0                                 ; y memory corrupted
230       000001           X_MEM_ER  EQU     1                                 ; x memory corrupted
231       000002           P_MEM_ER  EQU     2                                 ; p memory corrupted
232       000003           FO_EMPTY  EQU     3                                 ; no transmitted data in FIFO
233    
234       000004           FO_OVER   EQU     4                                 ; too much data received
235       000005           FO_UNDER  EQU     5                                 ; not enough data receiv
236       000006           FO_RX_ER  EQU     6                                 ; received data in FIFO incorrect.
237       000007           DEBUG     EQU     7                                 ; debug bit
Motorola DSP56300 Assembler  Version 6.3.4   07-10-31  14:32:10  PCI_SCUBA_header.asm  Page 5



238    
239    
240    
241    
242                                  INCLUDE 'PCI_SCUBA_initialisation.asm'
243                              COMMENT *
244    
245                        This is the code which is executed first after power-up etc.
246                        It sets all the internal registers to their operating values,
247                        sets up the ISR vectors and inialises the hardware etc.
248    
249                        Project:     SCUBA 2
250                        Author:      DAVID ATKINSON
251                        Target:      250MHz SDSU PCI card - DSP56301
252                        Controller:  For use with SCUBA 2 Multichannel Electronics
253    
254                        Assembler directives:
255                                ROM=EEPROM => EEPROM CODE
256                                ROM=ONCE => ONCE CODE
257    
258                                *
259                                  PAGE    132                               ; Printronix page width - 132 columns
260                                  OPT     CEX                               ; print DC evaluations
261    
**** 262 [PCI_SCUBA_initialisation.asm 20]:  INCLUDE PCI_initialisation.asm HERE  
262                                  MSG     ' INCLUDE PCI_initialisation.asm HERE  '
263    
264                        ; The EEPROM boot code expects first to read 3 bytes specifying the number of
265                        ; program words, then 3 bytes specifying the address to start loading the
266                        ; program words and then 3 bytes for each program word to be loaded.
267                        ; The program words will be condensed into 24 bit words and stored in contiguous
268                        ; PRAM memory starting at the specified starting address. Program execution
269                        ; starts from the same address where loading started.
270    
271                        ; Special address for two words for the DSP to bootstrap code from the EEPROM
272                                  IF      @SCP("ROM","ROM")                 ; Boot from ROM on power-on
273       P:000000 P:000000                   ORG     P:0,P:0
274  d    P:000000 P:000000 000810            DC      END_ADR-INIT-2                    ; Number of boot words
275  d    P:000001 P:000001 000000            DC      INIT                              ; Starting address
276       P:000000 P:000002                   ORG     P:0,P:2
277       P:000000 P:000002 0C0030  INIT      JMP     <INIT_PCI                         ; Configure PCI port
278       P:000001 P:000003 000000            NOP
279                                           ENDIF
280    
281    
282                                 ; This allows for the DSP to be loaded from the ONCE port via the WIGGLER
283                                 ; command converter
284                                           IF      @SCP("ROM","ONCE")                ; Download via ONCE debugger
288                                           ENDIF
289    
290                                 ; Vectored interrupt table, addresses at the beginning are reserved
291  d    P:000002 P:000004 000000            DC      0,0,0,0,0,0,0,0,0,0,0,0,0,0       ; $02-$0f Reserved
     d                      000000
     d                      000000
     d                      000000
     d                      000000
     d                      000000
     d                      000000
     d                      000000
     d                      000000
     d                      000000
     d                      000000
Motorola DSP56300 Assembler  Version 6.3.4   07-10-31  14:32:10  PCI_SCUBA_initialisation.asm  Page 6



     d                      000000
     d                      000000
     d                      000000
292  d    P:000010 P:000012 000000            DC      0,0                               ; $10-$13 Reserved
     d                      000000
293    
294                                 ; FIFO HF* flag interrupt vector is here at $12 - this is connected to the
295                                 ; IRQB* interrupt line so its ISR vector must be here
296  d    P:000012 P:000014 000000            DC      0,0                               ; $was ld scatter routine ...HF*
     d                      000000
297    
298                                 ; a software reset button on the font panel of the card is connected to the IRQC*
299                                 ; line which if pressed causes the DSP to jump to an ISR which causes the program
300                                 ; counter to the beginning of the program INIT and sets the stack pointer to TOP.
301       P:000014 P:000016 0BF080            JSR     CLEAN_UP_PCI                      ; $14 - Software reset switch
                            00023B
302    
303  d    P:000016 P:000018 000000            DC      0,0,0,0,0,0,0,0,0,0,0,0           ; Reserved interrupts
     d                      000000
     d                      000000
     d                      000000
     d                      000000
     d                      000000
     d                      000000
     d                      000000
     d                      000000
     d                      000000
     d                      000000
     d                      000000
304  d    P:000022 P:000024 000000            DC      0,0,0,0,0,0,0,0,0,0,0,0,0,0
     d                      000000
     d                      000000
     d                      000000
     d                      000000
     d                      000000
     d                      000000
     d                      000000
     d                      000000
     d                      000000
     d                      000000
     d                      000000
     d                      000000
     d                      000000
305    
306                                 ; Now we're at P:$30, where some unused vector addresses are located
307                                 ; This is ROM only code that is only executed once on power-up when the
308                                 ; ROM code is downloaded. It is skipped over on OnCE downloads.
309    
310                                 ; A few seconds after power up on the Host, it interrogates the PCI bus to find
311                                 ; out what boards are installed and configures this PCI board. The EEPROM booting
312                                 ; procedure ends with program execution  starting at P:$0 where the EEPROM has
313                                 ; inserted a JMP INIT_PCI instruction. This routine sets the PLL paramter and
314                                 ; does a self configuration and software reset of the PCI controller in the DSP.
315                                 ; After configuring the PCI controller the DSP program overwrites the instruction
316                                 ; at P:$0 with a new JMP START to skip over the INIT_PCI routine. The program at
317                                 ; START address begins configuring the DSP and processing commands.
318                                 ; Similarly the ONCE option places a JMP START at P:$0 to skip over the
319                                 ; INIT_PCI routine. If this routine where executed after the host computer had booted
320                                 ; it would cause it to crash since the host computer would overwrite the
321                                 ; configuration space with its own values and doesn't tolerate foreign values.
322    
323                                 ; Initialize the PLL - phase locked loop
Motorola DSP56300 Assembler  Version 6.3.4   07-10-31  14:32:10  PCI_SCUBA_initialisation.asm  Page 7



324                                 INIT_PCI
325       P:000030 P:000032 08F4BD            MOVEP             #PLL_INIT,X:PCTL        ; Initialize PLL
                            050003
326       P:000032 P:000034 000000            NOP
327    
328                                 ; Program the PCI self-configuration registers
329       P:000033 P:000035 240000            MOVE              #0,X0
330       P:000034 P:000036 08F485            MOVEP             #$500000,X:DCTR         ; Set self-configuration mode
                            500000
331       P:000036 P:000038 0604A0            REP     #4
332       P:000037 P:000039 08C408            MOVEP             X0,X:DPAR               ; Dummy writes to configuration space
333       P:000038 P:00003A 08F487            MOVEP             #>$0000,X:DPMC          ; Subsystem ID
                            000000
334       P:00003A P:00003C 08F488            MOVEP             #>$0000,X:DPAR          ; Subsystem Vendor ID
                            000000
335    
336                                 ; PCI Personal reset
337       P:00003C P:00003E 08C405            MOVEP             X0,X:DCTR               ; Personal software reset
338       P:00003D P:00003F 000000            NOP
339       P:00003E P:000040 000000            NOP
340       P:00003F P:000041 0A89B7            JSET    #HACT,X:DSR,*                     ; Test for personal reset completion
                            00003F
341       P:000041 P:000043 07F084            MOVE              P:(*+3),X0              ; Trick to write "JMP <START" to P:0
                            000044
342       P:000043 P:000045 070004            MOVE              X0,P:(0)
343       P:000044 P:000046 0C0100            JMP     <START
344    
345  d    P:000045 P:000047 000000            DC      0,0,0,0,0,0,0,0,0,0,0,0           ; Filler
     d                      000000
     d                      000000
     d                      000000
     d                      000000
     d                      000000
     d                      000000
     d                      000000
     d                      000000
     d                      000000
     d                      000000
     d                      000000
346  d    P:000051 P:000053 000000            DC      0,0,0,0,0,0,0,0,0,0,0,0           ; Filler
     d                      000000
     d                      000000
     d                      000000
     d                      000000
     d                      000000
     d                      000000
     d                      000000
     d                      000000
     d                      000000
     d                      000000
     d                      000000
347  d    P:00005D P:00005F 000000            DC      0,0,0,0,0,0,0,0,0,0,0,0           ; $60-$71 Reserved PCI
     d                      000000
     d                      000000
     d                      000000
     d                      000000
     d                      000000
     d                      000000
     d                      000000
     d                      000000
     d                      000000
     d                      000000
Motorola DSP56300 Assembler  Version 6.3.4   07-10-31  14:32:10  PCI_SCUBA_initialisation.asm  Page 8



     d                      000000
348    
349                                 ;**************************************************************************
350                                 ; Check for program space overwriting of ISR starting at P:$72
351                                           IF      @CVS(N,*)>$71
353                                           ENDIF
354    
355                                 ;       ORG     P:$72,P:$72
356       P:000072 P:000074                   ORG     P:$72,P:$74
357    
358                                 ; This allows for the DSP to be loaded from the ONCE port via the WIGGLER
359                                 ; command converter
360                                           IF      @SCP("ROM","ONCE")                ; Download via ONCE debugger
362                                           ENDIF
363    
364    
365                                 ;**************************************************************************
366    
367                                 ; Three non-maskable fast interrupt service routines for clearing PCI interrupts
368                                 ; The Host will use these to clear the INTA* after it has serviced the interrupt
369                                 ; which had been generated by the PCI board.
370    
371       P:000072 P:000074 0A8506            BCLR    #INTA,X:DCTR                      ; $72/3 - Clear PCI interrupt
372       P:000073 P:000075 000000            NOP
373    
374       P:000074 P:000076 0A8503            BCLR    #DCTR_HF3,X:DCTR                  ; clear interrupt flag
375       P:000075 P:000077 000000            NOP                                       ; needs to be fast addressing <
376    
377       P:000076 P:000078 0A0022            BSET    #FATAL_ERROR,X:<STATUS            ; $76/7 - driver informing us of PCI_MESSAGE
_TO_HOST error
378       P:000077 P:000079 000000            NOP
379    
380                                 ; Interrupt locations for 7 available commands on PCI board
381                                 ; Each JSR takes up 2 locations in the table
382       P:000078 P:00007A 0BF080            JSR     WRITE_MEMORY                      ; $78
                            0003AA
383       P:00007A P:00007C 0BF080            JSR     READ_MEMORY                       ; $7A
                            000247
384       P:00007C P:00007E 0BF080            JSR     START_APPLICATION                 ; $7C
                            00036A
385       P:00007E P:000080 0BF080            JSR     STOP_APPLICATION                  ; $7E
                            000382
386                                 ; software reset is the same as cleaning up the PCI - use same routine
387                                 ; when HOST does a RESET then this routine is run
388       P:000080 P:000082 0BF080            JSR     SOFTWARE_RESET                    ; $80
                            000332
389       P:000082 P:000084 0BF080            JSR     SEND_PACKET_TO_CONTROLLER         ; $82
                            0002C4
390       P:000084 P:000086 0BF080            JSR     SEND_PACKET_TO_HOST               ; $84
                            000312
391       P:000086 P:000088 0BF080            JSR     RESET_CONTROLLER                  ; $86
                            000286
392    
393    
394                                 ; ***********************************************************************
395                                 ; For now have boot code starting from P:$100
396                                 ; just to make debugging tidier etc.
397    
398       P:000100 P:000102                   ORG     P:$100,P:$102
399    
400                                 ; This allows for the DSP to be loaded from the ONCE port via the WIGGLER
401                                 ; command converter
Motorola DSP56300 Assembler  Version 6.3.4   07-10-31  14:32:10  PCI_SCUBA_initialisation.asm  Page 9



402                                           IF      @SCP("ROM","ONCE")                ; Download via ONCE debugger
404                                           ENDIF
405                                 ; ***********************************************************************
406    
407    
408    
409                                 ; ******************************************************************
410                                 ;
411                                 ;       AA0 = RDFIFO* of incoming fiber optic data
412                                 ;       AA1 = EEPROM access
413                                 ;       AA2 = DRAM access
414                                 ;       AA3 = output to parallel data connector, for a video pixel clock
415                                 ;       $FFxxxx = Write to fiber optic transmitter
416                                 ;
417                                 ; ******************************************************************
418    
419    
420       P:000100 P:000102 08F487  START     MOVEP             #>$000001,X:DPMC
                            000001
421       P:000102 P:000104 0A8534            BSET    #20,X:DCTR                        ; HI32 mode = 1 => PCI
422       P:000103 P:000105 0A8515            BCLR    #21,X:DCTR
423       P:000104 P:000106 0A8516            BCLR    #22,X:DCTR
424       P:000105 P:000107 000000            NOP
425       P:000106 P:000108 0A8632            BSET    #MACE,X:DPCR                      ; Master access counter enable
426       P:000107 P:000109 000000            NOP
427       P:000108 P:00010A 000000            NOP                                       ; End of PCI programming
428    
429    
430                                 ; Set operation mode register OMR to normal expanded
431       P:000109 P:00010B 0500BA            MOVEC             #$0000,OMR              ; Operating Mode Register = Normal Expanded
432       P:00010A P:00010C 0500BB            MOVEC             #0,SP                   ; Reset the Stack Pointer SP
433    
434                                 ; Program the serial port ESSI0 = Port C for serial transmission to
435                                 ;   the timing board
436       P:00010B P:00010D 07F43F            MOVEP             #>0,X:PCRC              ; Software reset of ESSI0
                            000000
437                                 ;**********************************************************************
438       P:00010D P:00010F 07F435            MOVEP             #$00080B,X:CRA0         ; Divide 100.0 MHz by 24 to get 4.17 MHz
                            00080B
439                                                                                     ; DC0-CD4 = 0 for non-network operation
440                                                                                     ; WL0-WL2 = ALC = 0 for 2-bit data words
441                                                                                     ; SSC1 = 0 for SC1 not used
442                                 ;************************************************************************
443       P:00010F P:000111 07F436            MOVEP             #$010120,X:CRB0         ; SCKD = 1 for internally generated clock
                            010120
444                                                                                     ; SHFD = 0 for MSB shifted first
445                                                                                     ; CKP = 0 for rising clock edge transitions
446                                                                                     ; TE0 = 1 to enable transmitter #0
447                                                                                     ; MOD = 0 for normal, non-networked mode
448                                                                                     ; FSL1 = 1, FSL0 = 0 for on-demand transmit
449       P:000111 P:000113 07F43F            MOVEP             #%101000,X:PCRC         ; Control Register (0 for GPIO, 1 for ESSI)
                            000028
450                                                                                     ; Set SCK0 = P3, STD0 = P5 to ESSI0
451                                 ;********************************************************************************
452       P:000113 P:000115 07F43E            MOVEP             #%111100,X:PRRC         ; Data Direction Register (0 for In, 1 for O
ut)
                            00003C
453       P:000115 P:000117 07F43D            MOVEP             #%000000,X:PDRC         ; Data Register - AUX3 = i/p, AUX1 not used
                            000000
454                                 ;***********************************************************************************
455                                 ; 250MHz
456                                 ; Conversion from software bits to schematic labels for Port C and D
Motorola DSP56300 Assembler  Version 6.3.4   07-10-31  14:32:10  PCI_SCUBA_initialisation.asm  Page 10



457                                 ;       PC0 = SC00 = AUX3               PD0 = SC10 = EF*
458                                 ;       PC1 = SC01 = A/B* = input       PD1 = SC11 = HF*
459                                 ;       PC2 = SC02 = No connect         PD2 = SC12 = RS*
460                                 ;       PC3 = SCK0 = No connect         PD3 = SCK1 = NWRFIFO*
461                                 ;       PC4 = SRD0 = AUX1               PD4 = SRD1 = No connect (** in 50Mhz this was MODE selec
t for 16 or 32 bit FO)
462                                 ;       PC5 = STD0 = No connect         PD5 = STD1 = WRFIFO*
463                                 ; ***********************************************************************************
464    
465    
466                                 ; ****************************************************************************
467                                 ; Program the serial port ESSI1 = Port D for general purpose I/O (GPIO)
468    
469       P:000117 P:000119 07F42F            MOVEP             #%000000,X:PCRD         ; Control Register (0 for GPIO, 1 for ESSI)
                            000000
470       P:000119 P:00011B 07F42E            MOVEP             #%011100,X:PRRD         ; Data Direction Register (0 for In, 1 for O
ut)
                            00001C
471       P:00011B P:00011D 07F42D            MOVEP             #%010000,X:PDRD         ; Data Register - Pulse RS* low
                            000010
472       P:00011D P:00011F 060AA0            REP     #10
473       P:00011E P:000120 000000            NOP
474       P:00011F P:000121 07F42D            MOVEP             #%010100,X:PDRD         ; Data Register - Pulse RS* high
                            000014
475                                                                                     ; was %011100
476    
477    
478                                 ; Program the SCI port to benign values:
479                                 ;       PE0 = RXD
480                                 ;       PE1 = TXD  - use for debug (on d-type) to show when GO sent
481                                 ;       PE2 = SCLK
482    
483       P:000121 P:000123 07F41F            MOVEP             #%000,X:PCRE            ; Port Control Register = GPIO
                            000000
484       P:000123 P:000125 07F41E            MOVEP             #%111,X:PRRE            ; Port Direction Register (0 = Input)
                            000007
485       P:000125 P:000127 07F41D            MOVEP             #%001,X:PDRE            ; Port Data Register
                            000001
486    
487    
488                                 ; Program the triple timer to assert TCI0 as an GPIO output = 1
489       P:000127 P:000129 07F40F            MOVEP             #$2800,X:TCSR0
                            002800
490       P:000129 P:00012B 07F40B            MOVEP             #$2800,X:TCSR1
                            002800
491       P:00012B P:00012D 07F407            MOVEP             #$2800,X:TCSR2
                            002800
492    
493    
494                                 ; Program the address attribute pins AA0 to AA2. AA3 is not yet implemented.
495       P:00012D P:00012F 08F4B9            MOVEP             #$FFFC21,X:AAR0         ; Y = $FFF000 to $FFFFFF asserts Y:RDFIFO*
                            FFFC21
496       P:00012F P:000131 08F4B8            MOVEP             #$008929,X:AAR1         ; P = $008000 to $00FFFF asserts AA1 low tru
e
                            008929
497       P:000131 P:000133 08F4B7            MOVEP             #$000122,X:AAR2         ; Y = $000800 to $7FFFFF accesses SRAM
                            000122
498    
499    
500                                 ; Program the DRAM memory access and addressing
501       P:000133 P:000135 08F4BB            MOVEP             #$020022,X:BCR          ; Bus Control Register
                            020022
Motorola DSP56300 Assembler  Version 6.3.4   07-10-31  14:32:10  PCI_SCUBA_initialisation.asm  Page 11



502       P:000135 P:000137 08F4BA            MOVEP             #$893A05,X:DCR          ; DRAM Control Register
                            893A05
503    
504    
505                                 ; Clear all PCI error conditions
506       P:000137 P:000139 084E0A            MOVEP             X:DPSR,A
507       P:000138 P:00013A 0140C2            OR      #$1FE,A
                            0001FE
508       P:00013A P:00013C 000000            NOP
509       P:00013B P:00013D 08CE0A            MOVEP             A,X:DPSR
510    
511                                 ;--------------------------------------------------------------------
512                                 ; Enable one interrupt only: software reset switch
513       P:00013C P:00013E 08F4BF            MOVEP             #$0001C0,X:IPRC         ; IRQB priority = 1 (FIFO half full HF*)
                            0001C0
514                                                                                     ; IRQC priority = 2 (reset switch)
515       P:00013E P:000140 05F439            MOVE              #$200,SR                ; Mask set up for reset switch only
                            000200
516    
517    
518                                 ;--------------------------------------------------------------------------
519                                 ; Initialize the fiber optic serial transmitter to zero
520       P:000140 P:000142 01B786            JCLR    #TDE,X:SSISR0,*
                            000140
521       P:000142 P:000144 07F43C            MOVEP             #$000000,X:TX00
                            000000
522    
523                                 ;--------------------------------------------------------------------
524    
525                                 ; clear DTXM - PCI master transmitter
526       P:000144 P:000146 0A862E            BSET    #CLRT,X:DPCR                      ; Clear the master transmitter DTXM
527       P:000145 P:000147 0A86AE            JSET    #CLRT,X:DPCR,*                    ; Wait for the clearing to be complete
                            000145
528    
529                                 ;----------------------------------------------------------------------
530                                 ; clear DRXR - PCI receiver
531    
532       P:000147 P:000149 0A8982  CLR0      JCLR    #SRRQ,X:DSR,CLR1                  ; Wait for the receiver to be empty
                            00014C
533       P:000149 P:00014B 08440B            MOVEP             X:DRXR,X0               ; Read receiver to empty it
534       P:00014A P:00014C 000000            NOP
535       P:00014B P:00014D 0C0147            JMP     <CLR0
536                                 CLR1
537    
538                                 ;-----------------------------------------------------------------------------
539                                 ; copy parameter table from P memory into X memory
540    
541                                 ; but not word_count and num_dumped - don't want these reset by fatal error....
542                                 ; they will be reset by new packet or pci_reset ISR
543    
544    
545       P:00014C P:00014E 46F000            MOVE              X:WORD_COUNT,Y0         ; store packet word count
                            000006
546       P:00014E P:000150 47F000            MOVE              X:NUM_DUMPED,Y1         ; store number dumped (after HST TO)
                            000007
547       P:000150 P:000152 45F000            MOVE              X:FRAME_COUNT,X1        ; store frame count
                            000001
548    
549                                 ; Move the table of constants from P: space to X: space
550       P:000152 P:000154 61F400            MOVE              #VAR_TBL_START,R1       ; Start of parameter table in P
                            000593
551       P:000154 P:000156 300000            MOVE              #VAR_TBL,R0             ; start of parameter table in X
Motorola DSP56300 Assembler  Version 6.3.4   07-10-31  14:32:10  PCI_SCUBA_initialisation.asm  Page 12



552       P:000155 P:000157 064F80            DO      #VAR_TBL_LENGTH,X_WRITE
                            000158
553       P:000157 P:000159 07D984            MOVE              P:(R1)+,X0
554       P:000158 P:00015A 445800            MOVE              X0,X:(R0)+              ; Write the constants to X:
555                                 X_WRITE
556    
557    
558       P:000159 P:00015B 467000            MOVE              Y0,X:WORD_COUNT         ; restore packet word count
                            000006
559       P:00015B P:00015D 477000            MOVE              Y1,X:NUM_DUMPED         ; restore number dumped (after HST TO)
                            000007
560       P:00015D P:00015F 457000            MOVE              X1,X:FRAME_COUNT        ; restore frame count
                            000001
561    
562                                 ;-------------------------------------------------------------------------------
563                                 ; initialise some bits in STATUS
564    
565       P:00015F P:000161 0A0000            BCLR    #APPLICATION_LOADED,X:<STATUS     ; clear application loaded flag
566       P:000160 P:000162 0A000C            BCLR    #APPLICATION_RUNNING,X:<STATUS    ; clear appliaction running flag
567                                                                                     ; (e.g. not running diagnostic application
568                                                                                     ;      in self_test_mode)
569    
570       P:000161 P:000163 0A0002            BCLR    #FATAL_ERROR,X:<STATUS            ; initialise fatal error flag.
571       P:000162 P:000164 0A0028            BSET    #PACKET_CHOKE,X:<STATUS           ; enable MCE packet choke
572                                                                                     ; HOST not informed of anything from MCE unt
il
573                                                                                     ; comms are opened by host with first CON co
mmand
574    
575       P:000163 P:000165 0A0006            BCLR    #PREAMBLE_ERROR,X:<STATUS         ; flag to let host know premable error
576    
577                                 ;------------------------------------------------------------------------------
578                                 ; disable FIFO HF* intererupt...not used anymore.
579    
580       P:000164 P:000166 08F4BF            MOVEP             #$0001C0,X:IPRC         ; Disable FIFO HF* interrupt
                            0001C0
581       P:000166 P:000168 05F439            MOVEC             #$200,SR                ; Mask level 1 interrupts
                            000200
582    
583                                 ;----------------------------------------------------------------------------
584                                 ; Disable Byte swapin - enabled after first command to MCE.
585                                 ; i.e after first 'CON'
586    
587       P:000168 P:00016A 0A0005            BCLR    #BYTE_SWAP,X:<STATUS              ; flag to let host know byte swapping off
588       P:000169 P:00016B 013D04            BCLR    #AUX1,X:PDRC                      ; enable disable
589    
590                                 ;----------------------------------------------------------------------------
591                                 ; Initialize PCI controller again, after booting, to make sure it sticks
592       P:00016A P:00016C 0A8514            BCLR    #20,X:DCTR                        ; Terminate and reset mode
593       P:00016B P:00016D 000000            NOP
594       P:00016C P:00016E 0A89B7            JSET    #HACT,X:DSR,*                     ; Test for personal reset completion
                            00016C
595       P:00016E P:000170 000000            NOP
596       P:00016F P:000171 0A8534            BSET    #20,X:DCTR                        ; HI32 mode = 1 => PCI
597       P:000170 P:000172 000000            NOP
598       P:000171 P:000173 0A8AAC            JSET    #12,X:DPSR,*                      ; Host data transfer not in progress
                            000171
599                                 ;-----------------------------------------------------------------------------
600                                 ; Here endth the initialisation code run after power up.
601                                 ; ----------------------------------------------------------------------------
602    
603    
Motorola DSP56300 Assembler  Version 6.3.4   07-10-31  14:32:10  PCI_SCUBA_initialisation.asm  Page 13



604    
605    
606                                           INCLUDE 'PCI_SCUBA_main.asm'
607                                  COMMENT *
608    
609                                 This is the main section of the pci card code.
610    
611                                 Project:     SCUBA 2
612                                 Author:      DAVID ATKINSON
613                                 Target:      250MHz SDSU PCI card - DSP56301
614                                 Controller:  For use with SCUBA 2 Multichannel Electronics
615    
616                                 Version:     Release Version A (2.0)
617    
618    
619                                 Assembler directives:
620                                         ROM=EEPROM => EEPROM CODE
621                                         ROM=ONCE => ONCE CODE
622    
623                                         *
624                                           PAGE    132                               ; Printronix page width - 132 columns
625                                           OPT     CEX                               ; print DC evaluations
626    
**** 627 [PCI_SCUBA_main.asm 21]:  INCLUDE PCI_main.asm HERE  
627                                           MSG     ' INCLUDE PCI_main.asm HERE  '
628    
629                                 ; --------------------------------------------------------------------------
630                                 ; --------------------- MAIN PACKET HANDLING CODE --------------------------
631                                 ; --------------------------------------------------------------------------
632    
633                                 ; initialse buffer pointers
634                                 PACKET_IN
635    
636                                 ; R1 used as pointer for data written to y:memory            FO --> (Y)
637                                 ; R2 used as pointer for date in y mem to be writen to host  (Y) --> HOST
638    
639       P:000173 P:000175 310000            MOVE              #<IMAGE_BUFFER,R1       ; pointer for Fibre ---> Y mem
640       P:000174 P:000176 320000            MOVE              #<IMAGE_BUFFER,R2       ; pointer for Y mem ---> PCI BUS
641    
642                                 ; initialise some bits in status..
643       P:000175 P:000177 0A0001            BCLR    #SEND_TO_HOST,X:<STATUS           ; clear send to host flag
644       P:000176 P:000178 0A0009            BCLR    #HST_NFYD,X:<STATUS               ; clear flag to indicate host has been notif
ied.
645       P:000177 P:000179 0A0003            BCLR    #FO_WRD_RCV,X:<STATUS             ; clear Fiber Optic flag
646    
647                                 ; check some bits in status....
648       P:000178 P:00017A 0A00A2            JSET    #FATAL_ERROR,X:<STATUS,START      ; fatal error?  Go to initialisation.
                            000100
649       P:00017A P:00017C 0A00A0            JSET    #APPLICATION_LOADED,X:<STATUS,APPLICATION ; application loaded?  Execute in ap
pl space.
                            000800
650       P:00017C P:00017E 0A00AD            JSET    #INTERNAL_GO,X:<STATUS,APPLICATION ; internal GO to process?  PCI bus master w
rite test.
                            000800
651    
652       P:00017E P:000180 0D0419  CHK_FIFO  JSR     <GET_FO_WRD                       ; see if there's a 16-bit word in Fibre FIFO
 from MCE
653    
654    
655       P:00017F P:000181 0A00A3            JSET    #FO_WRD_RCV,X:<STATUS,CHECK_WD    ; there is a word - check if it's preamble
                            000182
656       P:000181 P:000183 0C0173            JMP     <PACKET_IN                        ; else go back and repeat
Motorola DSP56300 Assembler  Version 6.3.4   07-10-31  14:32:10  PCI_SCUBA_main.asm  Page 14



657    
658                                 ; check that we preamble sequence
659    
660       P:000182 P:000184 0A00A8  CHECK_WD  JSET    #PACKET_CHOKE,X:<STATUS,PACKET_IN ; IF MCE Packet choke on - just keep clearin
g FIFO.
                            000173
661       P:000184 P:000186 441D00            MOVE              X0,X:<HEAD_W1_0         ;store received word
662       P:000185 P:000187 56F000            MOVE              X:PREAMB1,A
                            000035
663       P:000187 P:000189 200045            CMP     X0,A                              ; check it is correct
664       P:000188 P:00018A 0E219C            JNE     <PRE_ERROR                        ; if not go to start
665    
666    
667       P:000189 P:00018B 0D0421            JSR     <WT_FIFO                          ; wait for next preamble 16-bit word
668       P:00018A P:00018C 441C00            MOVE              X0,X:<HEAD_W1_1         ;store received word
669       P:00018B P:00018D 56F000            MOVE              X:PREAMB1,A
                            000035
670       P:00018D P:00018F 200045            CMP     X0,A                              ; check it is correct
671       P:00018E P:000190 0E219C            JNE     <PRE_ERROR                        ; if not go to start
672    
673    
674       P:00018F P:000191 0D0421            JSR     <WT_FIFO                          ; wait for next preamble 16-bit word
675       P:000190 P:000192 441F00            MOVE              X0,X:<HEAD_W2_0         ;store received word
676       P:000191 P:000193 56F000            MOVE              X:PREAMB2,A
                            000036
677       P:000193 P:000195 200045            CMP     X0,A                              ; check it is correct
678       P:000194 P:000196 0E219C            JNE     <PRE_ERROR                        ; if not go to start
679    
680       P:000195 P:000197 0D0421            JSR     <WT_FIFO                          ; wait for next preamble 16-bit word
681       P:000196 P:000198 441E00            MOVE              X0,X:<HEAD_W2_1         ;store received word
682       P:000197 P:000199 56F000            MOVE              X:PREAMB2,A
                            000036
683       P:000199 P:00019B 200045            CMP     X0,A                              ; check it is correct
684       P:00019A P:00019C 0E219C            JNE     <PRE_ERROR                        ; if not go to start
685       P:00019B P:00019D 0C01A8            JMP     <PACKET_INFO                      ; get packet info
686    
687    
688                                 PRE_ERROR
689       P:00019C P:00019E 0A0026            BSET    #PREAMBLE_ERROR,X:<STATUS         ; indicate a preamble error
690       P:00019D P:00019F 440200            MOVE              X0,X:<PRE_CORRUPT       ; store corrupted word
691    
692                                 ; preampble error so clear out both FIFOs using reset line
693                                 ; - protects against an odd number of bytes having been sent
694                                 ; (byte swapping on - so odd byte being would end up in
695                                 ; the FIFO without the empty flag)
696    
697       P:00019E P:0001A0 07F42D            MOVEP             #%011000,X:PDRD         ; clear FIFO RESET* for 2 ms
                            000018
698       P:0001A0 P:0001A2 44F400            MOVE              #200000,X0
                            030D40
699       P:0001A2 P:0001A4 06C400            DO      X0,*+3
                            0001A4
700       P:0001A4 P:0001A6 000000            NOP
701       P:0001A5 P:0001A7 07F42D            MOVEP             #%011100,X:PDRD
                            00001C
702    
703       P:0001A7 P:0001A9 0C0173            JMP     <PACKET_IN                        ; wait for next packet
704    
705    
706                                 PACKET_INFO                                         ; packet preamble valid
707    
708                                 ; Packet preamble is valid so....
Motorola DSP56300 Assembler  Version 6.3.4   07-10-31  14:32:10  PCI_SCUBA_main.asm  Page 15



709                                 ; now get next two 32bit words.  i.e. $20205250 $00000004, or $20204441 $xxxxxxxx
710                                 ; note that these are received little endian (and byte swapped)
711                                 ; i.e. for RP receive 50 52 20 20  04 00 00 00
712                                 ; but byte swapped on arrival
713                                 ; 5250
714                                 ; 2020
715                                 ; 0004
716                                 ; 0000
717    
718       P:0001A8 P:0001AA 0D0421            JSR     <WT_FIFO
719       P:0001A9 P:0001AB 442100            MOVE              X0,X:<HEAD_W3_0         ; RP or DA
720       P:0001AA P:0001AC 0D0421            JSR     <WT_FIFO
721       P:0001AB P:0001AD 442000            MOVE              X0,X:<HEAD_W3_1         ; $2020
722    
723       P:0001AC P:0001AE 0D0421            JSR     <WT_FIFO
724       P:0001AD P:0001AF 442300            MOVE              X0,X:<HEAD_W4_0         ; packet size lo
725       P:0001AE P:0001B0 0D0421            JSR     <WT_FIFO
726       P:0001AF P:0001B1 442200            MOVE              X0,X:<HEAD_W4_1         ; packet size hi
727    
728       P:0001B0 P:0001B2 44A100            MOVE              X:<HEAD_W3_0,X0         ; get data header word 3 (low 2 bytes)
729       P:0001B1 P:0001B3 56B800            MOVE              X:<REPLY_WD,A           ; $5250
730       P:0001B2 P:0001B4 200045            CMP     X0,A                              ; is it a reply packet?
731       P:0001B3 P:0001B5 0AF0AA            JEQ     MCE_PACKET                        ; yes - go process it.
                            0001C7
732    
733       P:0001B5 P:0001B7 56B700            MOVE              X:<DATA_WD,A            ; $4441
734       P:0001B6 P:0001B8 200045            CMP     X0,A                              ; is it a data packet?
735       P:0001B7 P:0001B9 0E2173            JNE     <PACKET_IN                        ; no?  Not a valid packet type.  Go back to 
start and resync to next preamble.
736    
737    
738                                 ; It's a data packet.
739                                 ; check if it's the first packet after the GO command has been issued.
740    
741       P:0001B8 P:0001BA 0A0087            JCLR    #DATA_DLY,X:STATUS,INC_FRAME_COUNT ; do we need to add a delay since first fra
me?
                            0001C2
742    
743                                 ; yes first frame after GO reply packet so add a delay.
744                                 PACKET_DELAY
745       P:0001BA P:0001BC 44F000            MOVE              X:DATA_DLY_VAL,X0
                            00003E
746       P:0001BC P:0001BE 06C400            DO      X0,*+3                            ; 10ns x DATA_DLY_VAL
                            0001BE
747       P:0001BE P:0001C0 000000            NOP
748       P:0001BF P:0001C1 000000            NOP
749       P:0001C0 P:0001C2 0A7007            BCLR    #DATA_DLY,X:STATUS                ; clear so delay isn't added next time.
                            000000
750    
751    
752                                 INC_FRAME_COUNT                                     ; increment frame count
753       P:0001C2 P:0001C4 200013            CLR     A
754       P:0001C3 P:0001C5 508100            MOVE              X:<FRAME_COUNT,A0
755       P:0001C4 P:0001C6 000008            INC     A
756       P:0001C5 P:0001C7 000000            NOP
757       P:0001C6 P:0001C8 500100            MOVE              A0,X:<FRAME_COUNT
758    
759                                 ; -------------------------------------------------------------------------------------------
760                                 ; ----------------------------------- IT'S A PAKCET FROM MCE --------------------------------
761                                 ; -------------------------------------------------------------------------------------------
762                                 ; prepare notify to inform host that a packet has arrived.
763    
Motorola DSP56300 Assembler  Version 6.3.4   07-10-31  14:32:10  PCI_SCUBA_main.asm  Page 16



764                                 MCE_PACKET
765       P:0001C7 P:0001C9 44F400            MOVE              #'NFY',X0               ; initialise communication to host as a noti
fy
                            4E4659
766       P:0001C9 P:0001CB 440C00            MOVE              X0,X:<DTXS_WD1          ; 1st word transmitted to host in notify mes
sage
767    
768       P:0001CA P:0001CC 44A100            MOVE              X:<HEAD_W3_0,X0         ;RP or DA - top two bytes of word 3 ($2020) 
not passed to driver.
769       P:0001CB P:0001CD 440D00            MOVE              X0,X:<DTXS_WD2          ;2nd word transmitted to host in notify mess
age
770    
771       P:0001CC P:0001CE 44A300            MOVE              X:<HEAD_W4_0,X0         ; size of packet LSB 16bits (# 32bit words)
772       P:0001CD P:0001CF 440E00            MOVE              X0,X:<DTXS_WD3          ; 3rd word transmitted to host in notify mes
sage
773    
774       P:0001CE P:0001D0 44A200            MOVE              X:<HEAD_W4_1,X0         ; size of packet MSB 16bits (# of 32bit word
s)
775       P:0001CF P:0001D1 440F00            MOVE              X0,X:<DTXS_WD4          ; 4th word transmitted to host in notify mes
sasge
776    
777       P:0001D0 P:0001D2 200013            CLR     A                                 ;
778       P:0001D1 P:0001D3 340000            MOVE              #0,R4                   ; initialise word count
779       P:0001D2 P:0001D4 560600            MOVE              A,X:<WORD_COUNT         ; initialise word count store (num of words 
written over bus/packet)
780       P:0001D3 P:0001D5 560700            MOVE              A,X:<NUM_DUMPED         ; initialise number dumped from FIFO (after 
HST TO)
781    
782    
783                                 ; ----------------------------------------------------------------------------------------------
------------
784                                 ; Determine how to break up packet to write to host.
785                                 ; Determine number of Half Full FIFOs will be read in and number of left over words in FIFO.
786                                 ; Determine the number of maximum PCI write bursts (256 bytes) are required
787                                 ; to write the packet to host, and the size of the left over burst.
788    
789                                 ; Note that this SR uses accumulator B
790                                 ; Therefore execute before we get the bus address from host (which is stored in B)
791                                 ; i.e before we issue notify message ('NFY')
792    
793       P:0001D4 P:0001D6 0D03E7            JSR     <CALC_NO_BUFFS                    ; subroutine which calculates the number of 
512 (16bit)
794    
795                                 ; ----------------------------------------------------------------------------------------------
---
796    
797    
798                                 ; notify the host that there is a packet.....
799    
800       P:0001D5 P:0001D7 0D048B            JSR     <PCI_MESSAGE_TO_HOST              ; notify host of packet
801       P:0001D6 P:0001D8 0A0029            BSET    #HST_NFYD,X:<STATUS               ; flag to indicate host has been notified.
802    
803                                 ; initialise read/write buffers
804                                 ; AND IMMEDIATELY BEGIN TO BUFFER FIBRE DATA TO Y MEMORY.
805    
806       P:0001D7 P:0001D9 310000            MOVE              #<IMAGE_BUFFER,R1       ; FO ---> Y mem
807       P:0001D8 P:0001DA 320000            MOVE              #<IMAGE_BUFFER,R2       ; Y mem ----->  PCI BUS
808    
809    
810                                 ; ----------------------------------------------------------------------------------------------
-----------
811                                 ; Write TOTAL_BUFFS * 512 buffers to host
Motorola DSP56300 Assembler  Version 6.3.4   07-10-31  14:32:10  PCI_SCUBA_main.asm  Page 17



812                                 ; ----------------------------------------------------------------------------------------------
------
813       P:0001D9 P:0001DB 063A00            DO      X:<TOTAL_BUFFS,READ_BUFFS_END
                            0001E6
814    
815       P:0001DB P:0001DD 0A00A2  WAIT_BUFF JSET    #FATAL_ERROR,X:<STATUS,DUMP_FIFO  ; if fatal error then dump fifo and reset (i
.e. if HST timeout)
                            000227
816       P:0001DD P:0001DF 01ADA1            JSET    #HF,X:PDRD,WAIT_BUFF              ; Wait for FIFO to be half full + 1
                            0001DB
817       P:0001DF P:0001E1 000000            NOP
818       P:0001E0 P:0001E2 000000            NOP
819       P:0001E1 P:0001E3 01ADA1            JSET    #HF,X:PDRD,WAIT_BUFF              ; Protection against metastability
                            0001DB
820    
821                                 ; Copy the image block as 512 x 16bit words to DSP Y: Memory using R1 as pointer
822       P:0001E3 P:0001E5 060082            DO      #512,L_BUFFER
                            0001E5
823       P:0001E5 P:0001E7 0959FF            MOVEP             Y:RDFIFO,Y:(R1)+
824                                 L_BUFFER
825       P:0001E6 P:0001E8 000000            NOP
826                                 READ_BUFFS_END                                      ; all buffers have been read (-->Y)
827    
828                                 ; ----------------------------------------------------------------------------------------------
-----------
829                                 ; Read NUM_LEFTOVER_BLOCKS * 128 blocks to host
830                                 ; ----------------------------------------------------------------------------------------------
------
831                                 ; less than 512 Y Memory locations then read in N x 128 (x16bit words)
832    
833       P:0001E7 P:0001E9 063D00            DO      X:<NUM_LEFTOVER_BLOCKS,READ_BLOCKS
                            0001F4
834    
835       P:0001E9 P:0001EB 068080            DO      #128,S_BUFFER
                            0001F3
836       P:0001EB P:0001ED 0A00A2  WAIT_1    JSET    #FATAL_ERROR,X:<STATUS,DUMP_FIFO  ; check for fatal error (i.e. after HST time
out)
                            000227
837       P:0001ED P:0001EF 01AD80            JCLR    #EF,X:PDRD,WAIT_1                 ; Wait for the pixel datum to be there
                            0001EB
838       P:0001EF P:0001F1 000000            NOP                                       ; Settling time
839       P:0001F0 P:0001F2 000000            NOP
840       P:0001F1 P:0001F3 01AD80            JCLR    #EF,X:PDRD,WAIT_1                 ; Protection against metastability
                            0001EB
841       P:0001F3 P:0001F5 0959FF            MOVEP             Y:RDFIFO,Y:(R1)+        ; save fibre word
842                                 S_BUFFER
843       P:0001F4 P:0001F6 000000            NOP
844                                 READ_BLOCKS
845    
846                                 ; ----------------------------------------------------------------------------------------------
-------
847                                 ; Left over data to read from FIFO
848                                 ; ----------------------------------------------------------------------------------------------
------
849    
850                                 LEFT_OVERS
851       P:0001F5 P:0001F7 063B00            DO      X:<LEFT_TO_READ,LEFT_OVERS_READ   ; read in remaining words of data packet
                            0001FF
852    
853    
854       P:0001F7 P:0001F9 0A00A2  WAIT_2    JSET    #FATAL_ERROR,X:<STATUS,START      ; check for fatal error (i.e. after HST time
out)
Motorola DSP56300 Assembler  Version 6.3.4   07-10-31  14:32:10  PCI_SCUBA_main.asm  Page 18



                            000100
855       P:0001F9 P:0001FB 01AD80            JCLR    #EF,X:PDRD,WAIT_2                 ; Wait till something in FIFO flagged
                            0001F7
856       P:0001FB P:0001FD 000000            NOP
857       P:0001FC P:0001FE 000000            NOP
858       P:0001FD P:0001FF 01AD80            JCLR    #EF,X:PDRD,WAIT_2                 ; protect against metastability.....
                            0001F7
859       P:0001FF P:000201 0959FF            MOVEP             Y:RDFIFO,Y:(R1)+        ; save fibre word
860                                 LEFT_OVERS_READ
861    
862                                 ;---------------------------------------------------------------------------------------
863                                 ; ENTIRE PACKET NOW IN Y MEMORY
864                                 ;----------------------------------------------------------------------------------------
865                                 ; CHECK THAT HST COMMAND WAS ISSUED DURING DATA COLLECTION...
866    
867    
868       P:000200 P:000202 0A00A2  WT_HOST   JSET    #FATAL_ERROR,X:<STATUS,START      ; if fatal error - run initialisation code..
.
                            000100
869       P:000202 P:000204 0A0081            JCLR    #SEND_TO_HOST,X:<STATUS,WT_HOST   ; wait for host to reply - which it does wit
h 'send_packet_to_host' ISR
                            000200
870    
871                                 ; we now have 32 bit address in accumulator B
872                                 ; from send-packet_to_host (HST COMMAND) which should of been issued during data collection.
873    
874                                 ; Write all data to host.
875    
876                                 ; ----------------------------------------------------------------------------------------------
-----------
877                                 ; Write N * maximum bursts over bus.  Each burst writes from 128 y memory locations
878                                 ; R2 points to data in Y memory to be written to host
879                                 ; host address is in B - got by SEND_PACKET_TO_HOST command
880                                 ; ----------------------------------------------------------------------------------------------
------
881    
882       P:000204 P:000206 063900            DO      X:<NMAX_BURSTS,WRITE_BUFFS_END    ; write N x 256 byte bursts.
                            00020B
883       P:000206 P:000208 44F400            MOVE              #>128,X0
                            000080
884       P:000208 P:00020A 447000            MOVE              X0,X:NBURST_YMEM        ; # of locations in y memory (256bytes)
                            000040
885       P:00020A P:00020C 0D04F4            JSR     <WRITE_PCI_BURST
886       P:00020B P:00020D 000000            NOP
887                                 WRITE_BUFFS_END                                     ; all buffers have been writen to host
888       P:00020C P:00020E 0A00A2            JSET    #FATAL_ERROR,X:<STATUS,START
                            000100
889    
890                                 ; ----------------------------------------------------------------------------------------------
-----------
891                                 ; Burst the final data words over the PCI bus
892                                 ; ----------------------------------------------------------------------------------------------
------
893    
894       P:00020E P:000210 200013            CLR     A
895       P:00020F P:000211 44F000            MOVE              X:LEFT_TO_READ,X0       ; number of left over 16-bit words in Y memo
ry
                            00003B
896       P:000211 P:000213 447000            MOVE              X0,X:NBURST_YMEM
                            000040
897       P:000213 P:000215 200045            CMP     X0,A
898       P:000214 P:000216 0AF0AA            JEQ     HST_ACK_REP                       ; Check that there are words to write.
Motorola DSP56300 Assembler  Version 6.3.4   07-10-31  14:32:10  PCI_SCUBA_main.asm  Page 19



                            000219
899       P:000216 P:000218 0D04F4            JSR     <WRITE_PCI_BURST
900       P:000217 P:000219 0A00A2            JSET    #FATAL_ERROR,X:<STATUS,START
                            000100
901    
902                                 ; ----------------------------------------------------------------------------------------------
------------
903                                 ; reply to host's send_packet_to_host command
904    
905                                  HST_ACK_REP
906       P:000219 P:00021B 44F400            MOVE              #'REP',X0
                            524550
907       P:00021B P:00021D 440C00            MOVE              X0,X:<DTXS_WD1          ; REPly
908       P:00021C P:00021E 44F400            MOVE              #'HST',X0
                            485354
909       P:00021E P:000220 440D00            MOVE              X0,X:<DTXS_WD2          ; echo command sent
910       P:00021F P:000221 44F400            MOVE              #'ACK',X0
                            41434B
911       P:000221 P:000223 440E00            MOVE              X0,X:<DTXS_WD3          ; ACKnowledge okay
912       P:000222 P:000224 44F400            MOVE              #'000',X0
                            303030
913       P:000224 P:000226 440F00            MOVE              X0,X:<DTXS_WD4          ; no error
914       P:000225 P:000227 0D048B            JSR     <PCI_MESSAGE_TO_HOST
915       P:000226 P:000228 0C0173            JMP     <PACKET_IN
916    
917                                 ;-----------------------------------------------------------------------------------------------
----
918                                 ; clear out the fifo after an HST timeout...
919                                 ;----------------------------------------------------------
920    
921       P:000227 P:000229 61F400  DUMP_FIFO MOVE              #DUMP_BUFF,R1           ; address where dumped words stored in Y mem
                            001000
922       P:000229 P:00022B 44F400            MOVE              #MAX_DUMP,X0            ; put a limit to number of words read from f
ifo
                            000200
923       P:00022B P:00022D 200013            CLR     A
924       P:00022C P:00022E 320000            MOVE              #0,R2                   ; use R2 as a dump count
925    
926       P:00022D P:00022F 01AD80  NEXT_DUMP JCLR    #EF,X:PDRD,FIFO_EMPTY
                            000238
927       P:00022F P:000231 000000            NOP
928       P:000230 P:000232 000000            NOP
929       P:000231 P:000233 01AD80            JCLR    #EF,X:PDRD,FIFO_EMPTY
                            000238
930    
931       P:000233 P:000235 0959FF            MOVEP             Y:RDFIFO,Y:(R1)+        ; dump word to Y mem.
932       P:000234 P:000236 205A00            MOVE              (R2)+                   ; inc dump count
933       P:000235 P:000237 224E00            MOVE              R2,A                    ;
934       P:000236 P:000238 200045            CMP     X0,A                              ; check we've not hit dump limit
935       P:000237 P:000239 0E222D            JNE     NEXT_DUMP                         ; not hit limit?
936    
937    
938       P:000238 P:00023A 627000  FIFO_EMPTY MOVE             R2,X:NUM_DUMPED         ; store number of words dumped after HST tim
eout.
                            000007
939       P:00023A P:00023C 0C0100            JMP     <START                            ; re-initialise
940    
941    
942    
943                                 ; ----------------------------------------------------------------------------------------------
--
944                                 ;                              END OF MAIN PACKET HANDLING CODE
Motorola DSP56300 Assembler  Version 6.3.4   07-10-31  14:32:10  PCI_SCUBA_main.asm  Page 20



945                                 ; ---------------------------------------------------------------------------------------------
946    
947    
948                                 ; -------------------------------------------------------------------------------------
949                                 ;
950                                 ;                              INTERRUPT SERVICE ROUTINES
951                                 ;
952                                 ; ---------------------------------------------------------------------------------------
953    
954                                 ;--------------------------------------------------------------------
955                                 CLEAN_UP_PCI
956                                 ;--------------------------------------------------------------------
957                                 ; Clean up the PCI board from wherever it was executing
958    
959       P:00023B P:00023D 08F4BF            MOVEP             #$0001C0,X:IPRC         ; Disable HF* FIFO interrupt
                            0001C0
960       P:00023D P:00023F 05F439            MOVE              #$200,SR                ; mask for reset interrupts only
                            000200
961    
962       P:00023F P:000241 0501BB            MOVEC             #1,SP                   ; Point stack pointer to the top
963       P:000240 P:000242 05F43D            MOVEC             #$000200,SSL            ; SR = zero except for interrupts
                            000200
964       P:000242 P:000244 0500BB            MOVEC             #0,SP                   ; Writing to SSH preincrements the SP
965       P:000243 P:000245 05F43C            MOVEC             #START,SSH              ; Set PC to for full initialization
                            000100
966       P:000245 P:000247 000000            NOP
967       P:000246 P:000248 000004            RTI
968    
969                                 ; ---------------------------------------------------------------------------
970                                 READ_MEMORY
971                                 ;--------------------------------------------------------------------------
972                                 ; word 1 = command = 'RDM'
973                                 ; word 2 = memory type, P=$00'_P', X=$00_'X' or Y=$00_'Y'
974                                 ; word 3 = address in memory
975                                 ; word 4 = not used
976    
977       P:000247 P:000249 0D04E8            JSR     <SAVE_REGISTERS                   ; save working registers
978    
979       P:000248 P:00024A 0D04A6            JSR     <RD_DRXR                          ; read words from host write to HTXR
980       P:000249 P:00024B 56F000            MOVE              X:DRXR_WD1,A            ; read command
                            000008
981       P:00024B P:00024D 44F400            MOVE              #'RDM',X0
                            52444D
982       P:00024D P:00024F 200045            CMP     X0,A                              ; ensure command is 'RDM'
983       P:00024E P:000250 0E2272            JNE     <READ_MEMORY_ERROR_CNE            ; error, command NOT HCVR address
984       P:00024F P:000251 568900            MOVE              X:<DRXR_WD2,A           ; Memory type (X, Y, P)
985       P:000250 P:000252 578A00            MOVE              X:<DRXR_WD3,B
986       P:000251 P:000253 000000            NOP                                       ; pipeline restriction
987       P:000252 P:000254 21B000            MOVE              B1,R0                   ; get address to write to
988       P:000253 P:000255 0140C5            CMP     #$005F50,A                        ; $00'_P'
                            005F50
989       P:000255 P:000257 0E2259            JNE     <RDX
990       P:000256 P:000258 07E084            MOVE              P:(R0),X0               ; Read from P memory
991       P:000257 P:000259 208E00            MOVE              X0,A                    ;
992       P:000258 P:00025A 0C0264            JMP     <FINISH_READ_MEMORY
993                                 RDX
994       P:000259 P:00025B 0140C5            CMP     #$005F58,A                        ; $00'_X'
                            005F58
995       P:00025B P:00025D 0E225F            JNE     <RDY
996       P:00025C P:00025E 44E000            MOVE              X:(R0),X0               ; Read from P memory
997       P:00025D P:00025F 208E00            MOVE              X0,A
998       P:00025E P:000260 0C0264            JMP     <FINISH_READ_MEMORY
Motorola DSP56300 Assembler  Version 6.3.4   07-10-31  14:32:10  PCI_SCUBA_main.asm  Page 21



999                                 RDY
1000      P:00025F P:000261 0140C5            CMP     #$005F59,A                        ; $00'_Y'
                            005F59
1001      P:000261 P:000263 0E2277            JNE     <READ_MEMORY_ERROR_MTE            ; not a valid memory type
1002      P:000262 P:000264 4CE000            MOVE                          Y:(R0),X0   ; Read from P memory
1003      P:000263 P:000265 208E00            MOVE              X0,A
1004   
1005                                ; when completed successfully then PCI needs to reply to Host with
1006                                ; word1 = reply/data = reply
1007                                FINISH_READ_MEMORY
1008      P:000264 P:000266 44F400            MOVE              #'REP',X0
                            524550
1009      P:000266 P:000268 440C00            MOVE              X0,X:<DTXS_WD1          ; REPly
1010      P:000267 P:000269 44F400            MOVE              #'RDM',X0
                            52444D
1011      P:000269 P:00026B 440D00            MOVE              X0,X:<DTXS_WD2          ; echo command sent
1012      P:00026A P:00026C 44F400            MOVE              #'ACK',X0
                            41434B
1013      P:00026C P:00026E 440E00            MOVE              X0,X:<DTXS_WD3          ;  im command
1014      P:00026D P:00026F 21C400            MOVE              A,X0
1015      P:00026E P:000270 440F00            MOVE              X0,X:<DTXS_WD4          ; write to PCI memory error
1016      P:00026F P:000271 0D04D3            JSR     <RESTORE_REGISTERS                ; restore registers
1017      P:000270 P:000272 0D048B            JSR     <PCI_MESSAGE_TO_HOST              ; interrupt host with message (x0 restored h
ere)
1018      P:000271 P:000273 000004            RTI
1019   
1020                                READ_MEMORY_ERROR_CNE
1021      P:000272 P:000274 44F400            MOVE              #'CNE',X0
                            434E45
1022      P:000274 P:000276 440F00            MOVE              X0,X:<DTXS_WD4          ; Command Name Error - command name in DRXR 
does not match
1023      P:000275 P:000277 0AF080            JMP     READ_MEMORY_ERROR                 ; fill in rest of reply
                            00027A
1024                                READ_MEMORY_ERROR_MTE
1025      P:000277 P:000279 44F400            MOVE              #'MTE',X0
                            4D5445
1026      P:000279 P:00027B 440F00            MOVE              X0,X:<DTXS_WD4          ;  Memory Type Error - not a valid memory ty
pe
1027   
1028                                READ_MEMORY_ERROR
1029      P:00027A P:00027C 44F400            MOVE              #'REP',X0
                            524550
1030      P:00027C P:00027E 440C00            MOVE              X0,X:<DTXS_WD1          ; REPly
1031      P:00027D P:00027F 44F400            MOVE              #'RDM',X0
                            52444D
1032      P:00027F P:000281 440D00            MOVE              X0,X:<DTXS_WD2          ; echo command sent
1033      P:000280 P:000282 44F400            MOVE              #'ERR',X0
                            455252
1034      P:000282 P:000284 440E00            MOVE              X0,X:<DTXS_WD3          ; ERRor.
1035      P:000283 P:000285 0D04D3            JSR     <RESTORE_REGISTERS                ; restore working registers
1036      P:000284 P:000286 0D048B            JSR     <PCI_MESSAGE_TO_HOST              ; interrupt host with message (x0 restored h
ere)
1037      P:000285 P:000287 000004            RTI
1038   
1039                                ;-----------------------------------------------------------------------------
1040                                RESET_CONTROLLER
1041                                ; Reset the controller by sending a special code byte $0B with SC/nData = 1
1042                                ;---------------------------------------------------------------------------
1043                                ; word 1 = command = 'RCO'
1044                                ; word 2 = not used but read
1045                                ; word 3 = not used but read
1046                                ; word 4 = not used but read
Motorola DSP56300 Assembler  Version 6.3.4   07-10-31  14:32:10  PCI_SCUBA_main.asm  Page 22



1047   
1048      P:000286 P:000288 0D04E8            JSR     <SAVE_REGISTERS                   ; save working registers
1049      P:000287 P:000289 0D04A6            JSR     <RD_DRXR                          ; read words from host write to HTXR
1050      P:000288 P:00028A 568800            MOVE              X:<DRXR_WD1,A           ; read command
1051      P:000289 P:00028B 44F400            MOVE              #'RCO',X0
                            52434F
1052      P:00028B P:00028D 200045            CMP     X0,A                              ; ensure command is 'RCO'
1053      P:00028C P:00028E 0E22B1            JNE     <RCO_ERROR                        ; error, command NOT HCVR address
1054   
1055                                ; if we get here then everything is fine and we can send reset to controller
1056   
1057                                ; 250MHZ CODE....
1058   
1059      P:00028D P:00028F 011D22            BSET    #SCLK,X:PDRE                      ; Enable special command mode
1060      P:00028E P:000290 000000            NOP
1061      P:00028F P:000291 000000            NOP
1062      P:000290 P:000292 60F400            MOVE              #$FFF000,R0             ; Memory mapped address of transmitter
                            FFF000
1063      P:000292 P:000294 44F400            MOVE              #$10000B,X0             ; Special command to reset controller
                            10000B
1064      P:000294 P:000296 446000            MOVE              X0,X:(R0)
1065      P:000295 P:000297 0606A0            REP     #6                                ; Wait for transmission to complete
1066      P:000296 P:000298 000000            NOP
1067      P:000297 P:000299 011D02            BCLR    #SCLK,X:PDRE                      ; Disable special command mode
1068   
1069                                ; Wait for a bit for MCE to be reset.......
1070      P:000298 P:00029A 44F400            MOVE              #10000,X0               ; Delay by about 350 milliseconds
                            002710
1071      P:00029A P:00029C 06C400            DO      X0,L_DELAY
                            0002A0
1072      P:00029C P:00029E 06E883            DO      #1000,L_RDFIFO
                            00029F
1073      P:00029E P:0002A0 09463F            MOVEP             Y:RDFIFO,Y0             ; Read the FIFO word to keep the
1074      P:00029F P:0002A1 000000            NOP                                       ;   receiver empty
1075                                L_RDFIFO
1076      P:0002A0 P:0002A2 000000            NOP
1077                                L_DELAY
1078      P:0002A1 P:0002A3 000000            NOP
1079   
1080                                ; when completed successfully then PCI needs to reply to Host with
1081                                ; word1 = reply/data = reply
1082                                FINISH_RCO
1083      P:0002A2 P:0002A4 44F400            MOVE              #'REP',X0
                            524550
1084      P:0002A4 P:0002A6 440C00            MOVE              X0,X:<DTXS_WD1          ; REPly
1085      P:0002A5 P:0002A7 44F400            MOVE              #'RCO',X0
                            52434F
1086      P:0002A7 P:0002A9 440D00            MOVE              X0,X:<DTXS_WD2          ; echo command sent
1087      P:0002A8 P:0002AA 44F400            MOVE              #'ACK',X0
                            41434B
1088      P:0002AA P:0002AC 440E00            MOVE              X0,X:<DTXS_WD3          ; ACKnowledge okay
1089      P:0002AB P:0002AD 44F400            MOVE              #'000',X0
                            303030
1090      P:0002AD P:0002AF 440F00            MOVE              X0,X:<DTXS_WD4          ; read data
1091      P:0002AE P:0002B0 0D04D3            JSR     <RESTORE_REGISTERS                ; restore working registers
1092      P:0002AF P:0002B1 0D048B            JSR     <PCI_MESSAGE_TO_HOST              ; interrupt host with message (x0 restored h
ere)
1093      P:0002B0 P:0002B2 000004            RTI                                       ; return from ISR
1094   
1095                                ; when there is a failure in the host to PCI command then the PCI
1096                                ; needs still to reply to Host but with an error message
1097                                RCO_ERROR
Motorola DSP56300 Assembler  Version 6.3.4   07-10-31  14:32:10  PCI_SCUBA_main.asm  Page 23



1098      P:0002B1 P:0002B3 44F400            MOVE              #'REP',X0
                            524550
1099      P:0002B3 P:0002B5 447000            MOVE              X0,X:DTXS_WD1           ; REPly
                            00000C
1100      P:0002B5 P:0002B7 44F400            MOVE              #'RCO',X0
                            52434F
1101      P:0002B7 P:0002B9 447000            MOVE              X0,X:DTXS_WD2           ; echo command sent
                            00000D
1102      P:0002B9 P:0002BB 44F400            MOVE              #'ERR',X0
                            455252
1103      P:0002BB P:0002BD 447000            MOVE              X0,X:DTXS_WD3           ; ERRor im command
                            00000E
1104      P:0002BD P:0002BF 44F400            MOVE              #'CNE',X0
                            434E45
1105      P:0002BF P:0002C1 447000            MOVE              X0,X:DTXS_WD4           ; Command Name Error - command name in DRXR 
does not match
                            00000F
1106      P:0002C1 P:0002C3 0D04D3            JSR     <RESTORE_REGISTERS                ; restore wroking registers
1107      P:0002C2 P:0002C4 0D048B            JSR     <PCI_MESSAGE_TO_HOST              ; interrupt host with message (x0 restored h
ere)
1108      P:0002C3 P:0002C5 000004            RTI                                       ; return from ISR
1109   
1110   
1111                                ;----------------------------------------------------------------------
1112                                SEND_PACKET_TO_CONTROLLER
1113   
1114                                ; forward packet stuff to the MCE
1115                                ; gets address in HOST memory where packet is stored
1116                                ; read 3 consecutive locations starting at this address
1117                                ; then sends the data from these locations up to the MCE
1118                                ;----------------------------------------------------------------------
1119   
1120                                ; word 1 = command = 'CON'
1121                                ; word 2 = host high address
1122                                ; word 3 = host low address
1123                                ; word 4 = '0' --> when MCE command is RS,WB,RB,ST
1124                                ;        = '1' --> when MCE command is GO
1125   
1126                                ; all MCE commands are now 'block commands'
1127                                ; i.e. 64 words long.
1128   
1129      P:0002C4 P:0002C6 0D04E8            JSR     <SAVE_REGISTERS                   ; save working registers
1130   
1131      P:0002C5 P:0002C7 0D04A6            JSR     <RD_DRXR                          ; read words from host write to HTXR
1132                                                                                    ; reads as 4 x 24 bit words
1133   
1134      P:0002C6 P:0002C8 568800            MOVE              X:<DRXR_WD1,A           ; read command
1135      P:0002C7 P:0002C9 44F400            MOVE              #'CON',X0
                            434F4E
1136      P:0002C9 P:0002CB 200045            CMP     X0,A                              ; ensure command is 'CON'
1137      P:0002CA P:0002CC 0E2303            JNE     <CON_ERROR                        ; error, command NOT HCVR address
1138   
1139                                ; convert 2 x 24 bit words ( only 16 LSBs are significant) from host into 32 bit address
1140      P:0002CB P:0002CD 20001B            CLR     B
1141      P:0002CC P:0002CE 448900            MOVE              X:<DRXR_WD2,X0          ; MS 16bits of address
1142      P:0002CD P:0002CF 518A00            MOVE              X:<DRXR_WD3,B0          ; LS 16bits of address
1143      P:0002CE P:0002D0 0C1941            INSERT  #$010010,X0,B                     ; convert to 32 bits and put in B
                            010010
1144   
1145      P:0002D0 P:0002D2 568B00            MOVE              X:<DRXR_WD4,A           ; read word 4 - GO command?
1146      P:0002D1 P:0002D3 44F000            MOVE              X:ZERO,X0
                            000043
Motorola DSP56300 Assembler  Version 6.3.4   07-10-31  14:32:10  PCI_SCUBA_main.asm  Page 24



1147      P:0002D3 P:0002D5 200045            CMP     X0,A
1148      P:0002D4 P:0002D6 0AF0AA            JEQ     BLOCK_CON
                            0002E4
1149   
1150                                ; debug: toggle TOUT to indicate go command issued (monitor pin 26 on Dtype)
1151      P:0002D6 P:0002D8 07F41D            MOVEP             #%010,X:PDRE            ; Port E Data Register (TXD-->TOUT)
                            000002
1152   
1153      P:0002D8 P:0002DA 0A008C            JCLR    #APPLICATION_RUNNING,X:STATUS,SET_PACKET_DELAY ; not running diagnostic applic
ation?
                            0002E2
1154   
1155                                ; need to generate an internal go command to test master write on bus.....  Diagnostic test
1156      P:0002DA P:0002DC 0A702D            BSET    #INTERNAL_GO,X:STATUS             ; set flag so that GO reply / data is genera
ted by PCI card...
                            000000
1157   
1158                                ; since INTERNAL_GO  - read command but don't send it to MCE...
1159   
1160                                CLR_CMD
1161      P:0002DC P:0002DE 064080            DO      #64,END_CLR_CMD                   ; block size = 32bit x 64 (256 bytes)
                            0002DF
1162      P:0002DE P:0002E0 0D04B3            JSR     <READ_FROM_PCI                    ; get next 32 bit word from HOST
1163      P:0002DF P:0002E1 000000            NOP
1164                                END_CLR_CMD
1165      P:0002E0 P:0002E2 0AF080            JMP     FINISH_CON                        ; don't send out on command on fibre
                            0002F4
1166   
1167   
1168                                SET_PACKET_DELAY
1169      P:0002E2 P:0002E4 0A7027            BSET    #DATA_DLY,X:STATUS                ; set data delay so that next data packet af
ter go reply
                            000000
1170                                                                                    ; experiences a delay before host notify.
1171   
1172                                ; -----------------------------------------------------------------------
1173                                ; WARNING!!!
1174                                ; MCE requires IDLE characters between 32bit words sent FROM the PCI card
1175                                ; DO not change READ_FROM_PCI to DMA block transfer....
1176                                ; ------------------------------------------------------------------------
1177   
1178                                BLOCK_CON
1179      P:0002E4 P:0002E6 66F000            MOVE              X:CONSTORE,R6
                            00003F
1180   
1181      P:0002E6 P:0002E8 064080            DO      #64,END_BLOCK_CON                 ; block size = 32bit x 64 (256 bytes)
                            0002EE
1182      P:0002E8 P:0002EA 0D04B3            JSR     <READ_FROM_PCI                    ; get next 32 bit word from HOST
1183      P:0002E9 P:0002EB 208C00            MOVE              X0,A1                   ; prepare to send
1184      P:0002EA P:0002EC 20A800            MOVE              X1,A0                   ; prepare to send
1185   
1186      P:0002EB P:0002ED 4D5E00            MOVE                          X1,Y:(R6)+  ; b4, b3 (msb)
1187      P:0002EC P:0002EE 4C5E00            MOVE                          X0,Y:(R6)+  ; b2, b1  (lsb)
1188   
1189      P:0002ED P:0002EF 0D057D            JSR     <XMT_WD_FIBRE                     ; off it goes
1190      P:0002EE P:0002F0 000000            NOP
1191                                END_BLOCK_CON
1192   
1193      P:0002EF P:0002F1 07F41D            MOVEP             #%001,X:PDRE            ; re-initialise Port Data Register - GO done
.
                            000001
1194      P:0002F1 P:0002F3 0A0008            BCLR    #PACKET_CHOKE,X:<STATUS           ; disable packet choke...
Motorola DSP56300 Assembler  Version 6.3.4   07-10-31  14:32:10  PCI_SCUBA_main.asm  Page 25



1195                                                                                    ; comms now open with MCE and packets will b
e processed.
1196                                ; Enable Byte swaping for correct comms protocol.
1197      P:0002F2 P:0002F4 0A0025            BSET    #BYTE_SWAP,X:<STATUS              ; flag to let host know byte swapping on
1198      P:0002F3 P:0002F5 013D24            BSET    #AUX1,X:PDRC                      ; enable hardware
1199   
1200   
1201                                ; -------------------------------------------------------------------------
1202                                ; when completed successfully then PCI needs to reply to Host with
1203                                ; word1 = reply/data = reply
1204                                FINISH_CON
1205      P:0002F4 P:0002F6 44F400            MOVE              #'REP',X0
                            524550
1206      P:0002F6 P:0002F8 440C00            MOVE              X0,X:<DTXS_WD1          ; REPly
1207      P:0002F7 P:0002F9 44F400            MOVE              #'CON',X0
                            434F4E
1208      P:0002F9 P:0002FB 440D00            MOVE              X0,X:<DTXS_WD2          ; echo command sent
1209      P:0002FA P:0002FC 44F400            MOVE              #'ACK',X0
                            41434B
1210      P:0002FC P:0002FE 440E00            MOVE              X0,X:<DTXS_WD3          ; ACKnowledge okay
1211      P:0002FD P:0002FF 44F400            MOVE              #'000',X0
                            303030
1212      P:0002FF P:000301 440F00            MOVE              X0,X:<DTXS_WD4          ; read data
1213      P:000300 P:000302 0D04D3            JSR     <RESTORE_REGISTERS                ; restore working registers
1214      P:000301 P:000303 0D048B            JSR     <PCI_MESSAGE_TO_HOST              ;  interrupt host with message (x0 restored 
here)
1215      P:000302 P:000304 000004            RTI                                       ; return from ISR
1216   
1217                                ; when there is a failure in the host to PCI command then the PCI
1218                                ; needs still to reply to Host but with an error message
1219                                CON_ERROR
1220      P:000303 P:000305 44F400            MOVE              #'REP',X0
                            524550
1221      P:000305 P:000307 440C00            MOVE              X0,X:<DTXS_WD1          ; REPly
1222      P:000306 P:000308 44F400            MOVE              #'CON',X0
                            434F4E
1223      P:000308 P:00030A 440D00            MOVE              X0,X:<DTXS_WD2          ; echo command sent
1224      P:000309 P:00030B 44F400            MOVE              #'ERR',X0
                            455252
1225      P:00030B P:00030D 440E00            MOVE              X0,X:<DTXS_WD3          ; ERRor im command
1226      P:00030C P:00030E 44F400            MOVE              #'CNE',X0
                            434E45
1227      P:00030E P:000310 440F00            MOVE              X0,X:<DTXS_WD4          ; Command Name Error - command name in DRXR 
does not match
1228      P:00030F P:000311 0D04D3            JSR     <RESTORE_REGISTERS                ; restore working registers
1229      P:000310 P:000312 0D048B            JSR     <PCI_MESSAGE_TO_HOST              ; interrupt host with message (x0 restored h
ere)
1230      P:000311 P:000313 000004            RTI                                       ; return from ISR
1231   
1232                                ; ------------------------------------------------------------------------------------
1233                                SEND_PACKET_TO_HOST
1234                                ; this command is received from the Host and actions the PCI board to pick up an address
1235                                ; pointer from DRXR which the PCI board then uses to write packets from the
1236                                ; MCE to the host memory starting at the address given.
1237                                ; Since this is interrupt driven all this piece of code does is get the address pointer from
1238                                ; the host via DRXR, set a flag so that the main prog can write the packet.  Replies to
1239                                ; HST after packet sent (unless error).
1240                                ; --------------------------------------------------------------------------------------
1241                                ; word 1 = command = 'HST'
1242                                ; word 2 = host high address
1243                                ; word 3 = host low address
1244                                ; word 4 = not used but read
Motorola DSP56300 Assembler  Version 6.3.4   07-10-31  14:32:10  PCI_SCUBA_main.asm  Page 26



1245   
1246                                ; save some registers but not B
1247   
1248      P:000312 P:000314 0D04E8            JSR     <SAVE_REGISTERS                   ; save working registers
1249   
1250      P:000313 P:000315 0D04A6            JSR     <RD_DRXR                          ; read words from host write to HTXR
1251      P:000314 P:000316 20001B            CLR     B
1252      P:000315 P:000317 568800            MOVE              X:<DRXR_WD1,A           ; read command
1253      P:000316 P:000318 44F400            MOVE              #'HST',X0
                            485354
1254      P:000318 P:00031A 200045            CMP     X0,A                              ; ensure command is 'HST'
1255      P:000319 P:00031B 0E2321            JNE     <HOST_ERROR                       ; error, command NOT HCVR address
1256      P:00031A P:00031C 448900            MOVE              X:<DRXR_WD2,X0          ; high 16 bits of address
1257      P:00031B P:00031D 518A00            MOVE              X:<DRXR_WD3,B0          ; low 16 bits of adderss
1258      P:00031C P:00031E 0C1941            INSERT  #$010010,X0,B                     ; convert to 32 bits and put in B
                            010010
1259   
1260      P:00031E P:000320 0A0021            BSET    #SEND_TO_HOST,X:<STATUS           ; tell main program to write packet to host 
memory
1261      P:00031F P:000321 0D04DF            JSR     <RESTORE_HST_REGISTERS            ; restore registers for HST .... B not resto
red..
1262      P:000320 P:000322 000004            RTI
1263   
1264                                ; !!NOTE!!!
1265                                ; successful reply to this command is sent after packet has been send to host.
1266                                ; Not here unless error.
1267   
1268                                ; when there is a failure in the host to PCI command then the PCI
1269                                ; needs still to reply to Host but with an error message
1270                                HOST_ERROR
1271      P:000321 P:000323 0A7001            BCLR    #SEND_TO_HOST,X:STATUS
                            000000
1272      P:000323 P:000325 44F400            MOVE              #'REP',X0
                            524550
1273      P:000325 P:000327 440C00            MOVE              X0,X:<DTXS_WD1          ; REPly
1274      P:000326 P:000328 44F400            MOVE              #'HST',X0
                            485354
1275      P:000328 P:00032A 440D00            MOVE              X0,X:<DTXS_WD2          ; echo command sent
1276      P:000329 P:00032B 44F400            MOVE              #'ERR',X0
                            455252
1277      P:00032B P:00032D 440E00            MOVE              X0,X:<DTXS_WD3          ; ERRor im command
1278      P:00032C P:00032E 44F400            MOVE              #'CNE',X0
                            434E45
1279      P:00032E P:000330 440F00            MOVE              X0,X:<DTXS_WD4          ; Command Name Error - command name in DRXR 
does not match
1280      P:00032F P:000331 0D04D3            JSR     <RESTORE_REGISTERS                ; restore working registers
1281      P:000330 P:000332 0D048B            JSR     <PCI_MESSAGE_TO_HOST              ; interrupt host with message (x0 restored h
ere)
1282      P:000331 P:000333 000004            RTI
1283   
1284                                ; --------------------------------------------------------------------
1285                                SOFTWARE_RESET
1286                                ;----------------------------------------------------------------------
1287                                ; word 1 = command = 'RST'
1288                                ; word 2 = not used but read
1289                                ; word 3 = not used but read
1290                                ; word 4 = not used but read
1291   
1292      P:000332 P:000334 0D04E8            JSR     <SAVE_REGISTERS
1293   
1294      P:000333 P:000335 0D04A6            JSR     <RD_DRXR                          ; read words from host write to HTXR
1295      P:000334 P:000336 568800            MOVE              X:<DRXR_WD1,A           ; read command
Motorola DSP56300 Assembler  Version 6.3.4   07-10-31  14:32:10  PCI_SCUBA_main.asm  Page 27



1296      P:000335 P:000337 44F400            MOVE              #'RST',X0
                            525354
1297      P:000337 P:000339 200045            CMP     X0,A                              ; ensure command is 'RST'
1298      P:000338 P:00033A 0E235B            JNE     <RST_ERROR                        ; error, command NOT HCVR address
1299   
1300                                ; RST command OK so reply to host
1301                                FINISH_RST
1302      P:000339 P:00033B 44F400            MOVE              #'REP',X0
                            524550
1303      P:00033B P:00033D 440C00            MOVE              X0,X:<DTXS_WD1          ; REPly
1304      P:00033C P:00033E 44F400            MOVE              #'RST',X0
                            525354
1305      P:00033E P:000340 440D00            MOVE              X0,X:<DTXS_WD2          ; echo command sent
1306      P:00033F P:000341 44F400            MOVE              #'ACK',X0
                            41434B
1307      P:000341 P:000343 440E00            MOVE              X0,X:<DTXS_WD3          ; ACKnowledge okay
1308      P:000342 P:000344 44F400            MOVE              #'000',X0
                            303030
1309      P:000344 P:000346 440F00            MOVE              X0,X:<DTXS_WD4          ; read data
1310      P:000345 P:000347 0D048B            JSR     <PCI_MESSAGE_TO_HOST
1311   
1312      P:000346 P:000348 0A85A3            JSET    #DCTR_HF3,X:DCTR,*
                            000346
1313   
1314      P:000348 P:00034A 0A0000            BCLR    #APPLICATION_LOADED,X:<STATUS     ; clear app flag
1315      P:000349 P:00034B 0A0006            BCLR    #PREAMBLE_ERROR,X:<STATUS         ; clear preamble error
1316      P:00034A P:00034C 0A000C            BCLR    #APPLICATION_RUNNING,X:<STATUS    ; clear appl running bit.
1317   
1318                                ; initialise some parameter here - that we don't want to initialse under a fatal error reset.
1319   
1320      P:00034B P:00034D 200013            CLR     A
1321      P:00034C P:00034E 340000            MOVE              #0,R4                   ; initialise word count
1322      P:00034D P:00034F 560600            MOVE              A,X:<WORD_COUNT         ; initialise word count store (num of words 
written over bus/packet)
1323      P:00034E P:000350 560700            MOVE              A,X:<NUM_DUMPED         ; initialise number dumped from FIFO (after 
HST TO)
1324   
1325   
1326                                ; remember we are in a ISR so can't just jump to start.
1327   
1328      P:00034F P:000351 08F4BF            MOVEP             #$0001C0,X:IPRC         ; Disable HF* FIFO interrupt
                            0001C0
1329      P:000351 P:000353 05F439            MOVE              #$200,SR                ; Mask set up for reset switch only.
                            000200
1330   
1331   
1332      P:000353 P:000355 0501BB            MOVEC             #1,SP                   ; Point stack pointer to the top
1333      P:000354 P:000356 05F43D            MOVEC             #$000200,SSL            ; SSL holds SR return state
                            000200
1334                                                                                    ; set to zero except for interrupts
1335      P:000356 P:000358 0500BB            MOVEC             #0,SP                   ; Writing to SSH preincrements the SP
1336                                                                                    ; so first set to 0
1337      P:000357 P:000359 05F43C            MOVEC             #START,SSH              ; SSH holds return address of PC
                            000100
1338                                                                                    ; therefore,return to initialization
1339      P:000359 P:00035B 000000            NOP
1340      P:00035A P:00035C 000004            RTI                                       ; return from ISR - to START
1341   
1342                                ; when there is a failure in the host to PCI command then the PCI
1343                                ; needs still to reply to Host but with an error message
1344                                RST_ERROR
1345      P:00035B P:00035D 44F400            MOVE              #'REP',X0
Motorola DSP56300 Assembler  Version 6.3.4   07-10-31  14:32:10  PCI_SCUBA_main.asm  Page 28



                            524550
1346      P:00035D P:00035F 440C00            MOVE              X0,X:<DTXS_WD1          ; REPly
1347      P:00035E P:000360 44F400            MOVE              #'RST',X0
                            525354
1348      P:000360 P:000362 440D00            MOVE              X0,X:<DTXS_WD2          ; echo command sent
1349      P:000361 P:000363 44F400            MOVE              #'ERR',X0
                            455252
1350      P:000363 P:000365 440E00            MOVE              X0,X:<DTXS_WD3          ; ERRor im command
1351      P:000364 P:000366 44F400            MOVE              #'CNE',X0
                            434E45
1352      P:000366 P:000368 440F00            MOVE              X0,X:<DTXS_WD4          ; Command Name Error - command name in DRXR 
does not match
1353      P:000367 P:000369 0D04D3            JSR     <RESTORE_REGISTERS                ; restore working registers
1354      P:000368 P:00036A 0D048B            JSR     <PCI_MESSAGE_TO_HOST              ; interrupt host with message (x0 restored h
ere)
1355      P:000369 P:00036B 000004            RTI                                       ; return from ISR
1356   
1357   
1358                                ;-----------------------------------------------------------------------------
1359                                START_APPLICATION
1360                                ; an application should already have been downloaded to the PCI memory.
1361                                ; this command will execute it.
1362                                ; ----------------------------------------------------------------------
1363                                ; word 1 = command = 'GOA'
1364                                ; word 2 = not used but read by RD_DRXR
1365                                ; word 3 = not used but read by RD_DRXR
1366                                ; word 4 = not used but read by RD_DRXR
1367   
1368      P:00036A P:00036C 0D04E8            JSR     <SAVE_REGISTERS                   ; save working registers
1369   
1370      P:00036B P:00036D 0D04A6            JSR     <RD_DRXR                          ; read words from host write to HTXR
1371      P:00036C P:00036E 568800            MOVE              X:<DRXR_WD1,A           ; read command
1372      P:00036D P:00036F 44F400            MOVE              #'GOA',X0
                            474F41
1373      P:00036F P:000371 200045            CMP     X0,A                              ; ensure command is 'RDM'
1374      P:000370 P:000372 0E2373            JNE     <GO_ERROR                         ; error, command NOT HCVR address
1375   
1376                                ; if we get here then everything is fine and we can start the application
1377                                ; set bit in status so that main fibre servicing code knows to jump
1378                                ; to application space after returning from this ISR
1379   
1380                                ; reply after application has been executed.
1381      P:000371 P:000373 0A0020            BSET    #APPLICATION_LOADED,X:<STATUS
1382      P:000372 P:000374 000004            RTI                                       ; return from ISR
1383   
1384   
1385                                ; when there is a failure in the host to PCI command then the PCI
1386                                ; needs still to reply to Host but with an error message
1387                                GO_ERROR
1388      P:000373 P:000375 44F400            MOVE              #'REP',X0
                            524550
1389      P:000375 P:000377 440C00            MOVE              X0,X:<DTXS_WD1          ; REPly
1390      P:000376 P:000378 44F400            MOVE              #'GOA',X0
                            474F41
1391      P:000378 P:00037A 440D00            MOVE              X0,X:<DTXS_WD2          ; echo command sent
1392      P:000379 P:00037B 44F400            MOVE              #'ERR',X0
                            455252
1393      P:00037B P:00037D 440E00            MOVE              X0,X:<DTXS_WD3          ; ERRor im command
1394      P:00037C P:00037E 44F400            MOVE              #'CNE',X0
                            434E45
1395      P:00037E P:000380 440F00            MOVE              X0,X:<DTXS_WD4          ; Command Name Error - command name in DRXR 
does not match
Motorola DSP56300 Assembler  Version 6.3.4   07-10-31  14:32:10  PCI_SCUBA_main.asm  Page 29



1396      P:00037F P:000381 0D04D3            JSR     <RESTORE_REGISTERS                ; restore working registers
1397      P:000380 P:000382 0D048B            JSR     <PCI_MESSAGE_TO_HOST              ; interrupt host with message (x0 restored h
ere)
1398      P:000381 P:000383 000004            RTI                                       ; return from ISR
1399   
1400                                ; ---------------------------------------------------------
1401                                STOP_APPLICATION
1402                                ; this command stops an application that is currently running
1403                                ; used for applications that once started run contiunually
1404                                ;-----------------------------------------------------------
1405   
1406                                ; word 1 = command = ' STP'
1407                                ; word 2 = not used but read
1408                                ; word 3 = not used but read
1409                                ; word 4 = not used but read
1410   
1411      P:000382 P:000384 0D04E8            JSR     <SAVE_REGISTERS
1412   
1413      P:000383 P:000385 0D04A6            JSR     <RD_DRXR                          ; read words from host write to HTXR
1414      P:000384 P:000386 568800            MOVE              X:<DRXR_WD1,A           ; read command
1415      P:000385 P:000387 44F400            MOVE              #'STP',X0
                            535450
1416      P:000387 P:000389 200045            CMP     X0,A                              ; ensure command is 'RDM'
1417      P:000388 P:00038A 0E239B            JNE     <STP_ERROR                        ; error, command NOT HCVR address
1418   
1419      P:000389 P:00038B 0A0000            BCLR    #APPLICATION_LOADED,X:<STATUS
1420      P:00038A P:00038C 0A700C            BCLR    #APPLICATION_RUNNING,X:STATUS
                            000000
1421   
1422                                ; when completed successfully then PCI needs to reply to Host with
1423                                ; word1 = reply/data = reply
1424                                FINISH_STP
1425      P:00038C P:00038E 44F400            MOVE              #'REP',X0
                            524550
1426      P:00038E P:000390 440C00            MOVE              X0,X:<DTXS_WD1          ; REPly
1427      P:00038F P:000391 44F400            MOVE              #'STP',X0
                            535450
1428      P:000391 P:000393 440D00            MOVE              X0,X:<DTXS_WD2          ; echo command sent
1429      P:000392 P:000394 44F400            MOVE              #'ACK',X0
                            41434B
1430      P:000394 P:000396 440E00            MOVE              X0,X:<DTXS_WD3          ; ACKnowledge okay
1431      P:000395 P:000397 44F400            MOVE              #'000',X0
                            303030
1432      P:000397 P:000399 440F00            MOVE              X0,X:<DTXS_WD4          ; read data
1433      P:000398 P:00039A 0D04D3            JSR     <RESTORE_REGISTERS                ; restore working registers.
1434      P:000399 P:00039B 0D048B            JSR     <PCI_MESSAGE_TO_HOST              ; interrupt host with message (x0 restored h
ere)
1435      P:00039A P:00039C 000004            RTI
1436   
1437                                ; when there is a failure in the host to PCI command then the PCI
1438                                ; needs still to reply to Host but with an error message
1439                                STP_ERROR
1440      P:00039B P:00039D 44F400            MOVE              #'REP',X0
                            524550
1441      P:00039D P:00039F 440C00            MOVE              X0,X:<DTXS_WD1          ; REPly
1442      P:00039E P:0003A0 44F400            MOVE              #'STP',X0
                            535450
1443      P:0003A0 P:0003A2 440D00            MOVE              X0,X:<DTXS_WD2          ; echo command sent
1444      P:0003A1 P:0003A3 44F400            MOVE              #'ERR',X0
                            455252
1445      P:0003A3 P:0003A5 440E00            MOVE              X0,X:<DTXS_WD3          ; ERRor im command
1446      P:0003A4 P:0003A6 44F400            MOVE              #'CNE',X0
Motorola DSP56300 Assembler  Version 6.3.4   07-10-31  14:32:10  PCI_SCUBA_main.asm  Page 30



                            434E45
1447      P:0003A6 P:0003A8 440F00            MOVE              X0,X:<DTXS_WD4          ; Command Name Error - command name in DRXR 
does not match
1448      P:0003A7 P:0003A9 0D04D3            JSR     <RESTORE_REGISTERS                ; restore working registers
1449      P:0003A8 P:0003AA 0D048B            JSR     <PCI_MESSAGE_TO_HOST              ; interrupt host with message (x0 restored h
ere)
1450      P:0003A9 P:0003AB 000004            RTI
1451   
1452                                ;--------------------------------------------------------------
1453                                WRITE_MEMORY
1454                                ;---------------------------------------------------------------
1455                                ; word 1 = command = 'WRM'
1456                                ; word 2 = memory type, P=$00'_P', X=$00'_X' or Y=$00'_Y'
1457                                ; word 3 = address in memory
1458                                ; word 4 = value
1459   
1460      P:0003AA P:0003AC 0D04E8            JSR     <SAVE_REGISTERS                   ; save working registers
1461   
1462      P:0003AB P:0003AD 0D04A6            JSR     <RD_DRXR                          ; read words from host write to HTXR
1463      P:0003AC P:0003AE 56F000            MOVE              X:DRXR_WD1,A            ; read command
                            000008
1464      P:0003AE P:0003B0 44F400            MOVE              #'WRM',X0
                            57524D
1465      P:0003B0 P:0003B2 200045            CMP     X0,A                              ; ensure command is 'WRM'
1466      P:0003B1 P:0003B3 0E23D4            JNE     <WRITE_MEMORY_ERROR_CNE           ; error, command NOT HCVR address
1467      P:0003B2 P:0003B4 568900            MOVE              X:<DRXR_WD2,A           ; Memory type (X, Y, P)
1468      P:0003B3 P:0003B5 578A00            MOVE              X:<DRXR_WD3,B
1469      P:0003B4 P:0003B6 000000            NOP                                       ; pipeline restriction
1470      P:0003B5 P:0003B7 21B000            MOVE              B1,R0                   ; get address to write to
1471      P:0003B6 P:0003B8 448B00            MOVE              X:<DRXR_WD4,X0          ; get data to write
1472      P:0003B7 P:0003B9 0140C5            CMP     #$005F50,A                        ; $00'_P'
                            005F50
1473      P:0003B9 P:0003BB 0E23BC            JNE     <WRX
1474      P:0003BA P:0003BC 076084            MOVE              X0,P:(R0)               ; Write to Program memory
1475      P:0003BB P:0003BD 0C03C5            JMP     <FINISH_WRITE_MEMORY
1476                                WRX
1477      P:0003BC P:0003BE 0140C5            CMP     #$005F58,A                        ; $00'_X'
                            005F58
1478      P:0003BE P:0003C0 0E23C1            JNE     <WRY
1479      P:0003BF P:0003C1 446000            MOVE              X0,X:(R0)               ; Write to X: memory
1480      P:0003C0 P:0003C2 0C03C5            JMP     <FINISH_WRITE_MEMORY
1481                                WRY
1482      P:0003C1 P:0003C3 0140C5            CMP     #$005F59,A                        ; $00'_Y'
                            005F59
1483      P:0003C3 P:0003C5 0E23D8            JNE     <WRITE_MEMORY_ERROR_MTE
1484      P:0003C4 P:0003C6 4C6000            MOVE                          X0,Y:(R0)   ; Write to Y: memory
1485   
1486                                ; when completed successfully then PCI needs to reply to Host with
1487                                ; word1 = reply/data = reply
1488                                FINISH_WRITE_MEMORY
1489      P:0003C5 P:0003C7 44F400            MOVE              #'REP',X0
                            524550
1490      P:0003C7 P:0003C9 440C00            MOVE              X0,X:<DTXS_WD1          ; REPly
1491      P:0003C8 P:0003CA 44F400            MOVE              #'WRM',X0
                            57524D
1492      P:0003CA P:0003CC 440D00            MOVE              X0,X:<DTXS_WD2          ; echo command sent
1493      P:0003CB P:0003CD 44F400            MOVE              #'ACK',X0
                            41434B
1494      P:0003CD P:0003CF 440E00            MOVE              X0,X:<DTXS_WD3          ; ACKnowledge okay
1495      P:0003CE P:0003D0 44F400            MOVE              #'000',X0
                            303030
1496      P:0003D0 P:0003D2 440F00            MOVE              X0,X:<DTXS_WD4          ; no error
Motorola DSP56300 Assembler  Version 6.3.4   07-10-31  14:32:10  PCI_SCUBA_main.asm  Page 31



1497      P:0003D1 P:0003D3 0D04D3            JSR     <RESTORE_REGISTERS                ; restore working registers
1498      P:0003D2 P:0003D4 0D048B            JSR     <PCI_MESSAGE_TO_HOST              ; interrupt host with message (x0 restored h
ere)
1499      P:0003D3 P:0003D5 000004            RTI
1500   
1501                                ;
1502                                WRITE_MEMORY_ERROR_CNE
1503      P:0003D4 P:0003D6 44F400            MOVE              #'CNE',X0
                            434E45
1504      P:0003D6 P:0003D8 440F00            MOVE              X0,X:<DTXS_WD4          ; Command Name Error - command name in DRXR 
does not match
1505      P:0003D7 P:0003D9 0C03DB            JMP     <WRITE_MEMORY_ERROR               ; fill in rest of reply
1506   
1507                                WRITE_MEMORY_ERROR_MTE
1508      P:0003D8 P:0003DA 44F400            MOVE              #'MTE',X0
                            4D5445
1509      P:0003DA P:0003DC 440F00            MOVE              X0,X:<DTXS_WD4          ; Memory Type Error - memory type not valid
1510   
1511                                WRITE_MEMORY_ERROR
1512      P:0003DB P:0003DD 44F400            MOVE              #'REP',X0
                            524550
1513      P:0003DD P:0003DF 440C00            MOVE              X0,X:<DTXS_WD1          ; REPly
1514      P:0003DE P:0003E0 44F400            MOVE              #'WRM',X0
                            57524D
1515      P:0003E0 P:0003E2 440D00            MOVE              X0,X:<DTXS_WD2          ; echo command sent
1516      P:0003E1 P:0003E3 44F400            MOVE              #'ERR',X0
                            455252
1517      P:0003E3 P:0003E5 440E00            MOVE              X0,X:<DTXS_WD3          ; ERRor im command
1518      P:0003E4 P:0003E6 0D04D3            JSR     <RESTORE_REGISTERS                ; restore working registers
1519      P:0003E5 P:0003E7 0D048B            JSR     <PCI_MESSAGE_TO_HOST              ; interrupt host with message (x0 restored h
ere)
1520      P:0003E6 P:0003E8 000004            RTI
1521   
1522   
1523                                ;---------------------------------------------------------------
1524                                ;
1525                                ;                          * END OF ISRs *
1526                                ;
1527                                ;--------------------------------------------------------------
1528   
1529   
1530   
1531                                ;----------------------------------------------------------------
1532                                ;
1533                                ;                     * Beginning of SUBROUTINES *
1534                                ;
1535                                ;-----------------------------------------------------------------
1536   
1537   
1538                                ; -------------------------------------------------------------
1539                                CALC_NO_BUFFS
1540                                ;----------------------------------------------------
1541                                ; number of 512 buffers in packet calculated (X:TOTAL_BUFFS)
1542                                ; and number of left over blocks (X:NUM_LEFTOVER_BLOCKS)
1543                                ; and left over words (X:LEFT_TO_READ)
1544   
1545      P:0003E7 P:0003E9 20001B            CLR     B
1546      P:0003E8 P:0003EA 51A300            MOVE              X:<HEAD_W4_0,B0         ; LS 16bits
1547      P:0003E9 P:0003EB 44A200            MOVE              X:<HEAD_W4_1,X0         ; MS 16bits
1548   
1549      P:0003EA P:0003EC 0C1941            INSERT  #$010010,X0,B                     ; now size of packet B....giving # of 32bit 
words in packet
Motorola DSP56300 Assembler  Version 6.3.4   07-10-31  14:32:10  PCI_SCUBA_main.asm  Page 32



                            010010
1550      P:0003EC P:0003EE 000000            NOP
1551   
1552                                ; need to covert this to 16 bit since read from FIFO and saved in Y memory as 16bit words...
1553   
1554                                ; so double size of packet....
1555      P:0003ED P:0003EF 20003A            ASL     B
1556   
1557                                ; now save
1558      P:0003EE P:0003F0 212400            MOVE              B0,X0
1559      P:0003EF P:0003F1 21A500            MOVE              B1,X1
1560      P:0003F0 P:0003F2 443300            MOVE              X0,X:<PACKET_SIZE_LOW   ; low 24 bits of packet size (in 16bit words
)
1561      P:0003F1 P:0003F3 453400            MOVE              X1,X:<PACKET_SIZE_HIH   ; high 8 bits of packet size (in 16bit words
)
1562   
1563      P:0003F2 P:0003F4 50B300            MOVE              X:<PACKET_SIZE_LOW,A0
1564      P:0003F3 P:0003F5 54B400            MOVE              X:<PACKET_SIZE_HIH,A1
1565      P:0003F4 P:0003F6 0C1C0E            ASR     #7,A,A                            ; divide by 128. To get # of max 256byte bur
sts over bus
1566      P:0003F5 P:0003F7 000000            NOP
1567      P:0003F6 P:0003F8 503900            MOVE              A0,X:<NMAX_BURSTS
1568      P:0003F7 P:0003F9 0C1C04            ASR     #2,A,A                            ; divide by another 2 (total=/512: number of
 16bit words)
1569      P:0003F8 P:0003FA 000000            NOP
1570      P:0003F9 P:0003FB 503A00            MOVE              A0,X:<TOTAL_BUFFS       ; number of half full fifos required to read
 in all of data.
1571   
1572   
1573      P:0003FA P:0003FC 210500            MOVE              A0,X1
1574      P:0003FB P:0003FD 47F400            MOVE              #HF_FIFO,Y1
                            000200
1575      P:0003FD P:0003FF 2000F0            MPY     X1,Y1,A
1576      P:0003FE P:000400 0C1C03            ASR     #1,A,B                            ; B holds number of 16bit words in all full 
buffers
1577      P:0003FF P:000401 000000            NOP
1578   
1579      P:000400 P:000402 50B300            MOVE              X:<PACKET_SIZE_LOW,A0
1580      P:000401 P:000403 54B400            MOVE              X:<PACKET_SIZE_HIH,A1   ; A holds total number of 16bit words
1581      P:000402 P:000404 200014            SUB     B,A                               ; now A holds number of left over 16bit word
s
1582      P:000403 P:000405 000000            NOP
1583      P:000404 P:000406 503B00            MOVE              A0,X:<LEFT_TO_READ      ; store number of left over 16bit words to r
ead
1584      P:000405 P:000407 0C1C0E            ASR     #7,A,A                            ; divide by 128 - for max burst size (256byt
es)
1585      P:000406 P:000408 000000            NOP
1586      P:000407 P:000409 503D00            MOVE              A0,X:<NUM_LEFTOVER_BLOCKS
1587      P:000408 P:00040A 210500            MOVE              A0,X1
1588      P:000409 P:00040B 47F400            MOVE              #>128,Y1
                            000080
1589      P:00040B P:00040D 2000F0            MPY     X1,Y1,A
1590      P:00040C P:00040E 0C1C02            ASR     #1,A,A
1591      P:00040D P:00040F 000000            NOP
1592   
1593      P:00040E P:000410 200018            ADD     A,B                               ; B holds words in all buffers
1594      P:00040F P:000411 000000            NOP
1595      P:000410 P:000412 50B300            MOVE              X:<PACKET_SIZE_LOW,A0
1596      P:000411 P:000413 54B400            MOVE              X:<PACKET_SIZE_HIH,A1   ; A holds total number of words
1597      P:000412 P:000414 200014            SUB     B,A                               ; now A holds number of left over words
1598      P:000413 P:000415 000000            NOP
1599      P:000414 P:000416 503B00            MOVE              A0,X:<LEFT_TO_READ      ; store number of left over 16bit words to r
Motorola DSP56300 Assembler  Version 6.3.4   07-10-31  14:32:10  PCI_SCUBA_main.asm  Page 33



ead
1600   
1601      P:000415 P:000417 0C1C02            ASR     #1,A,A                            ; divide by two to get number of 32 bit word
s to write
1602      P:000416 P:000418 000000            NOP                                       ; for pipeline
1603      P:000417 P:000419 503C00            MOVE              A0,X:<LEFT_TO_WRITE     ; store number of left over 32 bit words (2 
x 16 bit) to write to host after small block transfer as well
1604   
1605      P:000418 P:00041A 00000C            RTS
1606   
1607                                ;---------------------------------------------------------------
1608                                GET_FO_WRD
1609                                ;--------------------------------------------------------------
1610                                ; Anything in fibre receive FIFO?   If so store in X0
1611   
1612      P:000419 P:00041B 01AD80            JCLR    #EF,X:PDRD,CLR_FO_RTS
                            00042F
1613      P:00041B P:00041D 000000            NOP
1614      P:00041C P:00041E 000000            NOP
1615      P:00041D P:00041F 01AD80            JCLR    #EF,X:PDRD,CLR_FO_RTS             ; check twice for FO metastability.
                            00042F
1616      P:00041F P:000421 0AF080            JMP     RD_FO_WD
                            000427
1617   
1618      P:000421 P:000423 01AD80  WT_FIFO   JCLR    #EF,X:PDRD,*                      ; Wait till something in FIFO flagged
                            000421
1619      P:000423 P:000425 000000            NOP
1620      P:000424 P:000426 000000            NOP
1621      P:000425 P:000427 01AD80            JCLR    #EF,X:PDRD,WT_FIFO                ; check twice.....
                            000421
1622   
1623                                ; Read one word from the fiber optics FIFO, check it and put it in A1
1624                                RD_FO_WD
1625      P:000427 P:000429 09443F            MOVEP             Y:RDFIFO,X0             ; then read to X0
1626      P:000428 P:00042A 54F400            MOVE              #$00FFFF,A1             ; mask off top 2 bytes ($FC)
                            00FFFF
1627      P:00042A P:00042C 200046            AND     X0,A                              ; since receiving 16 bits in 24bit register
1628      P:00042B P:00042D 000000            NOP
1629      P:00042C P:00042E 218400            MOVE              A1,X0
1630      P:00042D P:00042F 0A0023            BSET    #FO_WRD_RCV,X:<STATUS
1631      P:00042E P:000430 00000C            RTS
1632                                CLR_FO_RTS
1633      P:00042F P:000431 0A0003            BCLR    #FO_WRD_RCV,X:<STATUS
1634      P:000430 P:000432 00000C            RTS
1635   
1636                                ;-----------------------------------------------
1637                                PCI_ERROR_RECOVERY
1638                                ; Recover from an error writing to the PCI bus
1639                                ; TO, TDIS                      - resume burst
1640                                ; TRTY,TAB,MAB,APER,DPER        - restart burst
1641                                ;
1642                                ; resume recovery for TO/TDIS added on advice
1643                                ; from Matthew Hasselfield (UBC)
1644                                ;----------------------------------------------
1645   
1646                                ; in pci error count
1647   
1648      P:000431 P:000433 50F000            MOVE              X:ECOUNT_PCI,A0
                            000047
1649      P:000433 P:000435 000008            INC     A
1650      P:000434 P:000436 000000            NOP
1651      P:000435 P:000437 507000            MOVE              A0,X:ECOUNT_PCI
Motorola DSP56300 Assembler  Version 6.3.4   07-10-31  14:32:10  PCI_SCUBA_main.asm  Page 34



                            000047
1652   
1653      P:000437 P:000439 0A8AAA            JSET    #TRTY,X:DPSR,TRTY_ERROR
                            000445
1654      P:000439 P:00043B 0A8AAB            JSET    #TO,X:DPSR,TO_ERROR
                            00044F
1655      P:00043B P:00043D 0A8AA9            JSET    #TDIS,X:DPSR,TDIS_ERROR
                            000459
1656      P:00043D P:00043F 0A8AA8            JSET    #TAB,X:DPSR,TAB_ERROR
                            000463
1657      P:00043F P:000441 0A8AA7            JSET    #MAB,X:DPSR,MAB_ERROR
                            00046D
1658      P:000441 P:000443 0A8AA6            JSET    #DPER,X:DPSR,DPER_ERROR
                            000477
1659      P:000443 P:000445 0A8AA5            JSET    #APER,X:DPSR,APER_ERROR
                            000481
1660   
1661                                TRTY_ERROR                                          ; Retry error
1662      P:000445 P:000447 50F000            MOVE              X:ECOUNT_TRTY,A0
                            000048
1663      P:000447 P:000449 000008            INC     A
1664      P:000448 P:00044A 08F48A            MOVEP             #$0400,X:DPSR           ; Clear target retry error bit
                            000400
1665      P:00044A P:00044C 507000            MOVE              A0,X:ECOUNT_TRTY
                            000048
1666      P:00044C P:00044E 0A702E            BSET    #PCIBURST_RESTART,X:STATUS
                            000000
1667      P:00044E P:000450 00000C            RTS
1668   
1669                                TO_ERROR                                            ; Timeout error
1670      P:00044F P:000451 50F000            MOVE              X:ECOUNT_TO,A0
                            000049
1671      P:000451 P:000453 000008            INC     A
1672      P:000452 P:000454 08F48A            MOVEP             #$0800,X:DPSR           ; Clear timeout error bit
                            000800
1673      P:000454 P:000456 507000            MOVE              A0,X:ECOUNT_TO
                            000049
1674      P:000456 P:000458 0A702F            BSET    #PCIBURST_RESUME,X:STATUS
                            000000
1675      P:000458 P:00045A 00000C            RTS
1676   
1677                                TDIS_ERROR                                          ; Target disconnect error
1678      P:000459 P:00045B 50F000            MOVE              X:ECOUNT_TDIS,A0
                            00004A
1679      P:00045B P:00045D 000008            INC     A
1680      P:00045C P:00045E 08F48A            MOVEP             #$0200,X:DPSR           ; Clear target disconnect bit
                            000200
1681      P:00045E P:000460 507000            MOVE              A0,X:ECOUNT_TDIS
                            00004A
1682      P:000460 P:000462 0A702F            BSET    #PCIBURST_RESUME,X:STATUS
                            000000
1683      P:000462 P:000464 00000C            RTS
1684   
1685                                TAB_ERROR                                           ; Target abort error
1686      P:000463 P:000465 50F000            MOVE              X:ECOUNT_TAB,A0
                            00004B
1687      P:000465 P:000467 000008            INC     A
1688      P:000466 P:000468 08F48A            MOVEP             #$0100,X:DPSR           ; Clear target abort error bit
                            000100
1689      P:000468 P:00046A 507000            MOVE              A0,X:ECOUNT_TAB
                            00004B
1690      P:00046A P:00046C 0A702E            BSET    #PCIBURST_RESTART,X:STATUS
Motorola DSP56300 Assembler  Version 6.3.4   07-10-31  14:32:10  PCI_SCUBA_main.asm  Page 35



                            000000
1691      P:00046C P:00046E 00000C            RTS
1692   
1693                                MAB_ERROR                                           ; Master abort error
1694      P:00046D P:00046F 50F000            MOVE              X:ECOUNT_MAB,A0
                            00004C
1695      P:00046F P:000471 000008            INC     A
1696      P:000470 P:000472 08F48A            MOVEP             #$0080,X:DPSR           ; Clear master abort error bit
                            000080
1697      P:000472 P:000474 507000            MOVE              A0,X:ECOUNT_MAB
                            00004C
1698      P:000474 P:000476 0A702E            BSET    #PCIBURST_RESTART,X:STATUS
                            000000
1699      P:000476 P:000478 00000C            RTS
1700   
1701                                DPER_ERROR                                          ; Data parity error
1702      P:000477 P:000479 50F000            MOVE              X:ECOUNT_DPER,A0
                            00004D
1703      P:000479 P:00047B 000008            INC     A
1704      P:00047A P:00047C 08F48A            MOVEP             #$0040,X:DPSR           ; Clear data parity error bit
                            000040
1705      P:00047C P:00047E 507000            MOVE              A0,X:ECOUNT_DPER
                            00004D
1706      P:00047E P:000480 0A702E            BSET    #PCIBURST_RESTART,X:STATUS
                            000000
1707      P:000480 P:000482 00000C            RTS
1708   
1709                                APER_ERROR                                          ; Address parity error
1710      P:000481 P:000483 50F000            MOVE              X:ECOUNT_APER,A0
                            00004E
1711      P:000483 P:000485 000008            INC     A
1712      P:000484 P:000486 08F48A            MOVEP             #$0020,X:DPSR           ; Clear address parity error bit
                            000020
1713      P:000486 P:000488 507000            MOVE              A0,X:ECOUNT_APER
                            00004E
1714      P:000488 P:00048A 0A702E            BSET    #PCIBURST_RESTART,X:STATUS
                            000000
1715      P:00048A P:00048C 00000C            RTS
1716   
1717   
1718                                ; ----------------------------------------------------------------------------
1719                                PCI_MESSAGE_TO_HOST
1720                                ;----------------------------------------------------------------------------
1721   
1722                                ; subroutine to send 4 words as a reply from PCI to the Host
1723                                ; using the DTXS-HRXS data path
1724                                ; PCI card writes here first then causes an interrupt INTA on
1725                                ; the PCI bus to alert the host to the reply message
1726   
1727      P:00048B P:00048D 0A85A3            JSET    #DCTR_HF3,X:DCTR,*                ; make sure host ready to receive interrupt
                            00048B
1728                                                                                    ; cleared via fast interrupt if host out of 
its ISR
1729   
1730      P:00048D P:00048F 0A8981            JCLR    #STRQ,X:DSR,*                     ; Wait for transmitter to be NOT FULL
                            00048D
1731                                                                                    ; i.e. if CLR then FULL so wait
1732                                                                                    ; if not then it is clear to write
1733      P:00048F P:000491 448C00            MOVE              X:<DTXS_WD1,X0
1734      P:000490 P:000492 447000            MOVE              X0,X:DTXS               ; Write 24 bit word1
                            FFFFCD
1735   
Motorola DSP56300 Assembler  Version 6.3.4   07-10-31  14:32:10  PCI_SCUBA_main.asm  Page 36



1736      P:000492 P:000494 0A8981            JCLR    #STRQ,X:DSR,*                     ; wait to be not full
                            000492
1737      P:000494 P:000496 448D00            MOVE              X:<DTXS_WD2,X0
1738      P:000495 P:000497 447000            MOVE              X0,X:DTXS               ; Write 24 bit word2
                            FFFFCD
1739   
1740      P:000497 P:000499 0A8981            JCLR    #STRQ,X:DSR,*                     ; wait to be not full
                            000497
1741      P:000499 P:00049B 448E00            MOVE              X:<DTXS_WD3,X0
1742      P:00049A P:00049C 447000            MOVE              X0,X:DTXS               ; Write 24 bit word3
                            FFFFCD
1743   
1744      P:00049C P:00049E 0A8981            JCLR    #STRQ,X:DSR,*                     ; wait to be not full
                            00049C
1745      P:00049E P:0004A0 448F00            MOVE              X:<DTXS_WD4,X0
1746      P:00049F P:0004A1 447000            MOVE              X0,X:DTXS               ; Write 24 bit word4
                            FFFFCD
1747   
1748   
1749                                ; restore X0....
1750                                ; PCI_MESSAGE_TO_HOST is used by all command vector ISRs.
1751                                ; Working registers must be restored before RTI.
1752                                ; However, we want to restore before asserting INTA.
1753                                ; x0 is only one that can't be restored before PCI_MESSAGE_TO_HOST
1754                                ; (since it is used by this SR) hence we restore here.
1755                                ; this is redundant for a 'NFY' message (since sequential instruction)
1756                                ; but may be required for a PCI command reply 'REP' message.
1757                                ; (since interrupt driven)
1758   
1759      P:0004A1 P:0004A3 44F000            MOVE              X:SV_X0,X0              ; restore X0
                            00002E
1760   
1761                                ; all the transmit words are in the FIFO, interrupt the Host
1762                                ; the Host should clear this interrupt once it is detected.
1763                                ; It does this by writing to HCVR to cause a fast interrupt.
1764   
1765   
1766      P:0004A3 P:0004A5 0A8523            BSET    #DCTR_HF3,X:DCTR                  ; set flag to handshake interrupt (INTA) wit
h host.
1767      P:0004A4 P:0004A6 0A8526            BSET    #INTA,X:DCTR                      ; Assert the interrupt
1768   
1769      P:0004A5 P:0004A7 00000C            RTS
1770   
1771                                ;---------------------------------------------------------------
1772                                RD_DRXR
1773                                ;--------------------------------------------------------------
1774                                ; routine is used to read from HTXR-DRXR data path
1775                                ; which is used by the Host to communicate with the PCI board
1776                                ; the host writes 4 words to this FIFO then interrupts the PCI
1777                                ; which reads the 4 words and acts on them accordingly.
1778   
1779   
1780      P:0004A6 P:0004A8 0A8982            JCLR    #SRRQ,X:DSR,*                     ; Wait for receiver to be not empty
                            0004A6
1781                                                                                    ; implies that host has written words
1782   
1783   
1784                                ; actually reading as slave here so this shouldn't be necessary......?
1785   
1786      P:0004A8 P:0004AA 0A8717            BCLR    #FC1,X:DPMC                       ; 24 bit read FC1 = 0, FC1 = 0
1787      P:0004A9 P:0004AB 0A8736            BSET    #FC0,X:DPMC
1788   
Motorola DSP56300 Assembler  Version 6.3.4   07-10-31  14:32:10  PCI_SCUBA_main.asm  Page 37



1789   
1790      P:0004AA P:0004AC 08440B            MOVEP             X:DRXR,X0               ; Get word1
1791      P:0004AB P:0004AD 440800            MOVE              X0,X:<DRXR_WD1
1792      P:0004AC P:0004AE 08440B            MOVEP             X:DRXR,X0               ; Get word2
1793      P:0004AD P:0004AF 440900            MOVE              X0,X:<DRXR_WD2
1794      P:0004AE P:0004B0 08440B            MOVEP             X:DRXR,X0               ; Get word3
1795      P:0004AF P:0004B1 440A00            MOVE              X0,X:<DRXR_WD3
1796      P:0004B0 P:0004B2 08440B            MOVEP             X:DRXR,X0               ; Get word4
1797      P:0004B1 P:0004B3 440B00            MOVE              X0,X:<DRXR_WD4
1798      P:0004B2 P:0004B4 00000C            RTS
1799   
1800                                ;---------------------------------------------------------------
1801                                READ_FROM_PCI
1802                                ;--------------------------------------------------------------
1803                                ; sub routine to read a 24 bit word in from PCI bus --> Y memory
1804                                ; 32bit host address in accumulator B.
1805   
1806                                ; read as master
1807   
1808      P:0004B3 P:0004B5 0C1890            EXTRACTU #$010010,B,A                     ; Get D31-16 bits only
                            010010
1809      P:0004B5 P:0004B7 000000            NOP
1810   
1811      P:0004B6 P:0004B8 210C00            MOVE              A0,A1
1812      P:0004B7 P:0004B9 000000            NOP
1813      P:0004B8 P:0004BA 547000            MOVE              A1,X:DPMC               ; high 16bits of address in DSP master cntr 
reg.
                            FFFFC7
1814                                                                                    ; 32 bit read so FC1 = 0 and FC0 = 0
1815   
1816      P:0004BA P:0004BC 000000            NOP
1817      P:0004BB P:0004BD 0C1890            EXTRACTU #$010000,B,A
                            010000
1818      P:0004BD P:0004BF 000000            NOP
1819      P:0004BE P:0004C0 210C00            MOVE              A0,A1
1820      P:0004BF P:0004C1 0140C2            OR      #$060000,A                        ; A1 gets written to DPAR register
                            060000
1821      P:0004C1 P:0004C3 000000            NOP                                       ; C3-C0 of DPAR=0110 for memory read
1822      P:0004C2 P:0004C4 08CC08  WRT_ADD   MOVEP             A1,X:DPAR               ; Write address to PCI bus - PCI READ action
1823      P:0004C3 P:0004C5 000000            NOP                                       ; Pipeline delay
1824      P:0004C4 P:0004C6 0A8AA2  RD_PCI    JSET    #MRRQ,X:DPSR,GET_DAT              ; If MTRQ = 1 go read the word from host via
 FIFO
                            0004CD
1825      P:0004C6 P:0004C8 0A8A8A            JCLR    #TRTY,X:DPSR,RD_PCI               ; Bit is set if its a retry
                            0004C4
1826      P:0004C8 P:0004CA 08F48A            MOVEP             #$0400,X:DPSR           ; Clear bit 10 = target retry bit
                            000400
1827      P:0004CA P:0004CC 0A8A84            JCLR    #MARQ,X:DPSR,*                    ; Wait for PCI addressing to be complete
                            0004CA
1828      P:0004CC P:0004CE 0C04C2            JMP     <WRT_ADD
1829   
1830      P:0004CD P:0004CF 08440B  GET_DAT   MOVEP             X:DRXR,X0               ; Read 1st 16 bits of 32 bit word from host 
memory
1831      P:0004CE P:0004D0 08450B            MOVEP             X:DRXR,X1               ; Read 2nd 16 bits of 32 bit word from host 
memory
1832   
1833                                ; note that we now have 4 bytes in X0 and X1.
1834                                ; The 32bit word was in host memory in little endian format
1835                                ; If form LSB --> MSB the bytes are b1, b2, b3, b4 in host memory
1836                                ; in progressing through the HTRX/DRXR FIFO the
1837                                ; bytes end up like this.....
1838                                ; then X0 = $00 b2 b1
Motorola DSP56300 Assembler  Version 6.3.4   07-10-31  14:32:10  PCI_SCUBA_main.asm  Page 38



1839                                ; and  X1 = $00 b4 b3
1840   
1841      P:0004CF P:0004D1 0604A0            REP     #4                                ; increment PCI address by four bytes.
1842      P:0004D0 P:0004D2 000009            INC     B
1843      P:0004D1 P:0004D3 000000            NOP
1844      P:0004D2 P:0004D4 00000C            RTS
1845   
1846                                ;------------------------------------------------------------------------------------
1847                                RESTORE_REGISTERS
1848                                ;-------------------------------------------------------------------------------------
1849   
1850      P:0004D3 P:0004D5 05B239            MOVEC             X:<SV_SR,SR
1851   
1852      P:0004D4 P:0004D6 50A800            MOVE              X:<SV_A0,A0
1853      P:0004D5 P:0004D7 54A900            MOVE              X:<SV_A1,A1
1854      P:0004D6 P:0004D8 52AA00            MOVE              X:<SV_A2,A2
1855   
1856      P:0004D7 P:0004D9 51AB00            MOVE              X:<SV_B0,B0
1857      P:0004D8 P:0004DA 55AC00            MOVE              X:<SV_B1,B1
1858      P:0004D9 P:0004DB 53AD00            MOVE              X:<SV_B2,B2
1859   
1860      P:0004DA P:0004DC 44AE00            MOVE              X:<SV_X0,X0
1861      P:0004DB P:0004DD 45AF00            MOVE              X:<SV_X1,X1
1862   
1863      P:0004DC P:0004DE 46B000            MOVE              X:<SV_Y0,Y0
1864      P:0004DD P:0004DF 47B100            MOVE              X:<SV_Y1,Y1
1865   
1866      P:0004DE P:0004E0 00000C            RTS
1867                                ;------------------------------------------------------------------------------------
1868                                RESTORE_HST_REGISTERS
1869                                ;-------------------------------------------------------------------------------------
1870                                ; B not restored after HST as it now contains address.
1871   
1872      P:0004DF P:0004E1 05B239            MOVEC             X:<SV_SR,SR
1873   
1874      P:0004E0 P:0004E2 50A800            MOVE              X:<SV_A0,A0
1875      P:0004E1 P:0004E3 54A900            MOVE              X:<SV_A1,A1
1876      P:0004E2 P:0004E4 52AA00            MOVE              X:<SV_A2,A2
1877   
1878      P:0004E3 P:0004E5 44AE00            MOVE              X:<SV_X0,X0
1879      P:0004E4 P:0004E6 45AF00            MOVE              X:<SV_X1,X1
1880   
1881      P:0004E5 P:0004E7 46B000            MOVE              X:<SV_Y0,Y0
1882      P:0004E6 P:0004E8 47B100            MOVE              X:<SV_Y1,Y1
1883   
1884      P:0004E7 P:0004E9 00000C            RTS
1885   
1886                                ;-------------------------------------------------------------------------------------
1887                                SAVE_REGISTERS
1888                                ;-------------------------------------------------------------------------------------
1889   
1890      P:0004E8 P:0004EA 053239            MOVEC             SR,X:<SV_SR             ; save status register.  May jump to ISR dur
ing CMP
1891   
1892      P:0004E9 P:0004EB 502800            MOVE              A0,X:<SV_A0
1893      P:0004EA P:0004EC 542900            MOVE              A1,X:<SV_A1
1894      P:0004EB P:0004ED 522A00            MOVE              A2,X:<SV_A2
1895   
1896      P:0004EC P:0004EE 512B00            MOVE              B0,X:<SV_B0
1897      P:0004ED P:0004EF 552C00            MOVE              B1,X:<SV_B1
1898      P:0004EE P:0004F0 532D00            MOVE              B2,X:<SV_B2
1899   
Motorola DSP56300 Assembler  Version 6.3.4   07-10-31  14:32:10  PCI_SCUBA_main.asm  Page 39



1900      P:0004EF P:0004F1 442E00            MOVE              X0,X:<SV_X0
1901      P:0004F0 P:0004F2 452F00            MOVE              X1,X:<SV_X1
1902   
1903      P:0004F1 P:0004F3 463000            MOVE              Y0,X:<SV_Y0
1904      P:0004F2 P:0004F4 473100            MOVE              Y1,X:<SV_Y1
1905   
1906      P:0004F3 P:0004F5 00000C            RTS
1907   
1908   
1909                                ;-----------------------------------------------------------------------------------------------
---
1910                                WRITE_PCI_BURST                                     ; writes 128x16bit words across PCI bus: 256
 bytes (max burst)
1911                                ;-----------------------------------------------------------------------------------------------
-----
1912   
1913      P:0004F4 P:0004F6 200013            CLR     A
1914      P:0004F5 P:0004F7 50F000            MOVE              X:NBURST_YMEM,A0        ; Number of y memory locations to trasfer.
                            000040
1915      P:0004F7 P:0004F9 72F000            MOVE              X:NBURST_YMEM,N2        ; y memory increment
                            000040
1916   
1917      P:0004F9 P:0004FB 0C1D02            ASL     #1,A,A                            ; x2 for bytes
1918      P:0004FA P:0004FC 000000            NOP
1919      P:0004FB P:0004FD 507000            MOVE              A0,X:NBURST_BYTE        ; save # bytes to transfer
                            000041
1920      P:0004FD P:0004FF 0C1C02            ASR     #1,A,A                            ; back to pixels
1921      P:0004FE P:000500 014080            ADD     #0,A                              ; clear carry
1922      P:0004FF P:000501 00000A            DEC     A                                 ; DMA count = number pixels - 1
1923      P:000500 P:000502 014080            ADD     #0,A                              ; clear carry
1924   
1925      P:000501 P:000503 627000            MOVE              R2,X:DSR0               ; Source address for DMA = pixel data
                            FFFFEF
1926      P:000503 P:000505 08F4AE            MOVEP             #DTXM,X:DDR0            ; Destination = PCI master transmitter
                            FFFFCC
1927      P:000505 P:000507 08C82D            MOVEP             A0,X:DCO0               ; DMA Count = # of pixels - 1
1928      P:000506 P:000508 08F4AC  DMA_GO    MOVEP             #$8EFA51,X:DCR0         ; Start DMA with control register DE=1
                            8EFA51
1929      P:000508 P:00050A 204A00            MOVE              (R2)+N2                 ; Increment pixel buffer address for next ti
me
1930   
1931      P:000509 P:00050B 0C1C02            ASR     #1,A,A                            ; npix/2 to get BL (#PCI transfers-1)
1932      P:00050A P:00050C 014080            ADD     #0,A                              ; clear carry
1933      P:00050B P:00050D 0C1D20            ASL     #16,A,A                           ; get BL into top byte
1934      P:00050C P:00050E 000000            NOP
1935      P:00050D P:00050F 507000            MOVE              A0,X:PCI_BL             ; save BL
                            000042
1936   
1937                                PCI_BURST
1938      P:00050F P:000511 0C1890            EXTRACTU #$010010,B,A                     ; Get D31-16 bits only of PCI addr
                            010010
1939      P:000511 P:000513 0C1D30            ASL     #24,A,A                           ; put in A1
1940      P:000512 P:000514 44F000            MOVE              X:PCI_BL,X0
                            000042
1941      P:000514 P:000516 200040            ADD     X0,A                              ; add BL = pci burst size - 1
1942      P:000515 P:000517 000000            NOP                                       ;   = # of pixels / 2 - 1 ...
1943      P:000516 P:000518 547000            MOVE              A1,X:DPMC               ; DPMC = B[31:16] + $BL0000
                            FFFFC7
1944   
1945      P:000518 P:00051A 0C1890            EXTRACTU #$010000,B,A
                            010000
1946      P:00051A P:00051C 0C1D30            ASL     #24,A,A                           ; put in A1
Motorola DSP56300 Assembler  Version 6.3.4   07-10-31  14:32:10  PCI_SCUBA_main.asm  Page 40



1947      P:00051B P:00051D 240700            MOVE              #$070000,X0
1948      P:00051C P:00051E 200040            ADD     X0,A
1949      P:00051D P:00051F 000000            NOP
1950      P:00051E P:000520 08CC08            MOVEP             A1,X:DPAR               ; Initiate writing to the PCI bus
1951      P:00051F P:000521 000000            NOP
1952      P:000520 P:000522 000000            NOP
1953                                WAIT_PCI
1954      P:000521 P:000523 0A8A84            JCLR    #MARQ,X:DPSR,*                    ; Wait until the PCI operation is done
                            000521
1955      P:000523 P:000525 0A8AAE            JSET    #MDT,X:DPSR,WR_OK                 ; If no error go to the next sub-block
                            00052C
1956      P:000525 P:000527 0D0431            JSR     <PCI_ERROR_RECOVERY
1957      P:000526 P:000528 0A700E            BCLR    #PCIBURST_RESTART,X:STATUS        ;  Clear and Test
                            000000
1958      P:000528 P:00052A 0E850F            JCS     <PCI_BURST                        ;  restart burst
1959      P:000529 P:00052B 0A700F            BCLR    #PCIBURST_RESUME,X:STATUS         ;  Clear and Test
                            000000
1960      P:00052B P:00052D 0E8531            JCS     <PCI_RESUME                       ;  resume burst
1961                                WR_OK
1962      P:00052C P:00052E 200013            CLR     A
1963      P:00052D P:00052F 50F000            MOVE              X:NBURST_BYTE,A0        ; get number of bytes transferred
                            000041
1964      P:00052F P:000531 200018            ADD     A,B                               ; update PCI address = + # bytes transferred
1965      P:000530 P:000532 00000C            RTS
1966   
1967                                PCI_RESUME
1968      P:000531 P:000533 200013            CLR     A
1969      P:000532 P:000534 08480A            MOVEP             X:DPSR,A0               ; get dpsr: remaining data count
1970      P:000533 P:000535 0C1C20            ASR     #16,A,A                           ; get remaining words to write into bottom b
yte
1971      P:000534 P:000536 0A8A8F            JCLR    #RDCQ,X:DPSR,NO_RDCQ              ;
                            000537
1972      P:000536 P:000538 000008            INC     A                                 ; BL[5-0] = RDC[5-0] + RDCQ
1973                                NO_RDCQ
1974      P:000537 P:000539 000000            NOP
1975      P:000538 P:00053A 210500            MOVE              A0,X1                   ; save burst length still to go in X1 (=tran
sfers-1)
1976   
1977      P:000539 P:00053B 000008            INC     A                                 ; BL + 1 = number of 32bit words left to tra
nsfer
1978      P:00053A P:00053C 0C1D04            ASL     #2,A,A                            ; x4 = number of bytes left to transfer
1979      P:00053B P:00053D 000000            NOP
1980      P:00053C P:00053E 210400            MOVE              A0,X0                   ; number bytes left to transfer now in x0
1981   
1982      P:00053D P:00053F 56F000            MOVE              X:NBURST_BYTE,A         ; get number of bytes that were supposed to 
have been transferred (A1)
                            000041
1983      P:00053F P:000541 447000            MOVE              X0,X:NBURST_BYTE        ; update #bytes left to burst in resume
                            000041
1984      P:000541 P:000543 200044            SUB     X0,A                              ; subtract #bytes left to get number of byte
s trasferred already (A1)
1985      P:000542 P:000544 0C1C30            ASR     #24,A,A                           ; shift to A0
1986      P:000543 P:000545 014080            ADD     #0,A                              ; clear carry
1987   
1988      P:000544 P:000546 200018            ADD     A,B                               ; add what's been transferred to pci bus add
ress
1989      P:000545 P:000547 014088            ADD     #0,B                              ; clear carry
1990      P:000546 P:000548 20A800            MOVE              X1,A0                   ; get BL (transfers-1)
1991      P:000547 P:000549 0C1D20            ASL     #16,A,A                           ; get BL into top byte
1992      P:000548 P:00054A 000000            NOP
1993      P:000549 P:00054B 507000            MOVE              A0,X:PCI_BL             ; save burst length (top byte)
                            000042
Motorola DSP56300 Assembler  Version 6.3.4   07-10-31  14:32:10  PCI_SCUBA_main.asm  Page 41



1994      P:00054B P:00054D 0C050F            JMP     PCI_BURST                         ; resume burst
1995   
1996   
1997   
1998                                ;------------------------------------------------------------
1999                                WRITE_512_TO_PCI
2000                                ;-------------------------------------------------------------
2001                                ; DMAs 128 x 16bit words to host memory as PCI burst
2002                                ; does x 4 of these (total of 512 x 16bit words written to host memory)
2003                                ;
2004                                ; R2 is used as a pointer to Y:memory address
2005   
2006   
2007      P:00054C P:00054E 3A8000            MOVE              #128,N2                 ; Number of 16bit words per transfer.
2008      P:00054D P:00054F 3C4000            MOVE              #64,N4                  ; NUmber of 32bit words per transfer.
2009   
2010                                ; Make sure its always 512 pixels per loop = 1/2 FIFO
2011      P:00054E P:000550 627000            MOVE              R2,X:DSR0               ; Source address for DMA = pixel data
                            FFFFEF
2012      P:000550 P:000552 08F4AE            MOVEP             #DTXM,X:DDR0            ; Destination = PCI master transmitter
                            FFFFCC
2013      P:000552 P:000554 08F4AD            MOVEP             #>127,X:DCO0            ; DMA Count = # of pixels - 1
                            00007F
2014   
2015                                ; Do loop does 4 x 128 pixel DMA writes = 512.
2016                                ; need to recalculate hi and lo parts of address
2017                                ; for each burst.....Leach code doesn't do this since not
2018                                ; multiple frames...so only needs to inc low part.....
2019   
2020      P:000554 P:000556 060480            DO      #4,WR_BLK0                        ; x # of pixels = 512
                            000577
2021   
2022      P:000556 P:000558 0C1890            EXTRACTU #$010010,B,A                     ; Get D31-16 bits only
                            010010
2023      P:000558 P:00055A 000000            NOP
2024      P:000559 P:00055B 210C00            MOVE              A0,A1                   ; [D31-16] in A1
2025      P:00055A P:00055C 000000            NOP
2026      P:00055B P:00055D 0140C2            ORI     #$3F0000,A                        ; Burst length = # of PCI writes
                            3F0000
2027      P:00055D P:00055F 000000            NOP                                       ;   = # of pixels / 2 - 1 ...$3F = 63
2028      P:00055E P:000560 547000            MOVE              A1,X:DPMC               ; DPMC = B[31:16] + $3F0000
                            FFFFC7
2029   
2030   
2031      P:000560 P:000562 0C1890            EXTRACTU #$010000,B,A
                            010000
2032      P:000562 P:000564 000000            NOP
2033      P:000563 P:000565 210C00            MOVE              A0,A1                   ; Get PCI_ADDR[15:0] into A1[15:0]
2034      P:000564 P:000566 000000            NOP
2035      P:000565 P:000567 0140C2            OR      #$070000,A                        ; A1 gets written to DPAR register
                            070000
2036      P:000567 P:000569 000000            NOP
2037   
2038   
2039      P:000568 P:00056A 08F4AC  AGAIN0    MOVEP             #$8EFA51,X:DCR0         ; Start DMA with control register DE=1
                            8EFA51
2040      P:00056A P:00056C 08CC08            MOVEP             A1,X:DPAR               ; Initiate writing to the PCI bus
2041      P:00056B P:00056D 000000            NOP
2042      P:00056C P:00056E 000000            NOP
2043      P:00056D P:00056F 0A8A84            JCLR    #MARQ,X:DPSR,*                    ; Wait until the PCI operation is done
                            00056D
2044      P:00056F P:000571 0A8AAE            JSET    #MDT,X:DPSR,WR_OK0                ; If no error go to the next sub-block
Motorola DSP56300 Assembler  Version 6.3.4   07-10-31  14:32:10  PCI_SCUBA_main.asm  Page 42



                            000573
2045      P:000571 P:000573 0D0431            JSR     <PCI_ERROR_RECOVERY
2046      P:000572 P:000574 0C0568            JMP     <AGAIN0                           ; Just try to write the sub-block again
2047                                WR_OK0
2048   
2049      P:000573 P:000575 204C13            CLR     A         (R4)+N4                 ; clear A and increment word count
2050      P:000574 P:000576 50F400            MOVE              #>256,A0                ; 2 bytes on pcibus per pixel
                            000100
2051      P:000576 P:000578 640618            ADD     A,B       R4,X:<WORD_COUNT        ; Inc bus address by # of bytes, and save wo
rd count
2052      P:000577 P:000579 204A00            MOVE              (R2)+N2                 ; Pixel buffer address = + # of pixels
2053                                WR_BLK0
2054      P:000578 P:00057A 00000C            RTS
2055   
2056                                ;-----------------------------
2057                                XMT_DLY
2058                                ;-----------------------------
2059                                ; Short delay for reliability
2060   
2061      P:000579 P:00057B 000000            NOP
2062      P:00057A P:00057C 000000            NOP
2063      P:00057B P:00057D 000000            NOP
2064      P:00057C P:00057E 00000C            RTS
2065   
2066                                ;-------------------------------------------------------
2067                                XMT_WD_FIBRE
2068                                ;-----------------------------------------------------
2069                                ; 250 MHz code - Transmit contents of Accumulator A1 to the MCE
2070                                ; we want to send 32bit word in little endian fomat to the host.
2071                                ; i.e. b4b3b2b1 goes b1, b2, b3, b4
2072                                ; currently the bytes are in this order:
2073                                ;  A1 = $00 b2 b1
2074                                ;  A0 = $00 b4 b3
2075                                ;  A = $00 00 b2 b1 00 b4 b3
2076   
2077                                ; This subroutine must take at least 160ns (4 bytes at 25Mbytes/s)
2078   
2079      P:00057D P:00057F 000000            NOP
2080      P:00057E P:000580 000000            NOP
2081   
2082                                ; split up 4 bytes b2, b1, b4, b3
2083   
2084      P:00057F P:000581 0C1D20            ASL     #16,A,A                           ; shift byte b2 into A2
2085      P:000580 P:000582 60F400            MOVE              #$FFF000,R0             ; Memory mapped address of transmitter
                            FFF000
2086   
2087      P:000582 P:000584 214700            MOVE              A2,Y1                   ; byte b2 in Y1
2088   
2089      P:000583 P:000585 0C1D10            ASL     #8,A,A                            ; shift byte b1 into A2
2090      P:000584 P:000586 000000            NOP
2091      P:000585 P:000587 214600            MOVE              A2,Y0                   ; byte b1 in Y0
2092   
2093      P:000586 P:000588 0C1D20            ASL     #16,A,A                           ; shift byte b4 into A2
2094      P:000587 P:000589 000000            NOP
2095      P:000588 P:00058A 214500            MOVE              A2,X1                   ; byte b4 in X1
2096   
2097   
2098      P:000589 P:00058B 0C1D10            ASL     #8,A,A                            ; shift byte b3 into A2
2099      P:00058A P:00058C 000000            NOP
2100      P:00058B P:00058D 214400            MOVE              A2,X0                   ; byte b3 in x0
2101   
2102                                ; transmit b1, b2, b3 ,b4
Motorola DSP56300 Assembler  Version 6.3.4   07-10-31  14:32:10  PCI_SCUBA_main.asm  Page 43



2103   
2104      P:00058C P:00058E 466000            MOVE              Y0,X:(R0)               ; byte b1 - off it goes
2105      P:00058D P:00058F 476000            MOVE              Y1,X:(R0)               ; byte b2 - off it goes
2106      P:00058E P:000590 446000            MOVE              X0,X:(R0)               ; byte b3 - off it goes
2107      P:00058F P:000591 456000            MOVE              X1,X:(R0)               ; byte b4 - off it goes
2108   
2109      P:000590 P:000592 000000            NOP
2110      P:000591 P:000593 000000            NOP
2111      P:000592 P:000594 00000C            RTS
2112   
2113   
2114                                BOOTCODE_END
2115                                 BOOTEND_ADDR
2116      000593                              EQU     @CVI(BOOTCODE_END)
2117   
2118                                PROGRAM_END
2119      000593                    PEND_ADDR EQU     @CVI(PROGRAM_END)
2120                                ;---------------------------------------------
2121   
2122   
2123                                ; --------------------------------------------------------------------
2124                                ; --------------- x memory parameter table ---------------------------
2125                                ; --------------------------------------------------------------------
2126   
2127      X:000000 P:000595                   ORG     X:VAR_TBL,P:
2128   
2129   
2130                                          IF      @SCP("ROM","ROM")                 ; Boot ROM code
2131                                 VAR_TBL_START
2132      000593                              EQU     @LCV(L)-2
2133                                          ENDIF
2134   
2135                                          IF      @SCP("ROM","ONCE")                ; Download via ONCE debugger
2137                                          ENDIF
2138   
2139                                ; -----------------------------------------------
2140                                ; do not move these (X:0 --> x:3)
2141 d    X:000000 P:000595 000000  STATUS    DC      0
2142 d                               FRAME_COUNT
2143 d    X:000001 P:000596 000000            DC      0                                 ; used as a check....... increments for ever
y frame write.....must be cleared by host.
2144 d                               PRE_CORRUPT
2145 d    X:000002 P:000597 000000            DC      0
2146 d    X:000003 P:000598 410200  REV_NUMBER DC     $410200                           ; byte 0 = minor revision #
2147                                                                                    ; byte 1 = mayor revision #
2148                                                                                    ; byte 2 = release Version (ascii letter)
2149 d    X:000004 P:000599 1F0A07  REV_DATA  DC      $1F0A07                           ; data: day-month-year
2150 d    X:000005 P:00059A E8681F  P_CHECKSUM DC     $e8681f                           ;**** DO NOT CHANGE
2151                                ; -------------------------------------------------
2152 d    X:000006 P:00059B 000000  WORD_COUNT DC     0                                 ; word count.  Number of words successfully 
writen to host in last packet.
2153 d    X:000007 P:00059C 000000  NUM_DUMPED DC     0                                 ; number of words (16-bit) dumped to Y memor
y (512) after an HST timeout.
2154                                ; ----------------------------------------------------------------------------------------------
----------------
2155   
2156 d    X:000008 P:00059D 000000  DRXR_WD1  DC      0
2157 d    X:000009 P:00059E 000000  DRXR_WD2  DC      0
2158 d    X:00000A P:00059F 000000  DRXR_WD3  DC      0
2159 d    X:00000B P:0005A0 000000  DRXR_WD4  DC      0
2160 d    X:00000C P:0005A1 000000  DTXS_WD1  DC      0
2161 d    X:00000D P:0005A2 000000  DTXS_WD2  DC      0
Motorola DSP56300 Assembler  Version 6.3.4   07-10-31  14:32:10  PCI_SCUBA_main.asm  Page 44



2162 d    X:00000E P:0005A3 000000  DTXS_WD3  DC      0
2163 d    X:00000F P:0005A4 000000  DTXS_WD4  DC      0
2164   
2165 d    X:000010 P:0005A5 000000  PCI_WD1_1 DC      0
2166 d    X:000011 P:0005A6 000000  PCI_WD1_2 DC      0
2167 d    X:000012 P:0005A7 000000  PCI_WD2_1 DC      0
2168 d    X:000013 P:0005A8 000000  PCI_WD2_2 DC      0
2169 d    X:000014 P:0005A9 000000  PCI_WD3_1 DC      0
2170 d    X:000015 P:0005AA 000000  PCI_WD3_2 DC      0
2171 d    X:000016 P:0005AB 000000  PCI_WD4_1 DC      0
2172 d    X:000017 P:0005AC 000000  PCI_WD4_2 DC      0
2173 d    X:000018 P:0005AD 000000  PCI_WD5_1 DC      0
2174 d    X:000019 P:0005AE 000000  PCI_WD5_2 DC      0
2175 d    X:00001A P:0005AF 000000  PCI_WD6_1 DC      0
2176 d    X:00001B P:0005B0 000000  PCI_WD6_2 DC      0
2177   
2178   
2179 d    X:00001C P:0005B1 000000  HEAD_W1_1 DC      0
2180 d    X:00001D P:0005B2 000000  HEAD_W1_0 DC      0
2181 d    X:00001E P:0005B3 000000  HEAD_W2_1 DC      0
2182 d    X:00001F P:0005B4 000000  HEAD_W2_0 DC      0
2183 d    X:000020 P:0005B5 000000  HEAD_W3_1 DC      0
2184 d    X:000021 P:0005B6 000000  HEAD_W3_0 DC      0
2185 d    X:000022 P:0005B7 000000  HEAD_W4_1 DC      0
2186 d    X:000023 P:0005B8 000000  HEAD_W4_0 DC      0
2187   
2188   
2189 d    X:000024 P:0005B9 000000  REP_WD1   DC      0
2190 d    X:000025 P:0005BA 000000  REP_WD2   DC      0
2191 d    X:000026 P:0005BB 000000  REP_WD3   DC      0
2192 d    X:000027 P:0005BC 000000  REP_WD4   DC      0
2193   
2194 d    X:000028 P:0005BD 000000  SV_A0     DC      0
2195 d    X:000029 P:0005BE 000000  SV_A1     DC      0
2196 d    X:00002A P:0005BF 000000  SV_A2     DC      0
2197 d    X:00002B P:0005C0 000000  SV_B0     DC      0
2198 d    X:00002C P:0005C1 000000  SV_B1     DC      0
2199 d    X:00002D P:0005C2 000000  SV_B2     DC      0
2200 d    X:00002E P:0005C3 000000  SV_X0     DC      0
2201 d    X:00002F P:0005C4 000000  SV_X1     DC      0
2202 d    X:000030 P:0005C5 000000  SV_Y0     DC      0
2203 d    X:000031 P:0005C6 000000  SV_Y1     DC      0
2204   
2205 d    X:000032 P:0005C7 000000  SV_SR     DC      0                                 ; stauts register save.
2206   
2207   
2208   
2209 d                               PACKET_SIZE_LOW
2210 d    X:000033 P:0005C8 000000            DC      0
2211 d                               PACKET_SIZE_HIH
2212 d    X:000034 P:0005C9 000000            DC      0
2213   
2214 d    X:000035 P:0005CA 00A5A5  PREAMB1   DC      $A5A5                             ; pramble 16-bit word....2 of which make up 
first preamble 32bit word
2215 d    X:000036 P:0005CB 005A5A  PREAMB2   DC      $5A5A                             ; preamble 16-bit word....2 of which make up
 second preamble 32bit word
2216 d    X:000037 P:0005CC 004441  DATA_WD   DC      $4441                             ; "DA"
2217 d    X:000038 P:0005CD 005250  REPLY_WD  DC      $5250                             ; "RP"
2218   
2219 d                               NMAX_BURSTS
2220 d    X:000039 P:0005CE 000000            DC      0
2221 d                               TOTAL_BUFFS
Motorola DSP56300 Assembler  Version 6.3.4   07-10-31  14:32:10  PCI_SCUBA_main.asm  Page 45



2222 d    X:00003A P:0005CF 000000            DC      0                                 ; total number of 512 buffers in packet
2223 d                               LEFT_TO_READ
2224 d    X:00003B P:0005D0 000000            DC      0                                 ; number of words (16 bit) left to read afte
r last 512 buffer
2225 d                               LEFT_TO_WRITE
2226 d    X:00003C P:0005D1 000000            DC      0                                 ; number of woreds (32 bit) to write to host
 i.e. half of those left over read
2227 d                               NUM_LEFTOVER_BLOCKS
2228 d    X:00003D P:0005D2 000000            DC      0                                 ; small block DMA burst transfer
2229   
2230 d                               DATA_DLY_VAL
2231 d    X:00003E P:0005D3 000000            DC      0                                 ; data delay value..  Delay added to first f
rame received after GO command
2232 d    X:00003F P:0005D4 000200  CONSTORE  DC      $200
2233   
2234 d                               NBURST_YMEM
2235 d    X:000040 P:0005D5 000000            DC      0                                 ; number of y memory locations in DMA transf
er (to PCI burst)
2236 d                               NBURST_BYTE
2237 d    X:000041 P:0005D6 000000            DC      0                                 ; number of bytes in PCI burst
2238 d    X:000042 P:0005D7 000000  PCI_BL    DC      0                                 ; holds PCI "burst length" in top byte (= wo
rd transfers -1)
2239   
2240 d    X:000043 P:0005D8 000000  ZERO      DC      0
2241 d    X:000044 P:0005D9 000001  ONE       DC      1
2242 d    X:000045 P:0005DA 000004  FOUR      DC      4
2243   
2244 d    X:000046 P:0005DB 000000  FILL46    DC      0
2245   
2246                                ; pci error counts
2247 d    X:000047 P:0005DC 000000  ECOUNT_PCI DC     0                                 ; total count
2248 d                               ECOUNT_TRTY
2249 d    X:000048 P:0005DD 000000            DC      0                                 ; PCI target retry count
2250 d    X:000049 P:0005DE 000000  ECOUNT_TO DC      0                                 ; PCI time out count
2251 d                               ECOUNT_TDIS
2252 d    X:00004A P:0005DF 000000            DC      0                                 ; PCI target disconnect count
2253 d    X:00004B P:0005E0 000000  ECOUNT_TAB DC     0                                 ; PCI target abort count
2254 d    X:00004C P:0005E1 000000  ECOUNT_MAB DC     0                                 ; PCI master abort count
2255 d                               ECOUNT_DPER
2256 d    X:00004D P:0005E2 000000            DC      0                                 ; PCI data parity error count
2257 d                               ECOUNT_APER
2258 d    X:00004E P:0005E3 000000            DC      0                                 ; PCI address parity error count
2259   
2260                                ;----------------------------------------------------------
2261   
2262   
2263   
2264                                          IF      @SCP("ROM","ROM")                 ; Boot ROM code
2265                                 VAR_TBL_END
2266      0005E2                              EQU     @LCV(L)-2
2267                                          ENDIF
2268   
2269                                          IF      @SCP("ROM","ONCE")                ; Download via ONCE debugger
2271                                          ENDIF
2272   
2273                                 VAR_TBL_LENGTH
2274      00004F                              EQU     VAR_TBL_END-VAR_TBL_START
2275   
2276   
2277                                          IF      @CVS(N,*)>=APPLICATION
2279                                          ENDIF
2280   
Motorola DSP56300 Assembler  Version 6.3.4   07-10-31  14:32:10  PCI_SCUBA_main.asm  Page 46



2281   
2282                                ;--------------------------------------------
2283                                ; APPLICATION AREA
2284                                ;---------------------------------------------
2285                                          IF      @SCP("ROM","ROM")                 ; Download via ONCE debugger
2286      P:000800 P:000802                   ORG     P:APPLICATION,P:APPLICATION+2
2287                                          ENDIF
2288   
2289                                          IF      @SCP("ROM","ONCE")                ; Download via ONCE debugger
2291                                          ENDIF
2292   
2293                                ; starts with no application loaded
2294                                ; so just reply with an error if we get a GOA command
2295      P:000800 P:000802 44F400            MOVE              #'REP',X0
                            524550
2296      P:000802 P:000804 440C00            MOVE              X0,X:<DTXS_WD1          ; REPly
2297      P:000803 P:000805 44F400            MOVE              #'GOA',X0
                            474F41
2298      P:000805 P:000807 440D00            MOVE              X0,X:<DTXS_WD2          ; echo command sent
2299      P:000806 P:000808 44F400            MOVE              #'ERR',X0
                            455252
2300      P:000808 P:00080A 440E00            MOVE              X0,X:<DTXS_WD3          ; No Application Loaded
2301      P:000809 P:00080B 44F400            MOVE              #'NAL',X0
                            4E414C
2302      P:00080B P:00080D 440F00            MOVE              X0,X:<DTXS_WD4          ; write to PCI memory error;
2303      P:00080C P:00080E 0D04D3            JSR     <RESTORE_REGISTERS
2304      P:00080D P:00080F 0D048B            JSR     <PCI_MESSAGE_TO_HOST
2305      P:00080E P:000810 0A0000            BCLR    #APPLICATION_LOADED,X:<STATUS
2306      P:00080F P:000811 0C0173            JMP     PACKET_IN
2307   
2308   
2309      000812                    END_ADR   EQU     @LCV(L)                           ; End address of P: code written to ROM
2310   
**** 2311 [PCI_SCUBA_build.asm 25]:  Build is complete
2311                                          MSG     ' Build is complete'
2312   
2313   
2314   

0    Errors
0    Warnings


