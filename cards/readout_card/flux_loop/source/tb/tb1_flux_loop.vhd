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
-- tb1_flux_loop.vhd
--
-- Project:       SCUBA-2
-- Author:        Mohsen Nahvi & Anthony Ko
-- Organisation:  UBC
--
-- Description:
-- This testbench tests the integration of eight flux_loop_ctrl and one of
-- wbs_fb_data and wbs_frame_data.
-- 
-- The architecture of this test bench follows tb2_flux_loop_ctrl.
--
-- The frame_timing signals are provided to the testbench by instantiating the 
-- frame_timing library component. 
-- 
-- This testbench is for: 
-- 
-- Lock Mode: where fsfb_calc in the flux_loop_ctrl gets the values from
-- adc_sample_coadd and outputs PIDZ error values.
-- For the Lock Mode, we perform a selfcheck. The selfcheck relies on a random
-- value generated block(LFSR) to assign values  to adc_dat_i.
--
-- The following operation is performed:
--
-- Emulating the behaviour of the Dispatch, we write new values inot P/I/D/Z,
-- adc_offset, filter_coeff, servo_mode, ramp_step_size, ramp_amp, const_val,
-- num_ramp_frame_cycles, sa_bias, and offset_dat paramters.
-- 
-- We write a new piece of data to adc_dat_i on the FALLING edge of the clk
-- to mimick the data coming from A/D.  Note that data from A/D is ready on the
-- falling edge of adc_en_clk.
--
-- We excite wbs_frame_data by emulating proper commands as sent by Dispatch
-- and we monitor wbs_frame_data output and perform selfcheck.
--
-- Revision history:
-- 
-- $Log: tb1_flux_loop.vhd,v $
-- Revision 1.3  2004/12/10 23:57:25  mohsen
-- Sorted out the size of RAW data read by creating new signal and read procedure.
-- Completed read and write commands from wbs_frame_data that
-- created a hang in the test bench to match the new version of
-- wbs_frame_data that can handle those cases.
--
-- Revision 1.2  2004/12/10 00:01:24  mohsen
-- Added comments
--
-- Revision 1.1  2004/12/07 19:48:19  mohsen
-- Anthony & Mohsen: Initial release
--
--
--
--
------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
--use ieee.numeric_std.all;


library components;
use components.component_pack.all;

library sys_param;
use sys_param.wishbone_pack.all;
use sys_param.command_pack.all;

library work;

-- DUT Library Call
use work.flux_loop_pack.all;

-- library for parents
use work.readout_card_pack.all;

-- library for frame timing core
use work.frame_timing_core_pack.all;

-- library for sync gen core
use work.sync_gen_core_pack.all;


entity tb1_flux_loop is
  
end tb1_flux_loop;


