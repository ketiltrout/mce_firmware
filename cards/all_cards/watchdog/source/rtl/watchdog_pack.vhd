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
-- <Title>
--
-- <revision control keyword substitutions e.g. $Id: watchdog_pack.vhd,v 1.1 2004/04/14 21:48:20 jjacob Exp $>
--
-- Project:		SCUBA2
-- Author:		Bryce Burger
-- Organisation:	SCUBA2
--
-- Description:
-- <description text>
--
-- Revision history:
-- <date $Date: 2004/04/14 21:48:20 $>	-		<text>		- <initials $Author: jjacob $>
-- $Log: watchdog_pack.vhd,v $
-- Revision 1.1  2004/04/14 21:48:20  jjacob
-- new directory structure
--
-- Revision 1.3  2004/04/08 18:42:26  erniel
-- removed obsolete signals
--
--
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library sys_param;
use sys_param.wishbone_pack.all;

package watchdog_pack is
  
   component watchdog
      generic (
         ADDR_WIDTH : integer := WB_ADDR_WIDTH;
         DATA_WIDTH : integer := WB_DATA_WIDTH;
         TAG_ADDR_WIDTH : integer := WB_TAG_ADDR_WIDTH
      );
      port (      
         clk_i   : in std_logic;
         rst_i   : in std_logic;		
         dat_i 	 : in std_logic_vector (WB_DATA_WIDTH-1 downto 0); -- not used since not writing to array ID
         addr_i  : in std_logic_vector (WB_ADDR_WIDTH-1 downto 0);
         tga_i   : in std_logic_vector (TAG_ADDR_WIDTH-1 downto 0);
         we_i    : in std_logic;
         stb_i   : in std_logic;
         cyc_i   : in std_logic;
         dat_o   : out std_logic_vector (WB_DATA_WIDTH-1 downto 0);
         rty_o   : out std_logic;
         ack_o   : out std_logic;         

         you_kick_my_dog : out std_logic
      );
   end component;      
   
end watchdog_pack;