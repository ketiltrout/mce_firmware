
library IEEE;
use IEEE.std_logic_1164.all;

entity TB_RS232_TX is
end TB_RS232_TX;

architecture BEH of TB_RS232_TX is

   component RS232_TX
      port(CLK_I        : in std_logic ;
           COMM_CLK_I   : in std_logic ;
           RST_I        : in std_logic ;
           DAT_I        : in std_logic_vector ( 7 downto 0 );
           START_I      : in std_logic ;
           DONE_O       : out std_logic ;
           RS232_O      : out std_logic );

   end component;


   constant PERIOD : time := 40 ns;
   constant COMM_PERIOD : time := 10 ns;

   signal W_CLK_I        : std_logic := '1';
   signal W_COMM_CLK_I   : std_logic := '1';
   signal W_RST_I        : std_logic ;
   signal W_DAT_I        : std_logic_vector ( 7 downto 0 );
   signal W_START_I      : std_logic ;
   signal W_DONE_O       : std_logic ;
   signal W_RS232_O      : std_logic ;

begin

   DUT : RS232_TX
      port map(CLK_I        => W_CLK_I,
               COMM_CLK_I   => W_COMM_CLK_I,
               RST_I        => W_RST_I,
               DAT_I        => W_DAT_I,
               START_I      => W_START_I,
               DONE_O       => W_DONE_O,
               RS232_O      => W_RS232_O);

   W_CLK_I <= not W_CLK_I after PERIOD/2;
   W_COMM_CLK_I <= not W_COMM_CLK_I after COMM_PERIOD/2;
   
   STIMULI : process
   procedure do_reset is
   begin
      W_RST_I        <= '1';
      W_DAT_I        <= (others => '0');
      W_START_I      <= '0';
      
      wait for PERIOD;
      
      W_RST_I        <= '0';
      W_DAT_I        <= (others => '0');
      W_START_I      <= '0';
      
      wait for PERIOD;
      
   end do_reset;
   
   procedure do_transmit (data : in std_logic_vector(7 downto 0)) is
   begin
      W_RST_I        <= '0';
      W_DAT_I        <= data;
      
      wait for PERIOD;
      
      W_START_I      <= '1';
      
--      wait for PERIOD;
--      
--      W_START_I      <= '0';
      
      wait until W_DONE_O = '1';
      
      wait for PERIOD;
      
   end do_transmit;   
   begin
   
      do_reset;
      
      do_transmit("11110000");
      do_transmit("00001111");
      do_transmit("01010101");
      do_transmit("11111100");
      
      wait for PERIOD;
      
      assert FALSE report "End of simulation." severity FAILURE;

--      W_RST_I        <= '0';
--      W_DAT_I        <= (others => '0');
--      W_START_I      <= '0';
--
      wait for PERIOD;
      wait;
   end process STIMULI;

end BEH;
