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
-- adc_sample_coadd_pack.vhd
--
-- Project:	  SCUBA-2
-- Author:        Mohsen Nahvi
-- Organisation:  UBC
--
-- Description:
-- The package file for the adc_sample_coadd.vhd file.
--
-- Revision history:
-- 
-- $Log$
--
------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

--library sys_param;
--use sys_param.wishbone_pack.all;


package adc_sample_coadd_pack is

  
  -----------------------------------------------------------------------------
  -- Constants used in A/D sampler and coadder
  -----------------------------------------------------------------------------


  constant RAW_ADDR_WIDTH     : integer := 13;
  constant MAX_RAW_ADDR_COUNT : integer := (2**RAW_ADDR_WIDTH)-1; 
  constant ADC_LATENCY        : integer := 4;
  constant TOTAL_ROW_NO       : integer := 64;
  constant FSFB_DONE_DLY      : integer := 6;

  -----------------------------------------------------------------------------
  -- Raw data storage component
  -----------------------------------------------------------------------------

  component raw_dat_bank
    port (
      data      : in  std_logic_vector (15 downto 0);
      wren      : in  std_logic;
      wraddress : in  std_logic_vector (12 downto 0);
      rdaddress : in  std_logic_vector (12 downto 0);
      clock     : in  std_logic;
      q         : out std_logic_vector (15 downto 0));
  end component;

  
  -----------------------------------------------------------------------------
  -- Raw Data Manager Data Path.
  -----------------------------------------------------------------------------

  component raw_dat_manager_data_path
    generic (
      ADDR_WIDTH : integer := RAW_ADDR_WIDTH ;
      MAX_COUNT  : integer := MAX_RAW_ADDR_COUNT); --Normally=(2^ADDR_WIDTH)-1
    port (
      rst_i        : in  std_logic;
      clk_i        : in  std_logic;
      clr_index_i  : in  std_logic;
      addr_index_o : out std_logic_vector (12 downto 0));
  end component;


  -----------------------------------------------------------------------------
  -- Raw Data Manager Controller
  -----------------------------------------------------------------------------

  component raw_dat_manager_ctrl
    port (
      rst_i                   : in  std_logic;
      clk_i                   : in  std_logic;
      restart_frame_aligned_i : in  std_logic;
      raw_req_i               : in  std_logic;
      clr_raw_addr_index_o    : out std_logic;
      raw_wren_o              : out std_logic;
      raw_ack_o               : out std_logic);
  end component;

  
  -----------------------------------------------------------------------------
  -- Coadd Manager and Dynamic Data Manager Storage Component
  -----------------------------------------------------------------------------

  component coadd_storage
    port (
      data        : in  std_logic_vector(31 downto 0);
      wraddress   : in  std_logic_vector(5 downto 0);
      rdaddress_a : in  std_logic_vector(5 downto 0);
      rdaddress_b : in  std_logic_vector(5 downto 0);
      wren        : in  std_logic;
      clock       : in  std_logic;
      qa          : out std_logic_vector(31 downto 0);
      qb          : out std_logic_vector(31 downto 0));
  end component;


  -----------------------------------------------------------------------------
  -- Coadd Manager Data Path
  -----------------------------------------------------------------------------

  component coadd_manager_data_path

    generic (
      MAX_COUNT                 : integer := TOTAL_ROW_NO;  
      MAX_SHIFT                 : integer := ADC_LATENCY+1);  
  
    port (
      rst_i                     : in  std_logic;
      clk_i                     : in  std_logic;
      adc_dat_i                 : in  std_logic_vector(13 downto 0);
      adc_offset_dat_i          : in  std_logic_vector(15 downto 0);
      adc_offset_adr_o          : out std_logic_vector(5 downto 0);
      adc_coadd_en_i            : in  std_logic;
      adc_coadd_en_5delay_o     : out std_logic;
      adc_coadd_en_4delay_o     : out std_logic;
      clr_samples_coadd_reg_i   : in  std_logic;
      samples_coadd_reg_o       : out std_logic_vector(31 downto 0);
      address_count_en_i        : in  std_logic;
      clr_address_count_i       : in  std_logic;
      coadd_write_addr_o        : out std_logic_vector(5 downto 0));

  end component;

 
  
  -----------------------------------------------------------------------------
  -- Coadd & Dynamic Manager Controller
  -----------------------------------------------------------------------------
  
  component coadd_dynamic_manager_ctrl

    generic (
      COADD_DONE_MAX_COUNT : integer := FSFB_DONE_DLY;
      MAX_SHIFT            : integer := ADC_LATENCY+1);
 
    port (
      rst_i                     : in  std_logic;
      clk_i                     : in  std_logic;
      restart_frame_1row_prev_i : in  std_logic;
      restart_frame_aligned_i   : in  std_logic;
      row_switch_i              : in  std_logic;
      adc_coadd_en_i            : in  std_logic;
      adc_coadd_en_5delay_i     : in  std_logic;
      adc_coadd_en_4delay_i     : in  std_logic;
      clr_samples_coadd_reg_o   : out std_logic;
      address_count_en_o        : out std_logic;
      clr_address_count_o       : out std_logic;
      wren_bank0_o              : out std_logic;
      wren_bank1_o              : out std_logic;
      wren_for_fsfb_o           : out std_logic;
      coadd_done_o              : out std_logic;
      current_bank_o            : out std_logic);

  end component;


  -----------------------------------------------------------------------------
  -- Dynamic Manager Data Path
  -----------------------------------------------------------------------------

  component dynamic_manager_data_path
    
    generic (
      MAX_SHIFT : integer := ADC_LATENCY+1);   

  
    port (
      rst_i                  : in  std_logic;
      clk_i                  : in  std_logic;
      initialize_window_i    : in  std_logic;
      current_coadd_dat_i    : in  std_logic_vector(31 downto 0);
      current_bank_i         : in  std_logic;
      wren_for_fsfb_i        : in  std_logic;
      coadd_dat_frm_bank0_i  : in  std_logic_vector(31 downto 0);
      coadd_dat_frm_bank1_i  : in  std_logic_vector(31 downto 0);
      intgrl_dat_frm_bank0_i : in  std_logic_vector(31 downto 0);
      intgrl_dat_frm_bank1_i : in  std_logic_vector(31 downto 0);
      current_coadd_dat_o    : out std_logic_vector(31 downto 0);
      current_diff_dat_o     : out std_logic_vector(31 downto 0);
      current_integral_dat_o : out std_logic_vector(31 downto 0);
      integral_result_o      : out std_logic_vector(31 downto 0));
  end component;

  -----------------------------------------------------------------------------
  -- 
  -----------------------------------------------------------------------------
  
end adc_sample_coadd_pack;

