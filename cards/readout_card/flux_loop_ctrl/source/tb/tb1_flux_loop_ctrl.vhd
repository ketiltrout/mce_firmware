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
-- tb1_flux_loop_ctrl.vhd
--
-- Project:	  SCUBA-2
-- Author:        Mohsen Nahvi & Anthony Ko
-- Organisation:  UBC
--
-- Description:
-- This testbench tests the integration of three blocks within flux_loop_ctrl.
-- These blocks are: adc_sample_coadd, fsfb_calc, and fsfb_ctrl.
-- 
-- This testbench test performs in three different modes:
-- 
-- A) Lock Mode: where fsfb_calc gets the values from adc_sample_coadd and
-- outputs PIDZ error values.
-- B) Constant Mode: where fsfb_calc gets a constant value from wbs_fb_data and
-- outputs the same value to fsfb_ctrl.
-- C) Ramp Mode: where fsfb_calc gets ramp parameters from wbs_fb_data and
-- outputs the ramp result to fsfb_ctrl.
-- 
-- For the Lock Mode, we perform a selfcheck for the fsfb_calc outputs.
-- However, this selfcheck process needs to be commented out for other modes.
-- The selfcheck relies on a random value generated block(LFSR) to assign
-- values to adc_dat_i.
-- In the case of the fsfb_ctrl, we selfcheck its output with the expected
-- results.  Note that certain lines need to be commented out based on the mode
-- and based on the instantiation values used for the generic parameters in the
-- fsfb_ctrl block.
--
-- The following operations are performed:
-- 1. Initialize and free run row_switch_i, restart_frame_1row_prev_i,
-- restart_frame_1row_prev_i, and restart_frame_1row_post_i at the nominal
-- frequency of (64*41*period). 
-- 2. We write a new piece of data to adc_dat_i on the FALLING edge of the clk
-- to mimick the data coming from A/D.  Note that data from A/D is ready on the
-- falling edge of adc_en_clk. Moreover, we configure the PIDZ coefficient
-- queues for calculating the PIDZ error value in lock mode and select a servo
-- mode.
-- 3.Perform the tests by:
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
--
--
--
-- Revision history:
-- 
-- $Log: tb1_flux_loop_ctrl.vhd,v $
-- Revision 1.3  2004/11/19 23:20:18  anthonyk
-- Added various sa_bias/offset ctrl related changes
--
-- Revision 1.2  2004/11/08 23:56:22  mohsen
-- Sorted out parameters.  Also, incorporated fsfb_ctrl in the testbench and done self check.
--
-- Revision 1.1  2004/10/28 19:50:04  mohsen
-- created
--
--
--
------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library components;
use components.component_pack.all;

library sys_param;
use sys_param.wishbone_pack.all;

library work;
use work.adc_sample_coadd_pack.all;
use work.fsfb_calc_pack.all;
use work.fsfb_ctrl_pack.all;
use work.offset_ctrl_pack.all;
use work.sa_bias_ctrl_pack.all;



entity tb1_flux_loop_ctrl is
  
end tb1_flux_loop_ctrl;


