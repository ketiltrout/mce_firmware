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
-- <revision control keyword substitutions e.g. $Id: card_id_pack.vhd,v 1.1 2004/04/14 21:40:58 jjacob Exp $>
--
-- Project:		<project name>
-- Author:		<author name>
-- Organisation:	<organisation name>
--
-- Description:
-- <description text>
--
-- Revision history:
-- <date $Date: 2004/04/14 21:40:58 $>	-		<text>		- <initials $Author: jjacob $>
--
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library sys_param;
use sys_param.wishbone_pack.all;

package card_id_pack is


   signal READ_ROM_CMD : std_logic_vector(7 downto 0) := "00110011"; -- 0x33


------------------------------------------------------------------------
--
-- card_id
--
------------------------------------------------------------------------ 
 
   component card_id


   generic(--WB_DATA_WIDTH         : integer := WB_DATA_WIDTH;
           --WB_ADDR_WIDTH         : integer := WB_ADDR_WIDTH;
           CARD_ID_ADDR         : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := CARD_ID_ADDR  );

   port(-- ID chip interface:
        data_bi : inout std_logic;

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

end card_id_pack;