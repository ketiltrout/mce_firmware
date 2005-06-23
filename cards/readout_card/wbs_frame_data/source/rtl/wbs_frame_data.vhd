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
-- Author:           David Atkinson
-- Organisation:        UKATC
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
-- <date $Date: 2005/01/12 23:28:31 $> - <text> - <initials $Author: mohsen $>
--
-- $Log: wbs_frame_data.vhd,v $
-- Revision 1.20  2005/01/12 23:28:31  mohsen
-- Anthony & Mohse: Fixed latch inference problem from next state due to imcomplete condition coverage.
--
-- Revision 1.19  2005/01/11 02:37:59  mohsen
-- Anthony & Mohse: Got rid multi level "if" statements to help resolve timing violation
--
-- Revision 1.18  2005/01/10 20:40:08  mohsen
-- Anthony & Mohse: Got rid of priority coding to help solve timing violation.
--
-- Revision 1.17  2004/12/17 09:59:29  dca
-- fixed bug where FSM output signal 'dec_addr_ena' was previously unassigned in  two states.
--
-- Revision 1.16  2004/12/14 19:57:55  erniel
-- attempted fix on inferred latches
--
-- Revision 1.15  2004/12/09 12:58:34  dca
-- block now also acknowledges:
-- read captr_raw
-- read data_mode
-- write ret_data
--
-- Revision 1.14  2004/12/07 19:37:46  mohsen
-- Anthony & Mohsen: Restructured constant declaration.  Moved shared constants from lower level package files to the upper level ones.  This was done to resolve compilation error resulting from shared constants defined in multiple package files.
--
-- Revision 1.13  2004/11/26 18:29:08  mohsen
-- Anthony & Mohsen: Restructured constant declaration.  Moved shared constants from lower level package files to the upper level ones.  This was done to resolve compilation error resulting from shared constants defined in multiple package files.
--
-- Revision 1.12  2004/11/04 17:12:36  dca
-- code added to reset raw address if a captr_raw instruction comes arrives
-- between 328 block reads (i.e. before all 128 block reads are performed).
--
-- Revision 1.11  2004/10/29 12:39:34  dca
-- read cycle changed to block read...
-- Can now handle master wait states being inserted.
--
-- Revision 1.10  2004/10/28 15:43:48  dca
-- ret_data wishbone reads changed to block reads.
--
-- Revision 1.9  2004/10/27 13:10:55  dca
-- some minor changes
--
-- Revision 1.8  2004/10/26 16:13:33  dca
-- 1st complete version.
--
-- Revision 1.7  2004/10/20 13:21:50  dca
-- FSM changed for captr_raw writes.
--
-- Revision 1.6  2004/10/19 14:30:45  dca
-- raw data addressing changed.
-- MUX structure changed
--
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
use work.flux_loop_pack.all;
use work.readout_card_pack.all;


entity wbs_frame_data is



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
                  
     dat_o                     : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);       -- data out
     ack_o                     : out std_logic                                         -- acknowledge out
     );      
end wbs_frame_data;


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;


architecture rtl of wbs_frame_data is

-- three wishbone read/write request enables
--signal write_data_mode     : std_logic;                        
signal read_ret_data       : std_logic;
--signal write_captr_raw     : std_logic;

-- three further wishbone read/write request enables
-- in general these won't be called but need to be handled
--signal read_data_mode     : std_logic;    -- to verify written mode value                     
--signal write_ret_data     : std_logic;   -- only would occur as an error
--signal read_captr_raw     : std_logic;   -- only would occur as an error.  read is meaningless.


-- signals for registering data mode word

signal data_mode_reg       : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
signal data_mode           : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
signal data_mode_mux_sel   : std_logic ;


-- data mapped to wishbone data output

signal wbs_data            : std_logic_vector(WB_DATA_WIDTH-1 downto 0);


-- four types of data read from flux_loop_cntr blocks

signal filtered_dat        : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
signal unfiltered_dat      : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
signal fb_error_dat        : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);
signal raw_dat             : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0);


-- signal used to map correct data type to output
signal dat_out_mux_sel     : std_logic_vector (1 downto 0);

-- signals to enable increment, decrement and reset address counters
signal inc_addr_ena        : std_logic;
signal dec_addr_ena        : std_logic;
signal rst_addr_ena        : std_logic;

-- address used for modes 1, 2 and 3

