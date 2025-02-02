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
-- readout_card.vhd
--
-- Project:       SCUBA-2
-- Author:        David Atkinson
-- Organisation:  ATC
--
-- Description:
-- Readout Card top-level file
--
-- Revision history:
--
-- $Log: readout_card.vhd,v $
-- Revision 1.101  2012-03-26 02:04:09  mandana
-- 5.1.b for RevB cards
-- bugfix: rectangle mode addressing
-- bugfix: integral term is now calculated based on all samples
-- tcl file is now updated to teh correct device of c7 speed grade!
--
-- Revision 1.100  2011-06-02 23:15:41  mandana
-- rev. 5.1.4
-- fixed bug with fsfb_corr when reverting back to applying sq1fb after 7 clk cycles when fj is off
--
-- Revision 1.99  2011-06-02 20:53:39  mandana
-- rev. 5.1.3 reverts back to applying SQ1FB after only 7 clock cycles when flux-jumping is off.
--
-- Revision 1.98  2011-01-21 01:40:19  mandana
-- 5.1.2, bugfix for filtered data being 2 row behind
--
-- Revision 1.97  2010-11-30 19:52:45  mandana
-- rev. 5.1.1 with reduced range for filter_scale_lsb to resolve timing failures
-- restructured pack files
--
-- Revision 1.96  2010-11-13 00:40:35  mandana
-- filter_coeff added
-- revision 5.1.0
-- comments added for more structured revision numbering
--
-- Revision 1.95  2010/10/21 22:05:16  mandana
-- 5.0.f with integral_clamp fixed in dynamic_data_manager
--
-- Revision 1.94  2010/10/07 20:05:25  mandana
-- rev. 5.0.e with clamp bug fix
-- added virtual pcb_rev signals to be compatible with latest all_cards (that has pcb_rev interface to support new hardware)
--
-- Revision 1.93  2010/08/04 21:37:59  bburger
-- BB:  0500000d
--
-- Revision 1.92  2010/06/17 01:07:57  bburger
-- BB: rc_v0500000c
--
-- Revision 1.91  2010/06/03 21:40:23  bburger
-- BB:  rc_v0500000b
--
-- Revision 1.90  2010/04/08 20:41:37  mandana
-- revision 5.0.a with added FLTR_TYPE and I_CLAMP_VAL commands
--
-- Revision 1.89  2010/03/12 20:54:23  bburger
-- BB: re-introduced a generic that had gone missing, and upped the revision to v0500000A
--
-- Revision 1.84.2.3  2009/10/15 20:56:32  mandana
-- fw_rev 5.0.8 has wider input to the filter and sticky bits removed from internal filter calcs.
--
-- Revision 1.84.2.2  2009/10/09 21:24:19  mandana
--  low-pass-filter to f(3db)=75Hz for f(sample)=30000.
-- sticky bit removed in internal filter arithmetic
-- filter-input width increased to 20bits
-- removed correction in fsfb_proc_pidz
-- 5.0.7
--
-- Revision 1.84.2.1  2009/09/04 23:25:17  mandana
-- rev. 5.0.5, added filter coeffs for fs=30000, fc=75Hz and adjusted midstage gains
--
-- Revision 1.88  2009/11/24 23:51:24  bburger
-- BB: Made a top-level modification that does not affect old cards with the MAX1618, but enables the LM95235 on new cards.
--
-- Revision 1.87  2009/08/28 17:51:02  bburger
-- BB: re_v05000004
--
-- Revision 1.86  2009/06/30 18:08:32  bburger
-- BB:  Removed an unused generic
--
-- Revision 1.85  2009/06/18 22:59:40  bburger
-- BB:  Upped the version number for 5.0.2
--
-- Revision 1.84  2009/05/27 22:37:47  bburger
-- BB: Upped the version number and added the data_size interface between dispatch and flux_loop for rectangle data
--
-- Revision 1.83  2009/03/19 22:01:26  bburger
-- BB:
-- - Added the ADC_LATENCY generic to generalize this block for Readout Card Rev. C
-- - Removed unused signals adc_ovr_i, adc_rdy_i, adc_clk_o from interface
-- - Added default TTL outputs
--
-- Revision 1.82  2009/01/23 23:49:36  bburger
-- BB:  Adding new files for Readout Card rev. C.  Also regenerated the following RAM blocks for the new revision:  pid_ram, ram_14x64, wbs_fb_storage.
--
--
-----------------------------------------------------------------------------
-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;

library work;
use work.readout_card_pack.all;
use work.all_cards_pack.all;
use work.adc_sample_coadd_pack.all;

entity readout_card is
generic(
   CARD            : std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0) := READOUT_CARD_1);
