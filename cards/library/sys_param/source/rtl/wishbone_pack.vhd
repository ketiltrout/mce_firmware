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
-- <date $Date: 2004/09/24 02:00:26 $> - <initials $Author: erniel $>
-- $Log: wishbone_pack.vhd,v $
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
   constant NULL_ADDR         : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"00";
   
   -- Address Card Specific
   constant ON_BIAS_ADDR      : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"02";
   constant OFF_BIAS_ADDR     : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"03";
   constant ROW_MAP_ADDR      : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"04";
   constant SWTCH_DLY_ADDR    : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"05";
   constant ACTV_ROW_ADDR     : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"06";
   constant STRT_MUX_ADDR     : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"07";

   -- Readout Card Specific
   constant FST_ST_FB_ADDR    : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"10";
   constant SA_BIAS_ADDR      : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"11";
   constant OFFSET_ADDR       : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"12";
   constant FILT_COEF_ADDR    : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"13";
   constant COL_MAP_ADDR      : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"14";
   constant ENBL_SERVO_ADDR   : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"15";
   constant COL_ENBL_ADDR     : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"16";
   constant SAMP_DLY_ADDR     : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"17";
   constant SAMP_NUM_ADDR     : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"18";
   constant FB_DLY_ADDR       : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"1A";
   constant RAMP_DLY_ADDR     : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"1B";
   constant RAMP_AMP_ADDR     : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"1C";
   constant FB_CONST_ADDR     : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"1D";

   constant GAINP0_ADDR       : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"70";
   constant GAINP1_ADDR       : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"71";
   constant GAINP2_ADDR       : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"72";
   constant GAINP3_ADDR       : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"73";
   constant GAINP4_ADDR       : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"74";
   constant GAINP5_ADDR       : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"75";
   constant GAINP6_ADDR       : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"76";
   constant GAINP7_ADDR       : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"77";
   constant GAINI0_ADDR       : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"78";
   constant GAINI1_ADDR       : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"79";
   constant GAINI2_ADDR       : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"7A";
   constant GAINI3_ADDR       : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"7B";
   constant GAINI4_ADDR       : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"7C";
   constant GAINI5_ADDR       : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"7D";
   constant GAINI6_ADDR       : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"7E";
   constant GAINI7_ADDR       : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"7F";
   constant ZERO0_ADDR        : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"80";
   constant ZERO1_ADDR        : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"81";
   constant ZERO2_ADDR        : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"82";
   constant ZERO3_ADDR        : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"83";
   constant ZERO4_ADDR        : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"84";
   constant ZERO5_ADDR        : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"85";
   constant ZERO6_ADDR        : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"86";
   constant ZERO7_ADDR        : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"87";
   constant GAIND0_ADDR       : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"88";
   constant GAIND1_ADDR       : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"89";
   constant GAIND2_ADDR       : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"8A";
   constant GAIND3_ADDR       : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"8B";
   constant GAIND4_ADDR       : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"8C";
   constant GAIND5_ADDR       : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"8D";
   constant GAIND6_ADDR       : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"8E";
   constant GAIND7_ADDR       : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"8F";
   
   -- Bias Card Specific
   constant FLUX_FB_ADDR      : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"20";
   constant BIAS_ADDR         : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"21";

   -- All FPGA Cards
   constant RET_DAT_ADDR      : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"30";
   constant DATA_MODE_ADDR    : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"31";
   constant ROW_ORDER_ADDR    : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"33";
   constant RET_DAT_S_ADDR    : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"34";
   constant USE_DV_ADDR       : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"37";

   -- Any FPGA Card
   constant STATUS_ADDR       : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"40";
   constant RST_WTCHDG_ADDR   : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"41";
   constant RST_REG_ADDR      : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"42";
   constant EEPROM_ADDR       : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"43";
   constant VFY_EEPROM_ADDR   : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"44";
   constant CLR_ERROR_ADDR    : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"45";
   constant EEPROM_SRT_ADDR   : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"46";
   constant RESYNC_ADDR       : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"48";

   constant BIT_STATUS_ADDR   : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"90";
   constant FPGA_TEMP_ADDR    : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"91";
   constant CARD_TEMP_ADDR    : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"92";
   constant CARD_ID_ADDR      : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"93";
   constant CARD_TYPE_ADDR    : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"94";
   constant SLOT_ID_ADDR      : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"95";
   constant FMWR_VRSN_ADDR    : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"96";
   constant DIP_ADDR          : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"97";
   constant CYC_OO_SYC_ADDR   : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"98";

   -- Clock Card Specific
   constant CONFIG_S_ADDR     : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"50";
   constant CONFIG_ADDR       : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"51";
   constant ARRAY_ID_ADDR     : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"52";
   constant BOX_ID_ADDR       : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"53";
   constant APP_CONFIG_ADDR   : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"54";
   constant SRAM1_ADDR        : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"55";
   constant VRFY_SRAM1_ADDR   : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"56";
   constant SRAM2_ADDR        : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"57";
   constant VRFY_SRAM2_ADDR   : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"58";
   constant FAC_CONFIG_ADDR   : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"59";
   constant SRAM1_CONT_ADDR   : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"5A";
   constant SRAM2_CONT_ADDR   : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"5B";
   constant SRAM1_STRT_ADDR   : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"5C";
   constant SRAM2_STRT_ADDR   : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"5D";

   -- Power Card Specific
   constant PSC_STATUS_ADDR   : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"60";
   constant BRST_ADDR         : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"61";
   constant PSC_RST_ADDR      : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"62";
   constant PSC_OFF_ADDR      : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"63";
   
   
   ---------------------------------------------------------------------------------
   -- Instruction Parameters Default values
   constant MUX_ON           : std_logic_vector(7 downto 0) := x"FF";
   constant MUX_OFF          : std_logic_vector(7 downto 0) := x"00";

end wishbone_pack;