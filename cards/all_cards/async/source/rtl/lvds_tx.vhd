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
-- lvds_tx.vhd
--
-- Project:       SCUBA-2
-- Author:         Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- LVDS transmit module (LVDS wrapper for async_tx)
--
-- Revision history:
-- 
-- $Log: lvds_tx.vhd,v $
-- Revision 1.11  2004/12/17 20:51:07  erniel
-- revert to 200 MHz clock divider
-- WARNING: temporary solution!  Work still in progress!
--
-- Revision 1.10  2004/12/16 18:21:08  erniel
-- fixed small bug in counter
--
-- Revision 1.9  2004/12/16 18:09:32  erniel
-- fixed small bug in counter
--
-- Revision 1.8  2004/12/15 01:48:04  erniel
-- removed clock divider logic (moved to async_tx)
-- added FIFO buffer
-- reworked FSM to handle FIFO buffer
--
-- Revision 1.7  2004/09/01 17:17:01  erniel
-- added buffer_out to process sensitivity list
--
-- Revision 1.6  2004/08/27 19:31:50  erniel
-- replaced start/done with rdy/busy interface
--
-- Revision 1.5  2004/08/25 22:16:40  bburger
-- Bryce:  changed int_zero from signal to constant
--
-- Revision 1.4  2004/08/24 23:53:23  bburger
-- Bryce:  bug fix - added a signal call int_zero for portmaps to counters
--
-- Revision 1.3  2004/08/09 22:17:54  erniel
-- fixed inverted clock bug
--
-- Revision 1.2  2004/08/06 20:38:29  erniel
-- replaced some processes with rtl-blocks
-- added setup state
--
-- Revision 1.1  2004/06/17 01:25:41  erniel
-- initial version
--
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library components;
use components.component_pack.all;

entity lvds_tx is
port(clk_i      : in std_logic;
     mem_clk_i  : in std_logic;
     comm_clk_i : in std_logic;
     rst_i      : in std_logic;
     
     dat_i      : in std_logic_vector(31 downto 0);
     rdy_i      : in std_logic;
     busy_o     : out std_logic;
     
     lvds_o     : out std_logic);
end lvds_tx;

architecture rtl of lvds_tx is

component async_tx
generic(CLK_DIV_FACTOR : in integer := 8); 
port(comm_clk_i : in std_logic;
     rst_i      : in std_logic;

     dat_i    : in std_logic_vector (7 downto 0);
     rdy_i    : in std_logic;
     busy_o   : out std_logic;
     
     tx_o     : out std_logic);
end component;

signal tx_data : std_logic_vector(7 downto 0);
signal tx_rdy  : std_logic;
signal tx_busy : std_logic;

signal byte_count     : integer range 0 to 3;
signal byte_count_ena : std_logic;
signal byte_count_clr : std_logic;

signal buf_data : std_logic_vector(31 downto 0);
signal buf_read : std_logic;
signal buf_empty : std_logic;
signal buf_full : std_logic;

type states is (IDLE, SEND, BUSY, SETUP_BYTE, SETUP_WORD);
signal pres_state : states;
signal next_state : states;

begin

   transmit: async_tx
   generic map(CLK_DIV_FACTOR => 8)
   port map(comm_clk_i => comm_clk_i,
            rst_i      => rst_i,
            dat_i      => tx_data,
            rdy_i      => tx_rdy,
            busy_o     => tx_busy,
            tx_o       => lvds_o);
   
   byte_counter: counter
   generic map(MAX => 3,
               WRAP_AROUND => '0')
   port map(clk_i   => clk_i,
            rst_i   => rst_i,
            ena_i   => byte_count_ena,
            load_i  => byte_count_clr,
            count_i => 0,
            count_o => byte_count);
            
   tx_buffer: fifo
   generic map(DATA_WIDTH => 32,
               ADDR_WIDTH => 4)
   port map(clk_i     => clk_i,
            mem_clk_i => mem_clk_i,
            rst_i     => rst_i,
            data_i    => dat_i,
            data_o    => buf_data,
            read_i    => buf_read,
            write_i   => rdy_i,
            clear_i   => '0',
            empty_o   => buf_empty,
            full_o    => buf_full,
            used_o    => open);
   
   busy_o <= buf_full;
   
   with byte_count select
      tx_data <= buf_data(7 downto 0)   when 0,
                 buf_data(15 downto 8)  when 1,
                 buf_data(23 downto 16) when 2,
                 buf_data(31 downto 24) when others;
                           
   stateFF: process(rst_i, clk_i)
   begin
      if(rst_i = '1') then
         pres_state <= IDLE;
      elsif(clk_i'event and clk_i = '1') then
         pres_state <= next_state;
      end if;
   end process stateFF;

   stateNS: process(pres_state, buf_empty, tx_busy, byte_count)
   begin
      case pres_state is
         when IDLE =>       if(buf_empty = '0') then
                              next_state <= SEND;
                            else
                               next_state <= IDLE;
                            end if;
                         
         when SEND =>       if(tx_busy = '1') then
                               next_state <= BUSY;
                            else
                               next_state <= SEND;
                            end if;
                         
         when BUSY =>       if(tx_busy = '0') then
                               if(byte_count = 3) then
                                  if(buf_empty = '1') then  
                                     next_state <= IDLE;
                                  else
                                     next_state <= SETUP_WORD;
                                  end if;
                               else
                                  next_state <= SETUP_BYTE;
                               end if;
                            else
                               next_state <= BUSY;
                            end if;
         
         when SETUP_BYTE => next_state <= SEND;
         
         when SETUP_WORD => next_state <= IDLE;
      end case;
   end process stateNS;

   stateOut: process(pres_state)
   begin
      tx_rdy         <= '0';
      buf_read       <= '0';
      byte_count_ena <= '0';
      byte_count_clr <= '0';
      
      case pres_state is                         
         when SEND =>       tx_rdy <= '1';
                        
         when SETUP_BYTE => byte_count_ena <= '1';
         
         when SETUP_WORD => byte_count_ena <= '1';
                            byte_count_clr <= '1';
                            buf_read <= '1';
         
         when others => null;                        
      end case;
   end process stateOut;
         
end rtl;