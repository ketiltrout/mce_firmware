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
-- $Id: frame_timing_core.vhd,v 1.5 2005/01/18 22:21:47 bburger Exp $
--
-- Project:       SCUBA2
-- Author:        Bryce Burger
-- Organisation:  UBC
--
-- Description:
-- This implements the frame synchronization block for the AC, BC, RC.
--
-- Revision history:
-- $Log: frame_timing_core.vhd,v $
-- Revision 1.5  2005/01/18 22:21:47  bburger
-- Bryce:  Added offesets to some of the frame_timing_core signal to compensate for FSM latency
--
-- Revision 1.4  2005/01/13 03:14:51  bburger
-- Bryce:
-- addr_card and clk_card:  added slot_id functionality, removed mem_clock
-- sync_gen and frame_timing:  added custom counters and registers
--
-- Revision 1.3  2004/12/16 22:05:40  bburger
-- Bryce:  changes associated with lvds_tx and cmd_translator interface changes
--
-- Revision 1.2  2004/12/14 20:17:38  bburger
-- Bryce:  Repaired some problems with frame_timing and added a list of frame_timing-initialization commands to clk_card
--
-- Revision 1.1  2004/11/19 20:00:05  bburger
-- Bryce :  updated frame_timing and sync_gen interfaces
--
--
--
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library sys_param;
use sys_param.wishbone_pack.all;

library work;
use work.frame_timing_core_pack.all;
use work.frame_timing_pack.all;

library components;
use components.component_pack.all;

entity frame_timing_core is
   port(
      -- Readout Card interface
      dac_dat_en_o               : out std_logic;
      adc_coadd_en_o             : out std_logic;
      restart_frame_1row_prev_o  : out std_logic;
      restart_frame_aligned_o    : out std_logic; 
      restart_frame_1row_post_o  : out std_logic;
      initialize_window_o        : out std_logic;
      
      -- Address Card interface
      row_switch_o               : out std_logic;
      row_en_o                   : out std_logic;
         
      -- Bias Card interface
      update_bias_o              : out std_logic;
      
      -- Wishbone interface
      row_len_i                  : in integer; -- not used yet
      num_rows_i                 : in integer; -- not used yet
      sample_delay_i             : in integer;
      sample_num_i               : in integer;
      feedback_delay_i           : in integer;
      address_on_delay_i         : in integer;
      resync_req_i               : in std_logic;
      resync_ack_o               : out std_logic; -- not used yet
      init_window_req_i          : in std_logic;
      init_window_ack_o          : out std_logic; -- not used yet
      
      -- Global signals
      clk_i                      : in std_logic;
      mem_clk_i                  : in std_logic;
      rst_i                      : in std_logic;
      sync_i                     : in std_logic
   );
end frame_timing_core;

architecture beh of frame_timing_core is
   
   constant ONE_CYCLE_LATENCY     : integer := 1;
   constant TWO_CYCLE_LATENCY     : integer := 2;
--   constant MIN_ADDRESS_ON_DELAY  : integer := 3;
--   constant MIN_SAMPLE_DELAY      : integer := ;
--   constant MIN_FEEDBACK_DELAY    : integer := ;
   
--   signal clk_error               : std_logic_vector(31 downto 0);
--   signal counter_rst             : std_logic;
--   signal error_count             : std_logic_vector(31 downto 0);
   signal frame_count_int         : integer;
   signal frame_count_new         : integer;
   signal row_count_int           : integer;
   signal row_count_new           : integer;
--   signal wait_for_sync           : std_logic;
--   signal latch_error             : std_logic;
   signal enable_counters         : std_logic;
--   signal restart_frame_aligned   : std_logic;
--   signal frame_rst               : std_logic;
   signal sync_received           : std_logic;
   
   signal end_of_frame_minus_1row : integer;
   signal end_of_frame_plus_1row  : integer;
--   signal frame_end               : integer;
   signal address_on_delay        : integer;

   type states is (IDLE, GOT_BIT0, GOT_BIT1, GOT_BIT2, GOT_BIT3, GOT_SYNC, WAIT_FRM_RST);--, WAIT_TO_LATCH_ERR);
   signal current_state, next_state : states;
   
   type init_win_states is (INIT_OFF, INIT_ON, INIT_HOLD, SET, SET_HOLD);
   signal current_init_win_state, next_init_win_state : init_win_states;
   
   begin
   
