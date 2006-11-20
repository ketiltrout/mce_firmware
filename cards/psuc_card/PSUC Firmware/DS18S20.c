/***************************************************************************************/
/*       Silicon Serial Number / Temperature Sensor Functions - DS18S20        	*/
/********************************************************************************/
// Revision history: 
// $Log: DS18S20.c,v $
// Revision 1.3  2006/10/03 07:38:34  stuartah
// Added presence detection of DS18S20s
//
// Revision 1.2  2006/10/03 05:59:12  stuartah
// Tested in Subrack, Basic Command working
//
// Revision 1.1  2006/08/29 21:06:06  stuartah
// Initial CVS Build - Most Basic Functionality Implemented
//	

/*****  Refer to DS18S20 Datasheet for Command and Timing Specs *****/
/* 	The transaction sequence for accessing the DS18S20 is as follows:	(Refer to datasheets)
Step 1. Initialization (reset pulse)
Step 2. ROM Command (followed by any required data exchange)
Step 3. DS18S20 Function Command (followed by any required data exchange)  
Step 4. Read returned bytes													*/

// header file - contains function protypes and operational parameters
#include "DS18S20.h"

// variables
unsigned char bdata command_bit_adr;				// temporary bit-adressable variable for reading/writing at bit level
sbit command_lsb = command_bit_adr^0;

unsigned char adr_mask;								// sbits CANNOT be passed between functions...therefore bit mask used to adress P2 line (all Ds18S20s connceted tp P2)
													// value MUST be one of 0x04 - PSUC_ID, 0x08 - DTEMP2, 0x10 - DTEMP1, 0x20-PSU_ID

// Physical Bit Writing - Used to support multiple DS18S20s on different busses	- Bus default state is HIGH
#define DRIVE_BUS_LOW		P2 = P2 & ~adr_mask;	// Write a 0
#define RELEASE_BUS			P2 = P2 | adr_mask;		// Write a 1 (bus default high)

/***************************************************************************************/
/*  Initialize DS18S20      */ 
/****************************/
bit ds_initialize( char mask )
{
	bit present = 0;
	
	// Initialize
	adr_mask = mask;		   						// select deviec
	present = ds_reset();			

   	//	Send CONVERT T command if device prsent 				
	if(present)
		ds_convert_T();								// initial convert takes about a second to return accurate readings

	return present;
}

/***************************************************************************************/
/*  GET Silicon ID         */ 
/***************************/
// ROM Code Format	[ 8bit CRC | 48bit Serial Number | 8 bit Family Code =0x10 ]    
// Sent LSB first with bits sent LSb first					
			
void ds_get_4byte_id( char mask, char *target )		// returns pointer to lowest 32 bits of 48 bit Serial Number
{
    bit presence_detect = 0;						// for detecting presence pulse on reset	
	
	unsigned char family_code;						// for storing returned bytes
	unsigned char serial_number[6];
	unsigned char crc_code;					
	
	// Initialize
    adr_mask = mask;								// select device
	presence_detect = ds_reset();					// for now ignore presence pulse (assume always detected)		

	// Send ROM command								
	ds_write_byte(READ_ROM);						// this command skips the Function Command step

	// Receive back 8 bytes
	family_code = ds_read_byte();
	serial_number[5] = ds_read_byte();				// read back lower order bytes first
	serial_number[4] = ds_read_byte();
	serial_number[3] = ds_read_byte();	   	
	serial_number[2] = ds_read_byte();				// currently store all 6 bytes of serial code.  Could ignore unneeded bytes and set psu block directly here
	serial_number[1] = ds_read_byte();
	serial_number[0] = ds_read_byte();
	crc_code = ds_read_byte();			   			// ignore CRC code as only one device on bus.  May implement error check later.

	// Set pointer to lowest 4 bytes					
	*target = serial_number[2];						// ignore highest 2 bytes of Silicon ID
	*(target+1) = serial_number[3];
	*(target+2) = serial_number[4];
	*(target+3) = serial_number[5];	
} 

/***************************************************************************************/
/* GET Temperature       */ 
/*************************/
// DS18S20 returns 2 byte signed temperature 0.5 deg. Celsius per bit (refer to datasheet)
// Function returns 1 byte temperature (signed byte, 1 deg. Celsius per bit)
 
