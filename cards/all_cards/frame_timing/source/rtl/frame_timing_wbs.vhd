-- 2003 SCUBA-2 Project
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
-- $Id: frame_timing_wbs.vhd,v 1.5 2005/01/13 23:57:23 bburger Exp $
--
-- Project:       SCUBA2
-- Author:        Bryce Burger
-- Organisation:  UBC
--
-- Description:
-- Wishbone interface for a 14-bit 165MS/s DAC (AD9744) controller
-- This block was written to be coupled with wbs_ac_dac_ctrl
--
-- Revision history:
-- $Log: frame_timing_wbs.vhd,v $
-- Revision 1.5  2005/01/13 23:57:23  bburger
-- Bryce:  init_window_req_reg has been replaced with a custom register to get rid of a non-standard usaged of the rst_i line
--
-- Revision 1.4  2005/01/13 03:14:51  bburger
-- Bryce:
-- addr_card and clk_card:  added slot_id functionality, removed mem_clock
-- sync_gen and frame_timing:  added custom counters and registers
--
-- Revision 1.3  2005/01/06 01:34:52  bburger
-- Bryce:  mem_clk_i is no longer used to clock internal registers
--
-- Revision 1.2  2004/12/14 20:17:38  bburger
-- Bryce:  Repaired some problems with frame_timing and added a list of frame_timing-initialization commands to clk_card
--
-- Revision 1.1  2004/11/18 05:21:56  bburger
-- Bryce :  modified addr_card top level.  Added ac_dac_ctrl and frame_timing
--
-- Revision 1.6  2004/11/08 23:40:29  bburger
-- Bryce:  small modifications
--
-- Revision 1.5  2004/11/06 03:12:01  bburger
-- Bryce:  debugging
--
-- Revision 1.4  2004/11/04 00:08:18  bburger
-- Bryce:  small updates
--
-- Revision 1.3  2004/11/02 07:38:09  bburger
-- Bryce:  ac_dac_ctrl in progress
--
--
-----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

library components;
use components.component_pack.all;

library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;

library work;
use work.frame_timing_pack.all;

entity frame_timing_wbs is        
   port
   (
      -- frame_timing interface:
      row_len_o          : out integer;
      num_rows_o         : out integer;
      sample_delay_o     : out integer;
      sample_num_o       : out integer;
      feedback_delay_o   : out integer;
      address_on_delay_o : out integer;
      resync_ack_i       : in std_logic;      
      resync_req_o       : out std_logic;
      init_window_ack_i  : in std_logic;
      init_window_req_o  : out std_logic;

      -- wishbone interface:
      dat_i              : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      addr_i             : in std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
      tga_i              : in std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
      we_i               : in std_logic;
      stb_i              : in std_logic;
      cyc_i              : in std_logic;
      dat_o              : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      ack_o              : out std_logic;

      -- global interface
      clk_i              : in std_logic;
      rst_i              : in std_logic 
   );     
end frame_timing_wbs;

architecture rtl of frame_timing_wbs is

   -- FSM inputs
   signal wr_cmd                : std_logic;
   signal rd_cmd                : std_logic;
   signal master_wait           : std_logic;

   -- Register signals
   signal row_length_wren       : std_logic;
   signal row_length_data       : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal num_rows_wren         : std_logic;
   signal num_rows_data         : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal sample_delay_wren     : std_logic;
   signal sample_delay_data     : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal sample_num_wren       : std_logic;
   signal sample_num_data       : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal feedback_delay_wren   : std_logic;
   signal feedback_delay_data   : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal address_on_delay_wren : std_logic;
   signal address_on_delay_data : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal resync_req_wren       : std_logic;
   signal resync_req_data       : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal init_window_req_wren  : std_logic;
   signal init_window_req_data  : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   
   signal init_window_rst       : std_logic;
   
   -- WBS states:
   type states is (IDLE, WR, RD); 
   signal current_state    : states;
   signal next_state       : states;
   
