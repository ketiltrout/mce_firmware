library IEEE;
use IEEE.std_logic_1164.all;

library components;
use components.component_pack.all;

entity TB_READ_DATA_1_WIRE is
end TB_READ_DATA_1_WIRE;

architecture BEH of TB_READ_DATA_1_WIRE is

   component READ_DATA_1_WIRE

      generic(DATA_LENGTH   : integer  := 8 );

      port(CLK            : in std_logic ;
           RST            : in std_logic ;
           READ_START_I   : in std_logic ;
           READ_DONE_O    : out std_logic ;
           READ_DATA_O    : out std_logic_vector ( DATA_LENGTH - 1 downto 0 );
           DATA_BI        : inout std_logic );

   end component;


   constant PERIOD : time := 20 ns;
   constant DATA_LENGTH : integer := 8;
   
   signal W_CLK            : std_logic  := '0';
   signal W_RST            : std_logic ;
   signal W_READ_START_I   : std_logic ;
   signal W_READ_DONE_O    : std_logic ;
   signal W_READ_DATA_O    : std_logic_vector ( DATA_LENGTH - 1 downto 0 );
   signal W_DATA_BI        : std_logic ;

begin

   DUT : READ_DATA_1_WIRE

      generic map(DATA_LENGTH   => 8 )

      port map(CLK            => W_CLK,
               RST            => W_RST,
               READ_START_I   => W_READ_START_I,
               READ_DONE_O    => W_READ_DONE_O,
               READ_DATA_O    => W_READ_DATA_O,
               DATA_BI        => W_DATA_BI);

   W_CLK <= not W_CLK after PERIOD/2;

   STIMULI : process
   procedure do_reset is
   begin
      W_DATA_BI         <= 'H';
      W_RST             <= '1';
      W_READ_START_I    <= '0';

      wait for PERIOD;
   end do_reset;
   
   procedure do_start is
   begin
      W_DATA_BI         <= 'H';      
      W_RST             <= '0';
      W_READ_START_I    <= '1';
      
      wait for PERIOD;
      
      W_READ_START_I    <= '0';
   end do_start;
   
   procedure do_read_1 is
   begin
      wait until W_DATA_BI = '0';
      wait for 5 us;
      
      W_DATA_BI <= 'H';
   end do_read_1;
   
   procedure do_read_0 is
   begin
      wait until W_DATA_BI = '0';
      wait for 5 us;
      
      W_DATA_BI <= '0';
      
      wait for 45 us;
      
      W_DATA_BI <= 'H';
   end do_read_0;
   
   begin
      
   do_reset;
   do_start;
   
   do_read_1;
   do_read_0;
   do_read_1;
   do_read_0;
   do_read_1;
   do_read_0;
   do_read_1;
   do_read_0;
   
   wait for 280 us;
   
   do_start;
   
   do_read_1;
   do_read_1;
   do_read_1;
   do_read_1;   
   do_read_1;
   do_read_1;
   do_read_1;
   do_read_1;   
      
   wait for 280 us;
   
   do_start;
   
   do_read_0;
   do_read_1;
   do_read_0;
   do_read_1;
   do_read_0;
   do_read_1;
   do_read_1;
   do_read_1;
   
   wait for 280 us;
   
   wait;
   
--      W_DATA_BI         <= 'H';      
--      W_RST             <= '0';
--      W_READ_START_I    <= '0';
--      
--      wait for 1 ms;
--      
--      W_DATA_BI         <= 'H';      
--      W_RST             <= '0';
--      W_READ_START_I    <= '1';
--      
--      wait for PERIOD;
--      
--      W_DATA_BI         <= 'H';      
--      W_RST             <= '0';
--      W_READ_START_I    <= '0';
--      
--      wait for 1 ms;
--      
--      W_DATA_BI         <= 'H';      
--      W_RST             <= '0';
--      W_READ_START_I    <= '1';
--      
--      wait for PERIOD;
--      
--      W_DATA_BI         <= 'H';      
--      W_RST             <= '0';
--      W_READ_START_I    <= '0';
--      
--      wait for 1 ms;
--      
--      W_DATA_BI         <= 'H';      
--      W_RST             <= '0';
--      W_READ_START_I    <= '1';
--      
--      wait for PERIOD;
--      
--      W_DATA_BI         <= 'H';      
--      W_RST             <= '0';
--      W_READ_START_I    <= '0';
--      
--      wait for 1 ms;
      
   end process STIMULI;
   
end BEH;

