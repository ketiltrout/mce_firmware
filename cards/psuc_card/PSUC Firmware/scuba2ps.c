/***************************************************************************************/
/* 	Scuba 2 Power Supply Controller - SC2_ELE_S565_102D
		Tom Felton - Feb 22, 2006
 		Stuart Hadfield - July/August 2006		 
/****************************************************************************************/
// Revision history: 
// $Log: scuba2ps.c,v $
// Revision 1.3  2006/08/30 19:54:19  stuartah
// Implemented checksum
//
// Revision 1.2  2006/08/29 21:06:06  stuartah
// Initial CVS Build - Most Basic Functionality Implemented
//	

/*	Refer to the following Data Sheets:
		Processor - Atmel AT89C5131AM
		Temperature Monitoring & Silicon ID - Dallas DS18S20-PAR
		ADC for Power Supply Voltage Monitoring - Maxim MAX1270ACAI
		EEPROM non-volatile memory - Atmel AT25128A

	NOTE: THIS PROGRAM IS NO WHERE NEAR COMPLETE OR TESTED
	The I/O pins are set correctly for this version (revF). The SIO routines, startup and LED
	routines work.  I was working on the SPI interface but it is not working.(yet) TF   */
/****************************************************************************************/

// Header File containing function prototypes and global variable declarations
#include "scuba2ps.h"

// Constant Variables
char code asc_version[] =  "\n\rPSUC v2.10\n\r\0";
char code software_version_byte = 0x21;		 					// 1 byte Software Version 



/****************************************************************************************
 *  Main Program		   	   *
 *************************** */

main() 
{ 
   	// Initialize Hardware Registers and Software Variables
	init();											
	
	// Output Version on Serial Port
	snd_msg(asc_version);	

   	// Initial Power-Up
	sequence_on();									// Run Power-On sequence
	reset_MCE();									// redundant but just to be sure
   	ENABLE_BLINK;
       

  /***  Main Loop - Periodically update PSU data block, respond to Clock Card / RS232 Commands  ***/
	while(TRUE) {								

	  	// Time to re-poll data
	  	if ( poll_data == SET ) {				// polling rate needs to be same or faster than CC request rate			
	  	 	update_data_block();
			poll_data = CLEAR;					// Data Poll Complete
	  	}

	  	// Serial I/O message ready to parse
	  	if ( sio_msg_complete == SET ) {					
	     	sio_msg_complete = CLEAR;
		 	sio_rx_idx = 0;							// reset message pointer
	  	 	switch ( sio_rxbuf[0] ) {					// parse message
				
				case 'R':								// Reset MCE Command
			   		reset_MCE();
			   		break;

				case 'V':								// Respond with Software Version
			   		snd_msg(asc_version);
			   		break;
		    
				default:
			   		break;
		 	}
	  	}

		// Listen for data request from clock card
		cc_spi = ~SREQ;									// SREQ active low

	  	// Act on command from Clock Card
	  	if ( cc_command != NULL )		
		 	switch ( *cc_command ) {					// parse message	
				
				case 0:									// default Status Command with ACK
					if ( cc_spi == TRUE)														 			   
	  	  				send_psu_data_block();
					break;				

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

		    	default:
					cc_command = NULL;
			   		break;  
		}
														
		else if ( cc_spi == TRUE)						// default Status Command with NAK		 			   
	  	  	send_psu_data_block();						// Time to send SPI Data to Clock Card
	}

}

/****************************************************************************************
 *  Initialize		   	   *
 *************************** */

