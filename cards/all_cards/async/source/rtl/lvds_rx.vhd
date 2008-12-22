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
-- LVDS receive module
--
-- Revision history:
--
-- $Log: lvds_rx.vhd,v $
-- Revision 1.19  2006/03/01 01:02:55  erniel
-- reduced comm_clk_i frequency from 200 MHz to 100 MHz
-- modified datapath to work with new comm_clk frequency
--      (performs 4x oversampling instead of 8x)
-- replaced datapath and interface FSMs with simple status flags and logic
--      (optimized control logic)
--
-- Revision 1.18  2006/02/15 09:57:43  erniel
-- manual optimization of FIFO write logic (attempt at reducing number of levels of logic)
--
-- Revision 1.17  2006/02/15 01:09:41  erniel
-- attempt at correcting timing problem on path data_buf_full to data_buf_write
--
-- Revision 1.16  2005/12/01 18:39:07  erniel
-- minor bug fix: enabled output register on dcfifo
--
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
     pres_n_o   : out std_logic;
     ack_i      : in std_logic;

     lvds_i     : in std_logic);
end lvds_rx;

architecture rtl of lvds_rx is

   signal lvds      : std_logic;
   signal lvds_temp : std_logic;

   signal sample_count     : std_logic_vector(7 downto 0);
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

   signal lvds_receiving : std_logic;
   signal data_ready     : std_logic;

   constant START_TIME : integer := 1023;
   signal reverted_dat : std_logic;
   signal time_new  : integer range -1 to START_TIME;
   signal time      : integer range 0 to START_TIME;

begin

   -------------------------------------------------------------------------------------------
   -- Timer for determining if cards are not present.
   -------------------------------------------------------------------------------------------
   time_new <= time - 1;
   timer: process(rst_i, clk_i)
   begin
      if(rst_i = '1') then
         time <= START_TIME;
      elsif(clk_i'event and clk_i = '1') then
         if(lvds_i = '1') then
            if(time > 0) then
               time <= time_new;
            else
               time <= 0;
            end if;
         else
            time <= START_TIME;
         end if;
      end if;
   end process timer;

   reverted_dat <= not lvds_i;
--   reverted_dat <= lvds_i;
   pres_n_o <= '1' when time = 0 else '0';

   -- bring lvds_i into comm_clk domain from asynch domain using a synchronizer:
   process(rst_i, comm_clk_i)
   begin
      if(rst_i = '1') then
         lvds_temp <= '1';   -- idle state of lvds line is high
         lvds      <= '1';
      elsif(comm_clk_i'event and comm_clk_i = '1') then
         lvds_temp <= reverted_dat;
         lvds      <= lvds_temp;
      end if;
   end process;

   sample_counter: binary_counter
   generic map(WIDTH => 8)
   port map(
      clk_i   => comm_clk_i,
      rst_i   => rst_i,
      ena_i   => sample_count_ena,
      up_i    => '1',
      load_i  => '0',
      clear_i => sample_count_clr,
      count_i => (others => '0'),
      count_o => sample_count);

   sample_count_ena <= lvds_receiving;
   sample_count_clr <= not lvds_receiving;

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

   sample_buf_ena <= lvds_receiving;
   sample_buf_clr <= not lvds_receiving;

   -- received bit is majority function of sample buffer
   rx_bit <= (sample_buf(2) and sample_buf(1)) or (sample_buf(2) and sample_buf(0)) or (sample_buf(1) and sample_buf(0));

   rx_buffer: shift_reg
   generic map(
      WIDTH => 34)
   port map(
      clk_i      => comm_clk_i,
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
   rx_buf_clr <= not lvds_receiving;

   data_buffer: dcfifo
   generic map(
      intended_device_family  => "Stratix",
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
   port map(
      wrclk   => comm_clk_i,
      rdclk   => clk_i,
      wrreq   => data_buf_write,
      rdreq   => data_buf_read,
      data    => rx_buf(32 downto 1),
      q       => dat_o,
      aclr    => rst_i,
      wrfull  => data_buf_full,
      rdempty => data_buf_empty);

   data_buf_write <= not data_buf_full when sample_count = 135 else '0';
   data_buf_read <= not data_buf_empty and not data_ready;

   -- lvds_receiving flag (high when a transfer is in progress):
   process(rst_i, comm_clk_i)
   begin
      if(rst_i = '1') then
         lvds_receiving <= '0';
      elsif(comm_clk_i'event and comm_clk_i = '1') then
         -- The leading bit must be '0' and the trailing bit must be '1'
         if((lvds = '0' and lvds_receiving = '0') or (sample_count = 135 and lvds_receiving = '1')) then
            lvds_receiving <= not lvds_receiving;
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