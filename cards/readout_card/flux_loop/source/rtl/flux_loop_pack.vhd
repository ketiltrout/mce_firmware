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
-- Revision 1.27  2013/05/27 20:26:05  mandana
-- added servo_rst_window interface
--
-- Revision 1.26  2012-10-30 19:08:05  mandana
-- only renaming signals for clarity
--
-- Revision 1.25  2012-09-07 18:37:51  mandana
-- *** empty log message ***
--
-- Revision 1.24  2012-01-23 20:52:50  mandana
-- added qterm to interfaces
--
-- Revision 1.23  2011-01-21 01:32:56  mandana
-- fixed typo in comments for filter type 2
--
-- Revision 1.22  2010-11-30 19:43:46  mandana
-- filter_coeff ports reduced to filter_coef_width instead of wb_data_width to help fitting in EP1S40.
-- reorganized pack files and moved filter_coef definitions here to keep hierarchical pack files
--
-- Revision 1.21  2010/06/03 20:46:11  bburger
-- BB:  added a initialize_window_i interface to fsfb_corr, and clarified the value of SERVO_MODE_SEL_WIDTH.
--
-- Revision 1.20  2010/03/12 20:39:50  bburger
-- BB: added i_clamp_val interface signals
--
-- Revision 1.19.2.1  2009/11/13 19:33:17  bburger
-- BB: Added i-term clamp interface signals
--
-- Revision 1.19  2009/05/27 22:33:24  bburger
-- BB: Added data_size_i interface to wishbone entity for rectangle mode data acquisition
--
-- Revision 1.18  2009/05/27 01:24:40  bburger
-- BB: Added raw-data components, new to v5.x from 4.0.d
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
   constant ADC_OFFSET_ADDR_WIDTH  : integer := ROW_ADDR_WIDTH;       -- memory used has 2**6 locations 
   constant SERVO_RST_ADDR_WIDTH   : integer := ROW_ADDR_WIDTH;
   
   constant PIDZ_ADDR_WIDTH        : integer := ROW_ADDR_WIDTH;       -- Note that same memory storage element is used for PIDZ and ADC_OFFSET and FLUX_QUANTA
   constant PIDZ_DATA_WIDTH        : integer := 12;
   constant PIDZ_MAX               : integer := (2**(PIDZ_DATA_WIDTH-1))-1;
   constant PIDZ_MIN               : integer := -(2**(PIDZ_DATA_WIDTH-1));
   
   constant SERVO_MODE_SEL_WIDTH   : integer := 2;                    -- data width of servo mode selection:  00,01=constant; 10=ramp; 11=servo.
   constant CONSTANT_MODE0         : std_logic_vector(1 downto 0) := "00";
   constant CONSTANT_MODE1         : std_logic_vector(1 downto 0) := "01";
   constant RAMP_MODE              : std_logic_vector(1 downto 0) := "10";
   constant LOCK_MODE              : std_logic_vector(1 downto 0) := "11";

   constant CONST_VAL_WIDTH        : integer := WB_DATA_WIDTH;        -- data width of constant value
   constant RAMP_STEP_WIDTH        : integer := CONST_VAL_WIDTH;      -- data width of ramp step size
   constant RAMP_AMP_WIDTH         : integer := CONST_VAL_WIDTH;      -- data width of ramp peak amplitude
   constant RAMP_CYC_WIDTH         : integer := CONST_VAL_WIDTH;      -- data width of ramp frame cycle number
   
   constant FLUX_QUANTA_ADDR_WIDTH : integer := ROW_ADDR_WIDTH;
   constant FLUX_QUANTA_DATA_WIDTH : integer := 14;
   constant FLUX_QUANTA_MAX        : integer := (2**(FLUX_QUANTA_DATA_WIDTH))-1;
   constant FLUX_QUANTA_MIN        : integer := 0;                    -- Flux Quanta are always positive numbers.
   
   -- Wishbone frame data specific
   constant RAW_DATA_WIDTH         : integer := ADC_DAT_WIDTH;
   constant RAW_ADDR_WIDTH         : integer := 16;                   
   constant RAW_RAM_WIDTH          : integer := 14;                  
   constant RAW_ADDR_MAX           : std_logic_vector(RAW_ADDR_WIDTH DOWNTO 0) := "01111111111111111";
   -- This is the offset buy which the raw data address preceeds the raw data output register = 2
   constant RAW_OFFSET_MAX         : std_logic_vector(RAW_ADDR_WIDTH DOWNTO 0) := "00000000000000001";
   constant RAW_NULL_DATA          : std_logic_vector(WB_DATA_WIDTH-1 downto 0) := x"80000000";
   
   -- Flux Loop Control Specific
   constant COADD_ADDR_WIDTH       : integer := ROW_ADDR_WIDTH;
   constant FLUX_QUANTA_CNT_WIDTH  : integer := 8;

   -- The following is for debug and will be taken out in the final version 
   constant FSFB_QUEUE_DATA_WIDTH  : integer := 39;---8;              -- data width of first stage feedback queue
   constant COEFF_QUEUE_DATA_WIDTH : integer := WB_DATA_WIDTH;        -- data width of PIDZ coefficient queue
   constant COEFF_QUEUE_ADDR_WIDTH : integer := PIDZ_ADDR_WIDTH;      -- address width of PIDZ coefficient queue

   -- filter related 
   constant FLTR_QUEUE_DATA_WIDTH  : integer := WB_DATA_WIDTH;        -- data width of the filter results storage
   constant FLTR_QUEUE_ADDR_WIDTH  : integer := ROW_ADDR_WIDTH;
   constant FLTR_QUEUE_COUNT       : integer := 2**FLTR_QUEUE_ADDR_WIDTH-1; -- or just 41! 

   constant NUM_FILTER_COEFF       : integer := 6;                    -- number of filter coefficients
   constant FILTER_COEF_WIDTH      : integer := 15;                   -- number of bits in the coefficient

   -- This filter implementation takes 6 parameters: filter_coeff0 to filter_coeff5.
   -- The coefficients are chosen through Simulink FDAtool interface when a 4-pole Butterworth filter is chosen
   -- filter_coeff0 to filter_coeff3 are: b11, b12, b21, b22 or the Butterworth coefficients 
   -- filter_coeff4 or filter_scale_lsb is the number of bits dropped after the second biquad 
   -- filter_coeff5 or filter_gain_width is the gain scaling between the two biquads (1/2^gain) to preserve dynamic range.
   -- Here are the coefficients for filter type 1 and 2:
   -- (SOS: Second-order sections)
   --                                    SOS: a0 a1 a2 b0 b1                   b2
   -- for princeton act fc/fs=100/12195, SOS: 1  2  1  1  -1.9587428340882587  0.96134553442399129 (1st biquad)       
   --                                         1  2  1  1  -1.9066292518523014  0.90916270571237567 (2nd biquad)       
   --                           Scale Values: 0.00065067508393319923                                       
   --                                         0.00063336346501859835       
   --                           Filter Type : 1
   ------------------------------------------------------------------------------------------------------------
   -- for Spider/Bicep fc/fs=75/30000,  SOS: 1  2  1  1  -1.9711486088510415  0.97139181456687917         
   --                                         1  2  1  1  -1.9878047097960421  0.98804997058724808         
   --                           Scale Values: 0.0000000037280516432624239
   --                                         1                                                            
   --                           Filter Type : 2
   
   -- To convert to signed binary fractional, multiply the number by 2^14 and convert to hex. 
   constant FILTER_TYPE             : std_logic_vector(7 downto 0) := x"FF";
   -- Filter Type: xFF is programmable filter coefficients.

   subtype word_coeff is std_logic_vector(FILTER_COEF_WIDTH-1 downto  0);
   type coeff_array is array (0 to NUM_FILTER_COEFF-1) of integer; 
  
   -- Filter coefficients for Filter Type: 1
   constant FILT_COEF_DEFAULTS : coeff_array := (32092,15750,31238,14895,0, 11);
   
   -- Filter coefficients for Filter Type: 2
   -- constant FILT_COEF_DEFAULTS : coeff_array := (32295,15915,32568,16188, 3, 14); 

   -----------------------------------------------------------------------------
   -- Raw Data/ Rectangle Mode RAM Bank
   -----------------------------------------------------------------------------
