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
-- $Id: frame_timing_core.vhd,v 1.19 2013/05/31 19:54:17 mandana Exp $
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
-- Revision 1.19  2013/05/31 19:54:17  mandana
-- fixed the combinational loop for servo_rst_sync_count
--
-- Revision 1.18  2013/05/16 22:43:57  mandana
-- servo_rst_arm parameter is added to generate a servo_rst_window for the rest of the system
--
-- Revision 1.17  2011-05-11 21:28:49  bburger
-- BB:  Corrected a timing comment
--
-- Revision 1.16  2010/06/01 21:10:08  mandana
-- update_bias _o is now asserted certain clock cycles prior to row switch
--
-- Revision 1.15  2009/09/14 20:02:19  bburger
-- BB: added the row_count_o interface for the Address Card row-specific BIAS_START command
--
-- Revision 1.14  2009/03/19 20:15:51  bburger
-- *** empty log message ***
--
-- Revision 1.13  2008/06/17 18:46:30  bburger
-- BB:  Added the error_o interface which is asserted if there is a slip in the timing of sync pulses, caused by missing a sync pulse, or receiving a spurrious one.
--
-- Revision 1.13  2008/05/29 21:22:01  bburger
-- BB:  Added the error_o interface which is asserted if there is a slip in the timing of sync pulses, caused by missing a sync pulse, or receiving a spurrious one.
--
-- Revision 1.12  2006/03/22 19:25:12  mandana
-- moved constant definitions from sync_gen_pack to frame_timing_pack
--
-- Revision 1.11  2006/03/08 22:57:22  bburger
-- Bryce:
-- - removed component delclarations from frame_timing pack files
-- - added sync_num_o interfaces to frame_timing and frame_timing_core
-- - added a counter to frame_timing_core for outputting the sync_num_o
--
-- Revision 1.10  2006/02/09 20:32:59  bburger
-- Bryce:
-- - Added a fltr_rst_o output signal from the frame_timing block
-- - Adjusted the top-levels of each card to reflect the frame_timing interface change
--
-- Revision 1.9  2005/05/19 22:58:11  bburger
-- Bryce:  v01010018
--
-- Revision 1.8  2005/05/06 20:02:31  bburger
-- Bryce:  Added a 50MHz clock that is 180 degrees out of phase with clk_i.
-- This clk_n_i signal is used for sampling the sync_i line during the middle of the pulse, to avoid problems associated with sampling on the edges.
--
-- Revision 1.7  2005/04/19 19:11:41  bburger
-- Bryce:  added syncronizer to the sync_i to remove the possibility of metastbility in the fsm
--
-- Revision 1.6  2005/02/17 22:42:12  bburger
-- Bryce:  changes to synchronization in the MCE in response to two problems
-- - a rising edge on the sync line during configuration
-- - an errant pulse on the restart_frame_1row_post_o from frame_timing block
--
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
use ieee.std_logic_unsigned.all;

library sys_param;
use sys_param.wishbone_pack.all;

library work;
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
      fltr_rst_o                 : out std_logic;
      servo_rst_window_o         : out std_logic;
      sync_num_o                 : out std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);

      -- Address Card interface
      row_count_o                : out std_logic_vector(ROW_COUNT_WIDTH-1 downto 0);
      row_switch_o               : out std_logic;
      row_en_o                   : out std_logic;

      -- Bias Card interface
      update_bias_o              : out std_logic;
      flux_fb_dly_o              : out std_logic;

      -- Wishbone interface
      row_len_i                  : in integer; -- not used yet
      num_rows_i                 : in integer; -- not used yet
      sample_delay_i             : in integer;
      sample_num_i               : in integer;
      feedback_delay_i           : in integer;
      address_on_delay_i         : in integer;
      flux_fb_dly_i              : in integer;
      resync_req_i               : in std_logic;
      resync_ack_o               : out std_logic; -- not used yet
      init_window_req_i          : in std_logic;
      init_window_ack_o          : out std_logic; -- not used yet
      fltr_rst_ack_o             : out std_logic;
      fltr_rst_req_i             : in std_logic;
      servo_rst_req_i            : in std_logic;
      servo_rst_ack_o            : out std_logic; -- not used yet

      -- Debug interface
      error_o                    : out std_logic;

      -- Global signals
      clk_i                      : in std_logic;
      clk_n_i                    : in std_logic;
      rst_i                      : in std_logic;
      sync_i                     : in std_logic
   );
end frame_timing_core;

