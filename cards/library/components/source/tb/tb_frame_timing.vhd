-- tb_frame_timing.vhd
--
-- <revision control keyword substitutions e.g. $Id: tb_frame_timing.vhd,v 1.3 2004/04/16 21:58:13 bburger Exp $>
--
-- Project:    SCUBA2
-- Author:     Bryce Burger
-- Organisation:  UBC Physics and Astronomy
--
-- Description:
-- This code implements the testbench for the Array ID
--
-- Revision history:
-- <date $Date: 2004/04/16 21:58:13 $> -     <text>      - <initials $Author: bburger $>
--
------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

library sys_param;
use sys_param.frame_timing_pack.all;
use sys_param.general_pack.all;

entity TB_FRAME_TIMING is
end TB_FRAME_TIMING;

architecture BEH of TB_FRAME_TIMING is

--   signal tb_clk_o : std_logic;
   signal sync_i          : std_logic;
   signal frame_rst_i     : std_logic;
   signal clk_count_o     : integer;
   signal clk_error_o     : std_logic_vector(31 downto 0);
   signal clk_i           : std_logic := '1';

------------------------------------------------------------------------
--
-- Instantiate the design
--
------------------------------------------------------------------------

begin

   DUT : frame_timing
      port map(
         clk_i => clk_i,
         sync_i => sync_i,
         frame_rst_i => frame_rst_i,
         clk_count_o => clk_count_o,
         clk_error_o => clk_error_o
      );

   -- Create a test clock
   clk_i <= not clk_i after CLOCK_PERIOD/2;

   -- Create stimulus
   STIMULI : process

   -- Procdures for creating stimulus

   procedure do_init is
   begin
      sync_i <= '0';
      frame_rst_i <= '0';
      assert false report " init" severity NOTE;
   end do_init;

   procedure do_nop is
   begin
      wait for CLOCK_PERIOD;
      assert false report " nop" severity NOTE;
   end do_nop;

   procedure do_reset is
   begin
      frame_rst_i <= '1';
      wait for CLOCK_PERIOD;
      assert false report " reset" severity NOTE;
   end do_reset;

   procedure do_sync is
   begin
      sync_i <= '1';
      wait for CLOCK_PERIOD;
      assert false report " sync" severity NOTE;
   end do_sync;

   -- Start the test
   begin

      do_nop;
      do_nop;
      do_sync;
      do_init;
      do_nop;
      do_nop;
      do_nop;
      do_nop;
      do_nop;

      do_nop;
      do_nop;
      do_sync;
      do_init;
      do_reset;
      do_init;
      do_nop;
      do_nop;
      do_nop;
      do_nop;

      do_nop;
      do_nop;
      do_sync;
      do_init;
      do_nop;
      do_nop;
      do_nop;
      do_nop;
      do_nop;

      do_nop;
      do_nop;
      do_sync;
      do_init;
      do_nop;
      do_nop;
      do_nop;
      do_nop;
      do_nop;

      do_nop;
      do_nop;
      do_sync;
      do_init;
      do_nop;
      do_nop;
      do_nop;
      do_nop;
      do_nop;

      do_nop;
      do_nop;
      do_sync;
      do_init;
      do_nop;
      do_nop;
      do_nop;
      do_nop;
      do_nop;

      assert false report " Simulation done." severity FAILURE;
   end process STIMULI;
end BEH;

------------------------------------------------------------------------
--
-- Configuration
--
------------------------------------------------------------------------

configuration TB_FRAME_TIMING_CONF of TB_FRAME_TIMING is
   for BEH
   end for;
end TB_FRAME_TIMING_CONF;