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
-- Project:   SCUBA-2
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
-- Revision 1.21  2012-10-30 19:11:07  mandana
-- only renaming signals for clarity
--
-- Revision 1.20  2012-01-23 20:53:25  mandana
-- added qterm to interfaces
--
-- Revision 1.19  2010-11-30 19:45:58  mandana
-- filter_coeff ports reduced to filter_coef_width instead of wb_data_width to help fitting in EP1S40.
-- reorganized pack files and moved fsfb definitions here to stay compliant with hierarchical pack files
--
-- Revision 1.18  2010-11-13 00:36:01  mandana
-- added filtr_coeff interface
--
-- Revision 1.17  2010/03/12 20:46:21  bburger
-- BB: added i_clamp_val interface signals, and changed lock_dat_left to lock_dat_lsb
--
-- Revision 1.16.2.1  2009/11/13 20:04:02  bburger
-- BB: Added i-term clamp interface signals and removed the lock_dat_left generic
--
-- Revision 1.16  2009/05/27 01:25:04  bburger
-- BB: Added raw-data components, new to v5.x from 4.0.d
--
-- Revision 1.15  2009/03/19 21:49:16  bburger
-- BB:
-- - Added the ADC_LATENCY generic to generalize this block for Readout Card Rev. C
-- - Removed unused signals adc_ovr_i, adc_rdy_i, adc_clk_o from interface
--
-- Revision 1.14  2007/10/31 20:12:01  mandana
-- sa_bias_rdy and offset_dat_rdy signals are added to the interface to notify controller blocks when these are updated
--
-- Revision 1.13  2006/02/15 21:35:14  mandana
-- added fltr_rst_i
--
-- Revision 1.12  2005/12/12 22:24:26  mandana
-- removed the unused flux_jumping_en_i port
-- changed fsfb_fltr_dat_o port definition to fltr_queue_data_width-1
-- changed lock_dat_left position
--
-- Revision 1.11  2005/11/29 19:18:30  mandana
-- filter wishbone interface added
--
-- Revision 1.10  2005/10/07 21:38:07  bburger
-- Bryce:  Added a port between fsfb_io_controller and wbs_frame_data to readout flux_counts
--
-- Revision 1.9  2005/09/14 23:48:39  bburger
-- bburger:
-- Integrated flux-jumping into flux_loop
--
-- Revision 1.8  2005/03/18 01:24:08  mohsen
-- shifted the accuracy position to 23.  This essentially divides the input from the upstream block by 1024(2^23-13) when
-- the upstream is in lock mode.
--
-- Revision 1.7  2004/12/24 01:07:54  mohsen
-- need to slow down dac clock, so require 2 row times between sa_bias and offset write trigger.
--
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
generic (ADC_LATENCY         : integer);
port (
   -- ADC interface signals
   adc_dat_i                  : in  std_logic_vector (ADC_DAT_WIDTH-1 downto 0);

   -- Global signals 
   clk_50_i                   : in  std_logic;
   clk_25_i                   : in  std_logic;
   rst_i                      : in  std_logic;
 
   i_clamp_val_i              : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   qterm_decay_bits_i         : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);   

   -- Frame timing signals
   adc_coadd_en_i             : in  std_logic;
   restart_frame_1row_prev_i  : in  std_logic;
   restart_frame_aligned_i    : in  std_logic;
   restart_frame_1row_post_i  : in  std_logic;
   row_switch_i               : in  std_logic;
   initialize_window_i        : in  std_logic;
   servo_rst_window_i         : in  std_logic;
   fltr_rst_i                 : in  std_logic;                                             -- reset internal registers (wn) of the filter block
   num_rows_sub1_i            : in  std_logic_vector(FSFB_QUEUE_ADDR_WIDTH-1 downto 0);    -- number of rows per frame subtract 1
   dac_dat_en_i               : in  std_logic;

   -- Wishbone Slave (wbs) Frame Data signals
   coadded_addr_i             : in  std_logic_vector (COADD_ADDR_WIDTH-1 downto 0);
   coadded_dat_o              : out std_logic_vector (WB_DATA_WIDTH-1 downto 0);
 
   fsfb_addr_i                : in  std_logic_vector(FSFB_QUEUE_ADDR_WIDTH-1 downto 0);    -- fs feedback queue previous address/data inputs/outputs
   fsfb_dat_o                 : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);            -- read-only operations
   flux_cnt_ws_dat_o          : out std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
   filtered_addr_i            : in  std_logic_vector(FSFB_QUEUE_ADDR_WIDTH-1 downto 0);    -- filter queue address for wishbone access (read only)
   filtered_dat_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);            -- read-only operations for filter queue wishbone access
   
   -- Wishbove Slave (wbs) Feedback (fb) Data Signals
   adc_offset_dat_i           : in  std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
   adc_offset_adr_o           : out std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0);
   servo_rst_dat_i            : in  std_logic;
   servo_rst_addr_o           : out std_logic_vector(SERVO_RST_ADDR_WIDTH-1 downto 0);

   servo_mode_i               : in  std_logic_vector(SERVO_MODE_SEL_WIDTH-1 downto 0);     -- servo mode selection 
   ramp_step_size_i           : in  std_logic_vector(RAMP_STEP_WIDTH-1 downto 0);          -- ramp step increments/decrements
   ramp_amp_i                 : in  std_logic_vector(RAMP_AMP_WIDTH-1 downto 0);           -- ramp peak amplitude
   const_val_i                : in  std_logic_vector(CONST_VAL_WIDTH-1 downto 0);          -- fs feedback constant value
   num_ramp_frame_cycles_i    : in  std_logic_vector(RAMP_CYC_WIDTH-1 downto 0);           -- number of frame cycle ramp remained level 
   p_addr_o                   : out std_logic_vector(COEFF_QUEUE_ADDR_WIDTH-1 downto 0);   -- coefficient queue address/data inputs/outputs 
   p_dat_i                    : in  std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);   -- read-only operations
   i_addr_o                   : out std_logic_vector(COEFF_QUEUE_ADDR_WIDTH-1 downto 0); 
   i_dat_i                    : in  std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);
   d_addr_o                   : out std_logic_vector(COEFF_QUEUE_ADDR_WIDTH-1 downto 0); 
   d_dat_i                    : in  std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);
   flux_quanta_addr_o         : out std_logic_vector(COEFF_QUEUE_ADDR_WIDTH-1 downto 0); 
   flux_quanta_dat_i          : in  std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);
   sa_bias_dat_i              : in  std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   sa_bias_dat_rdy_i          : in  std_logic;
   offset_dat_i               : in  std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   offset_dat_rdy_i           : in  std_logic;
   filter_coeff0_i            : in  std_logic_vector(FILTER_COEF_WIDTH-1 downto 0);
   filter_coeff1_i            : in  std_logic_vector(FILTER_COEF_WIDTH-1 downto 0);
   filter_coeff2_i            : in  std_logic_vector(FILTER_COEF_WIDTH-1 downto 0);
   filter_coeff3_i            : in  std_logic_vector(FILTER_COEF_WIDTH-1 downto 0);
   filter_coeff4_i            : in  std_logic_vector(FILTER_COEF_WIDTH-1 downto 0);
   filter_coeff5_i            : in  std_logic_vector(FILTER_COEF_WIDTH-1 downto 0);
   filter_coeff6_i            : in  std_logic_vector(FILTER_COEF_WIDTH-1 downto 0);
   
   -- DAC Interface
   dac_dat_o                  : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
   dac_clk_o                  : out std_logic;

   -- spi DAC Interface
   sa_bias_dac_spi_o          : out std_logic_vector(SA_BIAS_SPI_DATA_WIDTH-1 downto 0);
   offset_dac_spi_o           : out std_logic_vector(OFFSET_SPI_DATA_WIDTH-1 downto 0);
  
   -- fsfb_calc Interface
   fsfb_fltr_dat_rdy_o        : out std_logic;                                             -- fsfb filter data ready 
   fsfb_fltr_dat_o            : out std_logic_vector(FLTR_QUEUE_DATA_WIDTH-1 downto 0);    -- fsfb filter data
   fsfb_ctrl_dat_o            : out std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0);    -- fs feedback queue previous data (uncorrected)
   fsfb_ctrl_dat_rdy_o        : out std_logic;                                             -- fs feedback queue previous data ready (uncorrected).  The rdy pulse is also good for num_flux_quanta_prev    
   fsfb_ctrl_lock_en_o        : out std_logic;                                             -- fs feedback lock servo mode enable
    
   fj_count_o                 : out std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);    -- flux quanta previous count            
   fj_count_rdy_i             : in  std_logic;                                             -- flux quanta present count ready
   fj_count_i                 : in  std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);    -- flux quanta present count    
   flux_quanta_o              : out std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);   -- flux quanta value (formerly known as coeff z)

   -- fsfb_ctrl Interface
   fsfb_ctrl_dat_rdy_i        : in  std_logic;                                             -- fsfb control data ready (corrected)
   fsfb_ctrl_dat_i            : in  std_logic_vector(DAC_DAT_WIDTH-1 downto 0)             -- fsfb control data (corrected)

); 
end flux_loop_ctrl;



