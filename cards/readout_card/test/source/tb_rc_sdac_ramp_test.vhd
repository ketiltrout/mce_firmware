library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;
use work.rc_test_pack.all;

library sys_param;
use sys_param.wishbone_pack.all;

entity tb_rc_sdac_ramp_test is

end tb_rc_sdac_ramp_test;

architecture test of tb_rc_sdac_ramp_test is

component rc_sdac_ramp_test is
   port(
      rst_n : in std_logic;
      
      -- clock signals
      inclk  : in std_logic;
      outclk : out std_logic;
           
      -- rc serial dac interface
      dac_dat        : out std_logic_vector (7 downto 0); 
      dac_clk       : out std_logic_vector (7 downto 0);
      bias_dac_ncs   : out std_logic_vector (7 downto 0); 
      offset_dac_ncs : out std_logic_vector (7 downto 0); 

      mictor : out std_logic_vector(31 downto 0)
      );
end component rc_sdac_ramp_test;

   -- constant/signal declarations
   constant clk_period              :              time      := 20 ns;   -- 50 MHz clock period

   signal clk_i                     :              std_logic := '0';
   signal rst                       :              std_logic := '0';     -- global reset
   signal dac_dat                   :              std_logic_vector(7 downto 0);
   signal dac_clk                   :              std_logic_vector(7 downto 0);
   signal bias_dac_ncs              :              std_logic_vector(7 downto 0);
   signal offset_dac_ncs            :              std_logic_vector(7 downto 0);

   shared variable endsim           :              boolean   := false;   -- simulation window
   
begin
   
   rst <= '1' after 10 * clk_period;
   
   -- Generate a 50MHz clock (ie 20 ns period)
   clk_gen : process
   begin
      if not (endsim) then
         clk_i <= not clk_i;
         wait for clk_period/2;
      end if;
   end process clk_gen;

   sim_time : process
   begin
      wait for 4000*clk_period;
      endsim := true;
      report "Simulation Finished....."
      severity NOTE;
   end process sim_time;


   -- unit under test:  first stage feedback queue
   UUT : rc_sdac_ramp_test
      port map (
      rst_n  => rst,
      
      -- clock signals
      inclk  => clk_i,
      outclk => open,
           
      -- rc serial dac interface
      dac_dat => dac_dat,
      dac_clk => dac_clk,
      bias_dac_ncs => bias_dac_ncs,
      offset_dac_ncs =>offset_dac_ncs,

      mictor      => open

   );
   
end test;

