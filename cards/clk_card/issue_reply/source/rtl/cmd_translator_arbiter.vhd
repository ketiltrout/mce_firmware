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
-- <revision control keyword substitutions e.g. $Id: cmd_translator_arbiter.vhd,v 1.14 2004/09/09 18:25:51 jjacob Exp $>
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
-- <date $Date: 2004/09/09 18:25:51 $>	-		<text>		- <initials $Author: jjacob $>
--
-- $Log: cmd_translator_arbiter.vhd,v $
-- Revision 1.14  2004/09/09 18:25:51  jjacob
-- added 3 outputs:
-- >       cmd_type_o        :  out std_logic_vector (CMD_TYPE_WIDTH-1 downto 0);       -- this is a re-mapping of the cmd_code into a 3-bit number
-- >       cmd_stop_o        :  out std_logic;                                          -- indicates a STOP command was recieved
-- >       last_frame_o      :  out std_logic;                                          -- indicates the last frame of data for a ret_dat command
--
-- Revision 1.13  2004/09/02 18:24:28  jjacob
-- cleaning up and formatting
--
-- Revision 1.12  2004/08/24 00:00:44  jjacob
-- registered the macro_instr_rdy_o signal, and the ack_i signal to/from the
-- cmd_queue to break a combinational loop
--
-- Revision 1.11  2004/08/06 00:14:14  jjacob
-- hard coded data size to (others=>'0') for ret_dat commands.  This needs
-- to be changed at the source.
--
-- Revision 1.10  2004/08/05 20:51:33  jjacob
-- added sync_number input
--
-- Revision 1.9  2004/08/05 18:14:42  jjacob
-- changed frame_sync_num_o to use the parameter
-- SYNC_NUM_BUS_WIDTH
--
-- Revision 1.8  2004/08/03 20:00:55  jjacob
-- updating the macro_instr_rdy signal and cleaning up
--
-- Revision 1.7  2004/07/30 23:31:32  jjacob
-- safety checkin for the long weekend
--
-- Revision 1.6  2004/07/28 23:39:12  jjacob
-- added:
-- library sys_param;
-- use sys_param.command_pack.all;
--
-- Revision 1.5  2004/07/05 23:51:47  jjacob
-- added ack_o output to cmd_translator_ret_dat_fsm
--
-- Revision 1.4  2004/06/21 17:01:51  jjacob
-- first stable version, doesn't yet have macro-instruction buffer, doesn't have
-- "quick" acknolwedgements for instructions that require them, no error
-- handling, basically no return path logic yet.  Have implemented ret_dat
-- instructions, and "simple" instructions.  Not all instructions are fully
-- implemented yet.
--
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


library sys_param;
use sys_param.wishbone_pack.all;
use sys_param.general_pack.all;
use sys_param.command_pack.all;

library components;
use components.component_pack.all;

library work;
use work.issue_reply_pack.all;

entity cmd_translator_arbiter is

