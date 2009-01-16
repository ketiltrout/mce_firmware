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
-- reply_queue_receiver.vhd
--
-- Project:       SCUBA-2
-- Author:        Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Implements a single receiver module for reply queue.
--
-- Revision history:
--
-- $Log: reply_queue_receive.vhd,v $
-- Revision 1.20  2008/12/22 20:49:28  bburger
-- BB:  Added a second LVDS receiver, and modified the FSM to support receiving interleaved data.
--
-- Revision 1.19  2007/12/18 20:33:23  bburger
-- BB:  Added a signal called bad_preamble_o that will all signaltap to trigger when the receiver gets a starting word that does not match the preamble
--
-- Revision 1.18  2007/07/24 23:12:23  bburger
-- BB:
-- - Cleaned out comments
--
-- Revision 1.17  2006/07/07 00:42:08  bburger
-- Bryce: changed the meaning of bit 2 of the error code to indicate whether the state machine has left idle.  This is used to determine if unexpected packets have been received by this block in reply_queue_sequencer
--
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library components;
use components.component_pack.all;

library sys_param;
use sys_param.command_pack.all;

entity reply_queue_receive is
   port(
      clk_i          : in std_logic;
      comm_clk_i     : in std_logic;
      rst_i          : in std_logic;

      lvds_reply_a_i : in std_logic;
      lvds_reply_b_i : in std_logic;

      error_o        : out std_logic_vector(2 downto 0);   -- 3 error bits: Tx CRC error, Rx CRC error, Execute Error
      bad_preamble_o : out std_logic;

      data_o         : out std_logic_vector(31 downto 0);
      rdy_o          : out std_logic;
      pres_n_o       : out std_logic;
      ack_i          : in std_logic;
      clear_i        : in std_logic
   );
end reply_queue_receive;

architecture rtl of reply_queue_receive is

   component lvds_rx
      port(
         clk_i      : in std_logic;
         comm_clk_i : in std_logic;
         rst_i      : in std_logic;
         dat_o      : out std_logic_vector(31 downto 0);
         rdy_o      : out std_logic;
         pres_n_o   : out std_logic;
         ack_i      : in std_logic;
         lvds_i     : in std_logic
      );
   end component;

   signal lvds_rx_data_a : std_logic_vector(31 downto 0);
   signal lvds_rx_rdy_a  : std_logic;
   signal lvds_rx_ack_a  : std_logic;
   signal pres_n_a       : std_logic;

   signal lvds_rx_data_b : std_logic_vector(31 downto 0);
   signal lvds_rx_rdy_b  : std_logic;
   signal lvds_rx_ack_b  : std_logic;
   signal pres_n_b       : std_logic;

   signal crc_ena       : std_logic;
   signal crc_clr       : std_logic;
   signal crc_valid     : std_logic;
   signal crc_num_words : integer;
   signal crc_data_in   : std_logic_vector(31 downto 0);

   signal buf_write   : std_logic;
   signal buf_read    : std_logic;
   signal buf_clear   : std_logic;
   signal buf_empty   : std_logic;
   signal buf_data_in : std_logic_vector(31 downto 0);

   signal header0    : std_logic_vector(31 downto 0);
   signal header1    : std_logic_vector(31 downto 0);
   signal header0_ld : std_logic;
   signal header1_ld : std_logic;

   signal error_clr : std_logic;
   signal error_ld  : std_logic;

   signal word_count     : std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);
   signal word_count_ena : std_logic;
   signal word_count_clr : std_logic;

   signal toggle_state : std_logic;
   signal toggle : std_logic;
   signal toggle_clr : std_logic;
   constant CHANNEL_A : std_logic := '0';
   constant CHANNEL_b : std_logic := '1';

   type states is (RX_INIT, RX_HEADER0, RX_HEADER1, RX_DATA, RX_CRC, RX_DONE, STATUS_READY, DATA_READY);
   signal pres_state : states;
   signal next_state : states;

