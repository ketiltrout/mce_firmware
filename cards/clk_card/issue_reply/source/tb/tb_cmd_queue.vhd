-- Copyright (c) 2003 SCUBA-2 Project
--               All Rights Reserved
--
-- THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF THE SCUBA-2 Project
-- The copyright notice above does not evidence any
-- actual or intended publication of such source code.
--
-- SOURCE CODE IS PROVIDED "AS IS". ALL EXPRESS OR IMPLIED CONDITIONS,
-- REPRESENTATIONS, AND WARRANTIES, INCLUDING ANY IMPLIED WARRANT OF
-- MERCHANTABILITY, SATISFACTORY QUALITY, FITNESS FOR A PARTICULAR
-- PURPOSE, OR NON-INFRINGEMENT, ARE DISCLAIMED, EXCEPT TO THE EXTENT
-- THAT SUCH DISCLAIMERS ARE HELD TO BE LEGALLY INVALID.
--
-- For the purposes of this code the SCUBA-2 Project consists of the
-- following organisations.
--
-- UKATC, Royal Observatory, Blackford Hill Edinburgh EH9 3HJ
-- UBC,   University of British Columbia, Physics & Astronomy Department,
--        Vancouver BC, V6T 1Z1
--
-- $Id: tb_cmd_queue.vhd,v 1.9 2004/07/31 00:13:15 bench2 Exp $
--
-- Project:       SCUBA2
-- Author:        Bryce Burger
-- Organisation:  UBC
--
-- Description:
-- Pack file for cmd_queue
--
-- Revision history:
-- $Log: tb_cmd_queue.vhd,v $
-- Revision 1.9  2004/07/31 00:13:15  bench2
-- Bryce: in progress
--
-- Revision 1.8  2004/07/30 00:19:41  bench2
-- Bryce: in progress
--
-- Revision 1.7  2004/07/27 22:54:51  bench2
-- Bryce: in progress
--
-- Revision 1.6  2004/07/22 23:43:42  bench2
-- Bryce: in progress
--
-- Revision 1.5  2004/07/22 20:39:20  bench2
-- Bryce: in progress
--
-- Revision 1.4  2004/07/09 00:03:47  bburger
-- in progress
--
-- Revision 1.3  2004/06/07 23:45:53  bburger
-- in progress
--
-- Revision 1.2  2004/05/31 21:56:02  mandana
-- syntax fix
--
-- Revision 1.1  2004/05/31 21:23:37  bburger
-- in progress
--
--
--
------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

library sys_param;
use sys_param.general_pack.all;
use sys_param.wishbone_pack.all;
use sys_param.command_pack.all;
use sys_param.frame_timing_pack.all;

library work;
use work.cmd_queue_pack.all;
use work.issue_reply_pack.all;
use work.cmd_queue_ram40_pack.all;
use work.async_pack.all;

entity TB_CMD_QUEUE is
end TB_CMD_QUEUE;

