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
-- <revision control keyword substitutions e.g. $Id: card_id_wait_for_temp.vhd,v 1.1 2004/03/05 22:38:35 jjacob Exp $>
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
-- <date $Date: 2004/03/05 22:38:35 $>	-		<text>		- <initials $Author: jjacob $>
--
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library work;
use work.card_id_pack.all;
use work.component_lib_pack.all;

entity card_id_wait_for_temp is
   
   port (
  
      -- inputs   
      clk                   : in std_logic;
      rst                   : in std_logic;    
      init_fsm_ctrl_i       : in std_logic; -- indicates to start up this state machine.
    
      -- outputs
      fsm_done_ctrl_o       : out std_logic; -- indicates this state machine is done
      
      -- bi-directional
      data_bi               : inout std_logic
           
   );
end card_id_wait_for_temp;

architecture rtl of card_id_wait_for_temp is

-- internal signals
signal current_state        : std_logic_vector(2 downto 0);
signal next_state           : std_logic_vector(2 downto 0);
signal timer_rst            : std_logic;

signal tri_state_en         : std_logic;
signal data_to_tri_state    : std_logic;
signal data                 : std_logic;

signal time                 : integer range 0 to 100;

begin
 
 
------------------------------------------------------------------------
--
-- Instantiate the counter
--
------------------------------------------------------------------------ 
 
   timer : us_counter
      port map(clk     => clk,
           a_rst   => timer_rst,
           count_o => time);
 

------------------------------------------------------------------------
--
-- Instantiate the tri-state buffer
--
------------------------------------------------------------------------

   buf0 : tri_state_buffer
      port map(data_i  => data_to_tri_state,
               buf_en  => tri_state_en,
               data_o  => data_bi);
 

------------------------------------------------------------------------
--
-- This state machine reads the 64-bit data from the 
-- DS18S20 ID chip
--
------------------------------------------------------------------------

-- next state logic

 process (current_state, time, init_fsm_ctrl_i, data)
   begin
   
      case current_state is
      
      when IDLE =>
         if init_fsm_ctrl_i = '1' then
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
            if data = 'H' then
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
      
            data                <= '0';

            tri_state_en        <= '0';
            data_to_tri_state   <= '0';
            timer_rst           <= '1';
            fsm_done_ctrl_o     <= '0';
 
      when PULL_DOWN =>
      
            tri_state_en        <= '0';
            data_to_tri_state   <= '0';
            timer_rst           <= '1';
            fsm_done_ctrl_o     <= '0';      
                  
      when WAIT_5_MICRO_SEC_A =>

            tri_state_en        <= '1';
            data_to_tri_state   <= '0';
            timer_rst           <= '0';
            fsm_done_ctrl_o     <= '0';
           
      when RELEASE_BUS =>
      
            tri_state_en        <= '0';
            data_to_tri_state   <= '0';
            timer_rst           <= '1';
            fsm_done_ctrl_o     <= '0';
        
      when WAIT_5_MICRO_SEC_B =>

            tri_state_en        <= '0';
            data_to_tri_state   <= '0';
            timer_rst           <= '0';
            fsm_done_ctrl_o     <= '0';
                              
       when MASTER_SAMPLE =>
            tri_state_en        <= '0';
            data_to_tri_state   <= '0';
            timer_rst           <= '1';
            fsm_done_ctrl_o     <= '0';
            
            data                <= data_bi;  -- sample the data
                        
       when WAIT_60_MICRO_SEC =>

            tri_state_en        <= '0';
            data_to_tri_state   <= '0';
            timer_rst           <= '0';
            fsm_done_ctrl_o     <= '0';
        
       when DONE =>
            tri_state_en        <= '0';
            data_to_tri_state   <= '0';
            timer_rst           <= '1';
            fsm_done_ctrl_o     <= '1';       
         
       when others =>
       
            tri_state_en        <= '0';
            data_to_tri_state   <= '0';
            timer_rst           <= '1';
            fsm_done_ctrl_o     <= '0';
          
       end case;         
            
   end process;   



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