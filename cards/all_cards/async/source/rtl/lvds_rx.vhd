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
-- lvds_rx.vhd
--
-- Project:	      SCUBA-2
-- Author:	       Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- LVDS receive module (LVDS wrapper for async_rx)
--
-- Revision history:
-- 
-- $Log$
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity lvds_rx is
port(clk_i      : in std_logic;
     comm_clk_i : in std_logic;
     rst_i      : in std_logic;
     
     dat_o      : out std_logic_vector(31 downto 0);
     rdy_o      : out std_logic;
     ack_i      : in std_logic;
     
     lvds_i     : in std_logic);
end lvds_rx;

architecture rtl of lvds_rx is
component async_rx
port(rx_clk_i : in std_logic;
     rst_i    : in std_logic;
     
     dat_o    : out std_logic_vector (7 downto 0);
     stb_i    : in std_logic;
     rx_i     : in std_logic;
     valid_o  : out std_logic;
     error_o  : out std_logic);
end component;

signal rx_data : std_logic_vector(7 downto 0);
signal rx_stb : std_logic;
signal rx_rdy : std_logic;
signal rx_error : std_logic;

signal data_reg : std_logic_vector(31 downto 0);

signal byte_count : integer range 0 to 4;

type states is (IDLE, LATCH, RXWAIT, DONE);
signal pres_state : states;
signal next_state : states;

begin

   receive: async_rx
   port map(rx_clk_i => comm_clk_i,   -- no clock division required
            rst_i    => rst_i,
            dat_o    => rx_data,
            stb_i    => rx_stb,
            rx_i     => lvds_i,
            valid_o  => rx_rdy,
            error_o  => rx_error);
                  
   stateFF: process(rst_i, clk_i)
   begin
      if(rst_i = '1') then
         pres_state <= IDLE;
      elsif(clk_i'event and clk_i = '1') then
         pres_state <= next_state;
      end if;
   end process stateFF;
   
   stateNS: process(pres_state, rx_rdy, ack_i, byte_count)
   begin
      case pres_state is
         when IDLE =>   if(rx_rdy = '1') then       -- if receiver signals incoming byte, prepare to copy it
                           next_state <= LATCH;
                        else
                           next_state <= IDLE;
                        end if;
                        
         when LATCH =>  if(byte_count = 4) then     -- if we've received 4 bytes, then done.  Otherwise, wait for next byte.
                           next_state <= DONE;
                        else
                           next_state <= RXWAIT;
                        end if;
                        
         when RXWAIT => if(rx_rdy = '1') then       -- if when waiting for next byte, receiver signals byte ready, prepare to copy
                           next_state <= LATCH;
                        else
                           next_state <= RXWAIT;
                        end if;
         
         when DONE =>   if(ack_i = '1') then        -- when external module has copied received word, return to idle.
                           next_state <= IDLE;
                        else
                           next_state <= DONE;
                        end if;
      end case;
   end process stateNS;
   
   stateOut: process(pres_state)
   begin
      case pres_state is
         when IDLE =>   data_reg <= (others => '0');
                        dat_o <= (others => '0');
                        rdy_o <= '0';
                        rx_stb <= '0';
                        byte_count <= 0;
                        
         when LATCH =>  case byte_count is
                           when 0 => data_reg(7 downto 0) <= rx_data;
                           when 1 => data_reg(15 downto 8) <= rx_data;
                           when 2 => data_reg(23 downto 16) <= rx_data;
                           when others => data_reg(31 downto 24) <= rx_data;
                        end case;
                        dat_o <= (others => '0');
                        rdy_o <= '0';
                        rx_stb <= '1';
                        byte_count <= byte_count + 1;
                        
         when RXWAIT => dat_o <= (others => '0');
                        rdy_o <= '0';
                        rx_stb <= '0';
                        
         when DONE =>   dat_o <= data_reg;
                        rdy_o <= '1';
                        rx_stb <= '0';
      end case;
   end process stateOut;

end rtl;