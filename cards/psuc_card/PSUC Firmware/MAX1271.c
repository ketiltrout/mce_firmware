/************************************************************************************************/
/*      ADC Interface - Maxim MAX1271           */
/*********************************************************
MAX1271 ADC Interfacing Function
	Manually implements SPI transaction (lack of SSTRB signal means data must be clocked manually)	 	
	Currently SCLK almost uniform...timing seems okay....
	Timing verified for extreme case of switching consecutively between +/- maximum input levels 
*************************************************************************************************/
// Revision history: 
// $Log: MAX1271.c,v $
// Revision 1.5  2006/11/20 23:22:00  stuartah
// Cleaned code, improved commenting, implemented changes for PSUC rev. G
//
// Revision 1.4  2006/10/03 05:58:49  stuartah
// Tested in Subrack, Basic Command working
//
// Revision 1.3  2006/09/23 00:32:49  stuartah
// Fixed bug (last read bit was shifted erroneously)
//
// Revision 1.2  2006/09/07 20:37:01  stuartah
// Cleaned up init() and re-organized main loop structure
//
// Revision 1.1  2006/09/05 20:02:48  stuartah
// Renamed from i2c.c (doesn't use I2C protocol)
/**************************************************************/

unsigned char bdata adc_data;  						// bit adressable variable
sbit ADC_MS_DBIT = adc_data^7;						


/****************************************************************************************
 *  Read ADC 	*
 ************** */
// non-pipeling implementation
 		 		  
void read_adc(char chan, char mode, bit adc_sel, char *target, char data_size)		   	
{   
   	unsigned char bit_cnt, *temp_char_ptr;
   	unsigned int adc_reading=0;					
   
   	MISO = 1;                             			// port bit set for input (**must have this)
   	
	//SPI must be disabled to manually control SCLK
	SPCON &= ~SPI_EN;             					// SPEN = 0:	
   
   	adc_data = chan + mode;	  						// higher 4 bits determine channel, lower 4 bits determine mode
   	SCLK = 0;										// make sure CLK is low
   	_nop_();										// delay for hardware
   	_nop_();

   	// select ONE ADC only - done with adc_sel bit as sbit/sfr types cannot be passed into functions
   	if (adc_sel == VOLTAGE)						
   		CS_VADC = 0;
   	else
   		CS_IADC = 0;								
   
   	// Send Control Byte - shift out 8 bits (8 clock cycles)
   	for (bit_cnt=1 ; bit_cnt <=8; bit_cnt++) {	
     	MOSI = ADC_MS_DBIT;							// starts conversion, data clocked in to ADC on rising clock edge
      	SCLK = 1;                                 	// loads data bit
	  	adc_data = adc_data<<1;
	  	SCLK = 0;
  	}
   
   	MOSI = 0;                                     	// don't start new conversion
   
  	/***	Wait For Ready  ----  need to change, no SSTRB pin connection **/	   			// while ( ADC_STRB == LOW );	          
	// Need 5 clock cycle delay in place of waiting for SSTRB signal to assert.  
	// ADC starts shifting out data on 14th clock signal.
  	for (bit_cnt=1 ; bit_cnt <=5; bit_cnt++) {	  										
	 	SCLK = 1;
	  	_nop_();									
	  	//_nop_();									// include for uniform timing	
	  	SCLK = 0;
	  	_nop_();
	  	//_nop_();									// include for uniform timing
  	}

   	/***	 now clock in 12 data bits	***/	  			
	// get first bit	
   	SCLK = 1;
   	if ( MISO == 1) {                          		// MSB is ready at DOUT
     	++adc_reading;
     }
   	SCLK = 0;										// this edge latches bit

   	// get last 11 bits
	for ( bit_cnt=1 ; bit_cnt<=11 ; bit_cnt++ ) {
		adc_reading = adc_reading<<1;                // rotate reading
      	SCLK = 1;                                 
      	if ( MISO == 1) {
         	++adc_reading;
		}									
		//else _nop_();								// include for uniform timing
      	SCLK = 0;                                 	// loads next bit
   }
   
   	// de-select ADC
   	if (adc_sel == VOLTAGE)						
   		CS_VADC = 1;
   	else
   		CS_IADC = 1;	   

 	// clear ports						
	MISO = 1;													
	MOSI=1;
		   
  	// re-enable SPI
	SPCON |= SPI_EN;		
	
	// return adc_reading;  - modified v4.0 for size of register - 1 or 2 bytes, according to data size allowed within data header

	if ( data_size == 2 ) {								// size of data is 2 bytes
	    temp_char_ptr = &adc_reading;	 				// need CHAR ptr to access individual bytes of int adc_reading
	    *target = *temp_char_ptr;						// higher order byte
	    *(target+1) = *(temp_char_ptr+1);				// lower order byte
	}
    else {												// size of data is 1 byte 
     	for ( bit_cnt=1 ; bit_cnt <= 4; bit_cnt++) {
		    adc_reading = adc_reading<<1;               // shift reading left 4 bits & remove four bits to fit data into 1byte size.
		}
        temp_char_ptr = &adc_reading;	 				// need CHAR ptr to access individual bytes of int adc_reading		 
		*target = *temp_char_ptr;						// only return 8 most significant bits. (1 byte)
	}
	
}


