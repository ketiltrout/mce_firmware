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
-- <revision control keyword substitutions e.g. $Id: dip_switch.vhd,v 1.3 2004/05/06 18:18:37 erniel Exp $>
--
-- Project:	      SCUBA-2
-- Author:	       Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- implements the interface for reading the DIP switch state
--
-- Revision history:
--
-- $Log: dip_switch.vhd,v $
-- Revision 1.3  2004/05/06 18:18:37  erniel
-- removed obsolete code
-- defined number of dip switch bits in a GENERIC
--
-- Revision 1.2  2004/03/29 21:39:48  erniel
-- removed obsolete slave_ctrl instantiation
-- added rty_o signal
-- added tga_i signal
--
-- Feb. 15 2004  - initial version      - EL
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library sys_param;
use sys_param.wishbone_pack.all;

entity dip_switch is
generic(WIDTH : in integer range 1 to 16 := 4);
port(dip_switch_i  : in std_logic_vector(WIDTH-1 downto 0);
     
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

   padded_dip_data(WB_DATA_WIDTH-1 downto WIDTH) <= (others => '0');
   padded_dip_data(WIDTH-1 downto 0) <= dip_switch_i;


------------------------------------------------------------------------
--
-- Wishbone
--
------------------------------------------------------------------------ 

   read_cmd <= '1' when (addr_i = DIP_ADDR and stb_i = '1' and cyc_i = '1' and we_i = '0') else '0';

   rty_o <= '0';
   
end behav;