
library IEEE;
use IEEE.std_logic_1164.all;

library components;
use components.component_pack.all;

entity TB_CRC is
end TB_CRC;

architecture BEH of TB_CRC is

   component CRC

      generic(DATA_LENGTH   : integer  := 64 );

      port(CLK           : in std_logic ;
           RST           : in std_logic ;
           CRC_START_I   : in std_logic ;
           CRC_DONE_O    : out std_logic ;
           CRC_DATA_I        : in std_logic_vector ( DATA_LENGTH - 1 downto 0 );
           VALID_O       : out std_logic );
--           VALUE_O       : out std_logic_vector ( 7 downto 0 );
--           COUNT_O       : out integer );

   end component;


   constant PERIOD : time := 20 ns;
   constant DATA_LENGTH : integer := 64;
   
   signal W_CLK           : std_logic  := '0';
   signal W_RST           : std_logic ;
   signal W_CRC_START_I   : std_logic ;
   signal W_CRC_DONE_O    : std_logic ;
   signal W_CRC_DATA_I        : std_logic_vector ( DATA_LENGTH - 1 downto 0 );
   signal W_VALID_O       : std_logic ;
--   signal W_VALUE_O       : std_logic_vector ( 7 downto 0 );
--   signal W_COUNT_O       : integer ;

begin

   DUT : CRC

      generic map(DATA_LENGTH   => 64 )

      port map(CLK           => W_CLK,
               RST           => W_RST,
               CRC_START_I   => W_CRC_START_I,
               CRC_DONE_O    => W_CRC_DONE_O,
               CRC_DATA_I        => W_CRC_DATA_I,
               VALID_O       => W_VALID_O);
--               VALUE_O       => W_VALUE_O,
--               COUNT_O       => W_COUNT_O);

   W_CLK <= not W_CLK after PERIOD/2;

   STIMULI : process
   begin
      W_RST           <= '1';
      W_CRC_START_I   <= '0';
      W_CRC_DATA_I        <= (others => '0');
      
      wait for PERIOD;
      
      W_RST           <= '0';
      W_CRC_START_I   <= '0';
      W_CRC_DATA_I        <= "0101010111110110101110100010100111101111111111100000000000001110";

      wait for PERIOD;
 
      W_RST           <= '0';
      W_CRC_START_I   <= '1';
      W_CRC_DATA_I        <= "1000100011111111000000000000000011111111000000001111111100000000";
      
      wait for PERIOD;
      
      W_RST           <= '0';
      W_CRC_START_I   <= '0';
      W_CRC_DATA_I        <= (others => '0');
      
--      W_CRC_DATA_I    <= "1000100011111111000000000000000011111111000000001111111100000000";
            
      wait for PERIOD*10;
      
      W_CRC_START_I   <= '1';
      W_CRC_DATA_I        <= (others => '0');
      
      wait for PERIOD;
      
      W_CRC_START_I   <= '0';
      
      wait for PERIOD*80;
      

      assert false report "Simulation done." severity failure;
      
      wait;
   end process STIMULI;

end BEH;

configuration CFG_TB_CRC of TB_CRC is
   for BEH
   end for;
end CFG_TB_CRC;
