------------------------------------------------------------------------
--
-- 
--
-- <revision control keyword substitutions e.g. $Id$>
--
-- Project:		SCUBA 2
-- Author:		jjacob
-- Organisation:	UBC Physics and Astronomy
--
-- Description:
-- This code implements the testbench for the Wishbone Slave state machine
--
-- Revision history:
-- <date $Date$>	-		<text>		- <initials $Author$>
--
------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

library WORK;
use WORK.card_id_pack.all;


entity TB_CARD_ID_READ_SERIAL_NUM is
end TB_CARD_ID_READ_SERIAL_NUM;

architecture BEH of TB_CARD_ID_READ_SERIAL_NUM is

--   component CARD_ID_READ_SERIAL_NUM
--      port(CLK               : in std_logic ;
--           RST               : in std_logic ;
--           INIT_FSM_CTRL_I   : in std_logic ;
--           FSM_DONE_CTRL_O   : out std_logic ;
--           DATA_BI           : inout std_logic_vector ( 0 downto 0 );
--           DATA_O            : out std_logic_vector ( 63 downto 0 ) );
--
--   end component;


   constant PERIOD : time := 20 ns;

   signal W_CLK               : std_logic  := '0';
   signal W_RST               : std_logic ;
   signal W_INIT_FSM_CTRL_I   : std_logic ;
   signal W_FSM_DONE_CTRL_O   : std_logic ;
   signal W_DATA_BI           : std_logic;
   signal W_DATA_O            : std_logic_vector ( 63 downto 0 ) ;


   signal bit_count                    : integer := 63;
   constant SERIAL_CODE         : std_logic_vector(63 downto 0) :=  x"C0DE_CAFE_BABE_DEAD";  --16#C0DE_CAFE_BABE_DEAD#;
   --"0000111100001111000011110000111100001111000011110000111100001111";
   -- signals for self-checking
   signal result                 : boolean;
   constant PASS                 : boolean := true;
   constant FAIL                 : boolean := false;
   

begin

------------------------------------------------------------------------
--
-- instantiate card_id
--
------------------------------------------------------------------------

 
   DUT : CARD_ID_READ_SERIAL_NUM
      port map(CLK               => W_CLK,
               RST               => W_RST,
               INIT_FSM_CTRL_I   => W_INIT_FSM_CTRL_I,
               FSM_DONE_CTRL_O   => W_FSM_DONE_CTRL_O,
               DATA_BI           => W_DATA_BI,
               DATA_O            => W_DATA_O);



------------------------------------------------------------------------
--
-- Create a test clock
--
------------------------------------------------------------------------

   W_CLK <= not W_CLK after PERIOD/2;

------------------------------------------------------------------------
--
-- Create stimulus
--
------------------------------------------------------------------------

   STIMULI : process
 
------------------------------------------------------------------------
--
-- Procdures for creating stimulus
--
------------------------------------------------------------------------ 

 -- do_nop procdure
   
      procedure do_nop is
      begin
 
         W_RST                <= '0';
         W_INIT_FSM_CTRL_I     <= '0';
         W_DATA_BI                 <= 'H';

         wait for PERIOD*3;     

         assert false report " Performing a NOP." severity NOTE;
      end do_nop ;
   
 -- do_reset procedure
 
      procedure do_reset is
      begin

         W_RST                <= '1';
         W_INIT_FSM_CTRL_I     <= '0';
         W_DATA_BI                 <= 'H';

         -- reset the sampling register
         --instr_command <= "XXXXXXXX";

         wait for PERIOD*3;           
      
         assert false report " Resetting the state machine." severity NOTE;
         
         W_RST                <= '0';
         W_INIT_FSM_CTRL_I     <= '0';
         W_DATA_BI                 <= 'H';

         wait for PERIOD;
         
         -- self-checking
         if W_DATA_BI = 'H' and W_FSM_DONE_CTRL_O = '0' then
            result <= PASS;
         else
            result <= FAIL;
         end if;             
         
         wait for PERIOD;
         
         assert result report " *** Self-Checking FAILED for reset operation *** " severity FAILURE;
                 
      end do_reset ;

 
      procedure do_init is
      begin

         W_RST                <= '0';
         W_INIT_FSM_CTRL_I     <= '1';
         W_DATA_BI                 <= 'H';

         wait for PERIOD;           
      
         assert false report " Initializing the state machine." severity NOTE;
         
        end do_init ;
 
 
      
      procedure do_master_sample is
      begin
      
         while bit_count >= 0 loop

         wait until W_DATA_BI = '0';

         wait for 4 us;   
         
         -- output the family code, serial code and CRC one bit at a time ;
         if SERIAL_CODE(bit_count) = '1' then--(bit_count downto bit_count) = '1' then
            W_DATA_BI <= 'H';
         else
            W_DATA_BI <= 'L';
         end if;   
         assert false report " Master is sampling bit from the DS18S20 " severity NOTE;
         bit_count <= bit_count - 1;       
           
         wait for 56 us;
         
         W_DATA_BI                 <= 'H';        
                  
         end loop;
         
      end do_master_sample; 
      

      procedure do_finish is
      begin

         wait for 60 us;   
         
      end do_finish; 


------------------------------------------------------------------------
--
-- Start the test
--
------------------------------------------------------------------------
 
   begin
   
      do_nop;
      
      do_reset;  
      
      do_init;
             
      do_master_sample;

      do_finish;
      
      assert false report " Simulation done." severity FAILURE;
      
   end process STIMULI;

end BEH;