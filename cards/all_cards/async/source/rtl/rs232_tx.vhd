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
-- Revision 1.1  2004/06/18 22:14:24  erniel
-- initial version
--
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity rs232_tx is
port(clk_i      : in std_logic;
     comm_clk_i : in std_logic;
     rst_i      : in std_logic;
     
     dat_i      : in std_logic_vector(7 downto 0);
     start_i    : in std_logic;
     done_o     : out std_logic;
     
     rs232_o    : out std_logic);
end rs232_tx;

architecture rtl of rs232_tx is
component async_tx
port(tx_clk_i : in std_logic;
     rst_i    : in std_logic;

     dat_i    : in std_logic_vector (7 downto 0);
     stb_i    : in std_logic;
     tx_o     : out std_logic;
     busy_o   : out std_logic);
end component;

signal tx_clk_divide : integer range 0 to 1736;
signal tx_clk : std_logic;
signal tx_data : std_logic_vector(7 downto 0);
signal tx_rdy : std_logic;
signal tx_busy : std_logic;

type states is (IDLE, TX, TXBUSY, DONE);
signal pres_state : states;
signal next_state : states;

begin

   transmit: async_tx
   port map(tx_clk_i => tx_clk,
            rst_i    => rst_i,
            dat_i    => tx_data,
            stb_i    => tx_rdy,
            tx_o     => rs232_o,
            busy_o   => tx_busy);

   clk_divide: process(rst_i, comm_clk_i)
   begin
      if(rst_i = '1') then
         tx_clk_divide <= 0;
      elsif(comm_clk_i'event and comm_clk_i = '1') then
         if(tx_clk_divide = 1735) then
            tx_clk_divide <= 0;
         else
            tx_clk_divide <= tx_clk_divide + 1;
         end if;
      end if;
   end process clk_divide;
   
   tx_clk <= '1' when tx_clk_divide = 1735 else '0';   -- 200 MHz input clock divided by 1736 = 115.2 kHz
   
   stateFF: process(rst_i, clk_i)
   begin
      if(rst_i = '1') then
         pres_state <= IDLE;
      elsif(clk_i'event and clk_i = '1') then
         pres_state <= next_state;
      end if;
   end process stateFF;
   
   stateNS: process(pres_state, start_i, tx_busy)
   begin
      case pres_state is
         when IDLE =>   if(start_i = '1') then
                           next_state <= TX;
                        else
                           next_state <= IDLE;
                        end if;
                         
         when TX =>     if(tx_busy = '1') then       -- wait until transmitter has started to transmit
                           next_state <= TXBUSY;
                        else
                           next_state <= TX;
                        end if;
                         
         when TXBUSY => if(tx_busy = '0') then       -- when transmitter signals byte complete, finish.
                           next_state <= DONE;
                        else
                           next_state <= TXBUSY;   
                        end if; 
                        
         when DONE =>   next_state <= IDLE;          -- signal done, then return to idle
      end case;
   end process stateNS;
   
   stateOut: process(pres_state, dat_i)
   begin
      case pres_state is
         when IDLE =>   tx_data <= dat_i;
                        tx_rdy <= '0';
                        done_o <= '0';
                                                 
         when TX =>     tx_rdy <= '1';
                        done_o <= '0';
                                                 
         when TXBUSY => tx_rdy <= '0';
                        done_o <= '0';
                        
         when DONE =>   tx_rdy <= '0';
                        done_o <= '1';
                        
      end case;
   end process stateOut;
                 
end rtl;