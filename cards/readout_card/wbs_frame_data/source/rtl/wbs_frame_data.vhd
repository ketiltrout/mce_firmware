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
-- <date $Date: 2004/10/18 16:35:47 $> - <text> - <initials $Author: dca $>
--
-- $Log: wbs_frame_data.vhd,v $
-- Revision 1.5  2004/10/18 16:35:47  dca
-- continued progress
--
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
     filtered_addr_ch1_o       : out std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- filtered data address - channel 1
     filtered_dat_ch1_i        : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- filtered data - channel 1
     fsfb_addr_ch1_o           : out std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- feedback data address - channel 1   
     fsfb_dat_ch1_i            : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- feedback data - channel 1
     coadded_addr_ch1_0        : out std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- co-added data address - channel 1
     coadded_dat_ch1_i         : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- co_added data - channel 1
     raw_addr_ch1_o            : out std_logic_vector (RAW_ADDR_WIDTH-1    downto 0);  -- raw data address - channel 1
     raw_dat_ch1_i             : in  std_logic_vector (RAW_DATA_WIDTH-1    downto 0);  -- raw data - channel 1
     raw_req_ch1_o             : out std_logic;                                        -- raw data request - channel 1
     raw_ack_ch1_i             : in  std_logic;                                        -- raw data acknowledgement - channel 1
      
     filtered_addr_ch2_o       : out std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- filtered data address - channel 2
     filtered_dat_ch2_i        : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- filtered data - channel 2
     fsfb_addr_ch2_o           : out std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- feedback data address - channel 2   
     fsfb_dat_ch2_i            : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- feedback data - channel 2
     coadded_addr_ch2_0        : out std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- co-added data address - channel 2
     coadded_dat_ch2_i         : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- co_added data - channel 2
     raw_addr_ch2_o            : out std_logic_vector (RAW_ADDR_WIDTH-1    downto 0);  -- raw data address - channel 2
     raw_dat_ch2_i             : in  std_logic_vector (RAW_DATA_WIDTH-1    downto 0);  -- raw data - channel 2
     raw_req_ch2_o             : out std_logic;                                        -- raw data request - channel 2
     raw_ack_ch2_i             : in  std_logic;                                        -- raw data acknowledgement - channel 2
   
     filtered_addr_ch3_o       : out std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- filtered data address - channel 3
     filtered_dat_ch3_i        : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- filtered data - channel 3
     fsfb_addr_ch3_o           : out std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- feedback data address - channel 3   
     fsfb_dat_ch3_i            : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- feedback data - channel 3
     coadded_addr_ch3_0        : out std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- co-added data address - channel 3
     coadded_dat_ch3_i         : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- co_added data - channel 3
     raw_addr_ch3_o            : out std_logic_vector (RAW_ADDR_WIDTH-1    downto 0);  -- raw data address - channel 3
     raw_dat_ch3_i             : in  std_logic_vector (RAW_DATA_WIDTH-1    downto 0);  -- raw data - channel 3
     raw_req_ch3_o             : out std_logic;                                        -- raw data request - channel 3
     raw_ack_ch3_i             : in  std_logic;                                        -- raw data acknowledgement - channel 3
   
     filtered_addr_ch4_o       : out std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- filtered data address - channel 4
     filtered_dat_ch4_i        : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- filtered data - channel 4
     fsfb_addr_ch4_o           : out std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- feedback data address - channel 4   
     fsfb_dat_ch4_i            : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- feedback data - channel 4
     coadded_addr_ch4_0        : out std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- co-added data address - channel 4
     coadded_dat_ch4_i         : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- co_added data - channel 4
     raw_addr_ch4_o            : out std_logic_vector (RAW_ADDR_WIDTH-1    downto 0);  -- raw data address - channel 4
     raw_dat_ch4_i             : in  std_logic_vector (RAW_DATA_WIDTH-1    downto 0);   -- raw data - channel 4
     raw_req_ch4_o             : out std_logic;                                        -- raw data request - channel 4
     raw_ack_ch4_i             : in  std_logic;                                        -- raw data acknowledgement - channel 4

     filtered_addr_ch5_o       : out std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- filtered data address - channel 5
     filtered_dat_ch5_i        : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- filtered data - channel 5
     fsfb_addr_ch5_o           : out std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- feedback data address - channel 5   
     fsfb_dat_ch5_i            : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- feedback data - channel 5
     coadded_addr_ch5_0        : out std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- co-added data address - channel 5
     coadded_dat_ch5_i         : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- co_added data - channel 5
     raw_addr_ch5_o            : out std_logic_vector (RAW_ADDR_WIDTH-1    downto 0);  -- raw data address - channel 5
     raw_dat_ch5_i             : in  std_logic_vector (RAW_DATA_WIDTH-1    downto 0);  -- raw data - channel 5
     raw_req_ch5_o             : out std_logic;                                        -- raw data request - channel 5
     raw_ack_ch5_i             : in  std_logic;                                        -- raw data acknowledgement - channel 5
   
     filtered_addr_ch6_o       : out std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- filtered data address - channel 6
     filtered_dat_ch6_i        : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- filtered data - channel 6
     fsfb_addr_ch6_o           : out std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- feedback data address - channel 6   
     fsfb_dat_ch6_i            : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- feedback data - channel 6
     coadded_addr_ch6_0        : out std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- co-added data address - channel 6
     coadded_dat_ch6_i         : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- co_added data - channel 6
     raw_addr_ch6_o            : out std_logic_vector (RAW_ADDR_WIDTH-1    downto 0);  -- raw data address - channel 6
     raw_dat_ch6_i             : in  std_logic_vector (RAW_DATA_WIDTH-1    downto 0);  -- raw data - channel 6
     raw_req_ch6_o             : out std_logic;                                        -- raw data request - channel 6
     raw_ack_ch6_i             : in  std_logic;                                        -- raw data acknowledgement - channel 6
   
     filtered_addr_ch7_o       : out std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- filtered data address - channel 7
     filtered_dat_ch7_i        : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- filtered data - channel 7
     fsfb_addr_ch7_o           : out std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- feedback data address - channel 7   
     fsfb_dat_ch7_i            : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- feedback data - channel 7
     coadded_addr_ch7_0        : out std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- co-added data address - channel 7
     coadded_dat_ch7_i         : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- co_added data - channel 7
     raw_addr_ch7_o            : out std_logic_vector (RAW_ADDR_WIDTH-1    downto 0);  -- raw data address - channel 7
     raw_dat_ch7_i             : in  std_logic_vector (RAW_DATA_WIDTH-1    downto 0);  -- raw data - channel 7
     raw_req_ch7_o             : out std_logic;                                        -- raw data request - channel 7
     raw_ack_ch7_i             : in  std_logic;                                        -- raw data acknowledgement - channel 7
   
     filtered_addr_ch8_o       : out std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- filtered data address - channel 8
     filtered_dat_ch8_i        : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- filtered data - channel 8
     fsfb_addr_ch8_o           : out std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- feedback data address - channel 8   
     fsfb_dat_ch8_i            : in  std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);  -- feedback data - channel 8
     coadded_addr_ch8_0        : out std_logic_vector (ROW_ADDR_WIDTH-1    downto 0);  -- co-added data address - channel 8
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

