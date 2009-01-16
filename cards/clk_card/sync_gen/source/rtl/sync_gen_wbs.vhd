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
-- $Id: sync_gen_wbs.vhd,v 1.9 2007/07/25 18:43:44 bburger Exp $
--
-- Project:       SCUBA2
-- Author:        Bryce Burger
-- Organisation:  UBC
--
-- Description:
-- Wishbone interface for sync_gen
--
-- Revision history:
-- $Log: sync_gen_wbs.vhd,v $
-- Revision 1.9  2007/07/25 18:43:44  bburger
-- BB:  Removed the unused master_wait signal from the sync_gen_wbs interface
--
-- Revision 1.8  2006/05/29 23:11:00  bburger
-- Bryce: Removed unused signals to simplify code and remove warnings from Quartus II
--
-- Revision 1.7  2006/03/09 00:44:13  bburger
-- Bryce:  Added registers and logic for USE_SYNC command
--
-- Revision 1.6  2005/03/16 02:20:58  bburger
-- bryce:  removed mem_clk from the cmd_queue and sync_gen blocks
--
-- Revision 1.5  2005/02/17 22:42:12  bburger
-- Bryce:  changes to synchronization in the MCE in response to two problems
-- - a rising edge on the sync line during configuration
-- - an errant pulse on the restart_frame_1row_post_o from frame_timing block
--
-- Revision 1.4  2005/02/15 00:55:24  bburger
-- Bryce:  removed a register that was associated with timing problems
--
-- Revision 1.3  2005/01/13 03:14:51  bburger
-- Bryce:
-- addr_card and clk_card:  added slot_id functionality, removed mem_clock
-- sync_gen and frame_timing:  added custom counters and registers
--
-- Revision 1.2  2004/11/25 01:34:32  bburger
-- Bryce:  changed signal dv_en interface from integer to std_logic
--
-- Revision 1.1  2004/11/18 05:21:56  bburger
-- Bryce :  modified addr_card top level.  Added ac_dac_ctrl and frame_timing
--
--
--
-----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

library components;
use components.component_pack.all;

library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;

library work;
use work.frame_timing_pack.all;
use work.sync_gen_pack.all;

