library ieee;
use ieee.std_logic_1164.all;

package general_pack is

   -- clock card global fpga clock:  50 MHz  
   -- (pls modify both parameters if you change the clock frequency)
   constant CLOCK_PERIOD_NS : integer := 20;
   constant CLOCK_PERIOD    : time    := 20 ns;
   
end general_pack;