void init(void) 	// still need to clean/fix this
{
	int i = 0;		// temporary index

//IO Port Setup 1=Input (or Special Function) 0=Output	-----these values seeem erroneous and redundant...CSare active low
   	P0 = 0x60;		//0110 0000
   	P1 = 0xed;		//1110 1101
   	P2 = 0x3c;		//0011 1100			   // go over / fix all these values!!!!!!!!!
   	P3 = 0xd7;		//1101 0111

//EEPROM setup
	CS_EEPROM = 1;				//EEPROM active low	 ->redundant, done above
	CS_VADC = 1;
	CS_IADC = 1;				// this is SS pin and needs to be set low for SPI //seems to be okay now
	SREQ = 1;	 //active low
	CCSS=1;		 //active low

//Counter/Timer 0 used as a Timer in Mode 1.  Interrupt Rate: 32mS
   	TR0 = ON;
	TH0 = 0;
   	TL0 = 135;
   
//Counter/Timer 1 used as a Timer in Mode 1.  Interrupt Rate: 5e-3 Sec
   	TL1 = LS_RELOAD_5mS;
   	TH1 = MS_RELOAD_5mS;
   	TMOD = 0x11;

//Serial I/O Setup:  Using Internal Baud Rate Generator on 89C5131A.  Set to Serial Mode 1 at 9600 Baud using 24MHz Clock
    SCON = 0x50;			// 0101 0000
	BDRCON = 0x1e; 		 	// 0001 1110
	CKCON0 = 0x7f;		 	// X2 set but 12 clocks per peripheral cycle -> 500ns pert tick
	PCON = 0x80; 		 	// 1000 0000 Double Baud Rate all others default
	BRL = 100;				// Baud rate reload - sets Baud rate to 9600
	sio_rx_idx = 0;			// reset message pointer

//PCA Counter Init
	CKCON0 |= 0x20;		//500ns per PCA tick
	CMOD |= 0x81;			// 0b 1000 000 Set PCA to stop counting during idle mode, disable PCA interrupts, and count Fclk-periph/6 (250ns period)
	CCON |= 0x01;			// enable PCA interrupts 

//LED Setup
	LEDCON = 0xfC;				// LED1-3 10mA Current Source
	LED_FAULT = 0;				// Off
	LED_STATUS = 1;				// Off
	LED_OUTON = 1;				// Off



//SPI Setup - Sets up spi in master mode with Fclk Periph/16 as baud rate and without slave select pin.
//SPCON = SPI_MSTR | SPI_EN | SPI_SSDIS | SPI_CPOL1 | SPI_1M5Hz;	// CPHA = 0, transfer on falling SCLK
    SPCON |= SPI_MSTR;         	// Master mode    
//	SPCON |= SPI_6MHz;			// Fclk Periph/4 (6MHz)
    SPCON |= SPI_1M5Hz;			// Fclk Periph/16 (1.5Mhz)		 //note any faster will screw up ADC code
	SPCON &= SPI_CPOL0;        	// CPOL = 0, Clk idle state 0
    SPCON &= SPI_CPHA0;        	// CPHA = 0, sample data on Clk rising edge
    SPCON |= SPI_SSDIS;			// Disable SS
    SPCON |= SPI_EN;           	// Run SPI
    spi_idx = 0;				// Pointer for SPI data output
	spi_complete = CLEAR;			// SPI transmission/reception complete status bit

//Interrupt Setup
	ES = 1;			 			// Enable SIO Interrupts
	IEN1 |= 0x04;               // Enable SPI Interrupts
	ET0 = 1;          			// Enable Timer0 Interrupts
    ET1 = 1;			 		// Enable Timer1 Interrupts
    EA = 1; 					// Enable Global Interrupts
	EC=1;						// Enable PCA Interrupts

/* Initialize Devices */	
	ds_initialize(PSUC_DS18S20);		  // alternatively could do convert_temp than wait 600ms on first one....

/* Initialize Variables */		// How much of this is needed???							
	bcnt = 0;
	running_checksum = 0;

	while(i < CC_SPI_BLEN) {			// initialize data blocks to all zeros	
		 	ps_data_blk[i] = 0;					
			rcv_spi_blk[i] = 0;
			i++;
	}
	

	// Initialize flags
	poll_data = SET; 			// Initial data poll
	
	cc_spi = CLEAR;				// Clear remaining flags
//	spi_complete = CLEAR;
	sio_msg_complete = CLEAR;
	timeup_T1 = CLEAR;
	DISABLE_BLINK;		  		// Initially disable LED blink
	
	
	// Initialize PSU data block - these aspects of data block set only once
	ds_get_4byte_id(PSU_DS18S20, SILICON_ID);	 // assign ID to PSU block
	*SOFTWARE_VERSION = software_version_byte; 	 // Software Version	byte
		
}

