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
-- tb_wbs_frame_data_flc_sim.vhd
--
--
-- Project: 			Scuba 2
-- Author:  			David Atkinson
-- Organisation: 			UKATC
--
-- Description:
-- 
-- test block to mimic flux_loop_cntl behaviour for wbs_frame_data test bed.
--
-- Revision history:
-- <date $Date: 2004/10/20 13:21:50 $> - <text> - <initials $Author: dca $>
--
-- $Log: tb_wbs_frame_data.vhd,v $
--
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

entity tb_wbs_frame_data_flc_sim is

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
end tb_wbs_frame_data_flc_sim;



library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;

library work;
use work.wbs_frame_data_pack.all;


architecture behav of tb_wbs_frame_data_flc_sim is

signal filtered_dat_ch0      : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  
signal fsfb_dat_ch0          : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0); 
signal coadded_dat_ch0       : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  
signal raw_dat_ch0           : std_logic_vector (RAW_DATA_WIDTH-1    downto 0);                            

signal filtered_dat_ch1      : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  
signal fsfb_dat_ch1          : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0); 
signal coadded_dat_ch1       : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  
signal raw_dat_ch1           : std_logic_vector (RAW_DATA_WIDTH-1    downto 0); 
 
signal filtered_dat_ch2      : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);   
signal fsfb_dat_ch2          : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);    
signal coadded_dat_ch2       : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);   
signal raw_dat_ch2           : std_logic_vector (RAW_DATA_WIDTH-1    downto 0); 

signal filtered_dat_ch3      : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  
signal fsfb_dat_ch3          : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0); 
signal coadded_dat_ch3       : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  
signal raw_dat_ch3           : std_logic_vector (RAW_DATA_WIDTH-1    downto 0); 

signal filtered_dat_ch4      : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);   
signal fsfb_dat_ch4          : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0); 
signal coadded_dat_ch4       : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);   
signal raw_dat_ch4           : std_logic_vector (RAW_DATA_WIDTH-1    downto 0); 

signal filtered_dat_ch5      : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);   
signal fsfb_dat_ch5          : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);   
signal coadded_dat_ch5       : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  
signal raw_dat_ch5           : std_logic_vector (RAW_DATA_WIDTH-1    downto 0); 
       
 
signal filtered_dat_ch6      : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  
signal fsfb_dat_ch6          : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  
signal coadded_dat_ch6       : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);    
signal raw_dat_ch6           : std_logic_vector (RAW_DATA_WIDTH-1    downto 0); 
     
 
signal filtered_dat_ch7      : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  
signal fsfb_dat_ch7          : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0); 
signal coadded_dat_ch7       : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  
signal raw_dat_ch7           : std_logic_vector (RAW_DATA_WIDTH-1    downto 0); 
        
    
signal raw_req_all        : std_logic;
signal raw_ack_all        : std_logic;

-- flux loop  contorl memory buffers

subtype dat_word  is std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
subtype raw_word  is std_logic_vector (RAW_DATA_WIDTH-1    downto 0); 

constant DAT_MEM_SIZE   : positive := 2**ROW_ADDR_WIDTH;
constant RAW_MEM_SIZE   : positive  := 2**RAW_ADDR_WIDTH;

type dat_memory is array (0 to DAT_MEM_SIZE-1) of dat_word;
type raw_memory is array (0 to RAW_MEM_SIZE-1) of raw_word;


-- 8 data channel bufferes 
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


-------------


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


type state is (IDLE, BUSY, ACK, DONE);                           

signal current_state:   state;
signal next_state:      state;

signal wait_count     : integer := 0;
signal rst_wait_count : std_logic;
signal ena_wait_count : std_logic;

