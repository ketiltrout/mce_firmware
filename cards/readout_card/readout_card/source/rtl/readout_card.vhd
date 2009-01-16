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
-- Revision 1.80  2008/12/22 20:33:06  bburger
-- BB: Added a second LVDS line, and added support for reading column data.
--
-- Revision 1.79  2008/11/21 18:09:37  bburger
-- BB:  v04040001, which fixes a bug with the fpga_thermo and id_thermo blocks where the ack signal wasn't being routed back properly.
--
-- Revision 1.78  2008/10/03 00:39:27  mandana
-- BB:  Re-integrated the id_thermo and fpga_thermo block in the readout_card.vhd top level that was removed in 4.0.c.
--
-- Revision 1.77  2008/08/15 18:14:44  mandana
-- BB:  rc_v0400000c_15aug2008
--
-- Revision 1.76  2008/08/04 12:07:28  mandana
-- added data_mode 10 for 4.0.b
--
-- Revision 1.75  2008/07/10 18:33:07  mandana
-- rev. 4.0.a
-- regenerated ram_8x64 (flx_quanta) and wbs_fb_storage (adc_offset) rams in Quartus to fix pre-reset read failure bug.
-- reduced servo_mode storage width to 2 bits in misc_banks_admin to relax timing
-- removed quartus.ini file from synth directory
--
-- Revision 1.74  2008/06/27 20:37:15  mandana
-- rev. 4.0.9
-- sa_bias/offset DACs only refreshed when new values are written to as oppose to every frame.
--
-- Revision 1.73  2008/06/27 18:38:50  mandana
-- rev. 4.0.8
-- increased pid width to 12 bits
-- fixed gainpid-read failure upon power-up (prior to reset)
--
-- Revision 1.72  2008/06/19 23:57:24  mandana
-- revision 4.3.7, 14-bit raw mode active, filter disabled, pid write only
--
-- Revision 1.69  2008/02/15 22:32:17  mandana
-- bugfix: unreliable reset due to unsafe and incomplete state machines is fixed.
-- bugfix: flux_jump sign problem fixed
-- servo_mode=2 or ramp previously only went from 0 to ramp_amp, but now goes from -8192 to -8192+ramp_amp
--  new commands are added: scratch and card_type. Scratch takes 8 values and can be used by software to detect reset.
-- slot_id and fw_rev are now integrated as part of all_cards.vhd
-- lvds_tx_b=0, This will allow Clock Card to use the secondary backplane lvds line and check whether RC is plugged in.
-- filter_coeff commented in misc_banks_admin
--
-- Revision 1.68  2007/11/01 18:53:47  mandana
-- 4.0.5: data mode 8 is replaced by data mode 9 with new windowing of filtered data
--
-- Revision 1.67  2007/10/24 23:31:45  mandana
-- added data mode 8 (mixed mode filtfb + flux_count)
--
-- Revision 1.66  2007/09/28 00:04:06  mandana
-- rev 4.0.3
-- fixed data mode 7 to be 22b filtfb and 10b error scaled by 16
-- wait 1 frame for mixed filtfb/error modes
--
-- Revision 1.65  2007/09/12 05:12:21  mandana
-- rev. 04000002 with data mode 7 added 22b filtfb/10b err, 10b pid pars
--
-- Revision 1.64  2007/09/10 23:33:07  mandana
-- rev. 4.0.1 for readout_row_index default to 0 and be able to do multiple rows
--
-- Revision 1.63  2007/08/28 19:32:11  mandana
-- v040000000 added readout_row_index
--
-- Revision 1.62  2007/06/16 03:29:00  mandana
-- v03000001e added data_mode=6 for 18b filtered fb + 14b error
--
-- Revision 1.61  2007/03/21 19:17:02  mandana
-- added new fpga_thermo module for reliable readings
-- major rewrite of fsfb_corr
--
-- Revision 1.60  2007/03/07 18:25:35  mandana
-- Revision 0300001c filter_input_width set to 18 instead of 28
--
-- Revision 1.59  2007/03/01 18:18:09  mandana
-- rev. 0300001b for 10b ram for pid coeffs
--
-- Revision 1.58  2007/02/22 00:21:51  mandana
-- Revision 0300001a same as 3.19 but filter included, raw mode excluded
--
-- Revision 1.57  2007/02/19 20:13:54  mandana
-- properly sign-extend raw-data both in adc_sample_coadd and wbs_frame_data
-- rewrote wbs_frame_data FSM
-- changed ram40x64 init file to hex file
-- changed revision to 3.000019
--
-- Revision 1.56  2006/12/13 18:26:26  mandana
-- changed rev. to 03000018 to enable raw_mode, disable filter with servo_mode/column control
--
-- Revision 1.55  2006/12/11 18:10:08  mandana
-- Changed revision to 3.17, added ports to fsfb_corr for servo_mode/column and fixed a bug with fsb_const initial value for column 8
--
-- Revision 1.54  2006/12/05 22:30:41  mandana
-- changed rev. to 03000016 to split the servo_mode to be column specific instead of common for all columns.
-- Note that flux_jump will still get enabled based on column 0 servo_mode!
--
-- Revision 1.53  2006/12/05 14:08:41  mandana
-- changed rev. to 03000015 to fix a bug related to splitting fb_const to be specific to each column and only column 0 being initialized to -8192 and the rest to 0. This should be fixed.
-- ramp_mode is disabled just to resolve timting violations encountered in fsfb_corr in 030000014
--
-- Revision 1.52  2006/11/24 21:08:55  mandana
-- splitted fb_const to be channel specific, changed revision to 3.14
--
-- Revision 1.51  2006/09/25 23:31:06  mandana
-- changed revision to 030000013 for changing PIDZ_DATA_WIDTH to 10b from 8b
--
-- Revision 1.50  2006/09/22 21:19:53  mandana
-- changed revision to 030000012 for adding adc_offset read-back feature
--
-- Revision 1.49  2006/08/10 21:35:42  mandana
-- revision 03000105 for FILTER_GAIN_WIDTH = 11, i.e. divide by 2048 between filter stages
--
-- Revision 1.48  2006/07/28 17:18:01  mandana
-- revision 03000104 for FILTER_LOCK_LSB_POS set to 12 and divide by 32 added between filter stages.
--
-- Revision 1.47  2006/07/24 23:23:37  mandana
-- revision 03000103 for FILTER_LOCK_LSB_POS set to 10 and fsfb_corr violations fixed by reducing operation(multi/sub) width
--
-- Revision 1.46  2006/07/24 18:24:38  mandana
-- revision 03000102 for 1S40 and FILTER_LOCK_LSB_POS set to 10
--
-- Revision 1.45  2006/07/20 23:32:43  mandana
-- revision 03000101 for 1S40 and FILTER_LOCK_LSB_POS set to 12 instead of 14
--
-- Revision 1.44  2006/07/18 17:06:08  mandana
-- revision 03000100 to fix the bug with PID RAMs for ch1 to ch7 being synthesized out, uses Q6.0 SP1.
--
-- Revision 1.43  2006/07/07 21:28:03  mandana
-- revision upgraded to 03000011 for DACs to be initialized to 0 by loading -8192 to DACs as default and default servo_mode is constant rather than undefined
--
-- Revision 1.42  2006/06/30 17:09:08  bburger
-- raw_mode enabled, filter disabled, Q42
--
-- Revision 1.41  2006/06/09 16:48:46  mandana
-- fixed pix_addr_cnt  reset problem in wbs_frame_data to fix a bug with readout data of reduced number of rows
--
-- Revision 1.40  2006/06/07 19:49:45  bburger
-- Bryce:  rc_v0300000d
--
-- Revision 1.39  2006/05/16 21:22:33  mandana
-- revision upgraded to 0300000b (from 03000000a) for slot_id, default LED status, fpga_temp
--
-- Revision 1.38  2006/05/05 19:56:26  mandana
-- use all_cards_pack.vhd
-- added fpga_thermo and slot_id
-- added err_o interface for slot_id, fw_rev, id_thermo, fpga_thermo
-- revision upgraded to 030000000a for weighted_integral calculation
--
-- Revision 1.37  2006/04/28 18:11:24  mandana
-- revision upgraded to 03000009 (from 030000006) to compile for 1S40 and backplane Rev. C
--
-- Revision 1.36  2006/04/18 17:37:07  mandana
-- revision upgraded to 03000008 (from 030000006) to compile for 1S40 and backplane Rev. A/B
--
-- Revision 1.35  2006/04/12 23:25:09  mandana
-- revision upgraded to 03000007 to enable raw mode and disable filter
--
-- Revision 1.34  2006/04/10 23:53:47  mandana
-- revision upgraded to 03000006 for Rev. A/B BP, data_mode 4 adjusted and 2^12 scaling in fsfb_corr_pack
--
-- Revision 1.33  2006/04/03 23:32:47  mandana
-- revision upgraded to 03000005 for Rev. C BP, data_mode 4 adjusted and 2^12 scaling in fsfb_corr_pack
--
-- Revision 1.32  2006/03/24 21:01:44  mandana
-- revision 03000004 built based on 03000003 where dip_sw ports are added for dispatch block
--
-- Revision 1.31  2006/03/22 19:28:34  mandana
-- revision 03000003 built based on 02000009 with latest BB protocol
--
-- Revision 1.30  2006/03/17 18:29:18  mandana
-- revision upgraded to 02000009 for data_mode 4 adjusted and 2^12 scaling in fsfb_corr_pack
--
-- Revision 1.28  2006/03/15 23:41:22  mandana
-- revision upgraded to 02000007 for 2^10 scaling in fsfb_corr_pack
--
-- Revision 1.27  2006/03/15 18:18:48  mandana
-- revision upgraded to 02000006 for 2^12 scaling in fsfb_corr_pack
--
-- Revision 1.26  2006/03/14 23:31:43  mandana
-- revision upgraded to 02000005 for 4-pole filter and timing violations introduced by Q5.1 are fixed now
-- mem_clk finally deleted
--
-- Revision 1.23.2.3  2006/02/17 21:16:48  mandana
-- revision number changed to 02000004 for princeton filter and filter window set at 14
--
-- Revision 1.23.2.2  2006/02/15 22:22:40  bburger
-- Bryce:  changed revision number to 02000003
--
-- Revision 1.23.2.1  2006/02/15 22:07:39  mandana
-- old dispatch, revision number changed to 02000002
--
-- Revision 1.23  2006/02/15 21:53:29  mandana
-- added FLTR_RST_ADDR command
-- moved component declarations to readout_card.pak
-- revision number upgraded to 0200000001
--
-- Revision 1.22  2006/02/09 20:32:59  bburger
-- Bryce:
-- - Added a fltr_rst_o output signal from the frame_timing block
-- - Adjusted the top-levels of each card to reflect the frame_timing interface change
--
-- Revision 1.21  2006/02/09 17:24:57  bburger
-- Bryce:  committing v02000000 for tagging
--
-- Revision 1.20  2006/02/06 19:23:35  bburger
-- Bryce:  commital for intermediate tag
--
-- Revision 1.19  2006/01/18 21:40:44  mandana
-- revision num. updated to 01040002 for integration of new dispatch module that incorporates new BB protocol
--
-- Revision 1.18  2005/12/14 20:01:50  mandana
-- revision number updated to 01040001 for merged filter + flux_jump functionality
--
-- Revision 1.17  2005/11/28 19:21:20  bburger
-- Bryce:  changed from v01020001 to v01020002
--
-- Revision 1.16  2005/09/14 23:48:39  bburger
-- bburger:
-- Integrated flux-jumping into flux_loop
--
-- Revision 1.15  2005/06/23 17:19:32  mohsen
-- Mandana: added COUNT_MAX to prevent raw_memory bank from wrapping, changed RAW_ADDR_MAX, RAW_DATA_POSITION_POINTER
--
-- Revision 1.14  2005/05/09 23:48:51  mohsen
-- Bryce - v01010006 of the 8-channel readout card with a fix that enables it to sample the sync line in the middle of a clock period.
--
-- Revision 1.13  2005/05/06 20:02:31  bburger
-- Bryce:  Added a 50MHz clock that is 180 degrees out of phase with clk_i.
-- This clk_n_i signal is used for sampling the sync_i line during the middle of the pulse, to avoid problems associated with sampling on the edges.
--
-- Revision 1.12  2005/03/31 18:18:45  mohsen
-- new rev number. This rev number is exactly the same as 01010004 except for lvds_rx synchronizer bug fix.
-- Thus, the revision is the normal readout card firmware with the exception of having data_mode 0 in
-- wbs_frame_data connected to co-added values rather than the filter values.  This is needed for cold test.
--
-- Revision 1.11  2005/03/30 18:30:16  mohsen
-- new rev number for 8-channel firmware validation
--
-- Revision 1.10  2005/03/18 01:27:41  mohsen
-- Fixed compilation errors and added mictor connection
--
-- Revision 1.9  2005/02/21 22:29:26  mandana
-- added firmware revision RC_REVISION (fw_rev)
--
-- Revision 1.8  2005/01/19 23:39:06  bburger
-- Bryce:  Fixed a couple of errors with the special-character clear.  Always compile, simulate before comitting.
--
-- Revision 1.7  2005/01/18 22:20:47  bburger
-- Bryce:  Added a BClr signal across the bus backplane to all the card top levels.
--
-- Revision 1.6  2005/01/13 22:38:54  mohsen
-- Dispatch interface change
--
-- Revision 1.5  2004/12/21 22:06:51  bburger
-- Bryce:  update
--
-- Revision 1.4  2004/12/10 20:23:40  mohsen
-- Mohsen & Anthony: Added mem and comm clock
-- Updated dispatch new interface, i.e., err_i
--
-- Revision 1.3  2004/12/07 20:22:21  mohsen
-- Anthony & Mohsen: Initial release
--
-- Revision 1.2  2004/12/06 07:22:34  bburger
-- Bryce:
-- Created pack files for the card top-levels.
-- Added some simulation signals to the top-levels (i.e. clocks)
--
-- Revision 1.1  2004/11/16 11:04:41  dca
-- Initial Version
--
--
--
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;

