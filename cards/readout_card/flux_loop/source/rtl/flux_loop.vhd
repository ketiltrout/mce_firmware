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
-- See CVS Record
--
------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;

-- Own Library
use work.flux_loop_pack.all;

-- Call Parent Library
use work.readout_card_pack.all;
use work.adc_sample_coadd_pack.all;

library sys_param;

-- System Library
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;


entity flux_loop is
generic (ADC_LATENCY         : integer := ADC_LATENCY_REVA);
port (
   -- Global signals 
   clk_50_i                  : in std_logic;
   clk_25_i                  : in std_logic;
   rst_i                     : in std_logic;
 
   -- Frame timing signals
   adc_coadd_en_i            : in std_logic;
   restart_frame_1row_prev_i : in std_logic;
   restart_frame_aligned_i   : in std_logic;
   restart_frame_1row_post_i : in std_logic;
   row_switch_i              : in std_logic;
   initialize_window_i       : in std_logic;
   servo_rst_window_i        : in std_logic;
   num_rows_sub1_i           : in std_logic_vector(FSFB_QUEUE_ADDR_WIDTH-1 downto 0);    -- number of rows per frame subtract 1
   dac_dat_en_i              : in std_logic;
   fltr_rst_i                : in std_logic;
   num_rows_i                : in integer;
   num_rows_reported_i       : in integer;
   num_cols_reported_i       : in integer;
   data_size_i               : in std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);

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
   -- For Readout Card Rev. A/AA/B/C
   adc_dat_ch0_i           : in  std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
   adc_dat_ch1_i           : in  std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
   adc_dat_ch2_i           : in  std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
   adc_dat_ch3_i           : in  std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
   adc_dat_ch4_i           : in  std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
   adc_dat_ch5_i           : in  std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
   adc_dat_ch6_i           : in  std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
   adc_dat_ch7_i           : in  std_logic_vector (ADC_DAT_WIDTH-1 downto 0);

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
   offset_dac_spi_ch7_o    : out std_logic_vector(OFFSET_SPI_DATA_WIDTH-1 downto 0)
); 
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
   signal filtered_addr_ch1 : std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
   signal filtered_dat_ch1  : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
   signal fsfb_addr_ch1     : std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
   signal fsfb_dat_ch1      : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
   signal flux_cnt_ws_dat_ch1 : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
   signal coadded_addr_ch1  : std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
   signal coadded_dat_ch1   : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
   signal filtered_addr_ch2 : std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
   signal filtered_dat_ch2  : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
   signal fsfb_addr_ch2     : std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
   signal fsfb_dat_ch2      : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
   signal flux_cnt_ws_dat_ch2 : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
   signal coadded_addr_ch2  : std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
   signal coadded_dat_ch2   : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
   signal filtered_addr_ch3 : std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
   signal filtered_dat_ch3  : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
   signal fsfb_addr_ch3     : std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
   signal fsfb_dat_ch3      : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
   signal flux_cnt_ws_dat_ch3 : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
   signal coadded_addr_ch3  : std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
   signal coadded_dat_ch3   : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
   signal filtered_addr_ch4 : std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
   signal filtered_dat_ch4  : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
   signal fsfb_addr_ch4     : std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
   signal fsfb_dat_ch4      : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
   signal flux_cnt_ws_dat_ch4 : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
   signal coadded_addr_ch4  : std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
   signal coadded_dat_ch4   : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
   signal filtered_addr_ch5 : std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
   signal filtered_dat_ch5  : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
   signal fsfb_addr_ch5     : std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
   signal fsfb_dat_ch5      : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
   signal flux_cnt_ws_dat_ch5 : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
   signal coadded_addr_ch5  : std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
   signal coadded_dat_ch5   : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
   signal filtered_addr_ch6 : std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
   signal filtered_dat_ch6  : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
   signal fsfb_addr_ch6     : std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
   signal fsfb_dat_ch6      : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
   signal flux_cnt_ws_dat_ch6 : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
   signal coadded_addr_ch6  : std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
   signal coadded_dat_ch6   : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
   signal filtered_addr_ch7 : std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
   signal filtered_dat_ch7  : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
   signal fsfb_addr_ch7     : std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
   signal fsfb_dat_ch7      : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
   signal flux_cnt_ws_dat_ch7 : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);
   signal coadded_addr_ch7  : std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
   signal coadded_dat_ch7   : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);

   signal sa_bias_dat_rdy   : std_logic_vector (NUM_COLS-1 downto 0);
   signal offset_dat_rdy    : std_logic_vector (NUM_COLS-1 downto 0);


   -- Signals Interface between wbs_fb_data and flux_loop_ctrl
   signal servo_rst_dat     : std_logic_vector(NUM_COLS-1 downto 0);
   signal servo_rst_dat2    : std_logic_vector(NUM_COLS-1 downto 0);
   signal servo_rst_addr2    : std_logic_vector(SERVO_RST_ADDR_WIDTH-1 downto 0);
   
   signal adc_offset_dat_ch0    : std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
   signal adc_offset_addr_ch0   : std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0);
   signal servo_rst_addr_ch0    : std_logic_vector(SERVO_RST_ADDR_WIDTH-1 downto 0);
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
   signal const_val_ch0         : std_logic_vector(CONST_VAL_WIDTH-1 downto 0);
   signal servo_mode_ch0        : std_logic_vector(SERVO_MODE_SEL_WIDTH-1 downto 0);  
   signal adc_offset_dat_ch1    : std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
   signal adc_offset_addr_ch1   : std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0);
   signal servo_rst_addr_ch1    : std_logic_vector(SERVO_RST_ADDR_WIDTH-1 downto 0);
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
   signal const_val_ch1         : std_logic_vector(CONST_VAL_WIDTH-1 downto 0);
   signal servo_mode_ch1        : std_logic_vector(SERVO_MODE_SEL_WIDTH-1 downto 0);  
   signal adc_offset_dat_ch2    : std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
   signal adc_offset_addr_ch2   : std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0);
   signal servo_rst_addr_ch2    : std_logic_vector(SERVO_RST_ADDR_WIDTH-1 downto 0);
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
   signal const_val_ch2         : std_logic_vector(CONST_VAL_WIDTH-1 downto 0);
   signal servo_mode_ch2        : std_logic_vector(SERVO_MODE_SEL_WIDTH-1 downto 0);  
   signal adc_offset_dat_ch3    : std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
   signal adc_offset_addr_ch3   : std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0);
   signal servo_rst_addr_ch3    : std_logic_vector(SERVO_RST_ADDR_WIDTH-1 downto 0);
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
   signal const_val_ch3         : std_logic_vector(CONST_VAL_WIDTH-1 downto 0);
   signal servo_mode_ch3        : std_logic_vector(SERVO_MODE_SEL_WIDTH-1 downto 0);  
   signal adc_offset_dat_ch4    : std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
   signal adc_offset_addr_ch4   : std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0);
   signal servo_rst_addr_ch4    : std_logic_vector(SERVO_RST_ADDR_WIDTH-1 downto 0);
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
   signal const_val_ch4         : std_logic_vector(CONST_VAL_WIDTH-1 downto 0);
   signal servo_mode_ch4        : std_logic_vector(SERVO_MODE_SEL_WIDTH-1 downto 0);  
   signal adc_offset_dat_ch5    : std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
   signal adc_offset_addr_ch5   : std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0);
   signal servo_rst_addr_ch5    : std_logic_vector(SERVO_RST_ADDR_WIDTH-1 downto 0);
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
   signal const_val_ch5         : std_logic_vector(CONST_VAL_WIDTH-1 downto 0);
   signal servo_mode_ch5        : std_logic_vector(SERVO_MODE_SEL_WIDTH-1 downto 0);  
   signal adc_offset_dat_ch6    : std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
   signal adc_offset_addr_ch6   : std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0);
   signal servo_rst_addr_ch6    : std_logic_vector(SERVO_RST_ADDR_WIDTH-1 downto 0);
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
   signal const_val_ch6         : std_logic_vector(CONST_VAL_WIDTH-1 downto 0);
   signal servo_mode_ch6        : std_logic_vector(SERVO_MODE_SEL_WIDTH-1 downto 0);  
   signal adc_offset_dat_ch7    : std_logic_vector(ADC_OFFSET_DAT_WIDTH-1 downto 0);
   signal adc_offset_addr_ch7   : std_logic_vector(ADC_OFFSET_ADDR_WIDTH-1 downto 0);
   signal servo_rst_addr_ch7    : std_logic_vector(SERVO_RST_ADDR_WIDTH-1 downto 0);
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
   signal const_val_ch7         : std_logic_vector(CONST_VAL_WIDTH-1 downto 0);
   signal servo_mode_ch7        : std_logic_vector(SERVO_MODE_SEL_WIDTH-1 downto 0);  
   signal filter_coeff0         : std_logic_vector(FILTER_COEF_WIDTH-1 downto 0);
   signal filter_coeff1         : std_logic_vector(FILTER_COEF_WIDTH-1 downto 0);
   signal filter_coeff2         : std_logic_vector(FILTER_COEF_WIDTH-1 downto 0);
   signal filter_coeff3         : std_logic_vector(FILTER_COEF_WIDTH-1 downto 0);
   signal filter_coeff4         : std_logic_vector(FILTER_COEF_WIDTH-1 downto 0);
   signal filter_coeff5         : std_logic_vector(FILTER_COEF_WIDTH-1 downto 0);
   signal filter_coeff6         : std_logic_vector(FILTER_COEF_WIDTH-1 downto 0);
   signal ramp_step_size        : std_logic_vector(RAMP_STEP_WIDTH-1 downto 0);
   signal ramp_amp              : std_logic_vector(RAMP_AMP_WIDTH-1 downto 0);
   signal num_ramp_frame_cycles : std_logic_vector(RAMP_CYC_WIDTH-1 downto 0);  
   signal i_clamp_val           : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal qterm_decay_bits      : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   
   
   -- Signals Interface between fsfb_corr and flux_loop_ctrl
   signal flux_jumping_en           : std_logic;    
   signal fj_count_rdy  : std_logic;                                             
   signal fsfb_ctrl_corr_rdy        : std_logic;                                                
   
   signal flux_quanta0              : std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);   
   signal fsfb_ctrl_dat0            : std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0);    
   signal fj_count0                 : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);    
   signal fj_count0_new             : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);    
   signal fsfb_ctrl_dat0_rdy        : std_logic;                                             
   signal fsfb_ctrl_corr0           : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);             
   signal fsfb_ctrl_lock_en0        : std_logic;                                             

   signal flux_quanta1              : std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);   
   signal fsfb_ctrl_dat1            : std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0);    
   signal fj_count1                 : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);    
   signal fj_count1_new             : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);    
   signal fsfb_ctrl_dat1_rdy        : std_logic;                                             
   signal fsfb_ctrl_corr1           : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);             
   signal fsfb_ctrl_lock_en1        : std_logic;                                             

   signal flux_quanta2              : std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);   
   signal fsfb_ctrl_dat2            : std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0);    
   signal fj_count2                 : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);    
   signal fj_count2_new             : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);    
   signal fsfb_ctrl_dat2_rdy        : std_logic;                                             
   signal fsfb_ctrl_corr2           : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);             
   signal fsfb_ctrl_lock_en2        : std_logic;                                             

   signal flux_quanta3              : std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);   
   signal fsfb_ctrl_dat3            : std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0);    
   signal fj_count3                 : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);    
   signal fj_count3_new             : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);    
   signal fsfb_ctrl_dat3_rdy        : std_logic;                                             
   signal fsfb_ctrl_corr3           : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);             
   signal fsfb_ctrl_lock_en3        : std_logic;                                             

   signal flux_quanta4              : std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);   
   signal fsfb_ctrl_dat4            : std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0);    
   signal fj_count4                 : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);    
   signal fj_count4_new             : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);    
   signal fsfb_ctrl_dat4_rdy        : std_logic;                                             
   signal fsfb_ctrl_corr4           : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);             
   signal fsfb_ctrl_lock_en4        : std_logic;                                             

   signal flux_quanta5              : std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);   
   signal fsfb_ctrl_dat5            : std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0);    
   signal fj_count5                 : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);    
   signal fj_count5_new             : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);    
   signal fsfb_ctrl_dat5_rdy        : std_logic;                                             
   signal fsfb_ctrl_corr5           : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);             
   signal fsfb_ctrl_lock_en5        : std_logic;                                             

   signal flux_quanta6              : std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);   
   signal fsfb_ctrl_dat6            : std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0);    
   signal fj_count6                 : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);    
   signal fj_count6_new             : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);    
   signal fsfb_ctrl_dat6_rdy        : std_logic;                                             
   signal fsfb_ctrl_corr6           : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);             
   signal fsfb_ctrl_lock_en6        : std_logic;                                             

   signal flux_quanta7              : std_logic_vector(COEFF_QUEUE_DATA_WIDTH-1 downto 0);   
   signal fsfb_ctrl_dat7            : std_logic_vector(FSFB_QUEUE_DATA_WIDTH-1 downto 0);    
   signal fj_count7                 : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);    
   signal fj_count7_new             : std_logic_vector(FLUX_QUANTA_CNT_WIDTH-1 downto 0);    
   signal fsfb_ctrl_dat7_rdy        : std_logic;                                             
   signal fsfb_ctrl_corr7           : std_logic_vector(DAC_DAT_WIDTH-1 downto 0);             
   signal fsfb_ctrl_lock_en7        : std_logic;                                             

   signal adc_dat      : STD_LOGIC_VECTOR (ADC_DAT_WIDTH-1 DOWNTO 0);
   signal adc_dat_sxt  : STD_LOGIC_VECTOR (RAW_RAM_WIDTH-1 DOWNTO 0);
   signal raw_rd_addr  : STD_LOGIC_VECTOR (RAW_ADDR_WIDTH-1 DOWNTO 0);
   signal raw_wr_addr  : STD_LOGIC_VECTOR (RAW_ADDR_WIDTH-1 DOWNTO 0);
   signal raw_wren     : STD_LOGIC  := '1';
   signal raw_dat      : STD_LOGIC_VECTOR (RAW_RAM_WIDTH-1 DOWNTO 0);
   signal raw_chan     : std_logic_vector (COL_ADDR_WIDTH-1    downto 0);
   signal raw_dat_req  : std_logic;
   signal raw_dat_ack  : std_logic;

   type states is (IDLE, REQ_RECEIVED, STORE_RAW, DONE);
   signal current_state, next_state : states;
  