port(

     -- global inputs

      rst_i                        : in std_logic;
      clk_i                        : in std_logic;

      -- inputs from the 'return data' state machine
      ret_dat_frame_seq_num_i      : in std_logic_vector (31 downto 0);
      ret_dat_frame_sync_num_i     : in std_logic_vector (7 downto 0);
      
      ret_dat_card_addr_i          : in std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0);  -- specifies which card the command is targetting
      ret_dat_parameter_id_i       : in std_logic_vector (PAR_ID_BUS_WIDTH-1 downto 0);     -- comes from reg_addr_i, indicates which device(s) the command is targett_ig
      ret_dat_data_size_i          : in std_logic_vector (DATA_SIZE_BUS_WIDTH-1 downto 0);  -- num_data_i, indicates number of 16-bit words of data
      ret_dat_data_i               : in std_logic_vector (DATA_BUS_WIDTH-1 downto 0);       -- data will be passed straight thru in 16-bit words
      ret_dat_data_clk_i           : in std_logic;							                                   -- for clocking out the data
      ret_dat_macro_instr_rdy_i    : in std_logic;                                          -- ='1' when the data is valid, else it's '0'
      ret_dat_fsm_working_i        : in std_logic;
      ret_dat_cmd_type_i           : in std_logic_vector (CMD_TYPE_WIDTH-1 downto 0);       -- this is a re-mapping of the cmd_code into a 3-bit number
      ret_dat_cmd_stop_i           : in std_logic;                                          -- indicates a STOP command was recieved
      ret_dat_last_frame_i         : in std_logic;  
        
      -- output to the 'return data' state machine
      ret_dat_ack_o                : out std_logic;                                         -- acknowledgment from the macro-instr arbiter that it is ready and has grabbed the data

      -- inputs from the 'simple commands' state machine
      simple_cmd_card_addr_i       : in std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0);  -- specifies which card the command is targetting
      simple_cmd_parameter_id_i    : in std_logic_vector (PAR_ID_BUS_WIDTH-1 downto 0);     -- comes from reg_addr_i, indicates which device(s) the command is targetting
      simple_cmd_data_size_i       : in std_logic_vector (DATA_SIZE_BUS_WIDTH-1 downto 0);  -- data_size_i, indicates number of 16-bit words of data
      simple_cmd_data_i            : in std_logic_vector (DATA_BUS_WIDTH-1 downto 0);       -- data will be passed straight thru in 16-bit words
      simple_cmd_data_clk_i        : in std_logic;							                                   -- for clocking out the data
      simple_cmd_macro_instr_rdy_i : in std_logic;                                          -- ='1' when the data is valid, else it's '0'
      simple_cmd_type_i            : in std_logic_vector (CMD_TYPE_WIDTH-1 downto 0);       -- this is a re-mapping of the cmd_code into a 3-bit number
      
      -- output to the ret_dat state machine
      simple_cmd_ack_o             : out std_logic ;  
      
      -- input for sync_number for simple commands
      sync_number_i                : in std_logic_vector (SYNC_NUM_BUS_WIDTH-1 downto 0);

      -- outputs to the micro instruction sequence generator
      m_op_seq_num_o               : out std_logic_vector (MOP_BUS_WIDTH-1 downto 0);        -- (7 downto 0);
      frame_seq_num_o              : out std_logic_vector (31 downto 0);
      frame_sync_num_o             : out std_logic_vector (SYNC_NUM_BUS_WIDTH-1 downto 0);   -- (7 downto 0);
      
      -- outputs to the cmd_queue (micro-instruction generator)
      card_addr_o                  : out std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0);  -- specifies which card the command is targetting
      parameter_id_o               : out std_logic_vector (PAR_ID_BUS_WIDTH-1 downto 0);     -- comes from reg_addr_i, indicates which device(s) the command is targetting
      data_size_o                  : out std_logic_vector (DATA_SIZE_BUS_WIDTH-1 downto 0);  -- num_data_i, indicates number of 16-bit words of data
      data_o                       : out std_logic_vector (DATA_BUS_WIDTH-1 downto 0);       -- data will be passed straight thru in 16-bit words
      data_clk_o                   : out std_logic;							                                   -- for clocking out the data
      macro_instr_rdy_o            : out std_logic;                                          -- ='1' when the data is valid, else it's '0'
      cmd_type_o                   : out std_logic_vector (CMD_TYPE_WIDTH-1 downto 0);       -- this is a re-mapping of the cmd_code into a 3-bit number
      cmd_stop_o                   : out std_logic;                                          -- indicates a STOP command was recieved
      last_frame_o                 : out std_logic;    
      
      -- input from the micro-instruction generator (cmd_queue)
      ack_i                        : in std_logic                   -- acknowledgment from the micro-instr generator (cmd_queue) that it is ready and has grabbed the data

   ); 
     
end cmd_translator_arbiter;