architecture beh of tb1_flux_loop_ctrl is



  component flux_loop_ctrl

  port (


    -- ADC interface signals
    adc_dat_i                 : in  std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
    adc_ovr_i                 : in  std_logic;
    adc_rdy_i                 : in  std_logic;
    adc_clk_o                 : out std_logic;

    -- Global signals 
    clk_50_i                  : in  std_logic;
    clk_25_i                  : in  std_logic;
    rst_i                     : in  std_logic;

    -- Frame timing signals
    adc_coadd_en_i            : in  std_logic;
    restart_frame_1row_prev_i : in  std_logic;
    restart_frame_aligned_i   : in  std_logic;
    restart_frame_1row_post_i : in  std_logic;
    row_switch_i              : in  std_logic;
    initialize_window_i       : in  std_logic;
    num_rows_sub1_i           : in  std_logic_vector(FSFB_QUEUE_ADDR_WIDTH-1 downto 0);    -- number of rows per frame subtract 1
    dac_dat_en_i              : in  std_logic;
    -- Wishbone Slave (wbs) Frame Data signals
    coadded_addr_i            : in  std_logic_vector (COADD_ADDR_WIDTH-1 downto 0);
    coadded_dat_o             : out std_logic_vector (WB_DATA_WIDTH-1 downto 0);
    raw_addr_i                : in  std_logic_vector (RAW_ADDR_WIDTH-1 downto 0);
    raw_dat_o                 : out std_logic_vector (RAW_DAT_WIDTH-1 downto 0);
    raw_req_i                 : in  std_logic;
    raw_ack_o                 : out std_logic;

    fsfb_addr_i               : in  std_logic_vector(FSFB_QUEUE_ADDR_WIDTH-1 downto 0);    -- fs feedback queue previous address/data inputs/outputs
    fsfb_dat_o                : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);            -- read-only operations
    filtered_addr_i           : in  std_logic_vector(5 downto 0);
    filtered_dat_o            : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);

    
    -- Wishbove Slave (wbs) Feedback (fb) Data Signals
    adc_offset_dat_i          : in  std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
    adc_offset_adr_o          : out std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0);

    servo_mode_i              : in  std_logic_vector(SERVO_MODE_SEL_WIDTH-1 downto 0);     -- servo mode selection 
    ramp_step_size_i          : in  std_logic_vector(RAMP_STEP_WIDTH-1 downto 0);          -- ramp step increments/decrements
    ramp_amp_i                : in  std_logic_vector(RAMP_AMP_WIDTH-1 downto 0);           -- ramp peak amplitude
    const_val_i               : in  std_logic_vector(CONST_VAL_WIDTH-1 downto 0);          -- fs feedback constant value
    num_ramp_frame_cycles_i   : in  std_logic_vector(RAMP_CYC_WIDTH-1 downto 0);           -- number of frame cycle ramp remained level 
    p_addr_o                  : out std_logic_vector(COEFF_QUEUE_ADDR_WIDTH-1 downto 0);   -- coefficient queue address/data inputs/outputs 
    p_dat_i                   : in  std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);   -- read-only operations
    i_addr_o                  : out std_logic_vector(COEFF_QUEUE_ADDR_WIDTH-1 downto 0); 
    i_dat_i                   : in  std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);
    d_addr_o                  : out std_logic_vector(COEFF_QUEUE_ADDR_WIDTH-1 downto 0); 
    d_dat_i                   : in  std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);
    z_addr_o                  : out std_logic_vector(COEFF_QUEUE_ADDR_WIDTH-1 downto 0); 
    z_dat_i                   : in  std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);
    sa_bias_dat_i             : in  std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    offset_dat_i              : in  std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    filter_coeff0_i           : in  std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    filter_coeff1_i           : in  std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    filter_coeff2_i           : in  std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    filter_coeff3_i           : in  std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    filter_coeff4_i           : in  std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    filter_coeff5_i           : in  std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    filter_coeff6_i           : in  std_logic_vector(WB_DATA_WIDTH-1 downto 0);

    -- DAC Interface
    dac_dat_o                 : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
    dac_clk_o                 : out std_logic;

    -- spi DAC Interface
    sa_bias_dac_spi_o         : out std_logic_vector(SA_BIAS_SPI_DATA_WIDTH-1 downto 0);
    offset_dac_spi_o          : out std_logic_vector(OFFSET_SPI_DATA_WIDTH-1 downto 0);

    -- INTERNAL
    fsfb_fltr_dat_rdy_o       : out std_logic;                                             -- fs feedback queue current data ready 
    fsfb_fltr_dat_o           : out std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0);    -- fs feedback queue current data 
    fsfb_ctrl_dat_rdy_o       : out std_logic;                                             -- fs feedback queue previous data ready
    fsfb_ctrl_dat_o           : out std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0)     -- fs feedback queue previous data
      );

  end component;

 

    signal adc_dat_i                 : std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
    signal adc_ovr_i                 : std_logic;
    signal adc_rdy_i                 : std_logic;
    signal adc_clk_o                 : std_logic;
    signal clk_50_i                  : std_logic;
    signal clk_25_i                  : std_logic;
    signal rst_i                     : std_logic :='1';
    signal adc_coadd_en_i            : std_logic := '0';
    signal restart_frame_1row_prev_i : std_logic;
    signal restart_frame_aligned_i   : std_logic;
    signal restart_frame_1row_post_i : std_logic;
    signal row_switch_i              : std_logic;
    signal initialize_window_i       : std_logic;
    signal num_rows_sub1_i           : std_logic_vector(FSFB_QUEUE_ADDR_WIDTH-1 downto 0);    -- number of rows per frame subtract 1
    signal dac_dat_en_i              : std_logic :='0';
    signal coadded_addr_i            : std_logic_vector (COADD_ADDR_WIDTH-1 downto 0) := (others => '0');
    signal coadded_dat_o             : std_logic_vector (WB_DATA_WIDTH-1 downto 0);
    signal raw_addr_i                : std_logic_vector (RAW_ADDR_WIDTH-1 downto 0) := "1010001111111";
    signal raw_dat_o                 : std_logic_vector (RAW_DAT_WIDTH-1 downto 0);
    signal raw_req_i                 : std_logic :='0';
    signal raw_ack_o                 : std_logic;

    signal fsfb_ws_addr_i            : std_logic_vector(FSFB_QUEUE_ADDR_WIDTH-1 downto 0);    -- fs feedback queue previous address/data inputs/outputs
    signal fsfb_ws_dat_o             : std_logic_vector(WB_DATA_WIDTH-1 downto 0);            -- read-only operations
    signal filtered_addr_i           : std_logic_vector(5 downto 0);
    signal filtered_dat_o            : std_logic_vector(WB_DATA_WIDTH-1 downto 0);   
    signal adc_offset_dat_i          : std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
    signal adc_offset_adr_o          : std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0);

    signal servo_mode_i              : std_logic_vector(SERVO_MODE_SEL_WIDTH-1 downto 0);     -- servo mode selection 
    signal ramp_step_size_i          : std_logic_vector(RAMP_STEP_WIDTH-1 downto 0);          -- ramp step increments/decrements
    signal ramp_amp_i                : std_logic_vector(RAMP_AMP_WIDTH-1 downto 0);           -- ramp peak amplitude
    signal const_val_i               : std_logic_vector(CONST_VAL_WIDTH-1 downto 0);          -- fs feedback constant value
    signal num_ramp_frame_cycles_i   : std_logic_vector(RAMP_CYC_WIDTH-1 downto 0);           -- number of frame cycle ramp remained level 
    signal p_addr_o                  : std_logic_vector(COEFF_QUEUE_ADDR_WIDTH-1 downto 0);   -- coefficient queue address/data inputs/outputs 
    signal p_dat_i                   : std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);   -- read-only operations
    signal i_addr_o                  : std_logic_vector(COEFF_QUEUE_ADDR_WIDTH-1 downto 0); 
    signal i_dat_i                   : std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);
    signal d_addr_o                  : std_logic_vector(COEFF_QUEUE_ADDR_WIDTH-1 downto 0); 
    signal d_dat_i                   : std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);
    signal z_addr_o                  : std_logic_vector(COEFF_QUEUE_ADDR_WIDTH-1 downto 0); 
    signal z_dat_i                   : std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);
    signal sa_bias_dat_i             : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    signal offset_dat_i              : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    signal filter_coeff0_i           : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    signal filter_coeff1_i           : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    signal filter_coeff2_i           : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    signal filter_coeff3_i           : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    signal filter_coeff4_i           : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    signal filter_coeff5_i           : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    signal filter_coeff6_i           : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    signal dac_dat_o                 : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
    signal dac_clk_o                 : std_logic;
    signal sa_bias_dac_spi_o         : std_logic_vector(2 downto 0);
    signal offset_dac_spi_o          : std_logic_vector(2 downto 0);
    signal fsfb_fltr_dat_rdy_o       : std_logic;                                             -- fs feedback queue current data ready 
    signal fsfb_fltr_dat_o           : std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0);    -- fs feedback queue current data 
    signal fsfb_ctrl_dat_rdy_o       : std_logic;                                             -- fs feedback queue previous data ready
    signal fsfb_ctrl_dat_o           : std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0);    -- fs feedback queue previous data
      


    constant PERIOD                  : time := 20 ns;
    constant EDGE_DEPENDENCY         : time := 2 ns;  --shows clk edge dependency
    constant RESET_WINDOW            : time := 8*PERIOD;
    constant FREE_RUN                : time := 19*PERIOD;
    constant CLOCKS_PER_ROW          : integer := 64;

    signal reset_window_done          : boolean := false;
    signal finish_tb1                 : boolean := false;  -- asserted to end tb1
    signal finish_test_flux_loop_ctrl : boolean := false;
    signal finish_phase1_testing      : boolean := false;
    signal finish_phase2_testing      : boolean := false;  
    signal new_frame                  : boolean := true;
  


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



  
   signal calc_clk_i                   : std_logic;
   -- wishbone access (away from frame boundary)
   signal calc_ws_addr_i               :     std_logic_vector(FSFB_QUEUE_ADDR_WIDTH-1 downto 0);
   signal calc_ws_dat_o                :     std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  
   -- PIDZ coefficient queues io  
   signal calc_p_addr_o                :     std_logic_vector(COEFF_QUEUE_ADDR_WIDTH-1 downto 0);
   signal calc_p_dat_i                 :     std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);
   signal calc_p_dat_i_33              :     std_logic_vector(32 downto 0);
   signal calc_i_addr_o                :     std_logic_vector(COEFF_QUEUE_ADDR_WIDTH-1 downto 0);
   signal calc_i_dat_i                 :     std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);
   signal calc_i_dat_i_33              :     std_logic_vector(32 downto 0);   
   signal calc_d_addr_o                :     std_logic_vector(COEFF_QUEUE_ADDR_WIDTH-1 downto 0);
   signal calc_d_dat_i                 :     std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);
   signal calc_d_dat_i_33              :     std_logic_vector(32 downto 0);
   signal calc_z_addr_o                :     std_logic_vector(COEFF_QUEUE_ADDR_WIDTH-1 downto 0);
   signal calc_z_dat_i                 :     std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);
   signal calc_z_dat_i_33              :     std_logic_vector(32 downto 0);
   
   
   signal pq_wraddr_i                  :     std_logic_vector(5 downto 0);
   signal iq_wraddr_i                  :     std_logic_vector(5 downto 0);
   signal dq_wraddr_i                  :     std_logic_vector(5 downto 0);
   signal zq_wraddr_i                  :     std_logic_vector(5 downto 0);
   
   signal pq_wrdata_i                  :     std_logic_vector(32 downto 0);
   signal iq_wrdata_i                  :     std_logic_vector(32 downto 0);
   signal dq_wrdata_i                  :     std_logic_vector(32 downto 0);
   signal zq_wrdata_i                  :     std_logic_vector(32 downto 0);   
   
   signal pq_wren_i                    :     std_logic;
   signal iq_wren_i                    :     std_logic;
   signal dq_wren_i                    :     std_logic;
   signal zq_wren_i                    :     std_logic;


  -- for selfcheck process
  type memory_bank  is array (0 to 63) of integer;

  signal integral_bank0       : memory_bank;  -- bank0 for integral values
  signal integral_bank1       : memory_bank;  -- bank1 for integral values
  signal coadd_bank0          : memory_bank;  -- bank0 for coadded values
  signal coadd_bank1          : memory_bank;  -- bank1 for coadded values

  
  signal filter_bank0         : memory_bank;  -- bank0 holds current filter/previous DAC control value
  signal filter_bank1         : memory_bank;  -- same as bank0 
  
  signal lfsr_o               : std_logic_vector(13 downto 0);
  signal adc_coadd_en_dly     : std_logic_vector(5 downto 0);  -- delyed adc_en
  signal current_bank         : std_logic :='0';  -- similar copy to DUT internal sig
  signal current_bank_ctrl    : std_logic := '1';  -- for DAC controller
  signal current_bank_fltr    : std_logic := '0';
  signal address_index        : integer :=0;  -- points to row in memory
  signal coadded_value        : integer;  -- hold coadd values at any time
  signal diff_value           : integer;  -- difference value
  signal found_filter_error   : boolean := false;
  signal found_ctrl_error     : boolean := false;
  signal found_dac_error      : boolean := false;
  
  signal p_value              : std_logic_vector(32 downto 0);
  signal i_value              : std_logic_vector(32 downto 0);
  signal d_value              : std_logic_vector(32 downto 0);
  signal z_value              : std_logic_vector(32 downto 0);
  signal p_value_addr         : std_logic_vector(5 downto 0);
  signal i_value_addr         : std_logic_vector(5 downto 0);
  signal d_value_addr         : std_logic_vector(5 downto 0);
  signal z_value_addr         : std_logic_vector(5 downto 0);
  signal address_index_plus1  : integer :=1;      -- points to row in memory
  signal addr_plus1_inc_ok    : boolean := true;  -- flags wrap around for address_index_plus1
  
  												   


 

  -----------------------------------------------------------------------------
  -- Procedures
  -----------------------------------------------------------------------------

   -- procedure for configuring PIDZ coefficient queues   
   procedure cfg_pidz(
      signal clk_i    : in  std_logic;
      start_val       : in  integer;
      signal p_addr_o : out std_logic_vector(COEFF_QUEUE_ADDR_WIDTH-1 downto 0);
      signal i_addr_o : out std_logic_vector(COEFF_QUEUE_ADDR_WIDTH-1 downto 0);
      signal d_addr_o : out std_logic_vector(COEFF_QUEUE_ADDR_WIDTH-1 downto 0);
      signal z_addr_o : out std_logic_vector(COEFF_QUEUE_ADDR_WIDTH-1 downto 0);
      signal p_dat_o  : out std_logic_vector(32 downto 0);
      signal i_dat_o  : out std_logic_vector(32 downto 0);        
      signal d_dat_o  : out std_logic_vector(32 downto 0);           
      signal z_dat_o  : out std_logic_vector(32 downto 0);
      signal p_wren_o : out std_logic;
      signal i_wren_o : out std_logic;
      signal d_wren_o : out std_logic;
      signal z_wren_o : out std_logic
      ) is
      
   begin
      for index in 0 to 40 loop
         wait until clk_i = '0';
         p_addr_o <= conv_std_logic_vector(index, COEFF_QUEUE_ADDR_WIDTH);
         i_addr_o <= conv_std_logic_vector(index, COEFF_QUEUE_ADDR_WIDTH);
         d_addr_o <= conv_std_logic_vector(index, COEFF_QUEUE_ADDR_WIDTH);
         z_addr_o <= conv_std_logic_vector(index, COEFF_QUEUE_ADDR_WIDTH);
         p_dat_o  <= conv_std_logic_vector(start_val+index, 33);
         i_dat_o  <= conv_std_logic_vector(start_val+2*index, 33);
         d_dat_o  <= conv_std_logic_vector(start_val+3*index, 33);
         z_dat_o  <= conv_std_logic_vector(start_val+4*index, 33);
         p_wren_o <= '1';
         i_wren_o <= '1';
         d_wren_o <= '1';
         z_wren_o <= '1';
      end loop;
      wait until clk_i = '0';
      p_wren_o <= '0';
      i_wren_o <= '0';
      d_wren_o <= '0';
      z_wren_o <= '0';
   end procedure cfg_pidz;
  

   -- procedure for test mode setting
   procedure cfg_test_mode(
      servo_mode_i               : in  integer;
      ramp_step_size_i           : in  integer;
      ramp_amp_i                 : in  integer;
      ramp_frame_cycles_i        : in  integer;
      const_val_i                : in  integer;
      signal servo_mode_o        : out std_logic_vector(SERVO_MODE_SEL_WIDTH-1 downto 0);
      signal ramp_step_size_o    : out std_logic_vector(RAMP_STEP_WIDTH-1 downto 0);
      signal ramp_amp_o          : out std_logic_vector(RAMP_AMP_WIDTH-1 downto 0);
      signal ramp_frame_cycles_o : out std_logic_vector(RAMP_CYC_WIDTH-1 downto 0);
      signal const_val_o         : out std_logic_vector(CONST_VAL_WIDTH-1 downto 0)
      ) is
   begin
      servo_mode_o <= conv_std_logic_vector(servo_mode_i, SERVO_MODE_SEL_WIDTH);
      sel : case servo_mode_i is
         -- constant mode setting
         when 1 => const_val_o         <= conv_std_logic_vector(const_val_i, CONST_VAL_WIDTH);
                   ramp_step_size_o    <= (others => 'X');
                   ramp_amp_o          <= (others => 'X');
                   ramp_frame_cycles_o <= (others => 'X');
         -- ramp mode setting
         when 2 => const_val_o         <= (others => 'X');
                   ramp_step_size_o    <= conv_std_logic_vector(ramp_step_size_i, RAMP_STEP_WIDTH);
                   ramp_amp_o          <= conv_std_logic_vector(ramp_amp_i, RAMP_AMP_WIDTH);
                   ramp_frame_cycles_o <= conv_std_logic_vector(ramp_frame_cycles_i, RAMP_CYC_WIDTH);                   
         -- lock mode setting and invalid
         when others => const_val_o         <= (others => 'X');
                        ramp_step_size_o    <= (others => 'X');
		        ramp_amp_o          <= (others => 'X');
                        ramp_frame_cycles_o <= (others => 'X');
      end case sel;
   end procedure cfg_test_mode;
  


  -----------------------------------------------------------------------------
  -- 
  -----------------------------------------------------------------------------
  
