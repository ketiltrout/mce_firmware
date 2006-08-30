/***************************************************************************************/
/*      I/O Assignments           */
/****************************************/
// Revision history: 
// $Log: io.h,v $
// Revision 1.1  2006/08/29 21:06:06  stuartah
// Initial CVS Build - Most Basic Functionality Implemented
//	


// AT89 I/O Pin Assignments
sbit BUS_SP2 =		P0^5;		// Bus Spare 1
sbit BUS_SP1 =		P0^6;		// Bus Spare 2

sbit FAN2_SPD =		P1^0;		// Fan 2 Tacho - Input
sbit CS_IADC =		P1^1;		// Chip Select Current ADC - Output
sbit SER_DSR =		P1^2;		// RS-232 Data Set Ready - Input
sbit SREQ =			P1^3;		// Clock Card Service Request - Input
sbit CCSS =			P1^4;		// Active for PS Data on SPI - Output
sbit MISO =			P1^5;		// SPI MISO - Input
sbit SCLK =			P1^6;		// SPI CLK - Output
sbit MOSI =	 		P1^7;		// SPI MOSI - Output

sbit BRST =			P2^0;		// Subrack Reset - Output
sbit nPSU_ON =		P2^1;		// Turn On PSU - Output
sbit PSUC_ID =		P2^2;		// Dallas DS18S20 PSUC ID - Input
sbit DTEMP2 =		P2^3;		// Dallas DS18S20 PSU Digital Temp2 - Input
sbit DTEMP1 =		P2^4;		// Dallas DS18S20 PSU Digital Temp1 - Input
sbit PSU_ID =		P2^5;		// Dallas DS18S20 PSU ID - Input
sbit nCORE_ON =		P2^7;		// Core Voltage On - Output

sbit CS_VADC =		P3^2;		// Chip Select Voltage ADC - Output
sbit CS_EEPROM =	P3^3;		// Chip Select EEPROM Atmel AT25128A - Output
sbit FAN1_SPD =     P3^4;		// Fan 1 Tacho - Input
sbit LED_FAULT =	P3^5;		// LED1 - Output	0 = off 1 = on
sbit LED_OUTON =	P3^6;		// LED3 - Output	0 = on  1 = off
sbit LED_STATUS =	P3^7;		// LED2 - Output	0 = on  1 = off	     ->currently not used
   
sbit SPARE2 =		P4^0;		// Bus Spare 1
sbit SPARE1 =		P4^1;		// Bus Spare 2


// PSU Data Block Settings
#define CC_SPI_BLEN		36		// Bytes in SPI Block to Clock Card
#define ACK_BYTE_POS	34		// ACK/NAK byte position - used instead of (CC_SPI_BLEN - 2) for optimization


// I/O Pin Bit Masks - For DS18S20 Addressing
#define PSUC_DS18S20 	0x04
#define	DTEMP2_ID		0x08
#define	DTEMP1_ID		0x10
#define PSU_DS18S20		0x20


// SPI Interface			
#define ADC_SPI_BLEN	1				// Bytes in SPI Block to ADC
#define SPI_MSTR		0x10			// SPCON Bit Set for Master
#define SPI_CPOL0		~0x08			// SPCON Bit Set for Clock Polarity - Active low
#define SPI_CPHA0		~0x04			// SPCON Bit Set for Clock Phase - Active low
#define SPI_1M5Hz		0x03			// SPCON Bits D7,D1,D0 for 1.5MHz
#define SPI_6MHz		0x01			// SPCON Bits D7,D1,D0 for 6MHz
#define SPI_EN			0x40			// SPCON Bit D6 Enables SPI
#define SPI_SSDIS		0x20			// SPCON Bit 5 Set disables SS Interrupts


// General Keywords
#define ON      	1
#define OFF     	0
#define TRUE    	1
#define FALSE   	0
#define SET     	1
#define CLEAR   	0
#define ENABLE		0
#define DISABLE		1
#define VOID		0x0
#define CR			0x0d					
#define LF			0x0a
#define ACK			0x06
#define NAK			0x15
#ifndef NULL 	
	#define NULL	0x00 				// NULL usually defined	
#endif	 


// Timing Parameters
#define MS_RELOAD_5mS	216  			// timing confirmed with 24MHz Clock
#define LS_RELOAD_5mS	239	 			//  Timing register loaded with 0xFFFF - (216)(239) = 0xD8FF = 10000, implies 500ns delay per click 
#define T5mS			1
#define T15mS			3
#define T25mS			5
#define T100mS			20
#define BRATE320mS		10

		
// ADC Control Channel/Mode Select
#define ADC_CH0		0x80            
#define ADC_CH1		0x90
#define ADC_CH2		0xA0
#define ADC_CH3		0xB0
#define ADC_CH4		0xC0
#define ADC_CH5		0xD0
#define ADC_CH6		0xE0
#define ADC_CH7		0xF0

#define ADC_UNI_5V	0x1
#define ADC_BI_5V	0x5
#define ADC_UNI_10V	0x9					//default mode
#define ADC_BI_10V	0xd

#define VOLTAGE 	0
#define CURRENT 	1