signal pix_addr_cnt      : integer range 0 to 2**(ROW_ADDR_WIDTH+CH_MUX_SEL_WIDTH)-1;
signal pix_address       : std_logic_vector (ROW_ADDR_WIDTH+CH_MUX_SEL_WIDTH-1 downto 0);       -- pixel address split for row and channel modes 1,2,3
signal ch_mux_sel        : std_logic_vector (CH_MUX_SEL_WIDTH-1 downto 0);       -- channel select ch 0 --> 7
    
-- channel select needs to be delayed by 2 clock cycles as that the time it take to update data
-- so an extra register stage...
signal ch_mux_sel_dly1   : std_logic_vector (CH_MUX_SEL_WIDTH-1 downto 0);   

-- address used for mode 4

signal raw_addr_cnt        : integer range 0 to 2**(RAW_ADDR_WIDTH+CH_MUX_SEL_WIDTH)-1;
signal raw_address         : std_logic_vector (RAW_ADDR_WIDTH+CH_MUX_SEL_WIDTH-1    downto 0);      -- raw 'row' address
signal raw_ch_mux_sel      : std_logic_vector (CH_MUX_SEL_WIDTH-1  downto 0);       -- raw channel select

-- channel select needs to be delayed by 2 clock cycles as that the time it take to update data
-- so an extra register stage
signal raw_ch_mux_sel_dly1   : std_logic_vector (CH_MUX_SEL_WIDTH-1 downto 0);   

signal raw_req             : std_logic;      -- signal fed to all 8 flux loop cntr channels 
signal raw_ack             : std_logic;      -- ANDedacknowledgements from all 8 flux loop cntr channels

signal dat_rdy             : std_logic;   -- asserted by FSM whne data word ready for read
signal instr_done          : std_logic;  -- asserted by FSM when write cycle done         

-- slave controller FSM

type state is (IDLE, WSS1, WSS2, READ_DATA, WSM1, WSM2, START_RAW, FINISH, SET_MODE, READ_MODE, DONE);                           

signal current_state: state;
signal next_state:    state;

begin


-------------------------------------------------------------------------------------------------
--                       Wishbone interface  -  identify 3 commands 
------------------------------------------------------------------------------------------------

-- removed all these to reduce logic loevels and help solve timing violations.
--  However, keep them as some sort of comment into the functionality.
  
--    write_data_mode <= '1' when (addr_i = DATA_MODE_ADDR and stb_i = '1' and cyc_i = '1' and we_i = '1')
--                    else '0';

  -- Only use for ack_o signal in the new version
    read_ret_data   <= '1' when (addr_i = RET_DAT_ADDR and stb_i = '1' and cyc_i = '1' and we_i = '0')
                    else '0';

--    write_captr_raw <= '1' when (addr_i = CAPTR_RAW_ADDR and stb_i = '1' and cyc_i = '1' and we_i = '1')
--                    else '0';
                   

-------------------------------------------------------------------------------------------------
--                       Wishbone interface  -  3 further commads for slave to handle 
------------------------------------------------------------------------------------------------
   
--    -- a read back of the data mode may be required for debug....
--    read_data_mode <= '1' when (addr_i = DATA_MODE_ADDR and stb_i = '1' and cyc_i = '1' and we_i = '0')
--                    else '0';
    
--    -- this would only ocurr as a error but slave needs to acknowledge or system will hang
--    write_ret_data   <= '1' when (addr_i = RET_DAT_ADDR and stb_i = '1' and cyc_i = '1' and we_i = '1')
--                    else '0';

--    -- again this should never be requested as data is meaningless.  However, slave must ack to prevent system hang
--    read_captr_raw <= '1' when (addr_i = CAPTR_RAW_ADDR and stb_i = '1' and cyc_i = '1' and we_i = '0')
--                    else '0';
   
   
    ack_o           <= instr_done or (dat_rdy and read_ret_data);     -- acknowledge when an instrunction is done or when data is ready (and master not inserted wait state)
      
