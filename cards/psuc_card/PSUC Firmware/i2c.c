/***************************************************************************************/
/*      I2C Function Library            */
/****************************************/
// Revision history: 
// $Log: scuba2ps.c,v $	


//#include <reg52.h>
//#include <intrins.h>
//#include "c:\Software Dev\8051\include\i2c.h"
//#include "io.h"

//idea: get rid of for loops and do everything manually to make clocking uniform (optimize)
//currently SCLK almost uniform...timing seems okay....could tweak further

//put ADC stuff in separate .h file so that can switch between pipeline and non-pipeline ADC read easily

/***************************************************************************************/
/*      ADC Functions - Maxim MAX1270       	*/
/************************************************/
//#define TP1 SPARE1;							//???  test point, assign to unused pin on AT89

unsigned char bdata adc_data;
sbit ADC_LS_DBIT = adc_data^0;			 //dont need this line???
sbit ADC_MS_DBIT = adc_data^7;												 //should these be bit or sbit???
		 		  
void read_adc(char chan, char mode, bit adc_sel, char *target)		   	// no pipeling version
{   
   
   unsigned char bit_cnt, *temp_char_ptr;
   unsigned int adc_reading=0;					
   
   //  MISO = 1;                                  // port bit set for input				//need this	 ???????
   SPCON &= ~0x40;             					// SPEN = 0:  SPI must be disabled in order to manually control SCLK
   
   adc_data = chan + mode;	  					// higher 4 bits determine channel, lower 4 bits determine mode
   SCLK = 0;									//make sure CLK is low, probably dont need this
   _nop_();										// delay for hardware			 ....are these still needed?
   _nop_();								// why nop???	 needed

   if (adc_sel == VOLTAGE)						// select ONE ADC only - done with adc_sel bit as sbit/sfr types cannot be passed into functions
   		CS_VADC = 0;
   else
   		CS_IADC = 0;								
   
   for (bit_cnt=1 ; bit_cnt <=8; bit_cnt++) {	// shift out 8 bits
      MOSI = ADC_MS_DBIT;						// starts conversion, data clocked in to ADC on rising clock edge
      SCLK = 1;                                 // loads data bit
	  adc_data = adc_data<<1;
	  SCLK = 0;
	 // _nop_();
	  //wait()????
   }
   
   MOSI = 0;                                     // don't start new conversion
   
  // while ( ADC_STRB == 0 );                     // wait for Ready----need to change, no sstrb connection
   
   for (bit_cnt=1 ; bit_cnt <=5; bit_cnt++) {	  // 8 clock cycles to shift out control bits. need 5 clock cycle delay in place of waiting for
												  // SSTRB signal.  ADC starts shifting out data on 14th clock signal.
	  SCLK = 1;
	  _nop_();
	  //_nop_();								//include for unifrom timing		
	  //wait()????								//put clk out here manually or count clk pulses?
	  SCLK = 0;
	  //wait()????
	  _nop_();
	  //_nop_();								//include for uniform timing
   }

   //now clock in 12 data bits											
   SCLK = 1;
   if ( MISO == 1) {                          // MSB is ready at DOUT
      ++adc_reading;
    //  SPARE1=1;                                    // TP1 follows DOUT
      }
  // else SPARE1=0;   
   
   SCLK = 0;									// this edge latches bit
   //_nop_();
   adc_reading = adc_reading<<1;                // rotate reading

   for ( bit_cnt=1 ; bit_cnt<=11 ; bit_cnt++ ) {// loop gets next 11 bits
      SCLK = 1;                                 
      if ( MISO == 1) {
         ++adc_reading;
         //SPARE1=1;									//need delays in here????
         }
     // else SPARE1=0;
      SCLK = 0;                                 // loads next bit
      adc_reading = adc_reading<<1;             // rotate reading
   }
   
   // de-select ADC
   if (adc_sel == VOLTAGE)						
   		CS_VADC = 1;
   else
   		CS_IADC = 1;	   
      
   // for testing
   SPARE1=0;

   SPCON |= 0x40;								// re-enable SPI
   
  // return (adc_reading);
  temp_char_ptr = &adc_reading;	 				// need CHAR ptr to access individual bytes of int adc_reading
  *target = *temp_char_ptr;						// higher order byte
  *(target+1) = *(temp_char_ptr+1);				// lower order byte
}