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
-- Project:       SCUBA-2
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
-- Revision 1.13  2005/03/05 01:27:50  bburger
-- Ernie: moved position of MATCHED state to after CALC_DATA_SIZE
--
-- Revision 1.12  2005/03/03 19:47:49  mandana
-- Had to comment out the rest of error_o line!
--
-- Revision 1.11  2005/03/03 19:37:45  mandana
-- Ernie: Error encoding removed.
--
-- Revision 1.10  2005/02/20 00:42:25  erniel
-- added MATCHED state
-- fixed bugs in state transitions
-- modified packet discard logic
-- modified data ready logic
--
-- Revision 1.9  2005/02/09 20:50:40  erniel
-- added support for data size calculation using an accumulator
-- added support for command timeouts
-- added support for new reply_queue_receiver interface
--
-- WARNING: Interim version. May contain bugs.
--
-- Revision 1.8  2005/01/11 20:42:28  bburger
-- Bryce:  size_o is now registered to maintain a valid value while data words are being clocked out
--
-- Revision 1.7  2004/12/01 18:43:11  erniel
-- changed UPDATE_HEADERS state to hold until cmd_valid deasserted
--
-- Revision 1.6  2004/12/01 04:26:54  erniel
-- added UPDATE HEADERS state
--
-- Revision 1.5  2004/11/30 22:58:47  bburger
-- Bryce:  reply_queue integration
--
-- Revision 1.4  2004/11/30 03:20:23  erniel
-- added error_o logic
--
-- Revision 1.3  2004/11/30 03:02:52  erniel
-- deleted done_o port
-- deleted status_i ports
--
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

library components;
use components.component_pack.all;

library work;
use work.reply_queue_pack.all;

entity reply_queue_sequencer is
port(
     -- for debugging
     timer_trigger_o : out std_logic;

     clk_i : in std_logic;
     rst_i : in std_logic;
     
     -- reply_queue_receive FIFO interfaces:
     ac_data_i    : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
     ac_rdy_i     : in std_logic;
     ac_ack_o     : out std_logic;
     ac_discard_o : out std_logic;
          
     bc1_data_i    : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
     bc1_rdy_i     : in std_logic;
     bc1_ack_o     : out std_logic;
     bc1_discard_o : out std_logic;
          
     bc2_data_i    : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
     bc2_rdy_i     : in std_logic;
     bc2_ack_o     : out std_logic;
     bc2_discard_o : out std_logic;
          
     bc3_data_i    : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
     bc3_rdy_i     : in std_logic;
     bc3_ack_o     : out std_logic;
     bc3_discard_o : out std_logic;
          
     rc1_data_i    : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
     rc1_rdy_i     : in std_logic;
     rc1_ack_o     : out std_logic;
     rc1_discard_o : out std_logic;
          
     rc2_data_i    : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
     rc2_rdy_i     : in std_logic;
     rc2_ack_o     : out std_logic;
     rc2_discard_o : out std_logic;
          
     rc3_data_i    : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
     rc3_rdy_i     : in std_logic;
     rc3_ack_o     : out std_logic;
     rc3_discard_o : out std_logic;
          
     rc4_data_i    : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
     rc4_rdy_i     : in std_logic;
     rc4_ack_o     : out std_logic;
     rc4_discard_o : out std_logic;
          
     cc_data_i    : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
     cc_rdy_i     : in std_logic;
     cc_ack_o     : out std_logic;
     cc_discard_o : out std_logic;
     
     -- reply_queue_retire interface:
     macro_op_i  : in std_logic_vector(BB_MACRO_OP_SEQ_WIDTH-1 downto 0);
     micro_op_i  : in std_logic_vector(BB_MICRO_OP_SEQ_WIDTH-1 downto 0);
     card_addr_i : in std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0);
     cmd_valid_i : in std_logic;
     matched_o   : out std_logic;
     timeout_o   : out std_logic;
     
     -- reply_translator interface:
     size_o  : out integer;
     error_o : out std_logic_vector(29 downto 0);
     data_o  : out std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
     rdy_o   : out std_logic;
     ack_i   : in std_logic);
