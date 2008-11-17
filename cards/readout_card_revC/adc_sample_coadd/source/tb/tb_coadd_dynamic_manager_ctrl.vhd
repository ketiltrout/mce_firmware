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
-- tb_coadd_dynamic_manager_ctrl.vhd
--
-- Project:	  SCUBA-2
-- Author:        Mohsen Nahvi
-- Organisation:  UBC
--
-- Description:
-- 
-- In this testbench file for the coadd_dynamic_manager_ctrl block, we do the
-- fllowings:
--
-- 1. Initialize and free run restart_frame_1row_prev_i and
-- restart_frame_aligned_i at their nominal frequency of (64*41*period)
-- 2. For two frame times, adc_coadd_en_i, adc_coadd_en_4delay_i, and
-- adc_coadd_en_5delay_i are asserted such that the finishing time of
-- adc_coadd_en_4delay_i is within a row dwell time.
-- 3. Same as case 2, but falling edge of adc_coadd_en_5delay_i is on row time
-- border. ################### TO BE IMPLEMENTED#####################
-- 4. same as case 2, but falling edge of adc_coadd_en_4delay_i is on row time.
-- ############### Case 4 to be implemented ######################
-- 5. For two frame time, adc_coadd_en_4delay_i and adc_coadd_en_5delay_i are
-- asserted such that both have their falling time in the next row time.
-- 6. We repeat case 2 above to check the consistency of going from one case to
-- the other case. 
-- 
--
-- Revision history:
-- 
-- $Log: tb_coadd_dynamic_manager_ctrl.vhd,v $
-- Revision 1.2  2004/10/29 02:03:56  mohsen
-- Sorted out library use and use parameters
--
-- Revision 1.1  2004/10/22 00:16:16  mohsen
-- Created
--
--
------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;


library work;
use work.adc_sample_coadd_pack.all;


entity tb_coadd_dynamic_manager_ctrl is

  generic (
    COADD_DONE_MAX_COUNT : integer := 7;
    MAX_SHIFT            : integer := 5);
  
end tb_coadd_dynamic_manager_ctrl;




architecture beh of tb_coadd_dynamic_manager_ctrl is


  component coadd_dynamic_manager_ctrl
    
    generic (
      COADD_DONE_MAX_COUNT : integer := 7;  -- = max delay+1 for coadd_done 
      MAX_SHIFT            : integer := ADC_LATENCY+1); 
 
    port (
      rst_i                     : in  std_logic;
      clk_i                     : in  std_logic;
      restart_frame_1row_prev_i : in  std_logic;
      restart_frame_aligned_i   : in  std_logic;
      row_switch_i              : in  std_logic;
      adc_coadd_en_i            : in  std_logic;
      adc_coadd_en_5delay_i     : in  std_logic;
      adc_coadd_en_4delay_i     : in  std_logic;
      clr_samples_coadd_reg_o   : out std_logic;
      address_count_en_o        : out std_logic;
      clr_address_count_o       : out std_logic;
      wren_bank0_o              : out std_logic;
      wren_bank1_o              : out std_logic;
      wren_for_fsfb_o           : out std_logic;
      coadd_done_o              : out std_logic;
      current_bank_o            : out std_logic);

  end component;

  

  signal rst_i                     : std_logic;
  signal clk_i                     : std_logic;
  signal restart_frame_1row_prev_i : std_logic;
  signal restart_frame_aligned_i   : std_logic;
  signal row_switch_i              : std_logic;
  signal adc_coadd_en_i            : std_logic;
  signal adc_coadd_en_5delay_i     : std_logic;
  signal adc_coadd_en_4delay_i     : std_logic;
  signal clr_samples_coadd_reg_o   : std_logic;
  signal address_count_en_o        : std_logic;
  signal clr_address_count_o       : std_logic;
  signal wren_bank0_o              : std_logic;
  signal wren_bank1_o              : std_logic;
  signal wren_for_fsfb_o           : std_logic;
  signal coadd_done_o              : std_logic;
  signal current_bank_o            : std_logic;

  
  constant PERIOD                : time := 20 ns;
  constant EDGE_DEPENDENCY       : time := 2 ns;  -- shows clk edge dependency
  constant RESET_WINDOW          : time := 8* PERIOD;
  constant CLOCKS_PER_ROW        : integer := 64;

  signal reset_window_done       : boolean := false;
  signal finish_tb : boolean     := false;  -- asserted to end test bench


  
  
