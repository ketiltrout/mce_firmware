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
-- <revision control keyword substitutions e.g. $Id: tb_simple_reply_fsm.vhd,v 1.1 2004/06/15 15:50:21 dca Exp $>
--
-- Project:	      SCUBA-2
-- Author:	      David Atkinson
--               
-- Organisation:  UK ATC
--
-- Description:  test_simple_reply_fsm
--
-- simple_reply_fsm test bed
--
--
-- Revision history:
-- 
-- <date $Date: 2004/06/15 15:50:21 $>	-		<text>		- <initials $Author: dca $>
-- $log$
-----------------------------------------------------------------------------

entity tb_simple_reply_fsm is
end tb_simple_reply_fsm ;


library ieee;
use ieee.std_logic_1164.all;

library work;
use work.simple_reply_fsm_pack.all;


architecture bench of tb_simple_reply_fsm is

 
constant clk_prd      : TIME := 20 ns;    -- 50Mhz clock
constant fifo_size    : positive := 16;

signal dut_rst   : std_logic;
signal tb_clk    : std_logic := '0'; 

signal txd         : std_logic_vector (7 downto 0);
signal tx_fw       : std_logic;
signal cmd_code    : std_logic_vector (15 downto 0);
signal cksum_err   : std_logic;
signal cmd_rdy     : std_logic;
signal tx_ff       : std_logic;         

begin

   -- Instantiate device under test
   DUT: simple_reply_fsm
      PORT MAP (
         rst_i       => dut_rst,
         clk_i       => tb_clk,
         cmd_code_i  => cmd_code,
         cksum_err_i => cksum_err,
         cmd_rdy_i   => cmd_rdy,
         tx_ff_i     => tx_ff,
         txd_o       => txd,
         tx_fw_o     => tx_fw
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
         cksum_err <= '0';
         cmd_rdy   <= '0';
         tx_ff     <= '0';
         cmd_code  <= X"FFFF";
         
         dut_rst   <= '0';
         wait for clk_prd*2;
         dut_rst   <= '1';
         wait for clk_prd*2;
         dut_rst   <= '0';
         wait for clk_prd*2;
      
         assert false report " Resetting the DUT." severity NOTE;
      end do_reset;  
  
  
 --------------------------------------------------------------- 
   procedure do_ok_rep is 
   begin
      cmd_rdy   <= '0';
      wait for clk_prd;
      cmd_rdy   <= '1';
      wait for clk_prd;
      cmd_rdy   <= '0';
      wait for clk_prd;
      assert false report " cmd_rdy asserted....." severity NOTE;
   end do_ok_rep;
-------------------------------------------------------------------- 
 
   procedure do_er_rep is 
   begin
      cksum_err   <= '0';
      wait for clk_prd;
      cksum_err   <= '1';
      wait for clk_prd;
      cksum_err   <= '0';
      wait for clk_prd;
      assert false report " cksum_err asserted....." severity NOTE;
   end do_er_rep;
-------------------------------------------------------------------- 

   begin -- stimulus process
  
      do_reset;
      
      cmd_code    <= x"5752";
      do_ok_rep;
      wait until txd <= x"A5";
      assert false report " got byte a5..." severity NOTE;
      wait until txd <= x"5A";
      assert false report " got byte 5a..." severity NOTE;
      wait until txd <= x"4B";
      wait until txd <= x"4F";
      assert false report " got OK ......" severity NOTE;
      
      
      wait for clk_prd*40;
      
      do_reset;
            
      cmd_code <= x"5752";
      do_er_rep;
      wait until txd <= x"A5";
      tx_ff <= '1';     -- test full fifo condition
      wait for clk_prd*2;
      tx_ff <= '0';
      wait until txd <= x"5A";
      wait until txd <= x"20";
      wait until txd <= x"52";
      wait until txd <= x"45";
      assert false report " got ER ........" severity NOTE;

      wait for clk_prd*40;
      assert false report " simulation finished....." severity FAILURE;
      wait;
      
   end process stimuli;
end bench;
