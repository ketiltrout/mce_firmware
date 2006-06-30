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
-- $Id: dv_rx_pack.vhd,v 1.4 2006/05/13 07:38:49 bburger Exp $
--
-- Project:       SCUBA-2
-- Author:        Bryce Burger
-- Organization:  UBC
--
-- Description:
-- DV and Manchester Decoder
--
-- Revision history:
-- $Log: dv_rx_pack.vhd,v $
-- Revision 1.4  2006/05/13 07:38:49  bburger
-- Bryce:  Intermediate commital -- going away on holiday and don't want to lose work
--
-- Revision 1.3  2006/03/09 00:53:04  bburger
-- Bryce:
-- - Implemented the dv_fibre receiver
-- - Moved some constants from dv_rx_pack to sync_gen_pack
--
-- Revision 1.2  2006/02/28 09:20:58  bburger
-- Bryce:  Modified the interface of dv_rx.  Non-functional at this point.
--
-- Revision 1.1  2006/02/11 01:11:53  bburger
-- Bryce:  New!
--
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package dv_rx_pack is

   constant MANCHESTER_WORD_WIDTH      : integer := 40;

   FUNCTION   to_bigendian_std_logic_vector(   x: IN STD_LOGIC_VECTOR)  RETURN STD_LOGIC_VECTOR;
   FUNCTION   to_littleendian_std_logic_vector(x: IN STD_LOGIC_VECTOR)  RETURN STD_LOGIC_VECTOR;

end dv_rx_pack;

PACKAGE BODY dv_rx_pack IS

   -- These functions were borrowed from http://bear.ces.cwru.edu/vhdl/source/endian_h.vhd
   FUNCTION to_bigendian_std_logic_vector(x: IN std_logic_vector) RETURN std_logic_vector IS
     VARIABLE y: std_logic_vector(x'HIGH DOWNTO x'LOW); --big endian: HIGH DOWNTO LOW
   BEGIN
     FOR i IN x'RANGE LOOP y(i) := x(i); END LOOP;
     RETURN y;
   END to_bigendian_std_logic_vector;

   FUNCTION to_littleendian_std_logic_vector(x: IN std_logic_vector) RETURN std_logic_vector IS
     VARIABLE y: std_logic_vector(x'LOW TO x'HIGH); --little endian: LOW TO HIGH
   BEGIN
     FOR i IN x'RANGE LOOP y(i) := x(i); END LOOP;
     RETURN y;
   END to_littleendian_std_logic_vector;
  
END dv_rx_pack;