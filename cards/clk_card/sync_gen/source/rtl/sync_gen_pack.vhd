-- Copyright (c) 2003 SCUBA-2 Project
--                  All Rights Reserved

--  THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF THE SCUBA-2 Project
--  The copyright notice above does not evidence any
--  actual or intended publication of such source code.

--  SOURCE CODE IS PROVIDED "AS IS". ALL EXPRESS OR IMPLIED CONDITIONS,
--  REPRESENTATIONS, AND WARRANTIES, INCLUDING ANY IMPLIED WARRANT OF
--  MERCHANTABILITY, SATISFACTORY QUALITY, FITNESS FOR A PARTICULAR
--  PURPOSE, OR NON-INFRINGEMENT, ARE DISCLAIMED, EXCEPT TO THE EXTENT
--  THAT SUCH DISCLAIMERS ARE HELD TO BE LEGALLY INVALID.

-- For the purposes of this code the SCUBA-2 Project consists of the
-- following organisations.

-- UKATC, Royal Observatory, Blackford Hill Edinburgh EH9 3HJ
-- UBC,   University of British Columbia, Physics & Astronomy Department,
--        Vancouver BC, V6T 1Z1

-- sync_gen_pack.vhd
--
-- Project:		 SCUBA-2
-- Author:		 Bryce Burger
-- Organisation:	 UBC
--
-- Description:
-- This implements the sync pulse generation on the Clock Card.
--
-- Revision history:
-- $Log: sync_gen_pack.vhd,v $
-- Revision 1.1  2004/08/05 00:19:33  bburger
-- Bryce:  new
--
--
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package sync_gen_pack is

   constant SYNC_NUM_WIDTH     : integer := 8;
   
   constant ISSUE_SYNC_WIDTH   : integer := SYNC_NUM_WIDTH;
   constant TIMEOUT_SYNC_WIDTH : integer := SYNC_NUM_WIDTH;
   
   component sync_gen
      port(
         clk_i       : in std_logic;
         rst_i       : in std_logic;
         dv_i        : in std_logic;
         dv_en_i     : in std_logic;
         sync_o      : out std_logic;
         sync_num_o  : out std_logic_vector(SYNC_NUM_WIDTH-1 downto 0)
      );
   end component;
end sync_gen_pack;