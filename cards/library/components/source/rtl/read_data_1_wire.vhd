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

-- read_data_1_wire.vhd
--
-- <revision control keyword substitutions e.g. $Id: read_data_1_wire.vhd,v 1.1 2004/03/05 22:38:35 jjacob Exp $>
--
-- Project:	      SCUBA-2
-- Author:	       Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Implements the master receive protocol for 1-wire signalling
--
-- Revision history:
-- Feb. 2 2004  - Initial version      - EL
-- <date $Date: 2004/03/05 22:38:35 $>	-		<text>		- <initials $Author: jjacob $>
-- $Log$
--
-----------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library components;
use components.component_pack.all;

entity read_data_1_wire is
generic(DATA_LENGTH : integer := 8);

port(clk           : in std_logic;
     rst           : in std_logic;
     read_start_i  : in std_logic;
     read_done_o   : out std_logic;
     read_data_o   : out std_logic_vector(DATA_LENGTH-1 downto 0);
     data_bi       : inout std_logic);
end read_data_1_wire;

architecture behav of read_data_1_wire is

-- state encoding:
constant IDLE       : std_logic_vector(2 downto 0) := "000";
constant SETUP_SLOT : std_logic_vector(2 downto 0) := "001";
constant INITIATE   : std_logic_vector(2 downto 0) := "010";
constant WAIT_VALID : std_logic_vector(2 downto 0) := "011";
constant SAMPLE     : std_logic_vector(2 downto 0) := "100";
constant RECOVERY   : std_logic_vector(2 downto 0) := "101";
constant DONE       : std_logic_vector(2 downto 0) := "110";

-- state variables:
signal present_state : std_logic_vector(2 downto 0) := "000";
signal next_state    : std_logic_vector(2 downto 0) := "000";

-- timer controls:
signal slot_timer_reset   : std_logic;
signal slot_timer_count   : integer;

-- rx counter controls:
signal rx_count_incr  : std_logic;
signal rx_count_reset : std_logic;
signal rx_count       : integer;

-- data register controls:
signal data_reg_ena : std_logic;
signal data_reg_clr : std_logic;
signal data_reg_shr : std_logic;

-- dummy signals for unused signals in shift register
signal load_dummy       : std_logic;
signal serial_o_dummy   : std_logic;
signal parallel_i_dummy : std_logic_vector(DATA_LENGTH-1 downto 0);

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
            clr => data_reg_clr,
            shr => data_reg_shr,
            serial_i => data_bi,
            parallel_o => read_data_o,
            
            -- unused signals (connected to dummy signals):
            load => load_dummy,
            serial_o => serial_o_dummy,
            parallel_i => parallel_i_dummy);
            
   data_reg_shr <= '1';
   
   
   state_FF : process(clk, rst)
   begin
      if(rst = '1') then
         present_state <= IDLE;
      elsif(clk'event and clk = '1') then
         present_state <= next_state;
      end if;
   end process state_FF;
   
   
   next_state_logic : process(present_state, read_start_i, slot_timer_count, rx_count)
   begin
      case present_state is      
         when IDLE =>
            if(read_start_i = '1') then
               next_state <= SETUP_SLOT;
            else
               next_state <= IDLE;
            end if;
            
         when SETUP_SLOT =>
            next_state <= INITIATE;
            
         when INITIATE =>
            if(slot_timer_count = READ_INITIATE_DELAY_US) then
               next_state <= WAIT_VALID;
            end if;
            
         when WAIT_VALID =>
            if(slot_timer_count = READ_VALID_DELAY_US) then
               next_state <= SAMPLE;
            end if;

         when SAMPLE =>
            next_state <= RECOVERY;
                     
         when RECOVERY =>
            if(slot_timer_count = SLOT_DURATION_US) then
               if(rx_count = DATA_LENGTH) then
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
   
   
   output_logic : process(present_state, rx_count)
   begin
      case present_state is
         when IDLE =>
            data_reg_ena     <= '0';
            data_reg_clr     <= '0';
            rx_count_incr    <= '0';
            rx_count_reset   <= '1';
            slot_timer_reset <= '0';
            data_bi          <= 'Z';
            read_done_o      <= '0';
            
         when SETUP_SLOT =>
            if(rx_count = 0) then
               data_reg_clr  <= '1';
               data_reg_ena  <= '1';
            else
               data_reg_clr  <= '0';
               data_reg_ena  <= '0';
            end if;
            rx_count_incr    <= '1';
            rx_count_reset   <= '0';
            slot_timer_reset <= '1';
            data_bi          <= 'Z';
            read_done_o      <= '0';
         
         when INITIATE =>
            data_reg_clr     <= '0';
            data_reg_ena     <= '0';
            rx_count_incr    <= '0';
            rx_count_reset   <= '0';
            slot_timer_reset <= '0';
            data_bi          <= '0';
            read_done_o      <= '0';
            
         when WAIT_VALID | RECOVERY =>
            data_reg_clr     <= '0';
            data_reg_ena     <= '0';
            rx_count_incr    <= '0';
            rx_count_reset   <= '0';
            slot_timer_reset <= '0';
            data_bi          <= 'Z';
            read_done_o      <= '0';
            
         when SAMPLE =>
            data_reg_clr     <= '0';
            data_reg_ena     <= '1';
            rx_count_incr    <= '0';
            rx_count_reset   <= '0';
            slot_timer_reset <= '0';
            data_bi          <= 'Z';
            read_done_o      <= '0';
            
         when DONE => 
            data_reg_clr     <= '0';
            data_reg_ena     <= '0';
            rx_count_incr    <= '0';
            rx_count_reset   <= '0';
            slot_timer_reset <= '0';
            data_bi          <= 'Z';
            read_done_o      <= '1';
         
         when others =>
            data_reg_clr     <= '0';
            data_reg_ena     <= '0';
            rx_count_incr    <= '0';
            rx_count_reset   <= '0';
            slot_timer_reset <= '0';
            data_bi          <= 'Z';
            read_done_o      <= '0';
   
         end case;
   end process output_logic;
   
   
   bit_counter : process(clk, rx_count_reset)
   begin
      if(rx_count_reset = '1') then
         rx_count <= 0;
      elsif(clk'event and clk= '1') then
         if(rx_count_incr = '1') then
            rx_count <= rx_count + 1;
         end if;
      end if;
   end process bit_counter;
   
end behav;
