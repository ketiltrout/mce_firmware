-- tb_leds.vhd
--
-- <revision control keyword substitutions e.g. $Id: tb_leds.vhd,v 1.7 2004/04/21 20:02:21 bburger Exp $>
--
-- Project:		SCUBA2
-- Author:		Bryce Burger
-- Organisation:	UBC Physics and Astronomy
--
-- Description:
-- This code implements the testbench for the Array ID
--
-- Revision history:
-- <date $Date: 2004/04/21 20:02:21 $>	-		<text>		- <initials $Author: bburger $>
--
------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

library WORK;
use WORK.leds_pack.all;

library SYS_PARAM;
use SYS_PARAM.wishbone_pack.all;

entity TB_LEDS is
end TB_LEDS;

architecture BEH of TB_LEDS is

   constant PERIOD : time := 10 ns;
   constant W_SLAVE_SEL : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := BIT_STATUS_ADDR ;
      
   signal W_LEDS_A : std_logic_vector (WB_DATA_WIDTH-1 downto 0) := "000000000000000000000000" & "00001111";
   signal W_LEDS_B : std_logic_vector (WB_DATA_WIDTH-1 downto 0) := "000000000000000000000000" & "00110001";
   signal W_LEDS_C : std_logic_vector (WB_DATA_WIDTH-1 downto 0) := "000000000000000000000000" & "00110010";
   signal W_LEDS_D : std_logic_vector (WB_DATA_WIDTH-1 downto 0) := "000000000000000000000000" & "00110001";
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
   signal w_power_ok_o : std_logic;
   signal w_status_o : std_logic;
   signal w_fault_ok_o : std_logic;
   signal w_spare_ok_o : std_logic;
   

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

   DUT : LEDS
      generic map(
         SLAVE_SEL  => BIT_STATUS_ADDR,
         ADDR_WIDTH => WB_ADDR_WIDTH,
         DATA_WIDTH => WB_DATA_WIDTH,
         TAG_ADDR_WIDTH => WB_TAG_ADDR_WIDTH         
      )
      port map(
         CLK_I => W_CLK_I,
         RST_I => W_RST_I,
         DAT_I => W_DAT_I,
         DAT_O => W_DAT_O,
         ADDR_I => W_ADDR_I,
         TGA_I => dummy,
         WE_I => W_WE_I,
         STB_I => W_STB_I,
         ACK_O => W_ACK_O,
         CYC_I => W_CYC_I,
         power_ok	=> w_power_ok_o, 
         status => w_status_o,
         fault => w_fault_ok_o,
         spare => w_spare_ok_o
      );

------------------------------------------------------------------------
--
-- Create a test clock
--
------------------------------------------------------------------------

   W_CLK_I <= not W_CLK_I after PERIOD/2;

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
         wait for PERIOD;
      
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
         wait for PERIOD;
      
         assert false report " Resetting the design." severity NOTE;
      end do_reset ;


-- do_read procdure

      procedure do_read is
      begin
         -- master starts a read cycle, slave ready
         W_RST_I                 <= '0';
         W_ADDR_I                <= W_SLAVE_SEL;
         W_WE_I                  <= '0';
         W_STB_I                 <= '1';
         W_CYC_I                 <= '1';
         wait for PERIOD;

         W_RST_I                 <= '0';
         W_ADDR_I                <= W_SLAVE_SEL;
         W_WE_I                  <= '0';
         W_STB_I                 <= '0';
         W_CYC_I                 <= '0';
         wait for PERIOD;      

         assert false report " Performing a READ." severity NOTE;
      end do_read ;   
   
-- do_write procdure

      procedure do_write (leds_dat_string : in std_logic_vector (WB_DATA_WIDTH-1 downto 0)) is
      begin

         W_RST_I 			<= '0';
         W_ADDR_I 			<= W_SLAVE_SEL;
         -- DAT_O: don't care
         W_DAT_I 			<= leds_dat_string;
         W_WE_I 			<= '1';
         W_STB_I 			<= '1';
         W_CYC_I 			<= '1';
         wait until W_ACK_O = '1';
         wait for PERIOD;      

         W_RST_I 			<= '0';
         W_ADDR_I 			<= (others => '0');
         -- DAT_O: don't care
         W_DAT_I 			<= (others => '0');
         W_WE_I 			<= '0';
         W_STB_I 			<= '0';
         W_CYC_I 			<= '0';
         -- W_ACK_O: don't care         
         wait for PERIOD;      

         assert false report " Performing a WRITE." severity NOTE;
      end do_write;   

------------------------------------------------------------------------
--
-- Start the test
--
------------------------------------------------------------------------
 
   begin
   
      do_nop;
      do_reset;
      do_nop;   
      do_read;
      do_nop;      
      do_write(W_LEDS_A);
      do_nop;
      do_write(W_LEDS_B);
      do_nop;
      do_write(W_LEDS_C);
      do_nop;
      do_write(W_LEDS_D);
      do_nop;
      do_read;
      do_nop;
      
      assert false report " Simulation done." severity FAILURE;

   end process STIMULI;

end BEH;

------------------------------------------------------------------------
--
-- Configuration
--
------------------------------------------------------------------------ 

configuration TB_LEDS_CONF of TB_LEDS is
   for BEH
   end for;
end TB_LEDS_CONF;