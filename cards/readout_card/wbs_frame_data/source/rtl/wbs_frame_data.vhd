-- Copyright (c) 2003 SCUBA-2 Project
-- All Rights Reserved
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
-- UBC, University of British chumbia, Physics & Astronomy Department,
-- Vancouver BC, V6T 1Z1
--
-- wbs_frame_data.vhd
--
--
-- Project:          Scuba 2
-- Author:           David Atkinson/ Mandana Amiri/ Bryce Burger
-- Organisation:     UKATC/ UBC
--
-- Description:
--
-- This block is a wishbone slave.  It responds the following commands:
-- READOUT_ROW_INDEX_ADDR
-- READOUT_COL_INDEX_ADDR
-- READOUT_PRIORITY_ADDR
-- RET_DAT_ADDR
-- DATA_MODE_ADDR
-- CAPTR_RAW_ADDR
--
-- It's main function is to collect data from the flux loop control blocks
-- to be read by the wishbone master (dispatch)
--
-- It supports the following data modes:
-- http://e-mode.phas.ubc.ca/mcewiki/index.php/Data_mode
--
-- Revision history:
-- <date $Date: 2009/01/16 02:18:24 $> - <text> - <initials $Author: bburger $>
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;

library work;
use work.wbs_frame_data_pack.all;
use work.flux_loop_pack.all;
use work.readout_card_pack.all;
use work.fsfb_corr_pack.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;

entity wbs_frame_data is
port(
   -- global inputs
   rst_i                     : in  std_logic;                                          -- global reset
   clk_i                     : in  std_logic;                                          -- global clock
   
   num_rows_i                : in integer;
   num_rows_reported_i       : in integer;
   num_cols_reported_i       : in integer;

   -- signal from frame_timing
   restart_frame_1row_post_i : in std_logic;

   -- signals to/from flux_loop_ctrl
   filtered_addr_ch0_o       : out std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- filtered data address - channel 0
   filtered_dat_ch0_i        : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- filtered data - channel 0
   fsfb_addr_ch0_o           : out std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- feedback data address - channel 0
   fsfb_dat_ch0_i            : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- feedback data - channel 0
   flux_cnt_dat_ch0_i        : in  std_logic_vector (FLUX_QUANTA_CNT_WIDTH-1 downto 0);
   coadded_addr_ch0_o        : out std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- co-added data address - channel 0
   coadded_dat_ch0_i         : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- co_added data - channel 0
   raw_addr_ch0_o            : out std_logic_vector (RAW_ADDR_WIDTH-1    downto 0);  -- raw data address - channel 0
   raw_dat_ch0_i             : in  std_logic_vector (RAW_DATA_WIDTH-1    downto 0);  -- raw data - channel 0
   raw_req_ch0_o             : out std_logic;                                        -- raw data request - channel 0
   raw_ack_ch0_i             : in  std_logic;                                        -- raw data acknowledgement - channel 0
                  
   filtered_addr_ch1_o       : out std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- filtered data address - channel 1
   filtered_dat_ch1_i        : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- filtered data - channel 1
   fsfb_addr_ch1_o           : out std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- feedback data address - channel 1
   fsfb_dat_ch1_i            : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- feedback data - channel 1
   flux_cnt_dat_ch1_i        : in  std_logic_vector (FLUX_QUANTA_CNT_WIDTH-1 downto 0);
   coadded_addr_ch1_o        : out std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- co-added data address - channel 1
   coadded_dat_ch1_i         : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- co_added data - channel 1
   raw_addr_ch1_o            : out std_logic_vector (RAW_ADDR_WIDTH-1    downto 0);  -- raw data address - channel 1
   raw_dat_ch1_i             : in  std_logic_vector (RAW_DATA_WIDTH-1    downto 0);  -- raw data - channel 1
   raw_req_ch1_o             : out std_logic;                                        -- raw data request - channel 1
   raw_ack_ch1_i             : in  std_logic;                                        -- raw data acknowledgement - channel 1

   filtered_addr_ch2_o       : out std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- filtered data address - channel 2
   filtered_dat_ch2_i        : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- filtered data - channel 2
   fsfb_addr_ch2_o           : out std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- feedback data address - channel 2
   fsfb_dat_ch2_i            : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- feedback data - channel 2
   flux_cnt_dat_ch2_i        : in  std_logic_vector (FLUX_QUANTA_CNT_WIDTH-1 downto 0);
   coadded_addr_ch2_o        : out std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- co-added data address - channel 2
   coadded_dat_ch2_i         : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- co_added data - channel 2
   raw_addr_ch2_o            : out std_logic_vector (RAW_ADDR_WIDTH-1    downto 0);  -- raw data address - channel 2
   raw_dat_ch2_i             : in  std_logic_vector (RAW_DATA_WIDTH-1    downto 0);  -- raw data - channel 2
   raw_req_ch2_o             : out std_logic;                                        -- raw data request - channel 2
   raw_ack_ch2_i             : in  std_logic;                                        -- raw data acknowledgement - channel 2

   filtered_addr_ch3_o       : out std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- filtered data address - channel 3
   filtered_dat_ch3_i        : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- filtered data - channel 3
   fsfb_addr_ch3_o           : out std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- feedback data address - channel 3
   fsfb_dat_ch3_i            : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- feedback data - channel 3
   flux_cnt_dat_ch3_i        : in  std_logic_vector (FLUX_QUANTA_CNT_WIDTH-1 downto 0);
   coadded_addr_ch3_o        : out std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- co-added data address - channel 3
   coadded_dat_ch3_i         : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- co_added data - channel 3
   raw_addr_ch3_o            : out std_logic_vector (RAW_ADDR_WIDTH-1    downto 0);  -- raw data address - channel 3
   raw_dat_ch3_i             : in  std_logic_vector (RAW_DATA_WIDTH-1    downto 0);  -- raw data - channel 3
   raw_req_ch3_o             : out std_logic;                                        -- raw data request - channel 3
   raw_ack_ch3_i             : in  std_logic;                                        -- raw data acknowledgement - channel 3

   filtered_addr_ch4_o       : out std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- filtered data address - channel 4
   filtered_dat_ch4_i        : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- filtered data - channel 4
   fsfb_addr_ch4_o           : out std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- feedback data address - channel 4
   fsfb_dat_ch4_i            : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- feedback data - channel 4
   flux_cnt_dat_ch4_i        : in  std_logic_vector (FLUX_QUANTA_CNT_WIDTH-1 downto 0);
   coadded_addr_ch4_o        : out std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- co-added data address - channel 4
   coadded_dat_ch4_i         : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- co_added data - channel 4
   raw_addr_ch4_o            : out std_logic_vector (RAW_ADDR_WIDTH-1    downto 0);  -- raw data address - channel 4
   raw_dat_ch4_i             : in  std_logic_vector (RAW_DATA_WIDTH-1    downto 0);   -- raw data - channel 4
   raw_req_ch4_o             : out std_logic;                                        -- raw data request - channel 4
   raw_ack_ch4_i             : in  std_logic;                                        -- raw data acknowledgement - channel 4

   filtered_addr_ch5_o       : out std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- filtered data address - channel 5
   filtered_dat_ch5_i        : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- filtered data - channel 5
   fsfb_addr_ch5_o           : out std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- feedback data address - channel 5
   fsfb_dat_ch5_i            : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- feedback data - channel 5
   flux_cnt_dat_ch5_i        : in  std_logic_vector (FLUX_QUANTA_CNT_WIDTH-1 downto 0);
   coadded_addr_ch5_o        : out std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- co-added data address - channel 5
   coadded_dat_ch5_i         : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- co_added data - channel 5
   raw_addr_ch5_o            : out std_logic_vector (RAW_ADDR_WIDTH-1    downto 0);  -- raw data address - channel 5
   raw_dat_ch5_i             : in  std_logic_vector (RAW_DATA_WIDTH-1    downto 0);  -- raw data - channel 5
   raw_req_ch5_o             : out std_logic;                                        -- raw data request - channel 5
   raw_ack_ch5_i             : in  std_logic;                                        -- raw data acknowledgement - channel 5

   filtered_addr_ch6_o       : out std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- filtered data address - channel 6
   filtered_dat_ch6_i        : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- filtered data - channel 6
   fsfb_addr_ch6_o           : out std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- feedback data address - channel 6
   fsfb_dat_ch6_i            : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- feedback data - channel 6
   flux_cnt_dat_ch6_i        : in  std_logic_vector (FLUX_QUANTA_CNT_WIDTH-1 downto 0);
   coadded_addr_ch6_o        : out std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- co-added data address - channel 6
   coadded_dat_ch6_i         : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- co_added data - channel 6
   raw_addr_ch6_o            : out std_logic_vector (RAW_ADDR_WIDTH-1    downto 0);  -- raw data address - channel 6
   raw_dat_ch6_i             : in  std_logic_vector (RAW_DATA_WIDTH-1    downto 0);  -- raw data - channel 6
   raw_req_ch6_o             : out std_logic;                                        -- raw data request - channel 6
   raw_ack_ch6_i             : in  std_logic;                                        -- raw data acknowledgement - channel 6

   filtered_addr_ch7_o       : out std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- filtered data address - channel 7
   filtered_dat_ch7_i        : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- filtered data - channel 7
   fsfb_addr_ch7_o           : out std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- feedback data address - channel 7
   fsfb_dat_ch7_i            : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- feedback data - channel 7
   flux_cnt_dat_ch7_i        : in  std_logic_vector (FLUX_QUANTA_CNT_WIDTH-1 downto 0);
   coadded_addr_ch7_o        : out std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- co-added data address - channel 7
   coadded_dat_ch7_i         : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- co_added data - channel 7
   raw_addr_ch7_o            : out std_logic_vector (RAW_ADDR_WIDTH-1    downto 0);  -- raw data address - channel 7
   raw_dat_ch7_i             : in  std_logic_vector (RAW_DATA_WIDTH-1    downto 0);  -- raw data - channel 7
   raw_req_ch7_o             : out std_logic;                                        -- raw data request - channel 7
   raw_ack_ch7_i             : in  std_logic;                                        -- raw data acknowledgement - channel 7

   -- signals to/from dispatch  (wishbone interface)
   dat_i                     : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);       -- wishbone data in
   addr_i                    : in std_logic_vector(WB_ADDR_WIDTH-1 downto 0);       -- wishbone address in
   tga_i                     : in std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);   --
   we_i                      : in std_logic;                                        -- write//read enable
   stb_i                     : in std_logic;                                        -- strobe
   cyc_i                     : in std_logic;                                        -- cycle
   err_o                     : out std_logic;
   dat_o                     : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);       -- data out
   ack_o                     : out std_logic                                         -- acknowledge out
);
end wbs_frame_data;

