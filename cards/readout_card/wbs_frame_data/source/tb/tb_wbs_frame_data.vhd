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
-- Project: 			Scuba 2
-- Author:  			David Atkinson
-- Organisation: 			UKATC
--
-- Description:
-- 
-- test bed for wbs_frame_data.vhd
--
-- Revision history:
-- <date $Date: 2004/10/26 16:14:12 $> - <text> - <initials $Author: dca $>
--
-- $Log: tb_wbs_frame_data.vhd,v $
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


architecture bench of tb_wbs_frame_data is

signal dut_rst        : std_logic;
signal dut_clk        : std_logic := '1';
constant clk_prd      : TIME := 20 ns;    -- 50Mhz clock

signal flc_buff_rst   : std_logic;   -- initialise FLUX loop contorl buffers...

signal param_id       :  std_logic_vector (WB_ADDR_WIDTH-1 downto 0);
   

signal filtered_addr_ch0     : std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  
signal filtered_dat_ch0      : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  
signal fsfb_addr_ch0         : std_logic_vector (ROW_ADDR_WIDTH-1    downto 0); 
signal fsfb_dat_ch0          : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0); 
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


begin

-------------------------------------------------
-- Instantiate DUT
-------------------------------------------------

   i_wbs_frame_data :  wbs_frame_data
   
   port map (
   
     -- global inputs 
     rst_i                     =>  dut_rst, 
     clk_i                     =>  dut_clk,

     -- signals to/from flux_loop_ctrl    

     filtered_addr_ch0_o       =>  filtered_addr_ch0,
     filtered_dat_ch0_i        =>  filtered_dat_ch0, 
     fsfb_addr_ch0_o           =>  fsfb_addr_ch0,
     fsfb_dat_ch0_i            =>  fsfb_dat_ch0,
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
                  
     dat_o 	                   =>  wbm_dat_i,
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
          
         assert false report " DATA MODE SET......" severity NOTE;
         wait for clk_prd;
           
      end do_set_data_mode;
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
   procedure do_read_data is
   -----------------------------
      begin

         wbm_addr_o <= RET_DAT_ADDR;
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
         
                
    --     assert false report " Got data Word ..........." severity NOTE;
         wait for clk_prd;
         
      
      end do_read_data;
   --------------------------
        
--------------------------------------------------

   begin
   
   do_reset;
   
   do_init_flc_buffers;
   
   
   -- Capture Raw Data - FLC instruction         
   do_req_raw_data;
   
   
   
   -- Get MODE 3 coadd/error data
   ------------------------------
   wbm_dat_o <= MODE3_FB_ERROR;
   do_set_data_mode;
   
   for i in 1 to (41*8) loop
      do_read_data;
   end loop;
   
     assert (wbm_dat_reg = x"17282728" ) report "***LAST DATA WORD INCORRECT....***" severity ERROR;
     assert (conv_integer(fsfb_addr_ch7) = 0) report "***ADDRESS NOT BACK TO ZERO***" severity ERROR;
     assert (conv_integer(coadded_addr_ch7) = 0) report "***ADDRESS NOT BACK TO ZERO***" severity ERROR;
   
   assert false report "A Frame of FEEDBACK/ERROR data has been read....." severity NOTE;
   
   
   
   -- Get MODE 2 unfilterd data
   ------------------------------
   wbm_dat_o <= MODE2_UNFILTERED;
   do_set_data_mode;
   
   for i in 1 to (41*8) loop
      do_read_data;
   end loop;
   
   assert false report "A Frame of UNFILTEREDdata has been read....." severity NOTE;
   
   wait for clk_prd;
   
     assert (wbm_dat_reg = x"1728FFFF" ) report "***LAST DATA WORD INCORRECT....***" severity ERROR;
     assert (conv_integer(fsfb_addr_ch7) = 0) report "***ADDRESS NOT BACK TO ZERO***" severity ERROR;
   
  
   
  
   -- Get MODE 1 Filtered data
   ------------------------------
   wbm_dat_o <= MODE1_FILTERED;
   do_set_data_mode;
   
   for i in 1 to (41*8) loop
      do_read_data;
   end loop;
      
   assert false report "A Frame of FILTERED data has been read....." severity NOTE;
   
     assert (wbm_dat_reg = x"0728FFFF" ) report "***LAST DATA WORD INCORRECT....***" severity ERROR;
     assert (conv_integer(filtered_addr_ch7) = 0) report "***ADDRESS NOT BACK TO ZERO***" severity ERROR;
   
   
   


 
   -- Get MODE 4 raw data
   ------------------------------
   wbm_dat_o <= MODE4_RAW;
   do_set_data_mode;
   
   for i in 1 to (2*64*41*8) loop
      do_read_data;
   end loop;
   
      
   assert (wbm_dat_reg = x"00003751" ) report "***LAST DATA WORD INCORRECT....***" severity ERROR;
   assert (conv_integer(raw_addr_ch7) = 0) report "***ADDRESS NOT BACK TO ZERO***" severity ERROR;
   
      
   assert false report "A Frame of RAW data has been read....." severity NOTE;




   wait for clk_prd*20;
   
   assert false report "END OF SIMULATION....." severity FAILURE;
   
   wait;
   
   end process stimuli;   
           
end bench;