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
-- <date $Date: 2012-08-13 22:23:51 $> - <text> - <initials $Author: mandana $>
--
-----------------------------------------------------------------------------


-- To Do:
--x There is a 3-cycle channel delay that needs to be taken account of here
--x There might be one too many pre- and post-delay states below
--x Special checking is needed in COPY_DATA to determing when to stop asserting fsfb signals 2 cycles ahead of time
--x Work on the FSM that reads out the rectangle_mode_fsm, i.e. address pointers etc.
--x Implement a switch between the raw_data_ram and the rectangle_mode_ram
--x rect_addr_offset may need some special handling to handle latency from the ram and to back up by a rectangle of indexes when read comes in....
--x simulate.
--x There is currently a 3-cycle delay that is artificially put in the raw data stream that can be removed once the rectangle mode ram becomes the interface to the wishbone master
--x remove the 3 cycle delay in the wishbone interface -- make it a normal wbs slave!!!!
-- Fix filtered data modes so that they are available on demand.


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use std.textio.all;

library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;

library work;
use work.wbs_frame_data_pack.all;
use work.flux_loop_pack.all;
use work.readout_card_pack.all;
use work.fsfb_corr_pack.all;

entity wbs_frame_data is
port(
   -- global inputs
   rst_i                     : in  std_logic;                                          -- global reset
   clk_i                     : in  std_logic;                                          -- global clock
   
   num_rows_i                : in integer;
   num_rows_reported_i       : in integer;
   num_cols_reported_i       : in integer;
   data_size_i               : in std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);

   -- signal from frame_timing
   restart_frame_1row_post_i : in std_logic;

   -- signals to/from flux_loop_ctrl
   raw_addr_o                : out std_logic_vector (RAW_ADDR_WIDTH-1 downto 0);  
   raw_dat_i                 : in  std_logic_vector (RAW_RAM_WIDTH-1 downto 0);      
   raw_req_o                 : out std_logic;                                        
   raw_ack_i                 : in  std_logic;                                        
   -- Used for raw and rectangle mode
   readout_col_index_o       : out std_logic_vector (COL_ADDR_WIDTH-1 downto 0);
   -- Used for rectangle mode only
   restart_frame_aligned_i   : in std_logic;
   
   global_addr_o             : out std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);
          
   filtered_addr_ch0_o       : out std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- filtered data address - channel 0
   filtered_dat_ch0_i        : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- filtered data - channel 0
   fsfb_addr_ch0_o           : out std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- feedback data address - channel 0
   fsfb_dat_ch0_i            : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- feedback data - channel 0
   flux_cnt_dat_ch0_i        : in  std_logic_vector (FLUX_QUANTA_CNT_WIDTH-1 downto 0);
   coadded_addr_ch0_o        : out std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- co-added data address - channel 0
   coadded_dat_ch0_i         : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- co_added data - channel 0
                  
   filtered_addr_ch1_o       : out std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- filtered data address - channel 1
   filtered_dat_ch1_i        : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- filtered data - channel 1
   fsfb_addr_ch1_o           : out std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- feedback data address - channel 1
   fsfb_dat_ch1_i            : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- feedback data - channel 1
   flux_cnt_dat_ch1_i        : in  std_logic_vector (FLUX_QUANTA_CNT_WIDTH-1 downto 0);
   coadded_addr_ch1_o        : out std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- co-added data address - channel 1
   coadded_dat_ch1_i         : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- co_added data - channel 1

   filtered_addr_ch2_o       : out std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- filtered data address - channel 2
   filtered_dat_ch2_i        : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- filtered data - channel 2
   fsfb_addr_ch2_o           : out std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- feedback data address - channel 2
   fsfb_dat_ch2_i            : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- feedback data - channel 2
   flux_cnt_dat_ch2_i        : in  std_logic_vector (FLUX_QUANTA_CNT_WIDTH-1 downto 0);
   coadded_addr_ch2_o        : out std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- co-added data address - channel 2
   coadded_dat_ch2_i         : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- co_added data - channel 2

   filtered_addr_ch3_o       : out std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- filtered data address - channel 3
   filtered_dat_ch3_i        : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- filtered data - channel 3
   fsfb_addr_ch3_o           : out std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- feedback data address - channel 3
   fsfb_dat_ch3_i            : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- feedback data - channel 3
   flux_cnt_dat_ch3_i        : in  std_logic_vector (FLUX_QUANTA_CNT_WIDTH-1 downto 0);
   coadded_addr_ch3_o        : out std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- co-added data address - channel 3
   coadded_dat_ch3_i         : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- co_added data - channel 3

   filtered_addr_ch4_o       : out std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- filtered data address - channel 4
   filtered_dat_ch4_i        : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- filtered data - channel 4
   fsfb_addr_ch4_o           : out std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- feedback data address - channel 4
   fsfb_dat_ch4_i            : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- feedback data - channel 4
   flux_cnt_dat_ch4_i        : in  std_logic_vector (FLUX_QUANTA_CNT_WIDTH-1 downto 0);
   coadded_addr_ch4_o        : out std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- co-added data address - channel 4
   coadded_dat_ch4_i         : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- co_added data - channel 4

   filtered_addr_ch5_o       : out std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- filtered data address - channel 5
   filtered_dat_ch5_i        : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- filtered data - channel 5
   fsfb_addr_ch5_o           : out std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- feedback data address - channel 5
   fsfb_dat_ch5_i            : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- feedback data - channel 5
   flux_cnt_dat_ch5_i        : in  std_logic_vector (FLUX_QUANTA_CNT_WIDTH-1 downto 0);
   coadded_addr_ch5_o        : out std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- co-added data address - channel 5
   coadded_dat_ch5_i         : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- co_added data - channel 5

   filtered_addr_ch6_o       : out std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- filtered data address - channel 6
   filtered_dat_ch6_i        : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- filtered data - channel 6
   fsfb_addr_ch6_o           : out std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- feedback data address - channel 6
   fsfb_dat_ch6_i            : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- feedback data - channel 6
   flux_cnt_dat_ch6_i        : in  std_logic_vector (FLUX_QUANTA_CNT_WIDTH-1 downto 0);
   coadded_addr_ch6_o        : out std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- co-added data address - channel 6
   coadded_dat_ch6_i         : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- co_added data - channel 6

   filtered_addr_ch7_o       : out std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- filtered data address - channel 7
   filtered_dat_ch7_i        : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- filtered data - channel 7
   fsfb_addr_ch7_o           : out std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- feedback data address - channel 7
   fsfb_dat_ch7_i            : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- feedback data - channel 7
   flux_cnt_dat_ch7_i        : in  std_logic_vector (FLUX_QUANTA_CNT_WIDTH-1 downto 0);
   coadded_addr_ch7_o        : out std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- co-added data address - channel 7
   coadded_dat_ch7_i         : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- co_added data - channel 7

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

   
   signal ack              : std_logic;
   ------------------------------------------------------------------------------------------------
   -- Wishbone read request enable
   ------------------------------------------------------------------------------------------------
   signal wr_cmd           : std_logic;
   signal rd_cmd           : std_logic;
   
   ------------------------------------------------------------------------------------------------
   -- WBS Register Signals
   ------------------------------------------------------------------------------------------------
   signal data_mode              : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal data_mode_wren         : std_logic ;
   signal readout_priority_index : std_logic_vector(ROW_ADDR_WIDTH-1 downto 0);
   signal readout_priority_wren  : std_logic;
   signal readout_row_index      : std_logic_vector(ROW_ADDR_WIDTH-1 downto 0);
   signal readout_row_wren       : std_logic;
   signal readout_col_index      : std_logic_vector(CH_MUX_SEL_WIDTH-1 downto 0);
   signal readout_col_wren       : std_logic;
   
   ------------------------------------------------------------------------------------------------
   -- Different types of data read from flux_loop_cntr blocks
   ------------------------------------------------------------------------------------------------
   signal error_dat           : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal unfiltered_dat      : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal filtered_dat        : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal fb_error_dat        : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal fb_flx_cnt_dat      : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal filtfb_error_2_dat  : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal filtfb_flx_cnt_dat  : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal filtfb_flx_cnt_dat2 : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