begin

   row_len_o          <= conv_integer(row_length_data);      
   num_rows_o         <= conv_integer(num_rows_data);        
   sample_delay_o     <= conv_integer(sample_delay_data);    
   sample_num_o       <= conv_integer(sample_num_data);      
   feedback_delay_o   <= conv_integer(feedback_delay_data);  
   address_on_delay_o <= conv_integer(address_on_delay_data);
   
   -- register the wren and use that to write to these registers
   resync_req_o       <= '0' when resync_req_data      = x"00000000" else '1';      
   init_window_req_o  <= '0' when init_window_req_data = x"00000000" else '1';   
   
   -- Custom register that gets set to MUX_LINE_PERIOD upon reset
   row_len_reg: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         row_length_data <= std_logic_vector(conv_unsigned(MUX_LINE_PERIOD, PACKET_WORD_WIDTH));
      elsif(clk_i'event and clk_i = '1') then
         if(row_length_wren = '1') then
            row_length_data <= dat_i;
         end if;
      end if;
   end process row_len_reg;

   -- Custom register that gets set to NUM_OF_ROWS upon reset
   num_rows_reg: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         num_rows_data <= std_logic_vector(conv_unsigned(NUM_OF_ROWS, PACKET_WORD_WIDTH));
      elsif(clk_i'event and clk_i = '1') then
         if(num_rows_wren = '1') then
            num_rows_data <= dat_i;
         end if;
      end if;
   end process num_rows_reg;

   sample_delay_reg : reg
      generic map(
         WIDTH             => PACKET_WORD_WIDTH
      )
      port map(
         clk_i             => clk_i,
         rst_i             => rst_i,
         ena_i             => sample_delay_wren,
         reg_i             => dat_i,
         reg_o             => sample_delay_data
      );

   sample_num_reg : reg
      generic map(
         WIDTH             => PACKET_WORD_WIDTH
      )
      port map(
         clk_i             => clk_i,
         rst_i             => rst_i,
         ena_i             => sample_num_wren,
         reg_i             => dat_i,
         reg_o             => sample_num_data
      );

   feedback_delay_reg : reg
      generic map(
         WIDTH             => PACKET_WORD_WIDTH
      )
      port map(
         clk_i             => clk_i,
         rst_i             => rst_i,
         ena_i             => feedback_delay_wren,
         reg_i             => dat_i,
         reg_o             => feedback_delay_data
      );

   address_on_delay_reg : reg
      generic map(
         WIDTH             => PACKET_WORD_WIDTH
      )
      port map(
         clk_i             => clk_i,
         rst_i             => rst_i,
         ena_i             => address_on_delay_wren,
         reg_i             => dat_i,
         reg_o             => address_on_delay_data
      );

   resync_req_reg : reg
      generic map(
         WIDTH             => PACKET_WORD_WIDTH
      )
      port map(
         clk_i             => clk_i,
         rst_i             => rst_i,
         ena_i             => resync_req_wren,
         reg_i             => dat_i,
         reg_o             => resync_req_data
      );

   -- Custom register
   init_window_req_reg: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         init_window_req_data <= (others => '0');
      elsif(clk_i'event and clk_i = '1') then
         if(init_window_ack_i = '1') then
            init_window_req_data <= (others => '0');
         end if;
         if(init_window_ack_i /= '1' and init_window_req_wren = '1') then
            init_window_req_data <= dat_i;
         end if;
      end if;
   end process init_window_req_reg;

------------------------------------------------------------
--  WB FSM
------------------------------------------------------------   

   -- clocked FSMs, advance the state for both FSMs
   state_FF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         current_state     <= IDLE;
      elsif(clk_i'event and clk_i = '1') then
         current_state     <= next_state;
      end if;
   end process state_FF;
   
   -- Transition table for DAC controller
   state_NS: process(current_state, rd_cmd, wr_cmd, cyc_i)
   begin
      -- Default assignments
      next_state <= current_state;
      
      case current_state is
         when IDLE =>
            if(wr_cmd = '1') then
               next_state <= WR;            
            elsif(rd_cmd = '1') then
               next_state <= RD;
            end if;                  
            
         when WR =>     
            if(cyc_i = '0') then
               next_state <= IDLE;
            end if;
         
         when RD =>
            if(cyc_i = '0') then
               next_state <= IDLE;
            end if;
         
         when others =>
            next_state <= IDLE;

      end case;
   end process state_NS;
   
   -- Output states for DAC controller   
   state_out: process(current_state, stb_i, addr_i)
   begin
      -- Default assignments
      ack_o                 <= '0';
      row_length_wren       <= '0';
      num_rows_wren         <= '0';
      sample_delay_wren     <= '0';
      sample_num_wren       <= '0';
      feedback_delay_wren   <= '0';
      address_on_delay_wren <= '0';
      resync_req_wren       <= '0';
      init_window_req_wren  <= '0';
      
      case current_state is         
         when IDLE  =>                   
            ack_o <= '0';
            
         when WR =>
            ack_o <= '1';
            if(stb_i = '1') then
               if(addr_i = ROW_LEN_ADDR) then
                  row_length_wren       <= '1';
               elsif(addr_i = NUM_ROWS_ADDR) then
                  num_rows_wren         <= '1';
               elsif(addr_i = SAMPLE_DLY_ADDR) then
                  sample_delay_wren     <= '1';
               elsif(addr_i = SAMPLE_NUM_ADDR) then
                  sample_num_wren       <= '1';
               elsif(addr_i = FB_DLY_ADDR) then
                  feedback_delay_wren   <= '1';
               elsif(addr_i = ROW_DLY_ADDR) then
                  address_on_delay_wren <= '1';
               elsif(addr_i = RESYNC_ADDR) then
                  resync_req_wren       <= '1';
               elsif(addr_i = FLX_LP_INIT_ADDR) then
                  init_window_req_wren  <= '1';
               end if;
            end if;
         
         when RD =>
            ack_o <= '1';
         
         when others =>
         
      end case;
   end process state_out;

------------------------------------------------------------
--  Wishbone interface: 
--  constant ROW_LEN_ADDR      
--  constant NUM_ROWS_ADDR     
--  constant SAMPLE_DLY_ADDR   
--  constant SAMPLE_NUM_ADDR   
--  constant FB_DLY_ADDR       
--  constant ROW_DLY_ADDR      
--  constant RESYNC_ADDR       
--  constant FLX_LP_INIT_ADDR  
------------------------------------------------------------
  
   with addr_i select dat_o <=
      row_length_data       when ROW_LEN_ADDR,
      num_rows_data         when NUM_ROWS_ADDR,
      sample_delay_data     when SAMPLE_DLY_ADDR,
      sample_num_data       when SAMPLE_NUM_ADDR,
      feedback_delay_data   when FB_DLY_ADDR,
      address_on_delay_data when ROW_DLY_ADDR,
      resync_req_data       when RESYNC_ADDR,
      init_window_req_data  when FLX_LP_INIT_ADDR,
      (others => '0') when others;
   
   master_wait <= '1' when ( stb_i = '0' and cyc_i = '1') else '0';   
           
   rd_cmd  <= '1' when 
      (stb_i = '1' and cyc_i = '1' and we_i = '0') and 
      (addr_i = ROW_LEN_ADDR or addr_i = NUM_ROWS_ADDR or addr_i = SAMPLE_DLY_ADDR or addr_i = SAMPLE_NUM_ADDR or 
       addr_i = FB_DLY_ADDR  or addr_i = ROW_DLY_ADDR  or addr_i = RESYNC_ADDR     or addr_i = FLX_LP_INIT_ADDR) else '0'; 
      
   wr_cmd  <= '1' when 
      (stb_i = '1' and cyc_i = '1' and we_i = '1') and 
      (addr_i = ROW_LEN_ADDR or addr_i = NUM_ROWS_ADDR or addr_i = SAMPLE_DLY_ADDR or addr_i = SAMPLE_NUM_ADDR or 
       addr_i = FB_DLY_ADDR  or addr_i = ROW_DLY_ADDR  or addr_i = RESYNC_ADDR     or addr_i = FLX_LP_INIT_ADDR) else '0'; 
      
end rtl;