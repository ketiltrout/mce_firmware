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
-- Stand-alone test module for readout card. 
-- For noise_response test the ADC outputs are routed to DAC inputs and 
-- For noise_test_chx a particular ADC output is routed to the mictor.
-- customize for the type of the test and the desired channel and recompile
--
-- Revision history:
-- -- <date $Date: 2006/04/12 23:02:22 $>    - <initials $Author: mandana $>
-- $Log: rc_noise_test.vhd,v $
-- Revision 1.6  2006/04/12 23:02:22  mandana
-- now uses the regular rc_pll model
-- mictor_clk pins added (new in Rev. B readout card)
-- added notes for how to use this file to generate response test and noise test for each channel
--
-- Revision 1.5  2005/12/15 21:24:42  mandana
-- *** empty log message ***
--
-- Revision 1.4  2004/07/26 22:52:59  bench1
-- Mandana: added comment, swapped adc_rdy and adc_ovr on mictor to work with the wire-add on board.
--
-- Revision 1.3  2004/07/22 23:51:27  bench1
-- Mandana: invert the last bit of ADC for all channels before routing to DAC
--
-- Revision 1.2  2004/07/21 23:05:05  bench1
-- Mandana: route ADC1 signals to DAC1 and complement bit 13
--
-- Revision 1.1  2004/07/20 22:19:50  mandana
-- Initial release, samples ADC at 50MHz, routes ADC LSb to DAC MSb
--
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library altera_mf;
use altera_mf.altera_mf_components.all;

entity rc_noise_test is
   port(
      rst_n : in std_logic;
      
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
      mictor : out std_logic_vector(31 downto 0);
      mictor_clk: out std_logic_vector(1 downto 0));
      
end rc_noise_test;

architecture behaviour of rc_noise_test is

  -----------------------------------------------------------------------------
  -- PLL Component
  -----------------------------------------------------------------------------

   component rc_pll
    port (
      inclk0 : IN  STD_LOGIC := '0';
      c0     : OUT STD_LOGIC;
      c1     : OUT STD_LOGIC;
      c2     : OUT STD_LOGIC;
      c3     : OUT STD_LOGIC;
      c4     : OUT STD_LOGIC);
   end component;

   signal zero : std_logic;
   signal one : std_logic;
   
   signal clk : std_logic;  
   signal nclk: std_logic;
   signal wrfull : std_logic;
   signal rdempty: std_logic;
   
begin
   
   ----------------------------------------------------------------------------
   -- PLL Instantiation
   ----------------------------------------------------------------------------
   
   i_rc_pll: rc_pll
     port map (
         inclk0 => inclk,
         c0     => clk,
         c1     => open,
         c2     => open,
         c3     => open,
         c4     => nclk);
         
    adc_fifo : dcfifo
	GENERIC MAP (
--		add_ram_output_register => "ON",
		clocks_are_synchronized => "FALSE",
		intended_device_family => "Stratix",
		lpm_numwords => 256,
		lpm_showahead => "OFF",
		lpm_type => "dcfifo",
		lpm_width => 14,
		lpm_widthu => 8,
		overflow_checking => "ON",
		underflow_checking => "ON",
		use_eab => "ON"
	)
	PORT MAP (
		wrclk => adc8_rdy,
		rdreq => '1',
		rdclk => clk,
		wrreq => '1',
		data  => adc8_dat(13 downto 0),
		rdempty => rdempty,
		wrfull  => wrfull,
		q     => mictor(13 downto 0)
	);

   mictor_clk(0) <= clk;
   mictor_clk(1) <= clk;
   
   adc1_clk <= clk;
   adc2_clk <= clk;
   adc3_clk <= clk;
   adc4_clk <= clk;
   adc5_clk <= clk;
   adc6_clk <= clk;
   adc7_clk <= clk;
   adc8_clk <= clk;
   
   -- map different channels to mictor
--   mictor (13 downto 0) <= adc7_dat(13 downto 0);
--   mictor (14)          <= adc7_ovr;
--   mictor (15)          <= adc7_rdy;
--   mictor_clk (0)       <= adc7_rdy;
--   mictor_clk (1)       <= adc1_rdy;
--   mictor (29 downto 16)<= adc1_dat(13 downto 0);
--   mictor (30)          <= adc8_rdy;
--   mictor (31)          <= adc7_rdy;
   
end behaviour;