--   signal filtfb_flx_cnt_dat3 : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal raw_dat             : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   signal chosen_dat          : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
   
   ------------------------------------------------------------------------------------------------
   -- Address of data to be accessed from the FSFB data queues, except raw modes (3, 12)
   ------------------------------------------------------------------------------------------------
   signal pix_address      : std_logic_vector(ROW_ADDR_WIDTH+CH_MUX_SEL_WIDTH-1 downto 0);   
   signal pix_address_dly1 : std_logic_vector(ROW_ADDR_WIDTH+CH_MUX_SEL_WIDTH-1 downto 0);       
   signal pix_address_dly2 : std_logic_vector(ROW_ADDR_WIDTH+CH_MUX_SEL_WIDTH-1 downto 0);       
   signal pix_addr_clr     : std_logic;
   signal pix_addr_incr    : std_logic;
   signal row_index        : std_logic_vector(ROW_ADDR_WIDTH-1 downto 0);
   signal col_index        : std_logic_vector(CH_MUX_SEL_WIDTH-1 downto 0);
   
   -- channel select ch 0 --> 7
   signal ch_mux_sel       : std_logic_vector(CH_MUX_SEL_WIDTH-1 downto 0);          
   -- channel select needs to be delayed by 2 clock cycles as that the time it take to update data so an extra register stage...
   signal ch_mux_sel_dly1  : std_logic_vector(CH_MUX_SEL_WIDTH-1 downto 0);
   
   ------------------------------------------------------------------------------------------------
   -- Signals used for writing data to the rectangle_mode_ram
   ------------------------------------------------------------------------------------------------
   signal rect_wr_addr     : std_logic_vector (RECT_ADDR_WIDTH-1 DOWNTO 0);
   signal rect_wren        : std_logic  := '1';
   signal rect_wr_addr_inc : std_logic;
   signal rect_wr_addr_clr : std_logic;
   signal rect_wr_addr_dec : std_logic;

   ------------------------------------------------------------------------------------------------
   -- Signals used for reading data out from the rectangle_mode_ram
   ------------------------------------------------------------------------------------------------
   signal rect_addr_offset : std_logic_vector(RECT_ADDR_WIDTH-1 DOWNTO 0);
   signal rect_rd_addr     : std_logic_vector(RECT_ADDR_WIDTH-1 DOWNTO 0);
   signal rect_dat         : std_logic_vector(RECT_RAM_WIDTH-1 DOWNTO 0);
   signal data_size        : std_logic_vector(RECT_ADDR_WIDTH-1 DOWNTO 0);
   
   ------------------------------------------------------------------------------------------------
   -- Signals used for reading data out from the raw_mode_ram
   ------------------------------------------------------------------------------------------------
   signal raw_addr         : std_logic_vector (RAW_ADDR_WIDTH-1 downto 0);  
   signal raw_addr_offset  : std_logic_vector (RAW_ADDR_WIDTH downto 0);      -- raw 'row' address
   signal raw_addr_clr     : std_logic;
   signal raw_addr_save    : std_logic;   
   signal raw_req          : std_logic;  -- signal fed to all 8 flux loop cntr channels
