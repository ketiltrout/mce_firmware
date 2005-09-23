Motorola DSP56300 Assembler  Version 6.3.4   05-09-23  15:59:30  PCI_SCUBA_build.asm  Page 1



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
12                                 ONCE=EEPROM => EEPROM CODE
13                                 ONCE=ONCE => ONCE CODE
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
33                                 ONCE=0 => EEPROM CODE
34                                 ONCE=1 => ONCE CODE
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
Motorola DSP56300 Assembler  Version 6.3.4   05-09-23  15:59:30  PCI_SCUBA_header.asm  Page 2



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
74        000004           INTA_FLAG EQU     4                                 ; used for interupt handshaking with host
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
97     
98     
99     
100    
101    
102    
103                        ; Various addressing control registers
104       FFFFFB           BCR       EQU     $FFFFFB                           ; Bus Control Register
105       FFFFFA           DCR       EQU     $FFFFFA                           ; DRAM Control Register
106       FFFFF9           AAR0      EQU     $FFFFF9                           ; Address Attribute Register, channel 0
107       FFFFF8           AAR1      EQU     $FFFFF8                           ; Address Attribute Register, channel 1
108       FFFFF7           AAR2      EQU     $FFFFF7                           ; Address Attribute Register, channel 2
109       FFFFF6           AAR3      EQU     $FFFFF6                           ; Address Attribute Register, channel 3
110       FFFFFD           PCTL      EQU     $FFFFFD                           ; PLL control register
111       FFFFFE           IPRP      EQU     $FFFFFE                           ; Interrupt Priority register - Peripheral
112       FFFFFF           IPRC      EQU     $FFFFFF                           ; Interrupt Priority register - Core
113    
114                        ; PCI control register
115       FFFFCD           DTXS      EQU     $FFFFCD                           ; DSP Slave transmit data FIFO
Motorola DSP56300 Assembler  Version 6.3.4   05-09-23  15:59:30  PCI_SCUBA_header.asm  Page 3



116       FFFFCC           DTXM      EQU     $FFFFCC                           ; DSP Master transmit data FIFO
117       FFFFCB           DRXR      EQU     $FFFFCB                           ; DSP Receive data FIFO
118       FFFFCA           DPSR      EQU     $FFFFCA                           ; DSP PCI Status Register
119       FFFFC9           DSR       EQU     $FFFFC9                           ; DSP Status Register
120       FFFFC8           DPAR      EQU     $FFFFC8                           ; DSP PCI Address Register
121       FFFFC7           DPMC      EQU     $FFFFC7                           ; DSP PCI Master Control Register
122       FFFFC6           DPCR      EQU     $FFFFC6                           ; DSP PCI Control Register
123       FFFFC5           DCTR      EQU     $FFFFC5                           ; DSP Control Register
124    
125                        ; Port E is the Synchronous Communications Interface (SCI) port
126       FFFF9F           PCRE      EQU     $FFFF9F                           ; Port Control Register
127       FFFF9E           PRRE      EQU     $FFFF9E                           ; Port Direction Register
128       FFFF9D           PDRE      EQU     $FFFF9D                           ; Port Data Register
129    
130                        ; Various PCI register bit equates
131       000001           STRQ      EQU     1                                 ; Slave transmit data request (DSR)
132       000002           SRRQ      EQU     2                                 ; Slave receive data request (DSR)
133       000017           HACT      EQU     23                                ; Host active, low true (DSR)
134       000001           MTRQ      EQU     1                                 ; Set whem master transmitter is not full (DPSR)
135       000004           MARQ      EQU     4                                 ; Master address request (DPSR)
136       000002           MRRQ      EQU     2                                 ; Master Receive Request (DPSR)
137       00000A           TRTY      EQU     10                                ; PCI Target Retry (DPSR)
138    
139       000005           APER      EQU     5                                 ; Address parity error
140       000006           DPER      EQU     6                                 ; Data parity error
141       000007           MAB       EQU     7                                 ; Master Abort
142       000008           TAB       EQU     8                                 ; Target Abort
143       000009           TDIS      EQU     9                                 ; Target Disconnect
144       00000B           TO        EQU     11                                ; Timeout
145       00000E           MDT       EQU     14                                ; Master Data Transfer complete
146       000002           SCLK      EQU     2                                 ; SCLK = transmitter special code
147    
148                        ; bits in DPMC
149    
150       000017           FC1       EQU     23
151       000016           FC0       EQU     22
152    
153    
154                        ; DMA register definitions
155       FFFFEF           DSR0      EQU     $FFFFEF                           ; Source address register
156       FFFFEE           DDR0      EQU     $FFFFEE                           ; Destination address register
157       FFFFED           DCO0      EQU     $FFFFED                           ; Counter register
158       FFFFEC           DCR0      EQU     $FFFFEC                           ; Control register
159    
160                        ; The DCTR host flags are written by the DSP and read by PCI host
161       000003           DCTR_RPLY EQU     3                                 ; Set after reply
162       000004           DCTR_BUF0 EQU     4                                 ; Set after buffer 0 is written to
163       000005           DCTR_BUF1 EQU     5                                 ; Set after buffer 1 is written to
164       000006           INTA      EQU     6                                 ; Request PCI interrupt
165    
166                        ; The DSR host flags are written by the PCI host and read by the DSP
167       000004           DSR_BUF0  EQU     4                                 ; PCI host sets this when copying buffer 0
168       000005           DSR_BUF1  EQU     5                                 ; PCI host sets this when copying buffer 1
169    
170                        ; DPCR bit definitions
171       00000E           CLRT      EQU     14                                ; Clear transmitter
172       000012           MACE      EQU     18                                ; Master access counter enable
173       000015           IAE       EQU     21                                ; Insert Address Enable
174    
175                        ; Addresses of ESSI port
176       FFFFBC           TX00      EQU     $FFFFBC                           ; Transmit Data Register 0
177       FFFFB7           SSISR0    EQU     $FFFFB7                           ; Status Register
Motorola DSP56300 Assembler  Version 6.3.4   05-09-23  15:59:30  PCI_SCUBA_header.asm  Page 4



178       FFFFB6           CRB0      EQU     $FFFFB6                           ; Control Register B
179       FFFFB5           CRA0      EQU     $FFFFB5                           ; Control Register A
180    
181                        ; SSI Control Register A Bit Flags
182       000006           TDE       EQU     6                                 ; Set when transmitter data register is empty
183    
184                        ; Miscellaneous addresses
185       FFFFFF           RDFIFO    EQU     $FFFFFF                           ; Read the FIFO for incoming fiber optic data
186       FFFF8F           TCSR0     EQU     $FFFF8F                           ; Triper timer control and status register 0
187       FFFF8B           TCSR1     EQU     $FFFF8B                           ; Triper timer control and status register 1
188       FFFF87           TCSR2     EQU     $FFFF87                           ; Triper timer control and status register 2
189    
190                        ;***************************************************************
191                        ; Phase Locked Loop initialization
192       050003           PLL_INIT  EQU     $050003                           ; PLL = 25 MHz x 4 = 100 MHz
193                        ;****************************************************************
194    
195                        ; Port C is Enhanced Synchronous Serial Port 0
196       FFFFBF           PCRC      EQU     $FFFFBF                           ; Port C Control Register
197       FFFFBE           PRRC      EQU     $FFFFBE                           ; Port C Data direction Register
198       FFFFBD           PDRC      EQU     $FFFFBD                           ; Port C GPIO Data Register
199    
200                        ; Port D is Enhanced Synchronous Serial Port 1
201       FFFFAF           PCRD      EQU     $FFFFAF                           ; Port D Control Register
202       FFFFAE           PRRD      EQU     $FFFFAE                           ; Port D Data direction Register
203       FFFFAD           PDRD      EQU     $FFFFAD                           ; Port D GPIO Data Register
204    
205                        ; Bit number definitions of GPIO pins on Port C
206       000002           ROM_FIFO  EQU     2                                 ; Select ROM or FIFO accesses for AA1
207    
208                        ; Bit number definitions of GPIO pins on Port D
209       000000           EF        EQU     0                                 ; FIFO Empty flag, low true
210       000001           HF        EQU     1                                 ; FIFO half full flag, low true
211       000002           RS        EQU     2                                 ; FIFO reset signal, low true
212       000003           FSYNC     EQU     3                                 ; High during image transmission
213       000004           AUX1      EQU     4                                 ; enable/disable byte swapping
214       000005           WRFIFO    EQU     5                                 ; Low true if FIFO is being written to
215    
216    
217                        ; Errors - self test application
218    
219       000000           Y_MEM_ER  EQU     0                                 ; y memory corrupted
220       000001           X_MEM_ER  EQU     1                                 ; x memory corrupted
221       000002           P_MEM_ER  EQU     2                                 ; p memory corrupted
222       000003           FO_EMPTY  EQU     3                                 ; no transmitted data in FIFO
223    
224       000004           FO_OVER   EQU     4                                 ; too much data received
225       000005           FO_UNDER  EQU     5                                 ; not enough data receiv
226       000006           FO_RX_ER  EQU     6                                 ; received data in FIFO incorrect.
227       000007           DEBUG     EQU     7                                 ; debug bit
228    
229    
230    
231    
232                                  INCLUDE 'PCI_SCUBA_initialisation.asm'
233                              COMMENT *
234    
235                        This is the code which is executed first after power-up etc.
236                        It sets all the internal registers to their operating values,
237                        sets up the ISR vectors and inialises the hardware etc.
238    
239                        Project:     SCUBA 2
Motorola DSP56300 Assembler  Version 6.3.4   05-09-23  15:59:30  PCI_SCUBA_initialisation.asm  Page 5



240                        Author:      DAVID ATKINSON
241                        Target:      250MHz SDSU PCI card - DSP56301
242                        Controller:  For use with SCUBA 2 Multichannel Electronics
243    
244                        Assembler directives:
245                                ONCE=EEPROM => EEPROM CODE
246                                ONCE=ONCE => ONCE CODE
247    
248                                *
249                                  PAGE    132                               ; Printronix page width - 132 columns
250                                  OPT     CEX                               ; print DC evaluations
251    
**** 252 [PCI_SCUBA_initialisation.asm 20]:  INCLUDE PCI_initialisation.asm HERE  
252                                  MSG     ' INCLUDE PCI_initialisation.asm HERE  '
253    
254                        ; The EEPROM boot code expects first to read 3 bytes specifying the number of
255                        ; program words, then 3 bytes specifying the address to start loading the
256                        ; program words and then 3 bytes for each program word to be loaded.
257                        ; The program words will be condensed into 24 bit words and stored in contiguous
258                        ; PRAM memory starting at the specified starting address. Program execution
259                        ; starts from the same address where loading started.
260    
261                        ; Special address for two words for the DSP to bootstrap code from the EEPROM
262                                  IF      @SCP("ONCE","ROM")                ; Boot from ROM on power-on
269                                  ENDIF
270    
271    
272                        ; This allows for the DSP to be loaded from the ONCE port via the WIGGLER
273                        ; command converter
274                                  IF      @SCP("ONCE","ONCE")               ; Download via ONCE debugger
275       P:000000 P:000000                   ORG     P:0,P:0
276       P:000000 P:000000 0C0100  INIT      JMP     <START
277       P:000001 P:000001 000000            NOP
278                                           ENDIF
279    
280                                 ; Vectored interrupt table, addresses at the beginning are reserved
281  d    P:000002 P:000002 000000            DC      0,0,0,0,0,0,0,0,0,0,0,0,0,0       ; $02-$0f Reserved
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
282  d    P:000010 P:000010 000000            DC      0,0                               ; $10-$13 Reserved
     d                      000000
283    
284                                 ; FIFO HF* flag interrupt vector is here at $12 - this is connected to the
285                                 ; IRQB* interrupt line so its ISR vector must be here
286  d    P:000012 P:000012 000000            DC      0,0                               ; $was ld scatter routine ...HF*
     d                      000000
287    
288                                 ; a software reset button on the font panel of the card is connected to the IRQC*
289                                 ; line which if pressed causes the DSP to jump to an ISR which causes the program
290                                 ; counter to the beginning of the program INIT and sets the stack pointer to TOP.
291       P:000014 P:000014 0BF080            JSR     CLEAN_UP_PCI                      ; $14 - Software reset switch
Motorola DSP56300 Assembler  Version 6.3.4   05-09-23  15:59:30  PCI_SCUBA_initialisation.asm  Page 6



                            000207
292    
293  d    P:000016 P:000016 000000            DC      0,0,0,0,0,0,0,0,0,0,0,0           ; Reserved interrupts
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
294  d    P:000022 P:000022 000000            DC      0,0,0,0,0,0,0,0,0,0,0,0,0,0
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
295    
296                                 ; Now we're at P:$30, where some unused vector addresses are located
297                                 ; This is ROM only code that is only executed once on power-up when the
298                                 ; ROM code is downloaded. It is skipped over on OnCE downloads.
299    
300                                 ; A few seconds after power up on the Host, it interrogates the PCI bus to find
301                                 ; out what boards are installed and configures this PCI board. The EEPROM booting
302                                 ; procedure ends with program execution  starting at P:$0 where the EEPROM has
303                                 ; inserted a JMP INIT_PCI instruction. This routine sets the PLL paramter and
304                                 ; does a self configuration and software reset of the PCI controller in the DSP.
305                                 ; After configuring the PCI controller the DSP program overwrites the instruction
306                                 ; at P:$0 with a new JMP START to skip over the INIT_PCI routine. The program at
307                                 ; START address begins configuring the DSP and processing commands.
308                                 ; Similarly the ONCE option places a JMP START at P:$0 to skip over the
309                                 ; INIT_PCI routine. If this routine where executed after the host computer had booted
310                                 ; it would cause it to crash since the host computer would overwrite the
311                                 ; configuration space with its own values and doesn't tolerate foreign values.
312    
313                                 ; Initialize the PLL - phase locked loop
314                                 INIT_PCI
315       P:000030 P:000030 08F4BD            MOVEP             #PLL_INIT,X:PCTL        ; Initialize PLL
                            050003
316       P:000032 P:000032 000000            NOP
317    
318                                 ; Program the PCI self-configuration registers
319       P:000033 P:000033 240000            MOVE              #0,X0
320       P:000034 P:000034 08F485            MOVEP             #$500000,X:DCTR         ; Set self-configuration mode
                            500000
321       P:000036 P:000036 0604A0            REP     #4
322       P:000037 P:000037 08C408            MOVEP             X0,X:DPAR               ; Dummy writes to configuration space
323       P:000038 P:000038 08F487            MOVEP             #>$0000,X:DPMC          ; Subsystem ID
                            000000
324       P:00003A P:00003A 08F488            MOVEP             #>$0000,X:DPAR          ; Subsystem Vendor ID
                            000000
Motorola DSP56300 Assembler  Version 6.3.4   05-09-23  15:59:30  PCI_SCUBA_initialisation.asm  Page 7



325    
326                                 ; PCI Personal reset
327       P:00003C P:00003C 08C405            MOVEP             X0,X:DCTR               ; Personal software reset
328       P:00003D P:00003D 000000            NOP
329       P:00003E P:00003E 000000            NOP
330       P:00003F P:00003F 0A89B7            JSET    #HACT,X:DSR,*                     ; Test for personal reset completion
                            00003F
331       P:000041 P:000041 07F084            MOVE              P:(*+3),X0              ; Trick to write "JMP <START" to P:0
                            000044
332       P:000043 P:000043 070004            MOVE              X0,P:(0)
333       P:000044 P:000044 0C0100            JMP     <START
334    
335  d    P:000045 P:000045 000000            DC      0,0,0,0,0,0,0,0,0,0,0,0           ; Filler
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
336  d    P:000051 P:000051 000000            DC      0,0,0,0,0,0,0,0,0,0,0,0           ; Filler
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
337  d    P:00005D P:00005D 000000            DC      0,0,0,0,0,0,0,0,0,0,0,0           ; $60-$71 Reserved PCI
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
338    
339                                 ;**************************************************************************
340                                 ; Check for program space overwriting of ISR starting at P:$72
341                                           IF      @CVS(N,*)>$71
343                                           ENDIF
344    
345                                 ;       ORG     P:$72,P:$72
346       P:000072 P:000074                   ORG     P:$72,P:$74
347    
348                                 ; This allows for the DSP to be loaded from the ONCE port via the WIGGLER
349                                 ; command converter
350                                           IF      @SCP("ONCE","ONCE")               ; Download via ONCE debugger
351       P:000072 P:000072                   ORG     P:$72,P:$72
352                                           ENDIF
Motorola DSP56300 Assembler  Version 6.3.4   05-09-23  15:59:30  PCI_SCUBA_initialisation.asm  Page 8



353    
354    
355                                 ;**************************************************************************
356    
357                                 ; Three non-maskable fast interrupt service routines for clearing PCI interrupts
358                                 ; The Host will use these to clear the INTA* after it has serviced the interrupt
359                                 ; which had been generated by the PCI board.
360    
361       P:000072 P:000072 0A8506            BCLR    #INTA,X:DCTR                      ; $72/3 - Clear PCI interrupt
362       P:000073 P:000073 000000            NOP
363    
364       P:000074 P:000074 0A0004            BCLR    #INTA_FLAG,X:<STATUS              ; $74/5 - Clear PCI interrupt
365       P:000075 P:000075 000000            NOP                                       ; needs to be fast addressing <
366    
367       P:000076 P:000076 0A0022            BSET    #FATAL_ERROR,X:<STATUS            ; $76/7 - driver informing us of PCI_MESSAGE
_TO_HOST error
368       P:000077 P:000077 000000            NOP
369    
370                                 ; Interrupt locations for 7 available commands on PCI board
371                                 ; Each JSR takes up 2 locations in the table
372       P:000078 P:000078 0BF080            JSR     WRITE_MEMORY                      ; $78
                            000368
373       P:00007A P:00007A 0BF080            JSR     READ_MEMORY                       ; $7A
                            000213
374       P:00007C P:00007C 0BF080            JSR     START_APPLICATION                 ; $7C
                            000328
375       P:00007E P:00007E 0BF080            JSR     STOP_APPLICATION                  ; $7E
                            000340
