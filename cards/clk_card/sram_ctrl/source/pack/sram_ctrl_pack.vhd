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

-- sram_ctrl_pack.vhd
--
-- <revision control keyword substitutions e.g. $Id$>
--
-- Project:	      SCUBA-2
-- Author:	       Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- package file for the SRAM controller
--
-- Revision history:
-- <date $Date$>	-		<text>		- <initials $Author$>

--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library sys_param;
use sys_param.wishbone_pack.all;

package sram_ctrl_pack is

component sram_ctrl
   generic(ADDR_WIDTH     : integer := WB_ADDR_WIDTH;
           DATA_WIDTH     : integer := WB_DATA_WIDTH;
           TAG_ADDR_WIDTH : integer := WB_TAG_ADDR_WIDTH);
        
   port(-- SRAM signals:
        addr_o  : out std_logic_vector(19 downto 0);
        data_bi : inout std_logic_vector(15 downto 0);
        n_ble_o : out std_logic;
        n_bhe_o : out std_logic;
        n_oe_o  : out std_logic;
        n_ce1_o : out std_logic;
        ce2_o   : out std_logic;
        n_we_o  : out std_logic;
     
        -- wishbone signals:
        clk_i   : in std_logic;
        rst_i   : in std_logic;		
        dat_i 	 : in std_logic_vector (DATA_WIDTH-1 downto 0);
        addr_i  : in std_logic_vector (ADDR_WIDTH-1 downto 0);
        tga_i   : in std_logic_vector (TAG_ADDR_WIDTH-1 downto 0);
        we_i    : in std_logic;
        stb_i   : in std_logic;
        cyc_i   : in std_logic;
        dat_o   : out std_logic_vector (DATA_WIDTH-1 downto 0);
        rty_o   : out std_logic;
        ack_o   : out std_logic);     
   end component;
   
end sram_ctrl_pack;