architecture rtl of cmd_translator_arbiter is

   signal macro_instr_rdy           : std_logic;
   signal macro_instr_rdy_reg       : std_logic;
   signal macro_instr_rdy_1st_stg   : std_logic;
   signal macro_instr_rdy_mux_sel   : std_logic;
   
   signal m_op_seq_num              : std_logic_vector (7 downto 0);
   signal m_op_seq_num_mux          : std_logic_vector (7 downto 0);
   signal m_op_seq_num_mux_sel      : std_logic;

   signal frame_seq_num             : std_logic_vector (31 downto 0);
   signal frame_seq_num_1st_stg     : std_logic_vector (31 downto 0);
   
   signal frame_sync_num            : std_logic_vector (7 downto 0);
   signal frame_sync_num_1st_stg    : std_logic_vector (7 downto 0);

   signal data_mux_sel              : std_logic; --'0' routes simple cmds thru, '1' is for ret_dat cmds
   signal simple_cmd_ack_mux_sel    : std_logic;
   signal ret_dat_ack_mux_sel       : std_logic;
   
   signal ret_dat_pending_mux       : std_logic;
   signal ret_dat_pending_mux_sel   : std_logic_vector(1 downto 0);
   
   type   state is (IDLE, SIMPLE_CMD_RDY, SIMPLE_CMD_PAUSE, RET_DAT_RDY, RET_DAT_PAUSE, RET_DAT_RDY_SIMPLE_CMD_PENDING,
                    RET_DAT_RDY_SIMPLE_CMD_PENDING_WAIT, RDY_HIGH, RDY_LOW1, RDY_LOW2, RDY_LOW_WAIT);
                   
   signal current_state, next_state : state;
   signal m_op_seq_num_next_state, m_op_seq_num_cur_state : state;
   
   signal arbiter_mux               : std_logic;
 
   signal ret_dat_pending           : std_logic;
   signal sync_number_plus_1        : std_logic_vector(SYNC_NUM_BUS_WIDTH-1 downto 0);
   
   signal ack_reg                   : std_logic;
   
   signal cmd_type_reg              : std_logic_vector (CMD_TYPE_WIDTH-1 downto 0);
   signal cmd_type                  : std_logic_vector (CMD_TYPE_WIDTH-1 downto 0);
   signal cmd_stop_reg              : std_logic;
   signal cmd_stop                  : std_logic;
   signal last_frame_reg            : std_logic;
   signal last_frame                : std_logic;
   
   constant SIMPLE_CMD              : std_logic := '0';
   constant RET_DAT                 : std_logic := '1';

begin

------------------------------------------------------------------------
--
-- arbiter state machine state sequencer
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
-- arbiter state machine
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
               next_state <= SIMPLE_CMD_PAUSE;
            else
               next_state <= IDLE;
            end if;
            
         when SIMPLE_CMD_PAUSE =>
            next_state <= RET_DAT_RDY;
            
         when RET_DAT_RDY =>
            if simple_cmd_macro_instr_rdy_i = '1' then
               next_state <= RET_DAT_RDY_SIMPLE_CMD_PENDING;
            elsif ret_dat_macro_instr_rdy_i = '1' then
               next_state <= RET_DAT_RDY;
            else
               next_state <= IDLE;
            end if; 
            
         when RET_DAT_RDY_SIMPLE_CMD_PENDING =>
            if ret_dat_macro_instr_rdy_i = '1' and simple_cmd_macro_instr_rdy_i = '1' then -- wait for current ret_dat m_op to finish
               next_state <= RET_DAT_RDY_SIMPLE_CMD_PENDING;
            elsif ret_dat_macro_instr_rdy_i = '0' and simple_cmd_macro_instr_rdy_i = '1' then
               next_state <= RET_DAT_RDY_SIMPLE_CMD_PENDING_WAIT;
            else
               next_state <= IDLE;
            end if;
            
         when RET_DAT_RDY_SIMPLE_CMD_PENDING_WAIT =>
            next_state <= SIMPLE_CMD_RDY;
                    
         when others => next_state <= IDLE;
         
      end case;
           
   end process;


