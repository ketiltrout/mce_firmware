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
-- <revision control keyword substitutions e.g. $Id$>
--
-- Project:	      SCUBA-2
-- Author:	      David Atkinson
--               
-- Organisation:  UK ATC
--
-- Description:  tb_rx_protocol_fsm
-- Test bed for rx_protocol_fsm
--
-- Revision history:
-- 
-- <date $Date$>	-		<text>		- <initials $Author$>
-- $log$
-----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
library work;
use work.rx_protocol_fsm_pack.all;


ENTITY tb_rx_protocol_fsm IS
END tb_rx_protocol_fsm ;


library ieee;
use ieee.std_logic_1164.all;
USE ieee.NUMERIC_STD.all;
library work;
use work.rx_protocol_fsm_pack.all;



architecture behav of tb_rx_protocol_fsm is


   signal dut_rst        : std_logic;
   signal tb_clk         : std_logic := '0';
   signal rx_fe          : std_logic;
   signal rxd            : std_logic_vector(7 downto 0);
   signal card_addr      : std_logic_vector(7 downto 0);
   signal cmd_code       : std_logic_vector(15 downto 0);
   signal cmd_data       : std_logic_vector(15 downto 0);
   signal cksum_err      : std_logic;
   signal cmd_rdy        : std_logic;
   signal data_clk       : std_logic;
   signal num_data       : std_logic_vector(7 downto 0);
   signal reg_addr       : std_logic_vector(23 downto 0);
   signal rx_fr          : std_logic;

   constant clk_prd      : TIME := 10 ns;    -- 100Mhz clock
   constant preamble1    : std_logic_vector (7 downto 0)  := X"A5";
   constant preamble2    : std_logic_vector (7 downto 0)  := X"5A";
   constant pre_fail     : std_logic_vector (7 downto 0)  := X"55";
   constant command_wb   : std_logic_vector (31 downto 0) := X"20205742";
   constant command_go   : std_logic_vector (31 downto 0) := X"2020474F";
   constant address      : std_logic_vector (31 downto 0) := X"FFEEDDCC";
   constant data_valid   : std_logic_vector (31 downto 0) := X"00000029";
   constant no_std_data  : std_logic_vector (31 downto 0) := X"00000001";
   constant data_block   : positive := 58;
   constant data_word1   : std_logic_vector (31 downto 0) := X"00001234";
   constant data_word2   : std_logic_vector (31 downto 0) := X"00005678";
   constant check_err    : std_logic_vector (31 downto 0) := X"fafafafa";
 
   signal   data         : integer := 0;
   signal   checksum     : std_logic_vector(31 downto 0):= X"00000000";
   signal   command      : std_logic_vector (31 downto 0);
   
begin

-------------------------------------------------
-- Instantiate DUT
-------------------------------------------------

   DUT :  rx_protocol_fsm
   
   port map ( 
      Brst        => dut_rst,
      clk         => tb_clk,
      rx_fe_i     => rx_fe,
      rxd_i       => rxd,
      card_addr_o => card_addr,
      cmd_code_o  => cmd_code,
      cmd_data_o  => cmd_data,
      cksum_err_o => cksum_err,
      cmd_rdy_o   => cmd_rdy,
      data_clk_o  => data_clk,
      num_data_o  => num_data,
      reg_addr_o  => reg_addr,
      rx_fr_o     => rx_fr
   );
   
------------------------------------------------
-- Create test bench clock
-------------------------------------------------
  
   tb_clk <= not tb_clk after clk_prd/2;

------------------------------------------------
-- Create test bench stimuli
-------------------------------------------------
   
   stimuli : process
  
------------------------------------------------
-- Stimulus procedures
-------------------------------------------------
   
   
   procedure do_reset is
      begin
         dut_rst <= '1';
         wait for clk_prd*5 ;
         dut_rst <= '0';
         wait for clk_prd*5 ;
      
         assert false report " Resetting the DUT." severity NOTE;
      end do_reset;
