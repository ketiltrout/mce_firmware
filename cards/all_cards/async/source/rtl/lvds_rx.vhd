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
-- $Log: lvds_rx.vhd,v $
-- Revision 1.1  2004/06/17 01:25:41  erniel
-- initial version
--
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library components;
use components.component_pack.all;


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

signal bytes_received : integer range 0 to 4;
signal byte_count_ena : std_logic;
signal byte_count_clr : std_logic;

signal byte_ld  : std_logic;
signal byte0_ld : std_logic;
signal byte1_ld : std_logic;
signal byte2_ld : std_logic;
signal byte3_ld : std_logic;

type states is (IDLE, LATCH, RXDONE, RXWAIT, DONE);
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
    
   byte_counter: counter
   generic map(MAX => 4,
               WRAP_AROUND => '0')
   port map(clk_i   => clk_i,
            rst_i   => rst_i,
            ena_i   => byte_count_ena,
            load_i  => byte_count_clr,
            count_i => 0,
            count_o => bytes_received);
            
   data_buf0: reg
   generic map(WIDTH => 8)
   port map(clk_i  => clk_i,
            rst_i  => rst_i,
            ena_i  => byte0_ld,
 
            reg_i  => rx_data,
            reg_o  => dat_o(7 downto 0));

   data_buf1: reg
   generic map(WIDTH => 8)
   port map(clk_i  => clk_i,
            rst_i  => rst_i,
            ena_i  => byte1_ld,
 
            reg_i  => rx_data,
            reg_o  => dat_o(15 downto 8));
            
   data_buf2: reg
   generic map(WIDTH => 8)
   port map(clk_i  => clk_i,
            rst_i  => rst_i,
            ena_i  => byte2_ld,
 
            reg_i  => rx_data,
            reg_o  => dat_o(23 downto 16));
            
   data_buf3: reg
   generic map(WIDTH => 8)
   port map(clk_i  => clk_i,
            rst_i  => rst_i,
            ena_i  => byte3_ld,
 
            reg_i  => rx_data,
            reg_o  => dat_o(31 downto 24));
            
   byte0_ld <= '1' when bytes_received = 0 and byte_ld = '1' else '0';
   byte1_ld <= '1' when bytes_received = 1 and byte_ld = '1' else '0';
   byte2_ld <= '1' when bytes_received = 2 and byte_ld = '1' else '0';
   byte3_ld <= '1' when bytes_received = 3 and byte_ld = '1' else '0';
   
   stateFF: process(rst_i, clk_i)
   begin
      if(rst_i = '1') then
         pres_state <= IDLE;
      elsif(clk_i'event and clk_i = '1') then
         pres_state <= next_state;
      end if;
   end process stateFF;
   
   stateNS: process(pres_state, rx_rdy, ack_i, bytes_received)
   begin
      case pres_state is
         when IDLE =>   if(rx_rdy = '1') then         -- if receiver signals incoming byte, prepare to copy it
                           next_state <= LATCH;
                        else
                           next_state <= IDLE;
                        end if;
                        
         when LATCH =>  next_state <= RXDONE;         -- copy the byte
         
         when RXDONE => if(bytes_received = 4) then   -- if we've received 4 bytes, then done.  Otherwise, wait for next byte.
                           next_state <= DONE;
                        else
                           next_state <= RXWAIT;
                        end if;
                        
         when RXWAIT => if(rx_rdy = '1') then         -- when waiting for next byte, receiver signals byte ready, prepare to copy
                           next_state <= LATCH;
                        else
                           next_state <= RXWAIT;
                        end if;
         
         when DONE =>   if(ack_i = '1') then          -- when external module has copied received word, return to idle.
                           next_state <= IDLE;
                        else
                           next_state <= DONE;
                        end if;
      end case;
   end process stateNS;
   
   stateOut: process(pres_state)
   begin
      rdy_o          <= '0';
      rx_stb         <= '0';
      byte_ld        <= '0';
      byte_count_ena <= '0';
      byte_count_clr <= '0';
      
      case pres_state is
         when IDLE =>   byte_count_ena <= '1';
                        byte_count_clr <= '1';
                        
         when LATCH =>  byte_ld        <= '1';
                        byte_count_ena <= '1';
         
         when RXDONE => rx_stb         <= '1';

         when DONE =>   rdy_o          <= '1';
                        
         when others => null;
      end case;
   end process stateOut;

end rtl;