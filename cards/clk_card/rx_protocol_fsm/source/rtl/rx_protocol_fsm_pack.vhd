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
-- rx_protocol_fsm_pack.vhd
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
USE ieee.std_logic_1164.all;

package rx_protocol_fsm_pack is

component rx_protocol_fsm 
   port( 
      Brst        : in     std_logic;
      clk         : in     std_logic;
      rx_fe_i     : in     std_logic;
      rxd_i       : in     std_logic_vector (7 DOWNTO 0);
      card_addr_o : out    std_logic_vector (7 DOWNTO 0);
      cmd_code_o  : out    std_logic_vector (15 DOWNTO 0);
      cmd_data_o  : out    std_logic_vector (15 DOWNTO 0);
      cksum_err_o : out    std_logic;
      cmd_rdy_o   : out    std_logic;
      data_clk_o  : out    std_logic;
      num_data_o  : out    std_logic_vector (7 downto 0);
      reg_addr_o  : out    std_logic_vector (23 DOWNTO 0);
      rx_fr_o     : out    std_logic
   );

end component;

end rx_protocol_fsm_pack;
