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
-- dispatch_cmd_receive.vhd
--
-- Project:	      SCUBA-2
-- Author:	       Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Implements the receiver and command parser for the dispatch block
--
-- Revision history:
-- 
-- $Log: dispatch_cmd_receive.vhd,v $
-- Revision 1.12  2005/01/12 23:23:41  erniel
-- updated lvds_rx component
--
-- Revision 1.11  2005/01/11 20:41:41  erniel
-- replaced CARD generic with card_i port
--
-- Revision 1.10  2004/12/11 00:32:01  erniel
-- put a range on integers: hdr_word_count, data_word_count & crc_bit_count
--
-- Revision 1.9  2004/12/06 20:30:31  erniel
-- fixed handling of READ commands by receive FSM
--
-- Revision 1.8  2004/11/26 01:38:47  erniel
-- fixed handling of READ commands by CRC subblock
--
-- Revision 1.7  2004/10/18 20:48:16  erniel
-- corrected sensitivity list in processes rx_stateNS and rx_stateOut
--
-- Revision 1.6  2004/09/27 23:02:22  erniel
-- using updated constants from command_pack
--
-- Revision 1.5  2004/09/11 01:02:49  erniel
-- minor signal name changes
--
-- Revision 1.4  2004/08/28 03:12:45  erniel
-- updated constant names from dispatch_pack
-- renamed several signals to match those used in dispatch_reply_transmit
--
-- Revision 1.3  2004/08/23 20:39:10  erniel
-- removed separate parameter outputs
-- some internal signal name changes
--
-- Revision 1.2  2004/08/10 00:35:35  erniel
-- initial version
--
-- Revision 1.1  2004/08/04 19:42:55  erniel
-- WARNING: not functional, work in progress
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

entity dispatch_cmd_receive is
port(clk_i      : in std_logic;
     comm_clk_i : in std_logic;
     rst_i      : in std_logic;		
     
     lvds_cmd_i : in std_logic;
     card_i     : in std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0);
     
     cmd_rdy_o : out std_logic;  -- indicates receive completed
     cmd_err_o : out std_logic;  -- indicates command failed CRC check
     
     -- Command header words:
     header0_o : out std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
     header1_o : out std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
     
     -- Buffer interface (stores data from command packet):
     buf_data_o : out std_logic_vector(BUF_DATA_WIDTH-1 downto 0);
     buf_addr_o : out std_logic_vector(BUF_ADDR_WIDTH-1 downto 0);
     buf_wren_o : out std_logic);
end dispatch_cmd_receive;

architecture rtl of dispatch_cmd_receive is

type receiver_states is (RX_HDR, RX_DATA, RX_CRC, INCR_HDR, INCR_DATA, INCR_SKIP, PARSE_HDR, WRITE_BUF, SKIP_CMD, LATCH_HDR, DONE, ERROR);
signal rx_pres_state : receiver_states;
signal rx_next_state : receiver_states;

signal lvds_rx_data : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
signal lvds_rx_rdy  : std_logic;
signal lvds_rx_ack  : std_logic;

signal temp0    : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
signal temp0_ld : std_logic;
signal temp1    : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
signal temp1_ld : std_logic;

signal header_ld : std_logic;

signal cmd_data_size : integer;
signal cmd_type      : std_logic_vector(BB_COMMAND_TYPE_WIDTH-1 downto 0);
signal cmd_valid     : std_logic;

signal hdr_word_count_ena : std_logic;
signal hdr_word_count     : integer range 0 to BB_NUM_CMD_HEADER_WORDS-1;

signal data_word_count_ena : std_logic;
signal data_word_count_clr : std_logic;
signal data_word_count     : integer range 0 to MAX_DATA_WORDS-1;


-- signals used in CRC datapath:

type crc_states is (IDLE_CRC, INITIALIZE_CRC, CALCULATE_CRC, CRC_WORD_DONE, SYNC_PREAMBLE, RECEIVE_WORD, LOAD_NEXT_WORD);
signal crc_pres_state : crc_states;
signal crc_next_state : crc_states;

signal data_size_ld   : std_logic;
signal data_size_temp : std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);
signal data_size      : std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);

signal data_shreg_ena : std_logic;
signal data_shreg_ld  : std_logic;
signal crc_cur_bit    : std_logic;
signal crc_word_out   : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);

signal crc_bit_count_clr : std_logic;
signal crc_bit_count     : integer range 0 to PACKET_WORD_WIDTH;

signal crc_ena   : std_logic;
signal crc_clr   : std_logic;
signal crc_done  : std_logic;
signal crc_valid : std_logic;

signal crc_num_bits : integer;

signal crc_word_rdy : std_logic;

