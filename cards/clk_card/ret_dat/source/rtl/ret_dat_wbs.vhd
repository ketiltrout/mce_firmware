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
-- $Id: ret_dat_wbs.vhd,v 1.23 2010/01/13 20:15:21 bburger Exp $
--
-- Project:       SCUBA2
-- Author:        Bryce Burger
-- Organisation:  UBC
--
-- Description:
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library components;
use components.component_pack.all;

library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;

library work;
use work.ret_dat_wbs_pack.all;
use work.sync_gen_pack.all;
use work.frame_timing_pack.all;

entity ret_dat_wbs is
   port(
      -- to issue_reply:
      start_seq_num_o        : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      stop_seq_num_o         : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      data_rate_o            : out std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);
      internal_cmd_mode_o    : out std_logic_vector(1 downto 0);
      step_period_o          : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      step_minimum_o         : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      step_size_o            : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      step_maximum_o         : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      step_param_id_o        : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      step_card_addr_o       : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      step_data_num_o        : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      run_file_id_o          : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      user_writable_o        : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      stop_delay_o           : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      crc_err_en_o           : out std_logic;
      cards_present_i        : in std_logic_vector(9 downto 0);
      cards_to_report_o      : out std_logic_vector(9 downto 0);
      rcs_to_report_data_o   : out std_logic_vector(9 downto 0);
      ret_dat_req_o          : out std_logic;
      ret_dat_ack_i          : in std_logic;
      mem_dat_o              : out std_logic_vector(MLS_DAT_WIDTH-1 downto 0);
      mem_addr_i             : in std_logic_vector(MLS_ADDR_WIDTH-1 downto 0);
      mem_num_pts_o          : out std_logic_vector(MLS_ADDR_WIDTH-1 downto 0);

      -- global interface
      clk_i                  : in std_logic;
      rst_i                  : in std_logic;

      -- wishbone interface:
      dat_i                  : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      addr_i                 : in std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
      tga_i                  : in std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
      we_i                   : in std_logic;
      stb_i                  : in std_logic;
      cyc_i                  : in std_logic;
      err_o                  : out std_logic;
      dat_o                  : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      ack_o                  : out std_logic
   );
end ret_dat_wbs;