/****************************************************************************************
 *  Startup (Turn-On) Sequence   	   *
 ***************************/

void sequence_on (void)
{
//	wait_time( T100mS );
	nPSU_ON = 0;
	wait_time( T100mS );
	nCORE_ON = 0;
	LED_OUTON = 0;							// 0 = LED on
}

/****************************************************************************************
 *  Turn-Off Sequence   	   *
 ***************************/

void sequence_off (void)
{
	nCORE_ON = 1;
	wait_time( T100mS );
	nPSU_ON = 1;
    wait_time( T100mS );					// need this??????
	LED_OUTON = 1;							// LED off
}

/****************************************************************************************
 *  Reset MCE  	   *
 ***************************/

void reset_MCE (void)
{
	BRST = 1;			 					// Pulse Reset Line for 100mS
	wait_time( T100mS );
	BRST = 0;
}

/****************************************************************************************
 *  Cycle Power  	   *
 ***************************/

void cycle_power (void)
{
	sequence_off();
	wait_time( T100mS );					// need this??????
	sequence_on();
}

/****************************************************************************************
 * 	Send PSU Data Block to CC via SPI  	   *
 ***************************/
void send_psu_data_block (void)
{				
	// Begin Transaction
	spi_idx = 0;								// Start at beginning of data block
	CCSS = 0;									// Select Clock Card (slave) to listen on SPI bus		
		 	
	// Send first 34 of 36 bytes (need to calculate checksum based on ACK/NAK byte)
	while(spi_idx < ACK_BYTE_POS) {				
		SPDAT = ps_data_blk[spi_idx];  			// send byte #spi_idx
		while(!spi_complete);					// wait for end of byte transmission
		spi_complete = 0;						// clear software flag
		spi_idx++;								// increment data block index
 	}
	
	// Update ACK/NAK byte and send
	parse_command();							// Sets ACK/NAK byte
	SPDAT = ps_data_blk[ACK_BYTE_POS];  		// Send ACK/NAK byte
	while(!spi_complete);						// wait for end of byte transmission
	spi_complete = 0;							// clear software flag
	
	// Update Check byte and send
	//*CHECK_BYTE = ~(running_checksum + ps_data_blk[ACK_BYTE_POS]) + 1;		// 2's compliment, so CHECK_BYTE + all other bytes = 0
	COMPLETE_CHECKSUM;	
	SPDAT = ps_data_blk[ACK_BYTE_POS + 1];  								// Send Check byte
	while(!spi_complete);													// wait for end of byte transmission
	spi_complete = 0;														// clear software flag
		
	// Finish Transaction
	CCSS = 1;									// De-select Clock Card
	cc_spi = FALSE;  							// Data Block Transmission Complete											
}

/****************************************************************************************
/*  Wait Timer - 5ms Multiples   	   */
/***************************/
//Sets up T1 interrupt to loops x 5mS, waits specified time then returns
 
void wait_time (unsigned char loops)
{
	timeup_T1 = CLEAR;
 	TL1 = LS_RELOAD_5mS;					// Interrupt interval set to 5mS
   	TH1 = MS_RELOAD_5mS;
   	num_T1_ints = loops;					// time expires after 1 interrupt
   	TR1 = ON;
   	while ( timeup_T1 != SET );			// wait here for specified time to expire
}

