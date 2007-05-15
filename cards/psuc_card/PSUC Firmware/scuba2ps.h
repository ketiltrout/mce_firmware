/************************************************************************************/
/* 	Scuba 2 Power Supply Controller - SC2_ELE_S565_102D
/************************************************************************************/
// Revision history:
// $Log: scuba2ps.h,v $
// Revision 1.13  2007/05/15 21:08:22  bburger
// Bryce:  firmware rev. 3.2
//

/***** 	Compiler Directives / File Inclusions *****/
#pragma db
//#pragma small
//#pragma rom (compact)
#pragma symbols
#include <at89c5131.h>
#include <stdio.h>
#include <intrins.h>
#include "io.h"										// contains IO port settings and global decalarations
#include "MAX1271.c"							   	// code for interfacing with MAX1271 ADCs
#include "DS18S20.c"								// code for interfacing with DS18S20 Digital ID / Temperature Sensor
#include "soft_reset.h"


// Memory Parameters
#define BUF_SIZE		10							// received serial message buffer size (commands always smaller than this length in bytes)

/***** 	Function Prototypes *****/
// PSUC Initialization
void init(void);  	  								// initializes hardware and software variables

// PSU Commands
void sequence_on(void);								// powers on MCE
void sequence_off(void);							// powers off MCE
void reset_MCE(void);								// resets MCE
void cycle_power(void);								// cycle MCE power
void send_psu_data_block (void);					// send PSU datablock to CC via SPI

// Timing Functions
void wait_time (unsigned int);						// waits input*5ms
void wait_time_x2us_plus3(unsigned char);			// waits input*2us + 3us

// protos for datablk RS232 output functions
void sio_prt_datablk_hex(void);
void sio_prt_temps_hex(void);
void sio_prt_currents(void);
void sio_prt_volts(void);

// Send Serial Message
void snd_msg (char *);								// sends message over serial port (RS232)

// PSU Data Block Functions
void update_data_block(void);						// updates voltage/current/temperature readings
void check_digit(void);								// calculates basis for checksum (without ACK/NAK added)
//unsigned char get_fan_speed(void);				// currently not implemented

// Command Parsing Functions
void parse_command(void);							// reads CC command from first 6 bytes received from SPI transaction
bit commands_match (char *, char *, char *);		// checks command received in triplicate
bit command_valid (char *);							// checks command received is a valid command


/*********	Variables *********/
// Memory Blocks/Pointers
unsigned char idata ps_data_blk[CC_SPI_BLEN];		// PSU data for sending to CC - declared as idata to conserve memory space
unsigned char idata rcv_spi_blk[CC_SPI_BLEN];		// Received SPI data block (from CC)
char *cc_command;									// Command (from CC) pointer
unsigned char idata sio_rxbuf[BUF_SIZE];			// Serial Received Data Buffer

// index/counter variables
unsigned char data spi_idx;							// SPI Data Block Index
char data sio_rx_idx;								// Serial Received Message Pointer
char *msg_ptr;									   	// Serial Message to Send Pointer
unsigned char data bcnt;							// Count of Timer0 interrupts
unsigned int data num_T1_ints;						// Number of Timer1 interrupts to allow before setting timeup_T1
unsigned char data running_checksum;				// Running total for checksum byte
unsigned char data cc_req_320ms;					// Count time since last request from CC - used for LED FAULT behavior
unsigned char data watchdog_count;					// Loop count for watchdog

// Software flags
bit cc_spi;											// Indicates Service Request from CC (via SPI)
bit spi_complete; 									// Indicates SPI transaction with CC complete
bit sio_msg_complete;								// Indicates Serial (RS232) message received
bit poll_data;										// Set when time to update PS data block
bit timeup_T1;										// Set on Timer1 expiration (overlow)
bit temp1_present, temp2_present, temp3_present;	// Indicates if DS18S20s temperature sensors actually connected


/********** PSU Data Block Settings  ***************/
// PSU Data Block POINTERS - defining this way prevents pointers from being reassigned dynamically
#define SILICON_ID 			ps_data_blk				// Read from DS18S20 LS 32 bits of 48
#define SOFTWARE_VERSION 	(ps_data_blk+4)			// Software Version
#define FAN1_TACH			(ps_data_blk+5)			// Fan 1 speed /16
#define FAN2_TACH  			(ps_data_blk+6)			// Fan 2 speed /16
#define PSU_TEMP_1			(ps_data_blk+7)			// temperature 1 from DS18S20 // V3.1 = PSUC temperature
#define PSU_TEMP_2			(ps_data_blk+8)			// temperature 2 from DS18S20
#define PSU_TEMP_3			(ps_data_blk+9)			// temperature 3 from DS18S20
#define ADC_OFFSET			(ps_data_blk+10)		// Grounded ADC input channel reading
#define V_VCORE				(ps_data_blk+12)		// +Vcore supply scaled 0 to +2V
#define V_VLVD				(ps_data_blk+14)		// +Vlvd supply scaled 0 to +2V
#define V_VAH				(ps_data_blk+16)		// +Vah supply scaled 0 to +2V
#define V_VA_PLUS			(ps_data_blk+18)		// +Va supply scaled 0 to +2V
#define V_VA_MINUS			(ps_data_blk+20)		// -Va supply scaled 0 to +2V
#define I_VCORE				(ps_data_blk+22)		// Current +Vcore supply scaled
#define I_VLVD				(ps_data_blk+24)		// Current +Vlvd supply scaled
#define I_VAH				(ps_data_blk+26)		// Current +Vah supply scaled
#define I_VA_PLUS			(ps_data_blk+28)		// Current +Va supply scaled
#define I_VA_MINUS			(ps_data_blk+30)		// Current -Va supply scaled
#define STATUS_WORD			(ps_data_blk+32)		// undefined place for status word
//#define ACK_NAK				(ps_data_blk+34)		// either ACK or NAK
#define DATABLK_UPDATED		(ps_data_blk+34)		// set on  update, cleared after tx to CC
#define CHECK_BYTE			(ps_data_blk+35)		// checksum byte


/*******	Macros	*******/
// General Macros/Parameters
#define COMPLETE_CHECKSUM		*CHECK_BYTE = ~(running_checksum + ps_data_blk[ACK_BYTE_POS]) + 1;		// 2's compliment, so CHECK_BYTE + all other bytes = 0