architecture struct of flux_loop_ctrl is

   -- signals from adc_sample_coadd
   signal coadd_done              : std_logic;
   signal current_coadd_dat       : std_logic_vector (31 downto 0);
   signal current_diff_dat        : std_logic_vector (31 downto 0);
   signal current_integral_dat    : std_logic_vector (31 downto 0);
   signal current_qterm_dat       : std_logic_vector (31 downto 0);  -- it really has to be COADD_DAT_WIDTH!!

   -- signals from fsfb_calc
   signal fsfb_ctrl_lock_en       : std_logic;
   


begin  -- struct

   -----------------------------------------------------------------------------
   -- Instantiate ADC Sample Coadd
   -----------------------------------------------------------------------------
   i_adc_sample_coadd : adc_sample_coadd
   generic map (ADC_LATENCY => ADC_LATENCY)
   port map (
      adc_dat_i                 => adc_dat_i,
      clk_50_i                  => clk_50_i,
      rst_i                     => rst_i,
      i_clamp_val_i             => i_clamp_val_i,
      qterm_decay_bits_i        => qterm_decay_bits_i,
      adc_coadd_en_i            => adc_coadd_en_i,
      restart_frame_1row_prev_i => restart_frame_1row_prev_i,
      restart_frame_aligned_i   => restart_frame_aligned_i,
      row_switch_i              => row_switch_i,
      initialize_window_i       => initialize_window_i,
      servo_rst_window_i        => servo_rst_window_i,
      coadded_addr_i            => coadded_addr_i,
      coadded_dat_o             => coadded_dat_o,
      coadd_done_o              => coadd_done,
      current_coadd_dat_o       => current_coadd_dat,
      current_diff_dat_o        => current_diff_dat,
      current_integral_dat_o    => current_integral_dat,
      current_qterm_dat_o       => current_qterm_dat,
      adc_offset_dat_i          => adc_offset_dat_i,
      adc_offset_adr_o          => adc_offset_adr_o,
      servo_rst_dat_i           => servo_rst_dat_i,
      servo_rst_addr_o          => servo_rst_addr_o     
   );
   

   -----------------------------------------------------------------------------
   -- Instantiate FSFB Calculation Block
   -----------------------------------------------------------------------------
   i_fsfb_calc : fsfb_calc
   generic map (
      start_val => 0,
      lock_dat_lsb => LOCK_LSB_POS)
   port map (
      rst_i                      => rst_i,
      clk_50_i                   => clk_50_i,
      coadd_done_i               => coadd_done,
      current_coadd_dat_i        => current_coadd_dat,
      current_diff_dat_i         => current_diff_dat,
      current_integral_dat_i     => current_integral_dat,
      current_qterm_dat_i        => current_qterm_dat,
      restart_frame_aligned_i    => restart_frame_aligned_i,
      restart_frame_1row_post_i  => restart_frame_1row_post_i,
      row_switch_i               => row_switch_i,
      initialize_window_i        => initialize_window_i,
      fltr_rst_i                 => fltr_rst_i,
      num_rows_sub1_i            => num_rows_sub1_i,
      servo_mode_i               => servo_mode_i,
      ramp_step_size_i           => ramp_step_size_i,
      ramp_amp_i                 => ramp_amp_i,
      const_val_i                => const_val_i,
      num_ramp_frame_cycles_i    => num_ramp_frame_cycles_i,
      p_addr_o                   => p_addr_o,
      p_dat_i                    => p_dat_i,
      i_addr_o                   => i_addr_o,
      i_dat_i                    => i_dat_i,
      d_addr_o                   => d_addr_o,
      d_dat_i                    => d_dat_i,
      flux_quanta_addr_o         => flux_quanta_addr_o,
      flux_quanta_dat_i          => flux_quanta_dat_i,
      filter_coeff0_i            => filter_coeff0_i,
      filter_coeff1_i            => filter_coeff1_i,
      filter_coeff2_i            => filter_coeff2_i,
      filter_coeff3_i            => filter_coeff3_i,
      filter_coeff4_i            => filter_coeff4_i,
      filter_coeff5_i            => filter_coeff5_i,

      fsfb_ws_fltr_addr_i        => filtered_addr_i,
      fsfb_ws_fltr_dat_o         => filtered_dat_o,
      fsfb_ws_addr_i             => fsfb_addr_i,
      fsfb_ws_dat_o              => fsfb_dat_o,
      flux_cnt_ws_dat_o          => flux_cnt_ws_dat_o,

      fsfb_fltr_dat_rdy_o        => fsfb_fltr_dat_rdy_o,
      fsfb_fltr_dat_o            => fsfb_fltr_dat_o,
      fsfb_ctrl_dat_rdy_o        => fsfb_ctrl_dat_rdy_o,
      fsfb_ctrl_dat_o            => fsfb_ctrl_dat_o,
      fsfb_ctrl_lock_en_o        => fsfb_ctrl_lock_en,

      num_flux_quanta_pres_rdy_i => fj_count_rdy_i,
      num_flux_quanta_pres_i     => fj_count_i,
      num_flux_quanta_prev_o     => fj_count_o,
      flux_quanta_o              => flux_quanta_o
   );

   -- bring out the internal fsfb_ctrl_lock_en signal to the fsfb_corr block
   fsfb_ctrl_lock_en_o <= fsfb_ctrl_lock_en;
    

   -----------------------------------------------------------------------------
   -- Instantiation of fsfb_ctrl
   -----------------------------------------------------------------------------
   i_fsfb_ctrl: fsfb_ctrl
   generic map (
      CONVERSION_POLARITY_MODE => 0
      --FSFB_ACCURACY_POSITION   => 13
   )
   port map (
      clk_50_i            => clk_50_i,
      rst_i               => rst_i,
      dac_dat_en_i        => dac_dat_en_i,
      fsfb_ctrl_dat_i     => fsfb_ctrl_dat_i,
      fsfb_ctrl_dat_rdy_i => fsfb_ctrl_dat_rdy_i,
      fsfb_ctrl_lock_en_i => fsfb_ctrl_lock_en,
      dac_dat_o           => dac_dat_o,
      dac_clk_o           => dac_clk_o
   );


   -----------------------------------------------------------------------------
   -- Instantiation of offset_ctrl
   -----------------------------------------------------------------------------
   i_offset_ctrl : offset_ctrl
   port map (
      rst_i                   => rst_i,
      clk_25_i                => clk_25_i,
      clk_50_i                => clk_50_i,
      restart_frame_aligned_i => restart_frame_1row_prev_i,
      offset_dat_rdy_i        => offset_dat_rdy_i,
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
      sa_bias_dat_rdy_i       => sa_bias_dat_rdy_i,
      sa_bias_dat_i           => sa_bias_dat_i,
      sa_bias_dac_spi_o       => sa_bias_dac_spi_o
   ); 
         
end struct;

