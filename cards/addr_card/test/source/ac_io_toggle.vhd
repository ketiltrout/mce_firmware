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

entity ac_io_toggle is
   port (
      -- basic signals
      inclk     : in std_logic;    -- clock input

      -- lvds tx signals
      lvds_txa : out std_logic;
      lvds_txb : out std_logic;

      -- random IO
      mictor : out std_logic_vector(32 downto 1);      
      mictorclk : out std_logic_vector(2 downto 1);
      test : out std_logic_vector(16 downto 3);
      ttl_tx : out std_logic_vector(3 downto 1);
      ttl_txena : out std_logic_vector(3 downto 1);

      -- extended signals
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
      dac_clk   : out std_logic_vector(40 downto 0)
   );
end;

architecture rtl of ac_io_toggle is

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

   dac_clk    <= (others => clk0);
   dac_data0  <= (others => clk0);
   dac_data2  <= (others => clk0);
   dac_data4  <= (others => clk0);
   dac_data6  <= (others => clk0);
   dac_data8  <= (others => clk0);
   dac_data10 <= (others => clk0);
   dac_data1  <= (others => clk0);
   dac_data3  <= (others => clk0);
   dac_data5  <= (others => clk0);
   dac_data7  <= (others => clk0);
   dac_data9  <= (others => clk0);

   mictor     <= (others => clk0);
   mictorclk  <= (others => clk0);
   test       <= (others => clk0);
   ttl_tx     <= (others => clk0);
   ttl_txena  <= (others => '0');

   lvds_txa   <= clk0;
   lvds_txb   <= clk0;
end;