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
-- wbs_fb_data_pack.vhd
--
-- Project:	  SCUBA-2
-- Author:        Mohsen Nahvi
-- Organisation:  UBC
--
-- Description:
-- The package file for the wbs_fb_data.vhd file.
--
--
-- Revision history:
-- 
-- $Log: wbs_fb_data_pack.vhd,v $
-- Revision 1.1  2004/11/20 01:22:02  mohsen
-- Initial release
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

library sys_param;
use sys_param.wishbone_pack.all;
use sys_param.command_pack.all;


package wbs_fb_data_pack is

  
  -----------------------------------------------------------------------------
  -- Constants 
  -----------------------------------------------------------------------------

  
  -----------------------------------------------------------------------------
  -- Memory Bank
  -----------------------------------------------------------------------------

  component wbs_fb_storage
    port (
      data        : IN  STD_LOGIC_VECTOR (31 DOWNTO 0);
      wraddress   : IN  STD_LOGIC_VECTOR (5 DOWNTO 0);
      rdaddress_a : IN  STD_LOGIC_VECTOR (5 DOWNTO 0);
      rdaddress_b : IN  STD_LOGIC_VECTOR (5 DOWNTO 0);
      wren        : IN  STD_LOGIC := '1';
      clock       : IN  STD_LOGIC;
      qa          : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
      qb          : OUT STD_LOGIC_VECTOR (31 DOWNTO 0));
  end component;

  
  -----------------------------------------------------------------------------
  -- P Banks Administrator
  -----------------------------------------------------------------------------

  component p_banks_admin
    port (
      clk_50_i     : in  std_logic;
      rst_i        : in  std_logic;
      p_dat_ch0_o  : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      p_addr_ch0_i : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      p_dat_ch1_o  : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      p_addr_ch1_i : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      p_dat_ch2_o  : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      p_addr_ch2_i : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      p_dat_ch3_o  : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      p_addr_ch3_i : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      p_dat_ch4_o  : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      p_addr_ch4_i : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      p_dat_ch5_o  : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      p_addr_ch5_i : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      p_dat_ch6_o  : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      p_addr_ch6_i : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      p_dat_ch7_o  : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      p_addr_ch7_i : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      dat_i        : in  std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      addr_i       : in  std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
      tga_i        : in  std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
      we_i         : in  std_logic;
      stb_i        : in  std_logic;
      cyc_i        : in  std_logic;
      qa_p_bank_o  : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      ack_p_bank_o : out std_logic);
  end component;

  
  -----------------------------------------------------------------------------
  -- I Banks Administrator
  -----------------------------------------------------------------------------

  component i_banks_admin
    port (
      clk_50_i     : in  std_logic;
      rst_i        : in  std_logic;
      i_dat_ch0_o  : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      i_addr_ch0_i : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      i_dat_ch1_o  : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      i_addr_ch1_i : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      i_dat_ch2_o  : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      i_addr_ch2_i : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      i_dat_ch3_o  : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      i_addr_ch3_i : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      i_dat_ch4_o  : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      i_addr_ch4_i : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      i_dat_ch5_o  : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      i_addr_ch5_i : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      i_dat_ch6_o  : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      i_addr_ch6_i : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      i_dat_ch7_o  : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      i_addr_ch7_i : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      dat_i        : in  std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      addr_i       : in  std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
      tga_i        : in  std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
      we_i         : in  std_logic;
      stb_i        : in  std_logic;
      cyc_i        : in  std_logic;
      qa_i_bank_o  : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      ack_i_bank_o : out std_logic);
  end component;

  
  -----------------------------------------------------------------------------
  -- D Banks Administrator
  -----------------------------------------------------------------------------

  component d_banks_admin
    port (
      clk_50_i     : in  std_logic;
      rst_i        : in  std_logic;
      d_dat_ch0_o  : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      d_addr_ch0_i : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      d_dat_ch1_o  : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      d_addr_ch1_i : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      d_dat_ch2_o  : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      d_addr_ch2_i : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      d_dat_ch3_o  : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      d_addr_ch3_i : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      d_dat_ch4_o  : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      d_addr_ch4_i : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      d_dat_ch5_o  : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      d_addr_ch5_i : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      d_dat_ch6_o  : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      d_addr_ch6_i : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      d_dat_ch7_o  : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      d_addr_ch7_i : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      dat_i        : in  std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      addr_i       : in  std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
      tga_i        : in  std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
      we_i         : in  std_logic;
      stb_i        : in  std_logic;
      cyc_i        : in  std_logic;
      qa_d_bank_o  : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      ack_d_bank_o : out std_logic);
  end component;

  
  -----------------------------------------------------------------------------
  -- Z Banks Administrator
  -----------------------------------------------------------------------------

  component z_banks_admin
    port (
      clk_50_i     : in  std_logic;
      rst_i        : in  std_logic;
      z_dat_ch0_o  : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      z_addr_ch0_i : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      z_dat_ch1_o  : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      z_addr_ch1_i : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      z_dat_ch2_o  : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      z_addr_ch2_i : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      z_dat_ch3_o  : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      z_addr_ch3_i : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      z_dat_ch4_o  : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      z_addr_ch4_i : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      z_dat_ch5_o  : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      z_addr_ch5_i : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      z_dat_ch6_o  : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      z_addr_ch6_i : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      z_dat_ch7_o  : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      z_addr_ch7_i : in  std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
      dat_i        : in  std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      addr_i       : in  std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
      tga_i        : in  std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
      we_i         : in  std_logic;
      stb_i        : in  std_logic;
      cyc_i        : in  std_logic;
      qa_z_bank_o  : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      ack_z_bank_o : out std_logic);
  end component;

  
  -----------------------------------------------------------------------------
  -- ADC Offset Banks Administrator
  -----------------------------------------------------------------------------

  component adc_offset_banks_admin
    port (
      clk_50_i              : in  std_logic;
      rst_i                 : in  std_logic;
      adc_offset_dat_ch0_o  : out std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
      adc_offset_addr_ch0_i : in  std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0);
      adc_offset_dat_ch1_o  : out std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
      adc_offset_addr_ch1_i : in  std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0);
      adc_offset_dat_ch2_o  : out std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
      adc_offset_addr_ch2_i : in  std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0);
      adc_offset_dat_ch3_o  : out std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
      adc_offset_addr_ch3_i : in  std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0);
      adc_offset_dat_ch4_o  : out std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
      adc_offset_addr_ch4_i : in  std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0);
      adc_offset_dat_ch5_o  : out std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
      adc_offset_addr_ch5_i : in  std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0);
      adc_offset_dat_ch6_o  : out std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
      adc_offset_addr_ch6_i : in  std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0);
      adc_offset_dat_ch7_o  : out std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
      adc_offset_addr_ch7_i : in  std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0);
      dat_i                 : in  std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      addr_i                : in  std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
      tga_i                 : in  std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
      we_i                  : in  std_logic;
      stb_i                 : in  std_logic;
      cyc_i                 : in  std_logic;
      qa_adc_offset_bank_o  : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      ack_adc_offset_bank_o : out std_logic);
  end component;
  
  -----------------------------------------------------------------------------
  -- Miscellanous Bank Administrator
  -----------------------------------------------------------------------------

  component misc_banks_admin
    port (
      clk_50_i                : in  std_logic;
      rst_i                   : in  std_logic;
      sa_bias_ch0_o           : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      offset_dat_ch0_o        : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      sa_bias_ch1_o           : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      offset_dat_ch1_o        : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      sa_bias_ch2_o           : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      offset_dat_ch2_o        : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      sa_bias_ch3_o           : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      offset_dat_ch3_o        : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      sa_bias_ch4_o           : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      offset_dat_ch4_o        : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      sa_bias_ch5_o           : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      offset_dat_ch5_o        : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      sa_bias_ch6_o           : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      offset_dat_ch6_o        : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
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
      qa_misc_bank_o          : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      ack_misc_bank_o         : out std_logic);
  end component;
  
  
end wbs_fb_data_pack;