port(  
   -- Global Interface
   rst_n           : in std_logic;

   -- PLL Interface
   inclk           : in std_logic;

   -- ADC Interface
   adc1_dat        : in  std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
   adc2_dat        : in  std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
   adc3_dat        : in  std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
   adc4_dat        : in  std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
   adc5_dat        : in  std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
   adc6_dat        : in  std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
   adc7_dat        : in  std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
   adc8_dat        : in  std_logic_vector (ADC_DAT_WIDTH-1 downto 0);
   adc1_ovr        : in  std_logic;
   adc2_ovr        : in  std_logic;
   adc3_ovr        : in  std_logic;
   adc4_ovr        : in  std_logic;
   adc5_ovr        : in  std_logic;
   adc6_ovr        : in  std_logic;
   adc7_ovr        : in  std_logic;
   adc8_ovr        : in  std_logic;
   adc1_rdy        : in  std_logic;
   adc2_rdy        : in  std_logic;
   adc3_rdy        : in  std_logic;
   adc4_rdy        : in  std_logic;
   adc5_rdy        : in  std_logic;
   adc6_rdy        : in  std_logic;
   adc7_rdy        : in  std_logic;
   adc8_rdy        : in  std_logic;
   adc1_clk        : out std_logic;
   adc2_clk        : out std_logic;
   adc3_clk        : out std_logic;
   adc4_clk        : out std_logic;
   adc5_clk        : out std_logic;
   adc6_clk        : out std_logic;
   adc7_clk        : out std_logic;
   adc8_clk        : out std_logic;

   -- DAC Interface
   dac_FB1_dat     : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
   dac_FB2_dat     : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
   dac_FB3_dat     : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
   dac_FB4_dat     : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
   dac_FB5_dat     : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
   dac_FB6_dat     : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
   dac_FB7_dat     : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
   dac_FB8_dat     : out std_logic_vector(DAC_DAT_WIDTH-1 downto 0);
   dac_FB_clk      : out std_logic_vector(7 downto 0);  -- Note number of channels are hard coded

   -- Sa_bias and Offset_ctrl Interface
   dac_clk         : out std_logic_vector(7 downto 0);  -- Note number of channels are hard coded
   dac_dat         : out std_logic_vector(7 downto 0);  -- Note number of channels are hard coded
   bias_dac_ncs    : out std_logic_vector(7 downto 0);  -- Note number of channels are hard coded
   offset_dac_ncs  : out std_logic_vector(7 downto 0);  -- Note number of channels are hard coded

   -- LVDS interface:
   lvds_cmd        : in std_logic;
   lvds_sync       : in std_logic;
   lvds_spare      : in std_logic;
   lvds_txa        : out std_logic;
   lvds_txb        : out std_logic;

   -- TTL interface:
   ttl_dir1        : out std_logic;
   ttl_in1         : in std_logic;
   ttl_out1        : out std_logic;

   ttl_dir2        : out std_logic;
   ttl_in2         : in std_logic;
   ttl_out2        : out std_logic;

   ttl_dir3        : out std_logic;
   ttl_in3         : in std_logic;
   ttl_out3        : out std_logic;

   -- LED Interface
   red_led         : out std_logic;
   ylw_led         : out std_logic;
   grn_led         : out std_logic;

   -- miscellaneous ports
   dip_sw3         : in std_logic;
   dip_sw4         : in std_logic;
   wdog            : out std_logic;

   -- slot_id interface
   slot_id         : in std_logic_vector(3 downto 0);

   -- silicon_id/temperature interface
   card_id         : inout std_logic;

   -- fpga_thermo serial interface
   smb_clk         : out std_logic;
   smb_nalert      : out std_logic;
   smb_data        : inout std_logic;

   -- Debug ports
   mictor          : out std_logic_vector(31 downto 0)
); 
end readout_card;

