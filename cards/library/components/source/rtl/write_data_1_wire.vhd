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

-- write_data_1_wire.vhd
--
-- <revision control keyword substitutions e.g. $Id: write_data_1_wire.vhd,v 1.2 2004/04/07 22:48:19 erniel Exp $>
--
-- Project:	      SCUBA-2
-- Author:	       Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Implements the master transmit protocol for 1-wire signalling
--
-- Revision history:
-- Jan. 31 2004  - Initial version      - EL
-- <date $Date: 2004/04/07 22:48:19 $>	-		<text>		- <initials $Author: erniel $>
-- $Log: write_data_1_wire.vhd,v $
-- Revision 1.2  2004/04/07 22:48:19  erniel
-- removed potential combinational loop in bit counter
--
--
-----------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library components;
use components.component_pack.all;

entity write_data_1_wire is
generic(DATA_LENGTH : integer := 8);

port(clk           : in std_logic;
     rst           : in std_logic;
     write_start_i : in std_logic;
     write_done_o  : out std_logic;
     write_data_i  : in std_logic_vector(DATA_LENGTH-1 downto 0);
     data_bi       : inout std_logic);
end write_data_1_wire;

architecture behav of write_data_1_wire is

-- state encoding:
constant IDLE       : std_logic_vector(2 downto 0) := "000";
constant SETUP_SLOT : std_logic_vector(2 downto 0) := "001";
constant WRITE_1    : std_logic_vector(2 downto 0) := "010";
constant WRITE_0    : std_logic_vector(2 downto 0) := "011";
constant RECOVERY   : std_logic_vector(2 downto 0) := "100";
constant DONE       : std_logic_vector(2 downto 0) := "101";

-- state variables:
signal present_state : std_logic_vector(2 downto 0) := "000";
signal next_state    : std_logic_vector(2 downto 0) := "000";

-- timer controls:
signal slot_timer_reset   : std_logic;
signal slot_timer_count   : integer;

-- tx counter controls:
signal tx_count_incr  : std_logic;
signal tx_count_reset : std_logic;
signal tx_count       : integer;

-- data register controls:
signal data_reg_ena  : std_logic;
signal data_reg_load : std_logic;
signal data_reg_shr  : std_logic;
signal data_reg_lsb  : std_logic;

-- dummy signals for unused signals in shift register
signal clr_dummy        : std_logic;
signal serial_i_dummy   : std_logic;
signal parallel_o_dummy : std_logic_vector(DATA_LENGTH-1 downto 0);

begin

   slot_timer : us_timer
   port map(clk => clk,
            timer_reset_i => slot_timer_reset,
            timer_count_o => slot_timer_count);
   
   
   data_store : shift_reg
   generic map(WIDTH => DATA_LENGTH)
   port map(clk => clk,
            rst => rst,
            ena => data_reg_ena,
            load => data_reg_load,
            shr => data_reg_shr,
            serial_o => data_reg_lsb,
            parallel_i => write_data_i,
            
            -- unused signals (connected to dummy signals):
            clr => clr_dummy,
            serial_i => serial_i_dummy,
            parallel_o => parallel_o_dummy);
            
   data_reg_shr <= '1';
   
   
   state_FF : process(clk, rst)
   begin
      if(rst = '1') then
         present_state <= IDLE;
      elsif(clk'event and clk = '1') then
         present_state <= next_state;
      end if;
   end process state_FF;
   
   
   next_state_logic : process(present_state, write_start_i, slot_timer_count, data_reg_lsb, tx_count)
   begin
      case present_state is      
         when IDLE =>
            if(write_start_i = '1') then
               next_state <= SETUP_SLOT;
            else
               next_state <= IDLE;
            end if;
            
         when SETUP_SLOT =>
            if(data_reg_lsb = '1') then
               next_state <= WRITE_1;
            else
               next_state <= WRITE_0;
            end if;
            
         when WRITE_1 =>
            if(slot_timer_count = WRITE_1_DELAY_US) then
               next_state <= RECOVERY;
            end if;
            
         when WRITE_0 =>
            if(slot_timer_count = WRITE_0_DELAY_US) then
               next_state <= RECOVERY;
            end if;
         
         when RECOVERY =>
            if(slot_timer_count = SLOT_DURATION_US) then
               if(tx_count = DATA_LENGTH) then
                  next_state <= DONE;
               else
                  next_state <= SETUP_SLOT;
               end if;
            end if;
            
         when DONE =>
            next_state <= IDLE;
            
         when others =>
            next_state <= IDLE;
               
      end case;
   end process next_state_logic;
   
   
   output_logic : process(present_state)
   begin
      case present_state is
         when IDLE =>
            data_reg_load    <= '1';
            data_reg_ena     <= '1';
            tx_count_incr    <= '0';
            tx_count_reset   <= '1';
            slot_timer_reset <= '0';
            data_bi          <= 'Z';
            write_done_o     <= '0';
            
         when SETUP_SLOT =>
            data_reg_load    <= '0';
            data_reg_ena     <= '1';
            tx_count_incr    <= '1';
            tx_count_reset   <= '0';
            slot_timer_reset <= '1';
            data_bi          <= 'Z';
            write_done_o     <= '0';
         
         when WRITE_1 | WRITE_0 =>
            data_reg_load    <= '0';
            data_reg_ena     <= '0';
            tx_count_incr    <= '0';
            tx_count_reset   <= '0';
            slot_timer_reset <= '0';
            data_bi          <= '0';
            write_done_o     <= '0';
            
         when RECOVERY =>
            data_reg_load    <= '0';
            data_reg_ena     <= '0';
            tx_count_incr    <= '0';
            tx_count_reset   <= '0';
            slot_timer_reset <= '0';
            data_bi          <= 'Z';
            write_done_o     <= '0';
            
         when DONE => 
            data_reg_load    <= '0';
            data_reg_ena     <= '0';
            tx_count_incr    <= '0';
            tx_count_reset   <= '0';
            slot_timer_reset <= '0';
            data_bi          <= 'Z';
            write_done_o     <= '1';
         
         when others =>
            data_reg_load    <= '0';
            data_reg_ena     <= '0';
            tx_count_incr    <= '0';
            tx_count_reset   <= '0';
            slot_timer_reset <= '0';
            data_bi          <= 'Z';
            write_done_o     <= '0';
   
         end case;
   end process output_logic;
   
   
   bit_counter : process(clk, tx_count_reset)
   begin
      if(tx_count_reset = '1') then
         tx_count <= 0;
      elsif(clk'event and clk = '1') then
         if(tx_count_incr = '1') then
            tx_count <= tx_count + 1;
         end if;
      end if;
   end process bit_counter;
   
end behav;