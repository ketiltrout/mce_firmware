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
-- tb_wbs_frame_data.vhd
--
--
-- Project:          Scuba 2
-- Author:           David Atkinson
-- Organisation:        UKATC
--
-- Description:
-- 
-- test bed for wbs_frame_data.vhd
--
-- Revision history:
-- <date $Date: 2007/09/10 21:50:33 $> - <text> - <initials $Author: mandana $>
--
-- $Log: tb_wbs_frame_data.vhd,v $
-- Revision 1.9  2007/09/10 21:50:33  mandana
-- added readout_row_index and relevant test
-- improved raw-mode and adjusted self-checking data
-- filter-mode to be debugged as restart_frame_post is not stimulated!
--
-- Revision 1.8  2005/12/15 19:41:09  mandana
-- added test for data modes 2, 4, 5
--
-- Revision 1.7  2004/12/13 10:00:58  dca
-- following instructions added:
--
-- read captr_raw
-- read data_mode
-- write ret_data
--
-- Revision 1.6  2004/12/07 19:37:46  mohsen
-- Anthony & Mohsen: Restructured constant declaration.  Moved shared constants from lower level package files to the upper level ones.  This was done to resolve compilation error resulting from shared constants defined in multiple package files.
--
-- Revision 1.5  2004/11/26 18:29:08  mohsen
-- Anthony & Mohsen: Restructured constant declaration.  Moved shared constants from lower level package files to the upper level ones.  This was done to resolve compilation error resulting from shared constants defined in multiple package files.
--
-- Revision 1.4  2004/10/29 12:37:24  dca
-- read cycle changed to block read...
-- test bed changed accordingly
--
-- Revision 1.3  2004/10/28 15:44:07  dca
-- ret_data wishbone reads changed to block reads.
-- testbed changed accordingly
--
-- Revision 1.2  2004/10/27 13:11:06  dca
-- some minor changes
--
-- Revision 1.1  2004/10/26 16:14:12  dca
-- Initial Version
--
--
-- 
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity tb_wbs_frame_data is
end tb_wbs_frame_data;



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

architecture bench of tb_wbs_frame_data is

signal dut_rst        : std_logic;
signal dut_clk        : std_logic := '1';
constant clk_prd      : TIME := 20 ns;    -- 50Mhz clock

signal flc_buff_rst   : std_logic;   -- initialise FLUX loop contorl buffers...

signal param_id       :  std_logic_vector (WB_ADDR_WIDTH-1 downto 0);
   
signal restart_frame_1row_post : std_logic;  

signal filtered_addr_ch0     : std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  
signal filtered_dat_ch0      : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  
signal fsfb_addr_ch0         : std_logic_vector (ROW_ADDR_WIDTH-1    downto 0); 
signal fsfb_dat_ch0          : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0); 
signal flux_cnt_dat_ch0      : std_logic_vector (FLUX_QUANTA_CNT_WIDTH-1 downto 0); 
signal coadded_addr_ch0      : std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);   
signal coadded_dat_ch0       : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  
signal raw_addr_ch0          : std_logic_vector (RAW_ADDR_WIDTH-1    downto 0);  
signal raw_dat_ch0           : std_logic_vector (RAW_DATA_WIDTH-1    downto 0); 
signal raw_req_ch0           : std_logic;                                       
signal raw_ack_ch0           : std_logic;                                        


signal filtered_addr_ch1     : std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  
signal filtered_dat_ch1      : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  
signal fsfb_addr_ch1         : std_logic_vector (ROW_ADDR_WIDTH-1    downto 0); 
signal fsfb_dat_ch1          : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0); 
signal flux_cnt_dat_ch1      : std_logic_vector (FLUX_QUANTA_CNT_WIDTH-1 downto 0); 
signal coadded_addr_ch1      : std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);   
signal coadded_dat_ch1       : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  
signal raw_addr_ch1          : std_logic_vector (RAW_ADDR_WIDTH-1    downto 0);  
signal raw_dat_ch1           : std_logic_vector (RAW_DATA_WIDTH-1    downto 0); 
signal raw_req_ch1           : std_logic;                                       
signal raw_ack_ch1           : std_logic;        

signal filtered_addr_ch2     : std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  
signal filtered_dat_ch2      : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  
signal fsfb_addr_ch2         : std_logic_vector (ROW_ADDR_WIDTH-1    downto 0); 
signal fsfb_dat_ch2          : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0); 
signal flux_cnt_dat_ch2      : std_logic_vector (FLUX_QUANTA_CNT_WIDTH-1 downto 0); 
signal coadded_addr_ch2      : std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);   
signal coadded_dat_ch2       : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  
signal raw_addr_ch2          : std_logic_vector (RAW_ADDR_WIDTH-1    downto 0);  
signal raw_dat_ch2           : std_logic_vector (RAW_DATA_WIDTH-1    downto 0); 
signal raw_req_ch2           : std_logic;                                       
signal raw_ack_ch2           : std_logic;        

signal filtered_addr_ch3     : std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  
signal filtered_dat_ch3      : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  
signal fsfb_addr_ch3         : std_logic_vector (ROW_ADDR_WIDTH-1    downto 0); 
signal fsfb_dat_ch3          : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0); 
signal flux_cnt_dat_ch3      : std_logic_vector (FLUX_QUANTA_CNT_WIDTH-1 downto 0); 
signal coadded_addr_ch3      : std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);   
signal coadded_dat_ch3       : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  
signal raw_addr_ch3          : std_logic_vector (RAW_ADDR_WIDTH-1    downto 0);  
signal raw_dat_ch3           : std_logic_vector (RAW_DATA_WIDTH-1    downto 0); 
signal raw_req_ch3           : std_logic;                                       
signal raw_ack_ch3           : std_logic;        

