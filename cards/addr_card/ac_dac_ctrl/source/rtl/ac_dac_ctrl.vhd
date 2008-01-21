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
-- $Id: ac_dac_ctrl.vhd,v 1.13 2008/01/08 23:23:42 bburger Exp $
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
      dac_clks_o              : out std_logic_vector(NUM_OF_ROWS-1 downto 0);

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
   type row_states is (PRESET1, PRESET2, IDLE, PROPAGATE1, LATCH1, PROPAGATE2, LATCH2, PROPAGATE3, LATCH3,
      PROPAGATE4, LATCH4, WAIT_FOR_NEW_ROW_INDEX, WAIT_FOR_ROW_SWITCH, AC_PROPAGATE_OFF, AC_LATCH_OFF, AC_PROPAGATE_ON,
      AC_LATCH_ON, AC_WAIT_FOR_NEW_ROW_INDEX, AC_WAIT_FOR_ROW_SWITCH);

   signal row_current_state   : row_states;
   signal row_next_state      : row_states;
   signal frame_aligned_reg   : std_logic;
   signal mux_en              : integer range 0 to 2;
   signal prev_row_count      : integer range 0 to (2**ROW_ADDR_WIDTH)-1;
   signal row_count_new       : integer range 0 to (2**ROW_ADDR_WIDTH)-1;

   -- DAC signals
   signal k                   : integer range 0 to AC_NUM_BUSES;
   signal dac_id_int          : integer range 0 to (2**ROW_ADDR_WIDTH)-1;

   signal fb_wren : w1_array41;
   signal dataa : w32_array41;
   signal datab : w32_array41;

   constant DAC_NO_CLKS  : std_logic_vector(NUM_OF_ROWS-1 downto 0) := "00000000000000000000000000000000000000000";
   constant DAC_ALL_CLKS : std_logic_vector(NUM_OF_ROWS-1 downto 0) := "11111111111111111111111111111111111111111";
   constant DAC_CLKS1    : std_logic_vector(NUM_OF_ROWS-1 downto 0) := "10000001100000011000000110000001100000011";
   constant DAC_CLKS2    : std_logic_vector(NUM_OF_ROWS-1 downto 0) := "00000110000001100000011000000110000001100";
   constant DAC_CLKS3    : std_logic_vector(NUM_OF_ROWS-1 downto 0) := "00011000000110000001100000011000000110000";
   constant DAC_CLKS4    : std_logic_vector(NUM_OF_ROWS-1 downto 0) := "01100000011000000110000001100000011000000";