begin

   ---------------------------------------------------------
   -- LVDS receiver
   ---------------------------------------------------------
   pres_n_o <= pres_n_a or pres_n_b;

   -- This block receives header0, and every even-indexed data word
   lvds_receiver_a : lvds_rx
      port map(
         clk_i      => clk_i,
         comm_clk_i => comm_clk_i,
         rst_i      => rst_i,
         dat_o      => lvds_rx_data_a,
         rdy_o      => lvds_rx_rdy_a,
         pres_n_o   => pres_n_a,
         ack_i      => lvds_rx_ack_a,
         lvds_i     => lvds_reply_a_i
      );

   -- This block receives header0, and every odd-indexed data word
   lvds_receiver_b : lvds_rx
      port map(
         clk_i      => clk_i,
         comm_clk_i => comm_clk_i,
         rst_i      => rst_i,
         dat_o      => lvds_rx_data_b,
         rdy_o      => lvds_rx_rdy_b,
         pres_n_o   => pres_n_b,
         ack_i      => lvds_rx_ack_b,
         lvds_i     => lvds_reply_b_i
      );
   ---------------------------------------------------------
   -- CRC validation
   ---------------------------------------------------------
   -- This fifo's data input is switched between LVDS lines a/ b.
   crc_calc : parallel_crc
      generic map(
         POLY_WIDTH => 32,
         DATA_WIDTH => 32
      )
      port map(
         clk_i       => clk_i,
         rst_i       => rst_i,
         clr_i       => crc_clr,
         ena_i       => crc_ena,
         poly_i      => "00000100110000010001110110110111",    -- CRC-32 polynomial
--         data_i      => lvds_rx_data_a,
         data_i      => crc_data_in,
         num_words_i => crc_num_words,
         done_o      => open,
         valid_o     => crc_valid,
         checksum_o  => open
      );

   crc_num_words <= conv_integer(header0(BB_DATA_SIZE'range) + 3);   -- data_size words + 2 headers + 1 CRC

   ---------------------------------------------------------
   -- Packet storage
   ---------------------------------------------------------
   -- This fifo's data input is switched between LVDS lines a/ b.
   packet_buffer : fifo
      generic map(
         DATA_WIDTH => 32,
         ADDR_WIDTH => BB_DATA_SIZE_WIDTH)
      port map(
         clk_i   => clk_i,
         rst_i   => rst_i,
--         data_i  => lvds_rx_data_a,
         data_i  => buf_data_in,
         data_o  => data_o,
         read_i  => buf_read,
         write_i => buf_write,
         clear_i => buf_clear,
         empty_o => buf_empty,
         full_o  => open,
         error_o => open,
         used_o  => open
      );

   -- This is connected to LVDS line 'a'
   header0_reg : reg
      generic map(WIDTH => 32)
      port map(
         clk_i => clk_i,
         rst_i => rst_i,
         ena_i => header0_ld,
         reg_i => lvds_rx_data_a,
         reg_o => header0
      );

   -- This is connected to LVDS line 'b'
   header1_reg : reg
      generic map(WIDTH => 32)
      port map(
         clk_i => clk_i,
         rst_i => rst_i,
         ena_i => header1_ld,
         reg_i => lvds_rx_data_b,
         reg_o => header1
      );

   ---------------------------------------------------------
   -- Error (Status) register
   ---------------------------------------------------------
   error_reg : process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         error_o <= (others => '0');
      elsif(clk_i'event and clk_i = '1') then
         if(error_clr = '1') then
            error_o <= (others => '0');
         elsif(error_ld = '1') then
               error_o(0) <= header1(1);                                -- Wishbone execution error
               error_o(1) <= (not crc_valid) or header1(0);             -- LVDS rx error in dispatch or reply_queue_receive (CRC error)
               if(pres_state = RX_HEADER0) then
                  error_o(2) <= '0';
               else
                  error_o(2) <= '1';
               end if;

--               error_o(2) <= '0' when (pres_state = RX_HEADER0) else '1'; -- Used to determine if the wrong card is replying
--            if(crc_valid = '0') then
--               error_o(0) <= '0';           -- if receive CRC failed, flag Rx CRC error condition
--               error_o(1) <= '0';           -- other error flags are meaningless
--               error_o(2) <= '1';
--            else
--               error_o(0) <= header1(0);    -- otherwise show error conditions received from dispatch
--               error_o(1) <= header1(1);
--               error_o(2) <= '0';
--            end if;

         end if;
      end if;
   end process error_reg;

   ---------------------------------------------------------
   -- Counter for received words
   ---------------------------------------------------------
   word_counter : binary_counter
      generic map(WIDTH => BB_DATA_SIZE_WIDTH)
      port map(
         clk_i   => clk_i,
         rst_i   => rst_i,
         ena_i   => word_count_ena,
         up_i    => '1',
         load_i  => '0',
         clear_i => word_count_clr,
         count_i => (others => '0'),
         count_o => word_count
      );

   ---------------------------------------------------------
   -- Receive controller FSM
   ---------------------------------------------------------
   state_FF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         pres_state <= RX_INIT;
         toggle_state <= CHANNEL_A;

      elsif(clk_i'event and clk_i = '1') then

         if(clear_i = '1') then
            pres_state <= RX_INIT;
         else
            pres_state <= next_state;
         end if;


         if(toggle_clr = '1') then
            toggle_state <= CHANNEL_A;
         elsif(toggle = '1') then
            toggle_state <= not toggle_state;
         else
            toggle_state <= toggle_state;
         end if;

      end if;
   end process state_FF;

   state_NS: process(pres_state, lvds_rx_rdy_a, lvds_rx_data_a, lvds_rx_rdy_b, --lvds_rx_data_b,
      word_count, header0, crc_valid, buf_empty, ack_i, toggle_state)
   begin
      -- Default Assignment
      next_state <= pres_state;

      case pres_state is
         when RX_INIT =>
            next_state <= RX_HEADER0;

         when RX_HEADER0 =>
            if(lvds_rx_rdy_a = '1' and lvds_rx_data_a(BB_PREAMBLE'range) = BB_PREAMBLE) then
               next_state <= RX_HEADER1;
            else
               next_state <= RX_HEADER0;
            end if;

         when RX_HEADER1 =>
            if(lvds_rx_rdy_b = '1') then
               next_state <= RX_DATA;
            else
               next_state <= RX_HEADER1;
            end if;

         when RX_DATA =>
            if(word_count = header0(BB_DATA_SIZE'range)) then
               next_state <= RX_CRC;
            else
               next_state <= RX_DATA;
            end if;

         when RX_CRC =>
            if(lvds_rx_rdy_a = '1' and toggle_state = CHANNEL_A) then
               next_state <= RX_DONE;
            elsif(lvds_rx_rdy_b = '1' and toggle_state = CHANNEL_B) then
               next_state <= RX_DONE;
            else
               next_state <= RX_CRC;
            end if;

         when RX_DONE =>
            if(crc_valid = '0' or header0(BB_COMMAND_TYPE'range) = WRITE_CMD) then
               next_state <= STATUS_READY;
            else
               next_state <= DATA_READY;
            end if;

         when STATUS_READY =>
            if(ack_i = '1') then
               next_state <= RX_INIT;
            else
               next_state <= STATUS_READY;
            end if;

         -- If bandwidth needs to be increased, one could start clocking data out to the fibre
         -- as soon as the first few words hit the buffer here.
         when DATA_READY =>
            if(buf_empty = '1') then
               next_state <= RX_INIT;
            else
               next_state <= DATA_READY;
            end if;

         when others =>
            next_state <= RX_INIT;
      end case;
   end process state_NS;

   state_Out: process(pres_state, lvds_rx_rdy_a, lvds_rx_data_a, lvds_rx_rdy_b, lvds_rx_data_b,
      word_count, header0, crc_valid, buf_empty, ack_i, toggle_state)
   begin
      lvds_rx_ack_a  <= '0';
      lvds_rx_ack_b  <= '0';

      crc_ena        <= '0';
      crc_clr        <= '0';
      crc_data_in    <= lvds_rx_data_a;

      buf_write      <= '0';
      buf_read       <= '0';
      buf_clear      <= '0';
      buf_data_in    <= lvds_rx_data_a;

      header0_ld     <= '0';
      header1_ld     <= '0';

      error_clr      <= '0';
      error_ld       <= '0';

      word_count_ena <= '0';
      word_count_clr <= '0';

      rdy_o          <= '0';

      bad_preamble_o <= '0';
--      toggle_state <= toggle_state;
      toggle         <= '0';
      toggle_clr     <= '0';

      case pres_state is
         when RX_INIT =>
            crc_clr           <= '1';
            buf_clear         <= '1';
            error_clr         <= '1';
            word_count_clr    <= '1';
            toggle_clr        <= '1';
            --toggle_state      <= CHANNEL_A;

         when RX_HEADER0 =>
            if(lvds_rx_rdy_a = '1') then
               if(lvds_rx_data_a(BB_PREAMBLE'range) /= BB_PREAMBLE) then
                  crc_clr        <= '1';         -- reset CRC calculation during resynchronization
                  bad_preamble_o <= '1';
                  -- In the case of a bad preamble, strobe both lvds_rx_ack_a and lvds_rx_ack_b, to clear out both buffers.
                  lvds_rx_ack_b  <= '1';
               end if;
               lvds_rx_ack_a     <= '1';
               crc_ena           <= '1';
               crc_data_in       <= lvds_rx_data_a;
               header0_ld        <= '1';
            end if;

         when RX_HEADER1 =>
            if(lvds_rx_rdy_b = '1') then
               lvds_rx_ack_b     <= '1';
               crc_data_in       <= lvds_rx_data_b;
               crc_ena           <= '1';
               header1_ld        <= '1';
            end if;

         when RX_DATA =>
            if(word_count /= header0(BB_DATA_SIZE'range)) then
               if(lvds_rx_rdy_a = '1' and toggle_state = CHANNEL_A) then
                  lvds_rx_ack_a  <= '1';
                  crc_data_in    <= lvds_rx_data_a;
                  crc_ena        <= '1';
                  buf_data_in    <= lvds_rx_data_a;
                  buf_write      <= '1';
                  word_count_ena <= '1';
                  --toggle_state   <= CHANNEL_B;
                  toggle         <= '1';
               elsif(lvds_rx_rdy_b = '1' and toggle_state = CHANNEL_B) then
                  lvds_rx_ack_b  <= '1';
                  crc_data_in    <= lvds_rx_data_b;
                  crc_ena        <= '1';
                  buf_data_in    <= lvds_rx_data_b;
                  buf_write      <= '1';
                  word_count_ena <= '1';
                  --toggle_state   <= CHANNEL_A;
                  toggle         <= '1';
               end if;
            end if;

         when RX_CRC =>
            if(lvds_rx_rdy_a = '1' and toggle_state = CHANNEL_A) then
               lvds_rx_ack_a  <= '1';
               crc_data_in    <= lvds_rx_data_a;
               crc_ena        <= '1';
            elsif(lvds_rx_rdy_b = '1' and toggle_state = CHANNEL_B) then
               lvds_rx_ack_b  <= '1';
               crc_data_in    <= lvds_rx_data_b;
               crc_ena        <= '1';
            end if;

         when RX_DONE =>
            error_ld          <= '1';
            if(crc_valid = '0') then
               buf_clear      <= '1';
            end if;

         when STATUS_READY =>
            rdy_o             <= '1';

         when DATA_READY =>
            if(buf_empty = '0') then
               rdy_o          <= '1';
            end if;
            if(ack_i = '1') then
               buf_read       <= '1';
            end if;

         when others =>
            null;

      end case;
   end process state_Out;
end rtl;