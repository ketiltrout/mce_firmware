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
-- <date $Date: 2007/01/24 01:19:41 $> - <text> - <initials $Author: bburger $>
--
-- $Log: cc_reset.vhd,v $
-- Revision 1.3  2007/01/24 01:19:41  bburger
-- Bryce:  Added a timer to extend the BClr pulse over the Bus Backplane to all the whole subrak to be reset.  Also added FSMs for recording BRst and BClr events.
--
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

library sys_param;
use sys_param.wishbone_pack.all;

library work;
use work.cc_reset_pack.all;

library components;
use components.component_pack.all;

entity cc_reset is
   port(
      clk_i            : in std_logic;
      fibre_clkr_i     : in std_logic;

      -- Header Signals
      brst_event_o     : out std_logic;
      brst_ack_i       : in std_logic;
      mce_bclr_event_o : out std_logic;
      mce_bclr_ack_i   : in std_logic;
      cc_bclr_event_o  : out std_logic;
      cc_bclr_ack_i    : in std_logic;

      -- Fibre Signals
      nRx_rdy_i        : in std_logic;                     -- hotlink receiver data ready (active low)
      rsc_nRd_i        : in std_logic;                     -- hotlink receiver special character/(not) Data
      rso_i            : in std_logic;                     -- hotlink receiver status out
      rvs_i            : in std_logic;                     -- hotlink receiver violation symbol detected
      rx_data_i        : in std_logic_vector (7 downto 0); -- hotlink receiver data byte

      -- Register Clear Signals
      ext_rst_n_i      : in std_logic;
      cc_bclr_o        : out std_logic;
      mce_bclr_o       : out std_logic;

      -- Wishbone Interface:
      dat_i            : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      addr_i           : in std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
      tga_i            : in std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
      we_i             : in std_logic;
      stb_i            : in std_logic;
      cyc_i            : in std_logic;
      dat_o            : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      ack_o            : out std_logic
   );
end cc_reset;

architecture rtl of cc_reset is

   signal startmce_brst   : std_logic;
   signal start_cc_bclr   : std_logic;
   signal start_mce_bclr  : std_logic;
--   signal done_reset     : std_logic;
--   signal done_reset2     : std_logic;

   signal done_mce_bclr1  : std_logic;
   signal done_mce_bclr2  : std_logic;
   signal done_cc_bclr1  : std_logic;
   signal done_cc_bclr2  : std_logic;
   signal done_brst        : std_logic;

   signal timeout_clr1     : std_logic;
   signal timeout_clr2     : std_logic;
   signal timeout_count1   : integer;
   signal timeout_count2   : integer;

   signal reset_count     : integer := 0;
   signal reset_count_new : integer;

   signal brst_event      : std_logic;
   signal cc_bclr_event1   : std_logic;
   signal cc_bclr_event2   : std_logic;
   signal mce_bclr_event1  : std_logic;
   signal mce_bclr_event2  : std_logic;

--   signal rst             : std_logic;
   signal cc_bclr         : std_logic;
--   signal mce_bclr        : std_logic;

   signal brst1           : std_logic := '0';
   signal brst2           : std_logic := '0';
   signal brst3           : std_logic := '0';
   signal brst4           : std_logic := '0';
   signal brst5           : std_logic := '0';

   -- FSM inputs
   signal wr_cmd          : std_logic;
   signal rd_cmd          : std_logic;

   -- Register signals
   signal mce_bclr_wren    : std_logic;
   signal mce_bclr1        : std_logic;
   signal mce_bclr2        : std_logic;
   signal cc_bclr_wren     : std_logic;
   --   signal mce_bclr_data    : std_logic_vector(WB_DATA_WIDTH-1 downto 0);

   -- FSM states:
   type states is (BRST_WAIT, FLAG_BRST, PREP_SUBRACK_BCLR, PREP_CLOCK_CARD_BCLR, ASSERT_SUBRACK_BCLR, ASSERT_SUBRACK_BCLR2,
      ASSERT_CLOCK_CARD_BCLR, DONE_CLOCK_CARD_BCLR, DONE_SUBRACK_BCLR, DONE_SUBRACK_BCLR2, WAIT_FOR_RESET, ASSERT_BCLR, TIMER_EXPIRED);
   signal current_state  : states;
   signal next_state     : states;

   type states2 is (IDLE, PREP_SUBRACK_BCLR, ASSERT_SUBRACK_BCLR, DONE_SUBRACK_BCLR);
   signal current_state2 : states2;
   signal next_state2    : states2;

   type mce_bclr_states is (MCE_BCLR_NOW, WAIT_FOR_ACK, IDLE);
   signal current_mce_bclr_state : mce_bclr_states;
   signal next_mce_bclr_state    : mce_bclr_states;

   type cc_bclr_states is (CC_BCLR_NOW, WAIT_FOR_ACK, IDLE);
   signal current_cc_bclr_state : cc_bclr_states;
   signal next_cc_bclr_state    : cc_bclr_states;

   type brst_states is (BRST_NOW, WAIT_FOR_ACK, IDLE);
   signal current_brst_state : brst_states;
   signal next_brst_state    : brst_states;

   -- WBS states:
   type wbs_states is (IDLE, WR, RD);
   signal current_wbs_state   : wbs_states;
   signal next_wbs_state      : wbs_states;

