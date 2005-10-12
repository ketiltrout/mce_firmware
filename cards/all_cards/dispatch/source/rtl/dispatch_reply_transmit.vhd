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
port(clk_i      : in std_logic;
     rst_i      : in std_logic;     
     
     lvds_tx_o : out std_logic;
     
     reply_rdy_i : in std_logic;
     reply_ack_o : out std_logic;  -- reply sent, clear to send next
     
     -- Command header words:
     header0_i : in std_logic_vector(31 downto 0);
     header1_i : in std_logic_vector(31 downto 0);
     
     -- Buffer interface:
     buf_data_i : in std_logic_vector(31 downto 0);
     buf_addr_o : out std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0));
end dispatch_reply_transmit;

architecture rtl of dispatch_reply_transmit is

component lvds_tx
port(clk_i      : in std_logic;
     rst_i      : in std_logic;
     dat_i      : in std_logic_vector(31 downto 0);
     rdy_i      : in std_logic;
     busy_o     : out std_logic;
     lvds_o     : out std_logic);
end component;

type transmitter_states is (IDLE, TX_HDR, TX_DATA, TX_CRC, DONE);
signal pres_state : transmitter_states;
signal next_state : transmitter_states;

signal lvds_tx_data : std_logic_vector(31 downto 0);
signal lvds_tx_rdy  : std_logic;
signal lvds_tx_busy : std_logic;

signal word_count_ena : std_logic;
signal word_count_clr : std_logic;
signal word_count     : std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);

signal crc_ena       : std_logic;
signal crc_clr       : std_logic;
signal crc_data      : std_logic_vector(31 downto 0);
signal crc_checksum  : std_logic_vector(31 downto 0);
signal crc_num_words : integer;

begin

   ---------------------------------------------------------
   -- LVDS transmitter
   ---------------------------------------------------------

   reply_tx: lvds_tx
   port map(clk_i      => clk_i,
            rst_i      => rst_i,
            dat_i      => lvds_tx_data,
            rdy_i      => lvds_tx_rdy,
            busy_o     => lvds_tx_busy,
            lvds_o     => lvds_tx_o);
            
                                 
   ---------------------------------------------------------
   -- CRC calculation
   ---------------------------------------------------------

   crc_calc : parallel_crc
      generic map(POLY_WIDTH => 32,
                  DATA_WIDTH => 32)
      port map(clk_i       => clk_i,
               rst_i       => rst_i,
               clr_i       => crc_clr,
               ena_i       => crc_ena,
               poly_i      => "00000100110000010001110110110111",    -- CRC-32 polynomial
               data_i      => crc_data,
               num_words_i => crc_num_words,
               done_o      => open,
               valid_o     => open,
               checksum_o  => crc_checksum);
    
   crc_num_words <= conv_integer(header0_i(BB_DATA_SIZE'range) + 2);           


   ---------------------------------------------------------               
   -- Counter for transmitted words
   ---------------------------------------------------------   
   
   word_counter : binary_counter
   generic map(WIDTH => BB_DATA_SIZE_WIDTH)
   port map(clk_i   => clk_i,
            rst_i   => rst_i,
            ena_i   => word_count_ena,
            up_i    => '1',
            load_i  => '0',
            clear_i => word_count_clr,
            count_i => (others => '0'),
            count_o => word_count);
            
   buf_addr_o <= word_count;
   
   
   ---------------------------------------------------------
   -- Transmit controller FSM
   ---------------------------------------------------------
   tx_stateFF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         pres_state <= IDLE;
      elsif(clk_i'event and clk_i = '1') then
         pres_state <= next_state;
      end if;
   end process tx_stateFF;
   
   tx_stateNS: process(pres_state, reply_rdy_i, lvds_tx_busy, word_count, header0_i)
   begin
      case pres_state is
         when IDLE =>      if(reply_rdy_i = '1') then
                              next_state <= TX_HDR;
                           else
                              next_state <= IDLE;
                           end if;
         
         when TX_HDR =>    if(lvds_tx_busy = '0' and word_count = 1) then 
                              if(header0_i(BB_DATA_SIZE'range) = 0) then
                                 next_state <= TX_CRC;
                              else
                                 next_state <= TX_DATA;
                              end if;
                           else
                              next_state <= TX_HDR;
                           end if;
         
         when TX_DATA =>   if(lvds_tx_busy = '0' and word_count = header0_i(BB_DATA_SIZE'range)-1) then
                              next_state <= TX_CRC;
                           else
                              next_state <= TX_DATA;
                           end if;
                           
         when TX_CRC =>    if(lvds_tx_busy = '0') then
                              next_state <= DONE;
                           else
                              next_state <= TX_CRC;
                           end if;
         
         when others =>    next_state <= IDLE;
      end case;
   end process tx_stateNS;
   
   tx_stateOut: process(pres_state, word_count, lvds_tx_busy, header0_i, header1_i, buf_data_i, crc_checksum)
   begin
      word_count_ena <= '0';
      word_count_clr <= '0';
      crc_ena        <= '0';
      crc_clr        <= '0';
      crc_data       <= (others => '0');
      lvds_tx_rdy    <= '0';
      lvds_tx_data   <= (others => '0');
      reply_ack_o    <= '0';
      
      case pres_state is
         when IDLE =>    word_count_clr       <= '1';
                         crc_clr              <= '1';
                      
         when TX_HDR =>  if(lvds_tx_busy = '0') then
                            crc_ena           <= '1';
                            lvds_tx_rdy       <= '1';
                               
                            if(word_count = 0) then
                               word_count_ena <= '1';
                               lvds_tx_data   <= header0_i;
                               crc_data       <= header0_i;
                            else
                               word_count_clr <= '1';        -- in this state, word_count only reaches 1 before it gets reset
                               lvds_tx_data   <= header1_i;
                               crc_data       <= header1_i;
                            end if;
                         end if;
         
         when TX_DATA => if(lvds_tx_busy = '0') then
                            word_count_ena    <= '1';
                            crc_ena           <= '1';
                            crc_data          <= buf_data_i;
                            lvds_tx_rdy       <= '1';
                            lvds_tx_data      <= buf_data_i;
                         end if;
         
         when TX_CRC =>  if(lvds_tx_busy = '0') then
                            lvds_tx_rdy       <= '1';
                            lvds_tx_data      <= crc_checksum;
                         end if;
         
         when DONE =>    reply_ack_o          <= '1';
         
         when others =>  null;
      end case;
   end process tx_stateOut;
   
end rtl;