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
-- $Id: ret_dat_wbs.vhd,v 1.5 2006/03/09 01:27:21 bburger Exp $
--
-- Project:       SCUBA2
-- Author:        Bryce Burger
-- Organisation:  UBC
--
-- Description:
--
-- Revision history:
-- $Log: ret_dat_wbs.vhd,v $
-- Revision 1.5  2006/03/09 01:27:21  bburger
-- Bryce:
-- - ret_dat_wbs no longer clamps the data_rate
-- - ret_dat_wbs_pack defines a default data rate of ~200Hz based on row_len=120 and num_rows=41
--
-- Revision 1.4  2006/01/16 18:00:44  bburger
-- Bryce:  Adjusted the upper and lower bounds for data_rate, and added a default value of 0x5F = 95 = data at 200 Hz based on 50 Mhz/41rows/64cycles per row
--
-- Revision 1.3  2005/07/23 01:39:25  bburger
-- Bryce:
-- Added a wishbone-accessible register to change the data rate.  The register default is one frame of data every ten frames (maximum rate).
-- Disabled internal commanding
--
-- Revision 1.2  2005/03/19 00:31:23  bburger
-- bryce:  Fixed several bugs.  Tagging cc_01010007.
--
-- Revision 1.1  2005/03/05 01:31:36  bburger
-- Bryce:  New
--
--
-----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library components;
use components.component_pack.all;

library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;

library work;
use work.ret_dat_wbs_pack.all;
use work.sync_gen_pack.all;

entity ret_dat_wbs is        
   port
   (
      -- cmd_translator interface:
      start_seq_num_o : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      stop_seq_num_o  : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      data_rate_o     : out std_logic_vector(SYNC_NUM_WIDTH-1 downto 0);
      ret_dat_req_o   : out std_logic;
      ret_dat_ack_i   : in std_logic;

      -- global interface
      clk_i          : in std_logic;
      rst_i          : in std_logic; 
      
      -- wishbone interface:
      dat_i          : in std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      addr_i         : in std_logic_vector(WB_ADDR_WIDTH-1 downto 0);
      tga_i          : in std_logic_vector(WB_TAG_ADDR_WIDTH-1 downto 0);
      we_i           : in std_logic;
      stb_i          : in std_logic;
      cyc_i          : in std_logic;
      dat_o          : out std_logic_vector(WB_DATA_WIDTH-1 downto 0);
      ack_o          : out std_logic
   );     
end ret_dat_wbs;

architecture rtl of ret_dat_wbs is

   -- FSM inputs
   signal wr_cmd            : std_logic;
   signal rd_cmd            : std_logic;
   signal master_wait       : std_logic;

   -- RAM/Register signals
   signal start_wren        : std_logic;   
   signal stop_wren         : std_logic;
   signal data_rate_wren    : std_logic;
   
   signal start_data        : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal stop_data         : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal data_rate_data    : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   
   signal data_req          : std_logic;
   
   -- WBS states:
   type states is (IDLE, WR, RD); 
   signal current_state     : states;
   signal next_state        : states;
   
begin

   start_seq_num_o <= start_data;
   start_reg : reg
      generic map(
         WIDTH             => WB_DATA_WIDTH
      )
      port map(
         clk_i             => clk_i,
         rst_i             => rst_i,
         ena_i             => start_wren,
         reg_i             => dat_i,
         reg_o             => start_data
      );

   stop_seq_num_o <= stop_data;
   stop_reg : reg
      generic map(
         WIDTH             => WB_DATA_WIDTH
      )
      port map(
         clk_i             => clk_i,
         rst_i             => rst_i,
         ena_i             => stop_wren,
         reg_i             => dat_i,
         reg_o             => stop_data
      );

   -- Custom register that gets set to DEF_DATA_RATE upon reset
   data_rate_o <= data_rate_data(SYNC_NUM_WIDTH-1 downto 0);
   data_rate_reg: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         data_rate_data <= DEF_DATA_RATE;
      elsif(clk_i'event and clk_i = '1') then
         if(data_rate_wren = '1') then
            data_rate_data <= dat_i;
         end if;
      end if;
   end process data_rate_reg;

   -- Custom register that indicates fresh ret_dat commands
   ret_dat_req_o <= data_req;
   data_req_reg: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         data_req <= '0';
      elsif(clk_i'event and clk_i = '1') then
         if(stb_i = '1' and cyc_i = '1' and we_i = '1' and addr_i = RET_DAT_S_ADDR) then
            data_req <= '1';
         elsif(ret_dat_ack_i = '1') then
            data_req <= '0';
         else
            data_req <= data_req;
         end if;
      end if;
   end process data_req_reg;
      
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
   state_out: process(current_state, stb_i, addr_i, tga_i, next_state)
   begin
      -- Default assignments
      start_wren      <= '0';
      stop_wren       <= '0';
      data_rate_wren  <= '0';
      ack_o           <= '0';
     
      case current_state is         
         when IDLE  =>                   
            ack_o <= '0';
            
         when WR =>
            if(stb_i = '1') then
               if(addr_i = RET_DAT_S_ADDR) then
                  if(tga_i = x"00000000") then
                     start_wren  <= '1';
                     ack_o <= '1';
                  else
                     stop_wren   <= '1';
                     ack_o <= '1';
                  end if;
               elsif(addr_i = DATA_RATE_ADDR) then
                  data_rate_wren <= '1';
                  ack_o <= '1';
               end if;
            end if;
         
         when RD =>
            if(next_state /= IDLE) then
               ack_o <= '1';
            end if;
         
         when others =>
         
      end case;
   end process state_out;


------------------------------------------------------------
--  Wishbone interface 
------------------------------------------------------------
   
   dat_o <= 
      start_data     when (addr_i = RET_DAT_S_ADDR and tga_i = x"00000000") else
      stop_data      when (addr_i = RET_DAT_S_ADDR and tga_i /= x"00000000") else
      data_rate_data when (addr_i = DATA_RATE_ADDR) else (others => '0');
   
   master_wait <= '1' when (stb_i = '0' and cyc_i = '1') else '0';   
           
   rd_cmd  <= '1' when 
      (stb_i = '1' and cyc_i = '1' and we_i = '0') and 
      (addr_i = RET_DAT_S_ADDR or addr_i = DATA_RATE_ADDR) else '0'; 
      
   wr_cmd  <= '1' when 
      (stb_i = '1' and cyc_i = '1' and we_i = '1') and 
      (addr_i = RET_DAT_S_ADDR or addr_i = DATA_RATE_ADDR) else '0'; 
      
end rtl;