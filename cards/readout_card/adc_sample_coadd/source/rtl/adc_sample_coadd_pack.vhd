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
-- Project:   SCUBA-2
-- Author:        Mohsen Nahvi
-- Organisation:  UBC
--
-- Description:
-- The package file for the adc_sample_coadd.vhd file.
--
-- Revision history:
-- 
-- $Log: adc_sample_coadd_pack.vhd,v $
-- Revision 1.10  2010/03/12 20:35:10  bburger
-- BB: added i_clamp_val interface signals
--
-- Revision 1.9.2.1  2009/11/13 19:27:19  bburger
-- BB: Added i-term clamp interface signals
--
-- Revision 1.9  2009/05/27 01:22:23  bburger
-- BB: removed unused entity declarations and constants.
--
-- Revision 1.8  2009/04/09 19:10:44  bburger
-- BB: Removed the default assignement of ADC_LATENCY which is a constant that doesn't exist anymore.
--
-- Revision 1.7  2009/03/19 21:24:41  bburger
-- BB: Split up the constant ADC_LATENCY into ADC_LATENCY_REVA/C and moved them into readout_card_pack.vhd
--
-- Revision 1.6  2008/06/19 23:50:15  mandana
-- increased USED_RAW_DAT_WIDTH to 14 and use it to make definitions parametric
--
-- Revision 1.5  2005/06/23 17:26:51  mohsen
-- MA/BB: RAW_DATA_POSITION_POINTER changed from 8 to 14
--
-- Revision 1.4  2004/12/13 21:03:01  mohsen
-- Reduced the word size of RAW data storage from 16 to 8.  This is as the result of
-- the memroy shortage in the Stratix EP1S30 with the current design of the readout card.
--
-- Revision 1.3  2004/11/26 18:25:54  mohsen
-- Anthony & Mohsen: Restructured constant declaration.  Moved shared constants from lower level package files to the upper level ones.  This was done to resolve compilation error resulting from shared constants defined in multiple package files.
--
-- Revision 1.2  2004/10/29 01:51:42  mohsen
-- Sorted out library use and use parameters
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

-- Call Parent Library
use work.flux_loop_ctrl_pack.all;
use work.flux_loop_pack.all;
use work.readout_card_pack.all;



package adc_sample_coadd_pack is

  
  -----------------------------------------------------------------------------
  -- Constants used in A/D sampler and coadder
  -----------------------------------------------------------------------------

  
  constant TOTAL_ROW_NO              : integer := 64;
  constant FSFB_DONE_DLY             : integer := 6;                    -- This should really be tied to ADC_LATENCY
  constant NUMB_RAW_FRM_TO_GRAB      : integer := 2;                    -- =#of raw frames to grab
  constant RAW_DATA_POSITION_POINTER : integer := 13;--USED_RAW_DAT_WIDTH;   -- Selects the accuracy of the ADC inputs, as we only save 8 bits out of 14. Note max value is the default 
  

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
      MAX_SHIFT                 : integer);
    
    port (
      rst_i                     : in  std_logic;
      clk_i                     : in  std_logic;
      adc_dat_i                 : in  std_logic_vector(ADC_DAT_WIDTH-1 downto 0);
      adc_offset_dat_i          : in  std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
      adc_offset_adr_o          : out std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0);
      adc_coadd_en_i            : in  std_logic;
      adc_coadd_en_5delay_o     : out std_logic;
      adc_coadd_en_4delay_o     : out std_logic;
      clr_samples_coadd_reg_i   : in  std_logic;
      samples_coadd_reg_o       : out std_logic_vector(COADD_DAT_WIDTH-1 downto 0);
      address_count_en_i        : in  std_logic;
      clr_address_count_i       : in  std_logic;
      coadd_write_addr_o        : out std_logic_vector(COADD_ADDR_WIDTH-1 downto 0));

  end component;

 
  
  -----------------------------------------------------------------------------
  -- Coadd & Dynamic Manager Controller
  -----------------------------------------------------------------------------
  
  component coadd_dynamic_manager_ctrl

    generic (
      COADD_DONE_MAX_COUNT : integer := FSFB_DONE_DLY;
      MAX_SHIFT            : integer);
 
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
      MAX_SHIFT : integer);   

  
    port (
      rst_i                  : in  std_logic;
      clk_i                  : in  std_logic;
      i_clamp_val_i          : in std_logic_vector(COADD_DAT_WIDTH-1 downto 0);
      initialize_window_i    : in  std_logic;
      current_coadd_dat_i    : in  std_logic_vector(COADD_DAT_WIDTH-1 downto 0);
      current_bank_i         : in  std_logic;
      wren_for_fsfb_i        : in  std_logic;
      coadd_dat_frm_bank0_i  : in  std_logic_vector(COADD_DAT_WIDTH-1 downto 0);
      coadd_dat_frm_bank1_i  : in  std_logic_vector(COADD_DAT_WIDTH-1 downto 0);
      intgrl_dat_frm_bank0_i : in  std_logic_vector(COADD_DAT_WIDTH-1 downto 0);
      intgrl_dat_frm_bank1_i : in  std_logic_vector(COADD_DAT_WIDTH-1 downto 0);
      current_coadd_dat_o    : out std_logic_vector(COADD_DAT_WIDTH-1 downto 0);
      current_diff_dat_o     : out std_logic_vector(COADD_DAT_WIDTH-1 downto 0);
      current_integral_dat_o : out std_logic_vector(COADD_DAT_WIDTH-1 downto 0);
      integral_result_o      : out std_logic_vector(COADD_DAT_WIDTH-1 downto 0));
  end component;

  -----------------------------------------------------------------------------
  -- 
  -----------------------------------------------------------------------------
  
end adc_sample_coadd_pack;