begin  -- struct

   increment_servo_rst_addr2: process (clk_50_i, rst_i)
   begin  
      if(rst_i = '1') then                
        servo_rst_addr2 <= (others => '0');
      elsif(clk_50_i'event and clk_50_i = '1') then      
         if restart_frame_aligned_i = '1' then
            servo_rst_addr2 <= (others => '0');
         elsif row_switch_i = '1' then
            servo_rst_addr2 <= servo_rst_addr2 + 1;
         end if;              
      end if;
   end process increment_servo_rst_addr2;

  
   -----------------------------------------------------------------------------
   -- Instantiation of Raw Data/ Rectangle Mode RAM block
   -----------------------------------------------------------------------------
   adc_dat <= 
      adc_dat_ch0_i when raw_chan = "000" else
      adc_dat_ch1_i when raw_chan = "001" else
      adc_dat_ch2_i when raw_chan = "010" else
      adc_dat_ch3_i when raw_chan = "011" else
      adc_dat_ch4_i when raw_chan = "100" else
      adc_dat_ch5_i when raw_chan = "101" else
      adc_dat_ch6_i when raw_chan = "110" else
      adc_dat_ch7_i when raw_chan = "111" else
      adc_dat_ch0_i;
      
   adc_dat_sxt <= sxt(adc_dat, RAW_RAM_WIDTH);
   
   rectangle_mode_ram: raw_ram_bank
   port map (
      clock     => clk_50_i,     
      data      => adc_dat_sxt,  
      rdaddress => raw_rd_addr,  
      wraddress => raw_wr_addr,  
      wren      => raw_wren,     
      q         => raw_dat   
   );

   increment_addr: process (clk_50_i, rst_i)
   begin  
      if(rst_i = '1') then                
         raw_wr_addr <= (others => '0');

      elsif(clk_50_i'event and clk_50_i = '1') then
         if(raw_wren = '1') then 
            raw_wr_addr <= raw_wr_addr + 1;
         elsif(raw_wren = '0') then
            raw_wr_addr <= (others => '0');
         end if;
      end if;
   end process increment_addr;
  
   state_FF: process(clk_50_i, rst_i)
   begin
      if(rst_i = '1') then
         current_state <= IDLE;
      elsif(clk_50_i'event and clk_50_i = '1') then
         current_state <= next_state;
      end if;
   end process state_FF;
   
   state_NS: process(current_state, restart_frame_aligned_i, raw_dat_req, raw_wr_addr)
   begin
      next_state <= current_state;
      case current_state is
         when IDLE =>
            if(raw_dat_req = '1') then 
               next_state <= REQ_RECEIVED;
            end if;
         when REQ_RECEIVED =>
            if(restart_frame_aligned_i = '1') then
               next_state <= STORE_RAW;
            end if;
         when STORE_RAW =>
            if(raw_wr_addr = RAW_ADDR_MAX) then
               next_state <= DONE;
            end if;
         when DONE =>
            next_state <= IDLE;
         when others =>
            next_state <= IDLE;
      end case;
   end process state_NS;
   
   state_out: process(current_state)
   begin
      raw_wren    <= '0';
      raw_dat_ack <= '0';

      case current_state is
         when IDLE =>
         when REQ_RECEIVED =>
         when STORE_RAW =>
            raw_wren    <= '1';
         when DONE =>
            raw_dat_ack <= '1';
         when others => 
            NULL;
      end case;
   end process state_out;
  
  -----------------------------------------------------------------------------
   -- Instantiation of Flux Loop Control
   -----------------------------------------------------------------------------
   i_flux_loop_ctrl_ch0: flux_loop_ctrl
   generic map (ADC_LATENCY => ADC_LATENCY)
   port map (
      adc_dat_i                 => adc_dat_ch0_i,
      clk_50_i                  => clk_50_i,
      clk_25_i                  => clk_25_i,
      rst_i                     => rst_i,
      adc_coadd_en_i            => adc_coadd_en_i,
      restart_frame_1row_prev_i => restart_frame_1row_prev_i,
      restart_frame_aligned_i   => restart_frame_aligned_i,
      restart_frame_1row_post_i => restart_frame_1row_post_i,
      row_switch_i              => row_switch_i,
      initialize_window_i       => initialize_window_i,
      servo_rst_window_i        => servo_rst_window_i,
      fltr_rst_i                => fltr_rst_i,
      num_rows_sub1_i           => (others =>'0'),                      -- not used
      dac_dat_en_i              => dac_dat_en_i,
      coadded_addr_i            => coadded_addr_ch0,
      coadded_dat_o             => coadded_dat_ch0,
      fsfb_addr_i               => fsfb_addr_ch0,
      fsfb_dat_o                => fsfb_dat_ch0,
      flux_cnt_ws_dat_o         => flux_cnt_ws_dat_ch0,
      filtered_addr_i           => filtered_addr_ch0,
      filtered_dat_o            => filtered_dat_ch0,
      adc_offset_dat_i          => adc_offset_dat_ch0,
      adc_offset_adr_o          => adc_offset_addr_ch0,
      servo_mode_i              => servo_mode_ch0,
      servo_rst_dat_i           => servo_rst_dat(0),
      servo_rst_addr_o          => servo_rst_addr_ch0,
      ramp_step_size_i          => ramp_step_size,
      ramp_amp_i                => ramp_amp,
      const_val_i               => const_val_ch0,
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
      sa_bias_dat_rdy_i         => sa_bias_dat_rdy(0),
      offset_dat_i              => offset_dat_ch0,
      offset_dat_rdy_i          => offset_dat_rdy(0),
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
      i_clamp_val_i             => i_clamp_val,
      qterm_decay_bits_i        => qterm_decay_bits,
      
      --  fsfb_corr interface
      fsfb_ctrl_lock_en_o       => fsfb_ctrl_lock_en0,   
      flux_quanta_o             => flux_quanta0,   
      fsfb_ctrl_dat_o           => fsfb_ctrl_dat0,   
      fsfb_ctrl_dat_rdy_o       => fsfb_ctrl_dat0_rdy,      
      fj_count_o                => fj_count0,   
      fj_count_rdy_i            => fj_count_rdy,   
      fj_count_i                => fj_count0_new,   
      fsfb_ctrl_dat_rdy_i       => fsfb_ctrl_corr_rdy,   
      fsfb_ctrl_dat_i           => fsfb_ctrl_corr0         
   );

   
   i_flux_loop_ctrl_ch1 : flux_loop_ctrl
   generic map (ADC_LATENCY => ADC_LATENCY)
   port map (
      adc_dat_i                 => adc_dat_ch1_i,
      clk_50_i                  => clk_50_i,
      clk_25_i                  => clk_25_i,
      rst_i                     => rst_i,
      adc_coadd_en_i            => adc_coadd_en_i,
      restart_frame_1row_prev_i => restart_frame_1row_prev_i,
      restart_frame_aligned_i   => restart_frame_aligned_i,
      restart_frame_1row_post_i => restart_frame_1row_post_i,
      row_switch_i              => row_switch_i,
      initialize_window_i       => initialize_window_i,
      servo_rst_window_i        => servo_rst_window_i,
      fltr_rst_i                => fltr_rst_i,
      num_rows_sub1_i           => (others =>'0'),                      -- not used
      dac_dat_en_i              => dac_dat_en_i,
      coadded_addr_i            => coadded_addr_ch1,
      coadded_dat_o             => coadded_dat_ch1,
      fsfb_addr_i               => fsfb_addr_ch1,
      fsfb_dat_o                => fsfb_dat_ch1,
      flux_cnt_ws_dat_o         => flux_cnt_ws_dat_ch1,
      filtered_addr_i           => filtered_addr_ch1,
      filtered_dat_o            => filtered_dat_ch1,
      adc_offset_dat_i          => adc_offset_dat_ch1,
      adc_offset_adr_o          => adc_offset_addr_ch1,
      servo_mode_i              => servo_mode_ch1,
      servo_rst_dat_i           => servo_rst_dat(1),
      servo_rst_addr_o          => servo_rst_addr_ch1,
      ramp_step_size_i          => ramp_step_size,
      ramp_amp_i                => ramp_amp,
      const_val_i               => const_val_ch1,
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
      sa_bias_dat_rdy_i         => sa_bias_dat_rdy(1),
      offset_dat_i              => offset_dat_ch1,
      offset_dat_rdy_i          => offset_dat_rdy(1),
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
      i_clamp_val_i             => i_clamp_val,
      qterm_decay_bits_i        => qterm_decay_bits,
      
      --  fsfb_corr interface
      fsfb_ctrl_lock_en_o       => fsfb_ctrl_lock_en1,   
      flux_quanta_o             => flux_quanta1,   
      fsfb_ctrl_dat_o           => fsfb_ctrl_dat1,   
      fsfb_ctrl_dat_rdy_o       => fsfb_ctrl_dat1_rdy,      
      fj_count_o                => fj_count1,   
      fj_count_rdy_i            => fj_count_rdy,   
      fj_count_i                => fj_count1_new,   
      fsfb_ctrl_dat_rdy_i       => fsfb_ctrl_corr_rdy,   
      fsfb_ctrl_dat_i           => fsfb_ctrl_corr1         
   );


   i_flux_loop_ctrl_ch2 : flux_loop_ctrl
   generic map (ADC_LATENCY => ADC_LATENCY)
   port map (
      adc_dat_i                 => adc_dat_ch2_i,
      clk_50_i                  => clk_50_i,
      clk_25_i                  => clk_25_i,
      rst_i                     => rst_i,
      adc_coadd_en_i            => adc_coadd_en_i,
      restart_frame_1row_prev_i => restart_frame_1row_prev_i,
      restart_frame_aligned_i   => restart_frame_aligned_i,
      restart_frame_1row_post_i => restart_frame_1row_post_i,
      row_switch_i              => row_switch_i,
      initialize_window_i       => initialize_window_i,
      servo_rst_window_i        => servo_rst_window_i,
      fltr_rst_i                => fltr_rst_i,
      num_rows_sub1_i           => (others =>'0'),                      -- not used
      dac_dat_en_i              => dac_dat_en_i,
      coadded_addr_i            => coadded_addr_ch2,
      coadded_dat_o             => coadded_dat_ch2,
      fsfb_addr_i               => fsfb_addr_ch2,
      fsfb_dat_o                => fsfb_dat_ch2,
      flux_cnt_ws_dat_o         => flux_cnt_ws_dat_ch2,
      filtered_addr_i           => filtered_addr_ch2,
      filtered_dat_o            => filtered_dat_ch2,
      adc_offset_dat_i          => adc_offset_dat_ch2,
      adc_offset_adr_o          => adc_offset_addr_ch2,
      servo_mode_i              => servo_mode_ch2,
      servo_rst_dat_i           => servo_rst_dat(2),
      servo_rst_addr_o          => servo_rst_addr_ch2,
      ramp_step_size_i          => ramp_step_size,
      ramp_amp_i                => ramp_amp,
      const_val_i               => const_val_ch2,
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
      sa_bias_dat_rdy_i         => sa_bias_dat_rdy(2),
      offset_dat_i              => offset_dat_ch2,
      offset_dat_rdy_i          => offset_dat_rdy(2),
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
      i_clamp_val_i             => i_clamp_val,
      qterm_decay_bits_i        => qterm_decay_bits,
      
      --  fsfb_corr interface
      fsfb_ctrl_lock_en_o       => fsfb_ctrl_lock_en2,   
      flux_quanta_o             => flux_quanta2,   
      fsfb_ctrl_dat_o           => fsfb_ctrl_dat2,   
      fsfb_ctrl_dat_rdy_o       => fsfb_ctrl_dat2_rdy,      
      fj_count_o                => fj_count2,   
      fj_count_rdy_i            => fj_count_rdy,   
      fj_count_i                => fj_count2_new,   
      fsfb_ctrl_dat_rdy_i       => fsfb_ctrl_corr_rdy,   
      fsfb_ctrl_dat_i           => fsfb_ctrl_corr2         
   );

   
   i_flux_loop_ctrl_ch3 : flux_loop_ctrl
   generic map (ADC_LATENCY => ADC_LATENCY)
   port map (
      adc_dat_i                 => adc_dat_ch3_i,
      clk_50_i                  => clk_50_i,
      clk_25_i                  => clk_25_i,
      rst_i                     => rst_i,
      adc_coadd_en_i            => adc_coadd_en_i,
      restart_frame_1row_prev_i => restart_frame_1row_prev_i,
      restart_frame_aligned_i   => restart_frame_aligned_i,
      restart_frame_1row_post_i => restart_frame_1row_post_i,
      row_switch_i              => row_switch_i,
      initialize_window_i       => initialize_window_i,
      servo_rst_window_i        => servo_rst_window_i,
      fltr_rst_i                => fltr_rst_i,
      num_rows_sub1_i           => (others =>'0'),                      -- not used
      dac_dat_en_i              => dac_dat_en_i,
      coadded_addr_i            => coadded_addr_ch3,
      coadded_dat_o             => coadded_dat_ch3,
      fsfb_addr_i               => fsfb_addr_ch3,
      fsfb_dat_o                => fsfb_dat_ch3,
      flux_cnt_ws_dat_o         => flux_cnt_ws_dat_ch3,
      filtered_addr_i           => filtered_addr_ch3,
      filtered_dat_o            => filtered_dat_ch3,
      adc_offset_dat_i          => adc_offset_dat_ch3,
      adc_offset_adr_o          => adc_offset_addr_ch3,
      servo_mode_i              => servo_mode_ch3,
      servo_rst_dat_i           => servo_rst_dat(3),
      servo_rst_addr_o          => servo_rst_addr_ch3,
      ramp_step_size_i          => ramp_step_size,
      ramp_amp_i                => ramp_amp,
      const_val_i               => const_val_ch3,
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
      sa_bias_dat_rdy_i         => sa_bias_dat_rdy(3),
      offset_dat_i              => offset_dat_ch3,
      offset_dat_rdy_i          => offset_dat_rdy(3),
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
      i_clamp_val_i             => i_clamp_val,
      qterm_decay_bits_i        => qterm_decay_bits,
      
      --  fsfb_corr interface
      fsfb_ctrl_lock_en_o       => fsfb_ctrl_lock_en3,   
      flux_quanta_o             => flux_quanta3,   
      fsfb_ctrl_dat_o           => fsfb_ctrl_dat3,   
      fsfb_ctrl_dat_rdy_o       => fsfb_ctrl_dat3_rdy,      
      fj_count_o                => fj_count3,   
      fj_count_rdy_i            => fj_count_rdy,   
      fj_count_i                => fj_count3_new,   
      fsfb_ctrl_dat_rdy_i       => fsfb_ctrl_corr_rdy,   
      fsfb_ctrl_dat_i           => fsfb_ctrl_corr3         
   );

   
   i_flux_loop_ctrl_ch4 : flux_loop_ctrl
   generic map (ADC_LATENCY => ADC_LATENCY)
   port map (
      adc_dat_i                 => adc_dat_ch4_i,
      clk_50_i                  => clk_50_i,
      clk_25_i                  => clk_25_i,
      rst_i                     => rst_i,
      adc_coadd_en_i            => adc_coadd_en_i,
      restart_frame_1row_prev_i => restart_frame_1row_prev_i,
      restart_frame_aligned_i   => restart_frame_aligned_i,
      restart_frame_1row_post_i => restart_frame_1row_post_i,
      row_switch_i              => row_switch_i,
      initialize_window_i       => initialize_window_i,
      servo_rst_window_i        => servo_rst_window_i,
      fltr_rst_i                => fltr_rst_i,
      num_rows_sub1_i           => (others =>'0'),                      -- not used
      dac_dat_en_i              => dac_dat_en_i,
      coadded_addr_i            => coadded_addr_ch4,
      coadded_dat_o             => coadded_dat_ch4,
      fsfb_addr_i               => fsfb_addr_ch4,
      fsfb_dat_o                => fsfb_dat_ch4,
      flux_cnt_ws_dat_o         => flux_cnt_ws_dat_ch4,
      filtered_addr_i           => filtered_addr_ch4,
      filtered_dat_o            => filtered_dat_ch4,
      adc_offset_dat_i          => adc_offset_dat_ch4,
      adc_offset_adr_o          => adc_offset_addr_ch4,
      servo_mode_i              => servo_mode_ch4,
      servo_rst_dat_i           => servo_rst_dat(4),
      servo_rst_addr_o          => servo_rst_addr_ch4,
      ramp_step_size_i          => ramp_step_size,
      ramp_amp_i                => ramp_amp,
      const_val_i               => const_val_ch4,
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
      sa_bias_dat_rdy_i         => sa_bias_dat_rdy(4),
      offset_dat_i              => offset_dat_ch4,
      offset_dat_rdy_i          => offset_dat_rdy(4),
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
      i_clamp_val_i             => i_clamp_val,
      qterm_decay_bits_i        => qterm_decay_bits,
      
      --  fsfb_corr interface
      fsfb_ctrl_lock_en_o       => fsfb_ctrl_lock_en4,   
      flux_quanta_o             => flux_quanta4,   
      fsfb_ctrl_dat_o           => fsfb_ctrl_dat4,   
      fsfb_ctrl_dat_rdy_o       => fsfb_ctrl_dat4_rdy,      
      fj_count_o                => fj_count4,   
      fj_count_rdy_i            => fj_count_rdy,   
      fj_count_i                => fj_count4_new,   
      fsfb_ctrl_dat_rdy_i       => fsfb_ctrl_corr_rdy,   
      fsfb_ctrl_dat_i           => fsfb_ctrl_corr4         
   );

   
   i_flux_loop_ctrl_ch5 : flux_loop_ctrl
   generic map (ADC_LATENCY => ADC_LATENCY)
   port map (
      adc_dat_i                 => adc_dat_ch5_i,
      clk_50_i                  => clk_50_i,
      clk_25_i                  => clk_25_i,
      rst_i                     => rst_i,
      adc_coadd_en_i            => adc_coadd_en_i,
      restart_frame_1row_prev_i => restart_frame_1row_prev_i,
      restart_frame_aligned_i   => restart_frame_aligned_i,
      restart_frame_1row_post_i => restart_frame_1row_post_i,
      row_switch_i              => row_switch_i,
      initialize_window_i       => initialize_window_i,
      servo_rst_window_i        => servo_rst_window_i,
      fltr_rst_i                => fltr_rst_i,
      num_rows_sub1_i           => (others =>'0'),                      -- not used
      dac_dat_en_i              => dac_dat_en_i,
      coadded_addr_i            => coadded_addr_ch5,
      coadded_dat_o             => coadded_dat_ch5,
      fsfb_addr_i               => fsfb_addr_ch5,
      fsfb_dat_o                => fsfb_dat_ch5,
      flux_cnt_ws_dat_o         => flux_cnt_ws_dat_ch5,
      filtered_addr_i           => filtered_addr_ch5,
      filtered_dat_o            => filtered_dat_ch5,
      adc_offset_dat_i          => adc_offset_dat_ch5,
      adc_offset_adr_o          => adc_offset_addr_ch5,
      servo_mode_i              => servo_mode_ch5,
      servo_rst_dat_i           => servo_rst_dat(5),
      servo_rst_addr_o          => servo_rst_addr_ch5,
      ramp_step_size_i          => ramp_step_size,
      ramp_amp_i                => ramp_amp,
      const_val_i               => const_val_ch5,
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
      sa_bias_dat_rdy_i         => sa_bias_dat_rdy(5),
      offset_dat_i              => offset_dat_ch5,
      offset_dat_rdy_i          => offset_dat_rdy(5),
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
      i_clamp_val_i             => i_clamp_val,
      qterm_decay_bits_i        => qterm_decay_bits,
      
      --  fsfb_corr interface
      fsfb_ctrl_lock_en_o       => fsfb_ctrl_lock_en5,   
      flux_quanta_o             => flux_quanta5,   
      fsfb_ctrl_dat_o           => fsfb_ctrl_dat5,   
      fsfb_ctrl_dat_rdy_o       => fsfb_ctrl_dat5_rdy,      
      fj_count_o                => fj_count5,   
      fj_count_rdy_i            => fj_count_rdy,   
      fj_count_i                => fj_count5_new,   
      fsfb_ctrl_dat_rdy_i       => fsfb_ctrl_corr_rdy,   
      fsfb_ctrl_dat_i           => fsfb_ctrl_corr5         
   );

   
   i_flux_loop_ctrl_ch6 : flux_loop_ctrl
   generic map (ADC_LATENCY => ADC_LATENCY)
   port map (
      adc_dat_i                 => adc_dat_ch6_i,
      clk_50_i                  => clk_50_i,
      clk_25_i                  => clk_25_i,
      rst_i                     => rst_i,
      adc_coadd_en_i            => adc_coadd_en_i,
      restart_frame_1row_prev_i => restart_frame_1row_prev_i,
      restart_frame_aligned_i   => restart_frame_aligned_i,
      restart_frame_1row_post_i => restart_frame_1row_post_i,
      row_switch_i              => row_switch_i,
      initialize_window_i       => initialize_window_i,
      servo_rst_window_i        => servo_rst_window_i,
      fltr_rst_i                => fltr_rst_i,
      num_rows_sub1_i           => (others =>'0'),                      -- not used
      dac_dat_en_i              => dac_dat_en_i,
      coadded_addr_i            => coadded_addr_ch6,
      coadded_dat_o             => coadded_dat_ch6,
      fsfb_addr_i               => fsfb_addr_ch6,
      fsfb_dat_o                => fsfb_dat_ch6,
      flux_cnt_ws_dat_o         => flux_cnt_ws_dat_ch6,
      filtered_addr_i           => filtered_addr_ch6,
      filtered_dat_o            => filtered_dat_ch6,
      adc_offset_dat_i          => adc_offset_dat_ch6,
      adc_offset_adr_o          => adc_offset_addr_ch6,
      servo_mode_i              => servo_mode_ch6,
      servo_rst_dat_i           => servo_rst_dat(6),
      servo_rst_addr_o          => servo_rst_addr_ch6,
      ramp_step_size_i          => ramp_step_size,
      ramp_amp_i                => ramp_amp,
      const_val_i               => const_val_ch6,
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
      sa_bias_dat_rdy_i         => sa_bias_dat_rdy(6),
      offset_dat_i              => offset_dat_ch6,
      offset_dat_rdy_i          => offset_dat_rdy(6),
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
      i_clamp_val_i             => i_clamp_val,
      qterm_decay_bits_i        => qterm_decay_bits,
      
      --  fsfb_corr interface
      fsfb_ctrl_lock_en_o       => fsfb_ctrl_lock_en6,   
      flux_quanta_o             => flux_quanta6,   
      fsfb_ctrl_dat_o           => fsfb_ctrl_dat6,   
      fsfb_ctrl_dat_rdy_o       => fsfb_ctrl_dat6_rdy,      
      fj_count_o                => fj_count6,   
      fj_count_rdy_i            => fj_count_rdy,   
      fj_count_i                => fj_count6_new,   
      fsfb_ctrl_dat_rdy_i       => fsfb_ctrl_corr_rdy,   
      fsfb_ctrl_dat_i           => fsfb_ctrl_corr6         
   );

   
   i_flux_loop_ctrl_ch7 : flux_loop_ctrl
   generic map (ADC_LATENCY => ADC_LATENCY)
   port map (
      adc_dat_i                 => adc_dat_ch7_i,
      clk_50_i                  => clk_50_i,
      clk_25_i                  => clk_25_i,
      rst_i                     => rst_i,
      adc_coadd_en_i            => adc_coadd_en_i,
      restart_frame_1row_prev_i => restart_frame_1row_prev_i,
      restart_frame_aligned_i   => restart_frame_aligned_i,
      restart_frame_1row_post_i => restart_frame_1row_post_i,
      row_switch_i              => row_switch_i,
      initialize_window_i       => initialize_window_i,
      servo_rst_window_i        => servo_rst_window_i,
      fltr_rst_i                => fltr_rst_i,
      num_rows_sub1_i           => (others =>'0'),                      -- not used
      dac_dat_en_i              => dac_dat_en_i,
      coadded_addr_i            => coadded_addr_ch7,
      coadded_dat_o             => coadded_dat_ch7,
      fsfb_addr_i               => fsfb_addr_ch7,
      fsfb_dat_o                => fsfb_dat_ch7,
      flux_cnt_ws_dat_o         => flux_cnt_ws_dat_ch7,
      filtered_addr_i           => filtered_addr_ch7,
      filtered_dat_o            => filtered_dat_ch7,
      adc_offset_dat_i          => adc_offset_dat_ch7,
      adc_offset_adr_o          => adc_offset_addr_ch7,
      servo_mode_i              => servo_mode_ch7,
      servo_rst_dat_i           => servo_rst_dat(7),
      servo_rst_addr_o          => servo_rst_addr_ch7,
      ramp_step_size_i          => ramp_step_size,
      ramp_amp_i                => ramp_amp,
      const_val_i               => const_val_ch7,
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
      sa_bias_dat_rdy_i         => sa_bias_dat_rdy(7),
      offset_dat_i              => offset_dat_ch7,
      offset_dat_rdy_i          => offset_dat_rdy(7),
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
      i_clamp_val_i             => i_clamp_val,
      qterm_decay_bits_i        => qterm_decay_bits,
      
      --  fsfb_corr interface
      fsfb_ctrl_lock_en_o       => fsfb_ctrl_lock_en7,   
      flux_quanta_o             => flux_quanta7,   
      fsfb_ctrl_dat_o           => fsfb_ctrl_dat7,   
      fsfb_ctrl_dat_rdy_o       => fsfb_ctrl_dat7_rdy,      
      fj_count_o                => fj_count7,   
      fj_count_rdy_i            => fj_count_rdy,   
      fj_count_i                => fj_count7_new,   
      fsfb_ctrl_dat_rdy_i       => fsfb_ctrl_corr_rdy,   
      fsfb_ctrl_dat_i           => fsfb_ctrl_corr7         
   );


   -----------------------------------------------------------------------------
   -- Instantiation of fsfb_corr
   -----------------------------------------------------------------------------
   i_fsfb_corr: fsfb_corr
   port map (
      -- fsfb_calc interface
      flux_jump_en_i       => flux_jumping_en,
      initialize_window_i  => initialize_window_i,
      servo_rst_window_i   => servo_rst_window_i,

      servo_rst_dat_i      => servo_rst_dat2,
      servo_en0_i          => fsfb_ctrl_lock_en0,
      servo_en1_i          => fsfb_ctrl_lock_en1,
      servo_en2_i          => fsfb_ctrl_lock_en2,
      servo_en3_i          => fsfb_ctrl_lock_en3,
      servo_en4_i          => fsfb_ctrl_lock_en4,
      servo_en5_i          => fsfb_ctrl_lock_en5,
      servo_en6_i          => fsfb_ctrl_lock_en6,
      servo_en7_i          => fsfb_ctrl_lock_en7,
      
      flux_quanta0_i       => flux_quanta0,
      flux_quanta1_i       => flux_quanta1,
      flux_quanta2_i       => flux_quanta2,
      flux_quanta3_i       => flux_quanta3,
      flux_quanta4_i       => flux_quanta4,
      flux_quanta5_i       => flux_quanta5,
      flux_quanta6_i       => flux_quanta6,
      flux_quanta7_i       => flux_quanta7,
      
      fj_count0_i          => fj_count0,
      fj_count1_i          => fj_count1,
      fj_count2_i          => fj_count2,
      fj_count3_i          => fj_count3,
      fj_count4_i          => fj_count4,
      fj_count5_i          => fj_count5,
      fj_count6_i          => fj_count6,
      fj_count7_i          => fj_count7,
      
      fsfb_ctrl_dat0_i     => fsfb_ctrl_dat0,
      fsfb_ctrl_dat1_i     => fsfb_ctrl_dat1,
      fsfb_ctrl_dat2_i     => fsfb_ctrl_dat2,
      fsfb_ctrl_dat3_i     => fsfb_ctrl_dat3,
      fsfb_ctrl_dat4_i     => fsfb_ctrl_dat4,
      fsfb_ctrl_dat5_i     => fsfb_ctrl_dat5,
      fsfb_ctrl_dat6_i     => fsfb_ctrl_dat6,
      fsfb_ctrl_dat7_i     => fsfb_ctrl_dat7,
      
      fsfb_ctrl_dat_rdy0_i => fsfb_ctrl_dat0_rdy,
      --fsfb_ctrl_dat_rdy1_i       => open,--fsfb_ctrl_dat1_rdy,
      --fsfb_ctrl_dat_rdy2_i       => open,--fsfb_ctrl_dat2_rdy,
      --fsfb_ctrl_dat_rdy3_i       => open,--fsfb_ctrl_dat3_rdy,
      --fsfb_ctrl_dat_rdy4_i       => open,--fsfb_ctrl_dat4_rdy,
      --fsfb_ctrl_dat_rdy5_i       => open,--fsfb_ctrl_dat5_rdy,
      --fsfb_ctrl_dat_rdy6_i       => open,--fsfb_ctrl_dat6_rdy,
      --fsfb_ctrl_dat_rdy7_i       => open,--fsfb_ctrl_dat7_rdy,
      
      fj_count0_o          => fj_count0_new,
      fj_count1_o          => fj_count1_new,
      fj_count2_o          => fj_count2_new,
      fj_count3_o          => fj_count3_new,
      fj_count4_o          => fj_count4_new,
      fj_count5_o          => fj_count5_new,
      fj_count6_o          => fj_count6_new,
      fj_count7_o          => fj_count7_new,
      
      fj_count_rdy_o       => fj_count_rdy,
      
      -- fsfb_ctrl interface
      fsfb_ctrl_dat0_o     => fsfb_ctrl_corr0,
      fsfb_ctrl_dat1_o     => fsfb_ctrl_corr1,
      fsfb_ctrl_dat2_o     => fsfb_ctrl_corr2,
      fsfb_ctrl_dat3_o     => fsfb_ctrl_corr3,
      fsfb_ctrl_dat4_o     => fsfb_ctrl_corr4,
      fsfb_ctrl_dat5_o     => fsfb_ctrl_corr5,
      fsfb_ctrl_dat6_o     => fsfb_ctrl_corr6,
      fsfb_ctrl_dat7_o     => fsfb_ctrl_corr7,
      fsfb_ctrl_dat_rdy_o  => fsfb_ctrl_corr_rdy,
      
      -- Global Signals      
      clk_i                => clk_50_i,
      rst_i                => rst_i
   );


   -----------------------------------------------------------------------------
   -- Instantiation of wbs_frame_data
   -----------------------------------------------------------------------------
   i_wbs_frame_data: wbs_frame_data
   port map (
      rst_i               => rst_i,
      clk_i               => clk_50_i,
      num_rows_i          => num_rows_i,
      num_rows_reported_i => num_rows_reported_i,
      num_cols_reported_i => num_cols_reported_i,
      data_size_i         => data_size_i,
      raw_addr_o          => raw_rd_addr,       
      raw_dat_i           => raw_dat,     
      raw_req_o           => raw_dat_req,     
      raw_ack_i           => raw_dat_ack,     
      readout_col_index_o => raw_chan,
      restart_frame_aligned_i => restart_frame_aligned_i,
      restart_frame_1row_post_i => restart_frame_1row_post_i,        
      filtered_addr_ch0_o => filtered_addr_ch0,
      filtered_dat_ch0_i  => filtered_dat_ch0,
      fsfb_addr_ch0_o     => fsfb_addr_ch0,
      fsfb_dat_ch0_i      => fsfb_dat_ch0,
      flux_cnt_dat_ch0_i  => flux_cnt_ws_dat_ch0,
      coadded_addr_ch0_o  => coadded_addr_ch0,
      coadded_dat_ch0_i   => coadded_dat_ch0,
      filtered_addr_ch1_o => filtered_addr_ch1,
      filtered_dat_ch1_i  => filtered_dat_ch1,
      fsfb_addr_ch1_o     => fsfb_addr_ch1,
      fsfb_dat_ch1_i      => fsfb_dat_ch1,
      flux_cnt_dat_ch1_i  => flux_cnt_ws_dat_ch1,
      coadded_addr_ch1_o  => coadded_addr_ch1,
      coadded_dat_ch1_i   => coadded_dat_ch1,
      filtered_addr_ch2_o => filtered_addr_ch2,
      filtered_dat_ch2_i  => filtered_dat_ch2,
      fsfb_addr_ch2_o     => fsfb_addr_ch2,
      fsfb_dat_ch2_i      => fsfb_dat_ch2,
      flux_cnt_dat_ch2_i  => flux_cnt_ws_dat_ch2,
      coadded_addr_ch2_o  => coadded_addr_ch2,
      coadded_dat_ch2_i   => coadded_dat_ch2,
      filtered_addr_ch3_o => filtered_addr_ch3,
      filtered_dat_ch3_i  => filtered_dat_ch3,
      fsfb_addr_ch3_o     => fsfb_addr_ch3,
      fsfb_dat_ch3_i      => fsfb_dat_ch3,
      flux_cnt_dat_ch3_i  => flux_cnt_ws_dat_ch3,
      coadded_addr_ch3_o  => coadded_addr_ch3,
      coadded_dat_ch3_i   => coadded_dat_ch3,
      filtered_addr_ch4_o => filtered_addr_ch4,
      filtered_dat_ch4_i  => filtered_dat_ch4,
      fsfb_addr_ch4_o     => fsfb_addr_ch4,
      fsfb_dat_ch4_i      => fsfb_dat_ch4,
      flux_cnt_dat_ch4_i  => flux_cnt_ws_dat_ch4,
      coadded_addr_ch4_o  => coadded_addr_ch4,
      coadded_dat_ch4_i   => coadded_dat_ch4,
      filtered_addr_ch5_o => filtered_addr_ch5,
      filtered_dat_ch5_i  => filtered_dat_ch5,
      fsfb_addr_ch5_o     => fsfb_addr_ch5,
      fsfb_dat_ch5_i      => fsfb_dat_ch5,
      flux_cnt_dat_ch5_i  => flux_cnt_ws_dat_ch5,
      coadded_addr_ch5_o  => coadded_addr_ch5,
      coadded_dat_ch5_i   => coadded_dat_ch5,
      filtered_addr_ch6_o => filtered_addr_ch6,
      filtered_dat_ch6_i  => filtered_dat_ch6,
      fsfb_addr_ch6_o     => fsfb_addr_ch6,
      fsfb_dat_ch6_i      => fsfb_dat_ch6,
      flux_cnt_dat_ch6_i  => flux_cnt_ws_dat_ch6,
      coadded_addr_ch6_o  => coadded_addr_ch6,
      coadded_dat_ch6_i   => coadded_dat_ch6,
      filtered_addr_ch7_o => filtered_addr_ch7,
      filtered_dat_ch7_i  => filtered_dat_ch7,
      fsfb_addr_ch7_o     => fsfb_addr_ch7,
      fsfb_dat_ch7_i      => fsfb_dat_ch7,
      flux_cnt_dat_ch7_i  => flux_cnt_ws_dat_ch7,
      coadded_addr_ch7_o  => coadded_addr_ch7,
      coadded_dat_ch7_i   => coadded_dat_ch7,
      dat_i               => dat_i,
      addr_i              => addr_i,
      tga_i               => tga_i,
      we_i                => we_i,
      stb_i               => stb_i,
      cyc_i               => cyc_i,
      dat_o               => dat_frame_o,
      ack_o               => ack_frame_o
   );

   -----------------------------------------------------------------------------
   -- Instantiation of wbs_fb_data
   -----------------------------------------------------------------------------

   i_wbs_fb_data: wbs_fb_data
   port map (
      clk_50_i                => clk_50_i,
      rst_i                   => rst_i,
      servo_rst_dat_o         => servo_rst_dat,
      servo_rst_dat2_o        => servo_rst_dat2,
      adc_offset_dat_ch0_o    => adc_offset_dat_ch0,
      adc_offset_addr_ch0_i   => adc_offset_addr_ch0,
      servo_rst_addr_ch0_i    => servo_rst_addr_ch0,      
      servo_rst_addr2_ch0_i   => servo_rst_addr2,      
      p_dat_ch0_o             => p_dat_ch0,
      p_addr_ch0_i            => p_addr_ch0,
      i_dat_ch0_o             => i_dat_ch0,
      i_addr_ch0_i            => i_addr_ch0,
      d_dat_ch0_o             => d_dat_ch0,
      d_addr_ch0_i            => d_addr_ch0,
      flux_quanta_dat_ch0_o   => flux_quanta_dat_ch0,
      flux_quanta_addr_ch0_i  => flux_quanta_addr_ch0,
      sa_bias_ch0_o           => sa_bias_dat_ch0,
      sa_bias_rdy_ch0_o       => sa_bias_dat_rdy(0),
      offset_dat_ch0_o        => offset_dat_ch0,
      offset_dat_rdy_ch0_o    => offset_dat_rdy(0),
      const_val_ch0_o         => const_val_ch0,
      servo_mode_ch0_o        => servo_mode_ch0,
      adc_offset_dat_ch1_o    => adc_offset_dat_ch1,
      adc_offset_addr_ch1_i   => adc_offset_addr_ch1,
      servo_rst_addr_ch1_i    => servo_rst_addr_ch1,      
      servo_rst_addr2_ch1_i   => servo_rst_addr2,      
      p_dat_ch1_o             => p_dat_ch1,
      p_addr_ch1_i            => p_addr_ch1,
      i_dat_ch1_o             => i_dat_ch1,
      i_addr_ch1_i            => i_addr_ch1,
      d_dat_ch1_o             => d_dat_ch1,
      d_addr_ch1_i            => d_addr_ch1,
      flux_quanta_dat_ch1_o   => flux_quanta_dat_ch1,
      flux_quanta_addr_ch1_i  => flux_quanta_addr_ch1,
      sa_bias_ch1_o           => sa_bias_dat_ch1,
      sa_bias_rdy_ch1_o       => sa_bias_dat_rdy(1),
      offset_dat_ch1_o        => offset_dat_ch1,
      offset_dat_rdy_ch1_o    => offset_dat_rdy(1),
      const_val_ch1_o         => const_val_ch1,
      servo_mode_ch1_o        => servo_mode_ch1,
      adc_offset_dat_ch2_o    => adc_offset_dat_ch2,
      adc_offset_addr_ch2_i   => adc_offset_addr_ch2,
      servo_rst_addr_ch2_i    => servo_rst_addr_ch2,      
      servo_rst_addr2_ch2_i    => servo_rst_addr2,            
      p_dat_ch2_o             => p_dat_ch2,
      p_addr_ch2_i            => p_addr_ch2,
      i_dat_ch2_o             => i_dat_ch2,
      i_addr_ch2_i            => i_addr_ch2,
      d_dat_ch2_o             => d_dat_ch2,
      d_addr_ch2_i            => d_addr_ch2,
      flux_quanta_dat_ch2_o   => flux_quanta_dat_ch2,
      flux_quanta_addr_ch2_i  => flux_quanta_addr_ch2,
      sa_bias_ch2_o           => sa_bias_dat_ch2,
      sa_bias_rdy_ch2_o       => sa_bias_dat_rdy(2),
      offset_dat_ch2_o        => offset_dat_ch2,
      offset_dat_rdy_ch2_o    => offset_dat_rdy(2),
      const_val_ch2_o         => const_val_ch2,
      servo_mode_ch2_o        => servo_mode_ch2,
      adc_offset_dat_ch3_o    => adc_offset_dat_ch3,
      adc_offset_addr_ch3_i   => adc_offset_addr_ch3,
      servo_rst_addr_ch3_i    => servo_rst_addr_ch3,      
      servo_rst_addr2_ch3_i   => servo_rst_addr2,      
      p_dat_ch3_o             => p_dat_ch3,
      p_addr_ch3_i            => p_addr_ch3,
      i_dat_ch3_o             => i_dat_ch3,
      i_addr_ch3_i            => i_addr_ch3,
      d_dat_ch3_o             => d_dat_ch3,
      d_addr_ch3_i            => d_addr_ch3,
      flux_quanta_dat_ch3_o   => flux_quanta_dat_ch3,
      flux_quanta_addr_ch3_i  => flux_quanta_addr_ch3,
      sa_bias_ch3_o           => sa_bias_dat_ch3,
      sa_bias_rdy_ch3_o       => sa_bias_dat_rdy(3),
      offset_dat_ch3_o        => offset_dat_ch3,
      offset_dat_rdy_ch3_o    => offset_dat_rdy(3),
      const_val_ch3_o         => const_val_ch3,
      servo_mode_ch3_o        => servo_mode_ch3,
      adc_offset_dat_ch4_o    => adc_offset_dat_ch4,
      adc_offset_addr_ch4_i   => adc_offset_addr_ch4,
      servo_rst_addr_ch4_i    => servo_rst_addr_ch4,      
      servo_rst_addr2_ch4_i   => servo_rst_addr2,      
      p_dat_ch4_o             => p_dat_ch4,
      p_addr_ch4_i            => p_addr_ch4,
      i_dat_ch4_o             => i_dat_ch4,
      i_addr_ch4_i            => i_addr_ch4,
      d_dat_ch4_o             => d_dat_ch4,
      d_addr_ch4_i            => d_addr_ch4,
      flux_quanta_dat_ch4_o   => flux_quanta_dat_ch4,
      flux_quanta_addr_ch4_i  => flux_quanta_addr_ch4,
      sa_bias_ch4_o           => sa_bias_dat_ch4,
      sa_bias_rdy_ch4_o       => sa_bias_dat_rdy(4),
      offset_dat_ch4_o        => offset_dat_ch4,
      offset_dat_rdy_ch4_o    => offset_dat_rdy(4),
      const_val_ch4_o         => const_val_ch4,
      servo_mode_ch4_o        => servo_mode_ch4,
      adc_offset_dat_ch5_o    => adc_offset_dat_ch5,
      adc_offset_addr_ch5_i   => adc_offset_addr_ch5,
      servo_rst_addr_ch5_i    => servo_rst_addr_ch5,      
      servo_rst_addr2_ch5_i   => servo_rst_addr2,      
      p_dat_ch5_o             => p_dat_ch5,
      p_addr_ch5_i            => p_addr_ch5,
      i_dat_ch5_o             => i_dat_ch5,
      i_addr_ch5_i            => i_addr_ch5,
      d_dat_ch5_o             => d_dat_ch5,
      d_addr_ch5_i            => d_addr_ch5,
      flux_quanta_dat_ch5_o   => flux_quanta_dat_ch5,
      flux_quanta_addr_ch5_i  => flux_quanta_addr_ch5,
      sa_bias_ch5_o           => sa_bias_dat_ch5,
      sa_bias_rdy_ch5_o       => sa_bias_dat_rdy(5),
      offset_dat_ch5_o        => offset_dat_ch5,
      offset_dat_rdy_ch5_o    => offset_dat_rdy(5),
      const_val_ch5_o         => const_val_ch5,
      servo_mode_ch5_o        => servo_mode_ch5,
      adc_offset_dat_ch6_o    => adc_offset_dat_ch6,
      adc_offset_addr_ch6_i   => adc_offset_addr_ch6,
      servo_rst_addr_ch6_i    => servo_rst_addr_ch6,      
      servo_rst_addr2_ch6_i   => servo_rst_addr2,      
      p_dat_ch6_o             => p_dat_ch6,
      p_addr_ch6_i            => p_addr_ch6,
      i_dat_ch6_o             => i_dat_ch6,
      i_addr_ch6_i            => i_addr_ch6,
      d_dat_ch6_o             => d_dat_ch6,
      d_addr_ch6_i            => d_addr_ch6,
      flux_quanta_dat_ch6_o   => flux_quanta_dat_ch6,
      flux_quanta_addr_ch6_i  => flux_quanta_addr_ch6,
      sa_bias_ch6_o           => sa_bias_dat_ch6,
      sa_bias_rdy_ch6_o       => sa_bias_dat_rdy(6),
      offset_dat_ch6_o        => offset_dat_ch6,
      offset_dat_rdy_ch6_o    => offset_dat_rdy(6),
      const_val_ch6_o         => const_val_ch6,
      servo_mode_ch6_o        => servo_mode_ch6,
      adc_offset_dat_ch7_o    => adc_offset_dat_ch7,
      adc_offset_addr_ch7_i   => adc_offset_addr_ch7,
      servo_rst_addr_ch7_i    => servo_rst_addr_ch7,      
      servo_rst_addr2_ch7_i   => servo_rst_addr2,      
      p_dat_ch7_o             => p_dat_ch7,
      p_addr_ch7_i            => p_addr_ch7,
      i_dat_ch7_o             => i_dat_ch7,
      i_addr_ch7_i            => i_addr_ch7,
      d_dat_ch7_o             => d_dat_ch7,
      d_addr_ch7_i            => d_addr_ch7,
      flux_quanta_dat_ch7_o   => flux_quanta_dat_ch7,
      flux_quanta_addr_ch7_i  => flux_quanta_addr_ch7,
      sa_bias_ch7_o           => sa_bias_dat_ch7,
      sa_bias_rdy_ch7_o       => sa_bias_dat_rdy(7),
      offset_dat_ch7_o        => offset_dat_ch7,
      offset_dat_rdy_ch7_o    => offset_dat_rdy(7),
      const_val_ch7_o         => const_val_ch7,
      servo_mode_ch7_o        => servo_mode_ch7,
      filter_coeff0_o         => filter_coeff0,
      filter_coeff1_o         => filter_coeff1,
      filter_coeff2_o         => filter_coeff2,
      filter_coeff3_o         => filter_coeff3,
      filter_coeff4_o         => filter_coeff4,
      filter_coeff5_o         => filter_coeff5,
      filter_coeff6_o         => filter_coeff6,
      ramp_step_size_o        => ramp_step_size,
      ramp_amp_o              => ramp_amp,
      num_ramp_frame_cycles_o => num_ramp_frame_cycles,
      flux_jumping_en_o       => flux_jumping_en,
      i_clamp_val_o           => i_clamp_val,
      qterm_decay_bits_o      => qterm_decay_bits,
      dat_i                   => dat_i,
      addr_i                  => addr_i,
      tga_i                   => tga_i,
      we_i                    => we_i,
      stb_i                   => stb_i,
      cyc_i                   => cyc_i,
      dat_o                   => dat_fb_o,
      ack_o                   => ack_fb_o
   );
  
  
end struct;