--   constant DAC_CLKS1    : std_logic_vector(NUM_OF_ROWS-1 downto 0) := "11000000110000001100000011000000110000001";
--   constant DAC_CLKS2    : std_logic_vector(NUM_OF_ROWS-1 downto 0) := "00110000001100000011000000110000001100000";
--   constant DAC_CLKS3    : std_logic_vector(NUM_OF_ROWS-1 downto 0) := "00001100000011000000110000001100000011000";
--   constant DAC_CLKS4    : std_logic_vector(NUM_OF_ROWS-1 downto 0) := "00000011000000110000001100000011000000110";

   -----------------------------------------------------------------------
   -- WBS Signals
   -----------------------------------------------------------------------
   component tpram_32bit_x_64
   PORT
   (
         data     : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
         wraddress      : IN STD_LOGIC_VECTOR (ROW_ADDR_WIDTH-1 DOWNTO 0);
         rdaddress_a    : IN STD_LOGIC_VECTOR (ROW_ADDR_WIDTH-1 DOWNTO 0);
         rdaddress_b    : IN STD_LOGIC_VECTOR (ROW_ADDR_WIDTH-1 DOWNTO 0);
         wren     : IN STD_LOGIC  := '1';
         clock    : IN STD_LOGIC ;
         qa    : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
         qb    : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
   );
   end component;

   component tpram_16bit_x_64
   PORT
   (
      clock    : IN STD_LOGIC ;
      data     : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
      rdaddress_a    : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
      rdaddress_b    : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
      wraddress      : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
      wren     : IN STD_LOGIC  := '1';
      qa    : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
      qb    : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
   );
   end component;

   -- FSM inputs
   signal wr_cmd           : std_logic;
   signal rd_cmd           : std_logic;
   signal master_wait      : std_logic;

   -- RAM/Register signals
   signal on_val_wren      : std_logic;
   signal off_val_wren     : std_logic;
   signal row_order_wren   : std_logic;
   signal mux_en_wren      : std_logic;
   signal mux_en_data      : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal on_dataa         : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal off_dataa        : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal on_datab         : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal off_datab        : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal row_order_data   : std_logic_vector(WB_DATA_WIDTH-1 downto 0);

   -- WBS states:
   type states is (IDLE, WR, RD1, RD2);
   signal current_state    : states;
   signal next_state       : states;

   signal addr_int : integer range 0 to (2**ROW_ADDR_WIDTH)-1;
   signal datab_mux : word32;
   signal dac_sel : integer range 0 to 6;

   signal update_row_index : std_logic;

   signal next_row_order_index_int                : integer range 0 to (2**ROW_ADDR_WIDTH)-1;
   signal next_row_order_index_int_new            : integer range 0 to (2**ROW_ADDR_WIDTH)-1;

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
   row_to_turn_on_int <= conv_integer(row_to_turn_on_slv);

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

   registered_inputs : process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         frame_aligned_reg <= '0';
         mux_en            <= 0;
      elsif(clk_i'event and clk_i = '1') then

         if(row_switch_i = '1') then
            frame_aligned_reg <= restart_frame_aligned_i;
         end if;

         if(restart_frame_aligned_i = '1') then
            if(mux_en_data = x"00000000") then
               mux_en <= 0;
            elsif(mux_en_data = x"00000001") then
               mux_en <= 1;
            else
               mux_en <= 2;
            end if;
         end if;

      end if;
   end process registered_inputs;

   ------------------------------------------------------------
   -- clocked FSMs, advance the state for both FSMs
   ------------------------------------------------------------
   state_FF2: process(clk_100_i, rst_i)
   begin
      if(rst_i = '1') then
         row_current_state <= PRESET1;
      elsif(clk_100_i'event and clk_100_i = '1') then
         row_current_state <= row_next_state;
      end if;
   end process state_FF2;

   -- Rework this..
   row_state_NS: process(row_current_state, restart_frame_aligned_i, mux_en, row_switch_i)
   begin
      -- Default assignments
      row_next_state <= row_current_state;

      case row_current_state is
         when PRESET1 =>
            row_next_state <= PRESET2;

         when PRESET2 =>
            row_next_state <= IDLE;

         when IDLE =>
            if(restart_frame_aligned_i = '1' and mux_en = 2) then
               row_next_state <= PROPAGATE1;
            elsif(restart_frame_aligned_i = '1' and mux_en = 1) then
               -- Implement an alternate branch in the FSM here that takes care of the original way of muliplexing on the Address Card
               row_next_state <= AC_PROPAGATE_OFF;
            end if;

         ------------------------------------------------------------------
         --  This is MUX Mode #1:  One DAC turned off and on every new row
         ------------------------------------------------------------------
         when AC_PROPAGATE_OFF =>
            row_next_state <= AC_LATCH_OFF;

         when AC_LATCH_OFF =>
            row_next_state <= AC_PROPAGATE_ON;

         when AC_PROPAGATE_ON =>
            row_next_state <= AC_LATCH_ON;

         when AC_LATCH_ON =>
            row_next_state <= AC_WAIT_FOR_NEW_ROW_INDEX;

         when AC_WAIT_FOR_NEW_ROW_INDEX =>
            row_next_state <= AC_WAIT_FOR_ROW_SWITCH;

         when AC_WAIT_FOR_ROW_SWITCH =>
            if(mux_en = 1 and row_switch_i = '1') then
               row_next_state <= AC_PROPAGATE_OFF;
            elsif(mux_en = 0 and row_switch_i = '1') then
               if(restart_frame_aligned_i = '0') then
                  row_next_state <= AC_PROPAGATE_OFF;
               elsif(restart_frame_aligned_i = '1') then
                  row_next_state <= IDLE;
               end if;
            end if;

         ------------------------------------------------------------------
         --  This is MUX Mode #2:  All 41 DAC values are changed every row
         ------------------------------------------------------------------
         when PROPAGATE1 =>
            -- This delay is here to ensure that the first new value is clocked in at the start of the new frame period.
            row_next_state <= LATCH1;

         when LATCH1 =>
            -- This is the start of the new frame period.
            row_next_state <= PROPAGATE2;

         when PROPAGATE2 =>
            row_next_state <= LATCH2;

         when LATCH2 =>
            row_next_state <= PROPAGATE3;

         when PROPAGATE3 =>
            row_next_state <= LATCH3;

         when LATCH3 =>
            row_next_state <= PROPAGATE4;

         when PROPAGATE4 =>
            row_next_state <= LATCH4;

         when LATCH4 =>
            row_next_state <= WAIT_FOR_NEW_ROW_INDEX;

         when WAIT_FOR_NEW_ROW_INDEX =>
            row_next_state <= WAIT_FOR_ROW_SWITCH;

         when WAIT_FOR_ROW_SWITCH =>
            if(mux_en = 2 and row_switch_i = '1') then
               row_next_state <= PROPAGATE1;
            elsif(mux_en = 0 and row_switch_i = '1') then
               if(restart_frame_aligned_i = '0') then
                  row_next_state <= PROPAGATE1;
               elsif(restart_frame_aligned_i = '1') then
                  row_next_state <= IDLE;
               end if;
            end if;

         when others =>
            row_next_state <= IDLE;
      end case;
   end process row_state_NS;

   -- output states for row selection FSM
   -- In every scan instance, the current row has to be turned on and the previous row has to be turned off
   -- Therefore only 2 DACs are clocked.
   row_state_out: process(row_current_state, row_to_turn_off_int, row_to_turn_on_int)
   begin
      -- Default assignments
      dac_sel    <= 0;
      dac_clks_o <= DAC_NO_CLKS;
      update_row_index <= '0';

      case row_current_state is
         when PRESET1 =>
            dac_sel    <= 0;

         when PRESET2 =>
            -- Set the output of all the DACs to '0'
            dac_sel    <= 0;
            dac_clks_o <= DAC_ALL_CLKS;

         when IDLE =>
            dac_sel    <= 1;

         ------------------------------------------------------------------
         --  This is MUX Mode #1:  One DAC turned off and on every new row
         ------------------------------------------------------------------
         when AC_PROPAGATE_OFF =>
            dac_sel    <= 6;

         when AC_LATCH_OFF =>
            dac_sel    <= 6;
            dac_clks_o(row_to_turn_off_int) <= '1';

         when AC_PROPAGATE_ON =>
            dac_sel    <= 5;

         when AC_LATCH_ON =>
            dac_sel    <= 5;
            dac_clks_o(row_to_turn_on_int) <= '1';
            update_row_index <= '1';

         when AC_WAIT_FOR_NEW_ROW_INDEX =>
            dac_sel    <= 5;
            update_row_index <= '1';

         when AC_WAIT_FOR_ROW_SWITCH =>
            dac_sel    <= 6;

         ------------------------------------------------------------------
         --  This is MUX Mode #2:  All 41 DAC values are changed every row
         ------------------------------------------------------------------
         when PROPAGATE1 =>
            dac_sel    <= 1;

         when LATCH1 =>
            dac_sel    <= 1;
            dac_clks_o <= DAC_CLKS1;

         when PROPAGATE2 =>
            dac_sel    <= 2;

         when LATCH2 =>
            dac_sel    <= 2;
            dac_clks_o <= DAC_CLKS2;

         when PROPAGATE3 =>
            dac_sel    <= 3;

         when LATCH3 =>
            dac_sel    <= 3;
            dac_clks_o <= DAC_CLKS3;

         when PROPAGATE4 =>
            dac_sel    <= 4;

         when LATCH4 =>
            dac_sel    <= 4;
            dac_clks_o <= DAC_CLKS4;
            update_row_index <= '1';

         when WAIT_FOR_NEW_ROW_INDEX =>
            dac_sel    <= 4;
            -- Need a second (100 MHz) state of asserting update_row_index to ensure that the register (50 MHz) above latches the new value
            update_row_index <= '1';

         when WAIT_FOR_ROW_SWITCH =>
            dac_sel    <= 1;

         when others =>

      end case;
   end process row_state_out;

   ------------------------------------------------------------
   --  WB FSM
   ------------------------------------------------------------
   -- clocked FSMs, advance the state for both FSMs
   state_FF1: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         current_state     <= IDLE;
      elsif(clk_i'event and clk_i = '1') then
         current_state     <= next_state;
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
   state_out: process(current_state, stb_i, addr_i, addr_int, cyc_i)
   begin
      -- Default assignments
      fb_wren        <= (others => '0');
      off_val_wren   <= '0';
      on_val_wren    <= '0';
      mux_en_wren    <= '0';
      row_order_wren <= '0';
      ack_o          <= '0';

      case current_state is
         when IDLE  =>
            ack_o <= '0';

         when WR =>
            if(cyc_i = '1' and stb_i = '1') then
               ack_o <= '1';
            end if;

            if(stb_i = '1') then
               if(addr_i = ON_BIAS_ADDR) then
                  on_val_wren <= '1';
               elsif(addr_i = OFF_BIAS_ADDR) then
                  off_val_wren <= '1';
               elsif(addr_i = ENBL_MUX_ADDR) then
                  mux_en_wren <= '1';
               elsif(addr_i = ROW_ORDER_ADDR) then
                  row_order_wren <= '1';
               elsif((addr_i >= FB_COL0_ADDR) and (addr_i <= FB_COL40_ADDR)) then
                  fb_wren(addr_int) <= '1';
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
   addr_int  <= conv_integer(addr_i(ROW_ADDR_WIDTH-1 downto 0));
   datab_mux <= datab(addr_int);

   dat_o     <=
      on_datab        when (addr_i = ON_BIAS_ADDR) else
      off_datab       when (addr_i = OFF_BIAS_ADDR) else
      mux_en_data     when (addr_i = ENBL_MUX_ADDR) else
      row_order_data  when (addr_i = ROW_ORDER_ADDR) else
      datab_mux       when ((addr_i >= FB_COL0_ADDR) and (addr_i <= FB_COL40_ADDR)) else
      (others => '0');

   rd_cmd  <= '1' when
      (stb_i = '1' and cyc_i = '1' and we_i = '0') and
      (addr_i = ON_BIAS_ADDR or addr_i = OFF_BIAS_ADDR or addr_i = ENBL_MUX_ADDR or addr_i = ROW_ORDER_ADDR or ((addr_i >= FB_COL0_ADDR) and (addr_i <= FB_COL40_ADDR))) else '0';

   wr_cmd  <= '1' when
      (stb_i = '1' and cyc_i = '1' and we_i = '1') and
      (addr_i = ON_BIAS_ADDR or addr_i = OFF_BIAS_ADDR or addr_i = ENBL_MUX_ADDR or addr_i = ROW_ORDER_ADDR or ((addr_i >= FB_COL0_ADDR) and (addr_i <= FB_COL40_ADDR))) else '0';

   -----------------------------------------------------------------------
   -- DAC Data MUXes
   -----------------------------------------------------------------------
   dac_data_o(0) <=
      dataa(0) (13 downto 0) when dac_sel = 1 else
      dataa(2) (13 downto 0) when dac_sel = 2 else
      dataa(5) (13 downto 0) when dac_sel = 3 else
      dataa(7) (13 downto 0) when dac_sel = 4 else
      on_dataa (13 downto 0) when dac_sel = 5 else
      off_dataa(13 downto 0) when dac_sel = 6 else
      (others => '0');

   dac_data_o(1) <=
      dataa(1) (13 downto 0) when dac_sel = 1 else
      dataa(3) (13 downto 0) when dac_sel = 2 else
      dataa(4) (13 downto 0) when dac_sel = 3 else
      dataa(6) (13 downto 0) when dac_sel = 4 else
      on_dataa (13 downto 0) when dac_sel = 5 else
      off_dataa(13 downto 0) when dac_sel = 6 else
      (others => '0');

   dac_data_o(2) <=
      dataa(8) (13 downto 0)  when dac_sel = 1 else
      dataa(10)(13 downto 0) when dac_sel = 2 else
      dataa(13)(13 downto 0) when dac_sel = 3 else
      dataa(15)(13 downto 0) when dac_sel = 4 else
      on_dataa (13 downto 0) when dac_sel = 5 else
      off_dataa(13 downto 0) when dac_sel = 6 else
      (others => '0');

   dac_data_o(3) <=
      dataa(9) (13 downto 0)  when dac_sel = 1 else
      dataa(11)(13 downto 0) when dac_sel = 2 else
      dataa(12)(13 downto 0) when dac_sel = 3 else
      dataa(14)(13 downto 0) when dac_sel = 4 else
      on_dataa (13 downto 0) when dac_sel = 5 else
      off_dataa(13 downto 0) when dac_sel = 6 else
      (others => '0');

   dac_data_o(4) <=
      dataa(16)(13 downto 0) when dac_sel = 1 else
      dataa(18)(13 downto 0) when dac_sel = 2 else
      dataa(21)(13 downto 0) when dac_sel = 3 else
      dataa(23)(13 downto 0) when dac_sel = 4 else
      on_dataa (13 downto 0) when dac_sel = 5 else
      off_dataa(13 downto 0) when dac_sel = 6 else
      (others => '0');

   dac_data_o(5) <=
      dataa(17)(13 downto 0) when dac_sel = 1 else
      dataa(19)(13 downto 0) when dac_sel = 2 else
      dataa(20)(13 downto 0) when dac_sel = 3 else
      dataa(22)(13 downto 0) when dac_sel = 4 else
      on_dataa (13 downto 0) when dac_sel = 5 else
      off_dataa(13 downto 0) when dac_sel = 6 else
      (others => '0');

   dac_data_o(6) <=
      dataa(24)(13 downto 0) when dac_sel = 1 else
      dataa(26)(13 downto 0) when dac_sel = 2 else
      dataa(29)(13 downto 0) when dac_sel = 3 else
      dataa(31)(13 downto 0) when dac_sel = 4 else
      on_dataa (13 downto 0) when dac_sel = 5 else
      off_dataa(13 downto 0) when dac_sel = 6 else
      (others => '0');

   dac_data_o(7) <=
      dataa(25)(13 downto 0) when dac_sel = 1 else
      dataa(27)(13 downto 0) when dac_sel = 2 else
      dataa(28)(13 downto 0) when dac_sel = 3 else
      dataa(30)(13 downto 0) when dac_sel = 4 else
      on_dataa (13 downto 0) when dac_sel = 5 else
      off_dataa(13 downto 0) when dac_sel = 6 else
      (others => '0');

   dac_data_o(8) <=
      dataa(32)(13 downto 0) when dac_sel = 1 else
      dataa(34)(13 downto 0) when dac_sel = 2 else
      dataa(37)(13 downto 0) when dac_sel = 3 else
      dataa(39)(13 downto 0) when dac_sel = 4 else
      on_dataa (13 downto 0) when dac_sel = 5 else
      off_dataa(13 downto 0) when dac_sel = 6 else
      (others => '0');

   dac_data_o(9) <=
      dataa(33)(13 downto 0) when dac_sel = 1 else
      dataa(35)(13 downto 0) when dac_sel = 2 else
      dataa(36)(13 downto 0) when dac_sel = 3 else
      dataa(38)(13 downto 0) when dac_sel = 4 else
      on_dataa (13 downto 0) when dac_sel = 5 else
      off_dataa(13 downto 0) when dac_sel = 6 else
      (others => '0');

   -- This data bus is only connected to one DAC
   dac_data_o(10) <=
      dataa(40)(13 downto 0) when dac_sel = 1 else
      dataa(40)(13 downto 0) when dac_sel = 2 else
      dataa(40)(13 downto 0) when dac_sel = 3 else
      dataa(40)(13 downto 0) when dac_sel = 4 else
      on_dataa (13 downto 0) when dac_sel = 5 else
      off_dataa(13 downto 0) when dac_sel = 6 else
      (others => '0');

   -----------------------------------------------------------------------
   -- RAM Storage
   -----------------------------------------------------------------------
   on_ram : tpram_32bit_x_64
      port map
      (
         data              => dat_i,
         wren              => on_val_wren,
         wraddress         => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         rdaddress_a       => row_to_turn_on_slv(ROW_ADDR_WIDTH-1 downto 0),
         rdaddress_b       => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         clock             => clk_i,
         qa                => on_dataa,
         qb                => on_datab
      );

   off_ram : tpram_32bit_x_64
      port map
      (
         data              => dat_i,
         wren              => off_val_wren,
         wraddress         => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         rdaddress_a       => row_to_turn_off_slv(ROW_ADDR_WIDTH-1 downto 0),
         rdaddress_b       => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         clock             => clk_i,
         qa                => off_dataa,
         qb                => off_datab
      );

   row_order_ram : tpram_32bit_x_64
      port map
      (
         data              => dat_i,
         wren              => row_order_wren,
         wraddress         => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         rdaddress_a       => row_order_index_slv,
         rdaddress_b       => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         clock             => clk_i,
         qa                => row_to_turn_on_slv,
         qb                => row_order_data
      );

   mux_en_reg : reg
      generic map(
         WIDTH             => PACKET_WORD_WIDTH
      )
      port map(
         clk_i             => clk_i,
         rst_i             => rst_i,
         ena_i             => mux_en_wren,
         reg_i             => dat_i,
         reg_o             => mux_en_data
      );

   ------------------------
   -- Columns 0-7
   ------------------------
   ram00 : tpram_32bit_x_64
      port map
      (
         data              => dat_i,
         wren              => fb_wren(0),
         wraddress         => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         rdaddress_a       => row_to_turn_on_slv(ROW_ADDR_WIDTH-1 downto 0),
         rdaddress_b       => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         clock             => clk_i,
         qa                => dataa(0),
         qb                => datab(0)
      );

   ram01 : tpram_32bit_x_64
      port map
      (
         data              => dat_i,
         wren              => fb_wren(1),
         wraddress         => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         rdaddress_a       => row_to_turn_on_slv(ROW_ADDR_WIDTH-1 downto 0),
         rdaddress_b       => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         clock             => clk_i,
         qa                => dataa(1),
         qb                => datab(1)
      );

   ram02 : tpram_32bit_x_64
      port map
      (
         data              => dat_i,
         wren              => fb_wren(2),
         wraddress         => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         rdaddress_a       => row_to_turn_on_slv(ROW_ADDR_WIDTH-1 downto 0),
         rdaddress_b       => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         clock             => clk_i,
         qa                => dataa(2),
         qb                => datab(2)
      );

   ram03 : tpram_32bit_x_64
      port map
      (
         data              => dat_i,
         wren              => fb_wren(3),
         wraddress         => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         rdaddress_a       => row_to_turn_on_slv(ROW_ADDR_WIDTH-1 downto 0),
         rdaddress_b       => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         clock             => clk_i,
         qa                => dataa(3),
         qb                => datab(3)
      );

   ram04 : tpram_32bit_x_64
      port map
      (
         data              => dat_i,
         wren              => fb_wren(4),
         wraddress         => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         rdaddress_a       => row_to_turn_on_slv(ROW_ADDR_WIDTH-1 downto 0),
         rdaddress_b       => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         clock             => clk_i,
         qa                => dataa(4),
         qb                => datab(4)
      );

   ram05 : tpram_32bit_x_64
      port map
      (
         data              => dat_i,
         wren              => fb_wren(5),
         wraddress         => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         rdaddress_a       => row_to_turn_on_slv(ROW_ADDR_WIDTH-1 downto 0),
         rdaddress_b       => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         clock             => clk_i,
         qa                => dataa(5),
         qb                => datab(5)
      );

   ram06 : tpram_32bit_x_64
      port map
      (
         data              => dat_i,
         wren              => fb_wren(6),
         wraddress         => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         rdaddress_a       => row_to_turn_on_slv(ROW_ADDR_WIDTH-1 downto 0),
         rdaddress_b       => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         clock             => clk_i,
         qa                => dataa(6),
         qb                => datab(6)
      );

   ram07 : tpram_32bit_x_64
      port map
      (
         data              => dat_i,
         wren              => fb_wren(7),
         wraddress         => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         rdaddress_a       => row_to_turn_on_slv(ROW_ADDR_WIDTH-1 downto 0),
         rdaddress_b       => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         clock             => clk_i,
         qa                => dataa(7),
         qb                => datab(7)
      );

   ------------------------
   -- Columns 8-15
   ------------------------
   ram08 : tpram_32bit_x_64
      port map
      (
         data              => dat_i,
         wren              => fb_wren(8),
         wraddress         => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         rdaddress_a       => row_to_turn_on_slv(ROW_ADDR_WIDTH-1 downto 0),
         rdaddress_b       => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         clock             => clk_i,
         qa                => dataa(8),
         qb                => datab(8)
      );

   ram09 : tpram_32bit_x_64
      port map
      (
         data              => dat_i,
         wren              => fb_wren(9),
         wraddress         => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         rdaddress_a       => row_to_turn_on_slv(ROW_ADDR_WIDTH-1 downto 0),
         rdaddress_b       => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         clock             => clk_i,
         qa                => dataa(9),
         qb                => datab(9)
      );

   ram10 : tpram_32bit_x_64
      port map
      (
         data              => dat_i,
         wren              => fb_wren(10),
         wraddress         => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         rdaddress_a       => row_to_turn_on_slv(ROW_ADDR_WIDTH-1 downto 0),
         rdaddress_b       => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         clock             => clk_i,
         qa                => dataa(10),
         qb                => datab(10)
      );

   ram11 : tpram_32bit_x_64
      port map
      (
         data              => dat_i,
         wren              => fb_wren(11),
         wraddress         => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         rdaddress_a       => row_to_turn_on_slv(ROW_ADDR_WIDTH-1 downto 0),
         rdaddress_b       => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         clock             => clk_i,
         qa                => dataa(11),
         qb                => datab(11)
      );

   ram12 : tpram_32bit_x_64
      port map
      (
         data              => dat_i,
         wren              => fb_wren(12),
         wraddress         => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         rdaddress_a       => row_to_turn_on_slv(ROW_ADDR_WIDTH-1 downto 0),
         rdaddress_b       => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         clock             => clk_i,
         qa                => dataa(12),
         qb                => datab(12)
      );

   ram13 : tpram_32bit_x_64
      port map
      (
         data              => dat_i,
         wren              => fb_wren(13),
         wraddress         => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         rdaddress_a       => row_to_turn_on_slv(ROW_ADDR_WIDTH-1 downto 0),
         rdaddress_b       => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         clock             => clk_i,
         qa                => dataa(13),
         qb                => datab(13)
      );

   ram14 : tpram_32bit_x_64
      port map
      (
         data              => dat_i,
         wren              => fb_wren(14),
         wraddress         => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         rdaddress_a       => row_to_turn_on_slv(ROW_ADDR_WIDTH-1 downto 0),
         rdaddress_b       => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         clock             => clk_i,
         qa                => dataa(14),
         qb                => datab(14)
      );

   ram15 : tpram_32bit_x_64
      port map
      (
         data              => dat_i,
         wren              => fb_wren(15),
         wraddress         => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         rdaddress_a       => row_to_turn_on_slv(ROW_ADDR_WIDTH-1 downto 0),
         rdaddress_b       => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         clock             => clk_i,
         qa                => dataa(15),
         qb                => datab(15)
      );

   ------------------------
   -- Columns 16-23
   ------------------------
   ram16 : tpram_32bit_x_64
      port map
      (
         data              => dat_i,
         wren              => fb_wren(16),
         wraddress         => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         rdaddress_a       => row_to_turn_on_slv(ROW_ADDR_WIDTH-1 downto 0),
         rdaddress_b       => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         clock             => clk_i,
         qa                => dataa(16),
         qb                => datab(16)
      );

   ram17 : tpram_32bit_x_64
      port map
      (
         data              => dat_i,
         wren              => fb_wren(17),
         wraddress         => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         rdaddress_a       => row_to_turn_on_slv(ROW_ADDR_WIDTH-1 downto 0),
         rdaddress_b       => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         clock             => clk_i,
         qa                => dataa(17),
         qb                => datab(17)
      );

   ram18 : tpram_32bit_x_64
      port map
      (
         data              => dat_i,
         wren              => fb_wren(18),
         wraddress         => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         rdaddress_a       => row_to_turn_on_slv(ROW_ADDR_WIDTH-1 downto 0),
         rdaddress_b       => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         clock             => clk_i,
         qa                => dataa(18),
         qb                => datab(18)
      );

   ram19 : tpram_32bit_x_64
      port map
      (
         data              => dat_i,
         wren              => fb_wren(19),
         wraddress         => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         rdaddress_a       => row_to_turn_on_slv(ROW_ADDR_WIDTH-1 downto 0),
         rdaddress_b       => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         clock             => clk_i,
         qa                => dataa(19),
         qb                => datab(19)
      );

   ram20 : tpram_32bit_x_64
      port map
      (
         data              => dat_i,
         wren              => fb_wren(20),
         wraddress         => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         rdaddress_a       => row_to_turn_on_slv(ROW_ADDR_WIDTH-1 downto 0),
         rdaddress_b       => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         clock             => clk_i,
         qa                => dataa(20),
         qb                => datab(20)
      );

   ram21 : tpram_32bit_x_64
      port map
      (
         data              => dat_i,
         wren              => fb_wren(21),
         wraddress         => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         rdaddress_a       => row_to_turn_on_slv(ROW_ADDR_WIDTH-1 downto 0),
         rdaddress_b       => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         clock             => clk_i,
         qa                => dataa(21),
         qb                => datab(21)
      );

   ram22 : tpram_32bit_x_64
      port map
      (
         data              => dat_i,
         wren              => fb_wren(22),
         wraddress         => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         rdaddress_a       => row_to_turn_on_slv(ROW_ADDR_WIDTH-1 downto 0),
         rdaddress_b       => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         clock             => clk_i,
         qa                => dataa(22),
         qb                => datab(22)
      );

   ram23 : tpram_32bit_x_64
      port map
      (
         data              => dat_i,
         wren              => fb_wren(23),
         wraddress         => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         rdaddress_a       => row_to_turn_on_slv(ROW_ADDR_WIDTH-1 downto 0),
         rdaddress_b       => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         clock             => clk_i,
         qa                => dataa(23),
         qb                => datab(23)
      );

   ------------------------
   -- Columns 24-31
   ------------------------
   ram24 : tpram_32bit_x_64
      port map
      (
         data              => dat_i,
         wren              => fb_wren(24),
         wraddress         => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         rdaddress_a       => row_to_turn_on_slv(ROW_ADDR_WIDTH-1 downto 0),
         rdaddress_b       => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         clock             => clk_i,
         qa                => dataa(24),
         qb                => datab(24)
      );

   ram25 : tpram_32bit_x_64
      port map
      (
         data              => dat_i,
         wren              => fb_wren(25),
         wraddress         => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         rdaddress_a       => row_to_turn_on_slv(ROW_ADDR_WIDTH-1 downto 0),
         rdaddress_b       => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         clock             => clk_i,
         qa                => dataa(25),
         qb                => datab(25)
      );

   ram26 : tpram_32bit_x_64
      port map
      (
         data              => dat_i,
         wren              => fb_wren(26),
         wraddress         => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         rdaddress_a       => row_to_turn_on_slv(ROW_ADDR_WIDTH-1 downto 0),
         rdaddress_b       => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         clock             => clk_i,
         qa                => dataa(26),
         qb                => datab(26)
      );

   ram27 : tpram_32bit_x_64
      port map
      (
         data              => dat_i,
         wren              => fb_wren(27),
         wraddress         => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         rdaddress_a       => row_to_turn_on_slv(ROW_ADDR_WIDTH-1 downto 0),
         rdaddress_b       => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         clock             => clk_i,
         qa                => dataa(27),
         qb                => datab(27)
      );

   ram28 : tpram_32bit_x_64
      port map
      (
         data              => dat_i,
         wren              => fb_wren(28),
         wraddress         => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         rdaddress_a       => row_to_turn_on_slv(ROW_ADDR_WIDTH-1 downto 0),
         rdaddress_b       => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         clock             => clk_i,
         qa                => dataa(28),
         qb                => datab(28)
      );

   ram29 : tpram_32bit_x_64
      port map
      (
         data              => dat_i,
         wren              => fb_wren(29),
         wraddress         => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         rdaddress_a       => row_to_turn_on_slv(ROW_ADDR_WIDTH-1 downto 0),
         rdaddress_b       => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         clock             => clk_i,
         qa                => dataa(29),
         qb                => datab(29)
      );

   ram30 : tpram_32bit_x_64
      port map
      (
         data              => dat_i,
         wren              => fb_wren(30),
         wraddress         => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         rdaddress_a       => row_to_turn_on_slv(ROW_ADDR_WIDTH-1 downto 0),
         rdaddress_b       => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         clock             => clk_i,
         qa                => dataa(30),
         qb                => datab(30)
      );

   ram31 : tpram_32bit_x_64
      port map
      (
         data              => dat_i,
         wren              => fb_wren(31),
         wraddress         => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         rdaddress_a       => row_to_turn_on_slv(ROW_ADDR_WIDTH-1 downto 0),
         rdaddress_b       => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         clock             => clk_i,
         qa                => dataa(31),
         qb                => datab(31)
      );

   ------------------------
   -- Columns 32-40
   ------------------------
   ram32 : tpram_32bit_x_64
      port map
      (
         data              => dat_i,
         wren              => fb_wren(32),
         wraddress         => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         rdaddress_a       => row_to_turn_on_slv(ROW_ADDR_WIDTH-1 downto 0),
         rdaddress_b       => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         clock             => clk_i,
         qa                => dataa(32),
         qb                => datab(32)
      );

   ram33 : tpram_32bit_x_64
      port map
      (
         data              => dat_i,
         wren              => fb_wren(33),
         wraddress         => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         rdaddress_a       => row_to_turn_on_slv(ROW_ADDR_WIDTH-1 downto 0),
         rdaddress_b       => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         clock             => clk_i,
         qa                => dataa(33),
         qb                => datab(33)
      );

   ram34 : tpram_32bit_x_64
      port map
      (
         data              => dat_i,
         wren              => fb_wren(34),
         wraddress         => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         rdaddress_a       => row_to_turn_on_slv(ROW_ADDR_WIDTH-1 downto 0),
         rdaddress_b       => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         clock             => clk_i,
         qa                => dataa(34),
         qb                => datab(34)
      );

   ram35 : tpram_32bit_x_64
      port map
      (
         data              => dat_i,
         wren              => fb_wren(35),
         wraddress         => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         rdaddress_a       => row_to_turn_on_slv(ROW_ADDR_WIDTH-1 downto 0),
         rdaddress_b       => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         clock             => clk_i,
         qa                => dataa(35),
         qb                => datab(35)
      );

   ram36 : tpram_32bit_x_64
      port map
      (
         data              => dat_i,
         wren              => fb_wren(36),
         wraddress         => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         rdaddress_a       => row_to_turn_on_slv(ROW_ADDR_WIDTH-1 downto 0),
         rdaddress_b       => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         clock             => clk_i,
         qa                => dataa(36),
         qb                => datab(36)
      );

   ram37 : tpram_32bit_x_64
      port map
      (
         data              => dat_i,
         wren              => fb_wren(37),
         wraddress         => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         rdaddress_a       => row_to_turn_on_slv(ROW_ADDR_WIDTH-1 downto 0),
         rdaddress_b       => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         clock             => clk_i,
         qa                => dataa(37),
         qb                => datab(37)
      );

   ram38 : tpram_32bit_x_64
      port map
      (
         data              => dat_i,
         wren              => fb_wren(38),
         wraddress         => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         rdaddress_a       => row_to_turn_on_slv(ROW_ADDR_WIDTH-1 downto 0),
         rdaddress_b       => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         clock             => clk_i,
         qa                => dataa(38),
         qb                => datab(38)
      );

   ram39 : tpram_32bit_x_64
      port map
      (
         data              => dat_i,
         wren              => fb_wren(39),
         wraddress         => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         rdaddress_a       => row_to_turn_on_slv(ROW_ADDR_WIDTH-1 downto 0),
         rdaddress_b       => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         clock             => clk_i,
         qa                => dataa(39),
         qb                => datab(39)
      );

   ram40 : tpram_32bit_x_64
      port map
      (
         data              => dat_i,
         wren              => fb_wren(40),
         wraddress         => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         rdaddress_a       => row_to_turn_on_slv(ROW_ADDR_WIDTH-1 downto 0),
         rdaddress_b       => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         clock             => clk_i,
         qa                => dataa(40),
         qb                => datab(40)
      );

end rtl;