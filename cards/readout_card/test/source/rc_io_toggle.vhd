-- 2003 SCUBA-2 Project
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

-- ac_dac_ctrl_test.vhd
--
-- Project:       SCUBA-2
-- Author:        Bryce Burger
-- Organisation:      UBC
--
-- Description:
-- toggles many io at the 
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library sys_param;
use sys_param.data_types_pack.all;

entity rc_io_toggle is
   port (
      -- basic signals
      inclk     : in std_logic;    -- clock input

      -- lvds tx signals
      lvds_txa : out std_logic;
      lvds_txb : out std_logic;

      -- random IO      
      ttl_out   : out std_logic_vector(3 downto 1);
      ttl_dir   : out std_logic_vector(3 downto 1);
      
      -- extended signals
      -- rc serial dac interface
      dac_dat        : out std_logic_vector (7 downto 0); 
      dac_sclk       : out std_logic_vector (7 downto 0);
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
      
      -- sram pins
      sram_addr      : out std_logic_vector (19 downto 0);
      sram_data      : out std_logic_vector (15 downto 0);
      sram_nbhe      : out std_logic;
      sram_nble	     : out std_logic;
      sram_noe 	     : out std_logic;
      sram_nwe 	     : out std_logic;
      sram_ncs 	     : out std_logic;
      
--      pll5_out       : out std_logic(3 downto 0);
--      pll6_out       : out std_logic(3 downto 0);
      
      adc_clk	     : out std_logic(7 downto 0);
      eeprom_si      : out std_logic;
      eeprom_sck     : out std_logic;
      eeprom_cs      : out std_logic;      
      
      --test pins
      mictor	     : out std_logic_vector(31 downto 0)
      
   );
end;

architecture rtl of rc_io_toggle is

component pll_in25m_out50m1m 
port(inclk0 : in std_logic;
     c0 : out std_logic;   -- 50 MHz
     c1 : out std_logic);  -- 1 MHz
end component;

signal clk0 : std_logic;
signal clk1 : std_logic;

begin

   pll : pll_in25m_out50m1m
   port map(inclk0 => inclk,
            c0 => clk1,
            c1 => clk0);
            
   lvds_txa   <= clk0;
   lvds_txb   <= clk0;

   ttl_out    <= (others => clk0);
   ttl_dir    <= (others => clk0);

   dac_dat    <= (others => clk0);       
   dac_sclk   <= (others => clk0);    
   bias_dac_ncs   <= (others => clk0);   
   offset_dac_ncs <= (others => clk0); 

   dac_FB1_dat <= (others => clk0);
   dac_FB2_dat <= (others => clk0);
   dac_FB3_dat <= (others => clk0);
   dac_FB4_dat <= (others => clk0);
   dac_FB5_dat <= (others => clk0);
   dac_FB6_dat <= (others => clk0);
   dac_FB7_dat <= (others => clk0);
   dac_FB8_dat <= (others => clk0);
   dac_FB_clk  <= (others => clk0);

   -- sram pi  <= (others => clk0);
   sram_addr   <= (others => clk0);
   sram_data   <= (others => clk0);
   sram_nbhe   <= clk0;
   sram_nble   <= clk0;
   sram_noe    <= clk0;
   sram_nwe    <= clk0;
   sram_ncs    <= clk0;

   adc_clk     <= (others => '0');
   eeprom_si   <= clk0; 
   eeprom_sck  <= clk0;
   eeprom_cs   <= clk0;

   mictor      <= (others => '0');
end;