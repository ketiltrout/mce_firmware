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
-- $Id: clk_card_pack.vhd,v 1.2 2004/12/08 22:15:12 bburger Exp $
--
-- Project:       SCUBA-2
-- Author:        Bryce Burger
-- Organization:  UBC
--
-- Description:
-- 
--
-- Revision history:
-- $Log: clk_card_pack.vhd,v $
-- Revision 1.2  2004/12/08 22:15:12  bburger
-- Bryce:  changed the usage of PLLs in the top levels of clk and addr cards
--
-- Revision 1.1  2004/11/30 23:07:53  bburger
-- Bryce:  testing the Clock Card top-level
--
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package clk_card_pack is

component clk_card
   port(
      -- PLL input:
      inclk      : in std_logic;
      rst_n      : in std_logic;
      
      -- LVDS interface:
      lvds_cmd   : out std_logic;
      lvds_sync  : out std_logic;
      lvds_spare : out std_logic;
      lvds_clk   : out std_logic;
      lvds_reply_ac_a  : in std_logic;  
      lvds_reply_ac_b  : in std_logic;
      lvds_reply_bc1_a  : in std_logic;
      lvds_reply_bc1_b  : in std_logic;
      lvds_reply_bc2_a  : in std_logic;
      lvds_reply_bc2_b  : in std_logic;
      lvds_reply_bc3_a  : in std_logic;
      lvds_reply_bc3_b  : in std_logic;
      lvds_reply_rc1_a  : in std_logic;
      lvds_reply_rc1_b  : in std_logic;
      lvds_reply_rc2_a  : in std_logic;
      lvds_reply_rc2_b  : in std_logic;
      lvds_reply_rc3_a  : in std_logic; 
      lvds_reply_rc3_b  : in std_logic;  
      lvds_reply_rc4_a  : in std_logic; 
      lvds_reply_rc4_b  : in std_logic;
      
      -- DV interface:
      dv_pulse_fibre  : in std_logic;
      dv_pulse_bnc    : in std_logic;
      
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
      
      -- miscellaneous ports:
      red_led    : out std_logic;
      ylw_led    : out std_logic;
      grn_led    : out std_logic;
      dip_sw3    : in std_logic;
      dip_sw4    : in std_logic;
      wdog       : out std_logic;
      slot_id    : in std_logic_vector(3 downto 0);
      
      -- debug ports:
      mictor_o    : out std_logic_vector(15 downto 1);
      mictorclk_o : out std_logic;
      mictor_e    : out std_logic_vector(15 downto 1);
      mictorclk_e : out std_logic;
      rs232_rx    : in std_logic;
      rs232_tx    : out std_logic;
      
      -- interface to HOTLINK fibre receiver      
      fibre_rx_clk       : out std_logic;
      fibre_rx_data      : in std_logic_vector (7 downto 0);  
      fibre_rx_rdy       : in std_logic;                      
      fibre_rx_rvs       : in std_logic;                      
      fibre_rx_status    : in std_logic;                      
      fibre_rx_sc_nd     : in std_logic;                      
      fibre_rx_ckr       : in std_logic;                      
      
      -- interface to hotlink fibre transmitter      
      fibre_tx_clk       : out std_logic;
      fibre_tx_data      : out std_logic_vector (7 downto 0);
      fibre_tx_ena       : out std_logic;  
      fibre_tx_sc_nd     : out std_logic
   );     
end component;

end clk_card_pack;
