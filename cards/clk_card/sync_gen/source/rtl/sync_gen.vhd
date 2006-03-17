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

-- sync_gen.vhd
--
-- Project:     SCUBA-2
-- Author:      Bryce Burger
-- Organisation:   UBC
--
-- Description:
-- This implements the sync pulse generation on the Clock Card.
-- This block outputs a sync pulse one clock cycle wide whenever clk_ctr wraps to zero
-- The clk_ctr wraps to zero after counting to the last clock cycle in a frame:  END_OF_FRAME
-- If the output of sync pulse is to be regulated by the DV pulse, then: 
-- 1- assert dv_en_i high, and 
-- 2- connect the DV pulse input to dv_i
--
-- As long as a DV pulse is detected once per frame, the sync_gen will generate a sync pulse
-- To make sure that the DV pulse is detected, one can leave the DV line asserted high as long as data are desired
-- Even with DV asserted high for the duration of several frame cycles, only one sync pulse will be generated per frame
--
-- Revision history:
-- $Log: sync_gen.vhd,v $
-- Revision 1.15  2006/03/09 00:41:02  bburger
-- Bryce:  Added the following signal interfaces:  dv_mode_o, sync_mode_o, encoded_sync_o, external_sync_i
--
-- Revision 1.14  2006/02/11 01:19:33  bburger
-- Bryce:  Added the following signal interfaces to implement responding to external dv pulses
-- data_req
-- data_ack
-- frame_num_external
--
-- Revision 1.13  2005/03/16 02:20:58  bburger
-- bryce:  removed mem_clk from the cmd_queue and sync_gen blocks
--
-- Revision 1.12  2005/01/13 03:14:51  bburger
-- Bryce:
-- addr_card and clk_card:  added slot_id functionality, removed mem_clock
-- sync_gen and frame_timing:  added custom counters and registers
--
-- Revision 1.11  2004/12/08 22:13:06  bburger
-- Bryce:  Added default values for some signals at the top of processes
--
-- Revision 1.10  2004/11/25 01:34:32  bburger
-- Bryce:  changed signal dv_en interface from integer to std_logic
--
-- Revision 1.9  2004/11/19 20:00:05  bburger
-- Bryce :  updated frame_timing and sync_gen interfaces
--
-- Revision 1.8  2004/11/18 05:21:56  bburger
-- Bryce :  modified addr_card top level.  Added ac_dac_ctrl and frame_timing
--
-- Revision 1.7  2004/11/15 20:03:41  bburger
-- Bryce :  Moved frame_timing to the 'work' library, and physically moved the files to "all_cards" directory
--
-- Revision 1.6  2004/10/23 02:28:48  bburger
-- Bryce:  Work out a couple of bugs to do with the initialization window
--
-- Revision 1.5  2004/10/22 01:55:31  bburger
-- Bryce:  adding timing signals for RC flux_loop
--
-- Revision 1.4  2004/10/06 19:48:35  erniel
-- moved constants from commnad_pack to sync_gen_pack
-- updated references to sync_gen_pack
--
-- Revision 1.3  2004/09/15 18:42:02  bburger
-- Bryce:  Added a recirculation MUX
--
-- Revision 1.2  2004/08/21 00:00:31  bburger
-- Bryce:  now issues a sync pulse on the last cycle of a frame.
--
-- Revision 1.1  2004/08/05 00:19:33  bburger
-- Bryce:  new
--
--
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;

library components;
use components.component_pack.all;

library work;
use work.sync_gen_pack.all;
use work.frame_timing_pack.all;
use work.sync_gen_wbs_pack.all;
use work.sync_gen_core_pack.all;

entity sync_gen is
   port(
      -- Inputs/Outputs
      dv_mode_o            : out std_logic_vector(DV_SELECT_WIDTH-1 downto 0);
      sync_mode_o          : out std_logic_vector(SYNC_SELECT_WIDTH-1 downto 0);
      encoded_sync_o       : out std_logic;
      external_sync_i      : in std_logic;
      row_len_o            : out integer;
      num_rows_o           : out integer;

      -- Wishbone interface
      dat_i                : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      addr_i               : in std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
      tga_i                : in std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
      we_i                 : in std_logic;
      stb_i                : in std_logic;
      cyc_i                : in std_logic;
      dat_o                : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      ack_o                : out std_logic;

      -- Global Signals
      clk_i                : in std_logic;
      rst_i                : in std_logic
   );
end sync_gen;

architecture beh of sync_gen is

   type states is (SYNC_LOW, SYNC_HIGH, DV_RECEIVED, RESET);   
   signal current_state, next_state : states;
   
   signal clk_count        : integer;
   signal sync_count       : integer;
   signal dv_mode          : std_logic_vector(DV_SELECT_WIDTH-1 downto 0);
   signal sync_mode        : std_logic_vector(SYNC_SELECT_WIDTH-1 downto 0);
   signal row_len          : integer;
   signal num_rows         : integer;

   component sync_gen_core
   port(
      -- Wishbone Interface
      dv_mode_i            : in std_logic_vector(DV_SELECT_WIDTH-1 downto 0);
      sync_mode_i          : in std_logic_vector(SYNC_SELECT_WIDTH-1 downto 0);
      row_len_i            : in integer;
      num_rows_i           : in integer;
      
      -- Inputs/Outputs
      external_sync_i      : in std_logic;
      encoded_sync_o       : out std_logic;

      -- Global Signals
      clk_i                : in std_logic;
      rst_i                : in std_logic
   );
   end component;

   component sync_gen_wbs        
   port(
      -- sync_gen interface:
      dv_mode_o           : out std_logic_vector(DV_SELECT_WIDTH-1 downto 0);
      sync_mode_o         : out std_logic_vector(SYNC_SELECT_WIDTH-1 downto 0);
      row_len_o           : out integer;
      num_rows_o          : out integer;

      -- wishbone interface:
      dat_i               : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      addr_i              : in std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
      tga_i               : in std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
      we_i                : in std_logic;
      stb_i               : in std_logic;
      cyc_i               : in std_logic;
      dat_o               : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      ack_o               : out std_logic;

      -- global interface
      clk_i               : in std_logic;
      rst_i               : in std_logic 
   );     
   end component;

begin      
   
   dv_mode_o <= dv_mode;
   sync_mode_o <= sync_mode;
   row_len_o <= row_len;
   num_rows_o <= num_rows;   
   
   wbi: sync_gen_wbs        
      port map(
         dv_mode_o   => dv_mode,
         sync_mode_o => sync_mode,
         row_len_o   => row_len,
         num_rows_o  => num_rows,

         dat_i       => dat_i, 
         addr_i      => addr_i,
         tga_i       => tga_i, 
         we_i        => we_i,  
         stb_i       => stb_i, 
         cyc_i       => cyc_i, 
         dat_o       => dat_o, 
         ack_o       => ack_o, 

         clk_i       => clk_i,           
         rst_i       => rst_i           
      );
   
   sgc: sync_gen_core
      port map(
         -- Wishbone Interface
         dv_mode_i            => dv_mode,
         sync_mode_i          => sync_mode,
         row_len_i            => row_len,
         num_rows_i           => num_rows,

         -- Inputs/Outputs
         external_sync_i      => external_sync_i,
         encoded_sync_o       => encoded_sync_o,

         -- Global Signals
         clk_i                => clk_i,    
         rst_i                => rst_i     
      );            
      
end beh;