architecture BEH of TB_CMD_QUEUE is

   -- reply_queue interface
   signal uop_status_i  : std_logic_vector(UOP_STATUS_BUS_WIDTH-1 downto 0) := (others => '0'); -- Tells the cmd_queue whether a reply was successful or erroneous
   signal uop_rdy_o     : std_logic := '0'; -- Tells the reply_queue when valid m-op and u-op codes are asserted on it's interface
   signal uop_ack_i     : std_logic := '0'; -- Tells the cmd_queue that a reply to the u-op waiting to be retired has been found and it's status is asserted on uop_status_i
   signal uop_discard_o : std_logic := '0'; -- Tells the reply_queue whether or not to discard the reply to the current u-op reply when uop_rdy_i goes low.  uop_rdy_o can only go low after rq_ack_o has been received.
   signal uop_timedout_o: std_logic := '0'; -- Tells that reply_queue that it should generated a timed-out reply based on the the par_id, card_addr, etc of the u-op being retired.
   signal uop_o         : std_logic_vector(QUEUE_WIDTH-1 downto 0) := (others => '0'); --Tells the reply_queue the next u-op that the cmd_queue wants to retire

   -- cmd_translator interface
   signal card_addr_i   : std_logic_vector (CARD_ADDR_BUS_WIDTH-1 downto 0) := (others => '0'); -- The card address of the m-op
   signal par_id_i      : std_logic_vector (PAR_ID_BUS_WIDTH-1 downto 0) := (others => '0'); -- The parameter id of the m-op
   signal data_size_i   : std_logic_vector (DATA_SIZE_BUS_WIDTH-1 downto 0) := (others => '0'); -- The number of bytes of data in the m-op
   signal data_i        : std_logic_vector (DATA_BUS_WIDTH-1 downto 0) := (others => '0');  -- Data belonging to a m-op
   signal data_clk_i    : std_logic := '0'; -- Clocks in 32-bit wide data
   signal mop_i         : std_logic_vector (MOP_BUS_WIDTH-1 downto 0) := (others => '0'); -- M-op sequence number
   signal issue_sync_i  : std_logic_vector (SYNC_NUM_BUS_WIDTH-1 downto 0) := (others => '0');
   signal mop_rdy_i     : std_logic := '0'; -- Tells cmd_queue when a m-op is ready
   signal mop_ack_o     : std_logic := '0'; -- Tells the cmd_translator when cmd_queue has taken the m-op

   -- lvds_tx interface
   signal tx_o          : std_logic := '0';  -- transmitter output pin
   signal clk_200mhz_i   : std_logic := '0';  -- PLL locked 25MHz input clock for the

   -- Clock lines
   signal sync_i        : std_logic := '0'; -- The sync pulse determines when and when not to issue u-ops
   signal clk_i         : std_logic := '0'; -- Advances the state machines
   signal clk_400mhz_i  : std_logic := '0';  -- Fast clock used for doing multi-cycle operations (inserting and deleting u-ops from the command queue) in a single clk_i cycle.  fast_clk_i must be at least 2x as fast as clk_i
   signal rst_i         : std_logic := '0';  -- Resets all FSMs

   signal count_value   : integer := 0;
   signal rx_dat        : std_logic_vector(31 downto 0);
   signal rx_rdy        : std_logic;
   signal rx_ack        : std_logic;

------------------------------------------------------------------------
--
-- Instantiate the design
--
------------------------------------------------------------------------

