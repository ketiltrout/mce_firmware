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

-- 
--
-- <revision control keyword substitutions e.g. $Id: cmd_translator_internal_cmd_fsm.vhd,v 1.5 2006/01/16 18:45:27 bburger Exp $>
--
-- Project:       SCUBA-2
-- Author:         Jonathan Jacob
--
-- Organisation:  UBC
--
-- Description:  
-- 
-- 
--
-- Revision history:
-- 
-- <date $Date: 2006/01/16 18:45:27 $> -     <text>      - <initials $Author: bburger $>
--
-- $Log: cmd_translator_internal_cmd_fsm.vhd,v $
-- Revision 1.5  2006/01/16 18:45:27  bburger
-- Ernie:  removed references to issue_reply_pack and cmd_translator_pack
-- moved component declarations from above package files to cmd_translator
-- renamed constants to work with new command_pack (new bus backplane constants)
--
-- Revision 1.4  2005/11/15 03:17:22  bburger
-- Bryce: Added support to reply_queue_sequencer, reply_queue and reply_translator for timeouts and CRC errors from the bus backplane
--
-- Revision 1.3  2005/09/03 23:51:26  bburger
-- jjacob:
-- removed recirculation muxes and replaced with register enables, and cleaned up formatting
--
-- Revision 1.2  2004/12/16 22:05:40  bburger
-- Bryce:  changes associated with lvds_tx and cmd_translator interface changes
--
-- Revision 1.1  2004/12/02 05:42:51  jjacob
-- new file for issuing internal commands
--
-- 
-----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library components;
use components.component_pack.all;

library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;

entity cmd_translator_internal_cmd_fsm is

port(
     -- global inputs
      rst_i                : in  std_logic;
      clk_i                : in  std_logic;

--      -- inputs from cmd_translator top level
--      internal_cmd_start_i : in  std_logic;
--      internal_cmd_en      : in std_logic;
--      tes_sq_wave_en       : in std_logic;
  
      -- outputs to the macro-instruction arbiter
      card_addr_o          : out std_logic_vector (BB_CARD_ADDRESS_WIDTH-1 downto 0);  -- specifies which card the command is targetting
      parameter_id_o       : out std_logic_vector (BB_PARAMETER_ID_WIDTH-1 downto 0);  -- comes from reg_addr_i, indicates which device(s) the command is targetting
      data_size_o          : out std_logic_vector (   BB_DATA_SIZE_WIDTH-1 downto 0);  -- data_size_i, indicates number of 16-bit words of data
      data_o               : out std_logic_vector (    PACKET_WORD_WIDTH-1 downto 0);  -- data will be passed straight thru in 16-bit words
      data_clk_o           : out std_logic;                                               -- for clocking out the data
      instr_rdy_o          : out std_logic;                                               -- ='1' when the data is valid, else it's '0'
      cmd_type_o           : out std_logic_vector (BB_COMMAND_TYPE_WIDTH-1 downto 0);  -- this is a re-mapping of the cmd_code into a 3-bit number
      
      -- input from the macro-instruction arbiter
      ack_i                : in  std_logic                                                -- acknowledgment from the arbiter that it is ready and has grabbed the data
   ); 
     
end cmd_translator_internal_cmd_fsm;

architecture rtl of cmd_translator_internal_cmd_fsm is

   -------------------------------------------------------------------------------------------
   -- type definitions
   ------------------------------------------------------------------------------------------- 
   type state is (IDLE, ISSUE_INTRNL_CMD);
   
   -------------------------------------------------------------------------------------------
   -- signals
   -------------------------------------------------------------------------------------------    
   signal current_state  : state;
   signal next_state     : state;

   signal internal_cmd_start           : std_logic; 
   signal timer_rst                    : std_logic;
   signal time                         : integer;

begin

   -------------------------------------------------------------------------------------------
   -- timer reset logic for issuing internal commands
   -------------------------------------------------------------------------------------------
   process(rst_i, clk_i)
   begin
      if rst_i = '1' then
         timer_rst               <= '1';
         internal_cmd_start      <= '0';  
      elsif clk_i'event and clk_i = '1' then 
   ---------------------------------------------------------------------  
   -- in order to disable internal commands, start commenting from here
   ---------------------------------------------------------------------
--      if time >= 400 then --1000000 then  -- 1x10^6 us = 1s
--         timer_rst            <= '1';
--         internal_cmd_start   <= '1';      
--      else
         timer_rst            <= '0';
         internal_cmd_start   <= '0';      
--      end if;
   ---------------------------------------------------------------------  
   -- end of comments for disabling internal commands.
   ---------------------------------------------------------------------  
      end if;
   end process;
 
   -------------------------------------------------------------------------------------------
   -- timer for issuing internal commands
   ------------------------------------------------------------------------------------------- 
   timer : us_timer
   port map(
      clk           => clk_i,
      timer_reset_i => timer_rst,
      timer_count_o => time);

   -------------------------------------------------------------------------------------------
   -- state sequencer
   -------------------------------------------------------------------------------------------    
   process(clk_i, rst_i)
   begin
      if rst_i = '1' then
         current_state <= IDLE;
      elsif clk_i'event and clk_i = '1' then
         current_state <= next_state;
      end if;
   end process;

   -------------------------------------------------------------------------------------------
   -- assign next state
   -------------------------------------------------------------------------------------------       
   process(internal_cmd_start, ack_i, current_state)
   begin
      case current_state is
         when IDLE =>
            if internal_cmd_start = '1' then
               next_state <= ISSUE_INTRNL_CMD;
            else
               next_state <= IDLE;
            end if;
            
         when ISSUE_INTRNL_CMD =>
            if ack_i = '1' then
               next_state <= IDLE;
            else
               next_state <= ISSUE_INTRNL_CMD;
            end if;
            
         when others =>
            next_state <= IDLE;
          
      end case;           
   end process;

   -------------------------------------------------------------------------------------------
   -- assign outputs
   -------------------------------------------------------------------------------------------
   card_addr_o       <= READOUT_CARD_1  when current_state = ISSUE_INTRNL_CMD else (others => '0');
   parameter_id_o    <= LED_ADDR        when current_state = ISSUE_INTRNL_CMD else (others => '0');
   instr_rdy_o       <= '1'             when current_state = ISSUE_INTRNL_CMD else '0';
   cmd_type_o        <= READ_CMD        when current_state = ISSUE_INTRNL_CMD else (others => '0');
   data_size_o       <= "00000101001"   when current_state = ISSUE_INTRNL_CMD else (others => '0');
   data_o            <= (others => '0');
   data_clk_o        <= '0';

    
end rtl;