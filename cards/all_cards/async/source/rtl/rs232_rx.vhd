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
-- $Log: rs232_rx.vhd,v $
-- Revision 1.1  2004/06/18 22:14:24  erniel
-- initial version
--
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library components;
use components.component_pack.all;

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
generic(CLK_DIV_FACTOR : integer := 217);
port(comm_clk_i : in std_logic;
     rst_i      : in std_logic;
     
     dat_o      : out std_logic_vector (7 downto 0);
     rdy_o      : out std_logic;
     ack_i      : in std_logic;

     rx_i       : in std_logic);
end component;

signal rx_data : std_logic_vector(7 downto 0);
signal rx_rdy  : std_logic;

signal data_out_ld : std_logic;

type states is (IDLE, READY, DONE); 
signal pres_state : states;
signal next_state : states;

begin

   receiver: async_rx
   generic map(CLK_DIV_FACTOR => 434)
   port map(comm_clk_i => comm_clk_i,
            rst_i      => rst_i,
            dat_o      => rx_data,
            rdy_o      => rx_rdy,
            ack_i      => '1',
            rx_i       => rs232_i);

   rx_buffer: reg
   generic map(WIDTH => 8)
   port map(clk_i  => clk_i,
            rst_i  => rst_i,
            ena_i  => data_out_ld,

            reg_i  => rx_data,
            reg_o  => dat_o);
   
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
                          next_state <= READY;
                       else
                          next_state <= IDLE;
                       end if;

         when READY => if(ack_i = '1') then
                          next_state <= DONE;
                       else
                          next_state <= READY;
                       end if;
                                      
         when DONE =>  if(rx_rdy = '0') then       --
                          next_state <= IDLE;
                       else
                          next_state <= DONE;
                       end if;
      end case;
   end process stateNS;
   
   stateOut: process(pres_state, rx_rdy)
   begin
      data_out_ld <= '0';
      rdy_o       <= '0';
      
      case pres_state is
         when IDLE =>   if(rx_rdy = '1') then
                           data_out_ld <= '1';
                        end if;

         when READY =>  rdy_o <= '1';
                        
         when others => null;
      end case;
   end process stateOut;               
end rtl;