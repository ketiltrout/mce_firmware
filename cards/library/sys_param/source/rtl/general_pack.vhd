library ieee;
use ieee.std_logic_1164.all;

package general_pack is

   -- clock card global fpga clock:  50 MHz  
   -- (pls modify both parameters if you change the clock frequency)
   constant CLOCK_PERIOD_NS : integer := 20;
   constant CLOCK_PERIOD    : time    := 20 ns;
   
   -- max and min allowable DAC settings on Bias card
   constant MAX_FLUX_FB      : std_logic_vector (15 downto 0) := x"FFFF";
   constant MIN_FLUX_FB      : std_logic_vector (15 downto 0) := x"0000";
   constant MAX_BIAS         : std_logic_vector (15 downto 0) := x"FFFF";
   constant MIN_BIAS         : std_logic_vector (15 downto 0) := x"0000";
   
end general_pack;