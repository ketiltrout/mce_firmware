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
-- <date $Date: 2004/05/19 18:35:19 $>	- <initials $Author: mandana $>
-- $Log: tb_dac_ctrl_test_wrapper.vhd,v $
-- Revision 1.5  2004/05/19 18:35:19  mandana
-- deleted nclr pin on DACs, it is tied to FPGA status
-- added ramp test
--
-- Revision 1.4  2004/04/29 20:53:59  mandana
-- added dac_nclr signal and removed tx signals from wrapper
--
-- Revision 1.3  2004/04/23 00:53:26  mandana
-- Sends enable signal 4 times(i.e. 4 DAC values examined)
--
-- Revision 1.2  2004/04/21 20:28:50  mandana
-- fixed errors
--
-- Revision 1.1  2004/04/21 20:00:27  mandana
-- Initial release
--   
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
           DAC_DAT_O   : out std_logic_vector ( 31 downto 0 );
           DAC_NCS_O   : out std_logic_vector ( 31 downto 0 );
           DAC_CLK_O   : out std_logic_vector ( 31 downto 0 );
           lvds_dac_dat_o: out std_logic;
           lvds_dac_ncs_o: out std_logic;
           lvds_dac_clk_o: out std_logic
      );

   end component;


   constant PERIOD : time := 20 ns;

   signal W_RST_I       : std_logic ;
   signal W_CLK_I       : std_logic := '0';
   signal W_EN_I        : std_logic ;
   signal W_DONE_O      : std_logic ;
   signal W_DAC_DAT_O   : std_logic_vector ( 31 downto 0 );
   signal W_DAC_NCS_O   : std_logic_vector ( 31 downto 0 );
   signal W_DAC_CLK_O   : std_logic_vector ( 31 downto 0 ) ;
   signal W_LVDS_DAC_DAT_O  : std_logic;
   signal W_LVDS_DAC_NCS_O  : std_logic;
   signal W_LVDS_DAC_CLK_O  : std_logic;
   
   signal zero          : std_logic := '0';

begin

   DUT : DAC_CTRL_TEST_WRAPPER
      port map(RST_I       => W_RST_I,
               CLK_I       => W_CLK_I,
               EN_I        => W_EN_I,
               DONE_O      => W_DONE_O,
               DAC_DAT_O   => W_DAC_DAT_O,
               DAC_NCS_O   => W_DAC_NCS_O,
               DAC_CLK_O   => W_DAC_CLK_O,
               lvds_dac_dat_o => W_LVDS_DAC_DAT_O,
	       lvds_dac_ncs_o => W_LVDS_DAC_NCS_O,
	       lvds_dac_clk_o => W_LVDS_DAC_CLK_O

               );

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
      WAIT for PERIOD*200; -- wait enough for SPI data to go out

      -- set all the DACs to the second value      
      W_EN_I        <= '1';
      wait until W_DONE_O = '1';
      W_EN_I        <= '0';
      WAIT for PERIOD*200;
      
      -- set all the DACs to the third value      
      W_EN_I        <= '1';
      wait until W_DONE_O = '1';
      W_EN_I        <= '0';
      WAIT for PERIOD*200;

      -- set all the DACs to the fourth value      
      W_EN_I        <= '1';
      wait until W_DONE_O = '1';
      W_EN_I        <= '0';
      WAIT for PERIOD*200;

      -- set LVDS DAC
      W_EN_I        <= '1';
      wait until W_DONE_O = '1';
      W_EN_I        <= '0';
      WAIT for PERIOD*200;

      -- RAMP Test
      W_EN_I        <= '1';
      wait until W_DONE_O = '1';
      W_EN_I        <= '0';
      WAIT for PERIOD*200;

      -- RAMP Test
      W_EN_I        <= '1';
      wait until W_DONE_O = '1';
      W_EN_I        <= '0';
      WAIT for PERIOD*200;

      -- RAMP Test
      W_EN_I        <= '1';
      wait until W_DONE_O = '1';
      W_EN_I        <= '0';
      WAIT for PERIOD*200;

      -- RAMP Test
      W_EN_I        <= '1';
      wait until W_DONE_O = '1';
      W_EN_I        <= '0';
      WAIT for PERIOD*200;
      
      assert FALSE report "Simulation done." severity failure;    
      wait;

   end process STIMULI;

end BEH;

configuration CFG_TB_DAC_CTRL_TEST_WRAPPER of TB_DAC_CTRL_TEST_WRAPPER is
   for BEH
   end for;
end CFG_TB_DAC_CTRL_TEST_WRAPPER;