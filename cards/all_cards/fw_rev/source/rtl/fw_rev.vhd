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
-- Project:      SCUBA2
-- Author:       Mandana Amiri
-- Organisation: UBC
--
-- Description:
-- A firmware-revision register that acts as a wishbone slave:
-- The revision is: RRrrBBBB where 
--                  RR is the major revision number
--                  rr is the minor revision number                   
--                  BBBB is the build number
--
-- Revision history:
-- <date $Date$>    - <initials $Author$>
-- $Log$ 
--
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library sys_param;
use sys_param.wishbone_pack.all;

entity fw_rev is
generic(REVISION         :std_logic_vector (31 downto 0) := X"01010001");
   port(clk_i   : in std_logic;
        rst_i   : in std_logic;		
        
        -- Wishbone signals
        dat_i 	 : in std_logic_vector (WB_DATA_WIDTH-1 downto 0); 
        addr_i  : in std_logic_vector (WB_ADDR_WIDTH-1 downto 0);
        tga_i   : in std_logic_vector (WB_TAG_ADDR_WIDTH-1 downto 0);
        we_i    : in std_logic;
        stb_i   : in std_logic;
        cyc_i   : in std_logic;
        dat_o   : out std_logic_vector (WB_DATA_WIDTH-1 downto 0);
        ack_o   : out std_logic
      );
end fw_rev;

architecture rtl of fw_rev is

type states is (IDLE, READ, DONE);
signal present_state : states;
signal next_state    : states;

signal read_cmd      : std_logic;

signal fw_rev_data      : std_logic_vector(31 downto 0);

begin
   fw_rev_data <= REVISION;
------------------------------------------------------------------------
--
-- Firmware Revision Wishbone slave FSM
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
         when IDLE =>        
            if(read_cmd = '1') then
               next_state <= READ;
            else
               next_state <= IDLE;
            end if;
                        
         when READ => 
            next_state <= DONE;
         
         when DONE => 
            next_state <= IDLE;
         
         when others =>
            next_state <= IDLE;
         
      end case;
   end process state_NS;
   
   state_out: process(present_state, fw_rev_data)
   begin
      case present_state is
         when IDLE =>        
            ack_o       <= '0';
            dat_o       <= (others => '0');
                             
         when READ => 
            ack_o       <= '1';
            dat_o       <= fw_rev_data;
                             
         when DONE =>        
            ack_o       <= '0';
            dat_o       <= (others => '0');            
      end case;
   end process state_out;

   read_cmd  <= '1' when (addr_i = FW_REV_ADDR and stb_i = '1' and cyc_i = '1' and we_i = '0') else '0';
   
end rtl;