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
-- <revision control keyword substitutions e.g. $Id: card_id_cmd_read_rom.vhd,v 1.1 2004/03/05 22:38:35 jjacob Exp $>
--
-- Project:		<project name>
-- Author:		Jonathan Jacob
-- Organisation:	<organisation name>
--
-- Description:
-- This state machine writes 0x33 (hex) or the bit pattern 00110011 to the
-- DS18S20 ID chip.  This is the command that causes the ID chip to output
-- its 64-bit family code/ serial number/ CRC data.
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

entity card_id_cmd_read_rom is

   port (
     
      -- inputs
      clk                : in std_logic;
      rst                : in std_logic;
      write_cmd_start_i  : in std_logic; -- indicates to start up this state machine.
 
      -- output   
      write_cmd_done_o   : out std_logic;
      
      -- bi-directional
      data_bi            : inout std_logic  

   );
   
end card_id_cmd_read_rom;

architecture rtl of card_id_cmd_read_rom is

-- internal signals
signal current_state        : std_logic_vector(2 downto 0);
signal next_state           : std_logic_vector(2 downto 0);
signal timer_rst            : std_logic;

signal tri_state_en         : std_logic;
signal data_to_tri_state    : std_logic;

signal flow_count           : integer range 0 to 16; -- to keep track of where we are
signal time                 : integer range 0 to 100;

begin
 
 
------------------------------------------------------------------------
--
-- Instantiate the counter
--
------------------------------------------------------------------------ 
 
 --counter instantiation
   timer : us_counter
      port map(clk     => clk,
           a_rst   => timer_rst,
           count_o => time);
 

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
-- This state machine implements the "write" command: 0x33 or b00110011
-- to the DS18S20 ID chip
--
------------------------------------------------------------------------
   
   process (current_state, time, write_cmd_start_i)
   begin
   
      case current_state is
      when IDLE =>
         if write_cmd_start_i = '1' then
            data_to_tri_state <= '0';
            tri_state_en  <= '0';
            timer_rst <= '1';
            flow_count <= 0;
            write_cmd_done_o <= '0';
            next_state <= WRITE0;
         else
            data_to_tri_state <= '0';
            tri_state_en  <= '0';
            timer_rst <= '1';
            flow_count <= 0;
            write_cmd_done_o <= '0';
            next_state <= IDLE;
         end if;        
         
      when WRITE0 =>
      
         data_to_tri_state <= '0';
         tri_state_en  <= '1';
         timer_rst <= '1';
         write_cmd_done_o <= '0';
            
         next_state <= WAIT_90_MICRO_SEC;
         
      when WAIT_90_MICRO_SEC =>
       
         data_to_tri_state <= '0';
         write_cmd_done_o <= '0';
 
         if time < 90 then
            next_state <= WAIT_90_MICRO_SEC;
            timer_rst <= '0';

         else
         
            flow_count <= flow_count + 1;
            timer_rst <= '1';
         
            case flow_count is
               when 0 | 2 | 8 | 10 =>
                  next_state <= RELEASE_BUS;
               when 5 | 13 => 
                  next_state <= WRITE1;
               when 7 => 
                  next_state <= WRITE0;
               when 15 =>
                  next_state <= DONE;
               when others =>
                  next_state <= IDLE;
             end case;
          end if;

          case flow_count is 
             when 0 | 2 | 8 | 10 => 
                tri_state_en<= '1';
             when 5 | 7 | 13 | 15  => 
                tri_state_en<= '0';
             when others =>
                tri_state_en<= '0';
          end case;

       when RELEASE_BUS =>
       
          data_to_tri_state <= '0';
          tri_state_en  <= '0';
          timer_rst <= '1';
          write_cmd_done_o <= '0';
          
          case flow_count is
          
             when 1 | 3 | 9 | 11 => next_state <= WAIT_5_MICRO_SEC;
             when 5 | 7 | 13 | 15 => next_state <= WAIT_90_MICRO_SEC;
             when others => next_state <= IDLE;
             
          end case;
      
       when WAIT_5_MICRO_SEC => 
       
          data_to_tri_state <= '0';
          write_cmd_done_o <= '0';

         if time < 5 then
            next_state <= WAIT_5_MICRO_SEC;
            timer_rst <= '0';

         else
         
            flow_count <= flow_count + 1;
            timer_rst <= '1';
         
            case flow_count is
          
               when 1 | 9 => 
                  next_state <= WRITE0;
               when 3 | 11 => 
                  next_state <= WRITE1;
               when 4 | 6 | 12 | 14 => 
                  next_state <= RELEASE_BUS;
               when others =>
                  next_state <= IDLE;            
          end case;
        end if;

         case flow_count is        
             when 1 | 3 | 9 | 11 => 
                tri_state_en  <= '0';
             when 4 | 6 | 12 | 14 => 
                tri_state_en  <= '1';     
             when others =>
                tri_state_en<= '0';      
          end case;    
      
       when WRITE1 =>
       
         data_to_tri_state <= '0';
         tri_state_en  <= '1';
         timer_rst <= '1';
         write_cmd_done_o <= '0';
            
         next_state <= WAIT_5_MICRO_SEC;
         
      when DONE =>
      
         data_to_tri_state <= '0';
         tri_state_en  <= '0';
         timer_rst <= '1';
         next_state <= DONE;
         write_cmd_done_o <= '1';
      
      when others =>
      
         data_to_tri_state <= '0';
         tri_state_en  <= '0';
         timer_rst <= '1';
         write_cmd_done_o <= '0';      
         next_state <= IDLE;
         
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