architecture top of readout_card is

   -- The REVISION format is RRrrBBBB where
   --               RR is the major revision number, incremented when major new features are added and possibly incompatible with previous versions
   --               rr is the minor revision number, incremented when new features added
   --               BBBB is the build number, incremented for bug fixes
   constant RC_REVISION : std_logic_vector (31 downto 0) := X"05020000";

   -- Global signals
   signal clk                     : std_logic;  -- system clk
   signal comm_clk                : std_logic;  -- communication clk
   signal spi_clk                 : std_logic;  -- spi clk
   signal rst                     : std_logic;
   signal clk_n                   : std_logic;

   -- dispatch interface signals
   signal dispatch_dat_out        : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal dispatch_addr_out       : std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
   signal dispatch_tga_out        : std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
   signal dispatch_we_out         : std_logic;
   signal dispatch_stb_out        : std_logic;
   signal dispatch_cyc_out        : std_logic;
   signal dispatch_err_in         : std_logic;
   signal dispatch_lvds_txa       : std_logic;

   -- WBS MUX output siganls
   signal dispatch_dat_in         : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal dispatch_ack_in         : std_logic;

   -- frame_timing output signals
   signal dac_dat_en              : std_logic;
   signal adc_coadd_en            : std_logic;
   signal restart_frame_1row_prev : std_logic;
   signal restart_frame_aligned   : std_logic;
   signal restart_frame_1row_post : std_logic;
   signal initialize_window       : std_logic;
   signal servo_rst_window        : std_logic;
   signal fltr_rst                : std_logic;
   signal row_switch              : std_logic;
   signal dat_ft                  : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal ack_ft                  : std_logic;

   -- flux_loop output signals
   signal dat_frame               : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal dat_fb                  : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal ack_frame               : std_logic;
   signal ack_fb                  : std_logic;
   signal sa_bias_dac_spi_ch0     : std_logic_vector(SA_BIAS_SPI_DATA_WIDTH-1 downto 0);
   signal sa_bias_dac_spi_ch1     : std_logic_vector(SA_BIAS_SPI_DATA_WIDTH-1 downto 0);
   signal sa_bias_dac_spi_ch2     : std_logic_vector(SA_BIAS_SPI_DATA_WIDTH-1 downto 0);
   signal sa_bias_dac_spi_ch3     : std_logic_vector(SA_BIAS_SPI_DATA_WIDTH-1 downto 0);
   signal sa_bias_dac_spi_ch4     : std_logic_vector(SA_BIAS_SPI_DATA_WIDTH-1 downto 0);
   signal sa_bias_dac_spi_ch5     : std_logic_vector(SA_BIAS_SPI_DATA_WIDTH-1 downto 0);
   signal sa_bias_dac_spi_ch6     : std_logic_vector(SA_BIAS_SPI_DATA_WIDTH-1 downto 0);
   signal sa_bias_dac_spi_ch7     : std_logic_vector(SA_BIAS_SPI_DATA_WIDTH-1 downto 0);
   signal offset_dac_spi_ch0      : std_logic_vector(OFFSET_SPI_DATA_WIDTH-1 downto 0);
   signal offset_dac_spi_ch1      : std_logic_vector(OFFSET_SPI_DATA_WIDTH-1 downto 0);
   signal offset_dac_spi_ch2      : std_logic_vector(OFFSET_SPI_DATA_WIDTH-1 downto 0);
   signal offset_dac_spi_ch3      : std_logic_vector(OFFSET_SPI_DATA_WIDTH-1 downto 0);
   signal offset_dac_spi_ch4      : std_logic_vector(OFFSET_SPI_DATA_WIDTH-1 downto 0);
   signal offset_dac_spi_ch5      : std_logic_vector(OFFSET_SPI_DATA_WIDTH-1 downto 0);
   signal offset_dac_spi_ch6      : std_logic_vector(OFFSET_SPI_DATA_WIDTH-1 downto 0);
   signal offset_dac_spi_ch7      : std_logic_vector(OFFSET_SPI_DATA_WIDTH-1 downto 0);

   -- LED output signals
   signal ack_led                 : std_logic;
   signal dat_led                 : std_logic_vector(WB_DATA_WIDTH-1 downto 0);

   -- all_cards regs (including fw_rev, card_type, slot_id, scratch) signals
   signal all_cards_data          : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal all_cards_ack           : std_logic;
   signal all_cards_err           : std_logic;

   -- id_thermo signals
   signal id_thermo_data          : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal id_thermo_ack           : std_logic;
   signal id_thermo_err           : std_logic;

   -- fpga_thermo signals
   signal fpga_thermo_data        : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal fpga_thermo_ack         : std_logic;
   signal fpga_thermo_err         : std_logic;
   
   -- frame_timing : wbs_frame_data interface
   signal num_rows                : integer;
   signal num_rows_reported       : integer;
   signal num_cols_reported       : integer;
   signal data_size               : std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);

   signal pcb_rev            : std_logic_vector(PCB_REV_BITS-1 downto 0);
  
