-- Copyright (c) 2003 SCUBA-2 Project
--               All Rights Reserved
--
-- THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF THE SCUBA-2 Project
-- The copyright notice above does not evidence any
-- actual or intended publication of such source code.
--
-- SOURCE CODE IS PROVIDED "AS IS". ALL EXPRESS OR IMPLIED CONDITIONS,
-- REPRESENTATIONS, AND WARRANTIES, INCLUDING ANY IMPLIED WARRANT OF
-- MERCHANTABILITY, SATISFACTORY QUALITY, FITNESS FOR A PARTICULAR
-- PURPOSE, OR NON-INFRINGEMENT, ARE DISCLAIMED, EXCEPT TO THE EXTENT
-- THAT SUCH DISCLAIMERS ARE HELD TO BE LEGALLY INVALID.
--
-- For the purposes of this code the SCUBA-2 Project consists of the
-- following organisations.
--
-- UKATC, Royal Observatory, Blackford Hill Edinburgh EH9 3HJ
-- UBC,   University of British Columbia, Physics & Astronomy Department,
--        Vancouver BC, V6T 1Z1
--
-- $Id: tb_cmd_queue.vhd,v 1.1 2004/05/31 21:23:37 bburger Exp $
--
-- Project:       SCUBA2
-- Author:        Bryce Burger
-- Organisation:  UBC
--
-- Description:
-- Pack file for cmd_queue
--
-- Revision history:
-- $Log: tb_cmd_queue.vhd,v $
-- Revision 1.1  2004/05/31 21:23:37  bburger
-- in progress
--
--
--
------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

library sys_param;

use sys_param.general_pack.all;
library work;
use work.cmd_queue_pack.all;
use work.issue_reply_pack.all;
use work.cmd_queue_ram40_pack.all;

entity TB_CMD_QUEUE is
end TB_CMD_QUEUE;

architecture BEH of TB_CMD_QUEUE is

   -- reply_queue interface
   signal uop_status_i  : std_logic_vector(UOP_STATUS_BUS_WIDTH-1 downto 0); -- Tells the cmd_queue whether a reply was successful or erroneous
   signal uop_rdy_o     : std_logic; -- Tells the reply_queue when valid m-op and u-op codes are asserted on it's interface
   signal uop_ack_i     : std_logic; -- Tells the cmd_queue that a reply to the u-op waiting to be retired has been found and it's status is asserted on uop_status_i
   signal uop_discard_o : std_logic; -- Tells the reply_queue whether or not to discard the reply to the current u-op reply when uop_rdy_i goes low.  uop_rdy_o can only go low after rq_ack_o has been received.
   signal uop_timedout_o: std_logic; -- Tells that reply_queue that it should generated a timed-out reply based on the the par_id, card_addr, etc of the u-op being retired.
   signal uop_o         : std_logic_vector(QUEUE_WIDTH-1 downto 0); --Tells the reply_queue the next u-op that the cmd_queue wants to retire

   -- cmd_translator interface
   signal card_addr_i   : std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0); -- The card address of the m-op
   signal par_id_i      : std_logic_vector (PAR_ID_BUS_WIDTH-1 downto 0); -- The parameter id of the m-op
   signal cmd_size_i    : std_logic_vector (DATA_SIZE_BUS_WIDTH-1 downto 0); -- The number of bytes of data in the m-op
   signal data_i        : std_logic_vector (DATA_BUS_WIDTH-1 downto 0);  -- Data belonging to a m-op
   signal data_clk_i    : std_logic; -- Clocks in 32-bit wide data
   signal mop_i         : std_logic_vector (MOP_BUS_WIDTH-1 downto 0); -- M-op sequence number
   signal issue_sync_i  : std_logic_vector (SYNC_NUM_BUS_WIDTH-1 downto 0);   signal mop_rdy_i     : std_logic; -- Tells cmd_queue when a m-op is ready
   signal mop_ack_o     : std_logic; -- Tells the cmd_translator when cmd_queue has taken the m-op

   -- bb_tx interface
   signal clk_o         : std_logic;
   signal rst_o         : std_logic;
   signal dat_o         : std_logic_vector (7 downto 0);
   signal we_o          : std_logic;
   signal stb_o         : std_logic;
   signal cyc_o         : std_logic;
   signal ack_i         : std_logic;

   -- Clock lines
   signal sync_i        : std_logic; -- The sync pulse determines when and when not to issue u-ops
   signal clk_i         : std_logic; -- Advances the state machines
   signal fast_clk_i    : std_logic;  -- Fast clock used for doing multi-cycle operations (inserting and deleting u-ops from the command queue) in a single clk_i cycle.  fast_clk_i must be at least 2x as fast as clk_i
   signal rst_i         : std_logic;  -- Resets all FSMs


