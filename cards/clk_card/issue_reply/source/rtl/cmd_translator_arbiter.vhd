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
-- <revision control keyword substitutions e.g. $Id: cmd_translator_arbiter.vhd,v 1.2 2004/06/09 23:35:54 jjacob Exp $>
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
-- <date $Date: 2004/06/09 23:35:54 $>	-		<text>		- <initials $Author: jjacob $>
--
-- $Log: cmd_translator_arbiter.vhd,v $
-- Revision 1.2  2004/06/09 23:35:54  jjacob
-- cleaned formatting
--
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
      
 
      -- output to the ret_dat state machine
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



   signal macro_instr_rdy           : std_logic;
   signal m_op_seq_num              : std_logic_vector (7 downto 0);

   
   --type a_state is (SIMPLE_CMD, RET_DAT);
   
   type state is (IDLE, SIMPLE_CMD_RDY, SIMPLE_CMD_PAUSE, RET_DAT_RDY, RET_DAT_PAUSE, RET_DAT_RDY_SIMPLE_CMD_PENDING,
                  RET_DAT_RDY_SIMPLE_CMD_PENDING_WAIT);
                   
   --signal async_state : a_state;
   
   signal current_state, next_state : state;
   
   signal arbiter_mux      : std_logic;
 
   signal ret_dat_pending  : std_logic;
   
   constant SIMPLE_CMD : std_logic := '0';
   constant RET_DAT    : std_logic := '1';

begin

------------------------------------------------------------------------
--
-- synchronous arbiter state machine
--
------------------------------------------------------------------------
   process(rst_i, clk_i)
   begin
      if rst_i = '1' then
         current_state <= SIMPLE_CMD_RDY;
      elsif clk_i'event and clk_i = '1' then
         current_state <= next_state;
      end if;
   
   end process;


------------------------------------------------------------------------
--
-- synchronous arbiter state machine
-- assign next states
--
------------------------------------------------------------------------



   process(current_state, simple_cmd_macro_instr_rdy_i, ret_dat_macro_instr_rdy_i)--, ack_i)
   begin
      case current_state is
         when IDLE =>
            if simple_cmd_macro_instr_rdy_i = '1' then
               next_state <= SIMPLE_CMD_RDY;
            elsif ret_dat_macro_instr_rdy_i = '1' then
               next_state <= RET_DAT_RDY;
            else
               next_state <= IDLE;
            end if;
      
      
         when SIMPLE_CMD_RDY =>
            if simple_cmd_macro_instr_rdy_i = '1' then
               next_state <= SIMPLE_CMD_RDY;
            elsif ret_dat_macro_instr_rdy_i = '1' then
               next_state <= SIMPLE_CMD_PAUSE;--RET_DAT_RDY;
            else
               next_state <= IDLE;--SIMPLE_CMD_RDY;
            end if;
            
         when SIMPLE_CMD_PAUSE =>
            next_state <= RET_DAT_RDY;
            
         when RET_DAT_RDY =>
            if simple_cmd_macro_instr_rdy_i = '1' then
               next_state <= RET_DAT_RDY_SIMPLE_CMD_PENDING;--RET_DAT_PAUSE;--SIMPLE_CMD_RDY;
            elsif ret_dat_macro_instr_rdy_i = '1' then
               next_state <= RET_DAT_RDY;
            else
               next_state <= IDLE;--SIMPLE_CMD_RDY;
            end if; 
            
         when RET_DAT_RDY_SIMPLE_CMD_PENDING =>
            if ret_dat_macro_instr_rdy_i = '1' and simple_cmd_macro_instr_rdy_i = '1' then
               next_state <= RET_DAT_RDY_SIMPLE_CMD_PENDING;
            elsif ret_dat_macro_instr_rdy_i = '0' and simple_cmd_macro_instr_rdy_i = '1' then
               next_state <= RET_DAT_RDY_SIMPLE_CMD_PENDING_WAIT;
            else
               next_state <= IDLE;--SIMPLE_CMD_RDY;
            end if;
            
         when RET_DAT_RDY_SIMPLE_CMD_PENDING_WAIT =>
            next_state <= SIMPLE_CMD_RDY;
         
            
         when others => next_state <= IDLE;--SIMPLE_CMD_RDY;
         
      end case;
           
   end process;


--   process(current_state, simple_cmd_macro_instr_rdy_i, ret_dat_macro_instr_rdy_i)--, ack_i)
--   begin
--      case current_state is
--         when SIMPLE_CMD_RDY =>
--            if simple_cmd_macro_instr_rdy_i = '1' then
--               next_state <= SIMPLE_CMD_RDY;
--            elsif ret_dat_macro_instr_rdy_i = '1' then
--               next_state <= RET_DAT_RDY;
--            else
--               next_state <= SIMPLE_CMD_RDY;
--            end if;
--            
--         when RET_DAT_RDY =>
--            if simple_cmd_macro_instr_rdy_i = '1' then
--               next_state <= SIMPLE_CMD_RDY;
--            elsif ret_dat_macro_instr_rdy_i = '1' then
--               next_state <= RET_DAT_RDY;
--            else
--               next_state <= SIMPLE_CMD_RDY;
--            end if; 
--            
--         when others => next_state <= SIMPLE_CMD_RDY;
--         
--      end case;
--           
--   end process;

