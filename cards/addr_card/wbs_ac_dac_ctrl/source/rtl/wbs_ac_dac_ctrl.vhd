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
-- $Id: wbs_ac_dac_ctrl.vhd,v 1.4 2004/11/04 00:08:18 bburger Exp $
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
-- $Log: wbs_ac_dac_ctrl.vhd,v $
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

library components;
use components.component_pack.all;

library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;

library work;
use work.wbs_ac_dac_ctrl_pack.all;

entity wbs_ac_dac_ctrl is        
   port
   (
      -- ac_dac_ctrl interface:
      on_off_addr_i  : in std_logic_vector(ROW_ADDR_WIDTH-1 downto 0);
      dac_id_o       : out std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
      on_data_o      : out std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
      off_data_o     : out std_logic_vector(PACKET_WORD_WIDTH-1 downto 0); 
      mux_en_o       : out std_logic;

      -- global interface
      clk_i          : in std_logic;
      mem_clk_i      : in std_logic;
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
end wbs_ac_dac_ctrl;

architecture rtl of wbs_ac_dac_ctrl is

   -- FSM inputs
   signal wr_cmd           : std_logic;
   signal rd_cmd           : std_logic;
   signal master_wait      : std_logic;

   -- RAM/Register signals
   signal on_val_wren      : std_logic;   
   signal off_val_wren     : std_logic;
   signal row_order_wren   : std_logic;
   signal logical_addr     : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal mux_en_wren      : std_logic;
   signal mux_en_data      : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal on_data          : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal off_data         : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   signal row_order_data   : std_logic_vector(WB_DATA_WIDTH-1 downto 0);
   
   -- WBS states:
   type states is (IDLE, WR, WR_ACK, WR_NXT, RD, RD_MEM1, RD_ACK, RD_NXT); 
   signal current_state    : states;
   signal next_state       : states;
   
begin

   on_ram : tpram_32bit_x_64
      port map
      (
         data              => dat_i,
         wren              => on_val_wren,
         wraddress         => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         rdaddress_a       => logical_addr(ROW_ADDR_WIDTH-1 downto 0),
         rdaddress_b       => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         clock             => mem_clk_i,
         qa                => on_data_o,
         qb                => on_data
      );   
   
   off_ram : tpram_32bit_x_64
      port map
      (
         data              => dat_i,
         wren              => off_val_wren,
         wraddress         => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         rdaddress_a       => logical_addr(ROW_ADDR_WIDTH-1 downto 0),
         rdaddress_b       => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         clock             => mem_clk_i,
         qa                => off_data_o,
         qb                => off_data
      );
      
   dac_id_o <= logical_addr;
   row_order_ram : tpram_32bit_x_64
      port map
      (
         data              => dat_i,
         wren              => row_order_wren,
         wraddress         => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,         
         rdaddress_a       => on_off_addr_i,
         rdaddress_b       => tga_i(ROW_ADDR_WIDTH-1 downto 0), --raw_addr_counter,
         clock             => mem_clk_i,
         qa                => logical_addr,
         qb                => row_order_data
      );

   mux_en_o <= mux_en_data(0);
   mux_en_reg : reg
      generic map(
         WIDTH             => PACKET_WORD_WIDTH
      )
      port map(
         clk_i             => mem_clk_i,
         rst_i             => rst_i,
         ena_i             => mux_en_wren,
         reg_i             => dat_i,
         reg_o             => mux_en_data
      );


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
      on_val_wren    <= '0';
      off_val_wren   <= '0';
      mux_en_wren    <= '0';
      row_order_wren <= '0';
      ack_o          <= '0';
      
      case current_state is         
         when IDLE  =>                   
            ack_o <= '0';
            
         when WR =>
            ack_o <= '1';
            if(stb_i = '1') then
               if(addr_i = ON_BIAS_ADDR) then
                  on_val_wren <= '1';
               elsif(addr_i = OFF_BIAS_ADDR) then
                  off_val_wren <= '1';
               elsif(addr_i = ENBL_MUX_ADDR) then
                  mux_en_wren <= '1';
               elsif(addr_i = ROW_ORDER_ADDR) then
                  row_order_wren <= '1';
               end if;
            end if;
         
         when RD =>
            ack_o <= '1';
         
         when others =>
         
      end case;
   end process state_out;

------------------------------------------------------------
--  Wishbone interface 
------------------------------------------------------------
   
   with addr_i select dat_o <=
      on_data         when ON_BIAS_ADDR,
      off_data        when OFF_BIAS_ADDR,
      mux_en_data     when ENBL_MUX_ADDR,
      row_order_data  when ROW_ORDER_ADDR,
      (others => '0') when others;
   
   master_wait <= '1' when ( stb_i = '0' and cyc_i = '1') else '0';   
           
   rd_cmd  <= '1' when 
      (stb_i = '1' and cyc_i = '1' and we_i = '0') and 
      (addr_i = ON_BIAS_ADDR or addr_i = OFF_BIAS_ADDR or addr_i = ENBL_MUX_ADDR or addr_i = ROW_ORDER_ADDR) else '0'; 
      
   wr_cmd  <= '1' when 
      (stb_i = '1' and cyc_i = '1' and we_i = '1') and 
      (addr_i = ON_BIAS_ADDR or addr_i = OFF_BIAS_ADDR or addr_i = ENBL_MUX_ADDR or addr_i = ROW_ORDER_ADDR) else '0'; 
      
end rtl;