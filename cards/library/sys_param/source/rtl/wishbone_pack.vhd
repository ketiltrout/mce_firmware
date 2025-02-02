-- 2003 SCUBA-2 Project
--                  All Rights Reserved

--  THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF THE SCUBA-2 Project
--  The copyright notice above does not evidence any
--  actual or intended publication of such source code.

--  SOURCE CODE IS PROVIDED "AS IS". ALL EXPRESS OR IMPLIED CONDITIONS,
--  REPRESENTATIONS, AND WARRANTIES, INCLUDING ANY IMPLIED WARRANT OF
--  MERCHANTABILITY, SATISFACTORY QUALITY, FITNESS FOR A PARTICULAR
--  PURPOSE, OR NON-INFRINGEMENT, ARE DISCLAIMED, EXCEPT TO THE EXTENT
--  THAT SUCH DISCLAIMERS ARE HELD TO BE LEGALLY INVALID.

-- For the purposes of this code the SCUBA-2 Project consists of the
-- following organisations.

-- UKATC, Royal Observatory, Blackford Hill Edinburgh EH9 3HJ
-- UBC,   University of British Columbia, Physics & Astronomy Department,
--        Vancouver BC, V6T 1Z1

-- wishbone_pack.vhd
--
-- Project:       SCUBA-2
-- Author:
-- Organisation:      UBC
--
-- Description:
--
--
-- Revision history:
-- <date $Date: 2016/05/19 22:09:39 $> - <initials $Author: mandana $>
-- $Log: wishbone_pack.vhd,v $
-- Revision 1.68  2016/05/19 22:09:39  mandana
-- added flux_fb_dly parameter
--
-- Revision 1.67  2014/12/18 23:25:12  mandana
-- num_idle_rows
--
-- Revision 1.66  2013/05/31 19:55:48  mandana
-- added servo_rst_col and servo_rst_arm
--
-- Revision 1.65  2012-03-26 17:04:26  mandana
-- added bias-card parameters: enbl_flux_fb_mod, enbl_bias_mod, mod_val
--
-- Revision 1.64  2012-01-23 20:33:14  mandana
-- added qterm_decay_bits
--
-- Revision 1.63  2012-01-05 23:10:46  mandana
-- added ramp_phase command
--
-- Revision 1.62  2011-11-07 23:24:35  mandana
-- added critical_error and dev_clr
--
-- Revision 1.61  2010/03/10 00:39:35  bburger
-- BB/MA:  added FLTR_TYPE_ADDR
--
-- Revision 1.60  2010/03/06 01:04:43  mandana
-- changed the comment on sram commands, not to risk losing their space holders
--
-- Revision 1.59  2010/03/05 19:07:27  bburger
-- BB: added the following commands: TMS_TDI_ADDR, TDO_ADDR, TDO_SAMPLE_DLY_ADDR, TCK_HALF_PERIOD_ADDR.
--
-- Revision 1.58  2010/02/26 09:16:09  bburger
-- BB: Removed a couple of unused commands, and added JTAG0_ADDR, JTAG1_ADDR, and JTAG2_ADDR
--
-- Revision 1.57  2010/01/18 20:39:38  bburger
-- BB: Changed "MLS" prefixes to "AWG" for "Abitrary Waveform Generator"
--
-- Revision 1.56  2010/01/13 20:28:43  bburger
-- BB: added the following commands: MLS_SEQUENCE_LEN, MLS_DATA, MLS_ADDR
--
-- Revision 1.55  2009/11/13 19:10:59  bburger
-- BB:  Added the I_CLAMP_VAL_ADDR parameter
--
-- Revision 1.54  2009/10/09 16:46:58  bburger
-- BB: Added
-- - HEATER_BIAS_ADDR
-- - HEATER_BIAS_LEN_ADDR
--
-- Revision 1.53  2009/09/16 18:56:18  bburger
-- BB:  Added a couple of redundant command names to make the latest file compatible with older versions of 4.x.x- firmware
--
-- Revision 1.52  2009/09/14 19:52:35  bburger
-- BB: added BIAS_START_ADDR for row-specific bias delays
--
-- Revision 1.51  2009/01/16 01:59:52  bburger
-- BB: Renamed num_rows_reported, and added num_cols_reported
--
-- Revision 1.50  2008/12/22 20:30:48  bburger
-- BB:  Added new commands to support reading out columns of data.
--
-- Revision 1.49  2008/10/25 00:25:23  bburger
-- BB:  Added RCS_TO_REPORT_DATA_ADDR
--
-- Revision 1.48  2008/10/24 23:55:11  bburger
-- BB: Renamed RET_DAT_CARD_ADDR_ADDR to RCS_TO_REPORT_ADDR
--
-- Revision 1.47  2008/08/13 20:53:21  bburger
-- BB:  Added STOP_DLY_ADDR command
--
-- Revision 1.46  2008/06/17 19:07:42  bburger
-- BB:  Added the const_val39 command, for ac_v02000007
--
-- Revision 1.46  2008/06/12 21:44:21  bburger
-- BB:  Added the const_val39 command, for ac_v02000007
--
-- Revision 1.45  2008/05/29 21:23:40  bburger
-- BB:  added const_mode_addr and const_val_addr constants
--
-- Revision 1.44  2008/02/03 09:53:26  bburger
-- BB:  Added parameter id's for the following commands:  CARDS_PRESENT_ADDR, CARDS_TO_REPORT_ADDR, SRAM_ADDR_ADDR, RCS_TO_REPORT_ADDR
--
-- Revision 1.43  2008/01/26 01:15:59  mandana
-- added scratch!
--
-- Revision 1.42  2008/01/21 19:43:06  bburger
-- BB:  Added the parameter IDs for fb_col0 through fb_col40 for the sq2fb multiplexing
--
-- Revision 1.41  2007/12/19 20:50:26  mandana
-- added flux_fb_upper, sa_htr0/1
--
-- Revision 1.40  2007/09/20 20:02:47  bburger
-- BB:  Now supports commands to the following param_id's (for the data frame header):
-- - RUN_ID_ADDR
-- - USER_WRITABLE_ADDR
--
-- Revision 1.39  2007/08/28 23:48:43  bburger
-- BB: added interface signals to support the following commands:
-- constant READOUT_ROW_INDEX_ADDR  : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"13";
-- constant NUM_ROWS_TO_READ_ADDR   : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"55";
-- constant INTERNAL_CMD_MODE_ADDR  : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"B0";
-- constant RAMP_STEP_PERIOD_ADDR   : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"B1";
-- constant RAMP_MIN_VAL_ADDR       : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"B2";
-- constant RAMP_STEP_SIZE_ADDR     : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"B3";
-- constant RAMP_MAX_VAL_ADDR       : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"B4";
-- constant RAMP_PARAM_ID_ADDR      : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"B5";
-- constant RAMP_CARD_ADDR_ADDR     : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"B6";
-- constant RAMP_STEP_DATA_NUM_ADDR : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"B7";
--
-- Revision 1.38  2007/08/28 19:59:27  bburger
-- Bryce:  Added parameters to support:
-- - Reading data from less than 41 rows
-- - Starting data readings at an arbitrary row
-- - Specifying ramp parameters on the Clock Card.
--
-- Revision 1.37  2007/07/25 19:25:17  bburger
-- BB:  Added MCE_BCLR_ADDR and CC_BCLR_ADDR
--
-- Revision 1.36  2007/01/08 21:40:22  mandana
-- changed SRAM_WRITE_ADDR to SRAM_DATA_ADDR
--
-- Revision 1.35  2006/11/14 22:41:12  bburger
-- Bryce:  updated some of the commands to the SRAM for use with the JTAG programmer
--
-- Revision 1.34  2006/11/03 23:15:58  bburger
-- Bryce:  New commands for remote JTAG configuration
--
-- Revision 1.33  2006/10/19 22:13:09  bburger
-- Bryce:  Added the crc_err_en command
--
-- Revision 1.32  2006/09/28 00:34:58  bburger
-- Bryce:  added a command for box_temp
--
-- Revision 1.31  2006/09/21 16:20:22  bburger
-- Bryce:  added constants for TES Bias internal commands
--
-- Revision 1.30  2006/08/01 18:33:43  bburger
-- Bryce:  Added new PSU commands
--
-- Revision 1.29  2006/06/19 17:28:24  bburger
-- Bryce:  added a new command called SELECT_CLK_ADDR
--
-- Revision 1.28  2006/04/26 22:41:25  bburger
-- *** empty log message ***
--
-- Revision 1.27  2006/03/02 19:00:34  bburger
-- Bryce:  branched to implement up-to-date definitions for the slot_id for revC of the bus backplane
--
-- Revision 1.26  2006/02/09 20:32:59  bburger
-- Bryce:
-- - Added a fltr_rst_o output signal from the frame_timing block
-- - Adjusted the top-levels of each card to reflect the frame_timing interface change
--
-- Revision 1.25  2005/09/15 20:59:44  bburger
-- bburger:
-- Integrated flux-jumping into flux_loop
--
-- Revision 1.24  2005/03/31 01:08:19  bburger
-- Bryce:  removed the row_map command from the address card
--
-- Revision 1.23  2005/03/19 00:31:23  bburger
-- bryce:  Fixed several bugs.  Tagging cc_01010007.
--
-- Revision 1.22  2005/02/22 18:17:14  bburger
-- Bryce:  removed the redundant fmsr_vsn command
--
-- Revision 1.21  2005/02/21 18:51:18  mandana
-- changed fw_rev command
--
-- Revision 1.20  2005/02/20 00:11:50  bburger
-- Bryce:  added firmware version command (fmwr_vsn)
--
-- Revision 1.19  2004/11/17 01:57:32  bburger
-- Bryce :  updating the interface signal order
--
-- Revision 1.18  2004/11/16 08:54:04  bburger
-- Bryce :  updated to match the mce1_1.xml file
--
-- Revision 1.17  2004/11/04 00:08:18  bburger
-- Bryce:  small updates
--
-- Revision 1.16  2004/10/15 16:03:43  dca
-- CAPTR_RAW_ADDR definition added
--
-- Revision 1.15  2004/10/12 22:45:23  erniel
-- added LED_ADDR
--
-- Revision 1.14  2004/09/24 02:00:26  erniel
-- removed redundancy with command_pack
--
-- Revision 1.13  2004/08/31 21:53:03  bburger
-- Bryce:  added the 'DATA' command type
--
-- Revision 1.12  2004/08/26 18:10:03  erniel
-- added command_type field declarations
--
-- Revision 1.11  2004/08/19 20:37:04  bburger
-- Bryce:  moded data_mode
--
-- Revision 1.10  2004/08/19 20:06:10  bburger
-- Bryce:  changed a parameter name
--
-- Revision 1.9  2004/08/19 19:54:21  bburger
-- Bryce:  added new parameter ids, and moved some around that didn't belong in a category
--
-- Revision 1.8  2004/07/29 00:39:30  bench2
-- Bryce: added new constants
--
-- Revision 1.7  2004/07/29 00:29:01  mandana
-- added MUX_ON/MUX_OFF default values
--
-- Revision 1.6  2004/07/20 21:45:44  erniel
-- changed ALL_FBGA_CARDS to ALL_FPGA_CARDS
--
-- Revision 1.5  2004/05/31 21:24:04  bburger
-- in progress
--
-- Revision 1.4  2004/05/25 21:25:57  bburger
-- compile error
--
-- Revision 1.3  2004/05/14 21:39:07  bburger
-- added card addresses
--
-- Revision 1.2  2004/04/21 19:50:01  bburger
-- Added slave addresses for all current instructions
--
-- Revision 1.1  2004/04/14 21:56:40  jjacob
-- new directory structure
--
-- Revision 1.7  2004/04/06 23:45:32  jjacob
-- changed EEPROM_ADDR to 0x43, and CARD_ID to 0xFF
--
-- Revision 1.5  2004/04/02 19:44:40  bburger
-- changed constant values from binary to hex
--
-- Revision 1.4  2004/04/02 17:17:40  mandana
-- Added new wishbone addresses for Bias card/dac_ctrl
-- Added header
--
--
--
library ieee;
use ieee.std_logic_1164.all;

