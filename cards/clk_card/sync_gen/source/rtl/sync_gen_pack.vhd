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

-- sync_gen_pack.vhd
--
-- Project:     SCUBA-2
-- Author:      Bryce Burger
-- Organisation:   UBC
--
-- Description:
-- This implements the sync pulse generation on the Clock Card.
--
-- Revision history:
-- $Log: sync_gen_pack.vhd,v $
-- Revision 1.7  2004/11/19 20:00:05  bburger
-- Bryce :  updated frame_timing and sync_gen interfaces
--
-- Revision 1.6  2004/11/18 05:21:56  bburger
-- Bryce :  modified addr_card top level.  Added ac_dac_ctrl and frame_timing
--
-- Revision 1.5  2004/10/23 02:28:48  bburger
-- Bryce:  Work out a couple of bugs to do with the initialization window
--
-- Revision 1.4  2004/10/22 01:55:31  bburger
-- Bryce:  adding timing signals for RC flux_loop
--
-- Revision 1.3  2004/10/08 19:45:26  bburger
-- Bryce:  Changed SYNC_NUM_WIDTH to 16, removed TIMEOUT_SYNC_WIDTH, added a command-code to cmd_queue, added two words of book-keeping information to the cmd_queue
--
-- Revision 1.2  2004/10/06 19:48:35  erniel
-- moved constants from commnad_pack to sync_gen_pack
-- updated references to sync_gen_pack
--
-- Revision 1.1  2004/08/05 00:19:33  bburger
-- Bryce:  new
--
--
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library sys_param;
use sys_param.wishbone_pack.all;

package sync_gen_pack is

constant SYNC_NUM_WIDTH     : integer := 16;
constant ISSUE_SYNC_WIDTH   : integer := SYNC_NUM_WIDTH;

component sync_gen
   port(
      -- Inputs/Outputs
      dv_i        : in std_logic;
      sync_o      : out std_logic;
      sync_num_o  : out std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);

      -- Wishbone interface
      dat_i              : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      addr_i             : in std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
      tga_i              : in std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
      we_i               : in std_logic;
      stb_i              : in std_logic;
      cyc_i              : in std_logic;
      dat_o              : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      ack_o              : out std_logic;

      -- Global Signals
      clk_i       : in std_logic;
--      mem_clk_i   : in std_logic;
      rst_i       : in std_logic
   );
end component;

end sync_gen_pack;