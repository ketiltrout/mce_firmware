library ieee;
use ieee.std_logic_1164.all;

package wishbone_pack is

   -- Wishbone bus widths
   constant WB_DATA_WIDTH     : integer := 32;
   constant WB_ADDR_WIDTH     : integer := 8;
   constant WB_TAG_ADDR_WIDTH : integer := 32;

   -- Wishbone addresses
   constant TEMPERATURE_ADDR : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := "01000010"; -- 0x42
   constant CARD_ID_ADDR     : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := "01000011"; -- 0x43
   constant LEDS_ADDR        : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := "01000101"; -- 0x45
   constant SLOT_ID_ADDR     : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := "01000111"; -- 0x47
   constant ARRAY_ID_ADDR    : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := "01001001"; -- 0x49
   constant DIP_ADDR         : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := "01001100"; -- 0x4C
   constant WATCHDOG_ADDR    : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := "01001101"; -- 0x4D
   constant SRAM_VERIFY_ADDR : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := "01010000"; -- 0x50
   constant SRAM_ADDR        : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := "01010001"; -- 0x51

    
-- OBSOLETE from here....
  
--   -- SlotID wishbone interface
--   constant SLOT_ID_DATA_WIDTH	: integer := DEF_WB_DATA_WIDTH;
--   constant SLOT_ID_ADDR_WIDTH : integer := DEF_WB_ADDR_WIDTH;
--   
--   -- ArrayID wishbone interface
--   constant ARRAY_ID_DATA_WIDTH	: integer := DEF_WB_DATA_WIDTH;
--   constant ARRAY_ID_ADDR_WIDTH : integer := DEF_WB_ADDR_WIDTH;
--   
--   -- CardID wishbone interface
--   constant CARD_ID_DATA_WIDTH	: integer := DEF_WB_DATA_WIDTH;
--   constant CARD_ID_ADDR_WIDTH : integer := DEF_WB_ADDR_WIDTH;
--   
--   -- LEDs wishbone interface
--   constant LEDS_DATA_WIDTH : integer := DEF_WB_DATA_WIDTH;
--   constant LEDS_ADDR_WIDTH : integer := DEF_WB_ADDR_WIDTH;
--   
--   -- DIP Switch wishbone interface
--   constant DIP_DATA_WIDTH : integer := DEF_WB_DATA_WIDTH;
--   constant DIP_ADDR_WIDTH : integer := DEF_WB_ADDR_WIDTH;
--   
--   -- Watchdog wishbone interface
--   constant WATCHDOG_DATA_WIDTH : integer := DEF_WB_DATA_WIDTH;
--   constant WATCHDOG_ADDR_WIDTH : integer := DEF_WB_ADDR_WIDTH;   
--
--   -- The logical length of command code field.  8 bits allows for 256 command codes.
--   constant ADDR_LENGTH : integer := 8;
   
   
-- ...to here!
   
end wishbone_pack;