end reply_queue_sequencer;

architecture rtl of reply_queue_sequencer is

type seq_states is (IDLE, WAIT_FOR_REPLY, MATCHED, CALC_DATA_SIZE, READ_AC, READ_BC1, READ_BC2, READ_BC3, 
                    READ_RC1, READ_RC2, READ_RC3, READ_RC4, READ_CC, TIMED_OUT, DONE);
signal pres_state : seq_states;
signal next_state : seq_states;

signal seq_num : std_logic_vector(15 downto 0);

signal data_size : std_logic_vector(RQ_DATA_SIZE_WIDTH-1 downto 0);

signal timeout       : std_logic;
signal timeout_clr   : std_logic;
signal timeout_count : integer;

signal accum_data_in  : std_logic_vector(31 downto 0);
signal accum_data_out : std_logic_vector(31 downto 0);
signal accum_ena      : std_logic;
signal accum_clr      : std_logic;

signal calc_count_ena : std_logic;
signal calc_count_clr : std_logic;
signal calc_count : integer range 0 to 10;

-- Debugging Logic
signal timer_count   : integer;

begin

   
   seq_num <= macro_op_i & micro_op_i;
   
   error_o <= (others => '0');

   -- error_o <= ac_data_i(31 downto 29)  & bc1_data_i(31 downto 29) & bc2_data_i(31 downto 29) & bc3_data_i(31 downto 29) &
   --           rc1_data_i(31 downto 29) & rc2_data_i(31 downto 29) & rc3_data_i(31 downto 29) & rc4_data_i(31 downto 29) &
   --           cc_data_i(31 downto 29) & "000";
   
   ---------------------------------------------------------
   -- Debugging Logic
   ---------------------------------------------------------
   -- This timer will allow us to trigger earlier to monitor the timeout of commands with little data.
   -- The purpose of time is to provide a trigger to track down unreliablility issues.
   
   timer_trigger_o <= '1' when timer_count >= 53 else '0';
   trigger_timer : us_timer
      port map(
         clk           => clk_i,
         timer_reset_i => timeout_clr,
         timer_count_o => timer_count
      );
   
   ---------------------------------------------------------
   -- Timeout Logic
   ---------------------------------------------------------
 
   timeout_timer : us_timer
   port map(clk => clk_i,
            timer_reset_i => timeout_clr,
            timer_count_o => timeout_count);
   
   timeout <= '1' when timeout_count >= TIMEOUT_LIMIT else '0';  -- TIMEOUT_LIMIT is defined in reply_queue_pack
   
      
   ---------------------------------------------------------
   -- Accumulator Block
   ---------------------------------------------------------
 
   accum_32bit : reply_queue_accumulator  
   port map(clock  => clk_i, 
            clken  => accum_ena,
            sload  => '0',
            aclr   => accum_clr,
            data   => accum_data_in,
            result => accum_data_out);

   accum_data_in <= "0000000000000000000000" & data_size;
   
   size_o <= conv_integer(accum_data_out);
   
   
   ---------------------------------------------------------
   -- Calculation Counter
   ---------------------------------------------------------
   
   calc_counter : counter
   generic map(MAX => 10,
               WRAP_AROUND => '0')
   port map(clk_i   => clk_i,
            rst_i   => rst_i,
            ena_i   => calc_count_ena,
            load_i  => calc_count_clr,
            count_i => 0,
            count_o => calc_count);
            
            
   ---------------------------------------------------------
   -- Sequencer FSM
   ---------------------------------------------------------
              
   state_FF: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then 
         pres_state <= IDLE;
      elsif(clk_i'event and clk_i = '1') then
         pres_state <= next_state;
      end if;
   end process state_FF;
   
   state_NS: process(pres_state, seq_num, calc_count, timeout, cmd_valid_i, card_addr_i, 
                     ac_rdy_i,  bc1_rdy_i,  bc2_rdy_i,  bc3_rdy_i,  rc1_rdy_i,  rc2_rdy_i,  rc3_rdy_i,  rc4_rdy_i,  cc_rdy_i, 
                     ac_data_i, bc1_data_i, bc2_data_i, bc3_data_i, rc1_data_i, rc2_data_i, rc3_data_i, rc4_data_i, cc_data_i)
   begin
      case pres_state is
         when IDLE =>           if(cmd_valid_i = '1') then
                                   next_state <= WAIT_FOR_REPLY;
                                else
                                   next_state <= IDLE;
                                end if;
                                 
         when WAIT_FOR_REPLY => if((card_addr_i = CLOCK_CARD and cc_data_i(RQ_SEQ_NUM'range) = seq_num and cc_rdy_i = '1') or
                                     
                                   (card_addr_i = ADDRESS_CARD and ac_data_i(RQ_SEQ_NUM'range) = seq_num and ac_rdy_i = '1') or
                                     
                                   (card_addr_i = BIAS_CARD_1 and bc1_data_i(RQ_SEQ_NUM'range) = seq_num and bc1_rdy_i = '1') or
                                     
                                   (card_addr_i = BIAS_CARD_2 and bc2_data_i(RQ_SEQ_NUM'range) = seq_num and bc2_rdy_i = '1') or
                                     
                                   (card_addr_i = BIAS_CARD_3 and bc3_data_i(RQ_SEQ_NUM'range) = seq_num and bc3_rdy_i = '1') or
                                     
                                   (card_addr_i = READOUT_CARD_1 and rc1_data_i(RQ_SEQ_NUM'range) = seq_num and rc1_rdy_i = '1') or
                                     
                                   (card_addr_i = READOUT_CARD_2 and rc2_data_i(RQ_SEQ_NUM'range) = seq_num and rc2_rdy_i = '1') or
                                     
                                   (card_addr_i = READOUT_CARD_3 and rc3_data_i(RQ_SEQ_NUM'range) = seq_num and rc3_rdy_i = '1') or
                                     
                                   (card_addr_i = READOUT_CARD_4 and rc4_data_i(RQ_SEQ_NUM'range) = seq_num and rc4_rdy_i = '1') or
                                     
         
                                   (card_addr_i = ALL_BIAS_CARDS and bc1_data_i(RQ_SEQ_NUM'range) = seq_num and bc1_rdy_i = '1' and
                                                                     bc2_data_i(RQ_SEQ_NUM'range) = seq_num and bc2_rdy_i = '1' and
                                                                     bc3_data_i(RQ_SEQ_NUM'range) = seq_num and bc3_rdy_i = '1') or

                                   (card_addr_i = ALL_READOUT_CARDS and rc1_data_i(RQ_SEQ_NUM'range) = seq_num and rc1_rdy_i = '1' and
                                                                        rc2_data_i(RQ_SEQ_NUM'range) = seq_num and rc2_rdy_i = '1' and
                                                                        rc3_data_i(RQ_SEQ_NUM'range) = seq_num and rc3_rdy_i = '1' and
                                                                        rc4_data_i(RQ_SEQ_NUM'range) = seq_num and rc4_rdy_i = '1') or

                                   (card_addr_i = ALL_FPGA_CARDS and cc_data_i(RQ_SEQ_NUM'range) = seq_num and cc_rdy_i = '1' and
                                                                     ac_data_i(RQ_SEQ_NUM'range) = seq_num and ac_rdy_i = '1' and
                                                                     bc1_data_i(RQ_SEQ_NUM'range) = seq_num and bc1_rdy_i = '1' and
                                                                     bc2_data_i(RQ_SEQ_NUM'range) = seq_num and bc2_rdy_i = '1' and
                                                                     bc3_data_i(RQ_SEQ_NUM'range) = seq_num and bc3_rdy_i = '1' and
                                                                     rc1_data_i(RQ_SEQ_NUM'range) = seq_num and rc1_rdy_i = '1' and
                                                                     rc2_data_i(RQ_SEQ_NUM'range) = seq_num and rc2_rdy_i = '1' and
                                                                     rc3_data_i(RQ_SEQ_NUM'range) = seq_num and rc3_rdy_i = '1' and
                                                                     rc4_data_i(RQ_SEQ_NUM'range) = seq_num and rc4_rdy_i = '1')) then
                                   next_state <= CALC_DATA_SIZE;
                                elsif(timeout = '1') then
                                   next_state <= TIMED_OUT;
                                else
                                   next_state <= WAIT_FOR_REPLY;
                                end if;
                                    
         when CALC_DATA_SIZE => case card_addr_i is
                                   when CLOCK_CARD | 
                                        BIAS_CARD_1 | 
                                        BIAS_CARD_2 | 
                                        BIAS_CARD_3 | 
                                        ADDRESS_CARD | 
                                        READOUT_CARD_1 | 
                                        READOUT_CARD_2 | 
                                        READOUT_CARD_3 | 
                                        READOUT_CARD_4 =>    next_state <= MATCHED;
                                   
                                   when ALL_BIAS_CARDS =>    if(calc_count = 2) then
                                                                next_state <= MATCHED;
                                                             else
                                                                next_state <= CALC_DATA_SIZE;
                                                             end if;
                                                      
                                   when ALL_READOUT_CARDS => if(calc_count = 3) then
                                                                next_state <= MATCHED;
                                                             else
                                                                next_state <= CALC_DATA_SIZE;
                                                             end if;
                                   
                                   when ALL_FPGA_CARDS =>    if(calc_count = 8) then
                                                                next_state <= MATCHED;
                                                             else
                                                                next_state <= CALC_DATA_SIZE;
                                                             end if;
                                                          
                                   when others => next_state <= IDLE;
                                end case;

         when MATCHED =>        case card_addr_i is
                                   when CLOCK_CARD =>        next_state <= READ_CC;
                                   
                                   when BIAS_CARD_1 | 
                                        ALL_BIAS_CARDS =>    next_state <= READ_BC1;
                                   
                                   when BIAS_CARD_2 =>       next_state <= READ_BC2;
                                   
                                   when BIAS_CARD_3 =>       next_state <= READ_BC3;
                                   
                                   when ADDRESS_CARD | 
                                        ALL_FPGA_CARDS =>    next_state <= READ_AC;
                                   
                                   when READOUT_CARD_1 | 
                                        ALL_READOUT_CARDS => next_state <= READ_RC1;
                                   
                                   when READOUT_CARD_2 =>    next_state <= READ_RC2;
                                   
                                   when READOUT_CARD_3 =>    next_state <= READ_RC3;
                                   
                                   when READOUT_CARD_4 =>    next_state <= READ_RC4;
                                                             
                                   when others => next_state <= IDLE;
                                end case;
                                         
         when READ_AC =>        if(ac_rdy_i = '0') then
                                   case card_addr_i is
                                      when ALL_FPGA_CARDS => next_state <= READ_BC1;
                                      when others =>         next_state <= DONE;
                                   end case;
                                else
                                   next_state <= READ_AC;
                                end if;
         
         when READ_BC1 =>       if(bc1_rdy_i = '0') then
                                   case card_addr_i is
                                      when ALL_BIAS_CARDS |
                                           ALL_FPGA_CARDS => next_state <= READ_BC2;
                                      when others =>         next_state <= DONE;
                                   end case;
                                else
                                   next_state <= READ_BC1;
                                end if;
         
         when READ_BC2 =>       if(bc2_rdy_i = '0') then
                                   case card_addr_i is
                                      when ALL_BIAS_CARDS |
                                           ALL_FPGA_CARDS => next_state <= READ_BC3;
                                      when others =>         next_state <= DONE;
                                   end case;
                                else
                                   next_state <= READ_BC2;
                                end if;
                                
         when READ_BC3 =>       if(bc3_rdy_i = '0') then
                                   case card_addr_i is
                                      when ALL_FPGA_CARDS => next_state <= READ_RC1;
                                      when others =>         next_state <= DONE;
                                   end case;
                                else
                                   next_state <= READ_BC3;
                                end if;
         
         when READ_RC1 =>       if(rc1_rdy_i = '0') then
                                   case card_addr_i is
                                      when ALL_READOUT_CARDS |
                                           ALL_FPGA_CARDS => next_state <= READ_RC2;
                                      when others =>         next_state <= DONE;
                                   end case;
                                else
                                   next_state <= READ_RC1;
                                end if;
         
         when READ_RC2 =>       if(rc2_rdy_i = '0') then
                                   case card_addr_i is
                                      when ALL_READOUT_CARDS |
                                           ALL_FPGA_CARDS => next_state <= READ_RC3;
                                      when others =>         next_state <= DONE;
                                   end case;
                                else
                                   next_state <= READ_RC2;
                                end if;
                                
         when READ_RC3 =>       if(rc3_rdy_i = '0') then
                                   case card_addr_i is
                                      when ALL_READOUT_CARDS |
                                           ALL_FPGA_CARDS => next_state <= READ_RC4;
                                      when others =>         next_state <= DONE;
                                   end case;
                                else
                                   next_state <= READ_RC3;
                                end if;
         
         when READ_RC4 =>       if(rc4_rdy_i = '0') then
                                   case card_addr_i is
                                      when ALL_FPGA_CARDS => next_state <= READ_CC;
                                      when others =>         next_state <= DONE;
                                   end case;
                                else
                                   next_state <= READ_RC4;
                                end if;
         
         when READ_CC =>        if(cc_rdy_i = '0') then
                                   next_state <= DONE;
                                else
                                   next_state <= READ_CC;
                                end if;
         
         when TIMED_OUT =>      next_state <= IDLE;
                  
         when DONE =>           if(cmd_valid_i = '0') then
                                   next_state <= IDLE;
                                else
                                   next_state <= DONE;
                                end if;
      end case;
   end process state_NS;
   
   state_Out: process(pres_state, seq_num, calc_count, card_addr_i, ack_i,
                      ac_rdy_i,  bc1_rdy_i,  bc2_rdy_i,  bc3_rdy_i,  rc1_rdy_i,  rc2_rdy_i,  rc3_rdy_i,  rc4_rdy_i,  cc_rdy_i,  
                      ac_data_i, bc1_data_i, bc2_data_i, bc3_data_i, rc1_data_i, rc2_data_i, rc3_data_i, rc4_data_i, cc_data_i)
   begin
      timeout_clr    <= '1';
      accum_ena      <= '0';
      accum_clr      <= '0';
      calc_count_ena <= '0';
      calc_count_clr <= '0';
      
      ac_ack_o      <= '0';
      ac_discard_o  <= '0';
      
      bc1_ack_o     <= '0';
      bc1_discard_o <= '0';
      
      bc2_ack_o     <= '0';
      bc2_discard_o <= '0';
      
      bc3_ack_o     <= '0';
      bc3_discard_o <= '0';
      
      rc1_ack_o     <= '0';
      rc1_discard_o <= '0';
      
      rc2_ack_o     <= '0';
      rc2_discard_o <= '0';
      
      rc3_ack_o     <= '0';
      rc3_discard_o <= '0';
      
      rc4_ack_o     <= '0';
      rc4_discard_o <= '0';
      
      cc_ack_o      <= '0';
      cc_discard_o  <= '0';
      
      data_o    <= (others => '0');
      rdy_o     <= '0';
      matched_o <= '0';
      timeout_o <= '0';
      
      data_size <= (others => '0');
           
      case pres_state is
         when IDLE =>           accum_ena      <= '1';
                                accum_clr      <= '1';
                                calc_count_ena <= '1';
                                calc_count_clr <= '1';
      
         when WAIT_FOR_REPLY => timeout_clr    <= '0';
                                case card_addr_i is
                                   when CLOCK_CARD =>        if(cc_data_i(RQ_SEQ_NUM'range) < seq_num and cc_rdy_i = '1') then
                                                                ac_discard_o <= '1';
                                                             end if;
                                   
                                   when BIAS_CARD_1 =>       if(bc1_data_i(RQ_SEQ_NUM'range) < seq_num and bc1_rdy_i = '1') then
                                                                bc1_discard_o <= '1';
                                                             end if;
                                                              
                                   when BIAS_CARD_2 =>       if(bc2_data_i(RQ_SEQ_NUM'range) < seq_num and bc2_rdy_i = '1') then
                                                                bc2_discard_o <= '1';
                                                             end if;
                                                              
                                   when BIAS_CARD_3 =>       if(bc3_data_i(RQ_SEQ_NUM'range) < seq_num and bc3_rdy_i = '1') then
                                                                bc3_discard_o <= '1';
                                                             end if;
                                                             
                                   when ADDRESS_CARD =>      if(ac_data_i(RQ_SEQ_NUM'range) < seq_num and ac_rdy_i = '1') then
                                                                ac_discard_o <= '1';
                                                             end if;
                                                              
                                   when READOUT_CARD_1 =>    if(rc1_data_i(RQ_SEQ_NUM'range) < seq_num and rc1_rdy_i = '1') then
                                                                rc1_discard_o <= '1';
                                                             end if;
                                                              
                                   when READOUT_CARD_2 =>    if(rc2_data_i(RQ_SEQ_NUM'range) < seq_num and rc2_rdy_i = '1') then
                                                                rc2_discard_o <= '1';
                                                             end if;
                                                              
                                   when READOUT_CARD_3 =>    if(rc3_data_i(RQ_SEQ_NUM'range) < seq_num and rc3_rdy_i = '1') then
                                                                rc3_discard_o <= '1';
                                                             end if;
                                                              
                                   when READOUT_CARD_4 =>    if(rc4_data_i(RQ_SEQ_NUM'range) < seq_num and rc4_rdy_i = '1') then
                                                                rc4_discard_o <= '1';
                                                             end if;
                                                              
                                   when ALL_BIAS_CARDS =>    if(bc1_data_i(RQ_SEQ_NUM'range) < seq_num and bc1_rdy_i = '1') then
                                                                bc1_discard_o <= '1';
                                                             end if;
                                                             if(bc2_data_i(RQ_SEQ_NUM'range) < seq_num and bc2_rdy_i = '1') then
                                                                bc2_discard_o <= '1';
                                                             end if;
                                                             if(bc3_data_i(RQ_SEQ_NUM'range) < seq_num and bc3_rdy_i = '1') then
                                                                bc3_discard_o <= '1';
                                                             end if;
                                                              
                                   when ALL_READOUT_CARDS => if(rc1_data_i(RQ_SEQ_NUM'range) < seq_num and rc1_rdy_i = '1') then
                                                                rc1_discard_o <= '1';
                                                             end if;
                                                             if(rc2_data_i(RQ_SEQ_NUM'range) < seq_num and rc2_rdy_i = '1') then
                                                                rc2_discard_o <= '1';
                                                             end if;
                                                             if(rc3_data_i(RQ_SEQ_NUM'range) < seq_num and rc3_rdy_i = '1') then
                                                                rc3_discard_o <= '1';
                                                             end if;
                                                             if(rc4_data_i(RQ_SEQ_NUM'range) < seq_num and rc4_rdy_i = '1') then
                                                                rc4_discard_o <= '1';
                                                             end if;
                                                              
                                   when ALL_FPGA_CARDS =>    if(ac_data_i(RQ_SEQ_NUM'range) < seq_num and ac_rdy_i = '1') then
                                                                ac_discard_o <= '1';
                                                             end if;
                                                             if(bc1_data_i(RQ_SEQ_NUM'range) < seq_num and bc1_rdy_i = '1') then
                                                                bc1_discard_o <= '1';
                                                             end if;
                                                             if(bc2_data_i(RQ_SEQ_NUM'range) < seq_num and bc2_rdy_i = '1') then
                                                                bc2_discard_o <= '1';
                                                             end if;
                                                             if(bc3_data_i(RQ_SEQ_NUM'range) < seq_num and bc3_rdy_i = '1') then
                                                                bc3_discard_o <= '1';
                                                             end if;
                                                             if(rc1_data_i(RQ_SEQ_NUM'range) < seq_num and rc1_rdy_i = '1') then
                                                                rc1_discard_o <= '1';
                                                             end if;
                                                             if(rc2_data_i(RQ_SEQ_NUM'range) < seq_num and rc2_rdy_i = '1') then
                                                                rc2_discard_o <= '1';
                                                             end if;
                                                             if(rc3_data_i(RQ_SEQ_NUM'range) < seq_num and rc3_rdy_i = '1') then
                                                                rc3_discard_o <= '1';
                                                             end if;
                                                             if(rc4_data_i(RQ_SEQ_NUM'range) < seq_num and rc4_rdy_i = '1') then
                                                                rc4_discard_o <= '1';
                                                             end if;
                                                             if(cc_data_i(RQ_SEQ_NUM'range) < seq_num and cc_rdy_i = '1') then
                                                                cc_discard_o <= '1';
                                                             end if;
                                                               
                                   when others =>            null;
                                end case;
                  
         when CALC_DATA_SIZE => accum_ena      <= '1';
                                calc_count_ena <= '1';
                                
                                case card_addr_i is
                                   when CLOCK_CARD =>        cc_ack_o <= '1';
                                                             data_size <= cc_data_i(RQ_DATA_SIZE'range);

                                   when BIAS_CARD_1 =>       bc1_ack_o <= '1';
                                                             data_size <= bc1_data_i(RQ_DATA_SIZE'range);

                                   when BIAS_CARD_2 =>       bc2_ack_o <= '1';
                                                             data_size <= bc2_data_i(RQ_DATA_SIZE'range);

                                   when BIAS_CARD_3 =>       bc3_ack_o <= '1';
                                                             data_size <= bc3_data_i(RQ_DATA_SIZE'range);

                                   when ADDRESS_CARD =>      ac_ack_o <= '1';
                                                             data_size <= ac_data_i(RQ_DATA_SIZE'range);

                                   when READOUT_CARD_1 =>    rc1_ack_o <= '1';
                                                             data_size <= rc1_data_i(RQ_DATA_SIZE'range);

                                   when READOUT_CARD_2 =>    rc2_ack_o <= '1';
                                                             data_size <= rc2_data_i(RQ_DATA_SIZE'range);

                                   when READOUT_CARD_3 =>    rc3_ack_o <= '1';
                                                             data_size <= rc3_data_i(RQ_DATA_SIZE'range);

                                   when READOUT_CARD_4 =>    rc4_ack_o <= '1';
                                                             data_size <= rc4_data_i(RQ_DATA_SIZE'range);

                                   when ALL_BIAS_CARDS =>    case calc_count is
                                                                when 0 =>      bc1_ack_o <= '1';
                                                                               data_size <= bc1_data_i(RQ_DATA_SIZE'range);

                                                                when 1 =>      bc2_ack_o <= '1';
                                                                               data_size <= bc2_data_i(RQ_DATA_SIZE'range);
                                                                               
                                                                when 2 =>      bc3_ack_o <= '1';
                                                                               data_size <= bc3_data_i(RQ_DATA_SIZE'range);
                                                                when others => null;
                                                             end case;
                                                             
                                   when ALL_READOUT_CARDS => case calc_count is
                                                                when 0 =>      rc1_ack_o <= '1';
                                                                               data_size <= rc1_data_i(RQ_DATA_SIZE'range);
                                                                
                                                                when 1 =>      rc2_ack_o <= '1';
                                                                               data_size <= rc2_data_i(RQ_DATA_SIZE'range);

                                                                when 2 =>      rc3_ack_o <= '1';
                                                                               data_size <= rc3_data_i(RQ_DATA_SIZE'range);

                                                                when 3 =>      rc4_ack_o <= '1';
                                                                               data_size <= rc4_data_i(RQ_DATA_SIZE'range);
                                                                when others => null;
                                                             end case;
                                                             
                                   when ALL_FPGA_CARDS =>    case calc_count is
                                                                when 0 =>      ac_ack_o <= '1';
                                                                               data_size <= ac_data_i(RQ_DATA_SIZE'range);

                                                                when 1 =>      bc1_ack_o <= '1';
                                                                               data_size <= bc1_data_i(RQ_DATA_SIZE'range);

                                                                when 2 =>      bc2_ack_o <= '1';
                                                                               data_size <= bc2_data_i(RQ_DATA_SIZE'range);

                                                                when 3 =>      bc3_ack_o <= '1';
                                                                               data_size <= bc3_data_i(RQ_DATA_SIZE'range);

                                                                when 4 =>      rc1_ack_o <= '1';
                                                                               data_size <= rc1_data_i(RQ_DATA_SIZE'range);

                                                                when 5 =>      rc2_ack_o <= '1';
                                                                               data_size <= rc2_data_i(RQ_DATA_SIZE'range);

                                                                when 6 =>      rc3_ack_o <= '1';
                                                                               data_size <= rc3_data_i(RQ_DATA_SIZE'range);

                                                                when 7 =>      rc4_ack_o <= '1';
                                                                               data_size <= rc4_data_i(RQ_DATA_SIZE'range);

                                                                when 8 =>      cc_ack_o <= '1';
                                                                               data_size <= cc_data_i(RQ_DATA_SIZE'range);

                                                                when others => null;
                                                             end case;
                                                                
                                   when others =>            null;
                                end case;
         
         when MATCHED =>        matched_o <= '1';
         
         when READ_AC =>        data_o <= ac_data_i;
                                rdy_o <= ac_rdy_i;
                                ac_ack_o <= ack_i;

         when READ_BC1 =>       data_o <= bc1_data_i;
                                rdy_o <= bc1_rdy_i;
                                bc1_ack_o <= ack_i;

         when READ_BC2 =>       data_o <= bc2_data_i;
                                rdy_o <= bc2_rdy_i;
                                bc2_ack_o <= ack_i;

         when READ_BC3 =>       data_o <= bc3_data_i;
                                rdy_o <= bc3_rdy_i;
                                bc3_ack_o <= ack_i;

         when READ_RC1 =>       data_o <= rc1_data_i;
                                rdy_o <= rc1_rdy_i;
                                rc1_ack_o <= ack_i;

         when READ_RC2 =>       data_o <= rc2_data_i;
                                rdy_o <= rc2_rdy_i;
                                rc2_ack_o <= ack_i;

         when READ_RC3 =>       data_o <= rc3_data_i;
                                rdy_o <= rc3_rdy_i;
                                rc3_ack_o <= ack_i;

         when READ_RC4 =>       data_o <= rc4_data_i;
                                rdy_o <= rc4_rdy_i;
                                rc4_ack_o <= ack_i;

         when READ_CC =>        data_o <= cc_data_i;
                                rdy_o <= cc_rdy_i;
                                cc_ack_o <= ack_i;
         
         when TIMED_OUT =>      timeout_o <= '1';
         
         when DONE =>           null;
      end case;
   end process state_Out;
   
end rtl;