376                                 ; software reset is the same as cleaning up the PCI - use same routine
377                                 ; when HOST does a RESET then this routine is run
378       P:000080 P:000080 0BF080            JSR     SOFTWARE_RESET                    ; $80
                            0002F4
379       P:000082 P:000082 0BF080            JSR     SEND_PACKET_TO_CONTROLLER         ; $82
                            000290
380       P:000084 P:000084 0BF080            JSR     SEND_PACKET_TO_HOST               ; $84
                            0002D4
381       P:000086 P:000086 0BF080            JSR     RESET_CONTROLLER                  ; $86
                            000252
382    
383    
384                                 ; ***********************************************************************
385                                 ; For now have boot code starting from P:$100
386                                 ; just to make debugging tidier etc.
387    
388       P:000100 P:000102                   ORG     P:$100,P:$102
389    
390                                 ; This allows for the DSP to be loaded from the ONCE port via the WIGGLER
391                                 ; command converter
392                                           IF      @SCP("ONCE","ONCE")               ; Download via ONCE debugger
393       P:000100 P:000100                   ORG     P:$100,P:$100
394                                           ENDIF
395                                 ; ***********************************************************************
396    
397    
398    
399                                 ; ******************************************************************
400                                 ;
401                                 ;       AA0 = RDFIFO* of incoming fiber optic data
402                                 ;       AA1 = EEPROM access
403                                 ;       AA2 = DRAM access
404                                 ;       AA3 = output to parallel data connector, for a video pixel clock
405                                 ;       $FFxxxx = Write to fiber optic transmitter
Motorola DSP56300 Assembler  Version 6.3.4   05-09-23  15:59:30  PCI_SCUBA_initialisation.asm  Page 9



406                                 ;
407                                 ; ******************************************************************
408    
409    
410       P:000100 P:000100 08F487  START     MOVEP             #>$000001,X:DPMC
                            000001
411       P:000102 P:000102 0A8534            BSET    #20,X:DCTR                        ; HI32 mode = 1 => PCI
412       P:000103 P:000103 0A8515            BCLR    #21,X:DCTR
413       P:000104 P:000104 0A8516            BCLR    #22,X:DCTR
414       P:000105 P:000105 000000            NOP
415       P:000106 P:000106 0A8632            BSET    #MACE,X:DPCR                      ; Master access counter enable
416       P:000107 P:000107 000000            NOP
417    
418    
419                                 ;       BSET    #IAE,X:DPCR             ; Insert PCI address before data
420                                 ; Unlike Bob Leach's code
421                                 ; we don't want IAE set in DPCR or else  data read by DSP from
422                                 ; DRXR FIFO will contain address of data as well as data...
423    
424       P:000108 P:000108 000000            NOP                                       ; End of PCI programming
425    
426    
427                                 ; Set operation mode register OMR to normal expanded
428       P:000109 P:000109 0500BA            MOVEC             #$0000,OMR              ; Operating Mode Register = Normal Expanded
429       P:00010A P:00010A 0500BB            MOVEC             #0,SP                   ; Reset the Stack Pointer SP
430    
431                                 ; Program the serial port ESSI0 = Port C for serial transmission to
432                                 ;   the timing board
433       P:00010B P:00010B 07F43F            MOVEP             #>0,X:PCRC              ; Software reset of ESSI0
                            000000
434                                 ;**********************************************************************
435       P:00010D P:00010D 07F435            MOVEP             #$00080B,X:CRA0         ; Divide 100.0 MHz by 24 to get 4.17 MHz
                            00080B
436                                                                                     ; DC0-CD4 = 0 for non-network operation
437                                                                                     ; WL0-WL2 = ALC = 0 for 2-bit data words
438                                                                                     ; SSC1 = 0 for SC1 not used
439                                 ;************************************************************************
440       P:00010F P:00010F 07F436            MOVEP             #$010120,X:CRB0         ; SCKD = 1 for internally generated clock
                            010120
441                                                                                     ; SHFD = 0 for MSB shifted first
442                                                                                     ; CKP = 0 for rising clock edge transitions
443                                                                                     ; TE0 = 1 to enable transmitter #0
444                                                                                     ; MOD = 0 for normal, non-networked mode
445                                                                                     ; FSL1 = 1, FSL0 = 0 for on-demand transmit
446       P:000111 P:000111 07F43F            MOVEP             #%101000,X:PCRC         ; Control Register (0 for GPIO, 1 for ESSI)
                            000028
447                                                                                     ; Set SCK0 = P3, STD0 = P5 to ESSI0
448                                 ;********************************************************************************
449       P:000113 P:000113 07F43E            MOVEP             #%111100,X:PRRC         ; Data Direction Register (0 for In, 1 for O
ut)
                            00003C
450       P:000115 P:000115 07F43D            MOVEP             #%000000,X:PDRC         ; Data Register - AUX3 = i/p, AUX1 not used
                            000000
451                                 ;***********************************************************************************
452                                 ; 250MHz
453                                 ; Conversion from software bits to schematic labels for Port C and D
454                                 ;       PC0 = SC00 = AUX3               PD0 = SC10 = EF*
455                                 ;       PC1 = SC01 = A/B* = input       PD1 = SC11 = HF*
456                                 ;       PC2 = SC02 = No connect         PD2 = SC12 = RS*
457                                 ;       PC3 = SCK0 = No connect         PD3 = SCK1 = NWRFIFO*
458                                 ;       PC4 = SRD0 = AUX1               PD4 = SRD1 = No connect (** in 50Mhz this was MODE selec
t for 16 or 32 bit FO)
Motorola DSP56300 Assembler  Version 6.3.4   05-09-23  15:59:30  PCI_SCUBA_initialisation.asm  Page 10



459                                 ;       PC5 = STD0 = No connect         PD5 = STD1 = WRFIFO*
460                                 ; ***********************************************************************************
461    
462    
463                                 ; ****************************************************************************
464                                 ; Program the serial port ESSI1 = Port D for general purpose I/O (GPIO)
465    
466       P:000117 P:000117 07F42F            MOVEP             #%000000,X:PCRD         ; Control Register (0 for GPIO, 1 for ESSI)
                            000000
467       P:000119 P:000119 07F42E            MOVEP             #%011100,X:PRRD         ; Data Direction Register (0 for In, 1 for O
ut)
                            00001C
468       P:00011B P:00011B 07F42D            MOVEP             #%011000,X:PDRD         ; Data Register - Pulse RS* low
                            000018
469       P:00011D P:00011D 060AA0            REP     #10
470       P:00011E P:00011E 000000            NOP
471       P:00011F P:00011F 07F42D            MOVEP             #%011100,X:PDRD         ; Data Register - Pulse RS* high
                            00001C
472    
473    
474                                 ; Program the SCI port to benign values
475       P:000121 P:000121 07F41F            MOVEP             #%000,X:PCRE            ; Port Control Register = GPIO
                            000000
476       P:000123 P:000123 07F41E            MOVEP             #%110,X:PRRE            ; Port Direction Register (0 = Input)
                            000006
477       P:000125 P:000125 07F41D            MOVEP             #%010,X:PDRE            ; Port Data Register
                            000002
478                                 ;       PE0 = RXD
479                                 ;       PE1 = TXD
480                                 ;       PE2 = SCLK
481    
482                                 ; Program the triple timer to assert TCI0 as an GPIO output = 1
483       P:000127 P:000127 07F40F            MOVEP             #$2800,X:TCSR0
                            002800
484       P:000129 P:000129 07F40B            MOVEP             #$2800,X:TCSR1
                            002800
485       P:00012B P:00012B 07F407            MOVEP             #$2800,X:TCSR2
                            002800
486    
487    
488                                 ; Program the address attribute pins AA0 to AA2. AA3 is not yet implemented.
489       P:00012D P:00012D 08F4B9            MOVEP             #$FFFC21,X:AAR0         ; Y = $FFF000 to $FFFFFF asserts Y:RDFIFO*
                            FFFC21
490       P:00012F P:00012F 08F4B8            MOVEP             #$008929,X:AAR1         ; P = $008000 to $00FFFF asserts AA1 low tru
e
                            008929
491       P:000131 P:000131 08F4B7            MOVEP             #$000122,X:AAR2         ; Y = $000800 to $7FFFFF accesses SRAM
                            000122
492    
493    
494                                 ; Program the DRAM memory access and addressing
495       P:000133 P:000133 08F4BB            MOVEP             #$020022,X:BCR          ; Bus Control Register
                            020022
496       P:000135 P:000135 08F4BA            MOVEP             #$893A05,X:DCR          ; DRAM Control Register
                            893A05
497    
498    
499                                 ; Clear all PCI error conditions
500       P:000137 P:000137 084E0A            MOVEP             X:DPSR,A
501       P:000138 P:000138 0140C2            OR      #$1FE,A
                            0001FE
502       P:00013A P:00013A 000000            NOP
Motorola DSP56300 Assembler  Version 6.3.4   05-09-23  15:59:30  PCI_SCUBA_initialisation.asm  Page 11



503       P:00013B P:00013B 08CE0A            MOVEP             A,X:DPSR
504    
505                                 ;--------------------------------------------------------------------
506                                 ; Enable one interrupt only: software reset switch
507       P:00013C P:00013C 08F4BF            MOVEP             #$0001C0,X:IPRC         ; IRQB priority = 1 (FIFO half full HF*)
                            0001C0
508                                                                                     ; IRQC priority = 2 (reset switch)
509       P:00013E P:00013E 05F439            MOVE              #$200,SR                ; Mask set up for reset switch only
                            000200
510    
511    
512                                 ;--------------------------------------------------------------------------
513                                 ; Initialize the fiber optic serial transmitter to zero
514       P:000140 P:000140 01B786            JCLR    #TDE,X:SSISR0,*
                            000140
515       P:000142 P:000142 07F43C            MOVEP             #$000000,X:TX00
                            000000
516    
517                                 ;--------------------------------------------------------------------
518    
519                                 ; clear DTXM - PCI master transmitter
520       P:000144 P:000144 0A862E            BSET    #CLRT,X:DPCR                      ; Clear the master transmitter DTXM
521       P:000145 P:000145 0A86AE            JSET    #CLRT,X:DPCR,*                    ; Wait for the clearing to be complete
                            000145
522    
523                                 ;----------------------------------------------------------------------
524                                 ; clear DRXR - PCI receiver
525    
526       P:000147 P:000147 0A8982  CLR0      JCLR    #SRRQ,X:DSR,CLR1                  ; Wait for the receiver to be empty
                            00014C
527       P:000149 P:000149 08440B            MOVEP             X:DRXR,X0               ; Read receiver to empty it
528       P:00014A P:00014A 000000            NOP
529       P:00014B P:00014B 0C0147            JMP     <CLR0
530                                 CLR1
531    
532                                 ;-----------------------------------------------------------------------------
533                                 ; copy parameter table from P memory into X memory
534    
535                                 ; Move the table of constants from P: space to X: space
536       P:00014C P:00014C 61F400            MOVE              #VAR_TBL_START,R1       ; Start of parameter table in P
                            00050B
537       P:00014E P:00014E 300000            MOVE              #VAR_TBL,R0             ; start of parameter table in X
538       P:00014F P:00014F 064080            DO      #VAR_TBL_LENGTH,X_WRITE
                            000152
539       P:000151 P:000151 07D984            MOVE              P:(R1)+,X0
540       P:000152 P:000152 445800            MOVE              X0,X:(R0)+              ; Write the constants to X:
541                                 X_WRITE
542    
543                                 ;-------------------------------------------------------------------------------
544                                 ; initialise some bits in STATUS
545    
546       P:000153 P:000153 0A0000            BCLR    #APPLICATION_LOADED,X:<STATUS     ; clear application loaded flag
547       P:000154 P:000154 0A000C            BCLR    #APPLICATION_RUNNING,X:<STATUS    ; clear appliaction running flag
548                                                                                     ; (e.g. not running diagnostic application
549                                                                                     ;      in self_test_mode)
550    
551       P:000155 P:000155 0A0002            BCLR    #FATAL_ERROR,X:<STATUS            ; initialise fatal error flag.
552       P:000156 P:000156 0A0028            BSET    #PACKET_CHOKE,X:<STATUS           ; enable MCE packet choke
553                                                                                     ; HOST not informed of anything from MCE unt
il
554                                                                                     ; comms are opened by host with first CON co
mmand
Motorola DSP56300 Assembler  Version 6.3.4   05-09-23  15:59:30  PCI_SCUBA_initialisation.asm  Page 12



555    
556       P:000157 P:000157 0A0006            BCLR    #PREAMBLE_ERROR,X:<STATUS         ; flag to let host know premable error
557    
558                                 ;------------------------------------------------------------------------------
559                                 ; disable FIFO HF* intererupt...not used anymore.
560    
561       P:000158 P:000158 08F4BF            MOVEP             #$0001C0,X:IPRC         ; Disable FIFO HF* interrupt
                            0001C0
562       P:00015A P:00015A 05F439            MOVEC             #$200,SR                ; Mask level 1 interrupts
                            000200
563    
564                                 ;----------------------------------------------------------------------------
565                                 ; Enable Byte swapin
566       P:00015C P:00015C 0A0025            BSET    #BYTE_SWAP,X:<STATUS              ; flag to let host know byte swapping on
567       P:00015D P:00015D 013D24            BSET    #AUX1,X:PDRC                      ; enable hardware
568    
569                                 ; ------------------------------------------------------------------------------
570                                 ; before starting main code
571                                 ; Clear out any garbage in the receive FIFO....
572                                 ; keep clearing for 350ms then continue....
573    
574       P:00015E P:00015E 44F400            MOVE              #10000,X0               ; Delay by about 350 milliseconds
                            002710
575       P:000160 P:000160 06C400            DO      X0,RX_DELAY
                            000166
576       P:000162 P:000162 06E883            DO      #1000,RX_RDFIFO
                            000165
577       P:000164 P:000164 09463F            MOVEP             Y:RDFIFO,Y0             ; Read the FIFO word to keep the
578       P:000165 P:000165 000000            NOP                                       ;   receiver empty
579                                 RX_RDFIFO
580       P:000166 P:000166 000000            NOP
581                                 RX_DELAY
582       P:000167 P:000167 000000            NOP
583                                 ;-----------------------------------------------------------------------------
584                                 ; Here endth the initialisation code run after power up.
585                                 ; ----------------------------------------------------------------------------
586    
587    
588    
589    
590                                           INCLUDE 'PCI_SCUBA_main.asm'
591                                  COMMENT *
592    
593                                 This is the main section of the pci card code.
594    
595                                 Project:     SCUBA 2
596                                 Author:      DAVID ATKINSON
597                                 Target:      250MHz SDSU PCI card - DSP56301
598                                 Controller:  For use with SCUBA 2 Multichannel Electronics
599    
600                                 Version:     Release Version A
601    
602    
603                                 Assembler directives:
604                                         ONCE=EEPROM => EEPROM CODE
605                                         ONCE=ONCE => ONCE CODE
606    
607                                         *
608                                           PAGE    132                               ; Printronix page width - 132 columns
609                                           OPT     CEX                               ; print DC evaluations
610    
**** 611 [PCI_SCUBA_main.asm 21]:  INCLUDE PCI_main.asm HERE  
Motorola DSP56300 Assembler  Version 6.3.4   05-09-23  15:59:30  PCI_SCUBA_main.asm  Page 13



611                                           MSG     ' INCLUDE PCI_main.asm HERE  '
612    
613                                 ; --------------------------------------------------------------------------
614                                 ; --------------------- MAIN PACKET HANDLING CODE --------------------------
615                                 ; --------------------------------------------------------------------------
616    
617                                 ; initialse buffer pointers
618                                 PACKET_IN
619    
620                                 ; R1 used as pointer for data written to y:memory            FO --> (Y)
621                                 ; R2 used as pointer for date in y mem to be writen to host  (Y) --> HOST
622    
623       P:000168 P:000168 310000            MOVE              #<IMAGE_BUFFER,R1       ; pointer for Fibre ---> Y mem
624       P:000169 P:000169 320000            MOVE              #<IMAGE_BUFFER,R2       ; pointer for Y mem ---> PCI BUS
625    
626                                 ; initialise some bits in status..
627       P:00016A P:00016A 0A0001            BCLR    #SEND_TO_HOST,X:<STATUS           ; clear send to host flag
628       P:00016B P:00016B 0A0009            BCLR    #HST_NFYD,X:<STATUS               ; clear flag to indicate host has been notif
ied.
629       P:00016C P:00016C 0A0003            BCLR    #FO_WRD_RCV,X:<STATUS             ; clear Fiber Optic flag
630    
631                                 ; check some bits in status....
632       P:00016D P:00016D 0A00A2            JSET    #FATAL_ERROR,X:<STATUS,START      ; fatal error?  Go to initialisation.
                            000100
633       P:00016F P:00016F 0A00A0            JSET    #APPLICATION_LOADED,X:<STATUS,APPLICATION ; application loaded?  Execute in ap
pl space.
                            000800
634       P:000171 P:000171 0A00AD            JSET    #INTERNAL_GO,X:<STATUS,APPLICATION ; internal GO to process?  PCI bus master w
rite test.
                            000800
635    
636       P:000173 P:000173 0D03D4  CHK_FIFO  JSR     <GET_FO_WRD                       ; see if there's a 16-bit word in Fibre FIFO
 from MCE
637    
638    
639       P:000174 P:000174 0A00A3            JSET    #FO_WRD_RCV,X:<STATUS,CHECK_WD    ; there is a word - check if it's preamble
                            000177
640       P:000176 P:000176 0C0168            JMP     <PACKET_IN                        ; else go back and repeat
641    
642                                 ; check that we preamble sequence
643    
644       P:000177 P:000177 0A00A8  CHECK_WD  JSET    #PACKET_CHOKE,X:<STATUS,PACKET_IN ; IF MCE Packet choke on - just keep clearin
g FIFO.
                            000168
645       P:000179 P:000179 441C00            MOVE              X0,X:<HEAD_W1_0         ;store received word
646       P:00017A P:00017A 56F000            MOVE              X:PREAMB1,A
                            000037
647       P:00017C P:00017C 200045            CMP     X0,A                              ; check it is correct
648       P:00017D P:00017D 0E2191            JNE     <PRE_ERROR                        ; if not go to start
649    
650    
651       P:00017E P:00017E 0D03DC            JSR     <WT_FIFO                          ; wait for next preamble 16-bit word
652       P:00017F P:00017F 441B00            MOVE              X0,X:<HEAD_W1_1         ;store received word
653       P:000180 P:000180 56F000            MOVE              X:PREAMB1,A
                            000037
