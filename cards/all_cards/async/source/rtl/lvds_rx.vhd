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
-- Project:       SCUBA-2
-- Author:         Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- LVDS receive module (LVDS wrapper for async_rx)
--
-- Revision history:
-- 
-- $Log: lvds_rx.vhd,v $
-- Revision 1.9  2005/03/23 01:56:11  erniel
-- added "when others" statements to FSMs
--
-- Revision 1.8  2005/01/12 22:40:30  erniel
-- removed clk_i from ports
-- modified rdy_o / ack_i logic
--
-- Revision 1.7  2005/01/11 02:35:44  erniel
-- removed async_rx instantiation
-- modified receiver datapath (based on async_rx datapath)
-- modified receiver control
-- signal name and state name changes
--
-- Revision 1.6  2004/12/16 18:21:08  erniel
-- fixed small bug in counter
--
-- Revision 1.5  2004/12/15 01:55:48  erniel
-- removed clock divider logic (moved to async_rx)
-- modified buffering to allow word to persist until next word ready
-- reworked FSM to handle new async_rx interface
--
-- Revision 1.4  2004/08/25 22:16:40  bburger
-- Bryce:  changed int_zero from signal to constant
--
-- Revision 1.3  2004/08/24 23:53:23  bburger
-- Bryce:  bug fix - added a signal call int_zero for portmaps to counters
--
-- Revision 1.2  2004/08/06 20:39:30  erniel
-- replaced some processes with rtl-blocks
-- added data buffer registers
--
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
port(comm_clk_i : in std_logic;
     rst_i      : in std_logic;
     
     dat_o      : out std_logic_vector(31 downto 0);
     rdy_o      : out std_logic;
     ack_i      : in std_logic;
     
     lvds_i     : in std_logic);
end lvds_rx;

architecture rtl of lvds_rx is

signal sample_count     : integer range 0 to 272;
signal sample_count_ena : std_logic;
signal sample_count_clr : std_logic;

signal sample_buf     : std_logic_vector(2 downto 0);
signal sample_buf_ena : std_logic;
signal sample_buf_clr : std_logic;

signal rx_bit     : std_logic;
signal rx_buf     : std_logic_vector(33 downto 0);
signal rx_buf_ena : std_logic;
signal rx_buf_clr : std_logic;

signal data_ld : std_logic;

signal rdy : std_logic;
signal ack : std_logic;

type states is (IDLE, RECV, READY);
signal pres_state : states;
signal next_state : states;

begin
    
   sample_counter: counter
   generic map(MAX => 271,
               WRAP_AROUND => '0')
   port map(clk_i   => comm_clk_i,
            rst_i   => rst_i,
            ena_i   => sample_count_ena,
            load_i  => sample_count_clr,
            count_i => 0,
            count_o => sample_count);
            
   rx_sample: shift_reg
   generic map(WIDTH => 3)
   port map(clk_i      => comm_clk_i,
            rst_i      => rst_i,
            ena_i      => sample_buf_ena,
            load_i     => '0',
            clr_i      => sample_buf_clr,
            shr_i      => '1',
            serial_i   => lvds_i,
            serial_o   => open,
            parallel_i => (others => '0'),
            parallel_o => sample_buf);
            
   -- received bit is majority function of sample buffer
   rx_bit <= (sample_buf(2) and sample_buf(1)) or (sample_buf(2) and sample_buf(0)) or (sample_buf(1) and sample_buf(0));
   
   rx_buffer: shift_reg
   generic map(WIDTH => 34)
   port map(clk_i      => comm_clk_i,
            rst_i      => rst_i,
            ena_i      => rx_buf_ena,
            load_i     => '0',
            clr_i      => rx_buf_clr,
            shr_i      => '1',
            serial_i   => rx_bit,
            serial_o   => open,
            parallel_i => (others => '0'),
            parallel_o => rx_buf);
            
   data_buffer: reg
   generic map(WIDTH => 32)
   port map(clk_i  => comm_clk_i,
            rst_i  => rst_i,
            ena_i  => data_ld,
 
            reg_i  => rx_buf(32 downto 1),
            reg_o  => dat_o);


------------------------------------------------------------
--
--  Receive FSM : Controls the receiver datapath
--
------------------------------------------------------------

   stateFF: process(rst_i, comm_clk_i)
   begin
      if(rst_i = '1') then
         pres_state <= IDLE;
      elsif(comm_clk_i'event and comm_clk_i = '1') then
         pres_state <= next_state;
      end if;
   end process stateFF;
   
   stateNS: process(pres_state, lvds_i, sample_count)
   begin
      next_state <= pres_state;
      case pres_state is
         when IDLE =>   if(lvds_i = '0') then
                           next_state <= RECV;
                        else
                           next_state <= IDLE;
                        end if;
                      
         when RECV =>   if(sample_count = 271) then
                           next_state <= READY;
                        else
                           next_state <= RECV;
                        end if;
                      
         when READY =>  next_state <= IDLE;
         
         when others => next_state <= IDLE;
      end case;
   end process stateNS;
   
   stateOut: process(pres_state, sample_count)
   begin
      sample_count_ena <= '0';
      sample_count_clr <= '0';
      sample_buf_ena   <= '0';
      sample_buf_clr   <= '0';
      rx_buf_ena       <= '0';
      rx_buf_clr       <= '0';
      data_ld          <= '0';
      rdy              <= '0';
      
      case pres_state is
         when IDLE =>   sample_count_ena <= '1';
                        sample_count_clr <= '1';
                        sample_buf_ena   <= '1';
                        sample_buf_clr   <= '1';
                        rx_buf_ena       <= '1';
                        rx_buf_clr       <= '1';
                       
         when RECV =>   sample_count_ena <= '1';
                        sample_buf_ena   <= '1';
                        if(sample_count = 5   or sample_count = 13  or sample_count = 21  or sample_count = 29  or sample_count = 37  or
                           sample_count = 45  or sample_count = 53  or sample_count = 61  or sample_count = 69  or sample_count = 77  or
                           sample_count = 85  or sample_count = 93  or sample_count = 101 or sample_count = 109 or sample_count = 117 or
                           sample_count = 125 or sample_count = 133 or sample_count = 141 or sample_count = 149 or sample_count = 157 or
                           sample_count = 165 or sample_count = 173 or sample_count = 181 or sample_count = 189 or sample_count = 197 or
                           sample_count = 205 or sample_count = 213 or sample_count = 221 or sample_count = 229 or sample_count = 237 or
                           sample_count = 245 or sample_count = 253 or sample_count = 261 or sample_count = 269) then rx_buf_ena <= '1';
                        end if;
                        if(sample_count = 271) then 
                           data_ld       <= '1';
                        end if;
                       
         when READY =>  rdy              <= '1';
         
         when others => null;
      end case;
   end process stateOut;


   process(comm_clk_i)
   begin
      if(comm_clk_i = '1') then
         ack <= ack_i;
      end if;
   end process;
   
   process(rst_i, comm_clk_i)
   begin
      if(rst_i = '1') then
         rdy_o <= '0';
      elsif(comm_clk_i'event and comm_clk_i = '1') then
         if(rdy = '1') then
            rdy_o <= '1';
         elsif(ack = '1') then
            rdy_o <= '0';
         end if;
      end if;
   end process;
                      
end rtl;