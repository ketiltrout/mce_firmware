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
     comm_clk_i : in std_logic;
     rst_i      : in std_logic;
     
     dat_i      : in std_logic_vector(31 downto 0);
     rdy_i      : in std_logic;
     busy_o     : out std_logic;
     
     lvds_o     : out std_logic);
end lvds_tx;

architecture rtl of lvds_tx is
component async_tx
port(tx_clk_i : in std_logic;
     rst_i    : in std_logic;

     dat_i    : in std_logic_vector (7 downto 0);
     stb_i    : in std_logic;
     tx_o     : out std_logic;
     busy_o   : out std_logic);
end component;

type states is (IDLE, TX, TXBUSY, SETUP, DONE);
signal pres_state : states;
signal next_state : states;

signal tx_clk_divide : std_logic_vector(2 downto 0);
signal tx_clk : std_logic;

signal tx_data : std_logic_vector(7 downto 0);
signal tx_rdy : std_logic;
signal tx_busy : std_logic;

signal buffer_ena : std_logic;
signal buffer_out : std_logic_vector(31 downto 0);

signal byte_count_ena : std_logic;
signal byte_count_clr : std_logic;
signal bytes_sent     : integer range 0 to 4;

constant int_zero : integer := 0;

begin

   transmit: async_tx
   port map(tx_clk_i => tx_clk,
            rst_i    => rst_i,
            dat_i    => tx_data,
            stb_i    => tx_rdy,
            tx_o     => lvds_o,
            busy_o   => tx_busy);

   clk_divide: process(rst_i, comm_clk_i)
   begin
      if(rst_i = '1') then
         tx_clk_divide <= "000";
      elsif(comm_clk_i'event and comm_clk_i = '1') then
         tx_clk_divide <= tx_clk_divide + 1;
      end if;
   end process clk_divide;
   
   tx_clk <= not tx_clk_divide(2);   -- 200 MHz input clock divided by 8 = 25 MHz
   
   data_buffer: reg
   generic map(WIDTH => 32)
   port map(clk_i  => clk_i,
            rst_i  => rst_i,
            ena_i  => buffer_ena,

            reg_i  => dat_i,
            reg_o  => buffer_out);
   
   byte_counter: counter
   generic map(MAX => 4,
               WRAP_AROUND => '0')
   port map(clk_i   => clk_i,
            rst_i   => rst_i,
            ena_i   => byte_count_ena,
            load_i  => byte_count_clr,
            count_i => int_zero,
            count_o => bytes_sent);
            
   stateFF: process(rst_i, clk_i)
   begin
      if(rst_i = '1') then
         pres_state <= IDLE;
      elsif(clk_i'event and clk_i = '1') then
         pres_state <= next_state;
      end if;
   end process stateFF;

   stateNS: process(pres_state, rdy_i, tx_busy, bytes_sent)
   begin
      case pres_state is
         when IDLE =>   if(rdy_i = '1') then
                           next_state <= TX;
                        else
                           next_state <= IDLE;
                        end if;
                         
         when TX =>     if(tx_busy = '1') then       -- wait until transmitter has started to transmit
                           next_state <= TXBUSY;
                        else
                           next_state <= TX;
                        end if;
                         
         when TXBUSY => if(tx_busy = '0') then  
                           next_state <= SETUP;
                        else
                           next_state <= TXBUSY;
                        end if;
         
         when SETUP =>  if(bytes_sent = 3) then
                           next_state <= DONE;
                        else
                           next_state <= TX;
                        end if;  
                        
         when DONE =>   next_state <= IDLE;          -- signal done, then return to idle
      end case;
   end process stateNS;

   stateOut: process(pres_state, bytes_sent, buffer_out)
   begin
      tx_rdy         <= '0';
      buffer_ena     <= '0';
      byte_count_ena <= '0';
      byte_count_clr <= '0';
      busy_o         <= '1';
      tx_data        <= (others => '0');
      
      case pres_state is
         when IDLE =>   buffer_ena     <= '1';
                        byte_count_ena <= '1';
                        byte_count_clr <= '1';
                        busy_o         <= '0';
                         
         when TX =>     case bytes_sent is
                           when 0 =>      tx_data <= buffer_out(7 downto 0);
                           when 1 =>      tx_data <= buffer_out(15 downto 8);
                           when 2 =>      tx_data <= buffer_out(23 downto 16);
                           when others => tx_data <= buffer_out(31 downto 24);
                        end case;
                        tx_rdy <= '1';
                        
         when SETUP =>  byte_count_ena <= '1';
         
         when others => null;                        
      end case;
   end process stateOut;
         
end rtl;