signal filtered_addr_ch4     : std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  
signal filtered_dat_ch4      : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  
signal fsfb_addr_ch4         : std_logic_vector (ROW_ADDR_WIDTH-1    downto 0); 
signal fsfb_dat_ch4          : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0); 
signal flux_cnt_dat_ch4      : std_logic_vector (FLUX_QUANTA_CNT_WIDTH-1 downto 0); 
signal coadded_addr_ch4      : std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);   
signal coadded_dat_ch4       : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  
signal raw_addr_ch4          : std_logic_vector (RAW_ADDR_WIDTH-1    downto 0);  
signal raw_dat_ch4           : std_logic_vector (RAW_DATA_WIDTH-1    downto 0); 
signal raw_req_ch4           : std_logic;                                       
signal raw_ack_ch4           : std_logic;        

signal filtered_addr_ch5     : std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  
signal filtered_dat_ch5      : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  
signal fsfb_addr_ch5         : std_logic_vector (ROW_ADDR_WIDTH-1    downto 0); 
signal fsfb_dat_ch5          : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0); 
signal flux_cnt_dat_ch5      : std_logic_vector (FLUX_QUANTA_CNT_WIDTH-1 downto 0); 
signal coadded_addr_ch5      : std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);   
signal coadded_dat_ch5       : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  
signal raw_addr_ch5          : std_logic_vector (RAW_ADDR_WIDTH-1    downto 0);  
signal raw_dat_ch5           : std_logic_vector (RAW_DATA_WIDTH-1    downto 0); 
signal raw_req_ch5           : std_logic;                                       
signal raw_ack_ch5           : std_logic;        

signal filtered_addr_ch6     : std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  
signal filtered_dat_ch6      : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  
signal fsfb_addr_ch6         : std_logic_vector (ROW_ADDR_WIDTH-1    downto 0); 
signal fsfb_dat_ch6          : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0); 
signal flux_cnt_dat_ch6      : std_logic_vector (FLUX_QUANTA_CNT_WIDTH-1 downto 0); 
signal coadded_addr_ch6      : std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);   
signal coadded_dat_ch6       : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  
signal raw_addr_ch6          : std_logic_vector (RAW_ADDR_WIDTH-1    downto 0);  
signal raw_dat_ch6           : std_logic_vector (RAW_DATA_WIDTH-1    downto 0); 
signal raw_req_ch6           : std_logic;                                       
signal raw_ack_ch6           : std_logic;        

signal filtered_addr_ch7     : std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  
signal filtered_dat_ch7      : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  
signal fsfb_addr_ch7         : std_logic_vector (ROW_ADDR_WIDTH-1    downto 0); 
signal fsfb_dat_ch7          : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0); 
signal flux_cnt_dat_ch7      : std_logic_vector (FLUX_QUANTA_CNT_WIDTH-1 downto 0); 
signal coadded_addr_ch7      : std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);   
signal coadded_dat_ch7       : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  
signal raw_addr_ch7          : std_logic_vector (RAW_ADDR_WIDTH-1    downto 0);  
signal raw_dat_ch7           : std_logic_vector (RAW_DATA_WIDTH-1    downto 0); 
signal raw_req_ch7           : std_logic;                                       
signal raw_ack_ch7           : std_logic;          
     
     
signal wbm_dat_o             : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
signal wbm_addr_o            : std_logic_vector(WB_ADDR_WIDTH-1 downto 0); 
signal wbm_tga_o             : std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0); 
signal wbm_we_o              : std_logic;
signal wbm_stb_o             : std_logic;
signal wbm_cyc_o             : std_logic;
signal wbm_dat_i             : std_logic_vector(WB_DATA_WIDTH-1 downto 0); 
signal wbm_ack_i             : std_logic;
 
 
signal wbm_dat_mux       : std_logic_vector(WB_DATA_WIDTH-1 downto 0); 
signal wbm_dat_reg       : std_logic_vector(WB_DATA_WIDTH-1 downto 0); 

signal raw_req_all        : std_logic;
signal raw_ack_all        : std_logic;

-- flux loop  contorl memory buffers

subtype dat_word  is std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
subtype raw_word  is std_logic_vector (RAW_DATA_WIDTH-1    downto 0); 

constant DAT_MEM_SIZE   : positive := 2**ROW_ADDR_WIDTH;
constant RAW_MEM_SIZE   : positive  := 2**RAW_ADDR_WIDTH;

type dat_memory is array (0 to DAT_MEM_SIZE-1) of dat_word;
type raw_memory is array (0 to RAW_MEM_SIZE-1) of raw_word;

