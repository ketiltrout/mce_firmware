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
-- <revision control keyword substitutions e.g. $Id: cmd_translator_ret_dat_fsm.vhd,v 1.9 2004/08/05 18:14:52 jjacob Exp $>
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
-- <date $Date: 2004/08/05 18:14:52 $>	-		<text>		- <initials $Author: jjacob $>
--
-- $Log: cmd_translator_ret_dat_fsm.vhd,v $
-- Revision 1.9  2004/08/05 18:14:52  jjacob
-- changed frame_sync_num_o to use the parameter
-- SYNC_NUM_BUS_WIDTH
--
-- Revision 1.8  2004/07/28 23:38:34  jjacob
-- added:
-- library sys_param;
-- use sys_param.command_pack.all;
-- overhauled state machine structure
--
-- Revision 1.7  2004/07/06 20:12:39  jjacob
-- decoupled the current_sync_num and current_seq_num from the
-- sync_number_i input
--
-- Revision 1.6  2004/07/05 23:38:10  jjacob
-- added ack_o signal to cmd_translator_ret_dat_fsm to control the
-- acknowledge signal back to the fibre_rx block
--
-- Revision 1.5  2004/06/21 17:02:14  jjacob
-- first stable version, doesn't yet have macro-instruction buffer, doesn't have
-- "quick" acknolwedgements for instructions that require them, no error
-- handling, basically no return path logic yet.  Have implemented ret_dat
-- instructions, and "simple" instructions.  Not all instructions are fully
-- implemented yet.
--
-- Revision 1.4  2004/06/10 21:15:32  jjacob
-- no message
--
-- Revision 1.3  2004/06/09 23:36:02  jjacob
-- cleaned formatting
--
-- Revision 1.2  2004/06/03 23:39:47  jjacob
-- safety checkin
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

library sys_param;
use sys_param.wishbone_pack.all;
use sys_param.general_pack.all;
use sys_param.command_pack.all;

library components;
use components.component_pack.all;

library work;
use work.issue_reply_pack.all;



entity cmd_translator_ret_dat_fsm is

port(

     -- global inputs

      rst_i                   : in     std_logic;
      clk_i                   : in     std_logic;

      -- inputs from fibre_rx      

      card_addr_i             : in std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0);  -- specifies which card the command is targetting
      parameter_id_i          : in std_logic_vector (PAR_ID_BUS_WIDTH-1 downto 0);     -- comes from reg_addr_i, indicates which device(s) the command is targetting
      data_size_i             : in std_logic_vector (DATA_SIZE_BUS_WIDTH-1 downto 0);  -- data_size_i, indicates number of 16-bit words of data
      data_i                  : in std_logic_vector (DATA_BUS_WIDTH-1 downto 0);       -- data will be passed straight thru in 16-bit words
      data_clk_i              : in std_logic;							                         -- for clocking out the data
      
      -- other inputs
      sync_pulse_i            : in std_logic;
      sync_number_i           : in std_logic_vector (7 downto 0);    -- a counter of synch pulses 
      ret_dat_start_i         : in std_logic;
      ret_dat_stop_i          : in std_logic;
      
      ret_dat_cmd_valid_o     : out std_logic;
    
      ret_dat_s_start_i       : in std_logic;
      ret_dat_s_done_o        : out std_logic;
      
      frame_seq_num_o         : out std_logic_vector (31 downto 0);
      frame_sync_num_o        : out std_logic_vector (SYNC_NUM_BUS_WIDTH-1 downto 0);--(7 downto 0);
      
      -- outputs to the macro-instruction arbiter
      card_addr_o             : out std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0);  -- specifies which card the command is targetting
      parameter_id_o          : out std_logic_vector (PAR_ID_BUS_WIDTH-1 downto 0);     -- comes from reg_addr_i, indicates which device(s) the command is targetting
      data_size_o             : out std_logic_vector (DATA_SIZE_BUS_WIDTH-1 downto 0);  -- num_data_i, indicates number of 16-bit words of data
      data_o                  : out std_logic_vector (DATA_BUS_WIDTH-1 downto 0);       -- data will be passed straight thru in 16-bit words
      data_clk_o              : out std_logic;							                                -- for clocking out the data
      macro_instr_rdy_o       : out std_logic;                                          -- ='1' when the data is valid, else it's '0'
      
      ret_dat_fsm_working_o   : out std_logic;                										  -- indicates the state machine is busy
      
      -- input from the macro-instruction arbiter
      ack_i                   : in std_logic;                   -- acknowledgment from the micro-instr arbiter that it is ready and has grabbed the data

      -- new output to the cmd_translator top level, this used to go straight from arbiter to top level, but now we
      -- need to multiplex this signal here
      ack_o                   : out std_logic  -- acknowledge signal going back to the fibre_rx block

   ); 
     
