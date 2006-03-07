Motorola DSP56300 Assembler  Version 6.3.4   06-03-07  12:16:30  PCI_SCUBA_build.asm  Page 1



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
Motorola DSP56300 Assembler  Version 6.3.4   06-03-07  12:16:30  PCI_SCUBA_header.asm  Page 2



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
99                         ; HST timeout recovery....
100    
101       000200           MAX_DUMP  EQU     512                               ; if HST timeout.. max number that could be in FIFO i
s 511..
102       000200           DUMP_BUFF EQU     512                               ; store in Y memory above normal data buffer...(Y:0 -
-> Y:511)
103    
104    
105    
106                        ; Various addressing control registers
107       FFFFFB           BCR       EQU     $FFFFFB                           ; Bus Control Register
108       FFFFFA           DCR       EQU     $FFFFFA                           ; DRAM Control Register
109       FFFFF9           AAR0      EQU     $FFFFF9                           ; Address Attribute Register, channel 0
110       FFFFF8           AAR1      EQU     $FFFFF8                           ; Address Attribute Register, channel 1
111       FFFFF7           AAR2      EQU     $FFFFF7                           ; Address Attribute Register, channel 2
112       FFFFF6           AAR3      EQU     $FFFFF6                           ; Address Attribute Register, channel 3
113       FFFFFD           PCTL      EQU     $FFFFFD                           ; PLL control register
Motorola DSP56300 Assembler  Version 6.3.4   06-03-07  12:16:30  PCI_SCUBA_header.asm  Page 3



114       FFFFFE           IPRP      EQU     $FFFFFE                           ; Interrupt Priority register - Peripheral
115       FFFFFF           IPRC      EQU     $FFFFFF                           ; Interrupt Priority register - Core
116    
117                        ; PCI control register
118       FFFFCD           DTXS      EQU     $FFFFCD                           ; DSP Slave transmit data FIFO
119       FFFFCC           DTXM      EQU     $FFFFCC                           ; DSP Master transmit data FIFO
120       FFFFCB           DRXR      EQU     $FFFFCB                           ; DSP Receive data FIFO
121       FFFFCA           DPSR      EQU     $FFFFCA                           ; DSP PCI Status Register
122       FFFFC9           DSR       EQU     $FFFFC9                           ; DSP Status Register
123       FFFFC8           DPAR      EQU     $FFFFC8                           ; DSP PCI Address Register
124       FFFFC7           DPMC      EQU     $FFFFC7                           ; DSP PCI Master Control Register
125       FFFFC6           DPCR      EQU     $FFFFC6                           ; DSP PCI Control Register
126       FFFFC5           DCTR      EQU     $FFFFC5                           ; DSP Control Register
127    
128                        ; Port E is the Synchronous Communications Interface (SCI) port
129       FFFF9F           PCRE      EQU     $FFFF9F                           ; Port Control Register
130       FFFF9E           PRRE      EQU     $FFFF9E                           ; Port Direction Register
131       FFFF9D           PDRE      EQU     $FFFF9D                           ; Port Data Register
132    
133                        ; Various PCI register bit equates
134       000001           STRQ      EQU     1                                 ; Slave transmit data request (DSR)
135       000002           SRRQ      EQU     2                                 ; Slave receive data request (DSR)
136       000017           HACT      EQU     23                                ; Host active, low true (DSR)
137       000001           MTRQ      EQU     1                                 ; Set whem master transmitter is not full (DPSR)
138       000004           MARQ      EQU     4                                 ; Master address request (DPSR)
139       000002           MRRQ      EQU     2                                 ; Master Receive Request (DPSR)
140       00000A           TRTY      EQU     10                                ; PCI Target Retry (DPSR)
141    
142       000005           APER      EQU     5                                 ; Address parity error
143       000006           DPER      EQU     6                                 ; Data parity error
144       000007           MAB       EQU     7                                 ; Master Abort
145       000008           TAB       EQU     8                                 ; Target Abort
146       000009           TDIS      EQU     9                                 ; Target Disconnect
147       00000B           TO        EQU     11                                ; Timeout
148       00000E           MDT       EQU     14                                ; Master Data Transfer complete
149       000002           SCLK      EQU     2                                 ; SCLK = transmitter special code
150    
151                        ; bits in DPMC
152    
153       000017           FC1       EQU     23
154       000016           FC0       EQU     22
155    
156    
157                        ; DMA register definitions
158       FFFFEF           DSR0      EQU     $FFFFEF                           ; Source address register
159       FFFFEE           DDR0      EQU     $FFFFEE                           ; Destination address register
160       FFFFED           DCO0      EQU     $FFFFED                           ; Counter register
161       FFFFEC           DCR0      EQU     $FFFFEC                           ; Control register
162    
163                        ; The DCTR host flags are written by the DSP and read by PCI host
164       000003           DCTR_RPLY EQU     3                                 ; Set after reply
165       000004           DCTR_BUF0 EQU     4                                 ; Set after buffer 0 is written to
166       000005           DCTR_BUF1 EQU     5                                 ; Set after buffer 1 is written to
167       000006           INTA      EQU     6                                 ; Request PCI interrupt
168    
169                        ; The DSR host flags are written by the PCI host and read by the DSP
170       000004           DSR_BUF0  EQU     4                                 ; PCI host sets this when copying buffer 0
171       000005           DSR_BUF1  EQU     5                                 ; PCI host sets this when copying buffer 1
172    
173                        ; DPCR bit definitions
174       00000E           CLRT      EQU     14                                ; Clear transmitter
175       000012           MACE      EQU     18                                ; Master access counter enable
Motorola DSP56300 Assembler  Version 6.3.4   06-03-07  12:16:30  PCI_SCUBA_header.asm  Page 4



176       000015           IAE       EQU     21                                ; Insert Address Enable
177    
178                        ; Addresses of ESSI port
179       FFFFBC           TX00      EQU     $FFFFBC                           ; Transmit Data Register 0
180       FFFFB7           SSISR0    EQU     $FFFFB7                           ; Status Register
181       FFFFB6           CRB0      EQU     $FFFFB6                           ; Control Register B
182       FFFFB5           CRA0      EQU     $FFFFB5                           ; Control Register A
183    
184                        ; SSI Control Register A Bit Flags
185       000006           TDE       EQU     6                                 ; Set when transmitter data register is empty
186    
187                        ; Miscellaneous addresses
188       FFFFFF           RDFIFO    EQU     $FFFFFF                           ; Read the FIFO for incoming fiber optic data
189       FFFF8F           TCSR0     EQU     $FFFF8F                           ; Triper timer control and status register 0
190       FFFF8B           TCSR1     EQU     $FFFF8B                           ; Triper timer control and status register 1
191       FFFF87           TCSR2     EQU     $FFFF87                           ; Triper timer control and status register 2
192    
193                        ;***************************************************************
194                        ; Phase Locked Loop initialization
195       050003           PLL_INIT  EQU     $050003                           ; PLL = 25 MHz x 4 = 100 MHz
196                        ;****************************************************************
197    
198                        ; Port C is Enhanced Synchronous Serial Port 0
199       FFFFBF           PCRC      EQU     $FFFFBF                           ; Port C Control Register
200       FFFFBE           PRRC      EQU     $FFFFBE                           ; Port C Data direction Register
201       FFFFBD           PDRC      EQU     $FFFFBD                           ; Port C GPIO Data Register
202    
203                        ; Port D is Enhanced Synchronous Serial Port 1
204       FFFFAF           PCRD      EQU     $FFFFAF                           ; Port D Control Register
205       FFFFAE           PRRD      EQU     $FFFFAE                           ; Port D Data direction Register
206       FFFFAD           PDRD      EQU     $FFFFAD                           ; Port D GPIO Data Register
207    
208                        ; Bit number definitions of GPIO pins on Port C
209       000002           ROM_FIFO  EQU     2                                 ; Select ROM or FIFO accesses for AA1
210    
211                        ; Bit number definitions of GPIO pins on Port D
212       000000           EF        EQU     0                                 ; FIFO Empty flag, low true
213       000001           HF        EQU     1                                 ; FIFO half full flag, low true
214       000002           RS        EQU     2                                 ; FIFO reset signal, low true
215       000003           FSYNC     EQU     3                                 ; High during image transmission
216       000004           AUX1      EQU     4                                 ; enable/disable byte swapping
217       000005           WRFIFO    EQU     5                                 ; Low true if FIFO is being written to
218    
219    
220                        ; Errors - self test application
221    
222       000000           Y_MEM_ER  EQU     0                                 ; y memory corrupted
223       000001           X_MEM_ER  EQU     1                                 ; x memory corrupted
224       000002           P_MEM_ER  EQU     2                                 ; p memory corrupted
225       000003           FO_EMPTY  EQU     3                                 ; no transmitted data in FIFO
226    
227       000004           FO_OVER   EQU     4                                 ; too much data received
228       000005           FO_UNDER  EQU     5                                 ; not enough data receiv
229       000006           FO_RX_ER  EQU     6                                 ; received data in FIFO incorrect.
230       000007           DEBUG     EQU     7                                 ; debug bit
231    
232    
233    
234    
235                                  INCLUDE 'PCI_SCUBA_initialisation.asm'
236                              COMMENT *
237    
Motorola DSP56300 Assembler  Version 6.3.4   06-03-07  12:16:30  PCI_SCUBA_initialisation.asm  Page 5



238                        This is the code which is executed first after power-up etc.
239                        It sets all the internal registers to their operating values,
240                        sets up the ISR vectors and inialises the hardware etc.
241    
242                        Project:     SCUBA 2
243                        Author:      DAVID ATKINSON
244                        Target:      250MHz SDSU PCI card - DSP56301
245                        Controller:  For use with SCUBA 2 Multichannel Electronics
246    
247                        Assembler directives:
248                                ONCE=EEPROM => EEPROM CODE
249                                ONCE=ONCE => ONCE CODE
250    
251                                *
252                                  PAGE    132                               ; Printronix page width - 132 columns
253                                  OPT     CEX                               ; print DC evaluations
254    
**** 255 [PCI_SCUBA_initialisation.asm 20]:  INCLUDE PCI_initialisation.asm HERE  
255                                  MSG     ' INCLUDE PCI_initialisation.asm HERE  '
256    
257                        ; The EEPROM boot code expects first to read 3 bytes specifying the number of
258                        ; program words, then 3 bytes specifying the address to start loading the
259                        ; program words and then 3 bytes for each program word to be loaded.
260                        ; The program words will be condensed into 24 bit words and stored in contiguous
261                        ; PRAM memory starting at the specified starting address. Program execution
262                        ; starts from the same address where loading started.
263    
264                        ; Special address for two words for the DSP to bootstrap code from the EEPROM
265                                  IF      @SCP("ONCE","ROM")                ; Boot from ROM on power-on
272                                  ENDIF
273    
274    
275                        ; This allows for the DSP to be loaded from the ONCE port via the WIGGLER
276                        ; command converter
277                                  IF      @SCP("ONCE","ONCE")               ; Download via ONCE debugger
278       P:000000 P:000000                   ORG     P:0,P:0
279       P:000000 P:000000 0C0100  INIT      JMP     <START
280       P:000001 P:000001 000000            NOP
281                                           ENDIF
282    
283                                 ; Vectored interrupt table, addresses at the beginning are reserved
284  d    P:000002 P:000002 000000            DC      0,0,0,0,0,0,0,0,0,0,0,0,0,0       ; $02-$0f Reserved
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
285  d    P:000010 P:000010 000000            DC      0,0                               ; $10-$13 Reserved
     d                      000000
286    
287                                 ; FIFO HF* flag interrupt vector is here at $12 - this is connected to the
288                                 ; IRQB* interrupt line so its ISR vector must be here
289  d    P:000012 P:000012 000000            DC      0,0                               ; $was ld scatter routine ...HF*
     d                      000000
Motorola DSP56300 Assembler  Version 6.3.4   06-03-07  12:16:30  PCI_SCUBA_initialisation.asm  Page 6



290    
291                                 ; a software reset button on the font panel of the card is connected to the IRQC*
292                                 ; line which if pressed causes the DSP to jump to an ISR which causes the program
293                                 ; counter to the beginning of the program INIT and sets the stack pointer to TOP.
294       P:000014 P:000014 0BF080            JSR     CLEAN_UP_PCI                      ; $14 - Software reset switch
                            000227
295    
296  d    P:000016 P:000016 000000            DC      0,0,0,0,0,0,0,0,0,0,0,0           ; Reserved interrupts
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
297  d    P:000022 P:000022 000000            DC      0,0,0,0,0,0,0,0,0,0,0,0,0,0
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
298    
299                                 ; Now we're at P:$30, where some unused vector addresses are located
300                                 ; This is ROM only code that is only executed once on power-up when the
301                                 ; ROM code is downloaded. It is skipped over on OnCE downloads.
302    
303                                 ; A few seconds after power up on the Host, it interrogates the PCI bus to find
304                                 ; out what boards are installed and configures this PCI board. The EEPROM booting
305                                 ; procedure ends with program execution  starting at P:$0 where the EEPROM has
306                                 ; inserted a JMP INIT_PCI instruction. This routine sets the PLL paramter and
307                                 ; does a self configuration and software reset of the PCI controller in the DSP.
308                                 ; After configuring the PCI controller the DSP program overwrites the instruction
309                                 ; at P:$0 with a new JMP START to skip over the INIT_PCI routine. The program at
310                                 ; START address begins configuring the DSP and processing commands.
311                                 ; Similarly the ONCE option places a JMP START at P:$0 to skip over the
312                                 ; INIT_PCI routine. If this routine where executed after the host computer had booted
313                                 ; it would cause it to crash since the host computer would overwrite the
314                                 ; configuration space with its own values and doesn't tolerate foreign values.
315    
316                                 ; Initialize the PLL - phase locked loop
317                                 INIT_PCI
318       P:000030 P:000030 08F4BD            MOVEP             #PLL_INIT,X:PCTL        ; Initialize PLL
                            050003
319       P:000032 P:000032 000000            NOP
320    
321                                 ; Program the PCI self-configuration registers
322       P:000033 P:000033 240000            MOVE              #0,X0
323       P:000034 P:000034 08F485            MOVEP             #$500000,X:DCTR         ; Set self-configuration mode
                            500000
324       P:000036 P:000036 0604A0            REP     #4
Motorola DSP56300 Assembler  Version 6.3.4   06-03-07  12:16:30  PCI_SCUBA_initialisation.asm  Page 7



325       P:000037 P:000037 08C408            MOVEP             X0,X:DPAR               ; Dummy writes to configuration space
326       P:000038 P:000038 08F487            MOVEP             #>$0000,X:DPMC          ; Subsystem ID
                            000000
327       P:00003A P:00003A 08F488            MOVEP             #>$0000,X:DPAR          ; Subsystem Vendor ID
                            000000
328    
329                                 ; PCI Personal reset
330       P:00003C P:00003C 08C405            MOVEP             X0,X:DCTR               ; Personal software reset
331       P:00003D P:00003D 000000            NOP
332       P:00003E P:00003E 000000            NOP
333       P:00003F P:00003F 0A89B7            JSET    #HACT,X:DSR,*                     ; Test for personal reset completion
                            00003F
334       P:000041 P:000041 07F084            MOVE              P:(*+3),X0              ; Trick to write "JMP <START" to P:0
                            000044
335       P:000043 P:000043 070004            MOVE              X0,P:(0)
336       P:000044 P:000044 0C0100            JMP     <START
337    
338  d    P:000045 P:000045 000000            DC      0,0,0,0,0,0,0,0,0,0,0,0           ; Filler
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
339  d    P:000051 P:000051 000000            DC      0,0,0,0,0,0,0,0,0,0,0,0           ; Filler
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
340  d    P:00005D P:00005D 000000            DC      0,0,0,0,0,0,0,0,0,0,0,0           ; $60-$71 Reserved PCI
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
341    
342                                 ;**************************************************************************
343                                 ; Check for program space overwriting of ISR starting at P:$72
344                                           IF      @CVS(N,*)>$71
346                                           ENDIF
347    
348                                 ;       ORG     P:$72,P:$72
349       P:000072 P:000074                   ORG     P:$72,P:$74
350    
Motorola DSP56300 Assembler  Version 6.3.4   06-03-07  12:16:30  PCI_SCUBA_initialisation.asm  Page 8



351                                 ; This allows for the DSP to be loaded from the ONCE port via the WIGGLER
352                                 ; command converter
353                                           IF      @SCP("ONCE","ONCE")               ; Download via ONCE debugger
354       P:000072 P:000072                   ORG     P:$72,P:$72
355                                           ENDIF
356    
357    
358                                 ;**************************************************************************
359    
360                                 ; Three non-maskable fast interrupt service routines for clearing PCI interrupts
361                                 ; The Host will use these to clear the INTA* after it has serviced the interrupt
362                                 ; which had been generated by the PCI board.
363    
364       P:000072 P:000072 0A8506            BCLR    #INTA,X:DCTR                      ; $72/3 - Clear PCI interrupt
365       P:000073 P:000073 000000            NOP
366    
367       P:000074 P:000074 0A0004            BCLR    #INTA_FLAG,X:<STATUS              ; $74/5 - Clear PCI interrupt
368       P:000075 P:000075 000000            NOP                                       ; needs to be fast addressing <
369    
370       P:000076 P:000076 0A0022            BSET    #FATAL_ERROR,X:<STATUS            ; $76/7 - driver informing us of PCI_MESSAGE
_TO_HOST error
371       P:000077 P:000077 000000            NOP
372    
373                                 ; Interrupt locations for 7 available commands on PCI board
374                                 ; Each JSR takes up 2 locations in the table
375       P:000078 P:000078 0BF080            JSR     WRITE_MEMORY                      ; $78
                            00038E
376       P:00007A P:00007A 0BF080            JSR     READ_MEMORY                       ; $7A
                            000233
377       P:00007C P:00007C 0BF080            JSR     START_APPLICATION                 ; $7C
                            00034E
378       P:00007E P:00007E 0BF080            JSR     STOP_APPLICATION                  ; $7E
                            000366
379                                 ; software reset is the same as cleaning up the PCI - use same routine
380                                 ; when HOST does a RESET then this routine is run
381       P:000080 P:000080 0BF080            JSR     SOFTWARE_RESET                    ; $80
                            000316
382       P:000082 P:000082 0BF080            JSR     SEND_PACKET_TO_CONTROLLER         ; $82
                            0002B0
383       P:000084 P:000084 0BF080            JSR     SEND_PACKET_TO_HOST               ; $84
                            0002F6
384       P:000086 P:000086 0BF080            JSR     RESET_CONTROLLER                  ; $86
                            000272