--   signal raw_ack          : std_logic;  -- acknowledgements from all 8 flux loop cntr channels

   ------------------------------------------------------------------------------------------------
   -- Miscellaneous
   ------------------------------------------------------------------------------------------------
   -- signals for data output multiplexer
   signal pid_loop_dat      : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   
   signal num_rows          : std_logic_vector(ROW_ADDR_WIDTH-1 downto 0);
   signal num_rows_reported : std_logic_vector(ROW_ADDR_WIDTH-1 downto 0);
   
   -- The number of columns reported is often 8, so doing use the index "CH_MUX_SEL_WIDTH-1"
   signal num_cols_reported : std_logic_vector(ROW_ADDR_WIDTH-1 downto 0);
   
   -- slave controller FSM
   type state is (IDLE, WR, RD1, RD2);   
   signal current_state : state;
   signal next_state    : state;
   
   ------------------------------------------------------------------------------------------------
   -- Rectangle Mode Signals
   ------------------------------------------------------------------------------------------------
   type rect_states is (IDLE, PRE_DELAY1, PRE_DELAY2, COPY_DATA, POST_DELAY1, POST_DELAY2, DONE, ONE_PIXEL_READOUT);
   signal rect_current_state   : rect_states;
   signal rect_next_state      : rect_states;   

begin