architecture beh of tb1_flux_loop is

  
  -- DUT component declaration
  component flux_loop
    port (
      clk_50_i                  : in  std_logic;
      clk_25_i                  : in  std_logic;
      rst_i                     : in  std_logic;
      adc_coadd_en_i            : in  std_logic;
      restart_frame_1row_prev_i : in  std_logic;
      restart_frame_aligned_i   : in  std_logic;
      restart_frame_1row_post_i : in  std_logic;
      row_switch_i              : in  std_logic;
      initialize_window_i       : in  std_logic;
      num_rows_sub1_i           : in  std_logic_vector(FSFB_QUEUE_ADDR_WIDTH-1 downto 0);
      dac_dat_en_i              : in  std_logic;
      dat_i                     : in  std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      addr_i                    : in  std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
      tga_i                     : in  std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
      we_i                      : in  std_logic;
      stb_i                     : in  std_logic;
      cyc_i                     : in  std_logic;
      dat_frame_o               : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      ack_frame_o               : out std_logic;
      dat_fb_o                  : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      ack_fb_o                  : out std_logic;
      adc_dat_ch0_i             : in  std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
      adc_dat_ch1_i             : in  std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
      adc_dat_ch2_i             : in  std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
      adc_dat_ch3_i             : in  std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
      adc_dat_ch4_i             : in  std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
      adc_dat_ch5_i             : in  std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
      adc_dat_ch6_i             : in  std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
      adc_dat_ch7_i             : in  std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
      adc_ovr_ch0_i             : in  std_logic;
      adc_ovr_ch1_i             : in  std_logic;
      adc_ovr_ch2_i             : in  std_logic;
      adc_ovr_ch3_i             : in  std_logic;
      adc_ovr_ch4_i             : in  std_logic;
      adc_ovr_ch5_i             : in  std_logic;
      adc_ovr_ch6_i             : in  std_logic;
      adc_ovr_ch7_i             : in  std_logic;
      adc_rdy_ch0_i             : in  std_logic;
      adc_rdy_ch1_i             : in  std_logic;
      adc_rdy_ch2_i             : in  std_logic;
      adc_rdy_ch3_i             : in  std_logic;
      adc_rdy_ch4_i             : in  std_logic;
      adc_rdy_ch5_i             : in  std_logic;
      adc_rdy_ch6_i             : in  std_logic;
      adc_rdy_ch7_i             : in  std_logic;
      adc_clk_ch0_o             : out std_logic;
      adc_clk_ch1_o             : out std_logic;
      adc_clk_ch2_o             : out std_logic;
      adc_clk_ch3_o             : out std_logic;
      adc_clk_ch4_o             : out std_logic;
      adc_clk_ch5_o             : out std_logic;
      adc_clk_ch6_o             : out std_logic;
      adc_clk_ch7_o             : out std_logic;
      dac_dat_ch0_o             : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
      dac_dat_ch1_o             : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
      dac_dat_ch2_o             : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
      dac_dat_ch3_o             : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
      dac_dat_ch4_o             : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
      dac_dat_ch5_o             : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
      dac_dat_ch6_o             : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
      dac_dat_ch7_o             : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
      dac_clk_ch0_o             : out std_logic;
      dac_clk_ch1_o             : out std_logic;
      dac_clk_ch2_o             : out std_logic;
      dac_clk_ch3_o             : out std_logic;
      dac_clk_ch4_o             : out std_logic;
      dac_clk_ch5_o             : out std_logic;
      dac_clk_ch6_o             : out std_logic;
      dac_clk_ch7_o             : out std_logic;
      sa_bias_dac_spi_ch0_o     : out std_logic_vector(SA_BIAS_SPI_DATA_WIDTH-1 downto 0);
      sa_bias_dac_spi_ch1_o     : out std_logic_vector(SA_BIAS_SPI_DATA_WIDTH-1 downto 0);
      sa_bias_dac_spi_ch2_o     : out std_logic_vector(SA_BIAS_SPI_DATA_WIDTH-1 downto 0);
      sa_bias_dac_spi_ch3_o     : out std_logic_vector(SA_BIAS_SPI_DATA_WIDTH-1 downto 0);
      sa_bias_dac_spi_ch4_o     : out std_logic_vector(SA_BIAS_SPI_DATA_WIDTH-1 downto 0);
      sa_bias_dac_spi_ch5_o     : out std_logic_vector(SA_BIAS_SPI_DATA_WIDTH-1 downto 0);
      sa_bias_dac_spi_ch6_o     : out std_logic_vector(SA_BIAS_SPI_DATA_WIDTH-1 downto 0);
      sa_bias_dac_spi_ch7_o     : out std_logic_vector(SA_BIAS_SPI_DATA_WIDTH-1 downto 0);
      offset_dac_spi_ch0_o      : out std_logic_vector(OFFSET_SPI_DATA_WIDTH-1 downto 0);
      offset_dac_spi_ch1_o      : out std_logic_vector(OFFSET_SPI_DATA_WIDTH-1 downto 0);
      offset_dac_spi_ch2_o      : out std_logic_vector(OFFSET_SPI_DATA_WIDTH-1 downto 0);
      offset_dac_spi_ch3_o      : out std_logic_vector(OFFSET_SPI_DATA_WIDTH-1 downto 0);
      offset_dac_spi_ch4_o      : out std_logic_vector(OFFSET_SPI_DATA_WIDTH-1 downto 0);
      offset_dac_spi_ch5_o      : out std_logic_vector(OFFSET_SPI_DATA_WIDTH-1 downto 0);
      offset_dac_spi_ch6_o      : out std_logic_vector(OFFSET_SPI_DATA_WIDTH-1 downto 0);
      offset_dac_spi_ch7_o      : out std_logic_vector(OFFSET_SPI_DATA_WIDTH-1 downto 0)
    );
  end component flux_loop;


  -- DUT Signals
  signal clk_50_i                  : std_logic;
  signal clk_25_i                  : std_logic;
  signal rst_i                     : std_logic;
  signal adc_coadd_en_i            : std_logic;
  signal restart_frame_1row_prev_i : std_logic;
  signal restart_frame_aligned_i   : std_logic;
  signal restart_frame_1row_post_i : std_logic;
  signal row_switch_i              : std_logic;
  signal initialize_window_i       : std_logic;
  signal num_rows_sub1_i           : std_logic_vector(FSFB_QUEUE_ADDR_WIDTH-1 downto 0);
  signal dac_dat_en_i              : std_logic;
  signal dat_i                     : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal addr_i                    : std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
  signal tga_i                     : std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
  signal we_i                      : std_logic;
  signal stb_i                     : std_logic;
  signal cyc_i                     : std_logic;
  signal dat_frame_o               : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal ack_frame_o               : std_logic;
  signal dat_fb_o                  : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal ack_fb_o                  : std_logic;
  signal adc_dat_ch0_i             : std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
  signal adc_dat_ch1_i             : std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
  signal adc_dat_ch2_i             : std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
  signal adc_dat_ch3_i             : std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
  signal adc_dat_ch4_i             : std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
  signal adc_dat_ch5_i             : std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
  signal adc_dat_ch6_i             : std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
  signal adc_dat_ch7_i             : std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
  signal adc_ovr_ch0_i             : std_logic;
  signal adc_ovr_ch1_i             : std_logic;
  signal adc_ovr_ch2_i             : std_logic;
  signal adc_ovr_ch3_i             : std_logic;
  signal adc_ovr_ch4_i             : std_logic;
  signal adc_ovr_ch5_i             : std_logic;
  signal adc_ovr_ch6_i             : std_logic;
  signal adc_ovr_ch7_i             : std_logic;
  signal adc_rdy_ch0_i             : std_logic;
  signal adc_rdy_ch1_i             : std_logic;
  signal adc_rdy_ch2_i             : std_logic;
  signal adc_rdy_ch3_i             : std_logic;
  signal adc_rdy_ch4_i             : std_logic;
  signal adc_rdy_ch5_i             : std_logic;
  signal adc_rdy_ch6_i             : std_logic;
  signal adc_rdy_ch7_i             : std_logic;
  signal adc_clk_ch0_o             : std_logic;
  signal adc_clk_ch1_o             : std_logic;
  signal adc_clk_ch2_o             : std_logic;
  signal adc_clk_ch3_o             : std_logic;
  signal adc_clk_ch4_o             : std_logic;
  signal adc_clk_ch5_o             : std_logic;
  signal adc_clk_ch6_o             : std_logic;
  signal adc_clk_ch7_o             : std_logic;
  signal dac_dat_ch0_o             : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
  signal dac_dat_ch1_o             : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
  signal dac_dat_ch2_o             : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
  signal dac_dat_ch3_o             : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
  signal dac_dat_ch4_o             : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
  signal dac_dat_ch5_o             : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
  signal dac_dat_ch6_o             : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
  signal dac_dat_ch7_o             : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
  signal dac_clk_ch0_o             : std_logic;
  signal dac_clk_ch1_o             : std_logic;
  signal dac_clk_ch2_o             : std_logic;
  signal dac_clk_ch3_o             : std_logic;
  signal dac_clk_ch4_o             : std_logic;
  signal dac_clk_ch5_o             : std_logic;
  signal dac_clk_ch6_o             : std_logic;
  signal dac_clk_ch7_o             : std_logic;
  signal sa_bias_dac_spi_ch0_o     : std_logic_vector(SA_BIAS_SPI_DATA_WIDTH-1 downto 0);
  signal sa_bias_dac_spi_ch1_o     : std_logic_vector(SA_BIAS_SPI_DATA_WIDTH-1 downto 0);
  signal sa_bias_dac_spi_ch2_o     : std_logic_vector(SA_BIAS_SPI_DATA_WIDTH-1 downto 0);
  signal sa_bias_dac_spi_ch3_o     : std_logic_vector(SA_BIAS_SPI_DATA_WIDTH-1 downto 0);
  signal sa_bias_dac_spi_ch4_o     : std_logic_vector(SA_BIAS_SPI_DATA_WIDTH-1 downto 0);
  signal sa_bias_dac_spi_ch5_o     : std_logic_vector(SA_BIAS_SPI_DATA_WIDTH-1 downto 0);
  signal sa_bias_dac_spi_ch6_o     : std_logic_vector(SA_BIAS_SPI_DATA_WIDTH-1 downto 0);
  signal sa_bias_dac_spi_ch7_o     : std_logic_vector(SA_BIAS_SPI_DATA_WIDTH-1 downto 0);
  signal offset_dac_spi_ch0_o      : std_logic_vector(OFFSET_SPI_DATA_WIDTH-1 downto 0);
  signal offset_dac_spi_ch1_o      : std_logic_vector(OFFSET_SPI_DATA_WIDTH-1 downto 0);
  signal offset_dac_spi_ch2_o      : std_logic_vector(OFFSET_SPI_DATA_WIDTH-1 downto 0);
  signal offset_dac_spi_ch3_o      : std_logic_vector(OFFSET_SPI_DATA_WIDTH-1 downto 0);
  signal offset_dac_spi_ch4_o      : std_logic_vector(OFFSET_SPI_DATA_WIDTH-1 downto 0);
  signal offset_dac_spi_ch5_o      : std_logic_vector(OFFSET_SPI_DATA_WIDTH-1 downto 0);
  signal offset_dac_spi_ch6_o      : std_logic_vector(OFFSET_SPI_DATA_WIDTH-1 downto 0);
  signal offset_dac_spi_ch7_o      : std_logic_vector(OFFSET_SPI_DATA_WIDTH-1 downto 0);
  

  -- tb1 constants/signals
  constant PERIOD                  : time    := 20 ns;      -- 50 MHz system clock
  constant EDGE_DEPENDENCY         : time    := 2 ns;       -- shows clk edge dependency
  constant RESET_WINDOW            : time    := 8*PERIOD;
  constant FREE_RUN                : time    := 19*PERIOD;
  constant CLOCKS_PER_ROW          : integer := 64;
  constant ROWS_PER_FRAME          : integer := 41;
  

  -- the following two values need to match the actual fsfb_ctrl HW generic  
  constant CONVERSION_POLARITY_MODE : integer := 0;      -- 0, straight/1, reverse polarity                                                        
  constant FSFB_ACCURACY_POSITION   : integer := 13;
    

  signal reset_window_done          : boolean := false;  -- asserted to denote reset completed
  signal finish_tb1                 : boolean := false;  -- asserted to end tb
  signal finish_test_flux_loop      : boolean := false;  -- asserted to end flux_loop test
  signal finish_wbs_fb_data         : boolean := false;  -- asserted when we complete configure wbs_fb_data
  

   -- the following is used to store the PIDZ and ADC offset values read from the wbs_fb_data
   type block_array is array (0 to 41*8-1) of std_logic_vector(31 downto 0);
   type block_array2 is array (0 to 2*41*8*64-1) of std_logic_vector(31 downto 0);

  
   -- Offset/Sa Bias Control Value 
   -- Only the first 8 elements are used; 1 per channel
   signal OFFSET_CTRL_ALL  : block_array  := (others => (others => '0'));
   signal SA_BIAS_CTRL_ALL : block_array  := (others => (others => '0'));
   signal INVALID_READ     : block_array  := (others => (others => '0'));
  

   -- The following arrays are the copy of parameters in the flux loop that we
   -- use in the tb.
   -- CHANNEL 0
   signal P_CH0        : block_array := (others => (others => '0'));
   signal I_CH0        : block_array := (others => (others => '0'));
   signal D_CH0        : block_array := (others => (others => '0'));
   signal Z_CH0        : block_array := (others => (others => '0'));
   signal OFFSET_CH0   : block_array := (others => (others => '0'));
   signal UNFILTER_CH0 : block_array := (others => (others => '0'));
   signal FB_ERROR_CH0 : block_array := (others => (others => '0'));
   signal RAW_CH0      : block_array2 := (others => (others => '0'));
  
   -- CHANNEL 1
   --signal P_CH1        : block_array := (others => (others => '0'));
   --signal I_CH1        : block_array := (others => (others => '0'));
   --signal D_CH1        : block_array := (others => (others => '0'));
   --signal Z_CH1        : block_array := (others => (others => '0'));
   --signal OFFSET_CH1   : block_array := (others => (others => '0'));
   --signal UNFILTER_CH1 : block_array := (others => (others => '0'));
   --signal FB_ERROR_CH1 : block_array := (others => (others => '0'));

   -- CHANNEL 2
   --signal P_CH2        : block_array := (others => (others => '0'));
   --signal I_CH2        : block_array := (others => (others => '0'));
   --signal D_CH2        : block_array := (others => (others => '0'));
   --signal Z_CH2        : block_array := (others => (others => '0'));
   --signal OFFSET_CH2   : block_array := (others => (others => '0'));
   --signal UNFILTER_CH2 : block_array := (others => (others => '0'));
   --signal FB_ERROR_CH2 : block_array := (others => (others => '0'));

   -- CHANNEL 3
   --signal P_CH3        : block_array := (others => (others => '0'));
   --signal I_CH3        : block_array := (others => (others => '0'));
   --signal D_CH3        : block_array := (others => (others => '0'));
   --signal Z_CH3        : block_array := (others => (others => '0'));
   --signal OFFSET_CH3   : block_array := (others => (others => '0'));
   --signal UNFILTER_CH3 : block_array := (others => (others => '0'));
   --signal FB_ERROR_CH3 : block_array := (others => (others => '0'));
   
   -- CHANNEL 4
   --signal P_CH4        : block_array := (others => (others => '0'));
   --signal I_CH4        : block_array := (others => (others => '0'));
   --signal D_CH4        : block_array := (others => (others => '0'));
   --signal Z_CH4        : block_array := (others => (others => '0'));
   --signal OFFSET_CH4   : block_array := (others => (others => '0'));
   --signal UNFILTER_CH4 : block_array := (others => (others => '0'));
   --signal FB_ERROR_CH4 : block_array := (others => (others => '0'));

   -- CHANNEL 5
   --signal P_CH5        : block_array := (others => (others => '0'));
   --signal I_CH5        : block_array := (others => (others => '0'));
   --signal D_CH5        : block_array := (others => (others => '0'));
   --signal Z_CH5        : block_array := (others => (others => '0'));
   --signal OFFSET_CH5   : block_array := (others => (others => '0'));
   --signal UNFILTER_CH5 : block_array := (others => (others => '0'));
   --signal FB_ERROR_CH5 : block_array := (others => (others => '0'));
   
   -- CHANNEL 6
   --signal P_CH6        : block_array := (others => (others => '0'));
   --signal I_CH6        : block_array := (others => (others => '0'));
   --signal D_CH6        : block_array := (others => (others => '0'));
   --signal Z_CH6        : block_array := (others => (others => '0'));
   --signal OFFSET_CH6   : block_array := (others => (others => '0'));
   --signal UNFILTER_CH6 : block_array := (others => (others => '0'));
   --signal FB_ERROR_CH6 : block_array := (others => (others => '0'));
   
   -- CHANNEL 7
   --signal P_CH7        : block_array := (others => (others => '0'));
   --signal I_CH7        : block_array := (others => (others => '0'));
   --signal D_CH7        : block_array := (others => (others => '0'));
   --signal Z_CH7        : block_array := (others => (others => '0'));
   --signal OFFSET_CH7   : block_array := (others => (others => '0'));
   --signal UNFILTER_CH7 : block_array := (others => (others => '0'));
   --signal FB_ERROR_CH7 : block_array := (others => (others => '0'));


  -- Signals to separte the wbs_fb_data and wbs_frame_data
  signal dat_fb_i                     : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal addr_fb_i                    : std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
  signal tga_fb_i                     : std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
  signal we_fb_i                      : std_logic;
  signal stb_fb_i                     : std_logic;
  signal cyc_fb_i                     : std_logic;

  signal dat_frame_i                  : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal addr_frame_i                 : std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
  signal tga_frame_i                  : std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
  signal we_frame_i                   : std_logic;
  signal stb_frame_i                  : std_logic;
  signal cyc_frame_i                  : std_logic;
  
  
  -- for selfcheck process
  signal adc_offset_dat_ch0   : std_logic_vector(15 downto 0);
  signal adc_offset_addr_ch0  : std_logic_vector(5 downto 0);
  
  --signal adc_offset_dat_ch1   : std_logic_vector(15 downto 0);
  --signal adc_offset_addr_ch1  : std_logic_vector(5 downto 0);
  
  --signal adc_offset_dat_ch2   : std_logic_vector(15 downto 0);
  --signal adc_offset_addr_ch2  : std_logic_vector(5 downto 0);

  --signal adc_offset_dat_ch3   : std_logic_vector(15 downto 0);
  --signal adc_offset_addr_ch3  : std_logic_vector(5 downto 0);

  --signal adc_offset_dat_ch4   : std_logic_vector(15 downto 0);
  --signal adc_offset_addr_ch4  : std_logic_vector(5 downto 0);
  
  --signal adc_offset_dat_ch5   : std_logic_vector(15 downto 0);
  --signal adc_offset_addr_ch5  : std_logic_vector(5 downto 0);

  --signal adc_offset_dat_ch6   : std_logic_vector(15 downto 0);
  --signal adc_offset_addr_ch6  : std_logic_vector(5 downto 0);

  --signal adc_offset_dat_ch7   : std_logic_vector(15 downto 0);
  --signal adc_offset_addr_ch7  : std_logic_vector(5 downto 0);

  signal coadded_addr         : std_logic_vector(5 downto 0);
  
  type memory_bank  is array (0 to 63) of integer;
  
  type memory_bank_vector32 is array (0 to 63) of std_logic_vector(31 downto 0);

  signal integral_bank0       : memory_bank_vector32;          -- bank0 for integral values
  signal integral_bank1       : memory_bank_vector32;          -- bank1 for integral values
  signal coadd_bank0          : memory_bank_vector32;          -- bank0 for coadded values
  signal coadd_bank1          : memory_bank_vector32;          -- bank1 for coadded values


  type memory_bank_vector66 is array (0 to 63) of std_logic_vector(65 downto 0);
  
  signal filter_bank0         : memory_bank_vector66;          -- bank0 holds current filter/previous DAC control value
  signal filter_bank1         : memory_bank_vector66;          -- same as bank0 
  
  signal lfsr_o               : std_logic_vector(13 downto 0);
  signal adc_coadd_en_dly     : std_logic_vector(5 downto 0);  -- delyed adc_en
  signal current_bank         : std_logic :='0';               -- similar copy to DUT internal sig
  signal current_bank_ctrl    : std_logic := '1';              -- for DAC controller
  signal current_bank_fltr    : std_logic := '0';
  signal address_index        : integer :=0;                   -- points to row in memory
  signal coadded_value        : integer;                       -- hold coadd values at any time
  signal diff_value           : integer;                       -- difference value
  
  signal found_filter_error   : boolean := false;              -- asserted if fsfb filter error found (not used)
  signal found_ctrl_error     : boolean := false;              -- asserted if fsfb control error found (not used)
  signal found_dac_error      : boolean := false;              -- asserted if control DAC error found
  signal found_error_unfilter : boolean := false;              -- asserted if UNFILTER read in wbs_frame_data is in error
  signal found_error_fb_error : boolean := false;              -- asserted if FB_ERROR read in wbs_frame_data is in error
  
  signal address_index_plus1  : integer :=1;                   -- points to row+1 in memory 
  signal addr_plus1_inc_ok    : boolean := true;               -- flags wrap around for address_index_plus1

  -- frame timing related
  signal init_window_req_i    : std_logic :='0';               -- initialize window command request
  signal sample_num_i         : integer := 40;                 -- number of samples to collect (needed by frame timing)
  signal sample_delay_i       : integer := 10;                 -- number of delays before sampling (needed by frame timing)
  signal feedback_delay_i     : integer := 6;                  
  signal clk_200_i            : std_logic;                     -- mem_clk
  signal sync                 : std_logic;                     -- output from sync_core
  
  -- offset/sa_bias ctrl test signals (channel 0)
  signal sc_data1             : std_logic_vector(15 downto 0); -- serial captured data (SA_Bias)
  signal sc_data2             : std_logic_vector(15 downto 0); -- serial captured data (Offset)


  -----------------------------------------------------------------------------
  -- Procedures
  -----------------------------------------------------------------------------

  -- Procedure for writing data into wbs_fb_data
  procedure write_wbs_data (
    signal   clk_i              : in std_logic;
    signal   ack_i              : in std_logic;
    constant address_to_write_i : in std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
    constant data_to_write_i    : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    constant num_dat_word_i     : in integer;
    constant master_wait_flg_i  : in boolean;  -- should the master wait?
    constant master_wait_cyc_i  : in integer;  -- where in cycles to wait?
    signal   dat_o              : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    signal   addr_o             : out std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
    signal   tga_o              : out std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
    signal   we_o               : out std_logic;
    signal   stb_o              : out std_logic;
    signal   cyc_o              : out std_logic) is

    variable data_tmp : std_logic_vector(WB_DATA_WIDTH-1 downto 0) := (others =>'0');
    variable tga      : std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0) := (others =>'0');
    
  begin
    tga_o <= (others => '0') after EDGE_DEPENDENCY;
    tga   := (others => '0');
      
    wait until rising_edge(clk_i);
    data_tmp := data_to_write_i;
    addr_o <= address_to_write_i after EDGE_DEPENDENCY;
    stb_o  <= '1' after EDGE_DEPENDENCY;
    cyc_o  <= '1' after EDGE_DEPENDENCY;
    we_o   <= '1' after EDGE_DEPENDENCY;
  
    for i in 1 to num_dat_word_i loop
      dat_o    <= data_tmp after EDGE_DEPENDENCY;
      data_tmp := data_tmp +7;

      wait for PERIOD;

      while ack_i='0' loop
        wait for PERIOD;                 
      end loop;
                
      -- assert a wait cycle by master
      if master_wait_flg_i then
        if i=master_wait_cyc_i then
          stb_o <= '0' after EDGE_DEPENDENCY;
          wait for 29*PERIOD;
          stb_o <= '1' after EDGE_DEPENDENCY;
        end if;
      end if;

      -- avoid incrementing for the last value
      if i< num_dat_word_i then
        tga := tga+1;
      end if;
        
      tga_o <= tga after EDGE_DEPENDENCY;
     
    end loop;  -- i
      
    stb_o <= '0' after EDGE_DEPENDENCY;
    cyc_o <= '0' after EDGE_DEPENDENCY;
    we_o  <= '0' after EDGE_DEPENDENCY;
        
  end procedure write_wbs_data;

    
  -- Procedure for reading data from wbs_fb_data
  -- Maximum size of read data block is 41*8 words
  procedure read_wbs_data (
    signal clk_i     : in std_logic;
    signal ack_i     : in std_logic;
    signal dat_rd_i  : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    constant address_to_read_i : in std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
    constant num_dat_word_i     : in integer;
    constant master_wait_flg_i  : in boolean;  -- should the master wait?
    constant master_wait_cyc_i  : in integer;  -- where in cycles to wait?
    signal dat_rd_o  : out block_array;
    signal addr_o : out std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
    signal tga_o  : out std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
    signal we_o   : out std_logic;
    signal stb_o  : out std_logic;
    signal cyc_o  : out std_logic) is

    variable tga      : std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0) := (others =>'0');

  begin
    tga_o <= (others => '0') after EDGE_DEPENDENCY;
    tga   := (others => '0');
      
    wait until rising_edge(clk_i);
    addr_o <= address_to_read_i after EDGE_DEPENDENCY;
    stb_o  <= '1' after EDGE_DEPENDENCY;
    cyc_o  <= '1' after EDGE_DEPENDENCY;
    we_o   <= '0' after EDGE_DEPENDENCY;
   
    for i in 1 to num_dat_word_i loop   
      wait for PERIOD;

      while ack_i='0' loop
        wait for PERIOD;                 
      end loop;
        
      dat_rd_o(i-1) <= dat_rd_i after EDGE_DEPENDENCY;
                 
      -- assert a wait cycle by master
      if master_wait_flg_i then
        if i=master_wait_cyc_i then
          stb_o <= '0' after EDGE_DEPENDENCY;
          wait for 29*PERIOD;
          stb_o <= '1' after EDGE_DEPENDENCY;
        end if;
      end if;

      -- avoid incrementing for the last value
      if i< num_dat_word_i then
        tga := tga+1;
      end if;
        
      tga_o <= tga after EDGE_DEPENDENCY;
      
    end loop;  -- i
      
    stb_o <= '0' after EDGE_DEPENDENCY;
    cyc_o <= '0' after EDGE_DEPENDENCY;

  end procedure read_wbs_data; 
  
  -- Procedure for reading RAW data from wbs_fb_data
  -- Maximum size of read data block is 2*41*8*64 words
  procedure read_for_raw_wbs_data (
    signal clk_i               : in std_logic;
    signal ack_i               : in std_logic;
    signal dat_rd_i            : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
    constant address_to_read_i : in std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
    constant num_dat_word_i    : in integer;
    constant master_wait_flg_i : in boolean;  -- should the master wait?
    constant master_wait_cyc_i : in integer;  -- where in cycles to wait?
    signal dat_rd_o            : out block_array2;
    signal addr_o              : out std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
    signal tga_o               : out std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
    signal we_o                : out std_logic;
    signal stb_o               : out std_logic;
    signal cyc_o               : out std_logic) is

    variable tga      : std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0) := (others =>'0');

  begin
    tga_o <= (others => '0') after EDGE_DEPENDENCY;
    tga   := (others => '0');
      
    wait until rising_edge(clk_i);
    addr_o <= address_to_read_i after EDGE_DEPENDENCY;
    stb_o  <= '1' after EDGE_DEPENDENCY;
    cyc_o  <= '1' after EDGE_DEPENDENCY;
    we_o   <= '0' after EDGE_DEPENDENCY;
   
    for i in 1 to num_dat_word_i loop   
      wait for PERIOD;

      while ack_i='0' loop
        wait for PERIOD;                 
      end loop;
        
      dat_rd_o(i-1) <= dat_rd_i after EDGE_DEPENDENCY;
                 
      -- assert a wait cycle by master
      if master_wait_flg_i then
        if i=master_wait_cyc_i then
          stb_o <= '0' after EDGE_DEPENDENCY;
          wait for 29*PERIOD;
          stb_o <= '1' after EDGE_DEPENDENCY;
        end if;
      end if;

      -- avoid incrementing for the last value
      if i< num_dat_word_i then
        tga := tga+1;
      end if;
        
      tga_o <= tga after EDGE_DEPENDENCY;
      
    end loop;  -- i
      
    stb_o <= '0' after EDGE_DEPENDENCY;
    cyc_o <= '0' after EDGE_DEPENDENCY;

  end procedure read_for_raw_wbs_data; 
 
