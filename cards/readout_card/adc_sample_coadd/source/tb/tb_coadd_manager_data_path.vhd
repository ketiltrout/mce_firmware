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
-- tb_coadd_manager_data_path.vhd
--
-- Project:	  SCUBA-2
-- Author:        Mohsen Nahvi
-- Organisation:  UBC
--
-- Description:
-- 
-- In this testbench file for the coadd_manager_data_path block, we do the
-- fllowings:
--
-- 1. Initialize and free run last_row_5delay, restart_frame_1row_prev_i,
-- restart_frame_aligned_i, and last_row  at the nominal frequency of
-- (64*41*period). These signals are not needed in this tb.  However, they are
-- good reference signals for the overall function of the block.
-- 2. We write a new piece of data to adc_dat_i on the FALLING edge of the clk
-- to mimick the data coming from A/D.  Note that data from A/D is ready on the
-- falling edge of adc_en_clk.
-- 3.  For two frame times, adc_coadd_en_i is asserted such that the finishing
-- time of adc_coadd_en_4delay_o is within a row dwell time.
-- 4. Same as case 3, but falling edge of adc_coadd_en_5delay_o is on row time
-- border. ################### TO BE IMPLEMENTED#####################
-- 5. same as case 3, but falling edge of adc_coadd_en_4delay_o is on row time.
-- ############### Case 4 to be implemented ######################
-- 6. For two frame time, adc_coadd_en_i is asserted such that the falling edge
-- of both adc_coadd_en_4delay_o and adc_coadd_en_5delay_o is the next row
-- time.
-- 7. We repeat case 3 above to check the consistency of going from one case to
-- the other case.
-- 8. We need to test the behaviour of the block when the number of the rows in
-- a frame are not 41, i.e., when after say row 24 we start a new frame and
-- this frame can have 12 rows between each restart_frame_aligned_i.  Thus we
-- generate the restart_frame_aligned_i, restart_frame_1row_prev_i, last_row,
-- and last_row_5delay for smaller intervals as mentioned in case 1 above.
-- 
--
-- Revision history:
-- 
-- $Log: tb_coadd_manager_data_path.vhd,v $
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

-- Call Parent Library
use work.flux_loop_ctrl_pack.all;
use work.flux_loop_pack.all;
use work.readout_card_pack.all;


entity tb_coadd_manager_data_path is

  generic (
    MAX_COUNT : integer :=64;
    MAX_SHIFT : integer := 5);
  
end tb_coadd_manager_data_path;



architecture beh of tb_coadd_manager_data_path is
  

  component coadd_manager_data_path
    
  generic (
    MAX_COUNT                 : integer := TOTAL_ROW_NO;
    MAX_SHIFT                 : integer := ADC_LATENCY+1); -- = Delay stages
                                                           -- for coadd enable
                                                           -- signals
                                                            
  port (
    rst_i                     : in  std_logic;
    clk_i                     : in  std_logic;
    adc_dat_i                 : in  std_logic_vector(ADC_DAT_WIDTH-1 downto 0);
    adc_offset_dat_i          : in  std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
    adc_offset_adr_o          : out std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0);
    adc_coadd_en_i            : in  std_logic;
    adc_coadd_en_5delay_o     : out std_logic;
    adc_coadd_en_4delay_o     : out std_logic;
    clr_samples_coadd_reg_i   : in  std_logic;
    samples_coadd_reg_o       : out std_logic_vector(COADD_DAT_WIDTH-1 downto 0);
    address_count_en_i        : in  std_logic;
    clr_address_count_i       : in  std_logic;
    coadd_write_addr_o        : out std_logic_vector(COADD_ADDR_WIDTH-1 downto 0));
    
    
  end component;



  signal rst_i                     : std_logic;
  signal clk_i                     : std_logic;
  signal adc_dat_i                 : std_logic_vector(ADC_DAT_WIDTH-1 downto 0);
  signal adc_offset_dat_i          : std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
  signal adc_offset_adr_o          : std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0);
  signal adc_coadd_en_i            : std_logic;
  signal adc_coadd_en_5delay_o     : std_logic;
  signal adc_coadd_en_4delay_o     : std_logic;
  signal clr_samples_coadd_reg_i   : std_logic;
  signal samples_coadd_reg_o       : std_logic_vector(COADD_DAT_WIDTH-1 downto 0);
  signal address_count_en_i        : std_logic;
  signal clr_address_count_i       : std_logic;
  signal coadd_write_addr_o        : std_logic_vector(COADD_ADDR_WIDTH-1 downto 0);

  
  constant PERIOD                : time := 20 ns;
  constant EDGE_DEPENDENCY       : time := 2 ns;  -- shows clk edge dependency
  constant RESET_WINDOW          : time := 8*PERIOD;
  constant CLOCKS_PER_ROW        : integer := 64;
  --constant ZERO_OFFSET           : integer := 1285;  -- adc offset value

  signal reset_window_done       : boolean := false;
  signal finish_tb               : boolean := false;  -- asserted to end tb
  signal finish_phase1_testing   : boolean := false;
  signal finish_phase2_testing   : boolean := false;

  signal restart_frame_1row_prev : std_logic;
  signal restart_frame_aligned   : std_logic;
  signal last_row                : std_logic;
  signal last_row_5delay         : std_logic;
  signal avalue                  : integer := 0;

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

  