begin

   cc_bclr_o  <= (not ext_rst_n_i) or cc_bclr;
   mce_bclr_o <= mce_bclr1 or mce_bclr2;

   --------------------------------------------------------------------------------------------------------------------
   -- Notes:
   -- A BRst initiates a reconfiguration of the sub-rack
   -- A flag should be set in the first reply packet after a Brst, and after that ignored
   -- Register whether a BRst flag has been sent out, and one one has, do not send another for the life time of that BRst period
   -- A BClr clears all the registers in the MCE
   -- A flag should be set in the frist reply packet after a BClr.
   -- Register the previous reset number and update it to the current one after the flag is issued
   -- ext_rst_n_i is the same as BClr but is hardware initiated by a push button that is wired to pin AC9
   -- ext_rst_n_i should have the same effect as BClr, and thus should exercise cc_bclr_o.
   --------------------------------------------------------------------------------------------------------------------

   --------------------------------------------------------------------------------------------------------------------
   -- A register that detects BRst pulses in the Clock Cards Clock domain, after the PLL has locked.
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
   timeout_timer1 : us_timer
   port map(
      clk           => clk_i,
      timer_reset_i => timeout_clr1,
      timer_count_o => timeout_count1
   );

   --------------------------------------------------------------------------------------------------------------------
   -- Counter for determining how many BClr's have occurred since the last reconfiguration or BRST
   --------------------------------------------------------------------------------------------------------------------
