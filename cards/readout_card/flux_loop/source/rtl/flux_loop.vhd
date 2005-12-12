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
-- flux_loop.vhd
--
-- Project:   SCUBA-2
-- Author:        Mohsen Nahvi
-- Organisation:  UBC
--
--
-- Description:
-- This block instantiates eight flux_loop_ctrl and one of wbs_frame_data and
-- wbs_fb_data.
--
--
-- 
-- Revision history:
--
--
-- $Log: flux_loop.vhd,v $
-- Revision 1.10  2005/11/29 18:30:13  mandana
-- added restart_frame_1row_post_i to wbs_frame_data interface in order to read filter data with precise timing. Now, filter data is read with one frame delay to avoid double-buffering the filter storage.
--
-- Revision 1.9  2005/10/07 21:38:07  bburger
-- Bryce:  Added a port between fsfb_io_controller and wbs_frame_data to readout flux_counts
--
-- Revision 1.8  2005/09/14 23:48:39  bburger
-- bburger:
-- Integrated flux-jumping into flux_loop
--
-- Revision 1.7  2004/12/04 03:08:24  mohsen
-- Initial Release
--
--
--
------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library work;

-- Own Library
use work.flux_loop_pack.all;

-- Call Parent Library
use work.readout_card_pack.all;

library sys_param;

-- System Library
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;


entity flux_loop is

  port (

    -- Global signals 
    clk_50_i                  : in  std_logic;
    clk_25_i                  : in  std_logic;
    rst_i                     : in  std_logic;
 
    -- Frame timing signals
    adc_coadd_en_i            : in  std_logic;
    restart_frame_1row_prev_i : in  std_logic;
    restart_frame_aligned_i   : in  std_logic;
    restart_frame_1row_post_i : in  std_logic;
    row_switch_i              : in  std_logic;
    initialize_window_i       : in  std_logic;
    num_rows_sub1_i           : in  std_logic_vector(FSFB_QUEUE_ADDR_WIDTH-1 downto 0);    -- number of rows per frame subtract 1
    dac_dat_en_i              : in  std_logic;

    -- signals to/from dispatch  (wishbone interface)
    dat_i                   : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);       -- wishbone data in
    addr_i                  : in std_logic_vector(WB_ADDR_WIDTH-1 downto 0);       -- wishbone address in
    tga_i                   : in std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);   -- 
    we_i                    : in std_logic;                                        -- write//read enable
    stb_i                   : in std_logic;                                        -- strobe 
    cyc_i                   : in std_logic;                                        -- cycle
    dat_frame_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);      -- data out
    ack_frame_o             : out std_logic;                                       -- acknowledge out
    dat_fb_o                : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);      -- data out
    ack_fb_o                : out std_logic;                                       -- acknowledge out
 
    -- ADC interface signals
    adc_dat_ch0_i           : in  std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
    adc_dat_ch1_i           : in  std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
    adc_dat_ch2_i           : in  std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
    adc_dat_ch3_i           : in  std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
    adc_dat_ch4_i           : in  std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
    adc_dat_ch5_i           : in  std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
    adc_dat_ch6_i           : in  std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
    adc_dat_ch7_i           : in  std_logic_vector (ADC_DAT_WIDTH-1 downto 0);

    adc_ovr_ch0_i           : in  std_logic;
    adc_ovr_ch1_i           : in  std_logic;
    adc_ovr_ch2_i           : in  std_logic;
    adc_ovr_ch3_i           : in  std_logic;
    adc_ovr_ch4_i           : in  std_logic;
    adc_ovr_ch5_i           : in  std_logic;
    adc_ovr_ch6_i           : in  std_logic;
    adc_ovr_ch7_i           : in  std_logic;

    adc_rdy_ch0_i           : in  std_logic;
    adc_rdy_ch1_i           : in  std_logic;
    adc_rdy_ch2_i           : in  std_logic;
    adc_rdy_ch3_i           : in  std_logic;
    adc_rdy_ch4_i           : in  std_logic;
    adc_rdy_ch5_i           : in  std_logic;
    adc_rdy_ch6_i           : in  std_logic;
    adc_rdy_ch7_i           : in  std_logic;

    adc_clk_ch0_o           : out std_logic;
    adc_clk_ch1_o           : out std_logic;
    adc_clk_ch2_o           : out std_logic;
    adc_clk_ch3_o           : out std_logic;
    adc_clk_ch4_o           : out std_logic;
    adc_clk_ch5_o           : out std_logic;
    adc_clk_ch6_o           : out std_logic;
    adc_clk_ch7_o           : out std_logic;

    -- DAC Interface
    dac_dat_ch0_o           : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
    dac_dat_ch1_o           : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
    dac_dat_ch2_o           : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
    dac_dat_ch3_o           : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
    dac_dat_ch4_o           : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
    dac_dat_ch5_o           : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
    dac_dat_ch6_o           : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
    dac_dat_ch7_o           : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);

    dac_clk_ch0_o           : out std_logic;
    dac_clk_ch1_o           : out std_logic;
    dac_clk_ch2_o           : out std_logic;
    dac_clk_ch3_o           : out std_logic;
    dac_clk_ch4_o           : out std_logic;
    dac_clk_ch5_o           : out std_logic;
    dac_clk_ch6_o           : out std_logic;
    dac_clk_ch7_o           : out std_logic;

    -- spi DAC Interface
    sa_bias_dac_spi_ch0_o   : out std_logic_vector(SA_BIAS_SPI_DATA_WIDTH-1 downto 0);
    sa_bias_dac_spi_ch1_o   : out std_logic_vector(SA_BIAS_SPI_DATA_WIDTH-1 downto 0);
    sa_bias_dac_spi_ch2_o   : out std_logic_vector(SA_BIAS_SPI_DATA_WIDTH-1 downto 0);
    sa_bias_dac_spi_ch3_o   : out std_logic_vector(SA_BIAS_SPI_DATA_WIDTH-1 downto 0);
    sa_bias_dac_spi_ch4_o   : out std_logic_vector(SA_BIAS_SPI_DATA_WIDTH-1 downto 0);
    sa_bias_dac_spi_ch5_o   : out std_logic_vector(SA_BIAS_SPI_DATA_WIDTH-1 downto 0);
    sa_bias_dac_spi_ch6_o   : out std_logic_vector(SA_BIAS_SPI_DATA_WIDTH-1 downto 0);
    sa_bias_dac_spi_ch7_o   : out std_logic_vector(SA_BIAS_SPI_DATA_WIDTH-1 downto 0);

    offset_dac_spi_ch0_o    : out std_logic_vector(OFFSET_SPI_DATA_WIDTH-1 downto 0);
    offset_dac_spi_ch1_o    : out std_logic_vector(OFFSET_SPI_DATA_WIDTH-1 downto 0);
    offset_dac_spi_ch2_o    : out std_logic_vector(OFFSET_SPI_DATA_WIDTH-1 downto 0);
    offset_dac_spi_ch3_o    : out std_logic_vector(OFFSET_SPI_DATA_WIDTH-1 downto 0);
    offset_dac_spi_ch4_o    : out std_logic_vector(OFFSET_SPI_DATA_WIDTH-1 downto 0);
    offset_dac_spi_ch5_o    : out std_logic_vector(OFFSET_SPI_DATA_WIDTH-1 downto 0);
    offset_dac_spi_ch6_o    : out std_logic_vector(OFFSET_SPI_DATA_WIDTH-1 downto 0);
    offset_dac_spi_ch7_o    : out std_logic_vector(OFFSET_SPI_DATA_WIDTH-1 downto 0));
  
end flux_loop;



