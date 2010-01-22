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
-- bc_test_pack.vhd
--
-- Project:	      SCUBA-2
-- Author:	       Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Package file for test module for bias card
-- 
-- Revision History:
--
-- $Log: bc_test_pack.vhd,v $
-- Revision 1.9  2006/08/30 20:57:11  mandana
-- updated to use bc_test_pll
-- added clk_4_i to DAC test interfaces
-- added sa_heater test block
--
-- Revision 1.8  2004/06/23 19:41:46  bench2
-- Mandana: added lvds_spi_start signal to be routed to test header
--
-- Revision 1.7  2004/06/21 18:32:28  bench2
-- renamed all_test_idle to bc_test_idle
--
-- Revision 1.6  2004/06/08 19:04:23  mandana
-- added the cross-talk test
--
-- Revision 1.5  2004/06/04 21:00:26  bench2
-- Mandana: ramp test works now
--
-- Revision 1.4  2004/05/16 23:38:12  erniel
-- changed LVDS tx test to two character command
-- modified command encoding
--
-- Revision 1.3  2004/05/12 18:03:15  mandana
-- seperated the lvds_dac signals on the wrapper
--
-- Revision 1.2  2004/05/12 16:49:07  erniel
-- removed components already in all_test
--
-- Revision 1.1  2004/05/11 23:04:40  mandana
-- initial release - copied from all_test
--
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

package bc_test_pack is
constant NUM_FLUX_FB_DACS       : integer := 32;
constant FLUX_FB_DAC_DATA_WIDTH : integer := 16;
constant FLUX_FB_DAC_ADDR_WIDTH : integer := 6;

constant NUM_LN_BIAS_DACS       : integer := 12; -- 1 prior to BC Rev. E hardware
constant LN_BIAS_DAC_DATA_WIDTH : integer := 16;
constant LN_BIAS_DAC_ADDR_WIDTH : integer :=  4; -- 1 prior to BC Rev. E hardware

  component bc_test_pll
     port(inclk0 : in std_logic;
          c0 : out std_logic;
          c1 : out std_logic);
     end component;
 
  ------------------------------------------------------------------
   -- BC DAC CTRL FIX values
  
  component bc_dac_ctrl_test_wrapper
     port (
        -- basic signals
          rst_i     : in std_logic;    -- reset input
          clk_i     : in std_logic;    -- clock input
          clk_4_i   : in std_logic;    -- clock div 4 input
          en_i      : in std_logic;    -- enable signal
          done_o    : out std_logic;   -- done ouput signal
          
          -- transmitter signals removed!
          
          -- extended signals
          dac_dat_o : out std_logic_vector (31 downto 0); 
          dac_ncs_o : out std_logic_vector (31 downto 0); 
          dac_clk_o : out std_logic_vector (31 downto 0);
          
--          dac_nclr_o: out std_logic;
          
          lvds_dac_dat_o : out std_logic;
          lvds_dac_ncs_o : out std_logic_vector (NUM_LN_BIAS_DACS-1 downto 0);
          lvds_dac_clk_o : out std_logic;
          spi_start_o    : out std_logic
--          lvds_spi_start_o: out std_logic
          );   
  end component;  
  

  ------------------------------------------------------------------
  -- BC DAC RAMP

component bc_dac_ramp_test_wrapper is
   port (
      -- basic signals
      rst_i     : in std_logic;    -- reset input
      clk_i     : in std_logic;    -- clock input
      clk_4_i   : in std_logic;    -- clock div 4 input
      en_i      : in std_logic;    -- enable signal
      done_o    : out std_logic;   -- done ouput signal
      
      -- transmitter signals removed!
                
      -- extended signals
      dac_dat_o : out std_logic_vector (31 downto 0); 
      dac_ncs_o : out std_logic_vector (31 downto 0); 
      dac_clk_o : out std_logic_vector (31 downto 0);
     
      lvds_dac_dat_o: out std_logic;
      lvds_dac_ncs_o: out std_logic_vector (NUM_LN_BIAS_DACS-1 downto 0);
      lvds_dac_clk_o: out std_logic;
      
      spi_start_o   : out std_logic
      
   );   
end component;  

  ------------------------------------------------------------------
  -- BC DAC XTALK

component bc_dac_xtalk_test_wrapper is
   port (
      -- basic signals
      rst_i     : in std_logic;    -- reset input
      clk_i     : in std_logic;    -- clock input
      clk_4_i   : in std_logic;    -- clock div 4 input
      en_i      : in std_logic;    -- enable signal
      mode_i    : in std_logic;    -- square wave on odd or even channels 
      done_o    : out std_logic;   -- done ouput signal
      
      -- transmitter signals removed!
                
      -- extended signals
      dac_dat_o : out std_logic_vector (31 downto 0); 
      dac_ncs_o : out std_logic_vector (31 downto 0); 
      dac_clk_o : out std_logic_vector (31 downto 0);
     
      lvds_dac_dat_o: out std_logic;
      lvds_dac_ncs_o: out std_logic_vector (NUM_LN_BIAS_DACS-1 downto 0);
      lvds_dac_clk_o: out std_logic;
      
      spi_start_o: out std_logic
      
   );   
end component;  

  ------------------------------------------------------------------
  -- BC SA HTR 

component bc_sa_htr_test is
   port (
      -- basic signals
      rst_i     : in std_logic;    -- reset input
      clk_i     : in std_logic;    -- clock input
      en_i      : in std_logic;    -- enable signal
      done_o    : out std_logic;   -- done ouput signal
                     
      -- extended signals     
      pos_o     : out std_logic;
      neg_o     : out std_logic
      
   );   
end component;  


end bc_test_pack;
