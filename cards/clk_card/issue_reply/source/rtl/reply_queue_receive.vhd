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
-- Revision 1.10  2005/02/09 21:01:02  erniel
-- removed separate header fifo (consolidated data and header fifos)
-- added another fifo stage for temporary storage during CRC verify
-- reworked fifo read and write FSMs to support new architecture
-- removed header_o from interface
-- removed done_o from interface (deassert rdy to indicate done)
--
-- WARNING: Interim version.  May contain bugs.
--
-- Revision 1.9  2005/01/12 23:24:02  erniel
-- updated lvds_rx component
--
-- Revision 1.8  2005/01/11 22:44:58  erniel
-- removed mem_clk_i from ports
-- updated fifo component
--
-- Revision 1.7  2004/12/03 20:37:22  erniel
-- added extra state in write FSM to deal with CRC word
--
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
use work.reply_queue_pack.all;

entity reply_queue_receive is
port(clk_i      : in std_logic;
     comm_clk_i : in std_logic;
     rst_i      : in std_logic;
     
     lvds_reply_i : in std_logic;
     
     data_o    : out std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
     rdy_o     : out std_logic;
     ack_i     : in std_logic;
     discard_i : in std_logic);
end reply_queue_receive;

architecture rtl of reply_queue_receive is

--------------------------------------------------
-- LVDS signals:

signal lvds_data : std_logic_vector(31 downto 0);
signal lvds_rdy  : std_logic;
signal lvds_ack  : std_logic;


--------------------------------------------------
-- CRC datapath control:

type crc_states is (CRC_IDLE, CRC_INIT, CRC_SYNC, CRC_CALCULATE, CRC_WORD_RDY, WRITE_STATUS, WAIT_NEXT_WORD, LOAD_NEXT_WORD);
signal crc_ps : crc_states;
signal crc_ns : crc_states;

constant CRC32 : std_logic_vector(31 downto 0) := "00000100110000010001110110110111";

signal num_data_words_ld : std_logic;
signal num_data_words    : std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);
signal crc_num_bits      : integer;

signal crc_bit_count_clr : std_logic;
signal crc_bit_count     : integer range 0 to PACKET_WORD_WIDTH;

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
-- Stage 1 Packet Buffer

signal buf_data_out : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
signal buf_write    : std_logic;
signal buf_read     : std_logic;
signal buf_clear    : std_logic;


--------------------------------------------------
-- Packet Buffer control:

type buf_ctrl_states is (WRITE_BUF, DISCARD_BUF, BUF_DONE);
signal buf_ps : buf_ctrl_states;
signal buf_ns : buf_ctrl_states;

signal buf_rdy : std_logic;


--------------------------------------------------
-- Stage 2 Packet Store

signal packet_data_in  : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
signal packet_data_out : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
signal packet_write    : std_logic;
signal packet_read     : std_logic;

signal header0    : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
signal header1    : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
signal header2    : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
signal header0_ld : std_logic;
signal header1_ld : std_logic;
signal header2_ld : std_logic;

signal wr_count     : integer;
signal wr_count_ena : std_logic;
signal wr_count_clr : std_logic;

signal rd_count     : integer;
signal rd_count_ena : std_logic;
signal rd_count_clr : std_logic;

signal packets : integer range 0 to 2**PACKET_STORAGE_DEPTH-1;

signal wr_done : std_logic;
signal rd_done : std_logic;

signal header    : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
signal header_ld : std_logic;

signal data_ld : std_logic;


--------------------------------------------------
-- Packet store write control:

type write_ctrl_states is (WRITE_IDLE, GET_LONG_HDRS, WRITE_SHORT_HDR, WRITE_DATA, REMOVE_CRC, WRITE_DONE);
signal write_ps : write_ctrl_states;
signal write_ns : write_ctrl_states;


--------------------------------------------------
-- Packet store read control:

type read_ctrl_states is (READ_IDLE, PACKET_SETUP, PACKET_READY, DISCARD_PACKET, READ_DONE);
signal read_ps : read_ctrl_states;
signal read_ns : read_ctrl_states;


