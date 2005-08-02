
library IEEE;
use IEEE.std_logic_1164.all;

entity TB_BER_TEST is
end TB_BER_TEST;

architecture BEH of TB_BER_TEST is

   component ber_test
      port(clk_i      : in std_logic;
           rst_i      : in std_logic;
           lvds_clk_o : out std_logic;
           mode_i  : in std_logic_vector(2 downto 0);

           tx0_o   : out std_logic;   -- BER output   (noise/data, depending on mode)
           tx1_o   : out std_logic;   -- dummy output (noise only)
           tx2_o   : out std_logic;   -- dummy output (noise only)
           rx_i    : in std_logic;    -- BER input

           nlock_o : out std_logic;   -- receiver is locked to transmitter
           ndata_o : out std_logic;   -- transmitter is sending data
           nrand_o : out std_logic;   -- transmitter is sending random noise
     
--           bit_err_o : out std_logic_vector(31 downto 0);   -- # of erroneous bits
--           pkt_err_o : out std_logic_vector(31 downto 0);   -- # of erroneous packets
--           loops_o   : out std_logic_vector(31 downto 0));  -- # of loops
           output_o : out std_logic_vector(31 downto 0));          
   end component;

   component lfsr
      generic(WIDTH : in integer range 3 to 168 := 8);
      port(clk_i  : in std_logic;
           rst_i  : in std_logic;
           ena_i  : in std_logic;
           load_i : in std_logic;
           clr_i  : in std_logic;
           lfsr_i : in std_logic_vector(WIDTH-1 downto 0);
           lfsr_o : out std_logic_vector(WIDTH-1 downto 0));
   end component;

   component lvds_tx   
   port(clk_i      : in std_logic;
        rst_i      : in std_logic;
     
        dat_i      : in std_logic_vector(31 downto 0);
        rdy_i      : in std_logic;
        busy_o     : out std_logic;
     
        lvds_o     : out std_logic);
   end component;
    
   constant PERIOD : time := 40 ns;    -- 25MHz clock feeds PLL inside BER test module
   constant DELAY  : time := 18 ns;    -- backplane delay is about 18 ns (measured on scope)
   
   constant TRANSMITTER : std_logic_vector(2 downto 0) := "000";
   constant RECEIVER    : std_logic_vector(2 downto 0) := "001";
   constant COMBINATION : std_logic_vector(2 downto 0) := "010";
   constant LOOPBACK    : std_logic_vector(2 downto 0) := "011";
   
   signal W_CLK_I      : std_logic := '1';
   signal W_RST_I      : std_logic := '0';
   signal W_LVDS_CLK   : std_logic := '1';

--   signal W_MODE1_I    : std_logic_vector(1 downto 0);
--   signal W_MODE2_I    : std_logic_vector(1 downto 0);
--   
--   signal W_TX1        : std_logic;
--   signal W_TX2        : std_logic;
--   
--   signal W_ERRORS1_O   : std_logic_vector(15 downto 0);
--   signal W_ERRORS2_O   : std_logic_vector(15 downto 0);   
--   signal W_LOOPS1_O    : std_logic_vector(15 downto 0);
--   signal W_LOOPS2_O    : std_logic_vector(15 downto 0);

   signal W_CARD1_TX0 : std_logic;
   signal W_CARD1_TX1 : std_logic;
   signal W_CARD1_TX2 : std_logic;
   signal W_CARD2_TX0 : std_logic;
   signal W_CARD2_TX1 : std_logic;
   signal W_CARD2_TX2 : std_logic;
   signal W_CHANNEL   : std_logic;
      
   signal W_LOCKED1 : std_logic;
   signal W_DATA1   : std_logic;
   signal W_NOISE1  : std_logic;
   signal W_BITERR1 : std_logic_vector(31 downto 0);
   signal W_PKTERR1 : std_logic_vector(31 downto 0);
   signal W_LOOPS1  : std_logic_vector(31 downto 0);
   signal W_OUTPUT1 : std_logic_vector(31 downto 0);
   
   signal W_LOCKED2 : std_logic;
   signal W_DATA2   : std_logic;
   signal W_NOISE2  : std_logic;
   signal W_BITERR2 : std_logic_vector(31 downto 0);
   signal W_PKTERR2 : std_logic_vector(31 downto 0);
   signal W_LOOPS2  : std_logic_vector(31 downto 0);
   signal W_OUTPUT2 : std_logic_vector(31 downto 0);
   
   signal W_RANDOM : std_logic_vector(31 downto 0);
   
begin
               
   card1 : BER_TEST   -- transmitter
      port map(clk_i      => W_CLK_I,
               rst_i      => W_RST_I,
               lvds_clk_o => W_LVDS_CLK,
               mode_i     => TRANSMITTER,
               
               tx0_o      => W_CARD1_TX0,
               tx1_o      => W_CARD1_TX1,
               tx2_o      => W_CARD1_TX2,
               rx_i       => '1',
               
               nlock_o    => W_LOCKED1,
               ndata_o    => W_DATA1,
               nrand_o    => W_NOISE1,
               output_o   => W_OUTPUT1);
           
   card2 : BER_TEST   -- receiver
      port map(CLK_I      => W_LVDS_CLK'delayed(DELAY),
               rst_i      => W_RST_I,
               lvds_clk_o => open,
               mode_i     => RECEIVER,
               
               tx0_o      => W_CARD2_TX0,
               tx1_o      => W_CARD2_TX1,
               tx2_o      => W_CARD2_TX2,
               rx_i       => W_CHANNEL'delayed(DELAY),
               
               nlock_o    => W_LOCKED2,
               ndata_o    => W_DATA2,
               nrand_o    => W_NOISE2,
               output_o   => W_OUTPUT2);               
   
   rand0 : lfsr
   generic map(WIDTH => 32)
   port map(clk_i  => W_CLK_I,
            rst_i  => W_RST_I,
            ena_i  => '1',
            load_i => '0',
            clr_i  => '0',
            lfsr_i => (others => '0'),
            lfsr_o => W_RANDOM);
   
   tx0 : lvds_tx
   port map(clk_i  => W_CLK_I,
            rst_i  => W_RST_I,
            dat_i  => W_RANDOM,
            rdy_i  => '1',
            busy_o => open,
            lvds_o => W_CHANNEL);
                     
   W_CLK_I <= not W_CLK_I after PERIOD/2;
   
--   W_CHANNEL <= W_CARD1_TX0 when W_RANDOM(0) = '1' else '1';
   
   
   STIMULI : process
   begin
      wait for 500 ns;
      
      W_RST_I         <= '1';
      wait for PERIOD;
      
      W_RST_I         <= '0';
      wait for 100 us;
      
      W_RST_I         <= '1';
      wait for PERIOD;
      
      W_RST_I         <= '0';
      wait for 100 us;
      
      assert FALSE report "End of simulation." severity FAILURE;
      
      wait;
   end process STIMULI;

end BEH;