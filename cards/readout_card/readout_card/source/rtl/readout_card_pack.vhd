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
-- Revision 1.20  2011-09-16 23:08:26  mandana
-- fix ADC_latency compensation bug in coadd window (is parameterized now)
--
-- Revision 1.19  2010-11-30 19:51:01  mandana
-- *** empty log message ***
--
-- Revision 1.18  2009/12/10 00:13:36  bburger
-- BB: Added CRC_ERROR entities and test functionality.
--
-- Revision 1.17  2009/10/06 06:03:58  bburger
-- BB: Added a PLL declaration for the adc_clk output
--
-- Revision 1.16  2009/08/21 21:34:12  bburger
-- BB: made changes to rc_pll_stratix_iii (locked) and adc_pll_stratix_iii (areset) interfaces.
--
-- Revision 1.15  2009/07/11 00:12:52  bburger
-- BB:  added adc_serdes_7_bit, adc_pll_stratic_iii_dual_serdes, flipflop_14
--
-- Revision 1.14  2009/06/30 18:30:17  bburger
-- BB:  Removed an unused PLL output (c1) and added and alternate PLL for testing.
--
-- Revision 1.13  2009/05/27 22:38:04  bburger
-- BB: Added data_size_i interface to wishbone entity for rectangle mode data acquisition
--
-- Revision 1.12  2009/05/27 01:31:27  bburger
-- BB: Added constant COL_ADDR_WIDTH
--
-- Revision 1.11  2009/03/19 22:06:34  bburger
-- BB:
-- - Added constants ADC_LATENCY_REVA/C
-- - Added generic ADC_LATENCY to flux_loop interface
-- - Removed unused signals adc_ovr, adc_rdy, adc_clk from flux_loop interface
-- - Added components adc_pll_stratix_iii, adc_serdes, flipflop_56, flipflop_112
--
-- Revision 1.10  2009/01/23 23:49:36  bburger
-- BB:  Adding new files for Readout Card rev. C.  Also regenerated the following RAM blocks for the new revision:  pid_ram, ram_14x64, wbs_fb_storage.
--
--
------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

--library stratixiii;
--use stratixiii.all;

-- System Library
library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;

package readout_card_pack is
 
   -----------------------------------------------------------------------------
   -- Constants 
   -----------------------------------------------------------------------------
   constant ADC_LATENCY_REVA       : integer := 4;  
   constant ADC_LATENCY_REVC       : integer := 11;  

   constant ROW_ADDR_WIDTH         : integer := 6;
   constant COL_ADDR_WIDTH         : integer := 3;
   constant NUM_COLS               : integer range 0 to (2**COL_ADDR_WIDTH) := 2**COL_ADDR_WIDTH;
  
   constant FSFB_QUEUE_ADDR_WIDTH  : integer := ROW_ADDR_WIDTH;       -- address width of first stage feedback queue 

   constant ADC_DAT_WIDTH          : integer := 14;
   constant DAC_DAT_WIDTH          : integer := 14;
   constant DAC_INIT_VAL           : integer := -8192;
   constant SA_BIAS_SPI_DATA_WIDTH : integer := 3;         -- data width of SPI interface 
   constant OFFSET_SPI_DATA_WIDTH  : integer := 3;         -- data width of SPI interface 


   component stratixiii_crcblock
      generic (
         crc_deld_disable  :  string := "off";
         error_delay :  natural := 0;
         error_dra_dl_bypass  :  string := "off";
         --lpm_hint :  string := "UNUSED";
         lpm_type :  string := "stratixiii_crcblock";
         oscillator_divider   :  natural := 2);
      port(
         clk   :  in std_logic := '0';
--         -- This signal is noted as required in an357, but is not present in any library interfaces except stratixiii_components.vhd
--         ldsrc :  in std_logic := '0';
         crcerror :  out std_logic;
         regout   :  out std_logic;
         shiftnld :  in std_logic := '0'
      );
   end component;   
   
   component d_flipflop IS
      PORT
      (
         clock    : IN STD_LOGIC ;
         data     : IN STD_LOGIC ;
         q     : OUT STD_LOGIC 
      );
   END component;
   
   -----------------------------------------------------------------------------
   -- Flux Loop Component
   -----------------------------------------------------------------------------
   component flux_loop
   generic (ADC_LATENCY         : integer := ADC_LATENCY_REVA);
   port (
      clk_50_i                  : in  std_logic;
      clk_25_i                  : in  std_logic;
      rst_i                     : in  std_logic;
      num_rows_i                : in  integer;
      num_rows_reported_i       : in integer;
      num_cols_reported_i       : in integer;
      data_size_i               : in std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);
      adc_coadd_en_i            : in  std_logic;
      restart_frame_1row_prev_i : in  std_logic;
      restart_frame_aligned_i   : in  std_logic;
      restart_frame_1row_post_i : in  std_logic;
      row_switch_i              : in  std_logic;
      initialize_window_i       : in  std_logic;
      servo_rst_window_i        : in  std_logic;
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

      -- For Readout Card Rev. A/AA/B
      adc_dat_ch0_i             : in  std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
      adc_dat_ch1_i             : in  std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
      adc_dat_ch2_i             : in  std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
      adc_dat_ch3_i             : in  std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
      adc_dat_ch4_i             : in  std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
      adc_dat_ch5_i             : in  std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
      adc_dat_ch6_i             : in  std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
      adc_dat_ch7_i             : in  std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
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
   end component;

   -----------------------------------------------------------------------------
   -- PLL Components
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

   component rc_pll_stratix_iii
   port (
      inclk0 : IN  STD_LOGIC := '0';
      c0     : OUT STD_LOGIC;
--      c1     : OUT STD_LOGIC;
      c2     : OUT STD_LOGIC;
      c3     : OUT STD_LOGIC;
      c4     : OUT STD_LOGIC;
      c5     : OUT STD_LOGIC;
      locked : OUT STD_LOGIC);
   end component;

   component adc_clk_pll_stratix_iii
   port (
      inclk0      : IN STD_LOGIC  := '0';
      c0          : OUT STD_LOGIC ;
      locked      : OUT STD_LOGIC);
   end component;

   component adc_pll_stratix_iii
   port (
      areset : IN STD_LOGIC ;
      inclk0 : IN STD_LOGIC  := '0';
      c0    : OUT STD_LOGIC ;
      c1    : OUT STD_LOGIC ;
      c2    : OUT STD_LOGIC ;
      c3    : OUT STD_LOGIC ;
      c4    : OUT STD_LOGIC ;
      locked      : OUT STD_LOGIC
   ); 
   end component;

