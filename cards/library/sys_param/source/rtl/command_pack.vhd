library ieee;
use ieee.std_logic_1164.all;

library sys_param;
use sys_param.wishbone_pack.all;

package command_pack is

   -- used for interfaces between blocks incapsulated by issue_reply
   constant CARD_ADDR_BUS_WIDTH    : integer := 16;
   constant PAR_ID_BUS_WIDTH       : integer := 16;
   constant MOP_BUS_WIDTH          : integer := 8;
   constant UOP_BUS_WIDTH          : integer := 8;
   constant UOP_STATUS_BUS_WIDTH   : integer := 8;
   constant DATA_SIZE_BUS_WIDTH    : integer := 32;
   constant DATA_BUS_WIDTH         : integer := 32;
   constant SYNC_NUM_BUS_WIDTH     : integer := 8;
   constant CMD_CODE_BUS_WIDTH     : integer := 16;
   constant CHECKSUM_BUS_WIDTH     : integer := 32;
   constant PREAMBLE_BUS_WIDTH     : integer := 16;
   constant ERROR_WORD_WIDTH       : integer := 32;
    
   constant BB_PREAMBLE            : std_logic_vector := x"AAAA";
   constant BB_PACKET_HEADER_SIZE  : integer := 2;

   constant FIBRE_PREAMBLE1        : std_logic_vector := X"A5";
   constant FIBRE_PREAMBLE2        : std_logic_vector := X"5A";

   -- used in cmd_queue
   constant ISSUE_SYNC_BUS_WIDTH   : integer := SYNC_NUM_BUS_WIDTH;  -- The width of the data field for the absolute sync count at which an instruction was issued
   constant TIMEOUT_SYNC_BUS_WIDTH : integer := SYNC_NUM_BUS_WIDTH;  -- The width of the data field for the absolute sync count at which an instruction expires
   constant CQ_CARD_ADDR_BUS_WIDTH : integer := CARD_ADDR_WIDTH;
   constant CQ_PAR_ID_BUS_WIDTH    : integer := WB_ADDR_WIDTH;
   constant CQ_DATA_SIZE_BUS_WIDTH : integer := 16;

-- when it's time to cleanup code:
-- 1. rename CQ_ constants to BB_ constants
-- 2. eliminate redundancy between command pack and wishbone pack.

--------------------------------------------------------------------------------------------------
--                         ERROR NUMBER TABLE. 
--------------------------------------------------------------------------------------------------
-- list of errors / error numbers to be returned to Linux PC (word 3 of reply packet)
-- if a command is unsuccessfully exectuted.
   
   constant CHECKSUM_ER_NUM     : std_logic_vector (ERROR_WORD_WIDTH-1 downto 0) := X"00000001" ;

--------------------------------------------------------------------------------------------------


-- ASCII character byte definitions
-- used with fibre commands


-- define sub-type 'byte'
   subtype byte is std_logic_vector( 7 downto 0);

-- some ascii definitions for fibre commands/reply packets

   constant ASCII_A    : byte := X"41";  -- ascii value for 'A'
   constant ASCII_B    : byte := X"42";  -- ascii value for 'B'
   constant ASCII_D    : byte := X"44";  -- ascii value for 'D'   
   constant ASCII_E    : byte := X"45";  -- ascii value for 'E'
   constant ASCII_G    : byte := X"47";  -- ascii value for 'G'
   constant ASCII_K    : byte := X"4B";  -- ascii value for 'K'
   constant ASCII_O    : byte := X"4F";  -- ascii value for 'O'
   constant ASCII_P    : byte := X"50";  -- ascii value for 'P'
   constant ASCII_R    : byte := X"52";  -- ascii value for 'R'
   constant ASCII_S    : byte := X"53";  -- ascii value for 'S'
   constant ASCII_T    : byte := X"54";  -- ascii value for 'T'
   constant ASCII_W    : byte := X"57";  -- ascii value for 'W'
   constant ASCII_SP   : byte := X"20";  -- ascii value for space


   

end command_pack;