-- three wishbone read/write request enables
signal write_data_mode     : std_logic;                        
signal read_ret_data       : std_logic;
signal write_captr_raw     : std_logic;


-- signals for registering data mode word

signal data_mode_reg       : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
signal data_mode           : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
signal data_mode_mux_sel   : std_logic ;

-- signal for registering captr raw word

signal captr_raw_reg       : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
signal captr_raw           : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
signal captr_raw_mux_sel   : std_logic ;

-- data mapped to wishbone data output

signal wbs_data            : std_logic_vector(WB_DATA_WIDTH-1 downto 0);


-- four types of data read from flux_loop_cntr blocks

signal filtered_dat        : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
signal unfiltered_dat      : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
signal fb_error_dat        : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
signal raw_dat             : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);


-- signal used to map correct data type to output
signal dat_out_mux_sel     : std_logic_vector (1 downto 0);

-- enable this signal to increment address counters
signal inc_addr_sel        : std_logic;


-- address used for modes 1, 2 and 3
signal pixel_address       : std_logic_vector (PIXEL_ADDR_WIDTH-1 downto 0);       -- pixel address split for row and channel modes 1,2,3
signal pixel_addr_cnt      : integer;
signal ch_mux_sel          : std_logic_vector (CH_MUX_SEL_WIDTH-1 downto 0);       -- channel select ch 1 --> 8
signal row_address         : std_logic_vector (ROW_ADDR_WIDTH-1 downto 0);         -- row address


