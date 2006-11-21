/************************************************************************************/
/* 	Scuba 2 Power Supply Controller - SC2_ELE_S565_102D
		Tom Felton - Feb 22, 2006
 		Stuart Hadfield - July/August 2006		 
/************************************************************************************/
// Revision history: 
// $Log: scuba2ps.c,v $
// Revision 1.9  2006/11/20 23:22:00  stuartah
// Cleaned code, improved commenting, implemented changes for PSUC rev. G
//
// Revision 1.8  2006/10/03 07:38:34  stuartah
// Added presence detection of DS18S20s
//
// Revision 1.7  2006/10/03 05:59:12  stuartah
// Tested in Subrack, Basic Command working
//
// Revision 1.6  2006/09/07 20:37:01  stuartah
// Cleaned up init() and re-organized main loop structure
//
// Revision 1.5  2006/09/05 20:06:20  stuartah
// Changed i2c.c to MAX1271.c (code for interfacing ADCs, does not use i2c protocol)
//
// Revision 1.4  2006/08/31 19:30:38  stuartah
// Added functionality for measuring fan speeds
//
// Revision 1.3  2006/08/30 19:54:19  stuartah
// Implemented checksum
//
// Revision 1.2  2006/08/29 21:06:06  stuartah
// Initial CVS Build - Most Basic Functionality Implemented
//	
/********************************************************************************	
Refer to the following Data Sheets:
		Processor - Atmel AT89C5131AM
		Temperature Monitoring & Silicon ID - Dallas DS18S20-PAR
		ADC for Power Supply Voltage Monitoring - Maxim MAX1270ACAI
		EEPROM non-volatile memory - Atmel AT25128A

	NOTE: THIS PROGRAM IS NO WHERE NEAR COMPLETE OR TESTED
	The I/O pins are set correctly for this version (revF).
*********************************************************************************/

/**********	Version 2.2	*****************
Polling and communication functionality seems to be working	*/


// Header File containing function prototypes and global variable declarations
#include "scuba2ps.h"

// Constant Variables
char code asc_version[] =  "\n\rPSUC v2.10\n\r\0";				// Software Version Serial Message
char code software_version_byte = 0x23;		 					// 1 byte Software Version 


/****************************************************************************************
 *  Main Program		   	   *
 *************************** */

main() 
{ 
   	// Initialize Hardware and Software Variables
	init();											
	
	// Output Version on Serial Port
	snd_msg(asc_version);	

   	// Initial Power-Up
	sequence_on();					
	ENABLE_BLINK;
	//reset_MCE();						// ** This line disables initial subrack reset **
   	  
  	/***  Main Loop - Periodically update PSU data block, respond to Clock Card / RS232 Commands  ***/
	while(TRUE) {								

	  	// Serial I/O message ready to parse
	  	if ( sio_msg_complete == SET ) {					
	     	sio_msg_complete = CLEAR;
		 	sio_rx_idx = 0;								// reset message pointer
	  	 	switch ( sio_rxbuf[0] ) {					// parse message
				case 'R':								// Reset MCE Command
			   		reset_MCE();
			   		break;

				case 'V':								// Respond with Software Version
			   		snd_msg(asc_version);
			   		break;

		/*		case 'D':								// Respond with PSU data block -- not yet implemented
					snd_msg(ps_data_block);				// **** problem with this is NULL in datablock will terminate transmission 
					break;		*/			
		    
				default:
			   		break;
		 	}
	  	}

		// Listen for data request from clock card
		cc_spi = ~SREQ;									// SREQ active low

	  	// Time to re-poll data
	  	if ( poll_data == SET ) {						// polling rate ~ 3Hz, CC Request Rate ~ 0.5Hz			
	  	 	update_data_block();
			poll_data = CLEAR;							// Data Poll Complete
	  	}
		
		// Send data block if it has been requested
		if ( cc_spi == TRUE) {		 			   
	  	  	send_psu_data_block();						// Time to send SPI Data to Clock Card
			cc_spi = FALSE;  							// Data Block Transmission Complete			
		}
	
		// Act on command from Clock Card
	  	if ( cc_command != NULL )		
		 	switch ( *cc_command ) {					// parse received command	
				
				case 'C':								// Cycle Power Command
					cycle_power();
					cc_command = NULL;
					break;
				
				case 'R':								// Reset MCE Command
			   		reset_MCE();
					cc_command = NULL;
			   		break;

				case 'T':								// Turn Off Command
					sequence_off();
					cc_command = NULL;
					break;

		    	default:								// Status Request or erroneous command.  Difference is ACK/NAK.
					cc_command = NULL;
			   		break;  
		}

	}
}

