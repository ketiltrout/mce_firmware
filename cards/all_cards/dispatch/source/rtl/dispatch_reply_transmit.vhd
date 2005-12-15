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
-- Revision 1.8.2.1  2005/11/28 19:41:34  bburger
-- Bryce:  changed crc instatiation to serial_crc instatiation so that these files are compatible with the new library.  When the library crc block was replaced with serial_crc, these files were not updated in CVS to match!!!!!  They should have, Ernie!!!
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

library work;
use work.async_pack.all;
use work.dispatch_pack.all;

entity dispatch_reply_transmit is
port(clk_i      : in std_logic;
     rst_i      : in std_logic;     
     
     lvds_tx_o : out std_logic;
     
     reply_rdy_i : in std_logic;
     reply_ack_o : out std_logic;  -- reply sent, clear to send next
     
     -- Command header words:
     header0_i : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
     header1_i : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
     header2_i : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);  -- pass/fail word
     
     -- Buffer interface:
     buf_data_i : in std_logic_vector(REPLY_BUF_DATA_WIDTH-1 downto 0);
     buf_addr_o : out std_logic_vector(REPLY_BUF_ADDR_WIDTH-1 downto 0));
end dispatch_reply_transmit;

architecture rtl of dispatch_reply_transmit is

type transmitter_states is (IDLE_TX, CALC_CRC, SEND_WORD, SEND_CRC, TX_DONE);
signal tx_pres_state : transmitter_states;
signal tx_next_state : transmitter_states;

signal lvds_tx_data : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
signal lvds_tx_rdy  : std_logic;
signal lvds_tx_busy : std_logic;

signal word_count_ena : std_logic;
signal word_count_clr : std_logic;
signal word_count     : integer range 0 to MAX_DATA_WORDS+5;

signal reply_size    : std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);
signal reply_size_ld : std_logic;

signal reply_num_words : integer;

-- signals used in CRC datapath:

type crc_states is (IDLE_CRC, INITIALIZE_CRC, CALCULATE_CRC, CRC_WORD_DONE, LOAD_NEXT_WORD, CRC_ALL_DONE);
signal crc_pres_state : crc_states;
signal crc_next_state : crc_states;

signal data_shreg_ena : std_logic;
signal data_shreg_ld  : std_logic;
signal crc_cur_bit    : std_logic;
signal crc_word_in    : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
signal crc_word_out   : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);

signal crc_input_sel : std_logic_vector(1 downto 0);
signal tx_input_sel  : std_logic;

signal crc_bit_count_clr : std_logic;
signal crc_bit_count     : integer range 0 to PACKET_WORD_WIDTH;

signal crc_ena      : std_logic;
signal crc_clr      : std_logic;
signal crc_done     : std_logic;
signal crc_checksum : std_logic_vector(31 downto 0);

signal crc_num_bits : integer;

signal crc_start     : std_logic;
signal crc_word_rdy  : std_logic;
signal transmit_busy : std_logic;
signal transmit_done : std_logic;

