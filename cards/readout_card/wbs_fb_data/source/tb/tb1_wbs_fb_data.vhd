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
-- tb1_wbs_fb_data.vhd
--
-- Project:	  SCUBA-2
-- Author:        Mohsen Nahvi
-- Organisation:  UBC
--
-- Description:
--
-- This testbench perform a simple test as per the following stepts.
--
-- 1. A series of incremental data is writen into the memory banks.  Here, we
-- mimick a Master wait cycle to test its impact.
-- 2. Data is read from memory banks from the dispatch block.  Here, we mimick
-- a Master wait cycle to test its impact.
-- 3. Data is read from the flux_loop_ctrl blocks.
--
-- Revision history:
-- 
-- $Log$
--
--
------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;
use work.wbs_fb_data_pack.all;


library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;



entity tb1_wbs_fb_data is

end tb1_wbs_fb_data;


architecture beh of tb1_wbs_fb_data is

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
      z_dat_ch0_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      z_addr_ch0_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
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
      z_dat_ch1_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      z_addr_ch1_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
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
      z_dat_ch2_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      z_addr_ch2_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
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
      z_dat_ch3_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      z_addr_ch3_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
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
      z_dat_ch4_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      z_addr_ch4_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
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
      z_dat_ch5_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      z_addr_ch5_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
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
      z_dat_ch6_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      z_addr_ch6_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
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
      z_dat_ch7_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      z_addr_ch7_i            : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
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
      dat_i                   : in  std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      addr_i                  : in  std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
      tga_i                   : in  std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
      we_i                    : in  std_logic;
      stb_i                   : in  std_logic;
      cyc_i                   : in  std_logic;
      dat_o                   : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      ack_o                   : out std_logic);
  end component;


  signal clk_50_i                : std_logic;
  signal rst_i                   : std_logic;
  signal adc_offset_dat_ch0_o    : std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
  signal adc_offset_addr_ch0_i   : std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0);
  signal p_dat_ch0_o             : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal p_addr_ch0_i            : std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
  signal i_dat_ch0_o             : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal i_addr_ch0_i            : std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
  signal d_dat_ch0_o             : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal d_addr_ch0_i            : std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
  signal z_dat_ch0_o             : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal z_addr_ch0_i            : std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
  signal sa_bias_ch0_o           : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal offset_dat_ch0_o        : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal adc_offset_dat_ch1_o    : std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
  signal adc_offset_addr_ch1_i   : std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0);
  signal p_dat_ch1_o             : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal p_addr_ch1_i            : std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
  signal i_dat_ch1_o             : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal i_addr_ch1_i            : std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
  signal d_dat_ch1_o             : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal d_addr_ch1_i            : std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
  signal z_dat_ch1_o             : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal z_addr_ch1_i            : std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
  signal sa_bias_ch1_o           : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal offset_dat_ch1_o        : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal adc_offset_dat_ch2_o    : std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
  signal adc_offset_addr_ch2_i   : std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0);
  signal p_dat_ch2_o             : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal p_addr_ch2_i            : std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
  signal i_dat_ch2_o             : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal i_addr_ch2_i            : std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
  signal d_dat_ch2_o             : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal d_addr_ch2_i            : std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
  signal z_dat_ch2_o             : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal z_addr_ch2_i            : std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
  signal sa_bias_ch2_o           : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal offset_dat_ch2_o        : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal adc_offset_dat_ch3_o    : std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
  signal adc_offset_addr_ch3_i   : std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0);
  signal p_dat_ch3_o             : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal p_addr_ch3_i            : std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
  signal i_dat_ch3_o             : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal i_addr_ch3_i            : std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
  signal d_dat_ch3_o             : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal d_addr_ch3_i            : std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
  signal z_dat_ch3_o             : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal z_addr_ch3_i            : std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
  signal sa_bias_ch3_o           : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal offset_dat_ch3_o        : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal adc_offset_dat_ch4_o    : std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
  signal adc_offset_addr_ch4_i   : std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0);
  signal p_dat_ch4_o             : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal p_addr_ch4_i            : std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
  signal i_dat_ch4_o             : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal i_addr_ch4_i            : std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
  signal d_dat_ch4_o             : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal d_addr_ch4_i            : std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
  signal z_dat_ch4_o             : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal z_addr_ch4_i            : std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
  signal sa_bias_ch4_o           : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal offset_dat_ch4_o        : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal adc_offset_dat_ch5_o    : std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
  signal adc_offset_addr_ch5_i   : std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0);
  signal p_dat_ch5_o             : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal p_addr_ch5_i            : std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
  signal i_dat_ch5_o             : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal i_addr_ch5_i            : std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
  signal d_dat_ch5_o             : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal d_addr_ch5_i            : std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
  signal z_dat_ch5_o             : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal z_addr_ch5_i            : std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
  signal sa_bias_ch5_o           : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal offset_dat_ch5_o        : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal adc_offset_dat_ch6_o    : std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
  signal adc_offset_addr_ch6_i   : std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0);
  signal p_dat_ch6_o             : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal p_addr_ch6_i            : std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
  signal i_dat_ch6_o             : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal i_addr_ch6_i            : std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
  signal d_dat_ch6_o             : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal d_addr_ch6_i            : std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
  signal z_dat_ch6_o             : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal z_addr_ch6_i            : std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
  signal sa_bias_ch6_o           : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal offset_dat_ch6_o        : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal adc_offset_dat_ch7_o    : std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
  signal adc_offset_addr_ch7_i   : std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0);
  signal p_dat_ch7_o             : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal p_addr_ch7_i            : std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
  signal i_dat_ch7_o             : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal i_addr_ch7_i            : std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
  signal d_dat_ch7_o             : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal d_addr_ch7_i            : std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
  signal z_dat_ch7_o             : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal z_addr_ch7_i            : std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
  signal sa_bias_ch7_o           : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal offset_dat_ch7_o        : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal filter_coeff0_o         : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal filter_coeff1_o         : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal filter_coeff2_o         : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal filter_coeff3_o         : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal filter_coeff4_o         : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal filter_coeff5_o         : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal filter_coeff6_o         : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal servo_mode_o            : std_logic_vector(SERVO_MODE_SEL_WIDTH-1 downto 0);
  signal ramp_step_size_o        : std_logic_vector(RAMP_STEP_WIDTH-1 downto 0);
  signal ramp_amp_o              : std_logic_vector(RAMP_AMP_WIDTH-1 downto 0);
  signal const_val_o             : std_logic_vector(CONST_VAL_WIDTH-1 downto 0);
  signal num_ramp_frame_cycles_o : std_logic_vector(RAMP_CYC_WIDTH-1 downto 0);
  signal dat_i                   : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal addr_i                  : std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
  signal tga_i                   : std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
  signal we_i                    : std_logic;
  signal stb_i                   : std_logic;
  signal cyc_i                   : std_logic;
  signal dat_o                   : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal ack_o                   : std_logic;


  constant PERIOD                : time := 20 ns;
  constant EDGE_DEPENDENCY       : time := 2 ns;  --shows clk edge dependency
  constant RESET_WINDOW          : time := 8*PERIOD;
  constant FREE_RUN              : time := 19*PERIOD;
  
  signal reset_window_done                 : boolean := false;
  signal finish_tb1                        : boolean := false;  -- asserted to end tb
  signal finish_write_p_bank_ch0           : boolean := false;
  signal finish_write_i_bank_ch0           : boolean := false;
  signal finish_write_d_bank_ch4           : boolean := false;
  signal finish_write_z_bank_ch7           : boolean := false;
  signal finish_write_adc_offset_bank_ch2  : boolean := false;
  signal finish_write_misc_bank_sa_bias    : boolean := false;
  signal finish_write_misc_bank_servo_mode : boolean := false;
  signal finish_write_to_banks             : boolean := false;
  signal finish_read_p_bank_ch0            : boolean := false;
  signal finish_read_i_bank_ch0            : boolean := false;
  signal finish_read_d_bank_ch4            : boolean := false;
  signal finish_read_z_bank_ch7            : boolean := false;
  signal finish_read_adc_offset_bank_ch2   : boolean := false;
  signal finish_read_misc_bank_sa_bias     : boolean := false;
  signal finish_read_misc_bank_servo_mode  : boolean := false;
  signal finish_read_from_banks            : boolean := false;

  

