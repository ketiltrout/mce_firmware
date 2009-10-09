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
-- $Id: ac_dac_ctrl.vhd,v 1.19 2009/09/14 21:36:46 bburger Exp $
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
-- $Log: ac_dac_ctrl.vhd,v $
-- Revision 1.19  2009/09/14 21:36:46  bburger
-- BB: correction to the width of mode_data_slv.
--
-- Revision 1.18  2009/09/14 20:11:12  bburger
-- BB: support added for BIAS_START_ADDR added to the mux_en = 1 branch of the FSM
--
-- Revision 1.17  2008/12/22 20:36:21  bburger
-- BB:  Added a comment
--
-- Revision 1.16  2008/06/17 19:02:25  bburger
-- BB:  Added support for const_val39, for revision ac_v02000007. Now adding a comment in the history.  This is a test.
--
-- Revision 1.16  2008/06/12 21:43:12  bburger
-- BB:  Added support for const_val39, for revision ac_v02000007
--
-- Revision 1.15  2008/05/29 21:13:15  bburger
-- BB:  Added support for const_mode and const_val commands, which allow a user to add any subset of the 41 DACs to a group that has one constant value latched out once.  The latching occurs when any of the following commands are issued:
-- - mux_en
-- - const_mode
-- - const_val
--
-- Revision 1.14  2008/01/21 19:22:12  bburger
-- BB:  Completely new revision!
-- - Added RAM storage for 41x64 SQ2FB values
-- - Added a new multiplexing mode (enbl_mux = 2) that will be used for SQ2FB multiplexing
-- - Retained the existing multiplexing mode (enbl_mux = 1) for use in the Address Card slot
-- - Amalgamated the ac_dac_ctrl_core and ac_dac_ctrl_wbs into the higher-level ac_dac_ctrl file to make coding easier
-- - Hardware and cold testing was successful
-- - At the moment, the parameter called row_dly is no longer supported
--
-- Revision 1.13  2008/01/08 23:23:42  bburger
-- BB:  Interim commital for code sharing between PCs
--
-- Revision 1.12  2006/08/01 18:20:51  bburger
-- Bryce:  removed component declarations from header files and moved them to source files
--
-- Revision 1.11  2005/01/26 01:21:29  mandana
-- removed mem_clk_i and other unused signals
--
-- Revision 1.10  2004/11/20 01:20:44  bburger
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
--use work.ac_dac_ctrl_core_pack.all;
use work.frame_timing_pack.all;

library components;
use components.component_pack.all;

-- Need this?
use work.ac_dac_ctrl_core_pack.all;

entity ac_dac_ctrl is
   port(
      -- DAC hardware interface:
      dac_data_o              : out w14_array11;
      dac_clks_o              : out std_logic_vector(AC_NUM_DACS-1 downto 0);

      -- wishbone interface:
      dat_i                   : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      addr_i                  : in std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
      tga_i                   : in std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
      we_i                    : in std_logic;
      stb_i                   : in std_logic;
      cyc_i                   : in std_logic;
      dat_o                   : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      ack_o                   : out std_logic;

      -- frame_timing interface:
      row_count_i             : in std_logic_vector(ROW_COUNT_WIDTH-1 downto 0);
      row_switch_i            : in std_logic;
      restart_frame_aligned_i : in std_logic;
      restart_frame_1row_prev_i : in std_logic;
      row_en_i                : in std_logic;

      -- Global Signals
      clk_i                   : in std_logic;
      clk_i_n                 : in std_logic;
      clk_100_i               : in std_logic;
      rst_i                   : in std_logic
   );
end ac_dac_ctrl;

architecture rtl of ac_dac_ctrl is
   -----------------------------------------------------------------------
   -- ADC <-> WBS Signals
   -----------------------------------------------------------------------
   signal row_to_turn_off_slv : std_logic_vector(ROW_ADDR_WIDTH-1 downto 0);
   signal row_to_turn_off_int : integer range 0 to (2**ROW_ADDR_WIDTH)-1;

   signal row_to_turn_on_slv : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal row_to_turn_on_int : integer range 0 to (2**ROW_ADDR_WIDTH)-1;

   signal row_order_index_int : integer range 0 to (2**ROW_ADDR_WIDTH)-1;
   signal row_order_index_slv : std_logic_vector(ROW_ADDR_WIDTH-1 downto 0);

   -----------------------------------------------------------------------
   -- ADC Signals
   -----------------------------------------------------------------------
   -- Row Addressing FSM signals:
   constant FSM_DELAY         : std_logic_vector(ROW_COUNT_WIDTH-1 downto 0) := x"0002";

   type row_states is (IDLE, 
      BC_LATCH1, BC_LATCH2, BC_LATCH3, BC_LATCH4, BC_LATCH_NEW_ROW_INDEX, BC_WAIT_FOR_ROW_SWITCH, 
      AC_LATCH_OFF, AC_ROW_DLY, AC_LATCH_ON, AC_LATCH_NEW_ROW_INDEX, AC_WAIT_FOR_ROW_SWITCH, --MODE3_ROW_OFF, 
      MODE3_HEAT1_ON, MODE3_HEAT2_ON, MODE3_HEAT3_ON, MODE3_HEAT4_ON, MODE3_HEATING, MODE3_HEAT_OFF, MODE3_ROW_ON, MODE3_LATCH_NEW_ROW_INDEX, MODE3_WAIT_FOR_ROW_SWITCH);
   signal row_current_state   : row_states;
   signal row_next_state      : row_states;

   type const_states is (IDLE, WRITING, WRITING2, WRITING3, UPDATE, READY_DELAY);
   signal const_current_state : const_states;
   signal const_next_state    : const_states;

   signal row_count           : std_logic_vector(ROW_COUNT_WIDTH-1 downto 0);
   signal frame_aligned_reg   : std_logic;
   signal mux_en              : integer range 0 to 3;
   signal prev_row_count      : integer range 0 to (2**ROW_ADDR_WIDTH)-1;
   signal row_count_new       : integer range 0 to (2**ROW_ADDR_WIDTH)-1;

   -- DAC signals
   signal k                   : integer range 0 to AC_NUM_BUSES;
   signal dac_id_int          : integer range 0 to (2**ROW_ADDR_WIDTH)-1;
   signal tga_int             : integer range 0 to MAX_NUM_OF_ROWS-1;

   signal fb_wren             : w1_array64;
   signal pre_reg_data        : w14_array64;
   signal fast_dac_data       : w14_array64;
   signal hb_data_vec         : w32_array64;
