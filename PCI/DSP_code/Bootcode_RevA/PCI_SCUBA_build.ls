Motorola DSP56300 Assembler  Version 6.3.4   04-11-29  14:14:18  PCI_SCUBA_build.asm  Page 1



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
Motorola DSP56300 Assembler  Version 6.3.4   04-11-29  14:14:18  PCI_SCUBA_header.asm  Page 2



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
78        000000                     EQU     0
79                         SEND_TO_HOST
80        000001                     EQU     1
81        000002           ERROR_HF  EQU     2
82        000003           FO_WRD_RCV EQU    3
83        000004           INTA_FLAG EQU     4
84        000005           BYTE_SWAP EQU     5
85                         PREAMBLE_ERROR
86        000006                     EQU     6
87     
88     
89                         ; Various addressing control registers
90        FFFFFB           BCR       EQU     $FFFFFB                           ; Bus Control Register
91        FFFFFA           DCR       EQU     $FFFFFA                           ; DRAM Control Register
92        FFFFF9           AAR0      EQU     $FFFFF9                           ; Address Attribute Register, channel 0
93        FFFFF8           AAR1      EQU     $FFFFF8                           ; Address Attribute Register, channel 1
94        FFFFF7           AAR2      EQU     $FFFFF7                           ; Address Attribute Register, channel 2
95        FFFFF6           AAR3      EQU     $FFFFF6                           ; Address Attribute Register, channel 3
96        FFFFFD           PCTL      EQU     $FFFFFD                           ; PLL control register
97        FFFFFE           IPRP      EQU     $FFFFFE                           ; Interrupt Priority register - Peripheral
98        FFFFFF           IPRC      EQU     $FFFFFF                           ; Interrupt Priority register - Core
99     
100                        ; PCI control register
101       FFFFCD           DTXS      EQU     $FFFFCD                           ; DSP Slave transmit data FIFO
102       FFFFCC           DTXM      EQU     $FFFFCC                           ; DSP Master transmit data FIFO
103       FFFFCB           DRXR      EQU     $FFFFCB                           ; DSP Receive data FIFO
104       FFFFCA           DPSR      EQU     $FFFFCA                           ; DSP PCI Status Register
105       FFFFC9           DSR       EQU     $FFFFC9                           ; DSP Status Register
106       FFFFC8           DPAR      EQU     $FFFFC8                           ; DSP PCI Address Register
107       FFFFC7           DPMC      EQU     $FFFFC7                           ; DSP PCI Master Control Register
108       FFFFC6           DPCR      EQU     $FFFFC6                           ; DSP PCI Control Register
109       FFFFC5           DCTR      EQU     $FFFFC5                           ; DSP Control Register
110    
111                        ; Port E is the Synchronous Communications Interface (SCI) port
112       FFFF9F           PCRE      EQU     $FFFF9F                           ; Port Control Register
113       FFFF9E           PRRE      EQU     $FFFF9E                           ; Port Direction Register
114       FFFF9D           PDRE      EQU     $FFFF9D                           ; Port Data Register
115    
116                        ; Various PCI register bit equates
117       000001           STRQ      EQU     1                                 ; Slave transmit data request (DSR)
118       000002           SRRQ      EQU     2                                 ; Slave receive data request (DSR)
119       000017           HACT      EQU     23                                ; Host active, low true (DSR)
120       000001           MTRQ      EQU     1                                 ; Set whem master transmitter is not full (DPSR)
Motorola DSP56300 Assembler  Version 6.3.4   04-11-29  14:14:18  PCI_SCUBA_header.asm  Page 3



121       000004           MARQ      EQU     4                                 ; Master address request (DPSR)
122       000002           MRRQ      EQU     2                                 ; Master Receive Request (DPSR)
123       00000A           TRTY      EQU     10                                ; PCI Target Retry (DPSR)
124    
125       000005           APER      EQU     5                                 ; Address parity error
126       000006           DPER      EQU     6                                 ; Data parity error
127       000007           MAB       EQU     7                                 ; Master Abort
128       000008           TAB       EQU     8                                 ; Target Abort
129       000009           TDIS      EQU     9                                 ; Target Disconnect
130       00000B           TO        EQU     11                                ; Timeout
131       00000E           MDT       EQU     14                                ; Master Data Transfer complete
132       000002           SCLK      EQU     2                                 ; SCLK = transmitter special code
133    
134                        ; bits in DPMC
135    
136       000017           FC1       EQU     23
137       000016           FC0       EQU     22
138    
139    
140                        ; DMA register definitions
141       FFFFEF           DSR0      EQU     $FFFFEF                           ; Source address register
142       FFFFEE           DDR0      EQU     $FFFFEE                           ; Destination address register
143       FFFFED           DCO0      EQU     $FFFFED                           ; Counter register
144       FFFFEC           DCR0      EQU     $FFFFEC                           ; Control register
145    
146                        ; The DCTR host flags are written by the DSP and read by PCI host
147       000003           DCTR_RPLY EQU     3                                 ; Set after reply
148       000004           DCTR_BUF0 EQU     4                                 ; Set after buffer 0 is written to
149       000005           DCTR_BUF1 EQU     5                                 ; Set after buffer 1 is written to
150       000006           INTA      EQU     6                                 ; Request PCI interrupt
151    
152                        ; The DSR host flags are written by the PCI host and read by the DSP
153       000004           DSR_BUF0  EQU     4                                 ; PCI host sets this when copying buffer 0
154       000005           DSR_BUF1  EQU     5                                 ; PCI host sets this when copying buffer 1
155    
156                        ; DPCR bit definitions
157       00000E           CLRT      EQU     14                                ; Clear transmitter
158       000012           MACE      EQU     18                                ; Master access counter enable
159       000015           IAE       EQU     21                                ; Insert Address Enable
160    
161                        ; Addresses of ESSI port
162       FFFFBC           TX00      EQU     $FFFFBC                           ; Transmit Data Register 0
163       FFFFB7           SSISR0    EQU     $FFFFB7                           ; Status Register
164       FFFFB6           CRB0      EQU     $FFFFB6                           ; Control Register B
165       FFFFB5           CRA0      EQU     $FFFFB5                           ; Control Register A
166    
167                        ; SSI Control Register A Bit Flags
168       000006           TDE       EQU     6                                 ; Set when transmitter data register is empty
169    
170                        ; Miscellaneous addresses
171       FFFFFF           RDFIFO    EQU     $FFFFFF                           ; Read the FIFO for incoming fiber optic data
172       FFFF8F           TCSR0     EQU     $FFFF8F                           ; Triper timer control and status register 0
173       FFFF8B           TCSR1     EQU     $FFFF8B                           ; Triper timer control and status register 1
174       FFFF87           TCSR2     EQU     $FFFF87                           ; Triper timer control and status register 2
175    
176                        ;***************************************************************
177                        ; Phase Locked Loop initialization
178       050003           PLL_INIT  EQU     $050003                           ; PLL = 25 MHz x 4 = 100 MHz
179                        ;****************************************************************
180    
181                        ; Port C is Enhanced Synchronous Serial Port 0
182       FFFFBF           PCRC      EQU     $FFFFBF                           ; Port C Control Register
Motorola DSP56300 Assembler  Version 6.3.4   04-11-29  14:14:18  PCI_SCUBA_header.asm  Page 4



183       FFFFBE           PRRC      EQU     $FFFFBE                           ; Port C Data direction Register
184       FFFFBD           PDRC      EQU     $FFFFBD                           ; Port C GPIO Data Register
185    
186                        ; Port D is Enhanced Synchronous Serial Port 1
187       FFFFAF           PCRD      EQU     $FFFFAF                           ; Port D Control Register
188       FFFFAE           PRRD      EQU     $FFFFAE                           ; Port D Data direction Register
189       FFFFAD           PDRD      EQU     $FFFFAD                           ; Port D GPIO Data Register
190    
191                        ; Bit number definitions of GPIO pins on Port C
192       000002           ROM_FIFO  EQU     2                                 ; Select ROM or FIFO accesses for AA1
193    
194                        ; Bit number definitions of GPIO pins on Port D
195       000000           EF        EQU     0                                 ; FIFO Empty flag, low true
196       000001           HF        EQU     1                                 ; FIFO half full flag, low true
197       000002           RS        EQU     2                                 ; FIFO reset signal, low true
198       000003           FSYNC     EQU     3                                 ; High during image transmission
199       000004           AUX1      EQU     4                                 ; enable/disable byte swapping
200       000005           WRFIFO    EQU     5                                 ; Low true if FIFO is being written to
201    
202    
203                                  INCLUDE 'PCI_SCUBA_initialisation.asm'
204                              COMMENT *
205    
206                        This is the code which is executed first after power-up etc.
207                        It sets all the internal registers to their operating values,
208                        sets up the ISR vectors and inialises the hardware etc.
209    
210                        Project:     SCUBA 2
211                        Author:      DAVID ATKINSON
212                        Target:      250MHz SDSU PCI card - DSP56301
213                        Controller:  For use with SCUBA 2 Multichannel Electronics
214    
215                        Assembler directives:
216                                ROM=EEPROM => EEPROM CODE
217                                ROM=ONCE => ONCE CODE
218    
219                                *
220                                  PAGE    132                               ; Printronix page width - 132 columns
221                                  OPT     CEX                               ; print DC evaluations
222    
**** 223 [PCI_SCUBA_initialisation.asm 20]:  INCLUDE PCI_initialisation.asm HERE  
223                                  MSG     ' INCLUDE PCI_initialisation.asm HERE  '
224    
225                        ; The EEPROM boot code expects first to read 3 bytes specifying the number of
226                        ; program words, then 3 bytes specifying the address to start loading the
227                        ; program words and then 3 bytes for each program word to be loaded.
228                        ; The program words will be condensed into 24 bit words and stored in contiguous
229                        ; PRAM memory starting at the specified starting address. Program execution
230                        ; starts from the same address where loading started.
231    
232                        ; Special address for two words for the DSP to bootstrap code from the EEPROM
233                                  IF      @SCP("ROM","ROM")                 ; Boot from ROM on power-on
234       P:000000 P:000000                   ORG     P:0,P:0
235  d    P:000000 P:000000 000588            DC      END_ADR-INIT-2                    ; Number of boot words
236  d    P:000001 P:000001 000000            DC      INIT                              ; Starting address
237       P:000000 P:000002                   ORG     P:0,P:2
238       P:000000 P:000002 0C0030  INIT      JMP     <INIT_PCI                         ; Configure PCI port
239       P:000001 P:000003 000000            NOP
240                                           ENDIF
241    
242    
243                                 ; This allows for the DSP to be loaded from the ONCE port via the WIGGLER
Motorola DSP56300 Assembler  Version 6.3.4   04-11-29  14:14:18  PCI_SCUBA_initialisation.asm  Page 5



244                                 ; command converter
245                                           IF      @SCP("ROM","ONCE")                ; Download via ONCE debugger
249                                           ENDIF
250    
251                                 ; Vectored interrupt table, addresses at the beginning are reserved
252  d    P:000002 P:000004 000000            DC      0,0,0,0,0,0,0,0,0,0,0,0,0,0       ; $02-$0f Reserved
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
253  d    P:000010 P:000012 000000            DC      0,0                               ; $10-$13 Reserved
     d                      000000
254    
255                                 ; FIFO HF* flag interrupt vector is here at $12 - this is connected to the
256                                 ; IRQB* interrupt line so its ISR vector must be here
257  d    P:000012 P:000014 000000            DC      0,0                               ; $was ld scatter routine ...HF*
     d                      000000
258    
259                                 ; a software reset button on the font panel of the card is connected to the IRQC*
260                                 ; line which if pressed causes the DSP to jump to an ISR which causes the program
261                                 ; counter to the beginning of the program INIT and sets the stack pointer to TOP.
262       P:000014 P:000016 0BF080            JSR     CLEAN_UP_PCI                      ; $14 - Software reset switch
                            0001FC
263    
264  d    P:000016 P:000018 000000            DC      0,0,0,0,0,0,0,0,0,0,0,0           ; Reserved interrupts
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
265  d    P:000022 P:000024 000000            DC      0,0,0,0,0,0,0,0,0,0,0,0,0,0
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
266    
267                                 ; Now we're at P:$30, where some unused vector addresses are located
268                                 ; This is ROM only code that is only executed once on power-up when the
Motorola DSP56300 Assembler  Version 6.3.4   04-11-29  14:14:18  PCI_SCUBA_initialisation.asm  Page 6



269                                 ; ROM code is downloaded. It is skipped over on OnCE downloads.
270    
271                                 ; A few seconds after power up on the Host, it interrogates the PCI bus to find
272                                 ; out what boards are installed and configures this PCI board. The EEPROM booting
273                                 ; procedure ends with program execution  starting at P:$0 where the EEPROM has
274                                 ; inserted a JMP INIT_PCI instruction. This routine sets the PLL paramter and
275                                 ; does a self configuration and software reset of the PCI controller in the DSP.
276                                 ; After configuring the PCI controller the DSP program overwrites the instruction
277                                 ; at P:$0 with a new JMP START to skip over the INIT_PCI routine. The program at
278                                 ; START address begins configuring the DSP and processing commands.
279                                 ; Similarly the ONCE option places a JMP START at P:$0 to skip over the
280                                 ; INIT_PCI routine. If this routine where executed after the host computer had booted
281                                 ; it would cause it to crash since the host computer would overwrite the
282                                 ; configuration space with its own values and doesn't tolerate foreign values.
283    
284                                 ; Initialize the PLL - phase locked loop
285                                 INIT_PCI
286       P:000030 P:000032 08F4BD            MOVEP             #PLL_INIT,X:PCTL        ; Initialize PLL
                            050003
287       P:000032 P:000034 000000            NOP
288    
289                                 ; Program the PCI self-configuration registers
290       P:000033 P:000035 240000            MOVE              #0,X0
291       P:000034 P:000036 08F485            MOVEP             #$500000,X:DCTR         ; Set self-configuration mode
                            500000
292       P:000036 P:000038 0604A0            REP     #4
293       P:000037 P:000039 08C408            MOVEP             X0,X:DPAR               ; Dummy writes to configuration space
294       P:000038 P:00003A 08F487            MOVEP             #>$0000,X:DPMC          ; Subsystem ID
                            000000
295       P:00003A P:00003C 08F488            MOVEP             #>$0000,X:DPAR          ; Subsystem Vendor ID
                            000000
296    
297                                 ; PCI Personal reset
298       P:00003C P:00003E 08C405            MOVEP             X0,X:DCTR               ; Personal software reset
299       P:00003D P:00003F 000000            NOP
300       P:00003E P:000040 000000            NOP
301       P:00003F P:000041 0A89B7            JSET    #HACT,X:DSR,*                     ; Test for personal reset completion
                            00003F
302       P:000041 P:000043 07F084            MOVE              P:(*+3),X0              ; Trick to write "JMP <START" to P:0
                            000044
303       P:000043 P:000045 070004            MOVE              X0,P:(0)
304       P:000044 P:000046 0C0100            JMP     <START
305    
306  d    P:000045 P:000047 000000            DC      0,0,0,0,0,0,0,0,0,0,0,0           ; Filler
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
307  d    P:000051 P:000053 000000            DC      0,0,0,0,0,0,0,0,0,0,0,0           ; Filler
     d                      000000
     d                      000000
     d                      000000
     d                      000000
     d                      000000
     d                      000000
Motorola DSP56300 Assembler  Version 6.3.4   04-11-29  14:14:18  PCI_SCUBA_initialisation.asm  Page 7



     d                      000000
     d                      000000
     d                      000000
     d                      000000
     d                      000000
308  d    P:00005D P:00005F 000000            DC      0,0,0,0,0,0,0,0,0,0,0,0           ; $60-$71 Reserved PCI
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
309    
310                                 ;**************************************************************************
311                                 ; Check for program space overwriting of ISR starting at P:$72
312                                           IF      @CVS(N,*)>$71
314                                           ENDIF
315    
316                                 ;       ORG     P:$72,P:$72
317       P:000072 P:000074                   ORG     P:$72,P:$74
318    
319                                 ; This allows for the DSP to be loaded from the ONCE port via the WIGGLER
320                                 ; command converter
321                                           IF      @SCP("ROM","ONCE")                ; Download via ONCE debugger
323                                           ENDIF
324    
325    
326                                 ;**************************************************************************
327    
328                                 ; Three non-maskable fast interrupt service routines for clearing PCI interrupts
329                                 ; The Host will use these to clear the INTA* after it has serviced the interrupt
330                                 ; which had been generated by the PCI board.
331    
332       P:000072 P:000074 0A8506            BCLR    #INTA,X:DCTR                      ; $72/3 - Clear PCI interrupt
333       P:000073 P:000075 000000            NOP
334    
335       P:000074 P:000076 0A0004            BCLR    #INTA_FLAG,X:<STATUS              ; $74/5 - Clear PCI interrupt
336       P:000075 P:000077 000000            NOP                                       ; needs to be fast addressing <
337    
338       P:000076 P:000078 0A8506            BCLR    #INTA,X:DCTR                      ; $76/7 - Clear PCI interrupt
339       P:000077 P:000079 000000            NOP
340    
341                                 ; Interrupt locations for 7 available commands on PCI board
342                                 ; Each JSR takes up 2 locations in the table
343       P:000078 P:00007A 0BF080            JSR     WRITE_MEMORY                      ; $78
                            000208
344       P:00007A P:00007C 0BF080            JSR     READ_MEMORY                       ; $7A
                            00023E
345       P:00007C P:00007E 0BF080            JSR     START_APPLICATION                 ; $7C
                            000276
346       P:00007E P:000080 0BF080            JSR     STOP_APPLICATION                  ; $7E
                            00029D
347                                 ; software reset is the same as cleaning up the PCI - use same routine
348                                 ; when HOST does a RESET then this routine is run
349       P:000080 P:000082 0BF080            JSR     SOFTWARE_RESET                    ; $80
                            0002C5
350       P:000082 P:000084 0BF080            JSR     SEND_PACKET_TO_CONTROLLER         ; $82
Motorola DSP56300 Assembler  Version 6.3.4   04-11-29  14:14:18  PCI_SCUBA_initialisation.asm  Page 8



                            0002FA
351       P:000084 P:000086 0BF080            JSR     SEND_PACKET_TO_HOST               ; $84
                            000353
352       P:000086 P:000088 0BF080            JSR     RESET_CONTROLLER                  ; $86
                            00037B