architecture rtl of wbs_frame_data is

   -- wishbone read request enable
   signal read_ret_data          : std_logic;
   
   -- data mode register
   signal data_mode              : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal data_mode_wren         : std_logic ;
   
   -- the row index for frame-rate wishbone data read
   signal row_start_index        : std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
   signal col_start_index        : std_logic_vector (CH_MUX_SEL_WIDTH-1 downto 0);
   signal readout_priority_index : std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);
   signal readout_row_wren       : std_logic;
   signal readout_col_wren       : std_logic;
   signal readout_priority_wren  : std_logic;
   
   -- different types of data read from flux_loop_cntr blocks
   signal error_dat           : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
   signal unfiltered_dat      : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
   signal filtered_dat        : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
   signal fb_error_dat        : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
   signal fb_flx_cnt_dat      : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
   -- signal filtfb_error_dat    : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
   signal filtfb_error_2_dat  : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
   signal filtfb_flx_cnt_dat  : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
   signal filtfb_flx_cnt_dat2 : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
   signal filtfb_flx_cnt_dat3 : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
   signal raw_dat             : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
   
   -- signals for data output multiplexer
   signal dat_out_mux_sel     : std_logic_vector (DAT_MUX_SEL_WIDTH-1 downto 0);
   signal wbs_data            : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   
   -- control signal for raw_addr and pix_addr counters
   signal inc_addr            : std_logic;
   
   -- address used for all modes except raw mode (mode 3)
   signal pix_address         : std_logic_vector (ROW_ADDR_WIDTH+CH_MUX_SEL_WIDTH-1 downto 0);       -- pixel address split for row and channel modes 1,2,3
   signal pix_address_dly1    : std_logic_vector (ROW_ADDR_WIDTH+CH_MUX_SEL_WIDTH-1 downto 0);       -- pixel address split for row and channel modes 1,2,3
   signal pix_address_dly2    : std_logic_vector (ROW_ADDR_WIDTH+CH_MUX_SEL_WIDTH-1 downto 0);       -- pixel address split for row and channel modes 1,2,3
   signal pix_addr_clr        : std_logic;
   signal ch_mux_sel          : std_logic_vector (CH_MUX_SEL_WIDTH-1 downto 0);       -- channel select ch 0 --> 7   
   
   -- channel select needs to be delayed by 2 clock cycles as that the time it take to update data
   -- so an extra register stage...
   signal ch_mux_sel_dly1 : std_logic_vector (CH_MUX_SEL_WIDTH-1 downto 0);
   
   -- address used for raw mode (mode 3)
   signal raw_address     : std_logic_vector (RAW_ADDR_WIDTH+CH_MUX_SEL_WIDTH-1    downto 0);      -- raw 'row' address
   signal raw_addr_clr    : std_logic;
   signal dec_raw_addr    : std_logic;
   signal raw_ch_mux_sel  : std_logic_vector (CH_MUX_SEL_WIDTH-1  downto 0);       -- raw channel select
   
   -- channel select needs to be delayed by 2 clock cycles as that the time it take to update data
   -- so an extra register stage
   signal raw_ch_mux_sel_dly1   : std_logic_vector (CH_MUX_SEL_WIDTH-1 downto 0);
   
   signal raw_req         : std_logic;      -- signal fed to all 8 flux loop cntr channels
   signal raw_ack         : std_logic;      -- ANDedacknowledgements from all 8 flux loop cntr channels
   
   signal dat_rdy         : std_logic;  -- asserted by FSM whne data word ready for read
   signal wb_ack          : std_logic;  -- acknowledge data_mode and capture_raw commands
   
   signal num_rows      : std_logic_vector(ROW_ADDR_WIDTH-1 downto 0);
   signal num_rows_reported : std_logic_vector(ROW_ADDR_WIDTH-1 downto 0);
   signal num_cols_reported : std_logic_vector(CH_MUX_SEL_WIDTH-1 downto 0);
   signal row_index         : std_logic_vector(ROW_ADDR_WIDTH-1 downto 0);
   signal col_index         : std_logic_vector(CH_MUX_SEL_WIDTH-1 downto 0);
   
   -- slave controller FSM
   type state is (IDLE, WSS1, WSS2, READ_DATA, START_RAW, WR_REG, RD_REG, WB_ACK_NOW, WB_ER);   
   signal current_state   : state;
   signal next_state      : state;