library work;
use work.readout_card_pack.all;
use work.all_cards_pack.all;

entity readout_card is
generic(
  CARD            : std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0) := READOUT_CARD_1
     );
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
  smb_nalert      : in std_logic;
  smb_data        : inout std_logic;

  -- Debug ports
  mictor          : out std_logic_vector(31 downto 0)
  );

end readout_card;

architecture top of readout_card is

   -- The REVISION format is RRrrBBBB where
   --               RR is the major revision number
   --               rr is the minor revision number
   --               BBBB is the build number
   constant RC_REVISION: std_logic_vector (31 downto 0) := X"05000000";

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

begin

   -- Active low enable signal for the transmitter on the card.  With '1' it is disabled.
   -- The transmitter is disabled because the Clock Card is driving this line.
   ttl_dir1 <= '1';
   -- The ttl_in1 signal is inverted on the Card, thus the FPGA sees an active-high signal.
   rst <= (not rst_n) or (ttl_in1);

   -- This line will be used by clock card to check card presence
   --lvds_txb <= '0';

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
      dat_fb          when   GAINP0_ADDR | GAINP1_ADDR | GAINP2_ADDR |
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
                             FILT_COEF_ADDR | SERVO_MODE_ADDR | RAMP_STEP_ADDR |
                             RAMP_AMP_ADDR  | FB_CONST_ADDR   | RAMP_DLY_ADDR  |
                             SA_BIAS_ADDR   | OFFSET_ADDR     | EN_FB_JUMP_ADDR,
      dat_frame       when   DATA_MODE_ADDR | RET_DAT_ADDR | CAPTR_RAW_ADDR | READOUT_ROW_INDEX_ADDR |
                             READOUT_COL_INDEX_ADDR | READOUT_PRIORITY_ADDR,
      dat_led         when   LED_ADDR,
      dat_ft          when   ROW_LEN_ADDR | NUM_ROWS_ADDR | SAMPLE_DLY_ADDR |
                             SAMPLE_NUM_ADDR | FB_DLY_ADDR | ROW_DLY_ADDR |
                             RESYNC_ADDR | FLX_LP_INIT_ADDR | FLTR_RST_ADDR | NUM_COLS_REPORTED_ADDR | NUM_ROWS_REPORTED_ADDR,
      all_cards_data  when   FW_REV_ADDR |CARD_TYPE_ADDR | SCRATCH_ADDR | SLOT_ID_ADDR,
      id_thermo_data  when   CARD_ID_ADDR | CARD_TEMP_ADDR,
      fpga_thermo_data when  FPGA_TEMP_ADDR,
      (others => '0') when others;        -- default to zero

