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
-- tb_sa_bias_clk_domain_crosser.vhd
--
-- Project:	  SCUBA-2
-- Author:        Anthony Ko
-- Organisation:  UBC
--
-- Description:
-- Testbench for the sa bias clock domain crosser
--
-- This bench investigates the behaviour of the clock domain crosser inside
-- the sa_bias_ctrl block.  To clearly see separate output pulses, the fast input 
-- should only be active for one fast clock period every FAST_TO_SLOW_RATIO*2
-- clock period.  Anything closer than this would blend the slow output pulses
-- together
--
-- Revision history:
-- 
-- $Log$
--
--

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.sa_bias_ctrl_pack.all;


entity tb_sa_bias_clk_domain_crosser is

end tb_sa_bias_clk_domain_crosser;


library ieee;
use ieee.std_logic_1164.all;

library work;
use work.sa_bias_ctrl_pack.all;


architecture test of tb_sa_bias_clk_domain_crosser is

   
   -- testbench constant and signal declarations

   constant CLK_FAST_PERIOD              : time      := 20 ns;       -- 50 MHz clock period (system clock)
   constant CLK_SLOW_PERIOD              : time      := 40 ns;       -- 25 MHz clock period (maximum spi clock)
   
   constant FAST_TO_SLOW_RATIO           : integer   := CLK_SLOW_PERIOD/CLK_FAST_PERIOD;   
                                                                     -- Add 1 to the quotient if not divisible
                                                                     -- (eg 2.2 -> 3, 2.5 -> 3, etc.)

   shared variable endsim                : boolean   := false;       -- simulation window

   signal   clk_fast                     : std_logic := '0';         -- fast clock input
   signal   clk_slow                     : std_logic := '0';         -- slow clock input 
   signal   input_fast                   : std_logic := '0';         -- fast signal input
   signal   output_slow                  : std_logic;                -- slow signal output
   signal   rst                          : std_logic := '0';         -- global reset


begin

   -- Bring out of reset after 10 slow clock period
   
   rst <= '1', '0' after 10*CLK_SLOW_PERIOD;

  
   -- Generate both the fast and slow clocks (ie 20 ns and 40 ns period)

   clk_fast_gen : process
   begin
      if not (endsim) then
         clk_fast <= not clk_fast;
         wait for CLK_FAST_PERIOD/2;
      end if;
   end process clk_fast_gen;
   
   clk_slow_gen : process
   begin
      if not (endsim) then
         clk_slow <= not clk_slow;
         wait for CLK_SLOW_PERIOD/2;
      end if;
   end process clk_slow_gen;
   
  
   -- Generate the fast input stimulus (a one clk_fast_period pulse)
   
   stimulus : process
   begin
      wait until clk_fast ='1';
      input_fast <= '1';
      wait for 1.1*clk_fast_period;
      input_fast <= '0';
      wait for 2*clk_fast_period;
   end process stimulus;
   
   
   -- End the simulation after 50 slow clock period

   sim_time : process
   begin
      wait for 50*CLK_SLOW_PERIOD;
      endsim := true;
      report "Simulation Finished....."
      severity FAILURE;
   end process sim_time;

   
   -- Instantiate the Unit Under Test

   UUT : sa_bias_clk_domain_crosser
      generic map (
         NUM_TIMES_FASTER => FAST_TO_SLOW_RATIO
      )
      port map (
         rst_i            => rst,
         clk_slow         => clk_slow,
         clk_fast         => clk_fast,
         input_fast       => input_fast,
         output_slow      => output_slow
      );
      
         
end test;
