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
-- ac_test_ssr.vhd
-- (ssr: Scuba2 SubRack)
--
-- Project:	  SCUBA-2
-- Author:	  Mandana Amiri
-- Organisation:  UBC
--
-- Description:
-- Test module for address card subrack noise and temperature testing
-- original source: ac_test, stripped off the rs232 debug interface and xtalk tests
-- compile with ramp_ena = '1' or '0' to get different tests
--
-- Revision history:
-- <date $Date$>    - <initials $Author$>
-- $Log$    
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library sys_param;
use sys_param.data_types_pack.all;

library work;
use work.ac_test_pack.all;

entity ac_test_ssr is
   port(
      n_rst : in std_logic;

      -- clock signals
      inclk : in std_logic;
      outclk : out std_logic;
            
      -- outputs of dac ramp and dac test for selective values
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
      test : out std_logic_vector(16 downto 3)      
   );         
end ac_test_ssr;

architecture behaviour of ac_test_ssr is
   
   component pll
   port(inclk0 : in std_logic;
        c0 : out std_logic;
        c1 : out std_logic;
        c2 : out std_logic);
   end component;
   
   signal clk : std_logic;   
   signal rst : std_logic;
   signal int_rst : std_logic;
   
   signal test_data : std_logic_vector(43 downto 0);
   
   signal fix_dac_data0  : std_logic_vector(13 downto 0);
   signal fix_dac_data1  : std_logic_vector(13 downto 0);
   signal fix_dac_data2  : std_logic_vector(13 downto 0);
   signal fix_dac_data3  : std_logic_vector(13 downto 0);
   signal fix_dac_data4  : std_logic_vector(13 downto 0);
   signal fix_dac_data5  : std_logic_vector(13 downto 0);
   signal fix_dac_data6  : std_logic_vector(13 downto 0);
   signal fix_dac_data7  : std_logic_vector(13 downto 0);
   signal fix_dac_data8  : std_logic_vector(13 downto 0);
   signal fix_dac_data9  : std_logic_vector(13 downto 0);
   signal fix_dac_data10 : std_logic_vector(13 downto 0);
   signal fix_dac_clk    : std_logic_vector(40 downto 0);
   
   signal ramp_dac_data0  : std_logic_vector(13 downto 0);
   signal ramp_dac_data1  : std_logic_vector(13 downto 0);
   signal ramp_dac_data2  : std_logic_vector(13 downto 0);
   signal ramp_dac_data3  : std_logic_vector(13 downto 0);
   signal ramp_dac_data4  : std_logic_vector(13 downto 0);
   signal ramp_dac_data5  : std_logic_vector(13 downto 0);
   signal ramp_dac_data6  : std_logic_vector(13 downto 0);
   signal ramp_dac_data7  : std_logic_vector(13 downto 0);
   signal ramp_dac_data8  : std_logic_vector(13 downto 0);
   signal ramp_dac_data9  : std_logic_vector(13 downto 0);
   signal ramp_dac_data10 : std_logic_vector(13 downto 0);
   signal ramp_dac_clk    : std_logic_vector(40 downto 0);
   
   signal ramp_ena : std_logic;
   signal ramp_ena_n: std_logic;

begin
   clk_gen : pll
      port map(inclk0 => inclk,
               c0 => clk,
               c1 => outclk,
               c2 => open  );
   
   ac_dac_fix : ac_dac_ctrl_test
      port map(rst_i       => rst,
               clk_i       => clk,
               en_i        => ramp_ena_n,
               done_o      => open,
               
               dac_dat0_o  => fix_dac_data0,
               dac_dat1_o  => fix_dac_data1,
               dac_dat2_o  => fix_dac_data2,
               dac_dat3_o  => fix_dac_data3,
               dac_dat4_o  => fix_dac_data4,
               dac_dat5_o  => fix_dac_data5,
               dac_dat6_o  => fix_dac_data6,
               dac_dat7_o  => fix_dac_data7,
               dac_dat8_o  => fix_dac_data8,
               dac_dat9_o  => fix_dac_data9,
               dac_dat10_o => fix_dac_data10,
               dac_clk_o   => fix_dac_clk);
  
   ac_dac_ramp1 : ac_dac_ramp
      port map(rst_i       => rst,
               clk_i       => clk,
               en_i        => ramp_ena,
               done_o      => open,
               
               dac_dat0_o  => ramp_dac_data0,
               dac_dat1_o  => ramp_dac_data1,
               dac_dat2_o  => ramp_dac_data2,
               dac_dat3_o  => ramp_dac_data3,
               dac_dat4_o  => ramp_dac_data4,
               dac_dat5_o  => ramp_dac_data5,
               dac_dat6_o  => ramp_dac_data6,
               dac_dat7_o  => ramp_dac_data7,
               dac_dat8_o  => ramp_dac_data8,
               dac_dat9_o  => ramp_dac_data9,
               dac_dat10_o => ramp_dac_data10,
               dac_clk_o   => ramp_dac_clk);  
               
   ramp_ena <= '0';
   rst <= not n_rst or int_rst;
   ramp_ena_n <= not ramp_ena;
   
   dac_data0  <= ramp_dac_data0  when ramp_ena = '1' else fix_dac_data0;
   dac_data1  <= ramp_dac_data1  when ramp_ena = '1' else fix_dac_data1;
   dac_data2  <= ramp_dac_data2  when ramp_ena = '1' else fix_dac_data2;
   dac_data3  <= ramp_dac_data3  when ramp_ena = '1' else fix_dac_data3;
   dac_data4  <= ramp_dac_data4  when ramp_ena = '1' else fix_dac_data4;
   dac_data5  <= ramp_dac_data5  when ramp_ena = '1' else fix_dac_data5;
   dac_data6  <= ramp_dac_data6  when ramp_ena = '1' else fix_dac_data6;
   dac_data7  <= ramp_dac_data7  when ramp_ena = '1' else fix_dac_data7;
   dac_data8  <= ramp_dac_data8  when ramp_ena = '1' else fix_dac_data8;
   dac_data9  <= ramp_dac_data9  when ramp_ena = '1' else fix_dac_data9;
   dac_data10 <= ramp_dac_data10 when ramp_ena = '1' else fix_dac_data10;
   dac_clk    <= ramp_dac_clk    when ramp_ena = '1' else fix_dac_clk;
      
   test(6) <= ramp_ena;
end behaviour;
