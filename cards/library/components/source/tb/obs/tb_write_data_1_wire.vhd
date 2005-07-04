library IEEE;
use IEEE.std_logic_1164.all;

library components;
use components.component_pack.all;

entity TB_WRITE_DATA_1_WIRE is
end TB_WRITE_DATA_1_WIRE;

architecture BEH of TB_WRITE_DATA_1_WIRE is

   component WRITE_DATA_1_WIRE

      generic(DATA_LENGTH   : integer  := 8 );

      port(CLK             : in std_logic ;
           RST             : in std_logic ;
           WRITE_START_I   : in std_logic ;
           WRITE_DONE_O    : out std_logic ;
           WRITE_DATA_I    : in std_logic_vector ( DATA_LENGTH - 1 downto 0 );
           DATA_BI         : inout std_logic );

   end component;


   constant PERIOD : time := 20 ns;
   constant DATA_LENGTH : integer := 8;

   signal W_CLK             : std_logic  := '0';
   signal W_RST             : std_logic ;
   signal W_WRITE_START_I   : std_logic ;
   signal W_WRITE_DONE_O    : std_logic ;
   signal W_WRITE_DATA_I    : std_logic_vector ( DATA_LENGTH - 1 downto 0 );
   signal W_DATA_BI         : std_logic ;

begin

   DUT : WRITE_DATA_1_WIRE

      generic map(DATA_LENGTH   => 8 )

      port map(CLK             => W_CLK,
               RST             => W_RST,
               WRITE_START_I   => W_WRITE_START_I,
               WRITE_DONE_O    => W_WRITE_DONE_O,
               WRITE_DATA_I    => W_WRITE_DATA_I,
               DATA_BI         => W_DATA_BI);

   W_CLK <= not W_CLK after PERIOD/2;

   STIMULI : process

   begin
      W_DATA_BI         <= 'H';
      W_RST             <= '1';
      W_WRITE_START_I   <= '0';
      W_WRITE_DATA_I    <= (others => '0');

      wait for PERIOD;

      W_DATA_BI         <= 'H';      
      W_RST             <= '0';
      W_WRITE_START_I   <= '1';
      W_WRITE_DATA_I    <= "11100011";
      
      wait for PERIOD;
      
      W_DATA_BI         <= 'H';      
      W_RST             <= '0';
      W_WRITE_START_I   <= '0';
      W_WRITE_DATA_I    <= (others => '0');
      
      wait for 1 ms;
      
      W_DATA_BI         <= 'H';      
      W_RST             <= '0';
      W_WRITE_START_I   <= '1';
      W_WRITE_DATA_I    <= "01010111";
      
      wait for PERIOD;
      
      W_DATA_BI         <= 'H';      
      W_RST             <= '0';
      W_WRITE_START_I   <= '0';
      W_WRITE_DATA_I    <= (others => '0');
      
      wait for 1 ms;
      
      W_DATA_BI         <= 'H';      
      W_RST             <= '0';
      W_WRITE_START_I   <= '1';
      W_WRITE_DATA_I    <= "00000000";
      
      wait for PERIOD;
      
      W_DATA_BI         <= 'H';      
      W_RST             <= '0';
      W_WRITE_START_I   <= '0';
      W_WRITE_DATA_I    <= (others => '0');
      
      wait for 1 ms;
      
      W_DATA_BI         <= 'H';      
      W_RST             <= '0';
      W_WRITE_START_I   <= '1';
      W_WRITE_DATA_I    <= "11111111";
      
      wait for PERIOD;
      
      W_DATA_BI         <= 'H';      
      W_RST             <= '0';
      W_WRITE_START_I   <= '0';
      W_WRITE_DATA_I    <= (others => '0');
      
      wait for 1 ms;
      
   end process STIMULI;

end BEH;

