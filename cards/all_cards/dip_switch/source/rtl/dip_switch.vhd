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

-- dip.vhd
--
-- <revision control keyword substitutions e.g. $Id$>
--
-- Project:	      SCUBA-2
-- Author:	       Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- implements the interface for reading the DIP switch state
--
-- Revision history:
-- Feb. 15 2004  - initial version      - EL
-- <date $Date$>	-		<text>		- <initials $Author$>

--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library sys_param;
use sys_param.wishbone_pack.all;

library components;
use components.component_pack.all;

library work;
use work.dip_switch_pack.all;

entity dip_switch is
port(dip_switch_i  : in std_logic_vector(DIP_SWITCH_BITS-1 downto 0);
     
     -- wishbone signals:
     clk_i  : in std_logic;
     rst_i  : in std_logic;
     dat_i  : in std_logic_vector(WB_DATA_WIDTH - 1 downto 0);
     addr_i : in std_logic_vector(WB_ADDR_WIDTH - 1 downto 0);
     we_i   : in std_logic;
     stb_i  : in std_logic;
     cyc_i  : in std_logic;
     dat_o  : out std_logic_vector(WB_DATA_WIDTH - 1 downto 0);
     ack_o  : out std_logic);
end dip_switch;

architecture behav of dip_switch is
signal dip_reg      : std_logic_vector(DIP_SWITCH_BITS-1 downto 0);
signal dip_rd_valid : std_logic;
signal dip_wr_ready : std_logic;

signal padded_dip_reg : std_logic_vector(WB_DATA_WIDTH-1 downto 0);

signal dummy_wr_data_valid : std_logic;
signal dummy_data          : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
begin

------------------------------------------------------------------------
--
-- Read DIP Switch
--
------------------------------------------------------------------------ 

   read_dip : process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         dip_reg <= (others => '0');
         dip_rd_valid <= '0';
      elsif(clk_i'event and clk_i = '1') then
         dip_reg <= dip_switch_i;
         dip_rd_valid <= '1';
      end if;
   end process read_dip;
   
   padded_dip_reg(WB_DATA_WIDTH-1 downto DIP_SWITCH_BITS) <= (others => '0');
   padded_dip_reg(DIP_SWITCH_BITS-1 downto 0) <= dip_reg;
   
------------------------------------------------------------------------
--
-- Wishbone
--
------------------------------------------------------------------------ 

   dip_wr_ready <= '0';

   slave_interface : slave_ctrl
   generic map(SLAVE_SEL  => DIP_ADDR, 
               ADDR_WIDTH => WB_ADDR_WIDTH,
               DATA_WIDTH => WB_DATA_WIDTH)
      
   port map(slave_rd_data_valid => dip_rd_valid, 
            slave_wr_ready      => dip_wr_ready,
            slave_ctrl_dat_i         => padded_dip_reg,
            
            master_wr_data_valid => dummy_wr_data_valid, 
            slave_ctrl_dat_o         => dummy_data, 
      
            -- wishbone signals
            clk_i  => clk_i,
            rst_i  => rst_i, 
            dat_i 	=> dat_i,
            addr_i => addr_i,
            we_i   => we_i,
            stb_i  => stb_i,
            cyc_i  => cyc_i, 
            dat_o  => dat_o, 
            ack_o  => ack_o);
end behav;