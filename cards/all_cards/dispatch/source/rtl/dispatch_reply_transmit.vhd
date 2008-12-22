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
-- dispatch_reply_transmit.vhd
--
-- Project:       SCUBA-2
-- Author:         Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Implements the reply transmitter for the dispatch block.
--
-- Revision history:
--
-- $Log: dispatch_reply_transmit.vhd,v $
-- Revision 1.14  2007/12/18 20:24:39  bburger
-- BB:  Added a default state assignment to the FSM to lessen the likelyhood of uncontrolled state transitions
--
-- Revision 1.13  2006/05/04 23:10:57  mandana
-- added integer range for crc_num_words
--
-- Revision 1.12  2006/01/16 20:02:48  bburger
-- Ernie:   Added dip_sw interfaces to introduce artifical crc rx/tx errors on the busbackplan.  This feature is for testing purposes only.
--
-- Revision 1.11  2005/12/02 00:41:01  erniel
-- modified FSM to accomodate pipeline-mode buffer at dispatch top-level
--
-- Revision 1.10  2005/10/28 01:10:07  erniel
-- some minor name changes
--
-- Revision 1.9  2005/10/12 15:53:02  erniel
-- replaced serial CRC datapath and control with parallel CRC module
-- simplified and rewrote control FSM
-- replaced counters with binary counters
--
-- Revision 1.8  2005/03/18 23:08:43  erniel
-- updated changed buffer addr & data bus size constants
--
-- Revision 1.7  2005/01/11 20:52:44  erniel
-- updated lvds_tx component
-- removed mem_clk_i port
-- removed comm_clk_i port
--
-- Revision 1.6  2004/12/16 22:05:40  bburger
-- Bryce:  changes associated with lvds_tx and cmd_translator interface changes
--
-- Revision 1.5  2004/12/16 01:57:33  erniel
-- modified transmit FSM to account for new "queued" LVDS_tx
-- modified crc FSM to process words as quickly as possible
--
-- Revision 1.4  2004/10/18 20:48:51  erniel
-- corrected sensitivity list in process tx_stateNS
--
-- Revision 1.3  2004/09/27 23:02:13  erniel
-- using updated constants from command_pack
--
-- Revision 1.2  2004/09/11 00:56:52  erniel
-- added comments
--
-- Revision 1.1  2004/09/10 16:40:46  erniel
-- initial version
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

entity dispatch_reply_transmit is
port(
   clk_i      : in std_logic;
   rst_i      : in std_logic;

   lvds_txa_o : out std_logic;
   lvds_txb_o : out std_logic;

   -- Start/done signals:
   reply_start_i : in std_logic;
   reply_done_o  : out std_logic;

   -- Command header words:
   header0_i : in std_logic_vector(31 downto 0);
   header1_i : in std_logic_vector(31 downto 0);

   -- Buffer interface:
   buf_data_i : in std_logic_vector(31 downto 0);
   buf_addr_o : out std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);

   -- test interface
   dip_sw : in std_logic
);
end dispatch_reply_transmit;

architecture rtl of dispatch_reply_transmit is

   component lvds_tx
   port(
      clk_i      : in std_logic;
      rst_i      : in std_logic;
      dat_i      : in std_logic_vector(31 downto 0);
      rdy_i      : in std_logic;
      busy_o     : out std_logic;
      lvds_o     : out std_logic
   );
   end component;

   type transmitter_states is (IDLE, TX_HDR, FETCH, TX_DATA, TX_CRC, DONE);
   signal pres_state : transmitter_states;
   signal next_state : transmitter_states;

   signal lvds_tx_data_a : std_logic_vector(31 downto 0);
   signal lvds_tx_rdy_a  : std_logic;
   signal lvds_tx_busy_a : std_logic;

   signal lvds_tx_data_b : std_logic_vector(31 downto 0);
   signal lvds_tx_rdy_b  : std_logic;
   signal lvds_tx_busy_b : std_logic;

   signal word_count_ena : std_logic;
   signal word_count_clr : std_logic;
   signal word_count     : std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);

   signal crc_ena       : std_logic;
   signal crc_clr       : std_logic;
   signal crc_data      : std_logic_vector(31 downto 0);
   signal crc_checksum  : std_logic_vector(31 downto 0);
   signal crc_num_words : integer range 0 to 2**BB_DATA_SIZE_WIDTH + 4;
   signal crc_poly      : std_logic_vector(31 downto 0);

   signal toggle_state : std_logic;
   signal toggle : std_logic;
   signal toggle_clr : std_logic;
   constant CHANNEL_A : std_logic := '0';
   constant CHANNEL_B : std_logic := '1';

