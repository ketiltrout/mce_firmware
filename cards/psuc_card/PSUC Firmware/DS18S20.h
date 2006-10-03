/***************************************************************************************/
/*       Silicon Serial Number / Temperature Sensor Functions - DS18S20        	*/
/********************************************************************************/
// Revision history: 
// $Log: DS18S20.h,v $
// Revision 1.2  2006/09/05 20:06:20  stuartah
// Changed i2c.c to MAX1271.c (code for interfacing ADCs, does not use i2c protocol)
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


/*********  Function Prototypes  **************/
// External Functions/Variables	(defined in scuba2ps.c)
extern void wait_time_x2us_plus3(unsigned char); 	 		// Waits (2*Value + 3) microseconds

// 'Public' Functions - ONLY these functions should be called externally
void ds_initialize( char );									// Initializes DS18S20
void ds_get_4byte_id( char, char* target);					// Reads Silicon ID, sets target value
void ds_get_temperature( char, char* target);				// Reads temperature from DS memory, sets target value

// The following functions are declared as 'static' to make them 'private'
// Command Functions
static void ds_convert_T( void );									// Starts temperature conversion 
static bit ds_reset(void);											// Command Reset

// 1-Wire Bus Protocol I/O Functions
static void ds_write_byte(unsigned char);							// Writes Byte
static unsigned char ds_read_byte(void);							// Reads Byte
static void ds_write_bit(bit);										// Writes Bit
static bit ds_read_bit(void);										// Reads Bit
static bit read_bus(void);											// Physical bus line bit read


/**************  DS18S20 Comands  *****************/
#define READ_ROM 			0x33							// Note: READROM command only works with a single device on the bus
#define SKIP_ROM			0xCC
#define CONVERT_T 			0x44
#define READ_SCRATCHPAD 	0xBE	 


/*************  DS18S20 Timing Parameters  **************/
// timing as per DS18S20 datasheet (DS18S20.pdf) and "1-Wire Communication Through Software" 
// (http://www.maxim-ic.com/appnotes.cfm/appnote_number/126 or 1WireCom.pdf)
// timing are RECOMMENDED times and can be adjusted for timing optimization...see above docs
#define WAIT_TIME_1uS		_nop_(); _nop_(); _nop_(); _nop_();					// 1 uS
#define WAIT_TIME_A			wait_time_x2us_plus3(1); WAIT_TIME_1uS; 			// 6 uS
#define WAIT_TIME_B			wait_time_x2us_plus3(30); WAIT_TIME_1uS;			// 64 uS
#define WAIT_TIME_C			wait_time_x2us_plus3(28); WAIT_TIME_1uS				// 60 uS
#define WAIT_TIME_D			wait_time_x2us_plus3(3); WAIT_TIME_1uS;				// 10 uS
#define WAIT_TIME_E			wait_time_x2us_plus3(3);	  						// 9 uS
#define WAIT_TIME_F			wait_time_x2us_plus3(26);	   						// 55 uS
//#define WAIT_TIME_G					0										// 0 uS - not needed
#define WAIT_TIME_H			wait_time_x2us_plus3(238); WAIT_TIME_1uS;			// 480 uS
#define WAIT_TIME_I			wait_time_x2us_plus3(33); WAIT_TIME_1uS;			// 70 uS
#define WAIT_TIME_J			wait_time_x2us_plus3(203); WAIT_TIME_1uS;			// 410 uS


/***************** Source Code ***********************/
//#include DS18S20.c															// source file