-------------------------------------------------------------------------------------------------
--                       Flux Loop Cntr  -  request/acknowledge signals 
------------------------------------------------------------------------------------------------  
     
   raw_ack       <= raw_ack_ch0_i and raw_ack_ch1_i and raw_ack_ch2_i and  raw_ack_ch3_i and
                    raw_ack_ch4_i and raw_ack_ch5_i and raw_ack_ch6_i and  raw_ack_ch7_i ;
  
   raw_req_ch0_o <= raw_req;
   raw_req_ch1_o <= raw_req;
   raw_req_ch2_o <= raw_req;
   raw_req_ch3_o <= raw_req;
   raw_req_ch4_o <= raw_req;
   raw_req_ch5_o <= raw_req;
   raw_req_ch6_o <= raw_req;
   raw_req_ch7_o <= raw_req; 
   
   
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
   
   -----------------------------------------------------------------------------------------
   nextstate_fsm: process (current_state, raw_ack, data_mode_reg, pix_addr_cnt, raw_addr_cnt, 
                           addr_i, stb_i, cyc_i, we_i)
   ------------------------------------------------------------------------------------------
   begin

     next_state <= current_state;  

     case current_state is
       
      when IDLE =>
   
         -- note the if statements are exclusive
         
         --if write_data_mode = '1' then
         if (addr_i = DATA_MODE_ADDR and stb_i = '1' and cyc_i = '1' and we_i = '1') then
            next_state <= SET_MODE;
         end if;
         
         --if read_ret_data = '1' then
         if (addr_i = RET_DAT_ADDR and stb_i = '1' and cyc_i = '1' and we_i = '0') then
            next_state <= WSS1;
         end if;
         
         --if write_captr_raw = '1' then
         if (addr_i = CAPTR_RAW_ADDR and stb_i = '1' and cyc_i = '1' and we_i = '1') then
            next_state <= START_RAW;
         end if;
         
         --if read_data_mode = '1' then
         if (addr_i = DATA_MODE_ADDR and stb_i = '1' and cyc_i = '1' and we_i = '0') then
            next_state <= READ_MODE;
         end if;
         
         --if write_ret_data = '1' or read_captr_raw = '1' then
         if ((addr_i = RET_DAT_ADDR and stb_i = '1' and cyc_i = '1' and we_i = '1') or (addr_i = CAPTR_RAW_ADDR and stb_i = '1' and cyc_i = '1' and we_i = '0')) then
            next_state <=  FINISH;
         end if;
                        
                     
      when WSS1 =>
         next_state <= WSS2;                
                           
      when WSS2 =>
         next_state <= READ_DATA;                                 
       
      when READ_DATA =>
         
        
         --if (read_ret_data = '1' and data_mode_reg = MODE4_RAW and (raw_addr_cnt < RAW_ADDR_MAX+1)) then 
--          if ((addr_i = RET_DAT_ADDR and stb_i = '1' and cyc_i = '1' and we_i = '0') and data_mode_reg = MODE4_RAW and (raw_addr_cnt < RAW_ADDR_MAX+1)) then
--            next_state <= READ_DATA;
--          end if;

         --if (read_ret_data='1' and data_mode_reg = MODE4_RAW and (raw_addr_cnt >= RAW_ADDR_MAX+1))  then
         if ((addr_i = RET_DAT_ADDR and stb_i = '1' and cyc_i = '1' and we_i = '0') and data_mode_reg = MODE4_RAW and (raw_addr_cnt >= RAW_ADDR_MAX-1))then
           next_state <= done;
         end if;

         --if (read_ret_data = '1' and data_mode_reg /= MODE4_RAW and (pix_addr_cnt < PIXEL_ADDR_MAX+1)) then
--          if ((addr_i = RET_DAT_ADDR and stb_i = '1' and cyc_i = '1' and we_i = '0') and data_mode_reg /= MODE4_RAW and (pix_addr_cnt < PIXEL_ADDR_MAX+1)) then
--            next_state <= READ_DATA;
--          end if;

         --if (read_ret_data = '1' and data_mode_reg /= MODE4_RAW and (pix_addr_cnt >= PIXEL_ADDR_MAX+1)) then
         if ((addr_i = RET_DAT_ADDR and stb_i = '1' and cyc_i = '1' and we_i = '0') and data_mode_reg /= MODE4_RAW and (pix_addr_cnt >= PIXEL_ADDR_MAX+1)) then
           next_state <= done;
         end if;
         
         --if read_ret_data = '0' then
         if not(addr_i = RET_DAT_ADDR and stb_i = '1' and cyc_i = '1' and we_i = '0') then
           next_state <= WSM1;     -- if stb has been ds-asserted go to wishbone master wait state  
                                   -- will also go here when a set of 328 raw data has been read
                                   -- but not yet at RAW_ADDR_MAX
         end if;
         
      when WSM1 =>
         next_state <= WSM2;
      
      when WSM2 => 
