
library IEEE;
use IEEE.std_logic_1164.all;

library components;
use components.component_pack.all;

entity TB_US_TIMER is
end TB_US_TIMER;

architecture BEH of TB_US_TIMER is

   component US_TIMER
      port(CLK             : in std_logic ;
           TIMER_RESET_I   : in std_logic ;
           TIMER_COUNT_O   : out integer );

   end component;


   constant PERIOD : time := 20 ns;

   signal W_CLK             : std_logic  := '1';
   signal W_TIMER_RESET_I   : std_logic ;
   signal W_TIMER_COUNT_O   : integer ;

begin

   DUT : US_TIMER
      port map(CLK             => W_CLK,
               TIMER_RESET_I   => W_TIMER_RESET_I,
               TIMER_COUNT_O   => W_TIMER_COUNT_O);

   W_CLK <= not W_CLK after PERIOD/2;

   STIMULI : process
   procedure reset is
   begin
      W_TIMER_RESET_I   <= '1';
      wait for PERIOD;
      
      W_TIMER_RESET_I   <= '0';
   end reset;
   
   
   begin
      reset;
      
      wait for 750 ns;      
      
      reset;
      
      wait for 2 us;
      
      reset;
      
      wait for 10 us;
      
      assert false report "End of Simulation" severity failure;
      
   end process STIMULI;
end BEH;