353    
354    
355                                 ; ***********************************************************************
356                                 ; For now have boot code starting from P:$100
357                                 ; just to make debugging tidier etc.
358    
359       P:000100 P:000102                   ORG     P:$100,P:$102
360    
361                                 ; This allows for the DSP to be loaded from the ONCE port via the WIGGLER
362                                 ; command converter
363                                           IF      @SCP("ROM","ONCE")                ; Download via ONCE debugger
365                                           ENDIF
366                                 ; ***********************************************************************
367    
368    
369    
370                                 ; ******************************************************************
371                                 ;
372                                 ;       AA0 = RDFIFO* of incoming fiber optic data
373                                 ;       AA1 = EEPROM access
374                                 ;       AA2 = DRAM access
375                                 ;       AA3 = output to parallel data connector, for a video pixel clock
376                                 ;       $FFxxxx = Write to fiber optic transmitter
377                                 ;
378                                 ; ******************************************************************
379    
380    
381       P:000100 P:000102 08F487  START     MOVEP             #>$000001,X:DPMC
                            000001
382       P:000102 P:000104 0A8534            BSET    #20,X:DCTR                        ; HI32 mode = 1 => PCI
383       P:000103 P:000105 0A8515            BCLR    #21,X:DCTR
384       P:000104 P:000106 0A8516            BCLR    #22,X:DCTR
385       P:000105 P:000107 000000            NOP
386       P:000106 P:000108 0A8632            BSET    #MACE,X:DPCR                      ; Master access counter enable
387       P:000107 P:000109 000000            NOP
388    
389    
390                                 ;       BSET    #IAE,X:DPCR             ; Insert PCI address before data
391                                 ; Unlike Bob Leach's code
392                                 ; we don't want IAE set in DPCR or else  data read by DSP from
393                                 ; DRXR FIFO will contain address of data as well as data...
394    
395       P:000108 P:00010A 000000            NOP                                       ; End of PCI programming
396    
397    
398                                 ; Set operation mode register OMR to normal expanded
399       P:000109 P:00010B 0500BA            MOVEC             #$0000,OMR              ; Operating Mode Register = Normal Expanded
400       P:00010A P:00010C 0500BB            MOVEC             #0,SP                   ; Reset the Stack Pointer SP
401    
402                                 ; Program the serial port ESSI0 = Port C for serial transmission to
403                                 ;   the timing board
404       P:00010B P:00010D 07F43F            MOVEP             #>0,X:PCRC              ; Software reset of ESSI0
                            000000
405                                 ;**********************************************************************
406       P:00010D P:00010F 07F435            MOVEP             #$00080B,X:CRA0         ; Divide 100.0 MHz by 24 to get 4.17 MHz
                            00080B
407                                                                                     ; DC0-CD4 = 0 for non-network operation
Motorola DSP56300 Assembler  Version 6.3.4   04-11-29  14:14:18  PCI_SCUBA_initialisation.asm  Page 9



408                                                                                     ; WL0-WL2 = ALC = 0 for 2-bit data words
409                                                                                     ; SSC1 = 0 for SC1 not used
410                                 ;************************************************************************
411       P:00010F P:000111 07F436            MOVEP             #$010120,X:CRB0         ; SCKD = 1 for internally generated clock
                            010120
412                                                                                     ; SHFD = 0 for MSB shifted first
413                                                                                     ; CKP = 0 for rising clock edge transitions
414                                                                                     ; TE0 = 1 to enable transmitter #0
415                                                                                     ; MOD = 0 for normal, non-networked mode
416                                                                                     ; FSL1 = 1, FSL0 = 0 for on-demand transmit
417       P:000111 P:000113 07F43F            MOVEP             #%101000,X:PCRC         ; Control Register (0 for GPIO, 1 for ESSI)
                            000028
418                                                                                     ; Set SCK0 = P3, STD0 = P5 to ESSI0
419                                 ;********************************************************************************
420       P:000113 P:000115 07F43E            MOVEP             #%111100,X:PRRC         ; Data Direction Register (0 for In, 1 for O
ut)
                            00003C
421       P:000115 P:000117 07F43D            MOVEP             #%000000,X:PDRC         ; Data Register - AUX3 = i/p, AUX1 not used
                            000000
422                                 ;***********************************************************************************
423                                 ; 250MHz
424                                 ; Conversion from software bits to schematic labels for Port C and D
425                                 ;       PC0 = SC00 = AUX3               PD0 = SC10 = EF*
426                                 ;       PC1 = SC01 = A/B* = input       PD1 = SC11 = HF*
427                                 ;       PC2 = SC02 = No connect         PD2 = SC12 = RS*
428                                 ;       PC3 = SCK0 = No connect         PD3 = SCK1 = NWRFIFO*
429                                 ;       PC4 = SRD0 = AUX1               PD4 = SRD1 = No connect (** in 50Mhz this was MODE selec
t for 16 or 32 bit FO)
430                                 ;       PC5 = STD0 = No connect         PD5 = STD1 = WRFIFO*
431                                 ; ***********************************************************************************
432    
433    
434                                 ; ****************************************************************************
435                                 ; Program the serial port ESSI1 = Port D for general purpose I/O (GPIO)
436    
437       P:000117 P:000119 07F42F            MOVEP             #%000000,X:PCRD         ; Control Register (0 for GPIO, 1 for ESSI)
                            000000
438       P:000119 P:00011B 07F42E            MOVEP             #%011100,X:PRRD         ; Data Direction Register (0 for In, 1 for O
ut)
                            00001C
439       P:00011B P:00011D 07F42D            MOVEP             #%011000,X:PDRD         ; Data Register - Pulse RS* low
                            000018
440       P:00011D P:00011F 060AA0            REP     #10
441       P:00011E P:000120 000000            NOP
442       P:00011F P:000121 07F42D            MOVEP             #%011100,X:PDRD         ; Data Register - Pulse RS* high
                            00001C
443    
444                                 ; note.....in 50MHz bit 4 selected FO receive 'MODE'
445                                 ; MODE = 1, 32 bit receive on FO
446                                 ; MODE = 0, 16 bit receive on FO
447                                 ; ultracam always used MODE = 0
448                                 ; however here bit 4 PD4 not connected so 32 bit or 16bit?
449    
450    
451    
452                                 ; Program the SCI port to benign values
453       P:000121 P:000123 07F41F            MOVEP             #%000,X:PCRE            ; Port Control Register = GPIO
                            000000
454       P:000123 P:000125 07F41E            MOVEP             #%110,X:PRRE            ; Port Direction Register (0 = Input)
                            000006
455       P:000125 P:000127 07F41D            MOVEP             #%010,X:PDRE            ; Port Data Register
                            000002
Motorola DSP56300 Assembler  Version 6.3.4   04-11-29  14:14:18  PCI_SCUBA_initialisation.asm  Page 10



456                                 ;       PE0 = RXD
457                                 ;       PE1 = TXD
458                                 ;       PE2 = SCLK
459    
460                                 ; Program the triple timer to assert TCI0 as an GPIO output = 1
461       P:000127 P:000129 07F40F            MOVEP             #$2800,X:TCSR0
                            002800
462       P:000129 P:00012B 07F40B            MOVEP             #$2800,X:TCSR1
                            002800
463       P:00012B P:00012D 07F407            MOVEP             #$2800,X:TCSR2
                            002800
464    
465    
466                                 ; Program the address attribute pins AA0 to AA2. AA3 is not yet implemented.
467       P:00012D P:00012F 08F4B9            MOVEP             #$FFFC21,X:AAR0         ; Y = $FFF000 to $FFFFFF asserts Y:RDFIFO*
                            FFFC21
468       P:00012F P:000131 08F4B8            MOVEP             #$008929,X:AAR1         ; P = $008000 to $00FFFF asserts AA1 low tru
e
                            008929
469       P:000131 P:000133 08F4B7            MOVEP             #$000122,X:AAR2         ; Y = $000800 to $7FFFFF accesses SRAM
                            000122
470    
471    
472                                 ; Program the DRAM memory access and addressing
473       P:000133 P:000135 08F4BB            MOVEP             #$020022,X:BCR          ; Bus Control Register
                            020022
474       P:000135 P:000137 08F4BA            MOVEP             #$893A05,X:DCR          ; DRAM Control Register
                            893A05
475    
476    
477                                 ; Clear all PCI error conditions
478       P:000137 P:000139 084E0A            MOVEP             X:DPSR,A
479       P:000138 P:00013A 0140C2            OR      #$1FE,A
                            0001FE
480       P:00013A P:00013C 000000            NOP
481       P:00013B P:00013D 08CE0A            MOVEP             A,X:DPSR
482    
483                                 ; Enable one interrupt only: software reset switch
484       P:00013C P:00013E 08F4BF            MOVEP             #$0001C0,X:IPRC         ; IRQB priority = 1 (FIFO half full HF*)
                            0001C0
485                                                                                     ; IRQC priority = 2 (reset switch)
486       P:00013E P:000140 05F439            MOVE              #$200,SR                ; Mask set up for reset switch only
                            000200
487    
488    
489    
490                                 ; bob leach 250MHz code
491                                 ; Establish interrupt priority levels IPL
492                                 ;       MOVEP   #$0001C0,X:IPRC ; IRQC priority IPL = 2 (reset switch, edge)
493                                 ;                               ; IRQB priority IPL = 2 or 0
494                                 ;                               ;     (FIFO half full - HF*, level)
495                                 ;       MOVEP   #>2,X:IPRP      ; Enable PCI Host interrupts, IPL = 1
496                                 ;       BSET    #HCIE,X:DCTR    ; Enable host command interrupts
497                                 ;       MOVE    #0,SR           ; Don't mask any interrupts
498    
499    
500                                 ; Initialize the fiber optic serial transmitter to zero
501       P:000140 P:000142 01B786            JCLR    #TDE,X:SSISR0,*
                            000140
502       P:000142 P:000144 07F43C            MOVEP             #$000000,X:TX00
                            000000
503    
Motorola DSP56300 Assembler  Version 6.3.4   04-11-29  14:14:18  PCI_SCUBA_initialisation.asm  Page 11



504                                 ; Clear out the PCI receiver and transmitter FIFOs
505    
506                                 ; clear DTXM - master transmitter
507       P:000144 P:000146 0A862E            BSET    #CLRT,X:DPCR                      ; Clear the master transmitter DTXM
508       P:000145 P:000147 0A86AE            JSET    #CLRT,X:DPCR,*                    ; Wait for the clearing to be complete
                            000145
509    
510                                 ; clear DRXR - receiver
511    
512       P:000147 P:000149 0A8982  CLR0      JCLR    #SRRQ,X:DSR,CLR1                  ; Wait for the receiver to be empty
                            00014C
513       P:000149 P:00014B 08440B            MOVEP             X:DRXR,X0               ; Read receiver to empty it
514       P:00014A P:00014C 000000            NOP
515       P:00014B P:00014D 0C0147            JMP     <CLR0
516                                 CLR1
517    
518                                 ; added code to initialise x table slots to zero
519    
520       P:00014C P:00014E 200013            CLR     A
521       P:00014D P:00014F 60F400            MOVE              #NO_BUFFERS,R0          ; start address of table
                            000800
522       P:00014F P:000151 0600A8            REP     #NO_BUFFERS                       ; size of table
523       P:000150 P:000152 565800            MOVE              A,X:(R0)+
524    
525    
526                                 ;  PCI address increment of 4 added here.
527                                 ; Y register not used in any other part of code
528                                 ; other than ISRs which restore this value.
529                                 ; using Y reg enables the +4 increment to be done in one cycle
530                                 ; rather than rep #4 inc commands
531    
532       P:000151 P:000153 270000            MOVE              #0,Y1                   ; initialise Y for PCI increment.
533       P:000152 P:000154 46B500            MOVE              X:<FOUR,Y0
534    
535    
536                                 ; copy parameter table from P memory into X memory
537    
538                                 ; Move the table of constants from P: space to X: space
539       P:000153 P:000155 61F400            MOVE              #VAR_TBL_START,R1       ; Start of parameter table in P
                            000548
540       P:000155 P:000157 300000            MOVE              #VAR_TBL,R0             ; start of parameter table in X
541       P:000156 P:000158 064080            DO      #VAR_TBL_LENGTH,X_WRITE
                            000159
542       P:000158 P:00015A 07D984            MOVE              P:(R1)+,X0
543       P:000159 P:00015B 445800            MOVE              X0,X:(R0)+              ; Write the constants to X:
544                                 X_WRITE
545    
546    
547                                 ; Her endth the initialisation code after power up only where the code has
548                                 ; been bootstrapped from the EEPROM - remember the code is not run if the
549                                 ; reset button is pressed only if the HOST computer has been RESET.
550    
551    
552       P:00015A P:00015C 0A0000            BCLR    #APPLICATION_LOADED,X:<STATUS     ; clear application flag
553    
554    
555    
556                                 ; disable FIFO HF* intererupt...not used anymore.
557    
558       P:00015B P:00015D 08F4BF            MOVEP             #$0001C0,X:IPRC         ; Disable FIFO HF* interrupt
                            0001C0
559       P:00015D P:00015F 05F439            MOVEC             #$200,SR                ; Mask level 1 interrupts
Motorola DSP56300 Assembler  Version 6.3.4   04-11-29  14:14:18  PCI_SCUBA_initialisation.asm  Page 12



                            000200
560    
561                                 ; BYTE SWAPPING is ENABLED
562       P:00015F P:000161 0A0025            BSET    #BYTE_SWAP,X:<STATUS              ; flag to let host know byte swapping on
563       P:000160 P:000162 013D24            BSET    #AUX1,X:PDRC                      ; enable hardware
564    
565       P:000161 P:000163 0A0006            BCLR    #PREAMBLE_ERROR,X:<STATUS         ; flag to let host know premable error
566    
567                                 ; END of Scuba 2 initialisation code after power up
568                                 ; --------------------------------------------------------------------
569                                           INCLUDE 'PCI_SCUBA_main.asm'
570                                  COMMENT *
571    
572                                 This is the main section of the pci card code.
573    
574                                 Project:     SCUBA 2
575                                 Author:      DAVID ATKINSON
576                                 Target:      250MHz SDSU PCI card - DSP56301
577                                 Controller:  For use with SCUBA 2 Multichannel Electronics
578    
579                                 Version:     Release Version A
580    
581    
582                                 Assembler directives:
583                                         ROM=EEPROM => EEPROM CODE
584                                         ROM=ONCE => ONCE CODE
585    
586                                         *
587                                           PAGE    132                               ; Printronix page width - 132 columns
588                                           OPT     CEX                               ; print DC evaluations
589    
**** 590 [PCI_SCUBA_main.asm 21]:  INCLUDE PCI_main.asm HERE  
590                                           MSG     ' INCLUDE PCI_main.asm HERE  '
591    
592                                 ; ****************************************************
593                                 ; ************* MAIN PACKET SWITCHING CODE ***********
594                                 ; ****************************************************
595    
596                                 ; initialse buffer pointers
597                                 PACKET_IN
598       P:000162 P:000164 310000            MOVE              #<IMAGE_BUFFER,R1       ; pointer for Fibre ---> Y mem
599       P:000163 P:000165 320000            MOVE              #<IMAGE_BUFFER,R2       ; pointer for Y mem ---> PCI BUS
600    
601                                 ; R1 used as pointer for data written to y:memory            FO --> (Y)
602                                 ; R2 used as pointer for date in y mem to be writen to host  (Y) --> HOST
603    
604    
605       P:000164 P:000166 0A7001            BCLR    #SEND_TO_HOST,X:STATUS            ; clear send to host flag
                            000000
606       P:000166 P:000168 0A0002            BCLR    #ERROR_HF,X:<STATUS               ; clear error flag
607       P:000167 P:000169 0A0003            BCLR    #FO_WRD_RCV,X:<STATUS             ; clear Fiber Optic flag
608    
609    
610                                 ; PCI test application loaded?
611       P:000168 P:00016A 0A00A0            JSET    #APPLICATION_LOADED,X:STATUS,APPLICATION ; at P:$800 for just now
                            000800
612    
613                                 ; if 'GOA' command has been sent will jump to application memory space
614                                 ; note that applications should terminate with the line 'JMP PACKET_IN'
615                                 ; terminate appl with a STP command
616    
617    
Motorola DSP56300 Assembler  Version 6.3.4   04-11-29  14:14:18  PCI_SCUBA_main.asm  Page 13



618       P:00016A P:00016C 0D04CC  CHK_FIFO  JSR     <GET_FO_WRD                       ; see if there's a 16-bit word in Fibre FIFO
 from MCE
619                                                                                     ; if so it will be in X0 (should be 'A5A5' -
 preamble)
620    
621    
622       P:00016B P:00016D 0A00A3            JSET    #FO_WRD_RCV,X:<STATUS,CHECK_WD    ; if there is check its preamble
                            00016E
623       P:00016D P:00016F 0C0162            JMP     <PACKET_IN                        ; else go back and repeat
624    
625                                 ; check that we have $a5a5a5a5 then $5a5a5a5a
626    
627       P:00016E P:000170 441700  CHECK_WD  MOVE              X0,X:<HEAD_W1_1         ;store received word
628       P:00016F P:000171 56F000            MOVE              X:PREAMB1,A
                            000039
629       P:000171 P:000173 200045            CMP     X0,A                              ; check it is correct
630       P:000172 P:000174 0E2186            JNE     <PRE_ERROR                        ; if not go to start
631    
632    
633       P:000173 P:000175 0D04D4            JSR     <WT_FIFO                          ; wait for next preamble 16-bit word
634       P:000174 P:000176 441800            MOVE              X0,X:<HEAD_W1_0         ;store received word
635       P:000175 P:000177 56F000            MOVE              X:PREAMB1,A
                            000039
636       P:000177 P:000179 200045            CMP     X0,A                              ; check it is correct
637       P:000178 P:00017A 0E2186            JNE     <PRE_ERROR                        ; if not go to start
638    
639    
640       P:000179 P:00017B 0D04D4            JSR     <WT_FIFO                          ; wait for next preamble 16-bit word
641       P:00017A P:00017C 441900            MOVE              X0,X:<HEAD_W2_1         ;store received word
642       P:00017B P:00017D 56F000            MOVE              X:PREAMB2,A
                            00003A
643       P:00017D P:00017F 200045            CMP     X0,A                              ; check it is correct
644       P:00017E P:000180 0E2186            JNE     <PRE_ERROR                        ; if not go to start
645    
646       P:00017F P:000181 0D04D4            JSR     <WT_FIFO                          ; wait for next preamble 16-bit word
647       P:000180 P:000182 441A00            MOVE              X0,X:<HEAD_W2_0         ;store received word
648       P:000181 P:000183 56F000            MOVE              X:PREAMB2,A
                            00003A
