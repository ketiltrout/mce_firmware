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
-- Project:    SCUBA2
-- Author:     Bryce Burger
-- Organisation:  UBC
--
-- Description:
-- Declares a few constants used as parameters in the issue_reply block
--
-- Revision history:
-- $Log$
--
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package issue_reply_pack is

   constant CARD_ADDR_BUS_WIDTH  : integer := 8;
   constant PAR_ID_BUS_WIDTH     : integer := 8;
   constant MOP_BUS_WIDTH        : integer := 8;
   constant UOP_BUS_WIDTH        : integer := 8;
   constant CMD_SIZE_BUS_WIDTH   : integer := 16;
   constant DATA_BUS_WIDTH       : integer := 16;

end issue_reply_pack;