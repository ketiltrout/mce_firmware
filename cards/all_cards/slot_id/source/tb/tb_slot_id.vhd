-- tb_slot_id.vhd
--
-- <revision control keyword substitutions e.g. $Id$>
--
-- Project:		SCUBA 2
-- Author:		jjacob
-- Organisation:	UBC Physics and Astronomy
--
-- Description:
-- This code implements the testbench for the Slot ID
--
-- Revision history:
-- <date $Date$>	-		<text>		- <initials $Author$>
--
------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

library WORK;
use WORK.slot_id_pack.all;

library sys_param;
use sys_param.wishbone_pack.all;

entity TB_SLOT_ID is
end TB_SLOT_ID;

architecture BEH of TB_SLOT_ID is

   constant PERIOD : time := 10 ns;
   constant W_SLAVE_SEL : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := SLOT_ID_ADDR;
      

   signal W_SLOT_ID_I   : std_logic_vector (SLOT_ID_BITS-1 downto 0) := "1010";
   signal W_CLK_I       : std_logic := '0';
   signal W_RST_I       : std_logic ;
   signal W_DAT_I       : std_logic_vector (WB_DATA_WIDTH-1 downto 0);
   signal W_DAT_O       : std_logic_vector (WB_DATA_WIDTH-1 downto 0);
   signal W_ADDR_I      : std_logic_vector (WB_ADDR_WIDTH-1 downto 0);
   signal W_WE_I        : std_logic ;
   signal W_STB_I       : std_logic ;
   signal W_ACK_O       : std_logic ;
   signal W_CYC_I       : std_logic ;

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

   DUT : SLOT_ID
   
      generic map(
               SLOT_ID_ADDR  => SLOT_ID_ADDR,
               SLOT_ID_ADDR_WIDTH => WB_ADDR_WIDTH,
               SLOT_ID_DATA_WIDTH => WB_DATA_WIDTH)

      port map(SLOT_ID_I   => W_SLOT_ID_I,
               CLK_I       => W_CLK_I,
               RST_I       => W_RST_I,
               DAT_I       => W_DAT_I,
               DAT_O       => W_DAT_O,
               ADDR_I      => W_ADDR_I,
               WE_I        => W_WE_I,
               STB_I       => W_STB_I,
               ACK_O       => W_ACK_O,
               CYC_I       => W_CYC_I);


 
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
               
         wait for PERIOD*3;
      
         assert false report " Resetting the design." severity NOTE;
      end do_reset ;


-- do_read procdure

      procedure do_read is
      begin
      
      -- master starts a read cycle, but slave is not immediately ready
      if toggle = '1' then
      

         W_RST_I                 <= '0';
         W_ADDR_I                <= W_SLAVE_SEL;
         W_WE_I                  <= '0';
         W_STB_I                 <= '1';
         W_CYC_I                 <= '1';
      
         wait for PERIOD * multiple;
         
         W_RST_I                 <= '0';
         W_ADDR_I                <= W_SLAVE_SEL;
         W_WE_I                  <= '0';
         W_STB_I                 <= '1';
         W_CYC_I                 <= '1';
         
         wait for PERIOD * multiple;
         
      else -- master starts a read cycle, and slave is immediately ready
      
         W_RST_I                 <= '0';
         W_ADDR_I                <= W_SLAVE_SEL;
         W_WE_I                  <= '0';
         W_STB_I                 <= '1';
         W_CYC_I                 <= '1';
         
         wait for PERIOD * multiple;
         
         
      end if;
      
         rand_loop <= multiple;
                  
         wait for PERIOD*multiple;
         
         if toggle = '1' then -- go into the loop and create random wait states
                 
            while rand_loop > 0 loop
         
               if multiple <= 3 then -- slave de-asserts its ready signal and delays the cycle
               
                  assert false report " Slave delays the READ cycle." severity NOTE;

                  W_RST_I                 <= '0';
                  W_ADDR_I                <= W_SLAVE_SEL;
                  W_WE_I                  <= '0';
                  W_STB_I                 <= '1';
                  W_CYC_I                 <= '1';
         
                  wait for PERIOD*multiple;   
            
               elsif multiple <= 7 then -- master de-asserts the strobe signal and delays the cycle
               
                  assert false report " Master delays the READ cycle." severity NOTE;

                  W_RST_I                 <= '0';
                  W_ADDR_I                <= W_SLAVE_SEL;
                  W_WE_I                  <= '0';
                  W_STB_I                 <= '0';
                  W_CYC_I                 <= '1';
                  
                  wait for PERIOD*multiple;   
            
               elsif multiple <= 11 then -- both de-assert their ready signals and delay the cycle
               
                  assert false report " Master and Slave delay the READ cycle." severity NOTE;

                  W_RST_I                 <= '0';
                  W_ADDR_I                <= W_SLAVE_SEL;
                  W_WE_I                  <= '0';
                  W_STB_I                 <= '0';
                  W_CYC_I                 <= '1';
                          
                  wait for PERIOD*multiple;
                  
               else -- both are ready
               
                  assert false report " Master and Slave both ready for READ cycle." severity NOTE;

                  W_RST_I                 <= '0';
                  W_ADDR_I                <= W_SLAVE_SEL;
                  W_WE_I                  <= '0';
                  W_STB_I                 <= '1';
                  W_CYC_I                 <= '1';              
               
                  wait for PERIOD*multiple;
               
               end if;
            

               W_RST_I                 <= '0';
               W_ADDR_I                <= W_SLAVE_SEL;
               W_WE_I                  <= '0';
               W_STB_I                 <= '1';
               W_CYC_I                 <= '1';            
                    
               rand_loop <= rand_loop - 1;
            
               wait for PERIOD*multiple;
            
            end loop;
            

            W_RST_I                 <= '0';
            W_ADDR_I                <= W_SLAVE_SEL;
            W_WE_I                  <= '0';
            W_STB_I                 <= '0';
            W_CYC_I                 <= '0';
            
            wait for PERIOD*multiple;
            
            toggle                  <= not(toggle);
         
         else -- do simple read
         -- end the read cycle 
         
            wait for PERIOD*multiple;         

            W_RST_I                 <= '0';
            W_ADDR_I                <= W_SLAVE_SEL;
            W_WE_I                  <= '0';
            W_STB_I                 <= '0';
            W_CYC_I                 <= '0';
         
            wait for PERIOD*multiple;      
            
            toggle                  <= not(toggle);       
            
         assert false report " Performing a READ." severity NOTE;
         end if;
         
      end do_read ;   
   
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
      
      assert false report " Simulation done." severity FAILURE;

   end process STIMULI;

end BEH;

------------------------------------------------------------------------
--
-- Configuration
--
------------------------------------------------------------------------ 

configuration TB_SLOT_ID_CONF of TB_SLOT_ID is
   for BEH
   end for;
end TB_SLOT_ID_CONF;