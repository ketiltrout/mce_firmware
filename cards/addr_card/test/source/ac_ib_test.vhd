-- Copyright (c) 2003 SCUBA-2 Project
--                  All Rights Reserved
--
--  THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF THE SCUBA-2 Project
--  The copyright notice above does not evidence any
--  actual or intended publication of such source code.
--
--  SOURCE CODE IS PROVIDED "AS IS". ALL EXPRESS OR IMPLIED CONDITIONS,
--  REPRESENTATIONS, AND WARRANTIES, INCLUDING ANY IMPLIED WARRANT OF
--  MERCHANTABILITY, SATISFACTORY QUALITY, FITNESS FOR A PARTICULAR
--  PURPOSE, OR NON-INFRINGEMENT, ARE DISCLAIMED, EXCEPT TO THE EXTENT
--  THAT SUCH DISCLAIMERS ARE HELD TO BE LEGALLY INVALID.
--
-- For the purposes of this code the SCUBA-2 Project consists of the
-- following organisations.
--
-- UKATC, Royal Observatory, Blackford Hill Edinburgh EH9 3HJ
-- UBC,   University of British Columbia, Physics & Astronomy Department,
--        Vancouver BC, V6T 1Z1
--
--
-- ac_ib_test.vhd
--
-- Project:	      SCUBA-2
-- Author:        Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Outputs a 1 MHz square wave from selected DAC onto Instrument Bus
--
-- Revision history:
-- 
-- $Log$
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity ac_ib_test is
port(inclk : in std_logic;
     outclk : out std_logic;

     test : in std_logic_vector(6 downto 1);

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

     dac_clk : out std_logic_vector(40 downto 0));
end ac_ib_test;

architecture rtl of ac_ib_test is

component ac_ib_test_pll
port(inclk0 : in std_logic;
     c0 : out std_logic;
     c1 : out std_logic;
     e0 : out std_logic);
end component;

signal clk : std_logic;
signal fastclk : std_logic;

signal sel : std_logic_vector(6 downto 1);

signal dac_clk_temp : std_logic_vector(40 downto 0);

type states is (OUT0, OUT1);
signal pres_state : states;
signal next_state : states;