--   component adc_pll_stratix_iii_not_fast
--   port (
--      inclk0 : IN STD_LOGIC  := '0';
--      c0    : OUT STD_LOGIC ;
--      c1    : OUT STD_LOGIC --;
--      --locked      : OUT STD_LOGIC
--   ); 
--   end component;
   
   component adc_pll_stratic_iii_dual_serdes
   port (
      inclk0      : IN STD_LOGIC  := '0';
      c0    : OUT STD_LOGIC ;
      c1    : OUT STD_LOGIC ;
      c2    : OUT STD_LOGIC ;
      c3    : OUT STD_LOGIC ;
      c4    : OUT STD_LOGIC ;
      locked      : OUT STD_LOGIC 
   ); 
   end component;
   
   -----------------------------------------------------------------------------
   -- Stratix 3 ADC SERDES
   -----------------------------------------------------------------------------
   component adc_serdes 
   port (
      rx_enable      : IN STD_LOGIC  := '1';
      rx_in    : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
      rx_inclock     : IN STD_LOGIC  := '0';
      rx_out      : OUT STD_LOGIC_VECTOR (55 DOWNTO 0)
   );
   end component;

   component adc_serdes_7_bit 
   port (
      rx_enable      : IN STD_LOGIC  := '1';
      rx_in    : IN STD_LOGIC_VECTOR (0 DOWNTO 0);
      rx_inclock     : IN STD_LOGIC  := '0';
      rx_out      : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
   );
   end component;

   component flipflop_14
   port (
      clock    : IN STD_LOGIC ;
      data     : IN STD_LOGIC_VECTOR (13 DOWNTO 0);
      q     : OUT STD_LOGIC_VECTOR (13 DOWNTO 0)
   );
   end component;

   component flipflop_56
   port (
      clock    : IN STD_LOGIC ;
      data     : IN STD_LOGIC_VECTOR (55 DOWNTO 0);
      q     : OUT STD_LOGIC_VECTOR (55 DOWNTO 0)
   );
   end component;

   component flipflop_112
   port (
      clock    : IN STD_LOGIC ;
      data     : IN STD_LOGIC_VECTOR (111 DOWNTO 0);
      q     : OUT STD_LOGIC_VECTOR (111 DOWNTO 0)
   );
   end component;

   -----------------------------------------------------------------------------
   -- DDR2 Controller Component
   -----------------------------------------------------------------------------
   component micron_ctrl
   PORT (
      local_address  : IN STD_LOGIC_VECTOR (22 DOWNTO 0);
      local_write_req   : IN STD_LOGIC;
      local_read_req : IN STD_LOGIC;
      local_burstbegin  : IN STD_LOGIC;
      local_wdata : IN STD_LOGIC_VECTOR (63 DOWNTO 0);
      local_be : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
      local_size  : IN STD_LOGIC;
      oct_ctl_rs_value  : IN STD_LOGIC_VECTOR (13 DOWNTO 0);
      oct_ctl_rt_value  : IN STD_LOGIC_VECTOR (13 DOWNTO 0);
      global_reset_n : IN STD_LOGIC;
      pll_ref_clk : IN STD_LOGIC;
      soft_reset_n   : IN STD_LOGIC;
      local_ready : OUT STD_LOGIC;
      local_rdata : OUT STD_LOGIC_VECTOR (63 DOWNTO 0);
      local_rdata_valid : OUT STD_LOGIC;
      reset_request_n   : OUT STD_LOGIC;
      mem_odt  : OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
      mem_cs_n : OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
      mem_cke  : OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
      mem_addr : OUT STD_LOGIC_VECTOR (12 DOWNTO 0);
      mem_ba   : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
      mem_ras_n   : OUT STD_LOGIC;
      mem_cas_n   : OUT STD_LOGIC;
      mem_we_n : OUT STD_LOGIC;
      mem_dm   : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
      local_refresh_ack : OUT STD_LOGIC;
      local_wdata_req   : OUT STD_LOGIC;
      local_init_done   : OUT STD_LOGIC;
      reset_phy_clk_n   : OUT STD_LOGIC;
      phy_clk  : OUT STD_LOGIC;
      aux_full_rate_clk : OUT STD_LOGIC;
      aux_half_rate_clk : OUT STD_LOGIC;
      mem_clk  : INOUT STD_LOGIC_VECTOR (0 DOWNTO 0);
      mem_clk_n   : INOUT STD_LOGIC_VECTOR (0 DOWNTO 0);
      mem_dq   : INOUT STD_LOGIC_VECTOR (15 DOWNTO 0);
      mem_dqs  : INOUT STD_LOGIC_VECTOR (1 DOWNTO 0);
      mem_dqsn : INOUT STD_LOGIC_VECTOR (1 DOWNTO 0)
   );
   end component;
   
   -----------------------------------------------------------------------------
   -- DDR2 Controller PLL Component
   -----------------------------------------------------------------------------
   component micron_ctrl_phy_alt_mem_phy_pll
   PORT (
      areset      : IN STD_LOGIC  := '0';
      inclk0      : IN STD_LOGIC  := '0';
      phasecounterselect      : IN STD_LOGIC_VECTOR (3 DOWNTO 0) :=  (OTHERS => '0');
      phasestep      : IN STD_LOGIC  := '0';
      phaseupdown    : IN STD_LOGIC  := '0';
      scanclk     : IN STD_LOGIC  := '1';
      c0    : OUT STD_LOGIC ;
      c1    : OUT STD_LOGIC ;
      c2    : OUT STD_LOGIC ;
      c3    : OUT STD_LOGIC ;
      c4    : OUT STD_LOGIC ;
      c5    : OUT STD_LOGIC ;
      c6    : OUT STD_LOGIC ;
      locked      : OUT STD_LOGIC ;
      phasedone      : OUT STD_LOGIC 
   );
   end component;

   -----------------------------------------------------------------------------
   -- DDR2 Controller Example Driver
   -----------------------------------------------------------------------------
   component micron_ctrl_example_driver is
   PORT (
       signal local_size : OUT STD_LOGIC;
       signal pnf_persist : OUT STD_LOGIC;
       signal local_cs_addr : OUT STD_LOGIC;
       signal local_bank_addr : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
       signal local_read_req : OUT STD_LOGIC;
       signal local_wdata : OUT STD_LOGIC_VECTOR (63 DOWNTO 0);
       signal local_be : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
       signal test_status : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
       signal local_write_req : OUT STD_LOGIC;
       signal local_col_addr : OUT STD_LOGIC_VECTOR (9 DOWNTO 0);
       signal local_row_addr : OUT STD_LOGIC_VECTOR (12 DOWNTO 0);
       signal test_complete : OUT STD_LOGIC;
       signal pnf_per_byte : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
       signal local_rdata_valid : IN STD_LOGIC;
       signal local_rdata : IN STD_LOGIC_VECTOR (63 DOWNTO 0);
       signal clk : IN STD_LOGIC;
       signal reset_n : IN STD_LOGIC;
       signal local_ready : IN STD_LOGIC
   );
   end component micron_ctrl_example_driver;

        
end readout_card_pack;