--   frame_end <= (num_rows_i*row_len_i)-1;
   end_of_frame_minus_1row <= (num_rows_i*row_len_i)-row_len_i-1;
   end_of_frame_plus_1row <= row_len_i-1;
   
   -- Temporary
   resync_ack_o <= '0';
   
--   frame_count_new <= (frame_count_int + 1) when frame_count_int < frame_end else 0;
   frame_count_new <= (frame_count_int + 1) when sync_received = '0' else 0;
   frame_period_cntr: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         frame_count_int <= 0;
      elsif(clk_i'event and clk_i = '1') then
         if(enable_counters = '1') then
            frame_count_int <= frame_count_new;
         end if;
      end if;
   end process frame_period_cntr;

   row_count_new <= (row_count_int + 1) when row_count_int < (row_len_i-1) and sync_received = '0' else 0;
--   row_count_new <= (row_count_int + 1) when sync_received = '0' else 0;
   row_dwell_cntr: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         row_count_int <= 0;
      elsif(clk_i'event and clk_i = '1') then
         if(enable_counters = '1') then
            row_count_int <= row_count_new;
         end if;
      end if;
   end process row_dwell_cntr;

      
--   -- This is pointless now that the frame_timing block resynchronizes on every sync pulse.
--   clock_err_reg : reg
--      generic map(
--         WIDTH       => 32
--      )
--      port map(
--         clk_i       => latch_error,
--         rst_i       => frame_rst,
--         ena_i       => '1',
--         reg_i       => error_count,
--         reg_o       => clk_error
--      );

--   error_count <= conv_std_logic_vector(frame_count_new, 32);
--   counter_rst <= '1' when wait_for_sync = '1' else '0';
--   frame_rst   <= '1' when resync_req_i = '1' else '0';

   -----------------------
   -- Frame-timing signals
   -----------------------
   -- The persistence of the last restart_frame signal is only for as long as the next one is not received.
   -- So I can send initialize window signals whenever I want to!.
   
   -- There are two situations in which the intialize_window should be asserted:
   -- 1- After a resync
   -- 2- After changing flux_loop parameters   
   
--   restart_frame_aligned      <= '1' when frame_count_int = frame_end else '0';
--   restart_frame_aligned      <= sync_received;
   restart_frame_1row_prev_o  <= '1' when frame_count_int = end_of_frame_minus_1row else '0';
   restart_frame_aligned_o    <= sync_received;
   restart_frame_1row_post_o  <= '1' when frame_count_int = end_of_frame_plus_1row else '0';
   
   -- The bias card DACs begin to be updated approximately 6 cycles after update_bias_o is asserted.
   -- The length of time required to update all 32 flux_feedback values on the bias card is longer than one row dwell period.
   update_bias_o              <= '1' when frame_count_int = UPDATE_BIAS else '0';

   -- row_switch_o is pulsed on the last clock cycle of every 
   row_switch_o               <= '1' when row_count_int = row_len_i - 1 or sync_received = '1' else '0';
   
   -- dac_dat_en_o has to be enabled on the clock cycle before the feedback begins, and lasts until the end of the row for safety reasons
   -- the dac_dat_en_o line is taken notice of after 6 clock cycle have elapsed on a new row.
   dac_dat_en_o               <= '1' when row_count_int >= feedback_delay_i - 1 else '0';
   
   -- adc_coadd_en_o has to be enabled on the same clock cycle that sampling begins, and has to be disabled on the same clock cycle when sampling finishes.  
   -- This is possible because of the 4-cycle latency in the ADCs
   adc_coadd_en_o             <= '1' when row_count_int >= sample_delay_i and row_count_int <= sample_delay_i + sample_num_i - 1 and row_count_int <= row_len_i-1 else '0';
   
   -- row_en_o has to be enabled on the clock cycle before the row is to be activated, and has to be disabled on the clock cycle before the row is to be deactivated
   -- row_en_o is only taken notice of a minimum of 3 clock cycles after a row_switch, to allow the ac_dac_ctrl_core time to preload the new value.
--   address_on_delay           <= MIN_ADDRESS_ON_DELAY when address_on_delay_i < MIN_ADDRESS_ON_DELAY else address_on_delay_i;
   row_en_o                   <= '1' when row_count_int >= address_on_delay_i-ONE_CYCLE_LATENCY and row_count_int <= row_len_i-1-ONE_CYCLE_LATENCY else '0';
   -----------------------
      
   init_win_state_FF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         current_init_win_state <= INIT_OFF;
      elsif(clk_i'event and clk_i = '1') then
         current_init_win_state <= next_init_win_state;
      end if;
   end process init_win_state_FF;

   init_win_state_NS: process(current_init_win_state, sync_received, init_window_req_i)
   begin
      next_init_win_state <= current_init_win_state;

      case current_init_win_state is
         when SET =>
            next_init_win_state <= SET_HOLD;
         when SET_HOLD =>
            if(sync_received = '1') then
               next_init_win_state <= INIT_ON;
            end if;
         when INIT_ON =>
            next_init_win_state <= INIT_HOLD;
         when INIT_HOLD =>
            if(sync_received = '1') then
               next_init_win_state <= INIT_OFF;
            end if;               
         when INIT_OFF =>
            if(init_window_req_i = '1') then
               if(sync_received = '1') then
                  next_init_win_state <= SET;
               else
                  next_init_win_state <= SET_HOLD;
               end if;
            end if;               
         when others =>
            next_init_win_state <= INIT_OFF;
      end case;
   end process init_win_state_NS;
   
   init_win_state_out: process(current_init_win_state, init_window_req_i)
   begin
      initialize_window_o <= '0';
      init_window_ack_o   <= '0';
      
      case current_init_win_state is
         when SET =>

         when SET_HOLD =>

         when INIT_ON =>
            initialize_window_o <= '1';
            if(init_window_req_i = '1') then
               init_window_ack_o <= '1';
            end if;

         when INIT_HOLD =>
            initialize_window_o <= '1';

         when INIT_OFF =>

         when others =>
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
   state_FF: process(clk_i, resync_req_i)
   begin
      if(resync_req_i = '1') then
         current_state <= IDLE;
         enable_counters <= '0';
         
      elsif(clk_i'event and clk_i = '1') then
         current_state <= next_state;
         
         if(enable_counters = '0') then
            if(sync_received = '1') then
               enable_counters <= '1';
            end if;
         end if;
         
      end if;
   end process state_FF;

   state_NS: process(current_state, sync_i)
   begin
      next_state <= current_state;
      case current_state is
         when IDLE =>
            if(sync_i = SYNC_PULSE_BIT0) then
               next_state <= GOT_BIT0;
            else
               next_state <= IDLE;
            end if;
         when GOT_BIT0 =>
            if(sync_i = SYNC_PULSE_BIT1) then
               next_state <= GOT_BIT1;
            else
               next_state <= IDLE;
            end if;
         when GOT_BIT1 =>
            if(sync_i = SYNC_PULSE_BIT2) then
               next_state <= GOT_BIT2;
            else
               next_state <= IDLE;
            end if;
         when GOT_BIT2 =>
            if(sync_i = SYNC_PULSE_BIT3) then
               next_state <= GOT_SYNC;
            else
               next_state <= IDLE;
            end if;
         when GOT_SYNC =>
            next_state <= IDLE;
         when others =>
      end case;
   end process state_NS;
   
   state_out: process(current_state)
   begin
      sync_received <= '0';
      case current_state is
         when IDLE =>
         when GOT_BIT0 =>
         when GOT_BIT1 =>
         when GOT_BIT2 =>
         when GOT_BIT3 =>
         when GOT_SYNC =>
            sync_received <= '1';
         when others =>
      end case;
   end process state_out;

--   state_NS: process(current_state, sync_i)
--   begin
--      next_state <= current_state;
--      
--      case current_state is
--         when WAIT_FRM_RST =>
--            if (sync_i = '1') then
--               next_state <= COUNT_UP;
--            else
--               next_state <= WAIT_FRM_RST;
--            end if;                  
--         when COUNT_UP =>
--            if (sync_i = '1') then
--               next_state <= GOT_SYNC;
--            else
--               next_state <= COUNT_UP;
--            end if;
--         when GOT_SYNC =>
--            next_state <= COUNT_UP;
--         when others =>
--            next_state <= WAIT_FRM_RST;
--      end case;
--   end process state_NS;
--   
--   state_out: process(current_state, sync_i)
--   begin
--      case current_state is
--         when WAIT_FRM_RST =>
--            latch_error <= '0';
--            if(sync_i = '1') then
--               wait_for_sync <= '1';
--            else
--               wait_for_sync <= '0';
--            end if;
--         when COUNT_UP =>
--            latch_error <= '0';
--            wait_for_sync <= '0';
--         when GOT_SYNC =>
--            latch_error <= '1';
--            wait_for_sync <= '0';
--         when others =>
--            latch_error <= '0';
--            wait_for_sync <= '0';
--      end case;
--   end process state_out;

end beh;