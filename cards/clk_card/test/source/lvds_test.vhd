-- Copyright (c) 2003 SCUBA-2 Project All Rights Reserved
-- THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF THE SCUBA-2 Project
-- The copyright notice above does not evidence any
-- actual or intended publication of such source code.
-- SOURCE CODE IS PROVIDED "AS IS". ALL EXPRESS OR IMPLIED CONDITIONS,
-- REPRESENTATIONS, AND WARRANTIES, INCLUDING ANY IMPLIED WARRANT OF
-- MERCHANTABILITY, SATISFACTORY QUALITY, FITNESS FOR A PARTICULAR
-- PURPOSE, OR NON-INFRINGEMENT, ARE DISCLAIMED, EXCEPT TO THE EXTENT
-- THAT SUCH DISCLAIMERS ARE HELD TO BE LEGALLY INVALID.
-- For the purposes of this code the SCUBA-2 Project consists of the
-- following organisations.
-- UKATC, Royal Observatory, Blackford Hill Edinburgh EH9 3HJ
-- UBC, University of British Columbia, Physics & Astronomy Department,
-- Vancouver BC, V6T 1Z1
-- <Title>
--
-- <revision control keyword substitutions e.g. $Id: lvds_test.vhd,v 1.1 2004/07/12 23:45:18 erniel Exp $>
--
-- Project: SCUBA-2
-- Author: Bryce Burger
-- Organisation: UBC Physics and Astronomy
--
-- Description:
-- LVDS loopback and DIP/LED test
--
-- Revision history:
-- <date $Date: 2004/07/12 23:45:18 $> - <text> - <initials $Author: erniel $>
-- $Log: lvds_test.vhd,v $
-- Revision 1.1  2004/07/12 23:45:18  erniel
-- moved to clk_card/test/source
--
-- Revision 1.1  2004/04/14 00:04:51  bburger
-- new
--
------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity LVDS_TEST is
port(
   dip3 : in std_logic;
   dip4 : in std_logic;
   nfault_led : out std_logic;
   status_led : out std_logic;
   pow_ok_led : out std_logic;

   lvds_clk : in std_logic;
   lvds_cmd : in std_logic;
   lvds_sync : in std_logic;
   lvds_spr : in std_logic;

   lvds_txa : out std_logic;
   lvds_txb : out std_logic
   );
end LVDS_TEST;

architecture BEH of LVDS_TEST is
begin
   status_led <= dip3;
   pow_ok_led <= dip4;
   lvds_txa <= lvds_clk;
   lvds_txb <= lvds_clk;
   nfault_led <= '1';
end BEH;
