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
-- $Id: addr_card_pack.vhd,v 1.2 2004/12/08 22:15:12 bburger Exp $
--
-- Project:       SCUBA-2
-- Author:        Bryce Burger
-- Organization:  UBC
--
-- Description:
-- 
--
-- Revision history:
-- $Log: addr_card_pack.vhd,v $
-- Revision 1.2  2004/12/08 22:15:12  bburger
-- Bryce:  changed the usage of PLLs in the top levels of clk and addr cards
--
-- Revision 1.1  2004/12/06 07:22:34  bburger
-- Bryce:
-- Created pack files for the card top-levels.
-- Added some simulation signals to the top-levels (i.e. clocks)
--
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package addr_card_pack is

component addr_card
   port(
      -- PLL input:
      inclk      : in std_logic;
      rst_n      : in std_logic;
      
      -- LVDS interface:
      lvds_cmd   : in std_logic;
      lvds_sync  : in std_logic;
      lvds_spare : in std_logic;
      lvds_txa   : out std_logic;
      lvds_txb   : out std_logic;
      
      -- TTL interface:
      ttl_nrx1   : in std_logic;
      ttl_tx1    : out std_logic;
      ttl_txena1 : out std_logic;
      
      ttl_nrx2   : in std_logic;
      ttl_tx2    : out std_logic;
      ttl_txena2 : out std_logic;
      
      ttl_nrx3   : in std_logic;
      ttl_tx3    : out std_logic;
      ttl_txena3 : out std_logic;
      
      -- eeprom interface:
      eeprom_si  : in std_logic;
      eeprom_so  : out std_logic;
      eeprom_sck : out std_logic;
      eeprom_cs  : out std_logic;
      
      -- dac interface:
      dac_data0  : out std_logic_vector(13 downto 0);
      dac_data1  : out std_logic_vector(13 downto 0);
      dac_data2  : out std_logic_vector(13 downto 0);
      dac_data3  : out std_logic_vector(13 downto 0);
      dac_data4  : out std_logic_vector(13 downto 0);
      dac_data5  : out std_logic_vector(13 downto 0);
      dac_data6  : out std_logic_vector(13 downto 0);
      dac_data7  : out std_logic_vector(13 downto 0);
      dac_data8  : out std_logic_vector(13 downto 0);
      dac_data9  : out std_logic_vector(13 downto 0);
      dac_data10 : out std_logic_vector(13 downto 0);
      dac_clk    : out std_logic_vector(40 downto 0);
      
      -- miscellaneous ports:
      red_led    : out std_logic;
      ylw_led    : out std_logic;
      grn_led    : out std_logic;
      dip_sw3    : in std_logic;
      dip_sw4    : in std_logic;
      wdog       : out std_logic;
      slot_id    : in std_logic_vector(3 downto 0);
      
      -- debug ports:
      test       : inout std_logic_vector(16 downto 3);
      mictor     : out std_logic_vector(32 downto 1);
      mictorclk  : out std_logic_vector(2 downto 1);
      rs232_rx   : in std_logic;
      rs232_tx   : out std_logic    
   );     
end component;

end addr_card_pack;