begin  -- beh

  -----------------------------------------------------------------------------
  -- OUTPUT MUX for DISPATCH
  -----------------------------------------------------------------------------

  with finish_wbs_fb_data select
    dat_i <=
    dat_fb_i    when false,
    dat_frame_i when others;

  with finish_wbs_fb_data select
    addr_i <=
    addr_fb_i    when false,
    addr_frame_i when others;

  with finish_wbs_fb_data select
    tga_i <=
    tga_fb_i    when false,
    tga_frame_i when others;

  with finish_wbs_fb_data select
    we_i <=
    we_fb_i    when false,
    we_frame_i when others;
  
  with finish_wbs_fb_data select
    stb_i <=
    stb_fb_i    when false,
    stb_frame_i when others;

  with finish_wbs_fb_data select
    cyc_i <=
    cyc_fb_i    when false,
    cyc_frame_i when others;

  
  -----------------------------------------------------------------------------
  -- Instantiate DUT
  -----------------------------------------------------------------------------

  DUT: flux_loop
    port map (
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
        dat_i                     => dat_i,
        addr_i                    => addr_i,
        tga_i                     => tga_i,
        we_i                      => we_i,
        stb_i                     => stb_i,
        cyc_i                     => cyc_i,
        dat_frame_o               => dat_frame_o,
        ack_frame_o               => ack_frame_o,
        dat_fb_o                  => dat_fb_o,
        ack_fb_o                  => ack_fb_o,
        adc_dat_ch0_i             => adc_dat_ch0_i,
        adc_dat_ch1_i             => adc_dat_ch1_i,
        adc_dat_ch2_i             => adc_dat_ch2_i,
        adc_dat_ch3_i             => adc_dat_ch3_i,
        adc_dat_ch4_i             => adc_dat_ch4_i,
        adc_dat_ch5_i             => adc_dat_ch5_i,
        adc_dat_ch6_i             => adc_dat_ch6_i,
        adc_dat_ch7_i             => adc_dat_ch7_i,
        adc_ovr_ch0_i             => adc_ovr_ch0_i,
        adc_ovr_ch1_i             => adc_ovr_ch1_i,
        adc_ovr_ch2_i             => adc_ovr_ch2_i,
        adc_ovr_ch3_i             => adc_ovr_ch3_i,
        adc_ovr_ch4_i             => adc_ovr_ch4_i,
        adc_ovr_ch5_i             => adc_ovr_ch5_i,
        adc_ovr_ch6_i             => adc_ovr_ch6_i,
        adc_ovr_ch7_i             => adc_ovr_ch7_i,
        adc_rdy_ch0_i             => adc_rdy_ch0_i,
        adc_rdy_ch1_i             => adc_rdy_ch1_i,
        adc_rdy_ch2_i             => adc_rdy_ch2_i,
        adc_rdy_ch3_i             => adc_rdy_ch3_i,
        adc_rdy_ch4_i             => adc_rdy_ch4_i,
        adc_rdy_ch5_i             => adc_rdy_ch5_i,
        adc_rdy_ch6_i             => adc_rdy_ch6_i,
        adc_rdy_ch7_i             => adc_rdy_ch7_i,
        adc_clk_ch0_o             => adc_clk_ch0_o,
        adc_clk_ch1_o             => adc_clk_ch1_o,
        adc_clk_ch2_o             => adc_clk_ch2_o,
        adc_clk_ch3_o             => adc_clk_ch3_o,
        adc_clk_ch4_o             => adc_clk_ch4_o,
        adc_clk_ch5_o             => adc_clk_ch5_o,
        adc_clk_ch6_o             => adc_clk_ch6_o,
        adc_clk_ch7_o             => adc_clk_ch7_o,
        dac_dat_ch0_o             => dac_dat_ch0_o,
        dac_dat_ch1_o             => dac_dat_ch1_o,
        dac_dat_ch2_o             => dac_dat_ch2_o,
        dac_dat_ch3_o             => dac_dat_ch3_o,
        dac_dat_ch4_o             => dac_dat_ch4_o,
        dac_dat_ch5_o             => dac_dat_ch5_o,
        dac_dat_ch6_o             => dac_dat_ch6_o,
        dac_dat_ch7_o             => dac_dat_ch7_o,
        dac_clk_ch0_o             => dac_clk_ch0_o,
        dac_clk_ch1_o             => dac_clk_ch1_o,
        dac_clk_ch2_o             => dac_clk_ch2_o,
        dac_clk_ch3_o             => dac_clk_ch3_o,
        dac_clk_ch4_o             => dac_clk_ch4_o,
        dac_clk_ch5_o             => dac_clk_ch5_o,
        dac_clk_ch6_o             => dac_clk_ch6_o,
        dac_clk_ch7_o             => dac_clk_ch7_o,
        sa_bias_dac_spi_ch0_o     => sa_bias_dac_spi_ch0_o,
        sa_bias_dac_spi_ch1_o     => sa_bias_dac_spi_ch1_o,
        sa_bias_dac_spi_ch2_o     => sa_bias_dac_spi_ch2_o,
        sa_bias_dac_spi_ch3_o     => sa_bias_dac_spi_ch3_o,
        sa_bias_dac_spi_ch4_o     => sa_bias_dac_spi_ch4_o,
        sa_bias_dac_spi_ch5_o     => sa_bias_dac_spi_ch5_o,
        sa_bias_dac_spi_ch6_o     => sa_bias_dac_spi_ch6_o,
        sa_bias_dac_spi_ch7_o     => sa_bias_dac_spi_ch7_o,
        offset_dac_spi_ch0_o      => offset_dac_spi_ch0_o,
        offset_dac_spi_ch1_o      => offset_dac_spi_ch1_o,
        offset_dac_spi_ch2_o      => offset_dac_spi_ch2_o,
        offset_dac_spi_ch3_o      => offset_dac_spi_ch3_o,
        offset_dac_spi_ch4_o      => offset_dac_spi_ch4_o,
        offset_dac_spi_ch5_o      => offset_dac_spi_ch5_o,
        offset_dac_spi_ch6_o      => offset_dac_spi_ch6_o,
        offset_dac_spi_ch7_o      => offset_dac_spi_ch7_o);
  

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
    sample_delay_i            => sample_delay_i,
    sample_num_i              => sample_num_i,
    feedback_delay_i          => feedback_delay_i,
    address_on_delay_i        => 2,
    resync_req_i              => '0',
    resync_ack_o              => open,
    init_window_req_i         => init_window_req_i,
    init_window_ack_o         => open,
    clk_i                     => clk_50_i,
    mem_clk_i                 => clk_200_i,
    rst_i                     => rst_i,
    sync_i                    => sync);
    

  -----------------------------------------------------------------------------
  -- Instantiate sync_gen_core
  -----------------------------------------------------------------------------
  i_sync_gen_core : sync_gen_core

    port map (
    dv_en_i    => '0',
    dv_i       => '0',
    sync_o     => sync,
    sync_num_o => open,
    clk_i      => clk_50_i,
    mem_clk_i  => clk_200_i,
    rst_i      => rst_i);

  
  -----------------------------------------------------------------------------
  -- Clocking
  -----------------------------------------------------------------------------

  clocking_200: process
  begin  -- process clocking

    clk_200_i <= '1';
    wait for PERIOD/8;
    
    while (not finish_tb1) loop
      clk_200_i <= not clk_200_i;
      wait for PERIOD/8;
    end loop;

    wait;
    
  end process clocking_200;
 
  
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
  -- Request for initialize window
  -----------------------------------------------------------------------------

  i_initialize_window: process
  begin  -- process i_initialize_window
    wait for RESET_WINDOW + EDGE_DEPENDENCY;
    wait for FREE_RUN;

    
    while (not finish_test_flux_loop) loop
      
      wait for CLOCKS_PER_ROW*PERIOD*3;
        init_window_req_i <= '1',
                             '0' after PERIOD;
      wait for CLOCKS_PER_ROW*PERIOD*5000;
        init_window_req_i <= '1',
                             '0' after PERIOD;
      wait for CLOCKS_PER_ROW*PERIOD*300;
     
    end loop;

 
    -- wait for FREE_RUN;

    ---------------------------------------------------------------------------
    -- Go to sleep
    ---------------------------------------------------------------------------
    
    wait;
        
  end process i_initialize_window;


  -----------------------------------------------------------------------------
  -- Write a new piece of data into the adc_dat_ch#_i on each clock cycle. Note
  -- that we use negative edge of clk to mimick the data output of ADC that is
  -- valid after falling edge
  -----------------------------------------------------------------------------
  
  i_input_adc_dat: process (clk_50_i, rst_i)
  begin  -- process i_input_adc_dat
    if rst_i = '1' then                 -- asynchronous reset (active high)
      adc_dat_ch0_i <=(others => '0');      
    elsif clk_50_i'event and clk_50_i = '0' then  -- falling clock edge
      if (unsigned(lfsr_o)<=4000) then  -- avoid maxout due to adc_offset
        adc_dat_ch0_i <= lfsr_o;
      else
        adc_dat_ch0_i <= "00" & lfsr_o(11 downto 0);  -- lower the number
      end if;
    end if;
  end process i_input_adc_dat;

  adc_dat_ch1_i <= adc_dat_ch0_i;
  adc_dat_ch2_i <= adc_dat_ch0_i;
  adc_dat_ch3_i <= adc_dat_ch0_i;
  adc_dat_ch4_i <= adc_dat_ch0_i;
  adc_dat_ch5_i <= adc_dat_ch0_i;
  adc_dat_ch6_i <= adc_dat_ch0_i;
  adc_dat_ch7_i <= adc_dat_ch0_i;




  -----------------------------------------------------------------------------
  -- The following process excites the wbs_frame_data.
  -- It detects the restart_frame_1row_post_i and then waits for row_switch_i.
  -- This ensures that the wbs_frame_data is excited outside of the critical
  -- frame boundary.
  -- The process writes the "mode" value into the wbs_frame_data and then
  -- performs a read.
  -----------------------------------------------------------------------------

  i_excite_wbs_frame_data: process
    variable j : integer := 0;
    variable i : integer := 0;
    
  begin  -- process i_excite_wbs_frame_data
    dat_frame_i     <= (others => '0');
    addr_frame_i    <= (others => '0');
    tga_frame_i     <= (others => '0');
    we_frame_i      <= '0';
    stb_frame_i     <= '0';
    cyc_frame_i     <= '0';

    
    while (finish_wbs_fb_data = true) loop
      wait until falling_edge(restart_frame_1row_post_i);
      wait for PERIOD;
      wait until falling_edge(row_switch_i);

      -- Select UNFILTER MODE
      write_wbs_data(clk_50_i, ack_frame_o, DATA_MODE_ADDR, x"00000001", 1,
                        false, 0, dat_frame_i, addr_frame_i, tga_frame_i,
                        we_frame_i, stb_frame_i, cyc_frame_i);
      report "I am done with selecting UNFILTER Mode" severity NOTE;

      wait for FREE_RUN;

      -- read UNFILTER data
      read_wbs_data(clk_50_i, ack_frame_o, dat_frame_o, RET_DAT_ADDR, 41*8, 
                       true, 28, UNFILTER_CH0, addr_frame_i, tga_frame_i,
                       we_frame_i, stb_frame_i, cyc_frame_i);
      report "I am done reading UNFILTER data" severity NOTE;

      wait for FREE_RUN;

      -- Self Check for UNFILTER
      case current_bank_fltr is
        when '0' =>

          -- for CH0
          for i in 0 to 40 loop
            wait for 1 ns;
            j :=  (i*8)+7;
            if (filter_bank1(i)(65)& filter_bank1(i)(30 downto 0)) /= UNFILTER_CH0(j)   then
              found_error_unfilter <= true;
            end if;

            assert found_error_unfilter=false
              report "FAILED at UNFILTER wbs_frame_data" 
              severity FAILURE;
           
          end loop;  -- i
          
        when '1' =>

          -- for CH0
          for i in 0 to 40 loop
            wait for 1 ns;
            j :=  (i*8)+7;
            if (filter_bank0(i)(65)& filter_bank0(i)(30 downto 0)) /= UNFILTER_CH0(j)   then
              found_error_unfilter <= true;
            end if;

            assert found_error_unfilter=false
              report "FAILED at UNFILTER wbs_frame_data" 
              severity FAILURE;
           
          end loop;  -- i

         when others => null;
      end case;
      report "I am done with self checking UNFILTER data" severity NOTE;
      

      wait for FREE_RUN;

      -- Select FB_ERROR Mode
      write_wbs_data(clk_50_i, ack_frame_o, DATA_MODE_ADDR, x"00000002", 1,
                        false, 0, dat_frame_i, addr_frame_i, tga_frame_i,
                        we_frame_i, stb_frame_i, cyc_frame_i);
      report "I am done with selecting FB_ERROR mode" severity NOTE;


      wait for FREE_RUN;

      read_wbs_data(clk_50_i, ack_frame_o, dat_frame_o, RET_DAT_ADDR, 41*8, 
                       true, 28, FB_ERROR_CH0, addr_frame_i, tga_frame_i,
                       we_frame_i, stb_frame_i, cyc_frame_i);
      report "I am done with reading FB_ERROR data" severity NOTE;

      wait for FREE_RUN;
      -- Self Check for FB_ERROR
      case current_bank_fltr is
        when '0' =>

          -- for CH0
          for i in 0 to 40 loop
            wait for 1 ns;
            j :=  (i*8)+7;
            if (filter_bank1(i)(65)& filter_bank1(i)(30 downto 16)& coadd_bank1(i)(31 downto 16)) /= FB_ERROR_CH0(j)   then
              found_error_fb_error <= true;
            end if;

            assert found_error_fb_error=false
              report "FAILED at FB_ERROR wbs_frame_data" 
              severity FAILURE;
           
          end loop;  -- i
          
        when '1' =>

          -- for CH0
          for i in 0 to 40 loop
            wait for 1 ns;
            j :=  (i*8)+7;
            if (filter_bank0(i)(65)& filter_bank0(i)(30 downto 16)& coadd_bank0(i)(31 downto 16)) /= FB_ERROR_CH0(j)   then
              found_error_fb_error <= true;
            end if;

            assert found_error_fb_error=false
              report "FAILED at FB_ERROR wbs_frame_data" 
              severity FAILURE;
           
          end loop;  -- i

         when others => null;
      end case;
      report "I am done with self checking FB_ERROR data" severity NOTE;


      
      wait for FREE_RUN;


      -- write into captr_raw
      write_wbs_data(clk_50_i, ack_frame_o, CAPTR_RAW_ADDR, x"0000000F", 1,
                        false, 0, dat_frame_i, addr_frame_i, tga_frame_i,
                        we_frame_i, stb_frame_i, cyc_frame_i);
      report "I am done with writing into CAPTR_RAW_ADDR" severity NOTE;

      wait for FREE_RUN;
      
      -- Select RAW MODE
      write_wbs_data(clk_50_i, ack_frame_o, DATA_MODE_ADDR, x"00000003", 1,
                        false, 0, dat_frame_i, addr_frame_i, tga_frame_i,
                        we_frame_i, stb_frame_i, cyc_frame_i);
      report "I am done with selecting RAW mode" severity NOTE;

      wait for FREE_RUN;

      -- read from ret_dat_addr with raw mode selected.
      read_for_raw_wbs_data(clk_50_i, ack_frame_o, dat_frame_o, RET_DAT_ADDR, 2*41*8*64, 
                       true, 28, RAW_CH0, addr_frame_i, tga_frame_i,
                       we_frame_i, stb_frame_i, cyc_frame_i);
      report "I am done with raw data read" severity NOTE;

      wait for FREE_RUN;


      -- perform a read from DATA_MODE_ADDR
      read_wbs_data(clk_50_i, ack_frame_o, dat_frame_o, DATA_MODE_ADDR, 1, 
                        false, 0, INVALID_READ, addr_frame_i, tga_frame_i,
                        we_frame_i, stb_frame_i, cyc_frame_i);
      report "I am done with doing a read from DATA_MODE_ADDR" severity NOTE;

      wait for FREE_RUN;

      -- perform a read from CAPTR_RAW_ADDR
      read_wbs_data(clk_50_i, ack_frame_o, dat_frame_o, CAPTR_RAW_ADDR, 1, 
                        false, 0, INVALID_READ, addr_frame_i, tga_frame_i,
                        we_frame_i, stb_frame_i, cyc_frame_i);                    
      report "I am done with doing a read from CAPTR_RAW_ADDR" severity NOTE;

      wait for FREE_RUN;

      -- illegarl write into RET_DAT_ADDR
      -- Nothing should happen.  wbs_frame_data only acknowledges this to
      -- prevent system hang.
      write_wbs_data(clk_50_i, ack_frame_o, RET_DAT_ADDR, x"00000001", 1,
                          false, 0, dat_frame_i, addr_frame_i, tga_frame_i,
                          we_frame_i, stb_frame_i, cyc_frame_i);
      report "I am done with doing a write into RET_DAT_ADDR.  I did nothing except to ack" severity NOTE;
     
      wait for FREE_RUN;

  
    end loop;

    wait for PERIOD;
    
  end process i_excite_wbs_frame_data;
                  

  
  -----------------------------------------------------------------------------
  -- The following process sets up the DUT environment and the test run duration.
  -----------------------------------------------------------------------------
 
  i_test: process

    ---------------------------------------------------------------------------
    -- Procedure to initialize all the inputs
    ---------------------------------------------------------------------------
    
    procedure do_initialize is
    begin
      reset_window_done       <= false;
      rst_i                   <= '1';
      coadded_addr            <= (others => '0');
      current_bank            <= '0';
      dat_fb_i                   <= (others => '0');
      addr_fb_i                  <= (others => '0');
      tga_fb_i                   <= (others => '0');
      we_fb_i                    <= '0';
      stb_fb_i                   <= '0';
      cyc_fb_i                   <= '0';
      
      wait for 113 ns;
      rst_i <= '0';
      wait for RESET_WINDOW - 113 ns;   -- aligned with clk

      reset_window_done <= true;
    end do_initialize;


    ---------------------------------------------------------------------------
    -- Generates bank selection for testbench coadd, filter, and control to be
    -- used in the selfcheck process.
    ---------------------------------------------------------------------------

    procedure gen_tb_bank_sel is
    begin

      wait until falling_edge(restart_frame_aligned_i);

      for i in 1 to 100*41 loop            
        
        wait for 8*PERIOD;
        wait for 25*PERIOD;
        wait for (CLOCKS_PER_ROW-25-8)*PERIOD;      
        coadded_addr          <= coadded_addr  +1 after 10*PERIOD;
     
        if (conv_integer(unsigned(coadded_addr)) = 41-2) then
          current_bank_ctrl <= not current_bank_ctrl after 11*PERIOD;
          addr_plus1_inc_ok <= false after 10*PERIOD,
                               true  after (CLOCKS_PER_ROW+10)*PERIOD;
        end if;
     
        if (conv_integer(unsigned(coadded_addr))=41-1) then
          current_bank       <= not current_bank      after 11*PERIOD;
          current_bank_fltr  <= not current_bank_fltr after 11*PERIOD;
          coadded_addr <=(others => '0' ) after 10*PERIOD;
        end if;

        
      end loop;  -- i

    

      
      wait for PERIOD;

    end gen_tb_bank_sel;

    ---------------------------------------------------------------------------
    -- 
    ---------------------------------------------------------------------------

  begin  -- process i_test

    
     
    do_initialize;

    ---------------------------------------------------------------------------
    -- Mimicking the the operation of the Dispatch (wishbone master):
    -- 1.Configure all the feedback data parameters such as PIDZ, etc.
    -- 2.Read these parameters to confirm.
    ---------------------------------------------------------------------------
    
    -- For channel0 of Flux loop control

    -- write PIDZ queues and OFFSET values
