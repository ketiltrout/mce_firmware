-- tb_frame_timing.vhd
--
-- <revision control keyword substitutions e.g. $Id: tb_frame_timing.vhd,v 1.1 2004/04/02 20:01:33 bburger Exp $>
--
-- Project:		SCUBA2
-- Author:		Bryce Burger
-- Organisation:	UBC Physics and Astronomy
--
-- Description:
-- This code implements the testbench for the Array ID
--
-- Revision history:
-- <date $Date: 2004/04/02 20:01:33 $>	-		<text>		- <initials $Author: bburger $>
--
------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

library sys_param;
use sys_param.frame_timing_pack.all;
use sys_param.general_pack.all;

entity TB_FRAME_TIMING is
end TB_FRAME_TIMING;

architecture BEH of TB_FRAME_TIMING is

--   signal tb_clk_o : std_logic;
   signal tb_sync_o : std_logic;
   signal tb_rst_on_next_sync_o : std_logic;
   signal tb_cycle_count_i : std_logic_vector(31 downto 0);
   signal tb_cycle_error_i : std_logic_vector(31 downto 0);

   signal W_CLK_I : std_logic := '0';
   
------------------------------------------------------------------------
--
-- Instantiate the design
--
------------------------------------------------------------------------

begin

   DUT : frame_timing
      port map(
         clk_i => W_CLK_I,
         sync_i => tb_sync_o,
         rst_on_next_sync_i => tb_rst_on_next_sync_o,
         cycle_count_o => tb_cycle_count_i,
         cycle_error_o => tb_cycle_error_i
      );

------------------------------------------------------------------------
--
-- Create a test clock
--
------------------------------------------------------------------------

   W_CLK_I <= not W_CLK_I after CLOCK_PERIOD/2;

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


         wait for CLOCK_PERIOD;      
         assert false report " Performing a NOP." severity NOTE;
      end do_nop ;
   
   
 -- do_reset procdure
 
      procedure do_reset is
      begin

         wait for CLOCK_PERIOD;
         assert false report " Resetting the design." severity NOTE;
      end do_reset ;


-- do_kick procdure

      procedure do_kick is
      begin

--         wait until W_ACK_O = '1';

         wait for CLOCK_PERIOD;      
         assert false report " Performing a WRITE." severity NOTE;
      end do_kick;   

------------------------------------------------------------------------
--
-- Start the test
--
------------------------------------------------------------------------
 
   begin
   
      do_nop;
      do_reset;
      do_nop;
      
      L1 : for count_value in 1 to 165 loop
         do_nop;
      end loop L1;  
       
      do_kick;
      do_nop;
      do_kick;
      do_nop;

      L2 : for count_value in 1 to 165 loop
         do_nop;
      end loop L2;  
      
      assert false report " Simulation done." severity FAILURE;

   end process STIMULI;

end BEH;

------------------------------------------------------------------------
--
-- Configuration
--
------------------------------------------------------------------------ 

configuration TB_FRAME_TIMING_CONF of TB_FRAME_TIMING is
   for BEH
   end for;
end TB_FRAME_TIMING_CONF;