architecture struct of flux_loop is



  -- Signals Interface between wbs_frame_data and flux_loop_ctrl

  signal filtered_addr_ch0 : std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
  signal filtered_dat_ch0  : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
  signal fsfb_addr_ch0     : std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
  signal fsfb_dat_ch0      : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
  signal flux_cnt_ws_dat_ch0 : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
  signal coadded_addr_ch0  : std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
  signal coadded_dat_ch0   : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
  signal raw_addr_ch0      : std_logic_vector (RAW_ADDR_WIDTH-1 downto 0);
  signal raw_dat_ch0       : std_logic_vector (RAW_DATA_WIDTH-1 downto 0);
  signal raw_req_ch0       : std_logic;
  signal raw_ack_ch0       : std_logic;
  signal filtered_addr_ch1 : std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
  signal filtered_dat_ch1  : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
  signal fsfb_addr_ch1     : std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
  signal fsfb_dat_ch1      : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
  signal flux_cnt_ws_dat_ch1 : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
  signal coadded_addr_ch1  : std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
  signal coadded_dat_ch1   : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
  signal raw_addr_ch1      : std_logic_vector (RAW_ADDR_WIDTH-1 downto 0);
  signal raw_dat_ch1       : std_logic_vector (RAW_DATA_WIDTH-1 downto 0);
  signal raw_req_ch1       : std_logic;
  signal raw_ack_ch1       : std_logic;
  signal filtered_addr_ch2 : std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
  signal filtered_dat_ch2  : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
  signal fsfb_addr_ch2     : std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
  signal fsfb_dat_ch2      : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
  signal flux_cnt_ws_dat_ch2 : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
  signal coadded_addr_ch2  : std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
  signal coadded_dat_ch2   : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
  signal raw_addr_ch2      : std_logic_vector (RAW_ADDR_WIDTH-1 downto 0);
  signal raw_dat_ch2       : std_logic_vector (RAW_DATA_WIDTH-1 downto 0);
  signal raw_req_ch2       : std_logic;
  signal raw_ack_ch2       : std_logic;
  signal filtered_addr_ch3 : std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
  signal filtered_dat_ch3  : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
  signal fsfb_addr_ch3     : std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
  signal fsfb_dat_ch3      : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
  signal flux_cnt_ws_dat_ch3 : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
  signal coadded_addr_ch3  : std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
  signal coadded_dat_ch3   : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
  signal raw_addr_ch3      : std_logic_vector (RAW_ADDR_WIDTH-1 downto 0);
  signal raw_dat_ch3       : std_logic_vector (RAW_DATA_WIDTH-1 downto 0);
  signal raw_req_ch3       : std_logic;
  signal raw_ack_ch3       : std_logic;
  signal filtered_addr_ch4 : std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
  signal filtered_dat_ch4  : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
  signal fsfb_addr_ch4     : std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
  signal fsfb_dat_ch4      : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
  signal flux_cnt_ws_dat_ch4 : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
  signal coadded_addr_ch4  : std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
  signal coadded_dat_ch4   : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
  signal raw_addr_ch4      : std_logic_vector (RAW_ADDR_WIDTH-1 downto 0);
  signal raw_dat_ch4       : std_logic_vector (RAW_DATA_WIDTH-1 downto 0);
  signal raw_req_ch4       : std_logic;
  signal raw_ack_ch4       : std_logic;
  signal filtered_addr_ch5 : std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
  signal filtered_dat_ch5  : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
  signal fsfb_addr_ch5     : std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
  signal fsfb_dat_ch5      : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
  signal flux_cnt_ws_dat_ch5 : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
  signal coadded_addr_ch5  : std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
  signal coadded_dat_ch5   : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
  signal raw_addr_ch5      : std_logic_vector (RAW_ADDR_WIDTH-1 downto 0);
  signal raw_dat_ch5       : std_logic_vector (RAW_DATA_WIDTH-1 downto 0);
  signal raw_req_ch5       : std_logic;
  signal raw_ack_ch5       : std_logic;
  signal filtered_addr_ch6 : std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
  signal filtered_dat_ch6  : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
  signal fsfb_addr_ch6     : std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
  signal fsfb_dat_ch6      : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
  signal flux_cnt_ws_dat_ch6 : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
  signal coadded_addr_ch6  : std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
  signal coadded_dat_ch6   : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
  signal raw_addr_ch6      : std_logic_vector (RAW_ADDR_WIDTH-1 downto 0);
  signal raw_dat_ch6       : std_logic_vector (RAW_DATA_WIDTH-1 downto 0);
  signal raw_req_ch6       : std_logic;
  signal raw_ack_ch6       : std_logic;
  signal filtered_addr_ch7 : std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
  signal filtered_dat_ch7  : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
  signal fsfb_addr_ch7     : std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
  signal fsfb_dat_ch7      : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
  signal flux_cnt_ws_dat_ch7 : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
  signal coadded_addr_ch7  : std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
  signal coadded_dat_ch7   : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
  signal raw_addr_ch7      : std_logic_vector (RAW_ADDR_WIDTH-1 downto 0);
  signal raw_dat_ch7       : std_logic_vector (RAW_DATA_WIDTH-1 downto 0);
  signal raw_req_ch7       : std_logic;
  signal raw_ack_ch7       : std_logic;


  


  -- Signals Interface between wbs_fb_data and flux_loop_ctrl

  signal adc_offset_dat_ch0    : std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
  signal adc_offset_addr_ch0   : std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0);
  signal p_dat_ch0             : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal p_addr_ch0            : std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
  signal i_dat_ch0             : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal i_addr_ch0            : std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
  signal d_dat_ch0             : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal d_addr_ch0            : std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
  signal flux_quanta_dat_ch0   : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal flux_quanta_addr_ch0  : std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
  signal sa_bias_dat_ch0       : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal offset_dat_ch0        : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal adc_offset_dat_ch1    : std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
  signal adc_offset_addr_ch1   : std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0);
  signal p_dat_ch1             : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal p_addr_ch1            : std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
  signal i_dat_ch1             : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal i_addr_ch1            : std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
  signal d_dat_ch1             : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal d_addr_ch1            : std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
  signal flux_quanta_dat_ch1   : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal flux_quanta_addr_ch1  : std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
  signal sa_bias_dat_ch1       : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal offset_dat_ch1        : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal adc_offset_dat_ch2    : std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
  signal adc_offset_addr_ch2   : std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0);
  signal p_dat_ch2             : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal p_addr_ch2            : std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
  signal i_dat_ch2             : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal i_addr_ch2            : std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
  signal d_dat_ch2             : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal d_addr_ch2            : std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
  signal flux_quanta_dat_ch2   : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal flux_quanta_addr_ch2  : std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
  signal sa_bias_dat_ch2       : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal offset_dat_ch2        : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal adc_offset_dat_ch3    : std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
  signal adc_offset_addr_ch3   : std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0);
  signal p_dat_ch3             : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal p_addr_ch3            : std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
  signal i_dat_ch3             : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal i_addr_ch3            : std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
  signal d_dat_ch3             : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal d_addr_ch3            : std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
  signal flux_quanta_dat_ch3   : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal flux_quanta_addr_ch3  : std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
  signal sa_bias_dat_ch3       : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal offset_dat_ch3        : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal adc_offset_dat_ch4    : std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
  signal adc_offset_addr_ch4   : std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0);
  signal p_dat_ch4             : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal p_addr_ch4            : std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
  signal i_dat_ch4             : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal i_addr_ch4            : std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
  signal d_dat_ch4             : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal d_addr_ch4            : std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
  signal flux_quanta_dat_ch4   : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal flux_quanta_addr_ch4  : std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
  signal sa_bias_dat_ch4       : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal offset_dat_ch4        : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal adc_offset_dat_ch5    : std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
  signal adc_offset_addr_ch5   : std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0);
  signal p_dat_ch5             : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal p_addr_ch5            : std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
  signal i_dat_ch5             : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal i_addr_ch5            : std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
  signal d_dat_ch5             : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal d_addr_ch5            : std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
  signal flux_quanta_dat_ch5   : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal flux_quanta_addr_ch5  : std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
  signal sa_bias_dat_ch5       : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal offset_dat_ch5        : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal adc_offset_dat_ch6    : std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
  signal adc_offset_addr_ch6   : std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0);
  signal p_dat_ch6             : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal p_addr_ch6            : std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
  signal i_dat_ch6             : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal i_addr_ch6            : std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
  signal d_dat_ch6             : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal d_addr_ch6            : std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
  signal flux_quanta_dat_ch6   : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal flux_quanta_addr_ch6  : std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
  signal sa_bias_dat_ch6       : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal offset_dat_ch6        : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal adc_offset_dat_ch7    : std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
  signal adc_offset_addr_ch7   : std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0);
  signal p_dat_ch7             : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal p_addr_ch7            : std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
  signal i_dat_ch7             : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal i_addr_ch7            : std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
  signal d_dat_ch7             : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal d_addr_ch7            : std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
  signal flux_quanta_dat_ch7   : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal flux_quanta_addr_ch7  : std_logic_vector(PIDZ_ADDR_WIDTH-1 downto 0);
  signal sa_bias_dat_ch7       : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal offset_dat_ch7        : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal filter_coeff0         : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal filter_coeff1         : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal filter_coeff2         : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal filter_coeff3         : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal filter_coeff4         : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal filter_coeff5         : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal filter_coeff6         : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
  signal servo_mode            : std_logic_vector(SERVO_MODE_SEL_WIDTH-1 downto 0);
  signal ramp_step_size        : std_logic_vector(RAMP_STEP_WIDTH-1 downto 0);
  signal ramp_amp              : std_logic_vector(RAMP_AMP_WIDTH-1 downto 0);
  signal const_val             : std_logic_vector(CONST_VAL_WIDTH-1 downto 0);
  signal num_ramp_frame_cycles : std_logic_vector(RAMP_CYC_WIDTH-1 downto 0);

  
  -- Signals Interface between fsfb_corr and flux_loop_ctrl
  signal flux_jumping_en           : std_logic;    
  signal fsfb_ctrl_lock_en         : std_logic;                                             
  signal num_flux_quanta_pres_rdy  : std_logic;                                             
  signal fsfb_ctrl_corr_rdy        : std_logic;                                                
  
  signal flux_quanta0              : std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);   
  signal fsfb_ctrl_dat0            : std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0);    
  signal num_flux_quanta_prev0     : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);    
  signal num_flux_quanta_pres0     : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);    
  signal fsfb_ctrl_dat0_rdy        : std_logic;                                             
  signal fsfb_ctrl_corr0           : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);             

  signal flux_quanta1              : std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);   
  signal fsfb_ctrl_dat1            : std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0);    
  signal num_flux_quanta_prev1     : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);    
  signal num_flux_quanta_pres1     : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);    
  signal fsfb_ctrl_dat1_rdy        : std_logic;                                             
  signal fsfb_ctrl_corr1           : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);             

  signal flux_quanta2              : std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);   
  signal fsfb_ctrl_dat2            : std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0);    
  signal num_flux_quanta_prev2     : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);    
  signal num_flux_quanta_pres2     : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);    
  signal fsfb_ctrl_dat2_rdy        : std_logic;                                             
  signal fsfb_ctrl_corr2           : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);             

  signal flux_quanta3              : std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);   
  signal fsfb_ctrl_dat3            : std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0);    
  signal num_flux_quanta_prev3     : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);    
  signal num_flux_quanta_pres3     : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);    
  signal fsfb_ctrl_dat3_rdy        : std_logic;                                             
  signal fsfb_ctrl_corr3           : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);             

  signal flux_quanta4              : std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);   
  signal fsfb_ctrl_dat4            : std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0);    
  signal num_flux_quanta_prev4     : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);    
  signal num_flux_quanta_pres4     : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);    
  signal fsfb_ctrl_dat4_rdy        : std_logic;                                             
  signal fsfb_ctrl_corr4           : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);             

  signal flux_quanta5              : std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);   
  signal fsfb_ctrl_dat5            : std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0);    
  signal num_flux_quanta_prev5     : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);    
  signal num_flux_quanta_pres5     : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);    
  signal fsfb_ctrl_dat5_rdy        : std_logic;                                             
  signal fsfb_ctrl_corr5           : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);             

  signal flux_quanta6              : std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);   
  signal fsfb_ctrl_dat6            : std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0);    
  signal num_flux_quanta_prev6     : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);    
  signal num_flux_quanta_pres6     : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);    
  signal fsfb_ctrl_dat6_rdy        : std_logic;                                             
  signal fsfb_ctrl_corr6           : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);             

  signal flux_quanta7              : std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);   
  signal fsfb_ctrl_dat7            : std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0);    
  signal num_flux_quanta_prev7     : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);    
  signal num_flux_quanta_pres7     : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);    
  signal fsfb_ctrl_dat7_rdy        : std_logic;                                             
  signal fsfb_ctrl_corr7           : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);             

  