--   constant RAW_DATA_RAM_DATA_WIDTH : integer := 13;
--   constant RAW_DATA_RAM_ADDR_WIDTH : integer := 12;

   component raw_ram_bank
   port (
      clock    : IN STD_LOGIC ;
      data     : IN STD_LOGIC_VECTOR (RAW_RAM_WIDTH-1 DOWNTO 0);
      rdaddress      : IN STD_LOGIC_VECTOR (RAW_ADDR_WIDTH-1 DOWNTO 0);
      wraddress      : IN STD_LOGIC_VECTOR (RAW_ADDR_WIDTH-1 DOWNTO 0);
      wren     : IN STD_LOGIC  := '1';
      q     : OUT STD_LOGIC_VECTOR (RAW_RAM_WIDTH-1 DOWNTO 0)
   );
   end component;
   
   -----------------------------------------------------------------------------
   -- Flux Loop Control Block
   -----------------------------------------------------------------------------
   component flux_loop_ctrl
   generic (ADC_LATENCY         : integer);
   port (
--      -- For Readout Card Rev. C
--      samp_clk_i                  : in  std_logic;
--      adc_frame_i                 : in  std_logic; 
--      adc_lvds_i                  : in  std_logic;      
      -- For Readout Card Rev. A/AA/B
      adc_dat_i                   : in  std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
--      adc_ovr_i                   : in  std_logic;
--      adc_rdy_i                   : in  std_logic;
      clk_50_i                    : in  std_logic;
      clk_25_i                    : in  std_logic;
      rst_i                       : in  std_logic;
      adc_coadd_en_i              : in  std_logic;
      restart_frame_1row_prev_i   : in  std_logic;
      restart_frame_aligned_i     : in  std_logic;
      restart_frame_1row_post_i   : in  std_logic;
      row_switch_i                : in  std_logic;
      initialize_window_i         : in  std_logic;
      servo_rst_window_i          : in  std_logic;
      fltr_rst_i                  : in  std_logic;
      num_rows_sub1_i             : in  std_logic_vector(FSFB_QUEUE_ADDR_WIDTH-1 downto 0);
      dac_dat_en_i                : in  std_logic;
      coadded_addr_i              : in  std_logic_vector (COADD_ADDR_WIDTH-1 downto 0);
      coadded_dat_o               : out std_logic_vector (WB_DATA_WIDTH-1 downto 0);
      fsfb_addr_i                 : in  std_logic_vector(FSFB_QUEUE_ADDR_WIDTH-1 downto 0);
      fsfb_dat_o                  : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      flux_cnt_ws_dat_o           : out std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
      filtered_addr_i             : in  std_logic_vector(5 downto 0);
      filtered_dat_o              : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      adc_offset_dat_i            : in  std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
      adc_offset_adr_o            : out std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0);
      servo_rst_dat_i             : in  std_logic;
      servo_rst_addr_o            : out std_logic_vector(SERVO_RST_ADDR_WIDTH-1 downto 0);
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
      sa_bias_dat_rdy_i           : in  std_logic;
      offset_dat_i                : in  std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      offset_dat_rdy_i            : in  std_logic;
      filter_coeff0_i             : in  std_logic_vector(FILTER_COEF_WIDTH-1 downto 0);
      filter_coeff1_i             : in  std_logic_vector(FILTER_COEF_WIDTH-1 downto 0);
      filter_coeff2_i             : in  std_logic_vector(FILTER_COEF_WIDTH-1 downto 0);
      filter_coeff3_i             : in  std_logic_vector(FILTER_COEF_WIDTH-1 downto 0);
      filter_coeff4_i             : in  std_logic_vector(FILTER_COEF_WIDTH-1 downto 0);
      filter_coeff5_i             : in  std_logic_vector(FILTER_COEF_WIDTH-1 downto 0);
      filter_coeff6_i             : in  std_logic_vector(FILTER_COEF_WIDTH-1 downto 0);
      dac_dat_o                   : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
      dac_clk_o                   : out std_logic;
      sa_bias_dac_spi_o           : out std_logic_vector(SA_BIAS_SPI_DATA_WIDTH-1 downto 0);
      offset_dac_spi_o            : out std_logic_vector(OFFSET_SPI_DATA_WIDTH-1 downto 0);
      fsfb_fltr_dat_rdy_o         : out std_logic;
      fsfb_fltr_dat_o             : out std_logic_vector(FLTR_QUEUE_DATA_WIDTH-1 downto 0);
      i_clamp_val_i               : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      qterm_decay_bits_i          : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      
      --  fsfb_corr interface
      fsfb_ctrl_lock_en_o         : out std_logic;                                             
      flux_quanta_o               : out std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);   
      fsfb_ctrl_dat_o             : out std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0);    
      fsfb_ctrl_dat_rdy_o         : out std_logic;                                                
      fj_count_o      : out std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);    
      fj_count_rdy_i  : in  std_logic;                                             
      fj_count_i      : in  std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);    
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
      flux_jump_en_i       : in std_logic;
      initialize_window_i  : in std_logic;
      servo_rst_window_i   : in std_logic;
      
      servo_rst_dat_i      : in std_logic_vector(NUM_COLS-1 downto 0);

      servo_en0_i          : in std_logic;
      servo_en1_i          : in std_logic;
      servo_en2_i          : in std_logic;
      servo_en3_i          : in std_logic;
      servo_en4_i          : in std_logic;
      servo_en5_i          : in std_logic;
      servo_en6_i          : in std_logic;
      servo_en7_i          : in std_logic;
      
      flux_quanta0_i       : in std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0); 
      flux_quanta1_i       : in std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0); 
      flux_quanta2_i       : in std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0); 
      flux_quanta3_i       : in std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0); 
      flux_quanta4_i       : in std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0); 
      flux_quanta5_i       : in std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0); 
      flux_quanta6_i       : in std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0); 
      flux_quanta7_i       : in std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0); 
      
      fj_count0_i          : in std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); 
      fj_count1_i          : in std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); 
      fj_count2_i          : in std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); 
      fj_count3_i          : in std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); 
      fj_count4_i          : in std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); 
      fj_count5_i          : in std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); 
      fj_count6_i          : in std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); 
      fj_count7_i          : in std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); 
      
      fsfb_ctrl_dat0_i     : in std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0); 
      fsfb_ctrl_dat1_i     : in std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0); 
      fsfb_ctrl_dat2_i     : in std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0); 
      fsfb_ctrl_dat3_i     : in std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0); 
      fsfb_ctrl_dat4_i     : in std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0); 
      fsfb_ctrl_dat5_i     : in std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0); 
      fsfb_ctrl_dat6_i     : in std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0); 
      fsfb_ctrl_dat7_i     : in std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0);      
      fsfb_ctrl_dat_rdy0_i : in std_logic;
      
      fj_count0_o          : out std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); --flux_jump_counter_array;
      fj_count1_o          : out std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); 
      fj_count2_o          : out std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); 
      fj_count3_o          : out std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); 
      fj_count4_o          : out std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); 
      fj_count5_o          : out std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); 
      fj_count6_o          : out std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0); 
      fj_count7_o          : out std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);     
      fj_count_rdy_o       : out std_logic;
      
      -- fsfb_ctrl interface
      fsfb_ctrl_dat0_o     : out  std_logic_vector(DAC_DAT_WIDTH-1 downto 0); 
      fsfb_ctrl_dat1_o     : out  std_logic_vector(DAC_DAT_WIDTH-1 downto 0); 
      fsfb_ctrl_dat2_o     : out  std_logic_vector(DAC_DAT_WIDTH-1 downto 0); 
      fsfb_ctrl_dat3_o     : out  std_logic_vector(DAC_DAT_WIDTH-1 downto 0); 
      fsfb_ctrl_dat4_o     : out  std_logic_vector(DAC_DAT_WIDTH-1 downto 0); 
      fsfb_ctrl_dat5_o     : out  std_logic_vector(DAC_DAT_WIDTH-1 downto 0); 
      fsfb_ctrl_dat6_o     : out  std_logic_vector(DAC_DAT_WIDTH-1 downto 0); 
      fsfb_ctrl_dat7_o     : out  std_logic_vector(DAC_DAT_WIDTH-1 downto 0); 
      fsfb_ctrl_dat_rdy_o  : out  std_logic;
      
      -- Global Signals      
      clk_i                : in std_logic;
      rst_i                : in std_logic
   );     
   end component;

 
   -----------------------------------------------------------------------------
   -- Wishbone Frame Data Block
   -----------------------------------------------------------------------------
   component wbs_frame_data
   port (
      rst_i               : in  std_logic;
      clk_i               : in  std_logic;
      num_rows_i          : in  integer;
      num_rows_reported_i : in integer;
      num_cols_reported_i : in integer;
      data_size_i         : in std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);
      raw_addr_o          : out std_logic_vector (RAW_ADDR_WIDTH-1    downto 0);  -- raw data address 
      raw_dat_i           : in  std_logic_vector (RAW_RAM_WIDTH-1 downto 0);  -- raw data 
      raw_req_o           : out std_logic;                                        -- raw data request 
      raw_ack_i           : in  std_logic;                                        -- raw data acknowledgement 
      readout_col_index_o : out std_logic_vector (COL_ADDR_WIDTH-1 downto 0);     -- readout column index for column-readout mode (raw)      
      restart_frame_aligned_i : in std_logic;
      restart_frame_1row_post_i : in  std_logic;      
      filtered_addr_ch0_o : out std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
      filtered_dat_ch0_i  : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
      fsfb_addr_ch0_o     : out std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
      fsfb_dat_ch0_i      : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
      flux_cnt_dat_ch0_i  : in  std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
      coadded_addr_ch0_o  : out std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
      coadded_dat_ch0_i   : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
      filtered_addr_ch1_o : out std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
      filtered_dat_ch1_i  : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
      fsfb_addr_ch1_o     : out std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
      fsfb_dat_ch1_i      : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
      flux_cnt_dat_ch1_i  : in  std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
      coadded_addr_ch1_o  : out std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
      coadded_dat_ch1_i   : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
      filtered_addr_ch2_o : out std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
      filtered_dat_ch2_i  : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
      fsfb_addr_ch2_o     : out std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
      fsfb_dat_ch2_i      : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
      flux_cnt_dat_ch2_i  : in  std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
      coadded_addr_ch2_o  : out std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
      coadded_dat_ch2_i   : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
      filtered_addr_ch3_o : out std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
      filtered_dat_ch3_i  : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
      fsfb_addr_ch3_o     : out std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
      fsfb_dat_ch3_i      : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
      flux_cnt_dat_ch3_i  : in  std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
      coadded_addr_ch3_o  : out std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
      coadded_dat_ch3_i   : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
      filtered_addr_ch4_o : out std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
      filtered_dat_ch4_i  : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
      fsfb_addr_ch4_o     : out std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
      fsfb_dat_ch4_i      : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
      flux_cnt_dat_ch4_i  : in  std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
      coadded_addr_ch4_o  : out std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
      coadded_dat_ch4_i   : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
      filtered_addr_ch5_o : out std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
      filtered_dat_ch5_i  : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
      fsfb_addr_ch5_o     : out std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
      fsfb_dat_ch5_i      : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
      flux_cnt_dat_ch5_i  : in  std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
      coadded_addr_ch5_o  : out std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
      coadded_dat_ch5_i   : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
      filtered_addr_ch6_o : out std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
      filtered_dat_ch6_i  : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
      fsfb_addr_ch6_o     : out std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
      fsfb_dat_ch6_i      : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
      flux_cnt_dat_ch6_i  : in  std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
      coadded_addr_ch6_o  : out std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
      coadded_dat_ch6_i   : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
      filtered_addr_ch7_o : out std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
      filtered_dat_ch7_i  : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
      fsfb_addr_ch7_o     : out std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
      fsfb_dat_ch7_i      : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
      flux_cnt_dat_ch7_i  : in  std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
      coadded_addr_ch7_o  : out std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
      coadded_dat_ch7_i   : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
      dat_i               : in  std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      addr_i              : in  std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
      tga_i               : in  std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
      we_i                : in  std_logic;
      stb_i               : in  std_logic;
      cyc_i               : in  std_logic;
      dat_o               : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      ack_o               : out std_logic
   );
   end component;   
   
   -----------------------------------------------------------------------------
   -- Wishbone Feedback Data Block
   -----------------------------------------------------------------------------
   component wbs_fb_data
   port (
      clk_50_i                : in  std_logic;
      rst_i                   : in  std_logic;
      servo_rst_dat_o         : out std_logic_vector(NUM_COLS-1 downto 0);    
      servo_rst_dat2_o        : out std_logic_vector(NUM_COLS-1 downto 0);      
      adc_offset_dat_ch0_o    : out std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
      adc_offset_addr_ch0_i   : in  std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0);
      servo_rst_addr_ch0_i    : in  std_logic_vector(SERVO_RST_ADDR_WIDTH-1 downto 0);
      servo_rst_addr2_ch0_i   : in  std_logic_vector(SERVO_RST_ADDR_WIDTH-1 downto 0);      
      p_dat_ch0_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      p_addr_ch0_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      i_dat_ch0_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      i_addr_ch0_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      d_dat_ch0_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      d_addr_ch0_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      flux_quanta_dat_ch0_o   : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      flux_quanta_addr_ch0_i  : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      sa_bias_ch0_o           : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      sa_bias_rdy_ch0_o       : out std_logic;
      offset_dat_ch0_o        : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      offset_dat_rdy_ch0_o    : out std_logic;
      const_val_ch0_o         : out std_logic_vector(CONST_VAL_WIDTH-1 downto 0);
      servo_mode_ch0_o        : out std_logic_vector(SERVO_MODE_SEL_WIDTH-1 downto 0);
      adc_offset_dat_ch1_o    : out std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
      adc_offset_addr_ch1_i   : in  std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0);
      servo_rst_addr_ch1_i    : in  std_logic_vector(SERVO_RST_ADDR_WIDTH-1 downto 0);
      servo_rst_addr2_ch1_i   : in  std_logic_vector(SERVO_RST_ADDR_WIDTH-1 downto 0);            
      p_dat_ch1_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      p_addr_ch1_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      i_dat_ch1_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      i_addr_ch1_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      d_dat_ch1_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      d_addr_ch1_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      flux_quanta_dat_ch1_o   : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      flux_quanta_addr_ch1_i  : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      sa_bias_ch1_o           : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      sa_bias_rdy_ch1_o       : out std_logic;
      offset_dat_ch1_o        : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      offset_dat_rdy_ch1_o    : out std_logic;
      const_val_ch1_o         : out std_logic_vector(CONST_VAL_WIDTH-1 downto 0);
      servo_mode_ch1_o        : out std_logic_vector(SERVO_MODE_SEL_WIDTH-1 downto 0);
      adc_offset_dat_ch2_o    : out std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
      adc_offset_addr_ch2_i   : in  std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0);
      servo_rst_addr_ch2_i    : in  std_logic_vector(SERVO_RST_ADDR_WIDTH-1 downto 0);
      servo_rst_addr2_ch2_i   : in  std_logic_vector(SERVO_RST_ADDR_WIDTH-1 downto 0);      
      p_dat_ch2_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      p_addr_ch2_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      i_dat_ch2_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      i_addr_ch2_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      d_dat_ch2_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      d_addr_ch2_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      flux_quanta_dat_ch2_o   : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      flux_quanta_addr_ch2_i  : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      sa_bias_ch2_o           : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      sa_bias_rdy_ch2_o       : out std_logic;
      offset_dat_ch2_o        : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      offset_dat_rdy_ch2_o    : out std_logic;
      const_val_ch2_o         : out std_logic_vector(CONST_VAL_WIDTH-1 downto 0);
      servo_mode_ch2_o        : out std_logic_vector(SERVO_MODE_SEL_WIDTH-1 downto 0);
      adc_offset_dat_ch3_o    : out std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
      adc_offset_addr_ch3_i   : in  std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0);
      servo_rst_addr_ch3_i    : in  std_logic_vector(SERVO_RST_ADDR_WIDTH-1 downto 0);
      servo_rst_addr2_ch3_i   : in  std_logic_vector(SERVO_RST_ADDR_WIDTH-1 downto 0);      
      p_dat_ch3_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      p_addr_ch3_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      i_dat_ch3_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      i_addr_ch3_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      d_dat_ch3_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      d_addr_ch3_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      flux_quanta_dat_ch3_o   : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      flux_quanta_addr_ch3_i  : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      sa_bias_ch3_o           : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      sa_bias_rdy_ch3_o       : out std_logic;
      offset_dat_ch3_o        : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      offset_dat_rdy_ch3_o    : out std_logic;
      const_val_ch3_o         : out std_logic_vector(CONST_VAL_WIDTH-1 downto 0);
      servo_mode_ch3_o        : out std_logic_vector(SERVO_MODE_SEL_WIDTH-1 downto 0);
      adc_offset_dat_ch4_o    : out std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
      adc_offset_addr_ch4_i   : in  std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0);
      servo_rst_addr_ch4_i    : in  std_logic_vector(SERVO_RST_ADDR_WIDTH-1 downto 0);
      servo_rst_addr2_ch4_i   : in  std_logic_vector(SERVO_RST_ADDR_WIDTH-1 downto 0);      
      p_dat_ch4_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      p_addr_ch4_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      i_dat_ch4_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      i_addr_ch4_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      d_dat_ch4_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      d_addr_ch4_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      flux_quanta_dat_ch4_o   : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      flux_quanta_addr_ch4_i  : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      sa_bias_ch4_o           : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      sa_bias_rdy_ch4_o       : out std_logic;
      offset_dat_ch4_o        : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      offset_dat_rdy_ch4_o    : out std_logic;
      const_val_ch4_o         : out std_logic_vector(CONST_VAL_WIDTH-1 downto 0);
      servo_mode_ch4_o        : out std_logic_vector(SERVO_MODE_SEL_WIDTH-1 downto 0);
      adc_offset_dat_ch5_o    : out std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
      adc_offset_addr_ch5_i   : in  std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0);
      servo_rst_addr_ch5_i    : in  std_logic_vector(SERVO_RST_ADDR_WIDTH-1 downto 0);
      servo_rst_addr2_ch5_i   : in  std_logic_vector(SERVO_RST_ADDR_WIDTH-1 downto 0);      
      p_dat_ch5_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      p_addr_ch5_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      i_dat_ch5_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      i_addr_ch5_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      d_dat_ch5_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      d_addr_ch5_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      flux_quanta_dat_ch5_o   : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      flux_quanta_addr_ch5_i  : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      sa_bias_ch5_o           : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      sa_bias_rdy_ch5_o       : out std_logic;
      offset_dat_ch5_o        : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      offset_dat_rdy_ch5_o    : out std_logic;
      const_val_ch5_o         : out std_logic_vector(CONST_VAL_WIDTH-1 downto 0);
      servo_mode_ch5_o        : out std_logic_vector(SERVO_MODE_SEL_WIDTH-1 downto 0);
      adc_offset_dat_ch6_o    : out std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
      adc_offset_addr_ch6_i   : in  std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0);
      servo_rst_addr_ch6_i    : in  std_logic_vector(SERVO_RST_ADDR_WIDTH-1 downto 0);
      servo_rst_addr2_ch6_i   : in  std_logic_vector(SERVO_RST_ADDR_WIDTH-1 downto 0);      
      p_dat_ch6_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      p_addr_ch6_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      i_dat_ch6_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      i_addr_ch6_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      d_dat_ch6_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      d_addr_ch6_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      flux_quanta_dat_ch6_o   : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      flux_quanta_addr_ch6_i  : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      sa_bias_ch6_o           : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      sa_bias_rdy_ch6_o       : out std_logic;
      offset_dat_ch6_o        : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      offset_dat_rdy_ch6_o    : out std_logic;
      const_val_ch6_o         : out std_logic_vector(CONST_VAL_WIDTH-1 downto 0);
      servo_mode_ch6_o        : out std_logic_vector(SERVO_MODE_SEL_WIDTH-1 downto 0);
      adc_offset_dat_ch7_o    : out std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
      adc_offset_addr_ch7_i   : in  std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0);
      servo_rst_addr_ch7_i    : in  std_logic_vector(SERVO_RST_ADDR_WIDTH-1 downto 0);
      servo_rst_addr2_ch7_i   : in  std_logic_vector(SERVO_RST_ADDR_WIDTH-1 downto 0);      
      p_dat_ch7_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      p_addr_ch7_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      i_dat_ch7_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      i_addr_ch7_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      d_dat_ch7_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      d_addr_ch7_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      flux_quanta_dat_ch7_o   : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      flux_quanta_addr_ch7_i  : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      sa_bias_ch7_o           : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      sa_bias_rdy_ch7_o       : out std_logic;
      offset_dat_ch7_o        : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      offset_dat_rdy_ch7_o    : out std_logic;
      const_val_ch7_o         : out std_logic_vector(CONST_VAL_WIDTH-1 downto 0);
      servo_mode_ch7_o        : out std_logic_vector(SERVO_MODE_SEL_WIDTH-1 downto 0);
      filter_coeff0_o         : out std_logic_vector(FILTER_COEF_WIDTH-1 downto 0);
      filter_coeff1_o         : out std_logic_vector(FILTER_COEF_WIDTH-1 downto 0);
      filter_coeff2_o         : out std_logic_vector(FILTER_COEF_WIDTH-1 downto 0);
      filter_coeff3_o         : out std_logic_vector(FILTER_COEF_WIDTH-1 downto 0);
      filter_coeff4_o         : out std_logic_vector(FILTER_COEF_WIDTH-1 downto 0);
      filter_coeff5_o         : out std_logic_vector(FILTER_COEF_WIDTH-1 downto 0);
      filter_coeff6_o         : out std_logic_vector(FILTER_COEF_WIDTH-1 downto 0);
      ramp_step_size_o        : out std_logic_vector(RAMP_STEP_WIDTH-1 downto 0);
      ramp_amp_o              : out std_logic_vector(RAMP_AMP_WIDTH-1 downto 0);
      num_ramp_frame_cycles_o : out std_logic_vector(RAMP_CYC_WIDTH-1 downto 0);
      flux_jumping_en_o       : out std_logic;
      i_clamp_val_o           : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      qterm_decay_bits_o      : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      dat_i                   : in  std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      addr_i                  : in  std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
      tga_i                   : in  std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
      we_i                    : in  std_logic;
      stb_i                   : in  std_logic;
      cyc_i                   : in  std_logic;
      dat_o                   : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      ack_o                   : out std_logic
   );
   end component;

end flux_loop_pack;