end cmd_translator_ret_dat_fsm;


architecture rtl of cmd_translator_ret_dat_fsm is

   signal ret_dat_start           : std_logic; 
   signal ret_dat_done            : std_logic; 
   signal ret_dat_fsm_working     : std_logic;  
   signal ret_dat_cmd_valid       : std_logic;  
   --signal current_sync_num        : std_logic_vector(7 downto 0);
   
   signal card_addr               : std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0); 
   signal parameter_id            : std_logic_vector (PAR_ID_BUS_WIDTH-1 downto 0);
   signal data_size               : std_logic_vector (DATA_SIZE_BUS_WIDTH-1 downto 0);
   signal data                    : std_logic_vector (DATA_BUS_WIDTH-1 downto 0);

   signal ret_dat_s_seq_start_num         : std_logic_vector (31 downto 0);
   signal ret_dat_s_seq_start_num_mux     : std_logic_vector (31 downto 0);
   signal ret_dat_s_seq_start_num_mux_sel : std_logic;
   
   signal ret_dat_s_seq_stop_num          : std_logic_vector (31 downto 0);
   signal ret_dat_s_seq_stop_num_mux      : std_logic_vector (31 downto 0);
   signal ret_dat_s_seq_stop_num_mux_sel  : std_logic;
   --signal current_seq_num         : std_logic_vector (31 downto 0);
   
   signal word_count              : std_logic_vector (DATA_SIZE_BUS_WIDTH-1 downto 0);
   
   type sync_state is                 (IDLE, SET_SEQ_NUM_1, SET_SEQ_NUM_2, RETURN_DATA_ASYNC_WAIT);  --asychronous states  
   signal sync_next_state, sync_current_state             : sync_state;
   
   type state is                   (RETURN_DATA_IDLE, RETURN_DATA_STOP, RETURN_DATA_DONE, 
                                    RETURN_DATA_PAUSE, RETURN_DATA, RETURN_DATA_ACK, RETURN_DATA_1ST, 
                                    RETURN_DATA_ACK_1ST, RETURN_DATA_LAST); --synchronous states
   signal next_state, current_state : state;


   -- signals for generating the sync and sequence numbers
   constant INPUT_NUM_SEL             : std_logic_vector(1 downto 0) := "00";
   constant CURRENT_NUM_PLUS_1_SEL    : std_logic_vector(1 downto 0) := "01";
   constant CURRENT_NUM_SEL           : std_logic_vector(1 downto 0) := "10";
   
   signal mux_sel                     : std_logic_vector(1 downto 0);
   
   signal current_sync_num_reg_plus_1 : std_logic_vector(7 downto 0);
   signal current_sync_num_reg        : std_logic_vector(7 downto 0);
   signal current_sync_num            : std_logic_vector(7 downto 0);
  
   signal current_seq_num_reg_plus_1  : std_logic_vector(31 downto 0);
   signal current_seq_num_reg         : std_logic_vector(31 downto 0);
   signal current_seq_num             : std_logic_vector(31 downto 0);
   
   signal ack_mux                     : std_logic;


begin

   -- dummy assignment, get rid of this signal later
   ret_dat_s_done_o        <= '0';

------------------------------------------------------------------------
--
-- recirculation mux and process for capturing start and stop frame numbers
-- July 26, 2004
--
------------------------------------------------------------------------

   
   ret_dat_s_seq_start_num_mux <= data_i when ret_dat_s_seq_start_num_mux_sel = '1' else ret_dat_s_seq_start_num;
   
   ret_dat_s_seq_stop_num_mux  <= data_i when ret_dat_s_seq_stop_num_mux_sel = '1' else ret_dat_s_seq_stop_num;
   
   process(clk_i, rst_i)
   begin
      if rst_i = '1' then
         ret_dat_s_seq_start_num <= (others=>'0');
         ret_dat_s_seq_stop_num  <= (others=>'0');
      elsif clk_i'event and clk_i = '1' then
         ret_dat_s_seq_start_num <= ret_dat_s_seq_start_num_mux;
         ret_dat_s_seq_stop_num  <= ret_dat_s_seq_stop_num_mux;
      end if;
   end process;
   
   
   
   