void ds_get_temperature( char mask, char *target )
{
	unsigned char value, sign;						// stores value and sign info
	adr_mask = mask;								// select device

	/*	Send CONVERT T command */
	ds_convert_T();

	/*	Send READ SCRATCHPAD command */
	// Initialize
	ds_reset();										// for now ignore presence pulse (assume always detected)

	// Send ROM Command								// send SKIP ROM command
	ds_write_byte(SKIP_ROM);  						//one device on bus only so don't need to adress

	// Send Function Command						
	ds_write_byte(READ_SCRATCHPAD);					// send READ SCRATCHPAD command
	
	/*	Read Temperature Data */
	// Read back scratchpad
	value = ds_read_byte();							// this byte contains only magnitude information ( 4 byte 2's compliment form)
	sign = ds_read_byte();							// this byte contains only sign information ( 4 byte 2's compliment form) ( = 00000000 or 11111111)
	
	// Issue reset 
	ds_reset();	  									// this terminates scratchpad reading (no need to read further bytes...ignore CRC check byte for now)
	
	// Scale to single byte and return				//***Note: this truncates the 0.5 degree least significant digit ... ie 25.5 and 25 both become 25 (floor function)
	value >>= 1;									// divide value by 2 (scale from 0.5 deg C to 1 deg. C per bit)
	
	if (sign > 0)									// *** need to make this more robust to allow for errors in sign byte
	   value |= 0x80;					   			// set MSB to indicate 2's compliment (0 shifted in to MSB in above line)
	
	/*  'Return' Scaled Temperature  */
	*target = value;
}

/***************************************************************************************/
/*  Initiate Temperature Conversion    */ 
/***************************************/

static void ds_convert_T (void)
{
   /*	Send CONVERT T command */
	// Initialize
	ds_reset();										// ignore presence pulse (assume always detected)

	// Send ROM Command					
	ds_write_byte(SKIP_ROM);  			

	// send Function Command
	ds_write_byte(CONVERT_T);
	while( ds_read_bit() );							// wait for DS to return a 1 which indicates temperature conversion complete
}

/***************************************************************************************/
/*  1-Wire Bus Reset Pulse    */ 
/******************************/
// Generates a 1-wire reset pulse and returns 1 iff presence pulse detected

static bit ds_reset(void)				
{
	bit presence = 0;
	
	//Initial Delay
	//WAIT_TIME_G;									// 0 uS

	//reset pulse
	DRIVE_BUS_LOW;									// drive bus low
	WAIT_TIME_H;									// hold low to indicate reset
	RELEASE_BUS;									// release bus
	
	//detect presence pulse
	WAIT_TIME_I;									// wait for presence pulse
	presence = ~read_bus();							// sample for presence pulse, indicated by bus being pulled LOW
	WAIT_TIME_J;									// reset sequence recovery time
	return presence;								// return presence indicator
}

/***************************************************************************************/
/*  1-Wire Bus Protocol - Write Byte    */ 
/****************************************/

static void ds_write_byte(unsigned char command) 	// ***sent LSB first
{													   
	int a; 
	command_bit_adr = command;						// load command byte into bit-adressable variable

	for ( a = 0; a < 8; a++ ) {						// Write single bit at a time, LSB to MSB		
		ds_write_bit(command_lsb);
		command_bit_adr >>=1;						// right-shift (bit 1 -> LSB)
	}
}

/***************************************************************************************/
/*  1-Wire Bus Protocol - Read Byte    */ 
/***************************************/

static unsigned char ds_read_byte(void) 			// ***read LSB first
{													   
	int b;
	unsigned char read_temp = 0; 
	
	for ( b = 0; b < 8; b++ ) {						// Read single bit at a time, LSB to MSB
		read_temp >>= 1;							// right shift data byte
		if( ds_read_bit() )							// read bit
			read_temp |= 0x80;						// if '1' then set MSb of read_temp; else do nothing
	}

	return read_temp;								// return byte (normal MSB first format) 
}

/***************************************************************************************/
/*  1-Wire Bus Protocol - Write Bit    */ 
/***************************************/

static void ds_write_bit(bit com_bit)
{
	// write a 1
	if (com_bit) {				
		DRIVE_BUS_LOW;							// drive bus low to initiate write time slot
		WAIT_TIME_A;							// hold line low
		RELEASE_BUS;							// release bus
		WAIT_TIME_B;							// hold bus high for write time slot and allow recovery time
	}

	// write a 0
	else {
	  	DRIVE_BUS_LOW;			   				// drive bus low to initiate write time slot
		WAIT_TIME_C;	   						// hold bus low over slot
		RELEASE_BUS;			   				// release bus
		WAIT_TIME_D;							// recovery time
	}
}

/***************************************************************************************/
/*  1-Wire Bus Protocol - Read Bit    */ 
/**************************************/

static bit ds_read_bit(void)  					// read ONLY works after master has written a READ-type command
{
	bit temp_bit;
	
	DRIVE_BUS_LOW;								// drive bus low to initiate read time slot
	WAIT_TIME_A;								// hold line low 
	RELEASE_BUS;								// release bus
	WAIT_TIME_E;								// allow settling time
	temp_bit = read_bus();						// read bit
	WAIT_TIME_F;								// recovery time
	return temp_bit;							// return read bit value
}

/***************************************************************************************/
/*  Physical Bit Read    */ 
/***************************/
//reads bit from input specified by adr_mask

static bit read_bus(void)
{
	if( (P2 & adr_mask) == 0 )
		return 0;
	else										// P2 & adr_mask = adr_mask
		return 1;
}