/****************************************************************************************
 *  Initialize		   	   *
 *************************** */

void init(void)
{
	int i = 0;					// temporary index variable

/**************		Hardware Setup		**************/
	// Set all input ports for input and output ports to default values	-- see schematic and io.h
	// IO Port Setup  --  1=Input(or Special Function), 0=Output
	P0 = 0x66;		//0110 0110		//****** changed to acomidate SSTRB lines in Rev G
   	//P0 = 0x60;	//0110 0000
	P1 = 0xff;		//1111 1111
   	P2 = 0xbe;		//1011 1110	 	// Intialize PSU OFF
   	P3 = 0xdf;		//1101 1111

	/* SPI setup				-- these declarations are redundant.  done in port settings above				
	CS_EEPROM = 1;				// CableSelect lines active low	
	CS_VADC = 1;
	CS_IADC = 1;
	CCSS=1;
	//SREQ = 0;					// SREQ active low but this is needed to not overload buffer U5 - PROTOTYPE PSUC REV F ONLY
	SREQ = 1;					// Port bit set for input -- REV G ONLY
	MISO = 1;					// Set for input
	MOSI = 1; 	  */
	
	// Counter/Timer 0 used as a Timer in Mode 1.  Interrupt Rate: 32mS	
	TH0 = 0;
   	TL0 = 135;
   	TR0 = ON;					// start timer 0

	// Counter/Timer 1 used as a Timer in Mode 1.  Interrupt Rate: 5e-3 Sec
   	TL1 = LS_RELOAD_5mS;
   	TH1 = MS_RELOAD_5mS;
   	TMOD = 0x11;

	// Timer 2 used as count up counter for soft reset function, triggered when external reset button pushed
	T2CON = 0x02;       		// 0b00000010 -- set for counter operation, external trigger on T2 pin
	TH2 = 0xFF;					// set counter so single external trigger causes interrupt -> soft reset
	TL2 = 0xFF;
	RCAP2H = 0xFF;				// same auto-reload values				
	RCAP2L = 0xFF;
	TR2 = 1;					// start timer 2

	// Serial I/O Setup:  Using Internal Baud Rate Generator on 89C5131A.  Set to Serial Mode 1 at 9600 Baud using 24MHz Clock
    SCON = 0x50;				// 0101 0000
	BDRCON = 0x1e; 		 		// 0001 1110
	CKCON0 = 0x7f;		 		// X2 set but 12 clocks per peripheral cycle -> 500ns pert tick
	PCON = 0x80; 		 		// 1000 0000 Double Baud Rate all others default
	BRL = 100;					// Baud rate reload - sets Baud rate to 9600

	//PCA Counter Init	  		// not implemented
	//CKCON0 |= 0x20;			// sets to 500ns per PCA tick
	//CMOD |= 0x81;				// 1000 0001 Set PCA to stop counting during idle mode, disable PCA interrupts, and count Fclk-periph/6 (250ns period)
	//CCON |= 0x01;				// enable PCA interrupts 

	// LED Setup
	LEDCON = 0xfC;				// LED1-3 10mA Current Source
	LED_FAULT = 0;				// Off
	LED_STATUS = 1;				// Off
	LED_OUTON = 1;				// Off

	// SPI Setup - Sets up spi in master mode with Fclk Periph/16 as baud rate and without slave select pin.
	// SPCON = SPI_MSTR | SPI_EN | SPI_SSDIS | SPI_CPOL1 | SPI_1M5Hz;	CPHA = 0, transfer on falling SCLK
    SPCON |= SPI_MSTR;         	// Master mode    
	//SPCON |= SPI_6MHz;		// Fclk Periph/4 (6MHz)
    SPCON |= SPI_1M5Hz;			// Fclk Periph/16 (1.5Mhz)
	SPCON &= SPI_CPOL0;        	// CPOL = 0, Clk idle state 0
    SPCON &= SPI_CPHA0;        	// CPHA = 0, sample data on Clk rising edge
    SPCON |= SPI_SSDIS;			// Disable SS
    SPCON |= SPI_EN;           	// Run SPI
    
	// Interrupt Setup
	ES = 1;			 			// Enable SIO Interrupts
	IEN1 |= 0x04;               // Enable SPI Interrupts
	ET0 = 1;          			// Enable Timer0 Interrupts
    ET1 = 1;			 		// Enable Timer1 Interrupts
	ET2 = 1;					// Enable Timer2 Interrupts
    EA = 1; 					// Enable Global Interrupts
	//EC = 1;					// Enable all PCA Interrupts


/**************** 	Initialize Variables 	********************/		// Some of this is redundant							
	// Initialize flags
	poll_data = SET; 			// Initial data poll
	cc_spi = CLEAR;				// Clear remaining flags
	spi_complete = CLEAR;		// SPI transmission/reception complete status bit
	sio_msg_complete = CLEAR;
	timeup_T1 = CLEAR;
	DISABLE_BLINK;		  		// Initially disable LED blink
		
	// Initialize other vars	
	spi_idx = 0;				// Reset pointer for SPI data output
	sio_rx_idx = 0;				// reset serial message pointer
	bcnt = 0;
	num_T1_ints = 0;
	running_checksum = 0;
	
	// Initialize pointers
	cc_command = NULL;
	msg_ptr = NULL;
		
	// Initialize data blocks to all zeros
	for(i=0; i < CC_SPI_BLEN; i++) {				
		 	ps_data_blk[i] = 0;					
			rcv_spi_blk[i] = 0;
	}
	for(i=0; i < BUF_SIZE; i++) {				
		 	sio_rxbuf[i] = 0;	
	}
	
	// Initialize PSU data block - these aspects of data block set only once
	ds_get_4byte_id(PSUC_DS18S20, SILICON_ID);	 // assign ID to PSU block
	*SOFTWARE_VERSION = software_version_byte; 	 // Software Version byte


/*****************		Initialize Devices 		***************/	
	// check for presence of DS18S20 temperature sensors	
	temp1_present = ds_initialize(PSU_DS18S20);		
	temp2_present =	ds_initialize(DTEMP1_ID);
	temp3_present =	ds_initialize(DTEMP2_ID);	
}

