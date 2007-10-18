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
-- $Id: dv_rx.vhd,v 1.15 2007/09/20 19:56:05 bburger Exp $
--
-- Project:       SCUBA-2
-- Author:        Bryce Burger
-- Organization:  UBC
--
-- Description:
-- DV and Manchester Decoder
--
-- Revision history:
-- $Log: dv_rx.vhd,v $
-- Revision 1.15  2007/09/20 19:56:05  bburger
-- BB:  Added a sync_box_err_ack signal to tell the dv_rx block when to clear an error
--
-- Revision 1.14  2007/07/25 18:31:41  bburger
-- BB:
-- - manch_clk_i signal is added to the dv_rx interace to allow the block to sample the fibre line with the manchester clock.
-- - added extra wait states in the FSM to account for the extra delay in the manchester data pipeline due to synchronization.
--
-- Revision 1.13  2006/08/16 17:55:55  bburger
-- Bryce:  Bug Fix:  dv_rx now registers the DV Sequence Number only when it receives a DV pulse
--
-- Revision 1.12  2006/06/30 22:08:21  bburger
-- Bryce:  Cleaned up the file, added sync_box_err and sync_box_free_run status signals to the interface
--
-- Revision 1.11  2006/05/30 00:53:37  bburger
-- Bryce:  Interim committal
--
-- Revision 1.10  2006/05/25 05:41:26  bburger
-- Bryce:  Intermediate committal
--
-- Revision 1.9  2006/05/24 07:07:29  bburger
-- Bryce:  Intermediate committal
--
-- Revision 1.8  2006/05/23 21:26:42  bburger
-- Bryce:  Intemediate Committal
--
-- Revision 1.7  2006/05/13 07:38:49  bburger
-- Bryce:  Intermediate commital -- going away on holiday and don't want to lose work
--
-- Revision 1.6  2006/03/23 23:18:02  bburger
-- Bryce:  cleaned up this file a little
--
-- Revision 1.5  2006/03/16 00:14:52  bburger
-- Bryce:  dv is inverted at the receiver, so dv_rx detects rising edges instead of falling edges.
--
-- Revision 1.4  2006/03/09 00:53:04  bburger
-- Bryce:
-- - Implemented the dv_fibre receiver
-- - Moved some constants from dv_rx_pack to sync_gen_pack
--
-- Revision 1.3  2006/03/01 02:53:32  bburger
-- Bryce:  modified interface signals dv_sel_i and sync_sel_i to dv_mode_i and sync_mode_i
--
-- Revision 1.2  2006/02/28 09:20:58  bburger
-- Bryce:  Modified the interface of dv_rx.  Non-functional at this point.
--
-- Revision 1.1  2006/02/11 01:11:53  bburger
-- Bryce:  New!
--
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library components;
use components.component_pack.all;

library work;
use work.sync_gen_pack.all;
use work.dv_rx_pack.all;

entity dv_rx is
   port(
      -- Clock and Reset:
      clk_i               : in std_logic;
      manch_clk_i         : in std_logic;
      clk_n_i             : in std_logic;
      rst_i               : in std_logic;

      -- Fibre Interface:
      manch_det_i         : in std_logic;
      manch_dat_i         : in std_logic;
      dv_dat_i            : in std_logic;

      -- Issue-Reply Interface:
      dv_mode_i           : in std_logic_vector(DV_SELECT_WIDTH-1 downto 0);
      dv_o                : out std_logic;
      dv_sequence_num_o   : out std_logic_vector(DV_NUM_WIDTH-1 downto 0);
      sync_box_err_o      : out std_logic;
      sync_box_err_ack_i  : in std_logic;
      sync_box_free_run_o : out std_logic;

      sync_mode_i         : in std_logic_vector(SYNC_SELECT_WIDTH-1 downto 0);
      sync_o              : out std_logic
   );
end dv_rx;

