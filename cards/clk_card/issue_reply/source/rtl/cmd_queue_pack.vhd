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
-- $Id$
--
-- Project:       SCUBA2
-- Author:        Bryce Burger
-- Organisation:  UBC
--
-- Description:
-- Pack file for cmd_queue
--
-- Revision history:
-- $Log$
--
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.issue_reply_pack.all;
use work.cmd_queue_ram40_pack.all;

package cmd_queue_pack is

   component cmd_queue
      port (
      -- reply_queue interface
      --mop_retire_o : out std_logic_vector(MOP_BUS_WIDTH-1 downto 0); -- Tells the reply_queue the next m-op that the cmd_queue wants to retire
      --uop_retire_o : out std_logic_vector(UOP_BUS_WIDTH-1 downto 0); -- Tells the reply_queue the next u-op that the cmd_queue wants to retire
      uop_status_i  : in std_logic_vector(UOP_STATUS_BUS_WIDTH-1 downto 0); -- Tells the cmd_queue whether a reply was successful or erroneous
      uop_rdy_o     : in std_logic; -- Tells the reply_queue when valid m-op and u-op codes are asserted on it's interface
      uop_ack_i     : out std_logic; -- Tells the cmd_queue that a reply to the u-op waiting to be retired has been found and it's status is asserted on uop_status_i
      uop_discard_o : out std_logic; -- Tells the reply_queue whether or not to discard the reply to the current u-op reply when uop_rdy_i goes low.  uop_rdy_o can only go low after rq_ack_o has been received.
      uop_timedout_o: out std_logic; -- Tells that reply_queue that it should generated a timed-out reply based on the the par_id, card_addr, etc of the u-op being retired.
      uop_o         : out std_logic_vector(QUEUE_WIDTH-1 downto 0); --Tells the reply_queue the next u-op that the cmd_queue wants to retire

      -- cmd_translator interface
      card_addr_i   : in std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0); -- The card address of the m-op
      par_id_i      : in std_logic_vector (PAR_ID_BUS_WIDTH-1 downto 0); -- The parameter id of the m-op
      cmd_size_i    : in std_logic_vector (DATA_SIZE_BUS_WIDTH-1 downto 0); -- The number of bytes of data in the m-op
      data_i        : in std_logic_vector (DATA_BUS_WIDTH-1 downto 0);  -- Data belonging to a m-op
      mop_i         : in std_logic_vector (MOP_BUS_WIDTH-1 downto 0); -- M-op sequence number
      issue_sync_i  : in std_logic; -- Bit will be toggled with each new m-op that belongs to a different sync period
      mop_rdy_i     : in std_logic; -- Tells cmd_queue when a m-op is ready
      mop_ack_o     : out std_logic; -- Tells the cmd_translator when cmd_queue has taken the m-op

      -- bb_tx interface
      clk_o         : out std_logic;
      rst_o         : out std_logic;
      dat_o         : out std_logic_vector (7 downto 0);
      we_o          : out std_logic;
      stb_o         : out std_logic;
      cyc_o         : out std_logic;
      ack_i         : in std_logic;
      --addr_i  : in std_logic_vector (ADDR_WIDTH-1 downto 0);
      --tga_i   : in std_logic_vector (TAG_ADDR_WIDTH-1 downto 0);
      --dat_o   : out std_logic_vector (DATA_WIDTH-1 downto 0);
      --rty_o   : out std_logic;

      -- Clock lines
      sync_i        : in std_logic; -- The sync pulse determines when and when not to issue u-ops
      clk_i         : in std_logic; -- Advances the state machines
      fast_clk_i    : in std_logic  -- Fast clock used for doing multi-cycle operations (inserting and deleting u-ops from the command queue) in a single clk_i cycle.  fast_clk_i must be at least 2x as fast as clk_i
      );
   end component;

end cmd_queue_pack;