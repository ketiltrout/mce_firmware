-- 2003 SCUBA-2 Project
--                  All Rights Reserved
--
--  THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF THE SCUBA-2 Project
--  The copyright notice above does not evidence any
--  actual or intended publication of such source code.
--
--  SOURCE CODE IS PROVIDED "AS IS". ALL EXPRESS OR IMPLIED CONDITIONS,
--  REPRESENTATIONS, AND WARRANTIES, INCLUDING ANY IMPLIED WARRANT OF
--  MERCHANTABILITY, SATISFACTORY QUALITY, FITNESS FOR A PARTICULAR
--  PURPOSE, OR NON-INFRINGEMENT, ARE DISCLAIMED, EXCEPT TO THE EXTENT
--  THAT SUCH DISCLAIMERS ARE HELD TO BE LEGALLY INVALID.
--
-- For the purposes of this code the SCUBA-2 Project consists of the
-- following organisations.
--
-- UKATC, Royal Observatory, Blackford Hill Edinburgh EH9 3HJ
-- UBC,   University of British Columbia, Physics & Astronomy Department,
--        Vancouver BC, V6T 1Z1
--
-- $Id: ac_dac_ctrl_core.vhd,v 1.5 2005/01/26 01:25:21 mandana Exp $
--
-- Project:       SCUBA2
-- Author:        Bryce Burger
-- Organisation:  UBC
--
-- Description:
-- 14-bit 165MS/s DAC (AD9744) controller
-- This block must be coupled with frame_timing and wbs_ac_dac_ctrl blocks to work properly
--
-- Revision history:
-- $Log: ac_dac_ctrl_core.vhd,v $
-- Revision 1.5  2005/01/26 01:25:21  mandana
-- removed mem_clk_i
-- added PAUSE1 and PAUSE2 state for data to be ready in time
-- removed dac_on_data and dac_off data registers
--
-- Revision 1.4  2005/01/20 19:48:54  bburger
-- Bryce:  Changes associated with timing errors (slack) on the address card
--
-- Revision 1.3  2005/01/18 22:23:14  bburger
-- Bryce:  Modified the ac_dac_ctrl_core FSM to correct a timing error
--
-- Revision 1.2  2005/01/08 00:58:20  bburger
-- Bryce:  mem_clk_i is no longer used to clock internal registers
--
-- Revision 1.1  2004/11/20 01:20:44  bburger
-- Bryce :  fixed a bug in the ac_dac_ctrl_core block that did not load the off value of the row at the end of a frame.
--
-- Revision 1.9  2004/11/18 05:21:56  bburger
-- Bryce :  modified addr_card top level.  Added ac_dac_ctrl and frame_timing
--
-- Revision 1.8  2004/11/15 20:03:41  bburger
-- Bryce :  Moved frame_timing to the 'work' library, and physically moved the files to "all_cards" directory
--
-- Revision 1.7  2004/11/06 03:12:01  bburger
-- Bryce:  debugging
--
-- Revision 1.6  2004/11/04 00:08:18  bburger
-- Bryce:  small updates
--
-- Revision 1.5  2004/11/02 07:38:09  bburger
-- Bryce:  ac_dac_ctrl in progress
--
--   
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library sys_param;
use sys_param.wishbone_pack.all;
use sys_param.command_pack.all;
use sys_param.data_types_pack.all;

library work;
use work.ac_dac_ctrl_pack.all;
use work.ac_dac_ctrl_wbs_pack.all;
use work.ac_dac_ctrl_core_pack.all;
use work.frame_timing_pack.all;

library components;
use components.component_pack.all;

entity ac_dac_ctrl_core is        
   port(
      -- DAC hardware interface:
      dac_data_o              : out w14_array11;   
      dac_clks_o              : out std_logic_vector(NUM_OF_ROWS-1 downto 0);
   
      -- Wishbone interface
      on_off_addr_o           : out std_logic_vector(ROW_ADDR_WIDTH-1 downto 0);
      dac_id_i                : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
      on_data_i               : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
      off_data_i              : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
      mux_en_wbs_i            : in std_logic;

      -- frame_timing interface:
      row_switch_i            : in std_logic;
      restart_frame_aligned_i : in std_logic;
      row_en_i                : in std_logic;
      
      -- Global Signals      
      clk_i                   : in std_logic;
      rst_i                   : in std_logic     
   );     
end ac_dac_ctrl_core;

architecture rtl of ac_dac_ctrl_core is

-- Row Addressing FSM signals:
type row_states is (PRESET1, PRESET2, IDLE, UPDATE_VALS, LOAD_ON_VAL, PAUSE1, PAUSE2, LATCH_ON_VAL, LOAD_OFF_VAL, LATCH_OFF_VAL);                
signal row_current_state   : row_states;
signal row_next_state      : row_states;
signal frame_aligned_reg   : std_logic;
signal mux_en              : std_logic;
signal row_count           : integer;
signal row_count_new       : integer;

