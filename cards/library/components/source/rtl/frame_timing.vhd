-- Copyright (c) 2003 SCUBA-2 Project
--                  All Rights Reserved
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
-- $Id: frame_timing.vhd,v 1.16 2004/11/02 07:38:09 bburger Exp $
--
-- Project:       SCUBA2
-- Author:        Bryce Burger
-- Organisation:  UBC
--
-- Description:
-- This implements the frame synchronization block for the AC, BC, RC.
--
-- Revision history:
-- <date $Date: 2004/11/02 07:38:09 $> - <text> - <initials $Author: bburger $>
-- $Log: frame_timing.vhd,v $
-- Revision 1.16  2004/11/02 07:38:09  bburger
-- Bryce:  ac_dac_ctrl in progress
--
-- Revision 1.15  2004/10/26 22:50:27  bburger
-- Bryce
--
-- Revision 1.1  2004/04/02 01:13:13  bburger
-- New
--
--
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library sys_param;
use sys_param.frame_timing_pack.all;

library components;
use components.component_pack.all;

entity frame_timing is
   port(
      clk_i                      : in std_logic;
      rst_i                      : in std_logic;
      sync_i                     : in std_logic;
      frame_rst_i                : in std_logic;
      
      -- Where does this signal come from?  Is it a re-sync request?  Or does it come from the flux_loop?
      init_window_req_i          : in std_logic;
      
      sample_num_i               : in integer;
      sample_delay_i             : in integer;
      feedback_delay_i           : in integer;
      address_on_delay_i         : in integer;
         
      update_bias_o              : out std_logic;
      dac_dat_en_o               : out std_logic;
      adc_coadd_en_o             : out std_logic;
      restart_frame_1row_prev_o  : out std_logic;
      restart_frame_aligned_o    : out std_logic; 
      restart_frame_1row_post_o  : out std_logic;
      row_switch_o               : out std_logic;
      row_en_o                   : out std_logic;
      initialize_window_o        : out std_logic
   );
end frame_timing;