begin  -- beh

  -----------------------------------------------------------------------------
  -- Instantiate the Device Under Test (DUT)
  -----------------------------------------------------------------------------

  DUT: coadd_manager_data_path
    generic map (
      MAX_COUNT => MAX_COUNT,
      MAX_SHIFT => MAX_SHIFT)

    port map (
      rst_i                   => rst_i,
      clk_i                   => clk_i,
      adc_dat_i               => adc_dat_i,
      adc_offset_dat_i        => adc_offset_dat_i,
      adc_offset_adr_o        => adc_offset_adr_o,
      adc_coadd_en_i          => adc_coadd_en_i,
      adc_coadd_en_5delay_o   => adc_coadd_en_5delay_o,
      adc_coadd_en_4delay_o   => adc_coadd_en_4delay_o,
      clr_samples_coadd_reg_i => clr_samples_coadd_reg_i,
      samples_coadd_reg_o     => samples_coadd_reg_o,
      address_count_en_i      => address_count_en_i,
      clr_address_count_i     => clr_address_count_i,
      coadd_write_addr_o      => coadd_write_addr_o);



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
  -- Generate restart_frame_1row_prev and restart_frame_aligned  sinals
  -- with some nominal frequency.  These are not used in this tb, but are good
  -- reference for other signals.
  -----------------------------------------------------------------------------

  i_gen_frame_sig: process
  begin  -- process i_gen_frame_sig
    
    restart_frame_1row_prev <= '0';
    restart_frame_aligned   <= '0';
    last_row                <= '0';
    last_row_5delay         <= '0';
    
    wait for RESET_WINDOW + EDGE_DEPENDENCY;
    wait for 19*PERIOD;                 -- free run

    while (not finish_phase1_testing) loop
      restart_frame_1row_prev <= '1';
      wait for PERIOD;
      restart_frame_1row_prev <= '0';
      last_row                <= '1';
      last_row_5delay         <= '1' after 5*PERIOD;
      
      wait for (64*PERIOD)-PERIOD;      -- wait for one row time
      
      restart_frame_aligned <= '1';
      wait for PERIOD;
      restart_frame_aligned <= '0';
      last_row              <= '0';
      last_row_5delay       <= '0' after 5*PERIOD;
      
      wait for (64*40*PERIOD)-PERIOD;   -- wait for one row time * 40 rows     
    end loop;

    ---------------------------------------------------------------------------
    -- now address case 8 of the test bench as described in the title
    ---------------------------------------------------------------------------
    wait for 19*PERIOD;                 -- free run

    --while (not finish_phase2_testing) loop
      restart_frame_1row_prev <= '1';
      wait for PERIOD;
      restart_frame_1row_prev <= '0';
      last_row                <= '1';
      last_row_5delay         <= '1' after 5*PERIOD;
      
      wait for (64*PERIOD)-PERIOD;      -- wait for one row time
      
      restart_frame_aligned <= '1';
      wait for PERIOD;
      restart_frame_aligned <= '0';
      last_row              <= '0';
      last_row_5delay       <= '0' after 5*PERIOD;
      
      wait for (64*22*PERIOD)-PERIOD;   -- wait for one row time * 22 rows     
    --end loop;

    --while (not finish_phase2_testing) loop
      restart_frame_1row_prev <= '1';
      wait for PERIOD;
      restart_frame_1row_prev <= '0';
      last_row                <= '1';
      last_row_5delay         <= '1' after 5*PERIOD;
      
      wait for (64*PERIOD)-PERIOD;      -- wait for one row time
      
      restart_frame_aligned <= '1';
      wait for PERIOD;
      restart_frame_aligned <= '0';
      last_row              <= '0';
      last_row_5delay       <= '0' after 5*PERIOD;
      
      wait for (64*34*PERIOD)-PERIOD;   -- wait for one row time * 34 rows     
    --end loop;

    while (not finish_phase2_testing) loop
      restart_frame_1row_prev <= '1';
      wait for PERIOD;
      restart_frame_1row_prev <= '0';
      last_row                <= '1';
      last_row_5delay         <= '1' after 5*PERIOD;
      
      wait for (64*PERIOD)-PERIOD;      -- wait for one row time
      
      restart_frame_aligned <= '1';
      wait for PERIOD;
      restart_frame_aligned <= '0';
      last_row              <= '0';
      last_row_5delay       <= '0' after 5*PERIOD;
      
      wait for (64*40*PERIOD)-PERIOD;   -- wait for one row time * 40 rows     
    end loop;
   
    

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
                                                                  
  i_input_adc_dat: process (clk_i, rst_i)
  begin  -- process i_input_adc_dat
    if rst_i = '1' then                 -- asynchronous reset (active hig)
      avalue <= 0;
    elsif clk_i'event and clk_i = '0' then  -- falling clock edge
      avalue <= avalue + 7;
      if avalue >4000 then
        avalue <=0;
      end if;      
    end if;
  end process i_input_adc_dat;
 
  adc_dat_i <= conv_std_logic_vector(avalue, adc_dat_i'length);



  
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
      adc_coadd_en_i          <= '0';
      address_count_en_i      <= '0';
      clr_samples_coadd_reg_i <= '1';
      clr_address_count_i     <= '0';
      rst_i <= '1';

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

    procedure test_coadd_manager_data_path is
    begin

   
    
      wait until falling_edge(restart_frame_aligned);
  
      -- Generate adc_coadd_en_i such that both adc_coadd_en_4delay_i and
      -- adc_coadd_en_5delay_i to be in the row time cycle.
      for i in 1 to 2*41 loop             -- Repeat for 2 frames
        wait for 8*PERIOD;
        adc_coadd_en_i <= '1';
        clr_samples_coadd_reg_i<= '0' after 4*PERIOD;
        wait for 25*PERIOD;
        adc_coadd_en_i <= '0';
        clr_samples_coadd_reg_i <= '1' after 5*PERIOD;
        address_count_en_i <= '1' after 5*PERIOD, '0' after 6*PERIOD;
        if (i=41 or i=2*41) then        -- last row in frame
          clr_address_count_i <= '1' after 5*PERIOD, '0' after 6*PERIOD;
        end if;
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
        adc_coadd_en_i <= '1';
        clr_samples_coadd_reg_i<= '0' after 4*PERIOD;
        wait for 55*PERIOD;
        adc_coadd_en_i <= '0';
        clr_samples_coadd_reg_i <= '1' after 5*PERIOD;
        address_count_en_i <= '1' after 5*PERIOD, '0' after 6*PERIOD;
        if (i=41 or i=2*41) then        -- last row in frame
          clr_address_count_i <= '1' after 5*PERIOD, '0' after 6*PERIOD;
        end if;
        wait for (CLOCKS_PER_ROW-55-8)*PERIOD;      
      end loop;  -- i

    
      -- Repeat the first cycle that generates both adc_coadd_en_4delay_o and
      -- adc_coadd_en_5delay_o in the row time cycle.

       for i in 1 to 2*41 loop             -- Repeat for 2 frames
        wait for 8*PERIOD;
        adc_coadd_en_i <= '1';
        clr_samples_coadd_reg_i<= '0' after 4*PERIOD;
        wait for 25*PERIOD;
        adc_coadd_en_i <= '0';
        clr_samples_coadd_reg_i <= '1' after 5*PERIOD;
        address_count_en_i <= '1' after 5*PERIOD, '0' after 6*PERIOD;
        if (i=41 or i=2*41) then        -- last row in frame
          clr_address_count_i <= '1' after 5*PERIOD, '0' after 6*PERIOD;
        end if;
        wait for (CLOCKS_PER_ROW-25-8)*PERIOD;      
      end loop;  -- i

      finish_phase1_testing <= true;
      wait for PERIOD;


      -------------------------------------------------------------------------
      -- Repeat cycle 1 and 2 above but Number of rows are not nominal 41
      -------------------------------------------------------------------------

      -- Generate adc_coadd_en_i such that both adc_coadd_en_4delay_i and
      -- adc_coadd_en_5delay_i to be in the row time cycle.

      wait until falling_edge(restart_frame_aligned);


      for i in 1 to 1*23 loop             -- Repeat for 1 frames
        wait for 8*PERIOD;
        adc_coadd_en_i <= '1';
        clr_samples_coadd_reg_i<= '0' after 4*PERIOD;
        wait for 25*PERIOD;
        adc_coadd_en_i <= '0';
        clr_samples_coadd_reg_i <= '1' after 5*PERIOD;
        address_count_en_i <= '1' after 5*PERIOD, '0' after 6*PERIOD;
        if (i=23 or i=1*23) then        -- last row in frame
          clr_address_count_i <= '1' after 5*PERIOD, '0' after 6*PERIOD;
        end if;
        wait for (CLOCKS_PER_ROW-25-8)*PERIOD;      
      end loop;  -- i


      -- Both adc_coadd_en_4delay_o and adc_coadd_en_5delay_o end in the
      -- following row cycle time, as adc_coadd_en_i may be very close to row
      -- cycle boundary.  Note that the end time for adc_coadd_en_i could one
      -- clk cycle before the end of the row cycle time.

      for i in 1 to 1*35 loop             -- Repeat for 1 frames
        wait for 8*PERIOD;
        adc_coadd_en_i <= '1';
        clr_samples_coadd_reg_i<= '0' after 4*PERIOD;
        wait for 55*PERIOD;
        adc_coadd_en_i <= '0';
        clr_samples_coadd_reg_i <= '1' after 5*PERIOD;
        address_count_en_i <= '1' after 5*PERIOD, '0' after 6*PERIOD;
        if (i=35 or i=1*35) then        -- last row in frame
          clr_address_count_i <= '1' after 5*PERIOD, '0' after 6*PERIOD;
        end if;
        wait for (CLOCKS_PER_ROW-55-8)*PERIOD;      
      end loop;  -- i

      
      -- Repeat the first cycle that generates both adc_coadd_en_4delay_o and
      -- adc_coadd_en_5delay_o in the row time cycle.

       for i in 1 to 2*41 loop             -- Repeat for 2 frames
        wait for 8*PERIOD;
        adc_coadd_en_i <= '1';
        clr_samples_coadd_reg_i<= '0' after 4*PERIOD;
        wait for 25*PERIOD;
        adc_coadd_en_i <= '0';
        clr_samples_coadd_reg_i <= '1' after 5*PERIOD;
        address_count_en_i <= '1' after 5*PERIOD, '0' after 6*PERIOD;
        if (i=41 or i=2*41) then        -- last row in frame
          clr_address_count_i <= '1' after 5*PERIOD, '0' after 6*PERIOD;
        end if;
        wait for (CLOCKS_PER_ROW-25-8)*PERIOD;      
      end loop;  -- i

      finish_phase2_testing <= true;
      
      
    end test_coadd_manager_data_path;

    


    ---------------------------------------------------------------------------
    -- 
    ---------------------------------------------------------------------------


  begin  -- process i_test
   do_initialize;
   test_coadd_manager_data_path;
   wait for 41*2*PERIOD;               -- free run
   finish_tb <= true;                  -- Terminate the Test Bench
     
   report "End of Test";

   wait;
   
  end process i_test;

  

end beh;

