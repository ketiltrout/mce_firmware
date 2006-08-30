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

-- tb_bc_dac_xtalk_test.vhd
--

-- Project:	      SCUBA-2
-- Author:	      Mandana Amiri
-- Organisation:  UBC
--
-- Description:
-- testbench for the bc_dac_xtalk_test, very simple: assert enable and wait for done!
--
-- Revision history:
-- <date $Date$>	- <initials $Author$>
-- $Log$
--  
-----------------------------------------------------------------------------
library IEEE, sys_param, components;
use IEEE.std_logic_1164.all;
use components.component_pack.all;
use sys_param.data_types_pack.all;

library work;
use work.bc_test_pack.all;

entity TB_BC_DAC_XTALK_TEST is
end TB_BC_DAC_XTALK_TEST;

architecture BEH of TB_BC_DAC_XTALK_TEST is

   constant PERIOD : time := 20 ns;

   signal W_RST_I         : std_logic ;
   signal W_CLK_I         : std_logic := '0';
   signal W_CLK_4_I       : std_logic := '0';
   signal W_MODE_I        : std_logic := '0';
   signal W_EN_I          : std_logic ;
   signal W_DONE_O        : std_logic ;
   signal W_DAC_DAT_O     : std_logic_vector(31 downto 0);
   signal W_DAC_NCS_O     : std_logic_vector(31 downto 0);
   signal W_DAC_CLK_O     : std_logic_vector(31 downto 0);
   signal W_LVDS_DAC_DAT_O: std_logic;
   signal W_LVDS_DAC_NCS_O: std_logic;
   signal W_LVDS_DAC_CLK_O: std_logic;
   signal W_SPI_START_O   : std_logic;   

begin

   DUT :  bc_dac_xtalk_test_wrapper
      port map(
               -- basic signals
               rst_i     => W_RST_I,
               clk_i     => W_CLK_I,
               clk_4_i   => W_CLK_4_I,
               mode_i    => W_MODE_I,
               en_i      => W_EN_I,
               done_o    => W_DONE_O,
               -- extended signals
               dac_dat_o  => W_DAC_DAT_O,
               dac_ncs_o  => W_DAC_NCS_O,
               dac_clk_o  => W_DAC_CLK_O,
              
               lvds_dac_dat_o=> W_LVDS_DAC_DAT_O,
               lvds_dac_ncs_o=> W_LVDS_DAC_NCS_O,
               lvds_dac_clk_o=> W_LVDS_DAC_CLK_O,
               
               spi_start_o  => W_SPI_START_O
            );     

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

      -- enable module
      W_EN_I        <= '1';     
      W_MODE_I      <= '0';
      wait until W_DONE_O = '1';
      W_EN_I        <= '0';
      wait for PERIOD*50000;
      
      -- enable module
      W_EN_I        <= '1';
      W_MODE_I      <= '1';
      wait until W_DONE_O = '1';
      W_EN_I        <= '0';
      wait for PERIOD*50000;
      
      --enable module
      W_EN_I        <= '1';     
      wait until W_DONE_O = '1';
      W_EN_I        <= '0';
      wait for PERIOD*50000;
      assert FALSE report "Simulation done." severity failure;    

   end process STIMULI;

end BEH;

configuration CFG_TB_BC_DAC_XTALK_TEST of TB_BC_DAC_XTALK_TEST is
   for BEH
   end for;
end CFG_TB_BC_DAC_XTALK_TEST;