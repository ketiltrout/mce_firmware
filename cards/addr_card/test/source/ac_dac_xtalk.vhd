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
-- Author:        Mandana Amiri
-- Organisation:      UBC
--
-- Description:
-- NOTE: THIS IS A SIMPLE implementation to make a ramp signal on the DAC outputs
--       once enable is received.
--
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library sys_param;
use sys_param.data_types_pack.all;

library components;
use components.component_pack.all;


entity ac_dac_xtalk is
   port (
      -- basic signals
      --rst_i     : in std_logic;    -- reset input
      inclk     : in std_logic;    -- clock input
      --en_i      : in std_logic;    -- enable signal
      --done_o    : out std_logic;   -- done ouput signal
      dip_sw3 : in std_logic;
      dip_sw4 : in std_logic;
      lvds_txa : out std_logic;
      lvds_txb : out std_logic;

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

      dac_clk   : out std_logic_vector(40 downto 0) );
end;

architecture rtl of ac_dac_xtalk is

-- DAC CTRL:
-- State encoding and state variables:

-- controller states:
signal data     : word14 := "00000000000000";
signal data2    : word14;
signal idac     : integer;
signal clkcount : std_logic;
signal nclk     : std_logic;
signal clk_2    : std_logic;
--signal clk_div  : integer;
signal low      : std_logic := '0';
signal high     : std_logic := '1';
signal dummy    : integer := 0;

type states is (EVEN, ODD);
signal ps : states;
signal ns : states;

component pll 
port(inclk0 : in std_logic;
     c0 : out std_logic;   -- 25 MHz
     c1 : out std_logic);  -- 0.5 MHz
end component;

signal clk0 : std_logic;
signal clk1 : std_logic;

signal clk_div : std_logic_vector(20 downto 0);

begin

   clk_pll : pll
   port map(inclk0 => inclk,
            c0 => clk0,
            c1 => clk1);

   process(clk1)
   begin
      if(clk1'event and clk1 = '1') then
         clk_div <= clk_div + 1;
      end if;
   end process;

   nclk <= not clk1;
      
   gen1: for idac in 0 to 40 generate
      dac_clk(idac) <= nclk;
   end generate gen1;

--     dac_clk(0) <= nclk;

   process(clk1)
   begin
      if(clk1'event and clk1 = '1') then
         if(data = "00000000000000") then
            data <= "11111111111111";
         else
            data <= "00000000000000";
         end if;
      end if;
   end process;

   data2 <= "11111111111111";

   dac_data0 <= data when dip_sw3 = '1' else data2;
   dac_data2 <= data when dip_sw3 = '1' else data2;
   dac_data4 <= data when dip_sw3 = '1' else data2;
   dac_data6 <= data when dip_sw3 = '1' else data2;
   dac_data8 <= data when dip_sw3 = '1' else data2;
   dac_data10 <= data when dip_sw3 = '1' else data2;

   dac_data1 <= data2 when dip_sw3 = '1' else data;
   dac_data3 <= data2 when dip_sw3 = '1' else data;
   dac_data5 <= data2 when dip_sw3 = '1' else data;
   dac_data7 <= data2 when dip_sw3 = '1' else data;
   dac_data9 <= data2 when dip_sw3 = '1' else data;

   lvds_txa <= inclk;
   lvds_txb <= inclk;
end;