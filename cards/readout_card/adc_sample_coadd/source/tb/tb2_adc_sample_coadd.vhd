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
-- tb2_adc_sample_coadd.vhd
--
-- Project:	  SCUBA-2
-- Author:        Mohsen Nahvi
-- Organisation:  UBC
--
-- Description:
-- This is the second testbench for adc_sample_coadd block.  In this testbench,
-- we use a random value generated block(LFSR) to assign values to adc_dat_i.  
-- We do the followings:
-- 1. Initialize and free run row_switch_i, restart_frame_1row_prev_i,
-- restart_frame_1row_prev_i, and restart_frame_1row_post_i at the nominal
-- frequency of (64*41*period). 
-- 2. We write a new piece of data to adc_dat_i on the FALLING edge of the clk
-- to mimick the data coming from A/D.  Note that data from A/D is ready on the
-- falling edge of adc_en_clk.
-- 3.Perform coadd and dynamic manager test by:
-- phase1: (assume number of rows are 41)
-- 3.1 For two frame times, adc_coadd_en_i is asserted such that the finishing
-- time of adc_coadd_en_4delay_o is within a row dwell time.
-- 3.2 For two frame time, adc_coadd_en_i is asserted such that the falling
-- edge of both adc_coadd_en_4delay_o and adc_coadd_en_5delay_o is the next row
-- time.
-- 3.3 We repeat case 3.1 above to check the consistency of going from one case
-- to the other case.
-- phase2: ( We need to test the behaviour of the block when the number of the
-- rows in a frame are not 41, i.e., when after say row 24 we start a new frame
-- and this frame can have 12 rows between each restart_frame_aligned_i.
-- 3.4 Thus we generate the restart_frame_aligned_i, restart_frame_1row_prev_i,
-- last_row, and last_row_5delay for smaller intervals for one frame time
-- (23 and 35), then we generate these signals for two frames of 41 rows.
-- 3.5 We self check the expected results for coaddition, integration, and
-- difference value with what is output, i.e., current_coadd_dat_o,
-- current_integral_dat_o, and current_diff_dat_o.  If at any time an error is
-- detected, the testbench exits with failure.
-- 4. Do Raw Data Management Test by asserting raw_req_i three times.
--
--
--
-- Revision history:
-- 
-- $Log: tb2_adc_sample_coadd.vhd,v $
-- Revision 1.1  2004/10/23 01:27:58  mohsen
-- Created
--
--
------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library components;
use components.component_pack.all;





entity tb2_adc_sample_coadd is
  
end tb2_adc_sample_coadd;


architecture beh of tb2_adc_sample_coadd is


  component adc_sample_coadd
      port (
        -- ADC interface signals
        adc_dat_i                 : in std_logic_vector (13 downto 0);
        adc_ovr_i                 : in std_logic;
        adc_rdy_i                 : in std_logic;
        adc_clk_o                 : out std_logic;

        -- global signals 
        clk_50_i                  : in  std_logic;
        rst_i                     : in  std_logic;

        -- Frame timing signals
        adc_coadd_en_i            : in  std_logic;
        restart_frame_1row_prev_i : in  std_logic;
        restart_frame_aligned_i   : in  std_logic;
        row_switch_i              : in  std_logic;
        initialize_window_i       : in  std_logic;

        -- Wishbone Slave (wbs) Frame Data signals
        coadded_addr_i            : in  std_logic_vector (5 downto 0);
        coadded_dat_o             : out std_logic_vector (31 downto 0);
        raw_addr_i                : in  std_logic_vector (12 downto 0);
        raw_dat_o                 : out std_logic_vector (15 downto 0);
        raw_req_i                 : in  std_logic;
        raw_ack_o                 : out std_logic;

        -- First Stage Feedback Calculation (fsfb_calc) block signals
        coadd_done_o              : out std_logic;
        current_coadd_dat_o       : out std_logic_vector (31 downto 0);
        current_diff_dat_o        : out std_logic_vector (31 downto 0);
        current_integral_dat_o    : out std_logic_vector (31 downto 0);

        -- Wishbove Slave (wbs) Feedback (fb) Data Signals
        adc_offset_dat_i          : in  std_logic_vector(15 downto 0);
        adc_offset_adr_o          : out std_logic_vector(5 downto 0));
        
      
  end component;


  signal adc_dat_i                 : std_logic_vector (13 downto 0);
  signal adc_ovr_i                 : std_logic;
  signal adc_rdy_i                 : std_logic;
  signal adc_clk_o                 : std_logic;
  signal clk_50_i                  : std_logic;
  signal rst_i                     : std_logic :='1';
  signal adc_coadd_en_i            : std_logic;
  signal restart_frame_1row_prev_i : std_logic;
  signal restart_frame_aligned_i   : std_logic;
  signal row_switch_i              : std_logic;
  signal restart_frame_1row_post_i : std_logic;
  signal initialize_window_i       : std_logic;
  signal coadded_addr_i            : std_logic_vector (5 downto 0);
  signal coadded_dat_o             : std_logic_vector (31 downto 0);
  signal raw_addr_i                : std_logic_vector (12 downto 0);
  signal raw_dat_o                 : std_logic_vector (15 downto 0);
  signal raw_req_i                 : std_logic;
  signal raw_ack_o                 : std_logic;
  signal coadd_done_o              : std_logic;
  signal current_coadd_dat_o       : std_logic_vector (31 downto 0);
  signal current_diff_dat_o        : std_logic_vector (31 downto 0);
  signal current_integral_dat_o    : std_logic_vector (31 downto 0);
  signal adc_offset_dat_i          : std_logic_vector(15 downto 0);
  signal adc_offset_adr_o          : std_logic_vector(5 downto 0);

 
  constant PERIOD                  : time := 20 ns;
  constant EDGE_DEPENDENCY         : time := 2 ns;  --shows clk edge dependency
  constant RESET_WINDOW            : time := 8*PERIOD;
  constant FREE_RUN                : time := 19*PERIOD;
  constant CLOCKS_PER_ROW          : integer := 64;

  signal reset_window_done           : boolean := false;
  signal finish_tb                   : boolean := false;  -- asserted to end tb
  signal finish_test_raw_dat_manager : boolean := false;
  signal finish_test_coadd_manager   : boolean := false;
  signal finish_phase1_testing       : boolean := false;
  signal finish_phase2_testing       : boolean := false;  
  signal new_frame                   : boolean := true;



  -- adc offset values to use (one per row)
  type offset_array is array (0 to 63) of integer;
  constant ZERO_OFFSET : offset_array := (1285, 3453, 876, -3687, 1875, 12,
                                          -920, 456, 1234, 98, 123, 45, 3,
                                          654, 590, 78, 754, 458, 645, 994,
                                          -56, -764, -883, 1883, 96, 84, 773,
                                          922, 22, 290, 111, 874, 7184, 292,
                                          2, 134,8, 23, -575, 887, -234, 32,
                                          654,-74, 2, 6, -9, 10, 98, -23, 322,
                                          -2222, 94, 783, -239, -872, -91, -8,
                                          23, -645, 34, 12, 80, -45);

  -- for selfcheck process
  type memory_bank  is array (0 to 63) of integer;

  signal integral_bank0       : memory_bank;  -- bank0 for integral values
  signal integral_bank1       : memory_bank;  -- bank1 for integral values
  signal coadd_bank0          : memory_bank;  -- bank0 for coadded values
  signal coadd_bank1          : memory_bank;  -- bank1 for coadded values
  
  signal lfsr_o               : std_logic_vector(13 downto 0);
  signal adc_coadd_en_dly     : std_logic_vector(4 downto 0);  -- delyed adc_en
  signal current_bank         : std_logic;  -- similar copy to DUT internal sig
  signal address_index        : integer;  -- points to row in memory
  signal coadded_value        : integer;  -- hold coadd values at any time
  signal diff_value           : integer;  -- difference value
  signal found_error_coadd    : boolean := false;  -- flag for errors
  signal found_error_intgrl   : boolean := false;  -- flag for errors
  signal found_error_diff     : boolean := false;  -- flag for errors


  
begin  -- beh

  
  -----------------------------------------------------------------------------
  -- Instantiation of Device Under Test
  -----------------------------------------------------------------------------

  DUT : adc_sample_coadd

    port map (
    adc_dat_i                 => adc_dat_i,
    adc_ovr_i                 => adc_ovr_i,
    adc_rdy_i                 => adc_rdy_i,
    adc_clk_o                 => adc_clk_o,
    clk_50_i                  => clk_50_i,
    rst_i                     => rst_i,
    adc_coadd_en_i            => adc_coadd_en_i,
    restart_frame_1row_prev_i => restart_frame_1row_prev_i,
    restart_frame_aligned_i   => restart_frame_aligned_i,
    row_switch_i              => row_switch_i,
    initialize_window_i       => initialize_window_i,
    coadded_addr_i            => coadded_addr_i,
    coadded_dat_o             => coadded_dat_o,
    raw_addr_i                => raw_addr_i,
    raw_dat_o                 => raw_dat_o,
    raw_req_i                 => raw_req_i,
    raw_ack_o                 => raw_ack_o,
    coadd_done_o              => coadd_done_o,
    current_coadd_dat_o       => current_coadd_dat_o,
    current_diff_dat_o        => current_diff_dat_o,
    current_integral_dat_o    => current_integral_dat_o,
    adc_offset_dat_i          => adc_offset_dat_i,
    adc_offset_adr_o          => adc_offset_adr_o);


  -----------------------------------------------------------------------------
  -- Instantiate an LFSR to generate random numbers.  The LFSR is in Library of
  -- the project.
  -----------------------------------------------------------------------------

  random_generator : lfsr

    generic map (
    WIDTH => 14)
    
    port map (
      clk_i  => clk_50_i,
      rst_i  => rst_i,
      ena_i  => '1',
      load_i => '0',
      clr_i  => '0',
      lfsr_i => (others => '0'),
      lfsr_o => lfsr_o);
  
  -----------------------------------------------------------------------------
  -- Clocking
  -----------------------------------------------------------------------------

  clocking: process
  begin  -- process clocking

    clk_50_i <= '1';
    wait for PERIOD/2;
    
    while (not finish_tb) loop
      clk_50_i <= not clk_50_i;
      wait for PERIOD/2;
    end loop;

    wait;
    
  end process clocking;


  -----------------------------------------------------------------------------
  -- Generate restart_frame_aligned_i, restart_frame_1row_post_i, and
  -- restart_frame_1row_post_i sinals with some nominal frequency.  These
  -- timing signals are changed for each set of tests.
  -----------------------------------------------------------------------------

  i_gen_frame_sig: process
  begin  -- process i_gen_frame_sig
    restart_frame_1row_prev_i <= '0';
    restart_frame_aligned_i   <= '0';
    restart_frame_1row_post_i <= '0';
    row_switch_i              <= '0';
    initialize_window_i       <= '0';
    new_frame                 <= true;
    wait for RESET_WINDOW + EDGE_DEPENDENCY;
    wait for FREE_RUN;

    ---------------------------------------------------------------------------
    -- frame timing for testing coadd and dynamic manager
    ---------------------------------------------------------------------------

    while (not finish_test_coadd_manager) loop

      -- Phase 1 has 41 rows per frame and we manipulate position of coadd_en
      while (not finish_phase1_testing) loop
        restart_frame_1row_prev_i <= '1',
                                     '0' after PERIOD;
        row_switch_i              <= '1',
                                     '0' after PERIOD;
        wait for CLOCKS_PER_ROW*PERIOD;   -- wait one row
        restart_frame_aligned_i   <= '1',
                                     '0' after PERIOD;
        row_switch_i              <= '1',
                                     '0' after PERIOD;
        if new_frame = true  then
          initialize_window_i <= '1' after PERIOD;
          new_frame <= false;
        else
          initialize_window_i <= '0' after PERIOD;
        end if;
        wait for CLOCKS_PER_ROW*PERIOD;   -- wait one row
        restart_frame_1row_post_i <= '1',
                                     '0' after PERIOD;
        row_switch_i              <= '1',
                                     '0' after PERIOD;
        for i in 1 to (41-2) loop       -- assert row switch for 41-2 rows
          wait for CLOCKS_PER_ROW*PERIOD;
          row_switch_i <= '1',
                          '0' after PERIOD;
        end loop;  -- i
          
      end loop;

      
      wait for FREE_RUN;

      
      -- Phase 2 has 23, 35, and 41 rows per frame and we manipulate coadd_en

      -- frame with 23 rows
      restart_frame_1row_prev_i <= '1',
                                   '0' after PERIOD;
      row_switch_i              <= '1',
                                   '0' after PERIOD;
      wait for CLOCKS_PER_ROW*PERIOD;   -- wait one row
      restart_frame_aligned_i   <= '1',
                                   '0' after PERIOD;
      row_switch_i              <= '1',
                                   '0' after PERIOD;
      if new_frame = true then
        initialize_window_i <= '1' after PERIOD;
        new_frame <= false;
      else
        initialize_window_i <= '0' after PERIOD;
      end if;
      wait for CLOCKS_PER_ROW*PERIOD;   -- wait one row
      restart_frame_1row_post_i <= '1',
                                   '0' after PERIOD;
      row_switch_i              <= '1',
                                   '0' after PERIOD;
      for i in 1 to (23-2) loop         -- assert row switch for 23-2 rows
        wait for CLOCKS_PER_ROW*PERIOD;
        row_switch_i <= '1',
                        '0' after PERIOD;
      end loop;  -- i

      -- frame with 35 rows
      restart_frame_1row_prev_i <= '1',
                                   '0' after PERIOD;
      row_switch_i              <= '1',
                                   '0' after PERIOD;
      wait for CLOCKS_PER_ROW*PERIOD;   -- wait one row
      restart_frame_aligned_i   <= '1',
                                   '0' after PERIOD;
      row_switch_i              <= '1',
                                   '0' after PERIOD;
      if new_frame = true then
        initialize_window_i <= '1' after PERIOD;
        new_frame <= false;
      else
        initialize_window_i <= '0' after PERIOD;
      end if;
      wait for CLOCKS_PER_ROW*PERIOD;   -- wait one row
      restart_frame_1row_post_i <= '1',
                                   '0' after PERIOD;
      row_switch_i              <= '1',
                                   '0' after PERIOD;
      for i  in 1 to (35-2) loop        -- assert row switch for 35-2 rows
        wait for CLOCKS_PER_ROW*PERIOD;
        row_switch_i <= '1',
                        '0' after PERIOD;
      end loop;  -- i 
      
      -- frame with 41 rows
      while (not finish_phase2_testing) loop
        restart_frame_1row_prev_i <= '1',
                                     '0' after PERIOD;
        row_switch_i              <= '1',
                                     '0' after PERIOD;
        wait for CLOCKS_PER_ROW*PERIOD;   -- wait one row
        restart_frame_aligned_i   <= '1',
                                     '0' after PERIOD;
        row_switch_i              <= '1',
                                     '0' after PERIOD;
        if new_frame = true then
          initialize_window_i <= '1' after PERIOD;
          new_frame <= false;
        else
          initialize_window_i <= '0' after PERIOD;
        end if;
        wait for CLOCKS_PER_ROW*PERIOD;   -- wait one row
        restart_frame_1row_post_i <= '1',
                                     '0' after PERIOD;
        row_switch_i              <= '1',
                                     '0' after PERIOD;
        for i in 1 to (41-2) loop       -- assert row switch for 41-2 rows
          wait for CLOCKS_PER_ROW*PERIOD;
          row_switch_i <= '1',
                          '0' after PERIOD;
        end loop;  -- i

      end loop;

    end loop;

    
    wait for FREE_RUN;


    ---------------------------------------------------------------------------
    -- Frame timing for testing raw data manager
    ---------------------------------------------------------------------------
    
    while (not finish_test_raw_dat_manager) loop
      restart_frame_1row_prev_i <= '1',
                                   '0' after PERIOD;
      wait for CLOCKS_PER_ROW*PERIOD;   -- wait one row
      restart_frame_aligned_i   <= '1',
                                   '0' after PERIOD;
      wait for CLOCKS_PER_ROW*PERIOD;   -- wait one row
      restart_frame_1row_post_i <= '1',
                                   '0' after PERIOD;      
      wait for (CLOCKS_PER_ROW*(41-2)*PERIOD); -- wait for one frame=41 rows
    end loop;


    wait for FREE_RUN;
    
    ---------------------------------------------------------------------------
    -- Go to sleep
    ---------------------------------------------------------------------------

    wait;
        
  end process i_gen_frame_sig;
  

  
  -----------------------------------------------------------------------------
  -- Write a new piece of data into the adc_dat_i on each clock cycle. Note
  -- that we use negative edge of clk to mimick the data output of ADC that is
  -- valid after falling edge
  -----------------------------------------------------------------------------

  adc_offset_dat_i<=conv_std_logic_vector
                     (ZERO_OFFSET(conv_integer(unsigned(adc_offset_adr_o))),
                      adc_offset_dat_i'length);

  i_input_adc_dat: process (clk_50_i, rst_i)
  begin  -- process i_input_adc_dat
    if rst_i = '1' then                 -- asynchronous reset (active high)
      adc_dat_i <=(others => '0');      
    elsif clk_50_i'event and clk_50_i = '0' then  -- falling clock edge
      if (unsigned(lfsr_o)<=4000) then  -- avoid maxout due to adc_offset
        adc_dat_i <= lfsr_o;
      else
        adc_dat_i <= "00" & lfsr_o(11 downto 0);  -- lower the number
      end if;
    end if;
  end process i_input_adc_dat;



  -----------------------------------------------------------------------------
  -- Perform Test
  -----------------------------------------------------------------------------

  
  i_test: process


    ---------------------------------------------------------------------------
    -- Procedure to initialize all the inputs
    ---------------------------------------------------------------------------
    
    procedure do_initialize is
    begin
      reset_window_done       <= false;
      rst_i                   <= '1';
      raw_addr_i              <= "1010001111111";
      coadded_addr_i          <= "000000";
      raw_req_i               <= '0';
      adc_coadd_en_i          <= '0';
      current_bank            <= '0';
      
      wait for 113 ns;
      rst_i <= '0';
      wait for RESET_WINDOW - 113 ns;   -- alligne with clk

      reset_window_done <= true;
    end do_initialize;


    
    ---------------------------------------------------------------------------
    -- Procedure to test coadd and dynamic manager. To test the effect of
    -- different width and different starting time for the adc_coadd_en_i, we
    -- creat multiple varaions.  We also test for various number of rows in a
    -- frame.
    ---------------------------------------------------------------------------

    procedure test_coadd_manager_data_path is
    begin
 

      -------------------------------------------------------------------------
      -- Phase 1 of testing coadd_manager.
      -- In this phase we assume number of rows per frame are 41.  We then
      -- assert adc_coadd_en_i signls such that the falling edge of
      -- adc_coadd_en_4delay_i and adc_coadd_en_5delay_i fall in the same row
      -- or next row cycle time, as described in the title of private test
      -- bench for this unit, i.e., tb_coadd_manager_data_path.
      -------------------------------------------------------------------------

      wait until falling_edge(restart_frame_aligned_i);

      -- Generate adc_coadd_en_i such that both adc_coadd_en_4delay_i and
      -- adc_coadd_en_5delay_i to be in the row time cycle.
      for i in 1 to 2*41 loop             -- Repeat for 2 frames
        wait for 8*PERIOD;
        adc_coadd_en_i <= '1';
        wait for 25*PERIOD;
        adc_coadd_en_i <= '0';
        wait for (CLOCKS_PER_ROW-25-8)*PERIOD;      
        coadded_addr_i          <= conv_std_logic_vector
                                   ((conv_integer(unsigned(coadded_addr_i)) +1)
                                    , coadded_addr_i'length) after 10*PERIOD;
        if (conv_integer(unsigned(coadded_addr_i))=41-1) then
          current_bank   <= not current_bank after 10*PERIOD;
          coadded_addr_i <=(others => '0' ) after 10*PERIOD;
        end if;
      end loop;  -- i

    
      -- Same as above, but falling edge of adc_coadd_en_5delay_o is on row
      -- border
    
      -- *********** PUT YOUR TEST STIMULI HERE
    
      -- Falling edge of adc_coadd_en_4delay_o is on row, so falling edge of
      -- adc_coadd_en_5delay_o is one clk cycle in the next row time cycle
    
      -- *********** PUT YOUR TEST STIMULI HERE


      -- Both adc_coadd_en_4delay_o and adc_coadd_en_5delay_o end in the
      -- following row cycle time, as adc_coadd_en_i may be very close to row
      -- cycle boundary.  Note that the end time for adc_coadd_en_i could one
      -- clk cycle before the end of the row cycle time.

      for i in 1 to 2*41 loop             -- Repeat for 2 frames
        wait for 8*PERIOD;
        adc_coadd_en_i <= '1';
        wait for 55*PERIOD;
        adc_coadd_en_i <= '0';
        wait for (CLOCKS_PER_ROW-55-8)*PERIOD;      
        coadded_addr_i          <= conv_std_logic_vector
                                   ((conv_integer(unsigned(coadded_addr_i)) +1)
                                    , coadded_addr_i'length) after 10*PERIOD;
        if (conv_integer(unsigned(coadded_addr_i))=41-1) then
          current_bank   <= not current_bank after 10*PERIOD;
          coadded_addr_i <=(others => '0') after 10*PERIOD;
        end if;
      end loop;  -- i

    
      -- Repeat the first cycle that generates both adc_coadd_en_4delay_o and
      -- adc_coadd_en_5delay_o in the row time cycle.

       for i in 1 to 2*41 loop             -- Repeat for 2 frames
        wait for 8*PERIOD;
        adc_coadd_en_i <= '1';
        wait for 25*PERIOD;
        adc_coadd_en_i <= '0';
        wait for (CLOCKS_PER_ROW-25-8)*PERIOD;      
        coadded_addr_i          <= conv_std_logic_vector
                                   ((conv_integer(unsigned(coadded_addr_i)) +1)
                                    , coadded_addr_i'length) after 10*PERIOD;
        if (conv_integer(unsigned(coadded_addr_i))=41-1) then
          current_bank   <= not current_bank after 10*PERIOD;
          coadded_addr_i <=(others => '0') after 10*PERIOD;
        end if;
      end loop;  -- i

      finish_phase1_testing <= true;
      
      wait for PERIOD;


      -------------------------------------------------------------------------
      -- Phase 2 of testing
      -- In this phase the number of rows per frame are not assumed to be 41
      -- and change. However, the test is similar to phase 1 in nature. We need
      -- to test the behaviour of the block when the number of the rows in a
      -- frame are not 41, i.e., when after say row 24 we start a new frame and
      -- this frame can have 12 rows between each restart_frame_aligned_i.
      -------------------------------------------------------------------------

      wait until falling_edge(restart_frame_aligned_i);

      
      -- Generate adc_coadd_en_i such that both adc_coadd_en_4delay_i and
      -- adc_coadd_en_5delay_i to be in the row time cycle.

      for i in 1 to 1*23 loop             -- Repeat for 1 frame(of 23 rows)
        wait for 8*PERIOD;
        adc_coadd_en_i <= '1';
        wait for 25*PERIOD;
        adc_coadd_en_i <= '0';
        wait for (CLOCKS_PER_ROW-25-8)*PERIOD;      
        coadded_addr_i          <= conv_std_logic_vector
                                   ((conv_integer(unsigned(coadded_addr_i)) +1)
                                    , coadded_addr_i'length) after 10*PERIOD;
        if (conv_integer(unsigned(coadded_addr_i))=23-1) then
          current_bank   <= not current_bank after 10*PERIOD;
          coadded_addr_i <=(others => '0') after 10*PERIOD;
        end if;
      end loop;  -- i


      -- Both adc_coadd_en_4delay_o and adc_coadd_en_5delay_o end in the
      -- following row cycle time, as adc_coadd_en_i may be very close to row
      -- cycle boundary.  Note that the end time for adc_coadd_en_i could one
      -- clk cycle before the end of the row cycle time.

      for i in 1 to 1*35 loop             -- Repeat for 1 frame(of 35 rows)
        wait for 8*PERIOD;
        adc_coadd_en_i <= '1';
        wait for 55*PERIOD;
        adc_coadd_en_i <= '0';
        wait for (CLOCKS_PER_ROW-55-8)*PERIOD;      
        coadded_addr_i          <= conv_std_logic_vector
                                   ((conv_integer(unsigned(coadded_addr_i)) +1)
                                    , coadded_addr_i'length) after 10*PERIOD;
        if (conv_integer(unsigned(coadded_addr_i))=35-1) then
          current_bank   <= not current_bank after 10*PERIOD;
          coadded_addr_i <=(others => '0' )after 10*PERIOD;
        end if;
      end loop;  -- i

      
      -- Repeat the first cycle that generates both adc_coadd_en_4delay_o and
      -- adc_coadd_en_5delay_o in the row time cycle.

       for i in 1 to 2*41 loop             -- Repeat for 2 frames(of 41 rows)
        wait for 8*PERIOD;
        adc_coadd_en_i <= '1';
        wait for 25*PERIOD;
        adc_coadd_en_i <= '0';
        wait for (CLOCKS_PER_ROW-25-8)*PERIOD;      
        coadded_addr_i          <= conv_std_logic_vector
                                   ((conv_integer(unsigned(coadded_addr_i)) +1)
                                    , coadded_addr_i'length) after 10*PERIOD;
        if (conv_integer(unsigned(coadded_addr_i))=41-1) then
          current_bank   <= not current_bank after 10*PERIOD;
          coadded_addr_i <=(others => '0') after 10*PERIOD;
        end if;
      end loop;  -- i

      finish_phase2_testing <= true;

      
    end test_coadd_manager_data_path;


    ---------------------------------------------------------------------------
    -- Procedure to test raw data manger part of the adc_sample_coadd
    ---------------------------------------------------------------------------

    procedure test_raw_data_manger is
      variable i : integer;
    begin
      raw_req_i <='0';
      for i in 0 to 2 loop
        wait for 300*(i+1)*PERIOD + EDGE_DEPENDENCY;  -- free run
        raw_req_i <='1';
        wait until rising_edge(raw_ack_o);
        raw_req_i <='0';
      end loop;  -- i
    end test_raw_data_manger;
    
          
    
    ---------------------------------------------------------------------------
    -- 
    ---------------------------------------------------------------------------

  begin  -- process i_test
    do_initialize;

    test_coadd_manager_data_path;
    finish_test_coadd_manager   <= true;

    test_raw_data_manger;
    finish_test_raw_dat_manager <= true;      

    wait for 56*FREE_RUN;              
    finish_tb <= true;                  -- Terminate the Test Bench
     
    report "End of Test";

    wait;

    
   
  end process i_test;


  

  -----------------------------------------------------------------------------
  -- Self check:
  -- This block generates the expected coadded, integral, and differential
  -- values for the input value of the ADC, as expected of adc_sample_coadd
  -- block.  It then checks these expected values with what is output for
  -- fsfb_calc block in the flux_loop_ctrl.
  -----------------------------------------------------------------------------
  
  i_check: process (clk_50_i, rst_i)
    
  begin  -- process i_check
    if rst_i = '1' then                 -- asynchronous reset (active high)
      
      adc_coadd_en_dly   <= (others => '0');
      found_error_coadd  <= false;
      found_error_intgrl <= false;
      found_error_diff   <= false;
      address_index      <= 0;
      coadded_value      <= 0;
      diff_value         <= 0;

      -- initialize memory banks
      for i in 0 to 63 loop
        integral_bank0(i) <= 0;
        integral_bank1(i) <= 0;
        coadd_bank0(i)    <= 0;
        coadd_bank1(i)    <= 0;
      end loop;  -- i
      
    elsif clk_50_i'event and clk_50_i = '1' then  -- rising clock edge

      address_index <=  conv_integer(unsigned(coadded_addr_i));

      -- delay adc_coadd_en_i with 5 clocks
      adc_coadd_en_dly(0)   <= adc_coadd_en_i;  
      for i in 1 to 4 loop
        adc_coadd_en_dly(i) <= adc_coadd_en_dly(i-1);
      end loop;  -- i

      -- coadd
      if adc_coadd_en_dly(3) = '1' then
        coadded_value <=  coadded_value +(conv_integer(signed(adc_dat_i)))-
                          (conv_integer(signed(adc_offset_dat_i)));
      end if;


      -- find integral and difference
      if adc_coadd_en_dly(4) = '1' and adc_coadd_en_dly(3) = '0' then
        
        if current_bank = '0' then
          coadd_bank0(address_index) <= coadded_value;
          integral_bank0(address_index) <=  coadded_value +
                                           integral_bank1(address_index);
          diff_value <=  coadded_value - coadd_bank1(address_index);
        end if;
        
        if current_bank = '1' then
          coadd_bank1(address_index) <= coadded_value;
          integral_bank1(address_index) <=  coadded_value +
                                           integral_bank0(address_index);
          diff_value <=  coadded_value - coadd_bank0(address_index);
        end if;

        coadded_value <= 0;
         
      end if;
      
      -- self check
      if coadd_done_o = '1' then

        if diff_value /= conv_integer(signed(current_diff_dat_o)) then
          found_error_diff <= true;
        end if;
  
        case current_bank is
          when '0' =>
            if (coadd_bank0(address_index) /=
                conv_integer(signed(current_coadd_dat_o))) then
              found_error_coadd <= true;
            end if;
            if (integral_bank0(address_index) /=
                conv_integer(signed(current_integral_dat_o))) then
              found_error_intgrl <= true;
            end if;

          when '1' =>
            if (coadd_bank1(address_index) /=
                conv_integer(signed(current_coadd_dat_o))) then
              found_error_coadd <= true;
            end if;
            if (integral_bank1(address_index) /=
                conv_integer(signed(current_integral_dat_o))) then
              found_error_intgrl <= true;
            end if;
            
          when others => null;
        end case;
      end if;

      
      assert (found_error_coadd = false and found_error_intgrl = false and
              found_error_diff = false) report "FAILED" severity FAILURE;

      
        
    end if;
  end process i_check;


 
  
end beh;
