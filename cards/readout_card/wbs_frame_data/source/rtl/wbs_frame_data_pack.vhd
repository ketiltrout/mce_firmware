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
-- UBC, University of British Columbia, Physics & Astronomy Department,
-- Vancouver BC, V6T 1Z1
--
-- wbs_frame_data_pack.vhd
--
--
-- Project: 			Scuba 2
-- Author:  			David Atkinson
-- Organisation: 			UKATC
--
-- Description:
-- 
--
-- Revision history:
-- <date $Date: 2004/10/20 13:50:11 $> - <text> - <initials $Author: dca $>
--
-- $Log: wbs_frame_data_pack.vhd,v $
-- Revision 1.3  2004/10/20 13:50:11  dca
-- channel range changed from 1-->8 to 0-->7
--
-- Revision 1.2  2004/10/19 14:30:39  dca
-- raw data addressing changed.
-- MUX structure changed
--
-- Revision 1.1  2004/10/18 16:35:36  dca
-- initial version
--

--
-- 
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;

package wbs_frame_data_pack is

constant RAW_ADDR_WIDTH    :  integer := 13; 
constant RAW_DATA_WIDTH    :  integer := 16;    
constant ROW_ADDR_WIDTH    :  integer := 6; 
constant CH_MUX_SEL_WIDTH :  integer := 3;

constant NO_CHANNELS       :  integer := 2**CH_MUX_SEL_WIDTH;
constant NO_ROWS           :  integer := 41;

constant PIXEL_ADDR_MAX    :  integer := NO_CHANNELS * NO_ROWS;
constant RAW_ADDR_MAX      :  integer := 2 * NO_CHANNELS * NO_ROWS * 64 ;

constant MODE1_FILTERED    : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0) := X"00000000";
constant MODE2_UNFILTERED  : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0) := X"00000001";
constant MODE3_FB_ERROR    : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0) := X"00000002";
constant MODE4_RAW         : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0) := X"00000003";


component wbs_frame_data

port(
     -- global inputs 
     rst_i                  : in  std_logic;                                          -- global reset
     clk_i                  : in  std_logic;                                          -- global clock

     -- signals to/from flux_loop_ctrl    

     filtered_addr_ch0_o       : out std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- filtered data address - channel 0
     filtered_dat_ch0_i        : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- filtered data - channel 0
     fsfb_addr_ch0_o           : out std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- feedback data address - channel 0   
     fsfb_dat_ch0_i            : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- feedback data - channel 0
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
                  
     dat_o 	                   : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);       -- data out
     ack_o                     : out std_logic                                         -- acknowledge out
     );   
     
     
end component;





component tb_wbs_frame_data_flc_sim 