--   -----------------------------------------------------------------------------------------
--   -- Storing simulation data to file
--   -----------------------------------------------------------------------------------------
--   -- storing filter results to files   
--   write_to_file: process (rect_wren) is 
--      file output1 : TEXT open WRITE_MODE is "data05_fsfb_dat_ch0";
--      file output2 : TEXT open WRITE_MODE is "data05_flux_cnt_dat_ch0";
--
--      --variable my_line : LINE;
--      variable my_output_line : LINE;
--   begin
--      if(rect_wren = '1') then -- latches the data from address 0 just before the data switch.
--         write(my_output_line, conv_integer(fsfb_dat_ch0_i));
--         writeline(output1, my_output_line);   
--         write(my_output_line, conv_integer(flux_cnt_dat_ch0_i));
--         writeline(output2, my_output_line);
--      end if;
--   end process write_to_file;
--
--   write_to_file2: process (ack) is 
--      file output3 : TEXT open WRITE_MODE is "data05_data_packets";
--
--      --variable my_line2 : LINE;
--      variable my_output_line2 : LINE;
--   begin
--      if (ack = '1') then
--         write(my_output_line2, conv_integer(rect_dat));
--         writeline(output3, my_output_line2);
--      end if;
--   end process write_to_file2;


   -----------------------------------------------------------------------------------------
   -- Pixel Address Delay for Pipelining Data from the FSFB Queues
   -----------------------------------------------------------------------------------------
   -- register channel select twice to add a 2-cycle pipeline delay required so that channel select is in sync with data
   channel_select_delay: process(clk_i, rst_i)
   begin
      if (rst_i = '1') then
         ch_mux_sel_dly1     <= (others => '0');
         ch_mux_sel          <= (others => '0');

         pix_address_dly1    <= (others => '0');
         pix_address_dly2    <= (others => '0');

      elsif (clk_i'EVENT and clk_i = '1') then
         ch_mux_sel_dly1     <= pix_address(CH_MUX_SEL_WIDTH-1 downto 0);
         ch_mux_sel          <= ch_mux_sel_dly1;
         
         -- For making sure that one is reading the right pixels.
         pix_address_dly1    <= pix_address;
         pix_address_dly2    <= pix_address_dly1;

      end if;
   end process channel_select_delay;

   --------------------------------------------------------------------------------------------
   -- Data MUX for rectangle_mode_ram input
   ---------------------------------------------------------------------------------------------
   with data_mode select pid_loop_dat <=
      error_dat                           when MODE0_ERROR,
      unfiltered_dat                      when MODE1_UNFILTERED,
      filtered_dat                        when MODE2_FILTERED,
      -- RAW_NULL_DATA                       when MODE3_RAW,    
      fb_error_dat                        when MODE4_FB_ERROR,
      fb_flx_cnt_dat                      when MODE5_FB_FLX_CNT,
      -- filtfb_error_dat                    when MODE6_FILT_ERROR, 
      filtfb_error_2_dat                  when MODE7_FILT_ERROR2,
      -- filtfb_flx_cnt_dat3                 when MODE8_FILT_ERROR3, 
      -- filtfb_flx_cnt_dat                  when MODE9_FILT_FLX_CNT,
      filtfb_flx_cnt_dat2                 when MODE10_FILT_FLX_CNT,
      x"00000" & "000" & pix_address_dly2 when MODE11_PIXEL_ADDR,
-- Raw data does not get stored in the rectangle RAM block.      
      -- raw_dat                             when MODE12_RAW_1_COL,   
      RAW_NULL_DATA                       when others;                

   --------------------------------------------------------------------------------------------
   -- Row MUXs for rectangle_mode_ram input
   --------------------------------------------------------------------------------------------
   -- assign counts to bit vectors - modes 1,2,3
   -- note that the LS 3 bits of the address determine the channel
   -- the other bits determine the row address.
   global_addr_o <= pix_address(ROW_ADDR_WIDTH+CH_MUX_SEL_WIDTH-1 downto CH_MUX_SEL_WIDTH);

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

   --------------------------------------------------------------------------------------------
   -- Channel MUXs for rectangle_mode_ram input
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

   -- Data Mode 4
   with ch_mux_sel select fb_error_dat <=
      fsfb_dat_ch0_i(LSB_WINDOW_INDEX+17 downto LSB_WINDOW_INDEX) & coadded_dat_ch0_i(13 downto 0) when "000",
      fsfb_dat_ch1_i(LSB_WINDOW_INDEX+17 downto LSB_WINDOW_INDEX) & coadded_dat_ch1_i(13 downto 0) when "001",
      fsfb_dat_ch2_i(LSB_WINDOW_INDEX+17 downto LSB_WINDOW_INDEX) & coadded_dat_ch2_i(13 downto 0) when "010",
      fsfb_dat_ch3_i(LSB_WINDOW_INDEX+17 downto LSB_WINDOW_INDEX) & coadded_dat_ch3_i(13 downto 0) when "011",
      fsfb_dat_ch4_i(LSB_WINDOW_INDEX+17 downto LSB_WINDOW_INDEX) & coadded_dat_ch4_i(13 downto 0) when "100",
      fsfb_dat_ch5_i(LSB_WINDOW_INDEX+17 downto LSB_WINDOW_INDEX) & coadded_dat_ch5_i(13 downto 0) when "101",
      fsfb_dat_ch6_i(LSB_WINDOW_INDEX+17 downto LSB_WINDOW_INDEX) & coadded_dat_ch6_i(13 downto 0) when "110",
      fsfb_dat_ch7_i(LSB_WINDOW_INDEX+17 downto LSB_WINDOW_INDEX) & coadded_dat_ch7_i(13 downto 0) when others;

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

   -- Data Mode 7
   with ch_mux_sel select filtfb_error_2_dat <=
      filtered_dat_ch0_i(28 downto 7) & coadded_dat_ch0_i(13 downto 4) when "000",
      filtered_dat_ch1_i(28 downto 7) & coadded_dat_ch1_i(13 downto 4) when "001",
      filtered_dat_ch2_i(28 downto 7) & coadded_dat_ch2_i(13 downto 4) when "010",
      filtered_dat_ch3_i(28 downto 7) & coadded_dat_ch3_i(13 downto 4) when "011",
      filtered_dat_ch4_i(28 downto 7) & coadded_dat_ch4_i(13 downto 4) when "100",
      filtered_dat_ch5_i(28 downto 7) & coadded_dat_ch5_i(13 downto 4) when "101",
      filtered_dat_ch6_i(28 downto 7) & coadded_dat_ch6_i(13 downto 4) when "110",
      filtered_dat_ch7_i(28 downto 7) & coadded_dat_ch7_i(13 downto 4) when others;

   -- Data Mode 8 obsolete
--   with ch_mux_sel select filtfb_flx_cnt_dat3 <=
--      filtered_dat_ch0_i (31 downto 8) & flux_cnt_dat_ch0_i when "000",

   -- Data Mode 9 obsolete
--   with ch_mux_sel select filtfb_flx_cnt_dat <=
--      filtered_dat_ch0_i(31) & filtered_dat_ch0_i(23 downto 1) & flux_cnt_dat_ch0_i when "000",

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
   -- Pixel addresses:  6-bit row index, 3-bit column index.
   -- The data output is taken care of by the pid_loop_dat multiplexer. 
   
   -- Data Mode 12
   -- Raw Data
   -- The data output is taken care of by another multiplexer. 

   ------------------------------------------------------------------------------------------------
   -- Rectangle Mode FSM
   ------------------------------------------------------------------------------------------------
   rectangle_mode_ram: rectangle_ram_bank
   port map (
      clock     => clk_i,     
      data      => pid_loop_dat,  
      rdaddress => rect_rd_addr,  
      wraddress => rect_wr_addr,  
      wren      => rect_wren,     
      q         => rect_dat   
   );

   -- data_size determines the start index of the readout pointer.
   data_size <= data_size_i(RECT_ADDR_WIDTH-1 downto 0);
   -- The next read index is the one that is behind by data_size.
   -- rect_rd_addr may need some special handling to handle latency from the ram and to back up by a rectangle of indexes when read comes in....
   -- Actually not!  Latency is taken into account by the Wishbone interface!  It assumes that there is 1-cycle delay between the assertion of an address and valid data output
   rect_rd_addr      <= rect_addr_offset - data_size + tga_i(RECT_ADDR_WIDTH-1 DOWNTO 0);      
   num_rows          <= conv_std_logic_vector(num_rows_i, ROW_ADDR_WIDTH);
   pix_address       <= row_index & col_index;   
   num_rows_reported <= conv_std_logic_vector(num_rows_reported_i, ROW_ADDR_WIDTH); 
   num_cols_reported <= conv_std_logic_vector(num_cols_reported_i, ROW_ADDR_WIDTH);   

   address_rectangler: process (clk_i, rst_i)
   begin
      if(rst_i = '1') then                         
         row_index    <= (others => '0');
         col_index    <= (others => '0');   
         rect_wr_addr <= (others => '0');

      elsif (clk_i'event AND clk_i = '1') then
         
         if(pix_addr_clr = '1') then
            row_index <= readout_row_index;
            col_index <= readout_col_index;            
         elsif(pix_addr_incr = '1') then
            -- If we're at the last column to report, move to the next row and the first column to report
            if(col_index = readout_col_index + num_cols_reported(CH_MUX_SEL_WIDTH-1 downto 0) - 1) then
               -- If we're at the last physical row in the array, wrap to the zeroeth row and the first column to report
               if(row_index = num_rows - 1) then
                  row_index <= (others => '0');
                  col_index <= readout_col_index;
               -- Otherwise, go to the next row and the first column to report
               else
                  row_index <= row_index + 1;
                  col_index <= readout_col_index;
               end if;
            -- Otherwise move to the next column in the same row
            else
               row_index <= row_index;
               col_index <= col_index + 1;
            end if;
         end if;
         
         if(rect_wr_addr_inc = '1') then 
            rect_wr_addr <= rect_wr_addr + 1;
         end if;
         
      end if;
   end process address_rectangler;

   state_FF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         rect_current_state <= IDLE;
      elsif(clk_i'event and clk_i = '1') then
         rect_current_state <= rect_next_state;
      end if;
   end process state_FF;
   
   state_NS: process(rect_current_state, restart_frame_aligned_i, row_index, readout_row_index, num_rows_reported, col_index, readout_col_index, num_cols_reported)
   begin
      rect_next_state <= rect_current_state;
      
      case rect_current_state is
         when IDLE =>
            if(restart_frame_aligned_i = '1') then
               rect_next_state <= PRE_DELAY1;
            end if;
         
         when PRE_DELAY1 =>
            if((row_index = readout_row_index + num_rows_reported - 1) and (col_index = readout_col_index + num_cols_reported(CH_MUX_SEL_WIDTH-1 downto 0) - 1)) then
               -- This following is a special branch of the FSM if we are reading out one pixel per frame period
               -- State sequence is: PRE_DELAY1 (no wren) -> ONE_PIXEL_READOUT (no wren) -> POST_DELAY2 (wren)
               rect_next_state <= ONE_PIXEL_READOUT;
            else
               rect_next_state <= PRE_DELAY2;
            end if;
            
         when PRE_DELAY2 =>
            if((row_index = readout_row_index + num_rows_reported - 1) and (col_index = readout_col_index + num_cols_reported(CH_MUX_SEL_WIDTH-1 downto 0) - 1)) then
               -- This following is a special branch of the FSM if we are reading out two pixels per frame period
               -- State sequence is: PRE_DELAY1 (no wren) -> PRE_DELAY2 (no wren) -> POST_DELAY1 (wren) -> POST_DELAY2 (wren)
               rect_next_state <= POST_DELAY1;
            else
               rect_next_state <= COPY_DATA;
            end if;

         when COPY_DATA =>
            -- The first data word becomes available here.
            if((row_index = readout_row_index + num_rows_reported - 1) and (col_index = readout_col_index + num_cols_reported(CH_MUX_SEL_WIDTH-1 downto 0) - 1)) then
               rect_next_state <= POST_DELAY1;
            else
               rect_next_state <= COPY_DATA;
            end if;
         
         when ONE_PIXEL_READOUT =>
            rect_next_state <= POST_DELAY2;
         
         when POST_DELAY1 =>
            rect_next_state <= POST_DELAY2;
            
         when POST_DELAY2 =>
            rect_next_state <= DONE;

         when DONE =>
            if(restart_frame_aligned_i = '1') then
               rect_next_state <= PRE_DELAY1;
            end if;
         
         when others =>
            rect_next_state <= IDLE;
      end case;
   end process state_NS;

   state_out: process(rect_current_state, row_index, readout_row_index, num_rows_reported, col_index, readout_col_index, num_cols_reported)
   begin
      -- Signals to the address rectangler process for reading the fsfb RAMs etc.
      pix_addr_clr     <= '0';
      pix_addr_incr    <= '0';
      rect_wr_addr_inc <= '0';

      -- Signals to the rectangle RAM for storing the data frames.
      rect_wren      <= '0';

      case rect_current_state is
         when IDLE =>
            pix_addr_clr  <= '1';

         when PRE_DELAY1 =>
            pix_addr_incr <= '1';

         when PRE_DELAY2 =>
            pix_addr_incr <= '1';

         when COPY_DATA =>            
            if((row_index = readout_row_index + num_rows_reported - 1) and (col_index = readout_col_index + num_cols_reported(CH_MUX_SEL_WIDTH-1 downto 0) - 1)) then
               null;
            else
               pix_addr_incr <= '1';
            end if;

            -- Start writing the data here, after the 3-cycle pipeline delay
            rect_wren        <= '1';
            rect_wr_addr_inc <= '1';

         when ONE_PIXEL_READOUT =>
            -- No wren in this state (it's a wait state)
         
         when POST_DELAY1 =>
            rect_wren        <= '1';
            rect_wr_addr_inc <= '1';
            
         when POST_DELAY2 =>
            rect_wren        <= '1';
            rect_wr_addr_inc <= '1';

         when DONE =>
            pix_addr_clr  <= '1';

         when others => 
            NULL;
      end case;
   end process state_out;

   ----------------------------------------------------------------------------------------------------------------------------------
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
   --
   -- for mode 4  there are  5248 'rows' per channel (2 frames of 64 samples for each of the 41 rows).
   -- Again the addressing is such that a 'row' is read from each of the 8 channels, then the next 'row' etc...
   ----------------------------------------------------------------------------------------------------------------------------------
   address_counter: process (clk_i, rst_i)
   begin
      if(rst_i = '1') then                         -- asynchronous reset
         raw_addr_offset  <= (others => '0');
         rect_addr_offset <= (others => '0');
      
      elsif (clk_i'event AND clk_i = '1') then
         --------------------------------------------------------------------------------
         -- raw-mode address counter for readout of the raw RAM
         --------------------------------------------------------------------------------
         if (raw_addr_clr = '1') then                 -- synchronous reset 
            raw_addr_offset <= (others => '0');
         elsif(raw_addr_save = '1') then
            raw_addr_offset <= raw_addr_offset + tga_i(RAW_ADDR_WIDTH-1 downto 0);  -- synchronous increment by 1
         end if;
         
         --------------------------------------------------------------------------------
         -- non-raw-mode address counter for readout of the rectangle_mode_ram
         --------------------------------------------------------------------------------
         if(restart_frame_aligned_i = '1' and cyc_i = '0' ) then                 
            -- rect_wr_addr forms the basis for reporting.  Readout returns the previous row_reported*cols_reported data points
            -- Readout assumes that frame periods are long enough that rect_addr_offset doesn't get updated during readout.
            -- before the start of a new frame pariod, rect_wr_addr points to one index past the last word written in the data RAM at each new frame period.
            rect_addr_offset <= rect_wr_addr;
         end if;

      end if;
   end process address_counter;

   ------------------------------------------------------------------------------------------------
   -- Wishbone FSM
   ------------------------------------------------------------------------------------------------
   clock_fsm : process(clk_i, rst_i )
   begin
      if (rst_i = '1') then
         current_state <= IDLE;
      elsif (clk_i'EVENT AND clk_i = '1') then
         current_state <= next_state;
      end if;

   end process clock_fsm;

   nextstate_fsm: process (current_state, cyc_i, wr_cmd, rd_cmd)
   begin
      next_state <= current_state;

      case current_state is
         when IDLE =>
            if(wr_cmd = '1') then
               next_state <= WR;            
            elsif(rd_cmd = '1') then
               -- Filtered data need 1 frame period for calculations.
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
         
   end process nextstate_fsm;
   
   ack_o <= ack;
   output_fsm: process (current_state, addr_i, stb_i, cyc_i, data_mode)
   begin
      -- default states
      data_mode_wren        <= '0';
      readout_row_wren      <= '0';
      readout_col_wren      <= '0';
      readout_priority_wren <= '0';
      ack                   <= '0';
      raw_req               <= '0';
      raw_addr_clr          <= '0';
      raw_addr_save         <= '0';

      case current_state is
      when IDLE  => 
         
      when WR =>
         ack <= '1';
         if(stb_i = '1') then
            if(addr_i = DATA_MODE_ADDR) then
               data_mode_wren <= '1';
            elsif(addr_i = READOUT_ROW_INDEX_ADDR) then
               readout_row_wren <= '1';
            elsif(addr_i = READOUT_COL_INDEX_ADDR) then
               readout_col_wren <= '1';
            elsif(addr_i = READOUT_PRIORITY_ADDR) then
               readout_priority_wren <= '1';
            elsif(addr_i = RET_DAT_ADDR) then
               null;
            elsif(addr_i = CAPTR_RAW_ADDR) then
               raw_addr_clr <= '1';
               raw_req      <= '1';
            end if;
         end if;
      
      when RD1 =>

      when RD2 =>
         ack    <= '1';
         
         if(cyc_i = '0' and data_mode = MODE12_RAW_1_COL) then
            -- If we're in raw mode, we save the last addressed index as the starting point for the next read.
            raw_addr_save <= '1';
         end if;           
      
      when others =>
      end case;
      
   end process output_fsm;

   ------------------------------------------------------------------------------------------------
   -- Raw-Mode Signals
   ------------------------------------------------------------------------------------------------
   -- We ignore raw_ack_i because we don't want to hang the FSM while the raw RAM fills up.
--   raw_ack    <= raw_ack_i;  
   raw_req_o  <= raw_req;
   raw_addr   <= raw_addr_offset(RAW_ADDR_WIDTH-1 downto 0) + tga_i(RAW_ADDR_WIDTH-1 downto 0);
   raw_dat    <= sxt(raw_dat_i, raw_dat'length) when raw_addr < RAW_ADDR_MAX + 1 else RAW_NULL_DATA;
   raw_addr_o <= raw_addr;
   
   ------------------------------------------------------------------------------------------------
   -- Wishbone 
   ------------------------------------------------------------------------------------------------
   -- Wishbone Error signal
   with addr_i select err_o <=
      we_i when RET_DAT_ADDR,
      '0'      when others;

   dat_o <=
      data_mode                                  when addr_i = DATA_MODE_ADDR else
      ext(readout_row_index, WB_DATA_WIDTH)      when addr_i = READOUT_ROW_INDEX_ADDR else
      ext(readout_col_index, WB_DATA_WIDTH)      when addr_i = READOUT_COL_INDEX_ADDR else
      ext(readout_priority_index, WB_DATA_WIDTH) when addr_i = READOUT_PRIORITY_ADDR else
      raw_dat                                    when addr_i = RET_DAT_ADDR and data_mode = MODE12_RAW_1_COL else
      rect_dat                                   when addr_i = RET_DAT_ADDR else
      x"00000000"                                when addr_i = CAPTR_RAW_ADDR else
      (others => '0');
   
   rd_cmd  <= '1' when 
      (stb_i = '1' and cyc_i = '1' and we_i = '0') and 
      (addr_i = DATA_MODE_ADDR or 
       addr_i = READOUT_ROW_INDEX_ADDR or 
       addr_i = READOUT_COL_INDEX_ADDR or 
       addr_i = READOUT_PRIORITY_ADDR or 
       addr_i = RET_DAT_ADDR or 
       addr_i = CAPTR_RAW_ADDR) else '0'; 
      
   wr_cmd  <= '1' when 
      (stb_i = '1' and cyc_i = '1' and we_i = '1') and 
      (addr_i = DATA_MODE_ADDR or 
       addr_i = READOUT_ROW_INDEX_ADDR or 
       addr_i = READOUT_COL_INDEX_ADDR or 
       addr_i = READOUT_PRIORITY_ADDR or 
       addr_i = RET_DAT_ADDR or 
       addr_i = CAPTR_RAW_ADDR) else '0'; 

   ------------------------------------------------------------------------------------------------
   -- Data Mode & Readout Row Index Register
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
         readout_row_index <= (others => '0');
      elsif (clk_i'EVENT and clk_i = '1') then
         if readout_row_wren = '1' then
            readout_row_index <= dat_i(readout_row_index'length -1 downto 0);
         end if;
      end if;
   end process readout_row_reg;

   readout_col_reg: process(clk_i, rst_i)
   begin
      if (rst_i = '1') then
         readout_col_index <= (others => '0');
      elsif (clk_i'EVENT and clk_i = '1') then
         if readout_col_wren = '1' then
            readout_col_index <= dat_i(readout_col_index'length -1 downto 0);
         end if;
      end if;
   end process readout_col_reg;
   readout_col_index_o <= readout_col_index; 

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

end rtl;