entity sync_gen_wbs is
   port(
      -- sync_gen interface:
      dv_mode_o           : out std_logic_vector(DV_SELECT_WIDTH-1 downto 0);
      sync_mode_o         : out std_logic_vector(SYNC_SELECT_WIDTH-1 downto 0);
--      row_len_o           : out integer;
--      num_rows_o          : out integer;

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
end sync_gen_wbs;

architecture rtl of sync_gen_wbs is

   -- FSM inputs
   signal wr_cmd          : std_logic;
   signal rd_cmd          : std_logic;

   -- Register signals
   signal dv_mode_wren    : std_logic;
   signal dv_mode_data    : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal sync_mode_wren  : std_logic;
   signal sync_mode_data  : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
--   signal row_length_wren : std_logic;
--   signal row_length_data : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
--   signal num_rows_wren   : std_logic;
--   signal num_rows_data   : std_logic_vector(WB_DATA_WIDTH-1 downto 0);


   -- WBS states:
   type states is (IDLE, WR, RD);
   signal current_state   : states;
   signal next_state      : states;

begin

   dv_en_reg : reg
      generic map(
         WIDTH             => PACKET_WORD_WIDTH
      )
      port map(
         clk_i             => clk_i,
         rst_i             => rst_i,
         ena_i             => dv_mode_wren,
         reg_i             => dat_i,
         reg_o             => dv_mode_data
      );

   sync_mode_reg : reg
      generic map(
         WIDTH             => PACKET_WORD_WIDTH
      )
      port map(
         clk_i             => clk_i,
         rst_i             => rst_i,
         ena_i             => sync_mode_wren,
         reg_i             => dat_i,
         reg_o             => sync_mode_data
      );

--   -- Custom register that gets set to MUX_LINE_PERIOD upon reset
--   row_len_reg: process(clk_i, rst_i)
--   begin
--      if(rst_i = '1') then
--         row_length_data <= std_logic_vector(conv_unsigned(MUX_LINE_PERIOD, PACKET_WORD_WIDTH));  -- 64 time-steps
--      elsif(clk_i'event and clk_i = '1') then
--         if(row_length_wren = '1') then
--            row_length_data <= dat_i;
--         end if;
--      end if;
--   end process row_len_reg;
--
--   -- Custom register that gets set to NUM_OF_ROWS upon reset
--   num_rows_reg: process(clk_i, rst_i)
--   begin
--      if(rst_i = '1') then
--         num_rows_data <= std_logic_vector(conv_unsigned(NUM_OF_ROWS, PACKET_WORD_WIDTH));
--      elsif(clk_i'event and clk_i = '1') then
--         if(num_rows_wren = '1') then
--            num_rows_data <= dat_i;
--         end if;
--      end if;
--   end process num_rows_reg;

--   row_len_o   <= conv_integer(row_length_data);
--   num_rows_o  <= conv_integer(num_rows_data);
   dv_mode_o   <= dv_mode_data(DV_SELECT_WIDTH-1 downto 0);
   sync_mode_o <= sync_mode_data(SYNC_SELECT_WIDTH-1 downto 0);

   ------------------------------------------------------------
   --  WB FSM
   ------------------------------------------------------------

   -- clocked FSMs, advance the state for both FSMs
   state_FF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         current_state     <= IDLE;
      elsif(clk_i'event and clk_i = '1') then
         current_state     <= next_state;
      end if;
   end process state_FF;

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
               next_state <= RD;
            end if;

         when WR =>
            if(cyc_i = '0') then
               next_state <= IDLE;
            end if;

         when RD =>
            if(cyc_i = '0') then
               next_state <= IDLE;
            end if;

         when others =>
            next_state <= IDLE;

      end case;
   end process state_NS;

   -- Output states for DAC controller
   state_out: process(current_state, stb_i, addr_i)
   begin
      -- Default assignments
      ack_o           <= '0';
      dv_mode_wren    <= '0';
--      row_length_wren <= '0';
--      num_rows_wren   <= '0';
      sync_mode_wren  <= '0';

      case current_state is
         when IDLE  =>
            ack_o <= '0';

         when WR =>
            ack_o <= '1';
            if(stb_i = '1') then
               if(addr_i = USE_DV_ADDR) then
                  dv_mode_wren <= '1';
--               elsif(addr_i = ROW_LEN_ADDR) then
--                  row_length_wren <= '1';
--               elsif(addr_i = NUM_ROWS_ADDR) then
--                  num_rows_wren <= '1';
               elsif(addr_i = USE_SYNC_ADDR) then
                  sync_mode_wren <= '1';
               end if;
            end if;

         when RD =>
            ack_o <= '1';

         when others =>

      end case;
   end process state_out;

   ------------------------------------------------------------
   --  Wishbone interface:
   ------------------------------------------------------------
   with addr_i select dat_o <=
      dv_mode_data    when USE_DV_ADDR,
--      row_length_data when ROW_LEN_ADDR,
--      num_rows_data   when NUM_ROWS_ADDR,
      sync_mode_data  when USE_SYNC_ADDR,
      (others => '0') when others;

--   master_wait <= '1' when ( stb_i = '0' and cyc_i = '1') else '0';

   rd_cmd  <= '1' when
      (stb_i = '1' and cyc_i = '1' and we_i = '0') and
--      (addr_i = USE_DV_ADDR or addr_i = ROW_LEN_ADDR or addr_i = NUM_ROWS_ADDR or addr_i = USE_SYNC_ADDR) else '0';
      (addr_i = USE_DV_ADDR or addr_i = USE_SYNC_ADDR) else '0';

   wr_cmd  <= '1' when
      (stb_i = '1' and cyc_i = '1' and we_i = '1') and
--      (addr_i = USE_DV_ADDR or addr_i = ROW_LEN_ADDR or addr_i = NUM_ROWS_ADDR or addr_i = USE_SYNC_ADDR) else '0';
      (addr_i = USE_DV_ADDR or addr_i = USE_SYNC_ADDR) else '0';

end rtl;