begin
   DUT : cmd_queue
      port map(
         -- reply_queue interface
         uop_status_i  => uop_status_i,
         uop_rdy_o     => uop_rdy_o,
         uop_ack_i     => uop_ack_i,
         uop_discard_o => uop_discard_o,
         uop_timedout_o=> uop_timedout_o,
         uop_o         => uop_o,

         -- cmd_translator
         card_addr_i   => card_addr_i,
         par_id_i      => par_id_i,
         data_size_i   => data_size_i,
         data_i        => data_i,
         data_clk_i    => data_clk_i,
         mop_i         => mop_i,
         issue_sync_i  => issue_sync_i,
         mop_rdy_i     => mop_rdy_i,
         mop_ack_o     => mop_ack_o,

         -- lvds_tx interface
         tx_o          => tx_o,
         clk_200mhz_i  => clk_200mhz_i,

         -- Clock lines
         sync_i        => sync_i,
         clk_i         => clk_i,
         rst_i         => rst_i
      );
      
   rx : lvds_rx
      port map(
        clk_i          => clk_i,
        comm_clk_i     => clk_200mhz_i,
        rst_i          => rst_i,
     
        dat_o          => rx_dat,
        rdy_o          => rx_rdy,
        ack_i          => rx_ack,
     
        lvds_i         => tx_o
      );

   -- Continuous assignements (clocks, etc.)
   sync_i <= not sync_i after CLOCK_PERIOD*END_OF_FRAME/2; -- The sync frequency is actually ~19 kHz.
   clk_i <= not clk_i after CLOCK_PERIOD/2; -- 50 MHz
   clk_200mhz_i <= not clk_200mhz_i after CLOCK_PERIOD/8;
   rx_ack <= rx_rdy;

   -- Create stimulus
   STIMULI : process

   procedure do_init is
   begin
      mop_rdy_i     <= '0';
      rst_i         <= '1';
      wait for CLOCK_PERIOD;
      rst_i         <= '0';
      wait for CLOCK_PERIOD;
      assert false report " init" severity NOTE;
   end do_init;

   procedure do_nop is
   begin
      wait for CLOCK_PERIOD;
      assert false report " nop" severity NOTE;
   end do_nop;

   procedure do_ret_dat_cmd is
   begin
      card_addr_i(CQ_CARD_ADDR_BUS_WIDTH-1 downto 0) <= ALL_CARDS;
      par_id_i      <= x"00" & RET_DAT_ADDR;
      data_size_i   <= (others => '0');
      data_i        <= (others => '0');
      data_clk_i    <= '0';
      mop_i         <= "00000001"; -- m-op #1
      issue_sync_i  <= "00000001"; -- Sync pulse 1
      
      L1: while mop_ack_o = '0' loop
         mop_rdy_i     <= '1';
         wait for CLOCK_PERIOD;
      end loop;
      
      mop_rdy_i     <= '0';
      assert false report " return data" severity NOTE;
      wait for CLOCK_PERIOD;
   end do_ret_dat_cmd;

   procedure do_rst_wtchdg_cmd is
   begin
      card_addr_i(CQ_CARD_ADDR_BUS_WIDTH-1 downto 0) <= ALL_CARDS;
      par_id_i      <= x"00" & RST_WTCHDG_ADDR;
      data_size_i   <= (others => '0');
      data_i        <= (others => '0');
      data_clk_i    <= '0';
      mop_i         <= "00000010"; -- m-op #2
      issue_sync_i  <= "00000010"; -- Sync pulse 2
      
      L1: while mop_ack_o = '0' loop
         mop_rdy_i     <= '1';
         wait for CLOCK_PERIOD;
      end loop;
      
      mop_rdy_i     <= '0';
      assert false report " reset watchdog" severity NOTE;
      wait for CLOCK_PERIOD;
   end do_rst_wtchdg_cmd;

   procedure do_strt_mux_cmd is
   begin
      card_addr_i(CQ_CARD_ADDR_BUS_WIDTH-1 downto 0) <= ALL_CARDS;
      par_id_i      <= x"00" & STRT_MUX_ADDR;
      data_size_i   <= x"00000001";
      data_i        <= x"FFFFFFFF";
      data_clk_i    <= '0';
      mop_i         <= "00000011"; -- m-op #3
      issue_sync_i  <= "00000011"; -- Sync pulse 3
      
      L1: while mop_ack_o = '0' loop
         mop_rdy_i     <= '1';
         wait for CLOCK_PERIOD;
      end loop;
      
      data_clk_i    <= '1';
      wait for CLOCK_PERIOD/2;      
      data_clk_i    <= '0';
      wait for CLOCK_PERIOD/2;      
      
      mop_rdy_i     <= '0';
      assert false report " start MUX" severity NOTE;
      wait for CLOCK_PERIOD;
   end do_strt_mux_cmd;

   procedure do_on_bias_cmd is
   begin
      card_addr_i(CQ_CARD_ADDR_BUS_WIDTH-1 downto 0) <= AC;
      par_id_i      <= x"00" & ON_BIAS_ADDR;
      data_size_i   <= x"00000003";
      mop_i         <= "00000100"; -- m-op #4
      issue_sync_i  <= "00000100"; -- Sync pulse 4
      data_clk_i    <= '0';
      
      L1: while mop_ack_o = '0' loop
         mop_rdy_i     <= '1';
         wait for CLOCK_PERIOD;
      end loop;
      
      data_i        <= x"11111111";
      data_clk_i    <= '1';
      wait for CLOCK_PERIOD/2;      
      data_clk_i    <= '0';
      wait for CLOCK_PERIOD/2;      
      
      data_i        <= x"22222222";
      data_clk_i    <= '1';
      wait for CLOCK_PERIOD/2;      
      data_clk_i    <= '0';
      wait for CLOCK_PERIOD/2;      

      data_i        <= x"44444444";
      data_clk_i    <= '1';
      wait for CLOCK_PERIOD/2;      
      data_clk_i    <= '0';
      wait for CLOCK_PERIOD/2;      

      mop_rdy_i     <= '0';
      assert false report " start MUX" severity NOTE;
      wait for CLOCK_PERIOD;
   end do_on_bias_cmd;

   -- Start the test
   begin
      do_nop;
      -- This delay is to synchronize the inputs controlled by this TB with the state transitions of the cmd_queue FSMs
      wait for CLOCK_PERIOD/2;
      do_init;
      do_nop;
      do_ret_dat_cmd;
      do_rst_wtchdg_cmd;
      do_strt_mux_cmd;
      do_on_bias_cmd;
      
      L2: for count_value in 0 to 5*END_OF_FRAME loop
         do_nop;
      end loop L2;
      assert false report " Simulation done." severity FAILURE;
   end process STIMULI;
end BEH;

------------------------------------------------------------------------
--
-- Configuration
--
------------------------------------------------------------------------

configuration TB_CMD_QUEUE_CONF of TB_CMD_QUEUE is
   for BEH
   end for;
end TB_CMD_QUEUE_CONF;