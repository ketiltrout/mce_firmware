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
-- <revision control keyword substitutions e.g. $Id: cmd_translator_arbiter.vhd,v 1.1 2004/06/03 23:40:34 jjacob Exp $>
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
-- <date $Date: 2004/06/03 23:40:34 $>	-		<text>		- <initials $Author: jjacob $>
--
-- $Log: cmd_translator_arbiter.vhd,v $
-- Revision 1.1  2004/06/03 23:40:34  jjacob
-- first version
--
-- Revision 1.1  2004/05/28 15:52:27  jjacob
-- first version
--
--
-- 
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library components;
use components.component_pack.all;

library work;
use work.issue_reply_pack.all;

library sys_param;
use sys_param.wishbone_pack.all;
use sys_param.general_pack.all;


entity cmd_translator_arbiter is

--generic(cmd_translator_ADDR               : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := EEPROM_ADDR  );

port(

     -- global inputs

      rst_i        : in     std_logic;
      clk_i        : in     std_logic;
      

      -- inputs from the 'return data' state machine
      ret_dat_frame_seq_num_i       : in std_logic_vector (31 downto 0);
      ret_dat_frame_sync_num_i        : in std_logic_vector (7 downto 0);
      
      ret_dat_card_addr_i       : in std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0);  -- specifies which card the command is targetting
      ret_dat_parameter_id_i    : in std_logic_vector (PAR_ID_BUS_WIDTH-1 downto 0);     -- comes from reg_addr_i, indicates which device(s) the command is targett_ig
      ret_dat_data_size_i       : in std_logic_vector (DATA_SIZE_BUS_WIDTH-1 downto 0);  -- num_data_i, indicates number of 16-bit words of data
      ret_dat_data_i            : in std_logic_vector (DATA_BUS_WIDTH-1 downto 0);       -- data will be passed straight thru in 16-bit words
      ret_dat_data_clk_i        : in std_logic;							                          -- for clocking out the data
      ret_dat_macro_instr_rdy_i : in std_logic;                                          -- ='1' when the data is valid, else it's '0'
      ret_dat_fsm_working_i     : in std_logic;
      
 
      -- output to the 'return data' state machine
      ret_dat_ack_o             : out std_logic;                   -- acknowledgment from the macro-instr arbiter that it is ready and has grabbed the data



      -- inputs from the 'simple commands' state machine
      simple_cmd_card_addr_i       : in std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0);  -- specifies which card the command is targetting
      simple_cmd_parameter_id_i    : in std_logic_vector (PAR_ID_BUS_WIDTH-1 downto 0);     -- comes from reg_addr_i, indicates which device(s) the command is targetting
      simple_cmd_data_size_i       : in std_logic_vector (DATA_SIZE_BUS_WIDTH-1 downto 0);  -- data_size_i, indicates number of 16-bit words of data
      simple_cmd_data_i            : in std_logic_vector (DATA_BUS_WIDTH-1 downto 0);       -- data will be passed straight thru in 16-bit words
      simple_cmd_data_clk_i        : in std_logic;							                                   -- for clocking out the data
      simple_cmd_macro_instr_rdy_i : in std_logic;                                          -- ='1' when the data is valid, else it's '0'
      
 
      -- input from the macro-instruction arbiter
      simple_cmd_ack_o             : out std_logic ;  


      -- outputs to the micro instruction sequence generator
      m_op_seq_num_o        : out std_logic_vector ( 7 downto 0);
      frame_seq_num_o       : out std_logic_vector (31 downto 0);
      frame_sync_num_o        : out std_logic_vector (7 downto 0);
      
      -- outputs to the macro-instruction arbiter
      card_addr_o       : out std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0);  -- specifies which card the command is targetting
      parameter_id_o    : out std_logic_vector (PAR_ID_BUS_WIDTH-1 downto 0);     -- comes from reg_addr_i, indicates which device(s) the command is targetting
      data_size_o       : out std_logic_vector (DATA_SIZE_BUS_WIDTH-1 downto 0);  -- num_data_i, indicates number of 16-bit words of data
      data_o            : out std_logic_vector (DATA_BUS_WIDTH-1 downto 0);       -- data will be passed straight thru in 16-bit words
      data_clk_o        : out std_logic;							                          -- for clocking out the data
      macro_instr_rdy_o : out std_logic;                                          -- ='1' when the data is valid, else it's '0'
      
 
      -- input from the micro-instruction arbiter
      ack_i             : in std_logic                   -- acknowledgment from the micro-instr arbiter that it is ready and has grabbed the data

   ); 
     
end cmd_translator_arbiter;


architecture rtl of cmd_translator_arbiter is


   signal arbiter_condition         : std_logic;
   signal macro_instr_rdy           : std_logic;
   signal m_op_seq_num              : std_logic_vector (7 downto 0);

   
   type a_state is (SIMPLE_CMD, RET_DAT);
                   
   signal async_state : a_state;



begin