654       P:000182 P:000182 200045            CMP     X0,A                              ; check it is correct
655       P:000183 P:000183 0E2191            JNE     <PRE_ERROR                        ; if not go to start
656    
657    
658       P:000184 P:000184 0D03DC            JSR     <WT_FIFO                          ; wait for next preamble 16-bit word
659       P:000185 P:000185 441E00            MOVE              X0,X:<HEAD_W2_0         ;store received word
660       P:000186 P:000186 56F000            MOVE              X:PREAMB2,A
Motorola DSP56300 Assembler  Version 6.3.4   05-09-23  15:59:30  PCI_SCUBA_main.asm  Page 14



                            000038
661       P:000188 P:000188 200045            CMP     X0,A                              ; check it is correct
662       P:000189 P:000189 0E2191            JNE     <PRE_ERROR                        ; if not go to start
663    
664       P:00018A P:00018A 0D03DC            JSR     <WT_FIFO                          ; wait for next preamble 16-bit word
665       P:00018B P:00018B 441D00            MOVE              X0,X:<HEAD_W2_1         ;store received word
666       P:00018C P:00018C 56F000            MOVE              X:PREAMB2,A
                            000038
667       P:00018E P:00018E 200045            CMP     X0,A                              ; check it is correct
668       P:00018F P:00018F 0E2191            JNE     <PRE_ERROR                        ; if not go to start
669       P:000190 P:000190 0C0194            JMP     <PACKET_INFO                      ; get packet info
670    
671    
672                                 PRE_ERROR
673       P:000191 P:000191 0A0026            BSET    #PREAMBLE_ERROR,X:<STATUS         ; indicate a preamble error
674       P:000192 P:000192 440200            MOVE              X0,X:<PRE_CORRUPT       ; store corrupted word
675       P:000193 P:000193 0C0168            JMP     <PACKET_IN                        ; wait for next packet
676    
677    
678                                 PACKET_INFO                                         ; packet preamble valid
679    
680                                 ; Packet preamle is valid so....
681                                 ; now get next two 32bit words.  i.e. $20205250 $00000004, or $20204441 $xxxxxxxx
682                                 ; note that these are received little endian (and byte swapped)
683                                 ; i.e. for RP receive 50 52 20 20  04 00 00 00
684                                 ; but byte swapped on arrival
685                                 ; 5250
686                                 ; 2020
687                                 ; 0004
688                                 ; 0000
689    
690       P:000194 P:000194 0D03DC            JSR     <WT_FIFO
691       P:000195 P:000195 442000            MOVE              X0,X:<HEAD_W3_0         ; RP or DA
692       P:000196 P:000196 0D03DC            JSR     <WT_FIFO
693       P:000197 P:000197 441F00            MOVE              X0,X:<HEAD_W3_1         ; $2020
694    
695       P:000198 P:000198 0D03DC            JSR     <WT_FIFO
696       P:000199 P:000199 442200            MOVE              X0,X:<HEAD_W4_0         ; packet size lo
697       P:00019A P:00019A 0D03DC            JSR     <WT_FIFO
698       P:00019B P:00019B 442100            MOVE              X0,X:<HEAD_W4_1         ; packet size hi
699    
700       P:00019C P:00019C 44A000            MOVE              X:<HEAD_W3_0,X0         ; get data header word 3 (low 2 bytes)
701       P:00019D P:00019D 56BA00            MOVE              X:<REPLY_WD,A           ; $5250
702       P:00019E P:00019E 200045            CMP     X0,A                              ; is it a reply packet?
703       P:00019F P:00019F 0AF0AA            JEQ     MCE_PACKET                        ; yes - go process it.
                            0001B3
704    
705       P:0001A1 P:0001A1 56B900            MOVE              X:<DATA_WD,A            ; $4441
706       P:0001A2 P:0001A2 200045            CMP     X0,A                              ; is it a data packet?
707       P:0001A3 P:0001A3 0E2168            JNE     <PACKET_IN                        ; no?  Not a valid packet type.  Go back to 
start and resync to next preamble.
708    
709    
710                                 ; It's a data packet....
711                                 ; check if it's the first packet after the GO command has been issued...
712    
713       P:0001A4 P:0001A4 0A0087            JCLR    #DATA_DLY,X:STATUS,INC_FRAME_COUNT ; do we need to add a delay since first fra
me?
                            0001AE
714    
715                                 ; yes first frame after GO reply packet so add a delay.
716                                 PACKET_DELAY
Motorola DSP56300 Assembler  Version 6.3.4   05-09-23  15:59:30  PCI_SCUBA_main.asm  Page 15



717       P:0001A6 P:0001A6 44F000            MOVE              X:DATA_DLY_VAL,X0
                            00003F
718       P:0001A8 P:0001A8 06C400            DO      X0,*+3                            ; 10ns x DATA_DLY_VAL
                            0001AA
719       P:0001AA P:0001AA 000000            NOP
720       P:0001AB P:0001AB 000000            NOP
721       P:0001AC P:0001AC 0A7007            BCLR    #DATA_DLY,X:STATUS                ; clear so delay isn't added next time.
                            000000
722    
723    
724                                 INC_FRAME_COUNT                                     ; increment frame count
725       P:0001AE P:0001AE 200013            CLR     A
726       P:0001AF P:0001AF 508100            MOVE              X:<FRAME_COUNT,A0
727       P:0001B0 P:0001B0 000008            INC     A
728       P:0001B1 P:0001B1 000000            NOP
729       P:0001B2 P:0001B2 500100            MOVE              A0,X:<FRAME_COUNT
730    
731                                 ; -------------------------------------------------------------------------------------------
732                                 ; ----------------------------------- IT'S A PAKCET FROM MCE --------------------------------
733                                 ; -------------------------------------------------------------------------------------------
734                                 ; prepare notify to inform host that a packet has arrived.
735    
736                                 MCE_PACKET
737       P:0001B3 P:0001B3 44F400            MOVE              #'NFY',X0               ; initialise communication to host as a noti
fy
                            4E4659
738       P:0001B5 P:0001B5 440B00            MOVE              X0,X:<DTXS_WD1          ; 1st word transmitted to host in notify mes
sage
739    
740       P:0001B6 P:0001B6 44A000            MOVE              X:<HEAD_W3_0,X0         ;RP or DA - top two bytes of word 3 ($2020) 
not passed to driver.
741       P:0001B7 P:0001B7 440C00            MOVE              X0,X:<DTXS_WD2          ;2nd word transmitted to host in notify mess
age
742    
743       P:0001B8 P:0001B8 44A200            MOVE              X:<HEAD_W4_0,X0         ; size of packet LSB 16bits (# 32bit words)
744       P:0001B9 P:0001B9 440D00            MOVE              X0,X:<DTXS_WD3          ; 3rd word transmitted to host in notify mes
sage
745    
746       P:0001BA P:0001BA 44A100            MOVE              X:<HEAD_W4_1,X0         ; size of packet MSB 16bits (# of 32bit word
s)
747       P:0001BB P:0001BB 440E00            MOVE              X0,X:<DTXS_WD4          ; 4th word transmitted to host in notify mes
sasge
748    
749       P:0001BC P:0001BC 200013            CLR     A                                 ;
750       P:0001BD P:0001BD 340000            MOVE              #0,R4                   ; initialise word count
751       P:0001BE P:0001BE 560600            MOVE              A,X:<WORD_COUNT         ; initialise word count store (num of words 
written over bus/packet)
752    
753                                 ; ----------------------------------------------------------------------------------------------
------------
754                                 ; Determine how to break up packet to write to host
755    
756                                 ; Note that this SR uses accumulator B
757                                 ; Therefore execute before we get the bus address from host (which is stored in B)
758                                 ; i.e before we issue notify message ('NFY')
759    
760       P:0001BF P:0001BF 0D03A5            JSR     <CALC_NO_BUFFS                    ; subroutine which calculates the number of 
512 (16bit) buffers
761                                                                                     ; number of left over 32 (16bit) blocks
762                                                                                     ; and number of left overs (16bit) words
763    
764                                 ;  note that a 512 (16-bit) buffer is transfered to the host as 4 x 64 x 32bit DMA burst
Motorola DSP56300 Assembler  Version 6.3.4   05-09-23  15:59:30  PCI_SCUBA_main.asm  Page 16



765                                 ;            a 32  (16-bit) block is transfered to the host as a    16 x 32bit DMA burst
766                                 ;            left over 16bit words are transfered to the host in pairs as 32bit words
767                                 ; ----------------------------------------------------------------------------------------------
---
768    
769    
770                                 ; notify the host that there is a packet.....
771    
772       P:0001C0 P:0001C0 0D040F            JSR     <PCI_MESSAGE_TO_HOST              ; notify host of packet
773       P:0001C1 P:0001C1 0A0029            BSET    #HST_NFYD,X:<STATUS               ; flag to indicate host has been notified.
774       P:0001C2 P:0001C2 0A00A2  WT_HOST   JSET    #FATAL_ERROR,X:<STATUS,START      ; if fatal error - run initialisation code..
.
                            000100
775       P:0001C4 P:0001C4 0A0081            JCLR    #SEND_TO_HOST,X:<STATUS,WT_HOST   ; wait for host to reply - which it does wit
h 'send_packet_to_host' ISR
                            0001C2
776    
777    
778                                 ; we now have 32 bit address in accumulator B
779                                 ; from send-packet_to_host
780    
781                                 ; ----------------------------------------------------------------------------------------------
-----------
782                                 ; Write TOTAL_BUFFS * 512 buffers to host
783                                 ; ----------------------------------------------------------------------------------------------
------
784       P:0001C6 P:0001C6 063B00            DO      X:<TOTAL_BUFFS,ALL_BUFFS_END      ; note that if TOTAL_BUFFS = 0 we jump to AL
L_BUFFS_END
                            0001D6
785    
786       P:0001C8 P:0001C8 310000            MOVE              #<IMAGE_BUFFER,R1       ; FO ---> Y mem
787       P:0001C9 P:0001C9 320000            MOVE              #<IMAGE_BUFFER,R2       ; Y mem ----->  PCI BUS
788    
789    
790       P:0001CA P:0001CA 0A00A2  WAIT_BUFF JSET    #FATAL_ERROR,X:<STATUS,START      ; if fatal error then reset (i.e. if HST tim
eout)
                            000100
791       P:0001CC P:0001CC 01ADA1            JSET    #HF,X:PDRD,WAIT_BUFF              ; Wait for FIFO to be half full + 1
                            0001CA
792       P:0001CE P:0001CE 000000            NOP
793       P:0001CF P:0001CF 000000            NOP
794       P:0001D0 P:0001D0 01ADA1            JSET    #HF,X:PDRD,WAIT_BUFF              ; Protection against metastability
                            0001CA
795    
796    
797                                 ; Copy the image block as 512 x 16bit words to DSP Y: Memory using R1 as pointer
798       P:0001D2 P:0001D2 060082            DO      #512,L_BUFFER
                            0001D4
799       P:0001D4 P:0001D4 0959FF            MOVEP             Y:RDFIFO,Y:(R1)+
800                                 L_BUFFER
801    
802    
803                                 ; R2 points to data in Y memory to be written to host
804                                 ; host address is in B - got by SEND_PACKET_TO_HOST command
805                                 ; so we can now write this buffer to host
806    
807       P:0001D5 P:0001D5 0D04C4            JSR     <WRITE_512_TO_PCI                 ; this subroutine will increment host addres
s, which is in B and R2
808       P:0001D6 P:0001D6 000000            NOP
809                                 ALL_BUFFS_END                                       ; all buffers have been writen to host
810    
811                                 ; ----------------------------------------------------------------------------------------------
Motorola DSP56300 Assembler  Version 6.3.4   05-09-23  15:59:30  PCI_SCUBA_main.asm  Page 17



-----------
812                                 ; Write NUM_LEFTOVER_BLOCKS * 32 blocks to host
813                                 ; ----------------------------------------------------------------------------------------------
------
814    
815                                 ; less than 512 pixels but if greater than 32 will then do bursts
816                                 ; of 16 x 32bit in length, if less than 32 then does single read writes
817    
818       P:0001D7 P:0001D7 063E00            DO      X:<NUM_LEFTOVER_BLOCKS,LEFTOVER_BLOCKS ;note that if NUM_LEFOVERS_BLOCKS = 0 w
e jump to LEFTOVER_BLOCKS
                            0001E7
819    
820    
821       P:0001D9 P:0001D9 310000            MOVE              #<IMAGE_BUFFER,R1       ; FO ---> Y mem
822       P:0001DA P:0001DA 320000            MOVE              #<IMAGE_BUFFER,R2       ; Y mem ----->  PCI BUS
823    
824       P:0001DB P:0001DB 062080            DO      #32,S_BUFFER
                            0001E5
825       P:0001DD P:0001DD 0A00A2  WAIT_1    JSET    #FATAL_ERROR,X:<STATUS,START      ; check for fatal error (i.e. after HST time
out)
                            000100
826       P:0001DF P:0001DF 01AD80            JCLR    #EF,X:PDRD,WAIT_1                 ; Wait for the pixel datum to be there
                            0001DD
827       P:0001E1 P:0001E1 000000            NOP                                       ; Settling time
828       P:0001E2 P:0001E2 000000            NOP
829       P:0001E3 P:0001E3 01AD80            JCLR    #EF,X:PDRD,WAIT_1                 ; Protection against metastability
                            0001DD
830       P:0001E5 P:0001E5 0959FF            MOVEP             Y:RDFIFO,Y:(R1)+        ; save fibre word
831                                 S_BUFFER
832    
833       P:0001E6 P:0001E6 0D0499            JSR     <WRITE_32_TO_PCI                  ; write small blocks
834       P:0001E7 P:0001E7 000000            NOP
835                                 LEFTOVER_BLOCKS
836    
837                                 ; ----------------------------------------------------------------------------------------------
-------
838                                 ; Single write left over words to host
839                                 ; ----------------------------------------------------------------------------------------------
------
840    
841                                 LEFT_OVERS
842       P:0001E8 P:0001E8 310000            MOVE              #<IMAGE_BUFFER,R1       ; FO ---> Y mem
843       P:0001E9 P:0001E9 320000            MOVE              #<IMAGE_BUFFER,R2       ; Y mem ----->  PCI BUS
844    
845       P:0001EA P:0001EA 063C00            DO      X:<LEFT_TO_READ,LEFT_OVERS_READ   ; read in remaining words of data packet
                            0001F4
846                                                                                     ; if LEFT_TO_READ = 0 then will jump to LEFT
_OVERS_READ
847    
848       P:0001EC P:0001EC 0A00A2  WAIT_2    JSET    #FATAL_ERROR,X:<STATUS,START      ; check for fatal error (i.e. after HST time
out)
                            000100
849       P:0001EE P:0001EE 01AD80            JCLR    #EF,X:PDRD,WAIT_2                 ; Wait till something in FIFO flagged
                            0001EC
850       P:0001F0 P:0001F0 000000            NOP
851       P:0001F1 P:0001F1 000000            NOP
852       P:0001F2 P:0001F2 01AD80            JCLR    #EF,X:PDRD,WAIT_2                 ; protect against metastability.....
                            0001EC
853       P:0001F4 P:0001F4 0959FF            MOVEP             Y:RDFIFO,Y:(R1)+        ; save fibre word
854                                 LEFT_OVERS_READ
855    
856                                 ; now write left overs to host as 32 bit words
Motorola DSP56300 Assembler  Version 6.3.4   05-09-23  15:59:30  PCI_SCUBA_main.asm  Page 18



857    
858       P:0001F5 P:0001F5 063D00            DO      X:LEFT_TO_WRITE,LEFT_OVERS_WRITEN ; left overs to write is half left overs rea
d - since 32 bit writes
                            0001F8
859                                                                                     ; if LEFT_TO_WRITE = 0, will jump to LEFT_OV
ERS_WRITTEN
860       P:0001F7 P:0001F7 0BF080            JSR     WRITE_TO_PCI                      ; uses R2 as pointer to Y memory, host addre
ss in B
                            000478
861                                 LEFT_OVERS_WRITEN
862    
863    
864                                 ; ----------------------------------------------------------------------------------------------
------------
865                                 ; reply to host's send_packet_to_host command
866    
867                                  HST_ACK_REP
868       P:0001F9 P:0001F9 44F400            MOVE              #'REP',X0
                            524550
869       P:0001FB P:0001FB 440B00            MOVE              X0,X:<DTXS_WD1          ; REPly
870       P:0001FC P:0001FC 44F400            MOVE              #'HST',X0
                            485354
871       P:0001FE P:0001FE 440C00            MOVE              X0,X:<DTXS_WD2          ; echo command sent
872       P:0001FF P:0001FF 44F400            MOVE              #'ACK',X0
                            41434B
873       P:000201 P:000201 440D00            MOVE              X0,X:<DTXS_WD3          ; ACKnowledge okay
874       P:000202 P:000202 44F400            MOVE              #'000',X0
                            303030
875       P:000204 P:000204 440E00            MOVE              X0,X:<DTXS_WD4          ; no error
876       P:000205 P:000205 0D040F            JSR     <PCI_MESSAGE_TO_HOST
877       P:000206 P:000206 0C0168            JMP     <PACKET_IN
878                                 ; ----------------------------------------------------------------------------------------------
--
879                                 ;                              END OF MAIN PACKET HANDLING CODE
880                                 ; ---------------------------------------------------------------------------------------------
881    
882    
883                                 ; -------------------------------------------------------------------------------------
884                                 ;
885                                 ;                              INTERRUPT SERVICE ROUTINES
886                                 ;
887                                 ; ---------------------------------------------------------------------------------------
888    
889                                 ;--------------------------------------------------------------------
890                                 CLEAN_UP_PCI
891                                 ;--------------------------------------------------------------------
892                                 ; Clean up the PCI board from wherever it was executing
893    
894       P:000207 P:000207 08F4BF            MOVEP             #$0001C0,X:IPRC         ; Disable HF* FIFO interrupt
                            0001C0
