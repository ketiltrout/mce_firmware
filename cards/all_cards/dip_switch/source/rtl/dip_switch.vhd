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
-- <revision control keyword substitutions e.g. $Id: dip_switch.vhd,v 1.1 2004/03/05 22:38:35 jjacob Exp $>
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
-- <date $Date: 2004/03/05 22:38:35 $>	-		<text>		- <initials $Author: jjacob $>
-- $Log$
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library sys_param;
use sys_param.wishbone_pack.all;

-- Obsolete:
--
--library components;
--use components.component_pack.all;

library work;
use work.dip_switch_pack.all;

entity dip_switch is
port(dip_switch_i  : in std_logic_vector(DIP_SWITCH_BITS-1 downto 0);
     
     -- wishbone signals:
     clk_i  : in std_logic;
     rst_i  : in std_logic;
     addr_i : in std_logic_vector(WB_ADDR_WIDTH - 1 downto 0);
     dat_i  : in std_logic_vector(WB_DATA_WIDTH - 1 downto 0);
     dat_o  : out std_logic_vector(WB_DATA_WIDTH - 1 downto 0);
     tga_i  : in std_logic_vector(WB_TAG_ADDR_WIDTH - 1 downto 0);
     we_i   : in std_logic;
     stb_i  : in std_logic;
     cyc_i  : in std_logic;
     rty_o  : out std_logic;
     ack_o  : out std_logic);
end dip_switch;

architecture behav of dip_switch is
type states is (IDLE, SEND_PACKET, DONE);
signal present_state : states;
signal next_state    : states;

signal read_cmd : std_logic;

signal padded_dip_data : std_logic_vector(WB_DATA_WIDTH-1 downto 0);

-- Obsolete:
--
--signal dip_reg      : std_logic_vector(DIP_SWITCH_BITS-1 downto 0);
--signal dip_rd_valid : std_logic;
--signal dip_wr_ready : std_logic;
--signal dummy_wr_data_valid : std_logic;
--signal dummy_data          : std_logic_vector(WB_DATA_WIDTH-1 downto 0);

begin

------------------------------------------------------------------------
--
-- DIP Switch Wishbone slave controller
--
------------------------------------------------------------------------ 

   state_FF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         present_state <= IDLE;
      elsif(clk_i'event and clk_i = '1') then
         present_state <= next_state;
      end if;
   end process state_FF;
   
   state_NS: process(present_state, read_cmd)
   begin
      case present_state is
         when IDLE =>        if(read_cmd = '1') then
                                next_state <= SEND_PACKET;
                             else
                                next_state <= IDLE;
                             end if;
                             
         when SEND_PACKET => next_state <= DONE;
         
         when DONE =>        next_state <= IDLE;
      end case;
   end process state_NS;
   
   state_out: process(present_state, padded_dip_data)
   begin
      case present_state is
         when IDLE =>        dat_o <= (others => '0');
                             ack_o <= '0';
                             
         when SEND_PACKET => dat_o <= padded_dip_data;
                             ack_o <= '1';
                             
         when DONE =>        dat_o <= (others => '0');
                             ack_o <= '0';
      end case;
   end process;

------------------------------------------------------------------------
--
-- Read DIP Switch
--
------------------------------------------------------------------------ 

   padded_dip_data(WB_DATA_WIDTH-1 downto DIP_SWITCH_BITS) <= (others => '0');
   padded_dip_data(DIP_SWITCH_BITS-1 downto 0) <= dip_switch_i;


-- Obsolete:
--
--   read_dip : process(clk_i, rst_i)
--   begin
--      if(rst_i = '1') then
--         dip_reg <= (others => '0');
--         dip_rd_valid <= '0';
--      elsif(clk_i'event and clk_i = '1') then
--         dip_reg <= dip_switch_i;
--         dip_rd_valid <= '1';
--      end if;
--   end process read_dip;

------------------------------------------------------------------------
--
-- Wishbone
--
------------------------------------------------------------------------ 

   read_cmd <= '1' when (addr_i = DIP_ADDR and stb_i = '1' and cyc_i = '1' and we_i = '0') else '0';

   rty_o <= '0';
   
-- Obsolete:
--
--   dip_wr_ready <= '0';
--
--   slave_interface : slave_ctrl
--   generic map(SLAVE_SEL  => DIP_ADDR, 
--               ADDR_WIDTH => WB_ADDR_WIDTH,
--               DATA_WIDTH => WB_DATA_WIDTH)
--      
--   port map(slave_rd_data_valid => dip_rd_valid, 
--            slave_wr_ready      => dip_wr_ready,
--            slave_ctrl_dat_i         => padded_dip_reg,
--            
--            master_wr_data_valid => dummy_wr_data_valid, 
--            slave_ctrl_dat_o         => dummy_data, 
--      
--            -- wishbone signals
--            clk_i  => clk_i,
--            rst_i  => rst_i, 
--            dat_i 	=> dat_i,
--            addr_i => addr_i,
--            we_i   => we_i,
--            stb_i  => stb_i,
--            cyc_i  => cyc_i, 
--            dat_o  => dat_o, 
--            ack_o  => ack_o);
end behav;