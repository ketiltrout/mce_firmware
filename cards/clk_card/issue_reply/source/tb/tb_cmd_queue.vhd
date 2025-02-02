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
-- $Id: tb_cmd_queue.vhd,v 1.25 2004/11/15 20:03:41 bburger Exp $
--
-- Project:       SCUBA2
-- Author:        Bryce Burger
-- Organisation:  UBC
--
-- Description:
-- TB file for cmd_queue
--
-- Revision history:
-- $Log: tb_cmd_queue.vhd,v $
-- Revision 1.25  2004/11/15 20:03:41  bburger
-- Bryce :  Moved frame_timing to the 'work' library, and physically moved the files to "all_cards" directory
--
-- Revision 1.24  2004/10/29 23:09:22  bburger
-- Bryce:  Weekend update
--
-- Revision 1.23  2004/10/22 01:54:38  bburger
-- Bryce:  fixed bugs
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
use IEEE.std_logic_arith.all;

library sys_param;
use sys_param.general_pack.all;
use sys_param.wishbone_pack.all;
use sys_param.command_pack.all;

library work;
use work.cmd_queue_pack.all;
use work.issue_reply_pack.all;
use work.cmd_queue_ram40_pack.all;
use work.async_pack.all;
use work.sync_gen_pack.all;
use work.reply_queue_pack.all;
use work.frame_timing_pack.all;

entity TB_CMD_QUEUE is
end TB_CMD_QUEUE;

architecture BEH of TB_CMD_QUEUE is

   signal debug_o       : std_logic_vector(31 downto 0);
   
   -- reply_queue interface
   signal uop_rdy_o       : std_logic := '0'; -- Tells the reply_queue when valid m-op and u-op codes are asserted on it's interface
   signal uop_ack_i       : std_logic := '0'; -- Tells the cmd_queue that a reply to the u-op waiting to be retired has been found and it's status is asserted on uop_status_i
   signal uop_ack         : std_logic := '0'; -- Tells the cmd_queue that a reply to the u-op waiting to be retired has been found and it's status is asserted on uop_status_i
   signal uop_o           : std_logic_vector(QUEUE_WIDTH-1 downto 0) := (others => '0'); --Tells the reply_queue the next u-op that the cmd_queue wants to retire

   -- reply_translator interface 
   signal m_op_done_o       : std_logic;
   signal m_op_error_code_o : std_logic_vector(BB_STATUS_WIDTH-1 downto 0); 
   signal m_op_cmd_code_o   : std_logic_vector(BB_COMMAND_TYPE_WIDTH-1 downto 0); -- Done
   signal m_op_param_id_o   : std_logic_vector(BB_PARAMETER_ID_WIDTH-1 downto 0); -- Done
   signal m_op_card_id_o    : std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0); -- Done
   signal fibre_word_o      : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0); 
   signal num_fibre_words_o : std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);    -- Done
   signal fibre_word_req_i  : std_logic := '0'; 
   signal fibre_word_rdy_o  : std_logic;
   signal m_op_ack_i        : std_logic := '0';    
   signal cmd_stop_o        : std_logic;                                          -- Done
   signal last_frame_o      : std_logic;                                          -- Done
   signal frame_seq_num_o   : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);     -- Done
   
   -- Bus Backplane interface
   signal lvds_rx0a         : std_logic;
   signal lvds_rx1a         : std_logic;
   signal lvds_rx2a         : std_logic;
   signal lvds_rx3a         : std_logic;
   signal lvds_rx4a         : std_logic;
   signal lvds_rx5a         : std_logic;
   signal lvds_rx6a         : std_logic;
   signal lvds_rx7a         : std_logic;
      
   -- cmd_translator interface
   signal card_addr_i     : std_logic_vector (FIBRE_CARD_ADDRESS_WIDTH-1 downto 0) := (others => '0'); -- The card address of the m-op
   signal par_id_i        : std_logic_vector (FIBRE_PARAMETER_ID_WIDTH-1 downto 0) := (others => '0'); -- The parameter id of the m-op
   signal data_size_i     : std_logic_vector (FIBRE_DATA_SIZE_WIDTH-1 downto 0) := (others => '0'); -- The number of bytes of data in the m-op
   signal data_i          : std_logic_vector (PACKET_WORD_WIDTH-1 downto 0) := (others => '0');  -- Data belonging to a m-op
   signal data_clk_i      : std_logic := '0'; -- Clocks in 32-bit wide data
   signal mop_i           : std_logic_vector (BB_MACRO_OP_SEQ_WIDTH-1 downto 0) := (others => '0'); -- M-op sequence number
   signal issue_sync_i    : std_logic_vector (SYNC_NUM_WIDTH-1 downto 0) := (others => '0');
   signal mop_rdy_i       : std_logic := '0'; -- Tells cmd_queue when a m-op is ready
   signal mop_ack_o       : std_logic := '0'; -- Tells the cmd_translator when cmd_queue has taken the m-op
   signal cmd_type_i      : std_logic_vector (BB_COMMAND_TYPE_WIDTH-1 downto 0) := (others => '0');       -- this is a re-mapping of the cmd_code into a 3-bit number
   signal cmd_stop_i      : std_logic := '0';                                          -- indicates a STOP command was recieved
   signal last_frame_i    : std_logic := '0';                                          -- indicates the last frame of data for a ret_dat command
   signal frame_seq_num_i : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0) := (others => '0');

   -- lvds_tx interface
   signal tx_o            : std_logic := '0';  -- transmitter output pin
   signal clk_200mhz_i    : std_logic := '1';  -- PLL locked 25MHz input clock for the

   -- Clock lines
   signal sync_i          : std_logic := '1'; -- The sync pulse determines when and when not to issue u-ops
   signal sync_num_i      : std_logic_vector(SYNC_NUM_WIDTH-1 downto 0) := (others => '0');
   signal clk_i           : std_logic := '1'; -- Advances the state machines
   signal rst_i           : std_logic := '0';  -- Resets all FSMs
   signal comm_clk_i      : std_logic := '0';

   signal count_value     : integer := 0;
   signal rx_dat          : std_logic_vector(31 downto 0);
   signal rx_rdy          : std_logic;
   signal rx_ack          : std_logic;
   signal dv_i            : std_logic := '0';
   signal dv_en_i         : std_logic := '0';

