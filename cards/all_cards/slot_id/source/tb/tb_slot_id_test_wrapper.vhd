-- Copyright (c) 2003 SCUBA-2 Project
--                  All Rights Reserved

--  THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF THE SCUBA-2 Project
--  The copyright notice above does not evidence any
--  actual or intended publication of such source code.

--  SOURCE CODE IS PROVIDED "AS IS". ALL EXPRESS OR IMPLIED CONDITIONS,
--  REPRESENTATIONS, AND WARRANTIES, INCLUDING ANY IMPLIED WARRANT OF
--  MERCHANTABILITY, SATISFACTORY QUALITY, FITNESS FOR A PARTICULAR
--  PURPOSE, OR NON-INFRINGEMENT, ARE DISCLAIMED, EXCEPT TO THE EXTENT
--  THAT SUCH DISCLAIMERS ARE HELD TO BE LEGALLY INVALID.

-- For the purposes of this code the SCUBA-2 Project consists of the
-- following organisations.

-- UKATC, Royal Observatory, Blackford Hill Edinburgh EH9 3HJ
-- UBC,   University of British Columbia, Physics & Astronomy Department,
--        Vancouver BC, V6T 1Z1

-- 
--
-- <revision control keyword substitutions e.g. $Id: tb_slot_id_test_wrapper.vhd,v 1.2 2004/03/24 22:45:36 erniel Exp $>
--
-- Project:	      SCUBA-2
-- Author:	       Jonathan Jacob
-- Organisation:  UBC
--
-- Description:
-- 
--
-- Revision history:
-- Feb. 3 2004   - Initial version      - JJ
-- <date $Date: 2004/03/24 22:45:36 $>	-		<text>		- <initials $Author: erniel $>
-- $Log: tb_slot_id_test_wrapper.vhd,v $
-- Revision 1.2  2004/03/24 22:45:36  erniel
-- slightly modified do_tx_byte_to_RS232 to assert tx_busy_i longer
-- slightly modified do_finish to wait for done_o before deasserting en_i
--
--
-----------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;

library components;
use components.component_pack.all;

library sys_param;
use sys_param.wishbone_pack.all;


entity TB_SLOT_ID_TEST_WRAPPER is
end TB_SLOT_ID_TEST_WRAPPER;

architecture BEH of TB_SLOT_ID_TEST_WRAPPER is

   component SLOT_ID_TEST_WRAPPER
      port(RST_I       : in std_logic ;
           CLK_I       : in std_logic ;
           EN_I        : in std_logic ;
           DONE_O      : out std_logic ;
           TX_BUSY_I   : in std_logic ;
           TX_ACK_I    : in std_logic ;
           TX_DATA_O   : out std_logic_vector ( 7 downto 0 );
           TX_WE_O     : out std_logic ;
           TX_STB_O    : out std_logic ;
           SLOT_ID_I   : in std_logic_vector(3 downto 0) );

   end component;


   constant PERIOD : time := 20 ns;

   signal W_RST_I       : std_logic ;
   signal W_CLK_I       : std_logic := '0';
   signal W_EN_I        : std_logic ;
   signal W_DONE_O      : std_logic ;
   signal W_TX_BUSY_I   : std_logic ;
   signal W_TX_ACK_I    : std_logic ;
   signal W_TX_DATA_O   : std_logic_vector ( 7 downto 0 );
   signal W_TX_WE_O     : std_logic ;
   signal W_TX_STB_O    : std_logic ;
   signal W_SLOT_ID_I   : std_logic_vector(3 downto 0) ;

   
   signal instr_command       : std_logic_vector(7 downto 0) := "00000000";

   constant SLOT_ID           : std_logic_vector(3 downto 0) := "1100"; -- 0xC

begin

------------------------------------------------------------------------
--
-- instantiate slot_id_test_wrapper
--
------------------------------------------------------------------------

   DUT : SLOT_ID_TEST_WRAPPER
      port map(RST_I       => W_RST_I,
               CLK_I       => W_CLK_I,
               EN_I        => W_EN_I,
               DONE_O      => W_DONE_O,
               TX_BUSY_I   => W_TX_BUSY_I,
               TX_ACK_I    => W_TX_ACK_I,
               TX_DATA_O   => W_TX_DATA_O,
               TX_WE_O     => W_TX_WE_O,
               TX_STB_O    => W_TX_STB_O,
               SLOT_ID_I   => W_SLOT_ID_I);


------------------------------------------------------------------------
--
-- Create a test clock
--
------------------------------------------------------------------------

   W_CLK_I <= not W_CLK_I after PERIOD/2;
   
   