385    
386    
387                                 ; ***********************************************************************
388                                 ; For now have boot code starting from P:$100
389                                 ; just to make debugging tidier etc.
390    
391       P:000100 P:000102                   ORG     P:$100,P:$102
392    
393                                 ; This allows for the DSP to be loaded from the ONCE port via the WIGGLER
394                                 ; command converter
395                                           IF      @SCP("ONCE","ONCE")               ; Download via ONCE debugger
396       P:000100 P:000100                   ORG     P:$100,P:$100
397                                           ENDIF
398                                 ; ***********************************************************************
399    
400    
401    
402                                 ; ******************************************************************
403                                 ;
Motorola DSP56300 Assembler  Version 6.3.4   06-03-07  12:16:30  PCI_SCUBA_initialisation.asm  Page 9



404                                 ;       AA0 = RDFIFO* of incoming fiber optic data
405                                 ;       AA1 = EEPROM access
406                                 ;       AA2 = DRAM access
407                                 ;       AA3 = output to parallel data connector, for a video pixel clock
408                                 ;       $FFxxxx = Write to fiber optic transmitter
409                                 ;
410                                 ; ******************************************************************
411    
412    
413       P:000100 P:000100 08F487  START     MOVEP             #>$000001,X:DPMC
                            000001
414       P:000102 P:000102 0A8534            BSET    #20,X:DCTR                        ; HI32 mode = 1 => PCI
415       P:000103 P:000103 0A8515            BCLR    #21,X:DCTR
416       P:000104 P:000104 0A8516            BCLR    #22,X:DCTR
417       P:000105 P:000105 000000            NOP
418       P:000106 P:000106 0A8632            BSET    #MACE,X:DPCR                      ; Master access counter enable
419       P:000107 P:000107 000000            NOP
420       P:000108 P:000108 000000            NOP                                       ; End of PCI programming
421    
422    
423                                 ; Set operation mode register OMR to normal expanded
424       P:000109 P:000109 0500BA            MOVEC             #$0000,OMR              ; Operating Mode Register = Normal Expanded
425       P:00010A P:00010A 0500BB            MOVEC             #0,SP                   ; Reset the Stack Pointer SP
426    
427                                 ; Program the serial port ESSI0 = Port C for serial transmission to
428                                 ;   the timing board
429       P:00010B P:00010B 07F43F            MOVEP             #>0,X:PCRC              ; Software reset of ESSI0
                            000000
430                                 ;**********************************************************************
431       P:00010D P:00010D 07F435            MOVEP             #$00080B,X:CRA0         ; Divide 100.0 MHz by 24 to get 4.17 MHz
                            00080B
432                                                                                     ; DC0-CD4 = 0 for non-network operation
433                                                                                     ; WL0-WL2 = ALC = 0 for 2-bit data words
434                                                                                     ; SSC1 = 0 for SC1 not used
435                                 ;************************************************************************
436       P:00010F P:00010F 07F436            MOVEP             #$010120,X:CRB0         ; SCKD = 1 for internally generated clock
                            010120
437                                                                                     ; SHFD = 0 for MSB shifted first
438                                                                                     ; CKP = 0 for rising clock edge transitions
439                                                                                     ; TE0 = 1 to enable transmitter #0
440                                                                                     ; MOD = 0 for normal, non-networked mode
441                                                                                     ; FSL1 = 1, FSL0 = 0 for on-demand transmit
442       P:000111 P:000111 07F43F            MOVEP             #%101000,X:PCRC         ; Control Register (0 for GPIO, 1 for ESSI)
                            000028
443                                                                                     ; Set SCK0 = P3, STD0 = P5 to ESSI0
444                                 ;********************************************************************************
445       P:000113 P:000113 07F43E            MOVEP             #%111100,X:PRRC         ; Data Direction Register (0 for In, 1 for O
ut)
                            00003C
446       P:000115 P:000115 07F43D            MOVEP             #%000000,X:PDRC         ; Data Register - AUX3 = i/p, AUX1 not used
                            000000
447                                 ;***********************************************************************************
448                                 ; 250MHz
449                                 ; Conversion from software bits to schematic labels for Port C and D
450                                 ;       PC0 = SC00 = AUX3               PD0 = SC10 = EF*
451                                 ;       PC1 = SC01 = A/B* = input       PD1 = SC11 = HF*
452                                 ;       PC2 = SC02 = No connect         PD2 = SC12 = RS*
453                                 ;       PC3 = SCK0 = No connect         PD3 = SCK1 = NWRFIFO*
454                                 ;       PC4 = SRD0 = AUX1               PD4 = SRD1 = No connect (** in 50Mhz this was MODE selec
t for 16 or 32 bit FO)
455                                 ;       PC5 = STD0 = No connect         PD5 = STD1 = WRFIFO*
456                                 ; ***********************************************************************************
Motorola DSP56300 Assembler  Version 6.3.4   06-03-07  12:16:30  PCI_SCUBA_initialisation.asm  Page 10



457    
458    
459                                 ; ****************************************************************************
460                                 ; Program the serial port ESSI1 = Port D for general purpose I/O (GPIO)
461    
462       P:000117 P:000117 07F42F            MOVEP             #%000000,X:PCRD         ; Control Register (0 for GPIO, 1 for ESSI)
                            000000
463       P:000119 P:000119 07F42E            MOVEP             #%011100,X:PRRD         ; Data Direction Register (0 for In, 1 for O
ut)
                            00001C
464       P:00011B P:00011B 07F42D            MOVEP             #%011000,X:PDRD         ; Data Register - Pulse RS* low
                            000018
465       P:00011D P:00011D 060AA0            REP     #10
466       P:00011E P:00011E 000000            NOP
467       P:00011F P:00011F 07F42D            MOVEP             #%011100,X:PDRD         ; Data Register - Pulse RS* high
                            00001C
468    
469    
470                                 ; Program the SCI port to benign values
471       P:000121 P:000121 07F41F            MOVEP             #%000,X:PCRE            ; Port Control Register = GPIO
                            000000
472       P:000123 P:000123 07F41E            MOVEP             #%110,X:PRRE            ; Port Direction Register (0 = Input)
                            000006
473       P:000125 P:000125 07F41D            MOVEP             #%010,X:PDRE            ; Port Data Register
                            000002
474                                 ;       PE0 = RXD
475                                 ;       PE1 = TXD
476                                 ;       PE2 = SCLK
477    
478                                 ; Program the triple timer to assert TCI0 as an GPIO output = 1
479       P:000127 P:000127 07F40F            MOVEP             #$2800,X:TCSR0
                            002800
480       P:000129 P:000129 07F40B            MOVEP             #$2800,X:TCSR1
                            002800
481       P:00012B P:00012B 07F407            MOVEP             #$2800,X:TCSR2
                            002800
482    
483    
484                                 ; Program the address attribute pins AA0 to AA2. AA3 is not yet implemented.
485       P:00012D P:00012D 08F4B9            MOVEP             #$FFFC21,X:AAR0         ; Y = $FFF000 to $FFFFFF asserts Y:RDFIFO*
                            FFFC21
486       P:00012F P:00012F 08F4B8            MOVEP             #$008929,X:AAR1         ; P = $008000 to $00FFFF asserts AA1 low tru
e
                            008929
487       P:000131 P:000131 08F4B7            MOVEP             #$000122,X:AAR2         ; Y = $000800 to $7FFFFF accesses SRAM
                            000122
488    
489    
490                                 ; Program the DRAM memory access and addressing
491       P:000133 P:000133 08F4BB            MOVEP             #$020022,X:BCR          ; Bus Control Register
                            020022
492       P:000135 P:000135 08F4BA            MOVEP             #$893A05,X:DCR          ; DRAM Control Register
                            893A05
493    
494    
495                                 ; Clear all PCI error conditions
496       P:000137 P:000137 084E0A            MOVEP             X:DPSR,A
497       P:000138 P:000138 0140C2            OR      #$1FE,A
                            0001FE
498       P:00013A P:00013A 000000            NOP
499       P:00013B P:00013B 08CE0A            MOVEP             A,X:DPSR
500    
Motorola DSP56300 Assembler  Version 6.3.4   06-03-07  12:16:30  PCI_SCUBA_initialisation.asm  Page 11



501                                 ;--------------------------------------------------------------------
502                                 ; Enable one interrupt only: software reset switch
503       P:00013C P:00013C 08F4BF            MOVEP             #$0001C0,X:IPRC         ; IRQB priority = 1 (FIFO half full HF*)
                            0001C0
504                                                                                     ; IRQC priority = 2 (reset switch)
505       P:00013E P:00013E 05F439            MOVE              #$200,SR                ; Mask set up for reset switch only
                            000200
506    
507    
508                                 ;--------------------------------------------------------------------------
509                                 ; Initialize the fiber optic serial transmitter to zero
510       P:000140 P:000140 01B786            JCLR    #TDE,X:SSISR0,*
                            000140
511       P:000142 P:000142 07F43C            MOVEP             #$000000,X:TX00
                            000000
512    
513                                 ;--------------------------------------------------------------------
514    
515                                 ; clear DTXM - PCI master transmitter
516       P:000144 P:000144 0A862E            BSET    #CLRT,X:DPCR                      ; Clear the master transmitter DTXM
517       P:000145 P:000145 0A86AE            JSET    #CLRT,X:DPCR,*                    ; Wait for the clearing to be complete
                            000145
518    
519                                 ;----------------------------------------------------------------------
520                                 ; clear DRXR - PCI receiver
521    
522       P:000147 P:000147 0A8982  CLR0      JCLR    #SRRQ,X:DSR,CLR1                  ; Wait for the receiver to be empty
                            00014C
523       P:000149 P:000149 08440B            MOVEP             X:DRXR,X0               ; Read receiver to empty it
524       P:00014A P:00014A 000000            NOP
525       P:00014B P:00014B 0C0147            JMP     <CLR0
526                                 CLR1
527    
528                                 ;-----------------------------------------------------------------------------
529                                 ; copy parameter table from P memory into X memory
530    
531                                 ; but not word_count and num_dumped - don't want these reset by fatal error....
532                                 ; they will be reset by new packet or pci_reset ISR
533    
534    
535       P:00014C P:00014C 46F000            MOVE              X:WORD_COUNT,Y0         ; store packet word count
                            000006
536       P:00014E P:00014E 47F000            MOVE              X:NUM_DUMPED,Y1         ; store number dumped (after HST TO)
                            000007
537       P:000150 P:000150 45F000            MOVE              X:FRAME_COUNT,X1        ; store frame count
                            000001
538    
539                                 ; Move the table of constants from P: space to X: space
540       P:000152 P:000152 61F400            MOVE              #VAR_TBL_START,R1       ; Start of parameter table in P
                            000531
541       P:000154 P:000154 300000            MOVE              #VAR_TBL,R0             ; start of parameter table in X
542       P:000155 P:000155 064180            DO      #VAR_TBL_LENGTH,X_WRITE
                            000158
543       P:000157 P:000157 07D984            MOVE              P:(R1)+,X0
544       P:000158 P:000158 445800            MOVE              X0,X:(R0)+              ; Write the constants to X:
545                                 X_WRITE
546    
547    
548       P:000159 P:000159 467000            MOVE              Y0,X:WORD_COUNT         ; restore packet word count
                            000006
549       P:00015B P:00015B 477000            MOVE              Y1,X:NUM_DUMPED         ; restore number dumped (after HST TO)
                            000007
Motorola DSP56300 Assembler  Version 6.3.4   06-03-07  12:16:30  PCI_SCUBA_initialisation.asm  Page 12



550       P:00015D P:00015D 457000            MOVE              X1,X:FRAME_COUNT        ; restore frame count
                            000001
551    
552                                 ;-------------------------------------------------------------------------------
553                                 ; initialise some bits in STATUS
554    
555       P:00015F P:00015F 0A0000            BCLR    #APPLICATION_LOADED,X:<STATUS     ; clear application loaded flag
556       P:000160 P:000160 0A000C            BCLR    #APPLICATION_RUNNING,X:<STATUS    ; clear appliaction running flag
557                                                                                     ; (e.g. not running diagnostic application
558                                                                                     ;      in self_test_mode)
559    
560       P:000161 P:000161 0A0002            BCLR    #FATAL_ERROR,X:<STATUS            ; initialise fatal error flag.
561       P:000162 P:000162 0A0028            BSET    #PACKET_CHOKE,X:<STATUS           ; enable MCE packet choke
562                                                                                     ; HOST not informed of anything from MCE unt
il
563                                                                                     ; comms are opened by host with first CON co
mmand
564    
565       P:000163 P:000163 0A0006            BCLR    #PREAMBLE_ERROR,X:<STATUS         ; flag to let host know premable error
566    
567                                 ;------------------------------------------------------------------------------
568                                 ; disable FIFO HF* intererupt...not used anymore.
569    
570       P:000164 P:000164 08F4BF            MOVEP             #$0001C0,X:IPRC         ; Disable FIFO HF* interrupt
                            0001C0
571       P:000166 P:000166 05F439            MOVEC             #$200,SR                ; Mask level 1 interrupts
                            000200
572    
573                                 ;----------------------------------------------------------------------------
574                                 ; Disable Byte swapin - enabled after first command to MCE.
575                                 ; i.e after first 'CON'
576    
577       P:000168 P:000168 0A0005            BCLR    #BYTE_SWAP,X:<STATUS              ; flag to let host know byte swapping off
578       P:000169 P:000169 013D04            BCLR    #AUX1,X:PDRC                      ; enable disable
579    
580                                 ;-----------------------------------------------------------------------------
581                                 ; Here endth the initialisation code run after power up.
582                                 ; ----------------------------------------------------------------------------
583    
584    
585    
586    
587                                           INCLUDE 'PCI_SCUBA_main.asm'
588                                  COMMENT *
589    
590                                 This is the main section of the pci card code.
591    
592                                 Project:     SCUBA 2
593                                 Author:      DAVID ATKINSON
594                                 Target:      250MHz SDSU PCI card - DSP56301
595                                 Controller:  For use with SCUBA 2 Multichannel Electronics
596    
597                                 Version:     Release Version A (1.4)
598    
599    
600                                 Assembler directives:
601                                         ONCE=EEPROM => EEPROM CODE
602                                         ONCE=ONCE => ONCE CODE
603    
604                                         *
605                                           PAGE    132                               ; Printronix page width - 132 columns
606                                           OPT     CEX                               ; print DC evaluations
Motorola DSP56300 Assembler  Version 6.3.4   06-03-07  12:16:30  PCI_SCUBA_main.asm  Page 13



607    
**** 608 [PCI_SCUBA_main.asm 21]:  INCLUDE PCI_main.asm HERE  
608                                           MSG     ' INCLUDE PCI_main.asm HERE  '
609    
610                                 ; --------------------------------------------------------------------------
611                                 ; --------------------- MAIN PACKET HANDLING CODE --------------------------
612                                 ; --------------------------------------------------------------------------
613    
614                                 ; initialse buffer pointers
615                                 PACKET_IN
616    
617                                 ; R1 used as pointer for data written to y:memory            FO --> (Y)
618                                 ; R2 used as pointer for date in y mem to be writen to host  (Y) --> HOST
619    
620       P:00016A P:00016A 310000            MOVE              #<IMAGE_BUFFER,R1       ; pointer for Fibre ---> Y mem
621       P:00016B P:00016B 320000            MOVE              #<IMAGE_BUFFER,R2       ; pointer for Y mem ---> PCI BUS
622    
623                                 ; initialise some bits in status..
624       P:00016C P:00016C 0A0001            BCLR    #SEND_TO_HOST,X:<STATUS           ; clear send to host flag
625       P:00016D P:00016D 0A0009            BCLR    #HST_NFYD,X:<STATUS               ; clear flag to indicate host has been notif
ied.
626       P:00016E P:00016E 0A0003            BCLR    #FO_WRD_RCV,X:<STATUS             ; clear Fiber Optic flag
627    
628                                 ; check some bits in status....
629       P:00016F P:00016F 0A00A2            JSET    #FATAL_ERROR,X:<STATUS,START      ; fatal error?  Go to initialisation.
                            000100
630       P:000171 P:000171 0A00A0            JSET    #APPLICATION_LOADED,X:<STATUS,APPLICATION ; application loaded?  Execute in ap
pl space.
                            000800
631       P:000173 P:000173 0A00AD            JSET    #INTERNAL_GO,X:<STATUS,APPLICATION ; internal GO to process?  PCI bus master w
rite test.
                            000800
632    
633       P:000175 P:000175 0D03FA  CHK_FIFO  JSR     <GET_FO_WRD                       ; see if there's a 16-bit word in Fibre FIFO
 from MCE
634    
635    
636       P:000176 P:000176 0A00A3            JSET    #FO_WRD_RCV,X:<STATUS,CHECK_WD    ; there is a word - check if it's preamble
                            000179
637       P:000178 P:000178 0C016A            JMP     <PACKET_IN                        ; else go back and repeat
638    
639                                 ; check that we preamble sequence
640    
641       P:000179 P:000179 0A00A8  CHECK_WD  JSET    #PACKET_CHOKE,X:<STATUS,PACKET_IN ; IF MCE Packet choke on - just keep clearin
g FIFO.
                            00016A
642       P:00017B P:00017B 441D00            MOVE              X0,X:<HEAD_W1_0         ;store received word
643       P:00017C P:00017C 56F000            MOVE              X:PREAMB1,A
                            000038
644       P:00017E P:00017E 200045            CMP     X0,A                              ; check it is correct
645       P:00017F P:00017F 0E2193            JNE     <PRE_ERROR                        ; if not go to start
646    
647    
648       P:000180 P:000180 0D0402            JSR     <WT_FIFO                          ; wait for next preamble 16-bit word
649       P:000181 P:000181 441C00            MOVE              X0,X:<HEAD_W1_1         ;store received word
650       P:000182 P:000182 56F000            MOVE              X:PREAMB1,A
                            000038
651       P:000184 P:000184 200045            CMP     X0,A                              ; check it is correct
652       P:000185 P:000185 0E2193            JNE     <PRE_ERROR                        ; if not go to start
653    
654    
655       P:000186 P:000186 0D0402            JSR     <WT_FIFO                          ; wait for next preamble 16-bit word
Motorola DSP56300 Assembler  Version 6.3.4   06-03-07  12:16:30  PCI_SCUBA_main.asm  Page 14



656       P:000187 P:000187 441F00            MOVE              X0,X:<HEAD_W2_0         ;store received word
657       P:000188 P:000188 56F000            MOVE              X:PREAMB2,A
                            000039
658       P:00018A P:00018A 200045            CMP     X0,A                              ; check it is correct
659       P:00018B P:00018B 0E2193            JNE     <PRE_ERROR                        ; if not go to start
660    
661       P:00018C P:00018C 0D0402            JSR     <WT_FIFO                          ; wait for next preamble 16-bit word
662       P:00018D P:00018D 441E00            MOVE              X0,X:<HEAD_W2_1         ;store received word
663       P:00018E P:00018E 56F000            MOVE              X:PREAMB2,A
                            000039
