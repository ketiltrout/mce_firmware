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
-- <revision control keyword substitutions e.g. $Id: rx_protocol_fsm_pack.vhd,v 1.1 2004/04/20 09:33:40 dca Exp $>
--
-- Project: Scuba 2
-- Author: David Atkinson	
-- Organisation: UK ATC
--
-- Description:
-- <description text>
--
-- Revision history:
-- <date $Date: 2004/04/20 09:33:40 $> - <text> - <initials $Author: dca $>
-- $LOG$

library ieee;
USE ieee.std_logic_1164.all;

package rx_protocol_fsm_pack is

component rx_protocol_fsm 
   port( 
      rst_i       : in     std_logic;                          -- reset
      clk_i       : in     std_logic;                          -- clock 
      rx_fe_i     : in     std_logic;                          -- receive fifo empty flag
      rxd_i       : in     std_logic_vector (7 downto 0);      -- receive data byte 
      cmd_ack_i   : in     std_logic;                          -- command acknowledge

      cmd_code_o  : out    std_logic_vector (15 downto 0);     -- command code  
      card_id_o   : out    std_logic_vector (15 downto 0);     -- card id
      param_id_o  : out    std_logic_vector (15 downto 0);     -- parameter id
      num_data_o  : out    std_logic_vector (7 downto 0);      -- number of valid 32 bit data words
      cmd_data_o  : out    std_logic_vector (31 downto 0);     -- 32bit valid data word
      cksum_err_o : out    std_logic;                          -- checksum error flag
      cmd_rdy_o   : out    std_logic;                          -- command ready flag (checksum passed)
      data_clk_o  : out    std_logic;                          -- data clock
      rx_fr_o     : out    std_logic                           -- receive fifo read request
   );
   end component;

end rx_protocol_fsm_pack;
