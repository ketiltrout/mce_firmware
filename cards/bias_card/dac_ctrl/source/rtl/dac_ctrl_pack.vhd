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

-- dac_ctrl_pack.vhd
--

-- Project:	      SCUBA-2
-- Author:	      Mandana Amiri
-- Organisation:  UBC
--
-- Description:
-- package file for dac_ctrl
--
-- 
-- Revision history:
-- <date $Date: 2004/04/29 20:51:03 $>	- <initials $Author: mandana $>
-- $Log: dac_ctrl_pack.vhd,v $
-- Revision 1.5  2004/04/29 20:51:03  mandana
-- added dac_nclr signal
--
-- Revision 1.4  2004/04/21 19:59:59  mandana
-- edited the log header
--
-- Revision 1.3  2004/04/21 16:52:16  mandana
-- change DAC_CTRL_ADDR to DAC32_CTRL_ADDR
--
-- Revision 1.2  2004/04/15 18:23:55  mandana
-- fixed typo
--
-- Revision 1.1  2004/04/14 21:50:27  jjacob
-- new directory structure
--
-- Revision 1.1  2004/04/08 17:55:54  mandana
-- Initial release
--   
--
--
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library sys_param;
use sys_param.wishbone_pack.all;

package dac_ctrl_pack is

component dac_ctrl
   generic(DAC32_CTRL_ADDR : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := FLUX_FB_ADDR;
           DAC_LVDS_CTRL_ADDR : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := BIAS_ADDR);
        
   port(-- DAC signals:
        dac_data_o  : out std_logic_vector(32 downto 0);   
        dac_ncs_o   : out std_logic_vector(32 downto 0);
        dac_clk_o   : out std_logic_vector(32 downto 0);
        -- wishbone signals:
        clk_i   : in  std_logic;
        rst_i   : in  std_logic;		
        dat_i 	: in  std_logic_vector (WB_DATA_WIDTH-1 downto 0);
        addr_i  : in  std_logic_vector (WB_ADDR_WIDTH-1 downto 0);
        tga_i   : in  std_logic_vector (WB_TAG_ADDR_WIDTH-1 downto 0);
        we_i    : in  std_logic;
        stb_i   : in  std_logic;
        cyc_i   : in  std_logic;
        dat_o   : out std_logic_vector (WB_DATA_WIDTH-1 downto 0);
        rty_o   : out std_logic;
        ack_o   : out std_logic;
        sync_i  : in  std_logic
   );     
   end component;
end dac_ctrl_pack;

