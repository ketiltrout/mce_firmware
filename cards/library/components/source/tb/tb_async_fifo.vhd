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
-- <revision control keyword substitutions e.g. $Id: tb_async_fifo.vhd,v 1.3 2004/06/30 10:53:48 dca Exp $>
--
-- Project:	      SCUBA-2
-- Author:	      David Atkinson
--               
-- Organisation:  UK ATC
--
-- Description: test bed for asynchronous FIFO
-- instantiated by blocks rx_fifo and tx_fifo
--
--
-- Revision history:

-- <date $Date: 2004/06/30 10:53:48 $>	-		<text>		- <initials $Author: dca $>
--
-- <$log$>
-----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity tb_async_fifo is
end tb_async_fifo;
 
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
 
library components;
use components.component_pack.all;



architecture bench of tb_async_fifo is

constant clk_prd      : TIME := 20 ns;    -- 50Mhz clock
constant addr_size    : positive := 4;

signal fifo_size      : positive;

signal dut_rst   : std_logic;
signal read      : std_logic;
signal write     : std_logic;
signal data_in   : std_logic_vector(7 downto 0);
signal empty     : std_logic;
signal full      : std_logic;
signal data_out  : std_logic_vector(7 downto 0);

signal tb_clk    : std_logic; 
signal test_data    : integer := 0;

begin

 
  -- Instantiate Device under test.
   DUT : async_fifo
      generic map (
         addr_size => addr_size
      )
      port map (
         rst_i       => dut_rst,
         read_i      => read,
         write_i     => write,
         d_i         => data_in,
         empty_o     => empty,
         full_o      => full,
         q_o         => data_out
      );
  
-- determine size of FIFO from address size (addr_size)   
   fifo_size <= 2**addr_size;   


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
         dut_rst <= '0';
         wait for clk_prd*2;
         dut_rst <= '1';
         wait for clk_prd*2;
         dut_rst <= '0';
         wait for clk_prd*2;
      
         assert false report " Resetting the DUT." severity NOTE;
      end do_reset;  
  
  
 --------------------------------------------------------------- 
   procedure do_fill_fifo is 
      begin
      for I in 0 to fifo_size-1 loop
      
         data_in <= std_logic_vector(To_unsigned(test_data,8));
         write <= '0';
         wait for 10 ns;
         write <= '1';
         test_data <= test_data +1;
         wait for 10 ns;
         
      end loop;    
         write <= '0';
  
      assert false report " FIFO full..." severity NOTE;
   end do_fill_fifo;
--------------------------------------------------------------------   

--------------------------------------------------------------- 
   procedure do_half_fill_fifo is 
      begin
      for I in 0 to ((fifo_size/2)-1) loop
      
         data_in <= std_logic_vector(To_unsigned(test_data,8));
         write <= '0';
         wait for 10 ns;
         write <= '1';
         test_data <= test_data +1;
         wait for 10 ns;
         
      end loop;    
         write <= '0';
  
      assert false report " half fill FIFO..." severity NOTE;
   end do_half_fill_fifo;
--------------------------------------------------------------------   
  
   procedure do_empty_fifo is 
      begin
      for I in 0 to fifo_size-1 loop
      
         read <= '0';
         wait for 10 ns;
         read <= '1';
         wait for 10 ns;
         
      end loop;    
         read <= '0';
  
      assert false report " FIFO empty..." severity NOTE;
   end do_empty_fifo;
  
  
--------------------------------------------------------

 procedure do_half_empty_fifo is 
      begin
      for I in 0 to ((fifo_size/2)-1) loop
      
         read <= '0';
         wait for 10 ns;
         read <= '1';
         wait for 10 ns;
         
      end loop;    
         read <= '0';
  
      assert false report " read half FIFO..." severity NOTE;
   end do_half_empty_fifo;
  
  --------------------------------------------------------

 procedure do_read_n_write is 
      begin
      
         data_in <= std_logic_vector(To_unsigned(test_data,8));
         write <= '0'  ; 
         read <= '0';
         wait for 10 ns;
         read <= '1';
         write <= '1';
         test_data <= test_data + 1;
         wait for 10 ns;
         
        
         read <= '0';
         write <= '0';
             
      assert false report " read and wrote fifo together..." severity NOTE;
   end do_read_n_write;
  
  
  
--------------------------------------------------------
 ---- BEGIN TESTBED
 ------------------------------------------------------      
       
   begin
   
   read <= '0';
   write <= '0';
   
   do_reset;
   assert false report "fifo reset... " severity NOTE;
   
   do_fill_fifo;
   assert false report "fifo should now be full... " severity NOTE;
   
   do_empty_fifo;
   assert false report "fifo should now be empty ... " severity NOTE;
   
   do_half_fill_fifo;
   do_read_n_write;
   do_read_n_write;
   do_half_empty_fifo;
   
      
   assert false report " End of simulation......fifo should be empty" severity FAILURE;
   wait;     
   end process stimuli;
   
end bench;