649       P:000183 P:000185 200045            CMP     X0,A                              ; check it is correct
650       P:000184 P:000186 0E2186            JNE     <PRE_ERROR                        ; if not go to start
651       P:000185 P:000187 0C0189            JMP     <PACKET_INFO                      ; get packet info
652    
653    
654                                 PRE_ERROR
655       P:000186 P:000188 0A0026            BSET    #PREAMBLE_ERROR,X:<STATUS         ; indicate a preamble error
656       P:000187 P:000189 440200            MOVE              X0,X:<PRE_CORRUPT       ; store corrupted word
657       P:000188 P:00018A 0C0162            JMP     <PACKET_IN                        ; wait for next packet
658    
659    
660                                 PACKET_INFO                                         ; packet preamble valid
661    
662                                 ; Packet preamle is valid so....
663                                 ; now get next two 32bit words.  i.e. $20205250 $00000004, or $20204441 $xxxxxxxx
664                                 ; note that these are received little endian (and byte swapped)
665                                 ; i.e. for RP receive 50 52 20 20  04 00 00 00
666                                 ; but byte swapped on arrival
667                                 ; 5250
668                                 ; 2020
669                                 ; 0004
670                                 ; 0000
671    
672       P:000189 P:00018B 0D04D4            JSR     <WT_FIFO
Motorola DSP56300 Assembler  Version 6.3.4   04-11-29  14:14:18  PCI_SCUBA_main.asm  Page 14



673       P:00018A P:00018C 441C00            MOVE              X0,X:<HEAD_W3_0         ; RP or DA
674       P:00018B P:00018D 0D04D4            JSR     <WT_FIFO
675       P:00018C P:00018E 441B00            MOVE              X0,X:<HEAD_W3_1         ; $2020
676       P:00018D P:00018F 0D04D4            JSR     <WT_FIFO
677       P:00018E P:000190 441E00            MOVE              X0,X:<HEAD_W4_0         ; packet size lo
678       P:00018F P:000191 0D04D4            JSR     <WT_FIFO
679       P:000190 P:000192 441D00            MOVE              X0,X:<HEAD_W4_1         ; packet size hi
680    
681       P:000191 P:000193 200013            CLR     A                                 ; check if it's a frame of data
682       P:000192 P:000194 449C00            MOVE              X:<HEAD_W3_0,X0
683       P:000193 P:000195 56BB00            MOVE              X:<DATA_WD,A            ; $4441
684       P:000194 P:000196 200045            CMP     X0,A
685       P:000195 P:000197 0AF0A2            JNE     MCE_PACKET                        ; if not - then must be a command reply
                            00019C
686                                 INC_FRAME_COUNT                                     ; if frame then inc count (which host PC can
 interrogate/clear)
687    
688                                 ; increment frame count
689    
690       P:000197 P:000199 200013            CLR     A
691       P:000198 P:00019A 508100            MOVE              X:<FRAME_COUNT,A0
692       P:000199 P:00019B 000008            INC     A
693       P:00019A P:00019C 000000            NOP
694       P:00019B P:00019D 500100            MOVE              A0,X:<FRAME_COUNT
695    
696    
697                                 ; *********************************************************************
698                                 ; *********************** IT'S A PAKCET FROM MCE ***********************
699                                 ; ***********************************************************************
700                                 ; ***  Data or reply packet from MCE *******
701    
702                                 ; prepare notify to inform host that a packet has arrived.
703    
704                                 MCE_PACKET
705       P:00019C P:00019E 44F400            MOVE              #'NFY',X0               ; initialise communication to host as a noti
fy
                            4E4659