-- DAC signals 
signal k                   : integer;
signal dac_data            : std_logic_vector(AC_BUS_WIDTH-1 downto 0);
signal dac_id_int          : integer;

begin
                       
   row_count_new <= (row_count + 1) when restart_frame_aligned_i = '0' else 0;
   row_counter: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         row_count <= 0;
      elsif(clk_i'event and clk_i = '1') then
         if(row_switch_i = '1') then
            row_count <= row_count_new;
         end if;
      end if;
   end process row_counter;
   

   on_off_addr_o <= std_logic_vector(conv_unsigned(row_count, ROW_ADDR_WIDTH));
   
   gen_outputs:
   for k in 0 to (AC_NUM_BUSES-1) generate
      dac_data_o(k) <= dac_data;
   end generate gen_outputs;
  
   registered_inputs : process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         frame_aligned_reg <= '0';
         mux_en            <= '0';
      elsif(clk_i'event and clk_i = '1') then
         
         if(row_switch_i = '1') then
            frame_aligned_reg <= restart_frame_aligned_i;
         end if;
         
         if(restart_frame_aligned_i = '1') then
            if(mux_en_wbs_i = '1') then
               mux_en <= '1';
            else
               mux_en <= '0';
            end if;
         end if;
         
      end if;
   end process registered_inputs;
   
   -- clocked FSMs, advance the state for both FSMs
   state_FF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         dac_id_int <= 0;         
         row_current_state <= PRESET1;
      elsif(clk_i'event and clk_i = '1') then
         dac_id_int <= conv_integer(dac_id_i);         
         row_current_state <= row_next_state;
      end if;
   end process state_FF;

   row_state_NS: process(row_current_state, restart_frame_aligned_i, mux_en, row_en_i, frame_aligned_reg)
   begin
      -- Default assignments
      row_next_state <= row_current_state;
      
      case row_current_state is 
         when PRESET1 =>
            row_next_state <= PRESET2;
         
         when PRESET2 =>
            row_next_state <= IDLE;

         when IDLE =>
            if(restart_frame_aligned_i = '1' and mux_en = '1') then
               row_next_state <= PAUSE1;
            end if;
         
         when PAUSE1 =>
            row_next_state <= PAUSE2;
         
         when PAUSE2 =>
            row_next_state <= LOAD_ON_VAL;
         
         when LOAD_ON_VAL =>
            if(row_en_i = '1') then
               row_next_state <= LATCH_ON_VAL;
            end if;
         
         when LATCH_ON_VAL =>
            row_next_state <= LOAD_OFF_VAL;
         
         when LOAD_OFF_VAL =>
            if(row_en_i = '0') then
               row_next_state <= LATCH_OFF_VAL;
            end if;
         
         when LATCH_OFF_VAL =>
            if(mux_en = '0' and frame_aligned_reg = '1') then
               row_next_state <= IDLE;
            else
               row_next_state <= PAUSE1;
            end if;
         
         when others =>
            row_next_state <= IDLE;
      end case;
   end process row_state_NS;   

   -- output states for row selection FSM
   -- In every scan instance, the current row has to be turned on and the previous row has to be turned off
   -- Therefore only 2 DACs are clocked. 
   row_state_out: process(row_current_state, on_data_i, off_data_i, dac_id_int)--, frame_aligned_reg)
   begin
      -- Default assignments
      dac_data                     <= (others => '0');
      dac_clks_o                   <= (others => '0');
      
      case row_current_state is
         when PRESET1 =>
            dac_clks_o             <= (others => '0');
         
         when PRESET2 =>
            -- Set the output of all the DACs to '0'
            dac_clks_o             <= (others => '1');

         when IDLE =>
            dac_data               <= (others => '0');
            dac_clks_o             <= (others => '0');
         
         when PAUSE1 =>
            dac_data               <= on_data_i(AC_BUS_WIDTH-1 downto 0);
            dac_clks_o             <= (others => '0');
         
         when PAUSE2 =>
            dac_data               <= on_data_i(AC_BUS_WIDTH-1 downto 0);
            dac_clks_o             <= (others => '0');
         
         when LOAD_ON_VAL =>
            dac_data               <= on_data_i(AC_BUS_WIDTH-1 downto 0);
            dac_clks_o             <= (others => '0');
         
         when LATCH_ON_VAL =>
            dac_data               <= on_data_i(AC_BUS_WIDTH-1 downto 0);
            dac_clks_o(dac_id_int) <= '1';
         
         when LOAD_OFF_VAL =>
            dac_data               <= off_data_i(AC_BUS_WIDTH-1 downto 0);
            dac_clks_o             <= (others => '0');
         
         when LATCH_OFF_VAL =>
            dac_data               <= off_data_i(AC_BUS_WIDTH-1 downto 0);
            dac_clks_o(dac_id_int) <= '1';
         
         when others =>
      end case;
   end process row_state_out;   
     
end rtl;