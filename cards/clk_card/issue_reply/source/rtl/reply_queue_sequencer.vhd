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
-- Revision 1.26  2006/09/15 00:48:36  bburger
-- Bryce:  Cleaned up the data word acknowledgement chain to speed things up.  Untested in hardware.  Data packets are un-simulated
--
-- Revision 1.25  2006/09/07 22:25:22  bburger
-- Bryce:  replace cmd_type (1-bit: read/write) interfaces and funtionality with cmd_code (32-bit: read_block/ write_block/ start/ stop/ reset) interface because reply_queue_sequencer needed to know to discard replies to reset commands
--
-- Revision 1.24  2006/09/06 00:27:11  bburger
-- Bryce:  added support for reset commands.  their replies are now discarded when they arrive from the backplane because the clock card has already sent a generic reply.
--
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library sys_param;
use sys_param.command_pack.all;
use sys_param.wishbone_pack.all;

library components;
use components.component_pack.all;

library work;
use work.issue_reply_pack.all;

entity reply_queue_sequencer is
port(
     -- for debugging
     timer_trigger_o   : out std_logic;

     comm_clk_i        : in std_logic;
     clk_i             : in std_logic;
     rst_i             : in std_logic;
     
     -- Bus Backplane interface
     lvds_reply_ac_a   : in std_logic;
     lvds_reply_bc1_a  : in std_logic;
     lvds_reply_bc2_a  : in std_logic;
     lvds_reply_bc3_a  : in std_logic;
     lvds_reply_rc1_a  : in std_logic;
     lvds_reply_rc2_a  : in std_logic;
     lvds_reply_rc3_a  : in std_logic;
     lvds_reply_rc4_a  : in std_logic;
     lvds_reply_cc_a   : in std_logic;
      
     card_data_size_i  : in std_logic_vector(BB_DATA_SIZE_WIDTH-1 downto 0);
     -- cmd_translator interface
     cmd_code_i        : in  std_logic_vector (FIBRE_PACKET_TYPE_WIDTH-1 downto 0);       -- the least significant 16-bits from the fibre packet
     par_id_i          : in std_logic_vector(BB_PARAMETER_ID_WIDTH-1 downto 0); 

     -- reply_queue_retire interface:
     card_addr_i       : in std_logic_vector(BB_CARD_ADDRESS_WIDTH-1 downto 0);
     cmd_valid_i       : in std_logic;
     matched_o         : out std_logic;
     timeout_o         : out std_logic;
     
     -- reply_translator interface:
     size_o            : out integer;
     error_o           : out std_logic_vector(30 downto 0);
     data_o            : out std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
     rdy_o             : out std_logic;
     ack_i             : in std_logic);
end reply_queue_sequencer;

architecture rtl of reply_queue_sequencer is

component reply_queue_receive
port(clk_i      : in std_logic;
     comm_clk_i : in std_logic;
     rst_i      : in std_logic;
     
     lvds_reply_i : in std_logic;     
     
     error_o : out std_logic_vector(2 downto 0);   -- 3 error bits: Tx CRC error, Rx CRC error, Execute Error
     data_o  : out std_logic_vector(31 downto 0);
     rdy_o   : out std_logic;
     ack_i   : in std_logic;
     clear_i : in std_logic);
end component;

type seq_states is (IDLE, WAIT_FOR_REPLY, READ_AC, READ_BC1, READ_BC2, READ_BC3, MATCHED, TIMED_OUT, 
                    READ_RC1, READ_RC2, READ_RC3, READ_RC4, READ_CC, DONE, STATUS_WORD, LATCH_ERROR, ERROR_WAIT1, ERROR_WAIT2, ERROR_WAIT3);
signal pres_state       : seq_states;
signal next_state       : seq_states;

--signal seq_num         : std_logic_vector(15 downto 0);

-- maybe register this
signal timeout          : std_logic;
signal timeout_clr      : std_logic;
signal timeout_count    : integer;

