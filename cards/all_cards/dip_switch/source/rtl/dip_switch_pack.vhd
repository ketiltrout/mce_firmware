
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library sys_param;
use sys_param.wishbone_pack.all;

package dip_switch_pack is

   constant DIP_SWITCH_BITS : integer := 8;
  
   component dip_switch      
      port(dip_switch_i : in std_logic_vector(DIP_SWITCH_BITS-1 downto 0);
     
           -- wishbone signals:
           clk_i : in std_logic;
           rst_i : in std_logic;
           dat_i : in std_logic_vector(WB_DATA_WIDTH - 1 downto 0);
           addr_i : in std_logic_vector(WB_ADDR_WIDTH - 1 downto 0);
           we_i : in std_logic;
           stb_i : in std_logic;
           cyc_i : in std_logic;
           dat_o : out std_logic_vector(WB_DATA_WIDTH - 1 downto 0);
           ack_o : out std_logic);
   end component;

end dip_switch_pack;