/****************************************************************************************
 *  Turn-On (Startup) Sequence   	   *
 ***************************/

void sequence_on (void)
{
	//wait_time( T100mS );
	nPSU_ON = 0;
	wait_time( T100mS );
	nCORE_ON = 0;
	LED_OUTON = 0;								// 0 = LED on
}

/****************************************************************************************
 *  Turn-Off Sequence   	   *
 *******************************/

void sequence_off (void)
{
	nCORE_ON = 1;
	wait_time( T100mS );
	nPSU_ON = 1;
    wait_time( T100mS );
	LED_OUTON = 1;								// LED off
}

/****************************************************************************************
 *  Reset MCE  	   *
 *******************/

void reset_MCE (void)
{
	BRST = 1;			 						// Pulse Reset Line for 100mS
	wait_time( T100mS );
	BRST = 0;
}

/****************************************************************************************
 *  Cycle Power  	   *
 ***********************/

void cycle_power (void)
{
	sequence_off();
	wait_time( T100mS );
	sequence_on();
}

/****************************************************************************************
/* 	Send PSU Data Block to CC via SPI  	   *
/*******************************************/
// Sends the 36 byte PSU Status Block to the CC via SPI interface while simultaneously 
// receiving a command from the CC.  ACK/NAK byte near end of datablock indicates whether
// a valid command was received during the SAME datablock transmission.