895       P:000209 P:000209 05F439            MOVE              #$200,SR                ; mask for reset interrupts only
                            000200
896    
897       P:00020B P:00020B 0501BB            MOVEC             #1,SP                   ; Point stack pointer to the top
898       P:00020C P:00020C 05F43D            MOVEC             #$000200,SSL            ; SR = zero except for interrupts
                            000200
899       P:00020E P:00020E 0500BB            MOVEC             #0,SP                   ; Writing to SSH preincrements the SP
900       P:00020F P:00020F 05F43C            MOVEC             #START,SSH              ; Set PC to for full initialization
                            000100
901       P:000211 P:000211 000000            NOP
902       P:000212 P:000212 000004            RTI
903    
Motorola DSP56300 Assembler  Version 6.3.4   05-09-23  15:59:30  PCI_SCUBA_main.asm  Page 19



904                                 ; ---------------------------------------------------------------------------
905                                 READ_MEMORY
906                                 ;--------------------------------------------------------------------------
907                                 ; word 1 = command = 'RDM'
908                                 ; word 2 = memory type, P=$00'_P', X=$00_'X' or Y=$00_'Y'
909                                 ; word 3 = address in memory
910                                 ; word 4 = not used
911    
912       P:000213 P:000213 0D046C            JSR     <SAVE_REGISTERS                   ; save working registers
913    
914       P:000214 P:000214 0D042A            JSR     <RD_DRXR                          ; read words from host write to HTXR
915       P:000215 P:000215 56F000            MOVE              X:DRXR_WD1,A            ; read command
                            000007
916       P:000217 P:000217 44F400            MOVE              #'RDM',X0
                            52444D
917       P:000219 P:000219 200045            CMP     X0,A                              ; ensure command is 'RDM'
918       P:00021A P:00021A 0E223E            JNE     <READ_MEMORY_ERROR_CNE            ; error, command NOT HCVR address
919       P:00021B P:00021B 568800            MOVE              X:<DRXR_WD2,A           ; Memory type (X, Y, P)
920       P:00021C P:00021C 578900            MOVE              X:<DRXR_WD3,B
921       P:00021D P:00021D 000000            NOP                                       ; pipeline restriction
922       P:00021E P:00021E 21B000            MOVE              B1,R0                   ; get address to write to
923       P:00021F P:00021F 0140C5            CMP     #$005F50,A                        ; $00'_P'
                            005F50
924       P:000221 P:000221 0E2225            JNE     <RDX
925       P:000222 P:000222 07E084            MOVE              P:(R0),X0               ; Read from P memory
926       P:000223 P:000223 208E00            MOVE              X0,A                    ;
927       P:000224 P:000224 0C0230            JMP     <FINISH_READ_MEMORY
928                                 RDX
929       P:000225 P:000225 0140C5            CMP     #$005F58,A                        ; $00'_X'
                            005F58
930       P:000227 P:000227 0E222B            JNE     <RDY
931       P:000228 P:000228 44E000            MOVE              X:(R0),X0               ; Read from P memory
932       P:000229 P:000229 208E00            MOVE              X0,A
933       P:00022A P:00022A 0C0230            JMP     <FINISH_READ_MEMORY
934                                 RDY
935       P:00022B P:00022B 0140C5            CMP     #$005F59,A                        ; $00'_Y'
                            005F59
936       P:00022D P:00022D 0E2243            JNE     <READ_MEMORY_ERROR_MTE            ; not a valid memory type
937       P:00022E P:00022E 4CE000            MOVE                          Y:(R0),X0   ; Read from P memory
938       P:00022F P:00022F 208E00            MOVE              X0,A
939    
940                                 ; when completed successfully then PCI needs to reply to Host with
941                                 ; word1 = reply/data = reply
942                                 FINISH_READ_MEMORY
943       P:000230 P:000230 44F400            MOVE              #'REP',X0
                            524550
944       P:000232 P:000232 440B00            MOVE              X0,X:<DTXS_WD1          ; REPly
945       P:000233 P:000233 44F400            MOVE              #'RDM',X0
                            52444D
946       P:000235 P:000235 440C00            MOVE              X0,X:<DTXS_WD2          ; echo command sent
947       P:000236 P:000236 44F400            MOVE              #'ACK',X0
                            41434B
948       P:000238 P:000238 440D00            MOVE              X0,X:<DTXS_WD3          ;  im command
949       P:000239 P:000239 21C400            MOVE              A,X0
950       P:00023A P:00023A 440E00            MOVE              X0,X:<DTXS_WD4          ; write to PCI memory error
951       P:00023B P:00023B 0D0457            JSR     <RESTORE_REGISTERS                ; restore registers
952       P:00023C P:00023C 0D040F            JSR     <PCI_MESSAGE_TO_HOST              ; interrupt host with message (x0 restored h
ere)
953       P:00023D P:00023D 000004            RTI
954    
955                                 READ_MEMORY_ERROR_CNE
956       P:00023E P:00023E 44F400            MOVE              #'CNE',X0
Motorola DSP56300 Assembler  Version 6.3.4   05-09-23  15:59:30  PCI_SCUBA_main.asm  Page 20



                            434E45
957       P:000240 P:000240 440E00            MOVE              X0,X:<DTXS_WD4          ; Command Name Error - command name in DRXR 
does not match
958       P:000241 P:000241 0AF080            JMP     READ_MEMORY_ERROR                 ; fill in rest of reply
                            000246
959                                 READ_MEMORY_ERROR_MTE
960       P:000243 P:000243 44F400            MOVE              #'MTE',X0
                            4D5445
961       P:000245 P:000245 440E00            MOVE              X0,X:<DTXS_WD4          ;  Memory Type Error - not a valid memory ty
pe
962    
963                                 READ_MEMORY_ERROR
964       P:000246 P:000246 44F400            MOVE              #'REP',X0
                            524550
965       P:000248 P:000248 440B00            MOVE              X0,X:<DTXS_WD1          ; REPly
966       P:000249 P:000249 44F400            MOVE              #'RDM',X0
                            52444D
967       P:00024B P:00024B 440C00            MOVE              X0,X:<DTXS_WD2          ; echo command sent
968       P:00024C P:00024C 44F400            MOVE              #'ERR',X0
                            455252
969       P:00024E P:00024E 440D00            MOVE              X0,X:<DTXS_WD3          ; ERRor.
970       P:00024F P:00024F 0D0457            JSR     <RESTORE_REGISTERS                ; restore working registers
971       P:000250 P:000250 0D040F            JSR     <PCI_MESSAGE_TO_HOST              ; interrupt host with message (x0 restored h
ere)
972       P:000251 P:000251 000004            RTI
973    
974                                 ;-----------------------------------------------------------------------------
975                                 RESET_CONTROLLER
976                                 ; Reset the controller by sending a special code byte $0B with SC/nData = 1
977                                 ;---------------------------------------------------------------------------
978                                 ; word 1 = command = 'RCO'
979                                 ; word 2 = not used but read
980                                 ; word 3 = not used but read
981                                 ; word 4 = not used but read
982    
983       P:000252 P:000252 0D046C            JSR     <SAVE_REGISTERS                   ; save working registers
984       P:000253 P:000253 0D042A            JSR     <RD_DRXR                          ; read words from host write to HTXR
985       P:000254 P:000254 568700            MOVE              X:<DRXR_WD1,A           ; read command
986       P:000255 P:000255 44F400            MOVE              #'RCO',X0
                            52434F
987       P:000257 P:000257 200045            CMP     X0,A                              ; ensure command is 'RCO'
988       P:000258 P:000258 0E227D            JNE     <RCO_ERROR                        ; error, command NOT HCVR address
989    
990                                 ; if we get here then everything is fine and we can send reset to controller
991    
992                                 ; 250MHZ CODE....
993    
994       P:000259 P:000259 011D22            BSET    #SCLK,X:PDRE                      ; Enable special command mode
995       P:00025A P:00025A 000000            NOP
996       P:00025B P:00025B 000000            NOP
997       P:00025C P:00025C 60F400            MOVE              #$FFF000,R0             ; Memory mapped address of transmitter
                            FFF000
998       P:00025E P:00025E 44F400            MOVE              #$10000B,X0             ; Special command to reset controller
                            10000B
999       P:000260 P:000260 446000            MOVE              X0,X:(R0)
1000      P:000261 P:000261 0606A0            REP     #6                                ; Wait for transmission to complete
1001      P:000262 P:000262 000000            NOP
1002      P:000263 P:000263 011D02            BCLR    #SCLK,X:PDRE                      ; Disable special command mode
1003   
1004                                ; Wait for a bit for MCE to be reset.......
1005      P:000264 P:000264 44F400            MOVE              #10000,X0               ; Delay by about 350 milliseconds
                            002710
Motorola DSP56300 Assembler  Version 6.3.4   05-09-23  15:59:30  PCI_SCUBA_main.asm  Page 21



1006      P:000266 P:000266 06C400            DO      X0,L_DELAY
                            00026C
1007      P:000268 P:000268 06E883            DO      #1000,L_RDFIFO
                            00026B
1008      P:00026A P:00026A 09463F            MOVEP             Y:RDFIFO,Y0             ; Read the FIFO word to keep the
1009      P:00026B P:00026B 000000            NOP                                       ;   receiver empty
1010                                L_RDFIFO
1011      P:00026C P:00026C 000000            NOP
1012                                L_DELAY
1013      P:00026D P:00026D 000000            NOP
1014   
1015                                ; when completed successfully then PCI needs to reply to Host with
1016                                ; word1 = reply/data = reply
1017                                FINISH_RCO
1018      P:00026E P:00026E 44F400            MOVE              #'REP',X0
                            524550
1019      P:000270 P:000270 440B00            MOVE              X0,X:<DTXS_WD1          ; REPly
1020      P:000271 P:000271 44F400            MOVE              #'RCO',X0
                            52434F
1021      P:000273 P:000273 440C00            MOVE              X0,X:<DTXS_WD2          ; echo command sent
1022      P:000274 P:000274 44F400            MOVE              #'ACK',X0
                            41434B
1023      P:000276 P:000276 440D00            MOVE              X0,X:<DTXS_WD3          ; ACKnowledge okay
1024      P:000277 P:000277 44F400            MOVE              #'000',X0
                            303030
1025      P:000279 P:000279 440E00            MOVE              X0,X:<DTXS_WD4          ; read data
1026      P:00027A P:00027A 0D0457            JSR     <RESTORE_REGISTERS                ; restore working registers
1027      P:00027B P:00027B 0D040F            JSR     <PCI_MESSAGE_TO_HOST              ; interrupt host with message (x0 restored h
ere)
1028      P:00027C P:00027C 000004            RTI                                       ; return from ISR
1029   
1030                                ; when there is a failure in the host to PCI command then the PCI
1031                                ; needs still to reply to Host but with an error message
1032                                RCO_ERROR
1033      P:00027D P:00027D 44F400            MOVE              #'REP',X0
                            524550
1034      P:00027F P:00027F 447000            MOVE              X0,X:DTXS_WD1           ; REPly
                            00000B
1035      P:000281 P:000281 44F400            MOVE              #'RCO',X0
                            52434F
1036      P:000283 P:000283 447000            MOVE              X0,X:DTXS_WD2           ; echo command sent
                            00000C
1037      P:000285 P:000285 44F400            MOVE              #'ERR',X0
                            455252
1038      P:000287 P:000287 447000            MOVE              X0,X:DTXS_WD3           ; ERRor im command
                            00000D
1039      P:000289 P:000289 44F400            MOVE              #'CNE',X0
                            434E45
1040      P:00028B P:00028B 447000            MOVE              X0,X:DTXS_WD4           ; Command Name Error - command name in DRXR 
does not match
                            00000E
1041      P:00028D P:00028D 0D0457            JSR     <RESTORE_REGISTERS                ; restore wroking registers
1042      P:00028E P:00028E 0D040F            JSR     <PCI_MESSAGE_TO_HOST              ; interrupt host with message (x0 restored h
ere)
1043      P:00028F P:00028F 000004            RTI                                       ; return from ISR
1044   
1045   
1046                                ;----------------------------------------------------------------------
1047                                SEND_PACKET_TO_CONTROLLER
1048   
1049                                ; forward packet stuff to the MCE
1050                                ; gets address in HOST memory where packet is stored
Motorola DSP56300 Assembler  Version 6.3.4   05-09-23  15:59:30  PCI_SCUBA_main.asm  Page 22



1051                                ; read 3 consecutive locations starting at this address
1052                                ; then sends the data from these locations up to the MCE
1053                                ;----------------------------------------------------------------------
1054   
1055                                ; word 1 = command = 'CON'
1056                                ; word 2 = host high address
1057                                ; word 3 = host low address
1058                                ; word 4 = '0' --> when MCE command is RS,WB,RB,ST
1059                                ;        = '1' --> when MCE command is GO
1060   
1061                                ; all MCE commands are now 'block commands'
1062                                ; i.e. 64 words long.
1063   
1064      P:000290 P:000290 0D046C            JSR     <SAVE_REGISTERS                   ; save working registers
1065   
1066      P:000291 P:000291 0D042A            JSR     <RD_DRXR                          ; read words from host write to HTXR
1067                                                                                    ; reads as 4 x 24 bit words
1068   
1069      P:000292 P:000292 568700            MOVE              X:<DRXR_WD1,A           ; read command
1070      P:000293 P:000293 44F400            MOVE              #'CON',X0
                            434F4E
1071      P:000295 P:000295 200045            CMP     X0,A                              ; ensure command is 'CON'
1072      P:000296 P:000296 0E22C5            JNE     <CON_ERROR                        ; error, command NOT HCVR address
1073   
1074                                ; convert 2 x 24 bit words ( only 16 LSBs are significant) from host into 32 bit address
1075      P:000297 P:000297 20001B            CLR     B
1076      P:000298 P:000298 448800            MOVE              X:<DRXR_WD2,X0          ; MS 16bits of address
1077      P:000299 P:000299 518900            MOVE              X:<DRXR_WD3,B0          ; LS 16bits of address
1078      P:00029A P:00029A 0C1941            INSERT  #$010010,X0,B                     ; convert to 32 bits and put in B
                            010010
1079   
1080      P:00029C P:00029C 568A00            MOVE              X:<DRXR_WD4,A           ; read word 4 - GO command?
1081      P:00029D P:00029D 44F000            MOVE              X:ZERO,X0
                            000032
1082      P:00029F P:00029F 200045            CMP     X0,A
1083      P:0002A0 P:0002A0 0AF0AA            JEQ     BLOCK_CON
                            0002AE
1084   
1085   
1086      P:0002A2 P:0002A2 0A008C            JCLR    #APPLICATION_RUNNING,X:STATUS,SET_PACKET_DELAY ; not running diagnostic applic
ation?
                            0002AC
1087   
1088                                ; need to generate an internal go command to test master write on bus.....  Diagnostic test
1089      P:0002A4 P:0002A4 0A702D            BSET    #INTERNAL_GO,X:STATUS             ; set flag so that GO reply / data is genera
ted by PCI card...
                            000000
1090   
1091                                ; since INTERNAL_GO  - read command but don't send it to MCE...
1092   
1093                                CLR_CMD
1094      P:0002A6 P:0002A6 064080            DO      #64,END_CLR_CMD                   ; block size = 32bit x 64 (256 bytes)
                            0002A9
1095      P:0002A8 P:0002A8 0D0437            JSR     <READ_FROM_PCI                    ; get next 32 bit word from HOST
1096      P:0002A9 P:0002A9 000000            NOP
1097                                END_CLR_CMD
1098      P:0002AA P:0002AA 0AF080            JMP     FINISH_CON                        ; don't send out on command on fibre
                            0002B6
1099   
1100   
1101                                SET_PACKET_DELAY
1102      P:0002AC P:0002AC 0A7027            BSET    #DATA_DLY,X:STATUS                ; set data delay so that next data packet af
Motorola DSP56300 Assembler  Version 6.3.4   05-09-23  15:59:30  PCI_SCUBA_main.asm  Page 23



ter go reply
                            000000
1103                                                                                    ; experiences a delay before host notify.
1104                                BLOCK_CON
1105      P:0002AE P:0002AE 064080            DO      #64,END_BLOCK_CON                 ; block size = 32bit x 64 (256 bytes)
                            0002B4
1106      P:0002B0 P:0002B0 0D0437            JSR     <READ_FROM_PCI                    ; get next 32 bit word from HOST
1107      P:0002B1 P:0002B1 208C00            MOVE              X0,A1                   ; prepare to send
1108      P:0002B2 P:0002B2 20A800            MOVE              X1,A0                   ; prepare to send
1109      P:0002B3 P:0002B3 0D04F5            JSR     <XMT_WD_FIBRE                     ; off it goes
1110      P:0002B4 P:0002B4 000000            NOP
1111                                END_BLOCK_CON
1112   
1113      P:0002B5 P:0002B5 0A0008            BCLR    #PACKET_CHOKE,X:<STATUS           ; disable packet choke...
1114                                                                                    ; comms now open with MCE and packets will b
e processed.
1115   
1116                                ; -------------------------------------------------------------------------
1117                                ; when completed successfully then PCI needs to reply to Host with
1118                                ; word1 = reply/data = reply
1119                                FINISH_CON
1120      P:0002B6 P:0002B6 44F400            MOVE              #'REP',X0
                            524550
1121      P:0002B8 P:0002B8 440B00            MOVE              X0,X:<DTXS_WD1          ; REPly
1122      P:0002B9 P:0002B9 44F400            MOVE              #'CON',X0
                            434F4E
1123      P:0002BB P:0002BB 440C00            MOVE              X0,X:<DTXS_WD2          ; echo command sent
1124      P:0002BC P:0002BC 44F400            MOVE              #'ACK',X0
                            41434B
1125      P:0002BE P:0002BE 440D00            MOVE              X0,X:<DTXS_WD3          ; ACKnowledge okay
1126      P:0002BF P:0002BF 44F400            MOVE              #'000',X0
                            303030
