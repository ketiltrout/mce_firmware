library ieee, sys_param;
use ieee.std_logic_1164.all;
use sys_param.data_types_pack.all;

package ac_dac_ctrl_pack is

   -- Memory map for the dac_ctrl sram
   constant ON_VAL_BASE : std_logic_vector (7 downto 0) := x"00"; 
   constant OFF_VAL_BASE: std_logic_vector (7 downto 0) := x"2a";
   constant ROW_ORD_BASE: std_logic_vector (7 downto 0) := x"52";
   constant MUX_ON_BASE : std_logic_vector (7 downto 0) := x"6A";

   constant ROW_ORDER: int_array41 := (
    0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 
   20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 
   40   
   );
   
   type    w16_array41 is array (40 downto 0) of integer; -- for address card rows

end ac_dac_ctrl_pack;