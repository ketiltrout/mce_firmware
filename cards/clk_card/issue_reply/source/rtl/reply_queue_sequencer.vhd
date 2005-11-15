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
-- Revision 1.15  2005/03/31 16:55:58  bburger
-- Bryce:  added special logic analyzer trigger signals for debugging
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

     clk_i         : in std_logic;
     rst_i         : in std_logic;
     
     -- reply_queue_receive FIFO interfaces:
     ac_data_i     : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
     ac_rdy_i      : in std_logic;
     ac_ack_o      : out std_logic;
     ac_discard_o  : out std_logic;
          
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
          
     cc_data_i     : in std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
     cc_rdy_i      : in std_logic;
     cc_ack_o      : out std_logic;
     cc_discard_o  : out std_logic;
     
     card_data_size_i : in std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);
     cmd_code_i       : in std_logic_vector(BB_COMMAND_TYPE_WIDTH-1 downto 0);

     -- reply_queue_retire interface:
     macro_op_i    : in std_logic_vector(BB_MACRO_OP_SEQ_WIDTH-1 downto 0);
     micro_op_i    : in std_logic_vector(BB_MICRO_OP_SEQ_WIDTH-1 downto 0);
     card_addr_i   : in std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0);
     cmd_valid_i   : in std_logic;
     matched_o     : out std_logic;
     timeout_o     : out std_logic;
     
     -- reply_translator interface:
     size_o        : out integer;
     error_o       : out std_logic_vector(29 downto 0);
     data_o        : out std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
     rdy_o         : out std_logic;
     ack_i         : in std_logic);
end reply_queue_sequencer;

architecture rtl of reply_queue_sequencer is

type seq_states is (IDLE, WAIT_FOR_REPLY, READ_AC, READ_BC1, READ_BC2, READ_BC3, MATCHED, TIMED_OUT, --CALC_DATA_SIZE, 
                    READ_RC1, READ_RC2, READ_RC3, READ_RC4, READ_CC, DONE, STATUS_WORD);
signal pres_state      : seq_states;
signal next_state      : seq_states;

signal seq_num         : std_logic_vector(15 downto 0);

signal timeout         : std_logic;
signal timeout_clr     : std_logic;
signal timeout_count   : integer;

signal timeout_reg_set : std_logic;
signal timeout_reg_clr : std_logic;
signal timeout_reg_q   : std_logic;

signal datasize_reg_en : std_logic;
signal datasize_reg_q  : std_logic_vector(63 downto 0);
signal num_cards       : std_logic_vector(31 downto 0);

signal status          : std_logic_vector(29 downto 0);


---------------------------------------------------------
-- FSM for latching out 0xDEADDEAD data
---------------------------------------------------------
constant err_dat     : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0) := x"DEADDEAD";

-- output that indicates that there is an error word ready
-- is asserted for each card that must reply only as long as needed to clock out the correct number of error words
signal err_rdy       : std_logic;

signal err_count_ena : std_logic;
signal err_count_clr : std_logic;
signal err_count     : integer;
signal err_count_new : integer;


---------------------------------------------------------
-- Debugging Logic
---------------------------------------------------------
signal timer_count     : integer;

begin

   ---------------------------------------------------------
   -- Continuous Assignments
   ---------------------------------------------------------
   seq_num  <= macro_op_i & micro_op_i;   

   -- This eventually needs to change
   error_o  <= status;
   status <= "00000000000000000000000000000" & timeout_reg_q;
