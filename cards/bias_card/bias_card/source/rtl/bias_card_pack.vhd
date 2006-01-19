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
-- $Id: bias_card_pack.vhd,v 1.7 2005/07/05 19:49:54 mandana Exp $
--
-- Project:       SCUBA-2
-- Author:        Bryce Burger
-- Organization:  UBC
--
-- Description:
-- 
--
-- Revision history:
-- $Log: bias_card_pack.vhd,v $
-- Revision 1.7  2005/07/05 19:49:54  mandana
-- added id_thermo dispatch slave to the top level, rev. 01020001
--
-- Revision 1.6  2005/02/01 01:10:18  mandana
-- slot_id and ttl_nrx1 are now hard coded in the self_test module
--
-- Revision 1.5  2005/01/27 00:12:09  mandana
-- added bias_card_self_test component
--
-- Revision 1.4  2005/01/19 23:39:06  bburger
-- Bryce:  Fixed a couple of errors with the special-character clear.  Always compile, simulate before comitting.
--
-- Revision 1.3  2005/01/12 22:37:11  mandana
-- added slot_id to dispatch interface
-- removed mem_clk_i from dispatch interface
--
-- Revision 1.2  2004/12/16 18:15:33  bench2
-- Mandana: fixed the clocking
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

library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;

library work;
use work.bc_dac_ctrl_pack.all;

package bias_card_pack is

component bias_card
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
      dac_ncs       : out std_logic_vector(NUM_FLUX_FB_DACS-1 downto 0);
      dac_sclk      : out std_logic_vector(NUM_FLUX_FB_DACS-1 downto 0);
      dac_data      : out std_logic_vector(NUM_FLUX_FB_DACS-1 downto 0);      
      lvds_dac_ncs  : out std_logic;
      lvds_dac_sclk : out std_logic;
      lvds_dac_data : out std_logic;
      dac_nclr      : out std_logic; -- add to tcl file
      
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
      mictor     : out std_logic_vector(31 downto 0);
      mictorclk  : out std_logic_vector(2 downto 1);
      rs232_rx   : in std_logic;
      rs232_tx   : out std_logic
   );     
end component;
  -----------------------------------------------------------------------------
  -- Dispatch component
  -----------------------------------------------------------------------------

  component dispatch
    port(clk_i      : in std_logic;
      comm_clk_i : in std_logic;
      rst_i      : in std_logic;     
      
      -- bus backplane interface (LVDS)
      lvds_cmd_i   : in std_logic;
      lvds_reply_o : out std_logic;
      
      -- wishbone slave interface
      dat_o  : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      addr_o : out std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
      tga_o  : out std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
      we_o   : out std_logic;
      stb_o  : out std_logic;
      cyc_o  : out std_logic;
      dat_i  : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      ack_i  : in std_logic;
      err_i  : in std_logic;
      
      -- misc. external interface
      wdt_rst_o : out std_logic;
      slot_i    : in std_logic_vector(3 downto 0);

      dip_sw3 : in std_logic;
      dip_sw4 : in std_logic);
  end component;
  
  -----------------------------------------------------------------------------
  -- bias card self test component
  -----------------------------------------------------------------------------

component bias_card_self_test
   port(
 
      -- PLL input:
      inclk      : in std_logic;
      rst_n      : in std_logic;
      
      -- LVDS interface:
--      lvds_cmd   : in std_logic;
      lvds_sync  : in std_logic;
      lvds_spare : in std_logic;
      lvds_txa   : out std_logic;
      lvds_txb   : out std_logic;
      
      -- TTL interface:
 --     ttl_nrx1   : in std_logic;
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
      dac_ncs       : out std_logic_vector(NUM_FLUX_FB_DACS-1 downto 0);
      dac_sclk      : out std_logic_vector(NUM_FLUX_FB_DACS-1 downto 0);
      dac_data      : out std_logic_vector(NUM_FLUX_FB_DACS-1 downto 0);      
      lvds_dac_ncs  : out std_logic;
      lvds_dac_sclk : out std_logic;
      lvds_dac_data : out std_logic;
      dac_nclr      : out std_logic; -- add to tcl file
      
      -- miscellaneous ports:
      red_led    : out std_logic;
      ylw_led    : out std_logic;
      grn_led    : out std_logic;
      dip_sw3    : in std_logic;
      dip_sw4    : in std_logic;
      wdog       : out std_logic;
 --     slot_id    : in std_logic_vector(3 downto 0);
      
      -- debug ports:
      test       : inout std_logic_vector(16 downto 3);
      mictor     : out std_logic_vector(31 downto 0);
      mictorclk  : out std_logic_vector(2 downto 1);
      rs232_rx   : in std_logic;
      rs232_tx   : out std_logic
   );
end component;

component id_thermo
  port(clk_i : in std_logic;
     rst_i : in std_logic;
     
     -- Wishbone signals
     dat_i   : in std_logic_vector (WB_DATA_WIDTH-1 downto 0); 
     addr_i  : in std_logic_vector (WB_ADDR_WIDTH-1 downto 0);
     tga_i   : in std_logic_vector (WB_TAG_ADDR_WIDTH-1 downto 0);
     we_i    : in std_logic;
     stb_i   : in std_logic;
     cyc_i   : in std_logic;
     dat_o   : out std_logic_vector (WB_DATA_WIDTH-1 downto 0);
     ack_o   : out std_logic;
        
     -- silicon id/temperature chip signals
     data_io : inout std_logic
  );
end component;

end bias_card_pack;
