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
-- tb2_flux_loop_ctrl.vhd
--
-- Project:   SCUBA-2
-- Author:        Mohsen Nahvi & Anthony Ko
-- Organisation:  UBC
--
-- Description:
-- This testbench tests the integration of three blocks within flux_loop_ctrl.
-- These blocks are: adc_sample_coadd, fsfb_calc, and fsfb_ctrl.  The 
-- frame_timing signals are provided to the testbench by instantiating the 
-- frame_timing library component. 
-- 
-- This testbench is for: 
-- 
-- Lock Mode: where fsfb_calc gets the values from adc_sample_coadd and
-- outputs PIDZ error values.
-- For the Lock Mode, we perform a selfcheck. The selfcheck relies on a random
-- value generated block(LFSR) to assign values  to adc_dat_i.
--
-- The following operation is performed:
-- 
-- We write a new piece of data to adc_dat_i on the FALLING edge of the clk
-- to mimick the data coming from A/D.  Note that data from A/D is ready on the
-- falling edge of adc_en_clk. Moreover, we configure the PIDZ coefficient
-- queues for calculating the PIDZ error value in lock mode and select the
-- servo lock mode.
--
--
-- Revision history:
-- 
-- $Log: tb2_flux_loop_ctrl.vhd,v $
-- Revision 1.11  2005/12/12 23:45:15  mandana
-- Interfaces updated with latest flux-jump and filter features added, so the testbench compiles. But the testbench has to be updated later to test the newly added features.
--
-- Revision 1.10  2005/09/14 23:48:39  bburger
-- bburger:
-- Integrated flux-jumping into flux_loop
--
-- Revision 1.9  2004/12/17 00:39:46  anthonyk
-- Number of clock cycles per row requirement is now changed to accomodate the increased latency of the shared pidz multiplier scheme.
--
-- Revision 1.8  2004/12/07 19:44:57  mohsen
-- Anthony & Mohsen: Miscellanous updates
--
-- Revision 1.7  2004/11/26 18:26:21  mohsen
-- Anthony & Mohsen: Restructured constant declaration.  Moved shared constants from lower level package files to the upper level ones.  This was done to resolve compilation error resulting from shared constants defined in multiple package files.
--
-- Revision 1.6  2004/11/25 00:32:58  mohsen
-- Modified frame_timing and sync_gen  to frame_timing_core and sync_gen_core and updated the interface.  Note that frame_timing has gone through major revision, where it now consists of "core" and "wbs" blocks.  The frame_timing_core is used for simple test benches, whereas the frame_timing is used in test benches that use issu/reply chain.
--
-- Revision 1.5  2004/11/24 23:33:45  mohsen
-- Change in wbs_fb_data Interface
--
-- Revision 1.4  2004/11/19 23:21:43  anthonyk
-- Added various sa_bias/offset ctrl related changes including automated check for sa_bias/offset ctrl blocks
--
-- Revision 1.3  2004/11/15 20:03:41  bburger
-- Bryce :  Moved frame_timing to the 'work' library, and physically moved the files to "all_cards" directory
--
-- Revision 1.2  2004/11/08 23:57:11  mohsen
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

-- used for PIDZ queue instantiation
use work.fsfb_calc_pack.all;

-- used for FSFB_MAX and FSFB_MIN
use work.fsfb_corr_pack.all;


-- DUT Library Call
use work.flux_loop_ctrl_pack.all;


-- library for flux_loop_ctrl
use work.flux_loop_pack.all;
use work.readout_card_pack.all;

-- library for frame timing core
use work.frame_timing_core_pack.all;

-- library for sync gen core
use work.sync_gen_core_pack.all;


entity tb2_flux_loop_ctrl is
  
end tb2_flux_loop_ctrl;


