------------------------------------------------------------------------
--
-- 
--
-- <revision control keyword substitutions e.g. $Id: tb_card_id_cmd_convert_temp.vhd,v 1.1 2004/03/05 22:38:35 jjacob Exp $>
--
-- Project:		SCUBA 2
-- Author:		jjacob
-- Organisation:	UBC Physics and Astronomy
--
-- Description:
-- This code implements the testbench for the Wishbone Slave state machine
--
-- Revision history:
-- <date $Date: 2004/03/05 22:38:35 $>	-		<text>		- <initials $Author: jjacob $>
--
------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

library WORK;
use WORK.card_id_pack.all;


entity TB_CARD_ID_cmd_convert_temp is
end TB_CARD_ID_cmd_convert_temp;

architecture BEH of TB_CARD_ID_cmd_convert_temp is

   constant PERIOD : time := 20 ns;

   signal W_CLK                : std_logic := '0';
   signal W_RST                : std_logic ;
   signal W_cmd_convert_temp_start_I     : std_logic ;
   signal W_DATA_BI                 : std_logic;
   signal W_cmd_convert_temp_done_O   : std_logic ;
   
   signal instr_command          : std_logic_vector (7 downto 0);
   
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

   DUT : CARD_ID_cmd_convert_temp
      port map(CLK                => W_CLK,
               RST                => W_RST,
               cmd_convert_temp_start_I     => W_cmd_convert_temp_start_I,
               DATA_BI                 => W_DATA_BI,
               cmd_convert_temp_done_O   => W_cmd_convert_temp_done_O);


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
         W_cmd_convert_temp_start_I     <= '0';
         W_DATA_BI                 <= 'H';

         wait for PERIOD*3;     

         assert false report " Performing a NOP." severity NOTE;
      end do_nop ;
   
 -- do_reset procedure
 
      procedure do_reset is
      begin

         W_RST                <= '1';
         W_cmd_convert_temp_start_I     <= '0';
         W_DATA_BI                 <= 'H';

         -- reset the sampling register
         instr_command <= "XXXXXXXX";

         wait for PERIOD*3;           
      
         assert false report " Resetting the state machine." severity NOTE;
         
         W_RST                <= '0';
         W_cmd_convert_temp_start_I     <= '0';
         W_DATA_BI                 <= 'H';

         wait for PERIOD;
         
         -- self-checking
         if W_DATA_BI = 'H' and W_cmd_convert_temp_done_O = '0' then
            result <= PASS;
         else
            result <= FAIL;
         end if;             
         
         wait for PERIOD;
         
         assert result report " *** Self-Checking FAILED for reset operation *** " severity FAILURE;
                 
      end do_reset ;

      
      procedure do_master_write is
      begin

         W_RST                <= '0';
         W_cmd_convert_temp_start_I     <= '1';
         W_DATA_BI                 <= 'H';

         assert false report " Master is writing 0x44 to the DS18S20 " severity NOTE;

         wait until W_DATA_BI = '0';

         wait for 40 us;   
         
         -- sample the data and shift it into instr_command
         instr_command <= instr_command(6 downto 0) & W_DATA_BI;
                  
         wait for PERIOD;
      
         
      end do_master_write; 
      

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
             
      do_master_write;
      do_master_write;
      do_master_write;
      do_master_write;
      
      do_master_write;
      do_master_write;
      do_master_write;
      do_master_write;

      do_finish;
      
      assert false report " Simulation done." severity FAILURE;
      
   end process STIMULI;

end BEH;