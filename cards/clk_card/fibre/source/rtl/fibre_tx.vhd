---------------------------------------------------------------------
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
-- Project:	      SCUBA-2
-- Author:	      Mandana Amiri
-- 
-- Organisation:  UBC
--
-- Description:
-- fibre_tx file: just a port map, the wrapper should push the data in and assert enable.
--
-- Revision history:
-- <date $Date$>	- <initials $Author$>
-- $Log$
--
-----------------------------------------------------------------------------

library ieee, sys_param, components, work;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
--use components.component_pack.all;

-----------------------------------------------------------------------------

entity fibre_tx is
   port(     
      -- fibre pins
      fo_tx_data   : out std_logic_vector(7 downto 0);
      fibre_tx_clk    : out std_logic;
      fo_tx_ena    : out std_logic;
      fo_tx_rp	   : out std_logic;
      fo_tx_sc_nd  : out std_logic;
      -- fo_tx_svs is tied to gnd on board
      -- fo_tx_enn is tied to vcc on board
      -- fo_tx_mode is tied to gnd on board
     );
end fo_bist;
                     
architecture rtl of fo_bist is
   
begin
  
  fo_sc_nd <= '0';
  
end rtl;