--   dispatch_ack_in <= ack_fb or ack_frame or ack_led or ack_ft or all_cards_ack; --or id_thermo_ack or fpga_thermo_ack;
   with dispatch_addr_out select dispatch_ack_in <=
      ack_fb          when   GAINP0_ADDR | GAINP1_ADDR | GAINP2_ADDR |
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
                             FILT_COEF_ADDR | SERVO_MODE_ADDR | RAMP_STEP_ADDR |
                             RAMP_AMP_ADDR  | FB_CONST_ADDR   | RAMP_DLY_ADDR  |
                             SA_BIAS_ADDR   | OFFSET_ADDR     | EN_FB_JUMP_ADDR,
      ack_frame       when   DATA_MODE_ADDR | RET_DAT_ADDR | CAPTR_RAW_ADDR | READOUT_ROW_INDEX_ADDR |
                             READOUT_COL_INDEX_ADDR | READOUT_PRIORITY_ADDR,
      ack_led         when   LED_ADDR,
      ack_ft          when   ROW_LEN_ADDR | NUM_ROWS_ADDR | SAMPLE_DLY_ADDR |
                             SAMPLE_NUM_ADDR | FB_DLY_ADDR | ROW_DLY_ADDR |
                             RESYNC_ADDR | FLX_LP_INIT_ADDR | FLTR_RST_ADDR | NUM_COLS_REPORTED_ADDR | NUM_ROWS_REPORTED_ADDR,
      all_cards_ack   when   FW_REV_ADDR |CARD_TYPE_ADDR | SCRATCH_ADDR | SLOT_ID_ADDR,
      id_thermo_ack   when   CARD_ID_ADDR | CARD_TEMP_ADDR,
      fpga_thermo_ack when   FPGA_TEMP_ADDR,
      '0'             when others;        -- default to zero

   with dispatch_addr_out select dispatch_err_in <=
     '0'             when   GAINP0_ADDR | GAINP1_ADDR | GAINP2_ADDR |
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
                            FILT_COEF_ADDR | SERVO_MODE_ADDR | RAMP_STEP_ADDR |
                            RAMP_AMP_ADDR  | FB_CONST_ADDR   | RAMP_DLY_ADDR  |
                            SA_BIAS_ADDR   | OFFSET_ADDR     | EN_FB_JUMP_ADDR |
                            DATA_MODE_ADDR | RET_DAT_ADDR | CAPTR_RAW_ADDR | READOUT_ROW_INDEX_ADDR |
                            READOUT_COL_INDEX_ADDR | READOUT_PRIORITY_ADDR |
                            LED_ADDR |
                            ROW_LEN_ADDR | NUM_ROWS_ADDR | SAMPLE_DLY_ADDR |
                            SAMPLE_NUM_ADDR | FB_DLY_ADDR | ROW_DLY_ADDR |
                            RESYNC_ADDR | FLX_LP_INIT_ADDR | FLTR_RST_ADDR | NUM_COLS_REPORTED_ADDR | NUM_ROWS_REPORTED_ADDR,
    all_cards_err    when   FW_REV_ADDR | CARD_TYPE_ADDR | SCRATCH_ADDR | SLOT_ID_ADDR,
    id_thermo_err    when   CARD_ID_ADDR | CARD_TEMP_ADDR,
    fpga_thermo_err  when   FPGA_TEMP_ADDR,
    '1'              when others;

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
   port map (
      clk_50_i                  => clk,
      clk_25_i                  => spi_clk,
      rst_i                     => rst,
      num_rows_i                => num_rows,
      num_rows_reported_i       => num_rows_reported,
      num_cols_reported_i       => num_cols_reported,
      adc_coadd_en_i            => adc_coadd_en,
      restart_frame_1row_prev_i => restart_frame_1row_prev,
      restart_frame_aligned_i   => restart_frame_aligned,
      restart_frame_1row_post_i => restart_frame_1row_post,
      row_switch_i              => row_switch,
      initialize_window_i       => initialize_window,
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
      adc_ovr_ch0_i             => adc1_ovr,
      adc_ovr_ch1_i             => adc2_ovr,
      adc_ovr_ch2_i             => adc3_ovr,
      adc_ovr_ch3_i             => adc4_ovr,
      adc_ovr_ch4_i             => adc5_ovr,
      adc_ovr_ch5_i             => adc6_ovr,
      adc_ovr_ch6_i             => adc7_ovr,
      adc_ovr_ch7_i             => adc8_ovr,
      adc_rdy_ch0_i             => adc1_rdy,
      adc_rdy_ch1_i             => adc2_rdy,
      adc_rdy_ch2_i             => adc3_rdy,
      adc_rdy_ch3_i             => adc4_rdy,
      adc_rdy_ch4_i             => adc5_rdy,
      adc_rdy_ch5_i             => adc6_rdy,
      adc_rdy_ch6_i             => adc7_rdy,
      adc_rdy_ch7_i             => adc8_rdy,
      adc_clk_ch0_o             => adc1_clk,
      adc_clk_ch1_o             => adc2_clk,
      adc_clk_ch2_o             => adc3_clk,
      adc_clk_ch3_o             => adc4_clk,
      adc_clk_ch4_o             => adc5_clk,
      adc_clk_ch5_o             => adc6_clk,
      adc_clk_ch6_o             => adc7_clk,
      adc_clk_ch7_o             => adc8_clk,
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
   i_MUX_dac: process (sa_bias_dac_spi_ch0, sa_bias_dac_spi_ch1,
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
   generic map( 
      REVISION => RC_REVISION,
      CARD_TYPE=> RC_CARD_TYPE
   )
   port map(
      clk_i     => clk,
      rst_i     => rst,

      dat_i     => dispatch_dat_out,
      addr_i    => dispatch_addr_out,
      tga_i     => dispatch_tga_out,
      we_i      => dispatch_we_out,
      stb_i     => dispatch_stb_out,
      cyc_i     => dispatch_cyc_out,
      slot_id_i => slot_id,
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
      smbalert_i => smb_nalert,
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
