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
-- flux_loop_ctrl_pack.vhd
--
-- Project:   SCUBA-2
-- Author:        Mohsen Nahvi & Anthony Ko
-- Organisation:  UBC
--
-- Description:
-- The package file for the flux_loop_ctrl.vhd file.
--
-- Revision history:
-- 
-- $Log: flux_loop_ctrl_pack.vhd,v $
-- Revision 1.4  2004/11/26 18:26:21  mohsen
-- Anthony & Mohsen: Restructured constant declaration.  Moved shared constants from lower level package files to the upper level ones.  This was done to resolve compilation error resulting from shared constants defined in multiple package files.
--
-- Revision 1.3  2004/11/17 01:02:18  anthonyk
-- Added sa_bias/offset ctrl component blocks
--
-- Revision 1.2  2004/11/08 23:59:03  mohsen
-- Sorted out parameters.  Also, added fsfb_ctrl.
--
-- Revision 1.1  2004/10/28 19:49:30  mohsen
-- created
--
--
--
------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;


library work;

-- Call Parent Library
use work.flux_loop_pack.all;
use work.readout_card_pack.all;

library sys_param;
use sys_param.wishbone_pack.all;


package flux_loop_ctrl_pack is

  
  -----------------------------------------------------------------------------
  -- Constants 
  -----------------------------------------------------------------------------

  -- ADC Sample Coadd Specific
  constant COADD_DAT_WIDTH        : integer := WB_DATA_WIDTH;          -- four bytes


  -- fsfb_cal Specific
  constant COADD_QUEUE_DATA_WIDTH : integer := WB_DATA_WIDTH;          -- data width of coadded data queue
  
  -- fsfb_ctrl Specific


  -- sa_bias_ctrl Specific
  constant SA_BIAS_DATA_WIDTH     : integer := 16;                     -- maximum data width of sa bias value determined by DAC device


  -- offset_ctrl Specific
  constant OFFSET_DATA_WIDTH      : integer := 16;                     -- maximum data width of offset value determined by DAC device
  
  
  -----------------------------------------------------------------------------
  -- ADC Sample Coadd Block
  -----------------------------------------------------------------------------

  component adc_sample_coadd
    port (
      adc_dat_i                 : in  std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
      adc_ovr_i                 : in  std_logic;
      adc_rdy_i                 : in  std_logic;
      adc_clk_o                 : out std_logic;
      clk_50_i                  : in  std_logic;
      rst_i                     : in  std_logic;
      adc_coadd_en_i            : in  std_logic;
      restart_frame_1row_prev_i : in  std_logic;
      restart_frame_aligned_i   : in  std_logic;
      row_switch_i              : in  std_logic;
      initialize_window_i       : in  std_logic;
      coadded_addr_i            : in  std_logic_vector (COADD_ADDR_WIDTH-1 downto 0);
      coadded_dat_o             : out std_logic_vector (COADD_DAT_WIDTH-1 downto 0);
      raw_addr_i                : in  std_logic_vector (RAW_ADDR_WIDTH-1 downto 0);
      raw_dat_o                 : out std_logic_vector (RAW_DAT_WIDTH-1 downto 0);
      raw_req_i                 : in  std_logic;
      raw_ack_o                 : out std_logic;
      coadd_done_o              : out std_logic;
      current_coadd_dat_o       : out std_logic_vector (COADD_DAT_WIDTH-1 downto 0);
      current_diff_dat_o        : out std_logic_vector (COADD_DAT_WIDTH-1 downto 0);
      current_integral_dat_o    : out std_logic_vector (COADD_DAT_WIDTH-1 downto 0);
      adc_offset_dat_i          : in  std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
      adc_offset_adr_o          : out std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0));
  end component;

 

  -----------------------------------------------------------------------------
  -- First Stage Feedback Calculation Block 
  -----------------------------------------------------------------------------

   component fsfb_calc is
      generic (
         start_val                  : integer;                                                     -- value read from the queue when initialize_window_i is asserted
         lock_dat_left              : integer                                                      -- most significant bit of lock mode result
         );
         
      port (
         rst_i                      : in    std_logic;                                             -- global reset
         clk_50_i                   : in    std_logic;                                             -- gobal clock 
         coadd_done_i               : in    std_logic;                                             -- done signal issued by coadd block to indicate coadd data valid (one-clk period pulse)
         current_coadd_dat_i        : in    std_logic_vector(COADD_QUEUE_DATA_WIDTH-1 downto 0);   -- current coadded value 
         current_diff_dat_i         : in    std_logic_vector(COADD_QUEUE_DATA_WIDTH-1 downto 0);   -- current difference
         current_integral_dat_i     : in    std_logic_vector(COADD_QUEUE_DATA_WIDTH-1 downto 0);   -- current integral
         restart_frame_aligned_i    : in    std_logic;                                             -- start of frame signal
         restart_frame_1row_post_i  : in    std_logic;                                             -- start of frame signal (1 row behind of actual frame start)
         row_switch_i               : in    std_logic;                                             -- row switch signal to indicate next clock cycle is the beginning of new row
         initialize_window_i        : in    std_logic;                                             -- frame window at which all values read equal to fixed preset parameter
         num_rows_sub1_i            : in    std_logic_vector(FSFB_QUEUE_ADDR_WIDTH-1 downto 0);    -- number of rows per frame subtract 1
         servo_mode_i               : in    std_logic_vector(SERVO_MODE_SEL_WIDTH-1 downto 0);     -- servo mode selection 
         ramp_step_size_i           : in    std_logic_vector(RAMP_STEP_WIDTH-1 downto 0);          -- ramp step increments/decrements
         ramp_amp_i                 : in    std_logic_vector(RAMP_AMP_WIDTH-1 downto 0);           -- ramp peak amplitude
         const_val_i                : in    std_logic_vector(CONST_VAL_WIDTH-1 downto 0);          -- fs feedback constant value
         num_ramp_frame_cycles_i    : in    std_logic_vector(RAMP_CYC_WIDTH-1 downto 0);           -- number of frame cycle ramp remained level 
         p_addr_o                   : out   std_logic_vector(COEFF_QUEUE_ADDR_WIDTH-1 downto 0);   -- coefficient queue address/data inputs/outputs 
         p_dat_i                    : in    std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);   -- read-only operations
         i_addr_o                   : out   std_logic_vector(COEFF_QUEUE_ADDR_WIDTH-1 downto 0); 
         i_dat_i                    : in    std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);
         d_addr_o                   : out   std_logic_vector(COEFF_QUEUE_ADDR_WIDTH-1 downto 0); 
         d_dat_i                    : in    std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);
         flux_quanta_addr_o         : out   std_logic_vector(COEFF_QUEUE_ADDR_WIDTH-1 downto 0); 
         flux_quanta_dat_i          : in    std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);
         fsfb_ws_addr_i             : in    std_logic_vector(FSFB_QUEUE_ADDR_WIDTH-1 downto 0);    -- fs feedback queue previous address/data inputs/outputs
         fsfb_ws_dat_o              : out   std_logic_vector(WB_DATA_WIDTH-1 downto 0);            -- read-only operations
         fsfb_fltr_dat_rdy_o        : out   std_logic;                                             -- fs feedback queue current data ready 
         fsfb_fltr_dat_o            : out   std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0);    -- fs feedback queue current data 
         num_flux_quanta_pres_rdy_i : in    std_logic;                                             -- flux quanta present count ready
         num_flux_quanta_pres_i     : in    std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);    -- flux quanta present count    
         fsfb_ctrl_dat_rdy_o        : out   std_logic;                                             -- fs feedback queue previous data ready (uncorrected)
                                                                                                   -- the rdy pulse is also good for num_flux_quanta_prev    
         fsfb_ctrl_dat_o            : out   std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0);    -- fs feedback queue previous data (uncorrected)
         num_flux_quanta_prev_o     : out   std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);    -- flux quanta previous count        
         fsfb_ctrl_lock_en_o        : out   std_logic;                                             -- fs feedback lock servo mode enable
         flux_jumping_en_i          : in    std_logic;
         flux_quanta_o              : out   std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0)    -- flux quanta value (formerly know as coeff z)
      );
   end component fsfb_calc;


  -----------------------------------------------------------------------------
  -- First Stage Feedback Control Block
  -----------------------------------------------------------------------------

  component fsfb_ctrl
    generic (
      CONVERSION_POLARITY_MODE : integer);
    port (
      clk_50_i            : in  std_logic;
      rst_i               : in  std_logic;
      dac_dat_en_i        : in  std_logic;
      fsfb_ctrl_dat_i     : in  std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
      fsfb_ctrl_dat_rdy_i : in  std_logic;
      fsfb_ctrl_lock_en_i : in  std_logic;
      dac_dat_o           : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
      dac_clk_o           : out std_logic);
  end component;


   -----------------------------------------------------------------------------
   -- Offset Control Block
   -----------------------------------------------------------------------------

   component offset_ctrl
      port ( 
         rst_i                     : in     std_logic;                                             -- global reset
         clk_25_i                  : in     std_logic;                                             -- global clock (25 MHz)
         clk_50_i                  : in     std_logic;                                             -- global clock (50 MHz)
         restart_frame_aligned_i   : in     std_logic;                                             -- start of frame signal (50 MHz domain)
         offset_dat_i              : in     std_logic_vector(WB_DATA_WIDTH-1 downto 0);            -- parallel offset data input value from wishbone feedback data
         offset_dac_spi_o          : out    std_logic_vector(OFFSET_SPI_DATA_WIDTH-1 downto 0)     -- serial offset data output value, clock and chip select
      );
   end component offset_ctrl;


   -----------------------------------------------------------------------------
   -- SA Bias Control Block
   -----------------------------------------------------------------------------
  
   component sa_bias_ctrl
      port ( 
         rst_i                     : in     std_logic;                                             -- global reset
         clk_25_i                  : in     std_logic;                                             -- global clock (25 MHz)
         clk_50_i                  : in     std_logic;                                             -- global clock (50 MHz)
         restart_frame_aligned_i   : in     std_logic;                                             -- start of frame signal (50 MHz domain)
         sa_bias_dat_i             : in     std_logic_vector(WB_DATA_WIDTH-1 downto 0);            -- parallel sa bias data input value from wishbone feedback data
         sa_bias_dac_spi_o         : out    std_logic_vector(SA_BIAS_SPI_DATA_WIDTH-1 downto 0)    -- serial sa bias data output value, clock and chip select
       );   
    end component sa_bias_ctrl;
  
  
  
end flux_loop_ctrl_pack;