-- address used for mode 4

signal raw_address         : std_logic_vector (RAW_ADDR_WIDTH-1    downto 0);      -- raw 'row' address
signal raw_addr_cnt        : integer;
signal raw_ch_mux_sel      : std_logic_vector (CH_MUX_SEL_WIDTH-1  downto 0);       -- raw channel select
signal raw_ch_cnt          : integer;


signal raw_req             : std_logic;      -- MUXed raw data request line
signal raw_ack             : std_logic;      -- MUXed raw data acknowledge line

-- slave controller FSM

type state is (IDLE, SET_MODE, SET_RAW, GET_RAW, READ_DAT, DONE);                           

signal current_state: state;
signal next_state:    state;

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
   nextstate_fsm: process (current_state, data_mode_reg, raw_ack,
                           write_data_mode, read_ret_data, write_captr_raw)
   ---------------------------------------------------------------------------------------
   begin
      case current_state is
      
      when IDLE =>
         if write_data_mode = '1' then 
            next_state <= SET_MODE;
         
         elsif read_ret_data = '1' then
            
            if data_mode_reg = MODE4_RAW then 
               next_state <= GET_RAW;
            else 
               next_state <= READ_DAT;
            end if;
                   
         elsif write_captr_raw = '1' then
            next_state <= SET_RAW;
             
         else
            next_state <= IDLE;
        
         end if;
              
      when GET_RAW  => 
        if raw_ack = '1' then 
           next_state <= READ_DAT;
        else
           next_state <= GET_RAW ;
        end if; 
      
                    
      when SET_MODE | SET_RAW | READ_DAT =>
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
         raw_req           <= '0';
             
      when SET_MODE =>
         ack_o             <= '1';
         dat_o             <= (others => '0');
         data_mode_mux_sel <= '1';
         captr_raw_mux_sel <= '0';
         inc_addr_sel      <= '0';
         raw_req           <= '0';

      when READ_DAT =>
         ack_o             <= '1';
         dat_o             <= wbs_data;
         data_mode_mux_sel <= '0';
         captr_raw_mux_sel <= '0';
         inc_addr_sel      <= '0';
         raw_req           <= '0';
         
       when GET_RAW => 
         ack_o             <= '0';
         dat_o             <= (others => '0');
         data_mode_mux_sel <= '0';
         captr_raw_mux_sel <= '0';
         inc_addr_sel      <= '0';
         raw_req           <= '1';
       
         
      when SET_RAW =>
         ack_o             <= '1';
         dat_o             <= (others => '0');
         data_mode_mux_sel <= '0';
         captr_raw_mux_sel <= '1';
         inc_addr_sel      <= '0';
         raw_req           <= '0';
         
      when DONE =>
         ack_o             <= '0';
         dat_o             <= (others => '0');
         data_mode_mux_sel <= '0';
         captr_raw_mux_sel <= '0';
         inc_addr_sel      <= '1';
         raw_req           <= '0';
         
      end case;
    end process output_fsm;       
         
         
-------------------------------------------------------------------------------------------------------------         
    
