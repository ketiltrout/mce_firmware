-- Copyright (c) 2003 SCUBA-2 Project
--               All Rights Reserved
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
-- UBC, University of British Columbia, Physics & Astronomy Department,
-- Vancouver BC, V6T 1Z1
--
-- rx_control_pack.vhd
--
-- <revision control keyword substitutions e.g. $Id$>
--
-- Project: Scuba 2
-- Author: David Atkinson	
-- Organisation: UK ATC
--
-- Description:
-- <description text>
--
-- Revision history:
-- <date $Date$> - <text> - <initials $Author$>
-- $LOG$

library ieee;
use ieee.std_logic_1164.all;

package rx_control_pack is

   component rx_control
      port( 
         nRx_rdy_i : in     std_logic;
         rsc_nRd_i : in     std_logic;
         rso_i     : in     std_logic;
         rvs_i     : in     std_logic;
         rx_ff_i   : in     std_logic;
         rx_fw_o   : out    std_logic
   );
   end component;

end rx_control_pack;