signal timeout_reg_set  : std_logic;
signal timeout_reg_clr  : std_logic;
signal timeout_reg_q    : std_logic;

signal datasize_reg_en  : std_logic;
signal datasize_reg_q   : std_logic_vector(BB_DATA_SIZE_WIDTH + 4 -1 downto 0);
signal num_cards        : std_logic_vector(3 downto 0);

signal cards_rdy        : std_logic_vector(9 downto 0);
signal cards_to_reply   : std_logic_vector(9 downto 0);
signal no_reply_yet     : std_logic_vector(9 downto 0);
signal wrong_cards      : std_logic_vector(9 downto 0);
-- Timeout:  Card Not Populated
signal timeout_not_pop  : std_logic_vector(9 downto 0);
-- Timeout:  Execution Error
signal timeout_error    : std_logic_vector(9 downto 0);
signal card_error       : std_logic_vector(9 downto 0);
signal half_done_error  : std_logic_vector(9 downto 0);
signal cumulative_error : std_logic_vector(9 downto 0);
signal update_status    : std_logic;


---------------------------------------------------------
-- FSM for latching out 0xDEADDEAD data
---------------------------------------------------------
constant err_dat        : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0) := x"FFFFFFFF";
constant ZEROS          : std_logic_vector(16-BB_DATA_SIZE_WIDTH-1 downto 0) := (others => '0'); 

-- output that indicates that there is an error word ready
-- is asserted for each card that must reply only as long as needed to clock out the correct number of error words
signal err_rdy          : std_logic;
signal err_count_ena    : std_logic;
signal err_count        : integer;
signal err_count_new    : integer;


---------------------------------------------------------
-- Debugging Logic
---------------------------------------------------------
signal timer_count     : integer;


---------------------------------------------------------
-- Reply_queue_receiver interface signals
---------------------------------------------------------
signal ac_error           : std_logic_vector(2 downto 0);
signal ac_data            : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
signal ac_rdy             : std_logic;
signal ac_ack             : std_logic;
signal ac_clear           : std_logic;

signal bc1_error          : std_logic_vector(2 downto 0);   
signal bc1_data           : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
signal bc1_rdy            : std_logic;
signal bc1_ack            : std_logic;
signal bc1_clear          : std_logic;
   
signal bc2_error          : std_logic_vector(2 downto 0);
signal bc2_data           : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
signal bc2_rdy            : std_logic;
signal bc2_ack            : std_logic;
signal bc2_clear          : std_logic;

signal bc3_error          : std_logic_vector(2 downto 0);   
signal bc3_data           : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
signal bc3_rdy            : std_logic;
signal bc3_ack            : std_logic;
signal bc3_clear          : std_logic;

signal rc1_error          : std_logic_vector(2 downto 0);   
signal rc1_data           : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
signal rc1_rdy            : std_logic;
signal rc1_ack            : std_logic;
signal rc1_clear          : std_logic;
   
signal rc2_error          : std_logic_vector(2 downto 0);   
signal rc2_data           : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
signal rc2_rdy            : std_logic;
signal rc2_ack            : std_logic;
signal rc2_clear          : std_logic;

signal rc3_error          : std_logic_vector(2 downto 0);   
signal rc3_data           : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
signal rc3_rdy            : std_logic;
signal rc3_ack            : std_logic;
signal rc3_clear          : std_logic;

signal rc4_error          : std_logic_vector(2 downto 0);   
signal rc4_data           : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
signal rc4_rdy            : std_logic;
signal rc4_ack            : std_logic;
signal rc4_clear          : std_logic;

signal cc_error           : std_logic_vector(2 downto 0);   
signal cc_data            : std_logic_vector(PACKET_WORD_WIDTH-1 downto 0);
signal cc_rdy             : std_logic;
signal cc_ack             : std_logic;
signal cc_clear           : std_logic;