port(
     -- global inputs 
     rst_i                  : in  std_logic;                                          -- global reset
     clk_i                  : in  std_logic;                                          -- global clock

     -- signals to/from flux_loop_ctrl    

     filtered_addr_ch0_i       : in  std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- filtered data address - channel 0
     filtered_dat_ch0_o        : out std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- filtered data - channel 0
     fsfb_addr_ch0_i           : in  std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- feedback data address - channel 0   
     fsfb_dat_ch0_o            : out std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- feedback data - channel 0
     coadded_addr_ch0_i        : in  std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- co-added data address - channel 0
     coadded_dat_ch0_o         : out std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- co_added data - channel 0
     raw_addr_ch0_i            : in  std_logic_vector (RAW_ADDR_WIDTH-1    downto 0);  -- raw data address - channel 0
     raw_dat_ch0_o             : out std_logic_vector (RAW_DATA_WIDTH-1    downto 0);  -- raw data - channel 0
     raw_req_ch0_i             : in  std_logic;                                        -- raw data request - channel 0
     raw_ack_ch0_o             : out std_logic;                                        -- raw data acknowledgement - channel 0

     filtered_addr_ch1_i       : in  std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- filtered data address - channel 1
     filtered_dat_ch1_o        : out std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- filtered data - channel 1
     fsfb_addr_ch1_i           : in  std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- feedback data address - channel 1   
     fsfb_dat_ch1_o            : out std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- feedback data - channel 1
     coadded_addr_ch1_i        : in  std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- co-added data address - channel 1
     coadded_dat_ch1_o         : out std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- co_added data - channel 1
     raw_addr_ch1_i            : in  std_logic_vector (RAW_ADDR_WIDTH-1    downto 0);  -- raw data address - channel 1
     raw_dat_ch1_o             : out std_logic_vector (RAW_DATA_WIDTH-1    downto 0);  -- raw data - channel 1
     raw_req_ch1_i             : in  std_logic;                                        -- raw data request - channel 1
     raw_ack_ch1_o             : out std_logic;                                        -- raw data acknowledgement - channel 1
      
     filtered_addr_ch2_i       : in  std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- filtered data address - channel 2
     filtered_dat_ch2_o        : out std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- filtered data - channel 2
     fsfb_addr_ch2_i           : in  std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- feedback data address - channel 2   
     fsfb_dat_ch2_o            : out std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- feedback data - channel 2
     coadded_addr_ch2_i        : in  std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- co-added data address - channel 2
     coadded_dat_ch2_o         : out std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- co_added data - channel 2
     raw_addr_ch2_i            : in  std_logic_vector (RAW_ADDR_WIDTH-1    downto 0);  -- raw data address - channel 2
     raw_dat_ch2_o             : out std_logic_vector (RAW_DATA_WIDTH-1    downto 0);  -- raw data - channel 2
     raw_req_ch2_i             : in  std_logic;                                        -- raw data request - channel 2
     raw_ack_ch2_o             : out std_logic;                                        -- raw data acknowledgement - channel 2
   
     filtered_addr_ch3_i       : in  std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- filtered data address - channel 3
     filtered_dat_ch3_o        : out std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- filtered data - channel 3
     fsfb_addr_ch3_i           : in  std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- feedback data address - channel 3   
     fsfb_dat_ch3_o            : out std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- feedback data - channel 3
     coadded_addr_ch3_i        : in  std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- co-added data address - channel 3
     coadded_dat_ch3_o         : out std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- co_added data - channel 3
     raw_addr_ch3_i            : in  std_logic_vector (RAW_ADDR_WIDTH-1    downto 0);  -- raw data address - channel 3
     raw_dat_ch3_o             : out std_logic_vector (RAW_DATA_WIDTH-1    downto 0);  -- raw data - channel 3
     raw_req_ch3_i             : in  std_logic;                                        -- raw data request - channel 3
     raw_ack_ch3_o             : out std_logic;                                        -- raw data acknowledgement - channel 3
   
     filtered_addr_ch4_i       : in  std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- filtered data address - channel 4
     filtered_dat_ch4_o        : out std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- filtered data - channel 4
     fsfb_addr_ch4_i           : in  std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- feedback data address - channel 4   
     fsfb_dat_ch4_o            : out std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- feedback data - channel 4
     coadded_addr_ch4_i        : in  std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- co-added data address - channel 4
     coadded_dat_ch4_o         : out std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- co_added data - channel 4
     raw_addr_ch4_i            : in  std_logic_vector (RAW_ADDR_WIDTH-1    downto 0);  -- raw data address - channel 4
     raw_dat_ch4_o             : out std_logic_vector (RAW_DATA_WIDTH-1    downto 0);   -- raw data - channel 4
     raw_req_ch4_i             : in  std_logic;                                        -- raw data request - channel 4
     raw_ack_ch4_o             : out std_logic;                                        -- raw data acknowledgement - channel 4

     filtered_addr_ch5_i       : in  std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- filtered data address - channel 5
     filtered_dat_ch5_o        : out std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- filtered data - channel 5
     fsfb_addr_ch5_i           : in  std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- feedback data address - channel 5   
     fsfb_dat_ch5_o            : out std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- feedback data - channel 5
     coadded_addr_ch5_i        : in  std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- co-added data address - channel 5
     coadded_dat_ch5_o         : out std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- co_added data - channel 5
     raw_addr_ch5_i            : in  std_logic_vector (RAW_ADDR_WIDTH-1    downto 0);  -- raw data address - channel 5
     raw_dat_ch5_o             : out std_logic_vector (RAW_DATA_WIDTH-1    downto 0);  -- raw data - channel 5
     raw_req_ch5_i             : in  std_logic;                                        -- raw data request - channel 5
     raw_ack_ch5_o             : out std_logic;                                        -- raw data acknowledgement - channel 5
   
     filtered_addr_ch6_i       : in  std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- filtered data address - channel 6
     filtered_dat_ch6_o        : out std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- filtered data - channel 6
     fsfb_addr_ch6_i           : in  std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- feedback data address - channel 6   
     fsfb_dat_ch6_o            : out std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- feedback data - channel 6
     coadded_addr_ch6_i        : in  std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- co-added data address - channel 6
     coadded_dat_ch6_o         : out std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- co_added data - channel 6
     raw_addr_ch6_i            : in  std_logic_vector (RAW_ADDR_WIDTH-1    downto 0);  -- raw data address - channel 6
     raw_dat_ch6_o             : out std_logic_vector (RAW_DATA_WIDTH-1    downto 0);  -- raw data - channel 6
     raw_req_ch6_i             : in  std_logic;                                        -- raw data request - channel 6
     raw_ack_ch6_o             : out std_logic;                                        -- raw data acknowledgement - channel 6
   
     filtered_addr_ch7_i       : in  std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- filtered data address - channel 7
     filtered_dat_ch7_o        : out std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- filtered data - channel 7
     fsfb_addr_ch7_i           : in  std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- feedback data address - channel 7   
     fsfb_dat_ch7_o            : out std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- feedback data - channel 7
     coadded_addr_ch7_i        : in  std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- co-added data address - channel 7
     coadded_dat_ch7_o         : out std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- co_added data - channel 7
     raw_addr_ch7_i            : in  std_logic_vector (RAW_ADDR_WIDTH-1    downto 0);  -- raw data address - channel 7
     raw_dat_ch7_o             : out std_logic_vector (RAW_DATA_WIDTH-1    downto 0);  -- raw data - channel 7
     raw_req_ch7_i             : in  std_logic;                                        -- raw data request - channel 7
     raw_ack_ch7_o             : out std_logic                                        -- raw data acknowledgement - channel 7
    );
end component ;


end package;