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
-- flux_loop_ctrl.vhd
--
-- Project:	  SCUBA-2
-- Author:        Mohsen Nahvi & Anthony Ko
-- Organisation:  UBC
--
-- Description:
-- 
-- The flux_loop_ctrl is instantiated 8 times inside flux_loop on the Readout
-- Card. This block operates on a single feedback path between a readout ADC
-- and a Feedback DAC of the same channel.  Nominally, each flux_loop_ctrl
-- block will lock First-Stage SQUIDs at their operating point, and record
-- data from the SQUIDs for reporting to the outside world. All digital
-- communication between the Realtime Linux PCs and the flux_loop_ctrl block
-- takes place through the Wishbone Interface Frame Data and Feedback Data.

--
--
--
-- Revision history:
-- 
-- $Log: flux_loop_ctrl.vhd,v $
-- Revision 1.6  2004/12/07 19:43:33  mohsen
-- Anthony & Mohsen: Accomodate the sa_bias & offset DAC shared bus structure in the readout card hardware.
--
-- Revision 1.5  2004/11/26 18:26:21  mohsen
-- Anthony & Mohsen: Restructured constant declaration.  Moved shared constants from lower level package files to the upper level ones.  This was done to resolve compilation error resulting from shared constants defined in multiple package files.
--
-- Revision 1.4  2004/11/24 23:34:00  mohsen
-- Change in wbs_fb_data Interface
--
-- Revision 1.3  2004/11/17 01:02:18  anthonyk
-- Added sa_bias/offset ctrl component blocks
--
-- Revision 1.2  2004/11/08 23:58:33  mohsen
-- Sorted out parameters.  Also, added fsfb_ctrl.
--
-- Revision 1.1  2004/10/28 19:49:30  mohsen
-- created
--
-- Revision 1.1  2004/10/22 00:14:37  mohsen
-- Created
--
--
------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library work;

-- Own Library Call
use work.flux_loop_ctrl_pack.all;

-- Parent Library Call
use work.flux_loop_pack.all;
use work.readout_card_pack.all;

library sys_param;
use sys_param.wishbone_pack.all;



entity flux_loop_ctrl is

  

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
    


end flux_loop_ctrl;



architecture struct of flux_loop_ctrl is

  -- signals from adc_sample_coadd
  signal coadd_done              : std_logic;
  signal current_coadd_dat       : std_logic_vector (31 downto 0);
  signal current_diff_dat        : std_logic_vector (31 downto 0);
  signal current_integral_dat    : std_logic_vector (31 downto 0);

  -- signals from fsfb_calc
  signal fsfb_ctrl_dat           : std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0);
  signal fsfb_ctrl_dat_rdy       : std_logic;
  signal fsfb_ctrl_lock_en       : std_logic;
  


begin  -- struct

  -----------------------------------------------------------------------------
  -- Instantiate ADC Sample Coadd
  -----------------------------------------------------------------------------
  i_adc_sample_coadd : adc_sample_coadd

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
    coadd_done_o              => coadd_done,
    current_coadd_dat_o       => current_coadd_dat,
    current_diff_dat_o        => current_diff_dat,
    current_integral_dat_o    => current_integral_dat,
    adc_offset_dat_i          => adc_offset_dat_i,
    adc_offset_adr_o          => adc_offset_adr_o);



  -----------------------------------------------------------------------------
  -- Instantiate FSFB Calculation Block
  -----------------------------------------------------------------------------
  i_fsfb_calc : fsfb_calc

    generic map (
    start_val => 0)

    port map (
      rst_i                     => rst_i,
      clk_50_i                  => clk_50_i,
      coadd_done_i              => coadd_done,
      current_coadd_dat_i       => current_coadd_dat,
      current_diff_dat_i        => current_diff_dat,
      current_integral_dat_i    => current_integral_dat,
      restart_frame_aligned_i   => restart_frame_aligned_i,
      restart_frame_1row_post_i => restart_frame_1row_post_i,
      row_switch_i              => row_switch_i,
      initialize_window_i       => initialize_window_i,
      num_rows_sub1_i           => num_rows_sub1_i,
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
      fsfb_ws_addr_i            => fsfb_addr_i,
      fsfb_ws_dat_o             => fsfb_dat_o,
      fsfb_fltr_dat_rdy_o       => fsfb_fltr_dat_rdy_o,
      fsfb_fltr_dat_o           => fsfb_fltr_dat_o,
      fsfb_ctrl_dat_rdy_o       => fsfb_ctrl_dat_rdy,
      fsfb_ctrl_dat_o           => fsfb_ctrl_dat,
      fsfb_ctrl_lock_en_o       => fsfb_ctrl_lock_en);

  -- bring out the internal outputs
  fsfb_ctrl_dat_rdy_o <= fsfb_ctrl_dat_rdy;
  fsfb_ctrl_dat_o     <= fsfb_ctrl_dat;


  -----------------------------------------------------------------------------
  -- Instantiation of fsfb_ctrl
  -----------------------------------------------------------------------------
  i_fsfb_ctrl: fsfb_ctrl
    
    generic map (
        CONVERSION_POLARITY_MODE => 0,
        FSFB_ACCURACY_POSITION   => 13)
    
    port map (
        clk_50_i            => clk_50_i,
        rst_i               => rst_i,
        dac_dat_en_i        => dac_dat_en_i,
        fsfb_ctrl_dat_i     => fsfb_ctrl_dat,
        fsfb_ctrl_dat_rdy_i => fsfb_ctrl_dat_rdy,
        fsfb_ctrl_lock_en_i => fsfb_ctrl_lock_en,
        dac_dat_o           => dac_dat_o,
        dac_clk_o           => dac_clk_o);


  -----------------------------------------------------------------------------
  -- Instantiation of offset_ctrl
  -----------------------------------------------------------------------------
  i_offset_ctrl : offset_ctrl
     port map (
        rst_i                   => rst_i,
        clk_25_i                => clk_25_i,
        clk_50_i                => clk_50_i,
        restart_frame_aligned_i => restart_frame_1row_prev_i,
        offset_dat_i            => offset_dat_i,
        offset_dac_spi_o        => offset_dac_spi_o
        );

  -----------------------------------------------------------------------------
  -- Instantiation of sa_bias_ctrl
  -----------------------------------------------------------------------------

  -- NOTE: During the readout_card block development, it was found that the
  -- data and the clock signals for offset_ctrl and sa_bias_ctrl DACs are tied
  -- together.  Therfore, we need to ensure that the operation of offset_ctrl
  -- and sa_bias_ctrl are mutually exclusive.  Here, we use a simple method to
  -- achieve this mutually exclusive behaviour by using
  -- restart_frame_1row_post_i in place of restart_frame_aligned_i in sa_bias_
  -- ctrl. Since the operation of each of these blocks take 46 clk_50 period,
  -- the minimum row dwell time need to satisfy this condition.  Otherwise,
  -- other method is necessary.
  
  i_sa_bias_ctrl : sa_bias_ctrl
     port map (
        rst_i                   => rst_i,
        clk_25_i                => clk_25_i,
        clk_50_i                => clk_50_i,
        restart_frame_aligned_i => restart_frame_1row_post_i,
        sa_bias_dat_i           => sa_bias_dat_i,
        sa_bias_dac_spi_o       => sa_bias_dac_spi_o
        ); 
        
end struct;