void send_psu_data_block (void)
{				
	// Begin Transaction
	spi_idx = 0;								// Start at beginning of data block
	CCSS = 0;									// Select Clock Card (as slave) to listen on SPI bus		
		 	
	// Send first 34 of 36 bytes (need to calculate checksum based on ACK/NAK byte after CC command recv'd)
	while(spi_idx < ACK_BYTE_POS) {				
		SPDAT = ps_data_blk[spi_idx];  			// send byte #spi_idx
		while(!spi_complete);					// wait for end of byte transmission
		spi_complete = 0;						// clear software flag
		spi_idx++;								// increment data block index
 	}
	
	// Update ACK/NAK byte and send
	parse_command();							// Check if command received and set ACK/NAK byte

	// Send ACK/NAK byte
	SPDAT = ps_data_blk[ACK_BYTE_POS];  		
	while(!spi_complete);						// wait for end of byte transmission
	spi_complete = 0;							// clear software flag
	
	// Update Checkbyte and send		
	COMPLETE_CHECKSUM;							// 2's compliment, so CHECKSUM_BYTE + all other bytes = 0	
	SPDAT = ps_data_blk[ACK_BYTE_POS + 1];  	// Send Check byte
	while(!spi_complete);						// wait for end of byte transmission
	spi_complete = 0;							// clear software flag
		
	// Finish Transaction
	CCSS = 1;									// De-select Clock Card	 				
}

/****************************************************************************************
/*  Wait Timer - 5ms Multiples   	   */
/***************************************/
//Sets up T1 interrupt to loops x 5mS, waits specified time then returns
 
void wait_time (unsigned char loops)
{
	timeup_T1 = CLEAR;
 	TL1 = LS_RELOAD_5mS;						// Interrupt interval set to 5mS
   	TH1 = MS_RELOAD_5mS;
   	num_T1_ints = loops;						// time expires after 1 interrupt
   	TR1 = ON;
   	while ( timeup_T1 != SET );					// wait here for specified time to expire
}

/****************************************************************************************
/*  Microsecond Wait Timer   	   */
/***********************************/
// returns 2*time_us_div2 + 3 (in uS)....tested and verified
// therefore works for a minimum of 3us (time_us_div2 = 0) or maximum of 513us (time_us_div2 = 0xFF)
// from numbers below, delay = time_us_div2 * (1.25+ 0.25 + 0.5) + 1.25+ 0.25 + 1 + 0.5 = 2*time_us_div2 + 3 (in uS)

void wait_time_x2us_plus3 (unsigned char time_us_div2)		// 1.25 us to call function
{	
	while(time_us_div2>0) {						// each comparison takes 1.25 uS
		time_us_div2--;							// 250ns operation
	}											// 500ns delay to begining of loop
	_nop_();									// 250 ns delay to make total delay an integer
} 												// 500 ns to return from function

/***************************************************************************************/
/* Timer0 Service Routine     			*/ 
/****************************************/
// Interrupt occurs every 32ms when enabled	  -  used for LED blink	and polling data

void timer0_isr (void) interrupt 1 using 3
{
	++bcnt;
	if ( bcnt == BRATE320mS) {
      	bcnt = 0;
	  	poll_data = SET;						// poll data every 320ms
	  	if (blink_en == SET)
	   		LED_FAULT = ~LED_FAULT;				// toggle LED every 320ms if enabled
   }
}

/***************************************************************************************/
/* Timer1 Service Routine     			*/ 
/****************************************/
// Interrupt occurs every 5ms when enabled	 - used for wait_time()

void timer1_isr (void) interrupt 3 using 3
{
   --num_T1_ints;								// count the number of interupts
   if (num_T1_ints == 0) {						// check if interrupt time is up
      TR1=OFF;									// Stop the timer
	  timeup_T1 = SET;							// Indicate time is up
   }
   else {										// reload timer
      TL1 = LS_RELOAD_5mS;						// interrupts always occur every 5mS
	  TH1 = MS_RELOAD_5mS;
   }
}

/***************************************************************************************/
/* Timer2 Service Routine     			*/ 
/****************************************/
// Interrupt occurs ONLY when external SOFT RESET button pushed

void timer2_isr (void) interrupt 5 using 0
{
	TF2=0;										// clear interrupt
	
	blink_en =~ blink_en;
	//soft_reset();
}


