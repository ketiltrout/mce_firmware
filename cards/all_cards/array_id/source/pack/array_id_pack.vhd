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
-- <revision control keyword substitutions e.g. $Id$>
--
-- Project:		<project name>
-- Author:		<author name>
-- Organisation:	<organisation name>
--
-- Description:
-- <description text>
--
-- Revision history:
-- <date $Date$>	-		<text>		- <initials $Author$>
--
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library sys_param;
use sys_param.wishbone_pack.all;

package array_id_pack is

   constant ARRAY_ID_BITS : integer := 3;
  
   component array_id
      generic (
         ARRAY_ID_ADDR : std_logic_vector(WB_ADDR_WIDTH - 1 downto 0) := ARRAY_ID_ADDR;
         ARRAY_ID_ADDR_WIDTH : integer := WB_ADDR_WIDTH;
         ARRAY_ID_DATA_WIDTH : integer := WB_DATA_WIDTH;
         TAG_ADDR_WIDTH : integer := WB_TAG_ADDR_WIDTH
      );
      port (      
         array_id_i : in std_logic_vector (ARRAY_ID_BITS-1 downto 0);
         -- wishbone signals
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
         ack_o   : out std_logic 
      );
   end component;      
   
end array_id_pack;