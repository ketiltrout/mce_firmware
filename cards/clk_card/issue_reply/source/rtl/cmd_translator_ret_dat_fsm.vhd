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
-- <revision control keyword substitutions e.g. $Id: cmd_translator_ret_dat_fsm.vhd,v 1.7 2004/05/06 18:16:43 jjacob Exp $>
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
-- <date $Date: 2004/05/06 18:16:43 $>	-		<text>		- <initials $Author: jjacob $>
--
-- $Log$
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


entity cmd_translator_ret_dat_fsm is

--generic(cmd_translator_ADDR               : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := EEPROM_ADDR  );

port(

     -- global inputs

      rst_i        : in     std_logic;
      clk_i        : in     std_logic;

      -- inputs from fibre_rx      

      card_addr_i       : in std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0);  -- specifies which card the command is targetting
      parameter_id_i    : in std_logic_vector (PAR_ID_BUS_WIDTH-1 downto 0);     -- comes from reg_addr_i, indicates which device(s) the command is targetting
      data_size_i       : in std_logic_vector (DATA_SIZE_BUS_WIDTH-1 downto 0);  -- data_size_i, indicates number of 16-bit words of data
      data_i            : in std_logic_vector (DATA_BUS_WIDTH-1 downto 0);       -- data will be passed straight thru in 16-bit words
      data_clk_i        : in std_logic;							                         -- for clocking out the data
      
      -- other inputs
      sync_pulse_i    : in std_logic;
      sync_number_i   : in std_logic_vector (7 downto 0);    -- a counter of synch pulses 
      ret_dat_start_i : in std_logic;
      ret_dat_stop_i  : in std_logic;
      
      ret_dat_cmd_valid_o     : out std_logic;
    
      ret_dat_s_start_i       : in std_logic;
      ret_dat_s_done_o        : out std_logic;
      
      frame_seq_num_o       : out std_logic_vector (31 downto 0);
      frame_sync_num_o        : out std_logic_vector (7 downto 0);
      
      -- outputs to the macro-instruction arbiter
      card_addr_o       : out std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0);  -- specifies which card the command is targetting
      parameter_id_o    : out std_logic_vector (PAR_ID_BUS_WIDTH-1 downto 0);     -- comes from reg_addr_i, indicates which device(s) the command is targetting
      data_size_o       : out std_logic_vector (DATA_SIZE_BUS_WIDTH-1 downto 0);  -- num_data_i, indicates number of 16-bit words of data
      data_o            : out std_logic_vector (DATA_BUS_WIDTH-1 downto 0);       -- data will be passed straight thru in 16-bit words
      data_clk_o        : out std_logic;							                          -- for clocking out the data
      macro_instr_rdy_o : out std_logic;                                          -- ='1' when the data is valid, else it's '0'
      
 
      -- input from the macro-instruction arbiter
      ack_i             : in std_logic                   -- acknowledgment from the micro-instr arbiter that it is ready and has grabbed the data

      -- outputs to the reply_translator block
      
      

   ); 
     
end cmd_translator_ret_dat_fsm;


architecture rtl of cmd_translator_ret_dat_fsm is


   -- signals to ret_dat state machine
   signal ret_dat_start : std_logic;
   signal ret_dat_stop  : std_logic;
   signal ret_dat_ack   : std_logic;

   signal ret_dat_done  : std_logic;
   
   signal ret_dat_fsm_working : std_logic;
   
   signal ret_dat_cmd_valid : std_logic;
   
   signal current_sync_num: std_logic_vector(7 downto 0);
   
   signal          card_addr : std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0); 
   signal          parameter_id : std_logic_vector (PAR_ID_BUS_WIDTH-1 downto 0);
   signal          data_size : std_logic_vector (DATA_SIZE_BUS_WIDTH-1 downto 0);
   signal          data : std_logic_vector (DATA_BUS_WIDTH-1 downto 0);
   
   
      
   
   signal ret_dat_s_seq_start_num : std_logic_vector (31 downto 0);
   signal ret_dat_s_seq_stop_num  : std_logic_vector (31 downto 0);
   signal current_seq_num         : std_logic_vector (31 downto 0);
   
   signal word_count     : std_logic_vector (DATA_SIZE_BUS_WIDTH-1 downto 0);
   
   type state is (IDLE, SET_SEQ_NUM, RETURN_DATA, RETURN_DATA_STOP, RETURN_DATA_DONE, RETURN_DATA_ASYNC_WAIT, 
                  RETURN_DATA_WAIT, RETURN_DATA_PAUSE);--, SEQ_START_NUM, SEQ_STOP_NUM);   
   signal async_state, next_state, current_state : state;



begin



------------------------------------------------------------------------
--
-- asynchronous state machine. Reacts immediately, no next-state clocking process
--
------------------------------------------------------------------------

   aysnc_fsm: process(ret_dat_s_start_i, data_i, word_count, data_size_i,
                      ret_dat_start_i, rst_i, ret_dat_done)
           -- not including async_state, ret_dat_s_seq_stop/start_num in sensitivity list on purpose
   begin
   
      -- outputs to the macro-instruction arbiter
