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
-- $Id: issue_reply_pack.vhd,v 1.2 2004/05/10 19:24:41 bburger Exp $
--
-- Project:    SCUBA2
-- Author:     Bryce Burger
-- Organisation:  UBC
--
-- Description:
-- Declares a few constants used as parameters in the issue_reply block
--
-- Revision history:
-- $Log: issue_reply_pack.vhd,v $
-- Revision 1.2  2004/05/10 19:24:41  bburger
-- added UOP_STATUS_BUS_WIDTH
--
-- Revision 1.1  2004/05/10 19:01:45  bburger
-- new
--
--
------------------------------------------------------------------------

--library ieee;
--use ieee.std_logic_1164.all;

package issue_reply_pack is

   -- used for interfaces between blocks incapsulated by issue_reply
   constant CARD_ADDR_BUS_WIDTH  : integer := 8;
   constant PAR_ID_BUS_WIDTH     : integer := 24;
   constant MOP_BUS_WIDTH        : integer := 3;
   constant UOP_BUS_WIDTH        : integer := 8 - MOP_BUS_WIDTH;
   constant UOP_STATUS_BUS_WIDTH : integer := 8;
   constant DATA_SIZE_BUS_WIDTH  : integer := 16;
   constant DATA_BUS_WIDTH       : integer := 16;

end issue_reply_pack;