/***************************************************************************************/
/* Send Serial Message     */ 
/***************************/

void snd_msg (char *message)
{
   msg_ptr = message;
   TI = SET;									// Generates SIO interrupt
}

/***************************************************************************************/
/* Serial Interrupt Service Routine     */ 
/****************************************/
// Interrupt driven serial I/O

void serial_isr (void) interrupt 4 using 2
{
	char msg;
   	
	// Transmitted Data Interrupt
	if ( TI == SET ) {                     		
      	TI = CLEAR;								// Clears TI Interrupt
	  	msg = *msg_ptr;
	  	if (msg != NULL) {						// If message not NULL, load into transmission buffer 
	     	++msg_ptr;
			SBUF = msg;	
	  	}
	  	else msg_ptr = 0;
  	}	
   
   	// Received Data Interrupt
   	if ( RI == SET ) {                			
      	RI = CLEAR;								// Clears RI Interrupt
	  	msg = SBUF;
		sio_rxbuf[sio_rx_idx++] = msg;			// *****these three lines are suspect, need to fix
	  	if (sio_rx_idx >= (BUF_SIZE-1))
	     	--sio_rx_idx;
	  	if (msg == LF) {	  					// LineFeed indicates end of message
	     	sio_rx_idx = 0;
	     	sio_msg_complete = SET;				// Indicate entire message received
	  	}
   	}   
}

/***************************************************************************************/
/* SPI Interrupt Service Routine     */ 
/*************************************/
// read and clear spi status register

void spi_isr (void) interrupt 9
{
	switch( SPSTA )         			
	{
		// SPIF flag set --> transmission complete
		case 0x80:								
           	rcv_spi_blk[spi_idx] = SPDAT; 		// read receive data
		   	spi_complete = 1;					// indicate transaction finished
			break;

	   	/* error cases -> refer to pg. 96 in AT89 datasheet */
		// mode fault
		case 0x10:							
         	// this does not apply as single master on SPI bus and SSDisable bit set in SPSTA register 													   								
			break;
	
		// write collision
		case 0x40:				   			
         	// write collision does NOT cause an interrupt therefore this should be elsewhere if needed
			// currently ONLY the function send_psu_data_block() ever writes to SPDAT so write collision not possible													 
			break;

		default:
			break;
	}
}
		
/***************************************************************************************/
/* Retrieve Data Block       */ 
/*****************************/	 
//Updates PSU Data Block with Current Values

void update_data_block (void)
{
	// Fan Speeds
	// get_fan_speeds();										// not implemented

	// DS18S20 - Temperatures - read only if present
	if (temp1_present){
		ds_get_temperature(PSU_DS18S20, PSU_TEMP_1);  			// temperature 1 
	}
	else														// for now read PSU DS if connected else read PSUC DS
		ds_get_temperature(PSUC_DS18S20, PSU_TEMP_1);
			
	if (temp2_present)
		ds_get_temperature(DTEMP1_ID, PSU_TEMP_2);				// temperature 2 
	if (temp3_present)
		ds_get_temperature(DTEMP2_ID, PSU_TEMP_3);				// temperature 3

	/*** ADC - Voltage and Current Readings - refer to documentation ***/
	// Ground reading scaled to 2mV per division (+/- 2.047V range)
	read_adc(ADC_CH5, ADC_BI_5V, VOLTAGE, ADC_OFFSET);			// Grounded ADC input channel reading (bipolar)
	
	// Voltages scaled to ~61% of nominal values, unipolar
	read_adc(ADC_CH0, ADC_UNI_10V, VOLTAGE, V_VCORE);			// +Vcore supply scaled
	read_adc(ADC_CH1, ADC_UNI_10V, VOLTAGE, V_VLVD);			// +Vlvd supply scaled
	read_adc(ADC_CH2, ADC_UNI_10V, VOLTAGE, V_VAH);				// +Vah supply scaled
	read_adc(ADC_CH3, ADC_UNI_10V, VOLTAGE, V_VA_PLUS);			// +Va supply scaled
	read_adc(ADC_CH4, ADC_UNI_10V, VOLTAGE, V_VA_MINUS);		// -Va supply scaled

	// Currents scaled to ~73% of nominal values, unipolar
	read_adc(ADC_CH0, ADC_UNI_10V, CURRENT, I_VCORE);			// Current +Vcore supply
	read_adc(ADC_CH1, ADC_UNI_10V, CURRENT, I_VLVD);			// Current +Vlvd supply
	read_adc(ADC_CH2, ADC_UNI_10V, CURRENT, I_VAH);				// Current +Vah supply
	read_adc(ADC_CH3, ADC_UNI_10V, CURRENT, I_VA_PLUS);			// Current +Va supply
	read_adc(ADC_CH4, ADC_UNI_10V, CURRENT, I_VA_MINUS);		// Current -Va supply	 
	
	// release SCLK
	SCLK = 1;													 //**needed for SPI in send_psu_data_block to work**																						
	
	// Bookkeeping 
		//Status Word currently not used (initialized to 0)
	// *STATUS_WORD = 0;		   								// undefined status word - higher byte
	// *(STATUS_WORD+1) = 0;									// undefined status word - lower byte
	*ACK_NAK = 0;												// Clear any ACK/NAK															
	
	// Check Digit pre-Calculation
	check_digit();												// updates running checksum total - done here for quick response in send_data_block()
}

