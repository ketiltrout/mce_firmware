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
-- $Id: cmd_queue_pack.vhd,v 1.10 2004/09/02 01:14:52 bburger Exp $
--
-- Project:       SCUBA2
-- Author:        Bryce Burger
-- Organisation:  UBC
--
-- Description:
-- Pack file for cmd_queue
--
-- Revision history:
-- $Log: cmd_queue_pack.vhd,v $
-- Revision 1.10  2004/09/02 01:14:52  bburger
-- Bryce:  Debugging - found that crc_ena must be asserted for crc_clear to function correctly
--
-- Revision 1.9  2004/08/18 06:48:43  bench2
-- Bryce: removed unnecessary interface signals between the cmd_queue and the reply_queue.
--
-- Revision 1.8  2004/08/04 17:26:43  bburger
-- Bryce:  In progress
--
-- Revision 1.7  2004/07/22 23:43:31  bench2
-- Bryce: in progress
--
-- Revision 1.6  2004/07/22 20:39:08  bench2
-- Bryce: in progress
--
-- Revision 1.5  2004/06/30 23:10:53  bburger
-- in progress
--
-- Revision 1.4  2004/06/16 17:02:36  bburger
-- in progress
--
-- Revision 1.3  2004/05/31 21:55:49  mandana
-- syntax fix
--
-- Revision 1.2  2004/05/31 21:23:19  bburger
-- in progress
--
-- Revision 1.1  2004/05/25 21:26:29  bburger
-- pack file
--
--
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;

library work;
use work.issue_reply_pack.all;
use work.cmd_queue_ram40_pack.all;

package cmd_queue_pack is

   component cmd_queue
      port(
         -- for testing
         debug_o  : out std_logic_vector(31 downto 0);

         -- reply_queue interface
--         uop_status_i  : in std_logic_vector(UOP_STATUS_BUS_WIDTH-1 downto 0); -- Tells the cmd_queue whether a reply was successful or erroneous
         uop_rdy_o     : out std_logic; -- Tells the reply_queue when valid m-op and u-op codes are asserted on it's interface
         uop_ack_i     : in std_logic; -- Tells the cmd_queue that a reply to the u-op waiting to be retired has been found and it's status is asserted on uop_status_i
--         uop_discard_o : out std_logic; -- Tells the reply_queue whether or not to discard the reply to the current u-op reply when uop_rdy_i goes low.  uop_rdy_o can only go low after rq_ack_o has been received.
--         uop_timedout_o: out std_logic; -- Tells that reply_queue that it should generated a timed-out reply based on the the par_id, card_addr, etc of the u-op being retired.
         uop_o         : out std_logic_vector(QUEUE_WIDTH-1 downto 0); --Tells the reply_queue the next u-op that the cmd_queue wants to retire

         -- cmd_translator interface
         card_addr_i   : in std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0); -- The card address of the m-op
         par_id_i      : in std_logic_vector (PAR_ID_BUS_WIDTH-1 downto 0); -- The parameter id of the m-op
         data_size_i   : in std_logic_vector (DATA_SIZE_BUS_WIDTH-1 downto 0); -- The number of bytes of data in the m-op
         data_i        : in std_logic_vector (DATA_BUS_WIDTH-1 downto 0);  -- Data belonging to a m-op
         data_clk_i    : in std_logic; -- Clocks in 32-bit wide data
         mop_i         : in std_logic_vector (MOP_BUS_WIDTH-1 downto 0); -- M-op sequence number
         issue_sync_i  : in std_logic_vector (SYNC_NUM_BUS_WIDTH-1 downto 0);
         mop_rdy_i     : in std_logic; -- Tells cmd_queue when a m-op is ready
         mop_ack_o     : out std_logic; -- Tells the cmd_translator when cmd_queue has taken the m-op
         cmd_type_i    : in std_logic_vector (CMD_TYPE_WIDTH-1 downto 0);       -- this is a re-mapping of the cmd_code into a 3-bit number
         cmd_stop_i    : in std_logic;                                          -- indicates a STOP command was recieved
         last_frame_i  : in std_logic;                                          -- indicates the last frame of data for a ret_dat command

         -- lvds_tx interface
         tx_o          : out std_logic;  -- transmitter output pin
         clk_200mhz_i   : in std_logic;  -- PLL locked 25MHz input clock for the

         -- Clock lines
         sync_i        : in std_logic; -- The sync pulse determines when and when not to issue u-ops
         sync_num_i    : in std_logic_vector(SYNC_NUM_BUS_WIDTH-1 downto 0);
         clk_i         : in std_logic; -- Advances the state machines
         rst_i         : in std_logic  -- Resets all FSMs
      );
   end component;
end cmd_queue_pack;