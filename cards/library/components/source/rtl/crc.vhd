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

-- crc.vhd
--
-- <revision control keyword substitutions e.g. $Id$>
--
-- Project:		 SCUBA-2
-- Author:		 Ernie Lin
-- Organisation: UBC
--
-- Description:
-- This implements the CRC algorithm using X^8 + X^5 + X^4 + 1
--
-- Revision history:
-- Dec. 12 2003  - Initial version      - EL
-- Jan. 29 2004  - Modified interface   - EL
-- Jan. 31 2004  - Added control logic  - EL
-- <date $Date$>	-		<text>		- <initials $Author$>

--
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity crc is
generic(DATA_LENGTH : integer := 64);

port(clk         : in std_logic;
     rst         : in std_logic;
     crc_start_i : in std_logic;
     crc_done_o  : out std_logic;
     crc_data_i  : in std_logic_vector(DATA_LENGTH-1 downto 0);
     valid_o     : out std_logic);
end crc;
	
architecture behav of crc is

-- state encoding:
constant IDLE       : std_logic_vector(1 downto 0) := "00";
constant SHIFT_DATA : std_logic_vector(1 downto 0) := "01";
constant CRC_DONE   : std_logic_vector(1 downto 0) := "10";

-- state variables:
signal present_state : std_logic_vector(1 downto 0) := "00";
signal next_state    : std_logic_vector(1 downto 0) := "00";

-- misc signals and registers:
signal crc_reg    : std_logic_vector(7 downto 0);
signal crc_fb     : std_logic;
signal crc_enable : std_logic;

signal data_reg      : std_logic_vector(DATA_LENGTH-1 downto 0);
signal data_reg_load : std_logic;

signal bit_count : integer;

begin

--------------------------------------------------
-- Control logic:

   state_FF: process(clk, rst)
   begin
      if(rst = '1') then
         present_state <= IDLE;
      elsif(clk'event and clk = '1') then
         present_state <= next_state;
      end if;
   end process state_FF;
   
   next_state_logic: process(present_state, crc_start_i, bit_count)
   begin
      case present_state is
         when IDLE => 
            if(crc_start_i = '1') then
               next_state <= SHIFT_DATA;
            else
               next_state <= IDLE;
            end if;
            
         when SHIFT_DATA =>
            if(bit_count = DATA_LENGTH) then
               next_state <= CRC_DONE;
            else
               next_state <= SHIFT_DATA;
            end if;
         
         when CRC_DONE =>
            next_state <= IDLE;
            
         when others =>
            next_state <= IDLE;
            
      end case;
   end process next_state_logic;
   
   output_logic: process(present_state)
   begin
      case present_state is
         when IDLE =>
            data_reg_load <= '1';
            crc_enable <= '0';
            crc_done_o <= '0';

         when SHIFT_DATA =>
            data_reg_load <= '0';
            crc_enable <= '1';
            crc_done_o <= '0';

         when CRC_DONE =>
            data_reg_load <= '0';
            crc_enable <= '0';
            crc_done_o <= '1';

         when others =>
            data_reg_load <= '0';
            crc_enable <= '0';
            crc_done_o <= '0';

      end case;
   end process output_logic;

--------------------------------------------------
-- Data storage:

   -- this process implements a shift register with parallel load and shift enable
   -- (data is shifted out LSB first)
   data_shift_reg : process(clk, rst)
   begin
      if(rst = '1') then
         data_reg <= (others => '0');
      elsif(clk'event and clk = '1') then
         if(data_reg_load = '1') then
            data_reg <= crc_data_i;
         elsif(crc_enable = '1') then
            data_reg <= '0' & data_reg(DATA_LENGTH-1 downto 1);
         end if;
      end if;
   end process data_shift_reg;

--------------------------------------------------
-- CRC logic:

   crc_fb <= crc_reg(0) xor data_reg(0);
   
   -- this process implements the X^8 + X^5 + X^4 + 1 CRC polynomial
   calc_crc : process(clk, rst)
   begin
      if(rst = '1') then
         crc_reg <= "00000000";
         bit_count <= 0;
      elsif(clk'event and clk = '1') then
         if(crc_enable = '1') then
            crc_reg <= crc_fb & crc_reg(7 downto 5) & (crc_fb xor crc_reg(4)) & (crc_fb xor crc_reg(3)) & crc_reg(2 downto 1);
            bit_count <= bit_count + 1;
         end if;
      end if;
   end process calc_crc;
   
   -- if CRC match, then crc_reg = 0.
   -- this process implements NOR (the == 0 operator) of crc_reg bits.  
   valid_bit : process(crc_reg)  
   variable temp : std_logic;
   begin
      temp := crc_reg(0) or crc_reg(1);
      for i in 2 to 7 loop
         temp := temp or crc_reg(i);
      end loop;
      valid_o <= not temp;
   end process valid_bit;
   
end behav;