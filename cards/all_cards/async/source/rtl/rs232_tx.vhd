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
     mem_clk_i  : in std_logic;
     comm_clk_i : in std_logic;
     rst_i      : in std_logic;
     
     dat_i      : in std_logic_vector(7 downto 0);
     rdy_i      : in std_logic;
     busy_o     : out std_logic;
     
     rs232_o    : out std_logic);
end rs232_tx;

architecture rtl of rs232_tx is

component async_tx
generic(CLK_DIV_FACTOR : in integer := 8);
port(comm_clk_i : in std_logic;
     rst_i      : in std_logic;

     dat_i  : in std_logic_vector (7 downto 0);
     rdy_i  : in std_logic;
     busy_o : out std_logic;

     tx_o   : out std_logic);
end component;

signal tx_data : std_logic_vector(7 downto 0);
signal tx_rdy : std_logic;
signal tx_busy : std_logic;

signal buf_read  : std_logic;
signal buf_empty : std_logic;
signal buf_full  : std_logic;

type states is (IDLE, SEND, BUSY, SETUP);
signal pres_state : states;
signal next_state : states;

begin

   transmit: async_tx
   generic map(CLK_DIV_FACTOR => 868)
   port map(comm_clk_i => comm_clk_i,
            rst_i      => rst_i,
            dat_i      => tx_data,
            rdy_i      => tx_rdy,
            busy_o     => tx_busy,
            tx_o       => rs232_o);
  
   tx_buffer: fifo
   generic map(DATA_WIDTH => 8,
               ADDR_WIDTH => 6)
   port map(clk_i     => clk_i,
            mem_clk_i => mem_clk_i,
            rst_i     => rst_i,
            data_i    => dat_i,
            data_o    => tx_data,
            read_i    => buf_read,
            write_i   => rdy_i,
            clear_i   => '0',
            empty_o   => buf_empty,
            full_o    => buf_full,
            used_o    => open);

   busy_o <= buf_full;

   stateFF: process(rst_i, clk_i)
   begin
      if(rst_i = '1') then
         pres_state <= IDLE;
      elsif(clk_i'event and clk_i = '1') then
         pres_state <= next_state;
      end if;
   end process stateFF;
   
   stateNS: process(pres_state, buf_empty, tx_busy)
   begin
      case pres_state is
         when IDLE =>   if(buf_empty = '0') then
                           next_state <= SEND;
                        else
                           next_state <= IDLE;
                        end if;

         when SEND => if(tx_busy = '1') then
                         next_state <= BUSY;
                      else
                         next_state <= SEND;
                      end if;

         when BUSY => if(tx_busy = '0') then
                         if(buf_empty = '1') then
                            next_state <= IDLE;
                         else
                            next_state <= SETUP;
                         end if;
                      else
                         next_state <= BUSY;
                      end if;

         when SETUP => next_state <= IDLE;

      end case;
   end process stateNS;
   
   stateOut: process(pres_state)
   begin
      tx_rdy   <= '0';
      buf_read <= '0';

      case pres_state is                                                          
         when SEND =>   tx_rdy   <= '1';

         when SETUP =>  buf_read <= '1';
     
         when others => null;                        
      end case;
   end process stateOut;
                 
end rtl;