664       P:000190 P:000190 200045            CMP     X0,A                              ; check it is correct
665       P:000191 P:000191 0E2193            JNE     <PRE_ERROR                        ; if not go to start
666       P:000192 P:000192 0C019F            JMP     <PACKET_INFO                      ; get packet info
667    
668    
669                                 PRE_ERROR
670       P:000193 P:000193 0A0026            BSET    #PREAMBLE_ERROR,X:<STATUS         ; indicate a preamble error
671       P:000194 P:000194 440200            MOVE              X0,X:<PRE_CORRUPT       ; store corrupted word
672    
673                                 ; preampble error so clear out both FIFOs using reset line
674                                 ; - protects against an odd number of bytes having been sent
675                                 ; (byte swapping on - so odd byte being would end up in
676                                 ; the FIFO without the empty flag)
677    
678       P:000195 P:000195 07F42D            MOVEP             #%011000,X:PDRD         ; clear FIFO RESET* for 2 ms
                            000018
679       P:000197 P:000197 44F400            MOVE              #200000,X0
                            030D40
680       P:000199 P:000199 06C400            DO      X0,*+3
                            00019B
681       P:00019B P:00019B 000000            NOP
682       P:00019C P:00019C 07F42D            MOVEP             #%011100,X:PDRD
                            00001C
683    
684       P:00019E P:00019E 0C016A            JMP     <PACKET_IN                        ; wait for next packet
685    
686    
687                                 PACKET_INFO                                         ; packet preamble valid
688    
689                                 ; Packet preamle is valid so....
690                                 ; now get next two 32bit words.  i.e. $20205250 $00000004, or $20204441 $xxxxxxxx
691                                 ; note that these are received little endian (and byte swapped)
692                                 ; i.e. for RP receive 50 52 20 20  04 00 00 00
693                                 ; but byte swapped on arrival
694                                 ; 5250
695                                 ; 2020
696                                 ; 0004
697                                 ; 0000
698    
699       P:00019F P:00019F 0D0402            JSR     <WT_FIFO
700       P:0001A0 P:0001A0 442100            MOVE              X0,X:<HEAD_W3_0         ; RP or DA
701       P:0001A1 P:0001A1 0D0402            JSR     <WT_FIFO
702       P:0001A2 P:0001A2 442000            MOVE              X0,X:<HEAD_W3_1         ; $2020
703    
704       P:0001A3 P:0001A3 0D0402            JSR     <WT_FIFO
705       P:0001A4 P:0001A4 442300            MOVE              X0,X:<HEAD_W4_0         ; packet size lo
706       P:0001A5 P:0001A5 0D0402            JSR     <WT_FIFO
707       P:0001A6 P:0001A6 442200            MOVE              X0,X:<HEAD_W4_1         ; packet size hi
708    
709       P:0001A7 P:0001A7 44A100            MOVE              X:<HEAD_W3_0,X0         ; get data header word 3 (low 2 bytes)
710       P:0001A8 P:0001A8 56BB00            MOVE              X:<REPLY_WD,A           ; $5250
711       P:0001A9 P:0001A9 200045            CMP     X0,A                              ; is it a reply packet?
Motorola DSP56300 Assembler  Version 6.3.4   06-03-07  12:16:30  PCI_SCUBA_main.asm  Page 15



712       P:0001AA P:0001AA 0AF0AA            JEQ     MCE_PACKET                        ; yes - go process it.
                            0001BE
713    
714       P:0001AC P:0001AC 56BA00            MOVE              X:<DATA_WD,A            ; $4441
715       P:0001AD P:0001AD 200045            CMP     X0,A                              ; is it a data packet?
716       P:0001AE P:0001AE 0E216A            JNE     <PACKET_IN                        ; no?  Not a valid packet type.  Go back to 
start and resync to next preamble.
717    
718    
719                                 ; It's a data packet....
720                                 ; check if it's the first packet after the GO command has been issued...
721    
722       P:0001AF P:0001AF 0A0087            JCLR    #DATA_DLY,X:STATUS,INC_FRAME_COUNT ; do we need to add a delay since first fra
me?
                            0001B9
723    
724                                 ; yes first frame after GO reply packet so add a delay.
725                                 PACKET_DELAY
726       P:0001B1 P:0001B1 44F000            MOVE              X:DATA_DLY_VAL,X0
                            000040
727       P:0001B3 P:0001B3 06C400            DO      X0,*+3                            ; 10ns x DATA_DLY_VAL
                            0001B5
728       P:0001B5 P:0001B5 000000            NOP
729       P:0001B6 P:0001B6 000000            NOP
730       P:0001B7 P:0001B7 0A7007            BCLR    #DATA_DLY,X:STATUS                ; clear so delay isn't added next time.
                            000000
731    
732    
733                                 INC_FRAME_COUNT                                     ; increment frame count
734       P:0001B9 P:0001B9 200013            CLR     A
735       P:0001BA P:0001BA 508100            MOVE              X:<FRAME_COUNT,A0
736       P:0001BB P:0001BB 000008            INC     A
737       P:0001BC P:0001BC 000000            NOP
738       P:0001BD P:0001BD 500100            MOVE              A0,X:<FRAME_COUNT
739    
740                                 ; -------------------------------------------------------------------------------------------
741                                 ; ----------------------------------- IT'S A PAKCET FROM MCE --------------------------------
742                                 ; -------------------------------------------------------------------------------------------
743                                 ; prepare notify to inform host that a packet has arrived.
744    
745                                 MCE_PACKET
746       P:0001BE P:0001BE 44F400            MOVE              #'NFY',X0               ; initialise communication to host as a noti
fy
                            4E4659
747       P:0001C0 P:0001C0 440C00            MOVE              X0,X:<DTXS_WD1          ; 1st word transmitted to host in notify mes
sage
748    
749       P:0001C1 P:0001C1 44A100            MOVE              X:<HEAD_W3_0,X0         ;RP or DA - top two bytes of word 3 ($2020) 
not passed to driver.
750       P:0001C2 P:0001C2 440D00            MOVE              X0,X:<DTXS_WD2          ;2nd word transmitted to host in notify mess
age
751    
752       P:0001C3 P:0001C3 44A300            MOVE              X:<HEAD_W4_0,X0         ; size of packet LSB 16bits (# 32bit words)
753       P:0001C4 P:0001C4 440E00            MOVE              X0,X:<DTXS_WD3          ; 3rd word transmitted to host in notify mes
sage
754    
755       P:0001C5 P:0001C5 44A200            MOVE              X:<HEAD_W4_1,X0         ; size of packet MSB 16bits (# of 32bit word
s)
756       P:0001C6 P:0001C6 440F00            MOVE              X0,X:<DTXS_WD4          ; 4th word transmitted to host in notify mes
sasge
757    
758       P:0001C7 P:0001C7 200013            CLR     A                                 ;
Motorola DSP56300 Assembler  Version 6.3.4   06-03-07  12:16:30  PCI_SCUBA_main.asm  Page 16



759       P:0001C8 P:0001C8 340000            MOVE              #0,R4                   ; initialise word count
760       P:0001C9 P:0001C9 560600            MOVE              A,X:<WORD_COUNT         ; initialise word count store (num of words 
written over bus/packet)
761       P:0001CA P:0001CA 560700            MOVE              A,X:<NUM_DUMPED         ; initialise number dumped from FIFO (after 
HST TO)
762    
763    
764                                 ; ----------------------------------------------------------------------------------------------
------------
765                                 ; Determine how to break up packet to write to host
766    
767                                 ; Note that this SR uses accumulator B
768                                 ; Therefore execute before we get the bus address from host (which is stored in B)
769                                 ; i.e before we issue notify message ('NFY')
770    
771       P:0001CB P:0001CB 0D03CB            JSR     <CALC_NO_BUFFS                    ; subroutine which calculates the number of 
512 (16bit) buffers
772                                                                                     ; number of left over 32 (16bit) blocks
773                                                                                     ; and number of left overs (16bit) words
774    
775                                 ;  note that a 512 (16-bit) buffer is transfered to the host as 4 x 64 x 32bit DMA burst
776                                 ;            a 32  (16-bit) block is transfered to the host as a    16 x 32bit DMA burst
777                                 ;            left over 16bit words are transfered to the host in pairs as 32bit words
778                                 ; ----------------------------------------------------------------------------------------------
---
779    
780    
781                                 ; notify the host that there is a packet.....
782    
783       P:0001CC P:0001CC 0D0435            JSR     <PCI_MESSAGE_TO_HOST              ; notify host of packet
784       P:0001CD P:0001CD 0A0029            BSET    #HST_NFYD,X:<STATUS               ; flag to indicate host has been notified.
785       P:0001CE P:0001CE 0A00A2  WT_HOST   JSET    #FATAL_ERROR,X:<STATUS,START      ; if fatal error - run initialisation code..
.
                            000100
786       P:0001D0 P:0001D0 0A0081            JCLR    #SEND_TO_HOST,X:<STATUS,WT_HOST   ; wait for host to reply - which it does wit
h 'send_packet_to_host' ISR
                            0001CE
787    
788    
789                                 ; we now have 32 bit address in accumulator B
790                                 ; from send-packet_to_host
791    
792                                 ; ----------------------------------------------------------------------------------------------
-----------
793                                 ; Write TOTAL_BUFFS * 512 buffers to host
794                                 ; ----------------------------------------------------------------------------------------------
------
795       P:0001D2 P:0001D2 063C00            DO      X:<TOTAL_BUFFS,ALL_BUFFS_END      ; note that if TOTAL_BUFFS = 0 we jump to AL
L_BUFFS_END
                            0001E2
796    
797       P:0001D4 P:0001D4 310000            MOVE              #<IMAGE_BUFFER,R1       ; FO ---> Y mem
798       P:0001D5 P:0001D5 320000            MOVE              #<IMAGE_BUFFER,R2       ; Y mem ----->  PCI BUS
799    
800    
801       P:0001D6 P:0001D6 0A00A2  WAIT_BUFF JSET    #FATAL_ERROR,X:<STATUS,DUMP_FIFO  ; if fatal error then dump fifo and reset (i
.e. if HST timeout)
                            000213
802       P:0001D8 P:0001D8 01ADA1            JSET    #HF,X:PDRD,WAIT_BUFF              ; Wait for FIFO to be half full + 1
                            0001D6
803       P:0001DA P:0001DA 000000            NOP
804       P:0001DB P:0001DB 000000            NOP
Motorola DSP56300 Assembler  Version 6.3.4   06-03-07  12:16:30  PCI_SCUBA_main.asm  Page 17



805       P:0001DC P:0001DC 01ADA1            JSET    #HF,X:PDRD,WAIT_BUFF              ; Protection against metastability
                            0001D6
806    
807    
808                                 ; Copy the image block as 512 x 16bit words to DSP Y: Memory using R1 as pointer
809       P:0001DE P:0001DE 060082            DO      #512,L_BUFFER
                            0001E0
810       P:0001E0 P:0001E0 0959FF            MOVEP             Y:RDFIFO,Y:(R1)+
811                                 L_BUFFER
812    
813    
814                                 ; R2 points to data in Y memory to be written to host
815                                 ; host address is in B - got by SEND_PACKET_TO_HOST command
816                                 ; so we can now write this buffer to host
817    
818       P:0001E1 P:0001E1 0D04EA            JSR     <WRITE_512_TO_PCI                 ; this subroutine will increment host addres
s, which is in B and R2
819       P:0001E2 P:0001E2 000000            NOP
820                                 ALL_BUFFS_END                                       ; all buffers have been writen to host
821    
822                                 ; ----------------------------------------------------------------------------------------------
-----------
823                                 ; Write NUM_LEFTOVER_BLOCKS * 32 blocks to host
824                                 ; ----------------------------------------------------------------------------------------------
------
825    
826                                 ; less than 512 pixels but if greater than 32 will then do bursts
827                                 ; of 16 x 32bit in length, if less than 32 then does single read writes
828    
829       P:0001E3 P:0001E3 063F00            DO      X:<NUM_LEFTOVER_BLOCKS,LEFTOVER_BLOCKS ;note that if NUM_LEFOVERS_BLOCKS = 0 w
e jump to LEFTOVER_BLOCKS
                            0001F3
830    
831    
832       P:0001E5 P:0001E5 310000            MOVE              #<IMAGE_BUFFER,R1       ; FO ---> Y mem
833       P:0001E6 P:0001E6 320000            MOVE              #<IMAGE_BUFFER,R2       ; Y mem ----->  PCI BUS
834    
835       P:0001E7 P:0001E7 062080            DO      #32,S_BUFFER
                            0001F1
836       P:0001E9 P:0001E9 0A00A2  WAIT_1    JSET    #FATAL_ERROR,X:<STATUS,DUMP_FIFO  ; check for fatal error (i.e. after HST time
out)
                            000213
837       P:0001EB P:0001EB 01AD80            JCLR    #EF,X:PDRD,WAIT_1                 ; Wait for the pixel datum to be there
                            0001E9
838       P:0001ED P:0001ED 000000            NOP                                       ; Settling time
839       P:0001EE P:0001EE 000000            NOP
840       P:0001EF P:0001EF 01AD80            JCLR    #EF,X:PDRD,WAIT_1                 ; Protection against metastability
                            0001E9
841       P:0001F1 P:0001F1 0959FF            MOVEP             Y:RDFIFO,Y:(R1)+        ; save fibre word
842                                 S_BUFFER
843    
844       P:0001F2 P:0001F2 0D04BF            JSR     <WRITE_32_TO_PCI                  ; write small blocks
845       P:0001F3 P:0001F3 000000            NOP
846                                 LEFTOVER_BLOCKS
847    
848                                 ; ----------------------------------------------------------------------------------------------
-------
849                                 ; Single write left over words to host
850                                 ; ----------------------------------------------------------------------------------------------
------
851    
852                                 LEFT_OVERS
Motorola DSP56300 Assembler  Version 6.3.4   06-03-07  12:16:30  PCI_SCUBA_main.asm  Page 18



853       P:0001F4 P:0001F4 310000            MOVE              #<IMAGE_BUFFER,R1       ; FO ---> Y mem
854       P:0001F5 P:0001F5 320000            MOVE              #<IMAGE_BUFFER,R2       ; Y mem ----->  PCI BUS
855    
856       P:0001F6 P:0001F6 063D00            DO      X:<LEFT_TO_READ,LEFT_OVERS_READ   ; read in remaining words of data packet
                            000200
857                                                                                     ; if LEFT_TO_READ = 0 then will jump to LEFT
_OVERS_READ
858    
859       P:0001F8 P:0001F8 0A00A2  WAIT_2    JSET    #FATAL_ERROR,X:<STATUS,START      ; check for fatal error (i.e. after HST time
out)
                            000100
860       P:0001FA P:0001FA 01AD80            JCLR    #EF,X:PDRD,WAIT_2                 ; Wait till something in FIFO flagged
                            0001F8
861       P:0001FC P:0001FC 000000            NOP
862       P:0001FD P:0001FD 000000            NOP
863       P:0001FE P:0001FE 01AD80            JCLR    #EF,X:PDRD,WAIT_2                 ; protect against metastability.....
                            0001F8
864       P:000200 P:000200 0959FF            MOVEP             Y:RDFIFO,Y:(R1)+        ; save fibre word
865                                 LEFT_OVERS_READ
866    
867                                 ; now write left overs to host as 32 bit words
868    
869       P:000201 P:000201 063E00            DO      X:LEFT_TO_WRITE,LEFT_OVERS_WRITEN ; left overs to write is half left overs rea
d - since 32 bit writes
                            000204
870                                                                                     ; if LEFT_TO_WRITE = 0, will jump to LEFT_OV
ERS_WRITTEN
871       P:000203 P:000203 0BF080            JSR     WRITE_TO_PCI                      ; uses R2 as pointer to Y memory, host addre
ss in B
                            00049E
872                                 LEFT_OVERS_WRITEN
873    
874    
875                                 ; ----------------------------------------------------------------------------------------------
------------
876                                 ; reply to host's send_packet_to_host command
877    
878                                  HST_ACK_REP
879       P:000205 P:000205 44F400            MOVE              #'REP',X0
                            524550
880       P:000207 P:000207 440C00            MOVE              X0,X:<DTXS_WD1          ; REPly
881       P:000208 P:000208 44F400            MOVE              #'HST',X0
                            485354
882       P:00020A P:00020A 440D00            MOVE              X0,X:<DTXS_WD2          ; echo command sent
883       P:00020B P:00020B 44F400            MOVE              #'ACK',X0
                            41434B
884       P:00020D P:00020D 440E00            MOVE              X0,X:<DTXS_WD3          ; ACKnowledge okay
885       P:00020E P:00020E 44F400            MOVE              #'000',X0
                            303030
886       P:000210 P:000210 440F00            MOVE              X0,X:<DTXS_WD4          ; no error
887       P:000211 P:000211 0D0435            JSR     <PCI_MESSAGE_TO_HOST
888       P:000212 P:000212 0C016A            JMP     <PACKET_IN
889    
890                                 ;-----------------------------------------------------------------------------------------------
----
891                                 ; clear out the fifo after an HST timeout...
892                                 ;----------------------------------------------------------
893    
894       P:000213 P:000213 61F400  DUMP_FIFO MOVE              #DUMP_BUFF,R1           ; address where dumped words stored in Y mem
                            000200
895       P:000215 P:000215 44F400            MOVE              #MAX_DUMP,X0            ; put a limit to number of words read from f
ifo
Motorola DSP56300 Assembler  Version 6.3.4   06-03-07  12:16:30  PCI_SCUBA_main.asm  Page 19



                            000200
896       P:000217 P:000217 200013            CLR     A
897       P:000218 P:000218 320000            MOVE              #0,R2                   ; use R2 as a dump count
898    
899       P:000219 P:000219 01AD80  NEXT_DUMP JCLR    #EF,X:PDRD,FIFO_EMPTY
                            000224
900       P:00021B P:00021B 000000            NOP
901       P:00021C P:00021C 000000            NOP
902       P:00021D P:00021D 01AD80            JCLR    #EF,X:PDRD,FIFO_EMPTY
                            000224
903    
904       P:00021F P:00021F 0959FF            MOVEP             Y:RDFIFO,Y:(R1)+        ; dump word to Y mem.
905       P:000220 P:000220 205A00            MOVE              (R2)+                   ; inc dump count
906       P:000221 P:000221 224E00            MOVE              R2,A                    ;
907       P:000222 P:000222 200045            CMP     X0,A                              ; check we've not hit dump limit
908       P:000223 P:000223 0E2219            JNE     NEXT_DUMP                         ; not hit limit?
909    
910    
911       P:000224 P:000224 627000  FIFO_EMPTY MOVE             R2,X:NUM_DUMPED         ; store number of words dumped after HST tim
eout.
                            000007
