---------------------------------------------------------------------
-- Copyright (c) 2003 UK Astronomy Technology Centre
--                All Rights Reserved
--
--  THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF THE UK ATC
--  The copyright notice above does not evidence any
--  actual or intended publication of such source code.
--
--  SOURCE CODE IS PROVIDED "AS IS". ALL EXPRESS OR IMPLIED CONDITIONS,
--  REPRESENTATIONS, AND WARRANTIES, INCLUDING ANY IMPLIED WARRANT OF
--  MERCHANTABILITY, SATISFACTORY QUALITY, FITNESS FOR A PARTICULAR
--  PURPOSE, OR NON-INFRINGEMENT, ARE DISCLAIMED, EXCEPT TO THE EXTENT
--  THAT SUCH DISCLAIMERS ARE HELD TO BE LEGALLY INVALID.
--
-- Project:             Scuba 2
-- Author:              Neil Gruending
-- Organisation:        UBC Physics and Astronomy
--
-- Description:
-- Wishbone asynchronous transmitter implementation.
-- 
-- Revision History:
--
-- $Log: async_tx.vhd,v $
-- Revision 1.3  2004/06/10 19:36:05  erniel
-- changed interface to non-wishbone
-- reworked code body (made it RTL description)
--
--
-- Dec 22, 2003: Initial version - NRG
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library components;
use components.component_pack.all;

---------------------------------------------------------------------

entity async_tx is
port(tx_clk_i : in std_logic;   -- 25 MHz for LVDS, 115.2 kHz for RS232
     rst_i    : in std_logic;

     dat_i    : in std_logic_vector (7 downto 0);
     stb_i    : in std_logic;
     tx_o     : out std_logic;
     busy_o   : out std_logic);
end async_tx ;

---------------------------------------------------------------------

architecture behaviour of async_tx is

   type states is (IDLE, SETUP, TRANSMIT);
   signal pres_state : states;
   signal next_state : states;

   signal count : integer;

   signal count_clr : std_logic;
   signal shreg_ena : std_logic;
   signal shreg_ld  : std_logic;
   
   signal shreg_data : std_logic_vector(9 downto 0);
   signal debug_data : std_logic_vector(9 downto 0);
   signal tx_data    : std_logic;
   
begin

   tx_counter : counter
      generic map(MAX         => 10,
                  WRAP_AROUND => '0')
      port map(clk_i   => tx_clk_i,
               rst_i   => rst_i,
               ena_i   => '1',
               load_i  => count_clr,
               count_i => 0,
               count_o => count);
               
   tx_databuf : shift_reg
      generic map(WIDTH => 10)
      port map(clk_i      => tx_clk_i,
               rst_i      => rst_i,
               ena_i      => shreg_ena,
               load_i     => shreg_ld,
               clr_i      => '0',
               shr_i      => '1',
               serial_i   => '0',
               serial_o   => tx_data,
               parallel_i => shreg_data,
               parallel_o => debug_data);

   shreg_data <= '1' & dat_i & '0';
     
   stateFF: process(rst_i, tx_clk_i)
   begin
      if(rst_i = '1') then   
         pres_state <= IDLE;
      elsif(tx_clk_i'event and tx_clk_i = '1') then
         pres_state <= next_state;
      end if;
   end process stateFF;
   
   stateNS: process(pres_state, stb_i, count)
   begin
      case pres_state is
         when IDLE =>     if(stb_i = '1') then
                             next_state <= SETUP;
                          else
                             next_state <= IDLE;
                          end if;
                          
         when SETUP =>    next_state <= TRANSMIT;
                                   
         when TRANSMIT => if(count = 9) then 
                             next_state <= IDLE;
                          else
                             next_state <= TRANSMIT;
                          end if;
      end case;
   end process stateNS;
   
   stateOut: process(pres_state, tx_data)
   begin
      count_clr <= '1';
      shreg_ena <= '0';
      shreg_ld  <= '0';
      busy_o    <= '0';
      tx_o      <= '1';
      
      case pres_state is 
         when SETUP =>    shreg_ena <= '1';
                          shreg_ld  <= '1';
                          
         when TRANSMIT => count_clr <= '0';
                          shreg_ena <= '1';
                          busy_o    <= '1';
                          tx_o      <= tx_data;
                          
         when others =>   null;
      end case;
   end process stateOut;
   
end behaviour;