-- Copyright (c) 2003 SCUBA-2 Project
--                  All Rights Reserved
--
--  THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF THE SCUBA-2 Project
--  The copyright notice above does not evidence any
--  actual or intended publication of such source code.
--
--  SOURCE CODE IS PROVIDED "AS IS". ALL EXPRESS OR IMPLIED CONDITIONS,
--  REPRESENTATIONS, AND WARRANTIES, INCLUDING ANY IMPLIED WARRANT OF
--  MERCHANTABILITY, SATISFACTORY QUALITY, FITNESS FOR A PARTICULAR
--  PURPOSE, OR NON-INFRINGEMENT, ARE DISCLAIMED, EXCEPT TO THE EXTENT
--  THAT SUCH DISCLAIMERS ARE HELD TO BE LEGALLY INVALID.
--
-- For the purposes of this code the SCUBA-2 Project consists of the
-- following organisations.
--
-- UKATC, Royal Observatory, Blackford Hill Edinburgh EH9 3HJ
-- UBC,   University of British Columbia, Physics & Astronomy Department,
--        Vancouver BC, V6T 1Z1
--
-- $Id: dv_rx_pack.vhd,v 1.1 2006/02/11 01:11:53 bburger Exp $
--
-- Project:       SCUBA-2
-- Author:        Greg Dennis
-- Organization:  UBC
--
-- Description:
-- DV and Manchester Decoder
--
-- Revision history:
-- $Log: dv_rx_pack.vhd,v $
-- Revision 1.1  2006/02/11 01:11:53  bburger
-- Bryce:  New!
--
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package dv_rx_pack is

   constant DV_SELECT_WIDTH        : integer := 2;
   constant DV_INTERNAL            : std_logic_vector(DV_SELECT_WIDTH-1 downto 0) := "00";
   constant DV_EXTERNAL_FIBRE      : std_logic_vector(DV_SELECT_WIDTH-1 downto 0) := "01";
   constant DV_EXTERNAL_MANCHESTER : std_logic_vector(DV_SELECT_WIDTH-1 downto 0) := "10";

   constant SYNC_SELECT_WIDTH      : integer := 2;
   constant SYNC_INTERNAL          : std_logic_vector(DV_SELECT_WIDTH-1 downto 0) := "00";
   constant SYNC_EXTERNAL          : std_logic_vector(DV_SELECT_WIDTH-1 downto 0) := "01";

end dv_rx_pack;