architecture beh of tb2_flux_loop_ctrl is



  component flux_loop_ctrl
  port (
     -- ADC interface signals
     adc_dat_i                  : in  std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
     adc_ovr_i                  : in  std_logic;
     adc_rdy_i                  : in  std_logic;
     adc_clk_o                  : out std_logic;
 
     -- Global signals 
     clk_50_i                   : in  std_logic;
     clk_25_i                   : in  std_logic;
     rst_i                      : in  std_logic;
  
     -- Frame timing signals
     adc_coadd_en_i             : in  std_logic;
     restart_frame_1row_prev_i  : in  std_logic;
     restart_frame_aligned_i    : in  std_logic;
     restart_frame_1row_post_i  : in  std_logic;
     row_switch_i               : in  std_logic;
     initialize_window_i        : in  std_logic;
     num_rows_sub1_i            : in  std_logic_vector(FSFB_QUEUE_ADDR_WIDTH-1 downto 0);    -- number of rows per frame subtract 1
     dac_dat_en_i               : in  std_logic;
 
     -- Wishbone Slave (wbs) Frame Data signals
     coadded_addr_i             : in  std_logic_vector (COADD_ADDR_WIDTH-1 downto 0);
     coadded_dat_o              : out std_logic_vector (WB_DATA_WIDTH-1 downto 0);
     raw_addr_i                 : in  std_logic_vector (RAW_ADDR_WIDTH-1 downto 0);
     raw_dat_o                  : out std_logic_vector (RAW_DATA_WIDTH-1 downto 0);
     raw_req_i                  : in  std_logic;
     raw_ack_o                  : out std_logic;
 
     fsfb_addr_i                : in  std_logic_vector(FSFB_QUEUE_ADDR_WIDTH-1 downto 0);    -- fs feedback queue previous address/data inputs/outputs
     fsfb_dat_o                 : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);            -- read-only operations
     filtered_addr_i            : in  std_logic_vector(5 downto 0);
     filtered_dat_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
 
     
     -- Wishbove Slave (wbs) Feedback (fb) Data Signals
     adc_offset_dat_i           : in  std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
     adc_offset_adr_o           : out std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0);
 
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
     offset_dat_i               : in  std_logic_vector(WB_DATA_WIDTH-1 downto 0);
     filter_coeff0_i            : in  std_logic_vector(WB_DATA_WIDTH-1 downto 0);
     filter_coeff1_i            : in  std_logic_vector(WB_DATA_WIDTH-1 downto 0);
     filter_coeff2_i            : in  std_logic_vector(WB_DATA_WIDTH-1 downto 0);
     filter_coeff3_i            : in  std_logic_vector(WB_DATA_WIDTH-1 downto 0);
     filter_coeff4_i            : in  std_logic_vector(WB_DATA_WIDTH-1 downto 0);
     filter_coeff5_i            : in  std_logic_vector(WB_DATA_WIDTH-1 downto 0);
     filter_coeff6_i            : in  std_logic_vector(WB_DATA_WIDTH-1 downto 0);
     
     -- DAC Interface
     dac_dat_o                  : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
     dac_clk_o                  : out std_logic;
 
     -- spi DAC Interface
     sa_bias_dac_spi_o          : out std_logic_vector(SA_BIAS_SPI_DATA_WIDTH-1 downto 0);
     offset_dac_spi_o           : out std_logic_vector(OFFSET_SPI_DATA_WIDTH-1 downto 0);
 

     -- fsfb_calc Interface
     fsfb_fltr_dat_rdy_o        : out std_logic;                                             -- fs feedback queue current data ready 
     fsfb_fltr_dat_o            : out std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0);    -- fs feedback queue current data 
     fsfb_ctrl_dat_o            : out std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0);    -- fs feedback queue previous data (uncorrected)
     fsfb_ctrl_dat_rdy_o        : out std_logic;                                             -- fs feedback queue previous data ready (uncorrected).  The rdy pulse is also good for num_flux_quanta_prev    
     fsfb_ctrl_lock_en_o        : out std_logic;                                             -- fs feedback lock servo mode enable
     num_flux_quanta_prev_o     : out std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);    -- flux quanta previous count            
     num_flux_quanta_pres_rdy_i : in  std_logic;                                             -- flux quanta present count ready
     num_flux_quanta_pres_i     : in  std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);    -- flux quanta present count    
     flux_jumping_en_i          : in std_logic;
     flux_quanta_o              : out std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);   -- flux quanta value (formerly known as coeff z)
 
     -- to fsfb_ctrl block
     fsfb_ctrl_dat_rdy_i        : in  std_logic;                                             -- fsfb control data ready (corrected)
     fsfb_ctrl_dat_i            : in  std_logic_vector(DAC_DAT_WIDTH-1 downto 0)             -- fsfb control data (corrected)
    
  );
  end component;

  -----------------------------------------------------------------------------
  -- First Stage Feedback Correction Block (for Flux Jumping)
  -----------------------------------------------------------------------------

  component fsfb_corr        
  port (
     -- fsfb_calc interface
     flux_jumping_en_i          : in std_logic;
     fsfb_ctrl_lock_en_i        : in std_logic;
     
     flux_quanta0_i             : in std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0); -- Z
     flux_quanta1_i             : in std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0); -- Z
     flux_quanta2_i             : in std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0); -- Z
     flux_quanta3_i             : in std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0); -- Z
     flux_quanta4_i             : in std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0); -- Z
     flux_quanta5_i             : in std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0); -- Z
     flux_quanta6_i             : in std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0); -- Z
     flux_quanta7_i             : in std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0); -- Z
     
     num_flux_quanta_prev0_i    : in std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); 
     num_flux_quanta_prev1_i    : in std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); 
     num_flux_quanta_prev2_i    : in std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); 
     num_flux_quanta_prev3_i    : in std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); 
     num_flux_quanta_prev4_i    : in std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); 
     num_flux_quanta_prev5_i    : in std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); 
     num_flux_quanta_prev6_i    : in std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); 
     num_flux_quanta_prev7_i    : in std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); 
     
     fsfb_ctrl_dat0_i           : in std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0); -- pid_prev
     fsfb_ctrl_dat1_i           : in std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0); -- pid_prev
     fsfb_ctrl_dat2_i           : in std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0); -- pid_prev
     fsfb_ctrl_dat3_i           : in std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0); -- pid_prev
     fsfb_ctrl_dat4_i           : in std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0); -- pid_prev
     fsfb_ctrl_dat5_i           : in std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0); -- pid_prev
     fsfb_ctrl_dat6_i           : in std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0); -- pid_prev
     fsfb_ctrl_dat7_i           : in std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0); -- pid_prev
     
     fsfb_ctrl_dat_rdy0_i       : in std_logic;
     fsfb_ctrl_dat_rdy1_i       : in std_logic;
     fsfb_ctrl_dat_rdy2_i       : in std_logic;
     fsfb_ctrl_dat_rdy3_i       : in std_logic;
     fsfb_ctrl_dat_rdy4_i       : in std_logic;
     fsfb_ctrl_dat_rdy5_i       : in std_logic;
     fsfb_ctrl_dat_rdy6_i       : in std_logic;
     fsfb_ctrl_dat_rdy7_i       : in std_logic;
     
     num_flux_quanta_pres0_o    : out std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- m_pres
     num_flux_quanta_pres1_o    : out std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- m_pres
     num_flux_quanta_pres2_o    : out std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- m_pres
     num_flux_quanta_pres3_o    : out std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- m_pres
     num_flux_quanta_pres4_o    : out std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- m_pres
     num_flux_quanta_pres5_o    : out std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- m_pres
     num_flux_quanta_pres6_o    : out std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- m_pres
     num_flux_quanta_pres7_o    : out std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- m_pres
     
     num_flux_quanta_pres_rdy_o : out std_logic;
     
     -- fsfb_ctrl interface
     fsfb_ctrl_dat0_o           : out  std_logic_vector(DAC_DAT_WIDTH-1 downto 0); -- pid_corr_prev
     fsfb_ctrl_dat1_o           : out  std_logic_vector(DAC_DAT_WIDTH-1 downto 0); -- pid_corr_prev
     fsfb_ctrl_dat2_o           : out  std_logic_vector(DAC_DAT_WIDTH-1 downto 0); -- pid_corr_prev
     fsfb_ctrl_dat3_o           : out  std_logic_vector(DAC_DAT_WIDTH-1 downto 0); -- pid_corr_prev
     fsfb_ctrl_dat4_o           : out  std_logic_vector(DAC_DAT_WIDTH-1 downto 0); -- pid_corr_prev
     fsfb_ctrl_dat5_o           : out  std_logic_vector(DAC_DAT_WIDTH-1 downto 0); -- pid_corr_prev
     fsfb_ctrl_dat6_o           : out  std_logic_vector(DAC_DAT_WIDTH-1 downto 0); -- pid_corr_prev
     fsfb_ctrl_dat7_o           : out  std_logic_vector(DAC_DAT_WIDTH-1 downto 0); -- pid_corr_prev
     fsfb_ctrl_dat_rdy_o        : out  std_logic;
     
     -- Global Signals      
     clk_i                      : in std_logic;
     rst_i                      : in std_logic);     
  end component;

   -- pidz queue component declaration
   -- This is only a test component used by the testbench
   --
   component pidz_queue is
      port (
         data        : in    std_logic_vector(32 downto 0);    
         wraddress   : in    std_logic_vector(5 downto 0);
         rdaddress_a : in    std_logic_vector(5 downto 0);
         rdaddress_b : in    std_logic_vector(5 downto 0);
         wren        : in    std_logic;
         clock       : in    std_logic;
         qa          : out   std_logic_vector(32 downto 0);
         qb          : out   std_logic_vector(32 downto 0)
      );
   end component pidz_queue;  
 
  -- flux_loop_ctrl signals
  signal adc_dat_i                 : std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
  signal adc_ovr_i                 : std_logic;
  signal adc_rdy_i                 : std_logic;
  signal adc_clk_o                 : std_logic;
  signal clk_50_i                  : std_logic;
  signal clk_50n_i                 : std_logic;
  signal clk_25_i                  : std_logic;
  signal rst_i                     : std_logic :='1';
  signal adc_coadd_en_i            : std_logic :='0';
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
  signal raw_dat_o                 : std_logic_vector (RAW_DATA_WIDTH-1 downto 0);
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
  signal fsfb_fltr_dat_o           : std_logic_vector(FLTR_QUEUE_DATA_WIDTH-1 downto 0);    -- fs feedback queue current data 
                                                                                            -- the rdy pulse is also good for num_flux_quanta_prev    

  -- Signals Interface between fsfb_corr and flux_loop_ctrl
  signal fsfb_ctrl_lock_en         : std_logic;   
  signal flux_jumping_en           : std_logic := '1';
  signal num_flux_quanta_pres_rdy  : std_logic;                                             
  signal fsfb_ctrl_corr_rdy        : std_logic;                                                
  
  signal flux_quanta0              : std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);   
  signal fsfb_ctrl_dat0            : std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0);    
  signal num_flux_quanta_prev0     : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);    
  signal num_flux_quanta_pres0     : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);    
  signal fsfb_ctrl_dat0_rdy        : std_logic;                                             
  signal fsfb_ctrl_corr0           : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);             

  signal flux_quanta1              : std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0) := (others => '0');   
  signal fsfb_ctrl_dat1            : std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0) := (others => '0');    
  signal num_flux_quanta_prev1     : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0) := (others => '0');    
  signal num_flux_quanta_pres1     : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);    
  signal fsfb_ctrl_dat1_rdy        : std_logic;                                             
  signal fsfb_ctrl_corr1           : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);             

  signal flux_quanta2              : std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0) := (others => '0');   
  signal fsfb_ctrl_dat2            : std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0) := (others => '0');    
  signal num_flux_quanta_prev2     : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0) := (others => '0');    
  signal num_flux_quanta_pres2     : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);    
  signal fsfb_ctrl_dat2_rdy        : std_logic;                                             
  signal fsfb_ctrl_corr2           : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);             

  signal flux_quanta3              : std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0) := (others => '0');   
  signal fsfb_ctrl_dat3            : std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0) := (others => '0');    
  signal num_flux_quanta_prev3     : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0) := (others => '0');    
  signal num_flux_quanta_pres3     : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);    
  signal fsfb_ctrl_dat3_rdy        : std_logic;                                             
  signal fsfb_ctrl_corr3           : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);             

  signal flux_quanta4              : std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0) := (others => '0');   
  signal fsfb_ctrl_dat4            : std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0) := (others => '0');    
  signal num_flux_quanta_prev4     : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0) := (others => '0');    
  signal num_flux_quanta_pres4     : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);    
  signal fsfb_ctrl_dat4_rdy        : std_logic;                                             
  signal fsfb_ctrl_corr4           : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);             

  signal flux_quanta5              : std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0) := (others => '0');   
  signal fsfb_ctrl_dat5            : std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0) := (others => '0');    
  signal num_flux_quanta_prev5     : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0) := (others => '0');    
  signal num_flux_quanta_pres5     : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);    
  signal fsfb_ctrl_dat5_rdy        : std_logic;                                             
  signal fsfb_ctrl_corr5           : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);             

  signal flux_quanta6              : std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0) := (others => '0');   
  signal fsfb_ctrl_dat6            : std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0) := (others => '0');    
  signal num_flux_quanta_prev6     : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0) := (others => '0');    
  signal num_flux_quanta_pres6     : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);    
  signal fsfb_ctrl_dat6_rdy        : std_logic;                                             
  signal fsfb_ctrl_corr6           : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);             

  signal flux_quanta7              : std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0) := (others => '0');   
  signal fsfb_ctrl_dat7            : std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0) := (others => '0');    
  signal num_flux_quanta_prev7     : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0) := (others => '0');    
  signal num_flux_quanta_pres7     : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);    
  signal fsfb_ctrl_dat7_rdy        : std_logic;                                             
  signal fsfb_ctrl_corr7           : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);             

  -- tb2 signals
  constant PERIOD                  : time := 20 ns;
  constant EDGE_DEPENDENCY         : time := 2 ns;  --shows clk edge dependency
  constant RESET_WINDOW            : time := 8*PERIOD;
  constant FREE_RUN                : time := 19*PERIOD;
  constant CLOCKS_PER_ROW          : integer := 64;
  constant ROWS_PER_FRAME          : integer := 41;

  signal reset_window_done          : boolean := false;
  signal finish_tb2                 : boolean := false;  -- asserted to end tb
  signal finish_test_flux_loop_ctrl : boolean := false;
  


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
  signal filter_bank1 : memory_bank;      -- same as bank0 
  
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
  signal address_index_plus1  : integer :=1;  -- points to row in memory
  signal addr_plus1_inc_ok    : boolean := true;  -- flags wrap around for address_index_plus1
  signal init_window_req_i    : std_logic :='0';
  signal resync_req_i         : std_logic :='0';
  signal clk_200_i            : std_logic;
  signal sync                 : std_logic;
  
  -- offset/sa_bias ctrl test signals
  signal pdata1          : std_logic_vector(15 downto 0)   := (others => '0');     -- parallel data (SA_Bias)
  signal pdata2          : std_logic_vector(15 downto 0)   := (others => '0');     -- parallel data (Offset)  
  signal sc_data1        : std_logic_vector(15 downto 0);                          -- serial captured data (SA_Bias)
  signal sc_data2        : std_logic_vector(15 downto 0);                          -- serial captured data (Offset)
  signal pc_data1        : std_logic_vector(15 downto 0);                          -- parallel captured data (SA_Bias)
  signal pc_data2        : std_logic_vector(15 downto 0);                          -- parallel captured data (Offset)
  
  -- temporary integers
  signal dac_clk1 : std_logic;
  signal dac_clk2 : std_logic;
  signal dac_clk3 : std_logic;
  signal dac_clk4 : std_logic;
  signal m_pres : integer;
  signal corr_pid : integer;
  signal corr_pid_slv : std_logic_vector(31 downto 0) := (others => '0');
  signal corr_pid_slv_14 : std_logic_vector(13 downto 0) := (others => '0');

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
    adc_dat_i                  => adc_dat_i,
    adc_ovr_i                  => adc_ovr_i,
    adc_rdy_i                  => adc_rdy_i,
    adc_clk_o                  => adc_clk_o,
    clk_50_i                   => clk_50_i,
    clk_25_i                   => clk_25_i,
    rst_i                      => rst_i,
    adc_coadd_en_i             => adc_coadd_en_i,
    restart_frame_1row_prev_i  => restart_frame_1row_prev_i,
    restart_frame_aligned_i    => restart_frame_aligned_i,
    restart_frame_1row_post_i  => restart_frame_1row_post_i,
    row_switch_i               => row_switch_i,
    initialize_window_i        => initialize_window_i,
    num_rows_sub1_i            => num_rows_sub1_i,
    dac_dat_en_i               => dac_dat_en_i,
    coadded_addr_i             => coadded_addr_i,
    coadded_dat_o              => coadded_dat_o,
    raw_addr_i                 => raw_addr_i,
    raw_dat_o                  => raw_dat_o,
    raw_req_i                  => raw_req_i,
    raw_ack_o                  => raw_ack_o,
    fsfb_addr_i                => fsfb_ws_addr_i,
    fsfb_dat_o                 => fsfb_ws_dat_o,
    filtered_addr_i            => filtered_addr_i,
    filtered_dat_o             => filtered_dat_o,
    adc_offset_dat_i           => adc_offset_dat_i,
    adc_offset_adr_o           => adc_offset_adr_o,
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
    flux_quanta_addr_o         => z_addr_o,
    flux_quanta_dat_i          => z_dat_i,
    sa_bias_dat_i              => sa_bias_dat_i,
    offset_dat_i               => offset_dat_i,
    filter_coeff0_i            => filter_coeff0_i,
    filter_coeff1_i            => filter_coeff1_i,
    filter_coeff2_i            => filter_coeff2_i,
    filter_coeff3_i            => filter_coeff3_i,
    filter_coeff4_i            => filter_coeff4_i,
    filter_coeff5_i            => filter_coeff5_i,
    filter_coeff6_i            => filter_coeff6_i,
    dac_dat_o                  => dac_dat_o,
    dac_clk_o                  => dac_clk_o,
    sa_bias_dac_spi_o          => sa_bias_dac_spi_o,
    offset_dac_spi_o           => offset_dac_spi_o,
    fsfb_fltr_dat_rdy_o        => fsfb_fltr_dat_rdy_o,
    fsfb_fltr_dat_o            => fsfb_fltr_dat_o,
    num_flux_quanta_pres_rdy_i => num_flux_quanta_pres_rdy,
    num_flux_quanta_pres_i     => num_flux_quanta_pres0,    
    fsfb_ctrl_dat_rdy_i        => fsfb_ctrl_corr_rdy,
    fsfb_ctrl_dat_i            => fsfb_ctrl_corr0,
    fsfb_ctrl_dat_rdy_o        => fsfb_ctrl_dat0_rdy,
    fsfb_ctrl_dat_o            => fsfb_ctrl_dat0,
    num_flux_quanta_prev_o     => num_flux_quanta_prev0,
    fsfb_ctrl_lock_en_o        => fsfb_ctrl_lock_en,
    flux_jumping_en_i          => flux_jumping_en,
    flux_quanta_o              => flux_quanta0);

  
  -----------------------------------------------------------------------------
  -- Instantiation of fsfb_corr
  -----------------------------------------------------------------------------
  
  i_fsfb_corr: fsfb_corr
    port map (
      -- fsfb_calc interface
      flux_jumping_en_i          => flux_jumping_en,
      fsfb_ctrl_lock_en_i        => fsfb_ctrl_lock_en,
      
      flux_quanta0_i             => flux_quanta0,
      flux_quanta1_i             => flux_quanta1,
      flux_quanta2_i             => flux_quanta2,
      flux_quanta3_i             => flux_quanta3,
      flux_quanta4_i             => flux_quanta4,
      flux_quanta5_i             => flux_quanta5,
      flux_quanta6_i             => flux_quanta6,
      flux_quanta7_i             => flux_quanta7,
      
      num_flux_quanta_prev0_i    => num_flux_quanta_prev0,
      num_flux_quanta_prev1_i    => num_flux_quanta_prev1,
      num_flux_quanta_prev2_i    => num_flux_quanta_prev2,
      num_flux_quanta_prev3_i    => num_flux_quanta_prev3,
      num_flux_quanta_prev4_i    => num_flux_quanta_prev4,
      num_flux_quanta_prev5_i    => num_flux_quanta_prev5,
      num_flux_quanta_prev6_i    => num_flux_quanta_prev6,
      num_flux_quanta_prev7_i    => num_flux_quanta_prev7,
      
      fsfb_ctrl_dat0_i           => fsfb_ctrl_dat0,
      fsfb_ctrl_dat1_i           => fsfb_ctrl_dat1,
      fsfb_ctrl_dat2_i           => fsfb_ctrl_dat2,
      fsfb_ctrl_dat3_i           => fsfb_ctrl_dat3,
      fsfb_ctrl_dat4_i           => fsfb_ctrl_dat4,
      fsfb_ctrl_dat5_i           => fsfb_ctrl_dat5,
      fsfb_ctrl_dat6_i           => fsfb_ctrl_dat6,
      fsfb_ctrl_dat7_i           => fsfb_ctrl_dat7,
      
      -- For now, we are testing a single channel
      -- For fsfb_corr to start manipulating data, all rdy signals need to be asserted
      fsfb_ctrl_dat_rdy0_i       => fsfb_ctrl_dat0_rdy,
      fsfb_ctrl_dat_rdy1_i       => fsfb_ctrl_dat0_rdy,
      fsfb_ctrl_dat_rdy2_i       => fsfb_ctrl_dat0_rdy,
      fsfb_ctrl_dat_rdy3_i       => fsfb_ctrl_dat0_rdy,
      fsfb_ctrl_dat_rdy4_i       => fsfb_ctrl_dat0_rdy,
      fsfb_ctrl_dat_rdy5_i       => fsfb_ctrl_dat0_rdy,
      fsfb_ctrl_dat_rdy6_i       => fsfb_ctrl_dat0_rdy,
      fsfb_ctrl_dat_rdy7_i       => fsfb_ctrl_dat0_rdy,
      
      num_flux_quanta_pres0_o    => num_flux_quanta_pres0,
      num_flux_quanta_pres1_o    => num_flux_quanta_pres1,
      num_flux_quanta_pres2_o    => num_flux_quanta_pres2,
      num_flux_quanta_pres3_o    => num_flux_quanta_pres3,
      num_flux_quanta_pres4_o    => num_flux_quanta_pres4,
      num_flux_quanta_pres5_o    => num_flux_quanta_pres5,
      num_flux_quanta_pres6_o    => num_flux_quanta_pres6,
      num_flux_quanta_pres7_o    => num_flux_quanta_pres7,
      
      num_flux_quanta_pres_rdy_o => num_flux_quanta_pres_rdy,
      
      -- fsfb_ctrl interface
      fsfb_ctrl_dat0_o           => fsfb_ctrl_corr0,
      fsfb_ctrl_dat1_o           => fsfb_ctrl_corr1,
      fsfb_ctrl_dat2_o           => fsfb_ctrl_corr2,
      fsfb_ctrl_dat3_o           => fsfb_ctrl_corr3,
      fsfb_ctrl_dat4_o           => fsfb_ctrl_corr4,
      fsfb_ctrl_dat5_o           => fsfb_ctrl_corr5,
      fsfb_ctrl_dat6_o           => fsfb_ctrl_corr6,
      fsfb_ctrl_dat7_o           => fsfb_ctrl_corr7,
      fsfb_ctrl_dat_rdy_o        => fsfb_ctrl_corr_rdy,
      
      -- Global Signals      
      clk_i                      => clk_50_i,
      rst_i                      => rst_i
    );

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

   p_queue : pidz_queue 
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

   i_queue : pidz_queue 
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

   d_queue : pidz_queue 
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

   z_queue : pidz_queue 
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
  -- Instantiate frame_timing_core
  -----------------------------------------------------------------------------
  i_frame_timing_core : frame_timing_core

    port map (
    dac_dat_en_o              => dac_dat_en_i,
    adc_coadd_en_o            => adc_coadd_en_i,
    restart_frame_1row_prev_o => restart_frame_1row_prev_i,
    restart_frame_aligned_o   => restart_frame_aligned_i,
    restart_frame_1row_post_o => restart_frame_1row_post_i,
    initialize_window_o       => initialize_window_i,
    row_switch_o              => row_switch_i,
    row_en_o                  => open,
    update_bias_o             => open,
    row_len_i                 => 64,
    num_rows_i                => 41,
    sample_delay_i            => 10,
    sample_num_i              => 40,
    feedback_delay_i          => 6,
    address_on_delay_i        => 4,
    resync_req_i              => resync_req_i,
    resync_ack_o              => open,
    init_window_req_i         => init_window_req_i,
    init_window_ack_o         => open,
    clk_i                     => clk_50_i,
    clk_n_i                   => clk_50n_i,
    rst_i                     => rst_i,
    sync_i                    => sync);
    
 
  -----------------------------------------------------------------------------
  -- Instantiate sync_gen_core
  -----------------------------------------------------------------------------
  i_sync_gen_core : sync_gen_core

    port map (
    dv_en_i    => '0',
    row_len_i  => 64,
    num_rows_i => 41,
    dv_i       => '0',
    sync_o     => sync,
    sync_num_o => open,
    clk_i      => clk_50_i,
    rst_i      => rst_i);

  
  -----------------------------------------------------------------------------
  -- Clocking
  -----------------------------------------------------------------------------

  clocking_200: process
  begin  -- process clocking

    clk_200_i <= '1';
    wait for PERIOD/2;
    
    while (not finish_tb2) loop
      clk_200_i <= not clk_200_i;
      wait for PERIOD/2;
    end loop;

    wait;
    
  end process clocking_200;
 
  
  clocking_50: process
  begin  -- process clocking

    clk_50_i <= '1';
    clk_50n_i <= '0';
    wait for PERIOD/2;
    
    while (not finish_tb2) loop
      clk_50_i <= not clk_50_i;
      clk_50n_i <= not clk_50n_i;
      wait for PERIOD/2;
    end loop;

    wait;
    
  end process clocking_50;

  clocking_25: process
  begin  -- process clocking

    clk_25_i <= '1';
    wait for PERIOD;
    
    while (not finish_tb2) loop
      clk_25_i <= not clk_25_i;
      wait for PERIOD;
    end loop;

    wait;
    
  end process clocking_25;
  
  -----------------------------------------------------------------------------
  -- Request for initialize window and resync_req (resync_req is temporary)
  -----------------------------------------------------------------------------

  i_initialize_window: process
  begin  -- process i_initialize_window
    wait for RESET_WINDOW + EDGE_DEPENDENCY;
    wait for FREE_RUN;

    resync_req_i      <= '1',
                         '0' after PERIOD;          
    
    while (not finish_test_flux_loop_ctrl) loop
      
      wait for CLOCKS_PER_ROW*PERIOD*3;
        init_window_req_i <= '1',
                             '0' after PERIOD;                                                
      wait for CLOCKS_PER_ROW*PERIOD*5000;
        init_window_req_i <= '1',
                             '0' after PERIOD;
      wait for CLOCKS_PER_ROW*PERIOD*300;
     
    end loop;

    
    wait for FREE_RUN;

    ---------------------------------------------------------------------------
    -- Go to sleep
    ---------------------------------------------------------------------------
    
    wait;
        
  end process i_initialize_window;


  
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
      current_bank            <= '0';
      
      wait for 113 ns;
      rst_i <= '0';
      wait for RESET_WINDOW - 113 ns;   -- alligne with clk

      reset_window_done <= true;
    end do_initialize;


    ---------------------------------------------------------------------------
    -- Generates bank selection for testbench coadd, filter, and control to be
    -- used in the selfcheck process.
    ---------------------------------------------------------------------------

    procedure gen_tb_bank_sel is
    begin
 

      wait until falling_edge(restart_frame_aligned_i);


      for i in 1 to 200*41 loop            
        wait for 8*PERIOD;
        wait for 25*PERIOD;
        wait for (CLOCKS_PER_ROW-25-8)*PERIOD;      
        coadded_addr_i          <= coadded_addr_i  +1 after 13*PERIOD;
        if (conv_integer(unsigned(coadded_addr_i)) = 41-2) then
          current_bank_ctrl <= not current_bank_ctrl after 11*PERIOD;
          addr_plus1_inc_ok <= false after 13*PERIOD,
                               true  after (CLOCKS_PER_ROW+13)*PERIOD;
        end if;
        if (conv_integer(unsigned(coadded_addr_i))=41-1) then
          current_bank       <= not current_bank      after 14*PERIOD;
          current_bank_fltr  <= not current_bank_fltr after 14*PERIOD;
          coadded_addr_i <=(others => '0' ) after 13*PERIOD;
        end if;
 
      end loop;  -- i

       
      wait for PERIOD;

      
    end gen_tb_bank_sel;

          
    
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

             
    cfg_pidz(calc_clk_i, 1,
               pq_wraddr_i, iq_wraddr_i, dq_wraddr_i, zq_wraddr_i,
               pq_wrdata_i, iq_wrdata_i, dq_wrdata_i, zq_wrdata_i,
               pq_wren_i, iq_wren_i, dq_wren_i, zq_wren_i);
     
    
    do_initialize;

    gen_tb_bank_sel;
    finish_test_flux_loop_ctrl   <= true;

    wait for 56*FREE_RUN;              
    finish_tb2 <= true;                  -- Terminate the Test Bench
     
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
  -----------------------------------------------------------------------------

  i_check: process (clk_50_i, rst_i)
  
  variable test_filter : std_logic_vector(65 downto 0);
  variable test_ctrl   : std_logic_vector(65 downto 0);
    
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

      address_index <=  conv_integer(unsigned(coadded_addr_i));

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
          if initialize_window_i = '0' then
            integral_bank0(address_index) <=  coadded_value +
                                              integral_bank1(address_index);
            diff_value <=  coadded_value - coadd_bank1(address_index);
          else                          -- ignore previous values