--      card_addr_o        <= card_addr_i;
--      parameter_id_o     <= parameter_id_i;
--      data_size_o        <= data_size_i;
--      data_o             <= data_i;
--      data_clk_o         <= data_clk_i;
      --macro_instr_rdy_o  <= '0';
   
   
      ret_dat_s_done_o        <= '0';
      ret_dat_cmd_valid_o     <= '0';
   
      case async_state is
         when IDLE =>
        
         
            if rst_i = '1' then
            
               ret_dat_s_seq_start_num <= (others => '0');
               ret_dat_s_seq_stop_num  <= (others => '0');
               
               async_state <= IDLE;   

         
            elsif ret_dat_s_start_i = '1' then
            
               ret_dat_s_seq_start_num <= data_i;
               ret_dat_s_seq_stop_num  <= ret_dat_s_seq_stop_num;
           
               async_state <= SET_SEQ_NUM;
               
            elsif ret_dat_start_i = '1' then
            
               -- make other signal assignment here also
--               current_seq_num <= ret_dat_s_seq_start_num;
--               current_sync_num <= sync_number_i;

               async_state <= RETURN_DATA_ASYNC_WAIT;
               
            elsif ret_dat_done = '1' then
            
               -- make other signal assignment here also
               async_state <= IDLE;
               
            else


               
               ret_dat_s_seq_start_num <= ret_dat_s_seq_start_num;
               ret_dat_s_seq_stop_num  <= ret_dat_s_seq_stop_num;
               async_state <= IDLE;

            end if;
         
         when SET_SEQ_NUM =>
         
            if word_count > data_size_i then
            
               
               ret_dat_s_seq_start_num <= ret_dat_s_seq_start_num;
               ret_dat_s_seq_stop_num  <= ret_dat_s_seq_stop_num;
               ret_dat_s_done_o        <= '1';
               
               if ret_dat_start_i = '1' then
            
               -- make other signal assignment here also
--                  current_seq_num <= ret_dat_s_seq_start_num;
--                  current_sync_num <= sync_number_i;

                  async_state <= RETURN_DATA_ASYNC_WAIT;
                  
               else
               
                  async_state <= IDLE;
               end if;
               

            else  
            

               ret_dat_s_seq_start_num <= ret_dat_s_seq_start_num;    
               ret_dat_s_seq_stop_num  <= data_i;

               async_state <= SET_SEQ_NUM;
               
            end if;
            
         when RETURN_DATA_ASYNC_WAIT =>
            if ret_dat_done = '1' then
            
               -- make other signal assignment here also
               async_state <= IDLE;
               
            else
            
               async_state <= RETURN_DATA_ASYNC_WAIT;
            end if;
            
         when others =>
         
            async_state <= IDLE;
         

       
      end case;
   
   end process;
 

------------------------------------------------------------------------
--
-- sequencer for synchronous state machine based on clk_i for 
-- issuing ret_dat macro-ops
--
------------------------------------------------------------------------

   process(rst_i, clk_i)
   begin
      if rst_i = '1' then
         current_state <= RETURN_DATA_WAIT;
      elsif clk_i'event and clk_i = '1' then
         current_state <= next_state;
      end if;
   end process;
   
------------------------------------------------------------------------
--
-- synchronous state machine based on clk_i for issuing ret_dat macro-ops
--
------------------------------------------------------------------------

   process(current_state, ret_dat_start_i, ret_dat_stop_i, current_seq_num, ret_dat_s_seq_stop_num)
   begin
      case current_state is
      
         when RETURN_DATA_WAIT =>
         
            if ret_dat_start_i = '1' then
               next_state <= RETURN_DATA;
               
            else
               next_state <= RETURN_DATA_WAIT;
            end if;
      
         when RETURN_DATA =>
        
            if ret_dat_stop_i = '1' then
               next_state <= RETURN_DATA_STOP;
            elsif current_seq_num = ret_dat_s_seq_stop_num then
               next_state <= RETURN_DATA_DONE;
            else
               next_state <= RETURN_DATA_PAUSE;
            end if;
            
         when RETURN_DATA_PAUSE =>
            next_state <= RETURN_DATA;
                    
         when RETURN_DATA_STOP =>
         
            next_state <= RETURN_DATA_WAIT;
            
         when RETURN_DATA_DONE =>
            
            next_state <= RETURN_DATA_WAIT;
            
         when others =>
         
            next_state <= RETURN_DATA_WAIT;
            
      end case;
   end process;

            
--         when ISSUE_CMD_DONE =>


   