-- for modes 1,2,3 pixel_addr_cnt is used.  Bits 2..0 determine the channel, and bits 8..3 determine the row.
-- the address cycles through:
--
--         (row_0 ch_1), (row_0 ch_2), (row_0 ch_3), (row_0 ch_4), (row_0 ch_5), (row_0 ch_6), (row_0 ch_7), (row_0 ch_8),
--         (row_1 ch_1), (row_1 ch_2), (row_1 ch_3), (row_1 ch_4), (row_1 ch_5), (row_1 ch_6), (row_1 ch_7), (row_1 ch_8),    
--                        --               
--                        --
--         (row_40 ch_1), (row_40 ch_2), (row_40 ch_3), (row_40 ch_4), (row_40 ch_5), (row_40 ch_6), (row_40 ch_7), (row_40 ch_8), 

-- for mode 4  there are  5248 'rows' per channel.  When reading out in this mode an entire channel is readout before moving to the 
-- next channel....
-- consequently the row and channel addresses are split   
-- 
-- readout ch_1: row 0 --> row 5247
--         ch_2: row 0 --> row 5247
--                 --
--                 --
--         ch_8: row 0 --> row 5247

  
    
   ------------------------------------- 
   address_counter: process (clk_i, rst_i) 
   -------------------------------------      
    begin
         
      if (rst_i = '1') then
         pixel_addr_cnt <= 0 ;
         raw_addr_cnt   <= 0 ;
      elsif (clk_i'EVENT AND clk_i = '1') then
         
         if inc_addr_sel = '1' then
         
            if data_mode_reg = MODE4_RAW then 
             
               if raw_addr_cnt = RAW_ADDR_MAX-1 then 
               
                  raw_addr_cnt   <= 0;
                  
                  if raw_ch_cnt = NO_CHANNELS-1 then
                     raw_ch_cnt <= 0;
                  else 
                     raw_ch_cnt <= raw_ch_cnt+1;
                  end if;
                       
               else 
                  raw_addr_cnt <= raw_addr_cnt + 1;
               end if;
            
            else 
                        
               if pixel_addr_cnt = PIXEL_ADDR_MAX-1 then 
                  pixel_addr_cnt <= 0;     
               else 
                  pixel_addr_cnt <= pixel_addr_cnt + 1;
               end if;
            end if;
            
            
         end if;
      end if;
   end process address_counter;
   
   -- assign counts to bit vectors
   pixel_address  <= std_logic_vector(to_unsigned(pixel_addr_cnt, PIXEL_ADDR_WIDTH));
   raw_address    <= std_logic_vector(to_unsigned(raw_addr_cnt,   RAW_ADDR_WIDTH  ));
   raw_ch_mux_sel <= std_logic_vector(to_unsigned(raw_ch_cnt,     CH_MUX_SEL_WIDTH  ));
   
   -- split pixel address into row and channel     
   row_address    <= pixel_address(PIXEL_ADDR_WIDTH-1 downto CH_MUX_SEL_WIDTH);
   ch_mux_sel     <= pixel_address(CH_MUX_SEL_WIDTH-1 downto 0);      
   
   
  
--------------------------------------------------------------------------------------------
--                  Data OUTPUT Select MUX
---------------------------------------------------------------------------------------------
  
   
   dat_out_mux_sel <= data_mode_reg(1 downto 0);
   
   wbs_data        <= filtered_dat   when dat_out_mux_sel = "00" else
                      unfiltered_dat when dat_out_mux_sel = "01" else
                      fb_error_dat   when dat_out_mux_sel = "01" else
                      raw_dat        when dat_out_mux_sel = "11";
                 
                 
 
 
--------------------------------------------------------------------------------------------
--                 Channel select MUXs
---------------------------------------------------------------------------------------------
 
  
 
 
   filtered_dat   <= filtered_dat_ch1_i when ch_mux_sel = "000" else
                     filtered_dat_ch2_i when ch_mux_sel = "001" else
                     filtered_dat_ch3_i when ch_mux_sel = "010" else
                     filtered_dat_ch4_i when ch_mux_sel = "011" else
                     filtered_dat_ch5_i when ch_mux_sel = "100" else
                     filtered_dat_ch6_i when ch_mux_sel = "101" else
                     filtered_dat_ch7_i when ch_mux_sel = "110" else
                     filtered_dat_ch8_i when ch_mux_sel = "111";
 
 
   unfiltered_dat <= fsfb_dat_ch1_i when ch_mux_sel = "000" else
                     fsfb_dat_ch2_i when ch_mux_sel = "001" else
                     fsfb_dat_ch3_i when ch_mux_sel = "010" else
                     fsfb_dat_ch4_i when ch_mux_sel = "011" else
                     fsfb_dat_ch5_i when ch_mux_sel = "100" else
                     fsfb_dat_ch6_i when ch_mux_sel = "101" else
                     fsfb_dat_ch7_i when ch_mux_sel = "110" else
                     fsfb_dat_ch8_i when ch_mux_sel = "111";
 
   
   fb_error_dat    <= fsfb_dat_ch1_i (31 downto 16) & coadded_dat_ch1_i(31 downto 16) when ch_mux_sel = "000" else
                      fsfb_dat_ch2_i (31 downto 16) & coadded_dat_ch2_i(31 downto 16) when ch_mux_sel = "001" else 
                      fsfb_dat_ch3_i (31 downto 16) & coadded_dat_ch3_i(31 downto 16) when ch_mux_sel = "010" else
                      fsfb_dat_ch4_i (31 downto 16) & coadded_dat_ch4_i(31 downto 16) when ch_mux_sel = "011" else
                      fsfb_dat_ch5_i (31 downto 16) & coadded_dat_ch5_i(31 downto 16) when ch_mux_sel = "100" else
                      fsfb_dat_ch6_i (31 downto 16) & coadded_dat_ch6_i(31 downto 16) when ch_mux_sel = "101" else
                      fsfb_dat_ch7_i (31 downto 16) & coadded_dat_ch7_i(31 downto 16) when ch_mux_sel = "110" else
                      fsfb_dat_ch8_i (31 downto 16) & coadded_dat_ch8_i(31 downto 16) when ch_mux_sel = "111";
     
      
   raw_dat(31 downto 16) <= (others => '0');
   raw_dat(15 downto  0) <= raw_dat_ch1_i when raw_ch_mux_sel = "000" else
                            raw_dat_ch2_i when raw_ch_mux_sel = "001" else 
                            raw_dat_ch2_i when raw_ch_mux_sel = "010" else
                            raw_dat_ch2_i when raw_ch_mux_sel = "011" else
                            raw_dat_ch2_i when raw_ch_mux_sel = "100" else
                            raw_dat_ch2_i when raw_ch_mux_sel = "101" else
                            raw_dat_ch2_i when raw_ch_mux_sel = "110" else
                            raw_dat_ch2_i when raw_ch_mux_sel = "111" ; 
       
      
      
    -- raw data acknowledge MUX  
      
    raw_ack             <=  raw_ack_ch1_i when raw_ch_mux_sel = "000" else
                            raw_ack_ch2_i when raw_ch_mux_sel = "001" else 
                            raw_ack_ch2_i when raw_ch_mux_sel = "010" else
                            raw_ack_ch2_i when raw_ch_mux_sel = "011" else
                            raw_ack_ch2_i when raw_ch_mux_sel = "100" else
                            raw_ack_ch2_i when raw_ch_mux_sel = "101" else
                            raw_ack_ch2_i when raw_ch_mux_sel = "110" else
                            raw_ack_ch2_i when raw_ch_mux_sel = "111" ; 
       


    -- output raw dat request select
    
    raw_req_ch1_o       <=  raw_req  when raw_ch_mux_sel = "000" else '0';
    raw_req_ch2_o       <=  raw_req  when raw_ch_mux_sel = "001" else '0';
    raw_req_ch3_o       <=  raw_req  when raw_ch_mux_sel = "010" else '0';
    raw_req_ch4_o       <=  raw_req  when raw_ch_mux_sel = "011" else '0';
    raw_req_ch5_o       <=  raw_req  when raw_ch_mux_sel = "100" else '0';
    raw_req_ch6_o       <=  raw_req  when raw_ch_mux_sel = "101" else '0';
    raw_req_ch7_o       <=  raw_req  when raw_ch_mux_sel = "110" else '0';
    raw_req_ch8_o       <=  raw_req  when raw_ch_mux_sel = "111" else '0';
    
    
       
      
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