------------------------------------------------------------------------
--
-- asynchronous arbiter state machine
--
------------------------------------------------------------------------

   arbiter_condition <= not(simple_cmd_macro_instr_rdy_i) and ret_dat_fsm_working_i;

   process(arbiter_condition, m_op_seq_num, ret_dat_frame_seq_num_i, ret_dat_frame_sync_num_i,
           ret_dat_card_addr_i, ret_dat_parameter_id_i, ret_dat_data_size_i, ret_dat_data_i,
           ret_dat_data_clk_i, ret_dat_macro_instr_rdy_i, simple_cmd_card_addr_i, simple_cmd_parameter_id_i,
           simple_cmd_data_size_i, simple_cmd_data_i, simple_cmd_data_clk_i, simple_cmd_macro_instr_rdy_i)
   begin
      case async_state is
         when SIMPLE_CMD =>
            if arbiter_condition = '1' then
            
               m_op_seq_num_o       <= m_op_seq_num;
               frame_seq_num_o      <= ret_dat_frame_seq_num_i;
               frame_sync_num_o     <= ret_dat_frame_sync_num_i;
      
               card_addr_o          <= ret_dat_card_addr_i; 
               parameter_id_o       <= ret_dat_parameter_id_i; 
               data_size_o          <= ret_dat_data_size_i;
               data_o               <= ret_dat_data_i; 
               data_clk_o           <= ret_dat_data_clk_i;
               macro_instr_rdy      <= ret_dat_macro_instr_rdy_i; 
            
               async_state <= RET_DAT;
               
            else
            
               m_op_seq_num_o       <= m_op_seq_num;
               frame_seq_num_o      <= (others=>'0');
               frame_sync_num_o     <= (others=>'0');
      
               card_addr_o          <= simple_cmd_card_addr_i; 
               parameter_id_o       <= simple_cmd_parameter_id_i; 
               data_size_o          <= simple_cmd_data_size_i;
               data_o               <= simple_cmd_data_i; 
               data_clk_o           <= simple_cmd_data_clk_i;
               macro_instr_rdy      <= simple_cmd_macro_instr_rdy_i; 
            
               async_state <= SIMPLE_CMD;
            end if;
            
         when RET_DAT =>
            if arbiter_condition = '1' then
            
               m_op_seq_num_o       <= m_op_seq_num;
               frame_seq_num_o      <= ret_dat_frame_seq_num_i;
               frame_sync_num_o     <= ret_dat_frame_sync_num_i;
      
               card_addr_o          <= ret_dat_card_addr_i; 
               parameter_id_o       <= ret_dat_parameter_id_i; 
               data_size_o          <= ret_dat_data_size_i;
               data_o               <= ret_dat_data_i; 
               data_clk_o           <= ret_dat_data_clk_i;
               macro_instr_rdy      <= ret_dat_macro_instr_rdy_i;
            
               async_state <= RET_DAT;
            else
            
               m_op_seq_num_o       <= m_op_seq_num;
               frame_seq_num_o      <= ret_dat_frame_seq_num_i;
               frame_sync_num_o     <= ret_dat_frame_sync_num_i;
      
               card_addr_o          <= ret_dat_card_addr_i; 
               parameter_id_o       <= ret_dat_parameter_id_i; 
               data_size_o          <= ret_dat_data_size_i;
               data_o               <= ret_dat_data_i; 
               data_clk_o           <= ret_dat_data_clk_i;
               macro_instr_rdy      <= ret_dat_macro_instr_rdy_i;
               
               async_state <= SIMPLE_CMD;
            end if;
            
         when others =>
         
            m_op_seq_num_o       <= m_op_seq_num;
            frame_seq_num_o      <= (others=>'0');
            frame_sync_num_o     <= (others=>'0');
      
            card_addr_o          <= simple_cmd_card_addr_i; 
            parameter_id_o       <= simple_cmd_parameter_id_i; 
            data_size_o          <= simple_cmd_data_size_i;
            data_o               <= simple_cmd_data_i; 
            data_clk_o           <= simple_cmd_data_clk_i;
            macro_instr_rdy      <= simple_cmd_macro_instr_rdy_i;
            
            async_state          <= SIMPLE_CMD;
            
      end case;
   end process;
   
   -- potentially needs fixing for synchronization between incoming commands
   simple_cmd_ack_o <= '1' when simple_cmd_macro_instr_rdy_i = '1'  else '0';
   ret_dat_ack_o    <= '1' when (simple_cmd_macro_instr_rdy_i = '0' and ret_dat_macro_instr_rdy_i = '1') else '0';
   
   macro_instr_rdy_o <= macro_instr_rdy;
------------------------------------------------------------------------
--
-- process to increment macro-op sequence number
--
------------------------------------------------------------------------   
   
   process(rst_i, macro_instr_rdy)
   begin
      if rst_i = '1' then
         m_op_seq_num <= x"00";
      elsif macro_instr_rdy'event and macro_instr_rdy = '1' then
         m_op_seq_num <= m_op_seq_num + 1;
      end if;   
   end process;
        
end rtl;