------------------------------------------------------------------------
--
-- arbiter state machine
-- assign outputs
--
------------------------------------------------------------------------
  
   process(current_state, simple_cmd_macro_instr_rdy_i, ret_dat_macro_instr_rdy_i, ret_dat_pending)           
   begin

         -- defaults
         data_mux_sel               <= '0';  --'0' routes simple cmds thru, '1' is for ret_dat cmds
         simple_cmd_ack_mux_sel     <= '0';
         ret_dat_ack_mux_sel        <= '0';
         macro_instr_rdy_mux_sel    <= '0'; 
         ret_dat_pending_mux_sel    <= "00";
   
      case current_state is
       
         when IDLE =>
            ret_dat_pending_mux_sel           <= "10"; 
      
         when SIMPLE_CMD_RDY =>
            if simple_cmd_macro_instr_rdy_i = '1' then
               simple_cmd_ack_mux_sel         <= '1';
            elsif ret_dat_macro_instr_rdy_i = '1' then
               if ret_dat_pending = '1' then 
                  data_mux_sel                <= '1';
                  macro_instr_rdy_mux_sel     <= '1';
               else
                  data_mux_sel                <= '1';
                  ret_dat_ack_mux_sel         <= '1';
               end if;
            else
               simple_cmd_ack_mux_sel         <= '1';
            end if;
            ret_dat_pending_mux_sel           <= "10"; 
            
         when SIMPLE_CMD_PAUSE =>
            macro_instr_rdy_mux_sel           <= '1';
            ret_dat_pending_mux_sel           <= "10";

         when RET_DAT_PAUSE =>
            data_mux_sel                      <= '1';
            ret_dat_pending_mux_sel           <= "10";
 
         when RET_DAT_RDY =>        
            if ret_dat_macro_instr_rdy_i = '1' then
               data_mux_sel                   <= '1';
            end if; 
            ret_dat_ack_mux_sel               <= '1';
          
         when RET_DAT_RDY_SIMPLE_CMD_PENDING =>

            data_mux_sel                      <= '1';
            ret_dat_ack_mux_sel               <= '1';
            ret_dat_pending_mux_sel           <= "10";
             
         when RET_DAT_RDY_SIMPLE_CMD_PENDING_WAIT =>
            ret_dat_pending_mux_sel           <= "01";
                  
         when others =>              
            simple_cmd_ack_mux_sel            <= '1';
            ret_dat_pending_mux_sel           <= "10";
            
      end case;
   end process;


------------------------------------------------------------------------
--
-- routing muxes
--
------------------------------------------------------------------------

   card_addr_o          <= simple_cmd_card_addr_i       when data_mux_sel = '0' else ret_dat_card_addr_i; 
   parameter_id_o       <= simple_cmd_parameter_id_i    when data_mux_sel = '0' else ret_dat_parameter_id_i; 
   data_size_o          <= simple_cmd_data_size_i       when data_mux_sel = '0' else (others=>'0');-- fix this in fibre_rx! data_size should be '0', not '1' for ret_dat commands. ret_dat_data_size_i;
   data_o               <= simple_cmd_data_i            when data_mux_sel = '0' else ret_dat_data_i; 
   data_clk_o           <= simple_cmd_data_clk_i        when data_mux_sel = '0' else ret_dat_data_clk_i;
   cmd_type             <= simple_cmd_type_i            when data_mux_sel = '0' else ret_dat_cmd_type_i;
   cmd_stop             <= '0'                          when data_mux_sel = '0' else ret_dat_cmd_stop_i;
   last_frame           <= '0'                          when data_mux_sel = '0' else ret_dat_last_frame_i;
   
   frame_seq_num_o      <= (others=>'0')                when data_mux_sel = '0' else ret_dat_frame_seq_num_i;
   frame_sync_num_o     <= sync_number_plus_1           when data_mux_sel = '0' else ret_dat_frame_sync_num_i;
   
   sync_number_plus_1   <= sync_number_i + 1;

   simple_cmd_ack_o     <= ack_reg                      when simple_cmd_ack_mux_sel = '1' else '0';
   ret_dat_ack_o        <= ack_reg                      when ret_dat_ack_mux_sel = '1'    else '0'; 
   
   macro_instr_rdy_1st_stg <= simple_cmd_macro_instr_rdy_i   when data_mux_sel = '0'            else ret_dat_macro_instr_rdy_i;
   macro_instr_rdy         <= macro_instr_rdy_1st_stg        when macro_instr_rdy_mux_sel = '0' else '0';

   -- re-circulation mux for ret_dat_pending signal
   ret_dat_pending_mux  <= '0' when ret_dat_pending_mux_sel = "00" else
                           '1' when ret_dat_pending_mux_sel = "01" else
                           ret_dat_pending;


   process(clk_i, rst_i)
   begin
      if rst_i = '1' then
         macro_instr_rdy_reg    <= '0';
         ack_reg                <= '0';
         ret_dat_pending        <= '0';
         cmd_type_reg           <= (others=>'0');
         cmd_stop_reg           <= '0';
         last_frame_reg         <= '0';
      elsif clk_i'event and clk_i = '1' then
         macro_instr_rdy_reg    <= macro_instr_rdy;
         ack_reg                <= ack_i;
         ret_dat_pending        <= ret_dat_pending_mux;
         cmd_type_reg           <= cmd_type;
         cmd_stop_reg           <= cmd_stop;
         last_frame_reg         <= last_frame;
      end if;
   end process;

   macro_instr_rdy_o <= macro_instr_rdy;  -- this outputs signal one clock cycle earlier
   --macro_instr_rdy_o <= macro_instr_rdy_reg;  -- this outputs signal one clock cycle later
   
   cmd_type_o        <= cmd_type;
   --cmd_type_o        <= cmd_type_reg;
   
   cmd_stop_o        <= cmd_stop;
   --cmd_stop_o        <= cmd_stop_reg;
   
   last_frame_o      <= last_frame;
   --last_frame_o      <= last_frame_reg;
   
