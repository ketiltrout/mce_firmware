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


entity TB_CARD_ID_WRITE_0x33 is
end TB_CARD_ID_WRITE_0x33;

architecture BEH of TB_CARD_ID_WRITE_0x33 is

--   component card_id_write_0x33
--
--   port (
--
--      clk                 : in std_logic;
--      rst                 : in std_logic;
--      init_fsm_ctrl_i     : in std_logic;
--      data_bi             : inout std_logic_vector(0 downto 0);
--      fsm_done_ctrl_o     : out std_logic 
-- 
--   );
--   end component;

   constant PERIOD : time := 20 ns;

   signal W_CLK                : std_logic := '0';
   signal W_RST                : std_logic ;
   signal W_INIT_FSM_CTRL_I     : std_logic ;
   signal W_DATA_BI                 : std_logic;
   signal W_FSM_DONE_CTRL_O   : std_logic ;
   
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

   DUT : CARD_ID_WRITE_0x33
      port map(CLK                => W_CLK,
               RST                => W_RST,
               INIT_FSM_CTRL_I     => W_INIT_FSM_CTRL_I,
               DATA_BI                 => W_DATA_BI,
               FSM_DONE_CTRL_O   => W_FSM_DONE_CTRL_O);


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
         instr_command <= "XXXXXXXX";

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

      
      procedure do_master_write is
      begin

         W_RST                <= '0';
         W_INIT_FSM_CTRL_I     <= '1';
         W_DATA_BI                 <= 'H';

         assert false report " Master is writing to the DS18S20 " severity NOTE;

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