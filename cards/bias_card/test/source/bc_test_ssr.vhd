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
-- bc_test_ssr.vhd
-- (ssr: Scuba2 SubRack)
--
-- Project:	  SCUBA-2
-- Author:	  Mandana Amiri
-- Organisation:  UBC
--
-- Description:
-- Test module for bias card subrack noise and temperature testing
-- original source: bc_test, stripped off the rs232 debug interface and xtalk tests
-- compile with dac_test_mode = '1' or '0' to get different tests
--
-- Revision history:
-- <date $Date$>    - <initials $Author$>
-- $Log$   
--
-----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library work;
use work.bc_test_pack.all;

entity bc_test_ssr is
   port(
      n_rst : in std_logic;
      
      -- clock signals
      inclk  : in std_logic;
      outclk : out std_logic;
            
      -- bc dac interface
      dac_data  : out std_logic_vector (31 downto 0); 
      dac_ncs  : out std_logic_vector (31 downto 0); 
      dac_sclk  : out std_logic_vector (31 downto 0);

      lvds_dac_data : out std_logic;
      lvds_dac_ncs : out std_logic;
      lvds_dac_sclk : out std_logic;
      --test pins
      test : out std_logic_vector(16 downto 3));
end bc_test_ssr;

architecture behaviour of bc_test_ssr is
   
   component pll
   port(inclk0 : in std_logic;
        c0 : out std_logic;
        e3 : out std_logic;
        c1 : out std_logic;
        c2 : out std_logic);
   end component;

   signal clk : std_logic;   
   signal rst : std_logic;
   
   signal dac_test_ncs: std_logic_vector(31 downto 0);
   signal dac_test_sclk: std_logic_vector(31 downto 0);
   signal dac_test_data: std_logic_vector(31 downto 0);
   
   signal fix_dac_ncs   : std_logic_vector (31 downto 0);
   signal fix_dac_sclk  : std_logic_vector (31 downto 0);
   signal fix_dac_data  : std_logic_vector (31 downto 0);
   signal fix_lvds_dac_ncs   : std_logic;
   signal fix_lvds_dac_sclk  : std_logic;
   signal fix_lvds_dac_data  : std_logic;
   signal ramp_dac_ncs       : std_logic_vector (31 downto 0);
   signal ramp_dac_sclk      : std_logic_vector (31 downto 0);
   signal ramp_dac_data      : std_logic_vector (31 downto 0);
   signal ramp_lvds_dac_ncs  : std_logic;
   signal ramp_lvds_dac_sclk : std_logic;
   signal ramp_lvds_dac_data : std_logic;   
   
   signal test_data : std_logic_vector(31 downto 0);

   signal lvds_spi_start : std_logic;
   signal spi_start      : std_logic;
   signal fix_spi_start  : std_logic;   
   signal ramp_spi_start : std_logic;

   signal rx_clk : std_logic;
   signal dac_test_mode : std_logic;
   signal dac_test_mode_n : std_logic;
   -- dac_test_mode : '0' means run the fix test with 0's on the outputs
   --               : '1' means run the ramp test
   
begin
   clk_gen : pll
      port map(inclk0 => inclk,
               c0 => clk,
               e3 => outclk,
               c1 => rx_clk,
               c2 => open);
               
   dac_fix : bc_dac_ctrl_test_wrapper
      port map(
               -- basic signals
               rst_i     => rst,
               clk_i     => clk,
               en_i      => dac_test_mode_n,
               done_o    => open,
               
               -- extended signals
               dac_dat_o => fix_dac_data,
               dac_ncs_o => fix_dac_ncs,
               dac_clk_o => fix_dac_sclk,
                           
               lvds_dac_dat_o => fix_lvds_dac_data,
               lvds_dac_ncs_o => fix_lvds_dac_ncs,
               lvds_dac_clk_o => fix_lvds_dac_sclk,

               spi_start_o    => fix_spi_start,
               lvds_spi_start_o => lvds_spi_start
               );   

   dac_ramp :  bc_dac_ramp_test_wrapper
      port map(
               -- basic signals
               rst_i     => rst,
               clk_i     => clk,
               en_i      => dac_test_mode,
               done_o    => open,
               
               -- extended signals
               dac_dat_o  => ramp_dac_data,
               dac_ncs_o  => ramp_dac_ncs,
               dac_clk_o  => ramp_dac_sclk,
              
               lvds_dac_dat_o=> ramp_lvds_dac_data,
               lvds_dac_ncs_o=> ramp_lvds_dac_ncs,
               lvds_dac_clk_o=> ramp_lvds_dac_sclk,
               
               spi_start_o  => ramp_spi_start
            );     
            
   dac_test_data <= fix_dac_data       when dac_test_mode = '0' else ramp_dac_data;
   dac_test_sclk <= fix_dac_sclk       when dac_test_mode = '0' else ramp_dac_sclk;
   dac_test_ncs  <= fix_dac_ncs        when dac_test_mode = '0' else ramp_dac_ncs;
---- lvds signals
   lvds_dac_data <= fix_lvds_dac_data  when dac_test_mode = '0' else ramp_lvds_dac_data;                       
   lvds_dac_sclk <= fix_lvds_dac_sclk  when dac_test_mode = '0' else ramp_lvds_dac_sclk;                        
   lvds_dac_ncs  <= fix_lvds_dac_ncs   when dac_test_mode = '0' else ramp_lvds_dac_ncs;
                       
-- for directing to test pin purpose only!
   spi_start     <= fix_spi_start      when dac_test_mode = '0' else ramp_spi_start;
   
   dac_ncs <= dac_test_ncs;
   dac_sclk <= dac_test_sclk;
   dac_data <= dac_test_data;
   
   rst <= not n_rst;
   dac_test_mode <= '1';
   dac_test_mode_n <= not dac_test_mode;
   
--   test(5) <= dac_test_ncs(0);
--   test(6) <= dac_test_ncs(1);
--   test(7) <= dac_test_sclk(0);
--   test(8) <= dac_test_sclk(1);
--   test(9) <= dac_test_data(0);
--   test(10) <= dac_test_data(1);
--   test(14) <= spi_start;
--   test(13) <= lvds_spi_start;
--   test(15) <= dac_test_ncs(15);
--   test(16) <= dac_test_data(15);

end behaviour;