1127      P:0002C1 P:0002C1 440E00            MOVE              X0,X:<DTXS_WD4          ; read data
1128      P:0002C2 P:0002C2 0D0457            JSR     <RESTORE_REGISTERS                ; restore working registers
1129      P:0002C3 P:0002C3 0D040F            JSR     <PCI_MESSAGE_TO_HOST              ;  interrupt host with message (x0 restored 
here)
1130      P:0002C4 P:0002C4 000004            RTI                                       ; return from ISR
1131   
1132                                ; when there is a failure in the host to PCI command then the PCI
1133                                ; needs still to reply to Host but with an error message
1134                                CON_ERROR
1135      P:0002C5 P:0002C5 44F400            MOVE              #'REP',X0
                            524550
1136      P:0002C7 P:0002C7 440B00            MOVE              X0,X:<DTXS_WD1          ; REPly
1137      P:0002C8 P:0002C8 44F400            MOVE              #'CON',X0
                            434F4E
1138      P:0002CA P:0002CA 440C00            MOVE              X0,X:<DTXS_WD2          ; echo command sent
1139      P:0002CB P:0002CB 44F400            MOVE              #'ERR',X0
                            455252
1140      P:0002CD P:0002CD 440D00            MOVE              X0,X:<DTXS_WD3          ; ERRor im command
1141      P:0002CE P:0002CE 44F400            MOVE              #'CNE',X0
                            434E45
1142      P:0002D0 P:0002D0 440E00            MOVE              X0,X:<DTXS_WD4          ; Command Name Error - command name in DRXR 
does not match
1143      P:0002D1 P:0002D1 0D0457            JSR     <RESTORE_REGISTERS                ; restore working registers
1144      P:0002D2 P:0002D2 0D040F            JSR     <PCI_MESSAGE_TO_HOST              ; interrupt host with message (x0 restored h
ere)
1145      P:0002D3 P:0002D3 000004            RTI                                       ; return from ISR
1146   
1147                                ; ------------------------------------------------------------------------------------
1148                                SEND_PACKET_TO_HOST
1149                                ; this command is received from the Host and actions the PCI board to pick up an address
Motorola DSP56300 Assembler  Version 6.3.4   05-09-23  15:59:30  PCI_SCUBA_main.asm  Page 24



1150                                ; pointer from DRXR which the PCI board then uses to write packets from the
1151                                ; MCE to the host memory starting at the address given.
1152                                ; Since this is interrupt driven all this piece of code does is get the address pointer from
1153                                ; the host via DRXR, set a flag so that the main prog can write the packet.  Replies to
1154                                ; HST after packet sent (unless error).
1155                                ; --------------------------------------------------------------------------------------
1156                                ; word 1 = command = 'HST'
1157                                ; word 2 = host high address
1158                                ; word 3 = host low address
1159                                ; word 4 = not used but read
1160   
1161                                ; save some registers but not B
1162   
1163      P:0002D4 P:0002D4 0D046C            JSR     <SAVE_REGISTERS                   ; save working registers
1164   
1165      P:0002D5 P:0002D5 0D042A            JSR     <RD_DRXR                          ; read words from host write to HTXR
1166      P:0002D6 P:0002D6 20001B            CLR     B
1167      P:0002D7 P:0002D7 568700            MOVE              X:<DRXR_WD1,A           ; read command
1168      P:0002D8 P:0002D8 44F400            MOVE              #'HST',X0
                            485354
1169      P:0002DA P:0002DA 200045            CMP     X0,A                              ; ensure command is 'HST'
1170      P:0002DB P:0002DB 0E22E3            JNE     <HOST_ERROR                       ; error, command NOT HCVR address
1171      P:0002DC P:0002DC 448800            MOVE              X:<DRXR_WD2,X0          ; high 16 bits of address
1172      P:0002DD P:0002DD 518900            MOVE              X:<DRXR_WD3,B0          ; low 16 bits of adderss
1173      P:0002DE P:0002DE 0C1941            INSERT  #$010010,X0,B                     ; convert to 32 bits and put in B
                            010010
1174   
1175      P:0002E0 P:0002E0 0A0021            BSET    #SEND_TO_HOST,X:<STATUS           ; tell main program to write packet to host 
memory
1176      P:0002E1 P:0002E1 0D0463            JSR     <RESTORE_HST_REGISTERS            ; restore registers for HST .... B not resto
red..
1177      P:0002E2 P:0002E2 000004            RTI
1178   
1179                                ; !!NOTE!!!
1180                                ; successful reply to this command is sent after packet has been send to host.
1181                                ; Not here unless error.
1182   
1183                                ; when there is a failure in the host to PCI command then the PCI
1184                                ; needs still to reply to Host but with an error message
1185                                HOST_ERROR
1186      P:0002E3 P:0002E3 0A7001            BCLR    #SEND_TO_HOST,X:STATUS
                            000000
1187      P:0002E5 P:0002E5 44F400            MOVE              #'REP',X0
                            524550
1188      P:0002E7 P:0002E7 440B00            MOVE              X0,X:<DTXS_WD1          ; REPly
1189      P:0002E8 P:0002E8 44F400            MOVE              #'HST',X0
                            485354
1190      P:0002EA P:0002EA 440C00            MOVE              X0,X:<DTXS_WD2          ; echo command sent
1191      P:0002EB P:0002EB 44F400            MOVE              #'ERR',X0
                            455252
1192      P:0002ED P:0002ED 440D00            MOVE              X0,X:<DTXS_WD3          ; ERRor im command
1193      P:0002EE P:0002EE 44F400            MOVE              #'CNE',X0
                            434E45
1194      P:0002F0 P:0002F0 440E00            MOVE              X0,X:<DTXS_WD4          ; Command Name Error - command name in DRXR 
does not match
1195      P:0002F1 P:0002F1 0D0457            JSR     <RESTORE_REGISTERS                ; restore working registers
1196      P:0002F2 P:0002F2 0D040F            JSR     <PCI_MESSAGE_TO_HOST              ; interrupt host with message (x0 restored h
ere)
1197      P:0002F3 P:0002F3 000004            RTI
1198   
1199                                ; --------------------------------------------------------------------
1200                                SOFTWARE_RESET
Motorola DSP56300 Assembler  Version 6.3.4   05-09-23  15:59:30  PCI_SCUBA_main.asm  Page 25



1201                                ;----------------------------------------------------------------------
1202                                ; word 1 = command = 'RST'
1203                                ; word 2 = not used but read
1204                                ; word 3 = not used but read
1205                                ; word 4 = not used but read
1206   
1207      P:0002F4 P:0002F4 0D046C            JSR     <SAVE_REGISTERS
1208   
1209      P:0002F5 P:0002F5 0D042A            JSR     <RD_DRXR                          ; read words from host write to HTXR
1210      P:0002F6 P:0002F6 568700            MOVE              X:<DRXR_WD1,A           ; read command
1211      P:0002F7 P:0002F7 44F400            MOVE              #'RST',X0
                            525354
1212      P:0002F9 P:0002F9 200045            CMP     X0,A                              ; ensure command is 'RST'
1213      P:0002FA P:0002FA 0E2319            JNE     <RST_ERROR                        ; error, command NOT HCVR address
1214   
1215                                ; RST command OK so reply to host
1216                                FINISH_RST
1217      P:0002FB P:0002FB 44F400            MOVE              #'REP',X0
                            524550
1218      P:0002FD P:0002FD 440B00            MOVE              X0,X:<DTXS_WD1          ; REPly
1219      P:0002FE P:0002FE 44F400            MOVE              #'RST',X0
                            525354
1220      P:000300 P:000300 440C00            MOVE              X0,X:<DTXS_WD2          ; echo command sent
1221      P:000301 P:000301 44F400            MOVE              #'ACK',X0
                            41434B
1222      P:000303 P:000303 440D00            MOVE              X0,X:<DTXS_WD3          ; ACKnowledge okay
1223      P:000304 P:000304 44F400            MOVE              #'000',X0
                            303030
1224      P:000306 P:000306 440E00            MOVE              X0,X:<DTXS_WD4          ; read data
1225      P:000307 P:000307 0D040F            JSR     <PCI_MESSAGE_TO_HOST
1226   
1227      P:000308 P:000308 0A00A4            JSET    #INTA_FLAG,X:<STATUS,*            ; wait for host to process
                            000308
1228   
1229      P:00030A P:00030A 0A0000            BCLR    #APPLICATION_LOADED,X:<STATUS     ; clear app flag
1230      P:00030B P:00030B 0A0006            BCLR    #PREAMBLE_ERROR,X:<STATUS         ; clear preamble error
1231      P:00030C P:00030C 0A000C            BCLR    #APPLICATION_RUNNING,X:<STATUS    ; clear appl running bit.
1232   
1233                                ; remember we are in a ISR so can't just jump to start.
1234   
1235      P:00030D P:00030D 08F4BF            MOVEP             #$0001C0,X:IPRC         ; Disable HF* FIFO interrupt
                            0001C0
1236      P:00030F P:00030F 05F439            MOVE              #$200,SR                ; Mask set up for reset switch only.
                            000200
1237   
1238   
1239      P:000311 P:000311 0501BB            MOVEC             #1,SP                   ; Point stack pointer to the top
1240      P:000312 P:000312 05F43D            MOVEC             #$000200,SSL            ; SSL holds SR return state
                            000200
1241                                                                                    ; set to zero except for interrupts
1242      P:000314 P:000314 0500BB            MOVEC             #0,SP                   ; Writing to SSH preincrements the SP
1243                                                                                    ; so first set to 0
1244      P:000315 P:000315 05F43C            MOVEC             #START,SSH              ; SSH holds return address of PC
                            000100
1245                                                                                    ; therefore,return to initialization
1246      P:000317 P:000317 000000            NOP
1247      P:000318 P:000318 000004            RTI                                       ; return from ISR - to START
1248   
1249                                ; when there is a failure in the host to PCI command then the PCI
1250                                ; needs still to reply to Host but with an error message
1251                                RST_ERROR
1252      P:000319 P:000319 44F400            MOVE              #'REP',X0
Motorola DSP56300 Assembler  Version 6.3.4   05-09-23  15:59:30  PCI_SCUBA_main.asm  Page 26



                            524550
1253      P:00031B P:00031B 440B00            MOVE              X0,X:<DTXS_WD1          ; REPly
1254      P:00031C P:00031C 44F400            MOVE              #'RST',X0
                            525354
1255      P:00031E P:00031E 440C00            MOVE              X0,X:<DTXS_WD2          ; echo command sent
1256      P:00031F P:00031F 44F400            MOVE              #'ERR',X0
                            455252
1257      P:000321 P:000321 440D00            MOVE              X0,X:<DTXS_WD3          ; ERRor im command
1258      P:000322 P:000322 44F400            MOVE              #'CNE',X0
                            434E45
1259      P:000324 P:000324 440E00            MOVE              X0,X:<DTXS_WD4          ; Command Name Error - command name in DRXR 
does not match
1260      P:000325 P:000325 0D0457            JSR     <RESTORE_REGISTERS                ; restore working registers
1261      P:000326 P:000326 0D040F            JSR     <PCI_MESSAGE_TO_HOST              ; interrupt host with message (x0 restored h
ere)
1262      P:000327 P:000327 000004            RTI                                       ; return from ISR
1263   
1264   
1265                                ;-----------------------------------------------------------------------------
1266                                START_APPLICATION
1267                                ; an application should already have been downloaded to the PCI memory.
1268                                ; this command will execute it.
1269                                ; ----------------------------------------------------------------------
1270                                ; word 1 = command = 'GOA'
1271                                ; word 2 = not used but read by RD_DRXR
1272                                ; word 3 = not used but read by RD_DRXR
1273                                ; word 4 = not used but read by RD_DRXR
1274   
1275      P:000328 P:000328 0D046C            JSR     <SAVE_REGISTERS                   ; save working registers
1276   
1277      P:000329 P:000329 0D042A            JSR     <RD_DRXR                          ; read words from host write to HTXR
1278      P:00032A P:00032A 568700            MOVE              X:<DRXR_WD1,A           ; read command
1279      P:00032B P:00032B 44F400            MOVE              #'GOA',X0
                            474F41
1280      P:00032D P:00032D 200045            CMP     X0,A                              ; ensure command is 'RDM'
1281      P:00032E P:00032E 0E2331            JNE     <GO_ERROR                         ; error, command NOT HCVR address
1282   
1283                                ; if we get here then everything is fine and we can start the application
1284                                ; set bit in status so that main fibre servicing code knows to jump
1285                                ; to application space after returning from this ISR
1286   
1287                                ; reply after application has been executed.
1288      P:00032F P:00032F 0A0020            BSET    #APPLICATION_LOADED,X:<STATUS
1289      P:000330 P:000330 000004            RTI                                       ; return from ISR
1290   
1291   
1292                                ; when there is a failure in the host to PCI command then the PCI
1293                                ; needs still to reply to Host but with an error message
1294                                GO_ERROR
1295      P:000331 P:000331 44F400            MOVE              #'REP',X0
                            524550
1296      P:000333 P:000333 440B00            MOVE              X0,X:<DTXS_WD1          ; REPly
1297      P:000334 P:000334 44F400            MOVE              #'GOA',X0
                            474F41
1298      P:000336 P:000336 440C00            MOVE              X0,X:<DTXS_WD2          ; echo command sent
1299      P:000337 P:000337 44F400            MOVE              #'ERR',X0
                            455252
1300      P:000339 P:000339 440D00            MOVE              X0,X:<DTXS_WD3          ; ERRor im command
1301      P:00033A P:00033A 44F400            MOVE              #'CNE',X0
                            434E45
1302      P:00033C P:00033C 440E00            MOVE              X0,X:<DTXS_WD4          ; Command Name Error - command name in DRXR 
does not match
Motorola DSP56300 Assembler  Version 6.3.4   05-09-23  15:59:30  PCI_SCUBA_main.asm  Page 27



1303      P:00033D P:00033D 0D0457            JSR     <RESTORE_REGISTERS                ; restore working registers
1304      P:00033E P:00033E 0D040F            JSR     <PCI_MESSAGE_TO_HOST              ; interrupt host with message (x0 restored h
ere)
1305      P:00033F P:00033F 000004            RTI                                       ; return from ISR
1306   
1307                                ; ---------------------------------------------------------
1308                                STOP_APPLICATION
1309                                ; this command stops an application that is currently running
1310                                ; used for applications that once started run contiunually
1311                                ;-----------------------------------------------------------
1312   
1313                                ; word 1 = command = ' STP'
1314                                ; word 2 = not used but read
1315                                ; word 3 = not used but read
1316                                ; word 4 = not used but read
1317   
1318      P:000340 P:000340 0D046C            JSR     <SAVE_REGISTERS
1319   
1320      P:000341 P:000341 0D042A            JSR     <RD_DRXR                          ; read words from host write to HTXR
1321      P:000342 P:000342 568700            MOVE              X:<DRXR_WD1,A           ; read command
1322      P:000343 P:000343 44F400            MOVE              #'STP',X0
                            535450
1323      P:000345 P:000345 200045            CMP     X0,A                              ; ensure command is 'RDM'
1324      P:000346 P:000346 0E2359            JNE     <STP_ERROR                        ; error, command NOT HCVR address
1325   
1326      P:000347 P:000347 0A0000            BCLR    #APPLICATION_LOADED,X:<STATUS
1327      P:000348 P:000348 0A700C            BCLR    #APPLICATION_RUNNING,X:STATUS
                            000000
1328   
1329                                ; when completed successfully then PCI needs to reply to Host with
1330                                ; word1 = reply/data = reply
1331                                FINISH_STP
1332      P:00034A P:00034A 44F400            MOVE              #'REP',X0
                            524550
1333      P:00034C P:00034C 440B00            MOVE              X0,X:<DTXS_WD1          ; REPly
1334      P:00034D P:00034D 44F400            MOVE              #'STP',X0
                            535450
1335      P:00034F P:00034F 440C00            MOVE              X0,X:<DTXS_WD2          ; echo command sent
1336      P:000350 P:000350 44F400            MOVE              #'ACK',X0
                            41434B
1337      P:000352 P:000352 440D00            MOVE              X0,X:<DTXS_WD3          ; ACKnowledge okay
1338      P:000353 P:000353 44F400            MOVE              #'000',X0
                            303030
1339      P:000355 P:000355 440E00            MOVE              X0,X:<DTXS_WD4          ; read data
1340      P:000356 P:000356 0D0457            JSR     <RESTORE_REGISTERS                ; restore working registers.
1341      P:000357 P:000357 0D040F            JSR     <PCI_MESSAGE_TO_HOST              ; interrupt host with message (x0 restored h
ere)
1342      P:000358 P:000358 000004            RTI
1343   
1344                                ; when there is a failure in the host to PCI command then the PCI
1345                                ; needs still to reply to Host but with an error message
1346                                STP_ERROR
1347      P:000359 P:000359 44F400            MOVE              #'REP',X0
                            524550
1348      P:00035B P:00035B 440B00            MOVE              X0,X:<DTXS_WD1          ; REPly
1349      P:00035C P:00035C 44F400            MOVE              #'STP',X0
                            535450
1350      P:00035E P:00035E 440C00            MOVE              X0,X:<DTXS_WD2          ; echo command sent
1351      P:00035F P:00035F 44F400            MOVE              #'ERR',X0
                            455252
1352      P:000361 P:000361 440D00            MOVE              X0,X:<DTXS_WD3          ; ERRor im command
1353      P:000362 P:000362 44F400            MOVE              #'CNE',X0
Motorola DSP56300 Assembler  Version 6.3.4   05-09-23  15:59:30  PCI_SCUBA_main.asm  Page 28



                            434E45
1354      P:000364 P:000364 440E00            MOVE              X0,X:<DTXS_WD4          ; Command Name Error - command name in DRXR 
does not match
1355      P:000365 P:000365 0D0457            JSR     <RESTORE_REGISTERS                ; restore working registers
1356      P:000366 P:000366 0D040F            JSR     <PCI_MESSAGE_TO_HOST              ; interrupt host with message (x0 restored h
ere)
1357      P:000367 P:000367 000004            RTI
1358   
1359                                ;--------------------------------------------------------------
1360                                WRITE_MEMORY
1361                                ;---------------------------------------------------------------
1362                                ; word 1 = command = 'WRM'
1363                                ; word 2 = memory type, P=$00'_P', X=$00'_X' or Y=$00'_Y'
1364                                ; word 3 = address in memory
1365                                ; word 4 = value
1366   
1367      P:000368 P:000368 0D046C            JSR     <SAVE_REGISTERS                   ; save working registers
1368   
1369      P:000369 P:000369 0D042A            JSR     <RD_DRXR                          ; read words from host write to HTXR
1370      P:00036A P:00036A 56F000            MOVE              X:DRXR_WD1,A            ; read command
                            000007
