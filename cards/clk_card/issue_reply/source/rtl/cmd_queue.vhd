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
-- $Id: cmd_queue.vhd,v 1.1 2004/05/11 02:17:31 bburger Exp $
--
-- Project:    SCUBA2
-- Author:     Bryce Burger
-- Organisation:  UBC
--
-- Description:
-- This file implements the cmd_queue block in the issue/reply hardware
-- on the clock card.
--
-- Revision history:
-- $Log: cmd_queue.vhd,v $
-- Revision 1.1  2004/05/11 02:17:31  bburger
-- new
--
--
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library sys_param;
use sys_param.wishbone_pack.all;

library components;
use components.component_pack.all;

library work;
use work.issue_reply_pack.all;

entity cmd_queue is
--generic(
--   ADDR_WIDTH     : integer := WB_ADDR_WIDTH;
--   DATA_WIDTH     : integer := WB_DATA_WIDTH;
--   TAG_ADDR_WIDTH : integer := WB_TAG_ADDR_WIDTH
--   );
port (
   -- reply_queue interface
   --rq_card_id_i   : in std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0);
   --rq_par_id_i    : in std_logic_vector (PAR_ID_BUS_WIDTH-1 downto 0);
   rq_next_mop_o  : out std_logic_vector (MOP_BUS_WIDTH-1 downto 0); -- tells the reply_queue the next m-op that the cmd_queue wants to retire
   rq_next_uop_o  : out std_logic_vector (UOP_BUS_WIDTH-1 downto 0); -- tells the reply_queue the next u-op that the cmd_queue wants to retire
   rq_uop_status_i: in std_logic_vector (UOP_STATUS_BUS_WIDTH-1 downto 0); -- tells the cmd_queue whether a reply was successful or erroneous
   rq_rdy_o       : in std_logic; -- tells the reply_queue when valid m-op and u-op codes are asserted on it's interface
   rq_ack_i       : out std_logic; -- tells the cmd_queue that a reply to the u-op waiting to be retired has been found and it's status is asserted on rq_uop_status_i
   rq_discard_o   : out std_logic; -- tells the reply_queue whether or not to discard the reply to the current u-op reply when rq_rdy_i goes low.  rq_rdy_o can only go low after rq_ack_o has been received.

   -- cmd_translator interface
   ct_card_id_i   : in std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0); -- the card address of the m-op
   ct_par_id_i    : in std_logic_vector (PAR_ID_BUS_WIDTH-1 downto 0); -- the parameter id of the m-op
   ct_cmd_size_i  : in std_logic_vector (CMD_SIZE_BUS_WIDTH-1 downto 0); -- the number of bytes of data in the m-op
   ct_data_i      : in std_logic_vector (DATA_BUS_WIDTH-1 downto 0);  -- data belonging to a m-op
   ct_mop_i       : in std_logic_vector (MOP_BUS_WIDTH-1 downto 0); -- m-op sequence number
   ct_sync_i      : in std_logic; -- bit will be toggled with each new m-op that belongs to a different sync period
   ct_rdy_i       : in std_logic; -- tells cmd_queue when a m-op is ready
   ct_ack_o       : out std_logic; -- tells the cmd_translator when cmd_queue has taken the m-op

   -- bb_tx interface
   bb_clk_o       : out std_logic;
   bb_rst_o       : out std_logic;
   bb_dat_o       : out std_logic_vector (DATA_WIDTH-1 downto 0);
   bb_we_o        : out std_logic;
   bb_stb_o       : out std_logic;
   bb_cyc_o       : out std_logic;
   bb_ack_i       : in std_logic;
   --addr_i  : in std_logic_vector (ADDR_WIDTH-1 downto 0);
   --tga_i   : in std_logic_vector (TAG_ADDR_WIDTH-1 downto 0);
   --dat_o   : out std_logic_vector (DATA_WIDTH-1 downto 0);
   --rty_o   : out std_logic;

   -- clock lines
   sync_i         : in std_logic -- the sync pulse determines when and when not to issue u-ops
   clk_i          : in std_logic -- advances the state machines
   );
end cmd_queue

architecture behav of cmd_queue is

-- Retire/Resend state machine:
-- State encoding and state variables:
type retire_states is (IDLE, NEXT_UOP, STATUS, RETIRE, FLUSH, NEXT_FLUSH, FLUSH_STATUS, FLUSH_DONE);
signal present_retire_state : states;
signal next_retire_state    : states;

-- Generate u-Op state machine:
-- State encoding and state variables:
type gen_uop_states is (IDLE, PARSE, INSERT);
signal present_gen_state : states;
signal next_gen_state    : states;

-- Send state machine:
-- State encoding and state variables:
type send_states is (IDLE, VERIFY, ISSUE);
signal present_send_state : states;
signal next_send_state    : states;

-- Shared registers

-- retire queue pointer:
   retire_ptr: reg
      generic map(WIDTH => 16)
      port map(clk_i  => clk_i,
               rst_i  => ,
               ena_i  => ,
               reg_i  => ,
               reg_o  => );

-- flush queue pointer:
   retire_ptr: reg
      generic map(WIDTH => 16)
      port map(clk_i  => clk_i,
               rst_i  => ,
               ena_i  => ,
               reg_i  => ,
               reg_o  => );

-- send queue pointer:
   retire_ptr: reg
      generic map(WIDTH => 16)
      port map(clk_i  => clk_i,
               rst_i  => ,
               ena_i  => ,
               reg_i  => ,
               reg_o  => );

-- free queue pointer:
   retire_ptr: reg
      generic map(WIDTH => 16)
      port map(clk_i  => clk_i,
               rst_i  => ,
               ena_i  => ,
               reg_i  => ,
               reg_o  => );