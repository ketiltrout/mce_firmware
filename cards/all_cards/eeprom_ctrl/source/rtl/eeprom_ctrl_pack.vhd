-- Copyright (c) 2003 SCUBA-2 Project
--               All Rights Reserved
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
-- component_pack
--
-- <revision control keyword substitutions e.g. $Id: eeprom_ctrl_pack.vhd,v 1.3 2004/03/31 18:59:30 jjacob Exp $>
--
-- Project:		SCUBA-2
-- Author:		Jonathan Jacob
-- Organisation:	UBC
--
-- Description:
-- This file contains the declarations for the EEPROM controller
--
-- Revision history:
-- 
--
-- <date $Date: 2004/03/31 18:59:30 $>	-		<text>		- <initials $Author: jjacob $>
--
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library sys_param;
use sys_param.general_pack.all;
use sys_param.wishbone_pack.all;

package eeprom_ctrl_pack is

------------------------------------------------------------
--
-- component for the EEPROM Controller
--
------------------------------------------------------------  

component eeprom_ctrl

generic(EEPROM_CTRL_ADDR : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := EEPROM_ADDR  );

port(

     -- EEPROM interface:
     
     -- outputs to the EEPROM
     n_eeprom_cs_o   : out std_logic; -- low enable eeprom chip select
     n_eeprom_hold_o : out std_logic; -- low enable eeprom hold
     n_eeprom_wp_o   : out std_logic; -- low enable write protect
     eeprom_si_o     : out std_logic; -- serial input data to the eeprom
     eeprom_clk_o    : out std_logic; -- clock signal to EEPROM     
     
     -- inputs from the EEPROM
     eeprom_so_i     : in std_logic;  -- serial output data from the eeprom
     
     -- Wishbone interface:
     clk_i   : in std_logic;
     rst_i   : in std_logic;		
     addr_i  : in std_logic_vector (WB_ADDR_WIDTH-1 downto 0);
     tga_i   : in std_logic_vector (WB_TAG_ADDR_WIDTH-1 downto 0);
     dat_i 	 : in std_logic_vector (WB_DATA_WIDTH-1 downto 0);
     dat_o   : out std_logic_vector (WB_DATA_WIDTH-1 downto 0);
     we_i    : in std_logic;
     stb_i   : in std_logic;
     ack_o   : out std_logic;
     rty_o   : out std_logic;
     cyc_i   : in std_logic ); 
     
end component;

end eeprom_ctrl_pack;