--------------------------------------------------

   procedure load_preamble is
   begin
      rx_fe       <= '1';
      dut_rst        <= '0';
      wait for clk_prd*5;
      rx_fe       <= '0';          -- FIFO NOT empty
   
      for I in 0 to 3 loop
         wait UNTIL rx_fr <= '1';
         rxd <= preamble1;
         wait UNTIL rx_fr <= '0';
      end loop;   
      
      rx_fe <= '1';
      wait for clk_prd*5;
      rx_fe <= '0';
      
      for I in 0 to 3 loop
         wait UNTIL rx_fr <= '1';
         rxd <= preamble2;
         wait UNTIL rx_fr <= '0';
      end loop;   
      
      rx_fe <= '1';				-- FIFO empty
      
      assert false report "preamble OK" severity NOTE;
   end load_preamble;
   
   --------------------------------------------------
   -- Preamble fail test
   --------------------------------------------------


   procedure load_preamble_test1 is
   begin
      rx_fe       <= '1';

      wait for clk_prd*5;
      rx_fe       <= '0';          -- FIFO NOT empty
   
      wait UNTIL rx_fr <= '1';     --fail on byte0
      rxd         <= pre_fail;
      wait UNTIL rx_fr <= '0';
 
 
            
      wait UNTIL rx_fr <= '1';  
      rxd <= preamble1;
      wait UNTIL rx_fr <= '0';
          
      wait UNTIL rx_fr <= '1';    -- fail on byte1
      rxd <= pre_fail;
      wait UNTIL rx_fr <= '0';    

      for I in 0 to 1 loop
         wait UNTIL rx_fr <= '1';  
         rxd <= preamble1;
         wait UNTIL rx_fr <= '0';
      end loop;    
          
      wait UNTIL rx_fr <= '1';    -- fail on byte2
      rxd <= pre_fail;
      wait UNTIL rx_fr <= '0';    


      for I in 0 to 2 loop
         wait UNTIL rx_fr <= '1';  
         rxd <= preamble1;
         wait UNTIL rx_fr <= '0';
      end loop;    
          
      wait UNTIL rx_fr <= '1';    -- fail on byte3
      rxd <= pre_fail;
      wait UNTIL rx_fr <= '0';    

      for I in 0 to 3 loop
         wait UNTIL rx_fr <= '1';  
         rxd <= preamble1;
         wait UNTIL rx_fr <= '0';
      end loop;    
          
      wait UNTIL rx_fr <= '1';    -- fail on byte4
      rxd <= pre_fail;
      wait UNTIL rx_fr <= '0';    
      
      
      for I in 0 to 3 loop
         wait UNTIL rx_fr <= '1';  
         rxd <= preamble1;
         wait UNTIL rx_fr <= '0';
      end loop;    

      wait UNTIL rx_fr <= '1';  
      rxd <= preamble2;
      wait UNTIL rx_fr <= '0';
 
      wait UNTIL rx_fr <= '1';    -- fail on byte5 
      rxd <= pre_fail;
      wait UNTIL rx_fr <= '0';    



     for I in 0 to 3 loop
         wait UNTIL rx_fr <= '1';  
         rxd <= preamble1;
         wait UNTIL rx_fr <= '0';
      end loop;    

      for I in 0 to 1 loop
         wait UNTIL rx_fr <= '1';  
         rxd <= preamble2;
         wait UNTIL rx_fr <= '0';
      end loop;
      
      wait UNTIL rx_fr <= '1';    -- fail on byte6 
      rxd <= pre_fail;
      wait UNTIL rx_fr <= '0';    

    
     for I in 0 to 3 loop
         wait UNTIL rx_fr <= '1';  
         rxd <= preamble1;
         wait UNTIL rx_fr <= '0';
      end loop;    

      for I in 0 to 2 loop
         wait UNTIL rx_fr <= '1';  
         rxd <= preamble2;
         wait UNTIL rx_fr <= '0';
      end loop;
      
      wait UNTIL rx_fr <= '1';    -- fail on byte7 
      rxd <= pre_fail;
      wait UNTIL rx_fr <= '0';    
      
      
      assert false report "tested preamble fails" severity NOTE;


   end load_preamble_test1;
   
