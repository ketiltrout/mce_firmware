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
-- rc_noise_test.vhd
--
-- Project:	      SCUBA-2
-- Author:	      Mandana Amiri
-- Organisation:  UBC
--
-- Description:
-- Stand-alone test module for readout card. It only routes the ADC outputs to DAC inputs. 
--
-- Revision history:
-- -- <date $Date$>    - <initials $Author$>
-- $Log$
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity rc_noise_test is
   port(
      n_rst : in std_logic;
      
      -- clock signals
      inclk  : in std_logic;
      outclk : out std_logic;
                        
      -- rc serial dac interface
      dac_dat        : out std_logic_vector (7 downto 0); 
      dac_clk       : out std_logic_vector (7 downto 0);
      bias_dac_ncs   : out std_logic_vector (7 downto 0); 
      offset_dac_ncs : out std_logic_vector (7 downto 0); 

      -- rc parallel dac interface
      dac_FB1_dat    : out std_logic_vector (13 downto 0);
      dac_FB2_dat    : out std_logic_vector (13 downto 0);
      dac_FB3_dat    : out std_logic_vector (13 downto 0);
      dac_FB4_dat    : out std_logic_vector (13 downto 0);
      dac_FB5_dat    : out std_logic_vector (13 downto 0);
      dac_FB6_dat    : out std_logic_vector (13 downto 0);
      dac_FB7_dat    : out std_logic_vector (13 downto 0);
      dac_FB8_dat    : out std_logic_vector (13 downto 0);

      dac_FB_clk     : out std_logic_vector (7 downto 0);     
      
      -- rc ADC interface
      adc1_clk       : out std_logic;
      adc1_rdy       : in std_logic;
      adc1_ovr       : in std_logic;
      adc1_dat       : in std_logic_vector (13 downto 0);  
      
      adc2_clk       : out std_logic;
      adc2_rdy       : in std_logic;
      adc2_ovr       : in std_logic;
      adc2_dat       : in std_logic_vector (13 downto 0);  
      
      adc3_clk       : out std_logic;
      adc3_rdy       : in std_logic;
      adc3_ovr       : in std_logic;      
      adc3_dat       : in std_logic_vector (13 downto 0);  
      
      adc4_clk       : out std_logic;
      adc4_rdy       : in std_logic;
      adc4_ovr       : in std_logic;
      adc4_dat       : in std_logic_vector (13 downto 0);  
      
      adc5_clk       : out std_logic;
      adc5_rdy       : in std_logic;
      adc5_ovr       : in std_logic;
      adc5_dat       : in std_logic_vector (13 downto 0);  
      
      adc6_clk       : out std_logic;
      adc6_rdy       : in std_logic;
      adc6_ovr       : in std_logic;
      adc6_dat       : in std_logic_vector (13 downto 0);  
      
      adc7_clk       : out std_logic;
      adc7_rdy       : in std_logic;
      adc7_ovr       : in std_logic;
      adc7_dat       : in std_logic_vector (13 downto 0);  

      adc8_clk       : out std_logic;
      adc8_rdy       : in std_logic;
      adc8_ovr       : in std_logic;      
      adc8_dat       : in std_logic_vector (13 downto 0);  
                  
      --test pins
      smb_clk: out std_logic; 
      mictor : out std_logic_vector(31 downto 0));
end rc_noise_test;

architecture behaviour of rc_noise_test is
   
   component pll
   port(inclk0 : in std_logic;
        c0 : out std_logic;
        c1 : out std_logic;
        e0 : out std_logic);
   end component;

   signal zero : std_logic;
   signal one : std_logic;
   
   signal clk : std_logic;  
   signal clk2: std_logic;
   signal nclk: std_logic;
   
begin
   
   clk_gen : pll
      port map(inclk0 => inclk,
               c0 => clk,
               c1 => clk2,
               e0 => outclk);
   
   adc1_clk <= clk;
   adc2_clk <= clk;
   adc3_clk <= clk;
   adc4_clk <= clk;
   adc5_clk <= clk;
   adc6_clk <= clk;
   adc7_clk <= clk;
   adc8_clk <= clk;
   
   dac_FB1_dat(13 downto 6) <= adc1_dat(7 downto 0);
   dac_FB2_dat(13 downto 6) <= adc2_dat(7 downto 0);
   dac_FB3_dat(13 downto 6) <= adc3_dat(7 downto 0);
   dac_FB4_dat(13 downto 6) <= adc4_dat(7 downto 0);
   dac_FB5_dat(13 downto 6) <= adc5_dat(7 downto 0);
   dac_FB6_dat(13 downto 6) <= adc6_dat(7 downto 0);
   dac_FB7_dat(13 downto 6) <= adc7_dat(7 downto 0);
   dac_FB8_dat(13 downto 6) <= adc8_dat(7 downto 0);

   nclk <= not(clk);
   dac_FB_clk <= (others => nclk);
   mictor (13 downto 0) <= adc1_dat(13 downto 0);
   mictor (14)          <= adc1_rdy;
   mictor (15)          <= clk;
   mictor (29 downto 16)<= adc2_dat(13 downto 0);
   mictor (30)          <= adc2_rdy;
   mictor (31)          <= clk;
   
end behaviour;