------------------------------------------------------------------------
--
-- Instantiate the design
--
------------------------------------------------------------------------

begin

   DUT : cmd_queue
      port map(
         -- reply_queue interface
         uop_status_i  => uop_status_i,
         uop_rdy_o     => uop_rdy_o,
         uop_ack_i     => uop_ack_i,
         uop_discard_o => uop_discard_o,
         uop_timedout_o=> uop_timedout_o,
         uop_o         => uop_o,

         -- cmd_translator
         card_addr_i   => card_addr_i,
         par_id_i      => par_id_i,
         cmd_size_i    => cmd_size_i,
         data_i        => data_i,
         data_clk_i    => data_clk_i,
         mop_i         => mop_i,
         issue_sync_i  => issue_sync_i,
         mop_rdy_i     => mop_rdy_i,
         mop_ack_o     => mop_ack_o,

         -- bb_tx interface
         clk_o         => clk_o,
--         rst_o         => rst_o,
         dat_o         => dat_o,
         we_o          => we_o,
         stb_o         => stb_o,
         cyc_o         => cyc_o,
         ack_i         => ack_i,

         -- Clock lines
         sync_i        => sync_i,
         clk_i         => clk_i,
         fast_clk_i    => fast_clk_i,
         rst_i         => rst_i
      );

   -- Create a test clock
   clk_i <= not clk_i after CLOCK_PERIOD/2;

   -- Create stimulus
   STIMULI : process

   -- Procdures for creating stimulus

   procedure do_init is
   begin
      assert false report " init" severity NOTE;
   end do_init;

   procedure do_nop is
   begin
      wait for CLOCK_PERIOD;
      assert false report " nop" severity NOTE;
   end do_nop;

   procedure do_reset is
   begin
      wait for CLOCK_PERIOD;
      assert false report " reset" severity NOTE;
   end do_reset;

   procedure do_sync is
   begin
      wait for CLOCK_PERIOD;
      assert false report " sync" severity NOTE;
   end do_sync;

   -- Start the test
   begin

      do_nop;
      do_nop;
      do_sync;
      do_init;
      do_nop;
      do_nop;
      do_nop;
      do_nop;
      do_nop;

      do_nop;
      do_nop;
      do_sync;
      do_init;
      do_reset;
      do_init;
      do_nop;
      do_nop;
      do_nop;
      do_nop;

      do_nop;
      do_nop;
      do_sync;
      do_init;
      do_nop;
      do_nop;
      do_nop;
      do_nop;
      do_nop;

      do_nop;
      do_nop;
      do_sync;
      do_init;
      do_nop;
      do_nop;
      do_nop;
      do_nop;
      do_nop;

      assert false report " Simulation done." severity FAILURE;
   end process STIMULI;
end BEH;

------------------------------------------------------------------------
--
-- Configuration
--
------------------------------------------------------------------------

configuration TB_CMD_QUEUE_CONF of TB_CMD_QUEUE is
   for BEH
   end for;
end TB_CMD_QUEUE_CONF;