Motorola DSP56300 Assembler  Version 6.3.4   05-04-07  11:14:42  PCI_SCUBA_build.asm  Page 1



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
44        000030           ARG_TBL   EQU     $30                               ; Command arguments and addresses
45        000060           TIM_TBL   EQU     ARG_TBL+$30                       ; Readout timing parameters
46        000100           TIM_LEN   EQU     $100                              ; Length of TIM_TBL = 256 bytes = 64 entries
47        000100           SC_TBL    EQU     $100                              ; Scatter/Gather table
48     
49        000800           IM_DA_TBL EQU     $800                              ; image data table in DRAM Y
50     
51                         APPLICATION
52        000800                     EQU     $800                              ; application memory start location in P memory
53                                                                             ; note applications should start with this address
54                                                                             ; and end with a JMP to PACKET_IN
55                                                                             ; if only want appl to run once
56                                                                             ; penultimate line of code should be
57                                                                             ; to clear bit APPLICATION_LOADED in STATUS
58                                                                             ; otherwise will run continusly until 'STP'
59                                                                             ; command is sent
60     
Motorola DSP56300 Assembler  Version 6.3.4   05-04-07  11:14:42  PCI_SCUBA_header.asm  Page 2



61        000000           BUSY      EQU     0                                 ; if bit 0 =1 if current block is being read or writt
en
62        0000FF           N_TABLE   EQU     255                               ; Number of entries in scatter/gather table
63                         ;NRDFIFO                EQU     128     ; Number of 512 pixel chunks in FIFO per
64                                                                             ;   image block
65     
66        000800           NO_BUFFERS EQU    2048                              ; number of buffers (512 words) in a block, i.e. Modu
lus of circular buffer
67        000200           HF_FIFO   EQU     512                               ; number of 16 bit words in a half full FIFO
68                         HF_FIFO_32BIT
69        000100                     EQU     256                               ; number of 32 bit words in a half full FIFO
70        000020           SMALL_BLK EQU     32                                ; small block burst size for < 512 pixels
71     
72                         IMAGE_BUFFER
73        000000                     EQU     0                                 ; location in y memory of image buffer....
74     
75                         ;Status bits
76     
77                         APPLICATION_LOADED
78        000000                     EQU     0                                 ; set if PCI application to run
79                         SEND_TO_HOST
80        000001                     EQU     1                                 ; set in HST ISR when host ready for packet
81        000002           ERROR_HF  EQU     2                                 ; - not used
82        000003           FO_WRD_RCV EQU    3                                 ; set when packet detected in FIFO - stays set till p
acket processed
83        000004           INTA_FLAG EQU     4                                 ; used for interupt handshaking with host
84        000005           BYTE_SWAP EQU     5                                 ; flag to show byte swapping enabled
85                         PREAMBLE_ERROR
86        000006                     EQU     6                                 ; set if preamble error detected
87        000007           DATA_DLY  EQU     7                                 ; set in CON ISR if MCE command is 'GO'.  USed to add
 delay to first returned data packet
88     
89     
90                         ; Various addressing control registers
91        FFFFFB           BCR       EQU     $FFFFFB                           ; Bus Control Register
92        FFFFFA           DCR       EQU     $FFFFFA                           ; DRAM Control Register
93        FFFFF9           AAR0      EQU     $FFFFF9                           ; Address Attribute Register, channel 0
94        FFFFF8           AAR1      EQU     $FFFFF8                           ; Address Attribute Register, channel 1
95        FFFFF7           AAR2      EQU     $FFFFF7                           ; Address Attribute Register, channel 2
96        FFFFF6           AAR3      EQU     $FFFFF6                           ; Address Attribute Register, channel 3
97        FFFFFD           PCTL      EQU     $FFFFFD                           ; PLL control register
98        FFFFFE           IPRP      EQU     $FFFFFE                           ; Interrupt Priority register - Peripheral
99        FFFFFF           IPRC      EQU     $FFFFFF                           ; Interrupt Priority register - Core
100    
101                        ; PCI control register
102       FFFFCD           DTXS      EQU     $FFFFCD                           ; DSP Slave transmit data FIFO
103       FFFFCC           DTXM      EQU     $FFFFCC                           ; DSP Master transmit data FIFO
104       FFFFCB           DRXR      EQU     $FFFFCB                           ; DSP Receive data FIFO
105       FFFFCA           DPSR      EQU     $FFFFCA                           ; DSP PCI Status Register
106       FFFFC9           DSR       EQU     $FFFFC9                           ; DSP Status Register
107       FFFFC8           DPAR      EQU     $FFFFC8                           ; DSP PCI Address Register
108       FFFFC7           DPMC      EQU     $FFFFC7                           ; DSP PCI Master Control Register
109       FFFFC6           DPCR      EQU     $FFFFC6                           ; DSP PCI Control Register
110       FFFFC5           DCTR      EQU     $FFFFC5                           ; DSP Control Register
111    
112                        ; Port E is the Synchronous Communications Interface (SCI) port
113       FFFF9F           PCRE      EQU     $FFFF9F                           ; Port Control Register
114       FFFF9E           PRRE      EQU     $FFFF9E                           ; Port Direction Register
115       FFFF9D           PDRE      EQU     $FFFF9D                           ; Port Data Register
116    
117                        ; Various PCI register bit equates
118       000001           STRQ      EQU     1                                 ; Slave transmit data request (DSR)
Motorola DSP56300 Assembler  Version 6.3.4   05-04-07  11:14:42  PCI_SCUBA_header.asm  Page 3



119       000002           SRRQ      EQU     2                                 ; Slave receive data request (DSR)
120       000017           HACT      EQU     23                                ; Host active, low true (DSR)
121       000001           MTRQ      EQU     1                                 ; Set whem master transmitter is not full (DPSR)
122       000004           MARQ      EQU     4                                 ; Master address request (DPSR)
123       000002           MRRQ      EQU     2                                 ; Master Receive Request (DPSR)
124       00000A           TRTY      EQU     10                                ; PCI Target Retry (DPSR)
125    
126       000005           APER      EQU     5                                 ; Address parity error
127       000006           DPER      EQU     6                                 ; Data parity error
128       000007           MAB       EQU     7                                 ; Master Abort
129       000008           TAB       EQU     8                                 ; Target Abort
130       000009           TDIS      EQU     9                                 ; Target Disconnect
131       00000B           TO        EQU     11                                ; Timeout
132       00000E           MDT       EQU     14                                ; Master Data Transfer complete
133       000002           SCLK      EQU     2                                 ; SCLK = transmitter special code
134    
135                        ; bits in DPMC
136    
137       000017           FC1       EQU     23
138       000016           FC0       EQU     22
139    
140    
141                        ; DMA register definitions
142       FFFFEF           DSR0      EQU     $FFFFEF                           ; Source address register
143       FFFFEE           DDR0      EQU     $FFFFEE                           ; Destination address register
144       FFFFED           DCO0      EQU     $FFFFED                           ; Counter register
145       FFFFEC           DCR0      EQU     $FFFFEC                           ; Control register
146    
147                        ; The DCTR host flags are written by the DSP and read by PCI host
148       000003           DCTR_RPLY EQU     3                                 ; Set after reply
149       000004           DCTR_BUF0 EQU     4                                 ; Set after buffer 0 is written to
150       000005           DCTR_BUF1 EQU     5                                 ; Set after buffer 1 is written to
151       000006           INTA      EQU     6                                 ; Request PCI interrupt
152    
153                        ; The DSR host flags are written by the PCI host and read by the DSP
154       000004           DSR_BUF0  EQU     4                                 ; PCI host sets this when copying buffer 0
155       000005           DSR_BUF1  EQU     5                                 ; PCI host sets this when copying buffer 1
156    
157                        ; DPCR bit definitions
158       00000E           CLRT      EQU     14                                ; Clear transmitter
159       000012           MACE      EQU     18                                ; Master access counter enable
160       000015           IAE       EQU     21                                ; Insert Address Enable
161    
162                        ; Addresses of ESSI port
163       FFFFBC           TX00      EQU     $FFFFBC                           ; Transmit Data Register 0
164       FFFFB7           SSISR0    EQU     $FFFFB7                           ; Status Register
165       FFFFB6           CRB0      EQU     $FFFFB6                           ; Control Register B
166       FFFFB5           CRA0      EQU     $FFFFB5                           ; Control Register A
167    
168                        ; SSI Control Register A Bit Flags
169       000006           TDE       EQU     6                                 ; Set when transmitter data register is empty
170    
171                        ; Miscellaneous addresses
172       FFFFFF           RDFIFO    EQU     $FFFFFF                           ; Read the FIFO for incoming fiber optic data
173       FFFF8F           TCSR0     EQU     $FFFF8F                           ; Triper timer control and status register 0
174       FFFF8B           TCSR1     EQU     $FFFF8B                           ; Triper timer control and status register 1
175       FFFF87           TCSR2     EQU     $FFFF87                           ; Triper timer control and status register 2
176    
177                        ;***************************************************************
178                        ; Phase Locked Loop initialization
179       050003           PLL_INIT  EQU     $050003                           ; PLL = 25 MHz x 4 = 100 MHz
180                        ;****************************************************************
Motorola DSP56300 Assembler  Version 6.3.4   05-04-07  11:14:42  PCI_SCUBA_header.asm  Page 4



181    
182                        ; Port C is Enhanced Synchronous Serial Port 0
183       FFFFBF           PCRC      EQU     $FFFFBF                           ; Port C Control Register
184       FFFFBE           PRRC      EQU     $FFFFBE                           ; Port C Data direction Register
185       FFFFBD           PDRC      EQU     $FFFFBD                           ; Port C GPIO Data Register
186    
187                        ; Port D is Enhanced Synchronous Serial Port 1
188       FFFFAF           PCRD      EQU     $FFFFAF                           ; Port D Control Register
189       FFFFAE           PRRD      EQU     $FFFFAE                           ; Port D Data direction Register
190       FFFFAD           PDRD      EQU     $FFFFAD                           ; Port D GPIO Data Register
191    
192                        ; Bit number definitions of GPIO pins on Port C
193       000002           ROM_FIFO  EQU     2                                 ; Select ROM or FIFO accesses for AA1
194    
195                        ; Bit number definitions of GPIO pins on Port D
196       000000           EF        EQU     0                                 ; FIFO Empty flag, low true
197       000001           HF        EQU     1                                 ; FIFO half full flag, low true
198       000002           RS        EQU     2                                 ; FIFO reset signal, low true
199       000003           FSYNC     EQU     3                                 ; High during image transmission
200       000004           AUX1      EQU     4                                 ; enable/disable byte swapping
201       000005           WRFIFO    EQU     5                                 ; Low true if FIFO is being written to
202    
203    
204                                  INCLUDE 'PCI_SCUBA_initialisation.asm'
205                              COMMENT *
206    
207                        This is the code which is executed first after power-up etc.
208                        It sets all the internal registers to their operating values,
209                        sets up the ISR vectors and inialises the hardware etc.
210    
211                        Project:     SCUBA 2
212                        Author:      DAVID ATKINSON
213                        Target:      250MHz SDSU PCI card - DSP56301
214                        Controller:  For use with SCUBA 2 Multichannel Electronics
215    
216                        Assembler directives:
217                                ROM=EEPROM => EEPROM CODE
218                                ROM=ONCE => ONCE CODE
219    
220                                *
221                                  PAGE    132                               ; Printronix page width - 132 columns
222                                  OPT     CEX                               ; print DC evaluations
223    
**** 224 [PCI_SCUBA_initialisation.asm 20]:  INCLUDE PCI_initialisation.asm HERE  
224                                  MSG     ' INCLUDE PCI_initialisation.asm HERE  '
225    
226                        ; The EEPROM boot code expects first to read 3 bytes specifying the number of
227                        ; program words, then 3 bytes specifying the address to start loading the
228                        ; program words and then 3 bytes for each program word to be loaded.
229                        ; The program words will be condensed into 24 bit words and stored in contiguous
230                        ; PRAM memory starting at the specified starting address. Program execution
231                        ; starts from the same address where loading started.
232    
233                        ; Special address for two words for the DSP to bootstrap code from the EEPROM
234                                  IF      @SCP("ROM","ROM")                 ; Boot from ROM on power-on
235       P:000000 P:000000                   ORG     P:0,P:0
236  d    P:000000 P:000000 000570            DC      END_ADR-INIT-2                    ; Number of boot words
237  d    P:000001 P:000001 000000            DC      INIT                              ; Starting address
238       P:000000 P:000002                   ORG     P:0,P:2
239       P:000000 P:000002 0C0030  INIT      JMP     <INIT_PCI                         ; Configure PCI port
240       P:000001 P:000003 000000            NOP
241                                           ENDIF
Motorola DSP56300 Assembler  Version 6.3.4   05-04-07  11:14:42  PCI_SCUBA_initialisation.asm  Page 5



242    
243    
244                                 ; This allows for the DSP to be loaded from the ONCE port via the WIGGLER
245                                 ; command converter
246                                           IF      @SCP("ROM","ONCE")                ; Download via ONCE debugger
250                                           ENDIF
251    
252                                 ; Vectored interrupt table, addresses at the beginning are reserved
253  d    P:000002 P:000004 000000            DC      0,0,0,0,0,0,0,0,0,0,0,0,0,0       ; $02-$0f Reserved
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
254  d    P:000010 P:000012 000000            DC      0,0                               ; $10-$13 Reserved
     d                      000000
255    
256                                 ; FIFO HF* flag interrupt vector is here at $12 - this is connected to the
257                                 ; IRQB* interrupt line so its ISR vector must be here
258  d    P:000012 P:000014 000000            DC      0,0                               ; $was ld scatter routine ...HF*
     d                      000000
259    
260                                 ; a software reset button on the font panel of the card is connected to the IRQC*
261                                 ; line which if pressed causes the DSP to jump to an ISR which causes the program
262                                 ; counter to the beginning of the program INIT and sets the stack pointer to TOP.
263       P:000014 P:000016 0BF080            JSR     CLEAN_UP_PCI                      ; $14 - Software reset switch
                            000206
264    
265  d    P:000016 P:000018 000000            DC      0,0,0,0,0,0,0,0,0,0,0,0           ; Reserved interrupts
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
266  d    P:000022 P:000024 000000            DC      0,0,0,0,0,0,0,0,0,0,0,0,0,0
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
Motorola DSP56300 Assembler  Version 6.3.4   05-04-07  11:14:42  PCI_SCUBA_initialisation.asm  Page 6



267    
268                                 ; Now we're at P:$30, where some unused vector addresses are located
269                                 ; This is ROM only code that is only executed once on power-up when the
270                                 ; ROM code is downloaded. It is skipped over on OnCE downloads.
271    
272                                 ; A few seconds after power up on the Host, it interrogates the PCI bus to find
273                                 ; out what boards are installed and configures this PCI board. The EEPROM booting
274                                 ; procedure ends with program execution  starting at P:$0 where the EEPROM has
275                                 ; inserted a JMP INIT_PCI instruction. This routine sets the PLL paramter and
276                                 ; does a self configuration and software reset of the PCI controller in the DSP.
277                                 ; After configuring the PCI controller the DSP program overwrites the instruction
278                                 ; at P:$0 with a new JMP START to skip over the INIT_PCI routine. The program at
279                                 ; START address begins configuring the DSP and processing commands.
280                                 ; Similarly the ONCE option places a JMP START at P:$0 to skip over the
281                                 ; INIT_PCI routine. If this routine where executed after the host computer had booted
282                                 ; it would cause it to crash since the host computer would overwrite the
283                                 ; configuration space with its own values and doesn't tolerate foreign values.
284    
285                                 ; Initialize the PLL - phase locked loop
286                                 INIT_PCI
287       P:000030 P:000032 08F4BD            MOVEP             #PLL_INIT,X:PCTL        ; Initialize PLL
                            050003
288       P:000032 P:000034 000000            NOP
289    
290                                 ; Program the PCI self-configuration registers
291       P:000033 P:000035 240000            MOVE              #0,X0
292       P:000034 P:000036 08F485            MOVEP             #$500000,X:DCTR         ; Set self-configuration mode
                            500000
293       P:000036 P:000038 0604A0            REP     #4
294       P:000037 P:000039 08C408            MOVEP             X0,X:DPAR               ; Dummy writes to configuration space
295       P:000038 P:00003A 08F487            MOVEP             #>$0000,X:DPMC          ; Subsystem ID
                            000000
296       P:00003A P:00003C 08F488            MOVEP             #>$0000,X:DPAR          ; Subsystem Vendor ID
                            000000
297    
298                                 ; PCI Personal reset
299       P:00003C P:00003E 08C405            MOVEP             X0,X:DCTR               ; Personal software reset
300       P:00003D P:00003F 000000            NOP
301       P:00003E P:000040 000000            NOP
302       P:00003F P:000041 0A89B7            JSET    #HACT,X:DSR,*                     ; Test for personal reset completion
                            00003F
303       P:000041 P:000043 07F084            MOVE              P:(*+3),X0              ; Trick to write "JMP <START" to P:0
                            000044
304       P:000043 P:000045 070004            MOVE              X0,P:(0)
305       P:000044 P:000046 0C0100            JMP     <START
306    
307  d    P:000045 P:000047 000000            DC      0,0,0,0,0,0,0,0,0,0,0,0           ; Filler
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
308  d    P:000051 P:000053 000000            DC      0,0,0,0,0,0,0,0,0,0,0,0           ; Filler
     d                      000000
     d                      000000
     d                      000000
Motorola DSP56300 Assembler  Version 6.3.4   05-04-07  11:14:42  PCI_SCUBA_initialisation.asm  Page 7



     d                      000000
     d                      000000
     d                      000000
     d                      000000
     d                      000000
     d                      000000
     d                      000000
     d                      000000