begin  -- beh

  -----------------------------------------------------------------------------
  -- Instantiate the Device Under Test (DUT)
  -----------------------------------------------------------------------------

  DUT: coadd_dynamic_manager_ctrl
    
    generic map (
      COADD_DONE_MAX_COUNT => COADD_DONE_MAX_COUNT,
      MAX_SHIFT            => MAX_SHIFT)
    
    port map (
      rst_i                     => rst_i,
      clk_i                     => clk_i,
      restart_frame_1row_prev_i => restart_frame_1row_prev_i,
      restart_frame_aligned_i   => restart_frame_aligned_i,
      row_switch_i              => row_switch_i,
      adc_coadd_en_i            => adc_coadd_en_i,
      adc_coadd_en_5delay_i     => adc_coadd_en_5delay_i,
      adc_coadd_en_4delay_i     => adc_coadd_en_4delay_i,
      clr_samples_coadd_reg_o   => clr_samples_coadd_reg_o,
      address_count_en_o        => address_count_en_o,
      clr_address_count_o       => clr_address_count_o,
      wren_bank0_o              => wren_bank0_o,
      wren_bank1_o              => wren_bank1_o,
      wren_for_fsfb_o           => wren_for_fsfb_o,
      coadd_done_o              => coadd_done_o,
      current_bank_o            => current_bank_o);


  -----------------------------------------------------------------------------
  -- Clocking
  -----------------------------------------------------------------------------

  clocking: process
  begin  -- process clocking

    clk_i <= '1';
    wait for PERIOD/2;
    
    while (not finish_tb) loop
      clk_i <= not clk_i;
      wait for PERIOD/2;
    end loop;

    wait;
    
  end process clocking;


  -----------------------------------------------------------------------------
  -- Generate restart_frame_1row_prev_i, restart_frame_aligned_i, row_switch_i
  -- sinals with some nominal frequency
  -----------------------------------------------------------------------------

  i_gen_frame_sig: process
  begin  -- process i_gen_frame_sig
    
    restart_frame_1row_prev_i <= '0';
    restart_frame_aligned_i   <= '0';
    row_switch_i              <= '0';
    
    wait for RESET_WINDOW + EDGE_DEPENDENCY;
    wait for 19*PERIOD;                 -- free run

    while (not finish_tb) loop
      restart_frame_1row_prev_i <= '1',
                                   '0' after PERIOD;
      row_switch_i              <= '1',
                                   '0' after PERIOD;
      
      wait for CLOCKS_PER_ROW*PERIOD;      -- wait for one row time
      
      restart_frame_aligned_i <= '1',
                                 '0' after PERIOD;
      row_switch_i            <= '1',
                                 '0' after PERIOD;

      for i in 1 to 40 loop             -- assert row switch for 40 rows
        wait for CLOCKS_PER_ROW*PERIOD;
        row_switch_i <= '1',
                        '0' after PERIOD;
      end loop;  -- i
      
    end loop;

    wait;

  end process i_gen_frame_sig;

  

  -----------------------------------------------------------------------------
  -- Generate adc_coadd_en_i, adc_coadd_en_5delay_i and adc_coadd_en_4delay_i
  -- signals.  To test the effect of different width and different starting
  -- time for these signals, we creat multiple varaions.
  -----------------------------------------------------------------------------

  i_adc_coadd_en_4_5_delay: process
  begin  -- process i_adc_coadd_en_4_5_delay

    adc_coadd_en_i        <= '0';
    adc_coadd_en_5delay_i <= '0';
    adc_coadd_en_4delay_i <= '0';
    
    wait for RESET_WINDOW;
    
    wait until falling_edge(restart_frame_aligned_i);
  
    -- Generate both adc_coadd_en_4delay_i and adc_coadd_en_5delay_i to be in
    -- the row time cycle.
    for i in 1 to 2*41 loop             -- Repeat for 2 frames
      wait for 8*PERIOD;
      adc_coadd_en_i        <= '1';
      adc_coadd_en_4delay_i <= '1' after 4*PERIOD;
      adc_coadd_en_5delay_i <= '1' after 5*PERIOD;
      wait for 25*PERIOD;
      adc_coadd_en_i        <= '0';
      adc_coadd_en_4delay_i <= '0' after 4*PERIOD;
      adc_coadd_en_5delay_i <= '0' after 5*PERIOD;
      wait for (CLOCKS_PER_ROW-25-8)*PERIOD;      
    end loop;  -- i

    
    -- Same as above, but falling edge of adc_coadd_en_5delay_i is on row
    -- border
    
    -- *********** PUT YOUR TEST STIMULI HERE
    
    -- Falling edge of adc_coadd_en_4delay_i is on row, so falling edge of
    -- adc_coadd_en_5delay_i is one clk cycle in the next row time cycle
    
    -- *********** PUT YOUR TEST STIMULI HERE


    -- Both adc_coadd_en_4delay_i and adc_coadd_en_5delay_i end in the
    -- following row cycle time, as adc_coadd_en may be very close to row cycle
    -- boundary.  Note that the end time for adc_coadd_en could one clk cycle
    -- before the end of the row cycle time.

    for i in 1 to 2*41 loop             -- Repeat for 2 frames
      wait for 8*PERIOD;
      adc_coadd_en_i        <= '1';
      adc_coadd_en_4delay_i <= '1' after 4*PERIOD;
      adc_coadd_en_5delay_i <= '1' after 5*PERIOD;
      wait for 55*PERIOD;
      adc_coadd_en_i        <= '0';
      adc_coadd_en_4delay_i <= '0' after 4*PERIOD;
      adc_coadd_en_5delay_i <= '0' after 5*PERIOD;
      wait for (CLOCKS_PER_ROW-55-8)*PERIOD;      
    end loop;  -- i

    
    -- Repeat the first cycle that generates both adc_coadd_en_4delay_i and
    -- adc_coadd_en_5delay_i in the row time cycle.
    for i in 1 to 2*41 loop             -- Repeat for 2 frames
      wait for 8*PERIOD;
      adc_coadd_en_I        <= '1';
      adc_coadd_en_4delay_i <= '1' after 4*PERIOD;
      adc_coadd_en_5delay_i <= '1' after 5*PERIOD;
      wait for 25*PERIOD;
      adc_coadd_en_i        <= '0';
      adc_coadd_en_4delay_i <= '0' after 4*PERIOD;
      adc_coadd_en_5delay_i <= '0' after 5*PERIOD;
      wait for (CLOCKS_PER_ROW-25-8)*PERIOD;      
    end loop;  -- i


    
    wait for 41*200*PERIOD;                 -- free run
    finish_tb <= true;                  -- Terminate the Test Bench
    
  end process i_adc_coadd_en_4_5_delay;
 
  -----------------------------------------------------------------------------
  -- Perform Test
  -----------------------------------------------------------------------------
  
  i_test: process

    
    ---------------------------------------------------------------------------
    -- Procedure to initialize all the inputs
    ---------------------------------------------------------------------------

    procedure do_initialize is
    begin
      reset_window_done <= false;
    
      rst_i <= '1';
      wait for 113 ns;
      rst_i <= '0';
      wait for RESET_WINDOW - 113 ns;   -- alligne with clk

      reset_window_done <= true;
     
    end do_initialize;


    ---------------------------------------------------------------------------
    -- 
    ---------------------------------------------------------------------------


  begin  -- process i_test
   do_initialize;

   wait until finish_tb;
   
   report "End of Test";

   wait;
   
  end process i_test;


  
end beh;