1371      P:00036C P:00036C 44F400            MOVE              #'WRM',X0
                            57524D
1372      P:00036E P:00036E 200045            CMP     X0,A                              ; ensure command is 'WRM'
1373      P:00036F P:00036F 0E2392            JNE     <WRITE_MEMORY_ERROR_CNE           ; error, command NOT HCVR address
1374      P:000370 P:000370 568800            MOVE              X:<DRXR_WD2,A           ; Memory type (X, Y, P)
1375      P:000371 P:000371 578900            MOVE              X:<DRXR_WD3,B
1376      P:000372 P:000372 000000            NOP                                       ; pipeline restriction
1377      P:000373 P:000373 21B000            MOVE              B1,R0                   ; get address to write to
1378      P:000374 P:000374 448A00            MOVE              X:<DRXR_WD4,X0          ; get data to write
1379      P:000375 P:000375 0140C5            CMP     #$005F50,A                        ; $00'_P'
                            005F50
1380      P:000377 P:000377 0E237A            JNE     <WRX
1381      P:000378 P:000378 076084            MOVE              X0,P:(R0)               ; Write to Program memory
1382      P:000379 P:000379 0C0383            JMP     <FINISH_WRITE_MEMORY
1383                                WRX
1384      P:00037A P:00037A 0140C5            CMP     #$005F58,A                        ; $00'_X'
                            005F58
1385      P:00037C P:00037C 0E237F            JNE     <WRY
1386      P:00037D P:00037D 446000            MOVE              X0,X:(R0)               ; Write to X: memory
1387      P:00037E P:00037E 0C0383            JMP     <FINISH_WRITE_MEMORY
1388                                WRY
1389      P:00037F P:00037F 0140C5            CMP     #$005F59,A                        ; $00'_Y'
                            005F59
1390      P:000381 P:000381 0E2396            JNE     <WRITE_MEMORY_ERROR_MTE
1391      P:000382 P:000382 4C6000            MOVE                          X0,Y:(R0)   ; Write to Y: memory
1392   
1393                                ; when completed successfully then PCI needs to reply to Host with
1394                                ; word1 = reply/data = reply
1395                                FINISH_WRITE_MEMORY
1396      P:000383 P:000383 44F400            MOVE              #'REP',X0
                            524550
1397      P:000385 P:000385 440B00            MOVE              X0,X:<DTXS_WD1          ; REPly
1398      P:000386 P:000386 44F400            MOVE              #'WRM',X0
                            57524D
1399      P:000388 P:000388 440C00            MOVE              X0,X:<DTXS_WD2          ; echo command sent
1400      P:000389 P:000389 44F400            MOVE              #'ACK',X0
                            41434B
1401      P:00038B P:00038B 440D00            MOVE              X0,X:<DTXS_WD3          ; ACKnowledge okay
1402      P:00038C P:00038C 44F400            MOVE              #'000',X0
                            303030
1403      P:00038E P:00038E 440E00            MOVE              X0,X:<DTXS_WD4          ; no error
Motorola DSP56300 Assembler  Version 6.3.4   05-09-23  15:59:30  PCI_SCUBA_main.asm  Page 29



1404      P:00038F P:00038F 0D0457            JSR     <RESTORE_REGISTERS                ; restore working registers
1405      P:000390 P:000390 0D040F            JSR     <PCI_MESSAGE_TO_HOST              ; interrupt host with message (x0 restored h
ere)
1406      P:000391 P:000391 000004            RTI
1407   
1408                                ;
1409                                WRITE_MEMORY_ERROR_CNE
1410      P:000392 P:000392 44F400            MOVE              #'CNE',X0
                            434E45
1411      P:000394 P:000394 440E00            MOVE              X0,X:<DTXS_WD4          ; Command Name Error - command name in DRXR 
does not match
1412      P:000395 P:000395 0C0399            JMP     <WRITE_MEMORY_ERROR               ; fill in rest of reply
1413   
1414                                WRITE_MEMORY_ERROR_MTE
1415      P:000396 P:000396 44F400            MOVE              #'MTE',X0
                            4D5445
1416      P:000398 P:000398 440E00            MOVE              X0,X:<DTXS_WD4          ; Memory Type Error - memory type not valid
1417   
1418                                WRITE_MEMORY_ERROR
1419      P:000399 P:000399 44F400            MOVE              #'REP',X0
                            524550
1420      P:00039B P:00039B 440B00            MOVE              X0,X:<DTXS_WD1          ; REPly
1421      P:00039C P:00039C 44F400            MOVE              #'WRM',X0
                            57524D
1422      P:00039E P:00039E 440C00            MOVE              X0,X:<DTXS_WD2          ; echo command sent
1423      P:00039F P:00039F 44F400            MOVE              #'ERR',X0
                            455252
1424      P:0003A1 P:0003A1 440D00            MOVE              X0,X:<DTXS_WD3          ; ERRor im command
1425      P:0003A2 P:0003A2 0D0457            JSR     <RESTORE_REGISTERS                ; restore working registers
1426      P:0003A3 P:0003A3 0D040F            JSR     <PCI_MESSAGE_TO_HOST              ; interrupt host with message (x0 restored h
ere)
1427      P:0003A4 P:0003A4 000004            RTI
1428   
1429   
1430                                ;---------------------------------------------------------------
1431                                ;
1432                                ;                          * END OF ISRs *
1433                                ;
1434                                ;--------------------------------------------------------------
1435   
1436   
1437   
1438                                ;----------------------------------------------------------------
1439                                ;
1440                                ;                     * Beginning of SUBROUTINES *
1441                                ;
1442                                ;-----------------------------------------------------------------
1443   
1444   
1445                                ; -------------------------------------------------------------
1446                                CALC_NO_BUFFS
1447                                ;----------------------------------------------------
1448                                ; number of 512 buffers in packet calculated (X:TOTAL_BUFFS)
1449                                ; and number of left over blocks (X:NUM_LEFTOVER_BLOCKS)
1450                                ; and left over words (X:LEFT_TO_READ)
1451   
1452      P:0003A5 P:0003A5 20001B            CLR     B
1453      P:0003A6 P:0003A6 51A200            MOVE              X:<HEAD_W4_0,B0         ; LS 16bits
1454      P:0003A7 P:0003A7 44A100            MOVE              X:<HEAD_W4_1,X0         ; MS 16bits
1455   
1456      P:0003A8 P:0003A8 0C1941            INSERT  #$010010,X0,B                     ; now size of packet B....giving # of 32bit 
words in packet
Motorola DSP56300 Assembler  Version 6.3.4   05-09-23  15:59:30  PCI_SCUBA_main.asm  Page 30



                            010010
1457      P:0003AA P:0003AA 000000            NOP
1458   
1459                                ; need to covert this to 16 bit since read from FIFO and saved in Y memory as 16bit words...
1460   
1461                                ; so double size of packet....
1462      P:0003AB P:0003AB 20003A            ASL     B
1463   
1464                                ; now save
1465      P:0003AC P:0003AC 212400            MOVE              B0,X0
1466      P:0003AD P:0003AD 21A500            MOVE              B1,X1
1467      P:0003AE P:0003AE 443500            MOVE              X0,X:<PACKET_SIZE_LOW   ; low 24 bits of packet size (in 16bit words
)
1468      P:0003AF P:0003AF 453600            MOVE              X1,X:<PACKET_SIZE_HIH   ; high 8 bits of packet size (in 16bit words
)
1469   
1470      P:0003B0 P:0003B0 50B500            MOVE              X:<PACKET_SIZE_LOW,A0
1471      P:0003B1 P:0003B1 54B600            MOVE              X:<PACKET_SIZE_HIH,A1
1472      P:0003B2 P:0003B2 0C1C12            ASR     #9,A,A                            ; divide by 512...number of 16bit words in a
 buffer
1473      P:0003B3 P:0003B3 000000            NOP
1474      P:0003B4 P:0003B4 503B00            MOVE              A0,X:<TOTAL_BUFFS
1475   
1476      P:0003B5 P:0003B5 210500            MOVE              A0,X1
1477      P:0003B6 P:0003B6 47F400            MOVE              #HF_FIFO,Y1
                            000200
1478      P:0003B8 P:0003B8 2000F0            MPY     X1,Y1,A
1479      P:0003B9 P:0003B9 0C1C03            ASR     #1,A,B                            ; B holds number of 16bit words in all full 
buffers
1480      P:0003BA P:0003BA 000000            NOP
1481   
1482      P:0003BB P:0003BB 50B500            MOVE              X:<PACKET_SIZE_LOW,A0
1483      P:0003BC P:0003BC 54B600            MOVE              X:<PACKET_SIZE_HIH,A1   ; A holds total number of 16bit words
1484      P:0003BD P:0003BD 200014            SUB     B,A                               ; now A holds number of left over 16bit word
s
1485      P:0003BE P:0003BE 000000            NOP
1486      P:0003BF P:0003BF 503C00            MOVE              A0,X:<LEFT_TO_READ      ; store number of left over 16bit words to r
ead
1487      P:0003C0 P:0003C0 0C1C0A            ASR     #5,A,A                            ; divide by 32... number of 16bit words in l
efover block
1488      P:0003C1 P:0003C1 000000            NOP
1489      P:0003C2 P:0003C2 503E00            MOVE              A0,X:<NUM_LEFTOVER_BLOCKS
1490      P:0003C3 P:0003C3 210500            MOVE              A0,X1
1491      P:0003C4 P:0003C4 47F400            MOVE              #>SMALL_BLK,Y1
                            000020
1492      P:0003C6 P:0003C6 2000F0            MPY     X1,Y1,A
1493      P:0003C7 P:0003C7 0C1C02            ASR     #1,A,A
1494      P:0003C8 P:0003C8 000000            NOP
1495   
1496      P:0003C9 P:0003C9 200018            ADD     A,B                               ; B holds words in all buffers
1497      P:0003CA P:0003CA 000000            NOP
1498      P:0003CB P:0003CB 50B500            MOVE              X:<PACKET_SIZE_LOW,A0
1499      P:0003CC P:0003CC 54B600            MOVE              X:<PACKET_SIZE_HIH,A1   ; A holds total number of words
1500      P:0003CD P:0003CD 200014            SUB     B,A                               ; now A holds number of left over words
1501      P:0003CE P:0003CE 000000            NOP
1502      P:0003CF P:0003CF 503C00            MOVE              A0,X:<LEFT_TO_READ      ; store number of left over 16bit words to r
ead
1503   
1504      P:0003D0 P:0003D0 0C1C02            ASR     #1,A,A                            ; divide by two to get number of 32 bit word
s to write
1505      P:0003D1 P:0003D1 000000            NOP                                       ; for pipeline
1506      P:0003D2 P:0003D2 503D00            MOVE              A0,X:<LEFT_TO_WRITE     ; store number of left over 32 bit words (2 
Motorola DSP56300 Assembler  Version 6.3.4   05-09-23  15:59:30  PCI_SCUBA_main.asm  Page 31



x 16 bit) to write to host after small block transfer as well
1507   
1508      P:0003D3 P:0003D3 00000C            RTS
1509   
1510                                ;---------------------------------------------------------------
1511                                GET_FO_WRD
1512                                ;--------------------------------------------------------------
1513                                ; Anything in fibre receive FIFO?   If so store in X0
1514   
1515      P:0003D4 P:0003D4 01AD80            JCLR    #EF,X:PDRD,CLR_FO_RTS
                            0003EA
1516      P:0003D6 P:0003D6 000000            NOP
1517      P:0003D7 P:0003D7 000000            NOP
1518      P:0003D8 P:0003D8 01AD80            JCLR    #EF,X:PDRD,CLR_FO_RTS             ; check twice for FO metastability.
                            0003EA
1519      P:0003DA P:0003DA 0AF080            JMP     RD_FO_WD
                            0003E2
1520   
1521      P:0003DC P:0003DC 01AD80  WT_FIFO   JCLR    #EF,X:PDRD,*                      ; Wait till something in FIFO flagged
                            0003DC
1522      P:0003DE P:0003DE 000000            NOP
1523      P:0003DF P:0003DF 000000            NOP
1524      P:0003E0 P:0003E0 01AD80            JCLR    #EF,X:PDRD,WT_FIFO                ; check twice.....
                            0003DC
1525   
1526                                ; Read one word from the fiber optics FIFO, check it and put it in A1
1527                                RD_FO_WD
1528      P:0003E2 P:0003E2 09443F            MOVEP             Y:RDFIFO,X0             ; then read to X0
1529      P:0003E3 P:0003E3 54F400            MOVE              #$00FFFF,A1             ; mask off top 2 bytes ($FC)
                            00FFFF
1530      P:0003E5 P:0003E5 200046            AND     X0,A                              ; since receiving 16 bits in 24bit register
1531      P:0003E6 P:0003E6 000000            NOP
1532      P:0003E7 P:0003E7 218400            MOVE              A1,X0
1533      P:0003E8 P:0003E8 0A0023            BSET    #FO_WRD_RCV,X:<STATUS
1534      P:0003E9 P:0003E9 00000C            RTS
1535                                CLR_FO_RTS
1536      P:0003EA P:0003EA 0A0003            BCLR    #FO_WRD_RCV,X:<STATUS
1537      P:0003EB P:0003EB 00000C            RTS
1538   
1539                                ;-----------------------------------------------
1540                                PCI_ERROR_RECOVERY
1541                                ;-----------------------------------------------
1542                                ; Recover from an error writing to the PCI bus
1543   
1544      P:0003EC P:0003EC 0A8A8A            JCLR    #TRTY,X:DPSR,ERROR1               ; Retry error
                            0003F1
1545      P:0003EE P:0003EE 08F48A            MOVEP             #$0400,X:DPSR           ; Clear target retry error bit
                            000400
1546      P:0003F0 P:0003F0 00000C            RTS
1547      P:0003F1 P:0003F1 0A8A8B  ERROR1    JCLR    #TO,X:DPSR,ERROR2                 ; Timeout error
                            0003F6
1548      P:0003F3 P:0003F3 08F48A            MOVEP             #$0800,X:DPSR           ; Clear timeout error bit
                            000800
1549      P:0003F5 P:0003F5 00000C            RTS
1550      P:0003F6 P:0003F6 0A8A89  ERROR2    JCLR    #TDIS,X:DPSR,ERROR3               ; Target disconnect error
                            0003FB
1551      P:0003F8 P:0003F8 08F48A            MOVEP             #$0200,X:DPSR           ; Clear target disconnect bit
                            000200
1552      P:0003FA P:0003FA 00000C            RTS
1553      P:0003FB P:0003FB 0A8A88  ERROR3    JCLR    #TAB,X:DPSR,ERROR4                ; Target abort error
                            000400
1554      P:0003FD P:0003FD 08F48A            MOVEP             #$0100,X:DPSR           ; Clear target abort error bit
Motorola DSP56300 Assembler  Version 6.3.4   05-09-23  15:59:30  PCI_SCUBA_main.asm  Page 32



                            000100
1555      P:0003FF P:0003FF 00000C            RTS
1556      P:000400 P:000400 0A8A87  ERROR4    JCLR    #MAB,X:DPSR,ERROR5                ; Master abort error
                            000405
1557      P:000402 P:000402 08F48A            MOVEP             #$0080,X:DPSR           ; Clear master abort error bit
                            000080
1558      P:000404 P:000404 00000C            RTS
1559      P:000405 P:000405 0A8A86  ERROR5    JCLR    #DPER,X:DPSR,ERROR6               ; Data parity error
                            00040A
1560      P:000407 P:000407 08F48A            MOVEP             #$0040,X:DPSR           ; Clear data parity error bit
                            000040
1561      P:000409 P:000409 00000C            RTS
1562      P:00040A P:00040A 0A8A85  ERROR6    JCLR    #APER,X:DPSR,ERROR7               ; Address parity error
                            00040E
1563      P:00040C P:00040C 08F48A            MOVEP             #$0020,X:DPSR           ; Clear address parity error bit
                            000020
1564      P:00040E P:00040E 00000C  ERROR7    RTS
1565   
1566                                ; ----------------------------------------------------------------------------
1567                                PCI_MESSAGE_TO_HOST
1568                                ;----------------------------------------------------------------------------
1569   
1570                                ; subroutine to send 4 words as a reply from PCI to the Host
1571                                ; using the DTXS-HRXS data path
1572                                ; PCI card writes here first then causes an interrupt INTA on
1573                                ; the PCI bus to alert the host to the reply message
1574   
1575   
1576   
1577      P:00040F P:00040F 0A00A4            JSET    #INTA_FLAG,X:<STATUS,*            ; make sure host ready to receive message
                            00040F
1578                                                                                    ; bit will be cleared by fast interrupt
1579                                                                                    ; if ready
1580      P:000411 P:000411 0A0024            BSET    #INTA_FLAG,X:<STATUS              ; set flag for next time round.....
1581   
1582   
1583      P:000412 P:000412 0A8981            JCLR    #STRQ,X:DSR,*                     ; Wait for transmitter to be NOT FULL
                            000412
1584                                                                                    ; i.e. if CLR then FULL so wait
1585                                                                                    ; if not then it is clear to write
1586      P:000414 P:000414 448B00            MOVE              X:<DTXS_WD1,X0
1587      P:000415 P:000415 447000            MOVE              X0,X:DTXS               ; Write 24 bit word1
                            FFFFCD
1588   
1589      P:000417 P:000417 0A8981            JCLR    #STRQ,X:DSR,*                     ; wait to be not full
                            000417
1590      P:000419 P:000419 448C00            MOVE              X:<DTXS_WD2,X0
1591      P:00041A P:00041A 447000            MOVE              X0,X:DTXS               ; Write 24 bit word2
                            FFFFCD
1592   
1593      P:00041C P:00041C 0A8981            JCLR    #STRQ,X:DSR,*                     ; wait to be not full
                            00041C
1594      P:00041E P:00041E 448D00            MOVE              X:<DTXS_WD3,X0
1595      P:00041F P:00041F 447000            MOVE              X0,X:DTXS               ; Write 24 bit word3
                            FFFFCD