309  d    P:00005D P:00005F 000000            DC      0,0,0,0,0,0,0,0,0,0,0,0           ; $60-$71 Reserved PCI
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
310    
311                                 ;**************************************************************************
312                                 ; Check for program space overwriting of ISR starting at P:$72
313                                           IF      @CVS(N,*)>$71
315                                           ENDIF
316    
317                                 ;       ORG     P:$72,P:$72
318       P:000072 P:000074                   ORG     P:$72,P:$74
319    
320                                 ; This allows for the DSP to be loaded from the ONCE port via the WIGGLER
321                                 ; command converter
322                                           IF      @SCP("ROM","ONCE")                ; Download via ONCE debugger
324                                           ENDIF
325    
326    
327                                 ;**************************************************************************
328    
329                                 ; Three non-maskable fast interrupt service routines for clearing PCI interrupts
330                                 ; The Host will use these to clear the INTA* after it has serviced the interrupt
331                                 ; which had been generated by the PCI board.
332    
333       P:000072 P:000074 0A8506            BCLR    #INTA,X:DCTR                      ; $72/3 - Clear PCI interrupt
334       P:000073 P:000075 000000            NOP
335    
336       P:000074 P:000076 0A0004            BCLR    #INTA_FLAG,X:<STATUS              ; $74/5 - Clear PCI interrupt
337       P:000075 P:000077 000000            NOP                                       ; needs to be fast addressing <
338    
339       P:000076 P:000078 0A8506            BCLR    #INTA,X:DCTR                      ; $76/7 - Clear PCI interrupt
340       P:000077 P:000079 000000            NOP
341    
342                                 ; Interrupt locations for 7 available commands on PCI board
343                                 ; Each JSR takes up 2 locations in the table
344       P:000078 P:00007A 0BF080            JSR     WRITE_MEMORY                      ; $78
                            000212
345       P:00007A P:00007C 0BF080            JSR     READ_MEMORY                       ; $7A
                            000248
346       P:00007C P:00007E 0BF080            JSR     START_APPLICATION                 ; $7C
                            000280
347       P:00007E P:000080 0BF080            JSR     STOP_APPLICATION                  ; $7E
                            0002A7
348                                 ; software reset is the same as cleaning up the PCI - use same routine
349                                 ; when HOST does a RESET then this routine is run
Motorola DSP56300 Assembler  Version 6.3.4   05-04-07  11:14:42  PCI_SCUBA_initialisation.asm  Page 8



350       P:000080 P:000082 0BF080            JSR     SOFTWARE_RESET                    ; $80
                            0002CF
351       P:000082 P:000084 0BF080            JSR     SEND_PACKET_TO_CONTROLLER         ; $82
                            000304
352       P:000084 P:000086 0BF080            JSR     SEND_PACKET_TO_HOST               ; $84
                            00033A
353       P:000086 P:000088 0BF080            JSR     RESET_CONTROLLER                  ; $86
                            000362
354    
355    
356                                 ; ***********************************************************************
357                                 ; For now have boot code starting from P:$100
358                                 ; just to make debugging tidier etc.
359    
360       P:000100 P:000102                   ORG     P:$100,P:$102
361    
362                                 ; This allows for the DSP to be loaded from the ONCE port via the WIGGLER
363                                 ; command converter
364                                           IF      @SCP("ROM","ONCE")                ; Download via ONCE debugger
366                                           ENDIF
367                                 ; ***********************************************************************
368    
369    
370    
371                                 ; ******************************************************************
372                                 ;
373                                 ;       AA0 = RDFIFO* of incoming fiber optic data
374                                 ;       AA1 = EEPROM access
375                                 ;       AA2 = DRAM access
376                                 ;       AA3 = output to parallel data connector, for a video pixel clock
377                                 ;       $FFxxxx = Write to fiber optic transmitter
378                                 ;
379                                 ; ******************************************************************
380    
381    
382       P:000100 P:000102 08F487  START     MOVEP             #>$000001,X:DPMC
                            000001
383       P:000102 P:000104 0A8534            BSET    #20,X:DCTR                        ; HI32 mode = 1 => PCI
384       P:000103 P:000105 0A8515            BCLR    #21,X:DCTR
385       P:000104 P:000106 0A8516            BCLR    #22,X:DCTR
386       P:000105 P:000107 000000            NOP
387       P:000106 P:000108 0A8632            BSET    #MACE,X:DPCR                      ; Master access counter enable
388       P:000107 P:000109 000000            NOP
389    
390    
391                                 ;       BSET    #IAE,X:DPCR             ; Insert PCI address before data
392                                 ; Unlike Bob Leach's code
393                                 ; we don't want IAE set in DPCR or else  data read by DSP from
394                                 ; DRXR FIFO will contain address of data as well as data...
395    
396       P:000108 P:00010A 000000            NOP                                       ; End of PCI programming
397    
398    
399                                 ; Set operation mode register OMR to normal expanded
400       P:000109 P:00010B 0500BA            MOVEC             #$0000,OMR              ; Operating Mode Register = Normal Expanded
401       P:00010A P:00010C 0500BB            MOVEC             #0,SP                   ; Reset the Stack Pointer SP
402    
403                                 ; Program the serial port ESSI0 = Port C for serial transmission to
404                                 ;   the timing board
405       P:00010B P:00010D 07F43F            MOVEP             #>0,X:PCRC              ; Software reset of ESSI0
                            000000
406                                 ;**********************************************************************
Motorola DSP56300 Assembler  Version 6.3.4   05-04-07  11:14:42  PCI_SCUBA_initialisation.asm  Page 9



407       P:00010D P:00010F 07F435            MOVEP             #$00080B,X:CRA0         ; Divide 100.0 MHz by 24 to get 4.17 MHz
                            00080B
408                                                                                     ; DC0-CD4 = 0 for non-network operation
409                                                                                     ; WL0-WL2 = ALC = 0 for 2-bit data words
410                                                                                     ; SSC1 = 0 for SC1 not used
411                                 ;************************************************************************
412       P:00010F P:000111 07F436            MOVEP             #$010120,X:CRB0         ; SCKD = 1 for internally generated clock
                            010120
413                                                                                     ; SHFD = 0 for MSB shifted first
414                                                                                     ; CKP = 0 for rising clock edge transitions
415                                                                                     ; TE0 = 1 to enable transmitter #0
416                                                                                     ; MOD = 0 for normal, non-networked mode
417                                                                                     ; FSL1 = 1, FSL0 = 0 for on-demand transmit
418       P:000111 P:000113 07F43F            MOVEP             #%101000,X:PCRC         ; Control Register (0 for GPIO, 1 for ESSI)
                            000028
419                                                                                     ; Set SCK0 = P3, STD0 = P5 to ESSI0
420                                 ;********************************************************************************
421       P:000113 P:000115 07F43E            MOVEP             #%111100,X:PRRC         ; Data Direction Register (0 for In, 1 for O
ut)
                            00003C
422       P:000115 P:000117 07F43D            MOVEP             #%000000,X:PDRC         ; Data Register - AUX3 = i/p, AUX1 not used
                            000000
423                                 ;***********************************************************************************
424                                 ; 250MHz
425                                 ; Conversion from software bits to schematic labels for Port C and D
426                                 ;       PC0 = SC00 = AUX3               PD0 = SC10 = EF*
427                                 ;       PC1 = SC01 = A/B* = input       PD1 = SC11 = HF*
428                                 ;       PC2 = SC02 = No connect         PD2 = SC12 = RS*
429                                 ;       PC3 = SCK0 = No connect         PD3 = SCK1 = NWRFIFO*
430                                 ;       PC4 = SRD0 = AUX1               PD4 = SRD1 = No connect (** in 50Mhz this was MODE selec
t for 16 or 32 bit FO)
431                                 ;       PC5 = STD0 = No connect         PD5 = STD1 = WRFIFO*
432                                 ; ***********************************************************************************
433    
434    
435                                 ; ****************************************************************************
436                                 ; Program the serial port ESSI1 = Port D for general purpose I/O (GPIO)
437    
438       P:000117 P:000119 07F42F            MOVEP             #%000000,X:PCRD         ; Control Register (0 for GPIO, 1 for ESSI)
                            000000
439       P:000119 P:00011B 07F42E            MOVEP             #%011100,X:PRRD         ; Data Direction Register (0 for In, 1 for O
ut)
                            00001C
440       P:00011B P:00011D 07F42D            MOVEP             #%011000,X:PDRD         ; Data Register - Pulse RS* low
                            000018
441       P:00011D P:00011F 060AA0            REP     #10
442       P:00011E P:000120 000000            NOP
443       P:00011F P:000121 07F42D            MOVEP             #%011100,X:PDRD         ; Data Register - Pulse RS* high
                            00001C
444    
445                                 ; note.....in 50MHz bit 4 selected FO receive 'MODE'
446                                 ; MODE = 1, 32 bit receive on FO
447                                 ; MODE = 0, 16 bit receive on FO
448                                 ; ultracam always used MODE = 0
449                                 ; however here bit 4 PD4 not connected so 32 bit or 16bit?
450    
451    
452    
453                                 ; Program the SCI port to benign values
454       P:000121 P:000123 07F41F            MOVEP             #%000,X:PCRE            ; Port Control Register = GPIO
                            000000
455       P:000123 P:000125 07F41E            MOVEP             #%110,X:PRRE            ; Port Direction Register (0 = Input)
Motorola DSP56300 Assembler  Version 6.3.4   05-04-07  11:14:42  PCI_SCUBA_initialisation.asm  Page 10



                            000006
456       P:000125 P:000127 07F41D            MOVEP             #%010,X:PDRE            ; Port Data Register
                            000002
457                                 ;       PE0 = RXD
458                                 ;       PE1 = TXD
459                                 ;       PE2 = SCLK
460    
461                                 ; Program the triple timer to assert TCI0 as an GPIO output = 1
462       P:000127 P:000129 07F40F            MOVEP             #$2800,X:TCSR0
                            002800
463       P:000129 P:00012B 07F40B            MOVEP             #$2800,X:TCSR1
                            002800
464       P:00012B P:00012D 07F407            MOVEP             #$2800,X:TCSR2
                            002800
465    
466    
467                                 ; Program the address attribute pins AA0 to AA2. AA3 is not yet implemented.
468       P:00012D P:00012F 08F4B9            MOVEP             #$FFFC21,X:AAR0         ; Y = $FFF000 to $FFFFFF asserts Y:RDFIFO*
                            FFFC21
469       P:00012F P:000131 08F4B8            MOVEP             #$008929,X:AAR1         ; P = $008000 to $00FFFF asserts AA1 low tru
e
                            008929
470       P:000131 P:000133 08F4B7            MOVEP             #$000122,X:AAR2         ; Y = $000800 to $7FFFFF accesses SRAM
                            000122
471    
472    
473                                 ; Program the DRAM memory access and addressing
474       P:000133 P:000135 08F4BB            MOVEP             #$020022,X:BCR          ; Bus Control Register
                            020022
475       P:000135 P:000137 08F4BA            MOVEP             #$893A05,X:DCR          ; DRAM Control Register
                            893A05
476    
477    
478                                 ; Clear all PCI error conditions
479       P:000137 P:000139 084E0A            MOVEP             X:DPSR,A
480       P:000138 P:00013A 0140C2            OR      #$1FE,A
                            0001FE
481       P:00013A P:00013C 000000            NOP
482       P:00013B P:00013D 08CE0A            MOVEP             A,X:DPSR
483    
484                                 ; Enable one interrupt only: software reset switch
485       P:00013C P:00013E 08F4BF            MOVEP             #$0001C0,X:IPRC         ; IRQB priority = 1 (FIFO half full HF*)
                            0001C0
486                                                                                     ; IRQC priority = 2 (reset switch)
487       P:00013E P:000140 05F439            MOVE              #$200,SR                ; Mask set up for reset switch only
                            000200
488    
489    
490    
491                                 ; bob leach 250MHz code
492                                 ; Establish interrupt priority levels IPL
493                                 ;       MOVEP   #$0001C0,X:IPRC ; IRQC priority IPL = 2 (reset switch, edge)
494                                 ;                               ; IRQB priority IPL = 2 or 0
495                                 ;                               ;     (FIFO half full - HF*, level)
496                                 ;       MOVEP   #>2,X:IPRP      ; Enable PCI Host interrupts, IPL = 1
497                                 ;       BSET    #HCIE,X:DCTR    ; Enable host command interrupts
498                                 ;       MOVE    #0,SR           ; Don't mask any interrupts
499    
500    
501                                 ; Initialize the fiber optic serial transmitter to zero
502       P:000140 P:000142 01B786            JCLR    #TDE,X:SSISR0,*
                            000140
Motorola DSP56300 Assembler  Version 6.3.4   05-04-07  11:14:42  PCI_SCUBA_initialisation.asm  Page 11



503       P:000142 P:000144 07F43C            MOVEP             #$000000,X:TX00
                            000000
504    
505                                 ; Clear out the PCI receiver and transmitter FIFOs
506    
507                                 ; clear DTXM - master transmitter
508       P:000144 P:000146 0A862E            BSET    #CLRT,X:DPCR                      ; Clear the master transmitter DTXM
509       P:000145 P:000147 0A86AE            JSET    #CLRT,X:DPCR,*                    ; Wait for the clearing to be complete
                            000145
510    
511                                 ; clear DRXR - receiver
512    
513       P:000147 P:000149 0A8982  CLR0      JCLR    #SRRQ,X:DSR,CLR1                  ; Wait for the receiver to be empty
                            00014C
514       P:000149 P:00014B 08440B            MOVEP             X:DRXR,X0               ; Read receiver to empty it
515       P:00014A P:00014C 000000            NOP
516       P:00014B P:00014D 0C0147            JMP     <CLR0
517                                 CLR1
518    
519                                 ; added code to initialise x table slots to zero
520    
521       P:00014C P:00014E 200013            CLR     A
522       P:00014D P:00014F 60F400            MOVE              #NO_BUFFERS,R0          ; start address of table
                            000800
523       P:00014F P:000151 0600A8            REP     #NO_BUFFERS                       ; size of table
524       P:000150 P:000152 565800            MOVE              A,X:(R0)+
525    
526    
527                                 ;  PCI address increment of 4 added here.
528                                 ; Y register not used in any other part of code
529                                 ; other than ISRs which restore this value.
530                                 ; using Y reg enables the +4 increment to be done in one cycle
531                                 ; rather than rep #4 inc commands
532    
533       P:000151 P:000153 270000            MOVE              #0,Y1                   ; initialise Y for PCI increment.
534       P:000152 P:000154 46B500            MOVE              X:<FOUR,Y0
535    
536    
537                                 ; copy parameter table from P memory into X memory
538    
539                                 ; Move the table of constants from P: space to X: space
540       P:000153 P:000155 61F400            MOVE              #VAR_TBL_START,R1       ; Start of parameter table in P
                            00052F
541       P:000155 P:000157 300000            MOVE              #VAR_TBL,R0             ; start of parameter table in X
542       P:000156 P:000158 064180            DO      #VAR_TBL_LENGTH,X_WRITE
                            000159
543       P:000158 P:00015A 07D984            MOVE              P:(R1)+,X0
544       P:000159 P:00015B 445800            MOVE              X0,X:(R0)+              ; Write the constants to X:
545                                 X_WRITE
546    
547    
548                                 ; Her endth the initialisation code after power up only where the code has
549                                 ; been bootstrapped from the EEPROM - remember the code is not run if the
550                                 ; reset button is pressed only if the HOST computer has been RESET.
551    
552    
553       P:00015A P:00015C 0A0000            BCLR    #APPLICATION_LOADED,X:<STATUS     ; clear application flag
554    
555    
556    
557                                 ; disable FIFO HF* intererupt...not used anymore.
558    
Motorola DSP56300 Assembler  Version 6.3.4   05-04-07  11:14:42  PCI_SCUBA_initialisation.asm  Page 12



559       P:00015B P:00015D 08F4BF            MOVEP             #$0001C0,X:IPRC         ; Disable FIFO HF* interrupt
                            0001C0
560       P:00015D P:00015F 05F439            MOVEC             #$200,SR                ; Mask level 1 interrupts
                            000200
561    
562                                 ; BYTE SWAPPING is ENABLED
563       P:00015F P:000161 0A0025            BSET    #BYTE_SWAP,X:<STATUS              ; flag to let host know byte swapping on
564       P:000160 P:000162 013D24            BSET    #AUX1,X:PDRC                      ; enable hardware
565    
566       P:000161 P:000163 0A0006            BCLR    #PREAMBLE_ERROR,X:<STATUS         ; flag to let host know premable error
567    
568                                 ; END of Scuba 2 initialisation code after power up
569                                 ; --------------------------------------------------------------------
570                                           INCLUDE 'PCI_SCUBA_main.asm'
571                                  COMMENT *
572    
573                                 This is the main section of the pci card code.
574    
575                                 Project:     SCUBA 2
576                                 Author:      DAVID ATKINSON
577                                 Target:      250MHz SDSU PCI card - DSP56301
578                                 Controller:  For use with SCUBA 2 Multichannel Electronics
579    
580                                 Version:     Release Version A
581    
582    
583                                 Assembler directives:
584                                         ROM=EEPROM => EEPROM CODE
585                                         ROM=ONCE => ONCE CODE
586    
587                                         *
588                                           PAGE    132                               ; Printronix page width - 132 columns
589                                           OPT     CEX                               ; print DC evaluations
590    
**** 591 [PCI_SCUBA_main.asm 21]:  INCLUDE PCI_main.asm HERE  
591                                           MSG     ' INCLUDE PCI_main.asm HERE  '
592    
593                                 ; ****************************************************
594                                 ; ************* MAIN PACKET SWITCHING CODE ***********
595                                 ; ****************************************************
596    
597                                 ; initialse buffer pointers
598                                 PACKET_IN
599       P:000162 P:000164 310000            MOVE              #<IMAGE_BUFFER,R1       ; pointer for Fibre ---> Y mem
600       P:000163 P:000165 320000            MOVE              #<IMAGE_BUFFER,R2       ; pointer for Y mem ---> PCI BUS
601    
602                                 ; R1 used as pointer for data written to y:memory            FO --> (Y)
603                                 ; R2 used as pointer for date in y mem to be writen to host  (Y) --> HOST
604    
605    
606       P:000164 P:000166 0A7001            BCLR    #SEND_TO_HOST,X:STATUS            ; clear send to host flag
                            000000
607       P:000166 P:000168 0A0002            BCLR    #ERROR_HF,X:<STATUS               ; clear error flag
608       P:000167 P:000169 0A0003            BCLR    #FO_WRD_RCV,X:<STATUS             ; clear Fiber Optic flag
609    
610    
611                                 ; PCI test application loaded?
612       P:000168 P:00016A 0A00A0            JSET    #APPLICATION_LOADED,X:STATUS,APPLICATION ; at P:$800 for just now
                            000800