912       P:000226 P:000226 0C0100            JMP     <START                            ; re-initialise
913    
914    
915    
916                                 ; ----------------------------------------------------------------------------------------------
--
917                                 ;                              END OF MAIN PACKET HANDLING CODE
918                                 ; ---------------------------------------------------------------------------------------------
919    
920    
921                                 ; -------------------------------------------------------------------------------------
922                                 ;
923                                 ;                              INTERRUPT SERVICE ROUTINES
924                                 ;
925                                 ; ---------------------------------------------------------------------------------------
926    
927                                 ;--------------------------------------------------------------------
928                                 CLEAN_UP_PCI
929                                 ;--------------------------------------------------------------------
930                                 ; Clean up the PCI board from wherever it was executing
931    
932       P:000227 P:000227 08F4BF            MOVEP             #$0001C0,X:IPRC         ; Disable HF* FIFO interrupt
                            0001C0
933       P:000229 P:000229 05F439            MOVE              #$200,SR                ; mask for reset interrupts only
                            000200
934    
935       P:00022B P:00022B 0501BB            MOVEC             #1,SP                   ; Point stack pointer to the top
936       P:00022C P:00022C 05F43D            MOVEC             #$000200,SSL            ; SR = zero except for interrupts
                            000200
937       P:00022E P:00022E 0500BB            MOVEC             #0,SP                   ; Writing to SSH preincrements the SP
938       P:00022F P:00022F 05F43C            MOVEC             #START,SSH              ; Set PC to for full initialization
                            000100
939       P:000231 P:000231 000000            NOP
940       P:000232 P:000232 000004            RTI
941    
942                                 ; ---------------------------------------------------------------------------
943                                 READ_MEMORY
944                                 ;--------------------------------------------------------------------------
945                                 ; word 1 = command = 'RDM'
946                                 ; word 2 = memory type, P=$00'_P', X=$00_'X' or Y=$00_'Y'
947                                 ; word 3 = address in memory
Motorola DSP56300 Assembler  Version 6.3.4   06-03-07  12:16:30  PCI_SCUBA_main.asm  Page 20



948                                 ; word 4 = not used
949    
950       P:000233 P:000233 0D0492            JSR     <SAVE_REGISTERS                   ; save working registers
951    
952       P:000234 P:000234 0D0450            JSR     <RD_DRXR                          ; read words from host write to HTXR
953       P:000235 P:000235 56F000            MOVE              X:DRXR_WD1,A            ; read command
                            000008
954       P:000237 P:000237 44F400            MOVE              #'RDM',X0
                            52444D
955       P:000239 P:000239 200045            CMP     X0,A                              ; ensure command is 'RDM'
956       P:00023A P:00023A 0E225E            JNE     <READ_MEMORY_ERROR_CNE            ; error, command NOT HCVR address
957       P:00023B P:00023B 568900            MOVE              X:<DRXR_WD2,A           ; Memory type (X, Y, P)
958       P:00023C P:00023C 578A00            MOVE              X:<DRXR_WD3,B
959       P:00023D P:00023D 000000            NOP                                       ; pipeline restriction
960       P:00023E P:00023E 21B000            MOVE              B1,R0                   ; get address to write to
961       P:00023F P:00023F 0140C5            CMP     #$005F50,A                        ; $00'_P'
                            005F50
962       P:000241 P:000241 0E2245            JNE     <RDX
963       P:000242 P:000242 07E084            MOVE              P:(R0),X0               ; Read from P memory
964       P:000243 P:000243 208E00            MOVE              X0,A                    ;
965       P:000244 P:000244 0C0250            JMP     <FINISH_READ_MEMORY
966                                 RDX
967       P:000245 P:000245 0140C5            CMP     #$005F58,A                        ; $00'_X'
                            005F58
968       P:000247 P:000247 0E224B            JNE     <RDY
969       P:000248 P:000248 44E000            MOVE              X:(R0),X0               ; Read from P memory
970       P:000249 P:000249 208E00            MOVE              X0,A
971       P:00024A P:00024A 0C0250            JMP     <FINISH_READ_MEMORY
972                                 RDY
973       P:00024B P:00024B 0140C5            CMP     #$005F59,A                        ; $00'_Y'
                            005F59
974       P:00024D P:00024D 0E2263            JNE     <READ_MEMORY_ERROR_MTE            ; not a valid memory type
975       P:00024E P:00024E 4CE000            MOVE                          Y:(R0),X0   ; Read from P memory
976       P:00024F P:00024F 208E00            MOVE              X0,A
977    
978                                 ; when completed successfully then PCI needs to reply to Host with
979                                 ; word1 = reply/data = reply
980                                 FINISH_READ_MEMORY
981       P:000250 P:000250 44F400            MOVE              #'REP',X0
                            524550
982       P:000252 P:000252 440C00            MOVE              X0,X:<DTXS_WD1          ; REPly
983       P:000253 P:000253 44F400            MOVE              #'RDM',X0
                            52444D
984       P:000255 P:000255 440D00            MOVE              X0,X:<DTXS_WD2          ; echo command sent
985       P:000256 P:000256 44F400            MOVE              #'ACK',X0
                            41434B
986       P:000258 P:000258 440E00            MOVE              X0,X:<DTXS_WD3          ;  im command
987       P:000259 P:000259 21C400            MOVE              A,X0
988       P:00025A P:00025A 440F00            MOVE              X0,X:<DTXS_WD4          ; write to PCI memory error
989       P:00025B P:00025B 0D047D            JSR     <RESTORE_REGISTERS                ; restore registers
990       P:00025C P:00025C 0D0435            JSR     <PCI_MESSAGE_TO_HOST              ; interrupt host with message (x0 restored h
ere)
991       P:00025D P:00025D 000004            RTI
992    
993                                 READ_MEMORY_ERROR_CNE
994       P:00025E P:00025E 44F400            MOVE              #'CNE',X0
                            434E45
995       P:000260 P:000260 440F00            MOVE              X0,X:<DTXS_WD4          ; Command Name Error - command name in DRXR 
does not match
996       P:000261 P:000261 0AF080            JMP     READ_MEMORY_ERROR                 ; fill in rest of reply
                            000266
997                                 READ_MEMORY_ERROR_MTE
Motorola DSP56300 Assembler  Version 6.3.4   06-03-07  12:16:30  PCI_SCUBA_main.asm  Page 21



998       P:000263 P:000263 44F400            MOVE              #'MTE',X0
                            4D5445
999       P:000265 P:000265 440F00            MOVE              X0,X:<DTXS_WD4          ;  Memory Type Error - not a valid memory ty
pe
1000   
1001                                READ_MEMORY_ERROR
1002      P:000266 P:000266 44F400            MOVE              #'REP',X0
                            524550
1003      P:000268 P:000268 440C00            MOVE              X0,X:<DTXS_WD1          ; REPly
1004      P:000269 P:000269 44F400            MOVE              #'RDM',X0
                            52444D
1005      P:00026B P:00026B 440D00            MOVE              X0,X:<DTXS_WD2          ; echo command sent
1006      P:00026C P:00026C 44F400            MOVE              #'ERR',X0
                            455252
1007      P:00026E P:00026E 440E00            MOVE              X0,X:<DTXS_WD3          ; ERRor.
1008      P:00026F P:00026F 0D047D            JSR     <RESTORE_REGISTERS                ; restore working registers
1009      P:000270 P:000270 0D0435            JSR     <PCI_MESSAGE_TO_HOST              ; interrupt host with message (x0 restored h
ere)
1010      P:000271 P:000271 000004            RTI
1011   
1012                                ;-----------------------------------------------------------------------------
1013                                RESET_CONTROLLER
1014                                ; Reset the controller by sending a special code byte $0B with SC/nData = 1
1015                                ;---------------------------------------------------------------------------
1016                                ; word 1 = command = 'RCO'
1017                                ; word 2 = not used but read
1018                                ; word 3 = not used but read
1019                                ; word 4 = not used but read
1020   
1021      P:000272 P:000272 0D0492            JSR     <SAVE_REGISTERS                   ; save working registers
1022      P:000273 P:000273 0D0450            JSR     <RD_DRXR                          ; read words from host write to HTXR
1023      P:000274 P:000274 568800            MOVE              X:<DRXR_WD1,A           ; read command
1024      P:000275 P:000275 44F400            MOVE              #'RCO',X0
                            52434F
1025      P:000277 P:000277 200045            CMP     X0,A                              ; ensure command is 'RCO'
1026      P:000278 P:000278 0E229D            JNE     <RCO_ERROR                        ; error, command NOT HCVR address
1027   
1028                                ; if we get here then everything is fine and we can send reset to controller
1029   
1030                                ; 250MHZ CODE....
1031   
1032      P:000279 P:000279 011D22            BSET    #SCLK,X:PDRE                      ; Enable special command mode
1033      P:00027A P:00027A 000000            NOP
1034      P:00027B P:00027B 000000            NOP
1035      P:00027C P:00027C 60F400            MOVE              #$FFF000,R0             ; Memory mapped address of transmitter
                            FFF000
1036      P:00027E P:00027E 44F400            MOVE              #$10000B,X0             ; Special command to reset controller
                            10000B
1037      P:000280 P:000280 446000            MOVE              X0,X:(R0)
1038      P:000281 P:000281 0606A0            REP     #6                                ; Wait for transmission to complete
1039      P:000282 P:000282 000000            NOP
1040      P:000283 P:000283 011D02            BCLR    #SCLK,X:PDRE                      ; Disable special command mode
1041   
1042                                ; Wait for a bit for MCE to be reset.......
1043      P:000284 P:000284 44F400            MOVE              #10000,X0               ; Delay by about 350 milliseconds
                            002710
1044      P:000286 P:000286 06C400            DO      X0,L_DELAY
                            00028C
1045      P:000288 P:000288 06E883            DO      #1000,L_RDFIFO
                            00028B
1046      P:00028A P:00028A 09463F            MOVEP             Y:RDFIFO,Y0             ; Read the FIFO word to keep the
1047      P:00028B P:00028B 000000            NOP                                       ;   receiver empty
Motorola DSP56300 Assembler  Version 6.3.4   06-03-07  12:16:30  PCI_SCUBA_main.asm  Page 22



1048                                L_RDFIFO
1049      P:00028C P:00028C 000000            NOP
1050                                L_DELAY
1051      P:00028D P:00028D 000000            NOP
1052   
1053                                ; when completed successfully then PCI needs to reply to Host with
1054                                ; word1 = reply/data = reply
1055                                FINISH_RCO
1056      P:00028E P:00028E 44F400            MOVE              #'REP',X0
                            524550
1057      P:000290 P:000290 440C00            MOVE              X0,X:<DTXS_WD1          ; REPly
1058      P:000291 P:000291 44F400            MOVE              #'RCO',X0
                            52434F
1059      P:000293 P:000293 440D00            MOVE              X0,X:<DTXS_WD2          ; echo command sent
1060      P:000294 P:000294 44F400            MOVE              #'ACK',X0
                            41434B
1061      P:000296 P:000296 440E00            MOVE              X0,X:<DTXS_WD3          ; ACKnowledge okay
1062      P:000297 P:000297 44F400            MOVE              #'000',X0
                            303030
1063      P:000299 P:000299 440F00            MOVE              X0,X:<DTXS_WD4          ; read data
1064      P:00029A P:00029A 0D047D            JSR     <RESTORE_REGISTERS                ; restore working registers
1065      P:00029B P:00029B 0D0435            JSR     <PCI_MESSAGE_TO_HOST              ; interrupt host with message (x0 restored h
ere)
1066      P:00029C P:00029C 000004            RTI                                       ; return from ISR
1067   
1068                                ; when there is a failure in the host to PCI command then the PCI
1069                                ; needs still to reply to Host but with an error message
1070                                RCO_ERROR
1071      P:00029D P:00029D 44F400            MOVE              #'REP',X0
                            524550
1072      P:00029F P:00029F 447000            MOVE              X0,X:DTXS_WD1           ; REPly
                            00000C
1073      P:0002A1 P:0002A1 44F400            MOVE              #'RCO',X0
                            52434F
1074      P:0002A3 P:0002A3 447000            MOVE              X0,X:DTXS_WD2           ; echo command sent
                            00000D
1075      P:0002A5 P:0002A5 44F400            MOVE              #'ERR',X0
                            455252
1076      P:0002A7 P:0002A7 447000            MOVE              X0,X:DTXS_WD3           ; ERRor im command
                            00000E
1077      P:0002A9 P:0002A9 44F400            MOVE              #'CNE',X0
                            434E45
1078      P:0002AB P:0002AB 447000            MOVE              X0,X:DTXS_WD4           ; Command Name Error - command name in DRXR 
does not match
                            00000F
1079      P:0002AD P:0002AD 0D047D            JSR     <RESTORE_REGISTERS                ; restore wroking registers
1080      P:0002AE P:0002AE 0D0435            JSR     <PCI_MESSAGE_TO_HOST              ; interrupt host with message (x0 restored h
ere)
1081      P:0002AF P:0002AF 000004            RTI                                       ; return from ISR
1082   
1083   
1084                                ;----------------------------------------------------------------------
1085                                SEND_PACKET_TO_CONTROLLER
1086   
1087                                ; forward packet stuff to the MCE
1088                                ; gets address in HOST memory where packet is stored
1089                                ; read 3 consecutive locations starting at this address
1090                                ; then sends the data from these locations up to the MCE
1091                                ;----------------------------------------------------------------------
1092   
1093                                ; word 1 = command = 'CON'
1094                                ; word 2 = host high address
Motorola DSP56300 Assembler  Version 6.3.4   06-03-07  12:16:30  PCI_SCUBA_main.asm  Page 23



1095                                ; word 3 = host low address
1096                                ; word 4 = '0' --> when MCE command is RS,WB,RB,ST
1097                                ;        = '1' --> when MCE command is GO
1098   
1099                                ; all MCE commands are now 'block commands'
1100                                ; i.e. 64 words long.
1101   
1102      P:0002B0 P:0002B0 0D0492            JSR     <SAVE_REGISTERS                   ; save working registers
1103   
1104      P:0002B1 P:0002B1 0D0450            JSR     <RD_DRXR                          ; read words from host write to HTXR
1105                                                                                    ; reads as 4 x 24 bit words
1106   
1107      P:0002B2 P:0002B2 568800            MOVE              X:<DRXR_WD1,A           ; read command
1108      P:0002B3 P:0002B3 44F400            MOVE              #'CON',X0
                            434F4E
1109      P:0002B5 P:0002B5 200045            CMP     X0,A                              ; ensure command is 'CON'
1110      P:0002B6 P:0002B6 0E22E7            JNE     <CON_ERROR                        ; error, command NOT HCVR address
1111   
1112                                ; convert 2 x 24 bit words ( only 16 LSBs are significant) from host into 32 bit address
1113      P:0002B7 P:0002B7 20001B            CLR     B
1114      P:0002B8 P:0002B8 448900            MOVE              X:<DRXR_WD2,X0          ; MS 16bits of address
1115      P:0002B9 P:0002B9 518A00            MOVE              X:<DRXR_WD3,B0          ; LS 16bits of address
1116      P:0002BA P:0002BA 0C1941            INSERT  #$010010,X0,B                     ; convert to 32 bits and put in B
                            010010
1117   
1118      P:0002BC P:0002BC 568B00            MOVE              X:<DRXR_WD4,A           ; read word 4 - GO command?
1119      P:0002BD P:0002BD 44F000            MOVE              X:ZERO,X0
                            000033
1120      P:0002BF P:0002BF 200045            CMP     X0,A
1121      P:0002C0 P:0002C0 0AF0AA            JEQ     BLOCK_CON
                            0002CE
1122   
1123   
1124      P:0002C2 P:0002C2 0A008C            JCLR    #APPLICATION_RUNNING,X:STATUS,SET_PACKET_DELAY ; not running diagnostic applic
ation?
                            0002CC
1125   
1126                                ; need to generate an internal go command to test master write on bus.....  Diagnostic test
1127      P:0002C4 P:0002C4 0A702D            BSET    #INTERNAL_GO,X:STATUS             ; set flag so that GO reply / data is genera
ted by PCI card...
                            000000
1128   
1129                                ; since INTERNAL_GO  - read command but don't send it to MCE...
1130   
1131                                CLR_CMD
1132      P:0002C6 P:0002C6 064080            DO      #64,END_CLR_CMD                   ; block size = 32bit x 64 (256 bytes)
                            0002C9
1133      P:0002C8 P:0002C8 0D045D            JSR     <READ_FROM_PCI                    ; get next 32 bit word from HOST
1134      P:0002C9 P:0002C9 000000            NOP
1135                                END_CLR_CMD
1136      P:0002CA P:0002CA 0AF080            JMP     FINISH_CON                        ; don't send out on command on fibre
                            0002D8
1137   
1138   
1139                                SET_PACKET_DELAY
1140      P:0002CC P:0002CC 0A7027            BSET    #DATA_DLY,X:STATUS                ; set data delay so that next data packet af
ter go reply
                            000000
1141                                                                                    ; experiences a delay before host notify.
1142   
1143                                ; -----------------------------------------------------------------------
1144                                ; WARNING!!!
Motorola DSP56300 Assembler  Version 6.3.4   06-03-07  12:16:30  PCI_SCUBA_main.asm  Page 24



1145                                ; MCE requires IDLE characters between 32bit words sent FROM the PCI card
1146                                ; DO not change READ_FROM_PCI to DMA block transfer....
1147                                ; ------------------------------------------------------------------------
1148   
1149                                BLOCK_CON
1150      P:0002CE P:0002CE 064080            DO      #64,END_BLOCK_CON                 ; block size = 32bit x 64 (256 bytes)
                            0002D4
1151      P:0002D0 P:0002D0 0D045D            JSR     <READ_FROM_PCI                    ; get next 32 bit word from HOST
1152      P:0002D1 P:0002D1 208C00            MOVE              X0,A1                   ; prepare to send
1153      P:0002D2 P:0002D2 20A800            MOVE              X1,A0                   ; prepare to send
1154      P:0002D3 P:0002D3 0D051B            JSR     <XMT_WD_FIBRE                     ; off it goes
1155      P:0002D4 P:0002D4 000000            NOP
1156                                END_BLOCK_CON
1157   
1158      P:0002D5 P:0002D5 0A0008            BCLR    #PACKET_CHOKE,X:<STATUS           ; disable packet choke...
1159                                                                                    ; comms now open with MCE and packets will b
e processed.
1160                                ; Enable Byte swaping for correct comms protocol.
1161      P:0002D6 P:0002D6 0A0025            BSET    #BYTE_SWAP,X:<STATUS              ; flag to let host know byte swapping on
1162      P:0002D7 P:0002D7 013D24            BSET    #AUX1,X:PDRC                      ; enable hardware
1163   
1164   
1165                                ; -------------------------------------------------------------------------
1166                                ; when completed successfully then PCI needs to reply to Host with
1167                                ; word1 = reply/data = reply
1168                                FINISH_CON
1169      P:0002D8 P:0002D8 44F400            MOVE              #'REP',X0
                            524550