begin

   -- Default assignments to get rid of synthesis warnings.
   ttl_out1 <= '0';
   ttl_dir2 <= '0';
   ttl_out2 <= '0';
   ttl_dir3 <= '0';
   ttl_out3 <= '0';

   adc1_clk <= clk;
   adc2_clk <= clk; 
   adc3_clk <= clk; 
   adc4_clk <= clk; 
   adc5_clk <= clk; 
   adc6_clk <= clk; 
   adc7_clk <= clk; 
   adc8_clk <= clk; 

   -- Active low enable signal for the transmitter on the card.  With '1' it is disabled.
   -- The transmitter is disabled because the Clock Card is driving this line.
   ttl_dir1 <= '1';
   -- The ttl_in1 signal is inverted on the Card, thus the FPGA sees an active-high signal.
   rst <= (not rst_n) or (ttl_in1);

   -- This line will be used by clock card to check card presence
   --lvds_txb <= '0';
   
   pcb_rev <= (others => '0');

   ----------------------------------------------------------------------------
   -- PLL Instantiation
   ----------------------------------------------------------------------------
   i_rc_pll: rc_pll
   port map (
      inclk0 => inclk,
      c0     => clk,
      c1     => open,
      c2     => comm_clk,
      c3     => spi_clk,
      c4     => clk_n
   );

   ----------------------------------------------------------------------------
   -- Dispatch Instantiation
   ----------------------------------------------------------------------------
   i_dispatch: dispatch
   port map (
      clk_i        => clk,
      comm_clk_i   => comm_clk,
      rst_i        => rst,
      lvds_cmd_i   => lvds_cmd,
      lvds_replya_o => lvds_txa,
      lvds_replyb_o => lvds_txb,
      dat_o        => dispatch_dat_out,
      addr_o       => dispatch_addr_out,
      tga_o        => dispatch_tga_out,
      we_o         => dispatch_we_out,
      stb_o        => dispatch_stb_out,
      cyc_o        => dispatch_cyc_out,
      dat_i        => dispatch_dat_in,
      ack_i        => dispatch_ack_in,
      err_i        => dispatch_err_in,
      wdt_rst_o    => wdog,
      slot_i       => slot_id,
      data_size_o  => data_size,
      dip_sw3      => '1',
      dip_sw4      => '1'
   );


   --lvds_txa <= dispatch_lvds_txa;-- when dip_sw3 = '1' else '1';  -- multiplexer for disabling the RC output during test of issue_reply

   -----------------------------------------------------------------------------
   -- Output MUX to Dispatch:
   --
   -- 1. dispatch_addr_out selects which wbs is sending its output to the
   -- dispatch.  The defulat connection is to data=0.
   --
   -- 2. Acknowlege is ORing of the acknowledge signals from all Admins.
   --
   -- 3. Generate dispatch_err_in signal based on dispatch_addr_out.
   -----------------------------------------------------------------------------
   with dispatch_addr_out select dispatch_dat_in <=
      dat_fb           when GAINP0_ADDR | GAINP1_ADDR | GAINP2_ADDR |
                            GAINP3_ADDR | GAINP4_ADDR | GAINP5_ADDR |
                            GAINP6_ADDR | GAINP7_ADDR |
                            GAINI0_ADDR | GAINI1_ADDR | GAINI2_ADDR |
                            GAINI3_ADDR | GAINI4_ADDR | GAINI5_ADDR |
                            GAINI6_ADDR | GAINI7_ADDR |
                            GAIND0_ADDR | GAIND1_ADDR | GAIND2_ADDR |
                            GAIND3_ADDR | GAIND4_ADDR | GAIND5_ADDR |
                            GAIND6_ADDR | GAIND7_ADDR |
                            FLX_QUANTA0_ADDR | FLX_QUANTA1_ADDR | FLX_QUANTA2_ADDR | FLX_QUANTA3_ADDR |
                            FLX_QUANTA4_ADDR | FLX_QUANTA5_ADDR | FLX_QUANTA6_ADDR | FLX_QUANTA7_ADDR |
                            ADC_OFFSET0_ADDR | ADC_OFFSET1_ADDR |
                            ADC_OFFSET2_ADDR | ADC_OFFSET3_ADDR |
                            ADC_OFFSET4_ADDR | ADC_OFFSET5_ADDR |
                            ADC_OFFSET6_ADDR | ADC_OFFSET7_ADDR |
                            SERVO_RST_COL0_ADDR | SERVO_RST_COL1_ADDR | SERVO_RST_COL2_ADDR | SERVO_RST_COL3_ADDR |
                            SERVO_RST_COL4_ADDR | SERVO_RST_COL5_ADDR | SERVO_RST_COL6_ADDR | SERVO_RST_COL7_ADDR |                           
                            FILT_COEF_ADDR | SERVO_MODE_ADDR | RAMP_STEP_ADDR |
                            RAMP_AMP_ADDR  | FB_CONST_ADDR   | RAMP_DLY_ADDR  |
                            SA_BIAS_ADDR   | OFFSET_ADDR     | EN_FB_JUMP_ADDR |
                            I_CLAMP_VAL_ADDR | FLTR_TYPE_ADDR | QTERM_DECAY_ADDR,
      dat_frame        when DATA_MODE_ADDR | RET_DAT_ADDR | CAPTR_RAW_ADDR | READOUT_ROW_INDEX_ADDR |
                            READOUT_COL_INDEX_ADDR | READOUT_PRIORITY_ADDR,
      dat_led          when LED_ADDR,
      dat_ft           when ROW_LEN_ADDR | NUM_ROWS_ADDR | SAMPLE_DLY_ADDR |
                            SAMPLE_NUM_ADDR | FB_DLY_ADDR | ROW_DLY_ADDR |
                            RESYNC_ADDR | FLX_LP_INIT_ADDR | FLTR_RST_ADDR | SERVO_RST_ARM_ADDR| 
                            NUM_COLS_REPORTED_ADDR | NUM_ROWS_REPORTED_ADDR,
      all_cards_data   when FW_REV_ADDR |CARD_TYPE_ADDR | SCRATCH_ADDR | SLOT_ID_ADDR,
      id_thermo_data   when CARD_ID_ADDR | CARD_TEMP_ADDR,
      fpga_thermo_data when FPGA_TEMP_ADDR,
      (others => '0')  when others;        -- default to zero