architecture top of dv_rx is

   ---------------------------------------------------------
   -- Signal Declarations
   ---------------------------------------------------------
   type states is (IDLE, FIBRE_DV_HIGH, FIBRE_DV_LOW, MANCH_DV_RCVD, MANCH_DV_ACK);
   signal current_state, next_state : states;

   type m_states is (IDLE, LATCH_MANCH_PACKET, RX_2, DONE);
   signal current_m_state, next_m_state : m_states;

   type sync_states is (IDLE, MANCH_SYNC_RCVD, MANCH_SYNC_ACK);
   signal current_s_state, next_s_state : sync_states;

   signal dv_dat_temp      : std_logic;
   signal dv_dat           : std_logic;

   signal manch_dat_temp   : std_logic;
   signal manch_det_temp   : std_logic;
   signal manch_dat        : std_logic;
   signal manch_det        : std_logic;
   signal manch_word       : std_logic_vector(MANCHESTER_WORD_WIDTH-1 downto 0);

   signal manch_reg_en     : std_logic;
   signal manch_sync       : std_logic;
   signal manch_dv         : std_logic;

   --00, followed by 6 spare bits, followed by a 32 bit number
   signal rx_buf_ena       : std_logic;

   constant MANCHESTER_PACKET_SIZE : std_logic_vector(7 downto 0) := "00101000";
   constant MANCHESTER_PACKET_SIZE_MINUS_1 : std_logic_vector(7 downto 0) := "00100111";

   signal sample_count     : std_logic_vector(7 downto 0);
   signal sample_count_ena : std_logic;
   signal sample_count_clr : std_logic;

   signal manch_rdy        : std_logic;
   signal manch_rdy_dly1   : std_logic;
   signal manch_rdy_dly2   : std_logic;

   signal manch_reg        : std_logic_vector(MANCHESTER_WORD_WIDTH-1 downto 0);
   signal manch_reg_dly1   : std_logic_vector(MANCHESTER_WORD_WIDTH-1 downto 0);
   signal manch_reg_dly2   : std_logic_vector(MANCHESTER_WORD_WIDTH-1 downto 0);

   signal dv_sequence_num      : std_logic_vector(DV_NUM_WIDTH-1 downto 0);
   signal reg_en               : std_logic;
   signal manch_ack            : std_logic;
   signal manch_ack1           : std_logic;
   signal manch_ack2           : std_logic;

   signal sync_box_err : std_logic;

