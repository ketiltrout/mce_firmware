
library IEEE;
use IEEE.std_logic_1164.all;

library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;

entity TB_DISPATCH_CMD_RECEIVE is
end TB_DISPATCH_CMD_RECEIVE;

architecture BEH of TB_DISPATCH_CMD_RECEIVE is

   component DISPATCH_CMD_RECEIVE

      generic(CARD   : std_logic_vector ( CQ_CARD_ADDR_BUS_WIDTH - 1 downto 0 )  := RC1 );

      port(CLK_I         : in std_logic ;
           COMM_CLK_I    : in std_logic ;
           RST_I         : in std_logic ;
           LVDS_CMD_I    : in std_logic ;
           DONE_O        : out std_logic ;
           DATA_SIZE_O   : out std_logic_vector ( CQ_DATA_SIZE_BUS_WIDTH - 1 downto 0 );
           PARAM_ID_O    : out std_logic_vector ( CQ_PAR_ID_BUS_WIDTH - 1 downto 0 );
           MACRO_SEQ_O   : out std_logic_vector ( 7 downto 0 );
           MICRO_SEQ_O   : out std_logic_vector ( 7 downto 0 );
           BUF_DATA_O    : out std_logic_vector ( 31 downto 0 );
           BUF_ADDR_O    : out std_logic_vector ( 5 downto 0 );
           BUF_WREN_O    : out std_logic );

   end component;

   component LVDS_TX
      port(CLK_I        : in std_logic ;
           COMM_CLK_I   : in std_logic ;
           RST_I        : in std_logic ;
           DAT_I        : in std_logic_vector ( 31 downto 0 );
           START_I      : in std_logic ;
           DONE_O       : out std_logic ;
           LVDS_O       : out std_logic );

   end component;


   constant PERIOD : time := 32 ns;
   constant COMM_PERIOD : time := 4 ns;
   
   signal W_CLK_I         : std_logic := '1';
   signal W_COMM_CLK_I    : std_logic := '1';
   signal W_RST_I         : std_logic ;
   signal W_DONE_O        : std_logic ;
   signal W_DATA_SIZE_O   : std_logic_vector ( CQ_DATA_SIZE_BUS_WIDTH - 1 downto 0 );
   signal W_PARAM_ID_O    : std_logic_vector ( CQ_PAR_ID_BUS_WIDTH - 1 downto 0 );
   signal W_MACRO_SEQ_O   : std_logic_vector ( 7 downto 0 );
   signal W_MICRO_SEQ_O   : std_logic_vector ( 7 downto 0 );
   signal W_CRC_VALID_O   : std_logic ;
   signal W_BUF_DATA_O    : std_logic_vector ( 31 downto 0 );
   signal W_BUF_ADDR_O    : std_logic_vector ( 5 downto 0 ) ;
   signal W_BUF_WREN_O    : std_logic ;
   signal W_DAT_I         : std_logic_vector ( 31 downto 0 );
   signal W_LVDS_START_I  : std_logic ;
   signal W_LVDS_DONE_O   : std_logic ;
   signal W_LVDS_CMD      : std_logic ;         

begin

   DUT : DISPATCH_CMD_RECEIVE

      generic map(CARD   => BC1)

      port map(CLK_I         => W_CLK_I,
               COMM_CLK_I    => W_COMM_CLK_I,
               RST_I         => W_RST_I,
               LVDS_CMD_I    => W_LVDS_CMD,
               DONE_O        => W_DONE_O,
               DATA_SIZE_O   => W_DATA_SIZE_O,
               PARAM_ID_O    => W_PARAM_ID_O,
               MACRO_SEQ_O   => W_MACRO_SEQ_O,
               MICRO_SEQ_O   => W_MICRO_SEQ_O,
               BUF_DATA_O    => W_BUF_DATA_O,
               BUF_ADDR_O    => W_BUF_ADDR_O,
               BUF_WREN_O    => W_BUF_WREN_O);

   TX : LVDS_TX
      port map(CLK_I        => W_CLK_I,
               COMM_CLK_I   => W_COMM_CLK_I,
               RST_I        => W_RST_I,
               DAT_I        => W_DAT_I,
               START_I      => W_LVDS_START_I,
               DONE_O       => W_LVDS_DONE_O,
               LVDS_O       => W_LVDS_CMD);

   
   W_CLK_I <= not W_CLK_I after PERIOD/2;
   W_COMM_CLK_I <= not W_COMM_CLK_I after COMM_PERIOD/2;
   
   STIMULI : process
   procedure reset is
   begin
      W_RST_I         <= '1';
      W_DAT_I         <= (others => '0');
      W_LVDS_START_I  <= '0';
      
      wait for PERIOD*200;
      
   end reset;
   
   procedure transmit (data : in std_logic_vector(31 downto 0)) is
   begin
      W_RST_I         <= '0';
      W_DAT_I         <= data;
      W_LVDS_START_I  <= '1';
      
      wait for PERIOD;
      
      W_RST_I         <= '0';
      W_LVDS_START_I  <= '0';
      
      wait until W_LVDS_DONE_O = '1';

      wait for PERIOD*2;
   
   end transmit;
   
   procedure pause (length : in integer) is
   begin
      wait for PERIOD*length;
      
   end pause;
   
   begin
      
      reset;
      
      transmit("10101010101010100000000000000001");  -- 1 data word
      transmit("00000000000000000000000000000000");  -- for no card
      transmit("00000000000000000000000000000000");  -- 0x00000000
      transmit("01010100010101011101111000000101");  -- 0x5455DE05
      
      pause(100);
      
      transmit("10101010101010100000000000000010");  -- 2 data words
      transmit("00000010010100110000000100000001");  -- for CC
      transmit("00001100000110100101010100011100");  -- 0x0C1A551C
      transmit("00000000000000001100000011011110");  -- 0x0000C0DE
      transmit("01111110010101011001000000000110");  -- 0x7E559006
            
      pause(200);
      
      transmit("10101010101010100000000000000011");  -- 3 data words
      transmit("00000111001000000000000000000000");  -- for BC1
      transmit("00000000000000000000000000001010");  -- 0x0000000A
      transmit("00000000000000001101111010101111");  -- 0x0000DEAF
      transmit("00000000110010101011101100011110");  -- 0x00CABB1E
      transmit("01110010011010111110010111111111");  -- 0x726BE5FF
      
      pause(50);
      
      transmit("10101010101010100000000000000001");  -- 1 data word
      transmit("00001100000011110001000000010001");  -- for all BCs
      transmit("00000000000000001111101010110101");  -- 0x0000FAB5
      transmit("00100101110000110110010000000100");  -- 0x25C36404
      
      pause(100);
      
      assert FALSE report "End of simulation." severity FAILURE;
      
      wait for PERIOD;
      wait;
   end process STIMULI;

end BEH;