-- Bryce:  ***There may be a bug here.  I think that the running integral and diff values need to be cleared - instead of skipping a value.
            integral_bank0(address_index) <=  coadded_value + 0;
            diff_value <=  coadded_value - 0;
            
          end if;
        end if;
        
        if current_bank = '1' then
          coadd_bank1(address_index) <= coadded_value;
          if initialize_window_i = '0' then
            integral_bank1(address_index) <=  coadded_value +
                                              integral_bank0(address_index);
            diff_value <=  coadded_value - coadd_bank0(address_index);
          else                          -- ingore previous values
          integral_bank1(address_index) <=  coadded_value + 0;
          diff_value <=  coadded_value - 0;
          end if;
        end if;

        coadded_value <= 0;
         
      end if;


      -- calculate pidz error value
      if adc_coadd_en_dly(5) = '1' then
        -- Anthony is cheating a little bit here.  He only waits 14 cycles before switching the bank filter.  I guess this helps the simulation finish a little faster.
        case current_bank_fltr is
          when '0' =>
            if current_bank = '0' then  -- use proper bank for coadd/intgral
              filter_bank0(address_index) <= (conv_integer(signed(p_value(31 downto 0)))*coadd_bank0(address_index))
                                             +(conv_integer(signed(i_value(31 downto 0)))*integral_bank0(address_index))
                                             +(conv_integer(signed(d_value(31 downto 0)))*diff_value);
            end if;
            if current_bank ='1' then
              filter_bank0(address_index) <= (conv_integer(signed(p_value(31 downto 0)))*coadd_bank1(address_index))
                                             +(conv_integer(signed(i_value(31 downto 0)))*integral_bank1(address_index))
                                             +(conv_integer(signed(d_value(31 downto 0)))*diff_value);
              
            end if;

          when '1' =>
            if current_bank ='0' then
              filter_bank1(address_index) <= (conv_integer(signed(p_value(31 downto 0)))*coadd_bank0(address_index))
                                             +(conv_integer(signed(i_value(31 downto 0)))*integral_bank0(address_index))
                                             +(conv_integer(signed(d_value(31 downto 0)))*diff_value);
              
            end if;
            if current_bank = '1' then
              filter_bank1(address_index) <= (conv_integer(signed(p_value(31 downto 0)))*coadd_bank1(address_index))
                                             +(conv_integer(signed(i_value(31 downto 0)))*integral_bank1(address_index))
                                             +(conv_integer(signed(d_value(31 downto 0)))*diff_value);
            
            end if;
            
          when others => null;
        end case;
      end if;
    end if;
  end process i_check;

  dac_clk_delay : process (clk_50_i, rst_i)
  begin
     if (rst_i = '1') then
        dac_clk1 <= '0';
        dac_clk2 <= '0';
        dac_clk3 <= '0';
        dac_clk4 <= '0';
     elsif (clk_50_i'event and clk_50_i = '1') then
        dac_clk4 <= dac_clk3;
        dac_clk3 <= dac_clk2;
        dac_clk2 <= dac_clk1;
        dac_clk1 <= dac_clk_o;
     end if;
  end process dac_clk_delay;  
  
  -----------------------------------------------------------------------------
  -- Self Check for fsfb_ctrl block
  -- WARNING: Based on the values used for the generic values in the fsfb_ctrl,
  -- you need to adjust the check. 
  -----------------------------------------------------------------------------
  i_check_fsfb_ctrl: process (clk_50_i)
  begin  -- process i_check_fsfb_ctrl
     if (clk_50_i'event and clk_50_i = '1') then
        -- I think that the reason that dac_clk never goes high is because flux_loop_ctrl is not being fed a fsfb_ctrl_dat0_rdy signal.
        -- Once I integrate the fsfb_corr block in this testbench, that will be taken care of.
        if (finish_test_flux_loop_ctrl=false and fsfb_ctrl_lock_en = '1') then
           
           if (dac_clk_o = '1') then
              if (conv_integer(signed(fsfb_ctrl_dat0(FSFB_QUEUE_DATA_WIDTH-1 downto LSB_WINDOW_INDEX))) - (conv_integer(signed(num_flux_quanta_prev0)) * conv_integer(signed(flux_quanta0))) > FSFB_MAX) then
                 m_pres <= conv_integer(signed(num_flux_quanta_prev0)) + 1;
              elsif (conv_integer(signed(fsfb_ctrl_dat0(FSFB_QUEUE_DATA_WIDTH-1 downto LSB_WINDOW_INDEX))) - (conv_integer(signed(num_flux_quanta_prev0)) * conv_integer(signed(flux_quanta0))) < FSFB_MIN) then
                 m_pres <= conv_integer(signed(num_flux_quanta_prev0)) - 1;
              else
                 m_pres <= conv_integer(signed(num_flux_quanta_prev0));
              end if;
           
           elsif (dac_clk1 = '1') then
              corr_pid <= conv_integer(signed(fsfb_ctrl_dat0(FSFB_QUEUE_DATA_WIDTH-1 downto LSB_WINDOW_INDEX))) - (m_pres * conv_integer(signed(flux_quanta0)));
              
           elsif (dac_clk2 = '1') then
              corr_pid_slv <= std_logic_vector(conv_signed(corr_pid, 32));

           elsif (dac_clk3 = '1') then
              -- This conversion is due to an obscure feature in the fsfb_ctrl block that switches the polarity of the 14-bit value depending on whether the feedback require positive feedback or negative feedback.  For now it is negative.
              corr_pid_slv_14 <= not corr_pid_slv(13) & corr_pid_slv(12 downto 0);

           elsif (dac_clk4 = '1') then
              --report "Doing FSFB Comparison";
              if (corr_pid_slv_14 /= dac_dat_o) then
                 found_dac_error <= true;
              end if;

              assert found_dac_error=false report "FAILED at DAC" severity FAILURE;

           end if;

        end if;
     end if;
  end process i_check_fsfb_ctrl;
  
  
  -------------------------------------------------------------------------------
  -- Offset/SA Bias control blocks testing
  -------------------------------------------------------------------------------
  
  -- Zero-padded parallel_data to 32 bits
     
  sa_bias_dat_i <= x"0000" & pdata1;
  offset_dat_i  <= x"0000" & pdata2;
     
     
  -- Generate the stimulus
     
  stimulus : process
  begin
     wait until restart_frame_aligned_i ='1';
     -- Increment the parallel data at about midway of each frame
     -- This allows the sampling of parallel data for comparison with serial
     -- data by not allowing any changes close to the restart_frame_aligned_i
     wait for 0.5*PERIOD*CLOCKS_PER_ROW*ROWS_PER_FRAME;
     pdata1 <= pdata1 + 1;
     pdata2 <= pdata2 + 256;
  end process stimulus;
     
     
  -- Capture the serial data for comparison
        
  scapture1 : process (sa_bias_dac_spi_o, rst_i)
  begin
     if (rst_i = '1') then
        sc_data1 <= (others => '0');
     elsif (sa_bias_dac_spi_o(1)'event and sa_bias_dac_spi_o(1) = '1') then
        if (sa_bias_dac_spi_o(2) = '0') then
           sc_data1(0) <= sa_bias_dac_spi_o(0);
           sc_data1(15 downto 1) <= sc_data1(14 downto 0);
        end if;
     end if;
  end process scapture1;
  
  scapture2 : process (offset_dac_spi_o, rst_i)
  begin
     if (rst_i = '1') then
        sc_data2 <= (others => '0');
     elsif (offset_dac_spi_o(1)'event and offset_dac_spi_o(1) = '1') then
        if (offset_dac_spi_o(2) = '0') then
           sc_data2(0) <= offset_dac_spi_o(0);
           sc_data2(15 downto 1) <= sc_data2(14 downto 0);
        end if;
     end if;
  end process scapture2;
  
        
  -- Capture the parallel data input for comparison
     
  pcapture : process (clk_50_i, rst_i)
  begin
     if (rst_i = '1') then
        pc_data1 <= (others => '0');
        pc_data2 <= (others => '0');
     elsif (clk_50_i'event and clk_50_i = '1') then
        if (restart_frame_1row_post_i = '1') then
           pc_data1 <= pdata1;
        end if;
        if (restart_frame_1row_prev_i = '1') then
           pc_data2 <= pdata2;
        end if;
     end if;
  end process pcapture;
        
        
  -- Comparison (Automated check)
        
  compare1 : process(sa_bias_dac_spi_o)
  begin
     if finish_test_flux_loop_ctrl=false then
        if (sa_bias_dac_spi_o(2)'event and sa_bias_dac_spi_o(2) = '1') then
           assert (sc_data1 = pc_data1) 
           report "SA_Bias_Ctrl:  Serial Data Output /= Parallel Data Input"
           severity FAILURE;
        end if;
     end if;
  end process compare1;
  
  compare2 : process(offset_dac_spi_o)
  begin
     if finish_test_flux_loop_ctrl=false then
        if (offset_dac_spi_o(2)'event and offset_dac_spi_o(2) = '1') then
           assert (sc_data2 = pc_data2) 
           report "Offset_Ctrl:  Serial Data Output /= Parallel Data Input"
           severity FAILURE;
        end if;
     end if;
  end process compare2;
  

end beh;


