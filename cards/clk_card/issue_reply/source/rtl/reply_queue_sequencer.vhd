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
-- reply_queue_sequencer.vhd
--
-- Project:	      SCUBA-2
-- Author:        Ernie Lin
-- Organisation:  UBC
--
-- Description:
-- Implementation of state machine that performs matching and sequencing 
-- functions for reply queue.
--
-- Revision history:
-- 
-- $Log: reply_queue_sequencer.vhd,v $
-- Revision 1.2  2004/11/12 19:42:03  erniel
-- added INSPECT_HEADER state
-- modified receiver FIFO interface
-- modified cmd_queue interface
--
-- NOTE:: has not been simulated, pending integration with reply_queue top level.
--
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library sys_param;
use sys_param.command_pack.all;

entity reply_queue_sequencer is
port(clk_i : in std_logic;
     rst_i : in std_logic;
     
     -- receiver FIFO interfaces:
     ac_data_i    : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
     ac_header_i  : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
     ac_rdy_i     : in std_logic;
     ac_ack_o     : out std_logic;
     ac_nack_o    : out std_logic;
     ac_done_i    : in std_logic;
          
     bc1_data_i   : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
     bc1_header_i : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
     bc1_rdy_i    : in std_logic;
     bc1_ack_o    : out std_logic;
     bc1_nack_o   : out std_logic;
     bc1_done_i   : in std_logic;
          
     bc2_data_i   : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
     bc2_header_i : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
     bc2_rdy_i    : in std_logic;
     bc2_ack_o    : out std_logic;
     bc2_nack_o   : out std_logic;
     bc2_done_i   : in std_logic;
          
     bc3_data_i   : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
     bc3_header_i : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
     bc3_rdy_i    : in std_logic;
     bc3_ack_o    : out std_logic;
     bc3_nack_o   : out std_logic;
     bc3_done_i   : in std_logic;
          
     rc1_data_i   : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
     rc1_header_i : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
     rc1_rdy_i    : in std_logic;
     rc1_ack_o    : out std_logic;
     rc1_nack_o   : out std_logic;
     rc1_done_i   : in std_logic;
          
     rc2_data_i   : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
     rc2_header_i : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
     rc2_rdy_i    : in std_logic;
     rc2_ack_o    : out std_logic;
     rc2_nack_o   : out std_logic;
     rc2_done_i   : in std_logic;
          
     rc3_data_i   : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
     rc3_header_i : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
     rc3_rdy_i    : in std_logic;
     rc3_ack_o    : out std_logic;
     rc3_nack_o   : out std_logic;
     rc3_done_i   : in std_logic;
          
     rc4_data_i   : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
     rc4_header_i : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
     rc4_rdy_i    : in std_logic;
     rc4_ack_o    : out std_logic;
     rc4_nack_o   : out std_logic;
     rc4_done_i   : in std_logic;
          
     cc_data_i    : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
     cc_header_i  : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
     cc_rdy_i     : in std_logic;
     cc_ack_o     : out std_logic;
     cc_nack_o    : out std_logic;
     cc_done_i    : in std_logic;
     
     -- fibre interface:
     size_o : out integer;
     data_o : out std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
     rdy_o  : out std_logic;
     ack_i  : in std_logic;
     
     -- cmd_queue interface:
     macro_op_i  : in std_logic_vector(BB_MACRO_OP_SEQ_WIDTH-1 downto 0);
     micro_op_i  : in std_logic_vector(BB_MICRO_OP_SEQ_WIDTH-1 downto 0);
     card_addr_i : in std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0);
     match_o     : out std_logic;
     start_i     : in std_logic);
end reply_queue_sequencer;

architecture rtl of reply_queue_sequencer is

type seq_states is (IDLE, INSPECT_HEADERS, READ_AC_DATA, READ_BC1_DATA, READ_BC2_DATA, READ_BC3_DATA, 
                    READ_RC1_DATA, READ_RC2_DATA, READ_RC3_DATA, READ_RC4_DATA, READ_CC_DATA, DONE);
signal pres_state : seq_states;
signal next_state : seq_states;

signal match   : std_logic;
signal seq_num : std_logic_vector(15 downto 0);