begin

   ---------------------------------------------------------               
   -- Register for data size parameter
   ---------------------------------------------------------
   
   data_size_reg : reg
   generic map(WIDTH => BB_DATA_SIZE_WIDTH)
   port map(clk_i => clk_i,
            rst_i => rst_i,
            ena_i => reply_size_ld,
            reg_i => header0_i(BB_DATA_SIZE'range),
            reg_o => reply_size);
            
   -- number of bits to be processed by CRC is (# of data words + 2 header words + 1 pass/fail word) * 32
   crc_num_bits <= conv_integer((reply_size + 3) & "00000");
   
   -- number of words in packet (not including CRC) is (# of data words + 2 header words + 1 pass/fail word)
   reply_num_words <= conv_integer(reply_size + 3);
   
            
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

   crc_data_reg : shift_reg
      generic map(WIDTH => PACKET_WORD_WIDTH)
      port map(clk_i      => clk_i,
               rst_i      => rst_i,
               ena_i      => data_shreg_ena,
               load_i     => data_shreg_ld,
               clr_i      => '0',
               shr_i      => '1',
               serial_i   => crc_cur_bit, 
               serial_o   => crc_cur_bit,
               parallel_i => crc_word_in,
               parallel_o => crc_word_out);
                  
   crc_bit_counter : counter
      generic map(MAX         => PACKET_WORD_WIDTH,
                  STEP_SIZE   => 1,
                  WRAP_AROUND => '0',
                  UP_COUNTER  => '1')
      port map(clk_i   => clk_i,
               rst_i   => rst_i,
               ena_i   => '1',
               load_i  => crc_bit_count_clr,
               count_i => 0,
               count_o => crc_bit_count);

   crc_calc : serial_crc
      generic map(POLY_WIDTH => 32)
      port map(clk_i      => clk_i,
               rst_i      => rst_i,
               clr_i      => crc_clr,
               ena_i      => crc_ena,
               data_i     => crc_cur_bit,
               num_bits_i => crc_num_bits,
               poly_i     => CRC32,
               done_o     => crc_done,
               valid_o    => open,
               checksum_o => crc_checksum);
               
   -- CRC control FSM
   crc_stateFF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         crc_pres_state <= IDLE_CRC;
      elsif(clk_i'event and clk_i = '1') then
         crc_pres_state <= crc_next_state;
      end if;
   end process crc_stateFF;
   
   crc_stateNS: process(crc_pres_state, crc_start, crc_bit_count, crc_done, lvds_tx_rdy)
   begin
      case crc_pres_state is
         when IDLE_CRC =>       if(crc_start = '1') then
                                   crc_next_state <= INITIALIZE_CRC;  
                                else
                                   crc_next_state <= IDLE_CRC;
                                end if;
                                   
         when INITIALIZE_CRC => crc_next_state <= CALCULATE_CRC;
                                
         when CALCULATE_CRC =>  if(crc_bit_count = PACKET_WORD_WIDTH-1) then  -- when done processing all bits
                                   crc_next_state <= CRC_WORD_DONE;
                                else
                                   crc_next_state <= CALCULATE_CRC;
                                end if;
                          
         when CRC_WORD_DONE =>  if(lvds_tx_rdy = '1') then                    -- when done sending previous word, 
                                   if(crc_done = '1') then                    -- if this is the last data word, hold checksum for tx
                                      crc_next_state <= CRC_ALL_DONE;
                                   else                                       -- else prepare next data word
                                      crc_next_state <= LOAD_NEXT_WORD;
                                   end if;
                                else
                                   crc_next_state <= CRC_WORD_DONE;
                                end if;
         
         when LOAD_NEXT_WORD => crc_next_state <= CALCULATE_CRC;
         
         when CRC_ALL_DONE =>   if(lvds_tx_rdy = '1') then
                                   crc_next_state <= IDLE_CRC;
                                else
                                   crc_next_state <= CRC_ALL_DONE;
                                end if;
                                         
         when others =>         crc_next_state <= IDLE_CRC;
      end case;
   end process crc_stateNS;
   
   crc_stateOut: process(crc_pres_state)
   begin 
      data_shreg_ena    <= '0';
      data_shreg_ld     <= '0';  
      crc_bit_count_clr <= '0';
      crc_ena           <= '0';
      crc_clr           <= '0';
      crc_word_rdy      <= '0';
      
      case crc_pres_state is
         when INITIALIZE_CRC => data_shreg_ena    <= '1';
                                data_shreg_ld     <= '1';
                                crc_bit_count_clr <= '1';
                                crc_ena           <= '1';
                                crc_clr           <= '1';
                           
         when CALCULATE_CRC =>  data_shreg_ena    <= '1';
                                crc_ena           <= '1';
         
         when CRC_WORD_DONE =>  crc_word_rdy      <= '1';
         
         when LOAD_NEXT_WORD => data_shreg_ena    <= '1';
                                data_shreg_ld     <= '1';
                                crc_bit_count_clr <= '1';
                                
         when others =>         null;
      end case;
   end process crc_stateOut;


   ---------------------------------------------------------               
   -- Counters for transmitted words
   ---------------------------------------------------------   
   
   -- when word count = x, the x'th word is being transmitted (ie. header0 = word 1)
   word_counter : counter
   generic map(MAX => MAX_DATA_WORDS + 3)  -- there are 3 header words in addition to the data words
   port map(clk_i   => clk_i,
            rst_i   => rst_i,
            ena_i   => word_count_ena,
            load_i  => word_count_clr,
            count_i => 0,
            count_o => word_count);
            
   -- when word count = x, buffer addr x-3 is being accessed by CRC
   buf_addr_o <= conv_std_logic_vector(word_count - 3, REPLY_BUF_ADDR_WIDTH);  
   
   ---------------------------------------------------------               
   -- Multiplexors for inputs to CRC and LVDS blocks
   ---------------------------------------------------------
   
   with crc_input_sel select
      crc_word_in <= header0_i when "00",
                     header1_i when "01",
                     header2_i when "10",
                     buf_data_i when others;
   
   with tx_input_sel select
      lvds_tx_data <= crc_word_out when '0',
                      crc_checksum when others;
                      
      
   ---------------------------------------------------------
   -- Transmit controller FSM
   ---------------------------------------------------------
   tx_stateFF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         tx_pres_state <= IDLE_TX;
      elsif(clk_i'event and clk_i = '1') then
         tx_pres_state <= tx_next_state;
      end if;
   end process tx_stateFF;
   
   tx_stateNS: process(tx_pres_state, reply_rdy_i, crc_word_rdy, lvds_tx_busy, word_count, reply_num_words)
   begin
      case tx_pres_state is
         when IDLE_TX =>   if(reply_rdy_i = '1') then
                              tx_next_state <= CALC_CRC;
                           else
                              tx_next_state <= IDLE_TX;
                           end if;
                          
         when CALC_CRC =>  if(crc_word_rdy = '1') then                           -- when crc done processing first word, start transmit
                              tx_next_state <= SEND_WORD;
                           else
                              tx_next_state <= CALC_CRC;
                           end if;
         
         when SEND_WORD => if(lvds_tx_busy = '0') then    -- when transmitter available and crc of next word is done,
                              if(word_count = reply_num_words-1) then              -- if done transmitting last data word
                                 tx_next_state <= SEND_CRC;
                              else                                               -- else transmit next data word
                                 tx_next_state <= CALC_CRC;
                              end if;
                           else
                              tx_next_state <= SEND_WORD;
                           end if;
 
         when SEND_CRC =>  if(lvds_tx_busy = '0') then                -- when transmit done, assert transmit_done
                              tx_next_state <= TX_DONE;               -- (to allow crc to return to idle)
                           else
                              tx_next_state <= SEND_CRC;
                           end if;
                          
         when TX_DONE =>   tx_next_state <= IDLE_TX;
         
         when others =>    tx_next_state <= IDLE_TX;
      end case;
   end process tx_stateNS;
   
   tx_stateOut: process(tx_pres_state, word_count, lvds_tx_busy)
   begin
      case word_count is
         when 0 =>      crc_input_sel <= "00";
         when 1 =>      crc_input_sel <= "01";
         when 2 =>      crc_input_sel <= "10";
         when others => crc_input_sel <= "11";
      end case;
                                            
      -- default values:
      tx_input_sel   <= '0';
      reply_size_ld  <= '0';
      word_count_ena <= '0';
      word_count_clr <= '0';
      lvds_tx_rdy    <= '0';
      crc_start      <= '0';
      transmit_busy  <= '0';
      transmit_done  <= '0';
      reply_ack_o    <= '0';
      
      case tx_pres_state is
         when IDLE_TX =>   reply_size_ld  <= '1';
                           word_count_ena <= '1';
                           word_count_clr <= '1';
                                
         when CALC_CRC =>  crc_start      <= '1';
         
         when SEND_WORD => if(lvds_tx_busy = '0') then
                              tx_input_sel   <= '0';
                              word_count_ena <= '1';
                              lvds_tx_rdy    <= '1';
                           end if;

         when SEND_CRC =>  if(lvds_tx_busy = '0') then
                              tx_input_sel   <= '1';
                              lvds_tx_rdy    <= '1';
                           end if;
   
         when TX_DONE =>   reply_ack_o    <= '1';
      end case;
   end process tx_stateOut;
   
end rtl;