
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library sys_param;
use sys_param.wishbone_pack.all;
use sys_param.general_pack.all;

entity TB_SRAM_CTRL is
end TB_SRAM_CTRL;

architecture BEH of TB_SRAM_CTRL is

   component SRAM_CTRL

      generic(ADDR_WIDTH       : integer  := WB_ADDR_WIDTH ;
              DATA_WIDTH       : integer  := WB_DATA_WIDTH ;
              TAG_ADDR_WIDTH   : integer  := WB_TAG_ADDR_WIDTH );

      port(ADDR_O    : out std_logic_vector ( 19 downto 0 );
           DATA_BI   : inout std_logic_vector ( 15 downto 0 );
           N_BLE_O   : out std_logic ;
           N_BHE_O   : out std_logic ;
           N_OE_O    : out std_logic ;
           N_CE1_O   : out std_logic ;
           CE2_O     : out std_logic ;
           N_WE_O    : out std_logic ;
           CLK_I     : in std_logic ;
           RST_I     : in std_logic ;
           DAT_I     : in std_logic_vector ( DATA_WIDTH - 1 downto 0 );
           ADDR_I    : in std_logic_vector ( ADDR_WIDTH - 1 downto 0 );
           TGA_I     : in std_logic_vector ( TAG_ADDR_WIDTH - 1 downto 0 );
           WE_I      : in std_logic ;
           STB_I     : in std_logic ;
           CYC_I     : in std_logic ;
           DAT_O     : out std_logic_vector ( DATA_WIDTH - 1 downto 0 );
           RTY_O     : out std_logic ;
           ACK_O     : out std_logic );

   end component;


--   constant PERIOD : time := 10 ns;

   signal W_ADDR_O    : std_logic_vector ( 19 downto 0 );
   signal W_DATA_BI   : std_logic_vector ( 15 downto 0 );
   signal W_N_BLE_O   : std_logic ;
   signal W_N_BHE_O   : std_logic ;
   signal W_N_OE_O    : std_logic ;
   signal W_N_CE1_O   : std_logic ;
   signal W_CE2_O     : std_logic ;
   signal W_N_WE_O    : std_logic ;
   signal W_CLK_I     : std_logic := '0';
   signal W_RST_I     : std_logic ;
   signal W_DAT_I     : std_logic_vector ( 31 downto 0 );
   signal W_ADDR_I    : std_logic_vector ( 7 downto 0 );
   signal W_TGA_I     : std_logic_vector ( 31 downto 0 );
   signal W_WE_I      : std_logic ;
   signal W_STB_I     : std_logic ;
   signal W_CYC_I     : std_logic ;
   signal W_DAT_O     : std_logic_vector ( 31 downto 0 );
   signal W_RTY_O     : std_logic ;
   signal W_ACK_O     : std_logic ;

   type regarray is array (63 downto 0) of std_logic_vector(15 downto 0);
   signal sram : regarray;
   
begin

   DUT : SRAM_CTRL

      generic map(ADDR_WIDTH       => WB_ADDR_WIDTH ,
                  DATA_WIDTH       => WB_DATA_WIDTH ,
                  TAG_ADDR_WIDTH   => WB_TAG_ADDR_WIDTH )

      port map(ADDR_O    => W_ADDR_O,
               DATA_BI   => W_DATA_BI,
               N_BLE_O   => W_N_BLE_O,
               N_BHE_O   => W_N_BHE_O,
               N_OE_O    => W_N_OE_O,
               N_CE1_O   => W_N_CE1_O,
               CE2_O     => W_CE2_O,
               N_WE_O    => W_N_WE_O,
               CLK_I     => W_CLK_I,
               RST_I     => W_RST_I,
               DAT_I     => W_DAT_I,
               ADDR_I    => W_ADDR_I,
               TGA_I     => W_TGA_I,
               WE_I      => W_WE_I,
               STB_I     => W_STB_I,
               CYC_I     => W_CYC_I,
               DAT_O     => W_DAT_O,
               RTY_O     => W_RTY_O,
               ACK_O     => W_ACK_O);

   W_CLK_I <= not W_CLK_I after CLOCK_PERIOD/2;

   STIMULI : process
   procedure sram_read is
   begin
      W_DATA_BI <= sram(conv_integer(W_ADDR_O(5 downto 0))) after 8 ns;   
   end sram_read;
   
   procedure sram_write is
   begin
      sram(conv_integer(W_ADDR_O(5 downto 0))) <= W_DATA_BI;
   end sram_write;
   
      
   begin
      W_RST_I     <= '0';
      W_DAT_I     <= (others => '0');
      W_ADDR_I    <= (others => '0');
      W_TGA_I     <= (others => '0');
      W_WE_I      <= '0';
      W_STB_I     <= '0';
      W_CYC_I     <= '0';

      wait for CLOCK_PERIOD;
      wait;
   end process STIMULI;

end BEH;
