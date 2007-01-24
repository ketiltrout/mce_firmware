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
-- Project:       SCUBA-2
-- Author:        Bryce Burger
--
-- Organisation:  UBC
--
-- Description: Block to generate global clock card reset on the receipt of a
-- 'special character' byte transmitted by the Linux PC.
--
-- Revision history:
-- <date $Date: 2005/03/09 18:08:23 $> - <text> - <initials $Author: bburger $>
--
-- $Log: cc_reset.vhd,v $
-- Revision 1.2  2005/03/09 18:08:23  bburger
-- mohsen:  registered and widened TTL reset pulse (BClr)
--
-- Revision 1.1  2005/01/13 16:32:29  dca
-- Initial Versions
--
--
-----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library work;
use work.cc_reset_pack.all;

library components;
use components.component_pack.all;

entity cc_reset is
   port(
      clk_i        : in  std_logic;
      brst_event_o : out std_logic;
      brst_ack_i   : in  std_logic;
      bclr_event_o : out std_logic;
      bclr_ack_i   : in  std_logic;
      rst_n_i      : in  std_logic; -- rst_n_i is an input to the FPGA that is dependent on the 1.5V level, the 3.3V level and BRst line.
      nRx_rdy_i    : in  std_logic;                     -- hotlink receiver data ready (active low)
      rsc_nRd_i    : in  std_logic;                     -- hotlink receiver special character/(not) Data
      rso_i        : in  std_logic;                     -- hotlink receiver status out
      rvs_i        : in  std_logic;                     -- hotlink receiver violation symbol detected
      rx_data_i    : in  std_logic_vector (7 downto 0); -- hotlink receiver data byte
      reset_o      : out std_logic                      -- cc firmware reset
   );

end cc_reset;

architecture rtl of cc_reset is

   signal start_reset     : std_logic;
   signal done_reset      : std_logic;

   signal timeout_clr     : std_logic;
   signal timeout_count   : integer;

   signal reset_count     : integer := 0;
   signal reset_count_new : integer;

   signal brst_event      : std_logic;
   signal bclr_event      : std_logic;

   signal brst1           : std_logic := '0';
   signal brst2           : std_logic := '0';
   signal brst3           : std_logic := '0';
   signal brst4           : std_logic := '0';
   signal brst5           : std_logic := '0';

   -- FSM states:
   type states is (BRST_WAIT, BRST, BCLR, WAIT_FOR_RESET, ASSERT_BCLR, TIMER_EXPIRED);
   signal current_state : states;
   signal next_state    : states;

   type bclr_states is (BCLR_NOW, WAIT_FOR_ACK, IDLE);
   signal current_bclr_state : bclr_states;
   signal next_bclr_state    : bclr_states;

   type brst_states is (BRST_NOW, WAIT_FOR_ACK, IDLE);
   signal current_brst_state : brst_states;
   signal next_brst_state    : brst_states;