begin

   --------------------------------------------------
   -- LVDS receiver:         
   --------------------------------------------------
   
   lvds_receiver : lvds_rx
      port map(comm_clk_i => comm_clk_i,
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
         crc_ps <= CRC_IDLE;
      elsif(clk_i'event and clk_i = '1') then
         crc_ps <= crc_ns;
      end if;
   end process crc_stateFF;
   
   
   -- Notes: - CRC receiver starts on valid preamble boundaries.
   --        - If receiver loses packet sync, words will be ignored:
   --             1. wait until return to CRC idle state (could be up to 8191 words later), then
   --             2. wait until valid preamble is detected.
   
   crc_stateNS: process(crc_ps, lvds_rdy, lvds_data, crc_bit_count, crc_done)
   begin
      case crc_ps is
         when CRC_IDLE =>       if(lvds_rdy = '1') then
                                   if(lvds_data(BB_PREAMBLE'range) = BB_PREAMBLE) then    -- valid preamble detected
                                      crc_ns <= CRC_INIT;  
                                   else
                                      crc_ns <= CRC_SYNC;
                                   end if;
                                else
                                   crc_ns <= CRC_IDLE;
                                end if;
                                   
         when CRC_INIT =>       crc_ns <= CRC_CALCULATE;
                                
         when CRC_SYNC =>       if(lvds_rdy = '1' and lvds_data(BB_PREAMBLE'range) = BB_PREAMBLE) then
                                   crc_ns <= CRC_INIT;  
                                else
                                   crc_ns <= CRC_SYNC;
                                end if;         
                  
         when CRC_CALCULATE =>  if(crc_bit_count = PACKET_WORD_WIDTH-1) then
                                   crc_ns <= CRC_WORD_RDY;
                                else
                                   crc_ns <= CRC_CALCULATE;
                                end if;
                          
         when CRC_WORD_RDY =>   crc_ns <= WAIT_NEXT_WORD;
                                         
         when WAIT_NEXT_WORD => if(crc_done = '1') then
                                   crc_ns <= CRC_IDLE;
                                elsif(lvds_rdy = '1') then 
                                   crc_ns <= LOAD_NEXT_WORD;
                                else
                                   crc_ns <= WAIT_NEXT_WORD;
                                end if;
                            
         when LOAD_NEXT_WORD => crc_ns <= CRC_CALCULATE;
         
         when others =>         crc_ns <= CRC_IDLE;
      end case;
   end process crc_stateNS;
   
   crc_stateOut: process(crc_ps)
   begin
      lvds_ack          <= '0';
      num_data_words_ld <= '0';
      crc_data_ena      <= '0';
      crc_data_ld       <= '0';
      crc_bit_count_clr <= '0';
      crc_ena           <= '0';
      crc_clr           <= '0';
      crc_rdy           <= '0';
            
      case crc_ps is
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
         
         when CRC_WORD_RDY =>   crc_rdy           <= '1';
                  
         when LOAD_NEXT_WORD => lvds_ack          <= '1';
                                crc_data_ena      <= '1';
                                crc_data_ld       <= '1';
                                crc_bit_count_clr <= '1';
                                
         when others =>         null;
      end case;
   end process crc_stateOut;
   
   --------------------------------------------------
   -- Stage 1 Packet Buffer:
   --------------------------------------------------

   -- Incoming packets are buffered while CRC is calculated.  
   -- If CRC fails, packet is discarded (FIFO cleared).  Else, it is passed to the packet store (Stage 2).  
   
   -- The entire packet is stored as-is, including the three header words and the CRC word.
      
   packet_buffer : fifo
      generic map(DATA_WIDTH => PACKET_WORD_WIDTH,
                  ADDR_WIDTH => PACKET_BUFFER_DEPTH)
      port map(clk_i   => clk_i,
               rst_i   => rst_i,
               data_i  => crc_data_out,
               data_o  => buf_data_out,
               read_i  => buf_read,
               write_i => buf_write,
               clear_i => buf_clear,
               empty_o => open,
               full_o  => open,
               error_o => open,
               used_o  => open); 

                  
   buf_FSM_state: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then 
         buf_ps <= WRITE_BUF;
      elsif(clk_i'event and clk_i = '1') then
         buf_ps <= buf_ns;
      end if;
   end process buf_FSM_state;
   
   buf_FSM_NS: process(buf_ps, crc_done, crc_rdy, crc_valid)
   begin
      case buf_ps is
         when WRITE_BUF => if(crc_done = '1' and crc_rdy = '1') then
                              if(crc_valid = '1') then
                                 buf_ns <= BUF_DONE;
                              else
                                 buf_ns <= DISCARD_BUF;
                              end if;
                           else
                              buf_ns <= WRITE_BUF;
                           end if;
                               
         when others =>    buf_ns <= WRITE_BUF;
      end case;
   end process buf_FSM_NS;
   
   buf_FSM_Out: process(buf_ps, crc_rdy)
   begin
      buf_write <= '0';
      buf_clear <= '0';
      buf_rdy   <= '0';
   
      case buf_ps is
         when WRITE_BUF =>   if(crc_rdy = '1') then
                                buf_write <= '1';
                             end if;
                            
         when DISCARD_BUF => buf_clear <= '1';
                             
         when BUF_DONE =>    buf_rdy <= '1';
         
         when others =>      null;
      end case;
   end process buf_FSM_Out;


   --------------------------------------------------
   -- Stage 2 Packet Store Write Interface:
   --------------------------------------------------
   
   -- Incoming packets are queued here awaiting matching by 
   -- reply_queue_sequencer and transmission to reply_translator.
   
   -- The three header words are read out of Stage 1 and written into Stage 2 in condensed format.
   -- Any data words are copied from Stage 1 to Stage 2.
   -- The CRC word is read out of Stage 1 but ignored by Stage 2.
   
   packet_store : fifo
      generic map(DATA_WIDTH => PACKET_WORD_WIDTH,
                  ADDR_WIDTH => PACKET_STORAGE_DEPTH)
      port map(clk_i   => clk_i,
               rst_i   => rst_i,
               data_i  => packet_data_in,
               data_o  => packet_data_out,
               read_i  => packet_read,
               write_i => packet_write,
               clear_i => '0',
               empty_o => open,
               full_o  => open,
               error_o => open,
               used_o  => open);
               
   hdr0_reg : reg
      generic map(WIDTH => PACKET_WORD_WIDTH)
      port map(clk_i => clk_i,
               rst_i => rst_i,
               ena_i => header0_ld,
               reg_i => buf_data_out,
               reg_o => header0);
               
   hdr1_reg : reg
      generic map(WIDTH => PACKET_WORD_WIDTH)
      port map(clk_i => clk_i,
               rst_i => rst_i,
               ena_i => header1_ld,
               reg_i => buf_data_out,
               reg_o => header1);
               
   hdr2_reg : reg
      generic map(WIDTH => PACKET_WORD_WIDTH)
      port map(clk_i => clk_i,
               rst_i => rst_i,
               ena_i => header2_ld,
               reg_i => buf_data_out,
               reg_o => header2);

   write_counter : counter
      generic map(MAX => 2**PACKET_STORAGE_DEPTH-1)
      port map(clk_i   => clk_i,
               rst_i   => rst_i,
               ena_i   => wr_count_ena,
               load_i  => wr_count_clr,
               count_i => 0,
               count_o => wr_count);
     
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
     
   write_FSM_state : process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         write_ps <= WRITE_IDLE;
      elsif(clk_i'event and clk_i = '1') then
         write_ps <= write_ns;
      end if;
   end process write_FSM_state;
   
   write_FSM_NS : process(write_ps, buf_rdy, wr_count, header0)
   begin
      case write_ps is
         when WRITE_IDLE =>      if(buf_rdy = '1') then
                                    write_ns <= GET_LONG_HDRS;
                                 else
                                    write_ns <= WRITE_IDLE;
                                 end if;
                      
         when GET_LONG_HDRS =>   if(wr_count = BB_NUM_REPLY_HEADER_WORDS-1) then
                                    write_ns <= WRITE_SHORT_HDR;
                                 else
                                    write_ns <= GET_LONG_HDRS;
                                 end if;
                               
         when WRITE_SHORT_HDR => if(header0(BB_DATA_SIZE'range) = 0) then
                                    write_ns <= REMOVE_CRC;
                                 else
                                    write_ns <= WRITE_DATA;
                                 end if;
         
         when WRITE_DATA =>      if(wr_count = header0(BB_DATA_SIZE'range)-1) then
                                    write_ns <= REMOVE_CRC;
                                 else
                                    write_ns <= WRITE_DATA;
                                 end if;
                                 
         when REMOVE_CRC =>      write_ns <= WRITE_DONE;
                                 
         when WRITE_DONE =>      write_ns <= WRITE_IDLE;
      end case;
   end process write_FSM_NS;
   
   write_FSM_Out : process(write_ps, wr_count, header0, header1, header2, buf_data_out)
   begin
      packet_data_in <= (others => '0');
      packet_write   <= '0';
      buf_read       <= '0';
      header0_ld     <= '0';
      header1_ld     <= '0';
      header2_ld     <= '0';
      wr_count_ena   <= '0';
      wr_count_clr   <= '0';
      wr_done        <= '0';
      
      case write_ps is
         when WRITE_IDLE =>      wr_count_ena   <= '1';
                                 wr_count_clr   <= '1';
         
         when GET_LONG_HDRS =>   buf_read       <= '1';
                                 wr_count_ena   <= '1';
                                 case wr_count is
                                    when 0 =>      header0_ld <= '1';
                                    when 1 =>      header1_ld <= '1';
                                    when 2 =>      header2_ld <= '1';
                                    when others => null;
                                 end case;
         
         when WRITE_SHORT_HDR => packet_data_in <= "0000" & header2(31 downto 30) & header0(9 downto 0) & header1(15 downto 0);
                                 packet_write   <= '1';
                                 wr_count_ena   <= '1';
                                 wr_count_clr   <= '1';
         
         when WRITE_DATA =>      packet_data_in <= buf_data_out;
                                 packet_write   <= '1';
                                 buf_read       <= '1';
                                 wr_count_ena   <= '1';
         
         when REMOVE_CRC =>      buf_read       <= '1';
         
         when WRITE_DONE =>      wr_done        <= '1';
      end case;
   end process write_FSM_Out;


   --------------------------------------------------
   -- Stage 2 Packet Store Read Interface:
   --------------------------------------------------
   
   hdr_reg : reg
      generic map(WIDTH => PACKET_WORD_WIDTH)
      port map(clk_i => clk_i,
               rst_i => rst_i,
               ena_i => header_ld,
               reg_i => packet_data_out,
               reg_o => header);
   
   data_reg : reg
      generic map(WIDTH => PACKET_WORD_WIDTH)
      port map(clk_i => clk_i,
               rst_i => rst_i,
               ena_i => data_ld,
               reg_i => packet_data_out,
               reg_o => data_o);
               
   read_counter : counter
      generic map(MAX => 2**PACKET_STORAGE_DEPTH-1)
      port map(clk_i   => clk_i,
               rst_i   => rst_i,
               ena_i   => rd_count_ena,
               load_i  => rd_count_clr,
               count_i => 0,
               count_o => rd_count);
           
   read_FSM_state : process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         read_ps <= READ_IDLE;
      elsif(clk_i'event and clk_i = '1') then
         read_ps <= read_ns;
      end if;
   end process read_FSM_state;
   
   read_FSM_NS : process(read_ps, header, rd_count, packets, ack_i, discard_i)
   begin
      case read_ps is
         when READ_IDLE =>      if(packets > 0) then
                                   read_ns <= PACKET_SETUP;
                                else
                                   read_ns <= READ_IDLE;
                                end if;
                                
         when PACKET_SETUP =>   read_ns <= PACKET_READY;
                      
         when PACKET_READY =>   if(discard_i = '1') then
                                   read_ns <= DISCARD_PACKET;
                                elsif(ack_i = '1') then
                                   if(rd_count = header(RQ_DATA_SIZE'range)) then
                                      read_ns <= READ_DONE;                                   
                                   end if;
                                else
                                   read_ns <= PACKET_READY;
                                end if;
                            
         when DISCARD_PACKET => if(rd_count = header(RQ_DATA_SIZE'range)) then
                                   read_ns <= READ_IDLE;
                                else
                                   read_ns <= DISCARD_PACKET;
                                end if;
                                
         when READ_DONE =>      read_ns <= READ_IDLE;
         
      end case;
   end process read_FSM_NS;
   
   read_FSM_Out : process(read_ps, ack_i)
   begin      
      packet_read  <= '0';
      header_ld    <= '0';
      data_ld      <= '0';
      rd_count_ena <= '0';
      rd_count_clr <= '0';
      rd_done      <= '0';
      rdy_o        <= '0';
      
      case read_ps is
         when READ_IDLE =>      rd_count_ena <= '1';
                                rd_count_clr <= '1';
         
         when PACKET_SETUP =>   packet_read  <= '1';
                                header_ld    <= '1';
                                data_ld      <= '1';
         
         when PACKET_READY =>   rdy_o <= '1';
                                if(ack_i = '1') then
                                   packet_read  <= '1';
                                   data_ld      <= '1';
                                   rd_count_ena <= '1';
                                end if;
         
         when DISCARD_PACKET => packet_read  <= '1';
                                rd_count_ena <= '1';
         
         when READ_DONE =>      rd_done <= '1';
         
      end case;
   end process read_FSM_Out;
   
end rtl; 