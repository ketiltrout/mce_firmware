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
-- tb_dynamic_manager_data_path.vhd
--
-- Project:	  SCUBA-2
-- Author:        Mohsen Nahvi
-- Organisation:  UBC
--
-- Description:
-- 
-- In this testbench file for the dynamic_manager_data_path block, we do the
-- fllowings:
--
-- 1. Initialize and free run restart_frame_1row_prev_i,
-- restart_frame_aligned_i, restart_frame_1row_post at their nominal frequency
-- of (64*41*period).  These signals are not needed in this tb.  However, they
-- are good reference signals for the overall function of the block. Also, we
-- assert initialize_window_i once to test the masking function performed in
-- calculating the integral and difference values.
-- 2.  For two frame times, adc_coadd_en_i is assumed to be such that the
-- finishing time of adc_coadd_en_4delay_o is within a row dwell time.
-- Necessary control signals and data values are set.
-- 3. ### To be Implemented ### Same as case 2, but falling edge of
-- adc_coadd_en_5delay_o is on row time border.
-- 4. ### To be Implemented ### Same as case 2, but falling edge of
-- adc_coadd_en_4delay_o is on row time.
-- 5. For two frame time, adc_coadd_en_i is assumed to be such that the
-- falling edge of both adc_coadd_en_4delay_o and adc_coadd_en_5delay_o is the
-- next row time. 
-- 6. We repeat case 2 above to check the consistency of going from one case to
-- the other case.
-- 7. We need to test the behaviour of the block when the number of the rows in
-- a frame are not 41, i.e., when after say row 24 we start a new frame and
-- this frame can have 12 rows between each restart_frame_aligned_i.  Thus we
-- generate the restart_frame_aligned_i, restart_frame_1row_prev_i, 
-- and restart_frame_1row_post smaller intervals as mentioned in case 1 above.
-- 
--
-- Revision history:
-- 
-- $Log$
--
------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;


entity tb_dynamic_manager_data_path is
  
  generic (
    MAX_SHIFT : integer := 5);

end tb_dynamic_manager_data_path;




architecture beh of tb_dynamic_manager_data_path is


  component dynamic_manager_data_path
    
    generic (
      MAX_SHIFT : integer);
    
    port (

      rst_i                  : in  std_logic;
      clk_i                  : in  std_logic;
      initialize_window_i    : in  std_logic;
      current_coadd_dat_i    : in  std_logic_vector(31 downto 0);
      current_bank_i         : in  std_logic;
      wren_for_fsfb_i        : in  std_logic;
      coadd_dat_frm_bank0_i  : in  std_logic_vector(31 downto 0);
      coadd_dat_frm_bank1_i  : in  std_logic_vector(31 downto 0);
      intgrl_dat_frm_bank0_i : in  std_logic_vector(31 downto 0);
      intgrl_dat_frm_bank1_i : in  std_logic_vector(31 downto 0);
      current_coadd_dat_o    : out std_logic_vector(31 downto 0);
      current_diff_dat_o     : out std_logic_vector(31 downto 0);
      current_integral_dat_o : out std_logic_vector(31 downto 0);
      integral_result_o      : out std_logic_vector(31 downto 0));
    
  end component;


  signal rst_i                  : std_logic;
  signal clk_i                  : std_logic;
  signal initialize_window_i    : std_logic;
  signal current_coadd_dat_i    : std_logic_vector(31 downto 0);
  signal current_bank_i         : std_logic;
  signal wren_for_fsfb_i        : std_logic;
  signal coadd_dat_frm_bank0_i  : std_logic_vector(31 downto 0);
  signal coadd_dat_frm_bank1_i  : std_logic_vector(31 downto 0);
  signal intgrl_dat_frm_bank0_i : std_logic_vector(31 downto 0);
  signal intgrl_dat_frm_bank1_i : std_logic_vector(31 downto 0);
  signal current_coadd_dat_o    : std_logic_vector(31 downto 0);
  signal current_diff_dat_o     : std_logic_vector(31 downto 0);
  signal current_integral_dat_o : std_logic_vector(31 downto 0);
  signal integral_result_o      : std_logic_vector(31 downto 0);

  
  constant PERIOD                : time := 20 ns;
  constant EDGE_DEPENDENCY       : time := 2 ns;  -- shows clk edge dependency
  constant RESET_WINDOW          : time := 8*PERIOD;
  constant FREE_RUN              : time := 19*PERIOD;
  constant CLOCKS_PER_ROW        : integer := 64;

  signal reset_window_done       : boolean := false;
  signal finish_tb               : boolean := false;  -- asserted to end tb
  signal finish_phase1_testing   : boolean := false;
  signal finish_phase2_testing   : boolean := false;
  signal new_frame               : boolean := true;

  signal restart_frame_1row_prev : std_logic;
  signal restart_frame_aligned   : std_logic;
  signal restart_frame_1row_post : std_logic;
  signal row_switch              : std_logic;
  signal avalue                  : integer := 0;


  