------------------------------------------------------------------------
--
-- Create stimulus
--
------------------------------------------------------------------------

   STIMULI : process
   
------------------------------------------------------------------------
--
-- Procdures for creating stimulus. MODEL THE SLOT ID, and the test interface
--
------------------------------------------------------------------------ 

      procedure do_nop is
      begin
      
         -- test software signals
         W_RST_I       <= '0';
         W_EN_I        <= '0';
         W_TX_BUSY_I   <= '0';
         W_TX_ACK_I    <= '0';
      
         -- slot ID signal
         W_SLOT_ID_I   <= "0000";
         
         wait for PERIOD;
         
         assert false report " Performing a NOP." severity NOTE;
      end do_nop ;
      
      
      procedure do_full_reset is
      begin
      
         -- test software signals
         W_RST_I       <= '1';
         W_EN_I        <= '0';
         W_TX_BUSY_I   <= '0';
         W_TX_ACK_I    <= '0';      
      
         -- slot ID signal
         W_SLOT_ID_I   <= "0000";
         
         wait for PERIOD*3;

         -- test software signals
         W_RST_I       <= '0';
         W_EN_I        <= '0';
         W_TX_BUSY_I   <= '0';
         W_TX_ACK_I    <= '0';      
      
         -- slot ID signal
         W_SLOT_ID_I   <= SLOT_ID;
         
         wait for PERIOD;
         
         assert false report " Performing a RESET." severity NOTE;
      end do_full_reset ;      


      procedure do_start is
      begin
      
         -- test software signals
         W_RST_I       <= '0';
         W_EN_I        <= '1';
         W_TX_BUSY_I   <= '0';
         W_TX_ACK_I    <= '0';

         -- slot ID signal
         W_SLOT_ID_I   <= SLOT_ID;
         
         wait for PERIOD;
         
         assert false report " STARTING the TEST." severity NOTE;
      end do_start ;     


 
      procedure do_wait is
      begin
      
         wait for PERIOD;
         
         -- test software signals
         W_RST_I       <= '0';
         W_EN_I        <= '1';
         W_TX_BUSY_I   <= '0';
         W_TX_ACK_I    <= '0';      
      
         -- slot ID signal
         W_SLOT_ID_I   <= SLOT_ID;
         
         wait for 10 us;        
         
         assert false report " Waiting for 10 us." severity NOTE;
      end do_wait ;     
      
 
 
      procedure do_tx_byte_to_RS232 is
      begin


         -- this means the test wrapper is ready to send data to the RS232
         if w_tx_stb_o = '0' then
            wait until w_tx_stb_o = '1';
         end if;
         
         if w_tx_we_o = '0' then
            wait until w_tx_we_o = '1';
         end if;
         
         -- test software signals
         W_RST_I       <= '0';
         W_EN_I        <= '1';
         W_TX_BUSY_I   <= '0';
         W_TX_ACK_I    <= '1';  -- grab the data
         
         wait for PERIOD;
         
         W_RST_I       <= '0';
         W_EN_I        <= '1';
         W_TX_BUSY_I   <= '1';  -- indicates it's busy now writing the "grabbed" data to the RS232
         W_TX_ACK_I    <= '0';
         
         
         wait for PERIOD*3;    

         W_RST_I       <= '0';
         W_EN_I        <= '1';
         W_TX_BUSY_I   <= '0';  -- indicates it's busy now writing the "grabbed" data to the RS232
         W_TX_ACK_I    <= '0';
         
         wait for PERIOD;    
         
         assert false report " Writing out the data to RS232." severity NOTE;
      end do_tx_byte_to_RS232;    



      procedure do_finish is
      begin
      
         wait until W_DONE_O = '1';
         wait for PERIOD;
         
         -- test software signals
         W_RST_I       <= '0';
         W_EN_I        <= '0';
         W_TX_BUSY_I   <= '0';
         W_TX_ACK_I    <= '0';      
      
         -- ID chip signal
         W_SLOT_ID_I   <= SLOT_ID;      

         wait for 1 us;     
 
         assert false report " Finishing up..." severity NOTE;
      end do_finish ;     

------------------------------------------------------------------------
--
-- Start the test
--
------------------------------------------------------------------------
          
   begin
      do_nop;
      
      do_full_reset;  
      
      do_start;
      
      do_tx_byte_to_RS232;

      do_finish;
      
      assert false report " FINISHED: Simulation done." severity FAILURE;
      
   end process STIMULI;

end beh;
