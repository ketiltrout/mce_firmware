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

      -- extended signals
      dac_dat0  : out std_logic_vector(13 downto 0);
      dac_dat1  : out std_logic_vector(13 downto 0);
      dac_dat2  : out std_logic_vector(13 downto 0);
      dac_dat3  : out std_logic_vector(13 downto 0);
      dac_dat4  : out std_logic_vector(13 downto 0);
      dac_dat5  : out std_logic_vector(13 downto 0);
      dac_dat6  : out std_logic_vector(13 downto 0);
      dac_dat7  : out std_logic_vector(13 downto 0);
      dac_dat8  : out std_logic_vector(13 downto 0);
      dac_dat9  : out std_logic_vector(13 downto 0);
      dac_dat10 : out std_logic_vector(13 downto 0);

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
     c0 : out std_logic;   -- 50 MHz
     c1 : out std_logic);  -- 1 MHz
end component;

signal clk0 : std_logic;
signal clk1 : std_logic;

signal clk_div : std_logic_vector(20 downto 0);

begin

   clk_pll : pll
   port map(inclk0 => inclk,
            c0 => clk0,
            c1 => clk1);

-- instantiate a counter to divide the clock by 40x
--   clk_div_2: counter
--   generic map(MAX => 20)
--   port map(clk_i   => clk0,
--            rst_i   => low,
--            ena_i   => high,
--            load_i  => low,
--            down_i  => low,
--            count_i => dummy,
--            count_o => clk_div);
--
--   clk_2   <= '1' when clk_div > 10 else '0'; -- slow down the 50MHz clock to 50/40MHz
--   clkcount <= clk_2;
--   nclk <= not (clkcount);

   process(clk1)
   begin
      if(clk1'event and clk1 = '1') then
         clk_div <= clk_div + 1;
      end if;
   end process;

   nclk <= clk_div(0);
      
   gen1: for idac in 0 to 40 generate
      dac_clk(idac) <= nclk;
   end generate gen1;

--   process(dip_sw3, clk_2)
--   begin
--      if(dip_sw3 = '0') then
--         if(clk_2 = '0') then
--            data <= "11111111111111";
--         else
--            data <= "00000000000000";
--         end if;
--         data2 <= "10000000000000";
--      else
--         if(clk_2 = '0') then
--            data2 <= "11111111111111";
--         else
--            data2 <= "00000000000000";
--         end if;
--         data <= "10000000000000";
--      end if;
--   end process;

   process(clk_div(0))
   begin
      if(clk_div(0)'event and clk_div(0) = '1') then
         data <= not data;
      end if;
   end process;

--   data <= clk_div(0) & clk_div(0) & clk_div(0) & clk_div(0) & clk_div(0) & clk_div(0) & clk_div(0) & clk_div(0) & clk_div(0) & clk_div(0) & clk_div(0) & clk_div(0) & clk_div(0) & clk_div(0);

   data2 <= "10000000000000";


   dac_dat0 <= data when dip_sw3 = '1' else data2;
   dac_dat2 <= data when dip_sw3 = '1' else data2;
   dac_dat4 <= data when dip_sw3 = '1' else data2;
   dac_dat6 <= data when dip_sw3 = '1' else data2;
   dac_dat8 <= data when dip_sw3 = '1' else data2;
   dac_dat10 <= data when dip_sw3 = '1' else data2;

   dac_dat1 <= data2 when dip_sw3 = '1' else data;
   dac_dat3 <= data2 when dip_sw3 = '1' else data;
   dac_dat5 <= data2 when dip_sw3 = '1' else data;
   dac_dat7 <= data2 when dip_sw3 = '1' else data;
   dac_dat9 <= data2 when dip_sw3 = '1' else data;
end;