1170      P:0002DA P:0002DA 440C00            MOVE              X0,X:<DTXS_WD1          ; REPly
1171      P:0002DB P:0002DB 44F400            MOVE              #'CON',X0
                            434F4E
1172      P:0002DD P:0002DD 440D00            MOVE              X0,X:<DTXS_WD2          ; echo command sent
1173      P:0002DE P:0002DE 44F400            MOVE              #'ACK',X0
                            41434B
1174      P:0002E0 P:0002E0 440E00            MOVE              X0,X:<DTXS_WD3          ; ACKnowledge okay
1175      P:0002E1 P:0002E1 44F400            MOVE              #'000',X0
                            303030
1176      P:0002E3 P:0002E3 440F00            MOVE              X0,X:<DTXS_WD4          ; read data
1177      P:0002E4 P:0002E4 0D047D            JSR     <RESTORE_REGISTERS                ; restore working registers
1178      P:0002E5 P:0002E5 0D0435            JSR     <PCI_MESSAGE_TO_HOST              ;  interrupt host with message (x0 restored 
here)
1179      P:0002E6 P:0002E6 000004            RTI                                       ; return from ISR
1180   
1181                                ; when there is a failure in the host to PCI command then the PCI
1182                                ; needs still to reply to Host but with an error message
1183                                CON_ERROR
1184      P:0002E7 P:0002E7 44F400            MOVE              #'REP',X0
                            524550
1185      P:0002E9 P:0002E9 440C00            MOVE              X0,X:<DTXS_WD1          ; REPly
1186      P:0002EA P:0002EA 44F400            MOVE              #'CON',X0
                            434F4E
1187      P:0002EC P:0002EC 440D00            MOVE              X0,X:<DTXS_WD2          ; echo command sent
1188      P:0002ED P:0002ED 44F400            MOVE              #'ERR',X0
                            455252
1189      P:0002EF P:0002EF 440E00            MOVE              X0,X:<DTXS_WD3          ; ERRor im command
1190      P:0002F0 P:0002F0 44F400            MOVE              #'CNE',X0
                            434E45
1191      P:0002F2 P:0002F2 440F00            MOVE              X0,X:<DTXS_WD4          ; Command Name Error - command name in DRXR 
does not match
1192      P:0002F3 P:0002F3 0D047D            JSR     <RESTORE_REGISTERS                ; restore working registers
1193      P:0002F4 P:0002F4 0D0435            JSR     <PCI_MESSAGE_TO_HOST              ; interrupt host with message (x0 restored h
ere)
Motorola DSP56300 Assembler  Version 6.3.4   06-03-07  12:16:30  PCI_SCUBA_main.asm  Page 25



1194      P:0002F5 P:0002F5 000004            RTI                                       ; return from ISR
1195   
1196                                ; ------------------------------------------------------------------------------------
1197                                SEND_PACKET_TO_HOST
1198                                ; this command is received from the Host and actions the PCI board to pick up an address
1199                                ; pointer from DRXR which the PCI board then uses to write packets from the
1200                                ; MCE to the host memory starting at the address given.
1201                                ; Since this is interrupt driven all this piece of code does is get the address pointer from
1202                                ; the host via DRXR, set a flag so that the main prog can write the packet.  Replies to
1203                                ; HST after packet sent (unless error).
1204                                ; --------------------------------------------------------------------------------------
1205                                ; word 1 = command = 'HST'
1206                                ; word 2 = host high address
1207                                ; word 3 = host low address
1208                                ; word 4 = not used but read
1209   
1210                                ; save some registers but not B
1211   
1212      P:0002F6 P:0002F6 0D0492            JSR     <SAVE_REGISTERS                   ; save working registers
1213   
1214      P:0002F7 P:0002F7 0D0450            JSR     <RD_DRXR                          ; read words from host write to HTXR
1215      P:0002F8 P:0002F8 20001B            CLR     B
1216      P:0002F9 P:0002F9 568800            MOVE              X:<DRXR_WD1,A           ; read command
1217      P:0002FA P:0002FA 44F400            MOVE              #'HST',X0
                            485354
1218      P:0002FC P:0002FC 200045            CMP     X0,A                              ; ensure command is 'HST'
1219      P:0002FD P:0002FD 0E2305            JNE     <HOST_ERROR                       ; error, command NOT HCVR address
1220      P:0002FE P:0002FE 448900            MOVE              X:<DRXR_WD2,X0          ; high 16 bits of address
1221      P:0002FF P:0002FF 518A00            MOVE              X:<DRXR_WD3,B0          ; low 16 bits of adderss
1222      P:000300 P:000300 0C1941            INSERT  #$010010,X0,B                     ; convert to 32 bits and put in B
                            010010
1223   
1224      P:000302 P:000302 0A0021            BSET    #SEND_TO_HOST,X:<STATUS           ; tell main program to write packet to host 
memory
1225      P:000303 P:000303 0D0489            JSR     <RESTORE_HST_REGISTERS            ; restore registers for HST .... B not resto
red..
1226      P:000304 P:000304 000004            RTI
1227   
1228                                ; !!NOTE!!!
1229                                ; successful reply to this command is sent after packet has been send to host.
1230                                ; Not here unless error.
1231   
1232                                ; when there is a failure in the host to PCI command then the PCI
1233                                ; needs still to reply to Host but with an error message
1234                                HOST_ERROR
1235      P:000305 P:000305 0A7001            BCLR    #SEND_TO_HOST,X:STATUS
                            000000
1236      P:000307 P:000307 44F400            MOVE              #'REP',X0
                            524550
1237      P:000309 P:000309 440C00            MOVE              X0,X:<DTXS_WD1          ; REPly
1238      P:00030A P:00030A 44F400            MOVE              #'HST',X0
                            485354
1239      P:00030C P:00030C 440D00            MOVE              X0,X:<DTXS_WD2          ; echo command sent
1240      P:00030D P:00030D 44F400            MOVE              #'ERR',X0
                            455252
1241      P:00030F P:00030F 440E00            MOVE              X0,X:<DTXS_WD3          ; ERRor im command
1242      P:000310 P:000310 44F400            MOVE              #'CNE',X0
                            434E45
1243      P:000312 P:000312 440F00            MOVE              X0,X:<DTXS_WD4          ; Command Name Error - command name in DRXR 
does not match
1244      P:000313 P:000313 0D047D            JSR     <RESTORE_REGISTERS                ; restore working registers
1245      P:000314 P:000314 0D0435            JSR     <PCI_MESSAGE_TO_HOST              ; interrupt host with message (x0 restored h
Motorola DSP56300 Assembler  Version 6.3.4   06-03-07  12:16:30  PCI_SCUBA_main.asm  Page 26



ere)
1246      P:000315 P:000315 000004            RTI
1247   
1248                                ; --------------------------------------------------------------------
1249                                SOFTWARE_RESET
1250                                ;----------------------------------------------------------------------
1251                                ; word 1 = command = 'RST'
1252                                ; word 2 = not used but read
1253                                ; word 3 = not used but read
1254                                ; word 4 = not used but read
1255   
1256      P:000316 P:000316 0D0492            JSR     <SAVE_REGISTERS
1257   
1258      P:000317 P:000317 0D0450            JSR     <RD_DRXR                          ; read words from host write to HTXR
1259      P:000318 P:000318 568800            MOVE              X:<DRXR_WD1,A           ; read command
1260      P:000319 P:000319 44F400            MOVE              #'RST',X0
                            525354
1261      P:00031B P:00031B 200045            CMP     X0,A                              ; ensure command is 'RST'
1262      P:00031C P:00031C 0E233F            JNE     <RST_ERROR                        ; error, command NOT HCVR address
1263   
1264                                ; RST command OK so reply to host
1265                                FINISH_RST
1266      P:00031D P:00031D 44F400            MOVE              #'REP',X0
                            524550
1267      P:00031F P:00031F 440C00            MOVE              X0,X:<DTXS_WD1          ; REPly
1268      P:000320 P:000320 44F400            MOVE              #'RST',X0
                            525354
1269      P:000322 P:000322 440D00            MOVE              X0,X:<DTXS_WD2          ; echo command sent
1270      P:000323 P:000323 44F400            MOVE              #'ACK',X0
                            41434B
1271      P:000325 P:000325 440E00            MOVE              X0,X:<DTXS_WD3          ; ACKnowledge okay
1272      P:000326 P:000326 44F400            MOVE              #'000',X0
                            303030
1273      P:000328 P:000328 440F00            MOVE              X0,X:<DTXS_WD4          ; read data
1274      P:000329 P:000329 0D0435            JSR     <PCI_MESSAGE_TO_HOST
1275   
1276      P:00032A P:00032A 0A00A4            JSET    #INTA_FLAG,X:<STATUS,*            ; wait for host to process
                            00032A
1277   
1278      P:00032C P:00032C 0A0000            BCLR    #APPLICATION_LOADED,X:<STATUS     ; clear app flag
1279      P:00032D P:00032D 0A0006            BCLR    #PREAMBLE_ERROR,X:<STATUS         ; clear preamble error
1280      P:00032E P:00032E 0A000C            BCLR    #APPLICATION_RUNNING,X:<STATUS    ; clear appl running bit.
1281   
1282                                ; initialise some parameter here - that we don't want to initialse under a fatal error reset.
1283   
1284      P:00032F P:00032F 200013            CLR     A
1285      P:000330 P:000330 340000            MOVE              #0,R4                   ; initialise word count
1286      P:000331 P:000331 560600            MOVE              A,X:<WORD_COUNT         ; initialise word count store (num of words 
written over bus/packet)
1287      P:000332 P:000332 560700            MOVE              A,X:<NUM_DUMPED         ; initialise number dumped from FIFO (after 
HST TO)
1288   
1289   
1290                                ; remember we are in a ISR so can't just jump to start.
1291   
1292      P:000333 P:000333 08F4BF            MOVEP             #$0001C0,X:IPRC         ; Disable HF* FIFO interrupt
                            0001C0
1293      P:000335 P:000335 05F439            MOVE              #$200,SR                ; Mask set up for reset switch only.
                            000200
1294   
1295   
1296      P:000337 P:000337 0501BB            MOVEC             #1,SP                   ; Point stack pointer to the top
Motorola DSP56300 Assembler  Version 6.3.4   06-03-07  12:16:30  PCI_SCUBA_main.asm  Page 27



1297      P:000338 P:000338 05F43D            MOVEC             #$000200,SSL            ; SSL holds SR return state
                            000200
1298                                                                                    ; set to zero except for interrupts
1299      P:00033A P:00033A 0500BB            MOVEC             #0,SP                   ; Writing to SSH preincrements the SP
1300                                                                                    ; so first set to 0
1301      P:00033B P:00033B 05F43C            MOVEC             #START,SSH              ; SSH holds return address of PC
                            000100
1302                                                                                    ; therefore,return to initialization
1303      P:00033D P:00033D 000000            NOP
1304      P:00033E P:00033E 000004            RTI                                       ; return from ISR - to START
1305   
1306                                ; when there is a failure in the host to PCI command then the PCI
1307                                ; needs still to reply to Host but with an error message
1308                                RST_ERROR
1309      P:00033F P:00033F 44F400            MOVE              #'REP',X0
                            524550
1310      P:000341 P:000341 440C00            MOVE              X0,X:<DTXS_WD1          ; REPly
1311      P:000342 P:000342 44F400            MOVE              #'RST',X0
                            525354
1312      P:000344 P:000344 440D00            MOVE              X0,X:<DTXS_WD2          ; echo command sent
1313      P:000345 P:000345 44F400            MOVE              #'ERR',X0
                            455252
1314      P:000347 P:000347 440E00            MOVE              X0,X:<DTXS_WD3          ; ERRor im command
1315      P:000348 P:000348 44F400            MOVE              #'CNE',X0
                            434E45
1316      P:00034A P:00034A 440F00            MOVE              X0,X:<DTXS_WD4          ; Command Name Error - command name in DRXR 
does not match
1317      P:00034B P:00034B 0D047D            JSR     <RESTORE_REGISTERS                ; restore working registers
1318      P:00034C P:00034C 0D0435            JSR     <PCI_MESSAGE_TO_HOST              ; interrupt host with message (x0 restored h
ere)
1319      P:00034D P:00034D 000004            RTI                                       ; return from ISR
1320   
1321   
1322                                ;-----------------------------------------------------------------------------
1323                                START_APPLICATION
1324                                ; an application should already have been downloaded to the PCI memory.
1325                                ; this command will execute it.
1326                                ; ----------------------------------------------------------------------
1327                                ; word 1 = command = 'GOA'
1328                                ; word 2 = not used but read by RD_DRXR
1329                                ; word 3 = not used but read by RD_DRXR
1330                                ; word 4 = not used but read by RD_DRXR
1331   
1332      P:00034E P:00034E 0D0492            JSR     <SAVE_REGISTERS                   ; save working registers
1333   
1334      P:00034F P:00034F 0D0450            JSR     <RD_DRXR                          ; read words from host write to HTXR
1335      P:000350 P:000350 568800            MOVE              X:<DRXR_WD1,A           ; read command
1336      P:000351 P:000351 44F400            MOVE              #'GOA',X0
                            474F41
1337      P:000353 P:000353 200045            CMP     X0,A                              ; ensure command is 'RDM'
1338      P:000354 P:000354 0E2357            JNE     <GO_ERROR                         ; error, command NOT HCVR address
1339   
1340                                ; if we get here then everything is fine and we can start the application
1341                                ; set bit in status so that main fibre servicing code knows to jump
1342                                ; to application space after returning from this ISR
1343   
1344                                ; reply after application has been executed.
1345      P:000355 P:000355 0A0020            BSET    #APPLICATION_LOADED,X:<STATUS
1346      P:000356 P:000356 000004            RTI                                       ; return from ISR
1347   
1348   
1349                                ; when there is a failure in the host to PCI command then the PCI
Motorola DSP56300 Assembler  Version 6.3.4   06-03-07  12:16:30  PCI_SCUBA_main.asm  Page 28



1350                                ; needs still to reply to Host but with an error message
1351                                GO_ERROR
1352      P:000357 P:000357 44F400            MOVE              #'REP',X0
                            524550
1353      P:000359 P:000359 440C00            MOVE              X0,X:<DTXS_WD1          ; REPly
1354      P:00035A P:00035A 44F400            MOVE              #'GOA',X0
                            474F41
1355      P:00035C P:00035C 440D00            MOVE              X0,X:<DTXS_WD2          ; echo command sent
1356      P:00035D P:00035D 44F400            MOVE              #'ERR',X0
                            455252
1357      P:00035F P:00035F 440E00            MOVE              X0,X:<DTXS_WD3          ; ERRor im command
1358      P:000360 P:000360 44F400            MOVE              #'CNE',X0
                            434E45
1359      P:000362 P:000362 440F00            MOVE              X0,X:<DTXS_WD4          ; Command Name Error - command name in DRXR 
does not match
1360      P:000363 P:000363 0D047D            JSR     <RESTORE_REGISTERS                ; restore working registers
1361      P:000364 P:000364 0D0435            JSR     <PCI_MESSAGE_TO_HOST              ; interrupt host with message (x0 restored h
ere)
1362      P:000365 P:000365 000004            RTI                                       ; return from ISR
1363   
1364                                ; ---------------------------------------------------------
1365                                STOP_APPLICATION
1366                                ; this command stops an application that is currently running
1367                                ; used for applications that once started run contiunually
1368                                ;-----------------------------------------------------------
1369   
1370                                ; word 1 = command = ' STP'
1371                                ; word 2 = not used but read
1372                                ; word 3 = not used but read
1373                                ; word 4 = not used but read
1374   
1375      P:000366 P:000366 0D0492            JSR     <SAVE_REGISTERS
1376   
1377      P:000367 P:000367 0D0450            JSR     <RD_DRXR                          ; read words from host write to HTXR
1378      P:000368 P:000368 568800            MOVE              X:<DRXR_WD1,A           ; read command
1379      P:000369 P:000369 44F400            MOVE              #'STP',X0
                            535450
1380      P:00036B P:00036B 200045            CMP     X0,A                              ; ensure command is 'RDM'
1381      P:00036C P:00036C 0E237F            JNE     <STP_ERROR                        ; error, command NOT HCVR address
1382   
1383      P:00036D P:00036D 0A0000            BCLR    #APPLICATION_LOADED,X:<STATUS
1384      P:00036E P:00036E 0A700C            BCLR    #APPLICATION_RUNNING,X:STATUS
                            000000
1385   
1386                                ; when completed successfully then PCI needs to reply to Host with
1387                                ; word1 = reply/data = reply
1388                                FINISH_STP
1389      P:000370 P:000370 44F400            MOVE              #'REP',X0
                            524550
1390      P:000372 P:000372 440C00            MOVE              X0,X:<DTXS_WD1          ; REPly
1391      P:000373 P:000373 44F400            MOVE              #'STP',X0
                            535450
1392      P:000375 P:000375 440D00            MOVE              X0,X:<DTXS_WD2          ; echo command sent
1393      P:000376 P:000376 44F400            MOVE              #'ACK',X0
                            41434B
1394      P:000378 P:000378 440E00            MOVE              X0,X:<DTXS_WD3          ; ACKnowledge okay
1395      P:000379 P:000379 44F400            MOVE              #'000',X0
                            303030
1396      P:00037B P:00037B 440F00            MOVE              X0,X:<DTXS_WD4          ; read data
1397      P:00037C P:00037C 0D047D            JSR     <RESTORE_REGISTERS                ; restore working registers.
1398      P:00037D P:00037D 0D0435            JSR     <PCI_MESSAGE_TO_HOST              ; interrupt host with message (x0 restored h
ere)
Motorola DSP56300 Assembler  Version 6.3.4   06-03-07  12:16:30  PCI_SCUBA_main.asm  Page 29



1399      P:00037E P:00037E 000004            RTI
1400   
1401                                ; when there is a failure in the host to PCI command then the PCI
1402                                ; needs still to reply to Host but with an error message
1403                                STP_ERROR
1404      P:00037F P:00037F 44F400            MOVE              #'REP',X0
                            524550
1405      P:000381 P:000381 440C00            MOVE              X0,X:<DTXS_WD1          ; REPly
1406      P:000382 P:000382 44F400            MOVE              #'STP',X0
                            535450