begin

   ---------------------------------------------------------
   -- double synchronizer for dv_dat_i
   ---------------------------------------------------------
   process(rst_i, clk_n_i)
   begin
      if(rst_i = '1') then
         dv_dat_temp    <= '0';
      elsif(clk_n_i'event and clk_n_i = '1') then
         dv_dat_temp    <= dv_dat_i;
      end if;
   end process;

   process(rst_i, clk_i)
   begin
      if(rst_i = '1') then
         dv_dat          <= '0';
      elsif(clk_i'event and clk_i = '1') then
         dv_dat          <= dv_dat_temp;
      end if;
   end process;

   ---------------------------------------------------------
   -- double synchronizer for manch_dat and mach
   ---------------------------------------------------------
   -- A double synchronizer is implemented here for the manch_dat or manch_det signals.
   -- The manchester decoder spec sheet garuntees that the data signal is aligned with the clock.
   -- However, with synchronizers we can ensure that data is captured on the falling edge of the clock, when all signals have settled.
   process(rst_i, manch_clk_i)
   begin
      if(rst_i = '1') then
         manch_dat_temp <= '0';
         manch_det_temp <= '0';
      elsif(manch_clk_i'event and manch_clk_i = '0') then
         manch_dat_temp <= manch_dat_i;
         manch_det_temp <= manch_det_i;
      end if;
   end process;

   process(rst_i, manch_clk_i)
   begin
      if(rst_i = '1') then
         manch_dat <= '0';
         manch_det <= '0';
         manch_ack1 <= '0';
         manch_ack2 <= '0';
      elsif(manch_clk_i'event and manch_clk_i = '1') then
         manch_dat <= manch_dat_temp;
         manch_det <= manch_det_temp;
         manch_ack1 <= manch_ack;
         manch_ack2 <= manch_ack1;
      end if;
   end process;

   ---------------------------------------------------------
   -- Continuous Assignments
   ---------------------------------------------------------
   -- manch_sync and manch_dv are active low
   manch_sync          <= manch_reg_dly2(39);
   manch_dv            <= manch_reg_dly2(38);

   -- sync_box_free_run_o, sync_box_err_o and dv_sequence_num_o bits are active high
   sync_box_free_run_o <= manch_reg_dly2(36);

   dv_sequence_num_o   <= dv_sequence_num;

   ---------------------------------------------------------
   -- Error Register:
   ---------------------------------------------------------
   sync_box_err_o <= sync_box_err;
   process(rst_i, clk_i)
   begin
      if(rst_i = '1') then
         sync_box_err <= '0';
      elsif(clk_i'event and clk_i = '1') then
         if(sync_box_err_ack_i = '1') then
            sync_box_err <= '0';
         elsif(manch_reg_dly2(35) = '1') then
            sync_box_err <= '1';
         end if;
      end if;
   end process;

   ---------------------------------------------------------
   -- double synchronizer for manchester data:
   ---------------------------------------------------------
   process(rst_i, clk_i)
   begin
      if(rst_i = '1') then
         manch_reg_dly1 <= (others => '0');
         manch_reg_dly2 <= (others => '0');

         manch_rdy_dly1 <= '0';
         manch_rdy_dly2 <= '0';

         dv_sequence_num <= (others => '0');

      elsif(clk_i'event and clk_i = '1') then
         manch_reg_dly1 <= manch_reg;
         manch_reg_dly2 <= manch_reg_dly1;

         manch_rdy_dly1 <= manch_rdy;
         manch_rdy_dly2 <= manch_rdy_dly1;

         if(reg_en = '1') then
            dv_sequence_num <= manch_reg_dly2(DV_NUM_WIDTH-1 downto 0);
         else
            dv_sequence_num <= dv_sequence_num;
         end if;

      end if;
   end process;

   process(rst_i, manch_clk_i)
   begin
      if(rst_i = '1') then
         manch_reg       <= (others => '0');
      elsif(manch_clk_i'event and manch_clk_i = '1') then
         if (manch_reg_en = '1') then
            manch_reg <= manch_word;
         else
            manch_reg <= manch_reg;
         end if;
      end if;
   end process;

   ---------------------------------------------------------
   -- Manchester receiver
   ---------------------------------------------------------
   rx_buffer: shift_reg
   generic map(WIDTH => MANCHESTER_WORD_WIDTH)
   port map(
      clk_i      => manch_clk_i,
      rst_i      => rst_i,
      ena_i      => rx_buf_ena,
      load_i     => '0',
      clr_i      => '0',
      shr_i      => '0',
      serial_i   => manch_dat,
      serial_o   => open,
      parallel_i => (others => '0'),
      parallel_o => manch_word
   );

   sample_counter: binary_counter
   generic map(WIDTH => 8)
   port map(
      clk_i   => manch_clk_i,
      rst_i   => rst_i,
      ena_i   => sample_count_ena,
      up_i    => '1',
      load_i  => '0',
      clear_i => sample_count_clr,
      count_i => (others => '0'),
      count_o => sample_count
   );

   manch_state_ff: process(manch_clk_i, rst_i)
   begin
      if(rst_i = '1') then
         current_m_state <= IDLE;
      elsif(manch_clk_i'event and manch_clk_i = '1') then
         current_m_state <= next_m_state;
      end if;
   end process manch_state_ff;

   manch_ns: process(current_m_state, manch_dat, sample_count, manch_det)--, manch_ack2)
   begin
      next_m_state <= current_m_state;
      case current_m_state is

         when IDLE =>
            -- Manchester sync and DV are active low
            if (manch_det = '1' and manch_dat = '0') then
               next_m_state <= RX_2;
            end if;

         when LATCH_MANCH_PACKET =>
            next_m_state <= DONE;

         when RX_2 =>
            if (sample_count = MANCHESTER_PACKET_SIZE_MINUS_1) then
               next_m_state <= LATCH_MANCH_PACKET;
            else
               next_m_state <= RX_2;
            end if;

         when DONE =>
--            if(manch_ack2 = '1') then
               next_m_state <= IDLE;
--            end if;

         when others =>
            next_m_state <= IDLE;
      end case;
   end process manch_ns;

   manch_out: process(current_m_state, manch_dat, manch_det)
   begin
      -- Default Assignments
      rx_buf_ena       <= '0';
      sample_count_ena <= '0';
      sample_count_clr <= '0';
      manch_reg_en     <= '0';
      manch_rdy        <= '0';

      case current_m_state is

         when IDLE =>
            -- Manchester sync and DV are active low
            if (manch_det = '1' and manch_dat = '0') then
               rx_buf_ena       <= '1';
               sample_count_ena <= '1';
            end if;

         when LATCH_MANCH_PACKET =>
            manch_reg_en     <= '1';

         when RX_2 =>
            rx_buf_ena       <= '1';
            sample_count_ena <= '1';

         when DONE =>
            sample_count_clr <= '1';
            manch_rdy        <= '1';

         when others => NULL;
      end case;
   end process manch_out;

   ---------------------------------------------------------
   -- State Machine
   ---------------------------------------------------------
   state_ff: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         current_state <= IDLE;
         current_s_state <= IDLE;
      elsif(clk_i'event and clk_i = '1') then
         current_state <= next_state;
         current_s_state <= next_s_state;
      end if;
   end process state_ff;

   -- This state machine is tuned to execute with the same timing as the one below when a manchester packet arrives
   dv_ns: process(current_state, dv_mode_i, dv_dat, manch_rdy_dly2)
   begin
      next_state <= current_state;
      case current_state is

         when IDLE =>
            if(dv_mode_i = DV_EXTERNAL_FIBRE) then
               -- Note: the dv input is inverted, so if we detect '0', we wait for the rising edge.
               if(dv_dat = '0') then
                  next_state <= FIBRE_DV_HIGH;
               end if;
            elsif(dv_mode_i = DV_EXTERNAL_MANCHESTER) then
               if(manch_rdy_dly2 = '1') then
                  next_state <= MANCH_DV_RCVD;
               end if;
            end if;

         when FIBRE_DV_HIGH =>
            if(dv_dat = '1') then
               next_state <= FIBRE_DV_LOW;
            end if;

         when FIBRE_DV_LOW =>
            next_state <= IDLE;

         when MANCH_DV_RCVD =>
            next_state <= MANCH_DV_ACK;

         when MANCH_DV_ACK =>
--            if (manch_rdy_dly2 = '0') then
               next_state <= IDLE;
--            end if;

         when others =>
            next_state <= IDLE;
      end case;
   end process dv_ns;

   dv_out: process(current_state, manch_dv, dv_mode_i, manch_rdy_dly2)
   begin
      -- Default Assignments
      dv_o       <= '0';
      reg_en     <= '0';

      case current_state is

         when IDLE =>
            if(dv_mode_i = DV_EXTERNAL_MANCHESTER) then
               if(manch_rdy_dly2 = '1') then
                  -- Latch the DV sequence number only if a DV pulse has been received
                  if(manch_dv = '0') then
                     reg_en <= '1';
                  end if;
               end if;
            end if;

         when FIBRE_DV_HIGH =>

         when FIBRE_DV_LOW =>
            -- cmd_translator synchronizes the DV pulse with the clock cycle following the next sync pulse (only for fibre dv input)
            -- DV input from Manchester is alredy sync'd with sync pulse.
            dv_o <= '1';

         when MANCH_DV_RCVD =>
            -- Manchester sync and DV are active low
            dv_o <= not manch_dv;

         when MANCH_DV_ACK =>

         when others => NULL;
      end case;
   end process dv_out;

   -- This state machine is tuned to execute with the same timing as the one above when a manchester packet arrives
   sync_ns: process(current_s_state, manch_rdy_dly2)
   begin
      next_s_state <= current_s_state;
      case current_s_state is

         when IDLE =>
            -- If we have a manchester signal, then we may as well always output the sync
            -- Because syncs are never received from the dv input.
            if(manch_rdy_dly2 = '1') then
               next_s_state <= MANCH_SYNC_RCVD;
            end if;

         when MANCH_SYNC_RCVD =>
            next_s_state <= MANCH_SYNC_ACK;

         when MANCH_SYNC_ACK =>
--            if (manch_rdy_dly2 = '0') then
               next_s_state <= IDLE;
--            end if;

         when others =>
            next_s_state <= IDLE;

      end case;
   end process sync_ns;

   sync_out: process(current_s_state)
   begin
      -- Default Assignments
      sync_o <= '0';
--      manch_ack  <= '0';

      case current_s_state is

         when IDLE =>

         when MANCH_SYNC_RCVD =>
            -- Manchester sync and DV are active low
            -- The sync pulse is always included in the manchester packet.
            -- So I can just assert sync_o, instead of sync_o <= not manch_sync
            sync_o <= '1';

         when MANCH_SYNC_ACK =>
--            manch_ack <= '1';

         when others => NULL;
      end case;
   end process sync_out;

end top;


