-- Copyright (c) 2003 SCUBA-2 Project
--               All Rights Reserved
--
-- THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF THE SCUBA-2 Project
-- The copyright notice above does not evidence any
-- actual or intended publication of such source code.
--
-- SOURCE CODE IS PROVIDED "AS IS". ALL EXPRESS OR IMPLIED CONDITIONS,
-- REPRESENTATIONS, AND WARRANTIES, INCLUDING ANY IMPLIED WARRANT OF
-- MERCHANTABILITY, SATISFACTORY QUALITY, FITNESS FOR A PARTICULAR
-- PURPOSE, OR NON-INFRINGEMENT, ARE DISCLAIMED, EXCEPT TO THE EXTENT
-- THAT SUCH DISCLAIMERS ARE HELD TO BE LEGALLY INVALID.
--
-- For the purposes of this code the SCUBA-2 Project consists of the
-- following organisations.
--
-- UKATC, Royal Observatory, Blackford Hill Edinburgh EH9 3HJ
-- UBC,   University of British Columbia, Physics & Astronomy Department,
--        Vancouver BC, V6T 1Z1
--
-- $Id: cmd_queue_ram40_pack.vhd,v 1.12 2004/10/26 23:59:16 bburger Exp $
--
-- Project:       SCUBA2
-- Author:        Bryce Burger
-- Organisation:  UBC
--
-- Description:
-- Pack file for the ram block used by cmd_queue
--
-- Revision history:
-- $Log: cmd_queue_ram40_pack.vhd,v $
-- Revision 1.12  2004/10/26 23:59:16  bburger
-- Bryce:  working out the bugs from the cmd_queue<->reply_queue interface
--
-- Revision 1.11  2004/10/08 19:45:26  bburger
-- Bryce:  Changed SYNC_NUM_WIDTH to 16, removed TIMEOUT_SYNC_WIDTH, added a command-code to cmd_queue, added two words of book-keeping information to the cmd_queue
--
-- Revision 1.10  2004/09/30 21:57:51  erniel
-- using new command_pack constants
--
-- Revision 1.9  2004/07/26 19:31:13  bench2
-- Bryce: in progress
--
-- Revision 1.8  2004/07/22 23:43:31  bench2
-- Bryce: in progress
--
-- Revision 1.7  2004/07/07 00:35:23  bburger
-- in progress
--
-- Revision 1.6  2004/07/06 00:27:22  bburger
-- in progress
--
-- Revision 1.5  2004/06/30 23:10:53  bburger
-- in progress
--
-- Revision 1.4  2004/06/16 17:02:36  bburger
-- in progress
--
-- Revision 1.3  2004/06/11 00:42:12  bburger
-- in progress
--
-- Revision 1.2  2004/05/31 21:23:19  bburger
-- in progress
--
-- Revision 1.1  2004/05/25 21:26:29  bburger
-- pack file
--
--
------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;

library sys_param;
use sys_param.command_pack.all;

library work;
use work.sync_gen_pack.all;

package cmd_queue_ram40_pack is

   constant QUEUE_LEN        : integer := 256; -- The u-op queue is 256 entries long
   constant QUEUE_WIDTH      : integer :=  32;
   constant QUEUE_ADDR_WIDTH : integer :=   8;

   subtype ram_line is std_logic_vector(QUEUE_WIDTH-1 downto 0);
   type ram40 is array (0 to 255) of ram_line;

   component cmd_queue_tpram is
      PORT
      (
         data        : IN STD_LOGIC_VECTOR (QUEUE_WIDTH-1 DOWNTO 0);
         wraddress   : IN STD_LOGIC_VECTOR (QUEUE_ADDR_WIDTH-1 DOWNTO 0);
         rdaddress_a : IN STD_LOGIC_VECTOR (QUEUE_ADDR_WIDTH-1 DOWNTO 0);
         rdaddress_b : IN STD_LOGIC_VECTOR (QUEUE_ADDR_WIDTH-1 DOWNTO 0);
         wren        : IN STD_LOGIC;
         clock       : IN STD_LOGIC;
         qa          : OUT STD_LOGIC_VECTOR (QUEUE_WIDTH-1 DOWNTO 0);
         qb          : OUT STD_LOGIC_VECTOR (QUEUE_WIDTH-1 DOWNTO 0)
      );
   END component;

--   component cmd_queue_ram40 is
--      PORT
--      (
--         data        : IN STD_LOGIC_VECTOR (QUEUE_WIDTH-1 DOWNTO 0);
--         wraddress   : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
--         rdaddress_a : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
--         rdaddress_b : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
--         wren        : IN STD_LOGIC;
--         clock       : IN STD_LOGIC;
--         qa          : OUT STD_LOGIC_VECTOR (QUEUE_WIDTH-1 DOWNTO 0);
--         qb          : OUT STD_LOGIC_VECTOR (QUEUE_WIDTH-1 DOWNTO 0)
--      );
--   END component;

end cmd_queue_ram40_pack;