begin

   --------------------------------------------------------------------------------------------------------------------
   -- Notes:
   -- A BRst initiates a reconfiguration of the sub-rack
   -- A flag should be set in the first reply packet after a Brst, and after that ignored
   -- Register whether a BRst flag has been sent out, and one one has, do not send another for the life time of that BRst period
   -- A BClr clears all the registers in the MCE
   -- A flag should be set in the frist reply packet after a BClr.
   -- Register the previous reset number and update it to the current one after the flag is issued
   -- rst_n_i is the same as BClr but is hardware initiated by a push button that is wired to pin AC9
   -- rst_n_i should have the same effect as BClr, and thus should exercise reset_o.
   --------------------------------------------------------------------------------------------------------------------

   --------------------------------------------------------------------------------------------------------------------
   -- A register that detects BRst pulses
   --------------------------------------------------------------------------------------------------------------------
   brst_reg: process(clk_i)
   begin
      if(clk_i'event and clk_i = '1') then
         brst1 <= '1';
         brst2 <= brst1;
         brst3 <= brst2;
         brst4 <= brst3;
         brst5 <= brst4;
      end if;
   end process brst_reg;

   --------------------------------------------------------------------------------------------------------------------
   -- Timer for asserting the BClr signal for a specified period of time
   --------------------------------------------------------------------------------------------------------------------
   timeout_timer : us_timer
   port map(
      clk           => clk_i,
      timer_reset_i => timeout_clr,
      timer_count_o => timeout_count
   );

   --------------------------------------------------------------------------------------------------------------------
   -- Counter for determining how many BClr's have occurred since the last reconfiguration
   --------------------------------------------------------------------------------------------------------------------
   reset_count_new <= reset_count + 1;
   reset_counter: process(clk_i, brst5)
   begin
      -- Neither rst_n_i (BRst, 1.5V monitor, 3.3V monitor) nor BClr should reset this register.
      if(brst5 = '0') then
         reset_count <= 0;
      elsif(clk_i'event and clk_i = '1') then
         if(done_reset = '1') then
            reset_count <= reset_count_new;
         end if;
      end if;
   end process reset_counter;

   --------------------------------------------------------------------------------------------------------------------
   -- FSM for exercising the counters and registers above correctly
   -- The purpose of this FSM is to:
   -- 1- detect BClr commands from the fibre or on-board push button
   -- 2- assert the BClr signal on the Bus Backplane to all other cards for a fixed period (hard coded)
   -- 3- exercise the counter above to record the occurence of BClr's and report the occurrences out.
   --------------------------------------------------------------------------------------------------------------------
   start_reset <= '1' when (nRx_rdy_i = '0' and rsc_nRd_i = '1' and rso_i = '1' and rvs_i = '0' and rx_data_i = SPEC_CHAR_RESET) else '0';

   -- State forwarder
   process(clk_i, brst5)
   begin
      -- Neither rst_n_i (BRst, 1.5V monitor, 3.3V monitor) nor BClr should reset this register.
      if(brst5 = '0') then
         current_state <= BRST_WAIT;
      elsif(clk_i'event and clk_i = '1') then
         current_state <= next_state;
      end if;
   end process;

   -- Transition table
   process(current_state, timeout_count, rst_n_i, start_reset)
   begin
      -- Default assignments
      next_state <= current_state;

      case current_state is
         when BRST_WAIT =>
            next_state <= BRST;

         when BRST =>
            -- After a BRST, let's assert BClr just to be sure all the registers are in their default states.
            next_state <= ASSERT_BCLR;

         when BCLR =>
            next_state <= ASSERT_BCLR;

         when ASSERT_BCLR =>
            if(timeout_count >= RESET_HOLD_TIME_US) then
               next_state <= TIMER_EXPIRED;
            end if;

         when TIMER_EXPIRED =>
            next_state <= WAIT_FOR_RESET;

         when WAIT_FOR_RESET =>
            -- Wait here until the next asynchronous BRST/ BCLR resets the state machine.
            if(start_reset = '1' or rst_n_i = '0') then
               next_state <= BCLR;
            end if;

         when others =>
            next_state <= BRST;
      end case;
   end process;

   -- Output states
   process(current_state)
   begin
      -- Default assignments
      timeout_clr     <= '1';
      reset_o         <= '0';
      done_reset      <= '0';
      brst_event      <= '0';
      bclr_event      <= '0';

      case current_state is
         when BRST_WAIT =>

         when BRST =>
            brst_event      <= '1';
            timeout_clr     <= '0';
            reset_o         <= '1';

         when BCLR =>
            bclr_event      <= '1';
            timeout_clr     <= '0';
            reset_o         <= '1';

         when ASSERT_BCLR =>
            timeout_clr     <= '0';
            reset_o         <= '1';

         when TIMER_EXPIRED =>
            done_reset      <= '1';

         when WAIT_FOR_RESET =>

         when others =>

      end case;
   end process;

   --------------------------------------------------------------------------------------------------------------------
   -- FSM for notifying the system of BClr's
   --------------------------------------------------------------------------------------------------------------------
   -- State forwarder
   process(clk_i, brst5)
   begin
      -- Neither rst_n_i (BRst, 1.5V monitor, 3.3V monitor) nor BClr should reset this register.
      if(brst5 = '0') then
         current_bclr_state <= IDLE;
      elsif(clk_i'event and clk_i = '1') then
         current_bclr_state <= next_bclr_state;
      end if;
   end process;

   -- Transition table
   process(current_bclr_state, bclr_event, done_reset, bclr_ack_i)
   begin
      -- Default assignments
      next_bclr_state <= current_bclr_state;

      case current_bclr_state is
         when IDLE =>
            if(bclr_event = '1') then
               next_bclr_state <= BCLR_NOW;
            end if;

         when BCLR_NOW =>
            if(done_reset = '1') then
               next_bclr_state <= WAIT_FOR_ACK;
            end if;

         when WAIT_FOR_ACK =>
            if(bclr_ack_i = '1') then
               next_bclr_state <= IDLE;
            end if;

         when others =>
            next_bclr_state <= IDLE;

      end case;
   end process;

   -- Output states
   process(current_bclr_state)
   begin
      -- Default assignments
      bclr_event_o <= '0';

      case current_bclr_state is
         when IDLE =>

         when BCLR_NOW =>

         when WAIT_FOR_ACK =>
            bclr_event_o <= '1';

         when others =>

      end case;
   end process;


   --------------------------------------------------------------------------------------------------------------------
   -- FSM for notifying the system of BRst's
   --------------------------------------------------------------------------------------------------------------------
   -- State forwarder
   process(clk_i, brst5)
   begin
      -- Neither rst_n_i (BRst, 1.5V monitor, 3.3V monitor) nor BClr should reset this register.
      if(brst5 = '0') then
         current_brst_state <= IDLE;
      elsif(clk_i'event and clk_i = '1') then
         current_brst_state <= next_brst_state;
      end if;
   end process;

   -- Transition table
   process(current_brst_state, brst_event, done_reset, brst_ack_i)
   begin
      -- Default assignments
      next_brst_state <= current_brst_state;

      case current_brst_state is
         when IDLE =>
            if(brst_event = '1') then
               next_brst_state <= BRST_NOW;
            end if;

         when BRST_NOW =>
            if(done_reset = '1') then
               next_brst_state <= WAIT_FOR_ACK;
            end if;

         when WAIT_FOR_ACK =>
            if(brst_ack_i = '1') then
               next_brst_state <= IDLE;
            end if;

         when others =>
            next_brst_state <= IDLE;

      end case;
   end process;

   -- Output states
   process(current_brst_state)
   begin
      -- Default assignments
      brst_event_o <= '0';

      case current_brst_state is
         when IDLE =>

         when BRST_NOW =>

         when WAIT_FOR_ACK =>
            brst_event_o <= '1';

         when others =>

      end case;
   end process;


end rtl;