-- tb_watchdog.vhd
--
-- <revision control keyword substitutions e.g. $Id: tb_watchdog.vhd,v 1.2 2004/03/29 19:33:08 bburger Exp $>
--
-- Project:		SCUBA2
-- Author:		Bryce Burger
-- Organisation:	UBC Physics and Astronomy
--
-- Description:
-- This code implements the testbench for the watchdog
--
-- Revision history:
-- <date $Date: 2004/03/29 19:33:08 $>	-		<text>		- <initials $Author: bburger $>
-- $Log$
--
------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

library WORK;
use WORK.watchdog_pack.all;

library SYS_PARAM;
use SYS_PARAM.wishbone_pack.all;
use SYS_PARAM.general_pack.all;

entity TB_WATCHDOG is
end TB_WATCHDOG;

architecture BEH of TB_WATCHDOG is
   
   signal W_CLK_I : std_logic := '1';
   signal W_RST_I : std_logic;
   signal W_DAT_I : std_logic_vector ( WB_DATA_WIDTH - 1 downto 0 );
   signal W_DAT_O : std_logic_vector ( WB_DATA_WIDTH - 1 downto 0 );
   signal W_ADDR_I : std_logic_vector ( WB_ADDR_WIDTH - 1 downto 0 );
   signal W_TGA_I : std_logic_vector ( WB_TAG_ADDR_WIDTH - 1 downto 0 );
   signal W_WE_I : std_logic;
   signal W_STB_I : std_logic;
   signal W_ACK_O : std_logic;
   signal W_CYC_I : std_logic;
   signal w_you_kick_my_dog_o : std_logic;

   
------------------------------------------------------------------------
--
-- Instantiate the design
--
------------------------------------------------------------------------

begin

   DUT : watchdog
      generic map(
         ADDR_WIDTH => WB_ADDR_WIDTH,
         DATA_WIDTH => WB_DATA_WIDTH,
         TAG_ADDR_WIDTH => WB_TAG_ADDR_WIDTH
      )
      port map(
         CLK_I => W_CLK_I,
         RST_I => W_RST_I,
         DAT_I => W_DAT_I,
         ADDR_I => W_ADDR_I,
         TGA_I => W_TGA_I,
         WE_I => W_WE_I,
         STB_I => W_STB_I,
         CYC_I => W_CYC_I,
         DAT_O => W_DAT_O,
         ACK_O => W_ACK_O,

         you_kick_my_dog => w_you_kick_my_dog_o
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
 
   
      procedure do_nop is
      begin

         W_RST_I       <= '0';
         W_DAT_I       <= (others => '0');
         W_ADDR_I      <= (others => '0');
         W_WE_I        <= '0';
         W_STB_I       <= '0';
         W_CYC_I       <= '0';
         wait for CLOCK_PERIOD;
      
         assert false report " Performing a NOP." severity NOTE;
      end do_nop ;
   
 
      procedure do_reset is
      begin

         W_RST_I       <= '1';
         W_DAT_I       <= (others => '0');
         W_ADDR_I      <= (others => '0');
         W_WE_I        <= '0';
         W_STB_I       <= '0';
         W_CYC_I       <= '0';
         wait for CLOCK_PERIOD;
      
         assert false report " Resetting the design." severity NOTE;
      end do_reset ;


      procedure do_kick is
      begin

         W_RST_I 			<= '0';
         W_ADDR_I 			<= WATCHDOG_ADDR;
         W_DAT_I 			<= (others => '0');
         W_WE_I 			<= '1';
         W_STB_I 			<= '1';
         W_CYC_I 			<= '1';
         
         wait until W_ACK_O = '1';   

         W_RST_I 			<= '0';
         W_ADDR_I 			<= (others => '0');
         W_DAT_I 			<= (others => '0');
         W_WE_I 			<= '0';
         W_STB_I 			<= '0';
         W_CYC_I 			<= '0';        
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
  
      do_kick;
      
      wait for 25 us;
          
      do_kick;
      
      wait for 25 us;
      
      do_kick;
      
      wait for 600 us;
      
      assert false report " Simulation done." severity FAILURE;

   end process STIMULI;

end BEH;