architecture rtl of ret_dat_wbs is

   component mls_data_bank IS
      PORT
      (
         clock    : IN STD_LOGIC  := '1';
         data     : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
         rdaddress      : IN STD_LOGIC_VECTOR (12 DOWNTO 0);
         wraddress      : IN STD_LOGIC_VECTOR (12 DOWNTO 0);
         wren     : IN STD_LOGIC  := '0';
         q     : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
      );
   END component;

   signal mls_mem_dat           : std_logic_vector(MLS_DAT_WIDTH-1 downto 0);
   signal mls_sequence_len_wren : std_logic;
   signal mls_addr_wren         : std_logic;
   signal mls_data_wren         : std_logic;
   signal mls_data_rden         : std_logic;
   signal mls_wr_addr           : std_logic_vector(MLS_ADDR_WIDTH-1 downto 0);
   signal mls_rd_addr           : std_logic_vector(MLS_ADDR_WIDTH-1 downto 0);

   constant DEFAULT_DATA_RATE        : std_logic_vector(WB_DATA_WIDTH-1 downto 0) := x"0000002F";  -- 202.71 Hz Based on 41 rows, 120 cycles per row, 20ns per cycle
   constant STOP_REPLY_WAIT_PERIOD   : std_logic_vector(WB_DATA_WIDTH-1 downto 0) := x"00002710";  -- 10000 u-seconds

   -- FSM inputs
   signal wr_cmd            : std_logic;
   signal rd_cmd            : std_logic;

   -- RAM/Register signals
   signal start_wren             : std_logic;
   signal stop_wren              : std_logic;
   signal data_rate_wren         : std_logic;
   signal tes_tgl_en_wren        : std_logic;
   signal tes_tgl_max_wren       : std_logic;
   signal tes_tgl_min_wren       : std_logic;
   signal tes_tgl_rate_wren      : std_logic;
   signal int_cmd_en_wren        : std_logic;
   signal crc_err_en_wren        : std_logic;
   signal internal_cmd_mode_wren : std_logic;
   signal step_period_wren       : std_logic;
   signal step_minimum_wren      : std_logic;
   signal step_size_wren         : std_logic;
   signal step_maximum_wren      : std_logic;
   signal step_param_id_wren     : std_logic;
   signal step_card_addr_wren    : std_logic;
   signal step_data_num_wren     : std_logic;
   signal run_file_id_wren       : std_logic;
   signal user_writable_wren     : std_logic;
   signal cards_present_wren     : std_logic;
   signal cards_to_report_wren   : std_logic;
   signal ret_dat_req_wren       : std_logic;
   signal stop_delay_wren        : std_logic;
   signal rcs_to_report_wren     : std_logic;

   signal start_data             : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal stop_data              : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal data_rate_data         : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal tes_tgl_en_data        : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal tes_tgl_max_data       : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal tes_tgl_min_data       : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal tes_tgl_rate_data      : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal int_cmd_en_data        : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal crc_err_en_data        : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal internal_cmd_mode_data : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal step_period_data       : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal step_minimum_data      : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal step_size_data         : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal step_maximum_data      : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal step_param_id_data     : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal step_card_addr_data    : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal step_data_num_data     : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal run_file_id_data       : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal user_writable_data     : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal cards_present_data     : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal cards_to_report_data   : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal ret_dat_req_data       : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal ret_dat_card_addr_data : std_logic_vector(WB_DATA_WIDTH-1 downto 0) := (others => '0');
   signal stop_delay_data        : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal rcs_to_report_data     : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal mls_sequence_len_data  : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   
   signal cards_present          : std_logic_vector(WB_DATA_WIDTH-1 downto 0);

   -- WBS states:
   type states is (IDLE, WR, RD1, RD2);
   signal current_state : states;
   signal next_state    : states;
   signal ret_dat_req   : std_logic;

begin