1407      P:000384 P:000384 440D00            MOVE              X0,X:<DTXS_WD2          ; echo command sent
1408      P:000385 P:000385 44F400            MOVE              #'ERR',X0
                            455252
1409      P:000387 P:000387 440E00            MOVE              X0,X:<DTXS_WD3          ; ERRor im command
1410      P:000388 P:000388 44F400            MOVE              #'CNE',X0
                            434E45
1411      P:00038A P:00038A 440F00            MOVE              X0,X:<DTXS_WD4          ; Command Name Error - command name in DRXR 
does not match
1412      P:00038B P:00038B 0D047D            JSR     <RESTORE_REGISTERS                ; restore working registers
1413      P:00038C P:00038C 0D0435            JSR     <PCI_MESSAGE_TO_HOST              ; interrupt host with message (x0 restored h
ere)
1414      P:00038D P:00038D 000004            RTI
1415   
1416                                ;--------------------------------------------------------------
1417                                WRITE_MEMORY
1418                                ;---------------------------------------------------------------
1419                                ; word 1 = command = 'WRM'
1420                                ; word 2 = memory type, P=$00'_P', X=$00'_X' or Y=$00'_Y'
1421                                ; word 3 = address in memory
1422                                ; word 4 = value
1423   
1424      P:00038E P:00038E 0D0492            JSR     <SAVE_REGISTERS                   ; save working registers
1425   
1426      P:00038F P:00038F 0D0450            JSR     <RD_DRXR                          ; read words from host write to HTXR
1427      P:000390 P:000390 56F000            MOVE              X:DRXR_WD1,A            ; read command
                            000008
1428      P:000392 P:000392 44F400            MOVE              #'WRM',X0
                            57524D
1429      P:000394 P:000394 200045            CMP     X0,A                              ; ensure command is 'WRM'
1430      P:000395 P:000395 0E23B8            JNE     <WRITE_MEMORY_ERROR_CNE           ; error, command NOT HCVR address
1431      P:000396 P:000396 568900            MOVE              X:<DRXR_WD2,A           ; Memory type (X, Y, P)
1432      P:000397 P:000397 578A00            MOVE              X:<DRXR_WD3,B
1433      P:000398 P:000398 000000            NOP                                       ; pipeline restriction
1434      P:000399 P:000399 21B000            MOVE              B1,R0                   ; get address to write to
1435      P:00039A P:00039A 448B00            MOVE              X:<DRXR_WD4,X0          ; get data to write
1436      P:00039B P:00039B 0140C5            CMP     #$005F50,A                        ; $00'_P'
                            005F50
1437      P:00039D P:00039D 0E23A0            JNE     <WRX
1438      P:00039E P:00039E 076084            MOVE              X0,P:(R0)               ; Write to Program memory
1439      P:00039F P:00039F 0C03A9            JMP     <FINISH_WRITE_MEMORY
1440                                WRX
1441      P:0003A0 P:0003A0 0140C5            CMP     #$005F58,A                        ; $00'_X'
                            005F58
1442      P:0003A2 P:0003A2 0E23A5            JNE     <WRY
1443      P:0003A3 P:0003A3 446000            MOVE              X0,X:(R0)               ; Write to X: memory
1444      P:0003A4 P:0003A4 0C03A9            JMP     <FINISH_WRITE_MEMORY
1445                                WRY
1446      P:0003A5 P:0003A5 0140C5            CMP     #$005F59,A                        ; $00'_Y'
                            005F59
1447      P:0003A7 P:0003A7 0E23BC            JNE     <WRITE_MEMORY_ERROR_MTE
1448      P:0003A8 P:0003A8 4C6000            MOVE                          X0,Y:(R0)   ; Write to Y: memory
1449   
Motorola DSP56300 Assembler  Version 6.3.4   06-03-07  12:16:30  PCI_SCUBA_main.asm  Page 30



1450                                ; when completed successfully then PCI needs to reply to Host with
1451                                ; word1 = reply/data = reply
1452                                FINISH_WRITE_MEMORY
1453      P:0003A9 P:0003A9 44F400            MOVE              #'REP',X0
                            524550
1454      P:0003AB P:0003AB 440C00            MOVE              X0,X:<DTXS_WD1          ; REPly
1455      P:0003AC P:0003AC 44F400            MOVE              #'WRM',X0
                            57524D
1456      P:0003AE P:0003AE 440D00            MOVE              X0,X:<DTXS_WD2          ; echo command sent
1457      P:0003AF P:0003AF 44F400            MOVE              #'ACK',X0
                            41434B
1458      P:0003B1 P:0003B1 440E00            MOVE              X0,X:<DTXS_WD3          ; ACKnowledge okay
1459      P:0003B2 P:0003B2 44F400            MOVE              #'000',X0
                            303030
1460      P:0003B4 P:0003B4 440F00            MOVE              X0,X:<DTXS_WD4          ; no error
1461      P:0003B5 P:0003B5 0D047D            JSR     <RESTORE_REGISTERS                ; restore working registers
1462      P:0003B6 P:0003B6 0D0435            JSR     <PCI_MESSAGE_TO_HOST              ; interrupt host with message (x0 restored h
ere)
1463      P:0003B7 P:0003B7 000004            RTI
1464   
1465                                ;
1466                                WRITE_MEMORY_ERROR_CNE
1467      P:0003B8 P:0003B8 44F400            MOVE              #'CNE',X0
                            434E45
1468      P:0003BA P:0003BA 440F00            MOVE              X0,X:<DTXS_WD4          ; Command Name Error - command name in DRXR 
does not match
1469      P:0003BB P:0003BB 0C03BF            JMP     <WRITE_MEMORY_ERROR               ; fill in rest of reply
1470   
1471                                WRITE_MEMORY_ERROR_MTE
1472      P:0003BC P:0003BC 44F400            MOVE              #'MTE',X0
                            4D5445
1473      P:0003BE P:0003BE 440F00            MOVE              X0,X:<DTXS_WD4          ; Memory Type Error - memory type not valid
1474   
1475                                WRITE_MEMORY_ERROR
1476      P:0003BF P:0003BF 44F400            MOVE              #'REP',X0
                            524550
1477      P:0003C1 P:0003C1 440C00            MOVE              X0,X:<DTXS_WD1          ; REPly
1478      P:0003C2 P:0003C2 44F400            MOVE              #'WRM',X0
                            57524D
1479      P:0003C4 P:0003C4 440D00            MOVE              X0,X:<DTXS_WD2          ; echo command sent
1480      P:0003C5 P:0003C5 44F400            MOVE              #'ERR',X0
                            455252
1481      P:0003C7 P:0003C7 440E00            MOVE              X0,X:<DTXS_WD3          ; ERRor im command
1482      P:0003C8 P:0003C8 0D047D            JSR     <RESTORE_REGISTERS                ; restore working registers
1483      P:0003C9 P:0003C9 0D0435            JSR     <PCI_MESSAGE_TO_HOST              ; interrupt host with message (x0 restored h
ere)
1484      P:0003CA P:0003CA 000004            RTI
1485   
1486   
1487                                ;---------------------------------------------------------------
1488                                ;
1489                                ;                          * END OF ISRs *
1490                                ;
1491                                ;--------------------------------------------------------------
1492   
1493   
1494   
1495                                ;----------------------------------------------------------------
1496                                ;
1497                                ;                     * Beginning of SUBROUTINES *
1498                                ;
1499                                ;-----------------------------------------------------------------
Motorola DSP56300 Assembler  Version 6.3.4   06-03-07  12:16:30  PCI_SCUBA_main.asm  Page 31



1500   
1501   
1502                                ; -------------------------------------------------------------
1503                                CALC_NO_BUFFS
1504                                ;----------------------------------------------------
1505                                ; number of 512 buffers in packet calculated (X:TOTAL_BUFFS)
1506                                ; and number of left over blocks (X:NUM_LEFTOVER_BLOCKS)
1507                                ; and left over words (X:LEFT_TO_READ)
1508   
1509      P:0003CB P:0003CB 20001B            CLR     B
1510      P:0003CC P:0003CC 51A300            MOVE              X:<HEAD_W4_0,B0         ; LS 16bits
1511      P:0003CD P:0003CD 44A200            MOVE              X:<HEAD_W4_1,X0         ; MS 16bits
1512   
1513      P:0003CE P:0003CE 0C1941            INSERT  #$010010,X0,B                     ; now size of packet B....giving # of 32bit 
words in packet
                            010010
1514      P:0003D0 P:0003D0 000000            NOP
1515   
1516                                ; need to covert this to 16 bit since read from FIFO and saved in Y memory as 16bit words...
1517   
1518                                ; so double size of packet....
1519      P:0003D1 P:0003D1 20003A            ASL     B
1520   
1521                                ; now save
1522      P:0003D2 P:0003D2 212400            MOVE              B0,X0
1523      P:0003D3 P:0003D3 21A500            MOVE              B1,X1
1524      P:0003D4 P:0003D4 443600            MOVE              X0,X:<PACKET_SIZE_LOW   ; low 24 bits of packet size (in 16bit words
)
1525      P:0003D5 P:0003D5 453700            MOVE              X1,X:<PACKET_SIZE_HIH   ; high 8 bits of packet size (in 16bit words
)
1526   
1527      P:0003D6 P:0003D6 50B600            MOVE              X:<PACKET_SIZE_LOW,A0
1528      P:0003D7 P:0003D7 54B700            MOVE              X:<PACKET_SIZE_HIH,A1
1529      P:0003D8 P:0003D8 0C1C12            ASR     #9,A,A                            ; divide by 512...number of 16bit words in a
 buffer
1530      P:0003D9 P:0003D9 000000            NOP
1531      P:0003DA P:0003DA 503C00            MOVE              A0,X:<TOTAL_BUFFS
1532   
1533      P:0003DB P:0003DB 210500            MOVE              A0,X1
1534      P:0003DC P:0003DC 47F400            MOVE              #HF_FIFO,Y1
                            000200
1535      P:0003DE P:0003DE 2000F0            MPY     X1,Y1,A
1536      P:0003DF P:0003DF 0C1C03            ASR     #1,A,B                            ; B holds number of 16bit words in all full 
buffers
1537      P:0003E0 P:0003E0 000000            NOP
1538   
1539      P:0003E1 P:0003E1 50B600            MOVE              X:<PACKET_SIZE_LOW,A0
1540      P:0003E2 P:0003E2 54B700            MOVE              X:<PACKET_SIZE_HIH,A1   ; A holds total number of 16bit words
1541      P:0003E3 P:0003E3 200014            SUB     B,A                               ; now A holds number of left over 16bit word
s
1542      P:0003E4 P:0003E4 000000            NOP
1543      P:0003E5 P:0003E5 503D00            MOVE              A0,X:<LEFT_TO_READ      ; store number of left over 16bit words to r
ead
1544      P:0003E6 P:0003E6 0C1C0A            ASR     #5,A,A                            ; divide by 32... number of 16bit words in l
efover block
1545      P:0003E7 P:0003E7 000000            NOP
1546      P:0003E8 P:0003E8 503F00            MOVE              A0,X:<NUM_LEFTOVER_BLOCKS
1547      P:0003E9 P:0003E9 210500            MOVE              A0,X1
1548      P:0003EA P:0003EA 47F400            MOVE              #>SMALL_BLK,Y1
                            000020
1549      P:0003EC P:0003EC 2000F0            MPY     X1,Y1,A
1550      P:0003ED P:0003ED 0C1C02            ASR     #1,A,A
Motorola DSP56300 Assembler  Version 6.3.4   06-03-07  12:16:30  PCI_SCUBA_main.asm  Page 32



1551      P:0003EE P:0003EE 000000            NOP
1552   
1553      P:0003EF P:0003EF 200018            ADD     A,B                               ; B holds words in all buffers
1554      P:0003F0 P:0003F0 000000            NOP
1555      P:0003F1 P:0003F1 50B600            MOVE              X:<PACKET_SIZE_LOW,A0
1556      P:0003F2 P:0003F2 54B700            MOVE              X:<PACKET_SIZE_HIH,A1   ; A holds total number of words
1557      P:0003F3 P:0003F3 200014            SUB     B,A                               ; now A holds number of left over words
1558      P:0003F4 P:0003F4 000000            NOP
1559      P:0003F5 P:0003F5 503D00            MOVE              A0,X:<LEFT_TO_READ      ; store number of left over 16bit words to r
ead
1560   
1561      P:0003F6 P:0003F6 0C1C02            ASR     #1,A,A                            ; divide by two to get number of 32 bit word
s to write
1562      P:0003F7 P:0003F7 000000            NOP                                       ; for pipeline
1563      P:0003F8 P:0003F8 503E00            MOVE              A0,X:<LEFT_TO_WRITE     ; store number of left over 32 bit words (2 
x 16 bit) to write to host after small block transfer as well
1564   
1565      P:0003F9 P:0003F9 00000C            RTS
1566   
1567                                ;---------------------------------------------------------------
1568                                GET_FO_WRD
1569                                ;--------------------------------------------------------------
1570                                ; Anything in fibre receive FIFO?   If so store in X0
1571   
1572      P:0003FA P:0003FA 01AD80            JCLR    #EF,X:PDRD,CLR_FO_RTS
                            000410
1573      P:0003FC P:0003FC 000000            NOP
1574      P:0003FD P:0003FD 000000            NOP
1575      P:0003FE P:0003FE 01AD80            JCLR    #EF,X:PDRD,CLR_FO_RTS             ; check twice for FO metastability.
                            000410
1576      P:000400 P:000400 0AF080            JMP     RD_FO_WD
                            000408
1577   
1578      P:000402 P:000402 01AD80  WT_FIFO   JCLR    #EF,X:PDRD,*                      ; Wait till something in FIFO flagged
                            000402
1579      P:000404 P:000404 000000            NOP
1580      P:000405 P:000405 000000            NOP
1581      P:000406 P:000406 01AD80            JCLR    #EF,X:PDRD,WT_FIFO                ; check twice.....
                            000402
1582   
1583                                ; Read one word from the fiber optics FIFO, check it and put it in A1
1584                                RD_FO_WD
1585      P:000408 P:000408 09443F            MOVEP             Y:RDFIFO,X0             ; then read to X0
1586      P:000409 P:000409 54F400            MOVE              #$00FFFF,A1             ; mask off top 2 bytes ($FC)
                            00FFFF
1587      P:00040B P:00040B 200046            AND     X0,A                              ; since receiving 16 bits in 24bit register
1588      P:00040C P:00040C 000000            NOP
1589      P:00040D P:00040D 218400            MOVE              A1,X0
1590      P:00040E P:00040E 0A0023            BSET    #FO_WRD_RCV,X:<STATUS
1591      P:00040F P:00040F 00000C            RTS
1592                                CLR_FO_RTS
1593      P:000410 P:000410 0A0003            BCLR    #FO_WRD_RCV,X:<STATUS
1594      P:000411 P:000411 00000C            RTS
1595   
1596                                ;-----------------------------------------------
1597                                PCI_ERROR_RECOVERY
1598                                ;-----------------------------------------------
1599                                ; Recover from an error writing to the PCI bus
1600   
1601      P:000412 P:000412 0A8A8A            JCLR    #TRTY,X:DPSR,ERROR1               ; Retry error
                            000417
1602      P:000414 P:000414 08F48A            MOVEP             #$0400,X:DPSR           ; Clear target retry error bit
Motorola DSP56300 Assembler  Version 6.3.4   06-03-07  12:16:30  PCI_SCUBA_main.asm  Page 33



                            000400
1603      P:000416 P:000416 00000C            RTS
1604      P:000417 P:000417 0A8A8B  ERROR1    JCLR    #TO,X:DPSR,ERROR2                 ; Timeout error
                            00041C
1605      P:000419 P:000419 08F48A            MOVEP             #$0800,X:DPSR           ; Clear timeout error bit
                            000800
1606      P:00041B P:00041B 00000C            RTS
1607      P:00041C P:00041C 0A8A89  ERROR2    JCLR    #TDIS,X:DPSR,ERROR3               ; Target disconnect error
                            000421
1608      P:00041E P:00041E 08F48A            MOVEP             #$0200,X:DPSR           ; Clear target disconnect bit
                            000200
1609      P:000420 P:000420 00000C            RTS
1610      P:000421 P:000421 0A8A88  ERROR3    JCLR    #TAB,X:DPSR,ERROR4                ; Target abort error
                            000426
1611      P:000423 P:000423 08F48A            MOVEP             #$0100,X:DPSR           ; Clear target abort error bit
                            000100
1612      P:000425 P:000425 00000C            RTS
1613      P:000426 P:000426 0A8A87  ERROR4    JCLR    #MAB,X:DPSR,ERROR5                ; Master abort error
                            00042B
1614      P:000428 P:000428 08F48A            MOVEP             #$0080,X:DPSR           ; Clear master abort error bit
                            000080
1615      P:00042A P:00042A 00000C            RTS
1616      P:00042B P:00042B 0A8A86  ERROR5    JCLR    #DPER,X:DPSR,ERROR6               ; Data parity error
                            000430
1617      P:00042D P:00042D 08F48A            MOVEP             #$0040,X:DPSR           ; Clear data parity error bit
                            000040
1618      P:00042F P:00042F 00000C            RTS
1619      P:000430 P:000430 0A8A85  ERROR6    JCLR    #APER,X:DPSR,ERROR7               ; Address parity error
                            000434
1620      P:000432 P:000432 08F48A            MOVEP             #$0020,X:DPSR           ; Clear address parity error bit
                            000020
1621      P:000434 P:000434 00000C  ERROR7    RTS
1622   
1623                                ; ----------------------------------------------------------------------------
1624                                PCI_MESSAGE_TO_HOST
1625                                ;----------------------------------------------------------------------------
1626   
1627                                ; subroutine to send 4 words as a reply from PCI to the Host
1628                                ; using the DTXS-HRXS data path
1629                                ; PCI card writes here first then causes an interrupt INTA on
1630                                ; the PCI bus to alert the host to the reply message
1631   
1632   
1633   
1634      P:000435 P:000435 0A00A4            JSET    #INTA_FLAG,X:<STATUS,*            ; make sure host ready to receive message
                            000435
1635                                                                                    ; bit will be cleared by fast interrupt
1636                                                                                    ; if ready
1637      P:000437 P:000437 0A0024            BSET    #INTA_FLAG,X:<STATUS              ; set flag for next time round.....
1638   
1639   
1640      P:000438 P:000438 0A8981            JCLR    #STRQ,X:DSR,*                     ; Wait for transmitter to be NOT FULL
                            000438
1641                                                                                    ; i.e. if CLR then FULL so wait
1642                                                                                    ; if not then it is clear to write
1643      P:00043A P:00043A 448C00            MOVE              X:<DTXS_WD1,X0
1644      P:00043B P:00043B 447000            MOVE              X0,X:DTXS               ; Write 24 bit word1
                            FFFFCD
