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
-- Revision 1.5  2005/01/13 00:26:30  erniel
-- replaced comm_clk_i with clk_i
-- recalculated sample_count intervals
--
-- Revision 1.4  2005/01/12 22:47:11  erniel
-- removed async_rx instantiation
-- removed clk_i from ports
-- modified receiver datapath (based on async_rx datapath)
-- modified receiver control
-- modified rdy_o / ack_i logic
-- signal name and state name changes
--
-- Revision 1.3  2005/01/05 23:39:31  erniel
-- updated async_rx component
--
-- Revision 1.2  2004/12/17 00:21:30  erniel
-- removed clock divider logic (moved to async_rx)
-- modified buffering to allow word to persist until next word ready
-- reworked FSM to handle new async_rx interface
--
-- Revision 1.1  2004/06/18 22:14:24  erniel
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

--signal sample_count     : integer range 0 to 4340;
signal sample_count     : std_logic_vector(7 downto 0);
signal sample_count_ena : std_logic;
signal sample_count_clr : std_logic;

signal sample_buf     : std_logic_vector(2 downto 0);
signal sample_buf_ena : std_logic;
signal sample_buf_clr : std_logic;

signal data_buf_write : std_logic;
signal data_buf_read  : std_logic;
signal data_buf_full  : std_logic;
signal data_buf_empty : std_logic;

signal rx_bit     : std_logic;
signal rx_buf     : std_logic_vector(9 downto 0);
signal rx_buf_ena : std_logic;
signal rx_buf_clr : std_logic;

signal data_ld : std_logic;

signal rdy : std_logic;
signal ack : std_logic;

signal rs232_temp : std_logic;
signal rs232_sig  : std_logic;
signal serial_receiving: std_logic;
signal data_ready: std_logic;

type states is (IDLE, RECV, READY);
signal pres_state : states;
signal next_state : states;

begin
   -- bring rs232_i into comm_clk domain from asynch domain using a synchronizer:
   process(rst_i, comm_clk_i)
   begin
      if(rst_i = '1') then   
         rs232_temp <= '1';   -- idle state of rs232_i line is high
         rs232_sig  <= '1';
      elsif(comm_clk_i'event and comm_clk_i = '1') then
         rs232_temp <= rs232_i;
         rs232_sig  <= rs232_temp;
      end if;
   end process;
 
   sample_counter: binary_counter
   generic map(WIDTH => 8)
   port map(clk_i   => comm_clk_i,
            rst_i   => rst_i,
            ena_i   => sample_count_ena,
            up_i    => '1',
            load_i  => '0',
            clear_i => sample_count_clr,
            count_i => (others => '0'),
            count_o => sample_count);

   sample_count_ena <= serial_receiving;
   sample_count_clr <= not serial_receiving;
            
   rx_sample: shift_reg
   generic map(WIDTH => 3)
   port map(clk_i      => comm_clk_i,
            rst_i      => rst_i,
            ena_i      => sample_buf_ena,
            load_i     => '0',
            clr_i      => sample_buf_clr,
            shr_i      => '1',
            serial_i   => rs232_sig,
            serial_o   => open,
            parallel_i => (others => '0'),
            parallel_o => sample_buf);

   sample_buf_ena <= serial_receiving;
   sample_buf_clr <= not serial_receiving;
            
   -- received bit is majority function of sample buffer
   rx_bit <= (sample_buf(2) and sample_buf(1)) or (sample_buf(2) and sample_buf(0)) or (sample_buf(1) and sample_buf(0));
   
   rx_buffer: shift_reg
   generic map(WIDTH => 10)
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
            
   rx_buf_ena <= '1' when sample_count(1 downto 0) = "10" else '0';
   rx_buf_clr <= not serial_receiving;
   
            
   data_buffer: dcfifo
   generic map(intended_device_family  => "Stratix",
               lpm_width               => 8,
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
            data    => rx_buf(8 downto 1),
            q       => dat_o,
            aclr    => rst_i,
            wrfull  => data_buf_full,
            rdempty => data_buf_empty); 

   data_buf_write <= not data_buf_full when sample_count = 39 else '0';   
   data_buf_read <= not data_buf_empty and not data_ready;    

   -- serial_receiving flag (high when a transfer is in progress):
   process(rst_i, comm_clk_i)
   begin
      if(rst_i = '1') then
         serial_receiving <= '0';
      elsif(comm_clk_i'event and comm_clk_i = '1') then
         if((rs232_sig = '0' and serial_receiving = '0') or (sample_count = 39 and serial_receiving = '1')) then
            serial_receiving <= not serial_receiving;
         end if;
      end if;
   end process;

   -- data_ready flag (high when a datum is output and waiting for an ack):
   process(rst_i, clk_i)
   begin
      if(rst_i = '1') then
         data_ready <= '0';
      elsif(clk_i'event and clk_i = '1') then
         if((data_buf_empty = '0' and data_ready = '0') or (ack_i = '1' and data_ready = '1')) then
            data_ready <= not data_ready;
         end if;
      end if;
   end process;
   
   rdy_o <= data_ready;
                      
end rtl;