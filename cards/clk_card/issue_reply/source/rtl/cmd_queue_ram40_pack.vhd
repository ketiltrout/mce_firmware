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
-- $Id$
--
-- Project:       SCUBA2
-- Author:        Bryce Burger
-- Organisation:  UBC
--
-- Description:
-- Pack file for the ram block used by cmd_queue
--
-- Revision history:
-- $Log$
--
------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;

package cmd_queue_ram40_pack is

   constant QUEUE_LEN   : integer  := 256; -- The u-op queue is 256 entries long
   constant QUEUE_WIDTH : integer  := 40; -- The u-op queue is 40 bits wide

   component cmd_queue_ram40 is
      PORT
      (
         data        : IN STD_LOGIC_VECTOR (39 DOWNTO 0);
         wraddress   : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
         rdaddress_a : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
         rdaddress_b : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
         wren        : IN STD_LOGIC  := '1';
         clock       : IN STD_LOGIC ;
         qa          : OUT STD_LOGIC_VECTOR (39 DOWNTO 0);
         qb          : OUT STD_LOGIC_VECTOR (39 DOWNTO 0)
      );
   END component;

end cmd_queue_ram40_pack;
