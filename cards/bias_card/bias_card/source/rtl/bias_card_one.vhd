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
-- $Id: bias_card_one.vhd,v 1.2 2004/12/06 07:22:34 bburger Exp $
--
-- Project:       SCUBA-2
-- Author:        Bryce Burger
-- Organisation:  UBC
--
-- Description:
-- Bias Card top-level file
--
-- Revision history:
-- 
-- $Log: bias_card_one.vhd,v $
-- Revision 1.2  2004/12/06 07:22:34  bburger
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
use sys_param.data_types_pack.all;

library work;
use work.dispatch_pack.all;
use work.leds_pack.all;
use work.frame_timing_pack.all;
use work.bc_dac_ctrl_pack.all;
use work.bias_card_pack.all;

entity bias_card_one is
   generic(
      CARD : std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0) := BIAS_CARD_1
   );
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
      ttl_nrx    : in std_logic_vector(3 downto 1);
      ttl_tx     : out std_logic_vector(3 downto 1);
      ttl_txena  : out std_logic_vector(3 downto 1);
      
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
      mictor     : out std_logic_vector(32 downto 1);
      mictorclk  : out std_logic_vector(2 downto 1);
      rs232_rx   : in std_logic;
      rs232_tx   : out std_logic
   );
end bias_card_one;

architecture top of bias_card_one is

begin
   
   i_bias_card_one : bias_card
      generic map(
         CARD          => CARD
      )
      port map(
         inclk         => inclk,      
         rst_n         => rst_n,      
         
                          
         lvds_cmd      => lvds_cmd,  
         lvds_sync     => lvds_sync,  
         lvds_spare    => lvds_spare, 
         lvds_txa      => lvds_txa,   
         lvds_txb      => lvds_txb,   
                      
                         
         ttl_nrx       => ttl_nrx,    
         ttl_tx        => ttl_tx,     
         ttl_txena     => ttl_txena,  
                       
                          
         eeprom_si     => eeprom_si,  
         eeprom_so     => eeprom_so,  
         eeprom_sck    => eeprom_sck, 
         eeprom_cs     => eeprom_cs,  
         
                         
         dac_ncs       => dac_ncs,      
         dac_sclk      => dac_sclk,     
         dac_data      => dac_data,     
         lvds_dac_ncs  => lvds_dac_ncs, 
         lvds_dac_sclk => lvds_dac_sclk,
         lvds_dac_data => lvds_dac_data,
         dac_nclr      => dac_nclr,     
         
                          
         red_led       => red_led,    
         ylw_led       => ylw_led,    
         grn_led       => grn_led,    
         dip_sw3       => dip_sw3,    
         dip_sw4       => dip_sw4,    
         wdog          => wdog,       
         slot_id       => slot_id,    
                       
                          
         test          => test,       
         mictor        => mictor,     
         mictorclk     => mictorclk,  
         rs232_rx      => rs232_rx,   
         rs232_tx      => rs232_tx  
      );               
   
end top;