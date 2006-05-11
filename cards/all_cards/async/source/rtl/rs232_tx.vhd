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
-- rs232_tx.vhd
--
-- Project:	      SCUBA-2
-- Author:	       Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- RS232 transmit module (RS232 wrapper for async_tx)
--
-- Revision history:
-- 
-- $Log: rs232_tx.vhd,v $
-- Revision 1.4  2005/01/12 22:45:56  erniel
-- removed async_tx instantiation
-- removed comm_clk and mem_clk
-- modified transmitter datapath (based on async_tx datapath)
-- modified transmitter control
--
-- Revision 1.3  2005/01/05 23:39:50  erniel
-- updated async_tx component
--
-- Revision 1.2  2004/12/17 00:21:50  erniel
-- removed clock divider logic (moved to async_tx)
-- added FIFO buffer
-- reworked FSM to handle FIFO buffer
--
-- Revision 1.1  2004/06/18 22:14:24  erniel
-- initial version
--
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library components;
use components.component_pack.all;

entity rs232_tx is
port(clk_i      : in std_logic;
     rst_i      : in std_logic;
     
     dat_i      : in std_logic_vector(7 downto 0);
     rdy_i      : in std_logic;
     busy_o     : out std_logic;
     
     rs232_o    : out std_logic);
end rs232_tx;

architecture rtl of rs232_tx is

signal bit_count     : integer range 0 to 4339;
signal bit_count_ena : std_logic;
signal bit_count_clr : std_logic;

signal buf_data : std_logic_vector(7 downto 0);
signal buf_read : std_logic;
signal buf_empty : std_logic;
signal buf_full : std_logic;

signal tx_ena  : std_logic;
signal tx_ld   : std_logic;
signal tx_bit  : std_logic;
signal tx_data : std_logic_vector(9 downto 0);

type states is (IDLE, SETUP, SEND, DONE);
signal pres_state : states;
signal next_state : states;

begin

   bit_counter: counter
   generic map(MAX => 4339,
               WRAP_AROUND => '0')
   port map(clk_i   => clk_i,
            rst_i   => rst_i,
            ena_i   => bit_count_ena,
            load_i  => bit_count_clr,
            count_i => 0,
            count_o => bit_count);
            
   data_buffer: fifo
   generic map(DATA_WIDTH => 8,
               ADDR_WIDTH => 6)
   port map(clk_i     => clk_i,
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
   
   tx_buffer: shift_reg
   generic map(WIDTH => 10)
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
         
         when SEND =>  if(bit_count = 4339) then
                          next_state <= DONE;
                       else
                          next_state <= SEND;
                       end if;
         
         when DONE =>  next_state <= IDLE;
         
         when others => next_state <= IDLE;
         
      end case;
   end process stateNS;
                         
   stateOut: process(pres_state, bit_count, tx_bit)
   begin
      bit_count_ena <= '0';
      bit_count_clr <= '0';
      buf_read      <= '0';
      tx_ena        <= '0';
      tx_ld         <= '0';
      rs232_o        <= '1';
            
      case pres_state is
         when IDLE =>  bit_count_ena <= '1';
                       bit_count_clr <= '1';
                       
         when SETUP => tx_ena        <= '1';
                       tx_ld         <= '1';
         
         when SEND =>  bit_count_ena <= '1';
                       -- for RS232 bitrate of 115 kbps, hold each bit for 434 clk_i periods.
                       if(bit_count = 433  or bit_count = 867  or bit_count = 1301 or bit_count = 1735 or 
                          bit_count = 2169 or bit_count = 2603 or bit_count = 3037 or bit_count = 3471 or 
                          bit_count = 3905 or bit_count = 4339) then tx_ena <= '1';
                       end if;
                       rs232_o <= tx_bit;                      
         
         when DONE =>  buf_read      <= '1';
         
         when others => null;
      end case;
   end process stateOut;
   
end rtl;