613    
614                                 ; if 'GOA' command has been sent will jump to application memory space
615                                 ; note that applications should terminate with the line 'JMP PACKET_IN'
Motorola DSP56300 Assembler  Version 6.3.4   05-04-07  11:14:42  PCI_SCUBA_main.asm  Page 13



616                                 ; terminate appl with a STP command
617    
618    
619       P:00016A P:00016C 0D04B3  CHK_FIFO  JSR     <GET_FO_WRD                       ; see if there's a 16-bit word in Fibre FIFO
 from MCE
620                                                                                     ; if so it will be in X0 (should be 'A5A5' -
 preamble)
621    
622    
623       P:00016B P:00016D 0A00A3            JSET    #FO_WRD_RCV,X:<STATUS,CHECK_WD    ; if there is check its preamble
                            00016E
624       P:00016D P:00016F 0C0162            JMP     <PACKET_IN                        ; else go back and repeat
625    
626                                 ; check that we have $a5a5a5a5 then $5a5a5a5a
627    
628       P:00016E P:000170 441700  CHECK_WD  MOVE              X0,X:<HEAD_W1_1         ;store received word
629       P:00016F P:000171 56F000            MOVE              X:PREAMB1,A
                            000039
630       P:000171 P:000173 200045            CMP     X0,A                              ; check it is correct
631       P:000172 P:000174 0E2186            JNE     <PRE_ERROR                        ; if not go to start
632    
633    
634       P:000173 P:000175 0D04BB            JSR     <WT_FIFO                          ; wait for next preamble 16-bit word
635       P:000174 P:000176 441800            MOVE              X0,X:<HEAD_W1_0         ;store received word
636       P:000175 P:000177 56F000            MOVE              X:PREAMB1,A
                            000039
637       P:000177 P:000179 200045            CMP     X0,A                              ; check it is correct
638       P:000178 P:00017A 0E2186            JNE     <PRE_ERROR                        ; if not go to start
639    
640    
641       P:000179 P:00017B 0D04BB            JSR     <WT_FIFO                          ; wait for next preamble 16-bit word
642       P:00017A P:00017C 441900            MOVE              X0,X:<HEAD_W2_1         ;store received word
643       P:00017B P:00017D 56F000            MOVE              X:PREAMB2,A
                            00003A
644       P:00017D P:00017F 200045            CMP     X0,A                              ; check it is correct
645       P:00017E P:000180 0E2186            JNE     <PRE_ERROR                        ; if not go to start
646    
647       P:00017F P:000181 0D04BB            JSR     <WT_FIFO                          ; wait for next preamble 16-bit word
648       P:000180 P:000182 441A00            MOVE              X0,X:<HEAD_W2_0         ;store received word
649       P:000181 P:000183 56F000            MOVE              X:PREAMB2,A
                            00003A
650       P:000183 P:000185 200045            CMP     X0,A                              ; check it is correct
651       P:000184 P:000186 0E2186            JNE     <PRE_ERROR                        ; if not go to start
652       P:000185 P:000187 0C0189            JMP     <PACKET_INFO                      ; get packet info
653    
654    
655                                 PRE_ERROR
656       P:000186 P:000188 0A0026            BSET    #PREAMBLE_ERROR,X:<STATUS         ; indicate a preamble error
657       P:000187 P:000189 440200            MOVE              X0,X:<PRE_CORRUPT       ; store corrupted word
658       P:000188 P:00018A 0C0162            JMP     <PACKET_IN                        ; wait for next packet
659    
660    
661                                 PACKET_INFO                                         ; packet preamble valid
662    
663                                 ; Packet preamle is valid so....
664                                 ; now get next two 32bit words.  i.e. $20205250 $00000004, or $20204441 $xxxxxxxx
665                                 ; note that these are received little endian (and byte swapped)
666                                 ; i.e. for RP receive 50 52 20 20  04 00 00 00
667                                 ; but byte swapped on arrival
668                                 ; 5250
669                                 ; 2020
670                                 ; 0004
Motorola DSP56300 Assembler  Version 6.3.4   05-04-07  11:14:42  PCI_SCUBA_main.asm  Page 14



671                                 ; 0000
672    
673       P:000189 P:00018B 0D04BB            JSR     <WT_FIFO
674       P:00018A P:00018C 441C00            MOVE              X0,X:<HEAD_W3_0         ; RP or DA
675       P:00018B P:00018D 0D04BB            JSR     <WT_FIFO
676       P:00018C P:00018E 441B00            MOVE              X0,X:<HEAD_W3_1         ; $2020
677       P:00018D P:00018F 0D04BB            JSR     <WT_FIFO
678       P:00018E P:000190 441E00            MOVE              X0,X:<HEAD_W4_0         ; packet size lo
679       P:00018F P:000191 0D04BB            JSR     <WT_FIFO
680       P:000190 P:000192 441D00            MOVE              X0,X:<HEAD_W4_1         ; packet size hi
681    
682       P:000191 P:000193 200013            CLR     A                                 ; check if it's a frame of data
683       P:000192 P:000194 449C00            MOVE              X:<HEAD_W3_0,X0
684       P:000193 P:000195 56BB00            MOVE              X:<DATA_WD,A            ; $4441
685       P:000194 P:000196 200045            CMP     X0,A
686       P:000195 P:000197 0AF0A2            JNE     MCE_PACKET                        ; if not - then must be a command reply
                            0001A6
687    
688    
689                                 ; we have a data pakcet - check if it's the first packet after the GO command has been issued...
690    
691       P:000197 P:000199 0A0087            JCLR    #DATA_DLY,X:STATUS,INC_FRAME_COUNT ; do we need to add a delay since first fra
me?
                            0001A1
692    
693                                 ; yes first frame after GO reply packet so add a delay.
694                                 PACKET_DELAY
695       P:000199 P:00019B 44F000            MOVE              X:DATA_DLY_VAL,X0
                            000040
696       P:00019B P:00019D 06C400            DO      X0,*+3                            ; 10ns x DATA_DLY_VAL
                            00019D
697       P:00019D P:00019F 000000            NOP
698       P:00019E P:0001A0 000000            NOP
699       P:00019F P:0001A1 0A7007            BCLR    #DATA_DLY,X:STATUS                ; clear so delay isn't added next time.
                            000000
700    
701    
702                                 INC_FRAME_COUNT                                     ; increment frame count
703       P:0001A1 P:0001A3 200013            CLR     A
704       P:0001A2 P:0001A4 508100            MOVE              X:<FRAME_COUNT,A0
705       P:0001A3 P:0001A5 000008            INC     A
706       P:0001A4 P:0001A6 000000            NOP
707       P:0001A5 P:0001A7 500100            MOVE              A0,X:<FRAME_COUNT
708    
709                                 ; *********************************************************************
710                                 ; *********************** IT'S A PAKCET FROM MCE ***********************
711                                 ; ***********************************************************************
712                                 ; ***  Data or reply packet from MCE *******
713    
714                                 ; prepare notify to inform host that a packet has arrived.
715    
716                                 MCE_PACKET
717       P:0001A6 P:0001A8 44F400            MOVE              #'NFY',X0               ; initialise communication to host as a noti
fy
                            4E4659
718       P:0001A8 P:0001AA 440700            MOVE              X0,X:<DTXS_WD1          ; 1st word transmitted to host to notify the
re's a message
719    
720       P:0001A9 P:0001AB 449C00            MOVE              X:<HEAD_W3_0,X0         ;RP or DA
721       P:0001AA P:0001AC 440800            MOVE              X0,X:<DTXS_WD2          ;2nd word transmitted to host to notify ther
e's a message
722    
Motorola DSP56300 Assembler  Version 6.3.4   05-04-07  11:14:42  PCI_SCUBA_main.asm  Page 15