--------------------------------------------------------   
-- test when have to wait for next preamble byte
-- i.e. when FIFO empty
----------------------------------------------------- 

   procedure load_preamble_test2 is
   begin
         
-- test when next byte not yet in FIFO

    rx_fe     <= '0';
      

    wait UNTIL rx_fr <= '0';
    wait UNTIL rx_fr <= '1';  
    rxd <= preamble1;
    rx_fe       <= '1';      -- test when next byte not yet in FIFO
    wait for clk_prd*4;
    rx_fe       <= '0';     
         
    wait UNTIL rx_fr <= '1';  
    rxd <= preamble1;
    rx_fe       <= '1';      -- test when next byte not yet in FIFO
    wait for clk_prd*4;
    rx_fe       <= '0';     
         
    wait UNTIL rx_fr <= '1';  
    rxd <= preamble1;
    rx_fe       <= '1';      -- test when next byte not yet in FIFO
    wait for clk_prd*4;
    rx_fe       <= '0';     
         
    wait UNTIL rx_fr <= '1';  
    rxd <= preamble1;
    rx_fe       <= '1';      -- test when next byte not n FIFO
    wait for clk_prd*4;
    rx_fe       <= '0';           

assert false report "tested preamble1 waits" severity NOTE;
      

     wait UNTIL rx_fr <= '1';  
     rxd <= preamble2;
     rx_fe       <= '1';      -- test when next byte not yet in FIFO
     wait for clk_prd*4;
     rx_fe       <= '0';     
         
     wait UNTIL rx_fr <= '1';  
     rxd <= preamble2;
     rx_fe       <= '1';      -- test when next byte not yet in FIFO
     wait for clk_prd*4;
     rx_fe       <= '0';     

     wait UNTIL rx_fr <= '1';  
     rxd <= preamble2;
     rx_fe       <= '1';      -- test when next byte not yet in FIFO
     wait for clk_prd*4;
     rx_fe       <= '0';     

     wait UNTIL rx_fr <= '1';  
     rxd <= preamble2;
     rx_fe       <= '1';      -- test when next byte not yet in FIFO
     wait for clk_prd*4;
     rx_fe       <= '0';              
                   
    
     assert false report "tested preamble2 waits" severity NOTE;
  


      rx_fe <= '1';				-- FIFO empty
      
     
   end load_preamble_test2;
      