1645   
1646      P:00043D P:00043D 0A8981            JCLR    #STRQ,X:DSR,*                     ; wait to be not full
                            00043D
1647      P:00043F P:00043F 448D00            MOVE              X:<DTXS_WD2,X0
Motorola DSP56300 Assembler  Version 6.3.4   06-03-07  12:16:30  PCI_SCUBA_main.asm  Page 34



1648      P:000440 P:000440 447000            MOVE              X0,X:DTXS               ; Write 24 bit word2
                            FFFFCD
1649   
1650      P:000442 P:000442 0A8981            JCLR    #STRQ,X:DSR,*                     ; wait to be not full
                            000442
1651      P:000444 P:000444 448E00            MOVE              X:<DTXS_WD3,X0
1652      P:000445 P:000445 447000            MOVE              X0,X:DTXS               ; Write 24 bit word3
                            FFFFCD
1653   
1654      P:000447 P:000447 0A8981            JCLR    #STRQ,X:DSR,*                     ; wait to be not full
                            000447
1655      P:000449 P:000449 448F00            MOVE              X:<DTXS_WD4,X0
1656      P:00044A P:00044A 447000            MOVE              X0,X:DTXS               ; Write 24 bit word4
                            FFFFCD
1657   
1658   
1659                                ; restore X0....
1660                                ; PCI_MESSAGE_TO_HOST is used by all command vector ISRs.
1661                                ; Working registers must be restored before RTI.
1662                                ; However, we want to restore before asserting INTA.
1663                                ; x0 is only one that can't be restored before PCI_MESSAGE_TO_HOST
1664                                ; (since it is used by this SR) hence we restore here.
1665                                ; this is redundant for a 'NFY' message (since sequential instruction)
1666                                ; but may be required for a PCI command reply 'REP' message.
1667                                ; (since interrupt driven)
1668   
1669      P:00044C P:00044C 44F000            MOVE              X:SV_X0,X0              ; restore X0
                            00002E
1670   
1671                                ; all the transmit words are in the FIFO, interrupt the Host
1672                                ; the Host should clear this interrupt once it is detected.
1673                                ; It does this by writing to HCVR to cause a fast interrupt.
1674   
1675      P:00044E P:00044E 0A8526            BSET    #INTA,X:DCTR                      ; Assert the interrupt
1676   
1677      P:00044F P:00044F 00000C            RTS
1678   
1679                                ;---------------------------------------------------------------
1680                                RD_DRXR
1681                                ;--------------------------------------------------------------
1682                                ; routine is used to read from HTXR-DRXR data path
1683                                ; which is used by the Host to communicate with the PCI board
1684                                ; the host writes 4 words to this FIFO then interrupts the PCI
1685                                ; which reads the 4 words and acts on them accordingly.
1686   
1687   
1688      P:000450 P:000450 0A8982            JCLR    #SRRQ,X:DSR,*                     ; Wait for receiver to be not empty
                            000450
1689                                                                                    ; implies that host has written words
1690   
1691   
1692                                ; actually reading as slave here so this shouldn't be necessary......?
1693   
1694      P:000452 P:000452 0A8717            BCLR    #FC1,X:DPMC                       ; 24 bit read FC1 = 0, FC1 = 0
1695      P:000453 P:000453 0A8736            BSET    #FC0,X:DPMC
1696   
1697   
1698      P:000454 P:000454 08440B            MOVEP             X:DRXR,X0               ; Get word1
1699      P:000455 P:000455 440800            MOVE              X0,X:<DRXR_WD1
1700      P:000456 P:000456 08440B            MOVEP             X:DRXR,X0               ; Get word2
1701      P:000457 P:000457 440900            MOVE              X0,X:<DRXR_WD2
1702      P:000458 P:000458 08440B            MOVEP             X:DRXR,X0               ; Get word3
Motorola DSP56300 Assembler  Version 6.3.4   06-03-07  12:16:30  PCI_SCUBA_main.asm  Page 35



1703      P:000459 P:000459 440A00            MOVE              X0,X:<DRXR_WD3
1704      P:00045A P:00045A 08440B            MOVEP             X:DRXR,X0               ; Get word4
1705      P:00045B P:00045B 440B00            MOVE              X0,X:<DRXR_WD4
1706      P:00045C P:00045C 00000C            RTS
1707   
1708                                ;---------------------------------------------------------------
1709                                READ_FROM_PCI
1710                                ;--------------------------------------------------------------
1711                                ; sub routine to read a 24 bit word in from PCI bus --> Y memory
1712                                ; 32bit host address in accumulator B.
1713   
1714                                ; read as master
1715   
1716      P:00045D P:00045D 0C1890            EXTRACTU #$010010,B,A                     ; Get D31-16 bits only
                            010010
1717      P:00045F P:00045F 000000            NOP
1718   
1719      P:000460 P:000460 210C00            MOVE              A0,A1
1720      P:000461 P:000461 000000            NOP
1721      P:000462 P:000462 547000            MOVE              A1,X:DPMC               ; high 16bits of address in DSP master cntr 
reg.
                            FFFFC7
1722                                                                                    ; 32 bit read so FC1 = 0 and FC0 = 0
1723   
1724      P:000464 P:000464 000000            NOP
1725      P:000465 P:000465 0C1890            EXTRACTU #$010000,B,A
                            010000
1726      P:000467 P:000467 000000            NOP
1727      P:000468 P:000468 210C00            MOVE              A0,A1
1728      P:000469 P:000469 0140C2            OR      #$060000,A                        ; A1 gets written to DPAR register
                            060000
1729      P:00046B P:00046B 000000            NOP                                       ; C3-C0 of DPAR=0110 for memory read
1730      P:00046C P:00046C 08CC08  WRT_ADD   MOVEP             A1,X:DPAR               ; Write address to PCI bus - PCI READ action
1731      P:00046D P:00046D 000000            NOP                                       ; Pipeline delay
1732      P:00046E P:00046E 0A8AA2  RD_PCI    JSET    #MRRQ,X:DPSR,GET_DAT              ; If MTRQ = 1 go read the word from host via
 FIFO
                            000477
1733      P:000470 P:000470 0A8A8A            JCLR    #TRTY,X:DPSR,RD_PCI               ; Bit is set if its a retry
                            00046E
1734      P:000472 P:000472 08F48A            MOVEP             #$0400,X:DPSR           ; Clear bit 10 = target retry bit
                            000400
1735      P:000474 P:000474 0A8A84            JCLR    #MARQ,X:DPSR,*                    ; Wait for PCI addressing to be complete
                            000474
1736      P:000476 P:000476 0C046C            JMP     <WRT_ADD
1737   
1738      P:000477 P:000477 08440B  GET_DAT   MOVEP             X:DRXR,X0               ; Read 1st 16 bits of 32 bit word from host 
memory
1739      P:000478 P:000478 08450B            MOVEP             X:DRXR,X1               ; Read 2nd 16 bits of 32 bit word from host 
memory
1740   
1741                                ; note that we now have 4 bytes in X0 and X1.
1742                                ; The 32bit word was in host memory in little endian format
1743                                ; If form LSB --> MSB the bytes are b1, b2, b3, b4 in host memory
1744                                ; in progressing through the HTRX/DRXR FIFO the
1745                                ; bytes end up like this.....
1746                                ; then X0 = $00 b2 b1
1747                                ; and  X1 = $00 b4 b3
1748   
1749      P:000479 P:000479 0604A0            REP     #4                                ; increment PCI address by four bytes.
1750      P:00047A P:00047A 000009            INC     B
1751      P:00047B P:00047B 000000            NOP
1752      P:00047C P:00047C 00000C            RTS
Motorola DSP56300 Assembler  Version 6.3.4   06-03-07  12:16:30  PCI_SCUBA_main.asm  Page 36



1753   
1754                                ;------------------------------------------------------------------------------------
1755                                RESTORE_REGISTERS
1756                                ;-------------------------------------------------------------------------------------
1757   
1758      P:00047D P:00047D 05B239            MOVEC             X:<SV_SR,SR
1759   
1760      P:00047E P:00047E 50A800            MOVE              X:<SV_A0,A0
1761      P:00047F P:00047F 54A900            MOVE              X:<SV_A1,A1
1762      P:000480 P:000480 52AA00            MOVE              X:<SV_A2,A2
1763   
1764      P:000481 P:000481 51AB00            MOVE              X:<SV_B0,B0
1765      P:000482 P:000482 55AC00            MOVE              X:<SV_B1,B1
1766      P:000483 P:000483 53AD00            MOVE              X:<SV_B2,B2
1767   
1768      P:000484 P:000484 44AE00            MOVE              X:<SV_X0,X0
1769      P:000485 P:000485 45AF00            MOVE              X:<SV_X1,X1
1770   
1771      P:000486 P:000486 46B000            MOVE              X:<SV_Y0,Y0
1772      P:000487 P:000487 47B100            MOVE              X:<SV_Y1,Y1
1773   
1774      P:000488 P:000488 00000C            RTS
1775                                ;------------------------------------------------------------------------------------
1776                                RESTORE_HST_REGISTERS
1777                                ;-------------------------------------------------------------------------------------
1778                                ; B not restored after HST as it now contains address.
1779   
1780      P:000489 P:000489 05B239            MOVEC             X:<SV_SR,SR
1781   
1782      P:00048A P:00048A 50A800            MOVE              X:<SV_A0,A0
1783      P:00048B P:00048B 54A900            MOVE              X:<SV_A1,A1
1784      P:00048C P:00048C 52AA00            MOVE              X:<SV_A2,A2
1785   
1786      P:00048D P:00048D 44AE00            MOVE              X:<SV_X0,X0
1787      P:00048E P:00048E 45AF00            MOVE              X:<SV_X1,X1
1788   
1789      P:00048F P:00048F 46B000            MOVE              X:<SV_Y0,Y0
1790      P:000490 P:000490 47B100            MOVE              X:<SV_Y1,Y1
1791   
1792      P:000491 P:000491 00000C            RTS
1793   
1794                                ;-------------------------------------------------------------------------------------
1795                                SAVE_REGISTERS
1796                                ;-------------------------------------------------------------------------------------
1797   
1798      P:000492 P:000492 053239            MOVEC             SR,X:<SV_SR             ; save status register.  May jump to ISR dur
ing CMP
1799   
1800      P:000493 P:000493 502800            MOVE              A0,X:<SV_A0
1801      P:000494 P:000494 542900            MOVE              A1,X:<SV_A1
1802      P:000495 P:000495 522A00            MOVE              A2,X:<SV_A2
1803   
1804      P:000496 P:000496 512B00            MOVE              B0,X:<SV_B0
1805      P:000497 P:000497 552C00            MOVE              B1,X:<SV_B1
1806      P:000498 P:000498 532D00            MOVE              B2,X:<SV_B2
1807   
1808      P:000499 P:000499 442E00            MOVE              X0,X:<SV_X0
1809      P:00049A P:00049A 452F00            MOVE              X1,X:<SV_X1
1810   
1811      P:00049B P:00049B 463000            MOVE              Y0,X:<SV_Y0
1812      P:00049C P:00049C 473100            MOVE              Y1,X:<SV_Y1
1813   
Motorola DSP56300 Assembler  Version 6.3.4   06-03-07  12:16:30  PCI_SCUBA_main.asm  Page 37



1814      P:00049D P:00049D 00000C            RTS
1815   
1816   
1817   
1818                                ; ------------------------------------------------------------------------------------
1819                                WRITE_TO_PCI
1820                                ;-------------------------------------------------------------------------------------
1821                                ; sub routine to write two 16 bit words (stored in Y memory)
1822                                ; to host memory as PCI bus master.
1823                                ; results in a 32bit word written to host memory.
1824   
1825                                ; the 32 bit host address is in accumulator B.
1826                                ; this address is writen to DPMC (MSBs) and DPAR (LSBs)
1827                                ; address is incrememted by 4 (bytes) after write.
1828   
1829                                ; R2 is used as a pointer to Y:memory address
1830   
1831   
1832      P:00049E P:00049E 0A8A81            JCLR    #MTRQ,X:DPSR,*                    ; wait here if DTXM is full
                            00049E
1833   
1834      P:0004A0 P:0004A0 08DACC  TX_LSB    MOVEP             Y:(R2)+,X:DTXM          ; Least significant word to transmit
1835      P:0004A1 P:0004A1 08DACC  TX_MSB    MOVEP             Y:(R2)+,X:DTXM          ; Most significant word to transmit
1836   
1837   
1838      P:0004A2 P:0004A2 0C1890            EXTRACTU #$010010,B,A                     ; Get D31-16 bits only,
                            010010
1839      P:0004A4 P:0004A4 000000            NOP                                       ; top byte = $00 so FC1 = FC0 = 0
1840      P:0004A5 P:0004A5 210C00            MOVE              A0,A1
1841   
1842                                ; we are using two 16 bit writes to make a 32bit word
1843                                ; so FC1=0 and FC0=0 when A1 written to DPMC
1844   
1845      P:0004A6 P:0004A6 000000            NOP
1846      P:0004A7 P:0004A7 547000            MOVE              A1,X:DPMC               ; DSP master control register
                            FFFFC7
1847      P:0004A9 P:0004A9 000000            NOP
1848      P:0004AA P:0004AA 0C1890            EXTRACTU #$010000,B,A
                            010000
1849      P:0004AC P:0004AC 000000            NOP
1850      P:0004AD P:0004AD 210C00            MOVE              A0,A1
1851      P:0004AE P:0004AE 0140C2            OR      #$070000,A                        ; A1 gets written to DPAR register
                            070000
1852      P:0004B0 P:0004B0 000000            NOP
1853   
1854      P:0004B1 P:0004B1 08CC08  AGAIN1    MOVEP             A1,X:DPAR               ; Write to PCI bus
1855      P:0004B2 P:0004B2 000000            NOP                                       ; Pipeline delay
1856      P:0004B3 P:0004B3 000000            NOP
1857      P:0004B4 P:0004B4 0A8A84            JCLR    #MARQ,X:DPSR,*                    ; Bit is set if its a retry
                            0004B4
1858      P:0004B6 P:0004B6 0A8AAE            JSET    #MDT,X:DPSR,INC_ADD               ; If no error go to the next sub-block
                            0004BA
1859      P:0004B8 P:0004B8 0D0412            JSR     <PCI_ERROR_RECOVERY
1860      P:0004B9 P:0004B9 0C04B1            JMP     <AGAIN1
1861                                INC_ADD
1862      P:0004BA P:0004BA 205C13            CLR     A         (R4)+                   ; clear A and increment word count
1863      P:0004BB P:0004BB 50F400            MOVE              #>4,A0                  ; 4 bytes per word transfer on pcibus
                            000004
1864      P:0004BD P:0004BD 640618            ADD     A,B       R4,X:<WORD_COUNT        ; Inc bus address by 4 bytes, and save word 
count
1865      P:0004BE P:0004BE 00000C            RTS
1866   
Motorola DSP56300 Assembler  Version 6.3.4   06-03-07  12:16:30  PCI_SCUBA_main.asm  Page 38



1867                                ; -------------------------------------------------------------------------------------------
1868                                WRITE_32_TO_PCI
1869                                ; DMAs 32 x 16bit words to host memory as PCI burst.
1870                                ;-----------------------------------------------------------------------------------------------
1871      P:0004BF P:0004BF 3A2000            MOVE              #32,N2                  ; Number of 16bit words per transfer
1872      P:0004C0 P:0004C0 3C1000            MOVE              #16,N4                  ; Number of 32bit words per transfer
1873   
1874      P:0004C1 P:0004C1 627000            MOVE              R2,X:DSR0               ; Source address for DMA = pixel data
                            FFFFEF
1875      P:0004C3 P:0004C3 08F4AE            MOVEP             #DTXM,X:DDR0            ; Destination = PCI master transmitter
                            FFFFCC
1876      P:0004C5 P:0004C5 08F4AD            MOVEP             #>31,X:DCO0             ; DMA Count = # of pixels - 1
                            00001F
1877   
1878      P:0004C7 P:0004C7 0C1890            EXTRACTU #$010010,B,A                     ; Get D31-16 bits only
                            010010
1879      P:0004C9 P:0004C9 000000            NOP
1880      P:0004CA P:0004CA 210C00            MOVE              A0,A1                   ; [D31-16] in A1
1881      P:0004CB P:0004CB 000000            NOP
1882      P:0004CC P:0004CC 0140C2            ORI     #$0F0000,A                        ; Burst length = # of PCI writes
                            0F0000
1883      P:0004CE P:0004CE 000000            NOP                                       ;   = # of pixels / 2 - 1 ...$0F = 16
1884      P:0004CF P:0004CF 547000            MOVE              A1,X:DPMC               ; DPMC = B[31:16] + $3F0000
                            FFFFC7
1885   
1886      P:0004D1 P:0004D1 0C1890            EXTRACTU #$010000,B,A
                            010000
1887      P:0004D3 P:0004D3 000000            NOP
1888      P:0004D4 P:0004D4 210C00            MOVE              A0,A1                   ; Get PCI_ADDR[15:0] into A1[15:0]
1889      P:0004D5 P:0004D5 000000            NOP
1890      P:0004D6 P:0004D6 0140C2            ORI     #$070000,A                        ; A1 gets written to DPAR register
                            070000
1891      P:0004D8 P:0004D8 000000            NOP
1892   
1893   
1894      P:0004D9 P:0004D9 08F4AC  AGAIN2    MOVEP             #$8EFA51,X:DCR0         ; Start DMA with control register DE=1
                            8EFA51
1895      P:0004DB P:0004DB 08CC08            MOVEP             A1,X:DPAR               ; Initiate writing to the PCI bus
1896      P:0004DC P:0004DC 000000            NOP
1897      P:0004DD P:0004DD 000000            NOP
1898      P:0004DE P:0004DE 0A8A84            JCLR    #MARQ,X:DPSR,*                    ; Wait until the PCI operation is done
                            0004DE
1899      P:0004E0 P:0004E0 0A8AAE            JSET    #MDT,X:DPSR,WR_OK1                ; If no error go to the next sub-block
                            0004E4
1900      P:0004E2 P:0004E2 0D0412            JSR     <PCI_ERROR_RECOVERY
1901      P:0004E3 P:0004E3 0C04D9            JMP     <AGAIN2                           ; Just try to write the sub-block again
1902                                WR_OK1
1903      P:0004E4 P:0004E4 204C13            CLR     A         (R4)+N4                 ; increment number of 32bit word count
1904      P:0004E5 P:0004E5 50F400            MOVE              #>64,A0                 ; 2 bytes on pcibus per pixel
                            000040