architecture beh of frame_timing is
   
   constant ONE_CYCLE_LATENCY : integer := 1;
   constant TWO_CYCLE_LATENCY : integer := 2;
   
   signal clk_error           : std_logic_vector(31 downto 0);
   signal counter_rst         : std_logic;
   signal count               : std_logic_vector(31 downto 0);
   signal frame_count_int     : integer;
   signal row_count_int       : integer;
   signal wait_for_sync       : std_logic;
   signal latch_error         : std_logic;
   signal restart_frame_aligned : std_logic;

   type states is (WAIT_FRM_RST, COUNT_UP, GOT_SYNC, WAIT_TO_LATCH_ERR);
   signal current_state, next_state : states;
   
   type init_win_states is (INIT_OFF, INIT_ON, INIT_HOLD, SET, SET_HOLD);
   signal current_init_win_state, next_init_win_state : init_win_states;
   
   begin
   frame_period_cntr : counter
      generic map(
         MAX => END_OF_FRAME, 
         STEP_SIZE => 1,
         WRAP_AROUND => '1',
         UP_COUNTER => '1'
      )
      port map(
         clk_i => clk_i,
         rst_i => counter_rst,
         ena_i => '1',
         load_i => '0',
         count_i => 0,
         count_o => frame_count_int
      );

   row_dwell_cntr : counter
      generic map(
         MAX => MUX_LINE_PERIOD-1, 
         STEP_SIZE => 1,
         WRAP_AROUND => '1',
         UP_COUNTER => '1'
      )
      port map(
         clk_i => clk_i,
         rst_i => counter_rst,
         ena_i => '1',
         load_i => '0',
         count_i => 0,
         count_o => row_count_int
      );

   clock_err_reg : reg
      generic map(
         WIDTH => 32
      )
      port map(
         clk_i => latch_error,
         rst_i => frame_rst_i,
         ena_i => '1',
         reg_i  => count,
         reg_o => clk_error
      );

   count                      <= conv_std_logic_vector(frame_count_int, 32);
   counter_rst                <= '1' when wait_for_sync = '1' else '0';

   -- Frame-timing signals

   -- The persistence of the last restart_frame signal is only for as long as the next one is not received.
   -- So I can send initialize window signals whenever I want to!.
   
   -- There are two situations in which the intialize_window should be asserted:
   -- 1- After a resync
   -- 2- After changing flux_loop parameters   
   
   update_bias_o              <= '1' when frame_count_int = UPDATE_BIAS and current_state /= WAIT_FRM_RST else '0';
   restart_frame_aligned      <= '1' when frame_count_int = END_OF_FRAME else '0';
   restart_frame_1row_prev_o  <= '1' when frame_count_int = END_OF_FRAME_1ROW_PREV and current_state /= WAIT_FRM_RST else '0';
   restart_frame_aligned_o    <= '1' when (restart_frame_aligned = '1' and current_state /= WAIT_FRM_RST) or (sync_i = '1' and current_state = WAIT_FRM_RST) else '0';
   restart_frame_1row_post_o  <= '1' when frame_count_int = END_OF_FRAME_1ROW_POST and current_state /= WAIT_FRM_RST else '0';
   row_switch_o               <= '1' when row_count_int = MUX_LINE_PERIOD-1 and current_state /= WAIT_FRM_RST else '0';
   dac_dat_en_o               <= '1' when row_count_int >= feedback_delay_i and current_state /= WAIT_FRM_RST else '0';
   adc_coadd_en_o             <= '1' when row_count_int >= sample_delay_i and row_count_int <= sample_delay_i + sample_num_i - TWO_CYCLE_LATENCY and current_state /= WAIT_FRM_RST else '0';
   row_en_o                   <= '1' when row_count_int >= address_on_delay_i-ONE_CYCLE_LATENCY and row_count_int <= MUX_LINE_PERIOD-1-ONE_CYCLE_LATENCY and current_state /= WAIT_FRM_RST else '0';
      
   init_win_state_FF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         current_init_win_state <= INIT_OFF;
      elsif(clk_i'event and clk_i = '1') then
         current_init_win_state <= next_init_win_state;
      end if;
   end process init_win_state_FF;

   init_win_state_NS: process(current_init_win_state, restart_frame_aligned, init_window_req_i)
   begin
      case current_init_win_state is
         when SET =>
            next_init_win_state <= SET_HOLD;
         when SET_HOLD =>
            if(restart_frame_aligned = '1') then
               next_init_win_state <= INIT_ON;
            end if;
         when INIT_ON =>
            next_init_win_state <= INIT_HOLD;
         when INIT_HOLD =>
            if(restart_frame_aligned = '1') then
               next_init_win_state <= INIT_OFF;
            end if;               
         when INIT_OFF =>
            if(init_window_req_i = '1') then
               if(restart_frame_aligned = '1') then
                  next_init_win_state <= SET;
               else
                  next_init_win_state <= SET_HOLD;
               end if;
            end if;               
         when others =>
            next_init_win_state <= INIT_OFF;
      end case;
   end process init_win_state_NS;
   
   init_win_state_out: process(current_init_win_state)
   begin
      case current_init_win_state is
         when SET =>
            initialize_window_o <= '0';
         when SET_HOLD =>
            initialize_window_o <= '0';
         when INIT_ON =>
            initialize_window_o <= '1';
         when INIT_HOLD =>
            initialize_window_o <= '1';
         when INIT_OFF =>
            initialize_window_o <= '0';
         when others =>
            initialize_window_o <= '0';
      end case;
   end process init_win_state_out;
   
   -- If a frame_reset occurs, then during the next sync pulse, frame_count_int resets to zero and increments to 1 two cycles after the rising edge of the sync pulse
   -- Otherwise, frame_count_int should reset to zero at the time when it reaches END_OF_FRAME - and disregard sync altogether.
   
   -- During normal operation, this block will have synchronized itself so that clk_count_o wraps to 0 on the clock cycle following the sync pulse
   -- Also, during normal operation, clk_error_o should indicate '0' if it is perfectly synchronized.
   -- Because the sync pulse comes in on the last clock cycle of the frame, I have had to delay the update of clk_error_o by two clock cycles to make sure that it latches '0'.
   -- One clock cycle is because the sync pulse happens on the last clock of the frame, when clk_count_o is at its maximum.
   -- The second clock cycle is to let the output of the counter stabilize before clocking in the value.
   -- According to simulations, when I register clk_error_o, it takes the value of clk_count_o from the previous clock cycle.
   -- That seems wonky to me, and in practice, we will probably have to test this.
   -- If the second clock cycle delay is not needed in hardware, then just remove the WAIT_TO_LATCH_ERR state from the FSM.
   state_FF: process(clk_i, frame_rst_i)
   begin
      if(frame_rst_i = '1') then
         current_state <= WAIT_FRM_RST;
      elsif(clk_i'event and clk_i = '1') then
         current_state <= next_state;
      end if;
   end process state_FF;

   state_NS: process(current_state, sync_i)
   begin
      case current_state is
         when WAIT_FRM_RST =>
            if (sync_i = '1') then
               next_state <= COUNT_UP;
            else
               next_state <= WAIT_FRM_RST;
            end if;                  
         when COUNT_UP =>
            if (sync_i = '1') then
               next_state <= GOT_SYNC;
            else
               next_state <= COUNT_UP;
            end if;
         when GOT_SYNC =>
            next_state <= WAIT_TO_LATCH_ERR;
         when WAIT_TO_LATCH_ERR =>
            next_state <= COUNT_UP;
         when others =>
            next_state <= WAIT_FRM_RST;
      end case;
   end process state_NS;
   
   state_out: process(current_state, sync_i)
   begin
      case current_state is
         when WAIT_FRM_RST =>
            latch_error <= '0';
            if(sync_i = '1') then
               wait_for_sync <= '1';
            else
               wait_for_sync <= '0';
            end if;
         when COUNT_UP =>
            latch_error <= '0';
            wait_for_sync <= '0';
         when GOT_SYNC =>
            latch_error <= '0';
            wait_for_sync <= '0';
         when WAIT_TO_LATCH_ERR =>
            latch_error <= '1';
            wait_for_sync <= '0';
         when others =>
            latch_error <= '0';
            wait_for_sync <= '0';
      end case;
   end process state_out;
   
end beh;