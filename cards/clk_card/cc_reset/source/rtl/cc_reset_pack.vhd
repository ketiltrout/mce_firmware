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
--
--
-- Project:       SCUBA-2
-- Author:        David Atkinson
--               
-- Organisation:  UK ATC
--
-- Description: package for cc_reset 
-- 
-- Revision history:
-- <date $Date: 2005/01/13 16:32:29 $> - <text> - <initials $Author: dca $>
--
-- $Log: cc_reset_pack.vhd,v $
-- Revision 1.1  2005/01/13 16:32:29  dca
-- Initial Versions
--
--
-----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;


package cc_reset_pack is

constant SPEC_CHAR_RESET : std_logic_vector (7 downto 0) := x"0B";

------------------
component cc_reset
------------------ 
   port( 
      clk_i      : in     std_logic;
      rst_n_i    : in     std_logic;
      nRx_rdy_i  : in     std_logic;                       -- hotlink receiver data ready (active low)
      rsc_nRd_i  : in     std_logic;                       -- hotlink receiver special character/(not) Data 
      rso_i      : in     std_logic;                       -- hotlink receiver status out
      rvs_i      : in     std_logic;                       -- hotlink receiver violation symbol detected
      rx_data_i  : in     std_logic_vector (7 downto 0);   -- hotlink receiver data byte
      reset_o    : out    std_logic                        -- cc firmware reset      
   );

end component;

end cc_reset_pack;
 