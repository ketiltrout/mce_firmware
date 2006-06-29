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
-- readout_card_pack.vhd
--
-- Project:   SCUBA-2
-- Author:        Mohsen Nahvi & Anthony Ko
-- Organisation:  UBC
--
-- Description:
-- The package file for the readout_card.vhd file.
--
--
-- Revision history:
-- 
-- $Log: readout_card_pack.vhd,v $
-- Revision 1.7  2006/05/05 19:58:31  mandana
-- moved all all_cards components to all_cards_pack.vhd
--
-- Revision 1.6  2006/02/15 21:55:06  mandana
-- added frame_timing component declaration
--
-- Revision 1.5  2006/01/18 21:42:08  mandana
-- component declaration added for dispatch, dispactch_pack.vhd is obsolete now.
--
-- Revision 1.4  2005/09/14 23:51:49  bburger
-- bburger:
-- Integrated flux-jumping into flux_loop
--
-- Revision 1.3  2005/05/06 20:02:31  bburger
-- Bryce:  Added a 50MHz clock that is 180 degrees out of phase with clk_i.
-- This clk_n_i signal is used for sampling the sync_i line during the middle of the pulse, to avoid problems associated with sampling on the edges.
--
-- Revision 1.2  2005/03/18 01:28:19  mohsen
-- Added comments for fv_rev blk component.
--
-- Revision 1.1  2004/12/07 20:22:21  mohsen
-- Anthony & Mohsen: Initial release
--
--
--
--
------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;



library sys_param;

-- System Library
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;

library work;

package readout_card_pack is

  
  -----------------------------------------------------------------------------
  -- Constants 
  -----------------------------------------------------------------------------

  constant ROW_ADDR_WIDTH         :  integer := 6;
  constant FSFB_QUEUE_ADDR_WIDTH  : integer := ROW_ADDR_WIDTH;       -- address width of first stage feedback queue 

  constant ADC_DAT_WIDTH          : integer := 14;
  constant DAC_DAT_WIDTH          : integer := 14;
  constant DAC_INIT_VAL           : integer := -8192;
  constant SA_BIAS_SPI_DATA_WIDTH : integer := 3;         -- data width of SPI interface 
  constant OFFSET_SPI_DATA_WIDTH  : integer := 3;         -- data width of SPI interface 

  -----------------------------------------------------------------------------
  -- Flux Loop Component
  -----------------------------------------------------------------------------

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
      fltr_rst_i                : in  std_logic;
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
      offset_dac_spi_ch7_o      : out std_logic_vector(OFFSET_SPI_DATA_WIDTH-1 downto 0));
  end component;

  -----------------------------------------------------------------------------
  -- PLL Component
  -----------------------------------------------------------------------------

  component rc_pll
    port (
      inclk0 : IN  STD_LOGIC := '0';
      c0     : OUT STD_LOGIC;
      c1     : OUT STD_LOGIC;
      c2     : OUT STD_LOGIC;
      c3     : OUT STD_LOGIC;
      c4     : OUT STD_LOGIC);
  end component;
      
end readout_card_pack;

