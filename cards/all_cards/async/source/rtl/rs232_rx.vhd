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
-- rs232_rx.vhd
--
-- Project:	      SCUBA-2
-- Author:	       Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- RS232 receive module (RS232 wrapper for async_rx)
--
-- Revision history:
-- 
-- $Log$
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity rs232_rx is
port(clk_i      : in std_logic;
     comm_clk_i : in std_logic;
     rst_i      : in std_logic;
     
     dat_o      : out std_logic_vector(7 downto 0);
     rdy_o      : out std_logic;
     ack_i      : in std_logic;
     
     rs232_i    : in std_logic);
end rs232_rx;

architecture rtl of rs232_rx is
component async_rx
port(rx_clk_i : in std_logic;
     rst_i    : in std_logic;
     
     dat_o    : out std_logic_vector (7 downto 0);
     stb_i    : in std_logic;
     rx_i     : in std_logic;
     valid_o  : out std_logic;
     error_o  : out std_logic);
end component;

signal rx_clk_divide : integer range 0 to 217;
signal rx_clk : std_logic;
signal rx_stb : std_logic;
signal rx_rdy : std_logic;
signal rx_error : std_logic;

type states is (IDLE, LATCH, DONE);
signal pres_state : states;
signal next_state : states;

begin

   receive: async_rx
   port map(rx_clk_i => rx_clk,
            rst_i    => rst_i,
            dat_o    => dat_o,
            stb_i    => rx_stb,
            rx_i     => rs232_i,
            valid_o  => rx_rdy,
            error_o  => rx_error);
   
   clk_divide: process(rst_i, comm_clk_i)
   begin
      if(rst_i = '1') then
         rx_clk_divide <= 0;
      elsif(comm_clk_i'event and comm_clk_i = '1') then
         if(rx_clk_divide = 216) then
            rx_clk_divide <= 0;
         else
            rx_clk_divide <= rx_clk_divide + 1;
         end if;
      end if;
   end process clk_divide;
   
   rx_clk <= '1' when rx_clk_divide = 216 else '0';   -- 200 MHz input clock divided by 217 = 921.6 kHz
   
   stateFF: process(rst_i, clk_i)
   begin
      if(rst_i = '1') then
         pres_state <= IDLE;
      elsif(clk_i'event and clk_i = '1') then
         pres_state <= next_state;
      end if;
   end process stateFF;
   
   stateNS: process(pres_state, rx_rdy, ack_i)
   begin
      case pres_state is
         when IDLE =>  if(rx_rdy = '1') then       --
                          next_state <= LATCH;
                       else
                          next_state <= IDLE;
                       end if;
         
         when LATCH => if(ack_i = '1') then
                          next_state <= DONE;
                       else
                          next_state <= LATCH;
                       end if;
                                      
         when DONE =>  if(rx_rdy = '0') then       --
                          next_state <= IDLE;
                       else
                          next_state <= DONE;
                       end if;
      end case;
   end process stateNS;
   
   stateOut: process(pres_state)
   begin
      case pres_state is
         when IDLE =>   rdy_o <= '0';
                        rx_stb <= '0';
                        
         when LATCH =>  rdy_o <= '1';
                        rx_stb <= '0';
                        
         when DONE =>   rdy_o <= '0';
                        rx_stb <= '1';
      end case;
   end process stateOut;               
end rtl;