--   error_o <= ac_data_i(31 downto 29)  & bc1_data_i(31 downto 29) & bc2_data_i(31 downto 29) & bc3_data_i(31 downto 29) &
--              rc1_data_i(31 downto 29) & rc2_data_i(31 downto 29) & rc3_data_i(31 downto 29) & rc4_data_i(31 downto 29) &
--              cc_data_i(31 downto 29) & "000";

   ---------------------------------------------------------
   -- Error Word FSM
   ---------------------------------------------------------   
   err_count_new <= err_count + 1;
   err_counter: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         err_count <= 0;
      elsif(clk_i'event and clk_i = '1') then
         if(err_count >= conv_integer(card_data_size_i)) then
            err_count <= 0;
         elsif(err_rdy = '1' and err_count_ena = '1') then
            err_count <= err_count_new;
         end if;
      end if;
   end process err_counter;
   
   -- The err_rdy signal's behavior is akin to the rdy signal from the reply_queue_receive blocks.
   -- However, the err_rdy signal is only used when an error has occurred.
   err_word_fsm: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         err_rdy <= '0';         
      elsif(clk_i'event and clk_i = '1') then         
         if(
         -- This state machine needs one clock cycle of set up time, during the MATCHED state
         --(pres_state = MATCHED) or 
         (pres_state = DONE) or
         ((pres_state = READ_AC) and (ac_rdy_i = '1')) or
         ((pres_state = READ_BC1) and (bc1_rdy_i = '1')) or
         ((pres_state = READ_BC2) and (bc2_rdy_i = '1')) or
         ((pres_state = READ_BC3) and (bc3_rdy_i = '1')) or
         ((pres_state = READ_RC1) and (rc1_rdy_i = '1')) or
         ((pres_state = READ_RC2) and (rc2_rdy_i = '1')) or
         ((pres_state = READ_RC3) and (rc3_rdy_i = '1')) or
         ((pres_state = READ_RC4) and (rc4_rdy_i = '1')) or
         ((pres_state = READ_CC) and (cc_rdy_i = '1'))) then
            err_rdy <= '0';
         elsif(timeout_reg_q = '1' and err_count < conv_integer(card_data_size_i)) then
            err_rdy <= '1';
         else
            err_rdy <= '0';
         end if;     
      end if;
   end process err_word_fsm;   
   
   ---------------------------------------------------------
   -- Registers
   ---------------------------------------------------------
   timeout_reg: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         timeout_reg_q <= '0';
      elsif(clk_i'event and clk_i = '1') then
         if(timeout_reg_clr = '1') then
            timeout_reg_q <= '0';
         elsif(timeout_reg_set = '1') then
            timeout_reg_q <= '1';
         end if;
      end if;
   end process timeout_reg;

   num_cards <= 
      x"00000000" when 
         (card_addr_i = NO_CARDS) else
      x"00000001" when 
         ((card_addr_i = POWER_SUPPLY_CARD) or 
         (card_addr_i = CLOCK_CARD) or 
         (card_addr_i = READOUT_CARD_1) or 
         (card_addr_i = READOUT_CARD_2) or 
         (card_addr_i = READOUT_CARD_3) or 
         (card_addr_i = READOUT_CARD_4) or 
         (card_addr_i = BIAS_CARD_1) or 
         (card_addr_i = BIAS_CARD_2) or 
         (card_addr_i = BIAS_CARD_3) or 
         (card_addr_i = ADDRESS_CARD)) else
      x"00000003" when
         (card_addr_i = ALL_BIAS_CARDS) else
      x"00000004" when
         (card_addr_i = ALL_READOUT_CARDS) else
      x"00000009" when
         (card_addr_i = ALL_FPGA_CARDS) else
      x"0000000A" when
         (card_addr_i = ALL_CARDS) else
      x"00000000";         
      
   size_o <= conv_integer(datasize_reg_q(31 downto 0));
   datasize_reg: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         datasize_reg_q <= (others => '0');
      elsif(clk_i'event and clk_i = '1') then
         if(datasize_reg_en = '1') then
            datasize_reg_q <= num_cards * ("0000000000000000000" & card_data_size_i);
         end if;
      end if;
   end process datasize_reg;
   
   ---------------------------------------------------------
   -- Debugging Logic
   ---------------------------------------------------------
   -- This timer will allow us to trigger earlier to monitor the timeout of commands with little data.
   -- The purpose of time is to provide a trigger to track down unreliablility issues.
   
   timer_trigger_o <= '1' when timer_count >= 600 else '0';
   trigger_timer : us_timer
      port map(
         clk           => clk_i,
         timer_reset_i => timeout_clr,
         timer_count_o => timer_count
      );
   
   ---------------------------------------------------------
   -- Command Timeout Logic
   ---------------------------------------------------------
   -- timeout_clr is exercised such that the timer only counts when there is a command in flight.
 
   timeout_timer : us_timer
   port map(clk => clk_i,
            timer_reset_i => timeout_clr,
            timer_count_o => timeout_count);
   
   timeout <= '1' when 
      (cmd_code_i /= DATA and timeout_count >= CMD_TIMEOUT_LIMIT) or
      (cmd_code_i = DATA and timeout_count >= DATA_TIMEOUT_LIMIT) else '0';  -- TIMEOUT_LIMIT is defined in reply_queue_pack   
      
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
   
   state_NS: process(pres_state, timeout, cmd_valid_i, card_addr_i, err_rdy, cmd_code_i, ack_i,
                     ac_rdy_i,  bc1_rdy_i,  bc2_rdy_i,  bc3_rdy_i,  rc1_rdy_i,  rc2_rdy_i,  rc3_rdy_i,  rc4_rdy_i,  cc_rdy_i)
   begin
      case pres_state is
         when IDLE =>           
            if(cmd_valid_i = '1') then
               next_state <= WAIT_FOR_REPLY;
            else
               next_state <= IDLE;
            end if;
                                 
         when WAIT_FOR_REPLY => 
            if((card_addr_i = CLOCK_CARD and 
                  cc_rdy_i = '1') or
               (card_addr_i = ADDRESS_CARD and 
                  ac_rdy_i = '1') or
               (card_addr_i = BIAS_CARD_1 and 
                  bc1_rdy_i = '1') or
               (card_addr_i = BIAS_CARD_2 and 
                  bc2_rdy_i = '1') or
               (card_addr_i = BIAS_CARD_3 and 
                  bc3_rdy_i = '1') or
               (card_addr_i = READOUT_CARD_1 and 
                  rc1_rdy_i = '1') or
               (card_addr_i = READOUT_CARD_2 and 
                  rc2_rdy_i = '1') or
               (card_addr_i = READOUT_CARD_3 and 
                  rc3_rdy_i = '1') or
               (card_addr_i = READOUT_CARD_4 and 
                  rc4_rdy_i = '1') or
               (card_addr_i = ALL_BIAS_CARDS and 
                  bc1_rdy_i = '1' and 
                  bc2_rdy_i = '1' and 
                  bc3_rdy_i = '1') or
               (card_addr_i = ALL_READOUT_CARDS and 
                  rc1_rdy_i = '1' and 
                  rc2_rdy_i = '1' and 
                  rc3_rdy_i = '1' and 
                  rc4_rdy_i = '1') or
               (card_addr_i = ALL_FPGA_CARDS and 
                  cc_rdy_i = '1' and 
                  ac_rdy_i = '1' and 
                  bc1_rdy_i = '1' and 
                  bc2_rdy_i = '1' and 
                  bc3_rdy_i = '1' and 
                  rc1_rdy_i = '1' and 
                  rc2_rdy_i = '1' and 
                  rc3_rdy_i = '1' and 
                  rc4_rdy_i = '1')) then
                  next_state <= MATCHED;
               elsif(timeout = '1') then
                  next_state <= TIMED_OUT;
               else
                  next_state <= WAIT_FOR_REPLY;
               end if;
                                    
         when MATCHED =>        
               next_state <= STATUS_WORD;
                                         
         when READ_AC =>        
            if(ac_rdy_i = '1' or err_rdy = '1') then
               next_state <= READ_AC;
            elsif(ac_rdy_i = '0' and err_rdy = '0') then
               case card_addr_i is
                  when ALL_FPGA_CARDS => 
                     next_state <= READ_BC1;
                  when others =>         
                     next_state <= DONE;
               end case;
            else
               next_state <= READ_AC;
            end if;
         
         when READ_BC1 =>       
            if(bc1_rdy_i = '1' or err_rdy = '1') then
               next_state <= READ_BC1;
            elsif(bc1_rdy_i = '0' and err_rdy = '0') then
               case card_addr_i is
                  when ALL_FPGA_CARDS => 
                     next_state <= READ_BC2;
                  when others =>         
                     next_state <= DONE;
               end case;
            else
               next_state <= READ_BC1;
            end if;
         
         when READ_BC2 =>       
            if(bc2_rdy_i = '1' or err_rdy = '1') then
               next_state <= READ_BC2;
            elsif(bc2_rdy_i = '0' and err_rdy = '0') then
               case card_addr_i is
                  when ALL_FPGA_CARDS => 
                     next_state <= READ_BC3;
                  when others =>         
                     next_state <= DONE;
               end case;
            else
               next_state <= READ_BC2;
            end if;
                                
         when READ_BC3 =>       
            if(bc3_rdy_i = '1' or err_rdy = '1') then
               next_state <= READ_BC3;
            elsif(bc3_rdy_i = '0' and err_rdy = '0') then
               case card_addr_i is
                  when ALL_FPGA_CARDS => 
                     next_state <= READ_RC1;
                  when others =>         
                     next_state <= DONE;
               end case;
            else
               next_state <= READ_BC3;
            end if;

         when READ_RC1 =>       
            if(rc1_rdy_i = '1' or err_rdy = '1') then
               next_state <= READ_RC1;
            elsif(rc1_rdy_i = '0' and err_rdy = '0') then
               case card_addr_i is
                  when ALL_READOUT_CARDS | ALL_FPGA_CARDS => 
                     next_state <= READ_RC2;
                  when others =>         
                     next_state <= DONE;
               end case;
            else
               next_state <= READ_RC1;
            end if;
         
         when READ_RC2 =>       
            if(rc2_rdy_i = '1' or err_rdy = '1') then
               next_state <= READ_RC2;
            elsif(rc2_rdy_i = '0' and err_rdy = '0') then
               case card_addr_i is
                  when ALL_READOUT_CARDS | ALL_FPGA_CARDS => 
                     next_state <= READ_RC3;
                  when others =>         
                     next_state <= DONE;
               end case;
            else
               next_state <= READ_RC2;
            end if;
                                
         when READ_RC3 =>       
            if(rc3_rdy_i = '1' or err_rdy = '1') then
               next_state <= READ_RC3;
            elsif(rc3_rdy_i = '0' and err_rdy = '0') then
               case card_addr_i is
                  when ALL_READOUT_CARDS | ALL_FPGA_CARDS => 
                     next_state <= READ_RC4;
                  when others =>         
                     next_state <= DONE;
               end case;
            else
               next_state <= READ_RC3;
            end if;
         
         when READ_RC4 =>       
            if(rc4_rdy_i = '1' or err_rdy = '1') then
               next_state <= READ_RC4;
            elsif(rc4_rdy_i = '0' and err_rdy = '0') then
               case card_addr_i is
                  when ALL_FPGA_CARDS => 
                     next_state <= READ_CC;
                  when others =>         
                     next_state <= DONE;
               end case;
            else
               next_state <= READ_RC4;
            end if;
         
         when READ_CC =>        
            if(cc_rdy_i = '1' or err_rdy = '1') then
               next_state <= READ_CC;
            elsif(cc_rdy_i = '0' and err_rdy = '0') then
               next_state <= DONE;
            end if;

         when TIMED_OUT =>      
            next_state <= MATCHED;
         
         when STATUS_WORD =>
            -- If the status word is acknowledged
            if(ack_i = '1') then
               -- If there is data to read
               if(cmd_code_i = READ_BLOCK or cmd_code_i = DATA) then
                  case card_addr_i is
                     when CLOCK_CARD => 
                        next_state <= READ_CC;
                     when BIAS_CARD_1 | ALL_BIAS_CARDS =>    
                        next_state <= READ_BC1;
                     when BIAS_CARD_2 =>       
                        next_state <= READ_BC2;
                     when BIAS_CARD_3 =>       
                        next_state <= READ_BC3;
                     when ADDRESS_CARD | ALL_FPGA_CARDS =>    
                        next_state <= READ_AC;
                     when READOUT_CARD_1 | ALL_READOUT_CARDS => 
                        next_state <= READ_RC1;
                     when READOUT_CARD_2 =>    
                        next_state <= READ_RC2;
                     when READOUT_CARD_3 =>    
                        next_state <= READ_RC3;
                     when READOUT_CARD_4 =>    
                        next_state <= READ_RC4;
                     when others => 
                        next_state <= IDLE;
                  end case;
               -- Otherwise, we are done
               else
                  next_state <= DONE;
               end if;
            end if;
            
         when DONE =>           
            if(cmd_valid_i = '0') then
               next_state <= IDLE;
            else
               next_state <= DONE;
            end if;
      end case;
   end process state_NS;
   
   state_Out: process(pres_state, ack_i, cmd_valid_i, --status, cmd_code_i, err_rdy, calc_count, next_state,  seq_num, card_addr_i,
                      ac_rdy_i,  bc1_rdy_i,  bc2_rdy_i,  bc3_rdy_i,  rc1_rdy_i,  rc2_rdy_i,  rc3_rdy_i,  rc4_rdy_i,  cc_rdy_i,  
                      ac_data_i, bc1_data_i, bc2_data_i, bc3_data_i, rc1_data_i, rc2_data_i, rc3_data_i, rc4_data_i, cc_data_i)
   begin
      timeout_clr    <= '1';
     
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
      
      datasize_reg_en <= '0';      
      timeout_reg_set <= '0';
      timeout_reg_clr <= '0';
      
      err_count_ena   <= '0';
           
      case pres_state is
         when IDLE =>           
            if(cmd_valid_i = '1') then
               datasize_reg_en <= '1';
            end if;
      
         when WAIT_FOR_REPLY => 
            timeout_clr     <= '0';
                             
         when MATCHED =>        
            matched_o <= '1';
         
         when READ_AC =>        
            if(ac_rdy_i = '1') then 
               data_o        <= ac_data_i;
               rdy_o         <= ac_rdy_i;
               ac_ack_o      <= ack_i;
            else
               data_o        <= err_dat;
               rdy_o         <= '1';
               err_count_ena <= ack_i;
            end if;

         when READ_BC1 =>       
            if(bc1_rdy_i = '1') then 
               data_o        <= bc1_data_i;
               rdy_o         <= bc1_rdy_i;
               bc1_ack_o     <= ack_i;
            else
               data_o        <= err_dat;
               rdy_o         <= '1';
               err_count_ena <= ack_i;
            end if;

         when READ_BC2 =>       
            if(bc2_rdy_i = '1') then 
               data_o        <= bc2_data_i;
               rdy_o         <= bc2_rdy_i;
               bc2_ack_o     <= ack_i;
            else
               data_o        <= err_dat;
               rdy_o         <= '1';
               err_count_ena <= ack_i;
            end if;

         when READ_BC3 =>       
            if(bc3_rdy_i = '1') then 
               data_o        <= bc3_data_i;
               rdy_o         <= bc3_rdy_i;
               bc3_ack_o     <= ack_i;
            else
               data_o        <= err_dat;
               rdy_o         <= '1';
               err_count_ena <= ack_i;
            end if;

         when READ_RC1 =>       
            if(rc1_rdy_i = '1') then 
               data_o        <= rc1_data_i;
               rdy_o         <= rc1_rdy_i;
               rc1_ack_o     <= ack_i;
            else
               data_o        <= err_dat;
               rdy_o         <= '1';
               err_count_ena <= ack_i;
            end if;
            
         when READ_RC2 =>       
            if(rc2_rdy_i = '1') then 
               data_o        <= rc2_data_i;
               rdy_o         <= rc2_rdy_i;
               rc2_ack_o     <= ack_i;
            else
               data_o        <= err_dat;
               rdy_o         <= '1';
               err_count_ena <= ack_i;
            end if;
            
         when READ_RC3 =>       
            if(rc3_rdy_i = '1') then 
               data_o        <= rc3_data_i;
               rdy_o         <= rc3_rdy_i;
               rc3_ack_o     <= ack_i;
            else
               data_o        <= err_dat;
               rdy_o         <= '1';
               err_count_ena <= ack_i;
            end if;
            
         when READ_RC4 =>       
            if(rc4_rdy_i = '1') then 
               data_o        <= rc4_data_i;
               rdy_o         <= rc4_rdy_i;
               rc4_ack_o     <= ack_i;
            else
               data_o        <= err_dat;
               rdy_o         <= '1';
               err_count_ena <= ack_i;
            end if;
            
         when READ_CC =>        
            if(cc_rdy_i = '1') then 
               data_o        <= cc_data_i;
               rdy_o         <= cc_rdy_i;
               cc_ack_o      <= ack_i;
            else
               data_o        <= err_dat;
               rdy_o         <= '1';
               err_count_ena <= ack_i;
            end if;
         
         when TIMED_OUT =>      
            timeout_o <= '1';
            timeout_reg_set <= '1';                                

         when STATUS_WORD =>
            data_o       <= x"EFF1CACE";
            rdy_o        <= '1';
            
            -- Currently, if no error occurs, the first word expressed by the reply_queue_receive block is the mop number.
            -- This has to be ack'd before the first word of data is displayed
            -- ***However, this will change when ernie's new implementation of the reply_queue_receive block.
            -- ***This section eventually has to be changed so that error checking is done on a card-by-card basis
            
            -- In Ernie's new implementation, if there has been an error on this receiver, or no data is to be collected then pipe the ack through to the receiver.
            -- Otherwise, don't pipe the ack through, because the ack would advance the receiver to the next data word.
            
--            if(status(0) = '1' or (status(0) = '0' and cmd_code_i /= DATA and cmd_code_i /= READ_BLOCK)) then
               cc_ack_o     <= ack_i;
--            end if;
--            if(status(0) = '1' or (status(0) = '0' and cmd_code_i /= DATA and cmd_code_i /= READ_BLOCK)) then
               rc4_ack_o    <= ack_i;
--            end if;
--            if(status(0) = '1' or (status(0) = '0' and cmd_code_i /= DATA and cmd_code_i /= READ_BLOCK)) then
               rc3_ack_o    <= ack_i;
--            end if;
--            if(status(0) = '1' or (status(0) = '0' and cmd_code_i /= DATA and cmd_code_i /= READ_BLOCK)) then
               rc2_ack_o    <= ack_i;
--            end if;
--            if(status(0) = '1' or (status(0) = '0' and cmd_code_i /= DATA and cmd_code_i /= READ_BLOCK)) then
               rc1_ack_o    <= ack_i;
--            end if;
--            if(status(0) = '1' or (status(0) = '0' and cmd_code_i /= DATA and cmd_code_i /= READ_BLOCK)) then
               bc3_ack_o    <= ack_i;
--            end if;
--            if(status(0) = '1' or (status(0) = '0' and cmd_code_i /= DATA and cmd_code_i /= READ_BLOCK)) then
               bc2_ack_o    <= ack_i;
--            end if;
--            if(status(0) = '1' or (status(0) = '0' and cmd_code_i /= DATA and cmd_code_i /= READ_BLOCK)) then
               bc1_ack_o    <= ack_i;
--            end if;
--            if(status(0) = '1' or (status(0) = '0' and cmd_code_i /= DATA and cmd_code_i /= READ_BLOCK)) then
               ac_ack_o     <= ack_i;            
--            end if;
         
         when DONE =>           
            timeout_reg_clr <= '1';

      end case;
   end process state_Out;
   
end rtl;