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
-- $Log: sync_gen_core.vhd,v $
-- Revision 1.10  2006/01/16 18:02:10  bburger
-- Bryce:  sign-extended a literal std_logic_vector
--
-- Revision 1.9  2005/03/19 00:31:23  bburger
-- bryce:  Fixed several bugs.  Tagging cc_01010007.
--
-- Revision 1.8  2005/03/16 02:20:58  bburger
-- bryce:  removed mem_clk from the cmd_queue and sync_gen blocks
--
-- Revision 1.7  2005/02/17 22:42:12  bburger
-- Bryce:  changes to synchronization in the MCE in response to two problems
-- - a rising edge on the sync line during configuration
-- - an errant pulse on the restart_frame_1row_post_o from frame_timing block
--
-- Revision 1.6  2005/02/15 00:55:24  bburger
-- Bryce:  removed a register that was associated with timing problems
--
-- Revision 1.5  2005/01/13 03:14:51  bburger
-- Bryce:
-- addr_card and clk_card:  added slot_id functionality, removed mem_clock
-- sync_gen and frame_timing:  added custom counters and registers
--
-- Revision 1.4  2004/12/08 22:13:06  bburger
-- Bryce:  Added default values for some signals at the top of processes
--
-- Revision 1.3  2004/12/04 02:03:06  bburger
-- Bryce:  fixing some problems associated with integrating the reply_queue
--
-- Revision 1.2  2004/11/25 01:34:32  bburger
-- Bryce:  changed signal dv_en interface from integer to std_logic
--
-- Revision 1.1  2004/11/19 20:00:05  bburger
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
use ieee.std_logic_unsigned.all;

library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;

library components;
use components.component_pack.all;

library work;
use work.sync_gen_pack.all;
use work.frame_timing_pack.all;
use work.sync_gen_core_pack.all;

entity sync_gen_core is
   port(
      -- Wishbone Interface
      dv_en_i     : in std_logic;
      row_len_i   : in integer;
      num_rows_i  : in integer;
      data_req_o           : out std_logic;
      data_ack_i           : in  std_logic;
      frame_num_external_o : out std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
      
      -- Inputs/Outputs
      dv_i        : in std_logic;
      sync_o      : out std_logic;
      sync_num_o  : out std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);

      -- Global Signals
      clk_i       : in std_logic;
--      mem_clk_i   : in std_logic;
      rst_i       : in std_logic
   );
end sync_gen_core;

architecture beh of sync_gen_core is

   type states is (SYNC_LOW, SYNC_HIGH, DV_RECEIVED, RESET, SEND_BIT0, SEND_BIT1, SEND_BIT2, SEND_BIT3);   
   signal current_state, next_state : states;
   
   signal new_frame_period : std_logic;   
   signal clk_count        : integer;
   signal clk_count_new    : integer;
   signal sync_count       : std_logic_vector(SYNC_NUM_WIDTH-1 downto 0); --: integer;
   signal sync_count_new   : std_logic_vector(SYNC_NUM_WIDTH-1 downto 0); --integer;
   signal sync_num         : std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);
   
   signal sync_num_mux     : std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);
   signal sync_num_mux_sel : std_logic;
   
   signal frame_end        : integer;

begin      

   frame_end <= (num_rows_i*row_len_i)-1;
   clk_count_new <= (clk_count + 1) when clk_count < frame_end else 0;
   clk_cntr: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         clk_count <= 0;
      elsif(clk_i'event and clk_i = '1') then
         clk_count <= clk_count_new;
      end if;
   end process clk_cntr;

   sync_count_new <= sync_count + "0000000000000001";
   sync_cntr: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         sync_count <= (others => '0');
      elsif(clk_i'event and clk_i = '1') then
         if(new_frame_period = '1') then
            sync_count <= sync_count_new;
         end if;
      end if;
   end process sync_cntr;

   new_frame_period  <= '1' when clk_count = frame_end else '0';
--   sync_o            <= new_frame_period;
   sync_num_o        <= sync_num;

   sync_state_FF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         current_state <= SYNC_HIGH;
         sync_num      <= (others=>'0');
      elsif(clk_i'event and clk_i = '1') then
         current_state <= next_state;
         sync_num      <= sync_num_mux;
      end if;
   end process;

   sync_state_NS: process(current_state, new_frame_period)--, dv_i, dv_en_i
   begin
      next_state <= current_state;
      case current_state is
         when SYNC_LOW =>
-- The functionality of being able to sync to the DV pulse is not implemented yet.
-- Currently, sync pulses and sync numbers will be disabled if this setting is enabled
--            if(dv_en_i = '1') then
--               if(dv_i = '1') then
--                  next_state <= DV_RECEIVED;
--               else
--                  next_state <= SYNC_LOW;
--               end if;
--            else
               if(new_frame_period = '1') then
                  next_state <= SEND_BIT0;
               else
                  next_state <= SYNC_LOW;
               end if;
--            end if;
         when SEND_BIT0 =>
            next_state <= SEND_BIT1;
         when SEND_BIT1 =>
            next_state <= SEND_BIT2;
         when SEND_BIT2 =>
            next_state <= SEND_BIT3;
         when SEND_BIT3 =>
            next_state <= SYNC_LOW;
         when DV_RECEIVED =>
            if(new_frame_period = '1') then
               next_state <= SYNC_HIGH;
            else
               next_state <= DV_RECEIVED;
            end if;
         when others =>
            next_state <= SYNC_LOW;
      end case;
   end process;    
   
   sync_state_out: process(current_state)
   begin
      sync_num_mux_sel <= '0';
      sync_o <= '0';
      case current_state is
         when SYNC_LOW =>
         when SEND_BIT0 =>
            sync_o <= SYNC_PULSE_BIT0;
         when SEND_BIT1 =>
            sync_o <= SYNC_PULSE_BIT1;
         when SEND_BIT2 =>
            sync_o <= SYNC_PULSE_BIT2;
         when SEND_BIT3 =>
            sync_o <= SYNC_PULSE_BIT3;
            sync_num_mux_sel <= '1';
         when DV_RECEIVED =>
         when others =>
      end case;
   end process;
   
   sync_num_mux <= sync_num when sync_num_mux_sel = '0' else sync_count;

end beh;