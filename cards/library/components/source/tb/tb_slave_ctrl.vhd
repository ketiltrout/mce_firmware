------------------------------------------------------------------------
--
-- tb_slave_ctrl.vhd
--
-- <revision control keyword substitutions e.g. $Id: tb_slave_ctrl.vhd,v 1.1 2004/03/05 22:38:35 jjacob Exp $>
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

--library WORK;
--use WORK.slave_ctrl_pack.all;
library sys_param;
use sys_param.wishbone_pack.all;

library components;
use components.component_pack.all;

entity TB_SLAVE_CTRL is
end TB_SLAVE_CTRL;

architecture BEH of TB_SLAVE_CTRL is

   constant PERIOD : time := 10 ns;
   constant W_SLAVE_SEL : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := "00010000";
   
   signal W_SLAVE_WR_READY         : std_logic ;
   signal W_SLAVE_RD_DATA_VALID    : std_logic ;
   signal W_MASTER_WR_DATA_VALID   : std_logic ;
   signal W_SLAVE_CTRL_DAT_I       : std_logic_vector ( WB_DATA_WIDTH - 1 downto 0 ) := (others => '1');
   signal W_SLAVE_CTRL_DAT_O       : std_logic_vector ( WB_DATA_WIDTH - 1 downto 0 );
   signal W_SLAVE_CTRL_TGA_O       : std_logic_vector ( WB_TAG_ADDR_WIDTH - 1 downto 0 );
   signal W_CLK_I                  : std_logic := '0';
   signal W_RST_I                  : std_logic ;
   signal W_DAT_I                  : std_logic_vector ( WB_DATA_WIDTH - 1 downto 0 ) := (others => '1');
   signal W_ADDR_I                 : std_logic_vector ( WB_ADDR_WIDTH - 1 downto 0 );
   signal W_TGA_I                  : std_logic_vector ( WB_TAG_ADDR_WIDTH - 1 downto 0 );
   signal W_WE_I                   : std_logic ;
   signal W_STB_I                  : std_logic ;
   signal W_CYC_I                  : std_logic ;
   signal W_DAT_O                  : std_logic_vector ( WB_DATA_WIDTH - 1 downto 0 );
   signal W_RTY_O                  : std_logic ;
   signal W_ACK_O                  : std_logic ;
   signal w_slave_retry             : std_logic ;
------------------------------------------------------------------------
--
-- Signals for the random number generator
--
------------------------------------------------------------------------

   signal feedback                : std_logic;
   signal rand_num                : std_logic_vector(7 downto 0);
   signal multiple                : integer;
   signal rand_loop               : integer := 0;
   signal toggle                  : std_logic := '0';
   
   
------------------------------------------------------------------------
--
-- Instantiate the design
--
------------------------------------------------------------------------
begin

   DUT : SLAVE_CTRL

      generic map(SLAVE_SEL        => "00010000",
                  ADDR_WIDTH       => WB_ADDR_WIDTH ,
                  DATA_WIDTH       => WB_DATA_WIDTH ,
                  TAG_ADDR_WIDTH   => WB_TAG_ADDR_WIDTH )

      port map(SLAVE_WR_READY         => W_SLAVE_WR_READY,
               SLAVE_RD_DATA_VALID    => W_SLAVE_RD_DATA_VALID,
               MASTER_WR_DATA_VALID   => W_MASTER_WR_DATA_VALID,
               SLAVE_CTRL_DAT_I       => W_SLAVE_CTRL_DAT_I,
               SLAVE_CTRL_DAT_O       => W_SLAVE_CTRL_DAT_O,
               SLAVE_CTRL_TGA_O       => W_SLAVE_CTRL_TGA_O,
               CLK_I                  => W_CLK_I,
               RST_I                  => W_RST_I,
               DAT_I                  => W_DAT_I,
               ADDR_I                 => W_ADDR_I,
               TGA_I                  => W_TGA_I,
               WE_I                   => W_WE_I,
               STB_I                  => W_STB_I,
               CYC_I                  => W_CYC_I,
               DAT_O                  => W_DAT_O,
               RTY_O                  => W_RTY_O,
               ACK_O                  => W_ACK_O,
               slave_retry            => w_slave_retry);



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
         W_SLAVE_WR_READY        <= '0';
         W_SLAVE_RD_DATA_VALID   <= '0';
         W_RST_I                 <= '0';
         W_ADDR_I                <= (others => '0');
         W_WE_I                  <= '0';
         W_STB_I                 <= '0';
         W_CYC_I                 <= '0';
      
         wait for PERIOD;
      
         assert false report " Performing a NOP." severity NOTE;
      end do_nop ;
   
   
 -- do_reset procdure
 
      procedure do_reset is
      begin
         W_SLAVE_WR_READY        <= '0';
         W_SLAVE_RD_DATA_VALID   <= '0';
         W_RST_I                 <= '1';
         W_ADDR_I                <= (others => '0');
         W_WE_I                  <= '0';
         W_STB_I                 <= '0';
         W_CYC_I                 <= '0';
      
         wait for PERIOD*3;
      
         assert false report " Resetting the design." severity NOTE;
      end do_reset ;