--   dispatch_ack_in <= ack_fb or ack_frame or ack_led or ack_ft or all_cards_ack; --or id_thermo_ack or fpga_thermo_ack;
   with dispatch_addr_out select dispatch_ack_in <=
      ack_fb          when GAINP0_ADDR | GAINP1_ADDR | GAINP2_ADDR |
                           GAINP3_ADDR | GAINP4_ADDR | GAINP5_ADDR |
                           GAINP6_ADDR | GAINP7_ADDR |
                           GAINI0_ADDR | GAINI1_ADDR | GAINI2_ADDR |
                           GAINI3_ADDR | GAINI4_ADDR | GAINI5_ADDR |
                           GAINI6_ADDR | GAINI7_ADDR |
                           GAIND0_ADDR | GAIND1_ADDR | GAIND2_ADDR |
                           GAIND3_ADDR | GAIND4_ADDR | GAIND5_ADDR |
                           GAIND6_ADDR | GAIND7_ADDR |
                           FLX_QUANTA0_ADDR | FLX_QUANTA1_ADDR | FLX_QUANTA2_ADDR | FLX_QUANTA3_ADDR |
                           FLX_QUANTA4_ADDR | FLX_QUANTA5_ADDR | FLX_QUANTA6_ADDR | FLX_QUANTA7_ADDR |
                           ADC_OFFSET0_ADDR | ADC_OFFSET1_ADDR |
                           ADC_OFFSET2_ADDR | ADC_OFFSET3_ADDR |
                           ADC_OFFSET4_ADDR | ADC_OFFSET5_ADDR |
                           ADC_OFFSET6_ADDR | ADC_OFFSET7_ADDR |
                           SERVO_RST_COL0_ADDR | SERVO_RST_COL1_ADDR | SERVO_RST_COL2_ADDR | SERVO_RST_COL3_ADDR |
                           SERVO_RST_COL4_ADDR | SERVO_RST_COL5_ADDR | SERVO_RST_COL6_ADDR | SERVO_RST_COL7_ADDR |                           
                           FILT_COEF_ADDR | SERVO_MODE_ADDR | RAMP_STEP_ADDR |
                           RAMP_AMP_ADDR  | FB_CONST_ADDR   | RAMP_DLY_ADDR  |
                           SA_BIAS_ADDR   | OFFSET_ADDR     | EN_FB_JUMP_ADDR |
                           I_CLAMP_VAL_ADDR | FLTR_TYPE_ADDR | QTERM_DECAY_ADDR,
      ack_frame       when DATA_MODE_ADDR | RET_DAT_ADDR | CAPTR_RAW_ADDR | READOUT_ROW_INDEX_ADDR |
                           READOUT_COL_INDEX_ADDR | READOUT_PRIORITY_ADDR,
      ack_led         when LED_ADDR,
      ack_ft          when ROW_LEN_ADDR | NUM_ROWS_ADDR | SAMPLE_DLY_ADDR |
                           SAMPLE_NUM_ADDR | FB_DLY_ADDR | ROW_DLY_ADDR |
                           RESYNC_ADDR | FLX_LP_INIT_ADDR | FLTR_RST_ADDR | SERVO_RST_ARM_ADDR |
                           NUM_COLS_REPORTED_ADDR | NUM_ROWS_REPORTED_ADDR,
      all_cards_ack   when FW_REV_ADDR |CARD_TYPE_ADDR | SCRATCH_ADDR | SLOT_ID_ADDR,
      id_thermo_ack   when CARD_ID_ADDR | CARD_TEMP_ADDR,
      fpga_thermo_ack when FPGA_TEMP_ADDR,
      '0'             when others;        -- default to zero

   with dispatch_addr_out select dispatch_err_in <=
      '0'             when GAINP0_ADDR | GAINP1_ADDR | GAINP2_ADDR |
                           GAINP3_ADDR | GAINP4_ADDR | GAINP5_ADDR |
                           GAINP6_ADDR | GAINP7_ADDR |
                           GAINI0_ADDR | GAINI1_ADDR | GAINI2_ADDR |
                           GAINI3_ADDR | GAINI4_ADDR | GAINI5_ADDR |
                           GAINI6_ADDR | GAINI7_ADDR |
                           GAIND0_ADDR | GAIND1_ADDR | GAIND2_ADDR |
                           GAIND3_ADDR | GAIND4_ADDR | GAIND5_ADDR |
                           GAIND6_ADDR | GAIND7_ADDR |
                           FLX_QUANTA0_ADDR | FLX_QUANTA1_ADDR | FLX_QUANTA2_ADDR | FLX_QUANTA3_ADDR |
                           FLX_QUANTA4_ADDR | FLX_QUANTA5_ADDR | FLX_QUANTA6_ADDR | FLX_QUANTA7_ADDR |
                           ADC_OFFSET0_ADDR | ADC_OFFSET1_ADDR |
                           ADC_OFFSET2_ADDR | ADC_OFFSET3_ADDR |
                           ADC_OFFSET4_ADDR | ADC_OFFSET5_ADDR |
                           ADC_OFFSET6_ADDR | ADC_OFFSET7_ADDR |
                           SERVO_RST_COL0_ADDR | SERVO_RST_COL1_ADDR | SERVO_RST_COL2_ADDR | SERVO_RST_COL3_ADDR |
                           SERVO_RST_COL4_ADDR | SERVO_RST_COL5_ADDR | SERVO_RST_COL6_ADDR | SERVO_RST_COL7_ADDR |                           
                           FILT_COEF_ADDR | SERVO_MODE_ADDR | RAMP_STEP_ADDR |
                           RAMP_AMP_ADDR  | FB_CONST_ADDR   | RAMP_DLY_ADDR  |
                           SA_BIAS_ADDR   | OFFSET_ADDR     | EN_FB_JUMP_ADDR |
                           DATA_MODE_ADDR | RET_DAT_ADDR | CAPTR_RAW_ADDR | READOUT_ROW_INDEX_ADDR |
                           READOUT_COL_INDEX_ADDR | READOUT_PRIORITY_ADDR |
                           LED_ADDR |
                           ROW_LEN_ADDR | NUM_ROWS_ADDR | SAMPLE_DLY_ADDR |
                           SAMPLE_NUM_ADDR | FB_DLY_ADDR | ROW_DLY_ADDR |
                           RESYNC_ADDR | FLX_LP_INIT_ADDR | FLTR_RST_ADDR | SERVO_RST_ARM_ADDR |
                           NUM_COLS_REPORTED_ADDR | NUM_ROWS_REPORTED_ADDR |
                           I_CLAMP_VAL_ADDR | FLTR_TYPE_ADDR | QTERM_DECAY_ADDR,
      all_cards_err   when FW_REV_ADDR | CARD_TYPE_ADDR | SCRATCH_ADDR | SLOT_ID_ADDR,
      id_thermo_err   when CARD_ID_ADDR | CARD_TEMP_ADDR,
      fpga_thermo_err when FPGA_TEMP_ADDR,
      '1'             when others;

   ----------------------------------------------------------------------------
   -- Frame_timing Instantiation
   ----------------------------------------------------------------------------
   i_frame_timing: frame_timing
   port map (
      dac_dat_en_o              => dac_dat_en,
      adc_coadd_en_o            => adc_coadd_en,
      restart_frame_1row_prev_o => restart_frame_1row_prev,
      restart_frame_aligned_o   => restart_frame_aligned,
      restart_frame_1row_post_o => restart_frame_1row_post,
      initialize_window_o       => initialize_window,
      servo_rst_window_o        => servo_rst_window,
      fltr_rst_o                => fltr_rst,
      num_rows_o                => num_rows,
      num_rows_reported_o       => num_rows_reported,
      num_cols_reported_o       => num_cols_reported,
      
      row_switch_o              => row_switch,
      row_en_o                  => open,
      
      update_bias_o             => open,
      
      dat_i                     => dispatch_dat_out,
      addr_i                    => dispatch_addr_out,
      tga_i                     => dispatch_tga_out,
      we_i                      => dispatch_we_out,
      stb_i                     => dispatch_stb_out,
      cyc_i                     => dispatch_cyc_out,
      dat_o                     => dat_ft,
      ack_o                     => ack_ft,
      clk_i                     => clk,
      clk_n_i                   => clk_n,
      rst_i                     => rst,
      sync_i                    => lvds_sync
   );


   ----------------------------------------------------------------------------
   -- Flux_loop Instantiation
   ----------------------------------------------------------------------------
   i_flux_loop: flux_loop
   generic map (ADC_LATENCY => ADC_LATENCY_REVA)
   port map (
      clk_50_i                  => clk,
      clk_25_i                  => spi_clk,
      rst_i                     => rst,
      num_rows_i                => num_rows,
      num_rows_reported_i       => num_rows_reported,
      num_cols_reported_i       => num_cols_reported,
      data_size_i               => data_size,
      adc_coadd_en_i            => adc_coadd_en,
      restart_frame_1row_prev_i => restart_frame_1row_prev,
      restart_frame_aligned_i   => restart_frame_aligned,
      restart_frame_1row_post_i => restart_frame_1row_post,
      row_switch_i              => row_switch,
      initialize_window_i       => initialize_window,
      servo_rst_window_i        => servo_rst_window,     
      fltr_rst_i                => fltr_rst,
      num_rows_sub1_i           => (others => '0'),
      dac_dat_en_i              => dac_dat_en,
      dat_i                     => dispatch_dat_out,
      addr_i                    => dispatch_addr_out,
      tga_i                     => dispatch_tga_out,
      we_i                      => dispatch_we_out,
      stb_i                     => dispatch_stb_out,
      cyc_i                     => dispatch_cyc_out,
      dat_frame_o               => dat_frame,
      ack_frame_o               => ack_frame,
      dat_fb_o                  => dat_fb,
      ack_fb_o                  => ack_fb,
      adc_dat_ch0_i             => adc1_dat,
      adc_dat_ch1_i             => adc2_dat,
      adc_dat_ch2_i             => adc3_dat,
      adc_dat_ch3_i             => adc4_dat,
      adc_dat_ch4_i             => adc5_dat,
      adc_dat_ch5_i             => adc6_dat,
      adc_dat_ch6_i             => adc7_dat,
      adc_dat_ch7_i             => adc8_dat,
      dac_dat_ch0_o             => dac_FB1_dat,
      dac_dat_ch1_o             => dac_FB2_dat,
      dac_dat_ch2_o             => dac_FB3_dat,
      dac_dat_ch3_o             => dac_FB4_dat,
      dac_dat_ch4_o             => dac_FB5_dat,
      dac_dat_ch5_o             => dac_FB6_dat,
      dac_dat_ch6_o             => dac_FB7_dat,
      dac_dat_ch7_o             => dac_FB8_dat,
      dac_clk_ch0_o             => dac_FB_clk(0),
      dac_clk_ch1_o             => dac_FB_clk(1),
      dac_clk_ch2_o             => dac_FB_clk(2),
      dac_clk_ch3_o             => dac_FB_clk(3),
      dac_clk_ch4_o             => dac_FB_clk(4),
      dac_clk_ch5_o             => dac_FB_clk(5),
      dac_clk_ch6_o             => dac_FB_clk(6),
      dac_clk_ch7_o             => dac_FB_clk(7),
      sa_bias_dac_spi_ch0_o     => sa_bias_dac_spi_ch0,
      sa_bias_dac_spi_ch1_o     => sa_bias_dac_spi_ch1,
      sa_bias_dac_spi_ch2_o     => sa_bias_dac_spi_ch2,
      sa_bias_dac_spi_ch3_o     => sa_bias_dac_spi_ch3,
      sa_bias_dac_spi_ch4_o     => sa_bias_dac_spi_ch4,
      sa_bias_dac_spi_ch5_o     => sa_bias_dac_spi_ch5,
      sa_bias_dac_spi_ch6_o     => sa_bias_dac_spi_ch6,
      sa_bias_dac_spi_ch7_o     => sa_bias_dac_spi_ch7,
      offset_dac_spi_ch0_o      => offset_dac_spi_ch0,
      offset_dac_spi_ch1_o      => offset_dac_spi_ch1,
      offset_dac_spi_ch2_o      => offset_dac_spi_ch2,
      offset_dac_spi_ch3_o      => offset_dac_spi_ch3,
      offset_dac_spi_ch4_o      => offset_dac_spi_ch4,
      offset_dac_spi_ch5_o      => offset_dac_spi_ch5,
      offset_dac_spi_ch6_o      => offset_dac_spi_ch6,
      offset_dac_spi_ch7_o      => offset_dac_spi_ch7
   );               

   -- Chip select signal assignment
   bias_dac_ncs(0) <= sa_bias_dac_spi_ch0(2);
   bias_dac_ncs(1) <= sa_bias_dac_spi_ch1(2);
   bias_dac_ncs(2) <= sa_bias_dac_spi_ch2(2);
   bias_dac_ncs(3) <= sa_bias_dac_spi_ch3(2);
   bias_dac_ncs(4) <= sa_bias_dac_spi_ch4(2);
   bias_dac_ncs(5) <= sa_bias_dac_spi_ch5(2);
   bias_dac_ncs(6) <= sa_bias_dac_spi_ch6(2);
   bias_dac_ncs(7) <= sa_bias_dac_spi_ch7(2);

   -- Chip select signal assignment
   offset_dac_ncs(0)  <= offset_dac_spi_ch0(2);
   offset_dac_ncs(1)  <= offset_dac_spi_ch1(2);
   offset_dac_ncs(2)  <= offset_dac_spi_ch2(2);
   offset_dac_ncs(3)  <= offset_dac_spi_ch3(2);
   offset_dac_ncs(4)  <= offset_dac_spi_ch4(2);
   offset_dac_ncs(5)  <= offset_dac_spi_ch5(2);
   offset_dac_ncs(6)  <= offset_dac_spi_ch6(2);
   offset_dac_ncs(7)  <= offset_dac_spi_ch7(2);

   -- MUX for slecting dac_dat or dac_clk from offset or sa_bias based on the
   -- chip select from sa_bias.  Note that we are assuming mutually exclusive
   -- chip select for sa_bias and offset.
   i_MUX_dac: process (
      sa_bias_dac_spi_ch0, sa_bias_dac_spi_ch1,
      sa_bias_dac_spi_ch2, sa_bias_dac_spi_ch3,
      sa_bias_dac_spi_ch4, sa_bias_dac_spi_ch5,
      sa_bias_dac_spi_ch6, sa_bias_dac_spi_ch7,
      offset_dac_spi_ch0, offset_dac_spi_ch1,
      offset_dac_spi_ch2, offset_dac_spi_ch3,
      offset_dac_spi_ch4, offset_dac_spi_ch5,
      offset_dac_spi_ch6, offset_dac_spi_ch7)
   begin  -- process i_MUX_dac_dat
      case sa_bias_dac_spi_ch0(2) is
         when '0' =>
            dac_dat(0) <= sa_bias_dac_spi_ch0(0);
            dac_clk(0) <= sa_bias_dac_spi_ch0(1);
         when others =>
            dac_dat(0) <= offset_dac_spi_ch0(0);
            dac_clk(0) <= offset_dac_spi_ch0(1);
      end case;

      case sa_bias_dac_spi_ch1(2) is
         when '0' =>
            dac_dat(1) <= sa_bias_dac_spi_ch1(0);
            dac_clk(1) <= sa_bias_dac_spi_ch1(1);
         when others =>
            dac_dat(1) <= offset_dac_spi_ch1(0);
            dac_clk(1) <= offset_dac_spi_ch1(1);
      end case;

      case sa_bias_dac_spi_ch2(2) is
         when '0' =>
            dac_dat(2) <= sa_bias_dac_spi_ch2(0);
            dac_clk(2) <= sa_bias_dac_spi_ch2(1);
         when others =>
            dac_dat(2) <= offset_dac_spi_ch2(0);
            dac_clk(2) <= offset_dac_spi_ch2(1);
      end case;

      case sa_bias_dac_spi_ch3(2) is
         when '0' =>
            dac_dat(3) <= sa_bias_dac_spi_ch3(0);
            dac_clk(3) <= sa_bias_dac_spi_ch3(1);
         when others =>
            dac_dat(3) <= offset_dac_spi_ch3(0);
            dac_clk(3) <= offset_dac_spi_ch3(1);
      end case;

      case sa_bias_dac_spi_ch4(2) is
         when '0' =>
            dac_dat(4) <= sa_bias_dac_spi_ch4(0);
            dac_clk(4) <= sa_bias_dac_spi_ch4(1);
         when others =>
            dac_dat(4) <= offset_dac_spi_ch4(0);
            dac_clk(4) <= offset_dac_spi_ch4(1);
      end case;

      case sa_bias_dac_spi_ch5(2) is
         when '0' =>
            dac_dat(5) <= sa_bias_dac_spi_ch5(0);
            dac_clk(5) <= sa_bias_dac_spi_ch5(1);
         when others =>
            dac_dat(5) <= offset_dac_spi_ch5(0);
            dac_clk(5) <= offset_dac_spi_ch5(1);
      end case;

      case sa_bias_dac_spi_ch6(2) is
         when '0' =>
            dac_dat(6) <= sa_bias_dac_spi_ch6(0);
            dac_clk(6) <= sa_bias_dac_spi_ch6(1);
         when others =>
            dac_dat(6) <= offset_dac_spi_ch6(0);
            dac_clk(6) <= offset_dac_spi_ch6(1);
      end case;

      case sa_bias_dac_spi_ch7(2) is
         when '0' =>
            dac_dat(7) <= sa_bias_dac_spi_ch7(0);
            dac_clk(7) <= sa_bias_dac_spi_ch7(1);
         when others =>
            dac_dat(7) <= offset_dac_spi_ch7(0);
            dac_clk(7) <= offset_dac_spi_ch7(1);
      end case;
   end process i_MUX_dac;

   ----------------------------------------------------------------------------
   -- LED Instantition
   ----------------------------------------------------------------------------
   i_LED: leds
   port map (
       clk_i  => clk,
       rst_i  => rst,
       dat_i  => dispatch_dat_out,
       addr_i => dispatch_addr_out,
       tga_i  => dispatch_tga_out,
       we_i   => dispatch_we_out,
       stb_i  => dispatch_stb_out,
       cyc_i  => dispatch_cyc_out,
       dat_o  => dat_led,
       ack_o  => ack_led,
       power  => grn_led,
       status => ylw_led,
       fault  => red_led
   );

   ----------------------------------------------------------------------------
   -- all_cards registers Instantition
   ----------------------------------------------------------------------------
   i_all_cards: all_cards
   generic map ( 
      REVISION => RC_REVISION,
      CARD_TYPE=> RC_CARD_TYPE)
   port map (
      clk_i     => clk,
      rst_i     => rst,
      dat_i     => dispatch_dat_out,
      addr_i    => dispatch_addr_out,
      tga_i     => dispatch_tga_out,
      we_i      => dispatch_we_out,
      stb_i     => dispatch_stb_out,
      cyc_i     => dispatch_cyc_out,
      slot_id_i => slot_id,
      pcb_rev_i => pcb_rev,
      err_o     => all_cards_err,
      dat_o     => all_cards_data,
      ack_o     => all_cards_ack
   );

   ----------------------------------------------------------------------------
   -- id_thermo Instantition
   ----------------------------------------------------------------------------
   i_id_thermo: id_thermo
   port map(
      clk_i   => clk,
      rst_i   => rst,

      -- Wishbone signals
      dat_i   => dispatch_dat_out,
      addr_i  => dispatch_addr_out,
      tga_i   => dispatch_tga_out,
      we_i    => dispatch_we_out,
      stb_i   => dispatch_stb_out,
      cyc_i   => dispatch_cyc_out,
      err_o   => id_thermo_err,
      dat_o   => id_thermo_data,
      ack_o   => id_thermo_ack,

      -- silicon id/temperature chip signals
      data_io => card_id
   );

   ----------------------------------------------------------------------------
   -- fpga_thermo Instantition
   ----------------------------------------------------------------------------
   smb_nalert <= '0';
   i_fpga_thermo: fpga_thermo
   port map(
      clk_i   => clk,
      rst_i   => rst,

      -- Wishbone signals
      dat_i   => dispatch_dat_out,
      addr_i  => dispatch_addr_out,
      tga_i   => dispatch_tga_out,
      we_i    => dispatch_we_out,
      stb_i   => dispatch_stb_out,
      cyc_i   => dispatch_cyc_out,
      err_o   => fpga_thermo_err,
      dat_o   => fpga_thermo_data,
      ack_o   => fpga_thermo_ack,

      -- FPGA temperature chip signals
      smbclk_o  => smb_clk,
      smbalert_i => '1',
      smbdat_io => smb_data
   );

   ----------------------------------------------------------------------------
   -- Mictor Connection
   ----------------------------------------------------------------------------

