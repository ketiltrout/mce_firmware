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
-- rc_test_ssr.vhd
--
-- Project:	  SCUBA-2
-- Author:	  Mandana Amiri
-- Organisation:  UBC
--
-- Description:
-- Test module for readout card subrack noise and temperature testing
-- original source: rc_test, stripped off the rs232 debug interface and xtalk tests
-- connect ADCs to parallel DACs and run a square wave on serial DACs
--
-- Revision history:
-- <date $Date$>    - <initials $Author$>
-- $Log$   

-----------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

library work;
use work.rc_test_pack.all;

entity rc_test is
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

      -- rc serial dac interface
      dac_FB1_dat    : out std_logic_vector (13 downto 0);
      dac_FB2_dat    : out std_logic_vector (13 downto 0);
      dac_FB3_dat    : out std_logic_vector (13 downto 0);
      dac_FB4_dat    : out std_logic_vector (13 downto 0);
      dac_FB5_dat    : out std_logic_vector (13 downto 0);
      dac_FB6_dat    : out std_logic_vector (13 downto 0);
      dac_FB7_dat    : out std_logic_vector (13 downto 0);
      dac_FB8_dat    : out std_logic_vector (13 downto 0);

      dac_FB_clk   : out std_logic_vector (7 downto 0);     

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
end rc_test;

architecture behaviour of rc_test is
   
   component pll
   port(inclk0 : in std_logic;
        c0 : out std_logic;
        c1 : out std_logic;
        c2 : out std_logic;
        e0 : out std_logic);
   end component;
  
   signal clk : std_logic;   
   signal rst : std_logic;
   signal int_rst : std_logic;
   
   signal dac_test_ncs: std_logic_vector(31 downto 0);
   signal dac_test_sclk: std_logic_vector(31 downto 0);
   signal dac_test_data: std_logic_vector(31 downto 0);


   signal test_dac_ncs      : std_logic_vector (7 downto 0);
   signal test_dac_clk     : std_logic_vector (7 downto 0);
   signal test_dac_data     : std_logic_vector (7 downto 0);   
   
   signal test_data : std_logic_vector(31 downto 0);
   signal spi_start : std_logic;

   signal rx_clk : std_logic;
   signal dac_test_mode : std_logic_vector(1 downto 0);
   
   signal en_toggle: std_logic;
   signal nclk     : std_logic;
   
begin
   clk_gen : pll
      port map(inclk0 => inclk,
               c0 => clk,
               c1 => rx_clk,
               c2 => en_toggle, -- 1MHz clock
               e0 => outclk);

               
   rc_serial_dac : rc_serial_dac_test_wrapper
      port map(
               -- basic signals
               rst_i     => rst,
               clk_i     => clk,
               en_i      => en_toggle, -- 1MHz on enable causes a square wave on DACs outputs
               mode      => dac_test_mode,
               done_o    => open,
               
               -- transmitter signals removed!
                         
               -- extended signals
               dac_clk_o => test_dac_clk,
               dac_dat_o => test_dac_data,
               dac_ncs_o => test_dac_ncs);

--   rc_parallel_dac : rc_parallel_dac_test_wrapper
--      port map(rst_i       => rst,
--               clk_i       => clk,
--               en_i        => '0',
--               mode        => dac_test_mode,               
--               done_o      => open,
               
--               dac0_dat_o  => dac_FB1_dat,
--               dac1_dat_o  => dac_FB2_dat,
--               dac2_dat_o  => dac_FB3_dat,
--               dac3_dat_o  => dac_FB4_dat,
--               dac4_dat_o  => dac_FB5_dat,
--               dac5_dat_o  => dac_FB6_dat,
--               dac6_dat_o  => dac_FB7_dat,
--               dac7_dat_o  => dac_FB8_dat,
--               dac_clk_o   => dac_FB_clk);
               
   dac_dat        <= test_dac_data;
   dac_clk       <= test_dac_clk;
   bias_dac_ncs   <= test_dac_ncs;
   offset_dac_ncs <= test_dac_ncs;
   
   dac_test_mode  <= "00"; -- means rc_serial_dacs would be running the square wave
   
   rst <= not n_rst or int_rst;
      adc1_clk <= clk;
      adc2_clk <= clk;
      adc3_clk <= clk;
      adc4_clk <= clk;
      adc5_clk <= clk;
      adc6_clk <= clk;
      adc7_clk <= clk;
      adc8_clk <= clk;
      
      dac_FB1_dat(12 downto 0) <= adc1_dat(12 downto 0);
      dac_FB2_dat(12 downto 0) <= adc2_dat(12 downto 0);
      dac_FB3_dat(12 downto 0) <= adc3_dat(12 downto 0);
      dac_FB4_dat(12 downto 0) <= adc4_dat(12 downto 0);
      dac_FB5_dat(12 downto 0) <= adc5_dat(12 downto 0);
      dac_FB6_dat(12 downto 0) <= adc6_dat(12 downto 0);
      dac_FB7_dat(12 downto 0) <= adc7_dat(12 downto 0);
      dac_FB8_dat(12 downto 0) <= adc8_dat(12 downto 0);
    
      dac_FB1_dat(13) <= not(adc1_dat(13)); --adc is signed
      dac_FB2_dat(13) <= not(adc2_dat(13)); --adc is signed
      dac_FB3_dat(13) <= not(adc3_dat(13)); --adc is signed
      dac_FB4_dat(13) <= not(adc4_dat(13)); --adc is signed
      dac_FB5_dat(13) <= not(adc5_dat(13)); --adc is signed
      dac_FB6_dat(13) <= not(adc6_dat(13)); --adc is signed
      dac_FB7_dat(13) <= not(adc7_dat(13)); --adc is signed
      dac_FB8_dat(13) <= not(adc8_dat(13)); --adc is signed
      
      nclk <= not(clk);
      dac_FB_clk <= (others => nclk);
      smb_clk <= en_toggle;
      
end behaviour;
