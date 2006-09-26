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
-- <revision control keyword substitutions e.g. $Id: cmd_translator_internal_cmd_fsm.vhd,v 1.8 2006/09/21 16:11:02 bburger Exp $>
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
-- <date $Date: 2006/09/21 16:11:02 $> -     <text>      - <initials $Author: bburger $>
--
-- $Log: cmd_translator_internal_cmd_fsm.vhd,v $
-- Revision 1.8  2006/09/21 16:11:02  bburger
-- Bryce:  Upgraded the functionality to allow issuing multiple different internal commands.
--
-- Revision 1.7  2006/09/07 22:25:22  bburger
-- Bryce:  replace cmd_type (1-bit: read/write) interfaces and funtionality with cmd_code (32-bit: read_block/ write_block/ start/ stop/ reset) interface because reply_queue_sequencer needed to know to discard replies to reset commands
--
-- Revision 1.6  2006/08/02 16:24:41  bburger
-- Bryce:  trying to fixed occasional wb bugs in issue_reply
--
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

library work;
use work.frame_timing_pack.all;
use work.issue_reply_pack.all;

library components;
use components.component_pack.all;

library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;

entity cmd_translator_internal_cmd_fsm is

port(
     -- global inputs
      rst_i                  : in  std_logic;
      clk_i                  : in  std_logic;

      sync_number_i          : in  std_logic_vector (SYNC_NUM_WIDTH-1 downto 0);

      -- ret_dat_wbs interface
      tes_bias_toggle_en_i   : in std_logic;
      tes_bias_high_i        : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      tes_bias_low_i         : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      tes_bias_toggle_rate_i : in std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);
      status_cmd_en_i        : in std_logic;
  
      -- outputs to the macro-instruction arbiter
      card_addr_o            : out std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0);  -- specifies which card the command is targetting
      parameter_id_o         : out std_logic_vector(BB_PARAMETER_ID_WIDTH-1 downto 0);  -- comes from reg_addr_i, indicates which device(s) the command is targetting
      data_size_o            : out std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);  -- data_size_i, indicates number of 16-bit words of data
      data_o                 : out std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);  -- data will be passed straight thru in 16-bit words
      data_clk_o             : out std_logic;                                               -- for clocking out the data
      instr_rdy_o            : out std_logic;                                               -- ='1' when the data is valid, else it's '0'
      cmd_code_o             : out std_logic_vector(FIBRE_PACKET_TYPE_WIDTH-1 downto 0);
      tes_bias_step_level_o  : out std_logic;
      
      -- input from the macro-instruction arbiter
      ack_i                  : in  std_logic                                                -- acknowledgment from the arbiter that it is ready and has grabbed the data
   );  
     
end cmd_translator_internal_cmd_fsm;

architecture rtl of cmd_translator_internal_cmd_fsm is

   -------------------------------------------------------------------------------------------
   -- type definitions
   ------------------------------------------------------------------------------------------- 
   type state is (IDLE, FPGA_TEMP, CARD_TEMP, PSC_STATUS, TES_BIAS, LATCH_TES_BIAS_DATA, DONE);
   
   -------------------------------------------------------------------------------------------
   -- signals
   -------------------------------------------------------------------------------------------    
   signal current_state       : state;
   signal next_state          : state;

   signal internal_status_req : std_logic; 
   signal internal_status_ack : std_logic;
   signal tes_bias_toggle_req : std_logic;
   signal tes_bias_toggle_ack : std_logic;
   signal toggle_which_way    : std_logic;
   signal toggle_en_delayed   : std_logic;
   
   signal next_toggle_sync    : std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);
   signal update_nts          : std_logic;
   
   signal timer_rst           : std_logic;
   signal time                : integer;
--   signal data_clk            : std_logic;

begin

   -------------------------------------------------------------------------------------------
   -- timer reset logic for issuing internal commands
   -------------------------------------------------------------------------------------------
   tes_bias_step_level_o <= not toggle_which_way;
   
   process(rst_i, clk_i)
   begin
      if(rst_i = '1') then
         timer_rst               <= '1';
         internal_status_req     <= '0';
         tes_bias_toggle_req     <= '0';
         next_toggle_sync        <= (others => '0');
         toggle_which_way        <= '1';
--         data_clk                <= '0';
         toggle_en_delayed       <= '0';

      elsif clk_i'event and clk_i = '1' then 
         