1596   
1597      P:000421 P:000421 0A8981            JCLR    #STRQ,X:DSR,*                     ; wait to be not full
                            000421
1598      P:000423 P:000423 448E00            MOVE              X:<DTXS_WD4,X0
1599      P:000424 P:000424 447000            MOVE              X0,X:DTXS               ; Write 24 bit word4
                            FFFFCD
1600   
Motorola DSP56300 Assembler  Version 6.3.4   05-09-23  15:59:30  PCI_SCUBA_main.asm  Page 33



1601   
1602                                ; restore X0....
1603                                ; PCI_MESSAGE_TO_HOST is used by all command vector ISRs.
1604                                ; Working registers must be restored before RTI.
1605                                ; However, we want to restore before asserting INTA.
1606                                ; x0 is only one that can't be restored before PCI_MESSAGE_TO_HOST
1607                                ; (since it is used by this SR) hence we restore here.
1608                                ; this is redundant for a 'NFY' message (since sequential instruction)
1609                                ; but may be required for a PCI command reply 'REP' message.
1610                                ; (since interrupt driven)
1611   
1612      P:000426 P:000426 44F000            MOVE              X:SV_X0,X0              ; restore X0
                            00002D
1613   
1614                                ; all the transmit words are in the FIFO, interrupt the Host
1615                                ; the Host should clear this interrupt once it is detected.
1616                                ; It does this by writing to HCVR to cause a fast interrupt.
1617   
1618      P:000428 P:000428 0A8526            BSET    #INTA,X:DCTR                      ; Assert the interrupt
1619   
1620      P:000429 P:000429 00000C            RTS
1621   
1622                                ;---------------------------------------------------------------
1623                                RD_DRXR
1624                                ;--------------------------------------------------------------
1625                                ; routine is used to read from HTXR-DRXR data path
1626                                ; which is used by the Host to communicate with the PCI board
1627                                ; the host writes 4 words to this FIFO then interrupts the PCI
1628                                ; which reads the 4 words and acts on them accordingly.
1629   
1630   
1631      P:00042A P:00042A 0A8982            JCLR    #SRRQ,X:DSR,*                     ; Wait for receiver to be not empty
                            00042A
1632                                                                                    ; implies that host has written words
1633   
1634   
1635                                ; actually reading as slave here so this shouldn't be necessary......?
1636   
1637      P:00042C P:00042C 0A8717            BCLR    #FC1,X:DPMC                       ; 24 bit read FC1 = 0, FC1 = 0
1638      P:00042D P:00042D 0A8736            BSET    #FC0,X:DPMC
1639   
1640   
1641      P:00042E P:00042E 08440B            MOVEP             X:DRXR,X0               ; Get word1
1642      P:00042F P:00042F 440700            MOVE              X0,X:<DRXR_WD1
1643      P:000430 P:000430 08440B            MOVEP             X:DRXR,X0               ; Get word2
1644      P:000431 P:000431 440800            MOVE              X0,X:<DRXR_WD2
1645      P:000432 P:000432 08440B            MOVEP             X:DRXR,X0               ; Get word3
1646      P:000433 P:000433 440900            MOVE              X0,X:<DRXR_WD3
1647      P:000434 P:000434 08440B            MOVEP             X:DRXR,X0               ; Get word4
1648      P:000435 P:000435 440A00            MOVE              X0,X:<DRXR_WD4
1649      P:000436 P:000436 00000C            RTS
1650   
1651                                ;---------------------------------------------------------------
1652                                READ_FROM_PCI
1653                                ;--------------------------------------------------------------
1654                                ; sub routine to read a 24 bit word in from PCI bus --> Y memory
1655                                ; 32bit host address in accumulator B.
1656   
1657                                ; read as master
1658   
1659      P:000437 P:000437 0C1890            EXTRACTU #$010010,B,A                     ; Get D31-16 bits only
                            010010
Motorola DSP56300 Assembler  Version 6.3.4   05-09-23  15:59:30  PCI_SCUBA_main.asm  Page 34



1660      P:000439 P:000439 000000            NOP
1661   
1662      P:00043A P:00043A 210C00            MOVE              A0,A1
1663      P:00043B P:00043B 000000            NOP
1664      P:00043C P:00043C 547000            MOVE              A1,X:DPMC               ; high 16bits of address in DSP master cntr 
reg.
                            FFFFC7
1665                                                                                    ; 32 bit read so FC1 = 0 and FC0 = 0
1666   
1667      P:00043E P:00043E 000000            NOP
1668      P:00043F P:00043F 0C1890            EXTRACTU #$010000,B,A
                            010000
1669      P:000441 P:000441 000000            NOP
1670      P:000442 P:000442 210C00            MOVE              A0,A1
1671      P:000443 P:000443 0140C2            OR      #$060000,A                        ; A1 gets written to DPAR register
                            060000
1672      P:000445 P:000445 000000            NOP                                       ; C3-C0 of DPAR=0110 for memory read
1673      P:000446 P:000446 08CC08  WRT_ADD   MOVEP             A1,X:DPAR               ; Write address to PCI bus - PCI READ action
1674      P:000447 P:000447 000000            NOP                                       ; Pipeline delay
1675      P:000448 P:000448 0A8AA2  RD_PCI    JSET    #MRRQ,X:DPSR,GET_DAT              ; If MTRQ = 1 go read the word from host via
 FIFO
                            000451
1676      P:00044A P:00044A 0A8A8A            JCLR    #TRTY,X:DPSR,RD_PCI               ; Bit is set if its a retry
                            000448
1677      P:00044C P:00044C 08F48A            MOVEP             #$0400,X:DPSR           ; Clear bit 10 = target retry bit
                            000400
1678      P:00044E P:00044E 0A8A84            JCLR    #MARQ,X:DPSR,*                    ; Wait for PCI addressing to be complete
                            00044E
1679      P:000450 P:000450 0C0446            JMP     <WRT_ADD
1680   
1681      P:000451 P:000451 08440B  GET_DAT   MOVEP             X:DRXR,X0               ; Read 1st 16 bits of 32 bit word from host 
memory
1682      P:000452 P:000452 08450B            MOVEP             X:DRXR,X1               ; Read 2nd 16 bits of 32 bit word from host 
memory
1683   
1684                                ; note that we now have 4 bytes in X0 and X1.
1685                                ; The 32bit word was in host memory in little endian format
1686                                ; If form LSB --> MSB the bytes are b1, b2, b3, b4 in host memory
1687                                ; in progressing through the HTRX/DRXR FIFO the
1688                                ; bytes end up like this.....
1689                                ; then X0 = $00 b2 b1
1690                                ; and  X1 = $00 b4 b3
1691   
1692      P:000453 P:000453 0604A0            REP     #4                                ; increment PCI address by four bytes.
1693      P:000454 P:000454 000009            INC     B
1694      P:000455 P:000455 000000            NOP
1695      P:000456 P:000456 00000C            RTS
1696   
1697                                ;------------------------------------------------------------------------------------
1698                                RESTORE_REGISTERS
1699                                ;-------------------------------------------------------------------------------------
1700   
1701      P:000457 P:000457 05B139            MOVEC             X:<SV_SR,SR
1702   
1703      P:000458 P:000458 50A700            MOVE              X:<SV_A0,A0
1704      P:000459 P:000459 54A800            MOVE              X:<SV_A1,A1
1705      P:00045A P:00045A 52A900            MOVE              X:<SV_A2,A2
1706   
1707      P:00045B P:00045B 51AA00            MOVE              X:<SV_B0,B0
1708      P:00045C P:00045C 55AB00            MOVE              X:<SV_B1,B1
1709      P:00045D P:00045D 53AC00            MOVE              X:<SV_B2,B2
1710   
Motorola DSP56300 Assembler  Version 6.3.4   05-09-23  15:59:30  PCI_SCUBA_main.asm  Page 35



1711      P:00045E P:00045E 44AD00            MOVE              X:<SV_X0,X0
1712      P:00045F P:00045F 45AE00            MOVE              X:<SV_X1,X1
1713   
1714      P:000460 P:000460 46AF00            MOVE              X:<SV_Y0,Y0
1715      P:000461 P:000461 47B000            MOVE              X:<SV_Y1,Y1
1716   
1717      P:000462 P:000462 00000C            RTS
1718                                ;------------------------------------------------------------------------------------
1719                                RESTORE_HST_REGISTERS
1720                                ;-------------------------------------------------------------------------------------
1721                                ; B not restored after HST as it now contains address.
1722   
1723      P:000463 P:000463 05B139            MOVEC             X:<SV_SR,SR
1724   
1725      P:000464 P:000464 50A700            MOVE              X:<SV_A0,A0
1726      P:000465 P:000465 54A800            MOVE              X:<SV_A1,A1
1727      P:000466 P:000466 52A900            MOVE              X:<SV_A2,A2
1728   
1729      P:000467 P:000467 44AD00            MOVE              X:<SV_X0,X0
1730      P:000468 P:000468 45AE00            MOVE              X:<SV_X1,X1
1731   
1732      P:000469 P:000469 46AF00            MOVE              X:<SV_Y0,Y0
1733      P:00046A P:00046A 47B000            MOVE              X:<SV_Y1,Y1
1734   
1735      P:00046B P:00046B 00000C            RTS
1736   
1737                                ;-------------------------------------------------------------------------------------
1738                                SAVE_REGISTERS
1739                                ;-------------------------------------------------------------------------------------
1740   
1741      P:00046C P:00046C 053139            MOVEC             SR,X:<SV_SR             ; save status register.  May jump to ISR dur
ing CMP
1742   
1743      P:00046D P:00046D 502700            MOVE              A0,X:<SV_A0
1744      P:00046E P:00046E 542800            MOVE              A1,X:<SV_A1
1745      P:00046F P:00046F 522900            MOVE              A2,X:<SV_A2
1746   
1747      P:000470 P:000470 512A00            MOVE              B0,X:<SV_B0
1748      P:000471 P:000471 552B00            MOVE              B1,X:<SV_B1
1749      P:000472 P:000472 532C00            MOVE              B2,X:<SV_B2
1750   
1751      P:000473 P:000473 442D00            MOVE              X0,X:<SV_X0
1752      P:000474 P:000474 452E00            MOVE              X1,X:<SV_X1
1753   
1754      P:000475 P:000475 462F00            MOVE              Y0,X:<SV_Y0
1755      P:000476 P:000476 473000            MOVE              Y1,X:<SV_Y1
1756   
1757      P:000477 P:000477 00000C            RTS
1758   
1759   
1760   
1761                                ; ------------------------------------------------------------------------------------
1762                                WRITE_TO_PCI
1763                                ;-------------------------------------------------------------------------------------
1764                                ; sub routine to write two 16 bit words (stored in Y memory)
1765                                ; to host memory as PCI bus master.
1766                                ; results in a 32bit word written to host memory.
1767   
1768                                ; the 32 bit host address is in accumulator B.
1769                                ; this address is writen to DPMC (MSBs) and DPAR (LSBs)
1770                                ; address is incrememted by 4 (bytes) after write.
1771   
Motorola DSP56300 Assembler  Version 6.3.4   05-09-23  15:59:30  PCI_SCUBA_main.asm  Page 36



1772                                ; R2 is used as a pointer to Y:memory address
1773   
1774   
1775      P:000478 P:000478 0A8A81            JCLR    #MTRQ,X:DPSR,*                    ; wait here if DTXM is full
                            000478
1776   
1777      P:00047A P:00047A 08DACC  TX_LSB    MOVEP             Y:(R2)+,X:DTXM          ; Least significant word to transmit
1778      P:00047B P:00047B 08DACC  TX_MSB    MOVEP             Y:(R2)+,X:DTXM          ; Most significant word to transmit
1779   
1780   
1781      P:00047C P:00047C 0C1890            EXTRACTU #$010010,B,A                     ; Get D31-16 bits only,
                            010010
1782      P:00047E P:00047E 000000            NOP                                       ; top byte = $00 so FC1 = FC0 = 0
1783      P:00047F P:00047F 210C00            MOVE              A0,A1
1784   
1785                                ; we are using two 16 bit writes to make a 32bit word
1786                                ; so FC1=0 and FC0=0 when A1 written to DPMC
1787   
1788      P:000480 P:000480 000000            NOP
1789      P:000481 P:000481 547000            MOVE              A1,X:DPMC               ; DSP master control register
                            FFFFC7
1790      P:000483 P:000483 000000            NOP
1791      P:000484 P:000484 0C1890            EXTRACTU #$010000,B,A
                            010000
1792      P:000486 P:000486 000000            NOP
1793      P:000487 P:000487 210C00            MOVE              A0,A1
1794      P:000488 P:000488 0140C2            OR      #$070000,A                        ; A1 gets written to DPAR register
                            070000
1795      P:00048A P:00048A 000000            NOP
1796   
1797      P:00048B P:00048B 08CC08  AGAIN1    MOVEP             A1,X:DPAR               ; Write to PCI bus
1798      P:00048C P:00048C 000000            NOP                                       ; Pipeline delay
1799      P:00048D P:00048D 000000            NOP
1800      P:00048E P:00048E 0A8A84            JCLR    #MARQ,X:DPSR,*                    ; Bit is set if its a retry
                            00048E
1801      P:000490 P:000490 0A8AAE            JSET    #MDT,X:DPSR,INC_ADD               ; If no error go to the next sub-block
                            000494
1802      P:000492 P:000492 0D03EC            JSR     <PCI_ERROR_RECOVERY
1803      P:000493 P:000493 0C048B            JMP     <AGAIN1
1804                                INC_ADD
1805      P:000494 P:000494 205C13            CLR     A         (R4)+                   ; clear A and increment word count
1806      P:000495 P:000495 50F400            MOVE              #>4,A0                  ; 4 bytes per word transfer on pcibus
                            000004
1807      P:000497 P:000497 640618            ADD     A,B       R4,X:<WORD_COUNT        ; Inc bus address by 4 bytes, and save word 
count
1808      P:000498 P:000498 00000C            RTS
1809   
1810                                ; -------------------------------------------------------------------------------------------
1811                                WRITE_32_TO_PCI
1812                                ; DMAs 32 x 16bit words to host memory as PCI burst.
1813                                ;-----------------------------------------------------------------------------------------------
1814      P:000499 P:000499 3A2000            MOVE              #32,N2                  ; Number of 16bit words per transfer
1815      P:00049A P:00049A 3C1000            MOVE              #16,N4                  ; Number of 32bit words per transfer
1816   
1817      P:00049B P:00049B 627000            MOVE              R2,X:DSR0               ; Source address for DMA = pixel data
                            FFFFEF
1818      P:00049D P:00049D 08F4AE            MOVEP             #DTXM,X:DDR0            ; Destination = PCI master transmitter
                            FFFFCC
1819      P:00049F P:00049F 08F4AD            MOVEP             #>31,X:DCO0             ; DMA Count = # of pixels - 1
                            00001F
1820   
1821      P:0004A1 P:0004A1 0C1890            EXTRACTU #$010010,B,A                     ; Get D31-16 bits only
Motorola DSP56300 Assembler  Version 6.3.4   05-09-23  15:59:30  PCI_SCUBA_main.asm  Page 37



                            010010
1822      P:0004A3 P:0004A3 000000            NOP
1823      P:0004A4 P:0004A4 210C00            MOVE              A0,A1                   ; [D31-16] in A1
1824      P:0004A5 P:0004A5 000000            NOP
1825      P:0004A6 P:0004A6 0140C2            ORI     #$0F0000,A                        ; Burst length = # of PCI writes
                            0F0000
1826      P:0004A8 P:0004A8 000000            NOP                                       ;   = # of pixels / 2 - 1 ...$0F = 16
1827      P:0004A9 P:0004A9 547000            MOVE              A1,X:DPMC               ; DPMC = B[31:16] + $3F0000
                            FFFFC7
1828   
1829      P:0004AB P:0004AB 0C1890            EXTRACTU #$010000,B,A
                            010000
1830      P:0004AD P:0004AD 000000            NOP
1831      P:0004AE P:0004AE 210C00            MOVE              A0,A1                   ; Get PCI_ADDR[15:0] into A1[15:0]
1832      P:0004AF P:0004AF 000000            NOP
1833      P:0004B0 P:0004B0 0140C2            ORI     #$070000,A                        ; A1 gets written to DPAR register
                            070000
1834      P:0004B2 P:0004B2 000000            NOP
1835   
1836   
1837      P:0004B3 P:0004B3 08F4AC  AGAIN2    MOVEP             #$8EFA51,X:DCR0         ; Start DMA with control register DE=1
                            8EFA51
1838      P:0004B5 P:0004B5 08CC08            MOVEP             A1,X:DPAR               ; Initiate writing to the PCI bus
1839      P:0004B6 P:0004B6 000000            NOP
1840      P:0004B7 P:0004B7 000000            NOP
1841      P:0004B8 P:0004B8 0A8A84            JCLR    #MARQ,X:DPSR,*                    ; Wait until the PCI operation is done
                            0004B8
1842      P:0004BA P:0004BA 0A8AAE            JSET    #MDT,X:DPSR,WR_OK1                ; If no error go to the next sub-block
                            0004BE
1843      P:0004BC P:0004BC 0D03EC            JSR     <PCI_ERROR_RECOVERY
1844      P:0004BD P:0004BD 0C04B3            JMP     <AGAIN2                           ; Just try to write the sub-block again
1845                                WR_OK1
1846      P:0004BE P:0004BE 204C13            CLR     A         (R4)+N4                 ; increment number of 32bit word count
1847      P:0004BF P:0004BF 50F400            MOVE              #>64,A0                 ; 2 bytes on pcibus per pixel
                            000040