begin

   ---------------------------------------------------------
   -- LVDS receiver
   ---------------------------------------------------------
   
   cmd_rx: lvds_rx
      port map(comm_clk_i => comm_clk_i,
               rst_i      => rst_i,
               dat_o      => lvds_rx_data,
               rdy_o      => lvds_rx_rdy,
               ack_i      => lvds_rx_ack,
               lvds_i     => lvds_cmd_i);
     
                       
   ---------------------------------------------------------
   -- CRC validation
   ---------------------------------------------------------
   
   -- CRC datapath
   crc_data_size_reg : reg
      generic map(WIDTH => BB_DATA_SIZE_WIDTH)
      port map(clk_i => clk_i,
               rst_i => rst_i,
               ena_i => data_size_ld,
               reg_i => data_size_temp,
               reg_o => data_size);

   -- for READ commands, data size is 0.  
   -- for WRITE commands, data size is given by data size field of packet.
   data_size_temp <= (others => '0') when lvds_rx_data(BB_COMMAND_TYPE'range) = READ_CMD else lvds_rx_data(BB_DATA_SIZE'range);
   
   -- number of bits to be processed by CRC is (2 header words + 1 CRC word + data size) * 32 bits/word
   crc_num_bits <= conv_integer((data_size + 3) & "00000");

   crc_data_reg : shift_reg
      generic map(WIDTH => PACKET_WORD_WIDTH)
      port map(clk_i      => clk_i,
               rst_i      => rst_i,
               ena_i      => data_shreg_ena,
               load_i     => data_shreg_ld,
               clr_i      => '0',
               shr_i      => '1',            -- CRC is calculated LSB first
               serial_i   => crc_cur_bit,    -- this makes the shift register a rotator! (eliminates need for separate buffer)
               serial_o   => crc_cur_bit,
               parallel_i => lvds_rx_data,
               parallel_o => crc_word_out);
   
   crc_bit_counter : counter
      generic map(MAX         => PACKET_WORD_WIDTH,
                  WRAP_AROUND => '0')
      port map(clk_i   => clk_i,
               rst_i   => rst_i,
               ena_i   => '1',
               load_i  => crc_bit_count_clr,
               count_i => 0,
               count_o => crc_bit_count);

   crc_calc : crc
      generic map(POLY_WIDTH => 32)
      port map(clk_i      => clk_i,
               rst_i      => rst_i,
               clr_i      => crc_clr,
               ena_i      => crc_ena,
               data_i     => crc_cur_bit,
               num_bits_i => crc_num_bits,
               poly_i     => CRC32,
               done_o     => crc_done,
               valid_o    => crc_valid,
               checksum_o => open);
           
   -- CRC control FSM
   crc_stateFF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         crc_pres_state <= IDLE_CRC;
      elsif(clk_i'event and clk_i = '1') then
         crc_pres_state <= crc_next_state;
      end if;
   end process crc_stateFF;
   
   
   -- Notes: - CRC receiver starts on valid preamble boundaries.
   --        - If receiver loses packet sync, words will be ignored:
   --             1. wait until return to CRC idle state (could be up to 8k words later), then
   --             2. wait until valid preamble is detected.
   
   crc_stateNS: process(crc_pres_state, lvds_rx_rdy, lvds_rx_data, crc_bit_count, crc_done)
   begin
      case crc_pres_state is
         when IDLE_CRC =>       if(lvds_rx_rdy = '1') then
                                   if(lvds_rx_data(BB_PREAMBLE'range) = BB_PREAMBLE) then    -- valid preamble detected
                                      crc_next_state <= INITIALIZE_CRC;  
                                   else
                                      crc_next_state <= SYNC_PREAMBLE;
                                   end if;
                                else
                                   crc_next_state <= IDLE_CRC;
                                end if;
                                   
         when INITIALIZE_CRC => crc_next_state <= CALCULATE_CRC;
                                
         when SYNC_PREAMBLE =>  if(lvds_rx_rdy = '1' and lvds_rx_data(BB_PREAMBLE'range) = BB_PREAMBLE) then
                                   crc_next_state <= INITIALIZE_CRC;  
                                else
                                   crc_next_state <= SYNC_PREAMBLE;
                                end if;         
                  
         when CALCULATE_CRC =>  if(crc_bit_count = PACKET_WORD_WIDTH-1) then
                                   crc_next_state <= CRC_WORD_DONE;
                                else
                                   crc_next_state <= CALCULATE_CRC;
                                end if;
                          
         when CRC_WORD_DONE =>  crc_next_state <= RECEIVE_WORD;
                                         
         when RECEIVE_WORD =>   if(crc_done = '1') then
                                   crc_next_state <= IDLE_CRC;
                                elsif(lvds_rx_rdy = '1') then 
                                   crc_next_state <= LOAD_NEXT_WORD;
                                else
                                   crc_next_state <= RECEIVE_WORD;
                                end if;
                            
         when LOAD_NEXT_WORD => crc_next_state <= CALCULATE_CRC;
         
         when others =>         crc_next_state <= IDLE_CRC;
      end case;
   end process crc_stateNS;
   
   crc_stateOut: process(crc_pres_state, lvds_rx_data)
   begin
      lvds_rx_ack       <= '0';   
      data_size_ld      <= '0';
      data_shreg_ena    <= '0';
      data_shreg_ld     <= '0';      
      crc_bit_count_clr <= '0';
      crc_ena           <= '0';
      crc_clr           <= '0';
      crc_word_rdy      <= '0';
      
      case crc_pres_state is
         when INITIALIZE_CRC => lvds_rx_ack       <= '1';  
                                data_size_ld      <= '1';
                                data_shreg_ld     <= '1';
                                data_shreg_ena    <= '1';
                                crc_bit_count_clr <= '1';
                                crc_ena           <= '1';
                                crc_clr           <= '1';
         
         when SYNC_PREAMBLE =>  if(lvds_rx_data(BB_PREAMBLE'range) /= BB_PREAMBLE) then 
                                   lvds_rx_ack    <= '1'; 
                                end if;
                           
         when CALCULATE_CRC =>  data_shreg_ena    <= '1';
                                crc_ena           <= '1';
         
         when CRC_WORD_DONE =>  crc_word_rdy      <= '1';
         
         when LOAD_NEXT_WORD => lvds_rx_ack       <= '1';
                                data_shreg_ena    <= '1';
                                data_shreg_ld     <= '1';
                                crc_bit_count_clr <= '1';
                                
         when others =>         null;
      end case;
   end process crc_stateOut;


   ---------------------------------------------------------
   -- Temp registers for header words
   ---------------------------------------------------------
   
   -- Notes: - Every time a new command arrives, its header words are stored regardless of whether the command is valid or not.
   --        - When the second header word is received, cmd_valid tells the receiver FSM if the command is valid.

   tmp_word0 : reg
      generic map(WIDTH => PACKET_WORD_WIDTH)
      port map(clk_i  => clk_i,
               rst_i  => rst_i,
               ena_i  => temp0_ld,
               reg_i  => crc_word_out,
               reg_o  => temp0);
   
   tmp_word1 : reg
      generic map(WIDTH => PACKET_WORD_WIDTH)
      port map(clk_i  => clk_i,
               rst_i  => rst_i,
               ena_i  => temp1_ld,
               reg_i  => crc_word_out,
               reg_o  => temp1);
  
   cmd_data_size <= 0 when temp0(BB_COMMAND_TYPE'range) = READ_CMD else conv_integer(temp0(BB_DATA_SIZE'range));
   
   cmd_type  <= temp0(BB_COMMAND_TYPE'range);
      
   cmd_valid <= '1' when (temp1(BB_CARD_ADDRESS'range) = card_i) or 
                         (temp1(BB_CARD_ADDRESS'range) = ALL_CARDS) or 
                         (temp1(BB_CARD_ADDRESS'range) = ALL_FPGA_CARDS) or
                         (temp1(BB_CARD_ADDRESS'range) = ALL_BIAS_CARDS and (card_i = BIAS_CARD_1 or card_i = BIAS_CARD_2 or card_i = BIAS_CARD_3)) or
                         (temp1(BB_CARD_ADDRESS'range) = ALL_READOUT_CARDS and (card_i = READOUT_CARD_1 or card_i = READOUT_CARD_2 or card_i = READOUT_CARD_3 or card_i = READOUT_CARD_4))
                    else '0';

   
   ---------------------------------------------------------               
   -- Counters for received words
   ---------------------------------------------------------   
   
   header_counter : counter
   generic map(MAX => BB_NUM_CMD_HEADER_WORDS-1)
   port map(clk_i   => clk_i,
            rst_i   => rst_i,
            ena_i   => hdr_word_count_ena,
            load_i  => '0',   -- does not need to be cleared, since number of header words is fixed, counter just wraps
            count_i => 0,
            count_o => hdr_word_count);
   
   data_counter : counter
   generic map(MAX => MAX_DATA_WORDS-1)
   port map(clk_i   => clk_i,
            rst_i   => rst_i,
            ena_i   => data_word_count_ena,
            load_i  => data_word_count_clr,
            count_i => 0,
            count_o => data_word_count);
            
   
   ---------------------------------------------------------
   -- Receive controller FSM
   ---------------------------------------------------------
   rx_stateFF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         rx_pres_state <= RX_HDR;
      elsif(clk_i'event and clk_i = '1') then
         rx_pres_state <= rx_next_state;
      end if;
   end process rx_stateFF;
   
   rx_stateNS: process(rx_pres_state, crc_word_rdy, crc_valid, cmd_valid, cmd_type, cmd_data_size, hdr_word_count, data_word_count)
   begin
      case rx_pres_state is
         when RX_HDR =>    if(crc_word_rdy = '1') then                        -- when CRC datapath is done with this word
                              rx_next_state <= INCR_HDR;
                           else
                              rx_next_state <= RX_HDR;
                           end if;
                           
         when INCR_HDR =>  if(hdr_word_count = BB_NUM_CMD_HEADER_WORDS-1) then   -- if we have received all header words
                              rx_next_state <= PARSE_HDR;
                           else
                              rx_next_state <= RX_HDR;
                           end if;
                           
         when PARSE_HDR => if(cmd_valid = '1') then                           -- if this command is for this card
                              if(cmd_type = WRITE_CMD) then                      -- if this command is a READ, next word is CRC
                                 rx_next_state <= RX_DATA;
                              else                                               -- if this command is a WRITE, next word is data
                                 rx_next_state <= RX_CRC;            
                              end if;
                           else                                               -- otherwise, skip it
                              rx_next_state <= SKIP_CMD;             
                           end if;
 
         when RX_DATA =>   if(crc_word_rdy = '1') then                        -- when CRC datapath is done with this word
                              rx_next_state <= WRITE_BUF;                                
                           else
                              rx_next_state <= RX_DATA;
                           end if;
         
         when WRITE_BUF => rx_next_state <= INCR_DATA;                        -- write data word into data buffer
         
         when INCR_DATA => if(data_word_count = cmd_data_size-1) then             -- if we have received all data words
                              rx_next_state <= RX_CRC;
                           else
                              rx_next_state <= RX_DATA;
                           end if;
         
         when RX_CRC =>    if(crc_word_rdy = '1') then                        -- when CRC datapath is done with this word
                              if(crc_valid = '1') then                           -- if checksum matches, pass command to next stage
                                 rx_next_state <= DONE;
                              else                                               -- otherwise, signal receive error
                                 rx_next_state <= ERROR;
                              end if;
                           else
                              rx_next_state <= RX_CRC;
                           end if;
                           
         when SKIP_CMD =>  if(crc_word_rdy = '1') then
                              rx_next_state <= INCR_SKIP;
                           else
                              rx_next_state <= SKIP_CMD;
                           end if;
                          
         when INCR_SKIP => if(data_word_count = cmd_data_size) then           -- if we have skipped over all data words AND the CRC word
                              rx_next_state <= RX_HDR;
                           else
                              rx_next_state <= SKIP_CMD;
                           end if;
                  
         when others =>    rx_next_state <= RX_HDR;
      end case;
   end process rx_stateNS;

   rx_stateOut: process(rx_pres_state, hdr_word_count, data_word_count, crc_word_out, temp0, temp1)
   begin
      -- default values:
      temp0_ld            <= '0';
      temp1_ld            <= '0';
      hdr_word_count_ena  <= '0';
      data_word_count_ena <= '0';
      data_word_count_clr <= '0';
      buf_data_o          <= (others => '0');
      buf_addr_o          <= (others => '0');
      buf_wren_o          <= '0';
      header0_o           <= (others => '0');
      header1_o           <= (others => '0');      
      cmd_rdy_o           <= '0';
      cmd_err_o           <= '0';
      
      case rx_pres_state is
         when RX_HDR =>                case hdr_word_count is
                                          when 0 =>      temp0_ld  <= '1';
                                          when others => temp1_ld  <= '1';
                                       end case;
                                
         when INCR_HDR =>              hdr_word_count_ena  <= '1';
         
         when PARSE_HDR =>             data_word_count_ena <= '1';
                                       data_word_count_clr <= '1';

         when INCR_DATA | INCR_SKIP => data_word_count_ena <= '1';     
                                 
         when WRITE_BUF =>             buf_data_o          <= crc_word_out;
                                       buf_addr_o          <= conv_std_logic_vector(data_word_count, BUF_ADDR_WIDTH);
                                       buf_wren_o          <= '1';
                  
         when DONE =>                  header0_o           <= temp0;
                                       header1_o           <= temp1;
                                       cmd_rdy_o           <= '1';
         
         when ERROR =>                 header0_o           <= "10101010101010100000000000000000";  -- preamble with no data
                                       header1_o           <= (others => '0');                     -- null fields
                                       cmd_rdy_o           <= '1';
                                       cmd_err_o           <= '1';
                                               
         when others =>                null;
      end case;
   end process rx_stateOut;
   
end rtl;