signal filtered_buff_ch0 : dat_memory := (others => dat_word'(others => '1'));
signal fsfb_buff_ch0     : dat_memory := (others => dat_word'(others => '1'));
signal coadd_buff_ch0    : dat_memory := (others => dat_word'(others => '1')); 
signal raw_buff_ch0      : raw_memory := (others => raw_word'(others => '1'));

signal filtered_buff_ch1 : dat_memory := (others => dat_word'(others => '1'));
signal fsfb_buff_ch1     : dat_memory := (others => dat_word'(others => '1'));
signal coadd_buff_ch1    : dat_memory := (others => dat_word'(others => '1')); 
signal raw_buff_ch1      : raw_memory := (others => raw_word'(others => '1'));

signal filtered_buff_ch2 : dat_memory := (others => dat_word'(others => '1'));
signal fsfb_buff_ch2     : dat_memory := (others => dat_word'(others => '1'));
signal coadd_buff_ch2    : dat_memory := (others => dat_word'(others => '1')); 
signal raw_buff_ch2      : raw_memory := (others => raw_word'(others => '1'));

signal filtered_buff_ch3 : dat_memory := (others => dat_word'(others => '1'));
signal fsfb_buff_ch3     : dat_memory := (others => dat_word'(others => '1'));
signal coadd_buff_ch3    : dat_memory := (others => dat_word'(others => '1')); 
signal raw_buff_ch3      : raw_memory := (others => raw_word'(others => '1'));

signal filtered_buff_ch4 : dat_memory := (others => dat_word'(others => '1'));
signal fsfb_buff_ch4     : dat_memory := (others => dat_word'(others => '1'));
signal coadd_buff_ch4    : dat_memory := (others => dat_word'(others => '1')); 
signal raw_buff_ch4      : raw_memory := (others => raw_word'(others => '1'));

signal filtered_buff_ch5 : dat_memory := (others => dat_word'(others => '1'));
signal fsfb_buff_ch5     : dat_memory := (others => dat_word'(others => '1'));
signal coadd_buff_ch5    : dat_memory := (others => dat_word'(others => '1')); 
signal raw_buff_ch5      : raw_memory := (others => raw_word'(others => '1'));

signal filtered_buff_ch6 : dat_memory := (others => dat_word'(others => '1'));
signal fsfb_buff_ch6     : dat_memory := (others => dat_word'(others => '1'));
signal coadd_buff_ch6    : dat_memory := (others => dat_word'(others => '1')); 
signal raw_buff_ch6      : raw_memory := (others => raw_word'(others => '1'));

signal filtered_buff_ch7 : dat_memory := (others => dat_word'(others => '1'));
signal fsfb_buff_ch7     : dat_memory := (others => dat_word'(others => '1'));
signal coadd_buff_ch7    : dat_memory := (others => dat_word'(others => '1')); 
signal raw_buff_ch7      : raw_memory := (others => raw_word'(others => '1'));



constant FILTERED_DATA  : std_logic_vector(3 downto 0) := "0000";
constant FSFB_DATA      : std_logic_vector(3 downto 0) := "0001";
constant COADD_DATA     : std_logic_vector(3 downto 0) := "0010";
constant RAW_DATA       : std_logic_vector(3 downto 0) := "0011";

constant CHANNEL_0      : std_logic_vector(3 downto 0) := "0000";
constant CHANNEL_1      : std_logic_vector(3 downto 0) := "0001";
constant CHANNEL_2      : std_logic_vector(3 downto 0) := "0010";
constant CHANNEL_3      : std_logic_vector(3 downto 0) := "0011";
constant CHANNEL_4      : std_logic_vector(3 downto 0) := "0100";
constant CHANNEL_5      : std_logic_vector(3 downto 0) := "0101";
constant CHANNEL_6      : std_logic_vector(3 downto 0) := "0110";
constant CHANNEL_7      : std_logic_vector(3 downto 0) := "0111";


-- number of raw samples / pixel
constant NO_SAMPLES     : integer := 64;
constant NO_PIX_PER_CH  : integer := 41;

constant RAW_DELAY      : integer := 25 ;  -- number of delayclocks before acknowledging raw data


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
     flux_cnt_dat_ch0_o        : out std_logic_vector (FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- flux jump count - channel 0           
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
     flux_cnt_dat_ch1_o        : out std_logic_vector (FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- flux jump count - channel 1           
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
     flux_cnt_dat_ch2_o        : out std_logic_vector (FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- flux jump count - channel 2           
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
     flux_cnt_dat_ch3_o        : out std_logic_vector (FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- flux jump count - channel 3           
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
     flux_cnt_dat_ch4_o        : out std_logic_vector (FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- flux jump count - channel 4           
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
     flux_cnt_dat_ch5_o        : out std_logic_vector (FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- flux jump count - channel 5           
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
     flux_cnt_dat_ch6_o        : out std_logic_vector (FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- flux jump count - channel 6           
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
     flux_cnt_dat_ch7_o        : out std_logic_vector (FLUX_QUANTA_CNT_WIDTH-1 downto 0); -- flux jump count - channel 7           
     coadded_addr_ch7_i        : in  std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- co-added data address - channel 7
     coadded_dat_ch7_o         : out std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- co_added data - channel 7
     raw_addr_ch7_i            : in  std_logic_vector (RAW_ADDR_WIDTH-1    downto 0);  -- raw data address - channel 7
     raw_dat_ch7_o             : out std_logic_vector (RAW_DATA_WIDTH-1    downto 0);  -- raw data - channel 7
     raw_req_ch7_i             : in  std_logic;                                        -- raw data request - channel 7
     raw_ack_ch7_o             : out std_logic                                        -- raw data acknowledgement - channel 7
    );
end component ;



begin

-------------------------------------------------
-- Instantiate DUT
-------------------------------------------------

   i_wbs_frame_data :  wbs_frame_data
   
   port map (
   
     -- global inputs 
     rst_i                     =>  dut_rst, 
     clk_i                     =>  dut_clk,

     -- signal from frame_timing
     restart_frame_1row_post_i =>  restart_frame_1row_post,
  
     -- signals to/from flux_loop_ctrl    
     filtered_addr_ch0_o       =>  filtered_addr_ch0,
     filtered_dat_ch0_i        =>  filtered_dat_ch0, 
     fsfb_addr_ch0_o           =>  fsfb_addr_ch0,
     fsfb_dat_ch0_i            =>  fsfb_dat_ch0,
     flux_cnt_dat_ch0_i        =>  flux_cnt_dat_ch0,
     coadded_addr_ch0_o        =>  coadded_addr_ch0,
     coadded_dat_ch0_i         =>  coadded_dat_ch0,
     raw_addr_ch0_o            =>  raw_addr_ch0, 
     raw_dat_ch0_i             =>  raw_dat_ch0, 
     raw_req_ch0_o             =>  raw_req_ch0,
     raw_ack_ch0_i             =>  raw_ack_ch0,


     filtered_addr_ch1_o       =>   filtered_addr_ch1,
     filtered_dat_ch1_i        =>   filtered_dat_ch1,
     fsfb_addr_ch1_o           =>   fsfb_addr_ch1,
     fsfb_dat_ch1_i            =>   fsfb_dat_ch1,
     flux_cnt_dat_ch1_i        =>   flux_cnt_dat_ch1,     
     coadded_addr_ch1_o        =>   coadded_addr_ch1,
     coadded_dat_ch1_i         =>   coadded_dat_ch1,
     raw_addr_ch1_o            =>   raw_addr_ch1,
     raw_dat_ch1_i             =>   raw_dat_ch1,
     raw_req_ch1_o             =>   raw_req_ch1,
     raw_ack_ch1_i             =>   raw_ack_ch1,
      
     filtered_addr_ch2_o       =>   filtered_addr_ch2,
     filtered_dat_ch2_i        =>   filtered_dat_ch2, 
     fsfb_addr_ch2_o           =>   fsfb_addr_ch2, 
     fsfb_dat_ch2_i            =>   fsfb_dat_ch2, 
     flux_cnt_dat_ch2_i        =>   flux_cnt_dat_ch2,     
     coadded_addr_ch2_o        =>   coadded_addr_ch2, 
     coadded_dat_ch2_i         =>   coadded_dat_ch2,
     raw_addr_ch2_o            =>   raw_addr_ch2,
     raw_dat_ch2_i             =>   raw_dat_ch2,
     raw_req_ch2_o             =>   raw_req_ch2,
     raw_ack_ch2_i             =>   raw_ack_ch2,
        
     filtered_addr_ch3_o       =>   filtered_addr_ch3,
     filtered_dat_ch3_i        =>   filtered_dat_ch3,
     fsfb_addr_ch3_o           =>   fsfb_addr_ch3 ,
     fsfb_dat_ch3_i            =>   fsfb_dat_ch3 ,
     flux_cnt_dat_ch3_i        =>   flux_cnt_dat_ch3,     
     coadded_addr_ch3_o        =>   coadded_addr_ch3,
     coadded_dat_ch3_i         =>   coadded_dat_ch3  ,
     raw_addr_ch3_o            =>   raw_addr_ch3,
     raw_dat_ch3_i             =>   raw_dat_ch3  ,  
     raw_req_ch3_o             =>   raw_req_ch3,
     raw_ack_ch3_i             =>   raw_ack_ch3,
   
     filtered_addr_ch4_o       =>   filtered_addr_ch4,
     filtered_dat_ch4_i        =>   filtered_dat_ch4,
     fsfb_addr_ch4_o           =>   fsfb_addr_ch4 ,
     fsfb_dat_ch4_i            =>   fsfb_dat_ch4 ,
     flux_cnt_dat_ch4_i        =>   flux_cnt_dat_ch4,     
     coadded_addr_ch4_o        =>   coadded_addr_ch4,
     coadded_dat_ch4_i         =>   coadded_dat_ch4,  
     raw_addr_ch4_o            =>   raw_addr_ch4,
     raw_dat_ch4_i             =>   raw_dat_ch4,    
     raw_req_ch4_o             =>   raw_req_ch4,
     raw_ack_ch4_i             =>   raw_ack_ch4 ,                                  -- raw data acknowledgement - channel 4
     
     filtered_addr_ch5_o       =>   filtered_addr_ch5,
     filtered_dat_ch5_i        =>   filtered_dat_ch5,
     fsfb_addr_ch5_o           =>   fsfb_addr_ch5 ,
     fsfb_dat_ch5_i            =>   fsfb_dat_ch5 ,
     flux_cnt_dat_ch5_i        =>   flux_cnt_dat_ch5,     
     coadded_addr_ch5_o        =>   coadded_addr_ch5,
     coadded_dat_ch5_i         =>   coadded_dat_ch5  ,
     raw_addr_ch5_o            =>   raw_addr_ch5,
     raw_dat_ch5_i             =>   raw_dat_ch5  ,  
     raw_req_ch5_o             =>   raw_req_ch5,
     raw_ack_ch5_i             =>   raw_ack_ch5,
     
     filtered_addr_ch6_o       =>   filtered_addr_ch6,
     filtered_dat_ch6_i        =>   filtered_dat_ch6,
     fsfb_addr_ch6_o           =>   fsfb_addr_ch6 ,
     fsfb_dat_ch6_i            =>   fsfb_dat_ch6 ,
     flux_cnt_dat_ch6_i        =>   flux_cnt_dat_ch6,     
     coadded_addr_ch6_o        =>   coadded_addr_ch6,
     coadded_dat_ch6_i         =>   coadded_dat_ch6  ,
     raw_addr_ch6_o            =>   raw_addr_ch6,
     raw_dat_ch6_i             =>   raw_dat_ch6  ,  
     raw_req_ch6_o             =>   raw_req_ch6,
     raw_ack_ch6_i             =>   raw_ack_ch6,

     filtered_addr_ch7_o       =>   filtered_addr_ch7,
     filtered_dat_ch7_i        =>   filtered_dat_ch7,
     fsfb_addr_ch7_o           =>   fsfb_addr_ch7 ,
     fsfb_dat_ch7_i            =>   fsfb_dat_ch7 ,
     flux_cnt_dat_ch7_i        =>   flux_cnt_dat_ch7,     
     coadded_addr_ch7_o        =>   coadded_addr_ch7,
     coadded_dat_ch7_i         =>   coadded_dat_ch7,  
     raw_addr_ch7_o            =>   raw_addr_ch7,
     raw_dat_ch7_i             =>   raw_dat_ch7  ,  
     raw_req_ch7_o             =>   raw_req_ch7,
     raw_ack_ch7_i             =>   raw_ack_ch7 ,       
   
       
     -- signals to/from dispatch  (wishbone interface)
  
     dat_i                     =>  wbm_dat_o,
     addr_i                    =>  wbm_addr_o,
     tga_i                     =>  wbm_tga_o,
     we_i                      =>  wbm_we_o,
     stb_i                     =>  wbm_stb_o,
     cyc_i                     =>  wbm_cyc_o,
                  
     dat_o                     =>  wbm_dat_i,
     ack_o                     =>  wbm_ack_i
     );   
      
 
-------------------------------------------------
-- Instantiate FLC simulator 
-------------------------------------------------

   i_tb_wbs_frame_data_flc_sim :  tb_wbs_frame_data_flc_sim
   
   port map (
   
     -- global inputs 
     rst_i                     =>  flc_buff_rst, 
     clk_i                     =>  dut_clk,

     -- signals to/from flux_loop_ctrl    

     filtered_addr_ch0_i       =>  filtered_addr_ch0,
     filtered_dat_ch0_o        =>  filtered_dat_ch0, 
     fsfb_addr_ch0_i           =>  fsfb_addr_ch0,
     fsfb_dat_ch0_o            =>  fsfb_dat_ch0,
     flux_cnt_dat_ch0_o        =>  flux_cnt_dat_ch0,
     coadded_addr_ch0_i        =>  coadded_addr_ch0,
     coadded_dat_ch0_o         =>  coadded_dat_ch0,
     raw_addr_ch0_i            =>  raw_addr_ch0, 
     raw_dat_ch0_o             =>  raw_dat_ch0, 
     raw_req_ch0_i             =>  raw_req_ch0,
     raw_ack_ch0_o             =>  raw_ack_ch0,


     filtered_addr_ch1_i       =>   filtered_addr_ch1,
     filtered_dat_ch1_o        =>   filtered_dat_ch1,
     fsfb_addr_ch1_i           =>   fsfb_addr_ch1,
     fsfb_dat_ch1_o            =>   fsfb_dat_ch1,
     flux_cnt_dat_ch1_o        =>   flux_cnt_dat_ch1,
     coadded_addr_ch1_i        =>   coadded_addr_ch1,
     coadded_dat_ch1_o         =>   coadded_dat_ch1,
     raw_addr_ch1_i            =>   raw_addr_ch1,
     raw_dat_ch1_o             =>   raw_dat_ch1,
     raw_req_ch1_i             =>   raw_req_ch1,
     raw_ack_ch1_o             =>   raw_ack_ch1,
      
     filtered_addr_ch2_i       =>   filtered_addr_ch2,
     filtered_dat_ch2_o        =>   filtered_dat_ch2, 
     fsfb_addr_ch2_i           =>   fsfb_addr_ch2, 
     fsfb_dat_ch2_o            =>   fsfb_dat_ch2, 
     flux_cnt_dat_ch2_o        =>   flux_cnt_dat_ch2,
     coadded_addr_ch2_i        =>   coadded_addr_ch2, 
     coadded_dat_ch2_o         =>   coadded_dat_ch2,
     raw_addr_ch2_i            =>   raw_addr_ch2,
     raw_dat_ch2_o             =>   raw_dat_ch2,
     raw_req_ch2_i             =>   raw_req_ch2,
     raw_ack_ch2_o             =>   raw_ack_ch2,
        
     filtered_addr_ch3_i       =>   filtered_addr_ch3,
     filtered_dat_ch3_o        =>   filtered_dat_ch3,
     fsfb_addr_ch3_i           =>   fsfb_addr_ch3 ,
     fsfb_dat_ch3_o            =>   fsfb_dat_ch3 ,
     flux_cnt_dat_ch3_o        =>   flux_cnt_dat_ch3,
     coadded_addr_ch3_i        =>   coadded_addr_ch3,
     coadded_dat_ch3_o         =>   coadded_dat_ch3  ,
     raw_addr_ch3_i            =>   raw_addr_ch3,
     raw_dat_ch3_o             =>   raw_dat_ch3  ,  
     raw_req_ch3_i             =>   raw_req_ch3,
     raw_ack_ch3_o             =>   raw_ack_ch3,
   
     filtered_addr_ch4_i       =>   filtered_addr_ch4,
     filtered_dat_ch4_o        =>   filtered_dat_ch4,
     fsfb_addr_ch4_i           =>   fsfb_addr_ch4 ,
     fsfb_dat_ch4_o            =>   fsfb_dat_ch4 ,
     flux_cnt_dat_ch4_o        =>   flux_cnt_dat_ch4,     
     coadded_addr_ch4_i        =>   coadded_addr_ch4,
     coadded_dat_ch4_o         =>   coadded_dat_ch4,  
     raw_addr_ch4_i            =>   raw_addr_ch4,
     raw_dat_ch4_o             =>   raw_dat_ch4,    
     raw_req_ch4_i             =>   raw_req_ch4,
     raw_ack_ch4_o             =>   raw_ack_ch4 ,                                  -- raw data acknowledgement - channel 4
     
     filtered_addr_ch5_i       =>   filtered_addr_ch5,
     filtered_dat_ch5_o        =>   filtered_dat_ch5,
     fsfb_addr_ch5_i           =>   fsfb_addr_ch5 ,
     fsfb_dat_ch5_o            =>   fsfb_dat_ch5 ,
     flux_cnt_dat_ch5_o        =>   flux_cnt_dat_ch5,     
     coadded_addr_ch5_i        =>   coadded_addr_ch5,
     coadded_dat_ch5_o         =>   coadded_dat_ch5  ,
     raw_addr_ch5_i            =>   raw_addr_ch5,
     raw_dat_ch5_o             =>   raw_dat_ch5  ,  
     raw_req_ch5_i             =>   raw_req_ch5,
     raw_ack_ch5_o             =>   raw_ack_ch5,
     
     filtered_addr_ch6_i       =>   filtered_addr_ch6,
     filtered_dat_ch6_o        =>   filtered_dat_ch6,
     fsfb_addr_ch6_i           =>   fsfb_addr_ch6 ,
     fsfb_dat_ch6_o            =>   fsfb_dat_ch6 ,
     flux_cnt_dat_ch6_o        =>   flux_cnt_dat_ch6,     
     coadded_addr_ch6_i        =>   coadded_addr_ch6,
     coadded_dat_ch6_o         =>   coadded_dat_ch6  ,
     raw_addr_ch6_i            =>   raw_addr_ch6,
     raw_dat_ch6_o             =>   raw_dat_ch6  ,  
     raw_req_ch6_i             =>   raw_req_ch6,
     raw_ack_ch6_o             =>   raw_ack_ch6,

     filtered_addr_ch7_i       =>   filtered_addr_ch7,
     filtered_dat_ch7_o        =>   filtered_dat_ch7,
     fsfb_addr_ch7_i           =>   fsfb_addr_ch7 ,
     fsfb_dat_ch7_o            =>   fsfb_dat_ch7 ,
     flux_cnt_dat_ch7_o        =>   flux_cnt_dat_ch7,     
     coadded_addr_ch7_i        =>   coadded_addr_ch7,
     coadded_dat_ch7_o         =>   coadded_dat_ch7,  
     raw_addr_ch7_i            =>   raw_addr_ch7,
     raw_dat_ch7_o             =>   raw_dat_ch7  ,  
     raw_req_ch7_i             =>   raw_req_ch7,
     raw_ack_ch7_o             =>   raw_ack_ch7       
   
     );     
   
   
 --------------------------------------------------
 ---   Wishbone Master Simulator
 ---   Register data reads using ack as enable
 --------------------------------------------------  
  
 -- register data reads (recirculation mux structure)
   
  wbm_dat_mux <= wbm_dat_i when wbm_ack_i = '1' else
                  wbm_dat_reg;
              
                  
  dff_wbm_dat_i: process(dut_rst, dut_clk)               
  begin
     if (dut_rst = '1') then   
        wbm_dat_reg <= (others => '0');
     elsif (dut_clk'EVENT and dut_clk = '1') then               
        wbm_dat_reg <= wbm_dat_mux ;            
     end if;                 
  end process dff_wbm_dat_i    ;            
                  
  -------------------------------------------------- 
   
 
   
------------------------------------------------
-- Create test bench clock
-------------------------------------------------
  
   dut_clk <= not dut_clk after clk_prd/2;   
 
------------------------------------------------
-- Create test bench stimuli
-------------------------------------------------
   
   stimuli : process
  
------------------------------------------------
-- Stimulus procedures
-------------------------------------------------
   
   -----------------------     
   procedure do_reset is
   -----------------------
      begin
         wbm_addr_o <= (others => '0'); 
         wbm_stb_o  <= '0';
         wbm_cyc_o  <= '0';
         wbm_we_o   <= '0';
   
         dut_rst <= '1';
         wait for clk_prd*5 ;
         dut_rst <= '0';
         wait for clk_prd*5 ;
      
         assert false report " Resetting the DUT." severity NOTE;
         wait for clk_prd;
      end do_reset;
   --------------------------
   
   --------------------------------     
   procedure do_init_flc_buffers is
   --------------------------------
   begin    
      flc_buff_rst <= '1'; 
      wait for clk_prd;
      assert false report " FLC Buffers Initialised......" severity NOTE;
      flc_buff_rst <= '0';
      wait for clk_prd;
   end do_init_flc_buffers;
   
   
   
   ------------------------------     
   procedure do_set_data_mode is 
   ------------------------------
      begin
      
         wbm_addr_o <= DATA_MODE_ADDR;
         wbm_stb_o  <= '1';
         wbm_cyc_o  <= '1';
         wbm_we_o   <= '1';
         
         wait until wbm_ack_i = '1';
         wait for clk_prd;
         
         wbm_addr_o <= (others => '0'); 
         wbm_stb_o  <= '0';
         wbm_cyc_o  <= '0';
         wbm_we_o   <= '0';
          
         wait for clk_prd;
           
      end do_set_data_mode;
   --------------------------
   
   
   ------------------------------     
   procedure do_read_data_mode is 
   ------------------------------
      begin
      
         wbm_addr_o <= DATA_MODE_ADDR;
         wbm_stb_o  <= '1';
         wbm_cyc_o  <= '1';
         wbm_we_o   <= '0';
         
         wait until wbm_ack_i = '1';
         wait for clk_prd;
         
         wbm_addr_o <= (others => '0'); 
         wbm_stb_o  <= '0';
         wbm_cyc_o  <= '0';
         wbm_we_o   <= '0';
          
         wait for clk_prd;
           
      end do_read_data_mode;
   --------------------------
   
   ------------------------------     
   procedure do_set_readout_row_index is 
   ------------------------------
      begin
      
         wbm_addr_o <= READOUT_ROW_INDEX_ADDR;
         wbm_stb_o  <= '1';
         wbm_cyc_o  <= '1';
         wbm_we_o   <= '1';
         
         wait until wbm_ack_i = '1';
         wait for clk_prd;
         
         wbm_addr_o <= (others => '0'); 
         wbm_stb_o  <= '0';
         wbm_cyc_o  <= '0';
         wbm_we_o   <= '0';
          
         wait for clk_prd;
           
      end do_set_readout_row_index;
   --------------------------
   
   
   ------------------------------     
   procedure do_read_readout_row_index is 
   ------------------------------
      begin
      
         wbm_addr_o <= READOUT_ROW_INDEX_ADDR;
         wbm_stb_o  <= '1';
         wbm_cyc_o  <= '1';
         wbm_we_o   <= '0';
         
         wait until wbm_ack_i = '1';
         wait for clk_prd;
         
         wbm_addr_o <= (others => '0'); 
         wbm_stb_o  <= '0';
         wbm_cyc_o  <= '0';
         wbm_we_o   <= '0';
          
         wait for clk_prd;
           
      end do_read_readout_row_index;
   --------------------------
   
    ------------------------------     
   procedure do_write_ret_data is 
   ------------------------------
      begin
      
         wbm_addr_o <= RET_DAT_ADDR;
         wbm_stb_o  <= '1';
         wbm_cyc_o  <= '1';
         wbm_we_o   <= '1';
         
         wait until wbm_ack_i = '1';
         wait for clk_prd;
         
         wbm_addr_o <= (others => '0'); 
         wbm_stb_o  <= '0';
         wbm_cyc_o  <= '0';
         wbm_we_o   <= '0';
          
         wait for clk_prd;
           
      end do_write_ret_data;
   --------------------------
   
    ----------------------------    
   procedure do_req_raw_data is
   -----------------------------
      begin
 

         wbm_addr_o <= CAPTR_RAW_ADDR;
         wbm_stb_o  <= '1';
         wbm_cyc_o  <= '1';
         wbm_we_o   <= '1';
                  
         wait until wbm_ack_i = '1';
         wait for clk_prd;
         
         wbm_addr_o <= (others => '0'); 
         wbm_stb_o  <= '0';
         wbm_cyc_o  <= '0';
         wbm_we_o   <= '0';   
         wbm_dat_o  <= (others => '0') ;      
         
                
         assert false report " RAW data collected by FLC..........." severity NOTE;
         wait for clk_prd;
         
      
      end do_req_raw_data;
   --------------------------
   
   
    ----------------------------    
   procedure do_read_captr_raw is
   -----------------------------
      begin


         wbm_addr_o <= CAPTR_RAW_ADDR;
         wbm_stb_o  <= '1';
         wbm_cyc_o  <= '1';
         wbm_we_o   <= '0';
                  
         wait until wbm_ack_i = '1';
         wait for clk_prd;
         
         wbm_addr_o <= (others => '0'); 
         wbm_stb_o  <= '0';
         wbm_cyc_o  <= '0';
         wbm_we_o   <= '0';   
         wbm_dat_o  <= (others => '0') ;      
         
         wait for clk_prd;
         
      
      end do_read_captr_raw;
   --------------------------
   
     
   -----------------------------------------    
   procedure do_insert_master_wait_state is
   -- insert one master wait state
   -----------------------------------------
   begin 
   
      wbm_stb_o  <= '0';
      assert false report "MASTER WAIT STATE INSERTED........." severity NOTE;
      wait for clk_prd;
      wbm_stb_o  <= '1' ;
   end do_insert_master_wait_state;        
   
   
   -----------------------------------------    
   procedure do_start_ret_data is
   -- insert one master wait state
   -----------------------------------------
   begin 
    
      wbm_addr_o <= RET_DAT_ADDR;
      wbm_stb_o  <= '1';
      wbm_cyc_o  <= '1';
      wbm_we_o   <= '0';
      wbm_dat_o  <= (others => '0') ; 
     
   end do_start_ret_data;       
   
   
   
   -----------------------------------------    
   procedure do_end_ret_data is
   -- insert one master wait state
   -----------------------------------------
   begin 
       wbm_addr_o <= (others => '0'); 
       wbm_stb_o  <= '0';
       wbm_cyc_o  <= '0';
       wbm_we_o   <= '0';   
       wbm_dat_o  <= (others => '0') ;      
   
   end do_end_ret_data;       
   
   
--------------------------------------------------

   begin
   
   do_reset;
   
   do_init_flc_buffers;
   
   
   -- Capture Raw Data - FLC instruction         
   do_req_raw_data;
   
   -- test writing and reading data mode
   wbm_dat_o <= MODE4_FB_ERROR;
   do_set_data_mode;
   assert false report " DATA MODE SET ....." severity NOTE;
   wait for clk_prd;
   do_read_data_mode;
   assert false report " DATA MODE READ ....." severity NOTE;
   wait for clk_prd;
   
   -- test reading captr raw.....  (meaningless instruction whcih requires ack...)
  
   do_read_captr_raw;
   assert false report " CAPTR RAW READ ....." severity NOTE;
   wait for clk_prd;
   
   -- test writing and reading readout_row_index
   wbm_dat_o <= conv_std_logic_vector(10, WB_DATA_WIDTH);
   do_set_readout_row_index;
   assert false report " READOUT_ROW SET ....." severity NOTE;
   wait for clk_prd;
   do_read_readout_row_index;
   assert false report " READOUT_ROW READ ....." severity NOTE;
   wait for clk_prd;
   
   -- test writing ret_dat (error instruction whcih requires ack...)
   do_write_ret_data;
   assert false report " WRITE RET_DATA ....." severity NOTE;
   wait for clk_prd;
   
   -- Get MODE 0 error data
   ------------------------------
   wbm_dat_o <= MODE0_ERROR;
   do_set_data_mode;
   assert false report " DATA MODE SET to MODE 0 (ERROR)......" severity NOTE;
   
   wait for clk_prd;
   
   do_start_ret_data; 
                  
   wait until wbm_ack_i = '1';
   
   for i in 1 to (1*8) loop
      wait for clk_prd;
   end loop;
            
   do_end_ret_data;   
   
   wait  for clk_prd;
  
   assert false report "A Frame of ERROR (COADD) data has been read....." severity NOTE;
   
   wait for clk_prd;
   
     assert (wbm_dat_reg = x"070AFFFF" ) report "***LAST DATA WORD INCORRECT....***" severity ERROR;
--     assert (conv_integer(fsfb_addr_ch7) = 0) report "***ADDRESS NOT BACK TO ZERO***" severity ERROR;   
 
   
   -- Get MODE 1 unfilterd data
   ------------------------------
   wbm_dat_o <= MODE1_UNFILTERED;
   do_set_data_mode;
   assert false report " DATA MODE SET to MODE 1 (UNFILTERED)......" severity NOTE;
   
   wait for clk_prd;
   
   do_start_ret_data; 
                  
   wait until wbm_ack_i = '1';
   
   for i in 1 to (31*8) loop
      wait for clk_prd;
   end loop;
            
   do_end_ret_data;   
   
   wait  for clk_prd;
   
   assert false report "A row-10 to 41 Frame of UNFILTERED data has been read....." severity NOTE;
   
   wait for clk_prd;
   
     assert (wbm_dat_reg = x"1728FFFF" ) report "***LAST DATA WORD INCORRECT....***" severity ERROR;
--     assert (conv_integer(fsfb_addr_ch7) = 0) report "***ADDRESS NOT BACK TO ZERO***" severity ERROR;
   
   
   ---- check the wrapping
   do_start_ret_data; 
                  
   wait until wbm_ack_i = '1';
   
   for i in 1 to (41*8) loop
      wait for clk_prd;
   end loop;
            
   do_end_ret_data;   
   
   wait  for clk_prd;
   
   assert false report "A Full Frame of UNFILTERED data has been read....." severity NOTE;
   
   wait for clk_prd;
   
   assert (wbm_dat_reg = x"1709FFFF" ) report "***LAST DATA WORD INCORRECT....***" severity ERROR;
   
 
   -- Get MODE 3 raw data
   ------------------------------
   -- test writing and reading readout_row_index
   wbm_dat_o <= conv_std_logic_vector(0, WB_DATA_WIDTH);
   do_set_readout_row_index;
   assert false report " READOUT_ROW RESET ....." severity NOTE;
   
   wbm_dat_o <= MODE3_RAW;
   do_set_data_mode;
   assert false report " DATA MODE SET to MODE 3 (RAW)......" severity NOTE;
   
    wait for clk_prd;
   
   -- read 128 sets or raw data to get a full raw data frame...
   
   for i in 1 to 128 loop 
     
      do_start_ret_data; 
      wait until wbm_ack_i = '1';
   
      for j in 1 to (41*8) loop
         wait for clk_prd;
      end loop;
      
      assert (wbm_dat_reg = x"000037" & conv_std_logic_vector(i, 8)) report "**SET OF RAW DATA READ.........." severity NOTE;
      do_end_ret_data; 
      wait  for clk_prd;
   
   end loop;
   
       
   assert (wbm_dat_reg = x"0000377F" ) report "***LAST DATA WORD INCORRECT....***" severity ERROR;
  -- assert (conv_integer(raw_addr_ch7) = 0) report "***ADDRESS NOT BACK TO ZERO***" severity ERROR;
         
   assert false report "******A FRAME OF RAW DATA HAS BEEN READ******" severity NOTE;
   
   -- now test for end of 8192 raw buffer check
   for i in 1 to 72 loop 
     
      do_start_ret_data; 
      wait until wbm_ack_i = '1';
   
      for j in 1 to (41*8) loop
         wait for clk_prd;
      end loop;
      
      assert (wbm_dat_reg = x"000037" & conv_std_logic_vector(i, 8)) report "**SET OF RAW DATA READ.........." severity NOTE;
      do_end_ret_data; 
      wait  for clk_prd;
   
   end loop;
   

   -- Get MODE 2 Filtered data -- currently not working because test bench doesn't excite restart_frame_1row_post
   ------------------------------
   wait for clk_prd; -- This is sort of to cover up a non-desired case that the state machine is not in idle yet and would cause ignore of the next command

   wbm_dat_o <= MODE2_FILTERED;
   do_set_data_mode;
   assert false report " DATA MODE SET to MODE 2 (FILTERED)......" severity NOTE;
   
   wait for clk_prd;
   
   do_start_ret_data; 
                  
   wait until wbm_ack_i = '1';
   
   for i in 1 to (31*8) loop
      wait for clk_prd;
   end loop;
            
   do_end_ret_data;    
   
   wait  for clk_prd;
      
   assert false report "A Frame of FILTERED data has been read....." severity NOTE;
   
   assert (wbm_dat_reg = x"2728FFFF" ) report "***LAST DATA WORD INCORRECT....***" severity ERROR;
     
    -- assert (conv_integer(filtered_addr_ch7) = 0) report "***ADDRESS NOT BACK TO ZERO***" severity ERROR;
   
   -- wait for clk_prd * 20;
   -- assert false report "END OF SIMULATION....." severity FAILURE;

   -- Get MODE 4 fb/error data
   ------------------------------
   wbm_dat_o <= MODE4_FB_ERROR;
   do_set_data_mode;
   assert false report " DATA MODE SET to MODE 4 (FB_ERROR)......" severity NOTE;
   
   wait for clk_prd;
  
  
   do_start_ret_data; 
   
                  
   wait until wbm_ack_i = '1';  
   for i in 1 to (41*4) loop     -- wait for half a frame
      wait for clk_prd;
   end loop;
     
   do_insert_master_wait_state;
  
   wait until wbm_ack_i = '1'; 
   for i in 1 to (41*4) loop    -- wait for 2nd half of frame data
      wait for clk_prd;
   end loop;
   
   do_end_ret_data;
            
   
   wait  for clk_prd;
   
   assert (wbm_dat_reg = x"17282728" ) report "***LAST DATA WORD INCORRECT....***" severity ERROR;
 --  assert (conv_integer(fsfb_addr_ch7) = 0) report "***ADDRESS NOT BACK TO ZERO***" severity ERROR;
 --  assert (conv_integer(coadded_addr_ch7) = 0) report "***ADDRESS NOT BACK TO ZERO***" severity ERROR;
   
   assert false report "A Frame of FEEDBACK/ERROR data has been read....." severity NOTE;


   -- Get MODE 5 fb/flx_cnt data
   ------------------------------
   wbm_dat_o <= MODE5_FB_FLX_CNT;
   do_set_data_mode;
   assert false report " DATA MODE SET to MODE 5 (FB_FLX_CNT)......" severity NOTE;
   
   wait for clk_prd;
  
  
   do_start_ret_data; 
   
                  
   wait until wbm_ack_i = '1';  
   for i in 1 to (41*4) loop     -- wait for half a frame
      wait for clk_prd;
   end loop;
     
   do_insert_master_wait_state;
  
   wait until wbm_ack_i = '1'; 
   for i in 1 to (41*4) loop    -- wait for 2nd half of frame data
      wait for clk_prd;
   end loop;
   
   do_end_ret_data;
            
   
   wait  for clk_prd;
   
   assert (wbm_dat_reg = x"17282728" ) report "***LAST DATA WORD INCORRECT....***" severity ERROR;
 --  assert (conv_integer(fsfb_addr_ch7) = 0) report "***ADDRESS NOT BACK TO ZERO***" severity ERROR;
 --  assert (conv_integer(coadded_addr_ch7) = 0) report "***ADDRESS NOT BACK TO ZERO***" severity ERROR;
   
   assert false report "A Frame of FEEDBACK/FLUX_COUNT data has been read....." severity NOTE;

   ------------------------------

   wait for clk_prd*20;
   assert false report "END OF SIMULATION....." severity FAILURE;
   
   wait;
   
   end process stimuli;   
           
end bench;
