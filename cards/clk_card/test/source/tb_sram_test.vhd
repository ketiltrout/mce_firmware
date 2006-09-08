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

-- tb_sram_test.vhd
--

-- Project:	      SCUBA-2
-- Author:	      Mandana Amiri
-- Organisation:  UBC
--
-- Description:
-- testbench for the bc_sram_test, very simple: assert enable and wait for done!
--
-- Revision history:
-- <date $Date$>	- <initials $Author$>
-- $Log$
--  
-----------------------------------------------------------------------------
library IEEE, sys_param, components;
use IEEE.std_logic_1164.all;
use components.component_pack.all;
use sys_param.data_types_pack.all;

library work;
use work.cc_test_pack.all;

entity tb_sram_test is
end tb_sram_test;

architecture beh of tb_sram_test is

   constant PERIOD : time := 20 ns;

   signal rst : std_logic;
   signal clk : std_logic := '0';
   signal ena : std_logic;
   signal done: std_logic;
   signal nbhe, nble,noe,ncs,cs,nwe,pass,fail: std_logic;
   signal addr: std_logic_vector (19 downto 0);
   signal data: std_logic_vector (15 downto 0);
   
   
begin

   DUT :  sram_test
      port map(
         rst_i    => rst,
         clk_i    => clk,
         en_i     => ena,
         done_o   => done,
          
         -- physical pins
         addr_o   => addr,
         data_bi  => data,
         n_ble_o  => nbhe,
         n_bhe_o  => nble,
         n_oe_o   => noe, 
         n_ce1_o  => ncs, 
         ce2_o    => cs, 
         n_we_o   => nwe,
         pass_o   => pass,
         fail_o   => fail
      );
   clk <= not clk after PERIOD/2;

   STIMULI : process
   begin
      ena       <= '0';
      rst       <= '0';
      wait for PERIOD;
      ena       <= '1';
      wait for PERIOD;
      rst       <= '0';     

      -- enable module
      ena       <= '1';     
      wait for PERIOD*10;
--      data   <= (others => '0');
      wait until done = '1';
      ena       <= '0';
      wait for PERIOD*500;
      
      -- enable module
      ena       <= '1';
      wait until done = '1';
      ena       <= '0';
      wait for PERIOD*500;
      
      --enable module
      ena       <= '1';     
      wait until done = '1';
      ena        <= '0';
      wait for PERIOD*500;
      assert FALSE report "Simulation done." severity failure;    

   end process STIMULI;

end BEH;

configuration cfg_tb_sram_test of tb_sram_test is
   for BEH
   end for;
end cfg_tb_sram_test;