begin

   seq_num <= macro_op_i & micro_op_i;
   
   match_o <= '1' when (((card_addr_i = ADDRESS_CARD)   and    (ac_header_i(31 downto 16)  = seq_num)) or
   
                        ((card_addr_i = BIAS_CARD_1)    and    (bc1_header_i(31 downto 16) = seq_num)) or
                      
                        ((card_addr_i = BIAS_CARD_2)    and    (bc2_header_i(31 downto 16) = seq_num)) or
                        
                        ((card_addr_i = BIAS_CARD_3)    and    (bc3_header_i(31 downto 16) = seq_num)) or
                      
                        ((card_addr_i = READOUT_CARD_1) and    (rc1_header_i(31 downto 16) = seq_num)) or
                      
                        ((card_addr_i = READOUT_CARD_2) and    (rc2_header_i(31 downto 16) = seq_num)) or
                      
                        ((card_addr_i = READOUT_CARD_3) and    (rc3_header_i(31 downto 16) = seq_num)) or
                      
                        ((card_addr_i = READOUT_CARD_4) and    (rc4_header_i(31 downto 16) = seq_num)) or
                      
                        ((card_addr_i = CLOCK_CARD)     and    (cc_header_i(31 downto 16)  = seq_num)) or                      
                      
                        ((card_addr_i = ALL_BIAS_CARDS) and    (bc1_header_i(31 downto 16) = seq_num) and
                                                               (bc2_header_i(31 downto 16) = seq_num) and
                                                               (bc3_header_i(31 downto 16) = seq_num)) or
                                                             
                        ((card_addr_i = ALL_READOUT_CARDS) and (rc1_header_i(31 downto 16) = seq_num) and
                                                               (rc2_header_i(31 downto 16) = seq_num) and
                                                               (rc3_header_i(31 downto 16) = seq_num) and
                                                               (rc4_header_i(31 downto 16) = seq_num)) or
                                                             
                        ((card_addr_i = ALL_FPGA_CARDS) and    (ac_header_i(31 downto 16)  = seq_num) and
                                                               (bc1_header_i(31 downto 16) = seq_num) and
                                                               (bc2_header_i(31 downto 16) = seq_num) and
                                                               (bc3_header_i(31 downto 16) = seq_num) and
                                                               (rc1_header_i(31 downto 16) = seq_num) and
                                                               (rc2_header_i(31 downto 16) = seq_num) and
                                                               (rc3_header_i(31 downto 16) = seq_num) and
                                                               (rc4_header_i(31 downto 16) = seq_num) and
                                                               (cc_header_i(31 downto 16)  = seq_num))) else '0';   

   state_FF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then 
         pres_state <= IDLE;
      elsif(clk_i'event and clk_i = '1') then
         pres_state <= next_state;
      end if;
   end process state_FF;
   
   state_NS: process(pres_state, seq_num, start_i, card_addr_i, 
                     ac_rdy_i, ac_done_i, ac_header_i,
                     bc1_rdy_i, bc1_done_i, bc1_header_i,
                     bc2_rdy_i, bc2_done_i, bc2_header_i,
                     bc3_rdy_i, bc3_done_i, bc3_header_i,
                     rc1_rdy_i, rc1_done_i, rc1_header_i,
                     rc2_rdy_i, rc2_done_i, rc2_header_i,
                     rc3_rdy_i, rc3_done_i, rc3_header_i,
                     rc4_rdy_i, rc4_done_i, rc4_header_i,
                     cc_rdy_i, cc_done_i, cc_header_i)
   begin
      case pres_state is
         when IDLE =>            if(start_i = '1') then
                                    next_state <= INSPECT_HEADERS;
                                 else
                                    next_state <= IDLE;
                                 end if;
         
         when INSPECT_HEADERS => next_state <= INSPECT_HEADERS;  -- default value
                                 case card_addr_i is
                                    when ADDRESS_CARD =>      if(ac_header_i(31 downto 16) = seq_num and ac_rdy_i = '1') then
                                                                 next_state <= READ_AC_DATA;
                                                              end if;
                                                              
                                    when BIAS_CARD_1 =>       if(bc1_header_i(31 downto 16) = seq_num and bc1_rdy_i = '1') then
                                                                 next_state <= READ_BC1_DATA;
                                                              end if;
                                                              
                                    when BIAS_CARD_2 =>       if(bc2_header_i(31 downto 16) = seq_num and bc2_rdy_i = '1') then
                                                                 next_state <= READ_BC2_DATA;
                                                              end if;
                                                              
                                    when BIAS_CARD_3 =>       if(bc3_header_i(31 downto 16) = seq_num and bc3_rdy_i = '1') then
                                                                 next_state <= READ_BC3_DATA;
                                                              end if;
                                                              
                                    when READOUT_CARD_1 =>    if(rc1_header_i(31 downto 16) = seq_num and rc1_rdy_i = '1') then
                                                                 next_state <= READ_RC1_DATA;
                                                              end if;
                                                              
                                    when READOUT_CARD_2 =>    if(rc2_header_i(31 downto 16) = seq_num and rc2_rdy_i = '1') then
                                                                 next_state <= READ_RC2_DATA;
                                                              end if;
                                                              
                                    when READOUT_CARD_3 =>    if(rc3_header_i(31 downto 16) = seq_num and rc3_rdy_i = '1') then
                                                                 next_state <= READ_RC3_DATA;
                                                              end if;
                                                              
                                    when READOUT_CARD_4 =>    if(rc4_header_i(31 downto 16) = seq_num and rc4_rdy_i = '1') then
                                                                 next_state <= READ_RC4_DATA;
                                                              end if;
                                                              
                                    when CLOCK_CARD =>        if(cc_header_i(31 downto 16) = seq_num and cc_rdy_i = '1') then
                                                                 next_state <= READ_CC_DATA;
                                                              end if;
                                                              
                                    when ALL_BIAS_CARDS =>    if((bc1_header_i(31 downto 0) = seq_num and bc1_rdy_i = '1') and
                                                                 (bc2_header_i(31 downto 0) = seq_num and bc2_rdy_i = '1') and
                                                                 (bc3_header_i(31 downto 0) = seq_num and bc3_rdy_i = '1')) then
                                                                 next_state <= READ_BC1_DATA;
                                                              end if;
                                                              
                                    when ALL_READOUT_CARDS => if((rc1_header_i(31 downto 0) = seq_num and rc1_rdy_i = '1') and
                                                                 (rc2_header_i(31 downto 0) = seq_num and rc2_rdy_i = '1') and
                                                                 (rc3_header_i(31 downto 0) = seq_num and rc3_rdy_i = '1') and
                                                                 (rc4_header_i(31 downto 0) = seq_num and rc4_rdy_i = '1')) then
                                                                 next_state <= READ_RC1_DATA;
                                                              end if;
                                                              
                                    when ALL_FPGA_CARDS =>    if((ac_header_i(31 downto 0) = seq_num and ac_rdy_i = '1') and
                                                                 (bc1_header_i(31 downto 0) = seq_num and bc1_rdy_i = '1') and
                                                                 (bc2_header_i(31 downto 0) = seq_num and bc2_rdy_i = '1') and
                                                                 (bc3_header_i(31 downto 0) = seq_num and bc3_rdy_i = '1') and
                                                                 (rc1_header_i(31 downto 0) = seq_num and rc1_rdy_i = '1') and
                                                                 (rc2_header_i(31 downto 0) = seq_num and rc2_rdy_i = '1') and
                                                                 (rc3_header_i(31 downto 0) = seq_num and rc3_rdy_i = '1') and
                                                                 (rc4_header_i(31 downto 0) = seq_num and rc4_rdy_i = '1') and
                                                                 (cc_header_i(31 downto 0) = seq_num and cc_rdy_i = '1')) then
                                                                 next_state <= READ_AC_DATA;
                                                              end if;
                                                              
                                    when others =>            null;
                                 end case;                                                              
                           
         when READ_AC_DATA =>    if(ac_done_i = '1') then
                                    if(card_addr_i = ALL_FPGA_CARDS) then
                                       next_state <= READ_BC1_DATA;
                                    else
                                       next_state <= DONE;
                                    end if;
                                 else
                                    next_state <= READ_AC_DATA;
                                 end if;
                          
         when READ_BC1_DATA =>   if(bc1_done_i = '1') then
                                    if((card_addr_i = ALL_FPGA_CARDS) or (card_addr_i = ALL_BIAS_CARDS)) then
                                       next_state <= READ_BC2_DATA;
                                    else
                                       next_state <= DONE;
                                    end if;
                                 else
                                    next_state <= READ_BC1_DATA;
                                 end if;
                               
         when READ_BC2_DATA =>   if(bc2_done_i = '1') then
                                    if((card_addr_i = ALL_FPGA_CARDS) or (card_addr_i = ALL_BIAS_CARDS)) then
                                       next_state <= READ_BC3_DATA;
                                    else
                                       next_state <= DONE;
                                    end if;
                                 else
                                    next_state <= READ_BC2_DATA;
                                 end if;
                               
         when READ_BC3_DATA =>   if(bc3_done_i = '1') then
                                    if(card_addr_i = ALL_FPGA_CARDS) then
                                       next_state <= READ_RC1_DATA;
                                    else
                                       next_state <= DONE;
                                    end if;
                                 else
                                    next_state <= READ_BC3_DATA;
                                 end if;
                          
         when READ_RC1_DATA =>   if(rc1_done_i = '1') then
                                    if((card_addr_i = ALL_FPGA_CARDS) or (card_addr_i = ALL_READOUT_CARDS)) then
                                       next_state <= READ_RC2_DATA;
                                    else
                                       next_state <= DONE;
                                    end if;
                                 else
                                    next_state <= READ_RC1_DATA;
                                 end if;
                               
         when READ_RC2_DATA =>   if(rc2_done_i = '1') then
                                    if((card_addr_i = ALL_FPGA_CARDS) or (card_addr_i = ALL_READOUT_CARDS)) then
                                       next_state <= READ_RC3_DATA;
                                    else
                                       next_state <= DONE;
                                    end if;
                                 else
                                    next_state <= READ_RC2_DATA;
                                 end if;
                               
         when READ_RC3_DATA =>   if(rc3_done_i = '1') then
                                    if((card_addr_i = ALL_FPGA_CARDS) or (card_addr_i = ALL_READOUT_CARDS)) then
                                       next_state <= READ_RC4_DATA;
                                    else
                                       next_state <= DONE;
                                    end if;
                                 else
                                    next_state <= READ_RC3_DATA;
                                 end if;
                               
         when READ_RC4_DATA =>   if(rc4_done_i = '1') then
                                    if(card_addr_i = ALL_FPGA_CARDS) then
                                       next_state <= READ_CC_DATA;
                                    else
                                       next_state <= DONE;
                                    end if;
                                 else
                                    next_state <= READ_RC4_DATA;
                                 end if;
         
         when READ_CC_DATA =>    if(cc_done_i = '1') then
                                    next_state <= DONE;         
                                 else
                                    next_state <= READ_CC_DATA;
                                 end if;
                          
         when DONE =>            next_state <= IDLE;
         
         when others =>          next_state <= IDLE;
      end case;
   end process state_NS;
   
   state_Out: process(pres_state, seq_num, card_addr_i, ack_i,
                      ac_rdy_i, ac_data_i, ac_header_i, 
                      bc1_rdy_i, bc1_data_i, bc1_header_i,
                      bc2_rdy_i, bc2_data_i, bc2_header_i,
                      bc3_rdy_i, bc3_data_i, bc3_header_i,
                      rc1_rdy_i, rc1_data_i, rc1_header_i,
                      rc2_rdy_i, rc2_data_i, rc2_header_i,
                      rc3_rdy_i, rc3_data_i, rc3_header_i,
                      rc4_rdy_i, rc4_data_i, rc4_header_i,
                      cc_rdy_i, cc_data_i, cc_header_i)
   begin
      ac_ack_o  <= '0';
      bc1_ack_o <= '0';
      bc2_ack_o <= '0';
      bc3_ack_o <= '0';
      rc1_ack_o <= '0';
      rc2_ack_o <= '0';
      rc3_ack_o <= '0';
      rc4_ack_o <= '0';
      cc_ack_o  <= '0';
      
      ac_nack_o  <= '0';
      bc1_nack_o <= '0';
      bc2_nack_o <= '0';
      bc3_nack_o <= '0';
      rc1_nack_o <= '0';
      rc2_nack_o <= '0';
      rc3_nack_o <= '0';
      rc4_nack_o <= '0';
      cc_nack_o  <= '0';
      
      size_o <= 0;
      data_o <= (others => '0');
      rdy_o  <= '0';
     
      case pres_state is
         when INSPECT_HEADERS => case card_addr_i is
                                    when ADDRESS_CARD =>      size_o <= conv_integer(ac_header_i(12 downto 0));
                                    
                                    when BIAS_CARD_1 =>       size_o <= conv_integer(bc1_header_i(12 downto 0));
                                    
                                    when BIAS_CARD_2 =>       size_o <= conv_integer(bc2_header_i(12 downto 0));
                                    
                                    when BIAS_CARD_3 =>       size_o <= conv_integer(bc3_header_i(12 downto 0));
                                    
                                    when READOUT_CARD_1 =>    size_o <= conv_integer(rc1_header_i(12 downto 0));
                                    
                                    when READOUT_CARD_2 =>    size_o <= conv_integer(rc2_header_i(12 downto 0));
                                    
                                    when READOUT_CARD_3 =>    size_o <= conv_integer(rc3_header_i(12 downto 0));
                                    
                                    when READOUT_CARD_4 =>    size_o <= conv_integer(rc4_header_i(12 downto 0));
                                    
                                    when CLOCK_CARD =>        size_o <= conv_integer(cc_header_i(12 downto 0));
                                    
                                    when ALL_BIAS_CARDS =>    size_o <= conv_integer(bc1_header_i(12 downto 0) + 
                                                                                     bc2_header_i(12 downto 0) + 
                                                                                     bc3_header_i(12 downto 0));
                                                                                     
                                    when ALL_READOUT_CARDS => size_o <= conv_integer(rc1_header_i(12 downto 0) + 
                                                                                     rc2_header_i(12 downto 0) + 
                                                                                     rc3_header_i(12 downto 0) + 
                                                                                     rc4_header_i(12 downto 0));
                                                                                     
                                    when ALL_FPGA_CARDS =>    size_o <= conv_integer(ac_header_i(12 downto 0) +
                                                                                     bc1_header_i(12 downto 0) + 
                                                                                     bc2_header_i(12 downto 0) + 
                                                                                     bc3_header_i(12 downto 0) +
                                                                                     rc1_header_i(12 downto 0) + 
                                                                                     rc2_header_i(12 downto 0) + 
                                                                                     rc3_header_i(12 downto 0) + 
                                                                                     rc4_header_i(12 downto 0) +
                                                                                     cc_header_i(12 downto 0));
                                                                                     
                                    when others =>            size_o <= 0;
                                 end case;
                                 
                                 case card_addr_i is
                                    when ADDRESS_CARD =>      if(ac_header_i(31 downto 16) /= seq_num and ac_rdy_i = '1') then
                                                                 ac_nack_o <= '1';
                                                              end if;
                                                                 
                                    when BIAS_CARD_1 =>       if(bc1_header_i(31 downto 16) /= seq_num and bc1_rdy_i = '1') then
                                                                 bc1_nack_o <= '1';
                                                              end if;
                                                               
                                    when BIAS_CARD_2 =>       if(bc2_header_i(31 downto 16) /= seq_num and bc2_rdy_i = '1') then
                                                                 bc2_nack_o <= '1';
                                                              end if;
                                                               
                                    when BIAS_CARD_3 =>       if(bc3_header_i(31 downto 16) /= seq_num and bc3_rdy_i = '1') then
                                                                 bc3_nack_o <= '1';
                                                              end if;
                                                               
                                    when READOUT_CARD_1 =>    if(rc1_header_i(31 downto 16) /= seq_num and rc1_rdy_i = '1') then
                                                                 rc1_nack_o <= '1';
                                                              end if;
                                                               
                                    when READOUT_CARD_2 =>    if(rc2_header_i(31 downto 16) /= seq_num and rc2_rdy_i = '1') then
                                                                 rc2_nack_o <= '1';
                                                              end if;
                                                               
                                    when READOUT_CARD_3 =>    if(rc3_header_i(31 downto 16) /= seq_num and rc3_rdy_i = '1') then
                                                                 rc3_nack_o <= '1';
                                                              end if;
                                                               
                                    when READOUT_CARD_4 =>    if(rc4_header_i(31 downto 16) /= seq_num and rc4_rdy_i = '1') then
                                                                 rc4_nack_o <= '1';
                                                              end if;
                                                               
                                    when CLOCK_CARD =>        if(cc_header_i(31 downto 16) /= seq_num and cc_rdy_i = '1') then
                                                                 ac_nack_o <= '1';
                                                              end if;
                                                               
                                    when ALL_BIAS_CARDS =>    if(bc1_header_i(31 downto 16) /= seq_num and bc1_rdy_i = '1') then
                                                                 bc1_nack_o <= '1';
                                                              end if;
                                                              if(bc2_header_i(31 downto 16) /= seq_num and bc2_rdy_i = '1') then
                                                                 bc2_nack_o <= '1';
                                                              end if;
                                                              if(bc3_header_i(31 downto 16) /= seq_num and bc3_rdy_i = '1') then
                                                                 bc3_nack_o <= '1';
                                                              end if;
                                                               
                                    when ALL_READOUT_CARDS => if(rc1_header_i(31 downto 16) /= seq_num and rc1_rdy_i = '1') then
                                                                 rc1_nack_o <= '1';
                                                              end if;
                                                              if(rc2_header_i(31 downto 16) /= seq_num and rc2_rdy_i = '1') then
                                                                 rc2_nack_o <= '1';
                                                              end if;
                                                              if(rc3_header_i(31 downto 16) /= seq_num and rc3_rdy_i = '1') then
                                                                 rc3_nack_o <= '1';
                                                              end if;
                                                              if(rc4_header_i(31 downto 16) /= seq_num and rc4_rdy_i = '1') then
                                                                 rc4_nack_o <= '1';
                                                              end if;
                                                               
                                    when ALL_FPGA_CARDS =>    if(ac_header_i(31 downto 16) /= seq_num and ac_rdy_i = '1') then
                                                                 ac_nack_o <= '1';
                                                              end if;
                                                              if(bc1_header_i(31 downto 16) /= seq_num and bc1_rdy_i = '1') then
                                                                 bc1_nack_o <= '1';
                                                              end if;
                                                              if(bc2_header_i(31 downto 16) /= seq_num and bc2_rdy_i = '1') then
                                                                 bc2_nack_o <= '1';
                                                              end if;
                                                              if(bc3_header_i(31 downto 16) /= seq_num and bc3_rdy_i = '1') then
                                                                 bc3_nack_o <= '1';
                                                              end if;
                                                              if(rc1_header_i(31 downto 16) /= seq_num and rc1_rdy_i = '1') then
                                                                 rc1_nack_o <= '1';
                                                              end if;
                                                              if(rc2_header_i(31 downto 16) /= seq_num and rc2_rdy_i = '1') then
                                                                 rc2_nack_o <= '1';
                                                              end if;
                                                              if(rc3_header_i(31 downto 16) /= seq_num and rc3_rdy_i = '1') then
                                                                 rc3_nack_o <= '1';
                                                              end if;
                                                              if(rc4_header_i(31 downto 16) /= seq_num and rc4_rdy_i = '1') then
                                                                 rc4_nack_o <= '1';
                                                              end if;
                                                              if(cc_header_i(31 downto 16) /= seq_num and cc_rdy_i = '1') then
                                                                 cc_nack_o <= '1';
                                                              end if;
                                                               
                                    when others =>            null;
                                 end case;
                                 
         when READ_AC_DATA =>    data_o    <= ac_data_i;
                                 rdy_o     <= '1';
                                 ac_ack_o  <= ack_i;
                                                                  
         when READ_BC1_DATA =>   data_o    <= bc1_data_i;
                                 rdy_o     <= '1';
                                 bc1_ack_o <= ack_i;
                                 
         when READ_BC2_DATA =>   data_o    <= bc2_data_i;
                                 rdy_o     <= '1';
                                 bc2_ack_o <= ack_i;
                                 
         when READ_BC3_DATA =>   data_o    <= bc3_data_i;
                                 rdy_o     <= '1';
                                 bc3_ack_o <= ack_i;
                                 
         when READ_RC1_DATA =>   data_o    <= rc1_data_i;
                                 rdy_o     <= '1';
                                 rc1_ack_o <= ack_i;
                                 
         when READ_RC2_DATA =>   data_o    <= rc2_data_i;
                                 rdy_o     <= '1';
                                 rc2_ack_o <= ack_i;
                                 
         when READ_RC3_DATA =>   data_o    <= rc3_data_i;
                                 rdy_o     <= '1';
                                 rc3_ack_o <= ack_i;
                                 
         when READ_RC4_DATA =>   data_o    <= rc4_data_i;
                                 rdy_o     <= '1';
                                 rc4_ack_o <= ack_i;
                                 
         when READ_CC_DATA =>    data_o    <= cc_data_i;
                                 rdy_o     <= '1';
                                 cc_ack_o  <= ack_i;
         
         when others =>          null;
      end case;
   end process state_Out;
   
end rtl;