begin

   
 --------------------------------  
 init_buffers : process (rst_i)
 --------------------------------
 -- on reset assign values to memory buffers
 -- which permit each address to be identified....
 -------------------------------
 
 -- most sig 4 bit = data type id
 -- next 4 bits  = channel id
 -- next 8 bits = row id
 
 --
 -- for filtered, fsfb, and coadd LS 16bits = 0xFFFF
 -- (raw data is only 16bits wide) 
 -- 
 -- for raw data there are 2x41x64 values per channel 
 -- (2 frames x 41 rows x 64 samples/row)
 -- here the 64 samples per row all have the same
 -- row id.  Essentially 82 rows x 64
 
  
 begin
 
    if (rst_i = '1') then
        
       for i in 0 to NO_PIX_PER_CH-1 loop
          filtered_buff_ch0(i) <=  FILTERED_DATA & CHANNEL_0 & conv_std_logic_vector(i,8) & x"FFFF";
          filtered_buff_ch1(i) <=  FILTERED_DATA & CHANNEL_1 & conv_std_logic_vector(i,8) & x"FFFF";
          filtered_buff_ch2(i) <=  FILTERED_DATA & CHANNEL_2 & conv_std_logic_vector(i,8) & x"FFFF";
          filtered_buff_ch3(i) <=  FILTERED_DATA & CHANNEL_3 & conv_std_logic_vector(i,8) & x"FFFF";
          filtered_buff_ch4(i) <=  FILTERED_DATA & CHANNEL_4 & conv_std_logic_vector(i,8) & x"FFFF";
          filtered_buff_ch5(i) <=  FILTERED_DATA & CHANNEL_5 & conv_std_logic_vector(i,8) & x"FFFF";
          filtered_buff_ch6(i) <=  FILTERED_DATA & CHANNEL_6 & conv_std_logic_vector(i,8) & x"FFFF";
          filtered_buff_ch7(i) <=  FILTERED_DATA & CHANNEL_7 & conv_std_logic_vector(i,8) & x"FFFF";
       
          fsfb_buff_ch0(i)     <=  FSFB_DATA & CHANNEL_0 & conv_std_logic_vector(i,8) & x"FFFF";
          fsfb_buff_ch1(i)     <=  FSFB_DATA & CHANNEL_1 & conv_std_logic_vector(i,8) & x"FFFF";
          fsfb_buff_ch2(i)     <=  FSFB_DATA & CHANNEL_2 & conv_std_logic_vector(i,8) & x"FFFF";
          fsfb_buff_ch3(i)     <=  FSFB_DATA & CHANNEL_3 & conv_std_logic_vector(i,8) & x"FFFF";
          fsfb_buff_ch4(i)     <=  FSFB_DATA & CHANNEL_4 & conv_std_logic_vector(i,8) & x"FFFF";
          fsfb_buff_ch5(i)     <=  FSFB_DATA & CHANNEL_5 & conv_std_logic_vector(i,8) & x"FFFF";
          fsfb_buff_ch6(i)     <=  FSFB_DATA & CHANNEL_6 & conv_std_logic_vector(i,8) & x"FFFF";
          fsfb_buff_ch7(i)     <=  FSFB_DATA & CHANNEL_7 & conv_std_logic_vector(i,8) & x"FFFF";
       
          coadd_buff_ch0(i)    <=  COADD_DATA & CHANNEL_0 & conv_std_logic_vector(i,8) & x"FFFF";
          coadd_buff_ch1(i)    <=  COADD_DATA & CHANNEL_1 & conv_std_logic_vector(i,8) & x"FFFF";
          coadd_buff_ch2(i)    <=  COADD_DATA & CHANNEL_2 & conv_std_logic_vector(i,8) & x"FFFF";
          coadd_buff_ch3(i)    <=  COADD_DATA & CHANNEL_3 & conv_std_logic_vector(i,8) & x"FFFF";
          coadd_buff_ch4(i)    <=  COADD_DATA & CHANNEL_4 & conv_std_logic_vector(i,8) & x"FFFF";
          coadd_buff_ch5(i)    <=  COADD_DATA & CHANNEL_5 & conv_std_logic_vector(i,8) & x"FFFF";
          coadd_buff_ch6(i)    <=  COADD_DATA & CHANNEL_6 & conv_std_logic_vector(i,8) & x"FFFF";
          coadd_buff_ch7(i)    <=  COADD_DATA & CHANNEL_7 & conv_std_logic_vector(i,8) & x"FFFF";      
       end loop;
 
    -- save 64 samples per pixels.....keep all 64 samples/pixel the same 
    -- there are 2x41 pixels per channel
    
       for i in 0 to (NO_PIX_PER_CH * 2)-1 loop
          for j in 0 to NO_SAMPLES-1 loop 
             raw_buff_ch0(i*NO_SAMPLES+j)    <=  RAW_DATA & CHANNEL_0 & conv_std_logic_vector(i,8) ;
             raw_buff_ch1(i*NO_SAMPLES+j)    <=  RAW_DATA & CHANNEL_1 & conv_std_logic_vector(i,8) ;
             raw_buff_ch2(i*NO_SAMPLES+j)    <=  RAW_DATA & CHANNEL_2 & conv_std_logic_vector(i,8) ;
             raw_buff_ch3(i*NO_SAMPLES+j)    <=  RAW_DATA & CHANNEL_3 & conv_std_logic_vector(i,8) ;
             raw_buff_ch4(i*NO_SAMPLES+j)    <=  RAW_DATA & CHANNEL_4 & conv_std_logic_vector(i,8) ;
             raw_buff_ch5(i*NO_SAMPLES+j)    <=  RAW_DATA & CHANNEL_5 & conv_std_logic_vector(i,8) ;
             raw_buff_ch6(i*NO_SAMPLES+j)    <=  RAW_DATA & CHANNEL_6 & conv_std_logic_vector(i,8) ;
             raw_buff_ch7(i*NO_SAMPLES+j)    <=  RAW_DATA & CHANNEL_7 & conv_std_logic_vector(i,8) ;
         end loop;           
      end loop;
   end if; 