--     write_wbs_data(clk_50_i, ack_fb_o, GAINP0_ADDR, x"00000001", 41,
--                       true, 29, dat_fb_i, addr_fb_i, tga_fb_i, we_fb_i, stb_fb_i, cyc_fb_i);
--     wait for FREE_RUN;
    
--     write_wbs_data(clk_50_i, ack_fb_o, GAINI0_ADDR, x"00000040", 41,
--                       true, 12, dat_fb_i, addr_fb_i, tga_fb_i, we_fb_i, stb_fb_i, cyc_fb_i);
--     wait for FREE_RUN;
--     write_wbs_data(clk_50_i, ack_fb_o, GAIND0_ADDR, x"00000B00", 41,
--                       true, 38, dat_fb_i, addr_fb_i, tga_fb_i, we_fb_i, stb_fb_i, cyc_fb_i);
--     wait for FREE_RUN;
--     write_wbs_data(clk_50_i, ack_fb_o, FLX_QUANTA0_ADDR, x"0000F000", 41,
--                       false, 0, dat_fb_i, addr_fb_i, tga_fb_i, we_fb_i, stb_fb_i, cyc_fb_i);
--     wait for FREE_RUN;
--     write_wbs_data(clk_50_i, ack_fb_o, ADC_OFFSET0_ADDR, x"00100000", 41,
--                       true, 9, dat_fb_i, addr_fb_i, tga_fb_i, we_fb_i, stb_fb_i, cyc_fb_i);
--     wait for FREE_RUN;

