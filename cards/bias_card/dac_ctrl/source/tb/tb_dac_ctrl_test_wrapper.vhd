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

-- tb_dac_ctrl_test_wrapper.vhd
--

-- Project:	      SCUBA-2
-- Author:	      Mandana Amiri
-- Organisation:  UBC
--
-- Description:
-- testbench for the dac_ctrl wrapper, very simple: assert enable and wait for done!
--
-- 
-- Revision history:
-- <date $Date$>	- <initials $Author$>
-- $Log$   
--
-----------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity TB_DAC_CTRL_TEST_WRAPPER is
end TB_DAC_CTRL_TEST_WRAPPER;

architecture BEH of TB_DAC_CTRL_TEST_WRAPPER is

   component DAC_CTRL_TEST_WRAPPER
      port(RST_I       : in std_logic ;
           CLK_I       : in std_logic ;
           EN_I        : in std_logic ;
           DONE_O      : out std_logic ;
           TX_BUSY_I   : in std_logic ;
           TX_ACK_I    : in std_logic ;
           TX_DATA_O   : out std_logic_vector ( 7 downto 0 );
           TX_WE_O     : out std_logic ;
           TX_STB_O    : out std_logic ;
           DAC_DAT_O   : out std_logic_vector ( 32 downto 0 );
           DAC_NCS_O   : out std_logic_vector ( 32 downto 0 );
           DAC_CLK_O   : out std_logic_vector ( 32 downto 0 ) );

   end component;


   constant PERIOD : time := 20 ns;

   signal W_RST_I       : std_logic ;
   signal W_CLK_I       : std_logic := '0';
   signal W_EN_I        : std_logic ;
   signal W_DONE_O      : std_logic ;
   signal W_DAC_DAT_O   : std_logic_vector ( 32 downto 0 );
   signal W_DAC_NCS_O   : std_logic_vector ( 32 downto 0 );
   signal W_DAC_CLK_O   : std_logic_vector ( 32 downto 0 ) ;
   signal zero          : std_logic := '0';

begin

   DUT : DAC_CTRL_TEST_WRAPPER
      port map(RST_I       => W_RST_I,
               CLK_I       => W_CLK_I,
               EN_I        => W_EN_I,
               DONE_O      => W_DONE_O,
               TX_BUSY_I   => zero,
               TX_ACK_I    => zero,
               TX_DATA_O   => open,
               TX_WE_O     => open,
               TX_STB_O    => open,
               DAC_DAT_O   => W_DAC_DAT_O,
               DAC_NCS_O   => W_DAC_NCS_O,
               DAC_CLK_O   => W_DAC_CLK_O);

   W_CLK_I <= not W_CLK_I after PERIOD/2;

   STIMULI : process
   begin
-- we shouldn't reset the wrapper, because we want the next enable to    
--      W_RST_I       <= '0';
--      wait for PERIOD;
--      W_RST_        <= '1';
--      wait for PERIOD;
      W_RST_I       <= '0'      
      W_EN_I        <= '1';
      wait for W_DONE_O = '1';
      W_EN_I        <= '0';
      
   end process STIMULI;

end BEH;

configuration CFG_TB_DAC_CTRL_TEST_WRAPPER of TB_DAC_CTRL_TEST_WRAPPER is
   for BEH
   end for;
end CFG_TB_DAC_CTRL_TEST_WRAPPER;