------------------------------------------------------------------------
--
-- synchronous state machine for grabbing ret_dat_s data
-- July 26, 2004
--
------------------------------------------------------------------------

   process(ret_dat_s_start_i, data_clk_i,
           sync_current_state, ret_dat_start_i, rst_i, ret_dat_done)
           -- not including async_state, ret_dat_s_seq_stop/start_num in sensitivity list on purpose
   begin

      ret_dat_s_seq_stop_num_mux_sel  <= '0';
      ret_dat_s_seq_start_num_mux_sel <= '0';
      ret_dat_start                   <= '0';
      
      case sync_current_state is
         when IDLE =>
            if rst_i = '1' then
               sync_next_state             <= IDLE;  
                    
            elsif ret_dat_s_start_i = '1' then          
               if data_clk_i = '1' then
                  ret_dat_s_seq_start_num_mux_sel <= '1';
                  sync_next_state             <= SET_SEQ_NUM_2;
               else
                  sync_next_state             <= SET_SEQ_NUM_1;
               end if;
                 
            elsif ret_dat_start_i = '1' then
            
               ret_dat_start               <= '1';  
               sync_next_state             <= RETURN_DATA_ASYNC_WAIT;
               
            elsif ret_dat_done = '1' then
            
               ret_dat_start               <= '0';       
               sync_next_state             <= IDLE;
                         
            else
               
               sync_next_state             <= IDLE;

            end if;
         
         when SET_SEQ_NUM_1 =>
            if data_clk_i = '1' then
               ret_dat_s_seq_start_num_mux_sel <= '1';
               sync_next_state                 <= SET_SEQ_NUM_2;
            else
               sync_next_state                 <= SET_SEQ_NUM_1;
            end if;


         when SET_SEQ_NUM_2 =>
            if data_clk_i = '1' then
               ret_dat_s_seq_stop_num_mux_sel  <= '1';
               if ret_dat_start_i = '1' then
                  sync_next_state <= RETURN_DATA_ASYNC_WAIT;
               else
                  sync_next_state <= IDLE;
               end if;
            else
               sync_next_state                 <= SET_SEQ_NUM_2;
            end if;
               
            
         when RETURN_DATA_ASYNC_WAIT =>
            if ret_dat_done = '1' then
               sync_next_state             <= IDLE;
            else
               sync_next_state <= RETURN_DATA_ASYNC_WAIT;
               ret_dat_start <= '1';
            end if;

         when others =>
            sync_next_state <= IDLE;
    
      end case;
   
   end process;
 


------------------------------------------------------------------------
--
-- sequencer for synchronous state machine based on clk_i 
--
------------------------------------------------------------------------

   process(rst_i, clk_i)
   begin
      if rst_i = '1' then
         sync_current_state <= IDLE;
      elsif clk_i'event and clk_i = '1' then
         sync_current_state <= sync_next_state;
      end if;
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
         current_state <= RETURN_DATA_IDLE;
      elsif clk_i'event and clk_i = '1' then
         current_state <= next_state;
      end if;
   end process;
   