begin

   ---------------------------------------------------------
   -- LVDS transmitter
   ---------------------------------------------------------
   reply_tx_a: lvds_tx
   port map(
      clk_i      => clk_i,
      rst_i      => rst_i,
      dat_i      => lvds_tx_data_a,
      rdy_i      => lvds_tx_rdy_a,
      busy_o     => lvds_tx_busy_a,
      lvds_o     => lvds_txa_o);

   reply_tx_b: lvds_tx
   port map(
      clk_i      => clk_i,
      rst_i      => rst_i,
      dat_i      => lvds_tx_data_b,
      rdy_i      => lvds_tx_rdy_b,
      busy_o     => lvds_tx_busy_b,
      lvds_o     => lvds_txb_o);

   ---------------------------------------------------------
   -- CRC calculation
   ---------------------------------------------------------
   crc_calc : parallel_crc
   generic map(
      POLY_WIDTH => 32,
      DATA_WIDTH => 32)
   port map(
      clk_i       => clk_i,
      rst_i       => rst_i,
      clr_i       => crc_clr,
      ena_i       => crc_ena,
      poly_i      => crc_poly,    -- CRC-32 polynomial
      data_i      => crc_data,
      num_words_i => crc_num_words,
      done_o      => open,
      valid_o     => open,
      checksum_o  => crc_checksum
   );

   crc_num_words <= conv_integer(header0_i(BB_DATA_SIZE'range) + 2);
   crc_poly <= "00000100110000010001110110110111" when dip_sw = '1' else "10000100110000010001110110110111";


   ---------------------------------------------------------
   -- Counter for transmitted words
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

   buf_addr_o <= word_count;

   ---------------------------------------------------------
   -- Transmit controller FSM
   ---------------------------------------------------------
   tx_stateFF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         pres_state <= IDLE;
         toggle_state <= CHANNEL_A;
      elsif(clk_i'event and clk_i = '1') then
         pres_state <= next_state;
         if(toggle_clr = '1') then
            toggle_state <= CHANNEL_A;
         elsif(toggle = '1') then
            toggle_state <= not toggle_state;
         else
            toggle_state <= toggle_state;
         end if;
      end if;
   end process tx_stateFF;


   tx_stateNS: process(pres_state, reply_start_i, lvds_tx_busy_a, lvds_tx_busy_b, word_count, header0_i, toggle_state)
   begin
      -- Default Assignment
      next_state <= pres_state;

      case pres_state is
         when IDLE =>
            if(reply_start_i = '1') then
               next_state <= TX_HDR;
            end if;

         when TX_HDR =>
            if(toggle_state = CHANNEL_A and lvds_tx_busy_a = '0') then
               next_state <= TX_HDR;
            elsif(toggle_state = CHANNEL_B and lvds_tx_busy_b = '0') then
               if(header0_i(BB_DATA_SIZE'range) = 0) then
                  next_state <= TX_CRC;
               else
                  next_state <= FETCH;
               end if;
            end if;

         when FETCH =>
            next_state <= TX_DATA;

         when TX_DATA =>
            if(toggle_state = CHANNEL_A) then
               if(lvds_tx_busy_a = '0' and word_count = header0_i(BB_DATA_SIZE'range)-1) then
                  next_state <= TX_CRC;
               else
                  next_state <= FETCH;
               end if;
            else -- toggle_state = CHANNEL_B
               if(lvds_tx_busy_b = '0' and word_count = header0_i(BB_DATA_SIZE'range)-1) then
                  next_state <= TX_CRC;
               else
                  next_state <= FETCH;
               end if;
            end if;

         when TX_CRC =>
            if(toggle_state = CHANNEL_A) then
               if(lvds_tx_busy_a = '0') then
                  next_state <= DONE;
               end if;
            else -- toggle_state = CHANNEL_B
               if(lvds_tx_busy_b = '0') then
                  next_state <= DONE;
               end if;
            end if;

         when others =>
            next_state <= IDLE;
      end case;
   end process tx_stateNS;


   tx_stateOut: process(pres_state, lvds_tx_busy_a, lvds_tx_busy_b, header0_i, header1_i, buf_data_i, crc_checksum, toggle_state)
   begin
      word_count_ena <= '0';
      word_count_clr <= '0';
      crc_ena        <= '0';
      crc_clr        <= '0';
      crc_data       <= (others => '0');
      lvds_tx_rdy_a  <= '0';
      lvds_tx_data_a <= (others => '0');
      lvds_tx_rdy_b  <= '0';
      lvds_tx_data_b <= (others => '0');
      reply_done_o   <= '0';
      toggle         <= '0';
      toggle_clr     <= '0';

      case pres_state is
         when IDLE =>
            word_count_clr       <= '1';
            crc_clr              <= '1';
            --toggle_state         <= CHANNEL_A;
            toggle_clr           <= '1';

         when TX_HDR =>
            if(toggle_state = CHANNEL_A) then
               if(lvds_tx_busy_a = '0') then
                  crc_ena        <= '1';
                  lvds_tx_rdy_a  <= '1';
                  lvds_tx_data_a <= header0_i;
                  crc_data       <= header0_i;
                  --toggle_state   <= not toggle_state;
                  toggle         <= '1';
                  word_count_ena <= '1';
               end if;
            else -- toggle_state = CHANNEL_B
               if(lvds_tx_busy_b = '0') then
                  crc_ena        <= '1';
                  lvds_tx_rdy_b  <= '1';
                  lvds_tx_data_b <= header1_i;
                  crc_data       <= header1_i;
                  --toggle_state   <= not toggle_state;
                  toggle         <= '1';
                  word_count_clr <= '1';        -- in this state, word_count only reaches 1 before it gets reset
               end if;
            end if;

         when FETCH =>   null;

         when TX_DATA =>
            if(toggle_state = CHANNEL_A) then
               if(lvds_tx_busy_a = '0') then
                  word_count_ena    <= '1';
                  crc_ena           <= '1';
                  crc_data          <= buf_data_i;
                  lvds_tx_rdy_a     <= '1';
                  lvds_tx_data_a    <= buf_data_i;
                  --toggle_state <= not toggle_state;
                  toggle         <= '1';
               end if;
            else -- toggle_state = CHANNEL_B
               if(lvds_tx_busy_b = '0') then
                  word_count_ena    <= '1';
                  crc_ena           <= '1';
                  crc_data          <= buf_data_i;
                  lvds_tx_rdy_b     <= '1';
                  lvds_tx_data_b    <= buf_data_i;
                  --toggle_state <= not toggle_state;
                  toggle         <= '1';
               end if;
            end if;

         when TX_CRC =>
            if(toggle_state = CHANNEL_A) then
               if(lvds_tx_busy_a = '0') then
                  lvds_tx_rdy_a       <= '1';
                  lvds_tx_data_a      <= crc_checksum;
               end if;
            else -- toggle_state = CHANNEL_B
               if(lvds_tx_busy_b = '0') then
                  lvds_tx_rdy_b       <= '1';
                  lvds_tx_data_b      <= crc_checksum;
               end if;
            end if;

         when DONE =>
            reply_done_o         <= '1';

         when others =>  null;
      end case;
   end process tx_stateOut;

end rtl;