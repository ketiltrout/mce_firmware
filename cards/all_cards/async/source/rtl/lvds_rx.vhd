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
-- lvds_rx.vhd
--
-- Project:       SCUBA-2
-- Author:         Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- LVDS receive module (LVDS wrapper for async_rx)
--
-- Revision history:
-- 
-- $Log: lvds_rx.vhd,v $
-- Revision 1.5  2004/12/15 01:55:48  erniel
-- removed clock divider logic (moved to async_rx)
-- modified buffering to allow word to persist until next word ready
-- reworked FSM to handle new async_rx interface
--
-- Revision 1.4  2004/08/25 22:16:40  bburger
-- Bryce:  changed int_zero from signal to constant
--
-- Revision 1.3  2004/08/24 23:53:23  bburger
-- Bryce:  bug fix - added a signal call int_zero for portmaps to counters
--
-- Revision 1.2  2004/08/06 20:39:30  erniel
-- replaced some processes with rtl-blocks
-- added data buffer registers
--
-- Revision 1.1  2004/06/17 01:25:41  erniel
-- initial version
--
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library components;
use components.component_pack.all;

entity lvds_rx is
port(clk_i      : in std_logic;
     comm_clk_i : in std_logic;
     rst_i      : in std_logic;
     
     dat_o      : out std_logic_vector(31 downto 0);
     rdy_o      : out std_logic;
     ack_i      : in std_logic;
     
     lvds_i     : in std_logic);
end lvds_rx;

architecture rtl of lvds_rx is

component async_rx
generic(CLK_DIV_FACTOR : integer := 2);
port(comm_clk_i : in std_logic;
     rst_i      : in std_logic;
     
     dat_o : out std_logic_vector (7 downto 0);
     rdy_o : out std_logic;
     ack_i : in std_logic;

     rx_i : in std_logic);
end component;

signal rx_data : std_logic_vector(7 downto 0);
signal rx_rdy  : std_logic;
signal rx_ack  : std_logic;

signal byte_count     : integer range 0 to 3;
signal byte_count_ena : std_logic;
signal byte_count_clr : std_logic;

signal temp_data     : std_logic_vector(23 downto 0);
signal temp_byte0_ld : std_logic;
signal temp_byte1_ld : std_logic;
signal temp_byte2_ld : std_logic;

signal data_out    : std_logic_vector(31 downto 0);
signal data_out_ld : std_logic;

type states is (IDLE, RECV, LATCH, ACK, READY, DONE);
signal pres_state : states;
signal next_state : states;

begin

   receive: async_rx
   generic map(CLK_DIV_FACTOR => 2)
   port map(comm_clk_i => comm_clk_i,  
            rst_i      => rst_i,
            dat_o      => rx_data,
            rdy_o      => rx_rdy,
            ack_i      => rx_ack,
            rx_i       => lvds_i);
    
   byte_counter: counter
   generic map(MAX => 3,
               WRAP_AROUND => '0')
   port map(clk_i   => clk_i,
            rst_i   => rst_i,
            ena_i   => byte_count_ena,
            load_i  => byte_count_clr,
            count_i => 0,
            count_o => byte_count);
            
   temp_byte0: reg
   generic map(WIDTH => 8)
   port map(clk_i  => clk_i,
            rst_i  => rst_i,
            ena_i  => temp_byte0_ld,
 
            reg_i  => rx_data,
            reg_o  => temp_data(7 downto 0));

   temp_byte1: reg
   generic map(WIDTH => 8)
   port map(clk_i  => clk_i,
            rst_i  => rst_i,
            ena_i  => temp_byte1_ld,
 
            reg_i  => rx_data,
            reg_o  => temp_data(15 downto 8));
            
   temp_byte2: reg
   generic map(WIDTH => 8)
   port map(clk_i  => clk_i,
            rst_i  => rst_i,
            ena_i  => temp_byte2_ld,
 
            reg_i  => rx_data,
            reg_o  => temp_data(23 downto 16));
            
   rx_buffer: reg
   generic map(WIDTH => 32)
   port map(clk_i  => clk_i,
            rst_i  => rst_i,
            ena_i  => data_out_ld,
 
            reg_i  => data_out,
            reg_o  => dat_o);
            
   data_out <= rx_data & temp_data;
   
   stateFF: process(rst_i, clk_i)
   begin
      if(rst_i = '1') then
         pres_state <= IDLE;
      elsif(clk_i'event and clk_i = '1') then
         pres_state <= next_state;
      end if;
   end process stateFF;
   
   stateNS: process(pres_state, rx_rdy, ack_i, byte_count)
   begin
      case pres_state is
         when IDLE =>   next_state <= RECV;
                        
         when RECV =>   if(rx_rdy = '1') then
                           next_state <= LATCH;
                        else
                           next_state <= RECV;
                        end if;
         
         when LATCH =>  next_state <= ACK;
                             
         when ACK =>    if(byte_count = 3) then
                           next_state <= READY;       
                        else
                           next_state <= RECV;
                        end if;
                        
         when READY =>  if(ack_i = '1') then
                           next_state <= DONE;
                        else
                           next_state <= READY;
                        end if;
                        
         when DONE =>   if(rx_rdy = '0') then          
                           next_state <= IDLE;
                        else
                           next_state <= DONE;
                        end if;
      end case;
   end process stateNS;
   
   stateOut: process(pres_state, byte_count)
   begin
      rx_ack         <= '0';
      temp_byte0_ld  <= '0';
      temp_byte1_ld  <= '0';
      temp_byte2_ld  <= '0';
      data_out_ld    <= '0';
      byte_count_ena <= '0';
      byte_count_clr <= '0';
      rdy_o          <= '0';
      
      case pres_state is
         when IDLE =>   byte_count_ena <= '1';
                        byte_count_clr <= '1';
                        
         when LATCH =>  case byte_count is
                           when 0 => temp_byte0_ld <= '1';
                           when 1 => temp_byte1_ld <= '1';
                           when 2 => temp_byte2_ld <= '1';
                           when others => data_out_ld <= '1';
                        end case;
         
         when ACK =>    rx_ack <= '1';
                        byte_count_ena <= '1';
         
         when READY =>  rdy_o <= '1';
                        
         when others => null;
      end case;
   end process stateOut;

end rtl;