-- do_read procdure

      procedure do_read is
      begin
      
      -- master starts a read cycle, but slave is not immediately ready
      if toggle = '1' then
      
         W_SLAVE_WR_READY        <= '0';
         W_SLAVE_RD_DATA_VALID   <= '0';
         W_RST_I                 <= '0';
         W_ADDR_I                <= W_SLAVE_SEL;
         W_WE_I                  <= '0';
         W_STB_I                 <= '1';
         W_CYC_I                 <= '1';
      
         wait for PERIOD * multiple;
         
         W_SLAVE_WR_READY        <= '0';
         W_SLAVE_RD_DATA_VALID   <= '1';
         W_RST_I                 <= '0';
         W_ADDR_I                <= W_SLAVE_SEL;
         W_WE_I                  <= '0';
         W_STB_I                 <= '1';
         W_CYC_I                 <= '1';
         
         wait for PERIOD * multiple;
         
      else -- master starts a read cycle, and slave is immediately ready
      
         W_SLAVE_WR_READY        <= '0';
         W_SLAVE_RD_DATA_VALID   <= '1';
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
                  W_SLAVE_WR_READY        <= '0';
                  W_SLAVE_RD_DATA_VALID   <= '0';
                  W_RST_I                 <= '0';
                  W_ADDR_I                <= W_SLAVE_SEL;
                  W_WE_I                  <= '0';
                  W_STB_I                 <= '1';
                  W_CYC_I                 <= '1';
         
                  wait for PERIOD*multiple;   
            
               elsif multiple <= 7 then -- master de-asserts the strobe signal and delays the cycle
               
                  assert false report " Master delays the READ cycle." severity NOTE;
                  W_SLAVE_WR_READY        <= '0';
                  W_SLAVE_RD_DATA_VALID   <= '1';
                  W_RST_I                 <= '0';
                  W_ADDR_I                <= W_SLAVE_SEL;
                  W_WE_I                  <= '0';
                  W_STB_I                 <= '0';
                  W_CYC_I                 <= '1';
                  
                  wait for PERIOD*multiple;   
            
               elsif multiple <= 11 then -- both de-assert their ready signals and delay the cycle
               
                  assert false report " Master and Slave delay the READ cycle." severity NOTE;
                  W_SLAVE_WR_READY        <= '0';
                  W_SLAVE_RD_DATA_VALID   <= '0';
                  W_RST_I                 <= '0';
                  W_ADDR_I                <= W_SLAVE_SEL;
                  W_WE_I                  <= '0';
                  W_STB_I                 <= '0';
                  W_CYC_I                 <= '1';
                          
                  wait for PERIOD*multiple;
                  
               else -- both are ready
               
                  assert false report " Master and Slave both ready for READ cycle." severity NOTE;
                  W_SLAVE_WR_READY        <= '0';
                  W_SLAVE_RD_DATA_VALID   <= '1';
                  W_RST_I                 <= '0';
                  W_ADDR_I                <= W_SLAVE_SEL;
                  W_WE_I                  <= '0';
                  W_STB_I                 <= '1';
                  W_CYC_I                 <= '1';              
               
                  wait for PERIOD*multiple;
               
               end if;
            
               W_SLAVE_WR_READY        <= '0';
               W_SLAVE_RD_DATA_VALID   <= '1';
               W_RST_I                 <= '0';
               W_ADDR_I                <= W_SLAVE_SEL;
               W_WE_I                  <= '0';
               W_STB_I                 <= '1';
               W_CYC_I                 <= '1';            
                    
               rand_loop <= rand_loop - 1;
            
               wait for PERIOD*multiple;
            
            end loop;
            
            W_SLAVE_WR_READY        <= '0';
            W_SLAVE_RD_DATA_VALID   <= '0';
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
            W_SLAVE_WR_READY        <= '0';
            W_SLAVE_RD_DATA_VALID   <= '0';
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
      