------------------------------------------------------------------------
--
-- next state logic for synchronous state machine based on clk_i for 
-- issuing ret_dat macro-ops
--
------------------------------------------------------------------------

   process(current_state, current_seq_num, sync_number_i, card_addr_i, parameter_id_i, data_size_i, data_i,
           ret_dat_s_seq_start_num)
   begin
      case current_state is
      
         when RETURN_DATA_WAIT =>
         
            current_sync_num        <= sync_number_i;
            current_seq_num         <= ret_dat_s_seq_start_num;
            card_addr               <= card_addr_i;              -- capture and hold the card_addr
            parameter_id            <= parameter_id_i;           -- capture and hold the parameter_id
            data_size               <= data_size_i;              -- capture and hold the data_size
            data                    <= data_i;                   -- capture and hold the data
            
            ret_dat_cmd_valid_o     <= '0';
            ret_dat_cmd_valid       <= '0';
            macro_instr_rdy_o       <= '0';               -- ='1' when the data is valid, else it's '0'
            ret_dat_done            <= '0';
            
            ret_dat_fsm_working     <= '0';
    
         when RETURN_DATA =>
         
            current_sync_num        <= current_sync_num + 1;   -- each new ret_dat command must corresponding to the next sync pulse
            current_seq_num         <= current_seq_num + 1;    -- this keeps track of what frame number we are on in the sequence of frames
            ret_dat_cmd_valid_o     <= '0';
            ret_dat_cmd_valid       <= '0';
            
            macro_instr_rdy_o       <= '0';
            ret_dat_done            <= '0';
            
            ret_dat_fsm_working     <= '1';
         
         when RETURN_DATA_PAUSE =>
         
            current_seq_num         <= current_seq_num;
            ret_dat_cmd_valid_o     <= '1';
            ret_dat_cmd_valid       <= '1';
            
            macro_instr_rdy_o       <= '1';
            ret_dat_done            <= '0';
            
            ret_dat_fsm_working     <= '1';
                  
         when RETURN_DATA_STOP =>
         
            current_seq_num         <= current_seq_num;
            ret_dat_cmd_valid_o     <= '0';
            ret_dat_cmd_valid       <= '0';
            
            macro_instr_rdy_o       <= '0';
            ret_dat_done            <= '1';
            
            ret_dat_fsm_working     <= '1';
   
         when RETURN_DATA_DONE =>
         
            current_seq_num         <= current_seq_num;
            ret_dat_cmd_valid_o     <= '0';
            ret_dat_cmd_valid       <= '0';
            
            macro_instr_rdy_o       <= '0';
            ret_dat_done            <= '1';
            
            ret_dat_fsm_working     <= '1';
            
         when others =>
         
         
            current_sync_num        <= (others => '0');
            current_seq_num         <= (others => '0');
            card_addr               <= (others => '0');
            parameter_id            <= (others => '0');
            data_size               <= (others => '0');
            data                    <= (others => '0');
         
            ret_dat_cmd_valid_o     <= '0';
            ret_dat_cmd_valid       <= '0';
            
            macro_instr_rdy_o       <= '0';               -- ='1' when the data is valid, else it's '0'
            ret_dat_done            <= '0';
            
            ret_dat_fsm_working     <= '0';
            
      end case;
   end process;
   
 
------------------------------------------------------------------------
--
-- mux for outputs
--
------------------------------------------------------------------------  
   
   process(ret_dat_s_start_i, ret_dat_fsm_working, card_addr_i, parameter_id_i, data_size_i, data_i,
           current_seq_num, current_sync_num, card_addr, parameter_id, data_size, data, data_clk_i, ret_dat_cmd_valid)
   begin
      if ret_dat_s_start_i = '1' then
      
         frame_seq_num_o  <= (others => '0');
         frame_sync_num_o <= (others => '0');

         card_addr_o      <= card_addr_i;
         parameter_id_o   <= parameter_id_i;
         data_size_o      <= data_size_i;
         data_o           <= data_i;
         
         data_clk_o       <= data_clk_i;
         
      elsif ret_dat_fsm_working = '1' then
      
         frame_seq_num_o  <= current_seq_num;
         frame_sync_num_o <= current_sync_num;

         card_addr_o      <= card_addr;
         parameter_id_o   <= parameter_id;
         data_size_o      <= data_size;
         data_o           <= data;
         
         data_clk_o       <= ret_dat_cmd_valid;
         
      else
      
         frame_seq_num_o  <= (others => '0');
         frame_sync_num_o <= (others => '0');

         card_addr_o      <= (others => '0');
         parameter_id_o   <= (others => '0');
         data_size_o      <= (others => '0');
         data_o           <= (others => '0');
         
      end if; 
      
   end process;

------------------------------------------------------------------------
--
-- current sequence frame number
--
------------------------------------------------------------------------ 
-- write a counter based on data_clk
--   process (sync_pulse_i)
--   begin
--      if sync_pulse_i'event and sync_pulse_i = '1' then
--         current_seq_num <= current_seq_num + 1;
--      end if;
--
--   end process; 

------------------------------------------------------------------------
--
-- word count
--
------------------------------------------------------------------------ 
-- write a counter based on data_clk
   process (async_state, data_clk_i) -- purposely didn't include word_count in sensitivity list
   begin
      case async_state is
         when IDLE =>
            word_count <= (others => '0');
         when SET_SEQ_NUM =>
            if data_clk_i'event and data_clk_i='1' then
               word_count <= word_count + 1;
            end if;
         when others =>
            word_count <= (others => '0');
      end case;
   end process;





      
end rtl;