begin  -- beh


  calc_clk_i   <= clk_50_i;
  
  p_value_addr <= conv_std_logic_vector(address_index, p_value_addr'length);
  i_value_addr <= conv_std_logic_vector(address_index, p_value_addr'length);
  d_value_addr <= conv_std_logic_vector(address_index, p_value_addr'length);
  z_value_addr <= conv_std_logic_vector(address_index, p_value_addr'length);

  address_index_plus1 <=
    address_index +1 when addr_plus1_inc_ok else
    0;
 
  
  
  -----------------------------------------------------------------------------
  -- Instantiate DUT
  -----------------------------------------------------------------------------

  DUT : flux_loop_ctrl

    port map (
    adc_dat_i                 => adc_dat_i,
    adc_ovr_i                 => adc_ovr_i,
    adc_rdy_i                 => adc_rdy_i,
    adc_clk_o                 => adc_clk_o,
    clk_50_i                  => clk_50_i,
    clk_25_i                  => clk_25_i,
    rst_i                     => rst_i,
    adc_coadd_en_i            => adc_coadd_en_i,
    restart_frame_1row_prev_i => restart_frame_1row_prev_i,
    restart_frame_aligned_i   => restart_frame_aligned_i,
    restart_frame_1row_post_i => restart_frame_1row_post_i,
    row_switch_i              => row_switch_i,
    initialize_window_i       => initialize_window_i,
    num_rows_sub1_i           => num_rows_sub1_i,
    dac_dat_en_i              => dac_dat_en_i,
    coadded_addr_i            => coadded_addr_i,
    coadded_dat_o             => coadded_dat_o,
    raw_addr_i                => raw_addr_i,
    raw_dat_o                 => raw_dat_o,
    raw_req_i                 => raw_req_i,
    raw_ack_o                 => raw_ack_o,
    fsfb_addr_i               => fsfb_ws_addr_i,
    fsfb_dat_o                => fsfb_ws_dat_o,
    filtered_addr_i           => filtered_addr_i,
    filtered_dat_o            => filtered_dat_o,
    adc_offset_dat_i          => adc_offset_dat_i,
    adc_offset_adr_o          => adc_offset_adr_o,
    servo_mode_i              => servo_mode_i,
    ramp_step_size_i          => ramp_step_size_i,
    ramp_amp_i                => ramp_amp_i,
    const_val_i               => const_val_i,
    num_ramp_frame_cycles_i   => num_ramp_frame_cycles_i,
    p_addr_o                  => p_addr_o,
    p_dat_i                   => p_dat_i,
    i_addr_o                  => i_addr_o,
    i_dat_i                   => i_dat_i,
    d_addr_o                  => d_addr_o,
    d_dat_i                   => d_dat_i,
    z_addr_o                  => z_addr_o,
    z_dat_i                   => z_dat_i,
    sa_bias_dat_i             => sa_bias_dat_i,
    offset_dat_i              => offset_dat_i,
    filter_coeff0_i           => filter_coeff0_i,
    filter_coeff1_i           => filter_coeff1_i,
    filter_coeff2_i           => filter_coeff2_i,
    filter_coeff3_i           => filter_coeff3_i,
    filter_coeff4_i           => filter_coeff4_i,
    filter_coeff5_i           => filter_coeff5_i,
    filter_coeff6_i           => filter_coeff6_i,
    dac_dat_o                 => dac_dat_o,
    dac_clk_o                 => dac_clk_o,
    sa_bias_dac_spi_o         => sa_bias_dac_spi_o,
    offset_dac_spi_o          => offset_dac_spi_o,
    fsfb_fltr_dat_rdy_o       => fsfb_fltr_dat_rdy_o,
    fsfb_fltr_dat_o           => fsfb_fltr_dat_o,
    fsfb_ctrl_dat_rdy_o       => fsfb_ctrl_dat_rdy_o,
    fsfb_ctrl_dat_o           => fsfb_ctrl_dat_o);

  
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
  -- Instantiate P coefficient queue
  -----------------------------------------------------------------------------
   p_queue : fsfb_queue 
      port map (
         data                     => pq_wrdata_i,
         wraddress                => pq_wraddr_i,
         rdaddress_a              => p_addr_o,
         rdaddress_b              => p_value_addr,
         wren                     => pq_wren_i,
         clock                    => calc_clk_i,
         qa                       => calc_p_dat_i_33,
         qb                       => p_value
         );

   p_dat_i <= calc_p_dat_i_33(COEFF_QUEUE_DATA_WIDTH-1 downto 0);         
   

  -----------------------------------------------------------------------------
   -- Instantiate I coefficient queue
  -----------------------------------------------------------------------------

   i_queue : fsfb_queue 
      port map (
         data                     => iq_wrdata_i,
         wraddress                => iq_wraddr_i,
         rdaddress_a              => i_addr_o,
         rdaddress_b              => i_value_addr,
         wren                     => iq_wren_i,
         clock                    => calc_clk_i,
         qa                       => calc_i_dat_i_33,
         qb                       => i_value
         );
         
   i_dat_i <= calc_i_dat_i_33(COEFF_QUEUE_DATA_WIDTH-1 downto 0);
   

  -----------------------------------------------------------------------------
   -- Instantiate D coefficient queue
  -----------------------------------------------------------------------------

   d_queue : fsfb_queue 
      port map (
         data                     => dq_wrdata_i,
         wraddress                => dq_wraddr_i,
         rdaddress_a              => d_addr_o,
         rdaddress_b              => d_value_addr,
         wren                     => dq_wren_i,
         clock                    => calc_clk_i,
         qa                       => calc_d_dat_i_33,
         qb                       => d_value
         );

   d_dat_i <= calc_d_dat_i_33(COEFF_QUEUE_DATA_WIDTH-1 downto 0);
         

  -----------------------------------------------------------------------------
   -- Instantiate Z coefficient queue
  -----------------------------------------------------------------------------

   z_queue : fsfb_queue 
      port map (
         data                     => zq_wrdata_i,
         wraddress                => zq_wraddr_i,
         rdaddress_a              => z_addr_o,
         rdaddress_b              => z_value_addr,
         wren                     => zq_wren_i,
         clock                    => calc_clk_i,
         qa                       => calc_z_dat_i_33,
         qb                       => z_value
         );

   z_dat_i <= calc_z_dat_i_33(COEFF_QUEUE_DATA_WIDTH-1 downto 0);



  
  -----------------------------------------------------------------------------
  -- Clocking
  -----------------------------------------------------------------------------

  clocking_50: process
  begin  -- process clocking

    clk_50_i <= '1';
    wait for PERIOD/2;
    
    while (not finish_tb1) loop
      clk_50_i <= not clk_50_i;
      wait for PERIOD/2;
    end loop;

    wait;
    
  end process clocking_50;
  
  clocking_25: process
  begin  -- process clocking

    clk_25_i <= '1';
    wait for PERIOD;
    
    while (not finish_tb1) loop
      clk_25_i <= not clk_25_i;
      wait for PERIOD;
    end loop;

    wait;
    
  end process clocking_25;

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
    dac_dat_en_i              <= '0';
    new_frame                 <= true;
    wait for RESET_WINDOW + EDGE_DEPENDENCY;
    wait for FREE_RUN;

    ---------------------------------------------------------------------------
    -- frame timing for testing coadd and dynamic manager
    ---------------------------------------------------------------------------

    while (not finish_test_flux_loop_ctrl) loop

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
        dac_dat_en_i              <= '0' after PERIOD,
                                     '1' after 7*PERIOD;
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
        dac_dat_en_i              <= '0' after PERIOD,
                                     '1' after 7*PERIOD;
        for i in 1 to (41-2) loop       -- assert row switch for 41-2 rows
          wait for CLOCKS_PER_ROW*PERIOD;
          row_switch_i <= '1',
                          '0' after PERIOD;
          dac_dat_en_i <= '0' after PERIOD,
                          '1' after 7*PERIOD;
        end loop;  -- i
          
      end loop;

      
      
      -- Phase 2 has 23, 35, and 41 rows per frame and we manipulate coadd_en

      restart_frame_1row_prev_i <= '1',
                                   '0' after PERIOD;
      row_switch_i              <= '1',
                                   '0' after PERIOD;
      dac_dat_en_i              <= '0' after PERIOD,
                                   '1' after 7*PERIOD;
      wait for CLOCKS_PER_ROW*PERIOD;   -- wait one row
      restart_frame_aligned_i   <= '1',
                                   '0' after PERIOD;
      row_switch_i              <= '1',
                                   '0' after PERIOD; 
      dac_dat_en_i              <= '0' after PERIOD,
                                   '1' after 7*PERIOD;
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
      dac_dat_en_i              <= '0' after PERIOD,
                                   '1' after 7*PERIOD;
      for i in 1 to (23-2) loop         -- assert row switch for 23-2 rows
        wait for CLOCKS_PER_ROW*PERIOD;
        row_switch_i <= '1',
                        '0' after PERIOD;
        dac_dat_en_i <= '0' after PERIOD,
                        '1' after 7*PERIOD;
      end loop;  -- i

      restart_frame_1row_prev_i <= '1',
                                   '0' after PERIOD;
      row_switch_i              <= '1',
                                   '0' after PERIOD;
      dac_dat_en_i              <= '0' after PERIOD,
                                   '1' after 7*PERIOD;
      wait for CLOCKS_PER_ROW*PERIOD;   -- wait one row
      restart_frame_aligned_i   <= '1',
                                   '0' after PERIOD;
      row_switch_i              <= '1',
                                   '0' after PERIOD;
      dac_dat_en_i              <= '0' after PERIOD,
                                   '1' after 7*PERIOD;
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
      dac_dat_en_i              <= '0' after PERIOD,
                                   '1' after 7*PERIOD;
      for i  in 1 to (35-2) loop        -- assert row switch for 35-2 rows
        wait for CLOCKS_PER_ROW*PERIOD;
        row_switch_i <= '1',
                        '0' after PERIOD;
        dac_dat_en_i <= '0' after PERIOD,
                        '1' after 7*PERIOD;
      end loop;  -- i 
      
      while (not finish_phase2_testing) loop
        restart_frame_1row_prev_i <= '1',
                                     '0' after PERIOD;
        row_switch_i              <= '1',
                                     '0' after PERIOD;
        dac_dat_en_i              <= '0' after PERIOD,
                                     '1' after 7*PERIOD;
        wait for CLOCKS_PER_ROW*PERIOD;   -- wait one row
        restart_frame_aligned_i   <= '1',
                                     '0' after PERIOD;
        row_switch_i              <= '1',
                                     '0' after PERIOD;
        dac_dat_en_i              <= '0' after PERIOD,
                                     '1' after 7*PERIOD;
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
        dac_dat_en_i              <= '0' after PERIOD,
                                     '1' after 7*PERIOD;
        for i in 1 to (41-2) loop       -- assert row switch for 41-2 rows
          wait for CLOCKS_PER_ROW*PERIOD;
          row_switch_i <= '1',
                          '0' after PERIOD;
          dac_dat_en_i <= '0' after PERIOD,
                          '1' after 7*PERIOD;
        end loop;  -- i

      end loop;

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
      coadded_addr_i          <= "000000";
      adc_coadd_en_i          <= '0';
      current_bank            <= '0';
      
      wait for 113 ns;
      rst_i <= '0';
      wait for RESET_WINDOW - 113 ns;   -- alligne with clk

      reset_window_done <= true;
    end do_initialize;


    
    ---------------------------------------------------------------------------
    -- To test the effect of different width and different starting time for
    -- the adc_coadd_en_i, we creat multiple varaions.  We also test for various
    -- number of rows in a frame.
    ---------------------------------------------------------------------------

    procedure test_flux_loop_ctrl is
    begin
 

      -------------------------------------------------------------------------
      -- Phase 1.
      -- In this phase we assume number of rows per frame are 41.  We then
      -- assert adc_coadd_en_i signls such that the falling edge of
      -- adc_coadd_en_4delay_i and adc_coadd_en_5delay_i fall in the same row
      -- or next row cycle time.
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
        coadded_addr_i          <= coadded_addr_i  +1 after 10*PERIOD;
        if (conv_integer(unsigned(coadded_addr_i)) = 41-2) then
          current_bank_ctrl <= not current_bank_ctrl after 10*PERIOD;
          addr_plus1_inc_ok <= false after 10*PERIOD,
                               true  after (CLOCKS_PER_ROW+10)*PERIOD;
        end if;
        if (conv_integer(unsigned(coadded_addr_i))=41-1) then
          current_bank       <= not current_bank      after 10*PERIOD;
          current_bank_fltr  <= not current_bank_fltr after 10*PERIOD;
          coadded_addr_i <=(others => '0' ) after 10*PERIOD;
        end if;
      end loop;  -- i


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
        coadded_addr_i          <= coadded_addr_i  +1 after 10*PERIOD;
        if (conv_integer(unsigned(coadded_addr_i)) = 41-2) then
          current_bank_ctrl <= not current_bank_ctrl after 10*PERIOD;
          addr_plus1_inc_ok <= false after 10*PERIOD,
                               true  after (CLOCKS_PER_ROW+10)*PERIOD;
        end if;
        if (conv_integer(unsigned(coadded_addr_i))=41-1) then
          current_bank       <= not current_bank      after 10*PERIOD;
          current_bank_fltr  <= not current_bank_fltr after 10*PERIOD;
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
        coadded_addr_i          <= coadded_addr_i  +1 after 10*PERIOD;
        if (conv_integer(unsigned(coadded_addr_i)) = 41-2) then
          current_bank_ctrl <= not current_bank_ctrl after 10*PERIOD;
          addr_plus1_inc_ok <= false after 10*PERIOD,
                               true  after (CLOCKS_PER_ROW+10)*PERIOD;
        end if;
        if (conv_integer(unsigned(coadded_addr_i))=41-1) then
          current_bank       <= not current_bank      after 10*PERIOD;
          current_bank_fltr  <= not current_bank_fltr after 10*PERIOD;
          coadded_addr_i <=(others => '0') after 10*PERIOD;
        end if;
      end loop;  -- i

      finish_phase1_testing <= true;

      
      -- free run for 1 frame
      for i in 1 to 41 loop
        wait for CLOCKS_PER_ROW*PERIOD;
        coadded_addr_i <= coadded_addr_i +1 after 10*PERIOD;
        if (conv_integer(unsigned(coadded_addr_i)) = 41-2) then
          current_bank_ctrl <= not current_bank_ctrl after 10*PERIOD;
          addr_plus1_inc_ok <= false after 10*PERIOD,
                               true  after (CLOCKS_PER_ROW+10)*PERIOD;
        end if;
        if (conv_integer(unsigned(coadded_addr_i))=41-1) then
          --current_bank   <= not current_bank after 10*PERIOD;
          current_bank_fltr   <= not current_bank_fltr after 10*PERIOD;
          coadded_addr_i <=(others => '0') after 10*PERIOD;
        end if;        
      end loop;  -- i

      
 
      -------------------------------------------------------------------------
      -- Phase 2 of testing
      -- In this phase the number of rows per frame are not assumed to be 41
      -- and change. However, the test is similar to phase 1 in nature. We need
      -- to test the behaviour of the block when the number of the rows in a
      -- frame are not 41, i.e., when after say row 24 we start a new frame and
      -- this frame can have 12 rows between each restart_frame_aligned_i.
      -------------------------------------------------------------------------


      
      -- Generate adc_coadd_en_i such that both adc_coadd_en_4delay_i and
      -- adc_coadd_en_5delay_i to be in the row time cycle.

      for i in 1 to 1*23 loop             -- Repeat for 1 frame(of 23 rows)
        wait for 8*PERIOD;
        adc_coadd_en_i <= '1';
        wait for 25*PERIOD;
        adc_coadd_en_i <= '0';
        wait for (CLOCKS_PER_ROW-25-8)*PERIOD;      
        coadded_addr_i          <= coadded_addr_i  +1 after 10*PERIOD;
        if (conv_integer(unsigned(coadded_addr_i)) = 23-2) then
          current_bank_ctrl <= not current_bank_ctrl after 10*PERIOD;
          addr_plus1_inc_ok <= false after 10*PERIOD,
                               true  after (CLOCKS_PER_ROW+10)*PERIOD;
        end if;
        if (conv_integer(unsigned(coadded_addr_i))=23-1) then
          current_bank       <= not current_bank      after 10*PERIOD;
          current_bank_fltr  <= not current_bank_fltr after 10*PERIOD;
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
        coadded_addr_i          <= coadded_addr_i  +1 after 10*PERIOD;
        if (conv_integer(unsigned(coadded_addr_i)) = 35-2) then
          current_bank_ctrl <= not current_bank_ctrl after 10*PERIOD;
          addr_plus1_inc_ok <= false after 10*PERIOD,
                               true  after (CLOCKS_PER_ROW+10)*PERIOD;
        end if;
        if (conv_integer(unsigned(coadded_addr_i))=35-1) then
          current_bank       <= not current_bank      after 10*PERIOD;
          current_bank_fltr  <= not current_bank_fltr after 10*PERIOD;
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
        coadded_addr_i          <= coadded_addr_i  +1 after 10*PERIOD;
        if (conv_integer(unsigned(coadded_addr_i)) = 41-2) then
          current_bank_ctrl <= not current_bank_ctrl after 10*PERIOD;
          addr_plus1_inc_ok <= false after 10*PERIOD,
                               true  after (CLOCKS_PER_ROW+10)*PERIOD;
        end if;
        if (conv_integer(unsigned(coadded_addr_i))=41-1) then
          current_bank       <= not current_bank      after 10*PERIOD;
          current_bank_fltr  <= not current_bank_fltr after 10*PERIOD;
          coadded_addr_i <=(others => '0') after 10*PERIOD;
        end if;
      end loop;  -- i

      finish_phase2_testing <= true;

      
    end test_flux_loop_ctrl;
  
          
    
    ---------------------------------------------------------------------------
    -- 
    ---------------------------------------------------------------------------

  begin  -- process i_test


    ---------------------------------------------------------------------------
    -- Choose one of the next three modes:
    -- 1. Lock Mode
    -- 2. Constant Mode
    -- 3. Ramp Mode
    -- by (un)commenting the respective lines.
    -- Note that you need to comment out the selfcheck process if you are not using
    -- the Lock Mode.
    ---------------------------------------------------------------------------

 --lock mode
       cfg_test_mode(3, 0, 0, 0, 0,
                     servo_mode_i, ramp_step_size_i, ramp_amp_i,
                     num_ramp_frame_cycles_i, const_val_i);

    
 --ramp mode testing   
--           cfg_test_mode(2, 2, 5, 1, 2**CONST_VAL_WIDTH-1,
--                         servo_mode_i, ramp_step_size_i, ramp_amp_i,
--                         num_ramp_frame_cycles_i, const_val_i);

         -- const mode testing
--           cfg_test_mode(1, 0, 0, 0, 2**CONST_VAL_WIDTH-1,
--                         servo_mode_i, ramp_step_size_i, ramp_amp_i,
--                         num_ramp_frame_cycles_i, const_val_i);          
         
     cfg_pidz(calc_clk_i, 1,
               pq_wraddr_i, iq_wraddr_i, dq_wraddr_i, zq_wraddr_i,
               pq_wrdata_i, iq_wrdata_i, dq_wrdata_i, zq_wrdata_i,
               pq_wren_i, iq_wren_i, dq_wren_i, zq_wren_i);
     
    
    do_initialize;

    test_flux_loop_ctrl;
    finish_test_flux_loop_ctrl   <= true;

    wait for 56*FREE_RUN;              
    finish_tb1 <= true;                  -- Terminate the Test Bench
     
    report "End of Test";

    wait;

    
   
  end process i_test;


  

  -----------------------------------------------------------------------------
  -- Self check:
  -- This block generates:
  -- 1. Delays adc_coadd_en_i
  -- 2. Finds the expected coadded, integral, and differential and saves them
  -- in respective memory banks
  -- 3. Calculates the expected fsfb_calc outputs to fsfb_ctrl and fsfb_fltr
  -- and saves them in respective memory banks
  -- 4. self check by checking the expected values of case 3 with the real
  -- values.
  -- WARNING: This process must be commented out if Lock Mode is not used in
  -- the i_test process (see description of different modes in i_test process)
  -----------------------------------------------------------------------------


   i_check: process (clk_50_i, rst_i)
    
   begin  -- process i_check
     if rst_i = '1' then                 -- asynchronous reset (active high)
      
       adc_coadd_en_dly   <= (others => '0');
       found_filter_error <= false;
       found_ctrl_error   <= false;
       address_index      <= 0;
       coadded_value      <= 0;
       diff_value         <= 0;

       -- initialize memory banks
       for i in 0 to 63 loop
         integral_bank0(i) <= 0;
         integral_bank1(i) <= 0;
         coadd_bank0(i)    <= 0;
         coadd_bank1(i)    <= 0;
         filter_bank0(i)   <= 0;
         filter_bank1(i)   <= 0;
       end loop;  -- i
      
     elsif clk_50_i'event and clk_50_i = '1' then  -- rising clock edge

       address_index       <=  conv_integer(unsigned(coadded_addr_i));

       -- delay adc_coadd_en_i with 5 clocks. 5th element is used for
       -- calculation of PIDZ error value
       adc_coadd_en_dly(0)   <= adc_coadd_en_i;  
       for i in 1 to 5 loop
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


       -- calculate pidz error value
       if adc_coadd_en_dly(5) = '1' then
        case current_bank_fltr is
           when '0' =>
             if current_bank = '0' then
               filter_bank0(address_index) <= (conv_integer(signed(p_value(31 downto 0)))*coadd_bank0(address_index))
                                              +(conv_integer(signed(i_value(31 downto 0)))*integral_bank0(address_index))
                                              +(conv_integer(signed(d_value(31 downto 0)))*diff_value)
                                              +(conv_integer(signed(z_value(31 downto 0))));
              
             end if;
             if current_bank ='1' then
               filter_bank0(address_index) <= (conv_integer(signed(p_value(31 downto 0)))*coadd_bank1(address_index))
                                              +(conv_integer(signed(i_value(31 downto 0)))*integral_bank1(address_index))
                                              +(conv_integer(signed(d_value(31 downto 0)))*diff_value)
                                              +(conv_integer(signed(z_value(31 downto 0))));
              
             end if;

           when '1' =>
             if current_bank ='0' then
               filter_bank1(address_index) <= (conv_integer(signed(p_value(31 downto 0)))*coadd_bank0(address_index))
                                              +(conv_integer(signed(i_value(31 downto 0)))*integral_bank0(address_index))
                                              +(conv_integer(signed(d_value(31 downto 0)))*diff_value)
                                              +(conv_integer(signed(z_value(31 downto 0))));
              
             end if;
             if current_bank = '1' then
               filter_bank1(address_index) <= (conv_integer(signed(p_value(31 downto 0)))*coadd_bank1(address_index))
                                              +(conv_integer(signed(i_value(31 downto 0)))*integral_bank1(address_index))
                                              +(conv_integer(signed(d_value(31 downto 0)))*diff_value)
                                              +(conv_integer(signed(z_value(31 downto 0))));
              
             end if;
            
           when others => null;
         end case;
        
       end if;
      


       -- self check
       if finish_test_flux_loop_ctrl = false then
         -- selfcheck filter
         if fsfb_fltr_dat_rdy_o = '1' then
           case current_bank_fltr is
             when '0' =>
               if conv_integer(signed(fsfb_fltr_dat_o)) /= filter_bank0(address_index) then
                 found_filter_error <= true;
               end if;
             when '1' =>
               if conv_integer(signed(fsfb_fltr_dat_o)) /= filter_bank1(address_index) then
                 found_filter_error <= true;
               end if;
             when others => null;
           end case;
         end if;

         -- selfcheck controller
         if fsfb_ctrl_dat_rdy_o = '1' then
           case current_bank_ctrl is
             when '0' =>
               if initialize_window_i = '0' then
                 if conv_integer(signed(fsfb_ctrl_dat_o)) /= filter_bank0(address_index_plus1) then             
                   found_ctrl_error <= true;
                 end if;            
               end if;
             when '1' =>
               if initialize_window_i = '0' then
                 if conv_integer(signed(fsfb_ctrl_dat_o)) /= filter_bank1(address_index_plus1) then
                   found_ctrl_error <= true;
                 end if;            
               end if;            
           when others => null;
           end case;
        
         end if;
         assert (found_filter_error = false and found_ctrl_error = false)
           report "FAILED" severity FAILURE;
        
       end if;

      

      
        
     end if;
   end process i_check;


  -----------------------------------------------------------------------------
  -- Self Check for fsfb_ctrl block
  -- WARNING: Based on the values used for the generic values in the fsfb_ctrl,
  -- you need to adjust the check. 
  -----------------------------------------------------------------------------
  i_check_fsfb_ctrl: process (clk_50_i)
  begin  -- process i_check_fsfb_ctrl
    if dac_clk_o='1' then
      if finish_test_flux_loop_ctrl=false then

        -----------------------------------------------------------------------
        -- Modifiy acccording to polarity of the ADC and bit accuracy as shown
        -- in the generic value in the fsfb_ctrl.  These values default to 0
        -- and 13 respective, showing a straight polarity.
        -- So, choose one of the next three group statements
        -----------------------------------------------------------------------

        
         -- if straigh polarity is used in instantiating the fsfb_ctrl and bit
         -- 13 down to 0 of input data is used
         -- comment out if not in lock mode
           if ((not fsfb_ctrl_dat_o(13))&fsfb_ctrl_dat_o(12 downto 0)) /= dac_dat_o then
             found_dac_error <= true;
           end if;

        -- if reverse polarity is used in instantiating the fsfb_ctrl
        -- comment out if not in lock mode
--          if (fsfb_ctrl_dat_o(13) &(not fsfb_ctrl_dat_o(12 downto 0))) /= dac_dat_o then
--            found_dac_error <= true;
--          end if;

        -- comment out if in lock mode
--          if fsfb_ctrl_dat_o(13 downto 0) /= dac_dat_o then
--            found_dac_error <= true;
--          end if;
         
        
      end if;
      assert found_dac_error=false
        report "FAILED at DAC" severity FAILURE;
    end if;
  end process i_check_fsfb_ctrl;
  

end beh;