723       P:0001AB P:0001AD 449E00            MOVE              X:<HEAD_W4_0,X0         ; size of packet LSB 16bits (# 32bit words)
724       P:0001AC P:0001AE 440900            MOVE              X0,X:<DTXS_WD3          ; 3rd word transmitted to host to notify the
re's a message
725    
726       P:0001AD P:0001AF 449D00            MOVE              X:<HEAD_W4_1,X0         ; size of packet MSB 16bits (# of 32bit word
s)
727       P:0001AE P:0001B0 440A00            MOVE              X0,X:<DTXS_WD4          ; 4th word transmitted to host to notify the
re's a message
728    
729    
730                                 ; ********************* HOW MANY BUFFERS *******************************************************
*********
731    
732                                 ; Note that this JSP uses accumulator B
733                                 ; therefore it MUST be run before we get the bus address from host...
734                                 ; i.e before we send 'NFY'
735    
736       P:0001AF P:0001B1 0D04FC            JSR     <CALC_NO_BUFFS                    ; subroutine which calculates the number of 
512 (16bit) buffers
737                                                                                     ; number of left over 32 (16bit) blocks
738                                                                                     ; and number of left overs (16bit) words
739    
740                                 ;  note that a 512 (16-bit) buffer is transfered to the host as a 256 x 32bit burst
741                                 ;            a 32  (16-bit) block is transfered to the host as a 16 x 32bit burst
742                                 ;            left over 16bit words are transfered to the host in pairs as 32bit words
743                                 ; **********************************************************************************************
******************
744    
745    
746       P:0001B0 P:0001B2 200013            CLR     A
747       P:0001B1 P:0001B3 44BC00            MOVE              X:<TOTAL_BUFFS,X0
748       P:0001B2 P:0001B4 200045            CMP     X0,A                              ; are there any 512 buffers to process
749       P:0001B3 P:0001B5 0EA1B5            JEQ     <CHK_SMALL_BLK                    ; is it a very small packet - i.e less than 
512 words so no 512 buffers
750       P:0001B4 P:0001B6 0C01BE            JMP     <WT_HOST_3                        ; there is a 512 block to move
751    
752                                 CHK_SMALL_BLK
753       P:0001B5 P:0001B7 200013            CLR     A
754       P:0001B6 P:0001B8 44BF00            MOVE              X:<NUM_LEFTOVER_BLOCKS,X0
755       P:0001B7 P:0001B9 200045            CMP     X0,A                              ; are there any 32 blocks to process
756       P:0001B8 P:0001BA 0E21BE            JNE     <WT_HOST_3                        ; there is a 32 (16bit) block to transfer
757    
758    
759       P:0001B9 P:0001BB 0D03AD  WT_HOST_2 JSR     <PCI_MESSAGE_TO_HOST              ; notify host of packet
760       P:0001BA P:0001BC 0A0081            JCLR    #SEND_TO_HOST,X:<STATUS,*         ; wait for host to reply - which it does wit
h 'send_packet_to_host' ISR
                            0001BA
761       P:0001BC P:0001BE 0A0001            BCLR    #SEND_TO_HOST,X:<STATUS           ; tidy up
762       P:0001BD P:0001BF 0C01E0            JMP     <LEFT_OVERS                       ; jump to left overs since HF not required
763    
764    
765       P:0001BE P:0001C0 0D03AD  WT_HOST_3 JSR     <PCI_MESSAGE_TO_HOST              ; notify host of packet
766       P:0001BF P:0001C1 0A0081            JCLR    #SEND_TO_HOST,X:<STATUS,*         ; wait for host to reply - which it does wit
h 'send_packet_to_host' ISR
                            0001BF
767       P:0001C1 P:0001C3 0A0001            BCLR    #SEND_TO_HOST,X:<STATUS           ; tidy up
768    
769    
770                                 ; we now have 32 bit address in accumulator B
771                                 ; from send-packet_to_host
772    
773                                 ; ************************* DO LOOP to write buffers to host ***********************************
Motorola DSP56300 Assembler  Version 6.3.4   05-04-07  11:14:42  PCI_SCUBA_main.asm  Page 16



***
774    
775       P:0001C2 P:0001C4 063C00            DO      X:<TOTAL_BUFFS,ALL_BUFFS_END
                            0001D0
776    
777    
778       P:0001C4 P:0001C6 310000            MOVE              #<IMAGE_BUFFER,R1       ; FO ---> Y mem
779       P:0001C5 P:0001C7 320000            MOVE              #<IMAGE_BUFFER,R2       ; Y mem ----->  PCI BUS
780    
781                                 WAIT_BUFF
782       P:0001C6 P:0001C8 01ADA1            JSET    #HF,X:PDRD,*                      ; Wait for FIFO to be half full + 1
                            0001C6
783       P:0001C8 P:0001CA 000000            NOP
784       P:0001C9 P:0001CB 000000            NOP
785       P:0001CA P:0001CC 01ADA1            JSET    #HF,X:PDRD,WAIT_BUFF              ; Protection against metastability
                            0001C6
786    
787    
788                                 ; Copy the image block as 512 x 16bit words to DSP Y: Memory using R1 as pointer
789       P:0001CC P:0001CE 060082            DO      #512,L_BUFFER
                            0001CE
790       P:0001CE P:0001D0 0959FF            MOVEP             Y:RDFIFO,Y:(R1)+
791                                 L_BUFFER
792    
793    
794                                 ; R2 points to data in Y memory to be written to host
795                                 ; host address is in B - got by SEND_PACKET_TO_HOST command
796                                 ; so we can now write this buffer to host
797    
798       P:0001CF P:0001D1 0D043A            JSR     <WRITE_512_TO_PCI                 ; this subroutine will increment host addres
s, which is in B and R2
799       P:0001D0 P:0001D2 000000            NOP
800                                 ALL_BUFFS_END                                       ; all buffers have been writen to host
801    
802                                 ; ******************************* END of buffer read/write DO LOOP *****************************
************************
803    
804                                 ; less than 512 pixels but if greater than 32 will then do bursts
805                                 ; of 16 x 32bit in length, if less than 32 then does single read writes
806    
807       P:0001D1 P:0001D3 063F00            DO      X:<NUM_LEFTOVER_BLOCKS,LEFTOVER_BLOCKS
                            0001DF
808       P:0001D3 P:0001D5 310000            MOVE              #<IMAGE_BUFFER,R1       ; FO ---> Y mem
809       P:0001D4 P:0001D6 320000            MOVE              #<IMAGE_BUFFER,R2       ; Y mem ----->  PCI BUS
810    
811       P:0001D5 P:0001D7 062080            DO      #32,S_BUFFER
                            0001DD
812       P:0001D7 P:0001D9 01AD80  WAIT_1    JCLR    #EF,X:PDRD,*                      ; Wait for the pixel datum to be there
                            0001D7
813       P:0001D9 P:0001DB 000000            NOP                                       ; Settling time
814       P:0001DA P:0001DC 000000            NOP
815       P:0001DB P:0001DD 01AD80            JCLR    #EF,X:PDRD,WAIT_1                 ; Protection against metastability
                            0001D7
816       P:0001DD P:0001DF 0959FF            MOVEP             Y:RDFIFO,Y:(R1)+
817                                 S_BUFFER
818    
819       P:0001DE P:0001E0 0D0466            JSR     <WRITE_32_TO_PCI                  ; write small blocks
820       P:0001DF P:0001E1 000000            NOP
821                                 LEFTOVER_BLOCKS
822    
823    
824    
Motorola DSP56300 Assembler  Version 6.3.4   05-04-07  11:14:42  PCI_SCUBA_main.asm  Page 17



825                                 LEFT_OVERS
826       P:0001E0 P:0001E2 310000            MOVE              #<IMAGE_BUFFER,R1       ; FO ---> Y mem
827       P:0001E1 P:0001E3 320000            MOVE              #<IMAGE_BUFFER,R2       ; Y mem ----->  PCI BUS
828    
829       P:0001E2 P:0001E4 063D00            DO      X:<LEFT_TO_READ,LEFT_OVERS_READ   ; read in remaining words of data packet
                            0001E5
830       P:0001E4 P:0001E6 0D04CB            JSR     <WT_FIFO_DA                       ; each word from FIFO to X0
831       P:0001E5 P:0001E7 4C5900            MOVE                          X0,Y:(R1)+  ; now store in Y memory
832                                 LEFT_OVERS_READ
833    
834                                 ; now write left overs to host as 32 bit words
835    
836       P:0001E6 P:0001E8 063E00            DO      X:LEFT_TO_WRITE,LEFT_OVERS_WRITEN ; left overs to write is half left overs rea
d - since 32 bit writes
                            0001E9
837       P:0001E8 P:0001EA 0BF080            JSR     WRITE_TO_PCI                      ; uses R2 as pointer to Y memory, host addre
ss in B
                            00041A
838                                 LEFT_OVERS_WRITEN
839    
840    
841    
842                                 ; reply to host's send_packet_to_host command
843    
844                                  HST_ACK_REP
845       P:0001EA P:0001EC 44F400            MOVE              #'REP',X0
                            524550
846       P:0001EC P:0001EE 440700            MOVE              X0,X:<DTXS_WD1          ; REPly
847       P:0001ED P:0001EF 44F400            MOVE              #'HST',X0
                            485354
848       P:0001EF P:0001F1 440800            MOVE              X0,X:<DTXS_WD2          ; echo command sent
849       P:0001F0 P:0001F2 44F400            MOVE              #'ACK',X0
                            41434B
850       P:0001F2 P:0001F4 440900            MOVE              X0,X:<DTXS_WD3          ; ACKnowledge okay
851       P:0001F3 P:0001F5 44F400            MOVE              #'000',X0
                            303030
852       P:0001F5 P:0001F7 440A00            MOVE              X0,X:<DTXS_WD4          ; no error
853       P:0001F6 P:0001F8 0D03AD            JSR     <PCI_MESSAGE_TO_HOST
854       P:0001F7 P:0001F9 0C0162            JMP     <PACKET_IN
855    
856                                 HST_ERR_REP
857       P:0001F8 P:0001FA 44F400            MOVE              #'REP',X0
                            524550
858       P:0001FA P:0001FC 440700            MOVE              X0,X:<DTXS_WD1          ; REPly
859       P:0001FB P:0001FD 44F400            MOVE              #'HST',X0
                            485354
860       P:0001FD P:0001FF 440800            MOVE              X0,X:<DTXS_WD2          ; echo command sent
861       P:0001FE P:000200 44F400            MOVE              #'ERR',X0
                            455252
862       P:000200 P:000202 440900            MOVE              X0,X:<DTXS_WD3          ; ACKnowledge okay
863       P:000201 P:000203 44F400            MOVE              #'HFE',X0
                            484645
864       P:000203 P:000205 440A00            MOVE              X0,X:<DTXS_WD4          ; HF error
865       P:000204 P:000206 0D03AD            JSR     <PCI_MESSAGE_TO_HOST
866       P:000205 P:000207 0C0162            JMP     <PACKET_IN                        ; return to service timing board fibre
867    
868    
869    
870    
871                                 ; ****************************************************************************************
872                                 ; ************************************ INTERRUPT ROUTINES ********************************
873                                 ; *****************************************************************************************
Motorola DSP56300 Assembler  Version 6.3.4   05-04-07  11:14:42  PCI_SCUBA_main.asm  Page 18



874    
875                                 ; ISR routines defined here
876                                 ; place holders only in place so we can build the code
877    
878                                 ; Clean up the PCI board from wherever it was executing
879                                 CLEAN_UP_PCI
880       P:000206 P:000208 08F4BF            MOVEP             #$0001C0,X:IPRC         ; Disable HF* FIFO interrupt
                            0001C0
881       P:000208 P:00020A 05F439            MOVE              #$200,SR                ; mask for reset interrupts only
                            000200
882    
883       P:00020A P:00020C 0501BB            MOVEC             #1,SP                   ; Point stack pointer to the top
884       P:00020B P:00020D 05F43D            MOVEC             #$000200,SSL            ; SR = zero except for interrupts
                            000200
885       P:00020D P:00020F 0500BB            MOVEC             #0,SP                   ; Writing to SSH preincrements the SP
886       P:00020E P:000210 05F43C            MOVEC             #START,SSH              ; Set PC to for full initialization
                            000100
887       P:000210 P:000212 000000            NOP
888       P:000211 P:000213 000004            RTI
889                                 ; ---------------------------------------------------------------------------
890    
891                                 WRITE_MEMORY
892                                 ; word 1 = command = 'WRM'
893                                 ; word 2 = memory type, P=$00'_P', X=$00'_X' or Y=$00'_Y'
894                                 ; word 3 = address in memory
895                                 ; word 4 = value
896       P:000212 P:000214 0D03A0            JSR     <RD_DRXR                          ; read words from host write to HTXR
897       P:000213 P:000215 56F000            MOVE              X:DRXR_WD1,A            ; read command
                            000003
898       P:000215 P:000217 44F400            MOVE              #'WRM',X0
                            57524D
899       P:000217 P:000219 200045            CMP     X0,A                              ; ensure command is 'WRM'
900       P:000218 P:00021A 0E223A            JNE     <WRITE_MEMORY_ERROR               ; error, command NOT HCVR address
901       P:000219 P:00021B 568400            MOVE              X:<DRXR_WD2,A           ; Memory type (X, Y, P)
902       P:00021A P:00021C 578500            MOVE              X:<DRXR_WD3,B
903       P:00021B P:00021D 000000            NOP                                       ; pipeline restriction
904       P:00021C P:00021E 21B000            MOVE              B1,R0                   ; get address to write to
905       P:00021D P:00021F 448600            MOVE              X:<DRXR_WD4,X0          ; get data to write
906       P:00021E P:000220 0140C5            CMP     #$005F50,A                        ; $00'_P'
                            005F50
907       P:000220 P:000222 0E2223            JNE     <WRX
908       P:000221 P:000223 076084            MOVE              X0,P:(R0)               ; Write to Program memory
909       P:000222 P:000224 0C022C            JMP     <FINISH_WRITE_MEMORY
910                                 WRX
911       P:000223 P:000225 0140C5            CMP     #$005F58,A                        ; $00'_X'
                            005F58
912       P:000225 P:000227 0E2228            JNE     <WRY
913       P:000226 P:000228 446000            MOVE              X0,X:(R0)               ; Write to X: memory
914       P:000227 P:000229 0C022C            JMP     <FINISH_WRITE_MEMORY
915                                 WRY
916       P:000228 P:00022A 0140C5            CMP     #$005F59,A                        ; $00'_Y'
                            005F59
917       P:00022A P:00022C 0E223A            JNE     <WRITE_MEMORY_ERROR
918       P:00022B P:00022D 4C6000            MOVE                          X0,Y:(R0)   ; Write to Y: memory
919    
920                                 ; when completed successfully then PCI needs to reply to Host with
921                                 ; word1 = reply/data = reply
922                                 FINISH_WRITE_MEMORY
923       P:00022C P:00022E 44F400            MOVE              #'REP',X0
                            524550
924       P:00022E P:000230 440700            MOVE              X0,X:<DTXS_WD1          ; REPly
925       P:00022F P:000231 44F400            MOVE              #'WRM',X0
Motorola DSP56300 Assembler  Version 6.3.4   05-04-07  11:14:42  PCI_SCUBA_main.asm  Page 19



                            57524D
926       P:000231 P:000233 440800            MOVE              X0,X:<DTXS_WD2          ; echo command sent
927       P:000232 P:000234 44F400            MOVE              #'ACK',X0
                            41434B
928       P:000234 P:000236 440900            MOVE              X0,X:<DTXS_WD3          ; ACKnowledge okay
929       P:000235 P:000237 44F400            MOVE              #'000',X0
                            303030
930       P:000237 P:000239 440A00            MOVE              X0,X:<DTXS_WD4          ; no error
931       P:000238 P:00023A 0D03AD            JSR     <PCI_MESSAGE_TO_HOST
932       P:000239 P:00023B 0C0247            JMP     <END_WRITE_MEMORY
933    
934                                 ; when there is a failure in the host to PCI command then the PCI
935                                 ; needs still to reply to Host but with an error message
936                                 WRITE_MEMORY_ERROR
937       P:00023A P:00023C 44F400            MOVE              #'REP',X0
                            524550
938       P:00023C P:00023E 440700            MOVE              X0,X:<DTXS_WD1          ; REPly
939       P:00023D P:00023F 44F400            MOVE              #'WRM',X0
                            57524D
940       P:00023F P:000241 440800            MOVE              X0,X:<DTXS_WD2          ; echo command sent
941       P:000240 P:000242 44F400            MOVE              #'ERR',X0
                            455252
942       P:000242 P:000244 440900            MOVE              X0,X:<DTXS_WD3          ; ERRor im command
943       P:000243 P:000245 44F400            MOVE              #'001',X0
                            303031
944       P:000245 P:000247 440A00            MOVE              X0,X:<DTXS_WD4          ; write to PCI memory error
945       P:000246 P:000248 0D03AD            JSR     <PCI_MESSAGE_TO_HOST
946                                 END_WRITE_MEMORY
947       P:000247 P:000249 000004            RTI
948    
949                                 ; ------------------------------------------------------------------------
950                                 READ_MEMORY
951                                 ; word 1 = command = 'RDM'
952                                 ; word 2 = memory type, P=$00'_P', X=$00_'X' or Y=$00_'Y'
953                                 ; word 3 = address in memory
954                                 ; word 4 = not used
955       P:000248 P:00024A 0D03A0            JSR     <RD_DRXR                          ; read words from host write to HTXR
956       P:000249 P:00024B 56F000            MOVE              X:DRXR_WD1,A            ; read command
                            000003
957       P:00024B P:00024D 44F400            MOVE              #'RDM',X0
                            52444D
958       P:00024D P:00024F 200045            CMP     X0,A                              ; ensure command is 'RDM'
959       P:00024E P:000250 0E2272            JNE     <READ_MEMORY_ERROR                ; error, command NOT HCVR address
960       P:00024F P:000251 568400            MOVE              X:<DRXR_WD2,A           ; Memory type (X, Y, P)
961       P:000250 P:000252 578500            MOVE              X:<DRXR_WD3,B
962       P:000251 P:000253 000000            NOP                                       ; pipeline restriction
963       P:000252 P:000254 21B000            MOVE              B1,R0                   ; get address to write to
964       P:000253 P:000255 448600            MOVE              X:<DRXR_WD4,X0          ; get data to write
965       P:000254 P:000256 0140C5            CMP     #$005F50,A                        ; $00'_P'
                            005F50
966       P:000256 P:000258 0E225A            JNE     <RDX
967       P:000257 P:000259 07E084            MOVE              P:(R0),X0               ; Read from P memory
968       P:000258 P:00025A 208E00            MOVE              X0,A                    ;
969       P:000259 P:00025B 0C0265            JMP     <FINISH_READ_MEMORY
970                                 RDX
971       P:00025A P:00025C 0140C5            CMP     #$005F58,A                        ; $00'_X'
                            005F58
972       P:00025C P:00025E 0E2260            JNE     <RDY
973       P:00025D P:00025F 44E000            MOVE              X:(R0),X0               ; Read from P memory
974       P:00025E P:000260 208E00            MOVE              X0,A
975       P:00025F P:000261 0C0265            JMP     <FINISH_READ_MEMORY
976                                 RDY
Motorola DSP56300 Assembler  Version 6.3.4   05-04-07  11:14:42  PCI_SCUBA_main.asm  Page 20



977       P:000260 P:000262 0140C5            CMP     #$005F59,A                        ; $00'_Y'
                            005F59
978       P:000262 P:000264 0E2272            JNE     <READ_MEMORY_ERROR
979       P:000263 P:000265 4CE000            MOVE                          Y:(R0),X0   ; Read from P memory
980       P:000264 P:000266 208E00            MOVE              X0,A
981    
982                                 ; when completed successfully then PCI needs to reply to Host with
983                                 ; word1 = reply/data = reply
984                                 FINISH_READ_MEMORY
985       P:000265 P:000267 44F400            MOVE              #'REP',X0
                            524550
986       P:000267 P:000269 440700            MOVE              X0,X:<DTXS_WD1          ; REPly
987       P:000268 P:00026A 44F400            MOVE              #'RDM',X0
                            52444D
988       P:00026A P:00026C 440800            MOVE              X0,X:<DTXS_WD2          ; echo command sent
989       P:00026B P:00026D 44F400            MOVE              #'ACK',X0
                            41434B
990       P:00026D P:00026F 440900            MOVE              X0,X:<DTXS_WD3          ;  im command
991       P:00026E P:000270 21C400            MOVE              A,X0
992       P:00026F P:000271 440A00            MOVE              X0,X:<DTXS_WD4          ; write to PCI memory error
993       P:000270 P:000272 0D03AD            JSR     <PCI_MESSAGE_TO_HOST
994       P:000271 P:000273 0C027F            JMP     <END_READ_MEMORY
995    
996                                 ; when there is a failure in the host to PCI command then the PCI
997                                 ; needs still to reply to Host but with an error message
998                                 READ_MEMORY_ERROR
999       P:000272 P:000274 44F400            MOVE              #'REP',X0
                            524550
1000      P:000274 P:000276 440700            MOVE              X0,X:<DTXS_WD1          ; REPly
1001      P:000275 P:000277 44F400            MOVE              #'RDM',X0
                            52444D
1002      P:000277 P:000279 440800            MOVE              X0,X:<DTXS_WD2          ; echo command sent
1003      P:000278 P:00027A 44F400            MOVE              #'ERR',X0
                            455252
1004      P:00027A P:00027C 440900            MOVE              X0,X:<DTXS_WD3          ; ERRor im command
1005      P:00027B P:00027D 44F400            MOVE              #'001',X0
                            303031
1006      P:00027D P:00027F 440A00            MOVE              X0,X:<DTXS_WD4          ; write to PCI memory error
1007      P:00027E P:000280 0D03AD            JSR     <PCI_MESSAGE_TO_HOST
1008                                END_READ_MEMORY
1009      P:00027F P:000281 000004            RTI
1010   
1011   
1012                                ; ----------------------------------------------------------------------
1013                                ; an application should already have been downloaded to the PCI memory
1014                                ; before this command is called - this command compares the
1015                                ; application name against the name in the GO command - if not the same
1016                                ; then error else switch on a flag to tell the boot code to start the application
1017   
1018                                START_APPLICATION
1019                                ; word 1 = command = 'GOA'
1020                                ; word 2 = application number or name
1021                                ; word 3 = not used but read
1022                                ; word 4 = not used but read
1023      P:000280 P:000282 0D03A0            JSR     <RD_DRXR                          ; read words from host write to HTXR
1024      P:000281 P:000283 568300            MOVE              X:<DRXR_WD1,A           ; read command
1025      P:000282 P:000284 44F400            MOVE              #'GOA',X0
                            474F41
1026      P:000284 P:000286 200045            CMP     X0,A                              ; ensure command is 'RDM'
1027      P:000285 P:000287 0E2298            JNE     <GO_ERROR                         ; error, command NOT HCVR address
1028      P:000286 P:000288 448400            MOVE              X:<DRXR_WD2,X0          ; APPLICATION NUMBER/NAME
1029      P:000287 P:000289 568500            MOVE              X:<DRXR_WD3,A           ; read word 3 - not used
Motorola DSP56300 Assembler  Version 6.3.4   05-04-07  11:14:42  PCI_SCUBA_main.asm  Page 21



1030      P:000288 P:00028A 578600            MOVE              X:<DRXR_WD4,B           ; read word 4 - not used
1031                                ; if we get here then everything is fine and we can start the application
1032                                ; but first we must reply to the host that everyting is fine and then
1033                                ;start the application
1034   
1035                                ; when completed successfully then PCI needs to reply to Host with
1036                                ; word1 = reply/data = reply
1037                                FINISH_GO
1038      P:000289 P:00028B 44F400            MOVE              #'REP',X0
                            524550
1039      P:00028B P:00028D 440700            MOVE              X0,X:<DTXS_WD1          ; REPly
1040      P:00028C P:00028E 44F400            MOVE              #'GOA',X0
                            474F41
1041      P:00028E P:000290 440800            MOVE              X0,X:<DTXS_WD2          ; echo command sent
1042      P:00028F P:000291 44F400            MOVE              #'ACK',X0
                            41434B
1043      P:000291 P:000293 440900            MOVE              X0,X:<DTXS_WD3          ; ACKnowledge okay
1044      P:000292 P:000294 44F400            MOVE              #'000',X0
                            303030
1045      P:000294 P:000296 440A00            MOVE              X0,X:<DTXS_WD4          ; read data
1046      P:000295 P:000297 0D03AD            JSR     <PCI_MESSAGE_TO_HOST
1047   
1048                                ; remember we are in an ISR so we just can't jump to any old code since
1049                                ; we must return from the ISR properly - thereofre we switched on a flag
1050                                ; in a STATUS word which tells the boot code that it has an application loaded
1051                                ; which it must now run
1052      P:000296 P:000298 0A0020            BSET    #APPLICATION_LOADED,X:<STATUS
1053      P:000297 P:000299 0C02A6            JMP     <END_GO
1054   
1055                                ; when there is a failure in the host to PCI command then the PCI
1056                                ; needs still to reply to Host but with an error message
1057                                GO_ERROR
1058      P:000298 P:00029A 44F400            MOVE              #'REP',X0
                            524550
1059      P:00029A P:00029C 440700            MOVE              X0,X:<DTXS_WD1          ; REPly
1060      P:00029B P:00029D 44F400            MOVE              #'GOA',X0
                            474F41
1061      P:00029D P:00029F 440800            MOVE              X0,X:<DTXS_WD2          ; echo command sent
1062      P:00029E P:0002A0 44F400            MOVE              #'ERR',X0
                            455252
1063      P:0002A0 P:0002A2 440900            MOVE              X0,X:<DTXS_WD3          ; ERRor im command
1064      P:0002A1 P:0002A3 44F400            MOVE              #'003',X0
                            303033
1065      P:0002A3 P:0002A5 440A00            MOVE              X0,X:<DTXS_WD4          ; write to PCI memory error
1066      P:0002A4 P:0002A6 0D03AD            JSR     <PCI_MESSAGE_TO_HOST
1067                                ; failure so ensure that no application is started
1068      P:0002A5 P:0002A7 0A0000            BCLR    #APPLICATION_LOADED,X:<STATUS
1069                                END_GO
1070      P:0002A6 P:0002A8 000004            RTI
1071   
1072                                ; ---------------------------------------------------------
1073                                ; this command stops an application that is already running
1074                                STOP_APPLICATION
1075                                ; word 1 = command = ' STP'
1076                                ; word 2 = application number or name
1077                                ; word 3 = not used but read
1078                                ; word 4 = not used but read
1079      P:0002A7 P:0002A9 0D03A0            JSR     <RD_DRXR                          ; read words from host write to HTXR
1080      P:0002A8 P:0002AA 568300            MOVE              X:<DRXR_WD1,A           ; read command
1081      P:0002A9 P:0002AB 44F400            MOVE              #'STP',X0
                            535450
1082      P:0002AB P:0002AD 200045            CMP     X0,A                              ; ensure command is 'RDM'
Motorola DSP56300 Assembler  Version 6.3.4   05-04-07  11:14:42  PCI_SCUBA_main.asm  Page 22



1083      P:0002AC P:0002AE 0E22BF            JNE     <STP_ERROR                        ; error, command NOT HCVR address
1084      P:0002AD P:0002AF 448400            MOVE              X:<DRXR_WD2,X0          ; APPLICATION NUMBER/NAME
1085      P:0002AE P:0002B0 568500            MOVE              X:<DRXR_WD3,A           ; read word 3 - not used
1086      P:0002AF P:0002B1 578600            MOVE              X:<DRXR_WD4,B           ; read word 4 - not used
1087                                ; if we get here then everything is fine and we can start the application
1088                                ; but first we must reply to the host that everyting is fine and then
1089                                ;start the application
1090   
1091                                ; when completed successfully then PCI needs to reply to Host with
1092                                ; word1 = reply/data = reply
1093                                FINISH_STP
1094      P:0002B0 P:0002B2 44F400            MOVE              #'REP',X0
                            524550
1095      P:0002B2 P:0002B4 440700            MOVE              X0,X:<DTXS_WD1          ; REPly
1096      P:0002B3 P:0002B5 44F400            MOVE              #'STP',X0
                            535450
1097      P:0002B5 P:0002B7 440800            MOVE              X0,X:<DTXS_WD2          ; echo command sent
1098      P:0002B6 P:0002B8 44F400            MOVE              #'ACK',X0
                            41434B
1099      P:0002B8 P:0002BA 440900            MOVE              X0,X:<DTXS_WD3          ; ACKnowledge okay
1100      P:0002B9 P:0002BB 44F400            MOVE              #'000',X0
                            303030
1101      P:0002BB P:0002BD 440A00            MOVE              X0,X:<DTXS_WD4          ; read data
1102      P:0002BC P:0002BE 0D03AD            JSR     <PCI_MESSAGE_TO_HOST
1103   
1104                                ; remember we are in an ISR so we just can't jump to any old code since
1105                                ; we must return from the ISR properly - therefore we switch the flag
1106                                ; off to tell the bootcode that no application is loaded
1107      P:0002BD P:0002BF 0A0000            BCLR    #APPLICATION_LOADED,X:<STATUS
1108      P:0002BE P:0002C0 0C02CE            JMP     <END_STP
1109   
1110                                ; when there is a failure in the host to PCI command then the PCI
1111                                ; needs still to reply to Host but with an error message
1112                                STP_ERROR
1113      P:0002BF P:0002C1 44F400            MOVE              #'REP',X0
                            524550
1114      P:0002C1 P:0002C3 440700            MOVE              X0,X:<DTXS_WD1          ; REPly
1115      P:0002C2 P:0002C4 44F400            MOVE              #'STP',X0
                            535450
1116      P:0002C4 P:0002C6 440800            MOVE              X0,X:<DTXS_WD2          ; echo command sent
1117      P:0002C5 P:0002C7 44F400            MOVE              #'ERR',X0
                            455252
1118      P:0002C7 P:0002C9 440900            MOVE              X0,X:<DTXS_WD3          ; ERRor im command
1119      P:0002C8 P:0002CA 44F400            MOVE              #'004',X0
                            303034
1120      P:0002CA P:0002CC 440A00            MOVE              X0,X:<DTXS_WD4          ; write to PCI memory error
1121      P:0002CB P:0002CD 0D03AD            JSR     <PCI_MESSAGE_TO_HOST
1122                                ; failure so ensure that application continues to run.
1123      P:0002CC P:0002CE 0A7020            BSET    #APPLICATION_LOADED,X:STATUS
                            000000
1124                                END_STP
1125      P:0002CE P:0002D0 000004            RTI
1126   
1127                                ; -------------------------------------------------------------------
1128                                ; nothing defined at present - just checks command and the replies
1129                                ; with ACKnowledge or ERRor
1130                                ; will modify later to do a nice cleanup and program start
1131                                SOFTWARE_RESET
1132                                ; word 1 = command = 'RST'
1133                                ; word 2 = not used but read
1134                                ; word 3 = not used but read
1135                                ; word 4 = not used but read
Motorola DSP56300 Assembler  Version 6.3.4   05-04-07  11:14:42  PCI_SCUBA_main.asm  Page 23



1136      P:0002CF P:0002D1 0D03A0            JSR     <RD_DRXR                          ; read words from host write to HTXR
1137      P:0002D0 P:0002D2 568300            MOVE              X:<DRXR_WD1,A           ; read command
1138      P:0002D1 P:0002D3 44F400            MOVE              #'RST',X0
                            525354
1139      P:0002D3 P:0002D5 200045            CMP     X0,A                              ; ensure command is 'RST'
1140      P:0002D4 P:0002D6 0E22F5            JNE     <RST_ERROR                        ; error, command NOT HCVR address
1141      P:0002D5 P:0002D7 448400            MOVE              X:<DRXR_WD2,X0          ; read but not used
1142      P:0002D6 P:0002D8 568500            MOVE              X:<DRXR_WD3,A           ; read word 3 - not used
1143      P:0002D7 P:0002D9 578600            MOVE              X:<DRXR_WD4,B           ; read word 4 - not used
1144                                ; if we get here then everything is fine and we can start the application
1145                                ; but first we must reply to the host that everyting is fine and then
1146                                ;start the application
1147   
1148                                ; when completed successfully then PCI needs to reply to Host with
1149                                ; word1 = reply/data = reply
1150                                FINISH_RST
1151      P:0002D8 P:0002DA 44F400            MOVE              #'REP',X0
                            524550
1152      P:0002DA P:0002DC 440700            MOVE              X0,X:<DTXS_WD1          ; REPly
1153      P:0002DB P:0002DD 44F400            MOVE              #'RST',X0
                            525354
1154      P:0002DD P:0002DF 440800            MOVE              X0,X:<DTXS_WD2          ; echo command sent
1155      P:0002DE P:0002E0 44F400            MOVE              #'ACK',X0
                            41434B
1156      P:0002E0 P:0002E2 440900            MOVE              X0,X:<DTXS_WD3          ; ACKnowledge okay
1157      P:0002E1 P:0002E3 44F400            MOVE              #'000',X0
                            303030
1158      P:0002E3 P:0002E5 440A00            MOVE              X0,X:<DTXS_WD4          ; read data
1159      P:0002E4 P:0002E6 0D03AD            JSR     <PCI_MESSAGE_TO_HOST
1160   
1161      P:0002E5 P:0002E7 0A00A4            JSET    #INTA_FLAG,X:<STATUS,*            ; wait for host to process
                            0002E5
1162   
1163      P:0002E7 P:0002E9 0A0000            BCLR    #APPLICATION_LOADED,X:<STATUS     ; clear app flag
1164      P:0002E8 P:0002EA 0A0006            BCLR    #PREAMBLE_ERROR,X:<STATUS         ; clear preamble error
1165   
1166                                ; remember we are in a ISR so can't just jump to start.
1167   
1168      P:0002E9 P:0002EB 08F4BF            MOVEP             #$0001C0,X:IPRC         ; Disable HF* FIFO interrupt
                            0001C0
1169      P:0002EB P:0002ED 05F439            MOVE              #$200,SR                ; Mask set up for reset switch only.
                            000200
1170   
1171   
1172      P:0002ED P:0002EF 0501BB            MOVEC             #1,SP                   ; Point stack pointer to the top
1173      P:0002EE P:0002F0 05F43D            MOVEC             #$000200,SSL            ; SSL holds SR return state
                            000200
1174                                                                                    ; set to zero except for interrupts
1175      P:0002F0 P:0002F2 0500BB            MOVEC             #0,SP                   ; Writing to SSH preincrements the SP
1176                                                                                    ; so first set to 0
1177      P:0002F1 P:0002F3 05F43C            MOVEC             #START,SSH              ; SSH holds return address of PC
                            000100
1178                                                                                    ; therefore,return to initialization
1179      P:0002F3 P:0002F5 000000            NOP
1180   
1181   
1182      P:0002F4 P:0002F6 0C0303            JMP     <END_RST
1183   
1184                                ; when there is a failure in the host to PCI command then the PCI
1185                                ; needs still to reply to Host but with an error message
1186                                RST_ERROR
1187      P:0002F5 P:0002F7 44F400            MOVE              #'REP',X0
Motorola DSP56300 Assembler  Version 6.3.4   05-04-07  11:14:42  PCI_SCUBA_main.asm  Page 24



                            524550
1188      P:0002F7 P:0002F9 440700            MOVE              X0,X:<DTXS_WD1          ; REPly
1189      P:0002F8 P:0002FA 44F400            MOVE              #'RST',X0
                            525354
1190      P:0002FA P:0002FC 440800            MOVE              X0,X:<DTXS_WD2          ; echo command sent
1191      P:0002FB P:0002FD 44F400            MOVE              #'ERR',X0
                            455252
1192      P:0002FD P:0002FF 440900            MOVE              X0,X:<DTXS_WD3          ; ERRor im command
1193      P:0002FE P:000300 44F400            MOVE              #'005',X0
                            303035
1194      P:000300 P:000302 440A00            MOVE              X0,X:<DTXS_WD4          ; write to PCI memory error
1195      P:000301 P:000303 0D03AD            JSR     <PCI_MESSAGE_TO_HOST
1196                                ; failure so ensure that application continues to run.
1197      P:000302 P:000304 0A0020            BSET    #APPLICATION_LOADED,X:<STATUS
1198                                END_RST
1199      P:000303 P:000305 000004            RTI
1200   
1201                                ; ---------------------------------------------------------------
1202   
1203                                ; forward packet stuff to the MCE
1204                                ; gets address in HOST memory where packet is stored
1205                                ; read 3 consecutive locations starting at this address
1206                                ; then sends the data from these locations up to the MCE
1207                                SEND_PACKET_TO_CONTROLLER
1208   
1209                                ; word 1 = command = 'CON'
1210                                ; word 2 = host high address
1211                                ; word 3 = host low address
1212                                ; word 4 = '0' --> when MCE command is RS,WB,RB,ST
1213                                ;        = '1' --> when MCE command is GO
1214                                ; all MCE commands are now 'block commands'
1215                                ; i.e. 64 words long.
1216   
1217   
1218      P:000304 P:000306 0D03A0            JSR     <RD_DRXR                          ; read words from host write to HTXR
1219                                                                                    ; reads as 4 x 24 bit words
1220   
1221      P:000305 P:000307 568300            MOVE              X:<DRXR_WD1,A           ; read command
1222      P:000306 P:000308 44F400            MOVE              #'CON',X0
                            434F4E
1223      P:000308 P:00030A 200045            CMP     X0,A                              ; ensure command is 'CON'
1224      P:000309 P:00030B 0E232C            JNE     <CON_ERROR                        ; error, command NOT HCVR address
1225   
1226                                ; convert 2 x 24 bit words ( only 16 LSBs are significant) from host into 32 bit address
1227      P:00030A P:00030C 20001B            CLR     B
1228      P:00030B P:00030D 448400            MOVE              X:<DRXR_WD2,X0          ; MS 16bits of address
1229      P:00030C P:00030E 518500            MOVE              X:<DRXR_WD3,B0          ; LS 16bits of address
1230      P:00030D P:00030F 0C1941            INSERT  #$010010,X0,B                     ; convert to 32 bits and put in B
                            010010
1231   
1232      P:00030F P:000311 568600            MOVE              X:<DRXR_WD4,A           ; read word 4 - GO command?
1233      P:000310 P:000312 44F000            MOVE              X:ZERO,X0
                            000031
1234      P:000312 P:000314 200045            CMP     X0,A
1235      P:000313 P:000315 0AF0AA            JEQ     BLOCK_CON
                            000317
1236   
1237                                SET_PACKET_DELAY
1238      P:000315 P:000317 0A7027            BSET    #DATA_DLY,X:STATUS                ; set data delay so that next data packet af
ter go reply
                            000000
1239                                                                                    ; experiences a delay before host notify.
Motorola DSP56300 Assembler  Version 6.3.4   05-04-07  11:14:42  PCI_SCUBA_main.asm  Page 25



1240                                BLOCK_CON
1241      P:000317 P:000319 064080            DO      #64,END_BLOCK_CON                 ; block size = 32bit x 64 (256 bytes)
                            00031D
1242      P:000319 P:00031B 0D03C6            JSR     <READ_FROM_PCI                    ; get next 32 bit word from HOST
1243      P:00031A P:00031C 208C00            MOVE              X0,A1                   ; prepare to send
1244      P:00031B P:00031D 20A800            MOVE              X1,A0                   ; prepare to send
1245      P:00031C P:00031E 0D04DC            JSR     <XMT_WD_FIBRE                     ; off it goes
1246      P:00031D P:00031F 000000            NOP
1247                                END_BLOCK_CON
1248   
1249                                ; --------------- this might work for a DMA block burst read ----------------
1250   
1251                                ; DMA block CON
1252                                ; note maximum block size is 64 (burst limit - since six bits in DPMC define length)
1253                                ;BLOCK_CON
1254                                ; set up clock size in x0, address in B
1255                                ;       MOVE    X:WBLK_SIZE,X0
1256                                ;       JSR     <READ_WBLOCK            ; DMA read block --> Y memory
1257                                ;XMT_WBLOCK                             ; send to BAC
1258                                ;       MOVE    X:ZERO,R3
1259                                ;       MOVE    X:WBLK_SIZE,X0          ;
1260                                ;       DO      X0,END_XMT_WBLOCK       ; block size in X0
1261                                ;       MOVE    Y:(R3)+,A1              ; get word MS16
1262                                ;       MOVE    Y:(R3)+,A0              ; get word LS16
1263                                ;       JSR     <XMT_WD_FIBRE           ; ...off it goes
1264                                ;       NOP
1265                                ;END_XMT_WBLOCK
1266                                ;       NOP
1267                                ;END_BLOCK_CON
1268   
1269                                ; -------------------------------------------------------------------------
1270   
1271                                ; when completed successfully then PCI needs to reply to Host with
1272                                ; word1 = reply/data = reply
1273                                FINISH_CON
1274      P:00031E P:000320 44F400            MOVE              #'REP',X0
                            524550
1275      P:000320 P:000322 440700            MOVE              X0,X:<DTXS_WD1          ; REPly
1276      P:000321 P:000323 44F400            MOVE              #'CON',X0
                            434F4E
1277      P:000323 P:000325 440800            MOVE              X0,X:<DTXS_WD2          ; echo command sent
1278      P:000324 P:000326 44F400            MOVE              #'ACK',X0
                            41434B
1279      P:000326 P:000328 440900            MOVE              X0,X:<DTXS_WD3          ; ACKnowledge okay
1280      P:000327 P:000329 44F400            MOVE              #'000',X0
                            303030
1281      P:000329 P:00032B 440A00            MOVE              X0,X:<DTXS_WD4          ; read data
1282      P:00032A P:00032C 0D03AD            JSR     <PCI_MESSAGE_TO_HOST
1283      P:00032B P:00032D 0C0339            JMP     <END_CON
1284   
1285                                ; when there is a failure in the host to PCI command then the PCI
1286                                ; needs still to reply to Host but with an error message
1287                                CON_ERROR
1288      P:00032C P:00032E 44F400            MOVE              #'REP',X0
                            524550
1289      P:00032E P:000330 440700            MOVE              X0,X:<DTXS_WD1          ; REPly
1290      P:00032F P:000331 44F400            MOVE              #'CON',X0
                            434F4E
1291      P:000331 P:000333 440800            MOVE              X0,X:<DTXS_WD2          ; echo command sent
1292      P:000332 P:000334 44F400            MOVE              #'ERR',X0
                            455252
1293      P:000334 P:000336 440900            MOVE              X0,X:<DTXS_WD3          ; ERRor im command
Motorola DSP56300 Assembler  Version 6.3.4   05-04-07  11:14:42  PCI_SCUBA_main.asm  Page 26



1294      P:000335 P:000337 44F400            MOVE              #'006',X0
                            303036
1295      P:000337 P:000339 440A00            MOVE              X0,X:<DTXS_WD4          ; write to PCI memory error
1296      P:000338 P:00033A 0D03AD            JSR     <PCI_MESSAGE_TO_HOST
1297   
1298                                END_CON
1299   
1300      P:000339 P:00033B 000004            RTI
1301   
1302                                ; ------------------------------------------------------------------------------------
1303   
1304                                SEND_PACKET_TO_HOST
1305                                ; this command is received from the Host and actions the PCI board to pick up an address
1306                                ; pointer from DRXR which the PCI board then uses to write packets from the
1307                                ; MCE to the host memory starting at the address given.
1308                                ; Since this is interrupt driven all this piece of code does is get the address pointer from
1309                                ; the host via DRXR, set a flag so that the main prog can write the packet.  Replies to
1310                                ; HST after packet sent (unless error).
1311                                ;
1312                                ; word 1 = command = 'HST'
1313                                ; word 2 = host high address
1314                                ; word 3 = host low address
1315                                ; word 4 = not used but read
1316   
1317                                ; store some registers.....
1318   
1319      P:00033A P:00033C 053039            MOVEC             SR,X:<SV_SR
1320      P:00033B P:00033D 502600            MOVE              A0,X:<SV_A0             ; Save registers used here
1321      P:00033C P:00033E 542700            MOVE              A1,X:<SV_A1
1322      P:00033D P:00033F 522800            MOVE              A2,X:<SV_A2
1323      P:00033E P:000340 442C00            MOVE              X0,X:<SV_X0
1324   
1325   
1326      P:00033F P:000341 0D03A0            JSR     <RD_DRXR                          ; read words from host write to HTXR
1327      P:000340 P:000342 20001B            CLR     B
1328      P:000341 P:000343 568300            MOVE              X:<DRXR_WD1,A           ; read command
1329      P:000342 P:000344 44F400            MOVE              #'HST',X0
                            485354
1330      P:000344 P:000346 200045            CMP     X0,A                              ; ensure command is 'HST'
1331      P:000345 P:000347 0E234D            JNE     <HOST_ERROR                       ; error, command NOT HCVR address
1332      P:000346 P:000348 448400            MOVE              X:<DRXR_WD2,X0          ; high 16 bits of address
1333      P:000347 P:000349 518500            MOVE              X:<DRXR_WD3,B0          ; low 16 bits of adderss
1334      P:000348 P:00034A 0C1941            INSERT  #$010010,X0,B                     ; convert to 32 bits and put in B
                            010010
1335      P:00034A P:00034C 448600            MOVE              X:<DRXR_WD4,X0          ; dummy
1336   
1337      P:00034B P:00034D 0A0021            BSET    #SEND_TO_HOST,X:<STATUS           ; tell main program to start sending packets
1338      P:00034C P:00034E 0C035C            JMP     <END_HOST
1339   
1340                                ; !!!!!!!!!!!! the reply is not sent here unless error !!!!!!!
1341                                ; reply to this command is sent after packet has been sucessfully send to host.
1342   
1343   
1344                                ; when there is a failure in the host to PCI command then the PCI
1345                                ; needs still to reply to Host but with an error message
1346                                HOST_ERROR
1347      P:00034D P:00034F 0A7001            BCLR    #SEND_TO_HOST,X:STATUS
                            000000
1348      P:00034F P:000351 44F400            MOVE              #'REP',X0
                            524550
1349      P:000351 P:000353 440700            MOVE              X0,X:<DTXS_WD1          ; REPly
1350      P:000352 P:000354 44F400            MOVE              #'HST',X0
Motorola DSP56300 Assembler  Version 6.3.4   05-04-07  11:14:42  PCI_SCUBA_main.asm  Page 27



                            485354
1351      P:000354 P:000356 440800            MOVE              X0,X:<DTXS_WD2          ; echo command sent
1352      P:000355 P:000357 44F400            MOVE              #'ERR',X0
                            455252
1353      P:000357 P:000359 440900            MOVE              X0,X:<DTXS_WD3          ; ERRor im command
1354      P:000358 P:00035A 44F400            MOVE              #'007',X0
                            303037
1355      P:00035A P:00035C 440A00            MOVE              X0,X:<DTXS_WD4          ; write to PCI memory error
1356      P:00035B P:00035D 0D03AD            JSR     <PCI_MESSAGE_TO_HOST
1357                                END_HOST
1358   
1359   
1360      P:00035C P:00035E 05B039            MOVEC             X:<SV_SR,SR
1361      P:00035D P:00035F 50A600            MOVE              X:<SV_A0,A0             ; restore registers used here
1362      P:00035E P:000360 54A700            MOVE              X:<SV_A1,A1
1363      P:00035F P:000361 52A800            MOVE              X:<SV_A2,A2
1364      P:000360 P:000362 44AC00            MOVE              X:<SV_X0,X0
1365   
1366      P:000361 P:000363 000004            RTI
1367                                ; --------------------------------------------------------------------
1368   
1369                                ; Reset the controller by sending a special code byte $0B with SC/nData = 1
1370                                RESET_CONTROLLER
1371                                ; word 1 = command = 'RCO'
1372                                ; word 2 = not used but read
1373                                ; word 3 = not used but read
1374                                ; word 4 = not used but read
1375      P:000362 P:000364 0D03A0            JSR     <RD_DRXR                          ; read words from host write to HTXR
1376      P:000363 P:000365 568300            MOVE              X:<DRXR_WD1,A           ; read command
1377      P:000364 P:000366 44F400            MOVE              #'RCO',X0
                            52434F
1378      P:000366 P:000368 200045            CMP     X0,A                              ; ensure command is 'RCO'
1379      P:000367 P:000369 0E238E            JNE     <RCO_ERROR                        ; error, command NOT HCVR address
1380      P:000368 P:00036A 448400            MOVE              X:<DRXR_WD2,X0          ; read but not used
1381      P:000369 P:00036B 568500            MOVE              X:<DRXR_WD3,A           ; read word 3 - not used
1382      P:00036A P:00036C 578600            MOVE              X:<DRXR_WD4,B           ; read word 4 - not used
1383   
1384                                ; if we get here then everything is fine and we can send reset to controller
1385   
1386                                ; 250MHZ CODE....
1387   
1388      P:00036B P:00036D 011D22            BSET    #SCLK,X:PDRE                      ; Enable special command mode
1389      P:00036C P:00036E 000000            NOP
1390      P:00036D P:00036F 000000            NOP
1391      P:00036E P:000370 60F400            MOVE              #$FFF000,R0             ; Memory mapped address of transmitter
                            FFF000
1392      P:000370 P:000372 44F400            MOVE              #$10000B,X0             ; Special command to reset controller
                            10000B
1393      P:000372 P:000374 446000            MOVE              X0,X:(R0)
1394      P:000373 P:000375 0606A0            REP     #6                                ; Wait for transmission to complete
1395      P:000374 P:000376 000000            NOP
1396      P:000375 P:000377 011D02            BCLR    #SCLK,X:PDRE                      ; Disable special command mode
1397   
1398                                ; Wait until the timing board is reset, because FO data is invalid
1399      P:000376 P:000378 44F400            MOVE              #10000,X0               ; Delay by about 350 milliseconds
                            002710
1400      P:000378 P:00037A 06C400            DO      X0,L_DELAY
                            00037E
1401      P:00037A P:00037C 06E883            DO      #1000,L_RDFIFO
                            00037D
1402      P:00037C P:00037E 09463F            MOVEP             Y:RDFIFO,Y0             ; Read the FIFO word to keep the
1403      P:00037D P:00037F 000000            NOP                                       ;   receiver empty
Motorola DSP56300 Assembler  Version 6.3.4   05-04-07  11:14:42  PCI_SCUBA_main.asm  Page 28



1404                                L_RDFIFO
1405      P:00037E P:000380 000000            NOP
1406                                L_DELAY
1407      P:00037F P:000381 000000            NOP
1408   
1409                                ; when completed successfully then PCI needs to reply to Host with
1410                                ; word1 = reply/data = reply
1411                                FINISH_RCO
1412      P:000380 P:000382 44F400            MOVE              #'REP',X0
                            524550
1413      P:000382 P:000384 440700            MOVE              X0,X:<DTXS_WD1          ; REPly
1414      P:000383 P:000385 44F400            MOVE              #'RCO',X0
                            52434F
1415      P:000385 P:000387 440800            MOVE              X0,X:<DTXS_WD2          ; echo command sent
1416      P:000386 P:000388 44F400            MOVE              #'ACK',X0
                            41434B
1417      P:000388 P:00038A 440900            MOVE              X0,X:<DTXS_WD3          ; ACKnowledge okay
1418      P:000389 P:00038B 44F400            MOVE              #'000',X0
                            303030
1419      P:00038B P:00038D 440A00            MOVE              X0,X:<DTXS_WD4          ; read data
1420      P:00038C P:00038E 0D03AD            JSR     <PCI_MESSAGE_TO_HOST
1421   
1422      P:00038D P:00038F 0C0303            JMP     <END_RST
1423   
1424                                ; when there is a failure in the host to PCI command then the PCI
1425                                ; needs still to reply to Host but with an error message
1426                                RCO_ERROR
1427      P:00038E P:000390 44F400            MOVE              #'REP',X0
                            524550
1428      P:000390 P:000392 447000            MOVE              X0,X:DTXS_WD1           ; REPly
                            000007
1429      P:000392 P:000394 44F400            MOVE              #'RCO',X0
                            52434F
1430      P:000394 P:000396 447000            MOVE              X0,X:DTXS_WD2           ; echo command sent
                            000008
1431      P:000396 P:000398 44F400            MOVE              #'ERR',X0
                            455252
1432      P:000398 P:00039A 447000            MOVE              X0,X:DTXS_WD3           ; ERRor im command
                            000009
1433      P:00039A P:00039C 44F400            MOVE              #'006',X0
                            303036
1434      P:00039C P:00039E 447000            MOVE              X0,X:DTXS_WD4           ; write to PCI memory error
                            00000A
1435      P:00039E P:0003A0 0D03AD            JSR     <PCI_MESSAGE_TO_HOST
1436                                END_RCO
1437      P:00039F P:0003A1 000004            RTI
1438                                ;---------------------------------------------------------------
1439                                ;                          * END OF ISRs *
1440                                ; --------------------------------------------------------------
1441   
1442   
1443   
1444                                ;                     * Beginning of SUBROUTINES *
1445                                ; --------------------------------------------------------------
1446                                ; routine is used to read from HTXR-DRXR data path
1447                                ; which is used by the Host to communicate with the PCI board
1448                                ; the host writes 4 words to this FIFO then interrupts the PCI
1449                                ; which reads the 4 words and acts on them accordingly.
1450                                RD_DRXR
1451      P:0003A0 P:0003A2 0A8982            JCLR    #SRRQ,X:DSR,*                     ; Wait for receiver to be not empty
                            0003A0
1452                                                                                    ; implies that host has written words
Motorola DSP56300 Assembler  Version 6.3.4   05-04-07  11:14:42  PCI_SCUBA_main.asm  Page 29



1453   
1454   
1455                                ; actually reading as slave here so this shouldn't be necessary......?
1456   
1457      P:0003A2 P:0003A4 0A8717            BCLR    #FC1,X:DPMC                       ; 24 bit read FC1 = 0, FC1 = 0
1458      P:0003A3 P:0003A5 0A8736            BSET    #FC0,X:DPMC
1459   
1460   
1461      P:0003A4 P:0003A6 08440B            MOVEP             X:DRXR,X0               ; Get word1
1462      P:0003A5 P:0003A7 440300            MOVE              X0,X:<DRXR_WD1
1463      P:0003A6 P:0003A8 08440B            MOVEP             X:DRXR,X0               ; Get word2
1464      P:0003A7 P:0003A9 440400            MOVE              X0,X:<DRXR_WD2
1465      P:0003A8 P:0003AA 08440B            MOVEP             X:DRXR,X0               ; Get word3
1466      P:0003A9 P:0003AB 440500            MOVE              X0,X:<DRXR_WD3
1467      P:0003AA P:0003AC 08440B            MOVEP             X:DRXR,X0               ; Get word4
1468      P:0003AB P:0003AD 440600            MOVE              X0,X:<DRXR_WD4
1469      P:0003AC P:0003AE 00000C            RTS
1470   
1471                                ; ----------------------------------------------------------------------------
1472                                ; subroutine to send 4 words as a reply from PCI to the Host
1473                                ; using the DTXS-HRXS data path
1474                                ; PCI card writes here first then causes an interrupt INTA on
1475                                ; the PCI bus to alert the host to the reply message
1476                                PCI_MESSAGE_TO_HOST
1477   
1478      P:0003AD P:0003AF 0A00A4            JSET    #INTA_FLAG,X:<STATUS,*            ; make sure host ready to receive message
                            0003AD
1479                                                                                    ; bit will be cleared by fast interrupt
1480                                                                                    ; if ready
1481      P:0003AF P:0003B1 0A0024            BSET    #INTA_FLAG,X:<STATUS              ; set flag for next time round.....
1482   
1483   
1484      P:0003B0 P:0003B2 0A8981            JCLR    #STRQ,X:DSR,*                     ; Wait for transmitter to be NOT FULL
                            0003B0
1485                                                                                    ; i.e. if CLR then FULL so wait
1486                                                                                    ; if not then it is clear to write
1487      P:0003B2 P:0003B4 448700            MOVE              X:<DTXS_WD1,X0
1488      P:0003B3 P:0003B5 447000            MOVE              X0,X:DTXS               ; Write 24 bit word1
                            FFFFCD
1489   
1490      P:0003B5 P:0003B7 0A8981            JCLR    #STRQ,X:DSR,*                     ; wait to be not full
                            0003B5
1491      P:0003B7 P:0003B9 448800            MOVE              X:<DTXS_WD2,X0
1492      P:0003B8 P:0003BA 447000            MOVE              X0,X:DTXS               ; Write 24 bit word2
                            FFFFCD
1493   
1494      P:0003BA P:0003BC 0A8981            JCLR    #STRQ,X:DSR,*                     ; wait to be not full
                            0003BA
1495      P:0003BC P:0003BE 448900            MOVE              X:<DTXS_WD3,X0
1496      P:0003BD P:0003BF 447000            MOVE              X0,X:DTXS               ; Write 24 bit word3
                            FFFFCD
1497   
1498      P:0003BF P:0003C1 0A8981            JCLR    #STRQ,X:DSR,*                     ; wait to be not full
                            0003BF
1499      P:0003C1 P:0003C3 448A00            MOVE              X:<DTXS_WD4,X0
1500      P:0003C2 P:0003C4 447000            MOVE              X0,X:DTXS               ; Write 24 bit word4
                            FFFFCD
1501   
1502                                ; once the transmit words are in the FIFO, interrupt the Host
1503                                ; the Host should clear this interrupt once it has seen it
1504                                ; to do this it writes to the HCVR to cause a fast interrupt in the DSP
1505                                ; which clears the interrupt
Motorola DSP56300 Assembler  Version 6.3.4   05-04-07  11:14:42  PCI_SCUBA_main.asm  Page 30



1506   
1507      P:0003C4 P:0003C6 0A8526            BSET    #INTA,X:DCTR                      ; Assert the interrupt
1508   
1509      P:0003C5 P:0003C7 00000C            RTS
1510   
1511                                ; ---------------------------------------------------------------
1512   
1513                                ; sub routine to read a 24 bit word in  from PCI bus
1514                                ; first setup the PCI address
1515                                ; assumes register B contains the 32 bit PCI address
1516                                READ_FROM_PCI
1517   
1518                                ; read as master
1519   
1520      P:0003C6 P:0003C8 0C1890            EXTRACTU #$010010,B,A                     ; Get D31-16 bits only
                            010010
1521      P:0003C8 P:0003CA 000000            NOP
1522   
1523      P:0003C9 P:0003CB 210C00            MOVE              A0,A1
1524      P:0003CA P:0003CC 000000            NOP
1525      P:0003CB P:0003CD 547000            MOVE              A1,X:DPMC               ; high 16bits of address in DSP master cntr 
reg.
                            FFFFC7
1526   
1527                                ; these should both be clear from above write....for 32 bit read.
1528                                ;       BCLR    #FC1,X:DPMC             ; 32 bit read FC1 = 0, FC1 = 0
1529                                ;       BCLR    #FC0,X:DPMC
1530   
1531   
1532      P:0003CD P:0003CF 000000            NOP
1533      P:0003CE P:0003D0 0C1890            EXTRACTU #$010000,B,A
                            010000
1534      P:0003D0 P:0003D2 000000            NOP
1535      P:0003D1 P:0003D3 210C00            MOVE              A0,A1
1536      P:0003D2 P:0003D4 0140C2            OR      #$060000,A                        ; A1 gets written to DPAR register
                            060000
1537      P:0003D4 P:0003D6 000000            NOP                                       ; C3-C0 of DPAR=0110 for memory read
1538      P:0003D5 P:0003D7 08CC08  WRT_ADD   MOVEP             A1,X:DPAR               ; Write address to PCI bus - PCI READ action
1539      P:0003D6 P:0003D8 000000            NOP                                       ; Pipeline delay
1540      P:0003D7 P:0003D9 0A8AA2  RD_PCI    JSET    #MRRQ,X:DPSR,GET_DAT              ; If MTRQ = 1 go read the word from host via
 FIFO
                            0003E0
1541      P:0003D9 P:0003DB 0A8A8A            JCLR    #TRTY,X:DPSR,RD_PCI               ; Bit is set if its a retry
                            0003D7
1542      P:0003DB P:0003DD 08F48A            MOVEP             #$0400,X:DPSR           ; Clear bit 10 = target retry bit
                            000400
1543      P:0003DD P:0003DF 0A8A84            JCLR    #MARQ,X:DPSR,*                    ; Wait for PCI addressing to be complete
                            0003DD
1544      P:0003DF P:0003E1 0C03D5            JMP     <WRT_ADD
1545   
1546      P:0003E0 P:0003E2 08440B  GET_DAT   MOVEP             X:DRXR,X0               ; Read 1st 16 bits of 32 bit word from host 
memory
1547      P:0003E1 P:0003E3 08450B            MOVEP             X:DRXR,X1               ; Read 2nd 16 bits of 32 bit word from host 
memory
1548   
1549                                ; note that we now have 4 bytes in X0 and X1.
1550                                ; The 32bit word was in host memory in little endian format
1551                                ; If form LSB --> MSB the bytes are b1, b2, b3, b4 in host memory
1552                                ; in progressing through the HTRX/DRXR FIFO the
1553                                ; bytes end up like this.....
1554                                ; then X0 = $00 b2 b1
1555                                ; and  X1 = $00 b4 b3
Motorola DSP56300 Assembler  Version 6.3.4   05-04-07  11:14:42  PCI_SCUBA_main.asm  Page 31



1556   
1557   
1558      P:0003E2 P:0003E4 0604A0            REP     #4                                ; increment PCI address by four bytes.
1559      P:0003E3 P:0003E5 000009            INC     B
1560      P:0003E4 P:0003E6 000000            NOP
1561      P:0003E5 P:0003E7 00000C            RTS
1562   
1563                                ; sub routine to write two 16 bit words to the PCI bus
1564                                ; which get read as a 32 bit word by the PC
1565                                ; the 32 bit address we are writing to is writen to DPMC (MSBs) and DPAR (LSBs)
1566                                ; writes 2 words from Y:memory to one 32 bit PC address then increments address
1567                                ;
1568                                ; R2 is used as a pointer to Y:memory address
1569   
1570   
1571   
1572   
1573                                ; sub routine to read a block of 24 bit words from PCI bus --> Y mem
1574                                ; assumes register B contains the 32 bit PCI address
1575                                ; register X0 contains block size
1576   
1577                                ; ------------------------------------------------------------------------------
1578   
1579                                READ_WBLOCK
1580                                ; this subroutine is as of yet untested.....26/2/4 da
1581                                ; and is currently not used.
1582   
1583                                ; set up DMA parameters
1584   
1585      P:0003E6 P:0003E8 200013            CLR     A
1586      P:0003E7 P:0003E9 000000            NOP
1587      P:0003E8 P:0003EA 21D300            MOVE              A,R3
1588   
1589      P:0003E9 P:0003EB 637000            MOVE              R3,X:DDR0               ; destination address address for DMA Y(R3)
                            FFFFEE
1590      P:0003EB P:0003ED 08F4AF            MOVEP             #DRXR,X:DSR0            ; source address for DMA X:DRXR
                            FFFFCB
1591   
1592      P:0003ED P:0003EF 208E00            MOVE              X0,A                    ; get block size
1593      P:0003EE P:0003F0 200032            ASL     A                                 ; double - since DMA trnasfers are extended 
16bit
1594      P:0003EF P:0003F1 00000A            DEC     A
1595      P:0003F0 P:0003F2 000000            NOP
1596      P:0003F1 P:0003F3 08CE2D            MOVEP             A,X:DCO0                ; #dma txfs - 1 (2*block size - 1)
1597   
1598                                ; get burst length -1 into top byte of X0 (block size-1)
1599      P:0003F2 P:0003F4 208E00            MOVE              X0,A
1600      P:0003F3 P:0003F5 00000A            DEC     A
1601      P:0003F4 P:0003F6 0C1D20            ASL     #16,A,A
1602      P:0003F5 P:0003F7 000000            NOP
1603      P:0003F6 P:0003F8 0140C6            ANDI    #$FF0000,A                        ; mask off bottom two bytes
                            FF0000
1604      P:0003F8 P:0003FA 21C400            MOVE              A,X0
1605   
1606                                ; read as master
1607   
1608   
1609      P:0003F9 P:0003FB 0C1890            EXTRACTU #$010010,B,A                     ; Get D31-16 bits only
                            010010
1610      P:0003FB P:0003FD 000000            NOP
1611      P:0003FC P:0003FE 210C00            MOVE              A0,A1
1612      P:0003FD P:0003FF 000000            NOP
Motorola DSP56300 Assembler  Version 6.3.4   05-04-07  11:14:42  PCI_SCUBA_main.asm  Page 32



1613      P:0003FE P:000400 200042            OR      X0,A                              ; add burst length to address
1614      P:0003FF P:000401 000000            NOP
1615      P:000400 P:000402 547000            MOVE              A1,X:DPMC               ; high 16bits of address in DSP master cntr 
reg.
                            FFFFC7
1616   
1617      P:000402 P:000404 000000            NOP
1618      P:000403 P:000405 0C1890            EXTRACTU #$010000,B,A
                            010000
1619      P:000405 P:000407 000000            NOP
1620      P:000406 P:000408 210C00            MOVE              A0,A1
1621      P:000407 P:000409 0140C2            OR      #$060000,A                        ; A1 gets written to DPAR register
                            060000
1622      P:000409 P:00040B 000000            NOP                                       ; C3-C0 of DPAR=0110 for memory read
1623   
1624      P:00040A P:00040C 08F4AC            MOVEP             #$8EFAC4,X:DCR0         ; START DMA with control reg DE=1
                            8EFAC4
1625                                                                                    ; source X, destination Y
1626                                                                                    ; post inc dest.
1627   
1628                                WRTB_ADD
1629      P:00040C P:00040E 08CC08            MOVEP             A1,X:DPAR               ; Initiate PCI READ action
1630      P:00040D P:00040F 000000            NOP                                       ; Pipeline delay
1631                                RDB_PCI
1632      P:00040E P:000410 0A8AA2            JSET    #MRRQ,X:DPSR,GETB_DON             ; If MTRQ = 1 - FIFO DRXR contains data
                            000417
1633      P:000410 P:000412 0A8A8A            JCLR    #TRTY,X:DPSR,RDB_PCI              ; Bit is set if its a retry
                            00040E
1634      P:000412 P:000414 08F48A            MOVEP             #$0400,X:DPSR           ; Clear bit 10 = target retry bit
                            000400
1635      P:000414 P:000416 0A8A84            JCLR    #MARQ,X:DPSR,*                    ; Wait for PCI addressing to be complete
                            000414
1636      P:000416 P:000418 0C040C            JMP     <WRTB_ADD
1637                                GETB_DON
1638      P:000417 P:000419 0A8AA2            JSET    #MRRQ,X:DPSR,*                    ; wait till finished.....till DMA empties DR
XR
                            000417
1639      P:000419 P:00041B 00000C            RTS
1640   
1641   
1642                                ; --------------------------------------------------------------------------------
1643   
1644   
1645                                WRITE_TO_PCI
1646   
1647      P:00041A P:00041C 0A8A81            JCLR    #MTRQ,X:DPSR,*                    ; wait here if DTXM is full
                            00041A
1648   
1649      P:00041C P:00041E 08DACC  TX_LSB    MOVEP             Y:(R2)+,X:DTXM          ; Least significant word to transmit
1650      P:00041D P:00041F 08DACC  TX_MSB    MOVEP             Y:(R2)+,X:DTXM          ; Most significant word to transmit
1651   
1652   
1653      P:00041E P:000420 0C1890            EXTRACTU #$010010,B,A                     ; Get D31-16 bits only
                            010010
1654      P:000420 P:000422 000000            NOP
1655      P:000421 P:000423 210C00            MOVE              A0,A1
1656   
1657                                ; we are using two 16 bit writes to make a 32bit word so FC1=0 and FC1=0
1658   
1659      P:000422 P:000424 000000            NOP
1660      P:000423 P:000425 547000            MOVE              A1,X:DPMC               ; DSP master control register
                            FFFFC7
Motorola DSP56300 Assembler  Version 6.3.4   05-04-07  11:14:42  PCI_SCUBA_main.asm  Page 33



1661      P:000425 P:000427 000000            NOP
1662      P:000426 P:000428 0C1890            EXTRACTU #$010000,B,A
                            010000
1663      P:000428 P:00042A 000000            NOP
1664      P:000429 P:00042B 210C00            MOVE              A0,A1
1665      P:00042A P:00042C 0140C2            OR      #$070000,A                        ; A1 gets written to DPAR register
                            070000
1666      P:00042C P:00042E 000000            NOP
1667   
1668      P:00042D P:00042F 08CC08  AGAIN1    MOVEP             A1,X:DPAR               ; Write to PCI bus
1669      P:00042E P:000430 000000            NOP                                       ; Pipeline delay
1670      P:00042F P:000431 000000            NOP
1671      P:000430 P:000432 0A8A84            JCLR    #MARQ,X:DPSR,*                    ; Bit is set if its a retry
                            000430
1672      P:000432 P:000434 0A8AAE            JSET    #MDT,X:DPSR,INC_ADD               ; If no error go to the next sub-block
                            000436
1673      P:000434 P:000436 0D0490            JSR     <PCI_ERROR_RECOVERY
1674      P:000435 P:000437 0C042D            JMP     <AGAIN1
1675                                INC_ADD
1676      P:000436 P:000438 0604A0            REP     #4                                ; increment PCI address by four bytes.
1677      P:000437 P:000439 000009            INC     B
1678      P:000438 P:00043A 000000            NOP
1679      P:000439 P:00043B 00000C            RTS
1680   
1681                                ; ----------------------------------------------------------------------------------
1682   
1683                                ; R2 is used as a pointer to Y:memory address
1684   
1685                                WRITE_512_TO_PCI                                    ; writes 512 pixels (256 x 32bit writes) acr
oss PCI bus in 4 x 128 pixel bursts
1686      P:00043A P:00043C 3A8000            MOVE              #128,N2                 ; Number of pixels per transfer (!!!)
1687   
1688                                ; Make sure its always 512 pixels per loop = 1/2 FIFO
1689      P:00043B P:00043D 627000            MOVE              R2,X:DSR0               ; Source address for DMA = pixel data
                            FFFFEF
1690      P:00043D P:00043F 08F4AE            MOVEP             #DTXM,X:DDR0            ; Destination = PCI master transmitter
                            FFFFCC
1691      P:00043F P:000441 08F4AD            MOVEP             #>127,X:DCO0            ; DMA Count = # of pixels - 1 (!!!)
                            00007F
1692   
1693                                ; Do loop does 4 x 128 pixel DMA writes = 512.
1694                                ; need to recalculate hi and lo parts of address
1695                                ; for each burst.....Leach doesn't do this since not
1696                                ; multiple frames...so only needs to inc low part.....
1697   
1698      P:000441 P:000443 060480            DO      #4,WR_BLK0                        ; x # of pixels = 512 (!!!)
                            000464
1699   
1700      P:000443 P:000445 0C1890            EXTRACTU #$010010,B,A                     ; Get D31-16 bits only
                            010010
1701      P:000445 P:000447 000000            NOP
1702      P:000446 P:000448 210C00            MOVE              A0,A1                   ; [D31-16] in A1
1703      P:000447 P:000449 000000            NOP
1704      P:000448 P:00044A 0140C2            ORI     #$3F0000,A                        ; Burst length = # of PCI writes (!!!)
                            3F0000
1705      P:00044A P:00044C 000000            NOP                                       ;   = # of pixels / 2 - 1 ...$3F = 63
1706      P:00044B P:00044D 547000            MOVE              A1,X:DPMC               ; DPMC = B[31:16] + $3F0000
                            FFFFC7
1707   
1708   
1709      P:00044D P:00044F 0C1890            EXTRACTU #$010000,B,A
                            010000
Motorola DSP56300 Assembler  Version 6.3.4   05-04-07  11:14:42  PCI_SCUBA_main.asm  Page 34



1710      P:00044F P:000451 000000            NOP
1711      P:000450 P:000452 210C00            MOVE              A0,A1                   ; Get PCI_ADDR[15:0] into A1[15:0]
1712      P:000451 P:000453 000000            NOP
1713      P:000452 P:000454 0140C2            OR      #$070000,A                        ; A1 gets written to DPAR register
                            070000
1714      P:000454 P:000456 000000            NOP
1715   
1716   
1717      P:000455 P:000457 08F4AC  AGAIN0    MOVEP             #$8EFA51,X:DCR0         ; Start DMA with control register DE=1
                            8EFA51
1718      P:000457 P:000459 08CC08            MOVEP             A1,X:DPAR               ; Initiate writing to the PCI bus
1719      P:000458 P:00045A 000000            NOP
1720      P:000459 P:00045B 000000            NOP
1721      P:00045A P:00045C 0A8A84            JCLR    #MARQ,X:DPSR,*                    ; Wait until the PCI operation is done
                            00045A
1722      P:00045C P:00045E 0A8AAE            JSET    #MDT,X:DPSR,WR_OK0                ; If no error go to the next sub-block
                            000460
1723      P:00045E P:000460 0D0490            JSR     <PCI_ERROR_RECOVERY
1724      P:00045F P:000461 0C0455            JMP     <AGAIN0                           ; Just try to write the sub-block again
1725                                WR_OK0
1726   
1727      P:000460 P:000462 200013            CLR     A
1728      P:000461 P:000463 50F400            MOVE              #>256,A0                ; 2 bytes on pcibus per pixel
                            000100
1729      P:000463 P:000465 200018            ADD     A,B                               ; PCI address = + 2 x # of pixels (!!!)
1730      P:000464 P:000466 204A00            MOVE              (R2)+N2                 ; Pixel buffer address = + # of pixels
1731                                WR_BLK0
1732      P:000465 P:000467 00000C            RTS
1733   
1734                                ; -------------------------------------------------------------------------------------------
1735   
1736                                WRITE_32_TO_PCI                                     ; writes 32 pixels....= 16 x 32bit words acr
oss PCI bus bursted
1737      P:000466 P:000468 3A2000            MOVE              #32,N2                  ; Number of pixels per transfer (!!!)
1738   
1739      P:000467 P:000469 627000            MOVE              R2,X:DSR0               ; Source address for DMA = pixel data
                            FFFFEF
1740      P:000469 P:00046B 08F4AE            MOVEP             #DTXM,X:DDR0            ; Destination = PCI master transmitter
                            FFFFCC
1741      P:00046B P:00046D 08F4AD            MOVEP             #>31,X:DCO0             ; DMA Count = # of pixels - 1 (!!!)
                            00001F
1742   
1743      P:00046D P:00046F 0C1890            EXTRACTU #$010010,B,A                     ; Get D31-16 bits only
                            010010
1744      P:00046F P:000471 000000            NOP
1745      P:000470 P:000472 210C00            MOVE              A0,A1                   ; [D31-16] in A1
1746      P:000471 P:000473 000000            NOP
1747      P:000472 P:000474 0140C2            ORI     #$0F0000,A                        ; Burst length = # of PCI writes (!!!)
                            0F0000
1748      P:000474 P:000476 000000            NOP                                       ;   = # of pixels / 2 - 1 ...$0F = 16
1749      P:000475 P:000477 547000            MOVE              A1,X:DPMC               ; DPMC = B[31:16] + $3F0000
                            FFFFC7
1750   
1751      P:000477 P:000479 0C1890            EXTRACTU #$010000,B,A
                            010000
1752      P:000479 P:00047B 000000            NOP
1753      P:00047A P:00047C 210C00            MOVE              A0,A1                   ; Get PCI_ADDR[15:0] into A1[15:0]
1754      P:00047B P:00047D 000000            NOP
1755      P:00047C P:00047E 0140C2            ORI     #$070000,A                        ; A1 gets written to DPAR register
                            070000
1756      P:00047E P:000480 000000            NOP
1757   
Motorola DSP56300 Assembler  Version 6.3.4   05-04-07  11:14:42  PCI_SCUBA_main.asm  Page 35



1758   
1759      P:00047F P:000481 08F4AC  AGAIN2    MOVEP             #$8EFA51,X:DCR0         ; Start DMA with control register DE=1
                            8EFA51
1760      P:000481 P:000483 08CC08            MOVEP             A1,X:DPAR               ; Initiate writing to the PCI bus
1761      P:000482 P:000484 000000            NOP
1762      P:000483 P:000485 000000            NOP
1763      P:000484 P:000486 0A8A84            JCLR    #MARQ,X:DPSR,*                    ; Wait until the PCI operation is done
                            000484
1764      P:000486 P:000488 0A8AAE            JSET    #MDT,X:DPSR,WR_OK1                ; If no error go to the next sub-block
                            00048A
1765      P:000488 P:00048A 0D0490            JSR     <PCI_ERROR_RECOVERY
1766      P:000489 P:00048B 0C047F            JMP     <AGAIN2                           ; Just try to write the sub-block again
1767                                WR_OK1
1768      P:00048A P:00048C 200013            CLR     A
1769      P:00048B P:00048D 50F400            MOVE              #>64,A0                 ; 2 bytes on pcibus per pixel
                            000040
1770      P:00048D P:00048F 200018            ADD     A,B                               ; PCI address = + 2 x # of pixels (!!!)
1771      P:00048E P:000490 204A00            MOVE              (R2)+N2                 ; Pixel buffer address = + # of pixels
1772      P:00048F P:000491 00000C            RTS
1773   
1774   
1775                                ; ------------------------------------------------------------------------------
1776   
1777                                                                                    ; Recover from an error writing to the PCI b
us
1778                                PCI_ERROR_RECOVERY
1779      P:000490 P:000492 0A8A8A            JCLR    #TRTY,X:DPSR,ERROR1               ; Retry error
                            000495
1780      P:000492 P:000494 08F48A            MOVEP             #$0400,X:DPSR           ; Clear target retry error bit
                            000400
1781      P:000494 P:000496 00000C            RTS
1782      P:000495 P:000497 0A8A8B  ERROR1    JCLR    #TO,X:DPSR,ERROR2                 ; Timeout error
                            00049A
1783      P:000497 P:000499 08F48A            MOVEP             #$0800,X:DPSR           ; Clear timeout error bit
                            000800
1784      P:000499 P:00049B 00000C            RTS
1785      P:00049A P:00049C 0A8A89  ERROR2    JCLR    #TDIS,X:DPSR,ERROR3               ; Target disconnect error
                            00049F
1786      P:00049C P:00049E 08F48A            MOVEP             #$0200,X:DPSR           ; Clear target disconnect bit
                            000200
1787      P:00049E P:0004A0 00000C            RTS
1788      P:00049F P:0004A1 0A8A88  ERROR3    JCLR    #TAB,X:DPSR,ERROR4                ; Target abort error
                            0004A4
1789      P:0004A1 P:0004A3 08F48A            MOVEP             #$0100,X:DPSR           ; Clear target abort error bit
                            000100
1790      P:0004A3 P:0004A5 00000C            RTS
1791      P:0004A4 P:0004A6 0A8A87  ERROR4    JCLR    #MAB,X:DPSR,ERROR5                ; Master abort error
                            0004A9
1792      P:0004A6 P:0004A8 08F48A            MOVEP             #$0080,X:DPSR           ; Clear master abort error bit
                            000080
1793      P:0004A8 P:0004AA 00000C            RTS
1794      P:0004A9 P:0004AB 0A8A86  ERROR5    JCLR    #DPER,X:DPSR,ERROR6               ; Data parity error
                            0004AE
1795      P:0004AB P:0004AD 08F48A            MOVEP             #$0040,X:DPSR           ; Clear data parity error bit
                            000040
1796      P:0004AD P:0004AF 00000C            RTS
1797      P:0004AE P:0004B0 0A8A85  ERROR6    JCLR    #APER,X:DPSR,ERROR7               ; Address parity error
                            0004B2
1798      P:0004B0 P:0004B2 08F48A            MOVEP             #$0020,X:DPSR           ; Clear address parity error bit
                            000020
1799      P:0004B2 P:0004B4 00000C  ERROR7    RTS
1800   
Motorola DSP56300 Assembler  Version 6.3.4   05-04-07  11:14:42  PCI_SCUBA_main.asm  Page 36



1801                                ; --------------------------------------------------------------------------------
1802   
1803   
1804                                ; **********   get a word from FO and put in X0     **********************************
1805   
1806      P:0004B3 P:0004B5 01AD80  GET_FO_WRD JCLR   #EF,X:PDRD,CLR_FO_RTS
                            0004C9
1807      P:0004B5 P:0004B7 000000            NOP
1808      P:0004B6 P:0004B8 000000            NOP
1809      P:0004B7 P:0004B9 01AD80            JCLR    #EF,X:PDRD,CLR_FO_RTS             ; check twice for FO metastability.
                            0004C9
1810      P:0004B9 P:0004BB 0AF080            JMP     RD_FO_WD
                            0004C1
1811   
1812      P:0004BB P:0004BD 01AD80  WT_FIFO   JCLR    #EF,X:PDRD,*                      ; Wait till something in FIFO flagged
                            0004BB
1813      P:0004BD P:0004BF 000000            NOP
1814      P:0004BE P:0004C0 000000            NOP
1815      P:0004BF P:0004C1 01AD80            JCLR    #EF,X:PDRD,WT_FIFO                ; check twice.....
                            0004BB
1816   
1817   
1818                                ; Read one word from the fiber optics FIFO, check it and put it in A1
1819                                RD_FO_WD
1820   
1821      P:0004C1 P:0004C3 09443F  GET_WD    MOVEP             Y:RDFIFO,X0             ; then read to X0
1822      P:0004C2 P:0004C4 54F400            MOVE              #$00FFFF,A1             ; mask off top 2 bytes ($FC)
                            00FFFF
1823      P:0004C4 P:0004C6 200046            AND     X0,A                              ; since receiving 16 bits in 24bit register
1824      P:0004C5 P:0004C7 000000            NOP
1825      P:0004C6 P:0004C8 218400            MOVE              A1,X0
1826      P:0004C7 P:0004C9 0A0023  SET_FO_RTS BSET   #FO_WRD_RCV,X:<STATUS
1827                                 END_WT_FIFO
1828      P:0004C8 P:0004CA 00000C            RTS
1829   
1830      P:0004C9 P:0004CB 0A0003  CLR_FO_RTS BCLR   #FO_WRD_RCV,X:<STATUS
1831      P:0004CA P:0004CC 00000C            RTS
1832   
1833                                ; ----------------------------------------------------------------------------------
1834   
1835                                ; put this in just now for left over data reads
1836                                WT_FIFO_DA
1837      P:0004CB P:0004CD 01AD80            JCLR    #EF,X:PDRD,*                      ; Wait till something in FIFO flagged
                            0004CB
1838      P:0004CD P:0004CF 000000            NOP
1839      P:0004CE P:0004D0 000000            NOP
1840      P:0004CF P:0004D1 01AD80            JCLR    #EF,X:PDRD,WT_FIFO_DA             ; check twice.....
                            0004CB
1841      P:0004D1 P:0004D3 09443F            MOVEP             Y:RDFIFO,X0             ; then read to X0
1842      P:0004D2 P:0004D4 54F400            MOVE              #$00FFFF,A1             ; mask off top 2 bytes ($FC)
                            00FFFF
1843      P:0004D4 P:0004D6 200046            AND     X0,A                              ; since receiving 16 bits and 3 bytes sent
1844      P:0004D5 P:0004D7 000000            NOP
1845      P:0004D6 P:0004D8 218400            MOVE              A1,X0
1846      P:0004D7 P:0004D9 00000C            RTS
1847   
1848                                ; Short delay for reliability
1849      P:0004D8 P:0004DA 000000  XMT_DLY   NOP
1850      P:0004D9 P:0004DB 000000            NOP
1851      P:0004DA P:0004DC 000000            NOP
1852      P:0004DB P:0004DD 00000C            RTS
1853   
Motorola DSP56300 Assembler  Version 6.3.4   05-04-07  11:14:42  PCI_SCUBA_main.asm  Page 37



1854                                ; 250 MHz code - Transmit contents of Accumulator A1 to the MCE
1855   
1856                                ; we want to send 32bit word in little endian fomat to the host.
1857                                ; i.e. b4b3b2b1 goes b1, b2, b3, b4
1858   
1859                                ; currently the bytes are in this order:
1860                                ; then A1 = $00 b2 b1
1861                                ; and  A0 = $00 b4 b3
1862                                ; A = $00 00 b2 b1 00 b4 b3
1863   
1864   
1865                                XMT_WD_FIBRE
1866   
1867                                ; save registers
1868   
1869      P:0004DC P:0004DE 502600            MOVE              A0,X:<SV_A0             ; Save registers used in XMT_WRD
1870      P:0004DD P:0004DF 542700            MOVE              A1,X:<SV_A1
1871      P:0004DE P:0004E0 522800            MOVE              A2,X:<SV_A2
1872      P:0004DF P:0004E1 452D00            MOVE              X1,X:<SV_X1
1873      P:0004E0 P:0004E2 442C00            MOVE              X0,X:<SV_X0
1874      P:0004E1 P:0004E3 472F00            MOVE              Y1,X:<SV_Y1
1875      P:0004E2 P:0004E4 462E00            MOVE              Y0,X:<SV_Y0
1876   
1877                                ; split up 4 bytes b2, b1, b4, b3
1878   
1879      P:0004E3 P:0004E5 0C1D20            ASL     #16,A,A                           ; shift byte b2 into A2
1880      P:0004E4 P:0004E6 60F400            MOVE              #$FFF000,R0             ; Memory mapped address of transmitter
                            FFF000
1881   
1882      P:0004E6 P:0004E8 214700            MOVE              A2,Y1                   ; byte b2 in Y1
1883   
1884      P:0004E7 P:0004E9 0C1D10            ASL     #8,A,A                            ; shift byte b1 into A2
1885      P:0004E8 P:0004EA 000000            NOP
1886      P:0004E9 P:0004EB 214600            MOVE              A2,Y0                   ; byte b1 in Y0
1887   
1888      P:0004EA P:0004EC 0C1D20            ASL     #16,A,A                           ; shift byte b4 into A2
1889      P:0004EB P:0004ED 000000            NOP
1890      P:0004EC P:0004EE 214500            MOVE              A2,X1                   ; byte b4 in X1
1891   
1892   
1893      P:0004ED P:0004EF 0C1D10            ASL     #8,A,A                            ; shift byte b3 into A2
1894      P:0004EE P:0004F0 000000            NOP
1895      P:0004EF P:0004F1 214400            MOVE              A2,X0                   ; byte b3 in x0
1896   
1897   
1898                                ; transmit b1, b2, b3 ,b4
1899   
1900      P:0004F0 P:0004F2 466000            MOVE              Y0,X:(R0)               ; byte b1 - off it goes
1901      P:0004F1 P:0004F3 476000            MOVE              Y1,X:(R0)               ; byte b2- off it goes
1902      P:0004F2 P:0004F4 446000            MOVE              X0,X:(R0)               ; byte b3 - off it goes
1903      P:0004F3 P:0004F5 456000            MOVE              X1,X:(R0)               ; byte b4 - off it goes
1904   
1905                                ; restore registers
1906      P:0004F4 P:0004F6 502600            MOVE              A0,X:<SV_A0
1907      P:0004F5 P:0004F7 542700            MOVE              A1,X:<SV_A1
1908      P:0004F6 P:0004F8 522800            MOVE              A2,X:<SV_A2
1909      P:0004F7 P:0004F9 45AD00            MOVE              X:<SV_X1,X1             ; Restore registers used here
1910      P:0004F8 P:0004FA 44AC00            MOVE              X:<SV_X0,X0
1911      P:0004F9 P:0004FB 47AF00            MOVE              X:<SV_Y1,Y1
1912      P:0004FA P:0004FC 46AE00            MOVE              X:<SV_Y0,Y0
1913      P:0004FB P:0004FD 00000C            RTS
1914   
Motorola DSP56300 Assembler  Version 6.3.4   05-04-07  11:14:42  PCI_SCUBA_main.asm  Page 38



1915                                ; ----------------------------------------------------------------------------
1916   
1917                                ; number of 512 buffers in packet calculated (X:TOTAL_BUFFS)
1918                                ; and number of left over blocks
1919                                ; and left over words (X:LEFT_TO_READ)
1920   
1921                                CALC_NO_BUFFS
1922   
1923      P:0004FC P:0004FE 462E00            MOVE              Y0,X:<SV_Y0
1924      P:0004FD P:0004FF 472F00            MOVE              Y1,X:<SV_Y1
1925   
1926      P:0004FE P:000500 20001B            CLR     B
1927      P:0004FF P:000501 519E00            MOVE              X:<HEAD_W4_0,B0         ; LS 16bits
1928      P:000500 P:000502 449D00            MOVE              X:<HEAD_W4_1,X0         ; MS 16bits
1929   
1930      P:000501 P:000503 0C1941            INSERT  #$010010,X0,B                     ; now size of packet B....giving # of 32bit 
words in packet
                            010010
1931      P:000503 P:000505 000000            NOP
1932   
1933                                ; need to covert this to 16 bit since read from FIFO and saved in Y memory as 16bit words...
1934   
1935                                ; so double size of packet....
1936      P:000504 P:000506 20003A            ASL     B
1937   
1938                                ; now save
1939      P:000505 P:000507 212400            MOVE              B0,X0
1940      P:000506 P:000508 21A500            MOVE              B1,X1
1941      P:000507 P:000509 443700            MOVE              X0,X:<PACKET_SIZE_LOW   ; low 24 bits of packet size (in 16bit words
)
1942      P:000508 P:00050A 453800            MOVE              X1,X:<PACKET_SIZE_HIH   ; high 8 bits of packet size (in 16bit words
)
1943   
1944      P:000509 P:00050B 50B700            MOVE              X:<PACKET_SIZE_LOW,A0
1945      P:00050A P:00050C 54B800            MOVE              X:<PACKET_SIZE_HIH,A1
1946      P:00050B P:00050D 0C1C12            ASR     #9,A,A                            ; divide by 512...number of 16bit words in a
 buffer
1947      P:00050C P:00050E 000000            NOP
1948      P:00050D P:00050F 503C00            MOVE              A0,X:<TOTAL_BUFFS
1949   
1950      P:00050E P:000510 210500            MOVE              A0,X1
1951      P:00050F P:000511 47F400            MOVE              #HF_FIFO,Y1
                            000200
1952      P:000511 P:000513 2000F0            MPY     X1,Y1,A
1953      P:000512 P:000514 0C1C03            ASR     #1,A,B                            ; B holds number of 16bit words in all full 
buffers
1954      P:000513 P:000515 000000            NOP
1955   
1956   
1957      P:000514 P:000516 50B700            MOVE              X:<PACKET_SIZE_LOW,A0
1958      P:000515 P:000517 54B800            MOVE              X:<PACKET_SIZE_HIH,A1   ; A holds total number of 16bit words
1959      P:000516 P:000518 200014            SUB     B,A                               ; now A holds number of left over 16bit word
s
1960      P:000517 P:000519 000000            NOP
1961      P:000518 P:00051A 503D00            MOVE              A0,X:<LEFT_TO_READ      ; store number of left over 16bit words to r
ead
1962      P:000519 P:00051B 0C1C0A            ASR     #5,A,A                            ; divide by 32... number of 16bit words in l
efover block
1963      P:00051A P:00051C 000000            NOP
1964      P:00051B P:00051D 503F00            MOVE              A0,X:<NUM_LEFTOVER_BLOCKS
1965      P:00051C P:00051E 210500            MOVE              A0,X1
1966      P:00051D P:00051F 47F400            MOVE              #>SMALL_BLK,Y1
Motorola DSP56300 Assembler  Version 6.3.4   05-04-07  11:14:42  PCI_SCUBA_main.asm  Page 39



                            000020
1967      P:00051F P:000521 2000F0            MPY     X1,Y1,A
1968      P:000520 P:000522 0C1C02            ASR     #1,A,A
1969      P:000521 P:000523 000000            NOP
1970   
1971      P:000522 P:000524 200018            ADD     A,B                               ; B holds words in all buffers
1972      P:000523 P:000525 000000            NOP
1973      P:000524 P:000526 50B700            MOVE              X:<PACKET_SIZE_LOW,A0
1974      P:000525 P:000527 54B800            MOVE              X:<PACKET_SIZE_HIH,A1   ; A holds total number of words
1975      P:000526 P:000528 200014            SUB     B,A                               ; now A holds number of left over words
1976      P:000527 P:000529 000000            NOP
1977      P:000528 P:00052A 503D00            MOVE              A0,X:<LEFT_TO_READ      ; store number of left over 16bit words to r
ead
1978   
1979      P:000529 P:00052B 0C1C02            ASR     #1,A,A                            ; divide by two to get number of 32 bit word
s to write
1980      P:00052A P:00052C 000000            NOP                                       ; for pipeline
1981      P:00052B P:00052D 503E00            MOVE              A0,X:<LEFT_TO_WRITE     ; store number of left over 32 bit words (2 
x 16 bit) to write to host after small block transfer as well
1982   
1983      P:00052C P:00052E 46AE00            MOVE              X:<SV_Y0,Y0
1984      P:00052D P:00052F 47AF00            MOVE              X:<SV_Y1,Y1
1985   
1986      P:00052E P:000530 00000C            RTS
1987   
1988                                ; -------------------------------------------------------------------------------------
1989   
1990                                ; ******** end of Sub Routines ********
1991   
1992   
1993                                          IF      @CVS(N,*)>=APPLICATION
1995                                          ENDIF
1996   
1997   
1998   
1999   
2000                                ; ******************************************
2001                                ;******* x memory parameter table **********
2002                                ; ******************************************
2003   
2004      X:000000 P:000531                   ORG     X:VAR_TBL,P:
2005   
2006   
2007                                          IF      @SCP("ROM","ROM")                 ; Boot ROM code
2008                                 VAR_TBL_START
2009      00052F                              EQU     @LCV(L)-2
2010                                          ENDIF
2011   
2012                                          IF      @SCP("ROM","ONCE")                ; Download via ONCE debugger
2014                                          ENDIF
2015   
2016                                ; -----------------------------------------------
2017                                ; do not move these from X:0 and X:1
2018 d    X:000000 P:000531 000000  STATUS    DC      0
2019 d                               FRAME_COUNT
2020 d    X:000001 P:000532 000000            DC      0                                 ; used as a check....... increments for ever
y frame write.....must be cleared by host.
2021 d                               PRE_CORRUPT
2022 d    X:000002 P:000533 000000            DC      0
2023                                ; -------------------------------------------------
2024   
2025 d    X:000003 P:000534 000000  DRXR_WD1  DC      0
Motorola DSP56300 Assembler  Version 6.3.4   05-04-07  11:14:42  PCI_SCUBA_main.asm  Page 40



2026 d    X:000004 P:000535 000000  DRXR_WD2  DC      0
2027 d    X:000005 P:000536 000000  DRXR_WD3  DC      0
2028 d    X:000006 P:000537 000000  DRXR_WD4  DC      0
2029 d    X:000007 P:000538 000000  DTXS_WD1  DC      0
2030 d    X:000008 P:000539 000000  DTXS_WD2  DC      0
2031 d    X:000009 P:00053A 000000  DTXS_WD3  DC      0
2032 d    X:00000A P:00053B 000000  DTXS_WD4  DC      0
2033   
2034 d    X:00000B P:00053C 000000  PCI_WD1_1 DC      0
2035 d    X:00000C P:00053D 000000  PCI_WD1_2 DC      0
2036 d    X:00000D P:00053E 000000  PCI_WD2_1 DC      0
2037 d    X:00000E P:00053F 000000  PCI_WD2_2 DC      0
2038 d    X:00000F P:000540 000000  PCI_WD3_1 DC      0
2039 d    X:000010 P:000541 000000  PCI_WD3_2 DC      0
2040 d    X:000011 P:000542 000000  PCI_WD4_1 DC      0
2041 d    X:000012 P:000543 000000  PCI_WD4_2 DC      0
2042 d    X:000013 P:000544 000000  PCI_WD5_1 DC      0
2043 d    X:000014 P:000545 000000  PCI_WD5_2 DC      0
2044 d    X:000015 P:000546 000000  PCI_WD6_1 DC      0
2045 d    X:000016 P:000547 000000  PCI_WD6_2 DC      0
2046   
2047   
2048 d    X:000017 P:000548 000000  HEAD_W1_1 DC      0
2049 d    X:000018 P:000549 000000  HEAD_W1_0 DC      0
2050 d    X:000019 P:00054A 000000  HEAD_W2_1 DC      0
2051 d    X:00001A P:00054B 000000  HEAD_W2_0 DC      0
2052 d    X:00001B P:00054C 000000  HEAD_W3_1 DC      0
2053 d    X:00001C P:00054D 000000  HEAD_W3_0 DC      0
2054 d    X:00001D P:00054E 000000  HEAD_W4_1 DC      0
2055 d    X:00001E P:00054F 000000  HEAD_W4_0 DC      0
2056   
2057   
2058 d    X:00001F P:000550 000000  REP_WD1   DC      0
2059 d    X:000020 P:000551 000000  REP_WD2   DC      0
2060 d    X:000021 P:000552 000000  REP_WD3   DC      0
2061 d    X:000022 P:000553 000000  REP_WD4   DC      0
2062   
2063 d    X:000023 P:000554 000000  NO_32BIT  DC      0
2064 d    X:000024 P:000555 00FFFF  MASK_16BIT DC     $00FFFF                           ; 16 bit mask to clear top to bytes
2065 d    X:000025 P:000556 00FF00  C00FF00   DC      $00FF00
2066   
2067 d    X:000026 P:000557 000000  SV_A0     DC      0
2068 d    X:000027 P:000558 000000  SV_A1     DC      0
2069 d    X:000028 P:000559 000000  SV_A2     DC      0
2070 d    X:000029 P:00055A 000000  SV_B0     DC      0
2071 d    X:00002A P:00055B 000000  SV_B1     DC      0
2072 d    X:00002B P:00055C 000000  SV_B2     DC      0
2073 d    X:00002C P:00055D 000000  SV_X0     DC      0
2074 d    X:00002D P:00055E 000000  SV_X1     DC      0
2075 d    X:00002E P:00055F 000000  SV_Y0     DC      0
2076 d    X:00002F P:000560 000000  SV_Y1     DC      0
2077   
2078 d    X:000030 P:000561 000000  SV_SR     DC      0                                 ; stauts register save.
2079   
2080 d    X:000031 P:000562 000000  ZERO      DC      0
2081 d    X:000032 P:000563 000001  ONE       DC      1
2082 d    X:000033 P:000564 000002  TWO       DC      2
2083 d    X:000034 P:000565 000003  THREE     DC      3
2084 d    X:000035 P:000566 000004  FOUR      DC      4
2085 d    X:000036 P:000567 000040  WBLK_SIZE DC      64
2086   
2087 d                               PACKET_SIZE_LOW
Motorola DSP56300 Assembler  Version 6.3.4   05-04-07  11:14:42  PCI_SCUBA_main.asm  Page 41



2088 d    X:000037 P:000568 000000            DC      0
2089 d                               PACKET_SIZE_HIH
2090 d    X:000038 P:000569 000000            DC      0
2091   
2092 d    X:000039 P:00056A 00A5A5  PREAMB1   DC      $A5A5                             ; pramble 16-bit word....2 of which make up 
first preamble 32bit word
2093 d    X:00003A P:00056B 005A5A  PREAMB2   DC      $5A5A                             ; preamble 16-bit word....2 of which make up
 second preamble 32bit word
2094 d    X:00003B P:00056C 004441  DATA_WD   DC      $4441
2095   
2096 d                               TOTAL_BUFFS
2097 d    X:00003C P:00056D 000000            DC      0                                 ; total number of 512 buffers in packet
2098 d                               LEFT_TO_READ
2099 d    X:00003D P:00056E 000000            DC      0                                 ; number of words (16 bit) left to read afte
r last 512 buffer
2100 d                               LEFT_TO_WRITE
2101 d    X:00003E P:00056F 000000            DC      0                                 ; number of woreds (32 bit) to write to host
 i.e. half of those left over read
2102 d                               NUM_LEFTOVER_BLOCKS
2103 d    X:00003F P:000570 000000            DC      0                                 ; small block DMA burst transfer
2104   
2105   
2106 d                               DATA_DLY_VAL
2107 d    X:000040 P:000571 000000            DC      0                                 ; data delay value..  Delay added to first f
rame received after GO command
2108   
2109   
2110                                          IF      @SCP("ROM","ROM")                 ; Boot ROM code
2111                                 VAR_TBL_END
2112      000570                              EQU     @LCV(L)-2
2113                                          ENDIF
2114   
2115                                          IF      @SCP("ROM","ONCE")                ; Download via ONCE debugger
2117                                          ENDIF
2118   
2119                                 VAR_TBL_LENGTH
2120      000041                              EQU     VAR_TBL_END-VAR_TBL_START
2121   
2122   
2123      000572                    END_ADR   EQU     @LCV(L)                           ; End address of P: code written to ROM
2124   
2125   
**** 2126 [PCI_SCUBA_build.asm 25]:  Build is complete
2126                                          MSG     ' Build is complete'
2127   
2128   
2129   

0    Errors
0    Warnings


