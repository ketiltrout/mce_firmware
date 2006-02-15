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
-- flux_loop_pack.vhd
--
-- Project:   SCUBA-2
-- Author:        Mohsen Nahvi & Anthony Ko
-- Organisation:  UBC
--
-- Description:
-- The package file for the flux_loop.vhd file.
--
--
-- Revision history:
-- 
-- $Log: flux_loop_pack.vhd,v $
-- Revision 1.8  2005/12/12 22:20:03  mandana
-- removed the unused flux_jumping_en_i port
-- changed fsfb_fltr_dat_o port definition to fltr_queue_data_width-1
--
-- Revision 1.7  2005/11/29 18:33:52  mandana
-- added filter queue storage parameters
--
-- Revision 1.6  2005/11/28 19:11:29  bburger
-- Bryce:  increased the bus width for fb_const, ramp_dly, ramp_amp and ramp_step from 14 bits to 32 bits, to use them for flux-jumping testing
--
-- Revision 1.5  2005/10/07 21:38:07  bburger
-- Bryce:  Added a port between fsfb_io_controller and wbs_frame_data to readout flux_counts
--
-- Revision 1.4  2005/09/14 23:48:39  bburger
-- bburger:
-- Integrated flux-jumping into flux_loop
--
-- Revision 1.3  2005/04/29 18:14:59  bburger
-- Bryce:  added FLUX_QUANTA_CNT_WIDTH constant, and fsfb_corr component declaration
--
-- Revision 1.2  2004/12/07 19:47:24  mohsen
-- Anthony & Mohsen: Restructured constant declaration.  Moved shared constants from lower level package files to the upper level ones.  This was done to resolve compilation error resulting from shared constants defined in multiple package files.
--
-- Revision 1.1  2004/12/04 03:08:24  mohsen
-- Initial Release
--
--
--
--
------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library work;
use work.readout_card_pack.all;

library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;

