library IEEE;
use IEEE.std_logic_1164.all;

entity TB_CLOCK_DOMAIN_INTERFACE is
end TB_CLOCK_DOMAIN_INTERFACE;

architecture BEH of TB_CLOCK_DOMAIN_INTERFACE is

   component CLOCK_DOMAIN_INTERFACE

      generic(DATA_WIDTH   : integer  := 32 );

      port(RST_I       : in std_logic;
           SRC_CLK_I   : in std_logic ;
           SRC_DAT_I   : in std_logic_vector ( DATA_WIDTH - 1 downto 0 );
           SRC_RDY_I   : in std_logic ;
           SRC_ACK_O   : out std_logic ;
           DST_CLK_I   : in std_logic ;
           DST_DAT_O   : out std_logic_vector ( DATA_WIDTH - 1 downto 0 );
           DST_RDY_O   : out std_logic );

   end component;


   constant SRC_PERIOD : time := 5 ns;
   constant DST_PERIOD : time := 20 ns;

   signal W_RST_I       : std_logic ;
   signal W_SRC_CLK_I   : std_logic := '1';
   signal W_SRC_DAT_I   : std_logic_vector ( 31 downto 0 );
   signal W_SRC_RDY_I   : std_logic ;
   signal W_SRC_ACK_O   : std_logic ;
   signal W_DST_CLK_I   : std_logic := '1';
   signal W_DST_DAT_O   : std_logic_vector ( 31 downto 0 );
   signal W_DST_RDY_O   : std_logic ;

begin

   DUT : CLOCK_DOMAIN_INTERFACE

      generic map(DATA_WIDTH   => 32 )

      port map(RST_I       => W_RST_I,
               SRC_CLK_I   => W_SRC_CLK_I,
               SRC_DAT_I   => W_SRC_DAT_I,
               SRC_RDY_I   => W_SRC_RDY_I,
               SRC_ACK_O   => W_SRC_ACK_O,
               DST_CLK_I   => W_DST_CLK_I,
               DST_DAT_O   => W_DST_DAT_O,
               DST_RDY_O   => W_DST_RDY_O);

   W_SRC_CLK_I <= not W_SRC_CLK_I after SRC_PERIOD/2;
   W_DST_CLK_I <= not W_DST_CLK_I after DST_PERIOD/2;

   STIMULI : process
   begin
      W_RST_I <= '1';
      
      wait for SRC_PERIOD;
      
      W_RST_I <= '0';
      W_SRC_DAT_I   <= "11110000111100001010101001010101";
      W_SRC_RDY_I   <= '1';

      wait for SRC_PERIOD;
      
      W_SRC_RDY_I   <= '0';
      
      wait until W_SRC_ACK_O = '1';
      
      wait for SRC_PERIOD;
      
      
      
      
      W_SRC_DAT_I   <= "10101010010101011111000011110000";
      W_SRC_RDY_I   <= '1';

      wait for SRC_PERIOD;
      
      W_SRC_RDY_I   <= '0';
      
      wait until W_SRC_ACK_O = '1';
      
      wait for SRC_PERIOD;
      
      
      
      wait for SRC_PERIOD*10;
      
      assert false report "End of simulation." severity FAILURE;
      
      wait;
   end process STIMULI;

end BEH;