begin
   clkgen : ac_ib_test_pll
   port map(inclk0 => inclk,
            c0 => clk,             -- 2 MHz clock output
            c1 => fastclk,         -- 50 MHz clock output (for debouncing)
            e0 => outclk);         -- 2 MHz external clock output
   
   -- debouncing switch input:
   debounce: process(fastclk)
   variable last : std_logic_vector(6 downto 1);
   variable count : integer;
   begin
      if(fastclk = '1') then
         if(count > 500000) then 
            count := 0;

            if(last = test) then
               sel <= not test;
            end if;

            last := test;
         else
            count := count + 1;
         end if;
      end if;
   end process debounce;
   
   -- Two state FSM to generate 1 MHz data outputs from 2 MHz clock:
   stateFF: process(clk)
   begin
      if(clk'event and clk = '1') then
         pres_state <= next_state;
      end if;
   end process stateFF;
   
   stateNS_Out: process(pres_state)
   begin
      if(pres_state = OUT0) then
         next_state <= OUT1;
         
         dac_data0  <= (others => '0');
         dac_data1  <= (others => '0');
         dac_data2  <= (others => '0');
         dac_data3  <= (others => '0');
         dac_data4  <= (others => '0');
         dac_data5  <= (others => '0');
         dac_data6  <= (others => '0');
         dac_data7  <= (others => '0');
         dac_data8  <= (others => '0');
         dac_data9  <= (others => '0');
         dac_data10 <= (others => '0');
         
      else
         next_state <= OUT0;
         
         dac_data0  <= (others => '1');
         dac_data1  <= (others => '1');
         dac_data2  <= (others => '1');
         dac_data3  <= (others => '1');
         dac_data4  <= (others => '1');
         dac_data5  <= (others => '1');
         dac_data6  <= (others => '1');
         dac_data7  <= (others => '1');
         dac_data8  <= (others => '1');
         dac_data9  <= (others => '1');
         dac_data10 <= (others => '1');

      end if;
   end process stateNS_Out;

   -- 2 MHz DAC clk outputs, based on switch value:
   -- clk is inverted so that rising edge is in middle of data period.
   dac_clk(0)  <= not clk when sel(6 downto 1) = "000000" else '0';
   dac_clk(1)  <= not clk when sel(6 downto 1) = "000001" else '0';
   dac_clk(2)  <= not clk when sel(6 downto 1) = "000010" else '0';
   dac_clk(3)  <= not clk when sel(6 downto 1) = "000011" else '0';
   dac_clk(4)  <= not clk when sel(6 downto 1) = "000100" else '0';
   dac_clk(5)  <= not clk when sel(6 downto 1) = "000101" else '0';
   dac_clk(6)  <= not clk when sel(6 downto 1) = "000110" else '0';
   dac_clk(7)  <= not clk when sel(6 downto 1) = "000111" else '0';
   dac_clk(8)  <= not clk when sel(6 downto 1) = "001000" else '0';
   dac_clk(9)  <= not clk when sel(6 downto 1) = "001001" else '0';
   dac_clk(10) <= not clk when sel(6 downto 1) = "001010" else '0';
   dac_clk(11) <= not clk when sel(6 downto 1) = "001011" else '0';
   dac_clk(12) <= not clk when sel(6 downto 1) = "001100" else '0';
   dac_clk(13) <= not clk when sel(6 downto 1) = "001101" else '0';
   dac_clk(14) <= not clk when sel(6 downto 1) = "001110" else '0';
   dac_clk(15) <= not clk when sel(6 downto 1) = "001111" else '0';
   dac_clk(16) <= not clk when sel(6 downto 1) = "010000" else '0';
   dac_clk(17) <= not clk when sel(6 downto 1) = "010001" else '0';
   dac_clk(18) <= not clk when sel(6 downto 1) = "010010" else '0';
   dac_clk(19) <= not clk when sel(6 downto 1) = "010011" else '0';
   dac_clk(20) <= not clk when sel(6 downto 1) = "010100" else '0';
   dac_clk(21) <= not clk when sel(6 downto 1) = "010101" else '0';
   dac_clk(22) <= not clk when sel(6 downto 1) = "010110" else '0';
   dac_clk(23) <= not clk when sel(6 downto 1) = "010111" else '0';
   dac_clk(24) <= not clk when sel(6 downto 1) = "011000" else '0';
   dac_clk(25) <= not clk when sel(6 downto 1) = "011001" else '0';
   dac_clk(26) <= not clk when sel(6 downto 1) = "011010" else '0';
   dac_clk(27) <= not clk when sel(6 downto 1) = "011011" else '0';
   dac_clk(28) <= not clk when sel(6 downto 1) = "011100" else '0';
   dac_clk(29) <= not clk when sel(6 downto 1) = "011101" else '0';
   dac_clk(30) <= not clk when sel(6 downto 1) = "011110" else '0';
   dac_clk(31) <= not clk when sel(6 downto 1) = "011111" else '0';
   dac_clk(32) <= not clk when sel(6 downto 1) = "100000" else '0';
   dac_clk(33) <= not clk when sel(6 downto 1) = "100001" else '0';
   dac_clk(34) <= not clk when sel(6 downto 1) = "100010" else '0';
   dac_clk(35) <= not clk when sel(6 downto 1) = "100011" else '0';
   dac_clk(36) <= not clk when sel(6 downto 1) = "100100" else '0';
   dac_clk(37) <= not clk when sel(6 downto 1) = "100101" else '0';
   dac_clk(38) <= not clk when sel(6 downto 1) = "100110" else '0';
   dac_clk(39) <= not clk when sel(6 downto 1) = "100111" else '0';
   dac_clk(40) <= not clk when sel(6 downto 1) = "101000" else '0';

end rtl;