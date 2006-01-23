
library IEEE;
use IEEE.std_logic_1164.all;

entity TB_SMB_TEST is
end TB_SMB_TEST;

architecture BEH of TB_SMB_TEST is

   component SMB_TEST
      port(CLK_I       : in std_logic ;
           NRST_I      : in std_logic ;
           SMBCLK_O    : out std_logic ;
           SMBDAT_IO   : inout std_logic ;
           TESTCLK_O   : out std_logic ;
           ONES_O      : out std_logic_vector ( 6 downto 0 );
           TENS_O      : out std_logic_vector ( 6 downto 0 ) );

   end component;


   constant PERIOD : time := 20 ns;

   signal W_CLK_I       : std_logic := '1';
   signal W_NRST_I      : std_logic ;
   signal W_SMBCLK_O    : std_logic ;
   signal W_SMBDAT_IO   : std_logic ;
   signal W_TESTCLK_O   : std_logic ;
   signal W_ONES_O      : std_logic_vector ( 6 downto 0 );
   signal W_TENS_O      : std_logic_vector ( 6 downto 0 ) ;

begin

   DUT : SMB_TEST
      port map(CLK_I       => W_CLK_I,
               NRST_I      => W_NRST_I,
               SMBCLK_O    => W_SMBCLK_O,
               SMBDAT_IO   => W_SMBDAT_IO,
               TESTCLK_O   => W_TESTCLK_O,
               ONES_O      => W_ONES_O,
               TENS_O      => W_TENS_O);

   W_CLK_I <= not W_CLK_I after PERIOD/2;

   W_SMBCLK_O <= 'H';
   W_SMBDAT_IO <= 'H';
    
   STIMULI : process
   begin
      W_NRST_I      <= '0';

      wait for PERIOD;
      
      W_NRST_I      <= '1';
      
      wait for 5 ms;
      
      assert false report "End of simulation." severity failure;
      
      wait;
   end process STIMULI;

end BEH;