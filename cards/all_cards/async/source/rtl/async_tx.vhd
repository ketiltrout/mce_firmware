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
-- Revision 1.7  2004/12/17 20:51:07  erniel
-- revert to 200 MHz clock divider
-- WARNING: temporary solution!  Work still in progress!
--
-- Revision 1.6  2004/12/14 23:05:01  erniel
-- changed CLK_DIV_FACTOR default value to LVDS
--
-- Revision 1.5  2004/12/10 01:36:58  erniel
-- added generic clock divide factor and clock division logic
-- changed some signal names
--
-- Revision 1.4  2004/08/06 20:36:24  erniel
-- replaced some processes with rtl-blocks
-- added setup state
--
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
generic(CLK_DIV_FACTOR : in integer := 8); 
port(comm_clk_i : in std_logic;
     rst_i      : in std_logic;

     dat_i  : in std_logic_vector (7 downto 0);
     rdy_i  : in std_logic;
     busy_o : out std_logic;

     tx_o   : out std_logic);
end async_tx ;

---------------------------------------------------------------------

architecture behaviour of async_tx is

signal tx_clk        : std_logic;

signal count     : integer range 0 to 10;
signal count_clr : std_logic;

signal buf_ena  : std_logic;
signal buf_ld   : std_logic;   
signal buf_data : std_logic_vector(9 downto 0);
signal tx_data  : std_logic;
   
type states is (IDLE, SETUP, TRANSMIT);
signal pres_state : states;
signal next_state : states;

begin

   -- clock divider process
   process(comm_clk_i, rst_i)
   variable clk_div_count : integer range 0 to CLK_DIV_FACTOR-1;
   begin
      if(rst_i = '1') then
         clk_div_count := 0;
      elsif(comm_clk_i'event and comm_clk_i = '1') then
         if(clk_div_count = CLK_DIV_FACTOR-1) then
            tx_clk <= '1';
            clk_div_count := 0;
         else
            tx_clk <= '0';
            clk_div_count := clk_div_count + 1;
         end if;
      end if;
   end process;
   
   tx_counter : counter
   generic map(MAX         => 10,
               WRAP_AROUND => '0')
   port map(clk_i   => tx_clk,
            rst_i   => rst_i,
            ena_i   => '1',
            load_i  => count_clr,
            count_i => 0,
            count_o => count);
               
   tx_buffer : shift_reg
   generic map(WIDTH => 10)
   port map(clk_i      => tx_clk,
            rst_i      => rst_i,
            ena_i      => buf_ena,
            load_i     => buf_ld,
            clr_i      => '0',
            shr_i      => '1',
            serial_i   => '0',
            serial_o   => tx_data,
            parallel_i => buf_data,
            parallel_o => open);

   buf_data <= '1' & dat_i & '0';
     
   stateFF: process(rst_i, tx_clk)
   begin
      if(rst_i = '1') then   
         pres_state <= IDLE;
      elsif(tx_clk'event and tx_clk = '1') then
         pres_state <= next_state;
      end if;
   end process stateFF;
   
   stateNS: process(pres_state, rdy_i, count)
   begin
      case pres_state is
         when IDLE =>     if(rdy_i = '1') then
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
      buf_ena   <= '0';
      buf_ld    <= '0';
      busy_o    <= '0';
      tx_o      <= '1';
      
      case pres_state is 
         when SETUP =>    buf_ena <= '1';
                          buf_ld  <= '1';
                          
         when TRANSMIT => count_clr <= '0';
                          buf_ena   <= '1';
                          busy_o    <= '1';
                          tx_o      <= tx_data;
                          
         when others =>   null;
      end case;
   end process stateOut;
   
end behaviour;