--   signal hb_data_vec_short   : w14_array64;
   signal dataa               : w32_array64;
   -- datab needs to be a vector of 64 signals, because its addressed using ROW_ADDR_WIDTH, which is 6 bits wide: 2^6 = 64
   signal datab               : w32_array64;

   signal mode_wren_vec       : w1_array64;
   signal val_wren_vec        : w1_array64;
   signal heater_bias_wren_vec: w1_array64;
   signal mode_data_slv       : std_logic_vector(AC_NUM_DACS-1 downto 0);
   signal mode_data_vec       : w32_array64;
   signal const_data_vec      : w32_array64;
   signal mode_data           : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal const_data          : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal heater_bias_data    : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal val_changing        : std_logic;
   signal update_const        : std_logic;
   signal update_const_dly1   : std_logic;
   signal update_const_dly2   : std_logic;
   signal update_const_ack    : std_logic;

   signal dac_clks            : std_logic_vector(AC_NUM_DACS-1 downto 0);
   constant DAC_NO_CLKS       : std_logic_vector(AC_NUM_DACS-1 downto 0) := "00000000000000000000000000000000000000000";
   constant DAC_ALL_CLKS      : std_logic_vector(AC_NUM_DACS-1 downto 0) := "11111111111111111111111111111111111111111";
   constant DAC_CLKS1         : std_logic_vector(AC_NUM_DACS-1 downto 0) := "10000001100000011000000110000001100000011";
   constant DAC_CLKS2         : std_logic_vector(AC_NUM_DACS-1 downto 0) := "00000110000001100000011000000110000001100";
   constant DAC_CLKS3         : std_logic_vector(AC_NUM_DACS-1 downto 0) := "00011000000110000001100000011000000110000";
   constant DAC_CLKS4         : std_logic_vector(AC_NUM_DACS-1 downto 0) := "01100000011000000110000001100000011000000";
   
   -----------------------------------------------------------------------
   -- WBS Signals
   -----------------------------------------------------------------------
   component tpram_32bit_x_64 port
   (
      data        : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
      wraddress   : IN STD_LOGIC_VECTOR (ROW_ADDR_WIDTH-1 DOWNTO 0);
      rdaddress_a : IN STD_LOGIC_VECTOR (ROW_ADDR_WIDTH-1 DOWNTO 0);
      rdaddress_b : IN STD_LOGIC_VECTOR (ROW_ADDR_WIDTH-1 DOWNTO 0);
      wren        : IN STD_LOGIC  := '1';
      clock       : IN STD_LOGIC ;
      qa          : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
      qb          : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
   );
   end component;

   component tpram_16bit_x_64 port
   (
      clock       : IN STD_LOGIC ;
      data        : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
      rdaddress_a : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
      rdaddress_b : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
      wraddress   : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
      wren        : IN STD_LOGIC  := '1';
      qa          : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
      qb          : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
   );
   end component;

   -- FSM inputs
   signal wr_cmd               : std_logic;
   signal rd_cmd               : std_logic;

   -- RAM/Register signals
   signal bias_start_wren      : std_logic;
   signal on_val_wren          : std_logic;
   signal off_val_wren         : std_logic;
   signal row_order_wren       : std_logic;
   signal mux_en_wren          : std_logic;
--   signal heater_bias_wren     : std_logic;
   signal heater_bias_len_wren : std_logic;
   
   signal mux_en_data          : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal heater_bias_len_data : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal bias_start_dataa     : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal bias_start_datab     : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal on_dataa             : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal on_datab             : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal off_dataa            : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal off_datab            : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal row_order_data       : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal slow_dac_data_on     : std_logic_vector(AC_BUS_WIDTH-1 downto 0);
   signal slow_dac_data_off    : std_logic_vector(AC_BUS_WIDTH-1 downto 0);
--   signal heater_bias_dataa    : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
--   signal heater_bias_datab    : std_logic_vector(WB_DATA_WIDTH-1 downto 0);

   -- WBS states:
   type states is (IDLE, WR, RD1, RD2);
   signal current_state        : states;
   signal next_state           : states;
   signal addr_int             : integer range 0 to (2**ROW_ADDR_WIDTH)-1;
   signal datab_mux            : word32;

   signal update_row_index             : std_logic;
   signal start_row                    : integer range 0 to (2**ROW_ADDR_WIDTH)-1;
   signal next_row_order_index_int     : integer range 0 to (2**ROW_ADDR_WIDTH)-1;
   signal next_row_order_index_int_new : integer range 0 to (2**ROW_ADDR_WIDTH)-1;

