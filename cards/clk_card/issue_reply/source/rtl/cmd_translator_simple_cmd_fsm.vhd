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
-- <revision control keyword substitutions e.g. $Id: cmd_translator_simple_cmd_fsm.vhd,v 1.9 2004/09/30 22:34:44 erniel Exp $>
--
-- Project:	      SCUBA-2
-- Author:	       Jonathan Jacob
--
-- Organisation:  UBC
--
-- Description:  This module is the fibre command translator. 
-- 
-- 
--
-- Revision history:
-- 
-- <date $Date: 2004/09/30 22:34:44 $>	-		<text>		- <initials $Author: erniel $>
--
-- $Log: cmd_translator_simple_cmd_fsm.vhd,v $
-- Revision 1.9  2004/09/30 22:34:44  erniel
-- using new command_pack constants
--
-- Revision 1.8  2004/09/09 18:26:14  jjacob
-- added 3 outputs:
-- >       cmd_type_o        :  out std_logic_vector (BB_COMMAND_TYPE_WIDTH-1 downto 0);       -- this is a re-mapping of the cmd_code into a 3-bit number
-- >       cmd_stop_o        :  out std_logic;                                          -- indicates a STOP command was recieved
-- >       last_frame_o      :  out std_logic;                                          -- indicates the last frame of data for a ret_dat command
--
-- Revision 1.7  2004/09/02 23:41:27  jjacob
-- cleaning up and formatting
--
-- Revision 1.6  2004/09/02 18:24:44  jjacob
-- cleaning up and formatting
--
-- Revision 1.5  2004/07/28 23:39:26  jjacob
-- added:
-- library sys_param;
-- use sys_param.command_pack.all;
--
-- Revision 1.4  2004/06/21 17:02:29  jjacob
-- first stable version, doesn't yet have macro-instruction buffer, doesn't have
-- "quick" acknolwedgements for instructions that require them, no error
-- handling, basically no return path logic yet.  Have implemented ret_dat
-- instructions, and "simple" instructions.  Not all instructions are fully
-- implemented yet.
--
-- Revision 1.3  2004/06/09 23:36:10  jjacob
-- cleaned formatting
--
-- Revision 1.2  2004/06/04 23:01:24  jjacob
-- daily update/ safety checkin
--
-- Revision 1.1  2004/05/28 15:53:10  jjacob
-- first version
--
--
-- 
-----------------------------------------------------------------------------

-- maybe absorb this file into the top level, there's not much functionality here anymore


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library components;
use components.component_pack.all;

library sys_param;
use sys_param.command_pack.all;

entity cmd_translator_simple_cmd_fsm is

port(

     -- global inputs

      rst_i             : in     std_logic;
      clk_i             : in     std_logic;

      -- inputs from cmd_translator top level      

      card_addr_i       : in std_logic_vector (FIBRE_CARD_ADDRESS_WIDTH-1 downto 0);  -- specifies which card the command is targetting
      parameter_id_i    : in std_logic_vector (FIBRE_PARAMETER_ID_WIDTH-1 downto 0);     -- comes from reg_addr_i, indicates which device(s) the command is targetting
      data_size_i       : in std_logic_vector (FIBRE_DATA_SIZE_WIDTH-1 downto 0);  -- data_size_i, indicates number of 16-bit words of data
      data_i            : in std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);       -- data will be passed straight thru in 16-bit words
      data_clk_i        : in std_logic;							                         -- for clocking out the data
      cmd_code_i        : in std_logic_vector (15 downto 0);
      
      -- other inputs
      sync_pulse_i      : in std_logic;
      cmd_start_i       : in std_logic;
      cmd_stop_i        : in std_logic;
  
      -- outputs to the macro-instruction arbiter
      card_addr_o       : out std_logic_vector (FIBRE_CARD_ADDRESS_WIDTH-1 downto 0);  -- specifies which card the command is targetting
      parameter_id_o    : out std_logic_vector (FIBRE_PARAMETER_ID_WIDTH-1 downto 0);     -- comes from reg_addr_i, indicates which device(s) the command is targetting
      data_size_o       : out std_logic_vector (FIBRE_DATA_SIZE_WIDTH-1 downto 0);  -- data_size_i, indicates number of 16-bit words of data
      data_o            : out std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);       -- data will be passed straight thru in 16-bit words
      data_clk_o        : out std_logic;							                          -- for clocking out the data
      macro_instr_rdy_o : out std_logic;                                          -- ='1' when the data is valid, else it's '0'
      cmd_type_o        : out std_logic_vector (BB_COMMAND_TYPE_WIDTH-1 downto 0);       -- this is a re-mapping of the cmd_code into a 3-bit number
      
      -- input from the macro-instruction arbiter
      ack_i             : in std_logic                   -- acknowledgment from the macro-instr arbiter that it is ready and has grabbed the data
      							 -- not currently used

   ); 
     
end cmd_translator_simple_cmd_fsm;

architecture rtl of cmd_translator_simple_cmd_fsm is

begin

------------------------------------------------------------------------
--
-- 
--
------------------------------------------------------------------------

   card_addr_o        <= card_addr_i    when cmd_start_i = '1' else (others => '0');
   parameter_id_o     <= parameter_id_i when cmd_start_i = '1' else (others => '0');
   data_size_o        <= data_size_i    when cmd_start_i = '1' else (others => '0');
   data_o             <= data_i         when cmd_start_i = '1' else (others => '0');
   data_clk_o         <= data_clk_i     when cmd_start_i = '1' else '0';
   macro_instr_rdy_o  <= '1'            when cmd_start_i = '1' else '0';

   -- re-mapping logic for cmd_code_i -> cmd_type_o
   with cmd_code_i select
      cmd_type_o <=
      WRITE_BLOCK   when x"5742",
      READ_BLOCK    when x"5242",
      START         when x"474F",
      STOP          when x"5354",
      RESET         when x"5253",
      (others=>'1') when others;  -- undefined cmd_type
   
   
   
--   process(cmd_start_i, data_size_i, card_addr_i, parameter_id_i,
--           data_i, data_clk_i)
--   begin
--      case cmd_start_i is
--         when '1' =>
--            card_addr_o        <= card_addr_i;
--            parameter_id_o     <= parameter_id_i;
--            data_size_o        <= data_size_i;
--            data_o             <= data_i;
--            data_clk_o         <= data_clk_i;
--            macro_instr_rdy_o  <= '1';
--            
--         when '0' =>
--         
--            card_addr_o        <= (others => '0');
--            parameter_id_o     <= (others => '0');
--            data_size_o        <= (others => '0');
--            data_o             <= (others => '0');
--            data_clk_o         <= '0';
--            macro_instr_rdy_o  <= '0';
--            
--         when others =>
--         
--            card_addr_o        <= (others => '0');
--            parameter_id_o     <= (others => '0');
--            data_size_o        <= (others => '0');
--            data_o             <= (others => '0');
--            data_clk_o         <= '0';
--            macro_instr_rdy_o  <= '0';
--         
--      end case;
--      
--   end process;
      
end rtl;