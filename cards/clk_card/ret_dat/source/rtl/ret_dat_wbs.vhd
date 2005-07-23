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
-- $Id: ret_dat_wbs.vhd,v 1.2 2005/03/19 00:31:23 bburger Exp $
--
-- Project:       SCUBA2
-- Author:        Bryce Burger
-- Organisation:  UBC
--
-- Description:
--
-- Revision history:
-- $Log: ret_dat_wbs.vhd,v $
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
   signal clamped_rate_data : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   
   -- WBS states:
   type states is (IDLE, WR, RD1, RD2, WR_START, WR_STOP, WR_RATE, RD_START, RD_STOP, RD_RATE); 
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

--   data_rate_o <= 
--      MAX_DATA_RATE(15 downto 0) when data_rate_data < MAX_DATA_RATE else 
--      MIN_DATA_RATE(15 downto 0) when data_rate_data > MIN_DATA_RATE else
--      data_rate_data(15 downto 0);
--
--   data_rate_reg : reg
--      generic map(
--         WIDTH             => WB_DATA_WIDTH
--      )
--      port map(
--         clk_i             => clk_i,
--         rst_i             => rst_i,
--         ena_i             => data_rate_wren,
--         reg_i             => dat_i,
--         reg_o             => data_rate_data
--      );
      
   -- Custom register that gets set to MAX_DATA_RATE upon reset
   data_rate_o <= data_rate_data(15 downto 0);
   data_rate_reg: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         data_rate_data <= MAX_DATA_RATE;
      elsif(clk_i'event and clk_i = '1') then
         if(data_rate_wren = '1') then
            if(dat_i < MAX_DATA_RATE) then
               data_rate_data <= MAX_DATA_RATE;
            elsif(dat_i > MIN_DATA_RATE) then
               data_rate_data <= MIN_DATA_RATE;
            else
               data_rate_data <= dat_i;
            end if;
         end if;
      end if;
   end process data_rate_reg;
      

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
   state_NS: process(current_state, rd_cmd, wr_cmd, cyc_i, addr_i)
   begin
      -- Default assignments
      next_state <= current_state;
      
      case current_state is
         when IDLE =>
            if(wr_cmd = '1' and addr_i = RET_DAT_S_ADDR) then
               next_state <= WR_STOP;            
            elsif(wr_cmd = '1' and addr_i = DATA_RATE_ADDR) then
               next_state <= IDLE;
            elsif(rd_cmd = '1' and addr_i = RET_DAT_S_ADDR) then
               next_state <= RD_STOP;
            elsif(rd_cmd = '1' and addr_i = DATA_RATE_ADDR) then
               next_state <= IDLE;
            else
               next_state <= IDLE;
            end if;                  
            
--         when WR_START =>     
--            if(cyc_i = '0') then
--               next_state <= IDLE;
--            else
--               next_state <= WR_STOP;
--            end if;
            
         when WR_STOP =>
            if(cyc_i = '0') then
               next_state <= IDLE;
            else
               next_state <= WR_STOP;
            end if;
            
         when WR_RATE =>
            if(cyc_i = '0') then 
               next_state <= IDLE;
            else
               next_state <= WR_RATE;
            end if;
            
--         when RD_START =>
--            if(cyc_i = '0') then
--               next_state <= IDLE;
--            else
--               next_state <= RD_STOP;
--            end if;

         when RD_STOP =>
            if(cyc_i = '0') then
               next_state <= IDLE;
            else
              next_state <= RD_STOP;
            end if;
         
--         when RD_RATE =>
--            if(cyc_i = '0') then
--               next_state <= IDLE;
--            else
--              next_state <= RD_RATE;
--            end if;

         when others =>
            next_state <= IDLE;

      end case;
   end process state_NS;
   
   -- Output states for DAC controller   
   state_out: process(current_state, stb_i, wr_cmd, addr_i, rd_cmd)
   begin
      -- Default assignments
      start_wren      <= '0';
      stop_wren       <= '0';
      data_rate_wren  <= '0';
      ack_o           <= '0';
      
      case current_state is         
         
         when IDLE  =>                   
            if(wr_cmd = '1' and addr_i = RET_DAT_S_ADDR) then
               ack_o          <= '1';
               start_wren     <= '1';
            elsif(wr_cmd = '1' and addr_i = DATA_RATE_ADDR) then
               ack_o          <= '1';
               data_rate_wren <= '1';
            elsif(rd_cmd = '1') then
               ack_o          <= '1';
            end if;
            
         when WR_START =>
            ack_o <= '1';
            if(stb_i = '1') then
               start_wren <= '1';
            end if;
         
         when WR_STOP =>
            ack_o <= '1';
            if(stb_i = '1') then
               stop_wren <= '1';
            end if;

         when WR_RATE =>
            ack_o <= '1';
            if(stb_i = '1') then
               data_rate_wren <= '1';
            end if;

--         when RD_START =>
--            ack_o <= '1';

         when RD_STOP =>
            ack_o <= '1';

--         when RD_RATE =>
--            ack_o <= '1';
         
         when others =>
         
      end case;
   end process state_out;

------------------------------------------------------------
--  Wishbone interface 
------------------------------------------------------------
   
--   with current_state select dat_o <=
--      start_data      when RD_START,
--      stop_data       when RD_STOP,
--      data_rate_data  when RD_RATE,
--      (others => '0') when others;
   
   dat_o <= 
      start_data     when (addr_i = RET_DAT_S_ADDR and current_state = IDLE) else
      stop_data      when (addr_i = RET_DAT_S_ADDR and current_state = RD_STOP) else
      data_rate_data when (addr_i = DATA_RATE_ADDR and current_state = IDLE) else (others => '0');
   
   master_wait <= '1' when (stb_i = '0' and cyc_i = '1') else '0';   
           
   rd_cmd  <= '1' when 
      (stb_i = '1' and cyc_i = '1' and we_i = '0') and 
      (addr_i = RET_DAT_S_ADDR or addr_i = DATA_RATE_ADDR) else '0'; 
      
   wr_cmd  <= '1' when 
      (stb_i = '1' and cyc_i = '1' and we_i = '1') and 
      (addr_i = RET_DAT_S_ADDR or addr_i = DATA_RATE_ADDR) else '0'; 
      
end rtl;