begin

   ---------------------------------------------------------
   -- Receive FIFO Instantiations
   ---------------------------------------------------------   
   rx_ac : reply_queue_receive
      port map(
         clk_i        => clk_i,
         comm_clk_i   => comm_clk_i,
         rst_i        => rst_i,
               
         lvds_reply_i => lvds_reply_ac_a,
         
         error_o      => ac_error,    
         data_o       => ac_data,
         rdy_o        => ac_rdy,
         ack_i        => ac_ack,
         clear_i      => ac_clear
      );
   
   rx_bc1 : reply_queue_receive
      port map(
         clk_i        => clk_i,
         comm_clk_i   => comm_clk_i,
         rst_i        => rst_i,
               
         lvds_reply_i => lvds_reply_bc1_a,
             
         error_o      => bc1_error,    
         data_o       => bc1_data,
         rdy_o        => bc1_rdy,
         ack_i        => bc1_ack,
         clear_i      => bc1_clear
      );
   
   rx_bc2 : reply_queue_receive
      port map(
         clk_i        => clk_i,
         comm_clk_i   => comm_clk_i,
         rst_i        => rst_i,
               
         lvds_reply_i => lvds_reply_bc2_a,
             
         error_o      => bc2_error,    
         data_o       => bc2_data,
         rdy_o        => bc2_rdy,
         ack_i        => bc2_ack,
         clear_i      => bc2_clear
      );
   
   rx_bc3 : reply_queue_receive
      port map(
         clk_i        => clk_i,
         comm_clk_i   => comm_clk_i,
         rst_i        => rst_i,
               
         lvds_reply_i => lvds_reply_bc3_a,
             
         error_o      => bc3_error,    
         data_o       => bc3_data,
         rdy_o        => bc3_rdy,
         ack_i        => bc3_ack,
         clear_i      => bc3_clear
      );
      
   rx_rc1 : reply_queue_receive
      port map(
         clk_i        => clk_i,
         comm_clk_i   => comm_clk_i,
         rst_i        => rst_i,
               
         lvds_reply_i => lvds_reply_rc1_a,
             
         error_o      => rc1_error,    
         data_o       => rc1_data,
         rdy_o        => rc1_rdy,
         ack_i        => rc1_ack,
         clear_i      => rc1_clear
      );
      
   rx_rc2 : reply_queue_receive
      port map(
         clk_i        => clk_i,
         comm_clk_i   => comm_clk_i,
         rst_i        => rst_i,
               
         lvds_reply_i => lvds_reply_rc2_a,
             
         error_o      => rc2_error,    
         data_o       => rc2_data,
         rdy_o        => rc2_rdy,
         ack_i        => rc2_ack,
         clear_i      => rc2_clear
      );
      
   rx_rc3 : reply_queue_receive
      port map(
         clk_i        => clk_i,
         comm_clk_i   => comm_clk_i,
         rst_i        => rst_i,
               
         lvds_reply_i => lvds_reply_rc3_a,
             
         error_o      => rc3_error,    
         data_o       => rc3_data,
         rdy_o        => rc3_rdy,
         ack_i        => rc3_ack,
         clear_i      => rc3_clear
      );
      
   rx_rc4 : reply_queue_receive
      port map(
         clk_i        => clk_i,
         comm_clk_i   => comm_clk_i,
         rst_i        => rst_i,
               
         lvds_reply_i => lvds_reply_rc4_a,
             
         error_o      => rc4_error,    
         data_o       => rc4_data,
         rdy_o        => rc4_rdy,
         ack_i        => rc4_ack,
         clear_i      => rc4_clear
      );
   
   rx_cc : reply_queue_receive
      port map(
         clk_i        => clk_i,
         comm_clk_i   => comm_clk_i,
         rst_i        => rst_i,
               
         lvds_reply_i => lvds_reply_cc_a,
             
         error_o      => cc_error,    
         data_o       => cc_data,
         rdy_o        => cc_rdy,
         ack_i        => cc_ack,
         clear_i      => cc_clear
      );
     

   ---------------------------------------------------------
   -- Continuous Assignments
   ---------------------------------------------------------
   error_o <= 
      '0' & -- This bit was originally used as the timeout bit for all cards.  Now unused.
      -- The bit order from left to right of the following lines is:
      -- (a) Timeout because card not present
      -- (b) CRC error or other timeout error
      -- (c) Wishbone execution error
      timeout_not_pop(9) & cumulative_error(9) & ac_error(0)  & 
      timeout_not_pop(8) & cumulative_error(8) & bc1_error(0) & 
      timeout_not_pop(7) & cumulative_error(7) & bc2_error(0) & 
      timeout_not_pop(6) & cumulative_error(6) & bc3_error(0) & 
      timeout_not_pop(5) & cumulative_error(5) & rc1_error(0) & 
      timeout_not_pop(4) & cumulative_error(4) & rc2_error(0) & 
      timeout_not_pop(3) & cumulative_error(3) & rc3_error(0) & 
      timeout_not_pop(2) & cumulative_error(2) & rc4_error(0) & 
      timeout_not_pop(1) & cumulative_error(1) & cc_error(0)  & 
      '0' & '0' & '0'; -- This last line is for the PSU, should it ever be implemented

   ---------------------------------------------------------
   -- Error FSM
   ---------------------------------------------------------   
   err_count_new <= err_count + 1;
   err_counter: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         err_count <= 0;
      elsif(clk_i'event and clk_i = '1') then
         if(err_count >= conv_integer(card_data_size_i)) then
            err_count <= 0;
         -- I don't think that I need the err_rdy = '1' condition here, because err_count_ena will only be asserted if err_rdy is already asserted.
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
         ((pres_state = READ_AC)  and (ac_rdy = '1'))  or
         ((pres_state = READ_BC1) and (bc1_rdy = '1')) or
         ((pres_state = READ_BC2) and (bc2_rdy = '1')) or
         ((pres_state = READ_BC3) and (bc3_rdy = '1')) or
         ((pres_state = READ_RC1) and (rc1_rdy = '1')) or
         ((pres_state = READ_RC2) and (rc2_rdy = '1')) or
         ((pres_state = READ_RC3) and (rc3_rdy = '1')) or
         ((pres_state = READ_RC4) and (rc4_rdy = '1')) or
         ((pres_state = READ_CC)  and (cc_rdy = '1'))) then
            err_rdy <= '0';
         elsif(timeout_reg_q = '1' and err_count < conv_integer(card_data_size_i)) then
            err_rdy <= '1';
         else
            err_rdy <= '0';
         end if;     
      end if;
   end process err_word_fsm;   
   
   ---------------------------------------------------------
   -- Status Word Registers
   ---------------------------------------------------------   
   status_word_ff: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         -- Resetting to '1' to clear the slate and record whether a card ever replies.
         no_reply_yet        <= (others => '1');
         wrong_cards         <= (others => '0');
         timeout_not_pop     <= (others => '0');
         timeout_error       <= (others => '0');
         cumulative_error    <= (others => '0');
      elsif(clk_i'event and clk_i = '1') then
         -- Cascaded logic
         -- The states are for sequential stages of the logic
         if(pres_state = LATCH_ERROR) then
            -- The Carnot Maps for this logic are Bryce Burger's SCUBA2 Logbook #8
            -- wrong_cards indicates that the wrong card has responded to the command.
            wrong_cards      <= (half_done_error and (not cards_to_reply));
            -- cumulative_error is any sort of error that is not due to a card not being populated or a wishbone error.
            cumulative_error <= card_error or timeout_error;
         elsif(pres_state = ERROR_WAIT1) then
            -- no_reply_yet indicates that a card that was supposed to respond has not sent a reply yet
            no_reply_yet     <= (no_reply_yet and (((not cards_to_reply) and wrong_cards) or ((not cards_rdy) and (not wrong_cards))));
         elsif(pres_state = ERROR_WAIT2) then
            -- timeout_not_pop indicates that a card has timed out because it is not populated.  The Clock Card assumes a card is not populated until the first response from that card
            timeout_not_pop  <= (cards_to_reply and (not cards_rdy) and no_reply_yet and (not wrong_cards));
            -- timeout_error can occur after the Clock Card has received a successful response from a card.
            -- timeout_error indicates that the receiver has not received an answer from a card that was supposed to reply because it is populated. 
            timeout_error    <= (cards_to_reply and (not cards_rdy) and (not no_reply_yet) and (not wrong_cards)) or ((not cards_to_reply) and cards_rdy and wrong_cards);
         else
            no_reply_yet        <= no_reply_yet;
            wrong_cards         <= wrong_cards;
            timeout_not_pop     <= timeout_not_pop;
            timeout_error       <= timeout_error;
            cumulative_error    <= cumulative_error;
         end if;      
      end if;
   end process;

   -- The card-error bit is set if the receiver has detected any sort of CRC error over the backplane in either direction
   card_error <= 
      ac_error(1) & bc1_error(1) & bc2_error(1) & bc3_error(1) & rc1_error(1) & rc2_error(1) & rc3_error(1) & rc4_error(1) & '0' & cc_error(1) when (card_addr_i = POWER_SUPPLY_CARD) else
      ac_error(1) & bc1_error(1) & bc2_error(1) & bc3_error(1) & rc1_error(1) & rc2_error(1) & rc3_error(1) & rc4_error(1) & cc_error(1) & '0';
   
   -- The half-done bit is set if the receiver has started receiving something, but has not finished
   half_done_error <= 
      ac_error(2) & bc1_error(2) & bc2_error(2) & bc3_error(2) & rc1_error(2) & rc2_error(2) & rc3_error(2) & rc4_error(2) & '0' & cc_error(2) when (card_addr_i = POWER_SUPPLY_CARD) else
      ac_error(2) & bc1_error(2) & bc2_error(2) & bc3_error(2) & rc1_error(2) & rc2_error(2) & rc3_error(2) & rc4_error(2) & cc_error(2) & '0';
   
   -- Note the two last bits are both "cc_rdy" because the Power Supply Controller is a sub-block of the Clock Card
   cards_rdy <= 
      ac_rdy & bc1_rdy & bc2_rdy & bc3_rdy & rc1_rdy & rc2_rdy & rc3_rdy & rc4_rdy & '0' & cc_rdy when (card_addr_i = POWER_SUPPLY_CARD) else
      ac_rdy & bc1_rdy & bc2_rdy & bc3_rdy & rc1_rdy & rc2_rdy & rc3_rdy & rc4_rdy & cc_rdy & '0';
   
   cards_to_reply <=
      "0000000000" when (card_addr_i = NO_CARDS) else
      "0000000001" when (card_addr_i = POWER_SUPPLY_CARD) else
      "0000000010" when (card_addr_i = CLOCK_CARD) else
      "0000000100" when (card_addr_i = READOUT_CARD_4) else
      "0000001000" when (card_addr_i = READOUT_CARD_3) else
      "0000010000" when (card_addr_i = READOUT_CARD_2) else
      "0000100000" when (card_addr_i = READOUT_CARD_1) else
      "0001000000" when (card_addr_i = BIAS_CARD_3) else
      "0010000000" when (card_addr_i = BIAS_CARD_2) else
      "0100000000" when (card_addr_i = BIAS_CARD_1) else
      "1000000000" when (card_addr_i = ADDRESS_CARD) else
      "0111000000" when (card_addr_i = ALL_BIAS_CARDS) else
      "0000111100" when (card_addr_i = ALL_READOUT_CARDS) else
      "1111111110" when (card_addr_i = ALL_FPGA_CARDS) else
      "1111111111" when (card_addr_i = ALL_CARDS) else
      "0000000000";

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
      x"0" when 
         (card_addr_i = NO_CARDS) else
      x"1" when 
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
      x"3" when
         (card_addr_i = ALL_BIAS_CARDS) else
      x"4" when
         (card_addr_i = ALL_READOUT_CARDS) else
      x"9" when
         (card_addr_i = ALL_FPGA_CARDS) else
      x"A" when
         (card_addr_i = ALL_CARDS) else
      x"0";         
      
   size_o <= conv_integer(datasize_reg_q);
   datasize_reg: process(clk_i, rst_i)
   begin
      if(rst_i = '1') then
         datasize_reg_q <= (others => '0');
      elsif(clk_i'event and clk_i = '1') then
         if(datasize_reg_en = '1') then
            datasize_reg_q <= num_cards * card_data_size_i;
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
      (par_id_i /= RET_DAT_ADDR and timeout_count >= CMD_TIMEOUT_LIMIT) or
      (par_id_i = RET_DAT_ADDR and timeout_count >= DATA_TIMEOUT_LIMIT) else '0';  -- TIMEOUT_LIMIT is defined in reply_queue_pack   
      
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
   
   state_NS: process(pres_state, timeout, cmd_valid_i, card_addr_i, err_rdy, ack_i,
                     ac_rdy, bc1_rdy, bc2_rdy, bc3_rdy, rc1_rdy, rc2_rdy, rc3_rdy, rc4_rdy, cc_rdy, cmd_code_i)
   begin
      -- Default Assignments
      next_state <= pres_state;
      
      case pres_state is
         when IDLE =>           
            if(cmd_valid_i = '1') then
               next_state <= WAIT_FOR_REPLY;
            else
               next_state <= IDLE;
            end if;
                                 
         when WAIT_FOR_REPLY => 
            if((card_addr_i = CLOCK_CARD and cc_rdy = '1') or
               (card_addr_i = POWER_SUPPLY_CARD and cc_rdy = '1') or
               (card_addr_i = ADDRESS_CARD and ac_rdy = '1') or
               (card_addr_i = BIAS_CARD_1 and bc1_rdy = '1') or
               (card_addr_i = BIAS_CARD_2 and bc2_rdy = '1') or
               (card_addr_i = BIAS_CARD_3 and bc3_rdy = '1') or
               (card_addr_i = READOUT_CARD_1 and rc1_rdy = '1') or
               (card_addr_i = READOUT_CARD_2 and rc2_rdy = '1') or
               (card_addr_i = READOUT_CARD_3 and rc3_rdy = '1') or
               (card_addr_i = READOUT_CARD_4 and rc4_rdy = '1') or
               (card_addr_i = ALL_BIAS_CARDS and 
                  bc1_rdy = '1' and 
                  bc2_rdy = '1' and 
                  bc3_rdy = '1') or
               (card_addr_i = ALL_READOUT_CARDS and 
                  rc1_rdy = '1' and 
                  rc2_rdy = '1' and 
                  rc3_rdy = '1' and 
                  rc4_rdy = '1') or
               (card_addr_i = ALL_FPGA_CARDS and 
                  cc_rdy = '1' and 
                  ac_rdy = '1' and 
                  bc1_rdy = '1' and 
                  bc2_rdy = '1' and 
                  bc3_rdy = '1' and 
                  rc1_rdy = '1' and 
                  rc2_rdy = '1' and 
                  rc3_rdy = '1' and 
                  rc4_rdy = '1')) then
                  next_state <= LATCH_ERROR;
               elsif(timeout = '1') then
                  next_state <= TIMED_OUT;
               else
                  next_state <= WAIT_FOR_REPLY;
               end if;
         
         when LATCH_ERROR =>
               next_state <= ERROR_WAIT1;

         when ERROR_WAIT1 =>
               next_state <= ERROR_WAIT2;
                                    
         when ERROR_WAIT2 =>
               next_state <= ERROR_WAIT3;

         when ERROR_WAIT3 =>
               next_state <= MATCHED;

         when MATCHED =>
            if (cmd_code_i = RESET) then
               next_state <= DONE;
            else
               next_state <= STATUS_WORD;
            end if;                             
         when READ_AC =>        
            if(ac_rdy = '1' or err_rdy = '1') then
               next_state <= READ_AC;
            elsif(ac_rdy = '0' and err_rdy = '0') then
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
            if(bc1_rdy = '1' or err_rdy = '1') then
               next_state <= READ_BC1;
            elsif(bc1_rdy = '0' and err_rdy = '0') then
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
            if(bc2_rdy = '1' or err_rdy = '1') then
               next_state <= READ_BC2;
            elsif(bc2_rdy = '0' and err_rdy = '0') then
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
            if(bc3_rdy = '1' or err_rdy = '1') then
               next_state <= READ_BC3;
            elsif(bc3_rdy = '0' and err_rdy = '0') then
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
            if(rc1_rdy = '1' or err_rdy = '1') then
               next_state <= READ_RC1;
            elsif(rc1_rdy = '0' and err_rdy = '0') then
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
            if(rc2_rdy = '1' or err_rdy = '1') then
               next_state <= READ_RC2;
            elsif(rc2_rdy = '0' and err_rdy = '0') then
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
            if(rc3_rdy = '1' or err_rdy = '1') then
               next_state <= READ_RC3;
            elsif(rc3_rdy = '0' and err_rdy = '0') then
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
            if(rc4_rdy = '1' or err_rdy = '1') then
               next_state <= READ_RC4;
            elsif(rc4_rdy = '0' and err_rdy = '0') then
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
            if(cc_rdy = '1' or err_rdy = '1') then
               next_state <= READ_CC;
            elsif(cc_rdy = '0' and err_rdy = '0') then
               next_state <= DONE;
            end if;

         when TIMED_OUT =>      
            next_state <= LATCH_ERROR;
         
         when STATUS_WORD =>
            -- If the status word is acknowledged
            if(ack_i = '1') then
               -- If there is data to read
               if(cmd_code_i = READ_BLOCK) then
                  case card_addr_i is
                     when CLOCK_CARD | POWER_SUPPLY_CARD => 
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
            next_state <= IDLE;
         
         when others =>
            next_state <= IDLE;

      end case;
   end process state_NS;
   
   data_o <=
      ac_data  when pres_state = READ_AC  and ac_rdy = '1'  else
      bc1_data when pres_state = READ_BC1 and bc1_rdy = '1' else
      bc2_data when pres_state = READ_BC2 and bc2_rdy = '1' else
      bc3_data when pres_state = READ_BC3 and bc3_rdy = '1' else
      rc1_data when pres_state = READ_RC1 and rc1_rdy = '1' else
      rc2_data when pres_state = READ_RC2 and rc2_rdy = '1' else
      rc3_data when pres_state = READ_RC3 and rc3_rdy = '1' else
      rc4_data when pres_state = READ_RC4 and rc4_rdy = '1' else
      cc_data  when pres_state = READ_CC  and cc_rdy = '1'  else
      err_dat;

   state_Out: process(pres_state, ack_i, cmd_valid_i,
      ac_rdy, bc1_rdy, bc2_rdy, bc3_rdy, rc1_rdy, rc2_rdy, rc3_rdy, rc4_rdy, cc_rdy)
   begin
      update_status <= '0';
      
      timeout_clr   <= '1';
     
      ac_ack        <= '0';
      ac_clear      <= '0';
      
      bc1_ack       <= '0';
      bc1_clear     <= '0';
      
      bc2_ack       <= '0';
      bc2_clear     <= '0';
      
      bc3_ack       <= '0';
      bc3_clear     <= '0';
      
      rc1_ack       <= '0';
      rc1_clear     <= '0';
      
      rc2_ack       <= '0';
      rc2_clear     <= '0';
      
      rc3_ack       <= '0';
      rc3_clear     <= '0';
      
      rc4_ack       <= '0';
      rc4_clear     <= '0';
      
      cc_ack        <= '0';
      cc_clear      <= '0';
      
      rdy_o         <= '0';
      matched_o     <= '0';
      timeout_o     <= '0';
      
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
            timeout_clr      <= '0';

         when LATCH_ERROR =>
            update_status    <= '1';

         when ERROR_WAIT1 =>
                                    
         when ERROR_WAIT2 =>
                             
         when ERROR_WAIT3 =>

         when MATCHED =>        
            matched_o        <= '1';
         
         when READ_AC =>        
            if(ac_rdy = '1') then 
               rdy_o         <= ac_rdy;
               ac_ack        <= ack_i;
            else
               rdy_o         <= '1';
               err_count_ena <= ack_i;
            end if;

         when READ_BC1 =>       
            if(bc1_rdy = '1') then 
               rdy_o         <= bc1_rdy;
               bc1_ack       <= ack_i;
            else
               rdy_o         <= '1';
               err_count_ena <= ack_i;
            end if;

         when READ_BC2 =>       
            if(bc2_rdy = '1') then 
               rdy_o         <= bc2_rdy;
               bc2_ack       <= ack_i;
            else
               rdy_o         <= '1';
               err_count_ena <= ack_i;
            end if;

         when READ_BC3 =>       
            if(bc3_rdy = '1') then 
               rdy_o         <= bc3_rdy;
               bc3_ack       <= ack_i;
            else
               rdy_o         <= '1';
               err_count_ena <= ack_i;
            end if;

         when READ_RC1 =>       
            if(rc1_rdy = '1') then 
               rdy_o         <= rc1_rdy;
               rc1_ack       <= ack_i;
            else
               rdy_o         <= '1';
               err_count_ena <= ack_i;
            end if;
            
         when READ_RC2 =>       
            if(rc2_rdy = '1') then 
               rdy_o         <= rc2_rdy;
               rc2_ack       <= ack_i;
            else
               rdy_o         <= '1';
               err_count_ena <= ack_i;
            end if;
            
         when READ_RC3 =>       
            if(rc3_rdy = '1') then 
               rdy_o         <= rc3_rdy;
               rc3_ack       <= ack_i;
            else
               rdy_o         <= '1';
               err_count_ena <= ack_i;
            end if;
            
         when READ_RC4 =>       
            if(rc4_rdy = '1') then 
               rdy_o         <= rc4_rdy;
               rc4_ack       <= ack_i;
            else
               rdy_o         <= '1';
               err_count_ena <= ack_i;
            end if;
            
         when READ_CC =>        
            if(cc_rdy = '1') then 
               rdy_o         <= cc_rdy;
               cc_ack        <= ack_i;
            else
               rdy_o         <= '1';
               err_count_ena <= ack_i;
            end if;
         
         when TIMED_OUT =>      
            timeout_o        <= '1';
            timeout_reg_set  <= '1';                                

         when STATUS_WORD =>
            rdy_o            <= '1';
            
            -- Even if there is just a status word (no data) we don't have to pipe through the ack, because the DONE state below
            -- takes care of clearing the reply_queue_receive blocks once we're done with them
         
         when DONE =>           
            timeout_reg_clr  <= '1';
            ac_clear         <= '1';            
            bc1_clear        <= '1';            
            bc2_clear        <= '1';            
            bc3_clear        <= '1';            
            rc1_clear        <= '1';            
            rc2_clear        <= '1';            
            rc3_clear        <= '1';            
            rc4_clear        <= '1';            
            cc_clear         <= '1';
         
         when others =>
            null;            

      end case;
   end process state_Out;
   
end rtl;