/****************************************************************************************
/*  Microsecond Wait Timer   	   */
/***************************/
// returns 2*time_us_div2 + 3 (in uS)....tested and verified
// therefore works for a minimum of 3us (time_us_div2 = 0) or maximum of 513us (time_us_div2 = 255)

void wait_time_x2us_plus3 (unsigned char time_us_div2)		// 1.25 us to call function
{	
	while(time_us_div2>0) {							// each comparison takes 1.25 uS
		time_us_div2--;								// 250ns operation
	}												// 500ns delay to begining of loop
	_nop_();										// 250 ns delay to make total delay an integer
} 													// 500 ns to return from function

// from above numbers, delay = time_us_div2 * (1.25+ 0.25 + 0.5) + 1.25+ 0.25 + 1 + 0.5 = 2*time_us_div2 + 3 (in uS)


 
/***************************************************************************************/
/* Send Serial Message     */ 
/***************************/

void snd_msg (char *message)
{
   msg_ptr = message;
   TI = SET;								// Generates SIO interrupt
}

/***************************************************************************************/
/* Serial Interrupt Service Routine     */ 
/****************************************/
// Interrupt driven serial I/O

void serial_isr (void) interrupt 4 using 2
{
	char msg;
   	
	// Transmitted Data Interrupt
	if ( TI == SET ) {                     	// Clears any TI Interrupts
      	TI = CLEAR;
	  	msg = *msg_ptr;
	  	if (msg != NULL) {
	     	++msg_ptr;
			SBUF = msg;	
	  	}
	  	else msg_ptr = 0;
  	}	
   
   	// Received Data Interrupt
   	if ( RI == SET ) {                		// Clears RI Interrupts
      	RI = CLEAR;
	  	msg = SBUF;
		sio_rxbuf[sio_rx_idx++] = msg;				// these three lines are suspect, need to fix
	  	if (sio_rx_idx >= (BUF_SIZE-1))
	     	--sio_rx_idx;
	  	if (msg == LF) {	  				// LineFeed indicates end of message
	     	sio_rx_idx = 0;
	     	sio_msg_complete = SET;			// Indicate entire message received
	  	}
   	}   
}

/***************************************************************************************/
/* Timer0 Service Routine     			*/ 
/****************************************/

// Interrupt occurs every 32ms when enabled	  -  used for LED blink

void timer0_isr (void) interrupt 1 using 3
{
	++bcnt;
	if ( bcnt == BRATE320mS) {
      	bcnt = 0;
	  	poll_data = SET;				// poll data every 320ms
	  	if (blink_en == SET);
	   		LED_FAULT = ~LED_FAULT;		//toggle LED every 320ms if enabled
   }
}

/***************************************************************************************/
/* Timer1 Service Routine     			*/ 
/****************************************/

// Interrupt occurs every 5ms when enabled	 - used for wait_time()

void timer1_isr (void) interrupt 3 using 3
{
   --num_T1_ints;						// count the number of interupts
   if (num_T1_ints == 0) {				// check if interrupt time is up
      TR1=OFF;							// Stop the timer
	  timeup_T1 = SET;					// Indicate time is up
   }
   else {								// reload timer
      TL1 = LS_RELOAD_5mS;				// multiple interrupts always occur every 5mS
	  TH1 = MS_RELOAD_5mS;
   }
}

/***************************************************************************************/
/* SPI Interrupt Service Routine     */ 
/****************************************/

void spi_isr (void) interrupt 9
{
	switch	( SPSTA )         			/* read and clear spi status register */
	{
		case 0x80:								// SPIF flag set --> transmission complete
           	rcv_spi_blk[spi_idx] = SPDAT; 		// read receive data
		   	spi_complete = 1;
			break;

	   	/* error cases -> refer to pg. 96 in AT89 datasheet */
		case 0x10:							// mode fault
         	// this does not apply as single master on SPI bus and SSDisable bit set in SPSTA register 													   								
			break;
	
		case 0x40:				   			// write collision
         	// write collision does NOT cause an interrupt therefore this should be elsewhere if needed													 
			break;

		default:
			break;
	}
}
		
