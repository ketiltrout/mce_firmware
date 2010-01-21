LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
LIBRARY sys_param;
USE sys_param.command_pack.ALL;
PACKAGE card_type_pack IS
   constant BC_CARD_TYPE      : std_logic_vector(CARD_TYPE_WIDTH-1 downto 0) := BC_E_CARD_TYPE;
END card_type_pack;