--         next_state <= WSM2;             -- default to same state

         -- exclusive if statements
         --if    (write_data_mode = '1' ) or ( write_captr_raw = '1' ) then 
         if ((addr_i = DATA_MODE_ADDR and stb_i = '1' and cyc_i = '1' and we_i = '1') or (addr_i = CAPTR_RAW_ADDR and stb_i = '1' and cyc_i = '1' and we_i = '1')) then
                                            -- if wishbone write instruction arrives then....
            next_state <= IDLE;             -- go to idle to reset address counters and process instruction 
                                            -- this should only occur when waiting to read next 328 raw data block and want to change mode
                                            -- or reset raw data.... 
         end if;
         
        --if (read_ret_data = '1' ) then  
        if (addr_i = RET_DAT_ADDR and stb_i = '1' and cyc_i = '1' and we_i = '0') then
            next_state <= WSS1;  -- if master de-asseterts wait state - or reading next 328  block of raw data
                                 -- go to wait state slave to start addressing cycle again
        end if;
                 
      
      when READ_MODE => 
           next_state <= DONE;                      
     
      when START_RAW  =>
        
        if raw_ack = '1' then 
           next_state <= FINISH;
        end if; 
      
                    
      when SET_MODE | FINISH=>
         next_state <= DONE;
      
      when DONE =>
         next_state <= IDLE;
      end case;
         
    end process nextstate_fsm;
    
   -------------------------------------------------------------- 
   output_fsm: process (current_state, wbs_data, data_mode_reg)
   ---------------------------------------------------------------
   begin

      case current_state is
      
      when IDLE =>
      
         dat_rdy           <= '0';
         instr_done        <= '0';
         dat_o             <= (others => '0');
         data_mode_mux_sel <= '0';
         inc_addr_ena      <= '0'; 
         dec_addr_ena      <= '0';
         rst_addr_ena      <= '1';   
         raw_req           <= '0';
                      
      when SET_MODE =>
         dat_rdy           <= '0';
         instr_done        <= '1';
         dat_o             <= (others => '0');
         data_mode_mux_sel <= '1';
         inc_addr_ena      <= '0';
         dec_addr_ena      <= '0';
         rst_addr_ena      <= '0';
         raw_req           <= '0';

                
      when WSS1 =>
         dat_rdy           <= '0';
         instr_done        <= '0';
         dat_o             <= (others => '0');
         data_mode_mux_sel <= '0';
         inc_addr_ena      <= '1';
         
         -- increment address here, the increment will take 1 clock cycle,
         -- then the data from the FLC blocks will take an additional 2 clock cycles to update.
         -- SO there is a total of 3 clock cycles until the next data word is ready to be read by the wishbone master.
         -- Consequently, 1st time in READ_DATA state we will be reading address 0, then next time address1 etc...
         dec_addr_ena      <= '0';
         rst_addr_ena      <= '0';
         raw_req           <= '0';          
                           
      when WSS2 =>
         dat_rdy           <= '0';
         instr_done        <= '0';
         dat_o             <= (others => '0');
         data_mode_mux_sel <= '0';
         inc_addr_ena      <= '1';
         dec_addr_ena      <= '0';
         rst_addr_ena      <= '0';
         raw_req           <= '0';

      when WSM1 =>
         dat_rdy           <= '0';
         instr_done        <= '0';
         dat_o             <= (others => '0');
         data_mode_mux_sel <= '0';
         inc_addr_ena      <= '0';
         
         -- need to count address back down so it's sync'ed with data when reads resume
         dec_addr_ena      <= '1';     
         rst_addr_ena      <= '0';
         raw_req           <= '0';
         
      when WSM2 =>
         dat_rdy           <= '0';
         instr_done        <= '0';
         dat_o             <= (others => '0');
         data_mode_mux_sel <= '0';
         inc_addr_ena      <= '0';
         dec_addr_ena      <= '0';
         rst_addr_ena      <= '0';
         raw_req           <= '0';   

      when READ_DATA =>
         dat_rdy           <= '1';
         instr_done        <= '0';
         dat_o             <= wbs_data;
         data_mode_mux_sel <= '0';
         inc_addr_ena      <= '1';    
         dec_addr_ena      <= '0';
         rst_addr_ena      <= '0';
         raw_req           <= '0';
             
      when START_RAW =>
         dat_rdy           <= '0';
         instr_done        <= '0';
         dat_o             <= (others => '0');
         data_mode_mux_sel <= '0';
         inc_addr_ena      <= '0';
         dec_addr_ena      <= '0';
         rst_addr_ena      <= '0';
         raw_req           <= '1';
         
      when READ_MODE =>
         dat_rdy           <= '0';
         instr_done        <= '1';
         dat_o             <= data_mode_reg;
         data_mode_mux_sel <= '0';
         inc_addr_ena      <= '0';
         dec_addr_ena      <= '0';
         rst_addr_ena      <= '0';
         raw_req           <= '0';   
         
      when FINISH =>   
         dat_rdy           <= '0';
         instr_done        <= '1';
         dat_o             <= (others => '0');
         data_mode_mux_sel <= '0';
         inc_addr_ena      <= '0';
         dec_addr_ena      <= '0';
         rst_addr_ena      <= '0';
         raw_req           <= '0';   
                    
      when DONE =>
         dat_rdy           <= '0';
         instr_done        <= '0';
         dat_o             <= (others => '0');
         data_mode_mux_sel <= '0';
         inc_addr_ena      <= '0';
         dec_addr_ena      <= '0';
         rst_addr_ena      <= '0';
         raw_req           <= '0';
         
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

    
 
   ------------------------------------- 
   address_counter: process (clk_i, rst_i) 
   -------------------------------------      
    begin
         
      if (rst_i = '1') then                         -- asynchronous reset
         pix_addr_cnt   <= 0 ;
         raw_addr_cnt   <= 0 ;
      elsif (clk_i'EVENT AND clk_i = '1') then
         
         -- note that rst_addr_ena, inc_addr_ena, and dec_addr_ena are exclusive!

         if rst_addr_ena = '1' then                 -- synchronous reset 
            pix_addr_cnt   <= 0 ;
            raw_addr_cnt   <= 0 ;
         end if;

          if inc_addr_ena = '1' and data_mode_reg = MODE4_RAW then
           raw_addr_cnt <= raw_addr_cnt+1;  -- synchronous increment by 1
         end if;

         if inc_addr_ena = '1' and data_mode_reg /= MODE4_RAW then
           pix_addr_cnt <= pix_addr_cnt +1; -- synchronous increment by 1
         end if;

         if dec_addr_ena = '1' and data_mode_reg = MODE4_RAW then
           raw_addr_cnt <= raw_addr_cnt -3;  -- synchronous decrement by 3
         end if;
         
         if dec_addr_ena = '1' and data_mode_reg /= MODE4_RAW then
           pix_addr_cnt <= pix_addr_cnt -3;  -- synchronous decrement by 3
         end if;

     end if;
  end process address_counter;
   
   
      
  
   -- assign counts to bit vectors - modes 1,2,3
   -- note that the LS 3 bits of the address determine the channel
   -- the other bits determine the row address.
   
   pix_address    <= conv_std_logic_vector(pix_addr_cnt, ROW_ADDR_WIDTH+CH_MUX_SEL_WIDTH);   
 --  ch_mux_sel     <= pix_address(CH_MUX_SEL_WIDTH-1 downto 0); 
       
   
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
   
 

   -- assign counts to address vectors - mode 4
   -- the LS  bits determine the channel
   -- the rest the 'row'.
 
  
   raw_address    <= conv_std_logic_vector(raw_addr_cnt,   RAW_ADDR_WIDTH+CH_MUX_SEL_WIDTH);   
 --  raw_ch_mux_sel <= raw_address(CH_MUX_SEL_WIDTH-1 downto 0);
   
   
   
   raw_addr_ch0_o <= raw_address(RAW_ADDR_WIDTH+CH_MUX_SEL_WIDTH-1 downto CH_MUX_SEL_WIDTH);  
   raw_addr_ch1_o <= raw_address(RAW_ADDR_WIDTH+CH_MUX_SEL_WIDTH-1 downto CH_MUX_SEL_WIDTH); 
   raw_addr_ch2_o <= raw_address(RAW_ADDR_WIDTH+CH_MUX_SEL_WIDTH-1 downto CH_MUX_SEL_WIDTH); 
   raw_addr_ch3_o <= raw_address(RAW_ADDR_WIDTH+CH_MUX_SEL_WIDTH-1 downto CH_MUX_SEL_WIDTH); 
   raw_addr_ch4_o <= raw_address(RAW_ADDR_WIDTH+CH_MUX_SEL_WIDTH-1 downto CH_MUX_SEL_WIDTH); 
   raw_addr_ch5_o <= raw_address(RAW_ADDR_WIDTH+CH_MUX_SEL_WIDTH-1 downto CH_MUX_SEL_WIDTH); 
   raw_addr_ch6_o <= raw_address(RAW_ADDR_WIDTH+CH_MUX_SEL_WIDTH-1 downto CH_MUX_SEL_WIDTH); 
   raw_addr_ch7_o <= raw_address(RAW_ADDR_WIDTH+CH_MUX_SEL_WIDTH-1 downto CH_MUX_SEL_WIDTH); 
   
       
  
--------------------------------------------------------------------------------------------
--                  Data OUTPUT Select MUX
---------------------------------------------------------------------------------------------
  
   
    dat_out_mux_sel <= data_mode_reg(1 downto 0);
   

    with dat_out_mux_sel select
       wbs_data     <= filtered_dat   when "00",
                       unfiltered_dat when "01",
                       fb_error_dat   when "10",
                       raw_dat        when others;
                 
 
 
--------------------------------------------------------------------------------------------
--                 Channel select MUXs
---------------------------------------------------------------------------------------------
 
                       
   with ch_mux_sel select
      filtered_dat  <= filtered_dat_ch0_i when "000",
                       filtered_dat_ch1_i when "001",
                       filtered_dat_ch2_i when "010",
                       filtered_dat_ch3_i when "011",
                       filtered_dat_ch4_i when "100",
                       filtered_dat_ch5_i when "101",
                       filtered_dat_ch6_i when "110",
                       filtered_dat_ch7_i when others;

   with ch_mux_sel select
      unfiltered_dat <= fsfb_dat_ch0_i when "000", 
                        fsfb_dat_ch1_i when "001",
                        fsfb_dat_ch2_i when "010",
                        fsfb_dat_ch3_i when "011",
                        fsfb_dat_ch4_i when "100",
                        fsfb_dat_ch5_i when "101",
                        fsfb_dat_ch6_i when "110",
                        fsfb_dat_ch7_i when others;
 
   
   with ch_mux_sel select
      fb_error_dat   <= fsfb_dat_ch0_i (31 downto 16) & coadded_dat_ch0_i(31 downto 16) when "000",
                        fsfb_dat_ch1_i (31 downto 16) & coadded_dat_ch1_i(31 downto 16) when "001",
                        fsfb_dat_ch2_i (31 downto 16) & coadded_dat_ch2_i(31 downto 16) when "010",
                        fsfb_dat_ch3_i (31 downto 16) & coadded_dat_ch3_i(31 downto 16) when "011",
                        fsfb_dat_ch4_i (31 downto 16) & coadded_dat_ch4_i(31 downto 16) when "100",
                        fsfb_dat_ch5_i (31 downto 16) & coadded_dat_ch5_i(31 downto 16) when "101",
                        fsfb_dat_ch6_i (31 downto 16) & coadded_dat_ch6_i(31 downto 16) when "110",
                        fsfb_dat_ch7_i (31 downto 16) & coadded_dat_ch7_i(31 downto 16) when others;
      
   raw_dat(31 downto 16)    <= (others => '0');
   with raw_ch_mux_sel select
      raw_dat(15 downto  0) <= raw_dat_ch0_i when "000",
                               raw_dat_ch1_i when "001", 
                               raw_dat_ch2_i when "010",
                               raw_dat_ch3_i when "011",
                               raw_dat_ch4_i when "100",
                               raw_dat_ch5_i when "101",
                               raw_dat_ch6_i when "110",
                               raw_dat_ch7_i when others;
       
  

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
        
     elsif (clk_i'EVENT and clk_i = '1') then
        ch_mux_sel_dly1     <= pix_address(CH_MUX_SEL_WIDTH-1 downto 0);  
        ch_mux_sel          <= ch_mux_sel_dly1;
        
        raw_ch_mux_sel_dly1 <= raw_address(CH_MUX_SEL_WIDTH-1 downto 0);
        raw_ch_mux_sel      <= raw_ch_mux_sel_dly1;
        
     end if;
  end process channel_select_delay;
          
           
end rtl;
