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
-- Author:        Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- LVDS transmit module (LVDS wrapper for async_tx)
--
-- Revision history:
-- 
-- $Log: lvds_tx.vhd,v $
-- Revision 1.13  2005/01/11 02:39:03  erniel
-- removed async_tx instantiation
-- removed comm_clk and mem_clk
-- modified transmitter datapath (based on async_tx datapath)
-- modified transmitter control
--
-- Revision 1.12  2005/01/05 23:33:50  erniel
-- updated async_tx component
--
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
     rst_i      : in std_logic;
     
     dat_i      : in std_logic_vector(31 downto 0);
     rdy_i      : in std_logic;
     busy_o     : out std_logic;
     
     lvds_o     : out std_logic);
end lvds_tx;

architecture rtl of lvds_tx is

signal bit_count     : integer range 0 to 67;
signal bit_count_ena : std_logic;
signal bit_count_clr : std_logic;

signal buf_data : std_logic_vector(31 downto 0);
signal buf_read : std_logic;
signal buf_empty : std_logic;
signal buf_full : std_logic;

signal tx_ena  : std_logic;
signal tx_ld   : std_logic;
signal tx_bit  : std_logic;
signal tx_data : std_logic_vector(33 downto 0);

type states is (IDLE, SETUP, SEND, DONE);
signal pres_state : states;
signal next_state : states;

begin

   bit_counter: counter
   generic map(MAX => 67,
               WRAP_AROUND => '0')
   port map(clk_i   => clk_i,
            rst_i   => rst_i,
            ena_i   => bit_count_ena,
            load_i  => bit_count_clr,
            count_i => 0,
            count_o => bit_count);
            
   data_buffer: fifo
   generic map(DATA_WIDTH => 32,
               ADDR_WIDTH => 4)
   port map(clk_i     => clk_i,
            rst_i     => rst_i,
            data_i    => dat_i,
            data_o    => buf_data,
            read_i    => buf_read,
            write_i   => rdy_i,
            clear_i   => '0',
            empty_o   => buf_empty,
            full_o    => buf_full,
            error_o   => open,
            used_o    => open);
   
   busy_o <= buf_full;
   
   tx_buffer: shift_reg
   generic map(WIDTH => 34)
   port map(clk_i      => clk_i,
            rst_i      => rst_i,
            ena_i      => tx_ena,
            load_i     => tx_ld,
            clr_i      => '0',
            shr_i      => '1',
            serial_i   => '1',
            serial_o   => tx_bit,
            parallel_i => tx_data,
            parallel_o => open);
           
   tx_data <= '1' & buf_data & '0';           
           
   stateFF: process(rst_i, clk_i)
   begin
      if(rst_i = '1') then
         pres_state <= IDLE;
      elsif(clk_i'event and clk_i = '1') then
         pres_state <= next_state;
      end if;
   end process stateFF;
   
   stateNS: process(pres_state, buf_empty, bit_count)
   begin
      case pres_state is
         when IDLE =>  if(buf_empty = '0') then
                          next_state <= SETUP;
                       else
                          next_state <= IDLE;
                       end if;
         
         when SETUP => next_state <= SEND;
         
         when SEND =>  if(bit_count = 67) then
                          next_state <= DONE;
                       else
                          next_state <= SEND;
                       end if;
         
         when DONE =>  next_state <= IDLE;
      end case;
   end process stateNS;
                         
   stateOut: process(pres_state, bit_count, tx_bit)
   begin
      bit_count_ena <= '0';
      bit_count_clr <= '0';
      buf_read      <= '0';
      tx_ena        <= '0';
      tx_ld         <= '0';
      lvds_o        <= '1';
            
      case pres_state is
         when IDLE =>  bit_count_ena <= '1';
                       bit_count_clr <= '1';
                       
         when SETUP => tx_ena        <= '1';
                       tx_ld         <= '1';
         
         when SEND =>  bit_count_ena <= '1';
                       if(bit_count = 1  or bit_count = 3  or bit_count = 5  or bit_count = 7  or bit_count = 9  or
                          bit_count = 11 or bit_count = 13 or bit_count = 15 or bit_count = 17 or bit_count = 19 or
                          bit_count = 21 or bit_count = 23 or bit_count = 25 or bit_count = 27 or bit_count = 29 or
                          bit_count = 31 or bit_count = 33 or bit_count = 35 or bit_count = 37 or bit_count = 39 or
                          bit_count = 41 or bit_count = 43 or bit_count = 45 or bit_count = 47 or bit_count = 49 or
                          bit_count = 51 or bit_count = 53 or bit_count = 55 or bit_count = 57 or bit_count = 59 or
                          bit_count = 61 or bit_count = 63 or bit_count = 65 or bit_count = 67) then tx_ena <= '1';
                       end if;
                       lvds_o <= tx_bit;                      
         
         when DONE =>  buf_read      <= '1';
      end case;
   end process stateOut;
   
end rtl;