1848      P:0004C1 P:0004C1 640618            ADD     A,B       R4,X:<WORD_COUNT        ; PCI address = + 2 x # of pixels (!!!)
1849      P:0004C2 P:0004C2 204A00            MOVE              (R2)+N2                 ; Pixel buffer address = + # of pixels
1850      P:0004C3 P:0004C3 00000C            RTS
1851   
1852                                ;------------------------------------------------------------
1853                                WRITE_512_TO_PCI
1854                                ;-------------------------------------------------------------
1855                                ; DMAs 128 x 16bit words to host memory as PCI burst
1856                                ; does x 4 of these (total of 512 x 16bit words written to host memory)
1857                                ;
1858                                ; R2 is used as a pointer to Y:memory address
1859   
1860   
1861      P:0004C4 P:0004C4 3A8000            MOVE              #128,N2                 ; Number of 16bit words per transfer.
1862      P:0004C5 P:0004C5 3C4000            MOVE              #64,N4                  ; NUmber of 32bit words per transfer.
1863   
1864                                ; Make sure its always 512 pixels per loop = 1/2 FIFO
1865      P:0004C6 P:0004C6 627000            MOVE              R2,X:DSR0               ; Source address for DMA = pixel data
                            FFFFEF
1866      P:0004C8 P:0004C8 08F4AE            MOVEP             #DTXM,X:DDR0            ; Destination = PCI master transmitter
                            FFFFCC
1867      P:0004CA P:0004CA 08F4AD            MOVEP             #>127,X:DCO0            ; DMA Count = # of pixels - 1
                            00007F
1868   
1869                                ; Do loop does 4 x 128 pixel DMA writes = 512.
1870                                ; need to recalculate hi and lo parts of address
1871                                ; for each burst.....Leach code doesn't do this since not
Motorola DSP56300 Assembler  Version 6.3.4   05-09-23  15:59:30  PCI_SCUBA_main.asm  Page 38



1872                                ; multiple frames...so only needs to inc low part.....
1873   
1874      P:0004CC P:0004CC 060480            DO      #4,WR_BLK0                        ; x # of pixels = 512
                            0004EF
1875   
1876      P:0004CE P:0004CE 0C1890            EXTRACTU #$010010,B,A                     ; Get D31-16 bits only
                            010010
1877      P:0004D0 P:0004D0 000000            NOP
1878      P:0004D1 P:0004D1 210C00            MOVE              A0,A1                   ; [D31-16] in A1
1879      P:0004D2 P:0004D2 000000            NOP
1880      P:0004D3 P:0004D3 0140C2            ORI     #$3F0000,A                        ; Burst length = # of PCI writes
                            3F0000
1881      P:0004D5 P:0004D5 000000            NOP                                       ;   = # of pixels / 2 - 1 ...$3F = 63
1882      P:0004D6 P:0004D6 547000            MOVE              A1,X:DPMC               ; DPMC = B[31:16] + $3F0000
                            FFFFC7
1883   
1884   
1885      P:0004D8 P:0004D8 0C1890            EXTRACTU #$010000,B,A
                            010000
1886      P:0004DA P:0004DA 000000            NOP
1887      P:0004DB P:0004DB 210C00            MOVE              A0,A1                   ; Get PCI_ADDR[15:0] into A1[15:0]
1888      P:0004DC P:0004DC 000000            NOP
1889      P:0004DD P:0004DD 0140C2            OR      #$070000,A                        ; A1 gets written to DPAR register
                            070000
1890      P:0004DF P:0004DF 000000            NOP
1891   
1892   
1893      P:0004E0 P:0004E0 08F4AC  AGAIN0    MOVEP             #$8EFA51,X:DCR0         ; Start DMA with control register DE=1
                            8EFA51
1894      P:0004E2 P:0004E2 08CC08            MOVEP             A1,X:DPAR               ; Initiate writing to the PCI bus
1895      P:0004E3 P:0004E3 000000            NOP
1896      P:0004E4 P:0004E4 000000            NOP
1897      P:0004E5 P:0004E5 0A8A84            JCLR    #MARQ,X:DPSR,*                    ; Wait until the PCI operation is done
                            0004E5
1898      P:0004E7 P:0004E7 0A8AAE            JSET    #MDT,X:DPSR,WR_OK0                ; If no error go to the next sub-block
                            0004EB
1899      P:0004E9 P:0004E9 0D03EC            JSR     <PCI_ERROR_RECOVERY
1900      P:0004EA P:0004EA 0C04E0            JMP     <AGAIN0                           ; Just try to write the sub-block again
1901                                WR_OK0
1902   
1903      P:0004EB P:0004EB 204C13            CLR     A         (R4)+N4                 ; clear A and increment word count
1904      P:0004EC P:0004EC 50F400            MOVE              #>256,A0                ; 2 bytes on pcibus per pixel
                            000100
1905      P:0004EE P:0004EE 640618            ADD     A,B       R4,X:<WORD_COUNT        ; Inc bus address by # of bytes, and save wo
rd count
1906      P:0004EF P:0004EF 204A00            MOVE              (R2)+N2                 ; Pixel buffer address = + # of pixels
1907                                WR_BLK0
1908      P:0004F0 P:0004F0 00000C            RTS
1909   
1910                                ;-----------------------------
1911                                XMT_DLY
1912                                ;-----------------------------
1913                                ; Short delay for reliability
1914   
1915      P:0004F1 P:0004F1 000000            NOP
1916      P:0004F2 P:0004F2 000000            NOP
1917      P:0004F3 P:0004F3 000000            NOP
1918      P:0004F4 P:0004F4 00000C            RTS
1919   
1920                                ;-------------------------------------------------------
1921                                XMT_WD_FIBRE
1922                                ;-----------------------------------------------------
Motorola DSP56300 Assembler  Version 6.3.4   05-09-23  15:59:30  PCI_SCUBA_main.asm  Page 39



1923                                ; 250 MHz code - Transmit contents of Accumulator A1 to the MCE
1924                                ; we want to send 32bit word in little endian fomat to the host.
1925                                ; i.e. b4b3b2b1 goes b1, b2, b3, b4
1926                                ; currently the bytes are in this order:
1927                                ;  A1 = $00 b2 b1
1928                                ;  A0 = $00 b4 b3
1929                                ;  A = $00 00 b2 b1 00 b4 b3
1930   
1931                                ; This subroutine must take at least 160ns (4 bytes at 25Mbytes/s)
1932   
1933      P:0004F5 P:0004F5 000000            NOP
1934      P:0004F6 P:0004F6 000000            NOP
1935   
1936                                ; split up 4 bytes b2, b1, b4, b3
1937   
1938      P:0004F7 P:0004F7 0C1D20            ASL     #16,A,A                           ; shift byte b2 into A2
1939      P:0004F8 P:0004F8 60F400            MOVE              #$FFF000,R0             ; Memory mapped address of transmitter
                            FFF000
1940   
1941      P:0004FA P:0004FA 214700            MOVE              A2,Y1                   ; byte b2 in Y1
1942   
1943      P:0004FB P:0004FB 0C1D10            ASL     #8,A,A                            ; shift byte b1 into A2
1944      P:0004FC P:0004FC 000000            NOP
1945      P:0004FD P:0004FD 214600            MOVE              A2,Y0                   ; byte b1 in Y0
1946   
1947      P:0004FE P:0004FE 0C1D20            ASL     #16,A,A                           ; shift byte b4 into A2
1948      P:0004FF P:0004FF 000000            NOP
1949      P:000500 P:000500 214500            MOVE              A2,X1                   ; byte b4 in X1
1950   
1951   
1952      P:000501 P:000501 0C1D10            ASL     #8,A,A                            ; shift byte b3 into A2
1953      P:000502 P:000502 000000            NOP
1954      P:000503 P:000503 214400            MOVE              A2,X0                   ; byte b3 in x0
1955   
1956                                ; transmit b1, b2, b3 ,b4
1957   
1958      P:000504 P:000504 466000            MOVE              Y0,X:(R0)               ; byte b1 - off it goes
1959      P:000505 P:000505 476000            MOVE              Y1,X:(R0)               ; byte b2 - off it goes
1960      P:000506 P:000506 446000            MOVE              X0,X:(R0)               ; byte b3 - off it goes
1961      P:000507 P:000507 456000            MOVE              X1,X:(R0)               ; byte b4 - off it goes
1962   
1963      P:000508 P:000508 000000            NOP
1964      P:000509 P:000509 000000            NOP
1965      P:00050A P:00050A 00000C            RTS
1966   
1967   
1968                                BOOTCODE_END
1969                                 BOOTEND_ADDR
1970      00050B                              EQU     @CVI(BOOTCODE_END)
1971   
1972                                PROGRAM_END
1973      00050B                    PEND_ADDR EQU     @CVI(PROGRAM_END)
1974                                ;---------------------------------------------
1975   
1976   
1977                                ; --------------------------------------------------------------------
1978                                ; --------------- x memory parameter table ---------------------------
1979                                ; --------------------------------------------------------------------
1980   
1981      X:000000 P:00050B                   ORG     X:VAR_TBL,P:
1982   
1983   
Motorola DSP56300 Assembler  Version 6.3.4   05-09-23  15:59:30  PCI_SCUBA_main.asm  Page 40



1984                                          IF      @SCP("ONCE","ROM")                ; Boot ROM code
1986                                          ENDIF
1987   
1988                                          IF      @SCP("ONCE","ONCE")               ; Download via ONCE debugger
1989                                 VAR_TBL_START
1990      00050B                              EQU     @LCV(L)
1991                                          ENDIF
1992   
1993                                ; -----------------------------------------------
1994                                ; do not move these (X:0 --> x:3)
1995 d    X:000000 P:00050B 000000  STATUS    DC      0
1996 d                               FRAME_COUNT
1997 d    X:000001 P:00050C 000000            DC      0                                 ; used as a check....... increments for ever
y frame write.....must be cleared by host.
1998 d                               PRE_CORRUPT
1999 d    X:000002 P:00050D 000000            DC      0
2000 d    X:000003 P:00050E 410103  REV_NUMBER DC     $410103                           ; byte 0 = minor revision #
2001                                                                                    ; byte 1 = mayor revision #
2002                                                                                    ; byte 2 = release Version (ascii letter)
2003 d    X:000004 P:00050F 230905  REV_DATA  DC      $230905                           ; data: day-month-year
2004 d    X:000005 P:000510 C06238  P_CHECKSUM DC     $c06238                           ;**** DO NOT CHANGE
2005                                ; -------------------------------------------------
2006   
2007 d    X:000006 P:000511 000000  WORD_COUNT DC     0                                 ; word count.  Number of words successfully 
writen to host in last packet.
2008   
2009 d    X:000007 P:000512 000000  DRXR_WD1  DC      0
2010 d    X:000008 P:000513 000000  DRXR_WD2  DC      0
2011 d    X:000009 P:000514 000000  DRXR_WD3  DC      0
2012 d    X:00000A P:000515 000000  DRXR_WD4  DC      0
2013 d    X:00000B P:000516 000000  DTXS_WD1  DC      0
2014 d    X:00000C P:000517 000000  DTXS_WD2  DC      0
2015 d    X:00000D P:000518 000000  DTXS_WD3  DC      0
2016 d    X:00000E P:000519 000000  DTXS_WD4  DC      0
2017   
2018 d    X:00000F P:00051A 000000  PCI_WD1_1 DC      0
2019 d    X:000010 P:00051B 000000  PCI_WD1_2 DC      0
2020 d    X:000011 P:00051C 000000  PCI_WD2_1 DC      0
2021 d    X:000012 P:00051D 000000  PCI_WD2_2 DC      0
2022 d    X:000013 P:00051E 000000  PCI_WD3_1 DC      0
2023 d    X:000014 P:00051F 000000  PCI_WD3_2 DC      0
2024 d    X:000015 P:000520 000000  PCI_WD4_1 DC      0
2025 d    X:000016 P:000521 000000  PCI_WD4_2 DC      0
2026 d    X:000017 P:000522 000000  PCI_WD5_1 DC      0
2027 d    X:000018 P:000523 000000  PCI_WD5_2 DC      0
2028 d    X:000019 P:000524 000000  PCI_WD6_1 DC      0
2029 d    X:00001A P:000525 000000  PCI_WD6_2 DC      0
2030   
2031   
2032 d    X:00001B P:000526 000000  HEAD_W1_1 DC      0
2033 d    X:00001C P:000527 000000  HEAD_W1_0 DC      0
2034 d    X:00001D P:000528 000000  HEAD_W2_1 DC      0
2035 d    X:00001E P:000529 000000  HEAD_W2_0 DC      0
2036 d    X:00001F P:00052A 000000  HEAD_W3_1 DC      0
2037 d    X:000020 P:00052B 000000  HEAD_W3_0 DC      0
2038 d    X:000021 P:00052C 000000  HEAD_W4_1 DC      0
2039 d    X:000022 P:00052D 000000  HEAD_W4_0 DC      0
2040   
2041   
2042 d    X:000023 P:00052E 000000  REP_WD1   DC      0
2043 d    X:000024 P:00052F 000000  REP_WD2   DC      0
2044 d    X:000025 P:000530 000000  REP_WD3   DC      0
Motorola DSP56300 Assembler  Version 6.3.4   05-09-23  15:59:30  PCI_SCUBA_main.asm  Page 41



2045 d    X:000026 P:000531 000000  REP_WD4   DC      0
2046   
2047 d    X:000027 P:000532 000000  SV_A0     DC      0
2048 d    X:000028 P:000533 000000  SV_A1     DC      0
2049 d    X:000029 P:000534 000000  SV_A2     DC      0
2050 d    X:00002A P:000535 000000  SV_B0     DC      0
2051 d    X:00002B P:000536 000000  SV_B1     DC      0
2052 d    X:00002C P:000537 000000  SV_B2     DC      0
2053 d    X:00002D P:000538 000000  SV_X0     DC      0
2054 d    X:00002E P:000539 000000  SV_X1     DC      0
2055 d    X:00002F P:00053A 000000  SV_Y0     DC      0
2056 d    X:000030 P:00053B 000000  SV_Y1     DC      0
2057   
2058 d    X:000031 P:00053C 000000  SV_SR     DC      0                                 ; stauts register save.
2059   
2060 d    X:000032 P:00053D 000000  ZERO      DC      0
2061 d    X:000033 P:00053E 000001  ONE       DC      1
2062 d    X:000034 P:00053F 000004  FOUR      DC      4
2063   
2064 d                               PACKET_SIZE_LOW
2065 d    X:000035 P:000540 000000            DC      0
2066 d                               PACKET_SIZE_HIH
2067 d    X:000036 P:000541 000000            DC      0
2068   
2069 d    X:000037 P:000542 00A5A5  PREAMB1   DC      $A5A5                             ; pramble 16-bit word....2 of which make up 
first preamble 32bit word
2070 d    X:000038 P:000543 005A5A  PREAMB2   DC      $5A5A                             ; preamble 16-bit word....2 of which make up
 second preamble 32bit word
2071 d    X:000039 P:000544 004441  DATA_WD   DC      $4441                             ; "DA"
2072 d    X:00003A P:000545 005250  REPLY_WD  DC      $5250                             ; "RP"
2073   
2074 d                               TOTAL_BUFFS
2075 d    X:00003B P:000546 000000            DC      0                                 ; total number of 512 buffers in packet
2076 d                               LEFT_TO_READ
2077 d    X:00003C P:000547 000000            DC      0                                 ; number of words (16 bit) left to read afte
r last 512 buffer
2078 d                               LEFT_TO_WRITE
2079 d    X:00003D P:000548 000000            DC      0                                 ; number of woreds (32 bit) to write to host
 i.e. half of those left over read
2080 d                               NUM_LEFTOVER_BLOCKS
2081 d    X:00003E P:000549 000000            DC      0                                 ; small block DMA burst transfer
2082   
2083 d                               DATA_DLY_VAL
2084 d    X:00003F P:00054A 000000            DC      0                                 ; data delay value..  Delay added to first f
rame received after GO command
2085   
2086                                ;----------------------------------------------------------
2087   
2088   
2089   
2090                                          IF      @SCP("ONCE","ROM")                ; Boot ROM code
2092                                          ENDIF
2093   
2094                                          IF      @SCP("ONCE","ONCE")               ; Download via ONCE debugger
2095                                 VAR_TBL_END
2096      00054B                              EQU     @LCV(L)
2097                                          ENDIF
2098   
2099                                 VAR_TBL_LENGTH
2100      000040                              EQU     VAR_TBL_END-VAR_TBL_START
2101   
2102   
Motorola DSP56300 Assembler  Version 6.3.4   05-09-23  15:59:30  PCI_SCUBA_main.asm  Page 42



2103                                          IF      @CVS(N,*)>=APPLICATION
2105                                          ENDIF
2106   
2107   
2108                                ;--------------------------------------------
2109                                ; APPLICATION AREA
2110                                ;---------------------------------------------
2111                                          IF      @SCP("ONCE","ROM")                ; Download via ONCE debugger
2113                                          ENDIF
2114   
2115                                          IF      @SCP("ONCE","ONCE")               ; Download via ONCE debugger
2116      P:000800 P:000800                   ORG     P:APPLICATION,P:APPLICATION
2117                                          ENDIF
2118   
2119                                ; starts with no application loaded
2120                                ; so just reply with an error if we get a GOA command
2121      P:000800 P:000800 44F400            MOVE              #'REP',X0
                            524550
2122      P:000802 P:000802 440B00            MOVE              X0,X:<DTXS_WD1          ; REPly
2123      P:000803 P:000803 44F400            MOVE              #'GOA',X0
                            474F41
2124      P:000805 P:000805 440C00            MOVE              X0,X:<DTXS_WD2          ; echo command sent
2125      P:000806 P:000806 44F400            MOVE              #'ERR',X0
                            455252
2126      P:000808 P:000808 440D00            MOVE              X0,X:<DTXS_WD3          ; No Application Loaded
2127      P:000809 P:000809 44F400            MOVE              #'NAL',X0
                            4E414C
2128      P:00080B P:00080B 440E00            MOVE              X0,X:<DTXS_WD4          ; write to PCI memory error;
2129      P:00080C P:00080C 0D0457            JSR     <RESTORE_REGISTERS
2130      P:00080D P:00080D 0D040F            JSR     <PCI_MESSAGE_TO_HOST
2131      P:00080E P:00080E 0A0000            BCLR    #APPLICATION_LOADED,X:<STATUS
2132      P:00080F P:00080F 0C0168            JMP     PACKET_IN
2133   
2134   
2135      000810                    END_ADR   EQU     @LCV(L)                           ; End address of P: code written to ROM
2136   
**** 2137 [PCI_SCUBA_build.asm 25]:  Build is complete
2137                                          MSG     ' Build is complete'
2138   
2139   
2140   

0    Errors
0    Warnings