architecture beh of frame_timing_core is

   constant ONE_CYCLE_LATENCY     : integer := 1;
   constant TWO_CYCLE_LATENCY     : integer := 2;

   -- type INTEGER has a maximum range of –2147483647 (i.e. -[2^31 - 1]) to 2147483647 (2^31 - 1)
   -- This is the length of a frame (row_len * num_rows)
   signal frame_count_int         : integer range 0 to 2147483647;
   signal frame_count_new         : integer range 0 to 2147483647; 
   signal servo_rst_sync_count    : integer range 0 to 3;
   signal servo_rst_count_inc     : std_logic;
   signal servo_rst_count_clr     : std_logic;   
   
   -- These are one-behind and two_behind versions of the variables above.
   signal frame_count_a           : integer range 0 to 2147483647;
   signal frame_count_b           : integer range 0 to 2147483647;
   
   -- This counts the length of a row (row_len)
   signal row_count_int           : integer range 0 to (2**ROW_COUNT_WIDTH)-1;
   signal row_count_new           : integer range 0 to (2**ROW_COUNT_WIDTH)-1;
   
   signal enable_counters         : std_logic;
   signal sync_received           : std_logic;

   signal sync_count       : std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);
   signal sync_count_new   : std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);

   signal end_of_frame_minus_1row : integer;
   signal end_of_frame_plus_1row  : integer;

   signal sync_temp               : std_logic;
   signal sync                    : std_logic;

   type states is (IDLE, GOT_BIT0, GOT_BIT1, GOT_BIT2, GOT_BIT3, GOT_SYNC, WAIT_FRM_RST);
   signal current_state, next_state : states;

   type init_win_states is (INIT_OFF, INIT_ON, INIT_HOLD, FLTR_RST_ON, FLTR_RST_HOLD, SERVO_RST_ON, SERVO_RST_HOLD,SET, SET_HOLD);
   signal current_init_win_state, next_init_win_state : init_win_states;

