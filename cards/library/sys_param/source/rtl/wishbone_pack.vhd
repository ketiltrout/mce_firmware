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
-- <date $Date: 2004/05/25 21:25:57 $> - <initials $Author: bburger $>
-- $Log: wishbone_pack.vhd,v $
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

package wishbone_pack is

   -- Wishbone bus widths
   constant WB_DATA_WIDTH     : integer := 32;
   constant WB_ADDR_WIDTH     : integer := 8;
   constant WB_TAG_ADDR_WIDTH : integer := 32;
   constant CARD_ADDR_WIDTH   : integer := 8;

   ---------------------------------------------------------------------------------
   -- Status Fields
   ---------------------------------------------------------------------------------
   constant SUCCESS        : std_logic_vector(7 downto 0) := "11111111";
   constant FAIL           : std_logic_vector(7 downto 0) := "00000000";

   ---------------------------------------------------------------------------------
   -- Card Addresses
   ---------------------------------------------------------------------------------
   constant NO_CARDS       : std_logic_vector(CARD_ADDR_WIDTH-1 downto 0) := x"00";
   constant PSC            : std_logic_vector(CARD_ADDR_WIDTH-1 downto 0) := x"01";
   constant CC             : std_logic_vector(CARD_ADDR_WIDTH-1 downto 0) := x"02";
   constant RC1            : std_logic_vector(CARD_ADDR_WIDTH-1 downto 0) := x"03";
   constant RC2            : std_logic_vector(CARD_ADDR_WIDTH-1 downto 0) := x"04";
   constant RC3            : std_logic_vector(CARD_ADDR_WIDTH-1 downto 0) := x"05";
   constant RC4            : std_logic_vector(CARD_ADDR_WIDTH-1 downto 0) := x"06";
   constant BC1            : std_logic_vector(CARD_ADDR_WIDTH-1 downto 0) := x"07";
   constant BC2            : std_logic_vector(CARD_ADDR_WIDTH-1 downto 0) := x"08";
   constant BC3            : std_logic_vector(CARD_ADDR_WIDTH-1 downto 0) := x"09";
   constant AC             : std_logic_vector(CARD_ADDR_WIDTH-1 downto 0) := x"0A";
   constant RCS            : std_logic_vector(CARD_ADDR_WIDTH-1 downto 0) := x"0B";
   constant BCS            : std_logic_vector(CARD_ADDR_WIDTH-1 downto 0) := x"0C";
   constant ALL_FBGA_CARDS : std_logic_vector(CARD_ADDR_WIDTH-1 downto 0) := x"0D";
   constant ALL_CARDS      : std_logic_vector(CARD_ADDR_WIDTH-1 downto 0) := x"0E";

   ---------------------------------------------------------------------------------
   -- Wishbone Parameter IDs
   ---------------------------------------------------------------------------------
   -- Address Card Specific
   constant ON_BIAS_ADDR      : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"02";
   constant OFF_BIAS_ADDR     : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"03";
   constant ROW_MAP_ADDR      : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"04";

   -- Readout Card Specific
   constant FST_ST_FB_ADDR    : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"10";
   constant SA_BIAS_ADDR      : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"11";
   constant OFFSET_ADDR       : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"12";
   constant FILT_COEF_ADDR    : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"13";
   constant COL_MAP_ADDR      : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"14";
   constant ENBL_SERVO_ADDR   : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"15";
   constant COL_ENBL_ADDR     : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"16";

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

   -- Bias Card Specific
   constant FLUX_FB_ADDR      : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"20";
   constant BIAS_ADDR         : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"21";

   -- System
   constant RET_DAT_ADDR      : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"30";
   constant DATA_MODE_ADDR    : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"31";
   constant STRT_MUX_ADDR     : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"32";
   constant ROW_ORDER_ADDR    : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"33";
   constant RET_DAT_S_ADDR    : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"34";
   constant DBL_BUFF_ADDR     : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"35";
   constant ACTV_ROW_ADDR     : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"36";
   constant USE_DV_ADDR       : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"37";

   -- Any Card
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

end wishbone_pack;