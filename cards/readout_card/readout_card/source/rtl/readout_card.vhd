-- Copyright (c) 2003 SCUBA-2 Project
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
--
-- readout_card.vhd
--
-- Project:	      SCUBA-2
-- Author:        David Atkinson
-- Organisation:  ATC
--
-- Description:
-- Readout Card top-level file
--
-- Revision history:
-- 
-- $Log: readout_card.vhd,v $
--
-- 
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;

library work;
use work.dispatch_pack.all;
use work.wbs_frame_data_pack.all;


entity readout_card is
port(
     inclk      : in std_logic;
     rst        : in std_logic;
     
     -- LVDS interface:
     lvds_cmd   : in std_logic;
     lvds_sync  : in std_logic;
     lvds_spare : in std_logic;
     lvds_txa   : out std_logic;
     lvds_txb   : out std_logic;
     
      -- miscellaneous ports:
     dip_sw3    : in std_logic;
     dip_sw4    : in std_logic;
     wdog       : out std_logic;
     slot_id    : in std_logic_vector(3 downto 0)
     );
end readout_card;

architecture top of readout_card is

-- clocks
signal clk      : std_logic;
signal mem_clk  : std_logic;
signal comm_clk : std_logic;

-- wishbone bus (from master)
signal data : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
signal addr : std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
signal tga  : std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
signal we   : std_logic;
signal stb  : std_logic;
signal cyc  : std_logic;

-- wishbone bus (from slaves)
signal slave_data            : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
signal slave_ack             : std_logic;
signal wbs_frame_data_data   : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
signal wbs_frame_data_ack    : std_logic;

-- wbs_frame_data / flux_loop_ctrl interface signals
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


component pll
port(inclk0 : in std_logic;
     c0 : out std_logic;
     c1 : out std_logic;
     c2 : out std_logic);
end component;

begin
   pll0: pll
   port map(inclk0 => inclk,
            c0 => clk,
            c1 => mem_clk,
            c2 => comm_clk);
            
   cmd0: dispatch
   generic map(CARD => ADDRESS_CARD)
   port map(clk_i      => clk,
            mem_clk_i  => mem_clk,
            comm_clk_i => comm_clk,
            rst_i      => rst,
        
            lvds_cmd_i   => lvds_cmd,
            lvds_reply_o => lvds_txa,
     
            dat_o  => data,
            addr_o => addr,
            tga_o  => tga,
            we_o   => we,
            stb_o  => stb,
            cyc_o  => cyc,
            dat_i  => slave_data,
            ack_i  => slave_ack,
     
            wdt_rst_o => wdog);
            
   wbs_frame_data0: wbs_frame_data
port map (
   
     -- global inputs 
     rst_i                     =>  rst, 
     clk_i                     =>  clk,

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
     raw_ack_ch4_i             =>   raw_ack_ch4 ,                                 
     
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
  
     dat_i                     =>  data,
     addr_i                    =>  addr,
     tga_i                     =>  tga,
     we_i                      =>  we,
     stb_i                     =>  stb,
     cyc_i                     =>  cyc,
                  
     dat_o 	                   =>  wbs_frame_data_data,
     ack_o                     =>  wbs_frame_data_ack
     );   
      
   slave_data <= wbs_frame_data_data;
   slave_ack  <= wbs_frame_data_ack;
   
end top;