706       P:00019E P:0001A0 440700            MOVE              X0,X:<DTXS_WD1          ; 1st word transmitted to host to notify the
re's a message
707    
708       P:00019F P:0001A1 449C00            MOVE              X:<HEAD_W3_0,X0         ;RP or DA
709       P:0001A0 P:0001A2 440800            MOVE              X0,X:<DTXS_WD2          ;2nd word transmitted to host to notify ther
e's a message
710    
711       P:0001A1 P:0001A3 449E00            MOVE              X:<HEAD_W4_0,X0         ; size of packet LSB 16bits (# 32bit words)
712       P:0001A2 P:0001A4 440900            MOVE              X0,X:<DTXS_WD3          ; 3rd word transmitted to host to notify the
re's a message
713    
714       P:0001A3 P:0001A5 449D00            MOVE              X:<HEAD_W4_1,X0         ; size of packet MSB 16bits (# of 32bit word
s)
715       P:0001A4 P:0001A6 440A00            MOVE              X0,X:<DTXS_WD4          ; 4th word transmitted to host to notify the
re's a message
716    
717    
718                                 ; ********************* HOW MANY BUFFERS *******************************************************
*********
719    
720                                 ; Note that this JSP uses accumulator B
721                                 ; therefore it MUST be run before we get the bus address from host...
722                                 ; i.e before we send 'NFY'
723    
724       P:0001A5 P:0001A7 0D0515            JSR     <CALC_NO_BUFFS                    ; subroutine which calculates the number of 
Motorola DSP56300 Assembler  Version 6.3.4   04-11-29  14:14:18  PCI_SCUBA_main.asm  Page 15



512 (16bit) buffers
725                                                                                     ; number of left over 32 (16bit) blocks
726                                                                                     ; and number of left overs (16bit) words
727    
728                                 ;  note that a 512 (16-bit) buffer is transfered to the host as a 256 x 32bit burst
729                                 ;            a 32  (16-bit) block is transfered to the host as a 16 x 32bit burst
730                                 ;            left over 16bit words are transfered to the host in pairs as 32bit words
731                                 ; **********************************************************************************************
******************
732    
733    
734       P:0001A6 P:0001A8 200013            CLR     A
735       P:0001A7 P:0001A9 44BC00            MOVE              X:<TOTAL_BUFFS,X0
736       P:0001A8 P:0001AA 200045            CMP     X0,A                              ; are there any 512 buffers to process
737       P:0001A9 P:0001AB 0EA1AB            JEQ     <CHK_SMALL_BLK                    ; is it a very small packet - i.e less than 
512 words so no 512 buffers
738       P:0001AA P:0001AC 0C01B4            JMP     <WT_HOST_3                        ; there is a 512 block to move
739    
740                                 CHK_SMALL_BLK
741       P:0001AB P:0001AD 200013            CLR     A
742       P:0001AC P:0001AE 44BF00            MOVE              X:<NUM_LEFTOVER_BLOCKS,X0
743       P:0001AD P:0001AF 200045            CMP     X0,A                              ; are there any 32 blocks to process
744       P:0001AE P:0001B0 0E21B4            JNE     <WT_HOST_3                        ; there is a 32 (16bit) block to transfer
745    
746    
747       P:0001AF P:0001B1 0D03C6  WT_HOST_2 JSR     <PCI_MESSAGE_TO_HOST              ; notify host of packet
748       P:0001B0 P:0001B2 0A0081            JCLR    #SEND_TO_HOST,X:<STATUS,*         ; wait for host to reply - which it does wit
h 'send_packet_to_host' ISR
                            0001B0
749       P:0001B2 P:0001B4 0A0001            BCLR    #SEND_TO_HOST,X:<STATUS           ; tidy up
750       P:0001B3 P:0001B5 0C01D6            JMP     <LEFT_OVERS                       ; jump to left overs since HF not required
751    
752    
753       P:0001B4 P:0001B6 0D03C6  WT_HOST_3 JSR     <PCI_MESSAGE_TO_HOST              ; notify host of packet
754       P:0001B5 P:0001B7 0A0081            JCLR    #SEND_TO_HOST,X:<STATUS,*         ; wait for host to reply - which it does wit
h 'send_packet_to_host' ISR
                            0001B5
755       P:0001B7 P:0001B9 0A0001            BCLR    #SEND_TO_HOST,X:<STATUS           ; tidy up
756    
757    
758                                 ; we now have 32 bit address in accumulator B
759                                 ; from send-packet_to_host
760    
761                                 ; ************************* DO LOOP to write buffers to host ***********************************
***
762    
763       P:0001B8 P:0001BA 063C00            DO      X:<TOTAL_BUFFS,ALL_BUFFS_END
                            0001C6
764    
765    
766       P:0001BA P:0001BC 310000            MOVE              #<IMAGE_BUFFER,R1       ; FO ---> Y mem
767       P:0001BB P:0001BD 320000            MOVE              #<IMAGE_BUFFER,R2       ; Y mem ----->  PCI BUS
768    
769                                 WAIT_BUFF
770       P:0001BC P:0001BE 01ADA1            JSET    #HF,X:PDRD,*                      ; Wait for FIFO to be half full + 1
                            0001BC
771       P:0001BE P:0001C0 000000            NOP
772       P:0001BF P:0001C1 000000            NOP
773       P:0001C0 P:0001C2 01ADA1            JSET    #HF,X:PDRD,WAIT_BUFF              ; Protection against metastability
                            0001BC
774    
775    
Motorola DSP56300 Assembler  Version 6.3.4   04-11-29  14:14:18  PCI_SCUBA_main.asm  Page 16



776                                 ; Copy the image block as 512 x 16bit words to DSP Y: Memory using R1 as pointer
777       P:0001C2 P:0001C4 060082            DO      #512,L_BUFFER
                            0001C4
778       P:0001C4 P:0001C6 0959FF            MOVEP             Y:RDFIFO,Y:(R1)+
779                                 L_BUFFER
780    
781    
782                                 ; R2 points to data in Y memory to be written to host
783                                 ; host address is in B - got by SEND_PACKET_TO_HOST command
784                                 ; so we can now write this buffer to host
785    
786       P:0001C5 P:0001C7 0D0453            JSR     <WRITE_512_TO_PCI                 ; this subroutine will increment host addres
s, which is in B and R2
787       P:0001C6 P:0001C8 000000            NOP
788                                 ALL_BUFFS_END                                       ; all buffers have been writen to host
789    
790                                 ; ******************************* END of buffer read/write DO LOOP *****************************
************************
791    
792                                 ; less than 512 pixels but if greater than 32 will then do bursts
793                                 ; of 16 x 32bit in length, if less than 32 then does single read writes
794    
795       P:0001C7 P:0001C9 063F00            DO      X:<NUM_LEFTOVER_BLOCKS,LEFTOVER_BLOCKS
                            0001D5
796       P:0001C9 P:0001CB 310000            MOVE              #<IMAGE_BUFFER,R1       ; FO ---> Y mem
797       P:0001CA P:0001CC 320000            MOVE              #<IMAGE_BUFFER,R2       ; Y mem ----->  PCI BUS
798    
799       P:0001CB P:0001CD 062080            DO      #32,S_BUFFER
                            0001D3
800       P:0001CD P:0001CF 01AD80  WAIT_1    JCLR    #EF,X:PDRD,*                      ; Wait for the pixel datum to be there
                            0001CD
801       P:0001CF P:0001D1 000000            NOP                                       ; Settling time
802       P:0001D0 P:0001D2 000000            NOP
803       P:0001D1 P:0001D3 01AD80            JCLR    #EF,X:PDRD,WAIT_1                 ; Protection against metastability
                            0001CD
804       P:0001D3 P:0001D5 0959FF            MOVEP             Y:RDFIFO,Y:(R1)+
805                                 S_BUFFER
806    
807       P:0001D4 P:0001D6 0D047F            JSR     <WRITE_32_TO_PCI                  ; write small blocks
808       P:0001D5 P:0001D7 000000            NOP
809                                 LEFTOVER_BLOCKS
810    
811    
812    
813                                 LEFT_OVERS
814       P:0001D6 P:0001D8 310000            MOVE              #<IMAGE_BUFFER,R1       ; FO ---> Y mem
815       P:0001D7 P:0001D9 320000            MOVE              #<IMAGE_BUFFER,R2       ; Y mem ----->  PCI BUS
816    
817       P:0001D8 P:0001DA 063D00            DO      X:<LEFT_TO_READ,LEFT_OVERS_READ   ; read in remaining words of data packet
                            0001DB
818       P:0001DA P:0001DC 0D04E4            JSR     <WT_FIFO_DA                       ; each word from FIFO to X0
819       P:0001DB P:0001DD 4C5900            MOVE                          X0,Y:(R1)+  ; now store in Y memory
820                                 LEFT_OVERS_READ
821    
822                                 ; now write left overs to host as 32 bit words
823    
824       P:0001DC P:0001DE 063E00            DO      X:LEFT_TO_WRITE,LEFT_OVERS_WRITEN ; left overs to write is half left overs rea
d - since 32 bit writes
                            0001DF
825       P:0001DE P:0001E0 0BF080            JSR     WRITE_TO_PCI                      ; uses R2 as pointer to Y memory, host addre
ss in B
                            000433
Motorola DSP56300 Assembler  Version 6.3.4   04-11-29  14:14:18  PCI_SCUBA_main.asm  Page 17



826                                 LEFT_OVERS_WRITEN
827    
828    
829    
830                                 ; reply to host's send_packet_to_host command
831    
832                                  HST_ACK_REP
833       P:0001E0 P:0001E2 44F400            MOVE              #'REP',X0
                            524550
834       P:0001E2 P:0001E4 440700            MOVE              X0,X:<DTXS_WD1          ; REPly
835       P:0001E3 P:0001E5 44F400            MOVE              #'HST',X0
                            485354
836       P:0001E5 P:0001E7 440800            MOVE              X0,X:<DTXS_WD2          ; echo command sent
837       P:0001E6 P:0001E8 44F400            MOVE              #'ACK',X0
                            41434B
838       P:0001E8 P:0001EA 440900            MOVE              X0,X:<DTXS_WD3          ; ACKnowledge okay
839       P:0001E9 P:0001EB 44F400            MOVE              #'000',X0
                            303030
840       P:0001EB P:0001ED 440A00            MOVE              X0,X:<DTXS_WD4          ; no error
841       P:0001EC P:0001EE 0D03C6            JSR     <PCI_MESSAGE_TO_HOST
842       P:0001ED P:0001EF 0C0162            JMP     <PACKET_IN
843    
844                                 HST_ERR_REP
845       P:0001EE P:0001F0 44F400            MOVE              #'REP',X0
                            524550
846       P:0001F0 P:0001F2 440700            MOVE              X0,X:<DTXS_WD1          ; REPly
847       P:0001F1 P:0001F3 44F400            MOVE              #'HST',X0
                            485354
848       P:0001F3 P:0001F5 440800            MOVE              X0,X:<DTXS_WD2          ; echo command sent
849       P:0001F4 P:0001F6 44F400            MOVE              #'ERR',X0
                            455252
850       P:0001F6 P:0001F8 440900            MOVE              X0,X:<DTXS_WD3          ; ACKnowledge okay
851       P:0001F7 P:0001F9 44F400            MOVE              #'HFE',X0
                            484645
852       P:0001F9 P:0001FB 440A00            MOVE              X0,X:<DTXS_WD4          ; HF error
853       P:0001FA P:0001FC 0D03C6            JSR     <PCI_MESSAGE_TO_HOST
854       P:0001FB P:0001FD 0C0162            JMP     <PACKET_IN                        ; return to service timing board fibre
855    
856    
857    
858    
859                                 ; ****************************************************************************************
860                                 ; ************************************ INTERRUPT ROUTINES ********************************
861                                 ; *****************************************************************************************
862    
863                                 ; ISR routines defined here
864                                 ; place holders only in place so we can build the code
865    
866                                 ; Clean up the PCI board from wherever it was executing
867                                 CLEAN_UP_PCI
868       P:0001FC P:0001FE 08F4BF            MOVEP             #$0001C0,X:IPRC         ; Disable HF* FIFO interrupt
                            0001C0
869       P:0001FE P:000200 05F439            MOVE              #$200,SR                ; mask for reset interrupts only
                            000200
870    
871       P:000200 P:000202 0501BB            MOVEC             #1,SP                   ; Point stack pointer to the top
872       P:000201 P:000203 05F43D            MOVEC             #$000200,SSL            ; SR = zero except for interrupts
                            000200
873       P:000203 P:000205 0500BB            MOVEC             #0,SP                   ; Writing to SSH preincrements the SP
874       P:000204 P:000206 05F43C            MOVEC             #START,SSH              ; Set PC to for full initialization
                            000100
875       P:000206 P:000208 000000            NOP
Motorola DSP56300 Assembler  Version 6.3.4   04-11-29  14:14:18  PCI_SCUBA_main.asm  Page 18



876       P:000207 P:000209 000004            RTI
877                                 ; ---------------------------------------------------------------------------
878    
879                                 WRITE_MEMORY
880                                 ; word 1 = command = 'WRM'
881                                 ; word 2 = memory type, P=$00'_P', X=$00'_X' or Y=$00'_Y'
882                                 ; word 3 = address in memory
883                                 ; word 4 = value
884       P:000208 P:00020A 0D03B9            JSR     <RD_DRXR                          ; read words from host write to HTXR
885       P:000209 P:00020B 56F000            MOVE              X:DRXR_WD1,A            ; read command
                            000003
886       P:00020B P:00020D 44F400            MOVE              #'WRM',X0
                            57524D
887       P:00020D P:00020F 200045            CMP     X0,A                              ; ensure command is 'WRM'
888       P:00020E P:000210 0E2230            JNE     <WRITE_MEMORY_ERROR               ; error, command NOT HCVR address
889       P:00020F P:000211 568400            MOVE              X:<DRXR_WD2,A           ; Memory type (X, Y, P)
890       P:000210 P:000212 578500            MOVE              X:<DRXR_WD3,B
891       P:000211 P:000213 000000            NOP                                       ; pipeline restriction
892       P:000212 P:000214 21B000            MOVE              B1,R0                   ; get address to write to
893       P:000213 P:000215 448600            MOVE              X:<DRXR_WD4,X0          ; get data to write
894       P:000214 P:000216 0140C5            CMP     #$005F50,A                        ; $00'_P'
                            005F50
895       P:000216 P:000218 0E2219            JNE     <WRX
896       P:000217 P:000219 076084            MOVE              X0,P:(R0)               ; Write to Program memory
897       P:000218 P:00021A 0C0222            JMP     <FINISH_WRITE_MEMORY
898                                 WRX
899       P:000219 P:00021B 0140C5            CMP     #$005F58,A                        ; $00'_X'
                            005F58
900       P:00021B P:00021D 0E221E            JNE     <WRY
901       P:00021C P:00021E 446000            MOVE              X0,X:(R0)               ; Write to X: memory
902       P:00021D P:00021F 0C0222            JMP     <FINISH_WRITE_MEMORY
903                                 WRY
904       P:00021E P:000220 0140C5            CMP     #$005F59,A                        ; $00'_Y'
                            005F59
905       P:000220 P:000222 0E2230            JNE     <WRITE_MEMORY_ERROR
906       P:000221 P:000223 4C6000            MOVE                          X0,Y:(R0)   ; Write to Y: memory
907    
908                                 ; when completed successfully then PCI needs to reply to Host with
909                                 ; word1 = reply/data = reply
910                                 FINISH_WRITE_MEMORY
911       P:000222 P:000224 44F400            MOVE              #'REP',X0
                            524550
912       P:000224 P:000226 440700            MOVE              X0,X:<DTXS_WD1          ; REPly
913       P:000225 P:000227 44F400            MOVE              #'WRM',X0
                            57524D
914       P:000227 P:000229 440800            MOVE              X0,X:<DTXS_WD2          ; echo command sent
915       P:000228 P:00022A 44F400            MOVE              #'ACK',X0
                            41434B
916       P:00022A P:00022C 440900            MOVE              X0,X:<DTXS_WD3          ; ACKnowledge okay
917       P:00022B P:00022D 44F400            MOVE              #'000',X0
                            303030
918       P:00022D P:00022F 440A00            MOVE              X0,X:<DTXS_WD4          ; no error
919       P:00022E P:000230 0D03C6            JSR     <PCI_MESSAGE_TO_HOST
920       P:00022F P:000231 0C023D            JMP     <END_WRITE_MEMORY
921    
922                                 ; when there is a failure in the host to PCI command then the PCI
923                                 ; needs still to reply to Host but with an error message
924                                 WRITE_MEMORY_ERROR
925       P:000230 P:000232 44F400            MOVE              #'REP',X0
                            524550
926       P:000232 P:000234 440700            MOVE              X0,X:<DTXS_WD1          ; REPly
927       P:000233 P:000235 44F400            MOVE              #'WRM',X0
Motorola DSP56300 Assembler  Version 6.3.4   04-11-29  14:14:18  PCI_SCUBA_main.asm  Page 19



                            57524D
928       P:000235 P:000237 440800            MOVE              X0,X:<DTXS_WD2          ; echo command sent
929       P:000236 P:000238 44F400            MOVE              #'ERR',X0
                            455252
930       P:000238 P:00023A 440900            MOVE              X0,X:<DTXS_WD3          ; ERRor im command
931       P:000239 P:00023B 44F400            MOVE              #'001',X0
                            303031
932       P:00023B P:00023D 440A00            MOVE              X0,X:<DTXS_WD4          ; write to PCI memory error
933       P:00023C P:00023E 0D03C6            JSR     <PCI_MESSAGE_TO_HOST
934                                 END_WRITE_MEMORY
935       P:00023D P:00023F 000004            RTI
936    
937                                 ; ------------------------------------------------------------------------
938                                 READ_MEMORY
939                                 ; word 1 = command = 'RDM'
940                                 ; word 2 = memory type, P=$00'_P', X=$00_'X' or Y=$00_'Y'
941                                 ; word 3 = address in memory
942                                 ; word 4 = not used
943       P:00023E P:000240 0D03B9            JSR     <RD_DRXR                          ; read words from host write to HTXR
944       P:00023F P:000241 56F000            MOVE              X:DRXR_WD1,A            ; read command
                            000003
945       P:000241 P:000243 44F400            MOVE              #'RDM',X0
                            52444D
946       P:000243 P:000245 200045            CMP     X0,A                              ; ensure command is 'RDM'
947       P:000244 P:000246 0E2268            JNE     <READ_MEMORY_ERROR                ; error, command NOT HCVR address
948       P:000245 P:000247 568400            MOVE              X:<DRXR_WD2,A           ; Memory type (X, Y, P)
949       P:000246 P:000248 578500            MOVE              X:<DRXR_WD3,B
950       P:000247 P:000249 000000            NOP                                       ; pipeline restriction
951       P:000248 P:00024A 21B000            MOVE              B1,R0                   ; get address to write to
952       P:000249 P:00024B 448600            MOVE              X:<DRXR_WD4,X0          ; get data to write
953       P:00024A P:00024C 0140C5            CMP     #$005F50,A                        ; $00'_P'
                            005F50
954       P:00024C P:00024E 0E2250            JNE     <RDX
955       P:00024D P:00024F 07E084            MOVE              P:(R0),X0               ; Read from P memory
956       P:00024E P:000250 208E00            MOVE              X0,A                    ;
957       P:00024F P:000251 0C025B            JMP     <FINISH_READ_MEMORY
958                                 RDX
959       P:000250 P:000252 0140C5            CMP     #$005F58,A                        ; $00'_X'
                            005F58
960       P:000252 P:000254 0E2256            JNE     <RDY
961       P:000253 P:000255 44E000            MOVE              X:(R0),X0               ; Read from P memory
962       P:000254 P:000256 208E00            MOVE              X0,A
963       P:000255 P:000257 0C025B            JMP     <FINISH_READ_MEMORY
964                                 RDY
965       P:000256 P:000258 0140C5            CMP     #$005F59,A                        ; $00'_Y'
                            005F59
966       P:000258 P:00025A 0E2268            JNE     <READ_MEMORY_ERROR
967       P:000259 P:00025B 4CE000            MOVE                          Y:(R0),X0   ; Read from P memory
968       P:00025A P:00025C 208E00            MOVE              X0,A
969    
970                                 ; when completed successfully then PCI needs to reply to Host with
971                                 ; word1 = reply/data = reply
972                                 FINISH_READ_MEMORY
973       P:00025B P:00025D 44F400            MOVE              #'REP',X0
                            524550
974       P:00025D P:00025F 440700            MOVE              X0,X:<DTXS_WD1          ; REPly
975       P:00025E P:000260 44F400            MOVE              #'RDM',X0
                            52444D
976       P:000260 P:000262 440800            MOVE              X0,X:<DTXS_WD2          ; echo command sent
977       P:000261 P:000263 44F400            MOVE              #'ACK',X0
                            41434B
978       P:000263 P:000265 440900            MOVE              X0,X:<DTXS_WD3          ;  im command
Motorola DSP56300 Assembler  Version 6.3.4   04-11-29  14:14:18  PCI_SCUBA_main.asm  Page 20



979       P:000264 P:000266 21C400            MOVE              A,X0
980       P:000265 P:000267 440A00            MOVE              X0,X:<DTXS_WD4          ; write to PCI memory error
981       P:000266 P:000268 0D03C6            JSR     <PCI_MESSAGE_TO_HOST
982       P:000267 P:000269 0C0275            JMP     <END_READ_MEMORY
983    
984                                 ; when there is a failure in the host to PCI command then the PCI
985                                 ; needs still to reply to Host but with an error message
986                                 READ_MEMORY_ERROR
987       P:000268 P:00026A 44F400            MOVE              #'REP',X0
                            524550
988       P:00026A P:00026C 440700            MOVE              X0,X:<DTXS_WD1          ; REPly
989       P:00026B P:00026D 44F400            MOVE              #'RDM',X0
                            52444D
990       P:00026D P:00026F 440800            MOVE              X0,X:<DTXS_WD2          ; echo command sent
991       P:00026E P:000270 44F400            MOVE              #'ERR',X0
                            455252
992       P:000270 P:000272 440900            MOVE              X0,X:<DTXS_WD3          ; ERRor im command
993       P:000271 P:000273 44F400            MOVE              #'001',X0
                            303031
994       P:000273 P:000275 440A00            MOVE              X0,X:<DTXS_WD4          ; write to PCI memory error
995       P:000274 P:000276 0D03C6            JSR     <PCI_MESSAGE_TO_HOST
996                                 END_READ_MEMORY
997       P:000275 P:000277 000004            RTI
998    
999    
1000                                ; ----------------------------------------------------------------------
1001                                ; an application should already have been downloaded to the PCI memory
1002                                ; before this command is called - this command compares the
1003                                ; application name against the name in the GO command - if not the same
1004                                ; then error else switch on a flag to tell the boot code to start the application
1005   
1006                                START_APPLICATION
1007                                ; word 1 = command = 'GOA'
1008                                ; word 2 = application number or name
1009                                ; word 3 = not used but read
1010                                ; word 4 = not used but read
1011      P:000276 P:000278 0D03B9            JSR     <RD_DRXR                          ; read words from host write to HTXR
1012      P:000277 P:000279 568300            MOVE              X:<DRXR_WD1,A           ; read command
1013      P:000278 P:00027A 44F400            MOVE              #'GOA',X0
                            474F41
1014      P:00027A P:00027C 200045            CMP     X0,A                              ; ensure command is 'RDM'
1015      P:00027B P:00027D 0E228E            JNE     <GO_ERROR                         ; error, command NOT HCVR address
1016      P:00027C P:00027E 448400            MOVE              X:<DRXR_WD2,X0          ; APPLICATION NUMBER/NAME
1017      P:00027D P:00027F 568500            MOVE              X:<DRXR_WD3,A           ; read word 3 - not used
1018      P:00027E P:000280 578600            MOVE              X:<DRXR_WD4,B           ; read word 4 - not used
1019                                ; if we get here then everything is fine and we can start the application
1020                                ; but first we must reply to the host that everyting is fine and then
1021                                ;start the application
1022   
1023                                ; when completed successfully then PCI needs to reply to Host with
1024                                ; word1 = reply/data = reply
1025                                FINISH_GO
1026      P:00027F P:000281 44F400            MOVE              #'REP',X0
                            524550
1027      P:000281 P:000283 440700            MOVE              X0,X:<DTXS_WD1          ; REPly
1028      P:000282 P:000284 44F400            MOVE              #'GOA',X0
                            474F41
1029      P:000284 P:000286 440800            MOVE              X0,X:<DTXS_WD2          ; echo command sent
1030      P:000285 P:000287 44F400            MOVE              #'ACK',X0
                            41434B
1031      P:000287 P:000289 440900            MOVE              X0,X:<DTXS_WD3          ; ACKnowledge okay
1032      P:000288 P:00028A 44F400            MOVE              #'000',X0
Motorola DSP56300 Assembler  Version 6.3.4   04-11-29  14:14:18  PCI_SCUBA_main.asm  Page 21



                            303030
1033      P:00028A P:00028C 440A00            MOVE              X0,X:<DTXS_WD4          ; read data
1034      P:00028B P:00028D 0D03C6            JSR     <PCI_MESSAGE_TO_HOST
1035   
1036                                ; remember we are in an ISR so we just can't jump to any old code since
1037                                ; we must return from the ISR properly - thereofre we switched on a flag
1038                                ; in a STATUS word which tells the boot code that it has an application loaded
1039                                ; which it must now run
1040      P:00028C P:00028E 0A0020            BSET    #APPLICATION_LOADED,X:<STATUS
1041      P:00028D P:00028F 0C029C            JMP     <END_GO
1042   
1043                                ; when there is a failure in the host to PCI command then the PCI
1044                                ; needs still to reply to Host but with an error message
1045                                GO_ERROR
1046      P:00028E P:000290 44F400            MOVE              #'REP',X0
                            524550
1047      P:000290 P:000292 440700            MOVE              X0,X:<DTXS_WD1          ; REPly
1048      P:000291 P:000293 44F400            MOVE              #'GOA',X0
                            474F41
1049      P:000293 P:000295 440800            MOVE              X0,X:<DTXS_WD2          ; echo command sent
1050      P:000294 P:000296 44F400            MOVE              #'ERR',X0
                            455252
1051      P:000296 P:000298 440900            MOVE              X0,X:<DTXS_WD3          ; ERRor im command
1052      P:000297 P:000299 44F400            MOVE              #'003',X0
                            303033
1053      P:000299 P:00029B 440A00            MOVE              X0,X:<DTXS_WD4          ; write to PCI memory error
1054      P:00029A P:00029C 0D03C6            JSR     <PCI_MESSAGE_TO_HOST
1055                                ; failure so ensure that no application is started
1056      P:00029B P:00029D 0A0000            BCLR    #APPLICATION_LOADED,X:<STATUS
1057                                END_GO
1058      P:00029C P:00029E 000004            RTI
1059   
1060                                ; ---------------------------------------------------------
1061                                ; this command stops an application that is already running
1062                                STOP_APPLICATION
1063                                ; word 1 = command = ' STP'
1064                                ; word 2 = application number or name
1065                                ; word 3 = not used but read
1066                                ; word 4 = not used but read
1067      P:00029D P:00029F 0D03B9            JSR     <RD_DRXR                          ; read words from host write to HTXR
1068      P:00029E P:0002A0 568300            MOVE              X:<DRXR_WD1,A           ; read command
1069      P:00029F P:0002A1 44F400            MOVE              #'STP',X0
                            535450
1070      P:0002A1 P:0002A3 200045            CMP     X0,A                              ; ensure command is 'RDM'
1071      P:0002A2 P:0002A4 0E22B5            JNE     <STP_ERROR                        ; error, command NOT HCVR address
1072      P:0002A3 P:0002A5 448400            MOVE              X:<DRXR_WD2,X0          ; APPLICATION NUMBER/NAME
1073      P:0002A4 P:0002A6 568500            MOVE              X:<DRXR_WD3,A           ; read word 3 - not used
1074      P:0002A5 P:0002A7 578600            MOVE              X:<DRXR_WD4,B           ; read word 4 - not used
1075                                ; if we get here then everything is fine and we can start the application
1076                                ; but first we must reply to the host that everyting is fine and then
1077                                ;start the application
1078   
1079                                ; when completed successfully then PCI needs to reply to Host with
1080                                ; word1 = reply/data = reply
1081                                FINISH_STP
1082      P:0002A6 P:0002A8 44F400            MOVE              #'REP',X0
                            524550
1083      P:0002A8 P:0002AA 440700            MOVE              X0,X:<DTXS_WD1          ; REPly
1084      P:0002A9 P:0002AB 44F400            MOVE              #'STP',X0
                            535450
1085      P:0002AB P:0002AD 440800            MOVE              X0,X:<DTXS_WD2          ; echo command sent
1086      P:0002AC P:0002AE 44F400            MOVE              #'ACK',X0
Motorola DSP56300 Assembler  Version 6.3.4   04-11-29  14:14:18  PCI_SCUBA_main.asm  Page 22



                            41434B
1087      P:0002AE P:0002B0 440900            MOVE              X0,X:<DTXS_WD3          ; ACKnowledge okay
1088      P:0002AF P:0002B1 44F400            MOVE              #'000',X0
                            303030
1089      P:0002B1 P:0002B3 440A00            MOVE              X0,X:<DTXS_WD4          ; read data
1090      P:0002B2 P:0002B4 0D03C6            JSR     <PCI_MESSAGE_TO_HOST
1091   
1092                                ; remember we are in an ISR so we just can't jump to any old code since
1093                                ; we must return from the ISR properly - therefore we switch the flag
1094                                ; off to tell the bootcode that no application is loaded
1095      P:0002B3 P:0002B5 0A0000            BCLR    #APPLICATION_LOADED,X:<STATUS
1096      P:0002B4 P:0002B6 0C02C4            JMP     <END_STP
1097   
1098                                ; when there is a failure in the host to PCI command then the PCI
1099                                ; needs still to reply to Host but with an error message
1100                                STP_ERROR
1101      P:0002B5 P:0002B7 44F400            MOVE              #'REP',X0
                            524550
1102      P:0002B7 P:0002B9 440700            MOVE              X0,X:<DTXS_WD1          ; REPly
1103      P:0002B8 P:0002BA 44F400            MOVE              #'STP',X0
                            535450
1104      P:0002BA P:0002BC 440800            MOVE              X0,X:<DTXS_WD2          ; echo command sent
1105      P:0002BB P:0002BD 44F400            MOVE              #'ERR',X0
                            455252
1106      P:0002BD P:0002BF 440900            MOVE              X0,X:<DTXS_WD3          ; ERRor im command
1107      P:0002BE P:0002C0 44F400            MOVE              #'004',X0
                            303034
1108      P:0002C0 P:0002C2 440A00            MOVE              X0,X:<DTXS_WD4          ; write to PCI memory error
1109      P:0002C1 P:0002C3 0D03C6            JSR     <PCI_MESSAGE_TO_HOST
1110                                ; failure so ensure that application continues to run.
1111      P:0002C2 P:0002C4 0A7020            BSET    #APPLICATION_LOADED,X:STATUS
                            000000
1112                                END_STP
1113      P:0002C4 P:0002C6 000004            RTI
1114   
1115                                ; -------------------------------------------------------------------
1116                                ; nothing defined at present - just checks command and the replies
1117                                ; with ACKnowledge or ERRor
1118                                ; will modify later to do a nice cleanup and program start
1119                                SOFTWARE_RESET
1120                                ; word 1 = command = 'RST'
1121                                ; word 2 = not used but read
1122                                ; word 3 = not used but read
1123                                ; word 4 = not used but read
1124      P:0002C5 P:0002C7 0D03B9            JSR     <RD_DRXR                          ; read words from host write to HTXR
1125      P:0002C6 P:0002C8 568300            MOVE              X:<DRXR_WD1,A           ; read command
1126      P:0002C7 P:0002C9 44F400            MOVE              #'RST',X0
                            525354
1127      P:0002C9 P:0002CB 200045            CMP     X0,A                              ; ensure command is 'RST'
1128      P:0002CA P:0002CC 0E22EB            JNE     <RST_ERROR                        ; error, command NOT HCVR address
1129      P:0002CB P:0002CD 448400            MOVE              X:<DRXR_WD2,X0          ; read but not used
1130      P:0002CC P:0002CE 568500            MOVE              X:<DRXR_WD3,A           ; read word 3 - not used
1131      P:0002CD P:0002CF 578600            MOVE              X:<DRXR_WD4,B           ; read word 4 - not used
1132                                ; if we get here then everything is fine and we can start the application
1133                                ; but first we must reply to the host that everyting is fine and then
1134                                ;start the application
1135   
1136                                ; when completed successfully then PCI needs to reply to Host with
1137                                ; word1 = reply/data = reply
1138                                FINISH_RST
1139      P:0002CE P:0002D0 44F400            MOVE              #'REP',X0
                            524550
Motorola DSP56300 Assembler  Version 6.3.4   04-11-29  14:14:18  PCI_SCUBA_main.asm  Page 23



1140      P:0002D0 P:0002D2 440700            MOVE              X0,X:<DTXS_WD1          ; REPly
1141      P:0002D1 P:0002D3 44F400            MOVE              #'RST',X0
                            525354
1142      P:0002D3 P:0002D5 440800            MOVE              X0,X:<DTXS_WD2          ; echo command sent
1143      P:0002D4 P:0002D6 44F400            MOVE              #'ACK',X0
                            41434B
1144      P:0002D6 P:0002D8 440900            MOVE              X0,X:<DTXS_WD3          ; ACKnowledge okay
1145      P:0002D7 P:0002D9 44F400            MOVE              #'000',X0
                            303030
1146      P:0002D9 P:0002DB 440A00            MOVE              X0,X:<DTXS_WD4          ; read data
1147      P:0002DA P:0002DC 0D03C6            JSR     <PCI_MESSAGE_TO_HOST
1148   
1149      P:0002DB P:0002DD 0A00A4            JSET    #INTA_FLAG,X:<STATUS,*            ; wait for host to process
                            0002DB
1150   
1151      P:0002DD P:0002DF 0A0000            BCLR    #APPLICATION_LOADED,X:<STATUS     ; clear app flag
1152      P:0002DE P:0002E0 0A0006            BCLR    #PREAMBLE_ERROR,X:<STATUS         ; clear preamble error
1153   
1154                                ; remember we are in a ISR so can't just jump to start.
1155   
1156      P:0002DF P:0002E1 08F4BF            MOVEP             #$0001C0,X:IPRC         ; Disable HF* FIFO interrupt
                            0001C0
1157      P:0002E1 P:0002E3 05F439            MOVE              #$200,SR                ; Mask set up for reset switch only.
                            000200
1158   
1159   
1160      P:0002E3 P:0002E5 0501BB            MOVEC             #1,SP                   ; Point stack pointer to the top
1161      P:0002E4 P:0002E6 05F43D            MOVEC             #$000200,SSL            ; SSL holds SR return state
                            000200
1162                                                                                    ; set to zero except for interrupts
1163      P:0002E6 P:0002E8 0500BB            MOVEC             #0,SP                   ; Writing to SSH preincrements the SP
1164                                                                                    ; so first set to 0
1165      P:0002E7 P:0002E9 05F43C            MOVEC             #START,SSH              ; SSH holds return address of PC
                            000100
1166                                                                                    ; therefore,return to initialization
1167      P:0002E9 P:0002EB 000000            NOP
1168   
1169   
1170      P:0002EA P:0002EC 0C02F9            JMP     <END_RST
1171   
1172                                ; when there is a failure in the host to PCI command then the PCI
1173                                ; needs still to reply to Host but with an error message
1174                                RST_ERROR
1175      P:0002EB P:0002ED 44F400            MOVE              #'REP',X0
                            524550
1176      P:0002ED P:0002EF 440700            MOVE              X0,X:<DTXS_WD1          ; REPly
1177      P:0002EE P:0002F0 44F400            MOVE              #'RST',X0
                            525354
1178      P:0002F0 P:0002F2 440800            MOVE              X0,X:<DTXS_WD2          ; echo command sent
1179      P:0002F1 P:0002F3 44F400            MOVE              #'ERR',X0
                            455252
1180      P:0002F3 P:0002F5 440900            MOVE              X0,X:<DTXS_WD3          ; ERRor im command
1181      P:0002F4 P:0002F6 44F400            MOVE              #'005',X0
                            303035
1182      P:0002F6 P:0002F8 440A00            MOVE              X0,X:<DTXS_WD4          ; write to PCI memory error
1183      P:0002F7 P:0002F9 0D03C6            JSR     <PCI_MESSAGE_TO_HOST
1184                                ; failure so ensure that application continues to run.
1185      P:0002F8 P:0002FA 0A0020            BSET    #APPLICATION_LOADED,X:<STATUS
1186                                END_RST
1187      P:0002F9 P:0002FB 000004            RTI
1188   
1189                                ; ---------------------------------------------------------------
Motorola DSP56300 Assembler  Version 6.3.4   04-11-29  14:14:18  PCI_SCUBA_main.asm  Page 24



1190   
1191                                ; forward packet stuff to the MCE
1192                                ; gets address in HOST memory where packet is stored
1193                                ; read 3 consecutive locations starting at this address
1194                                ; then sends the data from these locations up to the MCE
1195                                SEND_PACKET_TO_CONTROLLER
1196   
1197                                ; word 1 = command = 'CON'
1198                                ; word 2 = host high address
1199                                ; word 3 = host low address
1200                                ; word 4 = '0' --> normal command
1201                                ;        = '1' --> 'block command'
1202                                ; all MCE commands are now 'block commands'
1203                                ; i.e. 64 words long.
1204   
1205   
1206      P:0002FA P:0002FC 0D03B9            JSR     <RD_DRXR                          ; read words from host write to HTXR
1207                                                                                    ; reads as 4 x 24 bit words
1208   
1209      P:0002FB P:0002FD 568300            MOVE              X:<DRXR_WD1,A           ; read command
1210      P:0002FC P:0002FE 44F400            MOVE              #'CON',X0
                            434F4E
1211      P:0002FE P:000300 200045            CMP     X0,A                              ; ensure command is 'CON'
1212      P:0002FF P:000301 0E2345            JNE     <CON_ERROR                        ; error, command NOT HCVR address
1213   
1214                                ; convert 2 x 24 bit words ( only 16 LSBs are significant) from host into 32 bit address
1215      P:000300 P:000302 20001B            CLR     B
1216      P:000301 P:000303 448400            MOVE              X:<DRXR_WD2,X0          ; MS 16bits of address
1217      P:000302 P:000304 518500            MOVE              X:<DRXR_WD3,B0          ; LS 16bits of address
1218      P:000303 P:000305 0C1941            INSERT  #$010010,X0,B                     ; convert to 32 bits and put in B
                            010010
1219   
1220      P:000305 P:000307 568600            MOVE              X:<DRXR_WD4,A           ; read word 4 - block command?
1221      P:000306 P:000308 44F000            MOVE              X:ZERO,X0
                            000031
1222      P:000308 P:00030A 200045            CMP     X0,A
1223      P:000309 P:00030B 0AF0A2            JNE     BLOCK_CON
                            000330
1224   
1225   
1226                                ; PCI address incremented in Sub routine
1227                                ; get 32bit word as 2 x 16 bit words
1228   
1229                                ; preamble
1230      P:00030B P:00030D 0D03DF            JSR     <READ_FROM_PCI                    ; get a 32 bit word from HOST
1231      P:00030C P:00030E 440B00            MOVE              X0,X:<PCI_WD1_1         ; read word 1 from host memory
1232      P:00030D P:00030F 450C00            MOVE              X1,X:<PCI_WD1_2
1233                                ; preamble
1234      P:00030E P:000310 0D03DF            JSR     <READ_FROM_PCI                    ; get a 32 bit word from HOST
1235      P:00030F P:000311 440D00            MOVE              X0,X:<PCI_WD2_1         ; read word 2 from host memory
1236      P:000310 P:000312 450E00            MOVE              X1,X:<PCI_WD2_2
1237                                ; command
1238      P:000311 P:000313 0D03DF            JSR     <READ_FROM_PCI                    ; get a 32 bit word from HOST
1239      P:000312 P:000314 440F00            MOVE              X0,X:<PCI_WD3_1         ; read word 3 from host memory
1240      P:000313 P:000315 451000            MOVE              X1,X:<PCI_WD3_2
1241                                ;arg1
1242      P:000314 P:000316 0D03DF            JSR     <READ_FROM_PCI                    ; get a 32 bit word from HOST
1243      P:000315 P:000317 441100            MOVE              X0,X:<PCI_WD4_1         ; read word 4 from host memory
1244      P:000316 P:000318 451200            MOVE              X1,X:<PCI_WD4_2
1245                                ;arg2
1246      P:000317 P:000319 0D03DF            JSR     <READ_FROM_PCI                    ; get a 32 bit word from HOST
1247      P:000318 P:00031A 441300            MOVE              X0,X:<PCI_WD5_1         ; read word 5 from host memory
Motorola DSP56300 Assembler  Version 6.3.4   04-11-29  14:14:18  PCI_SCUBA_main.asm  Page 25



1248      P:000319 P:00031B 451400            MOVE              X1,X:<PCI_WD5_2
1249                                ;checksum
1250      P:00031A P:00031C 0D03DF            JSR     <READ_FROM_PCI                    ; get a 32 bit word from HOST
1251      P:00031B P:00031D 441500            MOVE              X0,X:<PCI_WD6_1         ; read word 6 from host memory
1252      P:00031C P:00031E 451600            MOVE              X1,X:<PCI_WD6_2
1253   
1254   
1255                                ; when we reach this stage then we have successfully read a 3 word packet from
1256                                ; the host which has to be send onwards to the Timing board
1257                                ; the routine which transmits to the fibre expects the word to be in register A1
1258   
1259                                ; preamble
1260      P:00031D P:00031F 548B00            MOVE              X:<PCI_WD1_1,A1         ; put 1st word (1) in A1 to transmit
1261      P:00031E P:000320 508C00            MOVE              X:<PCI_WD1_2,A0         ; put 1st word (2) in A1 to transmit
1262      P:00031F P:000321 0D04F5            JSR     <XMT_WD_FIBRE                     ; off it goes
1263                                ;preamble
1264      P:000320 P:000322 548D00            MOVE              X:<PCI_WD2_1,A1         ; put 2nd word (1) in A1 to transmit
1265      P:000321 P:000323 508E00            MOVE              X:<PCI_WD2_2,A0         ; put 2nd word (2) in A1 to transmit
1266      P:000322 P:000324 0D04F5            JSR     <XMT_WD_FIBRE                     ; off it goes
1267                                ; command
1268      P:000323 P:000325 548F00            MOVE              X:<PCI_WD3_1,A1         ; put 3rd word (1) in A1 to transmit
1269      P:000324 P:000326 509000            MOVE              X:<PCI_WD3_2,A0         ; put 3rd word (2) in A1 to transmit
1270      P:000325 P:000327 0D04F5            JSR     <XMT_WD_FIBRE                     ; off it goes
1271                                ; arg1
1272      P:000326 P:000328 549100            MOVE              X:<PCI_WD4_1,A1         ; put 4th word (1) in A1 to transmit
1273      P:000327 P:000329 509200            MOVE              X:<PCI_WD4_2,A0         ; put 4th word (2)in A1 to transmit
1274      P:000328 P:00032A 0D04F5            JSR     <XMT_WD_FIBRE                     ; off it goes
1275                                ; arg2
1276      P:000329 P:00032B 549300            MOVE              X:<PCI_WD5_1,A1         ; put 5th word (1) in A1 to transmit
1277      P:00032A P:00032C 509400            MOVE              X:<PCI_WD5_2,A0         ; put 5th word (2) in A1 to transmit
1278      P:00032B P:00032D 0D04F5            JSR     <XMT_WD_FIBRE                     ; off it goes
1279                                ; check sum
1280      P:00032C P:00032E 549500            MOVE              X:<PCI_WD6_1,A1         ; put 6th word (1) in A1 to transmit
1281      P:00032D P:00032F 509600            MOVE              X:<PCI_WD6_2,A0         ; put 6th word (2) in A1 to transmit
1282      P:00032E P:000330 0D04F5            JSR     <XMT_WD_FIBRE                     ; off it goes
1283      P:00032F P:000331 0C0337            JMP     <FINISH_CON                       ; finished
1284   
1285                                BLOCK_CON
1286      P:000330 P:000332 064080            DO      #64,END_BLOCK_CON                 ; block size = 32bit x 64 (256 bytes)
                            000336
1287      P:000332 P:000334 0D03DF            JSR     <READ_FROM_PCI                    ; get next 32 bit word from HOST
1288      P:000333 P:000335 208C00            MOVE              X0,A1                   ; prepare to send
1289      P:000334 P:000336 20A800            MOVE              X1,A0                   ; prepare to send
1290      P:000335 P:000337 0D04F5            JSR     <XMT_WD_FIBRE                     ; off it goes
1291      P:000336 P:000338 000000            NOP
1292                                END_BLOCK_CON
1293   
1294                                ; --------------- this might work for a DMA block burst read ----------------
1295   
1296                                ; DMA block CON
1297                                ; note maximum block size is 64 (burst limit - since six bits in DPMC define length)
1298   
1299                                ;BLOCK_CON
1300                                ; set up clock size in x0, address in B
1301   
1302                                ;       MOVE    X:WBLK_SIZE,X0
1303                                ;       JSR     <READ_WBLOCK            ; DMA read block --> Y memory
1304   
1305                                ;XMT_WBLOCK                             ; send to BAC
1306                                ;       MOVE    X:ZERO,R3
1307                                ;       MOVE    X:WBLK_SIZE,X0          ;
1308                                ;       DO      X0,END_XMT_WBLOCK       ; block size in X0
Motorola DSP56300 Assembler  Version 6.3.4   04-11-29  14:14:18  PCI_SCUBA_main.asm  Page 26



1309                                ;       MOVE    Y:(R3)+,A1              ; get word MS16
1310                                ;       MOVE    Y:(R3)+,A0              ; get word LS16
1311                                ;       JSR     <XMT_WD_FIBRE           ; ...off it goes
1312                                ;       NOP
1313                                ;END_XMT_WBLOCK
1314                                ;       NOP
1315                                ;END_BLOCK_CON
1316   
1317                                ; -------------------------------------------------------------------------
1318   
1319                                ; when completed successfully then PCI needs to reply to Host with
1320                                ; word1 = reply/data = reply
1321                                FINISH_CON
1322      P:000337 P:000339 44F400            MOVE              #'REP',X0
                            524550
1323      P:000339 P:00033B 440700            MOVE              X0,X:<DTXS_WD1          ; REPly
1324      P:00033A P:00033C 44F400            MOVE              #'CON',X0
                            434F4E
1325      P:00033C P:00033E 440800            MOVE              X0,X:<DTXS_WD2          ; echo command sent
1326      P:00033D P:00033F 44F400            MOVE              #'ACK',X0
                            41434B
1327      P:00033F P:000341 440900            MOVE              X0,X:<DTXS_WD3          ; ACKnowledge okay
1328      P:000340 P:000342 44F400            MOVE              #'000',X0
                            303030
1329      P:000342 P:000344 440A00            MOVE              X0,X:<DTXS_WD4          ; read data
1330      P:000343 P:000345 0D03C6            JSR     <PCI_MESSAGE_TO_HOST
1331      P:000344 P:000346 0C0352            JMP     <END_CON
1332   
1333                                ; when there is a failure in the host to PCI command then the PCI
1334                                ; needs still to reply to Host but with an error message
1335                                CON_ERROR
1336      P:000345 P:000347 44F400            MOVE              #'REP',X0
                            524550
1337      P:000347 P:000349 440700            MOVE              X0,X:<DTXS_WD1          ; REPly
1338      P:000348 P:00034A 44F400            MOVE              #'CON',X0
                            434F4E
1339      P:00034A P:00034C 440800            MOVE              X0,X:<DTXS_WD2          ; echo command sent
1340      P:00034B P:00034D 44F400            MOVE              #'ERR',X0
                            455252
1341      P:00034D P:00034F 440900            MOVE              X0,X:<DTXS_WD3          ; ERRor im command
1342      P:00034E P:000350 44F400            MOVE              #'006',X0
                            303036
1343      P:000350 P:000352 440A00            MOVE              X0,X:<DTXS_WD4          ; write to PCI memory error
1344      P:000351 P:000353 0D03C6            JSR     <PCI_MESSAGE_TO_HOST
1345   
1346                                END_CON
1347   
1348      P:000352 P:000354 000004            RTI
1349   
1350                                ; ------------------------------------------------------------------------------------
1351   
1352                                SEND_PACKET_TO_HOST
1353                                ; this command is received from the Host and actions the PCI board to pick up an address
1354                                ; pointer from DRXR which the PCI board then uses to write packets from the
1355                                ; MCE to the host memory starting at the address given.
1356                                ; Since this is interrupt driven all this piece of code does is get the address pointer from
1357                                ; the host via DRXR, set a flag so that the main prog can write the packet.  Replies to
1358                                ; HST after packet sent (unless error).
1359                                ;
1360                                ; word 1 = command = 'HST'
1361                                ; word 2 = host high address
1362                                ; word 3 = host low address
Motorola DSP56300 Assembler  Version 6.3.4   04-11-29  14:14:18  PCI_SCUBA_main.asm  Page 27



1363                                ; word 4 = not used but read
1364   
1365                                ; store some registers.....
1366   
1367      P:000353 P:000355 053039            MOVEC             SR,X:<SV_SR
1368      P:000354 P:000356 502600            MOVE              A0,X:<SV_A0             ; Save registers used here
1369      P:000355 P:000357 542700            MOVE              A1,X:<SV_A1
1370      P:000356 P:000358 522800            MOVE              A2,X:<SV_A2
1371      P:000357 P:000359 442C00            MOVE              X0,X:<SV_X0
1372   
1373   
1374      P:000358 P:00035A 0D03B9            JSR     <RD_DRXR                          ; read words from host write to HTXR
1375      P:000359 P:00035B 20001B            CLR     B
1376      P:00035A P:00035C 568300            MOVE              X:<DRXR_WD1,A           ; read command
1377      P:00035B P:00035D 44F400            MOVE              #'HST',X0
                            485354
1378      P:00035D P:00035F 200045            CMP     X0,A                              ; ensure command is 'HST'
1379      P:00035E P:000360 0E2366            JNE     <HOST_ERROR                       ; error, command NOT HCVR address
1380      P:00035F P:000361 448400            MOVE              X:<DRXR_WD2,X0          ; high 16 bits of address
1381      P:000360 P:000362 518500            MOVE              X:<DRXR_WD3,B0          ; low 16 bits of adderss
1382      P:000361 P:000363 0C1941            INSERT  #$010010,X0,B                     ; convert to 32 bits and put in B
                            010010
1383      P:000363 P:000365 448600            MOVE              X:<DRXR_WD4,X0          ; dummy
1384   
1385      P:000364 P:000366 0A0021            BSET    #SEND_TO_HOST,X:<STATUS           ; tell main program to start sending packets
1386      P:000365 P:000367 0C0375            JMP     <END_HOST
1387   
1388                                ; !!!!!!!!!!!! the reply is not sent here unless error !!!!!!!
1389                                ; reply to this command is sent after packet has been sucessfully send to host.
1390   
1391   
1392                                ; when there is a failure in the host to PCI command then the PCI
1393                                ; needs still to reply to Host but with an error message
1394                                HOST_ERROR
1395      P:000366 P:000368 0A7001            BCLR    #SEND_TO_HOST,X:STATUS
                            000000
1396      P:000368 P:00036A 44F400            MOVE              #'REP',X0
                            524550
1397      P:00036A P:00036C 440700            MOVE              X0,X:<DTXS_WD1          ; REPly
1398      P:00036B P:00036D 44F400            MOVE              #'HST',X0
                            485354
1399      P:00036D P:00036F 440800            MOVE              X0,X:<DTXS_WD2          ; echo command sent
1400      P:00036E P:000370 44F400            MOVE              #'ERR',X0
                            455252
1401      P:000370 P:000372 440900            MOVE              X0,X:<DTXS_WD3          ; ERRor im command
1402      P:000371 P:000373 44F400            MOVE              #'007',X0
                            303037
1403      P:000373 P:000375 440A00            MOVE              X0,X:<DTXS_WD4          ; write to PCI memory error
1404      P:000374 P:000376 0D03C6            JSR     <PCI_MESSAGE_TO_HOST
1405                                END_HOST
1406   
1407   
1408      P:000375 P:000377 05B039            MOVEC             X:<SV_SR,SR
1409      P:000376 P:000378 50A600            MOVE              X:<SV_A0,A0             ; restore registers used here
1410      P:000377 P:000379 54A700            MOVE              X:<SV_A1,A1
1411      P:000378 P:00037A 52A800            MOVE              X:<SV_A2,A2
1412      P:000379 P:00037B 44AC00            MOVE              X:<SV_X0,X0
1413   
1414      P:00037A P:00037C 000004            RTI
1415                                ; --------------------------------------------------------------------
1416   
1417                                ; Reset the controller by sending a special code byte $0B with SC/nData = 1
Motorola DSP56300 Assembler  Version 6.3.4   04-11-29  14:14:18  PCI_SCUBA_main.asm  Page 28



1418                                RESET_CONTROLLER
1419                                ; word 1 = command = 'RCO'
1420                                ; word 2 = not used but read
1421                                ; word 3 = not used but read
1422                                ; word 4 = not used but read
1423      P:00037B P:00037D 0D03B9            JSR     <RD_DRXR                          ; read words from host write to HTXR
1424      P:00037C P:00037E 568300            MOVE              X:<DRXR_WD1,A           ; read command
1425      P:00037D P:00037F 44F400            MOVE              #'RCO',X0
                            52434F
1426      P:00037F P:000381 200045            CMP     X0,A                              ; ensure command is 'RCO'
1427      P:000380 P:000382 0E23A7            JNE     <RCO_ERROR                        ; error, command NOT HCVR address
1428      P:000381 P:000383 448400            MOVE              X:<DRXR_WD2,X0          ; read but not used
1429      P:000382 P:000384 568500            MOVE              X:<DRXR_WD3,A           ; read word 3 - not used
1430      P:000383 P:000385 578600            MOVE              X:<DRXR_WD4,B           ; read word 4 - not used
1431   
1432                                ; if we get here then everything is fine and we can send reset to controller
1433   
1434                                ; 250MHZ CODE....
1435   
1436      P:000384 P:000386 011D22            BSET    #SCLK,X:PDRE                      ; Enable special command mode
1437      P:000385 P:000387 000000            NOP
1438      P:000386 P:000388 000000            NOP
1439      P:000387 P:000389 60F400            MOVE              #$FFF000,R0             ; Memory mapped address of transmitter
                            FFF000
1440      P:000389 P:00038B 44F400            MOVE              #$10000B,X0             ; Special command to reset controller
                            10000B
1441      P:00038B P:00038D 446000            MOVE              X0,X:(R0)
1442      P:00038C P:00038E 0606A0            REP     #6                                ; Wait for transmission to complete
1443      P:00038D P:00038F 000000            NOP
1444      P:00038E P:000390 011D02            BCLR    #SCLK,X:PDRE                      ; Disable special command mode
1445   
1446                                ; Wait until the timing board is reset, because FO data is invalid
1447      P:00038F P:000391 44F400            MOVE              #10000,X0               ; Delay by about 350 milliseconds
                            002710
1448      P:000391 P:000393 06C400            DO      X0,L_DELAY
                            000397
1449      P:000393 P:000395 06E883            DO      #1000,L_RDFIFO
                            000396
1450      P:000395 P:000397 09463F            MOVEP             Y:RDFIFO,Y0             ; Read the FIFO word to keep the
1451      P:000396 P:000398 000000            NOP                                       ;   receiver empty
1452                                L_RDFIFO
1453      P:000397 P:000399 000000            NOP
1454                                L_DELAY
1455      P:000398 P:00039A 000000            NOP
1456   
1457                                ; when completed successfully then PCI needs to reply to Host with
1458                                ; word1 = reply/data = reply
1459                                FINISH_RCO
1460      P:000399 P:00039B 44F400            MOVE              #'REP',X0
                            524550
1461      P:00039B P:00039D 440700            MOVE              X0,X:<DTXS_WD1          ; REPly
1462      P:00039C P:00039E 44F400            MOVE              #'RCO',X0
                            52434F
1463      P:00039E P:0003A0 440800            MOVE              X0,X:<DTXS_WD2          ; echo command sent
1464      P:00039F P:0003A1 44F400            MOVE              #'ACK',X0
                            41434B
1465      P:0003A1 P:0003A3 440900            MOVE              X0,X:<DTXS_WD3          ; ACKnowledge okay
1466      P:0003A2 P:0003A4 44F400            MOVE              #'000',X0
                            303030
1467      P:0003A4 P:0003A6 440A00            MOVE              X0,X:<DTXS_WD4          ; read data
1468      P:0003A5 P:0003A7 0D03C6            JSR     <PCI_MESSAGE_TO_HOST
1469   
Motorola DSP56300 Assembler  Version 6.3.4   04-11-29  14:14:18  PCI_SCUBA_main.asm  Page 29



1470      P:0003A6 P:0003A8 0C02F9            JMP     <END_RST
1471   
1472                                ; when there is a failure in the host to PCI command then the PCI
1473                                ; needs still to reply to Host but with an error message
1474                                RCO_ERROR
1475      P:0003A7 P:0003A9 44F400            MOVE              #'REP',X0
                            524550
1476      P:0003A9 P:0003AB 447000            MOVE              X0,X:DTXS_WD1           ; REPly
                            000007
1477      P:0003AB P:0003AD 44F400            MOVE              #'RCO',X0
                            52434F
1478      P:0003AD P:0003AF 447000            MOVE              X0,X:DTXS_WD2           ; echo command sent
                            000008
1479      P:0003AF P:0003B1 44F400            MOVE              #'ERR',X0
                            455252
1480      P:0003B1 P:0003B3 447000            MOVE              X0,X:DTXS_WD3           ; ERRor im command
                            000009
1481      P:0003B3 P:0003B5 44F400            MOVE              #'006',X0
                            303036
1482      P:0003B5 P:0003B7 447000            MOVE              X0,X:DTXS_WD4           ; write to PCI memory error
                            00000A
1483      P:0003B7 P:0003B9 0D03C6            JSR     <PCI_MESSAGE_TO_HOST
1484                                END_RCO
1485      P:0003B8 P:0003BA 000004            RTI
1486                                ;---------------------------------------------------------------
1487                                ;                          * END OF ISRs *
1488                                ; --------------------------------------------------------------
1489   
1490   
1491   
1492                                ;                     * Beginning of SUBROUTINES *
1493                                ; --------------------------------------------------------------
1494                                ; routine is used to read from HTXR-DRXR data path
1495                                ; which is used by the Host to communicate with the PCI board
1496                                ; the host writes 4 words to this FIFO then interrupts the PCI
1497                                ; which reads the 4 words and acts on them accordingly.
1498                                RD_DRXR
1499      P:0003B9 P:0003BB 0A8982            JCLR    #SRRQ,X:DSR,*                     ; Wait for receiver to be not empty
                            0003B9
1500                                                                                    ; implies that host has written words
1501   
1502   
1503                                ; actually reading as slave here so this shouldn't be necessary......?
1504   
1505      P:0003BB P:0003BD 0A8717            BCLR    #FC1,X:DPMC                       ; 24 bit read FC1 = 0, FC1 = 0
1506      P:0003BC P:0003BE 0A8736            BSET    #FC0,X:DPMC
1507   
1508   
1509      P:0003BD P:0003BF 08440B            MOVEP             X:DRXR,X0               ; Get word1
1510      P:0003BE P:0003C0 440300            MOVE              X0,X:<DRXR_WD1
1511      P:0003BF P:0003C1 08440B            MOVEP             X:DRXR,X0               ; Get word2
1512      P:0003C0 P:0003C2 440400            MOVE              X0,X:<DRXR_WD2
1513      P:0003C1 P:0003C3 08440B            MOVEP             X:DRXR,X0               ; Get word3
1514      P:0003C2 P:0003C4 440500            MOVE              X0,X:<DRXR_WD3
1515      P:0003C3 P:0003C5 08440B            MOVEP             X:DRXR,X0               ; Get word4
1516      P:0003C4 P:0003C6 440600            MOVE              X0,X:<DRXR_WD4
1517      P:0003C5 P:0003C7 00000C            RTS
1518   
1519                                ; ----------------------------------------------------------------------------
1520                                ; subroutine to send 4 words as a reply from PCI to the Host
1521                                ; using the DTXS-HRXS data path
1522                                ; PCI card writes here first then causes an interrupt INTA on
Motorola DSP56300 Assembler  Version 6.3.4   04-11-29  14:14:18  PCI_SCUBA_main.asm  Page 30



1523                                ; the PCI bus to alert the host to the reply message
1524                                PCI_MESSAGE_TO_HOST
1525   
1526      P:0003C6 P:0003C8 0A00A4            JSET    #INTA_FLAG,X:<STATUS,*            ; make sure host ready to receive message
                            0003C6
1527                                                                                    ; bit will be cleared by fast interrupt
1528                                                                                    ; if ready
1529      P:0003C8 P:0003CA 0A0024            BSET    #INTA_FLAG,X:<STATUS              ; set flag for next time round.....
1530   
1531   
1532      P:0003C9 P:0003CB 0A8981            JCLR    #STRQ,X:DSR,*                     ; Wait for transmitter to be NOT FULL
                            0003C9
1533                                                                                    ; i.e. if CLR then FULL so wait
1534                                                                                    ; if not then it is clear to write
1535      P:0003CB P:0003CD 448700            MOVE              X:<DTXS_WD1,X0
1536      P:0003CC P:0003CE 447000            MOVE              X0,X:DTXS               ; Write 24 bit word1
                            FFFFCD
1537   
1538      P:0003CE P:0003D0 0A8981            JCLR    #STRQ,X:DSR,*                     ; wait to be not full
                            0003CE
1539      P:0003D0 P:0003D2 448800            MOVE              X:<DTXS_WD2,X0
1540      P:0003D1 P:0003D3 447000            MOVE              X0,X:DTXS               ; Write 24 bit word2
                            FFFFCD
1541   
1542      P:0003D3 P:0003D5 0A8981            JCLR    #STRQ,X:DSR,*                     ; wait to be not full
                            0003D3
1543      P:0003D5 P:0003D7 448900            MOVE              X:<DTXS_WD3,X0
1544      P:0003D6 P:0003D8 447000            MOVE              X0,X:DTXS               ; Write 24 bit word3
                            FFFFCD
1545   
1546      P:0003D8 P:0003DA 0A8981            JCLR    #STRQ,X:DSR,*                     ; wait to be not full
                            0003D8
1547      P:0003DA P:0003DC 448A00            MOVE              X:<DTXS_WD4,X0
1548      P:0003DB P:0003DD 447000            MOVE              X0,X:DTXS               ; Write 24 bit word4
                            FFFFCD
1549   
1550                                ; once the transmit words are in the FIFO, interrupt the Host
1551                                ; the Host should clear this interrupt once it has seen it
1552                                ; to do this it writes to the HCVR to cause a fast interrupt in the DSP
1553                                ; which clears the interrupt
1554   
1555      P:0003DD P:0003DF 0A8526            BSET    #INTA,X:DCTR                      ; Assert the interrupt
1556   
1557      P:0003DE P:0003E0 00000C            RTS
1558   
1559                                ; ---------------------------------------------------------------
1560   
1561                                ; sub routine to read a 24 bit word in  from PCI bus
1562                                ; first setup the PCI address
1563                                ; assumes register B contains the 32 bit PCI address
1564                                READ_FROM_PCI
1565   
1566                                ; read as master
1567   
1568      P:0003DF P:0003E1 0C1890            EXTRACTU #$010010,B,A                     ; Get D31-16 bits only
                            010010
1569      P:0003E1 P:0003E3 000000            NOP
1570   
1571      P:0003E2 P:0003E4 210C00            MOVE              A0,A1
1572      P:0003E3 P:0003E5 000000            NOP
1573      P:0003E4 P:0003E6 547000            MOVE              A1,X:DPMC               ; high 16bits of address in DSP master cntr 
reg.
Motorola DSP56300 Assembler  Version 6.3.4   04-11-29  14:14:18  PCI_SCUBA_main.asm  Page 31



                            FFFFC7
1574   
1575                                ; these should both be clear from above write....for 32 bit read.
1576                                ;       BCLR    #FC1,X:DPMC             ; 32 bit read FC1 = 0, FC1 = 0
1577                                ;       BCLR    #FC0,X:DPMC
1578   
1579   
1580      P:0003E6 P:0003E8 000000            NOP
1581      P:0003E7 P:0003E9 0C1890            EXTRACTU #$010000,B,A
                            010000
1582      P:0003E9 P:0003EB 000000            NOP
1583      P:0003EA P:0003EC 210C00            MOVE              A0,A1
1584      P:0003EB P:0003ED 0140C2            OR      #$060000,A                        ; A1 gets written to DPAR register
                            060000
1585      P:0003ED P:0003EF 000000            NOP                                       ; C3-C0 of DPAR=0110 for memory read
1586      P:0003EE P:0003F0 08CC08  WRT_ADD   MOVEP             A1,X:DPAR               ; Write address to PCI bus - PCI READ action
1587      P:0003EF P:0003F1 000000            NOP                                       ; Pipeline delay
1588      P:0003F0 P:0003F2 0A8AA2  RD_PCI    JSET    #MRRQ,X:DPSR,GET_DAT              ; If MTRQ = 1 go read the word from host via
 FIFO
                            0003F9
1589      P:0003F2 P:0003F4 0A8A8A            JCLR    #TRTY,X:DPSR,RD_PCI               ; Bit is set if its a retry
                            0003F0
1590      P:0003F4 P:0003F6 08F48A            MOVEP             #$0400,X:DPSR           ; Clear bit 10 = target retry bit
                            000400
1591      P:0003F6 P:0003F8 0A8A84            JCLR    #MARQ,X:DPSR,*                    ; Wait for PCI addressing to be complete
                            0003F6
1592      P:0003F8 P:0003FA 0C03EE            JMP     <WRT_ADD
1593   
1594      P:0003F9 P:0003FB 08440B  GET_DAT   MOVEP             X:DRXR,X0               ; Read 1st 16 bits of 32 bit word from host 
memory
1595      P:0003FA P:0003FC 08450B            MOVEP             X:DRXR,X1               ; Read 2nd 16 bits of 32 bit word from host 
memory
1596   
1597                                ; note that we now have 4 bytes in X0 and X1.
1598                                ; The 32bit word was in host memory in little endian format
1599                                ; If form LSB --> MSB the bytes are b1, b2, b3, b4 in host memory
1600                                ; in progressing through the HTRX/DRXR FIFO the
1601                                ; bytes end up like this.....
1602                                ; then X0 = $00 b2 b1
1603                                ; and  X1 = $00 b4 b3
1604   
1605   
1606      P:0003FB P:0003FD 0604A0            REP     #4                                ; increment PCI address by four bytes.
1607      P:0003FC P:0003FE 000009            INC     B
1608      P:0003FD P:0003FF 000000            NOP
1609      P:0003FE P:000400 00000C            RTS
1610   
1611                                ; sub routine to write two 16 bit words to the PCI bus
1612                                ; which get read as a 32 bit word by the PC
1613                                ; the 32 bit address we are writing to is writen to DPMC (MSBs) and DPAR (LSBs)
1614                                ; writes 2 words from Y:memory to one 32 bit PC address then increments address
1615                                ;
1616                                ; R2 is used as a pointer to Y:memory address
1617   
1618   
1619   
1620   
1621                                ; sub routine to read a block of 24 bit words from PCI bus --> Y mem
1622                                ; assumes register B contains the 32 bit PCI address
1623                                ; register X0 contains block size
1624   
1625                                ; ------------------------------------------------------------------------------
Motorola DSP56300 Assembler  Version 6.3.4   04-11-29  14:14:18  PCI_SCUBA_main.asm  Page 32



1626   
1627                                READ_WBLOCK
1628                                ; this subroutine is as of yet untested.....26/2/4 da
1629                                ; and is currently not used.
1630   
1631                                ; set up DMA parameters
1632   
1633      P:0003FF P:000401 200013            CLR     A
1634      P:000400 P:000402 000000            NOP
1635      P:000401 P:000403 21D300            MOVE              A,R3
1636   
1637      P:000402 P:000404 637000            MOVE              R3,X:DDR0               ; destination address address for DMA Y(R3)
                            FFFFEE
1638      P:000404 P:000406 08F4AF            MOVEP             #DRXR,X:DSR0            ; source address for DMA X:DRXR
                            FFFFCB
1639   
1640      P:000406 P:000408 208E00            MOVE              X0,A                    ; get block size
1641      P:000407 P:000409 200032            ASL     A                                 ; double - since DMA trnasfers are extended 
16bit
1642      P:000408 P:00040A 00000A            DEC     A
1643      P:000409 P:00040B 000000            NOP
1644      P:00040A P:00040C 08CE2D            MOVEP             A,X:DCO0                ; #dma txfs - 1 (2*block size - 1)
1645   
1646                                ; get burst length -1 into top byte of X0 (block size-1)
1647      P:00040B P:00040D 208E00            MOVE              X0,A
1648      P:00040C P:00040E 00000A            DEC     A
1649      P:00040D P:00040F 0C1D20            ASL     #16,A,A
1650      P:00040E P:000410 000000            NOP
1651      P:00040F P:000411 0140C6            ANDI    #$FF0000,A                        ; mask off bottom two bytes
                            FF0000
1652      P:000411 P:000413 21C400            MOVE              A,X0
1653   
1654                                ; read as master
1655   
1656   
1657      P:000412 P:000414 0C1890            EXTRACTU #$010010,B,A                     ; Get D31-16 bits only
                            010010
1658      P:000414 P:000416 000000            NOP
1659      P:000415 P:000417 210C00            MOVE              A0,A1
1660      P:000416 P:000418 000000            NOP
1661      P:000417 P:000419 200042            OR      X0,A                              ; add burst length to address
1662      P:000418 P:00041A 000000            NOP
1663      P:000419 P:00041B 547000            MOVE              A1,X:DPMC               ; high 16bits of address in DSP master cntr 
reg.
                            FFFFC7
1664   
1665      P:00041B P:00041D 000000            NOP
1666      P:00041C P:00041E 0C1890            EXTRACTU #$010000,B,A
                            010000
1667      P:00041E P:000420 000000            NOP
1668      P:00041F P:000421 210C00            MOVE              A0,A1
1669      P:000420 P:000422 0140C2            OR      #$060000,A                        ; A1 gets written to DPAR register
                            060000
1670      P:000422 P:000424 000000            NOP                                       ; C3-C0 of DPAR=0110 for memory read
1671   
1672      P:000423 P:000425 08F4AC            MOVEP             #$8EFAC4,X:DCR0         ; START DMA with control reg DE=1
                            8EFAC4
1673                                                                                    ; source X, destination Y
1674                                                                                    ; post inc dest.
1675   
1676                                WRTB_ADD
1677      P:000425 P:000427 08CC08            MOVEP             A1,X:DPAR               ; Initiate PCI READ action
Motorola DSP56300 Assembler  Version 6.3.4   04-11-29  14:14:18  PCI_SCUBA_main.asm  Page 33



1678      P:000426 P:000428 000000            NOP                                       ; Pipeline delay
1679                                RDB_PCI
1680      P:000427 P:000429 0A8AA2            JSET    #MRRQ,X:DPSR,GETB_DON             ; If MTRQ = 1 - FIFO DRXR contains data
                            000430
1681      P:000429 P:00042B 0A8A8A            JCLR    #TRTY,X:DPSR,RDB_PCI              ; Bit is set if its a retry
                            000427
1682      P:00042B P:00042D 08F48A            MOVEP             #$0400,X:DPSR           ; Clear bit 10 = target retry bit
                            000400
1683      P:00042D P:00042F 0A8A84            JCLR    #MARQ,X:DPSR,*                    ; Wait for PCI addressing to be complete
                            00042D
1684      P:00042F P:000431 0C0425            JMP     <WRTB_ADD
1685                                GETB_DON
1686      P:000430 P:000432 0A8AA2            JSET    #MRRQ,X:DPSR,*                    ; wait till finished.....till DMA empties DR
XR
                            000430
1687      P:000432 P:000434 00000C            RTS
1688   
1689   
1690                                ; --------------------------------------------------------------------------------
1691   
1692   
1693                                WRITE_TO_PCI
1694   
1695      P:000433 P:000435 0A8A81            JCLR    #MTRQ,X:DPSR,*                    ; wait here if DTXM is full
                            000433
1696   
1697      P:000435 P:000437 08DACC  TX_LSB    MOVEP             Y:(R2)+,X:DTXM          ; Least significant word to transmit
1698      P:000436 P:000438 08DACC  TX_MSB    MOVEP             Y:(R2)+,X:DTXM          ; Most significant word to transmit
1699   
1700   
1701      P:000437 P:000439 0C1890            EXTRACTU #$010010,B,A                     ; Get D31-16 bits only
                            010010
1702      P:000439 P:00043B 000000            NOP
1703      P:00043A P:00043C 210C00            MOVE              A0,A1
1704   
1705                                ; we are using two 16 bit writes to make a 32bit word so FC1=0 and FC1=0
1706   
1707      P:00043B P:00043D 000000            NOP
1708      P:00043C P:00043E 547000            MOVE              A1,X:DPMC               ; DSP master control register
                            FFFFC7
1709      P:00043E P:000440 000000            NOP
1710      P:00043F P:000441 0C1890            EXTRACTU #$010000,B,A
                            010000
1711      P:000441 P:000443 000000            NOP
1712      P:000442 P:000444 210C00            MOVE              A0,A1
1713      P:000443 P:000445 0140C2            OR      #$070000,A                        ; A1 gets written to DPAR register
                            070000
1714      P:000445 P:000447 000000            NOP
1715   
1716      P:000446 P:000448 08CC08  AGAIN1    MOVEP             A1,X:DPAR               ; Write to PCI bus
1717      P:000447 P:000449 000000            NOP                                       ; Pipeline delay
1718      P:000448 P:00044A 000000            NOP
1719      P:000449 P:00044B 0A8A84            JCLR    #MARQ,X:DPSR,*                    ; Bit is set if its a retry
                            000449
1720      P:00044B P:00044D 0A8AAE            JSET    #MDT,X:DPSR,INC_ADD               ; If no error go to the next sub-block
                            00044F
1721      P:00044D P:00044F 0D04A9            JSR     <PCI_ERROR_RECOVERY
1722      P:00044E P:000450 0C0446            JMP     <AGAIN1
1723                                INC_ADD
1724      P:00044F P:000451 0604A0            REP     #4                                ; increment PCI address by four bytes.
1725      P:000450 P:000452 000009            INC     B
1726      P:000451 P:000453 000000            NOP
Motorola DSP56300 Assembler  Version 6.3.4   04-11-29  14:14:18  PCI_SCUBA_main.asm  Page 34



1727      P:000452 P:000454 00000C            RTS
1728   
1729                                ; ----------------------------------------------------------------------------------
1730   
1731                                ; R2 is used as a pointer to Y:memory address
1732   
1733                                WRITE_512_TO_PCI                                    ; writes 512 pixels (256 x 32bit writes) acr
oss PCI bus in 4 x 128 pixel bursts
1734      P:000453 P:000455 3A8000            MOVE              #128,N2                 ; Number of pixels per transfer (!!!)
1735   
1736                                ; Make sure its always 512 pixels per loop = 1/2 FIFO
1737      P:000454 P:000456 627000            MOVE              R2,X:DSR0               ; Source address for DMA = pixel data
                            FFFFEF
1738      P:000456 P:000458 08F4AE            MOVEP             #DTXM,X:DDR0            ; Destination = PCI master transmitter
                            FFFFCC
1739      P:000458 P:00045A 08F4AD            MOVEP             #>127,X:DCO0            ; DMA Count = # of pixels - 1 (!!!)
                            00007F
1740   
1741                                ; Do loop does 4 x 128 pixel DMA writes = 512.
1742                                ; need to recalculate hi and lo parts of address
1743                                ; for each burst.....Leach doesn't do this since not
1744                                ; multiple frames...so only needs to inc low part.....
1745   
1746      P:00045A P:00045C 060480            DO      #4,WR_BLK0                        ; x # of pixels = 512 (!!!)
                            00047D
1747   
1748      P:00045C P:00045E 0C1890            EXTRACTU #$010010,B,A                     ; Get D31-16 bits only
                            010010
1749      P:00045E P:000460 000000            NOP
1750      P:00045F P:000461 210C00            MOVE              A0,A1                   ; [D31-16] in A1
1751      P:000460 P:000462 000000            NOP
1752      P:000461 P:000463 0140C2            ORI     #$3F0000,A                        ; Burst length = # of PCI writes (!!!)
                            3F0000
1753      P:000463 P:000465 000000            NOP                                       ;   = # of pixels / 2 - 1 ...$3F = 63
1754      P:000464 P:000466 547000            MOVE              A1,X:DPMC               ; DPMC = B[31:16] + $3F0000
                            FFFFC7
1755   
1756   
1757      P:000466 P:000468 0C1890            EXTRACTU #$010000,B,A
                            010000
1758      P:000468 P:00046A 000000            NOP
1759      P:000469 P:00046B 210C00            MOVE              A0,A1                   ; Get PCI_ADDR[15:0] into A1[15:0]
1760      P:00046A P:00046C 000000            NOP
1761      P:00046B P:00046D 0140C2            OR      #$070000,A                        ; A1 gets written to DPAR register
                            070000
1762      P:00046D P:00046F 000000            NOP
1763   
1764   
1765      P:00046E P:000470 08F4AC  AGAIN0    MOVEP             #$8EFA51,X:DCR0         ; Start DMA with control register DE=1
                            8EFA51
1766      P:000470 P:000472 08CC08            MOVEP             A1,X:DPAR               ; Initiate writing to the PCI bus
1767      P:000471 P:000473 000000            NOP
1768      P:000472 P:000474 000000            NOP
1769      P:000473 P:000475 0A8A84            JCLR    #MARQ,X:DPSR,*                    ; Wait until the PCI operation is done
                            000473
1770      P:000475 P:000477 0A8AAE            JSET    #MDT,X:DPSR,WR_OK0                ; If no error go to the next sub-block
                            000479
1771      P:000477 P:000479 0D04A9            JSR     <PCI_ERROR_RECOVERY
1772      P:000478 P:00047A 0C046E            JMP     <AGAIN0                           ; Just try to write the sub-block again
1773                                WR_OK0
1774   
1775      P:000479 P:00047B 200013            CLR     A
Motorola DSP56300 Assembler  Version 6.3.4   04-11-29  14:14:18  PCI_SCUBA_main.asm  Page 35



1776      P:00047A P:00047C 50F400            MOVE              #>256,A0                ; 2 bytes on pcibus per pixel
                            000100
1777      P:00047C P:00047E 200018            ADD     A,B                               ; PCI address = + 2 x # of pixels (!!!)
1778      P:00047D P:00047F 204A00            MOVE              (R2)+N2                 ; Pixel buffer address = + # of pixels
1779                                WR_BLK0
1780      P:00047E P:000480 00000C            RTS
1781   
1782                                ; -------------------------------------------------------------------------------------------
1783   
1784                                WRITE_32_TO_PCI                                     ; writes 32 pixels....= 16 x 32bit words acr
oss PCI bus bursted
1785      P:00047F P:000481 3A2000            MOVE              #32,N2                  ; Number of pixels per transfer (!!!)
1786   
1787      P:000480 P:000482 627000            MOVE              R2,X:DSR0               ; Source address for DMA = pixel data
                            FFFFEF
1788      P:000482 P:000484 08F4AE            MOVEP             #DTXM,X:DDR0            ; Destination = PCI master transmitter
                            FFFFCC
1789      P:000484 P:000486 08F4AD            MOVEP             #>31,X:DCO0             ; DMA Count = # of pixels - 1 (!!!)
                            00001F
1790   
1791      P:000486 P:000488 0C1890            EXTRACTU #$010010,B,A                     ; Get D31-16 bits only
                            010010
1792      P:000488 P:00048A 000000            NOP
1793      P:000489 P:00048B 210C00            MOVE              A0,A1                   ; [D31-16] in A1
1794      P:00048A P:00048C 000000            NOP
1795      P:00048B P:00048D 0140C2            ORI     #$0F0000,A                        ; Burst length = # of PCI writes (!!!)
                            0F0000
1796      P:00048D P:00048F 000000            NOP                                       ;   = # of pixels / 2 - 1 ...$0F = 16
1797      P:00048E P:000490 547000            MOVE              A1,X:DPMC               ; DPMC = B[31:16] + $3F0000
                            FFFFC7
1798   
1799      P:000490 P:000492 0C1890            EXTRACTU #$010000,B,A
                            010000
1800      P:000492 P:000494 000000            NOP
1801      P:000493 P:000495 210C00            MOVE              A0,A1                   ; Get PCI_ADDR[15:0] into A1[15:0]
1802      P:000494 P:000496 000000            NOP
1803      P:000495 P:000497 0140C2            ORI     #$070000,A                        ; A1 gets written to DPAR register
                            070000
1804      P:000497 P:000499 000000            NOP
1805   
1806   
1807      P:000498 P:00049A 08F4AC  AGAIN2    MOVEP             #$8EFA51,X:DCR0         ; Start DMA with control register DE=1
                            8EFA51
1808      P:00049A P:00049C 08CC08            MOVEP             A1,X:DPAR               ; Initiate writing to the PCI bus
1809      P:00049B P:00049D 000000            NOP
1810      P:00049C P:00049E 000000            NOP
1811      P:00049D P:00049F 0A8A84            JCLR    #MARQ,X:DPSR,*                    ; Wait until the PCI operation is done
                            00049D
1812      P:00049F P:0004A1 0A8AAE            JSET    #MDT,X:DPSR,WR_OK1                ; If no error go to the next sub-block
                            0004A3
1813      P:0004A1 P:0004A3 0D04A9            JSR     <PCI_ERROR_RECOVERY
1814      P:0004A2 P:0004A4 0C0498            JMP     <AGAIN2                           ; Just try to write the sub-block again
1815                                WR_OK1
1816      P:0004A3 P:0004A5 200013            CLR     A
1817      P:0004A4 P:0004A6 50F400            MOVE              #>64,A0                 ; 2 bytes on pcibus per pixel
                            000040
1818      P:0004A6 P:0004A8 200018            ADD     A,B                               ; PCI address = + 2 x # of pixels (!!!)
1819      P:0004A7 P:0004A9 204A00            MOVE              (R2)+N2                 ; Pixel buffer address = + # of pixels
1820      P:0004A8 P:0004AA 00000C            RTS
1821   
1822   
1823                                ; ------------------------------------------------------------------------------
Motorola DSP56300 Assembler  Version 6.3.4   04-11-29  14:14:18  PCI_SCUBA_main.asm  Page 36



1824   
1825                                                                                    ; Recover from an error writing to the PCI b
us
1826                                PCI_ERROR_RECOVERY
1827      P:0004A9 P:0004AB 0A8A8A            JCLR    #TRTY,X:DPSR,ERROR1               ; Retry error
                            0004AE
1828      P:0004AB P:0004AD 08F48A            MOVEP             #$0400,X:DPSR           ; Clear target retry error bit
                            000400
1829      P:0004AD P:0004AF 00000C            RTS
1830      P:0004AE P:0004B0 0A8A8B  ERROR1    JCLR    #TO,X:DPSR,ERROR2                 ; Timeout error
                            0004B3
1831      P:0004B0 P:0004B2 08F48A            MOVEP             #$0800,X:DPSR           ; Clear timeout error bit
                            000800
1832      P:0004B2 P:0004B4 00000C            RTS
1833      P:0004B3 P:0004B5 0A8A89  ERROR2    JCLR    #TDIS,X:DPSR,ERROR3               ; Target disconnect error
                            0004B8
1834      P:0004B5 P:0004B7 08F48A            MOVEP             #$0200,X:DPSR           ; Clear target disconnect bit
                            000200
1835      P:0004B7 P:0004B9 00000C            RTS
1836      P:0004B8 P:0004BA 0A8A88  ERROR3    JCLR    #TAB,X:DPSR,ERROR4                ; Target abort error
                            0004BD
1837      P:0004BA P:0004BC 08F48A            MOVEP             #$0100,X:DPSR           ; Clear target abort error bit
                            000100
1838      P:0004BC P:0004BE 00000C            RTS
1839      P:0004BD P:0004BF 0A8A87  ERROR4    JCLR    #MAB,X:DPSR,ERROR5                ; Master abort error
                            0004C2
1840      P:0004BF P:0004C1 08F48A            MOVEP             #$0080,X:DPSR           ; Clear master abort error bit
                            000080
1841      P:0004C1 P:0004C3 00000C            RTS
1842      P:0004C2 P:0004C4 0A8A86  ERROR5    JCLR    #DPER,X:DPSR,ERROR6               ; Data parity error
                            0004C7
1843      P:0004C4 P:0004C6 08F48A            MOVEP             #$0040,X:DPSR           ; Clear data parity error bit
                            000040
1844      P:0004C6 P:0004C8 00000C            RTS
1845      P:0004C7 P:0004C9 0A8A85  ERROR6    JCLR    #APER,X:DPSR,ERROR7               ; Address parity error
                            0004CB
1846      P:0004C9 P:0004CB 08F48A            MOVEP             #$0020,X:DPSR           ; Clear address parity error bit
                            000020
1847      P:0004CB P:0004CD 00000C  ERROR7    RTS
1848   
1849                                ; --------------------------------------------------------------------------------
1850   
1851   
1852                                ; **********   get a word from FO and put in X0     **********************************
1853   
1854      P:0004CC P:0004CE 01AD80  GET_FO_WRD JCLR   #EF,X:PDRD,CLR_FO_RTS
                            0004E2
1855      P:0004CE P:0004D0 000000            NOP
1856      P:0004CF P:0004D1 000000            NOP
1857      P:0004D0 P:0004D2 01AD80            JCLR    #EF,X:PDRD,CLR_FO_RTS             ; check twice for FO metastability.
                            0004E2
1858      P:0004D2 P:0004D4 0AF080            JMP     RD_FO_WD
                            0004DA
1859   
1860      P:0004D4 P:0004D6 01AD80  WT_FIFO   JCLR    #EF,X:PDRD,*                      ; Wait till something in FIFO flagged
                            0004D4
1861      P:0004D6 P:0004D8 000000            NOP
1862      P:0004D7 P:0004D9 000000            NOP
1863      P:0004D8 P:0004DA 01AD80            JCLR    #EF,X:PDRD,WT_FIFO                ; check twice.....
                            0004D4
1864   
1865   
Motorola DSP56300 Assembler  Version 6.3.4   04-11-29  14:14:18  PCI_SCUBA_main.asm  Page 37



1866                                ; Read one word from the fiber optics FIFO, check it and put it in A1
1867                                RD_FO_WD
1868   
1869      P:0004DA P:0004DC 09443F  GET_WD    MOVEP             Y:RDFIFO,X0             ; then read to X0
1870      P:0004DB P:0004DD 54F400            MOVE              #$00FFFF,A1             ; mask off top 2 bytes ($FC)
                            00FFFF
1871      P:0004DD P:0004DF 200046            AND     X0,A                              ; since receiving 16 bits in 24bit register
1872      P:0004DE P:0004E0 000000            NOP
1873      P:0004DF P:0004E1 218400            MOVE              A1,X0
1874      P:0004E0 P:0004E2 0A0023  SET_FO_RTS BSET   #FO_WRD_RCV,X:<STATUS
1875                                 END_WT_FIFO
1876      P:0004E1 P:0004E3 00000C            RTS
1877   
1878      P:0004E2 P:0004E4 0A0003  CLR_FO_RTS BCLR   #FO_WRD_RCV,X:<STATUS
1879      P:0004E3 P:0004E5 00000C            RTS
1880   
1881                                ; ----------------------------------------------------------------------------------
1882   
1883                                ; put this in just now for left over data reads
1884                                WT_FIFO_DA
1885      P:0004E4 P:0004E6 01AD80            JCLR    #EF,X:PDRD,*                      ; Wait till something in FIFO flagged
                            0004E4
1886      P:0004E6 P:0004E8 000000            NOP
1887      P:0004E7 P:0004E9 000000            NOP
1888      P:0004E8 P:0004EA 01AD80            JCLR    #EF,X:PDRD,WT_FIFO_DA             ; check twice.....
                            0004E4
1889      P:0004EA P:0004EC 09443F            MOVEP             Y:RDFIFO,X0             ; then read to X0
1890      P:0004EB P:0004ED 54F400            MOVE              #$00FFFF,A1             ; mask off top 2 bytes ($FC)
                            00FFFF
1891      P:0004ED P:0004EF 200046            AND     X0,A                              ; since receiving 16 bits and 3 bytes sent
1892      P:0004EE P:0004F0 000000            NOP
1893      P:0004EF P:0004F1 218400            MOVE              A1,X0
1894      P:0004F0 P:0004F2 00000C            RTS
1895   
1896                                ; Short delay for reliability
1897      P:0004F1 P:0004F3 000000  XMT_DLY   NOP
1898      P:0004F2 P:0004F4 000000            NOP
1899      P:0004F3 P:0004F5 000000            NOP
1900      P:0004F4 P:0004F6 00000C            RTS
1901   
1902                                ; 250 MHz code - Transmit contents of Accumulator A1 to the MCE
1903   
1904                                ; we want to send 32bit word in little endian fomat to the host.
1905                                ; i.e. b4b3b2b1 goes b1, b2, b3, b4
1906   
1907                                ; currently the bytes are in this order:
1908                                ; then A1 = $00 b2 b1
1909                                ; and  A0 = $00 b4 b3
1910                                ; A = $00 00 b2 b1 00 b4 b3
1911   
1912   
1913                                XMT_WD_FIBRE
1914   
1915                                ; save registers
1916   
1917      P:0004F5 P:0004F7 502600            MOVE              A0,X:<SV_A0             ; Save registers used in XMT_WRD
1918      P:0004F6 P:0004F8 542700            MOVE              A1,X:<SV_A1
1919      P:0004F7 P:0004F9 522800            MOVE              A2,X:<SV_A2
1920      P:0004F8 P:0004FA 452D00            MOVE              X1,X:<SV_X1
1921      P:0004F9 P:0004FB 442C00            MOVE              X0,X:<SV_X0
1922      P:0004FA P:0004FC 472F00            MOVE              Y1,X:<SV_Y1
1923      P:0004FB P:0004FD 462E00            MOVE              Y0,X:<SV_Y0
Motorola DSP56300 Assembler  Version 6.3.4   04-11-29  14:14:18  PCI_SCUBA_main.asm  Page 38



1924   
1925                                ; split up 4 bytes b2, b1, b4, b3
1926   
1927      P:0004FC P:0004FE 0C1D20            ASL     #16,A,A                           ; shift byte b2 into A2
1928      P:0004FD P:0004FF 60F400            MOVE              #$FFF000,R0             ; Memory mapped address of transmitter
                            FFF000
1929   
1930      P:0004FF P:000501 214700            MOVE              A2,Y1                   ; byte b2 in Y1
1931   
1932      P:000500 P:000502 0C1D10            ASL     #8,A,A                            ; shift byte b1 into A2
1933      P:000501 P:000503 000000            NOP
1934      P:000502 P:000504 214600            MOVE              A2,Y0                   ; byte b1 in Y0
1935   
1936      P:000503 P:000505 0C1D20            ASL     #16,A,A                           ; shift byte b4 into A2
1937      P:000504 P:000506 000000            NOP
1938      P:000505 P:000507 214500            MOVE              A2,X1                   ; byte b4 in X1
1939   
1940   
1941      P:000506 P:000508 0C1D10            ASL     #8,A,A                            ; shift byte b3 into A2
1942      P:000507 P:000509 000000            NOP
1943      P:000508 P:00050A 214400            MOVE              A2,X0                   ; byte b3 in x0
1944   
1945   
1946                                ; transmit b1, b2, b3 ,b4
1947   
1948      P:000509 P:00050B 466000            MOVE              Y0,X:(R0)               ; byte b1 - off it goes
1949      P:00050A P:00050C 476000            MOVE              Y1,X:(R0)               ; byte b2- off it goes
1950      P:00050B P:00050D 446000            MOVE              X0,X:(R0)               ; byte b3 - off it goes
1951      P:00050C P:00050E 456000            MOVE              X1,X:(R0)               ; byte b4 - off it goes
1952   
1953                                ; restore registers
1954      P:00050D P:00050F 502600            MOVE              A0,X:<SV_A0
1955      P:00050E P:000510 542700            MOVE              A1,X:<SV_A1
1956      P:00050F P:000511 522800            MOVE              A2,X:<SV_A2
1957      P:000510 P:000512 45AD00            MOVE              X:<SV_X1,X1             ; Restore registers used here
1958      P:000511 P:000513 44AC00            MOVE              X:<SV_X0,X0
1959      P:000512 P:000514 47AF00            MOVE              X:<SV_Y1,Y1
1960      P:000513 P:000515 46AE00            MOVE              X:<SV_Y0,Y0
1961      P:000514 P:000516 00000C            RTS
1962   
1963                                ; ----------------------------------------------------------------------------
1964   
1965                                ; number of 512 buffers in packet calculated (X:TOTAL_BUFFS)
1966                                ; and number of left over blocks
1967                                ; and left over words (X:LEFT_TO_READ)
1968   
1969                                CALC_NO_BUFFS
1970   
1971      P:000515 P:000517 462E00            MOVE              Y0,X:<SV_Y0
1972      P:000516 P:000518 472F00            MOVE              Y1,X:<SV_Y1
1973   
1974      P:000517 P:000519 20001B            CLR     B
1975      P:000518 P:00051A 519E00            MOVE              X:<HEAD_W4_0,B0         ; LS 16bits
1976      P:000519 P:00051B 449D00            MOVE              X:<HEAD_W4_1,X0         ; MS 16bits
1977   
1978      P:00051A P:00051C 0C1941            INSERT  #$010010,X0,B                     ; now size of packet B....giving # of 32bit 
words in packet
                            010010
1979      P:00051C P:00051E 000000            NOP
1980   
1981                                ; need to covert this to 16 bit since read from FIFO and saved in Y memory as 16bit words...
1982   
Motorola DSP56300 Assembler  Version 6.3.4   04-11-29  14:14:18  PCI_SCUBA_main.asm  Page 39



1983                                ; so double size of packet....
1984      P:00051D P:00051F 20003A            ASL     B
1985   
1986                                ; now save
1987      P:00051E P:000520 212400            MOVE              B0,X0
1988      P:00051F P:000521 21A500            MOVE              B1,X1
1989      P:000520 P:000522 443700            MOVE              X0,X:<PACKET_SIZE_LOW   ; low 24 bits of packet size (in 16bit words
)
1990      P:000521 P:000523 453800            MOVE              X1,X:<PACKET_SIZE_HIH   ; high 8 bits of packet size (in 16bit words
)
1991   
1992      P:000522 P:000524 50B700            MOVE              X:<PACKET_SIZE_LOW,A0
1993      P:000523 P:000525 54B800            MOVE              X:<PACKET_SIZE_HIH,A1
1994      P:000524 P:000526 0C1C12            ASR     #9,A,A                            ; divide by 512...number of 16bit words in a
 buffer
1995      P:000525 P:000527 000000            NOP
1996      P:000526 P:000528 503C00            MOVE              A0,X:<TOTAL_BUFFS
1997   
1998      P:000527 P:000529 210500            MOVE              A0,X1
1999      P:000528 P:00052A 47F400            MOVE              #HF_FIFO,Y1
                            000200
2000      P:00052A P:00052C 2000F0            MPY     X1,Y1,A
2001      P:00052B P:00052D 0C1C03            ASR     #1,A,B                            ; B holds number of 16bit words in all full 
buffers
2002      P:00052C P:00052E 000000            NOP
2003   
2004   
2005      P:00052D P:00052F 50B700            MOVE              X:<PACKET_SIZE_LOW,A0
2006      P:00052E P:000530 54B800            MOVE              X:<PACKET_SIZE_HIH,A1   ; A holds total number of 16bit words
2007      P:00052F P:000531 200014            SUB     B,A                               ; now A holds number of left over 16bit word
s
2008      P:000530 P:000532 000000            NOP
2009      P:000531 P:000533 503D00            MOVE              A0,X:<LEFT_TO_READ      ; store number of left over 16bit words to r
ead
2010      P:000532 P:000534 0C1C0A            ASR     #5,A,A                            ; divide by 32... number of 16bit words in l
efover block
2011      P:000533 P:000535 000000            NOP
2012      P:000534 P:000536 503F00            MOVE              A0,X:<NUM_LEFTOVER_BLOCKS
2013      P:000535 P:000537 210500            MOVE              A0,X1
2014      P:000536 P:000538 47F400            MOVE              #>SMALL_BLK,Y1
                            000020
2015      P:000538 P:00053A 2000F0            MPY     X1,Y1,A
2016      P:000539 P:00053B 0C1C02            ASR     #1,A,A
2017      P:00053A P:00053C 000000            NOP
2018   
2019      P:00053B P:00053D 200018            ADD     A,B                               ; B holds words in all buffers
2020      P:00053C P:00053E 000000            NOP
2021      P:00053D P:00053F 50B700            MOVE              X:<PACKET_SIZE_LOW,A0
2022      P:00053E P:000540 54B800            MOVE              X:<PACKET_SIZE_HIH,A1   ; A holds total number of words
2023      P:00053F P:000541 200014            SUB     B,A                               ; now A holds number of left over words
2024      P:000540 P:000542 000000            NOP
2025      P:000541 P:000543 503D00            MOVE              A0,X:<LEFT_TO_READ      ; store number of left over 16bit words to r
ead
2026   
2027      P:000542 P:000544 0C1C02            ASR     #1,A,A                            ; divide by two to get number of 32 bit word
s to write
2028      P:000543 P:000545 000000            NOP                                       ; for pipeline
2029      P:000544 P:000546 503E00            MOVE              A0,X:<LEFT_TO_WRITE     ; store number of left over 32 bit words (2 
x 16 bit) to write to host after small block transfer as well
2030   
2031      P:000545 P:000547 46AE00            MOVE              X:<SV_Y0,Y0
2032      P:000546 P:000548 47AF00            MOVE              X:<SV_Y1,Y1
Motorola DSP56300 Assembler  Version 6.3.4   04-11-29  14:14:18  PCI_SCUBA_main.asm  Page 40



2033   
2034      P:000547 P:000549 00000C            RTS
2035   
2036                                ; -------------------------------------------------------------------------------------
2037   
2038                                ; ******** end of Sub Routines ********
2039   
2040   
2041                                          IF      @CVS(N,*)>=APPLICATION
2043                                          ENDIF
2044   
2045   
2046   
2047   
2048                                ; ******************************************
2049                                ;******* x memory parameter table **********
2050                                ; ******************************************
2051   
2052      X:000000 P:00054A                   ORG     X:VAR_TBL,P:
2053   
2054   
2055                                          IF      @SCP("ROM","ROM")                 ; Boot ROM code
2056                                 VAR_TBL_START
2057      000548                              EQU     @LCV(L)-2
2058                                          ENDIF
2059   
2060                                          IF      @SCP("ROM","ONCE")                ; Download via ONCE debugger
2062                                          ENDIF
2063   
2064                                ; -----------------------------------------------
2065                                ; do not move these from X:0 and X:1
2066 d    X:000000 P:00054A 000000  STATUS    DC      0
2067 d                               FRAME_COUNT
2068 d    X:000001 P:00054B 000000            DC      0                                 ; used as a check....... increments for ever
y frame write.....must be cleared by host.
2069 d                               PRE_CORRUPT
2070 d    X:000002 P:00054C 000000            DC      0
2071                                ; -------------------------------------------------
2072   
2073 d    X:000003 P:00054D 000000  DRXR_WD1  DC      0
2074 d    X:000004 P:00054E 000000  DRXR_WD2  DC      0
2075 d    X:000005 P:00054F 000000  DRXR_WD3  DC      0
2076 d    X:000006 P:000550 000000  DRXR_WD4  DC      0
2077 d    X:000007 P:000551 000000  DTXS_WD1  DC      0
2078 d    X:000008 P:000552 000000  DTXS_WD2  DC      0
2079 d    X:000009 P:000553 000000  DTXS_WD3  DC      0
2080 d    X:00000A P:000554 000000  DTXS_WD4  DC      0
2081   
2082 d    X:00000B P:000555 000000  PCI_WD1_1 DC      0
2083 d    X:00000C P:000556 000000  PCI_WD1_2 DC      0
2084 d    X:00000D P:000557 000000  PCI_WD2_1 DC      0
2085 d    X:00000E P:000558 000000  PCI_WD2_2 DC      0
2086 d    X:00000F P:000559 000000  PCI_WD3_1 DC      0
2087 d    X:000010 P:00055A 000000  PCI_WD3_2 DC      0
2088 d    X:000011 P:00055B 000000  PCI_WD4_1 DC      0
2089 d    X:000012 P:00055C 000000  PCI_WD4_2 DC      0
2090 d    X:000013 P:00055D 000000  PCI_WD5_1 DC      0
2091 d    X:000014 P:00055E 000000  PCI_WD5_2 DC      0
2092 d    X:000015 P:00055F 000000  PCI_WD6_1 DC      0
2093 d    X:000016 P:000560 000000  PCI_WD6_2 DC      0
2094   
2095   
Motorola DSP56300 Assembler  Version 6.3.4   04-11-29  14:14:18  PCI_SCUBA_main.asm  Page 41



2096 d    X:000017 P:000561 000000  HEAD_W1_1 DC      0
2097 d    X:000018 P:000562 000000  HEAD_W1_0 DC      0
2098 d    X:000019 P:000563 000000  HEAD_W2_1 DC      0
2099 d    X:00001A P:000564 000000  HEAD_W2_0 DC      0
2100 d    X:00001B P:000565 000000  HEAD_W3_1 DC      0
2101 d    X:00001C P:000566 000000  HEAD_W3_0 DC      0
2102 d    X:00001D P:000567 000000  HEAD_W4_1 DC      0
2103 d    X:00001E P:000568 000000  HEAD_W4_0 DC      0
2104   
2105   
2106 d    X:00001F P:000569 000000  REP_WD1   DC      0
2107 d    X:000020 P:00056A 000000  REP_WD2   DC      0
2108 d    X:000021 P:00056B 000000  REP_WD3   DC      0
2109 d    X:000022 P:00056C 000000  REP_WD4   DC      0
2110   
2111 d    X:000023 P:00056D 000000  NO_32BIT  DC      0
2112 d    X:000024 P:00056E 00FFFF  MASK_16BIT DC     $00FFFF                           ; 16 bit mask to clear top to bytes
2113 d    X:000025 P:00056F 00FF00  C00FF00   DC      $00FF00
2114   
2115 d    X:000026 P:000570 000000  SV_A0     DC      0
2116 d    X:000027 P:000571 000000  SV_A1     DC      0
2117 d    X:000028 P:000572 000000  SV_A2     DC      0
2118 d    X:000029 P:000573 000000  SV_B0     DC      0
2119 d    X:00002A P:000574 000000  SV_B1     DC      0
2120 d    X:00002B P:000575 000000  SV_B2     DC      0
2121 d    X:00002C P:000576 000000  SV_X0     DC      0
2122 d    X:00002D P:000577 000000  SV_X1     DC      0
2123 d    X:00002E P:000578 000000  SV_Y0     DC      0
2124 d    X:00002F P:000579 000000  SV_Y1     DC      0
2125   
2126 d    X:000030 P:00057A 000000  SV_SR     DC      0                                 ; stauts register save.
2127   
2128 d    X:000031 P:00057B 000000  ZERO      DC      0
2129 d    X:000032 P:00057C 000001  ONE       DC      1
2130 d    X:000033 P:00057D 000002  TWO       DC      2
2131 d    X:000034 P:00057E 000003  THREE     DC      3
2132 d    X:000035 P:00057F 000004  FOUR      DC      4
2133 d    X:000036 P:000580 000040  WBLK_SIZE DC      64
2134   
2135 d                               PACKET_SIZE_LOW
2136 d    X:000037 P:000581 000000            DC      0
2137 d                               PACKET_SIZE_HIH
2138 d    X:000038 P:000582 000000            DC      0
2139   
2140 d    X:000039 P:000583 00A5A5  PREAMB1   DC      $A5A5                             ; pramble 16-bit word....2 of which make up 
first preamble 32bit word
2141 d    X:00003A P:000584 005A5A  PREAMB2   DC      $5A5A                             ; preamble 16-bit word....2 of which make up
 second preamble 32bit word
2142 d    X:00003B P:000585 004441  DATA_WD   DC      $4441
2143   
2144 d                               TOTAL_BUFFS
2145 d    X:00003C P:000586 000000            DC      0                                 ; total number of 512 buffers in packet
2146 d                               LEFT_TO_READ
2147 d    X:00003D P:000587 000000            DC      0                                 ; number of words (16 bit) left to read afte
r last 512 buffer
2148 d                               LEFT_TO_WRITE
2149 d    X:00003E P:000588 000000            DC      0                                 ; number of woreds (32 bit) to write to host
 i.e. half of those left over read
2150 d                               NUM_LEFTOVER_BLOCKS
2151 d    X:00003F P:000589 000000            DC      0                                 ; small block DMA burst transfer
2152   
2153   
Motorola DSP56300 Assembler  Version 6.3.4   04-11-29  14:14:18  PCI_SCUBA_main.asm  Page 42



2154   
2155                                          IF      @SCP("ROM","ROM")                 ; Boot ROM code
2156                                 VAR_TBL_END
2157      000588                              EQU     @LCV(L)-2
2158                                          ENDIF
2159   
2160                                          IF      @SCP("ROM","ONCE")                ; Download via ONCE debugger
2162                                          ENDIF
2163   
2164                                 VAR_TBL_LENGTH
2165      000040                              EQU     VAR_TBL_END-VAR_TBL_START
2166   
2167   
2168      00058A                    END_ADR   EQU     @LCV(L)                           ; End address of P: code written to ROM
2169   
2170   
**** 2171 [PCI_SCUBA_build.asm 25]:  Build is complete
2171                                          MSG     ' Build is complete'
2172   
2173   
2174   

0    Errors
0    Warnings