/***************************************************************************************/
/* Retrieve Data Block    */ 
/****************************************/	 
//Updates PSU Data Block with Current Values

void update_data_block (void)
{
	// Fan Speeds
//	get_fan_speeds();

	// DS18S20 - Temperatures													   //averaging???
	ds_get_temperature(PSU_DS18S20, PSU_TEMP_1);								// temperature 1 
	ds_get_temperature(DTEMP1_ID, PSU_TEMP_2);								// temperature 2 
	ds_get_temperature(DTEMP2_ID, PSU_TEMP_3);								// temperature 3 from DS18S20

	// ADC - Voltage Readings
	read_adc(ADC_CH5, ADC_UNI_10V, VOLTAGE, ADC_OFFSET);			// Grounded ADC input channel reading
	read_adc(ADC_CH0, ADC_UNI_10V, VOLTAGE, V_VCORE);			// +Vcore supply scaled 0 to +2V
	read_adc(ADC_CH1, ADC_UNI_10V, VOLTAGE, V_VLVD);			// +Vlvd supply scaled 0 to +2V
	read_adc(ADC_CH2, ADC_UNI_10V, VOLTAGE, V_VAH);			// +Vah supply scaled 0 to +2V
	read_adc(ADC_CH3, ADC_UNI_10V, VOLTAGE, V_VA_PLUS);			// +Va supply scaled 0 to +2V
	read_adc(ADC_CH4, ADC_UNI_10V, VOLTAGE, V_VA_MINUS);			// -Va supply scaled 0 to +2V

	// ADC - Current Readings
	read_adc(ADC_CH0, ADC_UNI_10V, CURRENT, I_VCORE);			// Current +Vcore supply scaled
	read_adc(ADC_CH1, ADC_UNI_10V, CURRENT, I_VLVD);			// Current +Vlvd supply scaled
	read_adc(ADC_CH2, ADC_UNI_10V, CURRENT, I_VAH);			// Current +Vah supply scaled
	read_adc(ADC_CH3, ADC_UNI_10V, CURRENT, I_VA_PLUS);			// Current +Va supply scaled
	read_adc(ADC_CH4, ADC_UNI_10V, CURRENT, I_VA_MINUS);			// Current -Va supply scaled	 
																							
	// Bookkeeping
	*STATUS_WORD = 0;		   				// place for undefined status word - higher byte
	*(STATUS_WORD+1) = 0;						// place for undefined status word - lower byte
	
	// ***** these two lines can be optimized out ********
	*ACK_NAK = 0;										
	*CHECK_BYTE = 0;					
	
	// Check Digit Calculation
	check_digit();					// updates running checksum total   //maybe move this line to beginning of send_dat_block to avoid unneccessary repetitions
}

/***************************************************************************************/
/* Generate Check Digit    */ 
/****************************************/
// Implemented as checksum for now to optimize calculation speed (tradeoff for sub-optimal error detection)
// Checksum byte totals 0 when summed with the other 35 bytes in the PSU data block  (ignoring addition overflow)
// *** This function calculated total of first 34 bytes in checksum
// *** Finish checksum calculation and set in data block using COMPLETE_CHECKSUM (AFTER ACK/NAK byte has been set)
 
void check_digit (void)
{
	int j;
	running_checksum = 0;

	// sum PSU data block upto ACK/NAK byte
	for(j = 0; j < ACK_BYTE_POS; j++) {
		running_checksum += ps_data_blk[j];
	}
}

/***************************************************************************************/
/* Parse Command Received from CC    */ 
/****************************************/
// could to make this more robust - varying degrees of complexity in how to implement this