1905      P:0004E7 P:0004E7 640618            ADD     A,B       R4,X:<WORD_COUNT        ; PCI address = + 2 x # of pixels (!!!)
1906      P:0004E8 P:0004E8 204A00            MOVE              (R2)+N2                 ; Pixel buffer address = + # of pixels
1907      P:0004E9 P:0004E9 00000C            RTS
1908   
1909                                ;------------------------------------------------------------
1910                                WRITE_512_TO_PCI
1911                                ;-------------------------------------------------------------
1912                                ; DMAs 128 x 16bit words to host memory as PCI burst
1913                                ; does x 4 of these (total of 512 x 16bit words written to host memory)
1914                                ;
1915                                ; R2 is used as a pointer to Y:memory address
1916   
Motorola DSP56300 Assembler  Version 6.3.4   06-03-07  12:16:30  PCI_SCUBA_main.asm  Page 39



1917   
1918      P:0004EA P:0004EA 3A8000            MOVE              #128,N2                 ; Number of 16bit words per transfer.
1919      P:0004EB P:0004EB 3C4000            MOVE              #64,N4                  ; NUmber of 32bit words per transfer.
1920   
1921                                ; Make sure its always 512 pixels per loop = 1/2 FIFO
1922      P:0004EC P:0004EC 627000            MOVE              R2,X:DSR0               ; Source address for DMA = pixel data
                            FFFFEF
1923      P:0004EE P:0004EE 08F4AE            MOVEP             #DTXM,X:DDR0            ; Destination = PCI master transmitter
                            FFFFCC
1924      P:0004F0 P:0004F0 08F4AD            MOVEP             #>127,X:DCO0            ; DMA Count = # of pixels - 1
                            00007F
1925   
1926                                ; Do loop does 4 x 128 pixel DMA writes = 512.
1927                                ; need to recalculate hi and lo parts of address
1928                                ; for each burst.....Leach code doesn't do this since not
1929                                ; multiple frames...so only needs to inc low part.....
1930   
1931      P:0004F2 P:0004F2 060480            DO      #4,WR_BLK0                        ; x # of pixels = 512
                            000515
1932   
1933      P:0004F4 P:0004F4 0C1890            EXTRACTU #$010010,B,A                     ; Get D31-16 bits only
                            010010
1934      P:0004F6 P:0004F6 000000            NOP
1935      P:0004F7 P:0004F7 210C00            MOVE              A0,A1                   ; [D31-16] in A1
1936      P:0004F8 P:0004F8 000000            NOP
1937      P:0004F9 P:0004F9 0140C2            ORI     #$3F0000,A                        ; Burst length = # of PCI writes
                            3F0000
1938      P:0004FB P:0004FB 000000            NOP                                       ;   = # of pixels / 2 - 1 ...$3F = 63
1939      P:0004FC P:0004FC 547000            MOVE              A1,X:DPMC               ; DPMC = B[31:16] + $3F0000
                            FFFFC7
1940   
1941   
1942      P:0004FE P:0004FE 0C1890            EXTRACTU #$010000,B,A
                            010000
1943      P:000500 P:000500 000000            NOP
1944      P:000501 P:000501 210C00            MOVE              A0,A1                   ; Get PCI_ADDR[15:0] into A1[15:0]
1945      P:000502 P:000502 000000            NOP
1946      P:000503 P:000503 0140C2            OR      #$070000,A                        ; A1 gets written to DPAR register
                            070000
1947      P:000505 P:000505 000000            NOP
1948   
1949   
1950      P:000506 P:000506 08F4AC  AGAIN0    MOVEP             #$8EFA51,X:DCR0         ; Start DMA with control register DE=1
                            8EFA51
1951      P:000508 P:000508 08CC08            MOVEP             A1,X:DPAR               ; Initiate writing to the PCI bus
1952      P:000509 P:000509 000000            NOP
1953      P:00050A P:00050A 000000            NOP
1954      P:00050B P:00050B 0A8A84            JCLR    #MARQ,X:DPSR,*                    ; Wait until the PCI operation is done
                            00050B
1955      P:00050D P:00050D 0A8AAE            JSET    #MDT,X:DPSR,WR_OK0                ; If no error go to the next sub-block
                            000511
1956      P:00050F P:00050F 0D0412            JSR     <PCI_ERROR_RECOVERY
1957      P:000510 P:000510 0C0506            JMP     <AGAIN0                           ; Just try to write the sub-block again
1958                                WR_OK0
1959   
1960      P:000511 P:000511 204C13            CLR     A         (R4)+N4                 ; clear A and increment word count
1961      P:000512 P:000512 50F400            MOVE              #>256,A0                ; 2 bytes on pcibus per pixel
                            000100
1962      P:000514 P:000514 640618            ADD     A,B       R4,X:<WORD_COUNT        ; Inc bus address by # of bytes, and save wo
rd count
1963      P:000515 P:000515 204A00            MOVE              (R2)+N2                 ; Pixel buffer address = + # of pixels
1964                                WR_BLK0
Motorola DSP56300 Assembler  Version 6.3.4   06-03-07  12:16:30  PCI_SCUBA_main.asm  Page 40



1965      P:000516 P:000516 00000C            RTS
1966   
1967                                ;-----------------------------
1968                                XMT_DLY
1969                                ;-----------------------------
1970                                ; Short delay for reliability
1971   
1972      P:000517 P:000517 000000            NOP
1973      P:000518 P:000518 000000            NOP
1974      P:000519 P:000519 000000            NOP
1975      P:00051A P:00051A 00000C            RTS
1976   
1977                                ;-------------------------------------------------------
1978                                XMT_WD_FIBRE
1979                                ;-----------------------------------------------------
1980                                ; 250 MHz code - Transmit contents of Accumulator A1 to the MCE
1981                                ; we want to send 32bit word in little endian fomat to the host.
1982                                ; i.e. b4b3b2b1 goes b1, b2, b3, b4
1983                                ; currently the bytes are in this order:
1984                                ;  A1 = $00 b2 b1
1985                                ;  A0 = $00 b4 b3
1986                                ;  A = $00 00 b2 b1 00 b4 b3
1987   
1988                                ; This subroutine must take at least 160ns (4 bytes at 25Mbytes/s)
1989   
1990      P:00051B P:00051B 000000            NOP
1991      P:00051C P:00051C 000000            NOP
1992   
1993                                ; split up 4 bytes b2, b1, b4, b3
1994   
1995      P:00051D P:00051D 0C1D20            ASL     #16,A,A                           ; shift byte b2 into A2
1996      P:00051E P:00051E 60F400            MOVE              #$FFF000,R0             ; Memory mapped address of transmitter
                            FFF000
1997   
1998      P:000520 P:000520 214700            MOVE              A2,Y1                   ; byte b2 in Y1
1999   
2000      P:000521 P:000521 0C1D10            ASL     #8,A,A                            ; shift byte b1 into A2
2001      P:000522 P:000522 000000            NOP
2002      P:000523 P:000523 214600            MOVE              A2,Y0                   ; byte b1 in Y0
2003   
2004      P:000524 P:000524 0C1D20            ASL     #16,A,A                           ; shift byte b4 into A2
2005      P:000525 P:000525 000000            NOP
2006      P:000526 P:000526 214500            MOVE              A2,X1                   ; byte b4 in X1
2007   
2008   
2009      P:000527 P:000527 0C1D10            ASL     #8,A,A                            ; shift byte b3 into A2
2010      P:000528 P:000528 000000            NOP
2011      P:000529 P:000529 214400            MOVE              A2,X0                   ; byte b3 in x0
2012   
2013                                ; transmit b1, b2, b3 ,b4
2014   
2015      P:00052A P:00052A 466000            MOVE              Y0,X:(R0)               ; byte b1 - off it goes
2016      P:00052B P:00052B 476000            MOVE              Y1,X:(R0)               ; byte b2 - off it goes
2017      P:00052C P:00052C 446000            MOVE              X0,X:(R0)               ; byte b3 - off it goes
2018      P:00052D P:00052D 456000            MOVE              X1,X:(R0)               ; byte b4 - off it goes
2019   
2020      P:00052E P:00052E 000000            NOP
2021      P:00052F P:00052F 000000            NOP
2022      P:000530 P:000530 00000C            RTS
2023   
2024   
2025                                BOOTCODE_END
Motorola DSP56300 Assembler  Version 6.3.4   06-03-07  12:16:30  PCI_SCUBA_main.asm  Page 41



2026                                 BOOTEND_ADDR
2027      000531                              EQU     @CVI(BOOTCODE_END)
2028   
2029                                PROGRAM_END
2030      000531                    PEND_ADDR EQU     @CVI(PROGRAM_END)
2031                                ;---------------------------------------------
2032   
2033   
2034                                ; --------------------------------------------------------------------
2035                                ; --------------- x memory parameter table ---------------------------
2036                                ; --------------------------------------------------------------------
2037   
2038      X:000000 P:000531                   ORG     X:VAR_TBL,P:
2039   
2040   
2041                                          IF      @SCP("ONCE","ROM")                ; Boot ROM code
2043                                          ENDIF
2044   
2045                                          IF      @SCP("ONCE","ONCE")               ; Download via ONCE debugger
2046                                 VAR_TBL_START
2047      000531                              EQU     @LCV(L)
2048                                          ENDIF
2049   
2050                                ; -----------------------------------------------
2051                                ; do not move these (X:0 --> x:3)
2052 d    X:000000 P:000531 000000  STATUS    DC      0
2053 d                               FRAME_COUNT
2054 d    X:000001 P:000532 000000            DC      0                                 ; used as a check....... increments for ever
y frame write.....must be cleared by host.
2055 d                               PRE_CORRUPT
2056 d    X:000002 P:000533 000000            DC      0
2057 d    X:000003 P:000534 410104  REV_NUMBER DC     $410104                           ; byte 0 = minor revision #
2058                                                                                    ; byte 1 = mayor revision #
2059                                                                                    ; byte 2 = release Version (ascii letter)
2060 d    X:000004 P:000535 070306  REV_DATA  DC      $070306                           ; data: day-month-year
2061 d    X:000005 P:000536 B1FE60  P_CHECKSUM DC     $B1FE60                           ;**** DO NOT CHANGE
2062                                ; -------------------------------------------------
2063 d    X:000006 P:000537 000000  WORD_COUNT DC     0                                 ; word count.  Number of words successfully 
writen to host in last packet.
2064 d    X:000007 P:000538 000000  NUM_DUMPED DC     0                                 ; number of words (16-bit) dumped to Y memor
y (512) after an HST timeout.
2065                                ; ----------------------------------------------------------------------------------------------
----------------
2066   
2067 d    X:000008 P:000539 000000  DRXR_WD1  DC      0
2068 d    X:000009 P:00053A 000000  DRXR_WD2  DC      0
2069 d    X:00000A P:00053B 000000  DRXR_WD3  DC      0
2070 d    X:00000B P:00053C 000000  DRXR_WD4  DC      0
2071 d    X:00000C P:00053D 000000  DTXS_WD1  DC      0
2072 d    X:00000D P:00053E 000000  DTXS_WD2  DC      0
2073 d    X:00000E P:00053F 000000  DTXS_WD3  DC      0
2074 d    X:00000F P:000540 000000  DTXS_WD4  DC      0
2075   
2076 d    X:000010 P:000541 000000  PCI_WD1_1 DC      0
2077 d    X:000011 P:000542 000000  PCI_WD1_2 DC      0
2078 d    X:000012 P:000543 000000  PCI_WD2_1 DC      0
2079 d    X:000013 P:000544 000000  PCI_WD2_2 DC      0
2080 d    X:000014 P:000545 000000  PCI_WD3_1 DC      0
2081 d    X:000015 P:000546 000000  PCI_WD3_2 DC      0
2082 d    X:000016 P:000547 000000  PCI_WD4_1 DC      0
2083 d    X:000017 P:000548 000000  PCI_WD4_2 DC      0
2084 d    X:000018 P:000549 000000  PCI_WD5_1 DC      0
Motorola DSP56300 Assembler  Version 6.3.4   06-03-07  12:16:30  PCI_SCUBA_main.asm  Page 42



2085 d    X:000019 P:00054A 000000  PCI_WD5_2 DC      0
2086 d    X:00001A P:00054B 000000  PCI_WD6_1 DC      0
2087 d    X:00001B P:00054C 000000  PCI_WD6_2 DC      0
2088   
2089   
2090 d    X:00001C P:00054D 000000  HEAD_W1_1 DC      0
2091 d    X:00001D P:00054E 000000  HEAD_W1_0 DC      0
2092 d    X:00001E P:00054F 000000  HEAD_W2_1 DC      0
2093 d    X:00001F P:000550 000000  HEAD_W2_0 DC      0
2094 d    X:000020 P:000551 000000  HEAD_W3_1 DC      0
2095 d    X:000021 P:000552 000000  HEAD_W3_0 DC      0
2096 d    X:000022 P:000553 000000  HEAD_W4_1 DC      0
2097 d    X:000023 P:000554 000000  HEAD_W4_0 DC      0
2098   
2099   
2100 d    X:000024 P:000555 000000  REP_WD1   DC      0
2101 d    X:000025 P:000556 000000  REP_WD2   DC      0
2102 d    X:000026 P:000557 000000  REP_WD3   DC      0
2103 d    X:000027 P:000558 000000  REP_WD4   DC      0
2104   
2105 d    X:000028 P:000559 000000  SV_A0     DC      0
2106 d    X:000029 P:00055A 000000  SV_A1     DC      0
2107 d    X:00002A P:00055B 000000  SV_A2     DC      0
2108 d    X:00002B P:00055C 000000  SV_B0     DC      0
2109 d    X:00002C P:00055D 000000  SV_B1     DC      0
2110 d    X:00002D P:00055E 000000  SV_B2     DC      0
2111 d    X:00002E P:00055F 000000  SV_X0     DC      0
2112 d    X:00002F P:000560 000000  SV_X1     DC      0
2113 d    X:000030 P:000561 000000  SV_Y0     DC      0
2114 d    X:000031 P:000562 000000  SV_Y1     DC      0
2115   
2116 d    X:000032 P:000563 000000  SV_SR     DC      0                                 ; stauts register save.
2117   
2118 d    X:000033 P:000564 000000  ZERO      DC      0
2119 d    X:000034 P:000565 000001  ONE       DC      1
2120 d    X:000035 P:000566 000004  FOUR      DC      4
2121   
2122 d                               PACKET_SIZE_LOW
2123 d    X:000036 P:000567 000000            DC      0
2124 d                               PACKET_SIZE_HIH
2125 d    X:000037 P:000568 000000            DC      0
2126   
2127 d    X:000038 P:000569 00A5A5  PREAMB1   DC      $A5A5                             ; pramble 16-bit word....2 of which make up 
first preamble 32bit word
2128 d    X:000039 P:00056A 005A5A  PREAMB2   DC      $5A5A                             ; preamble 16-bit word....2 of which make up
 second preamble 32bit word
2129 d    X:00003A P:00056B 004441  DATA_WD   DC      $4441                             ; "DA"
2130 d    X:00003B P:00056C 005250  REPLY_WD  DC      $5250                             ; "RP"
2131   
2132 d                               TOTAL_BUFFS
2133 d    X:00003C P:00056D 000000            DC      0                                 ; total number of 512 buffers in packet
2134 d                               LEFT_TO_READ
2135 d    X:00003D P:00056E 000000            DC      0                                 ; number of words (16 bit) left to read afte
r last 512 buffer
2136 d                               LEFT_TO_WRITE
2137 d    X:00003E P:00056F 000000            DC      0                                 ; number of woreds (32 bit) to write to host
 i.e. half of those left over read
2138 d                               NUM_LEFTOVER_BLOCKS
2139 d    X:00003F P:000570 000000            DC      0                                 ; small block DMA burst transfer
2140   
2141 d                               DATA_DLY_VAL
2142 d    X:000040 P:000571 000000            DC      0                                 ; data delay value..  Delay added to first f
Motorola DSP56300 Assembler  Version 6.3.4   06-03-07  12:16:30  PCI_SCUBA_main.asm  Page 43



rame received after GO command
2143   
2144                                ;----------------------------------------------------------
2145   
2146   
2147   
2148                                          IF      @SCP("ONCE","ROM")                ; Boot ROM code
2150                                          ENDIF
2151   
2152                                          IF      @SCP("ONCE","ONCE")               ; Download via ONCE debugger
2153                                 VAR_TBL_END
2154      000572                              EQU     @LCV(L)
2155                                          ENDIF
2156   
2157                                 VAR_TBL_LENGTH
2158      000041                              EQU     VAR_TBL_END-VAR_TBL_START
2159   
2160   
2161                                          IF      @CVS(N,*)>=APPLICATION
2163                                          ENDIF
2164   
2165   
2166                                ;--------------------------------------------
2167                                ; APPLICATION AREA
2168                                ;---------------------------------------------
2169                                          IF      @SCP("ONCE","ROM")                ; Download via ONCE debugger
2171                                          ENDIF
2172   
2173                                          IF      @SCP("ONCE","ONCE")               ; Download via ONCE debugger
2174      P:000800 P:000800                   ORG     P:APPLICATION,P:APPLICATION
2175                                          ENDIF
2176   
2177                                ; starts with no application loaded
2178                                ; so just reply with an error if we get a GOA command
2179      P:000800 P:000800 44F400            MOVE              #'REP',X0
                            524550
2180      P:000802 P:000802 440C00            MOVE              X0,X:<DTXS_WD1          ; REPly
2181      P:000803 P:000803 44F400            MOVE              #'GOA',X0
                            474F41
2182      P:000805 P:000805 440D00            MOVE              X0,X:<DTXS_WD2          ; echo command sent
2183      P:000806 P:000806 44F400            MOVE              #'ERR',X0
                            455252
2184      P:000808 P:000808 440E00            MOVE              X0,X:<DTXS_WD3          ; No Application Loaded
2185      P:000809 P:000809 44F400            MOVE              #'NAL',X0
                            4E414C
2186      P:00080B P:00080B 440F00            MOVE              X0,X:<DTXS_WD4          ; write to PCI memory error;
2187      P:00080C P:00080C 0D047D            JSR     <RESTORE_REGISTERS
2188      P:00080D P:00080D 0D0435            JSR     <PCI_MESSAGE_TO_HOST
2189      P:00080E P:00080E 0A0000            BCLR    #APPLICATION_LOADED,X:<STATUS
2190      P:00080F P:00080F 0C016A            JMP     PACKET_IN
2191   
2192   
2193      000810                    END_ADR   EQU     @LCV(L)                           ; End address of P: code written to ROM
2194   
**** 2195 [PCI_SCUBA_build.asm 25]:  Build is complete
2195                                          MSG     ' Build is complete'
2196   
2197   
2198   

0    Errors
0    Warnings
Motorola DSP56300 Assembler  Version 6.3.4   06-03-07  12:16:30  PCI_SCUBA_build.asm  Page 44