begin  -- beh


  -----------------------------------------------------------------------------
  -- Instantiation of Device Under Test
  -----------------------------------------------------------------------------
  
  DUT: wbs_fb_data
    port map (
        clk_50_i                => clk_50_i,
        rst_i                   => rst_i,
        adc_offset_dat_ch0_o    => adc_offset_dat_ch0_o,
        adc_offset_addr_ch0_i   => adc_offset_addr_ch0_i,
        p_dat_ch0_o             => p_dat_ch0_o,
        p_addr_ch0_i            => p_addr_ch0_i,
        i_dat_ch0_o             => i_dat_ch0_o,
        i_addr_ch0_i            => i_addr_ch0_i,
        d_dat_ch0_o             => d_dat_ch0_o,
        d_addr_ch0_i            => d_addr_ch0_i,
        z_dat_ch0_o             => z_dat_ch0_o,
        z_addr_ch0_i            => z_addr_ch0_i,
        sa_bias_ch0_o           => sa_bias_ch0_o,
        offset_dat_ch0_o        => offset_dat_ch0_o,
        adc_offset_dat_ch1_o    => adc_offset_dat_ch1_o,
        adc_offset_addr_ch1_i   => adc_offset_addr_ch1_i,
        p_dat_ch1_o             => p_dat_ch1_o,
        p_addr_ch1_i            => p_addr_ch1_i,
        i_dat_ch1_o             => i_dat_ch1_o,
        i_addr_ch1_i            => i_addr_ch1_i,
        d_dat_ch1_o             => d_dat_ch1_o,
        d_addr_ch1_i            => d_addr_ch1_i,
        z_dat_ch1_o             => z_dat_ch1_o,
        z_addr_ch1_i            => z_addr_ch1_i,
        sa_bias_ch1_o           => sa_bias_ch1_o,
        offset_dat_ch1_o        => offset_dat_ch1_o,
        adc_offset_dat_ch2_o    => adc_offset_dat_ch2_o,
        adc_offset_addr_ch2_i   => adc_offset_addr_ch2_i,
        p_dat_ch2_o             => p_dat_ch2_o,
        p_addr_ch2_i            => p_addr_ch2_i,
        i_dat_ch2_o             => i_dat_ch2_o,
        i_addr_ch2_i            => i_addr_ch2_i,
        d_dat_ch2_o             => d_dat_ch2_o,
        d_addr_ch2_i            => d_addr_ch2_i,
        z_dat_ch2_o             => z_dat_ch2_o,
        z_addr_ch2_i            => z_addr_ch2_i,
        sa_bias_ch2_o           => sa_bias_ch2_o,
        offset_dat_ch2_o        => offset_dat_ch2_o,
        adc_offset_dat_ch3_o    => adc_offset_dat_ch3_o,
        adc_offset_addr_ch3_i   => adc_offset_addr_ch3_i,
        p_dat_ch3_o             => p_dat_ch3_o,
        p_addr_ch3_i            => p_addr_ch3_i,
        i_dat_ch3_o             => i_dat_ch3_o,
        i_addr_ch3_i            => i_addr_ch3_i,
        d_dat_ch3_o             => d_dat_ch3_o,
        d_addr_ch3_i            => d_addr_ch3_i,
        z_dat_ch3_o             => z_dat_ch3_o,
        z_addr_ch3_i            => z_addr_ch3_i,
        sa_bias_ch3_o           => sa_bias_ch3_o,
        offset_dat_ch3_o        => offset_dat_ch3_o,
        adc_offset_dat_ch4_o    => adc_offset_dat_ch4_o,
        adc_offset_addr_ch4_i   => adc_offset_addr_ch4_i,
        p_dat_ch4_o             => p_dat_ch4_o,
        p_addr_ch4_i            => p_addr_ch4_i,
        i_dat_ch4_o             => i_dat_ch4_o,
        i_addr_ch4_i            => i_addr_ch4_i,
        d_dat_ch4_o             => d_dat_ch4_o,
        d_addr_ch4_i            => d_addr_ch4_i,
        z_dat_ch4_o             => z_dat_ch4_o,
        z_addr_ch4_i            => z_addr_ch4_i,
        sa_bias_ch4_o           => sa_bias_ch4_o,
        offset_dat_ch4_o        => offset_dat_ch4_o,
        adc_offset_dat_ch5_o    => adc_offset_dat_ch5_o,
        adc_offset_addr_ch5_i   => adc_offset_addr_ch5_i,
        p_dat_ch5_o             => p_dat_ch5_o,
        p_addr_ch5_i            => p_addr_ch5_i,
        i_dat_ch5_o             => i_dat_ch5_o,
        i_addr_ch5_i            => i_addr_ch5_i,
        d_dat_ch5_o             => d_dat_ch5_o,
        d_addr_ch5_i            => d_addr_ch5_i,
        z_dat_ch5_o             => z_dat_ch5_o,
        z_addr_ch5_i            => z_addr_ch5_i,
        sa_bias_ch5_o           => sa_bias_ch5_o,
        offset_dat_ch5_o        => offset_dat_ch5_o,
        adc_offset_dat_ch6_o    => adc_offset_dat_ch6_o,
        adc_offset_addr_ch6_i   => adc_offset_addr_ch6_i,
        p_dat_ch6_o             => p_dat_ch6_o,
        p_addr_ch6_i            => p_addr_ch6_i,
        i_dat_ch6_o             => i_dat_ch6_o,
        i_addr_ch6_i            => i_addr_ch6_i,
        d_dat_ch6_o             => d_dat_ch6_o,
        d_addr_ch6_i            => d_addr_ch6_i,
        z_dat_ch6_o             => z_dat_ch6_o,
        z_addr_ch6_i            => z_addr_ch6_i,
        sa_bias_ch6_o           => sa_bias_ch6_o,
        offset_dat_ch6_o        => offset_dat_ch6_o,
        adc_offset_dat_ch7_o    => adc_offset_dat_ch7_o,
        adc_offset_addr_ch7_i   => adc_offset_addr_ch7_i,
        p_dat_ch7_o             => p_dat_ch7_o,
        p_addr_ch7_i            => p_addr_ch7_i,
        i_dat_ch7_o             => i_dat_ch7_o,
        i_addr_ch7_i            => i_addr_ch7_i,
        d_dat_ch7_o             => d_dat_ch7_o,
        d_addr_ch7_i            => d_addr_ch7_i,
        z_dat_ch7_o             => z_dat_ch7_o,
        z_addr_ch7_i            => z_addr_ch7_i,
        sa_bias_ch7_o           => sa_bias_ch7_o,
        offset_dat_ch7_o        => offset_dat_ch7_o,
        filter_coeff0_o         => filter_coeff0_o,
        filter_coeff1_o         => filter_coeff1_o,
        filter_coeff2_o         => filter_coeff2_o,
        filter_coeff3_o         => filter_coeff3_o,
        filter_coeff4_o         => filter_coeff4_o,
        filter_coeff5_o         => filter_coeff5_o,
        filter_coeff6_o         => filter_coeff6_o,
        servo_mode_o            => servo_mode_o,
        ramp_step_size_o        => ramp_step_size_o,
        ramp_amp_o              => ramp_amp_o,
        const_val_o             => const_val_o,
        num_ramp_frame_cycles_o => num_ramp_frame_cycles_o,
        dat_i                   => dat_i,
        addr_i                  => addr_i,
        tga_i                   => tga_i,
        we_i                    => we_i,
        stb_i                   => stb_i,
        cyc_i                   => cyc_i,
        dat_o                   => dat_o,
        ack_o                   => ack_o);


  -----------------------------------------------------------------------------
  -- Clocking
  -----------------------------------------------------------------------------

  clocking: process
  begin  -- process clocking

    clk_50_i <= '1';
    wait for PERIOD/2;
    
    while (not finish_tb1) loop
      clk_50_i <= not clk_50_i;
      wait for PERIOD/2;
    end loop;

    wait;
    
  end process clocking;


  -----------------------------------------------------------------------------
  -- Write into then Read from Banks 
  -----------------------------------------------------------------------------
  i_write_read_banks: process 
  begin  -- process i_write_read_banks

    ---------------------------------------------------------------------------
    -- For Bank P
    ---------------------------------------------------------------------------
    
    ---------------------------------------------------------------------------
    -- Start Writing
    dat_i  <= (others => '0');
    addr_i <= (others => '0');
    tga_i  <= (others => '0');
    we_i   <= '0';
    stb_i  <= '0';
    cyc_i  <= '0';
    
    wait for RESET_WINDOW;
    wait for FREE_RUN;
    wait for EDGE_DEPENDENCY;

    
    ---------------------------------------------------------------------------
    -- Write to Bank for Channel 0
    addr_i <= GAINP0_ADDR;
    stb_i  <= '1';
    cyc_i  <= '1';
    we_i   <= '1';
   
    for i in 0 to 40 loop
      dat_i  <= dat_i +7;
      wait until falling_edge(ack_o);
      wait for EDGE_DEPENDENCY;
      -- assert a wait cycle by master
      if i=25 then
        stb_i <= '0';
        wait for 11*PERIOD;
        stb_i <= '1';
      end if;
      tga_i  <= tga_i+1;
    end loop;  -- i
    
    finish_write_p_bank_ch0 <= true;
    stb_i <= '0';
    cyc_i <= '0';
    we_i  <= '0';
    tga_i    <= (others => '0');
    
    
    ---------------------------------------------------------------------------
    -- Write to other channnels here


    ---------------------------------------------------------------------------
    -- For Bank I
    ---------------------------------------------------------------------------
    
    
    ---------------------------------------------------------------------------
    -- Write to Bank for Channel 0
    wait for 27*PERIOD;
    addr_i <= GAINI0_ADDR;
    stb_i  <= '1';
    cyc_i  <= '1';
    we_i   <= '1';
   
    for i in 0 to 40 loop
      dat_i  <= dat_i +7;
      wait until falling_edge(ack_o);
      wait for EDGE_DEPENDENCY;
      -- assert a wait cycle by master
      if i=19 then
        stb_i <= '0';
        wait for 9*PERIOD;
        stb_i <= '1';
      end if;
      tga_i  <= tga_i+1;
    end loop;  -- i
    
    finish_write_i_bank_ch0 <= true;
    stb_i <= '0';
    cyc_i <= '0';
    we_i  <= '0';
    tga_i    <= (others => '0');
    
    
    ---------------------------------------------------------------------------
    -- Write to other channnels here

    
    ---------------------------------------------------------------------------
    -- For Bank D
    ---------------------------------------------------------------------------
    
    
    ---------------------------------------------------------------------------
    -- Write to Bank for Channel 4
    wait for 11*PERIOD;
    addr_i <= GAIND4_ADDR;
    stb_i  <= '1';
    cyc_i  <= '1';
    we_i   <= '1';
   
    for i in 0 to 40 loop
      dat_i  <= dat_i +7;
      wait until falling_edge(ack_o);
      wait for EDGE_DEPENDENCY;
      -- assert a wait cycle by master
      if i=22 then
        stb_i <= '0';
        wait for 9*PERIOD;
        stb_i <= '1';
      end if;
      tga_i  <= tga_i+1;
    end loop;  -- i
    
    finish_write_d_bank_ch4 <= true;
    stb_i <= '0';
    cyc_i <= '0';
    we_i  <= '0';
    tga_i    <= (others => '0');
    
    
    ---------------------------------------------------------------------------
    -- Write to other channnels here

    
    ---------------------------------------------------------------------------
    -- For Bank Z
    ---------------------------------------------------------------------------
    
    
    ---------------------------------------------------------------------------
    -- Write to Bank for Channel 7
    wait for 27*PERIOD;
    addr_i <= ZERO7_ADDR;
    stb_i  <= '1';
    cyc_i  <= '1';
    we_i   <= '1';
   
    for i in 0 to 40 loop
      dat_i  <= dat_i +7;
      wait until falling_edge(ack_o);
      wait for EDGE_DEPENDENCY;
      -- assert a wait cycle by master
      if i=6 then
        stb_i <= '0';
        wait for 17*PERIOD;
        stb_i <= '1';
      end if;
      tga_i  <= tga_i+1;
    end loop;  -- i
    
    finish_write_z_bank_ch7 <= true;
    stb_i <= '0';
    cyc_i <= '0';
    we_i  <= '0';
    tga_i    <= (others => '0');
    
    
    ---------------------------------------------------------------------------
    -- Write to other channnels here


    
    ---------------------------------------------------------------------------
    -- For Bank adc_offset
    ---------------------------------------------------------------------------
    
    
    ---------------------------------------------------------------------------
    -- Write to Bank for Channel 2
    wait for 9*PERIOD;
    addr_i <= ADC_OFFSET2_ADDR;
    stb_i  <= '1';
    cyc_i  <= '1';
    we_i   <= '1';
   
    for i in 0 to 40 loop
      dat_i  <= dat_i +7;
      wait until falling_edge(ack_o);
      wait for EDGE_DEPENDENCY;
      -- assert a wait cycle by master
      if i=12  then
        stb_i <= '0';
        wait for 7*PERIOD;
        stb_i <= '1';
      end if;
      tga_i  <= tga_i+1;
    end loop;  -- i
    
    finish_write_adc_offset_bank_ch2 <= true;
    stb_i <= '0';
    cyc_i <= '0';
    we_i  <= '0';
    tga_i    <= (others => '0');
    
    
    ---------------------------------------------------------------------------
    -- Write to other channnels here

    
    ---------------------------------------------------------------------------
    -- For Misc Bank
    ---------------------------------------------------------------------------

    
    ---------------------------------------------------------------------------
    -- Write to sa_bias
    wait for 23*PERIOD;
    addr_i <= SA_BIAS_ADDR;
    stb_i  <= '1';
    cyc_i  <= '1';
    we_i   <= '1';
   
    for i in 0 to 7 loop
      dat_i  <= dat_i +7;
      wait for PERIOD;
      --wait until falling_edge(ack_o);
      --wait for EDGE_DEPENDENCY;
      -- assert a wait cycle by master
      if i=5 then
        stb_i <= '0';
        wait for 6*PERIOD;
        stb_i <= '1';
      end if;
      tga_i  <= tga_i+1;
    end loop;  -- i
    
    finish_write_misc_bank_sa_bias <= true;
    stb_i <= '0';
    cyc_i <= '0';
    we_i  <= '0';
    tga_i    <= (others => '0');

    ---------------------------------------------------------------------------
    -- Write to servo_mode
    wait for 31*PERIOD;
    addr_i <= SERVO_MODE_ADDR;
    stb_i  <= '1';
    cyc_i  <= '1';
    we_i   <= '1';
   
    dat_i  <= dat_i +7;
    wait for PERIOD;
    --wait until falling_edge(ack_o);
    --wait for EDGE_DEPENDENCY;
    
    finish_write_misc_bank_servo_mode <= true;
    stb_i <= '0';
    cyc_i <= '0';
    we_i  <= '0';
    tga_i    <= (others => '0');

    
    ---------------------------------------------------------------------------
    -- Write to other parameters of Misc Bank here
   

    ---------------------------------------------------------------------------
    -- For Other Banks
    ---------------------------------------------------------------------------

    
    ---------------------------------------------------------------------------
    -- End Writing
    finish_write_to_banks <= true;



    ---------------------------------------------------------------------------
    -- Start Reading
    wait for 17*PERIOD;
   
    ---------------------------------------------------------------------------
    -- For P Banks
    ---------------------------------------------------------------------------
    
    ---------------------------------------------------------------------------
    -- Read from Bank for Channel 0
    addr_i <= GAINP0_ADDR;
    stb_i  <= '1';
    cyc_i  <= '1';
    we_i   <= '0';
   
    for i in 0 to 40 loop
      wait until falling_edge(ack_o);
      wait for EDGE_DEPENDENCY;
      -- assert a wait cycle by master
      if i=17 then
        stb_i <= '0';
        wait for 23*PERIOD;
        stb_i <= '1';
      end if;
      tga_i  <= tga_i+1;
    end loop;  -- i
    
    finish_read_p_bank_ch0 <= true;
    stb_i <= '0';
    cyc_i <= '0';
    we_i  <= '0';
    tga_i    <= (others => '0');

    
    ---------------------------------------------------------------------------
    -- Read from other channnels here
   

    ---------------------------------------------------------------------------
    -- For I Banks
    ---------------------------------------------------------------------------
    
    ---------------------------------------------------------------------------
    -- Read from Bank for Channel 0
    wait for 35*PERIOD;
    addr_i <= GAINI0_ADDR;
    stb_i  <= '1';
    cyc_i  <= '1';
    we_i   <= '0';
   
    for i in 0 to 40 loop
      wait until falling_edge(ack_o);
      wait for EDGE_DEPENDENCY;
      -- assert a wait cycle by master
      if i=32 then
        stb_i <= '0';
        wait for 13*PERIOD;
        stb_i <= '1';
      end if;
      tga_i  <= tga_i+1;
    end loop;  -- i
    
    finish_read_i_bank_ch0 <= true;
    stb_i <= '0';
    cyc_i <= '0';
    we_i  <= '0';
    tga_i    <= (others => '0');

    
    ---------------------------------------------------------------------------
    -- Read from other channnels here

    
    ---------------------------------------------------------------------------
    -- For D Banks
    ---------------------------------------------------------------------------
    
    ---------------------------------------------------------------------------
    -- Read from Bank for Channel 4
    wait for 24*PERIOD;
    addr_i <= GAIND4_ADDR;
    stb_i  <= '1';
    cyc_i  <= '1';
    we_i   <= '0';
   
    for i in 0 to 40 loop
      wait until falling_edge(ack_o);
      wait for EDGE_DEPENDENCY;
      -- assert a wait cycle by master
      if i=0 then
        stb_i <= '0';
        wait for 19*PERIOD;
        stb_i <= '1';
      end if;
      tga_i  <= tga_i+1;
    end loop;  -- i
    
    finish_read_d_bank_ch4 <= true;
    stb_i <= '0';
    cyc_i <= '0';
    we_i  <= '0';
    tga_i    <= (others => '0');

    
    ---------------------------------------------------------------------------
    -- Read from other channnels here


    ---------------------------------------------------------------------------
    -- For Z Banks
    ---------------------------------------------------------------------------
    
    ---------------------------------------------------------------------------
    -- Read from Bank for Channel 7
    wait for 24*PERIOD;
    addr_i <= ZERO7_ADDR;
    stb_i  <= '1';
    cyc_i  <= '1';
    we_i   <= '0';
   
    for i in 0 to 40 loop
      wait until falling_edge(ack_o);
      wait for EDGE_DEPENDENCY;
      -- assert a wait cycle by master
      if i=29 then
        stb_i <= '0';
        wait for 19*PERIOD;
        stb_i <= '1';
      end if;
      tga_i  <= tga_i+1;
    end loop;  -- i
    
    finish_read_z_bank_ch7 <= true;
    stb_i <= '0';
    cyc_i <= '0';
    we_i  <= '0';
    tga_i    <= (others => '0');

    
    ---------------------------------------------------------------------------
    -- Read from other channnels here


    ---------------------------------------------------------------------------
    -- For adc_offset Banks
    ---------------------------------------------------------------------------
    
    ---------------------------------------------------------------------------
    -- Read from Bank for Channel 2
    wait for 32*PERIOD;
    addr_i <= ADC_OFFSET2_ADDR;
    stb_i  <= '1';
    cyc_i  <= '1';
    we_i   <= '0';
   
    for i in 0 to 40 loop
      wait until falling_edge(ack_o);
      wait for EDGE_DEPENDENCY;
      -- assert a wait cycle by master
      if i=39 then
        stb_i <= '0';
        wait for 7*PERIOD;
        stb_i <= '1';
      end if;
      tga_i  <= tga_i+1;
    end loop;  -- i
    
    finish_read_adc_offset_bank_ch2 <= true;
    stb_i <= '0';
    cyc_i <= '0';
    we_i  <= '0';
    tga_i    <= (others => '0');

    
    ---------------------------------------------------------------------------
    -- Read from other channnels here

    
    
    ---------------------------------------------------------------------------
    -- For Misc Bank
    ---------------------------------------------------------------------------
    
    ---------------------------------------------------------------------------
    -- Read from sa_bias

    wait for 17*PERIOD;
    addr_i <= SA_BIAS_ADDR;
    stb_i  <= '1';
    cyc_i  <= '1';
    we_i   <= '0';
   
    for i in 0 to 7 loop
      wait for PERIOD;
      -- assert a wait cycle by master
      if i=3 then
        stb_i <= '0';
        wait for 19*PERIOD;
        stb_i <= '1';
      end if;
      tga_i  <= tga_i+1;
    end loop;  -- i
    
    finish_read_misc_bank_sa_bias <= true;
    stb_i <= '0';
    cyc_i <= '0';
    we_i  <= '0';
    tga_i    <= (others => '0');


     ---------------------------------------------------------------------------
    -- Read from servo_mode

    wait for 23*PERIOD;
    addr_i <= SERVO_MODE_ADDR;
    stb_i  <= '1';
    cyc_i  <= '1';
    we_i   <= '0';
   
    wait for PERIOD;
    tga_i  <= tga_i+1;

    finish_read_misc_bank_servo_mode <= true;
    stb_i <= '0';
    cyc_i <= '0';
    we_i  <= '0';
    tga_i    <= (others => '0');
   
    ---------------------------------------------------------------------------
    -- End Reading
    finish_read_from_banks <= true;



    wait;

  end process i_write_read_banks;



  
  -----------------------------------------------------------------------------
  -- Perform Test
  -----------------------------------------------------------------------------
  i_test: process

    ---------------------------------------------------------------------------
    -- Procedure to initialize all the inputs
     
    procedure do_initialize is
    begin
      reset_window_done      <= false;
      rst_i                  <= '1';
      p_addr_ch0_i           <= (others => '0');
      i_addr_ch0_i           <= (others => '0');
      d_addr_ch4_i           <= (others => '0');
      z_addr_ch7_i           <= (others => '0');
      adc_offset_addr_ch2_i  <= (others => '0');
                          
      wait for 113 ns;
      rst_i <= '0';
      wait for RESET_WINDOW - 113 ns;   -- alligne with clk

      reset_window_done <= true;
    end do_initialize;

    ---------------------------------------------------------------------------
    -- 


  begin  -- process i_test
 
    do_initialize;

    -- Read Bank P from Flux_loop_ctrl
    wait until finish_write_p_bank_ch0;
    --wait for EDGE_DEPENDENCY;
    for i in 0 to 40 loop
      p_addr_ch0_i <= p_addr_ch0_i+1;
      wait for PERIOD;
    end loop;  -- i

    -- Read Bank I from Flux_loop_ctrl
    wait until finish_write_i_bank_ch0;
    for i in 0 to 40 loop
      i_addr_ch0_i <= i_addr_ch0_i+1;
      wait for PERIOD;
    end loop;  -- i

    -- Read Bank D from Flux_loop_ctrl
    wait until finish_write_d_bank_ch4;
    for i in 0 to 40 loop
      d_addr_ch4_i <= d_addr_ch4_i+1;
      wait for PERIOD;
    end loop;  -- i

    -- Read Bank Z from Flux_loop_ctrl
    wait until finish_write_z_bank_ch7;
    for i in 0 to 40 loop
      z_addr_ch7_i <= z_addr_ch7_i+1;
      wait for PERIOD;
    end loop;  -- i

    -- Read Bank adc_offset from Flux_loop_ctrl
    wait until finish_write_adc_offset_bank_ch2;
    for i in 0 to 40 loop
      adc_offset_addr_ch2_i <= adc_offset_addr_ch2_i+1;
      wait for PERIOD;
    end loop;  -- i


    
    wait for FREE_RUN;

    wait until finish_read_from_banks;
    finish_tb1 <= true;

    report "END OF TEST";
    wait;
    
  end process i_test;

  
  -----------------------------------------------------------------------------
  -- 
  -----------------------------------------------------------------------------
  

end beh;