void parse_command(void)		 
{
	//assume commands are in first 6 bytes of received SPI block, ordered and repeated thrice
	if ( commands_match(rcv_spi_blk, rcv_spi_blk+2,rcv_spi_blk+4) && command_valid(rcv_spi_blk) ) { 
		cc_command = rcv_spi_blk;	
		*ACK_NAK = ACK;	
	}	
	
	else {
		cc_command = NULL;
		*ACK_NAK = NAK;
	}
}

/***************************************************************************************/
/* Matching Commands Check    */ 
/****************************************/
// checks three matching commands sent
// could be made more robust along with parse_command
bit commands_match (char *com_ptr_1, char *com_ptr_2, char *com_ptr_3)
{
	if( (*com_ptr_1 == *com_ptr_2) && (*(com_ptr_1 + 1) == *(com_ptr_2 + 1)) ) {			// first two commands match
		
		if( (*com_ptr_1 == *com_ptr_3) && (*(com_ptr_1 + 1) == *(com_ptr_3 + 1)) )			// third command matches
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
// could be made more robust along with parse_command

//this is somewhat redundant as we are checking what the command is here and in main...

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

/***************************************************************************************/
/* Get Fan Speeds    */ 
/***************************/
//maybe count a few (or up to 60...) pulses than convert to RPM
//need to use scope to see what pulses actually look at (ie high-low symmetrical) on PSUC end 
//line default is LOW (at AT89 end)
unsigned char get_fan_speeds (void)
{
	char *rpm_ptr;
	unsigned int time_elapsed = 0;			// these value records the time elapsed for a full two fan periods
	unsigned long rpm = 0;  					// 4 byte temporary variable
	
	// these two lines assure start of pulse
	while(FAN1_SPD);		// wait for fan speed line to go low
	while(!FAN1_SPD);		// wait for fan speed line to go high     // --may need some kind of counter/break here in case fan not connected (will hang int hsi case)

   	start_count_timer();		//maybe replace these with #define statements
	
	// allow to two fan pulses to occur - 2 pulses per fan roatation - see datasheet
	while(FAN1_SPD);		// wait for fan speed line to go low		 //this assumes constant fan speed...may want to count a few cycles
	while(!FAN1_SPD);		// wait for fan speed line to go high
	while(FAN1_SPD);		// wait for fan speed line to go low
	while(!FAN1_SPD);		// wait for fan speed line to go high
	
	// get elapsed time (in uS)
	time_elapsed = stop_count_timer();	      //maybe replace these with #define statements

	//rpm = (1/ (time_elapsed)  (uS/ periods)) *(60 000 000 (us/min))		// may need error case here to prevent div by 0
	rpm = 60000000 / time_elapsed;
	rpm = rpm>>5;								// divide by 32=2^5 to scale to 1 byte
	
	rpm_ptr = &rpm;								// need to cast to CHAR pointer to grap lowest byte
	
	return *( rpm_ptr + 3);						// return lowest byte   
}

/****************************************************************************************
/*  PCA Timer (Counter)   	   */
/***************************/
// used for calculating elapsed time between events
void start_pca_timer ( void )
{
 	// reset PCA timer
	CH = CLEAR;	
   	CL = CLEAR;

	// start PCA timer
	CCON |= 0x40;
}
/***************************/
// returns elapsed time since start_pca_timer in uS
int stop_pca_timer ( void )
{
	// stop PCA timer
	CCON &= ~0x40;

	// return integer timer count in uS
	return (CL + (0x0100*CH))/2;					// 500 us per click so divide register values by 2
}
/****************************************************************************************/

/****************************************************************************************
 *  PCA Timer - Interrupt Service Routine		   	   *
 *************************** */
void pca_isr(void) interrupt 6 /* interrupt address is 0x0033 */
// for now simply clear interrupt
// will implement overflow error handling later
{
	CF = 0;					// clear interrupt
	
	//set error value to indicate rollover of PCA counter
	// max count is 500ns * 0xFFFF = 32.77 miliseconds -> indicates ~30 revoltions per second	
	//pca_interrupts++;
}