-- do_read2 procedure
      procedure do_read2 is
      begin
      
      -- master starts a read cycle, but slave is not immediately ready
      
         W_SLAVE_WR_READY        <= '0';
         W_SLAVE_RD_DATA_VALID   <= '0';
         W_RST_I                 <= '0';
         W_ADDR_I                <= W_SLAVE_SEL;
         W_WE_I                  <= '0';
         W_STB_I                 <= '1';
         W_CYC_I                 <= '1';
      
         wait for PERIOD * 5 * multiple;
         
         W_SLAVE_WR_READY        <= '0';
         W_SLAVE_RD_DATA_VALID   <= '1';
         W_RST_I                 <= '0';
         W_ADDR_I                <= W_SLAVE_SEL;
         W_WE_I                  <= '0';
         W_STB_I                 <= '1';
         W_CYC_I                 <= '1';
         
         wait for PERIOD;
         
         W_SLAVE_WR_READY        <= '0';
         W_SLAVE_RD_DATA_VALID   <= '1';
         W_RST_I                 <= '0';
         W_ADDR_I                <= W_SLAVE_SEL;
         W_WE_I                  <= '0';
         W_STB_I                 <= '0';
         W_CYC_I                 <= '0';
         
         wait for PERIOD * multiple;  

         assert false report " Performing a READ2." severity NOTE;
    
         
      end do_read2 ;    

 -- do_write procedure
 
      procedure do_write is
      begin
            
      -- master starts a write cycle, but slave is not immediately ready
      
      if toggle = '1' then
   
         W_SLAVE_WR_READY        <= '0';
         W_SLAVE_RD_DATA_VALID   <= '0';
         W_RST_I                 <= '0';
         W_ADDR_I                <= W_SLAVE_SEL;
         W_WE_I                  <= '1';
         W_STB_I                 <= '1';
         W_CYC_I                 <= '1';
      
         wait for PERIOD * multiple;
         
         W_SLAVE_WR_READY        <= '1';
         W_SLAVE_RD_DATA_VALID   <= '0';
         W_RST_I                 <= '0';
         W_ADDR_I                <= W_SLAVE_SEL;
         W_WE_I                  <= '1';
         W_STB_I                 <= '1';
         W_CYC_I                 <= '1';
        
         wait for PERIOD * multiple;
        
      else -- master starts a write cycle, and slave is immediately ready
        
         W_SLAVE_WR_READY        <= '1';
         W_SLAVE_RD_DATA_VALID   <= '0';
         W_RST_I                 <= '0';
         W_ADDR_I                <= W_SLAVE_SEL;
         W_WE_I                  <= '1';
         W_STB_I                 <= '1';
         W_CYC_I                 <= '1';  
         
         wait for PERIOD * multiple;
               
      end if;
      
         rand_loop <= multiple;
         --toggle <= not(toggle);         
         wait for PERIOD*multiple;
           
           
         if toggle = '1' then  
                 
            while rand_loop > 0 loop
    
               if multiple <= 3 then -- slave de-asserts its ready signal and delays the cycle
               
                  assert false report " Slave delays the WRITE cycle." severity NOTE;
                  W_SLAVE_WR_READY        <= '0';
                  W_SLAVE_RD_DATA_VALID   <= '0';
                  W_RST_I                 <= '0';
                  W_ADDR_I                <= W_SLAVE_SEL;
                  W_WE_I                  <= '1';
                  W_STB_I                 <= '1';
                  W_CYC_I                 <= '1';
         
                  wait for PERIOD*multiple;   
            
               elsif multiple <= 7 then -- master de-asserts the strobe signal and delays the cycle
               
                  assert false report " Master delays the WRITE cycle." severity NOTE;
                  W_SLAVE_WR_READY        <= '1';
                  W_SLAVE_RD_DATA_VALID   <= '0';
                  W_RST_I                 <= '0';
                  W_ADDR_I                <= W_SLAVE_SEL;
                  W_WE_I                  <= '1';
                  W_STB_I                 <= '0';
                  W_CYC_I                 <= '1';
                  
                  wait for PERIOD*multiple;   
            
               elsif multiple <= 11 then -- both de-assert their ready signals and delay the cycle
               
                  assert false report " Master and Slave delay the WRITE cycle." severity NOTE;
                  W_SLAVE_WR_READY        <= '0';
                  W_SLAVE_RD_DATA_VALID   <= '0';
                  W_RST_I                 <= '0';
                  W_ADDR_I                <= W_SLAVE_SEL;
                  W_WE_I                  <= '1';
                  W_STB_I                 <= '0';
                  W_CYC_I                 <= '1';
                          
                  wait for PERIOD*multiple;
                  
               else -- both are ready
               
                  assert false report " Master and Slave both ready for WRITE cycle." severity NOTE;
                  W_SLAVE_WR_READY        <= '1';
                  W_SLAVE_RD_DATA_VALID   <= '0';
                  W_RST_I                 <= '0';
                  W_ADDR_I                <= W_SLAVE_SEL;
                  W_WE_I                  <= '1';
                  W_STB_I                 <= '1';
                  W_CYC_I                 <= '1';              
               
                  wait for PERIOD*multiple;
                  
               end if;
            
               W_SLAVE_WR_READY        <= '1';
               W_SLAVE_RD_DATA_VALID   <= '0';
               W_RST_I                 <= '0';
               W_ADDR_I                <= W_SLAVE_SEL;
               W_WE_I                  <= '1';
               W_STB_I                 <= '1';
               W_CYC_I                 <= '1';            
                    
               rand_loop <= rand_loop - 1;
               
               wait for PERIOD*multiple;
            
            end loop;
 
            W_SLAVE_WR_READY        <= '0';
            W_SLAVE_RD_DATA_VALID   <= '0';
            W_RST_I                 <= '0';
            W_ADDR_I                <= W_SLAVE_SEL;
            W_WE_I                  <= '0';
            W_STB_I                 <= '0';
            W_CYC_I                 <= '0';
         
            wait for PERIOD*multiple;                        
            
            toggle <= not(toggle);
         
         else -- do simple write
         -- end the write cycle right away 
         
            wait for PERIOD*multiple;         
            W_SLAVE_WR_READY        <= '0';
            W_SLAVE_RD_DATA_VALID   <= '0';
            W_RST_I                 <= '0';
            W_ADDR_I                <= W_SLAVE_SEL;
            W_WE_I                  <= '0';
            W_STB_I                 <= '0';
            W_CYC_I                 <= '0';
         
            wait for PERIOD*multiple;             
            
            toggle <= not(toggle);
            
         assert false report " Performing a WRITE." severity NOTE;
         end if;
         
      end do_write ;     

      
------------------------------------------------------------------------
--
-- Start the test
--
------------------------------------------------------------------------
 
   begin
      do_nop;
      do_reset;         
      do_nop;
      do_read2;
      do_read2;
      do_read2;
      do_nop;
      do_write;
      do_read2;
      do_nop;
      do_read2;
      
      do_nop;
      do_write;
      do_write;
      do_write;
      do_nop;
      do_read;
      do_write;
      do_write;
      do_read;
      do_nop;
      
      
      do_nop;
      do_read;
      do_nop;
      do_write;
      do_nop;
      do_write;
      do_nop;
      do_read;
      do_nop;
      do_write;
      do_nop;      
      do_read;
      do_read;
      do_write;
      do_write;
      do_read;
      do_write;
      do_nop;
      
      do_nop;
      
      assert false report " Simulation done." severity FAILURE;
      
   end process STIMULI;

end BEH;
