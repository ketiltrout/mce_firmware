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
-- wbs_frame_data.vhd
--
--
-- Project: 			Scuba 2
-- Author:  			David Atkinson
-- Organisation: 			UKATC
--
-- Description:
-- <description text>
--
-- Revision history:
-- <date $Date: 2004/10/06 21:48:53 $> - <text> - <initials $Author: erniel $>
--
-- $Log: wbs_frame_data.vhd,v $
--
--
-- 
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;

entity wbs_frame_data is

port(
     -- global inputs 
     rst_i                  : in  std_logic;                                 -- global reset
     clk_i                  : in  std_logic;                                 -- global clock

     -- signals to/from flux_loop_ctrl    
     filtered_addr_ch1_o    : out std_logic_vector (31 downto 0);            -- filtered data address - channel 1
     filtered_dat_ch1_i     : in  std_logic_vector (31 downto 0);            -- filtered data - channel 1
     fsfb_addr_ch1_o        : out std_logic_vector (31 downto 0);            -- feedback data address - channel 1   
     fsfb_dat_ch1_i         : in  std_logic_vector (31 downto 0);            -- feedback data - channel 1
     coadded_addr_ch1_0     : out std_logic_vector (31 downto 0);            -- co-added data address - channel 1
     coadded_dat_ch1_i      : in  std_logic_vector (31 downto 0);            -- co_added data - channel 1
     raw_addr_ch1_o         : out std_logic_vector (31 downto 0);            -- raw data address - channel 1
     raw_dat_ch1_i          : in  std_logic_vector (31 downto 0);            -- raw data - channel 1
     raw_req_ch1_o          : out std_logic;                                 -- raw data request - channel 1
     raw_ack_ch1_i          : in  std_logic;                                 -- raw data acknowledgement - channel 1
     
     filtered_addr_ch2_o    : out std_logic_vector (31 downto 0);            -- filtered data address - channel 2
     filtered_dat_ch2_i     : in  std_logic_vector (31 downto 0);            -- filtered data - channel 2
     fsfb_addr_ch2_o        : out std_logic_vector (31 downto 0);            -- feedback data address - channel 2   
     fsfb_dat_ch2_i         : in  std_logic_vector (31 downto 0);            -- feedback data - channel 2
     coadded_addr_ch2_0     : out std_logic_vector (31 downto 0);            -- co-added data address - channel 2
     coadded_dat_ch2_i      : in  std_logic_vector (31 downto 0);            -- co_added data - channel 2
     raw_addr_ch2_o         : out std_logic_vector (31 downto 0);            -- raw data address - channel 2
     raw_dat_ch2_i          : in  std_logic_vector (31 downto 0);            -- raw data - channel 2
     raw_req_ch2_o          : out std_logic;                                 -- raw data request - channel 2
     raw_ack_ch2_i          : in  std_logic;                                 -- raw data acknowledgement - channel 2
   
     filtered_addr_ch3_o    : out std_logic_vector (31 downto 0);            -- filtered data address - channel 3
     filtered_dat_ch3_i     : in  std_logic_vector (31 downto 0);            -- filtered data - channel 3
     fsfb_addr_ch3_o        : out std_logic_vector (31 downto 0);            -- feedback data address - channel 3   
     fsfb_dat_ch3_i         : in  std_logic_vector (31 downto 0);            -- feedback data - channel 3
     coadded_addr_ch3_0     : out std_logic_vector (31 downto 0);            -- co-added data address - channel 3
     coadded_dat_ch3_i      : in  std_logic_vector (31 downto 0);            -- co_added data - channel 3
     raw_addr_ch3_o         : out std_logic_vector (31 downto 0);            -- raw data address - channel 3
     raw_dat_ch3_i          : in  std_logic_vector (31 downto 0);            -- raw data - channel 3
     raw_req_ch3_o          : out std_logic;                                 -- raw data request - channel 3
     raw_ack_ch3_i          : in  std_logic;                                 -- raw data acknowledgement - channel 3
   
     filtered_addr_ch4_o    : out std_logic_vector (31 downto 0);            -- filtered data address - channel 4
     filtered_dat_ch4_i     : in  std_logic_vector (31 downto 0);            -- filtered data - channel 4
     fsfb_addr_ch4_o        : out std_logic_vector (31 downto 0);            -- feedback data address - channel 4   
     fsfb_dat_ch4_i         : in  std_logic_vector (31 downto 0);            -- feedback data - channel 4
     coadded_addr_ch4_0     : out std_logic_vector (31 downto 0);            -- co-added data address - channel 4
     coadded_dat_ch4_i      : in  std_logic_vector (31 downto 0);            -- co_added data - channel 4
     raw_addr_ch4_o         : out std_logic_vector (31 downto 0);            -- raw data address - channel 4
     raw_dat_ch4_i          : in  std_logic_vector (31 downto 0);            -- raw data - channel 4
     raw_req_ch4_o          : out std_logic;                                 -- raw data request - channel 4
     raw_ack_ch4_i          : in  std_logic;                                 -- raw data acknowledgement - channel 4

     filtered_addr_ch5_o    : out std_logic_vector (31 downto 0);            -- filtered data address - channel 5
     filtered_dat_ch5_i     : in  std_logic_vector (31 downto 0);            -- filtered data - channel 5
     fsfb_addr_ch5_o        : out std_logic_vector (31 downto 0);            -- feedback data address - channel 5   
     fsfb_dat_ch5_i         : in  std_logic_vector (31 downto 0);            -- feedback data - channel 5
     coadded_addr_ch5_0     : out std_logic_vector (31 downto 0);            -- co-added data address - channel 5
     coadded_dat_ch5_i      : in  std_logic_vector (31 downto 0);            -- co_added data - channel 5
     raw_addr_ch5_o         : out std_logic_vector (31 downto 0);            -- raw data address - channel 5
     raw_dat_ch5_i          : in  std_logic_vector (31 downto 0);            -- raw data - channel 5
     raw_req_ch5_o          : out std_logic;                                 -- raw data request - channel 5
     raw_ack_ch5_i          : in  std_logic;                                 -- raw data acknowledgement - channel 5
   
     filtered_addr_ch6_o    : out std_logic_vector (31 downto 0);            -- filtered data address - channel 6
     filtered_dat_ch6_i     : in  std_logic_vector (31 downto 0);            -- filtered data - channel 6
     fsfb_addr_ch6_o        : out std_logic_vector (31 downto 0);            -- feedback data address - channel 6   
     fsfb_dat_ch6_i         : in  std_logic_vector (31 downto 0);            -- feedback data - channel 6
     coadded_addr_ch6_0     : out std_logic_vector (31 downto 0);            -- co-added data address - channel 6
     coadded_dat_ch6_i      : in  std_logic_vector (31 downto 0);            -- co_added data - channel 6
     raw_addr_ch6_o         : out std_logic_vector (31 downto 0);            -- raw data address - channel 6
     raw_dat_ch6_i          : in  std_logic_vector (31 downto 0);            -- raw data - channel 6
     raw_req_ch6_o          : out std_logic;                                 -- raw data request - channel 6
     raw_ack_ch6_i          : in  std_logic;                                 -- raw data acknowledgement - channel 6
   
     filtered_addr_ch7_o    : out std_logic_vector (31 downto 0);            -- filtered data address - channel 7
     filtered_dat_ch7_i     : in  std_logic_vector (31 downto 0);            -- filtered data - channel 7
     fsfb_addr_ch7_o        : out std_logic_vector (31 downto 0);            -- feedback data address - channel 7   
     fsfb_dat_ch7_i         : in  std_logic_vector (31 downto 0);            -- feedback data - channel 7
     coadded_addr_ch7_0     : out std_logic_vector (31 downto 0);            -- co-added data address - channel 7
     coadded_dat_ch7_i      : in  std_logic_vector (31 downto 0);            -- co_added data - channel 7
     raw_addr_ch7_o         : out std_logic_vector (31 downto 0);            -- raw data address - channel 7
     raw_dat_ch7_i          : in  std_logic_vector (31 downto 0);            -- raw data - channel 7
     raw_req_ch7_o          : out std_logic;                                 -- raw data request - channel 7
     raw_ack_ch7_i          : in  std_logic;                                 -- raw data acknowledgement - channel 7
   
     filtered_addr_ch8_o    : out std_logic_vector (31 downto 0);            -- filtered data address - channel 8
     filtered_dat_ch8_i     : in  std_logic_vector (31 downto 0);            -- filtered data - channel 8
     fsfb_addr_ch8_o        : out std_logic_vector (31 downto 0);            -- feedback data address - channel 8   
     fsfb_dat_ch8_i         : in  std_logic_vector (31 downto 0);            -- feedback data - channel 8
     coadded_addr_ch8_0     : out std_logic_vector (31 downto 0);            -- co-added data address - channel 8
     coadded_dat_ch8_i      : in  std_logic_vector (31 downto 0);            -- co_added data - channel 8
     raw_addr_ch8_o         : out std_logic_vector (31 downto 0);            -- raw data address - channel 8
     raw_dat_ch8_i          : in  std_logic_vector (31 downto 0);            -- raw data - channel 8
     raw_req_ch8_o          : out std_logic;                                 -- raw data request - channel 8
     raw_ack_ch8_i          : in  std_logic                                  -- raw data acknowledgement - channel 8
   
    
     -- signals to/from dispatch  
  
  
     -- signals to / from frame_timing
  
  
     );      
end wbs_frame_data;


library ieee;
use ieee.std_logic_1164.all;

library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;


architecture rtl of wbs_frame_data is


begin

           
end rtl;