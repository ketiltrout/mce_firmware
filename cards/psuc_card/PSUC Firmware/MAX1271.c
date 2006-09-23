/***************************************************************************************/
/*      I2C Function Library            */
/****************************************/
// Revision history: 
// $Log: MAX1271.c,v $
// Revision 1.2  2006/09/07 20:37:01  stuartah
// Cleaned up init() and re-organized main loop structure
//
// Revision 1.1  2006/09/05 20:02:48  stuartah
// Renamed from i2c.c (doesn't use I2C protocol)
	
//#include <reg52.h>
//#include <intrins.h>
//#include "io.h"

//idea: get rid of for loops and do everything manually to make clocking uniform (optimize)
//idea: implement pipelined command/read
//currently SCLK almost uniform...timing seems okay....could tweak further

/***************************************************************************************/
/*      ADC Functions - Maxim MAX1271       	*/
/************************************************/

unsigned char bdata adc_data;
sbit ADC_LS_DBIT = adc_data^0;			 //dont need this line???
sbit ADC_MS_DBIT = adc_data^7;												 //should these be bit or sbit???
		 		  
void read_adc(char chan, char mode, bit adc_sel, char *target)		   	// no pipeling version
{   
   	unsigned char bit_cnt, *temp_char_ptr;
   	unsigned int adc_reading=0;					
   
   	  MISO = 1;                               // port bit set for input		//need this	 ???????  YES	   //need to clear at end?
   	
	// SPEN = 0:  SPI must be disabled to manually control SCLK
	SPCON &= ~0x40;             						
   
   	adc_data = chan + mode;	  							// higher 4 bits determine channel, lower 4 bits determine mode
   	SCLK = 0;									// make sure CLK is low -- probably dont need this
   	_nop_();									// delay for hardware	....are these still needed?
   	_nop_();									// why nop???	 needed?

   	// select ONE ADC only - done with adc_sel bit as sbit/sfr types cannot be passed into functions
   	if (adc_sel == VOLTAGE)						
   		CS_VADC = 0;
   	else
   		CS_IADC = 0;								
   
   	// Send Control Byte - shift out 8 bits (8 clock cycles)
   	for (bit_cnt=1 ; bit_cnt <=8; bit_cnt++) {	
     	MOSI = ADC_MS_DBIT;								// starts conversion, data clocked in to ADC on rising clock edge
      	SCLK = 1;                                 		// loads data bit
	  	adc_data = adc_data<<1;
	  	SCLK = 0;
	 	// _nop_();
	  	//wait()????
  	}
   
   	MOSI = 0;                                     // don't start new conversion
   
  	/***	Wait For Ready  ----  need to change, no SSTRB pin connection **/	   			// while ( ADC_STRB == 0 );	          
	// Need 5 clock cycle delay in place of waiting for SSTRB signal to assert.  
	// ADC starts shifting out data on 14th clock signal.
  	for (bit_cnt=1 ; bit_cnt <=5; bit_cnt++) {	  										
	 	SCLK = 1;
	  	_nop_();									//include for uniform timing
	  	//_nop_();										
	  	SCLK = 0;
	  	_nop_();
	  	//_nop_();									//include for uniform timing
  	}

   	/***	 now clock in 12 data bits	***/	  			
	// get first bit										//why is first bit separate?  for timing	
   	SCLK = 1;
   	if ( MISO == 1) {                          		// MSB is ready at DOUT
     	++adc_reading;
     	}
   	SCLK = 0;									// this edge latches bit
   	//_nop_();
   //	adc_reading = adc_reading<<1;                // rotate reading

   	// get next 11 bits
   	for ( bit_cnt=1 ; bit_cnt<=11 ; bit_cnt++ ) {
		adc_reading = adc_reading<<1;                // rotate reading
      	SCLK = 1;                                 
      	if ( MISO == 1) {
         	++adc_reading;									
		 	//need delays in here????  else {_nop_();} ?
         	}
      	SCLK = 0;                                 // loads next bit
      	//adc_reading = adc_reading<<1;             // rotate reading			 removed from here so last bit not shifted
   }
   
   	// de-select ADC
   	if (adc_sel == VOLTAGE)						
   		CS_VADC = 1;
   	else
   		CS_IADC = 1;	   


	MISO = 0; 							//clear port
	//MISO = 1;								

  	// re-enable SPI
	SPCON |= 0x40;								
   
  	// return (adc_reading);
  	temp_char_ptr = &adc_reading;	 				// need CHAR ptr to access individual bytes of int adc_reading
  	*target = *temp_char_ptr;						// higher order byte
  	*(target+1) = *(temp_char_ptr+1);				// lower order byte
}