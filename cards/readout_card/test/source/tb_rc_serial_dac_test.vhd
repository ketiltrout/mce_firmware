library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;
use work.rc_test_pack.all;

library sys_param;
use sys_param.wishbone_pack.all;

entity tb_rc_serial_dac_test is

end tb_rc_serial_dac_test;

architecture test of tb_rc_serial_dac_test is
component pll
   port(inclk0 : in std_logic;
        c0 : out std_logic;
        c1 : out std_logic;
        e0 : out std_logic);
end component;

  -- RC Serial DACs
    
  component rc_serial_dac_test_wrapper
     port (
        -- basic signals
          rst_i     : in std_logic;    -- reset input
          clk_i     : in std_logic;    -- clock input
          clk_4_i   : in std_logic;    -- spi clock input
          en_i      : in std_logic;    -- enable signal
          mode      : in std_logic_vector (1 downto 0);
          done_o    : out std_logic;   -- done ouput signal
          
          -- transmitter signals removed!
          
          -- extended signals
          dac_clk_o : out std_logic_vector (7 downto 0);
          dac_dat_o : out std_logic_vector (7 downto 0); 
          dac_ncs_o : out std_logic_vector (7 downto 0)                    
          );   
  end component;  

   -- constant/signal declarations
   constant clk_period              :              time      := 20 ns;   -- 50 MHz clock period

   signal inclk                     :              std_logic := '0';
   signal clk                       :              std_logic := '0';
   signal clk_4                     :              std_logic := '0';
   signal rst                       :              std_logic := '1';     -- global reset
   signal dac_dat                   :              std_logic_vector(7 downto 0);
   signal dac_clk                   :              std_logic_vector(7 downto 0);
   signal bias_dac_ncs              :              std_logic_vector(7 downto 0);
   signal offset_dac_ncs            :              std_logic_vector(7 downto 0);
   signal done                      :              std_logic;
   signal en                        :              std_logic; 
   signal dac_test_mode             :              std_logic_vector(1 downto 0) := "01";
   signal test_dac_ncs              :              std_logic_vector (7 downto 0);
   signal test_dac_clk              :              std_logic_vector (7 downto 0);
   signal test_dac_data             :              std_logic_vector (7 downto 0);   
   
   shared variable endsim           :              boolean   := false;   -- simulation window
   
begin
   
   rst <= '0' after 10 * clk_period;
   
   -- Generate a 50MHz clock (ie 20 ns period)
   clk_gen : process
   begin
      if not (endsim) then
         inclk <= not inclk;
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

   en_gen: process
   begin
      wait until rst = '0';
      en <= '1';
      wait for clk_period;
      en <= '0';
      wait until done = '1';      
   end process en_gen;


   -- unit under test:  rc_serial_dac_test_wrapper
   uut : rc_serial_dac_test_wrapper
      port map(
               -- basic signals
               rst_i     => rst,
               clk_i     => clk,
               clk_4_i   => clk_4,
               en_i      => en,
               mode      => dac_test_mode,
               done_o    => done,
               
               -- extended signals
               dac_clk_o => test_dac_clk,
               dac_dat_o => test_dac_data,
               dac_ncs_o => test_dac_ncs);
   
      inclk_gen : pll
      port map(inclk0 => inclk,
               c0 => clk,
               c1 => clk_4,
               e0 => open);

end test;

