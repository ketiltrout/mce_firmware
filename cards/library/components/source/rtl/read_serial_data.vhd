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

-- read_serial_data.vhd
--
-- <revision control keyword substitutions e.g. $Id$>
--
-- Project:	      SCUBA-2
-- Author:	       Ernie Lin, Jonathan Jacob
-- Organisation:  UBC
--
-- Description:
-- Reads data from the EEPROM serially, assembles it into a 32-bit register,
-- sends it out.
--
-- Revision history:
-- 
-- <date $Date$>	-		<text>		- <initials $Author$>

--
-----------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library components;
use components.component_pack.all;

library sys_param;
use sys_param.wishbone_pack.all;

entity read_serial_data is
generic(DATA_LENGTH : integer := WB_DATA_WIDTH);

port(clk           : in std_logic;
     rst           : in std_logic;
     read_start_i  : in std_logic;
     read_done_o   : out std_logic;
     --read_data_i   : in std_logic_vector(DATA_LENGTH-1 downto 0);
     read_data_i        : in std_logic; -- serial data from the eeprom
     read_data_o        : out std_logic_vector(DATA_LENGTH-1 downto 0) -- 32-bit data from the eeprom sent back to the eeprom controller state machine
     ); 
end read_serial_data;

architecture rtl of read_serial_data is

-- state encoding:
constant IDLE       : std_logic_vector(2 downto 0) := "000";
--constant SETUP_SLOT : std_logic_vector(2 downto 0) := "001";
constant READ    : std_logic_vector(2 downto 0) := "010";
--constant WRITE_1    : std_logic_vector(2 downto 0) := "010";
--constant WRITE_0    : std_logic_vector(2 downto 0) := "011";
--constant RECOVERY   : std_logic_vector(2 downto 0) := "100";
constant DONE       : std_logic_vector(2 downto 0) := "101";

-- state variables:
signal current_state : std_logic_vector(2 downto 0) := "000";
signal next_state    : std_logic_vector(2 downto 0) := "000";

-- timer controls:
signal slot_timer_reset   : std_logic;
signal slot_timer_count   : integer;

-- tx counter controls:
signal rx_count_incr  : std_logic;
signal rx_count_reset : std_logic;
signal rx_count       : integer;

-- data register controls:
signal data_reg_ena  : std_logic;
signal data_reg_load : std_logic;
signal data_reg_shr  : std_logic;
signal data_reg_msb  : std_logic;

-- dummy signals for unused signals in shift register
signal clr_dummy        : std_logic;
signal serial_i_dummy   : std_logic;
signal parallel_o_dummy : std_logic_vector(DATA_LENGTH-1 downto 0);


signal read_data : std_logic_vector(DATA_LENGTH-1 downto 0);

begin

--   slot_timer : us_timer
--   port map(clk => clk,
--            timer_reset_i => slot_timer_reset,
--            timer_count_o => slot_timer_count);
   
   
   data_store : shift_reg
   generic map(WIDTH => DATA_LENGTH)
   port map(clk => clk,
            rst => rst,
            ena => data_reg_ena,
            load => data_reg_load,
            shr => data_reg_shr,
            serial_o => data_reg_msb,
            parallel_i => read_data,
            
            -- unused signals (connected to dummy signals):
            clr => clr_dummy,
            serial_i => serial_i_dummy,
            parallel_o => parallel_o_dummy);
            
   data_reg_shr <= '0'; -- shift left, MSB first
   
   
   state_FF : process(clk, rst)
   begin
      if(rst = '1') then
         current_state <= IDLE;
      elsif(clk'event and clk = '1') then
         current_state <= next_state;
      end if;
   end process state_FF;
   
 
 
-----------------------------------------------------------------------------
--
-- Next state logic and output assignments
--
-----------------------------------------------------------------------------   
   process(current_state, read_start_i, slot_timer_count, data_reg_msb, rx_count)
   begin
      case current_state is      
         when IDLE =>
            if(read_start_i = '1') then
               next_state       <= READ;
               data_reg_load    <= '0';
               data_reg_ena     <= '0';
               rx_count_incr    <= '1';
               rx_count_reset   <= '0';
               --data_o           <= '0';
               read_done_o     <= '0';
            else
               next_state       <= IDLE;
               data_reg_load    <= '1';
               data_reg_ena     <= '1';
               rx_count_incr    <= '0';
               rx_count_reset   <= '1';
               --data_o           <= '0';
               read_done_o     <= '0';
            end if;
            
--         when SETUP_SLOT =>
--            if(data_reg_msb = '1') then
--               next_state <= WRITE_1;
--            else
--               next_state <= WRITE_0;
--            end if;
            
         when READ =>
            if(rx_count = DATA_LENGTH) then
               next_state <= DONE;
               data_reg_load    <= '0';
               data_reg_ena     <= '0';
               rx_count_incr    <= '0';
               rx_count_reset   <= '1';
               --slot_timer_reset <= '0';
               --data_o           <= '0';
               read_done_o     <= '1';
               
               read_data  <=  read_data(DATA_LENGTH-2 downto 1) & read_data_i;  --shift in the data
               
            else
               next_state <= READ;
               data_reg_load    <= '0';
               data_reg_ena     <= '0';
               rx_count_incr    <= '1';
               rx_count_reset   <= '0';
               --data_o           <= '0';
               read_done_o     <= '0';
             end if;
                  
                  --next_state <= SETUP_SLOT;

--            if(slot_timer_count = WRITE_1_DELAY_US) then
--               next_state <= RECOVERY;
--            end if;
            
         when DONE =>
            next_state <= IDLE;
            data_reg_load    <= '0';
            data_reg_ena     <= '0';
            rx_count_incr    <= '0';
            rx_count_reset   <= '1';
               --slot_timer_reset <= '0';
            --data_o           <= '0';
            read_done_o     <= '1';  --perhaps make this '0' so read_done_o isn't high for 2 cycles
            
         when others =>
            next_state <= IDLE;
            data_reg_load    <= '0';
            data_reg_ena     <= '0';
            rx_count_incr    <= '0';
            rx_count_reset   <= '0';
            --slot_timer_reset <= '0';
            --data_o           <= '0';
            read_done_o     <= '0';
            
            
               
      end case;
   end process;
   
  
   
   bit_counter : process(rx_count_incr, rx_count_reset)
   begin
      if(rx_count_reset = '1') then
         rx_count <= 0;
      elsif(rx_count_incr = '1') then
         rx_count <= rx_count + 1;
      end if;
   end process bit_counter;
   
end rtl;