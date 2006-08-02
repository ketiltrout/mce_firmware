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
-- <date $Date: 2004/07/29 17:23:32 $>	- <initials $Author: mandana $>
-- $Log: tb_ac_dac_ctrl_test.vhd,v $
-- Revision 1.2  2004/07/29 17:23:32  mandana
-- w14_array11 name change
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


entity TB_AC_DAC_CTRL_TEST is
end TB_AC_DAC_CTRL_TEST;

architecture BEH of TB_AC_DAC_CTRL_TEST is


   constant PERIOD          : time := 20 ns;
   constant EDGE_DEPENDENCY : time := 2 ns;       -- shows clk edge dependency
   constant NUM_FIXED_VALUES: integer:= 16;

   signal W_RST_I       : std_logic ;
   signal W_CLK_I       : std_logic := '0';
   signal W_EN_I        : std_logic ;
   signal W_DONE_O      : std_logic ;
   signal W_dac_dat0_o  : std_logic_vector(13 downto 0);
   signal W_dac_dat1_o  : std_logic_vector(13 downto 0);
   signal W_dac_dat2_o  : std_logic_vector(13 downto 0);
   signal W_dac_dat3_o  : std_logic_vector(13 downto 0);
   signal W_dac_dat4_o  : std_logic_vector(13 downto 0);
   signal W_dac_dat5_o  : std_logic_vector(13 downto 0);
   signal W_dac_dat6_o  : std_logic_vector(13 downto 0);
   signal W_dac_dat7_o  : std_logic_vector(13 downto 0);
   signal W_dac_dat8_o  : std_logic_vector(13 downto 0);
   signal W_dac_dat9_o  : std_logic_vector(13 downto 0);
   signal W_dac_dat10_o : std_logic_vector(13 downto 0);
   signal W_DAC_CLK_O   : std_logic_vector ( 40 downto 0 ) ;
   
   component AC_DAC_CTRL_TEST
      port(RST_I       : in std_logic ;
           CLK_I       : in std_logic ;
           EN_I        : in std_logic ;
           DONE_O      : out std_logic ;
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
           DAC_CLK_O   : out std_logic_vector (40 downto 0) );

   end component;

      
begin

   DUT : AC_DAC_CTRL_TEST
      port map(RST_I       => W_RST_I,
               CLK_I       => W_CLK_I,
               EN_I        => W_EN_I,
               DONE_O      => W_DONE_O,
               DAC_DAT0_O  => W_DAC_DAT0_O,
               DAC_DAT1_O  => W_DAC_DAT1_O,
               DAC_DAT2_O  => W_DAC_DAT2_O,
               DAC_DAT3_O  => W_DAC_DAT3_O,
               DAC_DAT4_O  => W_DAC_DAT4_O,
               DAC_DAT5_O  => W_DAC_DAT5_O,
               DAC_DAT6_O  => W_DAC_DAT6_O,
               DAC_DAT7_O  => W_DAC_DAT7_O,
               DAC_DAT8_O  => W_DAC_DAT8_O,
               DAC_DAT9_O  => W_DAC_DAT9_O,
               DAC_DAT10_O => W_DAC_DAT10_O,               
               DAC_CLK_O   => W_DAC_CLK_O);

   W_CLK_I <= not W_CLK_I after PERIOD/2;

   STIMULI : process
  
  procedure enable_test is
   begin
       -- set all DACs to the first value      
      W_EN_I  <= '1';  
      wait for PERIOD;
      W_EN_I  <= '0';
      wait until W_DONE_O = '1';
      WAIT for PERIOD*5; 
   end enable_test;

   procedure reset_test is
   begin 
      W_RST_I <= '0';
      wait for PERIOD;
      W_RST_I     <= '1';
      wait for 20*PERIOD;      
      W_RST_I <= '0';
   end reset_test;      
   
   begin
      reset_test;
      for i in 0 to NUM_FIXED_VALUES*2 loop
        enable_test;
      end loop;  
      
      assert FALSE report "Simulation done." severity failure;    
      wait;

   end process STIMULI;

end BEH;

configuration CFG_TB_AC_DAC_CTRL_TEST of TB_AC_DAC_CTRL_TEST is
   for BEH
   end for;
end CFG_TB_AC_DAC_CTRL_TEST;