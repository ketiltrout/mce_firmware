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
-- 
-- This block is a wishbone slave.  It responds to 3 commands:
-- ------------------------
--  wbs_frame_data commands:
-- ------------------------
-- ret_dat   :    ParId="0x30" 
-- data_mode :    ParId="0x31" 
-- captr_raw :    ParId="0x1F" 
--
-- It's main function is to collect data from the flux loop control blocks
-- to be read by the wishbone master (dispatch)
--
-- There are 4 data mode formats:
--
-- data mode 1: Filtered Feedback data
-- data mode 2: Unfiltered Feedback data
-- data mode 3: combined 16-bit/16-bit error and feedback data
-- data mode 4: Raw sampled data.
--
--
-- Revision history:
-- <date $Date: 2004/10/15 16:11:04 $> - <text> - <initials $Author: dca $>
--
-- $Log: wbs_frame_data.vhd,v $
-- Revision 1.4  2004/10/15 16:11:04  dca
-- minor changes
--
-- Revision 1.3  2004/10/15 14:56:44  dca
-- start on wishbone controller
--
-- Revision 1.2  2004/10/13 14:14:55  dca
-- more signals added to entity declaration
--
-- Revision 1.1  2004/10/13 13:53:19  dca
-- Initial Version
--
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
use work.wbs_frame_data_pack.all;



entity wbs_frame_data is