------------------------------------------------------------------------
--
-- processes to increment macro-op sequence number
--
------------------------------------------------------------------------   
   
   -- state sequencer
   process(rst_i, clk_i)
   begin
      if rst_i = '1' then
         m_op_seq_num_cur_state <= IDLE;
      elsif clk_i'event and clk_i = '1' then
         m_op_seq_num_cur_state <= m_op_seq_num_next_state;
      end if;
   end process;

   -- assign next state and output
   process(macro_instr_rdy, m_op_seq_num_cur_state)
   begin

      -- default
      m_op_seq_num_mux_sel       <= '0';
   
      case m_op_seq_num_cur_state is
         when IDLE =>
            if macro_instr_rdy = '1' then
               m_op_seq_num_next_state <= RDY_HIGH;
            else
               m_op_seq_num_next_state <= IDLE;
            end if;   
            
         when RDY_HIGH =>
            if macro_instr_rdy = '1' then
               m_op_seq_num_next_state <= RDY_HIGH;
            else
               m_op_seq_num_next_state <= RDY_LOW1;
            end if;
            
         when RDY_LOW1 =>
            if macro_instr_rdy = '1' then
               m_op_seq_num_next_state <= RDY_HIGH;
            else
               m_op_seq_num_next_state <= RDY_LOW2;
               m_op_seq_num_mux_sel       <= '1';
            end if;
           
         when RDY_LOW2 =>
            if macro_instr_rdy = '1' then
               m_op_seq_num_next_state <= RDY_HIGH;
            else
               m_op_seq_num_next_state <= RDY_LOW_WAIT;
            end if;
                     
         when RDY_LOW_WAIT =>
            if macro_instr_rdy = '1' then
               m_op_seq_num_next_state <= RDY_HIGH;
            else
               m_op_seq_num_next_state <= RDY_LOW_WAIT;
            end if;
            
         when others =>
            m_op_seq_num_next_state    <= IDLE;
           
      end case;   
   end process;

   -- recirculation mux
   m_op_seq_num_mux <= m_op_seq_num when m_op_seq_num_mux_sel = '0' else
                       m_op_seq_num + 1;

   -- register for recirculation mux                       
   process(rst_i, clk_i)
   begin
      if rst_i = '1' then
         m_op_seq_num <= (others=>'0');
      elsif clk_i'event and clk_i = '1' then
         m_op_seq_num <= m_op_seq_num_mux;
      end if;
   end process;
   
   m_op_seq_num_o    <= m_op_seq_num;
     
end rtl;