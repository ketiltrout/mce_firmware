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
-- Project:	      SCUBA-2
-- Author:        Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Implements a single receiver module for reply queue.
--
-- Revision history:
-- 
-- $Log: reply_queue_receive.vhd,v $
-- Revision 1.6  2004/12/01 18:42:10  erniel
-- renamed READ_DONE state to DISCARD_HEADER
--
-- Revision 1.5  2004/12/01 04:28:55  erniel
-- reworked read FSM state transitions to handle reply packets with size=0
--
-- Revision 1.4  2004/11/30 03:08:24  erniel
-- deleted remaining status fifo-related signals
--
-- Revision 1.3  2004/11/30 03:01:36  erniel
-- eliminated separate status fifo (combined with header fifo)
-- eliminated WRITE_STATUS state
-- moved WRITE_HEADER state to after WRITE_DATA state
--
-- Revision 1.2  2004/11/12 19:45:57  erniel
-- added nack_i (negative ack) port
-- implemented discard current packet on nack_i
--
-- Revision 1.1  2004/11/08 19:56:47  erniel
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

entity reply_queue_receive is
port(clk_i      : in std_logic;
     mem_clk_i  : in std_logic;
     comm_clk_i : in std_logic;
     rst_i      : in std_logic;
     
     lvds_reply_i : in std_logic;
     
     data_o   : out std_logic_vector(PACKET_WORD_WIDTH-1 downto 0); 
     header_o : out std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
     
     rdy_o  : out std_logic;
     ack_i  : in std_logic;
     nack_i : in std_logic;
     done_o : out std_logic);
end reply_queue_receive;

architecture rtl of reply_queue_receive is

signal lvds_data : std_logic_vector(31 downto 0);
signal lvds_rdy  : std_logic;
signal lvds_ack  : std_logic;

--------------------------------------------------
-- CRC datapath control:

type crc_states is (CRC_IDLE, CRC_INIT, CRC_SYNC, CRC_CALCULATE, CRC_WORD_READY, WAIT_NEXT_WORD, LOAD_NEXT_WORD);
signal crc_pres_state : crc_states;
signal crc_next_state : crc_states;

constant CRC32 : std_logic_vector(31 downto 0) := "00000100110000010001110110110111";

signal num_data_words_ld : std_logic;
signal num_data_words    : std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);
signal crc_num_bits      : integer;

signal crc_bit_count_clr : std_logic;
signal crc_bit_count     : integer;

signal crc_data_ena : std_logic;
signal crc_data_ld  : std_logic;
signal crc_data_in  : std_logic;
signal crc_data_out : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);

signal crc_ena   : std_logic;
signal crc_clr   : std_logic;
signal crc_done  : std_logic;
signal crc_valid : std_logic;
signal crc_rdy   : std_logic;

--------------------------------------------------
-- FIFO write control:

type write_ctrl_states is (WRITE_INIT, GET_HEADERS, WRITE_DATA, WRITE_HEADER, GET_CRC, WRITE_DONE);
signal wr_pres_state : write_ctrl_states;
signal wr_next_state : write_ctrl_states;

signal data_wr : std_logic;
signal header_wr : std_logic;
signal wr_done : std_logic;

signal wr_count_ena : std_logic;
signal wr_count_clr : std_logic;
signal wr_count : integer;

signal header_clr : std_logic;
signal header0_ld : std_logic;
signal header1_ld : std_logic;
signal header2_ld : std_logic;

signal status_clr : std_logic;

--------------------------------------------------
-- FIFO read control:

type read_ctrl_states is (READ_IDLE, DATA_READY, DATA_EMPTY, DISCARD_DATA, DISCARD_HEADER);
signal rd_pres_state : read_ctrl_states;
signal rd_next_state : read_ctrl_states;

signal data_rd : std_logic;
signal header_rd : std_logic;
signal rd_done : std_logic;

signal rd_count_ena : std_logic;
signal rd_count_clr : std_logic;
signal rd_count : integer;

signal data_err : std_logic;

signal temp_header : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
signal cur_header  : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);

signal packets : integer;

