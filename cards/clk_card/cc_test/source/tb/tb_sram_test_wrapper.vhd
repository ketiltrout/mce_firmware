
library IEEE;
use IEEE.std_logic_1164.all;

entity TB_SRAM_TEST_WRAPPER is
end TB_SRAM_TEST_WRAPPER;

architecture BEH of TB_SRAM_TEST_WRAPPER is

   component SRAM_TEST_WRAPPER
      port(RST_I       : in std_logic ;
           CLK_I       : in std_logic ;
           EN_I        : in std_logic ;
           DONE_O      : out std_logic ;
           TX_BUSY_I   : in std_logic ;
           TX_ACK_I    : in std_logic ;
           TX_DATA_O   : out std_logic_vector ( 7 downto 0 );
           TX_WE_O     : out std_logic ;
           TX_STB_O    : out std_logic ;
           ADDR_O      : out std_logic_vector ( 19 downto 0 );
           DATA_BI     : inout std_logic_vector ( 15 downto 0 );
           N_BLE_O     : out std_logic ;
           N_BHE_O     : out std_logic ;
           N_OE_O      : out std_logic ;
           N_CE1_O     : out std_logic ;
           CE2_O       : out std_logic ;
           N_WE_O      : out std_logic );

   end component;

   component SRAM_PASS
      port(ADDRESS   : in std_logic_vector ( 19 downto 0 );
           DATA      : inout std_logic_vector ( 15 downto 0 );
           N_BHE     : in std_logic ;
           N_BLE     : in std_logic ;
           N_OE      : in std_logic ;
           N_WE      : in std_logic ;
           N_CE1     : in std_logic ;
           CE2       : in std_logic ;
           RESET     : in std_logic);

   end component;
   
   constant PERIOD : time := 20 ns;

   signal W_RST_I       : std_logic ;
   signal W_CLK_I       : std_logic := '0';
   signal W_EN_I        : std_logic ;
   signal W_DONE_O      : std_logic ;
   signal W_TX_BUSY_I   : std_logic ;
   signal W_TX_ACK_I    : std_logic ;
   signal W_TX_DATA_O   : std_logic_vector ( 7 downto 0 );
   signal W_TX_WE_O     : std_logic ;
   signal W_TX_STB_O    : std_logic ;
   signal W_ADDR_O      : std_logic_vector ( 19 downto 0 );
   signal W_DATA_BI     : std_logic_vector ( 15 downto 0 );
   signal W_N_BLE_O     : std_logic ;
   signal W_N_BHE_O     : std_logic ;
   signal W_N_OE_O      : std_logic ;
   signal W_N_CE1_O     : std_logic ;
   signal W_CE2_O       : std_logic ;
   signal W_N_WE_O      : std_logic ;

begin

   DUT : SRAM_TEST_WRAPPER
      port map(RST_I       => W_RST_I,
               CLK_I       => W_CLK_I,
               EN_I        => W_EN_I,
               DONE_O      => W_DONE_O,
               TX_BUSY_I   => W_TX_BUSY_I,
               TX_ACK_I    => W_TX_ACK_I,
               TX_DATA_O   => W_TX_DATA_O,
               TX_WE_O     => W_TX_WE_O,
               TX_STB_O    => W_TX_STB_O,
               ADDR_O      => W_ADDR_O,
               DATA_BI     => W_DATA_BI,
               N_BLE_O     => W_N_BLE_O,
               N_BHE_O     => W_N_BHE_O,
               N_OE_O      => W_N_OE_O,
               N_CE1_O     => W_N_CE1_O,
               CE2_O       => W_CE2_O,
               N_WE_O      => W_N_WE_O);

   SRAM_MODEL : SRAM_PASS
      port map(ADDRESS   => W_ADDR_O, 
               DATA      => W_DATA_BI, 
               N_BHE     => W_N_BHE_O,
               N_BLE     => W_N_BLE_O,
               N_OE      => W_N_OE_O,
               N_WE      => W_N_WE_O,
               N_CE1     => W_N_CE1_O,
               CE2       => W_CE2_O,
               RESET     => W_RST_I);
           
   W_CLK_I <= not W_CLK_I after PERIOD/2;

   STIMULI : process
   procedure reset is
   begin
      W_RST_I       <= '1';
      W_EN_I        <= '0';
      W_TX_BUSY_I   <= '0';
      W_TX_ACK_I    <= '0';
      wait for PERIOD*5;
      W_RST_I       <= '0';
      W_EN_I        <= '0';
      W_TX_BUSY_I   <= '0';
      W_TX_ACK_I    <= '0';
      wait for PERIOD;
   end reset;
   
   procedure transmit is
   begin
      W_RST_I       <= '0';
      W_EN_I        <= '1';
      W_TX_BUSY_I   <= '0';
      W_TX_ACK_I    <= '0';
      wait for PERIOD;
      
      if(W_TX_STB_O = '0') then
         wait until W_TX_STB_O = '1';
      end if;
         
      if(W_TX_WE_O = '0') then
         wait until W_TX_WE_O = '1';
      end if;
         
      W_RST_I       <= '0';
      W_EN_I        <= '1';
      W_TX_BUSY_I   <= '0';
      W_TX_ACK_I    <= '1';
      wait for PERIOD;
      
      W_RST_I       <= '0';
      W_EN_I        <= '1';
      W_TX_BUSY_I   <= '1';
      W_TX_ACK_I    <= '0';
      wait for PERIOD*10;
      
      W_RST_I       <= '0';
      W_EN_I        <= '1';
      W_TX_BUSY_I   <= '0';
      W_TX_ACK_I    <= '0';
      wait for PERIOD;
   end transmit;
   
   procedure transmit_busy is
   begin
      W_RST_I       <= '0';
      W_EN_I        <= '1';
      W_TX_BUSY_I   <= '1';
      W_TX_ACK_I    <= '0';
      wait for 130 ms;
      
      W_RST_I       <= '0';
      W_EN_I        <= '1';
      W_TX_BUSY_I   <= '0';
      W_TX_ACK_I    <= '0';
      wait for PERIOD;
      
      if(W_TX_STB_O = '0') then
         wait until W_TX_STB_O = '1';
      end if;
         
      if(W_TX_WE_O = '0') then
         wait until W_TX_WE_O = '1';
      end if;
         
--      W_RST_I       <= '0';
--      W_EN_I        <= '1';
--      W_TX_BUSY_I   <= '1';
--      W_TX_ACK_I    <= '0';
--      wait for PERIOD*10;
      
      W_RST_I       <= '0';
      W_EN_I        <= '1';
      W_TX_BUSY_I   <= '0';
      W_TX_ACK_I    <= '1';
      wait for PERIOD;
      
      W_RST_I       <= '0';
      W_EN_I        <= '1';
      W_TX_BUSY_I   <= '1';
      W_TX_ACK_I    <= '0';
      wait for PERIOD*10;
      
      W_RST_I       <= '0';
      W_EN_I        <= '1';
      W_TX_BUSY_I   <= '0';
      W_TX_ACK_I    <= '0';
      wait for PERIOD;
   end transmit_busy;
   
   procedure end_request is
   begin
      wait until W_DONE_O = '1';
      wait for PERIOD;
      
      W_RST_I       <= '0';
      W_EN_I        <= '0';
      W_TX_BUSY_I   <= '0';
      W_TX_ACK_I    <= '0';
      wait for PERIOD;
      
      wait for 10 us;
   end end_request;
   
   begin
      reset;
      
      transmit_busy;
             
      end_request;
            
      assert FALSE report "Simulation done." severity failure;    
      wait;
   end process STIMULI;

end BEH;