begin  -- struct


  
  -----------------------------------------------------------------------------
  -- Instantiation of Flux Loop Control
  -----------------------------------------------------------------------------

  i_flux_loop_ctrl_ch0: flux_loop_ctrl
     port map (
        adc_dat_i                 => adc_dat_ch0_i,
        adc_ovr_i                 => adc_ovr_ch0_i,
        adc_rdy_i                 => adc_rdy_ch0_i,
        adc_clk_o                 => adc_clk_ch0_o,
        clk_50_i                  => clk_50_i,
        clk_25_i                  => clk_25_i,
        rst_i                     => rst_i,
        adc_coadd_en_i            => adc_coadd_en_i,
        restart_frame_1row_prev_i => restart_frame_1row_prev_i,
        restart_frame_aligned_i   => restart_frame_aligned_i,
        restart_frame_1row_post_i => restart_frame_1row_post_i,
        row_switch_i              => row_switch_i,
        initialize_window_i       => initialize_window_i,
        num_rows_sub1_i           => (others =>'0'),                      -- not used
        dac_dat_en_i              => dac_dat_en_i,
        coadded_addr_i            => coadded_addr_ch0,
        coadded_dat_o             => coadded_dat_ch0,
        raw_addr_i                => raw_addr_ch0,
        raw_dat_o                 => raw_dat_ch0,
        raw_req_i                 => raw_req_ch0,
        raw_ack_o                 => raw_ack_ch0,
        fsfb_addr_i               => fsfb_addr_ch0,
        fsfb_dat_o                => fsfb_dat_ch0,
        flux_cnt_ws_dat_o         => flux_cnt_ws_dat_ch0,
        filtered_addr_i           => filtered_addr_ch0,
        filtered_dat_o            => filtered_dat_ch0,
        adc_offset_dat_i          => adc_offset_dat_ch0,
        adc_offset_adr_o          => adc_offset_addr_ch0,
        servo_mode_i              => servo_mode,
        ramp_step_size_i          => ramp_step_size,
        ramp_amp_i                => ramp_amp,
        const_val_i               => const_val,
        num_ramp_frame_cycles_i   => num_ramp_frame_cycles,
        p_addr_o                  => p_addr_ch0,
        p_dat_i                   => p_dat_ch0,
        i_addr_o                  => i_addr_ch0,
        i_dat_i                   => i_dat_ch0,
        d_addr_o                  => d_addr_ch0,
        d_dat_i                   => d_dat_ch0,
        flux_quanta_addr_o        => flux_quanta_addr_ch0,
        flux_quanta_dat_i         => flux_quanta_dat_ch0,
        sa_bias_dat_i             => sa_bias_dat_ch0,
        offset_dat_i              => offset_dat_ch0,
        filter_coeff0_i           => filter_coeff0,
        filter_coeff1_i           => filter_coeff1,
        filter_coeff2_i           => filter_coeff2,
        filter_coeff3_i           => filter_coeff3,
        filter_coeff4_i           => filter_coeff4,
        filter_coeff5_i           => filter_coeff5,
        filter_coeff6_i           => filter_coeff6,
        dac_dat_o                 => dac_dat_ch0_o,
        dac_clk_o                 => dac_clk_ch0_o,
        sa_bias_dac_spi_o         => sa_bias_dac_spi_ch0_o,
        offset_dac_spi_o          => offset_dac_spi_ch0_o,
        fsfb_fltr_dat_rdy_o       => open,
        fsfb_fltr_dat_o           => open,
        
        --  fsfb_corr interface
        fsfb_ctrl_lock_en_o         => fsfb_ctrl_lock_en,   
        flux_quanta_o               => flux_quanta0,   
        fsfb_ctrl_dat_o             => fsfb_ctrl_dat0,   
        fsfb_ctrl_dat_rdy_o         => fsfb_ctrl_dat0_rdy,      
        num_flux_quanta_prev_o      => num_flux_quanta_prev0,   
        num_flux_quanta_pres_rdy_i  => num_flux_quanta_pres_rdy,   
        num_flux_quanta_pres_i      => num_flux_quanta_pres0,   
        fsfb_ctrl_dat_rdy_i         => fsfb_ctrl_corr_rdy,   
        fsfb_ctrl_dat_i             => fsfb_ctrl_corr0         
     );

  
  i_flux_loop_ctrl_ch1 : flux_loop_ctrl
    port map (
        adc_dat_i                 => adc_dat_ch1_i,
        adc_ovr_i                 => adc_ovr_ch1_i,
        adc_rdy_i                 => adc_rdy_ch1_i,
        adc_clk_o                 => adc_clk_ch1_o,
        clk_50_i                  => clk_50_i,
        clk_25_i                  => clk_25_i,
        rst_i                     => rst_i,
        adc_coadd_en_i            => adc_coadd_en_i,
        restart_frame_1row_prev_i => restart_frame_1row_prev_i,
        restart_frame_aligned_i   => restart_frame_aligned_i,
        restart_frame_1row_post_i => restart_frame_1row_post_i,
        row_switch_i              => row_switch_i,
        initialize_window_i       => initialize_window_i,
        num_rows_sub1_i           => (others =>'0'),                      -- not used
        dac_dat_en_i              => dac_dat_en_i,
        coadded_addr_i            => coadded_addr_ch1,
        coadded_dat_o             => coadded_dat_ch1,
        raw_addr_i                => raw_addr_ch1,
        raw_dat_o                 => raw_dat_ch1,
        raw_req_i                 => raw_req_ch1,
        raw_ack_o                 => raw_ack_ch1,
        fsfb_addr_i               => fsfb_addr_ch1,
        fsfb_dat_o                => fsfb_dat_ch1,
        flux_cnt_ws_dat_o         => flux_cnt_ws_dat_ch1,
        filtered_addr_i           => filtered_addr_ch1,
        filtered_dat_o            => filtered_dat_ch1,
        adc_offset_dat_i          => adc_offset_dat_ch1,
        adc_offset_adr_o          => adc_offset_addr_ch1,
        servo_mode_i              => servo_mode,
        ramp_step_size_i          => ramp_step_size,
        ramp_amp_i                => ramp_amp,
        const_val_i               => const_val,
        num_ramp_frame_cycles_i   => num_ramp_frame_cycles,
        p_addr_o                  => p_addr_ch1,
        p_dat_i                   => p_dat_ch1,
        i_addr_o                  => i_addr_ch1,
        i_dat_i                   => i_dat_ch1,
        d_addr_o                  => d_addr_ch1,
        d_dat_i                   => d_dat_ch1,
        flux_quanta_addr_o        => flux_quanta_addr_ch1,
        flux_quanta_dat_i         => flux_quanta_dat_ch1,
        sa_bias_dat_i             => sa_bias_dat_ch1,
        offset_dat_i              => offset_dat_ch1,
        filter_coeff0_i           => filter_coeff0,
        filter_coeff1_i           => filter_coeff1,
        filter_coeff2_i           => filter_coeff2,
        filter_coeff3_i           => filter_coeff3,
        filter_coeff4_i           => filter_coeff4,
        filter_coeff5_i           => filter_coeff5,
        filter_coeff6_i           => filter_coeff6,
        dac_dat_o                 => dac_dat_ch1_o,
        dac_clk_o                 => dac_clk_ch1_o,
        sa_bias_dac_spi_o         => sa_bias_dac_spi_ch1_o,
        offset_dac_spi_o          => offset_dac_spi_ch1_o,
        fsfb_fltr_dat_rdy_o       => open,
        fsfb_fltr_dat_o           => open,
        
        --  fsfb_corr interface
        fsfb_ctrl_lock_en_o         => open,   
        flux_quanta_o               => flux_quanta1,   
        fsfb_ctrl_dat_o             => fsfb_ctrl_dat1,   
        fsfb_ctrl_dat_rdy_o         => fsfb_ctrl_dat1_rdy,      
        num_flux_quanta_prev_o      => num_flux_quanta_prev1,   
        num_flux_quanta_pres_rdy_i  => num_flux_quanta_pres_rdy,   
        num_flux_quanta_pres_i      => num_flux_quanta_pres1,   
        fsfb_ctrl_dat_rdy_i         => fsfb_ctrl_corr_rdy,   
        fsfb_ctrl_dat_i             => fsfb_ctrl_corr1         
     );


  i_flux_loop_ctrl_ch2 : flux_loop_ctrl

    port map (
        adc_dat_i                 => adc_dat_ch2_i,
        adc_ovr_i                 => adc_ovr_ch2_i,
        adc_rdy_i                 => adc_rdy_ch2_i,
        adc_clk_o                 => adc_clk_ch2_o,
        clk_50_i                  => clk_50_i,
        clk_25_i                  => clk_25_i,
        rst_i                     => rst_i,
        adc_coadd_en_i            => adc_coadd_en_i,
        restart_frame_1row_prev_i => restart_frame_1row_prev_i,
        restart_frame_aligned_i   => restart_frame_aligned_i,
        restart_frame_1row_post_i => restart_frame_1row_post_i,
        row_switch_i              => row_switch_i,
        initialize_window_i       => initialize_window_i,
        num_rows_sub1_i           => (others =>'0'),                      -- not used
        dac_dat_en_i              => dac_dat_en_i,
        coadded_addr_i            => coadded_addr_ch2,
        coadded_dat_o             => coadded_dat_ch2,
        raw_addr_i                => raw_addr_ch2,
        raw_dat_o                 => raw_dat_ch2,
        raw_req_i                 => raw_req_ch2,
        raw_ack_o                 => raw_ack_ch2,
        fsfb_addr_i               => fsfb_addr_ch2,
        fsfb_dat_o                => fsfb_dat_ch2,
        flux_cnt_ws_dat_o         => flux_cnt_ws_dat_ch2,
        filtered_addr_i           => filtered_addr_ch2,
        filtered_dat_o            => filtered_dat_ch2,
        adc_offset_dat_i          => adc_offset_dat_ch2,
        adc_offset_adr_o          => adc_offset_addr_ch2,
        servo_mode_i              => servo_mode,
        ramp_step_size_i          => ramp_step_size,
        ramp_amp_i                => ramp_amp,
        const_val_i               => const_val,
        num_ramp_frame_cycles_i   => num_ramp_frame_cycles,
        p_addr_o                  => p_addr_ch2,
        p_dat_i                   => p_dat_ch2,
        i_addr_o                  => i_addr_ch2,
        i_dat_i                   => i_dat_ch2,
        d_addr_o                  => d_addr_ch2,
        d_dat_i                   => d_dat_ch2,
        flux_quanta_addr_o        => flux_quanta_addr_ch2,
        flux_quanta_dat_i         => flux_quanta_dat_ch2,
        sa_bias_dat_i             => sa_bias_dat_ch2,
        offset_dat_i              => offset_dat_ch2,
        filter_coeff0_i           => filter_coeff0,
        filter_coeff1_i           => filter_coeff1,
        filter_coeff2_i           => filter_coeff2,
        filter_coeff3_i           => filter_coeff3,
        filter_coeff4_i           => filter_coeff4,
        filter_coeff5_i           => filter_coeff5,
        filter_coeff6_i           => filter_coeff6,
        dac_dat_o                 => dac_dat_ch2_o,
        dac_clk_o                 => dac_clk_ch2_o,
        sa_bias_dac_spi_o         => sa_bias_dac_spi_ch2_o,
        offset_dac_spi_o          => offset_dac_spi_ch2_o,
        fsfb_fltr_dat_rdy_o       => open,
        fsfb_fltr_dat_o           => open,
        
        --  fsfb_corr interface
        fsfb_ctrl_lock_en_o         => open,   
        flux_quanta_o               => flux_quanta2,   
        fsfb_ctrl_dat_o             => fsfb_ctrl_dat2,   
        fsfb_ctrl_dat_rdy_o         => fsfb_ctrl_dat2_rdy,      
        num_flux_quanta_prev_o      => num_flux_quanta_prev2,   
        num_flux_quanta_pres_rdy_i  => num_flux_quanta_pres_rdy,   
        num_flux_quanta_pres_i      => num_flux_quanta_pres2,   
        fsfb_ctrl_dat_rdy_i         => fsfb_ctrl_corr_rdy,   
        fsfb_ctrl_dat_i             => fsfb_ctrl_corr2         
     );

  
  i_flux_loop_ctrl_ch3 : flux_loop_ctrl

    port map (
        adc_dat_i                 => adc_dat_ch3_i,
        adc_ovr_i                 => adc_ovr_ch3_i,
        adc_rdy_i                 => adc_rdy_ch3_i,
        adc_clk_o                 => adc_clk_ch3_o,
        clk_50_i                  => clk_50_i,
        clk_25_i                  => clk_25_i,
        rst_i                     => rst_i,
        adc_coadd_en_i            => adc_coadd_en_i,
        restart_frame_1row_prev_i => restart_frame_1row_prev_i,
        restart_frame_aligned_i   => restart_frame_aligned_i,
        restart_frame_1row_post_i => restart_frame_1row_post_i,
        row_switch_i              => row_switch_i,
        initialize_window_i       => initialize_window_i,
        num_rows_sub1_i           => (others =>'0'),                      -- not used
        dac_dat_en_i              => dac_dat_en_i,
        coadded_addr_i            => coadded_addr_ch3,
        coadded_dat_o             => coadded_dat_ch3,
        raw_addr_i                => raw_addr_ch3,
        raw_dat_o                 => raw_dat_ch3,
        raw_req_i                 => raw_req_ch3,
        raw_ack_o                 => raw_ack_ch3,
        fsfb_addr_i               => fsfb_addr_ch3,
        fsfb_dat_o                => fsfb_dat_ch3,
        flux_cnt_ws_dat_o         => flux_cnt_ws_dat_ch3,
        filtered_addr_i           => filtered_addr_ch3,
        filtered_dat_o            => filtered_dat_ch3,
        adc_offset_dat_i          => adc_offset_dat_ch3,
        adc_offset_adr_o          => adc_offset_addr_ch3,
        servo_mode_i              => servo_mode,
        ramp_step_size_i          => ramp_step_size,
        ramp_amp_i                => ramp_amp,
        const_val_i               => const_val,
        num_ramp_frame_cycles_i   => num_ramp_frame_cycles,
        p_addr_o                  => p_addr_ch3,
        p_dat_i                   => p_dat_ch3,
        i_addr_o                  => i_addr_ch3,
        i_dat_i                   => i_dat_ch3,
        d_addr_o                  => d_addr_ch3,
        d_dat_i                   => d_dat_ch3,
        flux_quanta_addr_o        => flux_quanta_addr_ch3,
        flux_quanta_dat_i         => flux_quanta_dat_ch3,
        sa_bias_dat_i             => sa_bias_dat_ch3,
        offset_dat_i              => offset_dat_ch3,
        filter_coeff0_i           => filter_coeff0,
        filter_coeff1_i           => filter_coeff1,
        filter_coeff2_i           => filter_coeff2,
        filter_coeff3_i           => filter_coeff3,
        filter_coeff4_i           => filter_coeff4,
        filter_coeff5_i           => filter_coeff5,
        filter_coeff6_i           => filter_coeff6,
        dac_dat_o                 => dac_dat_ch3_o,
        dac_clk_o                 => dac_clk_ch3_o,
        sa_bias_dac_spi_o         => sa_bias_dac_spi_ch3_o,
        offset_dac_spi_o          => offset_dac_spi_ch3_o,
        fsfb_fltr_dat_rdy_o       => open,
        fsfb_fltr_dat_o           => open,
        
        --  fsfb_corr interface
        fsfb_ctrl_lock_en_o         => open,   
        flux_quanta_o               => flux_quanta3,   
        fsfb_ctrl_dat_o             => fsfb_ctrl_dat3,   
        fsfb_ctrl_dat_rdy_o         => fsfb_ctrl_dat3_rdy,      
        num_flux_quanta_prev_o      => num_flux_quanta_prev3,   
        num_flux_quanta_pres_rdy_i  => num_flux_quanta_pres_rdy,   
        num_flux_quanta_pres_i      => num_flux_quanta_pres3,   
        fsfb_ctrl_dat_rdy_i         => fsfb_ctrl_corr_rdy,   
        fsfb_ctrl_dat_i             => fsfb_ctrl_corr3         
     );

  
  i_flux_loop_ctrl_ch4 : flux_loop_ctrl

    port map (
        adc_dat_i                 => adc_dat_ch4_i,
        adc_ovr_i                 => adc_ovr_ch4_i,
        adc_rdy_i                 => adc_rdy_ch4_i,
        adc_clk_o                 => adc_clk_ch4_o,
        clk_50_i                  => clk_50_i,
        clk_25_i                  => clk_25_i,
        rst_i                     => rst_i,
        adc_coadd_en_i            => adc_coadd_en_i,
        restart_frame_1row_prev_i => restart_frame_1row_prev_i,
        restart_frame_aligned_i   => restart_frame_aligned_i,
        restart_frame_1row_post_i => restart_frame_1row_post_i,
        row_switch_i              => row_switch_i,
        initialize_window_i       => initialize_window_i,
        num_rows_sub1_i           => (others =>'0'),                      -- not used
        dac_dat_en_i              => dac_dat_en_i,
        coadded_addr_i            => coadded_addr_ch4,
        coadded_dat_o             => coadded_dat_ch4,
        raw_addr_i                => raw_addr_ch4,
        raw_dat_o                 => raw_dat_ch4,
        raw_req_i                 => raw_req_ch4,
        raw_ack_o                 => raw_ack_ch4,
        fsfb_addr_i               => fsfb_addr_ch4,
        fsfb_dat_o                => fsfb_dat_ch4,
        flux_cnt_ws_dat_o         => flux_cnt_ws_dat_ch4,
        filtered_addr_i           => filtered_addr_ch4,
        filtered_dat_o            => filtered_dat_ch4,
        adc_offset_dat_i          => adc_offset_dat_ch4,
        adc_offset_adr_o          => adc_offset_addr_ch4,
        servo_mode_i              => servo_mode,
        ramp_step_size_i          => ramp_step_size,
        ramp_amp_i                => ramp_amp,
        const_val_i               => const_val,
        num_ramp_frame_cycles_i   => num_ramp_frame_cycles,
        p_addr_o                  => p_addr_ch4,
        p_dat_i                   => p_dat_ch4,
        i_addr_o                  => i_addr_ch4,
        i_dat_i                   => i_dat_ch4,
        d_addr_o                  => d_addr_ch4,
        d_dat_i                   => d_dat_ch4,
        flux_quanta_addr_o        => flux_quanta_addr_ch4,
        flux_quanta_dat_i         => flux_quanta_dat_ch4,
        sa_bias_dat_i             => sa_bias_dat_ch4,
        offset_dat_i              => offset_dat_ch4,
        filter_coeff0_i           => filter_coeff0,
        filter_coeff1_i           => filter_coeff1,
        filter_coeff2_i           => filter_coeff2,
        filter_coeff3_i           => filter_coeff3,
        filter_coeff4_i           => filter_coeff4,
        filter_coeff5_i           => filter_coeff5,
        filter_coeff6_i           => filter_coeff6,
        dac_dat_o                 => dac_dat_ch4_o,
        dac_clk_o                 => dac_clk_ch4_o,
        sa_bias_dac_spi_o         => sa_bias_dac_spi_ch4_o,
        offset_dac_spi_o          => offset_dac_spi_ch4_o,
        fsfb_fltr_dat_rdy_o       => open,
        fsfb_fltr_dat_o           => open,
        
        --  fsfb_corr interface
        fsfb_ctrl_lock_en_o         => open,   
        flux_quanta_o               => flux_quanta4,   
        fsfb_ctrl_dat_o             => fsfb_ctrl_dat4,   
        fsfb_ctrl_dat_rdy_o         => fsfb_ctrl_dat4_rdy,      
        num_flux_quanta_prev_o      => num_flux_quanta_prev4,   
        num_flux_quanta_pres_rdy_i  => num_flux_quanta_pres_rdy,   
        num_flux_quanta_pres_i      => num_flux_quanta_pres4,   
        fsfb_ctrl_dat_rdy_i         => fsfb_ctrl_corr_rdy,   
        fsfb_ctrl_dat_i             => fsfb_ctrl_corr4         
     );

  
  i_flux_loop_ctrl_ch5 : flux_loop_ctrl

    port map (
        adc_dat_i                 => adc_dat_ch5_i,
        adc_ovr_i                 => adc_ovr_ch5_i,
        adc_rdy_i                 => adc_rdy_ch5_i,
        adc_clk_o                 => adc_clk_ch5_o,
        clk_50_i                  => clk_50_i,
        clk_25_i                  => clk_25_i,
        rst_i                     => rst_i,
        adc_coadd_en_i            => adc_coadd_en_i,
        restart_frame_1row_prev_i => restart_frame_1row_prev_i,
        restart_frame_aligned_i   => restart_frame_aligned_i,
        restart_frame_1row_post_i => restart_frame_1row_post_i,
        row_switch_i              => row_switch_i,
        initialize_window_i       => initialize_window_i,
        num_rows_sub1_i           => (others =>'0'),                      -- not used
        dac_dat_en_i              => dac_dat_en_i,
        coadded_addr_i            => coadded_addr_ch5,
        coadded_dat_o             => coadded_dat_ch5,
        raw_addr_i                => raw_addr_ch5,
        raw_dat_o                 => raw_dat_ch5,
        raw_req_i                 => raw_req_ch5,
        raw_ack_o                 => raw_ack_ch5,
        fsfb_addr_i               => fsfb_addr_ch5,
        fsfb_dat_o                => fsfb_dat_ch5,
        flux_cnt_ws_dat_o         => flux_cnt_ws_dat_ch5,
        filtered_addr_i           => filtered_addr_ch5,
        filtered_dat_o            => filtered_dat_ch5,
        adc_offset_dat_i          => adc_offset_dat_ch5,
        adc_offset_adr_o          => adc_offset_addr_ch5,
        servo_mode_i              => servo_mode,
        ramp_step_size_i          => ramp_step_size,
        ramp_amp_i                => ramp_amp,
        const_val_i               => const_val,
        num_ramp_frame_cycles_i   => num_ramp_frame_cycles,
        p_addr_o                  => p_addr_ch5,
        p_dat_i                   => p_dat_ch5,
        i_addr_o                  => i_addr_ch5,
        i_dat_i                   => i_dat_ch5,
        d_addr_o                  => d_addr_ch5,
        d_dat_i                   => d_dat_ch5,
        flux_quanta_addr_o        => flux_quanta_addr_ch5,
        flux_quanta_dat_i         => flux_quanta_dat_ch5,
        sa_bias_dat_i             => sa_bias_dat_ch5,
        offset_dat_i              => offset_dat_ch5,
        filter_coeff0_i           => filter_coeff0,
        filter_coeff1_i           => filter_coeff1,
        filter_coeff2_i           => filter_coeff2,
        filter_coeff3_i           => filter_coeff3,
        filter_coeff4_i           => filter_coeff4,
        filter_coeff5_i           => filter_coeff5,
        filter_coeff6_i           => filter_coeff6,
        dac_dat_o                 => dac_dat_ch5_o,
        dac_clk_o                 => dac_clk_ch5_o,
        sa_bias_dac_spi_o         => sa_bias_dac_spi_ch5_o,
        offset_dac_spi_o          => offset_dac_spi_ch5_o,
        fsfb_fltr_dat_rdy_o       => open,
        fsfb_fltr_dat_o           => open,
        
        --  fsfb_corr interface
        fsfb_ctrl_lock_en_o         => open,   
        flux_quanta_o               => flux_quanta5,   
        fsfb_ctrl_dat_o             => fsfb_ctrl_dat5,   
        fsfb_ctrl_dat_rdy_o         => fsfb_ctrl_dat5_rdy,      
        num_flux_quanta_prev_o      => num_flux_quanta_prev5,   
        num_flux_quanta_pres_rdy_i  => num_flux_quanta_pres_rdy,   
        num_flux_quanta_pres_i      => num_flux_quanta_pres5,   
        fsfb_ctrl_dat_rdy_i         => fsfb_ctrl_corr_rdy,   
        fsfb_ctrl_dat_i             => fsfb_ctrl_corr5         
     );

  
  i_flux_loop_ctrl_ch6 : flux_loop_ctrl

    port map (
        adc_dat_i                 => adc_dat_ch6_i,
        adc_ovr_i                 => adc_ovr_ch6_i,
        adc_rdy_i                 => adc_rdy_ch6_i,
        adc_clk_o                 => adc_clk_ch6_o,
        clk_50_i                  => clk_50_i,
        clk_25_i                  => clk_25_i,
        rst_i                     => rst_i,
        adc_coadd_en_i            => adc_coadd_en_i,
        restart_frame_1row_prev_i => restart_frame_1row_prev_i,
        restart_frame_aligned_i   => restart_frame_aligned_i,
        restart_frame_1row_post_i => restart_frame_1row_post_i,
        row_switch_i              => row_switch_i,
        initialize_window_i       => initialize_window_i,
        num_rows_sub1_i           => (others =>'0'),                      -- not used
        dac_dat_en_i              => dac_dat_en_i,
        coadded_addr_i            => coadded_addr_ch6,
        coadded_dat_o             => coadded_dat_ch6,
        raw_addr_i                => raw_addr_ch6,
        raw_dat_o                 => raw_dat_ch6,
        raw_req_i                 => raw_req_ch6,
        raw_ack_o                 => raw_ack_ch6,
        fsfb_addr_i               => fsfb_addr_ch6,
        fsfb_dat_o                => fsfb_dat_ch6,
        flux_cnt_ws_dat_o         => flux_cnt_ws_dat_ch6,
        filtered_addr_i           => filtered_addr_ch6,
        filtered_dat_o            => filtered_dat_ch6,
        adc_offset_dat_i          => adc_offset_dat_ch6,
        adc_offset_adr_o          => adc_offset_addr_ch6,
        servo_mode_i              => servo_mode,
        ramp_step_size_i          => ramp_step_size,
        ramp_amp_i                => ramp_amp,
        const_val_i               => const_val,
        num_ramp_frame_cycles_i   => num_ramp_frame_cycles,
        p_addr_o                  => p_addr_ch6,
        p_dat_i                   => p_dat_ch6,
        i_addr_o                  => i_addr_ch6,
        i_dat_i                   => i_dat_ch6,
        d_addr_o                  => d_addr_ch6,
        d_dat_i                   => d_dat_ch6,
        flux_quanta_addr_o        => flux_quanta_addr_ch6,
        flux_quanta_dat_i         => flux_quanta_dat_ch6,
        sa_bias_dat_i             => sa_bias_dat_ch6,
        offset_dat_i              => offset_dat_ch6,
        filter_coeff0_i           => filter_coeff0,
        filter_coeff1_i           => filter_coeff1,
        filter_coeff2_i           => filter_coeff2,
        filter_coeff3_i           => filter_coeff3,
        filter_coeff4_i           => filter_coeff4,
        filter_coeff5_i           => filter_coeff5,
        filter_coeff6_i           => filter_coeff6,
        dac_dat_o                 => dac_dat_ch6_o,
        dac_clk_o                 => dac_clk_ch6_o,
        sa_bias_dac_spi_o         => sa_bias_dac_spi_ch6_o,
        offset_dac_spi_o          => offset_dac_spi_ch6_o,
        fsfb_fltr_dat_rdy_o       => open,
        fsfb_fltr_dat_o           => open,
        
        --  fsfb_corr interface
        fsfb_ctrl_lock_en_o         => open,   
        flux_quanta_o               => flux_quanta6,   
        fsfb_ctrl_dat_o             => fsfb_ctrl_dat6,   
        fsfb_ctrl_dat_rdy_o         => fsfb_ctrl_dat6_rdy,      
        num_flux_quanta_prev_o      => num_flux_quanta_prev6,   
        num_flux_quanta_pres_rdy_i  => num_flux_quanta_pres_rdy,   
        num_flux_quanta_pres_i      => num_flux_quanta_pres6,   
        fsfb_ctrl_dat_rdy_i         => fsfb_ctrl_corr_rdy,   
        fsfb_ctrl_dat_i             => fsfb_ctrl_corr6         
     );

  
  i_flux_loop_ctrl_ch7 : flux_loop_ctrl

    port map (
        adc_dat_i                 => adc_dat_ch7_i,
        adc_ovr_i                 => adc_ovr_ch7_i,
        adc_rdy_i                 => adc_rdy_ch7_i,
        adc_clk_o                 => adc_clk_ch7_o,
        clk_50_i                  => clk_50_i,
        clk_25_i                  => clk_25_i,
        rst_i                     => rst_i,
        adc_coadd_en_i            => adc_coadd_en_i,
        restart_frame_1row_prev_i => restart_frame_1row_prev_i,
        restart_frame_aligned_i   => restart_frame_aligned_i,
        restart_frame_1row_post_i => restart_frame_1row_post_i,
        row_switch_i              => row_switch_i,
        initialize_window_i       => initialize_window_i,
        num_rows_sub1_i           => (others =>'0'),                      -- not used
        dac_dat_en_i              => dac_dat_en_i,
        coadded_addr_i            => coadded_addr_ch7,
        coadded_dat_o             => coadded_dat_ch7,
        raw_addr_i                => raw_addr_ch7,
        raw_dat_o                 => raw_dat_ch7,
        raw_req_i                 => raw_req_ch7,
        raw_ack_o                 => raw_ack_ch7,
        fsfb_addr_i               => fsfb_addr_ch7,
        fsfb_dat_o                => fsfb_dat_ch7,
        flux_cnt_ws_dat_o         => flux_cnt_ws_dat_ch7,
        filtered_addr_i           => filtered_addr_ch7,
        filtered_dat_o            => filtered_dat_ch7,
        adc_offset_dat_i          => adc_offset_dat_ch7,
        adc_offset_adr_o          => adc_offset_addr_ch7,
        servo_mode_i              => servo_mode,
        ramp_step_size_i          => ramp_step_size,
        ramp_amp_i                => ramp_amp,
        const_val_i               => const_val,
        num_ramp_frame_cycles_i   => num_ramp_frame_cycles,
        p_addr_o                  => p_addr_ch7,
        p_dat_i                   => p_dat_ch7,
        i_addr_o                  => i_addr_ch7,
        i_dat_i                   => i_dat_ch7,
        d_addr_o                  => d_addr_ch7,
        d_dat_i                   => d_dat_ch7,
        flux_quanta_addr_o        => flux_quanta_addr_ch7,
        flux_quanta_dat_i         => flux_quanta_dat_ch7,
        sa_bias_dat_i             => sa_bias_dat_ch7,
        offset_dat_i              => offset_dat_ch7,
        filter_coeff0_i           => filter_coeff0,
        filter_coeff1_i           => filter_coeff1,
        filter_coeff2_i           => filter_coeff2,
        filter_coeff3_i           => filter_coeff3,
        filter_coeff4_i           => filter_coeff4,
        filter_coeff5_i           => filter_coeff5,
        filter_coeff6_i           => filter_coeff6,
        dac_dat_o                 => dac_dat_ch7_o,
        dac_clk_o                 => dac_clk_ch7_o,
        sa_bias_dac_spi_o         => sa_bias_dac_spi_ch7_o,
        offset_dac_spi_o          => offset_dac_spi_ch7_o,
        fsfb_fltr_dat_rdy_o       => open,
        fsfb_fltr_dat_o           => open,
        
        --  fsfb_corr interface
        fsfb_ctrl_lock_en_o         => open,   
        flux_quanta_o               => flux_quanta7,   
        fsfb_ctrl_dat_o             => fsfb_ctrl_dat7,   
        fsfb_ctrl_dat_rdy_o         => fsfb_ctrl_dat7_rdy,      
        num_flux_quanta_prev_o      => num_flux_quanta_prev7,   
        num_flux_quanta_pres_rdy_i  => num_flux_quanta_pres_rdy,   
        num_flux_quanta_pres_i      => num_flux_quanta_pres7,   
        fsfb_ctrl_dat_rdy_i         => fsfb_ctrl_corr_rdy,   
        fsfb_ctrl_dat_i             => fsfb_ctrl_corr7         
     );


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
      
      fsfb_ctrl_dat_rdy0_i       => fsfb_ctrl_dat0_rdy,
      fsfb_ctrl_dat_rdy1_i       => fsfb_ctrl_dat1_rdy,
      fsfb_ctrl_dat_rdy2_i       => fsfb_ctrl_dat2_rdy,
      fsfb_ctrl_dat_rdy3_i       => fsfb_ctrl_dat3_rdy,
      fsfb_ctrl_dat_rdy4_i       => fsfb_ctrl_dat4_rdy,
      fsfb_ctrl_dat_rdy5_i       => fsfb_ctrl_dat5_rdy,
      fsfb_ctrl_dat_rdy6_i       => fsfb_ctrl_dat6_rdy,
      fsfb_ctrl_dat_rdy7_i       => fsfb_ctrl_dat7_rdy,
      
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
  -- Instantiation of wbs_frame_data
  -----------------------------------------------------------------------------

  i_wbs_frame_data: wbs_frame_data
    port map (
        rst_i               => rst_i,
        clk_i               => clk_50_i,
        restart_frame_1row_post_i => restart_frame_1row_post_i,        
        filtered_addr_ch0_o => filtered_addr_ch0,
        filtered_dat_ch0_i  => filtered_dat_ch0,
        fsfb_addr_ch0_o     => fsfb_addr_ch0,
        fsfb_dat_ch0_i      => fsfb_dat_ch0,
        flux_cnt_dat_ch0_i  => flux_cnt_ws_dat_ch0,
        coadded_addr_ch0_o  => coadded_addr_ch0,
        coadded_dat_ch0_i   => coadded_dat_ch0,
        raw_addr_ch0_o      => raw_addr_ch0,
        raw_dat_ch0_i       => raw_dat_ch0,
        raw_req_ch0_o       => raw_req_ch0,
        raw_ack_ch0_i       => raw_ack_ch0,
        filtered_addr_ch1_o => filtered_addr_ch1,
        filtered_dat_ch1_i  => filtered_dat_ch1,
        fsfb_addr_ch1_o     => fsfb_addr_ch1,
        fsfb_dat_ch1_i      => fsfb_dat_ch1,
        flux_cnt_dat_ch1_i  => flux_cnt_ws_dat_ch1,
        coadded_addr_ch1_o  => coadded_addr_ch1,
        coadded_dat_ch1_i   => coadded_dat_ch1,
        raw_addr_ch1_o      => raw_addr_ch1,
        raw_dat_ch1_i       => raw_dat_ch1,
        raw_req_ch1_o       => raw_req_ch1,
        raw_ack_ch1_i       => raw_ack_ch1,
        filtered_addr_ch2_o => filtered_addr_ch2,
        filtered_dat_ch2_i  => filtered_dat_ch2,
        fsfb_addr_ch2_o     => fsfb_addr_ch2,
        fsfb_dat_ch2_i      => fsfb_dat_ch2,
        flux_cnt_dat_ch2_i  => flux_cnt_ws_dat_ch2,
        coadded_addr_ch2_o  => coadded_addr_ch2,
        coadded_dat_ch2_i   => coadded_dat_ch2,
        raw_addr_ch2_o      => raw_addr_ch2,
        raw_dat_ch2_i       => raw_dat_ch2,
        raw_req_ch2_o       => raw_req_ch2,
        raw_ack_ch2_i       => raw_ack_ch2,
        filtered_addr_ch3_o => filtered_addr_ch3,
        filtered_dat_ch3_i  => filtered_dat_ch3,
        fsfb_addr_ch3_o     => fsfb_addr_ch3,
        fsfb_dat_ch3_i      => fsfb_dat_ch3,
        flux_cnt_dat_ch3_i  => flux_cnt_ws_dat_ch3,
        coadded_addr_ch3_o  => coadded_addr_ch3,
        coadded_dat_ch3_i   => coadded_dat_ch3,
        raw_addr_ch3_o      => raw_addr_ch3,
        raw_dat_ch3_i       => raw_dat_ch3,
        raw_req_ch3_o       => raw_req_ch3,
        raw_ack_ch3_i       => raw_ack_ch3,
        filtered_addr_ch4_o => filtered_addr_ch4,
        filtered_dat_ch4_i  => filtered_dat_ch4,
        fsfb_addr_ch4_o     => fsfb_addr_ch4,
        fsfb_dat_ch4_i      => fsfb_dat_ch4,
        flux_cnt_dat_ch4_i  => flux_cnt_ws_dat_ch4,
        coadded_addr_ch4_o  => coadded_addr_ch4,
        coadded_dat_ch4_i   => coadded_dat_ch4,
        raw_addr_ch4_o      => raw_addr_ch4,
        raw_dat_ch4_i       => raw_dat_ch4,
        raw_req_ch4_o       => raw_req_ch4,
        raw_ack_ch4_i       => raw_ack_ch4,
        filtered_addr_ch5_o => filtered_addr_ch5,
        filtered_dat_ch5_i  => filtered_dat_ch5,
        fsfb_addr_ch5_o     => fsfb_addr_ch5,
        fsfb_dat_ch5_i      => fsfb_dat_ch5,
        flux_cnt_dat_ch5_i  => flux_cnt_ws_dat_ch5,
        coadded_addr_ch5_o  => coadded_addr_ch5,
        coadded_dat_ch5_i   => coadded_dat_ch5,
        raw_addr_ch5_o      => raw_addr_ch5,
        raw_dat_ch5_i       => raw_dat_ch5,
        raw_req_ch5_o       => raw_req_ch5,
        raw_ack_ch5_i       => raw_ack_ch5,
        filtered_addr_ch6_o => filtered_addr_ch6,
        filtered_dat_ch6_i  => filtered_dat_ch6,
        fsfb_addr_ch6_o     => fsfb_addr_ch6,
        fsfb_dat_ch6_i      => fsfb_dat_ch6,
        flux_cnt_dat_ch6_i  => flux_cnt_ws_dat_ch6,
        coadded_addr_ch6_o  => coadded_addr_ch6,
        coadded_dat_ch6_i   => coadded_dat_ch6,
        raw_addr_ch6_o      => raw_addr_ch6,
        raw_dat_ch6_i       => raw_dat_ch6,
        raw_req_ch6_o       => raw_req_ch6,
        raw_ack_ch6_i       => raw_ack_ch6,
        filtered_addr_ch7_o => filtered_addr_ch7,
        filtered_dat_ch7_i  => filtered_dat_ch7,
        fsfb_addr_ch7_o     => fsfb_addr_ch7,
        fsfb_dat_ch7_i      => fsfb_dat_ch7,
        flux_cnt_dat_ch7_i  => flux_cnt_ws_dat_ch7,
        coadded_addr_ch7_o  => coadded_addr_ch7,
        coadded_dat_ch7_i   => coadded_dat_ch7,
        raw_addr_ch7_o      => raw_addr_ch7,
        raw_dat_ch7_i       => raw_dat_ch7,
        raw_req_ch7_o       => raw_req_ch7,
        raw_ack_ch7_i       => raw_ack_ch7,
        dat_i               => dat_i,
        addr_i              => addr_i,
        tga_i               => tga_i,
        we_i                => we_i,
        stb_i               => stb_i,
        cyc_i               => cyc_i,
        dat_o               => dat_frame_o,
        ack_o               => ack_frame_o);

  -----------------------------------------------------------------------------
  -- Instantiation of wbs_fb_data
  -----------------------------------------------------------------------------

  i_wbs_fb_data: wbs_fb_data
    port map (
        clk_50_i                => clk_50_i,
        rst_i                   => rst_i,
        adc_offset_dat_ch0_o    => adc_offset_dat_ch0,
        adc_offset_addr_ch0_i   => adc_offset_addr_ch0,
        p_dat_ch0_o             => p_dat_ch0,
        p_addr_ch0_i            => p_addr_ch0,
        i_dat_ch0_o             => i_dat_ch0,
        i_addr_ch0_i            => i_addr_ch0,
        d_dat_ch0_o             => d_dat_ch0,
        d_addr_ch0_i            => d_addr_ch0,
        flux_quanta_dat_ch0_o   => flux_quanta_dat_ch0,
        flux_quanta_addr_ch0_i  => flux_quanta_addr_ch0,
        sa_bias_ch0_o           => sa_bias_dat_ch0,
        offset_dat_ch0_o        => offset_dat_ch0,
        adc_offset_dat_ch1_o    => adc_offset_dat_ch1,
        adc_offset_addr_ch1_i   => adc_offset_addr_ch1,
        p_dat_ch1_o             => p_dat_ch1,
        p_addr_ch1_i            => p_addr_ch1,
        i_dat_ch1_o             => i_dat_ch1,
        i_addr_ch1_i            => i_addr_ch1,
        d_dat_ch1_o             => d_dat_ch1,
        d_addr_ch1_i            => d_addr_ch1,
        flux_quanta_dat_ch1_o   => flux_quanta_dat_ch1,
        flux_quanta_addr_ch1_i  => flux_quanta_addr_ch1,
        sa_bias_ch1_o           => sa_bias_dat_ch1,
        offset_dat_ch1_o        => offset_dat_ch1,
        adc_offset_dat_ch2_o    => adc_offset_dat_ch2,
        adc_offset_addr_ch2_i   => adc_offset_addr_ch2,
        p_dat_ch2_o             => p_dat_ch2,
        p_addr_ch2_i            => p_addr_ch2,
        i_dat_ch2_o             => i_dat_ch2,
        i_addr_ch2_i            => i_addr_ch2,
        d_dat_ch2_o             => d_dat_ch2,
        d_addr_ch2_i            => d_addr_ch2,
        flux_quanta_dat_ch2_o   => flux_quanta_dat_ch2,
        flux_quanta_addr_ch2_i  => flux_quanta_addr_ch2,
        sa_bias_ch2_o           => sa_bias_dat_ch2,
        offset_dat_ch2_o        => offset_dat_ch2,
        adc_offset_dat_ch3_o    => adc_offset_dat_ch3,
        adc_offset_addr_ch3_i   => adc_offset_addr_ch3,
        p_dat_ch3_o             => p_dat_ch3,
        p_addr_ch3_i            => p_addr_ch3,
        i_dat_ch3_o             => i_dat_ch3,
        i_addr_ch3_i            => i_addr_ch3,
        d_dat_ch3_o             => d_dat_ch3,
        d_addr_ch3_i            => d_addr_ch3,
        flux_quanta_dat_ch3_o   => flux_quanta_dat_ch3,
        flux_quanta_addr_ch3_i  => flux_quanta_addr_ch3,
        sa_bias_ch3_o           => sa_bias_dat_ch3,
        offset_dat_ch3_o        => offset_dat_ch3,
        adc_offset_dat_ch4_o    => adc_offset_dat_ch4,
        adc_offset_addr_ch4_i   => adc_offset_addr_ch4,
        p_dat_ch4_o             => p_dat_ch4,
        p_addr_ch4_i            => p_addr_ch4,
        i_dat_ch4_o             => i_dat_ch4,
        i_addr_ch4_i            => i_addr_ch4,
        d_dat_ch4_o             => d_dat_ch4,
        d_addr_ch4_i            => d_addr_ch4,
        flux_quanta_dat_ch4_o   => flux_quanta_dat_ch4,
        flux_quanta_addr_ch4_i  => flux_quanta_addr_ch4,
        sa_bias_ch4_o           => sa_bias_dat_ch4,
        offset_dat_ch4_o        => offset_dat_ch4,
        adc_offset_dat_ch5_o    => adc_offset_dat_ch5,
        adc_offset_addr_ch5_i   => adc_offset_addr_ch5,
        p_dat_ch5_o             => p_dat_ch5,
        p_addr_ch5_i            => p_addr_ch5,
        i_dat_ch5_o             => i_dat_ch5,
        i_addr_ch5_i            => i_addr_ch5,
        d_dat_ch5_o             => d_dat_ch5,
        d_addr_ch5_i            => d_addr_ch5,
        flux_quanta_dat_ch5_o    => flux_quanta_dat_ch5,
        flux_quanta_addr_ch5_i   => flux_quanta_addr_ch5,
        sa_bias_ch5_o           => sa_bias_dat_ch5,
        offset_dat_ch5_o        => offset_dat_ch5,
        adc_offset_dat_ch6_o    => adc_offset_dat_ch6,
        adc_offset_addr_ch6_i   => adc_offset_addr_ch6,
        p_dat_ch6_o             => p_dat_ch6,
        p_addr_ch6_i            => p_addr_ch6,
        i_dat_ch6_o             => i_dat_ch6,
        i_addr_ch6_i            => i_addr_ch6,
        d_dat_ch6_o             => d_dat_ch6,
        d_addr_ch6_i            => d_addr_ch6,
        flux_quanta_dat_ch6_o   => flux_quanta_dat_ch6,
        flux_quanta_addr_ch6_i  => flux_quanta_addr_ch6,
        sa_bias_ch6_o           => sa_bias_dat_ch6,
        offset_dat_ch6_o        => offset_dat_ch6,
        adc_offset_dat_ch7_o    => adc_offset_dat_ch7,
        adc_offset_addr_ch7_i   => adc_offset_addr_ch7,
        p_dat_ch7_o             => p_dat_ch7,
        p_addr_ch7_i            => p_addr_ch7,
        i_dat_ch7_o             => i_dat_ch7,
        i_addr_ch7_i            => i_addr_ch7,
        d_dat_ch7_o             => d_dat_ch7,
        d_addr_ch7_i            => d_addr_ch7,
        flux_quanta_dat_ch7_o   => flux_quanta_dat_ch7,
        flux_quanta_addr_ch7_i  => flux_quanta_addr_ch7,
        sa_bias_ch7_o           => sa_bias_dat_ch7,
        offset_dat_ch7_o        => offset_dat_ch7,
        filter_coeff0_o         => filter_coeff0,
        filter_coeff1_o         => filter_coeff1,
        filter_coeff2_o         => filter_coeff2,
        filter_coeff3_o         => filter_coeff3,
        filter_coeff4_o         => filter_coeff4,
        filter_coeff5_o         => filter_coeff5,
        filter_coeff6_o         => filter_coeff6,
        servo_mode_o            => servo_mode,
        ramp_step_size_o        => ramp_step_size,
        ramp_amp_o              => ramp_amp,
        const_val_o             => const_val,
        num_ramp_frame_cycles_o => num_ramp_frame_cycles,
        flux_jumping_en_o       => flux_jumping_en,
        dat_i                   => dat_i,
        addr_i                  => addr_i,
        tga_i                   => tga_i,
        we_i                    => we_i,
        stb_i                   => stb_i,
        cyc_i                   => cyc_i,
        dat_o                   => dat_fb_o,
        ack_o                   => ack_fb_o);
  
  
end struct;
