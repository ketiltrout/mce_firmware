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
-- <revision control keyword substitutions e.g. $Id: fw_rev_pack.vhd,v 1.1 2005/02/21 22:25:15 mandana Exp $>
--
-- Project:      SCUBA2
-- Author:       Mandana Amiri
-- Organisation: UBC
--
-- Description:
-- fw_rev pack file
--
-- Revision history:
-- <date $Date: 2005/02/21 22:25:15 $>    - <initials $Author: mandana $>
-- $Log: fw_rev_pack.vhd,v $
-- Revision 1.1  2005/02/21 22:25:15  mandana
-- Initial release of firmware revision register
-- 
--
------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library sys_param;
use sys_param.wishbone_pack.all;

package fw_rev_pack is
   -- component declaration:
   component fw_rev
   generic ( REVISION: std_logic_vector (31 downto 0) := X"01010000");
   port(clk_i   : in std_logic;
        rst_i   : in std_logic;		
        
        -- Wishbone signals
        dat_i 	 : in std_logic_vector (WB_DATA_WIDTH-1 downto 0); -- not used since not writing to array ID
        addr_i  : in std_logic_vector (WB_ADDR_WIDTH-1 downto 0);
        tga_i   : in std_logic_vector (WB_TAG_ADDR_WIDTH-1 downto 0);
        we_i    : in std_logic;
        stb_i   : in std_logic;
        cyc_i   : in std_logic;
        err_o   : out std_logic;
        dat_o   : out std_logic_vector (WB_DATA_WIDTH-1 downto 0);
        ack_o   : out std_logic
      );
   end component;      
   
end fw_rev_pack;