package flux_loop_pack is

  
  -----------------------------------------------------------------------------
  -- Constants 
  -----------------------------------------------------------------------------

  -- Wishbone fb data specific
  constant ADC_OFFSET_DAT_WIDTH   : integer := 16;                   -- 2 MSB not used
  constant ADC_OFFSET_ADDR_WIDTH  : integer := 6;                    -- memory used has 2**6 locations 
  
  constant PIDZ_ADDR_WIDTH        : integer := 6;                    -- Note that same memory storage element is used for PIDZ and ADC_OFFSET and FLUX_QUANTA
  constant PIDZ_DATA_WIDTH        : integer := 8;
  constant PIDZ_MAX               : integer := (2**(PIDZ_DATA_WIDTH-1))-1;
  constant PIDZ_MIN               : integer := -(2**(PIDZ_DATA_WIDTH-1));
  
  constant SERVO_MODE_SEL_WIDTH   : integer := WB_DATA_WIDTH-30;     -- data width of servo mode selection

  constant CONST_VAL_WIDTH        : integer := WB_DATA_WIDTH;     -- data width of constant value
  constant RAMP_STEP_WIDTH        : integer := CONST_VAL_WIDTH;     -- data width of ramp step size
  constant RAMP_AMP_WIDTH         : integer := CONST_VAL_WIDTH;     -- data width of ramp peak amplitude
  constant RAMP_CYC_WIDTH         : integer := CONST_VAL_WIDTH;        -- data width of ramp frame cycle number
  
  constant FLUX_QUANTA_ADDR_WIDTH : integer := 6;
  constant FLUX_QUANTA_DATA_WIDTH : integer := 14;
  constant FLUX_QUANTA_MAX        : integer := (2**(FLUX_QUANTA_DATA_WIDTH))-1;
  constant FLUX_QUANTA_MIN        : integer := 0;  -- Flux Quanta are always positive numbers.
  
  -- Wishbone frame data specific
  constant RAW_DATA_WIDTH         : integer := 16;
  constant RAW_ADDR_WIDTH         : integer := 13;                   -- enough for two frame
  
  -- Flux Loop Control Specific
  constant RAW_DAT_WIDTH          : integer := RAW_DATA_WIDTH;       -- two bytes
  constant COADD_ADDR_WIDTH       : integer := ROW_ADDR_WIDTH;
  constant FLUX_QUANTA_CNT_WIDTH  : integer := 8;

  -- The following is for debug and will be taken out in the final version 
  constant FSFB_QUEUE_DATA_WIDTH  : integer := 39;---8;        -- data width of first stage feedback queue
  constant COEFF_QUEUE_DATA_WIDTH : integer := WB_DATA_WIDTH;        -- data width of PIDZ coefficient queue
  constant COEFF_QUEUE_ADDR_WIDTH : integer := PIDZ_ADDR_WIDTH;      -- address width of PIDZ coefficient queue

  -- filter related 
  constant FLTR_QUEUE_DATA_WIDTH  : integer := WB_DATA_WIDTH;        -- data width of the filter results storage
  constant FLTR_QUEUE_ADDR_WIDTH  : integer := 6;
  constant FLTR_QUEUE_COUNT       : integer := 41;                   -- 2**FLTR_QUEUE_ADDR_WIDTH-1; -- or just 41! 

  
  -----------------------------------------------------------------------------
  -- Flux Loop Control Block
  -----------------------------------------------------------------------------

  component flux_loop_ctrl
    port (
      adc_dat_i                   : in  std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
      adc_ovr_i                   : in  std_logic;
      adc_rdy_i                   : in  std_logic;
      adc_clk_o                   : out std_logic;
      clk_50_i                    : in  std_logic;
      clk_25_i                    : in  std_logic;
      rst_i                       : in  std_logic;
      adc_coadd_en_i              : in  std_logic;
      restart_frame_1row_prev_i   : in  std_logic;
      restart_frame_aligned_i     : in  std_logic;
      restart_frame_1row_post_i   : in  std_logic;
      row_switch_i                : in  std_logic;
      initialize_window_i         : in  std_logic;
      fltr_rst_i                  : in  std_logic;
      num_rows_sub1_i             : in  std_logic_vector(FSFB_QUEUE_ADDR_WIDTH-1 downto 0);
      dac_dat_en_i                : in  std_logic;
      coadded_addr_i              : in  std_logic_vector (COADD_ADDR_WIDTH-1 downto 0);
      coadded_dat_o               : out std_logic_vector (WB_DATA_WIDTH-1 downto 0);
      raw_addr_i                  : in  std_logic_vector (RAW_ADDR_WIDTH-1 downto 0);
      raw_dat_o                   : out std_logic_vector (RAW_DAT_WIDTH-1 downto 0);
      raw_req_i                   : in  std_logic;
      raw_ack_o                   : out std_logic;
      fsfb_addr_i                 : in  std_logic_vector(FSFB_QUEUE_ADDR_WIDTH-1 downto 0);
      fsfb_dat_o                  : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      flux_cnt_ws_dat_o           : out std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
      filtered_addr_i             : in  std_logic_vector(5 downto 0);
      filtered_dat_o              : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      adc_offset_dat_i            : in  std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
      adc_offset_adr_o            : out std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0);
      servo_mode_i                : in  std_logic_vector(SERVO_MODE_SEL_WIDTH-1 downto 0);
      ramp_step_size_i            : in  std_logic_vector(RAMP_STEP_WIDTH-1 downto 0);
      ramp_amp_i                  : in  std_logic_vector(RAMP_AMP_WIDTH-1 downto 0);
      const_val_i                 : in  std_logic_vector(CONST_VAL_WIDTH-1 downto 0);
      num_ramp_frame_cycles_i     : in  std_logic_vector(RAMP_CYC_WIDTH-1 downto 0);
      p_addr_o                    : out std_logic_vector(COEFF_QUEUE_ADDR_WIDTH-1 downto 0);
      p_dat_i                     : in  std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);
      i_addr_o                    : out std_logic_vector(COEFF_QUEUE_ADDR_WIDTH-1 downto 0);
      i_dat_i                     : in  std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);
      d_addr_o                    : out std_logic_vector(COEFF_QUEUE_ADDR_WIDTH-1 downto 0);
      d_dat_i                     : in  std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);
      flux_quanta_addr_o          : out std_logic_vector(COEFF_QUEUE_ADDR_WIDTH-1 downto 0);
      flux_quanta_dat_i           : in  std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);
      sa_bias_dat_i               : in  std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      offset_dat_i                : in  std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      filter_coeff0_i             : in  std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      filter_coeff1_i             : in  std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      filter_coeff2_i             : in  std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      filter_coeff3_i             : in  std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      filter_coeff4_i             : in  std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      filter_coeff5_i             : in  std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      filter_coeff6_i             : in  std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      dac_dat_o                   : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
      dac_clk_o                   : out std_logic;
      sa_bias_dac_spi_o           : out std_logic_vector(SA_BIAS_SPI_DATA_WIDTH-1 downto 0);
      offset_dac_spi_o            : out std_logic_vector(OFFSET_SPI_DATA_WIDTH-1 downto 0);
      fsfb_fltr_dat_rdy_o         : out std_logic;
      fsfb_fltr_dat_o             : out std_logic_vector(FLTR_QUEUE_DATA_WIDTH-1 downto 0);
      
      --  fsfb_corr interface
      fsfb_ctrl_lock_en_o         : out std_logic;                                             
      flux_quanta_o               : out std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);   
      fsfb_ctrl_dat_o             : out std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0);    
      fsfb_ctrl_dat_rdy_o         : out std_logic;                                                
      num_flux_quanta_prev_o      : out std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);    
      num_flux_quanta_pres_rdy_i  : in  std_logic;                                             
      num_flux_quanta_pres_i      : in  std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);    
      fsfb_ctrl_dat_rdy_i         : in  std_logic;                                             
      fsfb_ctrl_dat_i             : in  std_logic_vector(DAC_DAT_WIDTH-1 downto 0)             
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

 
  -----------------------------------------------------------------------------
  -- Wishbone Frame Data Block
  -----------------------------------------------------------------------------

  component wbs_frame_data
    port (
      rst_i               : in  std_logic;
      clk_i               : in  std_logic;
      restart_frame_1row_post_i : in  std_logic;      
      filtered_addr_ch0_o : out std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
      filtered_dat_ch0_i  : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
      fsfb_addr_ch0_o     : out std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
      fsfb_dat_ch0_i      : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
      flux_cnt_dat_ch0_i  : in  std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
      coadded_addr_ch0_o  : out std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
      coadded_dat_ch0_i   : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
      raw_addr_ch0_o      : out std_logic_vector (RAW_ADDR_WIDTH-1 downto 0);
      raw_dat_ch0_i       : in  std_logic_vector (RAW_DATA_WIDTH-1 downto 0);
      raw_req_ch0_o       : out std_logic;
      raw_ack_ch0_i       : in  std_logic;
      filtered_addr_ch1_o : out std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
      filtered_dat_ch1_i  : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
      fsfb_addr_ch1_o     : out std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
      fsfb_dat_ch1_i      : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
      flux_cnt_dat_ch1_i  : in  std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
      coadded_addr_ch1_o  : out std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
      coadded_dat_ch1_i   : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
      raw_addr_ch1_o      : out std_logic_vector (RAW_ADDR_WIDTH-1 downto 0);
      raw_dat_ch1_i       : in  std_logic_vector (RAW_DATA_WIDTH-1 downto 0);
      raw_req_ch1_o       : out std_logic;
      raw_ack_ch1_i       : in  std_logic;
      filtered_addr_ch2_o : out std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
      filtered_dat_ch2_i  : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
      fsfb_addr_ch2_o     : out std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
      fsfb_dat_ch2_i      : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
      flux_cnt_dat_ch2_i  : in  std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
      coadded_addr_ch2_o  : out std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
      coadded_dat_ch2_i   : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
      raw_addr_ch2_o      : out std_logic_vector (RAW_ADDR_WIDTH-1 downto 0);
      raw_dat_ch2_i       : in  std_logic_vector (RAW_DATA_WIDTH-1 downto 0);
      raw_req_ch2_o       : out std_logic;
      raw_ack_ch2_i       : in  std_logic;
      filtered_addr_ch3_o : out std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
      filtered_dat_ch3_i  : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
      fsfb_addr_ch3_o     : out std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
      fsfb_dat_ch3_i      : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
      flux_cnt_dat_ch3_i  : in  std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
      coadded_addr_ch3_o  : out std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
      coadded_dat_ch3_i   : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
      raw_addr_ch3_o      : out std_logic_vector (RAW_ADDR_WIDTH-1 downto 0);
      raw_dat_ch3_i       : in  std_logic_vector (RAW_DATA_WIDTH-1 downto 0);
      raw_req_ch3_o       : out std_logic;
      raw_ack_ch3_i       : in  std_logic;
      filtered_addr_ch4_o : out std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
      filtered_dat_ch4_i  : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
      fsfb_addr_ch4_o     : out std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
      fsfb_dat_ch4_i      : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
      flux_cnt_dat_ch4_i  : in  std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
      coadded_addr_ch4_o  : out std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
      coadded_dat_ch4_i   : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
      raw_addr_ch4_o      : out std_logic_vector (RAW_ADDR_WIDTH-1 downto 0);
      raw_dat_ch4_i       : in  std_logic_vector (RAW_DATA_WIDTH-1 downto 0);
      raw_req_ch4_o       : out std_logic;
      raw_ack_ch4_i       : in  std_logic;
      filtered_addr_ch5_o : out std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
      filtered_dat_ch5_i  : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
      fsfb_addr_ch5_o     : out std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
      fsfb_dat_ch5_i      : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
      flux_cnt_dat_ch5_i  : in  std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
      coadded_addr_ch5_o  : out std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
      coadded_dat_ch5_i   : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
      raw_addr_ch5_o      : out std_logic_vector (RAW_ADDR_WIDTH-1 downto 0);
      raw_dat_ch5_i       : in  std_logic_vector (RAW_DATA_WIDTH-1 downto 0);
      raw_req_ch5_o       : out std_logic;
      raw_ack_ch5_i       : in  std_logic;
      filtered_addr_ch6_o : out std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
      filtered_dat_ch6_i  : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
      fsfb_addr_ch6_o     : out std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
      fsfb_dat_ch6_i      : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
      flux_cnt_dat_ch6_i  : in  std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
      coadded_addr_ch6_o  : out std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
      coadded_dat_ch6_i   : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
      raw_addr_ch6_o      : out std_logic_vector (RAW_ADDR_WIDTH-1 downto 0);
      raw_dat_ch6_i       : in  std_logic_vector (RAW_DATA_WIDTH-1 downto 0);
      raw_req_ch6_o       : out std_logic;
      raw_ack_ch6_i       : in  std_logic;
      filtered_addr_ch7_o : out std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
      filtered_dat_ch7_i  : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
      fsfb_addr_ch7_o     : out std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
      fsfb_dat_ch7_i      : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
      flux_cnt_dat_ch7_i  : in  std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
      coadded_addr_ch7_o  : out std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
      coadded_dat_ch7_i   : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
      raw_addr_ch7_o      : out std_logic_vector (RAW_ADDR_WIDTH-1 downto 0);
      raw_dat_ch7_i       : in  std_logic_vector (RAW_DATA_WIDTH-1 downto 0);
      raw_req_ch7_o       : out std_logic;
      raw_ack_ch7_i       : in  std_logic;
      dat_i               : in  std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      addr_i              : in  std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
      tga_i               : in  std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
      we_i                : in  std_logic;
      stb_i               : in  std_logic;
      cyc_i               : in  std_logic;
      dat_o               : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      ack_o               : out std_logic);
  end component;
  
  
  -----------------------------------------------------------------------------
  -- Wishbone Feedback Data Block
  -----------------------------------------------------------------------------

  component wbs_fb_data
    port (
      clk_50_i                : in  std_logic;
      rst_i                   : in  std_logic;
      adc_offset_dat_ch0_o    : out std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
      adc_offset_addr_ch0_i   : in  std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0);
      p_dat_ch0_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      p_addr_ch0_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      i_dat_ch0_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      i_addr_ch0_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      d_dat_ch0_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      d_addr_ch0_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      flux_quanta_dat_ch0_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      flux_quanta_addr_ch0_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      sa_bias_ch0_o           : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      offset_dat_ch0_o        : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      adc_offset_dat_ch1_o    : out std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
      adc_offset_addr_ch1_i   : in  std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0);
      p_dat_ch1_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      p_addr_ch1_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      i_dat_ch1_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      i_addr_ch1_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      d_dat_ch1_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      d_addr_ch1_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      flux_quanta_dat_ch1_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      flux_quanta_addr_ch1_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      sa_bias_ch1_o           : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      offset_dat_ch1_o        : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      adc_offset_dat_ch2_o    : out std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
      adc_offset_addr_ch2_i   : in  std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0);
      p_dat_ch2_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      p_addr_ch2_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      i_dat_ch2_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      i_addr_ch2_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      d_dat_ch2_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      d_addr_ch2_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      flux_quanta_dat_ch2_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      flux_quanta_addr_ch2_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      sa_bias_ch2_o           : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      offset_dat_ch2_o        : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      adc_offset_dat_ch3_o    : out std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
      adc_offset_addr_ch3_i   : in  std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0);
      p_dat_ch3_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      p_addr_ch3_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      i_dat_ch3_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      i_addr_ch3_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      d_dat_ch3_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      d_addr_ch3_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      flux_quanta_dat_ch3_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      flux_quanta_addr_ch3_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      sa_bias_ch3_o           : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      offset_dat_ch3_o        : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      adc_offset_dat_ch4_o    : out std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
      adc_offset_addr_ch4_i   : in  std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0);
      p_dat_ch4_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      p_addr_ch4_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      i_dat_ch4_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      i_addr_ch4_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      d_dat_ch4_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      d_addr_ch4_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      flux_quanta_dat_ch4_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      flux_quanta_addr_ch4_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      sa_bias_ch4_o           : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      offset_dat_ch4_o        : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      adc_offset_dat_ch5_o    : out std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
      adc_offset_addr_ch5_i   : in  std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0);
      p_dat_ch5_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      p_addr_ch5_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      i_dat_ch5_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      i_addr_ch5_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      d_dat_ch5_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      d_addr_ch5_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      flux_quanta_dat_ch5_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      flux_quanta_addr_ch5_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      sa_bias_ch5_o           : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      offset_dat_ch5_o        : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      adc_offset_dat_ch6_o    : out std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
      adc_offset_addr_ch6_i   : in  std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0);
      p_dat_ch6_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      p_addr_ch6_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      i_dat_ch6_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      i_addr_ch6_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      d_dat_ch6_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      d_addr_ch6_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      flux_quanta_dat_ch6_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      flux_quanta_addr_ch6_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      sa_bias_ch6_o           : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      offset_dat_ch6_o        : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      adc_offset_dat_ch7_o    : out std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
      adc_offset_addr_ch7_i   : in  std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0);
      p_dat_ch7_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      p_addr_ch7_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      i_dat_ch7_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      i_addr_ch7_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      d_dat_ch7_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      d_addr_ch7_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      flux_quanta_dat_ch7_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      flux_quanta_addr_ch7_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      sa_bias_ch7_o           : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      offset_dat_ch7_o        : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      filter_coeff0_o         : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      filter_coeff1_o         : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      filter_coeff2_o         : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      filter_coeff3_o         : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      filter_coeff4_o         : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      filter_coeff5_o         : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      filter_coeff6_o         : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      servo_mode_o            : out std_logic_vector(SERVO_MODE_SEL_WIDTH-1 downto 0);
      ramp_step_size_o        : out std_logic_vector(RAMP_STEP_WIDTH-1 downto 0);
      ramp_amp_o              : out std_logic_vector(RAMP_AMP_WIDTH-1 downto 0);
      const_val_o             : out std_logic_vector(CONST_VAL_WIDTH-1 downto 0);
      num_ramp_frame_cycles_o : out std_logic_vector(RAMP_CYC_WIDTH-1 downto 0);
      flux_jumping_en_o       : out std_logic;
      dat_i                   : in  std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      addr_i                  : in  std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
      tga_i                   : in  std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
      we_i                    : in  std_logic;
      stb_i                   : in  std_logic;
      cyc_i                   : in  std_logic;
      dat_o                   : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      ack_o                   : out std_logic);
  end component;

end flux_loop_pack;