begin
   ------------------------------------------------------------
   -- Specialized Registers
   ------------------------------------------------------------
   next_row_order_index_int_new <= 0 when restart_frame_1row_prev_i = '1' else next_row_order_index_int + 1;
   row_num_cntr: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         next_row_order_index_int <= 0;
      elsif(clk_i'event and clk_i = '1') then
         if(row_switch_i = '1') then
            next_row_order_index_int <= next_row_order_index_int_new;
         end if;
      end if;
   end process row_num_cntr;

   row_order_index_slv <= std_logic_vector(conv_unsigned(row_order_index_int, ROW_ADDR_WIDTH));
   row_to_turn_off_int <= conv_integer(row_to_turn_off_slv);
   row_to_turn_on_int  <= conv_integer(row_to_turn_on_slv);

   row_index_register: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         row_order_index_int      <= 0;
         row_to_turn_off_slv  <= (others => '0');
      elsif(clk_i'event and clk_i = '1') then
         if(update_row_index = '1') then
            row_order_index_int  <= next_row_order_index_int;
            row_to_turn_off_slv  <= row_to_turn_on_slv(ROW_ADDR_WIDTH-1 downto 0);
         end if;
      end if;
   end process row_index_register;

   registered_signals : process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         frame_aligned_reg <= '0';
         update_const_dly1 <= '0';
         update_const_dly2 <= '0';
         slow_dac_data_on  <= (others => '0');
         slow_dac_data_off <= (others => '0');

      elsif(clk_i'event and clk_i = '1') then
         if(row_switch_i = '1') then
            frame_aligned_reg <= restart_frame_aligned_i;
         end if;

         update_const_dly1 <= update_const;
         update_const_dly2 <= update_const_dly1;

         if(mode_data_vec(row_to_turn_on_int)(0) = '0' and mux_en /= 0) then
            slow_dac_data_on <= on_dataa(AC_BUS_WIDTH-1 downto 0);
         else
            slow_dac_data_on <= const_data_vec(row_to_turn_on_int)(AC_BUS_WIDTH-1 downto 0);
         end if;

         if(mode_data_vec(row_to_turn_off_int)(0) = '0' and mux_en /= 0) then
            slow_dac_data_off <= off_dataa(AC_BUS_WIDTH-1 downto 0);
         else
            slow_dac_data_off <= const_data_vec(row_to_turn_off_int)(AC_BUS_WIDTH-1 downto 0);
         end if;

      end if;
   end process registered_signals;

   mux_en <= conv_integer(mux_en_data);

   ------------------------------------------------------------
   -- clocked FSMs, advance the state for both FSMs
   ------------------------------------------------------------
   state_FF2: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         row_current_state <= IDLE;
      elsif(clk_i'event and clk_i = '1') then
         row_current_state <= row_next_state;
      end if;
   end process state_FF2;

   row_count <= row_count_i + FSM_DELAY;
   row_state_NS: process(row_current_state, restart_frame_aligned_i, mux_en, row_switch_i, update_const, bias_start_dataa, row_count, heater_bias_len_data)
   begin
      -- Default assignments
      row_next_state <= row_current_state;

      case row_current_state is

         when IDLE =>
            if(restart_frame_aligned_i = '1' and mux_en = 3) then
               row_next_state <= MODE3_HEAT1_ON;
            elsif(restart_frame_aligned_i = '1' and mux_en = 2) then
               row_next_state <= BC_LATCH1;
            elsif(restart_frame_aligned_i = '1' and mux_en = 1) then
               -- Implement an alternate branch in the FSM here that takes care of the original way of muliplexing on the Address Card
               row_next_state <= AC_LATCH_OFF;
            elsif(update_const = '1') then
               -- fast_dac_data is a delay register that has either fast sq2fb or constant data multiplexed in.
               row_next_state <= BC_LATCH1;
            end if;

         ------------------------------------------------------------------
         --  This is MUX Mode #1:  One DAC turned off and on every new row
         ------------------------------------------------------------------
         when AC_LATCH_OFF =>
            row_next_state <= AC_ROW_DLY;

         when AC_ROW_DLY =>
            if(bias_start_dataa(ROW_COUNT_WIDTH-1 downto 0) <= row_count) then
               row_next_state <= AC_LATCH_ON;
            end if;
            
         when AC_LATCH_ON =>
            row_next_state <= AC_LATCH_NEW_ROW_INDEX;

         when AC_LATCH_NEW_ROW_INDEX =>
            row_next_state <= AC_WAIT_FOR_ROW_SWITCH;

         when AC_WAIT_FOR_ROW_SWITCH =>
            if(mux_en = 1 and row_switch_i = '1') then
               -- If multiplexing is still enabled and a row-switch occurs, keep on mux'ing
               row_next_state <= AC_LATCH_OFF;
            elsif(mux_en = 0 and row_switch_i = '1' and restart_frame_aligned_i = '0') then
               -- If multiplexing is disabled, but were are not yet at the end of a frame.
               row_next_state <= AC_LATCH_OFF;
            elsif(mux_en = 0 and row_switch_i = '1' and restart_frame_aligned_i = '1') then
               -- If multiplexing has been disabled, and we are at the end of a frame.
               row_next_state <= IDLE;
            elsif(mux_en /= 1 and row_switch_i = '1' and restart_frame_aligned_i = '0') then
               -- If multiplexing has been disabled, and we are at the end of a frame.
               row_next_state <= AC_LATCH_OFF;
            elsif(mux_en /= 1 and row_switch_i = '1' and restart_frame_aligned_i = '1') then
               -- If multiplexing has been disabled, and we are at the end of a frame.
               -- This was changed to a transition to IDLE when mode 3 was added.
               row_next_state <= IDLE;
            end if;

         ------------------------------------------------------------------
         --  This is MUX Mode #2:  All 41 DAC values are changed every row
         ------------------------------------------------------------------
         when BC_LATCH1 =>
            -- This is the start of the new frame period.
            row_next_state <= BC_LATCH2;

         when BC_LATCH2 =>
            row_next_state <= BC_LATCH3;

         when BC_LATCH3 =>
            row_next_state <= BC_LATCH4;

         when BC_LATCH4 =>
            row_next_state <= BC_LATCH_NEW_ROW_INDEX;

         when BC_LATCH_NEW_ROW_INDEX =>
            row_next_state <= BC_WAIT_FOR_ROW_SWITCH;

         when BC_WAIT_FOR_ROW_SWITCH =>
            if(mux_en = 2 and row_switch_i = '1') then
               -- If multiplexing is still enabled and a row-switch occurs, keep on mux'ing
               row_next_state <= BC_LATCH1;
            elsif(mux_en = 0 and row_switch_i = '1' and restart_frame_aligned_i = '0') then
               -- If multiplexing is disabled, but were are not yet at the end of a frame.
               row_next_state <= BC_LATCH1;
            elsif(mux_en = 0 and row_switch_i = '1' and restart_frame_aligned_i = '1') then
               -- If multiplexing has been disabled, and we are at the end of a frame.
               row_next_state <= IDLE;
            elsif(mux_en /= 2 and row_switch_i = '1' and restart_frame_aligned_i = '0') then
               -- If multiplexing has been disabled, and we are at the end of a frame.
               row_next_state <= BC_LATCH1;
            elsif(mux_en /= 2 and row_switch_i = '1' and restart_frame_aligned_i = '1') then
               -- If multiplexing has been disabled, and we are at the end of a frame.
               -- This was changed to a transition to IDLE when mode 3 was added.
               row_next_state <= IDLE;
            end if;

         ------------------------------------------------------------------
         --  This is MUX Mode #3:  At the start of every row, the array is heated differentially for Tc flattening
         ------------------------------------------------------------------
--         when MODE3_ROW_OFF =>
--            row_next_state <= MODE3_HEAT1_ON;

         when MODE3_HEAT1_ON =>
            row_next_state <= MODE3_HEAT2_ON;

         when MODE3_HEAT2_ON =>
            row_next_state <= MODE3_HEAT3_ON;

         when MODE3_HEAT3_ON =>
            row_next_state <= MODE3_HEAT4_ON;

         when MODE3_HEAT4_ON =>
            row_next_state <= MODE3_HEATING;

         when MODE3_HEATING =>
            if(heater_bias_len_data(ROW_COUNT_WIDTH-1 downto 0) <= row_count) then
               row_next_state <= MODE3_HEAT_OFF;
            end if;
            
         when MODE3_HEAT_OFF =>
            row_next_state <= MODE3_ROW_ON;

         when MODE3_ROW_ON =>
            row_next_state <= MODE3_LATCH_NEW_ROW_INDEX;
         
         when MODE3_LATCH_NEW_ROW_INDEX =>
            row_next_state <= MODE3_WAIT_FOR_ROW_SWITCH;

         when MODE3_WAIT_FOR_ROW_SWITCH =>
            if(mux_en = 3 and row_switch_i = '1') then
               -- If multiplexing is still enabled and a row-switch occurs, keep on mux'ing
               row_next_state <= MODE3_HEAT1_ON;
            elsif(mux_en = 0 and row_switch_i = '1' and restart_frame_aligned_i = '0') then
               -- If multiplexing is disabled, but were are not yet at the end of a frame.
               row_next_state <= MODE3_HEAT1_ON;
            elsif(mux_en = 0 and row_switch_i = '1' and restart_frame_aligned_i = '1') then
               -- If multiplexing has been disabled, and we are at the end of a frame.
               row_next_state <= IDLE;
            elsif(mux_en /= 3 and row_switch_i = '1' and restart_frame_aligned_i = '0') then
               -- If multiplexing has switched from 3->1 or 2, and we ARE NOT at the end of a frame.
               row_next_state <= MODE3_HEAT1_ON;
            elsif(mux_en /= 3 and row_switch_i = '1' and restart_frame_aligned_i = '1') then
               -- If multiplexing has switched from 3->1 or 2, and we ARE at the end of a frame.
               -- This was changed to a transition to IDLE in the othe modes when mode 3 was added.
               row_next_state <= IDLE;
            end if;

         when others =>
            row_next_state <= IDLE;
      end case;
   end process row_state_NS;

   -----------------------------------------------------------------------
   -- DAC Data MUXes
   -----------------------------------------------------------------------
   -- This strobes the clock lines of the DACs curing the second half of the state.
   dac_clks_o <=
      dac_clks and (clk_i_n &
      clk_i_n & clk_i_n & clk_i_n & clk_i_n & clk_i_n & clk_i_n & clk_i_n & clk_i_n &
      clk_i_n & clk_i_n & clk_i_n & clk_i_n & clk_i_n & clk_i_n & clk_i_n & clk_i_n &
      clk_i_n & clk_i_n & clk_i_n & clk_i_n & clk_i_n & clk_i_n & clk_i_n & clk_i_n &
      clk_i_n & clk_i_n & clk_i_n & clk_i_n & clk_i_n & clk_i_n & clk_i_n & clk_i_n &
      clk_i_n & clk_i_n & clk_i_n & clk_i_n & clk_i_n & clk_i_n & clk_i_n & clk_i_n);

   -- output states for row selection FSM
   -- In every scan instance, the current row has to be turned on and the previous row has to be turned off
   -- Therefore only 2 DACs are clocked.
   row_state_out: process(row_current_state, row_to_turn_off_int, row_to_turn_on_int,
      mode_data_slv, mux_en, update_const, update_const_dly2, restart_frame_aligned_i,
      slow_dac_data_off, slow_dac_data_on, fast_dac_data)
   begin
      -- Default assignments
      dac_data_o(0)  <= (others => '0');
      dac_data_o(1)  <= (others => '0');
      dac_data_o(2)  <= (others => '0');
      dac_data_o(3)  <= (others => '0');
      dac_data_o(4)  <= (others => '0');
      dac_data_o(5)  <= (others => '0');
      dac_data_o(6)  <= (others => '0');
      dac_data_o(7)  <= (others => '0');
      dac_data_o(8)  <= (others => '0');
      dac_data_o(9)  <= (others => '0');
      dac_data_o(10) <= (others => '0');

      dac_clks <= DAC_NO_CLKS;
      update_row_index <= '0';
      update_const_ack <= '0';

      case row_current_state is
         when IDLE =>
            dac_data_o(0)  <= fast_dac_data( 0);
            dac_data_o(1)  <= fast_dac_data( 1);
            dac_data_o(2)  <= fast_dac_data( 8);
            dac_data_o(3)  <= fast_dac_data( 9);
            dac_data_o(4)  <= fast_dac_data(16);
            dac_data_o(5)  <= fast_dac_data(17);
            dac_data_o(6)  <= fast_dac_data(24);
            dac_data_o(7)  <= fast_dac_data(25);
            dac_data_o(8)  <= fast_dac_data(32);
            dac_data_o(9)  <= fast_dac_data(33);
            dac_data_o(10) <= fast_dac_data(40);

         ------------------------------------------------------------------
         --  This is MUX Mode #1:  One DAC turned off and on every new row
         ------------------------------------------------------------------
         when AC_LATCH_OFF =>
            dac_data_o(0)  <= slow_dac_data_off;
            dac_data_o(1)  <= slow_dac_data_off;
            dac_data_o(2)  <= slow_dac_data_off;
            dac_data_o(3)  <= slow_dac_data_off;
            dac_data_o(4)  <= slow_dac_data_off;
            dac_data_o(5)  <= slow_dac_data_off;
            dac_data_o(6)  <= slow_dac_data_off;
            dac_data_o(7)  <= slow_dac_data_off;
            dac_data_o(8)  <= slow_dac_data_off;
            dac_data_o(9)  <= slow_dac_data_off;
            dac_data_o(10) <= slow_dac_data_off;

            -- If the constant values of some of the DACs have been updated, latch new values through all the DACs
            if(update_const = '1') then
               dac_clks(row_to_turn_off_int) <= '1';
            else
               dac_clks(row_to_turn_off_int) <= (not mode_data_slv(row_to_turn_off_int));
            end if;

         when AC_ROW_DLY =>
            dac_data_o(0)  <= slow_dac_data_on;
            dac_data_o(1)  <= slow_dac_data_on;
            dac_data_o(2)  <= slow_dac_data_on;
            dac_data_o(3)  <= slow_dac_data_on;
            dac_data_o(4)  <= slow_dac_data_on;
            dac_data_o(5)  <= slow_dac_data_on;
            dac_data_o(6)  <= slow_dac_data_on;
            dac_data_o(7)  <= slow_dac_data_on;
            dac_data_o(8)  <= slow_dac_data_on;
            dac_data_o(9)  <= slow_dac_data_on;
            dac_data_o(10) <= slow_dac_data_on;

         -- BB: There might be a bug here.
         -- If we are turning on the same row that we just turned off, we won't actually turn it on because the dac_clk signal is not deasserted!
         -- Add a wait state between AC_LATCH_OFF and AC_LATCH_ON
         -- Ha, no it's fine.  The dac_clks_o signal is anded with clk_i_n to prevent this bug.
         when AC_LATCH_ON =>
            dac_data_o(0)  <= slow_dac_data_on;
            dac_data_o(1)  <= slow_dac_data_on;
            dac_data_o(2)  <= slow_dac_data_on;
            dac_data_o(3)  <= slow_dac_data_on;
            dac_data_o(4)  <= slow_dac_data_on;
            dac_data_o(5)  <= slow_dac_data_on;
            dac_data_o(6)  <= slow_dac_data_on;
            dac_data_o(7)  <= slow_dac_data_on;
            dac_data_o(8)  <= slow_dac_data_on;
            dac_data_o(9)  <= slow_dac_data_on;
            dac_data_o(10) <= slow_dac_data_on;

            -- If the constant values of some of the DACs have been updated, latch new values through all the DACs
            if(update_const = '1') then
               dac_clks(row_to_turn_on_int) <= '1';
            else
               dac_clks(row_to_turn_on_int) <= (not mode_data_slv(row_to_turn_on_int));
            end if;

         when AC_LATCH_NEW_ROW_INDEX =>
            dac_data_o(0)  <= slow_dac_data_on;
            dac_data_o(1)  <= slow_dac_data_on;
            dac_data_o(2)  <= slow_dac_data_on;
            dac_data_o(3)  <= slow_dac_data_on;
            dac_data_o(4)  <= slow_dac_data_on;
            dac_data_o(5)  <= slow_dac_data_on;
            dac_data_o(6)  <= slow_dac_data_on;
            dac_data_o(7)  <= slow_dac_data_on;
            dac_data_o(8)  <= slow_dac_data_on;
            dac_data_o(9)  <= slow_dac_data_on;
            dac_data_o(10) <= slow_dac_data_on;

            -- We can assert update_row_index at the end of every row, because we never get into this state unless multiplexing is enabled.
            -- update_row_index has to be asserted for two 100 MHz clock cycles because the FSM it interfaces to a 50 MHz FSM
            update_row_index <= '1';

         when AC_WAIT_FOR_ROW_SWITCH =>
            dac_data_o(0)  <= slow_dac_data_off;
            dac_data_o(1)  <= slow_dac_data_off;
            dac_data_o(2)  <= slow_dac_data_off;
            dac_data_o(3)  <= slow_dac_data_off;
            dac_data_o(4)  <= slow_dac_data_off;
            dac_data_o(5)  <= slow_dac_data_off;
            dac_data_o(6)  <= slow_dac_data_off;
            dac_data_o(7)  <= slow_dac_data_off;
            dac_data_o(8)  <= slow_dac_data_off;
            dac_data_o(9)  <= slow_dac_data_off;
            dac_data_o(10) <= slow_dac_data_off;

            -- If we were updating constant DAC values, ack the changes at the end of the frame.
            -- To ensure that we don't ack at the beginning of the frame, we delay the constant signal by two cycles.
            if(restart_frame_aligned_i = '1' and update_const_dly2 = '1') then
               update_const_ack <= '1';
            end if;

         ------------------------------------------------------------------
         -- This is MUX Mode #0 or #2:
         -- This mode is used for fast sq2_fb multiplexing
         -- This sequence of states is also used for applying constants when multiplexing is off.
         -- fast_dac_data is a delay register that has either fast sq2fb or constant data multiplexed in.
         ------------------------------------------------------------------
         when BC_LATCH1 =>
            dac_data_o(0)  <= fast_dac_data( 0);
            dac_data_o(1)  <= fast_dac_data( 1);
            dac_data_o(2)  <= fast_dac_data( 8);
            dac_data_o(3)  <= fast_dac_data( 9);
            dac_data_o(4)  <= fast_dac_data(16);
            dac_data_o(5)  <= fast_dac_data(17);
            dac_data_o(6)  <= fast_dac_data(24);
            dac_data_o(7)  <= fast_dac_data(25);
            dac_data_o(8)  <= fast_dac_data(32);
            dac_data_o(9)  <= fast_dac_data(33);
            dac_data_o(10) <= fast_dac_data(40);

            if(mux_en = 0 and update_const = '1') then
               -- When mux_en = 0, if new constant values are written, update all DACs because they are all in constant mode
               -- This condition is also valid after a reset, because the update_const signal is asserted.
               -- This triggers the output of default values to the DACs.
               dac_clks <= DAC_CLKS1;
            elsif(mux_en = 0 and update_const = '0') then
               -- When mux_en = 0, and no new constant values have been written, hold everything steady
               -- This condition is valid after mux_en has changed to 0.
               null;
            elsif(mux_en /= 0 and update_const = '1') then
               -- When mux_en = 2, and a new constant has been written, update all DACS with either their constant val, or multiplexing value
               dac_clks <= DAC_CLKS1;
            elsif(mux_en /= 0 and update_const = '0') then
               -- When mux_en = 2, and no new constant values have been written, only clock the DACs that are being multiplexed
               dac_clks <= DAC_CLKS1 and (not mode_data_slv);
            end if;

         when BC_LATCH2 =>
            dac_data_o(0)  <= fast_dac_data( 2);
            dac_data_o(1)  <= fast_dac_data( 3);
            dac_data_o(2)  <= fast_dac_data(10);
            dac_data_o(3)  <= fast_dac_data(11);
            dac_data_o(4)  <= fast_dac_data(18);
            dac_data_o(5)  <= fast_dac_data(19);
            dac_data_o(6)  <= fast_dac_data(26);
            dac_data_o(7)  <= fast_dac_data(27);
            dac_data_o(8)  <= fast_dac_data(34);
            dac_data_o(9)  <= fast_dac_data(35);
            dac_data_o(10) <= fast_dac_data(40);

            if(mux_en = 0 and update_const = '1') then
               dac_clks <= DAC_CLKS2;
            elsif(mux_en = 0 and update_const = '0') then
               null;
            elsif(mux_en /= 0 and update_const = '1') then
               dac_clks <= DAC_CLKS2;
            elsif(mux_en /= 0 and update_const = '0') then
               dac_clks <= DAC_CLKS2 and (not mode_data_slv);
            end if;

         when BC_LATCH3 =>
            dac_data_o(0)  <= fast_dac_data( 5);
            dac_data_o(1)  <= fast_dac_data( 4);
            dac_data_o(2)  <= fast_dac_data(13);
            dac_data_o(3)  <= fast_dac_data(12);
            dac_data_o(4)  <= fast_dac_data(21);
            dac_data_o(5)  <= fast_dac_data(20);
            dac_data_o(6)  <= fast_dac_data(29);
            dac_data_o(7)  <= fast_dac_data(28);
            dac_data_o(8)  <= fast_dac_data(37);
            dac_data_o(9)  <= fast_dac_data(36);
            dac_data_o(10) <= fast_dac_data(40);

            if(mux_en = 0 and update_const = '1') then
               dac_clks <= DAC_CLKS3;
            elsif(mux_en = 0 and update_const = '0') then
               null;
            elsif(mux_en /= 0 and update_const = '1') then
               dac_clks <= DAC_CLKS3;
            elsif(mux_en /= 0 and update_const = '0') then
               dac_clks <= DAC_CLKS3 and (not mode_data_slv);
            end if;

         when BC_LATCH4 =>
            dac_data_o(0)  <= fast_dac_data( 7);
            dac_data_o(1)  <= fast_dac_data( 6);
            dac_data_o(2)  <= fast_dac_data(15);
            dac_data_o(3)  <= fast_dac_data(14);
            dac_data_o(4)  <= fast_dac_data(23);
            dac_data_o(5)  <= fast_dac_data(22);
            dac_data_o(6)  <= fast_dac_data(31);
            dac_data_o(7)  <= fast_dac_data(30);
            dac_data_o(8)  <= fast_dac_data(39);
            dac_data_o(9)  <= fast_dac_data(38);
            dac_data_o(10) <= fast_dac_data(40);

            if(mux_en = 0 and update_const = '1') then
               dac_clks <= DAC_CLKS4;
            elsif(mux_en = 0 and update_const = '0') then
               null;
            elsif(mux_en /= 0 and update_const = '1') then
               dac_clks <= DAC_CLKS4;
            elsif(mux_en /= 0 and update_const = '0') then
               dac_clks <= DAC_CLKS4 and (not mode_data_slv);
            end if;

         when BC_LATCH_NEW_ROW_INDEX =>
            dac_data_o(0)  <= fast_dac_data( 7);
            dac_data_o(1)  <= fast_dac_data( 6);
            dac_data_o(2)  <= fast_dac_data(15);
            dac_data_o(3)  <= fast_dac_data(14);
            dac_data_o(4)  <= fast_dac_data(23);
            dac_data_o(5)  <= fast_dac_data(22);
            dac_data_o(6)  <= fast_dac_data(31);
            dac_data_o(7)  <= fast_dac_data(30);
            dac_data_o(8)  <= fast_dac_data(39);
            dac_data_o(9)  <= fast_dac_data(38);
            dac_data_o(10) <= fast_dac_data(40);

            -- If the constant DAC values were changed during this frame period, acknowlege the change.
            if(update_const = '1') then
               update_const_ack <= '1';
            end if;

            -- What is this condition for? Is it for the case where we are in mode = 0, and are updating the constant values?  Probably.
            if (mux_en /= 0) then
               -- May need a second (100 MHz) state of asserting update_row_index to ensure that the register (50 MHz) above latches the new value
               update_row_index <= '1';
            end if;

         when BC_WAIT_FOR_ROW_SWITCH =>
            dac_data_o(0)  <= fast_dac_data( 0);
            dac_data_o(1)  <= fast_dac_data( 1);
            dac_data_o(2)  <= fast_dac_data( 8);
            dac_data_o(3)  <= fast_dac_data( 9);
            dac_data_o(4)  <= fast_dac_data(16);
            dac_data_o(5)  <= fast_dac_data(17);
            dac_data_o(6)  <= fast_dac_data(24);
            dac_data_o(7)  <= fast_dac_data(25);
            dac_data_o(8)  <= fast_dac_data(32);
            dac_data_o(9)  <= fast_dac_data(33);
            dac_data_o(10) <= fast_dac_data(40);

         ------------------------------------------------------------------
         --  This is MUX Mode #3:  At the start of every row, the array is heated differentially for Tc flattening
         ------------------------------------------------------------------
--         -- This state really isn't necessary, because it's DAC value is overwritten almost immediately in one of the following four states.
--         when MODE3_ROW_OFF =>
--            dac_data_o(0)  <= slow_dac_data_off;
--            dac_data_o(1)  <= slow_dac_data_off;
--            dac_data_o(2)  <= slow_dac_data_off;
--            dac_data_o(3)  <= slow_dac_data_off;
--            dac_data_o(4)  <= slow_dac_data_off;
--            dac_data_o(5)  <= slow_dac_data_off;
--            dac_data_o(6)  <= slow_dac_data_off;
--            dac_data_o(7)  <= slow_dac_data_off;
--            dac_data_o(8)  <= slow_dac_data_off;
--            dac_data_o(9)  <= slow_dac_data_off;
--            dac_data_o(10) <= slow_dac_data_off;
--
--            -- Constant values are applied next if necessary, so just update the DAC if it is not constant.
--            dac_clks(row_to_turn_off_int) <= (not mode_data_slv(row_to_turn_off_int));
        
         when MODE3_HEAT1_ON =>
            dac_data_o(0)  <= fast_dac_data( 0);
            dac_data_o(1)  <= fast_dac_data( 1);
            dac_data_o(2)  <= fast_dac_data( 8);
            dac_data_o(3)  <= fast_dac_data( 9);
            dac_data_o(4)  <= fast_dac_data(16);
            dac_data_o(5)  <= fast_dac_data(17);
            dac_data_o(6)  <= fast_dac_data(24);
            dac_data_o(7)  <= fast_dac_data(25);
            dac_data_o(8)  <= fast_dac_data(32);
            dac_data_o(9)  <= fast_dac_data(33);
            dac_data_o(10) <= fast_dac_data(40);

            if(mux_en = 0 and update_const = '1') then
               dac_clks <= DAC_CLKS1;
            elsif(mux_en = 0 and update_const = '0') then
               null;
            elsif(mux_en /= 0 and update_const = '1') then
               dac_clks <= DAC_CLKS1;
            elsif(mux_en /= 0 and update_const = '0') then
               dac_clks <= DAC_CLKS1 and (not mode_data_slv);
            end if;
         
         when MODE3_HEAT2_ON =>
            dac_data_o(0)  <= fast_dac_data( 2);
            dac_data_o(1)  <= fast_dac_data( 3);
            dac_data_o(2)  <= fast_dac_data(10);
            dac_data_o(3)  <= fast_dac_data(11);
            dac_data_o(4)  <= fast_dac_data(18);
            dac_data_o(5)  <= fast_dac_data(19);
            dac_data_o(6)  <= fast_dac_data(26);
            dac_data_o(7)  <= fast_dac_data(27);
            dac_data_o(8)  <= fast_dac_data(34);
            dac_data_o(9)  <= fast_dac_data(35);
            dac_data_o(10) <= fast_dac_data(40);

            if(mux_en = 0 and update_const = '1') then
               dac_clks <= DAC_CLKS2;
            elsif(mux_en = 0 and update_const = '0') then
               null;
            elsif(mux_en /= 0 and update_const = '1') then
               dac_clks <= DAC_CLKS2;
            elsif(mux_en /= 0 and update_const = '0') then
               dac_clks <= DAC_CLKS2 and (not mode_data_slv);
            end if;
         
         when MODE3_HEAT3_ON =>
            dac_data_o(0)  <= fast_dac_data( 5);
            dac_data_o(1)  <= fast_dac_data( 4);
            dac_data_o(2)  <= fast_dac_data(13);
            dac_data_o(3)  <= fast_dac_data(12);
            dac_data_o(4)  <= fast_dac_data(21);
            dac_data_o(5)  <= fast_dac_data(20);
            dac_data_o(6)  <= fast_dac_data(29);
            dac_data_o(7)  <= fast_dac_data(28);
            dac_data_o(8)  <= fast_dac_data(37);
            dac_data_o(9)  <= fast_dac_data(36);
            dac_data_o(10) <= fast_dac_data(40);

            if(mux_en = 0 and update_const = '1') then
               dac_clks <= DAC_CLKS3;
            elsif(mux_en = 0 and update_const = '0') then
               null;
            elsif(mux_en /= 0 and update_const = '1') then
               dac_clks <= DAC_CLKS3;
            elsif(mux_en /= 0 and update_const = '0') then
               dac_clks <= DAC_CLKS3 and (not mode_data_slv);
            end if;
         
         when MODE3_HEAT4_ON =>
            dac_data_o(0)  <= fast_dac_data( 7);
            dac_data_o(1)  <= fast_dac_data( 6);
            dac_data_o(2)  <= fast_dac_data(15);
            dac_data_o(3)  <= fast_dac_data(14);
            dac_data_o(4)  <= fast_dac_data(23);
            dac_data_o(5)  <= fast_dac_data(22);
            dac_data_o(6)  <= fast_dac_data(31);
            dac_data_o(7)  <= fast_dac_data(30);
            dac_data_o(8)  <= fast_dac_data(39);
            dac_data_o(9)  <= fast_dac_data(38);
            dac_data_o(10) <= fast_dac_data(40);

            if(mux_en = 0 and update_const = '1') then
               dac_clks <= DAC_CLKS4;
            elsif(mux_en = 0 and update_const = '0') then
               null;
            elsif(mux_en /= 0 and update_const = '1') then
               dac_clks <= DAC_CLKS4;
            elsif(mux_en /= 0 and update_const = '0') then
               dac_clks <= DAC_CLKS4 and (not mode_data_slv);
            end if;
         
         when MODE3_HEATING =>
            -- DAC buses are all held at zero.
         
         when MODE3_HEAT_OFF =>
            -- DAC buses are all held at zero.
            -- Constant values have already been applied if necessary, so just update the DACs if they are not constant.
            dac_clks <= DAC_ALL_CLKS and (not mode_data_slv);
         
         when MODE3_ROW_ON =>
            -- Constant data is multiplexed into slow_dac_data_on/ slow_dac_data_off only
            dac_data_o(0)  <= slow_dac_data_on;
            dac_data_o(1)  <= slow_dac_data_on;
            dac_data_o(2)  <= slow_dac_data_on;
            dac_data_o(3)  <= slow_dac_data_on;
            dac_data_o(4)  <= slow_dac_data_on;
            dac_data_o(5)  <= slow_dac_data_on;
            dac_data_o(6)  <= slow_dac_data_on;
            dac_data_o(7)  <= slow_dac_data_on;
            dac_data_o(8)  <= slow_dac_data_on;
            dac_data_o(9)  <= slow_dac_data_on;
            dac_data_o(10) <= slow_dac_data_on;

            -- Constant values have already been applied if necessary, so just update the DAC if it is not constant.
            dac_clks(row_to_turn_on_int) <= (not mode_data_slv(row_to_turn_on_int));
            
         when MODE3_LATCH_NEW_ROW_INDEX =>
            -- If the constant DAC values were changed during this frame period, acknowlege the change.
            if(update_const = '1') then
               update_const_ack <= '1';
            end if;

--            -- May need a second (100 MHz) state of asserting update_row_index to ensure that the register (50 MHz) above latches the new value.
--            -- We don't enter this state unless mux_en = 3, so don't worry about asserting this conditionally.
--            update_row_index <= '1';
            
            -- What is this condition for? Is it for the case where we are in mode = 0, and are updating the constant values?  Probably.
            if (mux_en /= 0) then
               -- May need a second (100 MHz) state of asserting update_row_index to ensure that the register (50 MHz) above latches the new value
               update_row_index <= '1';
            end if;
         
         when MODE3_WAIT_FOR_ROW_SWITCH =>
            dac_data_o(0)  <= fast_dac_data( 0);
            dac_data_o(1)  <= fast_dac_data( 1);
            dac_data_o(2)  <= fast_dac_data( 8);
            dac_data_o(3)  <= fast_dac_data( 9);
            dac_data_o(4)  <= fast_dac_data(16);
            dac_data_o(5)  <= fast_dac_data(17);
            dac_data_o(6)  <= fast_dac_data(24);
            dac_data_o(7)  <= fast_dac_data(25);
            dac_data_o(8)  <= fast_dac_data(32);
            dac_data_o(9)  <= fast_dac_data(33);
            dac_data_o(10) <= fast_dac_data(40);

         when others =>

      end case;
   end process row_state_out;

   ------------------------------------------------------------
   --  FSM for signaling when constant values have been written
   ------------------------------------------------------------
   const_state_NS: process(const_current_state, val_changing, restart_frame_aligned_i, update_const_ack)
   begin
      -- Default assignments
      const_next_state <= const_current_state;
      update_const <= '0';

      case const_current_state is
         when IDLE =>
            if(val_changing = '1') then
               const_next_state <= WRITING;
            end if;

         -- The WRITING/ WRITING2/ WRITING3 states are the basis of a timer that determines
         -- if the wishbone transaction is done yet.
         when WRITING =>
            if(val_changing = '0') then
               const_next_state <= WRITING2;
            else
               const_next_state <= WRITING;
            end if;

         when WRITING2 =>
            if(val_changing = '0') then
               const_next_state <= WRITING3;
            else
               const_next_state <= WRITING;
            end if;

         when WRITING3 =>
            if(val_changing = '0') then
               const_next_state <= READY_DELAY;
            else
               const_next_state <= WRITING;
            end if;

         -- We need this state because a WB is done in single word segments (not continuous)
         -- and may overlap into the next data frame.
         -- By giving the WB transaction one whole ARZ cycle, we ensure that it will finish
         -- by the time we are ready to apply the constant values
         when READY_DELAY =>
            if(restart_frame_aligned_i = '1') then
               const_next_state <= UPDATE;
               -- update_constant is asserted here so that it has the same timing as restart_frame_aligned
               update_const <= '1';
            else
               const_next_state <= READY_DELAY;
               update_const <= '0';
            end if;

         when UPDATE =>
            -- This state asserts "update_const" for as long as it needs to be to latch out the new constant values,
            -- depending on which multiplexer mode we are in.
            update_const <= '1';

            if(update_const_ack = '1') then
               const_next_state <= IDLE;
               -- This causes the synthesis to fail. I'm not sure why.
               --update_const <= '0';
            end if;

         when others =>
            const_next_state <= IDLE;
      end case;
   end process const_state_NS;

   ------------------------------------------------------------
   --  WB FSM
   ------------------------------------------------------------
   -- clocked FSMs, advance the state for both FSMs
   state_FF1: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         current_state       <= IDLE;
         const_current_state <= UPDATE;
      elsif(clk_i'event and clk_i = '1') then
         current_state       <= next_state;
         const_current_state <= const_next_state;
      end if;
   end process state_FF1;

   -- Transition table for DAC controller
   state_NS: process(current_state, rd_cmd, wr_cmd, cyc_i)
   begin
      -- Default assignments
      next_state <= current_state;

      case current_state is
         when IDLE =>
            if(wr_cmd = '1') then
               next_state <= WR;
            elsif(rd_cmd = '1') then
               next_state <= RD1;
            end if;

         when WR =>
            if(cyc_i = '0') then
               next_state <= IDLE;
            end if;

         when RD1 =>
            next_state <= RD2;

         when RD2 =>
            if(cyc_i = '0') then
               next_state <= IDLE;
            else
               next_state <= RD1;
            end if;

         when others =>
            next_state <= IDLE;

      end case;
   end process state_NS;

   -- Output states for DAC controller
   state_out: process(current_state, stb_i, addr_i, addr_int, cyc_i, tga_int)
   begin
      -- Default assignments
      fb_wren        <= (others => '0');
      bias_start_wren   <= '0';
      off_val_wren   <= '0';
      on_val_wren    <= '0';
      mux_en_wren    <= '0';
      row_order_wren <= '0';
      ack_o          <= '0';
      val_changing   <= '0';
      mode_wren_vec  <= (others => '0');
      val_wren_vec   <= (others => '0');
      heater_bias_wren_vec <= (others => '0');
      heater_bias_len_wren <= '0';

      case current_state is
         when IDLE  =>

         when WR =>
            if(cyc_i = '1' and stb_i = '1') then
               ack_o <= '1';
            end if;

            if(stb_i = '1') then
               if(addr_i = ON_BIAS_ADDR) then
                  -- We do not assert val_changing here 
                  on_val_wren            <= '1';
               elsif(addr_i = BIAS_START_ADDR) then
                  -- We do not assert val_changing here 
                  bias_start_wren        <= '1';
               elsif(addr_i = HEATER_BIAS_ADDR) then
                  -- We do not assert val_changing here 
                  heater_bias_wren_vec(tga_int) <= '1';
               elsif(addr_i = HEATER_BIAS_LEN_ADDR) then
                  -- We do not assert val_changing here 
                  heater_bias_len_wren   <= '1';
               elsif(addr_i = OFF_BIAS_ADDR) then
                  -- We do not assert val_changing here 
                  off_val_wren           <= '1';
               elsif(addr_i = ENBL_MUX_ADDR) then
                  mux_en_wren            <= '1';
                  -- We assert val_changing here
                  -- Not because we need to update the constant DACs when mux_en goes from 0 -> 1 or 2.
                  -- In this case, the constant values are up to date, and some are overwritten by multiplexed values
                  -- This assertion is critical here because when mux_en goes from 1 or 2 -> 0,
                  -- the latest multiplexed values need to be overwritten with constant values.
                  val_changing           <= '1';
               elsif(addr_i = ROW_ORDER_ADDR) then
                  row_order_wren <= '1';
               elsif((addr_i >= FB_COL0_ADDR) and (addr_i <= FB_COL40_ADDR)) then
                  fb_wren(addr_int)      <= '1';
                  -- We do not assert val_changing here, because when
                  -- mux_en = 0, we are in const mode, and fb_col values do not need to be latched into the DACs
                  -- mux_en = 2, the fb_col value will be latched in during the next frame period.
               elsif(addr_i = CONST_MODE_ADDR) then
                  mode_wren_vec(tga_int) <= '1';
                  -- We should update the constant outputs if either the mode bit or value changes.
                  val_changing           <= '1';
               elsif(addr_i = CONST_VAL_ADDR) then
                  val_wren_vec(tga_int)  <= '1';
                  -- We should update the constant outputs if either the mode bit or value changes.
                  val_changing           <= '1';
               elsif(addr_i = CONST_VAL39_ADDR) then
                  val_wren_vec(39)       <= '1';
                  -- We should update the constant outputs if either the mode bit or value changes.
                  val_changing           <= '1';
               end if;
            end if;

         -- implied that in RD1 ack_o is 0
         when RD2 =>
            ack_o <= '1';

         when others =>

      end case;
   end process state_out;

   ------------------------------------------------------------
   --  Wishbone Control Signals
   ------------------------------------------------------------
   addr_int          <= conv_integer(addr_i(ROW_ADDR_WIDTH-1 downto 0));
   tga_int           <= conv_integer(tga_i(WB_TAG_ADDR_WIDTH-1 downto 0));
   datab_mux         <= datab(addr_int);
   mode_data         <= mode_data_vec(tga_int);
   const_data        <= const_data_vec(tga_int);
   heater_bias_data  <= hb_data_vec(tga_int);

   dat_o <=
      on_datab             when (addr_i = ON_BIAS_ADDR) else
      off_datab            when (addr_i = OFF_BIAS_ADDR) else
      mux_en_data          when (addr_i = ENBL_MUX_ADDR) else
      row_order_data       when (addr_i = ROW_ORDER_ADDR) else
      mode_data            when (addr_i = CONST_MODE_ADDR) else
      const_data           when (addr_i = CONST_VAL_ADDR) else
      const_data_vec(39)   when (addr_i = CONST_VAL39_ADDR) else
      bias_start_datab     when (addr_i = BIAS_START_ADDR) else
      heater_bias_data     when (addr_i = HEATER_BIAS_ADDR) else
      heater_bias_len_data when (addr_i = HEATER_BIAS_LEN_ADDR) else
      datab_mux            when ((addr_i >= FB_COL0_ADDR) and (addr_i <= FB_COL40_ADDR)) else
      (others => '0');

   rd_cmd  <= '1' when
      (stb_i = '1' and cyc_i = '1' and we_i = '0') and
      (addr_i = ON_BIAS_ADDR or
         addr_i = OFF_BIAS_ADDR or
         addr_i = ENBL_MUX_ADDR or
         addr_i = ROW_ORDER_ADDR or
         addr_i = CONST_MODE_ADDR or
         addr_i = CONST_VAL_ADDR or
         addr_i = CONST_VAL39_ADDR or
         addr_i = BIAS_START_ADDR or
         addr_i = HEATER_BIAS_ADDR or
         addr_i = HEATER_BIAS_LEN_ADDR or
         ((addr_i >= FB_COL0_ADDR) and (addr_i <= FB_COL40_ADDR))) else '0';

   wr_cmd  <= '1' when
      (stb_i = '1' and cyc_i = '1' and we_i = '1') and
      (addr_i = ON_BIAS_ADDR or
         addr_i = OFF_BIAS_ADDR or
         addr_i = ENBL_MUX_ADDR or
         addr_i = ROW_ORDER_ADDR or
         addr_i = CONST_MODE_ADDR or
         addr_i = CONST_VAL_ADDR or
         addr_i = CONST_VAL39_ADDR or
         addr_i = BIAS_START_ADDR or
         addr_i = HEATER_BIAS_ADDR or
         addr_i = HEATER_BIAS_LEN_ADDR or
         ((addr_i >= FB_COL0_ADDR) and (addr_i <= FB_COL40_ADDR))) else '0';

   -----------------------------------------------------------------------
   -- RAM Storage
   -----------------------------------------------------------------------
   -- row_dly command handling was moved here from frame_timing because the row-order must drive which delay is used.
   bias_start_ram : tpram_32bit_x_64
      port map(
         data              => dat_i,
         wren              => bias_start_wren,
         wraddress         => tga_i(ROW_ADDR_WIDTH-1 downto 0), 
         rdaddress_a       => row_to_turn_on_slv(ROW_ADDR_WIDTH-1 downto 0),
         rdaddress_b       => tga_i(ROW_ADDR_WIDTH-1 downto 0), 
         clock             => clk_i,
         qa                => bias_start_dataa,
         qb                => bias_start_datab
      );

   on_ram : tpram_32bit_x_64
      port map(
         data              => dat_i,
         wren              => on_val_wren,
         wraddress         => tga_i(ROW_ADDR_WIDTH-1 downto 0), 
         rdaddress_a       => row_to_turn_on_slv(ROW_ADDR_WIDTH-1 downto 0),
         rdaddress_b       => tga_i(ROW_ADDR_WIDTH-1 downto 0), 
         clock             => clk_i,
         qa                => on_dataa,
         qb                => on_datab
      );

   off_ram : tpram_32bit_x_64
      port map(
         data              => dat_i,
         wren              => off_val_wren,
         wraddress         => tga_i(ROW_ADDR_WIDTH-1 downto 0), 
         rdaddress_a       => row_to_turn_off_slv(ROW_ADDR_WIDTH-1 downto 0),
         rdaddress_b       => tga_i(ROW_ADDR_WIDTH-1 downto 0), 
         clock             => clk_i,
         qa                => off_dataa,
         qb                => off_datab
      );

   row_order_ram : tpram_32bit_x_64
      port map(
         data              => dat_i,
         wren              => row_order_wren,
         wraddress         => tga_i(ROW_ADDR_WIDTH-1 downto 0), 
         rdaddress_a       => row_order_index_slv,
         rdaddress_b       => tga_i(ROW_ADDR_WIDTH-1 downto 0), 
         clock             => clk_i,
         qa                => row_to_turn_on_slv,
         qb                => row_order_data
      );

--   heater_bias_ram : tpram_32bit_x_64
--      port map(
--         data              => dat_i,
--         wren              => heater_bias_wren,
--         wraddress         => tga_i(ROW_ADDR_WIDTH-1 downto 0), 
--         rdaddress_a       => row_to_turn_on_slv(ROW_ADDR_WIDTH-1 downto 0),
--         rdaddress_b       => tga_i(ROW_ADDR_WIDTH-1 downto 0), 
--         clock             => clk_i,
--         qa                => heater_bias_dataa,
--         qb                => heater_bias_datab
--      );

   heater_bias_len_reg : reg
      generic map(
         WIDTH             => PACKET_WORD_WIDTH)
      port map(
         clk_i             => clk_i,
         rst_i             => rst_i,
         ena_i             => heater_bias_len_wren,
         reg_i             => dat_i,
         reg_o             => heater_bias_len_data
      );

   mux_en_reg : reg
      generic map(
         WIDTH             => PACKET_WORD_WIDTH)
      port map(
         clk_i             => clk_i,
         rst_i             => rst_i,
         ena_i             => mux_en_wren,
         reg_i             => dat_i,
         reg_o             => mux_en_data
      );


   -----------------------------------------------------------------------------
   -- Instantiation of All SQ2FB Fast Switching RAM Banks
   -----------------------------------------------------------------------------
   ram_bank: for i in 0 to AC_NUM_DACS-1 generate

      pre_reg_data(i) <=
         dataa(i)         (AC_BUS_WIDTH-1 downto 0) when mode_data_vec(i)(0) = '0' and mux_en = 2 else 
         hb_data_vec(i)   (AC_BUS_WIDTH-1 downto 0) when mode_data_vec(i)(0) = '0' and mux_en = 3 else         
         const_data_vec(i)(AC_BUS_WIDTH-1 downto 0);
      
      mode_data_slv(i) <= mode_data_vec(i)(0);

      -- This is a holding register for the data to latch into the DACs
      fast_dac_reg : reg
      generic map(WIDTH => AC_BUS_WIDTH)
      port map(
         clk_i  => clk_i,
         rst_i  => rst_i,
         ena_i  => '1',
         reg_i  => pre_reg_data(i),
         reg_o  => fast_dac_data(i)
      );

--      hb_data_vec_short(i) <= hb_data_vec(i)(AC_BUS_WIDTH-1 downto 0);
      heater_bias_reg : reg
      generic map(WIDTH => WB_DATA_WIDTH)
      port map(
         clk_i  => clk_i,
         rst_i  => rst_i,
         ena_i  => heater_bias_wren_vec(i),
         reg_i  => dat_i,
         reg_o  => hb_data_vec(i)
      );
      
      val_reg : reg
      generic map(WIDTH => WB_DATA_WIDTH)
      port map(
         clk_i  => clk_i,
         rst_i  => rst_i,
         ena_i  => val_wren_vec(i),
         reg_i  => dat_i,
         reg_o  => const_data_vec(i)
      );

      mode_reg : reg
      generic map(WIDTH => WB_DATA_WIDTH)
      port map(
         clk_i  => clk_i,
         rst_i  => rst_i,
         ena_i  => mode_wren_vec(i),
         reg_i  => dat_i,
         reg_o  => mode_data_vec(i)
      );

      ram : tpram_32bit_x_64
      port map(
         data              => dat_i,
         wren              => fb_wren(i),
         wraddress         => tga_i(ROW_ADDR_WIDTH-1 downto 0), 
         rdaddress_a       => row_to_turn_on_slv(ROW_ADDR_WIDTH-1 downto 0),
         rdaddress_b       => tga_i(ROW_ADDR_WIDTH-1 downto 0), 
         clock             => clk_i,
         qa                => dataa(i),
         qb                => datab(i)
      );

   end generate ram_bank;

end rtl;