------------------------------------------------------------------------
--
-- synchronous arbiter state machine
-- assign outputs
--
------------------------------------------------------------------------




   process(current_state, simple_cmd_macro_instr_rdy_i, ret_dat_macro_instr_rdy_i,
   
           simple_cmd_card_addr_i, simple_cmd_parameter_id_i, simple_cmd_data_size_i,
           simple_cmd_data_i, simple_cmd_data_clk_i,
           
           ret_dat_frame_seq_num_i, ret_dat_frame_sync_num_i, ret_dat_card_addr_i,
           ret_dat_parameter_id_i, ret_dat_data_size_i, ret_dat_data_i, ret_dat_data_clk_i, ack_i,
           
           ret_dat_pending)
           
           
   begin
      case current_state is
         when SIMPLE_CMD_RDY =>
         
            if simple_cmd_macro_instr_rdy_i = '1' then
               frame_seq_num_o      <= (others=>'0');
               frame_sync_num_o     <= (others=>'0');
      
               card_addr_o          <= simple_cmd_card_addr_i; 
               parameter_id_o       <= simple_cmd_parameter_id_i; 
               data_size_o          <= simple_cmd_data_size_i;
               data_o               <= simple_cmd_data_i; 
               data_clk_o           <= simple_cmd_data_clk_i;
               macro_instr_rdy      <= simple_cmd_macro_instr_rdy_i;
               
               simple_cmd_ack_o     <= ack_i;
               ret_dat_ack_o        <= '0';
               


               --demux                 <= SIMPLE_CMD;
            

            elsif ret_dat_macro_instr_rdy_i = '1' then
               if ret_dat_pending = '1' then  -- JJ might not need this signal if else is never executed
               
               frame_seq_num_o      <= ret_dat_frame_seq_num_i;
               frame_sync_num_o     <= ret_dat_frame_sync_num_i;
      
               card_addr_o          <= ret_dat_card_addr_i; 
               parameter_id_o       <= ret_dat_parameter_id_i; 
               data_size_o          <= ret_dat_data_size_i;
               data_o               <= ret_dat_data_i; 
               data_clk_o           <= ret_dat_data_clk_i;
               macro_instr_rdy      <= ret_dat_macro_instr_rdy_i;
               
               simple_cmd_ack_o     <= '0';
               ret_dat_ack_o        <= '0';
               
               else  -- JJ is this 'else' ever executed? (don't think so)

               
               frame_seq_num_o      <= ret_dat_frame_seq_num_i;  
               frame_sync_num_o     <= ret_dat_frame_sync_num_i;
      
               card_addr_o          <= ret_dat_card_addr_i; 
               parameter_id_o       <= ret_dat_parameter_id_i; 
               data_size_o          <= ret_dat_data_size_i;
               data_o               <= ret_dat_data_i; 
               data_clk_o           <= ret_dat_data_clk_i;
               macro_instr_rdy      <= ret_dat_macro_instr_rdy_i;
               
               simple_cmd_ack_o     <= '0';
               ret_dat_ack_o        <= ack_i; 
               
               end if;
               


           --  demux                 <= RET_DAT;

            else
               frame_seq_num_o      <= (others=>'0');
               frame_sync_num_o     <= (others=>'0');
      
               card_addr_o          <= simple_cmd_card_addr_i; 
               parameter_id_o       <= simple_cmd_parameter_id_i; 
               data_size_o          <= simple_cmd_data_size_i;
               data_o               <= simple_cmd_data_i; 
               data_clk_o           <= simple_cmd_data_clk_i;
               macro_instr_rdy      <= simple_cmd_macro_instr_rdy_i;
               
               simple_cmd_ack_o     <= ack_i;
               ret_dat_ack_o        <= '0';
               


             --  demux                 <= SIMPLE_CMD;
            end if;
         when SIMPLE_CMD_PAUSE =>
         
               frame_seq_num_o      <= (others=>'0');
               frame_sync_num_o     <= (others=>'0');
      
               card_addr_o          <= simple_cmd_card_addr_i; 
               parameter_id_o       <= simple_cmd_parameter_id_i; 
               data_size_o          <= simple_cmd_data_size_i;
               data_o               <= simple_cmd_data_i; 
               data_clk_o           <= simple_cmd_data_clk_i;
               macro_instr_rdy      <= simple_cmd_macro_instr_rdy_i;
               
               simple_cmd_ack_o     <= '0';
               ret_dat_ack_o        <= '0'; 
               

            
         when RET_DAT_PAUSE =>
         
               frame_seq_num_o      <= ret_dat_frame_seq_num_i;
               frame_sync_num_o     <= ret_dat_frame_sync_num_i;
      
               card_addr_o          <= ret_dat_card_addr_i; 
               parameter_id_o       <= ret_dat_parameter_id_i; 
               data_size_o          <= ret_dat_data_size_i;
               data_o               <= ret_dat_data_i; 
               data_clk_o           <= ret_dat_data_clk_i;
               macro_instr_rdy      <= ret_dat_macro_instr_rdy_i;
               
               simple_cmd_ack_o     <= '0';
               ret_dat_ack_o        <= '0';  
               

               
         when RET_DAT_RDY =>
         
            --if ret_dat_macro_instr_rdy_i = '0' then
         
               frame_seq_num_o      <= ret_dat_frame_seq_num_i;
               frame_sync_num_o     <= ret_dat_frame_sync_num_i;
      
               card_addr_o          <= ret_dat_card_addr_i; 
               parameter_id_o       <= ret_dat_parameter_id_i; 
               data_size_o          <= ret_dat_data_size_i;
               data_o               <= ret_dat_data_i; 
               data_clk_o           <= ret_dat_data_clk_i;
               macro_instr_rdy      <= ret_dat_macro_instr_rdy_i;
               
               simple_cmd_ack_o     <= '0';
               ret_dat_ack_o        <= ack_i;
               

                
            --   demux                 <= RET_DAT;
         
--            if ack_i = '1' then --ack_i = '1' then
--               next_state <= SIMPLE_CMD_RDY;
--            else
--               next_state <= RET_DAT_RDY;
--            end if

         when RET_DAT_RDY_SIMPLE_CMD_PENDING =>
         
               frame_seq_num_o      <= ret_dat_frame_seq_num_i;
               frame_sync_num_o     <= ret_dat_frame_sync_num_i;
      
               card_addr_o          <= ret_dat_card_addr_i; 
               parameter_id_o       <= ret_dat_parameter_id_i; 
               data_size_o          <= ret_dat_data_size_i;
               data_o               <= ret_dat_data_i; 
               data_clk_o           <= ret_dat_data_clk_i;
               macro_instr_rdy      <= ret_dat_macro_instr_rdy_i;
               
               simple_cmd_ack_o     <= '0';
               ret_dat_ack_o        <= ack_i;
               

               
         when RET_DAT_RDY_SIMPLE_CMD_PENDING_WAIT =>
         
               frame_seq_num_o      <= (others=>'0');
               frame_sync_num_o     <= (others=>'0');
      
               card_addr_o          <= simple_cmd_card_addr_i; 
               parameter_id_o       <= simple_cmd_parameter_id_i; 
               data_size_o          <= simple_cmd_data_size_i;
               data_o               <= simple_cmd_data_i; 
               data_clk_o           <= simple_cmd_data_clk_i;
               macro_instr_rdy      <= simple_cmd_macro_instr_rdy_i;
         
         
         
--               frame_seq_num_o      <= ret_dat_frame_seq_num_i;
--               frame_sync_num_o     <= ret_dat_frame_sync_num_i;
--      
--               card_addr_o          <= ret_dat_card_addr_i; 
--               parameter_id_o       <= ret_dat_parameter_id_i; 
--               data_size_o          <= ret_dat_data_size_i;
--               data_o               <= ret_dat_data_i; 
--               data_clk_o           <= ret_dat_data_clk_i;
--               macro_instr_rdy      <= ret_dat_macro_instr_rdy_i;
               
               simple_cmd_ack_o     <= '0';
               ret_dat_ack_o        <= '0';
               

         
      
         when others =>
         
               frame_seq_num_o      <= (others=>'0');
               frame_sync_num_o     <= (others=>'0');
      
               card_addr_o          <= simple_cmd_card_addr_i; 
               parameter_id_o       <= simple_cmd_parameter_id_i; 
               data_size_o          <= simple_cmd_data_size_i;
               data_o               <= simple_cmd_data_i; 
               data_clk_o           <= simple_cmd_data_clk_i;
               macro_instr_rdy      <= simple_cmd_macro_instr_rdy_i;
               
               simple_cmd_ack_o     <= ack_i;
               ret_dat_ack_o        <= '0';  
               

   
            --  demux                 <= SIMPLE_CMD;    

         end case;
      end process;
 
 
   process(clk_i, rst_i)
   begin
      if rst_i = '1' then
         ret_dat_pending         <= '0';
      elsif clk_i'event and clk_i = '1' then
         if current_state = RET_DAT_RDY_SIMPLE_CMD_PENDING_WAIT then
            ret_dat_pending      <= '1';
         elsif current_state = RET_DAT_RDY then
            ret_dat_pending      <= '0';
         else
            ret_dat_pending      <= ret_dat_pending;
         end if;
      end if;
   end process;
      
--      process(demux, ack_i)
--      begin
--         if demux = RET_DAT then
--            simple_cmd_ack_o <= '0';
--            ret_dat_ack_o    <= ack_i;
--         else
--            simple_cmd_ack_o <= ack_i;
--            ret_dat_ack_o    <= '0';
--         end if;
--      
--      end process;
--
--      simple_cmd_ack_o <= ack_i when demux = SIMPLE_CMD else '0';
--      ret_dat_ack_o    <= ack_i when demux = RET_DAT    else '0'; 
--

   
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
   
   m_op_seq_num_o <= m_op_seq_num;
        
end rtl;