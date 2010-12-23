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
-- ac_test_pack.vhd
--
-- Project:	      MCE
-- Author:	      Mandana Amiri
-- Organisation:  UBC
--
-- Description:
-- Package file for test module for address card test
-- 
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

package ac_test_pack is
constant NUM_FLUX_FB_DACS       : integer := 32;
constant FLUX_FB_DAC_DATA_WIDTH : integer := 16;
constant FLUX_FB_DAC_ADDR_WIDTH : integer := 5;

constant NUM_LN_BIAS_DACS       : integer := 12; -- 1 prior to BC Rev. E hardware
constant LN_BIAS_DAC_DATA_WIDTH : integer := 16;
constant LN_BIAS_DAC_ADDR_WIDTH : integer :=  4; -- 1 prior to BC Rev. E hardware

component ac_test_pll
port(inclk0 : in std_logic;
  c0 : out std_logic;
  c1 : out std_logic;
  c2 : out std_logic);
end component;
     
component ac_dac_ctrl_test
port(rst_i       : in std_logic;
  clk_i       : in std_logic;
  en_i        : in std_logic;
  done_o      : out std_logic;
  dac_dat0_o  : out std_logic_vector(13 downto 0);
  dac_dat1_o  : out std_logic_vector(13 downto 0);
  dac_dat2_o  : out std_logic_vector(13 downto 0);
  dac_dat3_o  : out std_logic_vector(13 downto 0);
  dac_dat4_o  : out std_logic_vector(13 downto 0);
  dac_dat5_o  : out std_logic_vector(13 downto 0);
  dac_dat6_o  : out std_logic_vector(13 downto 0);
  dac_dat7_o  : out std_logic_vector(13 downto 0);
  dac_dat8_o  : out std_logic_vector(13 downto 0);
  dac_dat9_o  : out std_logic_vector(13 downto 0);
  dac_dat10_o : out std_logic_vector(13 downto 0);
  dac_clk_o   : out std_logic_vector (40 downto 0));
end component;

component ac_dac_ramp
port(rst_i       : in std_logic;
  clk_i       : in std_logic;
  clk_4_i     : in std_logic;
  en_i        : in std_logic;
  done_o      : out std_logic;
  dac_dat0_o  : out std_logic_vector(13 downto 0);
  dac_dat1_o  : out std_logic_vector(13 downto 0);
  dac_dat2_o  : out std_logic_vector(13 downto 0);
  dac_dat3_o  : out std_logic_vector(13 downto 0);
  dac_dat4_o  : out std_logic_vector(13 downto 0);
  dac_dat5_o  : out std_logic_vector(13 downto 0);
  dac_dat6_o  : out std_logic_vector(13 downto 0);
  dac_dat7_o  : out std_logic_vector(13 downto 0);
  dac_dat8_o  : out std_logic_vector(13 downto 0);
  dac_dat9_o  : out std_logic_vector(13 downto 0);
  dac_dat10_o : out std_logic_vector(13 downto 0);
  dac_clk_o   : out std_logic_vector(40 downto 0));
end component;
     
end ac_test_pack;