end process init_buffers;
 
-----------  buffer outputs mapped to entity outputs....



 
------------------------------------
clock_buffers : process(clk_i, rst_i)
------------------------------------
   begin
         
      if (rst_i = '1') then
      
         filtered_dat_ch0   <= (others => '0');  
         fsfb_dat_ch0       <= (others => '0');  
         coadded_dat_ch0    <= (others => '0');  
         raw_dat_ch0        <= (others => '0');  
         
         filtered_dat_ch1   <= (others => '0');  
         fsfb_dat_ch1       <= (others => '0');  
         coadded_dat_ch1    <= (others => '0');  
         raw_dat_ch1        <= (others => '0');  
         
         filtered_dat_ch2   <= (others => '0');  
         fsfb_dat_ch2       <= (others => '0');  
         coadded_dat_ch2    <= (others => '0');  
         raw_dat_ch2        <= (others => '0');  
         
         filtered_dat_ch3   <= (others => '0');  
         fsfb_dat_ch3       <= (others => '0');  
         coadded_dat_ch3    <= (others => '0');  
         raw_dat_ch3        <= (others => '0');  
         
         filtered_dat_ch4   <= (others => '0');  
         fsfb_dat_ch4       <= (others => '0');  
         coadded_dat_ch4    <= (others => '0');  
         raw_dat_ch4        <= (others => '0');  
         
         filtered_dat_ch5   <= (others => '0');  
         fsfb_dat_ch5       <= (others => '0');  
         coadded_dat_ch5    <= (others => '0');  
         raw_dat_ch5        <= (others => '0');  
         
         filtered_dat_ch6   <= (others => '0');  
         fsfb_dat_ch6       <= (others => '0');  
         coadded_dat_ch6    <= (others => '0');  
         raw_dat_ch6        <= (others => '0');    
         
         filtered_dat_ch7   <= (others => '0');  
         fsfb_dat_ch7       <= (others => '0');  
         coadded_dat_ch7    <= (others => '0');  
         raw_dat_ch7        <= (others => '0');  
              
         
      elsif (clk_i'EVENT AND clk_i = '1') then
         filtered_dat_ch0   <= filtered_buff_ch0 (conv_integer(filtered_addr_ch0_i))  ;
         fsfb_dat_ch0       <= fsfb_buff_ch0     (conv_integer(fsfb_addr_ch0_i));
         coadded_dat_ch0    <= coadd_buff_ch0    (conv_integer(coadded_addr_ch0_i));
         raw_dat_ch0        <= raw_buff_ch0      (conv_integer(raw_addr_ch0_i) );  
         
         filtered_dat_ch1   <= filtered_buff_ch1 (conv_integer(filtered_addr_ch1_i) ); 
         fsfb_dat_ch1       <= fsfb_buff_ch1     (conv_integer(fsfb_addr_ch1_i)   );
         coadded_dat_ch1    <= coadd_buff_ch1    (conv_integer(coadded_addr_ch1_i));
         raw_dat_ch1        <= raw_buff_ch1      (conv_integer(raw_addr_ch1_i)   );
         
         filtered_dat_ch2   <= filtered_buff_ch2 (conv_integer(filtered_addr_ch2_i) ); 
         fsfb_dat_ch2       <= fsfb_buff_ch2     (conv_integer(fsfb_addr_ch2_i)   );
         coadded_dat_ch2    <= coadd_buff_ch2    (conv_integer(coadded_addr_ch2_i));
         raw_dat_ch2        <= raw_buff_ch2      (conv_integer(raw_addr_ch2_i)   );
         
         filtered_dat_ch3   <= filtered_buff_ch3 (conv_integer(filtered_addr_ch3_i) ); 
         fsfb_dat_ch3       <= fsfb_buff_ch3     (conv_integer(fsfb_addr_ch3_i));   
         coadded_dat_ch3    <= coadd_buff_ch3    (conv_integer(coadded_addr_ch3_i));
         raw_dat_ch3        <= raw_buff_ch3      (conv_integer(raw_addr_ch3_i));  
         
         filtered_dat_ch4   <= filtered_buff_ch4 (conv_integer(filtered_addr_ch4_i));  
         fsfb_dat_ch4       <= fsfb_buff_ch4     (conv_integer(fsfb_addr_ch4_i));  
         coadded_dat_ch4    <= coadd_buff_ch4    (conv_integer(coadded_addr_ch4_i));
         raw_dat_ch4        <= raw_buff_ch4      (conv_integer(raw_addr_ch4_i));   
         
         filtered_dat_ch5   <= filtered_buff_ch5 (conv_integer(filtered_addr_ch5_i));  
         fsfb_dat_ch5       <= fsfb_buff_ch5     (conv_integer(fsfb_addr_ch5_i));   
         coadded_dat_ch5    <= coadd_buff_ch5    (conv_integer(coadded_addr_ch5_i));
         raw_dat_ch5        <= raw_buff_ch5      (conv_integer(raw_addr_ch5_i) );  
         
         filtered_dat_ch6   <= filtered_buff_ch6 (conv_integer(filtered_addr_ch6_i) ); 
         fsfb_dat_ch6       <= fsfb_buff_ch6     (conv_integer(fsfb_addr_ch6_i));   
         coadded_dat_ch6    <= coadd_buff_ch6    (conv_integer(coadded_addr_ch6_i));
         raw_dat_ch6        <= raw_buff_ch6      (conv_integer(raw_addr_ch6_i)   );
         
         filtered_dat_ch7   <= filtered_buff_ch7 (conv_integer(filtered_addr_ch7_i));  
         fsfb_dat_ch7       <= fsfb_buff_ch7     (conv_integer(fsfb_addr_ch7_i)   );
         coadded_dat_ch7    <= coadd_buff_ch7    (conv_integer(coadded_addr_ch7_i));
         raw_dat_ch7        <= raw_buff_ch7      (conv_integer(raw_addr_ch7_i));       

      end if;

   end process clock_buffers;
   
   
  
 
--------------------------------------------
register_buff_output : process(clk_i, rst_i)
--------------------------------------------
   begin
         
      if (rst_i = '1') then
 
         filtered_dat_ch0_o   <= (others => '0');  
         fsfb_dat_ch0_o       <= (others => '0');  
         coadded_dat_ch0_o    <= (others => '0');  
         raw_dat_ch0_o        <= (others => '0');  
         
         filtered_dat_ch1_o   <= (others => '0');  
         fsfb_dat_ch1_o       <= (others => '0');  
         coadded_dat_ch1_o    <= (others => '0');  
         raw_dat_ch1_o        <= (others => '0');  
         
         filtered_dat_ch2_o   <= (others => '0');  
         fsfb_dat_ch2_o       <= (others => '0');  
         coadded_dat_ch2_o    <= (others => '0');  
         raw_dat_ch2_o        <= (others => '0');  
         
         filtered_dat_ch3_o   <= (others => '0');  
         fsfb_dat_ch3_o       <= (others => '0');  
         coadded_dat_ch3_o    <= (others => '0');  
         raw_dat_ch3_o        <= (others => '0');  
         
         filtered_dat_ch4_o   <= (others => '0');  
         fsfb_dat_ch4_o       <= (others => '0');  
         coadded_dat_ch4_o    <= (others => '0');  
         raw_dat_ch4_o        <= (others => '0');  
         
         filtered_dat_ch5_o   <= (others => '0');  
         fsfb_dat_ch5_o       <= (others => '0');  
         coadded_dat_ch5_o    <= (others => '0');  
         raw_dat_ch5_o        <= (others => '0');  
         
         filtered_dat_ch6_o   <= (others => '0');  
         fsfb_dat_ch6_o       <= (others => '0');  
         coadded_dat_ch6_o    <= (others => '0');  
         raw_dat_ch6_o        <= (others => '0');    
         
         filtered_dat_ch7_o   <= (others => '0');  
         fsfb_dat_ch7_o       <= (others => '0');  
         coadded_dat_ch7_o    <= (others => '0');  
         raw_dat_ch7_o        <= (others => '0'); 

 
      elsif (clk_i'event and clk_i = '1') then 
 
         filtered_dat_ch0_o   <= filtered_dat_ch0;  
         fsfb_dat_ch0_o       <= fsfb_dat_ch0;  
         coadded_dat_ch0_o    <= coadded_dat_ch0;  
         raw_dat_ch0_o        <= raw_dat_ch0;  
         
         filtered_dat_ch1_o   <= filtered_dat_ch1;  
         fsfb_dat_ch1_o       <= fsfb_dat_ch1;  
         coadded_dat_ch1_o    <= coadded_dat_ch1;  
         raw_dat_ch1_o        <= raw_dat_ch1;  
         
         filtered_dat_ch2_o   <= filtered_dat_ch2;  
         fsfb_dat_ch2_o       <= fsfb_dat_ch2;  
         coadded_dat_ch2_o    <= coadded_dat_ch2;  
         raw_dat_ch2_o        <= raw_dat_ch2;  
         
         filtered_dat_ch3_o   <= filtered_dat_ch3;  
         fsfb_dat_ch3_o       <= fsfb_dat_ch3;  
         coadded_dat_ch3_o    <= coadded_dat_ch3;  
         raw_dat_ch3_o        <= raw_dat_ch3;  
         
         filtered_dat_ch4_o   <= filtered_dat_ch4;  
         fsfb_dat_ch4_o       <= fsfb_dat_ch4;  
         coadded_dat_ch4_o    <= coadded_dat_ch4;  
         raw_dat_ch4_o        <= raw_dat_ch4;  
         
         filtered_dat_ch5_o   <= filtered_dat_ch5;  
         fsfb_dat_ch5_o       <= fsfb_dat_ch5;  
         coadded_dat_ch5_o    <= coadded_dat_ch5;  
         raw_dat_ch5_o        <= raw_dat_ch5;  
         
         filtered_dat_ch6_o   <= filtered_dat_ch6;  
         fsfb_dat_ch6_o       <= fsfb_dat_ch6;  
         coadded_dat_ch6_o    <= coadded_dat_ch6;  
         raw_dat_ch6_o        <= raw_dat_ch6;  
         
         filtered_dat_ch7_o   <= filtered_dat_ch7;  
         fsfb_dat_ch7_o       <= fsfb_dat_ch7;  
         coadded_dat_ch7_o    <= coadded_dat_ch7;  
         raw_dat_ch7_o        <= raw_dat_ch7;  
  
      end if;
 
   end process register_buff_output;
 
 
 
 
 
raw_req_all <= raw_req_ch0_i and raw_req_ch1_i and raw_req_ch2_i and raw_req_ch3_i and
               raw_req_ch4_i and raw_req_ch5_i and raw_req_ch6_i and raw_req_ch7_i ;
 
raw_ack_ch0_o <= raw_ack_all;
raw_ack_ch1_o <= raw_ack_all;
raw_ack_ch2_o <= raw_ack_all;
raw_ack_ch3_o <= raw_ack_all;
raw_ack_ch4_o <= raw_ack_all;
raw_ack_ch5_o <= raw_ack_all;
raw_ack_ch6_o <= raw_ack_all;
raw_ack_ch7_o <= raw_ack_all;
 
 
------------------------------------
clock_fsm : process(clk_i, rst_i)
------------------------------------
   begin
         
      if (rst_i = '1') then
         current_state <= IDLE;
      elsif (clk_i'EVENT AND clk_i = '1') then
         current_state <= next_state;
      end if;

   end process clock_fsm;
   
--------------------------------------------------------------------------------------
nextstate_fsm: process (current_state, raw_req_all, wait_count)
 ---------------------------------------------------------------------------------------
   begin
      case current_state is
      
      when IDLE =>
         if raw_req_all = '1' then 
           next_state <= BUSY;
         else 
           next_state <= IDLE;
         end if;   
         
                   
      when BUSY  => 
        if (wait_count <  RAW_DELAY ) then 
           next_state <= BUSY;
        else
           next_state <= ACK;
        end if; 
        
      when ACK =>
         next_state <= DONE;
                    
      when DONE =>
         next_state <= IDLE;
      
      when others =>
         next_state <= IDLE;
      end case;
    end process nextstate_fsm;
    
   --------------------------------------- 
   output_fsm: process (current_state)
   ---------------------------------------
   begin
      case current_state is
      
      when IDLE =>
        raw_ack_all        <= '0';
        ena_wait_count     <= '0';
        rst_wait_count     <= '1';
                      
      when BUSY =>
         raw_ack_all       <= '0';
         ena_wait_count    <= '1';
         rst_wait_count    <= '0';

      when ACK =>
         raw_ack_all       <= '1';
         ena_wait_count    <= '0';
         rst_wait_count    <= '0';

      when DONE => 
         raw_ack_all       <= '0'; 
         ena_wait_count    <= '0'; 
         rst_wait_count    <= '0';
      
      end case;
    end process output_fsm;       
         
           
           
           
           
------------------------------------
req_counter : process(clk_i, rst_i)
------------------------------------
   begin
         
      if (rst_i = '1') then
         wait_count <= 0 ;
         
      elsif (clk_i'EVENT AND clk_i = '1') then
         
         if (rst_wait_count = '1') then
            wait_count <= 0;
         elsif (ena_wait_count = '1') then 
            wait_count <= wait_count + 1;       
         else 
            wait_count <= wait_count;
         end if;
      end if;

   end process req_counter;
           
           
end behav;