/***************************************************************************************/
/* Generate Check Digit    */ 
/***************************/
// Implemented as checksum for now to optimize calculation speed (tradeoff for sub-optimal error detection)
// Checksum byte totals 0 when summed with the other 35 bytes in the PSU data block  (ignoring addition overflow)
// *** This function calculated total of first 34 bytes in checksum
// *** Finish checksum calculation and set in data block using COMPLETE_CHECKSUM macro (**AFTER** ACK/NAK byte has been set)
 
void check_digit (void)
{
	int j;
	running_checksum = 0;	   									// reset checksum
	for(j = 0; j < ACK_BYTE_POS; j++) {							// sum PSU data block up to ACK/NAK byte
		running_checksum += ps_data_blk[j];
	}
}

/***************************************************************************************/
/* Parse Command Received from CC    */ 
/*************************************/
// could to make this more robust - varying degrees of complexity in how to implement this
// current protocol receives 3 2-byte command in first 6 bytes of PSU Data Block transaction

void parse_command(void)		 
{
	//assume commands are in first 6 bytes of received SPI block, ordered and repeated thrice
	if ( commands_match(rcv_spi_blk, rcv_spi_blk+2,rcv_spi_blk+4) && command_valid(rcv_spi_blk) ) { 
		cc_command = rcv_spi_blk;	
		*ACK_NAK = ACK;											// ACK command if valid command received in triplicate	
	}	
	
	else {
		cc_command = NULL;								  		// else NAK command
		*ACK_NAK = NAK;
	}
}

/***************************************************************************************/
/* Matching Commands Check    */ 
/******************************/
// returns true if three matching commands sent else false

bit commands_match (char *com_ptr_1, char *com_ptr_2, char *com_ptr_3)
{
	if( (*com_ptr_1 == *com_ptr_2) && (*(com_ptr_1 + 1) == *(com_ptr_2 + 1)) ) {	// first two commands match
		
		if( (*com_ptr_1 == *com_ptr_3) && (*(com_ptr_1 + 1) == *(com_ptr_3 + 1)) )	// third command matches
			return TRUE;
	  	else
			return FALSE;
	}
	
	else
		return FALSE;
}

/***************************************************************************************/
/* Valid Command Check    */ 
/****************************************/
// returns true if command received is valid

bit command_valid (char *com_ptr)
{
	// If command is valid return TRUE
	if( (*com_ptr == 0) && (*(com_ptr+1) == 0) )				// Request Status Command (default)
		return TRUE;
	else if( (*com_ptr == 'C') && (*(com_ptr+1) == 'P') )		// Cycle Power Command
		return TRUE;
	else if( (*com_ptr == 'R') && (*(com_ptr+1) == 'M') )		// Reset MCE Command
		return TRUE;
	else if( (*com_ptr == 'T') && (*(com_ptr+1) == 'O') )		// Turn Off Command
		return TRUE;	
	else
		return FALSE;
}