------------------------------------------------------------------------
--
-- synchronous state machine based on clk_i for issuing ret_dat macro-ops
--
------------------------------------------------------------------------

   process(current_state, ret_dat_start, ret_dat_stop_i, current_seq_num, ret_dat_s_seq_stop_num, ack_i)
   begin
      case current_state is
      
         when RETURN_DATA_IDLE =>
         
            if ret_dat_start = '1' and ack_i = '0' then
               next_state <= RETURN_DATA_1ST;

            elsif ret_dat_start = '1' and ack_i = '1' then
               next_state <= RETURN_DATA_ACK_1ST;

            else
               next_state <= RETURN_DATA_IDLE;
            end if;
      
         when RETURN_DATA_1ST =>
        
            if ack_i = '1' then
               next_state <= RETURN_DATA_PAUSE;--RETURN_DATA_ACK; --
            elsif ret_dat_stop_i = '1' then
               next_state <= RETURN_DATA_LAST;
            else
               next_state <= RETURN_DATA_1ST;
            end if;


         when RETURN_DATA =>
        
            if ack_i = '1' then
               next_state <= RETURN_DATA_PAUSE;--RETURN_DATA_ACK; --
            elsif ret_dat_stop_i = '1' then
               next_state <= RETURN_DATA_LAST;
            else
               next_state <= RETURN_DATA;
            end if;

         when RETURN_DATA_ACK_1ST =>
            next_state <= RETURN_DATA_PAUSE;
            
         when RETURN_DATA_ACK =>
            next_state <= RETURN_DATA_PAUSE;
            
         when RETURN_DATA_PAUSE =>
            if ret_dat_stop_i = '1' then
               next_state <= RETURN_DATA_STOP;
            elsif current_seq_num >= ret_dat_s_seq_stop_num then
               next_state <= RETURN_DATA_DONE;
            else
               next_state <= RETURN_DATA;
            end if;
                    
         when RETURN_DATA_STOP =>
            next_state <= RETURN_DATA_IDLE;
            
         when RETURN_DATA_LAST =>
            if ack_i = '1' then
               next_state <= RETURN_DATA_IDLE;--RETURN_DATA_DONE;
            else
               next_state <= RETURN_DATA_LAST;
            end if;            

        
         when RETURN_DATA_DONE =>
            if ack_i = '1' then
               next_state <= RETURN_DATA_IDLE;
            else
               next_state <= RETURN_DATA_DONE;
            end if;    
                        
         when others =>
            next_state <= RETURN_DATA_IDLE;
            
      end case;
   end process;




------------------------------------------------------------------------
--
-- next state logic for synchronous state machine based on clk_i for 
-- issuing ret_dat macro-ops
--
------------------------------------------------------------------------

   ack_o <= ack_i when ack_mux = '1' else '0';
            
   process(current_state, ack_i, ret_dat_start) --card_addr_i, parameter_id_i, data_size_i, data_i, 
   begin
   
      -- default assignments
      ack_mux                 <= '0';

      ret_dat_cmd_valid       <= '0';
      macro_instr_rdy_o       <= '0';               -- ='1' when the data is valid, else it's '0'
      ret_dat_done            <= '0';
      ret_dat_fsm_working     <= '0';
      
      case current_state is
      
         when RETURN_DATA_IDLE =>
         
            if ret_dat_start = '1' then

               ret_dat_cmd_valid       <= '1';
               macro_instr_rdy_o       <= '1';
               ret_dat_fsm_working     <= '1';

            end if;

         when RETURN_DATA_1ST | RETURN_DATA_ACK_1ST =>

            ret_dat_cmd_valid       <= '1';
            macro_instr_rdy_o       <= '1';
            ret_dat_fsm_working     <= '1';
            
            ack_mux                 <= '1';
            

         when RETURN_DATA | RETURN_DATA_ACK =>

            ret_dat_cmd_valid       <= '1';
            macro_instr_rdy_o       <= '1';
            ret_dat_fsm_working     <= '1';  
            
            
         when RETURN_DATA_LAST =>
         
           if ack_i = '1' then
               ret_dat_cmd_valid       <= '1';
               macro_instr_rdy_o       <= '1';
               ret_dat_done            <= '1';
               ret_dat_fsm_working     <= '1';
               
            else
               ret_dat_cmd_valid       <= '1';
               macro_instr_rdy_o       <= '1';
               ret_dat_fsm_working     <= '1';
               
            end if;           
         
         when RETURN_DATA_PAUSE =>

            ret_dat_fsm_working     <= '1';
            
                  
         when RETURN_DATA_STOP =>  -- JJ Need to take some action, like send response back to Linux machine

            ret_dat_done            <= '1';
            ret_dat_fsm_working     <= '1';
   
         when RETURN_DATA_DONE =>  -- JJ Need to take some action, like send response back to Linux machine
         
            if ack_i = '1' then
               ret_dat_cmd_valid       <= '1';
               macro_instr_rdy_o       <= '1';
               ret_dat_done            <= '1';
               ret_dat_fsm_working     <= '1';
            else
               ret_dat_cmd_valid       <= '1';
               macro_instr_rdy_o       <= '1';

               ret_dat_fsm_working     <= '1';
            end if;           
            

      end case;
   end process;



   
   ret_dat_cmd_valid_o     <=    ret_dat_cmd_valid;
   ret_dat_fsm_working_o   <=    ret_dat_fsm_working;


   -- re-circulation muxes
   card_addr		<= card_addr_i     when current_state = RETURN_DATA_IDLE and ret_dat_start = '0' else
                   (others => '0') when rst_i = '1' else
                   card_addr;
  
   parameter_id <= parameter_id_i  when current_state = RETURN_DATA_IDLE and ret_dat_start = '0' else
                   (others => '0') when rst_i = '1' else
                   parameter_id;
                   
   data_size		<= data_size_i     when current_state = RETURN_DATA_IDLE and ret_dat_start = '0' else
                   (others => '0') when rst_i = '1' else
                   data_size;                 
  
   data		<= data_i          when current_state = RETURN_DATA_IDLE and ret_dat_start = '0' else
                   (others => '0') when rst_i = '1' else
                   data;      



