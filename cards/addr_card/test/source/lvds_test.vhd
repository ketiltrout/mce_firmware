

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity LVDS_TEST is
port(
   dip3 : in std_logic;
   dip4 : in std_logic;
   nfault_led : out std_logic;
   status_led : out std_logic;
   pow_ok_led : out std_logic;

   lvds_clk : in std_logic;
   lvds_cmd : in std_logic;
   lvds_sync : in std_logic;
   lvds_spr : in std_logic;

   lvds_txa : out std_logic;
   lvds_txb : out std_logic
   );
end LVDS_TEST;

architecture BEH of LVDS_TEST is
begin
   status_led <= dip3;
   pow_ok_led <= dip4;
   lvds_txa <= lvds_clk;
   lvds_txb <= lvds_clk;
   nfault_led <= '1';
end BEH;
