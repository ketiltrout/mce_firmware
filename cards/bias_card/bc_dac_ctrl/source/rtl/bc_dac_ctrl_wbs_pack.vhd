-- 2003 SCUBA-2 Project
--                  All Rights Reserved
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
-- $Id: wbs_bc_dac_ctrl_pack.vhd,v 1.1 2004/11/11 01:46:56 bburger Exp $
--
-- Project:       SCUBA2
-- Author:        Bryce Burger
-- Organisation:  UBC
--
-- Description:
-- Wishbone interface for a 16-bit serial DAC controller
-- This block was written to be coupled with bc_dac_ctrl
--
-- Revision history:
-- $Log: wbs_bc_dac_ctrl_pack.vhd,v $
-- Revision 1.1  2004/11/11 01:46:56  bburger
-- Bryce:  new
--
--
--
-----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;

library work;
use work.bc_dac_ctrl_pack.all;

package bc_dac_ctrl_wbs_pack is

component bc_dac_ctrl_wbs is        
   port
   (
      -- ac_dac_ctrl interface:
      flux_fb_addr_i    : in std_logic_vector(COL_ADDR_WIDTH-1 downto 0);
      flux_fb_data_o    : out std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
      bias_data_o       : out std_logic_vector(PACKET_WORD_WIDTH-1 downto 0); 
      flux_fb_changed_o : out std_logic;
      bias_changed_o    : out std_logic;

      -- wishbone interface:
      dat_i             : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      addr_i            : in std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
      tga_i             : in std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
      we_i              : in std_logic;
      stb_i             : in std_logic;
      cyc_i             : in std_logic;
      dat_o             : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      ack_o             : out std_logic;

      -- global interface
      clk_i             : in std_logic;
      mem_clk_i         : in std_logic;
      rst_i             : in std_logic
   );     
end component;

end package;