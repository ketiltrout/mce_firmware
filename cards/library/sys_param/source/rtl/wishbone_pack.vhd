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
-- Project:	      SCUBA-2
-- Author:	      
-- Organisation:      UBC
--
-- Description:
-- 
-- 
-- Revision history:
-- <date $Date: 2004/04/06 23:45:32 $>	- <initials $Author: jjacob $>
-- $Log: wishbone_pack.vhd,v $
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

   -- Wishbone addresses
   constant FLUX_FB_ADDR     : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"20"; -- 0x20 
   constant BIAS_ADDR        : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"21"; -- 0x21 
   constant SLOT_ID_ADDR     : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"40"; -- 0x40 
   constant TEMPERATURE_ADDR : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"42"; -- 0x42
   
   constant EEPROM_ADDR      : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"43"; -- 0x43
   constant LEDS_ADDR        : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"45"; -- 0x45
   constant CYC_OUT_SYNC_ADDR: std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"47"; -- 0x47
   constant RESYNC_NXT_ADDR  : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"48"; -- 0x48
   constant ARRAY_ID_ADDR    : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"49"; -- 0x49
   
   constant DIP_ADDR         : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"4C"; -- 0x4C
   constant WATCHDOG_ADDR    : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"4D"; -- 0x4D
   constant SRAM_VERIFY_ADDR : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"50"; -- 0x50
   constant SRAM_ADDR        : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"56"; -- 0x56
   
   constant CARD_ID_ADDR     : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"FF"; -- 0xFF  --NEEDS TO BE RESOLVED
   

    
-- OBSOLETE from here....
  
--   -- SlotID wishbone interface
--   constant SLOT_ID_DATA_WIDTH	: integer := DEF_WB_DATA_WIDTH;
--   constant SLOT_ID_ADDR_WIDTH : integer := DEF_WB_ADDR_WIDTH;
--   
--   -- ArrayID wishbone interface
--   constant ARRAY_ID_DATA_WIDTH	: integer := DEF_WB_DATA_WIDTH;
--   constant ARRAY_ID_ADDR_WIDTH : integer := DEF_WB_ADDR_WIDTH;
--   
--   -- CardID wishbone interface
--   constant CARD_ID_DATA_WIDTH	: integer := DEF_WB_DATA_WIDTH;
--   constant CARD_ID_ADDR_WIDTH : integer := DEF_WB_ADDR_WIDTH;
--   
--   -- LEDs wishbone interface
--   constant LEDS_DATA_WIDTH : integer := DEF_WB_DATA_WIDTH;
--   constant LEDS_ADDR_WIDTH : integer := DEF_WB_ADDR_WIDTH;
--   
--   -- DIP Switch wishbone interface
--   constant DIP_DATA_WIDTH : integer := DEF_WB_DATA_WIDTH;
--   constant DIP_ADDR_WIDTH : integer := DEF_WB_ADDR_WIDTH;
--   
--   -- Watchdog wishbone interface
--   constant WATCHDOG_DATA_WIDTH : integer := DEF_WB_DATA_WIDTH;
--   constant WATCHDOG_ADDR_WIDTH : integer := DEF_WB_ADDR_WIDTH;   
--
--   -- The logical length of command code field.  8 bits allows for 256 command codes.
--   constant ADDR_LENGTH : integer := 8;
   
   
-- ...to here!
   
end wishbone_pack;