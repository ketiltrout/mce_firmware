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
-- <revision control keyword substitutions e.g. $Id: cmd_translator_internal_cmd_fsm.vhd,v 1.9 2004/09/30 22:34:44 erniel Exp $>
--
-- Project:	      SCUBA-2
-- Author:	       Jonathan Jacob
--
-- Organisation:  UBC
--
-- Description:  
-- 
-- 
--
-- Revision history:
-- 
-- <date $Date: 2004/09/30 22:34:44 $>	-		<text>		- <initials $Author: erniel $>
--
-- $Log: cmd_translator_internal_cmd_fsm.vhd,v $
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

      rst_i             : in     std_logic;
      clk_i             : in     std_logic;

      -- inputs from cmd_translator top level
      
      internal_cmd_start_i : in std_logic;
      --internal_cmd_stop_i  : in std_logic;   
  
      -- outputs to the macro-instruction arbiter
      card_addr_o       : out std_logic_vector (FIBRE_CARD_ADDRESS_WIDTH-1 downto 0);  -- specifies which card the command is targetting
      parameter_id_o    : out std_logic_vector (FIBRE_PARAMETER_ID_WIDTH-1 downto 0);  -- comes from reg_addr_i, indicates which device(s) the command is targetting
      data_size_o       : out std_logic_vector (FIBRE_DATA_SIZE_WIDTH-1 downto 0);     -- data_size_i, indicates number of 16-bit words of data
      data_o            : out std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);         -- data will be passed straight thru in 16-bit words
      data_clk_o        : out std_logic;							                               -- for clocking out the data
      macro_instr_rdy_o : out std_logic;                                               -- ='1' when the data is valid, else it's '0'
      cmd_type_o        : out std_logic_vector (BB_COMMAND_TYPE_WIDTH-1 downto 0);     -- this is a re-mapping of the cmd_code into a 3-bit number
      
      -- input from the macro-instruction arbiter
      ack_i             : in std_logic                   -- acknowledgment from the macro-instr arbiter that it is ready and has grabbed the data
      							 -- not currently used

   ); 
     
end cmd_translator_internal_cmd_fsm;

architecture rtl of cmd_translator_internal_cmd_fsm is

type state is (IDLE, ISSUE_INTRNL_CMD);
signal current_state, next_state : state;


begin

------------------------------------------------------------------------
--
-- 
--
------------------------------------------------------------------------

   process(clk_i, rst_i)
   begin
      if rst_i = '1' then
         current_state <= IDLE;
      elsif clk_i'event and clk_i = '1' then
         current_state <= next_state;
      end if;
   end process;
   
   process(internal_cmd_start_i, ack_i, current_state)
   begin
      case current_state is
         when IDLE =>
            if internal_cmd_start_i = '1' then
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
   
   card_addr_o       <= x"00" & ADDRESS_CARD    when current_state = ISSUE_INTRNL_CMD else (others => '0');
   parameter_id_o    <= x"00" & ROW_ORDER_ADDR  when current_state = ISSUE_INTRNL_CMD else (others => '0');
   macro_instr_rdy_o <= '1'                     when current_state = ISSUE_INTRNL_CMD else '0';
   cmd_type_o        <= READ_BLOCK              when current_state = ISSUE_INTRNL_CMD else (others => '0');
   
   data_size_o       <= (others => '0');
   data_o            <= (others => '0');
   data_clk_o        <= '0';

      
end rtl;