begin

   sync_num_o     <= sync_count;
   sync_count_new <= sync_count + "00000000000000000000000000000001";
   sync_cntr: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         sync_count <= (others => '0');
      elsif(clk_i'event and clk_i = '1') then
         if(sync_received = '1') then
            sync_count <= sync_count_new;
         end if;
      end if;
   end process sync_cntr;

   end_of_frame_minus_1row <= (num_rows_i*row_len_i)-row_len_i-1;
   end_of_frame_plus_1row <= row_len_i-1;

   -- Temporary
   resync_ack_o <= '0';

   error_o <= '0' when frame_count_a = frame_count_b else '1';
   frame_count_new <= (frame_count_int + 1) when sync_received = '0' else 0;
   frame_period_cntr: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         frame_count_int <= 0;
         frame_count_a   <= 0;
         frame_count_b   <= 0;
      elsif(clk_i'event and clk_i = '1') then
         if(enable_counters = '1') then
            frame_count_int <= frame_count_new;
         end if;

         if(sync_received = '1') then
            frame_count_a   <= frame_count_int;
            frame_count_b   <= frame_count_a;
         end if;
      end if;
   end process frame_period_cntr;

   row_count_o <= std_logic_vector(conv_signed(row_count_int, 16));
   row_count_new <= (row_count_int + 1) when row_count_int < (row_len_i-1) and sync_received = '0' else 0;
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

   servo_rst_sync_cntr: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         servo_rst_sync_count <= 0;
      elsif(clk_i'event and clk_i = '1') then
         if(servo_rst_count_clr = '1') then
            servo_rst_sync_count <= 0;
         elsif (servo_rst_count_inc = '1') then
            servo_rst_sync_count <= servo_rst_sync_count + 1;
         end if;
      end if;
   end process servo_rst_sync_cntr;

   -----------------------
   -- Frame-timing signals
   -----------------------
   -- The persistence of the last restart_frame signal is only for as long as the next one is not received.
   -- So I can send initialize window signals whenever I want to!.

   -- There are two situations in which the intialize_window should be asserted:
   -- 1- After a resync
   -- 2- After changing flux_loop parameters
   restart_frame_1row_prev_o  <= '1' when frame_count_int = end_of_frame_minus_1row else '0';
   restart_frame_aligned_o    <= sync_received;
   restart_frame_1row_post_o  <= '1' when frame_count_int = end_of_frame_plus_1row else '0';

   -- The bias card DACs begin to be updated 10 cycles after update_bias_o is asserted.
   -- The length of time required to update all 32 flux_feedback values on the bias card is longer than one row dwell period.
   update_bias_o              <= '1' when row_count_int = flux_fb_dly_i + 1 else '0'; -- row_len_i - UPDATE_BIAS else '0';
   flux_fb_dly_o              <= '1' when row_count_int = flux_fb_dly_i else '0';

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

   init_win_state_NS: process(current_init_win_state, sync_received, init_window_req_i, fltr_rst_req_i, servo_rst_req_i, servo_rst_sync_count)
   begin
      next_init_win_state <= current_init_win_state;

      case current_init_win_state is
         when SET =>
            next_init_win_state <= SET_HOLD;

         when SET_HOLD =>
            if(sync_received = '1') then
               -- Will service an init_window request first, and then a fltr_rst request
               if(init_window_req_i = '1') then
                  next_init_win_state <= INIT_ON;
               elsif(fltr_rst_req_i = '1') then
                  next_init_win_state <= FLTR_RST_ON;
               elsif(servo_rst_req_i = '1') then
                  next_init_win_state <= SERVO_RST_ON;
                  
               end if;
            end if;

         when INIT_ON =>
            next_init_win_state <= INIT_HOLD;

         when INIT_HOLD =>
            if(sync_received = '1') then
               next_init_win_state <= INIT_OFF;
            end if;

         when FLTR_RST_ON =>
            next_init_win_state <= FLTR_RST_HOLD;

         when FLTR_RST_HOLD =>
            if(sync_received = '1') then
               next_init_win_state <= INIT_OFF;
            end if;

         when SERVO_RST_ON =>
            next_init_win_state <= SERVO_RST_HOLD;

         when SERVO_RST_HOLD =>
            if (sync_received = '1' and servo_rst_sync_count = 1) then
               next_init_win_state <= INIT_OFF;
            end if;

         when INIT_OFF =>
            if(init_window_req_i = '1' or fltr_rst_req_i = '1' or servo_rst_req_i = '1') then
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

   init_win_state_out: process(current_init_win_state, sync_received)
   begin
      initialize_window_o <= '0';
      init_window_ack_o   <= '0';
      fltr_rst_o          <= '0';
      fltr_rst_ack_o      <= '0';
      servo_rst_window_o  <= '0';
      servo_rst_ack_o     <= '0';
      servo_rst_count_inc <= '0';
      servo_rst_count_clr <= '1';
      
      case current_init_win_state is
         when SET => 

         when SET_HOLD =>

         when INIT_ON =>
            initialize_window_o <= '1';

         when INIT_HOLD =>
            initialize_window_o <= '1';

            if(sync_received = '1') then
               init_window_ack_o <= '1';
            end if;

         when FLTR_RST_ON =>
            fltr_rst_o <= '1';

         when FLTR_RST_HOLD =>
            fltr_rst_o <= '1';

            if(sync_received = '1') then
               fltr_rst_ack_o    <= '1';
            end if;

         when SERVO_RST_ON =>
            fltr_rst_o <= '1';
            servo_rst_window_o <= '1';

         when SERVO_RST_HOLD =>
            servo_rst_window_o <= '1';
            servo_rst_count_clr <= '0';
            if(sync_received = '1') then
               servo_rst_ack_o      <= '1';
               servo_rst_count_inc <= '1';
            end if;

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
   state_FF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         current_state <= IDLE;
         enable_counters <= '0';

      elsif(clk_i'event and clk_i = '1') then
         current_state <= next_state;

         if(resync_req_i = '1') then
            current_state <= IDLE;
            enable_counters <= '0';
         elsif(sync_received = '1') then
            enable_counters <= '1';
         end if;

      end if;
   end process state_FF;

   state_NS: process(current_state, sync)
   begin
      next_state <= current_state;
      case current_state is
         when IDLE =>
            if(sync = SYNC_PULSE_BIT0) then
               next_state <= GOT_BIT0;
            else
               next_state <= IDLE;
            end if;
         when GOT_BIT0 =>
            if(sync = SYNC_PULSE_BIT1) then
               next_state <= GOT_BIT1;
            else
               next_state <= IDLE;
            end if;
         when GOT_BIT1 =>
            if(sync = SYNC_PULSE_BIT2) then
               next_state <= GOT_BIT2;
            else
               next_state <= IDLE;
            end if;
         when GOT_BIT2 =>
            if(sync = SYNC_PULSE_BIT3) then
               next_state <= GOT_SYNC;
            else
               next_state <= IDLE;
            end if;
         when GOT_SYNC =>
            next_state <= IDLE;
         when others =>
            next_state <= IDLE;
      end case;
   end process state_NS;

   state_out: process(current_state)
   begin
      sync_received   <= '0';
      case current_state is
         when IDLE =>
         when GOT_BIT0 =>
         when GOT_BIT1 =>
         when GOT_BIT2 =>
         when GOT_BIT3 =>
         when GOT_SYNC =>
            sync_received <= '1';
         when others => NULL;
      end case;
   end process state_out;

   -- double synchronizer for sync_i:
   process(rst_i, clk_n_i)
   begin
      if(rst_i = '1') then
         sync_temp  <= '0';
      elsif(clk_n_i'event and clk_n_i = '1') then
         sync_temp  <= sync_i;
      end if;
   end process;

   process(rst_i, clk_i)
   begin
      if(rst_i = '1') then
         sync       <= '0';
      elsif(clk_i'event and clk_i = '1') then
         sync       <= sync_temp;
      end if;
   end process;



end beh;