------------------------------------------------------------------------
--
-- Instantiate the design
--
------------------------------------------------------------------------

begin
   dut : cmd_queue
      port map(
         debug_o       => debug_o,

         -- reply_queue interface
         uop_rdy_o     => uop_rdy_o,
         uop_ack_i     => uop_ack,
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
         cmd_type_i    => cmd_type_i,
         cmd_stop_i    => cmd_stop_i,
         last_frame_i  => last_frame_i,
         frame_seq_num_i => frame_seq_num_i,

         -- lvds_tx interface
         tx_o          => tx_o,
         clk_200mhz_i  => clk_200mhz_i,

         -- Clock lines
         sync_i        => sync_i,
         sync_num_i    => sync_num_i,
         clk_i         => clk_i,
         rst_i         => rst_i
      );
      
   dut2 : reply_queue
      port map(
         uop_rdy_i         => uop_rdy_o,
         uop_ack_o         => uop_ack_i,
         uop_i             => uop_o,
         
         m_op_done_o       => m_op_done_o,      
         m_op_error_code_o => m_op_error_code_o,
         m_op_cmd_code_o   => m_op_cmd_code_o,  
         m_op_param_id_o   => m_op_param_id_o,  
         m_op_card_id_o    => m_op_card_id_o,   
         fibre_word_o      => fibre_word_o,     
         num_fibre_words_o => num_fibre_words_o,
         fibre_word_req_i  => fibre_word_req_i, 
         fibre_word_rdy_o  => fibre_word_rdy_o, 
         m_op_ack_i        => m_op_ack_i,       
         cmd_stop_o        => cmd_stop_o,       
         last_frame_o      => last_frame_o,     
         frame_seq_num_o   => frame_seq_num_o,  
        
         lvds_rx0a         => lvds_rx0a,        
         lvds_rx1a         => lvds_rx1a,        
         lvds_rx2a         => lvds_rx2a,        
         lvds_rx3a         => lvds_rx3a,        
         lvds_rx4a         => lvds_rx4a,        
         lvds_rx5a         => lvds_rx5a,        
         lvds_rx6a         => lvds_rx6a,        
         lvds_rx7a         => lvds_rx7a,        
                                       
         clk_i             => clk_i,
         comm_clk_i        => comm_clk_i,
         rst_i             => rst_i
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
      
   sync_pulse_mgr : sync_gen
      port map(
         clk_i         => clk_i,
         rst_i         => rst_i,
         dv_i          => dv_i,
         dv_en_i       => dv_en_i,
         sync_o        => sync_i,
         sync_num_o    => sync_num_i      
      );

   -- Continuous assignements (clocks, etc.)
   sync_i <= not sync_i after CLOCK_PERIOD*(END_OF_FRAME+1)/2; -- The sync frequency is actually ~19 kHz.
   clk_i <= not clk_i after CLOCK_PERIOD/2; -- 50 MHz
   clk_200mhz_i <= not clk_200mhz_i after CLOCK_PERIOD/8;
   comm_clk_i <= not comm_clk_i after CLOCK_PERIOD;
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

   procedure do_retire is
   begin      
      wait for CLOCK_PERIOD;
      assert false report " retire" severity NOTE;
   end do_retire;

   procedure do_ret_dat_cmd is
   begin
      -- <ret_dat       ParId="0x30" Type="cmd" Count="1" />
      card_addr_i(BB_CARD_ADDRESS_WIDTH-1 downto 0) <= ALL_CARDS;
      par_id_i        <= x"00" & RET_DAT_ADDR;
      data_size_i     <= (others => '0');
      data_i          <= (others => '0');
      data_clk_i      <= '0';
      mop_i           <= "00000001"; -- m-op #1
      issue_sync_i    <= "0000000000000001"; -- Sync pulse 1

      cmd_type_i      <= "010";
      cmd_stop_i      <= '0';
      last_frame_i    <= '1';
      frame_seq_num_i <= "11111111111111111111111111111111";
      
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
      card_addr_i(BB_CARD_ADDRESS_WIDTH-1 downto 0) <= ALL_CARDS;
      par_id_i      <= x"00" & RST_WTCHDG_ADDR;
      data_size_i   <= x"00000001";
      data_clk_i    <= '0';
      mop_i         <= "00000010"; -- m-op #2
      issue_sync_i  <= "0000000000000010"; -- Sync pulse 2
      
      cmd_type_i      <= "000";
      cmd_stop_i      <= '0';
      last_frame_i    <= '0';
      frame_seq_num_i <= "00000000000000000000000000000000";

      L1: while mop_ack_o = '0' loop
         mop_rdy_i     <= '1';
         wait for CLOCK_PERIOD;
      end loop;
      
      data_i        <= x"FFFFFFFF";
      wait for CLOCK_PERIOD;      
      wait for CLOCK_PERIOD;      
      data_clk_i    <= '1';
      wait for CLOCK_PERIOD;      
      data_clk_i    <= '0';
      
      mop_rdy_i     <= '0';
      assert false report " reset watchdog" severity NOTE;
      wait for CLOCK_PERIOD;
   end do_rst_wtchdg_cmd;

   procedure do_strt_mux_cmd is
   begin
      card_addr_i(BB_CARD_ADDRESS_WIDTH-1 downto 0) <= ALL_CARDS;
      par_id_i      <= x"00" & ENBL_MUX_ADDR;
      data_size_i   <= x"00000001";
      data_clk_i    <= '0';
      mop_i         <= "00000011"; -- m-op #3
      issue_sync_i  <= "0000000000000011"; -- Sync pulse 3
      
      cmd_type_i      <= "000";
      cmd_stop_i      <= '0';
      last_frame_i    <= '0';
      frame_seq_num_i <= "00000000000000000000000000000000";

      L1: while mop_ack_o = '0' loop
         mop_rdy_i     <= '1';
         wait for CLOCK_PERIOD;
      end loop;
      
      data_i        <= x"FFFFFFFF";
      wait for CLOCK_PERIOD;      
      wait for CLOCK_PERIOD;      
      data_clk_i    <= '1';
      wait for CLOCK_PERIOD;      
      data_clk_i    <= '0';
      
      mop_rdy_i     <= '0';
      assert false report " start MUX" severity NOTE;
      wait for CLOCK_PERIOD;
   end do_strt_mux_cmd;

   procedure do_on_bias_cmd is
   begin
      card_addr_i(BB_CARD_ADDRESS_WIDTH-1 downto 0) <= ADDRESS_CARD;
      par_id_i      <= x"00" & ON_BIAS_ADDR;
      data_size_i   <= x"00000003";
      mop_i         <= "00000100"; -- m-op #4
      issue_sync_i  <= "0000000000000100"; -- Sync pulse 4
      data_clk_i    <= '0';
      
      cmd_type_i      <= "000";
      cmd_stop_i      <= '0';
      last_frame_i    <= '0';
      frame_seq_num_i <= "00000000000000000000000000000000";

      L1: while mop_ack_o = '0' loop
         mop_rdy_i     <= '1';
         wait for CLOCK_PERIOD;
      end loop;
      
      data_i        <= x"11111111";
      wait for CLOCK_PERIOD;      
      wait for CLOCK_PERIOD;      
      data_clk_i    <= '1';
      wait for CLOCK_PERIOD;      
      data_clk_i    <= '0';
      
      data_i        <= x"22222222";
      wait for CLOCK_PERIOD;      
      wait for CLOCK_PERIOD;      
      data_clk_i    <= '1';
      wait for CLOCK_PERIOD;      
      data_clk_i    <= '0';

      data_i        <= x"44444444";
      wait for CLOCK_PERIOD;      
      wait for CLOCK_PERIOD;      
      data_clk_i    <= '1';
      wait for CLOCK_PERIOD;      
      data_clk_i    <= '0';

      mop_rdy_i     <= '0';
      assert false report " start MUX" severity NOTE;
      wait for CLOCK_PERIOD;
   end do_on_bias_cmd;

   -- Start the test
   begin
      do_nop;
      -- This delay is to synchronize the inputs controlled by this TB with the state transitions of the cmd_queue FSMs
      --wait for CLOCK_PERIOD/2;
      do_init;
      do_nop;
      do_ret_dat_cmd;
      do_nop;
      do_nop;
      do_rst_wtchdg_cmd;
      do_nop;
      do_nop;
      do_strt_mux_cmd;
      do_nop;
      do_nop;
      do_on_bias_cmd;
      
      L2: for count_value in 0 to 5*END_OF_FRAME loop
         do_nop;
      end loop L2;
      assert false report " Simulation done." severity FAILURE;
   end process STIMULI;
   
   
   -- Typically, m_op_ack_i will be asserted by the reply_translator after sending out a packet in response to and m_op_done_o pulse
   -- Right now, I override the m_op_ack_i pulse from the testbench.
   uop_ack_proc : process
   begin
      L2: while uop_rdy_o = '0' loop
         uop_ack <= '0';         
         wait for CLOCK_PERIOD;
      end loop;
      
      wait for 100*CLOCK_PERIOD;
      uop_ack <= '1';
      wait for CLOCK_PERIOD;
      uop_ack <= '0';         
   end process uop_ack_proc;
   
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