--   ------------------------------------------------------------------------------------------------
--   -- Raw-Mode Signals
--   ------------------------------------------------------------------------------------------------
--   -- We ignore raw_ack_i because we don't want to hang the FSM while the raw RAM fills up.
--   raw_ack    <= raw_ack_i;  
--   raw_req_o  <= raw_req;
--   raw_addr   <= raw_addr_offset(RAW_ADDR_WIDTH-1 downto 0) + tga_i(RAW_ADDR_WIDTH-1 downto 0);
--   raw_dat    <= sxt(raw_dat_i, raw_dat'length) when raw_addr < RAW_ADDR_MAX + 1 else RAW_NULL_DATA;
--   raw_addr_o <= raw_addr;

   -- The mls_rd_addr gets the mls_wr_addr if we are reading from it, otherwise it gets mem_addr_i from the cmd_translator.
   -- The condition here must match the condition below.
   mls_rd_addr <= mls_wr_addr when (mls_data_rden = '1') else mem_addr_i;

   addr_manager: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         mls_wr_addr <= (others => '0');      
      elsif(clk_i'event and clk_i = '1') then
         
         -- Read/Write address management
         if(mls_addr_wren = '1' ) then
            mls_wr_addr <= dat_i(MLS_ADDR_WIDTH-1 downto 0);
         elsif(mls_data_rden = '1') then
            mls_wr_addr <= mls_wr_addr + 1;
         elsif(mls_data_wren = '1') then
            mls_wr_addr <= mls_wr_addr + 1;
         else
            mls_wr_addr <= mls_wr_addr;
         end if;      
         
      end if;
   end process addr_manager;

   mem_num_pts_o <= mls_sequence_len_data(MLS_ADDR_WIDTH-1 downto 0);
   mls_sequence_len_reg : reg
      generic map(WIDTH => WB_DATA_WIDTH)
      port map(
         clk_i             => clk_i,
         rst_i             => rst_i,
         ena_i             => mls_sequence_len_wren,
         reg_i             => dat_i,
         reg_o             => mls_sequence_len_data
      );

   mem_dat_o <= mls_mem_dat;
   mls : mls_data_bank
      port map (
         clock     => clk_i,
         data      => dat_i(15 downto 0),
         rdaddress => mls_rd_addr,
         wraddress => mls_wr_addr,
         wren      => mls_data_wren,
         q         => mls_mem_dat
      );

   internal_cmd_mode_o <=
      "00" when internal_cmd_mode_data = x"00000000" else
      "01" when internal_cmd_mode_data = x"00000001" else
      "10" when internal_cmd_mode_data = x"00000002" else
      "11" when internal_cmd_mode_data = x"00000003" else "00";

   -- Custom register
   cards_to_report_o <= cards_to_report_data(9 downto 0);
   cards_to_report_reg: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         cards_to_report_data <= DEFAULT_CARDS_TO_REPORT;
      elsif(clk_i'event and clk_i = '1') then
         if(cards_to_report_wren = '1') then
            cards_to_report_data <= dat_i;
         end if;
      end if;
   end process cards_to_report_reg;

   -- Custom register
   rcs_to_report_data_o <= rcs_to_report_data(9 downto 0);
   rcs_to_report_reg: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         rcs_to_report_data <= DEFAULT_RCS_TO_REPORT;
      elsif(clk_i'event and clk_i = '1') then
         if(rcs_to_report_wren = '1') then
            rcs_to_report_data <= dat_i;
         end if;
      end if;
   end process rcs_to_report_reg;

   cards_present <= "0000000000000000000000" & cards_present_i;
   cards_present_reg : reg
      generic map(WIDTH => WB_DATA_WIDTH)
      port map(
         clk_i             => clk_i,
         rst_i             => rst_i,
         ena_i             => '1',
         reg_i             => cards_present,
         reg_o             => cards_present_data
      );

   run_file_id_o <= run_file_id_data;
   run_file_id_reg : reg
      generic map(WIDTH => WB_DATA_WIDTH)
      port map(
         clk_i             => clk_i,
         rst_i             => rst_i,
         ena_i             => run_file_id_wren,
         reg_i             => dat_i,
         reg_o             => run_file_id_data
      );

   user_writable_o <= user_writable_data;
   user_writable_reg : reg
      generic map(WIDTH => WB_DATA_WIDTH)
      port map(
         clk_i             => clk_i,
         rst_i             => rst_i,
         ena_i             => user_writable_wren,
         reg_i             => dat_i,
         reg_o             => user_writable_data
      );

   internal_cmd_mode_reg : reg
      generic map(WIDTH => WB_DATA_WIDTH)
      port map(
         clk_i             => clk_i,
         rst_i             => rst_i,
         ena_i             => internal_cmd_mode_wren,
         reg_i             => dat_i,
         reg_o             => internal_cmd_mode_data
      );

   step_period_o <= step_period_data;
   step_period_reg : reg
      generic map(WIDTH => WB_DATA_WIDTH)
      port map(
         clk_i             => clk_i,
         rst_i             => rst_i,
         ena_i             => step_period_wren,
         reg_i             => dat_i,
         reg_o             => step_period_data
      );

   step_minimum_o <= step_minimum_data;
   step_minimum_reg : reg
      generic map(WIDTH => WB_DATA_WIDTH)
      port map(
         clk_i             => clk_i,
         rst_i             => rst_i,
         ena_i             => step_minimum_wren,
         reg_i             => dat_i,
         reg_o             => step_minimum_data
      );

   step_size_o <= step_size_data;
   step_size_reg : reg
      generic map(WIDTH => WB_DATA_WIDTH)
      port map(
         clk_i             => clk_i,
         rst_i             => rst_i,
         ena_i             => step_size_wren,
         reg_i             => dat_i,
         reg_o             => step_size_data
      );

   step_maximum_o <= step_maximum_data;
   step_maximum_reg : reg
      generic map(WIDTH => WB_DATA_WIDTH)
      port map(
         clk_i             => clk_i,
         rst_i             => rst_i,
         ena_i             => step_maximum_wren,
         reg_i             => dat_i,
         reg_o             => step_maximum_data
      );

   step_param_id_o <= step_param_id_data;
   step_param_id_reg : reg
      generic map(WIDTH => WB_DATA_WIDTH)
      port map(
         clk_i             => clk_i,
         rst_i             => rst_i,
         ena_i             => step_param_id_wren,
         reg_i             => dat_i,
         reg_o             => step_param_id_data
      );

   step_card_addr_o <= step_card_addr_data;
   step_card_addr_reg : reg
      generic map(WIDTH => WB_DATA_WIDTH)
      port map(
         clk_i             => clk_i,
         rst_i             => rst_i,
         ena_i             => step_card_addr_wren,
         reg_i             => dat_i,
         reg_o             => step_card_addr_data
      );

   -- Custom register
   step_data_num_o <= step_data_num_data;
   step_data_num_reg: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         step_data_num_data <= DEFAULT_STEP_DATA_NUM;
      elsif(clk_i'event and clk_i = '1') then
         if(step_data_num_wren = '1') then
            step_data_num_data <= dat_i;
         end if;
      end if;
   end process step_data_num_reg;

   -----------------------------------------------------------------------
   start_seq_num_o <= start_data;
   start_reg : reg
      generic map(WIDTH => WB_DATA_WIDTH)
      port map(
         clk_i             => clk_i,
         rst_i             => rst_i,
         ena_i             => start_wren,
         reg_i             => dat_i,
         reg_o             => start_data
      );

   stop_seq_num_o <= stop_data;
   stop_reg : reg
      generic map(WIDTH => WB_DATA_WIDTH)
      port map(
         clk_i             => clk_i,
         rst_i             => rst_i,
         ena_i             => stop_wren,
         reg_i             => dat_i,
         reg_o             => stop_data
      );

   -- Custom register
   stop_delay_o <= stop_delay_data;
   stop_delay_reg: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         stop_delay_data <= STOP_REPLY_WAIT_PERIOD;
      elsif(clk_i'event and clk_i = '1') then
         if(stop_delay_wren = '1') then
            stop_delay_data <= dat_i;
         end if;
      end if;
   end process stop_delay_reg;

   crc_err_en_o <= '0' when crc_err_en_data = x"00000000" else '1';
   crc_error_enable_reg : reg
      generic map(WIDTH => WB_DATA_WIDTH)
      port map(
         clk_i             => clk_i,
         rst_i             => rst_i,
         ena_i             => crc_err_en_wren,
         reg_i             => dat_i,
         reg_o             => crc_err_en_data
      );

   --tes_bias_toggle_en_o <= '0' when tes_tgl_en_data = x"00000000" else '1';
   tes_toggle_enable_reg : reg
      generic map(WIDTH => WB_DATA_WIDTH)
      port map(
         clk_i             => clk_i,
         rst_i             => rst_i,
         ena_i             => tes_tgl_en_wren,
         reg_i             => dat_i,
         reg_o             => tes_tgl_en_data
      );

   --tes_bias_high_o <= tes_tgl_max_data;
   tes_toggle_max_reg : reg
      generic map(WIDTH => WB_DATA_WIDTH)
      port map(
         clk_i             => clk_i,
         rst_i             => rst_i,
         ena_i             => tes_tgl_max_wren,
         reg_i             => dat_i,
         reg_o             => tes_tgl_max_data
      );

   --tes_bias_low_o <= tes_tgl_min_data;
   tes_toggle_min_reg : reg
      generic map(WIDTH => WB_DATA_WIDTH)
      port map(
         clk_i             => clk_i,
         rst_i             => rst_i,
         ena_i             => tes_tgl_min_wren,
         reg_i             => dat_i,
         reg_o             => tes_tgl_min_data
      );

   --tes_bias_toggle_rate_o <= tes_tgl_rate_data;
   tes_toggle_rate_reg : reg
      generic map(WIDTH => WB_DATA_WIDTH)
      port map(
         clk_i             => clk_i,
         rst_i             => rst_i,
         ena_i             => tes_tgl_rate_wren,
         reg_i             => dat_i,
         reg_o             => tes_tgl_rate_data
      );

   --status_cmd_en_o <= '0' when int_cmd_en_data = x"00000000" else '1';
   internal_command_enable_reg : reg
      generic map(WIDTH => WB_DATA_WIDTH)
      port map(
         clk_i             => clk_i,
         rst_i             => rst_i,
         ena_i             => int_cmd_en_wren,
         reg_i             => dat_i,
         reg_o             => int_cmd_en_data
      );

   -- Custom register that gets set to DEFAULT_DATA_RATE upon reset
   data_rate_o <= data_rate_data(SYNC_NUM_WIDTH-1 downto 0);
   data_rate_reg: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         data_rate_data <= DEFAULT_DATA_RATE;
      elsif(clk_i'event and clk_i = '1') then
         if(data_rate_wren = '1') then
            data_rate_data <= dat_i;
         end if;
      end if;
   end process data_rate_reg;

   ret_dat_req_data <= "0000000000000000000000000000000" & ret_dat_req;
   ret_dat_req_o <= ret_dat_req;
   process(rst_i, clk_i)
   begin
      if(rst_i = '1') then
         ret_dat_req <= '0';
      elsif(clk_i'event and clk_i = '1') then
         -- Track ret_dat commands
         if(ret_dat_ack_i = '1') then
            -- Data run is done
            ret_dat_req <= '0';
         elsif(ret_dat_req_wren = '1') then
            if(dat_i /= x"00000000") then
               ret_dat_req <= '1';
            else
               ret_dat_req <= '0';
            end if;
         end if;
      end if;
   end process;

     -- Can't put this here because ret_dat addresses refer to readout cards!!
     -- Eventually this register will be used when the ret_dat handling is moved to this block
     -- Custom register that indicates fresh ret_dat commands
--   ret_dat_req_o <= '0';
--   ret_dat_req_o <= data_req;
--   data_req_reg: process(clk_i, rst_i)
--   begin
--      if(rst_i = '1') then
--         data_req <= '0';
--      elsif(clk_i'event and clk_i = '1') then
--         if(stb_i = '1' and cyc_i = '1' and we_i = '1' and addr_i = RET_DAT_S_ADDR) then
--            data_req <= '1';
--         elsif(ret_dat_ack_i = '1') then
--            data_req <= '0';
--         else
--            data_req <= data_req;
--         end if;
--      end if;
--   end process data_req_reg;

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
               next_state <= RD1;
            end if;

         when WR =>
            if(cyc_i = '0') then
               next_state <= IDLE;
            end if;

         when RD1 =>
            if(cyc_i = '0') then
               next_state <= IDLE;
            else
               -- For reading from the mls RAM only, which has a latency of 3 clock cycles.
               next_state <= RD2;
            end if;

         when RD2 =>
            if(cyc_i = '0') then
               next_state <= IDLE;
            end if;           

         when others =>
            next_state <= IDLE;

      end case;
   end process state_NS;

   -- Output states for DAC controller
   state_out: process(current_state, stb_i, addr_i, tga_i, next_state, wr_cmd, rd_cmd)
   begin
      -- Default assignments
      start_wren             <= '0';
      stop_wren              <= '0';
      data_rate_wren         <= '0';
      tes_tgl_en_wren        <= '0';
      tes_tgl_max_wren       <= '0';
      tes_tgl_min_wren       <= '0';
      tes_tgl_rate_wren      <= '0';
      int_cmd_en_wren        <= '0';
      crc_err_en_wren        <= '0';
      internal_cmd_mode_wren <= '0';
      step_period_wren       <= '0';
      step_minimum_wren      <= '0';
      step_size_wren         <= '0';
      step_maximum_wren      <= '0';
      step_param_id_wren     <= '0';
      step_card_addr_wren    <= '0';
      step_data_num_wren     <= '0';
      run_file_id_wren       <= '0';
      user_writable_wren     <= '0';
      cards_present_wren     <= '0';
      cards_to_report_wren   <= '0';
      rcs_to_report_wren     <= '0';
      ret_dat_req_wren       <= '0';
      stop_delay_wren        <= '0';
      mls_sequence_len_wren  <= '0';
      mls_data_wren          <= '0';
      mls_data_rden          <= '0';
      mls_addr_wren          <= '0';
      ack_o                  <= '0';
      err_o                  <= '0';

      case current_state is
         when IDLE  =>
            ack_o <= '0';

            if(wr_cmd = '1') then
               if(addr_i = MLS_DATA_ADDR) then
                  ack_o <= '1';
                  mls_data_wren <= '1';
               end if;
            elsif(rd_cmd = '1') then
               if(addr_i = MLS_DATA_ADDR) then
                  mls_data_rden <= '1';
               end if;
            end if;

         when WR =>
            if(stb_i = '1') then
               ack_o <= '1';
               if(addr_i = RET_DAT_S_ADDR) then
                  if(tga_i = x"00000000") then
                     start_wren  <= '1';
                  else
                     stop_wren   <= '1';
                  end if;
               elsif(addr_i = RET_DAT_REQ_ADDR) then
                  ret_dat_req_wren <= '1';
               elsif(addr_i = RUN_ID_ADDR) then
                  run_file_id_wren <= '1';
               elsif(addr_i = USER_WRITABLE_ADDR) then
                  user_writable_wren <= '1';
               elsif(addr_i = DATA_RATE_ADDR) then
                  data_rate_wren <= '1';
               elsif(addr_i = TES_TGL_EN_ADDR) then
                  tes_tgl_en_wren <= '1';
               elsif(addr_i = TES_TGL_MAX_ADDR) then
                  tes_tgl_max_wren <= '1';
               elsif(addr_i = TES_TGL_MIN_ADDR) then
                  tes_tgl_min_wren <= '1';
               elsif(addr_i = TES_TGL_RATE_ADDR) then
                  tes_tgl_rate_wren <= '1';
               elsif(addr_i = INT_CMD_EN_ADDR) then
                  int_cmd_en_wren <= '1';
               elsif(addr_i = CRC_ERR_EN_ADDR) then
                  crc_err_en_wren <= '1';
               elsif(addr_i = INTERNAL_CMD_MODE_ADDR) then
                  internal_cmd_mode_wren <= '1';
               elsif(addr_i = RAMP_STEP_PERIOD_ADDR) then
                  step_period_wren <= '1';
               elsif(addr_i = RAMP_MIN_VAL_ADDR) then
                  step_minimum_wren <= '1';
               elsif(addr_i = RAMP_STEP_SIZE_ADDR) then
                  step_size_wren <= '1';
               elsif(addr_i = RAMP_MAX_VAL_ADDR) then
                  step_maximum_wren <= '1';
               elsif(addr_i = RAMP_PARAM_ID_ADDR) then
                  step_param_id_wren <= '1';
               elsif(addr_i = RAMP_CARD_ADDR_ADDR) then
                  step_card_addr_wren <= '1';
               elsif(addr_i = RAMP_STEP_DATA_NUM_ADDR) then
                  step_data_num_wren <= '1';
               elsif(addr_i = CARDS_PRESENT_ADDR) then
                  -- Not writable.
                  err_o <= '1';
               elsif(addr_i = CARDS_TO_REPORT_ADDR) then
                  cards_to_report_wren <= '1';
               elsif(addr_i = RCS_TO_REPORT_DATA_ADDR) then
                  rcs_to_report_wren <= '1';
               elsif(addr_i = STOP_DLY_ADDR) then
                  stop_delay_wren <= '1';
               elsif(addr_i = MLS_SEQUENCE_LEN_ADDR) then
                  mls_sequence_len_wren <= '1';
               elsif(addr_i = MLS_DATA_ADDR) then
                  mls_data_wren <= '1';
               elsif(addr_i = MLS_ADDR_ADDR) then
                  -- Scheme used for writing to/ reading from the mls_data_bank?
                  -- 1- In one WB transaction, write a starting value for the memory write address index (provides more flexibility, at the cost of time)
                  -- 2- In a seperate WB transaction, write 'n' data points starting from the memory write address index
                  --    (a) After each word of the WB is written, the index is incremented by one.
                  --    (b) After the WB is complete, the index is left as its last incremented value (I see nothing wrong with this!)
                  mls_addr_wren <= '1';
               end if;
            end if;

         when RD1 =>
            if(next_state /= IDLE) then
               ack_o <= '1';
               
               if(addr_i = MLS_DATA_ADDR) then
                  -- Don't assert ack_o if we are reading from the RAM becuase of it's 3-cycle latency
                  ack_o <= '0';
                  mls_data_rden <= '1';
               end if;
            end if;

         when RD2 =>
            if(next_state /= IDLE) then
               ack_o <= '1';
               
               if(addr_i = MLS_DATA_ADDR) then
                  mls_data_rden <= '1';
               end if;
            end if;
                        
         when others =>

      end case;
   end process state_out;


   ------------------------------------------------------------
   --  Wishbone interface
   ------------------------------------------------------------
   dat_o <=
      start_data                      when (addr_i = RET_DAT_S_ADDR and tga_i = x"00000000") else
      stop_data                       when (addr_i = RET_DAT_S_ADDR and tga_i /= x"00000000") else
      rcs_to_report_data              when (addr_i = RCS_TO_REPORT_DATA_ADDR) else
      ret_dat_req_data                when (addr_i = RET_DAT_REQ_ADDR) else
      data_rate_data                  when (addr_i = DATA_RATE_ADDR) else
      tes_tgl_en_data                 when (addr_i = TES_TGL_EN_ADDR) else
      tes_tgl_max_data                when (addr_i = TES_TGL_MAX_ADDR) else
      tes_tgl_min_data                when (addr_i = TES_TGL_MIN_ADDR) else
      tes_tgl_rate_data               when (addr_i = TES_TGL_RATE_ADDR) else
      int_cmd_en_data                 when (addr_i = INT_CMD_EN_ADDR) else
      crc_err_en_data                 when (addr_i = CRC_ERR_EN_ADDR) else
      internal_cmd_mode_data          when (addr_i = INTERNAL_CMD_MODE_ADDR) else
      step_period_data                when (addr_i = RAMP_STEP_PERIOD_ADDR) else
      step_minimum_data               when (addr_i = RAMP_MIN_VAL_ADDR) else
      step_size_data                  when (addr_i = RAMP_STEP_SIZE_ADDR) else
      step_maximum_data               when (addr_i = RAMP_MAX_VAL_ADDR) else
      step_param_id_data              when (addr_i = RAMP_PARAM_ID_ADDR) else
      step_card_addr_data             when (addr_i = RAMP_CARD_ADDR_ADDR) else
      step_data_num_data              when (addr_i = RAMP_STEP_DATA_NUM_ADDR) else
      run_file_id_data                when (addr_i = RUN_ID_ADDR) else
      user_writable_data              when (addr_i = USER_WRITABLE_ADDR) else
      cards_present_data              when (addr_i = CARDS_PRESENT_ADDR) else
      cards_to_report_data            when (addr_i = CARDS_TO_REPORT_ADDR) else
      stop_delay_data                 when (addr_i = STOP_DLY_ADDR) else
      mls_sequence_len_data           when (addr_i = MLS_SEQUENCE_LEN_ADDR) else
      ext(mls_wr_addr, WB_DATA_WIDTH) when (addr_i = MLS_ADDR_ADDR) else
      ext(mls_mem_dat, WB_DATA_WIDTH) when (addr_i = MLS_DATA_ADDR) else
      crc_err_en_data                 when (addr_i = CRC_ERR_EN_ADDR) else (others => '0');

   rd_cmd  <= '1' when
      (stb_i = '1' and cyc_i = '1' and we_i = '0') and
      (addr_i = RET_DAT_S_ADDR or
       addr_i = RCS_TO_REPORT_DATA_ADDR or
       addr_i = RET_DAT_REQ_ADDR or
       addr_i = DATA_RATE_ADDR or
       addr_i = TES_TGL_EN_ADDR or
       addr_i = TES_TGL_MAX_ADDR or
       addr_i = TES_TGL_MIN_ADDR or
       addr_i = TES_TGL_RATE_ADDR or
       addr_i = INTERNAL_CMD_MODE_ADDR or
       addr_i = RAMP_STEP_PERIOD_ADDR or
       addr_i = RAMP_MIN_VAL_ADDR or
       addr_i = RAMP_STEP_SIZE_ADDR or
       addr_i = RAMP_MAX_VAL_ADDR or
       addr_i = RAMP_PARAM_ID_ADDR or
       addr_i = RAMP_CARD_ADDR_ADDR or
       addr_i = RAMP_STEP_DATA_NUM_ADDR or
       addr_i = RUN_ID_ADDR or
       addr_i = USER_WRITABLE_ADDR or
       addr_i = INT_CMD_EN_ADDR or
       addr_i = CARDS_PRESENT_ADDR or
       addr_i = CARDS_TO_REPORT_ADDR or
       addr_i = STOP_DLY_ADDR or
       addr_i = MLS_SEQUENCE_LEN_ADDR or
       addr_i = MLS_ADDR_ADDR or
       addr_i = MLS_DATA_ADDR or
       addr_i = CRC_ERR_EN_ADDR) else '0';

   wr_cmd  <= '1' when
      (stb_i = '1' and cyc_i = '1' and we_i = '1') and
      (addr_i = RET_DAT_S_ADDR or
       addr_i = RCS_TO_REPORT_DATA_ADDR or
       addr_i = RET_DAT_REQ_ADDR or
       addr_i = DATA_RATE_ADDR or
       addr_i = TES_TGL_EN_ADDR or
       addr_i = TES_TGL_MAX_ADDR or
       addr_i = TES_TGL_MIN_ADDR or
       addr_i = TES_TGL_RATE_ADDR or
       addr_i = INTERNAL_CMD_MODE_ADDR or
       addr_i = RAMP_STEP_PERIOD_ADDR or
       addr_i = RAMP_MIN_VAL_ADDR or
       addr_i = RAMP_STEP_SIZE_ADDR or
       addr_i = RAMP_MAX_VAL_ADDR or
       addr_i = RAMP_PARAM_ID_ADDR or
       addr_i = RAMP_CARD_ADDR_ADDR or
       addr_i = RAMP_STEP_DATA_NUM_ADDR or
       addr_i = RUN_ID_ADDR or
       addr_i = USER_WRITABLE_ADDR or
       addr_i = INT_CMD_EN_ADDR or
       addr_i = CARDS_PRESENT_ADDR or
       addr_i = CARDS_TO_REPORT_ADDR or
       addr_i = STOP_DLY_ADDR or
       addr_i = MLS_SEQUENCE_LEN_ADDR or
       addr_i = MLS_ADDR_ADDR or
       addr_i = MLS_DATA_ADDR or
       addr_i = CRC_ERR_EN_ADDR) else '0';

end rtl;