begin

   -------------------------------------------------------------------------------------------------
   --                       Wishbone ack
   ------------------------------------------------------------------------------------------------
   read_ret_data <= '1' when (addr_i = RET_DAT_ADDR and stb_i = '1' and cyc_i = '1' and we_i = '0') else '0';
   ack_o <= wb_ack or (dat_rdy and read_ret_data);

   -------------------------------------------------------------------------------------------------
   --                       raw-mode handshake signals
   ------------------------------------------------------------------------------------------------
   raw_ack <= raw_ack_ch0_i and raw_ack_ch1_i and raw_ack_ch2_i and  raw_ack_ch3_i and raw_ack_ch4_i and raw_ack_ch5_i and raw_ack_ch6_i and  raw_ack_ch7_i ;
   raw_req_ch0_o <= raw_req;
   raw_req_ch1_o <= raw_req;
   raw_req_ch2_o <= raw_req;
   raw_req_ch3_o <= raw_req;
   raw_req_ch4_o <= raw_req;
   raw_req_ch5_o <= raw_req;
   raw_req_ch6_o <= raw_req;
   raw_req_ch7_o <= raw_req;

   -------------------------------------------------------------------------------------------------
   --                                  Wishbone FSM
   ------------------------------------------------------------------------------------------------
   clock_fsm : process(clk_i, rst_i )
   begin
      if (rst_i = '1') then
         current_state <= IDLE;
      elsif (clk_i'EVENT AND clk_i = '1') then
         current_state <= next_state;
      end if;
   end process clock_fsm;

   nextstate_fsm: process (current_state, raw_ack, pix_address, raw_address, data_mode,
      addr_i, stb_i, cyc_i, we_i, restart_frame_1row_post_i)
   begin
      next_state <= current_state;

      case current_state is
      when IDLE =>
         if ((addr_i = DATA_MODE_ADDR or addr_i = READOUT_ROW_INDEX_ADDR or addr_i = READOUT_COL_INDEX_ADDR or addr_i = READOUT_PRIORITY_ADDR) and stb_i = '1' and cyc_i = '1') then
            if (we_i = '1') then
               next_state <= WR_REG;
            else
               next_state <= RD_REG;
            end if;
         end if;

         if (addr_i = CAPTR_RAW_ADDR and stb_i = '1' and cyc_i = '1') then
            if (we_i = '1') then
               next_state <= START_RAW;
            else
               next_state <= WB_ACK_NOW;
            end if;
         end if;

         if (addr_i = RET_DAT_ADDR and stb_i = '1' and cyc_i = '1') then
            if we_i = '0' then

              -- For filter mode data wait for the start of the frame before reading back. In that case row 0 is read before
              -- being overwritten by this frame data.
              if(data_mode = MODE2_FILTERED or data_mode = MODE6_FILT_ERROR or data_mode = MODE7_FILT_ERROR2 or data_mode = MODE9_FILT_FLX_CNT or data_mode = MODE10_FILT_FLX_CNT) then
                 if(restart_frame_1row_post_i = '1') then
                    next_state <= WSS1;
                 --else
                 --   next_state <= IDLE;
                 end if;
              else -- filtered data mode
                 next_state <= WSS1;
              end if;

            -- write to ret_dat_addr is invalid
            else
              next_state <= WB_ER;
            end if;
         end if;

      when WR_REG =>
           next_state <= WB_ACK_NOW;

      when RD_REG =>
           next_state <= WB_ACK_NOW;

      when START_RAW  =>
        if raw_ack = '1' then
           next_state <= IDLE;
        end if;

      when WSS1 =>
         next_state <= WSS2;

      when WSS2 =>
         next_state <= READ_DATA;

      when READ_DATA =>
         if data_mode = MODE3_RAW then
            if cyc_i = '0' or raw_address >= RAW_ADDR_MAX-1 or pix_address >= PIXEL_ADDR_MAX+1 then
              next_state <= WB_ACK_NOW;
            end if;
         else
            if pix_address >= PIXEL_ADDR_MAX+1 then
              next_state <= WB_ACK_NOW;
            elsif  cyc_i = '0' then
              next_state <= IDLE;
            else
              next_state <= current_state;
            end if;
         end if;

      when WB_ACK_NOW =>
         next_state <= IDLE;

      when WB_ER =>
         next_state <= IDLE;

      end case;
   end process nextstate_fsm;

   output_fsm: process (current_state, wbs_data, data_mode, row_start_index, addr_i, stb_i, cyc_i, col_start_index, readout_priority_index)
   begin
      -- default states
      pix_addr_clr   <= '0';
      dat_rdy        <= '0';
      data_mode_wren <= '0';
      readout_row_wren <= '0';
      readout_col_wren <= '0';
      readout_priority_wren <= '0';
      wb_ack         <= '0';
      dat_o          <= (others => '0');
      raw_req        <= '0';
      raw_addr_clr   <= '0';
      dec_raw_addr   <= '0';
      inc_addr       <= '0';

      case current_state is

      when IDLE =>
         pix_addr_clr <= '1';

      when WSS1 =>
         inc_addr <= '1'; -- 1 clock cycle to update counter and 2 cycles to get update from the FLC blocks
                              -- total of 3 clock cycles until the next data word is ready to be read by the wishbone master.
      when WSS2 =>
         inc_addr <= '1';

      when READ_DATA =>
         dat_rdy <= '1';
         dat_o  <= wbs_data;
         inc_addr <= '1';

      when START_RAW =>
         raw_addr_clr <= '1';
         raw_req <= '1';
         if (addr_i = CAPTR_RAW_ADDR) then
            wb_ack <= (stb_i and cyc_i);
         end if;

      when WR_REG =>
         if(addr_i = DATA_MODE_ADDR) then
            data_mode_wren <= '1';
         elsif(addr_i = READOUT_ROW_INDEX_ADDR) then
            readout_row_wren <= '1';
         elsif(addr_i = READOUT_COL_INDEX_ADDR) then
            readout_col_wren <= '1';
         elsif(addr_i = READOUT_PRIORITY_ADDR) then
            readout_priority_wren <= '1';
         end if;

      when RD_REG =>
         if(addr_i = DATA_MODE_ADDR) then
            dat_o <= data_mode;
         elsif(addr_i = READOUT_ROW_INDEX_ADDR) then
            dat_o <= ext(row_start_index, WB_DATA_WIDTH);
         elsif(addr_i = READOUT_COL_INDEX_ADDR) then
            dat_o <= ext(col_start_index, WB_DATA_WIDTH);
         elsif(addr_i = READOUT_PRIORITY_ADDR) then
            dat_o <= ext(readout_priority_index, WB_DATA_WIDTH);
         end if;

      when WB_ACK_NOW =>
         if(addr_i = DATA_MODE_ADDR) then
            dat_o <= data_mode;
         elsif(addr_i = READOUT_ROW_INDEX_ADDR) then
            dat_o <= ext(row_start_index, WB_DATA_WIDTH);
         elsif(addr_i = READOUT_COL_INDEX_ADDR) then
            dat_o <= ext(col_start_index, WB_DATA_WIDTH);
         elsif(addr_i = READOUT_PRIORITY_ADDR) then
            dat_o <= ext(readout_priority_index, WB_DATA_WIDTH);
         end if;

         if (addr_i /= RET_DAT_ADDR) then -- both rw for datamode & row_start_index, only read for captr_raw
            wb_ack <= (stb_i and cyc_i);
         else
            dec_raw_addr <= '1';
         end if;

      when WB_ER =>
         wb_ack <= stb_i and cyc_i;
         err_o  <= '1';

      end case;
    end process output_fsm;

-------------------------------------------------------------------------------------------------------------

-- for modes 1,2,3 pixel_addr_cnt is used.  Bits 2 downto 0 determine the channel, and bits 8 downto 3 determine
-- the row.
--
-- the address cycles through:
--
--         (row_0 ch_0), (row_0 ch_1), (row_0 ch_2), (row_0 ch_3), (row_0 ch_4), (row_0 ch_5), (row_0 ch_6), (row_0 ch_7),
--         (row_1 ch_0), (row_1 ch_1), (row_1 ch_2), (row_1 ch_3), (row_1 ch_4), (row_1 ch_5), (row_1 ch_6), (row_1 ch_7),
--                        --
--                        --
--         (row_40 ch_0), (row_40 ch_1), (row_40 ch_2), (row_40 ch_3), (row_40 ch_4), (row_40 ch_5), (row_40 ch_6), (row_40 ch_7),

-- for mode 4  there are  5248 'rows' per channel (2 frames of 64 samples for each of the 41 rows).
--  Again the addressing is such that a 'row' is read from each of the 8 channels, then the next 'row' etc...
--
   num_rows <= conv_std_logic_vector(num_rows_i, ROW_ADDR_WIDTH);
   num_rows_reported <= conv_std_logic_vector(num_rows_reported_i, ROW_ADDR_WIDTH); 
   num_cols_reported <= conv_std_logic_vector(num_cols_reported_i, CH_MUX_SEL_WIDTH);   
   pix_address <= row_index & col_index;
   
   address_counter: process (clk_i, rst_i)
   begin
      if (rst_i = '1') then                         -- asynchronous reset
         row_index    <= (others => '0');
         col_index    <= (others => '0');
         raw_address  <= (others => '0');
      elsif (clk_i'EVENT AND clk_i = '1') then

         -- raw-mode address counter
         if raw_addr_clr = '1' then                 -- synchronous reset
            raw_address <= (others => '0');
         elsif inc_addr = '1' and data_mode = MODE3_RAW then
            if (raw_address < RAW_ADDR_MAX -1 ) then
               raw_address <= raw_address+1;  -- synchronous increment by 1
            end if;
         elsif dec_raw_addr = '1' and data_mode = MODE3_RAW then
            if (raw_address > 3) then
               raw_address <= raw_address-3;  -- this prevents address overrun due to dispatch delay in grabbing data, prepares raw_addr_cnt for next frame grab.
            end if;
         end if;

         -- non-raw-mode address counter
         if pix_addr_clr = '1' then -- and data_mode /= MODE3_RAW then
            row_index <= row_start_index;
            col_index <= col_start_index;
         elsif inc_addr = '1' then
            -- If we read across rows:
            if(readout_priority_index = x"00000000") then
---------------------------------------------------------
-- I can comment this out because columns are mod(8)
---------------------------------------------------------
--               -- If the col index is going to wrap during readout
--               if(col_start_index + num_cols_reported >= 8) then
--                  -- If we're at the last column to report, move to the next row and the first column to report
--                  if(col_index = col_start_index + num_cols_reported - 1) then
--                     -- If we're at the last physical row in the array, wrap to the zeroeth row and the first column to report
--                     if(row_index = num_rows - 1) then
--                        row_index <= (others => '0');
--                        col_index <= col_start_index;
--                     -- Otherwise, go to the next row and the first column to report
--                     else
--                        row_index <= row_index + 1;
--                        col_index <= col_start_index;
--                     end if;
--                  -- Else if we're at the last physical column of the array, wrap to the zeroeth column, but remain on the same row
--                  elsif(col_index = 7) then
--                     row_index <= row_index;
--                     col_index <= col_index + 1;
--                  -- Else move to the next column in the same row
--                  else
--                     row_index <= row_index;
--                     col_index <= col_index + 1;
--                  end if;
--               -- Else if the column index is NOT going to wrap during readout
--               else
                  -- If we're at the last column to report, move to the next row and the first column to report
                  if(col_index = col_start_index + num_cols_reported - 1) then
                     -- If we're at the last physical row in the array, wrap to the zeroeth row and the first column to report
                     if(row_index = num_rows - 1) then
                        row_index <= (others => '0');
                        col_index <= col_start_index;
                     -- Otherwise, go to the next row and the first column to report
                     else
                        row_index <= row_index + 1;
                        col_index <= col_start_index;
                     end if;
                  -- Otherwise move to the next column in the same row
                  else
                     row_index <= row_index; -- Same
                     col_index <= col_index + 1;
                  end if;               
--               end if;
            -- Otherwise, if we read down columns:
            else
               -- If the row_index is going to wrap during readout:
               if(row_start_index + num_rows_reported >= num_rows) then
                  -- If we're at the last row to report, move to the next column and the first row to report
                  if(row_index = num_rows_reported - (num_rows - row_start_index) - 1) then
                     row_index <= row_start_index;
                     col_index <= col_index + 1;
                  -- Else if we're at the last physical row of the array, wrap to the zeroeth row, but remain in the same column
                  elsif(row_index = num_rows - 1) then
                     row_index <= (others => '0');
                     col_index <= col_index;  -- Same
                  -- Otherwise, move to the next row in the same column
                  else
                     row_index <= row_index + 1;
                     col_index <= col_index;  -- Same
                  end if;           
               -- Else if the row index is NOT going to wrap during readout:
               else
                  -- If we're at the last row to report, move to the next column and the first row to report
                  if(row_index = row_start_index + num_rows_reported - 1) then
                     row_index <= row_start_index;
                     col_index <= col_index + 1;                  
                  -- Otherwise, move to the next row in the same column
                  else
                     row_index <= row_index + 1;
                     col_index <= col_index;  -- Same
                  end if;
               end if;
            end if;
         end if;
      end if;
   end process address_counter;

   -- assign counts to bit vectors - modes 1,2,3
   -- note that the LS 3 bits of the address determine the channel
   -- the other bits determine the row address.
   filtered_addr_ch0_o <= pix_address(ROW_ADDR_WIDTH+CH_MUX_SEL_WIDTH-1 downto CH_MUX_SEL_WIDTH);
   fsfb_addr_ch0_o     <= pix_address(ROW_ADDR_WIDTH+CH_MUX_SEL_WIDTH-1 downto CH_MUX_SEL_WIDTH);
   coadded_addr_ch0_o  <= pix_address(ROW_ADDR_WIDTH+CH_MUX_SEL_WIDTH-1 downto CH_MUX_SEL_WIDTH);

   filtered_addr_ch1_o <= pix_address(ROW_ADDR_WIDTH+CH_MUX_SEL_WIDTH-1 downto CH_MUX_SEL_WIDTH);
   fsfb_addr_ch1_o     <= pix_address(ROW_ADDR_WIDTH+CH_MUX_SEL_WIDTH-1 downto CH_MUX_SEL_WIDTH);
   coadded_addr_ch1_o  <= pix_address(ROW_ADDR_WIDTH+CH_MUX_SEL_WIDTH-1 downto CH_MUX_SEL_WIDTH);

   filtered_addr_ch2_o <= pix_address(ROW_ADDR_WIDTH+CH_MUX_SEL_WIDTH-1 downto CH_MUX_SEL_WIDTH);
   fsfb_addr_ch2_o     <= pix_address(ROW_ADDR_WIDTH+CH_MUX_SEL_WIDTH-1 downto CH_MUX_SEL_WIDTH);
   coadded_addr_ch2_o  <= pix_address(ROW_ADDR_WIDTH+CH_MUX_SEL_WIDTH-1 downto CH_MUX_SEL_WIDTH);

   filtered_addr_ch3_o <= pix_address(ROW_ADDR_WIDTH+CH_MUX_SEL_WIDTH-1 downto CH_MUX_SEL_WIDTH);
   fsfb_addr_ch3_o     <= pix_address(ROW_ADDR_WIDTH+CH_MUX_SEL_WIDTH-1 downto CH_MUX_SEL_WIDTH);
   coadded_addr_ch3_o  <= pix_address(ROW_ADDR_WIDTH+CH_MUX_SEL_WIDTH-1 downto CH_MUX_SEL_WIDTH);

   filtered_addr_ch4_o <= pix_address(ROW_ADDR_WIDTH+CH_MUX_SEL_WIDTH-1 downto CH_MUX_SEL_WIDTH);
   fsfb_addr_ch4_o     <= pix_address(ROW_ADDR_WIDTH+CH_MUX_SEL_WIDTH-1 downto CH_MUX_SEL_WIDTH);
   coadded_addr_ch4_o  <= pix_address(ROW_ADDR_WIDTH+CH_MUX_SEL_WIDTH-1 downto CH_MUX_SEL_WIDTH);

   filtered_addr_ch5_o <= pix_address(ROW_ADDR_WIDTH+CH_MUX_SEL_WIDTH-1 downto CH_MUX_SEL_WIDTH);
   fsfb_addr_ch5_o     <= pix_address(ROW_ADDR_WIDTH+CH_MUX_SEL_WIDTH-1 downto CH_MUX_SEL_WIDTH);
   coadded_addr_ch5_o  <= pix_address(ROW_ADDR_WIDTH+CH_MUX_SEL_WIDTH-1 downto CH_MUX_SEL_WIDTH);

   filtered_addr_ch6_o <= pix_address(ROW_ADDR_WIDTH+CH_MUX_SEL_WIDTH-1 downto CH_MUX_SEL_WIDTH);
   fsfb_addr_ch6_o     <= pix_address(ROW_ADDR_WIDTH+CH_MUX_SEL_WIDTH-1 downto CH_MUX_SEL_WIDTH);
   coadded_addr_ch6_o  <= pix_address(ROW_ADDR_WIDTH+CH_MUX_SEL_WIDTH-1 downto CH_MUX_SEL_WIDTH);

   filtered_addr_ch7_o <= pix_address(ROW_ADDR_WIDTH+CH_MUX_SEL_WIDTH-1 downto CH_MUX_SEL_WIDTH);
   fsfb_addr_ch7_o     <= pix_address(ROW_ADDR_WIDTH+CH_MUX_SEL_WIDTH-1 downto CH_MUX_SEL_WIDTH);
   coadded_addr_ch7_o  <= pix_address(ROW_ADDR_WIDTH+CH_MUX_SEL_WIDTH-1 downto CH_MUX_SEL_WIDTH);

   -- assign counts to address vectors - mode 3
   -- the LS  bits determine the channel
   -- the rest the 'row'.

   raw_addr_ch0_o <= raw_address(RAW_ADDR_WIDTH+CH_MUX_SEL_WIDTH-1 downto CH_MUX_SEL_WIDTH);
   raw_addr_ch1_o <= raw_address(RAW_ADDR_WIDTH+CH_MUX_SEL_WIDTH-1 downto CH_MUX_SEL_WIDTH);
   raw_addr_ch2_o <= raw_address(RAW_ADDR_WIDTH+CH_MUX_SEL_WIDTH-1 downto CH_MUX_SEL_WIDTH);
   raw_addr_ch3_o <= raw_address(RAW_ADDR_WIDTH+CH_MUX_SEL_WIDTH-1 downto CH_MUX_SEL_WIDTH);
   raw_addr_ch4_o <= raw_address(RAW_ADDR_WIDTH+CH_MUX_SEL_WIDTH-1 downto CH_MUX_SEL_WIDTH);
   raw_addr_ch5_o <= raw_address(RAW_ADDR_WIDTH+CH_MUX_SEL_WIDTH-1 downto CH_MUX_SEL_WIDTH);
   raw_addr_ch6_o <= raw_address(RAW_ADDR_WIDTH+CH_MUX_SEL_WIDTH-1 downto CH_MUX_SEL_WIDTH);
   raw_addr_ch7_o <= raw_address(RAW_ADDR_WIDTH+CH_MUX_SEL_WIDTH-1 downto CH_MUX_SEL_WIDTH);

   --------------------------------------------------------------------------------------------
   --  Data OUTPUT Select MUX.  These are all the Data Modes present in this firmware!  (key words: data_mode, data mode))
   ---------------------------------------------------------------------------------------------
   -- Note: 1000 or data_mode 8 is skipped for backward compatibility as it was used for different windowing in rc 4.0.4firmware
   dat_out_mux_sel <= data_mode(DAT_MUX_SEL_WIDTH-1 downto 0);

   with dat_out_mux_sel select wbs_data <=
      error_dat           when x"0",
      unfiltered_dat      when x"1",
      filtered_dat        when x"2",
      -- raw_dat             when x"3",
      fb_error_dat        when x"4",
      fb_flx_cnt_dat      when x"5",
      -- filtfb_error_dat    when x"6", -- mod 6 is skipped, as 7 is a better solution
      filtfb_error_2_dat  when x"7",
      -- filtfb_flx_cnt_dat3 when x"8", -- was mixed data: 24b filtered fb + 8b flux-jump counter (revision 4.0.4 only)
      -- filtfb_flx_cnt_dat  when x"9",
      filtfb_flx_cnt_dat2 when x"A",
      "00000000000000000000000" & pix_address_dly2    when x"B",
      (others => '0')     when others;

   --------------------------------------------------------------------------------------------
   --                 Channel select MUXs
   --------------------------------------------------------------------------------------------
   -- Data Mode 0
   with ch_mux_sel select error_dat <=
      coadded_dat_ch0_i(31 downto 0) when "000",
      coadded_dat_ch1_i(31 downto 0) when "001",
      coadded_dat_ch2_i(31 downto 0) when "010",
      coadded_dat_ch3_i(31 downto 0) when "011",
      coadded_dat_ch4_i(31 downto 0) when "100",
      coadded_dat_ch5_i(31 downto 0) when "101",
      coadded_dat_ch6_i(31 downto 0) when "110",
      coadded_dat_ch7_i(31 downto 0) when others;

   -- Data Mode 1
   with ch_mux_sel select unfiltered_dat <=
      fsfb_dat_ch0_i when "000",
      fsfb_dat_ch1_i when "001",
      fsfb_dat_ch2_i when "010",
      fsfb_dat_ch3_i when "011",
      fsfb_dat_ch4_i when "100",
      fsfb_dat_ch5_i when "101",
      fsfb_dat_ch6_i when "110",
      fsfb_dat_ch7_i when others;

   -- Data Mode 2
   with ch_mux_sel select filtered_dat <=
      filtered_dat_ch0_i when "000",
      filtered_dat_ch1_i when "001",
      filtered_dat_ch2_i when "010",
      filtered_dat_ch3_i when "011",
      filtered_dat_ch4_i when "100",
      filtered_dat_ch5_i when "101",
      filtered_dat_ch6_i when "110",
      filtered_dat_ch7_i when others;

   -- Data Mode 3
--   with raw_ch_mux_sel select raw_dat <=
--      sxt(raw_dat_ch0_i, raw_dat'length) when "000",
--      sxt(raw_dat_ch1_i, raw_dat'length) when "001",
--      sxt(raw_dat_ch2_i, raw_dat'length) when "010",
--      sxt(raw_dat_ch3_i, raw_dat'length) when "011",
--      sxt(raw_dat_ch4_i, raw_dat'length) when "100",
--      sxt(raw_dat_ch5_i, raw_dat'length) when "101",
--      sxt(raw_dat_ch6_i, raw_dat'length) when "110",
--      sxt(raw_dat_ch7_i, raw_dat'length) when others;

   -- Data Mode 4
   with ch_mux_sel select fb_error_dat <=
      fsfb_dat_ch0_i(31) & fsfb_dat_ch0_i(LSB_WINDOW_INDEX+16 downto LSB_WINDOW_INDEX) & coadded_dat_ch0_i(31) & coadded_dat_ch0_i(12 downto 0) when "000",
      fsfb_dat_ch1_i(31) & fsfb_dat_ch1_i(LSB_WINDOW_INDEX+16 downto LSB_WINDOW_INDEX) & coadded_dat_ch1_i(31) & coadded_dat_ch1_i(12 downto 0) when "001",
      fsfb_dat_ch2_i(31) & fsfb_dat_ch2_i(LSB_WINDOW_INDEX+16 downto LSB_WINDOW_INDEX) & coadded_dat_ch2_i(31) & coadded_dat_ch2_i(12 downto 0) when "010",
      fsfb_dat_ch3_i(31) & fsfb_dat_ch3_i(LSB_WINDOW_INDEX+16 downto LSB_WINDOW_INDEX) & coadded_dat_ch3_i(31) & coadded_dat_ch3_i(12 downto 0) when "011",
      fsfb_dat_ch4_i(31) & fsfb_dat_ch4_i(LSB_WINDOW_INDEX+16 downto LSB_WINDOW_INDEX) & coadded_dat_ch4_i(31) & coadded_dat_ch4_i(12 downto 0) when "100",
      fsfb_dat_ch5_i(31) & fsfb_dat_ch5_i(LSB_WINDOW_INDEX+16 downto LSB_WINDOW_INDEX) & coadded_dat_ch5_i(31) & coadded_dat_ch5_i(12 downto 0) when "101",
      fsfb_dat_ch6_i(31) & fsfb_dat_ch6_i(LSB_WINDOW_INDEX+16 downto LSB_WINDOW_INDEX) & coadded_dat_ch6_i(31) & coadded_dat_ch6_i(12 downto 0) when "110",
      fsfb_dat_ch7_i(31) & fsfb_dat_ch7_i(LSB_WINDOW_INDEX+16 downto LSB_WINDOW_INDEX) & coadded_dat_ch7_i(31) & coadded_dat_ch7_i(12 downto 0) when others;

   -- Data Mode 5
   with ch_mux_sel select fb_flx_cnt_dat <=
      fsfb_dat_ch0_i (31 downto 8) & flux_cnt_dat_ch0_i when "000",
      fsfb_dat_ch1_i (31 downto 8) & flux_cnt_dat_ch1_i when "001",
      fsfb_dat_ch2_i (31 downto 8) & flux_cnt_dat_ch2_i when "010",
      fsfb_dat_ch3_i (31 downto 8) & flux_cnt_dat_ch3_i when "011",
      fsfb_dat_ch4_i (31 downto 8) & flux_cnt_dat_ch4_i when "100",
      fsfb_dat_ch5_i (31 downto 8) & flux_cnt_dat_ch5_i when "101",
      fsfb_dat_ch6_i (31 downto 8) & flux_cnt_dat_ch6_i when "110",
      fsfb_dat_ch7_i (31 downto 8) & flux_cnt_dat_ch7_i when others;

   -- Data Mode 6
--   with ch_mux_sel select filtfb_error_dat <=
--      filtered_dat_ch0_i(31) & filtered_dat_ch0_i(27 downto 11) & coadded_dat_ch0_i(31) & coadded_dat_ch0_i(12 downto 0) when "000",
--      filtered_dat_ch1_i(31) & filtered_dat_ch1_i(27 downto 11) & coadded_dat_ch1_i(31) & coadded_dat_ch1_i(12 downto 0) when "001",
--      filtered_dat_ch2_i(31) & filtered_dat_ch2_i(27 downto 11) & coadded_dat_ch2_i(31) & coadded_dat_ch2_i(12 downto 0) when "010",
--      filtered_dat_ch3_i(31) & filtered_dat_ch3_i(27 downto 11) & coadded_dat_ch3_i(31) & coadded_dat_ch3_i(12 downto 0) when "011",
--      filtered_dat_ch4_i(31) & filtered_dat_ch4_i(27 downto 11) & coadded_dat_ch4_i(31) & coadded_dat_ch4_i(12 downto 0) when "100",
--      filtered_dat_ch5_i(31) & filtered_dat_ch5_i(27 downto 11) & coadded_dat_ch5_i(31) & coadded_dat_ch5_i(12 downto 0) when "101",
--      filtered_dat_ch6_i(31) & filtered_dat_ch6_i(27 downto 11) & coadded_dat_ch6_i(31) & coadded_dat_ch6_i(12 downto 0) when "110",
--      filtered_dat_ch7_i(31) & filtered_dat_ch7_i(27 downto 11) & coadded_dat_ch7_i(31) & coadded_dat_ch7_i(12 downto 0) when others;

   -- Data Mode 7
   with ch_mux_sel select filtfb_error_2_dat <=
      filtered_dat_ch0_i(31) & filtered_dat_ch0_i(27 downto 7) & coadded_dat_ch0_i(31) & coadded_dat_ch0_i(12 downto 4) when "000",
      filtered_dat_ch1_i(31) & filtered_dat_ch1_i(27 downto 7) & coadded_dat_ch1_i(31) & coadded_dat_ch1_i(12 downto 4) when "001",
      filtered_dat_ch2_i(31) & filtered_dat_ch2_i(27 downto 7) & coadded_dat_ch2_i(31) & coadded_dat_ch2_i(12 downto 4) when "010",
      filtered_dat_ch3_i(31) & filtered_dat_ch3_i(27 downto 7) & coadded_dat_ch3_i(31) & coadded_dat_ch3_i(12 downto 4) when "011",
      filtered_dat_ch4_i(31) & filtered_dat_ch4_i(27 downto 7) & coadded_dat_ch4_i(31) & coadded_dat_ch4_i(12 downto 4) when "100",
      filtered_dat_ch5_i(31) & filtered_dat_ch5_i(27 downto 7) & coadded_dat_ch5_i(31) & coadded_dat_ch5_i(12 downto 4) when "101",
      filtered_dat_ch6_i(31) & filtered_dat_ch6_i(27 downto 7) & coadded_dat_ch6_i(31) & coadded_dat_ch6_i(12 downto 4) when "110",
      filtered_dat_ch7_i(31) & filtered_dat_ch7_i(27 downto 7) & coadded_dat_ch7_i(31) & coadded_dat_ch7_i(12 downto 4) when others;

   -- Data Mode 8
--   with ch_mux_sel select filtfb_flx_cnt_dat3 <=
--      filtered_dat_ch0_i (31 downto 8) & flux_cnt_dat_ch0_i when "000",
--      filtered_dat_ch1_i (31 downto 8) & flux_cnt_dat_ch1_i when "001",
--      filtered_dat_ch2_i (31 downto 8) & flux_cnt_dat_ch2_i when "010",
--      filtered_dat_ch3_i (31 downto 8) & flux_cnt_dat_ch3_i when "011",
--      filtered_dat_ch4_i (31 downto 8) & flux_cnt_dat_ch4_i when "100",
--      filtered_dat_ch5_i (31 downto 8) & flux_cnt_dat_ch5_i when "101",
--      filtered_dat_ch6_i (31 downto 8) & flux_cnt_dat_ch6_i when "110",
--      filtered_dat_ch7_i (31 downto 8) & flux_cnt_dat_ch7_i when others;


   -- Data Mode 9
--   with ch_mux_sel select filtfb_flx_cnt_dat <=
--      filtered_dat_ch0_i(31) & filtered_dat_ch0_i(23 downto 1) & flux_cnt_dat_ch0_i when "000",
--      filtered_dat_ch1_i(31) & filtered_dat_ch1_i(23 downto 1) & flux_cnt_dat_ch1_i when "001",
--      filtered_dat_ch2_i(31) & filtered_dat_ch2_i(23 downto 1) & flux_cnt_dat_ch2_i when "010",
--      filtered_dat_ch3_i(31) & filtered_dat_ch3_i(23 downto 1) & flux_cnt_dat_ch3_i when "011",
--      filtered_dat_ch4_i(31) & filtered_dat_ch4_i(23 downto 1) & flux_cnt_dat_ch4_i when "100",
--      filtered_dat_ch5_i(31) & filtered_dat_ch5_i(23 downto 1) & flux_cnt_dat_ch5_i when "101",
--      filtered_dat_ch6_i(31) & filtered_dat_ch6_i(23 downto 1) & flux_cnt_dat_ch6_i when "110",
--      filtered_dat_ch7_i(31) & filtered_dat_ch7_i(23 downto 1) & flux_cnt_dat_ch7_i when others;

   -- Data Mode 10
   with ch_mux_sel select filtfb_flx_cnt_dat2 <=
      filtered_dat_ch0_i(27 downto 3) & flux_cnt_dat_ch0_i(6 downto 0) when "000",
      filtered_dat_ch1_i(27 downto 3) & flux_cnt_dat_ch1_i(6 downto 0) when "001",
      filtered_dat_ch2_i(27 downto 3) & flux_cnt_dat_ch2_i(6 downto 0) when "010",
      filtered_dat_ch3_i(27 downto 3) & flux_cnt_dat_ch3_i(6 downto 0) when "011",
      filtered_dat_ch4_i(27 downto 3) & flux_cnt_dat_ch4_i(6 downto 0) when "100",
      filtered_dat_ch5_i(27 downto 3) & flux_cnt_dat_ch5_i(6 downto 0) when "101",
      filtered_dat_ch6_i(27 downto 3) & flux_cnt_dat_ch6_i(6 downto 0) when "110",
      filtered_dat_ch7_i(27 downto 3) & flux_cnt_dat_ch7_i(6 downto 0) when others;
      
   -- Data Mode 11
   -- Consists of the pixel address:  6-bit row index, 3-bit column index.
   -- The data output is taken care of by the wbs_data multiplexer. 

   -------------------------------------------------------------------------------------------------
   --                      Data Mode & Readout Row Index Register
   ------------------------------------------------------------------------------------------------
   data_mode_reg: process(clk_i, rst_i)
   begin
      if (rst_i = '1') then
         data_mode <= (others => '0');
      elsif (clk_i'EVENT and clk_i = '1') then
         if data_mode_wren = '1' then
            data_mode <= dat_i;
         end if;
      end if;
   end process data_mode_reg;

   readout_row_reg: process(clk_i, rst_i)
   begin
      if (rst_i = '1') then
         row_start_index <= (others => '0');
      elsif (clk_i'EVENT and clk_i = '1') then
         if readout_row_wren = '1' then
            row_start_index <= dat_i(row_start_index'length -1 downto 0);
         end if;
      end if;
   end process readout_row_reg;

   readout_col_reg: process(clk_i, rst_i)
   begin
      if (rst_i = '1') then
         col_start_index <= (others => '0');
      elsif (clk_i'EVENT and clk_i = '1') then
         if readout_col_wren = '1' then
            col_start_index <= dat_i(col_start_index'length -1 downto 0);
         end if;
      end if;
   end process readout_col_reg;

   readout_priority_reg: process(clk_i, rst_i)
   begin
      if (rst_i = '1') then
         readout_priority_index <= (others => '0');
      elsif (clk_i'EVENT and clk_i = '1') then
         if readout_priority_wren = '1' then
            readout_priority_index <= dat_i(readout_priority_index'length -1 downto 0);
         end if;
      end if;
   end process readout_priority_reg;

   -----------------------------------------------------------------------------------------
   --                                  Channel Select Delay
   -----------------------------------------------------------------------------------------
   -- register channel select twice to add a pipeline delay
   -- required so taht channel select is in sync with data
   ---------------------------------------------------------
   channel_select_delay: process(clk_i, rst_i)
   begin
      if (rst_i = '1') then
         ch_mux_sel_dly1     <= (others => '0');
         ch_mux_sel          <= (others => '0');

         raw_ch_mux_sel_dly1 <= (others => '0');
         raw_ch_mux_sel      <= (others => '0');

         pix_address_dly1    <= (others => '0');
         pix_address_dly2    <= (others => '0');

      elsif (clk_i'EVENT and clk_i = '1') then
         ch_mux_sel_dly1     <= pix_address(CH_MUX_SEL_WIDTH-1 downto 0);
         ch_mux_sel          <= ch_mux_sel_dly1;

         raw_ch_mux_sel_dly1 <= raw_address(CH_MUX_SEL_WIDTH-1 downto 0);
         raw_ch_mux_sel      <= raw_ch_mux_sel_dly1;
         
         pix_address_dly1    <= pix_address;
         pix_address_dly2    <= pix_address_dly1;

      end if;
   end process channel_select_delay;


end rtl;
