-- Copyright (c) 2003 SCUBA-2 Project
-- All Rights Reserved
--
-- THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF THE SCUBA-2 Project
-- The copyright notice above does not evidence any
-- actual or intended publication of such source code.
--
-- SOURCE CODE IS PROVIDED "AS IS". ALL EXPRESS OR IMPLIED CONDITIONS,
-- REPRESENTATIONS, AND WARRANTIES, INCLUDING ANY IMPLIED WARRANT OF
-- MERCHANTABILITY, SATISFACTORY QUALITY, FITNESS FOR A PARTICULAR
-- PURPOSE, OR NON-INFRINGEMENT, ARE DISCLAIMED, EXCEPT TO THE EXTENT
-- THAT SUCH DISCLAIMERS ARE HELD TO BE LEGALLY INVALID.
--
-- For the purposes of this code the SCUBA-2 Project consists of the
-- following organisations.
--
-- UKATC, Royal Observatory, Blackford Hill Edinburgh EH9 3HJ
-- UBC, University of British Columbia, Physics & Astronomy Department,
-- Vancouver BC, V6T 1Z1
--
-- tx_reply_wrapper
--
--
-- Project: 			Scuba 2
-- Author:  			David Atkinson
-- Organisation: 			UKATC
--
-- Description:
-- Test wrapper used with NIOS board to test generating
-- a command packet.
--
-- Revision history:
-- <date $Date: 2004/10/08 14:10:40 $> - <text> - <initials $Author: dca $>
--
-- $Log: tb_fibre_rx_wrapper.vhd,v $

--
-- 
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.issue_reply_pack.all;

library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;

entity tb_fibre_rx_wrapper is
end tb_fibre_rx_wrapper;


library ieee;
use ieee.std_logic_1164.all;

library work;
use work.issue_reply_pack.all;

library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;


architecture bench of tb_fibre_rx_wrapper is


component fibre_rx_wrapper 

port(
     -- global inputs 
     rst_i                   : in  std_logic;                                            -- global reset
     clk_i                   : in  std_logic;                                            -- global clock

     -- two input signals (to generate monostable pulse) used to stimulate command packet generation    
     stim1_i                 : in  std_logic;  
     stim2_i                 : in  std_logic 
 
     );      

end component;


 
constant clk_prd        : time := 20 ns;  -- 50 MHz clock
 
-- internal signal declarations

signal dut_rst               : std_logic := '0' ;
signal dut_clk               : std_logic := '1' ;

signal stim1                 : std_logic := '0' ;
signal stim2                 : std_logic := '0' ; 

begin

   i_fibre_rx_wrapper : fibre_rx_wrapper 
   port map(
      rst_i                   => dut_rst,                 
      clk_i                   => dut_clk,
   
      stim1_i                 => stim1,  
      stim2_i                 => stim2

     );      


 -----------------------------------------------
-- Create test bench clock
-------------------------------------------------
  
   dut_clk <= not dut_clk after clk_prd/2;

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
      assert false report " Resetting the DUT." severity NOTE;
      wait for clk_prd*4 ;
      dut_rst <= '0';
      wait for clk_prd*4 ;
   end do_reset;
      
      
   procedure do_generate_packet is
   begin 
     stim1 <= '1';
     stim2 <= '0';
     wait for clk_prd*2;
     stim1 <= '0';
     stim2 <= '0';
     wait for clk_prd*2;
     stim1 <= '0';
     stim2 <= '1';
     wait for clk_prd*1;
     assert false report " Pulse to generate packet created" severity NOTE;
     wait for clk_prd*1;
     stim1 <= '0';
     stim2 <= '0';
     wait for clk_prd*2;
   end do_generate_packet;

     
   
--------------------------------------------------
  begin
           
     wait for clk_prd * 4;           
     do_reset;
     do_generate_packet;
    
     assert false report "packet generation started.....?" severity NOTE;
         
     
     wait;
     
  end process stimuli;
  
  
end bench;