port(
     -- global inputs 
     rst_i                  : in  std_logic;                                          -- global reset
     clk_i                  : in  std_logic;                                          -- global clock

     -- signals to/from flux_loop_ctrl    
     filtered_addr_ch1_o       : out std_logic_vector (FLC_ADDR_WIDTH-1    downto 0);  -- filtered data address - channel 1
     filtered_dat_ch1_i        : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- filtered data - channel 1
     fsfb_addr_ch1_o           : out std_logic_vector (FLC_ADDR_WIDTH-1    downto 0);  -- feedback data address - channel 1   
     fsfb_dat_ch1_i            : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- feedback data - channel 1
     coadded_addr_ch1_0        : out std_logic_vector (FLC_ADDR_WIDTH-1    downto 0);  -- co-added data address - channel 1
     coadded_dat_ch1_i         : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- co_added data - channel 1
     raw_addr_ch1_o            : out std_logic_vector (RAW_ADDR_WIDTH-1    downto 0);  -- raw data address - channel 1
     raw_dat_ch1_i             : in  std_logic_vector (RAW_DATA_WIDTH-1    downto 0);  -- raw data - channel 1
     raw_req_ch1_o             : out std_logic;                                        -- raw data request - channel 1
     raw_ack_ch1_i             : in  std_logic;                                        -- raw data acknowledgement - channel 1
      
     filtered_addr_ch2_o       : out std_logic_vector (FLC_ADDR_WIDTH-1    downto 0);  -- filtered data address - channel 2
     filtered_dat_ch2_i        : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- filtered data - channel 2
     fsfb_addr_ch2_o           : out std_logic_vector (FLC_ADDR_WIDTH-1    downto 0);  -- feedback data address - channel 2   
     fsfb_dat_ch2_i            : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- feedback data - channel 2
     coadded_addr_ch2_0        : out std_logic_vector (FLC_ADDR_WIDTH-1    downto 0);  -- co-added data address - channel 2
     coadded_dat_ch2_i         : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- co_added data - channel 2
     raw_addr_ch2_o            : out std_logic_vector (RAW_ADDR_WIDTH-1    downto 0);  -- raw data address - channel 2
     raw_dat_ch2_i             : in  std_logic_vector (RAW_DATA_WIDTH-1    downto 0);  -- raw data - channel 2
     raw_req_ch2_o             : out std_logic;                                        -- raw data request - channel 2
     raw_ack_ch2_i             : in  std_logic;                                        -- raw data acknowledgement - channel 2
   
     filtered_addr_ch3_o       : out std_logic_vector (FLC_ADDR_WIDTH-1    downto 0);  -- filtered data address - channel 3
     filtered_dat_ch3_i        : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- filtered data - channel 3
     fsfb_addr_ch3_o           : out std_logic_vector (FLC_ADDR_WIDTH-1    downto 0);  -- feedback data address - channel 3   
     fsfb_dat_ch3_i            : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- feedback data - channel 3
     coadded_addr_ch3_0        : out std_logic_vector (FLC_ADDR_WIDTH-1    downto 0);  -- co-added data address - channel 3
     coadded_dat_ch3_i         : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- co_added data - channel 3
     raw_addr_ch3_o            : out std_logic_vector (RAW_ADDR_WIDTH-1    downto 0);  -- raw data address - channel 3
     raw_dat_ch3_i             : in  std_logic_vector (RAW_DATA_WIDTH-1    downto 0);  -- raw data - channel 3
     raw_req_ch3_o             : out std_logic;                                        -- raw data request - channel 3
     raw_ack_ch3_i             : in  std_logic;                                        -- raw data acknowledgement - channel 3
   
     filtered_addr_ch4_o       : out std_logic_vector (FLC_ADDR_WIDTH-1    downto 0);  -- filtered data address - channel 4
     filtered_dat_ch4_i        : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- filtered data - channel 4
     fsfb_addr_ch4_o           : out std_logic_vector (FLC_ADDR_WIDTH-1    downto 0);  -- feedback data address - channel 4   
     fsfb_dat_ch4_i            : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- feedback data - channel 4
     coadded_addr_ch4_0        : out std_logic_vector (FLC_ADDR_WIDTH-1    downto 0);  -- co-added data address - channel 4
     coadded_dat_ch4_i         : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- co_added data - channel 4
     raw_addr_ch4_o            : out std_logic_vector (RAW_ADDR_WIDTH-1    downto 0);  -- raw data address - channel 4
     raw_dat_ch4_i             : in  std_logic_vector (RAW_DATA_WIDTH-1    downto 0);   -- raw data - channel 4
     raw_req_ch4_o             : out std_logic;                                        -- raw data request - channel 4
     raw_ack_ch4_i             : in  std_logic;                                        -- raw data acknowledgement - channel 4

     filtered_addr_ch5_o       : out std_logic_vector (FLC_ADDR_WIDTH-1    downto 0);  -- filtered data address - channel 5
     filtered_dat_ch5_i        : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- filtered data - channel 5
     fsfb_addr_ch5_o           : out std_logic_vector (FLC_ADDR_WIDTH-1    downto 0);  -- feedback data address - channel 5   
     fsfb_dat_ch5_i            : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- feedback data - channel 5
     coadded_addr_ch5_0        : out std_logic_vector (FLC_ADDR_WIDTH-1    downto 0);  -- co-added data address - channel 5
     coadded_dat_ch5_i         : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- co_added data - channel 5
     raw_addr_ch5_o            : out std_logic_vector (RAW_ADDR_WIDTH-1    downto 0);  -- raw data address - channel 5
     raw_dat_ch5_i             : in  std_logic_vector (RAW_DATA_WIDTH-1    downto 0);  -- raw data - channel 5
     raw_req_ch5_o             : out std_logic;                                        -- raw data request - channel 5
     raw_ack_ch5_i             : in  std_logic;                                        -- raw data acknowledgement - channel 5
   
     filtered_addr_ch6_o       : out std_logic_vector (FLC_ADDR_WIDTH-1    downto 0);  -- filtered data address - channel 6
     filtered_dat_ch6_i        : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- filtered data - channel 6
     fsfb_addr_ch6_o           : out std_logic_vector (FLC_ADDR_WIDTH-1    downto 0);  -- feedback data address - channel 6   
     fsfb_dat_ch6_i            : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- feedback data - channel 6
     coadded_addr_ch6_0        : out std_logic_vector (FLC_ADDR_WIDTH-1    downto 0);  -- co-added data address - channel 6
     coadded_dat_ch6_i         : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- co_added data - channel 6
     raw_addr_ch6_o            : out std_logic_vector (RAW_ADDR_WIDTH-1    downto 0);  -- raw data address - channel 6
     raw_dat_ch6_i             : in  std_logic_vector (RAW_DATA_WIDTH-1    downto 0);  -- raw data - channel 6
     raw_req_ch6_o             : out std_logic;                                        -- raw data request - channel 6
     raw_ack_ch6_i             : in  std_logic;                                        -- raw data acknowledgement - channel 6
   
     filtered_addr_ch7_o       : out std_logic_vector (FLC_ADDR_WIDTH-1    downto 0);  -- filtered data address - channel 7
     filtered_dat_ch7_i        : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- filtered data - channel 7
     fsfb_addr_ch7_o           : out std_logic_vector (FLC_ADDR_WIDTH-1    downto 0);  -- feedback data address - channel 7   
     fsfb_dat_ch7_i            : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- feedback data - channel 7
     coadded_addr_ch7_0        : out std_logic_vector (FLC_ADDR_WIDTH-1    downto 0);  -- co-added data address - channel 7
     coadded_dat_ch7_i         : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- co_added data - channel 7
     raw_addr_ch7_o            : out std_logic_vector (RAW_ADDR_WIDTH-1    downto 0);  -- raw data address - channel 7
     raw_dat_ch7_i             : in  std_logic_vector (RAW_DATA_WIDTH-1    downto 0);  -- raw data - channel 7
     raw_req_ch7_o             : out std_logic;                                        -- raw data request - channel 7
     raw_ack_ch7_i             : in  std_logic;                                        -- raw data acknowledgement - channel 7
   
     filtered_addr_ch8_o       : out std_logic_vector (FLC_ADDR_WIDTH-1    downto 0);  -- filtered data address - channel 8
     filtered_dat_ch8_i        : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- filtered data - channel 8
     fsfb_addr_ch8_o           : out std_logic_vector (FLC_ADDR_WIDTH-1    downto 0);  -- feedback data address - channel 8   
     fsfb_dat_ch8_i            : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- feedback data - channel 8
     coadded_addr_ch8_0        : out std_logic_vector (FLC_ADDR_WIDTH-1    downto 0);  -- co-added data address - channel 8
     coadded_dat_ch8_i         : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- co_added data - channel 8
     raw_addr_ch8_o            : out std_logic_vector (RAW_ADDR_WIDTH-1    downto 0);  -- raw data address - channel 8
     raw_dat_ch8_i             : in  std_logic_vector (RAW_DATA_WIDTH-1    downto 0);  -- raw data - channel 8
     raw_req_ch8_o             : out std_logic;                                        -- raw data request - channel 8
     raw_ack_ch8_i             : in  std_logic;                                        -- raw data acknowledgement - channel 8
   
    
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
end wbs_frame_data;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;


architecture rtl of wbs_frame_data is

constant RAW_ADDR_WIDTH   :  integer := 13; 
constant RAW_WORD_WIDTH   :  integer := 16;    
constant DATA_ADDR_WIDTH  :  integer := 6; 

signal write_data_mode     : std_logic;                        
signal read_ret_data       : std_logic;
signal write_captr_raw     : std_logic;

signal data_mode_reg       : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
signal data_mode           : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
signal data_mode_mux_sel   : std_logic ;

signal captr_raw_reg       : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
signal captr_raw           : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
signal captr_raw_mux_sel   : std_logic ;

signal wbs_data            : std_logic_vector(WB_DATA_WIDTH-1 downto 0);

signal dat_col1            : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
signal dat_col2            : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
signal dat_col3            : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
signal dat_col4            : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
signal dat_col5            : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
signal dat_col6            : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
signal dat_col7            : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
signal dat_col8            : std_logic_vector(WB_DATA_WIDTH-1 downto 0);


-- slave controller FSM

type state is (IDLE, SET_MODE, GET_DAT, SET_RAW, DONE);                           

signal current_state: state;
signal next_state:    state;

type   data_type is (FILTERED, UNFILTERED, COADD_FB, RAW);     
signal data_format: data_type;


signal col_mux_sel         : std_logic_vector (COL_MUX_SEL_WIDTH-1 downto 0);       -- select col 1 --> 8
signal mode_mux_sel        : std_logic_vector (1 downto 0);       -- select mode 1 --> 4 

signal inc_addr_sel        : std_logic;

signal pixel_address       : std_logic_vector (PIXEL_ADDR_WIDTH-1 downto 0);
signal pixel_count         : integer;

signal row_address         : std_logic_vector (FLC_ADDR_WIDTH-1 downto 0);

signal data_out_mux_sel    : std_logic_vector (1 downto 0);

begin


-------------------------------------------------------------------------------------------------
--                       Wishbone interface  -  identify 3 commands 
------------------------------------------------------------------------------------------------

   write_data_mode <= '1' when (addr_i = DATA_MODE_ADDR and stb_i = '1' and cyc_i = '1' and we_i = '1')
                   else '0';
    
   read_ret_data   <= '1' when (addr_i = RET_DAT_ADDR and stb_i = '1' and cyc_i = '1' and we_i = '0')
                   else '0';

   write_captr_raw <= '1' when (addr_i = CAPTR_RAW_ADDR and stb_i = '1' and cyc_i = '1' and we_i = '1')
                   else '0';
   
   
-------------------------------------------------------------------------------------------------
--                                  Wishbone slave controller FSM
------------------------------------------------------------------------------------------------
   
   ----------------------------------
   clock_fsm : process(clk_i, rst_i )
   ----------------------------------
   begin
         
      if (rst_i = '1') then
         current_state <= IDLE;
      elsif (clk_i'EVENT AND clk_i = '1') then
         current_state <= next_state;
      end if;

   end process clock_fsm;
   
   --------------------------------------------------------------------------------------
   nextstate_fsm: process (current_state, write_data_mode, read_ret_data, write_captr_raw)
   ---------------------------------------------------------------------------------------
   begin
      case current_state is
      
      when IDLE =>
         if write_data_mode = '1' then 
            next_state <= SET_MODE;
         
         elsif read_ret_data = '1' then
            next_state <= GET_DAT;
         
         elsif write_captr_raw = '1' then
            next_state <= SET_RAW;
             
         else
            next_state <= IDLE;
        
         end if;
              
      when SET_MODE | GET_DAT | SET_RAW =>
         next_state <= DONE;
      
      when DONE =>
         next_state <= IDLE;
      end case;
    end process nextstate_fsm;
    
   --------------------------------------------- 
   output_fsm: process (current_state, wbs_data)
   ---------------------------------------------
   begin
      case current_state is
      
      when IDLE =>
      
         ack_o             <= '0';
         dat_o             <= (others => '0');
         data_mode_mux_sel <= '0';
         captr_raw_mux_sel <= '0';
         inc_addr_sel      <= '0';    
             
      when SET_MODE =>
         ack_o             <= '1';
         dat_o             <= (others => '0');
         data_mode_mux_sel <= '1';
         captr_raw_mux_sel <= '0';
         inc_addr_sel      <= '0';
         
      when GET_DAT =>
         ack_o             <= '1';
         dat_o             <= wbs_data;
         data_mode_mux_sel <= '0';
         captr_raw_mux_sel <= '0';
         inc_addr_sel      <= '0';
         
      when SET_RAW =>
         ack_o             <= '1';
         dat_o             <= (others => '0');
         data_mode_mux_sel <= '0';
         captr_raw_mux_sel <= '1';
         inc_addr_sel      <= '0';
         
      when DONE =>
         ack_o             <= '0';
         dat_o             <= (others => '0');
         data_mode_mux_sel <= '0';
         captr_raw_mux_sel <= '0';
         inc_addr_sel      <= '1';
         
      end case;
    end process output_fsm;       
         
         
-------------------------------------------------------------------------------------------------------------         
    
   ------------------------------------- 
   address_counter: process (clk_i, rst_i) 
   -------------------------------------      
    begin
         
      if (rst_i = '1') then
         pixel_count <= 0 ;
      elsif (clk_i'EVENT AND clk_i = '1') then
         
         if inc_addr_sel = '1' then
            
            if pixel_count = PIXEL_ADDR_MAX-1 then 
               pixel_count <= 0;     
            else 
               pixel_count <= pixel_count + 1;
            end if;
            
         end if;
      end if;
   end process address_counter;
   
   pixel_address <= std_logic_vector(to_unsigned(pixel_count,PIXEL_ADDR_WIDTH));
   
   row_address   <= pixel_address(PIXEL_ADDR_WIDTH-1 downto COL_MUX_SEL_WIDTH);
   col_mux_sel   <= pixel_address(COL_MUX_SEL_WIDTH-1 downto 0);      
   
  
         
              
-------------------------------------------------------------------------------------------------
--                                  Column MUX
------------------------------------------------------------------------------------------------
         
         
   wbs_data  <= dat_col1 when col_mux_sel = "000" else
                dat_col2 when col_mux_sel = "001" else
                dat_col3 when col_mux_sel = "010" else
                dat_col4 when col_mux_sel = "011" else
                dat_col5 when col_mux_sel = "100" else
                dat_col6 when col_mux_sel = "101" else
                dat_col7 when col_mux_sel = "110" else
                dat_col8 when col_mux_sel = "111";
             


---------------------------------------------------------------------------------------------
--                  Data Select Output MUX
---------------------------------------------------------------------------------------------
  
  
  
   data_format <= FILTERED   when data_mode_reg = DATA_MODE1 else
                  UNFILTERED when data_mode_reg = DATA_MODE2 else
                  COADD_FB   when data_mode_reg = DATA_MODE3 else
                  RAW        when data_mode_reg = DATA_MODE4;
                  
 
  data_type_select : process (data_format,
                               filtered_dat_ch1_i, fsfb_dat_ch1_i, coadded_dat_ch1_i, raw_dat_ch1_i,
                               filtered_dat_ch2_i, fsfb_dat_ch2_i, coadded_dat_ch2_i, raw_dat_ch2_i,
                               filtered_dat_ch3_i, fsfb_dat_ch3_i, coadded_dat_ch3_i, raw_dat_ch3_i,
                               filtered_dat_ch4_i, fsfb_dat_ch4_i, coadded_dat_ch4_i, raw_dat_ch4_i,
                               filtered_dat_ch5_i, fsfb_dat_ch5_i, coadded_dat_ch5_i, raw_dat_ch5_i,
                               filtered_dat_ch6_i, fsfb_dat_ch6_i, coadded_dat_ch6_i, raw_dat_ch6_i,
                               filtered_dat_ch7_i, fsfb_dat_ch7_i, coadded_dat_ch7_i, raw_dat_ch7_i,
                               filtered_dat_ch8_i, fsfb_dat_ch8_i, coadded_dat_ch8_i, raw_dat_ch8_i
                               )
  
   begin
   
      case data_format is 
        
      when FILTERED =>
      
         dat_col1 <= filtered_dat_ch1_i ; 
         dat_col2 <= filtered_dat_ch2_i ; 
         dat_col3 <= filtered_dat_ch3_i ; 
         dat_col4 <= filtered_dat_ch4_i ; 
         dat_col5 <= filtered_dat_ch5_i ; 
         dat_col6 <= filtered_dat_ch6_i ; 
         dat_col7 <= filtered_dat_ch7_i ; 
         dat_col8 <= filtered_dat_ch8_i ; 
                  
      when UNFILTERED =>
      
         dat_col1 <= fsfb_dat_ch1_i ;
         dat_col2 <= fsfb_dat_ch2_i ; 
         dat_col3 <= fsfb_dat_ch3_i ; 
         dat_col4 <= fsfb_dat_ch4_i ; 
         dat_col5 <= fsfb_dat_ch5_i ; 
         dat_col6 <= fsfb_dat_ch6_i ; 
         dat_col7 <= fsfb_dat_ch7_i ; 
         dat_col8 <= fsfb_dat_ch8_i ; 
      
      when COADD_FB =>
      
         dat_col1 <= fsfb_dat_ch1_i (31 downto 16) & coadded_dat_ch1_i(31 downto 16);
         dat_col2 <= fsfb_dat_ch2_i (31 downto 16) & coadded_dat_ch2_i(31 downto 16); 
         dat_col3 <= fsfb_dat_ch3_i (31 downto 16) & coadded_dat_ch3_i(31 downto 16);
         dat_col4 <= fsfb_dat_ch4_i (31 downto 16) & coadded_dat_ch4_i(31 downto 16);
         dat_col5 <= fsfb_dat_ch5_i (31 downto 16) & coadded_dat_ch5_i(31 downto 16);
         dat_col6 <= fsfb_dat_ch6_i (31 downto 16) & coadded_dat_ch6_i(31 downto 16);
         dat_col7 <= fsfb_dat_ch7_i (31 downto 16) & coadded_dat_ch7_i(31 downto 16);
         dat_col8 <= fsfb_dat_ch8_i (31 downto 16) & coadded_dat_ch8_i(31 downto 16);
      
      when RAW =>
      
         dat_col1 (31 downto 16) <= (others => '0');
         dat_col2 (31 downto 16) <= (others => '0');
         dat_col3 (31 downto 16) <= (others => '0');
         dat_col4 (31 downto 16) <= (others => '0');
         dat_col5 (31 downto 16) <= (others => '0');
         dat_col6 (31 downto 16) <= (others => '0');
         dat_col7 (31 downto 16) <= (others => '0');
         dat_col8 (31 downto 16) <= (others => '0');
         
         dat_col1 (15 downto 0)  <= raw_dat_ch1_i;
         dat_col2 (15 downto 0)  <= raw_dat_ch2_i;
         dat_col3 (15 downto 0)  <= raw_dat_ch3_i;
         dat_col4 (15 downto 0)  <= raw_dat_ch4_i;
         dat_col5 (15 downto 0)  <= raw_dat_ch5_i;
         dat_col6 (15 downto 0)  <= raw_dat_ch6_i;
         dat_col7 (15 downto 0)  <= raw_dat_ch7_i;
         dat_col8 (15 downto 0)  <= raw_dat_ch8_i;    
       
      end case;    
      
   end process data_type_select;
                
-------------------------------------------------------------------------------------------------
--                                  Data Mode Recirculation MUX
------------------------------------------------------------------------------------------------

  data_mode  <= data_mode_reg when data_mode_mux_sel = '0' else dat_i;
   
  dff_data_mode: process(clk_i, rst_i)
  begin
     if (rst_i = '1') then 
        data_mode_reg <= (others => '0');
     elsif (clk_i'EVENT and clk_i = '1') then
        data_mode_reg <= data_mode;
     end if;
  end process dff_data_mode;
          
-------------------------------------------------------------------------------------------------
--                                  Capture Raw Recirculation MUX
------------------------------------------------------------------------------------------------

  captr_raw  <= captr_raw_reg when captr_raw_mux_sel = '0' else dat_i;
   
  dff_captr_raw: process(clk_i, rst_i)
  begin
     if (rst_i = '1') then 
        captr_raw_reg <= (others => '0');
     elsif (clk_i'EVENT and clk_i = '1') then
        captr_raw_reg <= captr_raw;
     end if;
  end process dff_captr_raw;
------------------------------------------------------------------------------------------------           

           
end rtl;