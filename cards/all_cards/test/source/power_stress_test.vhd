-- Copyright (c) 2003 SCUBA-2 Project
--                  All Rights Reserved
--
--  THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF THE SCUBA-2 Project
--  The copyright notice above does not evidence any
--  actual or intended publication of such source code.
--
--  SOURCE CODE IS PROVIDED "AS IS". ALL EXPRESS OR IMPLIED CONDITIONS,
--  REPRESENTATIONS, AND WARRANTIES, INCLUDING ANY IMPLIED WARRANT OF
--  MERCHANTABILITY, SATISFACTORY QUALITY, FITNESS FOR A PARTICULAR
--  PURPOSE, OR NON-INFRINGEMENT, ARE DISCLAIMED, EXCEPT TO THE EXTENT
--  THAT SUCH DISCLAIMERS ARE HELD TO BE LEGALLY INVALID.
--
-- For the purposes of this code the SCUBA-2 Project consists of the
-- following organisations.
--
-- UKATC, Royal Observatory, Blackford Hill Edinburgh EH9 3HJ
-- UBC,   University of British Columbia, Physics & Astronomy Department,
--        Vancouver BC, V6T 1Z1
--
--
-- power_stress_test.vhd
--
-- Project:	      SCUBA-2
-- Author:	       Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Power stress test for FPGAs
--
-- Revision history:
-- 
-- $Log$
--
-----------------------------------------------------------------------------
   
library ieee;
use ieee.std_logic_1164.all;

entity power_stress_test is
generic(NUM_COUNTER : integer range 1 to 256 := 10;
        NUM_OUTPUT  : integer range 1 to 128 := 16);
port(inclk : in std_logic;
     dat_o : out std_logic_vector(NUM_OUTPUT-1 downto 0));
end power_stress_test;

architecture behav of power_stress_test is

component pll
port(inclk0 : in std_logic;
     c0 : out std_logic);
end component;

signal clk : std_logic;

type lfsr_array is array (0 to NUM_COUNTER-1) of std_logic_vector(167 downto 0);
signal lfsr : lfsr_array;

signal out_temp : std_logic_vector(NUM_OUTPUT-1 downto 0);

begin

   clk_gen: pll
   port map(inclk0 => inclk,
            c0 => clk);
            
   lfsr_gen: for i in 0 to NUM_COUNTER-1 generate
      process(clk)
      begin
         if(clk'event and clk = '1') then
            lfsr(i) <= (not(lfsr(i)(0) xor lfsr(i)(2) xor lfsr(i)(15) xor lfsr(i)(17))) & lfsr(i)(167 downto 1);
         end if;
      end process;
   end generate lfsr_gen;
              
   outer_out_gen: for i in 0 to NUM_COUNTER-1 generate
      inner_out_gen: for j in 0 to NUM_OUTPUT-1 generate
         out_temp(j) <= lfsr(i)(j) xor out_temp(j);
      end generate inner_out_gen;
   end generate outer_out_gen;
   
   dat_o <= out_temp(NUM_OUTPUT-1 downto 0);
   
end behav;