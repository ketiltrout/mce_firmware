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
-- Revision 1.15  2005/10/03 02:43:22  erniel
-- simplified logic for asserting rx_buf_ena in datapath FSM
--
-- Revision 1.14  2005/10/01 00:59:12  erniel
-- minor bug fix to datapath FSM
--
-- Revision 1.13  2005/09/23 00:18:55  erniel
-- issue identified and resolved: data can change before assertion of ack_i
-- added a dual-clock fifo for clock domain crossing:
--      modified existing FSM to handle writing to FIFO in comm_clk domain
--      added new FSM to handle read from FIFO in clk domain
--
-- Revision 1.12  2005/03/31 00:51:05  erniel
-- fixed lvds synchronizer initial state
--
-- Revision 1.11  2005/03/23 23:23:46  erniel
-- added synchronizer on lvds_i
--
-- Revision 1.10  2005/03/23 19:05:02  bburger
-- Bryce:  Test commital
--
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
use ieee.std_logic_unsigned.all;

library altera_mf;
use altera_mf.altera_mf_components.all;

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

signal lvds      : std_logic;
signal lvds_temp : std_logic;

signal sample_count     : std_logic_vector(8 downto 0);
signal sample_count_ena : std_logic;
signal sample_count_clr : std_logic;

signal sample_buf     : std_logic_vector(2 downto 0);
signal sample_buf_ena : std_logic;
signal sample_buf_clr : std_logic;

signal rx_bit     : std_logic;
signal rx_buf     : std_logic_vector(33 downto 0);
signal rx_buf_ena : std_logic;
signal rx_buf_clr : std_logic;

signal data_buf_write : std_logic;
signal data_buf_read  : std_logic;
signal data_buf_full  : std_logic;
signal data_buf_empty : std_logic;

type datapath_states is (IDLE, RECV);
signal datapath_ps : datapath_states;
signal datapath_ns : datapath_states;

type interface_states is (IDLE, READY);
signal interface_ps : interface_states;
signal interface_ns : interface_states;

begin
   
   -- bring lvds_i into comm_clk domain from asynch domain using a synchronizer:
   process(rst_i, comm_clk_i)
   begin
      if(rst_i = '1') then   
         lvds_temp <= '1';   -- idle state of lvds line is high
         lvds      <= '1';
      elsif(comm_clk_i'event and comm_clk_i = '1') then
         lvds_temp <= lvds_i;
         lvds      <= lvds_temp;
      end if;
   end process;
    
   sample_counter: binary_counter
   generic map(WIDTH => 9)
   port map(clk_i   => comm_clk_i,
            rst_i   => rst_i,
            ena_i   => sample_count_ena,
            up_i    => '1',
            load_i  => '0',
            clear_i => sample_count_clr,
            count_i => (others => '0'),
            count_o => sample_count);
            
   rx_sample: shift_reg
   generic map(WIDTH => 3)
   port map(clk_i      => comm_clk_i,
            rst_i      => rst_i,
            ena_i      => sample_buf_ena,
            load_i     => '0',
            clr_i      => sample_buf_clr,
            shr_i      => '1',
            serial_i   => lvds,
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
            
   data_buffer: dcfifo
   generic map(intended_device_family  => "Stratix",
               lpm_width               => 32,
               lpm_numwords            => 16,
               lpm_widthu              => 4,
               clocks_are_synchronized => "TRUE",
               lpm_type                => "dcfifo",
               lpm_showahead           => "OFF",
               overflow_checking       => "ON",
               underflow_checking      => "ON",
               use_eab                 => "ON",
               add_ram_output_register => "ON",
               lpm_hint                => "RAM_BLOCK_TYPE=AUTO")
   port map(wrclk   => comm_clk_i,
            rdclk   => clk_i,
            wrreq   => data_buf_write,
            rdreq   => data_buf_read,
            data    => rx_buf(32 downto 1),
            q       => dat_o,
            aclr    => rst_i,
            wrfull  => data_buf_full,
            rdempty => data_buf_empty); 


------------------------------------------------------------
--
--  Datapath FSM : Controls the receiver datapath
--
------------------------------------------------------------

   dp_stateFF: process(rst_i, comm_clk_i)
   begin
      if(rst_i = '1') then
         datapath_ps <= IDLE;
      elsif(comm_clk_i'event and comm_clk_i = '1') then
         datapath_ps <= datapath_ns;
      end if;
   end process dp_stateFF;
   
   dp_stateNS: process(datapath_ps, lvds, sample_count)
   begin
      case datapath_ps is
         when IDLE =>   if(lvds = '0') then
                           datapath_ns <= RECV;
                        else
                           datapath_ns <= IDLE;
                        end if;
                      
         when RECV =>   if(sample_count = 271) then
                           datapath_ns <= IDLE;
                        else
                           datapath_ns <= RECV;
                        end if;
         
         when others => datapath_ns <= IDLE;
      end case;
   end process dp_stateNS;
   
   dp_stateOut: process(datapath_ps, sample_count, data_buf_full)
   begin
      sample_count_ena <= '0';
      sample_count_clr <= '0';
      sample_buf_ena   <= '0';
      sample_buf_clr   <= '0';
      rx_buf_ena       <= '0';
      rx_buf_clr       <= '0';
      data_buf_write   <= '0';
      
      case datapath_ps is
         when IDLE =>   sample_count_clr <= '1';
                        sample_buf_clr   <= '1';
                        rx_buf_clr       <= '1';
                       
         when RECV =>   sample_count_ena <= '1';
                        sample_buf_ena   <= '1';
                        if(sample_count(2 downto 0) = "101") then             -- enable rx_buf starting at sample_count = 5 and then every 8 thereafter
                           rx_buf_ena <= '1';
                        end if;
                        if(sample_count = 271 and data_buf_full = '0') then   -- write to data buffer when sample_count = 271
                           data_buf_write <= '1';
                        end if;
         
         when others => null;
      end case;
   end process dp_stateOut;


------------------------------------------------------------
--
--  Interface FSM : Manages the rdy/ack handshaking
--
------------------------------------------------------------

   if_stateFF: process(rst_i, clk_i)
   begin
      if(rst_i = '1') then
         interface_ps <= IDLE;
      elsif(clk_i'event and clk_i = '1') then
         interface_ps <= interface_ns;
      end if;
   end process if_stateFF; 
   
   if_stateNS: process(interface_ps, data_buf_empty, ack_i)
   begin
      case interface_ps is
         when IDLE =>   if(data_buf_empty = '0') then
                           interface_ns <= READY;
                        else
                           interface_ns <= IDLE;
                        end if;
                      
         when READY =>  if(ack_i = '1') then
                           interface_ns <= IDLE;
                        else
                           interface_ns <= READY;
                        end if;
         
         when others => interface_ns <= IDLE;
      end case;
   end process if_stateNS;
   
   if_stateOut: process(interface_ps, data_buf_empty)
   begin
      data_buf_read <= '0';
      rdy_o         <= '0';
      
      case interface_ps is
         when IDLE =>   if(data_buf_empty = '0') then
                           data_buf_read <= '1';
                        end if;
                       
         when READY =>   rdy_o <= '1';
         
         when others => null;
      end case;
   end process if_stateOut;   
             
end rtl;