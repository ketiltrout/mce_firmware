-- tb_watchdog.vhd
--
-- <revision control keyword substitutions e.g. $Id: tb_watchdog.vhd,v 1.1 2004/03/05 22:38:35 jjacob Exp $>
--
-- Project:		SCUBA2
-- Author:		Bryce Burger
-- Organisation:	UBC Physics and Astronomy
--
-- Description:
-- This code implements the testbench for the Array ID
--
-- Revision history:
-- <date $Date: 2004/03/05 22:38:35 $>	-		<text>		- <initials $Author: jjacob $>
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

   --constant PERIOD : time := 10 ns;
   constant W_SLAVE_SEL : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := WATCHDOG_ADDR;
      
   signal W_DAT_A : std_logic_vector (WB_DATA_WIDTH-1 downto 0) := "00000000000000000000000000000000";
   signal W_DAT_B : std_logic_vector (WB_DATA_WIDTH-1 downto 0) := "00000000000000000000000000000001";
   
   signal W_CLK_I : std_logic := '0';
   signal W_RST_I : std_logic;
   signal W_DAT_I : std_logic_vector ( WB_DATA_WIDTH - 1 downto 0 );
   signal W_DAT_O : std_logic_vector ( WB_DATA_WIDTH - 1 downto 0 );
   signal W_ADDR_I : std_logic_vector ( WB_ADDR_WIDTH - 1 downto 0 );
   signal dummy : std_logic_vector ( WB_TAG_ADDR_WIDTH - 1 downto 0 );
   signal W_WE_I : std_logic;
   signal W_STB_I : std_logic;
   signal W_ACK_O : std_logic;
   signal W_CYC_I : std_logic;
   signal w_you_kick_my_dog_o : std_logic;
--   signal w_wdtrl_o : integer;
--   signal w_wshbnhnrl_o : integer;
--   signal w_state_o : std_logic_vector(1 downto 0);


------------------------------------------------------------------------
--
-- Signals for the random number generator
--
------------------------------------------------------------------------

   signal feedback                : std_logic;
   signal rand_num                : std_logic_vector(7 downto 0);
   signal multiple                : integer;
   signal rand_loop               : integer := 0;
   signal toggle                  : std_logic := '1';
   
------------------------------------------------------------------------
--
-- Instantiate the design
--
------------------------------------------------------------------------

begin

   DUT : watchdog
      generic map(
         SLAVE_SEL  => WATCHDOG_ADDR,
         ADDR_WIDTH => WB_ADDR_WIDTH,
         DATA_WIDTH => WB_DATA_WIDTH,
         TAG_ADDR_WIDTH => WB_TAG_ADDR_WIDTH
      )
      port map(
         CLK_I => W_CLK_I,
         RST_I => W_RST_I,
         DAT_I => W_DAT_I,
         ADDR_I => W_ADDR_I,
         TGA_I => dummy,
         WE_I => W_WE_I,
         STB_I => W_STB_I,
         CYC_I => W_CYC_I,
         DAT_O => W_DAT_O,
         ACK_O => W_ACK_O,

         you_kick_my_dog => w_you_kick_my_dog_o
--         wdt_reached_lim => w_wdtrl_o,
--         wshbn_notreached_lim => w_wshbnhnrl_o,
--         wshbn_mach_state => w_state_o
      );

------------------------------------------------------------------------
--
-- Create a test clock
--
------------------------------------------------------------------------

   W_CLK_I <= not W_CLK_I after CLOCK_PERIOD/2;

------------------------------------------------------------------------
--
-- Random Number Generator
--
------------------------------------------------------------------------

   -- Right now, feedback and rand_num are unconnected to anything
   feedback <= (not(rand_num(7) xor rand_num(5) xor rand_num(4) xor rand_num(3)));
   
   process (W_CLK_I, W_RST_I)
   begin
      if W_RST_I = '1' then
         rand_num <= "00000000";
      elsif (W_CLK_I'event and W_CLK_I = '1') then
         rand_num <= rand_num(6 downto 0) & feedback;
      end if;
   end process;

   multiple <= 1 when (conv_integer(rand_num(3 downto 0)))= 0 else
               (conv_integer(rand_num(3 downto 0)));
               
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

         W_RST_I       <= '0';
         W_DAT_I       <= (others => '0');
         W_ADDR_I      <= (others => '0');
         W_WE_I        <= '0';
         W_STB_I       <= '0';
         W_CYC_I       <= '0';
         wait for CLOCK_PERIOD;
      
         assert false report " Performing a NOP." severity NOTE;
      end do_nop ;
   
   
 -- do_reset procdure
 
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


-- do_kick procdure

      procedure do_kick (watchdog_dat_string : in std_logic_vector (WB_DATA_WIDTH-1 downto 0)) is
      begin

         W_RST_I 			<= '0';
         W_ADDR_I 			<= W_SLAVE_SEL;
         -- DAT_O: don't care
         W_DAT_I 			<= watchdog_dat_string;
         W_WE_I 			<= '1';
         W_STB_I 			<= '1';
         W_CYC_I 			<= '1';
         wait until W_ACK_O = '1';
         wait for CLOCK_PERIOD;      

         W_RST_I 			<= '0';
         W_ADDR_I 			<= (others => '0');
         -- DAT_O: don't care
         W_DAT_I 			<= (others => '0');
         W_WE_I 			<= '0';
         W_STB_I 			<= '0';
         W_CYC_I 			<= '0';
         -- W_ACK_O: don't care         
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
       
      do_kick(W_DAT_A);
      do_nop;
      do_kick(W_DAT_B);
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

configuration TB_WATCHDOG_CONF of TB_WATCHDOG is
   for BEH
   end for;
end TB_WATCHDOG_CONF;