--     -- Read PIDZ queues and OFFSET values
--     read_wbs_data(clk_50_i, ack_fb_o, dat_fb_o, GAINP0_ADDR, 41, 
--                      false, 0, P_CH0, addr_fb_i, tga_fb_i, we_fb_i, stb_fb_i, cyc_fb_i);                    
--     wait for FREE_RUN;
--     read_wbs_data(clk_50_i, ack_fb_o, dat_fb_o, GAINI0_ADDR, 41, 
--                      false, 0, I_CH0, addr_fb_i, tga_fb_i, we_fb_i, stb_fb_i, cyc_fb_i);                    
--     wait for FREE_RUN;
--     read_wbs_data(clk_50_i, ack_fb_o, dat_fb_o, GAIND0_ADDR, 41, 
--                      false, 0, D_CH0, addr_fb_i, tga_fb_i, we_fb_i, stb_fb_i, cyc_fb_i);                    
--     wait for FREE_RUN;
--     read_wbs_data(clk_50_i, ack_fb_o, dat_fb_o, FLX_QUANTA0_ADDR, 41, 
--                      false, 0, Z_CH0, addr_fb_i, tga_fb_i, we_fb_i, stb_fb_i, cyc_fb_i);                    
                         
--     wait for FREE_RUN;
--     read_wbs_data(clk_50_i, ack_fb_o, dat_fb_o, ADC_OFFSET0_ADDR, 41, 
--                      false, 0, OFFSET_CH0, addr_fb_i, tga_fb_i, we_fb_i, stb_fb_i, cyc_fb_i);                    
--     wait for FREE_RUN;
    

    
    -- For channel7 of Flux loop control

    -- write PIDZ queues and OFFSET values
    write_wbs_data(clk_50_i, ack_fb_o, GAINP7_ADDR, x"00000007", 41,
                      true, 29, dat_fb_i, addr_fb_i, tga_fb_i, we_fb_i, stb_fb_i, cyc_fb_i);
    wait for FREE_RUN;
    
    write_wbs_data(clk_50_i, ack_fb_o, GAINI7_ADDR, x"00000047", 41,
                      true, 12, dat_fb_i, addr_fb_i, tga_fb_i, we_fb_i, stb_fb_i, cyc_fb_i);
    wait for FREE_RUN;
    write_wbs_data(clk_50_i, ack_fb_o, GAIND7_ADDR, x"00000B07", 41,
                      true, 38, dat_fb_i, addr_fb_i, tga_fb_i, we_fb_i, stb_fb_i, cyc_fb_i);
    wait for FREE_RUN;
    write_wbs_data(clk_50_i, ack_fb_o, FLX_QUANTA7_ADDR, x"0000F007", 41,
                      false, 0, dat_fb_i, addr_fb_i, tga_fb_i, we_fb_i, stb_fb_i, cyc_fb_i);
    wait for FREE_RUN;
    write_wbs_data(clk_50_i, ack_fb_o, ADC_OFFSET7_ADDR, x"00100007", 41,
                      true, 9, dat_fb_i, addr_fb_i, tga_fb_i, we_fb_i, stb_fb_i, cyc_fb_i);
    wait for FREE_RUN;

    -- Read PIDZ queues and OFFSET values
    read_wbs_data(clk_50_i, ack_fb_o, dat_fb_o, GAINP7_ADDR, 41, 
                     false, 0, P_CH0, addr_fb_i, tga_fb_i, we_fb_i, stb_fb_i, cyc_fb_i);                    
    wait for FREE_RUN;
    read_wbs_data(clk_50_i, ack_fb_o, dat_fb_o, GAINI7_ADDR, 41, 
                     false, 0, I_CH0, addr_fb_i, tga_fb_i, we_fb_i, stb_fb_i, cyc_fb_i);                    
    wait for FREE_RUN;
    read_wbs_data(clk_50_i, ack_fb_o, dat_fb_o, GAIND7_ADDR, 41, 
                     false, 0, D_CH0, addr_fb_i, tga_fb_i, we_fb_i, stb_fb_i, cyc_fb_i);                    
    wait for FREE_RUN;
    read_wbs_data(clk_50_i, ack_fb_o, dat_fb_o, FLX_QUANTA7_ADDR, 41, 
                     false, 0, Z_CH0, addr_fb_i, tga_fb_i, we_fb_i, stb_fb_i, cyc_fb_i);                    
                         
    wait for FREE_RUN;
    read_wbs_data(clk_50_i, ack_fb_o, dat_fb_o, ADC_OFFSET7_ADDR, 41, 
                     false, 0, OFFSET_CH0, addr_fb_i, tga_fb_i, we_fb_i, stb_fb_i, cyc_fb_i);                    
    wait for FREE_RUN;
    

    -- Put other Channels in here

    
    -- For all channels
    
    -- Note: filter component is not implemented for initial release                      
    write_wbs_data(clk_50_i, ack_fb_o, FILT_COEF_ADDR, x"04000000", 7,
                      true, 5, dat_fb_i, addr_fb_i, tga_fb_i, we_fb_i, stb_fb_i, cyc_fb_i);
    wait for FREE_RUN;
   
    -- Write 1, 2, or 3 for Constant, Ramp, or Lock Mode
    write_wbs_data(clk_50_i, ack_fb_o, SERVO_MODE_ADDR, x"00000003", 1,
                      false, 0, dat_fb_i, addr_fb_i, tga_fb_i, we_fb_i, stb_fb_i, cyc_fb_i);
    wait for FREE_RUN;
    
    -- The followings are only required for RAMP mode; otherwise meaningless
    write_wbs_data(clk_50_i, ack_fb_o, RAMP_STEP_ADDR, x"00000002", 1,
                      false, 0, dat_fb_i, addr_fb_i, tga_fb_i, we_fb_i, stb_fb_i, cyc_fb_i);
    wait for FREE_RUN;
    write_wbs_data(clk_50_i, ack_fb_o, RAMP_AMP_ADDR, x"00000005", 1,
                      false, 0, dat_fb_i, addr_fb_i, tga_fb_i, we_fb_i, stb_fb_i, cyc_fb_i);
    wait for FREE_RUN;
    -- minimum frame cycles of 1; specifiying with 0 actually means x"ffffffff"+1
    write_wbs_data(clk_50_i, ack_fb_o, RAMP_DLY_ADDR, x"00000001", 1,
                          false, 0, dat_fb_i, addr_fb_i, tga_fb_i, we_fb_i, stb_fb_i, cyc_fb_i);
    wait for FREE_RUN;
    
    -- The following is only required for CONST mode; otherwise meaningless    
    write_wbs_data(clk_50_i, ack_fb_o, FB_CONST_ADDR, x"0000000F", 1,
                      false, 0, dat_fb_i, addr_fb_i, tga_fb_i, we_fb_i, stb_fb_i, cyc_fb_i); 
    wait for FREE_RUN;

    
    write_wbs_data(clk_50_i, ack_fb_o, SA_BIAS_ADDR, x"00000005", 8,
                      true, 6, dat_fb_i, addr_fb_i, tga_fb_i, we_fb_i, stb_fb_i, cyc_fb_i);
    wait for FREE_RUN;
    
    write_wbs_data(clk_50_i, ack_fb_o, OFFSET_ADDR, x"00000003", 8,
                      true, 3, dat_fb_i, addr_fb_i, tga_fb_i, we_fb_i, stb_fb_i, cyc_fb_i);
    wait for FREE_RUN;

    read_wbs_data(clk_50_i, ack_fb_o, dat_fb_o, OFFSET_ADDR, 8, 
                     false, 0, OFFSET_CTRL_ALL, addr_fb_i, tga_fb_i, we_fb_i, stb_fb_i, cyc_fb_i);                    
    wait for FREE_RUN;
    read_wbs_data(clk_50_i, ack_fb_o, dat_fb_o,  SA_BIAS_ADDR, 8, 
                     false, 0, SA_BIAS_CTRL_ALL, addr_fb_i, tga_fb_i, we_fb_i, stb_fb_i, cyc_fb_i);                    
    wait for FREE_RUN;

    finish_wbs_fb_data <= true;

    

    -- used for self-check
    gen_tb_bank_sel;

    
    finish_test_flux_loop   <= true;

    wait for 56*FREE_RUN;

    finish_tb1 <= true;                  -- Terminate the Test Bench
     
    report "End of Test";

    wait;
   
  end process i_test;


  -----------------------------------------------------------------------------
  -- self check support 
  -- generate the correct adc_offset array address for co-add calculations
  -----------------------------------------------------------------------------
  
  internal_adc_offset_addr : process (clk_50_i, rst_i)
  begin
     if rst_i = '1' then
        adc_offset_addr_ch0 <= (others => '0');
     elsif clk_50_i'event and clk_50_i = '1' then
        if adc_coadd_en_dly(5) = '1' and adc_coadd_en_dly(4) = '0' then
           if adc_offset_addr_ch0 /= 40 then
              adc_offset_addr_ch0 <= adc_offset_addr_ch0 + 1;
           else 
              adc_offset_addr_ch0 <= (others => '0');
           end if;
        end if;
     end if;
  end process internal_adc_offset_addr;


  -----------------------------------------------------------------------------
  -- Self check for Single Channel:
  -- This block generates:
  -- 1. Delays adc_coadd_en_i
  -- 2. Finds the expected coadded, integral, and differential and saves them
  -- in respective memory banks
  -- 3. Calculates the expected fsfb_calc outputs to fsfb_ctrl and fsfb_fltr
  -- and saves them in respective memory banks
  -- 4. self check by checking the expected values of case 3 with the real
  -- values.
  -----------------------------------------------------------------------------


  adc_offset_dat_ch0 <= OFFSET_CH0(conv_integer(unsigned(adc_offset_addr_ch0)))(adc_offset_dat_ch0'length-1 downto 0);

  address_index_plus1 <= address_index +1 when addr_plus1_inc_ok 
                         else 0;


  i_check: process (clk_50_i, rst_i)
  
    variable p_coeff : std_logic_vector(32 downto 0);
    variable i_coeff : std_logic_vector(32 downto 0);
    variable d_coeff : std_logic_vector(32 downto 0);
    variable z_coeff : std_logic_vector(65 downto 0);
  
    variable coadded_sum : std_logic_vector(32 downto 0);
    variable integral    : std_logic_vector(32 downto 0);
    variable difference  : std_logic_vector(32 downto 0);
    
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
        integral_bank0(i) <= (others => '0');
        integral_bank1(i) <= (others => '0');
        coadd_bank0(i)    <= (others => '0');
        coadd_bank1(i)    <= (others => '0');
        filter_bank0(i)   <= (others => '0');
        filter_bank1(i)   <= (others => '0');
      end loop;  -- i
      
    elsif clk_50_i'event and clk_50_i = '1' then  -- rising clock edge

      address_index <=  conv_integer(unsigned(coadded_addr));

      -- delay adc_coadd_en_i with 5 clocks. 5th element is used for
      -- calculation of PIDZ error value
      adc_coadd_en_dly(0)   <= adc_coadd_en_i;  
      for i in 1 to 5 loop
        adc_coadd_en_dly(i) <= adc_coadd_en_dly(i-1);
      end loop;  -- i


      -- coadd
      if adc_coadd_en_dly(3) = '1' then
        coadded_value <=  coadded_value +(conv_integer(signed(adc_dat_ch0_i)))-
                          (conv_integer(signed(adc_offset_dat_ch0)));
      end if;


      -- find integral and difference
      if adc_coadd_en_dly(4) = '1' and adc_coadd_en_dly(3) = '0' then
        
        if current_bank = '0' then
          coadd_bank0(address_index) <= conv_std_logic_vector(coadded_value, 32);
          if initialize_window_i = '0' then
            integral_bank0(address_index) <= conv_std_logic_vector(coadded_value,32) +
                                              integral_bank1(address_index);
            diff_value <=  coadded_value - conv_integer(signed(coadd_bank1(address_index)));
          else                          -- ignore previous values
            integral_bank0(address_index) <=  conv_std_logic_vector((coadded_value + 0), 32);
            diff_value <=  coadded_value - 0;
           
          end if;
        end if;
        
        if current_bank = '1' then
          coadd_bank1(address_index) <= conv_std_logic_vector(coadded_value, 32);
          if initialize_window_i = '0' then
            integral_bank1(address_index) <= conv_std_logic_vector(coadded_value, 32) +
                                              integral_bank0(address_index);
            diff_value <=  coadded_value - conv_integer(signed(coadd_bank0(address_index)));
          else                          -- ingore previous values
            integral_bank1(address_index) <=  conv_std_logic_vector((coadded_value + 0), 32);
            diff_value <=  coadded_value - 0;
          end if;
        end if;

        coadded_value <= 0;
         
      end if;


      p_coeff := P_CH0(address_index)(31) & P_CH0(address_index);
      i_coeff := I_CH0(address_index)(31) & I_CH0(address_index);
      d_coeff := D_CH0(address_index)(31) & D_CH0(address_index);
              
      if Z_CH0(address_index)(31) = '0' then              
        z_coeff := ("00" & x"00000000" & Z_CH0(address_index));
      else 
        z_coeff := ("11" & x"FFFFFFFF" & Z_CH0(address_index));      
      end if;

      difference := conv_std_logic_vector(diff_value, 33);


      -- calculate pidz error value
      if adc_coadd_en_dly(5) = '1' then

        if current_bank = '0' then  -- use proper bank for coadd/intgral                                             
              
          coadded_sum := coadd_bank0(address_index)(31) & coadd_bank0(address_index);
          integral    := integral_bank0(address_index)(31) & integral_bank0(address_index);
              
        else

          coadded_sum := coadd_bank1(address_index)(31) & coadd_bank1(address_index);
          integral    := integral_bank1(address_index)(31) & integral_bank1(address_index);

        end if;



        case current_bank_fltr is
          when '0' =>
                                  
            filter_bank0(address_index) <=  conv_std_logic_vector((signed(p_coeff)*signed(coadded_sum)),66) + 
                                       conv_std_logic_vector((signed(i_coeff)*signed(integral)), 66) + 
                                       conv_std_logic_vector((signed(d_coeff)*signed(difference)), 66) + z_coeff;
 
          when '1' =>
            
            filter_bank1(address_index) <=  conv_std_logic_vector((signed(p_coeff)*signed(coadded_sum)),66) + 
                                            conv_std_logic_vector((signed(i_coeff)*signed(integral)), 66) + 
                                            conv_std_logic_vector((signed(d_coeff)*signed(difference)), 66) + z_coeff;
           
          when others => null;
        end case;
         
      end if;
    end if;
  end process i_check;
  
  
  -----------------------------------------------------------------------------
  -- Self Check for fsfb_ctrl block DAC output
  -- WARNING: Based on the values used for the generic values in the fsfb_ctrl,
  -- you need to adjust the check. 
  -----------------------------------------------------------------------------

  i_check_fsfb_ctrl: process (clk_50_i)
    variable fltr_reference: std_logic_vector(65 downto 0);
    variable dac_reference: std_logic_vector(13 downto 0);
  begin  -- process i_check_fsfb_ctrl
    if dac_clk_ch0_o = '1' then
      if finish_test_flux_loop=false then
  
        case current_bank_ctrl is
           
          when '0' => fltr_reference := filter_bank0(address_index_plus1);
     when '1' => fltr_reference := filter_bank1(address_index_plus1);        
          
          when others => null;
          
        end case;
          
        dac_reference := fltr_reference(fltr_reference'length-1) & 
                         fltr_reference(FSFB_ACCURACY_POSITION-1 downto (FSFB_ACCURACY_POSITION - DAC_DAT_WIDTH + 1));

  
        -----------------------------------------------------------------------
        -- Modifiy acccording to polarity of the ADC and bit accuracy as shown
        -- in the generic value in the fsfb_ctrl.  These values default to 0
        -- and 13 respective, showing a straight polarity.
        -- Manual inspection is required in constant and ramp modes
        -----------------------------------------------------------------------
        
        if initialize_window_i = '0' then
    
          -- comment out if not in lock mode              
          if CONVERSION_POLARITY_MODE = 0 then
           
            -- if straight polarity is used in instantiating the fsfb_ctrl and bit
       -- 13 down to 0 of input data is used
    
            if ((not dac_reference(13)) & dac_reference(12 downto 0)) /= dac_dat_ch7_o then
              found_dac_error <= true;
            end if;
             
          else

            -- if reverse polarity is used in instantiating the fsfb_ctrl
           
            if (dac_reference(13) & (not dac_reference(12 downto 0))) /= dac_dat_ch7_o then
              found_dac_error <= true;
            end if;
           
          end if;
                         
        end if;                        
      end if;
          
      assert found_dac_error=false
      report "FAILED at flux_loop DAC output" 
      severity FAILURE;
     
    end if;
  end process i_check_fsfb_ctrl;
  
  
  -------------------------------------------------------------------------------
  -- Offset/SA Bias control blocks testing
  -------------------------------------------------------------------------------     
     
  -- Capture the serial data for comparison
  -- Channel 0
  
  scapture1 : process (sa_bias_dac_spi_ch7_o, rst_i)
  begin
    if (rst_i = '1') then
      sc_data1 <= (others => '0');
    elsif (sa_bias_dac_spi_ch7_o(1)'event and sa_bias_dac_spi_ch7_o(1) = '1') then
      if (sa_bias_dac_spi_ch7_o(2) = '0') then
        sc_data1(0) <= sa_bias_dac_spi_ch7_o(0);
        sc_data1(15 downto 1) <= sc_data1(14 downto 0);
      end if;
    end if;
  end process scapture1;
  
  scapture2 : process (offset_dac_spi_ch7_o, rst_i)
  begin
    if (rst_i = '1') then
      sc_data2 <= (others => '0');
    elsif (offset_dac_spi_ch7_o(1)'event and offset_dac_spi_ch7_o(1) = '1') then
      if (offset_dac_spi_ch7_o(2) = '0') then
        sc_data2(0) <= offset_dac_spi_ch7_o(0);
        sc_data2(15 downto 1) <= sc_data2(14 downto 0);
      end if;
    end if;
  end process scapture2;     
        
  -- Comparison (Automated check)
        
  compare1 : process(sa_bias_dac_spi_ch7_o)
  begin
    if finish_test_flux_loop=false then
      if (sa_bias_dac_spi_ch7_o(2)'event and sa_bias_dac_spi_ch7_o(2) = '1') then
        assert (sc_data1 = SA_BIAS_CTRL_ALL(7)(15 downto 0)) 
        report "SA_Bias_Ctrl:  Serial Data Output /= Parallel Data Input"
        severity FAILURE;
      end if;
    end if;
  end process compare1;
  
  compare2 : process(offset_dac_spi_ch7_o)
  begin
    if finish_test_flux_loop=false then
      if (offset_dac_spi_ch7_o(2)'event and offset_dac_spi_ch7_o(2) = '1') then
        assert (sc_data2 = OFFSET_CTRL_ALL(7)(15 downto 0)) 
        report "Offset_Ctrl:  Serial Data Output /= Parallel Data Input"
        severity FAILURE;
      end if;
    end if;
  end process compare2;


  
  

end beh;