begin

   --------------------------------------------------
   -- LVDS receiver:         
   --------------------------------------------------
   
   lvds_receiver : lvds_rx
      port map(clk_i      => clk_i,
               comm_clk_i => comm_clk_i,
               rst_i      => rst_i,
               dat_o      => lvds_data,
               rdy_o      => lvds_rdy,
               ack_i      => lvds_ack,
               lvds_i     => lvds_reply_i);
   
   --------------------------------------------------
   -- CRC datapath:         
   --------------------------------------------------

   data_size : reg
      generic map(WIDTH => BB_DATA_SIZE_WIDTH)
      port map(clk_i => clk_i,
               rst_i => rst_i,
               ena_i => num_data_words_ld,
               reg_i => lvds_data(BB_DATA_SIZE'range),
               reg_o => num_data_words);

   -- number of bits to be processed by CRC is (# of data words + 3 header words + 1 CRC word) * 32
   crc_num_bits <= conv_integer((num_data_words + BB_NUM_REPLY_HEADER_WORDS + 1) & "00000");     

   crc_data_reg : shift_reg
      generic map(WIDTH => PACKET_WORD_WIDTH)
      port map(clk_i      => clk_i,
               rst_i      => rst_i,
               ena_i      => crc_data_ena,
               load_i     => crc_data_ld,
               clr_i      => '0',
               shr_i      => '1',            
               serial_i   => crc_data_in,  
               serial_o   => crc_data_in,
               parallel_i => lvds_data,
               parallel_o => crc_data_out);
   
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
      generic map(POLY_WIDTH => PACKET_WORD_WIDTH)
      port map(clk_i      => clk_i,
               rst_i      => rst_i,
               clr_i      => crc_clr,
               ena_i      => crc_ena,
               data_i     => crc_data_in,
               num_bits_i => crc_num_bits,
               poly_i     => CRC32,
               done_o     => crc_done,
               valid_o    => crc_valid,
               checksum_o => open);

               
   --------------------------------------------------
   -- CRC controller:
   --------------------------------------------------
   
   -- CRC control FSM
   crc_stateFF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         crc_pres_state <= CRC_IDLE;
      elsif(clk_i'event and clk_i = '1') then
         crc_pres_state <= crc_next_state;
      end if;
   end process crc_stateFF;
   
   
   -- Notes: - CRC receiver starts on valid preamble boundaries.
   --        - If receiver loses packet sync, words will be ignored:
   --             1. wait until return to CRC idle state (could be up to 8191 words later), then
   --             2. wait until valid preamble is detected.
   
   crc_stateNS: process(crc_pres_state, lvds_rdy, lvds_data, crc_bit_count, crc_done)
   begin
      case crc_pres_state is
         when CRC_IDLE =>       if(lvds_rdy = '1') then
                                   if(lvds_data(BB_PREAMBLE'range) = BB_PREAMBLE) then    -- valid preamble detected
                                      crc_next_state <= CRC_INIT;  
                                   else
                                      crc_next_state <= CRC_SYNC;
                                   end if;
                                else
                                   crc_next_state <= CRC_IDLE;
                                end if;
                                   
         when CRC_INIT =>       crc_next_state <= CRC_CALCULATE;
                                
         when CRC_SYNC =>       if(lvds_rdy = '1' and lvds_data(BB_PREAMBLE'range) = BB_PREAMBLE) then
                                   crc_next_state <= CRC_INIT;  
                                else
                                   crc_next_state <= CRC_SYNC;
                                end if;         
                  
         when CRC_CALCULATE =>  if(crc_bit_count = PACKET_WORD_WIDTH-1) then
                                   crc_next_state <= CRC_WORD_READY;
                                else
                                   crc_next_state <= CRC_CALCULATE;
                                end if;
                          
         when CRC_WORD_READY => crc_next_state <= WAIT_NEXT_WORD;
                                         
         when WAIT_NEXT_WORD => if(crc_done = '1') then
                                   crc_next_state <= CRC_IDLE;
                                elsif(lvds_rdy = '1') then 
                                   crc_next_state <= LOAD_NEXT_WORD;
                                else
                                   crc_next_state <= WAIT_NEXT_WORD;
                                end if;
                            
         when LOAD_NEXT_WORD => crc_next_state <= CRC_CALCULATE;
         
         when others =>         crc_next_state <= CRC_IDLE;
      end case;
   end process crc_stateNS;
   
   crc_stateOut: process(crc_pres_state)
   begin
      lvds_ack          <= '0';
      num_data_words_ld <= '0';
      crc_data_ena      <= '0';
      crc_data_ld       <= '0';
      crc_bit_count_clr <= '0';
      crc_ena           <= '0';
      crc_clr           <= '0';
      crc_rdy           <= '0';
      
      case crc_pres_state is
         when CRC_INIT =>       lvds_ack          <= '1';
                                num_data_words_ld <= '1';
                                crc_data_ld       <= '1';
                                crc_data_ena      <= '1';
                                crc_bit_count_clr <= '1';
                                crc_ena           <= '1';
                                crc_clr           <= '1';
         
         when CRC_SYNC =>       lvds_ack          <= '1';
         
         when CRC_CALCULATE =>  crc_data_ena      <= '1';
                                crc_ena           <= '1';
         
         when CRC_WORD_READY => crc_rdy           <= '1';
         
         when LOAD_NEXT_WORD => lvds_ack          <= '1';
                                crc_data_ena      <= '1';
                                crc_data_ld       <= '1';
                                crc_bit_count_clr <= '1';
                                
         when others =>         null;
      end case;
   end process crc_stateOut;
   
   --------------------------------------------------
   -- Receiver datapath:
   --------------------------------------------------
   
   -- stores reply packet data
   data_fifo : fifo
      generic map(DATA_WIDTH => PACKET_WORD_WIDTH,
                  ADDR_WIDTH => 10)
      port map(clk_i     => clk_i,
               mem_clk_i => mem_clk_i,
               rst_i     => rst_i,
               data_i    => crc_data_out,
               data_o    => data_o,
               read_i    => data_rd,
               write_i   => data_wr,
               clear_i   => '0',
               empty_o   => open,
               full_o    => open,
               error_o   => data_err,
               used_o    => open);
   
   -- stores reply packet header data in shortened format
   header_fifo : fifo
      generic map(DATA_WIDTH => PACKET_WORD_WIDTH,
                  ADDR_WIDTH => 5)
      port map(clk_i     => clk_i,
               mem_clk_i => mem_clk_i,
               rst_i     => rst_i,
               data_i    => temp_header,
               data_o    => cur_header,
               read_i    => header_rd,
               write_i   => header_wr,
               clear_i   => '0',
               empty_o   => open,
               full_o    => open,
               error_o   => open,
               used_o    => open);
   
   header_o <= cur_header;
   
   write_word_counter : counter
      generic map(MAX => 1024)
      port map(clk_i   => clk_i,
               rst_i   => rst_i,
               ena_i   => wr_count_ena,
               load_i  => wr_count_clr,
               count_i => 0,
               count_o => wr_count);
   
   read_word_counter : counter
      generic map(MAX => 1024)
      port map(clk_i   => clk_i,
               rst_i   => rst_i,
               ena_i   => rd_count_ena,
               load_i  => rd_count_clr,
               count_i => 0,
               count_o => rd_count);
                                          
   -- this process extracts the useful parts of the incoming headers and recombines them into a single word:
   --
   -- header contains: 1. size of incoming packet
   --                  2. macro/micro op number
   --                  3. dispatch wishbone error (slave not existent)
   --                  4. receive data fifo error (data incomplete)
   --
   header_assemble: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         temp_header <= (others => '0');
      elsif(clk_i'event and clk_i = '1') then
         if(header_clr = '1') then
            temp_header <= (others => '0');
         elsif(header0_ld = '1') then
            temp_header(12 downto 0) <= crc_data_out(BB_DATA_SIZE'range);
         elsif(header1_ld = '1') then
            temp_header(31 downto 16) <= crc_data_out(BB_MACRO_OP_SEQ'range) & crc_data_out(BB_MICRO_OP_SEQ'range);
         elsif(header2_ld = '1') then
            temp_header(15) <= crc_data_out(31);   -- dispatch error flag
         elsif(data_err = '1') then
            temp_header(14) <= '1';                -- receive data fifo error flag
         end if;
      end if;
   end process header_assemble;
   
   -- this process counts the number of packets waiting in the FIFO
   packet_count: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         packets <= 0;
      elsif(clk_i'event and clk_i = '1') then
         if(wr_done = '1' and rd_done = '0') then
            packets <= packets + 1;
         elsif(wr_done = '0' and rd_done = '1') then
            packets <= packets - 1;
         end if;
      end if;
   end process packet_count;
   

   --------------------------------------------------
   -- FIFO write controller:
   --------------------------------------------------
   
   write_stateFF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then 
         wr_pres_state <= WRITE_INIT;
      elsif(clk_i'event and clk_i = '1') then
         wr_pres_state <= wr_next_state;
      end if;
   end process write_stateFF;
   
   write_stateNS: process(wr_pres_state, wr_count, num_data_words, crc_rdy)
   begin
      case wr_pres_state is
         when WRITE_INIT =>   wr_next_state <= GET_HEADERS;
         
         when GET_HEADERS =>  if(wr_count = BB_NUM_REPLY_HEADER_WORDS) then
                                 wr_next_state <= WRITE_DATA;
                              else
                                 wr_next_state <= GET_HEADERS;
                              end if;
                                           
         when WRITE_DATA =>   if(wr_count = num_data_words) then
                                 wr_next_state <= WRITE_HEADER;
                              else
                                 wr_next_state <= WRITE_DATA;
                              end if;
         
         when WRITE_HEADER => wr_next_state <= GET_CRC;
         
         when GET_CRC =>      if(crc_rdy = '1') then
                                 wr_next_state <= WRITE_DONE;
                              else
                                 wr_next_state <= GET_CRC;
                              end if;
                                       
         when WRITE_DONE =>   wr_next_state <= WRITE_INIT;
                                  
         when others =>       wr_next_state <= WRITE_INIT;
      end case;
   end process write_stateNS;
   
   write_stateOut: process(wr_pres_state, crc_rdy, wr_count)
   begin
      data_wr      <= '0';
      header_wr    <= '0';
      header_clr   <= '0';
      header0_ld   <= '0';
      header1_ld   <= '0';
      header2_ld   <= '0';
      wr_done      <= '0';
      wr_count_ena <= '0';
      wr_count_clr <= '0';
      
      case wr_pres_state is
         when WRITE_INIT =>   header_clr       <= '1';
                              wr_count_ena     <= '1';
                              wr_count_clr     <= '1';
               
         when GET_HEADERS =>  if(crc_rdy = '1') then
                                 if(wr_count = 0) then    
                                    header0_ld <= '1';
                                 elsif(wr_count = 1) then 
                                    header1_ld <= '1';
                                 elsif(wr_count = 2) then 
                                    header2_ld <= '1';
                                 end if;
                                 wr_count_ena  <= '1';
                              end if;
                              
                              if(wr_count = BB_NUM_REPLY_HEADER_WORDS) then
                                 wr_count_ena <= '1';
                                 wr_count_clr <= '1';
                              end if;
                                     
         when WRITE_DATA =>   if(crc_rdy = '1') then
                                 data_wr       <= '1';
                                 wr_count_ena  <= '1';
                              end if;

         when WRITE_HEADER => header_wr        <= '1';

         when WRITE_DONE =>   wr_done          <= '1';
         
         when others =>       null;
      end case;
   end process write_stateOut;
   
   
   --------------------------------------------------
   -- FIFO read controller:
   --------------------------------------------------
   
   read_stateFF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         rd_pres_state <= READ_IDLE;
      elsif(clk_i'event and clk_i = '1') then
         rd_pres_state <= rd_next_state;
      end if;
   end process read_stateFF;
   
   read_stateNS: process(rd_pres_state, packets, rd_count, cur_header, ack_i, nack_i)
   begin
      case rd_pres_state is
         when READ_IDLE =>       if(packets > 0) then
                                    if(cur_header(12 downto 0) = 0) then
                                       rd_next_state <= DATA_EMPTY;
                                    else
                                       rd_next_state <= DATA_READY;
                                    end if;
                                 else
                                    rd_next_state <= READ_IDLE;
                                 end if;
         
         when DATA_READY =>      if(rd_count = cur_header(12 downto 0)-1 and ack_i = '1') then
                                    rd_next_state <= DATA_EMPTY;
                                 elsif(nack_i = '1') then
                                    rd_next_state <= DISCARD_DATA;
                                 else
                                    rd_next_state <= DATA_READY;
                                 end if;
         
         when DATA_EMPTY =>      if(ack_i = '1' or nack_i = '1') then
                                    rd_next_state <= DISCARD_HEADER;
                                 else
                                    rd_next_state <= DATA_EMPTY;
                                 end if;
                                 
         when DISCARD_DATA =>    if(rd_count = cur_header(12 downto 0)-1) then
                                    rd_next_state <= DISCARD_HEADER;
                                 else
                                    rd_next_state <= DISCARD_DATA;
                                 end if;
                                                     
         when DISCARD_HEADER =>  rd_next_state <= READ_IDLE;
          
         when others =>          rd_next_state <= READ_IDLE;
      end case;
   end process read_stateNS;
   
   read_stateOut: process(rd_pres_state, ack_i)
   begin
      rdy_o        <= '0';
      data_rd      <= '0';
      header_rd    <= '0';
      rd_count_ena <= '0';
      rd_count_clr <= '0';
      rd_done      <= '0';
      done_o       <= '0';
      
      case rd_pres_state is
         when DATA_READY =>      rdy_o           <= '1';
                                 if(ack_i = '1') then
                                    data_rd      <= '1';
                                    rd_count_ena <= '1';
                                 end if;
         
         when DATA_EMPTY =>      rdy_o  <= '1';
                                 done_o <= '1';
         
         when DISCARD_DATA =>    data_rd         <= '1';
                                 rd_count_ena    <= '1';
                               
         when DISCARD_HEADER =>  header_rd       <= '1';
                                 rd_count_ena    <= '1';
                                 rd_count_clr    <= '1';
                                 rd_done         <= '1';
         
         when others =>          null;
      end case;
   end process read_stateOut;
      
end rtl; 