---------------------------------------------------------    
 
   procedure load_command is 
   begin
   
      checksum <= command;
      wait for clk_prd*5;
      rx_fe <= '0';
                  
      wait UNTIL rx_fr <= '1';
      rxd   <= command(7 downto 0);
      wait UNTIL rx_fr <= '0';
      
      wait UNTIL rx_fr <= '1';
      rxd   <= command(15 downto 8);
      wait UNTIL rx_fr <= '0';
      
      wait UNTIL rx_fr <= '1';
      rxd   <= command(23 downto 16);
      wait UNTIL rx_fr <= '0';
      
      wait UNTIL rx_fr <= '1';
      rxd   <= command(31 downto 24);
      wait UNTIL rx_fr <= '0';
      
      rx_fe <= '1';
      assert false report "WB command loaded" severity NOTE;
     
  -- load up address

      checksum <= checksum XOR address;
      wait for clk_prd*5;
      rx_fe <= '0';
      
         
      wait UNTIL rx_fr <= '1';
      rxd <= address(7 downto 0);
      wait UNTIL rx_fr <= '0';
 
      wait UNTIL rx_fr <= '1';
      rxd <= address(15 downto 8);
      wait UNTIL rx_fr <= '0';
     
      wait UNTIL rx_fr <= '1';
      rxd <= address(23 downto 16);
      wait UNTIL rx_fr <= '0';
     
      wait UNTIL rx_fr <= '1';
      rxd <= address(31 downto 24);
      wait UNTIL rx_fr <= '0';
      
      rx_fe <= '1';
      assert false report "WB address loaded" severity NOTE;
 
   -- load up data valid = 41
   
       
       checksum <= checksum XOR data_valid;
       wait for clk_prd*5;
       rx_fe <= '0';      
       
       wait UNTIL rx_fr <= '1';
       rxd <= data_valid(7 downto 0);
       wait UNTIL rx_fr <= '0';
       
       wait UNTIL rx_fr <= '1'; 
       rxd <= data_valid(15 downto 8);
       wait UNTIL rx_fr <= '0';
       
       wait UNTIL rx_fr <= '1';
       rxd <= data_valid(23 downto 16);
       wait UNTIL rx_fr <= '0';
       
       wait UNTIL rx_fr <= '1';
       rxd <= data_valid(31 downto 24);
       wait UNTIL rx_fr <= '0';
       
       rx_fe <= '1';
       
  
  -- load up data block
  
      wait for clk_prd*5;
      rx_fe <= '0';
  
  -- first load valid data
      
      for I in 0 to (To_integer((Unsigned(data_valid)))-1) loop
      
         wait UNTIL rx_fr <= '1';
         rxd <= std_logic_vector(To_unsigned(data,8));
         checksum (7 downto 0) <= checksum (7 downto 0) XOR std_logic_vector(To_unsigned(data,8));
         wait UNTIL rx_fr <= '0';
         
         data <= data + 1;
         
         wait UNTIL rx_fr <= '1';
         rxd <= "00000000";
         wait UNTIL rx_fr <= '0';
           
         wait UNTIL rx_fr <= '1';
         rxd <= "00000000";
         wait UNTIL rx_fr <= '0';
         
         wait UNTIL rx_fr <= '1';      
         rxd <= "00000000";
         wait UNTIL rx_fr <= '0';
         
     end loop;
    
     for J in (To_integer((Unsigned(data_valid)))) to data_block-1 loop
     
         wait UNTIL rx_fr <= '1';
         rxd <= "00000000";
         wait UNTIL rx_fr <= '0';
         
         wait UNTIL rx_fr <= '1';
         rxd <= "00000000";
         wait UNTIL rx_fr <= '0';
           
         wait UNTIL rx_fr <= '1';
         rxd <= "00000000";
         wait UNTIL rx_fr <= '0';
         
         wait UNTIL rx_fr <= '1';      
         rxd <= "00000000";
         wait UNTIL rx_fr <= '0';
         
  
    end loop;

    rx_fe <= '1';
    assert false report "WB data loaded" severity NOTE;

    end load_command;
    
------------------------------------------------------

   procedure load_checksum is
    
      begin
   
      wait for clk_prd*5;
      rx_fe <= '0';
      
      wait UNTIL rx_fr <= '1';
      rxd <= checksum(7 downto 0);
      wait UNTIL rx_fr <= '0';
      
      wait UNTIL rx_fr <= '1';
      rxd <= checksum(15 downto 8);
      wait UNTIL rx_fr <= '0';
      
      wait UNTIL rx_fr <= '1';
      rxd <= checksum(23 downto 16);
      wait UNTIL rx_fr <= '0';
       
      wait UNTIL rx_fr <= '1';
      rxd <= checksum(31 downto 24);
      wait UNTIL rx_fr <= '0';
      
      rx_fe <= '1';     
      
      assert false report "checksum loaded" severity NOTE;  
      
   end load_checksum;
       
 --------------------------------------------------------
 ---- BEGIN TESTBED
 ------------------------------------------------------      
       
   begin
      
      do_reset; 
      load_preamble_test1;
      do_reset;  
      load_preamble_test2;
      do_reset;
      
      
      -- load a valid wb command
      
      command <= command_wb;
      load_preamble;
      load_command;
      load_checksum;
      wait until cmd_rdy <= '1';
      assert false report "command 1 ready" severity NOTE;
      wait until cmd_rdy <= '0';
      assert false report "command 1 finished" severity NOTE;
      
      -- load a wb command with checksum error
      
      command <= command_wb;
      load_preamble;
      load_command;
      checksum <= check_err;
      load_checksum;
      wait until cksum_err <= '1';
      wait until cksum_err <= '0';
      assert false report "command 2 finished with check err detected" severity NOTE;
      
      wait for clk_prd*10;
            
  
      assert false report "Simulation done." severity FAILURE;
      wait ;
   end process stimuli;
    

end behav;