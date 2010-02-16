-- Copyright (c) 2003 SCUBA-2 Project
--                  All Rights Reserved

--  THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF THE SCUBA-2 Project
--  The copyright notice above does not evidence any
--  actual or intended publication of such source code.

--  SOURCE CODE IS PROVIDED "AS IS". ALL EXPRESS OR IMPLIED CONDITIONS,
--  REPRESENTATIONS, AND WARRANTIES, INCLUDING ANY IMPLIED WARRANT OF
--  MERCHANTABILITY, SATISFACTORY QUALITY, FITNESS FOR A PARTICULAR
--  PURPOSE, OR NON-INFRINGEMENT, ARE DISCLAIMED, EXCEPT TO THE EXTENT
--  THAT SUCH DISCLAIMERS ARE HELD TO BE LEGALLY INVALID.

-- For the purposes of this code the SCUBA-2 Project consists of the
-- following organisations.

-- UKATC, Royal Observatory, Blackford Hill Edinburgh EH9 3HJ
-- UBC,   University of British Columbia, Physics & Astronomy Department,
--        Vancouver BC, V6T 1Z1

-- tb_ac_dac_ctrl_test.vhd
--

-- Project:	      SCUBA-2
-- Author:	      Mandana Amiri
-- Organisation:  UBC
--
-- Description:
-- testbench for the ac_dac_ctrl, very simple: assert enable and wait for done!
--
-- Revision history:
-- <date $Date: 2006/08/02 22:46:47 $>	- <initials $Author: mandana $>
-- $Log: tb_ac_dac_ramp.vhd,v $
-- Revision 1.2  2006/08/02 22:46:47  mandana
-- updated to improve coverage
--
-- Revision 1.1  2004/05/04 00:10:45  mandana
-- initial release
--
-- Revision 1.1  2004/04/29 17:50:25  mandana
-- initial release
--  

--   
--
-----------------------------------------------------------------------------
library IEEE, sys_param, components;
use IEEE.std_logic_1164.all;
use components.component_pack.all;
use sys_param.data_types_pack.all;


entity TB_AC_DAC_RAMP is
end TB_AC_DAC_RAMP;

architecture BEH of TB_AC_DAC_RAMP is

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

   constant PERIOD : time := 20 ns;

   signal W_RST_I         : std_logic ;
   signal W_CLK_I         : std_logic := '0';
   signal W_CLK_4_I       : std_logic := '0';
   signal W_EN_I          : std_logic ;
   signal W_DONE_O        : std_logic ;
   signal W_DAC_DAT0_O    : std_logic_vector(13 downto 0);
   signal W_DAC_DAT1_O    : std_logic_vector(13 downto 0);
   signal W_DAC_DAT2_O    : std_logic_vector(13 downto 0);
   signal W_DAC_DAT3_O    : std_logic_vector(13 downto 0);
   signal W_DAC_DAT4_O    : std_logic_vector(13 downto 0);
   signal W_DAC_DAT5_O    : std_logic_vector(13 downto 0);
   signal W_DAC_DAT6_O    : std_logic_vector(13 downto 0);
   signal W_DAC_DAT7_O    : std_logic_vector(13 downto 0);
   signal W_DAC_DAT8_O    : std_logic_vector(13 downto 0);
   signal W_DAC_DAT9_O    : std_logic_vector(13 downto 0);
   signal W_DAC_DAT10_O   : std_logic_vector(13 downto 0);
   signal W_DAC_CLK_O     : std_logic_vector ( 40 downto 0 ) ;

begin

   DUT : AC_DAC_RAMP
      port map(RST_I       => W_RST_I,
               CLK_I       => W_CLK_I,
               CLK_4_i     => W_CLK_4_I,
               EN_I        => W_EN_I,
               DONE_O      => W_DONE_O,
               DAC_DAT0_O   => W_DAC_DAT0_O,
               DAC_DAT1_O   => W_DAC_DAT1_O,               
               DAC_DAT2_O   => W_DAC_DAT2_O,               
               DAC_DAT3_O   => W_DAC_DAT3_O,               
               DAC_DAT4_O   => W_DAC_DAT4_O,               
               DAC_DAT5_O   => W_DAC_DAT5_O,               
               DAC_DAT6_O   => W_DAC_DAT6_O,               
               DAC_DAT7_O   => W_DAC_DAT7_O,               
               DAC_DAT8_O   => W_DAC_DAT8_O,               
               DAC_DAT9_O   => W_DAC_DAT9_O,               
               DAC_DAT10_O   => W_DAC_DAT10_O,               
               DAC_CLK_O   => W_DAC_CLK_O);

   W_CLK_I <= not W_CLK_I after PERIOD/2;
   W_CLK_4_I <= not W_CLK_4_I after 2*PERIOD;

   STIMULI : process
   begin
      W_EN_I        <= '0';
      W_RST_I       <= '0';
      wait for PERIOD;
      W_RST_I       <= '1';
      wait for PERIOD;
      W_RST_I       <= '0';     

      -- start the ramp
      W_EN_I        <= '1';     
      wait until W_DONE_O = '1';
      W_EN_I        <= '0';
      wait for PERIOD*10;
      
      -- toggle the ramp
      W_EN_I        <= '1';
      wait until W_DONE_O = '1';
      W_EN_I        <= '0';
      wait for PERIOD*10;
      
      --toggle the ramp
      W_EN_I        <= '1';     
      wait until W_DONE_O = '1';
      W_EN_I        <= '0';
      wait for PERIOD*100;
      assert FALSE report "Simulation done." severity failure;    

   end process STIMULI;

end BEH;

configuration CFG_TB_AC_DAC_RAMP of TB_AC_DAC_RAMP is
   for BEH
   end for;
end CFG_TB_AC_DAC_RAMP;