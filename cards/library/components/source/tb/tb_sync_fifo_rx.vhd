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
-- <revision control keyword substitutions e.g. $Id: tb_async_fifo.vhd,v 1.4 2004/07/13 00:11:54 erniel Exp $>
--
-- Project:	      SCUBA-2
-- Author:	      David Atkinson
--               
-- Organisation:  UK ATC
--
-- Description: test bed for synchronous FIFO 
-- insantiated by fibre_rx_fifo
-- 
----
-- Revision history:

-- <date $Date: 2004/07/13 00:11:54 $>	-		<text>		- <initials $Author: erniel $>
--
-- $Log: tb_sync_fifo_rx.vhd,v $

library ieee;
use ieee.std_logic_1164.all;

library altera_mf;
use altera_mf.altera_mf_components.all;

entity tb_sync_fifo_rx is
end tb_sync_fifo_rx;



library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library altera_mf;
use altera_mf.altera_mf_components.all;

library components;
use components.component_pack.all;


architecture bench of tb_sync_fifo_rx is


constant FIFO_DEEP           : positive := 256 ;    -- number of bytes in FIFO
	
	

constant global_clk_prd    : TIME := 20 ns;    -- 50Mhz clock
constant hot_clkr_prd      : TIME := 40 ns;    -- 25Mhz clock
constant rdy_dly           : TIME := hot_clkr_prd * 0.05;   -- delay between clkr and nRdy.

constant addr_size    : positive := 4;

signal fifo_size      : positive := FIFO_DEEP;

signal dut_rst   : std_logic  := '0';

signal read      : std_logic := '0';
signal write     : std_logic;

signal data_in   : std_logic_vector(7 downto 0);
signal empty     : std_logic;
signal full      : std_logic;
signal data_out  : std_logic_vector(7 downto 0);

signal global_clk : std_logic  := '1';
signal hot_clkr    : std_logic  := '1';
signal nRdy       : std_logic := '1';

 
signal test_data    : integer := 0;


component sync_fifo_rx 
port (
   data		: in STD_LOGIC_VECTOR (7 DOWNTO 0);
   wrreq		: in STD_LOGIC ;
   rdreq		: in STD_LOGIC ;
   rdclk		: in STD_LOGIC ;
   wrclk		: in STD_LOGIC ;
   aclr		: in STD_LOGIC  := '0';
   q		: out STD_LOGIC_VECTOR (7 DOWNTO 0);
   rdempty		: out STD_LOGIC ;
   wrfull		: out STD_LOGIC 
);
end component;




begin

  write <= not (nRdy);
  


 
  -- Instantiate Device under test.
   DUT : sync_fifo_rx
     
      port map (
         data		        => data_in,
	 wrreq		=> write,
	 rdreq	        => read,
	 rdclk		=> global_clk,
	 wrclk		=> hot_clkr,
	 aclr		=> dut_rst,
	 q		=> data_out,
	 rdempty		=> empty,
	 wrfull         => full
         );



------------------------------------------------
-- Create clocks
-------------------------------------------------
  
  
   global_clk <= not global_clk after global_clk_prd/2;
   hot_clkr   <= not hot_clkr   after hot_clkr_prd/2;
   
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
         wait for global_clk_prd*2;
         dut_rst <= '1';
         wait for global_clk_prd*2;
         dut_rst <= '0';
         wait for global_clk_prd*2;
      
         assert false report " Resetting the DUT." severity NOTE;
      end do_reset;  
  
  
 --------------------------------------------------------------- 
   procedure do_fill_fifo is 
      begin
      
      wait for rdy_dly; 
      
      for I in 0 to fifo_size-1 loop
       
         -- clk cycle starts high --    
         
         data_in <= std_logic_vector(To_unsigned(test_data,8));
         nRdy <= '1';
         
         wait for hot_clkr_prd * 0.4 ;   -- 40% high 60% low duty cycle
         
         nRdy <= '0';
                  
         test_data <= test_data +1;   -- inc for next time
         wait for hot_clkr_prd * 0.6 ;
         
         nRdy <= '1';
         

         
      end loop;    
   
  
      assert false report " FIFO full..." severity NOTE;
   end do_fill_fifo;
-------------------------------------------------------------------- 

  
  procedure do_empty_fifo is 
      begin
      
     
      for I in 0 to fifo_size-1 loop
      
         read <= '0';
         wait for global_clk_prd;   -- one state time in fsm of fibre_rx_protocol
         read <= '1';
         wait for global_clk_prd;  -- one state time in fsm of fibre_rx_protocol
         
      end loop;    
   
      read <= '0';
  
      assert false report " FIFO empty..." severity NOTE;
   end do_empty_fifo;
  
  
--------------------------------------------------------------- 
   procedure do_half_fill_fifo is 
      begin
      
      wait for rdy_dly; 
      
      for I in 0 to (fifo_size/2)-1 loop
       
         -- clk cycle starts high --    
         
         data_in <= std_logic_vector(To_unsigned(test_data,8));
         nRdy <= '1';
         
         wait for hot_clkr_prd * 0.4 ;   -- 40% high 60% low duty cycle
         
         nRdy <= '0';
                  
         test_data <= test_data +1;   -- inc for next time
         wait for hot_clkr_prd * 0.6 ;
         
         nRdy <= '1';
         

         
      end loop;    
   
  
      assert false report " FIFO half full..." severity NOTE;
   end do_half_fill_fifo;
   
  
 --------------------------------------------------
  
  procedure do_half_empty_fifo is 
      begin
      
     
      for I in 0 to (fifo_size/2)-1 loop
      
         read <= '0';
         wait for global_clk_prd;   -- one state time in fsm of fibre_rx_protocol
         read <= '1';
         wait for global_clk_prd;  -- one state time in fsm of fibre_rx_protocol
         
      end loop;    
   
      read <= '0';
  
      assert false report " FIFO empty..." severity NOTE;
   end do_half_empty_fifo;
  
  
---------------------------------------------------------------   
 
    
--------------------------------------------------------
 ---- BEGIN TESTBED
 ------------------------------------------------------      
       
   begin
 
   do_reset;
   assert false report "fifo reset... " severity NOTE;
   
   do_fill_fifo;
   assert false report "fifo should now be full... " severity NOTE;

  -- get back in sync with clock
  
   wait until global_clk <= '0'; 
   
   do_empty_fifo;
   assert false report "fifo should now be empty ... " severity NOTE;
 
   wait until global_clk <= '0'; 
   
   do_half_fill_fifo;
   --do_read_n_write;
   --do_read_n_write;
   do_half_empty_fifo;
   
   wait for global_clk_prd * 20;
      
   assert false report " End of simulation......fifo should be empty" severity FAILURE;
   wait;     
   end process stimuli;
   
end bench;
	


