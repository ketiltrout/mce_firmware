library ieee;
use ieee.std_logic_1164.all;

entity ac_core_power_ripple is
port(
   inclk : in std_logic;
   
   -- lvds tx signals
   lvds_txa : out std_logic;
   lvds_txb : out std_logic;
   -- random IO
   mictor : out std_logic_vector(32 downto 1);      
   mictorclk : out std_logic_vector(2 downto 1);
   test : out std_logic_vector(16 downto 3);
   ttl_tx : out std_logic_vector(3 downto 1);
   ttl_txena : out std_logic_vector(3 downto 1);

   -- extended signals
   dac_data0  : out std_logic_vector(13 downto 0);
   dac_data1  : out std_logic_vector(13 downto 0);
   dac_data2  : out std_logic_vector(13 downto 0);
   dac_data3  : out std_logic_vector(13 downto 0);
   dac_data4  : out std_logic_vector(13 downto 0);
   dac_data5  : out std_logic_vector(13 downto 0);
   dac_data6  : out std_logic_vector(13 downto 0);
   dac_data7  : out std_logic_vector(13 downto 0);
   dac_data8  : out std_logic_vector(13 downto 0);
   dac_data9  : out std_logic_vector(13 downto 0);
   dac_data10 : out std_logic_vector(13 downto 0);
   dac_clk   : out std_logic_vector(40 downto 0)
   );
end ac_core_power_ripple;

architecture behav of ac_core_power_ripple is

signal clk_25 : std_logic;
signal outclk : std_logic;
signal clk_400 : std_logic;

component pll
port(inclk0 : in std_logic;
     c0 : out std_logic;
     c1 : out std_logic;
     c2 : out std_logic;
     e0 : out std_logic);
end component;

component counter1
port(clock : in std_logic;
     q : out std_logic_vector(255 downto 0);
     cout : out std_logic);
end component;

begin
   clk0 : pll
   port map(inclk0 => inclk,
            c0 => clk_400,
            c1 => test(16),
            c2 => clk_25,
            e0 => outclk);

   cnt3 : counter1
   port map(clock => clk_400,
            --q => ????,
            cout => test(3));

   cnt4 : counter1
   port map(clock => clk_400,
            --q => ????,
            cout => test(4));

   cnt5 : counter1
   port map(clock => clk_400,
            --q => ????,
            cout => test(5));

   cnt6 : counter1
   port map(clock => clk_400,
            --q => ????,
            cout => test(6));

   cnt7 : counter1
   port map(clock => clk_400,
            --q => ????,
            cout => test(7));

   cnt8 : counter1
   port map(clock => clk_400,
            --q => ????,
            cout => test(8));

   cnt9 : counter1
   port map(clock => clk_400,
            --q => ????,
            cout => test(9));

   cnt10 : counter1
   port map(clock => clk_400,
            --q => ????,
            cout => test(10));

   cnt11 : counter1
   port map(clock => clk_400,
            --q => ????,
            cout => test(11));

   cnt12 : counter1
   port map(clock => clk_400,
            --q => ????,
            cout => test(12));

   cnt13 : counter1
   port map(clock => clk_400,
            --q => ????,
            cout => test(13));

   cnt14 : counter1
   port map(clock => clk_400,
            --q => ????,
            cout => test(14));

   cnt15 : counter1
   port map(clock => clk_400,
            --q => ????,
            cout => test(15));

--   dac_clk    <= (others => clk_25);
--   dac_data0  <= (others => clk_25);
--   dac_data2  <= (others => clk_25);
--   dac_data4  <= (others => clk_25);
--   dac_data6  <= (others => clk_25);
--   dac_data8  <= (others => clk_25);
--   dac_data10 <= (others => clk_25);
--   dac_data1  <= (others => clk_25);
--   dac_data3  <= (others => clk_25);
--   dac_data5  <= (others => clk_25);
--   dac_data7  <= (others => clk_25);
--   dac_data9  <= (others => clk_25);

--   mictor     <= (others => clk_25);
--   mictorclk  <= (others => clk_25);
--   test(9 downto 3) <= (others => clk_25);
--   ttl_txena  <= (others => '0');

--   lvds_txa   <= clk_25;
--   lvds_txb   <= clk_25;
end behav;