library sys_param;
use sys_param.command_pack.all;

package wishbone_pack is
   --
   -- unassigned parameter-id:0c-0f, 2A-2F, 38-3F, 40, 42, 47-4f, 9d-9f, e9-ef, f9-ff 
   -- preferably set aside E9-EF for AC, 29-2F for BC, 38-3F for system, f9-ff for rc
   --
  ---------------------------------------------------------------------------------
   -- Wishbone bus widths
   ---------------------------------------------------------------------------------
   constant WB_ADDR_WIDTH     : integer := BB_PARAMETER_ID_WIDTH;
   constant WB_DATA_WIDTH     : integer := 32;
   constant WB_TAG_ADDR_WIDTH : integer := 32;

   ---------------------------------------------------------------------------------
   -- Wishbone Parameter IDs
   ---------------------------------------------------------------------------------
   -- Null Address
   constant NULL_ADDR               : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"00";

   ---------------------------------------------------------------------------------------
   -- Address Card Specific Parameter IDs
   ---------------------------------------------------------------------------------------
   constant ROW_ORDER_ADDR          : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"01";
   constant ON_BIAS_ADDR            : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"02";
   constant OFF_BIAS_ADDR           : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"03";
   constant ENBL_MUX_ADDR           : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"05";
   constant CONST_MODE_ADDR         : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"06";
   constant CONST_VAL_ADDR          : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"07";
   constant CONST_VAL39_ADDR        : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"08";
   constant BIAS_START_ADDR         : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"09";
   constant HEATER_BIAS_ADDR        : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"0A";
   constant HEATER_BIAS_LEN_ADDR    : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"0B";
   ---------------------------------------------------------------------------------------
   -- Address Card Specific Parameter IDs
   -- Do not change addresses in the following block because the AC uses the fact that they
   -- are contiguous to simplify the written code.
   ---------------------------------------------------------------------------------------
   constant FB_COL0_ADDR            : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"C0";
   constant FB_COL1_ADDR            : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"C1";
   constant FB_COL2_ADDR            : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"C2";
   constant FB_COL3_ADDR            : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"C3";
   constant FB_COL4_ADDR            : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"C4";
   constant FB_COL5_ADDR            : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"C5";
   constant FB_COL6_ADDR            : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"C6";
   constant FB_COL7_ADDR            : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"C7";
   constant FB_COL8_ADDR            : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"C8";
   constant FB_COL9_ADDR            : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"C9";
   constant FB_COL10_ADDR           : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"CA";
   constant FB_COL11_ADDR           : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"CB";
   constant FB_COL12_ADDR           : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"CC";
   constant FB_COL13_ADDR           : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"CD";
   constant FB_COL14_ADDR           : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"CE";
   constant FB_COL15_ADDR           : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"CF";
   constant FB_COL16_ADDR           : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"D0";
   constant FB_COL17_ADDR           : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"D1";
   constant FB_COL18_ADDR           : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"D2";
   constant FB_COL19_ADDR           : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"D3";
   constant FB_COL20_ADDR           : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"D4";
   constant FB_COL21_ADDR           : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"D5";
   constant FB_COL22_ADDR           : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"D6";
   constant FB_COL23_ADDR           : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"D7";
   constant FB_COL24_ADDR           : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"D8";
   constant FB_COL25_ADDR           : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"D9";
   constant FB_COL26_ADDR           : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"DA";
   constant FB_COL27_ADDR           : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"DB";
   constant FB_COL28_ADDR           : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"DC";
   constant FB_COL29_ADDR           : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"DD";
   constant FB_COL30_ADDR           : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"DE";
   constant FB_COL31_ADDR           : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"DF";
   constant FB_COL32_ADDR           : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"E0";
   constant FB_COL33_ADDR           : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"E1";
   constant FB_COL34_ADDR           : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"E2";
   constant FB_COL35_ADDR           : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"E3";
   constant FB_COL36_ADDR           : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"E4";
   constant FB_COL37_ADDR           : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"E5";
   constant FB_COL38_ADDR           : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"E6";
   constant FB_COL39_ADDR           : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"E7";
   constant FB_COL40_ADDR           : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"E8";   
   ---------------------------------------------------------------------------------------

   ---------------------------------------------------------------------------------------
   -- Readout Card Specific Parameter IDs
   ---------------------------------------------------------------------------------------
   constant SA_BIAS_ADDR            : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"10";
   constant OFFSET_ADDR             : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"11";
   constant COL_MAP_ADDR            : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"12";
   constant READOUT_ROW_INDEX_ADDR  : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"13";
   constant FLTR_RST_ADDR           : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"14"; -- RCS
   constant EN_FB_JUMP_ADDR         : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"15"; -- RCS
   constant RET_DAT_ADDR            : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"16"; -- RCS
   constant DATA_MODE_ADDR          : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"17"; -- RCS
   constant CAPTR_RAW_ADDR          : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"18"; -- RCS
   constant READOUT_COL_INDEX_ADDR  : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"19";
   constant FILT_COEF_ADDR          : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"1A"; -- RCS
   constant SERVO_MODE_ADDR         : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"1B"; -- RCS
   constant RAMP_DLY_ADDR           : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"1C"; -- RCS
   constant RAMP_AMP_ADDR           : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"1D"; -- RCS
   constant RAMP_STEP_ADDR          : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"1E"; -- RCS
   constant FB_CONST_ADDR           : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"1F"; -- RCS

   constant QTERM_DECAY_ADDR        : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"64"; -- RCS   
   constant FLTR_TYPE_ADDR          : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"65"; -- RCS
   constant I_CLAMP_VAL_ADDR        : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"66"; -- RCS
   constant READOUT_PRIORITY_ADDR   : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"67"; -- Obsolete.
   constant ADC_OFFSET0_ADDR        : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"68";
   constant ADC_OFFSET1_ADDR        : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"69";
   constant ADC_OFFSET2_ADDR        : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"6A";
   constant ADC_OFFSET3_ADDR        : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"6B";
   constant ADC_OFFSET4_ADDR        : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"6C";
   constant ADC_OFFSET5_ADDR        : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"6D";
   constant ADC_OFFSET6_ADDR        : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"6E";
   constant ADC_OFFSET7_ADDR        : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"6F";
   constant GAINP0_ADDR             : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"70";
   constant GAINP1_ADDR             : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"71";
   constant GAINP2_ADDR             : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"72";
   constant GAINP3_ADDR             : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"73";
   constant GAINP4_ADDR             : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"74";
   constant GAINP5_ADDR             : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"75";
   constant GAINP6_ADDR             : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"76";
   constant GAINP7_ADDR             : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"77";
   constant GAINI0_ADDR             : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"78";
   constant GAINI1_ADDR             : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"79";
   constant GAINI2_ADDR             : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"7A";
   constant GAINI3_ADDR             : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"7B";
   constant GAINI4_ADDR             : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"7C";
   constant GAINI5_ADDR             : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"7D";
   constant GAINI6_ADDR             : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"7E";
   constant GAINI7_ADDR             : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"7F";
   constant FLX_QUANTA0_ADDR        : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"80";
   constant FLX_QUANTA1_ADDR        : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"81";
   constant FLX_QUANTA2_ADDR        : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"82";
   constant FLX_QUANTA3_ADDR        : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"83";
   constant FLX_QUANTA4_ADDR        : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"84";
   constant FLX_QUANTA5_ADDR        : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"85";
   constant FLX_QUANTA6_ADDR        : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"86";
   constant FLX_QUANTA7_ADDR        : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"87";
   constant GAIND0_ADDR             : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"88";
   constant GAIND1_ADDR             : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"89";
   constant GAIND2_ADDR             : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"8A";
   constant GAIND3_ADDR             : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"8B";
   constant GAIND4_ADDR             : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"8C";
   constant GAIND5_ADDR             : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"8D";
   constant GAIND6_ADDR             : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"8E";
   constant GAIND7_ADDR             : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"8F";
   constant SERVO_RST_COL0_ADDR     : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"F0";
   constant SERVO_RST_COL1_ADDR     : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"F1";
   constant SERVO_RST_COL2_ADDR     : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"F2";
   constant SERVO_RST_COL3_ADDR     : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"F3";
   constant SERVO_RST_COL4_ADDR     : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"F4";
   constant SERVO_RST_COL5_ADDR     : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"F5";
   constant SERVO_RST_COL6_ADDR     : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"F6";
   constant SERVO_RST_COL7_ADDR     : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"F7";
   constant SERVO_RST_ARM_ADDR      : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"F8";

   ---------------------------------------------------------------------------------------
   -- Bias Card Specific Parameter IDs
   ---------------------------------------------------------------------------------------
   constant FLUX_FB_ADDR            : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"20";
   constant BIAS_ADDR               : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"21";
   constant SA_HTR0_ADDR            : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"22";
   constant SA_HTR1_ADDR            : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"23";
   constant FLUX_FB_UPPER_ADDR      : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"24";
   constant ENBL_FLUX_FB_MOD_ADDR   : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"25";
   constant ENBL_BIAS_MOD_ADDR      : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"26";
   constant MOD_VAL_ADDR            : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"27";
   constant BC_NUM_IDLE_ROWS_ADDR   : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"28";
   constant FLUX_FB_DLY_ADDR        : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"29";

   ---------------------------------------------------------------------------------------
   -- System (All FPGA Cards) Parameter IDs
   ---------------------------------------------------------------------------------------
   constant ROW_LEN_ADDR            : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"30";
   constant NUM_ROWS_ADDR           : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"31";
   constant SAMPLE_DLY_ADDR         : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"32";
   constant SAMPLE_NUM_ADDR         : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"33";
   constant FB_DLY_ADDR             : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"34";
   constant ROW_DLY_ADDR            : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"35"; -- obsolete
   constant RESYNC_ADDR             : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"36"; -- obsolete?? check
   constant FLX_LP_INIT_ADDR        : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"37";

   ---------------------------------------------------------------------------------------
   -- Any FPGA Card Parameter IDs
   ---------------------------------------------------------------------------------------
   constant RST_WTCHDG_ADDR         : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"41";
   constant EEPROM_ADDR             : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"43";
   constant VFY_EEPROM_ADDR         : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"44";
   constant CLR_ERROR_ADDR          : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"45";
   constant EEPROM_SRT_ADDR         : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"46";
   constant BIT_STATUS_ADDR         : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"90"; -- obsolete
   constant FPGA_TEMP_ADDR          : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"91";
   constant CARD_TEMP_ADDR          : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"92";
   constant CARD_ID_ADDR            : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"93";
   constant CARD_TYPE_ADDR          : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"94";
   constant SLOT_ID_ADDR            : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"95";
   constant FW_REV_ADDR             : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"96";
   constant DIP_ADDR                : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"97";
   constant CYC_OO_SYC_ADDR         : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"98";
   constant LED_ADDR                : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"99";
   constant SCRATCH_ADDR            : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"9A";
   constant CRIT_ERR_RST_ADDR       : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"9B"; 
   constant DEV_CLR_ADDR            : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"9C";-- fpga_clr

   ---------------------------------------------------------------------------------------
   -- Clock Card Specific Parameter IDs
   ---------------------------------------------------------------------------------------
   constant CONFIG_FAC_ADDR         : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"51";
   constant CONFIG_APP_ADDR         : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"52";
   constant RET_DAT_S_ADDR          : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"53";
   constant USE_DV_ADDR             : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"54";
   constant NUM_ROWS_TO_READ_ADDR   : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"55"; -- Obsolete.  Replaced by NUM_ROWS_REPORTED_ADDR
   constant NUM_ROWS_REPORTED_ADDR  : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"55";
   constant RUN_ID_ADDR             : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"56";
   constant USER_WRITABLE_ADDR      : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"57";
   constant ARRAY_ID_ADDR           : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"58";
   constant BOX_ID_ADDR             : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"59";
   constant CARDS_PRESENT_ADDR      : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"5A";
   constant CARDS_TO_REPORT_ADDR    : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"5B";
   constant SRAM_DATA_ADDR          : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"5C"; -- used by sram_ctrl block!
   constant SRAM_ADDR_ADDR          : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"5E"; -- used by sram_ctrl block!
   constant RET_DAT_CARD_ADDR_ADDR  : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"5F"; -- Obsolete.  Replaced by RCS_TO_REPORT_DATA_ADDR
   constant RCS_TO_REPORT_DATA_ADDR : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"5F";
   constant DATA_RATE_ADDR          : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"A0";
   constant USE_SYNC_ADDR           : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"A1";
   constant SELECT_CLK_ADDR         : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"A2";
   -- Obsolete ---------------------------------------------------------------------------
   constant RET_DAT_REQ_ADDR        : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"5D"; -- Obsolete
   constant TES_TGL_EN_ADDR         : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"A3"; -- Obsolete
   constant TES_TGL_MAX_ADDR        : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"A4"; -- Obsolete
   constant TES_TGL_MIN_ADDR        : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"A5"; -- Obsolete
   constant TES_TGL_RATE_ADDR       : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"A6"; -- Obsolete
   constant INT_CMD_EN_ADDR         : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"A7"; -- Obsolete
   -- Obsolete ---------------------------------------------------------------------------
   constant BOX_TEMP_ADDR           : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"A8";
   constant CRC_ERR_EN_ADDR         : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"A9";
   constant MCE_BCLR_ADDR           : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"AB";
   constant CC_BCLR_ADDR            : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"AC";
   constant NUM_COLS_REPORTED_ADDR  : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"AD";
   constant INTERNAL_CMD_MODE_ADDR  : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"B0";   
   -- Certain "RAMP" parameters also apply to the MLS internal command mode..
   constant RAMP_STEP_PERIOD_ADDR   : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"B1"; -- Applies to MLS too
   constant RAMP_MIN_VAL_ADDR       : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"B2";
   constant RAMP_STEP_SIZE_ADDR     : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"B3";
   constant RAMP_MAX_VAL_ADDR       : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"B4";
   constant RAMP_PARAM_ID_ADDR      : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"B5"; -- Applies to MLS too
   constant RAMP_CARD_ADDR_ADDR     : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"B6"; -- Applies to MLS too
   constant RAMP_STEP_DATA_NUM_ADDR : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"B7"; -- Applies to MLS too   
   constant RAMP_PHASE_ADDR         : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"BB"; -- Applies to MLS too
   constant STOP_DLY_ADDR           : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"B8";   
   constant AWG_SEQUENCE_LEN_ADDR   : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"B9";
   constant AWG_DATA_ADDR           : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"BA";
   constant AWG_ADDR_ADDR           : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"BC";   
   -- JTAG Commands - Emulate a parallel port
   constant JTAG0_ADDR              : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"BD"; -- Output data
   constant JTAG1_ADDR              : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"BE"; -- Input data
   constant JTAG2_ADDR              : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"BF"; -- JTAG Chain control   
   -- JTAG Commands - These solve the "packing problem," aka the "encoding enigma."
   constant TMS_TDI_ADDR            : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"50";
   constant TDO_ADDR                : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"AA";
   constant TDO_SAMPLE_DLY_ADDR     : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"AE";
   constant TCK_HALF_PERIOD_ADDR    : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"AF";

   ---------------------------------------------------------------------------------------
   -- Power Card Specific Parameter IDs
   ---------------------------------------------------------------------------------------
   constant BRST_MCE_ADDR           : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"60";
   constant CYCLE_POW_ADDR          : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"61";
   constant CUT_POW_ADDR            : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"62";
   constant PSC_STATUS_ADDR         : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"63";

   ---------------------------------------------------------------------------------
   -- Instruction Parameters Default values
   ---------------------------------------------------------------------------------
   constant MUX_ON                  : std_logic_vector(7 downto 0) := x"FF";
   constant MUX_OFF                 : std_logic_vector(7 downto 0) := x"00";

end wishbone_pack;