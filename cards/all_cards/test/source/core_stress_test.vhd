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
-- core_stress_test.vhd
--
-- Project:	      SCUBA-2
-- Author:	       Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Power stress test for FPGA core
--
-- Revision history:
-- 
-- $Log$
--
-----------------------------------------------------------------------------
   
library ieee;
use ieee.std_logic_1164.all;

entity core_stress_test is
generic(NUM_COUNTER : integer range 3 to 512 := 475;
        NUM_OUTPUT  : integer range 1 to 32  := 16);
port(inclk  : in std_logic;
     outclk : out std_logic;

-- use either data or data2 (depending on which card you're compiling for)
-- use data  for AC, BC, CC
-- use data2 for RC

--     data   : out std_logic_vector(NUM_OUTPUT-1 downto 0));
     data2  : out std_logic_vector(NUM_OUTPUT-1 downto 0));
end core_stress_test;

architecture behav of core_stress_test is

component pll
port(inclk0 : in std_logic;
     c0 : out std_logic;
     e3 : out std_logic);
end component;

component lfsr
generic(WIDTH : in integer range 3 to 64 := 8);
port(clk    : in std_logic;
     rst    : in std_logic;
     ena    : in std_logic;
     load   : in std_logic;
     clr    : in std_logic;
     lfsr_i : in std_logic_vector(WIDTH-1 downto 0);
     lfsr_o : out std_logic_vector(WIDTH-1 downto 0));
end component;

signal clk  : std_logic;
signal rst  : std_logic;
signal ena  : std_logic;
signal load : std_logic;
signal clr  : std_logic;

type lfsr_array is array (0 to NUM_COUNTER-1) of std_logic_vector(63 downto 0);
signal lfsr_in  : lfsr_array;
signal lfsr_out : lfsr_array;

begin

   rst  <= '0';
   ena  <= '1';
   load <= '0';
   clr  <= '0';

   clk_gen: pll
      port map(inclk0 => inclk,
               c0 => clk,
               e3 => outclk);

   lfsr_gen: for i in 0 to NUM_COUNTER-1 generate
      lfsr0: if i = 0 generate
        lfsr_0 : lfsr
           generic map(WIDTH => 64)
           port map(clk => clk,
                    rst => rst,
                    ena => ena,
                    load => load,
                    clr => clr,
                    lfsr_i => lfsr_in(i),
                    lfsr_o => lfsr_out(i));
      end generate lfsr0;
      
      block1: if i > 0 and i <= 63 generate
        block_1 : lfsr
           generic map(WIDTH => 64)
           port map(clk => clk,
                    rst => rst,
                    ena => ena,
                    load => lfsr_out(i-1)(64-i),
                    clr => clr,
                    lfsr_i => lfsr_in(i),
                    lfsr_o => lfsr_out(i));
      end generate block1;

      block2: if i > 63 and i <= 127 generate
        block_2 : lfsr
           generic map(WIDTH => 64)
           port map(clk => clk,
                    rst => rst,
                    ena => lfsr_out(i-1)(i-64),
                    load => load,
                    clr => clr,
                    lfsr_i => lfsr_in(i),
                    lfsr_o => lfsr_out(i));
      end generate block2;

      block3: if i > 127 and i <= 191 generate
        block_3 : lfsr
           generic map(WIDTH => 64)
           port map(clk => clk,
                    rst => rst,
                    ena => lfsr_out(i-1)(15),
                    load => load,
                    clr => clr,
                    lfsr_i => lfsr_in(i),
                    lfsr_o => lfsr_out(i));
      end generate block3;

      block4: if i > 191 and i <= 255 generate
        block_4 : lfsr
           generic map(WIDTH => 64)
           port map(clk => clk,
                    rst => rst,
                    ena => ena,
                    load => lfsr_out(i-1)(31),
                    clr => clr,
                    lfsr_i => lfsr_in(i),
                    lfsr_o => lfsr_out(i));
      end generate block4;

      block5: if i > 255 and i <= 319 generate
        block_5 : lfsr
           generic map(WIDTH => 64)
           port map(clk => clk,
                    rst => rst,
                    ena => ena,
                    load => lfsr_out(i-1)(47),
                    clr => clr,
                    lfsr_i => lfsr_in(i),
                    lfsr_o => lfsr_out(i));
      end generate block5;

      block6: if i > 319 and i <= 383 generate
        block_6 : lfsr
           generic map(WIDTH => 64)
           port map(clk => clk,
                    rst => rst,
                    ena => lfsr_out(i-1)(63),
                    load => load,
                    clr => clr,
                    lfsr_i => lfsr_in(i),
                    lfsr_o => lfsr_out(i));
      end generate block6;

      block7: if i > 383 and i <= 447 generate
        block_7 : lfsr
           generic map(WIDTH => 64)
           port map(clk => clk,
                    rst => rst,
                    ena => ena,
                    load => lfsr_out(i-1)(447-i),
                    clr => clr,
                    lfsr_i => lfsr_in(i),
                    lfsr_o => lfsr_out(i));
      end generate block7;

      block8: if i > 447 and i <= 511 generate
        block_8 : lfsr
           generic map(WIDTH => 64)
           port map(clk => clk,
                    rst => rst,
                    ena => lfsr_out(i-1)(i-448),
                    load => load,
                    clr => clr,
                    lfsr_i => lfsr_in(i),
                    lfsr_o => lfsr_out(i));
      end generate block8;
   end generate lfsr_gen;
              
              
   input_gen: for i in 0 to NUM_COUNTER-1 generate
      first_input: if i = 0 generate
         lfsr_in(i) <= (others => '0');
      end generate first_input;
      
      second_input: if i = 1 generate
         lfsr_in(i) <= not(lfsr_out(0)(63 downto 1) xor lfsr_out(NUM_COUNTER-1)(63 downto 1)) & '0';
      end generate second_input;
      
      other_input: if i > 1 generate
         lfsr_in(i) <= not(lfsr_out(i-1)(63 downto 1) xor lfsr_out(i-2)(63 downto 1)) & '0';
      end generate other_input;
   end generate input_gen;
   
   
   output_gen: for i in 0 to NUM_OUTPUT-1 generate
--      data(i) <= lfsr_out(NUM_COUNTER-1)(63-i);
      data2(i) <= lfsr_out(NUM_COUNTER-1)(63-i);
   end generate output_gen;
   
end behav;