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
-- <date $Date$>	- <initials $Author$>
-- $Log$  

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

   component AC_DAC_CTRL_TEST
      port(RST_I       : in std_logic ;
           CLK_I       : in std_logic ;
           EN_I        : in std_logic ;
           DONE_O      : out std_logic ;
           DAC_DAT_O   : out w_array11; 
           DAC_CLK_O   : out std_logic_vector (40 downto 0) );

   end component;


   constant PERIOD : time := 20 ns;

   signal W_RST_I       : std_logic ;
   signal W_CLK_I       : std_logic := '0';
   signal W_EN_I        : std_logic ;
   signal W_DONE_O      : std_logic ;
   signal W_DAC_DAT_O   : w_array11;
   signal W_DAC_CLK_O   : std_logic_vector ( 40 downto 0 ) ;

begin

   DUT : AC_DAC_CTRL_TEST
      port map(RST_I       => W_RST_I,
               CLK_I       => W_CLK_I,
               EN_I        => W_EN_I,
               DONE_O      => W_DONE_O,
               DAC_DAT_O   => W_DAC_DAT_O,
               DAC_CLK_O   => W_DAC_CLK_O);

   W_CLK_I <= not W_CLK_I after PERIOD/2;

   STIMULI : process
   begin
      W_RST_I       <= '0';
      wait for PERIOD;
      W_RST_I       <= '1';
      wait for PERIOD;
      W_RST_I       <= '0';     

      -- set all DACs to the first value
      W_EN_I        <= '1';      
      wait until W_DONE_O = '1';
      W_EN_I        <= '0';
      WAIT for PERIOD*5; -- wait enough for SPI data to go out

      -- set all the DACs to the second value      
      W_EN_I        <= '1';
      wait until W_DONE_O = '1';
      W_EN_I        <= '0';
      WAIT for PERIOD*200;
      
      -- set all the DACs to the third value      
      W_EN_I        <= '1';
      wait until W_DONE_O = '1';
      W_EN_I        <= '0';
      WAIT for PERIOD*5;

      -- set all the DACs to the forth value      
      W_EN_I        <= '1';
      wait until W_DONE_O = '1';
      W_EN_I        <= '0';
      WAIT for PERIOD*5;

      -- set all the DACs to the forth value      
      W_EN_I        <= '1';
      wait until W_DONE_O = '1';
      W_EN_I        <= '0';
      WAIT for PERIOD*5;

      -- set all the DACs to the forth value      
      W_EN_I        <= '1';
      wait until W_DONE_O = '1';
      W_EN_I        <= '0';
      WAIT for PERIOD*5;

      assert FALSE report "Simulation done." severity failure;    
      wait;

   end process STIMULI;

end BEH;

configuration CFG_TB_AC_DAC_CTRL_TEST of TB_AC_DAC_CTRL_TEST is
   for BEH
   end for;
end CFG_TB_AC_DAC_CTRL_TEST;