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

end command_pack;