--         data_clk          <= not data_clk;
         toggle_en_delayed <= tes_bias_toggle_en_i;
         timer_rst         <= '0';
         
         if(status_cmd_en_i = '1' and time >= 2000000) then
            internal_status_req  <= '1';      
         elsif(internal_status_ack = '1') then
            internal_status_req  <= '0';
            timer_rst            <= '1';
         end if;
         
         if(tes_bias_toggle_en_i = '1' and next_toggle_sync = sync_number_i) then
            tes_bias_toggle_req  <= '1';      
         elsif(tes_bias_toggle_ack = '1') then
            tes_bias_toggle_req  <= '0';
            toggle_which_way     <= not toggle_which_way;
         end if;
         
         if(update_nts = '1' or (toggle_en_delayed = '0' and tes_bias_toggle_en_i = '1')) then
            next_toggle_sync <= sync_number_i + tes_bias_toggle_rate_i;
         end if;
         
      end if;
   end process;
 
   -------------------------------------------------------------------------------------------
   -- timer for issuing internal status commands
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
   next_state_fsm: process(internal_status_req, tes_bias_toggle_req, ack_i, current_state)
   begin
      next_state <= current_state;
      
      case current_state is
         when IDLE =>
            if(internal_status_req = '1' or tes_bias_toggle_req = '1') then
               next_state <= TES_BIAS;
            end if;
            
         when TES_BIAS =>
            if(tes_bias_toggle_req = '1') then
               if(ack_i = '1') then
                  next_state <= LATCH_TES_BIAS_DATA;
               end if;
            else
               next_state <= FPGA_TEMP;
            end if;

         when LATCH_TES_BIAS_DATA =>
            if(ack_i = '1') then
               next_state <= FPGA_TEMP;
            end if;

         when FPGA_TEMP =>
            if(internal_status_req = '1') then
               if(ack_i = '1') then
                  next_state <= CARD_TEMP;
               end if;
            else
               next_state <= CARD_TEMP;
            end if;
            
         when CARD_TEMP =>
            if(internal_status_req = '1') then
               if(ack_i = '1') then
                  next_state <= PSC_STATUS;
               end if;
            else
               next_state <= PSC_STATUS;
            end if;

         when PSC_STATUS =>
            if(internal_status_req = '1') then
               if(ack_i = '1') then
                  next_state <= IDLE;
               end if;
            else
               next_state <= IDLE;
            end if;

         when DONE =>
         
         
         when others =>
            next_state <= IDLE;
          
      end case;           
   end process next_state_fsm;
   
   out_state_fsm: process(tes_bias_toggle_req, ack_i, internal_status_req, toggle_which_way, 
      tes_bias_low_i, tes_bias_high_i, current_state, sync_number_i, next_toggle_sync)
   begin
      
      tes_bias_toggle_ack <= '0';
      internal_status_ack <= '0';
      update_nts          <= '0';
      card_addr_o         <= (others => '0');
      parameter_id_o      <= (others => '0');
      instr_rdy_o         <= '0';
      cmd_code_o          <= (others => '0');
      data_size_o         <= (others => '0');
      data_o              <= (others => '0');
      data_clk_o          <= '0';                  
      
      case current_state is
         when IDLE =>
            if(tes_bias_toggle_req = '1') then
               update_nts <= '1';
            end if;
            
         -- Internal Commands
         -- constant FPGA_TEMP_ADDR    : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"91";
         -- constant CARD_TEMP_ADDR    : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"92";
         -- constant PSC_STATUS_ADDR   : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"63";
         -- constant BIAS_ADDR         : std_logic_vector(WB_ADDR_WIDTH-1 downto 0) := x"21";  

         
         when TES_BIAS =>
            if(tes_bias_toggle_req = '1') then
               card_addr_o       <= BIAS_CARD_2;  
               parameter_id_o    <= BIAS_ADDR;        
               instr_rdy_o       <= '1';             
               cmd_code_o        <= WRITE_BLOCK;
               data_size_o       <= TES_BIAS_DATA_SIZE; -- 32 words
               data_clk_o        <= '0';
               
               if(toggle_which_way = '0') then 
                  data_o         <= tes_bias_low_i;
               else
                  data_o         <= tes_bias_high_i;
               end if;
               
--               if(ack_i = '1') then
--                  tes_bias_toggle_ack <= '1';
--               end if;
            end if;

         when LATCH_TES_BIAS_DATA =>
            if(tes_bias_toggle_req = '1') then
               card_addr_o       <= BIAS_CARD_2;  
               parameter_id_o    <= BIAS_ADDR;        
               instr_rdy_o       <= '1';             
               cmd_code_o        <= WRITE_BLOCK;
               data_size_o       <= TES_BIAS_DATA_SIZE; -- 32 words
               -- cmd_queue is level-sensitive, not edge-sensitive.
               data_clk_o        <= '1';
               
               if(toggle_which_way = '0') then 
                  data_o         <= tes_bias_low_i;
               else
                  data_o         <= tes_bias_high_i;
               end if;
               
               if(ack_i = '1') then
                  tes_bias_toggle_ack <= '1';
                  
                  -- if the issue of the internal command has been delayed such that (next_toggle_sync is < sync_number_i), 
                  -- we update the value here so as not to freeze the fsm.
                  if(sync_number_i /= next_toggle_sync) then
                     update_nts <= '1';
                  end if;                  
               
               end if;
            end if;

         when FPGA_TEMP =>
            if(internal_status_req = '1') then
               card_addr_o       <= ALL_FPGA_CARDS;  
               parameter_id_o    <= FPGA_TEMP_ADDR;        
               instr_rdy_o       <= '1';             
               cmd_code_o        <= READ_BLOCK;
               data_size_o       <= FPGA_TEMP_DATA_SIZE;   
               data_clk_o        <= '0';
               data_o            <= (others => '0');
            end if;
            
         when CARD_TEMP =>
            if(internal_status_req = '1') then
               card_addr_o       <= ALL_FPGA_CARDS;  
               parameter_id_o    <= CARD_TEMP_ADDR;        
               instr_rdy_o       <= '1';             
               cmd_code_o        <= READ_BLOCK;
               data_size_o       <= CARD_TEMP_DATA_SIZE;   
               data_clk_o        <= '0';
               data_o            <= (others => '0');
            end if;

         when PSC_STATUS =>
            if(internal_status_req = '1') then
               card_addr_o       <= POWER_SUPPLY_CARD;  
               parameter_id_o    <= PSC_STATUS_ADDR;        
               instr_rdy_o       <= '1';             
               cmd_code_o        <= READ_BLOCK;
               data_size_o       <= PSC_STATUS_DATA_SIZE; -- 9 words
               data_clk_o        <= '0';
               data_o            <= (others => '0');
            end if;

         when DONE =>
         when others =>
          
      end case;   
   end process out_state_fsm;    
end rtl;