--   reset_count_new <= reset_count + 1;
--   reset_counter: process(clk_i, brst5)
--   begin
--      -- Neither ext_rst_n_i (BRst, 1.5V monitor, 3.3V monitor) nor BClr should reset this register.
--      if(brst5 = '0') then
--         reset_count <= 0;
--      elsif(clk_i'event and clk_i = '1') then
--         if(done_reset = '1') then
--            reset_count <= reset_count_new;
--         end if;
--      end if;
--   end process reset_counter;

   --------------------------------------------------------------------------------------------------------------------
   -- Sniffer for special characters received over the fiber
   -- The sniffer runs off the fibre clock to make sure that it is functional even when the clock card clock source isn't
   -- This block of code will function even if the sync fibre (from which the clock card may be sourcing its clock from) is disconnected
   --------------------------------------------------------------------------------------------------------------------
   -- I have disabled the cc_bclr special character and reverted it back to the original mce_bclr
   start_cc_bclr <= '0';
   start_mce_bclr <= '1' when (nRx_rdy_i = '0' and rsc_nRd_i = '1' and rso_i = '1' and rvs_i = '0' and rx_data_i = SPEC_CHAR_RESET) else '0';

   timeout_timer2 : us_timer
   port map(
      clk           => fibre_clkr_i,
      timer_reset_i => timeout_clr2,
      timer_count_o => timeout_count2
   );

   -- State forwarder
   process(fibre_clkr_i, brst5)
   begin
      -- Neither ext_rst_n_i (BRst, 1.5V monitor, 3.3V monitor) nor BClr should reset this register.
      if(brst5 = '0') then
         current_state2 <= IDLE;
      elsif(fibre_clkr_i'event and fibre_clkr_i = '1') then
         current_state2 <= next_state2;
      end if;
   end process;

   -- Transition table
   process(current_state2, start_mce_bclr, timeout_count2)
   begin
      -- Default assignments
      next_state2 <= current_state2;

      case current_state2 is
         when IDLE =>
            if(start_mce_bclr = '1') then
               next_state2 <= PREP_SUBRACK_BCLR;
            end if;

         when PREP_SUBRACK_BCLR =>
            next_state2 <= ASSERT_SUBRACK_BCLR;

         when ASSERT_SUBRACK_BCLR =>
            -- The clock frequency of fibre_clkr_i is half that of clk_i, which is why we only wait RESET_HOLD_TIME_US/2
            if(timeout_count2 >= RESET_HOLD_TIME_US/2) then
               next_state2 <= DONE_SUBRACK_BCLR;
            end if;

         when DONE_SUBRACK_BCLR =>
            next_state2 <= IDLE;

         when others =>
            next_state2 <= IDLE;
      end case;
   end process;

   -- Output states
   process(current_state2)
   begin
      -- Default assignments
      mce_bclr2      <= '0';
      timeout_clr2   <= '1';

      done_mce_bclr2 <= '0';
      done_cc_bclr2  <= '0';

      mce_bclr_event2 <= '0';
      cc_bclr_event2  <= '0';

      case current_state2 is
         when IDLE =>

         when PREP_SUBRACK_BCLR =>
            mce_bclr2       <= '1';
            timeout_clr2    <= '0';
            mce_bclr_event2 <= '1';

         when ASSERT_SUBRACK_BCLR =>
            mce_bclr2       <= '1';
            timeout_clr2    <= '0';

         when DONE_SUBRACK_BCLR =>
            done_mce_bclr2  <= '1';

         when others =>

      end case;
   end process;

   --------------------------------------------------------------------------------------------------------------------
   -- FSM for exercising the counters and registers above correctly
   -- The purpose of this FSM is to:
   -- 1- detect BClr commands from the fibre or on-board push button
   -- 2- assert the BClr signal on the Bus Backplane to all other cards for a fixed period (hard coded)
   -- 3- exercise the counter above to record the occurence of BClr's and report the occurrences out.
   --------------------------------------------------------------------------------------------------------------------
   -- Brst cannot be triggered by the clock card.  A command must be sent to the PSUC
   startmce_brst <= '0';

   -- State forwarder
   process(clk_i, brst5)
   begin
      -- Neither ext_rst_n_i (BRst, 1.5V monitor, 3.3V monitor) nor BClr should reset this register.
      if(brst5 = '0') then
         current_state <= BRST_WAIT;
      elsif(clk_i'event and clk_i = '1') then
         current_state <= next_state;
      end if;
   end process;

   -- Transition table
   process(current_state, timeout_count1, ext_rst_n_i, mce_bclr_wren, cc_bclr_wren)
   begin
      -- Default assignments
      next_state <= current_state;

      case current_state is
         -- Hold in this state while a BRST is occurring
         when BRST_WAIT =>
            next_state <= FLAG_BRST;

         -- Increment the BRST counter
         when FLAG_BRST =>
            -- After a BRST, let's assert subrack BClr just to be sure all the registers are in their default states.
            next_state <= ASSERT_SUBRACK_BCLR2;

         when PREP_SUBRACK_BCLR =>
            next_state <= ASSERT_SUBRACK_BCLR;

         when ASSERT_SUBRACK_BCLR =>
            if(timeout_count1 >= RESET_HOLD_TIME_US) then
               next_state <= DONE_SUBRACK_BCLR;
            end if;

         when DONE_SUBRACK_BCLR =>
            next_state <= WAIT_FOR_RESET;

         when ASSERT_SUBRACK_BCLR2 =>
            if(timeout_count1 >= RESET_HOLD_TIME_US) then
               next_state <= DONE_SUBRACK_BCLR2;
            end if;

         when DONE_SUBRACK_BCLR2 =>
            next_state <= WAIT_FOR_RESET;

         when PREP_CLOCK_CARD_BCLR =>
            next_state <= ASSERT_CLOCK_CARD_BCLR;

         when ASSERT_CLOCK_CARD_BCLR =>
            if(timeout_count1 >= RESET_HOLD_TIME_US) then
               next_state <= DONE_CLOCK_CARD_BCLR;
            end if;

         when DONE_CLOCK_CARD_BCLR =>
            next_state <= WAIT_FOR_RESET;

         when WAIT_FOR_RESET =>
            -- Wait here until the next asynchronous BRST/ BCLR resets the state machine.
            -- if there is a cc bclr special character or a cc push button blr then
            if(cc_bclr_wren = '1' or ext_rst_n_i = '0') then
               next_state <= PREP_CLOCK_CARD_BCLR;
            -- if there is an mce_bclr special character or and mce push button bclr then
            elsif(mce_bclr_wren = '1') then
               next_state <= PREP_SUBRACK_BCLR;
            end if;

         when others =>
            next_state <= WAIT_FOR_RESET;
      end case;
   end process;

   -- Output states
   process(current_state)
   begin
      -- Default assignments
      timeout_clr1     <= '1';
      cc_bclr         <= '0';
      mce_bclr1       <= '0';

--      done_reset      <= '0';
      done_mce_bclr1  <= '0';
      done_cc_bclr1   <= '0';
      done_brst       <= '0';

      brst_event      <= '0';
      cc_bclr_event1   <= '0';
      mce_bclr_event1  <= '0';

      case current_state is
         when BRST_WAIT =>

         when FLAG_BRST =>
            brst_event      <= '1';
            timeout_clr1     <= '0';
            cc_bclr         <= '1';

         when PREP_SUBRACK_BCLR =>
            mce_bclr_event1  <= '1';
            timeout_clr1     <= '0';
            mce_bclr1       <= '1';

         when ASSERT_SUBRACK_BCLR =>
            timeout_clr1     <= '0';
            mce_bclr1       <= '1';

         when DONE_SUBRACK_BCLR =>
            done_mce_bclr1  <= '1';

         when ASSERT_SUBRACK_BCLR2 =>
            timeout_clr1     <= '0';
            mce_bclr1       <= '1';

         when DONE_SUBRACK_BCLR2 =>
            done_brst       <= '1';

         when PREP_CLOCK_CARD_BCLR =>
            cc_bclr_event1   <= '1';
            timeout_clr1     <= '0';
            cc_bclr         <= '1';

         when ASSERT_CLOCK_CARD_BCLR =>
            timeout_clr1     <= '0';
            cc_bclr         <= '1';

         when DONE_CLOCK_CARD_BCLR =>
            done_cc_bclr1   <= '1';

--         when TIMER_EXPIRED =>
--            done_reset       <= '1';

         when WAIT_FOR_RESET =>

         when others =>

      end case;
   end process;

   --------------------------------------------------------------------------------------------------------------------
   -- FSM for notifying the system of Clock Card BClr's
   --------------------------------------------------------------------------------------------------------------------
   -- State forwarder
   process(clk_i, brst5)
   begin
      -- Neither ext_rst_n_i (BRst, 1.5V monitor, 3.3V monitor) nor BClr should reset this register.
      if(brst5 = '0') then
         current_cc_bclr_state <= IDLE;
      elsif(clk_i'event and clk_i = '1') then
         current_cc_bclr_state <= next_cc_bclr_state;
      end if;
   end process;

   -- Transition table
   process(current_cc_bclr_state, cc_bclr_event1, cc_bclr_event2, done_cc_bclr1, done_cc_bclr2, cc_bclr_ack_i)
   begin
      -- Default assignments
      next_cc_bclr_state <= current_cc_bclr_state;

      case current_cc_bclr_state is
         when IDLE =>
            if(cc_bclr_event1 = '1' or cc_bclr_event2 = '1') then
               next_cc_bclr_state <= CC_BCLR_NOW;
            end if;

         when CC_BCLR_NOW =>
            if(done_cc_bclr1 = '1' or done_cc_bclr2 = '1') then
               next_cc_bclr_state <= WAIT_FOR_ACK;
            end if;

         when WAIT_FOR_ACK =>
            if(cc_bclr_ack_i = '1') then
               next_cc_bclr_state <= IDLE;
            end if;

         when others =>
            next_cc_bclr_state <= IDLE;

      end case;
   end process;

   -- Output states
   process(current_cc_bclr_state)
   begin
      -- Default assignments
      cc_bclr_event_o <= '0';

      case current_cc_bclr_state is
         when IDLE =>

         when CC_BCLR_NOW =>

         when WAIT_FOR_ACK =>
            cc_bclr_event_o <= '1';

         when others =>

      end case;
   end process;

   --------------------------------------------------------------------------------------------------------------------
   -- FSM for notifying the system of MCE BClr's
   --------------------------------------------------------------------------------------------------------------------
   -- State forwarder
   process(clk_i, brst5)
   begin
      -- Neither ext_rst_n_i (BRst, 1.5V monitor, 3.3V monitor) nor BClr should reset this register.
      if(brst5 = '0') then
         current_mce_bclr_state <= IDLE;
      elsif(clk_i'event and clk_i = '1') then
         current_mce_bclr_state <= next_mce_bclr_state;
      end if;
   end process;

   -- Transition table
   process(current_mce_bclr_state, mce_bclr_event1, mce_bclr_event2, done_mce_bclr1, done_mce_bclr2, mce_bclr_ack_i)
   begin
      -- Default assignments
      next_mce_bclr_state <= current_mce_bclr_state;

      case current_mce_bclr_state is
         when IDLE =>
            if(mce_bclr_event1 = '1' or mce_bclr_event2 = '1') then
               next_mce_bclr_state <= MCE_BCLR_NOW;
            end if;

         when MCE_BCLR_NOW =>
            if(done_mce_bclr1 = '1' or done_mce_bclr2 = '1') then
               next_mce_bclr_state <= WAIT_FOR_ACK;
            end if;

         when WAIT_FOR_ACK =>
            if(mce_bclr_ack_i = '1') then
               next_mce_bclr_state <= IDLE;
            end if;

         when others =>
            next_mce_bclr_state <= IDLE;

      end case;
   end process;

   -- Output states
   process(current_mce_bclr_state)
   begin
      -- Default assignments
      mce_bclr_event_o <= '0';

      case current_mce_bclr_state is
         when IDLE =>

         when MCE_BCLR_NOW =>

         when WAIT_FOR_ACK =>
            mce_bclr_event_o <= '1';

         when others =>

      end case;
   end process;


   --------------------------------------------------------------------------------------------------------------------
   -- FSM for notifying the system of BRst's
   --------------------------------------------------------------------------------------------------------------------
   -- State forwarder
   process(clk_i, brst5)
   begin
      -- Neither ext_rst_n_i (BRst, 1.5V monitor, 3.3V monitor) nor BClr should reset this register.
      if(brst5 = '0') then
         current_brst_state <= IDLE;
      elsif(clk_i'event and clk_i = '1') then
         current_brst_state <= next_brst_state;
      end if;
   end process;

   -- Transition table
   process(current_brst_state, brst_event, done_brst, brst_ack_i)
   begin
      -- Default assignments
      next_brst_state <= current_brst_state;

      case current_brst_state is
         when IDLE =>
            if(brst_event = '1') then
               next_brst_state <= BRST_NOW;
            end if;

         when BRST_NOW =>
            if(done_brst = '1') then
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

   ------------------------------------------------------------
   --  WB FSM
   ------------------------------------------------------------
   -- clocked FSMs, advance the state for both FSMs
   state_FF: process(clk_i, cc_bclr)
   begin
      if(cc_bclr = '1') then
         current_wbs_state <= IDLE;
      elsif(clk_i'event and clk_i = '1') then
         current_wbs_state <= next_wbs_state;
      end if;
   end process state_FF;

   -- Transition table for DAC controller
   state_NS: process(current_wbs_state, rd_cmd, wr_cmd, cyc_i)
   begin
      -- Default assignments
      next_wbs_state <= current_wbs_state;

      case current_wbs_state is
         when IDLE =>
            if(wr_cmd = '1') then
               next_wbs_state <= WR;
            elsif(rd_cmd = '1') then
               next_wbs_state <= RD;
            end if;

         when WR =>
            if(cyc_i = '0') then
               next_wbs_state <= IDLE;
            end if;

         when RD =>
            if(cyc_i = '0') then
               next_wbs_state <= IDLE;
            end if;

         when others =>
            next_wbs_state <= IDLE;

      end case;
   end process state_NS;

   -- Output states for DAC controller
   state_out: process(current_wbs_state, addr_i, stb_i)
--   state_out: process(current_wbs_state, stb_i, addr_i)
   begin
      -- Default assignments
      ack_o           <= '0';
      mce_bclr_wren   <= '0';
      cc_bclr_wren    <= '0';

      case current_wbs_state is
         when IDLE  =>
            ack_o <= '0';

            -- The reason that this is here is because these are Reset commands, and have no data
            -- The wishbone transaction is done in one cycle.
            if(stb_i = '1') then
               if(addr_i = MCE_BCLR_ADDR) then
                  mce_bclr_wren <= '1';
               elsif(addr_i = CC_BCLR_ADDR) then
                  cc_bclr_wren <= '1';
               end if;
            end if;

         when WR =>
            ack_o <= '1';
--            mce_bclr_wren <= '1';

         when RD =>
            ack_o <= '1';

         when others =>

      end case;
   end process state_out;

   ------------------------------------------------------------
   --  Wishbone interface:
   ------------------------------------------------------------
--   with addr_i select dat_o <=
--      mce_bclr_data    when MCE_BCLR_ADDR,
--      (others => '0') when others;

   dat_o <= (others => '0');

   rd_cmd  <= '1' when (stb_i = '1' and cyc_i = '1' and we_i = '0' and (addr_i = MCE_BCLR_ADDR or addr_i = CC_BCLR_ADDR)) else '0';
   wr_cmd  <= '1' when (stb_i = '1' and cyc_i = '1' and we_i = '1' and (addr_i = MCE_BCLR_ADDR or addr_i = CC_BCLR_ADDR)) else '0';

end rtl;