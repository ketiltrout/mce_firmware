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
-- Project:    SCUBA2
-- Author:     Bryce Burger
-- Organisation:  UBC
--
-- Description:
-- This file implements the cmd_queue block in the issue/reply hardware
-- on the clock card.
--
-- Revision history:
-- $Log$
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
   rq_card_id_i   : in std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0);
   rq_par_id_i    : in std_logic_vector (PAR_ID_BUS_WIDTH-1 downto 0);
   rq_mop_i       : in std_logic_vector (MOP_BUS_WIDTH-1 downto 0);
   rq_uop_i       : in std_logic_vector (UOP_BUS_WIDTH-1 downto 0);
   rq_uop_status_i: in std_logic_vector (UOP_STATUS_BUS_WIDTH-1 downto 0); -- tells the cmd_queue the error status of a reply received
   rq_rdy_i       : in std_logic; -- tells the cmd_queue when a reply to a u-op reply is ready
   rq_ack_o       : out std_logic; -- tells the reply_queue when the cmd_queue has taken the u-op

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

   -- sync pulse
   sync_i         : std_logic -- the sync pulse determines when and when not to issue u-ops
   );
end cmd_queue