begin  -- beh

  -----------------------------------------------------------------------------
  -- Instantiate the Device Under Test (DUT)
  -----------------------------------------------------------------------------

  DUT : dynamic_manager_data_path

    generic map (
    MAX_SHIFT => MAX_SHIFT)
    
    port map (
      rst_i                  => rst_i,
      clk_i                  => clk_i,
      initialize_window_i    => initialize_window_i,
      current_coadd_dat_i    => current_coadd_dat_i,
      current_bank_i         => current_bank_i,
      wren_for_fsfb_i        => wren_for_fsfb_i,
      coadd_dat_frm_bank0_i  => coadd_dat_frm_bank0_i,
      coadd_dat_frm_bank1_i  => coadd_dat_frm_bank1_i,
      intgrl_dat_frm_bank0_i => intgrl_dat_frm_bank0_i,
      intgrl_dat_frm_bank1_i => intgrl_dat_frm_bank1_i,
      current_coadd_dat_o    => current_coadd_dat_o,
      current_diff_dat_o     => current_diff_dat_o,
      current_integral_dat_o => current_integral_dat_o,
      integral_result_o      => integral_result_o);



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
  -- Generate restart_frame_1row_prev, restart_frame_aligned, row_switch
  -- sinals with some nominal frequency.  These are not used in this tb, but
  -- are good reference signals. Also, generate initialize_window_i
  -----------------------------------------------------------------------------

  i_gen_frame_sig: process
  begin  -- process i_gen_frame_sig
    
    restart_frame_1row_prev <= '0';
    restart_frame_aligned   <= '0';
    restart_frame_1row_post <= '0';
    row_switch              <= '0';
    initialize_window_i     <= '0';
    new_frame               <= true;
    wait for RESET_WINDOW + EDGE_DEPENDENCY;
    wait for FREE_RUN;



    ---------------------------------------------------------------------------
    -- Frame timing for phase 1.  Phase 1 has 41 rows per frame and we
    -- manupulate position of adc_coadd_en.
    ---------------------------------------------------------------------------
    while (not finish_phase1_testing) loop
      restart_frame_1row_prev <= '1',
                                 '0' after PERIOD;
      row_switch              <= '1',
                                 '0' after PERIOD;
      wait for CLOCKS_PER_ROW*PERIOD;      -- wait for one row time
      
      restart_frame_aligned <= '1',
                               '0' after PERIOD;
      row_switch            <= '1',
                               '0' after PERIOD;
      if new_frame = true then
        initialize_window_i <= '1' after PERIOD;
        new_frame <= false;
      else
        initialize_window_i <= '0' after PERIOD;
      end if;
      
      wait for CLOCKS_PER_ROW*PERIOD;     -- wait for one row
      restart_frame_1row_post <= '1',
                                 '0' after PERIOD;
      row_switch              <= '1',
                                 '0' after PERIOD;
      for i in 1 to 39 loop             -- assert row switch for 41-2 rows
        wait for CLOCKS_PER_ROW*PERIOD;
        row_switch <= '1',
                      '0' after PERIOD;
      end loop;  -- i
      
    end loop;


    wait for FREE_RUN;

    
    -- Phase 2 has 23, 35, and 41 rows per frame and we manipulate coadd_en

    restart_frame_1row_prev <= '1',
                               '0' after PERIOD;
    row_switch              <= '1',
                               '0' after PERIOD;
    wait for CLOCKS_PER_ROW*PERIOD;   -- wait one row
    
    restart_frame_aligned   <= '1',
                               '0' after PERIOD;
    row_switch              <= '1',
                               '0' after PERIOD;
    if new_frame = true then
      initialize_window_i <= '1' after PERIOD;
      new_frame <= false;
    else
      initialize_window_i <= '0' after PERIOD;
    end if;
    wait for CLOCKS_PER_ROW*PERIOD;   -- wait one row
    
    restart_frame_1row_post <= '1',
                               '0' after PERIOD;
    row_switch              <= '1',
                               '0' after PERIOD;
    for i in 1 to (23-2) loop           -- assert row swtich for 23-2 rows
      wait for CLOCKS_PER_ROW*PERIOD;
      row_switch <= '1',
                    '0' after PERIOD;
    end loop;  -- i
    

    restart_frame_1row_prev <= '1',
                               '0' after PERIOD;
    row_switch              <= '1',
                               '0' after PERIOD;
    wait for CLOCKS_PER_ROW*PERIOD;   -- wait one row
    
    restart_frame_aligned   <= '1',
                               '0' after PERIOD;
    row_switch              <= '1',
                               '0' after PERIOD;
    if new_frame = true then
      initialize_window_i <= '1' after PERIOD;
      new_frame <= false;
    else
      initialize_window_i <= '0' after PERIOD;
    end if;
    wait for CLOCKS_PER_ROW*PERIOD;   -- wait one row
    
    restart_frame_1row_post <= '1',
                               '0' after PERIOD;
    row_switch              <= '1',
                               '0' after PERIOD;    
    for i in 1 to (35-2) loop           -- assert row swtich for 35-2 rows
      wait for CLOCKS_PER_ROW*PERIOD;
      row_switch <= '1',
                    '0' after PERIOD;
    end loop;  -- i
      
     
    while (not finish_phase2_testing) loop
      restart_frame_1row_prev <= '1',
                                 '0' after PERIOD;
      row_switch              <= '1',
                                 '0' after PERIOD;
      wait for CLOCKS_PER_ROW*PERIOD;   -- wait one row
      
      restart_frame_aligned   <= '1',
                                 '0' after PERIOD;
      row_switch              <= '1',
                                 '0' after PERIOD;
      if new_frame = true then
        initialize_window_i <= '1' after PERIOD;
        new_frame <= false;
      else
        initialize_window_i <= '0' after PERIOD;
      end if;
      
      wait for CLOCKS_PER_ROW*PERIOD;   -- wait one row
      restart_frame_1row_post <= '1',
                                 '0' after PERIOD;
      row_switch              <= '1',
                                 '0' after PERIOD;
      for i in 1 to (41-2) loop           -- assert row swtich for 41-2 rows
        wait for CLOCKS_PER_ROW*PERIOD;
        row_switch <= '1',
                      '0' after PERIOD;
      end loop;  -- i

      
    end loop;


    
    wait for FREE_RUN;

    
    wait;

  end process i_gen_frame_sig;


  -----------------------------------------------------------------------------
  -- Perform Test
  -----------------------------------------------------------------------------
  
  i_test: process

    
    ---------------------------------------------------------------------------
    -- Procedure to initialize all the inputs
    ---------------------------------------------------------------------------

    procedure do_initialize is
    begin
      reset_window_done      <= false;
      avalue                 <= 0;
      rst_i                  <= '1';
      wren_for_fsfb_i        <= '0';
      current_bank_i         <= '0';
      current_coadd_dat_i    <= (others => '0');
      coadd_dat_frm_bank0_i  <= (others => '0');
      coadd_dat_frm_bank1_i  <= (others => '0');
      intgrl_dat_frm_bank0_i <= (others => '0');
      intgrl_dat_frm_bank1_i <= (others => '0');
      

      wait for 113 ns;
      rst_i <= '0';
      wait for RESET_WINDOW - 113 ns;   -- alligne with clk

      reset_window_done <= true;
     
    end do_initialize;

    ---------------------------------------------------------------------------
    -- Procedure to assert all inputs and test DUT. To test the effect of
    -- different width and different starting time for the signal, we creat
    -- multiple varaions.
    ---------------------------------------------------------------------------

    procedure test_dynamic_manager_data_path is
    begin

   
      -------------------------------------------------------------------------
      -- Phase 1 of testing dynamic_manager.
      -- In this phase we assume number of rows per frame are 41.  We then
      -- assume adc_coadd_en_i signl is such that the falling edge of
      -- adc_coadd_en_4delay_i and adc_coadd_en_5delay_i fall in the same row
      -- or next row cycle time, as described in the title of private test
      -- bench for this unit, i.e., tb_dynamic_manager_data_path.
      -------------------------------------------------------------------------
    
      wait until falling_edge(restart_frame_aligned);
  
      -- Assume adc_coadd_en_i to be such that both adc_coadd_en_4delay_i and
      -- adc_coadd_en_5delay_i to be in the row time cycle.
      for i in 1 to 2*41 loop             -- Repeat for 2 frames
        wait for 8*PERIOD;
        wait for 25*PERIOD;
        avalue <= avalue+7;
        if avalue >14000 then
          avalue <= 0;
        end if;
        -- Note coadd is asserted on falling edge of 4th delay of adc_coadd_en
        current_coadd_dat_i <= conv_std_logic_vector
                               (avalue, current_coadd_dat_i'length)
                               after 4*PERIOD;
        wren_for_fsfb_i <= '1' after 4*PERIOD, '0' after 5*PERIOD;
        if (i=41 or i=2*41) then        -- last row in frame
          current_bank_i <= not current_bank_i after 5*PERIOD;
        end if;        
        -- Note data sotrage use registered outputs, so 8 delays after e
        -- adc_coadd_en (2 delays after where the address changes in design)
        coadd_dat_frm_bank0_i <= conv_std_logic_vector
                                 (avalue+11, coadd_dat_frm_bank0_i'length)
                                 after 8*PERIOD;
        coadd_dat_frm_bank1_i <= conv_std_logic_vector
                                 (avalue-13, coadd_dat_frm_bank1_i'length)
                                 after 8*PERIOD;
        intgrl_dat_frm_bank0_i    <= conv_std_logic_vector
                                 (avalue+17, intgrl_dat_frm_bank0_i'length)
                                 after 8*PERIOD;
        intgrl_dat_frm_bank1_i    <= conv_std_logic_vector
                                 (avalue-19, intgrl_dat_frm_bank1_i'length)
                                 after 8*PERIOD;
        wait for (CLOCKS_PER_ROW-25-8)*PERIOD;      
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
        wait for 55*PERIOD;
        avalue <= avalue+7;
        if avalue >14000 then
          avalue <= 0;
        end if;
        current_coadd_dat_i <= conv_std_logic_vector
                               (avalue, current_coadd_dat_i'length)
                               after 4*PERIOD;
        wren_for_fsfb_i <= '1' after 4*PERIOD, '0' after 5*PERIOD;
        if (i=41 or i=2*41) then        -- last row in frame
          current_bank_i <= not current_bank_i after 5*PERIOD;
        end if;        
        coadd_dat_frm_bank0_i <= conv_std_logic_vector
                                 (avalue+11, coadd_dat_frm_bank0_i'length)
                                 after 8*PERIOD;
        coadd_dat_frm_bank1_i <= conv_std_logic_vector
                                 (avalue-13, coadd_dat_frm_bank1_i'length)
                                 after 8*PERIOD;
        intgrl_dat_frm_bank0_i    <= conv_std_logic_vector
                                 (avalue+17, intgrl_dat_frm_bank0_i'length)
                                 after 8*PERIOD;
        intgrl_dat_frm_bank1_i    <= conv_std_logic_vector
                                 (avalue-19, intgrl_dat_frm_bank1_i'length)
                                 after 8*PERIOD;
        wait for (CLOCKS_PER_ROW-55-8)*PERIOD;      
      end loop;  -- i

    
      -- Repeat the first cycle that generates both adc_coadd_en_4delay_o and
      -- adc_coadd_en_5delay_o in the row time cycle.

       for i in 1 to 2*41 loop             -- Repeat for 2 frames
        wait for 8*PERIOD;
        wait for 25*PERIOD;
        avalue <= avalue+7;
        if avalue >14000 then
          avalue <= 0;
        end if;
        current_coadd_dat_i <= conv_std_logic_vector
                               (avalue, current_coadd_dat_i'length)
                               after 4*PERIOD;
        wren_for_fsfb_i <= '1' after 4*PERIOD, '0' after 5*PERIOD;
        if (i=41 or i=2*41) then        -- last row in frame
          current_bank_i <= not current_bank_i after 5*PERIOD;
        end if;        
        coadd_dat_frm_bank0_i <= conv_std_logic_vector
                                 (avalue+11, coadd_dat_frm_bank0_i'length)
                                 after 8*PERIOD;
        coadd_dat_frm_bank1_i <= conv_std_logic_vector
                                 (avalue-13, coadd_dat_frm_bank1_i'length)
                                 after 8*PERIOD;
        intgrl_dat_frm_bank0_i    <= conv_std_logic_vector
                                 (avalue+17, intgrl_dat_frm_bank0_i'length)
                                 after 8*PERIOD;
        intgrl_dat_frm_bank1_i    <= conv_std_logic_vector
                                 (avalue-19, intgrl_dat_frm_bank1_i'length)
                                 after 8*PERIOD;
        wait for (CLOCKS_PER_ROW-25-8)*PERIOD;      
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

      wait until falling_edge(restart_frame_aligned);

      
      -- Assume adc_coadd_en_i is such that both adc_coadd_en_4delay_i and
      -- adc_coadd_en_5delay_i to be in the row time cycle.

      for i in 1 to 1*23 loop             -- Repeat for 1 frames
        wait for 8*PERIOD;
        wait for 25*PERIOD;
        avalue <= avalue+7;
        if avalue >14000 then
          avalue <= 0;
        end if;
        current_coadd_dat_i <= conv_std_logic_vector
                               (avalue, current_coadd_dat_i'length)
                               after 4*PERIOD;
        wren_for_fsfb_i <= '1' after 4*PERIOD, '0' after 5*PERIOD;
        if (i=23) then        -- last row in frame
          current_bank_i <= not current_bank_i after 5*PERIOD;
        end if;        
        coadd_dat_frm_bank0_i <= conv_std_logic_vector
                                 (avalue+11, coadd_dat_frm_bank0_i'length)
                                 after 8*PERIOD;
        coadd_dat_frm_bank1_i <= conv_std_logic_vector
                                 (avalue-13, coadd_dat_frm_bank1_i'length)
                                 after 8*PERIOD;
        intgrl_dat_frm_bank0_i    <= conv_std_logic_vector
                                 (avalue+17, intgrl_dat_frm_bank0_i'length)
                                 after 8*PERIOD;
        intgrl_dat_frm_bank1_i    <= conv_std_logic_vector
                                 (avalue-19, intgrl_dat_frm_bank1_i'length)
                                 after 8*PERIOD;
        wait for (CLOCKS_PER_ROW-25-8)*PERIOD;      
      end loop;  -- i


      -- Both adc_coadd_en_4delay_o and adc_coadd_en_5delay_o end in the
      -- following row cycle time, as adc_coadd_en_i may be very close to row
      -- cycle boundary.  Note that the end time for adc_coadd_en_i could one
      -- clk cycle before the end of the row cycle time.

      for i in 1 to 1*35 loop             -- Repeat for 1 frames
        wait for 8*PERIOD;
        wait for 55*PERIOD;
        avalue <= avalue+7;
        if avalue >14000 then
          avalue <= 0;
        end if;
        current_coadd_dat_i <= conv_std_logic_vector
                               (avalue, current_coadd_dat_i'length)
                               after 4*PERIOD;
        wren_for_fsfb_i <= '1' after 4*PERIOD, '0' after 5*PERIOD;
        if (i=35 or i=1*35) then        -- last row in frame
          current_bank_i <= not current_bank_i after 5*PERIOD;
        end if;
        coadd_dat_frm_bank0_i <= conv_std_logic_vector
                                 (avalue+11, coadd_dat_frm_bank0_i'length)
                                 after 8*PERIOD;
        coadd_dat_frm_bank1_i <= conv_std_logic_vector
                                 (avalue-13, coadd_dat_frm_bank1_i'length)
                                 after 8*PERIOD;
        intgrl_dat_frm_bank0_i    <= conv_std_logic_vector
                                 (avalue+17, intgrl_dat_frm_bank0_i'length)
                                 after 8*PERIOD;
        intgrl_dat_frm_bank1_i    <= conv_std_logic_vector
                                 (avalue-19, intgrl_dat_frm_bank1_i'length)
                                 after 8*PERIOD;
        wait for (CLOCKS_PER_ROW-55-8)*PERIOD;      
      end loop;  -- i

      
      -- Repeat the first cycle that generates both adc_coadd_en_4delay_o and
      -- adc_coadd_en_5delay_o in the row time cycle.

       for i in 1 to 2*41 loop             -- Repeat for 2 frames
        wait for 8*PERIOD;
        wait for 25*PERIOD;
        avalue <= avalue+7;
        if avalue >14000 then
          avalue <= 0;
        end if;
        current_coadd_dat_i <= conv_std_logic_vector
                               (avalue, current_coadd_dat_i'length)
                               after 4*PERIOD;
        wren_for_fsfb_i <= '1' after 4*PERIOD, '0' after 5*PERIOD;
        if (i=41 or i=2*41) then        -- last row in frame
          current_bank_i <= not current_bank_i after 5*PERIOD;
        end if;
        coadd_dat_frm_bank0_i <= conv_std_logic_vector
                                 (avalue+11, coadd_dat_frm_bank0_i'length)
                                 after 8*PERIOD;
        coadd_dat_frm_bank1_i <= conv_std_logic_vector
                                 (avalue-13, coadd_dat_frm_bank1_i'length)
                                 after 8*PERIOD;
        intgrl_dat_frm_bank0_i    <= conv_std_logic_vector
                                 (avalue+17, intgrl_dat_frm_bank0_i'length)
                                 after 8*PERIOD;
        intgrl_dat_frm_bank1_i    <= conv_std_logic_vector
                                 (avalue-19, intgrl_dat_frm_bank1_i'length)
                                 after 8*PERIOD;
        wait for (CLOCKS_PER_ROW-25-8)*PERIOD;      
      end loop;  -- i

      finish_phase2_testing <= true;
      
      
    end test_dynamic_manager_data_path;

    


    ---------------------------------------------------------------------------
    -- 
    ---------------------------------------------------------------------------


  begin  -- process i_test
   do_initialize;
   
   test_dynamic_manager_data_path;
   
   wait for 56*FREE_RUN;
   finish_tb <= true;                  -- Terminate the Test Bench
     
   report "End of Test";

   wait;
   
  end process i_test;


    
end beh;
