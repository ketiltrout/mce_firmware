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
-- $Id$
--
-- Project:       SCUBA-2
-- Author:        Greg Dennis
-- Organization:  UBC
--
-- Description:
-- DV and Manchester Decoder
--
-- Revision history:
-- $Log$
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package dv_rx_pack is

   constant DV_SELECT_WIDTH      : integer := 3;
   constant DV_INTERNAL          : std_logic_vector(DV_SELECT_WIDTH-1 downto 0) := "000";
   constant DV_FIBRE_PULSE       : std_logic_vector(DV_SELECT_WIDTH-1 downto 0) := "001";
   constant DV_FIBRE_PACKET      : std_logic_vector(DV_SELECT_WIDTH-1 downto 0) := "010";
   constant DV_MANCHESTER_PULSE  : std_logic_vector(DV_SELECT_WIDTH-1 downto 0) := "011";
   constant DV_MANCHESTER_PACKET : std_logic_vector(DV_SELECT_WIDTH-1 downto 0) := "100";

   constant ROW_SWITCH_SELECT_WIDTH      : integer := 3;
   constant ROW_SWITCH_INTERNAL          : std_logic_vector(DV_SELECT_WIDTH-1 downto 0) := "000";
   constant ROW_SWITCH_FIBRE_PACKET      : std_logic_vector(DV_SELECT_WIDTH-1 downto 0) := "001";
   constant ROW_SWITCH_MANCHESTER_PACKET : std_logic_vector(DV_SELECT_WIDTH-1 downto 0) := "010";

end dv_rx_pack;