--   mictor(0)  <= clk;
--   mictor(1)  <= dac_dat_en;
--   mictor(2)  <= adc_coadd_en;
--   mictor(3)  <= restart_frame_1row_prev;
--   mictor(4)  <= restart_frame_aligned;
--   mictor(5)  <= restart_frame_1row_post;
--   mictor(6)  <= row_switch;
--   mictor(7)  <= initialize_window;
--   mictor(8)  <= lvds_sync;
--   mictor(9)  <= lvds_cmd;
--   mictor(10) <= dispatch_lvds_txa;
--   mictor(11) <= dispatch_err_in;
--   mictor(12) <= dispatch_tga_out(0);
--   mictor(13) <= dispatch_tga_out(1);
--   mictor(14) <= dispatch_tga_out(2);
--   mictor(15) <= dispatch_we_out;
--   mictor(16) <= dispatch_stb_out;
--   mictor(17) <= dispatch_cyc_out;
--   mictor(18) <= dispatch_addr_out(0);
--   mictor(19) <= dispatch_addr_out(1);
--   mictor(20) <= dispatch_addr_out(2);
--   mictor(21) <= dispatch_addr_out(3);
--   mictor(22) <= dispatch_addr_out(4);
--   mictor(23) <= dispatch_addr_out(5);
--   mictor(24) <= dispatch_addr_out(6);
--   mictor(25) <= dispatch_addr_out(7);
--   mictor(26) <= ack_fb;
--   mictor(27) <= ack_frame;
--   mictor(28) <= ack_ft;
--   mictor(29) <= ack_led;
--   mictor(30) <= fw_rev_ack;
--   mictor(31) <= rst;

end top;