------------------------------------------------------------------------
--
-- select line generation for 'sync number' and 'sequence number' mux 
--
------------------------------------------------------------------------
   process(current_state, ret_dat_start)
   begin
      case current_state is 
           
         when RETURN_DATA_IDLE =>         
            if ret_dat_start = '0' then               
               mux_sel        <= CURRENT_NUM_SEL;            
            else
               mux_sel        <= INPUT_NUM_SEL;               
            end if;

         when RETURN_DATA | RETURN_DATA_LAST | RETURN_DATA_ACK | RETURN_DATA_STOP |
              RETURN_DATA_DONE | RETURN_DATA_1ST | RETURN_DATA_ACK_1ST =>      
            mux_sel           <= CURRENT_NUM_SEL;

         when RETURN_DATA_PAUSE =>        
            mux_sel           <= CURRENT_NUM_PLUS_1_SEL;
  
         when others =>            
            mux_sel           <= CURRENT_NUM_SEL;     

      end case;
   end process;

------------------------------------------------------------------------
--
-- 'sync number' and 'sequence number' registers
--
------------------------------------------------------------------------
   process(rst_i, clk_i)
   begin
      if rst_i = '1' then
         current_sync_num_reg <= (others=>'0');
         current_seq_num_reg  <= (others=>'0');
      elsif clk_i'event and clk_i='1' then
         current_sync_num_reg <= current_sync_num;
         current_seq_num_reg  <= current_seq_num;
      end if;
   end process;
   
------------------------------------------------------------------------
--
-- 'sync number' and 'sequence number' muxes
--
------------------------------------------------------------------------   
   current_sync_num <= sync_number_i + 1           when mux_sel = INPUT_NUM_SEL          else
                       current_sync_num_reg_plus_1 when mux_sel = CURRENT_NUM_PLUS_1_SEL else
                       current_sync_num_reg        when mux_sel = CURRENT_NUM_SEL        else
                       current_sync_num_reg;
                       
   current_sync_num_reg_plus_1 <= current_sync_num_reg + 1;

   current_seq_num  <= ret_dat_s_seq_start_num     when mux_sel = INPUT_NUM_SEL          else
                       current_seq_num_reg_plus_1  when mux_sel = CURRENT_NUM_PLUS_1_SEL else
                       current_seq_num_reg         when mux_sel = CURRENT_NUM_SEL        else
                       current_seq_num_reg;

   current_seq_num_reg_plus_1 <= current_seq_num_reg + 1;
   
------------------------------------------------------------------------
--
-- mux for outputs
--
------------------------------------------------------------------------  
   
   process(ret_dat_s_start_i, ret_dat_fsm_working, card_addr_i, parameter_id_i, data_size_i, data_i,
           current_seq_num, current_sync_num, card_addr, parameter_id, data_size, data, data_clk_i)
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
         
         data_clk_o       <= '0';  -- not passing any data, so keep the data clock inactive
         
      else
      
         frame_seq_num_o  <= (others => '0');
         frame_sync_num_o <= (others => '0');

         card_addr_o      <= (others => '0');
         parameter_id_o   <= (others => '0');
         data_size_o      <= (others => '0');
         data_o           <= (others => '0');
         
         data_clk_o       <= '0';
         
      end if; 
      
   end process;



      
end rtl;