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
-- Project:	      SCUBA-2
-- Author:	       Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- LVDS transmit module (LVDS wrapper for async_tx)
--
-- Revision history:
-- 
-- $Log$
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity lvds_tx is
port(clk_i      : in std_logic;
     comm_clk_i : in std_logic;
     rst_i      : in std_logic;
     
     dat_i      : in std_logic_vector(31 downto 0);
     start_i    : in std_logic;
     done_o     : out std_logic;
     
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

signal tx_clk_divide : std_logic_vector(2 downto 0);
signal tx_clk : std_logic;
signal tx_data : std_logic_vector(7 downto 0);
signal tx_rdy : std_logic;
signal tx_busy : std_logic;

signal data_reg : std_logic_vector(31 downto 0);

signal byte_count : integer range 0 to 4;

type states is (IDLE, TX, TXBUSY, DONE);
signal pres_state : states;
signal next_state : states;

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
   
   tx_clk <= tx_clk_divide(2);   -- 200 MHz input clock divided by 8 = 25 MHz
   
   data_buffer: process(rst_i, clk_i)
   begin
      if(rst_i = '1') then
         data_reg <= (others => '0');
      elsif(clk_i'event and clk_i = '1') then
         data_reg <= dat_i;
      end if;
   end process data_buffer;
   
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
                         
         when TXBUSY => if(tx_busy = '0') then       -- when transmitter signals byte complete, prepare to send next byte.
                           if(byte_count = 4) then
                              next_state <= DONE;
                           else
                              next_state <= TX;
                           end if;  
                        else
                           next_state <= TXBUSY;   
                        end if; 
                        
         when DONE =>   next_state <= IDLE;          -- signal done, then return to idle
      end case;
   end process stateNS;
   
   stateOut: process(pres_state, tx_busy)
   begin
      case pres_state is
         when IDLE =>   tx_data <= (others => '0');
                        tx_rdy <= '0';
                        done_o <= '0';
                        byte_count <= 0;
                         
         when TX =>     case byte_count is
                           when 0 => tx_data <= data_reg(7 downto 0);
                           when 1 => tx_data <= data_reg(15 downto 8);
                           when 2 => tx_data <= data_reg(23 downto 16);
                           when others => tx_data <= data_reg(31 downto 24);
                        end case;
                        tx_rdy <= '1';
                        done_o <= '0';
                        if(tx_busy = '1') then
                           byte_count <= byte_count + 1;
                        end if;
                                                 
         when TXBUSY => tx_data <= (others => '0');
                        tx_rdy <= '0';
                        done_o <= '0';
                        
         when DONE =>   tx_data <= (others => '0');
                        tx_rdy <= '0';
                        done_o <= '1';
                        
      end case;
   end process stateOut;
                 
end rtl;