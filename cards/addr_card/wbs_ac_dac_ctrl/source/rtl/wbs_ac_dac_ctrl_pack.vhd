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
-- $Id: wbs_ac_dac_ctrl_pack.vhd,v 1.3 2004/11/02 07:38:09 bburger Exp $
--
-- Project:       SCUBA2
-- Author:        Bryce Burger
-- Organisation:  UBC
--
-- Description:
-- Wishbone interface for a 14-bit 165MS/s DAC (AD9744) controller
-- This block was written to be coupled with wbs_ac_dac_ctrl
--
-- Revision history:
-- $Log: wbs_ac_dac_ctrl_pack.vhd,v $
-- Revision 1.3  2004/11/02 07:38:09  bburger
-- Bryce:  ac_dac_ctrl in progress
--
--
-----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;

package wbs_ac_dac_ctrl_pack is

constant ROW_ADDR_WIDTH : integer := 6; 

component wbs_ac_dac_ctrl is        
   port
   (
      -- ac_dac_ctrl interface:
      on_off_addr_i  : in std_logic_vector(ROW_ADDR_WIDTH-1 downto 0);
      dac_id_o       : out std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
      on_data_o      : out std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
      off_data_o     : out std_logic_vector(PACKET_WORD_WIDTH-1 downto 0); 
      mux_en_o       : out std_logic;

      -- global interface
      clk_i          : in std_logic;
      mem_clk_i      : in std_logic;
      rst_i          : in std_logic; 
      
      -- wishbone interface:
      dat_i          : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      addr_i         : in std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
      tga_i          : in std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
      we_i           : in std_logic;
      stb_i          : in std_logic;
      cyc_i          : in std_logic;
      dat_o          : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      ack_o          : out std_logic
   );     
end component;

--component dpram_32bit_x_64 is
--   port
--   (
--      data     : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
--      wren     : IN STD_LOGIC  := '1';
--      wraddress      : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
--      rdaddress      : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
--      clock    : IN STD_LOGIC ;
--      q     : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
--   );
--end component;

component tpram_32bit_x_64 is
   PORT
   (
      data     : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
      wraddress      : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
      rdaddress_a    : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
      rdaddress_b    : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
      wren     : IN STD_LOGIC  := '1';
      clock    : IN STD_LOGIC ;
      qa    : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
      qb    : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
   );
end component;

end package;