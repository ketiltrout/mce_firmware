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
-- Project:		<project name>
-- Author:		Jonathan Jacob
-- Organisation:	<organisation name>
--
-- Description:
-- This state machine grabs the 64-bit data from the DS18S20 ID chip and
-- outputs it to data_o.  The first byte is the family code, the next 6
-- bytes are the serial number and the last byte is the CRC
--
-- Revision history:
-- <date $Date$>	-		<text>		- <initials $Author$>
--
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library work;
use work.card_id_pack.all;
use work.component_lib_pack.all;

entity card_id_read_serial_num is
   
   port (
  
      -- inputs   
      clk                   : in std_logic;
      rst                   : in std_logic;    
      read_serial_start_i   : in std_logic; -- indicates to start up this state machine.
    
      -- outputs
      read_serial_done_o    : out std_logic; -- indicates this state machine is done
      serial_num_o          : out std_logic_vector(63 downto 0); -- the 64-bit serial number data
      
      -- bi-directional
      data_bi               : inout std_logic
           
   );
end card_id_read_serial_num;

architecture rtl of card_id_read_serial_num is

-- internal signals
signal current_state        : std_logic_vector(2 downto 0);
signal next_state           : std_logic_vector(2 downto 0);
signal timer_rst            : std_logic;

signal tri_state_en         : std_logic;
signal data_to_tri_state    : std_logic;
signal data                 : std_logic_vector(63 downto 0);

signal bit_counter          : integer range 0 to 64; -- to keep track of where we are
signal time                 : integer range 0 to 100;

begin
 
 
------------------------------------------------------------------------
--
-- Instantiate the counter
--
------------------------------------------------------------------------ 

   timer : us_timer
   port map(clk => clk,
            timer_reset_i => timer_rst,
            timer_count_o => time);
 

------------------------------------------------------------------------
--
-- Instantiate the tri-state buffer
--
------------------------------------------------------------------------

   buf0 : tri_state_buf
      --generic map(WIDTH  => 1)
      port map(data_i  => data_to_tri_state,
               buf_en_i  => tri_state_en,
               data_o  => data_bi);
 

------------------------------------------------------------------------
--
-- This state machine reads the 64-bit data from the 
-- DS18S20 ID chip
--
------------------------------------------------------------------------

-- next state logic

 process (current_state, time, read_serial_start_i)
   begin
   
      case current_state is
      
      when IDLE =>
         if read_serial_start_i = '1' then
            next_state <= PULL_DOWN;
         else
            next_state <= IDLE;
         end if;
            
      when PULL_DOWN =>
         next_state <= WAIT_5_MICRO_SEC_A;
            
      when WAIT_5_MICRO_SEC_A =>
         if time < 5 then      
            next_state <= WAIT_5_MICRO_SEC_A;
         else
            next_state <= RELEASE_BUS;                        
         end if;
            
      when RELEASE_BUS =>
            next_state <= WAIT_5_MICRO_SEC_B;               

      when WAIT_5_MICRO_SEC_B =>
         if time < 5 then      
            next_state <= WAIT_5_MICRO_SEC_B;
         else
            next_state <= MASTER_SAMPLE;                        
         end if;
         
      when MASTER_SAMPLE =>
         next_state <= WAIT_60_MICRO_SEC;
            
      when WAIT_60_MICRO_SEC =>
         if time < 60 then      
            next_state <= WAIT_60_MICRO_SEC;
         else
            if bit_counter = 64 then
               next_state <= DONE;
            else
               next_state <= PULL_DOWN;  
            end if;                   
         end if;  
         
      when DONE =>
         next_state <= DONE; 
         
      when others =>
         next_state <= IDLE;      
            
      end case;         
            
   end process;   


-- output assignments of current state

   process (current_state)
   begin
   
      case current_state is
      
      when IDLE =>
      
            data                <= (others => '0');
            bit_counter         <= 0;
          
            tri_state_en        <= '0';
            data_to_tri_state   <= '0';
            timer_rst           <= '1';
            read_serial_done_o     <= '0';
 
      when PULL_DOWN =>
      
            tri_state_en        <= '0';
            data_to_tri_state   <= '0';
            timer_rst           <= '1';
            read_serial_done_o     <= '0';      
                  
      when WAIT_5_MICRO_SEC_A =>

            tri_state_en        <= '1';
            data_to_tri_state   <= '0';
            timer_rst           <= '0';
            read_serial_done_o     <= '0';
           
      when RELEASE_BUS =>
      
            tri_state_en        <= '0';
            data_to_tri_state   <= '0';
            timer_rst           <= '1';
            read_serial_done_o     <= '0';
        
      when WAIT_5_MICRO_SEC_B =>

            tri_state_en        <= '0';
            data_to_tri_state   <= '0';
            timer_rst           <= '0';
            read_serial_done_o     <= '0';
                              
       when MASTER_SAMPLE =>
            tri_state_en        <= '0';
            data_to_tri_state   <= '0';
            timer_rst           <= '1';
            read_serial_done_o     <= '0';
            
            data                <= data_bi & data(62 downto 0);  -- shift in the data (LSB first)
            bit_counter         <= bit_counter + 1; -- we need to collect 64 bits
                        
       when WAIT_60_MICRO_SEC =>

            tri_state_en        <= '0';
            data_to_tri_state   <= '0';
            timer_rst           <= '0';
            read_serial_done_o     <= '0';
        
       when DONE =>
            tri_state_en        <= '0';
            data_to_tri_state   <= '0';
            timer_rst           <= '1';
            read_serial_done_o     <= '1';       
         
       when others =>
       
            tri_state_en        <= '0';
            data_to_tri_state   <= '0';
            timer_rst           <= '1';
            read_serial_done_o     <= '0';
          
       end case;         
            
   end process;   

   -- pass the collected 64-bit data to the output
   serial_num_o <= data;


------------------------------------------------------------------------
--
-- state sequencer
--
------------------------------------------------------------------------

   process (clk, rst)
   begin
      if rst = '1' then
         current_state <= IDLE;
      elsif (clk'event and clk = '1') then
         current_state <= next_state;
      end if;
   end process;
   
end rtl;